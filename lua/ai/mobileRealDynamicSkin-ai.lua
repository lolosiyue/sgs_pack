--神甘宁（万人辟易）
  --“魄袭”AI
local mrds_poxi_skill = {}
mrds_poxi_skill.name = "mrds_poxi"
table.insert(sgs.ai_skills, mrds_poxi_skill)
mrds_poxi_skill.getTurnUseCard = function(self, inclusive)
	if not self.player:hasUsed("#mrds_poxi") then
		return sgs.Card_Parse("#mrds_poxi:.:")
	end
end

sgs.ai_skill_use_func["#mrds_poxi"] = function(card, use, self)
	local target = nil
	self:updatePlayers()
	self:sort(self.enemies, "handcard")
	for _, enemy in ipairs(self.enemies) do
		target = enemy
	end
	if target == nil then return end
	self.room:setTag("mrds_poxi_target", sgs.QVariant(target:objectName()))
	if target:getHandcardNum() > 0 then
		use.card = card
		if use.to then use.to:append(target) end
	end
end

sgs.ai_skill_use["@mrds_poxi"] = function(self, prompt)
	local target_name = self.room:getTag("mrds_poxi_target"):toString()
	self.room:removeTag("mrds_poxi_target")
	local target = nil
	for _, p in sgs.qlist(self.room:getAlivePlayers()) do
		if p:objectName() == target_name then
			target = p
			break
		end
	end
	if target then
		local target_handcards = sgs.QList2Table(target:getCards("h"))
		self:sortByUseValue(target_handcards, inverse)
		local handcards = sgs.QList2Table(self.player:getCards("h"))
		local discard_cards = {}
		local spade_check = true
		local heart_check = true
		local club_check = true
		local diamond_check = true
		local target_discard_count = 0
		for _, c in ipairs(target_handcards) do
			if spade_check and c:getSuit() == sgs.Card_Spade then
				spade_check = false
				table.insert(discard_cards, c:getEffectiveId())
			elseif heart_check and c:getSuit() == sgs.Card_Heart then
				heart_check = false
				table.insert(discard_cards, c:getEffectiveId())
			elseif club_check and c:getSuit() == sgs.Card_Club then
				club_check = false
				table.insert(discard_cards, c:getEffectiveId())
			elseif diamond_check and c:getSuit() == sgs.Card_Diamond then
				diamond_check = false
				table.insert(discard_cards, c:getEffectiveId())
			end
			target_discard_count = #discard_cards
		end
		for _, c in ipairs(handcards) do
			if not c:isKindOf("Peach")
			and not c:isKindOf("Duel")
			and not c:isKindOf("Indulgence")
			and not c:isKindOf("SupplyShortage")
			and not (self:getCardsNum("Jink") == 1 and c:isKindOf("Jink"))
			and not (self:getCardsNum("Analeptic") == 1 and c:isKindOf("Analeptic"))
			then
				if spade_check and c:getSuit() == sgs.Card_Spade then
					spade_check = false
					table.insert(discard_cards, c:getEffectiveId())
				elseif heart_check and c:getSuit() == sgs.Card_Heart then
					heart_check = false
					table.insert(discard_cards, c:getEffectiveId())
				elseif club_check and c:getSuit() == sgs.Card_Club then
					club_check = false
					table.insert(discard_cards, c:getEffectiveId())
				elseif diamond_check and c:getSuit() == sgs.Card_Diamond then
					diamond_check = false
					table.insert(discard_cards, c:getEffectiveId())
				end
			end
		end
		if target_discard_count == 4 and not self.player:isWounded() then return "." end
		if 4 - target_discard_count == 1 and self.player:getHandcardNum() > self.player:getMaxCards() then return "." end
		
		if #discard_cards == 4 then
			return string.format("#mrds_poxi:%s:", table.concat(discard_cards, "+"))
		end
	end
	return "."
end

sgs.ai_use_priority["mrds_poxi"] = 3
sgs.ai_use_value["mrds_poxi"] = 3
sgs.ai_card_intention["mrds_poxi"] = 50

  --“劫营”AI
sgs.ai_skill_playerchosen["mrds_jieying"] = function(self, targets)
	self:updatePlayers()
	self:sort(self.enemies, "handcard")
	self.enemies = sgs.reverse(self.enemies)
	if self:isWeak() then
		for _, enemy in ipairs(self.enemies) do
			if #self.friends_noself == 0 and not enemy:inMyAttackRange(self.player) and enemy:faceUp() and not enemy:hasSkills("ol_mingjian|mingjian|nosrende|rende|olrende|ol_rende|luanji") then
				return enemy
			end
		end
	end
	for _, enemy in ipairs(self.enemies) do
		if enemy:containsTrick("indulgence") and enemy:getHp() > 1 and not enemy:hasSkills("ol_mingjian|mingjian|nosrende|rende|olrende|ol_rende|luanji") then
			return enemy
		end
	end
	for _, enemy in ipairs(self.enemies) do
		if enemy:faceUp() and enemy:getHandcardNum() > 2 and not enemy:hasSkills("ol_mingjian|mingjian|nosrende|rende|olrende|ol_rende|luanji") then
			return enemy
		end
	end
	return nil
end

sgs.ai_playerchosen_intention["mrds_jieying"] = 70

--界徐盛（破军杀将）
  --“破军”AI
sgs.ai_skill_invoke["mrds_pojun"] = function(self, data)
    local target = data:toPlayer()
    if not self:isFriend(target) then return true end
    return false
end

sgs.ai_skill_choice["mrds_pojun"] = function(self, choices, data)
	--[[local items = choices:split("+")
	return items[#items]]return #(choices:split("+"))
end

--神赵云（战龙在野）
  --“龙魂”AI
sgs.ai_view_as["mrds_longhun"] = function(card, player, card_place, class_name)
	local current = player:getRoom():getCurrent()
	local usable_cards = sgs.QList2Table(player:getCards("he"))
	if player:getPile("wooden_ox"):length() > 0 then
		for _, id in sgs.qlist(player:getPile("wooden_ox")) do
			table.insert(usable_cards, sgs.Sanguosha:getCard(id))
		end
	end
	local two_club_cards = {}
	local two_heart_cards = {}
	for _, c in ipairs(usable_cards) do
		if c:getSuit() == sgs.Card_Club and #two_club_cards < 2 then
			table.insert(two_club_cards, c:getEffectiveId())
		elseif c:getSuit() == sgs.Card_Heart and #two_heart_cards < 2 then
			table.insert(two_heart_cards, c:getEffectiveId())
		end
	end
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if #two_club_cards == 2 and current and not current:isNude() and current:getWeapon() and current:getWeapon():isKindOf("Crossbow") then
		return ("jink:mrds_longhunBuff[%s:%s]=%d+%d"):format("to_be_decided", 0, two_club_cards[1], two_club_cards[2])
	elseif card:getSuit() == sgs.Card_Club then
		return ("jink:mrds_longhun[%s:%s]=%d"):format(suit, number, card_id)
	end
	local dying = player:getRoom():getCurrentDyingPlayer()
	if #two_heart_cards == 2 and dying and not dying:hasSkill("new_juejing") and player:getMark("Global_PreventPeach") == 0 then
		return ("peach:mrds_longhunBuff[%s:%s]=%d+%d"):format("to_be_decided", 0, two_heart_cards[1], two_heart_cards[2])
	elseif card:getSuit() == sgs.Card_Heart and player:getMark("Global_PreventPeach") == 0 then
		return ("peach:mrds_longhun[%s:%s]=%d"):format(suit, number, card_id)
	end
	if card:getSuit() == sgs.Card_Diamond and not (card:isKindOf("WoodenOx") and player:getPile("wooden_ox"):length() > 0) then
		return ("fire_slash:mrds_longhun[%s:%s]=%d"):format(suit, number, card_id)
	elseif card:getSuit() == sgs.Card_Spade then
		return ("nullification:mrds_longhun[%s:%s]=%d"):format(suit, number, card_id)
	end
end

sgs.mrds_longhun_suit_value = sgs.longhun_suit_value

function sgs.ai_cardneed.mrds_longhun(to, card, self)
	if to:getCardCount() > 3 then return false end
	if to:isNude() then return true end
	return card:getSuit() == sgs.Card_Heart or card:getSuit() == sgs.Card_Spade
end

sgs.ai_need_damaged.mrds_longhun = function(self, attacker, player)
	if player:getHp() > 1 and player:hasSkill("new_juejing") then return true end
end

local mrds_longhun_skill = {}
mrds_longhun_skill.name = "mrds_longhun"
table.insert(sgs.ai_skills, mrds_longhun_skill)
mrds_longhun_skill.getTurnUseCard = function(self, inclusive)
	local usable_cards = sgs.QList2Table(self.player:getCards("h"))
	local equips = sgs.QList2Table(self.player:getCards("e"))
	for _, e in ipairs(equips) do
		if e:isKindOf("DefensiveHorse") or e:isKindOf("OffensiveHorse") then
			table.insert(usable_cards, e)
		end
	end
	if self.player:getPile("wooden_ox"):length() > 0 then
		for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
			table.insert(usable_cards, sgs.Sanguosha:getCard(id))
		end
	end
	self:sortByUseValue(usable_cards, true)
	local two_diamond_cards = {}
	for _, c in ipairs(usable_cards) do
		if c:getSuit() == sgs.Card_Diamond and #two_diamond_cards < 2 and not c:isKindOf("Peach") and not (c:isKindOf("WoodenOx") and self.player:getPile("wooden_ox"):length() > 0) then
			table.insert(two_diamond_cards, c:getEffectiveId())
		end
	end
	if #two_diamond_cards == 2 and self:slashIsAvailable() and self:getOverflow() > 1 then
		return sgs.Card_Parse(("fire_slash:mrds_longhunBuff[%s:%s]=%d+%d"):format("to_be_decided", 0, two_diamond_cards[1], two_diamond_cards[2]))
	end
	for _, c in ipairs(usable_cards) do
		if c:getSuit() == sgs.Card_Diamond and self:slashIsAvailable() and not c:isKindOf("Peach") and not (c:isKindOf("Jink") and self:getCardsNum("Jink") < 3) and not (c:isKindOf("WoodenOx") and self.player:getPile("wooden_ox"):length() > 0) then
			return sgs.Card_Parse(("fire_slash:mrds_longhun[%s:%s]=%d"):format(c:getSuitString(), c:getNumberString(), c:getEffectiveId()))
		end
	end
	for _, c in ipairs(usable_cards) do
		if c:getSuit() == sgs.Card_Heart and self.player:getMark("Global_PreventPeach") == 0 and not c:isKindOf("Peach") then
			return sgs.Card_Parse(("peach:mrds_longhun[%s:%s]=%d"):format(c:getSuitString(), c:getNumberString(), c:getEffectiveId()))
		end
	end
end

sgs.ai_choicemade_filter.cardChosen.mrds_longhun = sgs.ai_choicemade_filter.cardChosen.snatch

--界关羽（啸风从龙）
  --“武圣”AI
sgs.ai_view_as.mrds_wusheng = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place ~= sgs.Player_PlaceSpecial and card:isRed() and not card:isKindOf("Peach") and not card:hasFlag("using") then
		return ("slash:mrds_wusheng[%s:%s]=%d"):format(suit, number, card_id)
	end
end

local mrds_wusheng_skill = {}
mrds_wusheng_skill.name = "mrds_wusheng"
table.insert(sgs.ai_skills, mrds_wusheng_skill)
mrds_wusheng_skill.getTurnUseCard = function(self, inclusive)
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
			if  not enemy:hasArmorEffect("EightDiagram") and self.player:distanceTo(enemy) <= self.player:getAttackRange()
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
			if  not enemy:hasArmorEffect("EightDiagram") and self.player:distanceTo(enemy) <= self.player:getAttackRange() then
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
		local card_str = ("slash:mrds_wusheng[%s:%s]=%d"):format(suit, number, card_id)
		local slash = sgs.Card_Parse(card_str)
		assert(slash)
		return slash
	end
end

function sgs.ai_cardneed.mrds_wusheng(to, card)
	return to:getHandcardNum() < 3 and card:isRed()
end

  --“义绝”AI
local mrds_yijue_skill = {}
mrds_yijue_skill.name = "mrds_yijue"
table.insert(sgs.ai_skills, mrds_yijue_skill)
mrds_yijue_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("mrds_yijueCard") or self.player:isNude() or #self.enemies == 0 then return end
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
		if player:getWeapon() then card_id = player:getWeapon():getId()
		elseif player:getOffensiveHorse() then card_id = player:getOffensiveHorse():getId()
		elseif player:getDefensiveHorse() then card_id = player:getDefensiveHorse():getId()
		elseif player:getArmor() and player:getHandcardNum() <= 1 then card_id = player:getArmor():getId()
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
	    return sgs.Card_Parse("#mrds_yijueCard:"..card_id..":")
	end
end

sgs.ai_skill_use_func["#mrds_yijueCard"] = function(card, use, self)
    if not self.player:hasUsed("#mrds_yijueCard") then
        self:sort(self.enemies)
	    self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
		    if self:objectiveLevel(enemy) > 0 and not enemy:isKongcheng() then
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
	end
end

sgs.ai_use_value.mrds_yijueCard = 8.5
sgs.ai_use_priority.mrds_yijueCard = 9.5
sgs.ai_card_intention.mrds_yijueCard = 80

    --“义绝”展示AI
sgs.ai_cardshow.mrds_yijue = function(self, requestor)
	local cards, red = sgs.QList2Table(self.player:getCards("h")), {}
	self:sortByUseValue(cards, true)
	for _,c in ipairs(cards) do
		if c:isRed() then
			table.insert(red, c)
		end
	end
	if self:isFriend(requestor) and #red > 0 and (self.player:getLostHp() > 0 or self:getOverflow() > 0) then
		return red[1]
	end
	return cards[1]
end

--界李儒（鸩杀少帝）
  --“绝策”AI
sgs.ai_skill_invoke.mrds_juece = true

sgs.ai_skill_playerchosen.mrds_juece = function(self, targets)
	return sgs.ai_skill_playerchosen.mobilejuece(self, targets)
end

sgs.ai_playerchosen_intention.mrds_juece = function(self, from, to)
	return sgs.ai_playerchosen_intention.mobilejuece(self, from, to)
end

  --“灭计”AI
local mrds_mieji_skill = {}
mrds_mieji_skill.name = "mrds_mieji"
table.insert(sgs.ai_skills, mrds_mieji_skill)
mrds_mieji_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("mrds_miejiCard") or self.player:isKongcheng() then return end
	return sgs.Card_Parse("#mrds_miejiCard:.:")
end

sgs.ai_skill_use_func["#mrds_miejiCard"] = function(card, use, self)
	local nextAlive = self.player:getNextAlive()
	local hasLightning, hasIndulgence, hasSupplyShortage
	local tricks = nextAlive:getJudgingArea()
	if not tricks:isEmpty() and not nextAlive:containsTrick("YanxiaoCard") and not nextAlive:hasSkill("qianxi") then
		local trick = tricks:at(tricks:length() - 1)
		if self:hasTrickEffective(trick, nextAlive) then
			if trick:isKindOf("Lightning") then hasLightning = true
			elseif trick:isKindOf("Indulgence") then hasIndulgence = true
			elseif trick:isKindOf("SupplyShortage") then hasSupplyShortage = true
			end
		end
	end
	local putcard
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	for _, card in ipairs(cards) do
		if card:isBlack() and card:isKindOf("TrickCard") then
			if hasLightning and card:getSuit() == sgs.Card_Spade and card:getNumber() >= 2 and card:getNumber() <= 9 then
				if self:isEnemy(nextAlive) then
					putcard = card break
				else continue
				end
			end
			if hasSupplyShortage and card:getSuit() == sgs.Card_Club then
				if self:isFriend(nextAlive) then
					putcard = card break
				else continue
				end
			end
			if not putcard then
				putcard = card break
			end
		end
	end
	local target
	for _, enemy in ipairs(self.enemies) do
		if self:needKongcheng(enemy) and enemy:getHandcardNum() <= 2 then continue end
		if not enemy:isNude() then
			target = enemy break
		end
	end
	if not target then
		for _, friend in ipairs(self.friends_noself) do
			if self:needKongcheng(friend) and friend:getHandcardNum() < 2 and not friend:isKongcheng() then
				target = friend break
			end
		end
	end
	if putcard and target and not self.player:hasUsed("mrds_miejiCard") and not self.player:isKongcheng() then
		use.card = sgs.Card_Parse("#mrds_miejiCard:" .. putcard:getEffectiveId())
		if use.to then use.to:append(target) end
		return
	end
end

sgs.ai_use_priority.mrds_miejiCard = sgs.ai_use_priority.Dismantlement + 1
sgs.ai_card_intention.mrds_miejiCard = function(self, card, from, tos)
	for _, to in ipairs(tos) do
		if self:needKongcheng(to) and to:getHandcardNum() <= 2 then continue end
		sgs.updateIntention(from, to, 10)
	end
end

  --“焚城”AI
local mrds_fencheng_skill = {}
mrds_fencheng_skill.name = "mrds_fencheng"
table.insert(sgs.ai_skills, mrds_fencheng_skill)
mrds_fencheng_skill.getTurnUseCard = function(self)
	if self.player:getMark("@mrds_fencheng") == 0 then return false end
	return sgs.Card_Parse("#mrds_fenchengCard:.:")
end

sgs.ai_skill_use_func["#mrds_fenchengCard"] = function(card, use, self)
	local value = 0
	local neutral = 0
	local damage = { from = self.player, damage = 2, nature = sgs.DamageStruct_Fire }
	local lastPlayer = self.player
	for i, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		damage.to = p
		if self:damageIsEffective_(damage) then
			if sgs.evaluatePlayerRole(p, self.player) == "neutral" then neutral = neutral + 1 end
			local v = 4
			if (self:getDamagedEffects(p, self.player) or self:needToLoseHp(p, self.player)) and getCardsNum("Peach", p, self.player) + p:getHp() > 2 then
				v = v - 6
			elseif lastPlayer:objectName() ~= self.player:objectName() and lastPlayer:getCardCount(true) < p:getCardCount(true) then
				v = v - 4
			elseif lastPlayer:objectName() == self.player:objectName() and not p:isNude() then
				v = v - 4
			end
			if self:isFriend(p) then
				value = value - v - p:getHp() + 2
			elseif self:isEnemy(p) then
				value = value + v + p:getLostHp() - 1
			end
			if p:isLord() and p:getHp() <= 2
				and (self:isEnemy(p, lastPlayer) and p:getCardCount(true) <= lastPlayer:getCardCount(true)
					or lastPlayer:objectName() == self.player:objectName() and (not p:canDiscard(p, "he") or p:isNude())) then
				if not self:isEnemy(p) then
					if self:getCardsNum("Peach") + getCardsNum("Peach", p, self.player) + p:getHp() <= 2 then return end
				else
					use.card = card
					return
				end
			end
		end
	end
	if neutral > self.player:aliveCount() / 2 then return end
	if value > 0 then
		use.card = card
	end
end

sgs.ai_use_priority.mrds_fenchengCard = 9.1

sgs.ai_skill_discard.mrds_fencheng = function(self, discard_num, min_num, optional, include_equip)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	local current = self.room:getCurrent()
	local damage = { from = current, damage = 2, nature = sgs.DamageStruct_Fire }
	local to_discard = {}
	local length = min_num
	local peaches = 0
	local nextPlayer = self.player:getNextAlive()
	if self:isEnemy(nextPlayer) and self.player:getCardCount(true) > nextPlayer:getCardCount(true) and self.player:getCardCount(true) > length then
		length = tonumber(nextPlayer:getCardCount(true))
	end
	for _, c in ipairs(cards) do
		if self.player:canDiscard(self.player, c:getEffectiveId()) then
			table.insert(to_discard, c:getEffectiveId())
			if isCard("Peach", c, self.player) then peaches = peaches + 1 end
			if #to_discard == length then break end
		end
	end
	if peaches > 2 then
		return {}
	elseif peaches == 2 and self.player:getHp() > 1 and length == min_num then
		for _, friend in ipairs(self.friends_noself) do
			damage.to = friend
			if friend:getHp() <= 2 and self:damageIsEffective_(damage) then return {} end
		end
	end
	if nextPlayer:isLord() and self.role ~= "rebel" and nextPlayer:getHandcardNum() < min_num
		and not self:getDamagedEffects(nextPlayer, current) and not self:needToLoseHp(nextPlayer, current) then
		if nextPlayer:getHp() + getCardsNum("Peach", nextPlayer, self.player) + self:getCardsNum("Peach") <= 2 then return {} end
		if self.player:getHp() > nextPlayer:getHp() and self.player:getHp() > 2 then return {} end
	end
	return to_discard
end