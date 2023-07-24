
sgs.ai_fill_skill.zhizhe = function(self)
	local cs = {}
	for _,h in sgs.list(self:sortByUseValue(self.player:getCards("h")))do
		if h:getTypeId()<3 and not h:isKindOf("DelayedTrick")
		then table.insert(cs,h) end
	end
	if #cs<4 or self:getUseValue(cs[1])<8 then return end
	return sgs.Card_Parse("@ZhizheCard="..cs[1]:getEffectiveId())
end

sgs.ai_skill_use_func["ZhizheCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.ZhizheCard = 5.4
sgs.ai_use_priority.ZhizheCard = 13.8

sgs.ai_skill_playerschosen.qingshi = function(self,players,x,n)
	local destlist = sgs.QList2Table(players)
	self:sort(destlist,"hp")
	local tos = {}
	for _,to in sgs.list(destlist)do
		if #tos>=x then break end
		if self:isFriend(to) then table.insert(tos,to) end
	end
	for _,to in sgs.list(destlist)do
		if #tos>=x or #tos>self.player:aliveCount()/2 then break end
		if not table.contains(tos,to) and not self:isEnemy(to)
		then table.insert(tos,to) end
	end
	return tos
end

sgs.ai_skill_choice.qingshi = function(self,choices,data)
	local items = choices:split("+")
	if table.contains(items,"draw")
	and #self.friends_noself>self.player:getHp()
	and self.toUse and #self.toUse>3
	then return "draw" end
	for _,c in sgs.list(items)do
		if c:startsWith("selfdraw")
		then return c end
	end
	return items[1]
end

