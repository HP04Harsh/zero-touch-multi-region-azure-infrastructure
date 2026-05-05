output "india_website_url" {
  value = "http://${module.vm_india.public_ip}"
}

output "us_website_url" {
  value = "http://${module.vm_us.public_ip}"
}

output "summary" {
  value = "Infrastructure deployed. Access India at the URL above and US at the URL above."
}