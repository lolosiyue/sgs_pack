

sgs.ai_skill_invoke.jinbolan = function(self,data)
    return true
end

local jinbolan_skill={}
jinbolan_skill.name="jinbolan_skill"
table.insert(sgs.ai_skills,jinbolan_skill)
jinbolan_skill.getTurnUseCard = function(self)
	if self:isWeak() then return end
    for _,ep in sgs.list(self.room:getOtherPlayers(self.player))do
		if ep:hasSkill("jinbolan")
		and ep:getMark("jinbolan-PlayClear")<1
		and (not self:isEnemy(ep) or math.random()<0.4)
		then
			self.jinbolan_to=ep
			local parse = sgs.Card_Parse("@JinBolanSkillCard=.")
			assert(parse)
			return parse
		end
	end
end

sgs.ai_skill_use_func["JinBolanSkillCard"] = function(card,use,self)
	use.card = card
	if use.to then use.to:append(self.jinbolan_to) end
end

sgs.ai_use_value.JinBolanSkillCard = 4.4
sgs.ai_use_priority.JinBolanSkillCard = 5.2

sgs.ai_skill_playerchosen.jincanmou = function(self,players)
	local player = self.player
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
	local use = player:getTag("JincanmouData"):toCardUse()
	if use.to:contains(use.from)
	and not use.card:isDamageCard()
	then
		for _,target in sgs.list(destlist)do
			if self:isFriend(target)
			then return target end
		end
		for _,target in sgs.list(destlist)do
			if not self:isEnemy(target)
			then return target end
		end
	elseif use.card:isDamageCard()
	then
		for _,target in sgs.list(destlist)do
			if self:isEnemy(target)
			then return target end
		end
		for _,target in sgs.list(destlist)do
			if not self:isFriend(target)
			then return target end
		end
	elseif self:isFriend(use.from)
	then
		for _,to in sgs.list(use.to)do
			if self:isFriend(to)
			then
				for _,target in sgs.list(destlist)do
					if self:isFriend(target)
					then return target end
				end
				for _,target in sgs.list(destlist)do
					if not self:isEnemy(target)
					then return target end
				end
			end
		end
	else
		for _,to in sgs.list(use.to)do
			if self:isFriend(to)
			then
				for _,target in sgs.list(destlist)do
					if self:isEnemy(target)
					then return target end
				end
				for _,target in sgs.list(destlist)do
					if not self:isFriend(target)
					then return target end
				end
			end
		end
	end
end

sgs.ai_skill_invoke.jincongjian = function(self,data)
	local player = self.player
	local use = player:getTag("JincongjianData"):toCardUse()
	self.jcj_can = nil
	if use.to:contains(use.from)
	and not use.card:isDamageCard()
	then return true
	elseif use.card:isDamageCard()
	then
		self.jcj_can = not self:isWeak()
		return self.jcj_can
	end
end

sgs.ai_skill_cardask.jincongjian = function(self,data,pattern,prompt)
	local player = self.player
    local parsed = prompt:split(":")
    if self.jcj_can
	then
    	self.jcj_can = nil
		if parsed[1] == "slash-jink"
		then return false
		else
	    	parsed = data:toCardEffect()
			local card = parsed.card
			if card and card:isDamageCard()
			then return false end
		end
	end
end









