#!/bin/bash

set -o allexport
source .env
set +o allexport

#DB Section
DBS=("DB1" "DB2")

for DB in "${DBS[@]}"; do
  HOST_VAR="${DB}_HOST"
  USER_VAR="${DB}_USER"
  PASS_VAR="${DB}_PASS"

  DB_HOST="${!HOST_VAR}"
  DB_USER="${!USER_VAR}"
  DB_PASS="${!PASS_VAR}"

  echo "==============================="
  echo "Checking DB Host: $DB_HOST"

  if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_PASS" ]]; then
    echo "Missing configuration for $DB Skipping..."
    continue
  fi

  echo -n "Checking TCP Port 3306.. "
  if nc -z -w 3 "$DB_HOST" 3306 2>/dev/null; then
    echo "Open"
  else
    echo "Closed"
    continue
  fi

  echo -n "Testing MySQL login..."
  RESULT=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" 2>&1)
  if echo "$RESULT" | grep -q "ERROR"; then
    echo "Login Failed"
    echo "$RESULT"
  else
    echo "Login Successful"
  fi
done

