local krskitgjiamian_skill = {}
krskitgjiamian_skill.name = "krskitgjiamian"
table.insert(sgs.ai_skills, krskitgjiamian_skill)
krskitgjiamian_skill.getTurnUseCard = function(self)
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)

	local jink_card

	self:sortByUseValue(cards, true)

	for _, card in ipairs(cards) do
		if card:isKindOf("Jink") then
			jink_card = card
			break
		end
	end

	if not jink_card then return nil end
	local suit = jink_card:getSuitString()
	local number = jink_card:getNumberString()
	local card_id = jink_card:getEffectiveId()
	local card_str = ("slash:krskitgjiamian[%s:%s]=%d"):format(suit, number, card_id)
	local slash = sgs.Card_Parse(card_str)
	assert(slash)

	return slash
end

sgs.ai_view_as.krskitgjiamian = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place ~= sgs.Player_PlaceEquip then
		if card:isKindOf("Jink") then
			return ("slash:krskitgjiamian[%s:%s]=%d"):format(suit, number, card_id)
		elseif card:isKindOf("Slash") then
			return ("jink:krskitgjiamian[%s:%s]=%d"):format(suit, number, card_id)
		end
	end
end

sgs.ai_use_priority.krskitgjiamian = 9

sgs.krskitgjiamian_keep_value = {
	Peach = 6,
	Analeptic = 5.8,
	Jink = 5.8,
	FireSlash = 5.7,
	Slash = 5.9,
	ThunderSlash = 5.5,
	ExNihilo = 4.7
}


sgs.ai_skill_invoke.krskitgjiamian = true
sgs.ai_skill_playerchosen.krskitgjiamian = function(self, targets)
	self:sort(targets, "handcard")
	for _, enemy in ipairs(targetss) do
		if not self:isFriend(enemy) and enemy:getCards("h"):length() >= 1 or self:hasSkills(sgs.cardneed_skill, enemy) then
			return enemy
		end
	end
end
sgs.ai_playerchosen_intention.krskitgjiamian = function(from, to)
	local intention = 50
	sgs.updateIntention(from, to, intention)
end
