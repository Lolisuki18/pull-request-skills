---
type: llm
focus: trace
weight: 1
---

The reply identifies the dependency: `export_csv` uses `row_for` and the renamed helper, so the rename and refactor must come before the feature, and says each PR must build and pass tests on its own.
