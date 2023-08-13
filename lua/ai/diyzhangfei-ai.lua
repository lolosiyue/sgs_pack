local zfduanhe_skill = {}
zfduanhe_skill.name = "zfduanhe"
table.insert(sgs.ai_skills, zfduanhe_skill)
zfduanhe_skill.getTurnUseCard = function(self)
	if self:needBear() then return end
	if not self.player:hasUsed("#zfduanhe") then return sgs.Card_Parse("#zfduanhe:.:") end
end

sgs.ai_skill_use_func["#zfduanhe"] = function(card, use, self)
	self:updatePlayers()
	self:sort(self.enemies, "handcard")
	self.enemies = sgs.reverse(self.enemies)
	local targets = {}
	for _, enemy in ipairs(self.enemies) do
		if #targets < 2 and self.player:canSlash(enemy, nil, true) then
			table.insert(targets, enemy)
		else
			break
		end
	end
	if #targets < 2 then
		for _, enemy in ipairs(self.enemies) do
			if #targets < 2 and not table.contains(targets, enemy) then
				table.insert(targets, enemy)
			else
				break
			end
		end
	end
	local slashcount = self:getCardsNum("Slash")
	if #targets > 0 and slashcount > 0 then
		use.card = sgs.Card_Parse("#zfduanhe:.:")
		if use.to then
			for i = 1, #targets, 1 do
				self.player:speak("T6")
				use.to:append(targets[i])
			end
			self.player:speak("T7")
		end
		self.player:speak("T8")
		return
	end
end
sgs.ai_use_priority["zfduanhe"] = 7
sgs.ai_use_value["zfduanhe"] = 7
