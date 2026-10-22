# Papa Cologne PH Inventory

Starter inventory app for sealed, brand-new full perfume bottles and decants in variable sizes.

- Full bottles are sold as sealed units and tracked by bottle count.
- Decants are separate SKUs by size (e.g. 3 ml, 5 ml, 10 ml, 15 ml, or custom size), each with its own cost and selling price.
- Producing decants consumes liquid from a matching full-bottle SKU; sealed bottles and opened-bottle remaining milliliters are tracked separately.
- Excel inventory export included.

## Stack
React + Vite + TypeScript, Node.js + Express, Prisma, MySQL, ExcelJS.

## Local setup
Use Node.js 20+ and MySQL 8+. Copy `apps/api/.env.example` to `apps/api/.env` and fill in credentials. In `apps/api`, run `npm install`, `npx prisma generate`, `npx prisma migrate dev --name init`, then `npm run dev`. In `apps/web`, run `npm install` and `npm run dev`. Set `VITE_API_URL` to the API URL.

## Render
Use an external managed MySQL provider (Render's native managed database is PostgreSQL). Configure `DATABASE_URL`, `JWT_SECRET`, `CORS_ORIGIN`, and `VITE_API_URL` in Render settings. Deploy the API and static frontend using `render.yaml`.

## Production warning
This is a starter scaffold, not a production-ready system. Authentication, server-side role-based access control, sales/purchase/returns flows, audit coverage, concurrency tests, and a security review must be completed before public use. Do not commit secrets or real `.env` files.