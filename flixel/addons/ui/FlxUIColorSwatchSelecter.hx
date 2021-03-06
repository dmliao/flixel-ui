package flixel.addons.ui;
import flash.geom.Rectangle;
import flixel.addons.ui.interfaces.IFlxUIClickable;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * ...
 * @author larsiusprime
 */
class FlxUIColorSwatchSelecter extends FlxUIGroup implements IFlxUIClickable
{
	public static inline var CLICK_EVENT:String = "click_color_swatch_selecter";
	
	public var spacingH(default, set):Float;
	public var spacingV(default, set):Float;
	public var maxColumns(default, set):Float;
	
	private function set_spacingH(f:Float):Float {
		spacingH = f;
		_dirtyLayout = true;
		return f;
	}
	
	private function set_spacingV(f:Float):Float {
		spacingV = f;
		_dirtyLayout = true;
		return f;
	}
	
	private function set_maxColumns(f:Float):Float {
		maxColumns = f;
		_dirtyLayout = true;
		return f;
	}
	
	public var skipButtonUpdate(default, set):Bool;
	private function set_skipButtonUpdate(b:Bool):Bool
	{
		skipButtonUpdate = b;
		for (thing in members)
		{
			if (thing != _selectionSprite)
			{
				var swatch:FlxUIColorSwatch = cast thing;
				swatch.skipButtonUpdate = b;
			}
		}
		return b;
	}
	
	/**
	 * A handy little group for selecting color swatches from
	 * @param	X					X location
	 * @param	Y					Y location
	 * @param	?SelectionSprite	The selection box sprite (optional, auto-generated if not supplied)
	 * @param	?list_colors		A list of single-colors to generate swatches from. 1st of 3 alternatives.
	 * @param	?list_data			A list of swatch data to generate swatches from. 2nd of 3 alternatives.
	 * @param	?list_swatches		A list of the actual swatch widgets themselves. 3rd of 3 alternatives.
	 * @param	SpacingH			Horizontal spacing between swatches
	 * @param	SpacingV			Vertical spacing between swatches
	 * @param	MaxColumns			Number of horizontal swatches in a row before a line break
	 */
	
	public function new(X:Float,Y:Float,?SelectionSprite:FlxSprite,?list_colors:Array<Int>,?list_data:Array<SwatchData>,?list_swatches:Array<FlxUIColorSwatch>,SpacingH:Int=2, SpacingV:Int=2, MaxColumns:Int=-1) 
	{
		super(X, Y);
		
		if (SelectionSprite != null) {
			_selectionSprite = SelectionSprite;
		}
		
		var i:Int = 0;
		var swatch:FlxUIColorSwatch;
		if (list_data != null)
		{
			for (data in list_data)
			{
				swatch = new FlxUIColorSwatch(0, 0, data);
				swatch.callback = selectCallback.bind(i);
				swatch.broadcastToFlxUI = false;
				swatch.id = data.name;
				add(swatch);
				i++;
			}
		}else if (list_colors != null) 
		{
			for (color in list_colors) 
			{
				swatch = new FlxUIColorSwatch(0, 0, color);
				swatch.callback = selectCallback.bind(i);
				swatch.broadcastToFlxUI = false;
				swatch.id = "0x"+StringTools.hex(color, 6);
				add(swatch);
				i++;
			}
		}else if (list_swatches != null) 
		{
			for (swatch in list_swatches) 
			{
				swatch.id = "swatch_" + i;
				swatch.callback = selectCallback.bind(i);
				swatch.broadcastToFlxUI = false;
				add(swatch);
				i++;
			}
		}
		
		var xx:Float = X;
		var yy:Float = Y;
		
		var i:Int = 0;
		
		spacingH = SpacingH;
		spacingV = SpacingV;
		maxColumns = MaxColumns;
		
		if (_selectionSprite == null)
		{
			if (members.length >= 1) 
			{
				var ww:Int = Std.int(members[0].width);
				var hh:Int = Std.int(members[0].height);
				
				_selectionSprite = new FlxSprite();
				_selectionSprite.makeGraphic(ww+4, hh+4, 0xFFFFFFFF, false, "selection_sprite_" + ww + "x" + hh + "0xFFFFFFFF");
				
				if (_flashRect == null) { _flashRect = new Rectangle();}
				
				_flashRect.x = 2;
				_flashRect.y = 2;
				_flashRect.width = ww;
				_flashRect.height = hh;
				_selectionSprite.pixels.fillRect(_flashRect, 0x00000000);
				add(_selectionSprite);
			}
		}
		
		updateLayout();
		
		selectByIndex(0);
	}
	
	public override function update(elapsed:Float):Void {
		if (_dirtyLayout) {
			updateLayout();
		}
		super.update(elapsed);
	}
	
	public function updateLayout():Void {
		if (members == null || members.length == 0) {
			return;
		}
		
		var firstSprite:FlxSprite = members[0];
		var firstX:Float = x;
		var firstY:Float = y;
		if(firstSprite != null){
			firstX = firstSprite.x;
			firstY = firstSprite.y;
		}
		
		var xx:Float = firstX;
		var yy:Float = firstY;
		var columns:Int = 0;
		
		for (sprite in members) {
			if (sprite != null && sprite != _selectionSprite) {
				sprite.x = xx;
				sprite.y = yy;
				xx += (sprite.width + spacingH);
				columns++;
				if (maxColumns != -1 && columns >= maxColumns) {
					columns = 0;
					xx = firstX;
					yy += sprite.height + spacingV;
				}
			}
		}
		
		_dirtyLayout = false;
	}
	
	public function changeColors(list:Array<SwatchData>):Void {
		var swatches:Int = members.length - 1;
		
		var swatchForSelect:SwatchData = null;
		
		if (_selectedSwatch != null) {
			swatchForSelect = selectedSwatch.colors;
		}
		
		for (thing in members) {
			if(thing != _selectionSprite){
				thing.visible = false;
				thing.active = false;
			}else {
				remove(_selectionSprite, true);
			}
		}
		
		for (i in 0...list.length) {
			var fuics:FlxUIColorSwatch = null;
			
			if (i < members.length) {
				var sprite = members[i];
				if(sprite != null){
					if (Std.is(sprite, FlxUIColorSwatch)) {
						fuics = cast sprite;
						if(fuics.equalsSwatch(list[i]) == false){
							fuics.colors = list[i];
						}
					}
				}
			}
			
			if (fuics == null) {
				fuics = new FlxUIColorSwatch(0, 0, list[i]);
				fuics.id = list[i].name;
				fuics.broadcastToFlxUI = false;
				fuics.callback = selectCallback.bind(i);
				add(fuics);
			}
			
			fuics.visible = true;
			fuics.active = true;
		}
		
		var length:Int = members.length;
		for (i in 0...length) {
			var j:Int = (length - 1) - i;
			var thing:FlxSprite = members[j];
			if (thing != _selectionSprite) {
				if (thing == null) {
					members.splice(j, 1);
				}else if (thing.visible == false && thing.active == false) {
					thing.destroy();
					remove(thing, true);
					thing = null;
				}
			}
		}
		
		_dirtyLayout = true;
		
		add(_selectionSprite);
		
		if (swatchForSelect != null) {
			selectByColors(swatchForSelect, true);
		}else {
			unselect();
		}
	}
	
	public var selectedSwatch(get, null):FlxUIColorSwatch;
	private function get_selectedSwatch():FlxUIColorSwatch {
		return _selectedSwatch;
	}
	private var destroyed:Bool = false;
	public override function destroy():Void {
		destroyed = true;
		_selectedSwatch = null;
		_selectionSprite = null;
		super.destroy();
	}
	
	private function selectCallback(i:Int):Void {
		selectByIndex(i);
		if (broadcastToFlxUI) {
			if (_selectedSwatch != null) {
				if(_selectedSwatch.multiColored){
					FlxUI.event(CLICK_EVENT, this, _selectedSwatch.colors);
				}else {
					FlxUI.event(CLICK_EVENT, this, _selectedSwatch.color);
				}
			}
		}
	}
	
	public function selectByIndex(i:Int):Void {
		_selectedSwatch = cast members[i];
		updateSelected();
	}
	
	public function selectByColor(Color:Int):Void {
		_selectedSwatch = null;
		
		for (sprite in members) {
			if (sprite != _selectedSwatch) {
				var swatch:FlxUIColorSwatch = cast sprite;
				if (swatch.color == Color) {
					_selectedSwatch = swatch;
					break;
				}
			}
		}
		updateSelected();
	}
	
	public function selectByColors(Data:SwatchData, PickClosest:Bool = true, IgnoreInvisible:Bool = true):Void {
		var best_delta:Int = 99999999;
		var curr_delta:Int = 0;
		var best_swatch:FlxUIColorSwatch = null;
		
		_selectedSwatch = null;
		for (sprite in members) {
			if (sprite != _selectionSprite && sprite != _selectedSwatch && sprite.visible == true && sprite.active == true) {
				var swatch:FlxUIColorSwatch = cast sprite;
				var swatchData:SwatchData = swatch.colors;
				if (PickClosest) {
					curr_delta = Data.getRawDifference(swatchData,IgnoreInvisible);
					if (curr_delta < best_delta) {
						best_swatch = swatch;
						best_delta = curr_delta;
					}
				}else {
					if (Data.doColorsEqual(swatchData)) {
						best_swatch = swatch;
						break;
					}
				}
			}
		}
		
		_selectedSwatch = best_swatch;
		
		updateSelected();
	}
	
	public function selectByName(Name:String):Void {
		_selectedSwatch = null;
		
		for (sprite in members) {
			if (sprite != _selectedSwatch) {
				var swatch:FlxUIColorSwatch = cast sprite;
				if (swatch.id == Name) {
					_selectedSwatch = swatch;
					break;
				}
			}
		}
		updateSelected();
	}
	
	public function unselect():Void {
		_selectedSwatch = null;
		updateSelected();
	}
	
	private function updateSelected():Void {
		if (_selectedSwatch != null) {
			_selectionSprite.visible = true;
			_selectionSprite.x = _selectedSwatch.x + ((_selectedSwatch.width  - _selectionSprite.width) / 2);
			_selectionSprite.y = _selectedSwatch.y + ((_selectedSwatch.height - _selectionSprite.height) / 2);
		}else {
			_selectionSprite.visible = false;
		}
	}
	
	private var _selectedSwatch:FlxUIColorSwatch;
	private var _selectionSprite:FlxSprite;
	private var _dirtyLayout:Bool = false;
}