#!/usr/bin/env node

var join, pkg, program, AssetGraph, path, ag, typecount, shell;

path    = require('path');
join    = path.join;
pkg     = require(join(__dirname, '..', 'package'));
program = require('commander');
shell = require('shelljs');

program
  .version(pkg.version)
  .option('-i, --inp [input]', 'input directory')
  .option('-o, --out [output]', 'output directory')
  .option('-m, --minify', 'minify the output')
  .option('-h, --hash', 'rename files based on hash')
  .parse(process.argv);

// print help and exit with error if input or output options are missing
if (!program.inp || !program.out) {
  program.help();
  process.exit(1);
}

AssetGraph = require('../index').AssetGraph;

ag = new AssetGraph(program.inp);

ag.loadAssets('index.html');

console.log("\nloaded " + Object.keys(ag.nodes).length + " assets:");

typecount = {};

var count, k, out, type, useHashName, v, _ref;

_ref = ag.nodes;
for (k in _ref) {
  v = _ref[k];
  if (!typecount[v.type]) {
    typecount[v.type] = 0;
  }
  typecount[v.type] += 1;
}

for (type in typecount) {
  count = typecount[type];
  console.log('  ', type, ':', count);
}

if(program.minify) {
  ag.minifyAssets();
}

ag.moveAssets('static/');

hash = (typeof program.hash !== "undefined" && program.hash !== null);

// clean out and create the output directory
shell.rm('-Rf', join(program.out, '*'));
shell.mkdir('-p', join(program.out, 'static'));

ag.writeAssetsToDisc(program.out, hash);
