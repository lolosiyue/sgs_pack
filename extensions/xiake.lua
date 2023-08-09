module("extensions.xiake", package.seeall)
extension = sgs.Package("xiake")
caoxueyang = sgs.General(extension, "caoxueyang", "shu", "4",false)

--技能生效用隐藏武将
caoxueyang123 = sgs.General(extension, "caoxueyang123", "shu", "4",false,true, true)



--距离
--疾驱。相互-2
LuaChi = sgs.CreateDistanceSkill{
	name = "LuaChi",
	correct_func = function(self, from, to)
		if from:hasSkill("LuaChi") then
			return - 2
		end
		if to:hasSkill("LuaChi") then
			return - 2
		end
	
	end
}
--驰骋，相互+1，回合内疾驱
LuaCheng = sgs.CreateDistanceSkill{
	name = "LuaCheng",
	correct_func = function(self, from, to)
		if from:hasSkill("LuaCheng") then
			return 1
		end
		if to:hasSkill("LuaCheng") then
			return 1
		end
	end
}
--驰骋+咆哮，ORZ
LuaChicheng = sgs.CreateTriggerSkill{
	name = "#LuaChicheng",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local phase = player:getPhase()
		if phase == sgs.Player_Start then
			local room = player:getRoom()
				if player:hasSkill("LuaCheng") then
			    --room:handleAcquireDetachSkills(player, "LuaChi")
                room:acquireOneTurnSkills(player, "LuaCheng", "LuaChi")
			end
		end
	end
}


--穿云
LuaChuanyun = sgs.CreateTriggerSkill{
	name = "LuaChuanyun",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed,sgs.CardResponded},
	on_trigger = function(self, event, player, data)
		local card = nil
		local room = player:getRoom()
		if event == sgs.CardUsed then
			use = data:toCardUse()
			card = use.card
		elseif event == sgs.CardResponded then
			card = data:toCardResponse().m_card
		end
		if card:isKindOf("Slash") then
		        local count = player:getMark("&zhican")
			    if player:hasSkill("LuaPaoxiaoC") then
				   room:broadcastSkillInvoke("LuaPaoxiaoC")
				end
				if count < 6 then
			       player:gainMark("&zhican", 2)
				elseif count ==6 then
				   player:gainMark("&zhican", 1)
		        end
		end		
	end
}
LuaChuanyun_skill = sgs.CreateTriggerSkill{
	name = "#LuaChuanyun_skill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local phase = player:getPhase()
		if phase == sgs.Player_Start then
			local room = player:getRoom()
			local count = player:getMark("&zhican")
			if (player:hasSkill("LuaChuanyun")) and (count > 2) then 
			 	--room:handleAcquireDetachSkills(player, "LuaPaoxiaoC")
                room:acquireOneTurnSkills(player, "LuaChuanyun", "LuaPaoxiaoC")
			end
		end
	end
}

--龙牙：每当你对目标角色造成伤害，或使用杀指定一名角色为目标后，你可以消耗3层破甲进行一次判定
--红：目标流失一点体力；黑：你摸一张牌
LuaLongya = sgs.CreateTriggerSkill{
	name = "LuaLongya",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		local count = player:getMark("&zhican")
		if count > 2 then
		 if damage.from and damage.from:hasSkill(self:objectName()) and room:askForSkillInvoke(player, self:objectName(), data) then
		   	local victim = damage.to
			if not victim:isDead() then
			room:broadcastSkillInvoke(self:objectName())
			player:loseMark("&zhican", 3)
				local judge = sgs.JudgeStruct()
				judge.pattern = "."
				judge.good = true
				judge.who = victim
				judge.reason = self:objectName()
				room:judge(judge)
				local suit = judge.card:getSuit()
				if suit == sgs.Card_Spade or suit == sgs.Card_Club then
					player:drawCards(1)
				elseif suit == sgs.Card_Heart or suit == sgs.Card_Diamond then
					if victim:isAlive() then
						room:loseHp(victim)
					end
				end
			end
		  end
		end
	end
}

Table2IntList = function(theTable)
	local result = sgs.IntList()
	for i = 1, #theTable, 1 do
		result:append(theTable[i])
	end
	return result
end
LuaLongyaT = sgs.CreateTriggerSkill{
	name = "#LuaLongyaT" ,
	events = {sgs.TargetConfirmed} ,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local room = player:getRoom()
		local count = player:getMark("&zhican")
		if count > 2 then
		if (player:objectName() ~= use.from:objectName()) or (not use.card:isKindOf("Slash")) then return false end
		
		for _, p in sgs.qlist(use.to) do
			local _data = sgs.QVariant()
			_data:setValue(p)
			if player:askForSkillInvoke("#LuaLongyaT", _data) then
			    room:broadcastSkillInvoke(self:objectName())
			    player:loseMark("&zhican", 3)
				p:setFlags("LuaTiejiTarget")
				local judge = sgs.JudgeStruct()
				judge.pattern = "."
				judge.good = true
				judge.reason = self:objectName()
				judge.who = player
				player:getRoom():judge(judge)
				local kind = judge.card:getSuit()
				if kind == sgs.Card_Spade or kind == sgs.Card_Club then
					player:drawCards(1)
				elseif kind == sgs.Card_Heart or kind == sgs.Card_Diamond then
					if p:isAlive() then
						room:loseHp(p)
					end
				end
				p:setFlags("-LuaTiejiTarget")
		     end			
		end
		end
		
	end
}


--[[
	技能名：咆哮（锁定技）曹雪阳
	]]--
LuaPaoxiaoC = sgs.CreateTargetModSkill{
	name = "LuaPaoxiaoC",
	pattern = "Slash",
	residue_func = function(self, player)
		if player:hasSkill(self:objectName()) then
			return 1000
		end
	end,
}

--技能生效用隐藏武将
caoxueyang123:addSkill(LuaChi)
caoxueyang123:addSkill(LuaPaoxiaoC)

--曹雪阳·穿云龙牙驰骋

caoxueyang:addSkill(LuaChuanyun)
caoxueyang:addSkill(LuaChuanyun_skill)
extension:insertRelatedSkills("LuaChuanyun","#LuaChuanyun_skill")


caoxueyang:addSkill(LuaLongya)
caoxueyang:addSkill(LuaLongyaT)
extension:insertRelatedSkills("LuaLongya","#LuaLongyaT")

caoxueyang:addSkill(LuaCheng)
caoxueyang:addSkill(LuaChicheng)
extension:insertRelatedSkills("LuaCheng","#LuaChicheng")

caoxueyang:addRelateSkill("LuaPaoxiaoC")
caoxueyang:addRelateSkill("LuaChi")




sgs.LoadTranslationTable{
   ["xiake"] = "侠客包",
   
   ["caoxueyang"] = "曹雪阳",
   ["&caoxueyang"] = "曹雪阳",
   ["#caoxueyang"] = "宣威将军",
   ["LuaChuanyun"] = "穿云",
   [":LuaChuanyun"] = "每当你使用或打出【杀】时，获得2层【破甲】（至多7层）。准备阶段开始时，若你持有3层或以上的“破甲”，此回合内你获得【咆哮】",
   ["LuaPaoxiaoC"] = "咆哮",
   ["$LuaPaoxiaoC1"] = "喝！！",
   ["$LuaPaoxiaoC2"] = "呀啊啊！！",
   ["$LuaPaoxiaoC3"] = "敢挡我？！",
   ["$LuaPaoxiaoC4"] = "杀！",
   [":LuaPaoxiaoC"] = "你在出牌阶段内使用【杀】时无次数限制。",
   ["LuaLongya"] = "龙牙",
   ["$LuaLongya1"] = "就是现在！",
   ["$LuaLongya2"] = "这招如何？",
   [":LuaLongya"] = "当你对其他角色造成伤害，或使用【杀】指定其他角色为目标时，你可以消耗3层【破甲】进行一次判定。红：该角色流失一点体力；黑：你摸一张牌",
   ["#LuaLongyaT"] = "龙牙",
   ["$LuaLongyaT1"] = "当心啊",
   ["$LuaLongyaT2"] = "接招啦",
   ["LuaChicheng"] = "驰骋",
   [":LuaChicheng"] = "<font color=\"blue\"><b>锁定技，</b></font>你与其他角色相互计算距离时，始终+1；你在回合内获得技能【疾驱】",
   ["LuaCheng"] = "驰骋",
   [":LuaCheng"] =  "<font color=\"blue\"><b>锁定技，</b></font>你与其他角色相互计算距离时，始终+1；你在回合内获得技能【疾驱】",
   ["LuaChi"] = "疾驱",
   [":LuaChi"] = "你与其他角色相互计算距离时，始终-2",
   ["@zhican"] = "破甲",
   ["zhican"] = "破甲",
   
   [":LuaChi"] = "你与其他角色相互计算距离时，始终-2",
   ["designer:caoxueyang"] = "Caelamza",
   ["illustrator:caoxueyang"]="伊吹五月",

}