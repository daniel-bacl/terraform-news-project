output "grafana_api_key" {
  value       = aws_grafana_workspace_api_key.terraform.key
}

output "cloudwatch_datasource_id" {
  value       = grafana_data_source.cloudwatch.id
  description = "Grafana CloudWatch Data Source ID"
}

output "grafana_dashboard_id" {
  value       = grafana_dashboard.overview.id
  description = "Overview Dashboard ID"
}

output "grafana_workspace_endpoint" {
  value = module.grafana.workspace_endpoint
}

output "grafana_workspace_id" {
  value = module.grafana.workspace_id
}