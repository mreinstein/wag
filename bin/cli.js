#!/usr/bin/env node

var join, pkg, program, AssetGraph, path, ag, typecount, shell;

path    = require('path');
join    = path.join;
pkg     = require(join(__dirname, '..', 'package'));
program = require('commander');
shell   = require('shelljs');
wag     = require('../lib');


program
  .version(pkg.version)
  .option('--inp [input]', 'input html directory')
  .option('--out [output]', 'output directory')
  .option('--assets [assets]', 'assets directory')
  .option('--cdnroot [cdnroot]', 'optional CDN root to prepend (e.g., //mycdn.example.com )')
  .parse(process.argv);

// print help and exit with error if input or output options are missing
if (!program.inp || !program.out) {
  program.help();
  process.exit(1);
}

/*
invocation example:

wag --inp /Users/michaelreinstein/wwwroot/nir-project/service-website/lib \
    --out /Users/michaelreinstein/wwwroot/nir-project/service-website/public/optimized \
    --assets /Users/michaelreinstein/wwwroot/nir-project/service-website/public \
    --cdnroot //cdn.saymosaic.com
*/

program.cdnroot = program.cdnroot || '';
program.out = path.resolve(program.out);
program.inp = path.resolve(program.inp);
program.assets = path.resolve(program.assets);
wag(program.out, program.cdnroot, program.inp, program.assets);


// clean out and create the output directory
//shell.rm('-Rf', join(program.out, '*'));
//shell.mkdir('-p', join(program.out, 'static'));
