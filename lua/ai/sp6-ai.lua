
sgs.ai_skill_invoke.qianlong = function(self,data)
    return true
end

sgs.ai_skill_use["@@qianlong"] = function(self,prompt)
	self.qianlong_use = false
	local yuqi_help = self.player:getTag("qianlong_forAI"):toString():split("+")
	local n1,n2 = {},{}
	for c,id in sgs.list(yuqi_help)do
		table.insert(n1,sgs.Sanguosha:getCard(id))
	end
	local n = self.player:getLostHp()
	self:sortByKeepValue(n1,true)
	local poisons = self:poisonCards(n1)
	for _,c in sgs.list(n1)do
		if #n2>=n then break end
		if table.contains(poisons,c) or c:isAvailable(self.player)
		then self.qianlong_use = true continue end
		table.insert(n2,c:getEffectiveId())
	end
	for _,c in sgs.list(n1)do
		if #n2>=n then break end
		if table.contains(poisons,c)
		or self.player:getMark("@juetaoMark")>0
		or table.contains(n2,c:getEffectiveId())
		then continue end
		table.insert(n2,c:getEffectiveId())
	end
	if #n2<1 then table.insert(n2,n1[1]:getEffectiveId()) end
	return #n2>0 and ("@QianlongCard="..table.concat(n2,"+"))
end

sgs.ai_skill_playerchosen.fensi = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
	local dc = dummyCard()
	dc:setSkillName("_fensi")
    for _,target in sgs.list(destlist)do
		if target:canSlash(self.player,dc,false)
		then continue end
		if self:isEnemy(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if target:canSlash(self.player,dc,false)
		then continue end
		if not self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		then return target end
	end
	if not self:isWeak()
	then return self.player end
    for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		then return target end
	end
	return self.player
end

sgs.ai_skill_playerchosen.juetao = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if self.player:inMyAttackRange(target)
		and self:isEnemy(target)
		and self:isWeak(target)
		and self.qianlong_use
		then return target end
	end
end

sgs.ai_skill_use["@@juetao!"] = function(self,prompt)
    local c = sgs.Sanguosha:getCard(self.player:getMark("juetao_card_id")-1)
	self.room:setCardFlag(c,"juetao_card")
    local dummy = self:aiUseCard(c)
   	if dummy.card
   	and dummy.to
   	then
		if c:canRecast()
		and dummy.to:length()<1
		then return end
      	local tos = {}
       	for _,p in sgs.list(dummy.to)do
       		table.insert(tos,p:objectName())
       	end
       	return c:toString().."->"..table.concat(tos,"+")
    end
end

sgs.ai_skill_playerchosen.zhushi = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target) and self:isWeak(target)
		or self:isFriend(target)
		then return target end
	end
end

addAiSkills("xiaowu").getTurnUseCard = function(self)
	local parse = sgs.Card_Parse("@XiaowuCard=.")
	assert(parse)
	return parse
end

sgs.ai_skill_use_func["XiaowuCard"] = function(card,use,self)
	use.card = card
	sgs.xiaowu_n = 0
end

sgs.ai_use_value.XiaowuCard = 3.4
sgs.ai_use_priority.XiaowuCard = 4.8

sgs.ai_skill_choice.xiaowu = function(self,choices,data)
	local items = choices:split("+")
	if table.contains(items,"xiajia")
	then return "xiajia" end
	if table.contains(items,"shangjia")
	then return "shangjia" end
	local target = data:toPlayer()
	sgs.xiaowu_n = sgs.xiaowu_n or 0
	if sgs.xiaowu_n<1 and self:isWeak()
	or self:isFriend(target)
	then
		sgs.xiaowu_n = sgs.xiaowu_n+1
		return items[1]
	else
		sgs.xiaowu_n = sgs.xiaowu_n-1
		return items[2]
	end
end

sgs.ai_skill_playerchosen.xiaowu = function(self,players)
	return self.player
end

sgs.ai_skill_invoke.huaping = function(self,data)
	local n = 0
	for _,p in sgs.list(self.room:getPlayers())do
		if p:isDead() then n = n+1 end
	end
	return n>1
end

sgs.ai_skill_playerchosen.huaping = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp",true)
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target) and self:isWeak(target)
		then return target end
	end
end

sgs.ai_skill_use["@@shawu"] = function(self,prompt)
	local valid = {}
	local to = self.player:getTag("ShawuTarget"):toPlayer()
	if not self:isEnemy(to) and self:isWeak(to)
	or self:isFriend(to)
	then return end
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if self.player:getMark("&lyexwsha")*2>#cards 
		or #valid>=2  then continue end
    	table.insert(valid,h:getEffectiveId())
	end
	valid = #valid>1 and table.concat(valid,"+") or "."
	return string.format("@ShawuCard=%s",valid)
end

sgs.ai_skill_playerchosen.tenyearxizhen = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		or not target:isWounded()
		then continue end
		local use = {to = sgs.SPlayerList(),card = dummyCard()}
		use.card:setSkillName("_tenyearxizhen")
		use.to:append(target)
		self:targetRevises(use)
		sgs.ai_skill_choice.tenyearxizhen = "slash="..target:objectName()
		if not use.to:contains(target) then return target end
		use.card = dummyCard("duel")
		use.card:setSkillName("_tenyearxizhen")
		self:targetRevises(use)
		sgs.ai_skill_choice.tenyearxizhen = "duel="..target:objectName()
		if not use.to:contains(target)
		and self:isFriend(target)
		and target:isWounded()
		then return target end
	end
	self:sort(destlist,"hp",true)
    for d,target in sgs.list(destlist)do
		local dc = dummyCard()
		dc:setSkillName("_tenyearxizhen")
		d = self:aiUseCard(dc)
		sgs.ai_skill_choice.tenyearxizhen = "slash="..target:objectName()
		if d.to:contains(target)
		then return target end
		dc = dummyCard("duel")
		dc:setSkillName("_tenyearxizhen")
		d = self:aiUseCard(dc)
		sgs.ai_skill_choice.tenyearxizhen = "duel="..target:objectName()
		if d.to:contains(target)
		then return target end
	end
end

sgs.ai_skill_playerchosen.luochong = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if target:objectName()==self.luochong_to:objectName()
		then return target end
	end
end

sgs.ai_skill_choice.luochong = function(self,choices)
	local items = choices:split("+")
	if table.contains(items,"recover")
	then
		self:sort(self.friends,"hp")
		for _,to in sgs.list(self.friends)do
			self.luochong_to = to
			if self:isWeak(to) and to:isWounded()
			then return "recover" end
		end
	end
	if table.contains(items,"lose")
	then
		self:sort(self.enemies,"hp")
		for _,to in sgs.list(self.enemies)do
			self.luochong_to = to
			if self:isWeak(to)
			then return "lose" end
		end
	end
	if table.contains(items,"draw")
	then
		self:sort(self.friends,"handcard")
		for _,to in sgs.list(self.friends)do
			self.luochong_to = to
			if to:getHandcardNum()<4
			then return "draw" end
		end
	end
	if table.contains(items,"discard")
	then
		self:sort(self.enemies,"card")
		for _,to in sgs.list(self.enemies)do
			self.luochong_to = to
			if to:getCardCount()>1
			then return "discard" end
		end
		for _,to in sgs.list(self.friends_noself)do
			self.luochong_to = to
			if self:canDisCard(to,"e")
			then return "recover" end
		end
		for _,to in sgs.list(self.enemies)do
			self.luochong_to = to
			if to:getCardCount()>0
			then return "discard" end
		end
	end
	if table.contains(items,"draw")
	then
		self:sort(self.friends,"handcard")
		for _,to in sgs.list(self.friends)do
			self.luochong_to = to
			return "draw"
		end
	end
	return items[#items]
end

sgs.ai_skill_choice.aicheng = function(self,choices)
	local items = choices:split("+")
	return items[#items]
end

sgs.ai_skill_playerschosen.tongxie = function(self,players)
	local tos = {}
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard",true)
    for _,target in sgs.list(destlist)do
		if self:isFriend(target) and #tos<2
		then table.insert(tos,target) end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target) and #tos<2
		and not table.contains(tos,target)
		then table.insert(tos,target) end
	end
	return #tos>1 and tos
end

sgs.ai_skill_invoke.fuping = function(self,data)
	local cn = data:toString()
	cn = cn:split(":")[2]
	if cn~=""
	then
		cn = dummyCard(cn)
		return self:getUseValue(cn)>5
		or cn:isDamageCard() and self:getUseValue(cn)>4
	end
end

addAiSkills("fuping").getTurnUseCard = function(self)
	local cards = self.player:getCards("he")
	cards = self:sortByKeepValue(cards,nil,true)
	local record = self.player:property("SkillDescriptionRecord_fuping"):toString()
	record = record:split("+")
  	for _,c in sgs.list(cards)do
		if c:getTypeId()==1 then continue end
		for d,pn in sgs.list(record)do
			if self.player:getMark("fuping_guhuo_remove_"..pn.."-Clear")>0
			then continue end
			d = dummyCard(pn)
			d:addSubcard(c)
			d:setSkillName("fuping")
			local parse = self:aiUseCard(d)
			if d:isAvailable(self.player) and parse.card and parse.to
			and self:getCardsNum(d:getClassName())<1
			then
				if d:canRecast()
				and parse.to:length()<1
				then return end
				self.fuping_to = parse.to
				sgs.ai_use_priority.FupingCard = sgs.ai_use_priority[d:getClassName()]
				return sgs.Card_Parse("@FupingCard="..c:getEffectiveId()..":"..pn)
			end
		end
	end
end

sgs.ai_skill_use_func["FupingCard"] = function(card,use,self)
	if self.fuping_to
	then
		use.card = card
		if use.to then use.to = self.fuping_to end
	end
end

sgs.ai_use_value.FupingCard = 5.4
sgs.ai_use_priority.FupingCard = 4.8

sgs.ai_guhuo_card.fuping = function(self,toname,class_name)
    local cards = self:addHandPile("he")
    cards = self:sortByKeepValue(cards,nil,true) -- 按保留值排序
	local record = self.player:property("SkillDescriptionRecord_fuping"):toString()
	record = record:split("+")
	if #cards<1 or not table.contains(record,toname)
	or self.player:getMark("fuping_guhuo_remove_"..toname.."-Clear")>0
	then return end
    local num = self:getCardsNum(class_name)
   	for _,c in sgs.list(cards)do
       	if c:getTypeId()~=1
		and num<1
      	then
           	return "@FupingCard="..c:getEffectiveId()..":"..toname
       	end
   	end
end

addAiSkills("weilie").getTurnUseCard = function(self)
	local cards = self.player:getCards("he")
	cards = self:sortByKeepValue(cards,nil,true)
	if self.player:getMark("weilie_used_times")<self.player:getMark("&weilie_time")+1
	and #cards>0
	then
		local parse = sgs.Card_Parse("@WeilieCard="..cards[1]:getEffectiveId())
		assert(parse)
		return parse
	end
end

sgs.ai_skill_use_func["WeilieCard"] = function(card,use,self)
	self:sort(self.friends,"hp")
	for _,fp in sgs.list(self.friends)do
		if self:isWeak(fp)
		then
			use.card = card
			if use.to then use.to:append(fp) end
			return
		end
	end
end

sgs.ai_use_value.WeilieCard = 3.4
sgs.ai_use_priority.WeilieCard = 0.8

addAiSkills("tenyearjinggong").getTurnUseCard = function(self)
	local cards = self:addHandPile("he")
	cards = self:sortByKeepValue(cards,nil,true)
  	for _,c in sgs.list(cards)do
		if c:getTypeId()~=3 then continue end
		d = dummyCard()
		d:addSubcard(c)
		d:setSkillName("tenyearjinggong")
		local parse = self:aiUseCard(d)
		if d:isAvailable(self.player)
		and parse.card and parse.to
		then return d end
	end
end

sgs.ai_guhuo_card.tenyearjinggong = function(self,toname,class_name)
    local cards = self:addHandPile("he")
    cards = self:sortByKeepValue(cards,nil,true) -- 按保留值排序
   local num = self:getCardsNum(class_name)
   	for d,c in sgs.list(cards)do
       	if c:getTypeId()==3 and class_name=="Slash"	and num<1
		and sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
      	then
           	d = dummyCard()
			d:addSubcard(c)
			d:setSkillName("tenyearjinggong")
			return d:toString()
       	end
   	end
end

sgs.ai_skill_invoke.tenyearxiaojun = function(self,data)
	local invoke = data:toString():split(":")
	if invoke
	then
		local to = BeMan(self.room,invoke[2])
		return not self:isFriend(to)
	end
end

sgs.ai_skill_invoke.tenyearmingfa = function(self,data)
	local cn = data:toString()
	cn = cn:split(":")[2]
	if cn~=""
	then
		cn = dummyCard(cn)
		cn:setSkillName("tenyearmingfa")
		self.tenyearmingfa_c = cn
		return (#self.enemies>0 or #self.friends_noself<1)
		and (cn:isDamageCard() or self:getUseValue(cn)>5)
	end
end

sgs.ai_skill_invoke.tenyeardeshao = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isFriend(target)
		or target:getHandcardNum()<=self.player:getHandcardNum()
		or self:canDisCard(target,"e")
	end
end

sgs.ai_skill_playerchosen.tenyearmingfa = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and self.tenyearmingfa_c:targetFixed()
		and self.player:canUse(self.tenyearmingfa_c,target,true)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and self.player:canUse(self.tenyearmingfa_c,target,true)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isFriend(target) and not self:isWeak(target)
		and self.player:canUse(self.tenyearmingfa_c,target,true)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		and self.player:canUse(self.tenyearmingfa_c,target,true)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self.player:canUse(self.tenyearmingfa_c,target,true)
		then return target end
	end
end

sgs.ai_skill_discard.liejie = function(self,max,min)
	local to_cards = {}
	local cards = self.player:getCards("he")
	cards = self:sortByKeepValue(cards,nil,true)
   	for _,hcard in sgs.list(cards)do
   		if #to_cards>#cards/2
		or #to_cards>=max
		then break end
		table.insert(to_cards,hcard:getEffectiveId())
	end
	return to_cards
end

sgs.ai_skill_cardchosen.liejie = function(self,who,flags,method)
	if self:isFriend(who)
	then
		if self:canDisCard(who,"e")
		then
			for _,e in sgs.list(who:getEquipsId())do
				if self:canDisCard(who,e)
				then return e end
			end
		end
		return -1
	end
end

sgs.ai_skill_invoke.yuanzi = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return self:isFriend(target)
		and #self.enemies>0
	end
	return true
end

sgs.ai_skill_invoke.tongli = function(self,data)
    return true
end

sgs.ai_skill_invoke.shezang = function(self,data)
    return true
end

sgs.ai_skill_playerchosen.tuoxian = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp",true)
	local n = self.player:getChangeSkillState("piaoping")
	for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and self:canDisCard(target,"ej")
		and self.player:getMark("&piaoping_trigger-Clear")<3
		then return target end
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

sgs.ai_skill_use["@@tuoxian"] = function(self,prompt)
	local n1,n2 = self.player:getCards("hej"),{}
	self:sortByKeepValue(n1)
	for i,c in sgs.list(n1)do
		i = c:getEffectiveId()
		if #n2>=self.player:getMark("tuoxian_discard") then break end
		if self:canDisCard(self.player,i) then table.insert(n2,i) end
	end
	for i,c in sgs.list(n1)do
		i = c:getEffectiveId()
		if #n2>=self.player:getMark("tuoxian_discard") then break end
		if #n2>0 and not table.contains(n2,i)
		then table.insert(n2,i) end
	end
	return #n2>0 and ("@TuoxianCard="..table.concat(n2,"+"))
end

sgs.ai_skill_playerchosen.dunxi = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard",true)
	local n = self.player:getChangeSkillState("piaoping")
	for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and target:getMark("&bxdxdun")<1
		then return target end
	end
	for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		and target:getMark("&bxdxdun")<1
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
end

sgs.ai_skill_invoke.tenyearxiecui = function(self,data)
	local cn = data:toString()
	cn = cn:split(":")
	if cn~=""
	then
		local to = BeMan(self.room,cn[3])
		local from = BeMan(self.room,cn[2])
		return self:isEnemy(to)
		or not self:isFriend(to) and self:isFriend(from)
	end
end

sgs.ai_skill_invoke.tenyearyouxu = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return self:isFriend(target)
		and #self.friends_noself>1
		or #self.friends_noself>0
		or not self:isFriend(target)
	end
end

sgs.ai_skill_playerchosen.tenyearyouxu = function(self,players)
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

sgs.ai_skill_invoke.zhongjie = function(self,data)
	local target = data:toPlayer()
	if target
	then
		if target:objectName()==self.player:objectName()
		then
			return self:getCardsNum("Peach")+self:getCardsNum("Analeptic")<1
		end
		return self:isFriend(target)
	end
end

sgs.ai_skill_invoke.sushou = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return target:getHandcardNum()>3
		and (not self:isWeak() or self.player:hasSkill("zhongjie") and self.player:getMark("zhongjie_used_lun")<1)
	end
end

sgs.ai_skill_use["@@sushou"] = function(self,prompt)
	local yuqi_help = self.player:getTag("sushou_forAI"):toString():split("+")
	local n1,n2 = {},{}
	for c,id in sgs.list(yuqi_help)do
		table.insert(n1,sgs.Sanguosha:getCard(id))
	end
	local cards = self.player:getCards("h")
	cards = self:sortByKeepValue(cards)
   	local target = self.room:getCurrent()
	local n = self.player:getLostHp()*2
	self:sortByKeepValue(n1,true)
	local poisons = self:poisonCards(n1)
	for _,c in sgs.list(n1)do
		if #n2>=n then break end
		for _,h in sgs.list(cards)do
			if #n2>=n then break end
			if table.contains(poisons,c)
			or table.contains(n2,h:getEffectiveId())
			or self:getUseValue(c)>self:getUseValue(h) and self:isFriend(target)
			or self:getKeepValue(c)<=self:getKeepValue(h) then continue end
			table.insert(n2,c:getEffectiveId())
			table.insert(n2,h:getEffectiveId())
			break
		end
	end
	return #n2>1 and ("@SushouCard="..table.concat(n2,"+"))
end

sgs.ai_skill_playerchosen.suizheng = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard",true)
	for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and target~=self.player
		then return target end
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

sgs.ai_skill_use["@@suizheng"] = function(self,prompt)
    local c = dummyCard()
	c:setSkillName("suizheng")
    local dummy = self:aiUseCard(c)
   	local tos = {}
   	if dummy.card
   	and dummy.to
   	then
       	for _,p in sgs.list(dummy.to)do
			if #tos>0 then break end
       		if p:hasFlag("suizheng_target")
			then
				table.insert(tos,p:objectName())
			end
       	end
    end
	local Players = self.room:getOtherPlayers(self.player)
	Players = self:sort(Players,"handcard")
   	for _,p in sgs.list(Players)do
   		if #tos>0 then break end
		if p:hasFlag("suizheng_target")
		and CanToCard(c,self.player,p) and self:isEnemy(p)
		then table.insert(tos,p:objectName()) end
   	end
   	for _,p in sgs.list(Players)do
   		if #tos>0 then break end
		if p:hasFlag("suizheng_target")
		and CanToCard(c,self.player,p) and not self:isFriend(p)
		then table.insert(tos,p:objectName()) end
   	end
	if #tos>0
	then
		return "@SuizhengCard=.->"..table.concat(tos,"+")
	end
end

addAiSkills("kaiji").getTurnUseCard = function(self)
	local n = self.player:getChangeSkillState("kaiji")
	sgs.ai_use_priority.KaijiCard = 9.8
	if n<2
	then
		return sgs.Card_Parse("@KaijiCard=.")
	end
	n = {}
	local cards = self.player:getCards("he")
	cards = self:sortByKeepValue(cards,nil,true)
	for _,c in sgs.list(cards)do
		if #n>#self.enemies or #n>=self.player:getMaxHp()
		or #n>#cards/2 then break end
		table.insert(n,c:getEffectiveId())
	end
	sgs.ai_use_priority.KaijiCard = 0.8
	if #n>0
	then
		return sgs.Card_Parse("@KaijiCard="..table.concat(n,"+"))
	end
end

sgs.ai_skill_use_func["KaijiCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.KaijiCard = 3.4
sgs.ai_use_priority.KaijiCard = 9.8

sgs.ai_skill_playerschosen.pingxi = function(self,players)
	local destlist = self:sort(players,"card")
	local tos,n = {},self.player:getMark("pingxi_discard-Clear")
	for _,target in sgs.list(destlist)do
		if #tos>=n then break end
		if self:isEnemy(target)
		and self:canDisCard(target)
		then table.insert(tos,target) end
	end
	self:sort(destlist,"card",true)
	for _,target in sgs.list(destlist)do
		if #tos>=n then break end
		if self:isFriend(target)
		and self:canDisCard(target,"ej")
		then table.insert(tos,target) end
	end
	self:sort(destlist,"card")
	for _,target in sgs.list(destlist)do
		if #tos>=n then break end
		if not self:isFriend(target)
		and not table.contains(tos,target)
		and self:canDisCard(target)
		then table.insert(tos,target) end
	end
	for _,target in sgs.list(destlist)do
		if #tos>=n then break end
		if not self:isFriend(target)
		and not table.contains(tos,target)
		then table.insert(tos,target) end
	end
	return tos
end

addAiSkills("xunji").getTurnUseCard = function(self)
	local parse = sgs.Card_Parse("@XunjiCard=.")
	assert(parse)
	return parse
end

sgs.ai_skill_use_func["XunjiCard"] = function(card,use,self)
	self:sort(self.enemies,"handcard",true)
	for _,fp in sgs.list(self.enemies)do
		if fp:getHandcardNum()>2
		then
			use.card = card
			if use.to then use.to:append(fp) end
			return
		end
	end
	for _,fp in sgs.list(self.room:getOtherPlayers(self.player))do
		if fp:getHandcardNum()>2
		and not self:isFriend(fp)
		then
			use.card = card
			if use.to then use.to:append(fp) end
			return
		end
	end
end

sgs.ai_use_value.XunjiCard = 3.4
sgs.ai_use_priority.XunjiCard = 3.8

sgs.ai_skill_invoke.fanyin = function(self,data)
    return true
end

sgs.ai_skill_use["@@fanyin"] = function(self,prompt)
    local c = sgs.Sanguosha:getCard(self.player:getMark("fanyin_id-PlayClear")-1)
	c:setFlags("fanyin_use_card")
    local dummy = self:aiUseCard(c)
   	if dummy.card
   	and dummy.to
   	then
		if c:canRecast()
		and dummy.to:length()<1
		then return end
      	local tos = {}
       	for _,p in sgs.list(dummy.to)do
       		table.insert(tos,p:objectName())
       	end
       	return c:toString().."->"..table.concat(tos,"+")
    end
end

sgs.ai_skill_invoke.fanyin_targetfixed = function(self,data)
    local c = sgs.Sanguosha:getCard(self.player:getMark("fanyin_id-PlayClear")-1)
	c:setFlags("fanyin_use_card")
    local dummy = self:aiUseCard(c)
    return dummy.card and dummy.to
end

sgs.ai_skill_playerschosen.fanyin = function(self,players,x,n)
	if sgs.lastevent==sgs.PreCardUsed
	then
		local tos = {}
		self.player:setTag("yb_zhuzhan2_data",sgs.lasteventdata)
		while true do
			local to = sgs.ai_skill_playerchosen.yb_zhuzhan2(self,players)
			if to and #tos<x
			then
				table.insert(tos,to)
				players:removeOne(to)
			else break end
		end
		return tos
	end
end

sgs.ai_skill_invoke.peiqi = function(self,data)
	self.peiqiData = {}
	for ejs,ep in sgs.list(self.friends)do
		if self:canDisCard(ep,"ej")
		then
			self.peiqiData.from = ep
			ejs = ep:getCards("ej")
			ejs = self:sortByKeepValue(ejs)
			for i,ej in sgs.list(ejs)do
				i = ej:getEffectiveId()
				if self:canDisCard(ep,i)
				then
					self.peiqiData.cid = i
					for n,fp in sgs.list(self.enemies)do
						self.peiqiData.to = fp
						if ej:getTypeId()==3
						then
							n = ej:getRealCard():toEquipCard():location()
							if not fp:getEquip(n) and fp:hasEquipArea(n)
							then return true end
						else
							if self.player:canUse(ej,fp,true)
							then return true end
						end
					end
				end
			end
		end
	end
	for ejs,ep in sgs.list(self.enemies)do
		if self:canDisCard(ep,"ej")
		then
			self.peiqiData.from = ep
			ejs = ep:getCards("ej")
			ejs = self:sortByKeepValue(ejs,true)
			for i,ej in sgs.list(ejs)do
				i = ej:getEffectiveId()
				if self:canDisCard(ep,i)
				then
					self.peiqiData.cid = i
					for n,fp in sgs.list(self.friends)do
						self.peiqiData.to = fp
						if ej:getTypeId()==3
						then
							n = ej:getRealCard():toEquipCard():location()
							if not fp:getEquip(n) and fp:hasEquipArea(n)
							then return true end
						else
							if self.player:canUse(ej,fp,true)
							then return true end
						end
					end
				end
			end
		end
	end
	for ejs,ep in sgs.list(self.room:getOtherPlayers(self.player))do
		if self:canDisCard(ep,"ej")
		and not self:isFriend(ep)
		then
			self.peiqiData.from = ep
			ejs = ep:getCards("ej")
			ejs = self:sortByKeepValue(ejs,true)
			for i,ej in sgs.list(ejs)do
				i = ej:getEffectiveId()
				if self:canDisCard(ep,i)
				then
					self.peiqiData.cid = i
					for n,fp in sgs.list(self.friends)do
						self.peiqiData.to = fp
						if ej:getTypeId()==3
						then
							n = ej:getRealCard():toEquipCard():location()
							if not fp:getEquip(n) and fp:hasEquipArea(n)
							then return true end
						else
							if not fp:containsTrick(ej:objectName())
							and self.player:canUse(ej,fp,true)
							then return true end
						end
					end
				end
			end
		end
	end
end

sgs.ai_skill_playerchosen["peiqi_from"] = function(self,players)
	for _,target in sgs.list(players)do
		if target:objectName()==self.peiqiData.from:objectName()
		then return target end
	end
end

sgs.ai_skill_playerchosen["peiqi_to"] = function(self,players)
	for _,target in sgs.list(players)do
		if target:objectName()==self.peiqiData.to:objectName()
		then return target end
	end
end

sgs.ai_skill_cardchosen.peiqi = function(self,who,flags,method)
	for i,e in sgs.list(who:getCards(flags))do
		i = e:getEffectiveId()
		if i==self.peiqiData.cid
		then return i end
	end
end

sgs.ai_can_damagehp.peiqi = function(self,from,card,to)
	return to:getHp()+self:getAllPeachNum()-self:ajustDamage(from,to,1,card)>0
	and self:canLoseHp(from,card,to)
	and sgs.ai_skill_invoke.peiqi(self)
end

sgs.ai_skill_playerchosen.xiaoxinf = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
	for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and self:canDisCard(target,"e")
		then return target end
	end
	for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and self:canDisCard(target,"he")
		then return target end
	end
	for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		and self:canDisCard(target,"he")
		then return target end
	end
end

sgs.ai_skill_choice.xiaoxinf = function(self,choices)
	local items = choices:split("+")
	for _,to in sgs.list(self.enemies)do
		if self.player:getLostHp()>1
		and self.player:inMyAttackRange(to)
		and table.contains(items,"lose=2")
		then return "lose=2" end
	end
	for dc,item in sgs.list(items)do
		if item:startsWith("slash")
		then
			dc = dummyCard()
			dc:setSkillName("xiaoxinf")
			dc = self:aiUseCard(dc)
			if dc.card and dc.to
			then
				for _,to in sgs.list(dc.to)do
					self.xiaoxinf_to = to
					if self.player:inMyAttackRange(to)
					then return item end
				end
			end
		end
	end
	return items[1]
end

sgs.ai_skill_playerchosen["xiaoxinf_slash"] = function(self,players)
	for _,target in sgs.list(players)do
		if target:objectName()==self.xiaoxinf_to:objectName()
		then return target end
	end
end

sgs.ai_skill_invoke.xiongrao = function(self,data)
    return self.player:getMaxHp()<3
end

sgs.ai_skill_invoke.diting = function(self,data)
	local target = data:toPlayer()
	if target
	then
		self.diting_to = target
		return not self:isFriend(target)
		or target:getHandcardNum()>1
	end
end

sgs.ai_skill_askforag.diting = function(self,ids)
	local cs = getCardList(ids)
	cs = self:sortByUseValue(cs,self:isEnemy(self.diting_to))
	for _,c in sgs.list(cs)do
		if c:isDamageCard()
		then
			return c:getEffectiveId()
		end
	end
	return cs[1]:getEffectiveId()
end
--[[
sgs.ai_target_revises.diting = function(to,card,self)
    if self.player:getMark("diting_show_"..card:getEffectiveId().."_"..to:objectName().."-PlayClear")>0
	and self:isFriend(to)
	then return true end
end
--]]
sgs.ai_skill_playerchosen.bihuof = function(self,players)
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

sgs.ai_skill_playerchosen.bihuof2 = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp",true)
	for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		then return target end
	end
	for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		then return target end
	end
end

sgs.ai_skill_invoke.kanpodz = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isFriend(target)
	end
end

addAiSkills("kanpodz").getTurnUseCard = function(self)
	local cards = self:addHandPile()
	cards = self:sortByKeepValue(cards,nil,true)
  	for _,c in sgs.list(cards)do
		if self:getCardsNum("Slash")>0
		then break end
		d = dummyCard()
		d:addSubcard(c)
		d:setSkillName("kanpodz")
		local parse = self:aiUseCard(d)
		if d:isAvailable(self.player)
		and parse.card and parse.to
		then return d end
	end
end

sgs.ai_guhuo_card.kanpodz = function(self,toname,class_name)
    local cards = self:addHandPile()
    cards = self:sortByKeepValue(cards,nil,true) -- 按保留值排序
   	for d,c in sgs.list(cards)do
       	if class_name=="Slash"and self:getCardsNum(class_name)<1
		and sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
		and self.player:getMark("kanpodz_used-Clear")<1
      	then
           	d = dummyCard()
			d:addSubcard(c)
			d:setSkillName("kanpodz")
			return d:toString()
       	end
   	end
end

sgs.ai_skill_invoke.gengzhan = function(self,data)
    return true
end

addAiSkills("midu").getTurnUseCard = function(self)
	local parse = sgs.Card_Parse("@MiduCard=.")
	assert(parse)
	return parse
end

sgs.ai_skill_use_func["MiduCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.MiduCard = 3.4
sgs.ai_use_priority.MiduCard = 6.8

sgs.ai_skill_playerchosen.midu = function(self,players)
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

sgs.ai_skill_playerschosen.yingyu = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
	local tos = {}
	for _,target in sgs.list(destlist)do
		if #tos>0 then break end
		if self:isFriend(target)
		then table.insert(tos,target) end
	end
	for _,target in sgs.list(destlist)do
		if #tos>0 then break end
		if not self:isEnemy(target)
		then table.insert(tos,target) end
	end
	for _,target in sgs.list(destlist)do
		if #tos>1 then break end
		if self:isEnemy(target)
		then table.insert(tos,target) end
	end
	for _,target in sgs.list(destlist)do
		if #tos>0 then break end
		if not self:isFriend(target)
		then table.insert(tos,target) end
	end
	return #tos>1 and tos or {}
end

sgs.ai_skill_playerchosen.yingyu = function(self,players)
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

addAiSkills("yongbi").getTurnUseCard = function(self)
	local cards = self.player:getCards("h")
	cards = self:sortByKeepValue(cards,nil,true)
	local suits = {}
  	for s,c in sgs.list(cards)do
		s = c:getSuit()
		if table.contains(suits,s)
		then continue end
		table.insert(suits,s)
	end
	return #suits>2 and sgs.Card_Parse("@YongbiCard=.")
end

sgs.ai_skill_use_func["YongbiCard"] = function(card,use,self)
	self:sort(self.friends,"hp",true)
	for _,fp in sgs.list(self.friends)do
		if fp:isMale()
		then
			use.card = card
			if use.to then use.to:append(fp) end
			return
		end
	end
end

sgs.ai_use_value.YongbiCard = 3.4
sgs.ai_use_priority.YongbiCard = 0.8

sgs.ai_skill_cardask["@fenrui"] = function(self,data)
    return self.player:getCardCount()>2
end

sgs.ai_skill_playerchosen.fenrui = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
	for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and self.player:getEquips():length()-target:getEquips():length()>=target:getHp()
		then return target end
	end
end

sgs.ai_skill_invoke.tenyeartujue = function(self,data)
    return self:getCardsNum("Peach")+self:getCardsNum("Analeptic")<1
end

addAiSkills("tenyearquanjian").getTurnUseCard = function(self)
	local parse = sgs.Card_Parse("@TenyearQuanjianCard=.")
	assert(parse)
	return parse
end

sgs.ai_skill_use_func["TenyearQuanjianCard"] = function(card,use,self)
	if self.player:getMark("tenyearquanjian_tiansuan_remove_card-PlayClear")<1
	then
		self:sort(self.enemies,"handcard",true)
		for _,ep in sgs.list(self.enemies)do
			if ep:getHandcardNum()>ep:getMaxCards()
			then
				use.card = sgs.Card_Parse("@TenyearQuanjianCard=.:card")
				if use.to then use.to:append(ep) end
				return
			end
		end
		self:sort(self.friends_noself,"handcard")
		for _,fp in sgs.list(self.friends_noself)do
			if fp:getHandcardNum()<fp:getMaxCards()
			then
				use.card = sgs.Card_Parse("@TenyearQuanjianCard=.:card")
				if use.to then use.to:append(fp) end
				return
			end
		end
	end
	if self.player:getMark("tenyearquanjian_tiansuan_remove_damage-PlayClear")<1
	then
		self:sort(self.enemies,"hp")
		for _,ep in sgs.list(self.enemies)do
			for _,fp in sgs.list(self.friends_noself)do
				if fp:inMyAttackRange(ep)
				and ep:getMark("&tenyearquanjian_debuff-Clear")>0
				then
					use.card = sgs.Card_Parse("@TenyearQuanjianCard=.:damage")
					if use.to
					then
						use.to:append(fp)
						use.to:append(ep)
					end
					return
				end
			end
			for _,fp in sgs.list(self.room:getOtherPlayers(self.player))do
				if fp:inMyAttackRange(ep)
				and ep:getMark("&tenyearquanjian_debuff-Clear")>0
				and self:isEnemy(fp)
				then
					use.card = sgs.Card_Parse("@TenyearQuanjianCard=.:damage")
					if use.to
					then
						use.to:append(fp)
						use.to:append(ep)
					end
					return
				end
			end
		end
		for _,ep in sgs.list(self.enemies)do
			for _,fp in sgs.list(self.friends_noself)do
				if fp:inMyAttackRange(ep)
				then
					use.card = sgs.Card_Parse("@TenyearQuanjianCard=.:damage")
					if use.to
					then
						use.to:append(fp)
						use.to:append(ep)
					end
					return
				end
			end
			for _,fp in sgs.list(self.room:getOtherPlayers(self.player))do
				if fp:inMyAttackRange(ep)
				and self:isEnemy(fp)
				then
					use.card = sgs.Card_Parse("@TenyearQuanjianCard=.:damage")
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
end

sgs.ai_use_value.TenyearQuanjianCard = 3.4
sgs.ai_use_priority.TenyearQuanjianCard = 8.8

sgs.ai_skill_invoke.tenyearquanjian = function(self,data)
	local invoke = data:toString():split("+")
	if invoke[1]=="dodamage"
	then
		invoke = BeMan(self.room,invoke[2])
		if invoke
		then
			return not self:isFriend(invoke)
			or not self:isWeak(invoke)
		end
	end
    return true
end

sgs.ai_skill_discard.tenyearquanjian = function(self,max,min)
	local to_cards = {}
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
   	for _,hcard in sgs.list(cards)do
   		if #to_cards>=min or min>2 then break end
		table.insert(to_cards,hcard:getEffectiveId())
	end
	return to_cards
end

sgs.ai_skill_invoke.suoliang = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isFriend(target)
	end
end

sgs.ai_skill_invoke.chongyi = function(self,data)
	local invoke = data:toString():split("+")
	if #invoke>1
	then
		invoke = BeMan(self.room,invoke[2])
		if invoke
		then
			return self:isFriend(invoke)
			or self:isWeak(invoke) and not self:isEnemy(invoke)
		end
	end
end

sgs.ai_skill_invoke.yingtu = function(self,data)
	local target = data:toPlayer()
	if target
	then
		local to = self.player:getNextAlive()
		if to==target
		then
			to = self.player:getNextAlive(self.player:getAliveSiblings():length())
		end
		if not self:isFriend(target)
		and not self:isEnemy(to)
		then return true end
		if self:canDisCard(target,"e")
		then return true end
		if self:isFriend(target)
		and self:isFriend(to)
		then return true end
		if not self:isFriend(target)
		and not self:isFriend(to)
		then return true end
	end
end

sgs.ai_skill_cardask["@tenyearpoyuan-discard"] = function(self,data,pattern)
    return self.player:getCardCount()>1
end

sgs.ai_skill_playerchosen.tenyearpoyuan = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
	for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and self:canDisCard(target,"e")
		then return target end
	end
	for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and self:canDisCard(target,"e")
		then return target end
	end
	for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		and self:canDisCard(target,"e")
		then return target end
	end
end

sgs.ai_skill_cardchosen.tenyearpoyuan = function(self,who,flags,method)
	if self:canDisCard(who,flags)
	then
		for i,c in sgs.list(who:getCards(flags))do
			i = c:getEffectiveId()
			if self:canDisCard(who,i)
			then return i end
		end
	end
	return -1
end

addAiSkills("tenyearhuace").getTurnUseCard = function(self)
	local cards = self.player:getCards("h")
	cards = self:sortByKeepValue(cards,nil,true)
	for d,pn in sgs.list(patterns)do
		if self.player:getMark("tenyearhuace_guhuo_remove_"..pn)>0
		or #cards<1 then continue end
		d = PatternsCard(pn)
		if d and d:isNDTrick()
		and d:isDamageCard()
		then
			d = dummyCard(pn)
			d:addSubcard(cards[1])
			d:setSkillName("tenyearhuace")
			local parse = self:aiUseCard(d)
			if d:isAvailable(self.player) and parse.card and parse.to
			and self:getCardsNum(d:getClassName())<1
			then
				if d:canRecast()
				and parse.to:length()<1
				then return end
				self.tenyearhuace_to = parse.to
				sgs.ai_use_priority.TenyearHuaceCard = sgs.ai_use_priority[d:getClassName()]-0.3
				return sgs.Card_Parse("@TenyearHuaceCard="..cards[1]:getEffectiveId()..":"..pn)
			end
		end
	end
	for d,pn in sgs.list(patterns)do
		if self.player:getMark("tenyearhuace_guhuo_remove_"..pn)>0
		or #cards<1 then continue end
		d = PatternsCard(pn)
		if d and d:isNDTrick()
		then
			d = dummyCard(pn)
			d:addSubcard(cards[1])
			d:setSkillName("tenyearhuace")
			local parse = self:aiUseCard(d)
			if d:isAvailable(self.player) and parse.card and parse.to
			and self:getCardsNum(d:getClassName())<1
			then
				if d:canRecast()
				and parse.to:length()<1
				then return end
				self.tenyearhuace_to = parse.to
				sgs.ai_use_priority.TenyearHuaceCard = sgs.ai_use_priority[d:getClassName()]-0.3
				return sgs.Card_Parse("@TenyearHuaceCard="..cards[1]:getEffectiveId()..":"..pn)
			end
		end
	end
end

sgs.ai_skill_use_func["TenyearHuaceCard"] = function(card,use,self)
	if self.tenyearhuace_to
	then
		use.card = card
		if use.to then use.to = self.tenyearhuace_to end
	end
end

sgs.ai_use_value.TenyearHuaceCard = 5.4
sgs.ai_use_priority.TenyearHuaceCard = 4.8

sgs.ai_skill_invoke.ruizhan = function(self,data)
	local target = data:toPlayer()
	if target
	then
		local mc = self:getMaxCard()
		return mc and mc:getNumber()>10
		and (self:isEnemy(target) or not (self:isFriend(target) or self:isWeak(target)))
	end
end

addAiSkills("shilie").getTurnUseCard = function(self)
	return sgs.Card_Parse("@ShilieCard=.")
end

sgs.ai_skill_use_func["ShilieCard"] = function(card,use,self)
	local pile = self.player:getPile("shilie")
	if self:isWeak()
	then
		sgs.ai_skill_choice.shilie = "recover"
		if self.player:getCardCount()>self.player:getHp()
		or self.player:getCardCount()<1
		then use.card = card return end
	elseif pile:length()>1
	then
		sgs.ai_skill_choice.shilie = "lose"
		self.shilie_n = sgs.IntList()
		for d,c in sgs.list(getCardList(pile))do
			if c:isAvailable(self.player)
			then
				d = self:aiUseCard(c)
				if d.card and d.to
				then self.shilie_n:append(c:getEffectiveId()) end
			end
		end
		if self.shilie_n:length()>1
		then use.card = card return end
	end
	if self.player:isWounded()
	and self.player:getCardCount()>self.player:getHp()*(math.random()+1)
	then
		sgs.ai_skill_choice.shilie = "recover"
		use.card = card
	end
end

sgs.ai_use_value.ShilieCard = 3.4
sgs.ai_use_priority.ShilieCard = 5.8

sgs.ai_skill_use["@@shilie!"] = function(self,prompt)
	local n2 = {}
	for i,id in sgs.list(self.player:getPile("shilie"))do
		if self.shilie_n:contains(id) then table.insert(n2,id) end
	end
	return #n2>0 and ("@ShilieGetCard="..table.concat(n2,"+"))
end

sgs.ai_skill_playerchosen.shilie = function(self,players)
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

addAiSkills("qiaoli").getTurnUseCard = function(self)
	local cards = self:addHandPile("he")
	cards = self:sortByKeepValue(cards,nil,true)
  	for _,c in sgs.list(cards)do
		if c:getTypeId()~=3
		or self:getCardsNum("Duel")>0
		or (self.player:getMark("qiaoliWeapon-PlayClear")>0 and c:isKindOf("Weapon")
		or self.player:getMark("qiaoliEquip-PlayClear")>0 and not c:isKindOf("Weapon"))
		then continue end
		d = dummyCard("duel")
		d:addSubcard(c)
		d:setSkillName("qiaoli")
		local parse = self:aiUseCard(d)
		if d:isAvailable(self.player)
		and parse.card and parse.to
		then
			if d:canRecast()
			and parse.to:length()<1
			then continue end
			return d
		end
	end
end

sgs.ai_skill_invoke.qingliang = function(self,data)
	return self:getCardsNum("Jink")>0
	or self:isWeak()
end

sgs.ai_skill_choice.qingliang = function(self,choices)
	local items = choices:split("+")
	local cards = self.player:getCards("h")
	cards = self:sortByKeepValue(cards,nil,true)
	local suits = {}
  	for s,c in sgs.list(cards)do
		s = c:getSuitString()
		if suits[s] then suits[s] = suits[s]+1
		else suits[s] = 1 end
	end
	local function func(a,b)
		return a<b
	end
	table.sort(suits,func)
   	local target = self.room:getCurrent()
	if self:getCardsNum("Jink")>0
	and not self:isEnemy(target)
	then return items[1] end
  	for s,c in sgs.list(cards)do
		s = c:getSuitString()
		if suits[1]==suits[s]
		then
			return "discard="..s
		end
	end
end

sgs.ai_skill_choice.chongwang = function(self,choices)
	local items = choices:split("+")
	if items
	then
		local to = items[1]:split("=")[2]
		to = BeMan(self.room,to)
		if to and self:isEnemy(to)
		then return items[2] end
		if to and self:isFriend(to)
		then return items[1] end
	end
	return items[#items]
end

sgs.ai_skill_playerschosen.huagui = function(self,players,x,n)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard",true)
	local tos = {}
	for _,target in sgs.list(destlist)do
		if #tos>=x then break end
		if self:isFriend(target)
		then table.insert(tos,target) end
	end
	for _,target in sgs.list(destlist)do
		if #tos>=x then break end
		if self:isEnemy(target)
		then table.insert(tos,target) end
	end
	for _,target in sgs.list(destlist)do
		if #tos>=x then break end
		if not table.contains(tos,target)
		then table.insert(tos,target) end
	end
	return tos
end

sgs.ai_skill_choice.huagui = function(self,choices,data)
	local target = data:toPlayer()
	local items = choices:split("+")
	if self:isFriend(target)
	and math.random()<0.4
	then return items[1] end
	if not self:isEnemy(target)
	and math.random()<0.3
	then return items[1] end
	return items[2]
end

sgs.ai_skill_invoke.jingjian = function(self,data)
	local target = data:toString()
	target = target:split(":")[2]
	target = BeMan(self.room,target)
	if target
	then
		local mc = self:getMaxCard()
		return mc and mc:getNumber()>math.random(8,11)
		and (self:isEnemy(target) or not (self:isFriend(target) or self:isWeak(target)))
	end
end

sgs.ai_skill_choice.zhenze = function(self,choices)
	local items = choices:split("+")
	local function canZhenze(to)
		if to:getHandcardNum()>to:getHp()
		then return 1
		elseif to:getHandcardNum()==to:getHp()
		then return 0 end
		return -1
	end
	local n,x = canZhenze(self.player),0
	for _,target in sgs.list(self.room:getAllPlayers())do
		if n~=canZhenze(target)
		and not self:isFriend(target)
		then x = x+1 end
		if n==canZhenze(target)
		and not self:isEnemy(target)
		and target:isWounded()
		then x = x-1 end
	end
	if x>0 then return "lose" end
	if x<0 then return "recover" end
	return items[#items]
end

addAiSkills("anliao").getTurnUseCard = function(self)
	return sgs.Card_Parse("@AnliaoCard=.")
end

sgs.ai_skill_use_func["AnliaoCard"] = function(card,use,self)
	for _,fp in sgs.list(self.friends)do
		if self:canDisCard(fp,"e")
		then
			use.card = card
			if use.to then use.to:append(fp) end
			return
		end
	end
	for _,ep in sgs.list(self.enemies)do
		if ep:getHandcardNum()==1
		and ep:getMark("anliao_to-PlayClear")<1
		then
			use.card = card
			if use.to then use.to:append(ep) end
			ep:addMark("anliao_to-PlayClear")
			return
		end
	end
	for _,ep in sgs.list(self.enemies)do
		if self:canDisCard(ep,"he")
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	for _,c in sgs.list(self.player:getCards("he"))do
		if self:getKeepValue(c)<4
		or self.player:getCardCount()>3
		then
			use.card = card
			if use.to then use.to:append(self.player) end
			return
		end
	end
end

sgs.ai_use_value.AnliaoCard = 3.4
sgs.ai_use_priority.AnliaoCard = 5.8

sgs.ai_skill_invoke.xieshou = function(self,data)
	local target = data:toPlayer()
	return target and self:isFriend(target)
end

sgs.ai_skill_choice.xieshou = function(self,choices)
	if self:isWeak() then return "recover" end
	local items = choices:split("+")
	return items[#items]
end

sgs.ai_skill_invoke.qingyan = function(self,data)
	return true
end

sgs.ai_skill_cardask["@qingyan"] = function(self,data)
    return self.player:getHandcardNum()>self.player:getMaxCards()
end





















