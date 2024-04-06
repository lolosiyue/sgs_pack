--刺杀

sgs.ai_skill_discard._stabs_slash = function(self,max,min)
	local player = self.player
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	local dis = {}
	if #cards >= 1 then
		table.insert(dis, cards[1]:getEffectiveId())
	end
	return dis
end