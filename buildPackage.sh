#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
rm -rf project/obj
lime rebuild . ios
rm -rf project/obj
rm -f openfl-admob.zip
zip -0r openfl-admob.zip extension haxelib.json include.xml project ndll dependencies 
