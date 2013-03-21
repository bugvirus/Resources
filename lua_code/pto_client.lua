
local function db_fmt(value)
	saved = {}
	if type(value) == type({}) then
		local retval = ''
		retval = retval .. '{'
		local visited = {}
		for i, v in ipairs(value) do
			if saved[v] and type(v) == type({}) then
				retval = retval .. '<visited>' .. ', '
			else
				saved[v] = true
				retval = retval .. db_fmt( v, saved ) .. ', '
			end
			visited[i] = true
		end
		for k, v in pairs(value) do
			if visited[k] == nil then
				if saved[v] and type(v) == type({}) then
					retval = retval .. '[' .. db_fmt(k, saved) .. '] = ' .. '<visited>' .. ', '
				else
					saved[v] = true
					retval = retval .. '[' .. db_fmt(k,saved) .. '] = ' .. db_fmt( v,saved ) .. ', '
				end
			end
		end
		retval = retval .. '}'
		return retval 
	elseif type(value) == type('') then
		return(string.format("'%s'",value))
	elseif value ~= nil then
		return(string.format("%s",tostring(value)))					
	elseif value == nil then
		return 'nil'
	end
	return "<unknown>"
end

function print_data(data)
	print(db_fmt(data))
end

for_maker = {}

local function do_add_21card(uid, card_type, card)
	print("server call ", db_fmt(uid), card_type, card)
end

for_maker.c_add_21card = do_add_21card

function tbl_map_to_array(tbl)
	if not tbl or type(tbl)~="table" then return end
	local array = {}
	for k, v in pairs(tbl) do
		local temp = {}
		temp[k] = v
		table.insert(array, temp)
	end

	local function get_key(tbl)
		if not tbl or type(tbl)~="table" then return end
		for k,_ in pairs(tbl) do
			return tostring(k)
		end
	end

	local function compare_func(v1, v2)
		local key1 = get_key(v1)
		local key2 = get_key(v2)
		return key1 < key2
	end
	table.sort(array, compare_func)
	return array
end

function pto_main()
	local tbl, proto = safe_dofile("netpconf.lua")
	for i, v in ipairs(tbl) do
		local _type, _args = safe_dofile(v)
		_args = tbl_map_to_array(_args)
		
		xymodule.load_tb_fmt(_type, _args)
	end
		
	for i, v in ipairs(proto) do
		local _args = safe_dofile(v)
		
		local result = xymodule.load_proto_fmt(v, _args)
		print("load result", result)
	end

	local test_data = {
		["qizhi"] = 1,
		["wuxin"] = "bug",
		["moyi"] = 2,
		["naili"] = 3,
		["neili"] = 4,
	}
	local send_data = {
		[1] = test_data,
	}
	for_caller.s_add_21card(send_data)
end

