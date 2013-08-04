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
* über small (~ 600 lines of code)
* supports basic RequireJS and Browserify syntax
* can generate HTML5 appcache manifests
* can rename files based on their MD5 hash
* can compress css, javascript, and images (jpg, png, svg)

### Usage

```
npm install wag
```


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

# generates /Users/mike/Desktop/deployfolder/awesome.appcache
ag.generateAppCache out, 'awesome.appcache'

# generates /Users/mike/Desktop/deployfolder/manifest.appcache
#ag.generateAppCache out, true

# note: if the appcache file already exists, it will have the 
# new entries from the built assetgraph added to it, and an 
# updated timestamp will be set in the file
```


