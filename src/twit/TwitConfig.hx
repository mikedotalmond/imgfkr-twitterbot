package twit;

/**
 * ...
 * Externs for https://www.npmjs.com/package/twit
 * 
 * @author Mike Almond | https://github.com/mikedotalmond
 */

extern typedef TwitConfig = {
  var consumer_key:String;
  var consumer_secret:String;
  var access_token:String;
  var access_token_secret:String;
  @:optional var timeout_ms:Int;
}