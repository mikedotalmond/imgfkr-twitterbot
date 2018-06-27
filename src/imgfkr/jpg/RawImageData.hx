package imgfkr.jpg;

import js.node.Buffer;

/**
 * @author Mike Almond | https://github.com/mikedotalmond
 */
typedef RawImageData = {
	var width:Int;
	var height:Int;
	var data:Buffer; // RGBA pixel data
}