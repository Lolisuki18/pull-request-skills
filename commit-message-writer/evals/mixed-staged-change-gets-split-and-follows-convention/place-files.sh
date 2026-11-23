#!/usr/bin/env bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval

mkdir -p src
cat > src/cart.py <<'EOF'
def total(items):
    return sum(i["price"] * i["qty"] for i in items)

def apply_discount(amount, percent):
    return amount - amount * percent / 100
EOF
cat > src/util.py <<'EOF'
def clamp(x, lo, hi):
    return max(lo, min(x, hi))
EOF
git add -A && git commit -q -m "feat(cart): add total and discount helpers"
echo "x" > .keep && git add -A && git commit -q -m "chore: add keep file"
cat > src/cart.py <<'EOF'
def total(items):
    return sum(i["price"] * i["qty"] for i in items)


def apply_discount(amount, percent):
    # percent is clamped: values above 100 used to produce negative totals
    percent = max(0, min(percent, 100))
    return amount - amount * percent / 100
EOF
cat > src/util.py <<'EOF'
def clamp(x, lo, hi):
    return max(lo, min(x, hi))


def noop():
    pass
EOF
git add -A
