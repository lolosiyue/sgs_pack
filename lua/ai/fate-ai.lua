if not sgs.ai_damage_effect then
	sgs.ai_damage_effect = {}
end


--
sgs.ai_skill_invoke.fateyezhan = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.fateyezhan = sgs.ai_skill_playerchosen.damage



--土狗

local fatetouying_skill = {}
fatetouying_skill.name = "fatetouying"
table.insert(sgs.ai_skills, fatetouying_skill)
fatetouying_skill.getTurnUseCard = function(self, inclusive)
	if not self.player:hasFlag("fatetouyingx")  then return end
	local usable_cards = sgs.QList2Table(self.player:getCards("h"))
	if self.player:getPile("wooden_ox"):length() > 0 then
		for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
			table.insert(usable_cards, sgs.Sanguosha:getCard(id))
		end
	end
	self:sortByUseValue(usable_cards, true)
	local cards = {}
	for _,c in ipairs(usable_cards) do
		local cardex = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(self.player:getMark("fatetouyingskill")):objectName(), c:getSuit(), c:getNumber())
		if not self.player:isCardLimited(cardex, sgs.Card_MethodUse, true) and cardex:isAvailable(self.player) and not c:isKindOf("Peach") and not (c:isKindOf("Jink") and self:getCardsNum("Jink") < 3) then
		local name = sgs.Sanguosha:getCard(self.player:getMark("fatetouyingskill")):objectName()
		local new_card = sgs.Card_Parse((name..":fatetouying[%s:%s]=%d"):format(c:getSuitString(), c:getNumberString(), c:getEffectiveId()))
			assert(new_card) 
			return new_card
		end
	end
end

sgs.ai_view_as.fatetouying = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place == sgs.Player_PlaceHand or player:getPile("wooden_ox"):contains(card_id) then
		local name = sgs.Sanguosha:getCard(player:getMark("fatetouyingskill")):objectName()
		if name and player:hasFlag("fatetouyingx") then
			return (name..":fatetouying[%s:%s]=%d"):format(suit, number, card_id)
		end
	end
end



--saber 王者 

sgs.ai_skill_invoke.fatewangzhe = function(self, data)
	return true
end

sgs.ai_skill_askforag.fatewangzhe = function(self, card_ids)
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
	if not (self:needKongcheng(self.player) and self:getHandcardNum() <= 2) then
		if card:isKindOf("Peach") then
			return valuable
		end
		if card:isKindOf("TrickCard") or card:isKindOf("Indulgence") or card:isKindOf("SupplyShortage") then
			local dummy_use = { isDummy = true }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				return valuable
			end
		end
		if card:isKindOf("Jink") and self:getCardsNum("Jink") == 0 then
			return valuable
		end
		if card:isKindOf("Nullification") and self:getCardsNum("Nullification") == 0 then
			return valuable
		end
		if card:isKindOf("Slash") and self:slashIsAvailable() then
			local dummy_use = { isDummy = true }
			self:useBasicCard(card, dummy_use)
			if dummy_use.card then
				return valuable
			end
		end
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
		return valuable
	end
	if nextAlive:hasSkill("yinghun") and nextAlive:isWounded() then
		return valuable
	end
	if target:hasSkill("hongyan") and hasLightning and self:isEnemy(nextAlive) and not (nextAlive:hasSkill("qiaobian") and nextAlive:getHandcardNum() > 0) then
		for _, id in ipairs(card_ids) do
			local card = sgs.Sanguosha:getEngineCard(id)
			if card:getSuit() == sgs.Card_Spade and card:getNumber() >= 2 and card:getNumber() <= 9 then
				return id
			end
		end
	end
	if hasIndulgence and self:isFriend(nextAlive) then
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
			return valuable
		end
	end

	if self:isFriend(nextAlive) and not self:willSkipDrawPhase(nextAlive) and not self:willSkipPlayPhase(nextAlive)
		and not nextAlive:hasSkill("luoshen")
		and not nextAlive:hasSkill("tuxi") and not (nextAlive:hasSkill("qiaobian") and nextAlive:getHandcardNum() > 0) then
		if (peach and valuable == peach) or (ex_nihilo and valuable == ex_nihilo) then
			return valuable
		end
		if jink and valuable == jink and getCardsNum("Jink", nextAlive) < 1 then
			return valuable
		end
		if nullification and valuable == nullification and getCardsNum("Nullification", nextAlive) < 1 then
			return valuable
		end
		if slash and valuable == slash and self:hasCrossbowEffect(nextAlive) then
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
	return valuable
end


sgs.ai_skill_use["@fatewangzhe"] = function(self, prompt, method)
	local tag = self.room:getTag("fatewangzhe")
	local guanxu_cardsToGet
    if tag then
        guanxu_cardsToGet = tag:toString():split("+")
    else
        return "."
    end
    local discard_cards = {}
	local drawpile = {}
    for i=1,#guanxu_cardsToGet, 1 do
        local card_data = guanxu_cardsToGet[i]
        if card_data == nil then break end
        if card_data ~= "" then 
            local card_id = tonumber(card_data)
            table.insert(drawpile, sgs.Sanguosha:getCard(card_id))
        end
    end
    
    self:sortByUseValue(drawpile)
	for _, c in ipairs(drawpile) do
        table.insert(discard_cards, c:getEffectiveId())
    end
        
		
    if #discard_cards > 0 then
        return string.format("#fatewangzhe:%s:", discard_cards[1])
    end
end





--saber:求战
local fateqiuzhan_skill={}
fateqiuzhan_skill.name="fateqiuzhan"
table.insert(sgs.ai_skills,fateqiuzhan_skill)
fateqiuzhan_skill.getTurnUseCard=function(self)	
    if not self.player:hasUsed("#fateqiuzhan_card") then
		return sgs.Card_Parse("#fateqiuzhan_card:.:")
	end
end

sgs.ai_skill_use_func["#fateqiuzhan_card"]=function(card,use,self)
	self:sort(self.enemies, "hp") -- 按体力值从小到大排序
		for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and  self:damageIsEffective(enemy, sgs.DamageStruct_Normal)		then
				use.card = sgs.Card_Parse("#fateqiuzhan_card:.:") -- 不包含任何子卡的技能卡
				if use.to then
					use.to:append(enemy)
				end
				return
			end
		end
end



-- 手中杀大于等于Saber手牌的一半，则不打出杀
sgs.ai_skill_cardask["@fateqzslash"]=function(self, data, pattern, target)
	target = target or global_room:getCurrent()
	if (self:hasSkill("fatehuyou") and #self.enemies > 0) then
		return "."
	end
	if (self:getCardsNum("Slash")*2 >= target:getHandcardNum()) then
		return "."
	end
end

local fateshenjian_skill={}
fateshenjian_skill.name="fateshenjian"
table.insert(sgs.ai_skills,fateshenjian_skill)
fateshenjian_skill.getTurnUseCard=function(self)	
	if (self.player:getMark("@shenjian_mark")== 0) or not self.player:isWounded() then return end
	
	if self.player:getHp() + self:getCardsNum("Peach") + self:getCardsNum("Analeptic") <= 2 then
		return sgs.Card_Parse("#fateshenjian_card:.:")
	end
	local x = math.min(self.player:getLostHp(), 2)
	local target_num = 0
	for _, enemy in ipairs(self.enemies) do
		if  ((enemy:getHp() <= x) or (x == 2)) and self.player:distanceTo(enemy) <= self.player:getAttackRange()
			and not (self.role == "renegade" and enemy:isLord()) then
			target_num = target_num + 1
		end
	end
	if target_num > 1  or
	(#self.enemies + 1 == self.room:alivePlayerCount() and self.room:alivePlayerCount() < sgs.Sanguosha:getPlayerCount(self.room:getMode())) then
		return sgs.Card_Parse("#fateshenjian_card:.:")
	end
		
end

sgs.ai_skill_use_func["#fateshenjian_card"]=function(card,use,self)
	local x = math.min(self.player:getLostHp(), 2)
	if self.player:getMark("@shenjian_mark") == 0 then return end
	local targets = sgs.SPlayerList()
	self:sort(self.enemies, "hp")
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	local need_cards = {}
	for _, card in ipairs(cards) do
		if not card:isKindOf("Peach")  then 
			table.insert(need_cards, card:getId())
			if #need_cards >= 2 then
				break
			end
		end
	end
	if #need_cards < 2 then return end
	for _, enemy in ipairs(self.enemies) do
		if not (enemy:hasSkills("tianxiang|ol_tianxiang") and enemy:getHandcardNum() > 0) and self:damageIsEffective(enemy, sgs.DamageStruct_Normal) and self.player:distanceTo(enemy) <= self.player:getAttackRange()  and not self:cantbeHurt(enemy) then
			targets:append(enemy)
			if targets:length() >= 2 then break end
		end
	end
	for _, enemy in ipairs(self.enemies) do
		if not targets:contains(enemy) then
			if not (enemy:hasSkills("tianxiang|ol_tianxiang") and enemy:getHandcardNum() > 0) and self:damageIsEffective(enemy, sgs.DamageStruct_Normal) and self.player:distanceTo(enemy) <= self.player:getAttackRange()  and enemy:getHp()<= x then
				targets:append(enemy)
				if targets:length() >= 2 then break end
			end
		end
	end
	if targets:length() > 0 then
		use.card = sgs.Card_Parse("#fateshenjian_card:" .. table.concat(need_cards, "+"))
		if use.to then use.to = targets end
	end
end



--sgs.ai_use_priority["fateqiuzhan_card"] = 8
--sgs.ai_use_priority.fateqiuzhan_card = 8
--sgs.ai_card_intention["fateqiuzhan_card"] = 80
sgs.ai_use_value["#fateqiuzhan_card"] = 8.5
sgs.ai_use_priority["#fateqiuzhan_card"] = 2
sgs.dynamic_value.damage_card["fateqiuzhan_card"] = true
sgs.ai_card_intention["fateqiuzhan_card"] = 60


sgs.ai_use_value["#fateshenjian_card"] = 8.5
sgs.ai_use_priority["#fateshenjian_card"] = 9
sgs.dynamic_value.damage_card["fateshenjian_card"] = true
sgs.ai_card_intention["fateshenjian_card"] = 100


--Archer:天弓 出牌阶段，你可以弃一张手牌然后选择一名角色或两名距离1以内的角色，视为对其打出了一张不计入出牌阶段限制的无色的【火杀】。每回合限一次。
local fatetiangong_skill={}
fatetiangong_skill.name="fatetiangong_vs"
table.insert(sgs.ai_skills,fatetiangong_skill)
fatetiangong_skill.getTurnUseCard=function(self)
    if self.player:getHandcardNum()<1 then return nil end
    if self.player:hasUsed("#fatetiangong_card") then return nil end
    local cards = self.player:getHandcards()
    cards=sgs.QList2Table(cards)
    self:sortByKeepValue(cards)
	local card_str = ("#fatetiangong_card:%d:"):format(cards[1]:getId())
    return sgs.Card_Parse(card_str)
end

sgs.ai_skill_use_func["#fatetiangong_card"]=function(card,use,self)
	local first
	local slash = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_NoSuit, 0)
	self:sort(self.enemies, "hp") -- 按体力值从小到大排序
	for _, enemy in ipairs(self.enemies) do
		if self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and self.player:canSlash(enemy, slash) and not self:slashProhibit(slash, enemy) 
						and self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self) then
			use.card = sgs.Card_Parse("#fatetiangong_card:" .. card:getEffectiveId()..":")  -- 包含子卡的技能卡
			if use.to then
				use.to:append(enemy)
				first=enemy
				break
			end
		end
	end
	if first and self.player:distanceTo(first) == 1 then 
		for _, enemy2 in ipairs(self.enemies) do
		--	if ((enemy2:getSeat() - first:getSeat())==1 or (enemy2:getSeat() - first:getSeat())==-1) and not self:cantbeHurt(enemy) and enemy:getMark("@fog") < 1 and not enemy:hasSkill("fatefapao") then
			if (self.player:distanceTo(enemy2) == 1) and enemy2:getSeat() ~= first:getSeat() and not self:cantbeHurt(enemy2) and self.player:canSlash(enemy2, slash) and not self:slashProhibit(slash, enemy2) 
						and self:slashIsEffective(slash, enemy2) and sgs.isGoodTarget(enemy2, self.enemies, self) then
				use.to:append(enemy2)
				return
			end
		end
	end
end

sgs.ai_use_value.fatetiangong_card = 7.5
sgs.ai_use_priority.fatetiangong_card = 4
sgs.ai_card_intention.fatetiangong_card = 70

sgs.ai_skill_invoke.fatejianzhong = function(self, data)
	return true
end

sgs.ai_skill_playerchosen["@fatejianzhong2"] = sgs.ai_skill_playerchosen.zero_card_as_slash


--Berserker
--[[sgs.ai_skill_cardask["@fatejuli-jink-1"] = function(self)
    if (not (self:getCardsNum("Jink") > 0 and self:getCardsNum("Slash") > 0)) and (not (self.player:getHandcardNum() == 1 and self:hasSkills(sgs.need_kongcheng))) and (not self:hasSkill("lianying"))  then return "." end	
end]]

sgs.ai_skill_cardask["@fatejuli-jink-1"] = function(self, data, pattern, target)
	local isdummy = type(data) == "number"
	local function getJink()
		if (self:getCardsNum("Jink") > 0 and self:getCardsNum("Slash") > 0) then
		return self:getCardId("Slash") or not isdummy and "."
		else
		return "."
		end
	end

	local slash
	if type(data) == "userdata" then
		local effect = data:toSlashEffect()
		slash = effect.slash
	else
		slash = sgs.Sanguosha:cloneCard("slash")
	end
	local cards = sgs.QList2Table(self.player:getHandcards())
	if (not target or self:isFriend(target)) and slash:hasFlag("nosjiefan-slash") then return "." end
	if sgs.ai_skill_cardask.nullfilter(self, data, pattern, target) then return "." end
	if not target then return getJink() end
	if not self:hasHeavySlashDamage(target, slash, self.player) and self:getDamagedEffects(self.player, target, slash) then return "." end
	
	--排除有大霧非雷殺出閃
	local shenzhugeliang = self.room:findPlayerBySkillName("dawu")
	if shenzhugeliang and not target:hasSkill("jueqing") and self.player:getMark("@fog") > 0 and slash and not slash:isKindOf("ThunderSlash") then return "." end
	--新神趙雲手中有酒或桃賣血摸牌
	if self.player:hasSkills("new_longhun+new_juejing") and not self:hasHeavySlashDamage(target, slash, self.player) then
		if self:getCardId("Peach") or self:getCardId("Analeptic") then
			return "."
		end
	end
	
	--已下可以注釋掉，因為sgs.ai_skill_cardask.nullfilter已經檢查元素傷害部分有沒有效。但預防萬一還是保留。
	--排除司馬徽隱士技能，AI司馬徽被打
	if slash and target and slash:isKindOf("NatureSlash") and not target:hasSkill("jueqing") and self.player:hasSkill("yinshi") and self.player:getMark("@dragon") + self.player:getMark("@phoenix") == 0 and not self.player:getArmor() then return "." end
	--排除TW馬良白眉，TW馬良被打
	if slash and target and slash:isKindOf("NatureSlash") and not target:hasSkill("jueqing") and self.player:hasSkill("twyj_baimei") and self.player:isKongcheng() then return "." end

	if slash:isKindOf("NatureSlash") and self.player:isChained() and self:isGoodChainTarget(self.player, target, nil, nil, slash) then return "." end
	if self:isFriend(target) then
		if self:findLeijiTarget(self.player, 50, target) then return getJink() end
		if target:hasSkill("jieyin") and not self.player:isWounded() and self.player:isMale() and not self.player:hasSkills("leiji|nosleiji|olleiji|jieleiji") then return "." end
		if not target:hasSkill("jueqing") then
			if (target:hasSkill("nosrende") or (target:hasSkill("rende") and not target:hasUsed("RendeCard"))) and self.player:hasSkill("jieming") then return "." end
			if target:hasSkill("pojun") and not self.player:faceUp() then return "." end
			--add dmpkancolle
			if target:hasSkill("BurningLove") and slash:isKindOf("FireSlash") then return "." end
		end
	else
		if self:hasHeavySlashDamage(target, slash) then return getJink() end

		local current = self.room:getCurrent()
		if current and current:hasSkill("juece") and self.player:getHp() > 0 then
			local use = false
			for _, card in ipairs(self:getCards("Jink")) do
				if not self.player:isLastHandCard(card, true) then
					use = true
					break
				end
			end
			if not use then return not isdummy and "." end
		end
		if self.player:getHandcardNum() == 1 and self:needKongcheng() then return getJink() end
		if not self:hasLoseHandcardEffective() and not self.player:isKongcheng() then return getJink() end
		if target:hasSkill("mengjin") and not (target:hasSkill("nosqianxi") and target:distanceTo(self.player) == 1) then
			if self:doNotDiscard(self.player, "he", true) then return getJink() end
			if self.player:getCards("he"):length() == 1 and not self.player:getArmor() then return getJink() end
			if self.player:hasSkills("jijiu|qingnang") and self.player:getCards("he"):length() > 1 then return "." end
			if self:canUseJieyuanDecrease(target) then return "." end
			if (self:getCardsNum("Peach") > 0 or (self:getCardsNum("Analeptic") > 0 and self:isWeak()))
				and not self.player:hasSkills("tuntian+zaoxian") and not self:willSkipPlayPhase() then
				return "."
			end
		end
		if self.player:getHp() > 1 and getKnownCard(target, self.player, "Slash") >= 1 and getKnownCard(target, self.player, "Analeptic") >= 1 and self:getCardsNum("Jink") == 1
			and (target:getPhase() < sgs.Player_Play or self:slashIsAvailable(target) and target:canSlash(self.player)) then
			return "."
		end
		if not (target:hasSkill("nosqianxi") and target:distanceTo(self.player) == 1) then
			if target:hasWeapon("axe") then
				if target:hasSkills(sgs.lose_equip_skill) and target:getEquips():length() > 1 and target:getCards("he"):length() > 2 then return not isdummy and "." end
				if target:getHandcardNum() - target:getHp() > 2 and not self:isWeak() and not self:getOverflow() then return not isdummy and "." end
			elseif target:hasWeapon("blade") then
				
				local has_weak_chained_friend = false
				for _, friend in ipairs(self.friends_noself) do
					if friend:isChained() and self:isWeak(friend) then
						has_weak_chained_friend = true
					end
				end
				if has_weak_chained_friend and slash:isKindOf("NatureSlash") and self.player:isChained() then
					return getJink()
				end
				
				if slash:isKindOf("NatureSlash") and self.player:hasArmorEffect("vine")
					or self.player:hasArmorEffect("renwang_shield")
					or self:hasEightDiagramEffect()
					or self:hasHeavySlashDamage(target, slash)
					or (self.player:getHp() == 1 and #self.friends_noself == 0) then
				elseif (self:getCardsNum("Jink") <= getCardsNum("Slash", target, self.player) or self.player:hasSkill("qingnang")) and self.player:getHp() > 1
					or (self.player:hasSkill("jijiu") and getKnownCard(self.player, self.player, "red") > 0)
					or self:canUseJieyuanDecrease(target)
					then
					return not isdummy and "."
				end
			end
		end
	end
	return getJink()
end

sgs.ai_skill_cardask["@fatejuli-jink-2"] = function(self, data, pattern, target)
	local isdummy = type(data) == "number"
	local function getJink()
		if target and target:hasSkill("dahe") and self.player:hasFlag("dahe") then
			for _, card in ipairs(self:getCards("Jink")) do
				if card:getSuit() == sgs.Card_Heart then return card:getId() end
			end
			return "."
		end
		return self:getCardId("Jink") or not isdummy and "."
	end

	local slash
	if type(data) == "userdata" then
		local effect = data:toSlashEffect()
		slash = effect.slash
	else
		slash = sgs.Sanguosha:cloneCard("slash")
	end
	local cards = sgs.QList2Table(self.player:getHandcards())
	if (not target or self:isFriend(target)) and slash:hasFlag("nosjiefan-slash") then return "." end
	if sgs.ai_skill_cardask.nullfilter(self, data, pattern, target) then return "." end
	if not target then return getJink() end
	if not self:hasHeavySlashDamage(target, slash, self.player) and self:getDamagedEffects(self.player, target, slash) then return "." end
	
	--排除有大霧非雷殺出閃
	local shenzhugeliang = self.room:findPlayerBySkillName("dawu")
	if shenzhugeliang and not target:hasSkill("jueqing") and self.player:getMark("@fog") > 0 and slash and not slash:isKindOf("ThunderSlash") then return "." end
	--新神趙雲手中有酒或桃賣血摸牌
	if self.player:hasSkills("new_longhun+new_juejing") and not self:hasHeavySlashDamage(target, slash, self.player) then
		if self:getCardId("Peach") or self:getCardId("Analeptic") then
			return "."
		end
	end
	
	--已下可以注釋掉，因為sgs.ai_skill_cardask.nullfilter已經檢查元素傷害部分有沒有效。但預防萬一還是保留。
	--排除司馬徽隱士技能，AI司馬徽被打
	if slash and target and slash:isKindOf("NatureSlash") and not target:hasSkill("jueqing") and self.player:hasSkill("yinshi") and self.player:getMark("@dragon") + self.player:getMark("@phoenix") == 0 and not self.player:getArmor() then return "." end
	--排除TW馬良白眉，TW馬良被打
	if slash and target and slash:isKindOf("NatureSlash") and not target:hasSkill("jueqing") and self.player:hasSkill("twyj_baimei") and self.player:isKongcheng() then return "." end

	if slash:isKindOf("NatureSlash") and self.player:isChained() and self:isGoodChainTarget(self.player, target, nil, nil, slash) then return "." end
	if self:isFriend(target) then
		if self:findLeijiTarget(self.player, 50, target) then return getJink() end
		if target:hasSkill("jieyin") and not self.player:isWounded() and self.player:isMale() and not self.player:hasSkills("leiji|nosleiji|olleiji|jieleiji") then return "." end
		if not target:hasSkill("jueqing") then
			if (target:hasSkill("nosrende") or (target:hasSkill("rende") and not target:hasUsed("RendeCard"))) and self.player:hasSkill("jieming") then return "." end
			if target:hasSkill("pojun") and not self.player:faceUp() then return "." end
			--add dmpkancolle
			if target:hasSkill("BurningLove") and slash:isKindOf("FireSlash") then return "." end
		end
	else
		if self:hasHeavySlashDamage(target, slash) then return getJink() end

		local current = self.room:getCurrent()
		if current and current:hasSkill("juece") and self.player:getHp() > 0 then
			local use = false
			for _, card in ipairs(self:getCards("Jink")) do
				if not self.player:isLastHandCard(card, true) then
					use = true
					break
				end
			end
			if not use then return not isdummy and "." end
		end
		if self.player:getHandcardNum() == 1 and self:needKongcheng() then return getJink() end
		if not self:hasLoseHandcardEffective() and not self.player:isKongcheng() then return getJink() end
		if target:hasSkill("mengjin") and not (target:hasSkill("nosqianxi") and target:distanceTo(self.player) == 1) then
			if self:doNotDiscard(self.player, "he", true) then return getJink() end
			if self.player:getCards("he"):length() == 1 and not self.player:getArmor() then return getJink() end
			if self.player:hasSkills("jijiu|qingnang") and self.player:getCards("he"):length() > 1 then return "." end
			if self:canUseJieyuanDecrease(target) then return "." end
			if (self:getCardsNum("Peach") > 0 or (self:getCardsNum("Analeptic") > 0 and self:isWeak()))
				and not self.player:hasSkills("tuntian+zaoxian") and not self:willSkipPlayPhase() then
				return "."
			end
		end
		if self.player:getHp() > 1 and getKnownCard(target, self.player, "Slash") >= 1 and getKnownCard(target, self.player, "Analeptic") >= 1 and self:getCardsNum("Jink") == 1
			and (target:getPhase() < sgs.Player_Play or self:slashIsAvailable(target) and target:canSlash(self.player)) then
			return "."
		end
		if not (target:hasSkill("nosqianxi") and target:distanceTo(self.player) == 1) then
			if target:hasWeapon("axe") then
				if target:hasSkills(sgs.lose_equip_skill) and target:getEquips():length() > 1 and target:getCards("he"):length() > 2 then return not isdummy and "." end
				if target:getHandcardNum() - target:getHp() > 2 and not self:isWeak() and not self:getOverflow() then return not isdummy and "." end
			elseif target:hasWeapon("blade") then
				
				local has_weak_chained_friend = false
				for _, friend in ipairs(self.friends_noself) do
					if friend:isChained() and self:isWeak(friend) then
						has_weak_chained_friend = true
					end
				end
				if has_weak_chained_friend and slash:isKindOf("NatureSlash") and self.player:isChained() then
					return getJink()
				end
				
				if slash:isKindOf("NatureSlash") and self.player:hasArmorEffect("vine")
					or self.player:hasArmorEffect("renwang_shield")
					or self:hasEightDiagramEffect()
					or self:hasHeavySlashDamage(target, slash)
					or (self.player:getHp() == 1 and #self.friends_noself == 0) then
				elseif (self:getCardsNum("Jink") <= getCardsNum("Slash", target, self.player) or self.player:hasSkill("qingnang")) and self.player:getHp() > 1
					or (self.player:hasSkill("jijiu") and getKnownCard(self.player, self.player, "red") > 0)
					or self:canUseJieyuanDecrease(target)
					then
					return not isdummy and "."
				end
			end
		end
	end
	return getJink()
end

sgs.ai_skill_invoke.fateshilian = function(self, data)
 	return true
end


--Iriya：魔力
sgs.ai_skill_invoke.fatemoli = function(self, data)
	local baba = self.room:findPlayerBySkillName("fatejiezhi")
    if baba and self:isEnemy(baba) then
        return false
    else
		return true
	end
end

--暂时有bug
--Iriya:Loli
local fateloli_skill={}
fateloli_skill.name="fateloli_vs"
table.insert(sgs.ai_skills,fateloli_skill)
fateloli_skill.getTurnUseCard=function(self)
    if not self.player:hasUsed("#fateloli_card") then
		return sgs.Card_Parse("#fateloli_card:.:")
	end
end


sgs.ai_skill_use_func["#fateloli_card"]=function(card,use,self)
	self:sort(self.enemies, "hp") -- 按体力值从小到大排序
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isKongcheng() then
				use.card = sgs.Card_Parse("#fateloli_card:.:") -- 不包含任何子卡的技能卡
				if use.to then
					use.to:append(enemy)
				end
				return
			end
		end
end

sgs.ai_use_priority["#fateloli_card"] = 9.2
sgs.ai_card_intention["#fateloli_card"] = 50

sgs.ai_skill_askforag["fateloli_vs"] = function(self, card_ids)
	local target = self.room:getTag("fateloli"):toPlayer()
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
	if self:isEnemy(target) and target:hasSkill("tuntian") and card:getSuit() == sgs.Card_Heart then
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
			return valuable
		end
		if card:isKindOf("TrickCard") or card:isKindOf("Indulgence") or card:isKindOf("SupplyShortage") then
			local dummy_use = { isDummy = true }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				return valuable
			end
		end
		if card:isKindOf("Jink") and self:getCardsNum("Jink") == 0 then
			return valuable
		end
		if card:isKindOf("Nullification") and self:getCardsNum("Nullification") == 0 then
			return valuable
		end
		if card:isKindOf("Slash") and self:slashIsAvailable() then
			local dummy_use = { isDummy = true }
			self:useBasicCard(card, dummy_use)
			if dummy_use.card then
				return valuable
			end
		end
		return valuable
	end
--[[
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
		self.gongxinchoice = "put"
		return valuable
	end
	if nextAlive:hasSkill("yinghun") and nextAlive:isWounded() then
		self.gongxinchoice = self:isFriend(nextAlive) and "put" or "discard"
		return valuable
	end
	if target:hasSkill("hongyan") and hasLightning and self:isEnemy(nextAlive) and not (nextAlive:hasSkill("qiaobian") and nextAlive:getHandcardNum() > 0) then
		for _, id in ipairs(card_ids) do
			local card = sgs.Sanguosha:getEngineCard(id)
			if card:getSuit() == sgs.Card_Spade and card:getNumber() >= 2 and card:getNumber() <= 9 then
				self.gongxinchoice = "put"
				return id
			end
		end
	end
	if hasIndulgence and self:isFriend(nextAlive) then
		self.gongxinchoice = "put"
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
			self.gongxinchoice = "put"
			return valuable
		end
	end
]]
	if self:isFriend(nextAlive) and not self:willSkipDrawPhase(nextAlive) and not self:willSkipPlayPhase(nextAlive)
		and not nextAlive:hasSkill("luoshen")
		and not nextAlive:hasSkill("tuxi") and not (nextAlive:hasSkill("qiaobian") and nextAlive:getHandcardNum() > 0) then
		if (peach and valuable == peach) or (ex_nihilo and valuable == ex_nihilo) then
			return valuable
		end
		if jink and valuable == jink and getCardsNum("Jink", nextAlive) < 1 then
			return valuable
		end
		if nullification and valuable == nullification and getCardsNum("Nullification", nextAlive) < 1 then
			return valuable
		end
		if slash and valuable == slash and self:hasCrossbowEffect(nextAlive) then
			return valuable
		end
	end
	return valuable
end

sgs.ai_skill_discard["fateduoluo"] = function(self, discard_num, min_num, optional, include_equip)
	local current = self.room:getCurrent()
	local handcards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(handcards)
	local to_discard = {}
	for _,c in ipairs(handcards) do
		if not c:isKindOf("Peach")
		--and not c:isKindOf("Jink")
		and not c:isKindOf("Analeptic")
		then
			if #to_discard < min_num then
				table.insert(to_discard, c:getEffectiveId())
			end
		end
	end
	if #to_discard == min_num then
		return to_discard
	end
	return {}
end

--燕返 你可以将草花牌当【闪】使用或打出；将方片牌当【杀】使用或打出。
sgs.ai_view_as.fateyanfan_vs = function(card, player, card_place)
    local suit = card:getSuitString()
    local number = card:getNumberString()
    local card_id = card:getEffectiveId()
    if card:getSuit()== sgs.Card_Diamond and not card:isKindOf("Peach") then
        return ("slash:fateyanfan_vs[%s:%s]=%d"):format(suit, number, card_id)
    end
	if card:getSuit()== sgs.Card_Club then
        return ("jink:fateyanfan_vs[%s:%s]=%d"):format(suit, number, card_id)
    end
end

local fateyanfan_vs_skill={}
fateyanfan_vs_skill.name="fateyanfan_vs"
table.insert(sgs.ai_skills,fateyanfan_vs_skill)
fateyanfan_vs_skill.getTurnUseCard=function(self,inclusive)
    local cards = self.player:getCards("he")
    cards=sgs.QList2Table(cards)
    
    local diamond_card
    
    self:sortByUseValue(cards,true)
    
    for _,card in ipairs(cards) do
        if card:getSuit()== sgs.Card_Diamond and not card:isKindOf("Slash") and not card:isKindOf("Peach") 				--not peach
            and ((self:getUseValue(card)<sgs.ai_use_value.Slash) or inclusive) then
            diamond_card = card
            break
        end
    end

    if diamond_card then		
        local suit = diamond_card:getSuitString()
        local number = diamond_card:getNumberString()
        local card_id = diamond_card:getEffectiveId()
        local card_str = ("slash:fateyanfan_vs[%s:%s]=%d"):format(suit, number, card_id)
        local slash = sgs.Card_Parse(card_str)
        
        assert(slash)
        
        return slash
    end
end

sgs.Kojirou_suit_value = 
{
    diamond = 3.9,
    club = 4.8
}

--Carene 圣骸
sgs.ai_skill_invoke.fateshenghai = function(self, data)
	return true
end


fateshenghai_damageeffect = function(self, to, nature, from)
	if to:hasSkill("fateshenghai") and to:getMark("@fateshenghai") > 0 then return false end
	return true
end
table.insert(sgs.ai_damage_effect, fateshenghai_damageeffect)

--Kirei 黑键 你可以在出牌阶段将一张黑色手牌（每回合限一次）或其他角色死亡时弃掉的黑色牌置于你的武将牌上，称为【键】。你每拥有一张【键】，手牌上限便+1。
--你受到伤害时，可以弃掉一张【键】使伤害-1；造成伤害时，可以弃掉一张【键】使伤害+1。你最多只能同时拥有五张【键】。

local fateheijian_skill={}
fateheijian_skill.name="fateheijian"
table.insert(sgs.ai_skills,fateheijian_skill)
fateheijian_skill.getTurnUseCard=function(self)
	if not self.player:hasUsed("#fateheijian_card") and not self.player:isKongcheng() and (self.player:getPile("fateheijiancards")):length() < 5 then
	    local cards = self.player:getCards("h")
	    cards = sgs.QList2Table(cards)
	    self:sortByKeepValue(cards)
	    for _, c in ipairs(cards) do
			if c:isBlack() and not (c:isKindOf("Nullification") and self:getCardsNum("Nullification") == 1 and self.player:getHp() > 1) then 
	    		return sgs.Card_Parse("#fateheijian_card:" .. c:getEffectiveId()..":") 
	    	end
	    end
	end
end

sgs.ai_skill_use_func["#fateheijian_card"]=function(card,use,self)
	use.card=card
	if use.to then
		use.to:append(self.player)
	end
end

sgs.ai_skill_invoke["fateheijianDamage"] = function(self, data)
	--不能发动时不发动
	local damage = data:toDamage()
	if self:isFriend(damage.to) then return false end--对队友不发动
	if damage.to:getHp()<3 then return true end--对2血或2血以下的敌人发动
	if self.player:getHp() == 1 then return false end--1血时不发动
--[[	local i=0
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	for _, c in ipairs(cards) do
	    if c:isBlack() then
			i=i+1
		end
	end]]
	if ((self.player:getPile("fateheijiancards")):length() < 2)  and (self:getCardsNum("Jink") == 0) then --and (i==0) then--否则只有一张键且手牌无闪时，不发动
		return false
	end
	return true	
end

sgs.ai_skill_invoke["fateheijianDefense"] = function(self, data)
	if self:getCardsNum("Peach") < 2 then --有两个或以上的桃
		return true
	end		
end

sgs.ai_skill_invoke["fateheijianJianpai"] = function(self, data)
	return true		
end

sgs.Kirei_suit_value = 
{
	spade = 2.7,
	club = 2.7
}

--Lancelot
--sgs.ai_skill_invoke["fatefanji"] = function(self, data)
sgs.ai_skill_invoke["fatefanji"] = function(self, data, pattern, target)
--[[	local target = data:toResponsed().m_who
	if self:getCardsNum("Slash") >0 and not self:isFriend(target) then --有杀且不是队友
		return true
	end	
	
	local target = data:toPlayer()
	if self:isFriend(target) then
		return false
	end
	]]	
	if self:getCardsNum("Slash") == 0 then --没杀
		return false
	end
	local cur = self.room:getCurrent() --这句已测试，没有问题
	--local target = data:toPlayer()
--	local target = data:toResponsed().m_who
	--if target then return true end               self:isFriend(next_player)
	if self:isFriend(cur) then return false end
	return true
end

local fatefanshi_skill={}
fatefanshi_skill.name="fatefanshi"
table.insert(sgs.ai_skills,fatefanshi_skill)
fatefanshi_skill.getTurnUseCard=function(self)
    if not self.player:hasUsed("#fatefanshi_card") then
		return sgs.Card_Parse("#fatefanshi_card:.:")
	end
end

sgs.ai_skill_use_func["#fatefanshi_card"]=function(card,use,self)
	self:sort(self.enemies, "hp") -- 按体力值从小到大排序
		for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 3 and self.player:distanceTo(enemy) <= self.player:getAttackRange() then
				use.card = sgs.Card_Parse("#fatefanshi_card:.:") -- 不包含任何子卡的技能卡
				if use.to then
					use.to:append(enemy)
				end
				return
			end
		end
end

sgs.ai_use_priority["#fatefanshi_card"] = 2.2
sgs.ai_card_intention["#fatefanshi_card"] = 100


local fatexinyin_skill={}
fatexinyin_skill.name="fatexinyin"
table.insert(sgs.ai_skills,fatexinyin_skill)
fatexinyin_skill.getTurnUseCard=function(self)
    if not self.player:hasUsed("#fatexinyin_card") then
		return sgs.Card_Parse("#fatexinyin_card:.:")
	end
end

sgs.ai_skill_use_func["#fatexinyin_card"]=function(card,use,self)
	self:sort(self.enemies, "hp") -- 按体力值从小到大排序
		for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 3 and self.player:distanceTo(enemy) <= 1 then
				use.card = sgs.Card_Parse("#fatexinyin_card:.:") -- 不包含任何子卡的技能卡
				if use.to then
					use.to:append(enemy)
				end
				return
			end
		end
end

sgs.ai_use_priority["#fatexinyi_card"] = 7
sgs.ai_card_intention["#fatexinyi_card"] = 80

sgs.ai_skill_choice.fatexinyin_card=function(self,choices)
	return "xychoice1"
end

--Rin 远坂凛
sgs.ai_skill_invoke["fateqingxing"] = function(self, data)
	--对自己，如果有判定或损血就发动
	--对队友，如果血量小于3或损血且闪+红桃>2可以发动
	--不能发动时不发动
	local cards = self.player:getCards("he")
	local i=0
	cards = sgs.QList2Table(cards)
	for _, c in ipairs(cards) do
		if c:getSuit()==sgs.Card_Heart or c:isKindOf("Jink")then 
	    		i=i+1
	    end
	end
	if i==0 then return false end
	local player = self.room:getCurrent()
	if not self:isFriend(player) then return false end
	local judges = player:getJudgingArea() --返回 QList<const Card *>
	if player:hasSkill("fateqingxing") then 
		if player:isWounded() and player:getMark("@fatebimie")==0 then
			return true
		end
		if not judges:isEmpty() then
			if self:hasWizard(self.enemies) then return true end --如果敌人有神棍，直接发动
			for _,cd in sgs.qlist(judges) do
				if not cd:isKindOf("Lightning") then return true end --"Lightning"其实应改为“天灾”
			end
		else 
			return false --有且只有闪电
		end
	end
	if (player:getHp() < 2 and player:isWounded()) and player:getMark("@fatebimie")==0 then return true end
	local cards = self.player:getCards("he")
    cards=sgs.QList2Table(cards)
    local card
	local i=0
    self:sortByUseValue(cards,true)
    for _,acard in ipairs(cards)  do
        if (acard:getSuit() == sgs.Card_Heart) then 
			i=i+1
		end
    end
	if (player:getHp() < 3 and player:isWounded() and (self:getCardsNum("Jink")+ i> 1)) then return true end
	return false
end

sgs.ai_skill_cardask["@fateqingxing1"] = function(self, data, pattern, target)
	local cards = self.player:getCards("he")
	local i=0
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	local heart = {}
	for _, c in ipairs(cards) do
		if c:getSuit()==sgs.Card_Heart or c:isKindOf("Jink")then 
	    		i=i+1
				table.insert(heart, c:getEffectiveId())
	    end
	end
	if i==0 then return "." end
	local player = self.room:getCurrent()
	if not self:isFriend(player) then return "." end
	local judges = player:getJudgingArea() --返回 QList<const Card *>
	if player:hasSkill("fateqingxing") then 
		if player:isWounded() and player:getMark("@fatebimie")==0 then
			return "$" .. heart[1]
		end
		if not judges:isEmpty() then
			if self:hasWizard(self.enemies) then return "$" .. heart[1] end --如果敌人有神棍，直接发动
			for _,cd in sgs.qlist(judges) do
				if not cd:isKindOf("Lightning") then return "$" .. heart[1] end --"Lightning"其实应改为“天灾”
			end
		else 
			return "." --有且只有闪电
		end
	end
	if (self:isWeak(player) and player:isWounded()) and player:getMark("@fatebimie")==0 then return  "$" .. heart[1] end
	local cards = self.player:getCards("he")
    cards=sgs.QList2Table(cards)
    local card
	local i=0
    self:sortByUseValue(cards,true)
    for _,acard in ipairs(cards)  do
        if (acard:getSuit() == sgs.Card_Heart) then 
			i=i+1
		end
    end
	if self:needToThrowArmor() and self.player:getArmor():getSuit() == sgs.Card_Heart then
		return "$" .. self.player:getArmor() 
	end
	if ((not judges:isEmpty() or  player:getHp() < getBestHp(player)) and (self:getCardsNum("Jink")+ i> 1)) then return  "$" .. heart[1] end
	return "."
end


sgs.Rin_suit_value = 
{
	heart = 6
}

sgs.Rin_keep_value = 
{
    Jink = 6.5
}

local fatebumo_skill={}
fatebumo_skill.name="fatebumo"
table.insert(sgs.ai_skills,fatebumo_skill)
fatebumo_skill.getTurnUseCard=function(self)
    if (self.player:getMark("@bumo_mark")>0) and (self.player:isWounded() or self.player:getHandcardNum() < self.player:getMaxHp()) then
    	return sgs.Card_Parse("#fatebumo_card:.:")
	end
end

sgs.ai_skill_use_func["#fatebumo_card"]=function(card,use,self)
    self:sort(self.friends_noself, "hp")
    local lord = self.room:getLord()
    if self:isFriend(lord) and not sgs.isLordHealthy()  and lord:isMale() and lord:isWounded() then
        use.card=card
        if use.to then use.to:append(lord) end
        return
    end
    for _, friend in ipairs(self.friends_noself) do
        if friend:getGender()~=self.player:getGender() and self:isWeak(friend) and (friend:getSeat() - self.player:getSeat()) % (global_room:alivePlayerCount()) < 3 then 
            use.card=card
            if use.to then use.to:append(friend) end
            return
        end
    end
end

--Sakura 间桐樱

local fatechuyi_vs_skill={}
fatechuyi_vs_skill.name="fatechuyi_vs"
table.insert(sgs.ai_skills,fatechuyi_vs_skill)
fatechuyi_vs_skill.getTurnUseCard=function(self)
    if self.player:getHandcardNum()<2 then return nil end
    if self.player:hasUsed("#fatechuyi_card") then return nil end
    
    local cards = self.player:getHandcards()
    cards=sgs.QList2Table(cards)
    
    local first, second
    self:sortByUseValue(cards,true)
    for _, card in ipairs(cards) do
        if card:getTypeId() ~= sgs.Card_Equip then
            if not first then first  = cards[1]:getEffectiveId()
            else second = cards[2]:getEffectiveId()
            end
        end
        if second then break end
    end
    
    if not second then return end
    local card_str = ("#fatechuyi_card:%d+%d:"):format(first, second)
    assert(card_str)
    return sgs.Card_Parse(card_str)
end

sgs.ai_skill_use_func["#fatechuyi_card"]=function(card,use,self)
    self:sort(self.friends_noself, "defense")
    local lord = self.room:getLord()
    if self:isFriend(lord) and not sgs.isLordHealthy() and lord:isWounded() then
        use.card=card
        if use.to then use.to:append(lord) end
        return
    end	
    for _, friend in ipairs(self.friends_noself) do
        if friend:isWounded() and
            not (friend:hasSkill("longhun") and self:getAllPeachNum() > 0) and
            not (friend:hasSkill("hunzi") and friend:getMark("hunzi") == 0 and self:getAllPeachNum() > 1) then
            use.card=card
            if use.to then use.to:append(friend) end
            return
        end
    end
	if self:getOverflow()>0 then --无人受伤且需弃牌时时选择手牌最少的那个
		self:sort(self.friends_noself, "handcard")
		for _, friend in ipairs(self.friends_noself) do 
      		if not (friend:hasSkill("kongcheng") and friend:isKongcheng()) then
        	    use.card=card
        	    if use.to then use.to:append(friend) end
        	    return
        	end
    	end
	end
end

sgs.ai_use_priority.fatechuyi_card = 4.2
sgs.ai_card_intention.fatechuyi_card = -200
sgs.dynamic_value.benefit.fatechuyi_card = true

sgs.ai_skill_invoke["fatexinengloseHP"] = function(self, data)
	local next_player = self.player:getNextAlive()
	if not self:isFriend(next_player) then return true end 
	return false
end


--Medea
--vs部分，除了桃和无中之外都可以return，是否使用在后面判断

local fateyaoshu_skill={}
fateyaoshu_skill.name="fateyaoshu"
table.insert(sgs.ai_skills,fateyaoshu_skill)
fateyaoshu_skill.getTurnUseCard=function(self)
	local first_found, second_found = false, false
	local first_card, second_card
	if self.player:getHandcardNum() >= 2 then
		local cards = self.player:getHandcards()
		local same_suit=false
		cards = sgs.QList2Table(cards)
	--[[	local jinknum=0
		for _, card in ipairs(cards) do
			if card:isKindOf("Jink") then
				jinknum = jinknum+1
			end
		end]]
		for _, fcard in ipairs(cards) do
			if not (fcard:isKindOf("Peach") or fcard:isKindOf("ExNihilo")) then
				first_card = fcard
				first_found = true
				for _, scard in ipairs(cards) do
					--[[local jinksin2=0
					local jinktag=true
					if fcard:isKindOf("Jink") then 
						jinksin2 = 1
						if scard:isKindOf("Jink") then 
							jinksin2 = 2
						end
					elseif scard:isKindOf("Jink") then
						jinksin2 = 1
					else jinksin2 = 0
					end
					如果不是1血且发动后就没闪了，则不发动
					--if jinksin2 == self.player:getCardsNum("Jink") then 这句会有问题，看来不能这么调用
					if jinksin2 > 0 and jinksin2 == jinknum then --and jinksin2~=0 and self.player:getHp() >1 then
						jinktag = false
					else jinktag = true
					end]]
					if first_card ~= scard and scard:getSuitString() == first_card:getSuitString() and 
						not (scard:isKindOf("Peach") or scard:isKindOf("ExNihilo")) then -- and 
						--jinktag then
						second_card = scard
						second_found = true
						break
					end
				end
				if second_card then break end
			end
		end
	end

	if first_found and second_found then
		local first_suit, first_id = first_card:getSuit(), first_card:getEffectiveId()
		local second_suit, second_id = second_card:getSuit(), second_card:getEffectiveId()
		local card_str
		if first_suit == sgs.Card_Diamond then 
			card_str = ("#fateyaoshu3:%d+%d:"):format(first_id, second_id)
		elseif first_suit == sgs.Card_Spade then 
			card_str = ("#fateyaoshu2:%d+%d:"):format(first_id, second_id)
		elseif first_suit == sgs.Card_Heart then 
			card_str = ("#fateyaoshu1:%d+%d:"):format(first_id, second_id)
		elseif first_suit == sgs.Card_Club  then 
			card_str = ("#fateyaoshu4:%d+%d:"):format(first_id, second_id)
		end
		assert(card_str)
    	return sgs.Card_Parse(card_str)
	end
end

sgs.ai_skill_use_func["#fateyaoshu1"]=function(card,use,self)
	--[[use.card=card
	if use.to then
		if self.player:isWounded() then 
			use.to:append(self.player)
			return 
		end
	end
	if not self.player:isWounded() then return end
	use.card=card
	if use.to then
		use.to:append(self.player)
	end
	return]]
	if self.player:isWounded() then 
        use.card=card
        if use.to then use.to:append(self.player) end
    end
end

sgs.ai_skill_use_func["#fateyaoshu2"]=function(card,use,self)
	self:sort(self.enemies, "chaofeng") -- 按嘲讽值从大到小排序
		for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 3 and enemy:faceUp() then
				use.card = card -- 技能卡
				if use.to then
					use.to:append(enemy)
				end
				return
			end
		end
		for _, friend in ipairs(self.friends) do
        	if not friend:faceUp() then
				use.card = card -- 技能卡
				if use.to then
					use.to:append(friend)
				end
				return
			end
        end
end

--暂时只能对自己使用
sgs.ai_skill_use_func["#fateyaoshu3"]=function(card,use,self)
	use.card=card
	if use.to then
		use.to:append(self.player)
	end
end


sgs.ai_skill_use_func["#fateyaoshu4"]=function(card,use,self)
	self:sort(self.enemies, "hp") -- 按体力值从小到大排序
		for _, enemy in ipairs(self.enemies) do
			if self:getOverflow()<1 and enemy:getHp()>1 then return end --如果不需要弃牌，则只在补刀时发动
			if self:objectiveLevel(enemy) > 3 then
				use.card = card -- 技能卡
				if use.to then
					use.to:append(enemy)
				end
				return
			end
		end
end

sgs.ai_use_priority.fateyaoshucard1 = 3.2
sgs.ai_use_priority.fateyaoshucard2 = 10.2
sgs.ai_use_priority.fateyaoshucard3 = 3.1
sgs.ai_use_priority.fateyaoshucard4 = 3.0
sgs.ai_card_intention.fateyaoshucard1 = -150
sgs.ai_card_intention.fateyaoshucard3 = 70

fatefapao_damageeffect = function(self, to, nature, from)
	if to:hasSkill("fatefapao") and nature ~= sgs.DamageStruct_Normal then return false end
	return true
end
table.insert(sgs.ai_damage_effect, fatefapao_damageeffect)


--Gilgamesh 吉尔伽美什
local fateluanshe_vs_skill={}
fateluanshe_vs_skill.name="fateluanshe_vs"
table.insert(sgs.ai_skills,fateluanshe_vs_skill)
fateluanshe_vs_skill.getTurnUseCard=function(self,inclusive)
	if self.player:usedTimes("ArcheryAttack")>0 then return nil end
    local cards = self.player:getCards("h")
    cards=sgs.QList2Table(cards)
    local heart_card
    self:sortByUseValue(cards,true)
    for _,card in ipairs(cards) do
        if card:getSuit()== sgs.Card_Heart then
            heart_card = card
            break
        end
    end
	if heart_card then	
        local suit = heart_card:getSuitString()
        local number = heart_card:getNumberString()
        local card_id = heart_card:getEffectiveId()
        local card_str = ("archery_attack:fateluanshe_vs[%s:%s]=%d"):format(suit, number, card_id)
        local aa = sgs.Card_Parse(card_str)
        assert(aa)
        return aa
    end
end
--[[
sgs.ai_skill_playerchosen["@fatechuanxin2"] = function(self, targets)
	self:sort(self.enemies, "hp") -- 按体力值从小到大排序
	for _, enemy in ipairs(self.enemies) do
		if self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and enemy:getMark("@fog") < 1 and enemy:getMark("@fateshenghai") < 1
		and enemy:getMark("@fatesakura_mark") < 1 and not (enemy:hasSkill("yiji") or enemy:hasSkill("jieming") or enemy:hasSkill("fangzhu") or enemy:hasSkill("guixin") or enemy:hasSkill("fatewangzhe"))
	then
			return enemy
		end
	end
	for _, enemy in ipairs(self.enemies) do
		if self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and enemy:getMark("@fog") < 1 and enemy:getMark("@fateshenghai") < 1
		and enemy:getMark("@fatesakura_mark") < 1
		then
			return enemy
		end
	end
end
]]
sgs.ai_skill_playerchosen["@fatechuanxin2"] = sgs.ai_skill_playerchosen.zero_card_as_slash
sgs.Gilgamesh_suit_value = 
{
	heart = 7
}

sgs.Gilgamesh_use_value = 
{
	ArcheryAttack = 10
}

--Rider Medusa 
--若【杀】多于1，直接天义
--否则若有武器且距离内有敌人/或距离内有濒死敌人且自己2血以上，选择强袭
--否则若手牌中黑牌数大于等于2，选择奇袭
--否则若有一张杀，选择天义
--否则必无杀，若攻击范围内有敌人，选择武圣
--否则若有黑牌选择奇袭
--否则选择天义

sgs.ai_skill_invoke.fateguangbo = function(self, data)
	return true
end

sgs.ai_skill_choice.fateguangbo=function(self,choices)
	if self:getCardsNum("Slash") > 1 then return "fateguangbo3" end
	local hasweapon = false
	local weapon = self.player:getWeapon()
	
	if weapon then 
		hasweapon = true
	else 
		local cards = self.player:getHandcards()
		for _, card in sgs.qlist(cards) do
			if card:isKindOf("Weapon") then
				hasweapon = true
				break
			end
		end
	end
	for _, enemy in ipairs(self.enemies) do
		if self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and enemy:getMark("@fog") < 1 and enemy:getMark("@fateshenghai") < 1
		and enemy:getMark("@fatesakura_mark") < 1 then
			if (hasweapon or (enemy:getHp()==1 and self:getHp()>2)) and self.player:distanceTo(enemy) <=1 then
				return "fateguangbo2"
			end
		end
	end
	
	local cards = self.player:getCards("h")
	local blacknum = 0
	for _, card in sgs.qlist(cards) do
		if card:isBlack() then
			blacknum = blacknum + 1
		end
	end
	if blacknum > 1 then return "fateguangbo4" end
	
	if self:getCardsNum("Slash") > 0 then return "fateguangbo3" end
	
	for _, enemy in ipairs(self.enemies) do
		if self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and enemy:getMark("@fog") < 1 and enemy:getMark("@fateshenghai") < 1
		and enemy:getMark("@fatesakura_mark") < 1 then
			if self.player:distanceTo(enemy) <= self.player:getAttackRange() then
					return "fateguangbo5"
			end
		end
	end
	
	local cards = self.player:getCards("he")
	for _, card in sgs.qlist(cards) do
		if card:isBlack() then
			return "fateguangbo4"
		end
	end
	return "fateguangbo3"
end

--直接在首轮发动，简单省事~~~~~~~~~~~~~~~~~~~~~~~~~
sgs.ai_skill_invoke.fatetuji = function(self, data)
	return self:isWeak() or sgs.turncount > 1
end

--Irisviel fateshengqi
--[[sgs.ai_skill_cardask["fateshengqi"]=function(self, data)
	local judge = data:toJudge()
	local all_cards = self.player:getCards("he")
	if all_cards:isEmpty() then return "." end
	local cards = {}
	for _, card in sgs.qlist(all_cards) do
		if card:isRed() then
			table.insert(cards, card)
		end
	end

	if #cards == 0 then return "." end
	local card_id = self:getRetrialCardId(cards, judge)
	if card_id == -1 then
		if self:needRetrial(judge) then
			self:sortByUseValue(cards, true)
			if self:getUseValue(judge.card) > self:getUseValue(cards[1]) then
				return "@GuidaoCard[" .. cards[1]:getSuitString() .. ":" .. cards[1]:getNumberString() .."]=" .. cards[1]:getId()
			end
		end
	elseif self:needRetrial(judge) or self:getUseValue(judge.card) > self:getUseValue(sgs.Sanguosha:getCard(card_id)) then
		local card = sgs.Sanguosha:getCard(card_id)
		return "@GuidaoCard[" .. card:getSuitString() .. ":" .. card:getNumberString() .. "]=" .. card_id
	end
	
	return "."
end]]

sgs.ai_skill_cardask["@fateshengqi-card"]=function(self, data)
	local judge = data:toJudge()
	local all_cards = self.player:getCards("he")
	
	if self.player:getPile("wooden_ox"):length() > 0 then
		for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
			all_cards:prepend(sgs.Sanguosha:getCard(id))
		end
	end
	
	if all_cards:isEmpty() then return "." end

	local cards = {}
	for _, card in sgs.qlist(all_cards) do
		if card:isRed() and not card:hasFlag("using") then
			table.insert(cards, card)
		end
	end

	if #cards == 0 then return "." end

	local card_id = self:getRetrialCardId(cards, judge)
	if card_id == -1 then
		if self:needRetrial(judge) and judge.reason ~= "beige" then
			if self:needToThrowArmor() and self.player:getArmor():isRed() then return "$" .. self.player:getArmor():getEffectiveId() end
			self:sortByUseValue(cards, true)
			if self:getUseValue(judge.card) > self:getUseValue(cards[1]) then
				return "$" .. cards[1]:getId()
			end
		end
	elseif self:needRetrial(judge) or self:getUseValue(judge.card) > self:getUseValue(sgs.Sanguosha:getCard(card_id)) then
		local card = sgs.Sanguosha:getCard(card_id)
		return "$" .. card_id
	end

	return "."
end


sgs.ai_skill_invoke["fatehuyoubad"] = function(self, data)
--有判定牌时，对友方的拆顺不发动;或处于横置状态时，对铁索不发动
--	local effect = data:toCardEffect()
	--local from=data:toCardEffect().from
--	local card = effect.card
--	local cur = self.room:getCurrent() --这句已测试，没有问题
--	local judges = self:getJudgingArea() --返回 QList<const Card *>
	--if self:isFriend(cur) and ((effect.card:isKindOf("Snatch") or effect.card:isKindOf("Dismantlement")) and judges:isEmpty()==false) then return false end
--	if self:isFriend(cur) and (effect.card:isKindOf("Snatch") or effect.card:isKindOf("Dismantlement")) then return false end
--	if not judges:isEmpty() then return false end
--	if self:isChained() and effect.card:isKindOf("IronChain") then return false end
--	if self:isFriend(cur) then return true end
--	if (card:isKindOf("Snatch") or card:isKindOf("Dismantlement")) then return true end --这句有错！
	return true
end

sgs.ai_skill_playerchosen["#fatehuyoubad_target"] = function(self, targets) 
	local choices = {}
	for _, target in sgs.qlist(targets) do
		if self:isEnemy(target) then-- and (self.player:distanceTo(target) <= self.player:getAttackRange()) then
			table.insert(choices, target)
		end
	end
	if #choices == 0 then
		for _, target in sgs.qlist(targets) do
			if not self:isFriend(target) then
				table.insert(choices, target)
			end
		end
		self:sort(choices, "hp", true) --不加这句，会直接给主公(targets:at(0))
		return choices[1] --targets:at(0)
	end
	self:sort(choices, "hp")
	return choices[1]
end

sgs.ai_skill_invoke["fatehuyougood"] = function(self, data)
	for _, friend in ipairs(self.friends_noself) do  --卧槽，这里用isWounded()居然不行，mlgb
        if friend:getLostHp() > 0 and self.player:getLostHp()==0 then -- and (self.player:distanceTo(friend) <= self.player:getAttackRange()) 
            return true
        end
    end
	return false
end

sgs.ai_skill_playerchosen["#fatehuyougood_target"] = function(self, targets)
	local choices = {}
	for _, target in sgs.qlist(targets) do
		if self:isFriend(target) then
			table.insert(choices, target)
		end
	end
	self:sort(choices, "hp")
	return choices[1]
end

sgs.ai_skill_playerchosen["fatehuyou"] = function(self, targets) 
	local targets = sgs.QList2Table(targets)
	local effect = self.room:getTag("fatehuyou"):toCardEffect()
	local card = effect.card
	local target
	if card:isKindOf("AmazingGrace") or card:isKindOf("ExNihilo") or card:isKindOf("EXCard_YJJG") then
		for _, friend in ipairs(self.friends) do
			if friend:hasSkills(sgs.cardneed_skill) and not self:needKongcheng(friend, true) and not hasManjuanEffect(friend) and self:hasTrickEffective(card, effect.from, friend) 
			and self.player:getHandcardNum() > 	friend:getHandcardNum()	and table.contains(targets, friend)	then
				return friend
			end
		end
		return nil
	elseif  card:isKindOf("EXCard_TJBZ") then
		return nil
	elseif card:isKindOf("EXCard_YYDL")  then
		for _, friend in ipairs(self.friends) do
			if (self:hasSkills(sgs.lose_equip_skill, friend) or self:needToThrowArmor(friend)) and not hasManjuanEffect(friend) and self:hasTrickEffective(card, effect.from, friend) and table.contains(targets, friend) 	then
				return friend
			end
		end
		return nil
	elseif card:isKindOf("GodSalvation") then
		local lord = self.room:getLord()
		if self:isWeak(lord) and self.player:getRole() == "loyalist" and self:hasTrickEffective(card, effect.from, lord)  and table.contains(targets, lord) then
			return lord
		end
		self:sort(self.friends, "hp")
		if self:isWeak() and self:hasTrickEffective(card, effect.from, self.player)  then
			return nil
		else
			for _, target in sgs.qlist(self.friends) do
				if self:hasTrickEffective(card, effect.from, target) and target:getHp() < getBestHp(target)   and table.contains(targets, target) then
					return target
				end
			end
		end
		return nil
	elseif  card:isKindOf("Duel") or card:isKindOf("FireAttack") or card:isKindOf("EXCard_WWJZ") then
		local nature = sgs.DamageStruct_Normal
		if card:isKindOf("FireAttack") then
			nature = sgs.DamageStruct_Fire
		end
		self:sort(self.enemies, "hp")
		self:sort(self.friends, "hp")
		for _, enemy in ipairs(self.enemies) do
			if not enemy:hasSkills(sgs.masochism_skill) and self:hasTrickEffective(card, effect.from, enemy) and not self:cantbeHurt(enemy) and self:damageIsEffective(enemy, nature) and  table.contains(targets, enemy)	then
				return enemy
			end
		end
		for _, enemy in ipairs(self.enemies) do
			if not enemy:hasSkills(sgs.masochism_skill) and self:hasTrickEffective(card, effect.from, enemy) and not self:cantbeHurt(enemy) and  table.contains(targets, enemy)	then
				return enemy
			end
		end
		for _, friend in ipairs(self.friends) do
			if ((friend:hasSkills(sgs.masochism_skill) or self:needToLoseHp(friend, effect.from, false)) and not self:isWeak(friend)) or not self:hasTrickEffective(card, effect.from, friend) or not self:damageIsEffective(friend, nature)  and  table.contains(targets, friend) then
				return friend
			end
		end
		return targets[1]
	elseif  card:isKindOf("ArcheryAttack") or card:isKindOf("SavageAssault") then
		local nature = sgs.DamageStruct_Normal
		if card:isKindOf("FireAttack") then
			nature = sgs.DamageStruct_Fire
		end
		self:sort(self.enemies, "hp")
		self:sort(self.friends, "hp")
		for _, enemy in ipairs(self.enemies) do
			if not enemy:hasSkills(sgs.masochism_skill) and self:hasTrickEffective(card, effect.from, enemy) and not self:cantbeHurt(enemy) and self:damageIsEffective(enemy, nature) and not enemy:hasArmorEffect("vine") and  table.contains(targets, enemy) 	then
				return enemy
			end
		end
		for _, enemy in ipairs(self.enemies) do
			if not enemy:hasSkills(sgs.masochism_skill) and self:hasTrickEffective(card, effect.from, enemy) and not self:cantbeHurt(enemy)  and not enemy:hasArmorEffect("vine")	and  table.contains(targets, enemy) then
				return enemy
			end
		end
		for _, friend in ipairs(self.friends) do
			if (((friend:hasSkills(sgs.masochism_skill) or self:needToLoseHp(friend, effect.from, false)) and not self:isWeak(friend)) or not self:hasTrickEffective(card, effect.from, friend) or not self:damageIsEffective(friend, nature) or  friend:hasArmorEffect("vine")) and  table.contains(targets, friend) then
				return friend
			end
		end
		return targets[1]
	elseif card:isKindOf("Collateral") then
		self:sort(self.enemies, "handcard")
		for _, enemy in ipairs(self.enemies) do
			if not (self:hasSkills(sgs.lose_equip_skill, enemy) and enemy:getWeapon()) and self:hasTrickEffective(card, effect.from, enemy) and  table.contains(targets, enemy)	then
				return enemy
			end
		end
	elseif card:isKindOf("Dismantlement")  or card:isKindOf("Snatch") then
		if self:isFriend(effect.from) and (self.player:getJudgingArea():length() > 0 or self:hasSkills(sgs.lose_equip_skill, self.player)) and self:hasTrickEffective(card, effect.from, self.player) then
			return nil
		end
			if card:isKindOf("Dismantlement") then
				self:sort(self.enemies, "handcard")
				for _, enemy in ipairs(self.enemies) do
					if not self:doNotDiscard(enemy) and self:hasTrickEffective(card, effect.from, enemy) and  table.contains(targets, enemy)	then
						return enemy
					end
				end
				for _, enemy in ipairs(self.enemies) do
					if  self:hasTrickEffective(card, effect.from, enemy) and  table.contains(targets, enemy)	then
						return enemy
					end
				end
			end
	elseif card:isKindOf("GodFlower") or card:isKindOf("Snatch") then
		self:sort(self.enemies, "handcard")
		for _, enemy in ipairs(self.enemies) do
			if self:isEnemy(effect.from) and self:hasTrickEffective(card, effect.from, enemy) and (enemy:getJudgingArea():length() < 1 or not self:hasSkills(sgs.lose_equip_skill, enemy)) and  table.contains(targets, enemy)	then
				return enemy
			end
		end
	elseif card:isKindOf("IronChain") then
		for _, friend in ipairs(self.friends) do
			if self:hasTrickEffective(card, effect.from, friend) and friend:isChained()  and  table.contains(targets, friend) then
				return friend
			end
		end
		
		for _, enemy in ipairs(self.enemies) do
			if  self:hasTrickEffective(card, effect.from, enemy)  and  table.contains(targets, enemy) and not enemy:isChained()	then
				return enemy
			end
		end
	end
	
	return nil
end

sgs.Irisviel_suit_value = 
{
	heart = 3.9,
	diamond = 3.8
}

--Tokiomi
--[[
sgs.ai_skill_invoke.fatejiejie = function(self, data)
	return true
end
]]
sgs.ai_skill_invoke.fatejiejie = function(self, data)
	local dying = 0
	local handang = self.room:findPlayerBySkillName("nosjiefan")
	for _, aplayer in sgs.qlist(self.room:getAlivePlayers()) do
		if aplayer:getHp() < 1 and not aplayer:hasSkill("nosbuqu") then dying = 1 break end
	end
	if handang and self:isFriend(handang) and dying > 0 then return false end

	
	--隊友要鐵鎖連環殺自己時不用八卦陣
	local current = self.room:getCurrent()
	if current and self:isFriend(current) and self.player:isChained() and self:isGoodChainTarget(self.player, current) then return false end	--內奸跳反會有問題，非屬性殺也有問題。但狀況特殊，八卦陣原碼資訊不足，暫時這樣寫。

	if self.player:getHandcardNum() == 1 and self:getCardsNum("Jink") == 1 and self.player:hasSkills("zhiji|beifa") and self:needKongcheng() then
		local enemy_num = self:getEnemyNumBySeat(self.room:getCurrent(), self.player, self.player)
		if self.player:getHp() > enemy_num and enemy_num <= 1 then return false end
	end
	if handang and self:isFriend(handang) and dying > 0 then return false end
	if self:getDamagedEffects(self.player, nil, true) or self:needToLoseHp(self.player, nil, true, true) then return false end
	if self:getCardsNum("Jink") == 0 then return true end
	
	return true
end

local fatemoshu_skill={}
fatemoshu_skill.name="fatemoshu_vs"
table.insert(sgs.ai_skills,fatemoshu_skill)
fatemoshu_skill.getTurnUseCard=function(self)
    if self.player:getHandcardNum()<1 then return nil end
    if self.player:hasUsed("#fatemoshu_card") then return nil end
    local cards = self.player:getHandcards()
    cards=sgs.QList2Table(cards)
    self:sortByKeepValue(cards)
	local card_str = ("#fatemoshu_card:%d:"):format(cards[1]:getId())
    return sgs.Card_Parse(card_str)
end

sgs.ai_skill_use_func["#fatemoshu_card"]=function(card,use,self)
	self:sort(self.enemies, "hp") -- 按体力值从小到大排序
	for _, enemy in ipairs(self.enemies) do
		if not enemy:isKongcheng() and not enemy:hasSkill("tiandu") then
			use.card = sgs.Card_Parse("#fatemoshu_card:" .. card:getEffectiveId()..":")  -- 包含子卡的技能卡
			if use.to then
				use.to:append(enemy)
				return
			end
		end
	end
	for _, enemy in ipairs(self.enemies) do
		if self:getOverflow()>0 then
			use.card = sgs.Card_Parse("#fatemoshu_card:" .. card:getEffectiveId()..":")  -- 包含子卡的技能卡
			if use.to then
				use.to:append(enemy)
				return
			end
		end
	end
end

sgs.ai_use_value.fatemoshu_card = 7.5
sgs.ai_use_priority.fatemoshu_card = 4
sgs.ai_card_intention.fatemoshu_card = 70

--Alexander
local fatejuntuan_skill={}
fatejuntuan_skill.name="fatejuntuan_vs"
table.insert(sgs.ai_skills,fatejuntuan_skill)
fatejuntuan_skill.getTurnUseCard=function(self)
    if self.player:getHandcardNum()<1 then return nil end
    if self.player:hasUsed("#fatejuntuan_card") then return nil end
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _, c in ipairs(cards) do
		if c:isBlack() then 
	   		return sgs.Card_Parse("#fatejuntuan_card:" .. c:getEffectiveId()..":")
	   	end
	end
end

sgs.ai_skill_use_func["#fatejuntuan_card"]=function(card,use,self)
	local first
	self:sort(self.enemies, "hp") -- 按体力值从小到大排序
	for _, enemy in ipairs(self.enemies) do
		if self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and enemy:getMark("@fog") < 1 and self.player:distanceTo(enemy) < 2
		and not ((enemy:hasSkill("yiji") or enemy:hasSkill("jieming") or enemy:hasSkill("fangzhu") or enemy:hasSkill("guixin")) and enemy:getHp()>1)
		then
			use.card = sgs.Card_Parse("#fatejuntuan_card:" .. card:getEffectiveId()..":")  -- 包含子卡的技能卡
			if use.to then
				use.to:append(enemy)
				first=enemy
				break
			end
		end
	end
	if first then 
		for _, enemy2 in ipairs(self.enemies) do
			if self:objectiveLevel(enemy2) > 3 and not self:cantbeHurt(enemy2) and enemy2:getMark("@fog") < 1 and self.player:distanceTo(enemy2) < 2 and (enemy2:getSeat()~=first:getSeat())
			and not ((enemy2:hasSkill("yiji") or enemy2:hasSkill("jieming") or enemy2:hasSkill("fangzhu")) and enemy2:getHp()>1)
			then
				use.to:append(enemy2)
				return
			end
		end
	else
		for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and enemy:getMark("@fog") < 1 and self.player:distanceTo(enemy) < 2 then
				use.card = sgs.Card_Parse("#fatejuntuan_card:" .. card:getEffectiveId()..":")
				if use.to then
					use.to:append(enemy)
					first=enemy
					break
				end
			end
		end
	end
end

sgs.ai_use_value.fatejuntuan_card = 8.5
sgs.ai_use_priority.fatejuntuan_card = 3
sgs.ai_card_intention.fatejuntuan_card = 70

sgs.ai_skill_invoke.fatehuwei = function(self, data)
	if #self.friends_noself > 0 then
		return true
	end
	return false
end

sgs.ai_skill_playerchosen["@fatehuwei"] = function(self, targets)
	local choices = {}
	local card = sgs.Sanguosha:cloneCard("savage_assault", sgs.Card_NoSuit, -1)
	for _, target in sgs.qlist(targets) do
		local armor = target:getArmor()
		if self:isFriend(target)  and self:hasTrickEffective(card, target, self.player)
		and not (armor and armor:isKindOf("Vine")) --藤甲
		then
			table.insert(choices, target)
		end
	end
	self:sort(choices, "hp")
	return choices[1]
end

--Diarmuid
sgs.ai_skill_invoke.fatepomo = function(self, data)
	return true
end

sgs.ai_skill_playerchosen["@fatepomo"] = function(self, targets)
	for _, enemy in ipairs(self.enemies) do
		if enemy:hasSkill("beige") and not enemy:isNude() then
			return enemy
		end
	end
	--否则距离1以内的：堕落
	for _, enemy in ipairs(self.enemies) do
		if enemy:hasSkill("fateduoluo") and enemy:distanceTo(self.player)< 2 then
			return enemy
		end
	end
	self:sort(self.enemies, "hp") -- 按体力值从小到大排序
	--fate：王者，魔力，黑键，燕返，护佑，结界，+怯懦
	--正常版：遗计，奸雄，反馈，倾国，节命，刚烈，毅重，空城，龙胆，八阵，看破，无言，流离，天香，雷击，蛊惑，放逐，帷幕，屯田，享乐，归心，飞影，绝境，龙魂，忍戒
	--或是有防具的
	--如只有1血，则加上：
	--fate：圣骸，试炼
	--标准版：挥泪，武魂，追忆，急救，不屈, 断肠
	for _, enemy in ipairs(self.enemies) do
		if self.player:distanceTo(enemy) <= self.player:getAttackRange() and
		(enemy:hasSkill("fatewangzhe") or enemy:hasSkill("fatemoli") or enemy:hasSkill("fateheijian") or enemy:hasSkill("fateyanfan_vs") or enemy:hasSkill("fatehuyou") or enemy:hasSkill("fatejiejie") or enemy:hasSkill("fateqienuo") 
		or enemy:hasSkill("yiji") or enemy:hasSkill("jianxiong") or enemy:hasSkill("fankui") or enemy:hasSkill("qingguo") or enemy:hasSkill("ganglie")
		or enemy:hasSkill("yizhong") or enemy:hasSkill("kongcheng") or enemy:hasSkill("longdan") or enemy:hasSkill("bazhen") or enemy:hasSkill("kanpo")
		or enemy:hasSkill("wuyan") or enemy:hasSkill("liuli") or enemy:hasSkill("tianxiang") or enemy:hasSkill("leiji") or enemy:hasSkill("guhuo")
		or enemy:hasSkill("fangzhu") or enemy:hasSkill("weimu") or enemy:hasSkill("tuntian") or enemy:hasSkill("xiangle") 
		or enemy:hasSkill("fengying") or enemy:hasSkill("guixin") or enemy:hasSkill("juejing") or enemy:hasSkill("longhun") or enemy:hasSkill("renjie")
		or ((enemy:hasSkill("fateshenghai") or enemy:hasSkill("fateshilian") or enemy:hasSkill("huilei") or enemy:hasSkill("zhuiyi") or enemy:hasSkill("jijiu")
		or enemy:hasSkill("buqu") or enemy:hasSkill("duanchang")) and enemy:getHp()<2))
		or enemy:getArmor()~= nil
		then
			return enemy
		end
	end
	
	-- 否则全体的：
	--fate：竭智，圣器
	--正常版：看破，鬼才，鬼道，急救
	for _, enemy in ipairs(self.enemies) do
		if enemy:hasSkill("fatejiezhi") or enemy:hasSkill("fateshengqi") or enemy:hasSkill("kanpo") or enemy:hasSkill("guicai") or enemy:hasSkill("guidao") 
		or enemy:hasSkill("jijiu") 
		then
			return enemy
		end
	end
	
	
	--否则全体的：
	--fate：王者，护佑
	--正常版：遗计，节命，放逐，甘露，归心
	for _, enemy in ipairs(self.enemies) do
		if enemy:hasSkill("fatewangzhe") or enemy:hasSkill("fatehuyou") or enemy:hasSkill("yiji") or enemy:hasSkill("jieming") or enemy:hasSkill("fangzhu") 
		or enemy:hasSkill("ganlu") or enemy:hasSkill("guixin")
		then
			return enemy
		end
	end

	--否则全体的：
	--fate：剑冢，护卫，黑键
	--正常版：巨象，奸雄，祸首，帷幕，屯田
	for _, enemy in ipairs(self.enemies) do
		if enemy:hasSkill("fatejianzhong") or enemy:hasSkill("fatehuwei") or enemy:hasSkill("fateheijian") or enemy:hasSkill("juxiang") or enemy:hasSkill("jianxiong") 
		or enemy:hasSkill("huoshou") or enemy:hasSkill("weimu") or enemy:hasSkill("tuntian") 
		then
			return enemy
		end
	end
	
	--否则攻击范围内的：
	--fate：机智，法袍，献身
	--标准版：武圣，枭姬，义从，智迟，谦逊，狂暴，化身
	for _, enemy in ipairs(self.enemies) do
		if self.player:distanceTo(enemy) <= self.player:getAttackRange() and
		(enemy:hasSkill("fatejizhi") or enemy:hasSkill("fatefapao") or enemy:hasSkill("fatexianshen") or enemy:hasSkill("wusheng") or enemy:hasSkill("xiaoji") 
		or enemy:hasSkill("yicong") or enemy:hasSkill("zhichi") or enemy:hasSkill("qianxun") or enemy:hasSkill("kuangbao") or enemy:hasSkill("huashen"))
		then
			return enemy
		end
	end
	
	for _, enemy in ipairs(self.enemies) do
		if enemy:hasSkill("fatewangzhe") or enemy:hasSkill("fatemoli") or enemy:hasSkill("fateheijian") or enemy:hasSkill("fateyanfan") or enemy:hasSkill("fatehuyou") or enemy:hasSkill("fatejiejie")
		or enemy:hasSkill("yiji") or enemy:hasSkill("jianxiong") or enemy:hasSkill("fankui") or enemy:hasSkill("qingguo") or enemy:hasSkill("ganglie")
		or enemy:hasSkill("yizhong") or enemy:hasSkill("kongcheng") or enemy:hasSkill("longdan") or enemy:hasSkill("bazhen") or enemy:hasSkill("kanpo")
		or enemy:hasSkill("wuyan") or enemy:hasSkill("liuli") or enemy:hasSkill("tianxiang") or enemy:hasSkill("leiji") or enemy:hasSkill("guhuo")
		or enemy:hasSkill("fangzhu") or enemy:hasSkill("weimu") or enemy:hasSkill("tuntian") or enemy:hasSkill("xiangle") 
		or enemy:hasSkill("fengying") or enemy:hasSkill("guixin") or enemy:hasSkill("juejing") or enemy:hasSkill("longhun") or enemy:hasSkill("renjie")
		or ((enemy:hasSkill("fateshenghai") or enemy:hasSkill("fateshilian") or enemy:hasSkill("huilei") or enemy:hasSkill("zhuiyi") or enemy:hasSkill("jijiu")
		or enemy:hasSkill("buqu") or enemy:hasSkill("duanchang")) and enemy:getHp()==1)
		then
			return enemy
		end
	end
	
	for _, enemy in ipairs(self.enemies) do
		return enemy
	end
	
end

--Lancer
sgs.ai_skill_invoke.fatetuci = function(self, data)
	if self.player:getHandcardNum()<1 then return nil end
    local target = data:toPlayer()
	if target then
    return not self:isFriend(target) 
	end
	return false
end

--[[
local fatesiji_skill={}
fatesiji_skill.name="fatesiji_vs"
table.insert(sgs.ai_skills,fatesiji_skill)
fatesiji_skill.getTurnUseCard=function(self)
    if self.player:getHandcardNum()<1 then return nil end
    if self.player:hasUsed("#fatesiji_card") then return nil end
	if self.player:getLostHp()<2 then return nil end
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _, card in ipairs(cards) do
		if card:isKindOf("Weapon") then
			return sgs.Card_Parse("#fatesiji_card:" .. card:getEffectiveId()..":")
		end
	end
--    local weapon = self.player:getWeapon()
--	if weapon then
		--local card_str = ("#fatesiji_card:%d:"):format(weapon:getId())
		--return sgs.Card_Parse(card_str)
	--end
end


local fatesiji_skill={}
fatesiji_skill.name="fatesiji_vs"
table.insert(sgs.ai_skills,fatesiji_skill)
fatesiji_skill.getTurnUseCard=function(self)
    if self.player:getHandcardNum()<1 then return nil end
    if self.player:hasUsed("#fatesiji_card") then return nil end
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
--	for _, c in ipairs(cards) do
	--	if c:isBlack() then 
	--   		return sgs.Card_Parse("#fatesiji_card:" .. cards[1]:getEffectiveId()..":")
--	   	end
--	end
end

sgs.ai_skill_use_func["#fatesiji_card"]=function(card,use,self)
	self:sort(self.enemies, "hp") -- 按体力值从小到大排序
	for _, enemy in ipairs(self.enemies) do
		local armor = enemy:getArmor()
		if self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and enemy:getMark("@fog") < 1 and self:distanceTo(enemy) < 3 
		and not (armor and armor:isKindOf("Vine")) --藤甲
		then
			use.card = sgs.Card_Parse("#fatesiji_card:" .. card:getEffectiveId()..":")  -- 包含子卡的技能卡
			if use.to then
				use.to:append(enemy)
				return
			end
		end
	end
end
]]

local fatesiji_skill={}
fatesiji_skill.name="fatesiji_vs"
table.insert(sgs.ai_skills,fatesiji_skill)
fatesiji_skill.getTurnUseCard=function(self)
    if self.player:getHandcardNum()<1 then return nil end
    if self.player:hasUsed("#fatesiji_card") then return nil end
	if self.player:getLostHp()<2 then return nil end
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _, c in ipairs(cards) do
		if c:isKindOf("Weapon") then
	   		return sgs.Card_Parse("#fatesiji_card:" .. c:getEffectiveId()..":")
	   	end
	end
end

sgs.ai_skill_use_func["#fatesiji_card"]=function(card,use,self)
	self:sort(self.enemies, "hp") -- 按体力值从小到大排序
	for _, enemy in ipairs(self.enemies) do
		if self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and enemy:getMark("@fog") < 1 and enemy:getMark("@fateshenghai") < 1
		and enemy:getMark("@fatesakura_mark") < 1 and self.player:distanceTo(enemy) < 3 then
			use.card = sgs.Card_Parse("#fatesiji_card:" .. card:getEffectiveId()..":")  -- 包含子卡的技能卡
			if use.to then
				use.to:append(enemy)
				return
			end
		end
	end
end

sgs.ai_use_value["#fatesiji_card"] = 3.5
sgs.ai_use_priority["#fatesiji_card"] = 3
sgs.ai_card_intention["#fatesiji_card"] = 100

--shinji
sgs.ai_view_as.fateqienuo = function(card, player, card_place)
    local suit = card:getSuitString()
    local number = card:getNumberString()
    local card_id = card:getEffectiveId()
	if card:isKindOf("BasicCard") then
        return ("jink:fateqienuo[%s:%s]=%d"):format(suit, number, card_id)
    end
end

sgs.ai_skill_invoke.fateqiangtui = function(self, data)
	local room = self.room
	local players = room:getOtherPlayers(self.player)
	for _, target in sgs.qlist(players) do
		if self:isEnemy(target) and not target:isKongcheng() and (target:getSeat()==(self.player:getNextAlive()):getSeat() or self.player:getSeat()==(target:getNextAlive()):getSeat()) then
			return true
		end
	end
	for _, target in sgs.qlist(players) do
		if self.player:isWounded() and not target:isKongcheng() and target:isFemale()
		and (target:getSeat()==(self.player:getNextAlive()):getSeat() or self.player:getSeat()==(target:getNextAlive()):getSeat())
		then
			return true
		end
	end
    return false
end

sgs.ai_skill_playerchosen.fateqiangtui = function(self, targets) 
	local choices = {}
	if self.player:getLostHp() > 0 then
		for _, target in sgs.qlist(targets) do
			if self:isEnemy(target) and not target:isKongcheng() and target:isFemale() then
				table.insert(choices, target)
			end
		end
		if #choices ~= 0 then
			self:sort(choices, "hp")
			return choices[1]
		else
			for _, target in sgs.qlist(targets) do
				if not target:isKongcheng() and target:isFemale() then
					table.insert(choices, target)
				end
			end
			self:sort(choices, "hp", true)
			return choices[1]
		end
	end
	
	for _, target in sgs.qlist(targets) do
		if self:isEnemy(target) and not target:isKongcheng() then
			table.insert(choices, target)
		end
	end
	
	self:sort(choices, "hp")
	return choices[1]
end

--Kariya
local fatechongshu_skill={}
fatechongshu_skill.name="fatechongshu"
table.insert(sgs.ai_skills,fatechongshu_skill)
fatechongshu_skill.getTurnUseCard=function(self)
    if self.player:getHandcardNum()<1 then return nil end
    if self.player:hasUsed("#fatechongshu_card") then return nil end
    local cards = self.player:getHandcards()
    cards=sgs.QList2Table(cards)
    self:sortByKeepValue(cards)
	local card_str = ("#fatechongshu_card:%d:"):format(cards[1]:getId())
    return sgs.Card_Parse(card_str)
end

sgs.ai_skill_use_func["#fatechongshu_card"]=function(card,use,self)
	self:sort(self.enemies, "hp") -- 按体力值从小到大排序
	for _, enemy in ipairs(self.enemies) do
		if enemy:getHp()<2 and self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and enemy:getMark("@fog") < 1 and enemy:getMark("@fateshenghai") < 1
		and enemy:getMark("@fatesakura_mark") < 1 and enemy:getHandcardNum()<2
		then
			use.card = sgs.Card_Parse("#fatechongshu_card:" .. card:getEffectiveId()..":")  -- 包含子卡的技能卡
			if use.to then
				use.to:append(enemy)
				return
			end
		end
	end
	for _, enemy in ipairs(self.enemies) do
		if (self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and enemy:getMark("@fog") < 1 and enemy:getMark("@fateshenghai") < 1
		and enemy:getMark("@fatesakura_mark") < 1 and enemy:getHandcardNum()<2) or enemy:getHandcardNum()>1
		then
			use.card = sgs.Card_Parse("#fatechongshu_card:" .. card:getEffectiveId()..":")  -- 包含子卡的技能卡
			if use.to then
				use.to:append(enemy)
				return
			end
		end
	end
end

sgs.ai_use_value.fatechongshu_card = 7.5
sgs.ai_use_priority.fatechongshu_card = 4
sgs.ai_card_intention.fatechongshu_card = 100

sgs.ai_skill_invoke.fatejiushu = function(self, data)
	if self.player:getMark("@fatejiushu_mark")==0 then return false end
	if self.player:getRole()=="renegade"  then return false end
    return (#self.friends_noself > 0)
end

--一定不会选择内奸
--不会选择一血以上的郭嘉、狗或、曹丕
--优先华佗，香香，凛，樱(未觉醒时)
--否则大师
--否则切嗣，貂蝉，小次郎
--否则忠臣选择主公
--否则选择一血队友
--否则按嘲讽排序，选最嘲讽的
sgs.ai_skill_playerchosen["@fatejiushu"]= function(self, targets) 
	self:sort(self.friends_noself, "chaofeng")
	for _, friend in ipairs(self.friends_noself) do
        if (friend:hasSkill("qingnang") or friend:hasSkill("jieyin") or friend:hasSkill("fateqingxing") or friend:hasSkill("fatechuyi_vs")) and friend:getRole()~="renegade" then
            return friend
        end
    end
	for _, friend in ipairs(self.friends_noself) do
        if friend:hasSkill("dimeng") and friend:hasSkill("haoshi") and friend:getRole()~="renegade" then
            return friend
        end
    end
	for _, friend in ipairs(self.friends_noself) do
        if (friend:hasSkill("fatejiezhi") or friend:hasSkill("lijian") or friend:hasSkill("fatezonghe")) and friend:getRole()~="renegade" then
            return friend
        end
    end
	
    local lord = self.room:getLord()
    if self:isFriend(lord) and not self.player:isLord() then --因为内奸不会发动此技能……
        return lord
    end
	
    for _, friend in ipairs(self.friends_noself) do
        if friend:getHp()<2 and friend:getRole()~="renegade" then
			return friend
        end
    end
	for _, friend in ipairs(self.friends_noself) do
        if friend:getRole()~="renegade" and not ((friend:hasSkill("yiji") or friend:hasSkill("jieming") or friend:hasSkill("fangzhu") or friend:hasSkill("guixin")) and friend:getHp()>1) then
			return friend
        end
    end
end

fatejiushu_damageeffect = function(self, to, nature, from)
	if to:getMark("@fatesakura_mark") > 0 and nature == sgs.DamageStruct_Thunder then return false end
	return true
end
table.insert(sgs.ai_damage_effect, fatejiushu_damageeffect)

sgs.ai_chaofeng = {
	Kiritsugu=5,
	Shirou=2,
	Saber =0,
	Carene=-1,
	Medusa=2,
	Rin=3,
	Heracles=-2,
	Medea=2,
	Sakura=4,
	Gilgamesh=2,
	Emiya_Archer=4,
	Iriya=3,
	Gilles=2,
	Kojirou=5,
	Lancelot=4,
	Kirei=1,
	Hassan_Sabbah=4,
	Irisviel=1,
	Tokiomi=3,
	Alexander=4,
	Diarmuid=4,
	Chulainn=5,
	Shinji=1,
	Kariya=6
}