
LuaDuanjian_skill={}
LuaDuanjian_skill.name = "LuaDuanjian"
table.insert(sgs.ai_skills, LuaDuanjian_skill)

LuaDuanjian_skill.getTurnUseCard = function(self, inclusive)
	if self.player:isNude() then return end
	local cards = sgs.QList2Table(self.player:getCards("he"))
	local card
	for _,c in ipairs(cards) do if c:isKindOf("Weapon") then card = c end end
	if card then return sgs.Card_Parse("#LuaDuanjianCard:"..card:getEffectiveId()..":") end
end

sgs.ai_skill_use_func["#LuaDuanjianCard"] = function(card, use, self)
	local target1, target2
	local myoldenemy = findMyOE(self.player, self.room)
	if myoldenemy then
		target1 = self.player
		target2 = myoldenemy
	end
	if not (target1 and target2) then
		self:sort(self.enemies, "threat")
		for _, enemy in ipairs(self.enemies) do
			local theoldenemy = findMyOE(enemy, self.room)
			if theoldenemy then
				target1 = enemy
				target2 = theoldenemy
				break
			end
		end
	end
	if target1 and target2 then
		use.card = card
		if use.to then
			use.to:append(target1)
			use.to:append(target2)
		end
	end
end

sgs.ai_use_value["LuaDuanjianCard"] = 7.6
sgs.ai_use_priority["LuaDuanjianCard"] = 2.2

sgs.LuaDuanjian_keep_value = {
	Peach = 6,
	Jink = 5.1,
	Weapon = 5
}

