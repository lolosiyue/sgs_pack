--换英雄

sgs.ai_skill_invoke.guichangetupo = function(self, data)
	--[[local num = math.random(0,1)
	if (num == 0) then
	    return true
	else
		return false
	end]]
	return false
end

--鬼曹操
sgs.ai_skill_invoke.keguiduoyi = function(self, data)
	return true
end

--鬼关羽
sgs.ai_skill_invoke.keguiwumo = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.keguituodao = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
			theweak:append(p)
		end
	end
	for _,qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _,pp in sgs.qlist(theweaktwo) do
				if (pp:getHp() < qq:getHp()) then
					inin = 0
				end
			end
			if (inin == 1) then
				theweaktwo:append(qq)
			end
		end
	end
	if theweaktwo:length() > 0 then
	    return theweaktwo:at(0)
	end
	return nil
end

--鬼华雄

sgs.ai_skill_invoke.keguixiaoshou = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.keguixiaoshou = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isFriend(p) then
			theweak:append(p)
		end
	end
	for _,qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _,pp in sgs.qlist(theweaktwo) do
				if (pp:getHp() < qq:getHp()) then
					inin = 0
				end
			end
			if (inin == 1) then
				theweaktwo:append(qq)
			end
		end
	end
	if theweaktwo:length() > 0 then
	    return theweaktwo:at(0)
	end
	return nil
end

--鬼诸葛亮

sgs.ai_skill_invoke.keguizhuangshen = function(self, data)
	return true
end


--司马徽

local keguishouye_skill = {}
keguishouye_skill.name = "keguishouye"
table.insert(sgs.ai_skills, keguishouye_skill)
keguishouye_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("keguishouyeCard") then return end
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local to_throw = sgs.IntList()
	for _, acard in ipairs(cards) do
		to_throw:append(acard:getEffectiveId())
	end
	card_id = to_throw:at(0)
	if not card_id then
		return nil
	else
		return sgs.Card_Parse("#keguishouyeCard:"..card_id..":")
	end
end


sgs.ai_skill_use_func["#keguishouyeCard"] = function(card, use, self)
	if not self.player:hasUsed("#keguishouyeCard") then
        self:sort(self.friends)
		for _, friend in ipairs(self.friends) do
			if self:isFriend(friend)  then
				use.card = card
				if use.to then use.to:append(friend) end
				return
			end
		end
	end
end

sgs.ai_use_value.keguishouyeCard = 8.5
sgs.ai_use_priority.keguishouyeCard = 9.5
sgs.ai_card_intention.keguishouyeCard = 80

function sgs.ai_cardneed.keguishouyeCard(to, card)
	return true
end

--沙摩柯
sgs.ai_skill_invoke.keguiqinwang = function(self, data)
	return self.player:hasFlag("wantusekeguiqinwang")
end


--界鬼曹操
sgs.ai_skill_invoke.kejieguiduoyi = function(self, data)
	return true
end

--界鬼诸葛亮

sgs.ai_skill_invoke.kejieguizhuangshen = function(self, data)
	return true
end


sgs.ai_skill_choice.kejieguizhuangshen = function(self, choices, data)
    return "guidawu"
end

sgs.ai_skill_playerchosen.kejieguizhuangshen = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isFriend(p) then
			theweak:append(p)
		end
	end
	for _,qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _,pp in sgs.qlist(theweaktwo) do
				if (pp:getHp() < qq:getHp()) then
					inin = 0
				end
			end
			if (inin == 1) then
				theweaktwo:append(qq)
			end
		end
	end
	if theweaktwo:length() > 0 then
	    return theweaktwo:at(0)
	end
	return nil
end

--second

sgs.ai_skill_invoke.kejieguiqideng = function(self, data)
	return true
end

local kejieguizhashi_skill = {}
kejieguizhashi_skill.name = "kejieguizhashi"
table.insert(sgs.ai_skills, kejieguizhashi_skill)
kejieguizhashi_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("kejieguizhashiCard") then return end
	return sgs.Card_Parse("#kejieguizhashiCard:.:")
end

sgs.ai_skill_use_func["#kejieguizhashiCard"] = function(card, use, self)
    if not self.player:hasUsed("#kejieguizhashiCard") then
        self:sort(self.enemies)
	    self.enemies = sgs.reverse(self.enemies)
		local enys = sgs.SPlayerList()
		for _, enemy in ipairs(self.enemies) do
			if enys:isEmpty() then
				enys:append(enemy)
			else
				local yes = 1
				for _,p in sgs.qlist(enys) do
					if (enemy:getHp()+enemy:getHp()+enemy:getHandcardNum()) >= (p:getHp()+p:getHp()+p:getHandcardNum()) then
						yes = 0
					end
				end
				if (yes == 1) then
					enys:removeOne(enys:at(0))
					enys:append(enemy)
				end
			end
		end
		for _,enemy in sgs.qlist(enys) do
			if self:objectiveLevel(enemy) > 0 then
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
	end
end

sgs.ai_use_value.kejieguizhashiCard = 8.5
sgs.ai_use_priority.kejieguizhashiCard = 9.5
sgs.ai_card_intention.kejieguizhashiCard = 80

--鬼张飞

sgs.ai_skill_invoke.kejieguilongyin = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.kejieguilongyin = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isFriend(p) then
			theweak:append(p)
		end
	end
	for _,qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _,pp in sgs.qlist(theweaktwo) do
				if (pp:getHp() < qq:getHp()) then
					inin = 0
				end
			end
			if (inin == 1) then
				theweaktwo:append(qq)
			end
		end
	end
	if theweaktwo:length() > 0 then
	    return theweaktwo:at(0)
	end
	return nil
end

sgs.ai_skill_invoke.jueqiaogainslash = function(self, data)
	return true
end

--界鬼关羽

sgs.ai_skill_invoke.kejieguiwumo = function(self, data)
	return true
end

sgs.ai_skill_choice.kejieguituodao = function(self, choices, data)
    local players = sgs.SPlayerList()
	local yes = 1
	for _, p in sgs.qlist(self.player:getAliveSiblings()) do
		if self.player:inMyAttackRange(p) then
			yes = 0
			break
		end
	end
	if (yes == 1) then
		return "dao"
	else
		return "sha"
	end	 
end

sgs.ai_skill_playerchosen.kejieguituodao = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
			theweak:append(p)
		end
	end
	for _,qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _,pp in sgs.qlist(theweaktwo) do
				if (pp:getHp() < qq:getHp()) then
					inin = 0
				end
			end
			if (inin == 1) then
				theweaktwo:append(qq)
			end
		end
	end
	if theweaktwo:length() > 0 then
	    return theweaktwo:at(0)
	end
	return nil
end


--界鬼吕布

sgs.ai_skill_invoke.kejieguisheji = function(self, data)
	return self.player:hasFlag("wantusekejieguisheji")
end

sgs.ai_skill_invoke.kejieguishejitwo = function(self, data)
	return self.player:hasFlag("wantusekejieguishejitwo")
end

--界鬼华雄

sgs.ai_skill_invoke.kejieguixiaoshou = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.kejieguixiaoshou = function(self, targets)
	targets = sgs.QList2Table(targets)
	local theweak = sgs.SPlayerList()
	local theweaktwo = sgs.SPlayerList()
	for _, p in ipairs(targets) do
		if self:isFriend(p) then
			theweak:append(p)
		end
	end
	for _,qq in sgs.qlist(theweak) do
		if theweaktwo:isEmpty() then
			theweaktwo:append(qq)
		else
			local inin = 1
			for _,pp in sgs.qlist(theweaktwo) do
				if (pp:getHp() < qq:getHp()) then
					inin = 0
				end
			end
			if (inin == 1) then
				theweaktwo:append(qq)
			end
		end
	end
	if theweaktwo:length() > 0 then
	    return theweaktwo:at(0)
	end
	return nil
end














