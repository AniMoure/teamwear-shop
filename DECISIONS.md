# Decisions

Log of the choices made on this project.

## Step 1: Project setup

**Problem**: start a Rails project close to the stack of the target job offer.

**What I did**: Rails 8.1 with PostgreSQL, Tailwind and Hotwire, with RSpec as the test framework.

**What I chose not to do**:
- Minitest: RSpec is the framework used on the target stack.
- Kamal (deployment) and Solid Queue: the target stack deploys on Heroku and uses GoodJob for background jobs, so Solid Queue would duplicate GoodJob. The same option also removed Solid Cache and Solid Cable, to revisit if needed.
- Vite (for now): the app uses Rails' default importmap, which loads JavaScript without a build step. Vite will be added in its own PR, so that any bug from the integration is easy to isolate.

## Step 2: Product model

**Problem**: a catalog needs products with a price.

**What I did**: a Product with a name and a price, validated, with the specs written first.

**What I chose not to do**: store the price as a decimal number. Computers do not represent decimals exactly (0.1 + 0.2 gives 0.30000000000000004), which gives wrong results with money. The price is stored in cents as an integer, which is also the unit Stripe expects.

## Step 3: Catalog page and ProductCard component

**Problem**: show the products to visitors on a catalog page.

**What I did**:

1. A catalog page listing the products, with each product displayed by a ViewComponent (`ProductCardComponent`). I used ViewComponent instead of a partial because it is part of the target stack, so I wanted to practice with it.

2. I wrote the component spec first (TDD): I described what the component should display before implementing it. The spec tells me when it works, and lets me change it later without breaking what it shows.

3. The price is formatted with Rails' `number_to_currency`, called through `helpers`, since a component does not have access to view helpers by default.

**What I chose not to do**:
- Format the price by hand: Rails already handles separators and rounding.
- Pagination, filtering and product images: the page only needs to list products for now.

## Step 4: Cart and CartItem models

## Step 4: Cart and CartItem models

**Problem**: visitors need a cart to hold the products they want to buy.

**What I did**: `Cart` holds the cart, and `CartItem` links a cart to a product with a quantity (a whole number greater than zero, one by default).
A cart can hold a given product only once: trying to add it a second time is refused.
Increasing the quantity of an existing line comes with the "Add to cart" button, in the next PR.
This is enforced twice: by a validation, which gives a clear error, and by a unique index in the database, which also protects against two requests arriving at the same time.
The quantity can never be empty in the database (`null: false`).

**What I chose not to do**:
- Store the cart in the session: it is lost when the session ends, and it cannot be queried. With the cart in the database I can run queries on it and debug a problem afterwards.
- Add the "Add to cart" button, Turbo and Stimulus: they come in the next PRs, to keep this one small.
