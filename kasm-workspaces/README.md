# KASM Workspace Images

Custom KASM workspace images built on top of the [KasmTech workspaces-images](https://github.com/kasmtech/workspaces-images) base images.

## Repository Structure

```
dockerfile-kasm-*          # One Dockerfile per workspace image
src/kasm/
  common/core/install/     # Install scripts shared across all images
    new_startup/           # Startup framework (see below)
    tools/                 # Common tool installers
    chrome/, chromium/     # Browser installers
    gnome_keyring/         # Keyring support
    cleanup/               # Post-build cleanup
  ubuntu/install/          # Ubuntu-specific install scripts
    calibre/               # Calibre e-book manager
    dind_rootless/         # Rootless Docker-in-Docker
    dive/                  # Docker image layer explorer
    sublime_text/          # Sublime Text editor
    vs_code/               # VS Code
  alpine/                  # Alpine-based image scripts
```

## Building Images

Build from the `kasm-workspaces/` directory. All Dockerfiles expect the build context to be that directory.

```bash
docker build -f dockerfile-kasm-<name> \
  -t <image>:<tag> \
  --progress=plain . 2>&1 | tee build-<name>.log
```

The `--progress=plain` flag and log tee are recommended — builds are long and the log is useful for diagnosing failures.

### Build cache

Dockerfiles use BuildKit cache mounts for apt (`/var/cache/apt`, `/var/lib/apt`). Subsequent builds reuse the apt cache and are significantly faster. To force a clean build:

```bash
docker build --no-cache -f dockerfile-kasm-<name> ...
```

## Testing Images

### Inspecting a built image without starting the workspace

Read a file directly from the image:
```bash
docker run --rm --entrypoint cat <image>:<tag> /path/to/file
```

Run an arbitrary command:
```bash
docker run --rm --entrypoint bash <image>:<tag> -c "<command>"
```

Check installed packages:
```bash
docker run --rm --entrypoint bash <image>:<tag> -c "dpkg -l <package>"
```

Check for missing shared library dependencies:
```bash
docker run --rm --entrypoint bash <image>:<tag> -c \
  "ldd /path/to/binary.so | grep 'not found'"
```

### Running a workspace locally

KASM workspaces run a VNC server on port 6901. To test an image locally:

```bash
docker run --rm -it --shm-size=512m -p 6902:6901 -e VNC_PW=password <image>:<tag>
```

Use port 6902 (or any free port) on the host side if 6901 is already in use. Access the workspace at `https://localhost:6902`.

> **Note:** Running a KASM workspace container inside another KASM workspace will not work with standard port mapping — the inner and outer VNC servers conflict on port 6901 and rootless Docker has restricted port binding. Use a KASM host for live testing if possible.

### Pushing to a KASM host for testing

Transfer the image to your KASM host over SSH:

```bash
docker save <image>:<tag> | ssh <user>@<kasm-host> docker load
```

The image is then available for launch through the KASM admin panel. KASM's background pruner may remove images not associated with a registered workspace type — launch a session promptly after loading, or ensure the image is registered first.

## Adding a New Workspace Image

1. Create `dockerfile-kasm-<name>` based on an existing Dockerfile.
2. Create `src/kasm/ubuntu/install/<name>/` with:
   - `install_<name>.sh` — package installation and setup
   - `NNN-<name>.insh` — startup item config (if the app runs at boot)
3. Add the install script to `INST_SCRIPTS` in the Dockerfile.
4. If the app needs a startup entry, call `add_startup_item.sh` in the Dockerfile's `RUN` step.

## Startup Framework (`new_startup`)

Workspace processes are managed by `custom_startup.sh` via a startup item framework. Each process has:

- **`NNN-name.sh`** — symlink to `template.sh`; the number controls start order (000–999)
- **`NNN-name.insh`** — sourced by `template.sh`; defines the process configuration

### `.insh` configuration variables

The definitive list of configuration variables and their descriptions is located in `src/kasm/common/core/install/new_startup/startup.d/template.insh`

| Variable | Default | Description |
|---|---|---|
| `TITLE` | `"Default Title"` | Human-readable process name |
| `START_COMMAND` | `:` (no-op) | Shell command to launch the process (should be non-blocking, e.g. `myapp &`) |
| `PID_SEARCH_STRING` | `""` | String passed to `pgrep -nf` to find the running process PID |
| `KEEPALIVE` | `$_FALSE` | If `$_TRUE`, restart the process automatically if it exits |
| `RESTART_COMMAND` | `${START_COMMAND}` | Command used when restarting (if different from `START_COMMAND`) |
| `MAXIMIZE` | `$_FALSE` | If `$_TRUE`, maximize the window after launch |
| `MAXIMIZE_NAME` | `${TITLE}` | Window title string to match for maximize (uses `wmctrl -F` exact match) |
| `PID` | `0` | Override PID directly; if 0, PID is discovered via `PID_SEARCH_STRING` |

### Overridable hook functions

Define these in the `.insh` file to customize behavior:

| Function | Called when | Default |
|---|---|---|
| `__pre-run()` | Before `START_COMMAND` on initial launch only | no-op |
| `__post-run()` | After every invocation of `START_COMMAND` or `RESTART_COMMAND` | no-op |
| `__maximize()` | After `__post-run` on every start | runs `wmctrl` if `MAXIMIZE=$_TRUE` |

### Example `.insh` file

```bash
TITLE="My Application"
START_COMMAND="myapp --flag &"
PID_SEARCH_STRING="myapp"
KEEPALIVE=$_TRUE
MAXIMIZE=$_TRUE
MAXIMIZE_NAME="My Application — Main Window"

__pre-run() {
    /usr/bin/filter_ready    # wait for X display
    /usr/bin/desktop_ready   # wait for desktop
}

__post-run() {
    sleep 2
    PID=$(pgrep -o myapp || echo -n "0")
}
```

## Rootless Docker-in-Docker (DinD)

The `dockerfile-kasm-dev-desktop` image includes rootless Docker (`dockerd-rootless.sh`) for running Docker builds and containers inside the workspace.

### DNS configuration

Rootless Docker 24+ reads daemon config **only** from `~/.config/docker/daemon.json` — it does not fall back to `/etc/docker/daemon.json`. If `docker build` or container networking fails to resolve hostnames, ensure the correct DNS server is specified in the user's persistent profile:

```json
{
  "storage-driver": "fuse-overlayfs",
  "dns": ["<your-dns-server>"]
}
```

Place this file at `~/.config/docker/daemon.json` in the KASM persistent profile. The persistent profile is volume-mounted before the container entrypoint runs, so the file is present when `dockerd` starts.

### Docker socket

The inner Docker daemon socket is exposed at `unix:///docker/docker.sock` via `DOCKER_HOST`. Port 6901 is reserved for the workspace VNC server and cannot be used for Docker port mappings.
