#!/usr/bin/env bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
mkdir -p src tests
cat > src/cart.py <<'PY'
def total(items):
    return sum(i["price"] * i["qty"] for i in items)
PY
cat > tests/test_cart.py <<'PY'
from src.cart import total


def test_total():
    assert total([{"price": 2, "qty": 3}]) == 6
PY
git add -A && git commit -q -m "feat: cart total"
git checkout -q -b feature/discount
cp "$(dirname "$0")/files/brief.md" brief.md
cat >> src/cart.py <<'PY'


def apply_discount(total, percent):
    if percent < 0 or percent > 100:
        raise ValueError("percent must be between 0 and 100")
    return round(total * (100 - percent) / 100, 2)
PY
cat >> tests/test_cart.py <<'PY'


def test_discount():
    from src.cart import apply_discount
    assert apply_discount(10, 15) == 8.5
PY
git add -A && git commit -q -m "feat: apply_discount"
