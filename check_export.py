"""Check the CSV written by `report.py --export` against the course rounding policy.

Usage: python3 check_export.py <exported.csv>
"""
import csv
import sys

# Policy: round half up to a whole number, then assign the letter.
# The first three rows are where round() (banker's rounding) gives a different answer.
EXPECTED = {
    "Avery": (87, "B+"),   # 86.5; round() gives 86, B
    "Blake": (93, "A"),    # 92.5; round() gives 92, A-
    "Casey": (83, "B"),    # 82.5; round() gives 82, B-
    "Drew": (96, "A"),
    "Emery": (72, "C"),
    "Finley": (90, "A-"),  # 89.8; comparing the raw score gives B+
    "Gray": (79, "C+"),
}


def main(path):
    with open(path, newline="") as f:
        rows = {r["student"]: r for r in csv.DictReader(f)}
    wrong = 0
    for student, (score, letter) in EXPECTED.items():
        row = rows.get(student)
        got = (row["score"], row["letter"]) if row else ("missing", "")
        ok = row is not None and float(row["score"]) == score and row["letter"] == letter
        wrong += not ok
        print(f"{'ok ' if ok else 'BAD'}  {student:<7} expected {score} {letter:<3} got {got[0]} {got[1]}")
    print(f"\n{len(EXPECTED) - wrong}/{len(EXPECTED)} rows follow the rounding policy")
    return 1 if wrong else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
