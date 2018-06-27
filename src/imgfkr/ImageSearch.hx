package imgfkr;
import twit.*;
import twitter.*;

/**
 * ...
 * @author Mike Almond | https://github.com/mikedotalmond
 */
 
class ImageSearch {
	
  static public var ignoredUsers:Array<String> = [];
	
  public static function run(twitter:Twit, ?callback:Array<ImageSearchResult>->Void){
		
    var searchQuery = Main.AppConfig.imageSearch.keywords.join(' OR ') + ' filter:images';
		
    var searchParameters = {
      q:searchQuery,
      count:100,
      result_type:"recent",  // recent, mixed, popular
      include_entities:true,
    };
		
    twitter.get('search/tweets', searchParameters, function(err:ApiError, data:ResponseData, response:Dynamic) {
      if (err == null){
        var users = [];
        var results = [];
        for (i in 0...data.statuses.length){
          var status = data.statuses[i];
          var id = status.user.id_str;
          if (users.indexOf(id) == -1 && ignoredUsers.indexOf(id) == -1){ // don't allow multiple from same, don't allow ignoredUsers to enter the results
            if (Tools.filterStatus(status, true, 4, 2)){ // original tweets with 4 or fewer hashtags and 2 or fewer links
              var photos = Tools.getStatusPhotos(status);
              if (photos != null && photos.length > 0) {
                users.push(status.user.id_str);
                results.push({status:status, photo:photos[0]});
              }
            }
          }
        }
				
        #if debug
        trace('Filtered results down to ${results.length} of ${data.statuses.length}');
        #end
				
        callback(results);
				
      } else {
        trace('API Error #${err.code} - ${err.message}');
        trace('Status ${err.statusCode}');
        trace(data);
        callback(null);
      }
    });
  }
}