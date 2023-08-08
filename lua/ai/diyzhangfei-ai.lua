local zfduanhe_skill = {}
zfduanhe_skill.name = "zfduanhe"
table.insert(sgs.ai_skills, zfduanhe_skill)
zfduanhe_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#zfduanhe") then return sgs.Card_Parse("#zfduanhe:.:") end
end

sgs.ai_skill_use_func["#zfduanhe"] = function(card, use, self)
	local handcards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByCardNeed(handcards, true)
	self:updatePlayers()
	self:sort(self.enemies, "handcard")
	self.enemies = sgs.reverse(self.enemies)
	local targets = {}
	for _, enemy in ipairs(self.enemies) do
		if #targets < 2 then
			table.insert(targets, enemy)
		else
		break
		end
	end
	if #targets == 0 then return end
	local card_str = ("#zfduanhe:.:")
	local acard = sgs.Card_Parse(card_str)
	use.card = acard
	if use.to then
		for i = 1, #targets, 1 do
			use.to:append(targets[i])
		end
	end
	--if use.to then use.to:append(target) end
end
sgs.ai_use_priority["zfduanhe"] = 7
sgs.ai_use_value["zfduanhe"] = 7
