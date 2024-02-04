--祢衡
--“狂才”AI
sgs.ai_skill_invoke.mbkuangcai = true

--“舌剑”AI
sgs.ai_skill_playerchosen.mbshejian = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
			return p
		end
	end
	return nil
end

--星黄忠
--“义释”AI
sgs.ai_skill_invoke.styishi = function(self, data)
	local use = data:toCardUse()
	return self:isFriend(use.from)
end

--“骑射”AI
sgs.ai_view_as.stqishe = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if (card_place ~= sgs.Player_PlaceSpecial or player:getPile("wooden_ox"):contains(card_id))
		and not (card:isKindOf("WoodenOx") and player:getPile("wooden_ox"):length() > 0) and card:isKindOf("EquipCard") then
		return ("analeptic:stqishe[%s:%s]=%d"):format(suit, number, card_id)
	end
end

sgs.ai_cardneed.stqishe = function(to, card)
	return card:isKindOf("EquipCard")
end

--皇甫嵩
--“讨乱”AI
sgs.ai_skill_invoke.sjyan_taoluan = function(self, data)
	local use = data:toCardUse()
	return not self:isFriend(use.from)
end

sgs.ai_skill_choice.sjyan_taoluan = function(self, choices, data)
	return "2"
end

--“势击”AI
sgs.ai_skill_invoke.sjyan_shiji = function(self, data)
	local use = data:toCardUse()
	return not self:isFriend(use.from)
end

--“整军”AI
sgs.ai_skill_invoke.sjyan_zhengjun = true

--“整军”整肃奖励选择
sgs.ai_skill_choice["@ZS_reward"] = function(self, choices, data)
	if self.player:getHp() <= 1 and self.player:getHandcardNum() > 1 then return "recover" end
	return "draw"
end

--“整军”整肃共同奖励对象选择
sgs.ai_skill_playerchosen.sjyan_zhengjun = function(self, targets)
	local targets = sgs.QList2Table(targets)
	self:sort(self.friends_noself)
	for _, p in ipairs(self.friends_noself) do
		if self:isFriend(p) then
			return p
		end
	end
	return nil
end

--星魏延

--马钧
--“精械”AI
local mbgjingxie_skill = {}
mbgjingxie_skill.name = "mbgjingxie"
table.insert(sgs.ai_skills, mbgjingxie_skill)
mbgjingxie_skill.getTurnUseCard = function(self)
	return sgs.Card_Parse("#mbgjingxieCard:.:")
end

sgs.ai_skill_use_func["#mbgjingxieCard"] = function(card, use, self)
	local equipments = sgs.QList2Table(self.player:getCards("he"))
	for _, e in ipairs(equipments) do
		if e:isKindOf("Crossbow") then
			local card_str = string.format("#mbgjingxieCard:%s:", e:getEffectiveId())
			local acard = sgs.Card_Parse(card_str)
			use.card = acard
			return
		end
		if e:isKindOf("EightDiagram") then
			local card_str = string.format("#mbgjingxieCard:%s:", e:getEffectiveId())
			local acard = sgs.Card_Parse(card_str)
			use.card = acard
			return
		end
		if e:isKindOf("RenwangShield") then
			local card_str = string.format("#mbgjingxieCard:%s:", e:getEffectiveId())
			local acard = sgs.Card_Parse(card_str)
			use.card = acard
			return
		end
		if e:isKindOf("SilverLion") then
			local card_str = string.format("#mbgjingxieCard:%s:", e:getEffectiveId())
			local acard = sgs.Card_Parse(card_str)
			use.card = acard
			return
		end
		if e:isKindOf("Vine") then
			local card_str = string.format("#mbgjingxieCard:%s:", e:getEffectiveId())
			local acard = sgs.Card_Parse(card_str)
			use.card = acard
			return
		end
	end
end

sgs.ai_use_value.mbgjingxieCard = 9.9
sgs.ai_use_priority.mbgjingxieCard = 9.9
sgs.ai_card_intention.mbgjingxieCard = -99

sgs.ai_skill_cardask["@mbgjingxie"] = function(self, data, pattern, target, target2)
	local useable_cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByUseValue(useable_cards, true)
	for _, c in ipairs(useable_cards) do
		if c:isKindOf("Armor") then
			return c:toString()
		end
	end
end

sgs.mbgjingxie_keep_value = {
	Peach = 6,
	Jink = 4.8,
	Armor = 5
}
--==专属强化装备AI==--
--元戎精械弩
sgs.weapon_range.Yrjxn = 3

sgs.ai_use_priority.Yrjxn = 2.63

--先天八卦阵
sgs.ai_use_priority.Xtbgz = 0.8

sgs.ai_skill_invoke.Xtbgz = function(self, data)
	local dying = 0
	local handang = self.room:findPlayerBySkillName("nosjiefan")
	for _, aplayer in sgs.qlist(self.room:getAlivePlayers()) do
		if aplayer:getHp() < 1 and not aplayer:hasSkill("nosbuqu") then
			dying = 1
			break
		end
	end
	if handang and self:isFriend(handang) and dying > 0 then return false end
	local heart_jink = false
	for _, card in sgs.qlist(self.player:getCards("he")) do
		if card:getSuit() == sgs.Card_Heart and isCard("Jink", card, self.player) then
			heart_jink = true
			break
		end
	end
	if self:hasSkills("tiandu|leiji|nosleiji|gushou") then
		if self.player:hasFlag("dahe") and not heart_jink then return true end
		if sgs.hujiasource and not self:isFriend(sgs.hujiasource) and (sgs.hujiasource:hasFlag("dahe") or self.player:hasFlag("dahe")) then return true end
		if sgs.lianlisource and not self:isFriend(sgs.lianlisource) and (sgs.lianlisource:hasFlag("dahe") or self.player:hasFlag("dahe")) then return true end
		if self.player:hasFlag("dahe") and handang and self:isFriend(handang) and dying > 0 then return true end
	end
	if self.player:getHandcardNum() == 1 and self:getCardsNum("Jink") == 1 and self.player:hasSkills("zhiji|beifa") and self:needKongcheng() then
		local enemy_num = self:getEnemyNumBySeat(self.room:getCurrent(), self.player, self.player)
		if self.player:getHp() > enemy_num and enemy_num <= 1 then return false end
	end
	if handang and self:isFriend(handang) and dying > 0 then return false end
	if self.player:hasFlag("dahe") then return false end
	if sgs.hujiasource and (not self:isFriend(sgs.hujiasource) or sgs.hujiasource:hasFlag("dahe")) then return false end
	if sgs.lianlisource and (not self:isFriend(sgs.lianlisource) or sgs.lianlisource:hasFlag("dahe")) then return false end
	if self:getDamagedEffects(self.player, nil, true) or self:needToLoseHp(self.player, nil, nil, true) then return false end
	if self:getCardsNum("Jink") == 0 then return true end
	local zhangjiao = self.room:findPlayerBySkillName("guidao")
	if zhangjiao and self:isEnemy(zhangjiao) then
		if getKnownCard(zhangjiao, self.player, "black", false, "he") > 1 then return false end
		if self:getCardsNum("Jink") > 1 and getKnownCard(zhangjiao, self.player, "black", false, "he") > 0 then return false end
	end
	if self:getCardsNum("Jink") > 0 and self.player:getPile("incantation"):length() > 0 then return false end
	return true
end

sgs.ai_armor_value["_xtbgz"] = function(player, self, card)
	local haszj = self:hasSkills("guidao", self:getEnemies(player))
	if haszj then
		return 2
	end
	if player:hasSkills("tiandu|leiji|nosleiji|noszhenlie|gushou") then
		return 6
	end
	if self.role == "loyalist" and self.player:getKingdom() == "wei" and not self.player:hasSkill("bazhen") and getLord(self.player) and getLord(self.player):hasLordSkill("hujia") then
		return 5
	end
	return 4
end

--仁王金刚盾
sgs.ai_use_priority.Rwjgd = 0.85

sgs.ai_armor_value["_rwjgd"] = function(player, self, card)
	if player:hasSkill("yizhong") then return 0 end
	if player:hasSkill("bazhen") then return 0 end
	if player:hasSkills("leiji|nosleiji") and getKnownCard(player, self.player, "Jink", true) > 1 and player:hasSkill("guidao")
		and getKnownCard(player, self.player, "black", false, "he") > 0 then
		return 0
	end
	return 4.5
end

--照月狮子盔
sgs.ai_use_priority.Zyszk = 1.0

sgs.ai_armor_value["_zyszk"] = function(player, self, card)
	if self:hasWizard(self:getEnemies(player), true) then
		for _, player in sgs.qlist(self.room:getAlivePlayers()) do
			if player:containsTrick("lightning") then return 5 end
		end
	end
	if self.player:isWounded() and not self.player:getArmor() then return 9 end
	if self.player:isWounded() and self:getCardsNum("Armor", "h") >= 2
		and not self.player:hasArmorEffect("silver_lion") then
		return 8
	end
	return 1
end

--桐油百韧甲
sgs.ai_use_priority.Tybrj = 0.95
--===============--

--“巧思”AI
local mbgqiaosi_skill = {}
mbgqiaosi_skill.name = "mbgqiaosi"
table.insert(sgs.ai_skills, mbgqiaosi_skill)
mbgqiaosi_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#mbgqiaosiCard") then return end
	return sgs.Card_Parse("#mbgqiaosiCard:.:")
end

sgs.ai_skill_use_func["#mbgqiaosiCard"] = function(card, use, self)
	if not self.player:hasUsed("#mbgqiaosiCard") then
		use.card = card
	end
end

sgs.ai_use_value.mbgqiaosiCard = 8.5
sgs.ai_use_priority.mbgqiaosiCard = 9.5
sgs.ai_card_intention.mbgqiaosiCard = -80

sgs.ai_skill_choice["ShuiZhuanBaiXiTu"] = function(self, choices, data)
	return "1" or "6"
end

sgs.ai_skill_choice.mbgqiaosi = function(self, choices, data)
	self:updatePlayers()
	for _, friend in ipairs(self.friends_noself) do
		if not self:needKongcheng(friend, true) and not hasManjuanEffect(friend) then
			return "give"
		end
	end
	return "throw"
end

sgs.ai_skill_playerchosen.mbgqiaosi = function(self, targets)
	local targets = sgs.QList2Table(targets)
	self:sort(targets, "handcard")
	for _, p in ipairs(targets) do
		if self:isFriend(p) and not self:needKongcheng(p, true) and not hasManjuanEffect(p) then
			return p
		end
	end
	for _, p in ipairs(targets) do
		return p
	end
end

sgs.ai_playerchosen_intention.mbgqiaosi = -80
