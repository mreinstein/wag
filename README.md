wag
===

Website AssetGraph Library

### ?
wag is a tool that parses a connected pile of related web files (html, css, javascript) and builds a graph of assets, modeling each file and the dependencies between them.


The most obvious usage (to me) is building highly optimized website deploys by traversing the graph and applying operations (minification, renaming based on hashing, app cache generation, etc.) 

This could become part of a grunt workflow, or you could build your own custom tools. It's up to you.


### Features
* partially supports RequireJS
* very fast
* simple API
* über small (500 lines of code)




