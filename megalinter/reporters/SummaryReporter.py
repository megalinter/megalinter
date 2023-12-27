#!/usr/bin/env python3
"""
Produce SARIF report
"""
import json
import logging
import os

from megalinter import Reporter, config, utils
from megalinter.utils_reporter import build_markdown_summary
from megalinter.constants import DEFAULT_SUMMARY_REPORT_FILE_NAME
    


class SummaryReporter(Reporter):
    name = "SUMMARY"
    scope = "mega-linter"

    def __init__(self, params=None):
        # Activate SUMMARY reporter by default
        self.is_active = True
        super().__init__(params)

    def manage_activation(self):
        if not utils.can_write_report_files(self.master):
            self.is_active = False
        elif (
            config.get(self.master.request_id, "SUMMARY_REPORTER", "true")
            != "true"
        ):
            self.is_active = False
        logging.info(
                f"[SUMMARY Reporter] Enabled: {self.is_active}"
            )

    def produce_report(self):
        summary = build_markdown_summary(self, pipeline_step_run_url="")

        # Write output file
        summary_file_name = f"{self.report_folder}{os.path.sep}" + config.get(
            self.master.request_id,
            "SUMMARY_REPORTER_FILE_NAME",
            DEFAULT_SUMMARY_REPORT_FILE_NAME,
        )
        if os.path.isfile(summary_file_name):
            # Remove from previous run
            os.remove(summary_file_name)
        with open(summary_file_name, "w", encoding="utf-8") as sarif_file:
            sarif_file.write(summary)
        logging.info(
            f"[SUMMARY Reporter] Generated {self.name} report: {summary_file_name}"
        )
        