#!/usr/bin/env python3
"""
Produce SARIF report
"""
import json
from json.decoder import JSONDecodeError
import logging
import os

from megalinter import Reporter, config
from megalinter.constants import DEFAULT_SARIF_REPORT_FILE_NAME


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
        if config.get("SARIF_REPORTER", "false") == "true":
            self.is_active = True

    def produce_report(self):
        sarif_obj = {
            "$schema": "https://schemastore.azurewebsites.net/schemas/json/sarif-2.1.0-rtm.5.json",
            "version": "2.1.0",
            "properties": {"comment": "Generated by MegaLinter"},
            "runs": [],
        }
        # Check delete linter SARIF file if LOG_FILE=none
        keep_sarif_logs = True
        if config.get("LOG_FILE", "") == "none":
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
                    # fix sarif file
                    linter_sarif_obj = self.fix_sarif(linter_sarif_obj)
                    # append to global megalinter sarif run
                    sarif_obj["runs"] += linter_sarif_obj["runs"]
                # Delete linter SARIF file if LOG_FILE=none
                if keep_sarif_logs is False and os.path.isfile(
                    linter.sarif_output_file
                ):
                    os.remove(linter.sarif_output_file)
        result_json = json.dumps(sarif_obj, sort_keys=True, indent=4)
        # Write output file
        sarif_file_name = f"{self.report_folder}{os.path.sep}" + config.get(
            "SARIF_REPORTER_FILE_NAME", DEFAULT_SARIF_REPORT_FILE_NAME
        )
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

    # Some SARIF linter output contain errors (like references to line 0)
    # We must correct them so SARIF is valid
    def fix_sarif(self, linter_sarif_obj):
        # browse runs
        if "runs" in linter_sarif_obj:
            for id_run, run in enumerate(linter_sarif_obj["runs"]):
                if "results" in run:
                    # browse run results
                    for id_result, result in enumerate(run["results"]):
                        if "locations" in result:
                            # browse result locations
                            for id_location, location in enumerate(result["locations"]):
                                if "physicalLocation" in location:
                                    location[
                                        "physicalLocation"
                                    ] = self.fix_sarif_physical_location(
                                        location["physicalLocation"]
                                    )
                                result["locations"][id_location] = location
                        run["results"][id_result] = result
                linter_sarif_obj["runs"][id_run] = run
        return linter_sarif_obj

    # Replace startLine and endLine in region or contextRegion
    def fix_sarif_physical_location(self, physical_location):
        for location_key in physical_location.keys():
            location_item = physical_location[location_key]
            if "startLine" in location_item and location_item["startLine"] == 0:
                location_item["startLine"] = 1
            if "endLine" in location_item and location_item["endLine"] == 0:
                location_item["endLine"] = 1
            physical_location[location_key] = location_item
        return physical_location
