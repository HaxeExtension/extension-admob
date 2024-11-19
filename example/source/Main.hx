package;

class Main extends lime.app.Application
{
	private static final AD_UNIT_ID:String = "ca-app-pub-3940256099942544/9214589741";

	public function new():Void
	{
		super();

		admob.Admob.onStatus.add(function(event:String, message:String):Void
		{
			if (event == admob.AdmobEvent.INIT_OK)
				admob.Admob.showBanner(AD_UNIT_ID, admob.AdmobBannerSize.BANNER, admob.AdmobBannerAlign.TOP);

			#if android
			android.widget.Toast.makeText(message.length > 0 ? '$event:$message' : event, android.widget.Toast.LENGTH_SHORT);
			#else
			lime.utils.Log.info(message.length > 0 ? '$event:$message' : event);
			#end
		});
	}

	public override function onWindowCreate():Void
	{
		admob.Admob.init(true);
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
