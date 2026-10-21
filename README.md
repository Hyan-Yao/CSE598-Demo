# CSE598-Demo: memory branch

The runtime example for the CSE 598 lab on agent memory. A user corrects a
coding agent once, in one session. In a later session, with no file in the
repo mentioning the correction, does the agent still follow it? You run the
same task with Codex memories off and on, and compare.

## The scenario

`template/` is a small gradebook repo. The course policy is to round the final
score half up to a whole number and then assign the letter: 86.5 becomes 87,
which is a B+. Python's `round()` uses banker's rounding (`round(86.5) == 86`),
which gives a B. The code, README and tests in the repo never state the policy.

- **Day 1.** In an interactive session, ask the agent for a feature, then
  correct how it rounds. The rule now exists only in that conversation.
- **Reset.** The code goes back to its starting point (the `day0` tag). After
  that, the rule exists only in Codex's memory folder.
- **Day 2.** A new task that needs rounding, run twice: memories off and on.
- **Check.** `check_export.py` lives outside the demo repo, so the agent never
  sees it.

## Layout

```
template/            the gradebook repo at day0 (copied out by setup.sh)
setup.sh             creates the demo repo and a separate CODEX_HOME with memories on
skip_idle_wait.sh    skips the 6-hour idle wait before Phase 1 (see below)
reset_day0.sh        puts the demo repo back to day0
check_export.py      checks the CSV written on Day 2
```

## Requirements

Python 3.9+ (standard library only), git, and the Codex CLI with a Codex subscription.

## Setup

```
git clone -b memory https://github.com/Hyan-Yao/CSE598-Demo.git CSE598-Memory-Demo
cd CSE598-Memory-Demo
bash setup.sh                       # creates ~/cse598-memory-demo and ~/.codex-memory-demo
export CODEX_HOME=~/.codex-memory-demo
```

The separate `CODEX_HOME` keeps the demo out of your own `~/.codex`: the memory
pipeline only reads and writes sessions under this folder. `setup.sh` copies
your `~/.codex/auth.json` into it so you stay logged in.

## Day 1 (interactive)

Day 1 must run in the interactive `codex` TUI. Sessions started with
`codex exec` are never extracted into memory.

```
cd ~/cse598-memory-demo
codex
```

Turn 1:

> Add a `--curve N` option to report.py that adds N points to every weighted score before the letter grade is assigned. Keep the existing output format.

Turn 2, after it finishes:

> One more thing. In this course, final scores are rounded half up to a whole number before the letter is assigned: 86.5 becomes 87, which is a B+. Python's round() does banker's rounding (round(86.5) == 86), so never use round() for grades. Please fix the report. No need to add tests this time.

Check that `python3 report.py` shows Avery as B+, then exit the session.

## Build the memory

```
bash reset_day0.sh                  # remove Day 1's code; the rule is now only in memory
```

Phase 1 only picks up sessions that have been idle for 6 hours. Either wait
6 hours, or skip the wait:

```
bash skip_idle_wait.sh              # marks Day 1 as last updated 7 hours ago
```

The script changes `threads.updated_at_ms` in `$CODEX_HOME/state_5.sqlite` and
the matching rollout file's modification time. It refuses to run against
`~/.codex`.

Then start any session to trigger the pipeline, for example `codex` with
"What does this repo do?". The pipeline runs in the background; keep the
session open for 3 to 5 minutes before you exit. Check what it produced:

```
ls $CODEX_HOME/memories/
cat $CODEX_HOME/memories/memory_summary.md
```

## Day 2: with and without memory

Reset before each run.

```
cd ~/cse598-memory-demo
PROMPT="Add an --export PATH option to report.py that writes a CSV with columns student,score,letter, where score is the student's final score as a whole number. Then run it with --export out/grades.csv."

# A: memories off
bash ~/CSE598-Memory-Demo/reset_day0.sh
codex exec --disable memories --ephemeral --json "$PROMPT" | tee ../eventsA.jsonl
python3 ~/CSE598-Memory-Demo/check_export.py out/grades.csv

# B: memories on
bash ~/CSE598-Memory-Demo/reset_day0.sh
codex exec --json "$PROMPT" | tee ../eventsB.jsonl
python3 ~/CSE598-Memory-Demo/check_export.py out/grades.csv
```

Adjust `~/CSE598-Memory-Demo` to wherever you cloned this branch. The event
logs go one level up so that `reset_day0.sh` does not delete them. Model output
varies between runs, so run A may get lucky; the Lab slides list what to look
for in the logs and in the memory folder.

## Start over

```
codex debug clear-memories          # with CODEX_HOME pointing at the demo home
rm -rf ~/cse598-memory-demo
bash setup.sh
```
