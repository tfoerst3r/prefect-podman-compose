<!--
SPDX-FileCopyrightText: 2026 Thomas Förster <noreply@tfoerster.de>

SPDX-License-Identifier: CC-BY-4.0
-->

<div align='center'>
  <h1>Prefect+Postgres And Compose</h1>
  <p style='font-size:32pt;'>
  </p>
</div>

## About the Project 

This project is about remembering how to deploy a prefect properly.

## Getting Started

> [!WARNING]
> This is not a productive system. The reason why, is that you will find the `secrets/` folder here.
> Your secrets should not be included in the project and the `secrets/` folder needs to be added to `.gitignore`! 
> This is just for demonstration.


### Prerequisites

- podman


## Usage


### Starting and Access the Container Infrastructure

Inside that root directory, start the container in the background. 

```bash
podman compose up --detach
```

To access the **prefect** container use `podman exec`:

```bash
podman exec -it $(podman ps -q -f name=prefect) /bin/bash
```

To access the **postgres** container use `podman exec`:

```bash
podman exec -it $(podman ps -q -f name=postgres) /bin/bash
```

To access the postgres shell for each user you can use one of the given.

```bash
psql -U $POSTGRES_USER -d $POSTGRES_DB
psql -U ${PREFECT_USER} -d ${PREFECT_DB}
psql "postgresql://$PREFECT_USER:$PREFECT_PW@localhost:5432/$PREFECT_DB"
```

This gives an error because the prefect user should not have access to other databases,
here the `postgres` database.

```
psql -U $PREFECT_USER -d postgres -c "SELECT 1;"
```

<!-- ---- -->

### Running CLI `prefect` 

First you need to install the needed packages. They locally sourced (meaning they are installed in the root folder via `.env/`). Run:

```bash
poetry install
```

Now you can run the installed module, which is defined in `src/`:

```bash
poetry run python -m prefectflow
```


<!-- ---- -->

### Working with the WebUI

Via the URL: `http://localhost:PREFECT_PORT` you can access the Prefect WebUI. 
Please use your prefect port, default is 4200.

## License

See `LICENSE.md` for more information.

