
LuaFangxian_skill={}
LuaFangxian_skill.name = "LuaFangxian"
table.insert(sgs.ai_skills, LuaFangxian_skill)

LuaFangxian_skill.getTurnUseCard = function(self, inclusive)
	if self.player:hasUsed("#LuaFangxianCard") or self.player:isKongcheng() then return end
	local cards = sgs.QList2Table(self.player:getHandcards())
	local card = cards[1]
	for _,c in ipairs(cards) do if c:getSuit() == sgs.Card_Diamond then card = c end end
	for _,c in ipairs(cards) do if c:getSuit() == sgs.Card_Heart then card = c end end
	return sgs.Card_Parse("#LuaFangxianCard:"..card:getEffectiveId()..":")
end

sgs.ai_skill_use_func["#LuaFangxianCard"] = function(card, use, self)
	use.card = card
end

sgs.ai_skill_askforag["LuaFangxian"] = function(self, card_ids)
	local card_id = -1
	local re_id
	local re_n = 0
	local jink_id, peach_id, analeptic_id, ex_nihilo_id, nullification_id
	for _, id in ipairs(card_ids) do
		local target = self.room:getCardOwner(id)
		local card = sgs.Sanguosha:getCard(id)
		if self:isFriend(target) then
			local n = target:getHandcardNum() - target:getHp()
			if target:getHp() > 1 and n > 2 and card:isKindOf("Jink") then
				if re_n > n then re_n = n re_id = id end
			end 
			continue
		end
		card_id = id
		if card:isKindOf("Jink") then jink_id = id end
		if card:isKindOf("Analeptic") then analeptic_id = id end
		if card:isKindOf("ExNihilo") then ex_nihilo_id = id end
		if card:isKindOf("Nullification") then nullification_id = id end
		if card:isKindOf("Peach") then peach_id = id end
	end
	if jink_id then card_id = jink_id end
	if analeptic_id then card_id = analeptic_id end
	if ex_nihilo_id then card_id = ex_nihilo_id end
	if nullification_id then card_id = nullification_id end
	if peach_id then card_id = peach_id end
	if card_id == -1 and re_id and self:getCardsNum("Jink") < 1 and self.player:getHp() < 2 then card_id = re_id end
	return card_id
end

sgs.ai_use_value["LuaFangxianCard"] = 9
sgs.ai_use_priority["LuaFangxianCard"] = 9.2

sgs.ai_skill_playerchosen["LuaGaobi"] = function(self, targets)
	if #self.friends_noself < 1 then return self.player end
	local keepsNum = self:getCardsNum("Jink") + self:getCardsNum("Nullification") + self:getCardsNum("Peach") + self:getCardsNum("Analeptic") + self:getCardsNum("Slash")
	if self:getCardsNum("Slash") > 0 and sgs.Slash_IsAvailable(self.player) then keepsNum = keepsNum -1 end
	if self:getCardsNum("Peach") > 0 and self.player:isWounded() then keepsNum = keepsNum -1 end
	if self.player:getMaxCards() < keepsNum then return self.player end
	local target
	local t_num = - 10086
	for _, friend in ipairs(self.friends_noself) do
		local n = friend:getHandcardNum() - friend:getMaxCards()
		if n > t_num then
			t_num = n
			target = friend
		end
		if n > 0 and friend:getHp() < 2 then return friend end
	end
	return target or self.player
end

