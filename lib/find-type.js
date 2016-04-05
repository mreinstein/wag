var path = require('path');


module.exports = function findType (filepath) {
  var ext, type;
  ext = path.extname(filepath || '').split('.');
  ext = ext[ext.length - 1];
  if (ext === 'html' || ext === 'htm') {
    type = 'html';
  } else if (ext === 'js') {
    type = 'javascript';
  } else if (ext === 'css') {
    type = 'style';
  } else if (['png', 'gif', 'jpg', 'jpeg', 'ico', 'svg'].indexOf(ext) >= 0) {
    type = 'image';
  } else if (['woff', 'woff2', 'ttf', 'eot'].indexOf(ext) >= 0) {
    type = 'font';
  }
  return type;
};
