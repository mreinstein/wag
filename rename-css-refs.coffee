basename    = require('path').basename
css         = require 'css'
path        = require 'path'
join        = path.join
parseCssUrl = require './parse-css-url'


module.exports = renameCssReferences = (filepath, text, assetsPath, renamed) ->
  c = css.parse text 
  for rule in c.stylesheet.rules
    if rule.type is 'rule'
      for dec in rule.declarations
        if dec.type is 'declaration' and (dec.property is 'background-image' or dec.property is 'background')
          url = parseCssUrl dec.value
          if url
            if url.startsWith('..')
              fullpath = join path.dirname(filepath), url
            else
              fullpath = join assetsPath, url

            #assets.push { path: fullpath, dec: dec }
            url = parseCssUrl dec.value
            fname = "/optimized/#{basename(renamed[fullpath])}"

            dec.value = dec.value.replace url, fname

  css.stringify(c, { compress: true })
