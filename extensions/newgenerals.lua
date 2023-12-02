extension = sgs.Package("newgenerals", sgs.Package_GeneralPack)
local packages = {}
table.insert(packages, extension)

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
	return #targets == 0 and to_select:objectName() ~= player:objectName() and not player:isProhibited(to_select, self)
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
	local choice = room:askForChoice(from, "_qizhengxiangsheng", "zhengbing=" .. to:objectName() .. "+qibing=" .. to:objectName(), data)
	
	local log = sgs.LogMessage()
	log.type = "#QizhengxiangshengLog"
	log.from = from
	log.to:append(to)
	log.arg = "_qizhengxiangsheng_" .. choice:split("=")[1]
	room:sendLog(log, from)
	
	local card = nil
	if not effect.no_respond then
		data:setValue(effect)
		card = room:askForCard(to, "Slash,Jink", "@_qizhengxiangsheng-card:", data, sgs.Card_MethodResponse, from, false, "", false, self)
	end
	
	if choice:startsWith("zhengbing") then
		room:sendLog(log, room:getOtherPlayers(from,true))
		if not(card and card:isKindOf("Jink")) then
			if from:isDead() or to:isNude() then return end
			local id = room:askForCardChosen(from, to, "he", self:objectName())
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, from:objectName())
			room:obtainCard(from, sgs.Sanguosha:getCard(id), reason, false)
		end
	elseif choice:startsWith("qibing") then
		room:sendLog(log, room:getOtherPlayers(from,true))
		if not(card and card:isKindOf("Slash")) then
			room:damage(sgs.DamageStruct(self, from, to))
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
["@_qizhengxiangsheng-card"] = "奇正相生：你可以打出一张【杀】或【闪】",
["#QizhengxiangshengLog"] = "%from 为 %to 选择了“%arg”",
["_qizhengxiangsheng_zhengbing"] = "正兵",
["_qizhengxiangsheng_qibing"] = "奇兵",
["_qizhengxiangsheng_:slash"] = "打出一张【杀】",
["_qizhengxiangsheng_:jink"] = "打出一张【闪】",
}

--武将

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
events = {sgs.CardUsed, sgs.CardResponded},
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
		local tmp = string.byte(str, currentIndex)
		currentIndex  = currentIndex + chsize(tmp)
		length = length + 1
	end
	return length
end

zhiren = sgs.CreateTriggerSkill {
name = "zhiren",
events = {sgs.CardUsed, sgs.CardResponded},
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
			for _,p in sgs.qlist(room:getAlivePlayers()) do
				if player:canDiscard(p, "e") then
					targets:append(p)
				end
			end
			if not targets:isEmpty() then
				local to = room:askForPlayerChosen(player, targets, self:objectName(), "@zhiren-equip")
				room:doAnimate(1, player:objectName(), to:objectName())
				if player:canDiscard(to, "e") then
					local id = room:askForCardChosen(player, to, "e", self:objectName(), false, sgs.Card_MethodDiscard)
					room:throwCard(id, to, player)
				end
			end
			
			if player:isDead() then return false end
			targets = sgs.SPlayerList()
			for _,p in sgs.qlist(room:getAlivePlayers()) do
				if player:canDiscard(p, "j") then
					targets:append(p)
				end
			end
			if not targets:isEmpty() then
				local to = room:askForPlayerChosen(player, targets, "zhiren_judge", "@zhiren-judge")
				room:doAnimate(1, player:objectName(), to:objectName())
				if player:canDiscard(to, "j") then
					local id = room:askForCardChosen(player, to, "j", self:objectName(), false, sgs.Card_MethodDiscard)
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
		not move.from_places:contains(sgs.Player_PlaceHand) or move.from:isDead() then return false end
	
	local from = room:findPlayerByObjectName(move.from:objectName())
	if not from or from:isDead() then return false end
	
	for _,p in sgs.qlist(room:getOtherPlayers(from)) do
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
	for _,c in sgs.qlist(player:getHandcards()) do
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
	if damage.card and (damage.card:isKindOf("Slash") or damage.card:isKindOf("Duel"))
	and damage.card:hasFlag("quediDamage") then 
		damage.damage = damage.damage + 1
		data:setValue(damage)
	end
	return false
end
}

mobilechoujue = sgs.CreateTriggerSkill{
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
	for _,p in ipairs(targets) do
		qtargets:append(p)
	end
	if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
		local card, user_string = nil, self:getUserString()
        if user_string ~= "" then
            card = sgs.Sanguosha:cloneCard(user_string:split("+")[1])
			card:setSkillName("_chuifeng")
		end
        return card and card:targetFilter(qtargets, to_select, player) and not player:isProhibited(to_select, card, qtargets)
    end

    local card = player:getTag("chuifeng"):toCard()
    return card and card:targetFilter(qtargets, to_select, player) and not player:isProhibited(to_select, card, qtargets)
end,
feasible = function(self, targets, player)
	local card = player:getTag("chuifeng"):toCard()
	if card then
		card:setSkillName("_chuifeng")
	end
	local qtargets = sgs.PlayerList()
	for _,p in ipairs(targets) do
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
    use_card:setSkillName("_chuifeng")
    use_card:deleteLater()
    return use_card
end
}

chuifeng = sgs.CreateZeroCardViewAsSkill{
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
	return player:getKingdom() == "wei"
end,
enabled_at_response = function(self, player, pattern)
	if player:getKingdom() ~= "wei" then return false end
	if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then return false end
	return string.find(pattern, "slash") or string.find(pattern, "Slash") or string.find(pattern, "Duel")
end
}

chuifeng:setJuguanDialog("all_slashs,duel")

chongjianCard = sgs.CreateSkillCard {
name = "chongjian",
handling_method = sgs.Card_MethodUse,
filter = function(self, targets, to_select, player)
	local qtargets = sgs.PlayerList()
	for _,p in ipairs(targets) do
		qtargets:append(p)
	end
	if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
		local card, user_string = nil, self:getUserString()
        if user_string ~= "" then
            card = sgs.Sanguosha:cloneCard(user_string:split("+")[1])
			card:addSubcard(self)
			card:setSkillName("_chongjian")
		end
        return card and card:targetFilter(qtargets, to_select, player) and not player:isProhibited(to_select, card, qtargets)
    end

    local card = player:getTag("chongjian"):toCard()
	card:addSubcard(self)
	card:setSkillName("_chongjian")
	if card and card:targetFixed() then
		return card:isAvailable(player)
	end
    return card and card:targetFilter(qtargets, to_select, player) and not player:isProhibited(to_select, card, qtargets)
end,
feasible = function(self, targets, player)
	local card = player:getTag("chongjian"):toCard()
	if card then
		card:setSkillName("_chongjian")
		card:addSubcard(self)
	end
	local qtargets = sgs.PlayerList()
	for _,p in ipairs(targets) do
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
        user_string = room:askForChoice(source, "chuifeng", table.concat(slashs, "+"))
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

chongjian = sgs.CreateOneCardViewAsSkill{
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

mobile_wenyang:addSkill(quedi)
mobile_wenyang:addSkill(quediDamage)
mobile_wenyang:addSkill(mobilechoujue)
mobile_wenyang:addSkill(chuifeng)
mobile_wenyang:addSkill(chongjian)
extension:insertRelatedSkills("quedi", "#quediDamage")

--OL邓芝
ol_dengzhi = sgs.General(extension, "ol_dengzhi", "shu", 3)

xiuhao = sgs.CreateTriggerSkill{
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
	for _,p in sgs.qlist(sp) do
		if p:isDead() or not p:hasSkill(self) or p:getMark("xiuhaoUsed-Clear") > 0 then continue end
		--local spp = sp
		local spp = sgs.SPlayerList()
		for _,q in sgs.qlist(sp) do
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

sujian = sgs.CreatePhaseChangeSkill{
name = "sujian",
frequency = sgs.Skill_Compulsory,
on_phasechange = function(self, player, room)
	if player:getPhase() ~= sgs.Player_Discard then return false end
	room:sendCompulsoryTriggerLog(player, self)
	local cards, this_turn, this_turn_ids, can_dis = sgs.IntList(), player:property("fulin_list"):toString():split("+"), sgs.IntList(), sgs.IntList()
	
	for _,str in ipairs(this_turn) do
		local num = tonumber(str)
		if num and num > -1 then
			this_turn_ids:append(num)
		end
	end
	
	for _,id in sgs.qlist(player:handCards()) do
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
			local move = room:askForYijiStruct(player, cards, self:objectName(), false, false, false, -1, room:getOtherPlayers(player), sgs.CardMoveReason(), "@sujian-give", false, false)
			if move and move.to then
				local ids = give[move.to:objectName()] or sgs.IntList()
				for _,id in sgs.qlist(move.card_ids) do
					cards:removeOne(id)
					ids:append(id)
				end
				give[move.to:objectName()] = ids
			end
		end
		
		local moves = sgs.CardsMoveList()
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
			local ids = give[p:objectName()] or sgs.IntList()
			if ids:isEmpty() then continue end
			local move = sgs.CardsMoveStruct(ids, player, p, sgs.Player_PlaceHand, sgs.Player_PlaceHand,
				sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), p:objectName(), self:objectName(), ""))
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
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
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
			local id = room:askForCardChosen(player, to, "he", self:objectName(), false, sgs.Card_MethodDiscard, sgs.IntList(), true)
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

sujianFakeMove = sgs.CreateTriggerSkill{
name = "#sujianFakeMove",
events = {sgs.BeforeCardsMove, sgs.CardsMoveOneTime},
can_trigger = function(self, player)
	return player
end,
on_trigger = function(self, event, player, data, room)
	for _,p in sgs.qlist(room:getAllPlayers()) do
		if p:hasFlag("sujian_InTempMoving") then return true end
	end
	return false
end,
priority=10
}

ol_dengzhi:addSkill(xiuhao)
ol_dengzhi:addSkill(sujian)
ol_dengzhi:addSkill(sujianFakeMove)
extension:insertRelatedSkills("sujian", "#sujianFakeMove")

--OL马忠
ol_mazhong = sgs.General(extension, "ol_mazhong", "shu", 4)

olfumanCard = sgs.CreateSkillCard{
name = "olfuman",
handling_method = sgs.Card_MethodNone,
will_throw = false,
filter = function(self, targets, to_select, player)
	return #targets == 0 and to_select:objectName() ~= player:objectName() and to_select:getMark("olfuman_target-PlayClear") <= 0
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

olfumanVS = sgs.CreateOneCardViewAsSkill{
name = "olfuman",
filter_pattern = ".|.|.|hand",
view_as = function(self, card)
	local c = olfumanCard:clone()
	c:addSubcard(card)
	return c
end
}

olfuman = sgs.CreateTriggerSkill{
name = "olfuman",
events = {sgs.DamageDone, sgs.CardFinished},
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
			for _,p in sgs.qlist(room:getAllPlayers()) do
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

xianwei = sgs.CreateTriggerSkill{
name = "xianwei",
events = {sgs.EventPhaseStart, sgs.ThrowEquipArea},
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
		for _,id in sgs.qlist(room:getDrawPile()) do
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
		for _,p in sgs.qlist(room:getOtherPlayers(player, true)) do
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

zhiming = sgs.CreateTriggerSkill{
name = "zhiming",
events = {sgs.EventPhaseStart, sgs.EventPhaseEnd},
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
	room:moveCardTo(card, nil, sgs.Player_DrawPile, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), "zhiming", ""))
	return false
end
}

xingbu = sgs.CreatePhaseChangeSkill{
name = "xingbu",
frequency = sgs.Skill_Frequent,
on_phasechange = function(self, player, room)
	if player:getPhase() ~= sgs.Player_Finish then return false end
	local shows = room:showDrawPile(player, 3, "xingbu")
	
	local red = 0
	for _,id in sgs.qlist(shows) do
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
	
	local to = room:askForPlayerChosen(player, room:getOtherPlayers(player), "xingbu_" .. mark, "@xingbu-invoke:" .. mark)
	room:doAnimate(1, player:objectName(), to:objectName())
	if to:isAlive() then
		room:addPlayerMark(to, "&" .. mark .. "-SelfClear")
	end
	
	local slash = sgs.Sanguosha:cloneCard("slash")
	for _,id in sgs.qlist(shows) do
		if room:getCardPlace(id) == sgs.Player_PlaceTable then
			slash:addSubcard(id)
		end
	end
	slash:deleteLater()
	if slash:subcardsLength() > 0 then
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), "xingbu", "")
		room:throwCard(slash, reason, nil)
	end
	return false
end
}

xingbuEffect = sgs.CreateTriggerSkill{
name = "#xingbuEffect",
events = {sgs.EventPhaseChanging, sgs.DrawNCards, sgs.CardFinished},
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
		if use.card:isKindOf("SkillCard") or use.card:hasFlag("tenyearyixiang_first_card") then return false end
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

xingbuTMD = sgs.CreateTargetModSkill{
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

olxingbu = sgs.CreatePhaseChangeSkill{
name = "olxingbu",
frequency = sgs.Skill_Frequent,
on_phasechange = function(self, player, room)
	if player:getPhase() ~= sgs.Player_Finish then return false end
	local shows = room:showDrawPile(player, 3, "olxingbu")
	
	local red = 0
	for _,id in sgs.qlist(shows) do
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
	for _,id in sgs.qlist(shows) do
		if room:getCardPlace(id) == sgs.Player_PlaceTable then
			slash:addSubcard(id)
		end
	end
	slash:deleteLater()
	if slash:subcardsLength() > 0 then
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), "olxingbu", "")
		room:throwCard(slash, reason, nil)
	end
	return false
end
}

olxingbuEffect = sgs.CreateTriggerSkill{
name = "#olxingbuEffect",
events = {sgs.EventPhaseChanging, sgs.DrawNCards, sgs.EventPhaseStart},
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

olxingbuTMD = sgs.CreateTargetModSkill{
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

olwansha = sgs.CreateTriggerSkill{
name = "olwansha",
events = {sgs.AskForPeaches, sgs.EnterDying, sgs.QuitDying, sgs.PreventPeach, sgs.AfterPreventPeach, sgs.EventPhaseChanging},
frequency = sgs.Skill_Compulsory,
can_trigger = function(self, player)
	return player
end,
priority = {7, 7, 7},  --等价于 priority = {7, 7, 7, 2, 2} 因为触发技的默认优先级为2
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
			for _,p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:objectName() == current:objectName() or p:getMark("olwansha_effected-Clear") > 0 then continue end
				p:addMark("olwansha_effected-Clear")
				room:addPlayerMark(p, "@skill_invalidity")
				for _,p in sgs.qlist(room:getAllPlayers())do
					room:filterCards(p, p:getCards("he"), true)
				end
				local jsonValue={9}
				room:doBroadcastNotify(sgs.CommandType.S_COMMAND_LOG_EVENT, json.encode(jsonValue))
			end
		end
	else
		if event == sgs.EventPhaseChanging then
			if data:toPhaseChange().to ~= sgs.Player_NotActive then return false end
		end
		for _,p in sgs.qlist(room:getAllPlayers(true)) do
			if p:getMark("olwansha_effected-Clear") <= 0 then continue end
			p:removeMark("olwansha_effected-Clear")
			room:removePlayerMark(p, "@skill_invalidity")
			for _,p in sgs.qlist(room:getAllPlayers())do
				room:filterCards(p, p:getCards("he"), false)
			end
			local jsonValue={9}
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

olluanwuCard = sgs.CreateSkillCard{
name = "olluanwu",
target_fixed = true,
on_use = function(self, room, source)
	room:removePlayerMark(source, "@olluanwuMark")
	room:doSuperLightbox("ol_jiaxu", "olluanwu")
	for _,p in sgs.qlist(room:getOtherPlayers(source)) do
		if p:isDead() then continue end
		room:cardEffect(self, source, p)
        room:getThread():delay()
	end
	if source:isAlive() then
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:setSkillName("_olluanwu")
		slash:deleteLater()
		for _,p in sgs.qlist(room:getAlivePlayers()) do
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
	for _,p in sgs.qlist(players) do
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

olluanwu = sgs.CreateZeroCardViewAsSkill{
name = "olluanwu",
frequency = sgs.Skill_Limited,
limit_mark = "@olluanwuMark",
response_pattern = "@@olluanwu",
view_as = function(self,card)
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

olluanwuTMD = sgs.CreateTargetModSkill{
name="#olluanwuTMD",
distance_limit_func = function(self, player, card)
	if card:getSkillName() == "olluanwu" then
		return 1000
	end
end
}

olweimu = sgs.CreateProhibitSkill{
name = "olweimu",
is_prohibited = function(self, from, to, card)
	return to:hasSkill(self) and (card:isKindOf("TrickCard") or card:isKindOf("QiceCard")) and card:isBlack() and not string.find(card:getSkillName(), "guhuo")
end
}

olweimuDamage = sgs.CreateTriggerSkill{
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

olhaoshiCard = sgs.CreateSkillCard{
name = "olhaoshi",
will_throw = false,
handling_method = sgs.Card_MethodNone,
filter = function(self, targets, to_select, player)
	return #targets == 0 and to_select:objectName() ~= player:objectName() and to_select:getHandcardNum() == player:getMark("olhaoshi")
end,
on_effect = function(self, effect)
	local room = effect.from:getRoom()
	room:addPlayerMark(effect.to, "&olhaoshi+#" .. effect.from:objectName())
	room:giveCard(effect.from, effect.to, self, "olhaoshi")
end
}

olhaoshiVS = sgs.CreateViewAsSkill{
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

olhaoshi = sgs.CreateTriggerSkill{
name = "olhaoshi",
events = {sgs.DrawNCards, sgs.AfterDrawNCards, sgs.EventPhaseStart},
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
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
			least = math.min(least, p:getHandcardNum())
		end
		room:setPlayerMark(player, "olhaoshi", least)
		
		local used = room:askForUseCard(player, "@@olhaoshi!", "@haoshi", -1, sgs.Card_MethodNone)
		if used then return false end
		
		local beggar
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
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
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
			room:setPlayerMark(p, "&olhaoshi+#" .. player:objectName(), 0)
		end
	end
	return false
end
}

olhaoshiEffect = sgs.CreateTriggerSkill{
name = "#olhaoshiEffect",
events = sgs.TargetConfirmed,
on_trigger = function(self, event, player, data, room)
	local use = data:toCardUse()
	if not use.to:contains(player) then return false end
	if not use.card:isKindOf("Slash") and not use.card:isNDTrick() then return false end
	for _,p in sgs.qlist(room:getOtherPlayers(player)) do
		if player:isDead() then return false end
		if p:isDead() or p:getMark("&olhaoshi+#" .. player:objectName()) <= 0 or p:isKongcheng() then continue end
		local card = room:askForCard(p, ".|.|.|hand", "@olhaoshi-give:" .. player:objectName(), data, sgs.Card_MethodNone)
		if not card then continue end
		room:giveCard(p, player, card, "olhaoshi")
	end
	return false
end
}

oldimengCard = sgs.CreateSkillCard{
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

oldimengVS = sgs.CreateZeroCardViewAsSkill{
name = "oldimeng",
view_as = function(self,card)
	return oldimengCard:clone()
end,
enabled_at_play = function(self, player)
	return not player:hasUsed("#oldimeng")
end
}

oldimeng = sgs.CreateTriggerSkill{
name = "oldimeng",
events = sgs.EventPhaseEnd,
view_as_skill = oldimengVS,
can_trigger = function(self, player)
	return player and player:isAlive() and player:canDiscard(player, "he")
end,
on_trigger = function(self, event, player, data, room)
	if player:getPhase() ~= sgs.Player_Play then return false end
	local send = true
	for _,p in sgs.qlist(room:getAllPlayers()) do
		if player:isDead() or not player:canDiscard(player, "he") then return false end
		for _,q in sgs.qlist(room:getAllPlayers()) do
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

secondwenji = sgs.CreatePhaseChangeSkill{
name = "secondwenji",
on_phasechange = function(self, player, room)
	if player:getPhase() ~= sgs.Player_Play then return false end
	local sp = sgs.SPlayerList()
	for _,p in sgs.qlist(room:getOtherPlayers(player)) do
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

secondwenjiEffect = sgs.CreateTriggerSkill{
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
	for _,p in sgs.qlist(room:getOtherPlayers(player)) do
		table.insert(no_respond_list, p:objectName())
	end
	use.no_respond_list = no_respond_list
	data:setValue(use)
	return false
end
}

secondtunjiang = sgs.CreatePhaseChangeSkill{
name = "secondtunjiang",
frequency = sgs.Skill_Frequent,
on_phasechange = function(self, player, room)
	if player:getPhase() ~= sgs.Player_Finish or player:getMark("tunjiang-Clear") > 0 then return false end
	if not player:askForSkillInvoke(self) then return false end
	player:peiyin(self)
	local kingdoms = {}
	for _,p in sgs.qlist(room:getAlivePlayers()) do
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

secondkangge = sgs.CreateTriggerSkill{
name = "secondkangge",
events = {sgs.EventPhaseStart, sgs.CardsMoveOneTime, sgs.Dying, sgs.Death},
on_trigger = function(self, event, player, data, room)
	if event == sgs.EventPhaseStart then
		if player:getMark("jianjie_Round-Keep") ~= 1 or player:getPhase() ~= sgs.Player_RoundStart then return false end
		local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "@kangge-target", false, true)
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

secondjielie = sgs.CreateTriggerSkill{
name = "secondjielie",
events = sgs.DamageInflicted,
on_trigger = function(self, event, player, data, room)
	local damage = data:toDamage()
	if not damage.from or damage.from:objectName() == player:objectName() or damage.from:getMark("&secondkangge+#" .. player:objectName()) > 0 then return false end
	if damage.damage <= 0 then return false end
	player:setTag("secondjielie_damage_data", data)
	local invoke = player:askForSkillInvoke(self, sgs.QVariant("secondjielie:"  .. damage.damage))
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
	
	for _,p in sgs.qlist(room:getAllPlayers()) do
		if p:isDead() or p:getMark("&secondkangge+#" .. player:objectName()) <= 0 then continue end
		local list = sgs.IntList()
		for _,id in sgs.qlist(room:getDiscardPile()) do
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

yise = sgs.CreateTriggerSkill{
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
			if card:isRed() then red = true
			elseif card:isBlack() then black = true end
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

yiseDamage = sgs.CreateTriggerSkill{
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

shunshi = sgs.CreateTriggerSkill{
name = "shunshi",
events = {sgs.EventPhaseStart, sgs.Damaged},
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
	
	for _,p in sgs.qlist(players) do  --prepare for ai
		p:setFlags("shunshi")
	end
	
	local cards = sgs.IntList()
	for _,id in sgs.qlist(player:handCards()) do
		cards:append(id)
	end
	for _,id in sgs.qlist(player:getEquipsId()) do
		cards:append(id)
	end
	local move = room:askForYijiStruct(player, cards, self:objectName(), false, false, true, 1, players, sgs.CardMoveReason(), "@shunshi-give", true, false)
	if move.to and not move.card_ids:isEmpty() then
		for _,p in sgs.qlist(players) do
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

shunshiEffect = sgs.CreateTriggerSkill{
name = "#shunshiEffect",
events = {sgs.DrawNCards, sgs.EventPhaseStart},
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

shunshiTMD = sgs.CreateTargetModSkill{
name = "#shunshiTMD",
pattern = "Slash",
residue_func = function(self, player)
	return (player:getPhase() == sgs.Player_Play and player:getMark("shunshi_play-PlayClear")) or 0
end
}

shunshiMAX = sgs.CreateMaxCardsSkill{
name = "#shunshiMAX",
extra_func = function(self, player)
	return (player:getPhase() == sgs.Player_Discard and player:getMark("shunshi_discard-Self" .. sgs.Player_Discard .. "Clear")) or 0
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

fengzi = sgs.CreateTriggerSkill{
name = "fengzi",
events = sgs.CardUsed,
on_trigger = function(self, event, player, data, room)
	if player:getPhase() ~= sgs.Player_Play or player:getMark("fengzi_Used-PlayClear") > 0 then return false end
	local use = data:toCardUse()
	if not use.card:isKindOf("BasicCard") and not use.card:isNDTrick() then return false end
	if not player:canDiscard(player, "h") then return false end
	local typee = (use.card:isKindOf("BasicCard") and "BasicCard") or "TrickCard"
	local card = room:askForCard(player, ""..typee .. "|.|.|hand", "@fengzi-discard:" .. use.card:getType() .. "::" .. use.card:objectName(), data, self:objectName())
	if not card then return false end
	player:peiyin(self)
	player:addMark("fengzi_Used-PlayClear")
	room:setCardFlag(use.card, "fengzi_double")
	return false
end
}

fengziDouble = sgs.CreateTriggerSkill{
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
	if use.card:isKindOf("Slash") then  --【杀】需要单独处理
		for _,p in sgs.qlist(use.to) do
			local se = sgs.SlashEffectStruct()
			se.from = use.from
			se.to = p
			se.slash = use.card
			se.nullified = table.contains(use.nullified_list, "_ALL_TARGETS") or table.contains(use.nullified_list, p:objectName())
			se.no_offset = table.contains(use.no_offset_list, "_ALL_TARGETS") or table.contains(use.no_offset_list, p:objectName())
			se.no_respond = table.contains(use.no_respond_list, "_ALL_TARGETS") or table.contains(use.no_respond_list, p:objectName())
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

jizhanw = sgs.CreatePhaseChangeSkill{
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
	for _,id in sgs.qlist(gets) do
		if room:getCardPlace(id) ~= sgs.Player_PlaceTable then continue end
		slash:addSubcard(id)
	end
	
	if slash:subcardsLength() > 0 then
		if player:isDead() then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), "")
			room:throwCard(slash, reason, nil)
			return true
		end
		room:obtainCard(player, slash)
	end
	return true
end
}

fusong = sgs.CreateTriggerSkill{
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
	for _,p in sgs.qlist(room:getOtherPlayers(player)) do
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

qingjue = sgs.CreateTriggerSkill{
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
	for _,p in sgs.qlist(room:getOtherPlayers(player)) do
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

fengjie = sgs.CreatePhaseChangeSkill{
name = "fengjie",
frequency = sgs.Skill_Compulsory,
on_phasechange = function(self, player, room)
	if player:getPhase() ~= sgs.Player_Start then return false end
	local t = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "@fengjie-invoke", false, true)
	player:peiyin(self)
	room:setPlayerMark(t, "&fengjie+#" .. player:objectName(), 1)
	local tag = sgs.QVariant()
	tag:setValue(t)
	player:setTag("FengjieTarget", tag)
	return false
end
}

fengjieEffect = sgs.CreateTriggerSkill{
name = "#fengjieEffect",
events = {sgs.EventPhaseStart, sgs.Death},
can_trigger = function(self, player)
	return player
end,
on_trigger = function(self, event, player, data, room)
	if event == sgs.EventPhaseStart then
		if player:getPhase() == sgs.Player_RoundStart then
			player:removeTag("FengjieTarget")
			for _,p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, "&fengjie+#" .. player:objectName(), 0)
			end
		elseif player:getPhase() == sgs.Player_Finish then
			for _,p in sgs.qlist(room:getAllPlayers()) do
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
		for _,p in sgs.qlist(room:getAllPlayers()) do
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
	for _,c in sgs.qlist(target:getEquips()) do
		local n = c:getRealCard():toEquipCard():location()
		if player:getEquip(n) or not player:hasEquipArea(n) then
			ids:append(c:getEffectiveId())
		end
	end
	for _,c in sgs.qlist(target:getJudgingArea()) do
		if player:containsTrick(c:objectName()) then --target:isProhibited(player, c)
			ids:append(c:getEffectiveId())
		end
	end
	return ids
end

zhibian = sgs.CreatePhaseChangeSkill{
name = "zhibian",
on_phasechange = function(self, player, room)
	if player:getPhase() ~= sgs.Player_Start then return false end
	local sp = sgs.SPlayerList()
	for _,p in sgs.qlist(room:getOtherPlayers(player)) do
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

zhibianSkip = sgs.CreateTriggerSkill{
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

yuyanzy = sgs.CreateTriggerSkill{
name = "yuyanzy",
events = sgs.TargetConfirming,
frequency=sgs.Skill_Compulsory,
on_trigger=function(self, event, player, data, room)
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
	
	local card = room:askForCard(use.from, ".|.|" .. num + 1 .. "~13", "@yuyanzy-give:" .. player:objectName() .. "::" .. num, data, sgs.Card_MethodNone)
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

yilie = sgs.CreatePhaseChangeSkill{
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

yilieTMD = sgs.CreateTargetModSkill{
name = "#yilieTMD",
pattern = "Slash",
residue_func = function(self, player)
	return (player:getPhase() == sgs.Player_Play and player:getMark("yilie_slash-PlayClear")) or 0
end
}

yilieSlash = sgs.CreateTriggerSkill{
name = "#yilieSlash",
events = sgs.SlashMissed,
can_trigger = function(self, player)
	return player and player:isAlive() and player:getMark("yilie_draw-PlayClear") > 0 and player:getPhase() == sgs.Player_Play
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

mobilefenmingCard = sgs.CreateSkillCard{
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

mobilefenming = sgs.CreateZeroCardViewAsSkill{
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

gongxiu = sgs.CreateTriggerSkill{
name = "gongxiu",
events = sgs.EventPhaseChanging,
on_trigger = function(self, event, player, data, room)
	if data:toPhaseChange().to ~= sgs.Player_NotActive then return false end
	if player:getMark("jinghe_Used-Clear") <= 0 then return false end
	
	local choices = {}
	for _,p in sgs.qlist(room:getAllPlayers()) do
		if p:getMark("jinghe_GetSkill-Clear") > 0 then
			table.insert(choices, "draw")
			break
		end
	end
	for _,p in sgs.qlist(room:getOtherPlayers(player)) do
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
		for _,p in sgs.qlist(room:getAllPlayers()) do
			if p:getMark("jinghe_GetSkill-Clear") > 0 then
				sp:append(p)
			end
		end
		if not sp:isEmpty() then
			room:drawCards(sp, 1, self:objectName())
		end
	else
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:isAlive() and p:getMark("jinghe_GetSkill-Clear") <= 0 and p:canDiscard(p, "h") then
				room:askForDiscard(p, self:objectName(), 1, 1)
			end
		end
	end
	return false
end
}

jingheCard = sgs.CreateSkillCard{
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
	for _,id in sgs.qlist(self:getSubcards()) do
		room:showCard(source, id)
	end
	
	local tianshu_skills = {"tenyearleiji", "biyue", "nostuxi", "mingce", "zhiyan", "nhyinbing", "nhhuoqi", "nhguizhu", "nhxianshou", "nhlundao", "nhguanyue", "nhyanzheng"}
	
	for _,p in ipairs(targets) do
		if p:isDead() then continue end
		local new_tianshu_skills = {}
		for _,sk in ipairs(tianshu_skills) do
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

jingheVS = sgs.CreateViewAsSkill{
name = "jinghe",
n = 4,
view_filter = function(self, selected, to_select)
	if to_select:isEquipped() or #selected > 3 then return false end
	for _,c in ipairs(selected) do
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
enabled_at_play = function(self,player)
	return player:getMark("jinghe_Used-Clear") <= 0
end
}

jinghe = sgs.CreateTriggerSkill{
name = "jinghe",
events = {sgs.PreCardUsed, sgs.EventPhaseStart, sgs.Death},
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
		
		for _,p in sgs.qlist(room:getAllPlayers()) do
			if p:isDead() then continue end
			local skills = p:getTag("jinghe_GetSkills_" .. player:objectName()):toString():split(",")
			p:removeTag("jinghe_GetSkills_" .. player:objectName())
			if #skills == 0 or skills[1] == "" then continue end
			local lose = {}
			for _,sk in ipairs(skills) do
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

nhyinbing = sgs.CreateTriggerSkill{
name = "nhyinbing",
events = {sgs.Predamage, sgs.HpLost},
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
		for _,p in sgs.qlist(room:getAllPlayers()) do
			if p:isDead() or not p:hasSkill(self) then return false end
			room:sendCompulsoryTriggerLog(p, self)
			p:drawCards(1, self:objectName())
		end
	end
	return false
end
}

nhhuoqiCard = sgs.CreateSkillCard{
name = "nhhuoqi",
filter = function(self, targets, to_select, player)
	local hp = player:getHp()
	for _,p in sgs.qlist(player:getAliveSiblings()) do
		hp = math.min(hp, p:getHp())
	end
	return #targets  == 0 and to_select:getHp() == hp
end,
on_effect = function(self, effect)
	local room, from, to = effect.from:getRoom(), effect.from, effect.to
	room:recover(to, sgs.RecoverStruct((from:isAlive() and from) or nil))
	to:drawCards(1, "nhhuoqi")
end
}

nhhuoqi = sgs.CreateOneCardViewAsSkill{
name = "nhhuoqi",
filter_pattern = ".!",
view_as = function(self, card)
	local c = nhhuoqiCard:clone()
	c:addSubcard(card)
	return c
end,
enabled_at_play = function(self,player)
	return not player:hasUsed("#nhhuoqi")
end
}

nhguizhu = sgs.CreateTriggerSkill{
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

nhxianshouCard = sgs.CreateSkillCard{
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

nhxianshou = sgs.CreateZeroCardViewAsSkill{
name = "nhxianshou",
view_as = function(self, card)
	return nhxianshouCard:clone()
end,
enabled_at_play = function(self,player)
	return not player:hasUsed("#nhxianshou")
end
}

nhlundao = sgs.CreateMasochismSkill{
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

nhguanyue = sgs.CreatePhaseChangeSkill{
name = "nhguanyue",
frequency = sgs.Skill_Frequent,
on_phasechange = function(self, player, room)
	if player:getPhase() ~= sgs.Player_Finish then return false end
	if not player:askForSkillInvoke(self) then return false end
	player:peiyin(self)
	
	local ids = room:getNCards(2, false)
	room:fillAG(ids, player)  --偷懒用AG
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

nhyanzhengCard = sgs.CreateSkillCard{
name = "nhyanzheng",
filter = function(self, targets, to_select, player)
	return #targets < player:getMark("nhyanzheng-PlayClear")
end,
on_use = function(self, room, source, targets)
	local thread = room:getThread()
	for _,p in ipairs(targets) do
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

nhyanzhengVS = sgs.CreateZeroCardViewAsSkill{
name = "nhyanzheng",
response_pattern = "@@nhyanzheng",
view_as = function(self, card)
	return nhyanzhengCard:clone()
end
}

nhyanzheng = sgs.CreatePhaseChangeSkill{
name = "nhyanzheng",
view_as_skill = nhyanzhengVS,
on_phasechange = function(self, player, room)
	if player:getPhase() ~= sgs.Player_Start or player:getHandcardNum() <= 1 then return false end
	local card = room:askForCard(player, ".|.|.|hand", "@nhyanzheng-keep", sgs.QVariant(), sgs.Card_MethodNone, nil, false, self:objectName())
	if not card then return false end
	
	local slash = sgs.Sanguosha:cloneCard("slash")
	slash:deleteLater()
	for _,c in sgs.qlist(player:getCards("he")) do
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
	for _,p in ipairs(targets) do
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
	for _,p in ipairs(targets) do
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

nosjinwanyi = sgs.CreateOneCardViewAsSkill{
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

nosjinxuanbei = sgs.CreateTriggerSkill{
name = "nosjinxuanbei",
events = {sgs.GameStart, sgs.CardFinished},
on_trigger = function(self, event, player, data, room)
	if event == sgs.GameStart then
		local ids = sgs.IntList()
		for _,id in sgs.qlist(room:getDrawPile()) do
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
		local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "@nosjinxuanbei-invoke:" .. use.card:objectName(), true, true)
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

jinzhaosongCard = sgs.CreateSkillCard{
name = "jinzhaosong",
filter = function(self, targets, to_select, player)
	return #targets < 2 and to_select:hasFlag("jinzhaosong_can_choose")
end,
about_to_use = function(self, room, use)
	for _,p in sgs.qlist(use.to) do
		room:setPlayerFlag(p, "jinzhaosong_add")
	end
end
}

jinzhaosongVS = sgs.CreateZeroCardViewAsSkill{
name = "jinzhaosong",
response_pattern = "@@jinzhaosong",
view_as = function()
	return jinzhaosongCard:clone()
end,
}

jinzhaosong = sgs.CreateTriggerSkill{
name = "jinzhaosong",
events = {sgs.EventPhaseEnd, sgs.Dying, sgs.EventPhaseStart, sgs.CardUsed, sgs.CardFinished, sgs.DamageDone},
view_as_skill = jinzhaosongVS,
can_trigger = function(self, player)
	return player and player:isAlive()
end,
on_trigger = function(self, event, player, data, room)
	if event == sgs.EventPhaseEnd then
		if player:getPhase() ~= sgs.Player_Draw then return false end
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
			if player:getMark("&jzslei") > 0 or player:getMark("&jzsfu") > 0 or player:getMark("&jzssong") > 0 then return false end
			if player:isKongcheng() or player:isDead() then return false end
			if p:isDead() or not p:hasSkill(self) then continue end
			if not p:askForSkillInvoke(self, player) then continue end
			p:peiyin(self)
			
			local card = room:askForExchange(player, self:objectName(), 1, 1, false, "@jinzhaosong-give:" .. p:objectName())
			local _card = sgs.Sanguosha:getCard(card:getSubcards():first())
			local mark
			if _card:isKindOf("TrickCard") then mark = "&jzslei"
			elseif _card:isKindOf("EquipCard") then mark = "&jzsfu"
			elseif _card:isKindOf("BasicCard") then mark = "&jzssong" end
			
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
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
			if use.to:contains(p) or not player:canSlash(p, use.card) then continue end
			room:setPlayerFlag(p, "jinzhaosong_can_choose")
			can_invoke = true
		end
		
		if not can_invoke then
			for _,p in sgs.qlist(room:getOtherPlayers(player)) do
				room:setPlayerFlag(p, "-jinzhaosong_can_choose")
			end
			return false
		end
		
		local invoke = room:askForUseCard(player, "@@jinzhaosong", "@jinzhaosong", -1, sgs.Card_MethodNone)
		
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
			room:setPlayerFlag(p, "-jinzhaosong_can_choose")
		end
		
		if not invoke then return false end
		
		local targets = sgs.SPlayerList()
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
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
		for _,p in sgs.qlist(targets) do
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
		for _,p in sgs.qlist(room:getAllPlayers()) do
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

jinlisi = sgs.CreateTriggerSkill{
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
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
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

huishiCard = sgs.CreateSkillCard{
name = "huishi",
target_fixed = true,
on_use = function(self, room, source)	
	local suits = {}
	while (source:isAlive() and source:getMaxHp() < 10) do		
		local judge = sgs.JudgeStruct()
		judge.who = source
		judge.reason = self:objectName()
		judge.pattern = ".|" .. table.concat(suits, ",")
		judge.throw_card = false
		judge.good = false
		room:judge(judge)
		table.insert(suits, judge.card:getSuitString())
		local id = judge.card:getEffectiveId()
		if room:getCardPlace(id)==sgs.Player_PlaceJudge then
			self:addSubcard(id)
		end
		
		if judge:isGood() and source:getMaxHp() < 10 and source:isAlive() and source:askForSkillInvoke("huishi") then
			room:gainMaxHp(source, 1, self:objectName())
		else
			break
		end
	end
	
	if source:isAlive() and self:subcardsLength() > 0 then
		room:fillAG(self:getSubcards(), source)
		local to = room:askForPlayerChosen(source, room:getAlivePlayers(), self:objectName(), "@huishi-give", true, false)
		room:clearAG(source)
		if not to then return end
		room:doAnimate(1, source:objectName(), to:objectName())
		room:giveCard(source, to, self, self:objectName(), true)
		if to:isAlive() and source:isAlive() then
			local hand = to:getHandcardNum()
			for _,p in sgs.qlist(room:getAlivePlayers()) do
				if p:getHandcardNum() > hand then return end
			end
			room:loseMaxHp(source, 1, self:objectName())
		end
	end
end
}

huishi = sgs.CreateZeroCardViewAsSkill{
name = "huishi",
view_as = function()
	return huishiCard:clone()
end,
enabled_at_play = function(self, player)
	return player:getMaxHp() < 10 and not player:hasUsed("#huishi")
end
}

godtianyi = sgs.CreatePhaseChangeSkill{
name = "godtianyi",
frequency = sgs.Skill_Wake,
waked_skills = "zuoxing",
can_wake = function(self, event, player, data, room)
	if player:getPhase() ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
	if player:canWake(self:objectName()) then return true end
	for _,p in sgs.qlist(room:getAlivePlayers()) do
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

godtianyiRecord = sgs.CreateTriggerSkill{
name = "#godtianyiRecord",
--frequency = sgs.Skill_Wake,
events = sgs.DamageDone,
global = true,
on_trigger = function(self, event, player, data, room)
	player:addMark("godtianyi_record")
	return false
end
}

huishiiCard = sgs.CreateSkillCard{
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
	for _,sk in sgs.qlist(target:getVisibleSkillList()) do
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

huishiiVS = sgs.CreateZeroCardViewAsSkill{
name = "huishii",
view_as = function()
	return huishiiCard:clone()
end,
enabled_at_play = function(self, player)
	return player:getMark("@huishiiMark") > 0
end
}

huishii = sgs.CreateGameStartSkill{
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

zuoxingCard = sgs.CreateSkillCard{
name = "zuoxing",
target_fixed = false,
filter = function(self, targets, to_select, player)
	local card = player:getTag("zuoxing"):toCard()
	if not card then return false end

	local new_targets = sgs.PlayerList()
	for _,p in ipairs(targets) do
		new_targets:append(p)
	end
	
	local _card = sgs.Sanguosha:cloneCard(card:objectName())
	_card:setCanRecast(false)
	_card:setSkillName("zuoxing")
	_card:deleteLater()
	
	if _card and _card:targetFixed() then  --因源码bug，不得已而为之
		return #targets== 0 and to_select:objectName() == player:objectName() and not player:isProhibited(to_select, _card, new_targets)
	end
	return _card and _card:targetFilter(new_targets, to_select, player) and not player:isProhibited(to_select, _card, new_targets)
end,
feasible = function(self, targets, player)
	local card = player:getTag("zuoxing"):toCard()
	if not card then return false end
	
	local new_targets = sgs.PlayerList()
	for _,p in ipairs(targets) do
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

zuoxingVS = sgs.CreateZeroCardViewAsSkill{
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

zuoxing = sgs.CreatePhaseChangeSkill{
name = "zuoxing",
guhuo_type = "r",
view_as_skill = zuoxingVS,
on_phasechange = function(self, player, room)
	if player:getPhase() ~= sgs.Player_Start then return false end
	local shenguojias = sgs.SPlayerList()
	for _,p in sgs.qlist(room:getAlivePlayers()) do
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

dulie = sgs.CreateTriggerSkill{
name = "dulie",
events = {sgs.GameStart, sgs.TargetConfirming},
frequency = sgs.Skill_Compulsory,
on_trigger = function(self, event, player, data, room)
	if event == sgs.GameStart then
		room:sendCompulsoryTriggerLog(player, self)
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
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

dulieTMD = sgs.CreateTargetModSkill{
name="#dulie-tmd",
pattern = "Slash",
distance_limit_func = function(self, from, card, to)
	if from:hasSkill("dulie") and to and to:getMark("&stscdlwei") <= 0 then
		return 1000
	else
		return 0
	end
end
}

powei = sgs.CreateTriggerSkill{
name = "powei",
events = {sgs.DamageCaused, sgs.CardFinished, sgs.Dying},
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
		for _,p in sgs.qlist(room:getAlivePlayers()) do
			if p:getMark("&stscdlwei") > 0 then return false end
		end
		room:sendShimingLog(player, self)
		room:acquireSkill(player, "shenzhuo")
	else
		local who = room:getCurrentDyingPlayer()
		if not who or who:objectName() ~= player:objectName() then return false end
		room:sendShimingLog(player, self, false)
		local recover = math.min(1- player:getHp(), player:getMaxHp() - player:getHp())
		room:recover(player, sgs.RecoverStruct(player, nil, recover))
		if player:isAlive() then
			player:throwAllEquips()
		end
	end
	return false
end
}

dangmoCard = sgs.CreateSkillCard{
name = "dangmo",
mute = true,
filter = function(self, targets, to_select, player)
	return #targets < player:getHp() - 1 and to_select:hasFlag("dangmo")
end,
about_to_use = function(self, room, use)
	for _,p in sgs.qlist(use.to) do
		room:setPlayerFlag(p, "dangmo_slash")
	end
end
}

dangmoVS = sgs.CreateZeroCardViewAsSkill{
name = "dangmo",
response_pattern = "@@dangmo",
view_as = function()
	return dangmoCard:clone()
end
}

dangmo = sgs.CreateTriggerSkill{
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
	
	for _,p in sgs.qlist(extra_targets) do
		room:setPlayerFlag(p, "dangmo")
	end
	
	room:askForUseCard(player, "@@dangmo", "@dangmo:" .. use.card:objectName() .. "::" .. extra, -1, sgs.Card_MethodNone)
	
	local adds = sgs.SPlayerList()
	for _,p in sgs.qlist(extra_targets) do
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
	for _,p in sgs.qlist(adds) do
		room:doAnimate(1, player:objectName(), p:objectName())
	end
	room:notifySkillInvoked(player, self:objectName())
	player:peiyin(self)
	return false
end
}

dangmoSlash = sgs.CreateTriggerSkill{
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

shenzhuo = sgs.CreateTriggerSkill{
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

shenzhuoSlash = sgs.CreateTargetModSkill{
name = "#shenzhuo-slash",
pattern = "Slash",
residue_func=function(self,player)
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

yingbaCard = sgs.CreateSkillCard{
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

yingba = sgs.CreateZeroCardViewAsSkill{
name = "yingba",
view_as = function(self,card)
	return yingbaCard:clone()
end,
enabled_at_play = function(self, player)
	return not player:hasUsed("#yingba")
end
}

yingbaTMD = sgs.CreateTargetModSkill{
name="#yingba-tmd",
pattern = "^SkillCard",
distance_limit_func = function(self, from, card, to)
	if from:hasSkill("yingba") and to and to:getMark("&sscybpingding") > 0 then
		return 1000
	else
		return 0
	end
end
}

fuhaisc = sgs.CreateTriggerSkill{
name = "fuhaisc",
events = {sgs.CardUsed, sgs.TargetSpecifying, sgs.CardsMoveOneTime, sgs.Death, sgs.CardResponded},
frequency = sgs.Skill_Compulsory,
on_trigger = function(self, event, player, data, room)
	if event == sgs.CardUsed then
		local use = data:toCardUse()
		if use.card:isKindOf("SkillCard") then return false end
		local sp, no_respond_list = sgs.SPlayerList(), use.no_respond_list
		for _,p in sgs.qlist(room:getAllPlayers()) do
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
		for _,p in sgs.qlist(room:getAllPlayers()) do
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
		for _,p in sgs.qlist(use.to) do
			if p:getMark("&sscybpingding") > 0 then
				invoke = true
				break
			end
		end
		if not invoke then return false end
		room:sendCompulsoryTriggerLog(player, self)
		player:drawCards(1, self:objectName())
	elseif event == sgs.CardsMoveOneTime then  --这个时机应该单独写成一个触发技，要有单独的can_trigger，以免被无效，我就偷懒了
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

pinghe = sgs.CreateMaxCardsSkill{
name = "pinghe",
fixed_func = function(self, target)
	if target:hasSkill(self:objectName()) then
		return target:getLostHp()
	else
		return -1
	end
end
}

pinghedamage = sgs.CreateTriggerSkill{
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

tianzuo = sgs.CreateTriggerSkill{
name = "tianzuo",
events = {sgs.GameStart, sgs.CardEffected},
frequency = sgs.Skill_Compulsory,
waked_skills = "_qizhengxiangsheng",
on_trigger = function(self, event, player, data, room)
	if event == sgs.GameStart then
		local cards = sgs.IntList()
		for _,id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
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

lingce = sgs.CreateTriggerSkill{
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
	for _,p in sgs.qlist(room:getAllPlayers()) do
		if p:isDead() or not p:hasSkill(self) then continue end
		local names = p:property("SkillDescriptionRecord_dinghan"):toString():split("+")
		if use.card:isZhinangCard() or --use.card:isKindOf("Dismantlement") or use.card:isKindOf("Nullification") or use.card:isKindOf("Qizhengxiangsheng") or
			(p:hasSkill("dinghan", true) and table.contains(names, use.card:objectName())) then
			room:sendCompulsoryTriggerLog(p, self)
			p:drawCards(1, self:objectName())
		end
	end
	return false
end
}

dinghan = sgs.CreateTriggerSkill{
name = "dinghan",
events = {sgs.TargetConfirming, sgs.EventPhaseStart},
on_trigger = function(self, event, player, data, room)
	if event == sgs.TargetConfirming then
		local use = data:toCardUse()
		if not use.card:isKindOf("TrickCard") then return false end
		local names, name = player:property("SkillDescriptionRecord_dinghan"):toString():split("+"), use.card:objectName()
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
		local record, other, all, dinghan, tricks = sgs.IntList(), sgs.IntList(), sgs.IntList(), player:property("SkillDescriptionRecord_dinghan"):toString():split("+"), {}
		for _,id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
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
		
		for _,id in sgs.qlist(record) do
			all:append(id)
		end
		for _,id in sgs.qlist(other) do
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
		local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"), sgs.QVariant(), "", "tip")
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

tenyearjianshuCard = sgs.CreateSkillCard{
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
	
	local other = room:askForPlayerChosen(from, targets, self:objectName(), "@tenyearjianshu-pindian:" .. to:objectName())
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
		for _,id in sgs.qlist(winner:handCards()) do
			if winner:canDiscard(winner, id) then
				cards:append(id)
			end
		end
		for _,id in sgs.qlist(winner:getEquipsId()) do
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
		for _,p in sgs.qlist(losers) do
			room:loseHp(sgs.HpLostStruct(p, 1, "tenyearjianshu", from))
		end
	end
end
}

tenyearjianshuVS = sgs.CreateOneCardViewAsSkill{
name = "tenyearjianshu",
filter_pattern = ".|black|.|hand",
view_as = function(self, card)
	local c = tenyearjianshuCard:clone()
	c:addSubcard(card)
	return c
end,
enabled_at_play = function(self,player)
	return not player:hasUsed("#tenyearjianshu")
end
}

tenyearjianshu = sgs.CreateTriggerSkill{
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

tenyearyongdiCard = sgs.CreateSkillCard{
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
		for _,p in sgs.qlist(room:getOtherPlayers(to)) do
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
	for _,p in sgs.qlist(room:getOtherPlayers(to)) do
		if p:getHandcardNum() < hand then
			return
		end
	end
	to:drawCards(math.min(to:getMaxHp(), 5), self:objectName())
end
}

tenyearyongdi = sgs.CreateZeroCardViewAsSkill{
name = "tenyearyongdi",
frequency = sgs.Skill_Limited,
limit_mark = "@tenyearyongdiMark",
view_as = function(self,card)
	return tenyearyongdiCard:clone()
end,
enabled_at_play = function(self, player)
	return player:getMark("@tenyearyongdiMark") > 0
end
}

tenyear_new_sp_jiaxu:addSkill("zhenlve")
tenyear_new_sp_jiaxu:addSkill(tenyearjianshu)
tenyear_new_sp_jiaxu:addSkill(tenyearyongdi)

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
["illustrator:mobile_wenyang"] = "",
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
[":chuifeng"] = "魏势力技，你可以失去1点体力，视为使用一张【决斗】或任一种【杀】。",
["chongjian"] = "冲坚",
[":chongjian"] = "吴势力技，你可以将一张装备牌当【酒】或任一种【杀】使用。",

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
["$sujian1"] = "不苟素俭，不治私产",--对的，就是这个治，不是置。原文：身之衣食资仰于官,不苟素俭,然终不治私产,妻子不免饥寒 
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
[":xianwei"] = "锁定技，准备阶段开始时，你废除一个装备栏并摸等同于你未废除装备栏数的牌，然后令一名其他角色使用牌堆中第一张对应副类别的装备牌（若牌堆中没有则改为摸一张牌）。当你废除所有装备栏后，你加两点体力上限，然后你视为在其他角色攻击范围内且其他角色视为在你攻击范围内。",
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
[":xingbu"] = "结束阶段开始时，你可以亮出牌堆顶的三张牌，根据其中红色牌的数量，令一名其他角色获得对应效果直到其回合结束：\
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

["ol_qiaozhou"] = "OL谯周",
["&ol_qiaozhou"] = "谯周",
["#ol_qiaozhou"] = "观星知命",
["illustrator:ol_qiaozhou"] = "",
["olxingbu"] = "星卜",
[":olxingbu"] = "结束阶段开始时，你可以亮出牌堆顶的三张牌，根据其中红色牌的数量，令一名其他角色获得对应效果直到其回合结束：\
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
[":secondtunjiang"] = "结束阶段开始时，若你未于本回合的出牌阶段内使用牌指定过其他角色为目标，你可以摸X张牌（X为全场势力数）。",
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
[":fengjie"] = "锁定技，准备阶段开始时，你选择一名其他角色。直到你下回合开始，每名角色的结束阶段开始时，若其存活，你将手牌数摸至或弃置至与其体力值相同（至多为4）。",
["@fengjie-invoke"] = "请选择一名其他角色",

["zongyu"] = "宗预",
["#zongyu"] = "御严无惧",
["illustrator:zongyu"] = "",
["zhibian"] = "直辩",
[":zhibian"] = "准备阶段开始时，你可以与一名其他角色拼点。若你赢，你可以选择一项：将其场上的一张牌移到你的对应区域；2.回复1点体力；3.跳过下个摸牌阶段，然后依次执行前两项。若你没赢，你失去1点体力。",
["@zhibian-invoke"] = "你可以与一名其他角色拼点",
["zhibian:move"] = "移动%src场上的牌",
["zhibian:recover"] = "回复1点体力",
["zhibian:beishui"] = "跳过下个摸牌阶段，然后依次执行前两项",
["yuyanzy"] = "御严",
[":yuyanzy"] = "锁定技，当你成为体力值大于你的角色使用的非转化的【杀】的目标时，其选择一项：交给你一张点数大于此【杀】的牌；或取消之。",
["@yuyanzy-give"] = "请交给 %src 一张点数大于 %arg 的牌",

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
[":nhguanyue"] = "结束阶段开始时，你可以观看牌堆顶两张牌，然后获得其中一张牌并将另一张牌置于牌堆顶。",
["nhyanzheng"] = "言政",
[":nhyanzheng"] = "准备阶段开始时，若你的手牌数大于1，你可以保留一张手牌并弃置其余牌，然后选择至多等于弃牌数量的角色，对这些角色各造成1点伤害。",
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
["$nosjinwanyi1"] = "",
["$nosjinwanyi2"] = "",
["~nos_jin_yangzhi"] = "",

["nos_jin_yangyan"] = "杨艳-旧",
["&nos_jin_yangyan"] = "杨艳",
["#nos_jin_yangyan"] = "武元皇后",
["illustrator:nos_jin_yangyan"] = "",
["nosjinxuanbei"] = "选备",
[":nosjinxuanbei"] = "游戏开始时，你获得牌堆中两张带强化效果的牌。每个回合限一次，你使用带强化效果的牌后，你可将其交给一名其他角色。",
["@nosjinxuanbei-invoke"] = "你可以将 %src 交给一名其他角色",
["$nosjinxuanbei1"] = "",
["$nosjinxuanbei2"] = "",
["~nos_jin_yangyan"] = "",

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
["$jinzhaosong1"] = "",
["$jinzhaosong2"] = "",
["$jinlisi1"] = "",
["$jinlisi2"] = "",
["~jin_zuofen"] = "",

["shenguojia"] = "神郭嘉",
["#shenguojia"] = "星月奇佐",
["illustrator:shenguojia"] = "木美人",
["huishi"] = "慧识",
[":huishi"] = "出牌阶段限一次，若你的体力上限小于10，你可以进行一次判定，若判定结果与此阶段内以此法进行判定的判定结果花色均不同，且你的体力上限小于10，你可以重复此判定并加1点体力上限。" ..
				"然后你可将所有判定牌交给一名角色，然后若其手牌数为全场最多，你减1点体力上限。",
["@huishi-give"] = "你可将这些牌交给一名角色",
["godtianyi"] = "天翊",
[":godtianyi"] = "觉醒技，准备阶段开始时，若所有存活角色均受到过伤害，你加2点体力上限，回复1点体力，然后令一名角色获得“佐幸”。",
["@godtianyi-invoke"] = "请令一名角色获得“佐幸”",
["huishii"] = "辉逝",
[":huishii"] = "限定技，出牌阶段，你可以选择一名角色：若其有未触发的觉醒技且你的体力上限不小于存活角色数，你选择其中一个觉醒技，该技能视为满足觉醒条件；否则其摸四张牌。若如此做，你减2点体力上限。",
["zuoxing"] = "佐幸",
[":zuoxing"] = "准备阶段开始时，若神郭嘉存活且体力上限大于1，你可令神郭嘉减1点体力上限。若如此做，本回合的出牌阶段限一次，你可视为使用一张非延时类锦囊牌。",
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
["$powei1"] = "君且城中等候，待吾探敌虚实",--普通效果
["$powei2"] = "弓马骑射洒热血，突破重围显英豪",--成功
["$powei3"] = "敌军尚犹严防，有待明日再看",--失败
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
[":lingce"] = "锁定技，当一名角色使用非转化的锦囊牌时，若此牌是智囊牌或已被你的“定汉”记录，你摸一张牌。",
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
}

local skillList = sgs.SkillList()
local newgenerals_skills = {nhyinbing, nhhuoqi, nhguizhu, nhxianshou, nhlundao, nhguanyue, nhyanzheng, zuoxing, shenzhuo, shenzhuoSlash}
for _,sk in ipairs(newgenerals_skills) do
	if not sgs.Sanguosha:getSkill(sk:objectName()) then
		skillList:append(sk)
	end
end
sgs.Sanguosha:addSkills(skillList)

return packages