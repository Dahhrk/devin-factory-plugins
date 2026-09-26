'use strict';

const { readFile } = require('fs/promises');

async function readOk(path) {
  return readFile(path, 'utf8');
}

function mergeOk(body) {
  const out = Object.assign(Object.create(null), body);
  return out;
}

/* Named boundary docs; intentional legacy uses js-rg-allow on the smell line. */
function documentedLegacy(path) {
  const fs = require('fs');
  return fs.statSync(path); // js-rg-allow: boot-time view cache probe before async path binds
}

module.exports = { readOk, mergeOk, documentedLegacy };
