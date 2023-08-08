module("extensions.diyguanyupac", package.seeall)
extension = sgs.Package("diyguanyupac")

luadiyguanyu = sgs.General(extension, "luadiyguanyu", "shu", 4)

luajuaocard = sgs.CreateSkillCard{
	name = "luajuaocard",
	will_throw = false,
	target_fixed = false,
	once = true,
	filter = function(self, targets, to_select)
		if #targets > 0 then return false end
		return sgs.Self:objectName() ~= to_select:objectName()
	end,
	on_use = function(self, room, source, targets)
		if(#targets ~= 1) then return end
		local to = targets[1]
        room:moveCardTo(self, to, sgs.Player_PlaceHand, false)
		if to:getHp()>=source:getHp() then
			source:drawCards(1)
		end
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		duel:setSkillName("luajuao")
		local use = sgs.CardUseStruct()
		use.card = duel
		use.from = source
		local sp=sgs.SPlayerList()
		sp:append(to)
		use.to = sp
		room:useCard(use)
		room:setPlayerFlag(source, "luajuao_used")
        duel:deleteLater()
	end,
}

luajuao = sgs.CreateViewAsSkill{
	name = "luajuao",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isKindOf("Slash")
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local lcard = luajuaocard:clone()
		lcard:addSubcard(cards[1])
		lcard:setSkillName(self:objectName())
		return lcard
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#luajuaocard")
	end,
}


luadiyguanyu:addSkill("wusheng")
luadiyguanyu:addSkill(luajuao)

sgs.LoadTranslationTable{
	["diyguanyupac"] = "关羽",
	
	["luadiyguanyu"] = "关羽",
	["#luadiyguanyu"] = "千里独行",
	["luajuao"] = "倨傲",
	["luajuaocard"] = "倨傲",
	[":luajuao"] = "<font color=\"green\"><b>出牌阶段限一次，</b></font>你可以交给一名其他角色一张【杀】，视为你对其使用了一张【决斗】，若其体力值不少于你，在决斗结算前，你摸一张牌。",
	["designer:luadiyguanyu"] = "wubuchenzhou",
	["cv:luadiyguanyu"] = "",
	
	["$luajuao1"] = "以忠守心，以义规行。",
	["$luajuao2"] = "关某在此。来者~报上名来！",
}