# Bootstrap

## Environment

- TODO: Set up environment

## Plex-Specific

- Had to "claim" the server first before accessing on tailscale.
    - Go to `<localip>:32400` (e.g. 192.168.1.238:32400)
    - Login w/ Plex account, claim server.
    - Go to Settings -> [Server] -> Network
        - In **Custom server access URLs** add your public domain
- Now you should be able to access at `plex.$PUBLIC_HOSTNAME`.

# Notes

## Networking

All containers are sharing the network namespace with tailscale via the `network_mode: container:tailscale-traefik` setting.

Note that the tailscale container itself is exposed to the `host` network. This is primarily so that it is accessible _locally_ so that things like Plex can directly access files and stream at the highest quality.