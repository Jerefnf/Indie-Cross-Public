package;

import cpp.vm.Gc;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.filters.GlowFilter;
import haxe.Timer;

#if windows
@:headerCode("
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <psapi.h>
")
#end

class MemoryMonitor extends TextField
{
	private var memPeak:Float = 0;
	private var lastMem:Float = 0;
	private var dangerTime:Float = 0;
	private var hue:Float = 0;

	public function new(inX:Float = 10.0, inY:Float = 10.0)
	{
		super();
		x = inX;
		y = inY;
		width = 180;
		height = 60;
		selectable = false;
		multiline = true;
		background = true;
		backgroundColor = 0x000000;
		border = true;
		defaultTextFormat = new TextFormat("_typewriter", 13, 0x00FF99);
		text = "[ INIT ]";
		addEventListener(Event.ENTER_FRAME, onEnter);
	}

	private function onEnter(_)
	{
		var now = Timer.stamp();
		var mem = getMemoryInMB();
		var diff = mem - lastMem;
		lastMem = mem;

		if (mem > memPeak) memPeak = mem;
		if (diff > 100) dangerTime = now + 3;

		if (now < dangerTime) {
			textColor = 0xFF0000;
			borderColor = 0xFF0000;
			filters = [new GlowFilter(0xFF0000, 1, 6, 6, 2)];
		} else {
			hue += 1;
			if (hue >= 360) hue = 0;
			var rgb = hslToRgb(hue / 360, 1, 0.5);
			var color = (rgb.r << 16) | (rgb.g << 8) | rgb.b;
			textColor = color;
			borderColor = color;
			filters = [new GlowFilter(color, 1, 6, 6, 2)];
		}

		text = "[ MEM:  " + format(mem) + " MB ]\n[ PEAK: " + format(memPeak) + " MB ]";
	}

	private inline function format(v:Float):String
	{
		return Std.string(Math.round(v * 100) / 100);
	}

	private function getMemoryInMB():Float
	{
		#if windows
		return obtainMemory() / 1024 / 1024;
		#else
		return Gc.memInfo64(3) / 1024 / 1024;
		#end
	}

	private function hslToRgb(h:Float, s:Float, l:Float):{r:Int, g:Int, b:Int}
	{
		var r:Float, g:Float, b:Float;
		if (s == 0) {
			r = g = b = l;
		} else {
			function hue2rgb(p:Float, q:Float, t:Float):Float {
				if (t < 0) t += 1;
				if (t > 1) t -= 1;
				if (t < 1 / 6) return p + (q - p) * 6 * t;
				if (t < 1 / 2) return q;
				if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
				return p;
			}
			var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
			var p = 2 * l - q;
			r = hue2rgb(p, q, h + 1 / 3);
			g = hue2rgb(p, q, h);
			b = hue2rgb(p, q, h - 1 / 3);
		}
		return {
			r: Std.int(r * 255),
			g: Std.int(g * 255),
			b: Std.int(b * 255)
		};
	}

	#if windows
	@:functionCode("
		auto memhandle = GetCurrentProcess();
		PROCESS_MEMORY_COUNTERS pmc;
		if (GetProcessMemoryInfo(memhandle, &pmc, sizeof(pmc)))
			return(pmc.WorkingSetSize);
		else
			return 0;
	")
	function obtainMemory():Dynamic
	{
		return 0;
	}
	#end
}
