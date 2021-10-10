import flixel.math.FlxMath;

class HelperFunctions
{
	public static function truncateFloat(number:Float, precision:Int):Float {
		var perc = Math.pow(10, precision);
		return Math.round(number * perc) / perc;
	}

	public static function GCD(a, b) {
		return b == 0 ? FlxMath.absInt(a) : GCD(b, a % b);
	}
}