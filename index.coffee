# inspired by assetgraph
#	https://github.com/One-com/assetgraph
#
# uses these libraries for html,css,js parsing/minification
# 	https://github.com/fb55/htmlparser2
#	https://github.com/visionmedia/css
#	https://github.com/mishoo/UglifyJS2
#
# might be interesting points for further research
# 	https://github.com/kangax/html-minifier
# 	https://github.com/GoalSmashers/enhance-css

htmlparser = require 'htmlparser2'
css        = require 'css'
UglifyJS   = require 'uglify-js'
path       = require 'path'
join       = path.join
fs         = require 'fs'
_          = require 'underscore'
crypto     = require 'crypto'

# NOTE: renaming assets based on MD5 hash must be done in order because any 
#		assets that depend on that renamed file will mean the 
#		reference to that asset has to be updated, which will cascade through
#		the graph! the solution is to traverse through all dependencies, and
#		rename leaf nodes first, then work backwards.

# TODO: this might come in handy when supporting templated .html files
###
# parse html string as an underscore.js template, returning the list of 
# string locations for each dynamic section
parseHtmlUnderscoreTemplate = (html) ->
	idx = 0
	open = false
	dynamic = []
	while idx < html.length and idx >= 0
		if open
			q = '%>'
		else
			q = '<%'
		pos = html.indexOf q, idx
		if pos > -1
			if open
				dynamic.push { start: idx-2, end: pos+2 }
			open = !open
			idx = pos + 2
		else
			idx = pos
	# if any tags are left open, template has problemzz
	if open and dynamic.length > 0
		throw new Error('Invalid Template')
	dynamic

# given a DOM node, a set of changes, and a list of dynamic sections, product 
# an Html string that applies all changes and inserts the dynamic parts in
updateHtmlUnderscoreTemplate = (node, deltas, dynamic) ->
	# TODO
	# NOTE: templates/product.html is a great test example because it's large, 
	#		and has all 3 underscore tag types used:  <%   <%=   <%-
	''
###

requireJS = null

class Asset
	constructor: (@root, @filepath, @ag=null) ->	
		absPath = join @root, @filepath
		@type     = @_determineType absPath
		@to       = []  # Assets this references 
		@from     = []  # Assets referencing this
		@minified = null
		@hash     = null
		@pending  = [] # unresolved references to other nodes
		@obj      = @_buildObject @filepath, @type

	hashValue: ->
		if @hash then return

		# determine if any of the dependencies aren't named by hash
		for node in @to
			if !node.asset.hash then node.asset.hashValue()

		md5sum = crypto.createHash 'md5'

		if @type is 'javascript'
			md5sum.update @obj.print_to_string({ beautify: false })
			@hash = md5sum.digest 'hex'
		else if @type is 'style'
			if @minified
				md5sum.update @minified
			else
				md5sum.update css.stringify(@obj)
			@hash = md5sum.digest 'hex'
		else if @type is 'html'
			#
			# TODO remove after html templates are supported
			if typeof(@obj) is 'string'
				md5sum.update @obj
				@hash = md5sum.digest 'hex'
			else
				#
				for d in @obj
					md5sum.update htmlparser.DomUtils.getOuterHTML(d)
				@hash = md5sum.digest 'hex'
		else if @type is 'image'
			md5sum.update @obj
			@hash = md5sum.digest 'hex'

		newPath = path.dirname(@filepath) + '/' + @hash + path.extname(@filepath)
		@move newPath


	minify: ->
		if @minified then return

		# determine if any of the dependencies aren't minified
		for node in @to
			if !node.asset.minified then node.asset.minify()

		console.log 'minifying', @filepath

		if @type is 'javascript'
			#before = fs.readFileSync join(@root, @filepath), 'utf8'
			@obj.figure_out_scope()
			compressor = UglifyJS.Compressor()
			@obj.transform compressor
			@minified = @obj.print_to_string { beautify: false }
			#console.log '    before', before.length, 'after', @minified.length
		else if @type is 'style'
			#before = fs.readFileSync join(@root, @filepath), 'utf8'
			@minified = css.stringify @obj, { compress: true }
			#console.log '    before', before.length, 'after', ast.length
		else if @type is 'html'
			#
			# TODO remove after html templates are supported
			if typeof(@obj) is 'string'
				@minified = @obj
				return
			#
			@minified = ''
			for d in @obj
				@minified += htmlparser.DomUtils.getOuterHTML(d)
		else if @type is 'image'
			@minfied = @obj
			# TODO interesting image modules: jpegtran, optipng, pngcrush, 
			# pngquant, assetgraph-sprite, histogram


	move: (destination) ->
		oldpath = JSON.parse(JSON.stringify(@filepath))
		ext = path.extname destination

		# find all references to the asset and move
		for f in @from
			# f is pointing at the asset to move
			if f.asset.type is 'style'
				f.node.value = "url(#{destination})"
				#f.node.attribs.href = destination
			else if f.asset.type is 'javascript'
				if f.inRequireJS
					# this asset reference is in a RequireJS block
					if f.node.value.indexOf('text!') >= 0
						# this is a RequireJS plugin include
						f.node.value = "text!#{destination}"
					else
						# omit the file extension for javascript references in RequireJS blocks
						f.node.value = join(path.dirname(destination), path.basename(destination, ext))
			else if f.asset.type is 'html'
				# the asset that requires this one is an html document
				if (@type is 'javascript') and f.inRequireJS
					f.node.attribs['data-main'] = join path.dirname(destination), path.basename(destination, '.js')
				else if @type is 'style'
					f.node.attribs.href = destination
				else
					f.node.attribs.src = destination
			else if f.asset.type is 'image'
				if @type is 'style'
					#url = Asset.parseStyleSheetUrl(f.node.value)
					#newUrl = join('/', destination, path.basename(url))
					# TODO: this needs to be smarter so it doesn't clobber other values (e.g., no-repeat, etc)
					f.node.value = "url(#{destination})"
			else
				console.log 'TODO: support type', f.asset.type, f.node, 'host type', @type

		# change this file's path
		@filepath = destination
		if @ag
			@ag.addAsset this
			delete @ag.nodes[oldpath]

	writeToDisc: (destination) ->
		if @minified
			fs.writeFileSync join(destination, @filepath), @minified 
		else if @type is 'html'
			#
			# TODO remove after html templates are supported
			if typeof(@obj) is 'string'
				fs.writeFileSync join(destination, @filepath), @obj
				return
			#
			out = ''
			for d in @obj
				out += htmlparser.DomUtils.getOuterHTML(d)
			fs.writeFileSync join(destination, @filepath), out
		else if @type is 'javascript'
			fs.writeFileSync join(destination, @filepath), @obj.print_to_string({ beautify: true })
		else if @type is 'style'
			fs.writeFileSync join(destination, @filepath), css.stringify(@obj, { compress: false })
		else
			fs.writeFileSync join(destination, @filepath), @obj

	_buildObject: ->
		filepath = @filepath
		type = @type
		absPath = join @root, filepath
		if !fs.existsSync absPath
			console.log "error:file #{absPath} doesn't exist."
			return null

		file = fs.readFileSync absPath, 'utf8'
		if type is 'html'
			#
			# TODO remove after html templates are supported
			if file.indexOf('<%') >= 0
				console.log 'warning: template directives found. Not parsing', filepath
				return file
			#
			d = null
			handler = new htmlparser.DomHandler (er, dom) =>
				if er
					throw new Error(er)
				else
					# parsing done, analyze the DOM
					for d in dom
						@_parseDOMNode d
				d = dom

			parser = new htmlparser.Parser handler
			parser.parseComplete file
			return d
		else if type is 'style'
			return @_parseStyleSheet filepath, file
		else if type is 'javascript'
			return @_parseJavascript filepath, file
		else if type is 'image'
			return fs.readFileSync(absPath, 'utf8')
		null

	resolveDependencies: ->
		for p in @pending
			asset = @ag.nodes[p.filepath] or new Asset(@root, p.filepath, @ag)
			# only add the asset if it's object could be created (javascript ast, html dom, css style, etc)
			if asset.obj
				asset.from.push { asset: this, node: p.node, inRequireJS: p.inRequireJS }
				@to.push { asset: asset, node: p.node, inRequireJS: p.inRequireJS }
				@ag.addAsset asset
				asset.resolveDependencies()
		@pending = []


	_determineType: (filepath) ->
		ext = path.extname(filepath or '').split '.'
		ext = ext[ext.length - 1]
		if ext is 'html' or ext is 'htm'
			type = 'html'
		else if ext is 'js'
			type = 'javascript'
		else if ext is 'css'
			type = 'style'
		else if ext is 'png' or ext is 'gif' or ext is 'jpg' or ext is 'jpeg' or ext is 'ico' or ext is 'svg'
			type = 'image'
		type

	_foundAssetReference: (filepath, node, inRequireJS=false) ->
		# if there's no asset graph, don't bother linking up the asset
		if !@ag then return

		if !@ag.nodes[filepath]
			console.log 'loading ', filepath

		@pending.push {
			filepath    : filepath
			node        : node
			inRequireJS : inRequireJS
		}

	# recursively parse a DOM node's structure
	_parseDOMNode: (node) ->
		# html relation types:
		# 	type: tag    name: link
		# 	type: script name: script
		# 	type: tag    name: a
		# 	type: tag    name: style
		#   type: tag    name: img

		newAssetPath = null
		inRequireJS = false

		if node.type is 'tag' and (node.name is 'style' or node.name is 'link')
			newAssetPath = node.attribs.href
		else if node.type is 'script' and node.name is 'script'
			# if the src attribute isn't set, this must be an inline script with a body
			if !node.attribs or !node.attribs.src
				# TODO: parse node.children to get the actual javascript code?
			else
				if node.attribs['data-main']
					console.log 'found requirejs entry point', node.attribs.src, 'main', node.attribs['data-main']
					# found a requireJS config and we're trying to locate it, so parse it
					newAssetPath = "#{node.attribs['data-main']}.js"
					inRequireJS = true
				else
					console.log 'external script found', node.attribs.src
					newAssetPath = node.attribs.src
		else if node.type is 'tag' and node.name is 'img' and node.attribs.src and node.attribs.src isnt 'src'
			console.log "found image reference '#{node.attribs.src}'"
			newAssetPath = node.attribs.src

		if newAssetPath then @_foundAssetReference(newAssetPath, node, inRequireJS)

		# if this DOM node has any children, parse them for asset references
		if node.children
			for n in node.children
				@_parseDOMNode n

	_parseJavascript: (filepath, file) ->
		toplevel = null
		opts = {}
		###
		opts =
			filename : filepath
			toplevel : toplevel
		###
		toplevel = UglifyJS.parse file, opts

		# recursively parse an UglifyJS AST node
		walker = new UglifyJS.TreeWalker (node) =>
			if node instanceof UglifyJS.AST_Call and node.start.type is 'name' and node.start.value is 'require'
				# has the require.config 
				if node.expression.end.value is 'config'
					requireJS = @_parseRequireJSConfig node
				else if node.args.length is 2
					# has the script paths to require
					@_parseRequireStatement node
				return true # don't descend into RequireJS function calls

			if node instanceof UglifyJS.AST_Call and node.start.type is 'name' and node.start.value is 'define'
				@_parseRequireStatement node
				return true # don't descend into RequireJS function calls
			false

		toplevel.walk walker
		#console.log toplevel.print_to_string({ beautify: true })
		toplevel

	# parse a RequireJS configuration block and return it as JSON
	_parseRequireJSConfig: (node) ->
		cfg = {}
		for k in node.args[0].properties
			if k.key is 'baseUrl'
				cfg.baseUrl = k.value.value
			if k.key is 'paths'
				cfg.paths = {}
				for j in k.value.properties
					cfg.paths[j.key] = j.value.value
		cfg

	# parse the required scripts out of the require/define statement
	_parseRequireStatement: (node) ->
		if !node.args[0].elements
			return

		p = if requireJS then requireJS.baseUrl else ''
			
		# e.g., error: could not find asset text!/templates/partials/email-confirmation-banner.html
		for scriptpath in node.args[0].elements
			newAssetPath = null
			if scriptpath.value
				# some requirejs includes are html templates. e.g., text!/templates/signup.html
				if scriptpath.value.indexOf('text!') is 0
					newAssetPath = join p, scriptpath.value.substring(5)
				else if fs.existsSync join(@root, p, "#{scriptpath.value}.js")
					newAssetPath = join(p, "#{scriptpath.value}.js")
				else if scriptpath.value is 'exports' or (requireJS and scriptpath.value is 'require')
					# ignore exports for scriptpath.value and references to requireJS
				else if requireJS
					found = false
					for alias, pa of requireJS.paths
						if alias is scriptpath.value
							found = true
							newAssetPath = join p, "#{pa}.js"
					if !found
						console.log "error 1: could not find asset #{scriptpath.value}"
				else
					console.log "error: could not find asset #{scriptpath.value}"

			inRequireJS = true
			if newAssetPath then @_foundAssetReference(newAssetPath, scriptpath, inRequireJS)


	_parseStyleSheet: (filepath, file) ->
		c = css.parse file 
		for rule in c.stylesheet.rules
			if rule.type is 'rule'
				for dec in rule.declarations
					if dec.type is 'declaration' and (dec.property is 'background-image' or dec.property is 'background')
						url = Asset.parseStyleSheetUrl dec.value
						if url
							if url.indexOf('/') is 0
								# image url is absolute path
								fullpath = url
							else
								# image url is relative path to the css file including it
								fullpath = join(path.dirname(filepath), url)
							@_foundAssetReference fullpath, dec
		c

	@parseStyleSheetUrl: (declaration) ->
		b = declaration.match /url\((.+?)\)/gi
		if b
			pos = declaration.indexOf 'url('
			if pos >= 0
				# found an image url
				pos2 = declaration.indexOf ')', pos+4
				return declaration.substring(pos+4, pos2).trim()
		''


class AssetGraph 
	constructor: (@root) ->
		@nodes     = {}
		@indexNode = null

	addCacheManifest: ->
		# TODO

	loadAssets: (filepath) ->
		absPath = join @root, filepath
		if fs.statSync(absPath).isDirectory() 
			files = fs.readdirSync absPath
			for f in files
				@loadAssets join(filepath, f)
		else
			@_load filepath

	minifyAssets: ->
		# TODO: detect graph cycles to prevent infinite loop
		for p, a of @nodes
			a.minified = false

		for p, a of @nodes
			a.minify()

	moveAssets: (destination) ->
		for p,a of @nodes
			if p isnt 'index.html'
				newpath = join '/', destination, '/', path.basename(p)
				a.move newpath

	hashAssets: ->
		for p, a of @nodes
			a.hash = null

		for p, a of @nodes
			if p isnt 'index.html'
				a.hashValue()

	writeAssetsToDisc: (destination) ->
		for p, a of @nodes
			a.writeToDisc destination

	_load: (filepath) ->
		absPath = join @root, filepath
		if !fs.existsSync absPath
			console.log "file #{absPath} not found"
			return

		a = new Asset @root, filepath, this

		# the first loaded asset is considered the index node
		@indexNode or= a
		@addAsset a
		a.resolveDependencies()

	addAsset: (asset) ->
		# only add graph assets that are new and have type set
		if !@nodes[asset.filepath] and asset.type?
			#console.log 'adding!', asset.filepath
			@nodes[asset.filepath] = asset


module.exports.AssetGraph = AssetGraph
module.exports.Asset = Asset
