wag
===

![Alt text](http://i.imgur.com/9eJTHZz.jpg "The best meat's in the rump…")

Web AssetGraph Library


### ?
wag is a tool that parses a connected pile of related web files (html, css, javascript) and builds a graph of assets, modeling each file and the dependencies between them.


The most obvious usage (to me) is building highly optimized website deploys by traversing the graph and applying operations (minification, renaming based on hashing, app cache generation, etc.) 

This could become part of a grunt workflow, or you could build your own custom tools. It's up to you.

This tool is inspired by assetgraph and assetgraph-builder.

### Features
* very fast
* simple API*
* only 500 lines of code
* supports basic RequireJS and Browserify syntax
* provides command line tool and programmatic API
* can rename files based on their MD5 hash
* can prefix assets with a CDN host
* can compress css, javascript, and images (jpg, png, svg)

### Usage

[![NPM](https://nodei.co/npm/wag.png)](https://nodei.co/npm/wag/)


#### Command Line Example
```sh
cd projectdir
wag --inp public/ --out deploy/ --cdnroot mycdn.cloudfront.net --hash --minify'
```

What this does:

1. Traverse assets in a `public/` directory, writing them out to `deploy/`.
2. Minifies each file.
3. Renames the assets to the md5 of the their contents. (e.g., `/img/dog.png` is re-rewritten to `/static/343e32abce3968feac.png`)
4. re-writes the URL for the asset to point at a CDN version (e.g., `/static/343e32abce3968feac.png` is re-written to `//mycdn.cloudfront.net/static/343e32abce3968feac.png` )

#### Programmatic Example

```coffeescript
AssetGraph = require('wag').AssetGraph
root = '/Users/mike/wwwroot/mywebsite'
ag = new AssetGraph root

# load all of the asset files directly
ag.loadAssets 'index.html'
ag.loadAssets 'js/'

console.log "\nloaded #{Object.keys(ag.nodes).length} assets"


ag.minifyAssets()

ag.moveAssets 'static/'

out = '/Users/mike/Desktop/deployfolder'

# rename each file (except for index.html) to an md5 hash of it's contents
useHashName = true 
ag.writeAssetsToDisc out, useHashName
```


