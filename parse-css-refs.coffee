css         = require 'css'
fs          = require 'fs'
parseCssUrl = require './parse-css-url'
parser      = require 'css-font-face-src'
path        = require 'path'
join        = path.join


parseFontFaceUrls = (src) -> parser.parse src


parseCSS = (assetsPath, filepath, text) ->
  assets = []

  c = css.parse text 
  for rule in c.stylesheet.rules
    if rule.type is 'font-face'
      for dec in rule.declarations
        if (dec.type is 'declaration') and (dec.property is 'src')
          parsed = parser.parse dec.value
          for next in parsed
            if next.url.startsWith('..')
              fullpath = join path.dirname(filepath), next.url
            else
              fullpath = join assetsPath, next.url
            assets.push { path: fullpath, dec: dec }

    else if rule.type is 'rule'
      for dec in rule.declarations
        if dec.type is 'declaration' and (dec.property is 'background-image' or dec.property is 'background')
          url = parseCssUrl dec.value
          if url
            if url.startsWith('..')
              fullpath = join path.dirname(filepath), url
            else
              fullpath = join assetsPath, url

            assets.push { path: fullpath, dec: dec }
  assets


# given an asset directory and list of html files, parse them, looking for references to css assets
# returns an object where the key is the file path, and the value is an array of css assets referenced in the file (absolute paths)
module.exports = (assetsPath, htmlRefs) ->
  cssRefs = {}

  for f, refs of htmlRefs
    for ref in refs
      if ref.endsWith('.css')
        # ignore absolute refs
        if ref.indexOf('//') is 0
          noop = ''
        else if ref.indexOf('http') is 0
          noop = ''
        else
          cssRefs[ref] = {}

  result = {}
  for f, refs of cssRefs
    if fs.existsSync(f)
      file = fs.readFileSync f, 'utf8'
      result[f] = parseCSS(assetsPath, f, file)
  result
