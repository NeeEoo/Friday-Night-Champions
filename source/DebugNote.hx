package;

import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class DebugNote extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var rawNoteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:DebugNote;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;

	public var noteYOff:Int = 0;

	public var rating:String = "shit";

	public function new(downscroll:Bool, speed:Float, strumTime:Float, noteData:Int, ?prevNote:DebugNote, ?sustainNote:Bool = false, ?inCharter:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		if (inCharter)
			this.strumTime = strumTime;
		else
			this.strumTime = Math.round(strumTime);

		if (this.strumTime < 0)
			this.strumTime = 0;

		this.noteData = noteData;

		frames = Paths.getSparrowAtlas('NOTE_assets', "shared");

		if (isSustainNote)
		{
			animation.addByPrefix('purpleholdend', 'pruple end hold instance 1');
			animation.addByPrefix('greenholdend', 'green hold end instance 1');
			animation.addByPrefix('redholdend', 'red hold end instance 1');
			animation.addByPrefix('blueholdend', 'blue hold end instance 1');

			animation.addByPrefix('purplehold', 'purple hold piece instance 1');
			animation.addByPrefix('greenhold', 'green hold piece instance 1');
			animation.addByPrefix('redhold', 'red hold piece instance 1');
			animation.addByPrefix('bluehold', 'blue hold piece instance 1');
		} else {
			animation.addByPrefix('greenScroll', 'green instance 1');
			animation.addByPrefix('redScroll', 'red instance 1');
			animation.addByPrefix('blueScroll', 'blue instance 1');
			animation.addByPrefix('purpleScroll', 'purple instance 1');
		}

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = true;

		x += swagWidth * noteData;

		if(!isSustainNote) {
			switch (noteData%4)
			{
				case 0:
					animation.play('purpleScroll');
				case 1:
					animation.play('blueScroll');
				case 2:
					animation.play('greenScroll');
				case 3:
					animation.play('redScroll');
			}
		}

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		if (sustainNote && downscroll)
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			var stepHeight = (0.45 * Conductor.stepCrochet) * speed;

			noteYOff = Math.round(-stepHeight + swagWidth * 0.5);
			alpha = 0.6;

			x += width / 2;

			switch (noteData%4)
			{
				case 0:
					animation.play('purpleholdend');
				case 1:
					animation.play('blueholdend');
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
			}

			updateHitbox();

			x -= width / 2;

			//if (PlayState.curStage.startsWith('school'))
			//	x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData%4)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				if(prevNote.noteData == 3) {
					prevNote.updateHitbox();

					prevNote.scale.y *= stepHeight / prevNote.height;
					prevNote.updateHitbox();

					if (antialiasing)
						prevNote.scale.y *= 1.0 + (1.0 / prevNote.frameHeight);
				} else {
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * speed;
					prevNote.updateHitbox();
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// ass
			if (isSustainNote)
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
					canBeHit = true;
				else
					canBeHit = false;
			}

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
