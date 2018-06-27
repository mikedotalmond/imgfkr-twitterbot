package imgfkr.jpg;

/**
 * extend jpeg encoder Data with glitch parameters
 * @author Mike Almond | https://github.com/mikedotalmond
 */

typedef RGB<T> = {
  var r:T;
  var g:T;
  var b:T;
}

typedef CustomData = {> format.jpg.Data,
	
  var argb:Bool;
	
	// 0-1
  var yQuantRandom:Float;	
  var uvQuantRandom:Float;	
	
	// +/- 1
  var dctQuantRowRandom:Float;
  var dctQuantColRandom:Float;
	
	// Affects the RGB2YUV calculations
	// +/- 1 per component
  var yduNoise:RGB<Float>;
  var uduNoise:RGB<Float>;
  var vduNoise:RGB<Float>;
	
	// 
  var dcyMultRandom:Float;
  var dcuMultRandom:Float;
  var dcvMultRandom:Float;
	//
  var dcyOffsetRandom:Float;
  var dcuOffsetRandom:Float;
  var dcvOffsetRandom:Float;
	
	// 0...1
  var rowReadRandom:Float;
	// 0...1 for horiz lines. > 1 for skewing. < 0 for broken colours and skewing
  var colReadRandom:Float;
	
	// how null BitString values are handled in the encoder
  var nullFillMaxLen:Int; // Set 0 to skip nulls entirely
  var nullFillMaxVal:Int;
	
  var rgbXOffsetRange:RGB<Int>;
  var rgbYOffsetRange:RGB<Int>;
}