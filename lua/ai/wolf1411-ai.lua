sgs.ai_skill_playerchosen.tengxun = function(self, targets)
	local player_table = {}
	local players = sgs.SPlayerList()
	for _, enemy in ipairs(self.enemies) do
		if enemy:getHandcardNum() > self.player:getHandcardNum() and self.player:canDiscard(enemy, "h") then
			players:append(enemy)
		end
	end
	local enemies = {}
	if players:isEmpty() then return nil end
	for _, player in sgs.qlist(players) do
		if self:isEnemy(player) then table.insert(enemies, player) end
	end

	self:sort(enemies, "defense")

	for _, enemy in ipairs(enemies) do
		local cards = sgs.QList2Table(enemy:getHandcards())
		local flag = string.format("%s_%s_%s", "visible", self.player:objectName(), enemy:objectName())
		if #cards <= 2 and not enemy:isKongcheng() and not (enemy:hasSkills("tuntian+zaoxian") and enemy:getPhase() == sgs.Player_NotActive) then
			for _, cc in ipairs(cards) do
				if (cc:hasFlag("visible") or cc:hasFlag(flag)) and (cc:isKindOf("Peach") or cc:isKindOf("Analeptic")) and (self.player:canDiscard(enemy, cc:getId())) then
					table.insert(player_table, enemy)
				end
			end
		end
	end

	self:sort(enemies, "handcard")
	for _, enemy in ipairs(enemies) do
		if (self.player:canDiscard(enemy, "h")) and not self:doNotDiscard(enemy, "h") then
			table.insert(player_table, enemy)
		end
	end
	if #player_table == 0 then return nil else return player_table[1] end
end

--sgs.ai_playerchosen_intention.tengxun = 40

wolfchicheng_skill = {}
wolfchicheng_skill.name = "wolfchicheng"
table.insert(sgs.ai_skills, wolfchicheng_skill)
wolfchicheng_skill.getTurnUseCard = function(self)
	if self.player:getMark("@chicheng") < 1 then return end
	if not self.player:isWounded() then return end
	if (#self.friends <= #self.enemies and sgs.turncount > 2 and self.player:getLostHp() > 0) or (sgs.turncount > 1 and self:isWeak()) or #self.friends > 2 then
		return sgs.Card_Parse("#wolfchichengCard:.:")
	end
end

sgs.ai_skill_use_func["#wolfchichengCard"] = function(card, use, self)
	use.card = card
	local min = math.min(3, #self.friends)
	for i = 1, min - 1 do
		if use.to then use.to:append(self.friends[i]) end
	end
end

sgs.ai_card_intention.wolfchichengCard = -80
sgs.ai_use_priority.wolfchichengCard = 9.31


sgs.ai_skill_invoke.xionglie = function(self, data)
	if self.player:getPile("incantation"):length() > 0 then
		local card = sgs.Sanguosha:getCard(self.player:getPile("incantation"):first())
		if not self.player:getJudgingArea():isEmpty() and not self.player:containsTrick("YanxiaoCard") and not self:hasWizard(self.enemies, true) then
			local trick = self.player:getJudgingArea():last()
			if trick:isKindOf("Indulgence") then
				if card:getSuit() == sgs.Card_Heart or (self.player:hasSkill("hongyan") and card:getSuit() == sgs.Card_Spade) then return false end
			elseif trick:isKindOf("SupplyShortage") then
				if card:getSuit() == sgs.Card_Club then return false end
			end
		end
		local zhangbao = self.room:findPlayerBySkillName("yingbing")
		if zhangbao and self:isEnemy(zhangbao) and not zhangbao:hasSkill("manjuan")
			and (card:isRed() or (self.player:hasSkill("hongyan") and card:getSuit() == sgs.Card_Spade)) then
			return false
		end
	end
	for _, p in ipairs(self.enemies) do
		if self.player:distanceTo(p) == 1 and not p:isKongcheng() then
			return true
		end
	end
	return false
end



sgs.ai_skill_playerchosen.xionglie = function(self, targets)
	local enemies = {}
	local slash = self:getCard("Slash") or sgs.Sanguosha:cloneCard("slash")
	slash:deleteLater()
	for _, target in sgs.qlist(targets) do
		if self:isEnemy(target) and not target:isKongcheng() then
			table.insert(enemies, target)
		end
	end
	local friends = {}
	for _, target in sgs.qlist(targets) do
		if self:isFriend(target) and not target:isKongcheng() and (target:hasSkill("lianying") or target:hasSkill("tuntian")) then
			table.insert(friends, target)
		end
	end
	if #enemies == 1 then
		return enemies[1]
	else
		self:sort(enemies, "defense")
		for _, enemy in ipairs(enemies) do
			if enemy:hasSkill("qingguo") and self:slashIsEffective(slash, enemy) then return enemy end
		end
		for _, enemy in ipairs(enemies) do
			if enemy:hasSkill("kanpo") then return enemy end
		end
		for _, enemy in ipairs(enemies) do
			if getKnownCard(enemy, self.player, "Jink", false, "h") > 0 and self:slashIsEffective(slash, enemy) and self:isGoodTarget(enemy, self.enemies) then
				return
					enemy
			end
		end
		for _, enemy in ipairs(enemies) do
			if getKnownCard(enemy, self.player, "Peach", true, "h") > 0 or enemy:hasSkill("jijiu") then return enemy end
		end
		for _, enemy in ipairs(enemies) do
			if getKnownCard(enemy, self.player, "Jink", false, "h") > 0 and self:slashIsEffective(slash, enemy) then
				return
					enemy
			end
		end
		for _, enemy in ipairs(enemies) do
			if enemy:hasSkill("longhun") then return enemy end
		end
		return enemies[1]
	end
	if #enemies == 0 then
		return friends:first()
	end
	return targets:first()
end

sgs.ai_playerchosen_intention.xionglie = function(self, from, to)
	local intention = 80
	if (to:hasSkill("lianying") or to:hasSkill("tuntian")) then
		intention = 0
	end
	sgs.updateIntention(from, to, intention)
end

sgs.ai_skill_cardask["jieffan"] = function(self, data, pattern, target)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	local c
	local target = data:toDying().who
	local damage = data:toDying().damage
	for _, card in ipairs(cards) do
		if card:isKindOf("TrickCard") then
			c = card
			break
		end
	end
	if c and target then
		if self:isEnemy(target) then
			return "$" .. c:getEffectiveId()
		end
		if self:isFriend(target) and target:getRole() == "rebel" then
			if damage and damage.from and self:isFriend(damage.from) then return "." end
			for _, friend in ipairs(self.friends) do
				if getKnownCard(friend, self.player, "Peach", true, "h") > 0 then return "." end
				if friend:getHandcardNum() > 3 then return "." end
			end
		end
	end
	return "."
end





local tieti_skill = {}
tieti_skill.name = "tieti"
table.insert(sgs.ai_skills, tieti_skill)
tieti_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#tietiCard") then return end
	if #self.enemies < 1 then return end
	return sgs.Card_Parse("#tietiCard:.:")
end

sgs.ai_skill_use_func["#tietiCard"] = function(card, use, self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	local to_discard = {}
	self:sortByKeepValue(cards)
	for _, card in ipairs(cards) do
		if card:isBlack() and #to_discard < 2 then
			table.insert(to_discard, card:getEffectiveId())
		end
	end
	if #to_discard == 2 then
		self:sort(self.enemies)
		local target
		for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and self:damageIsEffective(enemy) then
				if self.player:distanceTo(enemy) == 1 then
					target = enemy
					break
				end
			end
		end
		if target then
			local card_str = string.format("#tietiCard:%s:", table.concat(to_discard, "+"))
			use.card = sgs.Card_Parse(card_str)
			if use.to then use.to:append(target) end
			return
		end
	end
end

sgs.ai_use_value["#tietiCard"] = 2.5
sgs.ai_card_intention["#tietiCard"] = 80
sgs.dynamic_value.damage_card["#tietiCard"] = true


sgs.ai_skill_invoke.duanqiao = function(self, data)
	local target = data:toDamage().from
	if target then
		if self:isFriend(target) then
			if self:needToThrowArmor(target) and (self.player:canDiscard(target, target:getArmor():getEffectiveId())) then
				return true
			end
			if target:hasSkill("kongcheng") and target:getHandcardNum() == 1 and self:getEnemyNumBySeat(self.player, target) > 0
				and target:getHp() <= 2 and (self.player:canDiscard(target, "h")) then
				return true
			end
		elseif self:isEnemy(target) then
			if self.player:canDiscard(target, "e") then
				local dangerous = self:getDangerousCard(target)
				if dangerous and (self.player:canDiscard(target, dangerous)) then
					return true
				end
				if target:hasArmorEffect("eight_diagram") and target:getArmor() and not self:needToThrowArmor(target) and self.player:canDiscard(target, target:getArmor():getEffectiveId()) then
					return true
				end
				if self.player:canDiscard(target, "e") then
					local valuable = self:getValuableCard(target)
					if valuable and (self.player:canDiscard(target, valuable)) then
						return true
					end
				end
				if target:hasSkills("jijiu|beige|mingce|weimu|qingcheng") and not self:doNotDiscard(target, "e") then
					if target:getDefensiveHorse() and (self.player:canDiscard(target, target:getDefensiveHorse():getEffectiveId())) then return true end
					if target:getArmor() and not self:needToThrowArmor(target) and (self.player:canDiscard(target, target:getArmor():getEffectiveId())) then return true end
					if target:getOffensiveHorse() and (not target:hasSkill("jijiu") or target:getOffensiveHorse():isRed()) and (self.player:canDiscard(target, target:getOffensiveHorse():getEffectiveId())) then
						return true
					end
					if target:getWeapon() and (not target:hasSkill("jijiu") or target:getWeapon():isRed()) and (self.player:canDiscard(target, target:getWeapon():getEffectiveId())) then
						table.insert(player_table, target)
					end
				end
				if self.player:canDiscard(target, "h") then
					local cards = sgs.QList2Table(target:getHandcards())
					local flag = string.format("%s_%s_%s", "visible", self.player:objectName(), target:objectName())
					if #cards <= 2 and not target:isKongcheng() and not (target:hasSkills("tuntian+zaoxian") and target:getPhase() == sgs.Player_NotActive) then
						for _, cc in ipairs(cards) do
							if (cc:hasFlag("visible") or cc:hasFlag(flag)) and (cc:isKindOf("Peach") or cc:isKindOf("Analeptic")) and (not isDiscard or self.player:canDiscard(target, cc:getId())) then
								return true
							end
						end
					end
				end
				if target:hasEquip() and not self:doNotDiscard(target, "e") and (self.player:canDiscard(target, "e")) then
					return true
				end
				if self.player:canDiscard(target, "h") then
					if (self.player:canDiscard(target, "h")) and not self:doNotDiscard(target, "h") then
						return true
					end
				end
			end
		end
	end
	return false
end




--[[
function SmartAI:useCardDrowning(card, use)
	if self.player:hasSkill("noswuyan") or (self.player:hasSkill("wuyan") and not self.player:hasSkill("jueqing")) then return end
	self:sort(self.enemies)
	local targets, equip_enemy = {}, {}
	for _, enemy in ipairs(self.enemies) do
		if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName()))
			and self:hasTrickEffective(card, enemy) and self:damageIsEffective(enemy) and self:canAttack(enemy)
			and not self:getDamagedEffects(enemy, self.player) and not self:needToLoseHp(enemy, self.player) then
			if enemy:hasEquip() then table.insert(equip_enemy, enemy)
			else table.insert(targets, enemy)
			end
		end
	end
	if not (self.player:hasSkill("wumou") and self.player:getMark("@wrath") < 7) then
		if #equip_enemy > 0 then
			local function cmp(a, b)
				return a:getEquips():length() >= b:getEquips():length()
			end
			table.sort(equip_enemy, cmp)
			for _, enemy in ipairs(equip_enemy) do
				if not self:needToThrowArmor(enemy) then table.insert(targets, enemy) end
			end
		end
		for _, friend in ipairs(self.friends_noself) do
			if not (not use.current_targets or not table.contains(use.current_targets, friend:objectName())) and self:needToThrowArmor(friend) then
				table.insert(targets, friend)
			end
		end
	end
	if #targets > 0 then
		local targets_num = 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card)
		if use.isDummy and use.extra_target then targets_num = targets_num + use.extra_target end
		local lx = self.room:findPlayerBySkillName("huangen")
		use.card = card
		if use.to then
			for i = 1, targets_num, 1 do
				if not (use.to:length() > 0 and targets[i]:hasSkill("danlao"))
					and not (use.to:length() > 0 and lx and self:isFriend(lx, targets[i]) and self:isEnemy(lx) and lx:getHp() > targets_num / 2) then
					use.to:append(targets[i])
					if #targets == i then break end
				end
			end
		end
	end
end]]

local shuiyan_skill = {}
shuiyan_skill.name = "shuiyan"
table.insert(sgs.ai_skills, shuiyan_skill)
shuiyan_skill.getTurnUseCard = function(self)
	if self.player:getCards("he"):length() < 3 then return end
	if not self.player:hasUsed("#shuiyanCard") then
		return sgs.Card_Parse("#shuiyanCard:.:")
	end
end

sgs.ai_skill_use_func["#shuiyanCard"] = function(card, use, self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	local to_discard = {}
	self:sortByKeepValue(cards)
	for _, card in ipairs(cards) do
		if #to_discard < 3 then
			if #to_discard > 0 then
				local same = false
				for i = 1, #to_discard, 1 do
					if card:getSuit() == sgs.Sanguosha:getCard(to_discard[i]):getSuit() then
						same = true
						break
					end
				end
				if not same then
					table.insert(to_discard, card:getEffectiveId())
				end
			else
				table.insert(to_discard, card:getEffectiveId())
			end
		end
	end
	if #to_discard == 3 then
		self:sort(self.enemies)

		local players = self.room:getOtherPlayers(self.player)
		if players:isEmpty() then return nil end
		local value_e = 0
		local value_f = 0
		for _, player in sgs.qlist(players) do
			local value = 0
			for _, equip in sgs.qlist(player:getEquips()) do
				if equip:isKindOf("Weapon") then
					value = value + self:evaluateWeapon(equip)
				elseif equip:isKindOf("Armor") then
					value = value + self:evaluateArmor(equip)
					if self:needToThrowArmor() then value = value - 5 end
				elseif equip:isKindOf("OffensiveHorse") then
					value = value + 2.5
				elseif equip:isKindOf("DefensiveHorse") then
					value = value + 5
				end
			end
			if self:isEnemy(player) then
				value_e = value_e + value
			elseif self:isFriend(player) then
				value_f = value_f + value
			end
		end
		if value_e > value_f then
			local card_str = string.format("#shuiyanCard:%s:", table.concat(to_discard, "+"))
			local acard = sgs.Card_Parse(card_str)
			use.card = acard
			return
		end
	end
end

sgs.ai_card_intention.shuiyan = function(self, card, from, tos)
	for _, to in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if self:needToThrowArmor(to) then
		else
			sgs.updateIntention(from, to, 80)
		end
	end
end

sgs.ai_use_value.shuiyan = 5
sgs.ai_use_priority.shuiyan = 7



sgs.ai_skill_choice.shuiyan = function(self, choices, data)
	local target = data:toPlayer()
	if not self:damageIsEffective(self.player, sgs.DamageStruct_Normal, target)
		or self:needToLoseHp(self.player, target)
		or self:getDamagedEffects(self.player, target) then
		return "be_lost"
	end
	if self:isWeak() and not self:needDeath() then return "throw_equips" end

	local value = 0
	for _, equip in sgs.qlist(self.player:getEquips()) do
		if equip:isKindOf("Weapon") then
			value = value + self:evaluateWeapon(equip)
		elseif equip:isKindOf("Armor") then
			value = value + self:evaluateArmor(equip)
			if self:needToThrowArmor() then value = value - 5 end
		elseif equip:isKindOf("OffensiveHorse") then
			value = value + 2.5
		elseif equip:isKindOf("DefensiveHorse") then
			value = value + 5
		end
	end
	if value < 8 then return "throw_equips" else return "be_lost" end
end



lalong_skill = {}
lalong_skill.name = "lalong"
table.insert(sgs.ai_skills, lalong_skill)
lalong_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#lalongCard") then return end

	local card
	if self:needToThrowArmor() and self.player:getArmor():getSuit() == sgs.Card_Spade then
		card = self.player:getArmor()
	end
	if not card then
		local hcards = self.player:getCards("h")
		hcards = sgs.QList2Table(hcards)
		self:sortByUseValue(hcards, true)

		for _, hcard in ipairs(hcards) do
			if hcard:getSuit() == sgs.Card_Spade then
				card = hcard
				break
			end
		end
	end
	if not card then
		local ecards = self.player:getCards("e")
		ecards = sgs.QList2Table(ecards)

		for _, ecard in ipairs(ecards) do
			if (ecard:isKindOf("Weapon") or ecard:isKindOf("OffensiveHorse")) and ecard:getSuit() == sgs.Card_Spade then
				card = ecard
				break
			end
		end
	end
	if card then
		card = sgs.Card_Parse("#lalongCard:" .. card:getEffectiveId() .. ":")
		return card
	end

	return nil
end

sgs.ai_skill_use_func["#lalongCard"] = function(card, use, self)
	local target
	local friends = self.friends_noself
	local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
	self.lalongTarget = nil

	local canMingceTo = function(player)
		local canGive = not self:needKongcheng(player, true)
		return canGive or (not canGive and self:getEnemyNumBySeat(self.player, player) == 0)
	end

	self:sort(self.enemies, "defense")
	for _, friend in ipairs(friends) do
		if canMingceTo(friend) then
			for _, enemy in ipairs(self.enemies) do
				if friend:canSlash(enemy) and not self:slashProhibit(slash, enemy) and sgs.getDefenseSlash(enemy, self) <= 2
					and self:slashIsEffective(slash, enemy) and self:isGoodTarget(enemy, self.enemies)
					and enemy:objectName() ~= self.player:objectName() then
					target = friend
					self.lalongTarget = enemy
					break
				end
			end
		end
		if target then break end
	end

	slash:deleteLater()
	if target then
		use.card = card
		if use.to then
			use.to:append(target)
		end
	end
end


sgs.ai_skill_playerchosen.lalong = function(self, targets)
	if self.lalongTarget then return self.lalongTarget end
	return sgs.ai_skill_playerchosen.zero_card_as_slash(self, targets)
end

sgs.ai_skill_playerchosen.renzha = function(self, targets)
	if self:isWeak() and (self.player:getJudgingArea():length() == 0) then return nil end
	targets = sgs.QList2Table(targets)
	for _, target in ipairs(targets) do
		if self:isFriend(target) and target:isAlive() then
			if (self.player:getJudgingArea():length() > 0)
				or (self:isWeak(target))
				or (self.player:hasSkills(sgs.lose_equip_skill) and self.player:getEquips():length() > 0)
				or (self.player:hasSkills(sgs.need_kongcheng) and self.player:getHandcardNum() == 1) then
				return target
			end
		end
	end
	return nil
end


sgs.ai_skill_invoke.shengui = function(self, data)
	local target = data:toPlayer()
	if target then
		if not self:isFriend(target) then
			if self:hasHeavyDamage(self.player, nil, target) and self:canLiegong(target, self.player) then
				if self.player:canDiscard(target, "h") and getCardsNum("Jink", target, self.player) > 1 then
					return false
				end
			end
			return true
		end
	end
	return false
end




sgs.ai_skill_use["@@sheji"] = function(self, prompt)
	local handcardnum = self.player:getHandcardNum()
	local trash = self:getCard("Disaster") or self:getCard("GodSalvation") or self:getCard("AmazingGrace") or
		self:getCard("Slash") or self:getCard("FireAttack") or self:getCard("Jink") or self:getCard("shuugakulyukou") or
		self:getCard("strike_the_death") or self:getCard("together_go_die") or self:getCard("rotenburo") or
		self:getCard("bunkasai")
	local best_target, target
	local cards = sgs.QList2Table(self.player:getCards("h"))
	local to_discard = {}
	for _, card in ipairs(cards) do
		table.insert(to_discard, card:getEffectiveId())
	end
	self:sort(self.enemies, "defenseSlash")
	if handcardnum <= 2 and trash and #self.enemies >= 1 then
		for _, enemy in ipairs(self.enemies) do
			local slash = sgs.Sanguosha:cloneCard("slash")
			if self.player:canSlash(enemy, slash, false) and not self:slashProhibit(nil, enemy) and self.player:inMyAttackRange(enemy)
				and self:slashIsEffective(slash, enemy) and self:isGoodTarget(enemy, self.enemies) then
				if enemy:getHp() == 1 and getCardsNum("Jink", enemy) == 0 then
					best_target = enemy
					break
				end
				if sgs.getDefense(enemy) < 6 then
					best_target = enemy
					break
				end
			end
			slash:deleteLater()
		end
		for _, enemy in ipairs(self.enemies) do
			local slash = sgs.Sanguosha:cloneCard("slash")
			if self.player:canSlash(enemy, slash, false) and not self:slashProhibit(nil, enemy) and self.player:inMyAttackRange(enemy)
				and self:slashIsEffective(slash, enemy) and self:isGoodTarget(enemy, self.enemies) then
				target = enemy
			end
			slash:deleteLater()
		end
	end
	for _, acard in sgs.qlist(self.player:getHandcards()) do
		if isCard("Peach", acard, self.player) and self.player:getHandcardNum() > 1 and self.player:isWounded()
			and not self:needToLoseHp(self.player) then
			return "."
		end
	end
	if best_target then
		return "#shejiCard:" .. table.concat(to_discard, "+") .. ":->" .. best_target:objectName()
	end
	if target then
		return "#shejiCard:" .. table.concat(to_discard, "+") .. ":->" .. target:objectName()
	end
end
