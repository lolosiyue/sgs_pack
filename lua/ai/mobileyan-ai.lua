
sgs.ai_skill_use["@@mobileyanyajun1"] = function(self,prompt)
	local valid = nil
	local destlist = self.room:getOtherPlayers(self.player)
    destlist = self:sort(destlist,"hp")
	for _,friend in sgs.list(destlist)do
		if valid then break end
		if self:isEnemy(friend)
		and self.player:canPindian(friend)
		then valid = friend:objectName() end
	end
	for _,friend in sgs.list(destlist)do
		if valid then break end
		if not self:isFriend(friend)
		and self.player:canPindian(friend)
		then valid = friend:objectName() end
	end
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	local strs = self.player:property("MobileYanYajunIds"):toString():split("+")
	for _,h in sgs.list(cards)do
		if table.contains(strs,""..h:getEffectiveId()) and h:getNumber()>9 and valid
		then return ("@MobileYanYajunCard="..h:getEffectiveId().."->"..valid) end
	end
end

sgs.ai_skill_use["@@mobileyanyajun2"] = function(self,prompt)
	local pdlist = self.player:getTag("mobileyanyajun_forAI"):toString():split("+")
	for c,id in sgs.list(pdlist)do
		c = sgs.Sanguosha:getCard(id)
		if c:isBlack()
		then
			return ("@MobileYanYajunPutCard="..id)
		end
	end
	return ("@MobileYanYajunPutCard="..pdlist[1])
end

addAiSkills("mobileyanzundi").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	if #cards<1 then return end
	return sgs.Card_Parse("@MobileYanZundiCard="..cards[1]:getEffectiveId())
end

sgs.ai_skill_use_func["MobileYanZundiCard"] = function(card,use,self)
	if #self.friends<1 then return end
	use.card = card
	self:sort(self.friends,"hp")
	if use.to then use.to:append(self.friends[1]) end
end

sgs.ai_use_value.MobileYanZundiCard = 5.4
sgs.ai_use_priority.MobileYanZundiCard = 4.8

sgs.ai_skill_discard.mobileyandifei = function(self)
	local cards = {}
    local handcards = sgs.QList2Table(self.player:getCards("h"))
    self:sortByKeepValue(handcards) -- 按保留值排序
   	for _,h in sgs.list(handcards)do
--		table.insert(cards,h:getEffectiveId())
	end
	return cards
end

addAiSkills("mobileyanyanjiao").getTurnUseCard = function(self)
	if self.player:getHandcardNum()<self.player:getMaxCards()
	or self.player:isKongcheng() then return end
	return sgs.Card_Parse("@MobileYanYanjiaoCard=.")
end

sgs.ai_skill_use_func["MobileYanYanjiaoCard"] = function(card,use,self)
	self:sort(self.friends_noself,"hp",true)
	for _,ep in sgs.list(self.friends_noself)do
		if ep:getHp()<2 then continue end
		use.card = card
		if use.to then use.to:append(ep) end
		return
	end
end

sgs.ai_use_value.MobileYanYanjiaoCard = 3.4
sgs.ai_use_priority.MobileYanYanjiaoCard = 1.8

sgs.ai_skill_choice.mobileyanyanjiao = function(self,choices)
	local items = choices:split("+")
	if table.contains(items,"club")
	then return "club" end
	if table.contains(items,"spade")
	then return "spade" end
end

sgs.ai_skill_invoke.mobileyanzhenting = function(self,data)
	local items = data:toString():split(":")
    local target = self.room:findPlayerByObjectName(items[2])
	if self:isFriend(target)
	then
		if string.find(items[4],"slash")
		then
	    	return self:isWeak(target)
			or self:getCardsNum("Jink","h")>0
			or self.player:getArmor()
		elseif string.find(items[4],"indulgence")
		then return target:getHandcardNum()>3
		elseif string.find(items[4],"supply_shortage")
		then return target:getHandcardNum()<3
		end
	end
end

addAiSkills("mobileyanjincui").getTurnUseCard = function(self)
	if #self.friends_noself>0
	and self:isWeak()
	then
		return sgs.Card_Parse("@MobileYanJincuiCard=.")
	end
end

sgs.ai_skill_use_func["@MobileYanJincuiCard"] = function(card,use,self)
	for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
		local n = 0
		for i=1,#self.friends_noself do
			i = p:getNextAlive(i)
			if self:isFriend(i)
			and i~=self.player
			then n = n+1
			else break end
		end
		if #self.friends_noself-n<2
		and not self:isFriend(p)
		then
			use.card = card
			if use.to then use.to:append(p) end
			return
		end
	end
end

sgs.ai_use_value.MobileYanJincuiCard = 2.4
sgs.ai_use_priority.MobileYanJincuiCard = -4.8

addAiSkills("mobileyanshangyi").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	if #cards<3 then return end
	return sgs.Card_Parse("@MobileYanShangyiCard="..cards[1]:getEffectiveId())
end

sgs.ai_skill_use_func["MobileYanShangyiCard"] = function(card,use,self)
	self:sort(self.enemies,"handcard",true)
	for _,ep in sgs.list(self.enemies)do
		if ep:getHandcardNum()>self.player:getHandcardNum()
		or ep:getHandcardNum()>1
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.MobileYanShangyiCard = 9.4
sgs.ai_use_priority.MobileYanShangyiCard = 4.8





