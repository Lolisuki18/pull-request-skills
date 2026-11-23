#!/usr/bin/env bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval

mkdir -p src tests
cat > src/pricing.py <<'EOF'
def price(item):
    return item["unit"] * item["qty"]
EOF
cat > tests/test_pricing.py <<'EOF'
import unittest, sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))
from pricing import price


class T(unittest.TestCase):
    def test_plain(self):
        self.assertEqual(price({"unit": 2.5, "qty": 2}), 5.0)

    def test_rounding(self):
        self.assertEqual(price({"unit": 0.1, "qty": 3}), 0.3)

    def test_discount(self):
        self.assertEqual(price({"unit": 10, "qty": 2, "discount": 25}), 15.0)


if __name__ == "__main__":
    unittest.main()
EOF
git add -A && git commit -q -m "feat: pricing base"
git checkout -q -b feature/discount
cat > src/pricing.py <<'EOF'
def price(item):
    amount = item["unit"] * item["qty"]
    return amount - amount * item.get("discount", 0) / 100
EOF
git commit -qam "feat(pricing): support percentage discount"
git checkout -q main
cat > src/pricing.py <<'EOF'
def price(item):
    return round(item["unit"] * item["qty"], 2)
EOF
git commit -qam "fix(pricing): round to cents"
git checkout -q feature/discount
git merge main >/dev/null 2>&1 || true
git status --short
