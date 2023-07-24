--mobileGod.lua的武将/卡牌AI
--==手杀神武将AI==--
--神郭嘉
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

sgs.ai_skill_invoke["@f_huishi_continue"] = true

sgs.ai_skill_playerchosen["f_huishi"] = function(self, targets)
    targets = sgs.QList2Table(targets)
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

--神荀彧
  --锦囊【奇正相生】（正兵与奇兵的智能用法已写进锦囊里，但也不够智能；无懈AI在smart-ai.lua里）
    --使用AI
function SmartAI:useCardFqizhengxiangsheng(card, use)
	for _, enemy in ipairs(self.enemies) do
		if self:objectiveLevel(enemy) > 0 then
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

--神太史慈
  --待写

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

--神孙策
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

  --“冯河”AI
    --鉴定为：春春的芝长
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

--==十周年神武将AI==--
--神姜维(爆料版/正式版)
  --“九伐”AI（自动发动）

--神马超
  --“横骛”AI（自动发动）

--==OL神武将AI==--
--神曹丕
  --“储元”AI
sgs.ai_skill_invoke.olchuyuan = function(self, data)
	local player = data:toPlayer()
	if self.player:getPile("powerful"):length() == 2 then
		if self.player:hasSkill("oldengji") and self.player:getMark("oldengji") <= 0 then return self.player:getMaxHp() > 1 end
		if self.player:hasSkill("oltianxing") and self.player:getMark("oltianxing") <= 0 then return self.player:getMaxHp() > 1 end
	end
	if self:doNotDiscard(player, "h") then return false end
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
			if self:isEnemy(target) and self:damageIsEffective(target, sgs.DamageStruct_Thunder) then table.insert(enemies, target) end
		end
		self:sort(enemies, "hp")
		return enemies[1]
	elseif isEvenInteger(self.player:getHandcardNum()) then
		local firstpriority = {}
		local tos = {}
		for _, target in sgs.qlist(targets) do
			if math.abs(target:getHandcardNum() - target:getHp()) == 1 then
				table.insert(firstpriority, target)
			else
				if self:isFriend(target) or (self:isEnemy(target) and not target:isKongcheng()) or (self:isEnemy(target) and target:hasSkill("kongcheng") and target:isKongcheng()) then
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

--==欢乐杀神武将AI==--
--欢乐杀神孙权
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

--欢乐杀神张辽
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

--欢乐杀神典韦
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

--电脑有一定概率更换皮肤
sgs.ai_skill_invoke.mobileGOD_SkinChange = function(self, data)
    if math.random() > 0.5 then return true end
	return false
end