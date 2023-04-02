#!/usr/bin/env python3
"""
Use GitLeaks to check for credentials in repository
"""
import json
import os

from git import Repo

from megalinter import Linter, config, utils


class GitleaksLinter(Linter):
    def __init__(self, params=None, linter_config=None):
        super().__init__(params, linter_config)
        self.pr_commits_scan = config.get("REPOSITORY_GITLEAKS_PR_COMMITS_SCAN", "false")
        if self.pr_commits_scan == "true" and utils.is_pr():
            self.pr_source_sha, self.pr_target_sha = self.get_pr_data()

    def get_pr_data(self):
        # Azure DevOps ref:
        # https://learn.microsoft.com/en-us/azure/devops/pipelines/build/variables?view=azure-devops&tabs=yaml
        # GitHub ref:
        # https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables
        # GitLab ref:
        # https://docs.gitlab.com/ee/ci/variables/predefined_variables.html

        pr_source_sha = config.get("REPOSITORY_GITLEAKS_PR_SOURCE_SHA")
        pr_target_sha = config.get("REPOSITORY_GITLEAKS_PR_TARGET_SHA")

        if pr_source_sha is None or pr_target_sha is None:
            if utils.is_azure_devops_pr():
                pr_source_sha = config.get("BUILD_SOURCEVERSION")
                pr_target_sha = self.get_azure_devops_pr_target_sha(config.get("SYSTEM_PULLREQUEST_TARGETBRANCH"))
            elif utils.is_github_pr():
                pr_source_sha, pr_target_sha = self.get_github_sha()
            elif utils.is_gitlab_mr() and utils.is_gitlab_premium():
                pr_source_sha = config.get("CI_MERGE_REQUEST_SOURCE_BRANCH_SHA")
                pr_target_sha = config.get("CI_MERGE_REQUEST_TARGET_BRANCH_SHA")
            elif utils.is_gitlab_external_pr() and utils.is_gitlab_premium():
                pr_source_sha = config.get("CI_EXTERNAL_PULL_REQUEST_SOURCE_BRANCH_SHA")
                pr_target_sha = config.get("CI_EXTERNAL_PULL_REQUEST_TARGET_BRANCH_SHA")

        return pr_source_sha, pr_target_sha

    def get_azure_devops_pr_target_sha(self, target_branch_name):
        repo = Repo(os.path.realpath(self.workspace))
        return repo.commit(target_branch_name.replace("refs/heads", "origin"))

    def get_github_sha(self):
        gh_event_file = open(os.environ["GITHUB_EVENT_PATH"])
        gh_event = json.load(gh_event_file)
        gh_event_file.close()
        return (
            gh_event["pull_request"]["head"]["sha"],
            gh_event["pull_request"]["base"]["sha"],
        )

    # Manage presence of --no-git in command line
    def build_lint_command(self, file=None):
        cmd = super().build_lint_command(file)
        # --no-git has been sent by user in REPOSITORY_GITLEAKS_ARGUMENTS
        # make sure that it is only once in the arguments list
        if "--no-git" in self.cli_lint_user_args:
            cmd = list(dict.fromkeys(cmd))
        # --no-git has been sent by default from ML descriptor
        # but as it is a git repo, remove all --no-git from arguments list
        elif "--no-git" in cmd and utils.is_git_repo(self.workspace):
            cmd = list(filter(lambda a: a != "--no-git", cmd))

        if config.get("VALIDATE_ALL_CODEBASE") == "false" and self.pr_commits_scan == "true" and utils.is_pr():
            if (
                    self.pr_target_sha is not None
                    and self.pr_source_sha is not None
                    and self.pr_target_sha != self.pr_source_sha
                ):
                # `--log-opts <arg_value>` has been sent by user in REPOSITORY_GITLEAKS_ARGUMENTS
                if "--log-opts" in cmd:
                    cmd.pop(cmd.index("--log-opts") + 1)
                    cmd.pop(cmd.index("--log-opts"))

                # `--log-opts=<arg_value>` has been sent by user in REPOSITORY_GITLEAKS_ARGUMENTS
                if any(v.startswith("--log-opts=") for v in cmd):
                    cmd.pop(cmd.index(next(v for v in cmd if v.startswith('--log-opts='))))

                self.cli_lint_extra_args = [
                    "--log-opts",
                    f"'{self.pr_target_sha}^..{self.pr_source_sha}'"
                ]
                cmd += self.cli_lint_extra_args

        return cmd
