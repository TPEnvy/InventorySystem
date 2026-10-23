# Render Production Deployment Guide

This guide deploys the Papa Cologne PH inventory app from `TPEnvy/InventorySystem` to Render. The app uses **MySQL + Prisma**. Render's managed PostgreSQL is not compatible with this schema; use an existing reachable MySQL database or a managed MySQL provider.

## 1. Prepare the MySQL database

1. Create a production database and a dedicated application user with permissions to create/alter tables and read/write the app database during migrations and normal use.
2. Enable TLS/SSL, restrict network access to the provider's allowed connections, and enable automated backups. Save the connection string in a password manager.
3. Confirm the provider's MySQL connection string format, typically `mysql://USER:PASSWORD@HOST:3306/DATABASE`. URL-encode special characters in the username/password if the provider requires it. Use the provider's TLS parameters as documented; do not disable certificate validation just to make a connection work.
4. Do not use a database that contains important existing data unless you have taken and verified a backup and reviewed the migration first.

## 2. Create the Render services from the Blueprint

1. Push this repository to GitHub and make sure the desired branch contains `render.yaml`.
2. In Render, choose **New → Blueprint**, connect GitHub, and select `TPEnvy/InventorySystem`.
3. Review the Blueprint before applying it. It defines an API web service and a static frontend. Select a region close to the database if possible.
4. Create the services. Render will ask for values marked `sync: false`; you can fill them during setup or in each service's **Environment** page.

## 3. Set the API service environment variables

Open the `papa-cologne-api` service → **Environment** and set these values for the production service:

| Variable | Value |
|---|---|
| `NODE_ENV` | `production` |
| `DATABASE_URL` | Production MySQL connection string, with TLS settings required by your provider |
| `JWT_SECRET` | A cryptographically random secret with at least 32 characters; keep it private |
| `BOOTSTRAP_SECRET` | A separate, temporary, one-time secret used only to create the first owner account |
| `CORS_ORIGIN` | Exact public frontend origin, e.g. `https://papa-cologne-web.onrender.com`; no trailing slash |

Generate secrets locally with a password manager or a cryptographically secure generator. Do not commit them to GitHub, paste them into public issues, or send them in ChatGPT. Avoid reusing the same value for `JWT_SECRET` and `BOOTSTRAP_SECRET`.

## 4. Set the frontend environment variable

1. Open the `papa-cologne-web` static site → **Environment**.
2. Set `VITE_API_URL` to the full public API origin, e.g. `https://papa-cologne-api.onrender.com` (no trailing slash). Use the actual URL shown by Render if it differs.
3. Set the API service's `CORS_ORIGIN` to the exact public URL of the static site. These two values must point to each other.
4. Save changes and trigger a deploy/redeploy of the frontend so the `VITE_API_URL` value is included in the built frontend bundle.

These values are public origins, not secrets. The frontend variable is compiled into browser code; never put credentials or private keys in any `VITE_*` variable.

## 5. Run and verify the production migration

The Blueprint runs `prisma migrate deploy` as the API service's pre-deploy command. It applies only committed migrations under `apps/api/prisma/migrations` and is intended for production deployment.

1. Before the first deployment, take a database backup or confirm that the new database is empty.
2. Deploy the API and inspect the Render deploy logs. Confirm the migration step succeeds before continuing.
3. If the migration fails, stop here. Do not create the owner account or enter stock. Review the full error, database connectivity/TLS, permissions, and migration status. Do not blindly reset or drop a production database.
4. To run the migration manually instead, use the Render Shell for the API service if available and run from the repository root:

   `npx prisma migrate deploy --schema apps/api/prisma/schema.prisma`

   If the shell opens inside `apps/api`, run `npx prisma migrate deploy` instead. Make sure the shell has the production `DATABASE_URL` set. Never print or share the value.

5. Check the deploy logs for successful completion. The migration should create the `User`, `Fragrance`, `ProductSku`, `InventoryBalance`, and `StockMovement` tables.

Do **not** use `prisma migrate reset`, `db push`, or manually drop production tables as a deployment shortcut.

## 6. Create the first owner account

After the API is deployed, create the first owner through the bootstrap endpoint. Use a private terminal or API client and substitute your real API URL and values:

```bash
curl -X POST 'https://YOUR-API.onrender.com/api/auth/bootstrap' \
  -H 'Content-Type: application/json' \
  --data '{"secret":"YOUR_TEMPORARY_BOOTSTRAP_SECRET","name":"Store Owner","email":"owner@example.com","password":"USE_A_UNIQUE_PASSWORD_AT_LEAST_12_CHARACTERS"}'
```

Use a unique password of at least 12 characters. Keep the response private because it includes a login token. The bootstrap endpoint should work only while there are no users in the database.

**Immediately after the owner account is created:** remove `BOOTSTRAP_SECRET` from the API service environment and redeploy the API. Then sign in through the website. Do not leave the bootstrap secret configured longer than necessary.

## 7. Production smoke test

Before entering real inventory, use test SKUs and verify all of the following:

- [ ] `https://YOUR-API.onrender.com/health` returns JSON with `ok: true`.
- [ ] The frontend loads and owner login works.
- [ ] An invalid login is rejected.
- [ ] Create one test sealed-bottle SKU and one matching decant SKU (each size has its own SKU).
- [ ] Receive stock and verify the quantity changes.
- [ ] Record a sale and verify stock decreases; an over-stock sale must be rejected.
- [ ] Produce decants and verify the source bottle liquid and decant quantity are correct.
- [ ] Export the inventory spreadsheet.
- [ ] Refresh/re-login and confirm data persists in MySQL.
- [ ] Check logs for errors and confirm automated backups and a restore procedure.

Remove test records before entering live stock if the app has no safe delete workflow; otherwise use a fresh test database for the smoke test.

## 8. Ongoing production safeguards

- Restrict owner/admin credentials and use a different account for routine sales.
- Keep database backups, and periodically test restoring one to a separate database.
- Rotate `JWT_SECRET` only with a planned re-login window because existing tokens will stop working.
- Add new schema changes as Prisma migrations committed to GitHub; review and back up before applying them.
- Monitor Render deploy logs and database health.
- Do not treat a successful build or a green health endpoint as proof that every inventory workflow is correct. Test sales/decant calculations and concurrent stock updates before relying on the app for accounting.

## Troubleshooting

- **CORS error in browser:** `CORS_ORIGIN` must exactly match the frontend origin, including `https://`, with no trailing slash.
- **Frontend calls wrong URL:** verify `VITE_API_URL`, then rebuild/redeploy the static site.
- **Database connection error:** verify host, port, allow-list, credentials, database name, TLS parameters, and whether the database accepts external connections.
- **Prisma cannot find schema:** run commands from the repository root with `--schema apps/api/prisma/schema.prisma`, or from `apps/api` without the schema flag.
- **Owner bootstrap says already closed:** a user already exists. Sign in with the existing owner account; do not delete users or reset the database to get around this.

## Important limitation

This guide prepares deployment configuration and operational steps; it does not itself provision a paid MySQL service, configure secrets in your Render account, or prove that a live production deployment has succeeded. The current app should receive end-to-end and concurrency testing before being used as the sole source of truth for inventory or accounting.