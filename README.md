wag
===

Web AssetGraph Library

### ?
wag is a tool that parses a connected pile of related web files (html, css, javascript) and builds a graph of assets, modeling each file and the dependencies between them.


The most obvious usage (to me) is building highly optimized website deploys by traversing the graph and applying operations (minification, renaming based on hashing, app cache generation, etc.) 

This could become part of a grunt workflow, or you could build your own custom tools. It's up to you.


### Features
* partially supports RequireJS syntax
* very fast
* simple API
* über small (< 500 lines of code)


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

console.log "\nloaded #{Object.keys(ag.nodes).length} assets:"

ag.moveAssets 'static/'
 
ag.minifyAssets()

ag.hashAssets()  # rename each file (except for index.html) to an md5 hash of it's contents

out = '/Users/mike/Desktop/deployfolder'
ag.writeAssetsToDisc out
```


