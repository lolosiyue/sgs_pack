--美人计
function SmartAI:useCardMeirenji(card,use)
	self:sort(self.enemies,"hp")
	local extraTarget = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
	if use.extra_target then extraTarget = extraTarget+use.extra_target end
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if use.to and CanToCard(card,self.player,ep)
		then
	    	use.card = card
			use.to:append(ep)
	    	if use.to:length()>extraTarget
			then return end
		end
	end
end
sgs.ai_use_priority.Meirenji = 6.5
sgs.ai_keep_value.Meirenji = 2
sgs.ai_use_value.Meirenji = 3.7

--笑里藏刀
function SmartAI:useCardXiaolicangdao(card,use)
	self:sort(self.enemies,"hp",true)
	local extraTarget = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
	if use.extra_target then extraTarget = extraTarget+use.extra_target end
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if use.to and CanToCard(card,self.player,ep)
		and self:isGoodTarget(ep,self.enemies,card)
		and ep:getHp()<2
		then
	    	use.card = card
			use.to:append(ep)
	    	if use.to:length()>extraTarget
			then return end
		end
	end
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if use.to and CanToCard(card,self.player,ep)
		and self:isGoodTarget(ep,self.enemies,card)
		then
	    	use.card = card
			use.to:append(ep)
	    	if use.to:length()>extraTarget
			then return end
		end
	end
	for _,ep in sgs.list(self.friends_noself)do
		if isCurrent(use.current_targets,ep) then continue end
		if use.to and CanToCard(card,self.player,ep)
		and self:ajustDamage(self.player,ep,1,card)~=0
		and ep:getHp()>1 and ep:getLostHp()>1
		then
	    	use.card = card
			use.to:append(ep)
	    	if use.to:length()>extraTarget
			then return end
		end
	end
end
sgs.ai_use_priority.Xiaolicangdao = 5.5
sgs.ai_keep_value.Xiaolicangdao = 1
sgs.ai_use_value.Xiaolicangdao = 3.7

--连计

--矜功
addAiSkills("jingong").getTurnUseCard = function(self)
	local toids = {}
    local cards = self:addHandPile("he")
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<1 then return end
	for _,h in sgs.list(cards)do
		if h:isKindOf("Slash")
		or h:isKindOf("EquipCard")
		then table.insert(toids,h:getEffectiveId()) end
	end
	local tricks = self.player:property("jingong_tricks"):toString():split("+")
	for _,name in sgs.list(tricks)do
        local c = sgs.Sanguosha:cloneCard(name)
		if c and c:isAvailable(self.player)
		and self:getCardsNum(c:getClassName())<1
		and #toids>0
		then
         	c:addSubcard(toids[1])
			c:setSkillName("jingong")
			local dummy = self:aiUseCard(c)
    		if dummy.card
	    	and dummy.to
	     	then
	           	if c:canRecast()
				and dummy.to:length()<1
				then continue end
                return c
			end
		end
		if c then c:deleteLater() end
	end
end

addAiSkills("tenyearjingong").getTurnUseCard = function(self)
	local toids = {}
    local cards = self:addHandPile("he")
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<1 then return end
	for _,h in sgs.list(cards)do
		if h:isKindOf("Slash")
		or h:isKindOf("EquipCard")
		then table.insert(toids,h:getEffectiveId()) end
	end
	local tricks = self.player:property("tenyearjingong_tricks"):toString():split("+")
	for _,name in sgs.list(tricks)do
        local c = sgs.Sanguosha:cloneCard(name)
		if c and c:isAvailable(self.player)
		and self:getCardsNum(c:getClassName())<1
		and #toids>0
		then
         	c:addSubcard(toids[1])
			c:setSkillName("tenyearjingong")
			local dummy = self:aiUseCard(c)
    		if dummy.card
	    	and dummy.to
	     	then
	           	if c:canRecast()
				and dummy.to:length()<1
				then continue end
                return c
			end
		end
		if c then c:deleteLater() end
	end
end

--十周年连计
addAiSkills("tenyearlianji").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
  	if #cards<2 then return end
	return sgs.Card_Parse("@TenyearLianjiCard="..cards[1]:getEffectiveId())
end

sgs.ai_skill_use_func["TenyearLianjiCard"] = function(card,use,self)
	self:sort(self.enemies,"hp",true)
	for _,ep in sgs.list(self.enemies)do
		use.card = card
		if use.to then use.to:append(ep) end
		return
	end
	for _,ep in sgs.list(self.friends_noself)do
		if ep:getHandcardNum()>2
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.TenyearLianjiCard = 9.4
sgs.ai_use_priority.TenyearLianjiCard = 3.8

--OL连计
addAiSkills("ollianji").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
  	if #cards<2 then return end
	return sgs.Card_Parse("@OLLianjiCard="..cards[1]:getEffectiveId())
end

sgs.ai_skill_use_func["OLLianjiCard"] = function(card,use,self)
	self:sort(self.enemies,"hp",true)
	for _,ep in sgs.list(self.enemies)do
		use.card = card
		if use.to then use.to:append(ep) end
		return
	end
	for _,ep in sgs.list(self.friends_noself)do
		if ep:getHandcardNum()>2
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.OLLianjiCard = 9.4
sgs.ai_use_priority.OLLianjiCard = 3.8

sgs.ai_skill_playerchosen.ollianji = function(self,players)
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

sgs.ai_skill_playerchosen.ollianji_give = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
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

--手杀连计
addAiSkills("mobilelianji").getTurnUseCard = function(self)
	return sgs.Card_Parse("@MobileLianjiCard=.")
end

sgs.ai_skill_use_func["MobileLianjiCard"] = function(card,use,self)
	self:sort(self.enemies,"hp",true)
	for _,fp in sgs.list(self.friends_noself)do
		if fp:getHandcardNum()>0
		then
			for _,ep in sgs.list(self.enemies)do
				use.card = card
				if use.to
				then
					use.to:append(fp)
					use.to:append(ep)
				end
				return
			end
		end
	end
end

sgs.ai_use_value.MobileLianjiCard = 9.4
sgs.ai_use_priority.MobileLianjiCard = 3.8

--屯储
sgs.ai_skill_invoke.newtunchu = function(self,data)
    return self:getCardsNum("Slash")<1 or #self.friends_noself>0
end

sgs.ai_skill_discard.newtunchu = function(self)
	local cards = {}
    local handcards = sgs.QList2Table(self.player:getCards("h"))
    self:sortByKeepValue(handcards) -- 按保留值排序
   	for _,h in sgs.list(handcards)do
		if #cards>2 or #cards>#handcards/2 then break end
		table.insert(cards,h:getEffectiveId())
	end
	return cards
end

--输粮
sgs.ai_skill_use["@@newshuliang"] = function(self,prompt)
    local ids = self.player:getPile("food")
   	local target = self.room:getCurrent()
	if ids:length()>0
	and self:isFriend(target)
	then
		return string.format("@NewShuliangCard=%s",ids:at(0))
	end
end

--天命
sgs.ai_skill_invoke.newtianming = function(self,data)
	return sgs.ai_skill_invoke.tianming(self,data)
end

sgs.ai_skill_discard.newtianming = function(self,discard_num,min_num,optional,include_equip)
	return sgs.ai_skill_discard.tianming(self,discard_num,min_num,optional,include_equip)
end

--观虚
addAiSkills("guanxu").getTurnUseCard = function(self)
	return sgs.Card_Parse("@GuanxuCard=.")
end

sgs.ai_skill_use_func["GuanxuCard"] = function(card,use,self)
	self:sort(self.enemies,"handcard",true)
	self.guanxu_friends = false
	for _,ep in sgs.list(self.enemies)do
		if ep:getHandcardNum()>2
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	for _,ep in sgs.list(self.friends_noself)do
		if ep:getHandcardNum()<4
		and ep:getHandcardNum()>0
		then
			use.card = card
			if use.to then use.to:append(ep) end
			self.guanxu_friends = true
			return
		end
	end
	for _,ep in sgs.list(self.enemies)do
		if ep:getHandcardNum()>0
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.GuanxuCard = 9.4
sgs.ai_use_priority.GuanxuCard = 6.8

sgs.ai_skill_use["@@guanxu1"] = function(self,prompt)
	local valid = {}
	local guanxuhand = self.player:getTag("guanxuhand_forAI"):toString():split("+")
	local guanxudrawpile = self.player:getTag("guanxudrawpile_forAI"):toString():split("+")
	local n1,n2,suits = {},{},{}
	for c,id in sgs.list(guanxuhand)do
		c = sgs.Sanguosha:getCard(id)
		table.insert(n1,c)
		if suits[c:getSuitString()]
		then suits[c:getSuitString()] = suits[c:getSuitString()]+1
		else suits[c:getSuitString()] = 1 end
	end
	for _,id in sgs.list(guanxudrawpile)do
		table.insert(n2,sgs.Sanguosha:getCard(id))
	end
	if self.guanxu_friends
	then
		self:sortByKeepValue(n1)
		self:sortByKeepValue(n2,true)
		for _,h in sgs.list(n1)do
			for _,c in sgs.list(n2)do
				if self:getKeepValue(c)>self:getKeepValue(h)
				then
					table.insert(valid,h:getEffectiveId())
					table.insert(valid,c:getEffectiveId())
					return ("@GuanxuChooseCard="..table.concat(valid,"+"))
				end
			end
		end
	end
	self:sortByKeepValue(n1,true)
	self:sortByKeepValue(n2)
	for _,h in sgs.list(n1)do
		for _,c in sgs.list(n2)do
			if self:getKeepValue(c)<self:getKeepValue(h)
			and suits[c:getSuitString()]==2
			then
				table.insert(valid,h:getEffectiveId())
				table.insert(valid,c:getEffectiveId())
				return ("@GuanxuChooseCard="..table.concat(valid,"+"))
			end
		end
	end
	for _,h in sgs.list(n1)do
		for _,c in sgs.list(n2)do
			if suits[c:getSuitString()]==2
			then
				table.insert(valid,h:getEffectiveId())
				table.insert(valid,c:getEffectiveId())
				return ("@GuanxuChooseCard="..table.concat(valid,"+"))
			end
		end
	end
	for _,h in sgs.list(n1)do
		for _,c in sgs.list(n2)do
			if suits[c:getSuitString()]==3
			and c:getSuitString()==h:getSuitString()
			and self:getKeepValue(c)<self:getKeepValue(h)
			then
				table.insert(valid,h:getEffectiveId())
				table.insert(valid,c:getEffectiveId())
				return ("@GuanxuChooseCard="..table.concat(valid,"+"))
			end
		end
	end
	for _,h in sgs.list(n1)do
		for _,c in sgs.list(n2)do
			if suits[c:getSuitString()]==3
			and c:getSuitString()==h:getSuitString()
			then
				table.insert(valid,h:getEffectiveId())
				table.insert(valid,c:getEffectiveId())
				return ("@GuanxuChooseCard="..table.concat(valid,"+"))
			end
		end
	end
	for _,h in sgs.list(n1)do
		for _,c in sgs.list(n2)do
			if self:getKeepValue(c)<self:getKeepValue(h)
			then
				table.insert(valid,h:getEffectiveId())
				table.insert(valid,c:getEffectiveId())
				return ("@GuanxuChooseCard="..table.concat(valid,"+"))
			end
		end
	end
	return #valid>1 and ("@GuanxuChooseCard="..table.concat(valid,"+"))
end

sgs.ai_skill_use["@@guanxu2"] = function(self,prompt)
	local guanxuhand = self.player:getTag("guanxu_forAI"):toString():split("+")
	local n1,n2,suits = {},{},{}
	for c,id in sgs.list(guanxuhand)do
		table.insert(n1,sgs.Sanguosha:getCard(id))
	end
	self:sortByKeepValue(n1,true)
	for _,c in sgs.list(n1)do
		if suits[c:getSuitString()]
		then table.insert(suits[c:getSuitString()],c:getEffectiveId())
		else
			suits[c:getSuitString()] = {}
			table.insert(suits[c:getSuitString()],c:getEffectiveId())
		end
	end
	for _,ids in sgs.list(suits)do
		if #ids>=3
		then
			for i=1,3 do
				table.insert(n2,ids[i])
			end
			return ("@GuanxuDiscardCard="..table.concat(n2,"+"))
		end
	end
end

--雅士
sgs.ai_skill_invoke.yashi = function(self,data)
    return true
end

sgs.ai_skill_choice.yashi = function(self,choices,data)
	local damage = data:toDamage()
	local items = choices:split("+")
	if table.contains(items,"guanxu")
	then
		for _,ep in sgs.list(self.enemies)do
			if ep:getHandcardNum()>2
			then return "guanxu" end
		end
		for _,ep in sgs.list(self.friends_noself)do
			if ep:getHandcardNum()<4
			and ep:getHandcardNum()>0
			then return "guanxu" end
		end
	elseif damage.from
	and not self:isFriend(damage.from)
	then return items[1] end
end

sgs.ai_skill_playerchosen.yashi = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard",true)
	self.guanxu_friends = false
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and target:getHandcardNum()>2
		then return target end
	end
	self:sort(destlist,"handcard")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and target:getHandcardNum()<4
		and target:getHandcardNum()>0
		then
			self.guanxu_friends = true
			return target
		end
	end
	return destlist[1]
end

addAiSkills("tenyearjiezhen").getTurnUseCard = function(self)
	return sgs.Card_Parse("@TenyearJiezhenCard=.")
end

sgs.ai_skill_use_func["TenyearJiezhenCard"] = function(card,use,self)
	self:sort(self.enemies)
	local function JiezhenSkill(p)
		local n = 0
		for _,s in sgs.list(p:getSkillList())do
			if s:isLimitedSkill()
			or s:isAttachedLordSkill()
			or s:isLordSkill()
			or s:getFrequency(p)==sgs.Skill_Compulsory
			or s:getFrequency(p)==sgs.Skill_Wake
			then continue end
			n = n+1
		end
		return n
	end
	for _,ep in sgs.list(self.enemies)do
		if JiezhenSkill(ep)>0
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	for _,ep in sgs.list(self.room:getOtherPlayers(self.player))do
		if JiezhenSkill(ep)>0
		and not self:isFriend(ep)
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.TenyearJiezhenCard = 2.4
sgs.ai_use_priority.TenyearJiezhenCard = 9.8

sgs.ai_skill_playerchosen.tenyearzecai = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard",true)
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and target:getHandcardNum()>3
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and target:getHandcardNum()>2
		and self:isWeak()
		then
			return target
		end
	end
end

sgs.ai_can_damagehp.tenyearyinshi = function(self,from,card,to)
	return not (card and (card:isRed() or card:isBlack()))
	and to:getMark("tenyearyinshi_damage-Clear")<1
	and self:canLoseHp(from,card,to)
end

sgs.ai_target_revises.tenyearyinshi = function(to,card,self,use)
	return card and (card:isRed() or card:isBlack())
	and to:getMark("tenyearyinshi_damage-Clear")<1
end

--挫锐
sgs.ai_skill_use["@@spcuorui"] = function(self,prompt)
	local targets = self:findPlayerToDiscard("h",false,false,nil,true)
	if #targets<=0 then return "." end
	
	local tos = {}
	for i = 1,math.min(self.player:getHp(),#targets)do
		table.insert(tos,targets[i]:objectName())
	end
	return "@SpCuoruiCard=.->"..table.concat(tos,"+")
end

--裂围
sgs.ai_skill_invoke.spliewei = function(self,data)
	return self:canDraw()
end

--挫锐-第二版
addAiSkills("secondspcuorui").getTurnUseCard = function(self)
	return sgs.Card_Parse("@SecondSpCuoruiCard=.")
end

sgs.ai_skill_use_func["SecondSpCuoruiCard"] = function(card,use,self)
	self:sort(self.enemies,"hp")
	local n = 0
	for _,ep in sgs.list(self.enemies)do
		if self:isWeak(ep)
		and ep:getHandcardNum()>0
		then n = n+1 end
	end
	for _,ep in sgs.list(self.enemies)do
		if ep:getHandcardNum()>0
		and n>=#self.enemies/2
		then
			use.card = card
			if use.to then use.to:append(ep) end
			if use.to:length()>=self.player:getHp()
			then return end
		end
	end
end

sgs.ai_use_value.SecondSpCuoruiCard = 9.4
sgs.ai_use_priority.SecondSpCuoruiCard = 6.8


--裂围-第二版
sgs.ai_skill_invoke.secondspliewei = function(self,data)
	return self:canDraw()
end

--天算
function getSpecialMark(special_mark,player)
	player = player or self.player
	local num = 0
	local marks = player:getMarkNames()
	for _,mark in ipairs(marks)do
		if not mark:startsWith(special_mark) or player:getMark(mark)<=0 then continue end
		num = num+1
	end
	return num
end

addAiSkills("tiansuan").getTurnUseCard = function(self)
	return sgs.Card_Parse("@TiansuanCard=.:"..math.random(1,5))
end

sgs.ai_skill_use_func["TiansuanCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.TiansuanCard = 9.4
sgs.ai_use_priority.TiansuanCard = 6.8

sgs.ai_skill_playerchosen.tiansuan0 = function(self,players)--无法知道天算签
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		then return target end
	end
	self:sort(destlist,"handcard")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and #self.enemies>0
		then return target end
	end
end

--掳掠
sgs.ai_skill_playerchosen.lulve = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		then return target end
	end
	self:sort(destlist,"handcard")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and #self.enemies>0
		then return target end
	end
end

sgs.ai_skill_choice.lulve = function(self,choices,data)
	local items = choices:split("+")
	local target = data:toPlayer()
	if self:isFriend(target) then return items[1]
	else return items[2] end
end

--望归
sgs.ai_skill_playerchosen.wanggui = function(self,targets)
	if targets:first():getKingdom()==self.player:getKingdom() then
		local target = self:findPlayerToDraw(false,1)
		if target then return target end
		if self:canDraw() then return self.player end
	else
		return self:findPlayerToDamage(1,self.player,sgs.DamageStruct_Normal,targets)
	end
	return nil
end

--息兵
sgs.ai_skill_invoke.xibing = function(self,data)
	local target = data:toPlayer()
	local hand_num = target:getHandcardNum()
	local num = target:getHp()-hand_num
	if num<=0 then return false end
	if self:isFriend(target) then
		if hand_num>2 then return false end
		return true
	elseif self:isEnemy(target) then
		if hand_num<=2 then return false end
		if hand_num>=5 then return true end
	end
	return false
end

--诱言
sgs.ai_skill_invoke.youyan = function(self,data)
	return self:canDraw()
end

--追还
sgs.ai_skill_playerchosen.zhuihuan = function(self,targets)
	targets = sgs.QList2Table(targets)
	self:sort(targets)
	for _,p in ipairs(targets)do
		if not self:isFriend(p) or p:getMark("&zhuihuan")>0 then continue end
		return p
	end
	for _,p in ipairs(targets)do
		if not self:isFriend(p) then continue end
		return p
	end
	return nil
end

--抗歌
sgs.ai_skill_playerchosen.kangge = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp",true)
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

sgs.ai_skill_invoke.kangge = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isEnemy(target)
	end
end

--节烈
sgs.ai_skill_invoke.jielie = function(self,data)
    return true
end

--拒关
addAiSkills("juguan").getTurnUseCard = function(self)
	local cards = self:addHandPile()
	self:sortByKeepValue(cards)
  	for d,c in sgs.list(cards)do
		local fs = sgs.Sanguosha:cloneCard("duel")
		fs:setSkillName("juguan")
		fs:addSubcard(c)
		d = self:aiUseCard(fs)
		self.jg_to = d.to
		sgs.ai_use_priority.JuguanCard = sgs.ai_use_priority.Duel
		if fs:isAvailable(self.player) and d.card and d.to
		then return sgs.Card_Parse("@JuguanCard="..c:getEffectiveId()..":duel") end
		fs:deleteLater()
	end
  	for d,c in sgs.list(cards)do
		local fs = sgs.Sanguosha:cloneCard("Slash")
		fs:setSkillName("juguan")
		fs:addSubcard(c)
		d = self:aiUseCard(fs)
		self.jg_to = d.to
		sgs.ai_use_priority.JuguanCard = sgs.ai_use_priority.Slash
		if fs:isAvailable(self.player) and d.card and d.to
		then return sgs.Card_Parse("@JuguanCard="..c:getEffectiveId()..":slash") end
		fs:deleteLater()
	end
end

sgs.ai_skill_use_func["JuguanCard"] = function(card,use,self)
	use.card = card
	if use.to then use.to = self.jg_to end
end

sgs.ai_use_value.JuguanCard = 9.4
sgs.ai_use_priority.JuguanCard = 4.8

--驱徙
sgs.ai_skill_invoke.quxi = function(self,data)
    return player:getHandcardNum()>=player:getMaxCards()
	and sgs.ai_skill_use["@@quxi1"](self,"quxi1")
end

sgs.ai_skill_use["@@quxi1"] = function(self,prompt)
	local valid = {}
	local destlist = self.player:getAliveSiblings()
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	for _,fp in sgs.list(destlist)do
		if #valid>1 then break end
		for _,ep in sgs.list(destlist)do
			if self:isFriend(fp) and self:isEnemy(ep)
			and fp:getHandcardNum()<ep:getHandcardNum()
			then
				table.insert(valid,fp:objectName())
				table.insert(valid,ep:objectName())
				break
			end
		end
	end
	for _,fp in sgs.list(destlist)do
		if #valid>1 then break end
		for _,ep in sgs.list(destlist)do
			if self:isFriend(fp) and not self:isFriend(ep)
			and fp:getHandcardNum()<ep:getHandcardNum()
			then
				table.insert(valid,fp:objectName())
				table.insert(valid,ep:objectName())
				break
			end
		end
	end
	for _,fp in sgs.list(destlist)do
		if #valid>1 then break end
		for _,ep in sgs.list(destlist)do
			if not self:isEnemy(fp) and self:isEnemy(ep)
			and fp:getHandcardNum()<ep:getHandcardNum()
			then
				table.insert(valid,fp:objectName())
				table.insert(valid,ep:objectName())
				break
			end
		end
	end
	for _,fp in sgs.list(destlist)do
		if #valid>1 then break end
		for _,ep in sgs.list(destlist)do
			if not self:isEnemy(fp) and not self:isFriend(ep)
			and fp:getHandcardNum()<ep:getHandcardNum()
			then
				table.insert(valid,fp:objectName())
				table.insert(valid,ep:objectName())
				break
			end
		end
	end
	if #valid>1
	then
    	return string.format("@QuxiCard=.->%s",table.concat(valid,"+"))
	end
end

sgs.ai_skill_use["@@quxi2"] = function(self,prompt)
	local valid = {}
	local destlist = self.player:getAliveSiblings()
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	local death = self.player:property("QuxiDeathPlayer"):toString()
	for _,fp in sgs.list(destlist)do
		if #valid>1 then break end
		if fp:objectName()~=death then continue end
		for _,ep in sgs.list(destlist)do
			if ep:objectName()==death then continue end
			if fp:getMark("&quxiqian")>0
			and self:isEnemy(ep)
			then
				table.insert(valid,fp:objectName())
				table.insert(valid,ep:objectName())
				break
			end
		end
	end
	for _,fp in sgs.list(destlist)do
		if #valid>1 then break end
		if fp:objectName()~=death then continue end
		for _,ep in sgs.list(destlist)do
			if ep:objectName()==death then continue end
			if fp:getMark("&quxiqian")>0
			and not self:isFriend(ep)
			then
				table.insert(valid,fp:objectName())
				table.insert(valid,ep:objectName())
				break
			end
		end
	end
	for _,fp in sgs.list(destlist)do
		if #valid>1 then break end
		if fp:objectName()~=death then continue end
		for _,ep in sgs.list(destlist)do
			if ep:objectName()==death then continue end
			if fp:getMark("&quxifeng")>0
			and self:isFriend(ep)
			then
				table.insert(valid,fp:objectName())
				table.insert(valid,ep:objectName())
				break
			end
		end
	end
	for _,fp in sgs.list(destlist)do
		if #valid>1 then break end
		if fp:objectName()~=death then continue end
		for _,ep in sgs.list(destlist)do
			if ep:objectName()==death then continue end
			if fp:getMark("&quxifeng")>0
			and not self:isEnemy(ep)
			then
				table.insert(valid,fp:objectName())
				table.insert(valid,ep:objectName())
				break
			end
		end
	end
	if #valid>1
	then
    	return string.format("@QuxiCard=.->%s",table.concat(valid,"+"))
	end
end

sgs.ai_skill_use["@@quxi3"] = function(self,prompt)
	local valid = {}
	local destlist = self.player:getAliveSiblings()
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	for _,fp in sgs.list(destlist)do
		if #valid>1 then break end
		for _,ep in sgs.list(destlist)do
			if fp:objectName()==ep:objectName() then continue end
			if fp:getMark("&quxiqian")>0
			and not self:isEnemy(fp)
			and self:isEnemy(ep)
			then
				table.insert(valid,fp:objectName())
				table.insert(valid,ep:objectName())
				break
			end
		end
	end
	for _,fp in sgs.list(destlist)do
		if #valid>1 then break end
		for _,ep in sgs.list(destlist)do
			if fp:objectName()==ep:objectName() then continue end
			if fp:getMark("&quxifeng")>0
			and not self:isFriend(fp)
			and self:isFriend(ep)
			then
				table.insert(valid,fp:objectName())
				table.insert(valid,ep:objectName())
				break
			end
		end
	end
	if #valid>1
	then
    	return string.format("@QuxiCard=.->%s",table.concat(valid,"+"))
	end
end

--齐攻
sgs.ai_skill_playerchosen.qigong = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard",true)
	if self:getCardsNum("Slash")>0
	then return self.player end
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and target:objectName()~=self.player:objectName()
		and target:getHandcardNum()>0
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		and target:getHandcardNum()>0
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and target:getHandcardNum()>0
		then return target end
	end
end

--列侯
addAiSkills("liehou").getTurnUseCard = function(self)
	return sgs.Card_Parse("@LiehouCard=.")
end

sgs.ai_skill_use_func["LiehouCard"] = function(card,use,self)
	self:sort(self.enemies,"handcard")
	for _,ep in sgs.list(self.enemies)do
		if self.player:inMyAttackRange(ep)
		and ep:getHandcardNum()>0
		then
			use.card = card
			if use.to then use.to:append(ep) end
			break
		end
	end
end

sgs.ai_use_value.LiehouCard = 9.4
sgs.ai_use_priority.LiehouCard = 4.8

sgs.ai_skill_askforyiji.liehou = function(self,card_ids)
	local target = self.player:getTag("LiehouTarget"):toPlayer()
	for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
	   	if self.player:inMyAttackRange(p)
		and p:objectName()~=target:objectName()
		and self:isFriend(p)
		then return p,card_ids[1] end
	end
	for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
	   	if self.player:inMyAttackRange(p)
		and p:objectName()~=target:objectName()
		and not self:isEnemy(p)
		then return p,card_ids[1] end
	end
	for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
	   	if self.player:inMyAttackRange(p)
		and p:objectName()~=target:objectName()
		then return p,card_ids[1] end
	end
end

sgs.ai_fill_skill.tenyearshuhe = function(self)
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	local ids = {}
	for _,p in sgs.list(self.room:getAlivePlayers())do
		for _,c in sgs.list(p:getCards("ej"))do
			if self:canDisCard(p,c:getId(),nil,true)
			then table.insert(ids,c:getNumber()) end
		end
	end
	for _,c in sgs.list(cards)do
		if table.contains(ids,c:getNumber())
		then return sgs.Card_Parse("@TenyearShuheCard="..c:getId()) end
	end
	if (#cards>2 or self:getOverflow()>0)
	and #self.friends_noself>0
	then
		return sgs.Card_Parse("@TenyearShuheCard="..cards[1]:getId())
	end
end

sgs.ai_skill_use_func["TenyearShuheCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.TenyearShuheCard = 3.4
sgs.ai_use_priority.TenyearShuheCard = 6.2

sgs.ai_skill_playerchosen.tenyearshuhe = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		then return target end
	end
end

sgs.ai_skill_discard.tenyearliehou = function(self,max,min,optional)
	local to_cards = self:poisonCards("e")
   	if #to_cards>=min then return to_cards end
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
   	for _,c in sgs.list(cards)do
   		if #to_cards>=min then break end
     	table.insert(to_cards,c:getEffectiveId())
	end
	if (min<2 or self:isWeak()) and #to_cards>=min
	then return to_cards end
	return {}
end

--狼灭
sgs.ai_skill_invoke.langmie = function(self,data)
    return true
end

sgs.ai_skill_cardask["@langmie-dis"] = function(self,data,pattern,prompt)
   	local target = self.room:getCurrent()
    if self:isEnemy(target) then return true end
	return not self:isFriend(target) and self.player:getCardCount()>4
end

sgs.ai_skill_choice.secondlangmie = function(self,choices,data)
	local items = choices:split("+")
	local target = data:toPlayer()
	if table.contains(items,"draw")
	and not self:isEnemy(target)
	then return "draw" end
	if self:isEnemy(target)
	or not self:isFriend(target) and self.player:getCardCount()>4
	then return items[#items-1] end
	if table.contains(items,"draw")
	then return "draw" end
end

sgs.ai_skill_cardask["@secondlangmie-damage"] = function(self,data,pattern,prompt)
   	local target = self.room:getCurrent()
    if self:isEnemy(target) then return true end
	return not self:isFriend(target) and self.player:getCardCount()>4
end

--祸水
sgs.ai_skill_use["@@tenyearhuoshui"] = function(self,prompt)
	local valid = {}
	local destlist = self.player:getAliveSiblings()
    destlist = self:sort(destlist,"hp")
	local n = math.max(self.player:getLostHp(),1)
	for _,fp in sgs.list(destlist)do
		if #valid>=n then break end
		if self:isEnemy(fp) then table.insert(valid,fp:objectName()) end
	end
	for _,fp in sgs.list(destlist)do
		if #valid>=n then break end
		if table.contains(valid,fp:objectName())
		or self:isFriend(fp)
		then continue end
		table.insert(valid,fp:objectName())
	end
	if #valid>0
	then
    	return string.format("@TenyearHuoshuiCard=.->%s",table.concat(valid,"+"))
	end
end

--倾城
addAiSkills("tenyearqingcheng").getTurnUseCard = function(self)
	return sgs.Card_Parse("@TenyearQingchengCard=.")
end

sgs.ai_skill_use_func["TenyearQingchengCard"] = function(card,use,self)
	self:sort(self.enemies,"handcard",true)
	local n = self:getCardsNum("Peach")
	local cs = self:poisonCards()
	for _,ep in sgs.list(self.enemies)do
		if ep:isMale() and #cs>0
		and self.player:getHandcardNum()-ep:getHandcardNum()<=#cs
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	for _,ep in sgs.list(self.enemies)do
		if ep:isMale() and n<1
		and ep:getHandcardNum()==self.player:getHandcardNum()
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	for _,ep in sgs.list(self.friends_noself)do
		if ep:isMale()
		and ep:getHandcardNum()<=self.player:getHandcardNum()
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.TenyearQingchengCard = 9.4
sgs.ai_use_priority.TenyearQingchengCard = 3.8

--祈禳
sgs.ai_skill_invoke.tenyearqirang = function(self,data)
    return true
end

sgs.ai_skill_playerchosen.tenyearqirang = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for c,id in sgs.list(self.player:getTag("tenyearqirang_tricks"):toIntList())do
		c = sgs.Sanguosha:getCard(id)
		if self:isEnemy(target)
		and c:isDamageCard()
		then return target end
	end
end

--寇略
sgs.ai_skill_invoke.koulve = function(self,data)
	local target = data:toPlayer()
	return not self:isFriend(target)
	and target:getHandcardNum()>2
end

sgs.ai_skill_invoke.secondkoulve = function(self,data)
	local target = data:toPlayer()
	return not self:isFriend(target)
	and target:getHandcardNum()>2
end

--随认
sgs.ai_skill_playerchosen.suirenq = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		then return target end
	end
end

sgs.ai_skill_invoke.fengshimf = function(self,data)
	local target = data:toPlayer()
	return self:isEnemy(target)
end

--摧坚
addAiSkills("cuijian").getTurnUseCard = function(self)
	return sgs.Card_Parse("@CuijianCard=.")
end

sgs.ai_skill_use_func["CuijianCard"] = function(card,use,self)
	self:sort(self.enemies,"handcard",true)
	for _,ep in sgs.list(self.enemies)do
		if ep:getHandcardNum()>0
		then
			use.card = card
			if use.to then use.to:append(ep) end
			break
		end
	end
end

sgs.ai_use_value.CuijianCard = 9.4
sgs.ai_use_priority.CuijianCard = 4.8

addAiSkills("secondcuijian").getTurnUseCard = function(self)
	return sgs.Card_Parse("@SecondCuijianCard=.")
end

sgs.ai_skill_use_func["SecondCuijianCard"] = function(card,use,self)
	self:sort(self.enemies,"handcard",true)
	for _,ep in sgs.list(self.enemies)do
		if ep:getHandcardNum()>0
		then
			use.card = card
			if use.to then use.to:append(ep) end
			break
		end
	end
end

sgs.ai_use_value.SecondCuijianCard = 9.4
sgs.ai_use_priority.SecondCuijianCard = 4.8

--同援
sgs.ai_skill_playerchosen.secondtongyuan0 = function(self,players)--无法知道牌
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
	for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		then return target end
	end
end


sgs.ai_skill_cardask["@chaofeng-discard"] = function(self,data,pattern,prompt)
    local damage = data:toDamage()
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	for _,c in sgs.list(cards)do
		if damage.card
		and damage.card:getSuit()==c:getSuit()
		then
			if self:isEnemy(damage.to)
			and damage.card:getNumber()==c:getNumber()
			then return c:getEffectiveId() end
		end
	end
	for _,c in sgs.list(cards)do
		if damage.card
		then
			if self:isEnemy(damage.to)
			and damage.card:getNumber()==c:getNumber()
			then return c:getEffectiveId() end
		end
	end
	for _,c in sgs.list(cards)do
		if damage.card
		and damage.card:getSuit()==c:getSuit()
		then return c:getEffectiveId() end
	end
	return #cards>1 and cards[1]:getEffectiveId() or "."
end

sgs.ai_skill_cardask["@secondchaofeng-discard"] = function(self,data,pattern,prompt)
    local damage = data:toDamage()
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	for _,c in sgs.list(cards)do
		if damage.card
		and damage.card:getColor()==c:getColor()
		then
			if self:isEnemy(damage.to)
			and damage.card:getTypeId()==c:getTypeId()
			then return c:getEffectiveId() end
		end
	end
	for _,c in sgs.list(cards)do
		if damage.card
		then
			if self:isEnemy(damage.to)
			and damage.card:getTypeId()==c:getTypeId()
			then return c:getEffectiveId() end
		end
	end
	for _,c in sgs.list(cards)do
		if damage.card
		and damage.card:getColor()==c:getColor()
		then return c:getEffectiveId() end
	end
	return #cards>1 and cards[1]:getEffectiveId() or "."
end

sgs.ai_skill_playerchosen.chuanshu = function(self,players,reason)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp",true)
	for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		then return target end
	end
end

sgs.ai_skill_playerchosen.secondchuanshu = function(self,players,reason)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp",true)
	for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		and #self.enemies>0
		then return target end
	end
end

sgs.ai_skill_invoke.chuanyun = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isFriend(target)
	end
end

sgs.ai_skill_invoke.xunde = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isEnemy(target)
	end
end

sgs.ai_skill_cardask["@chenjie-card"] = function(self,data)
	local judge = data:toJudge()
	local all_cards = self:addHandPile("he")
	if #all_cards<1 then return "." end
	local cards = {}
	for _,c in sgs.list(all_cards)do
		if c:getSuit()==judge.card:getSuit()
		then table.insert(cards,c) end
	end
	if #cards<1 then return "." end
	if self:needRetrial(judge)
	then
    	local id = self:getRetrialCardId(cards,judge)
    	if id~=-1 then return id end
	else
    	local id = self:getRetrialCardId(cards,judge)
    	if id~=-1 then return id end
	end
    return "."
end

sgs.ai_skill_invoke.jibing = function(self,data)
	if self:getCardsNum("Slash")<1
	and #self.enemies>0
	then
		return true
	end
	return self:getCardsNum("Jink")<1
end

function sgs.ai_cardsview.jibing(self,class_name,player)
   	local ids = self.player:getPile("jbbing")
	if class_name=="Jink"
	then return ("jink:jibing[no_suit:0]="..ids:at(0))
	elseif class_name=="Slash"
    then return ("slash:jibing[no_suit:0]="..ids:at(0)) end
end

addAiSkills("jibing").getTurnUseCard = function(self)
  	for _,c in sgs.list(self.player:getPile("jbbing"))do
	   	local fs = sgs.Sanguosha:cloneCard("slash")
		fs:setSkillName("jibing")
		fs:addSubcard(c)
		if fs:isAvailable(self.player)
	   	then return fs end
		fs:deleteLater()
	end
end

sgs.ai_skill_playerchosen.binghuo = function(self,players,reason)
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
end

sgs.ai_skill_cardask["@huantu-invoke"] = function(self,data,pattern,prompt)
   	local target = self.room:getCurrent()
	local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
    if self:isFriend(target)
	and target:getHandcardNum()<3 or target:getHandcardNum()>4
	then return cards[math.random(1,#cards)]:getEffectiveId() end
    if not self:isEnemy(target)
	then return cards[1]:getEffectiveId() end
	return "."
end

sgs.ai_skill_invoke.huantu = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isEnemy(target)
	end
end

sgs.ai_skill_choice.huantu = function(self,choices,data)
	local items = choices:split("+")
	local target = data:toPlayer()
	if self:isFriend(target)
	and self:isWeak(target)
	then return items[1] end
	return items[2]
end

sgs.ai_skill_invoke.bihuo = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return self:isFriend(target)
	end
end

sgs.ai_skill_invoke.yachai = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isFriend(target) or target:getHandcardNum()<3
	end
end

sgs.ai_skill_choice.yachai = function(self,choices,data)
	local damage = data:toDamage()
	local items = choices:split("+")
	if self:isFriend(damage.to)
	then return items[2] end
end

sgs.ai_skill_choice.yachai_suit = function(self,choices)
	local items = choices:split("+")
	local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	local suits = {}
	for _,c in sgs.list(cards)do
		if suits[c:getSuitString()]
		then suits[c:getSuitString()]=suits[c:getSuitString()]+1
		else suits[c:getSuitString()]=1 end
	end
    local compare_func = function(a,b)
        return a<b
    end
    table.sort(suits,compare_func)
	for _,s in sgs.list(items)do
		if suits[s]==suits[1]
		then return s end
	end
end

addAiSkills("qingtan").getTurnUseCard = function(self)
	return sgs.Card_Parse("@QingtanCard=.")
end

sgs.ai_skill_use_func["QingtanCard"] = function(card,use,self)
	self:sort(self.enemies,"handcard",true)
	for _,ep in sgs.list(self.enemies)do
		if ep:getHandcardNum()>0
		then
			use.card = card
		end
	end
end

sgs.ai_use_value.QingtanCard = 9.4
sgs.ai_use_priority.QingtanCard = 5.8

sgs.ai_skill_choice.qingtan = function(self,choices)
	local items = choices:split("+")
	table.removeOne(items,items[#items])
	return items[math.random(1,#items)]
end

sgs.ai_skill_invoke.zhukou = function(self,data)
    return true
end

sgs.ai_skill_use["@@zhukou"] = function(self,prompt)
	local valid = {}
	local destlist = self.player:getAliveSiblings()
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	for _,fp in sgs.list(destlist)do
		if #valid>1 then break end
		if self:isEnemy(fp) then table.insert(valid,fp:objectName()) end
	end
	for _,fp in sgs.list(destlist)do
		if #valid>1 then break end
		if table.contains(valid,fp:objectName())
		or self:isFriend(fp)
		then continue end
		table.insert(valid,fp:objectName())
	end
	if #valid>1
	then
    	return string.format("@ZhukouCard=.->%s",table.concat(valid,"+"))
	end
end

sgs.ai_skill_playerchosen.zhukou = function(self,players,reason)
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
end

sgs.ai_skill_choice.yuyun = function(self,choices)
	local items = choices:split("+")
	if table.contains(items,"maxhp")
	and self.player:getLostHp()>1
	then return "maxhp" end
	if table.contains(items,"hp")
	then return "hp" end
	if table.contains(items,"damage")
	then
		for _,fp in sgs.list(self.enemies)do
			if self:isWeak(fp) then return "damage" end
		end
	end
	if table.contains(items,"drawmaxhp")
	then
		for _,fp in sgs.list(self.friends)do
			if fp:getMaxHp()-fp:getHandcardNum()>1
			and fp:getHandcardNum()<5
			then return "drawmaxhp" end
		end
	end
	if table.contains(items,"obtain")
	then
		for _,fp in sgs.list(self.friends_noself)do
			if self:canDisCard(fp,"ej")
			then return "obtain" end
		end
	end
	if table.contains(items,"draw")
	and self.player:getHandcardNum()<=self.player:getMaxCards()
	then return "draw" end
	if table.contains(items,"maxcard")
	and self.player:getHandcardNum()>self.player:getMaxCards()
	then return "maxcard" end
end

sgs.ai_skill_playerchosen.yuyun = function(self,players,reason)
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
end

sgs.ai_skill_playerchosen.yuyun_obtain = function(self,players,reason)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
	for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and self:canDisCard(target,"ej")
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and self:canDisCard(target)
		then return target end
	end
	for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		and self:canDisCard(target)
		then return target end
	end
end

sgs.ai_skill_playerchosen.yuyun_drawmaxhp = function(self,players,reason)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard")
	for _,fp in sgs.list(destlist)do
		if fp:getMaxHp()-fp:getHandcardNum()>1
		and fp:getHandcardNum()<5
		and self:isFriend(fp)
		then return fp end
	end
	for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		then return target end
	end
end

sgs.ai_skill_playerchosen.zhenge = function(self,players,reason)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp",true)
	for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and target:getMark("&zhenge")<1
		then return target end
	end
	for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		and target:getMark("&zhenge")<1
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		then return target end
	end
end

sgs.ai_skill_invoke.zhenge = function(self,data)
	local items = data:toString():split(":")
    target = self.room:findPlayerByObjectName(items[2])
	if target
	then
		return self:isFriend(target)
	end
end

sgs.ai_skill_use["@@zhenge!"] = function(self,prompt)
    local c = dummyCard()
	c:setSkillName("_zhenge")
    local dummy = self:aiUseCard(c)
   	local tos = {}
   	if dummy.card
   	and dummy.to
   	then
       	for _,p in sgs.list(dummy.to)do
       		table.insert(tos,p:objectName())
       	end
       	return c:toString().."->"..table.concat(tos,"+")
    end
	dummy.to = sgs.SPlayerList()
    for _,to in sgs.list(self.room:getAllPlayers())do
		if CanToCard(c,self.player,to,dummy.to) and self:isEnemy(to)
		then dummy.to:append(to) table.insert(tos,p:objectName()) end
	end
    for _,to in sgs.list(self.room:getAllPlayers())do
		if dummy.to:contains(to) then continue end
		if CanToCard(c,self.player,to,dummy.to) and not self:isFriend(to)
		then dummy.to:append(to) table.insert(tos,p:objectName()) end
	end
   	return #tos>0 and c:toString().."->"..table.concat(tos,"+")
end

sgs.ai_skill_cardask["@tianze-discard"] = function(self,data,pattern,prompt)
	local use = data:toCardUse()
    if self:isEnemy(use.from)
	then return true end
	return "."
end

sgs.ai_skill_use["@@difa"] = function(self,prompt)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	local strs = self.player:property("DifaCardStr"):toString():split("+")
	for _,h in sgs.list(cards)do
		if table.contains(strs,""..h:getEffectiveId())
		then
			return string.format("@DifaCard=%s",h:getEffectiveId())
		end
	end
end

sgs.ai_skill_invoke.zhuangshu = function(self,data)
    return true
end

sgs.ai_skill_cardask["@zhuangshu-discard"] = function(self,data,pattern,prompt)
	local target = data:toPlayer()
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
    if self:isFriend(target)
	and target:getTreasure()==nil and #cards>2
	then return cards[1]:getEffectiveId() end
	return "."
end

sgs.ai_skill_use["@@chuiti"] = function(self,prompt)
	local ids = self.player:getTag("chuiti_forAI"):toString():split("+")
	for c,id in sgs.list(ids)do
		c = sgs.Sanguosha:getCard(id)
		local d = self:aiUseCard(c)
		if d.card and d.to
		then
			local tos = {}
			for _,p in sgs.list(d.to)do
				table.insert(tos,p:objectName())
			end
			return c:toString().."->"..table.concat(tos,"+")
		end
	end
end

sgs.ai_skill_invoke.wanwei = function(self,data)
    return true
end

sgs.ai_skill_invoke.yuejian = function(self,data)
	local use = data:toCardUse()
    local cards = self.player:getCards("h")
	for i,c in sgs.list(ids)do
		if c:getSuit()==use.card:getSuit()
		then return end
	end
	return true
end

addAiSkills("zhuning").getTurnUseCard = function(self)
	self.isfriend = nil
	local cards = sgs.QList2Table(self.player:getCards("he"))
	if #cards<2 then return end
	self:sortByKeepValue(cards)
	local toids = {}
  	for _,c in sgs.list(cards)do
		if #self.friends_noself<1
		or #toids>=#cards/2
		then continue end
		table.insert(toids,c:getEffectiveId())
		self.isfriend = true
	end
	if #toids<1 then table.insert(toids,cards[1]:getEffectiveId()) end
	if #toids>0 then return sgs.Card_Parse("@ZhuningCard="..table.concat(toids,"+")) end
end

sgs.ai_skill_use_func["ZhuningCard"] = function(card,use,self)
	if self.isfriend
	then
		self:sort(self.friends_noself,"hp")
		for _,ep in sgs.list(self.friends_noself)do
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	self:sort(self.enemies,"hp",true)
	for _,ep in sgs.list(self.enemies)do
		use.card = card
		if use.to then use.to:append(ep) end
		return
	end
end

sgs.ai_use_value.ZhuningCard = 9.4
sgs.ai_use_priority.ZhuningCard = 2.8

sgs.ai_skill_askforag.zhuning = function(self,card_ids)
	for c,id in sgs.list(card_ids)do
		c = sgs.Sanguosha:getCard(id)
		c = sgs.Sanguosha:cloneCard(c:objectName())
		c:setSkillName("_zhuning")
		local d = self:aiUseCard(c)
		self.zhuning_d = d
		if d.card and d.to
		then return id end
		c:deleteLater()
	end
end

sgs.ai_skill_use["@@zhuning"] = function(self,prompt)
	if self.zhuning_d
	then
		local tos = {}
		for _,p in sgs.list(self.zhuning_d.to)do
			table.insert(tos,p:objectName())
		end
		return self.zhuning_d.card:toString().."->"..table.concat(tos,"+")
	end
end












