package twitter;

/**
 * @author Mike Almond | https://github.com/mikedotalmond
 */
typedef ApiError = {
  var message:String;
  var code:Int;
  var allErrors:Array<ApiError>;
  var statusCode:Int;
}