
local soldierView = require("src/view/role/soldier")
local monsterModel = require("src/model/monsterModel")

local  leftMenu= class("leftMenu",function()
    return cc.LayerColor:create()
end)

function leftMenu.create(x,y,map)

    local layer = leftMenu.new()
    --------妖怪1 
    local  monster1 = cc.Sprite:create("monster/monster_head1.png")
    monster1:setScale(1.5)
    monster1:setPosition(x,y)
    layer:addChild(monster1,0,1)   
    monster1:setColor(cc.c3b(120,120,120))
    
    local monster1Time = cc.Label:createWithTTF("time","fonts/arial.ttf",13)
    monster1Time:setPosition(x,y)
    layer:addChild(monster1Time,0,11)
    
    local monster1Max = cc.Label:createWithTTF("MAX","fonts/arial.ttf",13)
    monster1Max:setPosition(x,y)
    layer:addChild(monster1Max,0,12)    

    --------妖怪2
    local monster2 = cc.Sprite:create("monster/monster_head2.png")
    monster2:setScale(1.5)
    monster2:setPosition(x ,y - 80)   
    layer:addChild(monster2,0,2) 
    monster2:setColor(cc.c3b(120,120,120))
    
    local monster2Time = cc.Label:createWithTTF("time","fonts/arial.ttf",13)
    monster2Time:setPosition(x ,y - 80)
    layer:addChild(monster2Time,0,21)

    local monster2Max = cc.Label:createWithTTF("MAX","fonts/arial.ttf",13)
    monster2Max:setPosition(x ,y - 80)
    layer:addChild(monster2Max,0,22) 

    --------妖怪3
    local monster3 = cc.Sprite:create("monster/RobotState4.png")
    monster3:setScale(1.3)
    monster3:setPosition(x ,y -160)   
    layer:addChild(monster3,0,3) 
    monster3:setColor(cc.c3b(120,120,120))
    
    local monster3Time = cc.Label:createWithTTF("time","fonts/arial.ttf",13)
    monster3Time:setPosition(x ,y -160)
    layer:addChild(monster3Time,0,31)

    local monster3Max = cc.Label:createWithTTF("MAX","fonts/arial.ttf",13)
    monster3Max:setPosition(x ,y -160)
    layer:addChild(monster3Max,0,32) 



    local whichmonster = nil   --用来生成拖动的moster
    local tag = nil 
    local listener_left = cc.EventListenerTouchOneByOne:create()
    local function onTouchBegan_left(touche, event)       
        local location = touche:getLocation()
        ---是否点中怪物
        if(cc.rectContainsPoint(monster1:getBoundingBox(),location) or 
               cc.rectContainsPoint(monster2:getBoundingBox(),location) or 
               cc.rectContainsPoint(monster3:getBoundingBox(),location)
          )then
                 
            listener_left:setSwallowTouches(true) --吞噬点击事件，不往下层传递，记得返回true
            --moster1
           if(cc.rectContainsPoint(monster1:getBoundingBox(),location))then 
                 --钱够，冷却时间到，没达到最大数量
                if(Money >= result.monster.monster1.cost and 
                   monsterModel.monsterTab.monster1.cd <= 0 and 
                   monsterModel.monsterTab.monster1.currentMosterNum < monsterModel.monsterTab.monster1.maxNum)then
                        tag = 100
                        whichmonster = leftMenu.createMonster1(monster1:getPositionX(),monster1:getPositionY())
                        whichmonster:setOpacity(120)
                        layer:addChild(whichmonster,0,tag)
                else
                  return false
                end
           end
           --moster2
           if(cc.rectContainsPoint(monster2:getBoundingBox(),location))then
                if(Money >= result.monster.monster2.cost and 
                   monsterModel.monsterTab.monster2.cd <= 0 and  
                   monsterModel.monsterTab.monster2.currentMosterNum < monsterModel.monsterTab.monster2.maxNum)then
                        tag = 200
                        whichmonster = leftMenu.createMonster2(monster2:getPositionX(),monster2:getPositionY())
                        whichmonster:setOpacity(120)
                        layer:addChild(whichmonster,0,tag)
                else
                   return false
                end
           end
            --moster3
           if(cc.rectContainsPoint(monster3:getBoundingBox(),location))then
                if(Money >= result.monster.monster3.cost and 
                   monsterModel.monsterTab.monster3.cd <= 0  and 
                   monsterModel.monsterTab.monster3.currentMosterNum < monsterModel.monsterTab.monster3.maxNum)then
                        tag = 300
                        whichmonster = leftMenu.createMonster3(monster3:getPositionX(),monster3:getPositionY())
                        whichmonster:setOpacity(120)
                        layer:addChild(whichmonster,0,tag)
                else
                   return false
                end
           end
           
            return true  ---setSwallowTouches能吞噬触屏，记得要返回true才行
        else
           
            return false -- 不触发move，end
        end
                      
    end
    
    local function onTouchesMove_left(touche, event)
        whichmonster:setPosition(touche:getLocation())                        
    end
    
    local function onTouchEnd_left(touche, event)
        listener_left:setSwallowTouches(false) --取消吞噬点击事件
        whichmonster:setOpacity(255)
        
        local clonesprite
        local map_x = (whichmonster:getPositionX()-map:getPositionX()) / ScaleRate
        local map_y = (whichmonster:getPositionY()-map:getPositionY()) / ScaleRate
        
        local item  = KUtil.getItem(map, cc.p(map_x, map_y))
        local layerBg=map:getLayer("layerMap")
        local gid = layerBg:getTileGIDAt(cc.p(item.x, item.y))
        if gid ~= 34 then
            local layerMap = map:getParent()
            layer:removeChildByTag(tag) --移除拖动的moster
            require("src/view/menu/scaleMap").showMessage("魔将只能放置在道路上", layerMap)  
            
            return
        end
        --创建moster
        if(tag == 100)then
            clonesprite = soldierView.create(map_x,map_y,"monster/monster1.png",result.monster.monster1.blood,result.monster.monster1.hurt,1,result.monster.monster1.speed,0)            
            --Money = Money - result.monster.monster1.cost
            local moneyControl = require("src/util/money")
            moneyControl.costMoney("monster1")
            
            monsterModel:addMoster("monster1")
            monsterModel:flushCD("monster1")
            monsterModel:printData()
            local layerMap = map:getParent()
            local message = "创建魔将1"
            if(monsterModel.monsterTab.monster1.currentMosterNum == 1)then               
                --激活monster1的效果:soldier blood + 200 hurt + 50
                for key, soldier in ipairs(soldierTab) do  --soldierTab存有怪兽
                	if(soldier.type == 0)then
                        soldier.hurt = soldier.hurt + result.monster.monster1.soldierHurt
                        soldier.remaindBlood = soldier.remaindBlood + result.monster.monster1.soldierBlood
                        soldier.blood = soldier.blood + result.monster.monster1.soldierBlood
                	end
                end        
                message = "创建魔将1，强化我方小兵"    
                soldierView.updateAllBlood()  
            end   
            
            require("src/view/menu/scaleMap").showMessage(message, layerMap)                 
        end
        
        if(tag == 200)then
            clonesprite = soldierView.create(map_x,map_y,"monster/monster2.png",result.monster.monster2.blood,result.monster.monster2.hurt,2,result.monster.monster2.speed,0)
            --Money =Money - result.monster.monster2.cost
            
            local moneyControl = require("src/util/money")
            moneyControl.costMoney("monster2")
            
            monsterModel:addMoster("monster2")
            monsterModel:flushCD("monster2")
            monsterModel:printData()
            
            local layerMap = map:getParent()
            local message = "创建魔将2"

            if(monsterModel.monsterTab.monster2.currentMosterNum == 1)then               
                --激活monster2的效果:enemysoldier blood - 150 hurt - 50
                for key, soldier in ipairs(warriorTab) do  --soldierTab存有怪兽
                    soldier.hurt = soldier.hurt - result.monster.monster2.enemysoldierHurt
                    soldier.remaindBlood = soldier.remaindBlood - result.monster.monster2.enemysoldierBlood
                end          
                message = "创建魔将2，弱化敌方小兵"
                require("src/view/role/enemySoldier").updateAllBlood()  
            end         
            require("src/view/menu/scaleMap").showMessage(message, layerMap)
        end
        
        if(tag == 300)then
            clonesprite = soldierView.create(map_x,map_y,"monster/RobotRun3.png",result.monster.monster3.blood,result.monster.monster3.hurt,3,result.monster.monster3.speed,0)            
            --Money = Money - result.monster.monster3.cost
            local moneyControl = require("src/util/money")
            moneyControl.costMoney("monster3")
            
            monsterModel:addMoster("monster3")
            monsterModel:flushCD("monster3")
            monsterModel:printData()
            
            local layerMap = map:getParent()
            local message = "创建魔将3"

            if(monsterModel.monsterTab.monster3.currentMosterNum == 1 and isExistWarrior)then               
                --激活monster3的效果:weak warrior  speed - 0.4 blood -300 hurt - 80
                Warrior_P[8] = Warrior_P[8] - result.monster.monster3.warriorHurt
                Warrior_P[2] = Warrior_P[2] - result.monster.monster3.warriorBlood
                Warrior_P[7] = Warrior_P[7] + result.monster.monster3.warriorSpeed           
                require("src/view/role/warrior").updateBlood()  
                message = "创建魔将3，弱化敌方勇士"
            end     
            require("src/view/menu/scaleMap").showMessage(message, layerMap)   
        end        
        map:addChild(clonesprite,0,soldierKey)--添加到map上
        soldierKey =soldierKey +1
        layer:removeChildByTag(tag) --移除拖动的moster

    end
    ----监听leftMenu       
    listener_left:registerScriptHandler(onTouchBegan_left,cc.Handler.EVENT_TOUCH_BEGAN )
    listener_left:registerScriptHandler(onTouchEnd_left,cc.Handler.EVENT_TOUCH_ENDED )
    listener_left:registerScriptHandler(onTouchesMove_left,cc.Handler.EVENT_TOUCH_MOVED )
    local eventDispatcher_left = layer:getEventDispatcher()
    eventDispatcher_left:addEventListenerWithSceneGraphPriority(listener_left, layer)
   
    return layer
end

function leftMenu.createMonster3(x,y)
     local sprite = cc.Sprite:create("monster/RobotRun3.png")
     
     sprite:setPosition(x,y)     
     sprite:setScale(0.3)
     return sprite     
end

function leftMenu.createMonster1(x,y)
    local sprite = cc.Sprite:create("monster/monster1.png")
    sprite:setPosition(x,y)
    sprite:setScale(0.6)
    
    return sprite     
end

function leftMenu.createMonster2(x,y)
    local sprite = cc.Sprite:create("monster/monster2.png")

    sprite:setPosition(x,y)
    sprite:setScale(0.6)

    return sprite     
end
return leftMenu