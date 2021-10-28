package;

import lime.utils.Assets;

using StringTools;

class Difficulty
{
    public static inline final EASY = 0;
    public static inline final NORMAL = 1;
    public static inline final HARD = 2;
    public static inline final CHAMP = 3;

	public static var difficultyArray:Array<String> = ["Easy", "Normal", "Hard", "Champ"];
	public static var difficultyEnding:Array<String> = ["-easy", "", "-hard", "-champ"];

	public static function fromInt(difficulty:Int):String
	{
		return difficultyArray[difficulty];
	}
}
