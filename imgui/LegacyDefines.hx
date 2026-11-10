package imgui;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;

class LegacyDefines {
	public static function apply():Void {
		final legacyValue = Context.definedValue("hlimgui");
		if (legacyValue == null)
			return;

		if (!Context.defined("heaps_imgui"))
			Compiler.define("heaps-imgui", legacyValue);

		Context.warning("The hlimgui define is deprecated. Use -D heaps-imgui instead.", Context.currentPos());
	}
}
#end
