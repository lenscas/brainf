local params = {...}
local compiler = require("compiler")
local interper = require("inter")
local possibleParams = {
	["--file"]=true,
	["--brain"]=true,
	["--help"]=true
}
local suppliedParamsAndValue = {}
local nextIsValue=false
for key,value in ipairs(params) do
	if nextIsValue then
		suppliedParamsAndValue[#suppliedParamsAndValue].value=value
		nextIsValue=false
	elseif possibleParams[value] then
		if value =="--help" then
			--the docs, sadly enough I can't intend this properly as that will be printed then as well
			print(
[[
--help		:	print this help
--file	<path>	:	reads a file and runs it
--brain <code>	:	reads code from stdin and runs it
]]
			)
			return
		end
		table.insert(suppliedParamsAndValue,{param=value,value=""})
		nextIsValue=true
	else
		print(value.." Is not a valid param")
		return
	end
end
local code
for key, value in ipairs(suppliedParamsAndValue) do
	if value.param=="--file" then
		local file = io.open(value.value,"r")
		if not file then
			print("Can't open "..value.value)
			return
		end
		code = file:read("*all") --*a reads everything
		file:close()
	elseif value.param == "--brain" then
		if code then
			print("Only supply with either --brain or --file. Not both")
			return
		end
		code = value.value
	end
end
code = code or "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."
local compiled = compiler:compile(code)
interper:run(compiled)
