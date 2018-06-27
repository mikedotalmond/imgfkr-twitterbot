package twitter;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
extern class StreamEvent {
  var event:StreamEventType;
  var created_at:String;
  var target:User;
  var source:User;
	var target_object:haxe.ds.Either<Dynamic,Status>;/*Status*/
}