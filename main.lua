local compiler= require("compiler")
local interper = require("inter")
local compiled = compiler:compile("+++++[>+++++++<-]>.")
interper:run(compiled)
