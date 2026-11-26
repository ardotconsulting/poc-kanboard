# Kanboard on SQLite: single-container demo. The official image runs nginx + PHP-FPM
# with SQLite — no external database needed. Data (boards, tasks, users) persists on
# the volume at /var/www/app/data, mounted by Coolify in production.
# ADMIN_PASSWORD is set at runtime by OpenTofu (generated_secrets); never put it here.
# Pinned: a floating tag would change the app on any redeploy.
FROM kanboard/kanboard:v1.2.58

# Copy the idempotent admin-claim script (post_deploy)
COPY setup-admin.sh /setup-admin.sh
RUN chmod +x /setup-admin.sh

EXPOSE 80

