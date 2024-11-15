package macros;

#if macro
class IOSMacro
{
    public static function setIOSEnvTable():Void
    {
        Sys.command("export", ["LD_RUNPATH_SEARCH_PATHS=\"$(inherited)", "/usr/lib/swift\""]);
        Sys.command("export", ["LIBRARY_SEARCH_PATHS=\"$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)", "$(TOOLCHAIN_DIR)/usr/lib/swift-5.0/$(PLATFORM_NAME)", "$(inherited)\""]);
    }
}
#end
