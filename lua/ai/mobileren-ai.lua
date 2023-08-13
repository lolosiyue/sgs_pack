
addAiSkills("mobilerenrenshi").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	if #cards<2 then return end
	return sgs.Card_Parse("@MobileRenRenshiCard="..cards[1]:getEffectiveId())
end

sgs.ai_skill_use_func["MobileRenRenshiCard"] = function(card,use,self)
	self:sort(self.friends_noself,"hp",true)
	for _,ep in sgs.list(self.friends_noself)do
		if ep:getMark("mobilerenrenshi-PlayClear")<1
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.MobileRenRenshiCard = 2.4
sgs.ai_use_priority.MobileRenRenshiCard = 2.3

sgs.ai_skill_discard["@mobilerensheyi-give"] = function(self,x,n)
	local cards = {}
	local damage = self.player:getTag("mobilerensheyi_data"):toDamage()
    local handcards = sgs.QList2Table(self.player:getCards("he"))
    self:sortByKeepValue(handcards) -- 按保留值排序
   	for _,h in sgs.list(handcards)do
		if #cards>=n then break end
		if #handcards>n and self:isWeak(damage.to) and self:isFriend(damage.to)
		then table.insert(cards,h:getEffectiveId()) end
	end
	return cards
end

addAiSkills("mobilerenboming").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	if #cards<2 then return end
	return sgs.Card_Parse("@MobileRenBomingCard="..cards[1]:getEffectiveId())
end

sgs.ai_skill_use_func["MobileRenBomingCard"] = function(card,use,self)
	self:sort(self.friends_noself,"hand")
	local ejian_names = self.player:getTag("mobilerenejian_names"):toStringList()
	for _,ep in sgs.list(self.friends_noself)do
		if ep:getHandcardNum()<3
		or table.contains(ejian_names,ep:objectName())
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	self:sort(self.enemies,"hand",true)
	for _,ep in sgs.list(self.enemies)do
		if table.contains(ejian_names,ep:objectName()) then continue end
		if ep:getHandcardNum()>2
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.MobileRenBomingCard = 2.4
sgs.ai_use_priority.MobileRenBomingCard = 1.8

addAiSkills("mobilerenmuzhen").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	local toids = {}
  	for _,c in sgs.list(cards)do
		local can
		if #cards>2
		then
			for _,ep in sgs.list(self.friends_noself)do
				if ep:hasEquip() then can = true end
			end
			if not can then continue end
			table.insert(toids,c:getEffectiveId())
			if #toids>1 then return sgs.Card_Parse("@MobileRenMuzhenCard="..table.concat(toids,"+")) end
		end
		if self.player:getMark("mobilerenmuzhen_put-PlayClear")<1
		and c:isKindOf("EquipCard")
		and #cards>1
		then
			local index = c:getRealCard():toEquipCard():location()
			for _,ep in sgs.list(self.friends_noself)do
				if ep:getEquip(index)==nil then can = true end
			end
			if not can then continue end
			return sgs.Card_Parse("@MobileRenMuzhenCard="..c:getEffectiveId())
		end
	end
end

sgs.ai_skill_use_func["MobileRenMuzhenCard"] = function(card,use,self)
	self:sort(self.friends_noself,"hp")
	for _,ep in sgs.list(self.friends_noself)do
		if ep:getHp()>=self.player:getHp()
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.MobileRenMuzhenCard = 9.4
sgs.ai_use_priority.MobileRenMuzhenCard = 3.8

sgs.ai_skill_playerchosen.mobilerenyaohu = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		then return target end
	end
	self:sort(destlist,"card",true)
    for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		then return target end
	end
	return destlist[1]
end

sgs.ai_skill_choice.mobilerenyaohu = function(self,choices)
	local items = choices:split("+")
	return items[1]
end

sgs.ai_target_revises.mobilerenyaohu = function(to,card,self)
	if card:isDamageCard() and self:isEnemy(to)
	and self.player:getMark("mobilerenyaohu_"..to:objectName().."-PlayClear")>0
	then
		local ds = self:askForDiscard("yaohu",2,2,false,true)
		if #ds<2 or self:getUseValue(card)<self:getKeepValue(sgs.Sanguosha:getCard(ds[1]))+self:getKeepValue(sgs.Sanguosha:getCard(ds[2]))
		then return true end
	end
end

sgs.ai_skill_discard["mobilerenyaohu"] = function(self,x,n)
	local cards = {}
    local hcards = sgs.QList2Table(self.player:getCards("he"))
    self:sortByKeepValue(hcards) -- 按保留值排序
   	for _,h in sgs.list(hcards)do
		if #cards>=n then break end
		table.insert(cards,h:getEffectiveId())
	end
	return cards
end









