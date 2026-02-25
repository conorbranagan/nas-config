# Docker-Compose NAS Config

This repo includes docker-compose files and configuration to setup some apps on a NAS.

In my setup I run a [TrueNAS](https://www.truenas.com/) server with the [Dockge](https://github.com/louislam/dockge). Each of the docker-compose files in `stacks` is deployed in Dockge.

The setup is as follows:

1. **Network stack**
    - [Traefik](https://traefik.io) as a reverse proxy for routing
    - [TailScale](https://tailscale.com/) for exposing Traefik (rather than exposing public)

2. **Monitoring stack**
    -  [Datadog](https://datadoghq.com) for monitorg running processes, containers and host-level stats.

3. **Apps stack** - all routed to through Traefik (e.g. `plex.{PUBLIC_HOSTNAME}.com`)
    - [Plex](https://www.plex.tv/)
    - [Sonarr](https://sonarr.tv/)
    - [Radarr](https://radarr.video/)
    - [Prowlarr](https://prowlarr.com/)
    - [QBittorrent](https://www.qbittorrent.org/)
    - [Homepage](https://gethomepage.dev/)
    - [Unifi-Controller](https://www.ui.com/)

4. **Backups**
    -  2 instances of [iCloud Photo Downloader](https://github.com/boredazfcuk/docker-icloudpd) for photo backup (we sync these to Backblaze B2 elsewhere)

5. **Claude Code** - a containerized [Claude Code](https://docs.anthropic.com/en/docs/claude-code) instance with Docker socket access and host filesystem mounted. Includes a `Dockerfile` for the build.

6. **NanoClaw** - a [NanoClaw](https://github.com/qwibitai/nanoclaw) multi-agent orchestrator. Auto-clones on first run via an entrypoint script. Includes a `Dockerfile` and `entrypoint.sh`.

7. **Utils** - a lightweight Ubuntu 24.04 utility container with common tools (git, jq, curl, docker CLI, etc.) for ad-hoc tasks and debugging.


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

    - Go to `<local-ip>:32400` (e.g. 192.168.1.123:32400)
    - Login w/ Plex account, claim server.
    - Go to Settings -> [Server] -> Network
        - In **Custom server access URLs** add your public domain
    - Now you should be able to access at `plex.$PUBLIC_HOSTNAME`.

4. Get [Homepage](https://gethomepage.dev/) running

    - Update `.env` with the app keys. Go through each app and generate the required keys and put them in the `.env` file.
    - Re-deploy with the new `.env` file via Dockge.
    - Deploy configuration: `./deploy-config -a <ip|hostname> -r <path/to/config>` (e.g. `./deploy-config -a 192.168.1.123 -r /mnt/flash/apps`)
    - Validate at `https://homepage.<PUBLIC_HOSTNAME>`.
