-- for CCLuaEngine traceback

function safe_dofile(fname)
	local file_str = xymodule.get_lua_str(fname)
	local func, msg = loadstring(file_str)
	return setfenv(func, _G)()
end

safe_dofile("import.lua")
safe_dofile("class.lua")

function __G__TRACKBACK__(msg)
	xymodule.print_android_str(msg)
	xymodule.print_android_str(debug.traceback())
	print("----------------------------------------")
	print("LUA ERROR: " .. tostring(msg) .. "\n")
	print(debug.traceback())
	print("----------------------------------------")
end

local cclog = function(...)
	print(string.format(...))
end

-------------------------------------------------------------------------
HTTP_CLIENT = Import("lua_code/http_client.lua")
PTO_CLIENT = Import("lua_code/pto_client.lua")
LIGHT_UI = Import("lua_code/light_ui.lua")
FARM_PANEL = Import("lua_code/farm_panel.lua")

--local cb = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(test, 1, false)

local function main()
	--print(httpMainModule.gettimeofdayCocos2d())
	HTTP_CLIENT.http_main()
end


xpcall(main, __G__TRACKBACK__)

