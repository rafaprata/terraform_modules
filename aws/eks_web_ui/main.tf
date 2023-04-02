resource "kubernetes_manifest" "namespace_kubernetes_dashboard" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Namespace"
    "metadata" = {
      "name" = "kubernetes-dashboard"
    }
  }
}

resource "kubernetes_manifest" "serviceaccount_kubernetes_dashboard_kubernetes_dashboard" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "labels" = {
        "k8s-app" = "kubernetes-dashboard"
      }
      "name" = "kubernetes-dashboard"
      "namespace" = "kubernetes-dashboard"
    }
  }
    depends_on = [
    kubernetes_manifest.namespace_kubernetes_dashboard
  ]
}

resource "kubernetes_manifest" "service_kubernetes_dashboard_kubernetes_dashboard" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "k8s-app" = "kubernetes-dashboard"
      }
      "name" = "kubernetes-dashboard"
      "namespace" = "kubernetes-dashboard"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 443
          "targetPort" = 8443
        },
      ]
      "selector" = {
        "k8s-app" = "kubernetes-dashboard"
      }
    }
  }
  depends_on = [
    kubernetes_manifest.serviceaccount_kubernetes_dashboard_kubernetes_dashboard
  ]
}

resource "kubernetes_manifest" "secret_kubernetes_dashboard_kubernetes_dashboard_certs" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Secret"
    "metadata" = {
      "labels" = {
        "k8s-app" = "kubernetes-dashboard"
      }
      "name" = "kubernetes-dashboard-certs"
      "namespace" = "kubernetes-dashboard"
    }
    "type" = "Opaque"
  }
  depends_on = [
    kubernetes_manifest.service_kubernetes_dashboard_kubernetes_dashboard
  ]
}

resource "kubernetes_manifest" "secret_kubernetes_dashboard_kubernetes_dashboard_csrf" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "csrf" = ""
    }
    "kind" = "Secret"
    "metadata" = {
      "labels" = {
        "k8s-app" = "kubernetes-dashboard"
      }
      "name" = "kubernetes-dashboard-csrf"
      "namespace" = "kubernetes-dashboard"
    }
    "type" = "Opaque"
  }
  depends_on = [
    kubernetes_manifest.secret_kubernetes_dashboard_kubernetes_dashboard_certs
  ]
}

resource "kubernetes_manifest" "secret_kubernetes_dashboard_kubernetes_dashboard_key_holder" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Secret"
    "metadata" = {
      "labels" = {
        "k8s-app" = "kubernetes-dashboard"
      }
      "name" = "kubernetes-dashboard-key-holder"
      "namespace" = "kubernetes-dashboard"
    }
    "type" = "Opaque"
  }
  depends_on = [
    kubernetes_manifest.secret_kubernetes_dashboard_kubernetes_dashboard_csrf
  ]
}

resource "kubernetes_manifest" "configmap_kubernetes_dashboard_kubernetes_dashboard_settings" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ConfigMap"
    "metadata" = {
      "labels" = {
        "k8s-app" = "kubernetes-dashboard"
      }
      "name" = "kubernetes-dashboard-settings"
      "namespace" = "kubernetes-dashboard"
    }
  }
  depends_on = [
    kubernetes_manifest.secret_kubernetes_dashboard_kubernetes_dashboard_key_holder
  ]
}

resource "kubernetes_manifest" "role_kubernetes_dashboard_kubernetes_dashboard" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "labels" = {
        "k8s-app" = "kubernetes-dashboard"
      }
      "name" = "kubernetes-dashboard"
      "namespace" = "kubernetes-dashboard"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resourceNames" = [
          "kubernetes-dashboard-key-holder",
          "kubernetes-dashboard-certs",
          "kubernetes-dashboard-csrf",
        ]
        "resources" = [
          "secrets",
        ]
        "verbs" = [
          "get",
          "update",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resourceNames" = [
          "kubernetes-dashboard-settings",
        ]
        "resources" = [
          "configmaps",
        ]
        "verbs" = [
          "get",
          "update",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resourceNames" = [
          "heapster",
          "dashboard-metrics-scraper",
        ]
        "resources" = [
          "services",
        ]
        "verbs" = [
          "proxy",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resourceNames" = [
          "heapster",
          "http:heapster:",
          "https:heapster:",
          "dashboard-metrics-scraper",
          "http:dashboard-metrics-scraper",
        ]
        "resources" = [
          "services/proxy",
        ]
        "verbs" = [
          "get",
        ]
      },
    ]
  }
  depends_on = [
    kubernetes_manifest.configmap_kubernetes_dashboard_kubernetes_dashboard_settings
  ]
}

resource "kubernetes_manifest" "clusterrole_kubernetes_dashboard" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "k8s-app" = "kubernetes-dashboard"
      }
      "name" = "kubernetes-dashboard"
    }
    "rules" = [
      {
        "apiGroups" = [
          "metrics.k8s.io",
        ]
        "resources" = [
          "pods",
          "nodes",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
    ]
  }
  depends_on = [
    kubernetes_manifest.role_kubernetes_dashboard_kubernetes_dashboard
  ]
}

resource "kubernetes_manifest" "rolebinding_kubernetes_dashboard_kubernetes_dashboard" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "labels" = {
        "k8s-app" = "kubernetes-dashboard"
      }
      "name" = "kubernetes-dashboard"
      "namespace" = "kubernetes-dashboard"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "Role"
      "name" = "kubernetes-dashboard"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "kubernetes-dashboard"
        "namespace" = "kubernetes-dashboard"
      },
    ]
  }
  depends_on = [
    kubernetes_manifest.clusterrole_kubernetes_dashboard
  ]
}

resource "kubernetes_manifest" "clusterrolebinding_kubernetes_dashboard" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "kubernetes-dashboard"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "kubernetes-dashboard"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "kubernetes-dashboard"
        "namespace" = "kubernetes-dashboard"
      },
    ]
  }
  depends_on = [
    kubernetes_manifest.rolebinding_kubernetes_dashboard_kubernetes_dashboard
  ]
}

resource "kubernetes_manifest" "deployment_kubernetes_dashboard_kubernetes_dashboard" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "k8s-app" = "kubernetes-dashboard"
      }
      "name" = "kubernetes-dashboard"
      "namespace" = "kubernetes-dashboard"
    }
    "spec" = {
      "replicas" = 1
      "revisionHistoryLimit" = 10
      "selector" = {
        "matchLabels" = {
          "k8s-app" = "kubernetes-dashboard"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "k8s-app" = "kubernetes-dashboard"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--auto-generate-certificates",
                "--namespace=kubernetes-dashboard",
              ]
              "image" = "kubernetesui/dashboard:${var.dashboard-version}"
              "imagePullPolicy" = "Always"
              "livenessProbe" = {
                "httpGet" = {
                  "path" = "/"
                  "port" = 8443
                  "scheme" = "HTTPS"
                }
                "initialDelaySeconds" = 30
                "timeoutSeconds" = 30
              }
              "name" = "kubernetes-dashboard"
              "ports" = [
                {
                  "containerPort" = 8443
                  "protocol" = "TCP"
                },
              ]
              "securityContext" = {
                "allowPrivilegeEscalation" = false
                "readOnlyRootFilesystem" = true
                "runAsGroup" = 2001
                "runAsUser" = 1001
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/certs"
                  "name" = "kubernetes-dashboard-certs"
                },
                {
                  "mountPath" = "/tmp"
                  "name" = "tmp-volume"
                },
              ]
            },
          ]
          "nodeSelector" = {
            "kubernetes.io/os" = "linux"
          }
          "securityContext" = {
            "seccompProfile" = {
              "type" = "RuntimeDefault"
            }
          }
          "serviceAccountName" = "kubernetes-dashboard"
          "tolerations" = [
            {
              "effect" = "NoSchedule"
              "key" = "node-role.kubernetes.io/master"
            },
          ]
          "volumes" = [
            {
              "name" = "kubernetes-dashboard-certs"
              "secret" = {
                "secretName" = "kubernetes-dashboard-certs"
              }
            },
            {
              "emptyDir" = {}
              "name" = "tmp-volume"
            },
          ]
        }
      }
    }
  }
  depends_on = [
    kubernetes_manifest.clusterrolebinding_kubernetes_dashboard
  ]
}

resource "kubernetes_manifest" "service_kubernetes_dashboard_dashboard_metrics_scraper" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "k8s-app" = "dashboard-metrics-scraper"
      }
      "name" = "dashboard-metrics-scraper"
      "namespace" = "kubernetes-dashboard"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 8000
          "targetPort" = 8000
        },
      ]
      "selector" = {
        "k8s-app" = "dashboard-metrics-scraper"
      }
    }
  }
  depends_on = [
    kubernetes_manifest.deployment_kubernetes_dashboard_kubernetes_dashboard
  ]
}

resource "kubernetes_manifest" "deployment_kubernetes_dashboard_dashboard_metrics_scraper" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "k8s-app" = "dashboard-metrics-scraper"
      }
      "name" = "dashboard-metrics-scraper"
      "namespace" = "kubernetes-dashboard"
    }
    "spec" = {
      "replicas" = 1
      "revisionHistoryLimit" = 10
      "selector" = {
        "matchLabels" = {
          "k8s-app" = "dashboard-metrics-scraper"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "k8s-app" = "dashboard-metrics-scraper"
          }
        }
        "spec" = {
          "containers" = [
            {
              "image" = "kubernetesui/metrics-scraper:${var.dms-version}"
              "livenessProbe" = {
                "httpGet" = {
                  "path" = "/"
                  "port" = 8000
                  "scheme" = "HTTP"
                }
                "initialDelaySeconds" = 30
                "timeoutSeconds" = 30
              }
              "name" = "dashboard-metrics-scraper"
              "ports" = [
                {
                  "containerPort" = 8000
                  "protocol" = "TCP"
                },
              ]
              "securityContext" = {
                "allowPrivilegeEscalation" = false
                "readOnlyRootFilesystem" = true
                "runAsGroup" = 2001
                "runAsUser" = 1001
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/tmp"
                  "name" = "tmp-volume"
                },
              ]
            },
          ]
          "nodeSelector" = {
            "kubernetes.io/os" = "linux"
          }
          "securityContext" = {
            "seccompProfile" = {
              "type" = "RuntimeDefault"
            }
          }
          "serviceAccountName" = "kubernetes-dashboard"
          "tolerations" = [
            {
              "effect" = "NoSchedule"
              "key" = "node-role.kubernetes.io/master"
            },
          ]
          "volumes" = [
            {
              "emptyDir" = {}
              "name" = "tmp-volume"
            },
          ]
        }
      }
    }
  }
  depends_on = [
    kubernetes_manifest.service_kubernetes_dashboard_dashboard_metrics_scraper
  ]
}