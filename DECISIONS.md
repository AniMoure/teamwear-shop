# Decisions

Short log of the choices made on this project, what I chose not to do, and why.

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
