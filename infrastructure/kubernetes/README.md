# Quick EKS guide

First, ensure that you have the AWS credentials already set up. Then, run

```bash
aws eks update-kubeconfig --region us-east-1 --name <clustern-name>
```

## Some useful/testing commands

```bash
# Applies a new testing deployment
kubectl apply -f nginx-deployment.yml

# Check deployments
kubectl get deployments --all-namespaces
```

## Infrastructure Setup

- Run `EKS-Cluster.yaml` in AWS Cloud Formation
    
  - Parameters of the cloud formation template:
    - VpcId: The vpc id of the private subnets where the cluster will be instantiated.
    - SubnetA, SubnetB: **Private subnets** where te cluster will be instantiated. The subnets should be private because we will use an api gateway to make the cluster public.
    - AvailabilityZones: zones where the cluster will be available.
    - ClusterName: The name of the cluster, this will be used as a prefix for name the resources created by the template (Cluster, FargateProfile, Roles)
    - Environment: The name of the environment, this will be used as a prefix for name the resources created by the template (Cluster, FargateProfile, Roles)


- Configure eks to point the cluster in the terminal

```bash
aws eks update-kubeconfig --region us-east-1 --name <clustern-name>
```

- Export vars for reusability
```bash
export ACCOUNT_ID=<account_id>
export CLUSTER_NAME=<ClusterName>
export ENVIRONMENT=<dev | qa | prod>
export FARGATE_PROFILE="$ENVIRONMENT-$CLUSTER_NAME-fargate-profile"
export POD_EXECUTION_ROLE="$ENVIRONMENT-$CLUSTER_NAME-fargate-pod-execution-role"
export VPC_ID=<VpcId>
export SUBNET_ID_1=<SubnetA>
export SUBNET_ID_2=<SubnetB>
```

- Recreate fargate profile. Coredns is not working because fargate create nodes matching namespaces and labels in the fargate profile, but cloudformation is creating the profile with the namespace kube-system and empty labels list (instead of ignore this key to tell fargate that all pods in that namespace should be managed by fargate) (maybe we can edit cloudformation template)
```bash
aws eks delete-fargate-profile --cluster-name $CLUSTER_NAME --fargate-profile-name $FARGATE_PROFILE
```
> You should wait a few minutes until the profile is completely deleted

```bash
aws eks create-fargate-profile --cluster-name $CLUSTER_NAME \
--fargate-profile-name $FARGATE_PROFILE \
--pod-execution-role-arn arn:aws:iam::$ACCOUNT_ID:role/$POD_EXECUTION_ROLE \
--subnets $SUBNET_ID_1 $SUBNET_ID_2 \
--selectors namespace=kube-system
```

- Verification:

```bash
aws eks describe-fargate-profile --cluster-name $CLUSTER_NAME --fargate-profile-name $FARGATE_PROFILE
```

- Restart coredns after fargate profile is active

```bash
kubectl rollout restart deployment coredns -n kube-system
```

- Verification:
```bash
kubectl get pods -n kube-system
```
> Status -> Running and Ready -> 1/1

- Set up logs - Create namespace and config map:

```bash
kubectl apply -f aws-observability-namespace.yaml
kubectl apply -f aws-logging-cloudwatch-configmap.yaml
```

- Set up logs - Create policy to allow fluent bit to create log groups in cloudwatch (only one time per account!!):

```bash
curl -o ~/loggin-permissions-eks.json https://raw.githubusercontent.com/aws-samples/amazon-eks-fluent-logging-examples/mainline/examples/fargate/cloudwatchlogs/permissions.json
aws iam create-policy --policy-name eks-fargate-logging-policy --policy-document file://~/loggin-permissions-eks.json
rm ~/loggin-permissions-eks.json
```

- Set up logs - Attach policy to role

```bash
aws iam attach-role-policy \                                                                                                                                                                                        ✔ 
  --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/eks-fargate-logging-policy \
  --role-name $POD_EXECUTION_ROLE
```

- Verification:

  - Go to cloudwatch and search for `fluent-bit` in log groups


- Set up nginx

```bash
kubectl apply -f nginx-deployment.yml
```

- Verification:

```bash
kubectl get deployments -n kube-system
```
> Ready -> 1/1 and Available -> 1

- Add eks-charts:

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
```

- Create AWS Policy (only one time per account!!)

```bash
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

aws iam create-policy \
--policy-name AWSLoadBalancerControllerIAMPolicy \
--policy-document file://iam-policy.json

rm iam-policy.json
```

- Associate policy to cluster:

```bash
eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=$CLUSTER_NAME --approve
```

```bash
eksctl create iamserviceaccount \
  --region=us-east-1 \
  --name aws-load-balancer-controller \
  --namespace kube-system \
  --cluster=$CLUSTER_NAME \
  --attach-policy-arn=arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

- Verification:

```bash
kubectl get serviceaccount aws-load-balancer-controller -n kube-system
```

- Install load balancer controller:
```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=$VPC_ID \
  --namespace kube-system
```

- Verification:

```bash
kubectl get deployments -n kube-system
```

- Deploy service to expose port:

```bash
kubectl apply -f nginx-service.yml
```

- Deploy ingress to create App Load Balancer
> Note: Remember to replace values in alb.ingress.kubernetes.io/subnets with the subnets ids specified in SUBNET_ID_1 and SUBNET_ID_2, remember that these subnets should be private (TODO: we will need to use helm for this)
```bash
kubectl apply -f ingress.yml
```

- Verify:

```bash
kubectl logs -n kube-system deployment.apps/aws-load-balancer-controller
```

- Create Api Gateway using cloudformation deploy in `ApiGateWay.yaml`

  - Parameters:
  
    - VpcLinkName: The name to assign to the vpc link
    - VpcSubnetIds: Private subnets of the load balancer (the private subnets that you specified in the `ingress.yml`)
    - HttpApiName: The name of the api gateway
    - LoadBalancerArn: Arn of the load balancer where the gateway should point
    - LoadBalancerListenerArn: Arn of the listener in the load balancer that you specified in `LoadBalancerArn`