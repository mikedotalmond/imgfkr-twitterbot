package twitter;

/**
 * @author Mike Almond | https://github.com/mikedotalmond
 */
typedef ResponseData = {
  @:optional var statuses:Array<Status>;
  @:optional var users:Array<User>;
  @:optional var media_id_string:String;
  @:optional var search_metadata:Dynamic;
}
