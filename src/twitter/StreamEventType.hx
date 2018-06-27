package twitter;

/**
 * ...
 * https://github.com/ttezel/twit
 * 
 * @author Mike Almond | https://github.com/mikedotalmond
 */
@:enum
abstract StreamEventType(String) {
  var Error = 'error';
  var Message = 'message'; // catch all
  var Tweet = 'tweet';
  var Delete = 'delete';
  var Limit = 'limit';
  var ScrubGeo = 'scrub_geo';
  var Disconnect = 'disconnect';
  var Connect = 'connect';
  var Connected = 'connected';
  var Reconnect = 'reconnect';
  var Warning = 'warning';
  var StatusWithheld = 'status_withheld';
  var UserWithheld = 'user_withheld';
  var Friends = 'friends';
  var DirectMessage = 'direct_message';
	
  var UserEvent = 'user_event';
  var Blocked = 'blocked';
  var Unblocked = 'unblocked';
  var Favorite = 'favorite';
  var Unfavorite = 'unfavorite';
  var Follow = 'follow';
  var Unfollow = 'unfollow';
  var UserUpdate = 'user_update';
  var ListCreated = 'list_created';
  var ListDestroyed = 'list_destroyed';
  var ListUpdated = 'list_updated';
  var ListMemberAdded = 'list_member_added';
  var ListMemberRemoved = 'list_member_removed';
  var ListUserSubscribed = 'list_user_subscribed';
  var ListUserUnsubscribed = 'list_user_unsubscribed';
  var QuotedTweet = 'quoted_tweet';
  var RetweetedRetweet = 'retweeted_retweet';
  var FavoritedRetweet = 'favorited_retweet';
  var Unknown = 'unknown_user_event';
}