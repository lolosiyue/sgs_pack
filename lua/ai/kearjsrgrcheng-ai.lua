--孙策
local kechengduxing_skill = {}
kechengduxing_skill.name = "kechengduxing"
table.insert(sgs.ai_skills, kechengduxing_skill)
kechengduxing_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kechengduxingCard") then return end
	return sgs.Card_Parse("#kechengduxingCard:.:")
end

sgs.ai_skill_use_func["#kechengduxingCard"] = function(card, use, self)
	if not self.player:hasUsed("#kechengduxingCard") then
		local room = self.room
		if (room:getTag("TurnLengthCount"):toInt() == 1) and (self.player:getRole() == "lord") then
			local all = room:getOtherPlayers(self.player)
			local willuse = 0
			for _, p in sgs.qlist(all) do
				if (p:getKingdom() == "wu") then
					willuse = willuse + 1
				end
			end
			local usenum = 0
			if (willuse >= 2) then
				for _, p in sgs.qlist(all) do
					use.card = card
					if use.to then
						use.to:append(p)
						usenum = usenum + 1
					end
				end
			end
			if (usenum == 0) then
				local enys = sgs.SPlayerList()
				for _, p in sgs.qlist(all) do
					if self:isEnemy(p) then
						if p:isKongcheng()
							or ((p:getHp() + p:getHp() + p:getHandcardNum()) < (self.player:getHp() + self.player:getHp() + self.player:getHandcardNum())) then
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
			end
			return
		else
			local all = room:getOtherPlayers(self.player)
			local enys = sgs.SPlayerList()
			for _, p in sgs.qlist(all) do
				if self:isEnemy(p) then
					if p:isKongcheng()
						or ((p:getHp() + p:getHp() + p:getHandcardNum()) < (self.player:getHp() + self.player:getHp() + self.player:getHandcardNum())) then
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

			--[[self:sort(self.enemies)
			self.enemies = sgs.reverse(self.enemies)
			for _, enemy in ipairs(self.enemies) do
				if self:objectiveLevel(enemy) > 0 then
					if enemy:isKongcheng()
					or ((enemy:getHp()+enemy:getHp()+enemy:getHandcardNum()) < (self.player:getHp()+self.player:getHp()+self.player:getHandcardNum())) then
						enys:append(enemy)
					end		
				end
			end
			if (enys:length() == 0) then return end
			for _, enemy in ipairs(self.enemies) do
				if self:objectiveLevel(enemy) > 0 then
					use.card = card
					if use.to then
						if enemy:isKongcheng()
						or ((enemy:getHp()+enemy:getHp()+enemy:getHandcardNum()) < (self.player:getHp()+self.player:getHp()+self.player:getHandcardNum())) then
							use.to:append(enemy)
						end
					end
					return 	
				end
			end]]
			return
		end
	end
end

sgs.ai_use_value.kechengduxingCard = 8.5
sgs.ai_use_priority.kechengduxingCard = 9.5
sgs.ai_card_intention.kechengduxingCard = 80

sgs.ai_skill_invoke.kechengzhasi = function(self, data)
	return true
end

sgs.ai_skill_invoke.keshengbashiusejink = function(self, data)
	return true
end

sgs.ai_skill_invoke.keshengbashiuseslash = function(self, data)
	return true
end

--陈登
local kechenglunshi_skill = {}
kechenglunshi_skill.name = "kechenglunshi"
table.insert(sgs.ai_skills, kechenglunshi_skill)
kechenglunshi_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kechenglunshiCard") then return end
	return sgs.Card_Parse("#kechenglunshiCard:.:")
end

sgs.ai_skill_use_func["#kechenglunshiCard"] = function(card, use, self)
	if not self.player:hasUsed("#kechenglunshiCard") then
		local room = self.room
		local mp = 0
		local qp = 0
		for _, one in sgs.qlist(room:getAllPlayers()) do
			mp = 0
			qp = 0
			for _, p in sgs.qlist(room:getOtherPlayers(one)) do
				if one:inMyAttackRange(p) then
					mp = mp + 1
				end
			end
			for _, p in sgs.qlist(room:getOtherPlayers(one)) do
				if p:inMyAttackRange(one) then
					qp = qp + 1
				end
			end
			if (one:getHandcardNum() >= 5) then mp = 0 end
			if (one:getHandcardNum() < 5) then mp = math.min(5 - one:getHandcardNum(), mp) end
			if (self:isFriend(one) and (mp >= qp)) or (self:isEnemy(one) and (mp < qp)) then
				use.card = card
				if use.to then use.to:append(one) end
				return
			end
		end
	end
end

sgs.ai_use_value.kechenglunshiCard = 8.5
sgs.ai_use_priority.kechenglunshiCard = 9.5
sgs.ai_card_intention.kechenglunshiCard = 80

--许贡
sgs.ai_skill_playerchosen.kechengyechou = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
			return p
		end
	end
	return nil
end

--吕布

local kechengqingjiao_skill = {}
kechengqingjiao_skill.name = "kechengqingjiao"
table.insert(sgs.ai_skills, kechengqingjiao_skill)
kechengqingjiao_skill.getTurnUseCard = function(self)
	if ((self.player:getMark("&useqingjiaochdj-Clear") > 0) and (self.player:getMark("&useqingjiaotxzf-Clear") > 0))
		--if self.player:hasUsed("kechengqingjiaoCard")
		or self.player:isNude()
		or #self.enemies == 0
		or (self.player:getKingdom() ~= "qun") then
		return
	end
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
		return sgs.Card_Parse("#kechengqingjiaoCard:" .. card_id .. ":")
	end
end

sgs.ai_skill_use_func["#kechengqingjiaoCard"] = function(card, use, self)
	if (self.player:getKingdom() == "qun") then
		if not (self.player:getMark("&useqingjiaochdj-Clear") > 0) then
			local room = self.room
			local all = room:getOtherPlayers(self.player)
			local enys = sgs.SPlayerList()
			for _, p in sgs.qlist(all) do
				if self:isEnemy(p) then
					if (p:getHandcardNum() < self.player:getHandcardNum())
						and (self.player:getMark("&useqingjiaochdj-Clear") < 1) then
						enys:append(p)
					end
				end
			end
			--挑选最脆弱的敌人
			local pre = sgs.SPlayerList()
			for _, enemy in sgs.qlist(enys) do
				if pre:isEmpty() then
					pre:append(enemy)
				else
					local yes = 1
					for _, p in sgs.qlist(pre) do
						if (enemy:getHp() + enemy:getHp() + enemy:getHandcardNum()) >= (p:getHp() + p:getHp() + p:getHandcardNum()) then
							yes = 0
						end
					end
					if (yes == 1) then
						pre:removeOne(pre:at(0))
						pre:append(enemy)
					end
				end
			end
			if (pre:length() > 0) then
				for _, p in sgs.qlist(pre) do
					use.card = card
					if use.to then
						use.to:append(p)
					end
					return
				end
			end
			return
		end
		if not (self.player:getMark("&useqingjiaotxzf-Clear") > 0) then
			local room = self.room
			local all = room:getOtherPlayers(self.player)
			local enys = sgs.SPlayerList()
			for _, p in sgs.qlist(all) do
				if self:isEnemy(p) then
					if (p:getHandcardNum() > self.player:getHandcardNum())
						and (self.player:distanceTo(p) <= 1)
						and (self.player:getMark("&useqingjiaotxzf-Clear") < 1)
					then
						enys:append(p)
					end
				end
			end
			--挑选最强大的敌人
			local pre = sgs.SPlayerList()
			for _, enemy in sgs.qlist(enys) do
				if pre:isEmpty() then
					pre:append(enemy)
				else
					local yes = 1
					for _, p in sgs.qlist(pre) do
						if (enemy:getHp() + enemy:getHp() + enemy:getHandcardNum()) < (p:getHp() + p:getHp() + p:getHandcardNum()) then
							yes = 0
						end
					end
					if (yes == 1) then
						pre:removeOne(pre:at(0))
						pre:append(enemy)
					end
				end
			end
			if (pre:length() > 0) then
				for _, p in sgs.qlist(pre) do
					use.card = card
					if use.to then
						use.to:append(p)
					end
					return
				end
			end
			return
		end

		--[[self:sort(self.enemies)
			self.enemies = sgs.reverse(self.enemies)
			for _, enemy in ipairs(self.enemies) do
				if self:objectiveLevel(enemy) > 0 then
					use.card = card
					if use.to then
						if ((enemy:getHandcardNum() < self.player:getHandcardNum())
						and (self.player:getMark("&useqingjiaochdj-Clear")<1))
						 then
							use.to:append(enemy)
							return
						end
					end
				end
			end
		elseif not (self.player:getMark("&useqingjiaotxzf-Clear")>0) then
			self:sort(self.enemies)
			self.enemies = sgs.reverse(self.enemies)
			for _, enemy in ipairs(self.enemies) do
				if self:objectiveLevel(enemy) > 0 then
					use.card = card
					if use.to then
						if ((enemy:getHandcardNum() > self.player:getHandcardNum())
						and (self.player:getMark("&useqingjiaotxzf-Clear")<1) and (self.player:distanceTo(enemy)<=1)) then
							use.to:append(enemy)
							return
						end
					end
				end
			end
		end]]
	end
end

sgs.ai_use_value.kechengqingjiaoCard = 8.5
sgs.ai_use_priority.kechengqingjiaoCard = 9.5
sgs.ai_card_intention.kechengqingjiaoCard = 80

sgs.ai_skill_cardask["_kecheng_chenhuodajie0"] = function(self, data, pattern, prompt)
	local c = sgs.Sanguosha:getCard(pattern)
	if c
	then
		if self:isWeak() and c:isKindOf("Analeptic")
			or self:getKeepValue(c, self.kept, true) > 5.3
		then
			return "."
		end
		return c:getEffectiveId()
	end
end

sgs.ai_cardneed.kechengqingjiao = function(to, card, self)
	return true
end







--许攸
--[[sgs.ai_skill_choice.kechengxuyou_ChooseKingdom = function(self, choices)
	local items = choices:split("+")
	if self.player:getKingdom() ~= "qun" then
	    return "qun"
	elseif self.player:getKingdom() ~= "wei" then
	    return "wei"
	end
end]]

sgs.ai_skill_invoke.lipanuseduel = function(self, data)
	return (self.player:getMark("wantuselipan-Clear") > 0)
end

sgs.ai_skill_invoke.kechenglipan = function(self, data)
	return true
end

local kechengqingxi_skill = {}
kechengqingxi_skill.name = "kechengqingxi"
table.insert(sgs.ai_skills, kechengqingxi_skill)
kechengqingxi_skill.getTurnUseCard = function(self)
	--if self.player:hasUsed("kechengqingxiCard") then return end
	return sgs.Card_Parse("#kechengqingxiCard:.:")
end

sgs.ai_skill_use_func["#kechengqingxiCard"] = function(card, use, self)
	if (self.player:getKingdom() == "qun") then
		local room = self.room
		local all = room:getOtherPlayers(self.player)
		local enys = sgs.SPlayerList()
		for _, p in sgs.qlist(all) do
			if self:isEnemy(p) then
				if not ((p:getArmor() ~= nil) and (p:getArmor():objectName() == "vine")) then
					if (p:getHandcardNum() < self.player:getHandcardNum())
						and (((self.player:getHandcardNum() - p:getHandcardNum()) < 2)
							or ((p:getHp() == 1) and ((self.player:getHandcardNum() - p:getHandcardNum()) < 3)))
						and (p:getMark("beusekechengqingxi-PlayClear") == 0) then
						enys:append(p)
					end
				end
			end
		end
		--挑选最脆弱的敌人
		local pre = sgs.SPlayerList()
		for _, enemy in sgs.qlist(enys) do
			if pre:isEmpty() then
				pre:append(enemy)
			else
				local yes = 1
				for _, p in sgs.qlist(pre) do
					if (enemy:getHp() + enemy:getHp() + enemy:getHandcardNum()) >= (p:getHp() + p:getHp() + p:getHandcardNum()) then
						yes = 0
					end
				end
				if (yes == 1) then
					pre:removeOne(pre:at(0))
					pre:append(enemy)
				end
			end
		end
		if (pre:length() > 0) then
			for _, p in sgs.qlist(pre) do
				use.card = card
				if use.to then
					use.to:append(p)
				end
				return
			end
		end
		return
	end
end

sgs.ai_use_value.kechengqingxiCard = 8.5
sgs.ai_use_priority.kechengqingxiCard = 9.5
sgs.ai_card_intention.kechengqingxiCard = 80


local kechengjinmie_skill = {}
kechengjinmie_skill.name = "kechengjinmie"
table.insert(sgs.ai_skills, kechengjinmie_skill)
kechengjinmie_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kechengjinmieCard") then return end
	return sgs.Card_Parse("#kechengjinmieCard:.:")
end

sgs.ai_skill_use_func["#kechengjinmieCard"] = function(card, use, self)
	if (not self.player:hasUsed("#kechengjinmieCard")) and (self.player:getKingdom() == "wei") then
		self:sort(self.enemies)
		self.enemies = sgs.reverse(self.enemies)
		local enys = sgs.SPlayerList()
		for _, enemy in ipairs(self.enemies) do
			if (enemy:getHandcardNum() > self.player:getHandcardNum()) then
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
		if (enys:length() > 0) then
			for _, enemy in sgs.qlist(enys) do
				if self:objectiveLevel(enemy) > 0 then
					use.card = card
					if use.to then use.to:append(enemy) end
					return
				end
			end
		end
	end
end

sgs.ai_use_value.kechengjinmieCard = 8.5
sgs.ai_use_priority.kechengjinmieCard = 9.5
sgs.ai_card_intention.kechengjinmieCard = 80

--张郃

sgs.ai_skill_choice.kechengzhanghe_ChooseKingdom = function(self, choices)
	local items = choices:split("+")
	return "wei"
end

sgs.ai_view_as.kechengxianzhu = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place ~= sgs.Player_PlaceSpecial and (player:getKingdom() == "wei") and card:isNDTrick() and not card:hasFlag("using") then
		return ("slash:kechengxianzhu[%s:%s]=%d"):format(suit, number, card_id)
	end
end

local kechengxianzhu_skill = {}
kechengxianzhu_skill.name = "kechengxianzhu"
table.insert(sgs.ai_skills, kechengxianzhu_skill)
kechengxianzhu_skill.getTurnUseCard = function(self, inclusive)
	if self.player:getKingdom() == "wei" then
		local cards = self.player:getCards("h")
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
				if card:isNDTrick() and card:isKindOf("TrickCard") and nuzhan_equip_e then
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
				if not enemy:hasArmorEffect("EightDiagram") and self.player:distanceTo(enemy) <= self.player:getAttackRange() then
					nuzhan_trick_e = true
					break
				end
			end
			for _, card in ipairs(cards) do
				if card:isNDTrick() and card:isKindOf("TrickCard") and nuzhan_trick_e then
					nuzhan_trick = true
					break
				end
			end
		end

		for _, card in ipairs(cards) do
			if card:isNDTrick() and not card:isKindOf("Slash") and not (nuzhan_equip or nuzhan_trick)
				and (not isCard("Peach", card, self.player) and not isCard("ExNihilo", card, self.player) and not useAll)
				and (not isCard("Crossbow", card, self.player) or disCrossbow)
				and (self:getUseValue(card) < sgs.ai_use_value.Slash or inclusive or sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, sgs.Sanguosha:cloneCard("slash")) > 0) then
				red_card = card
				break
			end
		end

		if nuzhan_equip then
			for _, card in ipairs(cards) do
				if card:isNDTrick() and card:isKindOf("EquipCard") then
					red_card = card
					break
				end
			end
		end

		if nuzhan_trick then
			for _, card in ipairs(cards) do
				if card:isNDTrick() and card:isKindOf("TrickCard") then
					red_card = card
					break
				end
			end
		end

		if red_card then
			local suit = red_card:getSuitString()
			local number = red_card:getNumberString()
			local card_id = red_card:getEffectiveId()
			local card_str = ("slash:kechengxianzhu[%s:%s]=%d"):format(suit, number, card_id)
			local slash = sgs.Card_Parse(card_str)

			assert(slash)
			return slash
		end
	end
end

function sgs.ai_cardneed.kechengxianzhu(to, card)
	return card:isNDTrick()
end

sgs.ai_use_priority["kechengxianzhu"] = 99

--关羽

local kechengnianen_skill = {}
kechengnianen_skill.name = "kechengnianen"
table.insert(sgs.ai_skills, kechengnianen_skill)
kechengnianen_skill.getTurnUseCard = function(self, inclusive)
	self:updatePlayers()
	self:sort(self.enemies, "defense")
	local handcards = sgs.QList2Table(self.player:getCards("h"))
	if self.player:getPile("wooden_ox"):length() > 0 then
		for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
			table.insert(handcards, sgs.Sanguosha:getCard(id))
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
	if (self.player:getMark("&bannianen-Clear") == 0) then
		if #basic_cards > 0 then
			table.insert(use_cards, basic_cards[1])
		end
		if #use_cards == 0 then return end
	end
	if self.player:isWounded() then
		return sgs.Card_Parse("#kechengnianen:" .. table.concat(use_cards, "+") .. ":" .. "peach")
	end
	local enys = sgs.SPlayerList()
	for _, enemy in ipairs(self.enemies) do
		enys:append(enemy)
	end
	if (enys:length() > 0) then
		for _, enemy in ipairs(self.enemies) do
			if self.player:canSlash(enemy) and self:isGoodTarget(enemy, self.enemies, nil) and self.player:inMyAttackRange(enemy) then
				local fire_slash = sgs.Sanguosha:cloneCard("fire_slash")
				local thunder_slash = sgs.Sanguosha:cloneCard("thunder_slash")
				local ice_slash = sgs.Sanguosha:cloneCard("ice_slash")
				local slash = sgs.Sanguosha:cloneCard("slash")
				if not self:slashProhibit(fire_slash, enemy, self.player) and self:slashIsEffective(fire_slash, enemy, self.player) then
					return sgs.Card_Parse("#kechengnianen:" .. table.concat(use_cards, "+") .. ":" .. "fire_slash")
				end
				if not self:slashProhibit(thunder_slash, enemy, self.player) and self:slashIsEffective(thunder_slash, enemy, self.player) then
					return sgs.Card_Parse("#kechengnianen:" .. table.concat(use_cards, "+") .. ":" .. "thunder_slash")
				end
				if not self:slashProhibit(ice_slash, enemy, self.player) and self:slashIsEffective(ice_slash, enemy, self.player) then
					return sgs.Card_Parse("#kechengnianen:" .. table.concat(use_cards, "+") .. ":" .. "ice_slash")
				end
				if not self:slashProhibit(slash, enemy, self.player) and self:slashIsEffective(slash, enemy, self.player) then
					return sgs.Card_Parse("#kechengnianen:" .. table.concat(use_cards, "+") .. ":" .. "slash")
				end
			end
		end
	end
end

sgs.ai_skill_use_func["#kechengnianen"] = function(card, use, self)
	if (self.player:getMark("&bannianen-Clear") == 0) then
		local userstring = card:toString()
		userstring = (userstring:split(":"))[4]
		local kechengnianencard = sgs.Sanguosha:cloneCard(userstring, card:getSuit(), card:getNumber())
		kechengnianencard:setSkillName("kechengnianen")
		self:useBasicCard(kechengnianencard, use)
		if not use.card then return end
		use.card = card
	end
end

sgs.ai_use_priority["kechengnianen"] = 9
sgs.ai_use_value["kechengnianen"] = 9

sgs.ai_view_as["kechengnianen"] = function(card, player, card_place, class_name)
	local classname2objectname = {
		["Slash"] = "slash",
		["Jink"] = "jink",
		["Peach"] = "peach",
		["Analeptic"] = "analeptic",
		["FireSlash"] = "fire_slash",
		["ThunderSlash"] = "thunder_slash",
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
			table.insert(handcards, sgs.Sanguosha:getCard(id))
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
	if (player:getMark("&bannianen-Clear") == 0) then
		if #basic_cards > 0 then
			table.insert(use_cards, basic_cards[1])
		end
		if #use_cards == 0 then return end
	end
	if (player:getMark("&bannianen-Clear") == 0) then
		if class_name == "Peach" then
			local dying = player:getRoom():getCurrentDyingPlayer()
			if dying and dying:getHp() < 0 then return end
			return (name .. ":kechengnianen[%s:%s]=%d"):format(sgs.Card_NoSuit, 0, use_cards[1])
		else
			return (name .. ":kechengnianen[%s:%s]=%d"):format(sgs.Card_NoSuit, 0, use_cards[1])
		end
	end
end

function sgs.ai_cardneed.kechengnianen(to, card, self)
	if (to:getMark("&bannianen-Clear") > 0) then return false end
	return true
end

--张辽

local kechengzhengbing_skill = {}
kechengzhengbing_skill.name = "kechengzhengbing"
table.insert(sgs.ai_skills, kechengzhengbing_skill)
kechengzhengbing_skill.getTurnUseCard = function(self)
	if (self.player:getMark("kechengzhengbing-Clear") >= 3) or (self.player:getKingdom() ~= "qun") or (self.player:isKongcheng()) then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if (self.player:getMark("kechengzhengbing-Clear") <= 1) then
		local yes = 0
		local to_throw = sgs.IntList()
		for _, acard in ipairs(cards) do
			if acard:isKindOf("Jink") then
				card_id = acard:getEffectiveId()
				yes = 1
				break
			end
		end
		if yes == 0 then
			for _, acard in ipairs(cards) do
				to_throw:append(acard:getEffectiveId())
			end
			card_id = to_throw:at(0) --(to_throw:length()-1)
		end
		if not card_id then
			return nil
		else
			return sgs.Card_Parse("#kechengzhengbingCard:" .. card_id .. ":")
		end
	else
		local to_throw = sgs.IntList()
		for _, acard in ipairs(cards) do
			to_throw:append(acard:getEffectiveId())
		end
		card_id = to_throw:at(0) --(to_throw:length()-1)
		if not card_id then
			return nil
		else
			return sgs.Card_Parse("#kechengzhengbingCard:" .. card_id .. ":")
		end
	end
end

sgs.ai_skill_use_func["#kechengzhengbingCard"] = function(card, use, self)
	if (self.player:getMark("kechengzhengbing-Clear") < 3) then
		use.card = card
		return
	end
end

function sgs.ai_cardneed.kechengzhengbing(to, card, self)
	if (self.player:getMark("kechengzhengbing-Clear") >= 3) then return false end
	return true
end

sgs.ai_use_value.kechengzhengbingCard = 8.5
sgs.ai_use_priority.kechengzhengbingCard = 9.5
sgs.ai_card_intention.kechengzhengbingCard = -80


--邹氏
sgs.ai_skill_invoke.kechengguyin = function(self, data)
	return (self.player:getMark("kechengguyinmale") >= 3)
end

sgs.ai_skill_invoke.kechengguyinturnover = function(self, data)
	local num = math.random(0, 1)
	return ((num == 1) and (self.player:hasFlag("willguyinturnover")))
end

--陶谦
sgs.ai_skill_invoke.kechengyirang = function(self, data)
	return self.player:hasFlag("aiuseyirang")
end

sgs.ai_skill_playerchosen.kechengyirang = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isFriend(p) and not (p:objectName() == self.player:objectName()) then
			return p
		end
	end
	return nil
end

--甄宓

sgs.ai_skill_invoke.kechengjixiang = function(self, data)
	return true
end

--二次元

sgs.ai_skill_invoke.kechengneifa = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.kechengneifa = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isFriend(p) then
			return p
		end
	end
	return nil
end

sgs.ai_skill_discard.kechengneifa = function(self)
	local to_discard = {}
	local slashnum = 0
	local ndnum = 0
	for _, c in sgs.qlist(self.player:getCards("h")) do
		if c:isKindOf("Slash") then
			slashnum = slashnum + 1
		elseif c:isNDTrick() then
			ndnum = ndnum + 1
		end
	end
	if (slashnum > ndnum) then
		for _, c in sgs.qlist(self.player:getCards("h")) do
			if c:isKindOf("Slash") then
				if (#to_discard == 0) then
					table.insert(to_discard, c:getEffectiveId())
				end
			end
		end
	elseif (slashnum < ndnum) then
		for _, c in sgs.qlist(self.player:getCards("h")) do
			if c:isNDTrick() then
				if (#to_discard == 0) then
					table.insert(to_discard, c:getEffectiveId())
				end
			end
		end
	end
	if (#to_discard == 0) then
		for _, c in sgs.qlist(self.player:getCards("h")) do
			if (#to_discard == 0) then
				table.insert(to_discard, c:getEffectiveId())
			end
		end
	end
	return to_discard
end
