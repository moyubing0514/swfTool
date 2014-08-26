package {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class Main extends Sprite {
		public function Main() {
			// Draw a square and add it to the display list.
			var square : Shape = new Shape();
			square.graphics.lineStyle(1, 0x000000);
			square.graphics.beginFill(0xff0000);
			square.graphics.drawRect(0, 0, 100, 100);
			square.graphics.endFill();
			this.addChild(square);

			// Draw a circle and add it to the display list.
			var circle : Sprite = new Sprite();
			circle.graphics.lineStyle(1, 0x000000);
			circle.graphics.beginFill(0x0000ff);
			circle.graphics.drawCircle(25, 25, 25);
			circle.graphics.endFill();
			this.addChild(circle);

			function maskSquare(event : MouseEvent) : void {
				square.mask = circle;
				circle.removeEventListener(MouseEvent.CLICK, maskSquare);
			}

			circle.addEventListener(MouseEvent.CLICK, maskSquare);
		}
	}
}
