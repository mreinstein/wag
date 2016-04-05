var fs         = require('fs');
var htmlparser = require('htmlparser2');
var join       = require('path').join;


// recursively parse a DOM node's structure and build the list of references
function _parseDOMNode (node, filepath) {
  var assets, i, len, n, newAssetPath, noop, ref1, toTraverse;

  // html relation types:
  //   type: tag    name: link
  //   type: script name: script
  //   type: tag    name: a
  //   type: tag    name: style
  //   type: tag    name: img

  assets = [];
  toTraverse = [node];
  while (toTraverse.length) {
    node = toTraverse.pop();
    newAssetPath = null;
    if (node.type === 'tag' && (node.name === 'style' || node.name === 'link')) {
      newAssetPath = node.attribs.href;
    } else if (node.type === 'script' && node.name === 'script') {
      // if the src attribute isn't set, this must be an inline script with a body
      if (!node.attribs || !node.attribs.src) {
        noop = '';  // ignore inlined javascript blocks
      } else {
        newAssetPath = node.attribs.src;
      }
    } else if (node.type === 'tag' && node.name === 'img' && node.attribs.src && node.attribs.src !== 'src') {
      newAssetPath = node.attribs.src;
    }
    if (newAssetPath) {
      // ignore absolute references (probably an external asset)
      if ((newAssetPath.indexOf('//') === 0) || (newAssetPath.indexOf('http') === 0)) {
        noop = '';
      } else {
        assets.push(newAssetPath);
      }
    }

    // if this DOM node has any children, parse them for asset references
    if (node.children) {
      ref1 = node.children;
      for (i = 0, len = ref1.length; i < len; i++) {
        n = ref1[i];
        toTraverse.push(n);
      }
    }
  }
  return assets;
}


/**
  given a list of html files, parse them, looking for references to other assets (images, css, javascript)
  returns an object where the key is the file path, and the value is an array of assets referenced in the file (relative paths)

  @param string rootPath    absolute path to the root directory containing the files in public/
 */
module.exports = function parseHTMLFiles (rootPath, html) {
  var f, file, handler, i, len, parser, references, refs;
  if (html == null) {
    html = [];
  }
  references = {};

  // for each html file, parse asset references
  for (i = 0, len = html.length; i < len; i++) {
    f = html[i];
    file = fs.readFileSync(f);
    handler = new htmlparser.DomHandler((function(_this) {
      return function(er, dom) {
        var absPath, d, j, len1, ref, refs, results;
        if (er) {
          throw new Error(er);
        } else {
          // parsing done, analyze the DOM
          references[f] = {};
          results = [];
          for (j = 0, len1 = dom.length; j < len1; j++) {
            d = dom[j];
            refs = _parseDOMNode(d, f);
            results.push((function() {
              var k, len2, results1;
              results1 = [];
              for (k = 0, len2 = refs.length; k < len2; k++) {
                ref = refs[k];
                // convert relative to absolute path
                absPath = join(rootPath, ref);
                results1.push(references[f][absPath] = true);
              }
              return results1;
            })());
          }
          return results;
        }
      };
    })(this));
    parser = new htmlparser.Parser(handler);
    parser.parseComplete(file);
  }
  for (f in references) {
    refs = references[f];
    references[f] = Object.keys(refs);
  }
  return references;
};
