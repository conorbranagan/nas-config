# My NAS Config

This is my basic NAS config using docker-compose. This is used on a TrueNas server via Dockge with each of the docker-compose files in `stacks` being deployed within there.

- Deploy a network stack with [Traefik](https://traefik.io) for routing and [TailScale](https://tailscale.com/) for exposure.
- Deploys the following apps:
    1. Sonarr
    1. Radarr
    1. Prowlarr
    1. QBittorrent
    1. Plex
    1. Homepage
    1. Unifi-Controller
- Monitoring using [Datadog](https://datadoghq.com)

_Note that Homepage has configuration to point to a Home Assistant instance. In my setup this is managed using a VM [following this guide](https://gist.github.com/coltenkrauter/aee059954b11bf4f6461309af521a277)._

# Setup

1. Set up your environment.

    ```
    cp .env-example .env
    ```

    Edit the `.env` file to set up initial keys. As noted in the example file, the keys for the apps (e.g. api key for Sonarr) will be unavailable until you start these up the first time.

2. Run the compose stacks. Assuming you're using TrueNas Scale 24.10 (Electric Eel) or later, you can:

    - Install the Dockge app via the TrueNas apps catalog
    - Navigate to Dockge (usually `http://<local-ip>:31014`).
    - Add a `Compose` for each of the files within Stacks. Make sure you copy _both_ the contents of the yaml file and the `.env` file appropriately. You should deploy them in the order they are listed to ensure the right dependencies are available.

3. Claim the Plex Server. To ensure you have access to the Media Server in Plex, you will need to first access it via your local IP:

    - Go to `<local-ip>:32400` (e.g. 192.168.1.238:32400)
    - Login w/ Plex account, claim server.
    - Go to Settings -> [Server] -> Network
        - In **Custom server access URLs** add your public domain
    - Now you should be able to access at `plex.$PUBLIC_HOSTNAME`.

4. Get [Homepage](https://gethomepage.dev/) running

    - Update `.env` with the app keys. Go through each app and generate the required keys and put them in the `.env` file.
    - Re-deploy with the new `.env` file via Dockge.
    - Deploy configuration: `./deploy-config -a <ip|hostname> -r <path/to/config>` (e.g. `./deploy-config -a 192.168.1.238 -r /mnt/flash/apps`)
    - Validate at `https://homepage.<PUBLIC_HOSTNAME>`.

# Notes

## Networking

All containers are sharing the network namespace with tailscale via the `network_mode: container:tailscale-traefik` setting.

Note that the tailscale container itself is exposed to the `host` network. This is primarily so that it is accessible _locally_ so that things like Plex can directly access files and stream at the highest quality.

This does mean you have to be careful about port conflicts across containers. There is likely a better approach here, so improvements may come in the future.