basename    = require('path').basename
htmlparser  = require 'htmlparser2'
path        = require 'path'
join        = path.join


# recursively parse a DOM node's structure
_parseDOMNode = (node, assetsPath, renamed, cdnPrefix) ->
  # html relation types:
  #   type: tag    name: link
  #   type: script name: script
  #   type: tag    name: a
  #   type: tag    name: style
  #   type: tag    name: img

  newAssetPath = null

  if node.type is 'tag' and (node.name is 'style' or node.name is 'link')
    newAssetPath = node.attribs.href
  else if node.type is 'script' and node.name is 'script'
    # if the src attribute isn't set, this must be an inline script with a body
    if node.attribs?.src
      newAssetPath = node.attribs.src
  else if node.type is 'tag' and node.name is 'img' and node.attribs.src and node.attribs.src isnt 'src'
    newAssetPath = node.attribs.src

  if newAssetPath
    if newAssetPath.startsWith('http') or newAssetPath.startsWith('//')
      noop = '' # skip absolute path references
    else
      newAssetPath = join assetsPath, newAssetPath
      if renamed[newAssetPath]
        fname = "#{cdnPrefix}/#{basename(renamed[newAssetPath])}"

        if node.attribs?.src
          node.attribs.src = fname
        else if node.attribs?.href
          node.attribs.href = fname
      else
        console.log 'skipping', newAssetPath

  # if this DOM node has any children, parse them for asset references
  if node.children
    for n in node.children
      _parseDOMNode n, assetsPath, renamed, cdnPrefix


module.exports = renameHtmlReferences = (filepath, text, assetsPath, renamed, cdnPrefix='') ->
  d = null
  handler = new htmlparser.DomHandler (er, dom) =>
    if er
      throw new Error(er)
    else
      # parsing done, analyze the DOM
      for d in dom
        _parseDOMNode d, assetsPath, renamed, cdnPrefix
    d = dom

  parser = new htmlparser.Parser handler
  parser.parseComplete text
  result = d

  # html file parsed

  updated = ''
  for d in result
    updated += htmlparser.DomUtils.getOuterHTML(d)
  updated
