extension = sgs.Package("YY")

--赵云
gz_zhaoyun = sgs.General(extension, "gz_zhaoyun", "qun", 4, true, true)
Qinggangex = sgs.CreateViewAsEquipSkill {
	name = "#Qinggangex",
	view_as_equip = function(self, player)
		return "qinggang_sword"
	end
}
--[[
Qinggang = sgs.CreateTriggerSkill{
	  name="Qinggang",
        events={sgs.TargetSpecified,sgs.Damage},
        priority=2,
        frequency=sgs.Skill_Compulsory,
        on_trigger=function(self,event,player,data)
		local room=player:getRoom()
-- 无视防具
		if event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.from and use.from:hasSkill(self:objectName()) then
				if use.card:isKindOf("Slash") then
					if use.from:objectName() == player:objectName() then
					   for _,p in sgs.qlist(use.to) do
                if (p:getMark("Equips_of_Others_Nullified_to_You") == 0) then
                    p:addQinggangTag(use.card)
                end
            end
                room:setEmotion(use.from, "weapon/qinggang_sword")
				room:broadcastSkillInvoke("Qinggang")
				room:sendCompulsoryTriggerLog(use.from, "Qinggang", true)
					end
				end
			end
-- 吸血
elseif event  == sgs.Damage then
		local damage = data:toDamage()
		if damage.from:hasSkill(self:objectName()) and damage.from:objectName() ~= damage.to:objectName()then		
			if damage.from:isWounded() then
				room:broadcastSkillInvoke("longhun")  --音效
				local recover = sgs.RecoverStruct()
				recover.who = damage.from
				recover.recover = damage.damage
				room:recover(damage.from,recover)
				room:sendCompulsoryTriggerLog(damage.from, "Qinggang", true)
			end
		end
		end
		end
}
]]

Qinggang = sgs.CreateTriggerSkill {
	name = "Qinggang",
	events = { sgs.Damage },
	priority = 2,
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damage then
			local damage = data:toDamage()
			if damage.from:hasSkill(self:objectName()) and damage.from:objectName() ~= damage.to:objectName() then
				if damage.from:isWounded() then
					room:broadcastSkillInvoke("longhun") --音效
					local recover = sgs.RecoverStruct()
					recover.who = damage.from
					recover.recover = damage.damage
					room:recover(damage.from, recover)
					room:sendCompulsoryTriggerLog(damage.from, "Qinggang", true)
				end
			end
		end
	end
}
--攻击距离


luanixi = sgs.CreateAttackRangeSkill {
	name = "luanixi",
	extra_func = function(self, player, include_weapon)
		if player:hasSkill("luanixi") then
			return player:getMark("&fenyong_y")
		end
	end,
}

luanixi_tr = sgs.CreateTriggerSkill {
	name = "#luanixi_tr",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.Damaged, sgs.DrawNCards },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged then
			local damage = data:toDamage()
			room:broadcastSkillInvoke("longdan") --音效
			player:gainMark("&fenyong_y", damage.damage);
			for i = 1, damage.damage, 1 do
				local x = player:getLostHp()
				if x > 0 then
					room:sendCompulsoryTriggerLog(player, "luanixi", true)
					player:drawCards(x)
				end
			end
		elseif event == sgs.DrawNCards then
			if player:isWounded() then
				room:sendCompulsoryTriggerLog(player, "luanixi", true)
				data:setValue(data:toInt() + player:getLostHp())
				room:broadcastSkillInvoke("juejing")
			end
		end
	end
}
luanixi_Keep = sgs.CreateMaxCardsSkill {
	name = "#luanixi_Keep",
	extra_func = function(self, target)
		if target:hasSkill(self:objectName()) then
			return target:getMark("&fenyong_y")
		else
			return 0
		end
	end
}

jibian = sgs.CreateTriggerSkill {
	name = "jibian",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.HpChanged },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		--if not room:askForSkillInvoke(player,self:objectName(),data) then return end
		--if player:getHandcardNum()>player:getHp() then
		--	player:drawCards(1)
		--	room:askForDiscard(player,self:objectName(),1,1,false,false)
		--else
		--	local x=math.min(7,player:getMaxHp()-player:getHandcardNum())	
		--	player:drawCards(x)
		--end
		if player:getHandcardNum() < player:getHp() then
			local x = math.min(7, player:getMaxHp() - player:getHandcardNum())
			player:drawCards(x)
		end
	end
}
--gz_zhaoyun:addSkill(jibian)
gz_zhaoyun:addSkill(Qinggang)
gz_zhaoyun:addSkill(Qinggangex)
extension:insertRelatedSkills("Qinggang", "#Qinggangex")
gz_zhaoyun:addSkill(luanixi) --攻击距离
gz_zhaoyun:addSkill(luanixi_tr)
--gz_zhaoyun:addSkill(luanixi_Keep)
extension:insertRelatedSkills("luanixi", "#luanixi_tr")
gz_zhaoyun:addSkill("feiyang")
gz_zhaoyun:addSkill("bahu")

--extension:insertRelatedSkills("luanixi","#luanixi_Keep")



sgs.LoadTranslationTable {
	["#gz_zhaoyun"] = "白马先锋",
	["gz_zhaoyun"] = "☆赵云",
	["Qinggang"] = "青釭",
	["$Qinggang"] = "(拔剑声)",
	[":Qinggang"] = "<font color=\"blue\"><b>锁定技，</b></font>你使用的【杀】无视目标角色的防具。你对其他角色造成伤害时，回复相应体力。",
	["fenyong_y"] = "勇",
	["luanixi"] = "逆袭",
	[":luanixi"] = "<font color=\"blue\"><b>锁定技，</b></font>摸牌阶段额外摸X张牌.你每受到1点伤害，你摸X张牌(X为你已损体力值)，同时你获得1枚勇标记，每有1枚勇标记，你的攻击范围+1，手牌上限+1。",
	["jibian"] = "机变",
	[":jibian"] = "当你的体力值发生变动时，若手牌数小于你的当前体力值，你可令手牌补将手牌补至X张（X为你的体力上限）。",
}
return { extension }
