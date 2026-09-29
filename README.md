<p align="center"><img src="codealpha-logo.png" alt="CodeAlpha" width="190"></p>

# Circle Market

**A curated clothing storefront built for the CodeAlpha internship.** Circle Market carries the light teal palette and clean card layout of the [Circle social app](https://github.com/kegodev/circle-mini-social-express-supabase) into a complete small-store shopping journey.

The store lets visitors browse and filter a six-piece clothing catalog, open individual product pages, and keep a shopping bag across refreshes. Customers sign in with Supabase Auth to place a sample order and revisit their order history. Checkout recalculates prices from the database, reserves stock inside one PostgreSQL transaction, and gives each order an ID. This is a **demonstration store**: it does not collect payment or arrange shipping.

## What the app includes

- Responsive product listings with category filters and stock indicators
- Dedicated product detail pages
- Persistent shopping bag with quantity controls and live totals
- Email/password account registration and sign-in
- Express API for catalog, checkout and customer order history
- Atomic order creation with server-side price lookup and stock reservation
- Row Level Security so customers can view only their own orders
- Isolated `shop_*` tables inside the existing Dinglo Supabase project

## Built with

<p>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/html5/html5-original.svg" width="36" alt="HTML5"> &nbsp;
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/css3/css3-original.svg" width="36" alt="CSS3"> &nbsp;
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/javascript/javascript-original.svg" width="36" alt="JavaScript"> &nbsp;
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/nodejs/nodejs-original.svg" width="36" alt="Node.js"> &nbsp;
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/express/express-original.svg" width="36" alt="Express.js"> &nbsp;
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/supabase/supabase-original.svg" width="36" alt="Supabase"> &nbsp;
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/postgresql/postgresql-original.svg" width="36" alt="PostgreSQL">
</p>

| Layer | Implementation |
| --- | --- |
| Frontend | Vanilla HTML, CSS, JavaScript |
| Backend | Node.js and Express.js |
| Authentication | Supabase Auth |
| Data | Supabase PostgreSQL with Row Level Security |
| Checkout | PostgreSQL function with transaction and row locks |

## Shopping journey

1. Browse products and open a detail page.
2. Add items to the bag; quantities persist locally.
3. Register or sign in to submit a sample order.
4. Express checks the session and calls `shop_place_order` using the customer's token.
5. PostgreSQL locks the requested products, checks stock, calculates prices, creates the order and order lines, then decrements stock in one transaction.
6. View the receipt and order history in the app.

The browser never receives a privileged database key. The privileged checkout routine lives in the unexposed `shop_private` schema. The public RPC wrapper runs as the caller and admits authenticated users only. Tables deny direct client writes; RLS restricts order reads to the owner.

## Run locally

Requires Node.js 20 or later. Clone the repository, then run:

```bash
npm ci
npm start
```

Open `http://localhost:3000`. The included public Supabase project URL and publishable key point to the Dinglo project. Apply `supabase/schema.sql` to a different Supabase project and set `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` to reuse the app elsewhere. Email confirmation may be required by the project's Auth settings.

## Project scope

This internship project demonstrates clothing discovery, client-side cart state, authenticated API routes, relational order data, stock handling, input validation and a mobile-friendly UI. No real payment, shipping, tax, administrative fulfillment or production fraud controls are included.

Built by [Kegorapetse Mangena](https://github.com/kegodev) for **CodeAlpha**.
