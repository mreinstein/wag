var css         = require('css');
var fs          = require('fs');
var parseCssUrl = require('./parse-css-url');
var parser      = require('css-font-face-src');
var path        = require('path');
var join        = path.join;


function parseFontFaceUrls (src) {
  return parser.parse(src);
}


function parseCSS (assetsPath, filepath, text) {
  var assets, c, dec, fullpath, i, j, k, l, len, len1, len2, len3, next, parsed, ref1, ref2, ref3, rule, url;
  assets = [];
  c = css.parse(text);
  ref1 = c.stylesheet.rules;
  for (i = 0, len = ref1.length; i < len; i++) {
    rule = ref1[i];
    if (rule.type === 'font-face') {
      ref2 = rule.declarations;
      for (j = 0, len1 = ref2.length; j < len1; j++) {
        dec = ref2[j];
        if ((dec.type === 'declaration') && (dec.property === 'src')) {
          parsed = parser.parse(dec.value);
          for (k = 0, len2 = parsed.length; k < len2; k++) {
            next = parsed[k];
            if (next.url.startsWith('..')) {
              fullpath = join(path.dirname(filepath), next.url);
            } else {
              fullpath = join(assetsPath, next.url);
            }
            assets.push(fullpath);
          }
        }
      }
    } else if (rule.type === 'rule') {
      ref3 = rule.declarations;
      for (l = 0, len3 = ref3.length; l < len3; l++) {
        dec = ref3[l];
        if (dec.type === 'declaration' && (dec.property === 'background-image' || dec.property === 'background')) {
          url = parseCssUrl(dec.value);
          if (url) {
            if (url.startsWith('..')) {
              fullpath = join(path.dirname(filepath), url);
            } else {
              fullpath = join(assetsPath, url);
            }
            assets.push(fullpath);
          }
        }
      }
    }
  }
  return assets;
}


// given an asset directory and list of html files, parse them, looking for references to css assets
// returns an object where the key is the file path, and the value is an array of css assets referenced in the file (absolute paths)
module.exports = function (assetsPath, htmlRefs) {
  var cssRefs, f, file, i, len, noop, ref, refs, result;
  cssRefs = {};
  for (f in htmlRefs) {
    refs = htmlRefs[f];
    for (i = 0, len = refs.length; i < len; i++) {
      ref = refs[i];
      if (ref.endsWith('.css')) {
        // ignore absolute references
        if (ref.indexOf('//') === 0) {
          noop = '';
        } else if (ref.indexOf('http') === 0) {
          noop = '';
        } else {
          cssRefs[ref] = {};
        }
      }
    }
  }
  result = {};
  for (f in cssRefs) {
    refs = cssRefs[f];
    if (fs.existsSync(f)) {
      file = fs.readFileSync(f, 'utf8');
      result[f] = parseCSS(assetsPath, f, file);
    }
  }
  return result;
};
