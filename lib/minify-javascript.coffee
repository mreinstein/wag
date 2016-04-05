UglifyJS = require 'uglify-js'


# uglifies (compresses) a javascript file 
#
# @param string filepath relative path of file
# @param buffer script
# @return string minified javascript file contents
module.exports = minifyJavascript = (filepath, script) ->
  opts = {} # filename : filepath, toplevel : toplevel

  obj = UglifyJS.parse script, opts
  obj.figure_out_scope()
  # https://github.com/mishoo/UglifyJS2#compressor-options
  # http://lisperator.net/uglifyjs/compress
  compressor = UglifyJS.Compressor { unused: false}
  obj.transform compressor
  minified = obj.print_to_string { beautify: false }
