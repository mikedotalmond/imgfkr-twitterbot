package twit;

import twitter.*;

/**
 * ...
 * Some incomplete externs for https://www.npmjs.com/package/twit
 * 
 * @author Mike Almond | https://github.com/mikedotalmond
 */


@:jsRequire('twit')
extern class Twit {
  public function new(config:TwitConfig){ }
	
	//post('statuses/update', { status: 'hello world!' }, function(err, data, response) 
  public function post(type:String, data:Dynamic, callback:ApiError->ResponseData->Dynamic->Void):Void{}
	
  public function get(type:String, data:Dynamic, callback:ApiError->ResponseData->Dynamic->Void):Void{}
	//get('search/tweets', { q: 'banana since:2011-07-11', count: 100 }, function(err, data, response) 
	
  public function stream(type:StreamType, ?parameters:Dynamic):TwitStream {}
 }