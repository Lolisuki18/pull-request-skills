---
tags: [skill-creator]
max_turns: 20
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

i left this comment on a coworker's PR and he went quiet on me. can you make it better? keep my point though.

"This is wrong. Why would you query inside a loop?? Everyone knows that's an N+1. Rewrite it."

the code is a for loop over orders that calls db.query('SELECT * FROM items WHERE order_id = ' + order.id) each time
