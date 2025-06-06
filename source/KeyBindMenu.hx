package;

import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.input.gamepad.FlxGamepad;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

using StringTools;

class KeyBindMenu extends FlxSubState
{
	var keyTextDisplay:FlxText;
	var keyWarning:FlxText;
	var warningTween:FlxTween;
	var keyText:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT", "LEFT ATTACK", "RIGHT ATTACK", "DODGE"];
	var defaultKeys:Array<String> = ["A", "S", "W", "D", "SHIFT", "SHIFT", "SPACE"];
	var defaultGpKeys:Array<String> = [
		"DPAD_LEFT",
		"DPAD_DOWN",
		"DPAD_UP",
		"DPAD_RIGHT",
		"LEFT_TRIGGER",
		'RIGHT_TRIGGER',
		"A"
	];
	var curSelected:Int = 0;

	var keys:Array<String> = [
		FlxG.save.data.leftBind,
		FlxG.save.data.downBind,
		FlxG.save.data.upBind,
		FlxG.save.data.rightBind,
		FlxG.save.data.attackLeftBind,
		FlxG.save.data.attackRightBind,
		FlxG.save.data.dodgeBind
	];
	var gpKeys:Array<String> = [
		FlxG.save.data.gpleftBind,
		FlxG.save.data.gpdownBind,
		FlxG.save.data.gpupBind,
		FlxG.save.data.gprightBind,
		FlxG.save.data.gpatkLeftBind,
		FlxG.save.data.gpatkRightBind,
		FlxG.save.data.gpdodgeBind
	];
	var tempKey:String = "";
	var blacklist:Array<String> = ["ESCAPE", "ENTER", "BACKSPACE", "TAB"];

	var blackBox:FlxSprite;
	var infoText:FlxText;

	var state:String = "select";

	var canChange:Bool = false;
	var gamepad:Bool = false;

	override function create()
	{
		for (i in 0...keys.length)
		{
			var k = keys[i];
			if (k == null)
				keys[i] = defaultKeys[i];
		}

		for (i in 0...gpKeys.length)
		{
			var k = gpKeys[i];
			if (k == null)
				gpKeys[i] = defaultGpKeys[i];
		}

		// FlxG.sound.playMusic('assets/music/configurator' + TitleState.soundExt);

		persistentUpdate = true;

		keyTextDisplay = new FlxText(-10, 0, 1280, "", 72);
		keyTextDisplay.scrollFactor.set(0, 0);
		keyTextDisplay.setFormat("VCR OSD Mono", 42, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyTextDisplay.borderSize = 3;
		keyTextDisplay.borderQuality = 1;

		blackBox = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackBox.scrollFactor.set(0, 0);
		add(blackBox);

		infoText = new FlxText(-10, 580, 1280,
			'Current Selected Mode: ${gamepad ? 'GAMEPAD' : 'KEYBOARD'}. Press TAB to switch\n(${gamepad ? 'RIGHT Trigger' : 'Escape'} to save, ${gamepad ? 'LEFT Trigger' : 'Backspace'} to leave without saving. ${gamepad ? 'START To change a keybind' : ''})',
			72);
		infoText.scrollFactor.set(0, 0);
		infoText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.borderSize = 3;
		infoText.borderQuality = 1;
		infoText.alpha = 0.00001;
		infoText.screenCenter(FlxAxes.X);
		add(infoText);
		add(keyTextDisplay);

		blackBox.alpha = 0.00001;
		keyTextDisplay.alpha = 0.00001;

		FlxTween.tween(keyTextDisplay, {alpha: 1}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(infoText, {alpha: 1}, 1.4, {ease: FlxEase.expoInOut});
		FlxTween.tween(blackBox, {alpha: 0.7}, 1, {ease: FlxEase.expoInOut});

		if (OptionsMenu.instance != null)
		{
			OptionsMenu.instance.acceptInput = false;
		}

		textUpdate();

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			canChange = true;
		});

		super.create();
	}

	var frames = 0;

	override function update(elapsed:Float)
	{
		var realGamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (frames <= 10)
			frames++;

		switch (state)
		{
			case "select":
				if (FlxG.keys.justPressed.UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}

				if (FlxG.keys.justPressed.DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}

				if (FlxG.keys.justPressed.TAB)
				{
					gamepad = !gamepad;
					infoText.text = 'Current Mode: ${gamepad ? 'GAMEPAD' : 'KEYBOARD'}. Press TAB to switch\n(${gamepad ? 'RIGHT Trigger' : 'Escape'} to save, ${gamepad ? 'LEFT Trigger' : 'Backspace'} to leave without saving. ${gamepad ? 'START To change a keybind' : ''})';
					textUpdate();
				}

				if (FlxG.keys.justPressed.ENTER)
				{
					if (canChange)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						state = "input";
					}
				}
				else if (FlxG.keys.justPressed.ESCAPE)
				{
					quit();
				}
				else if (FlxG.keys.justPressed.BACKSPACE)
				{
					reset();
				}
				if (realGamepad != null) // GP Logic
				{
					if (realGamepad.justPressed.DPAD_UP)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(-1);
						textUpdate();
					}
					if (realGamepad.justPressed.DPAD_DOWN)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(1);
						textUpdate();
					}

					if (realGamepad.justPressed.START && frames > 10)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						state = "input";
					}
					else if (realGamepad.justPressed.LEFT_TRIGGER)
					{
						quit();
					}
					else if (realGamepad.justPressed.RIGHT_TRIGGER)
					{
						reset();
					}
				}

			case "input":
				tempKey = keys[curSelected];
				keys[curSelected] = "?";
				if (gamepad)
					gpKeys[curSelected] = "?";
				textUpdate();
				state = "waiting";

			case "waiting":
				if (realGamepad != null && gamepad) // GP Logic
				{
					if (FlxG.keys.justPressed.ESCAPE)
					{ // just in case you get stuck
						gpKeys[curSelected] = tempKey;
						state = "select";
						FlxG.sound.play(Paths.sound('confirmMenu'));
					}

					if (realGamepad.justPressed.START)
					{
						addKeyGamepad(defaultKeys[curSelected]);
						save();
						state = "select";
					}

					if (realGamepad.justPressed.ANY)
					{
						trace(realGamepad.firstJustPressedID());
						addKeyGamepad(realGamepad.firstJustPressedID());
						save();
						state = "select";
						textUpdate();
					}
				}
				else
				{
					if (FlxG.keys.justPressed.ESCAPE)
					{
						keys[curSelected] = tempKey;
						state = "select";
						FlxG.sound.play(Paths.sound('confirmMenu'));
					}
					else if (FlxG.keys.justPressed.ENTER)
					{
						addKey(defaultKeys[curSelected]);
						save();
						state = "select";
					}
					else if (FlxG.keys.justPressed.ANY)
					{
						addKey(FlxG.keys.getIsDown()[0].ID.toString());
						save();
						state = "select";
					}
				}

			case "exiting":

			default:
				state = "select";
		}

		if (FlxG.keys.justPressed.ANY)
			textUpdate();

		super.update(elapsed);
	}

	function textUpdate()
	{
		keyTextDisplay.text = "\n\n";

		if (gamepad)
		{
			for (i in 0...gpKeys.length)
			{
				var textStart = (i == curSelected) ? "> " : "  ";
				trace(gpKeys[i]);
				keyTextDisplay.text += textStart + keyText[i] + ": " + gpKeys[i] + "\n";
			}
		}
		else
		{
			for (i in 0...keys.length)
			{
				var textStart = (i == curSelected) ? "> " : "  ";
				keyTextDisplay.text += textStart + keyText[i] + ": " + keys[i];

				if (keyText[i].toLowerCase() == 'left' || keyText[i].toLowerCase() == 'right' || keyText[i].toLowerCase() == 'up'
					|| keyText[i].toLowerCase() == 'down')
					keyTextDisplay.text += " / " + keyText[i] + " ARROW\n";
				else
					keyTextDisplay.text += "\n";
			}
		}

		keyTextDisplay.screenCenter();
	}

	function save()
	{
		FlxG.save.data.leftBind = keys[0];
		FlxG.save.data.downBind = keys[1];
		FlxG.save.data.upBind = keys[2];
		FlxG.save.data.rightBind = keys[3];
		FlxG.save.data.attackLeftBind = keys[4];
		FlxG.save.data.attackRightBind = keys[5];
		FlxG.save.data.dodgeBind = keys[6];

		FlxG.save.data.gpleftBind = gpKeys[0];
		FlxG.save.data.gpdownBind = gpKeys[1];
		FlxG.save.data.gpupBind = gpKeys[2];
		FlxG.save.data.gprightBind = gpKeys[3];
		FlxG.save.data.gpatkLeftBind = gpKeys[4];
		FlxG.save.data.gpatkRightBind = gpKeys[5];
		FlxG.save.data.gpdodgeBind = gpKeys[6];

		FlxG.save.flush();

		PlayerSettings.player1.controls.loadKeyBinds();
	}

	function reset()
	{
		for (i in 0...keys.length)
		{
			keys[i] = defaultKeys[i];
		}
		quit();
	}

	public static var backThing:Void->Void;

	function quit()
	{
		state = "exiting";

		save();

		if (OptionsMenu.instance != null)
			OptionsMenu.instance.acceptInput = true;

		FlxTween.tween(keyTextDisplay, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(blackBox, {alpha: 0}, 1.1, {
			ease: FlxEase.expoInOut,
			onComplete: function(flx:FlxTween)
			{
				close();
				if (backThing != null)
				{
					backThing();
				}
			}
		});
		FlxTween.tween(infoText, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
	}

	function addKeyGamepad(r:String)
	{
		var shouldReturn:Bool = true;

		var notAllowed:Array<String> = ["START"];

		for (x in 0...gpKeys.length)
		{
			var oK = gpKeys[x];
			if (oK == r)
			{
				gpKeys[x] = null;
			}
			if (notAllowed.contains(oK))
			{
				gpKeys[x] = null;
				return;
			}
		}

		if (shouldReturn)
		{
			gpKeys[curSelected] = r;
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		else
		{
			gpKeys[curSelected] = tempKey;
			FlxG.sound.play(Paths.sound('scrollMenu'));
			keyWarning.alpha = 1;
			warningTween.cancel();
			warningTween = FlxTween.tween(keyWarning, {alpha: 0}, 0.5, {ease: FlxEase.circOut, startDelay: 2});
		}
	}

	function addKey(r:String)
	{
		var shouldReturn:Bool = true;

		var notAllowed:Array<String> = [];

		for (x in blacklist)
		{
			notAllowed.push(x);
		}

		trace(notAllowed);

		for (x in 0...keys.length)
		{
			var oK = keys[x];
			if (oK == r)
			{
				if (!keyText[x].toLowerCase().contains('attack'))
				{
					keys[x] = null;
				}
			}
			if (notAllowed.contains(oK))
			{
				keys[x] = null;
				return;
			}
		}

		if (r.contains("NUMPAD"))
		{
			keys[curSelected] = null;
			return;
		}

		if (shouldReturn)
		{
			keys[curSelected] = r;
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		else
		{
			keys[curSelected] = tempKey;
			FlxG.sound.play(Paths.sound('scrollMenu'));
			keyWarning.alpha = 1;
			warningTween.cancel();
			warningTween = FlxTween.tween(keyWarning, {alpha: 0}, 0.5, {ease: FlxEase.circOut, startDelay: 2});
		}
	}

	function changeItem(_amount:Int = 0)
	{
		curSelected += _amount;

		if (curSelected > keys.length - 1)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = keys.length - 1;
	}
}
