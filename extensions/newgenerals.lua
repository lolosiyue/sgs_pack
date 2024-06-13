extension = sgs.Package("newgenerals", sgs.Package_GeneralPack)
local packages = {}
local skills = sgs.SkillList()
table.insert(packages, extension)
function KeToData(self)
	local data = sgs.QVariant()
	if type(self) == "string"
		or type(self) == "boolean"
		or type(self) == "number"
	then
		data = sgs.QVariant(self)
	elseif self ~= nil then
		data:setValue(self)
	end
	return data
end

--卡牌

--奇正相生
Qizhengxiangsheng = sgs.CreateTrickCard {
	name = "_qizhengxiangsheng",
	class_name = "Qizhengxiangsheng",
	subtype = "shenxunyu_card",
	suit = sgs.Card_Spade,
	number = 2,
	damage_card = true,
	single_target = true,
	filter = function(self, targets, to_select, player)
		return #targets == 0 and to_select:objectName() ~= player:objectName() and
		not player:isProhibited(to_select, self)
	end,
	available = function(self, player)
		return not player:isLocked(self)
	end,
	on_effect = function(self, effect)
		local from, to = effect.from, effect.to
		local room = from:getRoom()
		if from:isDead() or to:isDead() then return end

		local data = sgs.QVariant()
		data:setValue(to)
		local choice = room:askForChoice(from, "_qizhengxiangsheng",
			"zhengbing=" .. to:objectName() .. "+qibing=" .. to:objectName(), data)

		local log = sgs.LogMessage()
		log.type = "#QizhengxiangshengLog"
		log.from = from
		log.to:append(to)
		log.arg = "_qizhengxiangsheng_" .. choice:split("=")[1]
		room:sendLog(log, from)

		local choice2, card = "", nil
		if not effect.no_respond then
			data:setValue(effect)
			choice2 = room:askForChoice(to, "_qizhengxiangsheng_", "slash+jink+cancel", data)
			if choice2 ~= "cancel" then
				card = room:askForCard(to, choice2, "@_qizhengxiangsheng-card:" .. choice2, data, sgs
				.Card_MethodResponse, (from:isAlive() and from) or nil, false, "", false, self)
			end
		end

		if choice:startsWith("zhengbing") then
			if not card or choice2 ~= "jink" then
				if from:isDead() or to:isNude() then return end
				local id = room:askForCardChosen(from, to, "he", self:objectName())
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, from:objectName())
				room:obtainCard(from, sgs.Sanguosha:getCard(id), reason, false)
			end
		elseif choice:startsWith("qibing") then
			if not card or choice2 ~= "slash" then
				room:damage(sgs.DamageStruct(self, (from:isAlive() and from) or nil, to))
			end
		end
	end
}

Qizhengxiangsheng:setParent(extension)

for i = 3, 9 do
	local qzxs = Qizhengxiangsheng:clone(i % 2, i)
	qzxs:setParent(extension)
end

sgs.LoadTranslationTable {
	["_qizhengxiangsheng"] = "奇正相生",
	[":_qizhengxiangsheng"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名其他角色<br /><b>效果</b>：你秘密选择“正兵”或“奇兵”，然后目标角色可以打出一张【杀】或【闪】。" ..
		"若你选择了“正兵”且其未打出【闪】，你获得其一张牌；若你选择了“奇兵”且其未打出【杀】，你对其造成1点伤害。",
	["shenxunyu_card"] = "神荀彧专属",
	["_qizhengxiangsheng:zhengbing"] = "为%src选择“正兵”",
	["_qizhengxiangsheng:qibing"] = "为%src选择“奇兵”",
	["@_qizhengxiangsheng-card"] = "你可以打出一张【%src】",
	["#QizhengxiangshengLog"] = "%from 为 %to 选择了“%arg”",
	["_qizhengxiangsheng_zhengbing"] = "正兵",
	["_qizhengxiangsheng_qibing"] = "奇兵",
	["_qizhengxiangsheng_:slash"] = "打出一张【杀】",
	["_qizhengxiangsheng_:jink"] = "打出一张【闪】",
}

--武将

kexinjiangslashbuff = sgs.CreateTargetModSkill {
	name = "kexinjiangslashbuff",
	pattern = ".",
	residue_func = function(self, from, card, to)
		--[[local n = 0
		if (card:getSkillName() == "kehexuanfeng") then
			n = n + 1000
		end
		if from and from:hasSkill("kehezhubei") and to and (to:getMark("&kehezhubeisp-Clear") > 0) then
			n = n + 1000
		end
		return n]]
	end,
	extra_target_func = function(self, from, card)
		local n = 0
		if (card:getSkillName() == "keolkenshang") then
			n = card:getSubcards():length() - 1
		end
		return n
	end,
	distance_limit_func = function(self, from, card, to)
		--[[local n = 0
		if (card:getSkillName() == "kehexuanfeng") then
			n = n + 1000
		end
		return n]]
	end
}
if not sgs.Sanguosha:getSkill("kexinjiangslashbuff") then skills:append(kexinjiangslashbuff) end



local sendZhenguLog = function(player, skill_name, broadcast)
	broadcast = broadcast or true
	local room = player:getRoom()
	local log = sgs.LogMessage()
	log.type = "#ZhenguEffect"
	log.from = player
	log.arg = skill_name
	room:sendLog(log)
	if broadcast then
		player:peiyin(skill_name)
	end
end

--潘淑-十周年
tenyear_panshu = sgs.General(extension, "tenyear_panshu", "wu", 3, false)

zhirenRecord = sgs.CreateTriggerSkill {
	name = "#zhirenRecord",
	events = { sgs.CardUsed, sgs.CardResponded },
	global = true,
	priority = 3,
	on_trigger = function(self, event, player, data, room)
		local card
		if event == sgs.CardUsed then
			card = data:toCardUse().card
		else
			local res = data:toCardResponse()
			if not res.m_isUse then return false end
			card = res.m_card
		end
		if not card or card:isKindOf("SkillCard") or card:isVirtualCard() then return false end
		player:addMark("zhirenRecord-Clear")
		return false
	end
}

local function chsize(tmp)
	if not tmp then
		return 0
	elseif tmp > 240 then
		return 4
	elseif tmp > 225 then
		return 3
	elseif tmp > 192 then
		return 2
	else
		return 1
	end
end

local function utf8len(str)
	local length = 0
	local currentIndex = 1
	while currentIndex <= #str do
		local tmp    = string.byte(str, currentIndex)
		currentIndex = currentIndex + chsize(tmp)
		length       = length + 1
	end
	return length
end

zhiren = sgs.CreateTriggerSkill {
	name = "zhiren",
	events = { sgs.CardUsed, sgs.CardResponded },
	on_trigger = function(self, event, player, data, room)
		if player:getMark("zhirenRecord-Clear") ~= 1 then return false end
		if player:getMark("zhirenUsed-Clear") > 0 then return false end
		local phase = sgs.Player_RoundStart
		if player:getPhase() ~= sgs.Player_NotActive or player:getMark("&yaner-Self" .. phase .. "Clear") > 0 then
			local card
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else
				local res = data:toCardResponse()
				if not res.m_isUse then return false end
				card = res.m_card
			end
			if not card or card:isKindOf("SkillCard") or card:isVirtualCard() then return false end

			local name_num = utf8len(sgs.Sanguosha:translate(card:objectName()))
			if card:isKindOf("Slash") then name_num = 1 end

			if not player:askForSkillInvoke(self, data) then return false end
			player:peiyin(self)
			player:addMark("zhirenUsed-Clear")

			if name_num >= 1 and player:isAlive() then
				room:askForGuanxing(player, room:getNCards(name_num, false), 0)
			end

			if name_num >= 2 and player:isAlive() then
				local targets = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if player:canDiscard(p, "e") then
						targets:append(p)
					end
				end
				if not targets:isEmpty() then
					local to = room:askForPlayerChosen(player, targets, self:objectName(), "@zhiren-equip")
					room:doAnimate(1, player:objectName(), to:objectName())
					if player:canDiscard(to, "e") then
						local id = room:askForCardChosen(player, to, "e", self:objectName(), false,
							sgs.Card_MethodDiscard)
						room:throwCard(id, to, player)
					end
				end

				if player:isDead() then return false end
				targets = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if player:canDiscard(p, "j") then
						targets:append(p)
					end
				end
				if not targets:isEmpty() then
					local to = room:askForPlayerChosen(player, targets, "zhiren_judge", "@zhiren-judge")
					room:doAnimate(1, player:objectName(), to:objectName())
					if player:canDiscard(to, "j") then
						local id = room:askForCardChosen(player, to, "j", self:objectName(), false,
							sgs.Card_MethodDiscard)
						room:throwCard(id, to, player)
					end
				end
			end

			if name_num >= 3 and player:isAlive() then
				room:recover(player, sgs.RecoverStruct(player))
			end

			if name_num >= 4 and player:isAlive() then
				player:drawCards(3, self:objectName())
			end
		end
		return false
	end
}

yaner = sgs.CreateTriggerSkill {
	name = "yaner",
	events = sgs.CardsMoveOneTime,
	on_trigger = function(self, event, player, data, room)
		if not room:hasCurrent() then return false end
		local move = data:toMoveOneTime()
		if not move.from or move.from:objectName() == player:objectName() or move.from:getPhase() ~= sgs.Player_Play or not move.is_last_handcard or
			not move.from_places:contains(sgs.Player_PlaceHand) or move.from:isDead() then
			return false
		end

		local from = room:findPlayerByObjectName(move.from:objectName())
		if not from or from:isDead() then return false end

		for _, p in sgs.qlist(room:getOtherPlayers(from)) do
			if from:isDead() then return false end
			if p:isDead() or not p:hasSkill(self) or p:getMark("yanerUsed-Clear") > 0 then continue end
			if not p:askForSkillInvoke(self, from) then continue end
			p:peiyin(self)
			p:addMark("yanerUsed-Clear")

			local targets = sgs.SPlayerList(), p_list, f_list
			targets:append(p)
			targets:append(from)
			room:sortByActionOrder(targets)

			if targets:first():objectName() == from:objectName() then
				f_list = from:drawCardsList(2, self:objectName())
				p_list = p:drawCardsList(2, self:objectName())
			else
				p_list = p:drawCardsList(2, self:objectName())
				f_list = from:drawCardsList(2, self:objectName())
			end

			if p:isAlive() and p_list:length() == 2 then
				if sgs.Sanguosha:getCard(p_list:first()):getTypeId() == sgs.Sanguosha:getCard(p_list:last()):getTypeId() then
					local phase = sgs.Player_RoundStart
					room:setPlayerMark(p, "&yaner-Self" .. phase .. "Clear", 1)
				end
			end

			if from:isAlive() and f_list:length() == 2 then
				if sgs.Sanguosha:getCard(f_list:first()):getTypeId() == sgs.Sanguosha:getCard(f_list:last()):getTypeId() then
					room:recover(from, sgs.RecoverStruct(p))
				end
			end
		end
		return false
	end
}

tenyear_panshu:addSkill(zhirenRecord)
tenyear_panshu:addSkill(zhiren)
tenyear_panshu:addSkill(yaner)
extension:insertRelatedSkills("zhiren", "#zhirenRecord")

--手杀文鸯
mobile_wenyang = sgs.General(extension, "mobile_wenyang", "wei+wu", 4)

local function quediCandiscard(player)
	if player:isDead() then return false end
	local can_dis = false
	for _, c in sgs.qlist(player:getHandcards()) do
		if c:isKindOf("BasicCard") and player:canDiscard(player, c:getEffectiveId()) then
			can_dis = true
			break
		end
	end
	return can_dis
end

quedi = sgs.CreateTriggerSkill {
	name = "quedi",
	events = sgs.TargetSpecified,
	on_trigger = function(self, event, player, data, room)
		if player:getMark("quediUsed-Clear") > player:getMark("&mobilechoujue-Clear") then return false end
		if not room:hasCurrent() then return false end

		local use = data:toCardUse()
		if not use.card:isKindOf("Slash") and not use.card:isKindOf("Duel") then return false end
		if use.to:length() ~= 1 then return false end

		local choices, to = {}, use.to:first()
		if not to:isKongcheng() then
			table.insert(choices, "obtain=" .. to:objectName())
		end

		if quediCandiscard(player) then
			table.insert(choices, "damage")
		end

		table.insert(choices, "beishui")

		if not player:askForSkillInvoke(self, to) then return false end
		player:peiyin(self)
		player:addMark("quediUsed-Clear")

		local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"), data)
		if choice == "damage" then
			if quediCandiscard(player) then
				room:askForDiscard(player, self:objectName(), 1, 1, false, false, "@quedi-basic", "BasicCard")
				room:setCardFlag(use.card, "quediDamage")
			end
		elseif choice == "beishui" then
			if player:isDead() then return false end
			room:loseMaxHp(player, 1, "quedi")
			if player:isDead() then return false end
			if not to:isKongcheng() then
				local id = room:askForCardChosen(player, to, "h", self:objectName())
				player:obtainCard(sgs.Sanguosha:getCard(id), false)
			end
			if player:isDead() then return false end

			if quediCandiscard(player) then
				room:askForDiscard(player, self:objectName(), 1, 1, false, false, "@quedi-basic", "BasicCard")
				room:setCardFlag(use.card, "quediDamage")
			end
		else
			if not to:isKongcheng() then
				local id = room:askForCardChosen(player, to, "h", self:objectName())
				player:obtainCard(sgs.Sanguosha:getCard(id), false)
			end
		end
		return false
	end
}

quediDamage = sgs.CreateTriggerSkill {
	name = "#quediDamage",
	events = sgs.DamageCaused,
	can_trigger = function(self, player)
		return player ~= nil
	end,
	on_trigger = function(self, event, player, data, room)
		local damage = data:toDamage()
		if not damage.card then return false end
		if not damage.card:isKindOf("Slash") and not damage.card:isKindOf("Duel") then return false end
		if not damage.card:hasFlag("quediDamage") then return false end
		damage.damage = damage.damage + 1
		data:setValue(damage)
		return false
	end
}

mobilechoujue = sgs.CreateTriggerSkill {
	name = "mobilechoujue",
	events = sgs.Death,
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data, room)
		local death = data:toDeath()
		if death.who:objectName() == player:objectName() then return false end
		if death.damage and death.damage.from and death.damage.from:objectName() == player:objectName() then
			room:sendCompulsoryTriggerLog(player, self)
			room:gainMaxHp(player, 1, "mobilechoujue")
			player:drawCards(2, self:objectName())
			if room:hasCurrent() and player:isAlive() then
				room:addPlayerMark(player, "&mobilechoujue-Clear")
			end
		end
		return false
	end
}

chuifengCard = sgs.CreateSkillCard {
	name = "chuifeng",
	filter = function(self, targets, to_select, player)
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card, user_string = nil, self:getUserString()
			if user_string ~= "" then
				card = sgs.Sanguosha:cloneCard(user_string:split("+")[1])
				card:setSkillName("chuifeng")
			end
			return card and card:targetFilter(qtargets, to_select, player) and
			not player:isProhibited(to_select, card, qtargets)
		end

		local card = player:getTag("chuifeng"):toCard()
		return card and card:targetFilter(qtargets, to_select, player) and
		not player:isProhibited(to_select, card, qtargets)
	end,
	feasible = function(self, targets, player)
		local card = player:getTag("chuifeng"):toCard()
		if card then
			card:setSkillName("chuifeng")
		end
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		if card and card:canRecast() and #targets == 0 then
			return false
		end
		return card and card:targetsFeasible(qtargets, player)
	end,
	on_validate = function(self, cardUse)
		local source = cardUse.from
		local room = source:getRoom()

		local user_string = self:getUserString()
		if (string.find(user_string, "slash") or string.find(user_string, "Slash")) and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local slashs = sgs.Sanguosha:getSlashNames()
			user_string = room:askForChoice(source, "chuifeng", table.concat(slashs, "+"))
		end

		room:loseHp(sgs.HpLostStruct(source, 1, "chuifeng", source))
		if source:isDead() then return nil end

		local use_card = sgs.Sanguosha:cloneCard(user_string)
		if not use_card then return nil end
		use_card:setSkillName("chuifeng")
		use_card:deleteLater()
		return use_card
	end
}

chuifeng = sgs.CreateZeroCardViewAsSkill {
	name = "chuifeng",
	view_as = function()
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or
			sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local c = chuifengCard:clone()
			c:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
			return c
		end

		local card = sgs.Self:getTag("chuifeng"):toCard()
		if card and card:isAvailable(sgs.Self) then
			local c = chuifengCard:clone()
			c:setUserString(card:objectName())
			return c
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		if ((player:getMark("usetimeschuifeng-PlayClear") >= 2)
				or (player:getMark("banchuifeng-Clear") > 0)) then
			return false
		end
		return player:getKingdom() == "wei"
	end,
	enabled_at_response = function(self, player, pattern)
		if ((player:getMark("usetimeschuifeng-PlayClear") >= 2)
				or (player:getMark("banchuifeng-Clear") > 0)) then
			return false
		end
		if player:getKingdom() ~= "wei" then return false end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then return false end
		return string.find(pattern, "Duel")
	end
}
chuifeng:setJuguanDialog("duel")

chuifengex = sgs.CreateTriggerSkill {
	name = "#chuifengex",
	frequency = sgs.Skill_Frequent,
	events = { sgs.CardUsed, sgs.DamageInflicted, sgs.CardFinished },
	on_trigger = function(self, event, player, data, room)
		if (event == sgs.CardFinished) then
			local use = data:toCardUse()
			if (use.card:getSkillName() == "chuifeng") then
				room:removePlayerMark(use.from, "chuifengfrom-Clear", 1)
			end
		end
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if (use.card:getSkillName() == "chuifeng") then
				room:addPlayerMark(use.from, "usetimeschuifeng-PlayClear", 1)
				room:addPlayerMark(use.from, "chuifengfrom-Clear", 1)
			end
		end
		if event == sgs.DamageInflicted then
			local damage = data:toDamage()
			if damage.card and (damage.card:getSkillName() == "chuifeng")
				and (damage.to:getMark("chuifengfrom-Clear") > 0) then
				room:setPlayerMark(damage.to, "banchuifeng-Clear", 1)
				room:sendCompulsoryTriggerLog(damage.to, "chuifeng")
				return true
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end
}

chongjianslash = sgs.CreateTargetModSkill {
	name = "#chongjianslash",
	pattern = ".",
	distance_limit_func = function(self, from, card, to)
		local n = 0
		if (card:getSkillName() == "chongjian") and card:isKindOf("Slash") then
			n = n + 1000
		end
		return n
	end
}

chongjianCard = sgs.CreateSkillCard {
	name = "chongjian",
	handling_method = sgs.Card_MethodUse,
	filter = function(self, targets, to_select, player)
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card, user_string = nil, self:getUserString()
			if user_string ~= "" then
				card = sgs.Sanguosha:cloneCard(user_string:split("+")[1])
				card:addSubcard(self)
				card:setSkillName("chongjian")
			end
			return card and card:targetFilter(qtargets, to_select, player) and
			not player:isProhibited(to_select, card, qtargets)
		end

		local card = player:getTag("chongjian"):toCard()
		card:addSubcard(self)
		card:setSkillName("chongjian")
		if card and card:targetFixed() then
			return card:isAvailable(player)
		end
		return card and card:targetFilter(qtargets, to_select, player) and
		not player:isProhibited(to_select, card, qtargets)
	end,
	feasible = function(self, targets, player)
		local card = player:getTag("chongjian"):toCard()
		if card then
			card:setSkillName("chongjian")
			card:addSubcard(self)
		end
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		return card and card:targetsFeasible(qtargets, player)
	end,
	on_validate = function(self, cardUse)
		local source = cardUse.from
		local room = source:getRoom()

		local user_string = self:getUserString()
		if (string.find(user_string, "slash") or string.find(user_string, "Slash")) and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local slashs = sgs.Sanguosha:getSlashNames()
			user_string = room:askForChoice(source, "chongjian", table.concat(slashs, "+"))
		end

		local use_card = sgs.Sanguosha:cloneCard(user_string, self:getSuit(), self:getNumber())
		if not use_card then return nil end
		use_card:setSkillName("chongjian")
		use_card:addSubcard(self)
		use_card:deleteLater()
		return use_card
	end,
	on_validate_in_response = function(self, source)
		local room = source:getRoom()
		local user_string = self:getUserString()
		if user_string == "peach+analeptic" then
			user_string = "analeptic"
		end
		local use_card = sgs.Sanguosha:cloneCard(user_string, self:getSuit(), self:getNumber())
		if not use_card then return nil end
		use_card:setSkillName("chongjian")
		use_card:addSubcard(self)
		use_card:deleteLater()
		return use_card
	end
}

chongjian = sgs.CreateOneCardViewAsSkill {
	name = "chongjian",
	response_or_use = true,
	filter_pattern = "EquipCard",
	view_as = function(self, card)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or
			sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local c = chongjianCard:clone()
			c:addSubcard(card)
			c:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
			return c
		end

		local ccc = sgs.Self:getTag("chongjian"):toCard()
		if ccc and ccc:isAvailable(sgs.Self) then
			local c = chongjianCard:clone()
			c:setUserString(ccc:objectName())
			c:addSubcard(card)
			return c
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return player:getKingdom() == "wu"
	end,
	enabled_at_response = function(self, player, pattern)
		if player:getKingdom() ~= "wu" then return false end
		return string.find(pattern, "slash") or string.find(pattern, "Slash") or string.find(pattern, "analeptic")
	end
}
chongjian:setJuguanDialog("all_slashs,analeptic")
chongjianex = sgs.CreateTriggerSkill {
	name = "#chongjianex",
	frequency = sgs.Skill_Frequent,
	events = { sgs.CardUsed, sgs.Damage },
	on_trigger = function(self, event, player, data, room)
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			if damage.card and (damage.card:getSkillName() == "chongjian") then
				for i = 0, damage.damage - 1, 1 do
					if (damage.to:getCards("e") > 0) then
						local card_id = room:askForCardChosen(damage.from, damage.to, "e", self:objectName())
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION,
							damage.from:objectName())
						room:obtainCard(damage.from, sgs.Sanguosha:getCard(card_id), reason,
							room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
					end
				end
			end
		end
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if (use.card:getSkillName() == "chongjian") then
				room:setCardFlag(use.card, "SlashIgnoreArmor")
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end
}

mobile_wenyang:addSkill(quedi)
mobile_wenyang:addSkill(quediDamage)
mobile_wenyang:addSkill(mobilechoujue)
mobile_wenyang:addSkill(chuifeng)
mobile_wenyang:addSkill(chongjian)
mobile_wenyang:addSkill(chongjianex)
mobile_wenyang:addSkill(chuifengex)
mobile_wenyang:addSkill(chongjianslash)
extension:insertRelatedSkills("quedi", "#quediDamage")
extension:insertRelatedSkills("chuifeng", "#chuifengex")
extension:insertRelatedSkills("chongjian", "#chongjianex")
extension:insertRelatedSkills("chongjian", "#chongjianslash")

--OL邓芝
ol_dengzhi = sgs.General(extension, "ol_dengzhi", "shu", 3)

xiuhao = sgs.CreateTriggerSkill {
	name = "xiuhao",
	events = sgs.DamageCaused,
	can_trigger = function(self, player)
		return player and player:isAlive()
	end,
	on_trigger = function(self, event, player, data, room)
		if not room:hasCurrent() then return false end
		local damage = data:toDamage()
		if damage.to:isDead() or damage.to:objectName() == player:objectName() then return false end
		local sp = sgs.SPlayerList()
		sp:append(player)
		sp:append(damage.to)
		room:sortByActionOrder(sp)
		for _, p in sgs.qlist(sp) do
			if p:isDead() or not p:hasSkill(self) or p:getMark("xiuhaoUsed-Clear") > 0 then continue end
			--local spp = sp
			local spp = sgs.SPlayerList()
			for _, q in sgs.qlist(sp) do
				if q:objectName() == p:objectName() then continue end
				spp:append(q)
			end
			--spp:removeOne(p)
			local pp = spp:first()
			if pp:isDead() then continue end
			if not p:askForSkillInvoke(self, pp) then continue end
			p:peiyin(self)
			p:addMark("xiuhaoUsed-Clear")
			damage.from:drawCards(2, self:objectName())
			return true
		end
		return false
	end
}

sujian = sgs.CreatePhaseChangeSkill {
	name = "sujian",
	frequency = sgs.Skill_Compulsory,
	on_phasechange = function(self, player, room)
		if player:getPhase() ~= sgs.Player_Discard then return false end
		room:sendCompulsoryTriggerLog(player, self)
		local cards, this_turn, this_turn_ids, can_dis = sgs.IntList(),
			player:property("fulin_list"):toString():split("+"), sgs.IntList(), sgs.IntList()

		for _, str in ipairs(this_turn) do
			local num = tonumber(str)
			if num and num > -1 then
				this_turn_ids:append(num)
			end
		end

		for _, id in sgs.qlist(player:handCards()) do
			if this_turn_ids:contains(id) then continue end
			cards:append(id)
			if player:canDiscard(player, id) then
				can_dis:append(id)
			end
		end
		if cards:isEmpty() then return true end

		room:fillAG(cards, player)
		local data = sgs.QVariant()
		data:setValue(cards)
		local choices = "give"
		if not can_dis:isEmpty() then choices = choices .. "+discard" end
		local choice = room:askForChoice(player, self:objectName(), choices, data)
		room:clearAG(player)

		if choice == "give" then
			local give = {}

			while not cards:isEmpty() do
				local move = room:askForYijiStruct(player, cards, self:objectName(), false, false, false, -1,
					room:getOtherPlayers(player), sgs.CardMoveReason(), "@sujian-give", false, false)
				if move then
					local ids = give[move.to:objectName()] or sgs.IntList()
					for _, id in sgs.qlist(move.card_ids) do
						cards:removeOne(id)
						ids:append(id)
					end
					give[move.to:objectName()] = ids
				end
			end

			local moves = sgs.CardsMoveList()
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				local ids = give[p:objectName()] or sgs.IntList()
				if ids:isEmpty() then continue end
				local move = sgs.CardsMoveStruct(ids, player, p, sgs.Player_PlaceHand, sgs.Player_PlaceHand,
					sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), p:objectName(),
						self:objectName(), ""))
				moves:append(move)
			end
			if not moves:isEmpty() then
				room:moveCardsAtomic(moves, false)
			end
		else
			local slash = sgs.Sanguosha:cloneCard("slash")
			slash:deleteLater()
			slash:addSubcards(can_dis)
			room:throwCard(slash, player)

			if player:isDead() then return true end
			local sp = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if player:canDiscard(p, "he") then
					sp:append(p)
				end
			end
			if sp:isEmpty() then return true end

			local to = room:askForPlayerChosen(player, sp, self:objectName(), "@sujian-discard")
			room:doAnimate(1, player:objectName(), to:objectName())

			local length = can_dis:length()
			local places = {}
			local jink = sgs.Sanguosha:cloneCard("jink")
			jink:deleteLater()

			to:setFlags("sujian_InTempMoving")

			for i = 1, length, 1 do
				if not player:canDiscard(to, "he") then break end
				local id = room:askForCardChosen(player, to, "he", self:objectName(), false, sgs.Card_MethodDiscard,
					sgs.IntList(), true)
				if id < 0 then break end
				jink:addSubcard(id)
				table.insert(places, room:getCardPlace(id))
				to:addToPile("#sujian", id, false)
			end

			length = jink:subcardsLength()
			if length <= 0 then return true end
			local jink_ids = jink:getSubcards()
			for i = 1, length, 1 do
				room:moveCardTo(sgs.Sanguosha:getCard(jink_ids:at(i - 1)), to, places[i], false)
			end

			to:setFlags("-sujian_InTempMoving")

			room:throwCard(jink, to, player)
		end
		return true
	end
}

sujianFakeMove = sgs.CreateTriggerSkill {
	name = "#sujianFakeMove",
	events = { sgs.BeforeCardsMove, sgs.CardsMoveOneTime },
	can_trigger = function(self, player)
		return player
	end,
	on_trigger = function(self, event, player, data, room)
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasFlag("sujian_InTempMoving") then return true end
		end
		return false
	end,
	priority = 10
}

ol_dengzhi:addSkill(xiuhao)
ol_dengzhi:addSkill(sujian)
ol_dengzhi:addSkill(sujianFakeMove)
extension:insertRelatedSkills("sujian", "#sujianFakeMove")

--OL马忠
ol_mazhong = sgs.General(extension, "ol_mazhong", "shu", 4)

olfumanCard = sgs.CreateSkillCard {
	name = "olfuman",
	handling_method = sgs.Card_MethodNone,
	will_throw = false,
	filter = function(self, targets, to_select, player)
		return #targets == 0 and to_select:objectName() ~= player:objectName() and
		to_select:getMark("olfuman_target-PlayClear") <= 0
	end,
	on_effect = function(self, effect)
		local from, to = effect.from, effect.to
		local room = from:getRoom()
		room:addPlayerMark(to, "olfuman_target-PlayClear")
		room:giveCard(from, to, self, "olfuman")

		local id = self:getSubcards():first()
		if room:getCardPlace(id) ~= sgs.Player_PlaceHand then return end
		local slash = sgs.Sanguosha:cloneCard("slash", self:getSuit(), self:getNumber())
		slash:setSkillName("olfuman")
		local ccc = sgs.Sanguosha:getWrappedCard(id)
		ccc:takeOver(slash)
		room:notifyUpdateCard(room:getCardOwner(id), id, ccc)
	end
}

olfumanVS = sgs.CreateOneCardViewAsSkill {
	name = "olfuman",
	filter_pattern = ".|.|.|hand",
	view_as = function(self, card)
		local c = olfumanCard:clone()
		c:addSubcard(card)
		return c
	end
}

olfuman = sgs.CreateTriggerSkill {
	name = "olfuman",
	events = { sgs.DamageDone, sgs.CardFinished },
	view_as_skill = olfumanVS,
	can_trigger = function(self, player)
		return player
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.DamageDone then
			local damage = data:toDamage()
			if not damage.card or not damage.card:isKindOf("Slash") or not damage.card:hasFlag("olfuman_used_slash") then return false end
			room:setCardFlag(damage.card, "olfuman_damage_done")
		else
			local use = data:toCardUse()
			--if not use.card:isKindOf("Slash") then return false end  --如果原牌面不是【杀】，例如【闪】，ai操作时会判断不是【杀】
			if use.card:isKindOf("SkillCard") then return false end
			if use.card:hasFlag("olfuman_used_slash") or use.card:getSkillName() == "olfuman" then
				local x = (use.card:hasFlag("olfuman_damage_done") and 2) or 1
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:isDead() or not p:hasSkill(self) then continue end
					room:sendCompulsoryTriggerLog(p, self)
					p:drawCards(x, self:objectName())
				end
			end
		end
		return false
	end
}

ol_mazhong:addSkill(olfuman)

--曹安民
caoanmin = sgs.General(extension, "caoanmin", "wei", 4)

xianwei = sgs.CreateTriggerSkill {
	name = "xianwei",
	events = { sgs.EventPhaseStart, sgs.ThrowEquipArea },
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_Start or not player:hasEquipArea() then return false end
			local choices = {}
			for i = 0, 4 do
				if player:hasEquipArea(i) then
					table.insert(choices, i)
				end
			end
			if choices == "" then return false end
			room:sendCompulsoryTriggerLog(player, self)
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			local area, draw = tonumber(choice), 0
			player:throwEquipArea(area)
			for i = 0, 4 do
				if player:hasEquipArea(i) then
					draw = draw + 1
				end
			end
			if draw > 0 then
				player:drawCards(draw, self:objectName())
			end
			if player:isDead() then return false end

			local use_id = -1
			for _, id in sgs.qlist(room:getDrawPile()) do
				local card = sgs.Sanguosha:getCard(id)
				if card:isKindOf("EquipCard") and card:getRealCard():toEquipCard():location() == area then
					use_id = id
					break
				end
			end

			--[[local sp = sgs.SPlayerList()
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:hasEquipArea(area) then
				sp:append(p)
			end
		end
		if sp:isEmpty() then return false end]]

			local to = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "@xianwei-use")
			room:doAnimate(1, player:objectName(), to:objectName())
			if use_id >= 0 then
				local use_card = sgs.Sanguosha:getCard(use_id)
				if to:isAlive() and to:canUse(use_card, to, true) then
					room:useCard(sgs.CardUseStruct(use_card, to, to))
				end
			else
				to:drawCards(1, self:objectName())
			end
		else
			if player:hasEquipArea() then return false end
			local log = sgs.LogMessage()
			log.type = "#XianweiEquipArea"
			log.arg = self:objectName()
			log.from = player
			room:sendLog(log)
			player:peiyin(self)
			room:notifySkillInvoked(player, self:objectName())

			room:gainMaxHp(player, 2, self:objectName())
			for _, p in sgs.qlist(room:getOtherPlayers(player, true)) do
				room:insertAttackRangePair(player, p)
				room:insertAttackRangePair(p, player)
			end
		end
		return false
	end
}

caoanmin:addSkill(xianwei)

--谯周
qiaozhou = sgs.General(extension, "qiaozhou", "shu", 3)

zhiming = sgs.CreateTriggerSkill {
	name = "zhiming",
	events = { sgs.EventPhaseStart, sgs.EventPhaseEnd },
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_Start then return false end
		else
			if player:getPhase() ~= sgs.Player_Discard then return false end
		end
		room:sendCompulsoryTriggerLog(player, self)
		player:drawCards(1, self:objectName())
		if player:isDead() or player:isNude() then return false end
		local card = room:askForCard(player, "..", "@zhiming-put", data, sgs.Card_MethodNone)
		if not card then return false end
		room:moveCardTo(card, nil, sgs.Player_DrawPile,
			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), "zhiming", ""))
		return false
	end
}

xingbu = sgs.CreatePhaseChangeSkill {
	name = "xingbu",
	frequency = sgs.Skill_Frequent,
	on_phasechange = function(self, player, room)
		if player:getPhase() ~= sgs.Player_Finish then return false end
		local shows = room:showDrawPile(player, 3, "xingbu")

		local red = 0
		for _, id in sgs.qlist(shows) do
			if sgs.Sanguosha:getCard(id):isRed() then
				red = red + 1
			end
		end
		if red > 3 or red < 0 then return false end

		local mark = "xbwuxinglianzhu"
		if red == 2 then
			mark = "xbfukuangdongzhu"
		elseif red <= 1 then
			mark = "xbyinghuoshouxin"
		end

		local to = room:askForPlayerChosen(player, room:getOtherPlayers(player), "xingbu_" .. mark,
			"@xingbu-invoke:" .. mark)
		room:doAnimate(1, player:objectName(), to:objectName())
		if to:isAlive() then
			room:addPlayerMark(to, "&" .. mark .. "-SelfClear")
		end

		local slash = sgs.Sanguosha:cloneCard("slash")
		for _, id in sgs.qlist(shows) do
			if room:getCardPlace(id) == sgs.Player_PlaceTable then
				slash:addSubcard(id)
			end
		end
		slash:deleteLater()
		if slash:subcardsLength() > 0 then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), "xingbu",
				"")
			room:throwCard(slash, reason, nil)
		end
		return false
	end
}

xingbuEffect = sgs.CreateTriggerSkill {
	name = "#xingbuEffect",
	events = { sgs.EventPhaseChanging, sgs.DrawNCards, sgs.CardFinished },
	can_trigger = function(self, player)
		return player and player:isAlive()
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseChanging then
			if data:toPhaseChange().to ~= sgs.Player_Discard or player:getMark("&xbwuxinglianzhu-SelfClear") <= 0 then return false end
			if player:isSkipped(sgs.Player_Discard) then return false end
			sendZhenguLog(player, "xingbu")
			player:skip(sgs.Player_Discard)
		elseif event == sgs.DrawNCards then
			local mark = player:getMark("&xbwuxinglianzhu-SelfClear")
			if mark <= 0 then return false end
			sendZhenguLog(player, "xingbu")
			data:setValue(data:toInt() + 2 * mark)
		else
			if player:getPhase() ~= sgs.Player_Play then return false end
			local mark = player:getMark("&xbfukuangdongzhu-SelfClear")
			if mark <= 0 then return false end
			local use = data:toCardUse()
			if use.card:isKindOf("SkillCard") or not use.card:hasFlag("tenyearyixiang_first_card") then return false end
			for i = 1, mark do
				if player:isDead() or not player:canDiscard(player, "he") then break end
				sendZhenguLog(player, "xingbu")
				room:askForDiscard(player, "xingbu", 1, 1, false, true)
				player:drawCards(2, "xingbu")
			end
		end
		return false
	end
}

xingbuTMD = sgs.CreateTargetModSkill {
	name = "#xingbuTMD",
	pattern = "Slash",
	residue_func = function(self, player)
		if player:getPhase() == sgs.Player_Play then
			return player:getMark("&xbwuxinglianzhu-SelfClear") - player:getMark("&xbyinghuoshouxin-SelfClear")
		end
		return 0
	end
}

qiaozhou:addSkill(zhiming)
qiaozhou:addSkill(xingbu)
qiaozhou:addSkill(xingbuEffect)
qiaozhou:addSkill(xingbuTMD)
extension:insertRelatedSkills("xingbu", "#xingbuEffect")
extension:insertRelatedSkills("xingbu", "#xingbuTMD")

--OL谯周
ol_qiaozhou = sgs.General(extension, "ol_qiaozhou", "shu", 3)
--ol_qiaozhou:setImage("qiaozhou")

olxingbu = sgs.CreatePhaseChangeSkill {
	name = "olxingbu",
	frequency = sgs.Skill_Frequent,
	on_phasechange = function(self, player, room)
		if player:getPhase() ~= sgs.Player_Finish then return false end
		local shows = room:showDrawPile(player, 3, "olxingbu")

		local red = 0
		for _, id in sgs.qlist(shows) do
			if sgs.Sanguosha:getCard(id):isRed() then
				red = red + 1
			end
		end
		if red > 3 or red < 0 then return false end

		local mark = "olxingbu3"
		if red == 2 then
			mark = "olxingbu2"
		elseif red <= 1 then
			mark = "olxingbu1"
		end

		local to = room:askForPlayerChosen(player, room:getOtherPlayers(player), mark, "@olxingbu-invoke:" .. red)
		room:doAnimate(1, player:objectName(), to:objectName())
		if to:isAlive() then
			room:addPlayerMark(to, "&" .. mark .. "-SelfClear")
		end

		local slash = sgs.Sanguosha:cloneCard("slash")
		for _, id in sgs.qlist(shows) do
			if room:getCardPlace(id) == sgs.Player_PlaceTable then
				slash:addSubcard(id)
			end
		end
		slash:deleteLater()
		if slash:subcardsLength() > 0 then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), "olxingbu",
				"")
			room:throwCard(slash, reason, nil)
		end
		return false
	end
}

olxingbuEffect = sgs.CreateTriggerSkill {
	name = "#olxingbuEffect",
	events = { sgs.EventPhaseChanging, sgs.DrawNCards, sgs.EventPhaseStart },
	can_trigger = function(self, player)
		return player and player:isAlive()
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseChanging then
			if data:toPhaseChange().to ~= sgs.Player_Discard or player:getMark("&olxingbu2-SelfClear") <= 0 then return false end
			if player:isSkipped(sgs.Player_Discard) then return false end
			sendZhenguLog(player, "olxingbu")
			player:skip(sgs.Player_Discard)
		elseif event == sgs.DrawNCards then
			local mark = player:getMark("&olxingbu3-SelfClear")
			if mark <= 0 then return false end
			sendZhenguLog(player, "olxingbu")
			data:setValue(data:toInt() + 2 * mark)
		else
			if player:getPhase() ~= sgs.Player_Start then return false end
			local mark = player:getMark("&olxingbu1-SelfClear")
			if mark <= 0 then return false end
			for i = 0, mark do
				if player:isDead() or player:isKongcheng() then break end
				sendZhenguLog(player, "olxingbu")
				room:askForDiscard(player, "olxingbu", 1, 1)
			end
		end
		return false
	end
}

olxingbuTMD = sgs.CreateTargetModSkill {
	name = "#olxingbuTMD",
	pattern = "Slash",
	residue_func = function(self, player)
		if player:getPhase() == sgs.Player_Play then
			return player:getMark("&olxingbu3-SelfClear") - player:getMark("&olxingbu2-SelfClear")
		end
		return 0
	end
}

ol_qiaozhou:addSkill("zhiming")
ol_qiaozhou:addSkill(olxingbu)
ol_qiaozhou:addSkill(olxingbuEffect)
ol_qiaozhou:addSkill(olxingbuTMD)
extension:insertRelatedSkills("olxingbu", "#olxingbuEffect")
extension:insertRelatedSkills("olxingbu", "#olxingbuTMD")

--OL界贾诩
ol_jiaxu = sgs.General(extension, "ol_jiaxu", "qun", 3)

olwansha = sgs.CreateTriggerSkill {
	name = "olwansha",
	events = { sgs.AskForPeaches, sgs.EnterDying, sgs.QuitDying, sgs.PreventPeach, sgs.AfterPreventPeach, sgs.EventPhaseChanging },
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, player)
		return player
	end,
	priority = { 7, 7, 7 }, --等价于 priority = {7, 7, 7, 2, 2} 因为触发技的默认优先级为2
	on_trigger = function(self, event, player, data, room)
		local dying = data:toDying()
		if event == sgs.AskForPeaches then
			if player:objectName() == room:getAllPlayers():first():objectName() then
				local jiaxu = room:getCurrent()
				if not jiaxu or jiaxu:getPhase() == sgs.Player_NotActive or not jiaxu:hasSkill(self) then return false end
				if jiaxu:hasInnateSkill("olwansha") or not jiaxu:hasSkill("jilve") then
					jiaxu:peiyin(self)
				else
					jiaxu:peiyin("jilve", 3)
				end
				room:notifySkillInvoked(jiaxu, self:objectName())
				local log = sgs.LogMessage()
				log.from = jiaxu
				log.arg = self:objectName()
				if jiaxu:objectName() ~= dying.who:objectName() then
					log.type = "#WanshaTwo"
					log.to:append(dying.who)
				else
					log.type = "#WanshaOne"
				end
				room:sendLog(log)
			end
		elseif event == sgs.PreventPeach then
			local current = room:getCurrent()
			if current and current:isAlive() and current:getPhase() ~= sgs.Player_NotActive and current:hasSkill("olwansha") then
				if player:objectName() ~= current:objectName() and player:objectName() ~= dying.who:objectName() then
					player:setFlags("olwansha")
					room:addPlayerMark(player, "Global_PreventPeach")
				end
			end
		elseif event == sgs.AfterPreventPeach then
			if player:hasFlag("olwansha") and player:getMark("Global_PreventPeach") > 0 then
				player:setFlags("-wansha")
				room:removePlayerMark(player, "Global_PreventPeach")
			end
		elseif event == sgs.EnterDying then
			local current = room:getCurrent()
			if current and current:isAlive() and current:getPhase() ~= sgs.Player_NotActive and current:hasSkill("olwansha") then
				--local dying = room:getCurrentDyingPlayer()
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:objectName() == current:objectName() or p:getMark("olwansha_effected-Clear") > 0 then continue end
					p:addMark("olwansha_effected-Clear")
					room:addPlayerMark(p, "@skill_invalidity")
					for _, p in sgs.qlist(room:getAllPlayers()) do
						room:filterCards(p, p:getCards("he"), true)
					end
					local jsonValue = { 9 }
					room:doBroadcastNotify(sgs.CommandType.S_COMMAND_LOG_EVENT, json.encode(jsonValue))
				end
			end
		else
			if event == sgs.EventPhaseChanging then
				if data:toPhaseChange().to ~= sgs.Player_NotActive then return false end
			end
			for _, p in sgs.qlist(room:getAllPlayers(true)) do
				if p:getMark("olwansha_effected-Clear") <= 0 then continue end
				p:removeMark("olwansha_effected-Clear")
				room:removePlayerMark(p, "@skill_invalidity")
				for _, p in sgs.qlist(room:getAllPlayers()) do
					room:filterCards(p, p:getCards("he"), false)
				end
				local jsonValue = { 9 }
				room:doBroadcastNotify(sgs.CommandType.S_COMMAND_LOG_EVENT, json.encode(jsonValue))
			end
		end
		return false
	end
}

--[[olwanshaInvalidity = sgs.CreateInvaliditySkill{  --成功运行过两次，再后来就会崩了。。
name = "#olwanshaInvalidity",
skill_valid = function(self, player, skill)
	if player:hasSkill("olwansha", true) or player:hasFlag("Global_Dying") then return true end  --hasSkill设置为true，不然会栈溢出，当然这是不应该的
	local al = player:getAliveSiblings()
	al:append(player)
	local wansha = false
	for _,p in sgs.qlist(al) do
		if p:getPhase() ~= sgs.Player_NotActive and p:hasSkill("olwansha", true) then
			wansha = true
			break
		end
	end
	if not wansha then return true end
	for _,p in sgs.qlist(al) do
		if not p:hasFlag("Global_Dying") then continue end
		return skill:getFrequency(player) == sgs.Skill_Compulsory or skill:getFrequency(player) == sgs.Skill_Wake or skill:isAttachedLordSkill()
	end
	return true
end
}]]

olluanwuCard = sgs.CreateSkillCard {
	name = "olluanwu",
	target_fixed = true,
	on_use = function(self, room, source)
		room:removePlayerMark(source, "@olluanwuMark")
		room:doSuperLightbox("ol_jiaxu", "olluanwu")
		for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			if p:isDead() then continue end
			room:cardEffect(self, source, p)
			room:getThread():delay()
		end
		if source:isAlive() then
			local slash = sgs.Sanguosha:cloneCard("slash")
			slash:setSkillName("_olluanwu")
			slash:deleteLater()
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if source:canSlash(p, slash, false) then
					room:askForUseCard(source, "@@olluanwu", "@olluanwu")
					break
				end
			end
		end
	end,
	on_effect = function(self, effect)
		local from, to = effect.from, effect.to
		local room = from:getRoom()

		local distance_list, players = sgs.IntList(), room:getOtherPlayers(to)
		local nearest = to:distanceTo(players:first())
		for _, p in sgs.qlist(players) do
			local distance = to:distanceTo(p)
			distance_list:append(distance)
			nearest = math.min(nearest, distance)
		end

		local luanwu_targets = sgs.SPlayerList()
		for i = 0, distance_list:length() - 1 do
			if distance_list:at(i) == nearest and to:canSlash(players:at(i), nil, false) then
				luanwu_targets:append(players:at(i))
			end
		end

		if luanwu_targets:isEmpty() or not room:askForUseSlashTo(to, luanwu_targets, "@luanwu-slash") then
			room:loseHp(sgs.HpLostStruct(to, 1, "olluanwu", from))
		end
	end
}

olluanwu = sgs.CreateZeroCardViewAsSkill {
	name = "olluanwu",
	frequency = sgs.Skill_Limited,
	limit_mark = "@olluanwuMark",
	response_pattern = "@@olluanwu",
	view_as = function(self, card)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			return olluanwuCard:clone()
		else
			local slash = sgs.Sanguosha:cloneCard("slash")
			slash:setSkillName("_olluanwu")
			return slash
		end
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@olluanwuMark") > 0
	end
}

olluanwuTMD = sgs.CreateTargetModSkill {
	name = "#olluanwuTMD",
	distance_limit_func = function(self, player, card)
		if card:getSkillName() == "olluanwu" then
			return 1000
		end
	end
}

olweimu = sgs.CreateProhibitSkill {
	name = "olweimu",
	is_prohibited = function(self, from, to, card)
		return to:hasSkill(self) and (card:isKindOf("TrickCard") or card:isKindOf("QiceCard")) and card:isBlack() and
		not string.find(card:getSkillName(), "guhuo")
	end
}

olweimuDamage = sgs.CreateTriggerSkill {
	name = "#olweimuDamage",
	events = sgs.DamageInflicted,
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data, room)
		if player:getPhase() == sgs.Player_NotActive or not player:hasSkill("olweimu") then return false end
		local damage = data:toDamage()
		local log = sgs.LogMessage()
		log.type = "#OLWeimuPreventDamage"
		log.from = player
		log.arg = "olweimu"
		log.arg2 = damage.damage
		room:sendLog(log)
		room:notifySkillInvoked(player, "olweimu")
		player:peiyin("olweimu")
		player:drawCards(2 * damage.damage, "olweimu")
		return true
	end
}

ol_jiaxu:addSkill(olwansha)
--ol_jiaxu:addSkill(olwanshaInvalidity)
ol_jiaxu:addSkill(olluanwu)
ol_jiaxu:addSkill(olluanwuTMD)
ol_jiaxu:addSkill(olweimu)
ol_jiaxu:addSkill(olweimuDamage)
--extension:insertRelatedSkills("olwansha", "#olwanshaInvalidity")
extension:insertRelatedSkills("olluanwu", "#olluanwuTMD")
extension:insertRelatedSkills("olweimu", "#olweimuDamage")

--OL界鲁肃
ol_lusu = sgs.General(extension, "ol_lusu", "wu", 3)

olhaoshiCard = sgs.CreateSkillCard {
	name = "olhaoshi",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select, player)
		return #targets == 0 and to_select:objectName() ~= player:objectName() and
		to_select:getHandcardNum() == player:getMark("olhaoshi")
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		room:addPlayerMark(effect.to, "&olhaoshi+#" .. effect.from:objectName())
		room:giveCard(effect.from, effect.to, self, "olhaoshi")
	end
}

olhaoshiVS = sgs.CreateViewAsSkill {
	name = "olhaoshi",
	n = 9999,
	response_pattern = "@@olhaoshi!",
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped() and #selected < math.floor(sgs.Self:getHandcardNum() / 2)
	end,
	view_as = function(self, cards)
		if #cards ~= math.floor(sgs.Self:getHandcardNum() / 2) then return nil end
		local c = olhaoshiCard:clone()
		for i = 1, #cards, 1 do
			c:addSubcard(cards[i])
		end
		return c
	end
}

olhaoshi = sgs.CreateTriggerSkill {
	name = "olhaoshi",
	events = { sgs.DrawNCards, sgs.AfterDrawNCards, sgs.EventPhaseStart },
	view_as_skill = olhaoshiVS,
	can_trigger = function(self, player)
		return player and player:isAlive()
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.DrawNCards then
			if not player:hasSkill(self) or not player:askForSkillInvoke(self) then return false end
			player:peiyin(self)
			player:setFlags("olhaoshi")
			data:setValue(data:toInt() + 2)
		elseif event == sgs.AfterDrawNCards then
			if not player:hasFlag("olhaoshi") then return false end
			player:setFlags("-olhaoshi")
			if player:getHandcardNum() <= 5 then return false end
			local least = room:getOtherPlayers(player):first():getHandcardNum()
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				least = math.min(least, p:getHandcardNum())
			end
			room:setPlayerMark(player, "olhaoshi", least)

			local used = room:askForUseCard(player, "@@olhaoshi!", "@haoshi", -1, sgs.Card_MethodNone)
			if used then return false end

			local beggar
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:getHandcardNum() == least then
					beggar = p
					break
				end
			end
			if not beggar then return false end
			room:addPlayerMark(beggar, "&olhaoshi+#" .. player:objectName())
			local slash = sgs.Sanguosha:cloneCard("slash")
			slash:deleteLater()
			local hands = player:handCards()
			for i = 0, math.floor(player:getHandcardNum() / 2) - 1 do
				slash:addSubcard(hands:at(i))
			end
			if slash:subcardsLength() > 0 then
				room:giveCard(player, beggar, slash, "olhaoshi")
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_RoundStart then return false end
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				room:setPlayerMark(p, "&olhaoshi+#" .. player:objectName(), 0)
			end
		end
		return false
	end
}

olhaoshiEffect = sgs.CreateTriggerSkill {
	name = "#olhaoshiEffect",
	events = sgs.TargetConfirmed,
	on_trigger = function(self, event, player, data, room)
		local use = data:toCardUse()
		if not use.to:contains(player) then return false end
		if not use.card:isKindOf("Slash") and not use.card:isNDTrick() then return false end
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if player:isDead() then return false end
			if p:isDead() or p:getMark("&olhaoshi+#" .. player:objectName()) <= 0 or p:isKongcheng() then continue end
			local card = room:askForCard(p, ".|.|.|hand", "@olhaoshi-give:" .. player:objectName(), data,
				sgs.Card_MethodNone)
			if not card then continue end
			room:giveCard(p, player, card, "olhaoshi")
		end
		return false
	end
}

oldimengCard = sgs.CreateSkillCard {
	name = "oldimeng",
	filter = function(self, targets, to_select, player)
		if to_select:objectName() == player:objectName() then return false end
		if #targets == 0 then return true end
		if #targets == 1 then
			return math.abs(to_select:getHandcardNum() - targets[1]:getHandcardNum()) <= player:getCardCount()
		end
		return false
	end,
	feasible = function(self, targets, player)
		return #targets == 2
	end,
	on_use = function(self, room, source, targets)
		local a = targets[1]
		local b = targets[2]
		if a:isDead() or b:isDead() then return end
		room:addPlayerMark(a, "oldimeng_target_" .. b:objectName() .. "-PlayClear")
		a:setFlags("OLDimengTarget")
		b:setFlags("OLDimengTarget")

		local oldimeng_func = function(a, b)
			local n1 = a:getHandcardNum()
			local n2 = b:getHandcardNum()

			local exchangeMove = sgs.CardsMoveList()
			local move1 = sgs.CardsMoveStruct(a:handCards(), b, sgs.Player_PlaceHand,
				sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, a:objectName(), b:objectName(), "oldimeng", ""))
			local move2 = sgs.CardsMoveStruct(b:handCards(), a, sgs.Player_PlaceHand,
				sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, b:objectName(), a:objectName(), "oldimeng", ""))
			exchangeMove:append(move1)
			exchangeMove:append(move2)
			room:moveCardsAtomic(exchangeMove, false)

			local log = sgs.LogMessage()
			log.type = "#Dimeng"
			log.from = a
			log.to:append(b)
			log.arg = n1
			log.arg2 = n2
			room:sendLog(log)
		end

		local ok = pcall(oldimeng_func(a, b))
		if not ok then
			a:setFlags("-OLDimengTarget")
			b:setFlags("-OLDimengTarget")
		end

		a:setFlags("-OLDimengTarget")
		b:setFlags("-OLDimengTarget")
	end
}

oldimengVS = sgs.CreateZeroCardViewAsSkill {
	name = "oldimeng",
	view_as = function(self, card)
		return oldimengCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#oldimeng")
	end
}

oldimeng = sgs.CreateTriggerSkill {
	name = "oldimeng",
	events = sgs.EventPhaseEnd,
	view_as_skill = oldimengVS,
	can_trigger = function(self, player)
		return player and player:isAlive() and player:canDiscard(player, "he")
	end,
	on_trigger = function(self, event, player, data, room)
		if player:getPhase() ~= sgs.Player_Play then return false end
		local send = true
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if player:isDead() or not player:canDiscard(player, "he") then return false end
			for _, q in sgs.qlist(room:getAllPlayers()) do
				if player:isDead() or not player:canDiscard(player, "he") then return false end
				local mark = p:getMark("oldimeng_target_" .. q:objectName() .. "-PlayClear")
				for i = 1, mark do
					if player:isDead() or not player:canDiscard(player, "he") then return false end
					local phand, qhand = p:getHandcardNum(), q:getHandcardNum()
					local num = math.abs(phand - qhand)
					if num == 0 then break end
					if send then
						send = false
						sendZhenguLog(player, self:objectName())
					end
					room:askForDiscard(player, self:objectName(), num, num, false, true)
				end
			end
		end
		return false
	end
}

ol_lusu:addSkill(olhaoshi)
ol_lusu:addSkill(olhaoshiEffect)
ol_lusu:addSkill(oldimeng)
extension:insertRelatedSkills("olhaoshi", "#olhaoshiEffect")

--刘琦-第二版
second_liuqi = sgs.General(extension, "second_liuqi", "qun", 3)

secondwenji = sgs.CreatePhaseChangeSkill {
	name = "secondwenji",
	on_phasechange = function(self, player, room)
		if player:getPhase() ~= sgs.Player_Play then return false end
		local sp = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:isNude() then continue end
			sp:append(p)
		end
		if sp:isEmpty() then return false end

		local target = room:askForPlayerChosen(player, sp, self:objectName(), "@wenji-invoke", true, true)
		if not target then return false end
		player:peiyin(self)
		if target:isDead() or target:isNude() then return false end

		local data = sgs.QVariant()
		data:setValue(player)
		local card = room:askForCard(target, "..", "wenji-give:" .. player:objectName(), data, sgs.Card_MethodNone)
		if not card then
			card = target:getCards("he"):at(math.random(0, target:getCards("he"):length() - 1))
		end
		if not card then return false end
		room:giveCard(target, player, card, self:objectName())

		if player:isDead() then return false end
		local str = card:getType()
		room:setPlayerMark(player, "&secondwenji+" .. str .. "-Clear", 1)
		return false
	end
}

secondwenjiEffect = sgs.CreateTriggerSkill {
	name = "#secondwenjiEffect",
	events = sgs.CardUsed,
	can_trigger = function(self, player)
		return player and player:isAlive()
	end,
	on_trigger = function(self, event, player, data, room)
		if player:getPhase() == sgs.Player_NotActive then return false end
		local use = data:toCardUse()
		if use.card:isKindOf("SkillCard") then return false end
		local str = use.card:getType()
		if player:getMark("&secondwenji+" .. str .. "-Clear") <= 0 then return false end
		local no_respond_list = use.no_respond_list
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			table.insert(no_respond_list, p:objectName())
		end
		use.no_respond_list = no_respond_list
		data:setValue(use)
		return false
	end
}

secondtunjiang = sgs.CreatePhaseChangeSkill {
	name = "secondtunjiang",
	frequency = sgs.Skill_Frequent,
	on_phasechange = function(self, player, room)
		if player:getPhase() ~= sgs.Player_Finish or player:getMark("tunjiang-Clear") > 0 then return false end
		if not player:askForSkillInvoke(self) then return false end
		player:peiyin(self)
		local kingdoms = {}
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			local kingdom = p:getKingdom()
			if not table.contains(kingdoms, kingdom) then
				table.insert(kingdoms, kingdom)
			end
		end
		player:drawCards(#kingdoms, self:objectName())
		return false
	end
}

second_liuqi:addSkill(secondwenji)
second_liuqi:addSkill(secondwenjiEffect)
second_liuqi:addSkill(secondtunjiang)
extension:insertRelatedSkills("secondwenji", "#secondwenjiEffect")

--唐姬-第二版
second_tangji = sgs.General(extension, "second_tangji", "qun", 3, false)

secondkangge = sgs.CreateTriggerSkill {
	name = "secondkangge",
	events = { sgs.EventPhaseStart, sgs.CardsMoveOneTime, sgs.Dying, sgs.Death },
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseStart then
			if player:getMark("jianjie_Round-Keep") ~= 1 or player:getPhase() ~= sgs.Player_RoundStart then return false end
			local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(),
				"@kangge-target", false, true)
			player:peiyin(self)
			room:setPlayerMark(target, "&secondkangge+#" .. player:objectName(), 1)
		elseif event == sgs.Dying then
			if player:getMark("secondkangge_lun") > 0 then return false end
			local dying = data:toDying()
			if dying.who:getMark("&secondkangge+#" .. player:objectName()) <= 0 then return false end
			if not player:askForSkillInvoke(self, dying.who) then return false end
			player:peiyin(self)
			room:addPlayerMark(player, "secondkangge_lun")
			local recover_num = math.min(1 - dying.who:getHp(), dying.who:getMaxHp() - dying.who:getHp())
			room:recover(dying.who, sgs.RecoverStruct(player, nil, recover_num))
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who:getMark("&secondkangge+#" .. player:objectName()) <= 0 then return false end
			room:sendCompulsoryTriggerLog(player, self)
			player:throwAllHandCardsAndEquips()
			room:loseHp(sgs.HpLostStruct(player, 1, "secondkangge", player))
		else
			if not room:hasCurrent() or player:getMark("secondkangge-Clear") > 2 then return false end
			local move = data:toMoveOneTime()
			if not move.to or move.to:getMark("&secondkangge+#" .. player:objectName()) <= 0 or move.to:getPhase() ~= sgs.Player_NotActive then return false end
			if move.to_place ~= sgs.Player_PlaceHand then return false end
			local num = math.min(3 - player:getMark("secondkangge-Clear"), move.card_ids:length())
			if num <= 0 then return false end
			room:sendCompulsoryTriggerLog(player, self);
			room:addPlayerMark(player, "secondkangge-Clear", num)
			player:drawCards(num, self:objectName())
		end
		return false
	end
}

secondjielie = sgs.CreateTriggerSkill {
	name = "secondjielie",
	events = sgs.DamageInflicted,
	on_trigger = function(self, event, player, data, room)
		local damage = data:toDamage()
		if not damage.from or damage.from:objectName() == player:objectName() or damage.from:getMark("&secondkangge+#" .. player:objectName()) > 0 then return false end
		if damage.damage <= 0 then return false end
		player:setTag("secondjielie_damage_data", data)
		local invoke = player:askForSkillInvoke(self, sgs.QVariant("secondjielie:" .. damage.damage))
		player:removeTag("secondjielie_damage_data")
		if not invoke then return false end
		player:peiyin(self)

		local suit = room:askForSuit(player, self:objectName())
		local log = sgs.LogMessage()
		log.type = "#ChooseSuit"
		log.from = player
		log.arg = sgs.Card_Suit2String(suit)
		room:sendLog(log)
		room:loseHp(sgs.HpLostStruct(player, damage.damage, "secondjielie", player))

		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:isDead() or p:getMark("&secondkangge+#" .. player:objectName()) <= 0 then continue end
			local list = sgs.IntList()
			for _, id in sgs.qlist(room:getDiscardPile()) do
				local card = sgs.Sanguosha:getCard(id)
				if card:getSuit() ~= suit then continue end
				list:append(id)
			end
			if not list:isEmpty() then
				local slash = sgs.Sanguosha:cloneCard("slash")
				slash:deleteLater()
				for i = 1, damage.damage do
					if list:isEmpty() then break end
					local id = list:at(math.random(0, list:length() - 1))
					list:removeOne(id)
					slash:addSubcard(id)
				end
				if slash:subcardsLength() > 0 then
					room:obtainCard(p, slash)
				end
			end
		end
		return true
	end
}

second_tangji:addSkill(secondkangge)
second_tangji:addSkill(secondjielie)

--杜夫人
dufuren = sgs.General(extension, "dufuren", "wei", 3, false)

yise = sgs.CreateTriggerSkill {
	name = "yise",
	events = sgs.CardsMoveOneTime,
	on_trigger = function(self, event, player, data, room)
		local move = data:toMoveOneTime()
		if not move.to or not move.from or move.to:objectName() == move.from:objectName() or move.from:objectName() ~= player:objectName() then return false end
		if not move.from_places:contains(sgs.Player_PlaceEquip) and not move.from_places:contains(sgs.Player_PlaceHand) then return false end

		local to = room:findPlayerByObjectName(move.to:objectName())
		if not to or to:isDead() then return false end

		local red, black = false, false
		for i = 0, move.card_ids:length() - 1 do
			if move.from_places:at(i) == sgs.Player_PlaceEquip or move.from_places:at(i) == sgs.Player_PlaceHand then
				local card = sgs.Sanguosha:getCard(move.card_ids:at(i))
				if card:isRed() then
					red = true
				elseif card:isBlack() then
					black = true
				end
				if red and black then break end
			end
		end

		if red then
			if to:isWounded() and player:askForSkillInvoke(self, to) then
				player:peiyin(self)
				room:recover(to, sgs.RecoverStruct(player))
			end
		end

		if black and to:isAlive() then
			room:sendCompulsoryTriggerLog(player, self)
			room:addPlayerMark(to, "&yise")
		end
		return false
	end
}

yiseDamage = sgs.CreateTriggerSkill {
	name = "#yiseDamage",
	events = sgs.DamageInflicted,
	can_trigger = function(self, player)
		return player and player:isAlive() and player:getMark("&yise") > 0
	end,
	on_trigger = function(self, event, player, data, room)
		local damage = data:toDamage()
		if not damage.card or not damage.card:isKindOf("Slash") then return false end
		local mark = player:getMark("&yise")
		if mark <= 0 then return false end
		room:setPlayerMark(player, "&yise", 0)
		sendZhenguLog(player, "yise")
		damage.damage = damage.damage + mark
		data:setValue(damage)
		return false
	end
}

shunshi = sgs.CreateTriggerSkill {
	name = "shunshi",
	events = { sgs.EventPhaseStart, sgs.Damaged },
	on_trigger = function(self, event, player, data, room)
		if player:isNude() then return false end

		if event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_Start then return false end
		end

		local players = room:getOtherPlayers(player)

		if event == sgs.Damaged then
			if player:getPhase() ~= sgs.Player_NotActive then return false end
			local damage = data:toDamage()
			if damage.from then players:removeOne(damage.from) end
		end

		if players:isEmpty() then return false end

		for _, p in sgs.qlist(players) do --prepare for ai
			p:setFlags("shunshi")
		end

		local cards = sgs.IntList()
		for _, id in sgs.qlist(player:handCards()) do
			cards:append(id)
		end
		for _, id in sgs.qlist(player:getEquipsId()) do
			cards:append(id)
		end
		local move = room:askForYijiStruct(player, cards, self:objectName(), false, false, true, 1, players,
			sgs.CardMoveReason(), "@shunshi-give", true, false)
		if move.to and not move.card_ids:isEmpty() then
			for _, p in sgs.qlist(players) do
				p:setFlags("-shunshi")
			end
			local to = room:findPlayerByObjectName(move.to:objectName())
			if not to or to:isDead() then return false end
			room:giveCard(player, to, move.card_ids, self:objectName())
			if player:isAlive() then
				room:addPlayerMark(player, "&shunshi-SelfClear")
				room:addPlayerMark(player, "shunshi_draw")
				room:addPlayerMark(player, "shunshi_play")
				room:addPlayerMark(player, "shunshi_discard")
			end
		end
		return false
	end
}

shunshiEffect = sgs.CreateTriggerSkill {
	name = "#shunshiEffect",
	events = { sgs.DrawNCards, sgs.EventPhaseStart },
	can_trigger = function(self, player)
		return player and player:isAlive()
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.DrawNCards then
			local mark = player:getMark("shunshi_draw")
			if mark <= 0 then return false end
			room:setPlayerMark(player, "shunshi_draw", 0)
			sendZhenguLog(player, "shunshi")
			data:setValue(data:toInt() + mark)
		else
			if player:getPhase() == sgs.Player_Play then
				local mark = player:getMark("shunshi_play")
				if mark <= 0 then return false end
				room:setPlayerMark(player, "shunshi_play", 0)
				room:addPlayerMark(player, "shunshi_play-PlayClear", mark)
			elseif player:getPhase() == sgs.Player_Discard then
				room:setPlayerMark(player, "&shunshi-SelfClear", 0)
				local mark = player:getMark("shunshi_discard")
				if mark <= 0 then return false end
				room:setPlayerMark(player, "shunshi_discard", 0)
				room:addPlayerMark(player, "shunshi_discard-Self" .. sgs.Player_Discard .. "Clear", mark)
			end
		end
		return false
	end
}

shunshiTMD = sgs.CreateTargetModSkill {
	name = "#shunshiTMD",
	pattern = "Slash",
	residue_func = function(self, player)
		return (player:getPhase() == sgs.Player_Play and player:getMark("shunshi_play-PlayClear")) or 0
	end
}

shunshiMAX = sgs.CreateMaxCardsSkill {
	name = "#shunshiMAX",
	extra_func = function(self, player)
		return (player:getPhase() == sgs.Player_Discard and player:getMark("shunshi_discard-Self" .. sgs.Player_Discard .. "Clear")) or
		0
	end
}

dufuren:addSkill(yise)
dufuren:addSkill(yiseDamage)
dufuren:addSkill(shunshi)
dufuren:addSkill(shunshiEffect)
dufuren:addSkill(shunshiTMD)
dufuren:addSkill(shunshiMAX)
extension:insertRelatedSkills("yise", "#yiseDamage")
extension:insertRelatedSkills("shunshi", "#shunshiEffect")
extension:insertRelatedSkills("shunshi", "#shunshiTMD")
extension:insertRelatedSkills("shunshi", "#shunshiMAX")

--OL王荣
ol_wangrong = sgs.General(extension, "ol_wangrong", "qun", 3, false)

fengzi = sgs.CreateTriggerSkill {
	name = "fengzi",
	events = sgs.CardUsed,
	on_trigger = function(self, event, player, data, room)
		if player:getPhase() ~= sgs.Player_Play or player:getMark("fengzi_Used-PlayClear") > 0 then return false end
		local use = data:toCardUse()
		if not use.card:isKindOf("BasicCard") and not use.card:isNDTrick() then return false end
		if not player:canDiscard(player, "h") then return false end
		local typee = (use.card:isKindOf("BasicCard") and "BasicCard") or "TrickCard"
		local card = room:askForCard(player, "" .. typee .. "|.|.|hand",
			"@fengzi-discard:" .. use.card:getType() .. "::" .. use.card:objectName(), data, self:objectName())
		if not card then return false end
		player:peiyin(self)
		player:addMark("fengzi_Used-PlayClear")
		room:setCardFlag(use.card, "fengzi_double")
		return false
	end
}

fengziDouble = sgs.CreateTriggerSkill {
	name = "#fengziDouble",
	events = sgs.CardFinished,
	can_trigger = function(self, player)
		return player and player:isAlive()
	end,
	on_trigger = function(self, event, player, data, room)
		local use = data:toCardUse()
		if not use.card:isKindOf("BasicCard") and not use.card:isNDTrick() then return false end
		if not use.card:hasFlag("fengzi_double") then return false end
		room:setCardFlag(use.card, "-fengzi_double")
		--if use.card:hasPreAction() then end
		if use.card:isKindOf("Slash") then --【杀】需要单独处理
			for _, p in sgs.qlist(use.to) do
				local se = sgs.SlashEffectStruct()
				se.from = use.from
				se.to = p
				se.slash = use.card
				se.nullified = table.contains(use.nullified_list, "_ALL_TARGETS") or
				table.contains(use.nullified_list, p:objectName())
				se.no_offset = table.contains(use.no_offset_list, "_ALL_TARGETS") or
				table.contains(use.no_offset_list, p:objectName())
				se.no_respond = table.contains(use.no_respond_list, "_ALL_TARGETS") or
				table.contains(use.no_respond_list, p:objectName())
				se.multiple = use.to:length() > 1
				se.nature = sgs.DamageStruct_Normal
				if use.card:objectName() == "fire_slash" then
					se.nature = sgs.DamageStruct_Fire
				elseif use.card:objectName() == "thunder_slash" then
					se.nature = sgs.DamageStruct_Thunder
				elseif use.card:objectName() == "ice_slash" then
					se.nature = sgs.DamageStruct_Ice
				end
				if use.from:getMark("drank") > 0 then
					room:setCardFlag(use.card, "drank")
					use.card:setTag("drank", sgs.QVariant(use.from:getMark("drank")))
				end
				se.drank = use.card:getTag("drank"):toInt()
				room:slashEffect(se)
			end
		else
			use.card:use(room, use.from, use.to)
		end
		return false
	end
}

jizhanw = sgs.CreatePhaseChangeSkill {
	name = "jizhanw",
	on_phasechange = function(self, player, room)
		if player:getPhase() ~= sgs.Player_Draw or not player:askForSkillInvoke(self) then return false end
		player:peiyin(self)

		local gets = sgs.IntList()
		local ids = room:showDrawPile(player, 1, self:objectName())
		gets:append(ids:first())
		local num = sgs.Sanguosha:getEngineCard(ids:first()):getNumber()

		while player:isAlive() do
			local choices = {}
			table.insert(choices, "more=" .. num)
			table.insert(choices, "less=" .. num)
			table.insert(choices, "cancel")
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"), sgs.QVariant(num))
			if choice == "cancel" then break end

			ids = room:showDrawPile(player, 1, self:objectName())
			gets:append(ids:first())
			local next_num = sgs.Sanguosha:getEngineCard(ids:first()):getNumber()
			if (next_num == num) or (next_num > num and choice:startsWith("less")) or (next_num < num and choice:startsWith("more")) then break end
			num = next_num
		end

		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:deleteLater()
		for _, id in sgs.qlist(gets) do
			if room:getCardPlace(id) ~= sgs.Player_PlaceTable then continue end
			slash:addSubcard(id)
		end

		if slash:subcardsLength() > 0 then
			if player:isDead() then
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(),
					self:objectName(), "")
				room:throwCard(slash, reason, nil)
				return true
			end
			room:obtainCard(player, slash)
		end
		return true
	end
}

fusong = sgs.CreateTriggerSkill {
	name = "fusong",
	events = sgs.Death,
	can_trigger = function(self, player)
		return player and player:hasSkill(self)
	end,
	on_trigger = function(self, event, player, data, room)
		local death = data:toDeath()
		if death.who:objectName() ~= player:objectName() then return false end

		local players = sgs.SPlayerList()
		local max_hp = player:getMaxHp()
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:getMaxHp() <= max_hp then continue end
			players:append(p)
		end

		if players:isEmpty() then return false end
		local target = room:askForPlayerChosen(player, players, self:objectName(), "@fusong-invoke", true, true)
		if not target then return false end
		player:peiyin(self)

		local skills = {}
		if not target:hasSkill("fengzi", true) then table.insert(skills, "fengzi") end
		if not target:hasSkill("jizhanw", true) then table.insert(skills, "jizhanw") end
		if #skills == 0 then return false end
		local skill = room:askForChoice(target, self:objectName(), table.concat(skills, "+"))
		room:acquireSkill(target, skill)
		return false
	end
}

ol_wangrong:addSkill(fengzi)
ol_wangrong:addSkill(fengziDouble)
ol_wangrong:addSkill(jizhanw)
ol_wangrong:addSkill(fusong)
extension:insertRelatedSkills("fengzi", "#fengziDouble")

--袁涣
yuanhuan = sgs.General(extension, "yuanhuan", "wei", 3)

qingjue = sgs.CreateTriggerSkill {
	name = "qingjue",
	events = sgs.TargetSpecifying,
	can_trigger = function(self, player)
		return player and player:isAlive()
	end,
	on_trigger = function(self, event, player, data, room)
		local use = data:toCardUse()
		if use.card:isKindOf("SkillCard") or use.to:length() ~= 1 then return false end
		local to = use.to:first()
		if player:getHp() <= to:getHp() or to:hasFlag("Global_Dying") then return false end
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:isDead() or not p:hasSkill(self) or p:objectName() == to:objectName() or p:getMark("qingjue_lun") > 0 then return false end
			if not p:askForSkillInvoke(self, data) then continue end
			p:peiyin(self)
			room:addPlayerMark(p, "qingjue_lun")
			p:drawCards(1, self:objectName())
			if p:canPindian(player) then
				if p:pindian(player, self:objectName()) then
					use.to = sgs.SPlayerList()
					data:setValue(use)
				else
					use.to:removeOne(to)
					use.to:append(p)
					data:setValue(use)
					--room:getThread():trigger(sgs.TargetSpecifying, room, player, data)
				end
			end
			break
		end
		return false
	end
}

fengjie = sgs.CreatePhaseChangeSkill {
	name = "fengjie",
	frequency = sgs.Skill_Compulsory,
	on_phasechange = function(self, player, room)
		if player:getPhase() ~= sgs.Player_Start then return false end
		local t = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "@fengjie-invoke",
			false, true)
		player:peiyin(self)
		room:setPlayerMark(t, "&fengjie+#" .. player:objectName(), 1)
		local tag = sgs.QVariant()
		tag:setValue(t)
		player:setTag("FengjieTarget", tag)
		return false
	end
}

fengjieEffect = sgs.CreateTriggerSkill {
	name = "#fengjieEffect",
	events = { sgs.EventPhaseStart, sgs.Death },
	can_trigger = function(self, player)
		return player
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				player:removeTag("FengjieTarget")
				for _, p in sgs.qlist(room:getAllPlayers()) do
					room:setPlayerMark(p, "&fengjie+#" .. player:objectName(), 0)
				end
			elseif player:getPhase() == sgs.Player_Finish then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:isDead() then continue end
					local t = p:getTag("FengjieTarget"):toPlayer()
					if not t or t:isDead() then continue end

					local hand = p:getHandcardNum()
					local hp = t:getHp()
					if hand > hp and p:canDiscard(p, "h") then
						sendZhenguLog(p, "fengjie")
						room:askForDiscard(p, "fengjie", hand - hp, hand - hp)
					elseif hand < hp then
						hp = math.min(4, hp)
						if hp > hand then
							sendZhenguLog(p, "fengjie")
							p:drawCards(hp - hand, "fengjie")
						end
					end
				end
			end
		else
			local death = data:toDeath()
			local who = death.who
			if who:objectName() ~= player:objectName() then return false end
			who:removeTag("FengjieTarget")
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, "&fengjie+#" .. who:objectName(), 0)
			end
		end
		return false
	end
}

yuanhuan:addSkill(qingjue)
yuanhuan:addSkill(fengjie)
yuanhuan:addSkill(fengjieEffect)
extension:insertRelatedSkills("fengjie", "#fengjieEffect")

--宗预
zongyu = sgs.General(extension, "zongyu", "shu", 3)

local MoveEJDisabledList = function(player, target)
	local ids = sgs.IntList()
	for _, c in sgs.qlist(target:getEquips()) do
		local n = c:getRealCard():toEquipCard():location()
		if player:getEquip(n) or not player:hasEquipArea(n) then
			ids:append(c:getEffectiveId())
		end
	end
	for _, c in sgs.qlist(target:getJudgingArea()) do
		if player:containsTrick(c:objectName()) then --target:isProhibited(player, c)
			ids:append(c:getEffectiveId())
		end
	end
	return ids
end

zhibian = sgs.CreatePhaseChangeSkill {
	name = "zhibian",
	on_phasechange = function(self, player, room)
		if player:getPhase() ~= sgs.Player_Start then return false end
		local sp = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if player:canPindian(p) then
				sp:append(p)
			end
		end
		if sp:isEmpty() then return false end
		local t = room:askForPlayerChosen(player, sp, self:objectName(), "@zhibian-invoke", true, true)
		if not t then return false end
		player:peiyin(self)

		if player:pindian(t, self:objectName()) then
			local choices, data, ids = {}, sgs.QVariant(), MoveEJDisabledList(player, t)
			data:setValue(t)
			if t:getCards("ej"):length() - ids:length() > 0 then
				table.insert(choices, "move=" .. t:objectName())
			end
			if player:isWounded() then
				table.insert(choices, "recover")
			end
			table.insert(choices, "beishui")
			table.insert(choices, "cancel")

			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"), data)
			if choice == "cancel" then return false end
			if choice == "recover" then
				room:recover(player, sgs.RecoverStruct(player))
			elseif choice:startsWith("move") then
				local id = room:askForCardChosen(player, t, "ej", self:objectName(), false, sgs.Card_MethodNone, ids)
				local place = room:getCardPlace(id)
				room:moveCardTo(sgs.Sanguosha:getCard(id), player, place)
			else
				room:setPlayerMark(player, "&zhibian", 1)
				if t:getCards("ej"):length() - ids:length() > 0 and player:isAlive() and t:isAlive() then
					local id = room:askForCardChosen(player, t, "ej", self:objectName(), false, sgs.Card_MethodNone, ids)
					local place = room:getCardPlace(id)
					room:moveCardTo(sgs.Sanguosha:getCard(id), player, place)
				end
				if player:isAlive() and player:isWounded() then
					room:recover(player, sgs.RecoverStruct(player))
				end
			end
		else
			room:loseHp(sgs.HpLostStruct(player, 1, "zhibian", player))
		end
		return false
	end
}

zhibianSkip = sgs.CreateTriggerSkill {
	name = "#zhibianSkip",
	events = sgs.EventPhaseChanging,
	can_trigger = function(self, player)
		return player and player:isAlive() and player:getMark("&zhibian") > 0
	end,
	on_trigger = function(self, event, player, data, room)
		if data:toPhaseChange().to ~= sgs.Player_Draw then return false end
		if player:isSkipped(sgs.Player_Draw) then return false end
		room:setPlayerMark(player, "&zhibian", 0)
		sendZhenguLog(player, "zhibian")
		player:skip(sgs.Player_Draw)
		return false
	end
}

yuyanzy = sgs.CreateTriggerSkill {
	name = "yuyanzy",
	events = sgs.TargetConfirming,
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data, room)
		local use = data:toCardUse()
		if not use.card:isKindOf("Slash") or use.card:isVirtualCard() then return false end
		if not use.to:contains(player) or use.from:isDead() or use.from:getHp() <= player:getHp() then return false end
		room:sendCompulsoryTriggerLog(player, self)
		local num = use.card:getNumber()

		if num >= 13 or use.from:isNude() then
			use.to = sgs.SPlayerList()
			data:setValue(use)
			return false
		end

		local card = room:askForCard(use.from, ".|.|" .. num + 1 .. "~13",
			"@yuyanzy-give:" .. player:objectName() .. "::" .. num, data, sgs.Card_MethodNone)
		if card then
			room:giveCard(use.from, player, card, self:objectName(), true)
		else
			use.to = sgs.SPlayerList()
			data:setValue(use)
			return false
		end
		return false
	end
}

zongyu:addSkill(zhibian)
zongyu:addSkill(zhibianSkip)
zongyu:addSkill(yuyanzy)
extension:insertRelatedSkills("zhibian", "#zhibianSkip")

--陈武＆董袭
mobile_chenwudongxi = sgs.General(extension, "mobile_chenwudongxi", "wu", 4)

yilie = sgs.CreatePhaseChangeSkill {
	name = "yilie",
	frequency = sgs.Skill_Frequent,
	on_phasechange = function(self, player, room)
		if player:getPhase() ~= sgs.Player_Play then return false end
		if not player:askForSkillInvoke(self) then return false end
		player:peiyin(self)

		local choice = room:askForChoice(player, self:objectName(), "slash+draw+beishui")
		local log = sgs.LogMessage()
		log.from = player
		log.type = "#FumianFirstChoice"
		log.arg = "yilie:" .. choice
		room:sendLog(log)

		if choice == "slash" then
			room:addPlayerMark(player, "yilie_slash-PlayClear")
		elseif choice == "draw" then
			room:addPlayerMark(player, "yilie_draw-PlayClear")
		else
			room:loseHp(sgs.HpLostStruct(player, 1, "yilie", player))
			if player:isDead() then return false end
			room:addPlayerMark(player, "yilie_slash-PlayClear")
			room:addPlayerMark(player, "yilie_draw-PlayClear")
		end
		return false
	end
}

yilieTMD = sgs.CreateTargetModSkill {
	name = "#yilieTMD",
	pattern = "Slash",
	residue_func = function(self, player)
		return (player:getPhase() == sgs.Player_Play and player:getMark("yilie_slash-PlayClear")) or 0
	end
}

yilieSlash = sgs.CreateTriggerSkill {
	name = "#yilieSlash",
	events = sgs.SlashMissed,
	can_trigger = function(self, player)
		return player and player:isAlive() and player:getMark("yilie_draw-PlayClear") > 0 and
		player:getPhase() == sgs.Player_Play
	end,
	on_trigger = function(self, event, player, data, room)
		local mark = player:getMark("yilie_draw-PlayClear")
		for i = 1, mark do
			if player:isDead() then return false end
			sendZhenguLog(player, "yilie")
			player:drawCards(1, "yilie")
		end
		return false
	end
}

mobilefenmingCard = sgs.CreateSkillCard {
	name = "mobilefenming",
	filter = function(self, targets, to_select, player)
		return to_select:getHp() <= player:getHp() and #targets == 0
	end,
	on_effect = function(self, effect)
		local from, to, room = effect.from, effect.to, effect.from:getRoom()
		if to:isDead() then return end
		if to:isChained() then
			if from:isDead() then return end
			local flags = "he"
			if from:objectName() == to:objectName() then flags = "e" end
			if to:getCards(flags):length() <= 0 then return end
			local id = room:askForCardChosen(from, to, flags, "mobilefenming")
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, from:objectName())
			room:obtainCard(effect.from, sgs.Sanguosha:getCard(id), reason, false)
		else
			room:setPlayerChained(to)
		end
	end
}

mobilefenming = sgs.CreateZeroCardViewAsSkill {
	name = "mobilefenming",
	view_as = function()
		return mobilefenmingCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#mobilefenming")
	end
}

mobile_chenwudongxi:addSkill(yilie)
mobile_chenwudongxi:addSkill(yilieTMD)
mobile_chenwudongxi:addSkill(yilieSlash)
mobile_chenwudongxi:addSkill(mobilefenming)
extension:insertRelatedSkills("yilie", "#yilieTMD")
extension:insertRelatedSkills("yilie", "#yilieSlash")

--南华老仙
nanhualaoxian = sgs.General(extension, "nanhualaoxian", "qun", 4)

gongxiu = sgs.CreateTriggerSkill {
	name = "gongxiu",
	events = sgs.EventPhaseChanging,
	on_trigger = function(self, event, player, data, room)
		if data:toPhaseChange().to ~= sgs.Player_NotActive then return false end
		if player:getMark("jinghe_Used-Clear") <= 0 then return false end

		local choices = {}
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:getMark("jinghe_GetSkill-Clear") > 0 then
				table.insert(choices, "draw")
				break
			end
		end
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:getMark("jinghe_GetSkill-Clear") <= 0 and not p:isKongcheng() then
				table.insert(choices, "discard")
				break
			end
		end

		if #choices == 0 or not player:askForSkillInvoke(self) then return false end
		player:peiyin(self)
		local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
		if choice == "draw" then
			local sp = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("jinghe_GetSkill-Clear") > 0 then
					sp:append(p)
				end
			end
			if not sp:isEmpty() then
				room:drawCards(sp, 1, self:objectName())
			end
		else
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:isAlive() and p:getMark("jinghe_GetSkill-Clear") <= 0 and p:canDiscard(p, "h") then
					room:askForDiscard(p, self:objectName(), 1, 1)
				end
			end
		end
		return false
	end
}

jingheCard = sgs.CreateSkillCard {
	name = "jinghe",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		return #targets < self:subcardsLength()
	end,
	feasible = function(self, targets, player)
		return #targets == self:subcardsLength()
	end,
	on_use = function(self, room, source, targets)
		for _, id in sgs.qlist(self:getSubcards()) do
			room:showCard(source, id)
		end

		local tianshu_skills = { "tenyearleiji", "biyue", "nostuxi", "mingce", "zhiyan", "nhyinbing", "nhhuoqi",
			"nhguizhu", "nhxianshou", "nhlundao", "nhguanyue", "nhyanzheng" }

		for _, p in ipairs(targets) do
			if p:isDead() then continue end
			local new_tianshu_skills = {}
			for _, sk in ipairs(tianshu_skills) do
				if p:hasSkill(sk, true) or not sgs.Sanguosha:getSkill(sk) then continue end
				table.insert(new_tianshu_skills, sk)
			end
			if #new_tianshu_skills <= 0 then continue end

			local skill = room:askForChoice(p, self:objectName(), table.concat(new_tianshu_skills, "+"))
			room:addPlayerMark(p, "jinghe_GetSkill-Clear")
			local skills = p:getTag("jinghe_GetSkills_" .. source:objectName()):toString():split(",")
			if not table.contains(skills, skill) then
				table.insert(skills, skill)
				p:setTag("jinghe_GetSkills_" .. source:objectName(), sgs.QVariant(table.concat(skills, ",")))
			end
			room:acquireSkill(p, skill)
		end
	end
}

jingheVS = sgs.CreateViewAsSkill {
	name = "jinghe",
	n = 4,
	view_filter = function(self, selected, to_select)
		if to_select:isEquipped() or #selected > 3 then return false end
		for _, c in ipairs(selected) do
			if to_select:sameNameWith(c) then return false end
		end
		return true
	end,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local c = jingheCard:clone()
		for i = 1, #cards do
			c:addSubcard(cards[i])
		end
		return c
	end,
	enabled_at_play = function(self, player)
		return player:getMark("jinghe_Used-Clear") <= 0
	end
}

jinghe = sgs.CreateTriggerSkill {
	name = "jinghe",
	events = { sgs.PreCardUsed, sgs.EventPhaseStart, sgs.Death },
	view_as_skill = jingheVS,
	waked_skills = "tenyearleiji,biyue,nostuxi,mingce,zhiyan,nhyinbing,nhhuoqi,nhguizhu,nhxianshou,nhlundao,nhguanyue,nhyanzheng",
	can_trigger = function(self, player)
		return player
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.PreCardUsed then
			local use = data:toCardUse()
			--if not use.card:isKindOf("jingheCard") or not room:hasCurrent() then return false end
			if not use.card:isKindOf("SkillCard") or use.card:objectName() ~= "jinghe" or not room:hasCurrent() then return false end
			room:addPlayerMark(use.from, "jinghe_Used-Clear")
		else
			if event == sgs.EventPhaseStart then
				if player:getPhase() ~= sgs.Player_RoundStart then return false end
			elseif event == sgs.Death then
				local death = data:toDeath()
				local who = death.who
				if who:objectName() ~= player:objectName() then return false end
			end

			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:isDead() then continue end
				local skills = p:getTag("jinghe_GetSkills_" .. player:objectName()):toString():split(",")
				p:removeTag("jinghe_GetSkills_" .. player:objectName())
				if #skills == 0 or skills[1] == "" then continue end
				local lose = {}
				for _, sk in ipairs(skills) do
					if p:hasSkill(sk, true) then
						table.insert(lose, "-" .. sk)
					end
				end
				if #lose > 0 then
					room:handleAcquireDetachSkills(p, table.concat(lose, "|"))
				end
			end
		end
		return false
	end
}

nanhualaoxian:addSkill(gongxiu)
nanhualaoxian:addSkill(jinghe)

nhyinbing = sgs.CreateTriggerSkill {
	name = "nhyinbing",
	events = { sgs.Predamage, sgs.HpLost },
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, player)
		return player and player:isAlive()
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.Predamage then
			if not player:hasSkill(self) then return false end
			local damage = data:toDamage()
			if not damage.card or not damage.card:isKindOf("Slash") or damage.to:isDead() then return false end
			room:sendCompulsoryTriggerLog(player, self)
			room:loseHp(sgs.HpLostStruct(damage.to, damage.damage, "nhyinbing", player, damage.ignore_hujia))
			return true
		else
			--local sp = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:isDead() or not p:hasSkill(self) then return false end
				room:sendCompulsoryTriggerLog(p, self)
				p:drawCards(1, self:objectName())
			end
		end
		return false
	end
}

nhhuoqiCard = sgs.CreateSkillCard {
	name = "nhhuoqi",
	filter = function(self, targets, to_select, player)
		local hp = player:getHp()
		for _, p in sgs.qlist(player:getAliveSiblings()) do
			hp = math.min(hp, p:getHp())
		end
		return #targets == 0 and to_select:getHp() == hp
	end,
	on_effect = function(self, effect)
		local room, from, to = effect.from:getRoom(), effect.from, effect.to
		room:recover(to, sgs.RecoverStruct((from:isAlive() and from) or nil))
		to:drawCards(1, "nhhuoqi")
	end
}

nhhuoqi = sgs.CreateOneCardViewAsSkill {
	name = "nhhuoqi",
	filter_pattern = ".!",
	view_as = function(self, card)
		local c = nhhuoqiCard:clone()
		c:addSubcard(card)
		return c
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#nhhuoqi")
	end
}

nhguizhu = sgs.CreateTriggerSkill {
	name = "nhguizhu",
	events = sgs.Dying,
	frequency = sgs.Skill_Frequent,
	on_trigger = function(self, event, player, data, room)
		if player:getMark("nhguizhu_Used-Clear") > 0 then return false end
		if not player:askForSkillInvoke(self) then return false end
		player:peiyin(self)
		player:addMark("nhguizhu_Used-Clear")
		player:drawCards(2, self:objectName())
		return false
	end
}

nhxianshouCard = sgs.CreateSkillCard {
	name = "nhxianshou",
	filter = function(self, targets, to_select, player)
		return #targets == 0
	end,
	on_effect = function(self, effect)
		local to, room = effect.to, effect.to:getRoom()
		local x = (to:getLostHp() > 0 and 1) or 2
		to:drawCards(x, self:objectName())
	end
}

nhxianshou = sgs.CreateZeroCardViewAsSkill {
	name = "nhxianshou",
	view_as = function(self, card)
		return nhxianshouCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#nhxianshou")
	end
}

nhlundao = sgs.CreateMasochismSkill {
	name = "nhlundao",
	on_damaged = function(self, player, damage)
		local room, from = player:getRoom(), damage.from
		if not from or from:isDead() then return end
		local hand, fhand = player:getHandcardNum(), from:getHandcardNum()
		if fhand < hand then
			room:sendCompulsoryTriggerLog(player, self)
			player:drawCards(1, self:objectName())
			return
		end
		if fhand > hand and player:canDiscard(from, "he") then
			if not player:askForSkillInvoke(self, from) then return end
			player:peiyin(self)
			local id = room:askForCardChosen(player, from, "he", self:objectName(), false, sgs.Card_MethodDiscard)
			room:throwCard(id, from, player)
		end
	end
}

nhguanyue = sgs.CreatePhaseChangeSkill {
	name = "nhguanyue",
	frequency = sgs.Skill_Frequent,
	on_phasechange = function(self, player, room)
		if player:getPhase() ~= sgs.Player_Finish then return false end
		if not player:askForSkillInvoke(self) then return false end
		player:peiyin(self)

		local ids = room:getNCards(2, false)
		room:fillAG(ids, player) --偷懒用AG
		local id = room:askForAG(player, ids, false, self:objectName())
		room:clearAG(player)
		ids:removeOne(id)
		room:obtainCard(player, id, false)
		if player:isAlive() then
			room:askForGuanxing(player, ids, 1)
		else
			room:returnToTopDrawPile(ids)
		end
		return false
	end
}

nhyanzhengCard = sgs.CreateSkillCard {
	name = "nhyanzheng",
	filter = function(self, targets, to_select, player)
		return #targets < player:getMark("nhyanzheng-PlayClear")
	end,
	on_use = function(self, room, source, targets)
		local thread = room:getThread()
		for _, p in ipairs(targets) do
			if p:isDead() then continue end
			room:cardEffect(self, source, p)
			thread:delay()
		end
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		room:damage(sgs.DamageStruct("nhyanzheng", (effect.from:isAlive() and effect.from) or nil, effect.to))
	end
}

nhyanzhengVS = sgs.CreateZeroCardViewAsSkill {
	name = "nhyanzheng",
	response_pattern = "@@nhyanzheng",
	view_as = function(self, card)
		return nhyanzhengCard:clone()
	end
}

nhyanzheng = sgs.CreatePhaseChangeSkill {
	name = "nhyanzheng",
	view_as_skill = nhyanzhengVS,
	on_phasechange = function(self, player, room)
		if player:getPhase() ~= sgs.Player_Start or player:getHandcardNum() <= 1 then return false end
		local card = room:askForCard(player, ".|.|.|hand", "@nhyanzheng-keep", sgs.QVariant(), sgs.Card_MethodNone, nil,
			false, self:objectName())
		if not card then return false end

		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:deleteLater()
		for _, c in sgs.qlist(player:getCards("he")) do
			if c:getEffectiveId() == card:getEffectiveId() or not player:canDiscard(player, c:getEffectiveId()) then continue end
			slash:addSubcard(c)
		end
		local num = slash:subcardsLength()
		if num == 0 then return false end

		room:throwCard(slash, player)
		if player:isDead() then return false end
		room:setPlayerMark(player, "nhyanzheng-PlayClear", num)
		room:askForUseCard(player, "@@nhyanzheng", "@nhyanzheng:" .. num, -1, sgs.Card_MethodNone)
		return false
	end
}

--杨芷
nos_jin_yangzhi = sgs.General(extension, "nos_jin_yangzhi", "jin", 3, false)
--nos_jin_yangzhi:setImage("jin_yangzhi")

nosjinwanyiCard = sgs.CreateSkillCard {
	name = "nosjinwanyi",
	will_throw = false,
	handling_method = sgs.Card_MethodUse,
	filter = function(self, targets, to_select, player)
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		local card = player:getTag("nosjinwanyi"):toCard()
		if not card then return false end
		card:addSubcard(self)
		card:setSkillName("nosjinwanyi")
		return card:targetFilter(qtargets, to_select, player) and not player:isProhibited(to_select, card, qtargets)
	end,
	feasible = function(self, targets, player)
		local card = player:getTag("nosjinwanyi"):toCard()
		if not card then return false end
		card:addSubcard(self)
		card:setSkillName("nosjinwanyi")
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		if card:canRecast() and #targets == 0 then
			return false
		end
		return card:targetsFeasible(qtargets, player)
	end,
	on_validate = function(self, cardUse)
		local source = cardUse.from
		local room = source:getRoom()
		local user_string = self:getUserString()
		local use_card = sgs.Sanguosha:cloneCard(user_string, sgs.Card_SuitToBeDecided, -1)
		if not use_card then return nil end
		use_card:setSkillName("nosjinwanyi")
		use_card:deleteLater()
		use_card:addSubcard(self)
		room:addPlayerMark(source, "nosjinwanyi_juguan_remove_" .. user_string .. "-Clear")
		return use_card
	end
}

nosjinwanyi = sgs.CreateOneCardViewAsSkill {
	name = "nosjinwanyi",
	juguan_type = "zhujinqiyuan,chuqibuyi,drowning,dongzhuxianji",
	view_filter = function(self, to_select)
		if to_select:isEquipped() then return false end
		local EngineCard = sgs.Sanguosha:getEngineCard(to_select:getEffectiveId())
		if EngineCard:property("YingBianEffects"):toString() == "" then return false end
		local c = sgs.Self:getTag("nosjinwanyi"):toCard()
		if not c or not c:isAvailable(sgs.Self) then return false end
		c:addSubcard(to_select)
		c:setSkillName("nosjinwanyi")
		return c:isAvailable(sgs.Self) and not sgs.Self:isLocked(c, true)
	end,
	view_as = function(self, card)
		local _card = sgs.Self:getTag("nosjinwanyi"):toCard()
		if _card and _card:isAvailable(sgs.Self) then
			local c = nosjinwanyiCard:clone()
			c:setUserString(_card:objectName())
			c:addSubcard(card)
			return c
		end
		return nil
	end
}

nos_jin_yangzhi:addSkill(nosjinwanyi)
nos_jin_yangzhi:addSkill("jinmaihuo")

--杨艳
nos_jin_yangyan = sgs.General(extension, "nos_jin_yangyan", "jin", 3, false)
--nos_jin_yangyan:setImage("jin_yangyan")

nosjinxuanbei = sgs.CreateTriggerSkill {
	name = "nosjinxuanbei",
	events = { sgs.GameStart, sgs.CardFinished },
	on_trigger = function(self, event, player, data, room)
		if event == sgs.GameStart then
			local ids = sgs.IntList()
			for _, id in sgs.qlist(room:getDrawPile()) do
				if sgs.Sanguosha:getEngineCard(id):property("YingBianEffects"):toString() == "" then continue end
				ids:append(id)
			end
			if ids:isEmpty() then return false end
			room:sendCompulsoryTriggerLog(player, self)
			local slash = sgs.Sanguosha:cloneCard("slash")
			slash:deleteLater()
			for i = 1, 2 do
				if ids:isEmpty() then break end
				local id = ids:at(math.random(0, ids:length() - 1))
				ids:removeOne(id)
				slash:addSubcard(id)
			end
			if slash:subcardsLength() == 0 then return false end
			room:obtainCard(player, slash)
		else
			if not room:hasCurrent() or player:getMark("nosjinxuanbei_Used-Clear") > 0 then return false end
			local use = data:toCardUse()
			if use.card:isVirtualCard() or use.card:getSkillName() ~= "" then return false end
			if sgs.Sanguosha:getEngineCard(use.card:getEffectiveId()):property("YingBianEffects"):toString() == "" then return false end
			if not room:CardInPlace(use.card, sgs.Player_DiscardPile) then return false end
			local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(),
				"@nosjinxuanbei-invoke:" .. use.card:objectName(), true, true)
			if not target then return false end
			player:peiyin(self)
			player:addMark("nosjinxuanbei_Used-Clear")
			room:giveCard(player, target, use.card, self:objectName(), true)
		end
		return false
	end
}

nos_jin_yangyan:addSkill(nosjinxuanbei)
nos_jin_yangyan:addSkill("jinxianwan")

--左棻
jin_zuofen = sgs.General(extension, "jin_zuofen", "jin", 3, false)

jinzhaosongCard = sgs.CreateSkillCard {
	name = "jinzhaosong",
	filter = function(self, targets, to_select, player)
		return #targets < 2 and to_select:hasFlag("jinzhaosong_can_choose")
	end,
	about_to_use = function(self, room, use)
		for _, p in sgs.qlist(use.to) do
			room:setPlayerFlag(p, "jinzhaosong_add")
		end
	end
}

jinzhaosongVS = sgs.CreateZeroCardViewAsSkill {
	name = "jinzhaosong",
	response_pattern = "@@jinzhaosong",
	view_as = function()
		return jinzhaosongCard:clone()
	end,
}

jinzhaosong = sgs.CreateTriggerSkill {
	name = "jinzhaosong",
	events = { sgs.EventPhaseEnd, sgs.Dying, sgs.EventPhaseStart, sgs.CardUsed, sgs.CardFinished, sgs.DamageDone },
	view_as_skill = jinzhaosongVS,
	can_trigger = function(self, player)
		return player and player:isAlive()
	end,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseEnd then
			if player:getPhase() ~= sgs.Player_Draw then return false end
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if player:getMark("&jzslei") > 0 or player:getMark("&jzsfu") > 0 or player:getMark("&jzssong") > 0 then return false end
				if player:isKongcheng() or player:isDead() then return false end
				if p:isDead() or not p:hasSkill(self) then continue end
				if not p:askForSkillInvoke(self, player) then continue end
				p:peiyin(self)

				local card = room:askForExchange(player, self:objectName(), 1, 1, false,
					"@jinzhaosong-give:" .. p:objectName())
				local _card = sgs.Sanguosha:getCard(card:getSubcards():first())
				local mark
				if _card:isKindOf("TrickCard") then
					mark = "&jzslei"
				elseif _card:isKindOf("EquipCard") then
					mark = "&jzsfu"
				elseif _card:isKindOf("BasicCard") then
					mark = "&jzssong"
				end

				room:giveCard(player, p, card, self:objectName(), true)

				if not mark or player:isDead() then continue end
				player:gainMark(mark)
			end
		elseif event == sgs.Dying then
			local dying = data:toDying()
			if dying.who:objectName() ~= player:objectName() or player:getMark("&jzslei") <= 0 then return false end
			if not player:askForSkillInvoke("jinzhaosong_lei", sgs.QVariant("recover")) then return false end
			player:peiyin(self)
			player:loseAllMarks("&jzslei")
			local recover = math.min(1 - player:getHp(), player:getMaxHp() - player:getHp())
			room:recover(player, sgs.RecoverStruct(player))
			player:drawCards(1, self:objectName())
			room:loseMaxHp(player, 1, "jinzhaosong")
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_Play or player:getMark("&jzsfu") <= 0 then return false end
			local targets = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if player:canDiscard(p, "hej") then
					targets:append(p)
				end
			end
			if targets:isEmpty() then return false end
			local t = room:askForPlayerChosen(player, targets, self:objectName(), "@jinzhaosong-discard", true)
			if not t then return false end
			player:peiyin(self)
			room:doAnimate(1, player:objectName(), t:objectName())
			player:loseAllMarks("&jzsfu")
			local id = room:askForCardChosen(player, t, "hej", self:objectName(), false, sgs.Card_MethodDiscard)
			room:throwCard(id, t, player)
			if player:isAlive() and t:isAlive() then
				local new_data = sgs.QVariant()
				new_data:setValue(t)
				player:setTag("JinZhaosongDrawer", new_data)
				local invoke = player:askForSkillInvoke("jinzhaosong_fu", sgs.QVariant("draw"))
				player:removeTag("JinZhaosongDrawer")
				if invoke then
					t:drawCards(1, self:objectName())
				end
			end
		elseif event == sgs.CardUsed then
			if player:getMark("&jzssong") <= 0 then return false end
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash") or use.to:length() ~= 1 then return false end

			local can_invoke = false
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if use.to:contains(p) or not player:canSlash(p, use.card) then continue end
				room:setPlayerFlag(p, "jinzhaosong_can_choose")
				can_invoke = true
			end

			if not can_invoke then
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					room:setPlayerFlag(p, "-jinzhaosong_can_choose")
				end
				return false
			end

			local invoke = room:askForUseCard(player, "@@jinzhaosong", "@jinzhaosong", -1, sgs.Card_MethodNone)

			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				room:setPlayerFlag(p, "-jinzhaosong_can_choose")
			end

			if not invoke then return false end

			local targets = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:hasFlag("jinzhaosong_add") then
					room:setPlayerFlag(p, "-jinzhaosong_add")
					targets:append(p)
					use.to:append(p)
				end
			end
			if targets:isEmpty() then return false end

			player:peiyin(self)
			room:setCardFlag(use.card, "jinzhaosong_song")
			local new_data = sgs.QVariant()
			new_data:setValue(player)
			room:setTag("JinZhaosongUser_" .. use.card:toString(), new_data)

			player:loseAllMarks("&jzssong")
			room:sortByActionOrder(targets)
			room:sortByActionOrder(use.to)
			for _, p in sgs.qlist(targets) do
				room:doAnimate(1, player:objectName(), p:objectName())
			end
			local log = sgs.LogMessage()
			log.type = "#QiaoshuiAdd"
			log.from = player
			log.to = targets
			log.card_str = use.card:toString()
			log.arg = self:objectName()
			room:sendLog(log)
			data:setValue(use)
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash") or not use.card:hasFlag("jinzhaosong_song") then return false end
			local num = room:getTag("JinZhaosong_" .. use.card:toString()):toInt()
			room:removeTag("JinZhaosong_" .. use.card:toString())
			local from = room:getTag("JinZhaosongUser_" .. use.card:toString()):toPlayer()
			room:removeTag("JinZhaosongUser_" .. use.card:toString())
			if num >= 2 or not from or from:isDead() then return false end
			room:loseHp(from)
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if not p:hasSkill(self) then continue end
				room:loseHp(sgs.HpLostStruct(from, 1, "jinzhaosong", p))
			end
		elseif event == sgs.DamageDone then
			local damage = data:toDamage()
			if not damage.card or not damage.card:isKindOf("Slash") or not damage.card:hasFlag("jinzhaosong_song") then return false end
			local num = room:getTag("JinZhaosong_" .. damage.card:toString()):toInt()
			num = num + damage.damage
			room:setTag("JinZhaosong_" .. damage.card:toString(), sgs.QVariant(num))
		end
		return false
	end
}

jinlisi = sgs.CreateTriggerSkill {
	name = "jinlisi",
	events = sgs.CardsMoveOneTime,
	on_trigger = function(self, event, player, data, room)
		local move = data:toMoveOneTime()
		if not move.from_places:contains(sgs.Player_PlaceTable) or move.to_place ~= sgs.Player_DiscardPile then return false end
		if not move.from or move.from:objectName() ~= player:objectName() then return false end
		if player:getPhase() ~= sgs.Player_NotActive then return false end
		if move.reason.m_reason == sgs.CardMoveReason_S_REASON_USE or move.reason.m_reason == sgs.CardMoveReason_S_REASON_LETUSE then
			local card = move.reason.m_extraData:toCard()
			if not card or not room:CardInPlace(card, sgs.Player_DiscardPile) then return false end
			local targets, hand = sgs.SPlayerList(), player:getHandcardNum()
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:getHandcardNum() <= hand then
					targets:append(p)
				end
			end
			if targets:isEmpty() then return false end
			local ids = sgs.IntList()
			if card:isVirtualCard() then
				ids = card:getSubcards()
			else
				ids:append(card:getEffectiveId())
			end
			if ids:isEmpty() then return false end
			room:fillAG(ids, player)
			local t = room:askForPlayerChosen(player, targets, self:objectName(), "@jinlisi-give", true, true)
			room:clearAG(player)
			if not t then return false end
			player:peiyin(self)
			room:giveCard(player, t, card, "jinlisi", true)
		end
		return false
	end
}

jin_zuofen:addSkill(jinzhaosong)
jin_zuofen:addSkill(jinlisi)

--神郭嘉
shenguojia = sgs.General(extension, "shenguojia", "god", 3)

huishiCard = sgs.CreateSkillCard {
	name = "huishi",
	target_fixed = true,
	on_use = function(self, room, source)
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:deleteLater()

		while (source:isAlive() and source:getMaxHp() < 10) do
			local all, suits = { "spade", "heart", "club", "diamond" }, {} --不考虑无花色了
			for _, suit in ipairs(all) do
				if source:getMark("huishi_judge_" .. suit .. "-PlayClear") > 0 then continue end
				table.insert(suits, suit)
			end
			if #suits == 0 then suits = { "xxx" } end

			local judge = sgs.JudgeStruct()
			judge.who = source
			judge.reason = self:objectName()
			judge.pattern = ".|" .. table.concat(suits, ",")
			judge.good = true
			room:judge(judge)

			local suit_str = judge.pattern
			source:addMark("huishi_judge_" .. suit_str .. "-PlayClear")

			local id = judge.card:getEffectiveId()
			if room:getCardPlace(id) == sgs.Player_DiscardPile and not slash:getSubcards():contains(id) then
				slash:addSubcard(id)
			end

			if judge:isGood() and source:getMaxHp() < 10 and source:isAlive() then
				if not source:askForSkillInvoke("huishi") then break end
				room:gainMaxHp(source, 1, self:objectName())
			else
				break
			end
		end

		if source:isAlive() and slash:subcardsLength() > 0 then
			room:fillAG(slash:getSubcards(), source)
			local to = room:askForPlayerChosen(source, room:getAlivePlayers(), self:objectName(), "@huishi-give", true,
				false)
			room:clearAG(source)
			if not to then return end
			room:doAnimate(1, source:objectName(), to:objectName())
			room:giveCard(source, to, slash, self:objectName(), true)
			if to:isAlive() and source:isAlive() then
				local hand = to:getHandcardNum()
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if p:getHandcardNum() > hand then return end
				end
				room:loseMaxHp(source, 1, self:objectName())
			end
		end
	end
}

huishiVS = sgs.CreateZeroCardViewAsSkill {
	name = "huishi",
	view_as = function()
		return huishiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMaxHp() < 10 and not player:hasUsed("#huishi")
	end
}

huishi = sgs.CreateTriggerSkill {
	name = "huishi",
	events = sgs.FinishJudge,
	view_as_skill = huishiVS,
	can_trigger = function(self, player)
		return player
	end,
	on_trigger = function(self, event, player, data, room)
		local judge = data:toJudge()
		if judge.reason ~= "huishi" then return false end
		judge.pattern = judge.card:getSuitString()
	end
}

godtianyi = sgs.CreatePhaseChangeSkill {
	name = "godtianyi",
	frequency = sgs.Skill_Wake,
	waked_skills = "zuoxing",
	can_wake = function(self, event, player, data, room)
		if player:getPhase() ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:getMark("godtianyi_record") <= 0 then return false end
		end
		return true
	end,
	on_phasechange = function(self, player, room)
		room:sendCompulsoryTriggerLog(player, self)
		room:doSuperLightbox("shenguojia", "godtianyi")
		room:setPlayerMark(player, "godtianyi", 1)
		if room:changeMaxHpForAwakenSkill(player, 2, self:objectName()) then
			room:recover(player, sgs.RecoverStruct(player))
			if player:isDead() then return false end
			local t = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), "@godtianyi-invoke")
			if not t then return false end
			room:doAnimate(1, player:objectName(), t:objectName())
			room:acquireSkill(t, "zuoxing")
		end
		return false
	end
}

godtianyiRecord = sgs.CreateTriggerSkill {
	name = "#godtianyiRecord",
	--frequency = sgs.Skill_Wake,
	events = sgs.DamageDone,
	global = true,
	on_trigger = function(self, event, player, data, room)
		player:addMark("godtianyi_record")
		return false
	end
}

huishiiCard = sgs.CreateSkillCard {
	name = "huishii",
	filter = function(self, targets, to_select)
		return #targets == 0
	end,
	on_effect = function(self, effect)
		local source, target = effect.from, effect.to
		local room = source:getRoom()

		room:doSuperLightbox("shenguojia", "huishii")
		room:removePlayerMark(source, "@huishiiMark")

		local skills = {}
		for _, sk in sgs.qlist(target:getVisibleSkillList()) do
			if sk:getFrequency(target) ~= sgs.Skill_Wake or target:getMark(sk:objectName()) > 0 then continue end
			table.insert(skills, sk:objectName())
		end
		if #skills > 0 and source:getMaxHp() >= room:alivePlayerCount() then
			local data = sgs.QVariant()
			data:setValue(target)
			local skill = room:askForChoice(source, self:objectName(), table.concat(skills, "+"), data)
			target:setCanWake("huishii", skill)
		else
			target:drawCards(4, "huishii")
		end

		if source:isDead() then return end
		room:loseMaxHp(source, 2, self:objectName())
	end
}

huishiiVS = sgs.CreateZeroCardViewAsSkill {
	name = "huishii",
	view_as = function()
		return huishiiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@huishiiMark") > 0
	end
}

huishii = sgs.CreateGameStartSkill {
	name = "huishii",
	frequency = sgs.Skill_Limited,
	view_as_skill = huishiiVS,
	limit_mark = "@huishiiMark",
	on_gamestart = function(self, player)
		return false
	end
}

local function isSpecialOne(player, name)
	local g_name = sgs.Sanguosha:translate(player:getGeneralName())
	if string.find(g_name, name) then return true end
	if player:getGeneral2() then
		g_name = sgs.Sanguosha:translate(player:getGeneral2Name())
		if string.find(g_name, name) then return true end
	end
	return false
end

zuoxingCard = sgs.CreateSkillCard {
	name = "zuoxing",
	target_fixed = false,
	filter = function(self, targets, to_select, player)
		local card = player:getTag("zuoxing"):toCard()
		if not card then return false end

		local new_targets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			new_targets:append(p)
		end

		local _card = sgs.Sanguosha:cloneCard(card:objectName())
		_card:setCanRecast(false)
		_card:setSkillName("zuoxing")
		_card:deleteLater()

		if _card and _card:targetFixed() then --因源码bug，不得已而为之
			return #targets == 0 and to_select:objectName() == player:objectName() and
			not player:isProhibited(to_select, _card, new_targets)
		end
		return _card and _card:targetFilter(new_targets, to_select, player) and
		not player:isProhibited(to_select, _card, new_targets)
	end,
	feasible = function(self, targets, player)
		local card = player:getTag("zuoxing"):toCard()
		if not card then return false end

		local new_targets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			new_targets:append(p)
		end

		local _card = sgs.Sanguosha:cloneCard(card:objectName())
		_card:setCanRecast(false)
		_card:setSkillName("zuoxing")
		_card:deleteLater()
		return _card and _card:targetsFeasible(new_targets, player)
	end,
	on_validate = function(self, card_use)
		local user_string = self:getUserString()
		local use_card = sgs.Sanguosha:cloneCard(user_string)
		if not use_card then return nil end
		use_card:setSkillName("zuoxing")
		use_card:deleteLater()
		return use_card
	end
}

zuoxingVS = sgs.CreateZeroCardViewAsSkill {
	name = "zuoxing",
	view_as = function()
		local _card = sgs.Self:getTag("zuoxing"):toCard()
		if _card and _card:isAvailable(sgs.Self) then
			local c = zuoxingCard:clone()
			c:setUserString(_card:objectName())
			return c
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return player:getMark("zuoxing-Clear") > 0 and not player:hasUsed("#zuoxing")
	end
}

zuoxing = sgs.CreatePhaseChangeSkill {
	name = "zuoxing",
	guhuo_type = "r",
	view_as_skill = zuoxingVS,
	on_phasechange = function(self, player, room)
		if player:getPhase() ~= sgs.Player_Start then return false end
		local shenguojias = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:getMaxHp() > 1 and isSpecialOne(p, "神郭嘉") then
				shenguojias:append(p)
			end
		end
		local shenguojia = room:askForPlayerChosen(player, shenguojias, "zuoxing", "@zuoxing-invoke", true, true)
		if not shenguojia then return false end
		shenguojia:peiyin(self)
		room:loseMaxHp(shenguojia, 1, self:objectName())
		room:setPlayerMark(player, "zuoxing-Clear", 1)
		return false
	end
}

shenguojia:addSkill(huishi)
shenguojia:addSkill(godtianyi)
shenguojia:addSkill(godtianyiRecord)
shenguojia:addSkill(huishii)
extension:insertRelatedSkills("godtianyi", "#godtianyiRecord")

--神太史慈
shentaishici = sgs.General(extension, "shentaishici", "god", 4)

dulie = sgs.CreateTriggerSkill {
	name = "dulie",
	events = { sgs.GameStart, sgs.TargetConfirming },
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.GameStart then
			room:sendCompulsoryTriggerLog(player, self)
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:isDead() then continue end
				p:gainMark("&stscdlwei")
			end
		else
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash") or not use.to:contains(player) then return false end
			if not use.from or use.from:isDead() or use.from:getMark("&stscdlwei") > 0 then return false end
			room:sendCompulsoryTriggerLog(player, self)

			local judge = sgs.JudgeStruct()
			judge.who = player
			judge.good = true
			judge.pattern = ".|heart"
			judge.reason = self:objectName()
			room:judge(judge)

			if not judge:isGood() then return false end

			local nullified_list = use.nullified_list
			table.insert(nullified_list, player:objectName())
			use.nullified_list = nullified_list
			data:setValue(use)
		end
		return false
	end
}

dulieTMD = sgs.CreateTargetModSkill {
	name = "#dulie-tmd",
	pattern = "Slash",
	distance_limit_func = function(self, from, card, to)
		if from:hasSkill("dulie") and to and to:getMark("&stscdlwei") <= 0 then
			return 1000
		else
			return 0
		end
	end
}

powei = sgs.CreateTriggerSkill {
	name = "powei",
	events = { sgs.DamageCaused, sgs.CardFinished, sgs.Dying },
	shiming_skill = true,
	waked_skills = "shenzhuo",
	frequency = sgs.Skill_NotCompulsory,
	on_trigger = function(self, event, player, data, room)
		if player:getMark("powei") > 0 then return false end

		if event == sgs.DamageCaused then
			local damage = data:toDamage()
			if not damage.card or not damage.card:isKindOf("Slash") or not damage.by_user or damage.to:isDead() or damage.to:getMark("&stscdlwei") <= 0 then return false end
			room:sendCompulsoryTriggerLog(player, self, 1)
			damage.to:loseMark("&stscdlwei")
			return true
		elseif event == sgs.CardFinished then
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if p:getMark("&stscdlwei") > 0 then return false end
			end
			room:sendShimingLog(player, self)
			room:acquireSkill(player, "shenzhuo")
		else
			local who = room:getCurrentDyingPlayer()
			if not who or who:objectName() ~= player:objectName() then return false end
			room:sendShimingLog(player, self, false)
			local recover = math.min(1 - player:getHp(), player:getMaxHp() - player:getHp())
			room:recover(player, sgs.RecoverStruct(player, nil, recover))
			if player:isAlive() then
				player:throwAllEquips()
			end
		end
		return false
	end
}

dangmoCard = sgs.CreateSkillCard {
	name = "dangmo",
	mute = true,
	filter = function(self, targets, to_select, player)
		return #targets < player:getHp() - 1 and to_select:hasFlag("dangmo")
	end,
	about_to_use = function(self, room, use)
		for _, p in sgs.qlist(use.to) do
			room:setPlayerFlag(p, "dangmo_slash")
		end
	end
}

dangmoVS = sgs.CreateZeroCardViewAsSkill {
	name = "dangmo",
	response_pattern = "@@dangmo",
	view_as = function()
		return dangmoCard:clone()
	end
}

dangmo = sgs.CreateTriggerSkill {
	name = "dangmo",
	events = sgs.PreCardUsed,
	view_as_skill = dangmoVS,
	on_trigger = function(self, event, player, data, room)
		local use = data:toCardUse()
		if not use.card:isKindOf("Slash") or not use.card:hasFlag("dangmo_first_slash") then return false end
		room:setCardFlag(use.card, "-dangmo_first_slash")
		local extra = player:getHp() - 1
		if extra <= 0 then return false end

		local extra_targets = room:getCardTargets(player, use.card, use.to)
		if extra_targets:isEmpty() then return false end

		for _, p in sgs.qlist(extra_targets) do
			room:setPlayerFlag(p, "dangmo")
		end

		room:askForUseCard(player, "@@dangmo", "@dangmo:" .. use.card:objectName() .. "::" .. extra, -1,
			sgs.Card_MethodNone)

		local adds = sgs.SPlayerList()
		for _, p in sgs.qlist(extra_targets) do
			room:setPlayerFlag(p, "-dangmo")
			if p:hasFlag("dangmo_slash") then
				room:setPlayerFlag(p, "-dangmo_slash")
				use.to:append(p)
				adds:append(p)
			end
		end

		if adds:isEmpty() then return false end
		room:sortByActionOrder(adds)

		room:sortByActionOrder(use.to)
		data:setValue(use)

		local log = sgs.LogMessage()
		log.type = "#QiaoshuiAdd"
		log.from = player
		log.to = adds
		log.card_str = use.card:toString()
		log.arg = "dangmo"
		room:sendLog(log)
		for _, p in sgs.qlist(adds) do
			room:doAnimate(1, player:objectName(), p:objectName())
		end
		room:notifySkillInvoked(player, self:objectName())
		player:peiyin(self)
		return false
	end
}

dangmoSlash = sgs.CreateTriggerSkill {
	name = "#dangmo-slash",
	events = sgs.PreCardUsed,
	priority = 5,
	on_trigger = function(self, event, player, data, room)
		if player:getPhase() ~= sgs.Player_Play then return false end
		local use = data:toCardUse()
		if not use.card:isKindOf("Slash") or player:getMark("dangmo-PlayClear") > 0 then return false end
		room:addPlayerMark(player, "dangmo-PlayClear")
		room:setCardFlag(use.card, "dangmo_first_slash")
		return false
	end
}

shenzhuo = sgs.CreateTriggerSkill {
	name = "shenzhuo",
	events = sgs.CardFinished,
	on_trigger = function(self, event, player, data, room)
		local use = data:toCardUse()
		if not use.card:isKindOf("Slash") or use.card:isVirtualCard() then return false end
		room:sendCompulsoryTriggerLog(player, self)
		player:drawCards(1, "shenzhuo")
		return false
	end
}

shenzhuoSlash = sgs.CreateTargetModSkill {
	name = "#shenzhuo-slash",
	pattern = "Slash",
	residue_func = function(self, player)
		if player:hasSkill("shenzhuo") then
			return 1000
		else
			return 0
		end
	end
}

shentaishici:addSkill(dulie)
shentaishici:addSkill(dulieTMD)
shentaishici:addSkill(powei)
shentaishici:addSkill(dangmo)
shentaishici:addSkill(dangmoSlash)
extension:insertRelatedSkills("dulie", "#dulie-tmd")
extension:insertRelatedSkills("dangmo", "#dangmo-slash")
extension:insertRelatedSkills("shenzhuo", "#shenzhuo-slash")

--神孙策
shensunce = sgs.General(extension, "shensunce", "god", 6)
shensunce:setStartHp(1)

yingbaCard = sgs.CreateSkillCard {
	name = "yingba",
	filter = function(self, targets, to_select, player)
		return #targets == 0 and player:objectName() ~= to_select:objectName() and to_select:getMaxHp() > 1
	end,
	on_effect = function(self, effect)
		local from, to = effect.from, effect.to
		--if to:getMaxHp() <= 1 or from:objectName() == to:objectName() then return end
		local room = from:getRoom()
		room:loseMaxHp(to, 1, self:objectName())
		if to:isAlive() then
			to:gainMark("&sscybpingding")
		end
		room:loseMaxHp(from, 1, self:objectName())
	end
}

yingba = sgs.CreateZeroCardViewAsSkill {
	name = "yingba",
	view_as = function(self, card)
		return yingbaCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#yingba")
	end
}

yingbaTMD = sgs.CreateTargetModSkill {
	name = "#yingba-tmd",
	pattern = "^SkillCard",
	distance_limit_func = function(self, from, card, to)
		if from:hasSkill("yingba") and to and to:getMark("&sscybpingding") > 0 then
			return 1000
		else
			return 0
		end
	end
}

fuhaisc = sgs.CreateTriggerSkill {
	name = "fuhaisc",
	events = { sgs.CardUsed, sgs.TargetSpecifying, sgs.CardsMoveOneTime, sgs.Death, sgs.CardResponded },
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:isKindOf("SkillCard") then return false end
			local sp, no_respond_list = sgs.SPlayerList(), use.no_respond_list
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("&sscybpingding") > 0 then
					table.insert(no_respond_list, p:objectName())
					sp:append(p)
				end
			end
			if sp:isEmpty() then return false end
			use.no_respond_list = no_respond_list
			data:setValue(use)
			local log = sgs.LogMessage()
			log.type = "#FuqiNoResponse"
			log.from = player
			log.to = sp
			log.arg = self:objectName()
			log.card_str = use.card:toString()
			room:sendLog(log)
			room:notifySkillInvoked(player, self:objectName())
			player:peiyin(self)
		elseif event == sgs.CardResponded then
			local res = data:toCardResponse()
			if res.m_card:isKindOf("SkillCard") or not res.m_isUse then return false end
			local sp = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("&sscybpingding") > 0 then
					sp:append(p)
				end
			end
			if sp:isEmpty() then return false end
			local log = sgs.LogMessage()
			log.type = "#FuqiNoResponse"
			log.from = player
			log.to = sp
			log.arg = self:objectName()
			log.card_str = res.m_card:toString()
			room:sendLog(log)
			room:notifySkillInvoked(player, self:objectName())
			player:peiyin(self)
		elseif event == sgs.TargetSpecifying then
			if not room:hasCurrent() or player:getMark("fuhaisc_draw-Clear") > 1 then return false end
			local use = data:toCardUse()
			if use.card:isKindOf("SkillCard") then return false end
			local invoke = false
			for _, p in sgs.qlist(use.to) do
				if p:getMark("&sscybpingding") > 0 then
					invoke = true
					break
				end
			end
			if not invoke then return false end
			room:sendCompulsoryTriggerLog(player, self)
			player:drawCards(1, self:objectName())
		elseif event == sgs.CardsMoveOneTime then --这个时机应该单独写成一个触发技，要有单独的can_trigger，以免被无效，我就偷懒了
			local move = data:toMoveOneTime()
			if move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceHand and move.reason.m_skillName == self:objectName() then
				player:addMark("fuhaisc_draw-Clear", move.card_ids:length())
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if not death.who or death.who:objectName() == player:objectName() then return false end
			local mark = death.who:getMark("&sscybpingding")
			if mark <= 0 then return false end
			room:sendCompulsoryTriggerLog(player, self)
			room:gainMaxHp(player, mark, self:objectName())
			player:drawCards(mark, self:objectName())
		end
		return false
	end
}

pinghe = sgs.CreateMaxCardsSkill {
	name = "pinghe",
	fixed_func = function(self, target)
		if target:hasSkill(self:objectName()) then
			return target:getLostHp()
		else
			return -1
		end
	end
}

pinghedamage = sgs.CreateTriggerSkill {
	name = "#pinghe",
	events = sgs.DamageInflicted,
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data, room)
		if not player:hasSkill("pinghe") then return false end
		local damage = data:toDamage()
		if not damage.from or damage.from:objectName() == player:objectName() then return false end
		if player:isKongcheng() or player:getMaxHp() < 2 then return false end
		room:sendCompulsoryTriggerLog(player, "pinghe", true, true)
		room:loseMaxHp(player, 1, "pinghe")
		if player:isAlive() and not player:isKongcheng() then
			local hands = player:handCards()
			if not room:askForYiji(player, hands, "pinghe", false, false, false, 1) then
				local id = player:getRandomHandCardId()
				local tos = room:getOtherPlayers(player)
				local to = tos:at(math.random(0, tos:length() - 1))
				room:giveCard(player, to, sgs.Sanguosha:getCard(id), self:objectName())
			end
			if player:isAlive() and player:hasSkill("yingba", true) and damage.from and damage.from:isAlive() then
				damage.from:gainMark("&sscybpingding")
			end
		end
		return true
	end
}

shensunce:addSkill(yingba)
shensunce:addSkill(yingbaTMD)
shensunce:addSkill(fuhaisc)
shensunce:addSkill(pinghe)
shensunce:addSkill(pinghedamage)
extension:insertRelatedSkills("yingba", "#yingba-tmd")
extension:insertRelatedSkills("pinghe", "#pinghe")

--神荀彧
shenxunyu = sgs.General(extension, "shenxunyu", "god", 3)

tianzuo = sgs.CreateTriggerSkill {
	name = "tianzuo",
	events = { sgs.GameStart, sgs.CardEffected },
	frequency = sgs.Skill_Compulsory,
	waked_skills = "_qizhengxiangsheng",
	on_trigger = function(self, event, player, data, room)
		if event == sgs.GameStart then
			local cards = sgs.IntList()
			for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
				if sgs.Sanguosha:getEngineCard(id):isKindOf("Qizhengxiangsheng") and room:getCardPlace(id) ~= sgs.Player_DrawPile then
					cards:append(id)
				end
			end
			if not cards:isEmpty() then
				room:sendCompulsoryTriggerLog(player, self)
				room:shuffleIntoDrawPile(player, cards, self:objectName(), true)
			end
		else
			local effect = data:toCardEffect()
			if not effect.card:isKindOf("Qizhengxiangsheng") then return false end
			local log = sgs.LogMessage()
			log.type = "#WuyanGooD"
			log.from = player
			log.to:append(effect.from)
			log.arg = effect.card:objectName()
			log.arg2 = self:objectName()
			room:sendLog(log)
			room:notifySkillInvoked(player, self:objectName())
			player:peiyin(self)
			return true
		end
		return false
	end
}

lingce = sgs.CreateTriggerSkill {
	name = "lingce",
	events = sgs.CardUsed,
	frequency = sgs.Skill_Compulsory,
	waked_skills = "_qizhengxiangsheng",
	can_trigger = function(self, player)
		return player
	end,
	on_trigger = function(self, event, player, data, room)
		local use = data:toCardUse()
		if not use.card:isKindOf("TrickCard") or use.card:isVirtualCard() then return false end
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:isDead() or not p:hasSkill(self) then continue end
			local names = p:property("SkillDescriptionRecord_dinghan"):toString():split("+")
			if use.card:isKindOf("ExNihilo") or use.card:isKindOf("Dismantlement") or use.card:isKindOf("Nullification") or use.card:isKindOf("Qizhengxiangsheng") or
				(p:hasSkill("dinghan", true) and table.contains(names, use.card:objectName())) then
				room:sendCompulsoryTriggerLog(p, self)
				p:drawCards(1, self:objectName())
			end
		end
		return false
	end
}

dinghan = sgs.CreateTriggerSkill {
	name = "dinghan",
	events = { sgs.TargetConfirming, sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data, room)
		if event == sgs.TargetConfirming then
			local use = data:toCardUse()
			if not use.card:isKindOf("TrickCard") then return false end
			local names, name = player:property("SkillDescriptionRecord_dinghan"):toString():split("+"),
				use.card:objectName()
			if table.contains(names, name) then return false end
			table.insert(names, name)
			room:setPlayerProperty(player, "SkillDescriptionRecord_dinghan", sgs.QVariant(table.concat(names, "+")))
			room:changeTranslation(player, "dinghan", 11)

			local log = sgs.LogMessage()
			log.type = "#WuyanGooD"
			log.from = player
			log.to:append(use.from)
			log.arg = name
			log.arg2 = self:objectName()
			room:sendLog(log)
			room:notifySkillInvoked(player, self:objectName())
			player:peiyin(self)

			local nullified_list = use.nullified_list
			table.insert(nullified_list, player:objectName())
			use.nullified_list = nullified_list
			data:setValue(use)
		else
			if player:getPhase() ~= sgs.Player_RoundStart then return false end
			local record, other, all, dinghan, tricks = sgs.IntList(), sgs.IntList(), sgs.IntList(),
				player:property("SkillDescriptionRecord_dinghan"):toString():split("+"), {}
			for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
				local c = sgs.Sanguosha:getEngineCard(id)
				if not c:isKindOf("TrickCard") or table.contains(tricks, c:objectName()) then continue end
				table.insert(tricks, c:objectName())
				--all:append(id)
				if table.contains(dinghan, c:objectName()) then
					record:append(id)
				else
					other:append(id)
				end
			end

			for _, id in sgs.qlist(record) do
				all:append(id)
			end
			for _, id in sgs.qlist(other) do
				all:append(id)
			end

			local choices = {}
			if not other:isEmpty() then
				table.insert(choices, "add")
			end
			if not record:isEmpty() then
				table.insert(choices, "remove")
			end
			if #choices == 0 then return false end
			table.insert(choices, "cancel")

			room:fillAG(all, player, other)
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"), sgs.QVariant(), "",
				"tip")
			room:clearAG(player)

			if choice == "cancel" then return false end

			local log = sgs.LogMessage()
			log.type = "#InvokeSkill"
			log.from = player
			log.arg = self:objectName()
			room:sendLog(log)
			room:notifySkillInvoked(player, self:objectName())
			player:peiyin(self)

			if choice == "remove" then
				room:fillAG(record, player)
				local id = room:askForAG(player, record, false, self:objectName())
				room:clearAG(player)
				local name = sgs.Sanguosha:getEngineCard(id):objectName()
				log.type = "#DingHanRemove"
				log.from = player
				log.arg = self:objectName()
				log.arg2 = name
				room:sendLog(log)
				table.removeOne(dinghan, name)
				room:setPlayerProperty(player, "SkillDescriptionRecord_dinghan", sgs.QVariant(table.concat(dinghan, "+")))
				if #dinghan == 0 then
					room:changeTranslation(player, "dinghan", 1)
				else
					room:changeTranslation(player, "dinghan", 11)
				end
			else
				room:fillAG(other, player)
				local id = room:askForAG(player, other, false, self:objectName())
				room:clearAG(player)
				local name = sgs.Sanguosha:getEngineCard(id):objectName()
				log.type = "#DingHanAdd"
				log.from = player
				log.arg = self:objectName()
				log.arg2 = name
				room:sendLog(log)
				table.insert(dinghan, name)
				room:setPlayerProperty(player, "SkillDescriptionRecord_dinghan", sgs.QVariant(table.concat(dinghan, "+")))
				room:changeTranslation(player, "dinghan", 11)
			end
		end
		return false
	end
}

shenxunyu:addSkill(tianzuo)
shenxunyu:addSkill(lingce)
shenxunyu:addSkill(dinghan)

--新sp贾诩-十周年
tenyear_new_sp_jiaxu = sgs.General(extension, "tenyear_new_sp_jiaxu", "wei", 3)

tenyearjianshuCard = sgs.CreateSkillCard {
	name = "tenyearjianshu",
	will_throw = false,
	on_effect = function(self, effect)
		local from, to = effect.from, effect.to
		local room = from:getRoom()
		room:giveCard(from, to, self, "tenyearjianshu")

		if from:isDead() then return end
		local targets = room:getOtherPlayers(from)
		if targets:contains(to) then
			targets:removeOne(to)
		end
		if targets:isEmpty() then return end

		local other = room:askForPlayerChosen(from, targets, self:objectName(),
			"@tenyearjianshu-pindian:" .. to:objectName())
		room:doAnimate(1, to:objectName(), other:objectName())
		if not to:canPindian(other, false) then return end

		local n = to:pindianInt(other, self:objectName())
		if n < -1 then return end

		local losers, winner = sgs.SPlayerList(), nil
		if n == -1 then
			winner = other
			losers:append(to)
		elseif n == 1 then
			winner = to
			losers:append(other)
		elseif n == 0 then
			losers:append(to)
			losers:append(other)
		end

		if winner then
			local cards = sgs.IntList()
			for _, id in sgs.qlist(winner:handCards()) do
				if winner:canDiscard(winner, id) then
					cards:append(id)
				end
			end
			for _, id in sgs.qlist(winner:getEquipsId()) do
				if winner:canDiscard(winner, id) then
					cards:append(id)
				end
			end
			if not cards:isEmpty() then
				local id = cards:at(math.random(0, cards:length() - 1))
				room:throwCard(id, winner)
			else
				if not winner:isKongcheng() then
					local log = sgs.LogMessage()
					log.type = "#TenyearJianshuShow"
					log.from = winner
					room:sendLog(log)
					room:showAllCards(winner)
				end
			end
		end

		if not losers:isEmpty() then
			room:sortByActionOrder(losers)
			for _, p in sgs.qlist(losers) do
				room:loseHp(sgs.HpLostStruct(p, 1, "tenyearjianshu", from))
			end
		end
	end
}

tenyearjianshuVS = sgs.CreateOneCardViewAsSkill {
	name = "tenyearjianshu",
	filter_pattern = ".|black|.|hand",
	view_as = function(self, card)
		local c = tenyearjianshuCard:clone()
		c:addSubcard(card)
		return c
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#tenyearjianshu")
	end
}

tenyearjianshu = sgs.CreateTriggerSkill {
	name = "tenyearjianshu",
	events = sgs.Death,
	view_as_skill = tenyearjianshuVS,
	can_trigger = function(self, player)
		return player
	end,
	on_trigger = function(self, event, player, data, room)
		local death = data:toDeath()
		if not death.who or not death.hplost then return false end
		if death.hplost.reason ~= self:objectName() or not death.hplost.from then return false end
		room:addPlayerHistory(death.hplost.from, "#tenyearjianshu", 0)
	end
}

tenyearyongdiCard = sgs.CreateSkillCard {
	name = "tenyearyongdi",
	filter = function(self, targets, to_select, player)
		return #targets == 0 and to_select:isMale()
	end,
	on_effect = function(self, effect)
		local from, to = effect.from, effect.to
		local room = from:getRoom()

		room:doSuperLightbox("tenyear_new_sp_jiaxu", "tenyearyongdi")
		room:removePlayerMark(from, "@tenyearyongdiMark")

		local choices = ""
		if to:isLowestHpPlayer() then
			choices = "maxhp"
			if to:isWounded() then
				choices = "recover+maxhp"
			end
		else
			local maxhp, lowest = to:getMaxHp(), true
			for _, p in sgs.qlist(room:getOtherPlayers(to)) do
				if p:getMaxHp() < maxhp then
					lowest = false
					break
				end
			end
			if lowest then
				choices = "maxhp"
				if to:isWounded() then
					choices = "recover+maxhp"
				end
			end
		end

		if choices ~= "" then
			local choice = room:askForChoice(to, self:objectName(), choices)
			if choice == "recover" then
				room:recover(to, sgs.RecoverStruct(from))
			else
				room:gainMaxHp(to, 1, self:objectName())
			end
		end

		if to:isDead() then return end

		local hand = to:getHandcardNum()
		for _, p in sgs.qlist(room:getOtherPlayers(to)) do
			if p:getHandcardNum() < hand then
				return
			end
		end
		to:drawCards(math.min(to:getMaxHp(), 5), self:objectName())
	end
}

tenyearyongdi = sgs.CreateZeroCardViewAsSkill {
	name = "tenyearyongdi",
	frequency = sgs.Skill_Limited,
	limit_mark = "@tenyearyongdiMark",
	view_as = function(self, card)
		return tenyearyongdiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@tenyearyongdiMark") > 0
	end
}

tenyear_new_sp_jiaxu:addSkill("zhenlve")
tenyear_new_sp_jiaxu:addSkill(tenyearjianshu)
tenyear_new_sp_jiaxu:addSkill(tenyearyongdi)


--小珂酱新增部分

--手杀星周不疑

kexingzhoubuyi = sgs.General(extension, "kexingzhoubuyi", "wei", 3)

kehuiyaoCard = sgs.CreateSkillCard {
	name = "kehuiyaoCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:damage(sgs.DamageStruct("kehuiyao", nil, source))
		local other = room:askForPlayerChosen(source, room:getOtherPlayers(source), self:objectName(), "kehuiyao-ask",
			false, false)
		if other then
			local another = room:askForPlayerChosen(source, room:getOtherPlayers(other), self:objectName(),
				"kehuiyaotwo-ask", false, false)
			if another then
				room:doAnimate(1, other:objectName(), another:objectName())
				room:getThread():delay(1000)
				local log = sgs.LogMessage()
				log.type = "$kehuiyaolog"
				log.from = other
				log.to:append(another)
				room:sendLog(log)
				local thedamage = sgs.DamageStruct("kehuiyao", other, another)
				local _data = sgs.QVariant()
				_data:setValue(thedamage)
				room:getThread():trigger(sgs.Damage, room, other, _data)
				room:getThread():trigger(sgs.Damaged, room, another, _data)
			end
		end
	end
}
kehuiyao = sgs.CreateViewAsSkill {
	name = "kehuiyao",
	n = 0,
	view_as = function(self, cards)
		return kehuiyaoCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#kehuiyaoCard")
	end
}
kexingzhoubuyi:addSkill(kehuiyao)


kequesong = sgs.CreateTriggerSkill {
	name = "kequesong",
	frequency = sgs.Skill_Frequent,
	events = { sgs.EventPhaseStart, sgs.Damaged },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Damaged) then
			local damage = data:toDamage()
			if damage.to and damage.to:hasSkill(self:objectName()) then
				room:setPlayerMark(damage.to, "&kequesong-Clear", 1)
			end
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Finish) then
				for _, zby in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					if (zby:getMark("&kequesong-Clear") > 0) then
						local fri = room:askForPlayerChosen(zby, room:getAllPlayers(), self:objectName(), "kequesong-ask",
							true, true)
						if fri then
							room:broadcastSkillInvoke(self:objectName())
							local result = room:askForChoice(fri, self:objectName(), "draw+recover")
							if result == "draw" then
								if (fri:getCards("e"):length() > 2) then
									fri:drawCards(2)
								else
									fri:drawCards(3)
								end
							else
								room:recover(fri, sgs.RecoverStruct())
							end
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
kexingzhoubuyi:addSkill(kequesong)

sgs.LoadTranslationTable {
	["kexingzhoubuyi"] = "星周不疑",
	["&kexingzhoubuyi"] = "星周不疑",
	["#kexingzhoubuyi"] = "稚雀清声",
	["designer:kexingzhoubuyi"] = "官方",
	["cv:kexingzhoubuyi"] = "官方",
	["illustrator:kexingzhoubuyi"] = "官方",

	["kehuiyao"] = "慧夭",
	["kehuiyaoCard"] = "慧夭",
	[":kehuiyao"] = "出牌阶段限一次，你可以受到1点无来源的伤害，然后你令一名其他角色视为对其以外的一名角色造成过1点伤害。",
	["$kehuiyaolog"] = "%from 视为对 %to 造成过1点伤害！",

	["kequesong"] = "雀颂",
	[":kequesong"] = "一名角色的结束阶段，若你于此回合内受到过伤害，你可以令一名角色选择一项：摸三张牌（若其装备区牌数大于2，改为两张），或回复1点体力。",

	["kehuiyao-ask"] = "请选择视为造成伤害的 伤害来源",
	["kehuiyaotwo-ask"] = "请选择视为造成伤害的 受伤的角色",
	["kequesong-ask"] = "请选择发动“雀颂”的角色",

	["kequesong:draw"] = "摸牌",
	["kequesong:recover"] = "回复1点体力",

	["$kehuiyao2"] = "通悟而无笃学之念，则必盈天下之叹也。",
	["$kehuiyao1"] = "幸有仓舒为伴，吾不至居高寡寒。",
	["$kequesong2"] = "挽汉室于危亡，继光武之中兴！",
	["$kequesong1"] = "承白雀之瑞，显周公之德！",
	["~kexingzhoubuyi"] = "慧童亡，天下伤。",

}


keolzhouchu = sgs.General(extension, "keolzhouchu", "jin", 4)

keolshanduan = sgs.CreateTriggerSkill {
	name = "keolshanduan",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.EventPhaseStart, sgs.DrawNCards, sgs.Damaged },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Damaged) then
			local damage = data:toDamage()
			if damage.to and damage.to:hasSkill(self:objectName()) then
				room:addPlayerMark(damage.to, "&keolshanduandamage-SelfClear", 1)
			end
		end
		if (event == sgs.DrawNCards) then
			local count = data:toInt()
			count = math.max((count + player:getMark("shanduanmp-Clear") - 2), 0)
			local log = sgs.LogMessage()
			log.type = "$keolshanduanmplog"
			log.from = player
			log.arg = count
			room:sendLog(log)
			data:setValue(count)
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Draw) then
				local choices = {}
				if (player:getMark("shanduanchooseone-Clear") == 0) then
					table.insert(choices, "shanduanone")
				end
				if (player:getMark("shanduanchoosetwo-Clear") == 0) then
					table.insert(choices, "shanduantwo")
				end
				if (player:getMark("shanduanchoosethree-Clear") == 0) then
					table.insert(choices, "shanduanthree")
				end
				if (player:getMark("shanduanchoosefour-Clear") == 0) then
					table.insert(choices, "shanduanfour")
				end
				room:sendCompulsoryTriggerLog(player, self:objectName())
				--if not player:hasFlag("shanduanyuyin") then
				--	room:setPlayerFlag(player,"shanduanyuyin")
				room:broadcastSkillInvoke(self:objectName())
				--end
				local choice = room:askForChoice(player, "keolshanduanmpjd", table.concat(choices, "+"))
				if (choice == "shanduanone") then
					room:setPlayerMark(player, "shanduanchooseone-Clear", 1)
					room:setPlayerMark(player, "shanduanmp-Clear", 1 + player:getMark("&keolshanduandamage-SelfClear"))
				elseif (choice == "shanduantwo") then
					room:setPlayerMark(player, "shanduanchoosetwo-Clear", 1)
					room:setPlayerMark(player, "shanduanmp-Clear", 2)
				elseif (choice == "shanduanthree") then
					room:setPlayerMark(player, "shanduanchoosethree-Clear", 1)
					room:setPlayerMark(player, "shanduanmp-Clear", 3)
				elseif (choice == "shanduanfour") then
					room:setPlayerMark(player, "shanduanchoosefour-Clear", 1)
					room:setPlayerMark(player, "shanduanmp-Clear", 4)
				end
			end
			if (player:getPhase() == sgs.Player_Play) then
				--先选择攻击范围
				local choices = {}
				if (player:getMark("shanduanchooseone-Clear") == 0) then
					table.insert(choices, "shanduanone")
				end
				if (player:getMark("shanduanchoosetwo-Clear") == 0) then
					table.insert(choices, "shanduantwo")
				end
				if (player:getMark("shanduanchoosethree-Clear") == 0) then
					table.insert(choices, "shanduanthree")
				end
				if (player:getMark("shanduanchoosefour-Clear") == 0) then
					table.insert(choices, "shanduanfour")
				end
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local choice = room:askForChoice(player, "keolshanduancpgjfw", table.concat(choices, "+"))
				if (choice == "shanduanone") then
					room:setPlayerMark(player, "shanduanchooseone-Clear", 1)
					room:setPlayerMark(player, "keolshanduancpgjfw-Clear",
						1 + player:getMark("&keolshanduandamage-SelfClear"))
				elseif (choice == "shanduantwo") then
					room:setPlayerMark(player, "shanduanchoosetwo-Clear", 1)
					room:setPlayerMark(player, "keolshanduancpgjfw-Clear", 2)
				elseif (choice == "shanduanthree") then
					room:setPlayerMark(player, "shanduanchoosethree-Clear", 1)
					room:setPlayerMark(player, "keolshanduancpgjfw-Clear", 3)
				elseif (choice == "shanduanfour") then
					room:setPlayerMark(player, "shanduanchoosefour-Clear", 1)
					room:setPlayerMark(player, "keolshanduancpgjfw-Clear", 4)
				end
				local log = sgs.LogMessage()
				log.type = "$keolshanduancpgjfw"
				log.from = player
				log.arg = player:getMark("keolshanduancpgjfw-Clear")
				room:sendLog(log)
				--再选择杀的次数
				local schoices = {}
				if (player:getMark("shanduanchooseone-Clear") == 0) then
					table.insert(schoices, "shanduanone")
				end
				if (player:getMark("shanduanchoosetwo-Clear") == 0) then
					table.insert(schoices, "shanduantwo")
				end
				if (player:getMark("shanduanchoosethree-Clear") == 0) then
					table.insert(schoices, "shanduanthree")
				end
				if (player:getMark("shanduanchoosefour-Clear") == 0) then
					table.insert(schoices, "shanduanfour")
				end
				room:sendCompulsoryTriggerLog(player, self:objectName())
				local schoice = room:askForChoice(player, "keolshanduancpslash", table.concat(schoices, "+"))
				if (schoice == "shanduanone") then
					room:setPlayerMark(player, "shanduanchooseone-Clear", 1)
					room:setPlayerMark(player, "keolshanduancpslash-Clear",
						1 + player:getMark("&keolshanduandamage-SelfClear"))
				elseif (schoice == "shanduantwo") then
					room:setPlayerMark(player, "shanduanchoosetwo-Clear", 1)
					room:setPlayerMark(player, "keolshanduancpslash-Clear", 2)
				elseif (schoice == "shanduanthree") then
					room:setPlayerMark(player, "shanduanchoosethree-Clear", 1)
					room:setPlayerMark(player, "keolshanduancpslash-Clear", 3)
				elseif (schoice == "shanduanfour") then
					room:setPlayerMark(player, "shanduanchoosefour-Clear", 1)
					room:setPlayerMark(player, "keolshanduancpslash-Clear", 4)
				end
				local num = math.max(player:getMark("keolshanduancpslash-Clear") - 1, 0)
				room:addSlashCishu(player, num, true)
				local log = sgs.LogMessage()
				log.type = "$keolshanduancpslashlog"
				log.from = player
				log.arg = player:getMark("keolshanduancpslash-Clear")
				room:sendLog(log)
			end
			if (player:getPhase() == sgs.Player_Discard) then
				local choices = {}
				if (player:getMark("shanduanchooseone-Clear") == 0) then
					table.insert(choices, "shanduanone")
				end
				if (player:getMark("shanduanchoosetwo-Clear") == 0) then
					table.insert(choices, "shanduantwo")
				end
				if (player:getMark("shanduanchoosethree-Clear") == 0) then
					table.insert(choices, "shanduanthree")
				end
				if (player:getMark("shanduanchoosefour-Clear") == 0) then
					table.insert(choices, "shanduanfour")
				end
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local choice = room:askForChoice(player, "keolshanduanspsx", table.concat(choices, "+"))
				if (choice == "shanduanone") then
					room:setPlayerMark(player, "shanduanchooseone-Clear", 1)
					room:setPlayerMark(player, "shanduanqp-Clear", 1 + player:getMark("&keolshanduandamage-SelfClear"))
				elseif (choice == "shanduantwo") then
					room:setPlayerMark(player, "shanduanchoosetwo-Clear", 1)
					room:setPlayerMark(player, "shanduanqp-Clear", 2)
				elseif (choice == "shanduanthree") then
					room:setPlayerMark(player, "shanduanchoosethree-Clear", 1)
					room:setPlayerMark(player, "shanduanqp-Clear", 3)
				elseif (choice == "shanduanfour") then
					room:setPlayerMark(player, "shanduanchoosefour-Clear", 1)
					room:setPlayerMark(player, "shanduanqp-Clear", 4)
				end
			end
			if (player:getPhase() == sgs.Player_Discard) then
				local num = (player:getMark("shanduanqp-Clear") - player:getHp())
				room:addMaxCards(player, num, true)
				local log = sgs.LogMessage()
				log.type = "$keolshanduanqplog"
				log.from = player
				log.arg = player:getMark("shanduanqp-Clear")
				room:sendLog(log)
			end
		end
	end,
}
keolzhouchu:addSkill(keolshanduan)

keolshanduanex = sgs.CreateAttackRangeSkill {
	name = "keolshanduanex",
	extra_func = function(self, target)
		local n = 0
		if target:hasSkill("keolshanduan") then
			n = n + math.max(target:getMark("keolshanduancpgjfw-Clear") - 1, 0)
		end
		return n
	end
}
if not sgs.Sanguosha:getSkill("keolshanduanex") then skills:append(keolshanduanex) end

keolyilieCard = sgs.CreateSkillCard {
	name = "keolyilieCard",
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select)
		local plist = sgs.PlayerList()
		for i = 1, #targets do plist:append(targets[i]) end
		local rangefix = 0
		if not self:getSubcards():isEmpty() and sgs.Self:getWeapon() and sgs.Self:getWeapon():getId() == self:getSubcards():first() then
			local card = sgs.Self:getWeapon():getRealCard():toWeapon()
			rangefix = rangefix + card:getRange() - sgs.Self:getAttackRange(false)
		end
		if not self:getSubcards():isEmpty() and sgs.Self:getOffensiveHorse() and sgs.Self:getOffensiveHorse():getId() == self:getSubcards():first() then
			rangefix = rangefix + 1
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card, user_str = nil, self:getUserString()
			if user_str ~= "" then
				local us = user_str:split("+")
				card = sgs.Sanguosha:cloneCard(us[1])
			end
			return card and card:targetFilter(plist, to_select, sgs.Self) and
				not sgs.Self:isProhibited(to_select, card, plist)
				and not (card:isKindOf("Slash") and not sgs.Self:canSlash(to_select, true, rangefix))
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return false
		end
		local card = sgs.Self:getTag("keolyilie"):toCard()
		return card and card:targetFilter(plist, to_select, sgs.Self) and
			not sgs.Self:isProhibited(to_select, card, plist)
			and not (card:isKindOf("Slash") and not sgs.Self:canSlash(to_select, true, rangefix))
	end,
	target_fixed = function(self)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card, user_str = nil, self:getUserString()
			if user_str ~= "" then
				local us = user_str:split("+")
				card = sgs.Sanguosha:cloneCard(us[1])
			end
			return card and card:targetFixed()
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return true
		end
		local card = sgs.Self:getTag("keolyilie"):toCard()
		return card and card:targetFixed()
	end,
	feasible = function(self, targets)
		local plist = sgs.PlayerList()
		for i = 1, #targets do plist:append(targets[i]) end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card, user_str = nil, self:getUserString()
			if user_str ~= "" then
				local us = user_str:split("+")
				card = sgs.Sanguosha:cloneCard(us[1])
			end
			return card and card:targetsFeasible(plist, sgs.Self)
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return true
		end
		local card = sgs.Self:getTag("keolyilie"):toCard()
		return card and card:targetsFeasible(plist, sgs.Self)
	end,
	on_validate = function(self, card_use)
		local player = card_use.from
		local room, to_keolyilie = player:getRoom(), self:getUserString()
		if self:getUserString() == "slash" and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local keolyilie_list = {}
			table.insert(keolyilie_list, "slash")
			table.insert(keolyilie_list, "fire_slash")
			table.insert(keolyilie_list, "thunder_slash")
			table.insert(keolyilie_list, "ice_slash")
			to_keolyilie = room:askForChoice(player, "keolyilie_slash", table.concat(keolyilie_list, "+"))
		end
		local card = nil
		if self:subcardsLength() == 1 then card = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(self:getSubcards():first())) end
		local user_str
		if to_keolyilie == "slash" then
			--if card and card:isKindOf("Slash")and not (card:isKindOf("FireSlash") or card:isKindOf("ThunderSlash") or card:isKindOf("IceSlash")) then
			if card and card:objectName() == "slash" then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		else
			user_str = to_keolyilie
		end
		local use_card = sgs.Sanguosha:cloneCard(user_str, card and card:getSuit() or sgs.Card_SuitToBeDecided,
			card and card:getNumber() or -1)
		use_card:setSkillName("keolyilie")
		use_card:addSubcards(self:getSubcards())
		use_card:deleteLater()
		return use_card
	end,
	on_validate_in_response = function(self, user)
		local room, user_str = user:getRoom(), self:getUserString()
		local to_keolyilie
		if user_str == "peach+analeptic" then
			local keolyilie_list = {}
			table.insert(keolyilie_list, "peach")
			table.insert(keolyilie_list, "analeptic")
			to_keolyilie = room:askForChoice(user, "keolyilie_saveself", table.concat(keolyilie_list, "+"))
		elseif user_str == "slash" then
			local keolyilie_list = {}
			table.insert(keolyilie_list, "slash")
			table.insert(keolyilie_list, "fire_slash")
			table.insert(keolyilie_list, "thunder_slash")
			table.insert(keolyilie_list, "ice_slash")
			to_keolyilie = room:askForChoice(user, "keolyilie_slash", table.concat(keolyilie_list, "+"))
		else
			to_keolyilie = user_str
		end
		local card = nil
		if self:subcardsLength() == 1 then card = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(self:getSubcards():first())) end
		local user_str
		if to_keolyilie == "slash" then
			if card and card:objectName() == "slash" then
				--if card and card:isKindOf("Slash") and not (card:isKindOf("FireSlash") or card:isKindOf("ThunderSlash") or card:isKindOf("IceSlash"))then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		else
			user_str = to_keolyilie
		end
		local use_card = sgs.Sanguosha:cloneCard(user_str, card and card:getSuit() or sgs.Card_SuitToBeDecided,
			card and card:getNumber() or -1)
		use_card:setSkillName("keolyilie")
		use_card:addSubcards(self:getSubcards())
		use_card:deleteLater()
		return use_card
	end,
}
keolyilieVS = sgs.CreateViewAsSkill {
	name = "keolyilie",
	n = 2,
	response_or_use = true,
	view_filter = function(self, selected, to_select)
		if #selected == 0 then
			return not to_select:isEquipped()
		elseif #selected == 1 then
			local card = selected[1]
			if to_select:getColor() == card:getColor() then
				return not to_select:isEquipped()
			end
		else
			return false
		end
	end,
	view_as = function(self, cards)
		if #cards ~= 2 then return nil end
		local skillcard = keolyilieCard:clone()
		skillcard:setSkillName(self:objectName())
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE
			or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			skillcard:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
			for _, card in ipairs(cards) do
				skillcard:addSubcard(card)
			end
			return skillcard
		end
		local c = sgs.Self:getTag("keolyilie"):toCard()
		if c then
			skillcard:setUserString(c:objectName())
			for _, card in ipairs(cards) do
				skillcard:addSubcard(card)
			end
			return skillcard
		else
			return nil
		end
	end,
	enabled_at_play = function(self, player)
		local basic = {}
		if (player:getMark("keolyilieslash_lun") == 0) then
			table.insert(basic, "slash")
			table.insert(basic, "fire_slash")
			table.insert(basic, "thunder_slash")
			table.insert(basic, "ice_slash")
		end
		if player:getMark("keolyiliejiu_lun") == 0 then
			table.insert(basic, "analeptic")
		end
		if player:getMark("keolyiliepeach_lun") == 0 then
			table.insert(basic, "peach")
		end
		if #basic > 0 then
			for _, patt in ipairs(basic) do
				local poi = sgs.Sanguosha:cloneCard(patt, sgs.Card_NoSuit, -1)
				if poi and poi:isAvailable(player) and not (patt == "peach" and not player:isWounded()) then
					return true
				end
			end
		end
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		if string.startsWith(pattern, ".") or string.startsWith(pattern, "@") then return false end
		if (pattern == "peach") and ((player:getMark("Global_PreventPeach") > 0) or (player:getMark("keolyiliepeach_lun") > 0)) then return false end
		if (pattern == "jink") and (player:getMark("keolyiliejink_lun") > 0) then return false end
		return pattern ~= "nullification" and pattern ~= "jl_wuxiesy"
	end,
}

keolyilie = sgs.CreateTriggerSkill {
	name = "keolyilie",
	view_as_skill = keolyilieVS,
	events = { sgs.CardUsed },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardUsed) and player:hasSkill(self:objectName()) then
			local use = data:toCardUse()
			if (use.card:getSkillName() == "keolyilie") then
				if use.card:isKindOf("Slash") then room:setPlayerMark(use.from, "keolyilieslash_lun", 1) end
				if use.card:isKindOf("Jink") then room:setPlayerMark(use.from, "keolyiliejink_lun", 1) end
				if use.card:isKindOf("Peach") then room:setPlayerMark(use.from, "keolyiliepeach_lun", 1) end
				if use.card:isKindOf("Analeptic") then room:setPlayerMark(use.from, "keolyiliejiu_lun", 1) end
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end,
}
keolyilie:setGuhuoDialog("l")
keolzhouchu:addSkill(keolyilie)

sgs.LoadTranslationTable {
	["keolzhouchu"] = "OL周处",
	["&keolzhouchu"] = "周处",
	["#keolzhouchu"] = "忠烈果毅",
	["designer:keolzhouchu"] = "官方",
	["cv:keolzhouchu"] = "官方",
	["illustrator:keolzhouchu"] = "官方",

	["keolshanduan"] = "善断",
	["keolshanduandamage"] = "善断伤害",
	[":keolshanduan"] = "锁定技，摸牌/出牌/弃牌阶段开始时，你将本回合的摸牌数/攻击范围和【杀】的次数限制/手牌上限的默认值改为你从1、2、3和4中选择的本回合未以此法选择过的数值；当你于回合外受到伤害后，你令下回合以此法选择“1”后，该数值+1。",
	["$keolshanduanmplog"] = "%from 的摸牌数默认值改为 %arg !",
	["$keolshanduancpslashlog"] = "%from 的【杀】的次数限制默认值改为 %arg !",
	["$keolshanduancpgjfw"] = "%from 的攻击范围默认值改为 %arg !",
	["$keolshanduanqplog"] = "%from 的手牌上限默认值改为 %arg !",

	["keolyilie"] = "义烈",
	[":keolyilie"] = "你可以将两张颜色相同的手牌当本轮未以此法使用过的基本牌使用或打出。",

	["keolshanduanmpjd"] = "摸牌数默认值",
	["keolshanduanmpjd:shanduanone"] = "1",
	["keolshanduanmpjd:shanduantwo"] = "2",
	["keolshanduanmpjd:shanduanthree"] = "3",
	["keolshanduanmpjd:shanduanfour"] = "4",

	["keolshanduancpgjfw"] = "攻击范围默认值",
	["keolshanduancpgjfw:shanduanone"] = "1",
	["keolshanduancpgjfw:shanduantwo"] = "2",
	["keolshanduancpgjfw:shanduanthree"] = "3",
	["keolshanduancpgjfw:shanduanfour"] = "4",

	["keolshanduancpslash"] = "【杀】次数限制默认值",
	["keolshanduancpslash:shanduanone"] = "1",
	["keolshanduancpslash:shanduantwo"] = "2",
	["keolshanduancpslash:shanduanthree"] = "3",
	["keolshanduancpslash:shanduanfour"] = "4",

	["keolshanduanspsx"] = "手牌上限默认值",
	["keolshanduanspsx:shanduanone"] = "1",
	["keolshanduanspsx:shanduantwo"] = "2",
	["keolshanduanspsx:shanduanthree"] = "3",
	["keolshanduanspsx:shanduanfour"] = "4",

	["keolyilie_slash"] = "义烈",
	["keolyilie_saveself"] = "义烈",

	["$keolshanduan1"] = "浪子回头，其期未晚矣。",
	["$keolshanduan2"] = "心既存蛟虎，秉慧剑斩之。",
	["$keolyilie1"] = "从来天下义，只在青山中。",
	["$keolyilie2"] = "沥血染征袍，英名万古存。",
	["~keolzhouchu"] = "死战死谏，死亦可乎！",

}

keolxiahouxuan = sgs.General(extension, "keolxiahouxuan", "wei", 3)

keolhuanfu = sgs.CreateTriggerSkill {
	name = "keolhuanfu",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.TargetSpecified, sgs.TargetConfirmed, sgs.Damage, sgs.CardFinished },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardFinished) then
			local use = data:toCardUse()
			if use.card:hasFlag("huanfucard") then
				--if (room:getTag("keolhuanfudis"):toInt() == room:getTag("keolhuanfuda"):toInt()) then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if (p:getMark("usingkeolhuanfu" .. use.card:toString()) > 0) then
						if (p:getMark("keolhuanfudis" .. use.card:toString()) == p:getMark("keolhuanfuda" .. use.card:toString())) then
							p:drawCards(2 * (p:getMark("keolhuanfudis" .. use.card:toString())))
						end
					end
				end
				for _, pp in sgs.qlist(room:getAllPlayers()) do
					room:setPlayerMark(pp, "usingkeolhuanfu" .. use.card:toString(), 0)
					room:setPlayerMark(pp, "huanfutarget" .. use.card:toString(), 0)
					room:setPlayerMark(pp, "keolhuanfudis" .. use.card:toString(), 0)
					room:setPlayerMark(pp, "keolhuanfuda" .. use.card:toString(), 0)
				end
				--room:removeTag("keolhuanfuda")
				--room:removeTag("keolhuanfudis")
			end
		end
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			if damage.card and damage.card:hasFlag("huanfucard") and (damage.to:getMark("huanfutarget" .. damage.card:toString()) > 0) then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if (p:getMark("usingkeolhuanfu" .. damage.card:toString()) > 0) then
						room:addPlayerMark(p, "keolhuanfuda" .. damage.card:toString(), damage.damage)
					end
				end
				--[[if not room:getTag("keolhuanfuda") then
					damage.from:drawCards(5)
					room:setTag("keolhuanfuda", sgs.QVariant(damage.damage))
				else
					local num = room:getTag("keolhuanfuda"):toInt() + damage.damage
					room:setTag("keolhuanfuda", sgs.QVariant(num))
				end]]
			end
		end
		if (event == sgs.TargetConfirmed) then
			local use = data:toCardUse()
			if use.to:contains(player) and player:hasSkill(self:objectName())
				and use.card:isKindOf("Slash")
				and not player:isNude() then
				local askdis = room:askForDiscard(player, self:objectName(), player:getMaxHp(), 1, true, true,
					"keolhuanfudis")
				if askdis then
					room:broadcastSkillInvoke(self:objectName())
					room:setPlayerMark(player, "usingkeolhuanfu" .. use.card:toString(), 1)
					room:setPlayerMark(player, "huanfutarget" .. use.card:toString(), 1)
					room:setCardFlag(use.card, "huanfucard")
					room:setPlayerMark(player, "keolhuanfudis" .. use.card:toString(), askdis:getSubcards():length())
					--[[if not room:getTag("keolhuanfudis") then
						room:setTag("keolhuanfudis", sgs.QVariant(askdis:getSubcards():length()))
					end]]
				end
			end
		end
		if (event == sgs.TargetSpecified) then
			local use = data:toCardUse()
			if (use.from:objectName() == player:objectName())
				and use.card:isKindOf("Slash")
				and player:hasSkill(self:objectName())
				and not player:isNude() then
				local askdis = room:askForDiscard(player, self:objectName(), player:getMaxHp(), 1, true, true,
					"keolhuanfudis")
				if askdis then
					room:broadcastSkillInvoke(self:objectName())
					room:setPlayerMark(player, "usingkeolhuanfu" .. use.card:toString(), 1)
					room:setPlayerMark(player, "keolhuanfudis" .. use.card:toString(), askdis:getSubcards():length())
					for _, p in sgs.qlist(use.to) do
						room:setPlayerMark(p, "huanfutarget" .. use.card:toString(), 1)
					end
					room:setCardFlag(use.card, "huanfucard")
					--[[if not room:getTag("keolhuanfudis") then
						room:setTag("keolhuanfudis", sgs.QVariant(askdis:getSubcards():length()))
					end]]
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end
}
keolxiahouxuan:addSkill(keolhuanfu)

keolqingyiCard = sgs.CreateSkillCard {
	name = "keolqingyiCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return (#targets < 2) and (not to_select:isNude()) and (to_select:objectName() ~= sgs.Self:objectName())
	end,
	on_use = function(self, room, player, targets)
		local players = sgs.SPlayerList()
		if targets[1] then players:append(targets[1]) end
		if targets[2] then players:append(targets[2]) end
		local cangoon = 1
		local firsttime = 1
		while (cangoon == 1) do
			if (firsttime == 0) then
				local result = room:askForChoice(player, "keolqingyi", "jixu+suanle")
				if result == "suanle" then
					break
				else
					firsttime = 0
					if player:canDiscard(player, "he") and (not player:isNude()) then
						local mydis = room:askForExchange(player, "keolqingyi", 1, 1, true, "keolqingyidis", false)
						room:setCardFlag(sgs.Sanguosha:getCard(mydis:getSubcards():first()), "keolqingyicard")
						for _, p in sgs.qlist(players) do
							if p:canDiscard(p, "he") and (not p:isNude()) then
								local hedis = room:askForExchange(p, "keolqingyi", 1, 1, true, "keolqingyidis", false)
								room:setCardFlag(sgs.Sanguosha:getCard(hedis:getSubcards():first()), "keolqingyicard")
								if (sgs.Sanguosha:getCard(hedis:getSubcards():first()):getType() ~= sgs.Sanguosha:getCard(mydis:getSubcards():first()):getType()) then
									cangoon = 0
								end
							end
						end
						for _, c in sgs.qlist(player:getCards("he")) do
							if c:hasFlag("keolqingyicard") then
								room:throwCard(c, player, player)
							end
						end
						for _, pp in sgs.qlist(players) do
							for _, cc in sgs.qlist(pp:getCards("he")) do
								if cc:hasFlag("keolqingyicard") then
									room:throwCard(cc, pp, pp)
								end
							end
						end
					end
				end
			else
				firsttime = 0
				local mydis = room:askForExchange(player, "keolqingyi", 1, 1, true, "keolqingyidis", false)
				room:setCardFlag(sgs.Sanguosha:getCard(mydis:getSubcards():first()), "keolqingyicard")
				for _, p in sgs.qlist(players) do
					local hedis = room:askForExchange(p, "keolqingyi", 1, 1, true, "keolqingyidis", false)
					room:setCardFlag(sgs.Sanguosha:getCard(hedis:getSubcards():first()), "keolqingyicard")
					if (sgs.Sanguosha:getCard(hedis:getSubcards():first()):getType() ~= sgs.Sanguosha:getCard(mydis:getSubcards():first()):getType()) then
						cangoon = 0
					end
				end
				for _, c in sgs.qlist(player:getCards("he")) do
					if c:hasFlag("keolqingyicard") then
						room:throwCard(c, player, player)
					end
				end
				for _, pp in sgs.qlist(players) do
					for _, cc in sgs.qlist(pp:getCards("he")) do
						if cc:hasFlag("keolqingyicard") then
							room:throwCard(cc, pp, pp)
						end
					end
				end
			end
		end
	end
}

keolqingyiVS = sgs.CreateViewAsSkill {
	name = "keolqingyi",
	n = 0,
	view_as = function(self, cards)
		return keolqingyiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return (not player:isNude()) and (not (player:hasUsed("#keolqingyiCard")))
	end,
}

function keolgetCardList(intlist)
	local ids = sgs.CardList()
	for _, id in sgs.qlist(intlist) do
		ids:append(sgs.Sanguosha:getCard(id))
	end
	return ids
end

keolqingyi = sgs.CreateTriggerSkill {
	name = "keolqingyi",
	view_as_skill = keolqingyiVS,
	events = { sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) and (player:getPhase() == sgs.Player_Finish) then
			local card_ids = sgs.IntList()
			for _, id in sgs.qlist(room:getDiscardPile()) do
				if sgs.Sanguosha:getCard(id):hasFlag("keolqingyicard") then
					room:setCardFlag(sgs.Sanguosha:getCard(id), "-keolqingyicard")
					card_ids:append(id)
				end
			end
			--开始选择各一张
			if not card_ids:isEmpty() then
				room:broadcastSkillInvoke(self:objectName())
				room:fillAG(card_ids)
				local to_get = sgs.IntList()
				while not card_ids:isEmpty() do
					local card_id = room:askForAG(player, card_ids, false, self:objectName(), "keolqingyi-choice")
					card_ids:removeOne(card_id)
					to_get:append(card_id)
					local card = sgs.Sanguosha:getCard(card_id)
					--判断自己选的颜色
					room:takeAG(player, card_id, false)
					local _card_ids = card_ids
					for i = 0, 150 do
						for _, id in sgs.qlist(_card_ids) do
							local c = sgs.Sanguosha:getCard(id)
							if (c:getColor() == card:getColor()) then
								card_ids:removeOne(id)
								room:takeAG(nil, id, false)
							end
						end
					end
				end
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				if not to_get:isEmpty() then
					dummy:addSubcards(keolgetCardList(to_get))
					player:obtainCard(dummy)
				end
				dummy:deleteLater()
				room:clearAG()
			end
		end
	end,
	--[[can_trigger = function(self, player)
		return player
	end,]]
}
keolxiahouxuan:addSkill(keolqingyi)


keolzeyue = sgs.CreateTriggerSkill {
	name = "keolzeyue",
	events = { sgs.Damage, sgs.Damaged, sgs.EventPhaseChanging, sgs.EventPhaseStart, sgs.RoundStart },
	frequency = sgs.Skill_Limited,
	limit_mark = "@keolzeyue",
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.RoundStart) then
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if player:getMark("bezeyue" .. p:objectName()) > 0 then
					room:addPlayerMark(player, "&keolzeyuelose", 1)
				end
			end
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if player:getMark("bezeyue" .. p:objectName()) > 0 then
					for i = 0, player:getMark("&keolzeyuelose") - 1, 1 do
						local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
						slash:setSkillName("keolzeyue")
						local card_use = sgs.CardUseStruct()
						card_use.from = player
						card_use.to:append(p)
						card_use.card = slash
						room:useCard(card_use, false)
						slash:deleteLater()
					end
				end
			end
		end
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			if (damage.from:getMark("bezeyue" .. damage.to:objectName()) > 0) and damage.card
				and (damage.card:getSkillName() == "keolzeyue") then
				room:setPlayerMark(damage.from, "&keolzeyuelose", 0)
				room:removePlayerMark(damage.from, "bezeyue" .. damage.to:objectName())
				local skillname = room:getTag("keolzeyuetag" .. damage.from:objectName()):toString()
				if skillname and (skillname ~= "") then
					room:handleAcquireDetachSkills(damage.from, skillname)
				end
			end
		end
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				room:setPlayerMark(player, "keolzeyueon", 1)
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if (p:getMark("keolzeyue" .. player:objectName()) > 0) then
						room:setPlayerMark(p, "keolzeyueda" .. player:objectName(), 0)
					end
				end
			end
		end
		if (event == sgs.Damaged) then
			local damage = data:toDamage()
			if damage.from and (damage.to:getMark("keolzeyueon") > 0) and damage.to:hasSkill(self:objectName()) then
				room:setPlayerMark(damage.from, "keolzeyueda" .. damage.to:objectName(), 1)
			end
		end
		if (event == sgs.EventPhaseStart)
			and (player:getMark("@keolzeyue") > 0)
			and (player:getPhase() == sgs.Player_Start)
			and (player:hasSkill(self:objectName())) then
			local chooseplayers = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if (p:getMark("keolzeyueda" .. player:objectName()) > 0) then
					chooseplayers:append(p)
				end
			end
			local person = room:askForPlayerChosen(player, chooseplayers, self:objectName(), "keolzeyue-ask", true, true)
			if person then
				room:broadcastSkillInvoke(self:objectName())
				room:doSuperLightbox("keolxiahouxuan", "keolzeyue")
				room:removePlayerMark(player, "@keolzeyue")
				--给一个复仇标记
				room:setPlayerMark(person, "bezeyue" .. player:objectName(), 1)
				local skills_list = {}
				local gen = person:getGeneral()
				local gentwo = person:getGeneral2()
				for _, skill in sgs.qlist(gen:getSkillList()) do
					if (not table.contains(skills_list, skill:objectName()))
						and (not skill:isAttachedLordSkill())
						and (skill:isVisible())
						and (skill:getFrequency() ~= sgs.Skill_Compulsory) then
						table.insert(skills_list, skill:objectName())
					end
				end
				if gentwo then
					for _, skill in sgs.qlist(gentwo:getSkillList()) do
						if (not table.contains(skills_list, skill:objectName()))
							and (not skill:isAttachedLordSkill())
							and (skill:isVisible())
							and (skill:getFrequency() ~= sgs.Skill_Compulsory) then
							table.insert(skills_list, skill:objectName())
						end
					end
				end
				if (#skills_list > 0) then
					skill_zy = room:askForChoice(player, self:objectName(), table.concat(skills_list, "+"))
					room:detachSkillFromPlayer(person, skill_zy)
					room:setTag("keolzeyuetag" .. person:objectName(), sgs.QVariant(skill_zy))
					--player:getTag("Hunshangskills"):toString():split("+")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end
}
keolxiahouxuan:addSkill(keolzeyue)


sgs.LoadTranslationTable {
	["keolxiahouxuan"] = "OL夏侯玄",
	["&keolxiahouxuan"] = "夏侯玄",
	["#keolxiahouxuan"] = "明皎月影",
	["designer:keolxiahouxuan"] = "官方",
	["cv:keolxiahouxuan"] = "官方",
	["illustrator:keolxiahouxuan"] = "官方",

	["keolhuanfu"] = "宦浮",
	[":keolhuanfu"] = "当你使用【杀】指定目标后或成为【杀】的目标后，你可以弃置至多X张牌（X为你的体力上限），若如此做，此【杀】结算完毕时，若此【杀】对目标角色造成的总伤害数等于你弃置的牌数，你摸等同于弃牌数两倍的牌。",

	["keolqingyi"] = "清议",
	[":keolqingyi"] = "出牌阶段限一次，你可以与至多两名其他角色同时弃置一张牌，若这些牌类型相同，你可以重复此流程；结束阶段，你获得上个出牌阶段以此法弃置的牌中每种颜色的牌各一张。",

	["keolqingyidis"] = "清议：请弃置一张牌",
	["keolhuanfudis"] = "你可以发动“宦浮”弃置牌",
	["keolqingyi-choice"] = "请选择每种颜色各一张",

	["keolqingyi:jixu"] = "继续执行此流程",
	["keolqingyi:suanle"] = "取消",

	["keolzeyue"] = "迮阅",
	[":keolzeyue"] = "限定技，准备阶段，你可以令一名你上回合结束后对你造成过伤害的其他角色失去武将牌上的一个非锁定技；每轮开始时，该角色视为对你使用X张【杀】（X为其失去该技能的轮数），若此【杀】对你造成了伤害，其获得该技能。",
	["keolzeyuelose"] = "迮阅轮数",
	["keolzeyue-ask"] = "你可以选择发动“迮阅”的角色",


	["$keolhuanfu1"] = "宦海浮沉，莫问前路。",
	["$keolhuanfu2"] = "仕途险恶，吉凶难料。",
	["$keolqingyi1"] = "布政得失，愿与诸君共议。",
	["$keolqingyi2"] = "领军伐谋，还请诸位献策。",
	["$keolzeyue1"] = "以令相迮，束阀阅之家。",
	["$keolzeyue2"] = "以正相争，清朝野之妒。",
	["~keolxiahouxuan"] = "玉山倾颓心无尘……",

}

kemobilecaosong = sgs.General(extension, "kemobilecaosong", "wei", 3)

kemobileyijin = sgs.CreateTriggerSkill {
	name = "kemobileyijin",
	events = { sgs.GameStart, sgs.EventPhaseStart, sgs.EventPhaseChanging, sgs.DrawNCards, sgs.DamageInflicted },
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_NotActive) then
				--厚任
				if (player:getMark("diskeyijin_houren-SelfClear") > 0) then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					local recover = sgs.RecoverStruct()
					recover.who = player
					recover.recover = 3
					room:recover(player, recover)
				end
				if (player:getMark("diskeyijin_wushi-SelfClear") > 0) then room:removePlayerMark(player, "@keyijin_wushi") end
				if (player:getMark("diskeyijin_jinmi-SelfClear") > 0) then room:removePlayerMark(player, "@keyijin_jinmi") end
				if (player:getMark("diskeyijin_guxiong-SelfClear") > 0) then room:removePlayerMark(player,
						"@keyijin_guxiong") end
				if (player:getMark("diskeyijin_tongshen-SelfClear") > 0) then room:removePlayerMark(player,
						"@keyijin_tongshen") end
				if (player:getMark("diskeyijin_yongbi-SelfClear") > 0) then room:removePlayerMark(player,
						"@keyijin_yongbi") end
				if (player:getMark("diskeyijin_houren-SelfClear") > 0) then room:removePlayerMark(player,
						"@keyijin_houren") end
			end
		end
		--拥蔽:写在金迷里

		--通神
		if (event == sgs.DamageInflicted) then
			local damage = data:toDamage()
			if (damage.to:getMark("diskeyijin_tongshen-SelfClear") > 0)
				and (damage.nature ~= sgs.DamageStruct_Thunder) then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				return true
			end
		end
		--贾凶
		if (event == sgs.EventPhaseStart)
			and (player:getPhase() == sgs.Player_Play)
			and (player:getMark("diskeyijin_guxiong-SelfClear") > 0) then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:loseHp(player)
			room:addMaxCards(player, -3, true)
		end
		--V我50
		if (event == sgs.DrawNCards) and player:getMark("diskeyijin_wushi-SelfClear") > 0 then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			local count = data:toInt()
			count = count + 4
			room:addSlashCishu(player, 1, true)
			data:setValue(count)
		end
		--金迷
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_Play)
				and (player:getMark("diskeyijin_jinmi-SelfClear") > 0) then
				if not player:isSkipped(sgs.Player_Play) then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					player:skip(sgs.Player_Play)
				end
			elseif (change.to == sgs.Player_Discard)
				and (player:getMark("diskeyijin_jinmi-SelfClear") > 0) then
				if not player:isSkipped(sgs.Player_Discard) then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					player:skip(sgs.Player_Discard)
				end
			elseif (change.to == sgs.Player_Draw)
				and (player:getMark("diskeyijin_yongbi-SelfClear") > 0) then
				if not player:isSkipped(sgs.Player_Draw) then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					player:skip(sgs.Player_Draw)
				end
			end
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_RoundStart) and player:hasSkill(self:objectName()) then
				if ((player:getMark("@keyijin_wushi") + player:getMark("@keyijin_jinmi") + player:getMark("@keyijin_guxiong") + player:getMark("@keyijin_tongshen") + player:getMark("@keyijin_yongbi") + player:getMark("@keyijin_houren")) == 0) then
					room:broadcastSkillInvoke(self:objectName(), 3)
					room:getThread():delay(5000)
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:killPlayer(player)
				end
			end
			if (player:getPhase() == sgs.Player_Play) and player:hasSkill(self:objectName()) then
				local chooseplayers = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if ((p:getMark("@keyijin_wushi") + p:getMark("@keyijin_jinmi") + p:getMark("@keyijin_guxiong") + p:getMark("@keyijin_tongshen") + p:getMark("@keyijin_yongbi") + p:getMark("@keyijin_houren")) == 0) then
						chooseplayers:append(p)
					end
				end
				if not chooseplayers:isEmpty() then
					room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
					local giveone = room:askForPlayerChosen(player, chooseplayers, self:objectName(), "kemobileyijin-ask",
						false, true)
					local choices = {}
					if (player:getMark("@keyijin_wushi") > 0) then table.insert(choices, "keyijin_wushi") end
					if (player:getMark("@keyijin_jinmi") > 0) then table.insert(choices, "keyijin_jinmi") end
					if (player:getMark("@keyijin_guxiong") > 0) then table.insert(choices, "keyijin_guxiong") end
					if (player:getMark("@keyijin_tongshen") > 0) then table.insert(choices, "keyijin_tongshen") end
					if (player:getMark("@keyijin_yongbi") > 0) then table.insert(choices, "keyijin_yongbi") end
					if (player:getMark("@keyijin_houren") > 0) then table.insert(choices, "keyijin_houren") end
					local choice = room:askForChoice(player, "kemobileyijin", table.concat(choices, "+"))
					if (choice == "keyijin_wushi") then
						room:removePlayerMark(player, "@keyijin_wushi")
						--结束后要扔这个的
						room:addPlayerMark(giveone, "diskeyijin_wushi-SelfClear")
						room:addPlayerMark(giveone, "@keyijin_wushi")
					elseif (choice == "keyijin_jinmi") then
						room:removePlayerMark(player, "@keyijin_jinmi")
						--结束后要扔这个的
						room:addPlayerMark(giveone, "diskeyijin_jinmi-SelfClear")
						room:addPlayerMark(giveone, "@keyijin_jinmi")
					elseif (choice == "keyijin_guxiong") then
						room:removePlayerMark(player, "@keyijin_guxiong")
						--结束后要扔这个的
						room:addPlayerMark(giveone, "diskeyijin_guxiong-SelfClear")
						room:addPlayerMark(giveone, "@keyijin_guxiong")
					elseif (choice == "keyijin_tongshen") then
						room:removePlayerMark(player, "@keyijin_tongshen")
						--结束后要扔这个的
						room:addPlayerMark(giveone, "diskeyijin_tongshen-SelfClear")
						room:addPlayerMark(giveone, "@keyijin_tongshen")
					elseif (choice == "keyijin_yongbi") then
						room:removePlayerMark(player, "@keyijin_yongbi")
						--结束后要扔这个的
						room:addPlayerMark(giveone, "diskeyijin_yongbi-SelfClear")
						room:addPlayerMark(giveone, "@keyijin_yongbi")
					elseif (choice == "keyijin_houren") then
						room:removePlayerMark(player, "@keyijin_houren")
						--结束后要扔这个的
						room:addPlayerMark(giveone, "diskeyijin_houren-SelfClear")
						room:addPlayerMark(giveone, "@keyijin_houren")
					end
				end
			end
		end
		if (event == sgs.GameStart) and player:hasSkill(self:objectName()) then
			room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
			player:gainMark("@keyijin_wushi")
			player:gainMark("@keyijin_jinmi")
			player:gainMark("@keyijin_guxiong")
			player:gainMark("@keyijin_tongshen")
			player:gainMark("@keyijin_yongbi")
			player:gainMark("@keyijin_houren")
		end
	end,
	can_trigger = function(self, player)
		return player
	end
}
kemobilecaosong:addSkill(kemobileyijin)

kemobileguanzongCard = sgs.CreateSkillCard {
	name = "kemobileguanzongCard",
	will_throw = true,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (to_select:objectName() ~= sgs.Self:objectName())
	end,
	on_use = function(self, room, player, targets)
		local target = targets[1]
		local players = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if (p:objectName() ~= player:objectName()) and (p:objectName() ~= target:objectName()) then
				players:append(p)
			end
		end
		local to = room:askForPlayerChosen(player, room:getOtherPlayers(target), self:objectName(),
			"kemobileguanzong-ask", false, false)
		if to then
			local log = sgs.LogMessage()
			log.type = "$kehuiyaolog"
			log.from = target
			log.to:append(to)
			room:sendLog(log)
			room:doAnimate(1, target:objectName(), to:objectName())
			room:getThread():delay(500)
			local thedamage = sgs.DamageStruct("kemobileguanzong", target, to)
			local _data = sgs.QVariant()
			_data:setValue(thedamage)
			room:getThread():trigger(sgs.Damage, room, target, _data)
			room:getThread():trigger(sgs.Damaged, room, to, _data)
		end
	end
}

kemobileguanzong = sgs.CreateViewAsSkill {
	name = "kemobileguanzong",
	n = 0,
	view_as = function(self, cards)
		return kemobileguanzongCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#kemobileguanzongCard")
	end
}
kemobilecaosong:addSkill(kemobileguanzong)


sgs.LoadTranslationTable {
	["kemobilecaosong"] = "手杀曹嵩",
	["&kemobilecaosong"] = "曹嵩",
	["#kemobilecaosong"] = "舆金贾权",
	["designer:kemobilecaosong"] = "官方",
	["cv:kemobilecaosong"] = "官方",
	["illustrator:kemobilecaosong"] = "官方",

	["kemobileyijin"] = "亿金",
	[":kemobileyijin"] = "锁定技，游戏开始时，你获得六种“金”标记各1枚；回合开始时，若你没有“金”标记，你死亡；出牌阶段开始时，你将1枚“金”标记交给一名其他角色并令其执行对应效果，若如此做，其回合结束后弃置之。\
	<font color='#CFB53B'><b>膴仕：下回合的摸牌阶段多摸四张牌，且出牌阶段可以多使用一张【杀】；\
	金迷：跳过下回合的出牌阶段和弃牌阶段；\
	贾凶：下回合的出牌阶段开始时，失去1点体力且该回合手牌上限-3；\
	通神：防止受到的非雷电伤害；\
	拥蔽：跳过下回合的摸牌阶段；\
	厚任：下回合结束时，回复3点体力。</b></font>",

	["kemobileguanzong-ask"] = "请选择视为造成伤害的 受伤角色",
	["kemobileyijin-ask"] = "请选择“亿金”交给标记的角色",

	["@keyijin_wushi"] = "膴仕",
	["@keyijin_jinmi"] = "金迷",
	["@keyijin_guxiong"] = "贾凶",
	["@keyijin_tongshen"] = "通神",
	["@keyijin_yongbi"] = "拥蔽",
	["@keyijin_houren"] = "厚任",

	["keyijin_wushi"] = "膴仕：摸牌阶段多摸四张，出牌阶段可多使用一张【杀】",
	["keyijin_jinmi"] = "金迷：跳过出牌和弃牌阶段",
	["keyijin_guxiong"] = "贾凶：出牌阶段开始时失去1点体力且手牌上限-3",
	["keyijin_tongshen"] = "通神：防止非雷电伤害",
	["keyijin_yongbi"] = "拥蔽：跳过摸牌阶段",
	["keyijin_houren"] = "厚任：回合结束时回复3点体力",

	["kemobileguanzong"] = "惯纵",
	[":kemobileguanzong"] = "出牌阶段限一次，你可以令一名其他角色视为对另一名其他角色造成过1点伤害。",

	["$kemobileyijin1"] = "吾家资巨万，无惜此两贯三钱！",
	["$kemobileyijin2"] = "小儿持金过闹市，哼！杀人何需我多劳！",
	["$kemobileyijin3"] = "普天之下，竟有吾难市之职？",
	["$kemobileguanzong1"] = "汝为叔父，怎可与小辈计较！",
	["$kemobileguanzong2"] = "阿瞒生龙活虎，汝切勿胡言！",

	["~kemobilecaosong"] = "长恨人心不如水，等闲平地起波澜……",
}


keolliuba = sgs.General(extension, "keolliuba", "shu", 3)

keoltongdu = sgs.CreateTriggerSkill {
	name = "keoltongdu",
	events = { sgs.EventPhaseStart, sgs.EventPhaseEnd },
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) and (player:getPhase() == sgs.Player_Start) then
			local players = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if not p:isKongcheng() then
					players:append(p)
				end
			end
			local person = room:askForPlayerChosen(player, players, self:objectName(), "keoltongdu-ask", true, true)
			if person then
				local card = room:askForExchange(person, self:objectName(), 1, 1, false, "keoltongduchoose")
				if card then
					room:setPlayerMark(player, "keoltongdu", card:getSubcards():first())
					room:obtainCard(player, card,
						sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), player:objectName(),
							self:objectName(), ""), false)
				end
			end
		end
		if (event == sgs.EventPhaseEnd) and (player:getPhase() == sgs.Player_Play) then
			if (player:getMark("keoltongdu") > 0) then
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, player:objectName(), nil,
					"keoltongdu", nil)
				room:moveCardTo(sgs.Sanguosha:getCard(player:getMark("keoltongdu")), player, nil, sgs.Player_DrawPile,
					reason, true)
				room:setPlayerMark(player, "keoltongdu", 0)
			end
		end
	end,
	--[[can_trigger = function(self, player)
		return player
	end]]
}
keolliuba:addSkill(keoltongdu)

keolzhubiVSCard = sgs.CreateSkillCard {
	name = "keolzhubiVSCard",
	will_throw = false,
	target_fixed = true,
}
keolzhubiCard = sgs.CreateSkillCard {
	name = "keolzhubiCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return (#targets < 1) and (not to_select:isNude())
		--and (to_select:objectName() ~= sgs.Self:objectName())
	end,
	on_use = function(self, room, player, targets)
		local target = targets[1]
		--选一张牌
		local cardid = room:askForExchange(target, self:objectName(), 1, 1, true, "keolzhubichoose"):getSubcards():first()
		local card = sgs.Sanguosha:getCard(cardid)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECAST, target:objectName(), "keolzhubi", "")
		--重铸
		room:moveCardTo(card, target, sgs.Player_DiscardPile, reason)
		--标记摸的牌
		local ids = target:drawCardsList(1, "recast")
		room:setCardTip(ids:first(), "keolzhubi")
	end
}

keolzhubiVS = sgs.CreateViewAsSkill {
	name = "keolzhubi",
	n = 999,
	expand_pile = "#keolzhubi",
	view_filter = function(self, selected, to_select)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern == "@@keolzhubi"
		then
			return to_select:hasTip("keolzhubi")
				or sgs.Self:getPileName(to_select:getId()) == "#keolzhubi"
		end
	end,
	view_as = function(self, cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern == "@@keolzhubi"
		then
			local n = 0
			local card = keolzhubiVSCard:clone()
			for _, c in sgs.list(cards) do
				card:addSubcard(c)
				if c:hasTip("keolzhubi")
				then
					n = n + 1
				end
			end
			return #cards > 1 and n == #cards / 2 and card
		else
			return keolzhubiCard:clone()
		end
	end,
	enabled_at_response = function(self, player, pattern)
		return string.find(pattern, "@@keolzhubi")
	end,
	enabled_at_play = function(self, player)
		return (player:usedTimes("#keolzhubiCard") < player:getHp())
	end,
}

keolzhubi = sgs.CreateTriggerSkill {
	name = "keolzhubi",
	events = { sgs.EventPhaseStart },
	view_as_skill = keolzhubiVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (player:getPhase() == sgs.Player_Finish) then
			for _, c in sgs.qlist(player:getHandcards()) do
				if c:hasTip("keolzhubi") then
					--观看五张牌然后交换
					local ids = room:getNCards(5, false, false)
					room:returnToEndDrawPile(ids)
					room:notifyMoveToPile(player, ids, "keolzhubi", sgs.Player_DrawPile, true)
					local uc = room:askForUseCard(player, "@@keolzhubi", "keolzhubi0:", -1, sgs.Card_MethodNone)
					room:notifyMoveToPile(player, ids, "keolzhubi", sgs.Player_DrawPile, false)
					if uc then
						local ids1, dc = sgs.IntList(), dummyCard()
						for _, id in sgs.qlist(uc:getSubcards()) do
							local c = sgs.Sanguosha:getCard(id)
							if c:hasTip("keolzhubi")
							then
								ids1:append(id)
							else
								dc:addSubcard(id)
							end
						end
						room:moveCardsToEndOfDrawpile(player, ids1, "keolzhubi", false)
						room:obtainCard(player, dc, false)
					end
					break
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player and player:isAlive()
	end
}
keolliuba:addSkill(keolzhubi)

sgs.LoadTranslationTable {
	["keolliuba"] = "OL刘巴",
	["&keolliuba"] = "刘巴",
	["#keolliuba"] = "清尚之节",
	["designer:keolliuba"] = "官方",
	["cv:keolliuba"] = "官方",
	["illustrator:keolliuba"] = "官方",

	["keolzhubi0"] = "请选择交换的牌",
	["keolzhubichoose"] = "请选择重铸的牌",
	["keoltongduchoose"] = "请选择一张牌交给该角色",

	["keoltongdu"] = "统度",
	[":keoltongdu"] = "准备阶段，你可以令一名角色交给你一张手牌，然后出牌阶段结束时，你将此牌置于牌堆顶。",

	["keolzhubi"] = "铸币",
	[":keolzhubi"] = "出牌阶段限X次（X为你的体力上限），你可以令一名角色重铸一张牌，以此法摸的牌称为“币”；有“币”的角色的结束阶段，其观看牌堆底的五张牌，然后可以用任意“币”交换其中等量张牌。",

	["$keoltongdu1"] = "上下调度，臣工皆有所为。",
	["$keoltongdu2"] = "统筹部划，不糜国利分毫。",
	["$keolzhubi1"] = "钱货之通者，在乎币。",
	["$keolzhubi2"] = "融金为料，可铸五铢。",

	["~keolliuba"] = "恨未见，铸兵为币之日……",
}


--[[keolmoujiangwei = sgs.General(extension, "keolmoujiangwei", "shu", 4)

keolzhuriCard = sgs.CreateSkillCard{
	name = "keolzhuri",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	mute = true,
	filter = function(self, targets, to_select, player)
		local card = sgs.Sanguosha:getCard(self:getSubcards():at(0))
		local lists = sgs.PlayerList()
		for _, t in sgs.list(targets) do lists:append(t) end
		return card:targetFilter(lists, to_select, player) and not player:isProhibited(to_select, card, lists)
	end,
	feasible = function(self, targets)
		local card = sgs.Sanguosha:getCard(self:getSubcards():at(0))
		local lists = sgs.PlayerList()
		for _, t in sgs.list(targets) do lists:append(t) end
		return card:targetsFeasible(lists, sgs.Self)
	end,
	on_use = function(self, room, source, targets)
		for _, p in sgs.list(targets) do
			room:setPlayerFlag(p, "keolzhuri_target")
		end
	end,
}

keolzhuriVS = sgs.CreateOneCardViewAsSkill{
	name = "keolzhuri",
	expand_pile = "#keolzhuri",
	response_pattern = "@@keolzhuri",
	view_filter = function(self, to_select)
		return to_select:isAvailable(sgs.Self) and sgs.Self:getPile("#keolzhuri"):contains(to_select:getEffectiveId())
	end,
	view_as = function(self, card)
		local slash = keolzhuriCard:clone()
		slash:addSubcard(card)
		return slash
	end
}

keolzhuri = sgs.CreateTriggerSkill{
	name = "keolzhuri" ,
	frequency = sgs.Skill_NotFrequent,
	view_as_skill = keolzhuriVS,
	events = {sgs.EventPhaseStart,sgs.EventPhaseEnd,sgs.CardsMoveOneTime,sgs.Pindian,sgs.EventPhaseChanging} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardsMoveOneTime) and (player:getPhase() ~= sgs.Player_NotActive) then
			local move = data:toMoveOneTime()
			if (move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceHand)) or
				(move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceHand) then
				if (player:getHandcardNum() ~= player:getMark("keolzhurihandcardnum-Clear")) then
					room:setPlayerMark(player,"canzhuripindian-Clear",1)
				end
			end
		end		
		if (event == sgs.EventPhaseStart) then
			room:setPlayerMark(player,"keolzhurihandcardnum-Clear",player:getHandcardNum())
			room:setPlayerMark(player,"canzhuripindian-Clear",0)
		end
		if event == sgs.EventPhaseEnd then
			if (player:getMark("canzhuripindian-Clear") > 0) then
				local players = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if player:canPindian(p,true) and not p:isKongcheng() then
						players:append(p)
					end
				end
				if not players:isEmpty() then
					local eny = room:askForPlayerChosen(player,players , self:objectName(), "keolzhuri-ask", true, true)
					if eny then
						player:pindian(eny, self:objectName(), nil)
					end
				end
			end
		end
		if event == sgs.Pindian then
			local pindian = data:toPindian()	
			if (pindian.reason == self:objectName()) then
				if (pindian.from_number > pindian.to_number) then
					local cards = sgs.IntList()
					cards:append(pindian.from_card:getEffectiveId())
					cards:append(pindian.to_card:getEffectiveId())
					room:notifyMoveToPile(player, cards, self:objectName(), room:getCardPlace(cards:at(0)), true)
					local card = room:askForUseCard(player, "@@keolzhuri", "keolzhuriuse")
					room:notifyMoveToPile(player, cards, self:objectName(), room:getCardPlace(cards:at(0)), false)
					if card then
						card = sgs.Sanguosha:getCard(card:getSubcards():at(0))
						if card:targetFixed() then
							room:useCard(sgs.CardUseStruct(card, player, player))
						else
							local targets = sgs.SPlayerList()
							for _, p in sgs.list(room:getAlivePlayers()) do
								if p:hasFlag("keolzhuri_target") then
									targets:append(p)
									room:setPlayerFlag(p, "-keolzhuri_target")
								end
							end
							if targets:length() > 0 then
								room:useCard(sgs.CardUseStruct(card, player, targets))
							end
						end
					end
				else
					local choice = room:askForChoice(player, self:objectName(), "hp+skill")
					if choice == "hp" then
						room:loseHp(player, 1, true, player, self:objectName())
					else
						room:setPlayerMark(player, "keolzhuri_lose", 1)
						room:detachSkillFromPlayer(player, "keolzhuri")
					end
				end
			end
		end
	end,
}
keolmoujiangwei:addSkill(keolzhuri)

keolzhuriex = sgs.CreateTriggerSkill{
	name = "#keolzhuriex",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = sgs.EventPhaseChanging,
	on_trigger = function(self, event, player, data, room)
		local change = data:toPhaseChange()
		if (change.to == sgs.Player_NotActive) then
			room:sendCompulsoryTriggerLog(player, "keolzhuri")
			room:acquireSkill(player, "keolzhuri")
			room:setPlayerMark(player, "keolzhuri_lose", 0)
		end
	end,
	can_trigger = function(self, player)
		return player and (player:getMark("keolzhuri_lose") > 0)
	end
}
keolmoujiangwei:addSkill(keolzhuriex)
extension:insertRelatedSkills("keolzhuri", "#keolzhuriex")

keolranji = sgs.CreateTriggerSkill{
	name = "keolranji",
	frequency = sgs.Skill_Limited,
	limit_mark = "@keolranji",
	events = {sgs.EventPhaseStart, sgs.CardUsed, sgs.PreHpRecover, sgs.Death},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseStart then
			room:setPlayerFlag(player, "-keolranji_used")
			if player:getMark("@keolranji") == 0 or player:getPhase() ~= sgs.Player_Finish then return false end
			local skills, string = {}, nil
			if player:getMark("keolranji_used-Clear") >= player:getHp() then table.insert(skills,"kunfen") end
			if player:getMark("keolranji_used-Clear") <= player:getHp() then table.insert(skills,"zhaxiang") end
			if #skills == 1 then string = "keolranji1:" end
			if #skills == 2 then string = "keolranji2:" end
			if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant(string .. table.concat(skills,":"))) then
				room:removePlayerMark(player, "@keolranji")
				if table.contains(skills, "kunfen") then
					room:acquireSkill(player, "kunfen")
					room:addPlayerMark(player, "fengliang")
				end
				if table.contains(skills, "zhaxiang") then
					room:acquireSkill(player, "zhaxiang")
				end
				local choices = {}
				if player:isWounded() then table.insert(choices, "recover") end
				if player:getHandcardNum() < player:getMaxHp() then table.insert(choices, "draw") end
				if #choices ~= 0 then
					local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
					if choice == "recover" then
						room:recover(player, sgs.RecoverStruct(player, nil, player:getMaxHp() - player:getHp()))
					else
						room:drawCards(player, player:getMaxHp() - player:getHandcardNum(), self:objectName())
					end
				end
				room:setPlayerMark(player, "&keolranji_ban", 1)
			end
		elseif event == sgs.CardUsed then
			if not player:hasFlag("mouranji_used") then
				room:setPlayerFlag(player, "mouranji_used")
				room:addPlayerMark(player,"mouranji_used-Clear")
			end
		elseif event == sgs.PreHpRecover then
			local recover = data:toRecover()
			if recover.who:objectName() == player:objectName() and player:getMark("&keolranji_ban") > 0 then
				local log = sgs.LogMessage()
				log.type = "$keolranji_msg"
				log.from = player
				room:sendLog(log)
				return true
			end
		else
			local death = data:toDeath()
			if death.who:objectName() == player:objectName() then return false end
			if death.damage and death.damage.from:objectName() == player:objectName() then room:setPlayerMark(player, "&keolranji_ban", 0) end
		end
	end
}
keolmoujiangwei:addSkill(keolranji)]]

--[[keolranji = sgs.CreateTriggerSkill{
	name = "keolranji" ,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart,sgs.CardUsed} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			if (player:getMark("addedranji-Clear") > 0) then
				room:setPlayerMark(player,"addedranji-Clear",1)
				room:addPlayerMark(player,"ranjitimes-Clear",1)
			end
		end
		if event == sgs.EventPhaseStart then
			room:setPlayerMark(player,"addedranji-Clear",0)
			if (player:getPhase() == sgs.Player_Finish) then
			end
			
		end

	end,
}
keolmoujiangwei:addSkill(keolranji)]]

keolmoujiangwei = sgs.General(extension, "keolmoujiangwei", "shu", 4)

keolzhuriCard = sgs.CreateSkillCard {
	name = "keolzhuri",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	mute = true,
	filter = function(self, targets, to_select, player)
		local card = sgs.Sanguosha:getCard(self:getSubcards():at(0))
		local lists = sgs.PlayerList()
		for _, t in sgs.list(targets) do lists:append(t) end
		return card:targetFilter(lists, to_select, player) and not player:isProhibited(to_select, card, lists)
	end,
	feasible = function(self, targets)
		local card = sgs.Sanguosha:getCard(self:getSubcards():at(0))
		local lists = sgs.PlayerList()
		for _, t in sgs.list(targets) do lists:append(t) end
		return card:targetsFeasible(lists, sgs.Self)
	end,
	about_to_use = function(self, room, use)
		local source = use.from
		local n = 1
		for _, p in sgs.list(use.to) do
			room:setPlayerMark(p, "&keolzhuri_target", n)
			n = n + 1
		end
	end
}

keolzhuriVS = sgs.CreateOneCardViewAsSkill {
	name = "keolzhuri",
	expand_pile = "#keolzhuri",
	response_pattern = "@@keolzhuri",
	view_filter = function(self, to_select)
		return to_select:isAvailable(sgs.Self) and sgs.Self:getPile("#keolzhuri"):contains(to_select:getEffectiveId())
	end,
	view_as = function(self, card)
		local slash = keolzhuriCard:clone()
		slash:addSubcard(card)
		return slash
	end
}

keolzhuri = sgs.CreateTriggerSkill {
	name = "keolzhuri",
	view_as_skill = keolzhuriVS,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.CardsMoveOneTime, sgs.EventPhaseEnd, sgs.Pindian },
	on_trigger = function(self, event, player, data, room)
		if event == sgs.CardsMoveOneTime and player:getPhase() ~= sgs.Player_NotActive then
			local move = data:toMoveOneTime()
			if (move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceHand)) or
				(move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceHand) then
				room:setPlayerMark(player, "keolzhuri_changed", 1)
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() ~= sgs.Player_NotActive and player:getPhase() ~= sgs.Player_RoundStart and player:getMark("keolzhuri_changed") > 0 and player:getMark("keolzhuri_lose") == 0 then
				local targets = sgs.SPlayerList()
				for _, p in sgs.list(room:getOtherPlayers(player)) do
					if player:canPindian(p) and not p:isKongcheng() then targets:append(p) end
				end
				if targets:length() > 0 then
					local target = room:askForPlayerChosen(player, targets, self:objectName(), "@keolzhuri_choose", true,
						true)
					if target then
						room:broadcastSkillInvoke(self:objectName())
						player:pindian(target, self:objectName())
					end
				end
			end
			room:setPlayerMark(player, "keolzhuri_changed", 0)
		elseif event == sgs.Pindian then
			local pindian = data:toPindian()
			if pindian.reason ~= self:objectName() then return false end
			if pindian.from_number > pindian.to_number then
				local cards = sgs.IntList()
				cards:append(pindian.from_card:getEffectiveId())
				cards:append(pindian.to_card:getEffectiveId())
				room:notifyMoveToPile(player, cards, self:objectName(), room:getCardPlace(cards:at(0)), true)
				local card = room:askForUseCard(player, "@@keolzhuri", "@keolzhuri_use")
				room:notifyMoveToPile(player, cards, self:objectName(), room:getCardPlace(cards:at(0)), false)
				if card then
					card = sgs.Sanguosha:getCard(card:getSubcards():at(0))
					if card:targetFixed() then
						room:useCard(sgs.CardUseStruct(card, player, player))
					else
						local targets = sgs.SPlayerList()
						for i = 1, 20 do
							for _, p in sgs.list(room:getAlivePlayers()) do
								if p:getMark("&keolzhuri_target") == i then
									targets:append(p)
									room:setPlayerMark(p, "&keolzhuri_target", 0)
								end
							end
						end
						if targets:length() > 0 then
							room:useCard(sgs.CardUseStruct(card, player, targets))
						end
					end
				end
			else
				local choice = room:askForChoice(player, self:objectName(), "hp+skill")
				if choice == "hp" then
					room:loseHp(player, 1, true, player, self:objectName())
				else
					room:setPlayerMark(player, "keolzhuri_lose", 1)
					room:detachSkillFromPlayer(player, "keolzhuri")
				end
			end
		end
	end
}

keolzhuriEffect = sgs.CreateTriggerSkill {
	name = "#keolzhuriEffect",
	frequency = sgs.Skill_Compulsory,
	events = sgs.EventPhaseChanging,
	on_trigger = function(self, event, player, data, room)
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then return false end
		local jiangwei = sgs.SPlayerList()
		for _, p in sgs.list(room:getAlivePlayers()) do
			if p:getMark("keolzhuri_lose") > 0 then jiangwei:append(p) end
		end
		if jiangwei:length() == 0 then return false end
		for _, p in sgs.list(jiangwei) do
			room:sendCompulsoryTriggerLog(p, "keolzhuri")
			room:acquireSkill(p, "keolzhuri")
			room:setPlayerMark(p, "keolzhuri_lose", 0)
		end
	end,
	can_trigger = function(self, player)
		return player
	end
}

keolranji = sgs.CreateTriggerSkill {
	name = "keolranji",
	frequency = sgs.Skill_Limited,
	limit_mark = "@keolranji",
	waked_skills = "zhaxiang,kunfen",
	events = { sgs.EventPhaseStart, sgs.CardUsed, sgs.PreHpRecover, sgs.Death },
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseStart then
			room:setPlayerFlag(player, "-keolranji_used")
			if player:getMark("@keolranji") == 0 or player:getPhase() ~= sgs.Player_Finish then return false end
			local skills, string = {}, nil
			if player:getMark("keolranji_used-Clear") >= player:getHp() then table.insert(skills, "kunfen") end
			if player:getMark("keolranji_used-Clear") <= player:getHp() then table.insert(skills, "zhaxiang") end
			if #skills == 1 then string = "keolranji1:" end
			if #skills == 2 then string = "keolranji2:" end
			if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant(string .. table.concat(skills, ":"))) then
				room:broadcastSkillInvoke(self:objectName())
				room:doSuperLightbox("keolmoujiangwei", "keolranji")
				room:removePlayerMark(player, "@keolranji")
				if table.contains(skills, "kunfen") then
					room:acquireSkill(player, "kunfen")
					room:addPlayerMark(player, "fengliang")
				end
				if table.contains(skills, "zhaxiang") then
					room:acquireSkill(player, "zhaxiang")
				end
				local choices = {}
				if player:isWounded() then table.insert(choices, "recover") end
				if player:getHandcardNum() < player:getMaxHp() then table.insert(choices, "draw") end
				if #choices ~= 0 then
					local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
					if choice == "recover" then
						room:recover(player, sgs.RecoverStruct(player, nil, player:getMaxHp() - player:getHp()))
					else
						room:drawCards(player, player:getMaxHp() - player:getHandcardNum(), self:objectName())
					end
				end
				room:setPlayerMark(player, "&keolranji_ban", 1)
			end
		elseif event == sgs.CardUsed then
			if not player:hasFlag("keolranji_used") then
				room:setPlayerFlag(player, "keolranji_used")
				room:addPlayerMark(player, "keolranji_used-Clear")
			end
		elseif event == sgs.PreHpRecover then
			local recover = data:toRecover()
			if (player:getMark("&keolranji_ban") == 0) then return end
			local log = sgs.LogMessage()
			log.type = "$keolranji_msg"
			log.from = player
			room:sendLog(log)
			room:setEmotion(player, "judgebad");
			return true
		else
			local death = data:toDeath()
			if death.who:objectName() == player:objectName() then return false end
			if death.damage and death.damage.from:objectName() == player:objectName() then room:setPlayerMark(player,
					"&keolranji_ban", 0) end
		end
	end
}

keolmoujiangwei:addSkill(keolzhuri)
keolmoujiangwei:addSkill(keolzhuriEffect)
extension:insertRelatedSkills("keolzhuri", "#keolzhuriEffect")
keolmoujiangwei:addSkill(keolranji)

--sgs.Sanguosha:setAudioType("keolmoujiangwei","zhaxiang","3,4")

sgs.LoadTranslationTable {

	["keolmoujiangwei"] = "OL谋姜维",
	["&keolmoujiangwei"] = "谋姜维",
	["#keolmoujiangwei"] = "炎志灼心",
	["designer:keolmoujiangwei"] = "官方",
	["illustrator:keolmoujiangwei"] = "官方",
	["cv:keolmoujiangwei"] = "官方",
	["keolzhuri"] = "逐日",
	["#keolzhuri"] = "逐日",
	["keolzhuri:hp"] = "失去1点体力",
	["keolzhuri:skill"] = "失去本技能直到回合结束",
	["@keolzhuri_choose"] = "你可以与一名其他角色拼点",
	["@keolzhuri_use"] = "你可以使用一张拼点牌",
	[":keolzhuri"] = "你的阶段结束时，若你本阶段手牌数变化过，你可以拼点：若你赢，你可以使用一张拼点牌；若你没赢，你失去1点体力或失去“逐日”直到回合结束。",
	["keolranji"] = "燃己",
	["keolranji_ban"] = "禁止回复",
	["keolranji:keolranji1"] = "你可以发动“燃己”获得“%src”",
	["keolranji:keolranji2"] = "你可以发动“燃己”获得“%src”和“%dest”",
	["keolranji:recover"] = "将体力值调整至体力上限",
	["keolranji:draw"] = "将手牌数调整至体力上限",
	["$keolranji_msg"] = "%from 由于“<font color='yellow'><b>燃己</b></font>”的效果，不能回复体力值",
	[":keolranji"] = "限定技，结束阶段，若你本回合使用过牌的阶段数：不小于体力值，你可以获得“困奋”（升级）；不大于体力值，你可以获得“诈降”。若如此做，你将手牌数或体力值调整至上限，然后防止你回复体力直到你杀死角色。",

	["$keolzhuri1"] = "效逐日之夸父，怀忠志而长存。",
	["$keolzhuri2"] = "知天命而不顺，履穷途而强为。",
	["$keolranji1"] = "此身为薪，炬成灰亦照大汉长明。",
	["$keolranji2"] = "维之一腔骨血，可驱驰来北马否？",

	["~keolmoujiangwei"] = "姜维姜维，又将何为……",
}

keolzhangyi = sgs.General(extension, "keolzhangyi", "shu", 4)

keoldianjun = sgs.CreateTriggerSkill {
	name = "keoldianjun",
	frequency = sgs.Skill_Compulsory,
	events = sgs.EventPhaseChanging,
	on_trigger = function(self, event, player, data, room)
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then return false end
		room:broadcastSkillInvoke(self:objectName())
		room:damage(sgs.DamageStruct(self:objectName(), nil, player))
		player:setPhase(sgs.Player_Play)
		room:broadcastProperty(player, "phase")
		local thread = room:getThread()
		if not thread:trigger(sgs.EventPhaseStart, room, player) then
			thread:trigger(sgs.EventPhaseProceeding, room, player)
		end
		thread:trigger(sgs.EventPhaseEnd, room, player)
		player:setPhase(sgs.Player_RoundStart)
		room:broadcastProperty(player, "phase")
	end,
	--[[can_trigger = function(self, player)
		return player
	end]]
}
keolzhangyi:addSkill(keoldianjun)

keolkangrui = sgs.CreateTriggerSkill {
	name = "keolkangrui",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.Damaged, sgs.Damage, sgs.ConfirmDamage },
	on_trigger = function(self, event, player, data, room)
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			if (damage.from:getMark("readydismax-Clear") > 0) then
				room:addMaxCards(player, -player:getMaxCards(), true)
			end
		end
		if (event == sgs.ConfirmDamage) then
			local damage = data:toDamage()
			if (damage.from and damage.from:getMark("&keolkangrui-Clear") > 0) then
				local hurt = damage.damage
				damage.damage = hurt + 1
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:addPlayerMark(player, "readydismax-Clear", 1)
				data:setValue(damage)
			end
		end
		if (event == sgs.Damaged) then
			local damage = data:toDamage()
			if (damage.to:getPhase() ~= sgs.Player_NotActive) and (damage.to:getMark("keolkangruifirst-Clear") == 0) then
				room:setPlayerMark(damage.to, "keolkangruifirst-Clear", 1)
				for _, zy in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					local to_data = sgs.QVariant()
					to_data:setValue(damage.to)
					if room:askForSkillInvoke(zy, self:objectName(), to_data) then
						room:broadcastSkillInvoke(self:objectName())
						zy:drawCards(1)
						--for ai
						for _, c in sgs.qlist(damage.to:getCards("h")) do
							if c:isDamageCard() and c:isAvailable(damage.to) then
								room:setPlayerFlag(zy, "wantkangruida")
								break
							end
						end
						local result = room:askForChoice(zy, self:objectName(), "huifu+damage")
						room:setPlayerFlag(zy, "-wantkangruida")
						if result == "huifu" then
							room:recover(damage.to, sgs.RecoverStruct())
						else
							room:addPlayerMark(damage.to, "&keolkangrui-Clear")
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end
}
keolzhangyi:addSkill(keolkangrui)

sgs.LoadTranslationTable {
	["keolzhangyi"] = "OL张翼",
	["&keolzhangyi"] = "张翼",
	["#keolzhangyi"] = "奉公弗怠",
	["designer:keolzhangyi"] = "官方",
	["cv:keolzhangyi"] = "官方",
	["illustrator:keolzhangyi"] = "官方",


	["keoldianjun"] = "殿军",
	[":keoldianjun"] = "锁定技，回合结束时，你受到1点无来源的伤害并执行一个额外的出牌阶段。",

	["keolkangrui:huifu"] = "令其回复1点体力",
	["keolkangrui:damage"] = "其本回合下次造成的伤害+1且造成伤害后手牌上限改为0",
	["keolkangrui"] = "亢锐",
	[":keolkangrui"] = "当一名角色于其回合内首次受到伤害后，你可以摸一张牌并选择一项：1.其回复1点体力；2.其本回合下次造成的伤害+1，且造成伤害后其此回合手牌上限改为0。",

	["$keoldianjun1"] = "大将军勿忧，翼可领后军。",
	["$keoldianjun2"] = "诸将速行，某自领军殿后。",
	["$keolkangrui1"] = "尔等魍魉，愿试吾剑之利乎？",
	["$keolkangrui2"] = "诸君鼓励，克复中原指日可待！",

	["~keolzhangyi"] = "伯约不见疲惫之国力乎？",
}


keolyanliangwenchou = sgs.General(extension, "keolyanliangwenchou", "qun", 4)

function kenewgetCardList(intlist)
	local ids = sgs.CardList()
	for _, id in sgs.qlist(intlist) do
		ids:append(sgs.Sanguosha:getCard(id))
	end
	return ids
end

--local json = require ("json")
keolshuangxiongVS = sgs.CreateOneCardViewAsSkill {
	name = "keolshuangxiong",
	view_filter = function(self, to_select)
		return (to_select:getColor() ~= sgs.Self:getMark("keolshuangxiong-Clear"))
	end,
	view_as = function(self, card)
		local duel = sgs.Sanguosha:cloneCard("duel", card:getSuit(), card:getNumber())
		duel:setSkillName(self:objectName())
		duel:addSubcard(card)
		return duel
	end,
	enabled_at_play = function(self, player)
		return player:hasFlag("keolshuangxiong")
	end
}

keolshuangxiong = sgs.CreateTriggerSkill {
	name = "keolshuangxiong",
	view_as_skill = keolshuangxiongVS,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseEnd, sgs.EventPhaseStart, sgs.Damaged },
	on_trigger = function(self, event, player, data, room)
		if (event == sgs.Damaged) then
			local damage = data:toDamage()
			if damage.card and (damage.to:getPhase() ~= sgs.Player_NotActive) then
				--and (damage.card:getSubcards():length() > 0) then
				local tag = player:getTag("keolshuangxiongToGet"):toIntList()
				if damage.card:isVirtualCard()
				then
					for _, id in sgs.qlist(damage.card:getSubcards()) do
						tag:append(id)
					end
				else
					tag:append(damage.card:getId())
				end
				local data = sgs.QVariant()
				data:setValue(tag)
				player:setTag("keolshuangxiongToGet", data)
			end
		end
		if (event == sgs.EventPhaseEnd) and (player:getPhase() == sgs.Player_Draw) then
			local xxx = room:askForDiscard(player, self:objectName(), 1, 1, true, true, "keolshuangxiongdis")
			if xxx then
				room:setPlayerMark(player, "&keolshuangxiong+" .. xxx:getColorString() .. "-Clear", 1)
				room:setPlayerMark(player, "keolshuangxiong-Clear", xxx:getColor())
				room:setPlayerFlag(player, "keolshuangxiong")
			end
		end
		if (event == sgs.EventPhaseStart) and (player:getPhase() == sgs.Player_Finish) then
			local tag = player:getTag("keolshuangxiongToGet"):toIntList()
			player:removeTag("keolshuangxiongToGet")
			if tag:isEmpty() then
				return false
			end
			local cards = sgs.IntList()
			for _, id in sgs.qlist(tag) do
				if room:getCardPlace(id) == sgs.Player_DiscardPile then
					cards:append(id)
				end
			end
			if cards:length() > 0 then
				room:broadcastSkillInvoke(self:objectName())
				local move = sgs.CardsMoveStruct()
				move.card_ids = cards
				move.to = player
				move.to_place = sgs.Player_PlaceHand
				room:moveCardsAtomic(move, true)
			end
			--[[local gets = sgs.IntList()
			for _, id in sgs.qlist(room:getDiscardPile()) do
				if (sgs.Sanguosha:getCard(id):hasFlag("keolshuangxiong")) then
					room:setCardFlag(sgs.Sanguosha:getCard(id),"-keolshuangxiong")
					gets:append(id)
				end
			end	
			if gets:length()>0 then
				player:drawCards(5)
			end
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			dummy:addSubcards(kenewgetCardList(gets))
			player:obtainCard(dummy)
			dummy:deleteLater()]]
		end
	end,
	--[[can_trigger = function(self, player)
		return player
	end]]
}
keolyanliangwenchou:addSkill(keolshuangxiong)

sgs.LoadTranslationTable {
	["keolyanliangwenchou"] = "OL颜良文丑",
	["&keolyanliangwenchou"] = "颜良文丑",
	["#keolyanliangwenchou"] = "虎狼兄弟",
	["designer:keolyanliangwenchou"] = "官方",
	["cv:keolyanliangwenchou"] = "官方",
	["illustrator:keolyanliangwenchou"] = "官方",

	["keolshuangxiong"] = "双雄",
	[":keolshuangxiong"] = "摸牌阶段结束时，你可以弃置一张牌，然后你本回合可以将一张与之颜色不同的牌当【决斗】使用；结束阶段，你获得你回合内对你造成过伤害的牌。",

	["keolshuangxiongdis"] = "你可以发动“双雄”弃置一张牌",
	["keolshuangxiongred"] = "双雄弃红",
	["keolshuangxiongblack"] = "双雄弃黑",

	["$keolshuangxiong2"] = "兄弟协力，定可于乱世纵横。",
	["$keolshuangxiong1"] = "吾执矛，君执槊，此天下可有挡我者。",

	["~keolyanliangwenchou"] = "双雄皆陨，徒隆武圣之名……",
}

keolzhujun = sgs.General(extension, "keolzhujun", "qun", 4)

local function kechsize(tmp)
	if not tmp then
		return 0
	elseif tmp > 240 then
		return 4
	elseif tmp > 225 then
		return 3
	elseif tmp > 192 then
		return 2
	else
		return 1
	end
end

local function keutf8len(str)
	local length = 0
	local currentIndex = 1
	while currentIndex <= #str do
		local tmp    = string.byte(str, currentIndex)
		currentIndex = currentIndex + kechsize(tmp)
		length       = length + 1
	end
	return length
end

keolcuipo = sgs.CreateTriggerSkill {
	name = "keolcuipo",
	events = { sgs.CardUsed, sgs.ConfirmDamage, sgs.CardResponded },
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			room:addPlayerMark(player, "&keolcuipo-Clear")
			if (player:getMark("&keolcuipo-Clear") == keutf8len(sgs.Sanguosha:translate(use.card:objectName()))) then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				if use.card:isKindOf("Slash") or (use.card:isKindOf("TrickCard") and use.card:isDamageCard()) then
					room:setCardFlag(use.card, "keolcuipo")
				else
					player:drawCards(1)
				end
			end
		end
		if event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.card and damage.card:hasFlag("keolcuipo") then
				local hurt = damage.damage
				damage.damage = hurt + 1
				--room:sendCompulsoryTriggerLog(player, self:objectName())
				--room:broadcastSkillInvoke(self:objectName())
				data:setValue(damage)
			end
		end
		if (event == sgs.CardResponded) then
			local response = data:toCardResponse()
			local room = player:getRoom()
			room:addPlayerMark(player, "&keolcuipo-Clear")
			if (player:getMark("&keolcuipo-Clear") == keutf8len(sgs.Sanguosha:translate(response.m_card:objectName()))) then
				player:drawCards(1)
			end
		end
	end,
}
keolzhujun:addSkill(keolcuipo)

sgs.LoadTranslationTable {
	["keolzhujun"] = "OL朱儁",
	["&keolzhujun"] = "朱儁",
	["#keolzhujun"] = "钦明神武",
	["designer:keolzhujun"] = "官方",
	["cv:keolzhujun"] = "官方",
	["illustrator:keolzhujun"] = "官方",

	["keolcuipo"] = "摧破",
	[":keolcuipo"] = "锁定技，当你于当前回合使用第X张牌时（X为此牌牌名字数），若此牌为【杀】或伤害类锦囊牌，此牌造成的伤害+1，否则你摸一张牌。",

	["$keolcuipo1"] = "虎贲冯河，何惧千城。",
	["$keolcuipo2"] = "长锋在手，万寇辟易。",

	["~keolzhujun"] = "李郭匹夫，安敢辱我！",
}

keolquhuang = sgs.General(extension, "keolquhuang", "wu", 3)
keolqiejian = sgs.CreateTriggerSkill {
	name = "keolqiejian",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.CardsMoveOneTime },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.from
			and move.from:objectName() == player:objectName()
			and move.from_places:contains(sgs.Player_PlaceHand)
			and move.is_last_handcard
			and (player:getMark("&keolqiejian_lun") == 0) then
			for _, qh in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				local to_data = sgs.QVariant()
				to_data:setValue(player)
				local will_use = room:askForSkillInvoke(qh, self:objectName(), to_data)
				if will_use then
					room:broadcastSkillInvoke(self:objectName())
					--if room:askForSkillInvoke(qh, self:objectName(), data) then
					qh:drawCards(1, self:objectName())
					player:drawCards(1, self:objectName())
					local players = sgs.SPlayerList()
					if qh:canDiscard(qh, "ej") then
						players:append(qh)
					end
					if player:canDiscard(player, "ej") then
						if not players:contains(player) then
							players:append(player)
						end
					end
					local disone = room:askForPlayerChosen(qh, players, self:objectName(), "keolqiejian-ask", true, true)
					if disone then
						local to_throw = room:askForCardChosen(qh, disone, "ej", self:objectName())
						local card = sgs.Sanguosha:getCard(to_throw)
						room:throwCard(card, disone, qh)
					else
						room:setPlayerMark(player, "&keolqiejian_lun", 1)
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, player)
		return player
	end
}
keolquhuang:addSkill(keolqiejian)

keolnishou = sgs.CreateTriggerSkill {
	name = "keolnishou",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.CardsMoveOneTime, sgs.EventPhaseEnd },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseEnd) then
			for _, qh in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if (qh:getMark("&keolnishoujiaohuan-Clear") > 0) then
					room:setPlayerMark(qh, "&keolnishoujiaohuan-Clear", 0)
					local players = sgs.SPlayerList()
					players:append(qh)
					for _, p in sgs.qlist(room:getAllPlayers()) do
						for _, pp in sgs.qlist(players) do
							if (p:getHandcardNum() < pp:getHandcardNum()) then
								players:append(p)
								players:removeOne(pp)
							end
						end
					end
					local eny = room:askForPlayerChosen(qh, players, self:objectName(), "keolnishou-ask", false, true)
					if eny then
						room:broadcastSkillInvoke(self:objectName())
						local n1 = qh:getHandcardNum()
						local n2 = eny:getHandcardNum()
						for _, p in sgs.qlist(room:getAlivePlayers()) do
							if p:objectName() ~= qh:objectName() and p:objectName() ~= eny:objectName() then
								room:doNotify(p, sgs.CommandType.S_COMMAND_EXCHANGE_KNOWN_CARDS,
									json.encode({ qh:objectName(), eny:objectName() }))
							end
						end
						local exchangeMove = sgs.CardsMoveList()
						local move1 = sgs.CardsMoveStruct(qh:handCards(), eny, sgs.Player_PlaceHand,
							sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, qh:objectName(), eny:objectName(),
								self:objectName(), ""))
						local move2 = sgs.CardsMoveStruct(eny:handCards(), qh, sgs.Player_PlaceHand,
							sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, eny:objectName(), qh:objectName(),
								self:objectName(), ""))
						exchangeMove:append(move1)
						exchangeMove:append(move2)
						room:moveCardsAtomic(exchangeMove, false)
					end
				end
			end
		end
		if (event == sgs.CardsMoveOneTime) then
			local move = data:toMoveOneTime()
			if move.from
				and (move.from:objectName() == player:objectName())
				and player:hasSkill(self:objectName())
				and (not move.from_places:contains(sgs.Player_PlaceHand))
				and move.from_places:contains(sgs.Player_PlaceEquip)
				and (move.to_place == sgs.Player_DiscardPile) then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				if (player:getMark("&keolnishoujiaohuan-Clear") > 0) and (not player:containsTrick("lightning")) then
					local sdcard = sgs.Sanguosha:getCard(move.card_ids:first())
					local shandian = sgs.Sanguosha:cloneCard("lightning", sdcard:getSuit(), sdcard:getNumber())
					shandian:setSkillName("keolnishou")
					shandian:addSubcard(sdcard)
					if (not player:isProhibited(player, shandian)) and (not player:containsTrick("lightning")) then
						room:useCard(sgs.CardUseStruct(shandian, player, player))
					end
				else
					if (not player:containsTrick("lightning")) then
						local result = room:askForChoice(player, self:objectName(), "shandian+jiaohuan")
						if result == "shandian" then
							local sdcard = sgs.Sanguosha:getCard(move.card_ids:first())
							local shandian = sgs.Sanguosha:cloneCard("lightning", sdcard:getSuit(), sdcard:getNumber())
							shandian:setSkillName("keolnishou")
							shandian:addSubcard(sdcard)
							if not player:isProhibited(player, shandian) and (not player:containsTrick("lightning")) then
								room:useCard(sgs.CardUseStruct(shandian, player, player))
							end
						else
							room:setPlayerMark(player, "&keolnishoujiaohuan-Clear", 1)
						end
					else
						room:setPlayerMark(player, "&keolnishoujiaohuan-Clear", 1)
					end
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end
}
keolquhuang:addSkill(keolnishou)

sgs.LoadTranslationTable {
	["keolquhuang"] = "屈晃",
	["&keolquhuang"] = "屈晃",
	["#keolquhuang"] = "泥头自缚",
	["designer:keolquhuang"] = "官方",
	["cv:keolquhuang"] = "官方",
	["illustrator:keolquhuang"] = "官方",

	["keolqiejian"] = "切谏",
	[":keolqiejian"] = "当一名角色失去最后的手牌后，你可以与其各摸一张牌，然后选择一项：1.弃置你或其场上的一张牌；2.你本轮不能对其发动此技能。",

	["keolnishou"] = "泥首",
	["keolnishou:shandian"] = "将此牌当【闪电】使用",
	["keolnishou:jiaohuan"] = "本阶段结束时与手牌数最少的角色交换手牌",
	[":keolnishou"] = "锁定技，当你装备区里的牌进入弃牌堆后，你选择一项：1.将此牌当【闪电】使用；2.本阶段结束时，你与一名全场手牌数最少的角色交换手牌且本阶段内你无法选择此项。",

	["keolnishoujiaohuan"] = "泥首交换",
	["keolnishou-ask"] = "请选择一名角色，阶段结束后与其交换手牌",
	["keolqiejian-ask"] = "你可以弃置你或该角色场上的一张牌",


	["$keolqiejian1"] = "东宫不稳，必使众人生异。",
	["$keolqiejian2"] = "今三方鼎持，不宜擅动储君。",
	["$keolnishou1"] = "臣以泥涂首，足证本心。",
	["$keolnishou2"] = "人生百年，终埋一抔黄土。",

	["~keolquhuang"] = "臣死谏于斯，死得其所……",
}

keolwenqin = sgs.General(extension, "keolwenqin", "wei", 4)

keolguangaoex = sgs.CreateTargetModSkill {
	name = "#keolguangaoex",
	pattern = "Slash",
	extra_target_func = function(self, from)
		local k = 0
		if from:hasSkill("keolguangao") then
			return 1
		end
	end,
}
keolwenqin:addSkill(keolguangaoex)

keolguangao = sgs.CreateTriggerSkill {
	name = "keolguangao",
	frequency == sgs.Skill_Frequent,
	events = { sgs.CardUsed },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") then
				--别人额外目标
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:hasSkill(self:objectName()) and (not use.to:contains(p)) then
						if not player:isYourFriend(p) then room:setPlayerFlag(player, "wantusekeolguangao") end
						if player:askForSkillInvoke(self, KeToData("keolguangao-ask:" .. p:objectName())) then
							room:doAnimate(1, player:objectName(), p:objectName())
							room:broadcastSkillInvoke(self:objectName())
							room:setPlayerFlag(player, "-wantusekeolguangao")
							use.to:append(p)
						end
						room:setPlayerFlag(player, "-wantusekeolguangao")
					end
				end
				--自己用杀摸牌情形
				if (use.from:hasSkill(self:objectName())) then
					if (use.from:getHandcardNum() % 2 == 0) then
						use.from:drawCards(1)
						local fris = room:askForPlayersChosen(use.from, use.to, self:objectName(), 0, 99,
							"keolguangaominus-ask", true, true)
						if (fris:length() > 0) then
							room:broadcastSkillInvoke(self:objectName())
						end
						local nullified_list = use.nullified_list
						for _, p in sgs.qlist(fris) do
							table.insert(nullified_list, p:objectName())
						end
						use.nullified_list = nullified_list
						data:setValue(use)
					end
				end
				--被杀摸牌情形
				for _, p in sgs.qlist(use.to) do
					if p:hasSkill(self:objectName()) then
						if (p:getHandcardNum() % 2 == 0) then
							p:drawCards(1)
							local fris = room:askForPlayersChosen(p, use.to, self:objectName(), 0, 99,
								"keolguangaominus-ask", true, true)
							if (fris:length() > 0) then
								room:broadcastSkillInvoke(self:objectName())
							end
							local nullified_list = use.nullified_list
							for _, p in sgs.qlist(fris) do
								table.insert(nullified_list, p:objectName())
							end
							use.nullified_list = nullified_list
							data:setValue(use)
						end
					end
				end
				data:setValue(use)
			end
		end
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end
}
keolwenqin:addSkill(keolguangao)
extension:insertRelatedSkills("keolguangao", "#keolguangaoex")

keolhuiqi = sgs.CreateTriggerSkill {
	name = "keolhuiqi",
	events = { sgs.TargetConfirmed, sgs.EventPhaseChanging },
	frequency = sgs.Skill_Wake,
	waked_skills = "keolxieju",
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				--	local countnum = 0
				--[[for _,p in sgs.qlist(room:getAllPlayers()) do
					if (p:getMark("&keolhuiqi-Clear") > 0) then
						countnum = countnum + 1
					end
				end]]
				--if (countnum == 3) then
				for _, wq in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					if (wq:getMark("keolhuiqi-Clear") == 3)
						and (wq:getMark("&keolhuiqi-Clear") > 0) and (wq:getMark(self:objectName()) == 0) then
						room:sendCompulsoryTriggerLog(wq, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						room:doSuperLightbox("keolwenqin", "keolhuiqi")
						room:setPlayerMark(wq, self:objectName(), 1)
						room:changeMaxHpForAwakenSkill(wq, 0)
						room:recover(wq, sgs.RecoverStruct())
						room:acquireSkill(wq, "keolxieju")
					end
				end
				--end
			end
		end
		if (event == sgs.TargetConfirmed) then
			local use = data:toCardUse()
			local wqs = room:findPlayersBySkillName(self:objectName())
			if not use.card:isKindOf("SkillCard") then
				for _, p in sgs.qlist(use.to) do
					if (p:getMark("&keolhuiqi-Clear") == 0) then
						for _, pp in sgs.qlist(wqs) do
							room:addPlayerMark(pp, "keolhuiqi-Clear", 1)
						end
						room:setPlayerMark(p, "&keolhuiqi-Clear", 1, wqs)
					end
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end
}
keolwenqin:addSkill(keolhuiqi)

--黑牌当杀（以下）
keolxiejuslash = sgs.CreateViewAsSkill {
	name = "keolxiejuslash",
	n = 1,
	view_filter = function(self, selected, to_select)
		return #selected == 0 and (not sgs.Self:isJilei(to_select)) and to_select:isBlack()
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then
			return nil
		end
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:setSkillName("_keolxieju")
		slash:addSubcard(cards[1])
		return slash
	end,
	enabled_at_play = function()
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern:startsWith("@@keolxiejuslash")
	end
}
if not sgs.Sanguosha:getSkill("keolxiejuslash") then skills:append(keolxiejuslash) end
--黑牌当杀（以上结束）

keolxiejuCard = sgs.CreateSkillCard {
	name = "keolxiejuCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return (to_select:getMark("keolxiejutar-Clear") > 0)
	end,
	on_use = function(self, room, player, targets)
		for _, p in sgs.list(targets) do
			--依次询问黑牌当杀
			room:askForUseCard(p, "@@keolxiejuslash", "keolxiejuslash-ask")
		end
	end
}

keolxiejuVS = sgs.CreateZeroCardViewAsSkill {
	name = "keolxieju",
	enabled_at_play = function(self, player)
		return not player:hasUsed("#keolxiejuCard")
	end,
	view_as = function()
		return keolxiejuCard:clone()
	end
}

keolxieju = sgs.CreateTriggerSkill {
	name = "keolxieju",
	view_as_skill = keolxiejuVS,
	events = { sgs.TargetConfirmed },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.TargetConfirmed) then
			local use = data:toCardUse()
			local wq = room:getCurrent()
			if wq:hasSkill(self:objectName()) and (not use.card:isKindOf("SkillCard")) then
				for _, p in sgs.qlist(use.to) do
					room:setPlayerMark(p, "keolxiejutar-Clear", 1)
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end
}
--keolwenqin:addSkill(keolxieju)
if not sgs.Sanguosha:getSkill("keolxieju") then skills:append(keolxieju) end

sgs.LoadTranslationTable {
	["keolwenqin"] = "OL文钦",
	["&keolwenqin"] = "文钦",
	["#keolwenqin"] = "困兽鸱张",
	["designer:keolwenqin"] = "官方",
	["cv:keolwenqin"] = "官方",
	["illustrator:keolwenqin"] = "官方",

	["keolguangao"] = "犷骜",
	[":keolguangao"] = "你使用【杀】的目标数限制+1；其他角色使用【杀】时，其可以令你成为此【杀】的额外目标；当一名角色使用【杀】时，若你是使用者或目标且你的手牌数为偶数，你摸一张牌，然后可以令此【杀】对任意名角色无效。",
	["keolguangao:keolguangao-ask"] = "你可以发动“犷骜”令 %src 成为此【杀】的额外目标",

	["keolhuiqi"] = "慧企",
	[":keolhuiqi"] = "觉醒技，一个回合结束时，若此回合成为过牌的目标的角色数为3且包括你，你回复1点体力并获得“偕举”。",

	["keolxieju"] = "偕举",
	[":keolxieju"] = "出牌阶段限一次，你可以令任意名本回合成为过牌的目标的角色依次选择是否将一张黑色牌当【杀】使用。",
	["keolxiejuslashCard"] = "偕举",
	["keolxiejuCard"] = "偕举",

	["keolguangaominus-ask"] = "你可以发动“犷骜”令此【杀】对任意名目标角色无效",
	["keolxiejuslash-ask"] = "偕举：你可以将一张黑色牌当【杀】使用",

	["$keolguangao1"] = "大丈夫行事，焉能畏首畏尾。",
	["$keolguangao2"] = "策马觅封侯，长驱万里之数。",
	["$keolhuiqi1"] = "今大星西垂，此天降清君侧之证。",
	["$keolhuiqi2"] = "彗星竟于西北，此罚天狼之兆。",
	["$keolxieju1"] = "今举大义，誓与仲恭共死。",
	["$keolxieju2"] = "天降大任，当与志士同忾。",

	["~keolwenqin"] = "天不佑国魏，天不佑族文！",
}

keoljielvmeng = sgs.General(extension, "keoljielvmeng", "wu", 4)

keolkeji = sgs.CreateTriggerSkill {
	name = "keolkeji",
	frequency = sgs.Skill_Frequent,
	events = { sgs.PreCardUsed, sgs.CardResponded, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseChanging) then
			local can_trigger = true
			if player:hasFlag("keolkejiSlashInPlayPhase") then
				can_trigger = false
				player:setFlags("-keolkejiSlashInPlayPhase")
			end
			local change = data:toPhaseChange()
			if change.to == sgs.Player_Discard and player:isAlive() and player:hasSkill(self:objectName()) then
				if can_trigger and player:askForSkillInvoke(self:objectName()) then
					room:broadcastSkillInvoke(self:objectName())
					player:skip(sgs.Player_Discard)
				end
			end
		else
			if player:getPhase() == sgs.Player_Play then
				local card = nil
				if event == sgs.PreCardUsed then
					card = data:toCardUse().card
				else
					card = data:toCardResponse().m_card
				end
				if card:isKindOf("Slash") then
					player:setFlags("keolkejiSlashInPlayPhase")
				end
			end
		end
	end,
	--[[can_trigger = function(self,target)
		return target ~= nil
	end]]
}
keoljielvmeng:addSkill(keolkeji)

keolqinxue = sgs.CreateTriggerSkill {
	name = "keolqinxue",
	frequency = sgs.Skill_Wake,
	events = { sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		if player:getMark(self:objectName()) > 0 then return end
		if player:getPhase() ~= sgs.Player_Start then return end
		local n = 2
		local room = player:getRoom()
		if player:getHandcardNum() - math.max(player:getHp(), 0) >= n then
			room:notifySkillInvoked(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			room:doSuperLightbox("keoljielvmeng", "keolqinxue")
			room:addPlayerMark(player, self:objectName())
			if room:changeMaxHpForAwakenSkill(player) then
				room:acquireSkill(player, "keolgongxin")
				room:broadcastSkillInvoke(self:objectName())
			end
		end
	end
}
keoljielvmeng:addSkill(keolqinxue)

keolgongxinCard = sgs.CreateSkillCard {
	name = "keolgongxinCard",
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and not to_select:isKongcheng()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local ids = sgs.IntList()
		for _, card in sgs.qlist(effect.to:getHandcards()) do
			if card:getSuit() == sgs.Card_Heart then
				ids:append(card:getEffectiveId())
			end
		end
		local card_id = room:doGongxin(effect.from, effect.to, ids)
		if (card_id == -1) then return end
		local result = room:askForChoice(effect.from, "keolgongxin", "discard+put")
		effect.from:removeTag("keolgongxin")
		if result == "discard" then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, effect.from:objectName(), nil,
				"keolgongxin", nil)
			room:throwCard(sgs.Sanguosha:getCard(card_id), reason, effect.to, effect.from)
		else
			effect.from:setFlags("Global_GongxinOperator")
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, effect.from:objectName(), nil,
				"keolgongxin", nil)
			room:moveCardTo(sgs.Sanguosha:getCard(card_id), effect.to, nil, sgs.Player_DrawPile, reason, true)
			effect.from:setFlags("-Global_GongxinOperator")
		end
	end
}
keolgongxin = sgs.CreateZeroCardViewAsSkill {
	name = "keolgongxin",
	view_as = function()
		return keolgongxinCard:clone()
	end,
	enabled_at_play = function(self, target)
		return not target:hasUsed("#keolgongxinCard")
	end
}
if not sgs.Sanguosha:getSkill("keolgongxin") then skills:append(keolgongxin) end

keolbotu = sgs.CreateTriggerSkill {
	name = "keolbotu",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.CardsMoveOneTime, sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) and player:hasSkill(self:objectName()) then
			local num = player:getMark("@keolspade") + player:getMark("@keolclub") + player:getMark("@keolheart") +
			player:getMark("@keoldiamond")
			room:setPlayerMark(player, "@keolspade", 0)
			room:setPlayerMark(player, "@keolclub", 0)
			room:setPlayerMark(player, "@keolheart", 0)
			room:setPlayerMark(player, "@keoldiamond", 0)
			if (num >= 4) and (player:getMark("keolbotuuse_lun") < math.min(room:getAlivePlayers():length(), 3)) then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:broadcastSkillInvoke(self:objectName())
					room:addPlayerMark(player, "keolbotuuse_lun")
					player:gainAnExtraTurn()
				end
			end
		end
		if (event == sgs.CardsMoveOneTime) then
			local move = data:toMoveOneTime()
			if (move.to_place == sgs.Player_DiscardPile)
				and player:hasSkill(self:objectName())
				and (player:getPhase() ~= sgs.Player_NotActive) then
				for _, card_id in sgs.qlist(move.card_ids) do
					if ((sgs.Sanguosha:getCard(card_id)):getSuit() == sgs.Card_Spade) then
						room:setPlayerMark(player, "@keolspade", 1)
					elseif ((sgs.Sanguosha:getCard(card_id)):getSuit() == sgs.Card_Club) then
						room:setPlayerMark(player, "@keolclub", 1)
					elseif ((sgs.Sanguosha:getCard(card_id)):getSuit() == sgs.Card_Heart) then
						room:setPlayerMark(player, "@keolheart", 1)
					elseif ((sgs.Sanguosha:getCard(card_id)):getSuit() == sgs.Card_Diamond) then
						room:setPlayerMark(player, "@keoldiamond", 1)
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
keoljielvmeng:addSkill(keolbotu)
keoljielvmeng:addRelateSkill("keolgongxin")

sgs.LoadTranslationTable {
	["keoljielvmeng"] = "OL界吕蒙-第二版",
	["&keoljielvmeng"] = "界吕蒙",
	["#keoljielvmeng"] = "士别三日",
	["designer:keoljielvmeng"] = "官方",
	["cv:keoljielvmeng"] = "官方",
	["illustrator:keoljielvmeng"] = "官方",

	["keolkeji"] = "克己",
	[":keolkeji"] = "若你没有于出牌阶段内使用或打出过【杀】，你可以跳过此回合的弃牌阶段。",

	["keolqinxue"] = "勤学",
	[":keolqinxue"] = "觉醒技，准备阶段或结束阶段，若你的手牌数比体力值多2或更多，你减1点体力上限，回复1点体力或摸两张牌，然后获得技能“攻心”。",

	["keolgongxin"] = "攻心",
	[":keolgongxin"] = "出牌阶段限一次，你可以观看一名其他角色的手牌，然后你可以展示其中的一张红桃牌并选择一项：1.弃置此牌；2.将此牌置于牌堆顶。",

	["keolbotu"] = "博图",
	[":keolbotu"] = "每轮限X次（X为场上角色数且至多为3），回合结束后，若本回合置入弃牌堆的牌包含四种花色，则你可以获得一个额外回合。",

	["$keolkeji1"] = "蓄力待时，不争首功。",
	["$keolkeji2"] = "最好的机会，还在等着我。",
	["$keolqinxue1"] = "兵书熟读，了然于胸。",
	["$keolqinxue2"] = "勤以修身，学以报国。",
	["$keolgongxin1"] = "洞若观火，运筹帷幄。",
	["$keolgongxin2"] = "哼，早知如此。",
	["$keolbotu1"] = "时机已到，全军出击！",
	["$keolbotu2"] = "今日起兵，渡江攻敌！",

	["~keoljielvmeng"] = "你，给我等着！",
}


keoljiehuaxiong = sgs.General(extension, "keoljiehuaxiong", "qun", 6)

keolyaowu = sgs.CreateTriggerSkill {
	name = "keolyaowu",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.Damaged },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged then
			local damage = data:toDamage()
			if (damage.card) then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				if damage.card:isRed() then
					damage.from:drawCards(1)
				else
					player:drawCards(1)
				end
			end
		end
	end,
}
keoljiehuaxiong:addSkill(keolyaowu)

keolshizhanCard = sgs.CreateSkillCard {
	name = "keolshizhanCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return (#targets < 1) and (to_select:objectName() ~= sgs.Self:objectName())
	end,
	on_use = function(self, room, player, targets)
		local target = targets[1]
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		duel:setSkillName("keolshizhan")
		local card_use = sgs.CardUseStruct()
		card_use.from = target
		card_use.to:append(player)
		card_use.card = duel
		room:useCard(card_use, false)
		duel:deleteLater()
	end
}
--主技能
keolshizhan = sgs.CreateViewAsSkill {
	name = "keolshizhan",
	n = 0,
	view_as = function(self, cards)
		return keolshizhanCard:clone()
	end,
	enabled_at_play = function(self, player)
		return (player:usedTimes("#keolshizhanCard") < 2)
	end,
}
keoljiehuaxiong:addSkill(keolshizhan)

sgs.LoadTranslationTable {
	["keoljiehuaxiong"] = "OL界华雄-第二版",
	["&keoljiehuaxiong"] = "界华雄",
	["#keoljiehuaxiong"] = "飞扬跋扈",
	["designer:keoljiehuaxiong"] = "官方",
	["cv:keoljiehuaxiong"] = "官方",
	["illustrator:keoljiehuaxiong"] = "官方",

	["keolyaowu"] = "耀武",
	[":keolyaowu"] = "锁定技，当你受到伤害时，若对你造成伤害的牌：为红色，伤害来源摸一张牌；不为红色，你摸一张牌。",

	["keolshizhan"] = "势斩",
	[":keolshizhan"] = "出牌阶段限两次，你可以令一名其他角色视为对你使用一张【决斗】。",

	["$keolyaowu1"] = "这些杂兵，我有何惧！",
	["$keolyaowu2"] = "有吾在此，解太师烦忧。",
	["$keolshizhan1"] = "看你能坚持几个回合！",
	["$keolshizhan2"] = "兀那汉子，且报上名来！",

	["~keoljiehuaxiong"] = "我掉以轻心了……",
}

keoltianchou = sgs.General(extension, "keoltianchou", "qun", 4)

keolshandaoCard = sgs.CreateSkillCard {
	name = "keolshandaoCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return (#targets < 99) and (not to_select:isNude())
	end,
	on_use = function(self, room, player, targets)
		local players = sgs.SPlayerList()
		local daomeidans = sgs.SPlayerList()
		for _, target in pairs(targets) do
			local id = room:askForCardChosen(player, target, "he", "keolshandao", false, sgs.Card_MethodDiscard)
			room:moveCardTo(sgs.Sanguosha:getCard(id), player, sgs.Player_DrawPile)
			players:append(target)
			room:setPlayerMark(target, "keolshandaowg", 1)
		end
		local wgfd = sgs.Sanguosha:cloneCard("amazing_grace", sgs.Card_NoSuit, 0)
		wgfd:setSkillName("keolshandao")
		local card_use = sgs.CardUseStruct()
		card_use.from = player
		card_use.to = players
		card_use.card = wgfd
		room:useCard(card_use, true)
		wgfd:deleteLater()
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if not players:contains(p) then
				daomeidans:append(p)
				room:setPlayerMark(p, "keolshandaowj", 1)
			end
		end
		if daomeidans:length() > 0 then
			local wjqf = sgs.Sanguosha:cloneCard("archery_attack", sgs.Card_NoSuit, 0)
			wjqf:setSkillName("keolshandao")
			local card_use = sgs.CardUseStruct()
			card_use.from = player
			card_use.to = daomeidans
			card_use.card = wjqf
			room:useCard(card_use, true)
			wjqf:deleteLater()
		end
		for _, p in sgs.qlist(room:getAllPlayers()) do
			room:setPlayerMark(p, "keolshandaowj", 0)
			room:setPlayerMark(p, "keolshandaowg", 0)
		end
	end
}
--主技能
keolshandao = sgs.CreateViewAsSkill {
	name = "keolshandao",
	n = 0,
	view_as = function(self, cards)
		return keolshandaoCard:clone()
	end,
	enabled_at_play = function(self, player)
		return (not player:hasUsed("#keolshandaoCard"))
	end,
}
keoltianchou:addSkill(keolshandao)

keolshandaoex = sgs.CreateProhibitSkill {
	name = "#keolshandaoex",
	is_prohibited = function(self, from, to, card)
		return to and card and (card:getSkillName() == "keolshandao") and
		(((to:getMark("keolshandaowj") == 0) and card:isKindOf("ArcheryAttack")) or ((to:getMark("keolshandaowg") == 0) and card:isKindOf("AmazingGrace")))
	end
}
--if not sgs.Sanguosha:getSkill("keqizhenqiaoexex") then skills:append(keqizhenqiaoexex) end
keoltianchou:addSkill(keolshandaoex)

--[[keolshandao = sgs.CreateTriggerSkill{
	name = "keolshandao",
	view_as_skill = keolshandaoVS,
	events = {sgs.PreCardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.PreCardUsed) then
			local use = data:toCardUse()
			if use.card:isKindOf("ArcheryAttack") and (use.card:getSkillName() == "keolshandao") then
				local wjmbs = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if (p:getMark("keolshandaowj") > 0) then
						wjmbs:append(p)
					end
				end
				use.to = wjmbs
				data:setValue(use)
			end
			if use.card:isKindOf("AmazingGrace") and (use.card:getSkillName() == "keolshandao") then
				local wgmbs = sgs.SPlayerList()
				for _, q in sgs.qlist(room:getAllPlayers()) do
					if (q:getMark("keolshandaowg") > 0) then
						wgmbs:append(q)
					end
				end
				use.to = wgmbs
				data:setValue(use)
			end
		end
	end ,
}
keoltianchou:addSkill(keolshandao)]]

sgs.LoadTranslationTable {
	["keoltianchou"] = "田畴",
	["&keoltianchou"] = "田畴",
	["#keoltianchou"] = "乱世族隐",
	["designer:keoltianchou"] = "官方",
	["cv:keoltianchou"] = "官方",
	["illustrator:keoltianchou"] = "官方",

	["keolshandao"] = "善刀",
	[":keolshandao"] = "出牌阶段限一次，你可以将任意名角色的各一张牌置于牌堆顶，若如此做，你视为对这些角色使用一张【五谷丰登】，然后视为对其余其他角色使用一张【万箭齐发】。",

	["$keolshandao1"] = "君子藏器，待天时而动。",
	["$keolshandao2"] = "善刀而藏之，可解充栋之牛。",

	["~keoltianchou"] = "吾罪大矣，何堪封侯之荣。",
}

--马休马铁
keolmaxiumatie = sgs.General(extension, "keolmaxiumatie", "qun", 4)

keolkenshangVS = sgs.CreateViewAsSkill {
	name = "keolkenshang",
	n = 999,
	view_filter = function(self, selected, to_select)
		return not sgs.Self:isJilei(to_select)
	end,
	view_as = function(self, cards)
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		for _, c in pairs(cards) do
			slash:addSubcard(c)
		end
		slash:setSkillName("keolkenshang")
		if (#cards >= 2) then
			return slash
		else
			return nil
		end
	end,
	enabled_at_play = function(self, player)
		return sgs.Slash_IsAvailable(player)
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "slash"
	end
}

keolkenshang = sgs.CreateTriggerSkill {
	name = "keolkenshang",
	view_as_skill = keolkenshangVS,
	events = { sgs.Damage, sgs.CardFinished },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardFinished) then
			local use = data:toCardUse()
			if (use.card:getSkillName() == "keolkenshang") then
				if (room:getTag("keolkenshangda"):toInt() < use.card:getSubcards():length()) then
					use.from:drawCards(1)
				end
				room:removeTag("keolkenshangda")
			end
		end
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			if (damage.card:getSkillName() == "keolkenshang") then
				if not room:getTag("keolkenshangda") then
					room:setTag("keolkenshangda", sgs.QVariant(1))
				else
					local num = room:getTag("keolkenshangda"):toInt() + 1
					room:setTag("keolkenshangda", sgs.QVariant(num))
				end
				--room:addPlayerMark(damage.from,"keolkenshangda",damage.damage)
			end
		end
	end,
	--[[can_trigger = function(self,target)
		return target
	end]]
}
keolmaxiumatie:addSkill("mashu")
keolmaxiumatie:addSkill(keolkenshang)

sgs.LoadTranslationTable {
	["keolmaxiumatie"] = "马休＆马铁",
	["&keolmaxiumatie"] = "马休＆马铁",
	["#keolmaxiumatie"] = "颉翥三秦",
	["designer:keolmaxiumatie"] = "官方",
	["cv:keolmaxiumatie"] = "官方",
	["illustrator:keolmaxiumatie"] = "官方",

	["keolkenshang"] = "垦伤",
	[":keolkenshang"] = "你可以将至少两张牌当【杀】使用，且此【杀】的目标数限制为这些牌的数量，此【杀】结算完毕后，若这些牌的数量大于此【杀】造成的伤害，你摸一张牌。",

	["$keolkenshang1"] = "择兵选将，一击而大白。",
	["$keolkenshang2"] = "纵横三辅，垦伤庸富！",

	["~keolmaxiumatie"] = "我兄弟，愿随父帅赴死。",
}

































sgs.LoadTranslationTable {
	["newgenerals"] = "新将",

	["tenyear_panshu"] = "潘淑-十周年",
	["&tenyear_panshu"] = "潘淑",
	["#tenyear_panshu"] = "神女",
	["illustrator:tenyear_panshu"] = "夏季与杨杨",
	["zhiren"] = "织纴",
	[":zhiren"] = "当你于回合内使用第一张非转化的牌时，根据此牌名称字数，你可以依次执行以下选项中的前X项（X为此牌名称字数）：1.观看牌堆顶X张牌并以任意顺序置于牌堆顶或牌堆底；2.依次弃置场上一张装备牌和一张延时类锦囊牌；3.回复1点体力；4和4+.摸三张牌。",
	["@zhiren-equip"] = "请弃置场上一张装备牌",
	["@zhiren-judge"] = "请弃置场上一张延时类锦囊牌",
	["zhiren_judge"] = "织纴",
	["yaner"] = "燕尔",
	[":yaner"] = "每个回合限一次，当其他角色于其出牌阶段内失去最后的手牌后，你可以与其各摸两张牌。若你摸的两张牌类型相同，“织纴”改为回合外也可发动直到你的下个回合开始；若该角色摸的两张牌类型相同，其回复1点体力。",
	[":&yaner"] = "回合外也可发动“织纴”",
	["$zhiren1"] = "穿针引线，栩栩如生",
	["$zhiren2"] = "纺绩织纴，布帛可成",
	["$yaner1"] = "如胶似漆，白首相随",
	["$yaner2"] = "新婚燕尔，亲睦和美",
	["~tenyear_panshu"] = "有喜必忧，以为深戒",

	["mobile_wenyang"] = "手杀文鸯",
	["&mobile_wenyang"] = "文鸯",
	["#mobile_wenyang"] = "独骑破军",
	["illustrator:mobile_wenyang"] = "官方",
	["quedi"] = "却敌",
	[":quedi"] = "每个回合限一次，当你使用【杀】或【决斗】指定唯一目标后，你可以选择一项：1.获得其一张手牌；2.弃置一张基本牌令此牌伤害+1；3.减1点体力上限，然后依次执行前两项。",
	["quedi:obtain"] = "获得%src一张手牌",
	["quedi:damage"] = "此牌伤害+1",
	["quedi:beishui"] = "减1点体力上限，依次执行前两项",
	["@quedi-basic"] = "请弃置一张基本牌",
	["mobilechoujue"] = "仇决",
	[":mobilechoujue"] = "锁定技，当你杀死一名其他角色时，你加1点体力上限，摸两张牌，本回合可额外发动一次“却敌”。",
	[":&mobilechoujue"] = "本回合你可以额外发动%src次“却敌”",
	["chuifeng"] = "棰锋",
	[":chuifeng"] = "魏势力技，出牌阶段限两次，你可以失去1点体力视为使用一张【决斗】，当你受到此牌造成的伤害时，你防止之且“棰锋”本回合失效。",
	["chongjian"] = "冲坚",
	[":chongjian"] = "吴势力技，你可以将一张装备牌当【酒】或任一种【杀】使用，此【杀】无距离限制且无视防具；以此法使用的【杀】造成伤害后，你获得目标装备区的X张牌（X为伤害值）。",

	["$chuifeng1"] = "率军冲锋，不惧刀枪所阻！",
	["$chuifeng2"] = "登锋履刃，何妨马革裹尸！",
	["$chongjian1"] = "尔等良将，于我不堪一击！",
	["$chongjian2"] = "此等残兵，破之何其易也！",
	["$quedi1"] = "力摧敌阵，如视天光破云！",
	["$quedi2"] = "让尔等有命追，无命回！",
	["$mobilechoujue1"] = "血海深仇，便在今日来报！",
	["$mobilechoujue2"] = "取汝之头，以祭先父！",
	["~mobile_wenyang"] = "半生功业，而见疑于一家之言，岂能无怨！",
	["ol_dengzhi"] = "OL邓芝",
	["&ol_dengzhi"] = "邓芝",
	["#ol_dengzhi"] = "坚贞简亮",
	["illustrator:ol_dengzhi"] = "",
	["xiuhao"] = "修好",
	[":xiuhao"] = "每个回合限一次，当你对其他角色造成伤害时或其他角色对你造成伤害时，你可防止此伤害，然后伤害来源摸两张牌。",
	["sujian"] = "素俭",
	[":sujian"] = "锁定技，弃牌阶段开始时，你选择一项：将所有非本回合获得的手牌分配给其他角色；或弃置非本回合获得的手牌，然后弃置一名其他角色至多等量的牌。然后结束此阶段。",
	["sujian:give"] = "分配非本回合获得的手牌",
	["sujian:discard"] = "弃置非本回合获得的手牌，然后弃置一名其他角色至多等量的牌",
	["@sujian-give"] = "请分配这些牌",
	["@sujian-discard"] = "请弃置一名其他角色的牌",
	["$xiuhao1"] = "吴蜀合同，可御魏敌",
	["$xiuhao2"] = "与吾修好，共为唇齿",
	["$sujian1"] = "不苟素俭，不治私产", --对的，就是这个治，不是置。原文：身之衣食资仰于官,不苟素俭,然终不治私产,妻子不免饥寒
	["$sujian2"] = "高风亮节，摆袖却金",
	["~ol_dengzhi"] = "修好未成，蜀汉恐危……",

	["ol_mazhong"] = "OL马忠",
	["&ol_mazhong"] = "马忠",
	["illustrator:ol_mazhong"] = "Thinking",
	["olfuman"] = "抚蛮",
	[":olfuman"] = "<font color=\"green\"><b>出牌阶段每名角色限一次，</b></font>你可以将一张手牌交给一名其他角色，此牌视为【杀】直到离开一名角色的手牌。当此【杀】结算完时，你摸一张牌；若此【杀】造成了伤害，改为摸两张牌。",
	["$olfuman1"] = "恩威并施，蛮夷可为我所用。",
	["$olfuman2"] = "发兵器啦！",

	["caoanmin"] = "曹安民",
	["#caoanmin"] = "履薄临深",
	["illustrator:caoanmin"] = "君桓文化",
	["xianwei"] = "险卫",
	[":xianwei"] = "锁定技，准备阶段，你废除一个装备栏并摸等同于你未废除装备栏数的牌，然后令一名其他角色使用牌堆中第一张对应副类别的装备牌（若牌堆中没有则改为摸一张牌）。当你废除所有装备栏后，你加两点体力上限，然后你视为在其他角色攻击范围内且其他角色视为在你攻击范围内。",
	["xianwei:0"] = "废除武器栏",
	["xianwei:1"] = "废除防具栏",
	["xianwei:2"] = "废除+1坐骑栏",
	["xianwei:3"] = "废除-1坐骑栏",
	["xianwei:4"] = "废除宝物栏",
	["@xianwei-use"] = "请选择使用装备牌的角色",
	["#XianweiEquipArea"] = "%from 失去了所有装备栏，“%arg”被触发",
	["$xianwei1"] = "曹家儿郎，何惧一死",
	["$xianwei2"] = "此役当战，有死无生",
	["~caoanmin"] = "伯父快走……",

	["qiaozhou"] = "谯周",
	["#qiaozhou"] = "观星知命",
	["illustrator:qiaozhou"] = "",
	["zhiming"] = "知命",
	[":zhiming"] = "准备阶段开始时与弃牌阶段结束时，你摸一张牌，然后你可以将一张牌置于牌堆顶。",
	["@zhiming-put"] = "你可以将一张牌置于牌堆顶",
	["xingbu"] = "星卜",
	[":xingbu"] = "结束阶段，你可以亮出牌堆顶的三张牌，根据其中红色牌的数量，令一名其他角色获得对应效果直到其回合结束：\
				三张：（五星连珠）摸牌阶段额外摸两张牌、出牌阶段可以额外使用一张【杀】、跳过弃牌阶段；\
				两张：（扶匡东柱）出牌阶段使用第一张牌结算完时，弃置一张牌然后摸两张牌；\
				不多于一张：（荧惑守心）出牌阶段可使用【杀】的次数-1。",
	["@xingbu-invoke"] = "请选择一名其他角色获得 %src 效果",
	["xbwuxinglianzhu"] = "五星连珠",
	[":&xbwuxinglianzhu"] = "摸牌阶段额外摸2*%src张牌、出牌阶段可以额外使用%src张【杀】、跳过弃牌阶段",
	["xbfukuangdongzhu"] = "扶匡东柱",
	[":&xbfukuangdongzhu"] = "出牌阶段使用第一张牌结算完时，弃置一张牌然后摸两张牌",
	["xbyinghuoshouxin"] = "荧惑守心",
	[":&xbyinghuoshouxin"] = "出牌阶段可使用【杀】的次数-%src",
	["xingbu_xbwuxinglianzhu"] = "星卜",
	["xingbu_xbfukuangdongzhu"] = "星卜",
	["xingbu_xbyinghuoshouxin"] = "星卜",

	["$zhiming1"] = "天定人命，仅可一窥。",
	["$zhiming2"] = "知命而行，尽诸人事。",
	["$xingbu1"] = "天现祥瑞，此乃大吉之兆。",
	["$xingbu2"] = "天象显异，北伐万不可期。",
	["~qiaozhou"] = "老夫死不足惜，但求蜀地百姓无虞！",

	["ol_qiaozhou"] = "OL谯周",
	["&ol_qiaozhou"] = "谯周",
	["#ol_qiaozhou"] = "观星知命",
	["illustrator:ol_qiaozhou"] = "",
	["olxingbu"] = "星卜",
	[":olxingbu"] = "结束阶段，你可以亮出牌堆顶的三张牌，根据其中红色牌的数量，令一名其他角色获得对应效果直到其回合结束：\
				三张：摸牌阶段额外摸两张牌，出牌阶段使用【杀】的次数+1；\
				两张：出牌阶段使用【杀】的次数-1，跳过弃牌阶段；\
				不多于一张：准备阶段开始时弃置一张手牌。",
	["@olxingbu-invoke"] = "请选择一名其他角色获得星卜效果（%src张红色牌）",
	["olxingbu3"] = "星卜",
	[":&olxingbu3"] = "摸牌阶段额外摸2*%src张牌，出牌阶段使用【杀】的次数+%src",
	["olxingbu2"] = "星卜",
	[":&olxingbu2"] = "出牌阶段使用【杀】的次数-%src，跳过弃牌阶段",
	["olxingbu1"] = "星卜",
	[":&olxingbu1"] = "准备阶段开始时弃置%src张手牌",

	["$olxingbu1"] = "天现祥瑞，此乃大吉之兆。",
	["$olxingbu2"] = "天象显异，北伐万不可期。",
	["~ol_qiaozhou"] = "老夫死不足惜，但求蜀地百姓无虞！",


	["ol_jiaxu"] = "OL界贾诩",
	["&ol_jiaxu"] = "界贾诩",
	["illustrator:ol_jiaxu"] = "",
	["cv:ol_jiaxu"] = "官方",
	["olwansha"] = "完杀",
	[":olwansha"] = "锁定技，你的回合内：只有你和处于濒死状态的角色才能使用【桃】；一名角色的濒死结算中，除你和濒死角色外的角色的非锁定技无效。",
	["olluanwu"] = "乱武",
	[":olluanwu"] = "限定技，出牌阶段，你可以令所有其他角色依次选择一项：1.对其距离最近的另一名角色使用一张【杀】；2.失去1点体力。然后，你可以视为使用一张无距离限制的【杀】。",
	["@olluanwu"] = "你可以视为使用一张无距离限制的【杀】",
	["olweimu"] = "帷幕",
	[":olweimu"] = "锁定技，你不能成为黑色锦囊牌的目标。当你于回合内受到伤害时，防止此伤害并摸两倍数量的牌。",
	["#OLWeimuPreventDamage"] = "%from 的“%arg”被触发，防止了 %arg2 点伤害",
	["olluanwu"] = "乱武",
	[":olluanwu"] = "限定技，出牌阶段，你可以令所有其他角色依次选择一项：1.对距离最近的另一名角色使用一张【杀】；2.失去1点体力。然后，你可以视为使用一张无距离限制的【杀】。",
	["@olluanwu"] = "你可以视为使用一张无距离限制的【杀】",
	["$olwansha1"] = "有谁敢试试？",
	["$olwansha2"] = "斩草务尽，以绝后患",
	["$olweimu1"] = "此伤与我无关",
	["$olweimu2"] = "还是另寻他法吧",
	["$olluanwu1"] = "",
	["$olluanwu2"] = "",
	["~ol_jiaxu"] = "此劫，我亦有所算",

	["ol_lusu"] = "OL界鲁肃",
	["&ol_lusu"] = "界鲁肃",
	["illustrator:ol_lusu"] = "",
	["cv:ol_lusu"] = "官方",
	["olhaoshi"] = "好施",
	[":olhaoshi"] = "摸牌阶段，你可以额外摸两张牌，然后若你的手牌数大于5，你将一半的手牌交给手牌最少的一名其他角色（向下取整），" ..
		"然后直到你的回合开始，当你成为【杀】或非延时类锦囊牌的目标后，其可交给你一张手牌。",
	["@olhaoshi-give"] = "你可以交给 %src 一张手牌",
	["oldimeng"] = "缔盟",
	[":oldimeng"] = "出牌阶段限一次，你可交换两名手牌数的差不大于你的牌数的其他角色的手牌，若如此做，出牌阶段结束时，你弃置X张牌（X为这两名角色手牌数的差）。",
	["$olhaoshi1"] = "仗义疏财，深得人心",
	["$olhaoshi2"] = "召聚少年，给其衣食",
	["$oldimeng1"] = "深知其奇，相与亲结",
	["$oldimeng2"] = "同盟之人，言归于好",
	["~ol_lusu"] = "一生为国，纵死无憾",

	["second_liuqi"] = "刘琦-第二版",
	["&second_liuqi"] = "刘琦",
	["illustrator:second_liuqi"] = "NOVART",
	["secondwenji"] = "问计",
	[":secondwenji"] = "出牌阶段开始时，你可以令一名其他角色交给你一张牌。你于本回合内使用与该牌同类型的牌不能被其他角色响应。",
	["secondtunjiang"] = "屯江",
	[":secondtunjiang"] = "结束阶段，若你未于本回合的出牌阶段内使用牌指定过其他角色为目标，你可以摸X张牌（X为全场势力数）。",
	["$secondwenji1"] = "还望先生救我！",
	["$secondwenji2"] = "言出子口，入于吾耳，可以言未？",
	["$secondtunjiang1"] = "江夏冲要之地，孩儿愿往守之。",
	["$secondtunjiang2"] = "皇叔勿惊，吾与关将军已到。",

	["second_tangji"] = "唐姬-第二版",
	["&second_tangji"] = "唐姬",
	["illustrator:second_tangji"] = "",
	["secondkangge"] = "抗歌",
	[":secondkangge"] = "你的第一个回合开始时，选择一名其他角色。该角色于其回合外获得手牌后，你摸等量的牌（每回合最多摸三张）。" ..
		"每轮限一次，该角色进入濒死状态时，你可令其回复体力至1点。该角色死亡时，你弃置所有牌并失去1点体力。",
	["secondjielie"] = "节烈",
	[":secondjielie"] = "当你受到除自己和“抗歌”角色以外的角色造成的伤害时，你可以防止此伤害并选择一种花色，然后你失去X点体力，令“抗歌”角色从弃牌堆中随机获得X张此花色的牌（X为伤害值）。",
	["secondjielie:secondjielie"] = "你是否发动“节烈”防止%src点伤害？",
	["$secondkangge1"] = "慷慨悲歌，以抗凶逆",
	["$secondkangge2"] = "忧惶昼夜，抗之以歌",
	["$secondjielie1"] = "节烈之妇，从一而终也",
	["$secondjielie2"] = "清闲贞静，守节整齐",

	["dufuren"] = "杜夫人",
	["#dufuren"] = "沛王太妃",
	["illustrator:dufuren"] = "匠人绘",
	["yise"] = "异色",
	[":yise"] = "其他角色获得你的牌后，若其中包含：红色牌，你可令其回复1点体力；黑色牌，其下次受到【杀】的伤害时，此伤害+1。",
	[":&yise"] = "下次受到【杀】的伤害时，此伤害+%src",
	["shunshi"] = "顺世",
	[":shunshi"] = "准备阶段开始时或当你于回合外受到伤害后，你可交给除伤害来源外的一名其他角色一张牌。若如此做，你获得以下效果：下个摸牌阶段摸牌数+1、下个出牌阶段使用【杀】次数+1、下个弃牌阶段手牌上限+1。",
	["@shunshi-give"] = "你可交给一名其他角色一张牌",
	[":&shunshi"] = "下个摸牌阶段摸牌数+1、下个出牌阶段使用【杀】次数+1、下个弃牌阶段手牌上限+1",
	["$yise1"] = "明丽端庄，双瞳剪水",
	["$yise2"] = "姿色天然，貌若桃李",
	["$shunshi1"] = "顺应时运，得保安康",
	["$shunshi2"] = "随遇而安，宠辱不惊",
	["~dufuren"] = "往事云烟，去日苦多",

	["ol_wangrong"] = "OL王荣",
	["&ol_wangrong"] = "王荣",
	["illustrator:ol_wangrong"] = "",
	["fengzi"] = "丰姿",
	[":fengzi"] = "出牌阶段限一次，你使用基本牌或非延时类锦囊牌时，可以弃置一张同类型的手牌，令此牌的效果结算两次。",
	["@fengzi-discard"] = "你可以弃置一张 %src 令 %arg 结算两次",
	["jizhanw"] = "吉占",
	[":jizhanw"] = "摸牌阶段开始时，你可以放弃摸牌，展示牌堆顶的一张牌，猜测牌堆顶的下一张牌点数大于或小于此牌，然后展示之，若猜对你可重复此流程，最后你获得以此法展示的牌。",
	["jizhanw:more"] = "点数大于%src",
	["jizhanw:less"] = "点数小于%src",
	["fusong"] = "赋颂",
	[":fusong"] = "当你死亡时，你可令一名体力上限大于你的角色选择获得“丰姿”或“吉占”。",
	["@fusong-invoke"] = "你可以发动“赋颂”",
	["$fengzi1"] = "丰姿秀丽，礼法不失",
	["$fengzi2"] = "倩影姿态，悄然入心",
	["$jizhanw1"] = "得吉占之兆，言福运之气",
	["$jizhanw2"] = "吉占逢时，化险为夷",
	["$fusong1"] = "陛下垂爱，妾身方有此位",
	["$fusong2"] = "长情颂，君王恩",
	["~ol_wangrong"] = "只求吾儿一生平安",

	["yuanhuan"] = "袁涣",
	["#yuanhuan"] = "随车致雨",
	["illustrator:yuanhuan"] = "",
	["qingjue"] = "请决",
	[":qingjue"] = "每轮限一次，当其他角色使用牌指定一名体力值小于其且不处于濒死状态的角色为目标时，若目标唯一且不为你，你可以摸一张牌，然后与其拼点。若你：赢，取消之；没赢，你将此牌转移给你。",
	["fengjie"] = "奉节",
	[":fengjie"] = "锁定技，准备阶段，你选择一名其他角色。直到你下回合开始，每名角色的结束阶段，若其存活，你将手牌数摸至或弃置至与其体力值相同（至多为4）。",
	["@fengjie-invoke"] = "请选择一名其他角色",

	["$qingjue3"] = "鼓之以道德，征之以仁义，才可得百姓之心。",
	["$qingjue1"] = "兵者，凶器也，宜不得已而用之。",
	["$qingjue2"] = "民安土重迁，易以顺行，难以逆动。",
	["$fengjie1"] = "见贤思齐，内自省也。",
	["$fengjie2"] = "立本于道，置身于正。",
	["~yuanhuan"] = "乱世之中，有礼无用啊……",

	["zongyu"] = "宗预",
	["#zongyu"] = "御严无惧",
	["illustrator:zongyu"] = "",
	["zhibian"] = "直辩",
	[":zhibian"] = "准备阶段，你可以与一名其他角色拼点。若你赢，你可以选择一项：将其场上的一张牌移到你的对应区域；2.回复1点体力；3.跳过下个摸牌阶段，然后依次执行前两项。若你没赢，你失去1点体力。",
	["@zhibian-invoke"] = "你可以与一名其他角色拼点",
	["zhibian:move"] = "移动%src场上的牌",
	["zhibian:recover"] = "回复1点体力",
	["zhibian:beishui"] = "跳过下个摸牌阶段，然后依次执行前两项",
	["yuyanzy"] = "御严",
	[":yuyanzy"] = "锁定技，当你成为体力值大于你的角色使用的非转化的【杀】的目标时，其选择一项：交给你一张点数大于此【杀】的牌；或取消之。",
	["@yuyanzy-give"] = "请交给 %src 一张点数大于 %arg 的牌",
	["$zhibian1"] = "两国各增守将，皆事势宜然，何足相问。",
	["$zhibian2"] = "固边大计，乃立国之本，岂有不设之理。",
	["$yuyanzy1"] = "正直敢言，不惧圣怒。",
	["$yuyanzy2"] = "威武不能屈，方为大丈夫。",
	["~zongyu"] = "此次出使，终不负陛下期望。",

	["mobile_chenwudongxi"] = "陈武＆董袭",
	["&mobile_chenwudongxi"] = "陈武董袭",
	["#mobile_chenwudongxi"] = "陨身不恤",
	["illustrator:mobile_chenwudongxi"] = "",
	["yilie"] = "毅烈",
	[":yilie"] = "出牌阶段开始时，你可以选择一项：1.此阶段内，你可以额外使用一张【杀】；2.此阶段内，当你使用的【杀】被【闪】抵消时，你摸一张牌；3.失去1点体力，然后依次执行前两项。",
	["yilie:slash"] = "此阶段内可以额外使用一张【杀】",
	["yilie:draw"] = "此阶段内使用的【杀】被【闪】抵消时，摸一张牌",
	["yilie:beishui"] = "失去1点体力，依次执行前两项",
	["mobilefenming"] = "奋命",
	[":mobilefenming"] = "出牌阶段限一次，你可以横置一名体力值不大于你的角色，若其已横置，改为获得其一张牌。",
	["$yilie1"] = "哈哈哈哈！来吧！	",
	["$yilie2"] = "哼！都来受死！",
	["$mobilefenming1"] = "合肥一役，吾等必拼死效力！",
	["$mobilefenming2"] = "主公勿忧，待吾等上前一战！",
	["~mobile_chenwudongxi"] = "陛下速退！",

	["nanhualaoxian"] = "南华老仙",
	["#nanhualaoxian"] = "仙人指路",
	["illustrator:nanhualaoxian"] = "君桓文化",
	["gongxiu"] = "共修",
	[":gongxiu"] = "回合结束时，若你本回合发动过“经合”，你可以选择一项：1.所有在本回合通过“经合”获得过技能的角色摸一张牌；2.所有在本回合未通过“经合”获得过技能的其他角色弃置一张手牌。",
	["gongxiu:draw"] = "所有在本回合通过“经合”获得过技能的角色摸一张牌",
	["gongxiu:discard"] = "所有在本回合未通过“经合”获得过技能的其他角色弃置一张手牌",
	["jinghe"] = "经合",
	[":jinghe"] = "每回合限一次，出牌阶段，你可以展示至多四张牌名各不相同的手牌，并选择等量的角色，然后每名角色可以从“写满技能的天书”中选择并获得一个技能直到你的下回合开始。",
	["nhyinbing"] = "阴兵",
	[":nhyinbing"] = "锁定技，你造成的【杀】的伤害改为失去体力。其他角色失去体力后，你摸一张牌。",
	["nhhuoqi"] = "活气",
	[":nhhuoqi"] = "出牌阶段限一次，你可以弃置一张牌，然后令体力值最少的一名角色回复1点体力并摸一张牌。",
	["nhguizhu"] = "鬼助",
	[":nhguizhu"] = "每个回合限一次，一名角色进入濒死状态时，你可以摸两张牌。",
	["nhxianshou"] = "仙授",
	[":nhxianshou"] = "出牌阶段限一次，你可以令一名角色摸一张牌，若其体力值满，改为摸两张牌。",
	["nhlundao"] = "论道",
	[":nhlundao"] = "当你受到伤害后，若伤害来源手牌比你多，你可以弃置其一张牌；若伤害来源手牌比你少，你摸一张牌。",
	["nhguanyue"] = "观月",
	[":nhguanyue"] = "结束阶段，你可以观看牌堆顶两张牌，然后获得其中一张牌并将另一张牌置于牌堆顶。",
	["nhyanzheng"] = "言政",
	[":nhyanzheng"] = "准备阶段，若你的手牌数大于1，你可以保留一张手牌并弃置其余牌，然后选择至多等于弃牌数量的角色，对这些角色各造成1点伤害。",
	["@nhyanzheng-keep"] = "你可以发动“言政”保留一张手牌并弃置其余牌",
	["@nhyanzheng"] = "请对至多 %src 名角色各造成1点伤害",
	["$gongxiu1"] = "福祸与共，业山可移",
	["$gongxiu2"] = "修行退智，遂之道也",
	["$jinghe1"] = "大哉乾元，万物资始",
	["$jinghe2"] = "无极之外，复无无极",
	["~nanhualaoxian"] = "道亦有穷时",

	["nos_jin_yangzhi"] = "杨芷-旧",
	["&nos_jin_yangzhi"] = "杨芷",
	["#nos_jin_yangzhi"] = "武悼皇后",
	["illustrator:nos_jin_yangzhi"] = "",
	["nosjinwanyi"] = "婉嫕",
	[":nosjinwanyi"] = "出牌阶段，你可将一张带有强化效果的手牌当【逐近弃远】或【出其不意】或【水淹七军】或【洞烛先机】使用（每种牌名每回合限一次）。",
	["$nosjinwanyi1"] = "天性婉嫕，易以道御。",
	["$nosjinwanyi2"] = "婉嫕利珍，为后攸行。",
	["~nos_jin_yangzhi"] = "贾氏……构陷……",

	["nos_jin_yangyan"] = "杨艳-旧",
	["&nos_jin_yangyan"] = "杨艳",
	["#nos_jin_yangyan"] = "武元皇后",
	["illustrator:nos_jin_yangyan"] = "",
	["nosjinxuanbei"] = "选备",
	[":nosjinxuanbei"] = "游戏开始时，你获得牌堆中两张带强化效果的牌。每个回合限一次，你使用带强化效果的牌后，你可将其交给一名其他角色。",
	["@nosjinxuanbei-invoke"] = "你可以将 %src 交给一名其他角色",
	["$nosjinxuanbei1"] = "博选良家，以充后宫。",
	["$nosjinxuanbei2"] = "非良家，不可选也。",
	["~nos_jin_yangyan"] = "一旦殂损，痛悼伤怀……",

	["jin_zuofen"] = "左棻",
	["#jin_zuofen"] = "无宠的才女",
	["illustrator:jin_zuofen"] = "",
	["jinzhaosong"] = "诏颂",
	[":jinzhaosong"] = "其他角色的摸牌阶段结束时，若其没有标记，你可令其正面向上交给你一张手牌，然后根据此牌的类型，令该角色获得对应的标记：锦囊牌，“诔”标记；装备牌，“赋”标记；" ..
		"基本牌，“颂”标记。拥有标记的角色：进入濒死时，可弃置“诔”，回复至1体力，摸1张牌并减少1点体力上限；出牌阶段开始时，可弃置“赋”，弃置一名角色区域内的一张牌，" ..
		"然后可令其摸一张牌；使用仅指定一个目标的【杀】时，可弃置“颂”为此【杀】额外选择至多两个目标，然后若此【杀】造成的伤害小于2，其失去1点体力。",
	["jzslei"] = "诔",
	["jzsfu"] = "赋",
	["jzssong"] = "颂",
	["@jinzhaosong-give"] = "请交给 %src 一张手牌",
	["jinzhaosong_lei:recover"] = "你是否弃置“诔”，回复至1体力？",
	["jinzhaosong_fu:draw"] = "你是否令其摸一张牌？",
	["@jinzhaosong"] = "你可弃置“颂”为此【杀】额外选择至多两个目标",
	["jinlisi"] = "离思",
	[":jinlisi"] = "当你于回合外使用的牌置入弃牌堆后，你可将其交给一名手牌数不大于你的其他角色。",
	["@jinlisi-give"] = "你可以将这些牌交给一名手牌数不大于你的其他角色",
	["$jinzhaosong1"] = "领诏者，可上而颂之。",
	["$jinzhaosong2"] = "今为诏，以上告下也。",
	["$jinlisi1"] = "骨肉至亲，化为他人。",
	["$jinlisi2"] = "梦想魂归，见所思兮。",
	["~jin_zuofen"] = "惨怆愁悲……",

	["shenguojia"] = "神郭嘉",
	["#shenguojia"] = "星月奇佐",
	["illustrator:shenguojia"] = "木美人",
	["huishi"] = "慧识",
	[":huishi"] = "出牌阶段限一次，若你的体力上限小于10，你可以进行一次判定，若判定结果与此阶段内以此法进行判定的判定结果花色均不同，且你的体力上限小于10，你可以重复此判定并加1点体力上限。" ..
		"然后你可将所有判定牌交给一名角色，然后若其手牌数为全场最多，你减1点体力上限。",
	["@huishi-give"] = "你可将这些牌交给一名角色",
	["godtianyi"] = "天翊",
	[":godtianyi"] = "觉醒技，准备阶段，若所有存活角色均受到过伤害，你加2点体力上限，回复1点体力，然后令一名角色获得“佐幸”。",
	["@godtianyi-invoke"] = "请令一名角色获得“佐幸”",
	["huishii"] = "辉逝",
	[":huishii"] = "限定技，出牌阶段，你可以选择一名角色：若其有未触发的觉醒技且你的体力上限不小于存活角色数，你选择其中一个觉醒技，该技能视为满足觉醒条件；否则其摸四张牌。若如此做，你减2点体力上限。",
	["zuoxing"] = "佐幸",
	[":zuoxing"] = "准备阶段，若神郭嘉存活且体力上限大于1，你可令神郭嘉减1点体力上限。若如此做，本回合的出牌阶段限一次，你可视为使用一张非延时类锦囊牌。",
	["@zuoxing-invoke"] = "你可令神郭嘉减1点体力上限",
	["$huishi1"] = "聪以知远，明以察微",
	["$huishi2"] = "见微知著，识人心志",
	["$godtianyi1"] = "天命靡常，惟德是辅",
	["$godtianyi2"] = "可成吾志者，必此人也",
	["$huishii1"] = "丧家之犬，主公实不足虑也",
	["$huishii2"] = "时势兼备，主公复有何忧？",
	["$zuoxing1"] = "以聪虑难,悉咨于上",
	["$zuoxing2"] = "奉孝不才，愿献琴心",
	--身计国谋，不可两遂
	["~shenguojia"] = "可叹桢干命也迂",

	["shentaishici"] = "神太史慈",
	["#shentaishici"] = "义信天武",
	["illustrator:shentaishici"] = "",
	["dulie"] = "笃烈",
	[":dulie"] = "锁定技，游戏开始时，所有其他角色获得一枚“围”标记。你对没有“围”标记的角色使用【杀】无距离限制。当你成为没有“围”标记的角色使用的【杀】的目标时，你进行一次判定，若判定结果为红桃，此【杀】对你无效。",
	["stscdlwei"] = "围",
	["powei"] = "破围",
	[":powei"] = "使命技，当你使用的【杀】对有“围”标记的角色造成伤害时，该角色弃置一枚“围”标记，然后防止此伤害。\
			<font color=\"red\"><b>成功：</b></font>当你使用的【杀】结算完时，若没有角色有“围”标记，你获得技能“神著”。\
			<font color=\"blue\"><b>失败：</b></font>当你进入濒死时，你将体力回复至1点，然后弃置装备区内所有牌。",
	["dangmo"] = "荡魔",
	[":dangmo"] = "你于出牌阶段使用的第一张【杀】可以额外选择X名角色为目标（X为你的体力值-1）。",
	["@dangmo"] = "你可以为【%src】选择至多%arg名额外目标",
	["shenzhuo"] = "神著",
	[":shenzhuo"] = "你使用的非转化的【杀】结算完时，摸一张牌。你使用【杀】无次数限制。",
	["$dulie1"] = "素来言出必践，成吾信义昭彰",
	["$dulie2"] = "小信如若不成，大信将以何立？",
	["$powei1"] = "君且城中等候，待吾探敌虚实", --普通效果
	["$powei2"] = "弓马骑射洒热血，突破重围显英豪", --成功
	["$powei3"] = "敌军尚犹严防，有待明日再看", --失败
	["$dangmo1"] = "魔高一尺，道高一丈",
	["$dangmo2"] = "天魔祸世，吾自荡而除之",
	["$shenzhuo1"] = "力引强弓百斤，矢出贯手著棼",
	["$shenzhuo2"] = "箭既已在弦上，吾又岂能不发？",
	["~shentaishici"] = "魂归……天地……",

	["shensunce"] = "神孙策",
	["#shensunce"] = "踞江鬼雄",
	["illustrator:shensunce"] = "",
	["yingba"] = "英霸",
	[":yingba"] = "出牌阶段限一次，你可以令一名体力上限大于1的其他角色减1点体力上限并获得一枚“平定”标记，然后你减1点体力上限。你对拥有“平定”标记的角色使用牌无距离限制。",
	["sscybpingding"] = "平定",
	["fuhaisc"] = "覆海",
	[":fuhaisc"] = "锁定技，当你使用牌时，拥有“平定”标记的角色不能响应此牌。当你使用牌指定目标时，若目标中包含拥有“平定”标记的角色，且本回合你以此法获得的牌数小于2，你摸一张牌。一名其他角色死亡时，你加X点体力上限并摸X张牌（X为其“平定”标记数）。",
	["pinghe"] = "冯河",
	[":pinghe"] = "锁定技，你的手牌上限等于你已损失的体力值。当你受到其他角色的伤害时，若你有手牌且体力上限大于1，防止此伤害，然后你减1点体力上限并交给一名其他角色一张手牌，然后若你拥有“英霸”，伤害来源获得一枚“平定”标记。",

	["shenxunyu"] = "神荀彧",
	["#shenxunyu"] = "洞心先识",
	["illustrator:shenxunyu"] = "",
	["tianzuo"] = "天佐",
	[":tianzuo"] = "锁定技，游戏开始时，你将八张【奇正相生】洗入牌堆。【奇正相生】对你无效。",
	["lingce"] = "灵策",
	[":lingce"] = "锁定技，当一名角色使用非转化的锦囊牌时，若此牌是【无中生有】、【过河拆桥】、【无懈可击】、【奇正相生】或已被你的“定汉”记录，你摸一张牌。",
	["dinghan"] = "定汉",
	[":dinghan"] = "每种牌名限一次，当你成为锦囊牌的目标时，你记录此牌名，然后此牌对你无效。回合开始时，你可以在你的“定汉”的记录中增加或移除一个锦囊牌的牌名。",
	[":dinghan1"] = "每种牌名限一次，当你成为锦囊牌的目标时，你记录此牌名，然后此牌对你无效。回合开始时，你可以在你的“定汉”的记录中增加或移除一个锦囊牌的牌名。",
	[":dinghan11"] = "每种牌名限一次，当你成为锦囊牌的目标时，你记录此牌名，然后此牌对你无效。回合开始时，你可以在你的“定汉”的记录中增加或移除一个锦囊牌的牌名。\
				<font color=\"red\"><b>已记录：%arg11</b></font>",
	["#DingHanRemove"] = "%from 在“%arg”的记录中移除了【%arg2】",
	["#DingHanAdd"] = "%from 在“%arg”的记录中增加了【%arg2】",
	["dinghan:add"] = "增加一个记录",
	["dinghan:remove"] = "移除一个记录",
	["dinghan:tip"] = "变暗的卡牌是未记录的，其余的是已记录的",
	["$tianzuo1"] = "此时进之多弊，守之多利，愿主公熟虑",
	["$tianzuo2"] = "主公若不时定，待四方生心，则无及矣",
	["$lingce1"] = "绍士卒虽众，其实难用，必无为也",
	["$lingce2"] = "袁军不过一盘沙砾，主公用奇则散",
	["$dinghan2"] = "益国之事，虽死弗避",
	["$dinghan1"] = "杀身有地，报国有时",
	["~shenxunyu"] = "宁鸣而死，不默而生",

	["tenyear_new_sp_jiaxu"] = "新sp贾诩-十周年",
	["#tenyear_new_sp_jiaxu"] = "料事如神",
	["&tenyear_new_sp_jiaxu"] = "贾诩",
	["illustrator:tenyear_new_sp_jiaxu"] = "凝聚永恒",
	["cv:tenyear_new_sp_jiaxu"] = "官方",
	["tenyearjianshu"] = "间书",
	[":tenyearjianshu"] = "出牌阶段限一次，你可以将一张黑色手牌交给一名其他角色，然后选择另一名其他角色，令这两名角色拼点：赢的角色随机弃置一张牌，没赢的角色失去1点体力。若有角色因此死亡，此技能视为未发动过。",
	["@tenyearjianshu-pindian"] = "请选择 %src 拼点的目标",
	["#TenyearJianshuShow"] = "%from 展示了不能弃置的手牌",
	["tenyearyongdi"] = "拥嫡",
	[":tenyearyongdi"] = "限定技，出牌阶段，你可选择一名男性角色，若其体力值或体力上限全场最少，其回复1点体力或加1点体力上限；若其手牌数全场最少，其摸体力上限张牌（最多摸五张）。",
	["tenyearyongdi:recover"] = "回复1点体力",
	["tenyearyongdi:maxhp"] = "加1点体力上限",
	["$tenyearjianshu1"] = "来，让我看一出好戏吧。",
	["$tenyearjianshu2"] = "纵有千军万马，离心则难成大事。",
	["$tenyearyongdi1"] = "臣愿为世子，肝脑涂地。",
	["$tenyearyongdi2"] = "嫡庶有别，尊卑有序。",
	["~tenyear_new_sp_jiaxu"] = "立嫡之事，真是取祸之道！",

}

for _, sk in ipairs({ nhyinbing, nhhuoqi, nhguizhu, nhxianshou, nhlundao, nhguanyue, nhyanzheng, zuoxing, shenzhuo, shenzhuoSlash }) do
	if not sgs.Sanguosha:getSkill(sk:objectName()) then
		skills:append(sk)
	end
end
sgs.Sanguosha:addSkills(skills)

return packages
