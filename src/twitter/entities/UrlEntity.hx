package twitter.entities;

/**
 * @author Mike Almond | https://github.com/mikedotalmond
 */
typedef UrlEntity = {
  @:optional var url:String;
  @:optional var expanded_url:String;
  @:optional var display_url:String;
  var indices:Array<Int>;
}
