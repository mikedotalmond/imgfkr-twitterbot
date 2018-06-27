package imgfkr.jpg;

import js.node.Buffer;

/**
 * typedefs for https://github.com/eugeneware/jpeg-js
 * 
 * @author Mike Almond | https://github.com/mikedotalmond
 * 
 */

@:jsRequire('jpeg-js')
extern class JpegJs {
  public static function encode(rawImageData:RawImageData, quality:Int):Buffer;
  public static function decode(bytesData:Buffer):RawImageData;
}