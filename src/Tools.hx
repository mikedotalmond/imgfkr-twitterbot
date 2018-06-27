package;

import haxe.Json;
import js.node.Fs;
import twitter.Status;
import twitter.entities.MediaEntity;
import twitter.entities.TweetEntity;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
class Tools {
	
	/**
	 * 
	 */
  public static inline function now():Float return Date.now().getTime();
	
	
	/**
	 * 
	 * @param	s
	 * @return
	 */
  public static function isOriginal(s:Status):Bool {
    return s.in_reply_to_screen_name==null && s.retweeted_status == null && s.quoted_status == null;
  }
	
	
	/**
	 * 
	 * @param	status
	 * @param	requireOriginal
	 * @param	maxHashtags
	 * @param	maxUrls
	 * @param	minMessageLength
	 */
  public static function filterStatus(status:Status, requireOriginal:Bool,  maxHashtags:Int, maxUrls:Int, ?minMessageLength:Int=0) {
		
    if (requireOriginal) {
      if (!isOriginal(status)) return false;
    }
		
    if (status.user.verified) return false; // only want 'normal' people
		
    var entities = getEntities(status);

    if (entities.hashtags != null && entities.hashtags.length > maxHashtags) return false;
    if (entities.urls != null && entities.urls.length > maxUrls) return false;
		
    if (minMessageLength > 0){			
      var nonEntityText = stripEntitiesText(status);
      if (nonEntityText.length < minMessageLength) return false;		
    }
		
    return true;
  }
	
	
	
	/**
	 * Gets a Status' media entities. Looks to the origin tweet data if Status is a retweet or quoted status
	 * @param	s
	 * @return
	 */
  public static function getEntities(s:Status):TweetEntity {
		
    var entities:TweetEntity;
    var isRetweet = s.retweeted_status != null;
    var isQuoted = s.quoted_status != null;
		
    if (isRetweet) entities = cast s.retweeted_status.entities;
    else if (isQuoted) entities = cast s.quoted_status.entities;
    else entities = cast s.entities;
		
    return entities;
  }
	
	
	/**
	 * 
	 * @param	s
	 * @return
	 */
  inline public static function getStatusPhotos(s:Status):Array<MediaEntity> {
    return getPhotos(getEntities(s).media);
  }
	
	
	
	/**
	 * Get all photo entities.
	 * @param	media
	 * @return
	 */
  public static function getPhotos(media:Array<MediaEntity>):Array<MediaEntity> {		
		
    if (media != null &&  media.length > 0){
      return media.filter(function(m) return m.type == 'photo');
    }
		
    return null;
  }
	
	
	
	/**
	 * randomly pick from an input string to create output, up to maxLength.
	 * @param	status
	 * @param	maxLength
	 * @param	fillChance
	 */
  public static function scrambleStatusText(status:Status, maxLength:Int=140, fillChance:Float=1/3){
    var txt = stripEntitiesText(status);
    return scrambleText(txt, maxLength, fillChance);
  }
	
	
	
	/**
	 * 
	 * @param	txt
	 * @param	maxLength
	 * @param	fillChance
	 * @return
	 */
  static function scrambleText(txt:String, maxLength:Int=140, fillChance:Float=.5):String{
		
    if (txt.length < 1) return '';
		
    txt = StringTools.htmlUnescape(txt);
    txt = untyped unescape(txt);
		
    var n = txt.length;
    var counter = 0;
    var out = '';
		
    maxLength = Std.int(Math.min(txt.length * 2, maxLength));
		
    while (out.length < maxLength-1){
			
      var i = Math.random() < fillChance ? Std.int(Math.random() * n) : counter;
      out = out + txt.charAt(i);
			
      counter = (counter + 1) % n;
    }
		
    return ' ' + StringTools.trim(out);
  }	
	
	
	
	/**
	 * 
	 * @param	status
	 * @return
	 */
  public static function stripEntitiesText(status:Status):String {
    var txt = status.text;
    var out = '';
		
    var e:TweetEntity = cast status.entities;
		
    var indicesParis:Array<Array<Int>> = [];
    if (e.hashtags != null && e.hashtags.length > 0){
      for (i in 0...e.hashtags.length) indicesParis.push(e.hashtags[i].indices);
    }
    if (e.media != null && e.media.length > 0){
      for (i in 0...e.media.length) indicesParis.push(e.media[i].indices);
    }
    if (e.urls != null && e.urls.length > 0){
      for (i in 0...e.urls.length) indicesParis.push(e.urls[i].indices);
    }
    if (e.user_mentions != null && e.user_mentions.length > 0){
      for (i in 0...e.user_mentions.length) indicesParis.push(e.user_mentions[i].indices);
    }
		
    indicesParis.sort(function(a:Array<Int>,b:Array<Int>){
      return (a[0] > b[0]) ? 1 : -1;
    });
		
    var offset = 0;
    for (i in 0...indicesParis.length){
      var start = indicesParis[i][0];
      var end = indicesParis[i][1];
			
      if (offset < start){
        out += txt.substring(offset, start);
      }
			
      offset = end;
    }
		
    out = StringTools.trim(out);
		
    return out;
  }
	
	
	
	
	/**
	 *  take a twitter time string (eg "Wed Sep 05 00:37:15 +0000 2012") and use native js Date to convert to a Date
	 * @param	datetime
	 * @return
	 */
  public static function timeFromString(datetime:String):Float {
    return untyped __js__('new Date(datetime).getTime()');
  }
	
	
	/**
	 * save tweet to filesystem
	 * @param	s
	 */
  public static function saveTweet(s:Status){
    var time = timeFromString(s.created_at);
    Fs.writeFileSync('tweet_${time}.json', Json.stringify(s), {encoding:'utf-8'});
  }
}