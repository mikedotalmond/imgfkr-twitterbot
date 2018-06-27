package twitter;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
@:enum
abstract StreamType(String) {
  var StatusesFilter = 'statuses/filter';
  var StatusesSample = 'statuses/sample';
  var User = 'user';
  var Site = 'site';
}