import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location(
    "skill_validation", Path(__file__).resolve().parents[1] / "scripts/validate-skills.py"
)
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)


class SkillValidationTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.skill = self.root / "example"
        self.skill.mkdir()
        self.front = "---\nname: example\ndescription: Example workflow.\n---\n"

    def write_skill(self, body):
        (self.skill / "SKILL.md").write_text(self.front + body)

    def test_missing_guide_detected_and_repaired(self):
        self.write_skill("Read `references/guide.md`.\n")
        self.assertEqual(len(validator.validate(self.root)), 1)
        (self.skill / "references").mkdir()
        (self.skill / "references/guide.md").write_text("# Guide\n")
        self.assertEqual(validator.validate(self.root), [])

    def test_output_examples_and_remote_links_do_not_need_local_files(self):
        self.write_skill(
            "[Official guide](https://example.com/guide)\n"
            "```markdown\n[Example output](./project/GLOSSARY.md)\n```\n"
        )
        self.assertEqual(validator.validate(self.root), [])

    def test_name_must_match_directory(self):
        self.front = self.front.replace("name: example", "name: other")
        self.write_skill("# Workflow\n")
        self.assertTrue(any("name must match" in e for e in validator.validate(self.root)))

    def test_missing_link_in_supporting_document_is_detected(self):
        self.write_skill("[More](guide.md)\n")
        (self.skill / "guide.md").write_text("[Absent](missing.md)\n")
        self.assertTrue(any("missing.md" in e for e in validator.validate(self.root)))


if __name__ == "__main__":
    unittest.main()
