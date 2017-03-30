local memory = {}
memory.stored= {}
memory.at= 1
function memory:shift(direction)
	local addToAt = 1
	if direction=="left" then
		addToAt = -1
	end
	if self.at +addToAt <= 0 then
		error("pointer went too low")
	end
	self.at = self.at+addToAt 
end
function memory:getValueRaw()
	return self.stored[self.at] or 0
end
function memory:add(amount)
	self.stored[self.at] = self:getValueRaw()+amount
end
function memory:print()
	io.write(self:getValueRaw()," ")
	io.write(string.char(self:getValueRaw()))
	io.write("\n")
end
function memory:getInput()
	repeat
		local valid = false
		local input = io.read()
		if #input ==1 then
			memory.stored[memory.at] = string.byte(input)
			valid=true
		end
	until(valid)
end
return memory
