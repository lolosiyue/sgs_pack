--mobileGod.lua的武将/卡牌AI

--电脑有一定概率更换皮肤
sgs.ai_skill_invoke.mobileGOD_SkinChange = function(self, data)
    if math.random() > 0.5 then return true end
	return false
end
----

--==手杀神武将AI==--
--界神郭嘉
  --“慧识”AI
local f_huishi_skill = {}
f_huishi_skill.name = "f_huishi"
table.insert(sgs.ai_skills, f_huishi_skill)
f_huishi_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("f_huishiCard") or self.player:getMaxHp() >= 10 then return end
	return sgs.Card_Parse("#f_huishiCard:.:")
end

sgs.ai_skill_use_func["#f_huishiCard"] = function(card, use, self)
    if not self.player:hasUsed("#f_huishiCard") and self.player:getMaxHp() < 10 then
        use.card = card
	    return
	end
end

sgs.ai_skill_choice["@f_huishiAdd"] = function(self, choices, data)
    if self.player:isWounded() then return "hp" end
	return "mhp"
end

sgs.ai_skill_choice["@f_huishiLose"] = function(self, choices, data)
    if self.player:getMaxHp() <= 1 then return "hp" end
	if self.player:isWounded() and self.player:getMaxHp() > 2 then return "mhp" end
	return "hp"
end

sgs.ai_skill_invoke["@f_huishi_continue"] = true

    --“慧识”给牌
sgs.ai_skill_playerchosen["f_huishi"] = function(self, targets)
    local targets = sgs.QList2Table(targets)
	self:sort(self.friends_noself)
	for _, p in ipairs(self.friends_noself) do --如果自己手牌足够又有队友手牌不够，给队友
		if self:isFriend(p) and p:getHandcardNum() < 3 and self.player:getHandcardNum() > self.player:getMaxHp() then
			return p
		end
	end
    return self.player
end

sgs.ai_use_value.f_huishiCard = 8.5
sgs.ai_use_priority.f_huishiCard = 9.5
sgs.ai_card_intention.f_huishiCard = -80

  --“天翊”AI（印卡就不写了，影响到玩家体验也不好）
sgs.ai_skill_playerchosen["@f_tianyi"] = function(self, targets)
    targets = sgs.QList2Table(targets)
	return self.player
end

  --“辉逝”AI
local f_huishii_skill = {}
f_huishii_skill.name = "f_huishii"
table.insert(sgs.ai_skills, f_huishii_skill)
f_huishii_skill.getTurnUseCard = function(self)
	if self.player:getMark("@f_huishii") == 0 and self.player:getMaxHp() < 5 then return end
	return sgs.Card_Parse("#f_huishiiCard:.:")
end

sgs.ai_skill_use_func["#f_huishiiCard"] = function(card, use, self)
    if self.player:getMark("@f_huishii") > 0 and self.player:getMaxHp() >= 5 and self.player:getMark("f_tianyi") > 0 then
        use.card = card
		if use.to then use.to:append(self.player) end
		return
	end
end

sgs.ai_use_value.f_huishiiCard = 9.6
sgs.ai_use_priority.f_huishiiCard = 9.8
sgs.ai_card_intention.f_huishiiCard = -99





--

--界神荀彧
  --锦囊【奇正相生】（正兵与奇兵的智能用法已写进锦囊里，但也不够智能；无懈AI在smart-ai.lua里）
    --使用AI
function SmartAI:useCardFqizhengxiangsheng(card, use)
	for _, enemy in ipairs(self.enemies) do
		if self:objectiveLevel(enemy) > 0 and not self.player:isProhibited(enemy, card) then
			use.card = card
			if use.to then use.to:append(enemy) end
		    return
		end
	end
end

sgs.ai_keep_value.Fqizhengxiangsheng = 3.8
sgs.ai_use_value.Fqizhengxiangsheng = 8.5
sgs.ai_use_priority.Fqizhengxiangsheng = 9.5
sgs.ai_card_intention.Fqizhengxiangsheng = 80

  --“天佐”AI（无脑）
sgs.ai_skill_invoke.f_tianzuo = true

  --“定汉”AI（仅主动增加对自己有益锦囊的记录）
sgs.ai_skill_invoke.f_dinghanMR = function(self, data)
    if self.player:getMark("dzxj") > 0 and self.player:getMark("wzsy") > 0 and self.player:getMark("wgfd") > 0 and self.player:getMark("tyjy") > 0 then return false end
	return true
end

sgs.ai_skill_choice.f_dinghan = function(self, choices, data)
    if self.player:getMark("dzxj") > 0 and self.player:getMark("wzsy") > 0 and self.player:getMark("wgfd") > 0 and self.player:getMark("tyjy") > 0 then return "cancel" end
	return "addtrickcard"
end

sgs.ai_skill_choice["@f_dinghan1"] = function(self, choices, data) --不包括“无懈可击”，因为本身具有挡锦囊的能力
    if self.player:getMark("dzxj") > 0 or (self:getCardsNum("ExNihilo") > 0 and self:getCardsNum("Dongzhuxianji") == 0) then return "wzsy" end
	if self.player:getMark("dzxj") > 0 and self.player:getMark("wzsy") > 0 then return "wgfd" end
	if self.player:getMark("dzxj") > 0 and self.player:getMark("wzsy") > 0 and self.player:getMark("wgfd") > 0 then return "tyjy" end
	if self.player:getMark("dzxj") > 0 and self.player:getMark("wzsy") > 0 and self.player:getMark("wgfd") > 0 and self.player:getMark("tyjy") > 0 then return "cancel" end
	return "dzxj"
end

--神太史慈-第二版
  --“破围”AI
sgs.ai_skill_choice.f_poweii = function(self, choices, data)
	return "2"
end

  --“神著”AI
sgs.ai_skill_choice.f_shenzhuoo = function(self, choices, data)
	if self:getCardsNum("Slash") == 0 then return "2" end
	return "1"
end

--界神孙策
  --“英霸”AI
local imba_skill = {}
imba_skill.name = "imba"
table.insert(sgs.ai_skills, imba_skill)
imba_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("imbaCard") and self.player:getMaxHp() <= 2 then return end
	return sgs.Card_Parse("#imbaCard:.:")
end

sgs.ai_skill_use_func["#imbaCard"] = function(card, use, self)
    if not self.player:hasUsed("#imbaCard") and self.player:getMaxHp() > 2 then
		self:sort(self.enemies)
	    self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
		    if self:objectiveLevel(enemy) > 0 and enemy:getMaxHp() > 1 then
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
	end
end

sgs.ai_use_value.imbaCard = 8.5
sgs.ai_use_priority.imbaCard = 9.5
sgs.ai_card_intention.imbaCard = 80

  --“冯河”AI（鉴定为：春春的芝长）
sgs.ai_skill_playerchosen.f_pingheDefuseDamage = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
	    if self:isFriend(p) then
		    return p
		end
	end
end

--张仲景-测试初版
  --“疗疫”AI
    --待补充。

  --“病论”AI
--[[local f_binglun_skill = {}
f_binglun_skill.name = "f_binglun"
table.insert(sgs.ai_skills, f_binglun_skill)
f_binglun_skill.getTurnUseCard = function(self)
	if not (self.player:getPile("f_REN"):isEmpty() or self.player:hasUsed("f_binglunCard")) then
		return sgs.Card_Parse("@f_binglunCard=" .. self.player:getPile("f_REN"):first())
	end
	return nil
end

sgs.ai_skill_use_func["#f_binglunCard"] = function(card, use, self)
    if self.player:getPile("f_REN"):length() > 0 and not self.player:hasUsed("#f_binglunCard") then
		self:sort(self.friends_noself)
		for _, friend in ipairs(self.friends_noself) do
		    if self:isFriend(friend) then
			    use.card = card
			    if use.to then use.to:append(friend) end
		        return
			end
		end
		if use.to then use.to:append(self.player) end
		return
	end
end

sgs.ai_use_value.f_binglunCard = 8.5
sgs.ai_use_priority.f_binglunCard = 9.5
sgs.ai_card_intention.f_binglunCard = -80]]

sgs.ai_skill_choice.f_binglun = function(self, choices, data)
	if self.player:isWounded() and self:getCardsNum("Peach") == 0 then return "2" end
	if self.player:getHandcardNum() < 2 then return "1" end
	return "2"
end

--海外服神吕蒙
  --“涉猎”AI
sgs.ai_skill_invoke.osshelie = true

sgs.ai_skill_choice.osshelie = function(self, choices, data)
	return "1"
end

  --“攻心”AI
local osgongxin_skill = {}
osgongxin_skill.name = "osgongxin"
table.insert(sgs.ai_skills, osgongxin_skill)
osgongxin_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#osgongxinCard") then return end
	local osgongxin_card = sgs.Card_Parse("#osgongxinCard:.:")
	assert(osgongxin_card)
	return osgongxin_card
end

sgs.ai_skill_use_func["#osgongxinCard"] = function(card, use, self)
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

sgs.ai_skill_askforag.osgongxin = function(self, card_ids)
	self.osgongxinchoice = nil
	local target = self.player:getTag("osgongxin"):toPlayer()
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
			self.osgongxinchoice = "discard"
		else
			self.osgongxinchoice = "put"
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
			self.osgongxinchoice = "put"
			return valuable
		end
		if card:isKindOf("TrickCard") or card:isKindOf("Indulgence") or card:isKindOf("SupplyShortage") then
			local dummy_use = { isDummy = true }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				self.osgongxinchoice = "put"
				return valuable
			end
		end
		if card:isKindOf("Jink") and self:getCardsNum("Jink") == 0 then
			self.osgongxinchoice = "put"
			return valuable
		end
		if card:isKindOf("Nullification") and self:getCardsNum("Nullification") == 0 then
			self.osgongxinchoice = "put"
			return valuable
		end
		if card:isKindOf("Slash") and self:slashIsAvailable() then
			local dummy_use = { isDummy = true }
			self:useBasicCard(card, dummy_use)
			if dummy_use.card then
				self.osgongxinchoice = "put"
				return valuable
			end
		end
		self.osgongxinchoice = "discard"
		return valuable
	end
	local hasLightning, hasIndulgence, hasSupplyShortage
	local tricks = nextAlive:getJudgingArea()
	if not tricks:isEmpty() and not nextAlive:containsTrick("YanxiaoCard") then
		local trick = tricks:at(tricks:length() - 1)
		if self:hasTrickEffective(trick, nextAlive) then
			if trick:isKindOf("Lightning") then hasLightning = true
			elseif trick:isKindOf("Indulgence") then hasIndulgence = true
			elseif trick:isKindOf("SupplyShortage") then hasSupplyShortage = true
			end
		end
	end
	if self:isEnemy(nextAlive) and nextAlive:hasSkill("luoshen") and valuable then
		self.osgongxinchoice = "put"
		return valuable
	end
	if nextAlive:hasSkill("yinghun") and nextAlive:isWounded() then
		self.osgongxinchoice = self:isFriend(nextAlive) and "put" or "discard"
		return valuable
	end
	if target:hasSkill("hongyan") and hasLightning and self:isEnemy(nextAlive) and not (nextAlive:hasSkill("qiaobian") and nextAlive:getHandcardNum() > 0) then
		for _, id in ipairs(card_ids) do
			local card = sgs.Sanguosha:getEngineCard(id)
			if card:getSuit() == sgs.Card_Spade and card:getNumber() >= 2 and card:getNumber() <= 9 then
				self.osgongxinchoice = "put"
				return id
			end
		end
	end
	if hasIndulgence and self:isFriend(nextAlive) then
		self.osgongxinchoice = "put"
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
			self.osgongxinchoice = "put"
			return valuable
		end
	end
	if self:isFriend(nextAlive) and not self:willSkipDrawPhase(nextAlive) and not self:willSkipPlayPhase(nextAlive)
		and not nextAlive:hasSkill("luoshen")
		and not nextAlive:hasSkill("tuxi") and not (nextAlive:hasSkill("qiaobian") and nextAlive:getHandcardNum() > 0) then
		if (peach and valuable == peach) or (ex_nihilo and valuable == ex_nihilo) then
			self.osgongxinchoice = "put"
			return valuable
		end
		if jink and valuable == jink and getCardsNum("Jink", nextAlive) < 1 then
			self.osgongxinchoice = "put"
			return valuable
		end
		if nullification and valuable == nullification and getCardsNum("Nullification", nextAlive) < 1 then
			self.osgongxinchoice = "put"
			return valuable
		end
		if slash and valuable == slash and self:hasCrossbowEffect(nextAlive) then
			self.osgongxinchoice = "put"
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
	self.osgongxinchoice = (target:objectName() == nextAlive:objectName() and keep) and "put" or "discard"
	return valuable
end

sgs.ai_skill_choice.osgongxin = function(self, choices)
	return self.osgongxinchoice or "discard" or "red"
end

sgs.ai_use_value.osgongxinCard = 8.5
sgs.ai_use_priority.osgongxinCard = 9.5
sgs.ai_card_intention.osgongxinCard = 80



--

--==十周年神武将AI==--
--神张飞
  --“神裁”AI
local tyshencai_skill = {}
tyshencai_skill.name = "tyshencai"
table.insert(sgs.ai_skills, tyshencai_skill)
tyshencai_skill.getTurnUseCard = function(self)
	if self.player:getMark("tyshencai") > self.player:getMark("&tyshencaiAdd") then return end
	return sgs.Card_Parse("#tyshencaiCard:.:")
end

sgs.ai_skill_use_func["#tyshencaiCard"] = function(card, use, self)
    if self.player:getMark("tyshencai") <= self.player:getMark("&tyshencaiAdd") then
        self:sort(self.enemies)
	    self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do --优先找没有“神裁”相关标记的(“死”标记除外)
		    if self:objectiveLevel(enemy) > 0 and (enemy:getMark("&tyscCHI") == 0 and enemy:getMark("&tyscZHANG") == 0
			and enemy:getMark("&tyscTU") == 0 and enemy:getMark("&tyscLIU") == 0) then
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
		for _, enemy in ipairs(self.enemies) do
		    if self:objectiveLevel(enemy) > 0 then
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
	end
end

sgs.ai_use_value.tyshencaiCard = 8.5
sgs.ai_use_priority.tyshencaiCard = 9.5
sgs.ai_card_intention.tyshencaiCard = 80


--

--神张角
  --“三首”AI
sgs.ai_skill_invoke.tysanshou = function(self, data)
	local damage = data:toDamage()
	return not self:isFriend(damage.from)
end
---
  --“三首(装备)”AI
sgs.ai_use_priority.OlSanshou = 0.66
sgs.ai_skill_invoke["OlSanshow"] = function(self, data)
	local damage = data:toDamage()
	return not self:isFriend(damage.from)
end

  --“肆军”AI
sgs.ai_skill_invoke.tysijun = true
----
  --“肆军(OL版)”AI
sgs.ai_skill_invoke.olsijun = true

--神邓艾（“摧心”AI已在lua里体现，原则是确保是在上下家都是敌人的情况下发动；其余无）







--

--==OL神武将AI==--
--神曹丕
  --“储元”AI
sgs.ai_skill_invoke.olchuyuan = function(self, data)
	local player = data:toPlayer()
	if self.player:getPile("powerful"):length() == 2 then
		if self.player:hasSkill("oldengji") and self.player:getMark("oldengji") <= 0 then return self.player:getMaxHp() > 1 end
		if self.player:hasSkill("oltianxing") and self.player:getMark("oltianxing") <= 0 then return self.player:getMaxHp() > 1 end
	end
	if self:doNotDiscard(player, "h") then
	return false end
	return true
end

sgs.ai_skill_discard.olchuyuan = function(self, discard_num, min_num, optional, include_equip)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	return {cards[1]:getEffectiveId()}
end

  --“天行”AI
sgs.ai_skill_choice.oltianxing = function(self, choices, data)
	local skills = choices:split("+")
	local skillss = {}
	if table.contains(skills, "tenyearzhiheng") then table.insert(skillss, "tenyearzhiheng") end
	if table.contains(skills, "olluanji") then table.insert(skillss, "olluanji") end
	if #self.friends_noself <= 0 and #skillss > 0 then
		return skillss[math.random(1, #skillss)]
	end
	return skills[math.random(1, #skills)]
end

--神甄姬
  --“神赋”AI
function isOddInteger(int)
	return math.ceil(int/2) - math.floor(int/2) == 1
end

function isEvenInteger(int)
	return math.ceil(int/2) - math.floor(int/2) == 0
end

sgs.ai_skill_playerchosen.olshenfu = function(self, targets)
	if isOddInteger(self.player:getHandcardNum()) then
		local enemies = {}
		for _, target in sgs.qlist(targets) do
			if target:isAlive() and self:isEnemy(target) and self:damageIsEffective(target, sgs.DamageStruct_Thunder) then table.insert(enemies, target) end
		end
		self:sort(enemies, "hp")
		return enemies[1]
	elseif isEvenInteger(self.player:getHandcardNum()) then
		local firstpriority = {}
		local tos = {}
		for _, target in sgs.qlist(targets) do
			if target:isAlive() and math.abs(target:getHandcardNum() - target:getHp()) == 1 then
				table.insert(firstpriority, target)
			else
				if target:isAlive() and self:isFriend(target) or (self:isEnemy(target) and not target:isKongcheng())
				or (self:isEnemy(target) and target:hasSkill("kongcheng") and target:isKongcheng()) then
					table.insert(tos, target)
				end
			end
		end
		if #firstpriority > 0 then
			return firstpriority[math.random(1, #firstpriority)]
		else
			if #tos > 0 then return tos[math.random(1, #tos)] end
		end
	end
	return nil
end

sgs.ai_skill_choice.olshenfu = function(self, choices, data)
	local to = data:toPlayer()
	if self:isFriend(to) then
		if to:hasSkill("tuntian") and to:getHandcardNum() - to:getHp() == 1 then
			return "discard"
		end
		return "draw"
	end
	if self:isEnemy(to) then
		if to:hasSkill("kongcheng") and to:isKongcheng() then
			return "draw"
		end
		return "discard"
	end
	return "draw"
end
--

--神孙权（“驭衡”AI已在lua里体现；“权道”AI暂无）

--神张角（统一写在了新杀神张角那里）





--

--==欢乐杀神武将AI==--
--神孙权
  --“劝学”AI（给标记的部分写在武将技能里，但仅限于斗地主模式）
sgs.ai_skill_invoke.joyquanxue = true

  --AI应对移除“学”标记的智能选择
sgs.ai_skill_choice.joyquanxue = function(self, choices, data)
    if self.player:getHp() <= 1 and self:getCardsNum("Peach") == 0 and self:getCardsNum("Analeptic") == 0 then return "1" end
	if self:getCardsNum("Slash") == 0 and self:getCardsNum("Peach") == 0 and self:getCardsNum("TrickCard") == 0 and self:getCardsNum("EquipCard") == 0 then return "1" end
	return "2"
end

  --“鼎立”AI
sgs.ai_skill_use["@@joydingliSK"] = function(self, prompt)
	local card = sgs.Card_Parse("#joydingliSKCard:.:")
	local dummy_use = {isDummy = true}
	self:useSkillCard(card, dummy_use)
	if dummy_use.card then return (dummy_use.card):toString() .. "->." end
	return "."
end

local joydingliSK_skill = {}
joydingliSK_skill.name = "joydingliSK"
table.insert(sgs.ai_skills, joydingliSK_skill)
joydingliSK_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("joydingliSKCard") then return end
	return sgs.Card_Parse("#joydingliSKCard:.:")
end

sgs.ai_skill_use_func["#joydingliSKCard"] = function(card, use, self)
    use.card = card
	return
end

sgs.ai_use_value.joydingliSKCard = 10
sgs.ai_use_priority.joydingliSKCard = 10
sgs.ai_card_intention.joydingliSKCard = -100

--

--神张辽
  --“夺锐”AI
sgs.ai_skill_invoke.joyduorui = true

sgs.ai_skill_playerchosen.joyduorui = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
	    if self:isEnemy(p) then
		    return p
		end
	end
	return nil
end





--

--神典韦
  --“神卫”AI（无脑给自己套盾）
--sgs.ai_skill_invoke.joyshenwei = true
sgs.ai_skill_invoke.joyshenwei = function(self, data)
	if self.player:getMark("&joyWEI") > 0 then return false end
	return true
end

sgs.ai_skill_invoke["@joyshenweiMoveDamage"] = true --无脑转移

  --“恶来”AI
sgs.ai_skill_choice.joyelai = function(self, choices, data)
    if self.player:getHp() <= 1 then return "1" end
	return "2"
end

sgs.ai_skill_playerchosen.joyelai = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
	    if self:isEnemy(p) and self:inMyAttackRange(p) then
		    return p 
		end
	end
	return nil
end



--

--神华佗
  --“济世”AI（单救自己，要是能救别人属实是太ex人了）
sgs.ai_skill_invoke.joyjishi = function(self, data)
	if self.player:getMark("&joyMedicine") > 0 and self.player:hasFlag("Global_Dying") then return true end
	return false
end

  --“桃仙”AI
sgs.ai_view_as.joytaoxian = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place ~= sgs.Player_PlaceSpecial and card:getSuit() == sgs.Card_Heart
	and player:getMark("Global_PreventPeach") == 0 then
		return ("peach:joytaoxian[%s:%s]=%d"):format(suit, number, card_id)
	end
end

sgs.joytaoxian_suit_value = {
	heart = 6
}

sgs.ai_cardneed.joytaoxian = function(to, card)
	return card:getSuit() == sgs.Card_Heart
end



--

--神貂蝉
  --“魅魂”AI
sgs.ai_skill_invoke.joymeihun = true

sgs.ai_skill_playerchosen.joymeihun = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do --先找牌多的
	    if self:isEnemy(p) and not p:isNude() and p:getHandcardNum() + p:getEquips():length() > 4 then
		    return p 
		end
	end
	for _, p in ipairs(targets) do
	    if self:isEnemy(p) and not p:isNude() then
		    return p 
		end
	end
	return nil
end

  --“惑心”AI
    --AI应对
sgs.ai_skill_choice.joyhuoxin = function(self, choices, data)
    if self.player:getHandcardNum() + self.player:getEquips():length() > 4 then return "lh" or "ld" or "lc" or "ls" end
	return "gh=" .. jsdc:objectName() or "gd=" .. jsdc:objectName() or "gc=" .. jsdc:objectName() or "gs=" .. jsdc:objectName()
end



--

--神-大乔&小乔
  --“双姝”AI
sgs.ai_skill_invoke.joyshuangshu = true

  --“娉婷”AI
sgs.ai_skill_invoke.joypinting = true

sgs.ai_skill_choice.joypinting = function(self, choices, data)
	return not "cancel"
end

  --“移筝”AI
sgs.ai_skill_invoke.joyyizheng = false





--

--神关羽
  --“武神”AI
sgs.ai_view_as.joywushen = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place ~= sgs.Player_PlaceSpecial and card_place ~= sgs.Player_PlaceEquip
	and card:getSuit() == sgs.Card_Heart and not card:isKindOf("Peach") and not card:hasFlag("using") then
		return ("slash:joywushen[%s:%s]=%d"):format(suit, number, card_id)
	end
end

local joywushen_skill = {}
joywushen_skill.name = "joywushen"
table.insert(sgs.ai_skills, joywushen_skill)
joywushen_skill.getTurnUseCard = function(self, inclusive)
	if self.player:isKongcheng() then return false end
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	local heart_card
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
	for _, card in ipairs(cards) do
		if card:getSuit() == sgs.Card_Heart and not card:isKindOf("Slash") and (not isCard("Peach", card, self.player) and not isCard("ExNihilo", card, self.player) and not useAll)
			and (self:getUseValue(card) < sgs.ai_use_value.Slash or inclusive or sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, sgs.Sanguosha:cloneCard("slash")) > 0) then
			heart_card = card
			break
		end
	end
	if heart_card then
		local suit = heart_card:getSuitString()
		local number = heart_card:getNumberString()
		local card_id = heart_card:getEffectiveId()
		local card_str = ("slash:joywushen[%s:%s]=%d"):format(suit, number, card_id)
		local slash = sgs.Card_Parse(card_str)
		assert(slash)
		return slash
	end
end

function sgs.ai_cardneed.joywushen(to, card)
	return card:getSuit() == sgs.Card_Heart
end

  --“武魂”AI
--sgs.ai_chaofeng.joy_shenguanyu = -5

sgs.ai_skill_playerchosen.joywuhun = function(self, targets)
	local targetlist = sgs.QList2Table(targets)
	local target
	local lord
	for _, player in ipairs(targetlist) do
		if player:isLord() then lord = player end
		if self:isEnemy(player) and (not target or target:getHp() < player:getHp()) then
			target = player
		end
	end
	if self.role == "rebel" and lord then return lord end
	if target then return target end
	self:sort(targetlist, "hp")
	if self.player:getRole() == "loyalist" and targetlist[1]:isLord() then return targetlist[2] end
	return targetlist[1]
end

--神吕蒙
  --“攻心”AI
sgs.ai_skill_invoke.joygongxin = function(self, data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end

sgs.ai_skill_askforag.joygongxin = function(self, card_ids)
	self.joygongxinchoice = nil
	local target = self.player:getTag("joygongxin"):toPlayer()
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
			self.joygongxinchoice = "get"
		else
			self.joygongxinchoice = "put"
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
			self.joygongxinchoice = "put"
			return valuable
		end
		if card:isKindOf("TrickCard") or card:isKindOf("Indulgence") or card:isKindOf("SupplyShortage") then
			local dummy_use = { isDummy = true }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				self.joygongxinchoice = "put"
				return valuable
			end
		end
		if card:isKindOf("Jink") and self:getCardsNum("Jink") == 0 then
			self.joygongxinchoice = "put"
			return valuable
		end
		if card:isKindOf("Nullification") and self:getCardsNum("Nullification") == 0 then
			self.joygongxinchoice = "put"
			return valuable
		end
		if card:isKindOf("Slash") and self:slashIsAvailable() then
			local dummy_use = { isDummy = true }
			self:useBasicCard(card, dummy_use)
			if dummy_use.card then
				self.joygongxinchoice = "put"
				return valuable
			end
		end
		self.joygongxinchoice = "get"
		return valuable
	end
	local hasLightning, hasIndulgence, hasSupplyShortage
	local tricks = nextAlive:getJudgingArea()
	if not tricks:isEmpty() and not nextAlive:containsTrick("YanxiaoCard") then
		local trick = tricks:at(tricks:length() - 1)
		if self:hasTrickEffective(trick, nextAlive) then
			if trick:isKindOf("Lightning") then hasLightning = true
			elseif trick:isKindOf("Indulgence") then hasIndulgence = true
			elseif trick:isKindOf("SupplyShortage") then hasSupplyShortage = true
			end
		end
	end
	if self:isEnemy(nextAlive) and nextAlive:hasSkill("luoshen") and valuable then
		self.joygongxinchoice = "put"
		return valuable
	end
	if nextAlive:hasSkill("yinghun") and nextAlive:isWounded() then
		self.joygongxinchoice = self:isFriend(nextAlive) and "put" or "get"
		return valuable
	end
	if target:hasSkill("hongyan") and hasLightning and self:isEnemy(nextAlive) and not (nextAlive:hasSkill("qiaobian") and nextAlive:getHandcardNum() > 0) then
		for _, id in ipairs(card_ids) do
			local card = sgs.Sanguosha:getEngineCard(id)
			if card:getSuit() == sgs.Card_Spade and card:getNumber() >= 2 and card:getNumber() <= 9 then
				self.joygongxinchoice = "put"
				return id
			end
		end
	end
	if hasIndulgence and self:isFriend(nextAlive) then
		self.joygongxinchoice = "put"
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
			self.joygongxinchoice = "put"
			return valuable
		end
	end
	if self:isFriend(nextAlive) and not self:willSkipDrawPhase(nextAlive) and not self:willSkipPlayPhase(nextAlive)
		and not nextAlive:hasSkill("luoshen")
		and not nextAlive:hasSkill("tuxi") and not (nextAlive:hasSkill("qiaobian") and nextAlive:getHandcardNum() > 0) then
		if (peach and valuable == peach) or (ex_nihilo and valuable == ex_nihilo) then
			self.joygongxinchoice = "put"
			return valuable
		end
		if jink and valuable == jink and getCardsNum("Jink", nextAlive) < 1 then
			self.joygongxinchoice = "put"
			return valuable
		end
		if nullification and valuable == nullification and getCardsNum("Nullification", nextAlive) < 1 then
			self.joygongxinchoice = "put"
			return valuable
		end
		if slash and valuable == slash and self:hasCrossbowEffect(nextAlive) then
			self.joygongxinchoice = "put"
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
	self.joygongxinchoice = (target:objectName() == nextAlive:objectName() and keep) and "put" or "get"
	return valuable
end

sgs.ai_skill_choice.joygongxin = function(self, choices)
	return self.joygongxinchoice
end

--

--嫦娥
  --“捣药”AI
local joydaoyao_skill = {}
joydaoyao_skill.name = "joydaoyao"
table.insert(sgs.ai_skills, joydaoyao_skill)
joydaoyao_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("joydaoyaoCard") or self.player:isKongcheng() then return end
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
	    return sgs.Card_Parse("#joydaoyaoCard:"..card_id..":")
	end
end

sgs.ai_skill_use_func["#joydaoyaoCard"] = function(card, use, self)
    if not self.player:hasUsed("#joydaoyaoCard") and not self.player:isKongcheng() then
		use.card = card
		return
	end
end

sgs.ai_use_value.joydaoyaoCard = 8.5
sgs.ai_use_priority.joydaoyaoCard = 9.5
sgs.ai_card_intention.joydaoyaoCard = -80

--神周瑜
  --“琴音”AI
sgs.ai_skill_invoke.joyqinyin = function(self, data)
    self:sort(self.friends, "hp")
	self:sort(self.enemies, "hp")
	local up = 0
	local down = 0
	for _, friend in ipairs(self.friends) do
		down = down - 10
		up = up + (friend:isWounded() and 10 or 0)
		if self:hasSkills(sgs.masochism_skill, friend) then
			down = down - 5
			if friend:isWounded() then up = up + 5 end
		end
		if self:needToLoseHp(friend, nil, nil, true) then down = down + 5 end
		if self:needToLoseHp(friend, nil, nil, true, true) and friend:isWounded() then up = up - 5 end
		if self:isWeak(friend) then
			if friend:isWounded() then up = up + 10 + (friend:isLord() and 20 or 0) end
			down = down - 10 - (friend:isLord() and 40 or 0)
			if friend:getHp() <= 1 and not friend:hasSkill("buqu") or friend:getPile("buqu"):length() > 4 then
				down = down - 20 - (friend:isLord() and 40 or 0)
			end
		end
	end
	for _, enemy in ipairs(self.enemies) do
		down = down + 10
		up = up - (enemy:isWounded() and 10 or 0)
		if self:hasSkills(sgs.masochism_skill, enemy) then
			down = down + 10
			if enemy:isWounded() then up = up - 10 end
		end
		if self:needToLoseHp(enemy, nil, nil, true) then down = down - 5 end
		if self:needToLoseHp(enemy, nil, nil, true, true) and enemy:isWounded() then up = up - 5 end

		if self:isWeak(enemy) then
			if enemy:isWounded() then up = up - 10 end
			down = down + 10
			if enemy:getHp() <= 1 and not enemy:hasSkill("buqu") then
				down = down + 10 + ((enemy:isLord() and #self.enemies > 1) and 20 or 0)
			end
		end
	end
	if self:isWeak() and self.player:getCards("he"):length() >= 2 then
	    sgs.ai_skill_choice.joyqinyin = "r"
		return true
	end
	if down > 0 then
		sgs.ai_skill_choice.joyqinyin = "l"
		return true
	elseif up > 0 then
		sgs.ai_skill_choice.joyqinyin = "r"
		return true
	else
	    if not self:isWeak() then
	        sgs.ai_skill_choice.joyqinyin = "l" --SK神周瑜：我要报复社会！欢乐神周瑜：老哥，加我一个呗。
		    return true
		end
	--else sgs.ai_skill_choice.joyqinyin = "cancel"
	end
	return false
end

  --“业炎”AI
sgs.ai_skill_invoke.joyyeyan = true

sgs.ai_skill_playerchosen.joyyeyan = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
	    if self:isEnemy(p) and (p:getHp() <= 1 or (p:hasSkill("kongcheng") or p:hasSkill("bazhen"))) then
		    return p 
		end
	end
	for _, p in ipairs(targets) do
	    if self:isEnemy(p) then
		    return p 
		end
	end
end
--

--神诸葛亮
  --“狂风”AI
sgs.ai_skill_use["@@joykuangfeng"] = function(self, prompt)
	local targets, stars = {}, self.player:getPile("stars"):length()
	if #self.enemies == 0 or stars == 0 then return "." end
	self:sort(self.enemies, "hp")
	for _, enemy in ipairs(self.enemies) do
		if stars > 0 and self:objectiveLevel(enemy) > 0 --[[and self:isWeak(enemy)]] and not enemy:hasSkill("buqu")
		and not (enemy:hasSkill("hunzi") and enemy:getMark("hunzi") == 0 and enemy:getHp() > 1) then --江东小白板：村夫我**测你码
			table.insert(targets, enemy:objectName())
			stars = stars - 1
		end
	end
	if #targets > 0 then
		local s = sgs.QList2Table(self.player:getPile("stars"))
		local length = #targets
		for i = 1, #s - length do
			table.remove(s, #s)
		end
		return "#joykuangfengCard:" .. table.concat(s, "+") .. ":" .. "->" .. table.concat(targets, "+")
	end
	return "."
end

sgs.ai_card_intention["#joykuangfengCard"] = 100

  --“大雾”AI
sgs.ai_skill_use["@@joydawu"] = function(self, prompt)
	if self.player:getPile("stars"):isEmpty() then return "." end
	if self.player:getHp() + self.player:getHandcardNum() < 3 or self.player:getHp() <= 1 or self.player:isKongcheng() then
		return "#joydawuCard:" .. self.player:getPile("stars"):first() .. ":->" .. self.player:objectName()
	else
		return "."
	end
end

sgs.ai_card_intention["#joydawuCard"] = -99

--

--==小程序神武将AI==--
--神关羽
  --“武神”AI
sgs.ai_view_as.wxwushen = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place ~= sgs.Player_PlaceSpecial and card:isRed() and not card:isKindOf("Peach") and not card:hasFlag("using") then
		return ("slash:wxwushen[%s:%s]=%d"):format(suit, number, card_id)
	end
end

local wxwushen_skill = {}
wxwushen_skill.name = "wxwushen"
table.insert(sgs.ai_skills, wxwushen_skill)
wxwushen_skill.getTurnUseCard = function(self, inclusive)
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
		local card_str = ("slash:wxwushen[%s:%s]=%d"):format(suit, number, card_id)
		local slash = sgs.Card_Parse(card_str)
		assert(slash)
		return slash
	end
end

function sgs.ai_cardneed.wxwushen(to, card)
	return card:isRed() --鼓励使用，因为都有加成效果
end

--

--神吕蒙
  --“攻心”AI
local wxgongxin_skill = {}
wxgongxin_skill.name = "wxgongxin"
table.insert(sgs.ai_skills, wxgongxin_skill)
wxgongxin_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#wxgongxinCard") then return end
	local wxgongxin_card = sgs.Card_Parse("#wxgongxinCard:.:")
	assert(wxgongxin_card)
	return wxgongxin_card
end

sgs.ai_skill_use_func["#wxgongxinCard"] = function(card, use, self)
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

sgs.ai_skill_askforag.wxgongxin = function(self, card_ids)
	self.wxgongxinchoice = nil
	local target = self.player:getTag("wxgongxin"):toPlayer()
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
			self.wxgongxinchoice = "get"
		else
			self.wxgongxinchoice = "put"
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
			self.wxgongxinchoice = "put"
			return valuable
		end
		if card:isKindOf("TrickCard") or card:isKindOf("Indulgence") or card:isKindOf("SupplyShortage") then
			local dummy_use = { isDummy = true }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				self.wxgongxinchoice = "put"
				return valuable
			end
		end
		if card:isKindOf("Jink") and self:getCardsNum("Jink") == 0 then
			self.wxgongxinchoice = "put"
			return valuable
		end
		if card:isKindOf("Nullification") and self:getCardsNum("Nullification") == 0 then
			self.wxgongxinchoice = "put"
			return valuable
		end
		if card:isKindOf("Slash") and self:slashIsAvailable() then
			local dummy_use = { isDummy = true }
			self:useBasicCard(card, dummy_use)
			if dummy_use.card then
				self.wxgongxinchoice = "put"
				return valuable
			end
		end
		self.wxgongxinchoice = "get"
		return valuable
	end
	local hasLightning, hasIndulgence, hasSupplyShortage
	local tricks = nextAlive:getJudgingArea()
	if not tricks:isEmpty() and not nextAlive:containsTrick("YanxiaoCard") then
		local trick = tricks:at(tricks:length() - 1)
		if self:hasTrickEffective(trick, nextAlive) then
			if trick:isKindOf("Lightning") then hasLightning = true
			elseif trick:isKindOf("Indulgence") then hasIndulgence = true
			elseif trick:isKindOf("SupplyShortage") then hasSupplyShortage = true
			end
		end
	end
	if self:isEnemy(nextAlive) and nextAlive:hasSkill("luoshen") and valuable then
		self.wxgongxinchoice = "put"
		return valuable
	end
	if nextAlive:hasSkill("yinghun") and nextAlive:isWounded() then
		self.wxgongxinchoice = self:isFriend(nextAlive) and "put" or "get"
		return valuable
	end
	if target:hasSkill("hongyan") and hasLightning and self:isEnemy(nextAlive) and not (nextAlive:hasSkill("qiaobian") and nextAlive:getHandcardNum() > 0) then
		for _, id in ipairs(card_ids) do
			local card = sgs.Sanguosha:getEngineCard(id)
			if card:getSuit() == sgs.Card_Spade and card:getNumber() >= 2 and card:getNumber() <= 9 then
				self.wxgongxinchoice = "put"
				return id
			end
		end
	end
	if hasIndulgence and self:isFriend(nextAlive) then
		self.wxgongxinchoice = "put"
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
			self.wxgongxinchoice = "put"
			return valuable
		end
	end
	if self:isFriend(nextAlive) and not self:willSkipDrawPhase(nextAlive) and not self:willSkipPlayPhase(nextAlive)
		and not nextAlive:hasSkill("luoshen")
		and not nextAlive:hasSkill("tuxi") and not (nextAlive:hasSkill("qiaobian") and nextAlive:getHandcardNum() > 0) then
		if (peach and valuable == peach) or (ex_nihilo and valuable == ex_nihilo) then
			self.wxgongxinchoice = "put"
			return valuable
		end
		if jink and valuable == jink and getCardsNum("Jink", nextAlive) < 1 then
			self.wxgongxinchoice = "put"
			return valuable
		end
		if nullification and valuable == nullification and getCardsNum("Nullification", nextAlive) < 1 then
			self.wxgongxinchoice = "put"
			return valuable
		end
		if slash and valuable == slash and self:hasCrossbowEffect(nextAlive) then
			self.wxgongxinchoice = "put"
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
	self.wxgongxinchoice = (target:objectName() == nextAlive:objectName() and keep) and "put" or "get"
	return valuable
end

sgs.ai_skill_choice.wxgongxin = function(self, choices)
	return self.wxgongxinchoice
end

sgs.ai_use_value.wxgongxinCard = 8.5
sgs.ai_use_priority.wxgongxinCard = 9.5
sgs.ai_card_intention.wxgongxinCard = 80
--

--神诸葛亮
 --原版
  --“七星”AI
sgs.ai_skill_invoke.wxqixing = true

  --“祭风”AI
local wxjifeng_skill = {}
wxjifeng_skill.name = "wxjifeng"
table.insert(sgs.ai_skills, wxjifeng_skill)
wxjifeng_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("wxjifengCard") or self.player:isKongcheng() then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local lightning = self:getCard("Lightning")
	if lightning and not self:willUseLightning(lightning) then
		card_id = lightning:getEffectiveId()
	else
		for _, acard in ipairs(cards) do
			if (not acard:isKindOf("TrickCard") and not acard:isKindOf("Peach")) or acard:isKindOf("Nullification") then
				card_id = acard:getEffectiveId()
				break
			end
		end
	end
	if not card_id then
	    return nil
	else
	    return sgs.Card_Parse("#wxjifengCard:"..card_id..":")
	end
end

sgs.ai_skill_use_func["#wxjifengCard"] = function(card, use, self)
    if not self.player:hasUsed("#wxjifengCard") and not self.player:isKongcheng() then
		use.card = card
		return
	end
end

sgs.ai_use_value.wxjifengCard = 8.5
sgs.ai_use_priority.wxjifengCard = 9.5
sgs.ai_card_intention.wxjifengCard = -80

  --“天罚”AI
sgs.ai_skill_use["@@wxtianfa"] = function(self, prompt)
	local targets, wxFA = {}, self.player:getMark("&wxFA")
	if #self.enemies == 0 or wxFA == 0 then return "." end
	self:sort(self.enemies, "hp")
	for _, enemy in ipairs(self.enemies) do
		if wxFA > 0 and self:objectiveLevel(enemy) > 0 and not enemy:hasSkill("buqu")
		and not (enemy:hasSkill("hunzi") and enemy:getMark("hunzi") == 0 and enemy:getHp() > 1) then --江东小白板：村夫我**测你码X2
			table.insert(targets, enemy:objectName())
			wxFA = wxFA - 1
			break
		end
	end
	if #targets > 0 then
		return "#wxtianfaCard:.:->" .. table.concat(targets, "+")
	end
	return "."
end

sgs.ai_card_intention["#wxtianfaCard"] = 110

 --威力加强版
  --“七星”AI
sgs.ai_skill_invoke.wxqixingEX = true

  --“祭风”AI
local wxjifengEX_skill = {}
wxjifengEX_skill.name = "wxjifengEX"
table.insert(sgs.ai_skills, wxjifengEX_skill)
wxjifengEX_skill.getTurnUseCard = function(self)
	if self.player:getMark("wxjifengEX_zuiandfa") == 0 or self.player:isKongcheng() then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local lightning = self:getCard("Lightning")
	if lightning and not self:willUseLightning(lightning) then
		card_id = lightning:getEffectiveId()
	else
		for _, acard in ipairs(cards) do
			if (not acard:isKindOf("TrickCard") and not acard:isKindOf("Peach")) or acard:isKindOf("Nullification") then
				card_id = acard:getEffectiveId()
				break
			end
		end
	end
	if not card_id then
	    return nil
	else
	    return sgs.Card_Parse("#wxjifengEXCard:"..card_id..":")
	end
end

sgs.ai_skill_use_func["#wxjifengEXCard"] = function(card, use, self)
    if self.player:getMark("wxjifengEX_zuiandfa") > 0 and not self.player:isKongcheng() then
		use.card = card
		return
	end
end

sgs.ai_use_value.wxjifengEXCard = 8.5
sgs.ai_use_priority.wxjifengEXCard = 9.5
sgs.ai_card_intention.wxjifengEXCard = -80

  --“天罪”AI
sgs.ai_skill_use["@@wxtianzuiEX"] = function(self, prompt)
	local targets, exZUI = {}, self.player:getMark("&exZUI")
	if exZUI == 0 then return "." end
	--先帮判定区有牌的队友
	self:sort(self.friends_noself)
	for _, friend in ipairs(self.friends_noself) do
		if exZUI > 0 and friend:getJudgingArea():length() > 0 and self.player:canDiscard(friend, "j") then
			table.insert(targets, friend:objectName())
			exZUI = exZUI - 1
		end
	end
	if #self.enemies > 0 and exZUI > 0 then --再拆对手
		self:sort(self.enemies, "defense")
		for _, enemy in ipairs(self.enemies) do
			if exZUI > 0 and self:objectiveLevel(enemy) > 0 and not enemy:isNude() and self.player:canDiscard(enemy, "he") then
				table.insert(targets, enemy:objectName())
				exZUI = exZUI - 1
			end
		end
	end
	if #targets > 0 then
		return "#wxtianzuiEXCard:.:->" .. table.concat(targets, "+")
	end
	return "."
end

sgs.ai_card_intention["#wxtianzuiEXCard"] = 120

  --“天罚”AI
sgs.ai_skill_use["@@wxtianfaEX"] = function(self, prompt)
	local targets, exFA = {}, self.player:getMark("&exFA")
	if #self.enemies == 0 or exFA == 0 then return "." end
	self:sort(self.enemies, "hp")
	for _, enemy in ipairs(self.enemies) do
		if exFA > 0 and self:objectiveLevel(enemy) > 0 and not enemy:hasSkill("buqu")
		and not (enemy:hasSkill("hunzi") and enemy:getMark("hunzi") == 0 and enemy:getHp() > 1) then --江东小白板：村夫我**测你码X3
			table.insert(targets, enemy:objectName())
			exFA = exFA - 1
		end
	end
	if #targets > 0 then
		return "#wxtianfaEXCard:.:->" .. table.concat(targets, "+")
	end
	return "."
end

sgs.ai_card_intention["#wxtianfaEXCard"] = 120


--

--==极略三国神武将AI==--
--神黄忠
  --“烈弓”AI
sgs.ai_view_as.jlsgliegong = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place ~= sgs.Player_PlaceSpecial and card_place ~= sgs.Player_PlaceEquip and card and not card:isKindOf("Peach") and not card:hasFlag("using") then
		return ("fire_slash:jlsgliegong[%s:%s]=%d"):format(suit, number, card_id)
	end
end

local jlsgliegong_skill = {}
jlsgliegong_skill.name = "jlsgliegong"
table.insert(sgs.ai_skills, jlsgliegong_skill)
jlsgliegong_skill.getTurnUseCard = function(self, inclusive)
	if (not self.player:isWounded() and self.player:getMark("jlsgliegong") >= 1)
	or (self.player:isWounded() and self.player:getMark("jlsgliegong") >= 2)
	or self.player:isKongcheng() then return false end
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	local lg_card
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
	for _, card in ipairs(cards) do
		if card and not card:isKindOf("Slash") and (not isCard("Peach", card, self.player) and not isCard("ExNihilo", card, self.player) and not useAll)
			and (self:getUseValue(card) < sgs.ai_use_value.Slash or inclusive or sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, sgs.Sanguosha:cloneCard("slash")) > 0) then
			lg_card = card
			break
		end
	end
	if lg_card then
		local suit = lg_card:getSuitString()
		local number = lg_card:getNumberString()
		local card_id = lg_card:getEffectiveId()
		local card_str = ("fire_slash:jlsgliegong[%s:%s]=%d"):format(suit, number, card_id)
		local slash = sgs.Card_Parse(card_str)
		assert(slash)
		return slash
	end
end

function sgs.ai_cardneed.jlsgliegong(to, card)
	return card
end





--

--神华佗
  --“归元”AI
local jlsgguiyuan_skill = {}
jlsgguiyuan_skill.name = "jlsgguiyuan"
table.insert(sgs.ai_skills, jlsgguiyuan_skill)
jlsgguiyuan_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("jlsgguiyuanCard") then return end
	return sgs.Card_Parse("#jlsgguiyuanCard:.:")
end

sgs.ai_skill_use_func["#jlsgguiyuanCard"] = function(card, use, self)
    if not self.player:hasUsed("#jlsgguiyuanCard") then
		local cansave = 1 - self.player:getHp()
		local mark = self.player:getMark("@jlsgchongsheng")
		if self:getCardsNum("Peach") + self:getCardsNum("Analeptic") + mark >= cansave then
			use.card = card
			return
		end
	end
end

sgs.ai_use_value.jlsgguiyuanCard = 8.5
sgs.ai_use_priority.jlsgguiyuanCard = 9.5
sgs.ai_card_intention.jlsgguiyuanCard = -80

  --“重生”AI
sgs.ai_skill_invoke.jlsgchongsheng = function(self, data)
	local dying = data:toDying()
	if dying.who:objectName() == self.player:objectName() then
		local peaches = 1 - dying.who:getHp()
		return self:getCardsNum("Peach") + self:getCardsNum("Analeptic") < peaches
	else
		if self.player:getPile("jlsgyuanhua"):length() < 3 then return false end --无脑发动容易让别人变成1血魔将，直接帮倒忙
		return self:isFriend(dying.who)
	end
end

sgs.ai_skill_invoke["@jlsgchongsheng-generalChanged"] = true
--

--==线下神武将AI==--
--神姜维
  --“九伐”AI（部分内容已写进lua里）
sgs.ai_skill_invoke.ofljiufa = true




--

--神郭嘉
  --“慧识”AI
local oflhuishi_skill = {}
oflhuishi_skill.name = "oflhuishi"
table.insert(sgs.ai_skills, oflhuishi_skill)
oflhuishi_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("oflhuishiCard") then return end
	return sgs.Card_Parse("#oflhuishiCard:.:")
end

sgs.ai_skill_use_func["#oflhuishiCard"] = function(card, use, self)
    if not self.player:hasUsed("#oflhuishiCard") then
        use.card = card
	    return
	end
end

sgs.ai_skill_invoke.oflhuishi = true

    --“慧识”给牌
sgs.ai_skill_playerchosen["oflhuishi"] = function(self, targets)
    local targets = sgs.QList2Table(targets)
	self:sort(self.friends_noself)
	for _, p in ipairs(self.friends_noself) do --如果自己手牌足够又有队友手牌不够，给队友
		if self:isFriend(p) and p:getHandcardNum() < 3 and self.player:getHandcardNum() > self.player:getMaxHp() then
			return p
		end
	end
    return self.player
end

sgs.ai_use_value.oflhuishiCard = 8.5
sgs.ai_use_priority.oflhuishiCard = 9.5
sgs.ai_card_intention.oflhuishiCard = -80

  --“天翊”AI
sgs.ai_skill_playerchosen["@ofltianyi"] = function(self, targets)
    targets = sgs.QList2Table(targets)
	return self.player
end

  --“辉逝”AI
sgs.ai_skill_invoke.oflhuishii = true

sgs.ai_skill_playerchosen["oflhuishii"] = function(self, targets)
    local targets = sgs.QList2Table(targets)
	self:sort(self.friends_noself)
	for _, p in ipairs(self.friends_noself) do --优先帮牌少的队友补牌
		if self:isFriend(p) and p:getHandcardNum() < 3 then
			return p
		end
	end
	for _, p in ipairs(self.friends_noself) do --优先队友
		if self:isFriend(p) then
			return p
		end
	end
    return self.player
end

--长坂坡模式·神赵云
 --原版
  --“青釭”AI
sgs.ai_skill_invoke.oflqinggang = function(self, data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end
sgs.ai_skill_choice.oflqinggang = function(self, choices, data)
	if self.player:isKongcheng() or not self.player:canDiscard(self.player, "h") then return "2" end
	return "1"
end

  --“龙怒”AI
local ofllongnu_skill = {}
ofllongnu_skill.name = "ofllongnu"
table.insert(sgs.ai_skills, ofllongnu_skill)
ofllongnu_skill.getTurnUseCard = function(self)
	local slash = sgs.Sanguosha:cloneCard("slash")
	if self.player:getPile("oflAngry"):length() < 2 or self.player:getMark("&ofllongnu") > 0
	or self:getCardsNum("Slash") == 0 or not slash:isAvailable(self.player) then return end
	local AGY = self.player:getPile("oflAngry")
	local AGYids, AGYids_club, AGYids_spade = {}, {}, {} --仅限于黑色牌
	for _, id in sgs.qlist(AGY) do
		local card = sgs.Sanguosha:getCard(id)
		if #AGYids == 0 then --第一张
			if card:getSuit() == sgs.Card_Club then
				table.insert(AGYids_club, card:getEffectiveId())
			elseif card:getSuit() == sgs.Card_Spade then
				table.insert(AGYids_spade, card:getEffectiveId())
			end
			table.insert(AGYids, card:getEffectiveId())
		else --第二张
			if (card:getSuit() == sgs.Card_Club and #AGYids_club > 0)
			or (card:getSuit() == sgs.Card_Spade and #AGYids_spade > 0) then
				table.insert(AGYids, card:getEffectiveId())
			end
		end
		if #AGYids == 2 then break end
	end
	if #AGYids < 2 then return nil end
	local ofllongnu_card = sgs.Card_Parse("#ofllongnuCard:" .. table.concat(AGYids, "+") .. ":")
	return ofllongnu_card
end

sgs.ai_skill_use_func["#ofllongnuCard"] = function(card, use, self)
	local slash = sgs.Sanguosha:cloneCard("slash")
	if self.player:getPile("oflAngry"):length() >= 2 and self.player:getMark("&ofllongnu") == 0
	and self:getCardsNum("Slash") > 0 and slash:isAvailable(self.player) then
        use.card = card
	    return
	end
end

sgs.ai_use_value.ofllongnuCard = 8.5
sgs.ai_use_priority.ofllongnuCard = 9.5
sgs.ai_card_intention.ofllongnuCard = -80

  --“浴血”AI
local oflyuxue_skill = {}
oflyuxue_skill.name = "oflyuxue"
table.insert(sgs.ai_skills, oflyuxue_skill)
oflyuxue_skill.getTurnUseCard = function(self)
	local AGY = self.player:getPile("oflAngry")
	local AGYids = {}
	for _, id in sgs.qlist(AGY) do
		local card = sgs.Sanguosha:getCard(id)
		if card:getSuit() == sgs.Card_Heart or card:getSuit() == sgs.Card_Diamond then
			table.insert(AGYids, card:getEffectiveId())
		end
		if #AGYids == 1 then break end
	end
	if #AGYids < 1 or not self.player:isWounded() then return nil end
	local oflyuxue_peach = sgs.Card_Parse("#oflyuxue:" .. table.concat(AGYids, "+") .. ":" .. "peach")
	return oflyuxue_peach
end

sgs.ai_skill_use_func["#oflyuxue"] = function(card, use, self)
	local userstring = card:toString()
	userstring = (userstring:split(":"))[4]
	local oflyuxue_peach = sgs.Sanguosha:cloneCard(userstring, card:getSuit(), card:getNumber())
	oflyuxue_peach:setSkillName("oflyuxue")
	self:useBasicCard(oflyuxue_peach, use)
	if not use.card then return end
	use.card = card
end

sgs.ai_view_as["oflyuxue"] = function(card, player, card_place)
	local AGY = player:getPile("oflAngry")
	local AGYids, suit, number = {}, nil, nil
	for _, id in sgs.qlist(AGY) do
		local card = sgs.Sanguosha:getCard(id)
		if card:getSuit() == sgs.Card_Heart or card:getSuit() == sgs.Card_Diamond then
			table.insert(AGYids, card:getEffectiveId()) suit = card:getSuit() number = card:getNumber()
		end
		if #AGYids == 1 then break end
	end
	if #AGYids == 1 then return ("peach:oflyuxue[%s:%s]=%d"):format(suit, number, AGYids[1]) end
end

  --“龙吟”AI
sgs.ai_skill_invoke.ofllongyin = true

 --威力加强版
  --“青釭”AI
sgs.ai_skill_invoke.oflqinggangEX = function(self, data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end

  --“龙怒”AI
local ofllongnuEX_skill = {}
ofllongnuEX_skill.name = "ofllongnuEX"
table.insert(sgs.ai_skills, ofllongnuEX_skill)
ofllongnuEX_skill.getTurnUseCard = function(self)
	if self.player:getPile("oflAngry"):length() < 2 or self.player:getMark("&ofllongnuEX") > 0 then return end
	local AGY = self.player:getPile("oflAngry")
	local AGYids, AGYids_heart, AGYids_diamond, AGYids_club, AGYids_spade = {}, {}, {}, {}, {}
	for _, id in sgs.qlist(AGY) do
		local card = sgs.Sanguosha:getCard(id)
		if #AGYids == 0 then --第一张
			if card:getSuit() == sgs.Card_Spade then
				table.insert(AGYids_spade, card:getEffectiveId())
			elseif card:getSuit() == sgs.Card_Club then
				table.insert(AGYids_club, card:getEffectiveId())
			elseif card:getSuit() == sgs.Card_Diamond then
				table.insert(AGYids_diamond, card:getEffectiveId())
			elseif card:getSuit() == sgs.Card_Heart then
				table.insert(AGYids_heart, card:getEffectiveId())
			end
			table.insert(AGYids, card:getEffectiveId())
		else --第二张
			if (card:getSuit() == sgs.Card_Heart and #AGYids_heart > 0) or (card:getSuit() == sgs.Card_Diamond and #AGYids_diamond > 0)
			or (card:getSuit() == sgs.Card_Club and #AGYids_club > 0) or (card:getSuit() == sgs.Card_Spade and #AGYids_spade > 0) then
				table.insert(AGYids, card:getEffectiveId())
			end
		end
		if #AGYids == 2 then break end
	end
	if #AGYids < 2 then return nil end
	local ofllongnuEX_card = sgs.Card_Parse("#ofllongnuEXCard:" .. table.concat(AGYids, "+") .. ":")
	return ofllongnuEX_card
end

sgs.ai_skill_use_func["#ofllongnuEXCard"] = function(card, use, self)
    if self.player:getPile("oflAngry"):length() >= 2 and self.player:getMark("&ofllongnuEX") == 0 then
        use.card = card
	    return
	end
end

sgs.ai_skill_choice.ofllongnuEX = function(self, choices, data)
	local slash = sgs.Sanguosha:cloneCard("slash")
	if self:getCardsNum("Slash") == 0 or not slash:isAvailable(self.player) then return "get" end
	return "dis"
end

sgs.ai_use_value.ofllongnuEXCard = 8.5
sgs.ai_use_priority.ofllongnuEXCard = 9.5
sgs.ai_card_intention.ofllongnuEXCard = -80

  --“浴血”AI
local oflyuxueEX_skill = {}
oflyuxueEX_skill.name = "oflyuxueEX"
table.insert(sgs.ai_skills, oflyuxueEX_skill)
oflyuxueEX_skill.getTurnUseCard = function(self)
	local AGY = self.player:getPile("oflAngry")
	local AGYids, AGYids_red, AGYids_black = {}, {}, {}
	for _, id in sgs.qlist(AGY) do
		local card = sgs.Sanguosha:getCard(id)
		if card:isRed() then
			table.insert(AGYids_red, card:getEffectiveId())
		elseif card:isBlack() then
			table.insert(AGYids_black, card:getEffectiveId())
		end
		table.insert(AGYids, card:getEffectiveId())
		if #AGYids == 1 then break end
	end
	if #AGYids < 1 then return nil end
	local oflyuxue_basic = nil
	local newana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_SuitToBeDecided, 0)
	if #AGYids_red == 1 and self.player:isWounded() then
		oflyuxue_basic = sgs.Card_Parse("#oflyuxueEX:" .. table.concat(AGYids, "+") .. ":" .. "peach")
	elseif #AGYids_black == 1 and self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, newana) then
		oflyuxue_basic = sgs.Card_Parse("#oflyuxueEX:" .. table.concat(AGYids, "+") .. ":" .. "analeptic")
	end
	return oflyuxue_basic
end

sgs.ai_skill_use_func["#oflyuxueEX"] = function(card, use, self)
	local userstring = card:toString()
	userstring = (userstring:split(":"))[4]
	local oflyuxue_basic = sgs.Sanguosha:cloneCard(userstring, card:getSuit(), card:getNumber())
	oflyuxue_basic:setSkillName("oflyuxueEX")
	self:useBasicCard(oflyuxue_basic, use)
	if not use.card then return end
	use.card = card
end

sgs.ai_view_as["oflyuxueEX"] = function(card, player, card_place)
	local AGY = player:getPile("oflAngry")
	local AGYids, AGYids_red, AGYids_black, suit, number = {}, {}, {}, nil, nil
	for _, id in sgs.qlist(AGY) do
		local card = sgs.Sanguosha:getCard(id)
		if card:isRed() then
			table.insert(AGYids_red, card:getEffectiveId())
		elseif card:isBlack() then
			table.insert(AGYids_black, card:getEffectiveId())
		end
		table.insert(AGYids, card:getEffectiveId()) suit = card:getSuit() number = card:getNumber()
		if #AGYids == 1 then break end
	end
	if #AGYids == 1 then
		if #AGYids_red == 1 then return ("peach:oflyuxueEX[%s:%s]=%d"):format(suit, number, AGYids[1])
		elseif #AGYids_black == 1 then return ("analeptic:oflyuxueEX[%s:%s]=%d"):format(suit, number, AGYids[1]) end
	end
end

  --“龙吟”AI
sgs.ai_skill_invoke.ofllongyinEX = true

--长坂坡模式·神张飞
 --原版
  --“缠蛇”AI
    --暂不写。

  --“弑神”AI
local oflshishen_skill = {}
oflshishen_skill.name = "oflshishen"
table.insert(sgs.ai_skills, oflshishen_skill)
oflshishen_skill.getTurnUseCard = function(self)
	if self.player:getPile("oflAngry"):length() < 2 then return end
	local AGY = self.player:getPile("oflAngry")
	local AGYids, AGYids_red, AGYids_black = {}, {}, {}
	for _, id in sgs.qlist(AGY) do
		local card = sgs.Sanguosha:getCard(id)
		if #AGYids == 0 then --第一张
			if card:isRed() then
				table.insert(AGYids_red, card:getEffectiveId())
			elseif card:isBlack() then
				table.insert(AGYids_black, card:getEffectiveId())
			end
			table.insert(AGYids, card:getEffectiveId())
		else --第二张
			if (card:isRed() and #AGYids_red > 0) or (card:isBlack() and #AGYids_black > 0) then
				table.insert(AGYids, card:getEffectiveId())
			end
		end
		if #AGYids == 2 then break end
	end
	if #AGYids < 2 then return nil end
	local oflshishen_card = sgs.Card_Parse("#oflshishenCard:" .. table.concat(AGYids, "+") .. ":")
	return oflshishen_card
end

sgs.ai_skill_use_func["#oflshishenCard"] = function(card, use, self)
	if self.player:getPile("oflAngry"):length() >= 2 then
		self:sort(self.enemies)
	    self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
		    if self:objectiveLevel(enemy) > 0 and enemy:getHp() == 1 then --趁ta病，要ta命
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
		for _, enemy in ipairs(self.enemies) do
		    if self:objectiveLevel(enemy) > 0 then
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
	end
end

sgs.ai_use_value.oflshishenCard = 8.5
sgs.ai_use_priority.oflshishenCard = 9.5
sgs.ai_card_intention.oflshishenCard = 80

    --“弑神”[聚气]AI
sgs.ai_skill_invoke["oflshishenJQ"] = true

 --威力加强版
  --“备粮”AI
sgs.ai_skill_invoke.oflbeiliangEX = true

  --“缠蛇”AI
    --暂不写。

  --“弑神”AI
local oflshishenEX_skill = {}
oflshishenEX_skill.name = "oflshishenEX"
table.insert(sgs.ai_skills, oflshishenEX_skill)
oflshishenEX_skill.getTurnUseCard = function(self)
	if self.player:getPile("oflAngry"):length() < 2 then return end
	local AGY = self.player:getPile("oflAngry")
	local AGYids = {}
	for _, id in sgs.qlist(AGY) do
		local card = sgs.Sanguosha:getCard(id)
		table.insert(AGYids, card:getEffectiveId())
		if #AGYids == 2 then break end
	end
	if #AGYids < 2 then return nil end
	local oflshishen_exc = sgs.Card_Parse("#oflshishenEXCard:" .. table.concat(AGYids, "+") .. ":")
	return oflshishen_exc
end

sgs.ai_skill_use_func["#oflshishenEXCard"] = function(card, use, self)
	if self.player:getPile("oflAngry"):length() >= 2 then
		self:sort(self.enemies)
	    self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
		    if self:objectiveLevel(enemy) > 0 and enemy:getHp() <= 1 then --趁ta病，要ta命
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
		for _, enemy in ipairs(self.enemies) do
		    if self:objectiveLevel(enemy) > 0 then
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
	end
end

sgs.ai_use_value.oflshishenEXCard = 8.5
sgs.ai_use_priority.oflshishenEXCard = 9.5
sgs.ai_card_intention.oflshishenEXCard = 80

    --“弑神”[聚气]AI
sgs.ai_skill_invoke["oflshishenEXJQ"] = true




--

--==DIY神武将AI==--
--神刘备-威力加强版（要是ai能管住这家伙，我也不至于要隐藏他了）

--神董卓
  --“凶宴”AI
sgs.ai_skill_invoke.f_xiongyan = true

sgs.ai_skill_choice.f_xiongyan = function(self, choices, data)
	if self.player:getHandcardNum() + self.player:getEquips():length() < 2 then return "1" end
	if self.player:getHp() <= 1 then return "2" end
	for _, friend in ipairs(self.friends) do
		if friend:hasFlag("f_shendongzhuo") then return "2" end
	end
	--return "1"
	return "2"
end

sgs.ai_skill_discard.f_xiongyan = function(self) --限制电脑只能给两张，否则一旦牌多了就变成遛狗了
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	table.insert(to_discard, cards[1]:getEffectiveId())
	table.insert(to_discard, cards[2]:getEffectiveId())
	return to_discard
end

sgs.ai_skill_invoke["@f_xiongyanDraw"] = function(self, data)
	--[[local targets = sgs.QList2Table(targets)
	self:sort(self.friends_noself)
	for _, p in pairs(self.friends_noself) do
		if p:hasFlag("f_sdzForE") and self:isFriend(p) then
			return true
		end
	end
	return false]]
	self:sort(self.enemies)
	self.enemies = sgs.reverse(self.enemies)
	for _, enemy in ipairs(self.enemies) do
		if enemy:hasFlag("f_sdzForE") and self:objectiveLevel(enemy) > 0 then --直接反向思考，若是敌人就不给，否则就给（学会了仁德的董太师）
		    return false
		end
	end
	return true
end



--

--神刘禅
  --“单杀”AI
sgs.ai_skill_invoke.f_dansha = function(self, data)
	return self.player:hasLordSkill("f_dansha")
end

sgs.ai_skill_playerchosen.f_dansha = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
	    if self:isEnemy(p) then
		    return p 
		end
	end
	return nil
end



--

--神曹仁
  --“奇阵”AI
sgs.ai_skill_invoke.f_qizhen = function(self, data)
	local use = data:toCardUse()
	return not self:isFriend(use.from)
end

  --“励军”AI
sgs.ai_skill_invoke.f_lijun = true

sgs.ai_skill_choice.f_lijun = function(self, choices, data)
	local targets = sgs.QList2Table(targets)
	for _, p in pairs(targets) do
		if self:isEnemy(p) and p:getHandcardNum() - p:getHp() >= 3 then --评估场上是否有手牌溢出较严重的敌方，这样才有选2选项的价值
			return "2"
		end
	end
	return "1"
end

sgs.ai_skill_playerchosen.f_lijun = function(self, targets)
	local targets = sgs.QList2Table(targets)
	if self.player:hasFlag("f_lijunChooseOne") then --1选项，选择友方
		self:sort(self.friends_noself)
		for _, p in ipairs(self.friends_noself) do --先找没手牌的队友
			if self:isFriend(p) and p:getHandcardNum() == 0 and not p:hasSkill("kongcheng") then
				return p
			end
		end
		for _, p in ipairs(self.friends_noself) do --再找手牌低于其体力值的队友
			if self:isFriend(p) and p:getHandcardNum() < p:getHp() then
				return p
			end
		end
		for _, p in ipairs(self.friends_noself) do --然后还是优先找队友
			if self:isFriend(p) then
				return p
			end
		end
		return self.player --若没有队友，就给自己用
	elseif self.player:hasFlag("f_lijunChooseTwo") then --2选项，选择敌方
		self:sort(targets, "defense")
		for _, p in ipairs(targets) do
			if self:isEnemy(p) and p:getHandcardNum() - p:getHp() >= 3 then
				return p
			end
		end
	end
	return nil
end

--[[sgs.ai_skill_invoke["@f_lijunGHJ"] = function(self, data)
	local target = data:toPlayer()
	return self:isFriend(target)
end]]



--

--神赵云&陈到
  --“勇魂”AI（如果单纯是“摸牌数+2”＋“手牌上限+2”，强度如何？）
local f_yonghun_skill = {}
f_yonghun_skill.name = "f_yonghun"
table.insert(sgs.ai_skills, f_yonghun_skill)
f_yonghun_skill.getTurnUseCard = function(self)
	return sgs.Card_Parse("#f_yonghunCard:.:")
end

sgs.ai_skill_use_func["#f_yonghunCard"] = function(card, use, self)
    if not self.player:hasUsed("#f_yonghunCard") then
        use.card = card
	    return
	end
end

sgs.ai_use_value.f_yonghunCard = 8.5
sgs.ai_use_priority.f_yonghunCard = 9.5
sgs.ai_card_intention.f_yonghunCard = -80

--神于吉
  --“回生”AI
sgs.ai_skill_invoke.f_huisheng = function(self, data)
	--[[if self.player:getCardsNum("Peach") > 0 or self.player:getCardsNum("Analeptic") > 0 then return false end
	return true]]
	local dying = data:toDying()
	local peaches = 1 - dying.who:getHp()
	return self:getCardsNum("Peach") + self:getCardsNum("Analeptic") < peaches
end

  --“妙道”AI
sgs.ai_skill_invoke.f_miaodao = function(self, data)
	if self.player:getPile("f_syjDao"):length() >= 4 or self.player:getHandcardNum() <= 2 then return false end
	return true
end



--

--神庞统
  --“凤雏”AI
sgs.ai_skill_choice.f_fengchu = function(self, choices, data)
	if self.player:isWounded() then return "2"
	else return "1" end --受伤回复，满血加槽
	return "3" or "4" --为求稳必选这两个选项，摸牌收益高（不考虑被乐了、左慈等）、封印“落凤”保证不发生意外
end

--

--//神蒲元的“神兵库”//--
--1.混毒弯匕(已有,不用写)
----
--2.水波剑(已有,不用写)
----
--3.烈淬刀(已有,不用写)
----
--4.红锻枪(已有,不用写)
----
--5.无双方天戟
sgs.weapon_range.Fwushuangfangtianji = 4
sgs.ai_use_priority.Fwushuangfangtianji = 2.64
sgs.ai_skill_invoke["Fwushuangfangtianji"] = true
sgs.ai_skill_choice["Fwushuangfangtianji"] = function(self, choices, data)
	local target = data:toPlayer()
	if self:isFriend(target) then return "1" end --一般情况下，总不能丢队友的牌
	return "1" or "2=" .. damage.to:objectName()
end
--6.鬼龙斩月刀
sgs.weapon_range.Fguilongzhanyuedao = 3
sgs.ai_use_priority.Fguilongzhanyuedao = 2.66
--7.赤血青锋
sgs.weapon_range.Fchixieqingfeng = 2
sgs.ai_use_priority.Fchixieqingfeng = 2.65
--8.镔铁双戟
sgs.weapon_range.Fbingtieshuangji = 3
sgs.ai_use_priority.Fbingtieshuangji = 2.63
sgs.ai_skill_invoke["Fbingtieshuangji"] = function(self, data)
	if self.player:getHp() <= 1 and not self.player:hasSkill("newjuejing") and not self.player:hasSkill("mrds_juejing") then return false end
	return true
end
--9.乌铁锁链(已有,不用写)
----
--10.五行鹤翎扇(已有,不用写)
----
--11.玲珑狮蛮带
sgs.ai_use_priority.Flinglongshimandai = 0.88
sgs.ai_skill_invoke["Flinglongshimandai"] = function(self, data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end
--12.红棉百花袍
sgs.ai_use_priority.Fhongmianbaihuapao = 0.86
--13.国风玉袍
sgs.ai_use_priority.Fguofengyupao = 0.7
--14.奇门八阵
sgs.ai_use_priority.Fqimenbazhen = 0.72
--15.护心镜(已有,不用写)
----
--16.黑光铠(已有,不用写)
----
--17.束发紫金冠
sgs.ai_skill_playerchosen["Fshufazijinguan"] = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
	    if self:isEnemy(p) and p:getHp() <= 1 and not p:hasSkill("newjuejing") and not p:hasSkill("mrds_juejing") then --神赵云：tnnd，针对我是吧
		    return p 
		end
	end
	for _, p in ipairs(targets) do
	    if self:isEnemy(p) then
		    return p 
		end
	end
	return nil
end
--18.虚妄之冕
  --（无）
--19.天机图(已有,不用写)
----
--20.太公阴符(已有,不用写)
----
--21.三略
  --（无）
--22.照骨镜
  --（无）
----------------------
----
sgs.weapon_range.XyruyijingubangOne = 1
sgs.ai_use_priority.XyruyijingubangOne = 2.61
sgs.weapon_range.XyruyijingubangTwo = 2
sgs.ai_use_priority.XyruyijingubangTwo = 2.62
sgs.weapon_range.XyruyijingubangThree = 3
sgs.ai_use_priority.XyruyijingubangThree = 2.63
sgs.weapon_range.XyruyijingubangFour = 4
sgs.ai_use_priority.XyruyijingubangFour = 2.64


--

--神司马炎
  --“征灭(初版)”AI
sgs.ai_skill_playerchosen.f_zhengmie = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
	    if self:isEnemy(p) then
		    return p 
		end
	end
	return nil
end
  --“征灭(正式版)”AI
sgs.ai_skill_playerchosen.f_zhengmie_f = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
	    if self:isEnemy(p) then
		    return p 
		end
	end
	return nil
end

  --“奢靡”AI
sgs.ai_skill_choice.dy_shemi = function(self, choices, data)
	return not "cancel"
end


--

--神刘协
  --“天子”AI（代替出【闪】的部分）
sgs.ai_skill_invoke.f_skysson = true

  --“傀儡”AI
sgs.ai_skill_invoke.f_kuilei = true

sgs.ai_skill_playerchosen.f_kuilei = function(self, targets)
	local targets = sgs.QList2Table(targets)
	self:sort(self.friends_noself)
	for _, p in ipairs(self.friends_noself) do
		if self:isFriend(p) and not p:isNude() and (p:hasSkill("jijiu") or p:hasSkill("longhun") or p:hasSkill("newlonghun")
		or p:hasSkill("mrds_longhun") or p:hasSkill("sgkgodlonghun")) then --先找靠谱的队友
			return p
		end
	end
	--[[for _, p in ipairs(self.friends_noself) do
		if self:isFriend(p) and not p:isKongcheng() then --再找或许能救自己的队友（实测大部分时候都是坑队友，无效化了）
			return p
		end
	end]]
	for _, p in ipairs(targets) do --没得救就坑对手
		if self:isEnemy(p) then
			return p
		end
	end
end

--

--新神刘禅
  --“单杀”AI
sgs.ai_skill_invoke.f_dansha_new = true

sgs.ai_skill_playerchosen.f_dansha_new = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
	    if self:isEnemy(p) then
		    return p 
		end
	end
	return nil
end





--

--神-曹丕&甄姬
  --“洛殇”AI
sgs.ai_skill_invoke.diy_k_luoshang = true





--

--十长逝
  --韩悝-“巧思”AI
local hl_qiaosi_skill = {}
hl_qiaosi_skill.name = "hl_qiaosi"
table.insert(sgs.ai_skills, hl_qiaosi_skill)
hl_qiaosi_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#hl_qiaosiCard") then return end
	return sgs.Card_Parse("#hl_qiaosiCard:.:")
end

sgs.ai_skill_use_func["#hl_qiaosiCard"] = function(card, use, self)
	if not self.player:hasUsed("#hl_qiaosiCard") then
		use.card = card
	end
end

sgs.ai_use_value.hl_qiaosiCard = 8.5
sgs.ai_use_priority.hl_qiaosiCard = 9.5
sgs.ai_card_intention.hl_qiaosiCard = -80

sgs.ai_skill_choice["ShuiZhuanBaiXiTu"] = function(self, choices, data)
	return "1" or "6"
end

sgs.ai_skill_choice.hl_qiaosi = function(self, choices, data)
	self:updatePlayers()
	for _, friend in ipairs(self.friends_noself) do
		if not self:needKongcheng(friend, true) and not hasManjuanEffect(friend) then
			return "give"
		end
	end
	return "throw"
end

sgs.ai_skill_playerchosen.hl_qiaosi = function(self, targets)
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

sgs.ai_playerchosen_intention.hl_qiaosi = -80

  --高望-“安弱”AI
local dg_anruo_skill = {}
dg_anruo_skill.name = "dg_anruo"
table.insert(sgs.ai_skills, dg_anruo_skill)
dg_anruo_skill.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByUseValue(cards, true)
	for _, card in ipairs(cards) do
		if card:getSuit() == sgs.Card_Diamond and self:slashIsAvailable() then
			return sgs.Card_Parse(("fire_slash:dg_anruo[%s:%s]=%d"):format(card:getSuitString(), card:getNumberString(), card:getId()))
		end
	end
end

sgs.ai_view_as.dg_anruo = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place == sgs.Player_PlaceSpecial then return end
	if card:getSuit() == sgs.Card_Diamond then
		return ("fire_slash:dg_anruo[%s:%s]=%d"):format(suit, number, card_id)
	elseif card:getSuit() == sgs.Card_Club then
		return ("jink:dg_anruo[%s:%s]=%d"):format(suit, number, card_id)
	elseif card:getSuit() == sgs.Card_Heart and player:getMark("Global_PreventPeach") == 0 then
		return ("peach:dg_anruo[%s:%s]=%d"):format(suit, number, card_id)
	elseif card:getSuit() == sgs.Card_Spade then
		return ("nullification:dg_anruo[%s:%s]=%d"):format(suit, number, card_id)
	end
end

sgs.dg_anruo_suit_value = {
	heart = 6.7,
	spade = 5,
	club = 4.2,
	diamond = 3.9,
}

function sgs.ai_cardneed.dg_anruo(to, card, self)
	if to:isNude() then return true end
	return card:getSuit() == sgs.Card_Heart or card:getSuit() == sgs.Card_Spade
end

sgs.ai_skill_invoke.dg_anruo = function(self, data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end

sgs.ai_skill_playerchosen.dg_anruo = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
	    if self:isEnemy(p) and not p:isNude() then
		    return p 
		end
	end
	return nil
end



--

--神袁绍
  --“名望”AI
sgs.ai_skill_choice.f_mingwang = function(self, choices, data)
	return "1"
end

  --“非势”AI（“势”角色的抉择）
sgs.ai_skill_invoke.f_feishi = function(self, data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end 