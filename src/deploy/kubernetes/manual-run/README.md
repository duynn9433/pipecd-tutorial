# Manual Run (Non-Kubernetes) Example

This example shows how to use PIPECD `SCRIPT_RUN` stages to manage an application that is NOT deployed as a Kubernetes workload. It supports two execution modes:

1. `jar` (default) – simulate downloading and running a standalone Java JAR (here replaced by a simple bash script stub).
2. `docker` – pull and run a Docker image/container.

## Files

- `app.pipecd.yaml` – pipeline definition with three SCRIPT_RUN stages (stop, fetch, start + rollback).
- `version.txt` – desired new version for the next deployment.
- `scripts/` – operational scripts invoked by the pipeline.
  - `fetch.sh` – records previous version, prepares artifact (creates dummy jar) or pulls docker image.
  - `stop.sh` – stops existing process or container.
  - `start.sh` – starts new version (or previous one on rollback).
- `current_version.txt` / `previous_version.txt` – tracking files created during deployments.
- `artifacts/` – holds downloaded (dummy) JAR files.
- `app.pid` – PID of a running *jar* mode process.

## Environment Variables

Set these (via stage `env` or globally) to switch behavior:

- `MODE=jar|docker` – choose execution mode (default `jar`).
- `IMAGE_REPO` – docker repository (when `MODE=docker`). Default: `myrepo/demo-app`.

You can add to each SCRIPT_RUN stage, for example:

```yaml
with:
  env:
    STEP: fetch
    MODE: docker
    IMAGE_REPO: gcr.io/your-project/demo-app
```

## Deploy / Rollback Flow

1. StopOld (SCRIPT_RUN): `stop.sh` kills prior process/container if any.
2. Fetch (SCRIPT_RUN): `fetch.sh` saves current version to `previous_version.txt`, prepares new artifact, writes pending version.
3. Start (SCRIPT_RUN): `start.sh` promotes pending to current and launches it. On rollback PIPECD executes the `onRollback` script which calls `start.sh rollback` to restart the prior version.

## Updating Version

Change `version.txt` and push a commit. The next pipeline run will:
- Move the existing `current_version.txt` to `previous_version.txt`.
- Create a dummy JAR `artifacts/app-<version>.jar` (or pull the docker image tag).
- Start that version.

## Local Testing (Jar Mode)

```bash
cd src/deploy/kubernetes/manual-run
chmod +x scripts/*.sh
./scripts/fetch.sh
./scripts/start.sh
./scripts/stop.sh
```

## Local Testing (Docker Mode)

```bash
export MODE=docker IMAGE_REPO=hello-world
./scripts/fetch.sh
./scripts/start.sh
./scripts/stop.sh
```

> The docker example uses generic commands; adjust port mapping or image as needed.

## Notes

- The JAR file here is a stub containing a bash script for demonstration.
- Add real download logic (curl/wget/artifact manager) where indicated.
- Handle logs, health checks, and graceful shutdown as future enhancements.

## Cleanup

```bash
rm -rf artifacts app.pid current_version.txt previous_version.txt current_version.txt.pending
```
