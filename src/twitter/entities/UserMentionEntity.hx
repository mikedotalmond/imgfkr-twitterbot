package twitter.entities;

/**
 * @author Mike Almond | https://github.com/mikedotalmond
 */
typedef UserMentionEntity = {
  var screen_name:String;
  var name:String;
  var id:Int;
  var id_Str:String;
  var indices:Array<Int>;
}