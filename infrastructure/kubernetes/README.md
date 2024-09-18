# EKS infrastructure provisioning and deployment guide

## Infrastructure Setup

Run [`EKS-Cluster.yaml`] in AWS Cloud Formation, specifying the following parameters
  - `VpcId`: The vpc id of the private subnets where the cluster will be instantiated.
  - `SubnetA`, `SubnetB`: **Private subnets** where te cluster will be instantiated. The subnets should be private because we will use an api gateway to make the cluster public.
  - `AvailabilityZones`: zones where the cluster will be available.
  - `ClusterName`: The name of the cluster, this will be used as a prefix for name the resources created by the template (Cluster, FargateProfile, Roles)
  - `Environment`: The name of the environment, this will be used as a prefix for name the resources created by the template (Cluster, FargateProfile, Roles)


Then, configure eks to point the cluster in the terminal

```bash
aws eks update-kubeconfig --region us-east-1 --name <clustern-name>
```

It is recommended to export vars for reusability - the rest of this guide will use these variables
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


## Fix Fargate profile 

As a next step, we need to recreate fargate profile. OOTB, Coredns is not working because fargate create nodes matching namespaces and labels in the fargate profile, but cloudformation is creating the profile with the namespace kube-system and empty labels list - instead of ignore this key to tell fargate that all pods in that namespace should be managed by fargate. NOTE: this might be provided in the Cloudformation template in the future

```bash
aws eks delete-fargate-profile --cluster-name $CLUSTER_NAME --fargate-profile-name $FARGATE_PROFILE
```

You should wait a few minutes until the profile is completely deleted. Then create the Fargate profile again

```bash
aws eks create-fargate-profile --cluster-name $CLUSTER_NAME \
--fargate-profile-name $FARGATE_PROFILE \
--pod-execution-role-arn arn:aws:iam::$ACCOUNT_ID:role/$POD_EXECUTION_ROLE \
--subnets $SUBNET_ID_1 $SUBNET_ID_2 \
--selectors namespace=kube-system
```

You can  check if it was created by running

```bash
aws eks describe-fargate-profile --cluster-name $CLUSTER_NAME --fargate-profile-name $FARGATE_PROFILE
```

Then we need to restart Coredns

```bash
kubectl rollout restart deployment coredns -n kube-system
```

Let's check that is running properly - we need to ensure that Status is Running and Ready and we see 1/1

```bash
kubectl get pods -n kube-system
```

## Cloudwatch log integration

Next step is to set up Cloudwatch logs observability - via configmap

```bash
kubectl apply -f aws-observability-namespace.yaml
kubectl apply -f aws-logging-cloudwatch-configmap.yaml
```

**If it is the first time we set up Fluent Bit in this account**, we need to Create policy to allow fluent bit to create log groups in Cloudwatch

```bash
curl -o ~/loggin-permissions-eks.json https://raw.githubusercontent.com/aws-samples/amazon-eks-fluent-logging-examples/mainline/examples/fargate/cloudwatchlogs/permissions.json
aws iam create-policy --policy-name eks-fargate-logging-policy --policy-document file://~/loggin-permissions-eks.json
rm ~/loggin-permissions-eks.json
```

We need to attach the policy to the pod execution role

```bash
aws iam attach-role-policy \                                                                                                                                                                                        ✔ 
  --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/eks-fargate-logging-policy \
  --role-name $POD_EXECUTION_ROLE
```

To verify the correct set up, we can go to cloudwatch and search for `fluent-bit` in log groups

## Deploying a test app into the cluster, including a load balancer

You can run the following deployment that will start an nginx server

```bash
kubectl apply -f nginx-deployment.yml
```

To verify if the deploy was successful, just run

```bash
kubectl get deployments -n kube-system
```

You must see `Ready -> 1/1 and Available -> 1`


### Installing AWS LB controller via Helm

Now, it is time to set up the load balancer. Let's first add the EKS charts into helm

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
```

Now, **if it is the first time that a EKS cluster is created into the account**, we need to set up the policy for adding the AWS LB controller

```bash
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

aws iam create-policy \
--policy-name AWSLoadBalancerControllerIAMPolicy \
--policy-document file://iam-policy.json

rm iam-policy.json
```

Finally, we ssociate the IAM Policy to the cluster

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

We can verify if the LB was associated correctly by running

```bash
kubectl get serviceaccount aws-load-balancer-controller -n kube-system
```

And now, we install the controller

```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=$VPC_ID \
  --namespace kube-system
```

We can verify the installation by running

```bash
kubectl get deployments -n kube-system
```

### Deploying the service

Now, let's deploy a sample service to expose the ports

```bash
kubectl apply -f nginx-service.yml
```

And then we deploy the Ingress to provide external connectivity - **Note: Remember to replace values in alb.ingress.kubernetes.io/subnets with the subnets ids specified in SUBNET_ID_1 and SUBNET_ID_2. Remember that these subnets should be private (TODO: we will need to use helm for this)**

```bash
kubectl apply -f ingress.yml
```

We can verify the deployment by running

```bash
kubectl logs -n kube-system deployment.apps/aws-load-balancer-controller
```

## API Gateway creation

Since the service deployed currently is running in a private subnet, we need to expose it via an API Gateway. We can create a new one by using the [`ApiGateWay.yaml`](ApiGateWay.yaml) template. It requires the following parameters
  
  - VpcLinkName: The name to assign to the vpc link
  - VpcSubnetIds: Private subnets of the load balancer (the private subnets that you specified in the `ingress.yml`)
  - HttpApiName: The name of the api gateway
  - LoadBalancerArn: Arn of the load balancer where the gateway should point
  - LoadBalancerListenerArn: Arn of the listener in the load balancer that you specified in `LoadBalancerArn`