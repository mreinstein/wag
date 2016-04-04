fs        = require 'fs'
join      = require('path').join
optimize  = require './optimize'
parseCSS  = require './parse-css-refs'
parseHTML = require './parse-html'


# recursively find all HTML files
findHTMLFiles = (root) ->
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


# find all HTML files (entry points)
html = findHTMLFiles('/Users/michaelreinstein/wwwroot/nir-project/service-website/lib')

rootPath = '/Users/michaelreinstein/wwwroot/nir-project/service-website/public'
htmlRefs = parseHTML rootPath, html
styleRefs = parseCSS rootPath, htmlRefs

outputPath = '/tmp/mosaic'
results = optimize outputPath, htmlRefs, styleRefs

# TODO: copy files
#cp -r /tmp/mosaic /Users/michaelreinstein/wwwroot/nir-project/service-website/public/optimized
