resource "google_compute_subnetwork" "ilb_proxy_subnet_syd" {
  provider      = google-beta
  project       = var.project
  name          = "ilb-proxy-subnet-syd"
  ip_cidr_range = "10.0.0.0/24"
  region        = "australia-southeast1"
  purpose       = "GLOBAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = "default"
}

resource "google_compute_address" "ilb_syd" {
  project      = var.project
  name         = "ilb-address-syd"
  subnetwork   = "https://www.googleapis.com/compute/v1/projects/hgl-env-cloud-run-ilb-gclb/regions/australia-southeast1/subnetworks/default"
  address_type = "INTERNAL"
  address      = "10.152.0.40"
  region       = google_compute_subnetwork.ilb_proxy_subnet_syd.region
}

resource "google_compute_global_forwarding_rule" "ilb_syd" {
  provider              = google-beta
  project               = var.project
  name                  = "hello-service-internal-syd"
  target                = google_compute_target_http_proxy.ilb.id
  port_range            = "80"
  load_balancing_scheme = "INTERNAL_MANAGED"
  depends_on            = [google_compute_subnetwork.ilb_proxy_subnet_syd]
  ip_address            = google_compute_address.ilb_syd.address
  network               = "default"
  subnetwork            = "https://www.googleapis.com/compute/v1/projects/hgl-env-cloud-run-ilb-gclb/regions/australia-southeast1/subnetworks/default"
}

resource "google_compute_subnetwork" "ilb_proxy_subnet_mel" {
  provider      = google-beta
  project       = var.project
  name          = "ilb-proxy-subnet-mel"
  ip_cidr_range = "10.1.0.0/24"
  region        = "australia-southeast2"
  purpose       = "GLOBAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = "default"
}

resource "google_compute_address" "ilb_mel" {
  project      = var.project
  name         = "ilb-address-mel"
  subnetwork   = "https://www.googleapis.com/compute/v1/projects/hgl-env-cloud-run-ilb-gclb/regions/australia-southeast2/subnetworks/default"
  address_type = "INTERNAL"
  address      = "10.192.0.40"
  region       = google_compute_subnetwork.ilb_proxy_subnet_mel.region
}

resource "google_compute_global_forwarding_rule" "ilb_mel" {
  provider              = google-beta
  project               = var.project
  name                  = "hello-service-internal-mel"
  target                = google_compute_target_http_proxy.ilb.id
  port_range            = "80"
  load_balancing_scheme = "INTERNAL_MANAGED"
  depends_on            = [google_compute_subnetwork.ilb_proxy_subnet_mel]
  ip_address            = google_compute_address.ilb_mel.address
  network               = "default"
  subnetwork            = "https://www.googleapis.com/compute/v1/projects/hgl-env-cloud-run-ilb-gclb/regions/australia-southeast2/subnetworks/default"
}

resource "google_compute_target_http_proxy" "ilb" {
  provider = google-beta
  project  = var.project
  name     = "hello-service-internal"
  url_map  = google_compute_url_map.ilb.id
}

resource "google_compute_url_map" "ilb" {
  provider        = google-beta
  project         = var.project
  name            = "hello-service-internal"
  description     = "a description"
  default_service = google_compute_backend_service.ilb.id
}

resource "google_compute_backend_service" "ilb" {
  provider = google-beta
  project  = var.project
  name     = "hello-service-internal"

  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30

  load_balancing_scheme = "INTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.syd.id
  }

  backend {
    group = google_compute_region_network_endpoint_group.mel.id
  }
}