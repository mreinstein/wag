var basename   = require('path').basename;
var htmlparser = require('htmlparser2');
var path       = require('path');
var join       = path.join;


// recursively parse a DOM node's structure
function _parseDOMNode (node, assetsPath, renamed, cdnPrefix) {
  var fname, i, len, n, newAssetPath, noop, ref, ref1, ref2, ref3, results;
  newAssetPath = null;

  // html relation types:
  //   type: tag    name: link
  //   type: script name: script
  //   type: tag    name: a
  //   type: tag    name: style
  //   type: tag    name: img

  if (node.type === 'tag' && (node.name === 'style' || node.name === 'link')) {
    newAssetPath = node.attribs.href;
  } else if (node.type === 'script' && node.name === 'script') {
    // if the src attribute isn't set, this must be an inline script with a body
    if ((ref = node.attribs) != null ? ref.src : void 0) {
      newAssetPath = node.attribs.src;
    }
  } else if (node.type === 'tag' && node.name === 'img' && node.attribs.src && node.attribs.src !== 'src') {
    newAssetPath = node.attribs.src;
  }
  if (newAssetPath) {
    if (newAssetPath.startsWith('http') || newAssetPath.startsWith('//')) {
      noop = ''; // skip absolute path references
    } else {
      newAssetPath = join(assetsPath, newAssetPath);
      if (renamed[newAssetPath]) {
        fname = cdnPrefix + "/" + (basename(renamed[newAssetPath]));
        if ((ref1 = node.attribs) != null ? ref1.src : void 0) {
          node.attribs.src = fname;
        } else if ((ref2 = node.attribs) != null ? ref2.href : void 0) {
          node.attribs.href = fname;
        }
      } else {
        console.log('skipping', newAssetPath);
      }
    }
  }

  // if this DOM node has any children, parse them for asset references
  if (node.children) {
    ref3 = node.children;
    results = [];
    for (i = 0, len = ref3.length; i < len; i++) {
      n = ref3[i];
      results.push(_parseDOMNode(n, assetsPath, renamed, cdnPrefix));
    }
    return results;
  }
}


module.exports = function renameHtmlReferences (filepath, text, assetsPath, renamed, cdnPrefix) {
  var d, handler, i, len, parser, result, updated;
  if (cdnPrefix == null) {
    cdnPrefix = '';
  }
  d = null;
  handler = new htmlparser.DomHandler((function(_this) {
    return function(er, dom) {
      var i, len;
      if (er) {
        throw new Error(er);
      } else {
        // parsing done, analyze the DOM
        for (i = 0, len = dom.length; i < len; i++) {
          d = dom[i];
          _parseDOMNode(d, assetsPath, renamed, cdnPrefix);
        }
      }
      return d = dom;
    };
  })(this));
  parser = new htmlparser.Parser(handler);
  parser.parseComplete(text);
  result = d;

  // html file parsed
  updated = '';
  for (i = 0, len = result.length; i < len; i++) {
    d = result[i];
    updated += htmlparser.DomUtils.getOuterHTML(d);
  }
  return updated;
};
