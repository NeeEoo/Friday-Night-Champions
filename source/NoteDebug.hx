package;

import flixel.util.FlxSort;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

/**
 * DEBUG MODE
 */
class NoteDebug extends FlxState
{
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var camFollow:FlxObject;
	public var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public var notes:FlxTypedGroup<DebugNote>;

	public function new()
	{
		super();
	}

	override function create()
	{
		if(FlxG.sound.music != null) {
			FlxG.sound.music.stop();
		}

		Conductor.songPosition = 0;

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0.5, 0.5);
		gridBG.active = false;
		add(gridBG);

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(16, 16);
		textAnim.size = 26;
		textAnim.scrollFactor.set();

		textAnim.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		add(textAnim);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		notes = new FlxTypedGroup<DebugNote>();
		add(notes);

		FlxG.camera.follow(camFollow);

		generateStrums();
		generateNotes();

		super.create();
	}

	//var speed = 2.6;
	//var bpm = 190;
	//var totalHolds = 2;

	var downscroll = true;
	var speed = 1.3;
	var bpm = 159;
	var totalHolds = 1;

	var CENTER_OFFSET = 275;

	function generateStrums() {
		var strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes.forEach(function(spr) {
			spr.kill();
			spr.destroy();
		});

		strumLineNotes.clear();

		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets', "shared");
			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			babyArrow.x += DebugNote.swagWidth * i;
			switch (i%4)
			{
				case 0:
					babyArrow.animation.addByPrefix('static', 'arrow static instance 1');
					babyArrow.animation.addByPrefix('pressed', 'left press instance 1', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm instance 1', 24, false);
				case 1:
					babyArrow.animation.addByPrefix('static', 'arrow static instance 2');
					babyArrow.animation.addByPrefix('pressed', 'down press instance 1', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm instance 1', 24, false);
				case 2:
					babyArrow.animation.addByPrefix('static', 'arrow static instance 4');
					babyArrow.animation.addByPrefix('pressed', 'up press instance 1', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm instance 1', 24, false);
				case 3:
					babyArrow.animation.addByPrefix('static', 'arrow static instance 3');
					babyArrow.animation.addByPrefix('pressed', 'right press instance 1', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm instance 1', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.ID = i;

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * 1);

			babyArrow.x -= CENTER_OFFSET;

			//cpuStrums.forEach(function(spr:FlxSprite)
			//{
			//	spr.centerOffsets(); //CPU arrows start out slightly off-center
			//});

			strumLineNotes.add(babyArrow);
		}
	}

	function generateNotes() {
		Conductor.changeBPM(bpm);

		notes.forEach(function(spr) {
			spr.kill();
			spr.destroy();
		});

		notes.clear();

		var unspawnNotes:Array<DebugNote> = [];

		for (i in 0...4)
		{
			var songNotes:Array<Dynamic> = [100, i, Conductor.stepCrochet * totalHolds];
			var daStrumTime:Float = songNotes[0];
			if (daStrumTime < 0)
				daStrumTime = 0;
			var daNoteData:Int = Std.int(songNotes[1] % 4);

			var gottaHitNote:Bool = true;

			var oldNote:DebugNote = null;

			var swagNote:DebugNote = new DebugNote(downscroll, speed, daStrumTime, daNoteData, null);

			swagNote.sustainLength = songNotes[2];
			swagNote.scrollFactor.set(0, 0);

			var susLength:Float = totalHolds;//swagNote.sustainLength / Conductor.stepCrochet;

			unspawnNotes.push(swagNote);

			for (susNote in 0...Math.floor(susLength))
			{
				oldNote = unspawnNotes[unspawnNotes.length - 1];

				var sustainNote:DebugNote = new DebugNote(downscroll, speed, daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
				sustainNote.scrollFactor.set();
				unspawnNotes.push(sustainNote);

				sustainNote.mustPress = gottaHitNote;

				if (sustainNote.mustPress)
				{
					sustainNote.x += FlxG.width / 2; // general offset
					sustainNote.x -= CENTER_OFFSET; // general offset
				}
			}

			swagNote.mustPress = gottaHitNote;

			if (swagNote.mustPress)
			{
				swagNote.x += FlxG.width / 2; // general offset
				swagNote.x -= CENTER_OFFSET; // general offset
			}
		}

		unspawnNotes.sort(sortByShit);

		while (unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
		{
			var dunceNote:DebugNote = unspawnNotes[0];
			notes.add(dunceNote);

			var index:Int = unspawnNotes.indexOf(dunceNote);
			unspawnNotes.splice(index, 1);
		}
	}

	function sortByShit(Obj1:DebugNote, Obj2:DebugNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function updateNotePosition() {
		var fakeCrochet:Float = (60 / Conductor.bpm) * 1000;
		var diffY = 0.45 * speed * Conductor.stepCrochet;

		notes.forEachAlive(function(daNote:DebugNote)
		{
			var noteData = Math.floor(Math.abs(daNote.noteData));

			if (downscroll)
			{
				daNote.y = (strumLineNotes.members[noteData].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * speed);
				if(noteData == 3) {
					daNote.y -= daNote.noteYOff;
				}

				if(daNote.isSustainNote)
				{
					// Remember = minus makes notes go up, plus makes them go down
					if(noteData == 0) {
						if(daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
							daNote.y += daNote.prevNote.height;
						else
							daNote.y += daNote.height / 2;
					} else if(noteData == 1) {
						// Remember = minus makes notes go up, plus makes them go down
						if(daNote.prevNote != null && daNote.animation.curAnim.name.endsWith('end')) {
							daNote.y += (diffY + daNote.prevNote.height / 2) - daNote.height;// + 5;
						}
						else
							daNote.y += daNote.height / 2;
					} else if(noteData == 2) {
						if(daNote.prevNote != null && daNote.animation.curAnim.name.endsWith('end')) {
							if(daNote.prevNote.isSustainNote) {
								daNote.y += daNote.prevNote.height * 1.5;
							} else {
								daNote.y += diffY + daNote.prevNote.height / 2;
							}
							daNote.y -= daNote.height;
						}
						else {
							daNote.y += daNote.height / 2;
						}
					} else if(noteData == 3) {
						daNote.y -= daNote.height - diffY;
					}
				}
			}
			else
			{
				daNote.y = (strumLineNotes.members[noteData].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * speed);
				if(noteData == 3) {
					daNote.y += daNote.noteYOff;
				}

				if(daNote.isSustainNote)
				{
					if(noteData == 0) {
						daNote.y -= daNote.height / 2;
					} else if(noteData == 1) {
						if(daNote.prevNote != null && daNote.animation.curAnim.name.endsWith('end')) {
							daNote.y -= (diffY - daNote.prevNote.height / 2);// + 5;
						}
						else
							daNote.y -= daNote.height / 2;
					} else if(noteData == 2) {
						// Remember = minus makes notes go up, plus makes them go down
						if(daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null) {
							var noteOffset = daNote.prevNote.height / 2;
							if(daNote.prevNote.isSustainNote) {
								daNote.y -= noteOffset;
							} else {
								daNote.y -= diffY - noteOffset;
							}
						}
						else {
							daNote.y -= daNote.height / 2;
						}
					}

				}
			}
		});
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.25;

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -90;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 90;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -90;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 90;
			else
				camFollow.velocity.x = 0;
		}
		else
		{
			camFollow.velocity.set();
		}

		var oldBpm = bpm;
		var oldSpeed = speed;
		var oldTotalHolds = totalHolds;

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		if (FlxG.keys.justPressed.W) bpm += multiplier;
		if (FlxG.keys.justPressed.S) bpm -= multiplier;

		if (FlxG.keys.justPressed.R) speed += 0.1 * multiplier;
		if (FlxG.keys.justPressed.F) speed -= 0.1 * multiplier;

		if (FlxG.keys.justPressed.T) totalHolds += multiplier;
		if (FlxG.keys.justPressed.G) totalHolds -= multiplier;

		if (FlxG.keys.justPressed.SPACE) {
			downscroll = !downscroll;

			generateStrums();
			generateNotes();
		}

		if(bpm != oldBpm) {
			generateNotes();
		}
		if(totalHolds != oldTotalHolds) {
			generateNotes();
		}
		if(speed != oldSpeed) {
			generateNotes();
		}

		updateNotePosition();

		textAnim.text = [
			"Speed RF: " + speed,
			"BPM WS: " + bpm,
			"totalHolds TG: " + totalHolds,
			"Downscroll SPACE: " + downscroll,
			""
		].join("\n");

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}
}
