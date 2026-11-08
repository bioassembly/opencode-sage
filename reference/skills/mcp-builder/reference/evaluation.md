# Evaluating an MCP server

Choose representative client tasks with independently checkable outcomes. Include
at least one successful call, invalid input, authorization failure, pagination or
large output where supported, and timeout/cancellation of a slow request.

Use the actual MCP client/Inspector against the selected transport. Confirm
initialization and tool discovery, then call tools with recorded arguments and
compare observable results against fixtures or the source system. Check that
errors are actionable and secrets are absent from tool responses and logs.

For a mutating tool, use an isolated fixture and verify both the intended change
and the scope that should remain unchanged. Check retry/idempotency behavior only
when the tool promises it. Do not run an evaluation against live production data
unless that action is already authorized.

Record server revision, SDK/client versions, transport, command, input, expected
result, observed result, and pass/fail. A JSON object per case is sufficient. Keep
model quality evaluation separate from protocol and deterministic integration
checks; do not claim a benchmark gain from successful initialization alone.

Official tool for interactive protocol checks:
[MCP Inspector](https://modelcontextprotocol.io/docs/tools/inspector).
