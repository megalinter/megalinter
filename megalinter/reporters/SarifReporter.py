#!/usr/bin/env python3
"""
Produce SARIF report
"""
import json
import logging
import os
from json.decoder import JSONDecodeError

from megalinter import Reporter, config, utils
from megalinter.constants import (
    DEFAULT_SARIF_REPORT_FILE_NAME,
    DEFAULT_SARIF_SCHEMA_URI,
    DEFAULT_SARIF_VERSION,
    ML_DOC_URL,
)
from megalinter.utils import normalize_log_string


class SarifReporter(Reporter):
    name = "SARIF"
    scope = "mega-linter"
    report_type = "simple"

    def __init__(self, params=None):
        # Deactivate JSON output by default
        self.is_active = False
        self.processing_order = -9999  # Run first
        super().__init__(params)

    def manage_activation(self):
        if not utils.can_write_report_files(self.master):
            self.is_active = False
        elif config.get(self.master.request_id, "SARIF_REPORTER", "false") == "true":
            self.is_active = True

    def produce_report(self):
        sarif_obj = {
            "$schema": DEFAULT_SARIF_SCHEMA_URI,
            "version": DEFAULT_SARIF_VERSION,
            "properties": {
                "comment": "Generated by MegaLinter",
                "docUrl": ML_DOC_URL,
                "dockerImage": {
                    "buildDate": config.get(None, "BUILD_DATE", ""),
                    "buildRevision": config.get(None, "BUILD_REVISION", ""),
                    "buildVersion": config.get(None, "BUILD_VERSION", ""),
                    "flavor": config.get(None, "MEGALINTER_FLAVOR", "none"),
                    "singleLinter": config.get(None, "SINGLE_LINTER", ""),
                },
            },
            "runs": [],
        }
        # Check delete linter SARIF file if LOG_FILE=none
        keep_sarif_logs = True
        if config.get(self.master.request_id, "LOG_FILE", "") == "none":
            keep_sarif_logs = False
        # Build unique SARIF file with all SARIF output files
        for linter in self.master.linters:
            if linter.sarif_output_file is not None and os.path.isfile(
                linter.sarif_output_file
            ):
                # Read SARIF output file
                load_ok = False
                with open(
                    linter.sarif_output_file, "r", encoding="utf-8"
                ) as linter_sarif_file:
                    # parse sarif file
                    try:
                        linter_sarif_obj = json.load(linter_sarif_file)
                        load_ok = True
                    except JSONDecodeError as e:
                        # JSON decoding error
                        logging.error(
                            f"[SARIF reporter] ERROR: Unable to decode {linter.name} "
                            f"SARIF file {linter.sarif_output_file}"
                        )
                        logging.error(str(e))
                        logging.debug(
                            f"SARIF File content:\n{linter_sarif_file.read()}"
                        )
                    except Exception as e:  # noqa: E722
                        # Other error
                        logging.error(
                            f"[SARIF reporter] ERROR: Unknown error with {linter.name} "
                            f"SARIF file {linter.sarif_output_file}"
                        )
                        logging.error(str(e))
                if load_ok is True:
                    # append to global megalinter sarif run
                    sarif_obj["runs"] += linter_sarif_obj["runs"]
                    # Delete linter SARIF file if LOG_FILE=none
                    if keep_sarif_logs is False and os.path.isfile(
                        linter.sarif_output_file
                    ):
                        os.remove(linter.sarif_output_file)
        result_json = json.dumps(sarif_obj, sort_keys=True, indent=4)
        # Remove workspace prefix from file names
        result_json = result_json.replace("file:///github/workspace", "")
        result_json = normalize_log_string(result_json)
        # Write output file
        sarif_file_name = f"{self.report_folder}{os.path.sep}" + config.get(
            self.master.request_id,
            "SARIF_REPORTER_FILE_NAME",
            DEFAULT_SARIF_REPORT_FILE_NAME,
        )
        if os.path.isfile(sarif_file_name):
            # Remove from previous run
            os.remove(sarif_file_name)
        with open(sarif_file_name, "w", encoding="utf-8") as sarif_file:
            sarif_file.write(result_json)
            logging.info(
                f"[SARIF Reporter] Generated {self.name} report: {sarif_file_name}"
            )

    def filter_fields(self, obj, fields_to_keep):
        for field in dir(obj):
            if (
                not field.startswith("__")
                and not callable(getattr(obj, field))
                and (
                    (len(fields_to_keep) > 0 and field not in fields_to_keep)
                    or getattr(obj, field, None) is None
                )
            ):
                try:
                    delattr(obj, field)
                except:  # noqa: E722
                    pass
        return obj
