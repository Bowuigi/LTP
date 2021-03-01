#!/usr/bin/luajit

-- Change the first line to the path that has the lua version that has lcurses

Curses=require "curses"

--Split a string into a table separated by Separator
function split(Str, Separator)
	Separator=Separator or '%s'
	local t={}
	for field,s in string.gmatch(Str, "([^"..Separator.."]*)("..Separator.."?)") do
		t[#t+1]=field
		if s=="" then
			return t
		end
	end
end

--Clamp a value to min and max
function clamp(value,min,max)
	return math.min(math.max(min, value),max)
end

--Read from stdin when no file is given
if arg[1] then
	file=io.open(arg[1])
	allFileContent=file:read("*a")
else
	allFileContent=io.read("*a")
end
fileContent=split(allFileContent,"\n")

function main()
	--Init lcurses
	ss=curses.initscr()
	curses.echo(false)
	curses.cbreak()
	ss:keypad(true)
	ss:move(0,0)
	height,width=ss:getmaxyx()
	bufferOffset={x=0,y=0}
	scroll={x=1}

	while true do
		ss:erase()
		
		if k==curses.KEY_UP then bufferOffset.x=bufferOffset.x-1 end
		if k==curses.KEY_DOWN then bufferOffset.x=bufferOffset.x+1 end
		bufferOffset.x=clamp(bufferOffset.x,1,height)

		for i=1,30 do
			ss:mvaddstr(bufferOffset.x+i,0,fileContent[i] or "~")
		end
		ss:move(0,0)
		ss:refresh()
		k=ss:getch()
	end
	curses.endwin()
	os.exit()
end

function err(e)
	curses.endwin()
	print("Error: ",e)
	print(debug.traceback())
	os.exit()
end

xpcall(main,err,err)