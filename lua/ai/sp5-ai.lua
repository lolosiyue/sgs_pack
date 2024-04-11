

sgs.ai_skill_discard.zhouxuanz = function(self,x,n)
	local cards = {}
    local handcards = self.player:getCards("h")
    handcards = self:sortByKeepValue(handcards,true) -- 按保留值排序
   	for _,h in sgs.list(handcards)do
		if #handcards-#cards<self.player:getMaxCards()/2 or #cards>=x then break end
		table.insert(cards,h:getEffectiveId())
	end
	return cards
end

sgs.ai_skill_invoke.xianlve = function(self,data)
    return true
end

sgs.ai_skill_askforag.xianlve = function(self,card_ids)
	for c,id in sgs.list(card_ids)do
		c = sgs.Sanguosha:getCard(id)
		if self:getUseValue(c)>4
		then return id end
	end
end

addAiSkills("zaowang").getTurnUseCard = function(self)
	return sgs.Card_Parse("@ZaowangCard=.")
end

sgs.ai_skill_use_func["ZaowangCard"] = function(card,use,self)
	self:sort(self.friends,"hp",true)
	for _,ep in sgs.list(self.friends)do
		if ep:getHp()>=self.player:getHp()
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.ZaowangCard = 9.4
sgs.ai_use_priority.ZaowangCard = 4.8

sgs.ai_skill_invoke.guowu = function(self,data)
    return true
end

sgs.ai_skill_use["@@guowu2"] = function(self,prompt)
	local valid = {}
	local pr = prompt:split(":")
	local n = pr[4]-0
	local destlist = self.room:getAllPlayers()
    destlist = self:sort(destlist,"hp")
	for i=1,n do
		local use = sgs.CardUseStruct()
		use.from = self.player
		use.card = dummyCard(pr[2])
		local tos = sgs.SPlayerList()
		for _,ep in sgs.list(destlist)do
			if ep:hasFlag("guowu_canchoose")
			then tos:append(ep)
			elseif CanToCard(use.card,self.player,ep,use.to)
			then use.to:append(ep) end
		end
		self.player:setTag("yb_zhuzhan2_data",ToData(use))
		tos = sgs.ai_skill_playerchosen.yb_zhuzhan2(self,tos)
		if tos
		then
			table.insert(valid,tos:objectName())
			table.removeOne(destlist,tos)
		end
	end
	if #valid>0
	then
    	return string.format("@GuowuCard=.->%s",table.concat(valid,"+"))
	end
end

sgs.ai_skill_invoke.yuqi = function(self,data)
	local target = data:toPlayer()
	if target
	then
		self.yuqi_to = target
	end
	return true
end

sgs.ai_skill_use["@@yuqi1"] = function(self,prompt)
	if not self:isFriend(self.yuqi_to)
	then return end
	local yuqi_help = self.player:getTag("yuqiForAI"):toIntList()
	local n1,n2 = {},{}
	for c,id in sgs.list(yuqi_help)do
		table.insert(n1,sgs.Sanguosha:getCard(id))
	end
	local n = self.player:getMark("yuqi_help")
	self:sortByKeepValue(n1,true)
	local poisons = self:poisonCards(n1)
	for _,c in sgs.list(n1)do
		if #n2>=n then break end
		if table.contains(poisons,c) then continue end
		table.insert(n2,c:getEffectiveId())
	end
	return #n2>0 and ("@YuqiCard="..table.concat(n2,"+"))
end

sgs.ai_skill_use["@@yuqi2"] = function(self,prompt)
	local valid = {}
	local yuqi_help = self.player:getTag("yuqiForAI"):toIntList()
	local n1,n2 = {},{}
	for c,id in sgs.list(yuqi_help)do
		table.insert(n1,sgs.Sanguosha:getCard(id))
	end
	local n = self.player:getMark("yuqi_help")
	self:sortByKeepValue(n1,true)
	local poisons = self:poisonCards(n1)
	for _,c in sgs.list(n1)do
		if #n2>=n then break end
		if table.contains(poisons,c) then continue end
		table.insert(n2,c:getEffectiveId())
	end
	return #n2>0 and ("@YuqiCard="..table.concat(n2,"+"))
end

sgs.ai_skill_invoke.shanshen = function(self,data)
    return true
end

sgs.ai_skill_invoke.xianjing = function(self,data)
    return true
end

sgs.ai_skill_cardask.yuqi = function(self,data,pattern,prompt)
    local parsed = prompt:split(":")
    if not self:isWeak(self.player)
	and self.player:getMark("yuqi-Clear")<2
	then
    	if parsed[1]=="slash-jink"
		then
	    	parsed = data:toSlashEffect()
			local card = parsed.slash
			if self:canLoseHp(parsed.from,parsed.slash)
			and not self:isFriend(parsed.from)
			then return false end
		else
	    	parsed = data:toCardEffect()
			local card = parsed.card
			if card and card:isDamageCard()
			and not self:isFriend(parsed.from)
			and self:canLoseHp(parsed.from,parsed.card)
			then return false end
		end
	end
end

sgs.ai_nullification.yuqi = function(self,trick,from,to,positive)
    if to:hasSkill("yuqi")
	and self:isFriend(to)
	and not self:isWeak(to)
	and trick:isDamageCard()
	and to:getMark("yuqi-Clear")<2
   	and self:canLoseHp(from,trick,to)
	then return false end
end

sgs.ai_skill_invoke.huguan = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return self:isFriend(target)
	end
end

sgs.ai_skill_cardask["@yaopei-discard"] = function(self,data,pattern,prompt)
    local parsed = data:toPlayer()
    if self:isFriend(parsed)
	then return true end
	return "."
end

sgs.ai_skill_choice.yaopei = function(self,choices,data)
	local items = choices:split("+")
	local target = data:toPlayer()
	if self:isWeak() then return items[1] end
	if self:isWeak(target) then return items[2] end
	if self.player:isWounded() then return items[1] end
	if target:isWounded() then return items[2] end
	if target:getHandcardNum()>=target:getHandcardNum()
	then return items[2] else return items[1] end
end

sgs.ai_skill_use["@@heqia1"] = function(self,prompt)
	local valid,to = {},nil
	if #self.friends_noself<1 then return end
	self:sort(self.friends_noself,"card",true)
    for _,p in sgs.list(self.friends_noself)do
      	if p:getHandcardNum()>4
    	then return string.format("@HeqiaCard=.->%s",p:objectName()) end
	end
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if #valid>=#cards/2 then break end
    	table.insert(valid,h:getEffectiveId())
	end
	to = self.friends_noself[#self.friends_noself]
	if #valid<1 then return end
	return string.format("@HeqiaCard=%s->%s",table.concat(valid,"+"),to:objectName())
end

sgs.ai_skill_discard.heqia = function(self)
	local to_cards = {}
	local cards = self.player:getCards("h")
	cards = self:sortByUseValue(cards,true)
	if self:isFriend(self.room:getCurrent())
	then
		for _,c in sgs.list(cards)do
			if #to_cards>=#cards/2 then break end
			table.insert(to_cards,c:getEffectiveId())
		end
	end
	return to_cards
end

sgs.ai_skill_askforag.heqia = function(self,card_ids)
	local cards = self.player:getCards("h")
	if cards:length()<1 then return end
	for c,id in sgs.list(card_ids)do
		c = sgs.Sanguosha:getCard(id)
		c = sgs.Sanguosha:cloneCard(c:objectName())
		c:addSubcard(cards:at(0))
		c:setSkillName("_heqia")
		c:deleteLater()
		local d = self:aiUseCard(c)
		self.heqia_use = d
		if d.card and d.to
		then return id end
	end
end

sgs.ai_skill_use["@@heqia2"] = function(self,prompt)
    local dummy = self.heqia_use
   	if dummy.card
   	and dummy.to
   	then
      	local tos = {}
       	for _,p in sgs.list(dummy.to)do
       		table.insert(tos,p:objectName())
       	end
		if dummy.card:isKindOf("Peach")
		then
			for _,p in sgs.list(self.friends_noself)do
				if self.player:isProhibited(p,dummy.card)
				or not p:isWounded()
				or #tos>=self.player:getMark("heqia_get_card")
				then continue end
				table.insert(tos,p:objectName())
			end
		end
       	return dummy.card:toString().."->"..table.concat(tos,"+")
    end
end

sgs.ai_skill_invoke.lanjiang = function(self,data)
    return true
end

sgs.ai_skill_invoke.lanjiang_draw = function(self,data)
   	local target = self.room:getCurrent()
	return self:isFriend(target)
end

sgs.ai_skill_playerchosen.lanjiang = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and target:getHandcardNum()>=self.player:getHandcardNum()
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		and target:getHandcardNum()>=self.player:getHandcardNum()
		then return target end
	end
	self:sort(destlist,"hp")
	for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and target:getHandcardNum()<self.player:getHandcardNum()
		then return target end
	end
	for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		and target:getHandcardNum()<self.player:getHandcardNum()
		then return target end
	end
--	return destlist[1]
end

sgs.ai_skill_cardask["@mingluan-discard"] = function(self,data,pattern,prompt)
    local target = self.room:getCurrent()
    if self.player:getHandcardNum()<target:getHandcardNum()
	and self.player:getHandcardNum()<5
	then return true end
	return "."
end

sgs.ai_skill_playerchosen.bingqing = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	local n = self.player:getMark("bingqing_suit-PlayClear")
	self:sort(destlist,"hp")
	if n<3
	then
		for _,target in sgs.list(destlist)do
			if self:isFriend(target)
			then return target end
		end
		for _,target in sgs.list(destlist)do
			if not self:isEnemy(target)
			then return target end
		end
	elseif n<4
	then
		for _,target in sgs.list(destlist)do
			if self:isFriend(target)
			and self:doDisCard(target,"ej")
			then return target end
		end
		for _,target in sgs.list(destlist)do
			if self:isEnemy(target)
			then return target end
		end
		for _,target in sgs.list(destlist)do
			if not self:isFriend(target)
			then return target end
		end
	elseif n<5
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
--	return destlist[1]
end

sgs.ai_skill_playerchosen.yingfeng = function(self,players)
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
end

sgs.ai_skill_playerchosen.jixianzl = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard")
	for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and target:getHandcardNum()<3
		then return target end
	end
	for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		and target:getHandcardNum()<3
		then return target end
	end
	for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		then return target end
	end
end

addAiSkills("jinhui").getTurnUseCard = function(self)
	return sgs.Card_Parse("@JinhuiCard=.")
end

sgs.ai_skill_use_func["JinhuiCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.JinhuiCard = 9.4
sgs.ai_use_priority.JinhuiCard = 4.8

sgs.ai_skill_use["@@jinhui2!"] = function(self,prompt)
	local ids = self.player:getTag("jinhuiForAI"):toIntList()
	local n1 = {}
	for c,id in sgs.list(ids)do
		table.insert(n1,sgs.Sanguosha:getCard(id))
	end
	self:sortByKeepValue(n1,true)
   	local target = self.room:getCurrent()
	for _,c in sgs.list(n1)do
		if self.player:canUse(c,target,true)
		then
			return ("@JinhuiUseCard="..c:getEffectiveId())
		end
	end
	return ("@JinhuiUseCard="..n1[1]:getEffectiveId())
end

sgs.ai_skill_use["@@jinhui1"] = function(self,prompt)
	local ids = self.player:getTag("jinhuiForAI"):toIntList()
	local n1,n2 = {},{}
	for c,id in sgs.list(ids)do
		table.insert(n1,sgs.Sanguosha:getCard(id))
	end
	self:sortByKeepValue(n1,true)
	return ("@JinhuiUseCard="..n1[1]:getEffectiveId())
end

sgs.ai_skill_playerchosen.jinhui = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard")
	for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		then return target end
	end
	for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
	for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		then return target end
	end
	return destlist[1]
end

sgs.ai_skill_choice.saodi = function(self,choices,data)
	local items = choices:split("+")
	local use = data:toCardUse()
    local to = use.to:at(0)
	local rights,right,lefts,left = 0,0,0,0
    local to1 = self.player:getNextAlive()
    while to1~=to do
        rights = rights+1
		right = self:isFriend(to1) and right+1 or right
        to1 = to1:getNextAlive()
    end
    to1 = to:getNextAlive()
    while to1~=self.player do
        lefts = lefts+1
		left = self:isFriend(to1) and left+1 or left
        to1 = to1:getNextAlive()
    end
	if rights<lefts
	then
		if rights-right>=right
		then return items[1] end
	elseif rights>lefts
	then
		if lefts-left>=left
		then return items[1] end
	else
		if rights-right>=right
		then return items[1] end
		if lefts-left>=left
		then return items[2] end
	end
	return items[2]
end

sgs.ai_skill_playerchosen.zhuitao = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard")
	for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and self.player:distanceTo(target)>1
		then return target end
	end
	for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and self.player:distanceTo(target)>1
		then return target end
	end
	for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		and self.player:distanceTo(target)>1
		then return target end
	end
	for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		then return target end
	end
end

sgs.ai_skill_invoke.jiqiaosy = function(self,data)
    return self.player:getMaxHp()>2
end

sgs.ai_skill_use["@@jiqiaosy!"] = function(self,prompt)
	local n1,n2 = {},{}
	n2.isRed = 0
	n2.isBlack = 0
	for c,id in sgs.list(self.player:getPile("jiqiaosy"))do
		c = sgs.Sanguosha:getCard(id)
		table.insert(n1,c)
		if c:isRed() then n2.isRed = n2.isRed+1
		else n2.isBlack = n2.isBlack+1 end
	end
	self:sortByUseValue(n1,true)
	for d,c in sgs.list(n1)do
		d = self:aiUseCard(c)
		if d.card and c:isAvailable(self.player)
		then
			if c:isRed() and n2.isRed>n2.isBlack
			then return ("@JiqiaosyCard="..c:getEffectiveId())
			elseif c:isBlack() and n2.isRed<n2.isBlack
			then return ("@JiqiaosyCard="..c:getEffectiveId()) end
		end
	end
	for _,c in sgs.list(n1)do
		if c:isRed() and n2.isRed>n2.isBlack
		then return ("@JiqiaosyCard="..c:getEffectiveId())
		elseif c:isBlack() and n2.isRed<n2.isBlack
		then return ("@JiqiaosyCard="..c:getEffectiveId()) end
	end
	self:sortByKeepValue(n1,true)
	for d,c in sgs.list(n1)do
		d = self:aiUseCard(c)
		if d.card and c:isAvailable(self.player)
		then
			return ("@JiqiaosyCard="..c:getEffectiveId())
		end
	end
	return ("@JiqiaosyCard="..n1[1]:getEffectiveId())
end

sgs.ai_skill_invoke.xiongyisy = function(self,data)
    local dying = data:toDying()
	return dying.who:objectName()==self.player:objectName()
	and self:getCardsNum("Peach")+self:getCardsNum("Analeptic")<1
end

addAiSkills("xiongmang").getTurnUseCard = function(self)
	local cards = self:addHandPile()
	self:sortByKeepValue(cards,nil,true)
   	local fs = sgs.Sanguosha:cloneCard("slash")
	fs:setSkillName("xiongmang")
	local suits,n = {},0
   	for i,ep in sgs.list(self.enemies)do
		if self.player:canSlash(ep,fs)
		then n = n+1 end
	end
  	for _,c in sgs.list(cards)do
		if suits[c:getSuitString()]
		or fs:subcardsLength()>=n
		then continue end
		suits[c:getSuitString()]=true
		fs:addSubcard(c)
	end
	if fs:isAvailable(self.player)
	and fs:subcardsLength()>#self.enemies/2
 	then return fs end
	fs:deleteLater()
end

sgs.ai_skill_use["@@xiongmang"] = function(self,prompt)
	local valid = {}
	local xiongmang_c = self.player:property("xiongmang"):toString()
	xiongmang_c = sgs.Card_Parse(c)
	local destlist = self.player:getAliveSiblings()
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	for _,ep in sgs.list(destlist)do
		if #valid>=xiongmang_c:subcardsLength()-1 then break end
		if self:isEnemy(ep)
		and self.player:canSlash(ep,xiongmang_c)
		and not ep:hasFlag("xiongmang_target")
		then table.insert(valid,ep:objectName()) end
	end
	for _,ep in sgs.list(destlist)do
		if #valid>=xiongmang_c:subcardsLength()-1 then break end
		if table.contains(valid,ep:objectName()) then continue end
		if not self:isFriend(ep)
		and self.player:canSlash(ep,xiongmang_c)
		and not ep:hasFlag("xiongmang_target")
		then table.insert(valid,ep:objectName()) end
	end
	if #valid>0
	then
    	return string.format("@XiongmangCard=.->%s",table.concat(valid,"+"))
	end
end

sgs.ai_skill_use["@@jianliang"] = function(self,prompt)
	local valid = {}
	local destlist = self.player:getAliveSiblings()
	destlist:append(self.player)
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	for _,ep in sgs.list(destlist)do
		if #valid>1 then break end
		if self:isFriend(ep) then table.insert(valid,ep:objectName()) end
	end
	for _,ep in sgs.list(destlist)do
		if #valid>1 then break end
		if table.contains(valid,ep:objectName()) then continue end
		if not self:isEnemy(ep) then table.insert(valid,ep:objectName()) end
	end
	if #valid>0
	then
    	return string.format("@JianliangCard=.->%s",table.concat(valid,"+"))
	end
end

addAiSkills("weimeng").getTurnUseCard = function(self)
	if self.player:getHp()>0
	then
		return sgs.Card_Parse("@WeimengCard=.")
	end
end

sgs.ai_skill_use_func["WeimengCard"] = function(card,use,self)
	local destlist = self.room:getOtherPlayers(self.player)
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"handcard",true)
   	for i,ep in sgs.list(destlist)do
		if ep:getHandcardNum()>=self.player:getHp()
		and self:isEnemy(ep)
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
   	for i,ep in sgs.list(destlist)do
		if ep:getHandcardNum()>=self.player:getHp()
		and not self:isFriend(ep)
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
   	for i,ep in sgs.list(destlist)do
		if self:isFriend(ep)
		and ep:getHandcardNum()>0
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.WeimengCard = 9.4
sgs.ai_use_priority.WeimengCard = 5.8

sgs.ai_skill_invoke.yusui = function(self,data)
	local target = data:toPlayer()
	if target and self:isEnemy(target)
	and not self:isWeak()
	then
		return target:getHp()>self.player:getHp()
		or target:getHandcardNum()-self.player:getHandcardNum()>1
	end
end

sgs.ai_skill_choice.yusui = function(self,choices,data)
	local target = data:toPlayer()
	local items = choices:split("+")
	if ((target:getHp()-self.player:getHp())*2)>(target:getHandcardNum()-self.player:getHandcardNum())
	then return items[2] end
	return items[1]
end

addAiSkills("boyan").getTurnUseCard = function(self)
	return sgs.Card_Parse("@BoyanCard=.")
end

sgs.ai_skill_use_func["BoyanCard"] = function(card,use,self)
	local destlist = self.room:getOtherPlayers(self.player)
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"handcard")
   	for i,ep in sgs.list(destlist)do
		if self:isFriend(ep)
		and ep:getHandcardNum()<5
		and ep:getHandcardNum()<ep:getMaxHp()
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
   	for i,ep in sgs.list(destlist)do
		if (ep:getHandcardNum()>=ep:getMaxHp() or ep:getHandcardNum()>=5)
		and self:isEnemy(ep)
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
   	for i,ep in sgs.list(destlist)do
		if ep:getHandcardNum()<5
		and ep:getHandcardNum()<ep:getMaxHp()
		and not self:isEnemy(ep)
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.BoyanCard = 9.4
sgs.ai_use_priority.BoyanCard = 6.8

addAiSkills("juesheng").getTurnUseCard = function(self)
   	local fs = sgs.Sanguosha:cloneCard("duel")
	fs:setSkillName("juesheng")
	local d = self:aiUseCard(fs)
	if d.card and d.to
	and fs:isAvailable(self.player)
	then
		for i,ep in sgs.list(d.to)do
			i = ep:property("JueshengSlashNum"):toInt()
			if i>=ep:getHp() then return fs end
		end
	end
	fs:deleteLater()
end

sgs.ai_skill_choice.zengou = function(self,choices,data)
	local items = choices:split("+")
	local target = self.room:findPlayerByObjectName(items[1]:split("=")[2])
	if target and self:isEnemy(target)
	then
		if items[1]:startsWith("lose") and self:isWeak() then return "cancel" end
		if items[2]:startsWith("lose") and self:isWeak() then return items[1] end
		return items[1]
	end
	return "cancel"
end

sgs.ai_skill_cardask["@zengou-discard"] = function(self,data)
    local cards = self.player:getCards("he")
    cards = self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if self.player:isJilei(h)
		and h:getTypeId()==1
    	then continue end
		return h:getEffectiveId()
	end
    return "."
end

sgs.ai_skill_invoke.zhangji = function(self,data)
	local items = data:toString():split(":")
   	local target = self.room:getCurrent()
	if items[1]=="draw"
	then
		return not self:isEnemy(target)
	else
		return not self:isFriend(target)
	end
end

sgs.ai_skill_invoke.changji = function(self,data)
	return sgs.ai_skill_invoke.zhangji(self,data)
end

sgs.ai_skill_discard.shejian = function(self)
	local cards = {}
   	local target = self.room:getCurrent()
    local handcards = sgs.QList2Table(self.player:getCards("he"))
    self:sortByKeepValue(handcards) -- 按保留值排序
   	for _,h in sgs.list(handcards)do
		if #cards>1 then break end
		if self:isEnemy(target)
		and self:isWeak(target)
		then
			table.insert(cards,h:getEffectiveId())
		end
	end
	return #cards>1 and cards
end

sgs.ai_skill_choice.shejian = function(self,choices,data)
	local items = choices:split("+")
	if string.startsWith(items[1],"damage")
	then return items[2] end
	if string.startsWith(items[2],"damage")
	then return items[2] end
	return items[1]
end

sgs.ai_skill_playerchosen.jinhuaiyuan = function(self,players)
	local destlist = self:sort(players,"hp")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		then return target end
	end
end

sgs.ai_skill_choice.jinhuaiyuan = function(self,choices,data)
	local items = choices:split("+")
	local target = data:toPlayer()
	if target:getAttackRange()<3
	then return items[2] end
	if target:getMaxCards()<5
	then return items[1] end
	return items[3]
end

addAiSkills("jinchongxin").getTurnUseCard = function(self)
	if self.player:getCardCount()>1
	then
		return sgs.Card_Parse("@JinChongxinCard=.")
	end
end

sgs.ai_skill_use_func["JinChongxinCard"] = function(card,use,self)
	self:sort(self.enemies,"hp")
	for _,ep in sgs.list(self.enemies)do
		if ep:getHandcardNum()==1
		and self.player:inMyAttackRange(ep)
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	for _,ep in sgs.list(self.friends_noself)do
		if ep:getHandcardNum()>1
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	for _,ep in sgs.list(self.room:getOtherPlayers(self.player))do
		if ep:getHandcardNum()>0
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.JinChongxinCard = 3.4
sgs.ai_use_priority.JinChongxinCard = 4.8

sgs.ai_skill_cardask["@jinchongxin-recast"] = function(self,data)
    local cards = self.player:getCards("he")
    cards = self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if self.player:isCardLimited(h,sgs.Card_MethodRecast,self.player:getHandcards():contains(h))
    	then continue end
		return h:getEffectiveId()
	end
    return "."
end

sgs.ai_skill_playerchosen.jinweishu = function(self,players)
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

sgs.ai_skill_playerchosen.jinweishu_dis = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and self:doDisCard(target,"e")
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and self:doDisCard(target,"he")
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		and self:doDisCard(target,"he")
		then return target end
	end
	return destlist[1]
end

addAiSkills("channi").getTurnUseCard = function(self)
	local toids = {}
	local cards = self.player:getCards("h")
	cards = self:sortByKeepValue(cards)
  	for _,c in sgs.list(cards)do
		if #toids>#cards/2 then break end
		table.insert(toids,c:getEffectiveId())
	end
	if #toids<1 then return end
	return sgs.Card_Parse("@ChanniCard="..table.concat(toids,"+"))
end

sgs.ai_skill_use_func["ChanniCard"] = function(card,use,self)
	self:sort(self.friends_noself,"handcard",true)
	for c,fp in sgs.list(self.friends_noself)do
		c = dummyCard("duel")
		c:setSkillName("_channi")
		if c:isAvailable(fp)
		then
			use.card = card
			if use.to then use.to:append(fp) end
			return
		end
	end
end

sgs.ai_use_value.ChanniCard = 2.4
sgs.ai_use_priority.ChanniCard = 0.8

sgs.ai_skill_use["@@channi"] = function(self,prompt)
    local n = self.player:getMark("channi_mark-Clear")
	c = dummyCard("duel")
	c:setSkillName("_channi")
    local cards = self.player:getCards("h")
    cards = self:sortByKeepValue(cards,nil,true) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if c:subcardsLength()>=#cards/2
		or c:subcardsLength()>=n
		then break end
		if h:isKindOf("Slash")
		and math.random()>0.4
		then continue end
		c:addSubcard(h)
	end
    local dummy = self:aiUseCard(c)
   	if dummy.card
   	and dummy.to
   	then
      	local tos = {}
       	for _,p in sgs.list(dummy.to)do
       		table.insert(tos,p:objectName())
       	end
       	return c:toString().."->"..table.concat(tos,"+")
    end
end

sgs.ai_skill_invoke.tiqi = function(self,data)
    return true
end

sgs.ai_skill_choice.tiqi = function(self,choices,data)
	local items = choices:split("+")
	local target = data:toPlayer()
	if self:isFriend(target)
	then return items[1] end
	return items[2]
end

sgs.ai_skill_use["@@baoshu"] = function(self,prompt)
	local valid = {}
	local destlist = self.player:getAliveSiblings()
	destlist:append(self.player)
    destlist = self:sort(destlist,"hp")
	for _,friend in sgs.list(destlist)do
		if #valid>=self.player:getMaxHp() then break end
		if self:isFriend(friend)
		then table.insert(valid,friend:objectName()) end
	end
	if #valid>0
	then
    	return string.format("@BaoshuCard=.->%s",table.concat(valid,"+"))
	end
end

sgs.ai_skill_invoke.tianyun = function(self,data)
    return true
end

sgs.ai_skill_playerchosen.tianyun = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
end

sgs.ai_skill_playerchosen.yuyan = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and #self.enemies>#self.friends
		then return target end
		if self:isEnemy(target)
		and #self.enemies<#self.friends
		then return target end
	end
	return destlist[1]
end

sgs.ai_skill_invoke.bingjie = function(self,data)
    local n = 0
    for _,c in sgs.list(self:getTurnUse())do
		if c:getTypeId()==1
		or c:getTypeId()==2
		then n = n+1 end
	end
	return n>1 and self.player:isWounded()
end

sgs.ai_skill_invoke.qibie = function(self,data)
    return self.player:getHandcardNum()>4
	or self.player:isWounded()
end

addAiSkills("yijiao").getTurnUseCard = function(self)
	return sgs.Card_Parse("@YijiaoCard=.")
end

sgs.ai_skill_use_func["YijiaoCard"] = function(card,use,self)
	self:sort(self.friends_noself,"handcard",true)
	sgs.ai_skill_choice.yijiao = ""..math.random(1,2)
	for _,ep in sgs.list(self.friends_noself)do
		if ep:getHandcardNum()>0
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	sgs.ai_skill_choice.yijiao = ""..math.random(3,4)
	self:sort(self.enemies,"handcard")
	for _,ep in sgs.list(self.enemies)do
		if ep:getHandcardNum()>0
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	local tos = self.room:getOtherPlayers(self.player)
	tos = self:sort(tos,"handcard",true)
	sgs.ai_skill_choice.yijiao = ""..math.random(1,4)
	for _,ep in sgs.list(tos)do
		if ep:getHandcardNum()>2
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.YijiaoCard = 1.4
sgs.ai_use_priority.YijiaoCard = 1.8

sgs.ai_skill_use["@@xunli2!"] = function(self,prompt)
	local valid = {}
	local jpxlli = self.player:getTag("xunliForAI"):toIntList()
	jpxlli = getCardList(jpxlli)
	jpxlli = self:sortByUseValue(jpxlli)
	local put = 9-self.player:getPile("jpxlli"):length()
	for _,c in sgs.list(jpxlli)do
		if #valid>=put then break end
		if c:isAvailable(self.player)
		then
			table.insert(valid,c:getEffectiveId())
		end
	end
	for _,c in sgs.list(jpxlli)do
		if #valid>=put then break end
		if table.contains(valid,c:getEffectiveId())
		then continue end
		table.insert(valid,c:getEffectiveId())
	end
	return #valid>0 and string.format("@XunliPutCard=%s",table.concat(valid,"+"))
end

sgs.ai_skill_use["@@xunli1"] = function(self,prompt)
	local valid = {}
    local cards = self.player:getCards("h")
	local jpxlli = self.player:getPile("jpxlli")
	jpxlli = self:sortByUseValue(getCardList(jpxlli))
	for _,h in sgs.list(self:sortByKeepValue(cards))do
		if not h:isBlack() then continue end
		for i,c in sgs.list(jpxlli)do
			if self:aiUseCard(c).card
			then
				if self:aiUseCard(h).card
				then
					if self:getUseValue(h)<self:getUseValue(c)
					then
						table.insert(valid,h:getEffectiveId())
						table.insert(valid,c:getEffectiveId())
						table.remove(jpxlli,i)
						break
					end
				else
					table.insert(valid,h:getEffectiveId())
					table.insert(valid,c:getEffectiveId())
					table.remove(jpxlli,i)
					break
				end
			end
		end
	end
	return #valid>1 and string.format("@XunliCard=%s",table.concat(valid,"+"))
end

sgs.ai_skill_playerchosen.zhishi = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
end

sgs.ai_skill_use["@@zhishi"] = function(self,prompt)
	local valid = {}
	local jpxlli = self.player:getPile("jpxlli")
	jpxlli = getCardList(jpxlli)
	jpxlli = self:sortByUseValue(jpxlli)
	local to = self.player:getTag("ZhishiTarget"):toPlayer()
	for _,h in sgs.list(jpxlli)do
		if to:getHandcardNum()+#valid>3 or self:isEnemy(to) then continue end
		table.insert(valid,h:getEffectiveId())
	end
	return #valid>0 and string.format("@ZhishiCard=%s",table.concat(valid,"+"))
end

addAiSkills("lieyi").getTurnUseCard = function(self)
	if #self.toUse<2
	then
		return sgs.Card_Parse("@LieyiCard=.")
	end
end

sgs.ai_skill_use_func["LieyiCard"] = function(card,use,self)
	local jpxlli = self.player:getPile("jpxlli")
	jpxlli = getCardList(jpxlli)
	self:sort(self.enemies,"handcard")
	for n,ep in sgs.list(self.enemies)do
		n = 0
		for d,c in sgs.list(jpxlli)do
			d = self:aiUseCard(c)
			if d.card and d.to:contains(ep)
			then n = n+1 end
		end
		if n>jpxlli:length()/2
		or n>ep:getHp()
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	local tos = self.room:getOtherPlayers(self.player)
	tos = self:sort(tos,"handcard")
	for n,ep in sgs.list(tos)do
		n = 0
		for d,c in sgs.list(jpxlli)do
			d = self:aiUseCard(c)
			if d.card and d.to:contains(ep)
			then n = n+1 end
		end
		if n>jpxlli:length()/2
		or n>ep:getHp()
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.LieyiCard = 1.4
sgs.ai_use_priority.LieyiCard = 0.8

addAiSkills("manwang").getTurnUseCard = function(self)
	local toids = {}
	local cards = self.player:getCards("he")
	cards = self:sortByKeepValue(cards,nil,true)
	local n = 4-self.player:getMark("manwang_remove_last")
  	for _,c in sgs.list(cards)do
		if #toids>=#cards/2 or #toids>=n then break end
		if self:getUseValue(c)<3.5
		then
			table.insert(toids,c:getEffectiveId())
		end
	end
	if #toids<1 or #cards<3 then return end
	if self.player:hasSkill("panqin") and #toids<2 then return end
	if self:isWeak() and #toids<3 then return end
	return sgs.Card_Parse("@ManwangCard="..table.concat(toids,"+"))
end

sgs.ai_skill_use_func["ManwangCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.ManwangCard = 2.4
sgs.ai_use_priority.ManwangCard = 1.8

sgs.ai_skill_invoke.panqin = function(self,data)
    local dc = dummyCard()
	dc:setSkillName("panqin")
    for _,id in sgs.list(self.player:getTag("PanqinRecord"):toIntList())do
		if self.room:getCardPlace(id)==sgs.Player_DiscardPile
		then dc:addSubcard(id) end
	end
	return self:aiUseCard(dc).card
end

sgs.ai_skill_invoke.jinjian = function(self,data)
	local invoke = data:toString()
	local damage = self.player:getTag("JinjianDamage"):toDamage()
	if invoke=="add"
	then
		return self:isEnemy(damage.to)
		or not self:isFriend(damage.to) and not self:isWeak(damage.to)
	end
    return self:isFriend(damage.to)
	or self:isWeak(damage.to) and not self:isEnemy(damage.to)
end

sgs.ai_guhuo_card.dunshi = function(self,toname,class_name)
	if class_name=="Slash" then toname = "slash" end
   	local target = self.room:getCurrent()
	if self:getCardsNum(class_name)<1 or self:isFriend(target)
	then return "@DunshiCard=.:"..toname end
end

addAiSkills("dunshi").getTurnUseCard = function(self)
 	for dc,pn in sgs.list({"slash","peach","analeptic"})do
		if self.player:getMark("dunshi_used_"..pn)>0
		or pn=="slash" and not self.player:isWounded()
		then continue end
		dc = dummyCard(pn)
		if dc and self:getCardsNum(dc:getClassName())<1
		then
			dc:setSkillName("dunshi")
			if dc:isAvailable(self.player)
			then
				local dummy = self:aiUseCard(dc)
				if dummy.card and dummy.to
				then
					self.dunshi_to = dummy.to
					sgs.ai_use_priority.DunshiCard = sgs.ai_use_priority[dc:getClassName()]
					return sgs.Card_Parse("@DunshiCard=.:"..pn)
				end
			end
		end
	end
end

sgs.ai_skill_use_func["DunshiCard"] = function(card,use,self)
	if self.dunshi_to
	then
		use.card = card
		if use.to then use.to = self.dunshi_to end
	end
end

sgs.ai_use_value.DunshiCard = 2.4
sgs.ai_use_priority.DunshiCard = 6.8

sgs.ai_skill_choice.dunshi = function(self,choices,data)
	local items = choices:split("+")
	local damage = data:toDamage()
	if #items>2
	then
		if self.player:isWounded() or self.player:getMaxHp()>5 then return items[2] end
		if self:isFriend(damage.to) and self:isWeak(damage.to)
		or self:isFriend(damage.from) then return items[1] end
	else
		local cn = items[2]:split("=")[2]
		if cn=="slash" or cn=="analeptic"
		then return items[2] end
	end
	return items[1]
end

sgs.ai_skill_choice.dunshi_chooseskill = function(self,choices,data)
	local items = choices:split("+")
	local target = data:toPlayer()
	if self:isFriend(target)
	then
		if table.contains(items,"renzheng")
		then return "renzheng" end
		if table.contains(items,"lilu")
		then return "lilu" end
		if table.contains(items,"zhici")
		then return "zhici" end
	end
end

sgs.ai_skill_invoke.chenjian = function(self,data)
    return true
end

sgs.ai_skill_use["@@chenjian1"] = function(self,prompt)
	local valid = sgs.ai_skill_use["@@chenjian3"](self,prompt)
	if valid then return valid end
	return sgs.ai_skill_use["@@chenjian2"](self,prompt)
end

sgs.ai_skill_use["@@chenjian2"] = function(self,prompt)
	local jpxlli = self.player:getTag("chenjianForAI"):toIntList()
	jpxlli = getCardList(jpxlli)
	local suits = {}
    local cards = self.player:getCards("he")
    cards = self:sortByKeepValue(cards) -- 按保留值排序
	for s,c in sgs.list(jpxlli)do
		s = c:getSuitString()
		if suits[s] then suits[s] = suits[s]+1
		else suits[s] = 1 end
	end
	local func = function(a,b)
		return a>b
	end
	table.sort(suits,func)
	self:sort(self.friends,"handcard")
	for s,c in sgs.list(cards)do
		s = c:getSuitString()
		if suits[s] and suits[s]>0
		then
			return "@ChenjianCard="..c:getEffectiveId().."->"..self.friends[1]:objectName()
		end
	end
end

sgs.ai_skill_use["@@chenjian3"] = function(self,prompt)
	local valid = {}
	local jpxlli = self.player:getTag("chenjianForAI"):toIntList()
	jpxlli = getCardList(jpxlli)
	jpxlli = self:sortByKeepValue(jpxlli,true)
	for d,c in sgs.list(jpxlli)do
		if c:isAvailable(self.player)
		then
			d = self:aiUseCard(c)
			if d.card and d.to
			then
				if c:canRecast() and d.to:length()<1
				then continue end
				for _,to in sgs.list(d.to)do
					table.insert(valid,to:objectName())
				end
				return c:toString().."->"..table.concat(valid,"+")
			end
		end
	end
end

addAiSkills("yuanyu").getTurnUseCard = function(self)
	return sgs.Card_Parse("@YuanyuCard=.")
end

sgs.ai_skill_use_func["YuanyuCard"] = function(card,use,self)
	self:sort(self.enemies,"handcard",true)
	for _,ep in sgs.list(self.enemies)do
		if ep:getHandcardNum()>0
		and ep:getMark("&yuanyu+#"..self.player:objectName())<1
		then
			use.card = card
			return
		end
	end
	local tos = self.room:getOtherPlayers(self.player)
	tos = self:sort(tos,"handcard",true)
	for _,ep in sgs.list(tos)do
		if ep:getHandcardNum()>0
		and not self:isFriend(ep)
		then
			use.card = card
			return
		end
	end
end

sgs.ai_use_value.YuanyuCard = 3.4
sgs.ai_use_priority.YuanyuCard = 3.8

sgs.ai_skill_playerchosen.yuanyu = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard",true)
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and target:getMark("&yuanyu+#"..self.player:objectName())<1
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		and target:getMark("&yuanyu+#"..self.player:objectName())<1
		then return target end
	end
	return destlist[1]
end

sgs.ai_skill_playerchosen.jinzhefu = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard",true)
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

sgs.ai_skill_discard.jinzhefu = function(self,max,min,optional,include_equip,pattern)
	local to_cards = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
   	for _,h in sgs.list(cards)do
   		if #to_cards>=min then break end
		if self:getKeepValue(h)<5
		and sgs.Sanguosha:matchExpPattern(pattern,self.player,h)
		then table.insert(to_cards,h:getEffectiveId()) end
	end
	return to_cards
end


sgs.ai_skill_invoke.jinyidu = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return self:isEnemy(target)
		or not self:isFriend(target) and not self:isWeak(target)
	end
end

sgs.ai_skill_invoke.xingchong = function(self,data)
    return true
end

sgs.ai_skill_choice.xingchong = function(self,choices,data)
	local items = choices:split("+")
	if #items>1 then return items[math.random(2,#items)] end
	return items[1]
end

sgs.ai_skill_discard.xingchong = function(self,max,min)
	local to_cards = {}
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local uses = self:getTurnUse()
   	for _,h in sgs.list(cards)do
   		if #to_cards>=max then break end
		if table.contains(uses,h)
		then
         	table.insert(to_cards,h:getEffectiveId())
		end
	end
	return to_cards
end

sgs.ai_skill_playerschosen.lianzhou = function(self,players,n,x)
	local tos = {}
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard")
    for _,target in sgs.list(destlist)do
		if #tos>=x then break end
		if self:isEnemy(target)
		then table.insert(tos,target) end
	end
    for _,target in sgs.list(destlist)do
		if #tos>1 then break end
		if not self:isFriend(target)
		then table.insert(tos,target) end
	end
	return tos
end

sgs.ai_skill_invoke.choutao = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isFriend(target) and self:getCardsNum("Jink")<1
		or self:isFriend(target) and (self:doDisCard(target,"e") or target==self.player and target:getCardCount()>3)
	end
end

sgs.ai_skill_playerchosen.xiangshu = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and self:isWeak(target)
		and self.player:getMark("damage_point_round")>=target:getLostHp()
		then return target end
	end
end

sgs.ai_skill_invoke.zhubi = function(self,data)
   	local target = self.room:getCurrent()
	if target:getPhase()<sgs.Player_Play
	then return self:isFriend(target) end
	target = target:getNextAlive()
	return self:isFriend(target)
end

sgs.ai_skill_playerchosen.guili = function(self,players)
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

sgs.ai_skill_playerchosen.caiyi = function(self,players)
	local n = self.player:getChangeSkillState("caiyi")
	self.caiyi_from = self.player
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
	if n>1
	then
		for _,target in sgs.list(destlist)do
			if self:isEnemy(target)
			and (self:isWeak(target) or self:isWeak())
			then return target end
		end
	else
		local removes = self.player:property("SkillDescriptionRecord_caiyi"):toString():split("+")
		n = 4-#removes
		for _,target in sgs.list(destlist)do
			if self:isFriend(target)
			then
				if not table.contains(removes,"caiyi_recover") and (target:getLostHp()>=n or self:isWeak(target) and n>0)
				or not table.contains(removes,"caiyi_draw") and target:getHandcardNum()+n<5
				or not table.contains(removes,"caiyi_fuyuan") and not target:faceUp()
				or not table.contains(removes,"caiyi_random1") and self:isWeak(target)
				then return target end
			end
		end
	end
end

sgs.ai_skill_choice.caiyi = function(self,choices,data)
	local caiyi_from = self.caiyi_from or self.room:getCurrent()
	local n = caiyi_from:getChangeSkillState("caiyi")
	if n>1 then n = 4-(#caiyi_from:property("SkillDescriptionChoiceRecord1_caiyi"):toString():split("+"))
	else n = 4-(#caiyi_from:property("SkillDescriptionRecord_caiyi"):toString():split("+")) end
	local items = choices:split("+")
	self.room:writeToConsole(choices)
	
	for _,cho in sgs.list(items)do
		self.room:writeToConsole(cho)
		if string.startsWith(cho,"recover")
		and (self.player:getLostHp()>=n or self:isWeak() and n>0)
		then return cho end
		if string.startsWith(cho,"draw")
		and self.player:getHandcardNum()+n<5
		then return cho end
		if string.startsWith(cho,"fuyuan")
		and not self.player:faceUp()
		then return cho end
		if string.startsWith(cho,"discard")
		and self.player:getCardCount()-n>1
		then return cho end
		if string.startsWith(cho,"damage")
		and self.player:getHp()-n>1
		then return cho end
	end
end





















