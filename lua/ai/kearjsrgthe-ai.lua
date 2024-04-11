
sgs.ai_skill_use["@@kehexumouuse"] = function(self, prompt)
	local id = self.player:getMark("kehexumouuse-PlayClear") - 1
	if id < 0 then return "." end
	local card = sgs.Sanguosha:getEngineCard(id)
	if card:targetFixed() then
		if card:isKindOf("Peach") then
			if self:isWeak() then
				return card:toString()
			end
			if self:isWeak(self.friends_noself) then
				return "."
			end
			return card:toString()
		end
		if card:isKindOf("EquipCard") then
			local equip_index = card:getRealCard():toEquipCard():location()
			if self.player:getEquip(equip_index) == nil then
				return card:toString()
			end
		end
		if card:isKindOf("AOE") then
			if self:getAoeValue(card) > 0 then
				return card:toString()
			end
		end
		if card:isKindOf("Analeptic") then
			return "."
		end
		if card:isKindOf("ExNihilo") then
			return card:toString()
		end
	else
		local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
		self:useCardByClassName(card, dummy_use)
		if dummy_use.card and not dummy_use.to:isEmpty() then
			local targets = {}
			for _, p in sgs.qlist(dummy_use.to) do
				table.insert(targets, p:objectName())
			end
			if #targets > 0 then
				return card:toString() .. "->" .. table.concat(targets, "+")
			end
		end
	end
	return "."
end

--郭循

sgs.ai_skill_choice.keheeqian = function(self, choices, data)
	return "add"
end

sgs.ai_skill_invoke.keheeqian = function(self, data)
	return true
end

sgs.ai_skill_discard.keheeqian = function(self) 
	if not (self.player:containsTrick("_kezhuanxumou_card_one") or self.player:containsTrick("_kezhuanxumou_card_two") or
	self.player:containsTrick("_kezhuanxumou_card_three") or self.player:containsTrick("_kezhuanxumou_card_four") or
	self.player:containsTrick("_kezhuanxumou_card_five") or self:isWeak()) then
		local to_discard = {}
		local cards = self.player:getCards("h")
		cards = sgs.QList2Table(cards)
		--[[for _, c in sgs.ipairs(cards) do 
			if c:isDamageCard() or c:isAvailable(self.player) then
				table.insert(to_discard, c:getEffectiveId())
				break
			end
		end]]
		self:sortByKeepValue(cards)
		local nnum = #cards
		for i = 0, (#cards - 1), 1 do
			if cards[nnum]:isDamageCard() or cards[nnum]:isAvailable(self.player) then
				table.insert(to_discard, cards[nnum]:getEffectiveId())
				break
			end
			nnum = nnum - 1
		end
		--table.insert(to_discard, cards[#cards]:getEffectiveId())
		return to_discard		
	else
		return self:askForDiscard("dummyreason", 999, 999, true, true)
	end
end

local kehefusha_skill = {}
kehefusha_skill.name = "kehefusha"
table.insert(sgs.ai_skills, kehefusha_skill)
kehefusha_skill.getTurnUseCard = function(self)
	if (self.player:getMark("@kehefusha") <= 0) then return end
	return sgs.Card_Parse("#kehefushaCard:.:")
end

sgs.ai_skill_use_func["#kehefushaCard"] = function(card, use, self)
    if (self.player:getMark("@kehefusha")>0) then
        self:sort(self.enemies)
	    self.enemies = sgs.reverse(self.enemies)
		local enys = sgs.SPlayerList()
		for _, enemy in ipairs(self.enemies) do
			if self.player:inMyAttackRange(enemy) then
				enys:append(enemy)
				break
			end
		end
		local num = 0
		for _, p in sgs.qlist(self.player:getAliveSiblings()) do
			if self.player:inMyAttackRange(p) then
				num = num + 1
			end
		end
		for _,enemy in sgs.qlist(enys) do
			if (num == 1) and (self:objectiveLevel(enemy) > 0) then
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
	end
end

sgs.ai_use_value.kehefushaCard = 8.5
sgs.ai_use_priority.kehefushaCard = 9.5
sgs.ai_card_intention.kehefushaCard = 80



--诸葛亮

sgs.ai_skill_invoke.kehewentian = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.kehewentian = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isFriend(p) then
			theweak:append(p)
		end
	end
	for _,qq in sgs.qlist(theweak) do
		if (qq:getRole() == "lord") then
			for _,oo in sgs.qlist(theweak) do
				theweaktwo:removeOne(oo)
			end
			theweaktwo:append(qq)
			break
		end
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _,pp in sgs.qlist(theweaktwo) do
				if (pp:getHp() < qq:getHp()) then
					inin = 0
				end
			end
			if (inin == 1) then
				theweaktwo:append(qq)
			end
		end
	end
	--[[for _,zg in sgs.qlist(self.player:getAliveSiblings()) do
		if self:isFriend(zg) and (zg:getRole() == "lord") then
			return zg
		end
	end]]
	if theweaktwo:length() > 0 then
	    return theweaktwo:at(0)
	end
	return nil
end


local kehewentian_skill={}
kehewentian_skill.name="kehewentian"
table.insert(sgs.ai_skills,kehewentian_skill)
kehewentian_skill.getTurnUseCard=function(self)
	
	local room = self.room
	local card = sgs.Sanguosha:getCard(room:getDrawPile():first())
	if card:isRed() and (self.player:getMark("&bankehewentian_lun") == 0) then

		local suit = card:getSuitString()
		local number = card:getNumberString()
		local card_id = card:getEffectiveId()
		local card_str = ("fire_attack:kehewentian[%s:%s]=%d"):format(suit, number, card_id)
		local skillcard = sgs.Card_Parse(card_str)
	
		assert(skillcard)
	
		return skillcard
	end
end

--[[sgs.ai_view_as.kehewentian = function(card, player, card_place)
	local pdcard = sgs.Sanguosha:getCard(player:getMark("kehewentianId"))
	local suit = pdcard:getSuitString()
	local number = pdcard:getNumberString()
	local card_id = player:getMark("kehewentianId")
	if (pdcard:isBlack() or (math.random(1,10) >=7)) and (player:getMark("&bankehewentian_lun") == 0) then
		return ("nullification:kehewentian[%s:%s]=%d"):format(suit, number, card_id)
	end	
end]]

function sgs.ai_cardsview.kehewentian(self, class_name, player)
	if class_name == "Nullification" then
		if player:hasSkill("kehewentian") and (player:getMark("&bankehewentian_lun") == 0) then
			--return ("analeptic:jiushi[no_suit:0]=.")
			local pdcard = sgs.Sanguosha:getCard(player:getMark("kehewentianId"))
			local suit = pdcard:getSuitString()
			local number = pdcard:getNumberString()
			local card_id = player:getMark("kehewentianId")
			return ("nullification:kehewentian[%s:%s]=%d"):format(suit, number, card_id)
		end
	end
end

sgs.ai_skill_discard.keheyinlue = function(self, discard_num, min_num, optional, include_equip) 
	local to_discard = {}
	local cards = self.player:getCards("he")
	local len = cards:length()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if self.player:hasFlag("wantuseyinlue") and (len > 0) then
	    table.insert(to_discard, cards[1]:getEffectiveId())
		return to_discard
	else
	    return self:askForDiscard("dummyreason", 999, 999, true, true)
	end
end

local kehechushi_skill = {}
kehechushi_skill.name = "kehechushi"
table.insert(sgs.ai_skills, kehechushi_skill)
kehechushi_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kehechushiCard") then return end
	return sgs.Card_Parse("#kehechushiCard:.:")
end

sgs.ai_skill_use_func["#kehechushiCard"] = function(card, use, self)
    if not self.player:hasUsed("#kehechushiCard") then
        use.card = card
	    return
	end
end

sgs.ai_skill_invoke.keheyinlue = function(self, data)
	if self.player:hasFlag("wantuseyinlue") then
	    return true
	end
end

sgs.ai_skill_discard.kehechushi = function(self)
	local to_discard = {}
	if self.player:hasFlag("kehewentianred") then
		for _,c in sgs.qlist(self.player:getCards("h")) do
			if (c:isRed()) then
				if (#to_discard == 0) then
				    table.insert(to_discard, c:getEffectiveId())
				end
			end
		end
	elseif self.player:hasFlag("kehewentianblack") then
		for _,c in sgs.qlist(self.player:getCards("h")) do
			if (c:isBlack()) then
				if (#to_discard == 0) then
				    table.insert(to_discard, c:getEffectiveId())
				end
			end
		end
	else
		for _,c in sgs.qlist(self.player:getCards("h")) do
			if (#to_discard == 0) then
				table.insert(to_discard, c:getEffectiveId())
			end	
		end
	end
	if (#to_discard == 0) then
		for _,c in sgs.qlist(self.player:getCards("h")) do
			if (#to_discard == 0) then
				table.insert(to_discard, c:getEffectiveId())
			end
		end
	end
	return to_discard
end


--二虎

sgs.ai_skill_invoke.kehedaimouone = function(self, data)
	return true
end

--卫温诸葛直

local kehefuhai_skill = {}
kehefuhai_skill.name = "kehefuhai"
table.insert(sgs.ai_skills, kehefuhai_skill)
kehefuhai_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kehefuhaiCard") then return end
	return sgs.Card_Parse("#kehefuhaiCard:.:")
end

sgs.ai_skill_use_func["#kehefuhaiCard"] = function(card, use, self)
    if not self.player:hasUsed("#kehefuhaiCard") then
        use.card = card
	    return
	end
end

--郭照

sgs.ai_skill_invoke.kehepianchong = function(self, data)
	return true
end

--姜维

local kehejinfa_skill = {}
kehejinfa_skill.name = "kehejinfa"
table.insert(sgs.ai_skills, kehejinfa_skill)
kehejinfa_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kehejinfaCard") then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local to_throw = sgs.IntList()
	for _, acard in ipairs(cards) do
		to_throw:append(acard:getEffectiveId())
	end
	card_id = to_throw:at(0)--(to_throw:length()-1)
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("#kehejinfaCard:"..card_id..":")
	end
end

sgs.ai_skill_use_func["#kehejinfaCard"] = function(card, use, self)
    if not self.player:hasUsed("#kehejinfaCard") then
        use.card = card
	    return
	end
end

function sgs.ai_cardneed.kehejinfaCard(to, card, self)
	if self.player:hasUsed("#kehejinfaCard") then return false end
	return true
end

sgs.ai_use_value.kehejinfaCard = 8.5
sgs.ai_use_priority.kehejinfaCard = 9.5
sgs.ai_card_intention.kehejinfaCard = 80

sgs.ai_skill_playerschosen.kehejinfa = function(self, targets, max, min)
    local selected = sgs.SPlayerList()
    local n = max
    local can_choose = sgs.QList2Table(targets)
    self:sort(can_choose, "defense")
    for _,target in ipairs(can_choose) do
        if self:isFriend(target) then
            selected:append(target)
            n = n - 1
        end
        if n <= 0 then break end
    end
    return selected
end

sgs.ai_skill_choice.kehejiangwei_ChooseKingdom = function(self, choices)
	local items = choices:split("+")
	--[[if (self.player:getKingdom() == "shu") then
	    return "wei"
	else]]
		return "shu"
	--end
end

sgs.ai_skill_discard.kehejinfa = function(self)
	local to_discard = {}
	if self.player:hasFlag("wantjinfared") then
		for _,c in sgs.qlist(self.player:getCards("h")) do
			if (c:isRed()) then
				if (#to_discard == 0) then
				    table.insert(to_discard, c:getEffectiveId())
				end
			end
		end
	elseif self.player:hasFlag("wantjinfablack") then
		for _,c in sgs.qlist(self.player:getCards("h")) do
			if (c:isBlack()) then
				if (#to_discard == 0) then
				    table.insert(to_discard, c:getEffectiveId())
				end
			end
		end
	else
		for _,c in sgs.qlist(self.player:getCards("h")) do
			if (#to_discard == 0) then
				table.insert(to_discard, c:getEffectiveId())
			end	
		end
	end
	if (#to_discard == 0) then
		for _,c in sgs.qlist(self.player:getCards("h")) do
			if (#to_discard == 0) then
				table.insert(to_discard, c:getEffectiveId())
			end
		end
	end
	return to_discard
end

--[[sgs.ai_skill_use["@@kehefumou"] = function(self,prompt)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if self.player:isJilei(h) then continue end
    	local c = sgs.Sanguosha:cloneCard("slash")
		c:setSkillName("kehefumou")
		c:addSubcard(h)
		local dummy = {isDummy=true,to=sgs.SPlayerList()}
		self["use"..sgs.ai_type_name[c:getTypeId()+1].."Card"](self,c,dummy)
		if dummy.card and dummy.to
		then
			local tos = {}
			for _,p in sgs.list(dummy.to)do
				table.insert(tos,p:objectName())
			end
			return "#kezhuanchuanxinCard:"..h:getId()..":->"..table.concat(tos,"+")
		end
	end
end]]

sgs.ai_view_as.kehexuanfeng = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if (player:getKingdom() == "shu") and card_place ~= sgs.Player_PlaceSpecial and card:isKindOf("kezhuan_ying") and not card:isKindOf("Peach") and not card:hasFlag("using") then
		return ("slash:kehexuanfeng[%s:%s]=%d"):format(suit, number, card_id)
	end
end

local kehexuanfeng_skill = {}
kehexuanfeng_skill.name = "kehexuanfeng"
table.insert(sgs.ai_skills, kehexuanfeng_skill)
kehexuanfeng_skill.getTurnUseCard = function(self, inclusive)
	if (self.player:getKingdom() ~= "shu") then return end
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
			if card:isKindOf("kezhuan_ying") and card:isKindOf("TrickCard") and nuzhan_equip_e then
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
			if card:isKindOf("kezhuan_ying") and card:isKindOf("TrickCard") and nuzhan_trick_e then
				nuzhan_trick = true
				break
			end
		end
	end

	for _, card in ipairs(cards) do
		if card:isKindOf("kezhuan_ying") and not card:isKindOf("Slash") and not (nuzhan_equip or nuzhan_trick)
			and (not isCard("Peach", card, self.player) and not isCard("ExNihilo", card, self.player) and not useAll)
			and (not isCard("Crossbow", card, self.player) or disCrossbow)
			and (self:getUseValue(card) < sgs.ai_use_value.Slash or inclusive or sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, sgs.Sanguosha:cloneCard("slash")) > 0) then
			red_card = card
			break
		end
	end

	if nuzhan_equip then
		for _, card in ipairs(cards) do
			if card:isKindOf("kezhuan_ying") and card:isKindOf("EquipCard") then
				red_card = card
				break
			end
		end
	end

	if nuzhan_trick then
		for _, card in ipairs(cards) do
			if card:isKindOf("kezhuan_ying") and card:isKindOf("TrickCard")then
				red_card = card
				break
			end
		end
	end

	if red_card then
		local suit = red_card:getSuitString()
		local number = red_card:getNumberString()
		local card_id = red_card:getEffectiveId()
		local card_str = ("slash:kehexuanfeng[%s:%s]=%d"):format(suit, number, card_id)
		local slash = sgs.Card_Parse(card_str)

		assert(slash)
		return slash
	end
end

function sgs.ai_cardneed.kehexuanfeng(to, card)
	return card:isKindOf("kezhuan_ying") 
end

--曹芳
local kehezhaotu_skill={}
kehezhaotu_skill.name="kehezhaotu"
table.insert(sgs.ai_skills,kehezhaotu_skill)
kehezhaotu_skill.getTurnUseCard=function(self,inclusive)
	if (self.player:getMark("kehezhaotuuse_lun") ~= 0) then return end
	local cards = self.player:getCards("he")
	cards=sgs.QList2Table(cards)

	local card

	self:sortByUseValue(cards,true)

	local has_weapon, has_armor = false, false

	for _,acard in ipairs(cards)  do
		if acard:isKindOf("Weapon") and not (acard:isRed() and (not acard:isKindOf("TrickCard"))) then has_weapon=true end
	end

	for _,acard in ipairs(cards)  do
		if acard:isKindOf("Armor") and not (acard:isRed() and (not acard:isKindOf("TrickCard"))) then has_armor=true end
	end

	for _,acard in ipairs(cards)  do
		if acard:isRed() and (not acard:isKindOf("TrickCard")) and ((self:getUseValue(acard)<sgs.ai_use_value.Indulgence) or inclusive) then
			local shouldUse=true

			if acard:isKindOf("Armor") then
				if not self.player:getArmor() then shouldUse = false
				elseif self.player:hasEquip(acard) and not has_armor and self:evaluateArmor() > 0 then shouldUse = false
				end
			end

			if acard:isKindOf("Weapon") then
				if not self.player:getWeapon() then shouldUse = false
				elseif self.player:hasEquip(acard) and not has_weapon then shouldUse = false
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
	local card_str = ("indulgence:kehezhaotu[%s:%s]=%d"):format(suit, number, card_id)
	--local card_str = ("indulgence:kehezhaotu[diamond:%s]=%d"):format(number, card_id)
	local indulgence = sgs.Card_Parse(card_str)
	assert(indulgence)
	return indulgence
end

function sgs.ai_cardneed.kehezhaotu(to, card)
	return card:isRed() and (not card:isKindOf("TrickCard"))
end

--赵云
sgs.ai_skill_invoke.kehelonglinjuedou = function(self, data)
	return self.player:hasFlag("wantuselonglinjuedou")
end


sgs.ai_skill_discard.kehelonglin = function(self, discard_num, min_num, optional, include_equip) 
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if self.player:hasFlag("wantuselonglin") then
	    table.insert(to_discard, cards[1]:getEffectiveId())
		return to_discard
	else
	    return self:askForDiscard("dummyreason", 999, 999, true, true)
	end
end

local kehezhendan_skill = {}
kehezhendan_skill.name = "kehezhendan"
table.insert(sgs.ai_skills, kehezhendan_skill)
kehezhendan_skill.getTurnUseCard = function(self, inclusive)
	self:updatePlayers()
	self:sort(self.enemies, "defense")
	local handcards = sgs.QList2Table(self.player:getCards("h"))
	if self.player:getPile("wooden_ox"):length() > 0 then
		for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
			table.insert(handcards ,sgs.Sanguosha:getCard(id))
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
	--if self.player:getMark("&moulongdannLast") > 0 then
		if #basic_cards > 0 then
			table.insert(use_cards, basic_cards[1])
		end
		if #use_cards == 0 then return end
	--end
	if self.player:isWounded() then
		return sgs.Card_Parse("#kehezhendan:" .. table.concat(use_cards, "+") .. ":" .. "peach")
	end
	for _, enemy in ipairs(self.enemies) do
		if self.player:canSlash(enemy) and sgs.isGoodTarget(enemy, self.enemies, self, true) and self.player:inMyAttackRange(enemy) then
			local fire_slash = sgs.Sanguosha:cloneCard("fire_slash")
			local thunder_slash = sgs.Sanguosha:cloneCard("thunder_slash")
			local ice_slash = sgs.Sanguosha:cloneCard("ice_slash")
			local slash = sgs.Sanguosha:cloneCard("slash")
			if not self:slashProhibit(fire_slash, enemy, self.player) and self:slashIsEffective(fire_slash, enemy, self.player) then
				return sgs.Card_Parse("#kehezhendan:" .. table.concat(use_cards, "+") .. ":" .. "fire_slash")
			end
			if not self:slashProhibit(thunder_slash, enemy, self.player) and self:slashIsEffective(thunder_slash, enemy, self.player) then
				return sgs.Card_Parse("#kehezhendan:" .. table.concat(use_cards, "+") .. ":" .. "thunder_slash")
			end
			if not self:slashProhibit(ice_slash, enemy, self.player) and self:slashIsEffective(ice_slash, enemy, self.player) then
				return sgs.Card_Parse("#kehezhendan:" .. table.concat(use_cards, "+") .. ":" .. "ice_slash")
			end
			if not self:slashProhibit(slash, enemy, self.player) and self:slashIsEffective(slash, enemy, self.player) then
				return sgs.Card_Parse("#kehezhendan:" .. table.concat(use_cards, "+") .. ":" .. "slash")
			end
		end
	end
end

sgs.ai_skill_use_func["#kehezhendan"] = function(card, use, self)
	local userstring = card:toString()
	userstring = (userstring:split(":"))[4]
	local kehezhendancard = sgs.Sanguosha:cloneCard(userstring, card:getSuit(), card:getNumber())
	kehezhendancard:setSkillName("kehezhendan")
	self:useBasicCard(kehezhendancard, use)
	if not use.card then return end
	use.card = card
end

sgs.ai_use_priority["kehezhendan"] = 3
sgs.ai_use_value["kehezhendan"] = 3

sgs.ai_view_as["kehezhendan"] = function(card, player, card_place, class_name)
	local classname2objectname = {
		["Slash"] = "slash", ["Jink"] = "jink",
		["Peach"] = "peach", ["Analeptic"] = "analeptic",
		["FireSlash"] = "fire_slash", ["ThunderSlash"] = "thunder_slash",
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
			table.insert(handcards ,sgs.Sanguosha:getCard(id))
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
	--if player:getMark("&moulongdannLast") > 0 then
		if #basic_cards > 0 then
			table.insert(use_cards, basic_cards[1])
		end
		if #use_cards == 0 then return end
	--end
	--if player:getMark("&moulongdannLast") > 0 then
		if class_name == "Peach" then
			local dying = player:getRoom():getCurrentDyingPlayer()
			if dying and dying:getHp() < 0 then return end
			return (name..":kehezhendan[%s:%s]=%d"):format(sgs.Card_NoSuit, 0, use_cards[1])
		else
			return (name..":kehezhendan[%s:%s]=%d"):format(sgs.Card_NoSuit, 0, use_cards[1])
		end
	--end
end

function sgs.ai_cardneed.kehezhendan(to, card, self)
	return (not card:isKindOf("BasicCard")) and (not card:isEquipped())
end


--司马懿

sgs.ai_skill_invoke.keheyingshi = function(self, data)
	return true
end

sgs.ai_skill_invoke.kehetuigu = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.kehetuigu = function(self, targets)
	if self:isWeak() and (self.player:getEquipsId():length() > 0) then
		return self.player
	end
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
			theweak:append(p)
		end
	end
	for _,qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _,pp in sgs.qlist(theweaktwo) do
				if (pp:getEquips():length() > qq:getEquips():length()) then
					inin = 0
				end
			end
			if (inin == 1) then
				theweaktwo:removeOne(theweaktwo:at(0))
				theweaktwo:append(qq)
			end
		end
	end
	if theweaktwo:length() > 0 then
	    return theweaktwo:at(0)
	end
	return nil
end

--曹芳

local kehejingju_skill={}
kehejingju_skill.name="kehejingju"
table.insert(sgs.ai_skills,kehejingju_skill)
kehejingju_skill.getTurnUseCard = function(self)
	for _,p in sgs.list(self.player:getAliveSiblings())do
		for _,j in sgs.list(p:getJudgingArea())do
			if self.player:containsTrick(j:objectName())
			or self:isEnemy(p) then continue end
			return sgs.Card_Parse("#kehejingjuCard:.:")
		end
	end
end

sgs.ai_skill_use_func["#kehejingjuCard"] = function(card,use,self)
	for _,p in sgs.list(patterns)do
		local dc = dummyCard(p)
		if dc and dc:getTypeId()==1
		then
			dc:setSkillName("kehejingju")
			if dc:isAvailable(self.player)
			then
				--local dummy = self:aiUseCard(dc)
				local dummy = {isDummy=true,to=sgs.SPlayerList()}
				self:useCardByClassName(dc, dummy)
				if dummy.card and dummy.to
				then
					use.card = card
					if use.to then use.to = dummy.to end
					break
				end
			end
		end
	end
end

sgs.ai_use_value.kehejingjuCard = 4.4
sgs.ai_use_priority.kehejingjuCard = 3

function sgs.ai_cardsview.jingju(self,class_name,player)
	if sgs.Sanguosha:getCurrentCardUseReason()~=sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
	then return end
	local dc = dummyCard(class_name)
	if dc and dc:getTypeId()==1
	then
		for _,p in sgs.list(player:getAliveSiblings())do
			for _,j in sgs.list(p:getJudgingArea())do
				if player:containsTrick(j:objectName()) then continue end
				return ("#kehejingjuCard:.:"..dc:objectName())
			end
		end
	end
end

sgs.ai_skill_playerchosen.kehejingju = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		then return target end
	end
	return destlist[1]
end

sgs.ai_skill_discard.keheweizhui = function(self, discard_num, min_num, optional, include_equip) 
	local to_discard = {}
	local cards = self.player:getCards("he")
	local len = cards:length()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if self.player:hasFlag("wantuseweizhui") and (len > 0) then
		if cards[1]:isBlack() then
			table.insert(to_discard, cards[1]:getEffectiveId())
			return to_discard
		else
			return self:askForDiscard("dummyreason", 999, 999, true, true)
		end
	else
	    return self:askForDiscard("dummyreason", 999, 999, true, true)
	end
end

--陆逊

sgs.ai_skill_playerchosen.keheyoujin = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
			theweak:append(p)
		end
	end
	for _,qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _,pp in sgs.qlist(theweaktwo) do
				if (pp:getHp() < qq:getHp()) then
					inin = 0
				end
			end
			if (inin == 1) then
				theweaktwo:append(qq)
			end
		end
	end
	if theweaktwo:length() > 0
	and ((self.player:getHandcardNum() <= (self.player:getHp() + 3)) 
	or ((theweaktwo:at(0):getHp() + theweaktwo:at(0):getHujia()) <=2) 
	or (math.random(1,3) == 3)
    )then
	    return theweaktwo:at(0)
	end
	return nil
end


local kehedailao_skill = {}
kehedailao_skill.name = "kehedailao"
table.insert(sgs.ai_skills, kehedailao_skill)
kehedailao_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kehedailaoCard") then return end
	local num = 0
	for _,c in sgs.qlist(self.player:getHandcards()) do
		if (not self.player:isJilei(c)) and (c:isAvailable(self.player)) then
			num = num + 1
		end
	end
	if (num == 0) then
		return sgs.Card_Parse("#kehedailaoCard:.:")
	end
end

sgs.ai_skill_use_func["#kehedailaoCard"] = function(card, use, self)
	local num = 0
	for _,c in sgs.qlist(self.player:getHandcards()) do
		if (not self.player:isJilei(c)) and (c:isAvailable(self.player)) then
			num = num + 1
		end
	end
    if (not self.player:hasUsed("#kehedailaoCard")) and (num == 0) then
        use.card = card
	    return
	end
end

sgs.ai_use_value.kehedailaoCard = 8.5
sgs.ai_use_priority.kehedailaoCard = 9.5
sgs.ai_card_intention.kehedailaoCard = 80

--孙峻

sgs.ai_skill_invoke.keheyaoyan = function(self, data)
	return true
end

sgs.ai_skill_choice.keheyaoyan = function(self, choices, data)
	local sj = room:getCurrent()
	if (self.player:objectName() == sj:objectName()) then
		return "join"
	else
		if self:isFriend(sj) then
			local num = math.random(0,5)
			if num ~= 1 then
				return "join"
			else
				return "notjoin"
			end
		else
			local num = math.random(0,1)
			if num == 1 then
				return "join"
			else
				return "notjoin"
			end
		end
	end
end

sgs.ai_skill_playerschosen.keheyaoyan = function(self, targets, max, min)
    local selected = sgs.SPlayerList()
    local n = max
    local can_choose = sgs.QList2Table(targets)
    self:sort(can_choose, "defense")
    for _,target in ipairs(can_choose) do
        if (self:isEnemy(target)) 
		or (self:isFriend(target) and (target:getOverflow() > 1)) then
            selected:append(target)
            n = n - 1
        end
        if n <= 0 then break end
    end
    return selected
end

sgs.ai_skill_playerchosen.keheyaoyan = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
			theweak:append(p)
		end
	end
	for _,qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _,pp in sgs.qlist(theweaktwo) do
				if (pp:getHp() < qq:getHp()) then
					inin = 0
				end
			end
			if (inin == 1) then
				theweaktwo:append(qq)
			end
		end
	end
	if theweaktwo:length() > 0 then
	    return theweaktwo:at(0)
	end
	return nil
end

local kehechiying_skill = {}
kehechiying_skill.name = "kehechiying"
table.insert(sgs.ai_skills, kehechiying_skill)
kehechiying_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kehechiyingCard") then return end
	return sgs.Card_Parse("#kehechiyingCard:.:")
end

sgs.ai_skill_use_func["#kehechiyingCard"] = function(card, use, self)
    if not self.player:hasUsed("#kehechiyingCard") then
		self:sort(self.friends)
		local players = sgs.SPlayerList()
		players:append(self.player)
		for _, friend in ipairs(self.friends) do
			players:append(friend)
		end
		players = sgs.QList2Table(players) 
		self:sort(players,"hp")
		for _, friend in ipairs(players) do
			use.card = card
			if use.to then use.to:append(friend) end
			return
		end
	end
end

sgs.ai_use_value.kehechiyingCard = 8.5
sgs.ai_use_priority.kehechiyingCard = 9.5
sgs.ai_card_intention.kehechiyingCard = 80

--[[sgs.ai_skill_use_func["#kehechiyingCard"] = function(card, use, self)
	if not self.player:hasUsed("#kehechiyingCard") then
		self:updatePlayers()
		local room = self.room
		local can_dis = 0
		local target = nil
	
		for _,friend in ipairs(self.friends) do
			if friend:getHp() <= self.player:getHp() then
				local dis = 0
				for _,other in sgs.qlist(room:getOtherPlayers(friend)) do
					if friend:inMyAttackRange(other) and other:objectName() ~= self.player:objectName() then
						if not self:isFriend(other) then
							if friend:objectName() == self.player:objectName() then
								dis = dis + 1
							else
								dis = dis + 1.5
							end
						end
					end
				end
				if dis > can_dis then
					target = friend
					can_dis = dis
				end
			end
		end
	
		if not target then return end
		if target then
			local card_str = "#kehechiying:.:->"..target:objectName()
			local acard = sgs.Card_Parse(card_str)
			assert(acard)
			use.card = acard
			if use.to then
				use.to:append(target)
			end
		end
	end
end

sgs.ai_use_priority.kehechiying = 6]]



























