module("extensions.jsp500", package.seeall)
extension = sgs.Package("jsp500")

Nzhaoyun = sgs.General(extension,"Nzhaoyun","qun","4")

fjsp_youlong = sgs.CreateTriggerSkill{
   name = "fjsp_youlong",
   frequency = sgs.Skill_NotFrequent,
   events = {sgs.DamageComplete,sgs.Damage},
   on_trigger = function (self,event,player,data)
   local room = player:getRoom()
   local list = room:getAlivePlayers()
   if event == sgs.DamageComplete then      
      for _, zhaoyun in sgs.qlist(list) do
         if zhaoyun:isAlive() and zhaoyun:hasSkill(self:objectName()) and zhaoyun:canDiscard(zhaoyun, "he") and zhaoyun:getMark(self:objectName().."using") == 0 then 
			local damage = data:toDamage()
			local slash = sgs.Sanguosha:cloneCard("slash",sgs.Card_NoSuit,0)
        	slash:setSkillName(self:objectName())
			slash:deleteLater()
            local targets = sgs.SPlayerList()
			if zhaoyun:canSlash(damage.from, slash, false) then
				targets:append(damage.from)
			end
			if zhaoyun:canSlash(damage.to, slash, false) then
				targets:append(damage.to)
			end
        	if not targets:isEmpty() and room:askForSkillInvoke(zhaoyun,self:objectName(),data) then 
        		room:askForDiscard(zhaoyun,"fjsp_youlong",1,1,false,true) 
                room:addPlayerMark(zhaoyun, self:objectName().."using")
        		local use = sgs.CardUseStruct()       		
        		use.from = zhaoyun
        		use.card = slash 
        		local dest = room:askForPlayerChosen(zhaoyun,targets,self:objectName())
        		use.to:append(dest)
        		room:useCard(use)    
                room:setPlayerMark(zhaoyun, self:objectName().."using", 0)
        	end
         end
      end
    elseif event == sgs.Damage then 
    	local damage = data:toDamage()
    	if damage.card and damage.card:getSkillName()== self:objectName() then 
    	   local zhaoyun = damage.from
           room:drawCards(zhaoyun,1,self:objectName())
           zhaoyun:turnOver()
           room:handleAcquireDetachSkills(zhaoyun, "-"..self:objectName())
   	       room:setPlayerFlag(zhaoyun,"youlong_lose")
   	   end 
   	   return false
   end
   end,
   can_trigger = function(self,target)
   	 return target ~= nil 
   end,
   priority = -1,
}
fjsp_youlong_return = sgs.CreateTriggerSkill{
   name = "#fjsp_youlong_return",
   frequency = sgs.Skill_Compulsory,
   events = {sgs.EventPhaseChanging},
   on_trigger = function (self,event,player,data)
     local room = player:getRoom()
     local list = room:getAlivePlayers()
   	 local change = data:toPhaseChange()
   	 if change.to ~= sgs.Player_NotActive then return false end
   	 for _, zhaoyun in sgs.qlist(list) do
           if zhaoyun:hasFlag("youlong_lose")  then 
              room:setPlayerFlag(zhaoyun,"-youlong_lose")
              room:handleAcquireDetachSkills(zhaoyun,"fjsp_youlong")
           end
       end
    end, 
   can_trigger = function(self,target)
   	 return target ~= nil 
   end,
   }

dangqianCard = sgs.CreateSkillCard{
	name = "dangqianCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self,targets,to_select)
    local player = sgs.Self 	
    return #targets < player:getHp() and player:canDisCard(to_select, "he")
    end,
	feasible = function(self,targets)
	return #targets > 0
	end,
	on_effect = function(self,effect)
      local room = effect.from:getRoom()
      local id = room:askForCardChosen(effect.from,effect.to,"he","dangqian")
       room:throwCard(id,effect.to,effect.from)
	end
}
dangqianVS = sgs.CreateViewAsSkill{
	name = "dangqian",
	n = 0,
	view_as = function(self, cards)
		return dangqianCard:clone()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@dangqian"
	end
	}

dangqian = sgs.CreateTriggerSkill{
	name = "dangqian" ,
	events = {sgs.CardResponded, sgs.TargetConfirmed},
	view_as_skill = dangqianVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local arg = player:getHp()
		if event == sgs.CardResponded then
			local resp = data:toCardResponse()
			if (resp.m_card:getSkillName() == "longdan")  then
				room:askForUseCard(player, "@@dangqian", "@dangqian")
			end
		else
			local use = data:toCardUse()
			if (use.from:objectName() == player:objectName()) and (use.card:getSkillName() == "longdan") then
				room:askForUseCard(player, "@@dangqian", "@dangqian")
			end
		end
		return false
	end
}

local Skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("dangqian") then
Skills:append(dangqian)
end
sgs.Sanguosha:addSkills(Skills)

guishu = sgs.CreateTriggerSkill{
	name = "guishu" ,
	events = {sgs.EventPhaseStart} ,
	frequency = sgs.Skill_Wake ,
	on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        player:setMark("guishu", 1)
        local room = player:getRoom()
        if room:changeMaxHpForAwakenSkill(player) then 
            room:setPlayerProperty(player,"kingdom",sgs.QVariant("shu")) 
            room:handleAcquireDetachSkills(player, "longdan")
            room:handleAcquireDetachSkills(player, "dangqian")
            room:handleAcquireDetachSkills(player,"-fjsp_youlong")
            room:handleAcquireDetachSkills(player,"-#youlong_return")
            room:doLightbox("$guishu") 
        end			
		return false
	end ,
    can_wake = function(self, event, player, data, room)
	if player:getPhase() ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
	if player:canWake(self:objectName()) then return true end
	local lord = room:getLord()
		if lord then
			if (string.find(lord:getGeneralName(),"liubei") or string.find(lord:getGeneral2Name(),"liubei"))
			or (string.find(lord:getGeneralName(),"liushan") or string.find(lord:getGeneral2Name(),"liushan"))  then
                return true
            end
        end
	return false
end,
}
Nzhaoyun:addSkill(fjsp_youlong)
Nzhaoyun:addSkill(fjsp_youlong_return)
extension:insertRelatedSkills("fjsp_youlong","#fjsp_youlong_return")
Nzhaoyun:addSkill(guishu)
Nzhaoyun:addRelateSkill("dangqian")

sgs.LoadTranslationTable{
   ["jsp500"] = "界SP包",
   ["$guishu"] = "子龙一身是胆",
   ["Nzhaoyun"] = "界SP赵云",
   ["&Nzhaoyun"] = "界SP赵云",
   ["#Nzhaoyun"] = "常山的游侠",
   ["fjsp_youlong"] = "游龙",
   [":fjsp_youlong"] = "当一名角色受到伤害后，你可以于伤害结算结束后弃置一张牌，视为对其或伤害源角色使用一张杀，以此法使用的杀造成伤害后，你摸一张牌，将武将牌翻面，并失去“游龙”直到回合结束。",
   ["guishu"] = "归宿",
   [":guishu"] = "<font color=\"purple\"><b>觉醒技</b></font>，准备阶段开始时，若本局的主公为刘备或刘禅，你失去1点体力上限，失去“游龙”，获得“龙胆”，“当千”，并将势力变为蜀。",
   ["dangqian"] = "当千",
   [":dangqian"] = "当你发动龙胆时，你可以弃置x名角色各一张牌（x为你体力值）",
    ["@dangqian"] = "请选择“当千”的对象",
    ["~dangqian"] = "依次选择你要弃牌的对象",


  } 