from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional

app = FastAPI()

# In-memory store
products: dict[int, dict] = {}
counter: int = 1


class ProductCreate(BaseModel):
    name: str
    price: float
    quantity: int


class ProductUpdate(BaseModel):
    name: Optional[str] = None
    price: Optional[float] = None
    quantity: Optional[int] = None


@app.get("/products")
def list_products():
    return list(products.values())


@app.post("/products", status_code=201)
def create_product(product: ProductCreate):
    global counter
    new = {"id": counter, **product.model_dump()}
    products[counter] = new
    counter += 1
    return new


@app.get("/products/{product_id}")
def get_product(product_id: int):
    if product_id not in products:
        raise HTTPException(status_code=404, detail="Product not found")
    return products[product_id]


@app.put("/products/{product_id}")
def update_product(product_id: int, product: ProductUpdate):
    if product_id not in products:
        raise HTTPException(status_code=404, detail="Product not found")
    updates = product.model_dump(exclude_unset=True)
    products[product_id].update(updates)
    return products[product_id]


@app.delete("/products/{product_id}")
def delete_product(product_id: int):
    if product_id not in products:
        raise HTTPException(status_code=404, detail="Product not found")
    return products.pop(product_id)
