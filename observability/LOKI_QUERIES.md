# Loki Query Examples

Per-tenant log filtering (using tenant labels from promtail):

- `{tenant="tenant-a"} |= "tenant-a"`
- `{tenant="tenant-b"} |= "path=/"`

Top errors per tenant (if you add error logs):

- `sum(rate({tenant="tenant-a"} |~ "status=5" [5m]))`
- `sum(rate({tenant="tenant-b"} |~ "status=5" [5m]))`

Filter by app/environment:

- `{app="demo-api", environment="dev"}`
