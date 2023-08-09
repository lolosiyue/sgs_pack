local luajuao_skill = {}
luajuao_skill.name = "luajuao"
table.insert(sgs.ai_skills, luajuao_skill)
luajuao_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#luajuaocard") and not self.player:isKongcheng() then return sgs.Card_Parse("#luajuaocard:.:") end
end

sgs.ai_skill_use_func["#luajuaocard"] = function(card, use, self)
	local handcards = sgs.QList2Table(self.player:getCards("h"))
	local use_card = nil
	self:sortByCardNeed(handcards, true)
	self:updatePlayers()
	self:sort(self.enemies, "handcard")
	self.enemies = sgs.reverse(self.enemies)
	local target = nil
	for _,c in ipairs(handcards) do
		if c:isKindOf("Slash") then
			use_card = c
		end
	end
	if use_card == nil then return end
	local red= 0
	for _,c in ipairs(handcards) do
		if c:isAvailable(self.player) then
			if c:isRed() and not c:isKindOf("Slash") then
				red = red + 1 
			end
		end
	end
	local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
	for _, enemy in ipairs(self.enemies) do
		if self:hasTrickEffective(duel, enemy,self.player) then
			if self.player:getHp() <=  enemy:getHp() then
				red = red + 0.5
			end
			--if self:getCardsNum("Slash") + red > enemy:getHandcardNum() / 2 then
			if self:getCardsNum("Slash") + red > getCardsNum("Slash", enemy) then
				target = enemy
			end
			if self.player:getHp() <=  enemy:getHp() then
				red = red - 0.5
			end
		end
	end
	if target == nil then return end
	local card_str = string.format("#luajuaocard:%s:", use_card:getEffectiveId())
	local acard = sgs.Card_Parse(card_str)
	use.card = acard
    duel:deleteLater()
	if use.to then use.to:append(target) end
end
--sgs.ai_use_priority["#luajuaocard"] = sgs.ai_use_value.XiechanCard
sgs.ai_use_priority["#luajuaocard"] =sgs.ai_use_priority.XiechanCard
--sgs.ai_use_value["#luajuaocard"] = sgs.ai_use_value.XiechanCard
sgs.ai_use_value["#luajuaocard"] = sgs.ai_use_value.XiechanCard
sgs.ai_card_intention["#luajuaocard"] = sgs.ai_card_intention.XiechanCard

sgs.double_slash_skill = sgs.double_slash_skill .. "|luajuao"

sgs.ai_cardneed.luajuao = function(to, card, self)
    return isCard("Slash", card, to) and getKnownCard(to, self.player, "Slash", true) == 0
end