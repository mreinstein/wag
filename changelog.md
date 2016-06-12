# 1.1.0

handle image urls in css @media declarations. 

updated shelljs dependency


# 1.0.0

This release is essentially a re-write.

### breaking changes

Parsing javascript for references to assets has been removed. This was a
brittle solution, and couldn't detect most of the cases that might happen at
run-time when dynamically constructing asset urls.

Instead, you're encouraged to not build apps this way. Don't dynamically build
asset paths in javascript.


The programmatic API was removed. In the interest of simplification, only the 
command line invocation is supported. If people complain and really miss this,
it could be re-introduced.


Old versions of node (pre 4.x) are not supported, as some of the es6 related 
features like `string.endsWith()` are used. If people complain and really want
old support it could be re-introduced.


### new features

Font files are now supported (.woff, .woff2, .ttf, .eot) These files aren't
compressed/optimized, but they will at least be recognized and re-written based
on md5 hash of file contents, thereby enabling better cacheing.

css is now minified.

Now maintaining a changelog (this file.)


### changed features

All of the image optimization tools are embedded by default, which simplifies
the installation of wag and ensures optimizations are run more consistently.

Abandoned coffeescript in favor of vanilla javascript.


# 0.5.4

updated module dependencies


# 0.5.3

updated module dependencies
