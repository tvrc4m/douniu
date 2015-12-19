local Menu = class("Menu")
local Buying = require("app.scenes.game.Buying")

function Menu:ctor(game,menu)
    self.parts = {}
    self.parts["menu"] = menu
    self.parts["game"] = game
    self.parts["buying"] =  Buying.new(game) 

    local mask = display.newLayer()
        :addTo(menu,-1)
    -- self.parts["panel"]:setTouchEnabled(false)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function ( ... )
        self:close()
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    mask:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, mask)
    self.parts["mask"] = mask
    self.parts["listener"] = listener
    self.parts["menu"]:getChildByTag(907):setVisible(false)
    self.parts["menu"]:getChildByTag(936):setVisible(false)
    
    self.parts["ctype"] = menu:getChildByTag(119)
    self.parts["ctype"]:setVisible(false)
    self.parts["taskBtn"] = menu:getChildByTag(2)
    for i=1,6 do
        menu:getChildByTag(i):addTouchEventListener(handler(self, self["fun"..i]))
    end

    self.parts["handler"] = app:addEventListener("app.updateTask",function (event)
        if event.data.status > 0 then
            self:timeTask()
        else
            self.parts["animationItem"]:removeSelf()
            -- self.parts["taskBtn"]:removeAllChildren()
            self.parts["taskBtn"]:setOpacity(255)
        end
    end)

   
end

function Menu:timeTask( )
    local timeText = self.parts["menu"]:getChildByTag(351)
    local hour,time
    for i,v in pairs(CONFIG.task) do
        if checkint(v.subtype) == 11 and checkint(v.status) < 2 then
            v.comNum = v.comNum or 0 
            time = v.needNum - v.comNum --还需要多少秒
            local handler_ = schedule(self.parts["menu"],function ( )
                if self.parts["game"].gameStatus ~= 1 then return end
                time = time -1
                if time > 0 then
                    hour = checkint(time/3600)
                    if hour <= 0 then
                        hour = os.date("%M",time)..":"..os.date("%S",time)
                    else
                        hour = hour..":" .. os.date("%M",time)..":"..os.date("%S",time)
                    end
                    timeText:setString(hour)
                else
                    timeText:setString("")
                    self.parts["menu"]:stopAction(handler_)
                    self.parts["taskBtn"]:setOpacity(0)

                    local animationItem = cc.CSLoader:createNode("taskAni.csb")
                        :align(display.CENTER, 1138,654)
                        :addTo(self.parts["menu"])

                    self.parts["animationItem"] = animationItem
                    local tl = cc.CSLoader:createTimeline("taskAni.csb")
                    animationItem:runAction(tl)
                    -- tl:setTimeSpeed(0.05)
                    tl:gotoFrameAndPlay(0,50,true)
                end
            end,1)

            break
        end
    end

end

function Menu:menuLayerFun1(target, event )
    if not self:btnScale(target, event) then return end
end

function Menu:menuLayerFun2(target, event )
    if not self:btnScale(target, event) then return end
end

function Menu:btnScale(target, event )
    if event == 0 then
        target:setScale(0.9)
    elseif event == 3 or event == 2 then
        target:setScale(1)
    end
    if event ~= 2 then return false end
    utils.playSound("click")
    return true
end

function Menu:btnScale(target, event )
    if event == 0 then
        target:setScale(0.9)
    elseif event == 3 or event == 2 then
        target:setScale(1)
    end
    if event ~= 2 then return false end
    utils.playSound("click")
    return true
end
--退出
function Menu:menuLayerFun1(target, event )
    if not self:btnScale(target, event) then return end
    if self.parts["game"].gameStatus == 1 then
        showAutoTip("游戏正在进行中，不能退出房间！")
        return
    end
    self.parts["menuLayer"]:setVisible(false)
    SendCMD:outRoom()
end
--换桌
function Menu:menuLayerFun2(target, event )
    if not self:btnScale(target, event) then return end
    if self.parts["game"].gameStatus == 1 then
        showAutoTip("游戏正在进行中，不能切换房间！")
        return
    end
    self.parts["menuLayer"]:setVisible(false)
    local typeId = 29
    for k,v in pairs(CONFIG.roominfo) do
        if v.min <= USER.gold then
            typeId = v.typeId
        end
    end
    for i,v in ipairs(self.parts["game"].parts["seats"]) do
        if v.model.mid == USER.mid then
            v:reset()
        else
            v:stand()
        end
    end
    SendCMD:quickInRoom(1000,typeId)
end
--out
function Menu:fun1(target, event )
    if not self:btnScale(target, event) then return end
    if checkint(USER.seatid) == 1 then
        showAutoTip("游戏正在进行中，不能退出房间！")
        return
    end
    -- self.parts["menuLayer"]:setVisible(false)
    SendCMD:outRoom()

end
--chat
function Menu:fun2(target, event )
   if not self:btnScale(target, event) then return end
    self.parts["game"].parts["chat-layer"]:show()
end

--输赢历史
function Menu:fun3(target, event )
    if not self:btnScale(target, event) then return end
    local his = self.parts["menu"]:getChildByTag(936)
    his:setVisible(true)
    local model = his:getChildByTag(946)
    local list = his:getChildByTag(945)
    list:removeAllChildren()
    
    local item = model:clone()
    item:setVisible(true)
    list:pushBackCustomItem(item)

    local img = "room100/text/win.png"
    dump(self.parts["game"] .parts["his"])
    for i,v in ipairs(self.parts["game"] .parts["his"]) do
        local item = model:clone()
        item:setVisible(true)
        for j,v1 in ipairs(v) do
            if v1.win == 0 then
                img = "room100/text/lost.png"
            else
                img = "room100/text/win.png"
            end
            item:getChildByTag(j):loadTexture(img,1)
        end
        list:pushBackCustomItem(item)
    end

end

--task
function Menu:fun4(target, event )
    if not self:btnScale(target, event) then return end
    self.parts["task"] = require("app.views.Task").new(function ( ... )
            self.parts["task"] = nil
        end)
end

--card type
function Menu:fun5(target, event )
    if not self:btnScale(target, event) then return end
    self.parts["ctype"]:setVisible(true)
end


--dealer list
function Menu:fun6(target, event )
    if not self:btnScale(target, event) then return end
    local his = self.parts["menu"]:getChildByTag(907)   
    his:setVisible(true)
    local model = his:getChildByTag(908)
    local list = his:getChildByTag(914)
    list:setContentSize(360,display.height)
    list:removeAllChildren()
    
    dump(self.parts["game"].parts["users"])
    for i,v in ipairs(self.parts["game"].parts["users"]) do
        local item = model:clone()
        item:setVisible(true)
        item:getChildByTag(2):setString(v.name)
        item:getChildByTag(3):setString(utils.numAbbrZh(v.gold))
        -- local icon = item:getChildByTag(1)

        -- utils.loadImage(v[2] , function ( succ, ccimage )
        --     if succ then
        --          local ret,errMessage = xpcall(function ( ... )
        --             icon:setTexture(ccimage)
        --             local size = icon:getContentSize()
        --             if size.width > size.height then
        --                 scale = 72/size.width
        --             elseif size.height > size.width then
        --                 scale = 72/size.height
        --             else
        --                 scale = 72/size.height
        --             end
        --             icon:setScale(scale)
        --         end,function ( ... )
        --         end)
        --     end
        -- end)

        -- local size = icon:getContentSize()
        -- if size.width > size.height then
        --     scale = 72/size.width
        -- elseif size.height > size.width then
        --     scale = 72/size.height
        -- else
        --     scale = 72/size.height
        -- end
        -- icon:setScale(scale)

        list:pushBackCustomItem(item)
    end
end


--dealer list
function Menu:fun7(target, event )
    if not self:btnScale(target, event) then return end
    local his = self.parts["menu"]:getChildByTag(476)   
    his:setVisible(true)
    local model = his:getChildByTag(477)
    local list = his:getChildByTag(482)
    list:removeAllChildren()
    
    dump(CONFIG.upDealer)
    for i,v in ipairs(CONFIG.upDealer) do
        local item = model:clone()
        item:setVisible(true)
        item:getChildByTag(2):setString(v.name)
        item:getChildByTag(3):setString(utils.numAbbrZh(v.chipin))
        -- local icon = item:getChildByTag(1)

        -- utils.loadImage(v[2] , function ( succ, ccimage )
        --     if succ then
        --          local ret,errMessage = xpcall(function ( ... )
        --             icon:setTexture(ccimage)
        --             local size = icon:getContentSize()
        --             if size.width > size.height then
        --                 scale = 72/size.width
        --             elseif size.height > size.width then
        --                 scale = 72/size.height
        --             else
        --                 scale = 72/size.height
        --             end
        --             icon:setScale(scale)
        --         end,function ( ... )
        --         end)
        --     end
        -- end)

        -- local size = icon:getContentSize()
        -- if size.width > size.height then
        --     scale = 72/size.width
        -- elseif size.height > size.width then
        --     scale = 72/size.height
        -- else
        --     scale = 72/size.height
        -- end
        -- icon:setScale(scale)

        list:pushBackCustomItem(item)
    end

    local item = target:clone()
    if checkint(USER.seatid) == 1 then
        item:getChildByTag(1):setString("我要下庄")
    else
        item:getChildByTag(1):setString("我要上庄")
    end
    item:addTouchEventListener(handler(self,self.upDealer))
    self.parts["up"] = item
    list:pushBackCustomItem(item)
end

function Menu:upDealer(target, event )
    if not self:btnScale(target, event) then return end
    self.parts["buying"]:show()
end


function Menu:close()
    self:yourTrun()
end

function Menu:yourTrun()
    local flag = false
    if self.parts["game"].parts["chat-layer"].parts["chat"]:isVisible() then
        flag = true
    end
    self.parts["game"].parts["chat-layer"]:hide()

    if self.parts["buying"].parts["sp"]:isVisible() then
        self.parts["buying"].parts["sp"]:setVisible(false)
        flag = true
    end

    if self.parts["menu"]:getChildByTag(936):isVisible() then
        flag = true
    end
    self.parts["menu"]:getChildByTag(936):setVisible(false)
    
    if self.parts["menu"]:getChildByTag(907):isVisible() then
        flag = true
    end
    self.parts["menu"]:getChildByTag(907):setVisible(false)

    if self.parts["ctype"]:isVisible() then
        flag = true
    end
    self.parts["ctype"]:setVisible(false)
    
    if self.parts["task"] then
        self.parts["task"]:hide()
        flag = true
    end
    self.parts["task"] = nil

    return flag
end

return Menu