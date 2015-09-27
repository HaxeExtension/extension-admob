#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
haxelib remove extension-admob
haxelib local extension-admob.zip
