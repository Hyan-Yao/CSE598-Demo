# Lowest score for each letter, highest first.
CUTOFFS = [
    (93, "A"),
    (90, "A-"),
    (87, "B+"),
    (83, "B"),
    (80, "B-"),
    (77, "C+"),
    (70, "C"),
    (60, "D"),
]


def letter_for(score):
    for cutoff, letter in CUTOFFS:
        if score >= cutoff:
            return letter
    return "E"
