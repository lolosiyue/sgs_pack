sgs.ai_skill_invoke.qingyue = function(self, data)
	local damage = data:toDamage()
	local target = damage.to
	if target  then
		if self:isFriend(target) then
			if(target:hasSkill("kongcheng") or target:hasSkill("lianying") or target:hasSkill("tuntian")) and target:getHandcardNum() == 1 then 
			return true 
			end
		else
	return not target:hasSkill("kongcheng") 
		end
	end
	return false
end