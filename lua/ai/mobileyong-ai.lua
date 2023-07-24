
sgs.ai_skill_discard.mobileyongxizhan = function(self)
    local player = self.player
   	local target = self.room:getCurrent()
	local cards = {}
    local handcards = sgs.QList2Table(player:getCards("he"))
    self:sortByKeepValue(handcards) -- 按保留值排序
   	for _,h in sgs.list(handcards)do
		if self:isFriend(target)
		then
			if h:getSuit()==2
			or h:getSuit()==0
			then
				table.insert(cards,h:getEffectiveId())
				break
			end
		else
			table.insert(cards,h:getEffectiveId())
			break
		end
	end
	return cards
end

addAiSkills("mobileyongjungong").getTurnUseCard = function(self)
	local toids = {}
	local cards = self.player:getCards("he")
	cards = self:sortByKeepValue(cards,nil,true)
    local n = self.player:getMark("&mobileyongjungong-Clear")
  	for _,c in sgs.list(cards)do
		if #toids>n or n<1 and not self:isWeak() then break end
		table.insert(toids,c:getEffectiveId())
	end
	local slash = dummyCard()
	slash:setSkillName("mobileyongjungong")
	slash = self:aiUseCard(slash)
	if slash.card and slash.to
	and slash.card:isAvailable(self.player)
	then
		self.mobileyongjungong_to=slash.to
		local ids = #toids>0 and table.concat(toids,"+") or "."
		if #toids>n or n<1 then return sgs.Card_Parse("@MobileYongJungongCard="..ids) end
	end
end

sgs.ai_skill_use_func["MobileYongJungongCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.MobileYongJungongCard = 2.4
sgs.ai_use_priority.MobileYongJungongCard = 2.8

sgs.ai_skill_use["@@mobileyongjungong!"] = function(self,prompt)
	local valid = {}
	for _,to in sgs.list(self.mobileyongjungong_to)do
		table.insert(valid,to:objectName())
	end
	if #valid>0
	then
    	return "@MobileYongJungongCard=->"..table.concat(valid,"+")
	end
end

sgs.ai_skill_invoke.mobileyongdengli = function(self,data)
	return true
end










