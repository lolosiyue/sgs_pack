
sgs.ai_skill_invoke.liandui = function(self,data)
	local items = data:toString():split(":")
	if #items>1
	then
        local target = BeMan(self.room,items[2])
    	return target and not self:isEnemy(target)
	end
end

sgs.ai_skill_invoke.lianduiother = function(self,data)
	local items = data:toString():split(":")
	if #items>1
	then
        local target = BeMan(self.room,items[2])
    	return target and self:isFriend(target)
	end
end

addAiSkills("biejun-give").getTurnUseCard = function(self)
	local cards = self.player:getCards("h")
	cards = self:sortByKeepValue(cards)
  	for _,p in sgs.list(self.room:findPlayersBySkillName("biejun"))do
		if #cards<2 or p:objectName()==self.player:objectName()
		then continue end
		self.biejun_to = p
		if self:isFriend(p)
		then
			if #cards>self.player:getMaxCards() and #self.toUse<1
			then return sgs.Card_Parse("@BiejunCard="..cards[1]:getEffectiveId()) end
		else
			local pcs = self:poisonCards(cards)
			if #pcs>0
			then
				return sgs.Card_Parse("@BiejunCard="..pcs[1]:getEffectiveId())
			end
			if self:isEnemy(p)
			and self:isWeak(p)
			and p:getHandcardNum()<3
			and #cards>self.player:getMaxCards()
			and #self.toUse>1
			then return sgs.Card_Parse("@BiejunCard="..cards[1]:getEffectiveId()) end
		end
	end
end

sgs.ai_skill_use_func["BiejunCard"] = function(card,use,self)
	if self.biejun_to
	then
		use.card = card
		if use.to then use.to:append(self.biejun_to) end
	end
end

sgs.ai_use_value.BiejunCard = 0.4
sgs.ai_use_priority.BiejunCard = 5.8

sgs.ai_skill_invoke.biejun = function(self,data)
	return not self.player:faceUp() or self:isWeak()
end

sgs.ai_can_damagehp.biejun = function(self,from,card,to)
    for _,id in sgs.list(to:handCards())do
		if to:getMark("biejunGetCard_"..id.."-Clear")>0
		then return end
	end
	return to:getHp()+self:getAllPeachNum()-self:ajustDamage(from,to,1,card)>1
	and self:canLoseHp(from,card,to)
	and self:isFriend(to)
	and not to:faceUp()
end

sgs.ai_skill_playerchosen.sangu = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard",true)
    for _,target in sgs.list(destlist)do
		self.sangu_to = target
		if self:isFriend(target)
		and target:getHandcardNum()>1
		then return target end
	end
    for _,target in sgs.list(destlist)do
		self.sangu_to = target
		if self:isEnemy(target)
		and target:getHandcardNum()>1
		then return target end
	end
    for _,target in sgs.list(destlist)do
		self.sangu_to = target
		if not self:isEnemy(target)
		and target:getHandcardNum()>1
		then return target end
	end
end

sgs.ai_skill_askforag.sangu = function(self,card_ids)
    local cards = {}
	for c,id in sgs.list(card_ids)do
		table.insert(cards,sgs.Sanguosha:getCard(id))
	end
    self:sortByKeepValue(cards,self:isFriend(self.sangu_to))
	for i,c in sgs.list(cards)do
		if self:isEnemy(self.sangu_to) and c:isAvailable(self.sangu_to)
		or self:isFriend(self.sangu_to) and not c:isAvailable(self.sangu_to)
		then continue end
		if self.player:getMark("SanguRecord_"..c:objectName().."-PlayClear")>0
		and i<#cards/3 then return c:getEffectiveId() end
	end
	for i,c in sgs.list(cards)do
		if self.player:getMark("SanguRecord_"..c:objectName().."-PlayClear")>0
		and i<#cards/3 then return c:getEffectiveId() end
	end
	return cards[1]:getEffectiveId()
end

sgs.ai_skill_invoke.bushilk = function(self,data)
	return self.player:getHandcardNum()>0
end

sgs.ai_skill_discard.koujing = function(self,max,min,optional)
	local to_cards = {}
	local cards = self.player:getCards("h")
	cards = self:sortByUseValue(cards)
	local touse = self:getTurnUse()
   	for c,h in sgs.list(cards)do
   		c = dummyCard()
		c:addSubcard(h)
		c:setSkillName("koujing")
		if table.contains(touse,h)
		and self:getUseValue(c)<self:getUseValue(h)
		then continue end
		local d = self:aiUseCard(c)
		if d.card and d.to:length()>0
		and #to_cards<=d.to:at(0):getHp()
		then table.insert(to_cards,h:getEffectiveId()) end
	end
	return to_cards
end

sgs.ai_skill_invoke.koujing = function(self,data)
	local ids = self.player:getTag("KoujingShowCards"):toIntList()
	if ids:length()>0
	then
		return self.player:getHp()+self:getCardsNum("Peach")+self:getCardsNum("Analeptic")<=ids:length()
		or self.player:getHandcardNum()>=ids:length()
	end
end























