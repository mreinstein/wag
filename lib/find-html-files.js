var fs   = require('fs');
var join = require('path').join;


/*
find all HTML files, descending into all nested directories in its search.
@return array absolute paths of all found html files
*/
module.exports = function findHTMLFiles (root) {
  var f, files, i, len, path, results, toTraverse;
  results = [];
  toTraverse = [root];
  while (toTraverse.length) {
    path = toTraverse.pop();
    if (fs.statSync(path).isDirectory()) {
      files = fs.readdirSync(path);
      for (i = 0, len = files.length; i < len; i++) {
        f = files[i];
        f = join(path, f);
        if (fs.statSync(f).isDirectory()) {
          toTraverse.push(f);
        } else {
          if (f.endsWith('.html')) {
            results.push(f);
          }
        }
      }
    } else {
      results.push(path);
    }
  }
  return results;
};
