# extras

Roles that are **not** part of the RoboShop deployment: ELK, Docker, Jenkins,
Kubernetes tooling, Prometheus and the old `monitoring_common` (filebeat,
node_exporter, rsyslog, Azure CLI).

They were moved here from `roles/others/` unchanged. `ansible.cfg` puts
`extras/roles` on the roles path so they still resolve by name, but they are
excluded from linting and have not been updated for Rocky Linux 9. Review
before using.
