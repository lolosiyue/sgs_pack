--郭嘉
sgs.ai_skill_invoke.kezhuandingce = function(self, data)
	if self.player:hasFlag("dingceself")
		or self.player:hasFlag("dingcefriend")
		or self.player:hasFlag("dingceeny") then
		return true
	end
end

sgs.ai_skill_cardchosen.kezhuandingce = function(self, who)
	local handcards = sgs.QList2Table(who:getHandcards())
	local player = self.player
	if who:hasFlag("bestdingcered") then
		for _, c in sgs.qlist(who:getCards("h")) do
			if c:isRed() then
				return c:getId()
			end
		end
	else
		for _, c in sgs.qlist(who:getCards("h")) do
			if c:isBlack() then
				return c:getId()
			end
		end
	end
	return handcards[1]
end

local function aizhuanJfNames(player)
	local aps = player:getAliveSiblings()
	aps:append(player)
	local ption = ""
	for _, p in sgs.list(aps) do
		for _, s in sgs.list(p:getSkillList()) do
			if s:isAttachedLordSkill() then continue end
			ption = ption .. s:getDescription()
		end
	end
	local names = {}
	for c = 0, sgs.Sanguosha:getCardCount() - 1 do
		c = sgs.Sanguosha:getEngineCard(c)
		if c:getTypeId() > 2 or table.contains(names, c:objectName())
			or player:getMark(c:getType() .. "kezhuanzhenfeng-PlayClear") > 0 then
			continue
		end
		if string.find(ption, "【" .. sgs.Sanguosha:translate(c:objectName()) .. "】")
			and (c:isNDTrick() or c:isKindOf("BasicCard")) and (not c:isKindOf("kezhuan_ying"))
		then
			table.insert(names, c:objectName())
		end
	end
	return names
end

function aizhuandummyCard(name, suit, number)
	name = name or "slash"
	local c = sgs.Sanguosha:cloneCard(name)
	if c
	then
		if suit then c:setSuit(suit) end
		if number then c:setNumber(number) end
		c:deleteLater()
		return c
	end
end

local kezhuanzhenfeng = {}
kezhuanzhenfeng.name = "kezhuanzhenfeng"
table.insert(sgs.ai_skills, kezhuanzhenfeng)
kezhuanzhenfeng.getTurnUseCard = function(self)
	local yes = 0
	for c, p in sgs.list(aizhuanJfNames(self.player)) do
		c = aizhuandummyCard(p)
		c:setSkillName("kezhuanzhenfeng")
		if c:isAvailable(self.player)
		then
			yes = 1
			break
		end
	end
	if (yes == 1) or (self.player:getMark("aizhenfengtimes-PlayClear") < 2) then
		--if (self.player:getMark("aizhenfengtimes-PlayClear") < 2) then
		local choices = {}
		for d, p in sgs.list(aizhuanJfNames(self.player)) do
			d = aizhuandummyCard(p)
			d:setSkillName("kezhuanzhenfeng")
			if d:isAvailable(self.player)
			then
				table.insert(choices, p)
			end
		end
		if #choices < 1 then return end
		for _, choice in sgs.list(choices) do
			local transcard = sgs.Sanguosha:cloneCard(choice)
			if (transcard:isKindOf("Dongzhuxianji") and ((self.player:getHp() + self:getCardsNum("Peach") + self:getCardsNum("Analeptic")) < 3))
			then
				continue
			end
			transcard:setSkillName("kezhuanzhenfeng")
			transcard:deleteLater()
			local dummy = { isDummy = true, to = sgs.SPlayerList() }
			self:useCardByClassName(transcard, dummy)
			--self["use" .. sgs.ai_type_name[transcard:getTypeId() + 1] .. "Card"](self, transcard, dummy)
			if dummy.card and dummy.to
			then
				self.room:writeToConsole(transcard:objectName())
				self.kezhuanzhenfengData = dummy
				sgs.ai_skill_choice.kezhuanzhenfeng = choice
				if (dummy.to:isEmpty() and transcard:canRecast())
				then
					continue
				end
				sgs.ai_use_priority.kezhuancuifengCard = sgs.ai_use_priority[transcard:getClassName()]
				return sgs.Card_Parse("#kezhuanzhenfengCard:.:")
			end
		end
	end
end

sgs.ai_skill_use_func["#kezhuanzhenfengCard"] = function(card, use, self)
	if (self.player:getMark("aizhenfengtimes-PlayClear") < 2) then
		use.card = card
	end
end

sgs.ai_use_value.kezhuanzhenfengCard = 6.4
sgs.ai_use_priority.kezhuanzhenfengCard = 6.4

sgs.ai_skill_use["@@kezhuanzhenfeng"] = function(self, prompt)
	if (self.player:getMark("aizhenfengtimes-PlayClear") < 2) then
		local dummy = self.kezhuanzhenfengData
		if dummy.card and dummy.to
		then
			local tos = {}
			for _, p in sgs.list(dummy.to) do
				table.insert(tos, p:objectName())
			end
			return dummy.card:toString() .. "->" .. table.concat(tos, "+")
		end
	end
end

--[[
sgs.ai_skill_use["@@kezhuanzhenfeng"] = function(self, prompt)
	local id = self.player:getMark("kezhuanzhenfeng_id")
	if id < 0 then return "." end
	local pcard = sgs.Sanguosha:getEngineCard(id)
	local card = sgs.Sanguosha:cloneCard(pcard:objectName())
	card:setSkillName("kezhuanzhenfeng")
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
	card:deleteLater()
	return "."
end

local kezhuanzhenfeng_skill = {}
kezhuanzhenfeng_skill.name = "kezhuanzhenfeng"
table.insert(sgs.ai_skills, kezhuanzhenfeng_skill)
kezhuanzhenfeng_skill.getTurnUseCard = function(self)
	if (self.player:getMark("aizhenfengtimes-PlayClear") >= 2) then return end
	return sgs.Card_Parse("#kezhuanzhenfengCard:.:")
end

sgs.ai_skill_use_func["#kezhuanzhenfengCard"] = function(card, use, self)
    if (self.player:getMark("aizhenfengtimes-PlayClear") < 2) then
        use.card = card
	    return
	end
end

sgs.ai_skill_choice.kezhuanzhenfeng = function(self, choices, data)
    if table.contains(choices, "slash") then
		return "slash"
	end
end]]

--张任
sgs.ai_ajustdamage_from.kezhuanchuanxin = function(self, from, to, card, nature)
	if card and card:isKindOf("Slash") and card:getSkillName() == "kezhuanchuanxin"
	then
		return to:getMark("kezhuanchuanxin-Clear")
	end
end
sgs.ai_skill_askforyiji.kezhuanfuni = function(self, card_ids)
	return sgs.ai_skill_askforyiji.nosyiji(self, card_ids)
end

sgs.ai_skill_use["@@kezhuanchuanxin"] = function(self, prompt)
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards) -- 将列表转换为表
	self:sortByKeepValue(cards) -- 按保留值排序
	for _, h in sgs.list(cards) do
		if self.player:isJilei(h) then continue end
		local c = sgs.Sanguosha:cloneCard("slash")
		c:setSkillName("kezhuanchuanxin")
		c:addSubcard(h)
		local dummy = { isDummy = true, to = sgs.SPlayerList() }
		self:useBasicCard(c, dummy)
		if dummy.card and dummy.to
		then
			local tos = {}
			for _, p in sgs.list(dummy.to) do
				table.insert(tos, p:objectName())
			end
			return "#kezhuanchuanxinCard:" .. h:getId() .. ":->" .. table.concat(tos, "+")
		end
	end
end

--马超
sgs.ai_ajustdamage_from.kezhuanzhuiming = function(self, from, to, card, nature)
	if card and card:isKindOf("Slash") and card:hasFlag("kezhuanzhuimingcard")
	then
		return 1
	end
end
sgs.ai_skill_invoke.kezhuanzhuiming = function(self, data)
	if self.player:hasFlag("wantusezhuiming") then
		return true
	end
end

sgs.ai_skill_choice.kezhuanzhuiming = function(self, choices, data)
	if self.player:hasFlag("wantchooseblack") then
		return "zhuimingblack"
	else
		return "zhuimingred"
	end
end


sgs.ai_skill_cardchosen.kezhuanzhuiming = function(self, who)
	if self.player:hasFlag("wantchoosered") then
		local cards = sgs.QList2Table(who:getEquips())
		for i = 1, #cards, 1 do
			if (cards[i]:isRed()) then
				return cards[i]
			end
		end
		return who:getRandomHandCardId()
	elseif self.player:hasFlag("wantchooseblack") then
		local cards = sgs.QList2Table(who:getEquips())
		for i = 1, #cards, 1 do
			if (cards[i]:isBlack()) then
				return cards[i]
			end
		end
		--[[for _,c in sgs.qlist(who:getCards("e")) do
			if c:isBlack() then
				return c:getId()
			end
		end]]
		return who:getRandomHandCardId()
	end
end

sgs.ai_skill_discard.kezhuanzhuiming = function(self)
	local to_discard = {}
	if (self.player:hasFlag("machaomeipai")
			and (self:getCardsNum("Peach")
				+ self:getCardsNum("Analeptic") >= 2))
		or self.player:hasFlag("zhuimingnotdisany") then
		return self:askForDiscard("dummyreason", 999, 999, true, true)
	else
		for _, c in sgs.qlist(self.player:getCards("e")) do
			if c:isRed() and self.player:hasFlag("zhuimingrede") then
				table.insert(to_discard, c:getEffectiveId())
			elseif c:isBlack() and self.player:hasFlag("zhuimingblacke") then
				table.insert(to_discard, c:getEffectiveId())
			end
		end
		if self.player:hasFlag("readytodisblack") then
			for _, c in sgs.qlist(self.player:getCards("h")) do
				if c:isBlack() then
					table.insert(to_discard, c:getEffectiveId())
				end
			end
		end
		if self.player:hasFlag("readytodisred") then
			for _, c in sgs.qlist(self.player:getCards("h")) do
				if c:isRed() then
					table.insert(to_discard, c:getEffectiveId())
				end
			end
		end
		return to_discard
	end
	return self:askForDiscard("dummyreason", 999, 999, true, true)
end

--张飞
sgs.ai_ajustdamage_from.kezhuanbaohe = function(self, from, to, card, nature)
	if card and card:isKindOf("Slash") and card:getSkillName() == "kezhuanbaohe"
	then
		local x = self.room:getTag("kezhuanbaoheda"):toInt()
		return x
	end
end

sgs.ai_skill_discard.kezhuanbaohe = function(self)
	local to_discard = {}
	if self.player:hasFlag("wantusebaohe") then
		local cards = self.player:getCards("he")
		cards = sgs.QList2Table(cards)
		self:sortByKeepValue(cards)
		table.insert(to_discard, cards[1]:getEffectiveId())
		table.insert(to_discard, cards[2]:getEffectiveId())
		return to_discard
	else
		return self:askForDiscard("dummyreason", 999, 999, true, true)
	end
end

sgs.ai_skill_discard.kezhuanxushi = function(self)
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	table.insert(to_discard, cards[#cards]:getEffectiveId())
	return to_discard
end

local kezhuanxushi_skill = {}
kezhuanxushi_skill.name = "kezhuanxushi"
table.insert(sgs.ai_skills, kezhuanxushi_skill)
kezhuanxushi_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kezhuanxushiCard") then return end
	return sgs.Card_Parse("#kezhuanxushiCard:.:")
end

sgs.ai_skill_use_func["#kezhuanxushiCard"] = function(card, use, self)
	if (not self.player:hasUsed("#kezhuanxushiCard")) then --and (self.player:getOverflow() > 0) then
		self:sort(self.friends)
		local num = 0
		for _, friend in ipairs(self.friends) do
			if self:isFriend(friend) and (friend:objectName() ~= self.player:objectName()) and ((num <= 1) or (num < self:getOverflow())) then
				use.card = card
				if use.to then use.to:append(friend) end
				num = num + 1
			end
		end
		return
	end
end

--夏侯荣
sgs.ai_ajustdamage_to.kezhuanfenjian = function(self, from, to, card, nature)
	if to
	then
		return to:getMark("&kezhuanfenjianpeach-Clear") +
			to:getMark("&kezhuanfenjianduel-Clear")
	end
end

sgs.ai_skill_invoke.kezhuanfenjianex = function(self, data)
	if self.player:hasFlag("wantusefenjian") then
		return true
	end
end

local kezhuanfenjian_skill = {}
kezhuanfenjian_skill.name = "kezhuanfenjian"
table.insert(sgs.ai_skills, kezhuanfenjian_skill)
kezhuanfenjian_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kezhuanfenjianCard") then return end
	return sgs.Card_Parse("#kezhuanfenjianCard:.:")
end

sgs.ai_skill_use_func["#kezhuanfenjianCard"] = function(card, use, self)
	if not self.player:hasUsed("#kezhuanfenjianCard") then
		self:sort(self.enemies)
		self.enemies = sgs.reverse(self.enemies)
		local enys = sgs.SPlayerList()
		for _, enemy in ipairs(self.enemies) do
			if enys:isEmpty() then
				enys:append(enemy)
			else
				local yes = 1
				for _, p in sgs.qlist(enys) do
					if (enemy:getHp() + enemy:getHp() + enemy:getHandcardNum()) >= (p:getHp() + p:getHp() + p:getHandcardNum()) then
						yes = 0
					end
				end
				if (yes == 1) then
					enys:removeOne(enys:at(0))
					enys:append(enemy)
				end
			end
		end
		for _, enemy in sgs.qlist(enys) do
			local yes = 1
			if (self.player:getHp() <= 2) and (self.player:getHandcardNum() < 2)
				and (enemy:getHp() > 1) and (enemy:getHandcardNum() > 2) then
				yes = 0
			end
			if (self:objectiveLevel(enemy) > 0) and (yes == 1) then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.kezhuanfenjianCard = 8.5
sgs.ai_use_priority.kezhuanfenjianCard = 9.5
sgs.ai_card_intention.kezhuanfenjianCard = 80


local kezhuanguiji_skill = {}
kezhuanguiji_skill.name = "kezhuanguiji"
table.insert(sgs.ai_skills, kezhuanguiji_skill)
kezhuanguiji_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kezhuanguijiCard") or ((self.player:getMark("usekezhuanguiji") > 0)) then return end
	return sgs.Card_Parse("#kezhuanguijiCard:.:")
end

sgs.ai_skill_use_func["#kezhuanguijiCard"] = function(card, use, self)
	if not self.player:hasUsed("#kezhuanguijiCard") then
		local room = self.room
		self:sort(self.enemies)
		self.enemies = sgs.reverse(self.enemies)
		local enys = sgs.SPlayerList()
		local haveone = 0
		--[[for _,lb in sgs.qlist(room:getOtherPlayers(self.player)) do
			if self.player:isFriend(lb)
			and (lb:hasSkill("rende") or lb:hasSkill("tenyearrende"))
			and (lb:getHandcardNum() < self.player:getHandcardNum()) then
				enys:append(lb)
				use.card = card
				if use.to then use.to:append(enemy) end
				return	
			end
		end]]
		for _, enemy in ipairs(self.enemies) do
			if (enemy:getHandcardNum() < self.player:getHandcardNum()) then
				haveone = 1
				enys:append(enemy)
				break
			end
		end
		if (haveone == 1) then
			for _, enemy in ipairs(self.enemies) do
				local yes = 1
				for _, p in sgs.qlist(enys) do
					--如果比原有的手牌少，或者不满足条件，就不会加入
					if (enemy:getHandcardNum() < p:getHandcardNum())
						or (enemy:getHandcardNum() >= self.player:getHandcardNum()) then
						yes = 0
					end
				end
				if (yes == 1) then
					enys:removeOne(enys:at(0))
					enys:append(enemy)
				end
			end
			for _, enemy in sgs.qlist(enys) do
				local yingnum = 0
				local myyingnum = 0
				for _, c in sgs.qlist(enemy:getCards("h")) do
					if c:isKindOf("kezhuan_ying") then
						yingnum = yingnum + 1
					end
				end
				for _, cc in sgs.qlist(self.player:getCards("h")) do
					if cc:isKindOf("kezhuan_ying") then
						myyingnum = myyingnum + 1
					end
				end
				if ((enemy:getHandcardNum() - yingnum) > (self.player:getHandcardNum() - myyingnum)) then
					if (self:objectiveLevel(enemy) > 0) then
						use.card = card
						if use.to then use.to:append(enemy) end
						return
					end
				end
			end
		end
	end
end

sgs.ai_skill_invoke.kezhuanguijiagain = function(self, data)
	return self.player:hasFlag("wantuseguijiagain")
end

local kezhuanjiaohaoex_skill = {}
kezhuanjiaohaoex_skill.name = "kezhuanjiaohaoex"
table.insert(sgs.ai_skills, kezhuanjiaohaoex_skill)
kezhuanjiaohaoex_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kezhuanjiaohaoCard") then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local to_throw = sgs.IntList()
	for _, acard in ipairs(cards) do
		if acard:isKindOf("EquipCard") then
			to_throw:append(acard:getEffectiveId())
		end
	end
	card_id = to_throw:at(0)
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("#kezhuanjiaohaoCard:" .. card_id .. ":")
	end
end

sgs.ai_skill_use_func["#kezhuanjiaohaoCard"] = function(card, use, self)
	if (not self.player:hasUsed("#kezhuanjiaohaoCard")) then
		self:sort(self.friends)
		local num = 0

		local cards = self.player:getHandcards()
		cards = sgs.QList2Table(cards)
		self:sortByKeepValue(cards)

		for _, acard in ipairs(cards) do
			if acard:isKindOf("EquipCard") then
				local i = acard:getRealCard():toEquipCard():location()
				for _, friend in ipairs(self.friends_noself) do
					if self:isFriend(friend) and friend:hasSkill("kezhuanjiaohao") and not self:getSameEquip(acard, friend) and friend:hasEquipArea(i) and ((num <= 1) or (num < self:getOverflow())) then
						use.card = sgs.Card_Parse("#kezhuanjiaohaoCard:" .. acard:getEffectiveId() .. ":")
						if use.to then use.to:append(friend) end
						num = num + 1
					end
				end
			end
		end

		return
	end
end



--[[local kezhuanjiaohaoex_skill = {}
kezhuanjiaohaoex_skill.name = "kezhuanjiaohaoex"
table.insert(sgs.ai_skills, kezhuanjiaohaoex_skill)
kezhuanjiaohaoex_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#kezhuanjiaohaoCard") then return end
	local equips = {}
	for _, card in sgs.qlist(self.player:getHandcards()) do
		if card:getTypeId() == sgs.Card_TypeEquip then
			table.insert(equips, card)
		end
	end
	if #equips == 0 then return end
	--return sgs.Card_Parse("#kezhuanjiaohaoCard:.:")
	return sgs.Card_Parse("@kezhuanjiaohaoCard=.")
end

sgs.ai_skill_use_func.kezhuanjiaohaoCard = function(card, use, self)
	if not self.player:hasUsed("#kezhuanjiaohaoCard") then
		local equips = {}
		for _, card in sgs.qlist(self.player:getHandcards()) do
			if card:isKindOf("Armor") or card:isKindOf("Weapon") then
				if not self:getSameEquip(card) then
				elseif card:isKindOf("GudingBlade") and self:getCardsNum("Slash") > 0 then
					local HeavyDamage
					local slash = self:getCard("Slash")
					for _, enemy in ipairs(self.enemies) do
						if self.player:canSlash(enemy, slash, true) and not self:slashProhibit(slash, enemy) and
							self:slashIsEffective(slash, enemy) and not hasJueqingEffect(self.player, enemy) and enemy:isKongcheng() then
								HeavyDamage = true
								break
						end
					end
					if not HeavyDamage then table.insert(equips, card) end
				else
					table.insert(equips, card)
				end
			elseif card:getTypeId() == sgs.Card_TypeEquip then
				table.insert(equips, card)
			end
		end
	
		if #equips == 0 then return end
	
		local select_equip, target
		for _, friend in ipairs(self.friends_noself) do
			for _, equip in ipairs(equips) do
				local index = equip:getRealCard():toEquipCard():location()
				if not friend:hasEquipArea(index) then continue end
				if not self:getSameEquip(equip, friend) and self:hasSkills(sgs.need_equip_skill .. "|" .. sgs.lose_equip_skill, friend) then
					target = friend
					select_equip = equip
					break
				end
			end
			if target then break end
			for _, equip in ipairs(equips) do
				local index = equip:getRealCard():toEquipCard():location()
				if not friend:hasEquipArea(index) then continue end
				if not self:getSameEquip(equip, friend) then
					target = friend
					select_equip = equip
					break
				end
			end
			if target then break end
		end
	
		if not target then return end
		if use.to then
			use.to:append(target)
		end
		local kezhuanjiaohaoex = sgs.Card_Parse("@kezhuanjiaohaoCard=" .. select_equip:getId())
		--local kezhuanjiaohaoex = sgs.Card_Parse("#kezhuanjiaohaoCard:".. select_equip:getId())
		use.card = kezhuanjiaohaoex
	end
end

sgs.ai_card_intention.kezhuanjiaohaoCard = -80
sgs.ai_use_priority.kezhuanjiaohaoCard = sgs.ai_use_priority.RendeCard + 0.1
sgs.ai_cardneed.kezhuanjiaohaoCard = sgs.ai_cardneed.equip]]

-- --黄忠

-- sgs.ai_skill_use["@@kezhuanchuanxin"] = function(self, prompt)
-- 	local cards = self.player:getCards("he")
-- 	cards = sgs.QList2Table(cards) -- 将列表转换为表
-- 	self:sortByKeepValue(cards) -- 按保留值排序
-- 	for _, h in sgs.list(cards) do
-- 		if self.player:isJilei(h) then continue end
-- 		local c = sgs.Sanguosha:cloneCard("slash")
-- 		c:setSkillName("kezhuanchuanxin")
-- 		c:addSubcard(h)
-- 		local dummy = { isDummy = true, to = sgs.SPlayerList() }
-- 		self["use" .. sgs.ai_type_name[c:getTypeId() + 1] .. "Card"](self, c, dummy)
-- 		if dummy.card and dummy.to
-- 		then
-- 			local tos = {}
-- 			for _, p in sgs.list(dummy.to) do
-- 				table.insert(tos, p:objectName())
-- 			end
-- 			return "#kezhuanchuanxinCard:" .. h:getId() .. ":->" .. table.concat(tos, "+")
-- 		end
-- 	end
-- end

local kezhuancuifeng = {}
kezhuancuifeng.name = "kezhuancuifeng"
table.insert(sgs.ai_skills, kezhuancuifeng)
kezhuancuifeng.getTurnUseCard = function(self)
	if (self.player:getMark("@kezhuancuifeng") > 0) then
		local choices = {}
		for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
			local tcard = sgs.Sanguosha:getEngineCard(id)
			if tcard:isDamageCard()
				and self:getCardsNum(tcard:getClassName()) < 1
			then
				if table.contains(choices, tcard:objectName()) then continue end
				local transcard = sgs.Sanguosha:cloneCard(tcard:objectName())
				transcard:setSkillName("kezhuancuifeng")
				if not transcard:isAvailable(self.player) then continue end
				if (not tcard:isKindOf("DelayedTrick")) and (tcard:isSingleTargetCard()
						or ((self.player:aliveCount() == 2) and (tcard:isKindOf("AOE")))) then
					table.insert(choices, tcard:objectName())
				end
			end
		end
		if #choices < 1 then return end
		for _, choice in sgs.list(choices) do
			local transcard = sgs.Sanguosha:cloneCard(choice)
			transcard:setSkillName("kezhuancuifeng")
			local dummy = { isDummy = true, to = sgs.SPlayerList() }
			-- self["use" .. sgs.ai_type_name[transcard:getTypeId() + 1] .. "Card"](self, transcard, dummy)
			self:useCardByClassName(transcard, dummy)
			if dummy.card and dummy.to
			then
				self.kezhuancuifengData = dummy
				sgs.ai_skill_choice.kezhuancuifeng = choice
				if dummy.to:isEmpty() and transcard:canRecast() then continue end
				sgs.ai_use_priority.kezhuancuifengCard = sgs.ai_use_priority[transcard:getClassName()]
				return sgs.Card_Parse("#kezhuancuifengCard:.:")
			end
		end
	end
end

sgs.ai_skill_use_func["#kezhuancuifengCard"] = function(card, use, self)
	if (self.player:getMark("@kezhuancuifeng") > 0) then
		use.card = card
	end
end

sgs.ai_use_value.kezhuancuifengCard = 6.4
sgs.ai_use_priority.kezhuancuifengCard = 6.4

sgs.ai_skill_use["@@kezhuancuifeng"] = function(self, prompt)
	if (self.player:getMark("@kezhuancuifeng") > 0) then
		local dummy = self.kezhuancuifengData
		if dummy.card and dummy.to
		then
			local tos = {}
			for _, p in sgs.list(dummy.to) do
				table.insert(tos, p:objectName())
			end
			return dummy.card:toString() .. "->" .. table.concat(tos, "+")
		end
	end
end

local kezhuandengnan = {}
kezhuandengnan.name = "kezhuandengnan"
table.insert(sgs.ai_skills, kezhuandengnan)
kezhuandengnan.getTurnUseCard = function(self)
	if (self.player:getMark("@kezhuandengnan") > 0) then
		local choices = {}
		for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
			local tcard = sgs.Sanguosha:getEngineCard(id)
			if not tcard:isDamageCard() and tcard:isNDTrick()
				and self:getCardsNum(tcard:getClassName()) < 1
			then
				if table.contains(choices, tcard:objectName()) then continue end
				local transcard = sgs.Sanguosha:cloneCard(tcard:objectName())
				transcard:setSkillName("kezhuandengnan")
				if not transcard:isAvailable(self.player) then continue end
				table.insert(choices, tcard:objectName())
			end
		end
		if #choices < 1 then return end
		for _, choice in sgs.list(choices) do
			local transcard = sgs.Sanguosha:cloneCard(choice)
			transcard:setSkillName("kezhuandengnan")
			local dummy = { isDummy = true, to = sgs.SPlayerList() }
			-- self["use" .. sgs.ai_type_name[transcard:getTypeId() + 1] .. "Card"](self, transcard, dummy)
			self:useCardByClassName(transcard, dummy)
			if dummy.card and dummy.to
			then
				self.kezhuandengnanData = dummy
				sgs.ai_skill_choice.kezhuandengnan = choice
				if dummy.to:isEmpty() and transcard:canRecast() then continue end
				sgs.ai_use_priority.kezhuancuifengCard = sgs.ai_use_priority[transcard:getClassName()]
				return sgs.Card_Parse("#kezhuandengnanCard:.:")
			end
		end
	end
end

sgs.ai_skill_use_func["#kezhuandengnanCard"] = function(card, use, self)
	if (self.player:getMark("@kezhuandengnan") > 0) then
		use.card = card
	end
end

sgs.ai_use_value.kezhuandengnanCard = 6.4
sgs.ai_use_priority.kezhuandengnanCard = 6.4

sgs.ai_skill_use["@@kezhuandengnan"] = function(self, prompt)
	if (self.player:getMark("@kezhuandengnan") > 0) then
		local dummy = self.kezhuandengnanData
		if dummy.card and dummy.to
		then
			local tos = {}
			for _, p in sgs.list(dummy.to) do
				table.insert(tos, p:objectName())
			end
			return dummy.card:toString() .. "->" .. table.concat(tos, "+")
		end
	end
end



--娄圭

sgs.ai_skill_playerchosen.kezhuanshacheng = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isFriend(p) then
			theweak:append(p)
		end
	end
	for _, qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _, pp in sgs.qlist(theweaktwo) do
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

sgs.ai_skill_invoke.kezhuanshacheng = function(self, data)
	if self.player:hasFlag("wantuseshacheng") then
		return true
	end
end

sgs.ai_skill_invoke.kezhuanninghan = function(self, data)
	return true
end

--韩遂
sgs.ai_ajustdamage_from.kezhuanhuchou = function(self, from, to, card, nature)
	if to:getMark("&kezhuanhuchou") > 0 then
		return 1
	end
end

--张楚
kezhuanhuozhong_skill = {}
kezhuanhuozhong_skill.name = "kezhuanhuozhong"
table.insert(sgs.ai_skills, kezhuanhuozhong_skill)
kezhuanhuozhong_skill.getTurnUseCard = function(self)
	if self.player:containsTrick("supply_shortage") then return nil end
	local cards = self:addHandPile("he")
	local card
	self:sortByUseValue(cards, true)
	for _, acard in ipairs(cards) do
		if (acard:isBlack()) and (acard:isKindOf("BasicCard") or acard:isKindOf("EquipCard")) and (self:getDynamicUsePriority(acard) < sgs.ai_use_value.SupplyShortage) then
			card = acard
			break
		end
	end
	if not card then return nil end

	local card_id = card:getEffectiveId()
	return sgs.Card_Parse("#kezhuanhuozhongCard:" .. card_id .. ":")
end

kezhuanhuozhongex_skill = {}
kezhuanhuozhongex_skill.name = "kezhuanhuozhongex"
table.insert(sgs.ai_skills, kezhuanhuozhongex_skill)
kezhuanhuozhongex_skill.getTurnUseCard = function(self)
	if self.player:containsTrick("supply_shortage") then return nil end
	local cards = self:addHandPile("he")
	local card
	self:sortByUseValue(cards, true)
	for _, acard in ipairs(cards) do
		if (acard:isBlack()) and (acard:isKindOf("BasicCard") or acard:isKindOf("EquipCard")) and (self:getDynamicUsePriority(acard) < sgs.ai_use_value.SupplyShortage) then
			card = acard
			break
		end
	end
	if not card then return nil end

	local card_id = card:getEffectiveId()
	return sgs.Card_Parse("#kezhuanhuozhongCard:" .. card_id .. ":")
end

sgs.ai_skill_use_func["#kezhuanhuozhongCard"] = function(card, use, self)
	for _, p in ipairs(self.friends) do
		if p:hasSkill("kezhuanhuozhong") then
			if self.player:getJudgingArea():length() == 0 then
				use.card = card
				if use.to then
					use.to:append(self.player)
				end
			end
		end
	end
end

sgs.ai_skill_playerchosen.kezhuanhuozhong = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isFriend(p) then
			theweak:append(p)
		end
	end
	for _, qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _, pp in sgs.qlist(theweaktwo) do
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

sgs.ai_skill_invoke.kezhuanrihui = function(self, data)
	if self.player:hasFlag("wantuserihui") then
		return true
	end
end

--夏侯恩

sgs.ai_skill_invoke.kezhuanhujian = function(self, data)
	return true
end

local kezhuanshili_skill = {}
kezhuanshili_skill.name = "kezhuanshili"
table.insert(sgs.ai_skills, kezhuanshili_skill)
kezhuanshili_skill.getTurnUseCard = function(self)
	if (self.player:getMark("usekezhuanshili-PlayClear") > 0)
		or (self.player:hasFlag("usekezhuanshili")) then
		return nil
	end
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)

	local card
	for _, acard in ipairs(cards) do
		if (acard:isKindOf("EquipCard")) then
			card = acard
			break
		end
	end

	if not card then return nil end
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	local card_str = ("duel:kezhuanshili[%s:%s]=%d"):format(suit, number, card_id)
	local skillcard = sgs.Card_Parse(card_str)
	assert(skillcard)
	return skillcard
end

sgs.weapon_range.Kezhuan_chixueqingfeng = 2
sgs.ai_use_priority.Kezhuan_chixueqingfeng = 3


--庞统

local kezhuanyangming_skill = {}
kezhuanyangming_skill.name = "kezhuanyangming"
table.insert(sgs.ai_skills, kezhuanyangming_skill)
kezhuanyangming_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kezhuanyangmingCard") or (not self.player:canPindian()) then return end
	return sgs.Card_Parse("#kezhuanyangmingCard:.:")
end

sgs.ai_skill_use_func["#kezhuanyangmingCard"] = function(card, use, self)
	if (not self.player:hasUsed("#kezhuanyangmingCard"))
		and (not self.player:isKongcheng()) then
		self:sort(self.enemies)
		self.enemies = sgs.reverse(self.enemies)
		local enys = sgs.SPlayerList()
		for _, enemy in ipairs(self.enemies) do
			if (self.player:canPindian(enemy, true)) then
				if enys:isEmpty() then
					enys:append(enemy)
				else
					local yes = 1
					for _, p in sgs.qlist(enys) do
						if (enemy:getHp() + enemy:getHp() + enemy:getHandcardNum()) >= (p:getHp() + p:getHp() + p:getHandcardNum()) then
							yes = 0
						end
					end
					if (yes == 1) then
						enys:removeOne(enys:at(0))
						enys:append(enemy)
					end
				end
			end
		end
		for _, enemy in sgs.qlist(enys) do
			if (self:objectiveLevel(enemy) > 0) then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.kezhuanyangmingCard = 8.5
sgs.ai_use_priority.kezhuanyangmingCard = 9.5
sgs.ai_card_intention.kezhuanyangmingCard = 80

sgs.ai_skill_invoke.kezhuanyangming = function(self, data)
	return true
end

local kezhuanmanjuan = {}
kezhuanmanjuan.name = "kezhuanmanjuan"
table.insert(sgs.ai_skills, kezhuanmanjuan)
kezhuanmanjuan.getTurnUseCard = function(self)
	if self.player:isKongcheng() then
		for i = 0, sgs.Sanguosha:getCardCount() - 1 do
			local c = sgs.Sanguosha:getCard(i)
			if self.player:getMark(i .. "manjuanPile-Clear") > 0
				and self.player:getMark(c:getNumber() .. "manjuanNumber-Clear") < 1
				and c:isAvailable(self.player)
			then
				local dummy = { isDummy = true, to = sgs.SPlayerList() }
				--self["use" .. sgs.ai_type_name[c:getTypeId() + 1] .. "Card"](self, c, dummy)
				self:useCardByClassName(c, dummy)
				if dummy.card and dummy.to
				then
					self.kezhuanmanjuanAg = i
					self.kezhuanmanjuanData = dummy
					if dummy.to:isEmpty() and c:canRecast() then continue end
					sgs.ai_use_priority.kezhuanmanjuanCard = sgs.ai_use_priority[c:getClassName()]
					return sgs.Card_Parse("#kezhuanmanjuanCard:.:")
				end
			end
		end
	end
end

sgs.ai_skill_use_func["#kezhuanmanjuanCard"] = function(card, use, self)
	if self.player:isKongcheng() then
		use.card = card
	end
end

sgs.ai_use_value.kezhuanmanjuanCard = 6.4
sgs.ai_use_priority.kezhuanmanjuanCard = 6.4

sgs.ai_skill_askforag.kezhuanmanjuan = function(self, card_ids)
	for _, id in sgs.list(card_ids) do
		if id == self.kezhuanmanjuanAg
		then
			return id
		end
	end
end

sgs.ai_skill_use["@@kezhuanmanjuan"] = function(self, prompt)
	if self.player:isKongcheng() then
		local dummy = self.kezhuanmanjuanData
		if dummy.card and dummy.to
		then
			local tos = {}
			for _, p in sgs.list(dummy.to) do
				table.insert(tos, p:objectName())
			end
			return "#kezhuanmanjuanVsCard:.:@@kezhuanmanjuan->" .. table.concat(tos, "+")
		end
	end
end

function sgs.ai_cardsview.kezhuanmanjuan(self, class_name, player)
	if self.player:isKongcheng() then
		for i = 0, sgs.Sanguosha:getCardCount() - 1 do
			local c = sgs.Sanguosha:getCard(i)
			if player:getMark(i .. "manjuanPile-Clear") > 0
				and player:getMark(c:getNumber() .. "manjuanNumber-Clear") < 1
				and not player:isLocked(c) and c:isKindOf(class_name)
			then
				return "#kezhuanmanjuanVsCard:.:"
			end
		end
	end
end

--[[
	
function sgs.ai_cardsview.kezhuanmanjuan(self, class_name, player)
bug for askforpeach

sgs.ai_cardsview["se_chenyan"] = function(self, class_name, player)
	if sgs.Sanguosha:getCurrentCardUseReason() ~= sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then return end
	local classname2objectname = {
		["Slash"] = "slash",
		["Jink"] = "jink",
		["Peach"] = "peach",
		["Analeptic"] = "analeptic",
		["Nullification"] = "nullification",
		["FireSlash"] = "fire_slash",
		["ThunderSlash"] = "thunder_slash"
	}
	local name = classname2objectname[class_name]
	if not name then return end
	local no_have = true
	local cards = player:getCards("he")
	for _, id in sgs.qlist(player:getPile("wooden_ox")) do
		cards:prepend(sgs.Sanguosha:getCard(id))
	end
	for _, c in sgs.qlist(cards) do
		if c:isKindOf(class_name) then
			no_have = false
			break
		end
	end
	if not no_have or player:getMark("se_chenyan-Clear") ~= 0 then return end
	if class_name == "Peach" and player:getMark("Global_PreventPeach") > 0 then return end
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if player:getPile("wooden_ox"):length() > 0 then
		for _, id in sgs.qlist(player:getPile("wooden_ox")) do
			if not sgs.Sanguosha:getCard(id):isKindOf("Peach") then
				cards[1] = sgs.Sanguosha:getCard(id)
			end
		end
	end
	if #cards >= 2 then
		--if cards[1]:isKindOf("Peach") or cards[1]:isKindOf("Analeptic") then return end
		if cards[1]:isKindOf("Peach")
			or cards[1]:isKindOf("Analeptic")
			or (cards[1]:isKindOf("Jink") and self:getCardsNum("Jink") == 1)
			or (cards[1]:isKindOf("Slash") and self:getCardsNum("Slash") == 1)
			or cards[1]:isKindOf("Nullification")
			or cards[1]:isKindOf("SavageAssault")
			or cards[1]:isKindOf("ArcheryAttack")
			or cards[1]:isKindOf("Duel")
			or cards[1]:isKindOf("ExNihilo")
		then
			return
		end
		if cards[2]:isKindOf("Peach")
			or cards[2]:isKindOf("Analeptic")
			or (cards[2]:isKindOf("Jink") and self:getCardsNum("Jink") == 1)
			or (cards[2]:isKindOf("Slash") and self:getCardsNum("Slash") == 1)
			or cards[2]:isKindOf("Nullification")
			or cards[2]:isKindOf("SavageAssault")
			or cards[2]:isKindOf("ArcheryAttack")
			or cards[2]:isKindOf("Duel")
			or cards[2]:isKindOf("ExNihilo")
		then
			return
		end
	end

	--local suit = cards[1]:getSuitString()
	--local number = cards[1]:getNumberString()
	--local card_id = cards[1]:getEffectiveId()
	if player:hasSkill("se_chenyan") then
		--return (name..":se_chenyan[%s:%s]=%d"):format(suit, number, card_id)
		if #cards >= 2 then
			--return (name..":se_chenyan[%s:%s]=%d"):format(sgs.Card_NoSuit, -1, cards[1]:getEffectiveId() .."+".. cards[2]:getEffectiveId())
			return (name .. ":se_chenyan[%s:%s]=%d+%d"):format(sgs.Card_NoSuit, 0, cards[1]:getEffectiveId(),
				cards[2]:getEffectiveId())
		elseif not self:isWeak() then
			return string.format(name .. ":se_chenyan[%s:%s]=.", sgs.Card_NoSuit, 0)
		end
	end
	return
end
]]

--范疆张达

sgs.ai_skill_discard.kezhuanfushan = function(self, discard_num, min_num, optional, include_equip)
	if not (self.player:hasFlag("wantusefushan")) then
		return self:askForDiscard("dummyreason", 999, 999, true, true)
	else
		local to_discard = {}
		local yes = 0
		for _, c in sgs.qlist(self.player:getCards("h")) do
			if (c:isKindOf("Slash")) then
				table.insert(to_discard, c:getEffectiveId())
				yes = 1
				break
			end
		end
		if yes == 1 then
			return to_discard
		else
			return self:askForDiscard("dummyreason", 999, 999, true, true)
		end
	end
end
