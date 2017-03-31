local memory = {}
--the memory of the brainf program
memory.stored= {}
--what part of the memory the program can currently access
memory.at= 1
--this changes the part of the memory the program can access
function memory:shift(direction,amount)
	amount = amount or 1
	local addToAt = 1*amount
	if direction=="left" then
		addToAt = -1*amount
	end
	if self.at +addToAt <= 0 then
		error("pointer went too low")
	end
	self.at = self.at+addToAt 
end
--this function is used to get the value of the memory piece the program currenty has access to
function memory:getValueRaw()
	return self.stored[self.at] or 0
end
--add to the memory piece the programm has currently access to. Can be used to subtract instead by using negative numbers
function memory:add(amount)
	self.stored[self.at] = self:getValueRaw()+amount
end
--prints the current piece of memory x times, by default x =1
function memory:print(times)
	times = times or 1
	for i=1,times do
		io.write(string.char(self:getValueRaw()))
	end
end
--gets 1 char of input x times, by default x=1
function memory:getInput(times)
	times = times or 1
	for i=1,times do
		repeat
			local valid = false
			local input = io.read()
			if #input ==1 then
				memory.stored[memory.at] = string.byte(input)
				valid=true
			end
		until(valid)
	end
end
return memory