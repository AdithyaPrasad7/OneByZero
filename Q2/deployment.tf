resource "kubernetes_deployment" "datadog_agent" {
  metadata {
    name      = "datadog-cluster-agent"
    namespace = "default"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "datadog-cluster-agent"
      }
    }

    template {
      metadata {
        name = "datadog-cluster-agent"
        labels = {
          app                            = "datadog-cluster-agent"
          "app.kubernetes.io/component"  = "cluster-agent"
          "app.kubernetes.io/instance"   = "datadog"
          "app.kubernetes.io/managed-by" = "Helm"
          "app.kubernetes.io/name"       = "datadog"
        }
      }

      spec {
        init_container {
          name    = "init-volume"
          image   = "gcr.io/datadoghq/cluster-agent:7.46.0"
          command = ["bash", "-c"]
          args    = ["chmod -R 744 /etc/datadog-agent;\ncp -r /etc/datadog-agent /opt\n"]
          volume_mount {
            name       = "config"
            mount_path = "/opt/datadog-agent"
          }
          image_pull_policy = "IfNotPresent"
        }
        container {
          name  = "cluster-agent"
          image = "gcr.io/datadoghq/cluster-agent:7.46.0"

          port {
            name           = "agentport"
            container_port = 5005
            protocol       = "TCP"
          }

          port {
            name           = "agentmetrics"
            container_port = 5000
            protocol       = "TCP"
          }

          port {
            name           = "metricsapi"
            container_port = 8443
            protocol       = "TCP"
          }
          port {
            name           = "traceporthttp"
            host_port      = 4318
            container_port = 4318
            protocol       = "TCP"
          }
          env {
            name = "DD_POD_NAME"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name  = "DD_HEALTH_PORT"
            value = "5556"
          }

          env {
            name = "DD_API_KEY"
            value_from {
              secret_key_ref {
                name     = "datadog"
                key      = "api-key"
                optional = true
              }
            }
          }
          env {
            name  = "KUBERNETES"
            value = "yes"
          }
          env {
            name = "DD_APP_KEY"
            value_from {
              secret_key_ref {
                name = "datadog-appkey"
                key  = "app-key"
              }
            }
          }

          env {
            name  = "DD_EXTERNAL_METRICS_PROVIDER_ENABLED"
            value = "true"
          }
          env {
            name  = "DD_EXTERNAL_METRICS_PROVIDER_PORT"
            value = "8443"
          }
          env {
            name  = "DD_EXTERNAL_METRICS_PROVIDER_WPA_CONTROLLER"
            value = "false"
          }
          env {
            name  = "DD_EXTERNAL_METRICS_PROVIDER_USE_DATADOGMETRIC_CRD"
            value = "false"
          }
          env {
            name  = "DD_EXTERNAL_METRICS_AGGREGATOR"
            value = "avg"
          }
          env {
            name  = "DD_ADMISSION_CONTROLLER_ENABLED"
            value = "true"
          }
          env {
            name  = "DD_ADMISSION_CONTROLLER_MUTATE_UNLABELLED"
            value = "false"
          }
          env {
            name  = "DD_ADMISSION_CONTROLLER_SERVICE_NAME"
            value = "datadog-cluster-agent-admission-controller"
          }
          env {
            name  = "DD_ADMISSION_CONTROLLER_INJECT_CONFIG_MODE"
            value = "socket"
          }
          env {
            name  = "DD_ADMISSION_CONTROLLER_INJECT_CONFIG_LOCAL_SERVICE_NAME"
            value = "datadog"
          }
          env {
            name  = "DD_ADMISSION_CONTROLLER_FAILURE_POLICY"
            value = "Ignore"
          }
          env {
            name  = "DD_REMOTE_CONFIGURATION_ENABLED"
            value = "false"
          }
          env {
            name  = "DD_CLUSTER_CHECKS_ENABLED"
            value = "true"
          }
          env {
            name  = "DD_EXTRA_CONFIG_PROVIDERS"
            value = "kube_endpoints kube_services"
          }
          env {
            name  = "DD_EXTRA_LISTENERS"
            value = "kube_endpoints kube_services"
          }
          env {
            name  = "DD_LOG_LEVEL"
            value = "INFO"
          }
          env {
            name  = "DD_LEADER_ELECTION"
            value = "true"
          }
          env {
            name  = "DD_LEADER_LEASE_NAME"
            value = "datadog-leader-election"
          }
          env {
            name  = "DD_CLUSTER_AGENT_TOKEN_NAME"
            value = "datadogtoken"
          }
          env {
            name  = "DD_COLLECT_KUBERNETES_EVENTS"
            value = "true"
          }
          env {
            name  = "DD_CLUSTER_AGENT_KUBERNETES_SERVICE_NAME"
            value = "datadog-cluster-agent"
          }
          env {
            name = "DD_CLUSTER_AGENT_AUTH_TOKEN"
            value_from {
              secret_key_ref {
                name = "datadog-cluster-agent"
                key  = "token"
              }
            }
          }
          env {
            name  = "DD_CLUSTER_AGENT_COLLECT_KUBERNETES_TAGS"
            value = "false"
          }
          env {
            name  = "DD_KUBE_RESOURCES_NAMESPACE"
            value = "default"
          }
          env {
            name  = "CHART_RELEASE_NAME"
            value = "datadog"
          }
          env {
            name  = "AGENT_DAEMONSET"
            value = "datadog"
          }
          env {
            name  = "CLUSTER_AGENT_DEPLOYMENT"
            value = "datadog-cluster-agent"
          }
          env {
            name  = "DD_ORCHESTRATOR_EXPLORER_ENABLED"
            value = "true"
          }
          env {
            name  = "DD_OTLP_CONFIG_RECEIVER_PROTOCOLS_HTTP_ENDPOINT"
            value = "0.0.0.0:4318"
          }
          env {
            name  = "DD_ORCHESTRATOR_EXPLORER_CONTAINER_SCRUBBING_ENABLED"
            value = "true"
          }
          env {
            name = "HOST_IP"
            value_from {
              field_ref {
                field_path = "status.hostIP"
              }
            }
          }
          env {
            name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
            value = "http://$(HOST_IP):4318"
          }


          volume_mount {
            name       = "datadogrun"
            mount_path = "/opt/datadog-agent/run"
          }

          volume_mount {
            name       = "varlog"
            mount_path = "/var/log/datadog"
          }

          volume_mount {
            name       = "tmpdir"
            mount_path = "/tmp"
          }

          volume_mount {
            name       = "installinfo"
            read_only  = true
            mount_path = "/etc/datadog-agent/install_info"
            sub_path   = "install_info"
          }

          volume_mount {
            name       = "confd"
            read_only  = true
            mount_path = "/conf.d"
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/datadog-agent"
          }

          liveness_probe {
            http_get {
              path   = "/live"
              port   = "5556"
              scheme = "HTTP"
            }
            initial_delay_seconds = 15
            timeout_seconds       = 5
            period_seconds        = 15
            success_threshold     = 1
            failure_threshold     = 6
          }

          readiness_probe {
            http_get {
              path   = "/ready"
              port   = "5556"
              scheme = "HTTP"
            }
            initial_delay_seconds = 15
            timeout_seconds       = 5
            period_seconds        = 15
            success_threshold     = 1
            failure_threshold     = 6
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            read_only_root_filesystem = true
          }
        }
        volume {
          name      = "datadogrun"
          empty_dir = {}
        }
        volume {
          name      = "varlog"
          empty_dir = {}
        }
        volume {
          name      = "tmpdir"
          empty_dir = {}
        }
        volume {
          name = "installinfo"
          config_map {
            name = "datadog-installinfo"
          }
        }
        volume {
          name = "confd"
          config_map {
            name = "datadog-cluster-agent-confd"
            items {
              key  = "kubernetes_state_core.yaml.default"
              path = "kubernetes_state_core.yaml.default"
            }
          }
        }
        volume {
          name      = "config"
          empty_dir = {}
        }

        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 50

              pod_affinity_term {
                label_selector {
                  match_labels = {
                    app = "datadog-cluster-agent"
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge = "1"
      }
    }

    revision_history_limit = 10
  }
}
