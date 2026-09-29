<p align="center"><img src="codealpha-logo.png" alt="CodeAlpha" width="190"></p>

# Circle Market

**An easygoing clothing marketplace built for the CodeAlpha internship.** Circle Market brings a small collection of everyday pieces into a calm, responsive storefront with soft colour, clear product photography-style illustrations and a simple path from discovery to order.

The collection features six fictional clothing products across shirts, layers and bottoms. Shoppers can filter the catalog, explore a dedicated page for each piece, adjust quantities in a shopping bag that persists across refreshes, and see prices in South African rand. A signed-in customer can place a sample order and revisit its status and line items in an order history view.

> Circle Market is a portfolio demonstration. Orders are recorded in the app, but no payment is collected and no goods are shipped.

## The experience

- A responsive catalog with category filters, featured picks and stock visibility
- Individual product details with descriptions, prices and add-to-bag actions
- A persistent shopping bag with quantity controls and live subtotal
- Email and password accounts for sample checkout and order history
- Server-validated order processing with stock reservation and order records
- Original illustrations for all six fictional clothing products

## Languages and tools

<p>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/html5/html5-original.svg" width="36" alt="HTML5"> &nbsp;
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/css3/css3-original.svg" width="36" alt="CSS3"> &nbsp;
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/javascript/javascript-original.svg" width="36" alt="JavaScript"> &nbsp;
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/nodejs/nodejs-original.svg" width="36" alt="Node.js"> &nbsp;
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/express/express-original.svg" width="36" alt="Express.js"> &nbsp;
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/supabase/supabase-original.svg" width="36" alt="Supabase"> &nbsp;
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/postgresql/postgresql-original.svg" width="36" alt="PostgreSQL">
</p>

| Part | Technology | Role |
| --- | --- | --- |
| Storefront | HTML, CSS, JavaScript | Product browsing, details and shopping bag |
| API | Node.js, Express.js | Catalog, session checks and order endpoints |
| Accounts | Supabase Auth | Customer identity |
| Database | Supabase PostgreSQL | Products, orders and stock |
| Data protection | Row Level Security | Customer-specific order visibility |

The Express server passes the customer's session to a PostgreSQL checkout function. The function reads current prices, checks quantities, locks products, reserves stock and creates the order in a single transaction. Store data lives in dedicated `shop_*` tables within the Dinglo Supabase project. The browser has only a publishable key; it never receives a privileged database key.

## CodeAlpha internship

Circle Market is a full-stack e-commerce project by [Kegorapetse Mangena](https://github.com/kegodev), covering responsive interface design, a JavaScript shopping bag, Express routes, authentication, relational data and order processing.
