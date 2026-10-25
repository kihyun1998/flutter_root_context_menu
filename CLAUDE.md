# CLAUDE.md

## Agent skills

| When you | Read first |
|---|---|
| create, read, comment on or label an issue | `doc/agents/issue-tracker.md` |
| apply a triage role (needs triage, ready for agent…) | `doc/agents/triage-labels.md` |
| explore the code, name a domain concept, or contradict a decision | `doc/agents/domain.md` |

## Territory map

[`doc/map/README.md`](doc/map/README.md) maps what each area does and what moves with it. Before designing a change, open the territory it touches and walk its blast radius. After it lands, update the notes it made false. When a fix reveals a fact, ask whether it holds at every site that shares the same assumption; if yes, it lands with an invariant note.

## Comments

A comment says what the code is. Why it is this way, what it deliberately leaves out, the trap and the measured value go to the territory note under `doc/map/`. Where none seems to hold it, search the folder and the code symbol first; only then start a new note, named for what the system does there, not for the file. History goes to the commit message. Comments written before this rule still carry the rest: never delete one whose content the map does not yet hold — move it first (`decant`).
