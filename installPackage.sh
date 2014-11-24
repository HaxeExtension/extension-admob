#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
haxelib remove openfl-admob
haxelib local openfl-admob.zip
