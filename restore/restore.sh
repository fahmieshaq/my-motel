#!/usr/bin/env bash
set -Eeuo pipefail

fail() {
  status=$?
  echo "RESTORE_FAILED: PostgreSQL restore exited with code ${status}" >&2
  exit "$status"
}
trap fail ERR

: "${SPRING_DATASOURCE_URL:?Missing restore database URL}"
: "${SPRING_DATASOURCE_USERNAME:?Missing restore username}"
: "${SPRING_DATASOURCE_PASSWORD:?Missing restore password}"
: "${BACKUP_BUCKET:?Missing backup bucket}"
: "${BACKUP_KEY:?Missing backup object key}"
: "${AWS_REGION:?Missing AWS region}"

connection_uri="${SPRING_DATASOURCE_URL#jdbc:}"
connection_uri="${connection_uri%%\?*}"

# Neon restore-test uses database neondb on a separate branch.
# Replace this placeholder with the exact restore-test Neon hostname.
RESTORE_TEST_HOST="ep-fragrant-band-za0litj4-pooler.c-2.eu-west-2.aws.neon.tech"

if [[ "$connection_uri" != "postgresql://${RESTORE_TEST_HOST}/neondb" ]]; then
  echo "RESTORE_FAILED: Target must be Motel restore-test" >&2
  exit 1
fi

export PGUSER="$SPRING_DATASOURCE_USERNAME"
export PGPASSWORD="$SPRING_DATASOURCE_PASSWORD"
export PGSSLMODE=require
export PGCONNECT_TIMEOUT=20

backup_file="$(mktemp /tmp/motel-restore-XXXXXXXX.dump)"
trap 'rm -f -- "$backup_file"' EXIT

echo "Downloading database backup from S3"

aws s3 cp \
  "s3://${BACKUP_BUCKET}/${BACKUP_KEY}" \
  "$backup_file" \
  --region "$AWS_REGION" \
  --only-show-errors

echo "Restoring PostgreSQL database"

if [[ ! -s "$backup_file" ]]; then
  echo "RESTORE_FAILED: Empty backup file" >&2
  exit 1
fi

pg_restore \
  --dbname="$connection_uri" \
  --clean \
  --if-exists \
  --no-owner \
  --no-acl \
  --exit-on-error \
  "$backup_file"

echo "RESTORE_SUCCESS"