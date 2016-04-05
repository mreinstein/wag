var findHTML  = require('./find-html-files');
var fs        = require('fs');
var optimize  = require('./optimize');
var parseCSS  = require('./parse-css-refs');
var parseHTML = require('./parse-html');
var shell     = require('shelljs');


module.exports = function run (outputPath, cdnPrefix, htmlDirectory, assetsPath) {
  var html, htmlRefs, results, styleRefs;

  // find all HTML files (entry points)
  html = findHTML(htmlDirectory);
  htmlRefs = parseHTML(assetsPath, html);
  styleRefs = parseCSS(assetsPath, htmlRefs);
  shell.mkdir('-p', outputPath);
  shell.rm(outputPath + "/*");
  optimize(outputPath, assetsPath, htmlRefs, styleRefs, cdnPrefix);
};
