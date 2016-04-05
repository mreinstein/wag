findHTML  = require './find-html-files'
fs        = require 'fs'
optimize  = require './optimize'
parseCSS  = require './parse-css-refs'
parseHTML = require './parse-html'
shell     = require 'shelljs'


module.exports = run = (outputPath, cdnPrefix, htmlDirectory, assetsPath) ->
  # find all HTML files (entry points)
  html = findHTML htmlDirectory

  htmlRefs = parseHTML assetsPath, html
  styleRefs = parseCSS assetsPath, htmlRefs

  shell.mkdir '-p', outputPath

  shell.rm "#{outputPath}/*"

  results = optimize outputPath, assetsPath, htmlRefs, styleRefs, cdnPrefix
