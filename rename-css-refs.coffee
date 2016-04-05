basename    = require('path').basename
css         = require 'css'
parser      = require 'css-font-face-src'
path        = require 'path'
join        = path.join
parseCssUrl = require './parse-css-url'


module.exports = renameCssReferences = (filepath, text, assetsPath, renamed, cdnPrefix='') ->
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

            next.url = "#{cdnPrefix}/#{basename(renamed[fullpath])}"

          dec.value = parser.serialize(parsed)

    else if rule.type is 'rule'
      for dec in rule.declarations
        if dec.type is 'declaration' and (dec.property is 'background-image' or dec.property is 'background')
          url = parseCssUrl dec.value
          if url
            if url.startsWith('..')
              fullpath = join path.dirname(filepath), url
            else
              fullpath = join assetsPath, url

            url = parseCssUrl dec.value
            fname = "#{cdnPrefix}/#{basename(renamed[fullpath])}"
            dec.value = dec.value.replace url, fname

  css.stringify(c, { compress: true })
