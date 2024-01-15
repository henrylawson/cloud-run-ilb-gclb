resource "google_compute_region_network_endpoint_group" "syd" {
  project               = var.project
  name                  = "hello-au-syd"
  network_endpoint_type = "SERVERLESS"
  region                = "australia-southeast1"

  cloud_run {
    service = google_cloud_run_v2_service.au_syd.name
  }
}

resource "google_compute_region_network_endpoint_group" "mel" {
  project               = var.project
  name                  = "hello-au-mel"
  network_endpoint_type = "SERVERLESS"
  region                = "australia-southeast2"

  cloud_run {
    service = google_cloud_run_v2_service.au_mel.name
  }
}


