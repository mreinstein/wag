
# expirimental prototype to provide _extremely_ optimized production website deploys

AssetGraph = require('./index.coffee').AssetGraph
path       = require 'path'
join       = path.join

# usage
root = '/Users/mikereinstein/wwwroot/shopsavvy-web/shopsavvy.com/public'

ag = new AssetGraph root

# load all of the asset files directly
ag.loadAssets 'index.html'
#ag.loadAssets 'js/'

console.log "\nloaded #{Object.keys(ag.nodes).length} assets:"

typecount = {}

for k,v of ag.nodes
	if !typecount[v.type]
		typecount[v.type] = 0
	typecount[v.type] += 1

for type,count of typecount
	console.log '  ', type, ':', count

ag.minifyAssets()

ag.moveAssets 'static/'

out = '/Users/mikereinstein/Desktop/test'
useHashName = true
ag.writeAssetsToDisc out, useHashName

manifest = 'blech.appcache'
if manifest and manifest+'' isnt 'false'
	ag.generateAppCache out, manifest
