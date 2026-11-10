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

**Problem**: visitors need a cart to hold the products they want to buy.

**What I did**: `Cart` holds the cart, and `CartItem` links a cart to a product with a quantity (a whole number greater than zero, one by default).
A cart can hold a given product only once: trying to add it a second time is refused.
Increasing the quantity of an existing line comes with the "Add to cart" button, in the next PR.
This is enforced twice: by a validation, which gives a clear error, and by a unique index in the database, which also protects against two requests arriving at the same time.
The quantity can never be empty in the database (`null: false`).

**What I chose not to do**:
- Store the cart in the session: it is lost when the session ends, and it cannot be queried. With the cart in the database I can run queries on it and debug a problem afterwards.
- Add the "Add to cart" button, Turbo and Stimulus: they come in the next PRs, to keep this one small.

## Step 5: Add a product to the cart

**Problem**:
Visitors need to add a product to their cart, and adding the same product again should increase its quantity.

**What I did**:
`Cart#add_item(product)` looks for the product's line in the cart; if it exists, its quantity goes up by one, otherwise a new line is created with a quantity of one.

Two requests can arrive at the same time (a double click): both see no line, and the second insert is refused by the uniqueness validation or the unique index. In that case `add_item` retries once: the second lookup finds the line and increments it. If it fails again, the error is raised instead of looping forever.

`Cart#total_cents` now loads the products together with the lines (`includes(:product)`), so computing the total runs two queries instead of one query per line.

**What I chose not to do**:
- Use `find_or_initialize_by` instead of `find_by`. It always returns an object, so I would need an extra check `(new_record?)` to know whether the line is new; `find_by` returns `nil` when there is no line, which keeps the condition simple.
- Lock the cart row (`cart.with_lock`) to serialize requests: it would work, but it blocks every request on the cart, while the retry only costs something in the rare case of a collision.
- Use `upsert` with `ON CONFLICT ... quantity + 1`: a single query, but it skips validations and callbacks, and is harder to read for a first version.

## Step 6: Add to cart button with Turbo

**Problem**:
Visitors need a button to add a product to their cart from the catalog, and they should see the cart change without reloading the page.

**What I did**:
- Each product card has an "Add to cart" button (`button_to`) that posts to `CartItemsController#create`, which calls `Cart#add_item`.
- The visitor's cart is found through a `CurrentCart` concern: the session only stores the cart id, and the cart itself lives in the database. A cart is created the first time a product is added. If the cart in the session no longer exists, a new one is created.
- The header shows a cart counter (`CartCounterComponent`). The layout reads the count without creating a cart, so a visitor who only browses does not create an empty cart in the database.
- Turbo submits the form and asks for a Turbo Stream response: the controller replaces the counter and updates the flash message, so only those two parts of the page change. Without JavaScript, the same action redirects to the catalog with a notice.
- An unknown product returns a 404.

**What I chose not to do**:
- Write JavaScript or a Stimulus controller: Turbo Streams update the page from the server, with no custom JavaScript.
- Create a cart for every visitor on their first page view: it would fill the database with empty carts.
- Add Capybara for the component specs: `render_inline` returns an HTML fragment that I can query with CSS selectors, which is enough here.
- A cart page, removing items and changing the quantity: not needed to show the add-to-cart flow, they can come later.
