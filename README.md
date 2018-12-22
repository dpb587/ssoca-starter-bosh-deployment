# ssoca-starter-bosh-deployment

A BOSH deployment to get started using [ssoca](https://github.com/dpb587/ssoca) for OpenVPN servers or SSH bastion hosts. Consider the [caveats](#caveats) before using these configurations in production.


## Basic Usage

The [`deployment.yml`](deployment.yml) will get you started with a basic ssoca server. It is simply the ssoca server itself and does not yet know how to authenticate users or provide access to any services. Subsequent sections provide additional, default ways of customizing these behaviors.

**Variables**

 * **`ssoca_env_name`** - a slug-like alias which will be recommended to users when configuring this environment locally
 * **`ssoca_env_title`** - a human-friendly name which briefly describes this environment to users
 * **`ssoca_public_hostname`** - the domain or IP address where this server should be accessed
 * **`ssoca_public_ip`** - the public IP which should be assigned as a VIP network to the VM

**Example**

    bosh deploy deployment.yml \
      --var ssoca_env_name=acme-prod-gcp \
      --var ssoca_env_title="ACME Production Primary Environment (Google Cloud)" \
      --var ssoca_public_hostname=jump.prod1-gcp.acme-internal.com \
      --var ssoca_public_ip=203.0.113.87


## Customized Banner

To add a custom banner which is shown to users when connecting to ssoca, use [`with-env-banner.yml`](with-env-banner.yml) ([learn more](https://dpb587.github.io/ssoca/service/env/#options)).

**Variables**

 * **`ssoca_env_banner`** - a brief, custom banner message

**Example**

    bosh deploy deployment.yml \
      --ops-file with-env-banner.yml \
      --var ssoca_env_banner='Unauthorized use is strictly prohibited.'


## Customized Metadata

To add arbitrary, custom metadata about the environment, use [`with-env-metadata.yml`](with-env-metadata.yml). This can be used to customize the default ssoca frontend ([learn more](https://dpb587.github.io/ssoca/server/ui)).

**Variables**

 * **`ssoca_env_metadata`** - a hash of metadata

**Example**

    bosh deploy deployment.yml \
      --ops-file with-env-metadata.yml \
      --var ssoca_env_metadata={ui.usage:"ssoca -e acme-prod-gcp openvpn exec --sudo"}


## Let's Encrypt SSL

To automatically provision an SSL certificate from Let's Encrypt and have ssoca run on standard HTTP/HTTPS ports, use [`with-letsencrypt-ssl.yml`](with-letsencrypt-ssl.yml) ([learn more](https://github.com/dpb587/caddy-bosh-release/blob/master/README.md)).

**Variables**

 * **`admin_email`** - an email which will be used to register for certificates

**Example**

    bosh deploy deployment.yml ... \
      --ops-file with-letsencrypt-ssl.yml \
      --var admin_email=john.doe@example.com


## Forwarding Logs to Papertrail

To forward logs to [Papertrail](https://papertrailapp.com/), use [`with-logging/to-papertrail.yml`](with-logging/to-papertrail.yml).

**Variables**

 * **`logging_papertrail_address`** - the Papertrail-provided hostname for your system
 * **`logging_papertrail_port`** - the Papertrail-provided port for your system

**Example**

    bosh deploy deployment.yml ... \
      --ops-file with-logging/to-papertrail.yml \
      --var logging_papertrail_address=logs0.papertrailapp.com \
      --var logging_papertrail_port=65536 \


## Authentication

The ssoca server must be configured with an authentication provider.


### Google

The [`with-google-authn`](with-google-authn) directory provides options around authenticating users via Google accounts ([learn more](https://dpb587.github.io/ssoca/auth/authn/google/)). To enable this authentication, use [`enabled.yml`](with-google-authn/enabled.yml).

**Variables**

 * **`ssoca_authn_google_client_id`** - the client ID of a [registered application](https://dpb587.github.io/ssoca/auth/authn/google/#google-application)
 * **`ssoca_authn_google_client_secret`** - the client secret of a [registered application](https://dpb587.github.io/ssoca/auth/authn/google/#google-application)

**Example**

    bosh deploy deployment.yml ... \
      --ops-file with-google-authn/enabled.yml \
      --var ssoca_authn_google_client_id=1234567890-a1b2c3....apps.googleusercontent.com \
      --var ssoca_authn_google_client_secret=a1b2c3d4...


#### Cloud Project Scopes

If you wish to restrict access based on users having access to specific Cloud projects or roles in those projects, use [`cloud-project-scopes.yml`](with-google-authn/cloud-project-scopes.yml).

**Variables**

 * **`ssoca_authn_google_cloud_project`** - the [configuration](https://dpb587.github.io/ssoca/auth/authn/google/#options) to load project and role information

**Example**

    bosh deploy deployment.yml ... --ops-file with-google-authn/enabled.yml \
      --ops-file with-google-authn/cloud-project-scopes.yml \
      --var ssoca_authn_google_cloud_project={projects:[prod1],roles:[role/editor]}


### UAA

The [`with-uaa-authn`](with-uaa-authn) directory provides options around authenticating users via [Cloud Foundry UAA](https://github.com/cloudfoundry/uaa) ([learn more](https://dpb587.github.io/ssoca/auth/authn/uaa/)). To enable this authentication, use [`enabled.yml`](with-uaa-authn/enabled.yml).

**Variables**

 * **`ssoca_authn_uaa_url`** - the URL where clients will communicate with the UAA server
 * **`ssoca_authn_uaa_client_id`** - the client ID which will be used while authenticating users
 * **`ssoca_authn_uaa_public_key`** - the public key used to verify a user's JWT as trusted

**Example**

    bosh deploy deployment.yml ... \
      --ops-file with-uaa-authn/enabled.yml \
      --var ssoca_authn_uaa_url=https://uaa.prod1-gcp.acme-internal.com \
      --var ssoca_authn_uaa_client_id=ssoca \
      --var-file ssoca_authn_uaa_public_key=uaa-rsa.pub


#### Customizing Prompts

If UAA supports both password-based and single sign on, users will additionally be prompted for a one-time while logging in. If your users are one or the other, you may explicitly configure which prompts are required to improve UX by using [`custom-prompts.yml`](with-uaa-authn/custom-prompts.yml).

**Variables**

 * **`ssoca_authn_uaa_prompts`** - a list of prompts to limit what users enter during authentication

**Example**

    bosh deploy deployment.yml ... --ops-file with-uaa-authn/enabled.yml ... \
      --ops-file with-uaa-authn/custom-prompts.yml \
      --var ssoca_authn_uaa_prompts=[username,password]


## Services

The ssoca server must be configured with services that it will be signing certificates for.


### OpenVPN

The [`with-openvpn`](with-openvpn) directory provides options for using ssoca to authenticate to OpenVPN servers which use certificate-based authentication ([learn more](https://dpb587.github.io/ssoca/service/openvpn/)). To get started by running a VPN server alongside ssoca, use [`colocated.yml`](with-openvpn/colocated.yml).

**Variables**

 * **`ssoca_openvpn_authz`** - the [authorization rules](https://dpb587.github.io/ssoca/auth/authz/) required for users accessing OpenVPN
 * **`openvpn_vpn_network`** - the base address for the network managed by the VPN server
 * **`openvpn_vpn_network_mask`** - the IP mask for the network managed by the VPN server

**Example**

    bosh deploy deployment.yml ... \
      --ops-file with-openvpn/colocated.yml \
      --var ssoca_openvpn_authz=[{authenticated:~}] \
      --var openvpn_vpn_network=172.123.45.0 \
      --var openvpn_vpn_network_mask=255.255.255.0 \
      --var openvpn_vpn_network_mask_bits=24


#### Custom Diffie-Hellman Key

This deployment includes a default Diffie-Hellman key for the OpenVPN server, but use [`custom-dh-pem.yml`](with-openvpn/custom-dh-pem.yml) for a local key.

**Variables**

 * **`openvpn_dh_pem`** - pre-generated, PEM-formatted Diffie-Hellman key (e.g. `openssl dhparam -out dhparams.pem 2048`)

**Example**

    bosh deploy deployment.yml ... --os-file with-openvpn/colocated.yml \
      --ops-file with-openvpn/custom-dh-pem.yml \
      --var-file openvpn_dh_pem=dhparams.pem


#### Enabling LAN Access (Masquerade)

Typically a purpose of the VPN server is to allow clients to connect to resources on the private network. To allow the VPN server to masquerade traffic on behalf of clients, configure and use [`private-network-masquerade.yml`](with-openpn/private-network-masquerade.yml).

**Variables**

 * **`openvpn_private_network`** - the base address for the private network to expose to clients
 * **`openvpn_private_network_mask`** - the IP mask for the private network to expose to clients
 * **`openvpn_private_network_mask_bits`** - the IP mask bits for the private network to expose to clients

**Example**

    bosh deploy deployment.yml ... --ops-file with-openvpn/colocated.yml \
      --ops-file with-openvpn/private-network-masquerade.yml \
      --var openvpn_private_network=10.123.0.0 \
      --var openvpn_private_network_mask=255.255.0.0 \
      --var openvpn_private_network_mask_bits=16


### SSH

The [`with-ssh`](with-ssh) directory provides options for using ssoca to authenticate to SSH servers which use certificate-based authentication ([learn more](https://dpb587.github.io/ssoca/service/ssh/)). To get started by allowing SSH login alongside ssoca, use [`colocated.yml`](with-ssh/colocated.yml).

**Variables**

 * **`ssoca_ssh_authz`** - the [authorization rules](https://dpb587.github.io/ssoca/auth/authz/) required for users accessing SSH
 * **`ssh_username`** - the account name to provision for SSH logins

**Example**

    bosh deploy deployment.yml ... \
      --ops-file with-ssh/colocated.yml \
      --var ssoca_ssh_authz=[{authenticated:~}] \
      --var ssh_username=ssh


#### Provisioning an Additional User

If you would like to provision an additional user for SSH login, use [`additional-user.yml`](with-ssh/additional-user.yml).

**Variables**

 * **`ssh_additional_username`** - the additional account name to provision for SSH logins

**Example**

    bosh deploy deployment.yml ... --ops-file with-ssh/colocated.yml \
      --ops-file with-ssh/additional-user.yml \
      --var ssh_additional_username=dberger

    bosh deploy deployment.yml ... --ops-file with-ssh/colocated.yml \
      --ops-file <( bosh int with-ssh/additional-user.yml --var ssh_additional_username=john ) \
      --ops-file <( bosh int with-ssh/additional-user.yml --var ssh_additional_username=jane ) \


## Caveats

Some caveats about this deployment that you should be aware of.

 * This deployment currently colocates all services on a single VM. This makes it easy to get started, but is not recommended for production security.
 * This repository is not versioned and tagged. If you are relying on this, you should track commits and changes on your own.
 * This is a first iteration of a shared deployment for this and the interfaces may change. Consider it alpha quality.
 * This assumes the default `cloud-config` naming conventions which are used by [`bosh-deployment`](https://github.com/cloudfoundry/bosh-deployment).


## License

[MIT License](LICENSE)
