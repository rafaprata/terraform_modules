data "http" "aws_lb_controller_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json"

  request_headers = {
    Accept = "application/json"
  }
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "wdi_eks" {
  name = var.cluster_name
}

locals {
  wdi_eks_oidc_id = split("/", data.aws_eks_cluster.wdi_eks.identity[0].oidc[0].issuer)[length(split("/", data.aws_eks_cluster.wdi_eks.identity[0].oidc[0].issuer)) - 1]
  eks_charts      = "https://aws.github.io/eks-charts"
}

resource "aws_iam_policy" "lb_controller" {
  name        = "${var.cluster_name}_AWSLoadBalancerControllerIAMPolicy"
  policy      = tostring(data.http.aws_lb_controller_policy.response_body)
  description = "Load Balancer Controller add-on for EKS"
}

resource "aws_iam_role" "lb_controller" {
  name = "${var.cluster_name}_AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.region}.amazonaws.com/id/${local.wdi_eks_oidc_id}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "oidc.eks.${var.region}.amazonaws.com/id/${local.wdi_eks_oidc_id}:aud" : "sts.amazonaws.com",
            "oidc.eks.${var.region}.amazonaws.com/id/${local.wdi_eks_oidc_id}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  role       = aws_iam_role.lb_controller.name
  policy_arn = aws_iam_policy.lb_controller.arn
}

resource "kubernetes_service_account" "lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.lb_controller.name}"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lb_controller
  ]
}

resource "helm_release" "lb_controller" {
  repository      = local.eks_charts
  name            = "aws-load-balancer-controller"
  chart           = "aws-load-balancer-controller"
  namespace       = "kube-system"
  cleanup_on_fail = true
  force_update    = false

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  depends_on = [
    kubernetes_service_account.lb_controller
  ]
}
