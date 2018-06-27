package twitter.entities;

/**
 * @author Mike Almond | https://github.com/mikedotalmond
 */

typedef TweetEntity = {
  @:optional var urls:Array<UrlEntity>;
  @:optional var hashtags:Array<HashtagEntity>;
  @:optional var user_mentions:Array<UserMentionEntity>;
  @:optional var symbols:Array<Dynamic>;
  @:optional var media:Array<MediaEntity>;
}