# SPDX-FileCopyrightText: 2026 Thomas Foerster <noreply@tfoerster.de>
#
# SPDX-License-Identifier: MIT

_DB_TYPE="postgresql"
_DB_ATTRIBUTE="asyncpg"
_DB_HOST="postgres" #.. name of the service instance, is internally set by DNS

export PREFECT_SERVER_DATABASE_CONNECTION_URL="${_DB_TYPE}+${_DB_ATTRIBUTE}://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${_DB_HOST}:${POSTGRES_PORT}/${PREFECT_DB}"
export PREFECT_API_URL="http://127.0.0.1:${PREFECT_PORT}/api"

