--change

sgs.ai_skill_invoke.shengchangetupo = function(self, data)
	--[[local num = math.random(0,1)
	if (num == 0) then
	    return true
	else
		return false
	end]]
	return false
end

--圣孙权

sgs.ai_skill_invoke.keshengxionglve = function(self, data)
	return true
end

sgs.ai_skill_invoke.keshengganen = function(self, data)
	return self.player:hasFlag("wantusekeshengganen")
end

sgs.ai_skill_invoke.kejieshengxionglve = function(self, data)
	return true
end

sgs.ai_skill_invoke.keshengganen = function(self, data)
	--[[local current = self.room:getCurrent()
	if self.player:isFriend(current) and current:isWeak() then
		return true
	else
		return false
	end]]
	return self.player:hasFlag("wantusekejieshengganen")
end

sgs.ai_skill_choice.kejieshengganen = function(self, choices, data)
    if self.player:isWeak() then return "huixue" end
	return "mopai"
end

--圣孙策

sgs.ai_skill_cardask["shenghuju-slash"] = function(self, data, pattern, target)
	local effect = data:toSlashEffect()
	if self:isFriend(effect.to) then return "." end
	if self.player:getCardCount() - 2 >= self.player:getHp()
		or self:needKongcheng() and self.player:getHandcardNum() > 0
		or self.player:hasSkill("kuanggu") and self.player:isWounded() and self.player:distanceTo(effect.to) == 1
		or effect.to:getHp() <= 2 and not hasBuquEffect(effect.to)
		or self:getOverflow() > 0
	then
		return self:getCardId("Slash")
	else
		return "."
	end
end

sgs.ai_skill_cardask["jieshenghuju-slash"] = function(self, data, pattern, target)
	local effect = data:toSlashEffect()
	if self:isFriend(effect.to) then return "." end
	if self.player:getCardCount() - 2 >= self.player:getHp()
		or self:needKongcheng() and self.player:getHandcardNum() > 0
		or self.player:hasSkill("kuanggu") and self.player:isWounded() and self.player:distanceTo(effect.to) == 1
		or effect.to:getHp() <= 2 and not hasBuquEffect(effect.to)
		or self:getOverflow() > 0
	then
		for _, c in sgs.list(self.player:getHandcards()) do
			if c:isRed() and c:isKindOf("Slash") then return c:toString() end
		end
		for _, c in sgs.list(self.player:getHandcards()) do
			if c:isRed()  then return c:toString() end
		end
		for _, c in sgs.list(self.player:getHandcards()) do
			if c:isKindOf("Slash")  then return c:toString() end
		end
	else
		return "."
	end
end

sgs.ai_skill_cardask["jieshenghujutwo-slash"] = function(self, data, pattern, target)
	local effect = data:toSlashEffect()
	if self:isFriend(effect.to) then return "." end
	if self.player:getCardCount() - 2 >= self.player:getHp()
		or self:needKongcheng() and self.player:getHandcardNum() > 0
		or self.player:hasSkill("kuanggu") and self.player:isWounded() and self.player:distanceTo(effect.to) == 1
		or effect.to:getHp() <= 2 and not hasBuquEffect(effect.to)
		or self:getOverflow() > 0
	then
		for _, c in sgs.list(self.player:getHandcards()) do
			if c:isRed() and c:isKindOf("Slash") then return c:toString() end
		end
		for _, c in sgs.list(self.player:getHandcards()) do
			if c:isRed()  then return c:toString() end
		end
		for _, c in sgs.list(self.player:getHandcards()) do
			if c:isKindOf("Slash")  then return c:toString() end
		end
	else
		return "."
	end
end

--圣甄姬

sgs.ai_skill_invoke.keshengliufeng = function(self, data)
	return true
end

sgs.ai_skill_choice.keshenghuixue = function(self, choices, data)
    if self.keshenghuixueChoice then return self.keshenghuixueChoice end
	return "huixue"
end


sgs.ai_choicemade_filter.skillChoice["keshenghuixue"] = function(self, player, promptlist)
	local choice = promptlist[#promptlist]
	for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if p:hasFlag("keshenghuixueTarget") then
			if choice == "huixue" then
				sgs.updateIntention(player, p, -80)
			else 
				sgs.updateIntention(player, p, 80)
			end
		end
	end
end


local keshenghuixue_skill = {}
keshenghuixue_skill.name = "keshenghuixue"
table.insert(sgs.ai_skills, keshenghuixue_skill)
keshenghuixue_skill.getTurnUseCard = function(self)
	if not self.player:canDiscard(self.player, "h") then return end
	if self.player:hasUsed("keshenghuixueCard")  then return end
	return sgs.Card_Parse("#keshenghuixueCard:.:")
end

sgs.ai_skill_use_func["#keshenghuixueCard"] = function(card, use, self)
    if not self.player:hasUsed("#keshenghuixueCard") then
		for _,p in ipairs(self.friends_noself)do
			if p:getHp() < getBestHp(p) and p:isMale() and p:canDiscard(p, "h") then
				use.card = sgs.Card_Parse("#keshenghuixueCard:.:")
				self.keshenghuixueChoice = "huixue"
				if use.to then use.to:append(p) end
				return
			end
		end
		
		for _,enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and self:damageIsEffective(enemy)
			and self.player:getHp() > enemy:getHp() and self.player:getHp() > 1 and enemy:canDiscard(enemy, "h")
			then
				self.keshenghuixueChoice = "shanghai"
				use.card = sgs.Card_Parse("#keshenghuixueCard:.:")
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_use_value.keshenghuixueCard = 8.5
sgs.ai_use_priority.keshenghuixueCard = 9.5
--sgs.ai_card_intention.keshenghuixueCard = 80

sgs.ai_skill_invoke.kejieshengliufeng = function(self, data)
	return true
end

sgs.ai_skill_invoke.keshengliufeng = function(self, data)
	return true
end

sgs.ai_skill_choice.kejieshenghuixue = function(self, choices, data)
    if self.player:hasFlag("huixuehuixue") then return "huixue" end
	return "shanghai"
end

local kejieshenghuixue_skill = {}
kejieshenghuixue_skill.name = "kejieshenghuixue"
table.insert(sgs.ai_skills, kejieshenghuixue_skill)
kejieshenghuixue_skill.getTurnUseCard = function(self)
	if ((self.player:getMark("&useshengshanghai")>0) and (self.player:getMark("&useshenghuixue")>0)) then return end
	return sgs.Card_Parse("#kejieshenghuixueCard:.:")
end

sgs.ai_skill_use_func["#kejieshenghuixueCard"] = function(card, use, self)
    if not ((self.player:getMark("&useshengshanghai")>0) and (self.player:getMark("&useshenghuixue")>0)) then
		self:sort(self.friends)
		local yes = 0
		for _, friend in ipairs(self.friends) do
			if self:isFriend(friend) and friend:isWounded() then
				yes = 1
				break
			end
		end
		if (self.player:getMark("&useshengshanghai")==0) and (self.player:getHp() > 1) then
			self:sort(self.enemies)
			self.enemies = sgs.reverse(self.enemies)
			local enys = sgs.SPlayerList()
			for _, enemy in ipairs(self.enemies) do
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
			for _,enemy in sgs.qlist(enys) do
				if self:objectiveLevel(enemy) > 0 then
					use.card = card
					if use.to then use.to:append(enemy) end
					return
				end
			end
		elseif (self.player:getMark("&useshenghuixue")==0) and ((yes == 1) or (self.player:getHp() <= 1)) then
			self:sort(self.friends)
			local yes = 0
			for _, friend in ipairs(self.friends) do
				if self:isFriend(friend) and friend:isWounded() then
					yes = 1
					use.card = card
					if use.to then use.to:append(friend) end
					return
				end
			end
			if (yes == 0) then
				for _, friend in ipairs(self.friends) do
					if self:isFriend(friend) then
						yes = 1
						use.card = card
						if use.to then use.to:append(friend) end
						return
					end
				end
			end
		end
	end
end

sgs.ai_use_value.kejieshenghuixueCard = 8.5
sgs.ai_use_priority.kejieshenghuixueCard = 9.5
sgs.ai_card_intention.kejieshenghuixueCard = 80


--圣赵云

local keshengzhuihun_skill = {}
keshengzhuihun_skill.name = "keshengzhuihun"
table.insert(sgs.ai_skills, keshengzhuihun_skill)
keshengzhuihun_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#keshengzhuihunCard") 
	or (not self.player:canDiscard(self.player, "h"))
	or (self.player:getMark("keshengzhuihun") ~= 0) then return end
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
		return sgs.Card_Parse("#keshengzhuihunCard:"..card_id..":")
	end	
end

sgs.ai_skill_use_func["#keshengzhuihunCard"] = function(card, use, self)
    if not (
	self.player:hasUsed("#keshengzhuihunCard") 
	or (not self.player:canDiscard(self.player, "h"))
	or (self.player:getMark("keshengzhuihun") ~= 0)) then
        use.card = card
	    return
	end
end

function sgs.ai_cardneed.keshengzhuihun(to, card, self)
	if self.player:hasUsed("#keshengzhuihunCard") then return false end
	return true
end

sgs.ai_use_value.keshengzhuihunCard = 8.5
sgs.ai_use_priority.keshengzhuihunCard = 9.5
sgs.ai_card_intention.keshengzhuihunCard = -80

sgs.ai_skill_invoke.keshengjiuzhu = function(self, data)
	local target = data:toPlayer()
	if canNiepan(target) then return false end
	if self.player:getRole() == "loyalist" and self:isWeak(self.room:getLord()) 
	and  target:objectName() ~= self.player:objectName()  then return false end
	return self:isFriend(target)
end
	

--界圣赵云


local kejieshengzhuihun_skill = {}
kejieshengzhuihun_skill.name = "kejieshengzhuihun"
table.insert(sgs.ai_skills, kejieshengzhuihun_skill)
kejieshengzhuihun_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#kejieshengzhuihunCard") then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local to_throw = sgs.IntList()
	for _, acard in ipairs(cards) do
		if acard:isKindOf("BasicCard") or acard:isKindOf("TrickCard") then
		    to_throw:append(acard:getEffectiveId())
		end
	end
	card_id = to_throw:at(0)
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("#kejieshengzhuihunCard:"..card_id..":")
	end	
end

sgs.ai_skill_use_func["#kejieshengzhuihunCard"] = function(card, use, self)
    if not self.player:hasUsed("#kejieshengzhuihunCard") then
        use.card = card
	    return
	end
end

function sgs.ai_cardneed.keshengzhuihun(to, card, self)
	if self.player:hasUsed("#kejieshengzhuihunCard") then return false end
	return true
end

sgs.ai_use_value.kejieshengzhuihunCard = 8.5
sgs.ai_use_priority.kejieshengzhuihunCard = 9.5
sgs.ai_card_intention.kejieshengzhuihunCard = -80

sgs.ai_skill_invoke.kejieshengqinggang = function(self, data)
	return self.player:hasFlag("wantusekejieshengqinggang")
end

sgs.ai_skill_invoke.kejieshengjiuzhu = function(self, data)
	return self.player:hasFlag("wantusekejieshengjiuzhu")
end

--圣郭嘉

sgs.ai_skill_invoke.keshengqizuo = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.keshengqizuo = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
		    return p 
		end
	end
	return nil
end

sgs.ai_skill_invoke.keshengxiangzhi = function(self, data)
	return true
end

--[[sgs.ai_skill_askforyiji.keshengxiangzhi = function(self, card_ids)
	return sgs.ai_skill_askforyiji.nosyiji(self, card_ids)
end]]
sgs.ai_skill_askforyiji.keshengxiangzhi = function(self, card_ids)
	local available_friends = {}
	for _, friend in ipairs(self.friends_noself) do
		if not friend:hasSkill("manjuan") and not self:isLihunTarget(friend) then table.insert(available_friends, friend) end
	end

	local toGive, allcards = {}, {}
	local keep
	for _, id in ipairs(card_ids) do
		local card = sgs.Sanguosha:getCard(id)
		if not keep and (isCard("Jink", card, self.player) or isCard("Analeptic", card, self.player)) then
			keep = true
		else
			table.insert(toGive, card)
		end
		table.insert(allcards, card)
	end

	local cards = #toGive > 0 and toGive or allcards
	self:sortByKeepValue(cards, true)
	local id = cards[1]:getId()

	local card, friend = self:getCardNeedPlayer(cards)
	if card and friend and table.contains(available_friends, friend) then return friend, card:getId() end

	if #available_friends > 0 then
		self:sort(available_friends, "handcard")
		for _, afriend in ipairs(available_friends) do
			if not self:needKongcheng(afriend, true) then
				return afriend, id
			end
		end
		self:sort(available_friends, "defense")
		return available_friends[1], id
	end
	return nil, -1
end

--界圣郭嘉

sgs.ai_skill_invoke.kejieshengqizuo = function(self, data)
	return true
end
sgs.ai_skill_playerchosen.kejieshengqizuo = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
		    return p 
		end
	end
	return nil
end

sgs.ai_skill_invoke.kejieshengxiangzhi = function(self, data)
	return true
end

--[[sgs.ai_skill_askforyiji.kejieshengxiangzhi = function(self, card_ids)
	return sgs.ai_skill_askforyiji.nosyiji(self, card_ids)
end]]
sgs.ai_skill_askforyiji.kejieshengxiangzhi = function(self, card_ids)
	local available_friends = {}
	for _, friend in ipairs(self.friends_noself) do
		if not friend:hasSkill("manjuan") and not self:isLihunTarget(friend) then table.insert(available_friends, friend) end
	end

	local toGive, allcards = {}, {}
	local keep
	for _, id in ipairs(card_ids) do
		local card = sgs.Sanguosha:getCard(id)
		if not keep and (isCard("Jink", card, self.player) or isCard("Analeptic", card, self.player)) then
			keep = true
		else
			table.insert(toGive, card)
		end
		table.insert(allcards, card)
	end

	local cards = #toGive > 0 and toGive or allcards
	self:sortByKeepValue(cards, true)
	local id = cards[1]:getId()

	local card, friend = self:getCardNeedPlayer(cards)
	if card and friend and table.contains(available_friends, friend) then return friend, card:getId() end

	if #available_friends > 0 then
		self:sort(available_friends, "handcard")
		for _, afriend in ipairs(available_friends) do
			if not self:needKongcheng(afriend, true) then
				return afriend, id
			end
		end
		self:sort(available_friends, "defense")
		return available_friends[1], id
	end
	return nil, -1
end


--程普

sgs.ai_skill_invoke.keshengtonggui = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.keshengtonggui = function(self, targets)
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

sgs.ai_skill_invoke.keshengfuchou = function(self, data)
	local current = self.room:getCurrent()
	if self.player:isEnemy(current) then
		return true
	else
		return false
	end
end

sgs.ai_skill_invoke.kejieshengtonggui = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.kejieshengtonggui = function(self, targets)
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


sgs.ai_skill_invoke.kejieshengfuchou = function(self, data)
	local current = self.room:getCurrent()
	if self.player:isEnemy(current) then
		return true
	else
		return false
	end
end


--公孙瓒

sgs.ai_skill_invoke.keshengyuma = function(self, data)
	return true
end


sgs.ai_skill_invoke.kejieshengyuma = function(self, data)
	return true
end

sgs.ai_skill_invoke.kejieshengliema = function(self, data)
	return self.player:hasFlag("wantusekejieshengliema")
end












