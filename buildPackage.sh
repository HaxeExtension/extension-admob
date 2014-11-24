#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
rm -f openfl-admob.zip
zip -0r openfl-admob.zip extension haxelib.json include.xml project ndll dependencies 
