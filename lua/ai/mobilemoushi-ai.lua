


addAiSkills("mobilemouduanliang").getTurnUseCard = function(self)
	return sgs.Card_Parse("@MobileMouDuanliangCard=.")
end

sgs.ai_skill_use_func["MobileMouDuanliangCard"] = function(card,use,self)
	self:sort(self.enemies,"hp")
	for _,ep in sgs.list(self.enemies)do
		if ep:getHp()>=self.player:getHp()
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	for _,ep in sgs.list(self.enemies)do
		use.card = card
		if use.to then use.to:append(ep) end
		return
	end
end

sgs.ai_use_value.MobileMouDuanliangCard = 3.4
sgs.ai_use_priority.MobileMouDuanliangCard = 5.8

sgs.ai_skill_playerchosen.mobilemoushipo = function(self,players)
	players = self:sort(players,"handcard")
    for _,target in sgs.list(players)do
		if self:isEnemy(target)
		then return target end
	end
    for _,target in sgs.list(players)do
		if not self:isFriend(target)
		then return target end
	end
end

sgs.ai_skill_use["@@mobilemoushipo"] = function(self,prompt)
	local valid,to = {},nil
	local tos = self.player:getAliveSiblings()
	tos = self:sort(tos,"hp")
    for _,p in sgs.list(tos)do
      	if self:isFriend(p)
		and p:getHandcardNum()<self.player:getHandcardNum()
    	then to = p:objectName() break end
	end
    for _,p in sgs.list(tos)do
      	if self:isFriend(p) and self:isWeak(p)
    	then to = p:objectName() break end
	end
    local cards = self.player:getCards("he")
    cards = self:sortByKeepValue(cards) -- 按保留值排序
	local List = self.player:property("mobilemoushipo_card_ids"):toString():split("+")
	for _,h in sgs.list(cards)do
		if #valid>1 then break end
		if table.contains(List,h:getEffectiveId())
		then table.insert(valid,h:getEffectiveId()) end
	end
	if #valid<1 then return end
	return to and string.format("@MobileMouShipoCard=%s->%s",table.concat(valid,"+"),to)
end

sgs.ai_skill_invoke.mobilemoutieqi = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isFriend(target)
	end
end





















