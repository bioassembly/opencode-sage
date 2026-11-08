# Tests that protect behavior

Test a meaningful observable contract through the highest practical public seam.
A regression test should fail on the original bug and pass after the fix. Confirm
that failure comes from the intended behavior, not a missing import or fixture.

Use small deterministic fixtures with representative boundary cases. Exercise
actual parsing, transformations, and persistence when those are the behavior
under test. Mock external services, clocks, or expensive dependencies at their
boundaries; do not mock away the operation whose correctness matters.

Assert the result or state transition rather than the exact private helper calls.
Include failure or recovery cases when the change affects them. Keep assertions
specific enough to reject plausible wrong implementations, but avoid locking in
incidental formatting or ordering that the contract does not guarantee.

Follow existing repository runners and fixtures. Add only tests proportional to
the change: a documentation edit or reversible cosmetic change may need a parser,
link check, or visual inspection rather than a new unit test. Report the executed
command and outcome; do not convert an unrun example into a completion claim.
