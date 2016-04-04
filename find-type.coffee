path = require 'path'


module.exports = findType = (filepath) ->
    ext = path.extname(filepath or '').split '.'
    ext = ext[ext.length - 1]
    if ext is 'html' or ext is 'htm'
      type = 'html'
    else if ext is 'js'
      type = 'javascript'
    else if ext is 'css'
      type = 'style'
    else if [ 'png', 'gif', 'jpg', 'jpeg', 'ico', 'svg' ].indexOf(ext) >= 0
      type = 'image'
    type
