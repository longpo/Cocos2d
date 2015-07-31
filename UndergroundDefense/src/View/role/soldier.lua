-----soldier 的Layer

local A_start = require("src/util/A_start")
local coordinate = require("src/util/coordinate")

local soldierLayer = class("soldiersLayer",function()
    return cc.Layer:create()
end)

function soldierLayer.create(x,y,sprite,blood_num,hurt)
    
    local layer = soldierLayer.new()
        
    local soldier

    if(sprite)then 
        soldier = cc.Sprite:create(sprite)
        if(sprite == "monster/RobotRun3.png")then
            soldier:setScale(0.25)
        else
            soldier:setScale(0.6)
        end
    else
        soldier = cc.Sprite:create("soldier.png")
    end    
    
    soldier:setPosition(x,y)
    layer:addChild(soldier,0,100)
    
    ------添加血条    
    local blood = cc.Sprite:create("monster_blood_frame.png")
    blood:setPosition(x,y+20)
    blood:setScaleX(0.5)
    layer:addChild(blood,0,101)
    
    
    local blooding = cc.Sprite:create("monster_blood.png")

    local progress1 = cc.ProgressTimer:create(blooding)
    progress1:setType(1)--设成横向
    progress1:setMidpoint(cc.p(0,0))
    progress1:setBarChangeRate(cc.p(1,0))--左往右
    progress1:setPercentage(100)
    progress1:setPosition(x,y+20)   
    progress1:setScaleX(0.5)
    layer:addChild(progress1,0,102)
    
    local bd_txt
    if(blood_num)then
        bd_txt = blood_num .."/" ..blood_num
    else
        bd_txt = Soldier.blood .. "/".. Soldier.blood
    end
    
    ----添加血量文字
    local blood_txt = cc.Label:createWithTTF(bd_txt,"fonts/arial.ttf",10)
    blood_txt:setColor(cc.c3b(0,0,0))
    blood_txt:setPosition(x,y+30)
    layer:addChild(blood_txt,1,103)
   
    local path = {}
    --把小兵添加到集合
    --true用来指示一次目标点巡逻是否结束,0表示移动次数,path表示移动的线路,true表示是否在停止巡逻,小兵剩余血量,
    --小兵的tag,正在被打的小兵,是否运行攻击勇士,伤害值，总血量
    if(sprite)then 
        table.insert(soldierTab,{layer,true,0,path,false,blood_num,soldierKey,false,false,hurt,blood_num})
    else
        table.insert(soldierTab,{layer,true,0,path,false,Soldier.blood,soldierKey,false,false,Soldier.hurt,Soldier.blood})
    end 


    return layer
end

local function Noderun(var,node)
	if(node[3]< table.getn(node[4]))then
	   node[3] = node[3] +1 ;	   
        node[1]:getChildByTag(101):runAction(cc.MoveTo:create(Soldier.speed,
            cc.p((node[4])[node[3]].x,(node[4])[node[3]].y+20)))
        node[1]:getChildByTag(102):runAction(cc.MoveTo:create(Soldier.speed,
            cc.p((node[4])[node[3]].x,(node[4])[node[3]].y+20)))
        node[1]:getChildByTag(103):runAction(cc.MoveTo:create(Soldier.speed,
            cc.p((node[4])[node[3]].x,(node[4])[node[3]].y+30)))
	   
	   node[1]:getChildByTag(100):runAction(cc.Sequence:create(
            cc.MoveTo:create(Soldier.speed,(node[4])[node[3]]),cc.CallFunc:create(Noderun,node)))
                                   --第一个参数是回调的方法，第二个参数可以是开发者自定义的table
    else
       node[3] = 0;
       node[2] = true
    end
end
-- 
----小兵移动--查岗
function soldierLayer.move(map)	 
       
       for key, var in ipairs(soldierTab) do
      	   if(var[2])then
      	      var[3] = 0
      	      --print("再次巡逻、、。。。。。。")
              var[2]  =  false   --防止小兵在运动是再次触发移动 
              local point = cc.p(var[1]:getChildByTag(100):getPositionX(),
                   var[1]:getChildByTag(100):getPositionY())  
                ---获取起点的item           
              local startItem = coordinate.getItem(map,point)
              --print("start: " .. startItem.x .. "  " ..startItem.y)
            
              --获取巡逻终点的item
              local ram = math.random(1,table.getn(result.SoldierPoint)) 
                       
              local endItem = result.SoldierPoint[ram]
            
              --print("end : ".. endItem.x,endItem.y)
               --A_start寻路
              local result = A_start.findPath(startItem,endItem,map)
               ---路径查找到
              if(result ~= 0)then
                 var[4] = {} --path{}先清零
                 table.insert(var[4],1,coordinate.getPoint(map,endItem)) -- 插入终点
                 --位置数组
                 while(result.x)do
                    local item = {x =result.x, y=result.y}  
                                     
                    table.insert(var[4],1,coordinate.getPoint(map,item))
                 
                    result=result.father
                 end 
                
                --防止回退到item中心
                (var[4])[1].x,(var[4])[1].y = var[1]:getChildByTag(100):getPosition()  
                                       
                 --节点移动
                 Noderun("ff",var) --“ff"只是为了满足函数调用   
               --路径 没找到
               else
                var[2] = true  --重新巡逻 
               end
            
      	   end
       end       
  	
end

return soldierLayer