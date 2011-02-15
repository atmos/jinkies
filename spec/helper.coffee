require.paths.unshift(__dirname + "/../lib")

Vows = require "vows"
exports.Vows = Vows

Assert = require "assert"
exports.Assert = Assert

exports.default_options =
  job:     process.env.JENKINS_JOB              || "default"
  server:  process.env.JENKINS_SERVER           || "http://localhost:8080"
  campfire:
    user:    process.env.JENKINS_CAMPFIRE_USER    || 42
    room:    process.env.JENKINS_CAMPFIRE_ROOM    || 42
    token:   process.env.JENKINS_CAMPFIRE_TOKEN   || "xxxxxxxxxxxxxxxxxxxxxxxx"
    account: process.env.JENKINS_CAMPFIRE_ACCOUNT || "unknown"
