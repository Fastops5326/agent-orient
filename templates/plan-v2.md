---
mission_ref: <link to the issue / mission prompt / transcript this answers>
risk: <low | medium | high>
predicted_files:
  - <path/you/expect/to/touch>
  - <add one line per path; this feeds collision checks and accuracy telemetry>
---

# Plan: <short title>

## MISSION

> <The work order, quoted VERBATIM. Do not paraphrase. This quote is the
> authority every other section — and the eventual build — is judged against.>

Source: <link>

## WHY

<The problem or opportunity. What breaks, costs, or stays unrealized if this
is not done. Reviewers cannot judge proportionality without this.>

## RECON

<Current-state facts WITH RECEIPTS. Every material claim cites its evidence:>

- <claim> — receipt: `<file>:<lines>` / `$ <command>` → `<observed output>`
- <claim> — receipt: <API response, CI run link, PR comment>

<Unreceipted claims are review findings. This section is what makes the build
assembly instead of discovery.>

## COLLISIONS

<The gate injects a computed map of open PRs whose files overlap this plan.
Dispose of every overlap here — one of:>

- #<n> <title> — rebase on it / sequence after it / no true overlap because <reason>
- <or:> No open PRs overlap (verify against the gate's injected map).

## OUTCOME

<Success as an observable state of the world, not effort. Someone who did not
do the work can check it. e.g. "orient's ENV line prints the declared
environment instead of the warning.">

## VALIDATION

<The executable path from "built" to "believed":>

- Commands run and their expected results
- Tests added, and what each proves
- Evidence that will land in the PR (output, screenshots, check runs)

## BUILD

<Ordered steps sized to commits. A competent stranger could execute this
without making a single decision you'd care about.>

1. <step> — files: <paths>; changes: <interfaces/contracts/schemas touched>;
   risk: <what could break>; rollback: <the undo move>
2. <step> — ...

## NON-GOALS

<Explicit exclusions. Work appearing in the diff that this section excludes is
a merge-gate finding, not a judgment call.>

- <thing this plan deliberately does not do>
