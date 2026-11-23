#!/usr/bin/env bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval

mkdir -p src tests
cat > src/report.py <<'EOF'
def build_rows(orders):
    rows = []
    for o in orders:
        rows.append([o["id"], o["total"]])
    return rows


def render(rows):
    return "\n".join(", ".join(str(c) for c in r) for r in rows)
EOF
cat > src/helpers.py <<'EOF'
def fmt(n):
    return "%.2f" % n
EOF
cat > tests/test_report.py <<'EOF'
from src.report import build_rows


def test_rows():
    assert build_rows([{"id": 1, "total": 2}]) == [[1, 2]]
EOF
git add -A && git commit -q -m "feat: report basics"
git checkout -q -b feature/export-csv
cat > src/helpers.py <<'EOF'
def format_money(n):
    return "%.2f" % n
EOF
cat > src/report.py <<'EOF'
from src.helpers import format_money


def row_for(order):
    return [order["id"], format_money(order["total"])]


def build_rows(orders):
    return [row_for(o) for o in orders]


def render(rows):
    return "\n".join(", ".join(str(c) for c in r) for r in rows)


def export_csv(orders, header=True):
    lines = []
    if header:
        lines.append("id,total")
    lines += [",".join(str(c) for c in row_for(o)) for o in orders]
    return "\n".join(lines)
EOF
cat > tests/test_report.py <<'EOF'
from src.report import build_rows, export_csv, row_for


def test_rows():
    assert build_rows([{"id": 1, "total": 2}]) == [[1, "2.00"]]


def test_row_for():
    assert row_for({"id": 2, "total": 1.5}) == [2, "1.50"]


def test_csv():
    assert export_csv([{"id": 1, "total": 2}]) == "id,total\n1,2.00"
EOF
git add -A && git commit -q -m "wip: export csv, helper rename, refactor"
