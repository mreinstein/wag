
# expirimental prototype to provide _extremely_ optimized production website deploys

AssetGraph = require('./index.coffee').AssetGraph
path       = require 'path'
join       = path.join
shell      = require 'shelljs'

# usage
root = '/Users/mikereinstein/wwwroot/shopsavvy-web/shopsavvy.com'

ag = new AssetGraph root

# load all of the asset files directly
ag.loadAssets 'index.html'
ag.loadAssets 'js/'

console.log "\nloaded #{Object.keys(ag.nodes).length} assets:"

typecount = {}

for k,v of ag.nodes
	if !typecount[v.type]
		typecount[v.type] = 0
	typecount[v.type] += 1

for type,count of typecount
	console.log '  ', type, ':', count

ag.moveAssets 'static/'

#ag.minifyAssets()

ag.hashAssets()

out = '/Users/mikereinstein/Desktop/test'
ag.writeAssetsToDisc out

#shell.cp '-R', join(root,'components'), '/Users/mikereinstein/Desktop/test'

