var basename    = require('path').basename;
var css         = require('css');
var parser      = require('css-font-face-src');
var path        = require('path');
var join        = path.join;
var parseCssUrl = require('./parse-css-url');


module.exports = function renameCssReferences (filepath, text, assetsPath, renamed, cdnPrefix) {
  var c, dec, fname, fullpath, i, j, k, l, len, len1, len2, len3, next, parsed, ref, ref1, ref2, rule, url;
  if (cdnPrefix == null) {
    cdnPrefix = '';
  }
  c = css.parse(text);
  ref = c.stylesheet.rules;
  for (i = 0, len = ref.length; i < len; i++) {
    rule = ref[i];
    if (rule.type === 'font-face') {
      ref1 = rule.declarations;
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        dec = ref1[j];
        if ((dec.type === 'declaration') && (dec.property === 'src')) {
          parsed = parser.parse(dec.value);
          for (k = 0, len2 = parsed.length; k < len2; k++) {
            next = parsed[k];
            if (next.url.startsWith('..')) {
              fullpath = join(path.dirname(filepath), next.url);
            } else {
              fullpath = join(assetsPath, next.url);
            }
            next.url = cdnPrefix + "/" + (basename(renamed[fullpath]));
          }
          dec.value = parser.serialize(parsed);
        }
      }
    } else if (rule.type === 'rule') {
      ref2 = rule.declarations;
      for (l = 0, len3 = ref2.length; l < len3; l++) {
        dec = ref2[l];
        if (dec.type === 'declaration' && (dec.property === 'background-image' || dec.property === 'background')) {
          url = parseCssUrl(dec.value);
          if (url) {
            if (url.startsWith('..')) {
              fullpath = join(path.dirname(filepath), url);
            } else {
              fullpath = join(assetsPath, url);
            }
            url = parseCssUrl(dec.value);
            if (renamed[fullpath]) {
              fname = cdnPrefix + "/" + (basename(renamed[fullpath]));
              dec.value = dec.value.replace(url, fname);
            } else {
              console.error('WARNING: skipping', fullpath, ': file does not exist');
            }
          }
        }
      }
    }
  }
  return css.stringify(c, { compress: true });
};
