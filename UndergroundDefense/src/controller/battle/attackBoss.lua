
local coordinate = require("src/util/coordinate")

local gameTip = require("src/view/gameTip")

local warriorView = require("src/view/role/warrior")

local skill = require("src/controller/skill")

local attackBoss = class("attackBoss")

----攻击Boss
function attackBoss.bitBoss(map)

    if(isExistWarrior and (not Warrior_P[5]) )then  --没有攻击士兵才能攻击Boss

        ---勇士打Boss
        local warrior = map:getChildByTag(5000):getChildByTag(1000)
        local pointx,pointy = warrior:getPosition()

        local point = {x = pointx, y = pointy}

        local item = coordinate.getItem(map,point)
        if(item.x == BossItem.x  and item.y == BossItem.y)then --到达Boss
            Warrior_P[5] =true -- 攻击Boss状态
            local time_space = 0
            local bossLayer = map:getChildByTag(10000)
            local boss = bossLayer:getChildByTag(1000)
            local progress = bossLayer:getChildByTag(100001)
            local txt = bossLayer:getChildByTag(100002)

            local function attack()
                
                time_space = time_space + Warrior.time

                if(time_space > Warrior.skill_time) then  --技能
                    local type = skill.type()
                    time_space = 0
     
                    if(type == 1)then
                        --显示技能名
                        local skill_tip = gameTip.warriorTip("暴击-"..Warrior.skill_type1,map,300,10,cc.c3b(0,125,0))
                        map:addChild(skill_tip,0,300)
                   
                        Boss_blood = Boss_blood - Warrior.skill_type1 ;
                        progress:setPercentage(math.floor(Boss_blood/Boss.blood*100))
                        txt:setString(Boss_blood.. "/" .. Boss.blood)
                    else
                        --显示技能名
                        local skill_tip = gameTip.warriorTip("治疗术+".. Warrior.skill_type2,map,300,10,cc.c3b(0,125,0))
                        map:addChild(skill_tip,0,300)
                        Warrior_P [2] = Warrior_P [2] + Warrior.skill_type2
                        require("src/view/role/warrior").updateBlood() -- 更新血条                          
                    end
                else
                    Boss_blood = Boss_blood - Warrior_P[8] 
                    --显示扣血效果
                    local Bosstip =  gameTip.create(progress,"-"..Warrior_P[8],map,1001,4)
                    map:addChild(Bosstip,0,1001)
                end
                
                if( Boss_blood > 0)then
                    
                    progress:setPercentage(math.floor(Boss_blood/Boss.blood*100))
                    txt:setString(Boss_blood.. "/" .. Boss.blood)

                    local w_action = cc.Sequence:create(cc.DelayTime:create(Warrior.time),
                        cc.CallFunc:create(attack,{}))
                    w_action:setTag(1003)
                    warrior:runAction(w_action)
                else
                    print("游戏结束")
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerId)
                    gameResult = false
                    local scene = require("ResultScene")
                    local gameScene = scene.create()
                    cc.Director:getInstance():replaceScene(gameScene)
                end
            end

            attack()

            ---Boss打勇士

            local function attackWarrior()
                Warrior_P[2] = Warrior_P[2] - Boss.hurt
                if(Warrior_P[2] > 0)then
                    --print("Boss_time" .. Boss.time)
                    --显示扣血效果
                    local tip =  gameTip.create(Warrior_P[1]:getChildByTag(1000),"-"..Boss.hurt,map,585,1)
                    map:addChild(tip,0,585)
                    
                    require("src/view/role/warrior").updateBlood() -- 更新血条

                    local action =cc.Sequence:create(
                        cc.DelayTime:create(Boss.time),                       
                        cc.CallFunc:create(attackWarrior,{})
                    )
                    action:setTag(1008)
                    boss:runAction(action)
                                   
                else
                    local moneyControl = require("src/util/money")
                    moneyControl.addMoney("warrior", Warrior_P[1]:getChildByTag(1000), map)
                    
                    boss:stopActionByTag(1008)
                    map:removeChildByTag(5000) --移除勇士
                    isExistWarrior = false
                end

            end
            
            attackWarrior()

        end
    end
end


return attackBoss