# FastAPI Product CRUD — Design Spec

**Date:** 2026-05-18  
**Status:** Approved

---

## Overview

A FastAPI application exposing full CRUD for a `Product` resource. Storage is an in-memory Python dict (no database). Intended as a functional reference/demo.

---

## File Structure

```
.
├── main.py               # FastAPI app instance, includes router
├── dependencies.py       # In-memory store + DI getter
├── models/
│   ├── __init__.py
│   └── product.py        # Pydantic schemas
└── routers/
    ├── __init__.py
    └── products.py       # CRUD endpoints
```

---

## Data Model

### Product fields

| Field    | Type    | Constraints |
|----------|---------|-------------|
| `id`     | `int`   | Auto-incremented, assigned on create |
| `name`   | `str`   | Required, non-empty |
| `price`  | `float` | Required, ≥ 0 |
| `quantity` | `int` | Required, ≥ 0 |

### Pydantic schemas (`models/product.py`)

- **`ProductCreate`** — used for POST body: `name`, `price`, `quantity`
- **`ProductUpdate`** — used for PUT body: all fields optional (enables partial updates)
- **`ProductResponse`** — returned by all endpoints: all fields including `id`

---

## Storage (`dependencies.py`)

A module-level `dict[int, dict]` holds all products in memory, keyed by `id`. A module-level `int` counter tracks the next id to assign. `get_db()` returns the dict and is injected via FastAPI `Depends`; the counter is accessed directly from `dependencies.py` by the router (incrementing a mutable counter via `Depends` would require a class-based approach, which is out of scope here).

```python
# Conceptual shape
products_db: dict[int, dict] = {}
id_counter: int = 1

def get_db() -> dict[int, dict]:
    return products_db
```

Data does not persist across server restarts — this is by design for this scope.

---

## Routes (`routers/products.py`)

Router prefix: `/products`. All responses use `ProductResponse`.

| Method   | Path                | Action                        | Success | Error |
|----------|---------------------|-------------------------------|---------|-------|
| `GET`    | `/products`         | Return list of all products   | 200     | —     |
| `POST`   | `/products`         | Create product, return it     | 201     | —     |
| `GET`    | `/products/{id}`    | Return single product by id   | 200     | 404   |
| `PUT`    | `/products/{id}`    | Update product (partial ok)   | 200     | 404   |
| `DELETE` | `/products/{id}`    | Delete product, return it     | 200     | 404   |

**Error handling:** `HTTPException(status_code=404)` when the requested `id` is not in the store. No other error paths for this scope.

---

## `main.py`

Creates the `FastAPI()` instance, includes the products router, and exposes a `/` health-check route returning `{"status": "ok"}`.

---

## Out of Scope

- Persistence (database, file)
- Authentication / authorization
- Pagination / filtering
- Input sanitization beyond Pydantic field types
