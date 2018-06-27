package;

/**
 * 	imgfkr
 *  
 * 	A twitter bot running on nodejs, deployed to heroku
 * 	
 *  Though this runs as a nodejs application, the main image mangling code
 *  (a custom version of the JPEG encoder from the Haxe format library) 
 *  is not JS specific, and will compile to any of the Haxe targets should you want to use it elsewhere.
 *  
 *  See imgfkr.jpg.CustomData and imgfkr.jpg.CustomWriter for more
 *  
 *  @author Mike Almond | https://github.com/mikedotalmond
 */

import haxe.io.*;
import haxe.Timer;
import haxe.crypto.Base64;

import js.Node.process;
import js.node.Buffer;

import twit.*;
import twitter.*;
import twitter.entities.*;

import imgfkr.*;
import imgfkr.jpg.*;
import imgfkr.jpg.CustomData.RGB;


class Main {

  static function main() new Main();

  public static var AppConfig(default, never):AppConfig = CompileTime.parseJsonFile('../config/app.json');
  static var TwitterConfig(default, never):TwitConfig = CompileTime.parseJsonFile('../config/twitter-auth.json');

  static var AccountName(default, never):String = AppConfig.name;

  static var MAX_TWEET_QUEUE_SIZE = AppConfig.tweetQueueMax;
  static var MAX_PROCESS_QUEUE_SIZE = AppConfig.processQueueMax;
  static var MAX_SEARCH_HISTORY_SIZE = AppConfig.imageSearch.historySize;
  // don't tweet more than once every 30 secs
  static var MIN_TWEET_INTERVAL = AppConfig.minTweetInterval * 1000;

  #if debug
  static var ImageSearchInterval = 2 * 60 * 1000;
  static var SearchRetryInterval = 60 * 1000;
  #else
  static var ImageSearchInterval = AppConfig.imageSearch.interval * 1000; // 2.25 * 60 * 60 * 1000;
  static var SearchRetryInterval = AppConfig.imageSearch.retryInterval * 1000; //15 * 60 * 1000;
  #end

  var twit:Twit;
  var userStream:TwitStream;
  var tweetedSearchResultIds:Array<String> = [];
  var ignoredUsers:Array<User>;

  var timer:Timer;
  var startTime:Float;
  var searchTime:Float;
  var processing:Bool;
  var processQueue:Array<{url:String, status:Status}>;
  var tweetQueue:Array<Dynamic>;
  var lastTweetTime:Float;
  var shuttingDown:Bool;

  var jpegData:CustomData = {
    width:0, height:0, pixels: null, quality:0, argb:false,
    yQuantRandom:.0, uvQuantRandom:.0,
    dctQuantRowRandom:.0, dctQuantColRandom:.0,
    yduNoise:{r:.0, g:.0, b:.0}, uduNoise:{r:.0, g:.0, b:.0}, vduNoise:{r:.0,g:.0,b:.0},
    dcyMultRandom:.0, dcuMultRandom: .0, dcvMultRandom:.0,
    dcyOffsetRandom:.0,  dcuOffsetRandom:.0, dcvOffsetRandom:.0,
    rowReadRandom:.0, colReadRandom:0,
    nullFillMaxLen:0, nullFillMaxVal:0,
    rgbXOffsetRange:{r:0, g:0, b:0}, 
    rgbYOffsetRange:{r:0, g:0, b:0},
  }

  function new() {

    trace('Have image. Will glitch.');

    startTime = Tools.now();
    searchTime = startTime + 1000 * 60; // start running searches after 60 secs
    shuttingDown = false;
    processing = false;

    TwitterConfig.timeout_ms = 60 * 1000;
    twit = new Twit(TwitterConfig);
    userStream = twit.stream(StreamType.User);

    // user stream for responding to tweets @imgfkr
    userStream.on(StreamEventType.Tweet, onTweet);

    // load list of users to be ignored when performing an image search (some people don't like their images being randomly glitched by a bot)
    twit.get('lists/members', {slug:'ignore', owner_screen_name:AppConfig.name, count:5000}, listUsersLoaded);

    tweetQueue = [];
    processQueue = [];
    lastTweetTime = 0;

    timer = new Timer(1000);
    timer.run = tick;
    process.on('SIGTERM', shutdown);
  }


  function shutdown() {

    if (shuttingDown) return;

    trace('shutdown');

    tweetQueue = [];
    lastTweetTime = 0;

    shuttingDown = true;
    userStream.stop();
  }


  function tick() {

    if (shuttingDown) return;

    var n = Tools.now();

    if (searchTime !=-1){
      if (n >= searchTime){
        searchTime =-1;
        ImageSearch.run(twit, onSearchComplete);
      }
    }

    if (!processing && processQueue.length > 0){
      trace('processing queued item (current queue size:${processQueue.length})');
      var data = processQueue.shift();
      processImage(data.url, data.status);
    }

    if (tweetQueue.length > 0 && n - lastTweetTime > MIN_TWEET_INTERVAL){
      trace('sending item from tweetQueue. tweetQueue.length:${tweetQueue.length}');
      sendTweet(tweetQueue.shift());
    }
  }

  /**
   *  
   *  @param err - 
   *  @param data - 
   *  @param response - 
   */
  function listUsersLoaded(err:ApiError, data:ResponseData, response:Dynamic){
    if (err == null){
      ImageSearch.ignoredUsers = data.users.map(function(user) return user.id_str);
      trace('Ignoring ${ImageSearch.ignoredUsers.length} users.');
    } else {
      trace('Error loading ignore list members');
      trace(err.statusCode);
      trace(err.message);
    }
  }

  /**
  * 
  * @param  results
  */
  function onSearchComplete(results:Array<ImageSearchResult>) {

    if (shuttingDown) return;

    var now = Tools.now();

    if (results != null){
      // make sure we've not replied to this status already
      results = results.filter(function(result) return tweetedSearchResultIds.indexOf(result.status.id_str) == -1);

      if (results.length > 0) {
        // pick a random result
        var result = results[Std.int(Math.random() * results.length)];

        #if debug
        trace('ImageSearch done. Got ${results.length}');
        trace('Picked one. Will glitch image back to @' + result.status.user.screen_name);
        Tools.saveTweet(result.status);
        #end

        // prefer it large 
        var url = result.photo.media_url;
        if (result.photo.sizes.large != null) url = url + ":large";

        // store status id
        tweetedSearchResultIds.push(result.status.id_str);
        if (tweetedSearchResultIds.length > MAX_SEARCH_HISTORY_SIZE) tweetedSearchResultIds.shift();

        processImage(url, result.status);

        searchTime = now + ImageSearchInterval;

      } else {
        trace('No valid results. Retrying in $SearchRetryInterval');
        searchTime = now + SearchRetryInterval;
      }

    } else {
      trace('No usable results. retrying in $SearchRetryInterval');
      searchTime = now + SearchRetryInterval;
    }
  }


  /**
  * 
  * @param  message
  * @param  done
  */
  function sendTweet(data:Dynamic, ?done:Void->Void) {

    var now = Tools.now();
    if (now - lastTweetTime < MIN_TWEET_INTERVAL){
      tweetQueue.push(data);
      trace('tweet queued. queuesize:${tweetQueue.length}');
      if (tweetQueue.length > MAX_TWEET_QUEUE_SIZE) {        
        trace('tweetQueue size exceeds MAX_TWEET_QUEUE_SIZE ($MAX_TWEET_QUEUE_SIZE). Shifting oldest one.');
        tweetQueue.shift();
      }
      return;
    }

    lastTweetTime = now;

    #if debug
    trace('sendTweet - debug mode doesn\'t tweet');
    trace(data);
    if (done != null) done();
    return;
    #end

    try {    
      twit.post('statuses/update', data, function(err, d, response){
        if (err != null){
          trace("Error posting tweet.");
          trace(data.status);
          trace(err.code);
          trace(err.message);
        }
        if (done != null) done();
      });    
    } catch (error:Dynamic){
      trace("Error posting tweet.");
      trace(data.status);
      trace(error);
      if (done != null) done();
    }
  }


  /**
  * 
  * @param  status
  */
  function onTweet(status:Status) {

    var toUser = status.in_reply_to_screen_name;
    var fromUser = status.user.screen_name;

    // replying to ourselves? don't want this infinite recursion nightmare
    if (fromUser == AccountName && status.in_reply_to_status_id_str != null) return;

    //
    var mentioned = false;
    var direct = toUser == AccountName;

    var entities:TweetEntity = cast status.entities;
    var mediaEntities = Tools.getEntities(status).media;
    // var isRetweet = status.retweeted_status != null || status.quoted_status != null;

    // if not directly to us, are we mentioned by name?
    if(!direct){  
      var mentions = entities.user_mentions;
      if (mentions != null && mentions.length > 0){
        for (i in 0...mentions.length){
          if (mentions[i].screen_name == AccountName){
            mentioned = true;
          }
        }
      }
    }

    // someone tweeted directly to AccountName or mentioned it somewhere in their tweet
    if (direct || mentioned){

      var photos = Tools.getPhotos(mediaEntities);

      if (photos != null && photos.length > 0){
        var photo = photos[0];
        var url = photo.media_url;

        // prefer it large 
        if (photo.sizes.large != null) url = url + ":large";

        processImage(url, status);
      }
    }

    #if debug
    Tools.saveTweet(status);
    #end
  }



  /**
  * 
  * @param  status
  * @param  imageData
  */
  function replyToStatus(status:Status, imageData:String) {

    var name = status.user.screen_name;
    var scrambleLength = 140 - 4 - 25 - name.length; //23 chars reserved for photo.. apparently.
    var message = '.@${name}${Tools.scrambleStatusText(status, scrambleLength, 1/3)}' ;

    #if debug
    trace('replyToStatus...');
    trace(message);
    trace("debug mode does not reply");
    return;
    #end

    // post media to twitter
    twit.post('media/upload', { media_data: imageData }, function (err, data, response) {
      if (err == null){

        var mediaIdStr = data.media_id_string;
        var altText = 'A glitch for @${status.user.screen_name}';
        var meta_params = { media_id: mediaIdStr, alt_text: { text: altText } }

        // set media metadata
        twit.post('media/metadata/create', meta_params, function (err, data, response) {
          if (err == null) {
              var params:Dynamic = {
                status: message, 
                media_ids: [mediaIdStr], 
                in_reply_to_status_id: status.id_str
              };
              // post the status
              sendTweet(params);

          } else {
            trace('error creating media metadata');
            trace(err);
          }
        });
      } else {
        trace('error uploading image');
        trace(err);
      }
    });  
  }



  /**
  * 
  * @param  url
  * @param  complete
  */
  function processImage(url:String, ?status:Status = null) {

    if (processing){
      processQueue.push({url:url, status:status});
      trace('image processing queued. queuesize:${processQueue.length}');
      if (processQueue.length > MAX_PROCESS_QUEUE_SIZE){
        trace('processQueue size exceeds MAX_PROCESS_QUEUE_SIZE ($MAX_PROCESS_QUEUE_SIZE). Shifting oldest one.');
        processQueue.shift();
      }
      return;
    }

    processing = true;
    BufferLoader.load(url, function(data:Buffer){
            var response = null;

            if (!shuttingDown && data != null && data.length > 0) {        
                response = processBuffer(data);        
            } else {
                trace('Error loading image at $url');
            }

            onImageProcessingComplete(response, status);
            processing = false;
        });
  }


  function processBuffer(data:Buffer){

    var decoded = try { JpegJs.decode(data); } catch (err:Dynamic){ null; }

    if (decoded != null) {
      return glitchEncode(decoded);          
    } else {
      trace('Error decoding image.');
      return null;
    }
  }


  /**
  * 
  * @param  data
  * @param  status
  */
  function onImageProcessingComplete(data:String, ?status:Status){

    if (shuttingDown) return;

    if (data != null){

      if (status != null){
        replyToStatus(status, data);
      }

      #if debug
      var name = (status != null) ? status.id_str : '${Std.int(Math.random()*0xffffff)}';
      Fs.writeFileSync('$name.jpg', data, {encoding:'base64'});
      #end

    } else {
      trace('something went wrong processing the tweeted image');
    }
  }


  /**
  * 
  * @param  img data
  * @return base64 encoded jpeg data
  */
  function glitchEncode(img:RawImageData):String {

    var quality = Math.random() * Math.random() * 100;
    var wScale =  img.width / 20;
    var hScale =  img.height / 20;

    jpegData.width = img.width;
    jpegData.height = img.height;
    jpegData.pixels = Bytes.ofData(cast img.data);
    jpegData.quality = quality;

    jpegData.argb  = rBool(.25);
//
    jpegData.yQuantRandom = rBool(.25) ? Math.random() : .0;
    jpegData.uvQuantRandom = rBool(.15) ? Math.random() : .0;

    jpegData.dctQuantRowRandom = rBool(.1) ? (Math.random() - .5) * Math.random() * 100 : .0;
    jpegData.dctQuantColRandom = rBool(.1) ? Math.random() * 100: .0;

    randomiseRGB(jpegData.yduNoise, rBool(.1)?.25:.01, rBool(.1)?.25:.01, rBool(.1)?.25:.01);
    randomiseRGB(jpegData.uduNoise, rBool(.1)?.25:.01, rBool(.1)?.25:.01, rBool(.1)?.25:.01);
    randomiseRGB(jpegData.vduNoise, rBool(.2)?.25:.01, rBool(.2)?.25:.01, rBool(.2)?.25:.01);

    jpegData.dcyMultRandom = rBool(.15) ? Math.random() * 1.2 : .0;
    jpegData.dcuMultRandom = rBool(.15) ? Math.random() * 1.2 : .0;
    jpegData.dcvMultRandom = rBool(.15) ? Math.random() * 1.2 : .0;
    jpegData.dcyOffsetRandom = rBool(.15) ? Math.random() * 1.2 : .0; 
    jpegData.dcuOffsetRandom = rBool(.15) ? Math.random() * 1.2 : .0;
    jpegData.dcvOffsetRandom = rBool(.15) ? Math.random() * 1.2 : .0;

    jpegData.rowReadRandom = rBool(.5) ? rr( -1.5, 1.5) : .0;
    jpegData.colReadRandom = rBool(.25) ? rr( -1.5, 1.5) : 0;

    jpegData.nullFillMaxLen = rBool(.8) ? Std.int(Math.random() * 4) : 0;
    jpegData.nullFillMaxVal = Std.int(rr(0, 0xff));

    jpegData.rgbXOffsetRange.r = rBool(.9) ? 0 : Std.int(Math.random() * wScale);
    jpegData.rgbXOffsetRange.g = rBool(.9) ? 0 : Std.int(Math.random() * wScale);
    jpegData.rgbXOffsetRange.b = rBool(.9) ? 0 : Std.int(Math.random() * wScale);

    jpegData.rgbYOffsetRange.r = rBool(.9) ? 0 : Std.int(Math.random() * hScale);
    jpegData.rgbYOffsetRange.g = rBool(.9) ? 0 : Std.int(Math.random() * hScale);
    jpegData.rgbYOffsetRange.b = rBool(.9) ? 0 : Std.int(Math.random() * hScale);

    var wScalei = Math.round(wScale);
    if(rBool()) {
      shuffleBlocks(4 + Std.int(12 * Math.random()), [16, 32, 64, 128]);
      shuffleBlocks(2 + Std.int(4 * Math.random()), [wScalei, wScalei << 1, wScalei << 2, wScalei << 3, wScalei << 4]);
    } else {
      shuffleBlocks(2 + Std.int(4 * Math.random()), [wScalei, wScalei << 1, wScalei << 2, wScalei << 3, wScalei << 4]);
      shuffleBlocks(4 + Std.int(12 * Math.random()), [16, 32, 64, 128]);
    }

    return Base64.encode(writeJPEG());
  }


  function writeJPEG():Bytes {

    var io = new BytesOutput();
    var w = new CustomWriter(io);

    w.write(jpegData);

    return io.getBytes();
  }


  function shuffleBlocks(count:Int=8, blockSizes:Array<Int>) {

    var p = jpegData.pixels;
    var w = jpegData.width;
    var h = jpegData.height;

    var offsetBiasX = rBool() ? 0 : (Math.random() - .5) * 2.5;
    var offsetBiasY = rBool() ? 0 : (Math.random() - .5) * 2.5;

    for (c in 0...count){

      var xOff = Std.int(((Math.random() * Math.random())-.5 + offsetBiasX) * w/5);
      var yOff = Std.int(((Math.random() * Math.random())-.5 + offsetBiasY) * h/5);
      var startX = Std.int(Math.random() * w);
      var startY = Std.int(Math.random() * h);

      var blockSize = blockSizes[Std.int(Math.random() * blockSizes.length)];
      var width = blockSize;
      var height = rBool(.6) ? blockSize : blockSizes[Std.int(Math.random() * blockSizes.length)];

      if (width + startX > w) startX -= w;
      if (height + startY > h) startY -= h;

      for (x in startX...startX+width){
        for (y in startY...startY+height){

          var offsetA = (y * w + x) << 2; // src
          var offsetB = ((y+yOff) * w + x + xOff) << 2; // dest

          p.set(offsetB, p.get(offsetA));
          p.set(offsetB+1, p.get(offsetA+1)); 
          p.set(offsetB+2, p.get(offsetA+2));
          p.set(offsetB+3, p.get(offsetA+3)); 
        }
      }
    }
  }


  function randomiseRGB(rgb:RGB<Float>, aR:Float, aG:Float, aB:Float){
    rgb.r = Math.random() * aR;
    rgb.g = Math.random() * aG;
    rgb.b = Math.random() * aB;
  }


  static function rr(min:Float, max:Float):Float {
    return min + Math.random() * (max - min);
  }

  static inline function rBool(p:Float = .5):Bool return Math.random() < p;
}