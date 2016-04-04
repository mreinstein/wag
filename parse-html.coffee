fs         = require 'fs'
htmlparser = require 'htmlparser2'
join       = require('path').join


# recursively parse a DOM node's structure and build the list of references
_parseDOMNode = (node, filepath) ->
  assets = []

  toTraverse = [ node ]

  while toTraverse.length
    node = toTraverse.pop()

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
      if !node.attribs or !node.attribs.src
        noop = '' # ignore inlined javascript blocks
      else
        newAssetPath = node.attribs.src
    else if node.type is 'tag' and node.name is 'img' and node.attribs.src and node.attribs.src isnt 'src'
      newAssetPath = node.attribs.src

    if newAssetPath
      # ignore absolute refs
      if (newAssetPath.indexOf('//') is 0) or (newAssetPath.indexOf('http') is 0)
        noop = ''
      else
        assets.push newAssetPath

    # if this DOM node has any children, parse them for asset references
    if node.children
      toTraverse.push(n) for n in node.children

  assets


# given a list of html files, parse them, looking for references to other assets (images, css, javascript)
# returns an object where the key is the file path, and the value is an array of assets referenced in the file (relative paths)
#
# @param string rootPath    absolute path to the root directory containing the files in public/
module.exports = parseHTMLFiles = (rootPath, html=[]) ->
  references = {}
  # for each html file, parse asset references
  for f in html
    file = fs.readFileSync f
    handler = new htmlparser.DomHandler (er, dom) =>
      if er
        throw new Error(er)
      else
        # parsing done, analyze the DOM
        references[f] = {}
        for d in dom
          refs = _parseDOMNode(d, f)
          for ref in refs
            # convert relative path to absolute
            absPath = join rootPath, ref
            references[f][absPath] = true

    parser = new htmlparser.Parser handler
    parser.parseComplete file


  for f, refs of references
    references[f] = Object.keys(refs)

  references
