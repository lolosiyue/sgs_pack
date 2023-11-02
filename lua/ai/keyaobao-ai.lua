--change

sgs.ai_skill_invoke.yaochangetupo = function(self, data)
	--[[local num = math.random(0,1)
	if (num == 0) then
	    return true
	else
		return false
	end]]
	return false
end

--张角

sgs.ai_skill_invoke.keyaotuzhong = function(self, data) 
	local num = math.random(0,1)
	if (num == 0) then
	    return true
	else
		return false
	end
end

sgs.ai_skill_playerchosen.keyaotuzhong = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isFriend(p) then
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

--界张角

sgs.ai_skill_invoke.kejieyaotuzhong = function(self, data) 
	return (math.random(0,2) ~= 1)
end

sgs.ai_skill_playerchosen.kejieyaotuzhong = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isFriend(p) then
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

--司马懿

sgs.ai_skill_invoke.keyaozhabing = function(self, data) 
	return (self.player:getHp() > 1) 
	or (self.player:getCardsNum("Peach") > 0)
	or (self.player:getCardsNum("Analeptic") > 0)
end

--界司马懿

sgs.ai_skill_invoke.kejieyaozhabing = function(self, data) 
	return (self.player:getHp() > 1) 
	or (self.player:getCardsNum("Peach") > 0)
	or (self.player:getCardsNum("Analeptic") > 0)
end


--小乔

local keyaoquwu_skill = {}
keyaoquwu_skill.name = "keyaoquwu"
table.insert(sgs.ai_skills, keyaoquwu_skill)
keyaoquwu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("keyaoquwuCard") then return end
	return sgs.Card_Parse("#keyaoquwuCard:.:")
end

sgs.ai_skill_use_func["#keyaoquwuCard"] = function(card, use, self)
    if not self.player:hasUsed("#keyaoquwuCard") then
        self:sort(self.enemies)
	    self.enemies = sgs.reverse(self.enemies)
		local enys = sgs.SPlayerList()
		for _, enemy in ipairs(self.enemies) do
			if self.player:inMyAttackRange(enemy) then
				if enys:isEmpty() then
					enys:append(enemy)
				else
					local yes = 1
					for _,p in sgs.qlist(enys) do
						if (enemy:getHp()+enemy:getHp()+enemy:getHandcardNum()) >= (p:getHp()+p:getHp()+p:getHandcardNum()) then
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
		for _,enemy in sgs.qlist(enys) do
			if self:objectiveLevel(enemy) > 0 then
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
	end
end

--[[sgs.ai_use_value.keyaoquwuCard = 8.5
sgs.ai_use_priority.keyaoquwuCard = 9.5
sgs.ai_card_intention.keyaoquwuCard = 80]]

local kejieyaoquwu_skill = {}
kejieyaoquwu_skill.name = "kejieyaoquwu"
table.insert(sgs.ai_skills, kejieyaoquwu_skill)
kejieyaoquwu_skill.getTurnUseCard = function(self)
	if (self.player:getMark("canusequwucishu") <= 0) then return end
	return sgs.Card_Parse("#kejieyaoquwuCard:.:")
end

sgs.ai_skill_use_func["#kejieyaoquwuCard"] = function(card, use, self)
    if (self.player:getMark("canusequwucishu") > 0) then
        self:sort(self.enemies)
	    self.enemies = sgs.reverse(self.enemies)
		local enys = sgs.SPlayerList()
		for _, enemy in ipairs(self.enemies) do
			if self.player:inMyAttackRange(enemy) and (enemy:getMark("&keyaoquwu") == 0) then
				if enys:isEmpty() then
					enys:append(enemy)
				else
					local yes = 1
					for _,p in sgs.qlist(enys) do
						if (enemy:getHp()+enemy:getHp()+enemy:getHandcardNum()) >= (p:getHp()+p:getHp()+p:getHandcardNum()) then
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
		for _,enemy in sgs.qlist(enys) do
			if self:objectiveLevel(enemy) > 0 then
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
	end
end

--[[sgs.ai_use_value.kejieyaoquwuCard = 8.5
sgs.ai_use_priority.kejieyaoquwuCard = 9.5
sgs.ai_card_intention.kejieyaoquwuCard = 80]]

sgs.ai_skill_invoke.kejieyaoquwutwo = function(self, data) 
	return true
end

sgs.ai_skill_invoke.kejieyaotongquetwo = function(self, data) 
	return true
end

sgs.ai_skill_discard.kejieyaotongquetwo = function(self, discard_num, min_num, optional, include_equip) 
	local to_discard = {}
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	table.insert(to_discard, cards[1]:getEffectiveId())
	return to_discard
end

--卞氏

sgs.ai_view_as.keyaojiahuo = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card:isBlack() then
		return ("collateral:keyaojiahuo[%s:%s]=%d"):format(suit, number, card_id)
	end
end

sgs.ai_cardneed.keyaojiahuo = function(to, card, self)
	return card:isBlack()
end

sgs.ai_skill_choice.keyaoyaohou = function(self, choices, data)
    if self.player:hasFlag("wantusekeyaoyaohou") and self.player:hasFlag("wantusekeyaoyaohoutwo") then return "huode" end
	return "mopai"
end

--吉平

local keyaoshidu_skill = {}
keyaoshidu_skill.name = "keyaoshidu"
table.insert(sgs.ai_skills, keyaoshidu_skill)
keyaoshidu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("keyaoshiduCard") then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local to_throw = sgs.IntList()
	for _, acard in ipairs(cards) do
		if (acard:getSuit() == sgs.Card_Spade) and
		(acard:isKindOf("BasicCard") 
		or acard:isKindOf("EquipCard")) then
			to_throw:append(acard:getEffectiveId())
		end
	end
	card_id = to_throw:at(0)
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("#keyaoshiduCard:"..card_id..":")
	end
end

sgs.ai_skill_use_func["#keyaoshiduCard"] = function(card, use, self)
	if not self.player:hasUsed("#keyaoshiduCard") then
        self:sort(self.enemies)
	    self.enemies = sgs.reverse(self.enemies)
		local enys = sgs.SPlayerList()
		for _, enemy in ipairs(self.enemies) do
			if (enemy:getMark("&keyaoshidu") == 0) then
				if enys:isEmpty() then
					enys:append(enemy)
				else
					local yes = 1
					for _,p in sgs.qlist(enys) do
						if (enemy:getHp()+enemy:getHp()+enemy:getHandcardNum()) >= (p:getHp()+p:getHp()+p:getHandcardNum()) then
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
		for _,enemy in sgs.qlist(enys) do
			if self:objectiveLevel(enemy) > 0 then
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
	end
end

sgs.ai_use_value.keyaoshiduCard = 8.5
sgs.ai_use_priority.keyaoshiduCard = 9.5
sgs.ai_card_intention.keyaoshiduCard = 80

function sgs.ai_cardneed.keyaoshidu(to, card)
	return (card:getSuit() == sgs.Card_Spade) and (card:isKindOf("BasicCard") or card:isKindOf("EquipCard"))
end

sgs.ai_view_as.keyaogongdu = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place ~= sgs.Player_PlaceSpecial and (card:isBlack() and not card:isEquipped()) and player:getPhase() == sgs.Player_NotActive
		and player:getMark("Global_PreventPeach") == 0 then
		return ("peach:keyaogongdu[%s:%s]=%d"):format(suit, number, card_id)
	end
end

sgs.keyaogongdu_suit_value = {
	heart = 6,
	diamond = 6
}

sgs.ai_cardneed.keyaogongdu = function(to, card)
	return (card:isBlack() and not card:isEquipped())
end

--界妖吉平

local kejieyaoshidu_skill = {}
kejieyaoshidu_skill.name = "kejieyaoshidu"
table.insert(sgs.ai_skills, kejieyaoshidu_skill)
kejieyaoshidu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kejieyaoshiduCard") then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local to_throw = sgs.IntList()
	for _, acard in ipairs(cards) do
		if 
		(acard:isKindOf("BasicCard") 
		or acard:isKindOf("EquipCard")) then
			to_throw:append(acard:getEffectiveId())
		end
	end
	card_id = to_throw:at(0)
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("#kejieyaoshiduCard:"..card_id..":")
	end
end

sgs.ai_skill_use_func["#kejieyaoshiduCard"] = function(card, use, self)
	if not self.player:hasUsed("#kejieyaoshiduCard") then
        self:sort(self.enemies)
	    self.enemies = sgs.reverse(self.enemies)
		local enys = sgs.SPlayerList()
		for _, enemy in ipairs(self.enemies) do
			if (enemy:getMark("&keyaoshidu") == 0) then
				if enys:isEmpty() then
					enys:append(enemy)
				else
					local yes = 1
					for _,p in sgs.qlist(enys) do
						if (enemy:getHp()+enemy:getHp()+enemy:getHandcardNum()) >= (p:getHp()+p:getHp()+p:getHandcardNum()) then
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
		for _,enemy in sgs.qlist(enys) do
			if self:objectiveLevel(enemy) > 0 then
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
	end
end

sgs.ai_use_value.kejieyaoshiduCard = 8.5
sgs.ai_use_priority.kejieyaoshiduCard = 9.5
sgs.ai_card_intention.kejieyaoshiduCard = 80

function sgs.ai_cardneed.kejieyaoshidu(to, card)
	return (card:isKindOf("BasicCard") or card:isKindOf("EquipCard"))
end

sgs.ai_view_as.kejieyaogongdu = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place ~= sgs.Player_PlaceSpecial and card:isBlack() 
		and player:getMark("Global_PreventPeach") == 0 then
		return ("peach:kejieyaogongdu[%s:%s]=%d"):format(suit, number, card_id)
	end
end

sgs.kejieyaogongdu_suit_value = {
	heart = 6,
	diamond = 6
}

sgs.ai_cardneed.kejieyaogongdu = function(to, card)
	return card:isBlack() 
end


--凌统

sgs.ai_skill_invoke.keyaozhongyi = function(self, data) 
	return true
end

--程昱

sgs.ai_skill_invoke.keyaoxieqin = function(self, data) 
	return self.player:hasFlag("wantusekeyaoxieqin")
end

sgs.ai_skill_playerchosen.keyaoxieqin = function(self, targets)
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

sgs.ai_skill_invoke.keyaoshiwei = function(self, data) 
	return true
end


sgs.ai_skill_invoke.keyaoxieqin = function(self, data) 
	return self.player:hasFlag("wantusekejieyaoxieqin")
end

sgs.ai_skill_playerchosen.wantusekejieyaoxieqin = function(self, targets)
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

sgs.ai_skill_invoke.kejieyaoshiwei = function(self, data) 
	return true
end
















