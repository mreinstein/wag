UglifyJS = require 'uglify-js'
fs       = require 'fs'
os       = require 'os'
path     = require 'path'
join     = path.join
shell    = require 'shelljs'


# TODO: replace shelljs with native process exec

# write an optimized image to a temp directory. shells out to external image
# optimization tools that are installed.
#
# @param string filepath relative path of file
# @param buffer script
# @return string minified javascript file contents
module.exports = minifyJavascript = (filepath, script) ->
  opts = {}
  ###
  opts =
    filename : filepath
    toplevel : toplevel
  ###
  obj = UglifyJS.parse script, opts
  obj.figure_out_scope()
  # https://github.com/mishoo/UglifyJS2#compressor-options
  # http://lisperator.net/uglifyjs/compress
  compressor = UglifyJS.Compressor { unused: false}
  obj.transform compressor
  minified = obj.print_to_string { beautify: false }
