#!/bin/bash
# SPDX-FileCopyrightText: 2026 Thomas Foerster <noreply@tfoerster.de>
#
# SPDX-License-Identifier: MIT


#================#
#== USER INPUT ==#
#================#
## Add the Database ID here as a string

POSTGRES_DBS=(
    "PREFECT"
)

# Store raw variable names as strings (no '$' prefix)
PREFECT=(
    "PREFECT_USER"
    "PREFECT_PASSWORD"
    "PREFECT_DB"
)

# Base required variables + expanding variable names from PREFECT
REQUIRED_VARS=(
    "POSTGRES_USER"
    "POSTGRES_DB"
    "${PREFECT[@]}"
)

#===========#
#== TESTS ==#
#===========#

function _is_set {
  local -n REF="$1" 2>/dev/null || local REF="${!1}"
  [ -n "${REF+x}" ] && [ -n "$REF" ]
}

#---------------#

function _test_variables {

  local ERRORS=0
  local VARS=("$@")
 
  for VAR in "${VARS[@]}"; do
      
    if ! _is_set "$VAR"; then
      echo "ERROR: Variable '$VAR' is not set."
      ((ERRORS++))
    else
      echo "Variable '$VAR' is set."
    fi

  done

  if [ "$ERRORS" -ne 0 ]; then
    echo "-------------------------------------"
    echo "Validation of input variables FAILED."
    return 1
  fi

  echo "-------------------------------"
  echo "All required variables are set!"
  return 0

}

#===============#
#== FUNCTIONS ==#
#===============#

function _setting_databases {

for DB in "${POSTGRES_DBS[@]}"; do

  local -n db_id="$DB"
  
  local user="${!db_id[0]}"
  local password="${!db_id[1]}"
  local db="${!db_id[2]}"

# Create User and Database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create Database
    CREATE USER "${user}" WITH PASSWORD '${password}';
    CREATE DATABASE "${db}" OWNER "${user}";
    
    -- Revoke CONNECT on system DBs from PUBLIC (blocks ALL non-superusers)
    REVOKE CONNECT ON DATABASE "${POSTGRES_DB}" FROM PUBLIC;
    REVOKE CONNECT ON DATABASE template0 FROM PUBLIC;
    REVOKE CONNECT ON DATABASE template1 FROM PUBLIC;
    
    -- Revoke CONNECT on the new DB from PUBLIC (prevents future non-admin users from connecting)
    REVOKE CONNECT ON DATABASE "${db}" FROM PUBLIC;
    
    -- Explicitly grant CONNECT on the new DB to its designated owner only
    GRANT CONNECT ON DATABASE "${db}" TO "${user}";
EOSQL

# Grant privileges inside their specific database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "${db}" <<-EOSQL
    -- Make the user owner of the public schema inside their database
    ALTER SCHEMA public OWNER TO "${user}";

    -- Grant schema permissions
    GRANT ALL ON SCHEMA public TO "${user}";
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "${user}";
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "${user}";

    -- Ensure future objects created by anyone in this DB are fully accessible by the user
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO "${user}";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO "${user}";
EOSQL

done

}

#==========#
#== MAIN ==#
#==========#

function _testing {

  local FAILED=0

  #------------#
  ## Add your tests here
  _test_variables "${REQUIRED_VARS[@]}" || FAILED=1
  #------------#

  if [ "$FAILED" -ne 0 ]; then
    echo "====================================="
    echo "SUMMARY: One or more tests FAILED."
    echo "====================================="
    return 1
  fi

  echo "====================================="
  echo "SUMMARY: All tests PASSED!"
  echo "====================================="
  return 0

}

#---------------#

function _main {
  _setting_databases
}

#---------------#
if _testing; then
    _main
else
    echo "Aborting database setup due to failed tests."
    exit 1
fi

