# Cognitive Debt Principles

Cognitive debt is created when automation produces changes that the responsible human cannot explain, operate, review, or safely change later.

The harness must preserve the human mental model of the feature. At each meaningful phase, explain:

- what was understood;
- how the system currently behaves;
- why the proposed direction fits;
- what changes and what does not;
- which boundaries, contracts, data, permissions, and operations are affected;
- what remains uncertain.

Do not create long documents for routine work. Record a decision when a new judgment, risky change, important assumption, or irreversible consequence needs to remain understandable. Code diff, tests, and operational evidence are the primary evidence; prose is a compact explanation of the evidence.

The invariant is: do not advance past a meaningful decision while the user lacks enough information to understand and approve it.

