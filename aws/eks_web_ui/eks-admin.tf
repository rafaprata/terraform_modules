resource "kubernetes_manifest" "serviceaccount_kube_system_eks_admin" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "name" = "eks-admin"
      "namespace" = "kube-system"
    }
  }
  depends_on = [
    kubernetes_manifest.deployment_kubernetes_dashboard_dashboard_metrics_scraper
  ]
}

resource "kubernetes_manifest" "clusterrolebinding_eks_admin" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "eks-admin"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "cluster-admin"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "eks-admin"
        "namespace" = "kube-system"
      },
    ]
  }
  depends_on = [
    kubernetes_manifest.serviceaccount_kube_system_eks_admin
  ]
}

resource "kubernetes_manifest" "secret_kube_system_eks_admin" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Secret"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/service-account.name" = "eks-admin"
      }
      "name" = "eks-admin"
      "namespace" = "kube-system"
    }
    "type" = "kubernetes.io/service-account-token"
  }
  depends_on = [
    kubernetes_manifest.clusterrolebinding_eks_admin
  ]
}