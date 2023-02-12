#!/usr/bin/env python3
"""
Use Raku to lint raku files
https://raku.org/
"""
import os

from megalinter import Linter
from megalinter import utils


class PyrightLinter(Linter):
    def pre_test(self):
        # The file must be in the root of the repository so we create it temporarily for the test.
        # By default pyright ignores files starting with "." so we override this behavior 
        # to work with the .automation folder
        with open(os.path.join(utils.REPO_HOME_DEFAULT, "pyproject.toml"), "w", encoding="utf-8") as f:
            f.write("""[tool.pyright]
exclude = [
    "**/node_modules",
    "**/__pycache__"
]""")

    def post_test(self):
        os.remove(os.path.join(utils.REPO_HOME_DEFAULT, "pyproject.toml"))
