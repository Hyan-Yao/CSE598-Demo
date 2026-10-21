# CSE598-Demo: tool branch

A tiny login service with a seeded bug. It is the runtime example for
CSE 598 Lab 5 (tool use): the goal is to watch a coding agent find and fix
the bug with tools, and to match what you see to the Codex source code.

## Layout

```
src/hash.py      hash_password(pw), verify(pw, stored_hash)
src/session.py   create / get / destroy in-memory sessions
src/login.py     login(username, pw) -> Session | None
tests/           unittest suites for the three modules
AGENTS.md        instructions the agent reads before it starts
```

## Get it

```
git clone -b tool https://github.com/Hyan-Yao/CSE598-Demo.git CSE598-ToolUse-Demo
cd CSE598-ToolUse-Demo
```

## Run the tests

No dependencies beyond Python 3.9+.

```
python3 -m unittest -v
```

Two login tests error with a `ValueError` raised inside `src/hash.py`. The
traceback says where it hurts, not why: that is not where the bug is.

## Run the agent

```
git status                      # start from a clean tree
codex exec --json --sandbox workspace-write \
  "The login test is failing. Find out why and fix it." | tee events.jsonl
git diff                        # what the agent changed
python3 -m unittest -v          # verify
```

`events.jsonl` is the event stream the harness emits: every tool call the
model made, its output, and the file change. See the Lab 5 slides for what to
look for in it.

## Reset

```
git checkout -- src && rm -f events.jsonl
```
