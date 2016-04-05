wag
===

![Alt text](http://i.imgur.com/9eJTHZz.jpg "Web Asset Graph")

Web Asset Graph


### ?
wag parses a pile of HTML files, finds all references to assets (css, javascript, images, fonts) and re-writes the html in-place to point at these optimized assets.


This tool is inspired by assetgraph and assetgraph-builder.

### features
* fast
* simple API, only 500 lines of code
* renames files based on their MD5 hash so they can be cached forever
* prefixes assets with an optional CDN host
* compresses css, javascript, and images (jpg, png, svg)

### usage

[![NPM](https://nodei.co/npm/wag.png)](https://nodei.co/npm/wag/)


#### example
```sh
wag --inp /Users/mike/test-website/html \
    --out /Users/mike/test-website/public/optimized \
    --assets /Users/mike/test-website/public \
    --cdnroot //cdn.test-website.com
```

What this does:
1. Recursively find all HTML files in `test-website/html/` and subfolders
2. creates the `public/optimized/` directory and empties it
3. finds all css, images, javascripts, and font files references in the HTML files
4. minifies each file, renames them based on each file's md5 hash, and writes them to `public/optimized/`
   (e.g., `/public/images/dog.png` is re-rewritten to `/public/optimized/dog-343e32abce3968feac.png`)
5. Re-writes the URL for the asset to point at a CDN version (e.g., `/optimized/dog-343e32abce3968feac.png` is re-written to `//cdn.test-website.com/dog-343e32abce3968feac.png` )
