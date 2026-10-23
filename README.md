# Papa Cologne PH Inventory

Inventory application for Papa Cologne PH. Sealed, brand-new full bottles are tracked as whole-unit SKUs; decants are separate SKUs by size, with their own prices and stock.

## Features in this repository
- React/Vite responsive inventory dashboard
- Email/password login with bcrypt password hashes and signed bearer tokens
- Role checks for OWNER, ADMIN, INVENTORY_STAFF, and SALES_STAFF
- Separate SKU setup for sealed bottles and decant sizes
- Stock receiving, sales recording, decant production, and stock movement history
- Excel inventory export restricted to authorized staff
- MySQL + Prisma schema and initial migration
- Vercel configuration and a Render Blueprint for the API + frontend

## Deploy on Render

Use the repository Blueprint (`render.yaml`) to create two Render services: `papa-cologne-api` and `papa-cologne-web`. The API uses MySQL; Render PostgreSQL is not compatible with the current Prisma schema.

**Follow the full production checklist:** [`docs/RENDER_DEPLOYMENT.md`](docs/RENDER_DEPLOYMENT.md). It covers managed MySQL, Render environment variables, production migrations, first-owner bootstrap, secret removal, and smoke testing.

Required API environment variables: `DATABASE_URL`, `JWT_SECRET` (32+ random characters), `BOOTSTRAP_SECRET` (temporary), and `CORS_ORIGIN` (exact frontend origin). The frontend requires `VITE_API_URL` set to the API origin and then a new frontend build. Never commit production secrets or place secrets in `VITE_*` variables.

The Render API Blueprint runs `prisma migrate deploy` as a pre-deploy command; Render requires a paid API service plan for pre-deploy commands, so review the plan and price before creating resources. If running migration manually (including from a trusted local terminal for a Free instance), use `npx prisma migrate deploy --schema apps/api/prisma/schema.prisma` from the repository root with the production `DATABASE_URL` set privately. Do not use `migrate reset` or `db push` on production.

## Deploy on Vercel

Import `TPEnvy/InventorySystem` using the repository root. Build command: `npm run build`; output directory: `apps/web/dist`. Configure `DATABASE_URL`, `JWT_SECRET`, `BOOTSTRAP_SECRET`, and `CORS_ORIGIN` in the appropriate Vercel environments. Keep `VITE_API_URL` unset for the same-origin Vercel routing in `vercel.json`. Apply the production migration from a trusted terminal/CI runner with `cd apps/api && npx prisma migrate deploy`, then bootstrap the first owner and remove `BOOTSTRAP_SECRET` immediately.

## Local development

Requires Node.js 20+ and MySQL. Copy `apps/api/.env.example` to `apps/api/.env` and fill in local-only values. Install dependencies from the repository root with `npm install`; build with `npm run build`. Run the API and frontend workspaces separately for development and set `VITE_API_URL` to the local API origin.

## Production readiness warning

A successful deployment/build is not proof of production readiness. Before entering real stock, confirm the production migration succeeded, remove the bootstrap secret, test login/roles, stock receiving, sales, decant calculations, Excel export, concurrent stock changes, backups/restores, and monitoring. The current app does not yet provide a complete purchase ledger, refunds/returns workflow, password reset, or a formal audit-log UI. Do not use it as the sole accounting source until these limitations and tests are addressed.
