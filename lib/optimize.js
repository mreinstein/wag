var basename = require('path').basename;
var css = require('css');
var dirname = require('path').dirname;
var findType = require('./find-type');
var fs = require('fs');
var hash = require('./hash');
var join = require('path').join;
var minifyImage = require('./minify-image');
var minifyScript = require('./minify-javascript');
var parsePath = require('path').parse;
var parseCssUrl = require('./parse-css-url');
var extname = require('path').extname;
var ren = require('./rename-css-refs');
var ren2 = require('./rename-html-refs');


/**
  parse asset graph, minifying and renaming based on md5 hash
  @param string outputPath  absolute path to the directory minified/renamed
                            assets are written to
  @param string assetsPath  absolute path to location where assets currently
                            exist
  @param object htmlRefs    key is an absolute path to an html file, value is
                            an array of absolute filepaths referenced by the
                            html file
  @param object styleRefs   key is an absolute path to a css file, value is an
                            array of absolute filepaths referenced by the css
                            file
  @param string cdnPrefix   a url path to prepend to all assets when re-written
                            e.g., '//cdn.somedomain.com' will re-write abc.css
                            to '//cdn.somedomain.com/abc-<MD5 file hash>.css'
 */
module.exports = function optimize (outputPath, assetsPath, htmlRefs, styleRefs, cdnPrefix) {
  // maintain a list of assets that are renamed. key is original path, value is
  // renamed path
  var renamed = {};

  var absPath, font, hashed, html, i, image, j, len, len1, minified, out, parsed, path, refs, script, text, type;

  // renaming assets based on MD5 hash must be done in order because any assets
  // that depend on that renamed file will mean the reference to that asset has
  // to be updated, which will cascade through the graph! the solution is to
  // traverse through all dependencies, and rename leaf nodes first, then work 
  // backwards.  HTML -> CSS -> images, javascripts, fonts

  if (cdnPrefix == null) {
    cdnPrefix = '';
  }

  for (path in htmlRefs) {
    refs = htmlRefs[path];
    for (i = 0, len = refs.length; i < len; i++) {
      absPath = refs[i];
      // ensure the asset hasn't already been optimized
      if (!renamed[absPath]) {
        type = findType(absPath);
        if (type === 'image') {
          image = fs.readFileSync(absPath);
          minified = minifyImage(absPath, image);
          hashed = hash(minified);
          parsed = parsePath(absPath);
          out = join(outputPath, parsed.name + "-" + hashed + parsed.ext);
          fs.writeFileSync(out, minified);
          renamed[absPath] = out;
        } else if (type === 'javascript') {
          script = fs.readFileSync(absPath, 'utf8');
          minified = minifyScript(absPath, script);
          hashed = hash(minified);
          parsed = parsePath(absPath);
          out = join(outputPath, parsed.name + "-" + hashed + parsed.ext);
          fs.writeFileSync(out, minified);
          renamed[absPath] = out;
        } else if (type === 'font') {
          font = fs.readFileSync(absPath);
          hashed = hash(font);
          parsed = parsePath(absPath);
          out = join(outputPath, parsed.name + "-" + hashed + parsed.ext);
          fs.writeFileSync(out, font);
          renamed[absPath] = out;
        }
      }
    }
  }

  for (path in styleRefs) {
    refs = styleRefs[path];
    for (j = 0, len1 = refs.length; j < len1; j++) {
      absPath = refs[j];
      if (!renamed[absPath]) {
        type = findType(absPath);
        if (type === 'image') {
          image = fs.readFileSync(absPath);
          minified = minifyImage(absPath, image);
          hashed = hash(minified);
          parsed = parsePath(absPath);
          out = join(outputPath, parsed.name + "-" + hashed + parsed.ext);
          fs.writeFileSync(out, minified);
          renamed[absPath] = out;
        } else if (type === 'font') {
          font = fs.readFileSync(absPath);
          hashed = hash(font);
          parsed = parsePath(absPath);
          out = join(outputPath, parsed.name + "-" + hashed + parsed.ext);
          fs.writeFileSync(out, font);
          renamed[absPath] = out;
        }
      }
    }
  }

  // now all of the leaf nodes (images, fonts, javascripts) are processed.

  // update all css files to point at leaf node references
  for (path in styleRefs) {
    refs = styleRefs[path];
    text = fs.readFileSync(path, 'utf8');
    minified = ren(path, text, assetsPath, renamed, cdnPrefix);
    hashed = hash(minified);
    parsed = parsePath(path);
    out = join(outputPath, parsed.name + "-" + hashed + parsed.ext);
    fs.writeFileSync(out, minified, 'utf8');
    renamed[path] = out;
  }

  // update all html files to point at leaf node and css file references
  for (path in htmlRefs) {
    refs = htmlRefs[path];
    text = fs.readFileSync(path, 'utf8');
    html = ren2(path, text, assetsPath, renamed, cdnPrefix);
    console.log('updating', path);
    // update the html in-place
    fs.writeFileSync(path, html, 'utf8');
  }
};
