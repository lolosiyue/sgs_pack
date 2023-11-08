--曹操
sgs.ai_skill_invoke.keqizhenglue = function(self, data)
	return true
end
sgs.ai_skill_invoke.keqizhengluegaincard = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.keqizhenglue = function(self, targets)
	targets = sgs.QList2Table(targets)
	local num = 1
	for _, p in ipairs(targets) do
		if not (p:objectName() == self.player:objectName()) then
			num = 0
			return p
		end
	end
	if num == 1 then
		return self
	end
	return nil
end
--[[
sgs.ai_skill_playerschosen.keqizhenglue = function(self,players,x,n)
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	--self:sort(destlist,"hp")
	local tos = {}
	for _,to in sgs.list(destlist)do
        table.insert(tos,to) end
	return tos
end
]]
sgs.ai_skill_playerchosen.keqipingrong = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		return p
	end
	return nil
end

--刘备
sgs.ai_skill_playerchosen.keqijishan = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isFriend(p) then
		    return p 
		end
	end
	return nil
end

sgs.ai_skill_invoke.keqijishan_pre = function(self, data)
	local damage = data:toDamage()
	--对自己无脑用
	if (damage.to:objectName() == self.player:objectName()) then
		return true
	elseif self:isFriend(damage.to) and not self:isWeak() then
		return true
	end
end

--孙坚

local keqipingtao_skill = {}
keqipingtao_skill.name = "keqipingtao"
table.insert(sgs.ai_skills, keqipingtao_skill)
keqipingtao_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("keqipingtaoCard") then return end
	return sgs.Card_Parse("#keqipingtaoCard:.:")
end

sgs.ai_skill_use_func["#keqipingtaoCard"] = function(card, use, self)
    if not self.player:hasUsed("#keqipingtaoCard") then
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

sgs.ai_use_value.keqipingtaoCard = 8.5
sgs.ai_use_priority.keqipingtaoCard = 9.5
sgs.ai_card_intention.keqipingtaoCard = 80


--董白
sgs.ai_skill_invoke.keqishichong = function(self, data)
	return true
end

--何进
sgs.ai_skill_invoke.keqizhaobing = function(self, data)
	if self.player:getHandcardNum() < 3 then
	    return true
	end
end

sgs.ai_skill_invoke.keqizhuhuan = function(self, data)
	return true
end
sgs.ai_skill_playerchosen.keqizhaobing = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
		    return p 
		end
	end
	return nil
end

--皇甫嵩
local keqiguanhuo_skill = {}
keqiguanhuo_skill.name = "keqiguanhuo"
table.insert(sgs.ai_skills, keqiguanhuo_skill)
keqiguanhuo_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("keqiguanhuoCard") and (self.player:getMark("aiguanhuo-PlayClear") == 0) then return end
	return sgs.Card_Parse("#keqiguanhuoCard:.:")
end

--原版索敌
--[[
sgs.ai_skill_use_func["#keqiguanhuoCard"] = function(card, use, self)
    if (not self.player:hasUsed("#keqiguanhuoCard")) or (self.player:getMark("aiguanhuo-PlayClear") > 0) then
        self:sort(self.enemies)
	    self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
		    if self:objectiveLevel(enemy) > 0 then
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
	end
end
]]
sgs.ai_skill_use_func["#keqiguanhuoCard"] = function(card, use, self)
    if (not self.player:hasUsed("#keqiguanhuoCard")) or (self.player:getMark("aiguanhuo-PlayClear") > 0) then
        self:sort(self.enemies)
	    self.enemies = sgs.reverse(self.enemies)
		local enys = sgs.SPlayerList()
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isKongcheng() then
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
sgs.ai_use_value.keqiguanhuoCard = 8.5
sgs.ai_use_priority.keqiguanhuoCard = 9.5
sgs.ai_card_intention.keqiguanhuoCard = 80

--孔融
sgs.ai_skill_invoke.keqilirang_use = function(self, data)
	if self.player:hasFlag("aiuselirang") then
	    return true
	end
end
sgs.ai_skill_discard.keqilirang = function(self) --给牌
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	table.insert(to_discard, cards[1]:getEffectiveId())
	table.insert(to_discard, cards[2]:getEffectiveId())
	return to_discard
end
sgs.ai_skill_invoke.keqilirang_get = function(self, data)
	return true
end
--刘宏
sgs.ai_skill_invoke.keqichaozheng = function(self, data)
	local room = self.room
	local all = room:getAllPlayers()
	for _, p in sgs.qlist(all) do
		if self:isFriend(p) then
			return true
		end
	end
	return false
end

local keqishenchong_skill = {}
keqishenchong_skill.name = "keqishenchong"
table.insert(sgs.ai_skills, keqishenchong_skill)
keqishenchong_skill.getTurnUseCard = function(self)
	if self.player:getMark("@keqishenchong") == 0 then return end
	return sgs.Card_Parse("#keqishenchongCard:.:")
end

sgs.ai_skill_use_func["#keqishenchongCard"] = function(card, use, self)
    if (self.player:getMark("@keqishenchong") > 0)  then
		self:sort(self.friends,"defense")
	    self.friends = sgs.reverse(self.friends)
		for _, fri in ipairs(self.friends) do
		    if (fri:objectName() ~= self.player:objectName()) then
			    use.card = card
			    if use.to then use.to:append(fri) end
		        return
			end
		end
	end
end

sgs.ai_use_value.keqiguanhuoCard = 8.5
sgs.ai_use_priority.keqiguanhuoCard = 9.5
sgs.ai_card_intention.keqiguanhuoCard = 80



--[[sgs.ai_skill_cardchosen.keqichaozheng_yishi = function(self,who)
	local player = self.player
	for _,c in sgs.qlist(who:getCards("h")) do
		if c:hasFlag("chaozhengred") or c:hasFlag("chaozhengblack") then
			return c:getId()
		end
	end
	return -1
end]]

sgs.ai_skill_discard.keqichaozheng = function(self)
	local to_discard = {}
	if self.player:hasFlag("chaozhengwantred") then
		for _,c in sgs.qlist(self.player:getCards("h")) do
			if (c:isRed()) then
				if (#to_discard == 0) then
				    table.insert(to_discard, c:getEffectiveId())
				end
			end
		end
	else
		for _,c in sgs.qlist(self.player:getCards("h")) do
			if (c:isBlack()) then
				if (#to_discard == 0) then
				    table.insert(to_discard, c:getEffectiveId())
				end
			end
		end
	end
	if (#to_discard == 0) then
		for _,c in sgs.qlist(self.player:getCards("h")) do
			if (#to_discard == 0) then
				table.insert(to_discard, c:getEffectiveId())
			end
		end
	end
	return to_discard
end

sgs.ai_skill_invoke.keqijulian = function(self,data)
    return true
end


--南华老仙

sgs.ai_skill_invoke.keqixuanhuatwofirst = function(self, data)
	return true
end

sgs.ai_skill_playerchosen.keqishoushu = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if (self.player:objectName() == p:objectName()) then
		    return p 
		end
	end
	return nil
end

sgs.ai_skill_playerchosen.keqishoushutwo = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if (self.player:objectName() == p:objectName()) then
		    return p 
		end
	end
	return nil
end

sgs.ai_skill_invoke.keqixuanhua = function(self,data)
    if (self.player:getArmor() ~= nil) and (self.player:getArmor():objectName() == "_keqi_taipingyaoshu") then
		return true
	end
end

sgs.ai_skill_invoke.keqixuanhuatwo = function(self,data)
    if (self.player:getArmor() ~= nil) and (self.player:getArmor():objectName() == "_keqi_taipingyaoshu") then
		return true
	end
end

sgs.ai_skill_playerchosen.keqixuanhuaco_ask = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isFriend(p) and p:isWounded() then
		    return p 
		end
	end
	return nil
end
sgs.ai_skill_playerchosen.keqixuanhuada_ask = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
		    return p 
		end
	end
	return nil
end

--桥玄
sgs.ai_skill_invoke.keqijuezhi_wq = function(self,data)
    return true
end
sgs.ai_skill_invoke.keqijuezhi_fj = function(self,data)
    return true
end
sgs.ai_skill_invoke.keqijuezhi_fy = function(self,data)
    return true
end
sgs.ai_skill_invoke.keqijuezhi_jg = function(self,data)
    return true
end
sgs.ai_skill_invoke.keqijuezhi_bw = function(self,data)
    return true
end

--王允
--议事的AI与刘宏相同

local keqishelun_skill = {}
keqishelun_skill.name = "keqishelun"
table.insert(sgs.ai_skills, keqishelun_skill)
keqishelun_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("keqishelunCard") then return end
	return sgs.Card_Parse("#keqishelunCard:.:")
end

sgs.ai_skill_use_func["#keqishelunCard"] = function(card, use, self)
    if not self.player:hasUsed("#keqishelunCard") then
        self:sort(self.enemies)
	    self.enemies = sgs.reverse(self.enemies)
		local enys = sgs.SPlayerList()
		for _, enemy in ipairs(self.enemies) do
			if self.player:inMyAttackRange(enemy) then
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
		end
		if (enys:length() > 0) then
			for _,enemy in sgs.qlist(enys) do
				if self:objectiveLevel(enemy) > 0 then
					use.card = card
					if use.to then use.to:append(enemy) end
					return
				end
			end
		end
	end
end

sgs.ai_use_value.keqishelunCard = 8.5
sgs.ai_use_priority.keqishelunCard = 9.5
sgs.ai_card_intention.keqishelunCard = 80

sgs.ai_skill_playerchosen.keqifayi = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
		    return p 
		end
	end
	return nil
end

sgs.ai_skill_discard.keqishelun = function(self)
	local to_discard = {}
	if self.player:hasFlag("shulunfriend") then
		for _,c in sgs.qlist(self.player:getCards("h")) do
			if (c:isRed()) then
				if (#to_discard == 0) then
				    table.insert(to_discard, c:getEffectiveId())
				end
			end
		end
	else
		for _,c in sgs.qlist(self.player:getCards("h")) do
			if (c:isBlack()) then
				if (#to_discard == 0) then
				    table.insert(to_discard, c:getEffectiveId())
				end
			end
		end
	end
	if (#to_discard == 0) then
		for _,c in sgs.qlist(self.player:getCards("h")) do
			if (#to_discard == 0) then
				table.insert(to_discard, c:getEffectiveId())
			end
		end
	end
	return to_discard
end



--杨彪
local keqiyizheng_skill = {}
keqiyizheng_skill.name = "keqiyizheng"
table.insert(sgs.ai_skills, keqiyizheng_skill)
keqiyizheng_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("keqiyizhengCard") then return end
	return sgs.Card_Parse("#keqiyizhengCard:.:")
end

sgs.ai_skill_use_func["#keqiyizhengCard"] = function(card, use, self)
    if not self.player:hasUsed("#keqiyizhengCard") then
        self:sort(self.enemies)
	    self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
		    if (self:objectiveLevel(enemy) > 0) and (self.player:getHandcardNum() < enemy:getHandcardNum()) then
			    use.card = card
			    if use.to then use.to:append(enemy) end
		        return
			end
		end
	end
end

sgs.ai_use_value.keqiyizhengCard = 8.5
sgs.ai_use_priority.keqiyizhengCard = 9.5
sgs.ai_card_intention.keqiyizhengCard = 80


--朱儁
sgs.ai_skill_invoke.keqifendi = function(self,data)
    return true
end




--王荣
sgs.ai_skill_invoke.keqijizhanw = function(self,data)
    return true
end

sgs.ai_skill_choice.keqijizhanw = function(self,choices,data)
	local n = data:toInt()
	local player = self.player
	local items = choices:split("+")
	if n>6 then return items[2] end
	if n<7 then return items[1] end
	return items[2]
end


sgs.ai_skill_playerchosen.keqifusong = function(self,players)
	local player = self.player
	players = self:sort(players,"card",true)
    for _,target in sgs.list(players)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(players)do
		if not self:isEnemy(target)
		then return target end
	end
end









