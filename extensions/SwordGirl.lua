module("extensions.SwordGirl", package.seeall)
extension = sgs.Package("SwordGirl")

LuaDuanjianCard = sgs.CreateSkillCard {
	name = "LuaDuanjianCard",
	skill_name = "LuaDuanjian",
	will_throw = true,

	filter = function(self, targets, to_select, player)
		if #targets == 0 then return findMyOE(to_select) end
		if #targets == 1 then return to_select:objectName() == findMyOE(targets[1]):objectName() end
	end,

	feasible = function(self, targets)
		return #targets == 2
	end,

	on_use = function(self, room, source, targets)
		relieveOE(room, targets[1])
		return false
	end,
}

LuaDuanjian = sgs.CreateOneCardViewAsSkill {
	name = "LuaDuanjian",
	filter_pattern = "Weapon",
	view_as = function(self, card)
		local scard = LuaDuanjianCard:clone()
		scard:setSkillName(self:objectName())
		scard:addSubcard(card)
		return scard
	end,

	enabled_at_play = function(self, player)
		return true
	end,
}

LuaLianzhanTest = sgs.CreateTriggerSkill {
	name = "LuaLianzhanTest",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.CardEffected },

	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local effect = data:toCardEffect()
		for _, source in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
			if source and source:getPhase() == sgs.Player_NotActive then
				if effect.card and effect.card:getSkillName() == "establishOECard" then
					room:notifySkillInvoked(source, self:objectName())
					local log = sgs.LogMessage()
					log.type = "#TriggerSkill"
					log.from = source
					log.arg = self:objectName()
					room:sendLog(log)
					source:drawCards(1)
				end
			end
		end
		return false
	end,

	can_trigger = function(self, target)
		return target:isAlive()
	end,
}

SwordGirl = sgs.General(extension, "SwordGirl", "qun", 3, false)
SwordGirl:addSkill(LuaDuanjian)
SwordGirl:addSkill(LuaLianzhanTest)

sgs.LoadTranslationTable {
	["SwordGirl"] = "剑士妹子",
	["#SwordGirl"] = "战场武神",
	["&SwordGirl"] = "女剑士",
	["LuaDuanjianTest"] = "断剑",
	["LuaDuanjian"] = "断剑",
	[":LuaDuanjian"] = "出牌阶段，你可弃置一张武器牌令两名存在对应宿敌关系的角色解除此关系。",
	["LuaLianzhanTest"] = "恋战",
	[":LuaLianzhanTest"] = "<font color=\"blue\"><b>锁定技 </b></font>，回合外每当一名角色建立宿敌关系时，你摸一张牌。",
	["designer:SwordGirl"] = "Amira",
	["illustrator:SwordGirl"] = "opiu",
}
return { extension }
