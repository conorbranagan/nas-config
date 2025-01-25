# My NAS Config

This is my basic NAS config using docker-compose. This is used on a TrueNas server via Dockge with each of the docker-compose files in `stacks` being deployed within there.

- Deploys the following apps:
    1. Sonarr
    2. Radarr
    3. QBittorrent
    4. Plex
- All apps are exposed via [TailScale](https://tailscale.com/) rather than the public internet.
- Traffic is routed through [Traefik](https://traefik.io)
- Monitoring is (optionally) provided using [Datadog](https://datadoghq.com)


# Setup

1. Set up your environment.

    ```
    cp .env-example .env
    ```

    Edit the `.env` file following the guides in 

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

# Notes

## Networking

All containers are sharing the network namespace with tailscale via the `network_mode: container:tailscale-traefik` setting.

Note that the tailscale container itself is exposed to the `host` network. This is primarily so that it is accessible _locally_ so that things like Plex can directly access files and stream at the highest quality.