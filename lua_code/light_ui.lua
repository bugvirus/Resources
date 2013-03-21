local MOVE_HORIZON = 0
local MOVE_VERTICAL = 1

clsRowLayout = clsObject:Inherit()

function clsRowLayout:__init__(parent, x, y, desc_info)
	Super(clsRowLayout).__init__(self)

	self._RootPanel = CCLayer:create()
	self._RootPanel:setAnchorPoint(CCPointMake(0, 1))

	if parent then
		parent:addChild(self._RootPanel)
		self._RootPanel:setPosition(x, y)
	end

	self._item_width = desc_info["item_width"]
	self._item_height = desc_info["item_height"]
	self._column_cnt = desc_info["column_cnt"]
	self._x_space = desc_info["x_space"]
	self._y_space = desc_info["y_space"]

	self._view_item_list = {}
	self._item_list = {} 
end

function clsRowLayout:getCOObj()
	return self._RootPanel
end

function clsRowLayout:getPosition()
	return self._RootPanel:getPosition()
end

function clsRowLayout:setPosition(x, y)
	self._RootPanel:setPosition(x, y)
end

function clsRowLayout:cal_pos_by_ij(i, j)
	return (j-1) * (self._item_width + self._x_space), -(i-1) * (self._item_height + self._y_space)
end

function clsRowLayout:append_item(item)
	table.insert(self._item_list, item)
	local COObj = item:getCOObj()
	self._RootPanel:addChild(COObj)
	COObj:setAnchorPoint(CCPointMake(0, 1))
	COObj:setPosition(0, 0)
	COObj:setVisible(false)
	return item 
end

function clsRowLayout:get_item(row, column)
	local idx = (row-1) * self._column_cnt + column
	item_cnt = table.maxn(self._item_list)
	if (item_cnt <= 0) then
		return nil 
	end
	if (item_cnt >= idx) then
		return self._item_list[idx]
	else
		return nil 
	end
end

function clsRowLayout:get_item_by_func(func)
	for _, item in ipairs(self._item_list) do
		if func(item) then
			return item
		end
	end

	return nil
end

function clsRowLayout:_get_append_row(append_list)
	local row_cnt = table.maxn(append_list)
	if row_cnt <= 0 then
		return 1 
	end

	local last_row = append_list[row_cnt]
	local last_row_item_cnt = table.maxn(last_row)
	if last_row_item_cnt < self._column_cnt then
		return row_cnt
	else
		return row_cnt + 1
	end
end

function clsRowLayout:_do_append_item(item, append_list)
	local append_row = self:_get_append_row(append_list)
	local row_cnt = table.maxn(append_list)
	if row_cnt < append_row then
		table.insert(append_list, {})
	end

	local row_info = append_list[append_row]
	table.insert(row_info, item)
end

function clsRowLayout:hideAll()
	for _, item in ipairs(self._item_list) do
		item:getCOObj():setVisible(false)
		item:getCOObj():setPosition(0, 0)
	end
end

function clsRowLayout:filter_item()
	self._view_item_list = {} 
	for _, item in ipairs(self._item_list) do
		self:_do_append_item(item, self._view_item_list)
	end
end

function clsRowLayout:refresh_view()
	self._view_item_list = {}
	self:hideAll()
	self:filter_item()
	for row_idx, row_info in ipairs(self._view_item_list) do
		for column_idx, item in ipairs(row_info) do
			local x, y = self:cal_pos_by_ij(row_idx, column_idx)
			item:getCOObj():setPosition(x, y)
			item:getCOObj():setVisible(true)
		end
	end
end

function clsRowLayout:get_size()
	local row_cnt = table.maxn(self._view_item_list)
	return self._column_cnt * (self._item_width + self._x_space), row_cnt * (self._item_height + self._y_space) + self._extra_height
end
--------------------------------------------------------------------------
clsSimpleButton = clsObject:Inherit()

function clsSimpleButton:__init__(parent, x, y, normal_pic, click_pic)
	local menuItem = CCMenuItemImage:create(normal_pic, click_pic)
        local function onTouch(eventType, x, y)
		if eventType == CCTOUCHBEGAN then
			self:onTouchBegan(x, y)
			return true
		elseif eventType == CCTOUCHMOVED then
			self:onTouchMove(x, y)
			return nil
		else
			self:onTouchEnd(x, y)
			return nil
		end
        end
	menuItem:setPosition(0, 0)
	self._BtnObj = CCMenu:createWithItem(menuItem)
	self._BtnObj:registerScriptTouchHandler(onTouch, false, 0, true)
end

function clsSimpleButton:getCOObj()
	return self._BtnObj
end

function clsSimpleButton:onTouchBegan(x, y)
end

function clsSimpleButton:onTouchMove(x, y)
end

function clsSimpleButton:onTouchEnd(x, y)
end
-------------------------------------------------------------
clsLabel = clsObject:Inherit()

function clsLabel:__init__(parent, x, y, text)
	self._RootLabel = CCLabelTTF:create(text, "Arial", 16)
	if parent then
		parent:addChild(self._RootLabel)
		self._RootLabel:setPosition(x, y)
	end
end

function clsLabel:getCOObj()
	return self._RootLabel
end

function clsLabel:setColor(r, g, b)
	self._RootLabel:setColor(ccc3(r, g, b))
end
------------------------------------------------------------------------
local time_interval = 1/60
function aniMovePanel(obj, initVelocity, mul_factor, acc, move_limit)
	acc = acc * mul_factor
	local begin_x, begin_y = obj:getCOObj():getPosition()
	local tmp_begin_value = nil 
	local inc_value = nil
	if (obj._move_type == MOVE_HORIZON) then
		tmp_begin_value = begin_x
		inc_value = begin_x
	else
		tmp_begin_value = begin_y
		inc_value = begin_y
	end
	local cb_handle = nil
	tmp_velocity = initVelocity
	local function do_move()
		inc_value = inc_value + tmp_velocity * time_interval
		if math.abs(inc_value - tmp_begin_value) >= move_limit then
			inc_value = tmp_begin_value + (-1) * mul_factor * move_limit
		end
		if (obj._move_type == MOVE_HORIZON) then
			obj:getCOObj():setPosition(math.floor(inc_value), begin_y)
		else
			obj:getCOObj():setPosition(begin_x, math.floor(inc_value))
		end
		tmp_velocity = tmp_velocity + acc * time_interval
		if (tmp_velocity*initVelocity) <= 0 or math.abs(inc_value - tmp_begin_value) >= move_limit then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(cb_handle)
			obj._is_moving = false
			obj:onMoveEnd()
		end
	end
	if math.abs(initVelocity) > 0 then
		cb_handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(do_move, time_interval, false)
		obj._is_moving = true
	end
end
-----------------------------------------------------------------------
clsMoveGroup = clsObject:Inherit()

function clsMoveGroup:onMoveGroupTouchBegan(x, y)
	if (self._move_type == MOVE_HORIZON) then
		self._begin_value = x
	else
		self._begin_value = y
	end
	self._begin_time = httpMainModule.gettimeofdayCocos2d()
end

function clsMoveGroup:onMoveGroupTouchMove(x, y)
end

function clsMoveGroup:onMoveGroupTouchEnd(x, y)
	if (self._move_type == MOVE_HORIZON) then
		self._end_value = x
	else
		self._end_value = y
	end
	self._end_time = httpMainModule.gettimeofdayCocos2d()
	velocity = (self._end_value - self._begin_value)*1000000 / (self._end_time - self._begin_time)
	local mul_factor = 1
	if velocity > 0 then
		mul_factor = -1
	end
	if not self._is_moving then
		aniMovePanel(self, velocity, mul_factor, 0, 500)
	end
end

function clsMoveGroup:__init__(parent, x, y)
        local function onTouch(eventType, x, y)
		print(eventType, x, y)
		if eventType == CCTOUCHBEGAN then
			self:onMoveGroupTouchBegan(x, y)
			return true
		elseif eventType == CCTOUCHMOVED then
			return self:onMoveGroupTouchMove(x, y)
		else
			return self:onMoveGroupTouchEnd(x, y)
		end
        end

	self._RootPanel = CCLayer:create()
        self._RootPanel:registerScriptTouchHandler(onTouch, false, 0, true)
        self._RootPanel:setTouchEnabled(true)
	self._item_list = {}
	self._is_moving = false
	self._move_type = MOVE_HORIZON

	if parent then
		parent:addChild(self._RootPanel)
		self._RootPanel:setPosition(x, y)
	end
end

function clsMoveGroup:isMoving()
	return self._is_moving
end

function clsMoveGroup:setMoveVertical()
	self._move_type = MOVE_VERTICAL
end

local autoMoveVelocity = 600
function clsMoveGroup:moveToLeft()
	if not self._is_moving then
		self._move_type = MOVE_HORIZON
		aniMovePanel(self, -autoMoveVelocity, 1, 0, 500)
	end
end

function clsMoveGroup:moveToRight()
	if not self._is_moving then
		self._move_type = MOVE_HORIZON
		aniMovePanel(self, autoMoveVelocity, -1, 0, 500)
	end
end

function clsMoveGroup:onMoveEnd()
end

function clsMoveGroup:getCOObj()
	return self._RootPanel
end

function clsMoveGroup:appendItem(item, x, y)
	table.insert(self._item_list, item)
	self._RootPanel:addChild(item:getCOObj())
	item:getCOObj():setPosition(x, y)
end
----------------------------------------------------
clsAttachMoveGroup = clsMoveGroup:Inherit()

function clsAttachMoveGroup:__init__(parent, x, y)
	Super(clsAttachMoveGroup).__init__(self, parent, x, y)
end

function clsAttachMoveGroup:onMoveGroupTouchBegan(x, y)
	self._begin_obj_x, self._begin_obj_y = self:getCOObj():getPosition()
	self._begin_touch_x, self._begin_touch_y = x, y
end

function clsAttachMoveGroup:onMoveGroupTouchMove(x, y)
	local inc_x = x - self._begin_touch_x
	local inc_y = y - self._begin_touch_y
	if (self._move_type == MOVE_HORIZON) then
		self:getCOObj():setPosition(self._begin_obj_x + inc_x, self._begin_obj_y)
	else
		self:getCOObj():setPosition(self._begin_obj_x, self._begin_obj_y + inc_y)
	end
end

function clsAttachMoveGroup:onMoveGroupTouchEnd(x, y)
end

clsNode = clsObject:Inherit()

function clsNode:__init__(parent, x, y)
	self._RootNode = CCNode:create()
	if parent then
		parent:addChild(self._RootNode)
		self._RootNode:setPosition(x, y)
	end
end

function clsNode:getCOObj()
	return self._RootNode
end

