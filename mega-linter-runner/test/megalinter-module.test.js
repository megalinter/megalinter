#! /usr/bin/env node
'use strict'
const { MegaLinterRunner } = require('../lib/index')
const assert = require('assert')

const release = process.env.MEGALINTER_RELEASE || 'insiders'
const nodockerpull = (process.env.MEGALINTER_NO_DOCKER_PULL === 'true') ? true : false

describe('Module', function () {
    it('(Module) Show help', async () => {
        const options = {
            help: true
        }
        const res = await new MegaLinterRunner().run(options)
        assert(res.status === 0, `status is 0 (${res.status} returned)`)
        assert(res.stdout.includes("-r, --release String  Mega-Linter version - default: v4"), 'stdout contains help content');
    })
    it('(Module) Show version', async () => {
        const options = {
            version: true
        }
        const res = await new MegaLinterRunner().run(options)
        assert(res.status === 0, `status is 0 (${res.status} returned)`)
        assert(res.stdout.includes("mega-linter-runner version"), 'stdout should contains "mega-linter-runner version"');
    })
    it('(Module) run on own code base', async () => {
        const options = {
            path: './..',
            release,
            nodockerpull
        }
        const res = await new MegaLinterRunner().run(options)
        assert(res.status === 0, `status is 0 (${res.status} returned)`)
    })
})
