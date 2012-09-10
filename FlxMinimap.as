package {
	import flash.display.*;
	import flash.filters.*;
	import flash.geom.*;
	import org.flixel.*;
	
	/**
	 * A simple minimap implementation that centers and scales to the correct size within its bounding box and maintains a list of objects to follow.
	 * 
	 * @author BruceJillis (j.terhove@gmail.com)
	 */
	public class FlxMinimap extends FlxSprite {
		// bitmapdata used drawing and scaling the image of the level
		private var bmd:BitmapData;
		// all the dots currently visible on the minimap (shame there isn't an Object placeholder we can abuse somewhere, now we split the work over 2 arrays)
		private var dots:FlxGroup = new FlxGroup();
		// an array containing all objects that are followed on the minimap
		private var objects:Array = [];
		// scaling factor for the objects to correctly position them on the minimap
		private var sx:Number;
		private var sy:Number;
		// the tilemap we are representing
		private var tilemap:FlxTilemap;
		// internal placeholders for the empty and solid colors
		private var _solidColor:uint = 0xffffff;
		private var _emptyColor:uint = 0x000000;
		// gates if the dots groups has been added to the state
		private var dotsadded:Boolean = false;
		
		public function FlxMinimap(Tilemap:FlxTilemap, X:uint, Y:uint, W:uint, H:uint) {			
			super(X, Y);
			tilemap = Tilemap;
			width = W;
			height = H;
			// don't scroll with the camera
			scrollFactor = new FlxPoint();	
			// read the level data and scale to correct size
			read();
			scaleTo(width, height);			
			// set pixel data
			pixels = bmd;
		}
		
		/**
		 * Stupid hack to add the dots group at the right index (ie. after the minimap itself)
		 */
		override public function preUpdate():void {
			super.preUpdate();
			if (!dotsadded) {
				// wait for the right time to add the dots group (above/after the minimap/this has been added)
				FlxG.state.add(dots);				
			}
		}
		
		/**
		 * Update position to reflect object accurately
		 */
		override public function update():void {
			for (var i:uint = 0; i < objects.length; i++) {
				objects[i][1].x = x + int(objects[i][0].x / sx) - offset.x;
				objects[i][1].y = y + int(objects[i][0].y / sy) - offset.y;
			}
			super.update();
		}
		
		/**
		 * Clean up after ourselves when we get destroyed
		 */
		override public function destroy():void {
			FlxG.state.remove(dots).destroy();
		}		
		
		/**
		 * Refresh the minimap from scratch
		 */
		public function refresh():void {			
			// redo the minimap
			read();
			scaleTo(width, height);			
			// set pixel data
			pixels = bmd;		
		}
		
		/**
		 * Add an object to be followed on the minimap
		 * 
		 * @param	Obj the object to follow
		 * @param	Color the 0xAARRGGBB color of the icon representing the object on the minimap
		 */
		public function follow(Obj:FlxSprite, Color:uint = 0xFFFF0000):void	{
			var dot:FlxSprite = new FlxSprite();
			dot.makeGraphic(3, 3, Color);
			dot.scrollFactor = new FlxPoint();
			dots.add(dot);
			objects.push([Obj, dot]);
		}
		
		/**
		 * Scale bmd to correct size
		 * 
		 * @param	W the width
		 * @param	H the height
		 */
		private function scaleTo(W:uint, H:uint):void {
			// compute scale
			var s:Number = W / tilemap.widthInTiles;
			if (tilemap.heightInTiles > tilemap.widthInTiles) {
				// keep the longest side within the minimap bounds
				s = H / tilemap.heightInTiles;
			}
			// construct the scaling matrix
			var matrix:Matrix = new Matrix();
			matrix.scale(s, s);
			var scaled:BitmapData = new BitmapData(bmd.width * s, bmd.height * s, true, 0xff000000);
			scaled.draw(bmd, matrix, null, null, null, true);
			bmd = scaled;
			// scale factor pre compute for objects
			sx = tilemap.width / bmd.width;
			sy = tilemap.height / bmd.height;
			// offset needed to center the minimap
			offset.x = -((W / 2) - (bmd.width / 2));
			offset.y = -((H / 2) - (bmd.height / 2));
		}
		
		
		/**
		 * Read the data from the tilemap and plot as points on a bitmap
		 */
		private function read():void {
			// draw unscaled
			bmd = new BitmapData(tilemap.widthInTiles, tilemap.heightInTiles, true, 0xff000000);			
			for (var y:int = 0; y < bmd.height; y++) {
				for (var x:int = 0; x < bmd.width; x++) {
					if(tilemap.getTile(x, y) > 0) {
						bmd.setPixel(x, y, solidColor);
					} else {
						bmd.setPixel(x, y, emptyColor);
					}
				}
			}
		}
		
		
		/**
		 * Getter for the color used to indicate a solid tile
		 */
		public function get solidColor():uint {
			return _solidColor;
		}
		
		/**
		 * Setter for the color used to indicate a solid tile
		 */
		public function set solidColor(value:uint):void {
			_solidColor = value;
		}
		
		/**
		 * Getter color used for empty tiles
		 */
		public function get emptyColor():uint {
			return _emptyColor;
		}
		
		/**
		 * Setter for the color used for empty tiles
		 */
		public function set emptyColor(value:uint):void {
			_emptyColor = value;
		}	
	}
}