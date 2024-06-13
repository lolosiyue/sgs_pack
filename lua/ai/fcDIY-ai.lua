--DIY扩展包武将AI

--1 神貂蝉-自改版
--“魅魂”AI
sgs.ai_skill_invoke.f_meihun = true

sgs.ai_skill_playerchosen.f_meihun = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isEnemy(p) and not p:isAllNude() then
			return p
		end
	end
	return nil
end

--2 神张角
--“太平”AI（仅包括横置角色）
sgs.ai_skill_invoke.f_taiping = function(self, data)
	self:sort(self.enemies)
	self.enemies = sgs.reverse(self.enemies)
	for _, enemy in ipairs(self.enemies) do
		if self:objectiveLevel(enemy) > 0 then
			return true
		end
	end
	return false
end

sgs.ai_skill_playerchosen.f_taiping = function(self, targets)
	local targets = sgs.QList2Table(targets)
	self:sort(targets, "defense")
	for _, p in ipairs(targets) do
		if self:isEnemy(p) and not p:hasSkill("jieying") and not p:hasSkill("fcjieying") and not p:hasSkill("faen") and not p:hasSkill("qianjie") and not p:hasSkills("chenghao+yinshi") then
			return p
		end
	end
	for _, p in ipairs(targets) do
		return p
	end
end

sgs.ai_skill_choice.f_taiping = function(self, choices, data)
	return "tpChain"
end

--“妖术”AI
--不写。

--“落雷”AI
local f_luolei_skill = {}
f_luolei_skill.name = "f_luolei"
table.insert(sgs.ai_skills, f_luolei_skill)
f_luolei_skill.getTurnUseCard = function(self)
	if self.player:getMark("@f_luolei") == 0 then return end
	return sgs.Card_Parse("#f_luoleiCard:.:")
end

sgs.ai_skill_use_func["#f_luoleiCard"] = function(card, use, self)
	if self.player:getMark("@f_luolei") > 0 then
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

sgs.ai_use_value.f_luoleiCard = 8.5
sgs.ai_use_priority.f_luoleiCard = 9.5
sgs.ai_card_intention.f_luoleiCard = 80

--3 神张飞
--“斗神”AI
local f_doushen_skill = {}
f_doushen_skill.name = "f_doushen"
table.insert(sgs.ai_skills, f_doushen_skill)
f_doushen_skill.getTurnUseCard = function(self)
	if self.player:getMark("@f_doushen") == 0 and self:getCardsNum("Slash") < 3 then return end
	return sgs.Card_Parse("#f_doushenCard:.:")
end

sgs.ai_skill_use_func["#f_doushenCard"] = function(card, use, self)
	if self.player:getMark("@f_doushen") > 0 and self:getCardsNum("Slash") >= 3 then
		use.card = card
		return
	end
end

sgs.ai_use_value.f_doushenCard = 9.7
sgs.ai_use_priority.f_doushenCard = 9.8
sgs.ai_card_intention.f_doushenCard = -90

--“酒威”AI
sgs.ai_view_as.f_jiuwei = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if (card_place ~= sgs.Player_PlaceSpecial or player:getPile("wooden_ox"):contains(card_id))
		and not (card:isKindOf("WoodenOx") and player:getPile("wooden_ox"):length() > 0) then
		return ("analeptic:f_jiuwei[%s:%s]=%d"):format(suit, number, card_id)
	end
end

sgs.ai_cardneed.f_jiuwei = function(to, card)
	return card
end

--4 神马超
--“神临”AI
local f_shenlin_skill = {}
f_shenlin_skill.name = "f_shenlin"
table.insert(sgs.ai_skills, f_shenlin_skill)
f_shenlin_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("f_shenlinCard") or self.player:getHandcardNum() < 3 or (self:getCardsNum("TrickCard") == 0 and self:getCardsNum("EquipCard") == 0) or #self.enemies == 0 then return end
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
		return nil
	else
		return sgs.Card_Parse("#f_shenlinCard:" .. card_id .. ":")
	end
end

sgs.ai_skill_use_func["#f_shenlinCard"] = function(card, use, self)
	if not self.player:hasUsed("#f_shenlinCard") and self.player:getHandcardNum() > 2 then
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

sgs.ai_use_value.f_shenlinCard = 9
sgs.ai_use_priority.f_shenlinCard = 9.7
sgs.ai_card_intention.f_shenlinCard = 90

--“神怒”AI
local f_shennu_skill = {}
f_shennu_skill.name = "f_shennu"
table.insert(sgs.ai_skills, f_shennu_skill)
f_shennu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("f_shennuCard") or self.player:getHp() < 2 or self:getCardsNum("Slash") == 0 then return end
	return sgs.Card_Parse("#f_shennuCard:.:")
end

sgs.ai_skill_use_func["#f_shennuCard"] = function(card, use, self)
	if not self.player:hasFlag("shenzhinuhuo") then
		use.card = card
		return
	end
end

sgs.ai_use_value.f_shennuCard = 8.5
sgs.ai_use_priority.f_shennuCard = 9.5
sgs.ai_card_intention.f_shennuCard = -80

--5 神姜维
--“北伐!”AI
local f_beifa_skill = {}
f_beifa_skill.name = "f_beifa"
table.insert(sgs.ai_skills, f_beifa_skill)
f_beifa_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("f_beifaCard") or self.player:isNude() or #self.enemies == 0 then return end
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
		return sgs.Card_Parse("#f_beifaCard:" .. card_id .. ":")
	end
end

sgs.ai_skill_use_func["#f_beifaCard"] = function(card, use, self)
	if not self.player:hasUsed("#f_beifaCard") then
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

sgs.ai_use_value.f_beifaCard = 8.5
sgs.ai_use_priority.f_beifaCard = 9.5
sgs.ai_card_intention.f_beifaCard = 80

--6 神邓艾
--“毡衫”AI（不包括主动给别人标记）
sgs.ai_skill_invoke.f_zhanshan_Trigger = function(self, data)
	if self.player:getPhase() == sgs.Player_Start and self.player:getMaxHp() <= 2 then return false end
	return true
end

--7 汉中王神刘备
--“结义”AI

--“仁义”AI
local f_renyi_skill = {}
f_renyi_skill.name = "f_renyi"
table.insert(sgs.ai_skills, f_renyi_skill)
f_renyi_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("f_renyiCard") then return end
	return sgs.Card_Parse("#f_renyiCard:.:")
end

sgs.ai_skill_use_func["#f_renyiCard"] = function(card, use, self)
	if not self.player:hasUsed("#f_renyiCard") then
		use.card = card
		return
	end
end

sgs.ai_skill_playerchosen.f_renyiX = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isFriend(p) then
			return p
		end
	end
end

sgs.ai_use_value.f_renyiCard = 8.5
sgs.ai_use_priority.f_renyiCard = 9.5
sgs.ai_card_intention.f_renyiCard = -80

--8 神黄忠
--“定军”AI（不智能）
local f_dingjun_skill = {}
f_dingjun_skill.name = "f_dingjun"
table.insert(sgs.ai_skills, f_dingjun_skill)
f_dingjun_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("f_dingjunCard") and self.player:getPile("ShenJian"):length() >= 12 and self.player:getHandcardNum() <= 6 then return end
	return sgs.Card_Parse("#f_dingjunCard:.:")
end

sgs.ai_skill_use_func["#f_dingjunCard"] = function(card, use, self)
	if not self.player:hasUsed("#f_dingjunCard") and self.player:getPile("ShenJian"):length() < 12 and self.player:getHandcardNum() > 6 then
		use.card = card
		return
	end
end

sgs.ai_skill_choice.f_dingjun = function(self, choices, data)
	if self.player:getMark("DJSZhanGong") == 0 and self.player:getHandcardNum() >= 4 then return "add4ShenJian" end
	if self.player:getMark("DJSZhanGong") == 0 and self.player:getPile("ShenJian"):length() >= 4 and self.player:getHp() <= 2 and self.player:isKongcheng() then
		return
		"get4ShenJian"
	end
end

sgs.ai_use_value.f_dingjunCard = 8.5
sgs.ai_use_priority.f_dingjunCard = 9.5
sgs.ai_card_intention.f_dingjunCard = -80

local f_newdingjun_skill = {}
f_newdingjun_skill.name = "f_newdingjun"
table.insert(sgs.ai_skills, f_newdingjun_skill)
f_newdingjun_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("f_newdingjunCard") and self.player:getPile("ShenJian"):length() >= 12 and self.player:getHandcardNum() <= 3 then return end
	return sgs.Card_Parse("#f_newdingjunCard:.:")
end

sgs.ai_skill_use_func["#f_newdingjunCard"] = function(card, use, self)
	if not self.player:hasUsed("#f_newdingjunCard") and self.player:getPile("ShenJian"):length() < 12 and self.player:getHandcardNum() > 3 then
		use.card = card
		return
	end
end

sgs.ai_skill_choice.f_newdingjun = function(self, choices, data)
	if self.player:getMark("DJSZhanGong") > 0 and not self.player:isKongcheng() then return "add1to4ShenJian" end
	if self.player:getMark("DJSZhanGong") > 0 and self.player:getPile("ShenJian"):length() > 0 and self.player:getHp() <= 2 and self.player:isKongcheng() then
		return
		"get1to4ShenJian"
	end
end

sgs.ai_use_value.f_newdingjunCard = 8.5
sgs.ai_use_priority.f_newdingjunCard = 9.5
sgs.ai_card_intention.f_newdingjunCard = -80

sgs.ai_skill_use["@@getFShenJianSkill"] = function(self, prompt)
	local card = sgs.Card_Parse("#getFShenJianSkillCard:.:")
	local dummy_use = { isDummy = true }
	self:useSkillCard(card, dummy_use)
	if dummy_use.card then return (dummy_use.card):toString() .. "->." end
	return "."
end

sgs.ai_skill_use["@@getOTFShenJianSkill"] = function(self, prompt)
	local card = sgs.Card_Parse("#getOTFShenJianSkillCard:.:")
	local dummy_use = { isDummy = true }
	self:useSkillCard(card, dummy_use)
	if dummy_use.card then return (dummy_use.card):toString() .. "->." end
	return "."
end

--9 神项羽
--“霸王”AI
local f_bawang_skill = {}
f_bawang_skill.name = "f_bawang"
table.insert(sgs.ai_skills, f_bawang_skill)
f_bawang_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("f_bawangCard") or (self:getCardsNum("Slash") == 0 and self:getCardsNum("Jink") == 0 and self:getCardsNum("Analeptic") == 0) or #self.enemies == 0 then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _, acard in ipairs(cards) do
		if acard:isKindOf("BasicCard") and not acard:isKindOf("Peach") then
			card_id = acard:getEffectiveId()
			break
		end
	end
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("#f_bawangCard:" .. card_id .. ":")
	end
end

sgs.ai_skill_use_func["#f_bawangCard"] = function(card, use, self)
	if not self.player:hasUsed("#f_bawangCard") then
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

sgs.ai_use_value.f_bawangCard = 8.5
sgs.ai_use_priority.f_bawangCard = 9.5
sgs.ai_card_intention.f_bawangCard = 80

--10 神孙悟空（无）

--11 [神]君王霸王龙
--“地狱溪”AI
local f_diyuxi_skill = {}
f_diyuxi_skill.name = "f_diyuxi"
table.insert(sgs.ai_skills, f_diyuxi_skill)
f_diyuxi_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("f_diyuxiCard") and (not self.player:isRebel() and self.player:getHp() <= 1 and self.player:getMaxHp() <= 1) then return end
	return sgs.Card_Parse("#f_diyuxiCard:.:")
end

sgs.ai_skill_use_func["#f_diyuxiCard"] = function(card, use, self)
	if not self.player:hasUsed("#f_diyuxiCard") then --保证（非特殊情况）每回合必选一项且仅选一项，避免结束阶段失去体力
		use.card = card
		return
	end
end

sgs.ai_skill_choice.f_diyuxi = function(self, choices, data)
	if self.player:getHp() - self.player:getMaxHp() < 0 and self.player:getMaxHp() > 1 and (self:getCardsNum("Duel") > 0 or self:getCardsNum("SavageAssault") > 0 or self:getCardsNum("ArcheryAttack") > 0 or self:getCardsNum("FireAttack") > 0 or self:getCardsNum("Drowning") > 0 or self:getCardsNum("Chuqibuyi") > 0 or self:getCardsNum("Qizhengxiangsheng") > 0) then
		return
		"LM1D2D1"
	end
	--if self.player:isRebel() and self.player:getHp() <= 1 and self.player:getMaxHp() <= 1 then return "LM1D2D1" end --自我物理完杀，防止敌方收头拿牌&给农民队友补牌
	if self.player:getHp() <= 1 and self.player:getMaxHp() > 1 then return "LM1D2D1" end
	if self.player:getHp() <= 1 and self:getCardsNum("Peach") == 0 and self:getCardsNum("Analeptic") == 0 and (self:getCardsNum("Duel") == 0 and self:getCardsNum("SavageAssault") == 0 and self:getCardsNum("ArcheryAttack") == 0 and self:getCardsNum("FireAttack") == 0 and self:getCardsNum("Drowning") == 0 and self:getCardsNum("Chuqibuyi") == 0 and self:getCardsNum("Qizhengxiangsheng") == 0) then
		return
		"cancel"
	end
	return "L1D1SD1"
end

sgs.ai_use_value.f_diyuxiCard = 10
sgs.ai_use_priority.f_diyuxiCard = 10
sgs.ai_card_intention.f_diyuxiCard = -100

--12 [神]鲲鹏
--“九天”AI
local f_jiutian_skill = {}
f_jiutian_skill.name = "f_jiutian"
table.insert(sgs.ai_skills, f_jiutian_skill)
f_jiutian_skill.getTurnUseCard = function(self)
	if self.player:getMark("&f_juxing_trigger") == 0 and self.player:getMaxHp() <= 1 then return end
	return sgs.Card_Parse("#f_jiutianCard:.:")
end

sgs.ai_skill_use_func["#f_jiutianCard"] = function(card, use, self)
	if self.player:getMark("&f_juxing_trigger") > 0 and self.player:getMaxHp() > 1 then
		use.card = card
		return
	end
end

sgs.ai_skill_playerchosen.f_jiutianContinue = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isFriend(p) and (p:getHandcardNum() < p:getHp() or p:isWounded()) then
			return p
		end
	end
	return self.player
end

sgs.ai_use_value.f_jiutianCard = 10
sgs.ai_use_priority.f_jiutianCard = 10
sgs.ai_card_intention.f_jiutianCard = -87

--13 FC神吕蒙
sgs.ai_skill_invoke.fcshelie = true

local fcgongxin_skill = {}
fcgongxin_skill.name = "fcgongxin"
table.insert(sgs.ai_skills, fcgongxin_skill)
fcgongxin_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#fcgongxinCard") then return end
	local fcgongxin_card = sgs.Card_Parse("#fcgongxinCard:.:")
	assert(fcgongxin_card)
	return fcgongxin_card
end

sgs.ai_skill_use_func["#fcgongxinCard"] = function(card, use, self)
	self:sort(self.enemies, "handcard")
	self.enemies = sgs.reverse(self.enemies)

	for _, enemy in ipairs(self.enemies) do
		if not enemy:isKongcheng() and self:objectiveLevel(enemy) > 0 and self:getKnownNum(eneny) ~= enemy:getHandcardNum() then
			use.card = card
			if use.to then
				use.to:append(enemy)
			end
			return
		end
	end
end

sgs.ai_skill_askforag.fcgongxin = function(self, card_ids)
	self.fcgongxinchoice = nil
	local target = self.player:getTag("fcgongxin"):toPlayer()
	if not target or self:isFriend(target) then return -1 end
	local nextAlive = self.player
	repeat
		nextAlive = nextAlive:getNextAlive()
	until nextAlive:faceUp()

	local peach, ex_nihilo, jink, nullification, slash
	local valuable
	for _, id in ipairs(card_ids) do
		local card = sgs.Sanguosha:getCard(id)
		if card:isKindOf("Peach") then peach = id end
		if card:isKindOf("ExNihilo") then ex_nihilo = id end
		if card:isKindOf("Jink") then jink = id end
		if card:isKindOf("Nullification") then nullification = id end
		if card:isKindOf("Slash") then slash = id end
	end
	valuable = peach or ex_nihilo or jink or nullification or slash or card_ids[1]
	local card = sgs.Sanguosha:getCard(valuable)
	if self:isEnemy(target) and target:hasSkill("tuntian") then
		local zhangjiao = self.room:findPlayerBySkillName("guidao")
		if zhangjiao and self:isFriend(zhangjiao, target) and self:canRetrial(zhangjiao, target) and self:isValuableCard(card, zhangjiao) then
			self.fcgongxinchoice = "discard"
		else
			self.fcgongxinchoice = "put"
		end
		return valuable
	end

	local willUseExNihilo, willRecast
	if self:getCardsNum("ExNihilo") > 0 then
		local ex_nihilo = self:getCard("ExNihilo")
		if ex_nihilo then
			local dummy_use = { isDummy = true }
			self:useTrickCard(ex_nihilo, dummy_use)
			if dummy_use.card then willUseExNihilo = true end
		end
	elseif self:getCardsNum("IronChain") > 0 then
		local iron_chain = self:getCard("IronChain")
		if iron_chain then
			local dummy_use = { to = sgs.SPlayerList(), isDummy = true }
			self:useTrickCard(iron_chain, dummy_use)
			if dummy_use.card and dummy_use.to:isEmpty() then willRecast = true end
		end
	end
	if willUseExNihilo or willRecast then
		local card = sgs.Sanguosha:getCard(valuable)
		if card:isKindOf("Peach") then
			self.fcgongxinchoice = "put"
			return valuable
		end
		if card:isKindOf("TrickCard") or card:isKindOf("Indulgence") or card:isKindOf("SupplyShortage") then
			local dummy_use = { isDummy = true }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				self.fcgongxinchoice = "put"
				return valuable
			end
		end
		if card:isKindOf("Jink") and self:getCardsNum("Jink") == 0 then
			self.fcgongxinchoice = "put"
			return valuable
		end
		if card:isKindOf("Nullification") and self:getCardsNum("Nullification") == 0 then
			self.fcgongxinchoice = "put"
			return valuable
		end
		if card:isKindOf("Slash") and self:slashIsAvailable() then
			local dummy_use = { isDummy = true }
			self:useBasicCard(card, dummy_use)
			if dummy_use.card then
				self.fcgongxinchoice = "put"
				return valuable
			end
		end
		self.fcgongxinchoice = "discard"
		return valuable
	end

	local hasLightning, hasIndulgence, hasSupplyShortage
	local tricks = nextAlive:getJudgingArea()
	if not tricks:isEmpty() and not nextAlive:containsTrick("YanxiaoCard") then
		local trick = tricks:at(tricks:length() - 1)
		if self:hasTrickEffective(trick, nextAlive) then
			if trick:isKindOf("Lightning") then
				hasLightning = true
			elseif trick:isKindOf("Indulgence") then
				hasIndulgence = true
			elseif trick:isKindOf("SupplyShortage") then
				hasSupplyShortage = true
			end
		end
	end

	if self:isEnemy(nextAlive) and nextAlive:hasSkill("luoshen") and valuable then
		self.fcgongxinchoice = "put"
		return valuable
	end
	if nextAlive:hasSkill("yinghun") and nextAlive:isWounded() then
		self.fcgongxinchoice = self:isFriend(nextAlive) and "put" or "discard"
		return valuable
	end
	if target:hasSkill("hongyan") and hasLightning and self:isEnemy(nextAlive) and not (nextAlive:hasSkill("qiaobian") and nextAlive:getHandcardNum() > 0) then
		for _, id in ipairs(card_ids) do
			local card = sgs.Sanguosha:getEngineCard(id)
			if card:getSuit() == sgs.Card_Spade and card:getNumber() >= 2 and card:getNumber() <= 9 then
				self.fcgongxinchoice = "put"
				return id
			end
		end
	end
	if hasIndulgence and self:isFriend(nextAlive) then
		self.fcgongxinchoice = "put"
		return valuable
	end
	if hasSupplyShortage and self:isEnemy(nextAlive) and not (nextAlive:hasSkill("qiaobian") and nextAlive:getHandcardNum() > 0) then
		local enemy_null = 0
		for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if self:isFriend(p) then enemy_null = enemy_null - getCardsNum("Nullification", p) end
			if self:isEnemy(p) then enemy_null = enemy_null + getCardsNum("Nullification", p) end
		end
		enemy_null = enemy_null - self:getCardsNum("Nullification")
		if enemy_null < 0.8 then
			self.fcgongxinchoice = "put"
			return valuable
		end
	end

	if self:isFriend(nextAlive) and not self:willSkipDrawPhase(nextAlive) and not self:willSkipPlayPhase(nextAlive)
		and not nextAlive:hasSkill("luoshen")
		and not nextAlive:hasSkill("tuxi") and not (nextAlive:hasSkill("qiaobian") and nextAlive:getHandcardNum() > 0) then
		if (peach and valuable == peach) or (ex_nihilo and valuable == ex_nihilo) then
			self.fcgongxinchoice = "put"
			return valuable
		end
		if jink and valuable == jink and getCardsNum("Jink", nextAlive) < 1 then
			self.fcgongxinchoice = "put"
			return valuable
		end
		if nullification and valuable == nullification and getCardsNum("Nullification", nextAlive) < 1 then
			self.fcgongxinchoice = "put"
			return valuable
		end
		if slash and valuable == slash and self:hasCrossbowEffect(nextAlive) then
			self.fcgongxinchoice = "put"
			return valuable
		end
	end

	local card = sgs.Sanguosha:getCard(valuable)
	local keep = false
	if card:isKindOf("Slash") or card:isKindOf("Jink")
		or card:isKindOf("EquipCard")
		or card:isKindOf("Disaster") or card:isKindOf("GlobalEffect") or card:isKindOf("Nullification")
		or target:isLocked(card) then
		keep = true
	end
	self.fcgongxinchoice = (target:objectName() == nextAlive:objectName() and keep) and "put" or "discard"
	return valuable
end

sgs.ai_skill_choice.fcgongxin = function(self, choices)
	return self.fcgongxinchoice or "discard"
end

sgs.ai_use_value.fcgongxinCard = 8.5
sgs.ai_use_priority.fcgongxinCard = 9.5
sgs.ai_card_intention.fcgongxinCard = 80

--14 FC神赵云（不加AI）

--15 FC神刘备
--“结营”AI
sgs.ai_skill_invoke.fcjieying = function(self, data)
	self:sort(self.enemies)
	self.enemies = sgs.reverse(self.enemies)
	for _, enemy in ipairs(self.enemies) do
		if self:objectiveLevel(enemy) > 0 then
			return true
		end
	end
	return false
end

sgs.ai_skill_playerchosen.fcjieying = function(self, targets)
	local targets = sgs.QList2Table(targets)
	self:sort(targets, "defense")
	for _, p in ipairs(targets) do
		if self:isEnemy(p) and not p:hasSkill("jieying") and not p:hasSkill("fcjieying") and not p:hasSkill("faen") and not p:hasSkill("qianjie") and not p:hasSkills("chenghao+yinshi") then
			return p
		end
	end
	for _, p in ipairs(targets) do
		return p
	end
end

sgs.ai_playerchosen_intention.fcjieying = 10

--16 FC神张辽
--“夺锐”AI（无脑）
sgs.ai_skill_invoke.fcduorui = true

sgs.ai_skill_choice.fcduorui = function(self, choices, data)
	if not "obtain1card" then return "cancel" end
	return "obtain1card"
end

--17 地主
--“飞扬”AI
--[[sgs.ai_skill_use["@@f_feiyang"] = function(self, prompt)
	local handcards = {}
	for _, id in sgs.qlist(self.player:handCards()) do
		if self.player:canDiscard(self.player, id) then table.insert(handcards, sgs.Sanguosha:getCard(id)) end
	end
	if #handcards < 2 or self.player:getJudgingArea():length() == 0 then return "." end
	self:sortByKeepValue(handcards)
	local card = sgs.Card_Parse("#f_feiyangCard:.:")
	local dummy_use = {isDummy = true}
	self:useSkillCard(card, dummy_use)
	if dummy_use.card then return (dummy_use.card):toString() .. "->." end
	return "."
end]]

--18 农民
--“耕种”AI
local f_gengzhong_skill = {}
f_gengzhong_skill.name = "f_gengzhong"
table.insert(sgs.ai_skills, f_gengzhong_skill)
f_gengzhong_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("f_gengzhongCard") or (self:getCardsNum("BasicCard") == 0 and self:getCardsNum("Nullification") == 0) or self:getCardsNum("Slash") <= 1 or self.player:getHandcardNum() - self.player:getHp() < 2 or self.player:isNude() then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _, acard in ipairs(cards) do
		if acard:isKindOf("BasicCard") or acard:isKindOf("Nullification") then
			card_id = acard:getEffectiveId()
			break
		end
	end
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("#f_gengzhongCard:" .. card_id .. ":")
	end
end

sgs.ai_skill_use_func["#f_gengzhongCard"] = function(card, use, self)
	if not self.player:hasUsed("#f_gengzhongCard") and not self.player:isNude() then
		use.card = card
		return
	end
end

sgs.ai_use_value.f_gengzhongCard = 8.5
sgs.ai_use_priority.f_gengzhongCard = 9.5
sgs.ai_card_intention.f_gengzhongCard = -80

sgs.ai_skill_invoke["@f_gengzhongNTGet"] = function(self, data)
	if self.player:getPile("NT"):length() == 0 then return false end
	if self.player:getHp() <= 1 then return true end
	if self.player:getHandcardNum() <= 2 or self.player:getPile("NT"):length() >= 3 then return true end
	return false
end

--“共抗”AI
local f_gongkang_skill = {}
f_gongkang_skill.name = "f_gongkang"
table.insert(sgs.ai_skills, f_gongkang_skill)
f_gongkang_skill.getTurnUseCard = function(self)
	if self.player:getMark("@f_gongkang") == 0 then return end
	return sgs.Card_Parse("#f_gongkangCard:.:")
end

sgs.ai_skill_use_func["#f_gongkangCard"] = function(card, use, self)
	if self.player:getMark("@f_gongkang") > 0 then
		self:sort(self.friends_noself)
		for _, friend in ipairs(self.friends_noself) do
			if self:isFriend(friend) then
				use.card = card
				if use.to then use.to:append(friend) end
				return
			end
		end
		return
	end
end

sgs.ai_use_value.f_gongkangCard = 8.5
sgs.ai_use_priority.f_gongkangCard = 9.5
sgs.ai_card_intention.f_gongkangCard = -80

--“同心”AI
sgs.ai_skill_invoke.f_tongxin = true

sgs.ai_skill_choice.f_tongxin = function(self, choices, data)
	if self.player:getHp() <= 1 and not self.player:isKongcheng() then return "2" end
	return "1"
end

--19 武神·关羽
--“威震”AI
local sp_weizhen_skill = {}
sp_weizhen_skill.name = "sp_weizhen"
table.insert(sgs.ai_skills, sp_weizhen_skill)
sp_weizhen_skill.getTurnUseCard = function(self)
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	local card
	self:sortByUseValue(cards, true)
	for _, acard in ipairs(cards) do
		if acard:isBlack() and not acard:isKindOf("Peach") and (self:getDynamicUsePriority(acard) < sgs.ai_use_value.Drowning or self:getOverflow() > 0) then
			if acard:isKindOf("Slash") and self:getCardsNum("Slash") == 1 then
				local keep
				local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
				self:useBasicCard(acard, dummy_use)
				if dummy_use.card and dummy_use.to and dummy_use.to:length() > 0 then
					for _, p in sgs.qlist(dummy_use.to) do
						if p:getHp() <= 1 then
							keep = true
							break
						end
					end
					if dummy_use.to:length() > 1 then keep = true end
				end
				if keep then
					sgs.ai_use_priority.Slash = sgs.ai_use_priority.Drowning + 0.1
				else
					sgs.ai_use_priority.Slash = 2.6
					card = acard
					break
				end
			else
				card = acard
				break
			end
		end
	end
	if not card then return nil end
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	local card_str = ("drowning:sp_weizhen[%s:%s]=%d"):format(suit, number, card_id)
	local skillcard = sgs.Card_Parse(card_str)
	assert(skillcard)
	return skillcard
end

sgs.ai_cardneed.sp_weizhen = function(to, card, self)
	return card:isBlack() and (card:isKindOf("BasicCard") or card:isKindOf("TrickCard"))
end

sgs.ai_skill_use_func.sp_weizhen = function(card, use, self)
	if self.player:getMark("sp_weizhen_used") < 3 then
		use.card = card
		return
	end
end

--20 风神·吕蒙
--“刮目”AI
local sp_guamu_skill = {}
sp_guamu_skill.name = "sp_guamu"
table.insert(sgs.ai_skills, sp_guamu_skill)
sp_guamu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("sp_guamuCard") then return end
	return sgs.Card_Parse("#sp_guamuCard:.:")
end

sgs.ai_skill_use_func["#sp_guamuCard"] = function(card, use, self)
	if not self.player:hasUsed("#sp_guamuCard") then
		use.card = card
		if use.to then use.to:append(self.player) end
		return
	end
end

sgs.ai_skill_choice["sp_guamuONE"] = function(self, choices, data)
	return "sp_guamuONEthrow"
end

sgs.ai_use_value.sp_guamuCard = 8.5
sgs.ai_use_priority.sp_guamuCard = 9.5
sgs.ai_card_intention.sp_guamuCard = -80

--21 火神·周瑜
--“赤壁”AI
local sp_chibi_skill = {}
sp_chibi_skill.name = "sp_chibi"
table.insert(sgs.ai_skills, sp_chibi_skill)
sp_chibi_skill.getTurnUseCard = function(self)
	if self.player:getMark("@sp_chibi") == 0 then return end
	return sgs.Card_Parse("#sp_chibiCard:.:")
end

sgs.ai_skill_use_func["#sp_chibiCard"] = function(card, use, self)
	if self.player:getMark("@sp_chibi") > 0 then
		use.card = card
		return
	end
end

sgs.ai_use_value.sp_chibiCard = 8.5
sgs.ai_use_priority.sp_chibiCard = 9.5
sgs.ai_card_intention.sp_chibiCard = 80

--“神姿”AI
sgs.ai_skill_choice.sp_shenzi = function(self, choices, data)
	if (self.player:isKongcheng() or self.player:getHp() - self.player:getHandcardNum() > 1) and self.player:getHp() > 1 then
		return
		"sp_shenzi4cards"
	end
	if self.player:getHandcardNum() - self.player:getHp() > 2 then return "sp_shenzi1card" end
	return "sp_shenzi3cards"
end

--22 天神·诸葛
--“政神”AI（待补充）

--“祈天”AI
sgs.ai_skill_invoke.sp_qitian = true

sgs.ai_skill_choice.sp_qitian = function(self, choices, data)
	if self.player:getMark("&ShenZhi") < 4 then return "remove1szmark" end
	return "remove4szmarks"
end

sgs.ai_skill_playerchosen.sp_qitian = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
			return p
		end
	end
	return nil
end

--23 君神·曹操
--“煮酒”AI
sgs.ai_skill_invoke.sp_zhujiu = true

sgs.ai_skill_playerchosen.sp_zhujiu = function(self, targets)
	local targets = sgs.QList2Table(targets)
	self:sort(targets, "defense")
	for _, p in ipairs(targets) do
		if self:isEnemy(p) and not p:isKongcheng() then return p end
	end
end

local sp_zhujiu_skill = {}
sp_zhujiu_skill.name = "sp_zhujiu"
table.insert(sgs.ai_skills, sp_zhujiu_skill)
sp_zhujiu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("sp_zhujiuCard") or self.player:isKongcheng() then return end
	return sgs.Card_Parse("#sp_zhujiuCard:.:")
end

sgs.ai_skill_use_func["#sp_zhujiuCard"] = function(card, use, self)
	if not self.player:hasUsed("#sp_zhujiuCard") and not self.player:isKongcheng() then
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

sgs.ai_use_value.sp_zhujiuCard = 8.5
sgs.ai_use_priority.sp_zhujiuCard = 9.5
sgs.ai_card_intention.sp_zhujiuCard = 80

sgs.ai_skill_invoke["@sp_zhujiugetPindianCards"] = true

--24 战神·吕布
--“武极”AI
sgs.ai_skill_invoke["sp_wuji"] = true

sgs.ai_skill_choice["sp_wuji"] = function(self, choices, data)
	if self.player:getMaxHp() <= 3 then return "cancel" end
	if self.player:getHandcardNum() <= 3 then return "1" end
	return "2"
end

--“猛冠”AI
local sp_mengguan_skill = {}
sp_mengguan_skill.name = "sp_mengguan"
table.insert(sgs.ai_skills, sp_mengguan_skill)
sp_mengguan_skill.getTurnUseCard = function(self)
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	local card
	self:sortByUseValue(cards, true)
	for _, c in ipairs(cards) do
		if c:isKindOf("Weapon") then
			card = c
			break
		end
	end
	if not card then return nil end
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	local card_str = ("duel:sp_mengguan[%s:%s]=%d"):format(suit, number, card_id)
	local skillcard = sgs.Card_Parse(card_str)
	assert(skillcard)
	return skillcard
end

--“独勇”AI
sgs.ai_skill_invoke.sp_duyong = function(self, data)
	if self.player:isNude() then return false end
	local target = data:toPlayer()
	return not self:isFriend(target)
end

--25 枪神·赵云（这玩意还需要AI！？）
--“孤胆”AI
sgs.ai_skill_choice.sp_gudan = function(self, choices, data)
	return "1and0"
end

--26 暗神·司马
--“装病”AI
sgs.ai_skill_invoke.sp_zhuangbing = function(self, data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end

--AI获得“死士”牌：
local sp_sishi_skill = {}
sp_sishi_skill.name = "sp_sishi"
table.insert(sgs.ai_skills, sp_sishi_skill)
sp_sishi_skill.getTurnUseCard = function(self)
	if self.player:getPile("sp_ss"):length() < 2 then return end
	return sgs.Card_Parse("#sp_sishiCard:.:")
end

sgs.ai_skill_use_func["#sp_sishiCard"] = function(card, use, self)
	if self.player:getPile("sp_ss"):length() >= 2 and self.player:getHp() > 1 then --上古经典一血两牌理念
		use.card = card
		return
	end
end

sgs.ai_use_value.sp_sishiCard = 8.5
sgs.ai_use_priority.sp_sishiCard = 9.5
sgs.ai_card_intention.sp_sishiCard = -80

--27 剑神·刘备
--“英杰”AI
sgs.ai_skill_invoke["@sp_yingjie-xingxia"] = true

sgs.ai_skill_playerchosen["sp_yingjie"] = function(self, targets)
	targets = sgs.QList2Table(targets)
	return self.player
end

sgs.ai_skill_invoke["@sp_yingjie-zhangyi"] = true

sgs.ai_skill_playerchosen["sp_yingjiee"] = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isFriend(p) then
			return p
		end
	end
end

--“远志”AI
sgs.ai_skill_playerchosen.sp_yuanzhi = function(self, targets)
	local targets = sgs.QList2Table(targets)
	self:sort(targets, "defense")
	for _, p in ipairs(targets) do
		if self:isEnemy(p) and not p:isKongcheng() then
			return p
		end
	end
end

local sp_yuanzhi_skill = {}
sp_yuanzhi_skill.name = "sp_yuanzhi"
table.insert(sgs.ai_skills, sp_yuanzhi_skill)
sp_yuanzhi_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("sp_yuanzhiCard") or self.player:isKongcheng() and self.player:getMark("&sp_yuanzhiFQC") <= self.player:getMark("sp_yuanzhiUF") then return end
	return sgs.Card_Parse("#sp_yuanzhiCard:.:")
end

sgs.ai_skill_use_func["#sp_yuanzhiCard"] = function(card, use, self)
	if not self.player:hasUsed("#sp_yuanzhiCard") and not self.player:isKongcheng() and self.player:getMark("&sp_yuanzhiFQC") > self.player:getMark("sp_yuanzhiUF") then
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

sgs.ai_use_value.sp_yuanzhiCard = 8.5
sgs.ai_use_priority.sp_yuanzhiCard = 9.5
sgs.ai_card_intention.sp_yuanzhiCard = 80

sgs.ai_skill_choice.sp_yuanzhi = function(self, choices, data)
	return "2"
end

--28 军神·陆逊
--待补充（可以写，但会添乱）

--29 孤神·张辽
--......

--30 奇神·甘宁
--“袭营”AI
local sp_xiying_skill = {}
sp_xiying_skill.name = "sp_xiying"
table.insert(sgs.ai_skills, sp_xiying_skill)
sp_xiying_skill.getTurnUseCard = function(self)
	if self.player:getMark("@sp_xiying") == 0 then return end
	return sgs.Card_Parse("#sp_xiyingCard:.:")
end

sgs.ai_skill_use_func["#sp_xiyingCard"] = function(card, use, self)
	if self.player:getMark("@sp_xiying") > 0 and self.player:getHandcardNum() <= 3 then
		self:sort(self.enemies)
		self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 0 and enemy:getHandcardNum() - self.player:getHandcardNum() >= 3 then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.sp_xiyingCard = 9.5
sgs.ai_use_priority.sp_xiyingCard = 3.5
sgs.ai_card_intention.sp_xiyingCard = 30

--（J.SP赵云）“赤心”AI
local chixin_skill = {}
chixin_skill.name = "chixin"
table.insert(sgs.ai_skills, chixin_skill)
chixin_skill.getTurnUseCard = function(self)
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	local diamond_card
	self:sortByUseValue(cards, true)
	for _, card in ipairs(cards) do
		if card:getSuit() == sgs.Card_Diamond then
			diamond_card = card
			break
		end
	end
	if not diamond_card then return nil end
	local suit = diamond_card:getSuitString()
	local number = diamond_card:getNumberString()
	local card_id = diamond_card:getEffectiveId()
	local card_str = ("slash:chixin[%s:%s]=%d"):format(suit, number, card_id)
	local slash = sgs.Card_Parse(card_str)
	assert(slash)

	return slash
end

sgs.ai_view_as.chixin = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place ~= sgs.Player_PlaceSpecial then
		if card:getSuit() == sgs.Card_Diamond and player:getPhase() ~= sgs.Player_NotActive then
			return ("slash:chixin[%s:%s]=%d"):format(suit, number, card_id)
		elseif card:getSuit() == sgs.Card_Diamond and player:getPhase() == sgs.Player_NotActive then
			return ("jink:chixin[%s:%s]=%d"):format(suit, number, card_id)
		end
	end
end

sgs.chixin_keep_value = {
	Peach = 6,
	Analeptic = 5.8,
	Jink = 5.7,
	FireSlash = 5.7,
	Slash = 5.6,
	ThunderSlash = 5.5,
	ExNihilo = 4.7,
	IceSlash = 5.9
}

sgs.ai_skill_playerchosen.chixinDrawANDGive = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isFriend(p) then
			return p
		end
	end
	return self.player
end

--31 界刘繇
--“戡难”AI
local fcj_kannan_skill = {}
fcj_kannan_skill.name = "fcj_kannan"
table.insert(sgs.ai_skills, fcj_kannan_skill)
fcj_kannan_skill.getTurnUseCard = function(self)
	if self.player:getMark("fcj_kannanUsed") >= self.player:getHp() or self.player:isKongcheng() then return end
	return sgs.Card_Parse("#fcj_kannanCard:.:")
end

sgs.ai_skill_use_func["#fcj_kannanCard"] = function(card, use, self)
	if self.player:getMark("fcj_kannanUsed") < self.player:getHp() and not self.player:isKongcheng() then
		self:sort(self.enemies)
		self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 0 and not enemy:hasFlag("fcj_kannanSelected") and not enemy:isKongcheng() then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.fcj_kannanCard = 8.5
sgs.ai_use_priority.fcj_kannanCard = 9.5
sgs.ai_card_intention.fcj_kannanCard = 80

sgs.ai_skill_choice.fcj_kannan = function(self, choices, data)
	return "1"
end

--32 界庞德公
--“评才”AI（无脑玄剑）
local fcj_pingcai_skill = {}
fcj_pingcai_skill.name = "fcj_pingcai"
table.insert(sgs.ai_skills, fcj_pingcai_skill)
fcj_pingcai_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("fcj_pingcaiCard") then return end
	return sgs.Card_Parse("#fcj_pingcaiCard:.:")
end

sgs.ai_skill_use_func["#fcj_pingcaiCard"] = function(card, use, self)
	if not self.player:hasUsed("#fcj_pingcaiCard") then
		use.card = card
		return
	end
end

sgs.ai_use_value.fcj_pingcaiCard = 8.5
sgs.ai_use_priority.fcj_pingcaiCard = 9.5
sgs.ai_card_intention.fcj_pingcaiCard = -80

sgs.ai_skill_choice["@fcj_pingcai-ChooseTreasure"] = function(self, choices, data)
	return "xuanjian"
end

sgs.ai_skill_playerchosen["fcj_pingcaiXuanjian"] = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do                                 --先找体力值过低的队友
		if self:isFriend(p) and p:getMaxHp() > 2 and p:getHp() == 1 then --不写<=1，跳过周泰这个体力值不与生命危险程度挂钩的
			return p
		end
	end
	for _, p in ipairs(targets) do --再找受伤队友
		if self:isFriend(p) and p:isWounded() then
			return p
		end
	end
	for _, p in ipairs(targets) do --再找健康但手牌过少的队友
		if self:isFriend(p) and p:getHandcardNum() < 2 then
			return p
		end
	end
	for _, p in ipairs(targets) do --再找一般健康队友
		if self:isFriend(p) then
			return p
		end
	end
	return self.player --最后给自己
end

--33 界陈到
--“往烈”AI
sgs.ai_skill_invoke.fcj_wanglie = function(self, data)
	local use = data:toCardUse()
	local target = data:toPlayer()
	return use.card:isDamageCard() and not self:isFriend(target)
end

sgs.ai_skill_choice.fcj_wanglie = function(self, choices, data)
	if self.player:hasFlag("fcj_wanglie_cantchooseHit") and self.player:hasFlag("fcj_wanglie_cantchooseDamage") then
		return
		"Beishui"
	end
	return "Hit" or "Damage"
end

--34 界赵统赵广（加强部分为自动发动，无需写ai）

--35 界于禁-旧
--“毅重”AI
--给技能就不写了，怕ex到玩家......⁄(⁄ ⁄•⁄ω⁄•⁄ ⁄)⁄

--36 界曹昂
--“慷慨”AI

local function getKangkaiCard(self, target, data)
	local use = data:toCardUse()
	local weapon, armor, def_horse, off_horse = {}, {}, {}, {}
	for _, card in sgs.qlist(self.player:getHandcards()) do
		if card:isKindOf("Weapon") then
			table.insert(weapon, card)
		elseif card:isKindOf("Armor") then
			table.insert(armor, card)
		elseif card:isKindOf("DefensiveHorse") then
			table.insert(def_horse, card)
		elseif card:isKindOf("OffensiveHorse") then
			table.insert(off_horse, card)
		end
	end
	if #armor > 0 then
		for _, card in ipairs(armor) do
			if ((not target:getArmor() and not target:hasSkills("bazhen|yizhong"))
					or (target:getArmor() and self:evaluateArmor(card, target) >= self:evaluateArmor(target:getArmor(), target)))
				and not (card:isKindOf("Vine") and use.card:isKindOf("FireSlash") and self:slashIsEffective(use.card, target, use.from)) then
				return card:getEffectiveId()
			end
		end
	end
	if self:needToThrowArmor()
		and ((not target:getArmor() and not target:hasSkills("bazhen|yizhong"))
			or (target:getArmor() and self:evaluateArmor(self.player:getArmor(), target) >= self:evaluateArmor(target:getArmor(), target)))
		and not (self.player:getArmor():isKindOf("Vine") and use.card:isKindOf("FireSlash") and self:slashIsEffective(use.card, target, use.from)) then
		return self.player:getArmor():getEffectiveId()
	end
	if #def_horse > 0 then return def_horse[1]:getEffectiveId() end
	if #weapon > 0 then
		for _, card in ipairs(weapon) do
			if not target:getWeapon()
				or (self:evaluateArmor(card, target) >= self:evaluateArmor(target:getWeapon(), target)) then
				return card:getEffectiveId()
			end
		end
	end
	if self.player:getWeapon() and self:evaluateWeapon(self.player:getWeapon()) < 5
		and (not target:getArmor()
			or (self:evaluateArmor(self.player:getWeapon(), target) >= self:evaluateArmor(target:getWeapon(), target))) then
		return self.player:getWeapon():getEffectiveId()
	end
	if #off_horse > 0 then return off_horse[1]:getEffectiveId() end
	if self.player:getOffensiveHorse()
		and ((self.player:getWeapon() and not self.player:getWeapon():isKindOf("Crossbow")) or self.player:hasSkills("mashu|tuntian")) then
		return self.player:getOffensiveHorse():getEffectiveId()
	end
end
sgs.ai_skill_invoke.fcj_kangkai = function(self, data)
	self.fcj_kangkai_give_id = nil
	if hasManjuanEffect(self.player) then return false end
	local target = data:toPlayer()
	if not target then return false end
	if target:objectName() == self.player:objectName() then
		return true
	elseif not self:isFriend(target) then
		return hasManjuanEffect(target)
	else
		local id = getKangkaiCard(self, target, self.player:getTag("fcj_kangkaiSlash"))
		if id then return true else return not self:needKongcheng(target, true) end
	end
end

sgs.ai_skill_cardask["@fcj_kangkai_give"] = function(self, data, pattern, target)
	if self:isFriend(target) then
		local id = getKangkaiCard(self, target, data)
		if id then return "$" .. id end
		if self:getCardsNum("Jink") > 1 then
			for _, card in sgs.qlist(self.player:getHandcards()) do
				if isCard("Jink", card, target) then return "$" .. card:getEffectiveId() end
			end
		end
		for _, card in sgs.qlist(self.player:getHandcards()) do
			if not self:isValuableCard(card) then return "$" .. card:getEffectiveId() end
		end
	else
		local to_discard = self:askForDiscard("dummyreason", 1, 1, false, true)
		if #to_discard > 0 then return "$" .. to_discard[1] end
	end
end

sgs.ai_skill_invoke["fcj_kangkai_hedraw"] = true

sgs.ai_skill_invoke["fcj_kangkai_use"] = function(self, data)
	local use = self.player:getTag("fcj_kangkaiSlash"):toCardUse()
	local card = self.player:getTag("fcj_kangkaiGivenCard"):toCard()
	if not use.card or not card then return false end
	if card:isKindOf("Vine") and use.card:isKindOf("FireSlash") and self:slashIsEffective(use.card, self.player, use.from) then return false end
	if ((card:isKindOf("DefensiveHorse") and self.player:getDefensiveHorse())
			or (card:isKindOf("OffensiveHorse") and (self.player:getOffensiveHorse() or (self.player:hasSkill("drmashu") and self.player:getDefensiveHorse()))))
		and not self.player:hasSkills(sgs.lose_equip_skill) then
		return false
	end
	if card:isKindOf("Armor") and ((self.player:hasSkills("bazhen|yizhong") and not self.player:getArmor())
			or (self.player:getArmor() and self:evaluateArmor(card) < self:evaluateArmor(self.player:getArmor()))) then
		return false
	end
	if card:isKindOf("Weanpon") and (self.player:getWeapon() and self:evaluateArmor(card) < self:evaluateArmor(self.player:getWeapon())) then return false end
	return true
end

--37 界吕岱
--“勤国”AI
sgs.ai_skill_use["@@fcj_qinguo"] = function(self, prompt, method)
	self:updatePlayers()
	self:sort(self.enemies, "defense")
	local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
	for _, enemy in ipairs(self.enemies) do
		if self.player:inMyAttackRange(enemy) and not self:slashProhibit(slash, enemy)
			and self:isGoodTarget(enemy, self.enemies, slash) and self:slashIsEffective(slash, enemy)
		then
			return "#fcj_qinguoCard:.:->" .. enemy:objectName()
		end
	end
	return "."
end

--38 界陆抗
--“决堰”AI
local fcj_jueyan_skill = {}
fcj_jueyan_skill.name = "fcj_jueyan"
table.insert(sgs.ai_skills, fcj_jueyan_skill)
fcj_jueyan_skill.getTurnUseCard = function(self, inclusive)
	if self.player:hasEquipArea() then
		return sgs.Card_Parse("#fcj_jueyan:.:")
	end
end

sgs.ai_skill_use_func["#fcj_jueyan"] = function(card, use, self)
	use.card = card
end

sgs.ai_skill_choice["fcj_jueyan"] = function(self, choices, data)
	local has_fcj_jueyan_slash_target = false
	self:updatePlayers()
	self:sort(self.enemies, "defense")
	for _, enemy in ipairs(self.enemies) do
		if self.player:distanceTo(enemy) == 1 and not enemy:hasArmorEffect("vine") then
			has_fcj_jueyan_slash_target = true
		end
	end
	local items = choices:split("+")
	if self.player:hasEquipArea(0) and self:getCardsNum("Slash") > 2 and has_fcj_jueyan_slash_target then
		return "fcj_jueyan0"
	elseif self.player:hasEquipArea(4) and self:getCardsNum("ExNihilo") > 0 then
		return "fcj_jueyan4"
	elseif self.player:hasEquipArea(2) and self.player:hasEquipArea(3) and not has_fcj_jueyan_slash_target and self:getCardsNum("Slash") > 0 then
		return "fcj_jueyan2"
	elseif self.player:hasEquipArea(1) then
		return "fcj_jueyan1"
	else
		return items[1]
	end
end

sgs.ai_use_value.fcj_jueyan = 10
sgs.ai_use_priority.fcj_jueyan = 10
sgs.ai_card_intention.fcj_jueyan = -100

--“怀柔”AI
local ps_huairou_skill = {}
ps_huairou_skill.name = "ps_huairou"
table.insert(sgs.ai_skills, ps_huairou_skill)
ps_huairou_skill.getTurnUseCard = function(self, inclusive)
	local usable_cards = sgs.QList2Table(self.player:getCards("he"))
	for _, c in ipairs(usable_cards) do
		if self.player:hasArmorEffect("silver_lion") and c:isKindOf("SilverLion")
			and self.player:isWounded() then
			return sgs.Card_Parse(string.format("#ps_huairou:%s:", c:getEffectiveId()))
		elseif not self.player:hasEquipArea(0) and c:isKindOf("Weapon") then
			return sgs.Card_Parse(string.format("#ps_huairou:%s:", c:getEffectiveId()))
		elseif not self.player:hasEquipArea(1) and c:isKindOf("Armor") then
			return sgs.Card_Parse(string.format("#ps_huairou:%s:", c:getEffectiveId()))
		elseif not self.player:hasEquipArea(2) and c:isKindOf("DefensiveHorse") then
			return sgs.Card_Parse(string.format("#ps_huairou:%s:", c:getEffectiveId()))
		elseif not self.player:hasEquipArea(3) and c:isKindOf("OffensiveHorse") then
			return sgs.Card_Parse(string.format("#ps_huairou:%s:", c:getEffectiveId()))
		elseif not self.player:hasEquipArea(4) and c:isKindOf("Treasure") then
			return sgs.Card_Parse(string.format("#ps_huairou:%s:", c:getEffectiveId()))
		end
	end
end

sgs.ai_skill_use_func["#ps_huairou"] = function(card, use, self)
	use.card = card
end

sgs.ai_use_value.ps_huairou = 10
sgs.ai_use_priority.ps_huairou = 10
sgs.ai_card_intention.ps_huairou = -100
