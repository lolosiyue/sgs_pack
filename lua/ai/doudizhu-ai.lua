--飞扬
sgs.ai_skill_use["@@feiyang"] = function(self,prompt)
	local disaster,indulgence,supply_shortage = -1,-1,-1
	for _,card in sgs.list(self.player:getJudgingArea())do
		if card:isKindOf("Disaster") then disaster = card:getEffectiveId() end
		if card:isKindOf("Indulgence") then indulgence = card:getEffectiveId() end
		if card:isKindOf("SupplyShortage") then supply_shortage = card:getEffectiveId() end
	end
	
	local handcards = {}
	for _,id in sgs.list(self.player:handCards())do
		if self.player:canDiscard(self.player,id) then
			table.insert(handcards,sgs.Sanguosha:getCard(id))
		end
	end
	if #handcards<2 then return "." end
	self:sortByKeepValue(handcards)
	
	local discard = {}
	
	if disaster>-1 and self:hasSkills(sgs.wizard_skill,self.enemies) then
		table.insert(discard,disaster)
		table.insert(discard,handcards[1]:getEffectiveId())
		table.insert(discard,handcards[2]:getEffectiveId())
		return "@FeiyangCard="..table.concat(discard,"+")
	end
	
	if indulgence>-1 and self.player:hasSkill("keji") and supply_shortage>-1 then
		table.insert(discard,supply_shortage)
		table.insert(discard,handcards[1]:getEffectiveId())
		table.insert(discard,handcards[2]:getEffectiveId())
		return "@FeiyangCard="..table.concat(discard,"+")
	end
	
	if indulgence>-1 and self:getCardsNum("Peach")>1 and self:isWeak() then
		table.insert(discard,indulgence)
		table.insert(discard,handcards[1]:getEffectiveId())
		table.insert(discard,handcards[2]:getEffectiveId())
		return "@FeiyangCard="..table.concat(discard,"+")
	end
	
	if indulgence>-1 and self:getOverflow(self.player)>1 and (not self:isWeak() or not handcards[1]:isKindOf("Peach")) then
		table.insert(discard,indulgence)
		table.insert(discard,handcards[1]:getEffectiveId())
		table.insert(discard,handcards[2]:getEffectiveId())
		return "@FeiyangCard="..table.concat(discard,"+")
	end
	
	if supply_shortage>-1 and (not self:isWeak() or not handcards[1]:isKindOf("Peach")) then
		table.insert(discard,supply_shortage)
		table.insert(discard,handcards[1]:getEffectiveId())
		table.insert(discard,handcards[2]:getEffectiveId())
		return "@FeiyangCard="..table.concat(discard,"+")
	end
	
	if not self:isWeak() or not handcards[1]:isKindOf("Peach") then
		table.insert(discard,self.player:getJudgingArea():first():getEffectiveId())
		table.insert(discard,handcards[1]:getEffectiveId())
		table.insert(discard,handcards[2]:getEffectiveId())
		return "@FeiyangCard="..table.concat(discard,"+")
	end
	
	return "."
end

--队友死亡摸牌
sgs.ai_skill_invoke.doudizhu_reward = function(self,data)
	return self:canDraw()
end