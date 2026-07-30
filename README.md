# agent-orient

One script: `orient.sh`. Agents arriving in a Fastops repo fetch and run it
to get a runtime terrain brief — gates, CI, environment, open work — computed
live from GitHub state at the moment of contact.

```sh
curl -fsSL https://raw.githubusercontent.com/Fastops5326/agent-orient/main/orient.sh | bash
```

Design laws (enforced by construction, not convention):

1. **Generated, never written** — output is computed live; there is no stored
   prose to go stale.
2. **Fail-soft** — denied queries print what the denial means, then continue.
3. **Budget** — output stays under ~40 lines. Pointers, not explanations.

This repo is deliberately public and deliberately tiny: working-repo agents
can read it but their tokens cannot write to it. Nothing here is sensitive —
the script only queries the repo it runs in, using the caller's own auth.


## Ridgeline cloud capability packs

Working-repo contract for named cloud powers (Orient / Ship sites / App data / AI doors / Enclave ops) lives in `teamguy-ai`:

https://github.com/Fastops5326/teamguy-ai/blob/master/docs/CLOUD-PACKS.md

Fetch orientation here; escalate deploy/vendor access via that pack catalog — not via a human desktop login.

