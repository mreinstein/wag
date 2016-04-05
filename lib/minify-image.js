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
  var ext, minified, outfile, response, tmpfile;
  minified = image;
  ext = path.extname(filepath);
  if (ext === '.jpg' || ext === '.jpeg') {
    console.log('optimizing', filepath, 'via jpegtran');
    tmpfile = join(os.tmpdir(), 'wag12345');
    outfile = join(os.tmpdir(), 'wag12345.out');
    fs.writeFileSync(tmpfile, image);
    response = shell.exec("./node_modules/jpegtran-bin/cli.js -copy none -optimize -perfect -progressive -outfile " + outfile + " " + tmpfile, {
      silent: true
    });
    if (response.code !== 0) {
      console.log('failed to optimize', filepath, response.output);
    } else {
      minified = fs.readFileSync(outfile);
    }
    shell.rm(tmpfile);
    shell.rm(outfile);
  } else if (ext === '.png') {
    tmpfile = join(os.tmpdir(), 'wag12345');
    fs.writeFileSync(tmpfile, image);
    console.log('optimizing', filepath, 'via pngcrush');
    response = shell.exec("./node_modules/pngcrush-bin/cli.js -reduce -brute -ow " + tmpfile, {
      silent: true
    });
    if (response.code !== 0) {
      console.log('failed to optimize', filepath, response.output);
    }
    console.log('optimizing', filepath, 'via optipng');
    response = shell.exec("./node_modules/optipng-bin/cli.js " + tmpfile, {
      silent: true
    });
    if (response.code !== 0) {
      console.log('failed to optimize', filepath, response.output);
    }
    console.log('optimizing', filepath, 'via pngquant');
    response = shell.exec("./node_modules/pngquant-bin/cli.js --force " + tmpfile, {
      silent: true
    });
    if (response.code !== 0) {
      console.log('failed to optimize', filepath, response.output);
    } else {
      shell.mv('-f', tmpfile + "-fs8.png", tmpfile);
    }
    minified = fs.readFileSync(tmpfile);
    shell.rm(tmpfile);
  } else if (ext === '.svg') {
    console.log('optimizing', filepath, 'via svgo');
    tmpfile = join(os.tmpdir(), 'wag12345');
    fs.writeFileSync(tmpfile, image);
    response = shell.exec("./node_modules/svgo/bin/svgo --input " + tmpfile + " --output -", {
      silent: true
    });
    if (response.code !== 0) {
      console.log('failed to optimize', filepath, response.output);
    } else {
      minified = response.output;
    }
  }
  return minified;
};
