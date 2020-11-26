#! /usr/bin/env node
'use strict'
const assert = require('assert')
const childProcess = require("child_process");
const util = require("util");
const exec = util.promisify(childProcess.exec);

const release = process.env.MEGALINTER_RELEASE || 'insiders'
const nodockerpull = (process.env.MEGALINTER_NO_DOCKER_PULL === 'true') ? true : false

const MEGA_LINTER = "mega-linter "

describe('CLI', function () {
    it('(CLI) Show help', async () => {
        const params = ["--help"];
        const { stdout, stderr } = await exec(MEGA_LINTER + params.join(" "));
        if (stderr) {
            console.error(stderr);
        }
        assert(stdout, "stdout is set");
        assert(stdout.includes("mega-linter-runner version"), 'stdout should contains "mega-linter-runner version"');
    })
    it('(CLI) Show version', async () => {
        const params = ["--version"];
        const { stdout, stderr } = await exec(MEGA_LINTER + params.join(" "));
        if (stderr) {
            console.error(stderr);
        }
        assert(stdout, "stdout is set");
        assert(stdout.includes("mega-linter-runner version"), 'stdout should contains "mega-linter-runner version"');
    })
    it('(CLI) run on own code base', async () => {
        const params = [
            "--path",
            "./..",
            "--release",
            release
        ];
        if (nodockerpull) {
            params.push("nodockerpull")
        }
        const { stdout, stderr } = await exec(MEGA_LINTER + params.join(" "));
        if (stderr) {
            console.error(stderr);
        }
        assert(stdout, "stdout is set");
    })
})
