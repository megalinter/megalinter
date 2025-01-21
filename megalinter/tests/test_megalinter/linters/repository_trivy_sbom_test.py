# !/usr/bin/env python3
"""
Unit tests for REPOSITORY linter trivy-sbom
This class has been automatically @generated by .automation/build.py, please don't update it manually
"""

import os
import unittest
from unittest import TestCase

from megalinter.tests.test_megalinter.LinterTestRoot import LinterTestRoot


class repository_trivy_sbom_test(TestCase, LinterTestRoot):
    descriptor_id = "REPOSITORY"
    linter_name = "trivy-sbom"

    def test_success(self):
        self.check_if_another_test_suite()
        super().test_success()

    def test_failure(self):
        raise unittest.SkipTest("Skipped because SBOM generation can not fail")

    def test_get_linter_version(self):
        self.check_if_another_test_suite()
        super().test_get_linter_version()

    def test_get_linter_help(self):
        self.check_if_another_test_suite()
        super().test_get_linter_help()

    def test_report_tap(self):
        self.check_if_another_test_suite()
        super().test_report_tap()

    def test_report_sarif(self):
        raise unittest.SkipTest("Skipped because SBOM generation can not fail")

    def test_format_fix(self):
        self.check_if_another_test_suite()
        super().test_format_fix()

    def check_if_another_test_suite(self):
        if os.environ.get("SINGLE_LINTER", "") == "REPOSITORY_TRIVY":
            raise unittest.SkipTest("Skipped because unrelated test suite")
