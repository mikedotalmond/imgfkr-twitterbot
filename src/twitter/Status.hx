package twitter;
import twitter.entities.TweetEntities;
import twitter.entities.TweetEntity;

/**
 * @author Mike Almond | https://github.com/mikedotalmond
 */
 typedef StatusMetadata = {
  var iso_language_code:String;
  var result_type:String; 
 }
 
typedef Status = {
  var created_at:String;
  var id:Int;
  var id_str:String;
  var text:String;
  var entities:haxe.ds.Either<TweetEntity,TweetEntities>;
  var metadata:StatusMetadata;
  var source:String;
  var user:User;
  var truncated:Bool;
  var is_quote_status:Bool;
  var favorited:Bool;
  var retweeted:Bool;
  var possibly_sensitive:Bool;
  var lang:String;
	
  @:optional var in_reply_to_screen_name:String;
  @:optional var in_reply_to_status_id:Int;
  @:optional var in_reply_to_status_id_str:String;
  @:optional var in_reply_to_user_id:Int;
  @:optional var in_reply_to_user_id_str:String;
  @:optional var geo:GeolocationData;
  @:optional var coordinates:Dynamic;
  @:optional var place:Dynamic;
  @:optional var contributors:Dynamic;
  @:optional var retweeted_status:Status;
  @:optional var quoted_status:Status;
  @:optional var retweet_count:Int;
  @:optional var favorite_count:Int;
}