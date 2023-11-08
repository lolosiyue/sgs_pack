--==沙雕包==--
--<1.0>--
--神华佗
  --“疗毒”AI
local f_liaodu_skill = {}
f_liaodu_skill.name = "f_liaodu"
table.insert(sgs.ai_skills, f_liaodu_skill)
f_liaodu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("f_liaoduCard") or self:getCardsNum("EquipCard") == 0 then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if self:needToThrowArmor() then
		card_id = self.player:getArmor():getId()
	elseif self.player:getHandcardNum() > self.player:getHp() then
		for _, acard in ipairs(cards) do
			if acard:isKindOf("EquipCard") then
				card_id = acard:getEffectiveId()
				break
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
		for _, acard in ipairs(cards) do
			if acard:isKindOf("EquipCard") then
				card_id = acard:getEffectiveId()
				break
			end
		end
	end
	if not card_id then
	    return nil
	else
	    return sgs.Card_Parse("#f_liaoduCard:"..card_id..":")
	end
end

sgs.ai_skill_use_func["#f_liaoduCard"] = function(card, use, self)
	if not self.player:hasUsed("#f_liaoduCard") then
		local arr1, arr2 = self:getWoundedFriend(false, true)
		local target = nil
		if #arr1 > 0 and (self:isWeak(arr1[1]) or self:getOverflow() >= 1) and arr1[1]:getHp() < getBestHp(arr1[1]) then target = arr1[1] end
		if target then
			use.card = card
			if use.to then use.to:append(target) end
			return
		end
		if self:getOverflow() > 0 and #arr2 > 0 then
			for _, friend in ipairs(arr2) do
				if not friend:hasSkills("hunzi|longhun") then
					use.card = card
					if use.to then use.to:append(friend) end
					return
				end
			end
		end
	end
end

sgs.ai_use_value.f_liaoduCard = 7.1
sgs.ai_use_priority.f_liaoduCard = 4.2
sgs.ai_card_intention.f_liaoduCard = -100

sgs.dynamic_value.benefit.f_liaoduCard = true

  --“五禽”AI
local f_wuqin_skill = {}
f_wuqin_skill.name = "f_wuqin"
table.insert(sgs.ai_skills, f_wuqin_skill)
f_wuqin_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("f_wuqinCard") or (self:getCardsNum("Slash") == 0 and self:getCardsNum("Jink") == 0 and self:getCardsNum("Analeptic") == 0) or #self.enemies == 0 then return end
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
	    return sgs.Card_Parse("#f_wuqinCard:"..card_id..":")
	end
end

sgs.ai_skill_use_func["#f_wuqinCard"] = function(card, use, self)
    if not self.player:hasUsed("#f_wuqinCard") then
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

sgs.ai_use_value.f_wuqinCard = 8.5
sgs.ai_use_priority.f_wuqinCard = 9.5
sgs.ai_card_intention.f_wuqinCard = -80

--魔王-孙笑川（AI源自“脑洞包brainhole-ai.lua”）
  --“暴徒”AI
sgs.ai_skill_cardask["#f_baotu"] = function(self, data)
	local damage = self.room:getTag("CurrentDamageStruct"):toDamage()
	local to = damage.to
	if self:isEnemy(to) then
		if not (to:hasSkill("duanchang") or to:hasSkill("huilei")) then
			local cards = sgs.QList2Table(self.player:getCards("he"))
			if #cards == 0 then return end
			self:sortByKeepValue(cards)
			return cards[1]:getId()
		end
	end
	return "."
end

  --“儒雅”AI
sgs.ai_skill_invoke.f_ruya = function(self, data)
	return self:isEnemy(data:toPlayer())
end

sgs.ai_skill_discard.f_ruya = function(self)
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	table.insert(to_discard, cards[1]:getEffectiveId())
	return to_discard
end

  --“天皇”AI
sgs.ai_skill_invoke.f_tianhuang = function(self, data)
	if self.player:getHp() > 2 then return true end
	return false
end

sgs.ai_skill_invoke["f_tianhuang-to"] = function(self, data)
	return self:isFriend(data:toPlayer())
end

--管云鹏
  --“隐忍”AI
sgs.ai_skill_invoke["f_yinren_skipplayerstart"] = true
sgs.ai_skill_invoke["f_yinren_skipplayerjudge"] = true
sgs.ai_skill_invoke["f_yinren_skipplayerdiscard"] = true
sgs.ai_skill_invoke["f_yinren_skipplayerfinish"] = true

--广西鹿哥
  --“喜提”AI
local f_xiti_skill = {}
f_xiti_skill.name = "f_xiti"
table.insert(sgs.ai_skills, f_xiti_skill)
f_xiti_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("f_xitiCard") then return end
	return sgs.Card_Parse("#f_xitiCard:.:")
end

sgs.ai_skill_use_func["#f_xitiCard"] = function(card, use, self)
    if not self.player:hasUsed("#f_xitiCard") then
        use.card = card
	    return
	end
end

sgs.ai_skill_choice.f_xiti = function(self, choices, data)
	local items = choices:split("+")
	if self:needToThrowArmor() and self.player:hasEquipArea(1) and table.contains(items, "1") then
		return "1"
	elseif self.player:hasEquipArea(4) and not self.player:getTreasure() and table.contains(items, "4") then
		return "4"
	elseif self.player:hasEquipArea(1) and not self.player:getArmor() and table.contains(items, "1") then
		return "1"	
	elseif self.player:hasEquipArea(0) and not self.player:getWeapon() and table.contains(items, "0") then
		return "0"
	elseif self.player:hasEquipArea(3) and not self.player:getOffensiveHorse() and table.contains(items, "3") then
		return "3"	
	elseif self.player:hasEquipArea(2) and not self.player:getDefensiveHorse() and table.contains(items, "2") then
		return "2"
	elseif self.player:hasEquipArea(4) and not self:keepWoodenOx() and table.contains(items, "4") then
		return "4"
	elseif self.player:hasEquipArea(1) and table.contains(items, "1") then
		return "1"	
	elseif self.player:hasEquipArea(0) and table.contains(items, "0") then
		return "0"	
	elseif self.player:hasEquipArea(3) and table.contains(items, "3") then
		return "3"
	elseif self.player:hasEquipArea(2) and table.contains(items, "2") then
		return "2"
	else
		return items[1]
	end
end

sgs.ai_use_value.f_xitiCard = 8.5
sgs.ai_use_priority.f_xitiCard = 9.5
sgs.ai_card_intention.f_xitiCard = -80

--[1.5]--
--界·魔王-孙笑川
  --“界暴徒”AI
sgs.ai_skill_cardask["#j_baotu"] = function(self, data)
	local damage = self.room:getTag("CurrentDamageStruct"):toDamage()
	local to = damage.to
	if self:isEnemy(to) then
		if not (to:hasSkill("duanchang") or to:hasSkill("huilei")) then
			local cards = sgs.QList2Table(self.player:getCards("he"))
			if #cards == 0 then return end
			self:sortByKeepValue(cards)
			return cards[1]:getId()
		end
	end
	return "."
end

  --“界儒雅”AI
sgs.ai_skill_invoke.j_ruya = function(self, data)
	return self:isEnemy(data:toPlayer())
end

sgs.ai_skill_discard.j_ruya = function(self)
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	table.insert(to_discard, cards[1]:getEffectiveId())
	return to_discard
end

--<<2.0>>--
--无名小卒
  --“只能”AI
sgs.ai_skill_invoke.f_zhineng = true

sgs.ai_skill_playerchosen.f_zhineng = function(self, targets)
	local targets = sgs.QList2Table(targets)
	self:sort(self.friends_noself)
	for _, p in ipairs(self.friends_noself) do --先找没手牌的队友
		if self:isFriend(p) and p:getHandcardNum() == 0 and not p:hasSkill("kongcheng") then
			return p
		end
	end
	for _, p in ipairs(self.friends_noself) do --再找手牌比起其体力值较少的队友
		if self:isFriend(p) and p:getHandcardNum() < p:getHp() then
			return p
		end
	end
	for _, p in ipairs(self.friends_noself) do --然后再找血线危险的队友
		if self:isFriend(p) and p:getHp() <= 1 then
			return p
		end
	end
	for _, p in ipairs(self.friends_noself) do --然后再找手牌溢出不严重的队友
		if self:isFriend(p) and p:getHandcardNum() - p:getHp() < 2 then
			return p
		end
	end
	for _, p in ipairs(self.friends_noself) do --还是先找队友
		if self:isFriend(p) then
			return p
		end
	end
	return self.player --最后给自己
end

--红色风暴&蓝色妖姬
  --“环太平洋·暴风赤红”形态
    --“旋刀雷云阵”AI（等离子炮与冷冻液的AI特意没写，算是对这两种武器在电影中未能展现的遗憾吧。）
local bfch_xdlyz_skill = {}
bfch_xdlyz_skill.name = "bfch_xdlyz"
table.insert(sgs.ai_skills, bfch_xdlyz_skill)
bfch_xdlyz_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("bfch_xdlyzCard") or self.player:getMaxHp() <= 1 then return end
	return sgs.Card_Parse("#bfch_xdlyzCard:.:")
end

sgs.ai_skill_use_func["#bfch_xdlyzCard"] = function(card, use, self)
    if not self.player:hasUsed("#bfch_xdlyzCard") and self.player:getMaxHp() > 1 then
		self:sort(self.enemies)
	    self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
		    if self:objectiveLevel(enemy) > 0 and self.player:canSlash(to_select, nil)
			and (self.player:getWeapon():isKindOf("QinggangSword") or not enemy:hasArmorEffect("vine")) then --若自己未装备青釭剑，避开装有藤甲的目标
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
		return nil
	end
end

sgs.ai_use_value.bfch_xdlyzCard = 8.5
sgs.ai_use_priority.bfch_xdlyzCard = 9.5
sgs.ai_card_intention.bfch_xdlyzCard = 80

sgs.ai_skill_choice.bfch_xdlyz = function(self, choices, data)
	if self.player:getMaxHp() <= 2 then return "1" end
	if self.player:getMaxHp() == 3 then return "2" end
	return "3"
end

--狂暴流氓云
  --“冲阵”AI
sgs.ai_skill_playerchosen.f_chongzhen = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
	    if self:isEnemy(p) and not p:isAllNude() then
		    return p
		end
	end
	return nil
end

sgs.ai_skill_invoke.f_chongzhen = function(self, data)
	local target = data:toPlayer()
	if self:isFriend(target) then
		if hasManjuanEffect(self.player) then return false end
		if target:getJudgingArea():length() > 0 then return true end
		if self:needKongcheng(target) and target:getHandcardNum() == 1
		and target:getEquips():length() == 0 and target:getJudgingArea():length() == 0 then return true end
		if self:getOverflow(target) > 2 then return true end
		return false
	else
		return not (self:needKongcheng(target) and target:getHandcardNum() == 1
		and target:getEquips():length() == 0 and target:getJudgingArea():length() == 0)
	end
end

--(神徐盛/神黄忠)一定概率更换皮肤
sgs.ai_skill_invoke["@f_forSXSandSHZ_changeSkin"] = function(self, data)
    if math.random() > 0.5 then return true end
	return false
end

--神徐盛
  --“魄君”AI
sgs.ai_skill_invoke["f_pojun"] = function(self, data)
    local target = data:toPlayer()
    if not self:isFriend(target) then return true end
    return false
end

sgs.ai_skill_choice["f_pojun"] = function(self, choices, data)
	return #(choices:split("+"))
end

  --“怡娍”AI
sgs.ai_skill_invoke.f_yicheng = function(self, data)
	local target = data:toPlayer()
	return self:isFriend(target)
end

  --“搭妆”AI
sgs.ai_skill_invoke.f_dazhuang = true

--神黄忠
  --“开弓”AI
sgs.ai_skill_invoke.f_kaigong = function(self, data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end

  --“弓魂”AI
sgs.ai_skill_invoke["f_gonghunMission"] = true

    --“谋烈弓”AI
sgs.ai_skill_invoke.f_mouliegong = function(self, data)
    if not (self.player:getMark("&f_mouliegong+heart") > 0 and self.player:getMark("&f_mouliegong+diamond") > 0) then return false end
	local target = data:toPlayer()
	return not self:isFriend(target)
end

    --“神烈弓”AI
local smzy_shenliegong_skill = {}
smzy_shenliegong_skill.name = "smzy_shenliegong"
table.insert(sgs.ai_skills, smzy_shenliegong_skill)
smzy_shenliegong_skill.getTurnUseCard = function(self, inclusive)
	local x = 1
	if self.player:isWounded() then x = 2 end
	if self.player:getMark("slg_fire_time") >= x then return end
	if #self.enemies == 0 then return end
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByUseValue(cards, true)
	local need_ids = {}
	for _, c in ipairs(cards) do
		if c:getSuit() == sgs.Card_Spade and not c:isKindOf("Analeptic") then
			table.insert(need_ids, c:getEffectiveId())
			break
		end
	end
	for _, c in ipairs(cards) do
		if c:getSuit() == sgs.Card_Heart and not c:isKindOf("ExNihilo") then
			table.insert(need_ids, c:getEffectiveId())
			break
		end
	end
	for _, c in ipairs(cards) do
		if c:getSuit() == sgs.Card_Club then
			table.insert(need_ids, c:getEffectiveId())
			break
		end
	end
	for _, c in ipairs(cards) do
		if c:getSuit() == sgs.Card_Diamond and not c:isKindOf("Analeptic") then
			table.insert(need_ids, c:getEffectiveId())
			break
		end
	end
	if #need_ids > 0 then
		if #need_ids == 1 then
			local c = sgs.Sanguosha:getCard(need_ids[1])
			return sgs.Card_Parse(("fire_slash:smzy_shenliegong[%s:%s]=%d"):format(c:getSuitString(), c:getNumberString(), c:getEffectiveId()))
		end
		if #need_ids == 2 then return sgs.Card_Parse(("fire_slash:smzy_shenliegong[%s:%s]=%d+%d"):format("to_be_decided", 0, need_ids[1], need_ids[2])) end
		if #need_ids == 3 then return sgs.Card_Parse(("fire_slash:smzy_shenliegong[%s:%s]=%d+%d+%d"):format("to_be_decided", 0, need_ids[1], need_ids[2], need_ids[3])) end
		if #need_ids == 4 then return sgs.Card_Parse(("fire_slash:smzy_shenliegong[%s:%s]=%d+%d+%d+%d"):format("to_be_decided", 0, need_ids[1], need_ids[2], need_ids[3], need_ids[4])) end
	end
end

sgs.ai_view_as["smzy_shenliegong"] = function(card, player, card_place, class_name)
	local cards = sgs.QList2Table(player:getCards("h"))
	local x = 1
	if player:isWounded() then x = 2 end
	if player:getMark("slg_fire_time") >= x then return end
	local need_ids = {}
	for _, c in ipairs(cards) do
		if c:getSuit() == sgs.Card_Spade and not c:isKindOf("Analeptic") then
			table.insert(need_ids, c:getEffectiveId())
			break
		end
	end
	for _, c in ipairs(cards) do
		if c:getSuit() == sgs.Card_Heart and not c:isKindOf("ExNihilo") then
			table.insert(need_ids, c:getEffectiveId())
			break
		end
	end
	for _, c in ipairs(cards) do
		if c:getSuit() == sgs.Card_Club then
			table.insert(need_ids, c:getEffectiveId())
			break
		end
	end
	for _, c in ipairs(cards) do
		if c:getSuit() == sgs.Card_Diamond and not c:isKindOf("Analeptic") then
			table.insert(need_ids, c:getEffectiveId())
			break
		end
	end
	if #need_ids >= 2 then
		if #need_ids == 2 then
			return ("fire_slash:smzy_shenliegong[%s:%s]=%d+%d"):format("to_be_decided", 0, need_ids[1], need_ids[2])
		elseif #need_ids == 3 then
			return ("fire_slash:smzy_shenliegong[%s:%s]=%d+%d+%d"):format("to_be_decided", 0, need_ids[1], need_ids[2], need_ids[3])
		elseif #need_ids == 4 then
			return ("fire_slash:smzy_shenliegong[%s:%s]=%d+%d+%d+%d"):format("to_be_decided", 0, need_ids[1], need_ids[2], need_ids[3], need_ids[4])
		end
	else
		local suit = card:getSuitString()
		local number = card:getNumberString()
		local card_id = card:getEffectiveId()
		return ("fire_slash:smzy_shenliegong[%s:%s]=%d"):format(suit, number, card_id)
	end
end

--灭世“神兵”：赤血刃
sgs.weapon_range.Fchixieren = 1
sgs.ai_use_priority.Fchixieren = 2.5
sgs.ai_skill_invoke["Fchixieren"] = function(self, data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end

--灭世“神兵”：没日弓
sgs.weapon_range.Fmorigong = 6
sgs.ai_use_priority.Fmorigong = 2.52
sgs.ai_skill_invoke["Fmorigong"] = function(self, data)
	local target = data:toPlayer()
	if (self:isFriend(target) and target:hasSkill("zhaxiang")) or (not self:isFriend(target) and not target:hasSkill("zhaxiang")) --防老六
	then return true end
	return false
end