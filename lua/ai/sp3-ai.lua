--度断
sgs.ai_skill_cardask["@duoduan-card"] = function(self,data)
	if self:needToThrowArmor() then return "$"..self.player:getArmor():getEffectiveId() end
	local use = data:toCardUse()
	if use.card:isKindOf("FireSlash") and self:slashIsEffective(use.card,self.player,use.from) and self:damageIsEffective(self.player,sgs.DamageStruct_Fire,use.from) and
		self.player:hasArmorEffect("vine") and self.player:getArmor() and self.player:getArmor():objectName()=="vine" and
		(self:getCardsNum("Jink")==0 or self:canHit(self.player,use.from)) and not use.from:hasSkills("jueqing|gangzhi") then
		return "$"..self.player:getArmor():getEffectiveId()
	end
	
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	if cards[1]:isKindOf("Jink") and self:getCardsNum("Jink")==1 then return "." end
	if cards[1]:isKindOf("Peach") or cards[1]:isKindOf("Analeptic") then return "." end
	
	local nature = sgs.DamageStruct_Normal
	if use.card:isKindOf("FireSlash") then nature = sgs.DamageStruct_Fire end
	if use.card:isKindOf("ThunderSlash") then nature = sgs.DamageStruct_Thunder end
	if self:getCardsNum("Jink")==0 and self:slashIsEffective(use.card,self.player,use.from) and self:damageIsEffective(self.player,nature,use.from) then return "$"..cards[1]:getEffectiveId() end
	if not self:isValuableCard(cards[1]) then return "$"..cards[1]:getEffectiveId() end
	return "."
end

sgs.ai_skill_discard.duoduan = function(self,discard_num,min_num,optional,include_equip)
	local use = self.player:getTag("duoduanForAI"):toCardUse()
	return self:askForDiscard("dummyreason",1,1,false,true)
end

--共损
sgs.ai_skill_use["@@gongsun"] = function(self,prompt)
	local valid,to = {},nil
    for _,p in sgs.list(self.player:getAliveSiblings())do
      	if self:isEnemy(p) and p:getHandcardNum()>2
    	then to = p break end
	end
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if #valid>=2 or to==nil or #cards<4 then break end
    	table.insert(valid,h:getEffectiveId())
	end
	if #valid<2 or #self.friends_noself<1 then return end
	return string.format("@GongsunCard=%s->%s",table.concat(valid,"+"),to:objectName())
end

sgs.ai_skill_askforag.GongsunCard = function(self,card_ids)
	for c,id in sgs.list(card_ids)do
		c = sgs.Sanguosha:getCard(id)
		if c:isKindOf("Slash")
		then return id end
	end
	for c,id in sgs.list(card_ids)do
		c = sgs.Sanguosha:getCard(id)
		if c:isKindOf("Jink")
		and self:getCardsNum("Slash")>0
		then return id end
	end
	for c,id in sgs.list(card_ids)do
		c = sgs.Sanguosha:getCard(id)
		if c:isDamageCard()
		then return id end
	end
end

sgs.ai_skill_invoke.juanxia_slash = function(self,data)
	local items = data:toString():split(":")
	if items[1]=="juanxia_slash"
	then
        local target = self.room:findPlayerByObjectName(items[2])
    	return self:isEnemy(target)
	end
end

sgs.ai_skill_playerchosen.juanxia = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard")
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and self:isWeak(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:canDisCard(target,"ej")
		and self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
end

sgs.ai_skill_choice.juanxia = function(self,choices,data)
	local items = choices:split("+")
	local target = data:toPlayer()
	local cs = {}
	for c,pn in sgs.list(items)do
		c = dummyCard(pn)
		if c
		then
			c:setSkillName("_juanxia")
			table.insert(cs,c)
		end
	end
	self:sortByUseValue(cs)
	for d,c in sgs.list(cs)do
		d = self:aiUseCard(c)
		if d.card and d.to
		and d.to:contains(target)
		then return c:objectName() end
	end
	if self:isFriend(target)
	then
		for d,c in sgs.list(cs)do
			if self:canDisCard(target,"ej")
			and (c:isKindOf("Snatch") or c:isKindOf("Dismantlement") or c:isKindOf("Zhujinquyuan"))
			then return c:objectName() end
		end
		for d,c in sgs.list(cs)do
			if c:targetFixed() and not c:isDamageCard()
			then return c:objectName() end
		end
		for d,c in sgs.list(cs)do
			if not c:isDamageCard()
			then return c:objectName() end
		end
	else
		for d,c in sgs.list(cs)do
			if not c:targetFixed() or c:isDamageCard()
			then return c:objectName() end
		end
	end
end

sgs.ai_skill_invoke.tenyearjuanxia_slash = function(self,data)
	local items = data:toString():split(":")
	if items[1]=="tenyearjuanxia_slash"
	then
        local target = self.room:findPlayerByObjectName(items[2])
    	return target and self:isEnemy(target)
	end
end

sgs.ai_skill_playerchosen.tenyearjuanxia = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard")
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and self:isWeak(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:canDisCard(target,"ej")
		and self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
end

sgs.ai_skill_choice.tenyearjuanxia = function(self,choices,data)
	local items = choices:split("+")
	local target = data:toPlayer()
	for c,pn in sgs.list(items)do
		c = dummyCard(pn)
		c:setSkillName("_tenyearjuanxia")
		local d = self:aiUseCard(c)
		if d.card and d.to
		and d.to:contains(target)
		then return pn end
	end
	if self:isFriend(target)
	then
		for c,pn in sgs.list(items)do
			c = dummyCard(pn)
			c:setSkillName("_tenyearjuanxia")
			if self:canDisCard(target,"ej")
			and (c:isKindOf("Snatch") or c:isKindOf("Dismantlement") or c:isKindOf("Zhujinquyuan"))
			then return pn end
		end
		for c,pn in sgs.list(items)do
			c = dummyCard(pn)
			c:setSkillName("_tenyearjuanxia")
			if c:targetFixed()
			and not c:isDamageCard()
			then return pn end
		end
		for c,pn in sgs.list(items)do
			c = dummyCard(pn)
			c:setSkillName("_tenyearjuanxia")
			if not c:isDamageCard()
			then return pn end
		end
	else
		for c,pn in sgs.list(items)do
			c = dummyCard(pn)
			c:setSkillName("_tenyearjuanxia")
			if not c:targetFixed()
			or c:isDamageCard()
			then return pn end
		end
	end
end

--周旋
local zhouxuan_skill = {}
zhouxuan_skill.name = "zhouxuan"
table.insert(sgs.ai_skills,zhouxuan_skill)
zhouxuan_skill.getTurnUseCard = function(self)
	return sgs.Card_Parse("@ZhouxuanCard=.")
end

sgs.ai_skill_use_func.ZhouxuanCard = function(card,use,self)
	local id = -1
	if self:needToThrowArmor() and self.player:canDiscard(self.player,self.player:getArmor():getEffectiveId()) then
		id = self.player:getArmor():getEffectiveId()
	else
		local cards = sgs.QList2Table(self.player:getCards("he"))
		self:sortByKeepValue(cards)
		if cards[1]:isKindOf("Peach") or (cards[1]:isKindOf("Jink") and self:getCardsNum("Jink")==1) then return end
		id = cards[1]:getEffectiveId()
	end
	if id<0 or (self:getOverflow()<=0 and self.room:getCardPlace(id)==sgs.Player_PlaceHand) then return end
	use.card = sgs.Card_Parse("@ZhouxuanCard="..id)
end

sgs.ai_use_priority.ZhouxuanCard = 0
sgs.ai_card_intention.ZhouxuanCard = 0

sgs.ai_skill_playerchosen.zhouxuan = function(self,targets)
	targets = sgs.QList2Table(targets)
	self:sort(targets,"handcard")
	
	for _,p in ipairs(targets)do
		local flag = string.format("%s_%s_%s","visible",self.player:objectName(),p:objectName())
		for _,cc in sgs.qlist(p:getHandcards())do
			if (cc:hasFlag("visible") or cc:hasFlag(flag)) and cc:isKindOf("TrickCard") and not cc:isKindOf("Nullification") then
				sgs.ai_skill_choice.zhouxuan = "TrickCard"
				return p
            end
        end
	end
	
	for _,p in ipairs(targets)do
		local flag = string.format("%s_%s_%s","visible",self.player:objectName(),p:objectName())
		for _,cc in sgs.qlist(p:getHandcards())do
			if (cc:hasFlag("visible") or cc:hasFlag(flag)) and cc:isKindOf("EquipCard") and p:canUse(cc) then
				sgs.ai_skill_choice.zhouxuan = "EquipCard"
				return p
            end
        end
	end
	
	for _,p in ipairs(targets)do
		local flag = string.format("%s_%s_%s","visible",self.player:objectName(),p:objectName())
		for _,cc in sgs.qlist(p:getHandcards())do
			if (cc:hasFlag("visible") or cc:hasFlag(flag)) and cc:isKindOf("Peach") and p:canUse(cc) then
				sgs.ai_skill_choice.zhouxuan = "peach"
				return p
            end
        end
	end
	
	for _,p in ipairs(targets)do
		local flag = string.format("%s_%s_%s","visible",self.player:objectName(),p:objectName())
		for _,cc in sgs.qlist(p:getHandcards())do
			if (cc:hasFlag("visible") or cc:hasFlag(flag)) and cc:isKindOf("Slash") and self:canUse(cc,self:getEnemies(p),p) then
				sgs.ai_skill_choice.zhouxuan = cc:objectName()
				return p
            end
        end
	end
	
	for _,p in ipairs(targets)do
		local flag = string.format("%s_%s_%s","visible",self.player:objectName(),p:objectName())
		for _,cc in sgs.qlist(p:getHandcards())do
			if (cc:hasFlag("visible") or cc:hasFlag(flag)) and cc:isKindOf("Analeptic") and p:canUse(cc) then
				sgs.ai_skill_choice.zhouxuan = cc:objectName()
				return p
            end
        end
	end
	
	sgs.ai_skill_choice.zhouxuan = "slash"
	return targets[#targets]
end

sgs.ai_skill_askforyiji.zhouxuan = function(self,card_ids)
	return sgs.ai_skill_askforyiji.nosyiji(self,card_ids)
end

sgs.ai_skill_invoke.wangzu = function(self,data)
	return self.player:getHandcardNum()>1 or self:isWeak()
end

sgs.ai_skill_cardask["@wangzu-discard"] = function(self,data)
    local damage = data:toDamage()
    local cards = self.player:getCards("h")
    cards = self:sortByKeepValue(cards,nil,true) -- 按保留值排序
	if self:canDamageHp(damage.from,damage.card,damage.to)
	and damage.damage<2
	then return "." end
	if #cards>0	then return cards[1]:getEffectiveId() end
    return "."
end

addAiSkills("yingrui").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
  	if #cards>0
	then
		return sgs.Card_Parse("@YingruiCard="..cards[1]:getEffectiveId())
	end
end

sgs.ai_skill_use_func["YingruiCard"] = function(card,use,self)
	self:sort(self.enemies,"card",true)
	for _,ep in sgs.list(self.enemies)do
		if ep:getCardCount()>0
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.YingruiCard = 4.4
sgs.ai_use_priority.YingruiCard = 3.8

sgs.ai_skill_discard.yingrui = function(self,x,n)
	local ids = {}
    local cards = sgs.QList2Table(self.player:getCards("he"))
    self:sortByKeepValue(cards) -- 按保留值排序
   	for _,h in sgs.list(cards)do
		if #ids>=n then break end
		if h:isKindOf("EquipCard") and self:isWeak()
		then table.insert(ids,h:getEffectiveId()) end
	end
	return #ids>=n and ids or {}
end

sgs.ai_skill_invoke.fuyuan = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isEnemy(target)
	end
end

sgs.ai_skill_choice.olfengji = function(self,choices)
	local items = choices:split("+")
	if table.contains(items,"draw")
	and #self.friends_noself>0
	and self.player:getHandcardNum()>3
	then return "draw" end
	if table.contains(items,"slash")
	and #self.friends_noself>0
	then
		local slash = sgs.Sanguosha:cloneCard("slash")
		local n = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,slash)
		slash:deleteLater()
		for _,to in sgs.list(self.enemies)do
			if self.player:canSlash(to)
			and self:isWeak(to)
			then n = n-1 end
		end
		if n>0
		then
			return "slash"
		end
	end
	return items[#items]
end

sgs.ai_skill_playerchosen.olfengji = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard",true)
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		then return target end
	end
	return destlist[1]
end




--魅步
sgs.ai_skill_cardask["@tenyearmeibu-dis"] = function(self,data)
	local player = data:toPlayer()
	if self:isEnemy(player)
	then
		local cards = {}
		for _,c in sgs.qlist(self.player:getCards("he"))do
			if self.player:canDiscard(self.player,c:getEffectiveId())
			then table.insert(cards,c) end
		end
		if #cards>0 then
			self:sortByKeepValue(cards)
			for _,c in ipairs(cards)do
				if not self:isValuableCard(c) then return "$"..c:getEffectiveId() end
			end
		end
	end
	if not self:isFriend(player)
	and not player:hasSkill("tenyearzhixi",true)
	then
		if self:needToThrowArmor()
		and self.player:canDiscard(self.player,self.player:getArmor():getEffectiveId())
		then return "$"..self.player:getArmor():getEffectiveId() end
	end
	return "."
end

sgs.ai_skill_cardask["@secondtenyearmeibu-dis"] = function(self,data)
	return sgs.ai_skill_cardask["@tenyearmeibu-dis"](self,data)
end

--穆穆
sgs.ai_skill_invoke.tenyearmumu = function(self,data)
	local targets,targets2 = {},{}
	for _,p in sgs.qlist(self.room:getAlivePlayers())do
		if (self:isFriend(p) and p:hasSkills(sgs.lose_equip_skill)) or (self:isEnemy(p) and not self:doNotDiscard(p,"e")) then
			table.insert(targets,p)
		end
		if not p:getArmor() then continue end
		if (self:isFriend(p) and p:hasSkills(sgs.lose_equip_skill)) or (self:isEnemy(p) and not self:doNotDiscard(p,"e")) then
			table.insert(targets2,p)
		end
	end
	
	if #targets2>0 then
		local will_use_slash = false
		if self:getCardsNum("Slash")>0 then
			local slash = sgs.Sanguosha:cloneCard("slash")
			slash:deleteLater()
			local dummy_use = { isDummy = true,to = sgs.SPlayerList(),current_targets = {} }
			for _,p in sgs.qlist(self.room:getAlivePlayers())do
				if not self:isWeak(p) then
					table.insert(dummy_use.current_targets,p)
				end
			end
			self:useCardSlash(slash,dummy_use)
			if dummy_use.card and dummy_use.to:length()>0 then
				will_use_slash = true
			end
		end
		if not will_use_slash then
			sgs.ai_skill_choice.tenyearmumu = "get"
			self:sort(targets2)
			for _,p in ipairs(targets2)do
				if self:isEnemy(p) then
					sgs.ai_skill_playerchosen.tenyearmumu = p
					return true
				end
			end
			sgs.ai_skill_playerchosen.tenyearmumu = targets2[1]
			return true
		end
	end
	
	if #targets>0 then
		sgs.ai_skill_choice.tenyearmumu = "discard"
		self:sort(targets)
		for _,p in ipairs(targets)do
			if self:isEnemy(p) then
				sgs.ai_skill_playerchosen.tenyearmumu = p
				return true
			end
		end
		sgs.ai_skill_playerchosen.tenyearmumu = targets[1]
		return true
	end
	return false
end

sgs.ai_skill_invoke.SecondTenyearMumu = function(self,data)
	local targets,targets2 = {},{}
	for _,p in sgs.qlist(self.room:getAlivePlayers())do
		if (self:isFriend(p) and p:hasSkills(sgs.lose_equip_skill)) or (self:isEnemy(p) and not self:doNotDiscard(p,"e")) then
			table.insert(targets,p)
		end
		if not p:hasEquip() then continue end
		if (self:isFriend(p) and p:hasSkills(sgs.lose_equip_skill)) or (self:isEnemy(p) and not self:doNotDiscard(p,"e")) then
			table.insert(targets2,p)
		end
	end
	
	if #targets2>0 then
		local will_use_slash = false
		if self:getCardsNum("Slash")>0 then
			local slash = sgs.Sanguosha:cloneCard("slash")
			slash:deleteLater()
			local dummy_use = { isDummy = true,to = sgs.SPlayerList(),current_targets = {} }
			for _,p in sgs.qlist(self.room:getAlivePlayers())do
				if not self:isWeak(p) then
					table.insert(dummy_use.current_targets,p)
				end
			end
			self:useCardSlash(slash,dummy_use)
			if dummy_use.card and dummy_use.to:length()>0 then
				will_use_slash = true
			end
		end
		if not will_use_slash then
			sgs.ai_skill_choice.secondtenyearmumu = "get"
			self:sort(targets2)
			for _,p in ipairs(targets2)do
				if self:isEnemy(p) then
					sgs.ai_skill_playerchosen.secondtenyearmumu = p
					return true
				end
			end
			sgs.ai_skill_playerchosen.secondtenyearmumu = targets2[1]
			return true
		end
	end
	
	if #targets>0 then
		sgs.ai_skill_choice.secondtenyearmumu = "discard"
		self:sort(targets)
		for _,p in ipairs(targets)do
			if self:isEnemy(p) then
				sgs.ai_skill_playerchosen.secondtenyearmumu = p
				return true
			end
		end
		sgs.ai_skill_playerchosen.secondtenyearmumu = targets[1]
		return true
	end
	return false
end

--止息
sgs.ai_skill_discard.tenyearzhixi = function(self,discard_num,min_num,optional,include_equip)
	return self:askForDiscard("dummyreason",1,1,false,false)
end

--鬻爵
function getYujueTarget(self)
	--[[local enemies = {}   --对敌人  待补充
	for _,p in ipairs(self.enemies)do
		if p:getHandcardNum()~=1 then continue end
		if p:hasSkill("kongcheng") then continue end  --AOE不需要考虑空城
		table.insert(enemies,p)
	end
	for _,p in ipairs(enemies)do]]

	for _,p in ipairs(self.friends_noself)do
		if p:isKongcheng() then continue end
		if self:needToThrowLastHandcard(p) then
			return p
		end
	end
	self:sort(self.friends_noself,"handcard")
	self.friends_noself = sgs.reverse(self.friends_noself)
	for _,p in ipairs(self.friends_noself)do
		if p:isKongcheng() then continue end
		if self:doNotDiscard(p,"h") then
			return p
		end
	end
	for _,p in ipairs(self.friends_noself)do
		if p:isKongcheng() then continue end
		return p
	end
	return nil
end

local yujue_skill = {}
yujue_skill.name = "yujue"
table.insert(sgs.ai_skills,yujue_skill)
yujue_skill.getTurnUseCard = function(self,inclusive)
	sgs.yujue_target = getYujueTarget(self)
	if sgs.yujue_target then
		return sgs.Card_Parse("@YujueCard=.")
	end
end

sgs.ai_skill_use_func.YujueCard = function(card,use,self)
	use.card = card
end

sgs.ai_use_priority.YujueCard = 7
sgs.ai_use_value.YujueCard = 1

sgs.ai_skill_choice.yujue = function(self,choices,data)
	local items = choices:split("+")
	if self:needToThrowArmor() and self.player:hasEquipArea(1) and table.contains(items,"1") then
		return "1"
	elseif self.player:hasEquipArea(4) and not self.player:getTreasure() and table.contains(items,"4") then
		return "4"
	elseif self.player:hasEquipArea(1) and not self.player:getArmor() and table.contains(items,"1") then
		return "1"	
	elseif self.player:hasEquipArea(0) and not self.player:getWeapon() and table.contains(items,"0") then
		return "0"
	elseif self.player:hasEquipArea(3) and not self.player:getOffensiveHorse() and table.contains(items,"3") then
		return "3"	
	elseif self.player:hasEquipArea(2) and not self.player:getDefensiveHorse() and table.contains(items,"2") then
		return "2"
	elseif self.player:hasEquipArea(4) and not self:keepWoodenOx() and table.contains(items,"4") then
		return "4"
	elseif self.player:hasEquipArea(1) and table.contains(items,"1") then
		return "1"	
	elseif self.player:hasEquipArea(0) and table.contains(items,"0") then
		return "0"	
	elseif self.player:hasEquipArea(3) and table.contains(items,"3") then
		return "3"
	elseif self.player:hasEquipArea(2) and table.contains(items,"2") then
		return "2"
	else
		return items[1]
	end
	return items[math.random(1,#items)]
end

sgs.ai_skill_playerchosen.yujue = function(self,targets)
	if sgs.yujue_target and targets:contains(sgs.yujue_target) then return sgs.yujue_target end
	local p = getYujueTarget(self)
	if p then return p end
	return targets:at(math.random(0,targets:length()-1))
end

sgs.ai_skill_discard.yujue = function(self,discard_num,min_num,optional,include_equip)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByUseValue(cards,true)
	return {cards[1]:getEffectiveId()}
end

--第二版鬻爵
local secondyujue_skill = {}
secondyujue_skill.name = "secondyujue"
table.insert(sgs.ai_skills,secondyujue_skill)
secondyujue_skill.getTurnUseCard = function(self,inclusive)
	sgs.secondyujue_target = getYujueTarget(self)
	if sgs.secondyujue_target then
		return sgs.Card_Parse("@SecondYujueCard=.")
	end
end

sgs.ai_skill_use_func.SecondYujueCard = function(card,use,self)
	use.card = card
end

sgs.ai_use_priority.SecondYujueCard = sgs.ai_use_priority.YujueCard
sgs.ai_use_value.SecondYujueCard = sgs.ai_use_value.YujueCard

sgs.ai_skill_playerchosen.secondyujue = function(self,targets)
	if sgs.secondyujue_target and targets:contains(sgs.secondyujue_target) then return sgs.secondyujue_target end
	local p = getYujueTarget(self)
	if p then return p end
	return targets:at(math.random(0,targets:length()-1))
end

--逆乱
local spniluan_skill = {}
spniluan_skill.name = "spniluan"
table.insert(sgs.ai_skills,spniluan_skill)
spniluan_skill.getTurnUseCard = function(self,inclusive)
	if self.player:isNude() and self.player:getHandPile():isEmpty() then return end
	if self.player:hasSkill("nuzhan") then sgs.ai_use_priority.SpNiluanCard = sgs.ai_use_priority.Slash+0.05 end
	return sgs.Card_Parse("@SpNiluanCard=.")
end

sgs.ai_skill_use_func.SpNiluanCard = function(card,use,self)
	local allcards = self.player:getCards("he")
	allcards = sgs.QList2Table(allcards)
	for _,id in sgs.qlist(self.player:getHandPile())do
		if sgs.Sanguosha:getCard(id):isBlack() then
			table.insert(allcards,sgs.Sanguosha:getCard(id))
		end
	end
	local cards = {}
	self:sortByUseValue(allcards,true)
	for _,c in ipairs(allcards)do
		if not c:isBlack() then continue end
		local slash = sgs.Sanguosha:cloneCard("slash",c:getSuit(),c:getNumber())
		slash:setSkillName("spniluan")
		slash:addSubcard(c)
		slash:deleteLater()
		if self.player:isLocked(slash) then continue end
		local dummy_use = { isDummy = true,to = sgs.SPlayerList(),current_targets = {} }
		for _,p in sgs.qlist(self.room:getOtherPlayers(self.player))do
			if p:getHp()<=self.player:getHp() then
				table.insert(dummy_use.current_targets,p)
			end
		end
		self:useCardSlash(slash,dummy_use)
		if dummy_use.card and dummy_use.to:length()>0 then
			table.insert(cards,c)
		end
	end
	if #cards==0 then return end
	local black_card
	local useAll = false
	self:sort(self.enemies,"defense")
	for _,enemy in ipairs(self.enemies)do
		if enemy:getHp()==1 and not enemy:hasArmorEffect("eight_diagram") and self.player:distanceTo(enemy)<=self.player:getAttackRange() and self:isWeak(enemy)
			and getCardsNum("Jink",enemy,self.player)+getCardsNum("Peach",enemy,self.player)+getCardsNum("Analeptic",enemy,self.player)==0 then
			useAll = true
			break
		end
	end

	local disCrossbow = false
	if self:getCardsNum("Slash")<2 or self.player:hasSkills("paoxiao|tenyearpaoxiao|olpaoxiao") then
		disCrossbow = true
	end

	local nuzhan_equip = false
	local nuzhan_equip_e = false
	self:sort(self.enemies,"defense")
	if self.player:hasSkill("nuzhan") then
		for _,enemy in ipairs(self.enemies)do
			if not enemy:hasArmorEffect("eight_diagram") and self.player:distanceTo(enemy)<=self.player:getAttackRange()
			and getCardsNum("Jink",enemy)<1 then
				nuzhan_equip_e = true
				break
			end
		end
		for _,card in ipairs(cards)do
			if card:isKindOf("TrickCard") and nuzhan_equip_e then
				nuzhan_equip = true
				break
			end
		end
	end

	local nuzhan_trick = false
	local nuzhan_trick_e = false
	self:sort(self.enemies,"defense")
	if self.player:hasSkill("nuzhan") and not self.player:hasFlag("hasUsedSlash") and self:getCardsNum("Slash")>1 then
		for _,enemy in ipairs(self.enemies)do
			if not enemy:hasArmorEffect("eight_diagram") and self.player:distanceTo(enemy)<=self.player:getAttackRange() then
				nuzhan_trick_e = true
				break
			end
		end
		for _,card in ipairs(cards)do
			if card:isKindOf("TrickCard") and nuzhan_trick_e then
				nuzhan_trick = true
				break
			end
		end
	end

	for _,card in ipairs(cards)do
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:deleteLater()
		if not card:isKindOf("Slash") and not (nuzhan_equip or nuzhan_trick)
			and (not isCard("Peach",card,self.player) and not isCard("ExNihilo",card,self.player) and not useAll)
			and (not isCard("Crossbow",card,self.player) or disCrossbow)
			and (self:getUseValue(card)<sgs.ai_use_value.Slash or sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue,self.player,slash)>0) then
			black_card = card
			break
		end
	end

	if nuzhan_equip then
		for _,card in ipairs(cards)do
			if card:isKindOf("EquipCard") then
				black_card = card
				break
			end
		end
	end

	if nuzhan_trick then
		for _,card in ipairs(cards)do
			if card:isKindOf("TrickCard")then
				black_card = card
				break
			end
		end
	end

	if black_card then
		local slash = sgs.Sanguosha:cloneCard("slash",black_card:getSuit(),black_card:getNumber())
		slash:setSkillName("spniluan")
		slash:addSubcard(black_card)
		slash:deleteLater()
		if self.player:isLocked(slash) then return end
		local dummy_use = { isDummy = true,to = sgs.SPlayerList(),current_targets = {} }
		for _,p in sgs.qlist(self.room:getOtherPlayers(self.player))do
			if p:getHp()<=self.player:getHp() then
				table.insert(dummy_use.current_targets,p)
			end
		end
		self:useCardSlash(slash,dummy_use)
		if dummy_use.card and dummy_use.to:length()>0 then
			use.card = sgs.Card_Parse("@SpNiluanCard="..black_card:getEffectiveId())
			for i = 1,math.min(dummy_use.to:length(),1+sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue,self.player,slash))do
				if use.to then use.to:append(dummy_use.to:at(i-1)) end
			end
		end
	end
end

sgs.ai_use_priority.SpNiluanCard = sgs.ai_use_priority.Slash-0.05

--违忤
local weiwu_skill = {}
weiwu_skill.name = "weiwu"
table.insert(sgs.ai_skills,weiwu_skill)
weiwu_skill.getTurnUseCard = function(self,inclusive)
	if self.player:isNude() and self.player:getHandPile():isEmpty() then return end
	return sgs.Card_Parse("@WeiwuCard=.")
end

sgs.ai_skill_use_func.WeiwuCard = function(card,use,self)
	local disCrossbow = false
	if self:getCardsNum("Slash")<2 or self.player:hasSkills("paoxiao|tenyearpaoxiao|olpaoxiao") then
		disCrossbow = true
	end
	local allcards = {}
	for _,c in sgs.qlist(self.player:getCards("he"))do
		if c:isKindOf("WoodenOx") and not self.player:getPile("wooden_ox"):isEmpty() then continue end
		if c:isRed() and not c:isKindOf("Snatch") and not c:isKindOf("Peach") and not c:isKindOf("ExNihilo") and (not c:isKindOf("Crossbow") or disCrossbow) then
			table.insert(allcards,c)
		end
	end
	for _,id in sgs.qlist(self.player:getHandPile())do
		local c = sgs.Sanguosha:getCard(id)
		if c:isRed() and not c:isKindOf("Snatch") and not c:isKindOf("Peach") and not c:isKindOf("ExNihilo") and (not c:isKindOf("Crossbow") or disCrossbow) then
			table.insert(allcards,c)
		end
	end
	if #allcards==0 then return end
	self:sortByUseValue(allcards,true)
	local cards = {}
	for _,c in ipairs(allcards)do
		local snatch = sgs.Sanguosha:cloneCard("snatch",c:getSuit(),c:getNumber())
		snatch:setSkillName("weiwu")
		snatch:addSubcard(c)
		snatch:deleteLater()
		if self.player:isLocked(snatch) then continue end
		local dummy_use = { isDummy = true,to = sgs.SPlayerList(),current_targets = {} }
		for _,p in sgs.qlist(self.room:getOtherPlayers(self.player))do
			if p:getHandcardNum()<=self.player:getHandcardNum() then
				table.insert(dummy_use.current_targets,p)
			end
		end
		self:useCardSnatchOrDismantlement(snatch,dummy_use)
		if dummy_use.card and dummy_use.to:length()>0 then
			if self:getUseValue(c)<self:getUseValue(snatch) or sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue,self.player,snatch)>0 then
				table.insert(cards,c)
			end
		end
	end
	if #cards==0 then return end
	local snatch = sgs.Sanguosha:cloneCard("snatch",cards[1]:getSuit(),cards[1]:getNumber())
	snatch:setSkillName("weiwu")
	snatch:addSubcard(cards[1])
	snatch:deleteLater()
	if self.player:isLocked(snatch) then return end
	local dummy_use = { isDummy = true,to = sgs.SPlayerList(),current_targets = {} }
	for _,p in sgs.qlist(self.room:getOtherPlayers(self.player))do
		if p:getHandcardNum()<=self.player:getHandcardNum() then
			table.insert(dummy_use.current_targets,p)
		end
	end
	self:useCardSnatchOrDismantlement(snatch,dummy_use)
	if dummy_use.card and dummy_use.to:length()>0 then
		use.card = sgs.Card_Parse("@WeiwuCard="..cards[1]:getEffectiveId())
		for i = 1,math.min(dummy_use.to:length(),1+sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue,self.player,snatch))do
			if use.to then use.to:append(dummy_use.to:at(i-1)) end
		end
	end
end

sgs.ai_use_priority.WeiwuCard = sgs.ai_use_priority.Snatch+0.05

--攻坚
function gongjianDoNotDis2(self,to)
	if to:getCardCount(true)<2 then return true end
    local n = 0
	if not self:doNotDiscard(to,"e") then
		for _,c in sgs.qlist(to:getCards("e"))do
			if self.player:canDiscard(to,c:getEffectiveId()) then n = n+1 end
		end
	end
	if n<2 then
		if not self:hasLoseHandcardEffective(to,2-n) then return true end
		if to:getHandcardNum()<=2-n and self:needKongcheng(to) then return true end
	end
	if self:hasSkills(sgs.lose_equip_skill,to) and to:getHandcardNum()<2 then return true end
	if to:getCardCount(true)<=2 and self:needToThrowArmor(to) then return true end
end

sgs.ai_skill_invoke.gongjian = function(self,data)
	local player = data:toPlayer()
	if self:isFriend(player) then return false end
	
	local use = self.player:getTag("gongjianData"):toCardUse()
	if not use then
		--[[local n = player:getHandcardNum()
		for _,c in sgs.qlist(player:getCards("e"))do
			if n>=2 then break end
			if self.player:canDiscard(player,c:getEffectiveId()) then n = n+1 end
		end
		if n<=0 then return false end
		n = math.min(2,n)
		return not self:doNotDiscard(player,"he",nil,n)]]
		return not self:doNotDiscard(player,"he")
	end
	
	if player:objectName()==use.to:last():objectName() then
		--[[local n = player:getHandcardNum()
		for _,c in sgs.qlist(player:getCards("e"))do
			if n>=2 then break end
			if self.player:canDiscard(player,c:getEffectiveId()) then n = n+1 end
		end
		if n==0 then return false end
		n = math.min(2,n)
		return not self:doNotDiscard(player,"he",nil,n)]]
		return not self:doNotDiscard(player,"he")
	end
	
	local players = {}
	local names = self.room:getTag("gongjian_slash_targets"):toStringList()
	for _,p in sgs.qlist(use.to)do
		if self:isFriend(p) or not table.contains(names,p:objectName()) then continue end
		local n = p:getHandcardNum()
		for _,c in sgs.qlist(p:getCards("e"))do
			if n>=2 then break end
			if self.player:canDiscard(p,c:getEffectiveId()) then n = n+1 end
		end
		if n==0 then continue end
		n = math.min(2,n)
		if n==2 and not gongjianDoNotDis2(self,p) then
			table.insert(players,p)
		end
	end
	if #players>0 then
		self:sort(players)
		return player:objectName()==players[1]:objectName()
	end
	for _,p in sgs.qlist(use.to)do
		if self:isFriend(p) or not table.contains(names,p:objectName()) then continue end
		if self:doNotDiscard(player,"he") then continue end
		table.insert(players,p)
	end
	if #players>0 then
		self:sort(players)
		return player:objectName()==players[1]:objectName()
	end
	return false
end

sgs.ai_skill_choice.gongjian = function(self,choices,data)
	local player = data:toPlayer()
	if self:isFriend(player) and self:needToThrowLastHandcard(player,2) then return "2" end
	if self:isFriend(player) then return "1" end
	if gongjianDoNotDis2(self,player) then return "1" end
	return "2"
end

--慈孝
sgs.ai_skill_playerchosen.cixiao = function(self,targets)
	if #self.enemies>0 then
		self:sort(self.enemies,"chaofeng")
		local n = math.random(1,100)
		if n<=25 then self.player:speak("伤害不高，但侮辱性极强") end
		return self.enemies[1]
	end
	return nil
end

sgs.ai_skill_use["@@cixiao"] = function(self,prompt,method)
	if #self.enemies>0 then
		self:sort(self.enemies,"chaofeng")
		self.enemies = sgs.reverse(self.enemies)
		local first
		if self.player:getMark("&cxyizi")>0 then first = self.player:objectName() end
		if not first then
			for _,p in ipairs(self.enemies)do
				if p:getMark("&cxyizi")>0 then
					first = p:objectName()
					break
				end
			end
		end
		if not first then return "." end
		local second
		self.enemies = sgs.reverse(self.enemies)
		
		if self:needToThrowArmor() and self.player:canDiscard(self.player,self.player:getArmor():getEffectiveId()) then
			for _,p in ipairs(self.enemies)do
				if p:getMark("&cxyizi")==0 and p:objectName()~=first then
					second = p:objectName()
					break
				end
			end
			if second then
				return "@CixiaoCard="..self.player:getArmor():getEffectiveId().."->"..first.."+"..second
			end
			for _,p in ipairs(self.enemies)do
				if p:objectName()~=first then
					second = p:objectName()
					break
				end
			end
			if second then
				return "@CixiaoCard="..self.player:getArmor():getEffectiveId().."->"..first.."+"..second
			end
			if self.player:objectName()~=first then
				return "@CixiaoCard="..self.player:getArmor():getEffectiveId().."->"..first.."+"..self.player:objectName()
			end
			return "."
		end
		
		for _,p in ipairs(self.enemies)do
			if p:objectName()==first then break end
			if p:getMark("&cxyizi")==0 then
				second = p:objectName()
				break
			end
		end
		if not second then return "." end
		local cards = sgs.QList2Table(self.player:getCards("he"))
		self:sortByKeepValue(cards)
		for _,c in ipairs(cards)do
			if not self:isValuableCard(c) and self.player:canDiscard(self.player,c:getEffectiveId()) then
				return "@CixiaoCard="..c:getEffectiveId().."->"..first.."+"..second
			end
		end
	end
	return "."
end

--叛弑
sgs.ai_skill_askforyiji.panshi = function(self,card_ids)
	local cards = {}
	for _,id in ipairs(card_ids)do
		table.insert(cards,sgs.Sanguosha:getCard(id))
	end
	self:sortByUseValue(cards,true)
	
	local dingyuans,num,fri = {},0,0
	for _,p in sgs.qlist(self.room:getAlivePlayers())do
		if p:hasFlag("dingyuan") then
			table.insert(dingyuans,p)
			if not self:isEnemy(p) then
				num = num+1
			end
			if self:isFriend(p) then
				fri = fri+1
			end
		end
	end
	self:sort(dingyuans)
	if self.player:getHandcardNum()<=num then
		for _,p in ipairs(dingyuans)do
			if self:isFriend(p) then
				return p,cards[1]:getEffectiveId()
			end
		end
		for _,p in ipairs(dingyuans)do
			if not self:isEnemy(p) then
				return p,cards[1]:getEffectiveId()
			end
		end
		return dingyuans[1],cards[1]:getEffectiveId()
	else
		for _,p in ipairs(dingyuans)do
			if self:isEnemy(p) then
				return p,cards[1]:getEffectiveId()
			end
		end
		
		if self.player:getHandcardNum()<=fri then
			for _,p in ipairs(dingyuans)do
				if self:isFriend(p) then
					return p,cards[1]:getEffectiveId()
				end
			end
			return dingyuans[1],cards[1]:getEffectiveId()
		else
			for _,p in ipairs(dingyuans)do
				if not self:isFriend(p) then
					return p,cards[1]:getEffectiveId()
				end
			end
			return dingyuans[1],cards[1]:getEffectiveId()
		end
	end
	return dingyuans[1],cards[1]:getEffectiveId()
end

--节应
sgs.ai_skill_playerchosen.jieyingh = function(self,targets)
	local slash = dummyCard()
	self:sort(self.enemies,"handcard")
	self.enemies = sgs.reverse(self.enemies)
	for _,p in ipairs(self.enemies)do
		if self:canUse(slash,self.friends,p)
		and (self:hasCrossbowEffect(p) or p:hasSkills(sgs.double_slash_skill))
		then
			if getCardsNum("Slash",p)>1
			then return p end
		end
	end
	self:sort(self.friends_noself,"handcard")
	for _,p in ipairs(self.friends_noself)do
		if #self:getEnemies(p)>1
		and (getCardsNum("ExNihilo",p)>0 or getCardsNum("Snatch",p)>0 or getCardsNum("Dismantlement",p)>0 or getCardsNum("Duel",p)>0) then
			return p
		end
	end
	for _,p in ipairs(self.friends_noself)do
		if not self:hasCrossbowEffect(p) then
			if (getCardsNum("Slash",p)>0 or p:getHandcardNum()>=3) and not self:canUse(slash,self:getEnemies(p),p) then
				for _,enemy in ipairs(self:getEnemies(p))do
					if p:canSlash(enemy,nil,false) and not p:inMyAttackRange(enemy) then
						return p
					end
				end
			end
		end
	end
	for _,p in ipairs(self.friends_noself)do
		if (getCardsNum("Slash",p)>0 or p:getHandcardNum()>=3) and not self:canUse(slash,self:getEnemies(p),p) then
			for _,enemy in ipairs(self:getEnemies(p))do
				if p:canSlash(enemy,nil,false) and not p:inMyAttackRange(enemy) then
					return p
				end
			end
		end
	end
	for _,p in ipairs(self.friends_noself)do
		if self:canUse(slash,self:getEnemies(p),p) and #self:getEnemies(p)>1 and (getCardsNum("Slash",p)==1 or p:getHandcardNum()>=3) then
			return p
		end
	end
	for _,p in ipairs(self.friends_noself)do
		if p:getHandcardNum()<3 then
			return p
		end
	end
	
	self:sort(self.enemies,"handcard")
	if #self.enemies>0 and #self:getEnemies(self.enemies[1])<=1 then
		return self.enemies[1]
	end
	return nil
end

sgs.ai_skill_use["@@jieyingh"] = function(self,prompt,method)
	if self.player:hasFlag("jieyingh_now_use_collateral")
	then
		local card_str = self.player:property("extra_collateral"):toString()
		local card = sgs.Card_Parse(card_str)
		if not card then return "." end
		local dummy_use = {isDummy = true,to = sgs.SPlayerList()}
		dummy_use.current_targets = self.player:property("extra_collateral_current_targets"):toString():split("+")
		self:useCardCollateral(card,dummy_use)
		if dummy_use.card and dummy_use.to:length()==2 then
			return "@ExtraCollateralCard=.->"..dummy_use.to:first().."+"..dummy_use.to:last()
		end
	else
		local use = self.player:getTag("jieyinghData"):toCardUse()
		if not use then return "." end
		self.player:setTag("yb_zhuzhan2_data",ToData(use))
		local tos = sgs.SPlayerList()
		for _,p in sgs.qlist(self.room:getOtherPlayers(self.player))do
			if use.to:contains(p) then continue end
			if self.player:canUse(use.card,p,true)
			then tos:append(p) end
		end
		tos = sgs.ai_skill_playerchosen.yb_zhuzhan2(self,tos)
		if tos then return "@JieyinghCard=.->"..tos:objectName() end
	end
	return "."
end

--危迫
sgs.ai_skill_discard.weipo = function(self,discard_num,min_num,optional,include_equip)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByUseValue(cards,true)
	return {cards[1]:getEffectiveId()}
end

--敏思
addAiSkills("minsi").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	local function toids(cs)
		local ids = {}
		for _,c1 in sgs.list(cs)do
			table.insert(ids,c1:getEffectiveId())
		end
		return ids
	end
	local function minsiNumber(cs,c)
		local n = c:getNumber()
		for _,c1 in sgs.list(cs)do
			n = n+c1:getNumber()
		end
		return n==13 and 2 or n<=13 and 1 or 0 
	end
  	for _,c in sgs.list(cards)do
		local cs = {c}
		for i,c1 in sgs.list(cards)do
			if table.contains(cs,c1) then continue end
			i = minsiNumber(cs,c1)
			if i>0
			then
				table.insert(cs,c1)
				if i>1
				then
					cs = toids(cs)
					return sgs.Card_Parse("@MinsiCard="..table.concat(cs,"+"))
				end
				for i,c2 in sgs.list(cards)do
					if table.contains(cs,c2) then continue end
					i = minsiNumber(cs,c2)
					if i>0
					then
						table.insert(cs,c2)
						if i>1
						then
							cs = toids(cs)
							return sgs.Card_Parse("@MinsiCard="..table.concat(cs,"+"))
						end
					end
				end
			end
		end
	end
  	for _,c in sgs.list(cards)do
		if c:getNumber()==13
		then
			return sgs.Card_Parse("@MinsiCard="..c:getEffectiveId())
		end
	end
end

sgs.ai_skill_use_func["MinsiCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.MinsiCard = 9.4
sgs.ai_use_priority.MinsiCard = 4.8

--吉境
sgs.ai_skill_invoke.jijing = function(self,data)
    return self.player:isWounded()
end

sgs.ai_skill_use["@@jijing"] = function(self,prompt)
	local valid,ts = {},sgs.IntList()
	local jn = self.player:property("jijing_judge"):toInt()
	local function toids(cs)
		local ids = {}
		for _,c1 in sgs.list(cs)do
			table.insert(ids,c1:getEffectiveId())
		end
		return ids
	end
	local function minsiNumber(cs,c)
		local n = c:getNumber()
		for _,c1 in sgs.list(cs)do
			n = n+c1:getNumber()
		end
		return n==jn and 2 or n<=jn and 1 or 0 
	end
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
  	for _,c in sgs.list(cards)do
		if c:getNumber()==jn
		then
			return string.format("@JijingCard=%s",c:getEffectiveId())
		end
	end
  	for _,c in sgs.list(cards)do
		local cs = {c}
		for i,c1 in sgs.list(cards)do
			if table.contains(cs,c1) then continue end
			i = minsiNumber(cs,c1)
			if i>0
			then
				table.insert(cs,c1)
				if i>1
				then
					cs = toids(cs)
					return string.format("@JijingCard=%s",table.concat(cs,"+"))
				end
				for i,c2 in sgs.list(cards)do
					if table.contains(cs,c2) then continue end
					i = minsiNumber(cs,c2)
					if i>0
					then
						table.insert(cs,c2)
						if i>1
						then
							cs = toids(cs)
							return string.format("@JijingCard=%s",table.concat(cs,"+"))
						end
					end
				end
			end
		end
	end
end

--追德
sgs.ai_skill_playerchosen.zhuide = function(self,targets)
	self:sort(self.friends_noself)
	for _,p in ipairs(self.friends_noself)do
		if self:needKongcheng(p,true) or hasManjuanEffect(p) then continue end
		return p
	end
	local jink,ana,peach,slash = false,false,false,false
	for _,id in sgs.qlist(self.room:getDrawPile())do
		local card = sgs.Sanguosha:getCard(id)
		if card:isKindOf("Jink") then jink = true
		elseif card:isKindOf("Analeptic") then ana = true
		elseif card:isKindOf("Peach") then peach = true
		elseif card:isKindOf("Slash") then slash = true end
		if jink and ana and peach and slash then break end
	end
	if (jink and ana) or (jink and peach) or (ana and peach) then
		for _,p in ipairs(self.friends_noself)do
			if hasManjuanEffect(p) then continue end
			return p
		end
	end
	if slash and not jink and not ana and not peach then
		self:sort(self.enemies)
		for _,p in ipairs(self.enemies)do
			if hasManjuanEffect(p) then continue end
			if not self:needKongcheng(p,true) then continue end
			if self:getEnemyNumBySeat(self.player,p,p)>0 then
				return p
			end
		end
	end
	return nil
end

--毒逝
sgs.ai_skill_playerchosen.spdushi = function(self,targets)
	targets = sgs.QList2Table(targets)
	for _,p in ipairs(targets)do
		if self:isEnemy(p) and not p:hasSkill("spdushi",true) then
			return p
		end
	end
	for _,p in ipairs(targets)do
		if not self:isFriend(p) and not p:hasSkill("spdushi",true) then
			return p
		end
	end
	for _,p in ipairs(targets)do
		if self:isEnemy(p) then
			return p
		end
	end
	for _,p in ipairs(targets)do
		if not self:isFriend(p) then
			return p
		end
	end
	for _,p in ipairs(targets)do
		if self:isFriend(p) and p:hasSkill("spdushi",true) then
			return p
		end
	end
	targets = sgs.reverse(targets)
	return targets[1]
end

--盗戟
local daoji_skill = {}
daoji_skill.name = "daoji"
table.insert(sgs.ai_skills,daoji_skill)
daoji_skill.getTurnUseCard = function(self)
	return sgs.Card_Parse("@DaojiCard=.")
end

sgs.ai_skill_use_func.DaojiCard = function(card,use,self)
	local id = -1
	if self:needToThrowArmor() and self.player:canDiscard(self.player,self.player:getArmor():getEffectiveId()) then id = self.player:getArmor():getEffectiveId() end
	if id<0 and self.player:getWeapon() and self.player:canDiscard(self.player,self.player:getWeapon():getEffectiveId()) then id = self.player:getWeapon():getEffectiveId() end
	local cards = {}
	for _,c in sgs.qlist(self.player:getCards("he"))do
		if c:isKindOf("BasicCard") or self.player:canDiscard(self.player,c:getEffectiveId()) then continue end
		table.insert(cards,c)
	end
	if #cards>0 then
		self:sortByKeepValue(cards)
		if cards[1]:objectName()~="wooden_ox" or self.player:getPile("wooden_ox"):isEmpty() then
			if id<0 then id = cards[1]:getEffectiveId() end
		end
	end
	
	self:sort(self.enemies,"hp")
	self.daoji_throwcard = nil
	if id>=0 then
		for _,p in ipairs(self.enemies)do
			local damage = self:ajustDamage(self.player,p)
			if damage>=p:getHp() and self:damageIsEffective(p,nil,self.player) and p:getWeapon() then
				local weapon = sgs.Sanguosha:getCard(p:getWeapon():getEffectiveId())
				if self.player:canUse(weapon) then
					self.daoji_throwcard = weapon
					use.card = sgs.Card_Parse("@DaojiCard="..id)
					if use.to then use.to:append(p) end
					return
				end
			end
		end
		for _,p in ipairs(self.enemies)do
			if self:damageIsEffective(p,nil,self.player) and p:getWeapon() and not self:doNotDiscard(p,"e") then
				local weapon = sgs.Sanguosha:getCard(p:getWeapon():getEffectiveId())
				if self.player:canUse(weapon) then
					self.daoji_throwcard = weapon
					use.card = sgs.Card_Parse("@DaojiCard="..id)
					if use.to then use.to:append(p) end
					return
				end
			end
		end
	end
	
	self:sort(self.enemies)
	if self.player:getTreasure() and self.player:canDiscard(self.player,self.player:getTreasure():getEffectiveId()) then
		if self.player:getTreasure():objectName()~="wooden_ox" or self.player:getPile("wooden_ox"):isEmpty() then
			for _,p in ipairs(self.enemies)do
				if p:getTreasure() and not self:doNotDiscard(p,"e") then
					local treasure = sgs.Sanguosha:getCard(p:getTreasure():getEffectiveId())
					if treasure:objectName()=="wooden_ox" and not p:getPile("wooden_ox"):isEmpty() then
						if self.player:canUse(treasure) then
							self.daoji_throwcard = treasure
							use.card = sgs.Card_Parse("@DaojiCard="..self.player:getTreasure():getEffectiveId())
							if use.to then use.to:append(p) end
							return
						end
					end
				end
			end
		end
	end
	if self.player:getArmor() and self.player:canDiscard(self.player,self.player:getArmor():getEffectiveId()) then
		for _,p in ipairs(self.enemies)do
			if p:getArmor() and not self:doNotDiscard(p,"e") then
				local armor = sgs.Sanguosha:getCard(p:getArmor():getEffectiveId())
				if self.player:canUse(armor) then
					self.daoji_throwcard = armor
					use.card = sgs.Card_Parse("@DaojiCard="..self.player:getArmor():getEffectiveId())
					if use.to then use.to:append(p) end
					return
				end
			end
		end
	end
	if self.player:getDefensiveHorse() and self.player:canDiscard(self.player,self.player:getDefensiveHorse():getEffectiveId()) then
		for _,p in ipairs(self.enemies)do
			if p:getDefensiveHorse() and not self:doNotDiscard(p,"e") then
				local horse = sgs.Sanguosha:getCard(p:getDefensiveHorse():getEffectiveId())
				if self.player:canUse(horse) then
					self.daoji_throwcard = horse
					use.card = sgs.Card_Parse("@DaojiCard="..self.player:getDefensiveHorse():getEffectiveId())
					if use.to then use.to:append(p) end
					return
				end
			end
		end
	end
	if self.player:getOffensiveHorse() and self.player:canDiscard(self.player,self.player:getOffensiveHorse():getEffectiveId()) then
		for _,p in ipairs(self.enemies)do
			if p:getOffensiveHorse() and not self:doNotDiscard(p,"e") then
				local horse = sgs.Sanguosha:getCard(p:getOffensiveHorse():getEffectiveId())
				if self.player:canUse(horse) then
					self.daoji_throwcard = horse
					use.card = sgs.Card_Parse("@DaojiCard="..self.player:getOffensiveHorse():getEffectiveId())
					if use.to then use.to:append(p) end
					return
				end
			end
		end
	end
	if self.player:getTreasure() and self.player:canDiscard(self.player,self.player:getTreasure():getEffectiveId()) then
		if self.player:getTreasure():objectName()~="wooden_ox" or self.player:getPile("wooden_ox"):isEmpty() then
			for _,p in ipairs(self.enemies)do
				if p:getTreasure() and not self:doNotDiscard(p,"e") then
					local treasure = sgs.Sanguosha:getCard(p:getTreasure():getEffectiveId())
					if self.player:canUse(treasure) then
						self.daoji_throwcard = treasure
						use.card = sgs.Card_Parse("@DaojiCard="..self.player:getTreasure():getEffectiveId())
						if use.to then use.to:append(p) end
						return
					end
				end
			end
		end
	end
	
	if id>=0 then
		for _,p in ipairs(self.enemies)do
			if not self:doNotDiscard(p,"e") then
				local c
				if p:getTreasure() and p:getTreasure():objectName()=="wooden_ox" and not p:getPile("wooden_ox"):isEmpty() then
					c = sgs.Sanguosha:getCard(p:getTreasure():getEffectiveId())
				elseif p:getArmor() and not self.player:getArmor() then
					c = sgs.Sanguosha:getCard(p:getArmor():getEffectiveId())
				elseif p:getDefensiveHorse() and not self.player:getDefensiveHorse() then
					c = sgs.Sanguosha:getCard(p:getDefensiveHorse():getEffectiveId())
				elseif p:getOffensiveHorse() and not self.player:getOffensiveHorse() then
					c = sgs.Sanguosha:getCard(p:getOffensiveHorse():getEffectiveId())
				elseif p:getTreasure() and not self.player:getTreasure() then
					c = sgs.Sanguosha:getCard(p:getTreasure():getEffectiveId())
				end
				if c then
					self.daoji_throwcard = treasure
					use.card = sgs.Card_Parse("@DaojiCard="..id)
					if use.to then use.to:append(p) end
					return
				end
			end
		end
		for _,p in ipairs(self.enemies)do
			if not self:doNotDiscard(p,"e") then
				use.card = sgs.Card_Parse("@DaojiCard="..id)
				if use.to then use.to:append(p) end
				return
			end
		end
	end
end

sgs.ai_use_priority.DaojiCard = sgs.ai_use_priority.Slash+0.1

sgs.ai_skill_cardchosen.daoji = function(self,who,flags)
	if self.daoji_throwcard and who:getCards("e"):contains(self.daoji_throwcard) then return self.daoji_throwcard end
	if who:getCards("e"):length()==1 then return who:getCards("e"):first() end
	return self:askForCardChosen(who,"e","snatch")
end

--手杀逆乱
sgs.ai_skill_cardask["@mobileniluan"] = function(self,data,pattern,target)
	if target then
		for _,slash in ipairs(self:getCards("Slash"))do
			if self:isFriend(target) and self:slashIsEffective(slash,target) then
				if self:needLeiji(target,self.player) then return slash:toString() end
				if self:needToLoseHp(target,self.player,slash,true) then return slash:toString() end
			end
			if self:isEnemy(target) and self:slashIsEffective(slash,target)
			and not self:needToLoseHp(target,self.player,slash) and not self:needLeiji(target,self.player) 
			then return slash:toString() end
		end
	end
	return "."
end

--骁袭
sgs.ai_view_as.mobilexiaoxi = function(card,player,card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place~=sgs.Player_PlaceSpecial and card:isBlack() and not card:isKindOf("Peach") and not card:hasFlag("using") then
		return ("slash:mobilexiaoxi[%s:%s]=%d"):format(suit,number,card_id)
	end
end

local mobilexiaoxi_skill = {}
mobilexiaoxi_skill.name = "mobilexiaoxi"
table.insert(sgs.ai_skills,mobilexiaoxi_skill)
mobilexiaoxi_skill.getTurnUseCard = function(self,inclusive)
	local cards = self:addHandPile("he")
	local red_card
	self:sortByUseValue(cards,true)

	local useAll = false
	self:sort(self.enemies,"defense")
	for _,enemy in ipairs(self.enemies)do
		if enemy:getHp()==1 and not enemy:hasArmorEffect("EightDiagram") and self.player:distanceTo(enemy)<=self.player:getAttackRange() and self:isWeak(enemy)
			and getCardsNum("Jink",enemy,self.player)+getCardsNum("Peach",enemy,self.player)+getCardsNum("Analeptic",enemy,self.player)==0 then
			useAll = true
			break
		end
	end

	local disCrossbow = false
	if self:getCardsNum("Slash")<2 or self.player:hasSkills("paoxiao|tenyearpaoxiao|olpaoxiao") then
		disCrossbow = true
	end

	local nuzhan_equip = false
	local nuzhan_equip_e = false
	self:sort(self.enemies,"defense")
	if self.player:hasSkill("nuzhan") then
		for _,enemy in ipairs(self.enemies)do
			if  not enemy:hasArmorEffect("EightDiagram") and self.player:distanceTo(enemy)<=self.player:getAttackRange()
			and getCardsNum("Jink",enemy)<1 then
				nuzhan_equip_e = true
				break
			end
		end
		for _,card in ipairs(cards)do
			if card:isBlack() and card:isKindOf("TrickCard") and nuzhan_equip_e then
				nuzhan_equip = true
				break
			end
		end
	end

	local nuzhan_trick = false
	local nuzhan_trick_e = false
	self:sort(self.enemies,"defense")
	if self.player:hasSkill("nuzhan") and not self.player:hasFlag("hasUsedSlash") and self:getCardsNum("Slash")>1 then
		for _,enemy in ipairs(self.enemies)do
			if  not enemy:hasArmorEffect("EightDiagram") and self.player:distanceTo(enemy)<=self.player:getAttackRange() then
				nuzhan_trick_e = true
				break
			end
		end
		for _,card in ipairs(cards)do
			if card:isBlack() and card:isKindOf("TrickCard") and nuzhan_trick_e then
				nuzhan_trick = true
				break
			end
		end
	end

	for _,card in ipairs(cards)do
		if card:isBlack() and not card:isKindOf("Slash") and not (nuzhan_equip or nuzhan_trick)
			and (not isCard("Peach",card,self.player) and not isCard("ExNihilo",card,self.player) and not useAll)
			and (not isCard("Crossbow",card,self.player) or disCrossbow)
			and (self:getUseValue(card)<sgs.ai_use_value.Slash or inclusive or sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue,self.player,sgs.Sanguosha:cloneCard("slash"))>0) then
			red_card = card
			break
		end
	end

	if nuzhan_equip then
		for _,card in ipairs(cards)do
			if card:isBlack() and card:isKindOf("EquipCard") then
				red_card = card
				break
			end
		end
	end

	if nuzhan_trick then
		for _,card in ipairs(cards)do
			if card:isBlack() and card:isKindOf("TrickCard")then
				red_card = card
				break
			end
		end
	end

	if red_card then
		local suit = red_card:getSuitString()
		local number = red_card:getNumberString()
		local card_id = red_card:getEffectiveId()
		return sgs.Card_Parse(("slash:mobilexiaoxi[%s:%s]=%d"):format(suit,number,card_id))
	end
end

function sgs.ai_cardneed.mobilexiaoxi(to,card)
	return to:getHandcardNum()<3 and card:isBlack()
end

--评荐
sgs.ai_skill_invoke.pingjian = function(self,data)
    return true
end

function PingjianSkill(player)
	local pingjian_skills = player:property("pingjian_has_used_skills"):toStringList()
	local sks = canAiSkills()
	for i=1,99 do
		if #sks<1 then break end
		local sk = sks[math.random(1,#sks)]
		if table.contains(pingjian_skills,sk.name) then continue end
		i = sgs.Sanguosha:getSkill(sk.name)
		if i
		then
			i = i:getDescription()
			if string.find(i,"出牌阶段限一次，")
			or string.find(i,"阶段技，")
			or string.find(i,"出牌阶段限一次。")
			or string.find(i,"阶段技。")
			or string.find(i,"出牌阶段限一次")
			or string.find(i,"阶段技")
			then return sk end
		end
	end
end

addAiSkills("pingjian").getTurnUseCard = function(self)
	for i=1,3 do
		local tosk = PingjianSkill(self.player)
		if tosk and sgs.Sanguosha:getViewAsSkill(tosk.name):isEnabledAtPlay(self.player)
		then
			self.pjsk_to = tosk.ai_fill_skill(self,false)
			if not self.pjsk_to then continue end
			local use = self:aiUseCard(self.pjsk_to)
			if use.card
			then
				self.pjsk_to = use.to
				local ids = sgs.QList2Table(use.card:getSubcards())
				ids = #ids>0 and table.concat(ids,"+") or "."
				sgs.ai_use_priority.PingjianCard = sgs.ai_use_priority[use.card:getClassName()] or 5
				return sgs.Card_Parse("@PingjianCard="..ids..":"..tosk.name)
			end
		end
	end
end

sgs.ai_skill_use_func["PingjianCard"] = function(card,use,self)
	if self.pjsk_to
	then
		use.card = card
		if use.to
		then
			use.to = self.pjsk_to
		end
	end
end

sgs.ai_use_value.PingjianCard = 9.4
sgs.ai_use_priority.PingjianCard = 10.8


--授符
local shoufu_skill = {}
shoufu_skill.name = "shoufu"
table.insert(sgs.ai_skills,shoufu_skill)
shoufu_skill.getTurnUseCard = function(self)
	for _,p in ipairs(self.enemies)do
		if p:getPile("sflu"):isEmpty() then
			return sgs.Card_Parse("@ShoufuCard=.")
		end
	end
end

sgs.ai_skill_use_func.ShoufuCard = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.ShoufuCard = sgs.ai_use_value.Slash+1

sgs.ai_skill_use["@@shoufu!"] = function(self,prompt,method)
	self:sort(self.enemies,"handcard")
	self.enemies = sgs.reverse(self.enemies)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	for _,p in ipairs(self.enemies)do
		if p:getPile("sflu"):isEmpty() then
			return "@ShoufuPutCard="..cards[1]:getEffectiveId().."->"..p:objectName()
		end
	end
	return "."
end

--颂词
local tenyearsongci_skill = {}
tenyearsongci_skill.name = "tenyearsongci"
table.insert(sgs.ai_skills,tenyearsongci_skill)
tenyearsongci_skill.getTurnUseCard = function(self)
	return sgs.Card_Parse("@TenyearSongciCard=.")
end

sgs.ai_skill_use_func.TenyearSongciCard = function(card,use,self)
	self:sort(self.friends,"handcard")
	for _,friend in ipairs(self.friends)do
		if friend:getMark("tenyearsongci"..self.player:objectName())==0 and friend:getHandcardNum()<=friend:getHp() and self:canDraw(friend) then
			use.card = sgs.Card_Parse("@TenyearSongciCard=.")
			if use.to then use.to:append(friend) end
			return
		end
	end

	self:sort(self.enemies,"handcard")
	self.enemies = sgs.reverse(self.enemies)
	for _,enemy in ipairs(self.enemies)do
		if enemy:getMark("tenyearsongci"..self.player:objectName())==0 and enemy:getHandcardNum()>enemy:getHp() and not enemy:isNude()
			and not self:doNotDiscard(enemy,nil,false,2) then
			use.card = sgs.Card_Parse("@TenyearSongciCard=.")
			if use.to then use.to:append(enemy) end
			return
		end
	end
end

sgs.ai_use_value.TenyearSongciCard = sgs.ai_use_value.SongciCard
sgs.ai_use_priority.TenyearSongciCard = sgs.ai_use_priority.SongciCard

--游龙
addAiSkills("youlong").getTurnUseCard = function(self)
	for _,name in sgs.list(patterns)do
        local c = sgs.Sanguosha:cloneCard(name)
		if c and c:isAvailable(self.player)
		and self.player:getMark("youlong_"..name)<1
		and (c:isKindOf("BasicCard") and self.player:getMark("youlong_basic_lun")<1 and self.player:getChangeSkillState("youlong")>1
		or c:isNDTrick() and self.player:getMark("youlong_trick_lun")<1 and self.player:getChangeSkillState("youlong")<2)
		and self:getCardsNum(c:getClassName())<1
		and self.player:hasEquipArea()
		then
         	local dummy = self:aiUseCard(c)
    		if dummy.card
	    	and dummy.to
	     	then
	           	if c:canRecast()
				and dummy.to:length()<1
				then continue end
				self.yl_to = dummy.to
				sgs.ai_use_priority.YoulongCard = sgs.ai_use_priority[c:getClassName()]
                return sgs.Card_Parse("@YoulongCard=.:"..name)
			end
		end
		if c then c:deleteLater() end
	end
end

sgs.ai_skill_use_func["YoulongCard"] = function(card,use,self)
	use.card = card
	if use.to then use.to = self.yl_to end
end

sgs.ai_use_value.YoulongCard = 10.4
sgs.ai_use_priority.YoulongCard = 10.4

sgs.ai_guhuo_card.youlong = function(self,toname,class_name)
	if self:getCardsNum(class_name)<1
	then
        return "@YoulongCard=.:"..toname
	end
end

--鸾凤
sgs.ai_skill_invoke.luanfeng = function(self,data)
	local target = data:toPlayer()
	if target:hasSkill("niepan") and target:getMark("@nirvana")>0 then return false end
	if target:hasSkill("mobileniepan") and target:getMark("@mobileniepanMark")>0 then return false end
	if target:hasSkill("olniepan") and target:getMark("@olniepanMark")>0 then return false end
	return self:isFriend(target)
end

--战意
local secondzhanyi_skill = {}
secondzhanyi_skill.name = "secondzhanyi"
table.insert(sgs.ai_skills,secondzhanyi_skill)
secondzhanyi_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("SecondZhanyiCard") then
		return sgs.Card_Parse("@SecondZhanyiCard=.")
	end
	if self.player:getMark("ViewAsSkill_secondzhanyiEffect-PlayClear")>0 then
		local use_basic = self:ZhanyiUseBasic()
		local cards = self.player:getCards("h")
		cards=sgs.QList2Table(cards)
		self:sortByUseValue(cards,true)
		local BasicCards = {}
		for _,card in ipairs(cards)do
			if card:isKindOf("BasicCard") then
				table.insert(BasicCards,card)
			end
		end
		if use_basic and #BasicCards>0 then
			return sgs.Card_Parse("@SecondZhanyiViewAsBasicCard="..BasicCards[1]:getId()..":"..use_basic)
		end
	end
end

sgs.ai_skill_use_func.SecondZhanyiCard = function(card,use,self)
	local to_discard
	local cards = self.player:getCards("h")
	cards=sgs.QList2Table(cards)
	self:sortByUseValue(cards,true)

	local TrickCards = {}
	for _,card in ipairs(cards)do
		if card:isKindOf("Disaster") or card:isKindOf("GodSalvation") or card:isKindOf("AmazingGrace") or self:getCardsNum("TrickCard")>1 then
			table.insert(TrickCards,card)
		end
	end
	if #TrickCards>0 and (self.player:getHp()>2 or self:getCardsNum("Peach")>0 ) and self.player:getHp()>1 then
		to_discard = TrickCards[1]
	end

	local EquipCards = {}
	if self:needToThrowArmor() and self.player:getArmor() then table.insert(EquipCards,self.player:getArmor()) end
	for _,card in ipairs(cards)do
		if card:isKindOf("EquipCard") then
			table.insert(EquipCards,card)
		end
	end
	if not self:isWeak() and self.player:getDefensiveHorse() then table.insert(EquipCards,self.player:getDefensiveHorse()) end
	if self.player:hasTreasure("wooden_ox") and self.player:getPile("wooden_ox"):length()==0 then table.insert(EquipCards,self.player:getTreasure()) end
	self:sort(self.enemies,"defense")
	if self:getCardsNum("Slash")>0 and
	((self.player:getHp()>2 or self:getCardsNum("Peach")>0 ) and self.player:getHp()>1) then
		for _,enemy in ipairs(self.enemies)do
			if (self:isWeak(enemy)) or (enemy:getCardCount(true)<=4 and enemy:getCardCount(true)>=1)
				and self.player:canSlash(enemy) and self:slashIsEffective(sgs.Sanguosha:cloneCard("slash"),enemy,self.player)
				and self.player:inMyAttackRange(enemy) and not self:needToThrowArmor(enemy) then
				to_discard = EquipCards[1]
				break
			end
		end
	end

	local BasicCards = {}
	for _,card in ipairs(cards)do
		if card:isKindOf("BasicCard") then
			table.insert(BasicCards,card)
		end
	end
	local use_basic = self:ZhanyiUseBasic()
	if (use_basic=="peach" and self.player:getHp()>1 and #BasicCards>3)
	--or (use_basic=="analeptic" and self.player:getHp()>1 and #BasicCards>2)
	or (use_basic=="slash" and self.player:getHp()>1 and #BasicCards>1)
	then
		to_discard = BasicCards[1]
	end

	if to_discard then
		use.card = sgs.Card_Parse("@SecondZhanyiCard="..to_discard:getEffectiveId())
		return
	end
end

sgs.ai_use_priority.SecondZhanyiCard = sgs.ai_use_priority.ZhanyiCard

sgs.ai_skill_use_func.SecondZhanyiViewAsBasicCard=function(card,use,self)
	local userstring=card:toString()
	userstring=(userstring:split(":"))[3]
	local zhanyicard=sgs.Sanguosha:cloneCard(userstring,card:getSuit(),card:getNumber())
	zhanyicard:setSkillName("secondzhanyi")
	zhanyicard:deleteLater()
	if zhanyicard:getTypeId()==sgs.Card_TypeBasic then
		if not use.isDummy and use.card and zhanyicard:isKindOf("Slash") and (not use.to or use.to:isEmpty()) then return end
		self:useBasicCard(zhanyicard,use)
	end
	if not use.card then return end
	use.card=card
end

sgs.ai_use_priority.SecondZhanyiViewAsBasicCard = sgs.ai_use_priority.ZhanyiViewAsBasicCard

--偏宠
sgs.ai_skill_invoke.pianchong = function(self,data)
	return self.player:getPile("yiji"):isEmpty()
end

sgs.ai_skill_choice.pianchong = function(self,choices,data)
	local use_red,use_black,red,black = 0,0,0,0
	for _,c in sgs.qlist(self.player:getCards("h"))do
		if not self:willUse(self.player,c,false,false,true) then continue end
		if c:isRed() then use_red = use_red+1
		elseif c:isBlack() then use_black = use_black+1 end
	end
	if use_red>use_black then return "red"
	elseif use_red<use_black then return "black"
	else
		if red>black then return "red"
		elseif red<black then return "black" end
	end
	choices = choices:split("+")
	return choices[math.random(1,#choices)]
end

--尊位
local zunwei_skill = {}
zunwei_skill.name = "zunwei"
table.insert(sgs.ai_skills,zunwei_skill)
zunwei_skill.getTurnUseCard = function(self)
	return sgs.Card_Parse("@ZunweiCard=.")
end

sgs.ai_skill_use_func.ZunweiCard = function(card,use,self)
	local recover_t,draw_t,equip_t = {},{},{}
	if not self.player:property("zunwei_draw"):toBool() and self:canDraw() then
		for _,p in sgs.qlist(self.room:getOtherPlayers(self.player))do
			if p:getHandcardNum()>self.player:getHandcardNum() then
				table.insert(draw_t,p)
			end
		end
	end
	if not self.player:property("zunwei_recover"):toBool() and self.player:getLostHp()>0 then
		for _,p in sgs.qlist(self.room:getOtherPlayers(self.player))do
			if p:getHp()>self.player:getHp() then
				table.insert(recover_t,p)
			end
		end
	end
	if not self.player:property("zunwei_equip"):toBool() and self.player:hasEquipArea() then
		for _,p in sgs.qlist(self.room:getOtherPlayers(self.player))do
			if p:getEquips():length()>self.player:getEquips():length() then
				table.insert(equip_t,p)
			end
		end
	end
	if #recover_t==0 and #draw_t==0 and #equip_t==0 then return end
	
	if #recover_t>0 then self:sort(recover_t,"hp") recover_t = sgs.reverse(recover_t) end
	if #draw_t>0 then self:sort(draw_t,"handcard") draw_t = sgs.reverse(draw_t) end
	if #equip_t>0 then self:sort(equip_t,"equip") equip_t = sgs.reverse(equip_t) end
	
	if self:isWeak() then
		if #recover_t>0 then
			sgs.ai_use_priority.ZunweiCard = 10
			sgs.ai_skill_choice.zunwei = "recover"
			use.card = card
			if use.to then use.to:append(recover_t[1]) end
			return
		end
		
		if #draw_t>0 then
			sgs.ai_skill_choice.zunwei = "draw"
			use.card = card
			if use.to then use.to:append(draw_t[1]) end
			return
		end
		
		if #equip_t>0 then
			sgs.ai_skill_choice.zunwei = "equip"
			use.card = card
			if use.to then use.to:append(equip_t[1]) end
			return
		end
	end
	
	if #recover_t>0 and recover_t[1]:getHp()-self.player:getHp()>=2 and self.player:getLostHp()>=2 then
		sgs.ai_skill_choice.zunwei = "recover"
		use.card = card
		if use.to then use.to:append(recover_t[1]) end
		return
	end
		
	if #draw_t>0 and ((draw_t[1]:getHandcardNum()-self.player:getHandcardNum()>=2 and sgs.Slash_IsAvailable(self.player)) or
	draw_t[1]:getHandcardNum()-self.player:getHandcardNum()>=4) then
		sgs.ai_skill_choice.zunwei = "draw"
		use.card = card
		if use.to then use.to:append(draw_t[1]) end
		return
	end
		
	if #equip_t>0 and equip_t[1]:getEquips():length()-self.player:getEquips():length()>=2 then
		sgs.ai_skill_choice.zunwei = "equip"
		use.card = card
		if use.to then use.to:append(equip_t[1]) end
		return
	end
end

sgs.ai_use_priority.ZunweiCard = 0

--讨灭
sgs.ai_skill_invoke.taomie = function(self,data)
	local player = data:toPlayer()
	return not self:isFriend(player)
end

sgs.ai_skill_choice.taomie = function(self,choices,data)
	local damage = data:toDamage()
	local to = damage.to
	choices = choices:split("+")
	
	local damage = getChoice(choices,"damage")
	local get = getChoice(choices,"get")
	local all = getChoice(choices,"all")
	
	if #choices==2 then
		table.removeOne(choices,all)
		return choices[1]
	end
	if #choices==3 then
		if self:cantDamageMore(self.player,to) then
			if self:doNotDiscard(to,"hej") then return damage end
			return get
		end
		if self:doNotDiscard(to,"hej") then return damage end
		return all
	end
	return choices[1]
end

sgs.ai_skill_askforyiji.taomie = function(self,card_ids)
	return sgs.ai_skill_askforyiji.nosyiji(self,card_ids)
end

--粮营
sgs.ai_skill_invoke.liangying = function(self,data)
	for _,p in ipairs(self.friends)do
		if self:canDraw(p) then return true end
	end
	return false
end

sgs.ai_skill_choice.liangying = function(self,choices,data)
	choices = choices:split("+")
	local n = tonumber(choices[#choices])
	n = math.min(n,#self.friends)
	for _,p in ipairs(self.friends)do
		if not self:canDraw(p) then n = n-1 end
	end
	if n>0 then
		return ""..n
	else
		return choices[1]
	end
end

sgs.ai_skill_askforyiji.liangying = function(self,card_ids)
	local friends = {}
	for _,p in ipairs(self.friends)do
		if p:getMark("liangying-Clear")<=0
		then
			table.insert(friends,p)
		end
	end
	local toGive,allcards = {},{}
	local keep
	for _,id in ipairs(card_ids)do
		local card = sgs.Sanguosha:getCard(id)
		if not keep and (isCard("Jink",card,self.player) or isCard("Analeptic",card,self.player))
		then keep = true else table.insert(toGive,card) end
		table.insert(allcards,card)
	end
	local cards = #toGive>0 and toGive or allcards
	self:sortByKeepValue(cards,true)
	local id = cards[1]:getId()
	local card,friend = self:getCardNeedPlayer(cards,true,friends)
	if card and friend and table.contains(friends,friend) then return friend,card:getId() end
	if #friends>0
	then
		self:sort(friends,"handcard")
		for _,afriend in ipairs(friends)do
			if not self:needKongcheng(afriend,true)
			then return afriend,id end
		end
		self:sort(friends,"defense")
		return friends[1],id
	end
	return nil,-1
end

--把盏
local bazhan_skill = {}
bazhan_skill.name = "bazhan"
table.insert(sgs.ai_skills,bazhan_skill)
bazhan_skill.getTurnUseCard = function(self)
	return sgs.Card_Parse("@BazhanCard=.")
end

sgs.ai_skill_use_func.BazhanCard = function(card,use,self)
	local n = self.player:getChangeSkillState("bazhan")
	if n~=1 and n~=2 then return end
	if n==1 then
		if self.player:isKongcheng() then return end
		local cards = sgs.QList2Table(self.player:getCards("h"))
		self:sortByUseValue(cards,true)
		local hearts = {}
		for _,c in ipairs(cards)do
			if c:isKindOf("Analeptic") or c:getSuit()==sgs.Card_Heart then
				table.insert(hearts,c)
			end
		end
		if #hearts>0 then
			self:sort(self.friends_noself,"hp")
			for _,p in ipairs(self.friends_noself)do
				if self:isWeak(p) and p:getLostHp()>0 and not (p:isKongcheng() and self:needKongcheng(p,true)) then
					sgs.ai_use_priority.BazhanCard = 7
					use.card = sgs.Card_Parse("@BazhanCard="..hearts[1]:getEffectiveId())
					if use.to then use.to:append(p) end
					return
				end
			end
			
			self:sort(self.friends_noself)
			for _,p in ipairs(self.friends_noself)do
				if not p:faceUp() and not (p:isKongcheng() and self:needKongcheng(p,true)) then
					sgs.ai_use_priority.BazhanCard = 7
					use.card = sgs.Card_Parse("@BazhanCard="..hearts[1]:getEffectiveId())
					if use.to then use.to:append(p) end
					return
				end
			end
			
			local card,friend = self:getCardNeedPlayer({hearts[1]},false)
			if card and friend then
				sgs.ai_use_priority.BazhanCard = 7
				use.card = sgs.Card_Parse("@BazhanCard="..card:getEffectiveId())
				if use.to then use.to:append(friend) end
				return
			end
		end
		
		if self:getOverflow()>0 then
			if not cards[1]:isKindOf("Jink") and not cards[1]:isKindOf("Peach") and not cards[1]:isKindOf("Analeptic") and not cards[1]:isKindOf("ExNihilo") then
				self:sort(self.enemies)
				for _,p in ipairs(self.enemies)do
					if p:isKongcheng() and self:needKongcheng(p,true) then
						use.card = sgs.Card_Parse("@BazhanCard="..cards[1]:getEffectiveId())
						if use.to then use.to:append(p) end
						return
					end
				end
			end
			
			local card,friend = self:getCardNeedPlayer({cards[1]},false)
			if card and friend then
				use.card = sgs.Card_Parse("@BazhanCard="..card:getEffectiveId())
				if use.to then use.to:append(friend) end
				return
			end
			
			self:sort(self.friends_noself,"handcard")
			for _,p in ipairs(self.friends_noself)do
				if not (p:isKongcheng() and self:needKongcheng(p,true)) and not self:willSkipPlayPhase(p) then
					use.card = sgs.Card_Parse("@BazhanCard="..cards[1]:getEffectiveId())
					if use.to then use.to:append(p) end
					return
				end
			end
			
			for _,p in ipairs(self.friends_noself)do
				if not (p:isKongcheng() and self:needKongcheng(p,true)) then
					use.card = sgs.Card_Parse("@BazhanCard="..cards[1]:getEffectiveId())
					if use.to then use.to:append(p) end
					return
				end
			end
		end
	else
		if self.player:isKongcheng() and self:needKongcheng(self.player,true) then return end
		self:sort(self.friends_noself)
		self.friends_noself = sgs.reverse(self.friends_noself)
		for _,p in ipairs(self.friends_noself)do
			if self:needToThrowLastHandcard(p) then
				use.card = sgs.Card_Parse("@BazhanCard=.")
				if use.to then use.to:append(p) end
				return
			end
		end
		
		self:sort(self.friends_noself,"handcard")
		self.friends_noself = sgs.reverse(self.friends_noself)
		for _,p in ipairs(self.friends_noself)do
			if self:doNotDiscard(p,"h") and not self:isWeak(p) then
				use.card = sgs.Card_Parse("@BazhanCard=.")
				if use.to then use.to:append(p) end
				return
			end
		end
		
		self:sort(self.enemies)
		for _,p in ipairs(self.enemies)do
			if not self:doNotDiscard(p,"h") then
				sgs.ai_use_priority.BazhanCard = sgs.ai_use_priority.Snatch
				use.card = sgs.Card_Parse("@BazhanCard=.")
				if use.to then use.to:append(p) end
				return
			end
		end
		
		for _,p in ipairs(self.friends_noself)do
			if self:getOverflow(p)>1 and (not self:isWeak(p) or self:willSkipPlayPhase(p)) then
				use.card = sgs.Card_Parse("@BazhanCard=.")
				if use.to then use.to:append(p) end
				return
			end
		end
	end
end

sgs.ai_use_priority.BazhanCard = 0

sgs.ai_skill_choice.bazhan = function(self,choices,data)
	local to = data:toPlayer()
	if not self:isFriend(to) then return "cancel" end
	choices = choices:split("+")
	
	local recover = getChoice(choices,"recover")
	local reset = getChoice(choices,"reset")
	
	if recover then
		if self:isWeak(to) then return recover end
		if not to:faceUp() then return reset end
		if to:isChained() and self:getFinalRetrial(to)==2 then
			if self:hasSkills("leiji|nosleiji|olleiji|",self.enemies) then return reset end
			for _,p in sgs.qlist(self.room:getAlivePlayers())do
				if not p:containsTrick("YanxiaoCard") and p:containsTrick("lightning") then
					return reset
				end
			end
		end
		return recover
	end
	return reset
end

--醮影
sgs.ai_skill_playerchosen.jiaoying = function(self,targets)
	local player = sgs.ai_skill_playerchosen.jieming(self,targets)
	if player then return player end
	return self.player
end

--殃众
sgs.ai_skill_cardask["@yangzhong"] = function(self,data,pattern,target)
	if not target or target:isDead() or self:isFriend(target) then return "." end
	local dis = {}
	if target:getHp()<=1 and not hasBuquEffect(target) then
		dis = self:askForDiscard("dummyreason",2,2,false,true)
		if #dis>=2 then
			return "$"..table.concat(dis,"+")
		else
			return "."
		end
	end
	if hasZhaxiangEffect(target) and not self:willSkipPlayPhase(target) then return "." end
	dis = self:askForDiscard("dummyreason",2,2,false,true)
	if #dis==2 then
		for _,id in ipairs(dis)do
			if sgs.Sanguosha:getCard(id):isKindOf("Peach") then return "." end
			if sgs.Sanguosha:getCard(id):isKindOf("Analeptic") and self:isWeak() then return "." end
		end
		return "$"..table.concat(dis,"+")
	end
	return "."
end

--礼赂
sgs.ai_skill_invoke.lilu = function(self,data)
	local invoke = false
	for _,p in ipairs(self.friends_noself)do
		if p:isKongcheng() and self:needKongcheng(p,true) then continue end
		invoke = true
		break
	end
	if not invoke then return false end
	local draw = math.min(self.player:getMaxHp(),5)-self.player:getHandcardNum()
	local mark = self.player:getMark("&lilu")
	if draw<=2 then
		if self:getOverflow()+math.max(draw,0)>=mark+1 and ((self.player:isSkipped(sgs.Player_Play) and self:getOverflow()+math.max(draw,0)>0) or
		self:getOverflow()-mark>=1 or mark<=1) then
			return true
		else
			return false
		end
	end
	--[[return draw+self.player:getHandcardNum()-mark>=2 or (self.player:hasSkill("kongcheng") and draw+self.player:getHandcardNum()<=mark) or 
		self.player:isSkipped(sgs.Player_Play)]]
	return true
end

sgs.ai_skill_use["@@lilu!"] = function(self,prompt)
	local mark = self.player:getMark("&lilu")
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByUseValue(cards,true)
	self:sort(self.friends_noself)
	
	local target
	for _,p in ipairs(self.friends_noself)do
		if self:canDraw(p) and not self:willSkipPlayPhase(p) then
			target = p
			break
		end
	end
	if not target then
		for _,p in ipairs(self.friends_noself)do
			if not (p:isKongcheng() and self:needKongcheng(p,true)) and not self:willSkipPlayPhase(p) then
				target = p
				break
			end
		end
	end
	if not target then
		for _,p in ipairs(self.friends_noself)do
			if self:canDraw(p) then
				target = p
				break
			end
		end
	end
	if not target then
		for _,p in ipairs(self.friends_noself)do
			if not (p:isKongcheng() and self:needKongcheng(p,true)) then
				target = p
				break
			end
		end
	end
	if not target then target = self.friends_noself[1] end
	
	local give,hand_num = {},self.player:getHandcardNum()
	if hand_num<mark+1 and target then
		if self:needToThrowLastHandcard(self.player,hand_num) then
			for _,c in ipairs(cards)do
				table.insert(give,c:getEffectiveId())
			end
			return "@LiluCard="..table.concat(give,"+").."->"..target:objectName()
		end
		local card,friend = self:getCardNeedPlayer(cards,false)
		if card and friend then
			return "@LiluCard="..card:getEffectiveId().."->"..friend:objectName()
		end
		return "@LiluCard="..cards[1]:getEffectiveId().."->"..target:objectName()
	end
	
	for i = 1,mark+1 do
		if #cards<i then break end
		table.insert(give,cards[i]:getEffectiveId())
	end
	if #give>0 and target then
		return "@LiluCard="..table.concat(give,"+").."->"..target:objectName()
	end
	return "."
end

--翊正
sgs.ai_skill_playerchosen.yizhengc = function(self,targets)
	if self.player:getMaxHp()<=3 or #self.friends_noself<=0 then return nil end
	local friends = {}
	for _,p in ipairs(self.friends_noself)do
		if p:getMaxHp()<self.player:getMaxHp() and p:getMark("&yizhengc+#"..self.player:objectName())<=0 and not self:willSkipPlayPhase(p) then
			table.insert(friends,p)
		end
	end
	if #friends>0 then
		self:sort(friends,"threat")
		return friends[1]
	end
	
	for _,p in ipairs(self.friends_noself)do
		if p:getMaxHp()<self.player:getMaxHp() and not self:willSkipPlayPhase(p) then
			table.insert(friends,p)
		end
	end
	if #friends>0 then
		self:sort(friends,"threat")
		return friends[1]
	end
	
	for _,p in ipairs(self.friends_noself)do
		if p:getMaxHp()<self.player:getMaxHp() and p:getMark("&yizhengc+#"..self.player:objectName())<=0 then
			table.insert(friends,p)
		end
	end
	if #friends>0 then
		self:sort(friends,"threat")
		return friends[1]
	end
	
	for _,p in ipairs(self.friends_noself)do
		if p:getMaxHp()<self.player:getMaxHp() then
			table.insert(friends,p)
		end
	end
	if #friends>0 then
		self:sort(friends,"threat")
		return friends[1]
	end
	
	self:sort(self.friends_noself,"threat")
	return self.friends_noself[1]
end

--十周年揖让
sgs.ai_skill_playerchosen.tenyearyirang = function(self,targets)
	return sgs.ai_skill_playerchosen.yirang(self,targets)
end

--凤魄
sgs.ai_skill_choice.newfengpo = function(self,choices,data)
	return sgs.ai_skill_choice.fengpo(self,choices,data)
end

--天匠
addAiSkills("tianjiang").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("e"))
	self:sortByKeepValue(cards)
  	for _,e in sgs.list(cards)do
		local equip = e:getRealCard():toEquipCard()
		local x = equip:location()
		for _,h in sgs.list(self.player:getCards("h"))do
			if h:isKindOf("EquipCard")
			then
				local eq = h:getRealCard():toEquipCard()
				local n = eq:location()
				if x==n
				then
					n = self.friends_noself
					if self:evaluateArmor(e)<-5
					then n = self.enemies end
					for _,ep in sgs.list(n)do
						if ep:hasEquipArea(x)
						then
							self.tj_to = ep
							if self:isFriend(ep)
							then
								if ep:getEquip(x)==nil
								then return sgs.Card_Parse("@TianjiangCard="..e:getEffectiveId()) end
							else
								if ep:getEquip(x)~=nil
								then return sgs.Card_Parse("@TianjiangCard="..e:getEffectiveId()) end
							end
						end
					end
				end
			end
		end
	end
  	for _,e in sgs.list(cards)do
		local equip = e:getRealCard():toEquipCard()
		local x = equip:location()
		for _,h in sgs.list(self.player:getCards("h"))do
			if h:isKindOf("EquipCard")
			then
				local eq = h:getRealCard():toEquipCard()
				local n = eq:location()
				if x==n
				then
					n = self.friends_noself
					if self:evaluateArmor(e)<-5
					then n = self.enemies end
					for _,ep in sgs.list(n)do
						if ep:hasEquipArea(x)
						then
							self.tj_to = ep
							if self:isFriend(ep)
							then
								if ep:getEquip(x)==nil
								then return sgs.Card_Parse("@TianjiangCard="..e:getEffectiveId()) end
							else return sgs.Card_Parse("@TianjiangCard="..e:getEffectiveId()) end
						end
					end
				end
			end
		end
	end
  	for _,e in sgs.list(cards)do
		local equip = e:getRealCard():toEquipCard()
		local x = equip:location()
		local n = self.friends_noself
		if self:evaluateArmor(e)<-5
		then n = self.enemies end
		for _,ep in sgs.list(n)do
			if ep:hasEquipArea(x)
			then
				self.tj_to = ep
				if self:isFriend(ep)
				then
					if ep:getEquip(x)==nil
					and self:isWeak(ep)
					then return sgs.Card_Parse("@TianjiangCard="..e:getEffectiveId()) end
				else return sgs.Card_Parse("@TianjiangCard="..e:getEffectiveId()) end
			end
		end
	end
  	for _,e in sgs.list(cards)do
		local equip = e:getRealCard():toEquipCard()
		local x = equip:location()
		for _,ep in sgs.list(self.friends_noself)do
			if ep:hasEquipArea(x)
			then
				self.tj_to = ep
				equip = e:objectName()
				if equip=="_hongduanqiang"
				or equip=="_liecuidao"
				or equip=="_shuibojian"
				or equip=="_hunduwanbi"
				or equip=="_tianleiren"
				then return sgs.Card_Parse("@TianjiangCard="..e:getEffectiveId()) end
			end
		end
	end
end

sgs.ai_skill_use_func["TianjiangCard"] = function(card,use,self)
	use.card = card
	if use.to then use.to:append(self.tj_to) end
end

sgs.ai_use_value.TianjiangCard = 9.4
sgs.ai_use_priority.TianjiangCard = 4.8


--铸刃
addAiSkills("zhuren").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	local toids = {}
  	for _,c in sgs.list(cards)do
		if c:getNumber()>6
		and self.player:getWeapon()==nil
		then return sgs.Card_Parse("@ZhurenCard="..c:getEffectiveId()) end
	end
  	for _,c in sgs.list(cards)do
		if c:getNumber()<6
		and self:getCardsNum("Slash")<1
		and sgs.Slash_IsAvailable(self.player)
		then return sgs.Card_Parse("@ZhurenCard="..c:getEffectiveId()) end
	end
end

sgs.ai_skill_use_func["ZhurenCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.ZhurenCard = 9.4
sgs.ai_use_priority.ZhurenCard = 4.8

--短兵
sgs.ai_skill_playerchosen.olduanbing = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		then return target end
	end
end

--奋迅
addAiSkills("olfenxun").getTurnUseCard = function(self)
	return sgs.Card_Parse("@OLFenxunCard=.")
end

sgs.ai_skill_use_func["OLFenxunCard"] = function(card,use,self)
	self:sort(self.enemies,"handcard")
	for _,ep in sgs.list(self.enemies)do
		if self.player:distanceTo(ep)>1
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.OLFenxunCard = 3.4
sgs.ai_use_priority.OLFenxunCard = 8.8

--筹略
sgs.ai_skill_playerchosen.choulve = function(self,players)
	local name = self.player:property("choulve_damage_card"):toString()
	name = sgs.Sanguosha:cloneCard(name)
	if not name then return end
	name:setSkillName("_choulve")
	name:deleteLater()
	name = self:aiUseCard(name)
	if name.card==nil then return end
	self.cl_to = name.to
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card",true)
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and target:getCardCount()>0
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		and target:getCardCount()>0
		then return target end
	end
end

sgs.ai_skill_discard.choulve = function(self)
	local ids = {}
    local cards = self.player:getCards("he")
    cards = self:sortByKeepValue(cards) -- 按保留值排序
   	local target = self.room:getCurrent()
	if self:isFriend(target)
	and #cards>0
	then
		table.insert(ids,cards[1]:getEffectiveId())
	end
	return ids
end

sgs.ai_skill_use["@@choulve!"] = function(self,prompt)
    local c = self.player:property("choulve_damage_card"):toString()
	c = sgs.Sanguosha:cloneCard(c)
	c:setSkillName("_choulve")
   	if self.cl_to
   	then
      	local tos = {}
       	for _,p in sgs.list(self.cl_to)do
       		table.insert(tos,p:objectName())
       	end
		self.cl_to = nil
       	return c:toString().."->"..table.concat(tos,"+")
    end
end






--威仪
sgs.ai_skill_choice.weiyi = function(self,choices,data)
	local player = data:toPlayer()
	if not player or player:isDead() then return "cancel" end
	choices = choices:split("+")
	local recover = getChoice(choices,"recover")
	local losehp = getChoice(choices,"losehp")
	if self:isFriend(player) and recover then return recover end
	if self:isEnemy(player) and losehp then return losehp end  --不管诈降了
	return "cancel"
end

--锦织
addAiSkills("jinzhi").getTurnUseCard = function(self)
	local toids = {}
	local mark = self.player:getMark("&jinzhi_lun")
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
	if #cards<=mark then return end
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if h:getColor()~=cards[1]:getColor() then continue end
		table.insert(toids,h:getEffectiveId())
		if #toids>mark then break end
	end
	for _,name in sgs.list(patterns)do
        local c = dummyCard(name)
		if c and c:isKindOf("BasicCard")
		and c:isAvailable(self.player)
		and #toids>mark	and #toids<3
		and self:getCardsNum(c:getClassName())<1
		then
         	local dummy = self:aiUseCard(c)
    		if dummy.card and dummy.to
	     	then
				self.jz_to = dummy.to
				toids = #toids>0 and table.concat(toids,"+") or "."
	           	if c:canRecast() and dummy.to:length()<1 then continue end
				sgs.ai_use_priority.JinzhiCard = sgs.ai_use_priority[c:getClassName()]
                return sgs.Card_Parse("@JinzhiCard="..toids..":"..name)
			end
		end
	end
end

sgs.ai_skill_use_func["JinzhiCard"] = function(card,use,self)
	use.card = card
	if use.to then use.to = self.jz_to end
end

sgs.ai_use_value.JinzhiCard = 10.4
sgs.ai_use_priority.JinzhiCard = 10.4

sgs.ai_guhuo_card.jinzhi = function(self,toname,class_name)
	local toids = {}
	local mark = self.player:getMark("&jinzhi_lun")
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
	if #cards<=mark then return end
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if h:getColor()~=cards[1]:getColor() then continue end
		table.insert(toids,h:getEffectiveId())
		if #toids>mark then break end
	end
	if self:getCardsNum(class_name)<1
	and #toids>mark and #toids<3
	then
		toids = #toids>0 and table.concat(toids,"+") or "."
        return "@JinzhiCard="..toids..":"..toname
	end
end


--第二版锦织
addAiSkills("secondjinzhi").getTurnUseCard = function(self)
	local toids = {}
	local mark = self.player:getMark("&secondjinzhi_lun")
    local cards = self.player:getCards("he")
	self.player:speak("secondjinzhi T0")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<1 then return end
	for _,h in sgs.list(cards)do
		if h:getColor()~=cards[1]:getColor() then continue end
		table.insert(toids,h:getEffectiveId())
		if #toids>mark then break end
	end
	self.player:speak("secondjinzhi T1")
	for _,name in sgs.list(patterns)do
        local c = dummyCard(name)
		if c and c:isKindOf("BasicCard")
		and #toids>mark and c:isAvailable(self.player)
		and self:getCardsNum(c:getClassName())<1
		then
			self.player:speak("secondjinzhi T2")
         	local dummy = self:aiUseCard(c)
    		if dummy.card and dummy.to
	     	then
				self.player:speak("secondjinzhi T3")
				self.jz_to = dummy.to
				toids = #toids>0 and table.concat(toids,"+") or "."
	           	if c:canRecast() and dummy.to:length()<1 then continue end
				sgs.ai_use_priority.SecondJinzhiCard = sgs.ai_use_priority[c:getClassName()]
                return sgs.Card_Parse("@SecondJinzhiCard="..toids..":"..name)
			end
		end
	end
end

sgs.ai_skill_use_func["SecondJinzhiCard"] = function(card,use,self)
	use.card = card
	self.player:speak("secondjinzhi T4")
	if use.to then use.to = self.jz_to end
end

sgs.ai_use_value.SecondJinzhiCard = 10.4
sgs.ai_use_priority.SecondJinzhiCard = 10.4

sgs.ai_guhuo_card.secondjinzhi = function(self,toname,class_name)
	local toids = {}
	local mark = self.player:getMark("&secondjinzhi_lun")
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
	self.player:speak("secondjinzhi T5")
	if #cards<1 then return end
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if h:getColor()~=cards[1]:getColor() then continue end
		table.insert(toids,h:getEffectiveId())
		if #toids>mark then break end
	end
	self.player:speak("secondjinzhi T6")
	if #toids>mark
	and self:getCardsNum(class_name)<1
	then
		toids = #toids>0 and table.concat(toids,"+") or "."
		self.player:speak("secondjinzhi T7")
		self.player:speak("secondjinzhi " .. toname)
        return "@SecondJinzhiCard="..toids..":"..toname
	end
end


--兴作
sgs.ai_skill_invoke.xingzuo = function(self,data)
    return self.player:getHandcardNum()>1
end

sgs.ai_skill_use["@@xingzuo"] = function(self,prompt)
	local valid = {}
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	local cidlist = self.player:getTag("xingzuo_forAI"):toString():split("+")
	for _,h in sgs.list(cards)do
		for c,id in sgs.list(cidlist)do
			c = sgs.Sanguosha:getCard(id)
			if self:getKeepValue(c)>self:getKeepValue(h)
			and not table.contains(valid,h:getEffectiveId())
			and not table.contains(valid,c:getEffectiveId())
			then
				table.insert(valid,h:getEffectiveId())
				table.insert(valid,c:getEffectiveId())
				break
			end
		end
	end
	return #valid>1 and ("@XingzuoCard="..table.concat(valid,"+"))
end

sgs.ai_skill_playerchosen.xingzuo = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and target:getHandcardNum()<3
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		and target:getHandcardNum()>0
		then return target end
	end
    return destlist[1]
end

--妙弦
addAiSkills("miaoxian").getTurnUseCard = function(self)
	local toids = {}
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<1 then return end
	for _,h in sgs.list(cards)do
		if h:isBlack() then table.insert(toids,h:getEffectiveId()) end
	end
	for _,name in sgs.list(patterns)do
        if #toids~=1 then continue end
		local c = dummyCard(name)
		if c and c:isNDTrick()
		and c:isAvailable(self.player)
		and self:getCardsNum(c:getClassName())<1
		then
         	local dummy = self:aiUseCard(c)
    		if dummy.card and dummy.to
	     	then
				self.mx_to = dummy.to
				toids = #toids>0 and table.concat(toids,"+") or "."
	           	if c:canRecast() and dummy.to:length()<1 then continue end
				sgs.ai_use_priority.MiaoxianCard = sgs.ai_use_priority[c:getClassName()]
                return sgs.Card_Parse("@MiaoxianCard="..toids..":"..name)
			end
		end
	end
end

sgs.ai_skill_use_func["MiaoxianCard"] = function(card,use,self)
	use.card = card
	if use.to then use.to = self.mx_to end
end

sgs.ai_use_value.MiaoxianCard = 10.4
sgs.ai_use_priority.MiaoxianCard = 10.4

sgs.ai_guhuo_card.miaoxian = function(self,toname,class_name)
	local toids = {}
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<1 then return end
	for _,h in sgs.list(cards)do
		if h:isBlack() then table.insert(toids,h:getEffectiveId()) end
	end
	if self.player:getMark("miaoxian-Clear")<1
	and #toids==1 and self:getCardsNum(class_name)<1
	then
		toids = #toids>0 and table.concat(toids,"+") or "."
        return "@MiaoxianCard="..toids..":"..toname
	end
end

--谋逆
sgs.ai_skill_playerchosen.mouni = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and self:getCardsNum("Slash")>=target:getHp()
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and self:getCardsNum("Slash")>0
		and self:isWeak(target)
		then return target end
	end
end


--纵反

sgs.ai_skill_playerchosen.fuzhong = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		then return target end
	end
	return destlist[1]
end
