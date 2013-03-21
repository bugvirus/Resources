------------------------------------------------- dice scene code
local BeginY = 536 
local item_width = 91
local item_height = 125 
local column_cnt = 3
local y_gap = 45 

local screen_width = 480
local screen_height = 640 

local dice_panel = nil

local login_txt = nil
local login_sid = nil
local login_name = nil

local function create_player_info(player_info)
	local small_img = player_info["small"]
	local large_img = player_info["large"]
	local logo_img = player_info["logo"]
	local replies = player_info["replys"]
	local user_sex = player_info["sex"]
	local user_name = player_info["name"]
	local user_id = player_info["id"]
	local content = player_info["content"]
	local name_txt = LIGHT_UI.clsLabel:New(nil, 0, 0, user_name .. ": " .. content)
	name_txt:setColor(100,200,0)
	return name_txt
end

local function on_back(obj, x, y)
	dice_panel._move_player_grp:getCOObj():setVisible(false)
	dice_panel._move_player_grp:getCOObj():setTouchEnabled(false)
	dice_panel._back_btn:getCOObj():setVisible(false)
	dice_panel._move_group:getCOObj():setVisible(true)
	dice_panel._move_group:getCOObj():setTouchEnabled(true)
	login_txt:setVisible(true)
end

local function do_create_player_info_list(player_list)
	local desc_info = {
		item_width = 94,
		item_height = 94,
		column_cnt = 1,
		x_space = 20,
		y_space = 20,
	}
	local player_row_layout = LIGHT_UI.clsRowLayout:New(nil, 0, 0, desc_info)

	for _, player_info in pairs(player_list) do
		local player_item = create_player_info(player_info)
		player_row_layout:append_item(player_item)
	end
	
	player_row_layout:refresh_view()

	local move_grp = LIGHT_UI.clsAttachMoveGroup:New(nil, 0, 0)
	move_grp:appendItem(player_row_layout, 0, 0)
	dice_panel._move_player_grp = move_grp
	dice_panel:addChild(move_grp:getCOObj())
	move_grp:getCOObj():setPosition(30, 600)
	move_grp:setMoveVertical()

	dice_panel._back_btn = LIGHT_UI.clsSimpleButton:New(nil, 0, 0, "sz_off.png", "sz_off.png")
	--dice_panel._back_btn = LIGHT_UI.clsSimpleButton:New(nil, 0, 0, "test.jpg", "test.jpg")
	dice_panel._back_btn.onTouchEnd = on_back
	dice_panel._back_btn:getCOObj():setPosition(420, 60)
	dice_panel:addChild(dice_panel._back_btn:getCOObj())
end

local function pic_response_cb(data)
        local test_pic = CCSprite:createWithJPGBuffer(data, string.len(data))
	test_pic:setPosition(100, 100)
	dice_panel:addChild(test_pic)
end

local rec_data = "" 
local function say_response_cb(data)
	local data_tbl = json.decode(data)
	do_create_player_info_list(data_tbl["data"])
end

local function login_response_cb(data)
	print("oooo",data)
	rec_data = rec_data .. data
	local data_sum_len = string.len(rec_data)
	local end_str = string.sub(rec_data, data_sum_len-3,data_sum_len)
	--[[if end_str ~= "\r\n\r\n" then
		return
	end]]
	--local real_data = string.sub(rec_data, 1, data_sum_len - 7)
	local real_data = data
	rec_data = ""
	local data_tbl = json.decode(real_data)
	login_sid = data_tbl.sid
	login_name = data_tbl["data"]["name"]
	login_txt:setString("login success " .. login_name)
end

local function pic_click_func(obj, x, y)
	local url_str = string.format("http://saiyou.mobi/frontend/logo/7/237/50ffb3e5b361e.jpg.s.jpg")
	libcurl.lcurl_http_request(url_str, pic_response_cb)
end

local function default_click_func(obj, x, y)
	return nil
end

local function on_say_click_func(obj, x, y)
	if dice_panel._move_group:isMoving() then
		return
	end

	if dice_panel._move_player_grp then
		dice_panel._move_player_grp:getCOObj():setVisible(true)
		dice_panel._move_player_grp:getCOObj():setTouchEnabled(true)
		dice_panel._back_btn:getCOObj():setVisible(true)
		dice_panel._move_group:getCOObj():setVisible(false)
		dice_panel._move_group:getCOObj():setTouchEnabled(false)
		login_txt:setVisible(false)
		return
	end

	local url_str = string.format("http://touyou.mobi/interface/comment.php?type=lists&&sid=%s",login_sid)
	if libcurl.lcurl_http_request(url_str, say_response_cb) then
		--dice_panel._move_group:moveToRight()
		dice_panel._move_group:getCOObj():setVisible(false)
		dice_panel._move_group:getCOObj():setTouchEnabled(false)
		login_txt:setVisible(false)
	end
	return nil
end

local btn_list_info1 = {
	[1] = {
		["normal_res"] = "challengehall_bt_default.png",
		["selected_res"] = "challengehall_bt_selected.png",
		["dis_txt"] = "挑战大厅",
		["on_click_func"] = pic_click_func,
	},
	[2] = {
		["normal_res"] = "yj_on.png",
		["selected_res"] = "yj_off.png",
		["dis_txt"] = "骰魔大赛",
		["on_click_func"] = default_click_func,
	},
	[3] = {
		["normal_res"] = "tc_on.png",
		["selected_res"] = "tc_off.png",
		["dis_txt"] = "排行榜",
		["on_click_func"] = default_click_func,
	},
	[4] = {
		["normal_res"] = "sl_on.png",
		["selected_res"] = "sl_off.png",
		["dis_txt"] = "说两句",
		["on_click_func"] = on_say_click_func,
	},
	[5] = {
		["normal_res"] = "kxp_on.png",
		["selected_res"] = "kxp_off.png",
		["dis_txt"] = "看相打分",
		["on_click_func"] = default_click_func,
	},
	[6] = {
		["normal_res"] = "rw_on.png",
		["selected_res"] = "rw_off.png",
		["dis_txt"] = "任务",
		["on_click_func"] = default_click_func,
	},
	[7] = {
		["normal_res"] = "extract_awards_default.png",
		["selected_res"] = "extract_awards_selected.png",
		["dis_txt"] = "幸运转盘",
		["on_click_func"] = default_click_func,
	},
	[8] = {
		["normal_res"] = "dj_on.png",
		["selected_res"] = "dj_off.png",
		["dis_txt"] = "商城",
		["on_click_func"] = default_click_func,
	},
	[9] = {
		["normal_res"] = "activity_default.png",
		["selected_res"] = "activity_selected.png",
		["dis_txt"] = "活动优惠",
		["on_click_func"] = default_click_func,
	},
}

local btn_list_info2 = {
	[1] = {
		["normal_res"] = "myhome_default.png",
		["selected_res"] = "myhome_selected.png",
		["dis_txt"] = "个人主页",
		["on_click_func"] = default_click_func,
	},
	[2] = {
		["normal_res"] = "zj_off.png",
		["selected_res"] = "zj_on.png",
		["dis_txt"] = "自己玩玩",
		["on_click_func"] = default_click_func,
	},
	[3] = {
		["normal_res"] = "sz_off.png",
		["selected_res"] = "sz_on.png",
		["dis_txt"] = "setting",
		["on_click_func"] = default_click_func,
	},
}

local function doCreateBtnList(row_layout, btn_list_info)
	for tag, btn_info in ipairs(btn_list_info) do
		local nodeObj = LIGHT_UI.clsNode:New(nil, 0, 0)
		local BtnObj = LIGHT_UI.clsSimpleButton:New(nil, 0, 0, btn_info["normal_res"], btn_info["selected_res"])
		BtnObj.onTouchEnd = btn_info["on_click_func"] 
		BtnObj:getCOObj():setPosition(0,0)
		nodeObj:getCOObj():addChild(BtnObj:getCOObj())

		local txt = CCLabelTTF:create(btn_info["dis_txt"], "Arial", 21)
		txt:setPosition(0, -60)
		nodeObj:getCOObj():addChild(txt)

		row_layout:append_item(nodeObj)
	end
end

local function onMoveEnd(move_obj)
	--libcurl.lcurl_http_request("http://touyou.mobi/interface/comment.php?type=lists&&sid=375b977edcfac03b1ce94e6ef789fb353b010386", response_cb)
end

local function createBtnList(parent)
	local desc_info = {
		item_width = 94,
		item_height = 94,
		column_cnt = 3,
		x_space = 20,
		y_space = 40,
	}

	row_layout1 = LIGHT_UI.clsRowLayout:New(nil, 0, 0, desc_info)
	doCreateBtnList(row_layout1, btn_list_info1)
	row_layout1:refresh_view()

	row_layout2 = LIGHT_UI.clsRowLayout:New(nil, 0, 0, desc_info)
	doCreateBtnList(row_layout2, btn_list_info2)
	row_layout2:refresh_view()

	parent._move_group = LIGHT_UI.clsMoveGroup:New(parent, 130, 500)
	parent._move_group:appendItem(row_layout1, 0, 0)
	parent._move_group:appendItem(row_layout2, 500, 0)
	parent._move_group.onMoveEnd = onMoveEnd
end


local function createBGPanel()
	local winSize = CCDirector:sharedDirector():getWinSize()
        local bg_layer = CCClipLayer:create()
	bg_layer:set_msg_rect(0, 0, 480, 640)
        --bg_layer._bg_pic = CCSprite:create("bg.png")
        --bg_layer._bg_pic:setPosition((winSize.width / 2), winSize.height / 2)
        --bg_layer:addChild(bg_layer._bg_pic)
	bg_layer:setPosition(0,0)
	createBtnList(bg_layer)
	login_txt = CCLabelTTF:create("", "Arial", 21)
	login_txt:setPosition(100, 100)
	login_txt:setColor(ccc3(128,138,0))
	bg_layer:addChild(login_txt)

	return bg_layer
end

local function create_dice_main()
	local dice_scene = CCScene:create()
	dice_panel = createBGPanel()
	dice_scene:addChild(dice_panel)
	CCDirector:sharedDirector():runWithScene(dice_scene)
end

local function msg_test()
	local dice_scene = CCScene:create()
	local msg_layer1 = CCLayer:create()
	local msg_layer2 = CCLayer:create()
        local function onTouch1(eventType, x, y)
		if eventType == CCTOUCHBEGAN then
			return true
		elseif eventType == CCTOUCHMOVED then
			return nil
		else
			return nil
		end
        end
        local function onTouch2(eventType, x, y)
		if eventType == CCTOUCHBEGAN then
			return true
		elseif eventType == CCTOUCHMOVED then
			return nil
		else
			return nil
		end
        end
	dice_scene:addChild(msg_layer1)
	msg_layer1:addChild(msg_layer2)
	msg_layer2:registerScriptTouchHandler(onTouch2, false, 0, true)
	msg_layer2:setTouchEnabled(true)
	msg_layer1:registerScriptTouchHandler(onTouch1)
	msg_layer1:setTouchEnabled(true)
	CCDirector:sharedDirector():runWithScene(dice_scene)

end

local function test_pos()
	local dice_scene = CCScene:create()
	local bg_panel = CCLayer:create()
	local BtnObj = LIGHT_UI.clsSimpleButton:New(nil, 0, 0, "challengehall_bt_default.png","challengehall_bt_default.png")
	BtnObj:getCOObj():setPosition(0,0)
	bg_panel:addChild(BtnObj:getCOObj())
	bg_panel:setPosition(100, 0)
	dice_scene:addChild(bg_panel)
	CCDirector:sharedDirector():runWithScene(dice_scene)
end
---------------------------------------------------------------------

function http_main()
	libcurl.lcurl_http_request("http://www.touyou.mobi/interface/user.php?type=logon&name=ddb&pass=1234&version=28", login_response_cb)
	create_dice_main()
	--test_pos()
	--FARM_PANEL.create_scene()
	--msg_test()
end

