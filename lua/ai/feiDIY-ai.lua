sgs.ai_skill_invoke.feiqianxun = function(self, data)
	local effect
	if self.player:getPhase() == sgs.Player_Judge then
		effect = data:toCardEffect()
	else
		effect = data:toCardUse()
	end
	if effect.card and effect.card:isKindOf("Collateral") and self.player:getWeapon() then
		local victim = self.player:getTag("collateralVictim"):toPlayer()
		if victim
			and sgs.ai_skill_cardask["collateral-slash"](self, nil, nil, victim, effect.from) ~= "."
		then
			return false
		end
	end
	if self.player:getPhase() == sgs.Player_Judge then
		if effect.card:isKindOf("Lightning")
			and self:isWeak()
			and self:getCardsNum("Peach") + self:getCardsNum("Analeptic") > 0 then
			return false
		end
		return true
	end
	local current = self.room:getCurrent()
	if current and self:isFriend(current) and effect.from and self:isFriend(effect.from) then return true end
	if effect.card and effect.card:isKindOf("Duel") and sgs.ai_skill_cardask["duel-slash"](self, data, nil, effect.from) ~= "." then return false end
	if effect.card and effect.card:isKindOf("AOE") and sgs.ai_skill_cardask.aoe(self, data, nil, effect.from, effect.card:objectName()) ~= "." then return false end
	if self.player:getHandcardNum() < self:getLeastHandcardNum(self.player) then return true end
	local l_lim, u_lim = math.max(2, self:getLeastHandcardNum(self.player)), math.max(5, #self.friends)
	if u_lim <= l_lim then u_lim = l_lim + 1 end
	return math.random(0, 100) >= (self.player:getHandcardNum() - l_lim) / (u_lim - l_lim + 1) * 100
end


local feiqianxun_skill = {}
feiqianxun_skill.name = "feiqianxun"
table.insert(sgs.ai_skills, feiqianxun_skill)
feiqianxun_skill.getTurnUseCard = function(self, inclusive)
	if sgs.turncount <= 1 and #self.friends_noself == 0 and not self:isWeak() and self:getOverflow() <= 0 then return end
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)

	local red_card
	if self:needBear() then return end
	self:sortByUseValue(cards, true)

	for _, card in ipairs(cards) do
		local shouldUse = true
		if card:isKindOf("Slash") then
			local dummy_use = { isDummy = true }
			if self:getCardsNum("Slash") == 1 then
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then shouldUse = false end
			end
		end

		if self:getUseValue(card) > sgs.ai_use_value["#feiqianxuncard"] and card:isKindOf("TrickCard") then
			local dummy_use = { isDummy = true }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then shouldUse = false end
		end

		if shouldUse and not card:isKindOf("Peach") then
			red_card = card
			break
		end
	end
	if red_card then
		return sgs.Card_Parse("#feiqianxuncard:.:")
	end
end

sgs.ai_skill_use_func["#feiqianxuncard"] = function(card, use, self)
	use.card = card
	if use.to then use.to:append(self.player) end
	for _, player in ipairs(self.friends) do
		if use.to and not player:hasSkill("manjuan") and player:objectName() ~= self.player:objectName() then
			if use.to:length() >= self.player:getHandcardNum() then
				break
			end
			use.to:append(player)
		end
	end
	for _, enemy in ipairs(self.enemies) do
		if use.to and enemy:hasSkill("manjuan") then
			if use.to:length() >= self.player:getHandcardNum() then
				break
			end
			use.to:append(enemy)
		end
	end
end

sgs.ai_use_value["#feiqianxuncard"] = 3
sgs.ai_use_priority["#feiqianxuncard"] = 2.2
sgs.ai_card_intention["#feiqianxuncard"] = function(self, card, from, tos, source)
	for _, to in ipairs(tos) do
		sgs.updateIntention(from, to, to:hasSkill("manjuan") and 50 or -50)
	end
end

sgs.ai_skill_invoke.feilianying = function(self, data)
	return true
end
sgs.ai_skill_use["@@feilianying"] = function(self, prompt)
	if self.player:getMark("feilianying") == 1 or self.player:getMark("feilianying") == 0 then
		return "#feilianyingCard:.:->" .. self.player:objectName()
	end
	local to = {}

	self:sort(self.enemies, "defense")
	self.feilianyingchoice = "Chain"
	for _, enemy in ipairs(self.enemies) do
		if self:objectiveLevel(enemy) > 2
			and not (enemy:isChained() or self:needToLoseHp(enemy))
			and self:isGoodTarget(enemy, self.enemies)
		then
			table.insert(to, enemy:objectName())
			if #to == self.player:getMark("feilianying")
			then
				self.feilianyingchoice = "Chain"
				break
			end
		end
	end

	if (#to > 0) and (#to < self.player:getMark("feilianying")) then
		self:sort(self.friends, "defense")
		for _, friend in ipairs(self.friends) do
			if not (friend:isChained()) and self:needToLoseHp(friend) then
				table.insert(to, friend:objectName())
				if #to == self.player:getMark("feilianying")
				then
					break
				end
			end
		end
	end
	if #to == 0 then
		self.feilianyingchoice = "draw"
		self:sort(self.friends, "defense")
		table.insert(to, self.player:objectName())
		for _, friend in ipairs(self.friends_noself) do
			if not (friend:hasSkill("manjuan")) then
				if #to == self.player:getMark("feilianying")
				then
					break
				end
				table.insert(to, friend:objectName())
			end
		end
	end

	-- for _, player in ipairs(others) do
	-- 	if self:isEnemy(player) and not player:isChained() then
	-- 		table.insert(to, player:objectName())
	-- 	end
	-- 	if #to == self.player:getMark("feilianying") then
	-- 		sgs.ai_skill_choice.feilianyingCard = "Chain"
	-- 		break
	-- 	end
	-- end
	-- if #to == 0 then
	-- 	for _, player in ipairs(others) do
	-- 		if self:isFriend(player) then
	-- 			table.insert(to, player:objectName())
	-- 		end
	-- 		if #to == self.player:getMark("feilianying") then
	-- 			sgs.ai_skill_choice.feilianyingCard = "draw"
	-- 			break
	-- 		end
	-- 	end
	-- else
	-- 	sgs.ai_skill_choice.feilianyingCard = "Chain"
	-- end
	if (#to > 0) then
		assert(string.format("#feilianyingCard:.:->%s", table.concat(to, "+")))
		return string.format("#feilianyingCard:.:->%s", table.concat(to, "+"))
	end
	return "."
end
sgs.ai_skill_choice.feilianyingCard = function(self, choices)
	return self.feilianyingchoice
end


sgs.ai_skill_playerchosen.feilianyingCard = function(self, targets)
	local fire_attack = sgs.Sanguosha:cloneCard("fire_attack", sgs.Card_NoSuit, 0)
	fire_attack:deleteLater()
	fire_attack:setSkillName("feilianying")
	local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
	self:useTrickCard(fire_attack, dummy_use)
	if dummy_use.card then
		if not dummy_use.to:isEmpty() then
			for _, p in sgs.qlist(dummy_use.to) do
				if self:isEnemy(p) then
					return p
				end
			end
		end
	end
end

sgs.ai_skill_invoke.feituxi = function(self, data)
	if self:isEnemy(self.room:getCurrent()) and not self:doNotDiscard(self.room:getCurrent(), "h", true) then
		return true
	end
	if self:isFriend(self.room:getCurrent()) and self:doNotDiscard(self.room:getCurrent(), "h", true) then
		return true
	end
end

sgs.ai_skill_choice.feizhaohu = function(self, targets)
	players = sgs.QList2Table(self.room:getAllPlayers())
	local move
	for _, player in ipairs(players) do
		if player:getMark("feizhaohup") > 0 then
			move = player:getTag("feizhaohuData"):toMoveOneTime()
		end
	end
	if self.player:getMark("&feizhaohu") >= 2

		and move.from
		and self:isEnemy(move.from)
		and self:damageIsEffective(move.from) and not self:cantbeHurt(move.from) then
		return "lose"
	end
	return "get"
end
sgs.ai_skill_invoke.feiyinghun = function(self, data)
	return self.player:getHp() > 1 and math.random() < 0.3
end
sgs.ai_skill_choice.feiyinghun = function(self, targets)
	if self:isFriend(self.room:getCurrent()) then
		return "draw"
	else
		return "throw"
	end
end
sgs.ai_skill_invoke.feijiangchi = function(self, data)
	if self:getCardsNum("Slash") > 3 or self.player:getHandcardNum() < self.player:getHp() then
		return true
	end
	return false
end
sgs.ai_skill_choice.feijiangchi = function(self, targets)
	if self.player:getHandcardNum() > self.player:getHp() then
		return "play"
	else
		return "draw"
	end
end
local feihujue_skill = {}
feihujue_skill.name = "feihujue"
table.insert(sgs.ai_skills, feihujue_skill)
feihujue_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#feihujueCard") then return end
	assert(sgs.Card_Parse("#feihujueCard:.:"))
	return sgs.Card_Parse("#feihujueCard:.:")
end
sgs.ai_skill_use_func["#feihujueCard"] = function(card, use, self)
	self:updatePlayers()
	self:sort(self.enemies, "handcard")
	local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
	duel:deleteLater()
	duel:setSkillName("feihujue")
	local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
	self:useTrickCard(duel, dummy_use)
	if dummy_use.card then
		if not dummy_use.to:isEmpty() then
			for _, p in sgs.qlist(dummy_use.to) do
				use.card = card
				if use.to then
					use.to:append(p)
				end
				return
			end
		end
	end
end
sgs.ai_use_priority.feihujueCard = 4.9
sgs.ai_use_value.feihujueCard = 5
sgs.ai_card_intention.feihujueCard = 60

local feilangduo_skill = {}
feilangduo_skill.name = "feilangduo"
table.insert(sgs.ai_skills, feilangduo_skill)
feilangduo_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#feilangduoCard")
		or self.player:isKongcheng() then
		return
	end
	assert(sgs.Card_Parse("#feilangduoCard:.:"))
	return sgs.Card_Parse("#feilangduoCard:.:")
end
sgs.ai_skill_use_func["#feilangduoCard"] = function(card, use, self)
	self:updatePlayers()
	self:sort(self.enemies, "hp")
	local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
	duel:deleteLater()
	duel:setSkillName("feihujue")
	local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
	self:useTrickCard(duel, dummy_use)
	if dummy_use.card then
		if not dummy_use.to:isEmpty() then
			for _, p in sgs.qlist(dummy_use.to) do
				if self.player:canPindian(p) then
					use.card = card
					if use.to then
						use.to:append(p)
					end
					return
				end
			end
		end
	end
end
sgs.ai_use_priority.feilangduoCard = 5.1
sgs.ai_use_value.feilangduoCard = 5
sgs.ai_card_intention.feilangduoCard = 90
sgs.ai_skill_invoke.feibenzi = function(self, data)
	return true
end
sgs.ai_skill_invoke.feifeijiang = function(self, data)
	-- local use = data:toCardUse()
	-- for _, p in sgs.qlist(use.to) do
	-- 	if self:isFriend(p) then
	-- 		return false
	-- 	end
	-- end
	-- return true
	local target = data:toPlayer()
	if target then
		if self:isFriend(target) then
			return false
		else
			return true
		end
	end
	return false
end
sgs.ai_skill_invoke.feijiedou = function(self, data)
	local use = data:toCardUse()
	for _, p in sgs.qlist(use.to) do
		if self:isFriend(p) then
			return true
		end
	end
	return false
end
feisheji_skill = {}
feisheji_skill.name = "feisheji"
table.insert(sgs.ai_skills, feisheji_skill)
feisheji_skill.getTurnUseCard          = function(self, inclusive)
	if #self.enemies < 1 then return end
	if self.player:isKongcheng() then return end
	local cards = sgs.QList2Table(self.player:getHandcards())
	local card_OK = false
	for _, acard in ipairs(cards) do
		if acard:isKindOf("EquipCard") then
			card_OK = true
		end
	end
	if not card_OK then return end
	local selfSub = self.player:getHp() - self.player:getHandcardNum()
	local selfDef = sgs.getDefense(self.player)

	for _, enemy in ipairs(self.enemies) do
		local def = sgs.getDefenseSlash(enemy, self)
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:deleteLater()
		local eff = self:slashIsEffective(slash, enemy) and self:isGoodTarget(enemy, self.enemies, slash)

		if self.player:canSlash(enemy, slash, true) and not self:slashProhibit(nil, enemy) and def < 6 and eff then
			return sgs.Card_Parse("#feishejiCard:.:")
		end
	end
end

sgs.ai_skill_use_func["#feishejiCard"] = function(card, use, self)
	local cards = sgs.QList2Table(self.player:getHandcards())
	local target
	local card
	for _, acard in ipairs(cards) do
		if acard:isKindOf("EquipCard") then
			card = acard
		end
	end
	local selfSub = self.player:getHp() - self.player:getHandcardNum()
	local selfDef = sgs.getDefense(self.player)

	for _, enemy in ipairs(self.enemies) do
		local def = sgs.getDefenseSlash(enemy, self)
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:deleteLater()
		local eff = self:slashIsEffective(slash, enemy) and self:isGoodTarget(enemy, self.enemies, nil)

		if self.player:canSlash(enemy, slash, true) and not self:slashProhibit(nil, enemy) and def < 6 and eff then
			target = enemy
			break
		end
	end
	if target and card then
		use.card = sgs.Card_Parse("#feishejiCard:" .. card:getEffectiveId() .. ":")
		if use.to then use.to:append(target) end
		return
	end
end

sgs.ai_use_value["#feishejiCard"]      = 9
sgs.ai_use_priority["#feishejiCard"]   = 3.2
sgs.ai_card_intention["#feishejiCard"] = 80

sgs.ai_skill_invoke.feixiaohu          = function(self, data)
	return true
end
sgs.ai_skill_invoke.feifenhu           = function(self, data)
	local x = self:ImitateResult_DrawNCards(self.player, self.player:getVisibleSkillList(true))
	if x > #self.friends then
		return false
	end
	return true
end
sgs.ai_skill_use["@@feifenhu"]         = function(self, prompt)
	local players = self.room:getAllPlayers()
	players = sgs.QList2Table(players)
	local to = {}
	for _, player in ipairs(players) do
		if not self:isEnemy(player) then
			table.insert(to, player:objectName())
		end
	end
	assert(string.format("#feifenhuCard:.:->%s", table.concat(to, "+")))
	return string.format("#feifenhuCard:.:->%s", table.concat(to, "+"))
end
sgs.ai_card_intention.feifenhuCard     = -20
sgs.ai_skill_invoke.feidaizui          = function(self, data)
	if self:getCardsNum("Jink") > 0 then
		return false
	end
	return true
end
sgs.ai_skill_playerchosen.feidaizui    = function(self, targets)
	self:updatePlayers()
	self:sort(self.friends_noself, "handcard")
	for _, friend in ipairs(self.friends_noself) do
		if friend then
			return friend
		end
	end
end
sgs.ai_skill_choice.feidaizui          = function(self, targets)
	if self:getCardsNum("Jink") > 1 then
		return "give"
	end
	return "no"
end
sgs.ai_skill_invoke.feidaizuidraw      = function(self, data)
	local least = 1000
	local f, e = 0, 0
	for _, p in sgs.qlist(self.room:getAlivePlayers()) do
		least = math.min(p:getHandcardNum(), least)
	end
	for _, p in sgs.qlist(self.room:getAlivePlayers()) do
		if p:getHandcardNum() == least then
			if self:isFriend(p) then
				f = f + 1
			else
				e = e + 1
			end
		end
	end
	if f >= e then
		return true
	end
	return false
end
sgs.ai_can_damagehp.feidaizui          = function(self, from, card, to)
	local least = 1000
	local f, e = 0, 0
	for _, p in sgs.qlist(self.room:getAlivePlayers()) do
		least = math.min(p:getHandcardNum(), least)
	end
	for _, p in sgs.qlist(self.room:getAlivePlayers()) do
		if p:getHandcardNum() == least then
			if self:isFriend(p) then
				f = f + 1
			else
				e = e + 1
			end
		end
	end
	return to:getHp() + self:getAllPeachNum() - self:ajustDamage(from, to, 1, card) > 0
		and self:canLoseHp(from, card, to) and f >= e
end

local feizuijiao_skill                 = {}
feizuijiao_skill.name                  = "feizuijiao"
table.insert(sgs.ai_skills, feizuijiao_skill)
feizuijiao_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#feizuijiaoCard")
		or self.player:getHandcardNum() > self.player:getMaxHp() then
		return
	end
	assert(sgs.Card_Parse("#feizuijiaoCard:.:"))
	return sgs.Card_Parse("#feizuijiaoCard:.:")
end
sgs.ai_skill_use_func["#feizuijiaoCard"] = function(card, use, self)
	self:updatePlayers()
	self:sort(self.enemies, "hp")
	for _, to in ipairs(self.enemies) do
		if to then
			use.card = card
			if use.to then
				use.to:append(to)
			end
			return
		end
	end
end
sgs.ai_skill_invoke.feizuijiao = function(self, data)
	if self.player:isWeak() then
		return true
	end
	if math.random() < 0.4 then
		return true
	end
	return false
end
sgs.ai_use_priority.feizuijiaoCard = 4.4
sgs.ai_use_value.feizuijiaoCard = 4.5
sgs.ai_card_intention.feizuijiaoCard = 20
sgs.ai_skill_invoke.feihuchen = function(self, data)
	local move = data:toMoveOneTime()
	if self:isFriend(move.to) then
		return true
	end
	return false
end

local feiwusheng_skill = {}
feiwusheng_skill.name = "feiwusheng"
feiwusheng_skill.getTurnUseCard = function(self)
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	local card = nil
	for _, c in ipairs(cards) do
		if not c:isKindOf("Slash") and not c:isKindOf("Peach")
			and ((self:getUseValue(card) < sgs.ai_use_value.Slash) or inclusive) then
			card = c
			break
		end
	end
	if not card then return nil end
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	local card_str = ("slash:feiwusheng[%s:%s]=%d"):format(suit, number, card_id)
	local slash = sgs.Card_Parse(card_str)
	assert(slash)
	return slash
end
sgs.ai_ajustdamage_from.feiwusheng = function(self, from, to, card, nature)
	if to:getHujia() > 0 and to:getHp() ~= 1
	then
		return 1
	end
end


local feiyanjun_skill = {}
feiyanjun_skill.name = "feiyanjun"
table.insert(sgs.ai_skills, feiyanjun_skill)
feiyanjun_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#feiyanjunCard")
		or self.player:isNude() then
		return
	end
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	local card_ids = {}
	for _, c in pairs(cards) do
		if not c:isKindOf("BasicCard") then
			table.insert(card_ids, c:getEffectiveId())
			break
		end
	end
	if #card_ids ~= 0 then
		return sgs.Card_Parse("#feiyanjunCard:" .. table.concat(card_ids, "+") .. ":")
	else
		return nil
	end
end
sgs.ai_skill_use_func["#feiyanjunCard"] = function(card, use, self)
	self:updatePlayers()
	self:sort(self.enemies, "hp")
	for _, to in ipairs(self.enemies) do
		if to then
			use.card = card
			if use.to then
				use.to:append(to)
			end
			return
		end
	end
end
sgs.ai_use_priority.feiyanjunCard = 7.9
sgs.ai_use_value.feiyanjunCard = 6
sgs.ai_card_intention.feiyanjunCard = 100


sgs.ai_skill_use["@@feifengpo"] = function(self, prompt)
	local use = self.room:getTag("feifengpo"):toCardUse()
	if use.from and self:isFriend(use.from) then
		return "."
	end
	if self:needToThrowArmor() and self.player:getArmor() and self.player:getArmor():isRed() then
		return "#feifengpoCard:" ..
			self.player:getArmor():getEffectiveId() .. ":"
	end
	if not self:slashIsEffective(use.card, self.player, use.from)
		or (self:ajustDamage(use.from, self.player, 1, use.card) < 2
			and self:needToLoseHp(self.player, use.from, use.card)) then
		return "."
	end
	if self:ajustDamage(use.from, self.player, 1, use.card) and self:getCardsNum("Peach") > 0 then return "." end
	if self:getCardsNum("Jink") == 0 or not sgs.isJinkAvailable(use.from, self.player, use.card, true) then return "." end
	local equip_index = { 3, 0, 2, 4, 1 }
	if self.player:hasSkills(sgs.lose_equip_skill) then
		for _, i in ipairs(equip_index) do
			if i == 4 then break end
			if self.player:getEquip(i) and self.player:getEquip(i):isRed() then
				return "#feifengpoCard:" ..
					self.player:getEquip(i):getEffectiveId() .. ":"
			end
		end
	end
	local jiangqin = self.room:findPlayerBySkillName("niaoxiang")
	local need_double_jink = use.from:hasSkill("wushuang")
		or (use.from:hasSkill("roulin") and self.player:isFemale())
		or (self.player:hasSkill("roulin") and use.from:isFemale())
		or (jiangqin and jiangqin:isAdjacentTo(self.player) and use.from:isAdjacentTo(self.player) and self:isEnemy(jiangqin))
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByKeepValue(cards)
	for _, card in ipairs(cards) do
		if not card:getSuitString():isRed() or (not self:isWeak() and (self:getKeepValue(card) > 8 or self:isValuableCard(card)))
			or (isCard("Jink", card, self.player) and self:getCardsNum("Jink") - 1 < (need_double_jink and 2 or 1)) then
			continue
		end
		return "#feifengpoCard:" ..
			card:getEffectiveId() .. ":"
	end
	for _, i in ipairs(equip_index) do
		if self.player:getEquip(i) and self.player:getEquip(i):isRed() then
			if not (i == 1 and self:evaluateArmor() > 3)
				and not (i == 4 and self.player:getTreasure():isKindOf("WoodenOx") and self.player:getPile("wooden_ox"):length() >= 3) then
				return "#feifengpoCard:" ..
					self.player:getEquip(i):getEffectiveId() .. ":"
			end
		end
	end
	return "."
end
sgs.ai_skill_invoke.feifengpo   = function(self, data)
	-- local use = data:toCardUse()
	-- for _, p in sgs.qlist(use.to) do
	-- 	if not self:isFriend(p) then
	-- 		return true
	-- 	end
	-- end
	local target = data:toPlayer()
	if not self:isFriend(target) then
		return true
	end
	return false
end
sgs.ai_skill_invoke.feiniepan   = function(self, data)
	return true
end
sgs.ai_skill_invoke.feilianhuan = function(self, data)
	return true
end

local feilianhuan_skill         = {}
feilianhuan_skill.name          = "feilianhuan"
table.insert(sgs.ai_skills, feilianhuan_skill)
feilianhuan_skill.getTurnUseCard = function(self)
	if self.player:isKongcheng() then return end
	assert(sgs.Card_Parse("#feilianhuanCard:.:"))
	return sgs.Card_Parse("#feilianhuanCard:.:")
end
sgs.ai_skill_use_func["#feilianhuanCard"] = function(card, use, self)
	self:updatePlayers()
	self:sort(self.enemies, "value")
	for _, to in ipairs(self.enemies) do
		if to and not to:isKongcheng() and not to:isChained() then
			use.card = card
			if use.to then
				use.to:append(to)
			end
			return
		end
	end
end
sgs.ai_use_priority.feilianhuanCard = 3.1
sgs.ai_use_value.feilianhuanCard = 4
sgs.ai_card_intention.feilianhuanCard = 30
