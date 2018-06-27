# [imgfkr](https://twitter.com/imgfkr)

A Twitter bot running on Node.js, deployed to Heroku

Though this runs as a nodejs application, the main image mangling code
(a custom version of the JPEG encoder from the Haxe format library) 
is not JS specific, and will compile to any of the Haxe targets should you want to use it elsewhere.

[@mikedotalmond](https://twitter.com/mikedotalmond)