package;

import admob.Admob;

/**
 * The entry point of the application.
 */
class Main extends lime.app.Application
{
	// This is an ad unit ID for a test ad. Replace with your own banner ad unit ID.
	private static final AD_UNIT_ID:String = "ca-app-pub-3940256099942544/9214589741";

	public function new():Void
	{
		super();

		Admob.onStatus.add(function(event:String, message:String):Void
		{
			if (event == Admob.INIT_OK)
				Admob.showBanner(AD_UNIT_ID);

			lime.utils.Log.info('$event:$message');
		});

		Admob.init(true);
	}

	public override function render(context:lime.graphics.RenderContext):Void
	{
		switch (context.type)
		{
			case CAIRO:
				context.cairo.setSourceRGB(0.75, 1, 0);
				context.cairo.paint();
			case CANVAS:
				context.canvas2D.fillStyle = '#BFFF00';
				context.canvas2D.fillRect(0, 0, window.width, window.height);
			case DOM:
				context.dom.style.backgroundColor = '#BFFF00';
			case FLASH:
				context.flash.graphics.beginFill(0xBFFF00);
				context.flash.graphics.drawRect(0, 0, window.width, window.height);
			case OPENGL | OPENGLES | WEBGL:
				context.webgl.clearColor(0.75, 1, 0, 1);
				context.webgl.clear(context.webgl.COLOR_BUFFER_BIT);
			default:
		}
	}
}
