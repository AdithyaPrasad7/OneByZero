resource "kubernetes_config_map" "datadog_installinfo" {
  metadata {
    name      = "datadog-installinfo"
    namespace = "default"
  }

  data = {
    install_info = "---\ninstall_method:\n  tool: kubernetes sample manifests\n  tool_version: kubernetes sample manifests\n  installer_version: kubernetes sample manifests\n"
  }
}