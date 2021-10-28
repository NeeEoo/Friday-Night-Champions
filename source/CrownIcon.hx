package;

import flixel.FlxSprite;

class CrownIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	public function new()
	{
		super();

		loadGraphic(Paths.image('crown'));
		antialiasing = true;

		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width - 70, sprTracker.y - 20);
	}
}
