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


- Configure eks to point the cluster in the terminal

```bash
aws eks update-kubeconfig --region us-east-1 --name <clustern-name>
```

- Export vars for reusability
```bash
export CLUSTER_NAME=<cluster_name>
export FARGATE_PROFILE=<profile_name>
export ACCOUNT_ID=<account_id>
export POD_EXECUTION_ROLE=<role_name>
export VPC_ID=<vpc_id>
export SUBNET_ID_1=<subnet_1_id>
export SUBNET_ID_2=<subnet_2_id>
```

- Recreate fargate profile (because coredns not working)(maybe we can edit cloudformation template)
```bash
aws eks delete-fargate-profile --cluster-name $CLUSTER_NAME --fargate-profile-name $FARGATE_PROFILE
```

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

- Set up logs - Create and attack policy to allow fluent bit to create log groups in cloudwatch (only one time per account!!):

```bash
curl -o ~/Desktop/loggin-permissions-eks.json https://raw.githubusercontent.com/aws-samples/amazon-eks-fluent-logging-examples/mainline/examples/fargate/cloudwatchlogs/permissions.json
aws iam create-policy --policy-name eks-fargate-logging-policy --policy-document file://~/Desktop/loggin-permissions-eks.json
```

- Set up logs - Create and 

```bash
aws iam attach-role-policy \                                                                                                                                                                                        ✔ 
  --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/eks-fargate-logging-policy \
  --role-name $POD_EXECUTION_ROLE
```

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
> Note: Remember to replace values in alb.ingress.kubernetes.io/subnets with the subnets ids specified in SUBNET_ID_1 and SUBNET_ID_2 (TODO: we will need to use helm for this)
```bash
kubectl apply -f ingress.yml
```

- Verify:

```bash
kubectl logs -n kube-system deployment.apps/aws-load-balancer-controller
```

- Create Api Gateway using cloudformation deploy in `ApiGateWay.yaml`