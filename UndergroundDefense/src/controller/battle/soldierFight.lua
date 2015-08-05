local A_start=require("src/util/A_start")

local warriorView = require("src/view/role/warrior")

local soldierView = require("src/view/role/soldier")

local gameTip = require("src/view/gameTip")

local coordinate = require("src/util/coordinate")

local skill = require("src/controller/skill")

local soldierFight = class("soldierFight")
 
--小兵打小兵
function soldierFight.soldierVsSoldier(map)
	for key, soldier in ipairs(soldierTab) do
	     
	end
end 
 


local time_space = 0 
-- 检查勇士进入小兵视野内
function soldierFight.warriorVsSoldier(map)
    local warriorLayer = map:getChildByTag(5000)
    local warrior = warriorLayer:getChildByTag(1000)
    local blood =warriorLayer:getChildByTag(1001)
    local blooding =warriorLayer:getChildByTag(1002)
    local blood_txt =warriorLayer:getChildByTag(1003)
    local wpointx,wpointy = warrior:getPosition()
        
    local wpoint = {x = wpointx , y = wpointy}
    local item = coordinate.getItem(map,wpoint)
    local attack = true  --勇士优先攻击巢穴和魔王
    if((item.x == 5 and item.y == 57)or ((item.x == 10 and item.y == 17)))then
       attack = false  --不打小兵
    end
   
    
    for key, var in ipairs(soldierTab) do
        if(not var.isStop)then  --没和勇士战斗的小兵
            local spointx,spointy = var.layer:getChildByTag(100):getPosition()
            --遇到勇士
            if(math.abs(spointx-wpointx)< Soldier.Viewrang and math.abs(spointy-wpointy) < Soldier.Viewrang)then
                var.isStop = true -- 遇上勇士
                --小兵
                local soldier = var.layer:getChildByTag(100)
                local sblood =var.layer:getChildByTag(101)
                local sblooding =var.layer:getChildByTag(102)
                local sblood_txt =var.layer:getChildByTag(103)
                sblood:stopAllActions()
                sblooding:stopAllActions()
                sblood_txt:stopAllActions()
                soldier:stopAllActions();

                --停止运动的勇士
                if(Warrior_P [4])then
                    blood:stopAllActions()
                    blooding:stopAllActions()
                    blood_txt:stopAllActions()
                    warrior:stopActionByTag(1010);
                    Warrior_P [4] = false
                end
            end
        else --和勇士战斗的小兵
            if(not var.isBit)then --还没运行攻击的小兵               
                var.isBit =true
                
                local function bitWarrior()
                    Warrior_P[2] = Warrior_P[2] - var.hurt
                    --勇士死亡
                    if(Warrior_P[2] <= 0)then
                        map:removeChildByTag(5000) --移除勇士                        
                        isExistWarrior = false                                               
                        for key1, var1 in ipairs(soldierTab) do
                        
                            var1.layer:getChildByTag(100):stopAllActions() --勇士死亡，停止攻击活动
                            var1.isStop = false --没遇到勇士
                            var1.isPatrol = true  --从新巡逻
                            var1.isBit = false --没有攻击勇士活动
                        end
                        soldierView.move(map)

                    else
                        if(map:getChildByTag(5000))then
                            --显示扣血效果
                            local tip =  gameTip.create(Warrior_P[1]:getChildByTag(1000),"-"..var.hurt,map,5555,1)
                            
                            map:addChild(tip,0,5555) 
                            blooding:setPercentage(math.floor(Warrior_P[2]/Warrior.blood*100))
                            blood_txt:setString(Warrior_P[2].. "/" .. Warrior.blood)
                        end

                        var.layer:getChildByTag(100):runAction(cc.Sequence:create(cc.DelayTime:create(Soldier.time),
                            cc.CallFunc:create(bitWarrior,{})))
                    end

                end
                bitWarrior()
            end
        end
    end
    
    --攻击小兵
    
    if((not Warrior_P[5]) and attack)then 
        local hitkey = -1
       
        local function bitSoldier()
             local fight_soldier = (soldierTab[hitkey])
             local remaind = fight_soldier.layer:getChildByTag(102)
             local txt = fight_soldier.layer:getChildByTag(103) 
             time_space = time_space +   Warrior.time   
             
             if(time_space > Warrior.skill_time) then  --技能
               local type = skill.type()
               time_space = 0
               if(type == 1)then
                    --显示技能名
                    local skill_tip =  gameTip.skill(Warrior_P[1]:getChildByTag(1000),"暴击-"..Warrior.skill_type1 ,map,123)
                    map:addChild(skill_tip,0,123)
                    
                    fight_soldier.remaindBlood = fight_soldier.remaindBlood - Warrior.skill_type1 ;
                    remaind:setPercentage(math.floor(fight_soldier.remaindBlood/fight_soldier.blood*100))
                    
                    txt:setString(fight_soldier.remaindBlood.. "/" .. fight_soldier.blood)
               else
                    --显示技能名
                    local skill_tip =  gameTip.skill(Warrior_P[1]:getChildByTag(1000),"治疗术+".. Warrior.skill_type2,map,123)
                    map:addChild(skill_tip,0,123)
                    Warrior_P [2] = Warrior_P [2] + Warrior.skill_type2
                    
                    blooding:setPercentage(math.floor(Warrior_P[2]/Warrior.blood*100))
                    blood_txt:setString(Warrior_P[2].. "/" .. Warrior.blood)
               end
             else   --普攻            
                fight_soldier.remaindBlood = fight_soldier.remaindBlood - Warrior_P[8] ;
                remaind:setPercentage(math.floor(fight_soldier.remaindBlood/fight_soldier.blood*100))
                txt:setString(fight_soldier.remaindBlood.. "/" .. fight_soldier.blood)
             end
             if(fight_soldier.remaindBlood > 0)then 
                    local w_action = cc.Sequence:create(cc.DelayTime:create(Warrior.time),
                        cc.CallFunc:create(bitSoldier,{}))
                    w_action:setTag(888)
                    warrior:runAction(w_action) 
             else
                  --小兵被打死
                  warrior:stopActionByTag(888);   
                  map:removeChildByTag(fight_soldier.tag) --从地图移除
                  table.remove(soldierTab,hitkey) -- 移除该小兵                  
                  Warrior_P[5] = false 
                  hitkey = -1                                                            
             end                     
        end  
              
        for key, var in ipairs(soldierTab) do
              if(var.isStop)then
                 hitkey = key  --寻找一个周围小兵攻击
                 Warrior_P[5] = true 
                 --print("找到")                 
                 bitSoldier() --攻击
                 break;
              end
         end         
         ---周围没小兵，运动
         if(hitkey == -1)then
             time_space = 0
             if(not Warrior_P [4])then --如果勇士是静止的
                 warriorView.move(map)
             end
                          
         end
         
      
    end 

end

---小兵的战斗
function soldierFight.soldierVsSoldier(map)

   
 	
end
return soldierFight