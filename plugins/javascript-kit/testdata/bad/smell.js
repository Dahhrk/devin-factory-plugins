'use strict';

const fs = require('fs');

function runBad(code) {
  return eval(code);
}

function mergeBad(req) {
  const target = {};
  target.__proto__ = req.body;
  return Object.assign(target, req.body);
}

function readBad(path) {
  return fs.readFileSync(path, 'utf8');
}

module.exports = { runBad, mergeBad, readBad };
