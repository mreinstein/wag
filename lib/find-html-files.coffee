fs   = require 'fs'
join = require('path').join


# find all HTML files, descending into all nested directories in its search.
# @return array absolute paths of all found html files
module.exports = findHTMLFiles = (root) ->
  results = []
  toTraverse = [ root ]

  while toTraverse.length
    path = toTraverse.pop()
    if fs.statSync(path).isDirectory()
      files = fs.readdirSync path
      for f in files
        f = join path, f
        if fs.statSync(f).isDirectory()
          toTraverse.push f
        else
          if f.endsWith '.html'
            results.push f
    else
      results.push path

  results
