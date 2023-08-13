


sgs.ai_skill_invoke.mobilemouliegong = function(self,data)
	local target = data:toPlayer()
	local record = self.player:property("MobileMouLiegongRecords"):toString():split(",")
	if target and #record>2 then return not self:isFriend(target) end
end

addAiSkills("mobilemoukeji").getTurnUseCard = function(self)
	local cards = self.player:getCards("h")
	cards = self:sortByKeepValue(cards,nil,"j")
	if #cards<2 and self:isWeak() then return end
	local m = self.player:getMark("mobilemoukeji-PlayClear")
	local toids = self:isWeak() or #cards>2 and cards[1]:getEffectiveId() or "."
	if m<1 or m==1 and toids~="." or m>1 and toids=="."
	then
		return sgs.Card_Parse("@MobileMouKejiCard="..toids)
	end
end

sgs.ai_skill_use_func["MobileMouKejiCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.MobileMouKejiCard = 9.4
sgs.ai_use_priority.MobileMouKejiCard = 2.8

sgs.ai_skill_invoke.mobilemouduojing = function(self,data)
	local target = data:toPlayer()
	if target and self.player:getHujia()>1
	and self:isEnemy(target)
	then
		return target:getHandcardNum()>0 or target:getArmor()
	end
end

sgs.ai_use_revises.mobilemouduojing = function(self,card,use)
	if card:isKindOf("Slash") and self.player:getHujia()>1
	then card:setFlags("Qinggang") end
end


sgs.ai_skill_discard.mobilemouxiayuan = function(self)
	local cards = {}
    local handcards = sgs.QList2Table(self.player:getCards("h"))
    self:sortByKeepValue(handcards) -- 按保留值排序
   	local target = self.room:getCurrent()
   	for _,h in sgs.list(handcards)do
		if #cards>1 then break end
		table.insert(cards,h:getEffectiveId())
	end
	return self:isEnemy(target) and cards or {}
end

sgs.ai_skill_playerchosen.mobilemoujieyue = function(self,players)
	players = self:sort(players,"card")
    for _,target in sgs.list(players)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(players)do
		if not self:isEnemy(target)
		then return target end
	end
end















