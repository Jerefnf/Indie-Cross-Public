package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;


class DiamondTransSubState extends FlxSubState
{
	var filters:Array<BitmapFilter> = [];
        var shader:ShaderFilter = new ShaderFilter(new DiamondTransShader());
	var rect:FlxSprite;
	var tween:FlxTween;

	var finishCallback:() -> Void;
	var duration:Float;

	var fi:Bool = true;

	public function new(duration:Float = 1.0, fadeIn:Bool = true, finishCallback:() -> Void = null)
	{
		super();

		this.duration = duration;
		this.finishCallback = finishCallback;
		this.fi = fadeIn;
	}

	override public function create()
	{
		super.create();

		camera = new FlxCamera();
		camera.bgColor = FlxColor.TRANSPARENT;

		FlxG.cameras.add(camera, false);

		// shader = new DiamondTransShader();

		shader.shader.data.progress.value = [0.0];
		shader.shader.data.reverse.value = [false];
                shader.shader.data.diamondPixelSize.value = [30.0];
                filters.push(shader);

		rect = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		rect.scrollFactor.set();
		rect.alpha = 0.00001;

                var camlol = new flixel.FlxCamera();
		FlxG.cameras.add(camlol, false);
		camlol.bgColor.alpha = 0;
                camlol.filtersEnabled = true;
                camlol.setFilters(filters);

                rect.cameras = [camlol];
                add(rect);
                

		if (fi)
			fadeIn();
		else
			fadeOut();

		closeCallback = _closeCallback;
	}

	function __fade(from:Float, to:Float, reverse:Bool)
	{
		trace("fade initiated");

		rect.alpha = 1;
		shader.shader.data.progress.value = [from];
		shader.shader.data.reverse.value = [reverse];

		tween = FlxTween.num(from, to, duration, {
			ease: FlxEase.linear,
			onComplete: function(_)
			{
				trace("finished");
				if (finishCallback != null)
				{
					trace("with callback");
					finishCallback();
				}
			}
		}, function(num:Float)
		{
			shader.shader.data.progress.value = [num];
		});
	}

	function fadeIn()
	{
		__fade(0.0, 1.0, true);
	}

	function fadeOut()
	{
		__fade(0.0, 1.0, false);
	}

	function _closeCallback()
	{
		if (tween != null)
			tween.cancel();
	}
}
