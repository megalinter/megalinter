#!/usr/bin/env python3
"""
Use Dustilock to detect dependency injection hacks
https://github.com/Checkmarx/dustilock
"""

import json
import logging

from megalinter import Linter
from megalinter.constants import (
    DEFAULT_SARIF_SCHEMA_URI,
    DEFAULT_SARIF_VERSION,
    ML_DOC_URL,
)


class DustilockLinter(Linter):

    # Get dustilock text output and build SARIF output from it
    def manage_sarif_output(self, return_stdout):
        if self.can_output_sarif is True and self.output_sarif is True:
            # Build results
            logging.debug(
                "[dustilock] Build SARIF result from output stdout:\n" + return_stdout
            )
            results = []
            for line in return_stdout.splitlines():
                if line.startswith("error"):
                    error_text = line.partition(" - ")[2]
                    # npm error
                    if "npm" in error_text:
                        rule_id = "PACKAGE_JSON_ERROR"
                        rule_index = 0
                    # python error
                    elif "python" in error_text:
                        rule_id = "PYTHON_REQUIREMENT_ERROR"
                        rule_index = 1
                    # other error (we should not go there)
                    else:
                        rule_id = "OTHER_ERROR"
                        rule_index = 2
                    file = error_text.partition(". ")[2]
                    result = {
                        "level": "error",
                        "message": {"text": error_text},
                        "locations": [
                            {
                                "physicalLocation": {
                                    "artifactLocation": {
                                        "uri": file,
                                        "uriBaseId": "ROOTPATH",
                                    }
                                }
                            }
                        ],
                        "ruleId": rule_id,
                        "ruleIndex": rule_index,
                    }
                    results += [result]
            # Build final output
            sarif_obj = {
                "$schema": DEFAULT_SARIF_SCHEMA_URI,
                "properties": {
                    "comment": "Generated by MegaLinter for dustilock",
                    "docUrl": ML_DOC_URL,
                },
                "runs": [
                    {
                        "tool": {
                            "driver": {
                                "informationUri": "https://github.com/Checkmarx/dustilock",
                                "name": "dustilock",
                                "version": self.get_linter_version(),
                                "rules": [
                                    {
                                        "id": "PACKAGE_JSON_ERROR",
                                        "name": "Error in package.json",
                                        "shortDescription": {
                                            "text": "Dependency injection in package.json"
                                        },
                                    },
                                    {
                                        "id": "PYTHON_REQUIREMENT_ERROR",
                                        "name": "Error in Python requirements",
                                        "shortDescription": {
                                            "text": "Dependency injection in python requirements.txt"
                                        },
                                    },
                                    {
                                        "id": "OTHER_ERROR",
                                        "name": "Other errors",
                                        "shortDescription": {"text": "Other error"},
                                    },
                                ],
                            }
                        },
                        "results": results,
                    }
                ],
                "version": DEFAULT_SARIF_VERSION,
            }
            # Write sarif output file
            with open(self.sarif_output_file, "w", encoding="utf-8") as outfile:
                json.dump(sarif_obj, outfile, indent=4, sort_keys=False)
                outfile.write("\n")
