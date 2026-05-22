# Yggdrasil

Yggdrasil deploys all microservices and databases for the crisis communication system — spin up the full stack with a single command.

## Services & Ports

| Service | Port | Purpose                                         |
|---|---|-------------------------------------------------|
| web-app-nidhogg | 3000 | Crisis communication frontend                   |
| api-service-notifier | 8082 (mock only) | Sends notifications via SMS and Teams           |
| api-service-webappusers | internal | Manages web app users and authentication        |
| api-service-sms-sender | internal | Sends SMS via Telia and Linkmobility            |
| api-service-teams-sender | internal | Sends messages via Microsoft Teams              |
| csv-filereader | internal | Imports organization and employee data from CSV |
| MariaDB | internal | notifier, users and teamssender databases       |
| WireMock (mock only) | 9090 | Mocks external SMS and Teams APIs               |

## Requirements

- Docker

## Quick Start

### Production
```bash
git clone git@github.com:Sundsvallskommun/Yggdrasil.git
cd Yggdrasil
```

Create the environment files with placeholder values:
```bash
for f in config/backend/.env-*.example; do cp "$f" "${f%.example}"; done
```

Then start the stack:
```bash
docker compose up -d
```

### Mock (local development)
Starts the full stack with WireMock replacing external SMS and Teams APIs. Includes mock CSV data with 12 employees and 5 organizations. Uses a separate database volume (`db_data_mock`) so production data is never affected.

Copy the example env files (if not already done):
```bash
for f in config/backend/.env-*.example; do cp "$f" "${f%.example}"; done
```

Then start the stack:
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

### Production
Fill in the required values in the created environment files:
```
config/backend/.env-notifier
config/backend/.env-webappusers
config/backend/.env-smssender
config/backend/.env-teams-sender
config/backend/.env-csv-filereader
```

### Mock
Mock environment files are included in the repo and require no configuration:
```
config/backend/mock-notifier.env
config/backend/mock-webappusers.env
config/backend/mock-smssender.env
config/backend/mock-teams-sender.env
config/backend/mock-csv-filereader.env
```

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

## Logs & Troubleshooting
```bash
# Tail all logs
docker compose logs -f

# Tail a specific service
docker compose logs -f api-service-notifier

# Check running services
docker compose ps
```