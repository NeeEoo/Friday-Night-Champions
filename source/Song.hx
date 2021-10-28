package;

import haxe.Json;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	var validScore:Bool;
}

class Song
{
	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		trace(jsonInput);

		// pre lowercasing the folder name
		var folderLowercase = Song.fixSongname(folder);

		trace('loading ' + folderLowercase + '/' + jsonInput.toLowerCase());

		var rawJson = Assets.getText(Paths.json(folderLowercase + '/' + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}

	public inline static function fixSongname(songName:String) {
		var sn = StringTools.replace(songName, " ", "-").toLowerCase();
		switch (sn) {
			case 'dad-battle': sn = 'dadbattle';
			case 'philly-nice': sn = 'philly';
		}
		return sn;
	}
}
