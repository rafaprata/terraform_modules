# AWS Load Balancer Controller add-on for EKS

The AWS Load Balancer Controller manages AWS Elastic Load Balancers for a Kubernetes cluster.

> An AWS Application Load Balancer (ALB) when you create a Kubernetes ***Ingress***.

> An AWS Network Load Balancer (NLB) when you create a Kubernetes service of type ***LoadBalancer***.

More information: https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html

---
### How to use this module?
```
module "aws_lb_controller" { 
    source = "github.com/raxkumar/terraform_modules/aws/aws_lb_controller" 
    cluster_name = "eks_cluster_name" 
    region = "eks_cluster_deployed_region" 
}
```