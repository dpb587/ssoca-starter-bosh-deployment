#!/bin/bash

set -e

bosh interpolate deployment.yml \
  --var ssoca_env_name=acme-prod-gcp \
  --var ssoca_env_title="ACME Production Primary Environment (Google Cloud)" \
  --var ssoca_public_hostname=jump.prod1-gcp.acme-internal.com \
  --var ssoca_public_ip=203.0.113.87 \
  \
  --ops-file with-letsencrypt-ssl.yml \
  --var admin_email=john.doe@example.com \
  \
  --ops-file with-google-authn/enabled.yml \
  --var ssoca_authn_google_client_id=1234567890-a1b2c3.apps.googleusercontent.com \
  --var ssoca_authn_google_client_secret=a1b2c3d4 \
  \
  --ops-file with-logging/to-papertrail.yml \
  --var logging_papertrail_address=logs0.papertrailapp.com \
  --var logging_papertrail_port=65536 \
  \
  --ops-file with-openvpn/colocated.yml \
  --var ssoca_openvpn_authz=[{authenticated:~}] \
  --var openvpn_vpn_network=172.123.45.0 \
  --var openvpn_vpn_network_mask=255.255.255.0 \
  --var openvpn_vpn_network_mask_bits=24 \
  \
  --ops-file with-env-banner.yml \
  --var ssoca_env_banner='Unauthorized use is strictly prohibited.'
