package twitter;
import twitter.entities.TweetEntities;

/**
 * @author Mike Almond | https://github.com/mikedotalmond
 */
typedef User = {
  var id:Int;
  var id_str:String;
  var name:String;
  var screen_name:String;
  var location:String;
  var description:String;
  @:optional var url:String;
  var entities:TweetEntities;
  var protected:Bool;
  var followers_count:Int;
  var friends_count:Int;
  var listed_count:Int;
  var created_at:String;
  var favorites_count:Int;
  var utc_offset:Int;
  @:optional var timezone:String;
  var geo_enabled:Bool;
  var verified:Bool;
  var statuses_count:Int;
  var lang:String;
  var contributors_enabled:Bool;
  var is_translator:Bool;
  var is_translatoion_enabled:Bool;
  var profile_background_color:String;
  var profile_background_image_url:String;
  var profile_background_image_url_https:String;
  var profile_background_tile:Bool;
  var profile_image_url:String;
  var profile_image_url_https:String;
  var profile_link_color:String;
  var profile_sidebar_border_color:String;
  var profile_sidebar_fill_color:String;
  var profile_text_color:String;
	
  var profile_use_background_image:Bool;
  var has_extended_profile:Bool;
  var default_profile:Bool;
  var default_profile_image:Bool;
  var following:String;
  var following_request_sent:Bool;
  var notifications:Bool;
  @:optional var suspended:Bool;
  @:optional var needs_phone_verification:Bool;
}

/*
[ 'id',
  'id_str',
  'name',
  'screen_name',
  'location',
  'profile_location',
  'description',
  'url',
  'entities',
  'protected',
  'followers_count',
  'friends_count',
  'listed_count',
  'created_at',
  'favourites_count',
  'utc_offset',
  'time_zone',
  'geo_enabled',
  'verified',
  'statuses_count',
  'lang',
  'status',
  'contributors_enabled',
  'is_translator',
  'is_translation_enabled',
  'profile_background_color',
  'profile_background_image_url',
  'profile_background_image_url_https',
  'profile_background_tile',
  'profile_image_url',
  'profile_image_url_https',
  'profile_link_color',
  'profile_sidebar_border_color',
  'profile_sidebar_fill_color',
  'profile_text_color',
  'profile_use_background_image',
  'has_extended_profile',
  'default_profile',
  'default_profile_image',
  'following',
  'follow_request_sent',
  'notifications',
  'suspended',
  'needs_phone_verification' ]
*/