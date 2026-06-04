# Yggdrasil

Yggdrasil deploys all microservices and databases for the crisis communication system — spin up the full stack with a single command.

## Services & Ports

| Service                  | Port             | Purpose                                                              |
|--------------------------|------------------|---------------------------------------------------------------------|
| web-app-nidhogg          | 3000             | Crisis communication frontend                                       |
| api-service-notifier     | 8080 (mock only) | Notifications (SMS/Teams) **+** user auth/admin **+** CSV directory import |
| api-service-sms-sender   | internal         | Sends SMS via Telia and Linkmobility                                |
| api-service-teams-sender | internal         | Sends messages via Microsoft Teams (currently disabled)             |
| MariaDB                  | internal         | `notifier` database (single schema)                                 |
| WireMock (mock only)     | 9090             | Mocks external SMS and Teams APIs                                   |

> **Note:** `api-service-notifier` is now a single deployable that absorbs the former
> `api-service-webappusers` (user auth/admin) and `csv-filereader` (CSV import) services.

## Requirements

- Docker

## Quick Start

### Production
```bash
git clone git@github.com:Sundsvallskommun/Yggdrasil.git
cd Yggdrasil
```

Supply the production service configs (see [Configuration](#configuration)), then start the stack:
```bash
docker compose up -d
```

### Mock (local development)
Starts the full stack with WireMock replacing external SMS and Teams APIs. Includes mock CSV data with 12 employees and 5 organizations. Uses a separate database volume (`db_data_mock`) so production data is never affected.

No setup needed — the committed service configs already contain mock values. Just start the stack:
```bash
docker compose -f docker-compose.yml -f docker-compose.mock.yml up -d
```

To stop and keep production data intact:
```bash
docker compose down
```

To stop and clean up the mock database:
```bash
docker compose -f docker-compose.yml -f docker-compose.mock.yml down -v
```

## Configuration

Each backend service reads a single mounted `application.yml`. The files checked in here
contain **mock values** for local/mock runs and require no setup:
```
config/backend/application-notifier.yml
config/backend/application-smssender.yml
config/backend/application-teams-sender.yml
```

### Production
The committed files hold mock values only. For production, replace each
`config/backend/application-*.yml` with the real config (holding live secrets) from the
GitLab config repo before `docker compose up -d` — e.g. by checking the GitLab files out
over `config/backend/` on the deploy host, or bind-mounting them via
`docker-compose.override.yml`.

### web-app-nidhogg
nidhogg is a Node/Prisma app and can't read an `application.yml`, so it keeps its own
`config/secret.env` (gitignored) holding `DB_PASSWORD` and `DATABASE_URL`. This is the only
`.env` file in the repo. Point at an alternate file with `SECRETS_FILE=/path/to/secrets.env`.

## WireMock Tests

With the mock stack running, verify that all WireMock endpoints respond correctly:

```bash
# Run all test suites
bash config/wiremock/tests/run_all.sh

# Run a specific suite
bash config/wiremock/tests/run_all.sh sms
bash config/wiremock/tests/run_all.sh teams
bash config/wiremock/tests/run_all.sh e2e
```

See [config/wiremock/tests/README.md](config/wiremock/tests/README.md) for more details.

## Reset the stack

To start over from a completely clean state — empty databases, fresh CSV directories — as if running `docker compose up` for the first time:

```bash
docker compose down -v
docker compose up -d
```

`down -v` removes all containers, project networks, and the named volumes declared in `docker-compose.yml` (just `db_data`). The CSV import folders are bind-mounted under `/opt/apps/Yggdrasil/csv/` (`incoming`, `processed`, `failed`, `temp`), so `-v` does **not** touch them — clear them manually if needed. Images stay cached and bind-mounted files under `config/` are untouched.

Optional extras:
- `docker compose down -v --remove-orphans` — also clean up containers left behind by older compose variants.
- `docker compose pull` before `up -d` — re-pull image tags in case upstream has been updated in place.
- `docker volume rm yggdrasil_db_data_mock` — also drop the mock database volume (not declared in `docker-compose.yml`, so `-v` won't touch it).

If you want belt-and-suspenders verification afterward:
- `docker compose ps` — expect everything healthy/running
- `docker inspect --format '{{.Name}}: restarts={{.RestartCount}}' $(docker compose ps -q)` — Verify that all restarts = 0

## Logs & Troubleshooting
```bash
# Tail all logs
docker compose logs -f

# Tail a specific service
docker compose logs -f api-service-notifier

# Check running services
docker compose ps
```