local inter = {}
--the memory for the brainf program
inter.memory = require("memory")
--this will hold the program
inter.program={}
--hodls at what instruction the interperter is currently at
inter.at = 1
--this moves the instruction pointer by 1 to dir
function inter:moveChar(dir)
	dir = dir or "right"
	if dir =="right" then
		self.at=self.at+1
	elseif dir=="left" then
		self.at=inter.at-1
	end
	if self.at <= 0 then
		return false
	elseif self.at > #self.program then
		return false
	end
	return true
end
--this is just here to nicely get the current instruction
function inter:getCurChar()
	return self.program[inter.at] 
end
--this is the old method to "jump" to diffrent parts of the loop
function inter:jumpToMatch(searchFor)
	searchFor = searchFor or "["
	local foundOtherSymbol = 0
	repeat
		local hasJumped = false
		if searchFor=="]" then
			self:moveChar()
		elseif searchFor=="[" then
			self:moveChar("left")
		else 
			error("Not a valid jump char")
		end
		--check if found
		local char = self:getCurChar()
		if char == searchFor and foundOtherSymbol ==0 then
			hasJumped =true
		elseif searchFor =="[" and char=="]" then
			foundOtherSymbol = foundOtherSymbol+1
		elseif searchFor=="]" and char=="[" then
			foundOtherSymbol=foundOtherSymbol+1
		else
			
		end
	until(hasJumped)
end
--this checks if the programneeds to make a jump and does so if needed
function inter:checkJump(stayAtChar,data)
	stayAtChar = stayAtChar or false
	local num= inter.memory:getValueRaw()
	if stayAtChar then
		if num ~=0 then
			self.at=data.link
		end
	else
		if num ==0 then
			self.at= data.link
		end
	end
end
--this loads the program and runs it
function inter:run(prog)
	self.program = prog
	local commands = {
		[">"]=function(inter) inter.memory:shift("right") end,
		["<"]=function(inter) inter.memory:shift("left") end,
		["+"]=function(inter) inter.memory:add(1) end,
		["-"]=function(inter) inter.memory:add(-1) end,
		["."]=function(inter) inter.memory:print(); end,
		[","]=function(inter) inter.memory:getInput() end,
		["["]=function(inter) inter:checkJump()  end,
		["]"]=function(inter) inter:checkJump(true) end,
	}
	local shortenedChars = {
		[">"]=function(inter,data) inter.memory:shift("right",data.count) end,
		["<"]=function(inter,data) inter.memory:shift("left",data.count) end,
		["+"]=function(inter,data) inter.memory:add(data.count)end,
		["-"]=function(inter,data) inter.memory:add(data.count*-1) end,
		["."]=function(inter,data) inter.memory:print(data.count); end,
		[","]=function(inter,data) inter.memory:getInput(data.count) end,
		["["]=function(inter,data) inter:checkJump(false,data) end,
		["]"]=function(inter,data) inter:checkJump(true,data) end
	}
	print("running")
	repeat
		local reachedEnd=false
		local atChar = self:getCurChar()
		if commands[atChar] then
			commands[atChar](self)
		elseif type(atChar) =="table" then
			if shortenedChars[atChar.char] then
				shortenedChars[atChar.char](self,atChar)
			end
		else
			print(type(atChar))
			print(atChar.char)
			error("not comipiled correctly!")
		end
		if not self:moveChar() then
			reachedEnd = true
		end
	until(reachedEnd)
	print("Done")
end
return inter