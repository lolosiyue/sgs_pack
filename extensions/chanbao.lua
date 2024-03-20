module("extensions.chanbao", package.seeall)
extension = sgs.Package("chanbao")
diaochanchan = sgs.General(extension, "diaochanchan", "qun", 3, false)
qingyue = sgs.CreateTriggerSkill {
	name = "qingyue",
	frequency = sgs.Skill_Frequent,
	events = { sgs.DamageCaused },
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local reason = damage.card
		if reason and not damage.to:isNude() then
			if reason:isKindOf("Slash") and damage.to:isMale() then
				if not damage.to:isNude() then
					if player:askForSkillInvoke(self:objectName(), data) then
						local allcard = sgs.Sanguosha:cloneCard("slash")
						local cards = damage.to:getCards("h")
						for _, card in sgs.qlist(cards) do
							allcard:addSubcard(card)
						end
						allcard:deleteLater()
						player:getRoom():obtainCard(player, allcard, false)
						player:getRoom():broadcastSkillInvoke("qingyue", math.random(2))
					end
				end
			end
		end
		return false
	end,
}

cqingxin = sgs.CreateProhibitSkill {
	name = "cqingxin",
	is_prohibited = function(self, from, to, card)
		if to:hasSkill(self:objectName()) then
			return card:isKindOf("TrickCard") and not card:isNDTrick()
		end
	end,
}
biyuechan = sgs.CreateTriggerSkill {
	name = "biyuechan",
	frequency = sgs.Skill_Frequent,
	events = { sgs.EventPhaseStart },
	can_trigger = function(self, target)
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Finish and player:hasSkill("biyuechan") then
			if not room:askForSkillInvoke(player, "biyuechan", data) then return false end
			room:broadcastSkillInvoke("biyuechan", math.random(2))
			local x = player:getLostHp() + 1
			player:drawCards(x)
			room:askForDiscard(player, self:objectName(), 1, 1, false, true)
		end
	end,
}
diaochanchan:addSkill(qingyue)
diaochanchan:addSkill(cqingxin)
diaochanchan:addSkill(biyuechan)
sgs.LoadTranslationTable {
	["chanbao"] = "蝉包",
	["diaochanchan"] = "貂蝉",
	["qingyue"] = "倾月",
	[":qingyue"] = "当你使用【杀】对男性角色造成伤害后，你可立即获得其所有手牌。",
	["cqingxin"] = "倾心",
	[":cqingxin"] = "<font color=\"blue\"><b>锁定技，</b></font>你不能成为其他角色延时锦囊目标。",
	["biyuechan"] = "蔽月",
	[":biyuechan"] = "回合结束阶段，你可摸1+等同于你已损失的体力的牌数，然后弃1张牌。",
	["~diaochanchan"] = "义父，来世再做您的好女儿。",
	["#diaochanchan"] = "闭月天仙",

	["$biyuechan1"] = "月垂蔽，情依旧。",
	["$biyuechan2"] = "妾身..美吗？",

	["$qingyue1"] = "嗯~就是他！",
	["$qingyue2"] = "都是他的错！",
}

return { extension }
