
-- 宿敌规则，AI君 
-- version 2.1

sgs.ai_skill_invoke["LuaOldEnemyHermit"] = function(self, data)
	local target = self.room:getTag("OldEnemyHermit"):toPlayer()
	if self:isFriend(target) then
		if target:getJudgingArea():length() > 0 then return true end
		if self:getOverflow(target) > 2 then return true end
		if self:doNotDiscard(target) then return true end
		return (self:hasSkills(sgs.lose_equip_skill, target) and not target:getEquips():isEmpty())
		  or (self:needToThrowArmor(target) and target:getArmor()) or self:doNotDiscard(target)
	end
	if self:isEnemy(target) then
		if self:doNotDiscard(target) then return false end
		return true
	end
	return true
end

sgs.ai_skill_invoke["LuaPublicEnemy"] = function(self, data)
	return true
end

sgs.ai_skill_playerchosen["LuaOldEnemyHermit"] = function(self, targets)
	self:sort(self.friends_noself, "chaofeng")
	for _, friend in ipairs(self.friends_noself) do
		return friend
	end
end