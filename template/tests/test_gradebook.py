import unittest

from gradebook.letters import letter_for
from gradebook.scores import WEIGHTS, load_roster, weighted_score


class ScoresTest(unittest.TestCase):
    def test_weights_sum_to_100(self):
        self.assertEqual(sum(WEIGHTS.values()), 100)

    def test_weighted_score(self):
        row = {"hw": 95, "midterm": 97, "final": 96}
        self.assertAlmostEqual(weighted_score(row), 96.0)

    def test_load_roster(self):
        rows = load_roster("data/roster.csv")
        self.assertEqual(len(rows), 7)
        self.assertEqual(rows[0]["student"], "Avery")


class LettersTest(unittest.TestCase):
    def test_cutoffs(self):
        self.assertEqual(letter_for(95), "A")
        self.assertEqual(letter_for(90), "A-")
        self.assertEqual(letter_for(84), "B")
        self.assertEqual(letter_for(50), "E")


if __name__ == "__main__":
    unittest.main()
