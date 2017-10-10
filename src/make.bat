if NOT EXIST build mkdir build
if NOT EXIST build\debug mkdir build\debug
if NOT EXIST build\release mkdir build\release
call admb -g fm.tpl 
copy fm.exe build\debug
call admb -f fm.tpl 
copy fm.exe build\release

