# Backend Setup Guide

This project uses **[Supabase](https://supabase.com/)** as its backend for authentication, database, and API access.  
To run the app locally, you’ll need a local Supabase instance up and running.

## 1. Prerequisites

Make sure you have the following installed on your system:

- **[Docker](https://www.docker.com/get-started/)**  
    Supabase uses Docker containers to run locally.
- **[Supabase CLI](https://supabase.com/docs/guides/cli)**  
    You can install it via Homebrew, npm, or manual download.

## 2. Run

Start local Supabase instance:

```bash
supabase start
```

And if you want to stop it:

```bash
supabase stop
```

## 3. Backend Changes

If you want to modify the backend, fork this repository, commit changes and invite **TODO**.

> ❗️ Important -
> We expect that any changes will be applied to the backend when we run supabase start.

## 4. Database Structure

The Supabase backend provides authentication, user management, and data storage for the food ordering app.  
Below is an overview of the database schema, relationships, and how each entity fits together.

---

### 🧩 Enums

**`pizza_type`** — defines pizza categories: `vegetarian`, `vegan`, `meat`, `spicy`

**`role`** — defines user roles within the app: `user`, `admin`

---

### 👥 Users & Roles

#### **`users_data`**
Stores user information linked to the Supabase Auth system.

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` | Primary key, references `auth.users.id` |
| `email` | `text` | User’s email address |
| `created_at` | `timestamp with time zone` | Creation timestamp |

#### **`user_roles`**
Stores each user’s role (either `user` or `admin`).

| Column | Type | Notes |
|--------|------|-------|
| `user_id` | `uuid` | References `users_data.id` |
| `role` | `role` | Enum value defining the user’s role |

> 💡 New users are automatically added to both `users_data` and `user_roles` through a trigger when a record is created in `auth.users`.

---

### 🍕 Menu & Add-ons

#### **`pizzas`**
Stores the available pizzas in the menu.

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` | Primary key |
| `name` | `text` | Pizza name |
| `price` | `smallint` | Price in smallest currency unit |
| `image_url` | `text` | Image link |
| `description` | `text` | Optional description |
| `type` | `pizza_type` | Enum defining pizza category |

#### **`add_ons`**
Stores optional toppings or sides that can be added to pizzas.

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` | Primary key |
| `name` | `text` | Add-on name |
| `price` | `smallint` | Add-on price |

> 🧾 **Note:** The pizza menu data is pre-filled via **seed files** included in the Supabase setup.  
> These seed files populate the database with sample pizza entries for testing and UI development.

---

### 🧾 Orders

#### **`orders`**
Represents a user’s order.

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` | Primary key |
| `user_id` | `uuid` | References `users_data.id` |
| `created_at` | `timestamp with time zone` | Order creation time |

#### **`order_lines`**
Contains the individual pizzas (and their add-ons) within an order.

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` | Primary key |
| `order_id` | `uuid` | References `orders.id` |
| `pizza_id` | `uuid` | References `pizzas.id` |
| `price` | `smallint` | Pizza price at the time of order |
| `quantity` | `smallint` | Number of pizzas ordered |
| `add_ons` | `jsonb` | Optional list of add-ons for the line item |

#### **`order_lines_add_ons`**
A join table for many-to-many relationships between order lines and add-ons.

| Column | Type | Notes |
|--------|------|-------|
| `order_line_id` | `uuid` | References `order_lines.id` |
| `add_on_id` | `uuid` | References `add_ons.id` |

---

### ⚙️ Database Functions & Triggers

#### **`handle_new_user_creation()`**
Trigger that automatically:
1. Inserts a new record into `users_data` when a new `auth.users` entry is created.
2. Assigns the default role `user` into `user_roles`.

#### **`custom_access_token_hook(event jsonb)`**
Adds a user’s role into their JWT claims during authentication.  
This allows role-based access checks directly in the frontend without extra queries.