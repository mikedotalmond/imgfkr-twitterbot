package twit;
import twitter.*;
/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
extern class TwitStream {
	
  @:overload(function(type:StreamEventType, handler:Status->Void):Void {})
  public function on(type:StreamEventType, handler:StreamEvent->Void):Void;
	
  public function start():Void { }
  public function stop():Void { }
}