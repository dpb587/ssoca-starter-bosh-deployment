#!/bin/bash

set -e

bosh interpolate deployment.yml \
  --ops-file with-google-authn/enabled.yml \
  --ops-file with-google-authn/cloud-project-scopes.yml \
  --ops-file with-logging/to-papertrail.yml \
  --ops-file with-openvpn/colocated.yml \
  --ops-file with-openvpn/custom-dh-pem.yml \
  --ops-file with-openvpn/private-network-masquerade.yml \
  --ops-file with-openvpn/client-to-client-support.yml \
  --ops-file with-openvpn/duplicate-cn-support.yml \
  --ops-file with-ssh/colocated.yml \
  --ops-file with-ssh/additional-user.yml \
  --ops-file with-uaa-authn/enabled.yml \
  --ops-file with-uaa-authn/custom-prompts.yml \
  --ops-file with-env-banner.yml \
  --ops-file with-env-metadata.yml \
  --ops-file with-letsencrypt-ssl.yml
