# !/usr/bin/env python3
"""
Unit tests for TERRAFORM linter checkov
This class has been automatically generated by .automation/build.py, please do not update it manually
"""

from unittest import TestCase

from megalinter.tests.test_megalinter.LinterTestRoot import LinterTestRoot


class terraform_checkov_test(TestCase, LinterTestRoot):
    descriptor_id = "TERRAFORM"
    linter_name = "checkov"
