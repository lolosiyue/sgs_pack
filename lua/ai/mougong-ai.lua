--谋黄忠-七天体验卡
--“烈弓”AI
sgs.ai_skill_invoke.mouliegongg = function(self, data)
	if not (self.player:getMark("&mouliegongg+heart") > 0 and self.player:getMark("&mouliegongg+diamond") > 0) then return false end
	local target = data:toPlayer()
	return not self:isFriend(target)
end

--谋黄忠-正式版
--“烈弓”AI
sgs.ai_skill_invoke.mouliegongf = function(self, data)
	if not (self.player:getMark("&mouliegongf+heart") > 0 and self.player:getMark("&mouliegongf+diamond") > 0) then return false end
	local target = data:toPlayer()
	return not self:isFriend(target)
end


--

--谋华雄-魔将之泪
--“扬威”AI
local mouyangweii_skill = {}
mouyangweii_skill.name = "mouyangweii"
table.insert(sgs.ai_skills, mouyangweii_skill)
mouyangweii_skill.getTurnUseCard = function(self)
	if self.player:getMark("mouyangweiiUsed") > 0 or self:getCardsNum("Slash") == 0 then return end
	return sgs.Card_Parse("#mouyangweiiCard:.:")
end

sgs.ai_skill_use_func["#mouyangweiiCard"] = function(card, use, self)
	if self.player:getMark("mouyangweiiUsed") == 0 then
		use.card = card
		return
	end
end

sgs.ai_use_value.mouyangweiiCard = 8.5
sgs.ai_use_priority.mouyangweiiCard = 9.5
sgs.ai_card_intention.mouyangweiiCard = -80
--

--FC谋关羽
--“武圣”AI
sgs.ai_view_as.fcmouwusheng = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place ~= sgs.Player_PlaceSpecial and card:isRed() and not card:isKindOf("Peach") and not card:hasFlag("using") then
		return ("slash:fcmouwusheng[%s:%s]=%d"):format(suit, number, card_id)
	end
end

local fcmouwusheng_skill = {}
fcmouwusheng_skill.name = "fcmouwusheng"
table.insert(sgs.ai_skills, fcmouwusheng_skill)
fcmouwusheng_skill.getTurnUseCard = function(self, inclusive)
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	local red_card
	self:sortByUseValue(cards, true)
	local useAll = false
	self:sort(self.enemies, "defense")
	for _, enemy in ipairs(self.enemies) do
		if enemy:getHp() == 1 and not enemy:hasArmorEffect("EightDiagram") and self.player:distanceTo(enemy) <= self.player:getAttackRange() and self:isWeak(enemy)
			and getCardsNum("Jink", enemy, self.player) + getCardsNum("Peach", enemy, self.player) + getCardsNum("Analeptic", enemy, self.player) == 0 then
			useAll = true
			break
		end
	end
	local disCrossbow = false
	if self:getCardsNum("Slash") < 2 or self.player:hasSkills("paoxiao|tenyearpaoxiao|olpaoxiao") then
		disCrossbow = true
	end
	local nuzhan_equip = false
	local nuzhan_equip_e = false
	self:sort(self.enemies, "defense")
	if self.player:hasSkill("nuzhan") then
		for _, enemy in ipairs(self.enemies) do
			if not enemy:hasArmorEffect("EightDiagram") and self.player:distanceTo(enemy) <= self.player:getAttackRange()
				and getCardsNum("Jink", enemy) < 1 then
				nuzhan_equip_e = true
				break
			end
		end
		for _, card in ipairs(cards) do
			if card:isRed() and card:isKindOf("TrickCard") and nuzhan_equip_e then
				nuzhan_equip = true
				break
			end
		end
	end
	local nuzhan_trick = false
	local nuzhan_trick_e = false
	self:sort(self.enemies, "defense")
	if self.player:hasSkill("nuzhan") and not self.player:hasFlag("hasUsedSlash") and self:getCardsNum("Slash") > 1 then
		for _, enemy in ipairs(self.enemies) do
			if not enemy:hasArmorEffect("EightDiagram") and self.player:distanceTo(enemy) <= self.player:getAttackRange() then
				nuzhan_trick_e = true
				break
			end
		end
		for _, card in ipairs(cards) do
			if card:isRed() and card:isKindOf("TrickCard") and nuzhan_trick_e then
				nuzhan_trick = true
				break
			end
		end
	end
	for _, card in ipairs(cards) do
		if card:isRed() and not card:isKindOf("Slash") and not (nuzhan_equip or nuzhan_trick)
			and (not isCard("Peach", card, self.player) and not isCard("ExNihilo", card, self.player) and not useAll)
			and (not isCard("Crossbow", card, self.player) or disCrossbow)
			and (self:getUseValue(card) < sgs.ai_use_value.Slash or inclusive or sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, sgs.Sanguosha:cloneCard("slash")) > 0) then
			red_card = card
			break
		end
	end
	if nuzhan_equip then
		for _, card in ipairs(cards) do
			if card:isRed() and card:isKindOf("EquipCard") then
				red_card = card
				break
			end
		end
	end
	if nuzhan_trick then
		for _, card in ipairs(cards) do
			if card:isRed() and card:isKindOf("TrickCard") then
				red_card = card
				break
			end
		end
	end
	if red_card then
		local suit = red_card:getSuitString()
		local number = red_card:getNumberString()
		local card_id = red_card:getEffectiveId()
		local card_str = ("slash:fcmouwusheng[%s:%s]=%d"):format(suit, number, card_id)
		local slash = sgs.Card_Parse(card_str)
		assert(slash)
		return slash
	end
end

function sgs.ai_cardneed.fcmouwusheng(to, card)
	return card:isRed() --鼓励使用，因为都有加成效果
end

--“义绝”AI
local fcmouyijue_skill = {}
fcmouyijue_skill.name = "fcmouyijue"
table.insert(sgs.ai_skills, fcmouyijue_skill)
fcmouyijue_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("fcmouyijueCard") or self.player:isNude() or #self.enemies == 0 then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local lightning = self:getCard("Lightning")
	if self:needToThrowArmor() then
		card_id = self.player:getArmor():getId()
	elseif self.player:getHandcardNum() > self.player:getHp() then
		if lightning and not self:willUseLightning(lightning) then
			card_id = lightning:getEffectiveId()
		else
			for _, acard in ipairs(cards) do
				if (acard:isKindOf("BasicCard") or acard:isKindOf("EquipCard") or acard:isKindOf("AmazingGrace"))
					and not acard:isKindOf("Peach") then
					card_id = acard:getEffectiveId()
					break
				end
			end
		end
	elseif not self.player:getEquips():isEmpty() then
		local player = self.player
		if player:getWeapon() then
			card_id = player:getWeapon():getId()
		elseif player:getOffensiveHorse() then
			card_id = player:getOffensiveHorse():getId()
		elseif player:getDefensiveHorse() then
			card_id = player:getDefensiveHorse():getId()
		elseif player:getArmor() and player:getHandcardNum() <= 1 then
			card_id = player:getArmor():getId()
		end
	end
	if not card_id then
		if lightning and not self:willUseLightning(lightning) then
			card_id = lightning:getEffectiveId()
		else
			for _, acard in ipairs(cards) do
				if (acard:isKindOf("BasicCard") or acard:isKindOf("EquipCard") or acard:isKindOf("AmazingGrace"))
					and not acard:isKindOf("Peach") then
					card_id = acard:getEffectiveId()
					break
				end
			end
		end
	end
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("#fcmouyijueCard:" .. card_id .. ":")
	end
end

sgs.ai_skill_use_func["#fcmouyijueCard"] = function(card, use, self)
	if not self.player:hasUsed("#fcmouyijueCard") then
		self:sort(self.enemies)
		self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 0 then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.fcmouyijueCard = 8.5
sgs.ai_use_priority.fcmouyijueCard = 9.5
sgs.ai_card_intention.fcmouyijueCard = 80

--谋赵云
--“龙胆”AI
local moulongdann_skill = {}
moulongdann_skill.name = "moulongdann"
table.insert(sgs.ai_skills, moulongdann_skill)
moulongdann_skill.getTurnUseCard = function(self)
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	local jink_card
	self:sortByUseValue(cards, true)
	for _, card in ipairs(cards) do
		if card:isKindOf("Jink") then
			jink_card = card
			break
		end
	end
	if not jink_card then return nil end
	local suit = jink_card:getSuitString()
	local number = jink_card:getNumberString()
	local card_id = jink_card:getEffectiveId()
	local card_str = ("slash:moulongdann[%s:%s]=%d"):format(suit, number, card_id)
	local slash = sgs.Card_Parse(card_str)
	assert(slash)
	return slash
end

sgs.ai_view_as.moulongdann = function(card, player, card_place)
	if player:getMark("&moulongdannLast") == 0 then return false end
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place == sgs.Player_PlaceHand then
		if card:isKindOf("Jink") then
			return ("slash:moulongdann[%s:%s]=%d"):format(suit, number, card_id)
		elseif card:isKindOf("Slash") then
			return ("jink:moulongdann[%s:%s]=%d"):format(suit, number, card_id)
		end
	end
end

sgs.moulongdann_keep_value = {
	Peach = 6,
	Analeptic = 5.8,
	Jink = 5.7,
	Slash = 5.6,
	FireSlash = 5.7,
	ThunderSlash = 5.5,
	IceSlash = 5.9,
	ExNihilo = 4.7
}
--“龙胆”升级版AI
local moulongdannEX_skill = {}
moulongdannEX_skill.name = "moulongdannEX"
table.insert(sgs.ai_skills, moulongdannEX_skill)
moulongdannEX_skill.getTurnUseCard = function(self, inclusive)
	self:updatePlayers()
	self:sort(self.enemies, "defense")
	local handcards = sgs.QList2Table(self.player:getCards("h"))
	if self.player:getPile("wooden_ox"):length() > 0 then
		for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
			table.insert(handcards, sgs.Sanguosha:getCard(id))
		end
	end
	self:sortByUseValue(handcards, true)
	local equipments = sgs.QList2Table(self.player:getCards("e"))
	self:sortByUseValue(equipments, true)
	local basic_cards = {}
	local basic_cards_count = 0
	local non_basic_cards = {}
	local use_cards = {}
	if self.player:getArmor() and self.player:hasArmorEffect("silver_lion") and self.player:isWounded() and self.player:getLostHp() >= 2 then
		table.insert(non_basic_cards, self.player:getArmor():getEffectiveId())
	end
	for _, c in ipairs(handcards) do
		if not c:isKindOf("Peach") then
			if c:isKindOf("BasicCard") then
				basic_cards_count = basic_cards_count + 1
				table.insert(basic_cards, c:getEffectiveId())
			else
				table.insert(non_basic_cards, c:getEffectiveId())
			end
		end
	end
	for _, e in ipairs(equipments) do
		if e:isKindOf("OffensiveHorse") then
			table.insert(non_basic_cards, e:getEffectiveId())
		end
	end
	if self:getOverflow() <= 0 then return end
	if self.player:getMark("&moulongdannLast") > 0 then
		if #basic_cards > 0 then
			table.insert(use_cards, basic_cards[1])
		end
		if #use_cards == 0 then return end
	end
	if self.player:isWounded() then
		return sgs.Card_Parse("#moulongdannEX:" .. table.concat(use_cards, "+") .. ":" .. "peach")
	end
	for _, enemy in ipairs(self.enemies) do
		if self.player:canSlash(enemy) and self:isGoodTarget(enemy, self.enemies, nil) and self.player:inMyAttackRange(enemy) then
			local fire_slash = sgs.Sanguosha:cloneCard("fire_slash")
			local thunder_slash = sgs.Sanguosha:cloneCard("thunder_slash")
			local ice_slash = sgs.Sanguosha:cloneCard("ice_slash")
			local slash = sgs.Sanguosha:cloneCard("slash")
			if not self:slashProhibit(fire_slash, enemy, self.player) and self:slashIsEffective(fire_slash, enemy, self.player) then
				return sgs.Card_Parse("#moulongdannEX:" .. table.concat(use_cards, "+") .. ":" .. "fire_slash")
			end
			if not self:slashProhibit(thunder_slash, enemy, self.player) and self:slashIsEffective(thunder_slash, enemy, self.player) then
				return sgs.Card_Parse("#moulongdannEX:" .. table.concat(use_cards, "+") .. ":" .. "thunder_slash")
			end
			if not self:slashProhibit(ice_slash, enemy, self.player) and self:slashIsEffective(ice_slash, enemy, self.player) then
				return sgs.Card_Parse("#moulongdannEX:" .. table.concat(use_cards, "+") .. ":" .. "ice_slash")
			end
			if not self:slashProhibit(slash, enemy, self.player) and self:slashIsEffective(slash, enemy, self.player) then
				return sgs.Card_Parse("#moulongdannEX:" .. table.concat(use_cards, "+") .. ":" .. "slash")
			end
		end
	end
end

sgs.ai_skill_use_func["#moulongdannEX"] = function(card, use, self)
	if self.player:getMark("&moulongdannLast") == 0 then return false end
	local userstring = card:toString()
	userstring = (userstring:split(":"))[4]
	local moulongdannEXcard = sgs.Sanguosha:cloneCard(userstring, card:getSuit(), card:getNumber())
	moulongdannEXcard:setSkillName("moulongdannEX")
	self:useBasicCard(moulongdannEXcard, use)
	if not use.card then return end
	use.card = card
end

sgs.ai_use_priority["moulongdannEX"] = 3
sgs.ai_use_value["moulongdannEX"] = 3

sgs.ai_view_as["moulongdannEX"] = function(card, player, card_place, class_name)
	local classname2objectname = {
		["Slash"] = "slash",
		["Jink"] = "jink",
		["Peach"] = "peach",
		["Analeptic"] = "analeptic",
		["FireSlash"] = "fire_slash",
		["ThunderSlash"] = "thunder_slash",
		["IceSlash"] = "ice_slash"
	}
	local name = classname2objectname[class_name]
	if not name then return end
	local no_have = true
	local cards = player:getCards("he")
	if player:getPile("wooden_ox"):length() > 0 then
		for _, id in sgs.qlist(player:getPile("wooden_ox")) do
			cards:prepend(sgs.Sanguosha:getCard(id))
		end
	end
	for _, c in sgs.qlist(cards) do
		if c:isKindOf(class_name) then
			no_have = false
			break
		end
	end
	if not no_have then return end
	if class_name == "Peach" and player:getMark("Global_PreventPeach") > 0 then return end
	local handcards = sgs.QList2Table(player:getCards("h"))
	if player:getPile("wooden_ox"):length() > 0 then
		for _, id in sgs.qlist(player:getPile("wooden_ox")) do
			table.insert(handcards, sgs.Sanguosha:getCard(id))
		end
	end
	local equipments = sgs.QList2Table(player:getCards("e"))
	local basic_cards = {}
	local non_basic_cards = {}
	local use_cards = {}
	if player:getArmor() and player:hasArmorEffect("silver_lion") and player:isWounded() and player:getLostHp() >= 2 then
		table.insert(non_basic_cards, player:getArmor():getEffectiveId())
	end
	for _, c in ipairs(handcards) do
		if not c:isKindOf("Peach") then
			if c:isKindOf("BasicCard") then
				table.insert(basic_cards, c:getEffectiveId())
			else
				table.insert(non_basic_cards, c:getEffectiveId())
			end
		end
	end
	for _, e in ipairs(equipments) do
		if not (e:isKindOf("Armor") or e:isKindOf("DefensiveHorse")) and not (e:isKindOf("WoodenOx") and player:getPile("wooden_ox"):length() > 0) then
			table.insert(non_basic_cards, e:getEffectiveId())
		end
	end
	if player:getMark("&moulongdannLast") > 0 then
		if #basic_cards > 0 then
			table.insert(use_cards, basic_cards[1])
		end
		if #use_cards == 0 then return end
	end
	if player:getMark("&moulongdannLast") > 0 then
		if class_name == "Peach" then
			local dying = player:getRoom():getCurrentDyingPlayer()
			if dying and dying:getHp() < 0 then return end
			return (name .. ":moulongdannEX[%s:%s]=%d"):format(sgs.Card_NoSuit, 0, use_cards[1])
		else
			return (name .. ":moulongdannEX[%s:%s]=%d"):format(sgs.Card_NoSuit, 0, use_cards[1])
		end
	end
end

function sgs.ai_cardneed.moulongdannEX(to, card, self)
	if to:getMark("&moulongdannLast") == 0 then return false end
	return card:isKindOf("BasicCard")
end

--“积著”AI（威力加强版的就不写了）
sgs.ai_skill_invoke.moujizhuoo = true

sgs.ai_skill_playerchosen.moujizhuoo = function(self, targets)
	return self.player:getNextAlive() --积著“协力”只有选下家才能收益最大化
end

sgs.ai_skill_choice.moujizhuoo = function(self, choices, data)
	local items = choices:split("+")
	if table.contains(items, "XL_bingjin") and math.random() < 0.7 then
		return
		"XL_bingjin"
	end
	if table.contains(items, "XL_tongchou") and math.random() < 0.6 then
		return
		"XL_tongchou"
	end
	if table.contains(items, "XL_luli") and math.random() < 0.6 then
		return
		"XL_luli"
	end
	return items[math.random(1, #items)]
end



--

--谋孙尚香
--“良助”AI
local mouliangzhuu_skill = {}
mouliangzhuu_skill.name = "mouliangzhuu"
table.insert(sgs.ai_skills, mouliangzhuu_skill)
mouliangzhuu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("mouliangzhuuCard") or self.player:getKingdom() ~= "shu" then return end
	return sgs.Card_Parse("#mouliangzhuuCard:.:")
end

sgs.ai_skill_use_func["#mouliangzhuuCard"] = function(card, use, self)
	if not self.player:hasUsed("#mouliangzhuuCard") and self.player:getKingdom() == "shu" then
		self:sort(self.enemies)
		self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 0 and enemy:getEquips():length() > 0 then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.mouliangzhuuCard = 8.5
sgs.ai_use_priority.mouliangzhuuCard = 9.5
sgs.ai_card_intention.mouliangzhuuCard = 80

sgs.ai_skill_choice.mouliangzhuu = function(self, choices, data)
	if self.player:getHp() <= 1 and self.player:getHandcardNum() > 0 then return "1" end
	return "2"
end

--“结姻”AI
sgs.ai_skill_choice.moujieyinn = function(self, choices, data)
	if self.player:getHandcardNum() - self.player:getHp() >= 2 and self.player:getHp() > 1 then return "1" end
	if self.player:getMark("&mouHusbandMarkLost") > 0 then return "3" end
	return "2"
end

sgs.ai_skill_discard.moujieyinn = function(self) --给牌
	local to_discard = {}
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	table.insert(to_discard, cards[1]:getEffectiveId())
	table.insert(to_discard, cards[2]:getEffectiveId())
	return to_discard
end

--“枭姬”AI
sgs.ai_skill_playerchosen.mouxiaojii = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isEnemy(p) and p:getEquips():length() > 0 then
			return p
		end
	end
	return nil
end
--

--谋马超
--“铁骑”AI
--发动
sgs.ai_skill_invoke.moutieqii = function(self, data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end
--谋弈时的博弈AI已写在技能中。

--谋杨婉
--“暝眩”AI（待补充，且须补充）
sgs.ai_skill_discard.moumingxuann = function(self) --给牌
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	table.insert(to_discard, cards[1]:getEffectiveId())
	return to_discard
end

--“陷仇”AI
sgs.ai_skill_invoke.mouxianchouu = true

sgs.ai_skill_playerchosen.mouxianchouu = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isFriend(p) and not self:isNude() then
			return p
		end
	end
	return nil
end




--

--谋孙权
--“制衡”AI
local mouzhihengg_skill = {}
mouzhihengg_skill.name = "mouzhihengg"
table.insert(sgs.ai_skills, mouzhihengg_skill)
mouzhihengg_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("mouzhihenggCard") then
		return sgs.Card_Parse("#mouzhihenggCard:.:")
	end
end

sgs.ai_skill_use_func["#mouzhihenggCard"] = function(card, use, self)
	if self.player:hasUsed("#mouzhihenggCard") then return false end

	local unpreferedCards = {}
	local cards = sgs.QList2Table(self.player:getHandcards())
	if self.player:getHp() < 3 then
		local zcards = self.player:getCards("he")
		local use_slash, keep_jink, keep_analeptic, keep_weapon = false, false, false
		local keep_slash = self.player:getTag("JilveWansha"):toBool()
		for _, zcard in sgs.qlist(zcards) do
			if not isCard("Peach", zcard, self.player) and not isCard("ExNihilo", zcard, self.player) then
				local shouldUse = true
				if isCard("Slash", zcard, self.player) and not use_slash then
					local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
					self:useBasicCard(zcard, dummy_use)
					if dummy_use.card then
						if keep_slash then shouldUse = false end
						if dummy_use.to then
							for _, p in sgs.qlist(dummy_use.to) do
								if p:getHp() <= 1 then
									shouldUse = false
									if self.player:distanceTo(p) > 1 then keep_weapon = self.player:getWeapon() end
									break
								end
							end
							if dummy_use.to:length() > 1 then shouldUse = false end
						end
						if not self:isWeak() then shouldUse = false end
						if not shouldUse then use_slash = true end
					end
				end
				if zcard:getTypeId() == sgs.Card_TypeTrick then
					local dummy_use = { isDummy = true }
					self:useTrickCard(zcard, dummy_use)
					if dummy_use.card then shouldUse = false end
				end
				if zcard:getTypeId() == sgs.Card_TypeEquip and not self.player:hasEquip(zcard) then
					local dummy_use = { isDummy = true }
					self:useEquipCard(zcard, dummy_use)
					if dummy_use.card then shouldUse = false end
					if keep_weapon and zcard:getEffectiveId() == keep_weapon:getEffectiveId() then shouldUse = false end
				end
				if self.player:hasEquip(zcard) and zcard:isKindOf("Armor") and not self:needToThrowArmor() then shouldUse = false end
				if self.player:hasEquip(zcard) and zcard:isKindOf("DefensiveHorse") and not self:needToThrowArmor() then shouldUse = false end
				if self.player:hasEquip(zcard) and zcard:isKindOf("WoodenOx") and self.player:getPile("wooden_ox"):length() > 1 then shouldUse = false end
				if isCard("Jink", zcard, self.player) and not keep_jink then
					keep_jink = true
					shouldUse = false
				end
				if self.player:getHp() == 1 and isCard("Analeptic", zcard, self.player) and not keep_analeptic then
					keep_analeptic = true
					shouldUse = false
				end
				if shouldUse then table.insert(unpreferedCards, zcard:getId()) end
			end
		end
	end
	if #unpreferedCards == 0 then
		local use_slash_num = 0
		self:sortByKeepValue(cards)
		for _, card in ipairs(cards) do
			if card:isKindOf("Slash") then
				local will_use = false
				if use_slash_num <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, card) then
					local dummy_use = { isDummy = true }
					self:useBasicCard(card, dummy_use)
					if dummy_use.card then
						will_use = true
						use_slash_num = use_slash_num + 1
					end
				end
				if not will_use then table.insert(unpreferedCards, card:getId()) end
			end
		end
		local num = self:getCardsNum("Jink") - 1
		if self.player:getArmor() then num = num + 1 end
		if num > 0 then
			for _, card in ipairs(cards) do
				if card:isKindOf("Jink") and num > 0 then
					table.insert(unpreferedCards, card:getId())
					num = num - 1
				end
			end
		end
		for _, card in ipairs(cards) do
			if (card:isKindOf("Weapon") and self.player:getHandcardNum() < 3) or card:isKindOf("OffensiveHorse")
				or self:getSameEquip(card, self.player) or card:isKindOf("AmazingGrace") then
				table.insert(unpreferedCards, card:getId())
			elseif card:getTypeId() == sgs.Card_TypeTrick then
				local dummy_use = { isDummy = true }
				self:useTrickCard(card, dummy_use)
				if not dummy_use.card then table.insert(unpreferedCards, card:getId()) end
			end
		end
		if self.player:getWeapon() and self.player:getHandcardNum() < 3 then
			table.insert(unpreferedCards, self.player:getWeapon():getId())
		end
		if self:needToThrowArmor() then
			table.insert(unpreferedCards, self.player:getArmor():getId())
		end
		if self.player:getOffensiveHorse() and self.player:getWeapon() then
			table.insert(unpreferedCards, self.player:getOffensiveHorse():getId())
		end
	end
	for index = #unpreferedCards, 1, -1 do
		if sgs.Sanguosha:getCard(unpreferedCards[index]):isKindOf("WoodenOx") and self.player:getPile("wooden_ox"):length() > 1 then
			table.removeOne(unpreferedCards, unpreferedCards[index])
		end
	end
	local use_cards = {}
	for index = #unpreferedCards, 1, -1 do
		if not self.player:isJilei(sgs.Sanguosha:getCard(unpreferedCards[index])) then table.insert(use_cards,
				unpreferedCards[index]) end
	end
	if #use_cards > 0 then
		use.card = sgs.Card_Parse("#mouzhihenggCard:" .. table.concat(use_cards, "+") .. ":")
		return
	end
end

sgs.ai_use_value.mouzhihenggCard = sgs.ai_use_value.ZhihengCard
sgs.ai_use_priority.mouzhihenggCard = sgs.ai_use_priority.ZhihengCard
sgs.dynamic_value.benefit.mouzhihenggCard = sgs.dynamic_value.benefit.ZhihengCard

--[[function sgs.ai_cardneed.mouzhihengg(to, card)
	return not card:isKindOf("Jink")
end]]

--

--谋吕蒙
--“克己”AI
local moukejii_skill = {}
moukejii_skill.name = "moukejii"
table.insert(sgs.ai_skills, moukejii_skill)
moukejii_skill.getTurnUseCard = function(self)
	if (self.player:getMark("moudujiangg") == 0 and self.player:hasFlag("moukejii_get1hujia") and self.player:hasFlag("moukejii_get2hujias"))
		or (self.player:getMark("moudujiangg") > 0 and self.player:hasUsed("moukejiiCard")) then
		return
	end
	return sgs.Card_Parse("#moukejiiCard:.:")
end

sgs.ai_skill_use_func["#moukejiiCard"] = function(card, use, self)
	if ((self.player:getMark("moudujiangg") == 0 and not (self.player:hasFlag("moukejii_get1hujia") and self.player:hasFlag("moukejii_get2hujias")))
			or (self.player:getMark("moudujiangg") > 0 and not self.player:hasUsed("#moukejiiCard")))
		and not (self.player:hasFlag("moukejii_get2hujias") and self.player:isKongcheng()) --防止选过2选项又没手牌导致选不了1选项只能点“取消”从而无限发动的情况
		and not (self.player:hasFlag("moukejii_get1hujia") and self.player:getHp() <= 1
			and self:getCardsNum("Peach") == 0 and self:getCardsNum("Analeptic") == 0) then --防止选过1选项又不能冒把自己崩死的险点“取消”从而无限发动的情况
		use.card = card
		return
	end
end

sgs.ai_use_value.moukejiiCard = 8.5
sgs.ai_use_priority.moukejiiCard = 9.5
sgs.ai_card_intention.moukejiiCard = -80

sgs.ai_skill_choice.moukejii = function(self, choices, data)
	if not self.player:hasFlag("moukejii_get2hujias") then return "2" end
	if not self.player:isKongcheng() and not self.player:hasFlag("moukejii_get1hujia") then return "1" end
	if self.player:getHp() <= 1 and self:getCardsNum("Peach") == 0 and self:getCardsNum("Analeptic") == 0 then return
		"cancel" end
	return "2"
end

--“夺荆”AI
sgs.ai_skill_invoke.moudj_duojing = function(self, data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end
--

--谋徐晃
--“断粮”AI
local mouduanliangg_skill = {}
mouduanliangg_skill.name = "mouduanliangg"
table.insert(sgs.ai_skills, mouduanliangg_skill)
mouduanliangg_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("mouduanlianggCard") then return end
	return sgs.Card_Parse("#mouduanlianggCard:.:")
end

sgs.ai_skill_use_func["#mouduanlianggCard"] = function(card, use, self)
	if not self.player:hasUsed("#mouduanlianggCard") then
		self:sort(self.enemies)
		self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 0 then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.mouduanlianggCard = 8.5
sgs.ai_use_priority.mouduanlianggCard = 9.5
sgs.ai_card_intention.mouduanlianggCard = 80

--“势迫”AI（无发动ai）
sgs.ai_skill_choice.moushipoo = function(self, choices, data)
	if self.player:isKongcheng() then return "3" end
	if self.player:getHp() <= 1 and self.player:getHandcardNum() <= 1
		and (self:getCardsNum("Peach") > 0 or self:getCardsNum("Analeptic") > 0)
	then
		return "4"
	end
	if self.player:getHp() <= 1 then return "3" end
	return "4"
end

sgs.ai_skill_discard.moushipoo = function(self) --给牌
	local to_discard = {}
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	table.insert(to_discard, cards[1]:getEffectiveId())
	return to_discard
end


--

--谋于禁-初版
--“节钺”AI
sgs.ai_skill_invoke.moujieyuee = true

sgs.ai_skill_playerchosen.moujieyuee = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isFriend(p) then
			return p
		end
	end
	return nil
end

sgs.ai_skill_discard.moujieyuee = function(self) --给牌
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	table.insert(to_discard, cards[1]:getEffectiveId())
	table.insert(to_discard, cards[2]:getEffectiveId())
	return to_discard
end





--

--FC文鸯
--“却敌”AI
sgs.ai_skill_invoke.fcquedi = function(self, data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end

sgs.ai_skill_choice.fcquedi = function(self, choices, data)
	local target = data:toPlayer()
	if target:isKongcheng() then return "damage" end
	if self.player:getMaxHp() > 0 then return "beishui" end --无脑背水以求输出最大化，背水一战，不胜便死！
	return "obtain"
end

--“棰锋”AI
local fcchuifeng_skill = {}
fcchuifeng_skill.name = "fcchuifeng"
table.insert(sgs.ai_skills, fcchuifeng_skill)
fcchuifeng_skill.getTurnUseCard = function(self)
	if self.player:usedTimes("#fcchuifengCard") >= 2 or self.player:hasFlag("fcchuifengEnd") then return end
	return sgs.Card_Parse("#fcchuifengCard:.:")
end

sgs.ai_skill_use_func["#fcchuifengCard"] = function(card, use, self)
	if self.player:usedTimes("#fcchuifengCard") < 2 and not self.player:hasFlag("fcchuifengEnd") then --甚至不考虑体力因素，置于死地，方能后生！
		self:sort(self.enemies)
		self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 0 then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.fcchuifengCard = 8.5
sgs.ai_use_priority.fcchuifengCard = 9.5
sgs.ai_card_intention.fcchuifengCard = 80

--“波折”AI
sgs.ai_skill_invoke["@fcbozhe-ChangeToJin"] = true


--

--阴间之王
--......这么阴间的武将还写AI你良心不会痛吗？.jpg

--谋·贾逵
--“挽澜”AI
sgs.ai_skill_playerchosen["@mouwlRD"] = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isFriend(p) then
			return p
		end
	end
	return self.player
end

sgs.ai_skill_playerchosen["@mouwlBT"] = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isEnemy(p) and not p:isNude() then
			return p
		end
	end
	return nil
end

--谋曹操
--“奸雄”AI
sgs.ai_skill_choice["@moujx_getMarks"] = function(self, choices, data)
	--return "0" --一奸到底，反正AI又不用清正（doge
	return "2" --正式版“奸雄”收益削弱之后，反而要走“清正”路线了，不然就一界曹操TAT
end

--“清正”AI
sgs.ai_skill_invoke.mouqingzhengg = true

sgs.ai_skill_playerchosen.mouqingzhengg = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isEnemy(p) and not p:isKongcheng() then
			return p
		end
	end
	return nil
end

--谋甘宁-初版
--“奇袭”AI
local mouqixii_skill = {}
mouqixii_skill.name = "mouqixii"
table.insert(sgs.ai_skills, mouqixii_skill)
mouqixii_skill.getTurnUseCard = function(self, inclusive)
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	local black_card
	self:sortByUseValue(cards, true)
	local has_weapon = false
	for _, card in ipairs(cards) do
		if card:isKindOf("Weapon") and card:isBlack() then has_weapon = true end
	end
	for _, card in ipairs(cards) do
		if card:isBlack() and ((self:getUseValue(card) < sgs.ai_use_value.Dismantlement) or inclusive or self:getOverflow() > 0) then
			local shouldUse = true
			if card:isKindOf("Armor") then
				if not self.player:getArmor() then
					shouldUse = false
				elseif self.player:hasEquip(card) and not self:needToThrowArmor() then
					shouldUse = false
				end
			end
			if card:isKindOf("Weapon") then
				if not self.player:getWeapon() then
					shouldUse = false
				elseif self.player:hasEquip(card) and not has_weapon then
					shouldUse = false
				end
			end
			if card:isKindOf("Slash") then
				local dummy_use = { isDummy = true }
				if self:getCardsNum("Slash") == 1 then
					self:useBasicCard(card, dummy_use)
					if dummy_use.card then shouldUse = false end
				end
			end
			if self:getUseValue(card) > sgs.ai_use_value.Dismantlement and card:isKindOf("TrickCard") then
				local dummy_use = { isDummy = true }
				self:useTrickCard(card, dummy_use)
				if dummy_use.card then shouldUse = false end
			end
			if shouldUse then
				black_card = card
				break
			end
		end
	end
	if black_card then
		local suit = black_card:getSuitString()
		local number = black_card:getNumberString()
		local card_id = black_card:getEffectiveId()
		local card_str = ("dismantlement:mouqixii[%s:%s]=%d"):format(suit, number, card_id)
		local dismantlement = sgs.Card_Parse(card_str)
		assert(dismantlement)

		return dismantlement
	end
end

sgs.mouqixii_suit_value = {
	spade = 3.9,
	club = 3.9
}

function sgs.ai_cardneed.mouqixii(to, card)
	return card:isBlack()
end

--“奇袭”扒光AI
sgs.ai_skill_invoke.mouqixii = function(self, data)
	local target = data:toPlayer()
	return not self:isFriend(target) and not target:hasSkill("kongcheng")
end

--“奋威”AI（大哥，算了算了）

--谋甘宁-重做版
--“奇袭”AI
local mouqixir_skill = {}
mouqixir_skill.name = "mouqixir"
table.insert(sgs.ai_skills, mouqixir_skill)
mouqixir_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#mouqixirCard") or self.player:isKongcheng() then return end
	return sgs.Card_Parse("#mouqixirCard:.:")
end

sgs.ai_skill_use_func["#mouqixirCard"] = function(card, use, self)
	if not self.player:hasUsed("#mouqixirCard") and not self.player:isKongcheng() then
		self:sort(self.enemies)
		self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 0 and not enemy:isNude() then --不是写“and not enemy:isAllNude()”:对着就判定区有牌的敌方用就duck不必了，直接资敌了
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.mouqixirCard = 8.5
sgs.ai_use_priority.mouqixirCard = 9.5
sgs.ai_card_intention.mouqixirCard = 80

--谋夏侯氏
--“燕语”AI
local mouyanyuu_skill = {}
mouyanyuu_skill.name = "mouyanyuu"
table.insert(sgs.ai_skills, mouyanyuu_skill)
mouyanyuu_skill.getTurnUseCard = function(self)
	if self.player:usedTimes("#mouyanyuuCard") >= 2 or self:getCardsNum("Slash") == 0 then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _, acard in ipairs(cards) do
		if acard:isKindOf("Slash") then
			card_id = acard:getEffectiveId()
			break
		end
	end
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("#mouyanyuuCard:" .. card_id .. ":")
	end
end

sgs.ai_skill_use_func["#mouyanyuuCard"] = function(card, use, self)
	if self.player:usedTimes("#mouyanyuuCard") < 2 and self:getCardsNum("Slash") > 0 then
		use.card = card
		return
	end
end

sgs.ai_use_value.mouyanyuuCard = 8.5
sgs.ai_use_priority.mouyanyuuCard = 9.5
sgs.ai_card_intention.mouyanyuuCard = -80

sgs.ai_skill_invoke.mouyanyuu = function(self, data)
	if #self.friends_noself == 0 then return false end
	return true
end

sgs.ai_skill_playerchosen.mouyanyuu = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isFriend(p) and p:objectName() ~= self.player:objectName() then
			return p
		end
	end
	return nil
end

--“樵拾”AI
sgs.ai_skill_invoke["@mouqiaoshii_RecoverHer"] = function(self, data)
	local target = data:toPlayer()
	return self:isFriend(target)
end

--

--KJ谋夏侯霸
--“试锋”AI
sgs.ai_skill_invoke.kjmoushifeng = true

--“绝辗”AI
sgs.ai_skill_choice.kjmoujuezhan = function(self, choices, data)
	if self.player:isWounded() and self.player:getHp() <= 1 and self.player:getHandcardNum() > 1 then return "1" end
	return "2"
end

--“励进”AI
sgs.ai_skill_choice.kjmoulijin = function(self, choices, data)
	if self.player:isWounded() and self.player:getHp() <= 1 and self.player:getHujia() == 0
		and self.player:getHandcardNum() - self.player:getHp() <= 1 then
		return "discard"
	end
	if self:getHandcardNum() <= 2 then return "draw" end
	return "play"
end

--

--谋周瑜
--“反间”应对AI（防止出现(作为对手的)谋周瑜只能扣一种花色了还猜不对的情况，虽然正常情况下并没有谁会这样做）
sgs.ai_skill_choice.moufanjiann = function(self, choices, data)
	return "1"
end

sgs.ai_skill_choice["@moufanjiann_guess"] = function(self, choices, data)
	local targets = sgs.QList2Table(targets)
	for _, p in pairs(targets) do
		if self:isEnemy(p) and p:hasFlag("mou_zhouyuu") then
			if (p:hasFlag("moufanjiann_chooseHeart") and (p:hasFlag("moufanjiann_diamondUsed") and p:hasFlag("moufanjiann_clubUsed") and p:hasFlag("moufanjiann_spadeUsed") and not p:hasFlag("moufanjiann_heartUsed")))
				or (p:hasFlag("moufanjiann_chooseDiamond") and (p:hasFlag("moufanjiann_heartUsed") and p:hasFlag("moufanjiann_clubUsed") and p:hasFlag("moufanjiann_spadeUsed") and not p:hasFlag("moufanjiann_diamondUsed")))
				or (p:hasFlag("moufanjiann_chooseClub") and (p:hasFlag("moufanjiann_heartUsed") and p:hasFlag("moufanjiann_diamondUsed") and p:hasFlag("moufanjiann_spadeUsed") and not p:hasFlag("moufanjiann_clubUsed")))
				or (p:hasFlag("moufanjiann_chooseSpade") and (p:hasFlag("moufanjiann_heartUsed") and p:hasFlag("moufanjiann_diamondUsed") and p:hasFlag("moufanjiann_clubUsed") and not p:hasFlag("moufanjiann_spadeUsed"))) then
				return "1"
			else
				return "2"
			end
		end
	end
	return "1" or "2"
end






--

--谋黄盖
--“苦肉”AI
sgs.ai_skill_invoke.moukurouu = true

sgs.ai_skill_playerchosen.moukurouu = function(self, targets)
	local targets = sgs.QList2Table(targets)
	self:sort(self.friends_noself)

	for _, p in ipairs(self.friends_noself) do
		if self:isFriend(p) then
			return p
		end
	end
	return nil
end



--

--谋刘备
--“仁德”AI（待补充）
--......

--“章武”给牌AI
sgs.ai_skill_discard.mouzhangwuu = function(self)
	local to_discard = {}
	local m = self.player:getMark("mouzhangwuuGive")
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	table.insert(to_discard, cards[1]:getEffectiveId())
	if m > 1 then table.insert(to_discard, cards[2]:getEffectiveId()) end
	if m > 2 then table.insert(to_discard, cards[3]:getEffectiveId()) end
	return to_discard
end

--“激将”选择AI
sgs.ai_skill_choice.moujijiangg = function(self, choices, data)
	return "1=" .. jjto:objectName()
end

--FC谋姜维
--“挑衅”AI
local fcmoutiaoxin_skill = {}
fcmoutiaoxin_skill.name = "fcmoutiaoxin"
table.insert(sgs.ai_skills, fcmoutiaoxin_skill)
fcmoutiaoxin_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("fcmoutiaoxinCard") or self.player:getMark("@fcXuLi") == 0 then return end
	return sgs.Card_Parse("#fcmoutiaoxinCard:.:")
end

sgs.ai_skill_use_func["#fcmoutiaoxinCard"] = function(card, use, self)
	if not self.player:hasUsed("#fcmoutiaoxinCard") and self.player:getMark("@fcXuLi") > 0 then
		local n = 0
		local m = self.player:getMark("@fcXuLi")
		self:sort(self.enemies)
		self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 0 then
				use.card = card
				if use.to then
					use.to:append(enemy)
					n = n + 1
				end
				if n >= m then return end
			end
		end
		return
	end
end

sgs.ai_use_value.fcmoutiaoxinCard = 8.5
sgs.ai_use_priority.fcmoutiaoxinCard = 9.5
sgs.ai_card_intention.fcmoutiaoxinCard = 80

--“志继”->“妖智”AI
sgs.ai_skill_invoke.fcmzj_yaozhi = true

--“志继”->“界妆神”AI
sgs.ai_skill_invoke.fcmzj_jiezhuangshen = true

--谋曹仁
--“据守”AI
local moujushouu_skill = {}
moujushouu_skill.name = "moujushouu"
table.insert(sgs.ai_skills, moujushouu_skill)
moujushouu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("moujushouuCard") or self.player:isNude() then return end
	return sgs.Card_Parse("#moujushouuCard:.:")
end

sgs.ai_skill_use_func["#moujushouuCard"] = function(card, use, self)
	if not self.player:hasUsed("#moujushouuCard") and not self.player:isNude() then
		use.card = card
		return
	end
end

sgs.ai_use_value.moujushouuCard = 2
sgs.ai_use_priority.moujushouuCard = 2.5
sgs.ai_card_intention.moujushouuCard = -20

sgs.ai_skill_choice.moujushouu = function(self, choices, data)
	return "11" --无脑弃一叠一，保证“解围”的发动
		or "2" --无脑叠，增加摸牌收益
end

--“解围”AI
local moujieweii_skill = {}
moujieweii_skill.name = "moujieweii"
table.insert(sgs.ai_skills, moujieweii_skill)
moujieweii_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#moujieweiiCard") or self.player:getHujia() == 0 then return end
	return sgs.Card_Parse("#moujieweiiCard:.:")
end

sgs.ai_skill_use_func["#moujieweiiCard"] = function(card, use, self)
	if not self.player:hasUsed("#moujieweiiCard") and self.player:getHujia() > 0 then
		self:sort(self.enemies, "handcard")
		self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isKongcheng() and self:objectiveLevel(enemy) > 0 then
				use.card = card
				if use.to then
					use.to:append(enemy)
				end
				return
			end
		end
	end
end

sgs.ai_use_value.moujieweiiCard = 1.8
sgs.ai_use_priority.moujieweiiCard = 2.4
sgs.ai_card_intention.moujieweiiard = 18



--

--谋甄姬
--“倾国”AI
sgs.ai_view_as.mouqingguoo = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card:isBlack() and card_place == sgs.Player_PlaceHand then
		return ("jink:mouqingguoo[%s:%s]=%d"):format(suit, number, card_id)
	end
end

function sgs.ai_cardneed.mouqingguoo(to, card)
	return to:getCards("h"):length() < 2 and card:isBlack()
end

--

--谋法正
--“眩惑”AI
local mouxuanhuoo_skill = {}
mouxuanhuoo_skill.name = "mouxuanhuoo"
table.insert(sgs.ai_skills, mouxuanhuoo_skill)
mouxuanhuoo_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("mouxuanhuooCard") or self.player:isNude() or #self.enemies == 0 then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local lightning = self:getCard("Lightning")
	if self:needToThrowArmor() then
		card_id = self.player:getArmor():getId()
	elseif self.player:getHandcardNum() > self.player:getHp() then
		if lightning and not self:willUseLightning(lightning) then
			card_id = lightning:getEffectiveId()
		else
			for _, acard in ipairs(cards) do
				if acard:isKindOf("EquipCard") or acard:isKindOf("AmazingGrace") then
					card_id = acard:getEffectiveId()
					break
				end
			end
		end
	elseif not self.player:getEquips():isEmpty() then
		local player = self.player
		if player:getWeapon() then
			card_id = player:getWeapon():getId()
		elseif player:getOffensiveHorse() then
			card_id = player:getOffensiveHorse():getId()
		elseif player:getDefensiveHorse() then
			card_id = player:getDefensiveHorse():getId()
		elseif player:getArmor() and player:getHandcardNum() <= 1 then
			card_id = player:getArmor():getId()
		end
	end
	if not card_id then
		if lightning and not self:willUseLightning(lightning) then
			card_id = lightning:getEffectiveId()
		else
			for _, acard in ipairs(cards) do
				if acard:isKindOf("EquipCard") or acard:isKindOf("AmazingGrace") then
					card_id = acard:getEffectiveId()
					break
				end
			end
		end
	end
	if not card_id then
		for _, acard in ipairs(cards) do
			if acard:isKindOf("BasicCard") and not acard:isKindOf("Peach") and not acard:isKindOf("Analeptic") then
				card_id = acard:getEffectiveId()
				break
			end
		end
	end
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("#mouxuanhuooCard:" .. card_id .. ":")
	end
end

sgs.ai_skill_use_func["#mouxuanhuooCard"] = function(card, use, self)
	if not self.player:hasUsed("#mouxuanhuooCard") and not self.player:isNude() then
		self:sort(self.enemies)
		self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 0 and enemy:getMark("&mXuan") == 0 then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.mouxuanhuooCard = 8.5
sgs.ai_use_priority.mouxuanhuooCard = 9.5
sgs.ai_card_intention.mouxuanhuooCard = 80

--“恩怨”AI
sgs.ai_skill_discard.mouenyuann = function(self)
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	table.insert(to_discard, cards[1]:getEffectiveId())
	table.insert(to_discard, cards[2]:getEffectiveId())
	table.insert(to_discard, cards[3]:getEffectiveId())
	return to_discard
end

--谋庞统
--“连环”AI（仅附加效果，待补充）
sgs.ai_skill_invoke.moulianhuann = true

--“涅槃”AI
sgs.ai_skill_invoke.mouniepann = function(self, data)
	local dying = data:toDying()
	local peaches = 1 - dying.who:getHp()
	return self:getCardsNum("Peach") + self:getCardsNum("Analeptic") < peaches
end

--谋貂蝉
--“离间”AI（待补充）




--

--谋袁绍
--“乱击”AI
local mouluanjii_skill = {}
mouluanjii_skill.name = "mouluanjii"
table.insert(sgs.ai_skills, mouluanjii_skill)
mouluanjii_skill.getTurnUseCard = function(self)
	local archery = sgs.Sanguosha:cloneCard("archery_attack")
	local first_found, second_found = false, false
	local first_card, second_card
	if self.player:getHandcardNum() >= 2 and not self.player:hasFlag("mouluanjiiUsed") then
		local cards = self.player:getHandcards()
		cards = sgs.QList2Table(cards)
		self:sortByKeepValue(cards)
		local useAll = false
		for _, enemy in ipairs(self.enemies) do
			if enemy:getHp() == 1 and not enemy:hasArmorEffect("Vine") and not self:hasEightDiagramEffect(enemy) and self:damageIsEffective(enemy, nil, self.player)
				and self:isWeak(enemy) and getCardsNum("Jink", enemy, self.player) + getCardsNum("Peach", enemy, self.player) + getCardsNum("Analeptic", enemy, self.player) == 0 then
				useAll = true
			end
		end
		for _, fcard in ipairs(cards) do
			local fvalueCard = (isCard("Peach", fcard, self.player) or isCard("ExNihilo", fcard, self.player) or isCard("ArcheryAttack", fcard, self.player))
			if useAll then fvalueCard = isCard("ArcheryAttack", fcard, self.player) end
			if not fvalueCard then
				first_card = fcard
				first_found = true
				for _, scard in ipairs(cards) do
					local svalueCard = (isCard("Peach", scard, self.player) or isCard("ExNihilo", scard, self.player) or isCard("ArcheryAttack", scard, self.player))
					if useAll then svalueCard = (isCard("ArcheryAttack", scard, self.player)) end
					if first_card ~= scard and not svalueCard then
						local card_str = ("archery_attack:mouluanjii[%s:%s]=%d+%d"):format("to_be_decided", 0,
							first_card:getId(), scard:getId())
						local archeryattack = sgs.Card_Parse(card_str)
						assert(archeryattack)
						local dummy_use = { isDummy = true }
						self:useTrickCard(archeryattack, dummy_use)
						if dummy_use.card then
							second_card = scard
							second_found = true
							break
						end
					end
				end
				if second_card then
					break
				end
			end
		end
	end
	if first_found and second_found then
		local first_id = first_card:getId()
		local second_id = second_card:getId()
		local card_str = ("archery_attack:mouluanjii[%s:%s]=%d+%d"):format("to_be_decided", 0, first_id, second_id)
		local archeryattack = sgs.Card_Parse(card_str)
		assert(archeryattack)
		return archeryattack
	end
end


--

--谋孙策
--“制霸”AI
sgs.ai_skill_invoke.mouzhibaa = true

--谋孙策-第二版
--“制霸”AI
sgs.ai_skill_invoke.mouzhibas = true

--

--FC谋孙策
--“制霸”AI
local fcmouzhiba_skill = {}
fcmouzhiba_skill.name = "fcmouzhiba"
table.insert(sgs.ai_skills, fcmouzhiba_skill)
fcmouzhiba_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#fcmouzhibaCard") or self.player:getKingdom() ~= "wu" or self.player:isKongcheng() then return end --限制用一次
	return sgs.Card_Parse("#fcmouzhibaCard:.:")
end

sgs.ai_skill_use_func["#fcmouzhibaCard"] = function(card, use, self)
	if not self.player:hasUsed("#fcmouzhibaCard") and self.player:getKingdom() == "wu" and not self.player:isKongcheng() then
		self:sort(self.enemies, "handcard")
		self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do --先找体力值和手牌数都只有1的
			if not enemy:isKongcheng() and self:objectiveLevel(enemy) > 0 and enemy:getHp() == 1 and enemy:getHandcardNum() == 1 then
				use.card = card
				if use.to then
					use.to:append(enemy)
				end
				return
			end
		end
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isKongcheng() and self:objectiveLevel(enemy) > 0 then
				use.card = card
				if use.to then
					use.to:append(enemy)
				end
				return
			end
		end
	end
end

sgs.ai_use_value.fcmouzhibaCard = 8.5
sgs.ai_use_priority.fcmouzhibaCard = 9.5
sgs.ai_card_intention.fcmouzhibaard = 80


--

--谋大乔
--“国色”AI
local mouguosee_skill = {}
mouguosee_skill.name = "mouguosee"
table.insert(sgs.ai_skills, mouguosee_skill)
mouguosee_skill.getTurnUseCard = function(self, inclusive)
	if self.player:getMark("mouguoseeUsed") >= 4 then return end
	local cards = self.player:getCards("he")
	for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
		local c = sgs.Sanguosha:getCard(id)
		cards:prepend(c)
	end
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	local card = nil
	local has_weapon, has_armor = false, false
	for _, acard in ipairs(cards) do
		if acard:isKindOf("Weapon") and not (acard:getSuit() == sgs.Card_Diamond) then has_weapon = true end
	end
	for _, acard in ipairs(cards) do
		if acard:isKindOf("Armor") and not (acard:getSuit() == sgs.Card_Diamond) then has_armor = true end
	end
	for _, acard in ipairs(cards) do
		if (acard:getSuit() == sgs.Card_Diamond) and ((self:getUseValue(acard) < sgs.ai_use_value.Indulgence) or inclusive) then
			local shouldUse = true
			if acard:isKindOf("Armor") then
				if not self.player:getArmor() then
					shouldUse = false
				elseif self.player:hasEquip(acard) and not has_armor and self:evaluateArmor() > 0 then
					shouldUse = false
				end
			end
			if acard:isKindOf("Weapon") then
				if not self.player:getWeapon() then
					shouldUse = false
				elseif self.player:hasEquip(acard) and not has_weapon then
					shouldUse = false
				end
			end
			if shouldUse then
				card = acard
				break
			end
		end
	end
	if not card then return nil end
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	local card_str = ("indulgence:mouguosee[diamond:%s]=%d"):format(number, card_id)
	local indulgence = sgs.Card_Parse(card_str)
	assert(indulgence)
	return indulgence
end

function sgs.ai_cardneed.mouguosee(to, card)
	return card:getSuit() == sgs.Card_Diamond
end

sgs.mouguosee_suit_value = {
	diamond = 4.2
}

--“流离”AI
--[[sgs.ai_skill_use["@@mouliulii"] = sgs.ai_skill_use["@@liuli"]

sgs.ai_card_intention.mouliuliiCard = function(self, card, from, to)
	sgs.ai_mouliulii_effect = true
	if not hasExplicitRebel(self.room) then sgs.ai_mouliulii_user = from
	else sgs.ai_mouliulii_user = nil end
end

function sgs.ai_slash_prohibit.mouliulii(self, from, to, card)
	if self:isFriend(to, from) then return false end
	if from:hasFlag("NosJiefanUsed") then return false end
	if to:isNude() then return false end
	for _, friend in ipairs(self:getFriendsNoself(from)) do
		if to:canSlash(friend, card) and self:slashIsEffective(card, friend, from) then return true end
	end
end

function sgs.ai_cardneed.mouliulii(to, card)
	return to:getCards("he"):length() <= 2
end

sgs.ai_skill_playerchosen.mouliulii = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
	    if self:isFriend(p) and not p:hasFlag("mouliulii_DontChooseMe") then
		    return p
		end
	end
	return nil
end]]

sgs.ai_skill_invoke["mouliuliiextraPlay"] = true --白嫖，岂不美哉？
