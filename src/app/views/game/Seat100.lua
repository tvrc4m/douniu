local Seat = class("Seat")


function Seat:ctor(sp,id)
    self.parts ={}
    self.parts["seat"] = sp
    self.parts["cards"] = {}
    
    -- sp:setVisible(false)

    local key = {"chipin","niu","total"}
    local scale = 1
    for i=1,8 do
        if i <= 5 then
            if id ~= 3 then
                scale = 0.53
            end
            self.parts["card"..i] = Card100.new({batchnode = self.parts["seat"]:getChildByTag(i),scale = scale}) 
        else
            self.parts[key[i-5]] = sp:getChildByTag(i)
        end
    end
    self:setCardsVisible(false)

    self.parts["niu"].label = self.parts["niu"]:getChildByTag(1)
    self.model = {
                mid = 0,
                icon = "",
                name = "",
                seatid = id,
                baseId = id
            }

    local head = utils.makeAvatar()
    self.parts["seat"]:addChild(head,-1)
    self.parts["head"]  = head 
    head:setPosition(120,120)
    self:reset()
end

function Seat:changePic(pic_path)
    -- dump(pic_path)
    self.parts["head"]:setVisible(true)
    if #pic_path > 0 then
        
        utils.loadRemote(self.parts["head"].pic,pic_path,function ( succ,texture )
             if not succ then return end
            self.parts["head"].pic:setTexture(texture)
            transition.fadeIn(self.parts["head"].pic,{time = .2})
        end)
    else
        self.parts["head"].pic:setTexture(cc.Director:getInstance():getTextureCache():getTextureForKey("default.png"))
    end
end

function Seat:setCardsVisible(flag)
    for i=1,5 do
        self.parts["card"..i].sp:setVisible(flag)
        if not flag then
            self.parts["card"..i]:changeVal("-")
        end
    end
end

function Seat:changeChpin(gold)
    self.parts["chipin"]:setString(utils.numAbbrZh(gold))
end

function Seat:changeName(gold)
    self.parts["total"]:setString(utils.numAbbrZh(gold))
end

function Seat:addGold(gold,parent)
    local c = Chip:new(point.x + math.random(10,160),point.y + math.random(10,170),parent)
end


function Seat:setCardsVisible(flag)
    for i=1,5 do
        self.parts["card"..i].sp:setVisible(flag)
        if not flag then
            self.parts["card"..i]:changeVal("-")
        end
    end
end

function Seat:reset( )
    self:setCardsVisible(false)
    self.parts["total"]:setString("")
    self.parts["chipin"]:setString("")
    self.parts["head"]:setVisible(false)
    self.parts["niu"]:setVisible(false)

end

function Seat:sit(udata)
	table.merge(self.model,udata)
    self:changePic(udata.icon)
    self:changeChpin(udata.chipin)
    self:changeName(data.name)
end

function Seat:showCard(cards,quick,callback)
    for i=1,5 do
        self.parts["card"..i]:changeVal(cards[i],quick)
        if i == to and callback then
            callback()
        end
    end
    self.parts["cards"] = cards
end

function Seat:showNiuType( index )
    self.parts["niu"]:setVisible(true)
    if index == 0 then
        self.parts["niu"].label:setFntFile("fonts/num-green.fnt")
        self.parts["niu"].label:setPositionY(58)
    elseif index < 10 then
        self.parts["niu"].label:setPositionY(92)
        self.parts["niu"].label:setFntFile("fonts/num-yellow.fnt")
    elseif index >= 10 then
        self.parts["niu"].label:setFntFile("fonts/num-blue.fnt")
        self.parts["niu"].label:setPositionY(84)
    end
    if index == 0 then
        self.parts["niu"].label:setString("没牛")
        for i=1,5 do
            self.parts["card"..i]:gray()
        end
    else
        self.parts["niu"].label:setString(CONFIG.niuType[index])
    end
end 


function Seat:stand( )
    local baseId = self.model.baseId
    self.model = {
        mid = 0,
        seatid = 0,
        baseId = baseId,
        icon = "",
        name = "",
        status = 0,
        sex = 0
    }
    self:reset()
end



return Seat