import csv

# Percent weights; they must add up to 100.
WEIGHTS = {"hw": 30, "midterm": 30, "final": 40}


def load_roster(path):
    with open(path, newline="") as f:
        rows = list(csv.DictReader(f))
    for row in rows:
        for key in WEIGHTS:
            row[key] = int(row[key])
    return rows


def weighted_score(row):
    return sum(WEIGHTS[k] * row[k] for k in WEIGHTS) / 100
