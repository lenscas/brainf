local comp= {}
function comp:compile(str)
	print("compiling:")
	print(str)
	local compiled= {}
	local chars = {[">"]=true,["<"]=true,["+"]=true,["-"]=true,["."]=true,[","]=true,["["]=true,["]"]=true}
	local lastSpecialChar  =""
	local lastSpecialCount =0
	local indexesOfStartingLoops={}
	for c in str:gmatch"." do
		if chars[c] then
			if lastSpecialChar == c then
				lastSpecialCount = lastSpecialCount+1
			else 
				if lastSpecialCount > 1 then 
					table.insert(compiled,{char=lastSpecialChar,count=lastSpecialCount})
				elseif lastSpecialCount == 1 then
					table.insert(compiled,lastSpecialChar)
				end
				if c =="+" or c=="-" then
					lastSpecialChar = c
					lastSpecialCount=1
				else
					if c=="[" then
						table.insert(compiled,{char=c,link=0})
						table.insert(indexesOfStartingLoops,#compiled)
					elseif c=="]" then
						local linkedTo = indexesOfStartingLoops[#indexesOfStartingLoops]
						table.insert(compiled,{char=c,link=linkedTo})
						--we now need to update the start of the loop with the end
						compiled[linkedTo].link = #compiled
						table.remove(indexesOfStartingLoops,#indexesOfStartingLoops)
					else
						table.insert(compiled,c)
					end
					lastSpecialCount=0
				end
			end
		end
	end
	print("compiled to:")
	--print(unpack(compiled))
	local niceCompiledTable = {}
	for key,value in ipairs(compiled) do
		local addToTable = value
		if type(value)=="table" then
			if value.char=="+" or value.char=="-" then
				addToTable="{char="..value.char..",amount="..value.count.."}"
			else
				addToTable="{char="..value.char.."link="..value.link.."}"
			end
		end
		table.insert(niceCompiledTable,addToTable)
	end
	print(table.concat(niceCompiledTable))
	return compiled
end
return comp
