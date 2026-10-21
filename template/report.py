import argparse

from gradebook.letters import letter_for
from gradebook.scores import load_roster, weighted_score


def main():
    parser = argparse.ArgumentParser(description="Print the course grade report.")
    parser.add_argument("--roster", default="data/roster.csv")
    args = parser.parse_args()

    for row in load_roster(args.roster):
        score = weighted_score(row)
        print(f"{row['student']:<8}{score:6.1f}  {letter_for(score)}")


if __name__ == "__main__":
    main()
