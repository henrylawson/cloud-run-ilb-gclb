resource "google_compute_global_address" "gclb" {
  provider = google-beta
  project  = var.project
  name     = "hello-service-public"
}

resource "google_compute_global_forwarding_rule" "gclb" {
  project               = var.project
  name                  = "hello-service-public"
  provider              = google-beta
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.gclb.id
  ip_address            = google_compute_global_address.gclb.id
}

resource "google_compute_target_http_proxy" "gclb" {
  project  = var.project
  name     = "hello-service-public"
  provider = google-beta
  url_map  = google_compute_url_map.gclb.id
}

resource "google_compute_url_map" "gclb" {
  project         = var.project
  name            = "hello-service-public"
  provider        = google-beta
  default_service = google_compute_backend_service.gclb.id
}

resource "google_compute_backend_service" "gclb" {
  project = var.project
  name    = "hello-service-public"

  load_balancing_scheme = "EXTERNAL_MANAGED"

  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30

  backend {
    group = google_compute_region_network_endpoint_group.syd.id
  }

  backend {
    group = google_compute_region_network_endpoint_group.mel.id
  }
}