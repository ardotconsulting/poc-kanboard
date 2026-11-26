#!/bin/sh
# setup-admin.sh — idempotent admin claim for Kanboard POC.
# Kanboard ships with default admin/admin. This script changes the admin
# password to the generated ADMIN_PASSWORD by updating the SQLite database
# directly with PHP. Safe to re-run (overwrites the password hash each time).
set -e

# Wait for Kanboard web server to be ready
for i in $(seq 1 30); do
  code=$(wget -q -O /dev/null --spider -T 5 http://localhost:80/ 2>/dev/null && echo "200" || echo "000")
  if [ "$code" -ge 200 ] && [ "$code" -lt 500 ]; then
    echo "Kanboard is ready (HTTP $code)."
    break
  fi
  if [ "$i" = "30" ]; then
    echo "Kanboard not ready after 150s — continuing anyway."
    exit 0
  fi
  sleep 5
done

# Update admin password directly in the SQLite database using PHP.
# The database is created on first boot; by the time the web server answers,
# it exists and has the default admin user (id=1, username=admin).
php -r '
$hash = password_hash(getenv("ADMIN_PASSWORD"), PASSWORD_BCRYPT);
$db = new SQLite3("/var/www/app/data/db.sqlite");
$stmt = $db->prepare("UPDATE users SET password = :hash WHERE username = :username");
$stmt->bindValue(":hash", $hash, SQLITE3_TEXT);
$stmt->bindValue(":username", "admin", SQLITE3_TEXT);
$stmt->execute();
$changes = $db->changes();
$db->close();
if ($changes > 0) {
    echo "Admin password updated ($changes row(s)).\n";
} else {
    echo "No admin user found or password already set (0 rows changed).\n";
}
'

exit 0
