output "app_url" {
  value       = "http://${aws_instance.app.public_ip}:8000"
  description = "Your FastAPI app URL"
}

output "docs_url" {
  value       = "http://${aws_instance.app.public_ip}:8000/docs"
  description = "FastAPI auto-generated docs"
}

