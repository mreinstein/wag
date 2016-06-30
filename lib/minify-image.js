var fs    = require('fs');
var os    = require('os');
var path  = require('path');
var join  = path.join;
var shell = require('shelljs');


/*
  write an optimized image to a temp directory. shells out to external image
  optimization tools that are installed.

  @param string filepath relative path of file
  @param buffer image
  @return buffer minified image file contents
*/
module.exports = minifyImage = function(filepath, image) {
  var cmd, ext, minified, outfile, response, tmpfile;
  minified = image;
  ext = path.extname(filepath);
  tmpfile = join(os.tmpdir(), 'wag12345');

  if (ext === '.jpg' || ext === '.jpeg') {
    outfile = join(os.tmpdir(), 'wag12345.out');
    fs.writeFileSync(tmpfile, image);
    cmd = __dirname + "/../node_modules/jpegtran-bin/cli.js -copy none -optimize -perfect -progressive -outfile " + outfile + " " + tmpfile;
    response = shell.exec(cmd,  { silent: true });
    if (response.code !== 0) {
      console.log('failed to optimize', filepath, response.stdout);
    } else {
      minified = fs.readFileSync(outfile);
    }
  } else if (ext === '.png') {
    fs.writeFileSync(tmpfile, image);
    cmd = __dirname + "/../node_modules/pngcrush-bin/cli.js -reduce -brute -ow " + tmpfile;
    response = shell.exec(cmd, { silent: true });
    if (response.code !== 0) {
      console.log('failed to optimize', filepath, response.stdout);
    }

    cmd = __dirname + "/../node_modules/optipng-bin/cli.js " + tmpfile;
    response = shell.exec(cmd, { silent: true });
    if (response.code !== 0) {
      console.log('failed to optimize', filepath, response.stdout);
    }

    cmd = __dirname + "/../node_modules/pngquant-bin/cli.js --force " + tmpfile;
    response = shell.exec(cmd, { silent: true });
    if (response.code !== 0) {
      console.log('failed to optimize', filepath, response.stdout);
    } else {
      shell.mv('-f', tmpfile + "-fs8.png", tmpfile);
    }
    minified = fs.readFileSync(tmpfile);
  } else if (ext === '.svg') {
    fs.writeFileSync(tmpfile, image);
    cmd = __dirname + "/../node_modules/svgo/bin/svgo --input " + tmpfile + " --output -";
    response = shell.exec(cmd, { silent: true });
    if (response.code !== 0) {
      console.log('failed to optimize', filepath, response.stdout);
    } else {
      minified = response.stdout;
    }
  }
  return minified;
};
