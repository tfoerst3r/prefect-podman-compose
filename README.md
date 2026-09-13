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

To access the container use `podman exec`:

```bash
podman exec -it $(podman ps -q -f name=prefect) /bin/bash
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

