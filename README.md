# Papa Cologne PH Inventory

Vercel-oriented inventory application for Papa Cologne PH. It treats sealed, brand-new full bottles as whole-unit SKUs and decants as independently priced SKUs by size (for example 3 ml, 5 ml, 10 ml, 15 ml, or any supported custom size). Decant production consumes liquid from the corresponding full bottle, keeping unopened bottles separate from remaining opened liquid.

## Features in this repository
- React/Vite responsive inventory dashboard
- Email/password login with bcrypt password hashes and signed bearer tokens
- Role checks for OWNER, ADMIN, INVENTORY_STAFF, and SALES_STAFF
- SKU setup with different prices and stock for full bottles and each decant size
- Stock receiving, sales recording, decant production, and stock movement history
- Excel inventory export restricted to authorized staff
- MySQL + Prisma schema and initial migration
- Vercel serverless API entrypoint and deployment configuration

## Vercel setup
Import `TPEnvy/InventorySystem` as a Vercel project using the repository root. Build command is `npm run build`; output directory is `apps/web/dist`. The included `vercel.json` routes API calls through the serverless function.

Use a managed MySQL database with TLS enabled and automated backups. Add these environment variables in Vercel for Production (and Preview only if using a separate database):
- `DATABASE_URL`: MySQL connection string
- `JWT_SECRET`: long, random secret of at least 32 characters
- `BOOTSTRAP_SECRET`: temporary one-time owner creation secret
- `CORS_ORIGIN`: exact deployed frontend origin, e.g. `https://your-project.vercel.app`

Leave `VITE_API_URL` unset for same-origin deployment. Do not add real secrets to GitHub.

## First deployment checklist
1. Provision MySQL and save the connection string privately.
2. Configure the Vercel environment variables above and deploy from the repository root.
3. Apply the included Prisma migration from a trusted terminal/CI runner with the production `DATABASE_URL`: `cd apps/api && npx prisma migrate deploy`. Confirm the migration completed successfully.
4. Create the first owner account by POSTing JSON to `https://YOUR-DEPLOYMENT.vercel.app/api/auth/bootstrap`: `{"secret":"YOUR_BOOTSTRAP_SECRET","name":"Owner name","email":"owner@example.com","password":"a-long-unique-password"}`. The password must be at least 12 characters. This endpoint refuses to run after any user exists.
5. Immediately remove `BOOTSTRAP_SECRET` from Vercel and redeploy. Sign in through `/api/auth/login`. Authenticated API requests require `Authorization: Bearer YOUR_TOKEN`.
6. Verify login, create a test SKU, receive stock, record a test sale, produce test decants, export Excel, and verify the database balances. Use test data before entering real stock.

## Development
Requires Node.js 20+ and MySQL. Copy `apps/api/.env.example` to `apps/api/.env` and fill in local-only values. Run `npm install` at the repository root, then `npm run build` to build both apps. For development, run the API and frontend workspaces separately; set the frontend `VITE_API_URL` to the local API origin.

## Production warning
The code is deployment-oriented but has not been built or security-tested in the live Vercel environment from this chat. Do not treat it as production-ready until the build passes, the database migration succeeds, bootstrap secret is removed, end-to-end tests and concurrency tests pass, backups/restore are tested, and monitoring is enabled. The initial app does not yet provide a complete purchase ledger, refunds/returns workflow, password reset, or a formal audit log UI. Vercel deployment and managed database provisioning require access to your Vercel account and database credentials; no live URL is claimed until an actual deployment succeeds.
