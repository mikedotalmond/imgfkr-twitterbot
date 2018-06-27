package imgfkr;
import js.node.Buffer;
import js.node.Http;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class BufferLoader {

  static public function load(url:String, done:Buffer->Void){
		
    var protocolEnd = url.indexOf("://") + 3;
    var hostEnd = url.indexOf("/", protocolEnd);
    var host = url.substring(protocolEnd, hostEnd);
    var path = url.substring(hostEnd);
		
    #if debug
    trace('BufferLoader.load $host$path');
    #end
		
    var options = { hostname:host, path: path, port:80,	};
		
    var buffers:Array<Buffer> = [];
    var request = Http.get(options, function(message){
      if (message.statusCode < 400){
        message.on('data', function(chunk){ buffers.push(chunk); });
        message.on('end', function(){ done(Buffer.concat(buffers)); });
      } else {
        trace('BufferLoader.load error - ' + message.statusCode);
        done(null);
      }
    });
		
    request.on('error', function(_){
      trace('BufferLoader.load error ' + _);
      done(null);
    });
  }
}