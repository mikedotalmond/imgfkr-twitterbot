package imgfkr;

typedef AppConfig = {
  name:String,
  minTweetInterval:Int,
  processQueueMax:Int,
  tweetQueueMax:Int,
  imageSearch:{
    interval:Int,
    retryInterval:Int,
    historySize:Int,
    keywords:Array<String>
  }
}