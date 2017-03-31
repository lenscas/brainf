local comp= {}
comp.indexesOfStartingLoops = {}
comp.compiled = {}
function comp:insertIntoCompiled(char,amount)
	--amount is not always set, in that case it is safe to assume that it is 0
	amount = amount or 0
	-- the loop characters need special tables, lets filter those out
	if char ~= "[" and char ~= "]" then
		--make sure that the amount is higher then 0, then insert the correct table
		if amount >0 then
			table.insert(self.compiled,{char=char,count=amount})
		end
	else
		--we need to compile a loop
		--lets start with the begining of one
		if char=="[" then
			--insert the table representing the start of a loop. 
			--at this point in time we do not know to what index it will be linked to
			table.insert(self.compiled,{char = char,link=0})
			--we then put the key of this loop in this table enabling us to more easily find to what start an end piece of a loop belongs to
			table.insert(self.indexesOfStartingLoops,#self.compiled)
		--now lets compile the end of a loop
		elseif char=="]" then
			--the last value of this table is the place of the nearest opening of a not linked loop
			--we need this as that is what the closed part will be linked to
			local matching = self.indexesOfStartingLoops[#self.indexesOfStartingLoops]
			--now lets insert it
			table.insert(self.compiled,{char=char,link=matching})
			--now that it is inserted we can update the starting of the loop so that it is properly linked to the end
			self.compiled[matching]["link"]  = #self.compiled
			--we now have processed the start as well thus we can remove it from the list of start's that need to be processed
			table.remove(self.indexesOfStartingLoops,#self.indexesOfStartingLoops)
			
		end
	end
end
function comp:compile(str)
	print("compiling:")
	print(str)
	--all the characters that need to be compiled.
	local chars = {[">"]=true,["<"]=true,["+"]=true,["-"]=true,["."]=true,[","]=true,["["]=true,["]"]=true}
	--these 2 are used to be able to compress multiple of the same instructions into 1
	local lastChar  =""
	local lastCount =0
	--loop over the string
	for c in str:gmatch"." do
		--look if the current character is a character that needs to be compiled
		if chars[c] then
			--check if the character can be compressed
			if lastChar == c then
				lastCount = lastCount+1
			else
				--they are not the same, thus lets insert the last character
				self:insertIntoCompiled(lastChar,lastCount)
				--because the loop characters can't be compressed we are not even going to try that
				if c~="[" and c~="]" then
					--mark the lastChar to the current character so that it can be compressed
					lastChar  = c
					lastCount = 1
				else
					--we are dealing with loop characters, remove the lastChar as there is no compression possible and insert the current character directly
					self:insertIntoCompiled(c)
					lastCount=0
					lastChar=""
				end
			end
		end
	end
	--after the loop ends the last character is still waiting to be inserted as the loop marked it to compress it
	self:insertIntoCompiled(lastChar,lastCount)
	print("compiled to:")
	--nicely print the compiled version
	--we use a table to hold it before we print it as that is faster
	local niceCompiledTable = {}
	--loop over the compiled version
	for key,value in ipairs(self.compiled) do
		--we can't print compressed instructions directly
		local addToTable = value
		if type(value)=="table" then
			--the instruction is part of a loop, lets nicely print that
			if value.char=="[" or value.char=="]" then
				addToTable="{char="..value.char.."link="..value.link.."}"
			else
				--it is an compressed instruction, lets nicely print that
				addToTable="{char="..value.char..",count="..value.count.."}"
			end
		end
		--insert the nicely formatted instruction
		table.insert(niceCompiledTable,addToTable)
	end
	--now we actually print it all
	print(table.concat(niceCompiledTable,""))
	return self.compiled
end
return comp
