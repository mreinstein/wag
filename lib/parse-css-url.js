module.exports = function parseStyleSheetUrl (declaration) {
  var b, pos, pos2, url;
  b = declaration.match(/url\((.+?)\)/gi);
  if (b) {
    pos = declaration.indexOf('url(');
    if (pos >= 0) {
      // found an image url
      pos2 = declaration.indexOf(')', pos + 4);
      url = declaration.substring(pos + 4, pos2).trim();
      return url.replace(/"|'/g, '');
    }
  }
  return '';
};
