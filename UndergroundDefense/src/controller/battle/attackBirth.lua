
local coordinate = require("src/util/coordinate")

local gameTip = require("src/view/gameTip")

local warriorView = require("src/view/role/warrior")

local skill = require("src/controller/skill")

local attackBirth = class("attackBirth")

----攻击小怪出生地
function attackBirth.soldierBirth(map)
    if((not Warrior_P[5]) and birthplace_blood > 0)then--没有攻击士兵才能攻击巢穴
        
        local warrior = map:getChildByTag(5000):getChildByTag(1000)
        local pointx,pointy = warrior:getPosition()

        local point = {x = pointx, y = pointy}

        local item = coordinate.getItem(map, point)
        if(item.x == soldierItem.x and item.y == soldierItem.y)then --到达巢穴     
             Warrior_P[4] = false  
             
             Warrior_P[5] = true -- 攻击巢穴状态
             local time_space = 0
             local function bitBirth()
                  local birth = map:getChildByTag(250)
                  local progress = birth:getChildByTag(20)
                  local txt = birth:getChildByTag(21)
                  time_space = time_space + Warrior.time
                  
                  if(time_space > Warrior.skill_time) then  --技能
                      local type = skill.type()
                      time_space = 0
                     
                      if(type == 1)then
                      --显示技能名
                        local skill_tip = gameTip.warriorTip("暴击-"..Warrior.skill_type1,map,300,10,cc.c3b(0,125,0))
                        map:addChild(skill_tip,0,300)

                        birthplace_blood = birthplace_blood - Warrior.skill_type1 ;
                        progress:setPercentage(math.floor(birthplace_blood/result.birthplace_blood*100))
                        txt:setString(birthplace_blood.. "/" .. result.birthplace_blood)
                        
                      else
                        --显示技能名
                        local skill_tip = gameTip.warriorTip("治疗术+".. Warrior.skill_type2,map,300,10,cc.c3b(0,125,0))
                        map:addChild(skill_tip,0,300)
                        Warrior_P [2] = Warrior_P [2] + Warrior.skill_type2
                        
                        local warriorLayer = map:getChildByTag(5000)
                        local blooding1 =warriorLayer:getChildByTag(1002)
                        local blood_txt1 =warriorLayer:getChildByTag(1003)
                        blooding1:setPercentage(math.floor(Warrior_P[2]/Warrior.blood*100))
                        blood_txt1:setString(Warrior_P[2].. "/" .. Warrior.blood)
                      end
                  else
                     birthplace_blood = birthplace_blood - Warrior_P[8]
                     --显示扣血效果
                    local Birthtip =  gameTip.create(progress,"-"..Warrior_P[8],map,666,4)
                     map:addChild(Birthtip,0,666) 
                  end
                  if(birthplace_blood > 0)then
                   
                    progress:setPercentage(math.floor(birthplace_blood/result.birthplace_blood*100))
                    txt:setString(birthplace_blood.. "/" .. result.birthplace_blood)
                    
                    local w_action = cc.Sequence:create(cc.DelayTime:create(Warrior.time),
                        cc.CallFunc:create(bitBirth,{}))
                    w_action:setTag(2500)
                    warrior:runAction(w_action)
                  else
                     --摧毁巢穴
                    local distroy =  gameTip.brith(progress,"巢穴被摧毁!!",map,666)
                    map:addChild(distroy,0,666)  
                    
                    local moneyControl = require("src/util/money")
                    moneyControl.addMoney("birth", progress, map)
                    
                    map:removeChildByTag(250)
                    local layerBg=map:getLayer("layerMap")    
                    
                    if soldierState == "left" then
                        layerBg:removeTileAt(cc.p(item.x - 1, item.y)) 
                        layerBg:removeTileAt(cc.p(item.x - 2, item.y)) 
                        layerBg:removeTileAt(cc.p(item.x - 1, item.y - 1)) 
                        layerBg:removeTileAt(cc.p(item.x - 2, item.y - 1)) 
                    end

                    if soldierState == "right" then
                        layerBg:removeTileAt(cc.p(item.x + 1, item.y)) 
                        layerBg:removeTileAt(cc.p(item.x + 2, item.y)) 
                        layerBg:removeTileAt(cc.p(item.x + 1, item.y - 1)) 
                        layerBg:removeTileAt(cc.p(item.x + 2, item.y - 1))
                    end

                    if(isExistWarrior)then
                        warrior:stopActionByTag(2500)
                        Warrior_P[5] =false
                        warriorView.move(map, BossItem)
                    end
                  end
             end
             
             bitBirth()       
        end
    end
end

return attackBirth
