--曹操

sgs.ai_skill_invoke.kejianxiong = function(self, data)
	return true
end

sgs.ai_skill_use["@@kejianxiong"] = function(self, prompt)
	local id = self.player:getMark("kejianxiong-PlayClear") - 1
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


--赵云
local kexianglong_skill = {}
kexianglong_skill.name = "kexianglong"
table.insert(sgs.ai_skills, kexianglong_skill)
kexianglong_skill.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	for _, id in sgs.qlist(self.player:getHandPile()) do
		table.insert(cards, sgs.Sanguosha:getCard(id))
	end
	self:sortByUseValue(cards, true)

	for _, c in ipairs(cards) do
		if c:isKindOf("Analeptic") then
			return sgs.Card_Parse(("peach:kexianglong[%s:%s]=%d"):format(c:getSuitString(), c:getNumberString(),
				c:getEffectiveId()))
		end
	end

	for _, c in ipairs(cards) do
		if c:isKindOf("Peach") then
			return sgs.Analeptic_IsAvailable(self.player) and
				sgs.Card_Parse(("analeptic:kexianglong[%s:%s]=%d"):format(c:getSuitString(), c:getNumberString(),
					c:getEffectiveId()))
		end
	end

	for _, c in ipairs(cards) do
		if c:isKindOf("Jink") then
			return sgs.Card_Parse(("slash:kexianglong[%s:%s]=%d"):format(c:getSuitString(), c:getNumberString(),
				c:getEffectiveId()))
		end
	end
end

sgs.ai_view_as.kexianglong = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place == sgs.Player_PlaceHand then
		if card:isKindOf("Jink") then
			return ("slash:kexianglong[%s:%s]=%d"):format(suit, number, card_id)
		elseif card:isKindOf("Slash") then
			return ("jink:kexianglong[%s:%s]=%d"):format(suit, number, card_id)
		elseif card:isKindOf("Peach") then
			return ("analeptic:kexianglong[%s:%s]=%d"):format(suit, number, card_id)
		elseif card:isKindOf("Analeptic") then
			return ("peach:kexianglong[%s:%s]=%d"):format(suit, number, card_id)
		end
	end
end

sgs.kexianglong_keep_value = sgs.longdan_keep_value

local keliezhen_skill = {}
keliezhen_skill.name = "keliezhen"
table.insert(sgs.ai_skills, keliezhen_skill)
keliezhen_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("keliezhenCard") then return end
	return sgs.Card_Parse("#keliezhenCard:.:")
end

sgs.ai_skill_use_func["#keliezhenCard"] = function(card, use, self)
	if not self.player:hasUsed("#keliezhenCard") then
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
			if self:objectiveLevel(enemy) > 0 then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.keliezhenCard = 8.5
sgs.ai_use_priority.keliezhenCard = 9.5
sgs.ai_card_intention.keliezhenCard = 80

sgs.ai_skill_playerchosen.kelongxiang = function(self, targets)
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


--孙尚香

sgs.ai_skill_playerchosen.kexiaoji = function(self, targets)
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

sgs.ai_skill_choice.kexiaoji = function(self, choices, data)
	if self.player:hasFlag("xiaojichoosehuixue") then return "huixue" end
	return "shouhui"
end

--曹婴

sgs.ai_skill_discard.ketwopaomu = function(self, discard_num, min_num, optional, include_equip)
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if self.player:hasFlag("wantusepaomu") then
		table.insert(to_discard, cards[1]:getEffectiveId())
		return to_discard
	else
		return self:askForDiscard("dummyreason", 999, 999, true, true)
	end
end


local kequshang_skill = {}
kequshang_skill.name = "kequshang"
table.insert(sgs.ai_skills, kequshang_skill)
kequshang_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kequshangCard") then return end
	return sgs.Card_Parse("#kequshangCard:.:")
end

sgs.ai_skill_use_func["#kequshangCard"] = function(card, use, self)
	if not self.player:hasUsed("#kequshangCard") then
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
			if self:objectiveLevel(enemy) > 0 then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.kequshangCard = 8.5
sgs.ai_use_priority.kequshangCard = 9.5
sgs.ai_card_intention.kequshangCard = 80


--徐庶

sgs.ai_skill_playerchosen.kexiajue = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
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


local kexiajuetwo_skill = {}
kexiajuetwo_skill.name = "kexiajuetwo"
table.insert(sgs.ai_skills, kexiajuetwo_skill)
kexiajuetwo_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kexiajuetwoCard") then return end
	return sgs.Card_Parse("#kexiajuetwoCard:.:")
end

sgs.ai_skill_use_func["#kexiajuetwoCard"] = function(card, use, self)
	if not self.player:hasUsed("#kexiajuetwoCard") then
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
			if self:objectiveLevel(enemy) > 0 then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.kexiajuetwoCard = 8.5
sgs.ai_use_priority.kexiajuetwoCard = 9.5
sgs.ai_card_intention.kexiajuetwoCard = 80

sgs.ai_skill_playerchosen.kedianzhen = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
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

--大乔

local keguose_skill = {}
keguose_skill.name = "keguose"
table.insert(sgs.ai_skills, keguose_skill)
keguose_skill.getTurnUseCard = function(self)
	if ((self.player:getMark("useliulilbss-Clear") > 0) and (self.player:getMark("useliuliqzpdq-Clear") > 0)) then return end
	if (self.player:getMark("useliulilbss-Clear") == 0) then
		local cards = self.player:getCards("he")
		for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
			local c = sgs.Sanguosha:getCard(id)
			cards:prepend(c)
		end
		cards = sgs.QList2Table(cards)

		self:sortByUseValue(cards, true)
		local card = nil
		local has_weapon, has_armor = false, false

		for _, acard in ipairs(cards) do
			if acard:isKindOf("Weapon") and not (acard:getSuit() == sgs.Card_Diamond) then has_weapon = true end
		end

		for _, acard in ipairs(cards) do
			if acard:isKindOf("Armor") and not (acard:getSuit() == sgs.Card_Diamond) then has_armor = true end
		end

		for _, acard in ipairs(cards) do
			if (acard:getSuit() == sgs.Card_Diamond) and ((self:getUseValue(acard) < sgs.ai_use_value.Indulgence) or inclusive) then
				local shouldUse = true

				if acard:isKindOf("Armor") then
					if not self.player:getArmor() then
						shouldUse = false
					elseif self.player:hasEquip(acard) and not has_armor and self:evaluateArmor() > 0 then
						shouldUse = false
					end
				end

				if acard:isKindOf("Weapon") then
					if not self.player:getWeapon() then
						shouldUse = false
					elseif self.player:hasEquip(acard) and not has_weapon then
						shouldUse = false
					end
				end

				if shouldUse then
					card = acard
					break
				end
			end
		end

		if not card then return nil end
		return sgs.Card_Parse("#keguoseCard:" .. card:getEffectiveId() .. ":")
	end
	if (self.player:getMark("useliuliqzpdq-Clear") == 0) then
		return sgs.Card_Parse("#keguoseCard:.:")
	end
end


sgs.ai_skill_use_func["#keguoseCard"] = function(card, use, self)
	local id = card:getEffectiveId()
	if (self.player:getMark("useliulilbss-Clear") == 0) and (id >= 0) then
		local indulgence = sgs.Sanguosha:cloneCard("Indulgence")
		indulgence:addSubcard(id)
		if not self.player:isLocked(indulgence) then
			sgs.ai_use_priority.keguoseCard = sgs.ai_use_priority.Indulgence
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useCardIndulgence(indulgence, dummy_use)
			if dummy_use.card and dummy_use.to:length() > 0 then
				use.card = card
				if use.to then use.to:append(dummy_use.to:first()) end
				return
			end
		end
	elseif (self.player:getMark("useliuliqzpdq-Clear") == 0) and (id < 0) then
		self:sort(self.friends)
		local yes = 0
		for _, friend in ipairs(self.friends) do
			if self:isFriend(friend) then
				if (friend:getJudgingArea():length() > 0) and (friend:objectName() ~= self.player:objectName()) then
					use.card = card
					if use.to then use.to:append(friend) end
					yes = 1
					return
				end
			end
		end
		if (yes == 0) then
			for _, friend in ipairs(self.friends) do
				if self:isFriend(friend) and (friend:objectName() ~= self.player:objectName()) then
					use.card = card
					if use.to then use.to:append(friend) end
					return
				end
			end
		end
	end
end

sgs.ai_use_priority.keguoseCard = 5.5
sgs.ai_use_value.keguoseCard = 5
sgs.ai_card_intention.keguoseCard = -60

function sgs.ai_cardneed.keguose(to, card)
	return card:getSuit() == sgs.Card_Diamond
end

sgs.keguose_suit_value = {
	diamond = 3.9
}


--刘谌

sgs.ai_skill_choice.kenewwenxiang = function(self, choices, data)
	if self.player:hasFlag("wenxiangget") then
		return "get"
	else
		return "noget"
	end
end

local kenewwenxiang_skill = {}
kenewwenxiang_skill.name = "kenewwenxiang"
table.insert(sgs.ai_skills, kenewwenxiang_skill)
kenewwenxiang_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kenewwenxiangCard") then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local to_throw = sgs.IntList()
	for _, acard in ipairs(cards) do
		if acard:isRed() then
			to_throw:append(acard:getEffectiveId())
		end
	end
	card_id = to_throw:at(0)
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("#kenewwenxiangCard:" .. card_id .. ":")
	end
end


sgs.ai_skill_use_func["#kenewwenxiangCard"] = function(card, use, self)
	if not self.player:hasUsed("#kenewwenxiangCard") then
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
			if self:objectiveLevel(enemy) > 0 then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.kenewwenxiangCard = 8.5
sgs.ai_use_priority.kenewwenxiangCard = 9.5
sgs.ai_card_intention.kenewwenxiangCard = 80

function sgs.ai_cardneed.kenewwenxiang(to, card)
	return card:isRed()
end

--曹睿

sgs.ai_skill_playerchosen.kehuituo = function(self, targets)
	self:sort(self.friends, "defense")
	return self.friends[1]
end

sgs.ai_skill_use["@@kemingjianusevs"] = function(self, prompt)
	local id = self.player:getMark("kemingjianusevs-PlayClear") - 1
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

sgs.ai_skill_invoke.kexingshuai = function(self, data)
	return true
end

sgs.ai_skill_choice.xingshuai_choice = function(self, choices, data)
	if self.player:hasFlag("helpcaorui") then
		return "huifu"
	else
		return "no"
	end
end


--王基
sgs.ai_skill_playerchosen.kenewqizhi = function(self, targets)
	self:updatePlayers()
	local targets = sgs.QList2Table(targets)
	for _, target in ipairs(targets) do
		if self:isEnemy(target) and hasManjuanEffect(target) and not target:isNude() then
			return target
		end
	end
	for _, target in ipairs(targets) do
		if self:isFriend(target) and not hasManjuanEffect(target) and self:needToThrowCard(target, "he", false, false, true) then
			return target
		end
	end
	for _, target in ipairs(targets) do
		if self:isEnemy(target) and (self:getDangerousCard(target) or self:keepWoodenOx(target)) then return target end
		if self:isEnemy(target) and self:getValuableCard(target) and not self:doNotDiscard(target, "e")
			and not target:hasSkills(sgs.notActive_cardneed_skill) then
			return target
		end
	end
	for _, target in ipairs(targets) do
		if target:objectName() == self.player:objectName() then
			local cards = sgs.QList2Table(self.player:getCards("he"))
			for _, c in ipairs(cards) do
				if not self:keepCard(c, self.player) then return target end
			end
		end
	end
	return nil
end

sgs.ai_skill_invoke.kenewqizhi = function(self, data)
	return self.player:hasFlag("qizhiletmopai")
end

local keyanzhu_skill = {}
keyanzhu_skill.name = "keyanzhu"
table.insert(sgs.ai_skills, keyanzhu_skill)
keyanzhu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("keyanzhuCard") then return end
	return sgs.Card_Parse("#keyanzhuCard:.:")
end

sgs.ai_skill_use_func["#keyanzhuCard"] = function(card, use, self)
	if not self.player:hasUsed("#keyanzhuCard") then
		local room = self.room
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

		local all = room:getOtherPlayers(self.player)
		local enys = sgs.SPlayerList()
		for _, p in sgs.qlist(all) do
			if self:isEnemy(p) and (not enys:contains(p)) and (enys:length() < math.max(1, self.player:getLostHp())) then
				enys:append(p)
			end
		end
		if (enys:length() > 0) then
			for _, p in sgs.qlist(enys) do
				use.card = card
				if use.to then
					use.to:append(p)
				end
			end
		end
		return
	end
end

sgs.ai_use_value.keyanzhuCard = 8.5
sgs.ai_use_priority.keyanzhuCard = 9.5
sgs.ai_card_intention.keyanzhuCard = 80

sgs.ai_skill_choice.keyanzhu = function(self, choices, data)
	if self.player:hasFlag("yanzhuda") then
		return "damage"
	else
		local num = math.random(1, 2)
		if num == 1 then
			return "get"
		else
			return "damage"
		end
	end
end


local kezhaofu_skill = {}
kezhaofu_skill.name = "kezhaofu"
table.insert(sgs.ai_skills, kezhaofu_skill)
kezhaofu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kezhaofuCard") then return end
	return sgs.Card_Parse("#kezhaofuCard:.:")
end

sgs.ai_skill_use_func["#kezhaofuCard"] = function(card, use, self)
	if (self.player:getMark("@kezhaofu") > 0) and (self:getCardsNum("Slash") > 0) and not self.player:hasUsed("#kezhaofuCard") then
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
			if self:objectiveLevel(enemy) > 0 then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

--钟会

sgs.ai_skill_invoke.kezhenggong = function(self, data)
	return true
end

local kesuni_skill = {}
kesuni_skill.name = "kesuni"
table.insert(sgs.ai_skills, kesuni_skill)
kesuni_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kesuniCard") then return end
	return sgs.Card_Parse("#kesuniCard:.:")
end

sgs.ai_skill_use_func["#kesuniCard"] = function(card, use, self)
	if (self.player:getMark("&kegong") > 0) and not self.player:hasUsed("#kesuniCard") then
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
			if self:objectiveLevel(enemy) > 0 then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.kesuniCard = 8.5
sgs.ai_use_priority.kesuniCard = 9.5
sgs.ai_card_intention.kesuniCard = 80


--曹冲
local kenewchengxiang_skill = {}
kenewchengxiang_skill.name = "kenewchengxiang"
table.insert(sgs.ai_skills, kenewchengxiang_skill)
kenewchengxiang_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kenewchengxiangCard") then return end
	return sgs.Card_Parse("#kenewchengxiangCard:.:")
end

sgs.ai_skill_use_func["#kenewchengxiangCard"] = function(card, use, self)
	if not self.player:hasUsed("#kenewchengxiangCard") then
		local room = self.room
		local all = room:getOtherPlayers(self.player)
		local enys = sgs.SPlayerList()
		for _, p in sgs.qlist(all) do
			if self:isEnemy(p) then
				if (not p:isKongcheng()) and ((p:getHp() >= self.player:getHp()) or (p:getHandcardNum() >= self.player:getHandcardNum())) then
					enys:append(p)
				end
			end
		end
		if (enys:length() > 0) then
			for _, p in sgs.qlist(enys) do
				use.card = card
				if use.to then
					use.to:append(p)
				end
			end
		end
		return
	end
end

sgs.ai_use_value.kenewchengxiangCard = 8.5
sgs.ai_use_priority.kenewchengxiangCard = 9.5
sgs.ai_card_intention.kenewchengxiangCard = 80

sgs.ai_skill_invoke.keceyin = function(self, data)
	return self.player:hasFlag("wantuseceyin")
end

sgs.ai_skill_discard.keceyin = function(self, discard_num, min_num, optional, include_equip)
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if self.player:hasFlag("wantuseceyin") then
		table.insert(to_discard, cards[1]:getEffectiveId())
		return to_discard
	else
		return self:askForDiscard("dummyreason", 999, 999, true, true)
	end
end

--孙鲁育

sgs.ai_skill_invoke.keraoxi = function(self, data)
	return self.player:hasFlag("wantuseraoxi")
end

sgs.ai_skill_discard.keceyin = function(self, discard_num, min_num, optional, include_equip)
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if (self.player:getCardCount() > 1) and (self.player:getMark("useraoxi_lun") < 2) and self.player:hasFlag("wantuseraoxi") then
		table.insert(to_discard, cards[1]:getEffectiveId())
		return to_discard
	else
		return self:askForDiscard("dummyreason", 999, 999, true, true)
	end
end


sgs.ai_skill_choice.keraoxi = function(self, choices, data)
	if self.player:hasFlag("wantchoosecp") then
		return "skipmp"
	else
		return "skipcp"
	end
end



local kemumu_skill = {}
kemumu_skill.name = "kemumu"
table.insert(sgs.ai_skills, kemumu_skill)
kemumu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kemumuCard") then return end
	return sgs.Card_Parse("#kemumuCard:.:")
end

sgs.ai_skill_use_func["#kemumuCard"] = function(card, use, self)
	if not self.player:hasUsed("#kemumuCard") then
		self:sort(self.friends, "defense")
		self.friends = sgs.reverse(self.friends)
		for _, fri in ipairs(self.friends) do
			if (fri:objectName() ~= self.player:objectName()) and (fri:getJudgingArea():length() > 0) then
				use.card = card
				if use.to then use.to:append(fri) end
				return
			end
		end
		local enys = sgs.SPlayerList()
		self:sort(self.enemies)
		self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isNude() then
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
			if self:objectiveLevel(enemy) > 0 then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.kemumuCard = 8.5
sgs.ai_use_priority.kemumuCard = 9.5
sgs.ai_card_intention.kemumuCard = 80


--张星彩
local keqiangwu_skill = {}
keqiangwu_skill.name = "keqiangwu"
table.insert(sgs.ai_skills, keqiangwu_skill)
keqiangwu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("keqiangwuCard") then return end
	return sgs.Card_Parse("#keqiangwuCard:.:")
end

sgs.ai_skill_use_func["#keqiangwuCard"] = function(card, use, self)
	if not self.player:hasUsed("#keqiangwuCard") then
		use.card = card
		return
	end
end

sgs.ai_use_value.keqiangwuCard = 8.5
sgs.ai_use_priority.keqiangwuCard = 9.5
sgs.ai_card_intention.keqiangwuCard = 80

sgs.ai_skill_invoke.kexianjie = function(self, data)
	return self.player:hasFlag("wantusexianjie")
end

sgs.ai_skill_playerchosen.keqiangwu = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
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


--曹仁
sgs.ai_view_as.keyanzheng = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place == sgs.Player_PlaceHand then
		if card:isBlack() or card:isRed() then
			return ("nullification:keyanzheng[%s:%s]=%d"):format(suit, number, card_id)
		end
	end
end

sgs.ai_cardneed.keyanzheng = function(to, card, self)
	return card:isBlack() or card:isRed()
end

local keyugong_skill = {}
keyugong_skill.name = "keyugong"
table.insert(sgs.ai_skills, keyugong_skill)
keyugong_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#keyugongCard") then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if (self.player:getChangeSkillState("keyugong") == 2) then
		local yes = 0
		local to_throw = sgs.IntList()
		for _, acard in ipairs(cards) do
			if acard:isDamageCard() then
				to_throw:append(acard:getEffectiveId())
			end
		end
		card_id = to_throw:at(0)
		if not card_id then
			return nil
		else
			return sgs.Card_Parse("#keyugongCard:" .. card_id .. ":")
		end
	elseif (self.player:getChangeSkillState("keyugong") == 1) then
		local to_throw = sgs.IntList()
		for _, acard in ipairs(cards) do
			if not acard:isDamageCard() then
				to_throw:append(acard:getEffectiveId())
			end
		end
		card_id = to_throw:at(0) --(to_throw:length()-1)
		if not card_id then
			return nil
		else
			return sgs.Card_Parse("#keyugongCard:" .. card_id .. ":")
		end
	end
end

sgs.ai_skill_use_func["#keyugongCard"] = function(card, use, self)
	if not self.player:hasUsed("#keyugongCard") then
		use.card = card
		return
	end
end

function sgs.ai_cardneed.keyugongCard(to, card, self)
	if self.player:hasUsed("#keyugongCard") then return false end
	return true
end

sgs.ai_use_value.keyugongCard = 8.5
sgs.ai_use_priority.keyugongCard = 9.5
sgs.ai_card_intention.keyugongCard = 80

--邓艾

sgs.ai_skill_choice.kepihuang = function(self, choices, data)
	if (self.player:getMark("&ketian") <= 2) or (not self.player:hasSkill("kezhuxian")) then
		return "bozhong"
	else
		return "fengshou"
	end
end

sgs.ai_skill_choice.kezaoxian = function(self, choices, data)
	if (self:isWeak() and self.player:isWounded()) then
		return "recover"
	else
		return "draw"
	end
end

sgs.ai_skill_playerchosen.kezhuxian = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
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

--姜维

local ketiaoxin_skill = {}
ketiaoxin_skill.name = "ketiaoxin"
table.insert(sgs.ai_skills, ketiaoxin_skill)
ketiaoxin_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("ketiaoxinCard") then return end
	return sgs.Card_Parse("#ketiaoxinCard:.:")
end

sgs.ai_skill_use_func["#ketiaoxinCard"] = function(card, use, self)
	if not self.player:hasUsed("#ketiaoxinCard") then
		self:sort(self.enemies)
		self.enemies = sgs.reverse(self.enemies)
		local enys = sgs.SPlayerList()
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isNude() then
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
			if self:objectiveLevel(enemy) > 0 then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.ketiaoxinCard = 8.5
sgs.ai_use_priority.ketiaoxinCard = 9.5
sgs.ai_card_intention.ketiaoxinCard = 80

sgs.ai_skill_choice.kezhiji = function(self, choices, data)
	if (self:isWeak() and self.player:isWounded()) then
		return "recover"
	else
		return "draw"
	end
end

sgs.ai_skill_choice.kejwkuitian = function(self, choices, data)
	return "fromass"
end

sgs.ai_skill_invoke.kenewgonghuan = function(self, data)
	return ((self.player:hasFlag("wantusegonghuan")) or (self.player:hasFlag("wantusegonghuantwo")))
end


sgs.ai_skill_choice.kenewgonghuan = function(self, choices, data)
	if (self.player:hasFlag("wantchooserecovergh")) then
		return "recover"
	else
		return "mopai"
	end
end

local kenewsangzhi_skill = {}
kenewsangzhi_skill.name = "kenewsangzhi"
table.insert(sgs.ai_skills, kenewsangzhi_skill)
kenewsangzhi_skill.getTurnUseCard = function(self)
	--if self.player:hasUsed("kenewsangzhiCard") then return end
	return sgs.Card_Parse("#kenewsangzhiCard:.:")
end

sgs.ai_skill_use_func["#kenewsangzhiCard"] = function(card, use, self)
	--if not self.player:hasUsed("#kenewsangzhiCard") then
	local room = self.player:getRoom()
	local hpones = sgs.SPlayerList()
	local spones = sgs.SPlayerList()
	local ones = room:getOtherPlayers(self.player)
	for _, one in sgs.qlist(ones) do
		if (one:getHp() > self.player:getHp()) and (one:getMark("beselectsangzhi") == 0) then
			if hpones:isEmpty() then
				hpones:append(one)
			else
				local yes = 1
				for _, p in sgs.qlist(hpones) do
					if (p:getHp() >= one:getHp()) then
						yes = 0
						break
					end
				end
				if (yes == 1) then
					hpones:removeOne(hpones:at(0))
					hpones:append(one)
				end
			end
		end
		if (one:getHandcardNum() > self.player:getHandcardNum()) and (one:getMark("beselectsangzhi") == 0) then
			if spones:isEmpty() then
				spones:append(one)
			else
				local yes = 1
				for _, p in sgs.qlist(spones) do
					if (p:getHandcardNum() >= one:getHandcardNum()) then
						yes = 0
						break
					end
				end
				if (yes == 1) then
					spones:removeOne(spones:at(0))
					spones:append(one)
				end
			end
		end
	end
	if not hpones:isEmpty() then
		use.card = card
		if use.to then use.to:append(hpones:at(0)) end
		return
	end
	if not spones:isEmpty() then
		use.card = card
		if use.to then use.to:append(spones:at(0)) end
		return
	end
	--end
end

sgs.ai_use_value.kenewsangzhiCard = 8.5
sgs.ai_use_priority.kenewsangzhiCard = 9.5
sgs.ai_card_intention.kenewsangzhiCard = 80

local kenewzahuo_skill = {}
kenewzahuo_skill.name = "kenewzahuo"
table.insert(sgs.ai_skills, kenewzahuo_skill)
kenewzahuo_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kenewzahuoCard") or (self.player:getMark("@kecaoxie") < 3) then return end
	return sgs.Card_Parse("#kenewzahuoCard:.:")
end

sgs.ai_skill_use_func["#kenewzahuoCard"] = function(card, use, self)
	if (self.player:getMark("@kecaoxie") >= 3) and not self.player:hasUsed("#kenewzahuoCard") then
		use.card = card
		return
	end
end

sgs.ai_use_value.kenewzahuoCard = 8.5
sgs.ai_use_priority.kenewzahuoCard = 9.5
sgs.ai_card_intention.kenewzahuoCard = 80


sgs.ai_skill_choice.goodsclass = function(self, choices, data)
	local room = self.player:getRoom()
	local yes = 0
	for _, p in sgs.qlist(room:getOtherPlayers(self.player)) do
		if self.player:isEnemy(p) and self.player:inMyAttackRange(p)
			and (self:getCardsNum("Slash") > 0) then
			yes = 1
		end
	end
	if (self:isWeak() and self.player:isWounded() and (self.player:getMark("@kecaoxie") >= 5))
		or ((self.player:getMark("@kecaoxie") >= 3) and (sgs.Slash_IsAvailable(self.player)) and (self:getCardsNum("Slash") == 0)) then
		return "basiccard"
	elseif (yes == 0) and (self.player:getMark("@kecaoxie") >= 4) then
		return "equip"
	elseif (self.player:getMark("@kecaoxie") >= 4) and (not sgs.Slash_IsAvailable(self.player)) and (self:getCardsNum("Slash") > 0)
		or (self.player:getMark("@kecaoxie") >= 3) and (self.player:getHandcardNum() > self.player:getMaxCards() + 2) then
		return "effect"
	end
end

sgs.ai_skill_choice.liubeijibenpai = function(self, choices, data)
	local room = self.player:getRoom()
	if self:isWeak() and self.player:isWounded() and (self.player:getMark("@kecaoxie") >= 5) then
		return "peach"
	elseif (self.player:getMark("@kecaoxie") >= 3) and (sgs.Slash_IsAvailable(self.player)) and (self:getCardsNum("Slash") == 0) then
		return "slash"
	end
end

sgs.ai_skill_choice.liubeizhuangbei = function(self, choices, data)
	return "weapon"
end

sgs.ai_skill_choice.liubeitexiao = function(self, choices, data)
	local room = self.player:getRoom()
	if (self.player:getMark("@kecaoxie") >= 4) and (not sgs.Slash_IsAvailable(self.player)) and (self:getCardsNum("Slash") > 0) then
		return "addslash"
	elseif (self.player:getMark("@kecaoxie") >= 3) and (self.player:getHandcardNum() > self.player:getMaxCards() + 2) then
		return "maxhand"
	end
end

--孙权

sgs.ai_skill_choice.kezhiheng = function(self, choices, data)
	return "damo"
end

--卧龙诸葛亮

sgs.ai_skill_discard.kenewhuojispade = function(self)
	local to_discard = {}
	local yes = 0
	for _, c in sgs.qlist(self.player:getCards("h")) do
		if (c:getSuit() == sgs.Card_Spade) then
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
sgs.ai_skill_discard.kenewhuojidiamond = function(self)
	local to_discard = {}
	local yes = 0
	for _, c in sgs.qlist(self.player:getCards("h")) do
		if (c:getSuit() == sgs.Card_Diamond) then
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
sgs.ai_skill_discard.kenewhuojiclub = function(self)
	local to_discard = {}
	local yes = 0
	for _, c in sgs.qlist(self.player:getCards("h")) do
		if (c:getSuit() == sgs.Card_Club) then
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
sgs.ai_skill_discard.kenewhuojiheart = function(self)
	local to_discard = {}
	local yes = 0
	for _, c in sgs.qlist(self.player:getCards("h")) do
		if (c:getSuit() == sgs.Card_Heart) then
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

local kenewhuoji_skill = {}
kenewhuoji_skill.name = "kenewhuoji"
table.insert(sgs.ai_skills, kenewhuoji_skill)
kenewhuoji_skill.getTurnUseCard = function(self)
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)

	local card

	self:sortByUseValue(cards, true)

	for _, acard in ipairs(cards) do
		if acard:isRed() and not acard:isKindOf("Peach") and (self:getDynamicUsePriority(acard) < sgs.ai_use_value.FireAttack or self:getOverflow() > 0) then
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
					sgs.ai_use_priority.Slash = sgs.ai_use_priority.FireAttack + 0.1
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
	local card_str = ("fire_attack:kenewhuoji[%s:%s]=%d"):format(suit, number, card_id)
	local skillcard = sgs.Card_Parse(card_str)

	assert(skillcard)

	return skillcard
end

sgs.ai_cardneed.kenewhuoji = function(to, card, self)
	return to:getHandcardNum() >= 2 and card:isRed()
end

sgs.ai_view_as.kenewkanpo = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card:isBlack() then
		return ("nullification:kenewkanpo[%s:%s]=%d"):format(suit, number, card_id)
	end
end

sgs.ai_cardneed.kenewkanpo = function(to, card, self)
	return card:isBlack()
end

sgs.ai_skill_invoke.kenewbazhen = function(self, data)
	return true
end

--十常侍

--赵忠
sgs.ai_skill_invoke.kenewshiren = function(self, data)
	if self.player:hasFlag("wantuseshiren") then
		return true
	end
end

--孙璋
local kenewqieshui_skill = {}
kenewqieshui_skill.name = "kenewqieshui"
table.insert(sgs.ai_skills, kenewqieshui_skill)
kenewqieshui_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kenewqieshuiCard") then return end
	return sgs.Card_Parse("#kenewqieshuiCard:.:")
end

sgs.ai_skill_use_func["#kenewqieshuiCard"] = function(card, use, self)
	if not self.player:hasUsed("#kenewqieshuiCard") then
		local room = self.room
		local all = room:getOtherPlayers(self.player)
		local enys = sgs.SPlayerList()
		for _, p in sgs.qlist(all) do
			if self:isEnemy(p) then
				enys:append(p)
			end
		end
		if (enys:length() > 0) then
			for _, p in sgs.qlist(enys) do
				use.card = card
				if use.to and (use.to:length() < self.player:getMark("sunzhanglunci")) then
					use.to:append(p)
				end
			end
		end
		return
	end
end

sgs.ai_use_value.kenewqieshuiCard = 8.5
sgs.ai_use_priority.kenewqieshuiCard = 9.5
sgs.ai_card_intention.kenewqieshuiCard = 80

sgs.ai_skill_askforyiji.kenewqieshui = function(self, card_ids)
	return sgs.ai_skill_askforyiji.nosyiji(self, card_ids)
end


sgs.ai_skill_choice.kenewrongyuan = function(self, choices, data)
	local num = math.random(0, 1)
	if num == 0 then
		return "dis"
	else
		return "mopai"
	end
end

--夏恽
sgs.ai_skill_invoke.kenewbiting = function(self, data)
	return true
end

sgs.ai_skill_discard.kenewbiting = function(self)
	local to_discard = {}
	if self.player:hasFlag("bitingfriend") then
		for _, c in sgs.qlist(self.player:getCards("he")) do
			table.insert(to_discard, c:getEffectiveId())
		end
	else
		local cards = self.player:getCards("he")
		cards = sgs.QList2Table(cards)
		self:sortByKeepValue(cards)
		table.insert(to_discard, cards[1]:getEffectiveId())
	end
	return to_discard
end

--栗嵩
sgs.ai_skill_invoke.kenewmieyao = function(self, data)
	return self.player:hasFlag("wantusemieyao")
end

--郭胜
sgs.ai_skill_playerchosen.kenewyuanli = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
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

--高望

sgs.ai_skill_invoke.kenewsiji = function(self, data)
	return self.player:hasFlag("wantusekenewsiji")
end

--张让

local kenewwangmiu_skill = {}
kenewwangmiu_skill.name = "kenewwangmiu"
table.insert(sgs.ai_skills, kenewwangmiu_skill)
kenewwangmiu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kenewwangmiuCard") then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local to_throw = sgs.IntList()
	for _, acard in ipairs(cards) do
		if acard:isKindOf("BasicCard") or acard:isNDTrick() then
			to_throw:append(acard:getEffectiveId())
		end
	end
	card_id = to_throw:at(0)
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("#kenewwangmiuCard:" .. card_id .. ":")
	end
end


sgs.ai_skill_use_func["#kenewwangmiuCard"] = function(card, use, self)
	if not self.player:hasUsed("#kenewwangmiuCard") then
		self:sort(self.friends)
		for _, friend in ipairs(self.friends) do
			if self:isFriend(friend) and (self.player:objectName() ~= friend:objectName()) then
				use.card = card
				if use.to then use.to:append(friend) end
				return
			end
		end
	end
end

sgs.ai_use_value.kenewwangmiuCard = 8.5
sgs.ai_use_priority.kenewwangmiuCard = 9.5
sgs.ai_card_intention.kenewwangmiuCard = 80

function sgs.ai_cardneed.kenewwangmiuCard(to, card)
	return card:isKindOf("BasicCard") or card:isNDTrick()
end

--夏侯紫萼

sgs.ai_skill_invoke.kenewlvefeng = function(self, data)
	return self.player:hasFlag("wantusekenewlvefeng")
end


--王异

sgs.ai_skill_invoke.kenewzhenlietwo = function(self, data)
	if not self.player:isWounded() then
		return true
	else
		if (self.player:getHp() > 2) then
			local num = math.random(0, 1)
			if num == 0 then
				return true
			else
				return false
			end
		end
	end
end

function sgs.ai_skill_invoke.kenewzhenlie(self, data)
	local use = data:toCardUse()
	if not use.from or use.from:isDead() then return false end
	if self.role == "rebel" and sgs.ai_role[use.from:objectName()] == "rebel" and not use.from:hasSkill("jueqing")
		and self.player:getHp() == 1 and self:getAllPeachNum() < 1 then
		return false
	end

	if self:isEnemy(use.from) or (self:isFriend(use.from) and self.role == "loyalist" and not use.from:hasSkill("jueqing") and use.from:isLord() and self.player:getHp() == 1) then
		if use.card:isKindOf("Slash") then
			if not self:slashIsEffective(use.card, self.player, use.from) then return false end
			if self:hasHeavySlashDamage(use.from, use.card, self.player) then return true end

			local jink_num = self:getExpectedJinkNum(use)
			local hasHeart = false
			for _, card in ipairs(self:getCards("Jink")) do
				if card:getSuit() == sgs.Card_Heart then
					hasHeart = true
					break
				end
			end
			if self:getCardsNum("Jink") == 0
				or jink_num == 0
				or self:getCardsNum("Jink") < jink_num
				or (use.from:hasSkill("dahe") and self.player:hasFlag("dahe") and not hasHeart) then
				if use.card:isKindOf("NatureSlash") and self.player:isChained() and not self:isGoodChainTarget(self.player, use.from, nil, nil, use.card) then return true end
				if use.from:hasSkill("nosqianxi") and use.from:distanceTo(self.player) == 1 then return true end
				if self:isFriend(use.from) and self.role == "loyalist" and not use.from:hasSkill("jueqing") and use.from:isLord() and self.player:getHp() == 1 then return true end
				if (not (self:hasSkills(sgs.masochism_skill) or (self.player:hasSkill("tianxiang") and getKnownCard(self.player, self.player, "heart") > 0)) or use.from:hasSkill("jueqing"))
					and not self:doNotDiscard(use.from) then
					return true
				end
			end
		elseif use.card:isKindOf("AOE") then
			local from = use.from
			if use.card:isKindOf("SavageAssault") then
				local menghuo = self.room:findPlayerBySkillName("huoshou")
				if menghuo then from = menghuo end
			end

			local friend_null = 0
			for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
				if self:isFriend(p) then friend_null = friend_null + getCardsNum("Nullification", p, self.player) end
				if self:isEnemy(p) then friend_null = friend_null - getCardsNum("Nullification", p, self.player) end
			end
			friend_null = friend_null + self:getCardsNum("Nullification")
			local sj_num = self:getCardsNum(use.card:isKindOf("SavageAssault") and "Slash" or "Jink")

			if not self:hasTrickEffective(use.card, self.player, from) then return false end
			if not self:damageIsEffective(self.player, sgs.DamageStruct_Normal, from) then return false end
			if use.from:hasSkill("drwushuang") and self.player:getCardCount() == 1 and self:hasLoseHandcardEffective() then return true end
			if sj_num == 0 and friend_null <= 0 then
				if self:isEnemy(from) and from:hasSkill("jueqing") then return not self:doNotDiscard(from) end
				if self:isFriend(from) and self.role == "loyalist" and from:isLord() and self.player:getHp() == 1 and not from:hasSkill("jueqing") then return true end
				if (not (self:hasSkills(sgs.masochism_skill) or (self.player:hasSkill("tianxiang") and getKnownCard(self.player, self.player, "heart") > 0)) or use.from:hasSkill("jueqing"))
					and not self:doNotDiscard(use.from) then
					return true
				end
			end
		elseif self:isEnemy(use.from) then
			if use.card:isKindOf("FireAttack") and use.from:getHandcardNum() > 0 then
				if not self:hasTrickEffective(use.card, self.player) then return false end
				if not self:damageIsEffective(self.player, sgs.DamageStruct_Fire, use.from) then return false end
				if (self.player:hasArmorEffect("vine") or self.player:getMark("&kuangfeng") > 0) and use.from:getHandcardNum() > 3
					and not (use.from:hasSkill("hongyan") and getKnownCard(self.player, self.player, "spade") > 0) then
					return not self:doNotDiscard(use.from)
				elseif self.player:isChained() and not self:isGoodChainTarget(self.player, use.from) then
					return not self:doNotDiscard(use.from)
				end
			elseif (use.card:isKindOf("Snatch") or use.card:isKindOf("Dismantlement"))
				and self:getCardsNum("Peach") == self.player:getHandcardNum() and not self.player:isKongcheng() then
				if not self:hasTrickEffective(use.card, self.player) then return false end
				return not self:doNotDiscard(use.from)
			elseif use.card:isKindOf("Duel") then
				if self:getCardsNum("Slash") == 0 or self:getCardsNum("Slash") < getCardsNum("Slash", use.from, self.player) then
					if not self:hasTrickEffective(use.card, self.player) then return false end
					if not self:damageIsEffective(self.player, sgs.DamageStruct_Normal, use.from) then return false end
					return not self:doNotDiscard(use.from)
				end
			elseif use.card:isKindOf("TrickCard") and not use.card:isKindOf("AmazingGrace") then
				if not self:doNotDiscard(use.from) and self:needToLoseHp(self.player) then
					return true
				end
			end
		end
	end
	return false
end

sgs.ai_skill_invoke.kenewmiji = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.kenewmiji = function(self, targets)
	if (self.player:getHandcardNum() > 3) then
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
	end
	return nil
end

sgs.ai_skill_discard.kenewmiji = function(self, discard_num, min_num, optional, include_equip)
	local to_discard = {}
	--[[local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)]]
	if (self.player:getHandcardNum() <= 3) then
		return self:askForDiscard("dummyreason", 999, 999, true, true)
	else
		local dd = self.player:getHandcardNum()
		while (dd > 3)
		do
			dd = dd - 1
			local cards = self.player:getCards("h")
			cards = sgs.QList2Table(cards)
			self:sortByKeepValue(cards)
			table.insert(to_discard, cards[1]:getEffectiveId())
		end
		return to_discard
	end
end
