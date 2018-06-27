package twitter.entities;

/**
 * @author Mike Almond | https://github.com/mikedotalmond
 */
typedef MediaSize = {
  var w:Int;
  var h:Int;
  var resize:String;
}

typedef MediaSizes = {
  var small:MediaSize;
  var thumb:MediaSize;
  var medium:MediaSize;
  var large:MediaSize;
}
 
typedef MediaEntity ={
  var id:Int;	
  var id_str:String;	
  var indices:Array<Int>;	
  var media_url:String;	
  var media_url_https:String;	
  var display_url:String;	
  var expanded_url:String;	
  var type:String;	
  var sizes:MediaSizes;	
}