

function SmartAI:useCardQizhengxiangsheng(card,use)
	self:sort(self.enemies,"hp")
	local extraTarget = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
	if use.extra_target then extraTarget = extraTarget+use.extra_target end
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if use.to and CanToCard(card,self.player,ep,use.to)
		and self:ajustDamage(self.player,ep,1,card)~=0
		then
	    	use.card = card
			use.to:append(ep)
	    	if use.to:length()>extraTarget
			then return end
		end
	end
end
sgs.ai_use_priority.Qizhengxiangsheng = 3.4
sgs.ai_keep_value.Qizhengxiangsheng = 4
sgs.ai_use_value.Qizhengxiangsheng = 3.7
sgs.ai_card_intention.Qizhengxiangsheng = 22

sgs.ai_nullification.Qizhengxiangsheng = function(self,trick,from,to,positive)
    if positive
	then
		return self:isFriend(to)
		and self:isWeak(to)
	else
		return self:isEnemy(to)
		and self:isWeak(to)
	end
end

sgs.ai_skill_choice._qizhengxiangsheng = function(self,choices,data)
	local items = choices:split("+")
	local target = data:toPlayer()
	if target:getHandcardNum()<3 and math.random()>0.4
	or target:isKongcheng()
	then return items[2] end
	if math.random()<0.4
	then return items[1] end
end

sgs.ai_skill_invoke.zhiren = function(self,data)
    return true
end

sgs.ai_skill_playerchosen.zhiren = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"equip")
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

sgs.ai_skill_playerchosen.zhiren_judge = function(self,players)
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

sgs.ai_skill_invoke.yaner = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isEnemy(target)
	end
end

sgs.ai_skill_invoke.quedi = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return self:isEnemy(target)
	end
end

sgs.ai_skill_choice.quedi = function(self,choices,data)
	local items = choices:split("+")
	local use = data:toCardUse()
	if use.to:at(0):getHandcardNum()>1
	then return items[1] end
	if use.to:at(0):getHandcardNum()<2
	then return items[2] end
end

--[[addAiSkills("chuifeng").getTurnUseCard = function(self)
	--添加限制
	if ((self.player:getMark("usetimeschuifeng-PlayClear") < 2)
	and (self.player:getMark("banchuifeng-Clear") == 0)) then
	--以上
		for d,cn in sgs.list(patterns)do
			local fs = dummyCard(cn)
			if fs and self.player:getKingdom()=="wei"
			and fs:isKindOf("Duel")
			and fs:isAvailable(self.player)
			and not self:isWeak()
			then
				fs:setSkillName("chuifeng")
				d = self:aiUseCard(fs)
				sgs.ai_use_priority.chuifeng = sgs.ai_use_priority[fs:getClassName()]
				self.cf_to = d.to
				if d.card and d.to then
					return sgs.Card_Parse("#chuifeng:.:"..cn) 
				end
			end	
		end
	end
end

sgs.ai_skill_use_func["#chuifeng"] = function(card,use,self)
	use.card = card
	if use.to then use.to = self.cf_to end
end

sgs.ai_use_value.chuifeng = 5.4
sgs.ai_use_priority.chuifeng = 2.8]]

--[[sgs.ai_guhuo_card.chuifeng = function(self,toname,class_name)
	if (class_name=="Slash" or class_name=="Duel")
	and self.player:getKingdom()=="wei"
	and sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
	then return "#chuifeng:.:"..toname end
end]]


--[[addAiSkills("chongjian").getTurnUseCard = function(self)
	local cards = self:addHandPile("he")
	cards = self:sortByKeepValue(cards,nil,true)
	local toids = {}
  	for _,c in sgs.list(cards)do
		if c:isKindOf("EquipCard")
		then table.insert(toids,c) end
	end
	for d,cn in sgs.list(patterns)do
	   	local fs = dummyCard(cn)
		if fs and self.player:getKingdom()=="wu"
		and (fs:isKindOf("Slash") or fs:isKindOf("Analeptic"))
		and #toids>0
		then
			fs:setSkillName("chuifeng")
			fs:addSubcard(toids[1])
			d = self:aiUseCard(fs)
			if fs:isAvailable(self.player)
			and d.card and d.to
			then return fs end
		end
	end
end]]

--[[sgs.ai_guhuo_card.chongjian = function(self,toname,class_name)
	local cards = self:addHandPile("he")
	cards = self:sortByKeepValue(cards,nil,true)
	local toids = {}
  	for _,c in sgs.list(cards)do
		if c:isKindOf("EquipCard")
		then table.insert(toids,c:getEffectiveId()) end
	end
	if #toids>0
	and self.player:getKingdom()=="wu"
	and (class_name=="Slash" or class_name=="Analeptic")
	and sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
	then return "#chongjian:"..toids[1]..":"..toname end
end]]


sgs.ai_skill_invoke.xiuhao = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isEnemy(target) or self:isWeak()
	end
end

sgs.ai_skill_playerchosen.sujian = function(self,players)
	players = self:sort(players,"card",true)
    for _,target in sgs.list(players)do
		if self:isEnemy(target)
		then return target end
	end
    for _,target in sgs.list(players)do
		if not self:isFriend(target)
		then return target end
	end
	return players[1]
end

sgs.ai_skill_askforyiji.sujian = function(self,card_ids)
    return sgs.ai_skill_askforyiji.nosyiji(self,card_ids)
end

addAiSkills("olfuman").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	for _,ep in sgs.list(self.friends_noself)do
		if ep:getMark("olfuman_target-PlayClear")<1
		and #cards>=self.player:getMaxCards()
		then
			return sgs.Card_Parse("#olfuman:"..cards[1]:getEffectiveId()..":")
		end
	end
	for _,ep in sgs.list(self.room:getOtherPlayers(self.player))do
		if ep:getMark("olfuman_target-PlayClear")<1
		and #cards>self.player:getMaxCards()
		and not self:isEnemy(ep)
		then
			return sgs.Card_Parse("#olfuman:"..cards[1]:getEffectiveId()..":")
		end
	end
end

sgs.ai_skill_use_func["#olfuman"] = function(card,use,self)
	self:sort(self.friends_noself,"hp")
	for _,ep in sgs.list(self.friends_noself)do
		if ep:getMark("olfuman_target-PlayClear")<1
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	for _,ep in sgs.list(self.room:getOtherPlayers(self.player))do
		if ep:getMark("olfuman_target-PlayClear")<1
		and self.player:getHandcardNum()>self.player:getMaxCards()
		and not self:isEnemy(ep)
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.olfuman = 9.4
sgs.ai_use_priority.olfuman = 4.8

sgs.ai_skill_playerchosen.xianwei = function(self,players)
	players = self:sort(players,"hp")
    for _,target in sgs.list(players)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(players)do
		if not self:isEnemy(target)
		then return target end
	end
	return players[1]
end

sgs.ai_skill_discard.zhiming = function(self)
	local cards = {}
	local js = self.player:getCards("j")
	if js:length()>0
	and self.player:getPhase()==sgs.Player_Start
	then
		local handcards = self.player:getCards("he")
		handcards = self:sortByKeepValue(handcards) -- 按保留值排序
		local jt = sgs.ai_judgestring[js:last():objectName()]
		if type(jt)~="table"
		then
			if type(jt)=="string"
			then
				jt = {jt,true}
			else
				jt = {jc:getSuitString(),true}
			end
		end
		if jt
		then
			for _,h in sgs.list(handcards)do
				if sgs.Sanguosha:matchExpPattern(jt[1],self.player,h)==jt[2]
				then table.insert(cards,h:getEffectiveId()) end
				if #cards>0 then return cards end
			end
		end
	end
	js = self:poisonCards("he")
	if self.player:getPhase()~=sgs.Player_Start
	and #js>0
	then
		table.insert(cards,js[1]:getEffectiveId())
	end
	return cards
end

sgs.ai_skill_cardask["@zhiming-put"] = function(self,data,pattern)
	local target = self.room:getCurrent()
    local cards = sgs.ai_skill_discard.zhiming(self)
    return #cards>0 and cards[1] or "."
end

sgs.ai_skill_playerchosen.xingbu_xbwuxinglianzhu = function(self,players)
	players = self:sort(players,"handcard",true)
    for _,target in sgs.list(players)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(players)do
		if not self:isEnemy(target)
		then return target end
	end
	return players[1]
end

sgs.ai_skill_playerchosen.xingbu_xbfukuangdongzhu = function(self,players)
	players = self:sort(players,"hp")
    for _,target in sgs.list(players)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(players)do
		if not self:isEnemy(target)
		then return target end
	end
	return players[1]
end

sgs.ai_skill_playerchosen.xingbu_xbyinghuoshouxin = function(self,players)
	players = self:sort(players,"handcard",true)
    for _,target in sgs.list(players)do
		if self:isEnemy(target)
		then return target end
	end
    for _,target in sgs.list(players)do
		if not self:isFriend(target)
		then return target end
	end
	return players[1]
end

sgs.ai_skill_invoke.olhaoshi = function(self,data)
	local al = self.player:getAliveSiblings()
	local n,can = 998,false
    for _,target in sgs.list(al)do
		n = math.min(n,target:getHandcardNum())
	end
    for _,target in sgs.list(al)do
		if target:getHandcardNum()<=n
		and not self:isEnemy(target)
		then can = true end
	end
    return self.player:getHandcardNum()+2<=5 or can
end

sgs.ai_skill_cardask["@olhaoshi-give"] = function(self,data,pattern,to)
	local use = data:toCardUse()
	if self:isFriend(to)
	and self:isWeak(to)
	then
		local cs
		if use.card:isKindOf("Slash")
		or use.card:isKindOf("ArcheryAttack")
		then cs = self:getCards("Jink") end
		if use.card:isKindOf("Duel")
		or use.card:isKindOf("SavageAssault")
		then cs = self:getCards("Slash") end
		if cs then return cs[1]:getEffectiveId() end
	end
	return "."
end

addAiSkills("oldimeng").getTurnUseCard = function(self)
	if self.player:hasUsed("oldimeng") then return end
	return sgs.Card_Parse("#oldimeng:.:")
end

sgs.ai_skill_use_func["#oldimeng"] = function(card,use,self)
	if not self.player:hasUsed("#oldimeng") then
		self:sort(self.enemies,"handcard",true)
		self:sort(self.friends_noself,"handcard")
		for _,ep in sgs.list(self.enemies)do
			for _,fp in sgs.list(self.friends_noself)do
				if ep:getHandcardNum()>fp:getHandcardNum()
				then
					use.card = card
					if use.to
					then
						use.to:append(ep)
						use.to:append(fp)
					end
					return
				end
			end
		end
	end
end

sgs.ai_use_value.oldimeng = 9.4
sgs.ai_use_priority.oldimeng = 5.8

sgs.ai_skill_playerchosen.secondwenji = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card",true)
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		then return target end
	end
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		then return target end
	end
	self:sort(destlist,"card",true)
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
	return destlist[1]
end

sgs.ai_skill_playerchosen.secondkangge = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card",true)
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		then return target end
	end
	self:sort(destlist,"card",true)
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		then return target end
	end
	return destlist[1]
end

sgs.ai_skill_playerchosen.fengjie = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp",true)
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		then return target end
	end
	return destlist[1]
end

sgs.ai_skill_invoke.secondkangge = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isEnemy(target)
	end
end

sgs.ai_skill_invoke.secondjielie = function(self,data)
    return true
end

sgs.ai_skill_invoke.yise = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return self:isFriend(target)
	end
end

sgs.ai_skill_askforyiji.shunshi = function(self,card_ids)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	local tos = self.room:getOtherPlayers(self.player)
	tos = self:sort(tos,"hp")
	for _,p in sgs.list(tos)do
	   	if p:hasFlag("shunshi")
		then
			if cards[1]:isRed() and self:isFriend(p)
			or cards[1]:isBlack() and self:isEnemy(p)
			then return p,cards[1]:getEffectiveId() end
		end
	end
end

sgs.ai_skill_cardask["@fengzi-discard"] = function(self,data)
    local use = data:toCardUse()
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if h:getTypeId()==use.card:getTypeId()
    	then
			if use.card:isKindOf("Peach")
			and self.player:getLostHp()>1
			then return h:getEffectiveId()
			elseif use.card:isKindOf("Analeptic")
			and not(h:isKindOf("Slash") and table.contains(self.toUse,h))
			then return h:getEffectiveId()
			elseif use.to:contains(self.player)
			then return h:getEffectiveId()
			elseif use.card:isDamageCard()
			or use.card:isKindOf("SingleTargetTrick")
			then
				for _,to in sgs.list(use.to)do
					if self:isFriend(to)
					then return "." end
				end
				return h:getEffectiveId()
			end
		end
	end
    return "."
end

sgs.ai_skill_invoke.jizhanw = function(self,data)
    return true
end

sgs.ai_skill_choice.jizhanw = function(self,choices,data)
	local n = data:toInt()
	local items = choices:split("+")
	if n>6 then return items[2] end
	if n<7 then return items[1] end
	return items[2]
end


sgs.ai_skill_playerchosen.fusong = function(self,players)
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

sgs.ai_skill_invoke.qingjue = function(self,data)
	local use = data:toCardUse()
	if use.to
	and self:isFriend(use.to:at(0))
	then
		if self:isWeak(use.to:at(0))
		and use.card:isDamageCard()
		then return true
		else
			local cards = self.player:getCards("h")
			cards = sgs.QList2Table(cards) -- 将列表转换为表
			self:sortByKeepValue(cards) -- 按保留值排序
			for _,h in sgs.list(cards)do
				if h:getNumber()>9
				then return true end
			end
		end
	end
end

sgs.ai_skill_playerchosen.zhibian = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
		local cards = self.player:getCards("h")
		cards = sgs.QList2Table(cards) -- 将列表转换为表
		self:sortByKeepValue(cards) -- 按保留值排序
		for _,h in sgs.list(cards)do
			if h:getNumber()>9
			and self:isEnemy(target)
			then return target end
		end
	end
end

--[[sgs.ai_useto_revises.yuyan = function(self,card,use,p)
	if card:isKindOf("Slash")
	and not card:isVirtualCard()
	then
		sgs.ai_skill_defense.yuyan = 0
		local xc = self:getMaxCard(nil,self:getCards("he"))
		if xc and xc:getNumber()<=card:getNumber()
		then sgs.ai_skill_defense.yuyan = 4 end
	end
end]]

sgs.ai_skill_invoke.yilie = function(self,data)
    return true
end

addAiSkills("mobilefenming").getTurnUseCard = function(self)
	if self.player:hasUsed("mobilefenming") then return end
	return sgs.Card_Parse("#mobilefenming:.:")
end

sgs.ai_skill_use_func["#mobilefenming"] = function(card,use,self)
	if not self.player:hasUsed("#mobilefenming") then
		self:sort(self.enemies,"hp")
		for _,ep in sgs.list(self.enemies)do
			if ep:isChained() and ep:getCardCount()>1
			and ep:getHp()<=self.player:getHp()
			then
				use.card = card
				if use.to then use.to:append(ep) end
				return
			end
		end
		for _,ep in sgs.list(self.enemies)do
			if ep:getHp()>self.player:getHp() then continue end
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.mobilefenming = 3.4
sgs.ai_use_priority.mobilefenming = 4.8

addAiSkills("jinghe").getTurnUseCard = function(self)
	if self.player:hasUsed("jinghe") then return end
	local cards = sgs.QList2Table(self.player:getCards("h"))
    if #cards<1 then return end
	self:sortByKeepValue(cards)
	local toids,cs = {},{}
  	for _,c in sgs.list(cards)do
		if #toids>=#self.friends
		or cs[c:objectName()]
		then continue end
		cs[c:objectName()] = true
		table.insert(toids,c:getEffectiveId())
	end
	self.jh_n = #toids
	return #toids>0 and sgs.Card_Parse("#jinghe:"..table.concat(toids,"+")..":")
end

sgs.ai_skill_use_func["#jinghe"] = function(card,use,self)
	if not self.player:hasUsed("#jinghe") then
		self:sort(self.friends,"hp",true)
		for _,ep in sgs.list(self.friends)do
			use.card = card
			if use.to and use.to:length()<self.jh_n
			then use.to:append(ep) end
		end
	end
end

sgs.ai_use_value.jinghe = 9.4
sgs.ai_use_priority.jinghe = 6.8

sgs.ai_skill_invoke.gongxiu = function(self,data)
    return true
end


sgs.ai_skill_choice.gongxiu = function(self,choices)
	local items = choices:split("+")
	local draw,discard = 0,0
	for _,p in sgs.list(self.room:getAllPlayers())do
		if p:getMark("jinghe_GetSkill-Clear")>0
		then draw = draw+1
		elseif not p:isKongcheng()
		then discard = discard+1 end
	end
	if draw<discard
	then return "discard"
	else return "draw" end
end

--[[addAiSkills("nhhuoqi").getTurnUseCard = function(self)
	local cards = self.player:getCards("he")
	cards = self:sortByKeepValue(cards,nil,true)
	if #cards>0
	then
		if self.player:hasUsed("nhhuoqi") then return end
		return sgs.Card_Parse("#nhhuoqi:"..cards[1]:getEffectiveId()..":")
	end
end

sgs.ai_skill_use_func["#nhhuoqi"] = function(card,use,self)
	if not self.player:hasUsed("#nhhuoqi") then
		self:sort(self.friends,"hp")
		local tos = self.player:getAliveSiblings()
		tos = self:sort(tos,"hp")
		for _,ep in sgs.list(self.friends)do
			if ep:getHp()<=tos[1]:getHp()
			then
				use.card = card
				if use.to then use.to:append(ep) end
				return
			end
		end
	end
end

sgs.ai_use_value.nhhuoqi = 9.4
sgs.ai_use_priority.nhhuoqi = 4.8]]

sgs.ai_skill_invoke.nhguizhu = function(self,data)
    return true
end

addAiSkills("nhxianshou").getTurnUseCard = function(self)
	if self.player:hasUsed("nhxianshou") then return end
	return sgs.Card_Parse("#nhxianshou:.:")
end

sgs.ai_skill_use_func["#nhxianshou"] = function(card,use,self)
	if not self.player:hasUsed("#nhxianshou") then
		self:sort(self.friends,"hp")
		for _,ep in sgs.list(self.friends)do
			if not ep:isWounded()
			then
				use.card = card
				if use.to then use.to:append(ep) end
				return
			end
		end
		for _,ep in sgs.list(self.friends)do
			if ep:isWounded()
			then
				use.card = card
				if use.to then use.to:append(ep) end
				return
			end
		end
	end
end

sgs.ai_use_value.nhxianshou = 9.4
sgs.ai_use_priority.nhxianshou = 3.8

sgs.ai_skill_invoke.yise = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isFriend(target) and target:getHandcardNum()>self.player:getHandcardNum()
		or target:getHandcardNum()<self.player:getHandcardNum()
	end
end

sgs.ai_skill_invoke.nhguanyue = function(self,data)
    return true
end

sgs.ai_skill_cardask["@nhyanzheng-keep"] = function(self,data)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards,true) -- 按保留值排序
	local n = #cards-1
	if n>#self.enemies/2
	and n<#self.enemies*2
	then
		return cards[1]:getEffectiveId()
	end
    return "."
end

sgs.ai_skill_use["@@nhyanzheng"] = function(self,prompt)
	local valid = {}
	local destlist = self.player:getAliveSiblings()
    destlist = self:sort(destlist,"hp")
	local n = self.player:getMark("nhyanzheng-PlayClear")
	for _,friend in sgs.list(destlist)do
		if #valid>=n then break end
		if self:isEnemy(friend)
		then table.insert(valid,friend:objectName()) end
	end
	for _,friend in sgs.list(destlist)do
		if #valid>=n then break end
		if not self:isFriend(friend)
		and not table.contains(valid,friend:objectName())
		then table.insert(valid,friend:objectName()) end
	end
	if #valid>0
	then
    	return string.format("#nhyanzheng:.:->%s",table.concat(valid,"+"))
	end
end

--[[addAiSkills("nosjinwanyi").getTurnUseCard = function(self)
	local cards = self:addHandPile()
	cards = self:sortByKeepValue(cards,nil,true)
  	for _,c in sgs.list(cards)do
		local eg = sgs.Sanguosha:getEngineCard(c:getEffectiveId())
		if eg:property("YingBianEffects"):toString()=="" then continue end
		for d,cn in sgs.list({"zhujinqiyuan","chuqibuyi","drowning","dongzhuxianji"})do
			local tc = dummyCard(cn)
			if not tc or c:objectName()==cn then continue end
			tc:setSkillName("nosjinwanyi")
			tc:addSubcard(c)
			d = self:aiUseCard(tc)
			sgs.ai_use_priority.nosjinwanyi = sgs.ai_use_priority[tc:getClassName()]
			self.wy_to = d.to
			if d.card and d.to
			and tc:isAvailable(self.player)
			then return sgs.Card_Parse("#nosjinwanyi:"..c:getEffectiveId()..":"..cn) end
		end
	end
end

sgs.ai_skill_use_func["#nosjinwanyi"] = function(card,use,self)
	if self.wy_to
	then
		use.card = card
		if use.to then use.to = self.wy_to end
	end
end

sgs.ai_use_value.nosjinwanyi = 9.4
sgs.ai_use_priority.nosjinwanyi = 7.8]]


sgs.ai_skill_playerchosen.nosjinxuanbei = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card",true)
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		then return target end
	end
end



sgs.ai_skill_invoke.jinzhaosong = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isEnemy(target)
	end
end

sgs.ai_skill_invoke.jinzhaosong_lei = function(self,data)
    return true
end

sgs.ai_skill_playerchosen.jinzhaosong = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card",true)
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and self:doDisCard(target,"ej")
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and target:getCardCount()>0
		then return target end
	end
end

sgs.ai_skill_invoke.jinzhaosong_fu = function(self,data)
	local target = self.player:getTag("JinZhaosongDrawer"):toPlayer()
	if target then return not self:isEnemy(target) end
end

sgs.ai_skill_use["@@jinzhaosong"] = function(self,prompt)
	local valid = {}
	local destlist = self.player:getAliveSiblings()
    destlist = self:sort(destlist,"hp")
	for _,friend in sgs.list(destlist)do
		if #valid>1 then break end
		if self:isEnemy(friend)
		and friend:hasFlag("jinzhaosong_can_choose")
		then table.insert(valid,friend:objectName()) end
	end
	for _,friend in sgs.list(destlist)do
		if #valid>1 then break end
		if not self:isFriend(friend)
		and friend:hasFlag("jinzhaosong_can_choose")
		and not table.contains(valid,friend:objectName())
		then table.insert(valid,friend:objectName()) end
	end
	if #valid>0
	then
    	return string.format("#jinzhaosong:.:->%s",table.concat(valid,"+"))
	end
end


sgs.ai_skill_playerchosen.jinlisi = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card",true)
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		then return target end
	end
end


--[[addAiSkills("zuoxing").getTurnUseCard = function(self)
	for _,name in sgs.list(patterns)do
		local poi = dummyCard(name)
		if poi==nil then continue end
		poi:setSkillName("zuoxing")
		if poi:isAvailable(self.player)
		and poi:isNDTrick() and poi:isDamageCard()
		then
			local dummy = self:aiUseCard(poi)
			if dummy.card and dummy.to
			then
				self.zx_to = dummy.to
				sgs.ai_use_priority.zuoxing = sgs.ai_use_priority[poi:getClassName()]
				if poi:canRecast() and dummy.to:length()<1 then continue end
				return sgs.Card_Parse("#zuoxing:.:"..name)
			end
		end
	end
	for _,name in sgs.list(patterns)do
		local poi = dummyCard(name)
		if poi==nil then continue end
		poi:setSkillName("zuoxing")
		if poi:isAvailable(self.player)
		and poi:isNDTrick()
		and name~="amazing_grace"
		and name~="collateral"
		then
			local dummy = self:aiUseCard(poi)
			if dummy.card and dummy.to
			then
				self.zx_to = dummy.to
				sgs.ai_use_priority.zuoxing = sgs.ai_use_priority[poi:getClassName()]
				if poi:canRecast() and dummy.to:length()<1 then continue end
				return sgs.Card_Parse("#zuoxing:.:"..name)
			end
		end
	end
end

sgs.ai_skill_use_func["#zuoxing"] = function(card,use,self)
	use.card = card
	if use.to then use.to = self.zx_to end
end

sgs.ai_use_value.zuoxing = 8.4
sgs.ai_use_priority.zuoxing = 8.4]]

addAiSkills("huishi").getTurnUseCard = function(self)
	if self.player:hasUsed("huishi") then return end
	local player = self.player
   	if not player:hasUsed("#huishi")
	and player:getMaxHp()<10
   	then
		local parse = sgs.Card_Parse("#huishi:.:")
        assert (parse)
        return parse
	end
end

sgs.ai_skill_use_func["#huishi"] = function(card,use,self)
	if not self.player:hasUsed("#huishi") then
		local player = self.player
		use.card = card
	end
end

sgs.ai_use_value.huishi = 8.4
sgs.ai_use_priority.huishi = 8.4

sgs.ai_skill_invoke.huishi = function(self,data)
	local player = self.player
    return true
end

sgs.ai_skill_playerchosen.huishi = function(self,players)
	players = self:sort(players,"handcard")
    for _,target in sgs.list(players)do
    	if self:isFriend(target)
		then
            return target
		end
	end
end

sgs.ai_skill_playerchosen.godtianyi = function(self,players)
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"maxhp",true)
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		then
            return target
		end
	end
    return destlist[1]
end

sgs.ai_skill_playerchosen.zuoxing = function(self,players)
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"maxhp")
    for _,target in sgs.list(destlist)do
    	if self:isEnemy(target)
		then
            return target
		end
	end
    return destlist[1]
end

addAiSkills("huishii").getTurnUseCard = function(self)
	if (self.player:getMark("@huishiiMark") < 1) then return end
    return sgs.Card_Parse("#huishii:.:")
end

sgs.ai_skill_use_func["#huishii"] = function(card,use,self)
	if (self.player:getMark("@huishiiMark") > 0) then
		self:sort(self.friends,"hp")
		for _,ep in sgs.list(self.friends)do
			local skills = {}
			for _,sk in sgs.list(ep:getVisibleSkillList())do
				if sk:getFrequency(ep)~=sgs.Skill_Wake
				or ep:getMark(sk:objectName())>0
				then continue end
				table.insert(skills,sk:objectName())
			end
			if #skills>0
			and self.player:getMaxHp()>2
			and self.player:getLostHp()>1
			and self.player:getMaxHp()>=self.room:alivePlayerCount()
			then
				use.card = card
				if use.to then use.to:append(ep) end
				return
			end
		end
		for _,ep in sgs.list(self.friends)do
			if self:isWeak(ep) and self.player:getMaxHp()>2
			and self.player:getLostHp()>1
			then
				use.card = card
				if use.to then use.to:append(ep) end
				return
			end
		end
	end
end

sgs.ai_use_value.huishii = 8.4
sgs.ai_use_priority.huishii = 8.5

sgs.ai_skill_use["@@dangmo"] = function(self,prompt)
	local valid = {}
	local destlist = self.player:getAliveSiblings()
    destlist = self:sort(destlist,"hp")
	local n = self.player:getHp()-1
	for _,friend in sgs.list(destlist)do
		if #valid>=n then break end
		if self:isEnemy(friend)
		and friend:hasFlag("dangmo")
		then table.insert(valid,friend:objectName()) end
	end
	for _,friend in sgs.list(destlist)do
		if #valid>=n then break end
		if not self:isFriend(friend)
		and friend:hasFlag("dangmo")
		and not table.contains(valid,friend:objectName())
		then table.insert(valid,friend:objectName()) end
	end
	if #valid>0
	then
    	return string.format("#dangmo:.:->%s",table.concat(valid,"+"))
	end
end

addAiSkills("yingba").getTurnUseCard = function(self)
	if self.player:hasUsed("yingba") then return end
   	if self.player:getMaxHp()>2
   	then
        return sgs.Card_Parse("#yingba:.:")
	end
end

sgs.ai_skill_use_func["#yingba"] = function(card,use,self)
	if not self.player:hasUsed("#yingba") then
		self:sort(self.enemies,"hp")
		for _,ep in sgs.list(self.enemies)do
			if ep:isWounded()
			or ep:getMaxHp()<2
			then continue end
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
		self:sort(self.enemies,"hp",true)
		for _,ep in sgs.list(self.enemies)do
			if ep:getMaxHp()<2
			then continue end
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.yingba = 8.4
sgs.ai_use_priority.yingba = 7.4

sgs.ai_skill_askforyiji.pinghe = function(self,card_ids)
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
	   	if self:isFriend(p) then return p,cards[1]:getEffectiveId() end
	end
	for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
	   	if self:isEnemy(p) then continue end
		return p,cards[1]:getEffectiveId()
	end
	for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
		return p,cards[1]:getEffectiveId()
	end
end

--[[sgs.ai_use_revises.pinghe = function(self,card)
	if card:isKindOf("Peach")
	then return false end
end]]

--[[sgs.ai_skill_choice.dinghan = function(self,choices)
	local items = choices:split("+")
	local cns = self.player:property("SkillDescriptionRecord_dinghan"):toString():split("+")
	if table.contains(items,"remove")
	then
		for c,pn in sgs.list(cns)do
			c = dummyCard(pn)
			if c
			then
				self.ai_dinghan_choice = c:objectName()
				if c:isDamageCard() and self:isWeak()
				and self:getRestCardsNum(c:getClassName())>0
				then return "remove" end
				if c:isKindOf("DelayedTrick")
				and self:getRestCardsNum(c:getClassName())>0
				then return "remove" end
			end
		end
	end
	if table.contains(items,"add")
	then
		for d,c in sgs.list(self.player:getHandcards())do
			if table.contains(cns,c:objectName())
			or c:isZhinangCard() then continue end
			if c:targetFixed() and not c:isDamageCard()
			then
				self.ai_dinghan_choice = c:objectName()
				d = self:aiUseCard(c)
				if d.card and d.to
				then return "add" end
			end
		end
		for c,pn in sgs.list(patterns)do
			if table.contains(cns,pn) then continue end
			c = dummyCard(pn)
			if c
			then
				if table.contains(sgs.ZhinangClassName,c:getClassName())
				or c:isZhinangCard() then continue end
				self.ai_dinghan_choice = pn
				if c:targetFixed() and not c:isDamageCard()
				and self:getRestCardsNum(c:getClassName())>0
				then return "add" end
			end
		end
		for c,pn in sgs.list(patterns)do
			if table.contains(cns,pn) then continue end
			c = dummyCard(pn)
			if c
			then
				if table.contains(sgs.ZhinangClassName,c:getClassName())
				or c:isZhinangCard() then continue end
				self.ai_dinghan_choice = pn
				if c:isKindOf("GlobalEffect") and not c:isDamageCard()
				and self:getRestCardsNum(c:getClassName())>0
				then return "add" end
			end
		end
	end
	return "cancel"
end]]

sgs.ai_skill_askforag.dinghan = function(self,card_ids)
    for c,id in sgs.list(card_ids)do
        c = sgs.Sanguosha:getCard(id)
		if c:objectName()==self.ai_dinghan_choice
	    then return id end
    end
    for c,id in sgs.list(card_ids)do
        c = sgs.Sanguosha:getCard(id)
		if c:isDamageCard() and self:isWeak()
		and self:getRestCardsNum(c:getClassName())>0
	    then return id end
    end
    for c,id in sgs.list(card_ids)do
        c = sgs.Sanguosha:getCard(id)
		if c:targetFixed() and not c:isDamageCard()
		and self:getRestCardsNum(c:getClassName())>0
	    then return id end
    end
    for c,id in sgs.list(card_ids)do
        c = sgs.Sanguosha:getCard(id)
		if c:isKindOf("GlobalEffect") and not c:isDamageCard()
		and self:getRestCardsNum(c:getClassName())>0
	    then return id end
    end
end

--[[sgs.ai_target_revises.tianzuo = function(to,card,self)
    if card:isKindOf("Qizhengxiangsheng")
	and not self:isFriend(to)
	then return true end
end

sgs.ai_target_revises.dinghan = function(to,card,self)
    if card:getTypeId()==2
	then
		local cns = to:property("SkillDescriptionRecord_dinghan"):toString():split("+")
		if table.contains(cns,card:objectName())
		then return end
		return true
	end
end]]

sgs.ai_skill_playerchosen.kemobileyijin = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		then
            if self.player:getMark("@keyijin_houren")>0 and self:isWeak(target) and target:isWounded()
			then 
				sgs.ai_skill_choice.kemobileyijin = "keyijin_houren"
				return target
			end
            if self.player:getMark("@keyijin_tongshen")>0 and self:isWeak(target)
			then 
				sgs.ai_skill_choice.kemobileyijin = "keyijin_tongshen"
				return target
			end
            if self.player:getMark("@keyijin_wushi")>0 and not self:isWeak(target)
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_wushi"
				return target
			end
            if self.player:getMark("@keyijin_jinmi")>0 and target:isSkipped(sgs.Player_Play)
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_jinmi"
				return target
			end
		end
	end
    for _,target in sgs.list(destlist)do
    	if self:isEnemy(target)
		then
            if self.player:getMark("@keyijin_guxiong")>0 and self:isWeak(target)
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_guxiong"
				return target
			end
            if self.player:getMark("@keyijin_yongbi")>0 and target:getHandcardNum()<4
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_yongbi"
				return target
			end
            if self.player:getMark("@keyijin_jinmi")>0 and self:getOverflow()~=0
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_jinmi"
				return target
			end
		end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isFriend(target)
		then
            if self.player:getMark("@keyijin_guxiong")>0 and self:isWeak(target)
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_guxiong"
				return target
			end
            if self.player:getMark("@keyijin_yongbi")>0 and target:getHandcardNum()<4
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_yongbi"
				return target
			end
            if self.player:getMark("@keyijin_jinmi")>0 and self:getOverflow()~=0
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_jinmi"
				return target
			end
		end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isEnemy(target)
		then
            if self.player:getMark("@keyijin_houren")>0 and self:isWeak(target) and target:isWounded()
			then 
				sgs.ai_skill_choice.kemobileyijin = "keyijin_houren"
				return target
			end
            if self.player:getMark("@keyijin_tongshen")>0 and self:isWeak(target)
			then 
				sgs.ai_skill_choice.kemobileyijin = "keyijin_tongshen"
				return target
			end
            if self.player:getMark("@keyijin_wushi")>0 and not self:isWeak(target)
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_wushi"
				return target
			end
            if self.player:getMark("@keyijin_jinmi")>0 and target:isSkipped(sgs.Player_Play)
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_jinmi"
				return target
			end
		end
	end
end


--周不疑

local kehuiyao_skill = {}
kehuiyao_skill.name="kehuiyao"
table.insert(sgs.ai_skills,kehuiyao_skill)
kehuiyao_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#kehuiyaoCard") then
		if (not self:isWeak()) 
		and (self.player:getMark("&kequesong-Clear") == 0) then
			return sgs.Card_Parse("#kehuiyaoCard:.:")
		end
	end
end

sgs.ai_skill_use_func["#kehuiyaoCard"] = function(card,use,self)
	if not self.player:hasUsed("#kehuiyaoCard") then
		if (not self:isWeak()) 
		and (self.player:getMark("&kequesong-Clear") == 0) then
			use.card = card
		end
	end
end

sgs.ai_skill_playerchosen.kequesong = function(self, targets)
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

--摸牌回血随机选吧

sgs.ai_skill_playerchosen.kehuiyaoone = function(self, targets)
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

sgs.ai_skill_playerchosen.kehuiyaotwo = function(self, targets)
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

--ol周处

sgs.ai_skill_choice.keolshanduanmpjd = function(self, choices, data)
	return "shanduanfour"
end

sgs.ai_skill_choice.keolshanduancpgjfw = function(self, choices, data)
	local two = 1
	for _,p in sgs.qlist(self.player:getAliveSiblings()) do
		if self.player:isEnemy(p) and self.player:inMyAttackRange(p) then
			two = 0
		end
		break
	end	
	if two == 1 then
	    return "shanduantwo"
	else
		return "shanduanone"
	end
end

sgs.ai_skill_choice.keolshanduancpslash = function(self, choices, data)
	local items = choices:split("+")
	return items[#items]
end

sgs.ai_skill_discard.keolhuanfu = function(self, discard_num, min_num, optional, include_equip) 
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if self.player:hasFlag("wantusehuanfu") then
	    table.insert(to_discard, cards[1]:getEffectiveId())
		return to_discard
	else
	    return self:askForDiscard("dummyreason", 999, 999, true, true)
	end
end

local keolqingyi_skill = {}
keolqingyi_skill.name = "keolqingyi"
table.insert(sgs.ai_skills, keolqingyi_skill)
keolqingyi_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("keolqingyiCard") then return end
	return sgs.Card_Parse("#keolqingyiCard:.:")
end

sgs.ai_skill_use_func["#keolqingyiCard"] = function(card, use, self)
    if not self.player:hasUsed("#keolqingyiCard") then
		local room = self.room
		local all = room:getOtherPlayers(self.player)
		local enys = sgs.SPlayerList()
		for _, p in sgs.qlist(all) do
			if self:isEnemy(p) and (enys:length() < 2) then
				enys:append(p)
			end
		end
		if (enys:length() > 0) then
			for _, p in sgs.qlist(enys) do
				use.card = card
				if use.to then
					use.to:append(p)
				end
			end
		end	
		return
	end
end

sgs.ai_use_value.keolqingyiCard = 8.5
sgs.ai_use_priority.keolqingyiCard = 9.5
sgs.ai_card_intention.keolqingyiCard = 80


sgs.ai_skill_playerchosen.keolzeyue = function(self, targets)
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

--曹嵩

sgs.ai_skill_playerchosen.kemobileyijin = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		then
            if self.player:getMark("@keyijin_houren")>0 and self:isWeak(target) and target:isWounded()
			then 
				sgs.ai_skill_choice.kemobileyijin = "keyijin_houren"
				return target
			end
            if self.player:getMark("@keyijin_tongshen")>0 and self:isWeak(target)
			then 
				sgs.ai_skill_choice.kemobileyijin = "keyijin_tongshen"
				return target
			end
            if self.player:getMark("@keyijin_wushi")>0 and not self:isWeak(target)
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_wushi"
				return target
			end
            if self.player:getMark("@keyijin_jinmi")>0 and target:isSkipped(sgs.Player_Play)
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_jinmi"
				return target
			end
		end
	end
    for _,target in sgs.list(destlist)do
    	if self:isEnemy(target)
		then
            if self.player:getMark("@keyijin_guxiong")>0 and self:isWeak(target)
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_guxiong"
				return target
			end
            if self.player:getMark("@keyijin_yongbi")>0 and target:getHandcardNum()<4
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_yongbi"
				return target
			end
            if self.player:getMark("@keyijin_jinmi")>0 and self:getOverflow()~=0
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_jinmi"
				return target
			end
		end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isFriend(target)
		then
            if self.player:getMark("@keyijin_guxiong")>0 and self:isWeak(target)
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_guxiong"
				return target
			end
            if self.player:getMark("@keyijin_yongbi")>0 and target:getHandcardNum()<4
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_yongbi"
				return target
			end
            if self.player:getMark("@keyijin_jinmi")>0 and self:getOverflow()~=0
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_jinmi"
				return target
			end
		end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isEnemy(target)
		then
            if self.player:getMark("@keyijin_houren")>0 and self:isWeak(target) and target:isWounded()
			then 
				sgs.ai_skill_choice.kemobileyijin = "keyijin_houren"
				return target
			end
            if self.player:getMark("@keyijin_tongshen")>0 and self:isWeak(target)
			then 
				sgs.ai_skill_choice.kemobileyijin = "keyijin_tongshen"
				return target
			end
            if self.player:getMark("@keyijin_wushi")>0 and not self:isWeak(target)
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_wushi"
				return target
			end
            if self.player:getMark("@keyijin_jinmi")>0 and target:isSkipped(sgs.Player_Play)
			then
				sgs.ai_skill_choice.kemobileyijin = "keyijin_jinmi"
				return target
			end
		end
	end
end

local kemobileguanzong={}
kemobileguanzong.name="kemobileguanzong"
table.insert(sgs.ai_skills,kemobileguanzong)
kemobileguanzong.getTurnUseCard = function(self)
	if self.player:hasUsed("kemobileguanzongCard") then return end
	return sgs.Card_Parse("#kemobileguanzongCard:.:")
end

sgs.ai_skill_use_func["#kemobileguanzongCard"] = function(card,use,self)
	if not self.player:hasUsed("#kemobileguanzongCard") then
		self.gz_to = nil
		for _,fp in sgs.list(self.friends_noself)do
			for _,sk in sgs.list(aiConnect(fp))do
				local tsk = sgs.Sanguosha:getTriggerSkill(sk)
				if tsk and tsk:hasEvent(sgs.Damage)
				then
					use.card = card
					if use.to then use.to:append(fp) end
					return
				end
			end
		end
		for _,ep in sgs.list(self.enemies)do
			local can = true
			for _,sk in sgs.list(aiConnect(ep))do
				local tsk = sgs.Sanguosha:getTriggerSkill(sk)
				if tsk and tsk:hasEvent(sgs.Damage)
				then can = false break end
			end
			if can==false then break end
			for _,fp in sgs.list(self.friends_noself)do
				for _,sk in sgs.list(aiConnect(fp))do
					local tsk = sgs.Sanguosha:getTriggerSkill(sk)
					if tsk and tsk:hasEvent(sgs.Damaged)
					then
						use.card = card
						if use.to then use.to:append(ep) end
						self.gz_to = fp
						return
					end
				end
			end
		end
	end
end

sgs.ai_use_value.kemobileguanzongCard = 3.4
sgs.ai_use_priority.kemobileguanzongCard = 2.7

sgs.ai_skill_playerchosen.kemobileguanzongCard = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
		if target==self.gz_to
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		then return target end
	end
end

sgs.ai_skill_playerchosen.keoltongdu = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target) and self:isWeak()
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		then return target end
	end
	self:sort(destlist,"card",true)
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and target:getHandcardNum()>5
		then return target end
	end
	return destlist[1]
end

local keolzhubi={}
keolzhubi.name="keolzhubi"
table.insert(sgs.ai_skills,keolzhubi)
keolzhubi.getTurnUseCard = function(self)
	if self.player:hasUsed("keolzhubiCard") then return end
	return sgs.Card_Parse("#keolzhubiCard:.:")
end

sgs.ai_skill_use_func["#keolzhubiCard"] = function(card,use,self)
	if not self.player:hasUsed("#keolzhubiCard") then
		self:sort(self.friends,"card")
		for _,fp in sgs.list(self.friends)do
			if not fp:hasFlag("keolzhubiTo")
			and fp:getCardCount()>1
			then
				use.card = card
				fp:setFlags("keolzhubiTo")
				if use.to then use.to:append(fp) end
				return
			end
		end
		for _,fp in sgs.list(self.enemies)do
			if not fp:hasFlag("keolzhubiTo")
			and fp:getCardCount()==1
			then
				use.card = card
				fp:setFlags("keolzhubiTo")
				if use.to then use.to:append(fp) end
				return
			end
		end
		for _,fp in sgs.list(self.friends)do
			if fp:getCardCount()>2
			then
				use.card = card
				fp:setFlags("keolzhubiTo")
				if use.to then use.to:append(fp) end
				return
			end
		end
	end
end

sgs.ai_use_value.keolzhubiCard = 3.4
sgs.ai_use_priority.keolzhubiCard = 6.2

sgs.ai_skill_use["@@keolzhubi"] = function(self,prompt)
	local valid = {}
	local ids = self.player:getTag("keolzhubiForAI"):toIntList()
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
    self:sortByKeepValue(cards) -- 按保留值排序
   	for _,c in sgs.list(cards)do
    	if c:hasTip("keolzhubi")
		then
			for _,id in sgs.list(ids)do
				if table.contains(valid,id) then continue end
				local c2 = sgs.Sanguosha:getCard(id)
				if self:cardNeed(c2)>self:cardNeed(c)
				then
					table.insert(valid,c:getId())
					table.insert(valid,id)
					break
				end
			end
		end
	end
	if #valid<2 then return end
	return string.format("#keolzhubiVSCard:%s:",table.concat(valid,"+"))
end

sgs.ai_skill_playerchosen.keolzhuri = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card")
	local mc = self:getMaxCard()
	if mc
	then
		for _,target in sgs.list(destlist)do
			if self:isEnemy(target) and self:isWeak(target)
			and mc:getNumber()>9 then return target end
		end
		for _,target in sgs.list(destlist)do
			if self:isEnemy(target)
			and mc:getNumber()>9 then return target end
		end
		for _,target in sgs.list(destlist)do
			if not self:isFriend(target)
			and mc:getNumber()>9 then return target end
		end
		self:sort(destlist,"card",true)
		for _,target in sgs.list(destlist)do
			if self:isFriend(target)
			and mc:getNumber()>6 then return target end
		end
	end
end

--[[sgs.ai_skill_use["@@keolzhuri"] = function(self,prompt)
	local ids = self.player:getTag("keolzhuriForAI"):toIntList()
	for _,id in sgs.list(ids)do
		local c2 = sgs.Sanguosha:getCard(id)
		if c2:isAvailable(self.player)
		then
			local d = self:aiUseCard(c2)
			if d.card
			then
				local tos = {}
				for _,p in sgs.list(d.to)do
					table.insert(tos,p:objectName())
				end
				if c2:canRecast() and #tos<1 then continue end
				return id.."->"..table.concat(tos,"+")
			end
		end
	end
end]]

sgs.ai_skill_choice.keolzhuri = function(self,choices)
	local items = choices:split("+")
	return self:isWeak() and items[2] or items[1]
end

sgs.ai_skill_invoke.keolranji = function(self,data)
    return self.player:getMark("keolranji_used-Clear") == self.player:getHp()
end

sgs.ai_skill_invoke.keolguangao = function(self,data)
    if self.player:hasFlag("wantusekeolguangao") then
		return true
	end
end

--[[sgs.ai_skill_playerschosen.keolguangao = function(self, targets, max, min)
    local selected = sgs.SPlayerList()
    local n = max
    local can_choose = sgs.QList2Table(targets)
    --self:sort(can_choose, "defense")
    for _,target in ipairs(can_choose) do
        if self:isFriend(target) then
            selected:append(target)
            n = n - 1
        end
        if n <= 0 then break end
    end
    return selected
end]]

local keolxieju_skill = {}
keolxieju_skill.name = "keolxieju"
table.insert(sgs.ai_skills, keolxieju_skill)
keolxieju_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("keolxiejuCard") then return end
	return sgs.Card_Parse("#keolxiejuCard:.:")
end

sgs.ai_skill_use_func["#keolxiejuCard"] = function(card, use, self)
	if not self.player:hasUsed("#keolxiejuCard") then
		for _, p in sgs.list(self.friends) do
			if p:getMark("keolxiejutar-Clear") > 0 then
				use.card = card
				if use.to then
					use.to:append(p)
				end
			end
		end
	end
end

--[[sgs.ai_use_value.keolxiejuCard = 8.5
sgs.ai_use_priority.keolxiejuCard = 9.5
sgs.ai_card_intention.keolxiejuCard = 80]]

sgs.ai_skill_use["@@keolxiejuslash"] = function(self,prompt)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if self.player:isLocked(h) or not h:isBlack() then continue end
    	local c = dummyCard()
		c:setSkillName("_keolxieju")
		c:addSubcard(h)
		--local dummy = self:aiUseCard(c)
		local dummy = {isDummy=true,to=sgs.SPlayerList()}
        self:useCardByClassName(c, dummy)
		if dummy.card and dummy.to
		then
			local tos = {}
			for _,p in sgs.list(dummy.to)do
				table.insert(tos,p:objectName())
			end
			return c:toString().."->"..table.concat(tos,"+")
		end
	end
end


--[[sgs.ai_skill_use["@@keolxiejuslash"] = function(self,prompt)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if self.player:isJilei(h) or (not h:isBlack()) then continue end
    	local c = sgs.Sanguosha:cloneCard("slash")
		c:setSkillName("_keolxieju")
		c:addSubcard(h)
		local dummy = {isDummy=true,to=sgs.SPlayerList()}
		self["use"..sgs.ai_type_name[c:getTypeId()+1].."Card"](self,c,dummy)
		if dummy.card and dummy.to
		then
			local tos = {}
			for _,p in sgs.list(dummy.to)do
				table.insert(tos,p:objectName())
			end
			return "#kezhuanchuanxinCard:"..h:getId()..":->"..table.concat(tos,"+")
		end
	end
end]]

sgs.ai_skill_discard.keolshuangxiong = function(self, discard_num, min_num, optional, include_equip) 
	local cards = self.player:getCards("he")
	if cards:length()>2 then
	    return self:askForDiscard("dummyreason", 1, 1, true, true)
	end
end

local keolshuangxiong = {}
keolshuangxiong.name = "keolshuangxiong"
table.insert(sgs.ai_skills, keolshuangxiong)
keolshuangxiong.getTurnUseCard = function(self)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if self.player:isLocked(h)
		or h:getColor()==self.player:getMark("keolshuangxiong-Clear")
		then continue end
    	local c = dummyCard("duel")
		c:setSkillName("keolshuangxiong")
		c:addSubcard(h)
		if c:isAvailable(self.player)
		then return c end
	end
end


sgs.ai_skill_invoke.keolqiejian = function(self,data)
    return true
end

--张翼

sgs.ai_skill_invoke.keolkangrui = function(self,data)
	local room = self.room
	local nowplayer = room:getCurrent()
    return self:isFriend(nowplayer)
end


sgs.ai_skill_choice.keolkangrui = function(self, choices, data)
    if self.player:hasFlag("wantkangruida") and (not self:isWeak()) then return "damage" end
	return "huifu"
end






























