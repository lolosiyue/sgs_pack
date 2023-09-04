

sgs.ai_skill_defense.bf_jiufa = function(self,player)
	return self:isFriend(player) and player:getMaxHp() or -player:getMaxHp()
end

sgs.ai_skill_defense.bf_pingxiang = function(self,player)
    return player:getMark("@bf_pingxiang")>0 and player:getMaxHp() or 0
end

sgs.ai_skill_choice.bf_quanxue = function(self,choices,data)
	local player = self.player
	local items = choices:split("+")
	local to = data:toPlayer()
   	if hasZhaxiangEffect(player)
	then return "lost_hp" end
	if not self:isEnemy(to)
	then return "draw" end
	items = sgs.QList2Table(player:getCards("h"))
   	for _,h in sgs.list(items)do
		h = self:aiUseCard(h)
		if h.card and h.to
		then return "draw" end
	end
	return "no_card_to"
end

local bf_pingxiang={}
bf_pingxiang.name="bf_pingxiang"
table.insert(sgs.ai_skills,bf_pingxiang)
bf_pingxiang.getTurnUseCard = function(self)
	if self.player:getMaxHp()>9
	and #self.enemies>0
	then
        local parse = sgs.Card_Parse("#bf_pingxiangCard:.:")
        assert(parse)
        return parse
	end
end

sgs.ai_skill_use_func["#bf_pingxiangCard"] = function(card,use,self)
	local player = self.player
	use.card = card
	local destlist = self.room:getAlivePlayers()
	destlist = sgs.QList2Table(destlist)
	self:sort(destlist,"hp")
	for _,ep in sgs.list(destlist)do
		if use.to
		and self:isEnemy(ep)
		then
			for i=0,ep:getHp()do
	        	if use.to:length()>=9
				then break end
				use.to:append(ep)
			end
		end
	end
	for _,ep in sgs.list(destlist)do
		if use.to
		and not self:isEnemy(ep)
		and not self:isFriend(ep)
		then
			for i=0,ep:getHp()do
	        	if use.to:length()>=9
				then break end
				use.to:append(ep)
			end
		end
	end
	if use.to
	and use.to:length()>0
	then
		local uto = sgs.SPlayerList()
		for _,to in sgs.list(use.to)do
			uto:append(to)
		end
		while use.to:length()<9 do
			local bto = nil
			for _,to in sgs.list(uto)do
		    	if to==bto
				or use.to:length()>=9
				then continue end
				use.to:append(to)
				bto = to
			end
		end
	end
end

sgs.ai_use_value.bf_pingxiangCard = 9.4
sgs.ai_use_priority.bf_pingxiangCard = 1.4

sgs.ai_skill_invoke.bf_huizhi = function(self,data)
	local player = self.player
	return bf_huizhi_self:length()<3
	or not self:isWeak()
end

sgs.ai_skill_playerchosen.bf_huizhi = function(self,players)
	local player = self.player
	local destlist,a = players,false
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"hp")
	for _,c in sgs.list(bf_huizhi_self)do
		c = sgs.Sanguosha:getCard(c)
		if c:isKindOf("Analeptic")
		then a = c break end
	end
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		and target:isKongcheng()
		and self:isWeak(target)
		and a
		then return target end
	end
    return player
end

sgs.ai_skill_playerchosen.bf_tianyig = function(self,players)
	local player = self.player
    return player
end

sgs.ai_skill_playerchosen.bf_zuoxing = function(self,players)
	local player = self.player
	local destlist,a = players,false
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
    	if self:isEnemy(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if target:getMaxHp()>1
		then return target end
	end
end

sgs.ai_skill_choice.bf_huishi = function(self,choices)
	local player = self.player
	local items,can = choices:split("+"),true
    for _,sk in sgs.list(player:getVisibleSkillList())do
	   	if sk:getFrequency(player)==sgs.Skill_Wake
		and self.player:getMark(sk:objectName())<1
		then can = false end
    end
   	if can
	and player:getHp()>1
	and player:getHandcardNum()<4
	and table.contains(items,"bf_huishi_hp")
	then return "bf_huishi_hp" end
   	if table.contains(items,"bf_huishi_card")
	and player:getCardCount()>4
	then return "bf_huishi_card" end
   	if table.contains(items,"bf_huishi_maxhp")
	and player:getLostHp()>1
	then return "bf_huishi_maxhp" end
   	if table.contains(items,"bf_huishi_hp")
	and player:getHp()>3
	then return "bf_huishi_hp" end
   	if table.contains(items,"bf_huishi_card")
	then return "bf_huishi_card" end
end

sgs.ai_skill_invoke.bf_poxi = function(self,data)
	local player = self.player
	local dama = data:toPlayer()
	if dama:isKongcheng()
	then return end
    return not self:isFriend(dama) and dama:getHandcardNum()<5
	or dama:getHandcardNum()>1 and dama:getHandcardNum()<4
end

sgs.ai_skill_invoke.bf_jieyingg = function(self,data)
	local player = self.player
    if self:isWeak()
	and self:getCardsNum("Peach","he")>0
	then return end
	return player:getHandcardNum()<5
end

sgs.ai_skill_playerchosen.bf_jieyingg = function(self,players)
	local player = self.player
	local destlist,a = players,false
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"handcard")
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		and self:canDisCard(target,"j")
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if self:isEnemy(target)
		and target:getHandcardNum()>0
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if target:getHandcardNum()>1
		then return target end
	end
	return destlist[1]
end

sgs.ai_skill_playerchosen.bf_jieying = function(self,players)
	local player = self.player
	local destlist,a = players,false
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"handcard")
    for _,target in sgs.list(destlist)do
    	if target:isChained() then continue end
    	if self:isEnemy(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if target:isChained() then continue end
		if not self:isFriend(target)
		then return target end
	end
	return destlist[1]
end

sgs.ai_skill_invoke.bf_jilve = function(self,data)
	local player = self.player
    if bf_jilve_trigger.event==sgs.EventPhaseChanging
	then
		for _,p in sgs.list(self.enemies)do
			if self:isWeak(p)
			and player:canSlash(p)
			then
				local slash = self:getCard("Slash")
				if slash
				then
					slash = self:aiUseCard(slash)
					if slash.card and slash.to:contains(p)
					then return true end
				end
			end
		end
	end
    if bf_jilve_trigger.event==sgs.Damaged
	then
		return sgs.ai_skill_invoke.bf_fangzhu(self,bf_jilve_trigger.data)
	end
    if bf_jilve_trigger.event==sgs.AskForRetrial
	then
		return sgs.Sanguosha:cloneCard(bf_jilve_trigger.data:toJudge().reason)
		and sgs.ai_skill_cardask["@nosguicai-card"](self,data)~="."
	end
end

sgs.ai_skill_invoke.bf_guixin = function(self,data)
	local player,can = self.player,0
	for _,p in sgs.list(player:getAliveSiblings())do
		if p:getCardCount()>0
		then can = can+1 end
	end
	return can>1
	or not player:faceUp()
end

sgs.ai_skill_cardask.bf_guixin = function(self,data,pattern,prompt)
	local player = self.player
    local parsed = prompt:split(":")
    if not self:isWeak()
	and player:getAliveSiblings():length()>1
	then
    	if parsed[1]=="slash-jink"
		then
	    	parsed = data:toSlashEffect()
			if parsed.slash
			and parsed.to==player
			and self:getKnownCards(parsed.to,parsed.from,parsed.slash)
			then return false end
		else
	    	parsed = data:toCardEffect()
			if parsed.card
			and parsed.card:isDamageCard()
			and parsed.to==player
			and self:canLoseHp(parsed.from,parsed.card)
			then return false end
		end
	end
	if not player:faceUp()
	and self:getCardsNum("Peach","he")+self:getCardsNum("Analeptic","he")>0
	then return false end
end

sgs.ai_nullification.bf_guixin = function(self,trick,from,to,positive)
    if self:isFriend(to)
	and not self:isWeak()
	and to:getAliveSiblings():length()>1
	and self:canLoseHp(from,trick,to)
	then return false end
	if not to:faceUp()
	and to==self.player
	and self:getCardsNum("Peach","he")+self:getCardsNum("Analeptic","he")>0
	then return false end
end

sgs.ai_skill_use["@@bf_guixin"] = function(self,prompt)
    return "#bf_guixincard:.:"
end

sgs.ai_skill_use["@@bf_qinyin"] = function(self,prompt)
	local player = self.player
    return "#bf_qinyincard:.:"
end

sgs.ai_skill_invoke.bf_qinyin = function(self,data)
	local player,can = self.player,0
	for _,p in sgs.list(self.room:getAlivePlayers())do
		if self:isEnemy(p)
		and self:isWeak(p)
		then can = can+1 end
		if p:getHp()<2
		and self:isEnemy(p)
		then can = can+1 end
		if self:isFriend(p)
		and self:isWeak(p)
		then can = can+1 end
		if p:getHp()<2
		and self:isFriend(p)
		then can = can+1 end
		if p:getHp()>2
		and self:isFriend(p)
		then can = can+1 end
	end
	return can>1
end

sgs.ai_skill_choice.bf_qinyin = function(self,choices,data)
	local player = self.player
	local items,can = choices:split("+"),0
	for _,p in sgs.list(self.room:getAlivePlayers())do
		if self:isEnemy(p)
		and self:isWeak(p)
		then can = can+1 end
		if p:getHp()<2
		and self:isEnemy(p)
		then can = can+1 end
		if p:getHp()<2
		and self:isFriend(p)
		then can = can-1 end
		if p:getHp()>2
		and self:isFriend(p)
		then can = can+1 end
	end
	return can>2 and "bf_down" or "bf_up"
end

sgs.ai_skill_playerchosen.bf_shenfu = function(self,players)
	local player = self.player
	local destlist,can = players,math.mod(player:getHandcardNum(),2)==1
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
    	if can
		and self:isEnemy(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if can
		and not self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if not can
		and self:isFriend(target)
		then return target end
	end
end

sgs.ai_skill_invoke.bf_shenfu = function(self,data)
	local player = self.player
	return false
end

sgs.ai_skill_invoke.bf_duorui = function(self,data)
	local player = self.player
	return not self:isFriend(bf_duorui_to)
end

sgs.ai_skill_use["@@bf_qixing"] = function(self,prompt)
	local player = self.player
    local stars,cs = player:getPile("stars"),{}
    stars = sgs.QList2Table(stars) -- 将列表转换为表
	for _,c in sgs.list(stars)do
		table.insert(cs,sgs.Sanguosha:getCard(c))
	end
    self:sortByKeepValue(cs) -- 按保留值排序
	local toids = {}
    local cards = player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for i,c in sgs.list(cs)do
    	if math.mod(i,2)==1
		and #toids<#cards/2
		then
			table.insert(toids,c:getEffectiveId())
		end
	end
	local n = #toids
	for i,c in sgs.list(cards)do
    	if math.mod(i,2)==1
		and #toids<n*2
		then
			table.insert(toids,c:getEffectiveId())
		end
	end
	if #toids>1
	and math.mod(#toids,2)~=1
	then
    	return string.format("#bf_qixingCard:%s:",table.concat(toids,"+"))
	end
end

sgs.ai_skill_use["@@bf_kuangfeng"] = function(self,prompt)
	local valid = {}
	local player = self.player
    local stars,cs = player:getPile("stars"),{}
    stars = sgs.QList2Table(stars) -- 将列表转换为表
	for _,c in sgs.list(stars)do
		table.insert(cs,sgs.Sanguosha:getCard(c))
	end
    self:sortByKeepValue(cs) -- 按保留值排序
	local destlist = player:getAliveSiblings()
--	destlist:append(player)
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	for _,fp in sgs.list(destlist)do
		if #valid>=#cs then break end
		if self:isEnemy(fp)
		and self:isWeak(fp)
		then
    		table.insert(valid,fp:objectName())
		end
	end
	if #valid<1 then return end
	local give = {}
	for _,c in sgs.list(cs)do
		if #give>=#valid then break end
		table.insert(give,c:getEffectiveId())
	end
--	return string.format("#bf_kuangfengCard:%s:->%s",table.concat(give,"+"),table.concat(valid,"+"))
end

sgs.ai_skill_use["@@bf_dawu"] = function(self,prompt)
	local player = self.player
    local stars,cs = player:getPile("stars"),{}
	for _,c in sgs.list(stars)do
		table.insert(cs,sgs.Sanguosha:getCard(c))
	end
    self:sortByKeepValue(cs) -- 按保留值排序
	local destlist = player:getAliveSiblings()
	destlist:append(player)
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	local give = {}
	local valid = {}
	for _,fp in sgs.list(destlist)do
		if #valid>=#cs
		then break end
		if self:isFriend(fp)
		and self:isWeak(fp)
		and fp:getMark("&bf_dawu")<#destlist
		and fp:getHandcardNum()+fp:getPile("wooden_ox"):length()<2
		then
			for _,c in sgs.list(cs)do
				
				if c:getNumber()>=#destlist
				then
					table.insert(valid,fp:objectName())
					table.insert(give,c:getEffectiveId())
					table.removeOne(cs,c)
					break
				end
			end
		end
	end
	if #valid<1
	or #valid~=#give
	then return end
	return string.format("#bf_dawuCard:%s:->%s",table.concat(give,"+"),table.concat(valid,"+"))
end

sgs.ai_skill_cardask["&bf_dawu"] = function(self,data,pattern,prompt)
	local player = self.player
    local parsed = prompt:split(":")
   	if parsed[1]=="slash-jink"
	then
	   	parsed = data:toSlashEffect()
		if parsed.slash:objectName()=="thunder_slash"
		or hasJueqingEffect(parsed.from,parsed.to)
		then return end
	end
	return false
end

sgs.ai_target_revises["&bf_dawu"] = function(to,card,self)
	if card:objectName()=="thunder_slash"
	or hasJueqingEffect(self.player,to)
	then return end
	return card:isDamageCard() or nil
end

sgs.ai_skill_playerchosen.rende = function(self,players)
	local player = self.player
	local destlist,a = players,false
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"handcard")
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

sgs.ai_skill_playerchosen.fangquan = function(self,players)
	local player = self.player
	local destlist,a = players,false
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"chaofeng")
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

--[[
sgs.ai_skill_use["@@bf_tianxing"] = function(self,prompt)
	local valid = {}
	local player = self.player
    local stars,sk = player:getPile("powerful"),prompt:split(":")[2]
    stars = sgs.QList2Table(stars) -- 将列表转换为表
	if #stars<2
	then return end
	local give = {}
	table.insert(give,stars[1])
	table.insert(give,stars[2])
	if sgs.ai_skill_playerchosen[sk](self,self.room:getOtherPlayers(player))
	or sgs.ai_skill_invoke[sk](self,player:getTag("bf_tianxing"))
	then
		return string.format("#bf_tianxingCard:%s:%s",table.concat(give,"+"),"@@bf_tianxing")
	end
end
--]]

sgs.ai_skill_use["@@bf_tianxing"] = function(self,prompt)
	local player = self.player
    local stars,sk = player:getPile("powerful"),prompt:split(":")[2]
    stars = sgs.QList2Table(stars) -- 将列表转换为表
    local cards = {}
	for i,id in sgs.list(stars)do
		table.insert(cards,sgs.Sanguosha:getCard(id))
	end
    self:sortByKeepValue(cards) -- 按保留值排序
	cards = string.format("#bf_tianxingCard:%s:%s",cards[#cards]:getEffectiveId(),"@@bf_tianxing")
	if sk=="fangquan"
	then return sgs.ai_skill_invoke[sk](self) and cards
	else return cards end
end

sgs.ai_skill_choice.bf_tianxing = function(self,choices,data)
	local player = self.player
	local items = choices:split("+")
	return self.bf_tianxing_choice
end

sgs.ai_skill_cardask.bf_tianxing = function(self,data,pattern,prompt)
	local player = self.player
    local stars = player:getPile("powerful")
    local parsed = prompt:split(":")
    if not self:isWeak()
	then
    	if parsed[1]=="slash-jink"
		then
	    	parsed = data:toSlashEffect()
			if parsed.slash
			and self:canLoseHp(parsed.from,parsed.slash)
			then return false end
		else
	    	parsed = data:toCardEffect()
			if parsed.card
			and parsed.card:isDamageCard()
			and self:canLoseHp(parsed.from,parsed.card)
			then return false end
		end
	end
end

sgs.ai_nullification.bf_tianxing = function(self,trick,from,to,positive)
    local stars = to:getPile("powerful")
    if self:isFriend(to)
	and not self:isWeak()
	and stars:length()>to:getLostHp()
	and self:canLoseHp(tfrom,trick,to)
	then return false end
end

sgs.ai_skill_playerchosen.bf_cuike = function(self,players)
	local player = self.player
	local destlist,n = players,math.mod(player:getMark("@junlve"),2)==1
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if n and self:isEnemy(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isFriend(target)
		and target:getCardCount()>0
		and not target:isChained()
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isFriend(target)
		and target:getCardCount()>0
		then return target end
	end
end

sgs.ai_skill_playerchosen.bf_zhanhuo = function(self,players)
	local player = self.player
	local destlist,n = players,math.mod(player:getMark("@junlve"),2)==1
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if target:isChained()
		and self:isWeak(target)
		and self:isEnemy(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if self:isEnemy(target)
		and target:isChained()
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isFriend(target)
		then return target end
	end
end

sgs.ai_skill_choice.bf_powei = function(self,choices,data)
	local player = self.player
	local use = data:toCardUse()
	return math.random(0,use.to:at(0):getHandcardNum())<3 and "bf_shi" or "bf_xu"
end

sgs.ai_skill_use["@@bf_pinghe!"] = function(self,prompt)
	local valid = nil
	local player = self.player
    local cards = player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	local destlist = player:getAliveSiblings()
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"handcard")
	for _,fp in sgs.list(destlist)do
		if valid then break end
		if self:isFriend(fp) and self:isWeak(fp)
		then valid = fp:objectName() end
	end
	for _,fp in sgs.list(destlist)do
		if valid then break end
		if self:isFriend(fp)
		then valid = fp:objectName() end
	end
	for _,fp in sgs.list(destlist)do
		if valid then break end
		if not self:isEnemy(fp)
		then valid = fp:objectName() end
	end
	valid = valid or destlist[1]:objectName()
	return string.format("#bf_pingheCard:%s:->%s",cards[1]:getEffectiveId(),valid)
end

sgs.ai_use_revises.bf_pinghe = function(self,card,use)
	if card:isKindOf("Peach")
	then return false end
end

sgs.card_value.bf_pinghe = {
	Jink = 9.7,
	Nullification = 8,
	Slash = 7.2,
--	Peach = -3.9,
	Analeptic = -1.9,
}

sgs.ai_skill_invoke.bf_chuyuan = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return not self:isEnemy(to) or to:getCardCount()<2
	or player:getPile("powerful"):length()<player:getMaxHp()
end

sgs.ai_skill_invoke.bf_meihun = function(self,data)
	local player = self.player
	local use = data:toCardUse()
	return not self:isFriend(use.from)
	or not self:isFriend(use.to:at(0))
	or self:isWeak()
end

sgs.ai_skill_choice.bf_meihun = function(self,choices,data)
	local player = self.player
	local use = data:toCardUse()
	if self:isFriend(use.from)
	then
    	return self:isFriend(use.to:at(0)) and "black" or "red"
	else return "red" end
end

sgs.ai_skill_use["@@bf_huoxin"] = function(self,prompt)
	local valid = {}
	local player = self.player
    local hs = {}
	for _,fp in sgs.list(self.room:getOtherPlayers(player))do
		if fp:getMark("bf_huoxin-Clear")>0
		then
			hs = sgs.QList2Table(fp:getHandcards())
			self:sortByUsePriority(hs)
			for _,c in sgs.list(hs)do
				if c:isAvailable(fp)
				then
					local dummy = self:aiUseCard(c)
					if dummy.card
					and dummy.to
					then
						for _,p in sgs.list(dummy.to)do
							local plist = sgs.PlayerList()
							if c:targetFilter(plist,p,fp)
							then
								table.insert(valid,p:objectName())
								plist:append(p)
							end
						end
						if dummy.to:length()>0 and #valid<1
						or self:isEnemy(fp) and c:getTypeId()==3
						then return end
						return string.format("#bf_huoxincard:%s:->%s",c:getEffectiveId(),table.concat(valid,"+"))
					end
				end
			end
		end
	end
end

sgs.ai_skill_invoke.bf_songwei = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return self:isFriend(to)
end

sgs.ai_skill_invoke.bf_fangzhu = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return not self:isFriend(to) and to:faceUp()
	or not self:isEnemy(to) and not to:faceUp()
end

sgs.ai_skill_cardask.bf_guicai0 = function(self,data)
    local judge = data:toJudge()
	local player = self.player
	local cards = player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if self:needRetrial(judge)
    then
    	local canc = {}
		while #cards>0 do
			local id = self:getRetrialCardId(cards,judge)
			if id~=-1
			then
				id = sgs.Sanguosha:getCard(id)
				table.insert(canc,id)
				table.removeOne(cards,id)
			else break end
		end
		if #canc>0
		then
			for i,c in sgs.list(canc)do
				if c:isRed()
				and self:getUseValue(judge.card)>=self:getUseValue(c)
				then return c:getEffectiveId() end
			end
			for i,c in sgs.list(canc)do
				if c:isRed()
				then return c:getEffectiveId() end
			end
			return canc[1]:getEffectiveId()
		end
	else
    	local canc = {}
		while #cards>0 do
			local id = self:getRetrialCardId(cards,judge)
			if id~=-1
			then
				id = sgs.Sanguosha:getCard(id)
				table.insert(canc,id)
				table.removeOne(cards,id)
			else break end
		end
		if #canc>0
		then
			for i,c in sgs.list(canc)do
				if c:isRed()
				and self:getUseValue(judge.card)>self:getUseValue(c)
				then return c:getEffectiveId() end
			end
		end
	end
    return "."
end

sgs.ai_useto_revises.bf_guicai = function(self,card,use,to)--卡牌对场上某张牌的使用修正
	if self:isFriend(to)
	and not to:isKongcheng()
	and card:isKindOf("Lightning")
	then use.card = card end
end

sgs.ai_use_revises.bf_juejing = function(self,card,use)
	if card:isKindOf("Peach")
	then return false end
end

sgs.ai_skill_cardask.bf_juejing = function(self,data,pattern,prompt)
	local player = self.player
    local parsed = prompt:split(":")
    if player:hasSkill("bf_longhun")
	and player:getHp()>1
	then
    	if parsed[1]=="slash-jink"
		then
	    	parsed = data:toSlashEffect()
			if parsed.slash
			and parsed.to==player
			then return false end
		else
	    	parsed = data:toCardEffect()
			if parsed.card
			and parsed.card:isDamageCard()
			and parsed.to==player
			then return false end
		end
	end
end

sgs.ai_nullification.bf_juejing = function(self,trick,from,to,positive)
    if self:isFriend(to)
	and trick:isDamageCard()
   	and to:hasSkill("bf_longhun")
	and to:getHp()>1
	then return false end
end

sgs.ai_use_revises.bf_lianpo = function(self,card,use)
	if card:isDamageCard()
	and self.player:hasFlag("bf_lianpo")
	then return false end
end

sgs.ai_skill_cardask.bf_renjie = function(self,data,pattern,prompt)
	local player = self.player
    local parsed = prompt:split(":")
    if not self:isWeak()
   	and player:hasSkill("bf_baiyin")
	and player:getPhase()==sgs.Player_NotActive
	then
    	if parsed[1]=="slash-jink"
		then
	    	parsed = data:toSlashEffect()
			if parsed.slash
			and parsed.to==player
			and self:canLoseHp(parsed.from,parsed.slash)
			then return false end
		else
	    	parsed = data:toCardEffect()
			if parsed.card
			and parsed.card:isDamageCard()
			and parsed.to==player
			and self:canLoseHp(parsed.from,parsed.card)
			then return false end
		end
	end
end

sgs.ai_nullification.bf_renjie = function(self,trick,from,to,positive)
    if self:isFriend(to)
	and not self:isWeak()
   	and to:hasSkill("bf_baiyin")
	and self:canLoseHp(from,trick,to)
	and to:getPhase()==sgs.Player_NotActive
	then return false end
end

sgs.ai_use_revises.bf_jilve = function(self,card,use)
	local player = self.player
	if card:isKindOf("Lightning")
	and player:getMark("@bear")>1
	then use.card = card end
end

sgs.ai_use_revises.bf_renjie = function(self,card,use)
	if card:isKindOf("Peach") and self:isWeak()
	or card:isKindOf("ExNihilo")
	then return end
	if card:getTypeId()~=0
   	and self.player:hasSkill("bf_baiyin")
	and self.player:getMark("bf_baiyin")<1
--	and self.player:getHandcardNum()-self.player:getMaxCards()==1
	then return false end
end

sgs.ai_skill_use["@@bf_jiufa!"] = function(self,prompt)
	local valid = {}
	local player = self.player
    local slash = sgs.Sanguosha:cloneCard("slash")
	slash:setSkillName("_bf_jiufa")
	local dummy = self:aiUseCard(slash)
	if dummy.card
	and dummy.to
	and dummy.to:length()>0
	then
		for i,p in sgs.list(dummy.to)do
			table.insert(valid,p:objectName())
		end
		return slash:toString().."->"..table.concat(valid,"+")
	end
	local x = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,player,slash)+1
	local destlist = self.room:getOtherPlayers(player)
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	for _,ep in sgs.list(destlist)do
		if self:isFriend(ep)
		or	#valid>=x
		then continue end
		if source:canSlash(ep,slash)
		then table.insert(valid,ep:objectName()) end
	end
	if #valid<1
	then
		for _,ep in sgs.list(destlist)do
			if #valid>=x
			then continue end
			if source:canSlash(ep,slash)
			then table.insert(valid,ep:objectName()) end
		end
	end
	return #valid>0 and slash:toString().."->"..table.concat(valid,"+")
end

sgs.ai_skill_cardask.bf_ganglie0 = function(self,data)
    local to = data:toPlayer()
	local player = self.player
	local cards = player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if self:isEnemy(to)
    then
    	return cards[1]:getEffectiveId()
	end
    return "."
end

sgs.ai_skill_cardask.bf_fankui0 = function(self,data,pattern)
	local player = self.player
	local cards = player:getCards("he")
	cards = sgs.QList2Table(cards)
    self:sortByKeepValue(cards) -- 按保留值排序
   	for _,c in sgs.list(cards)do
    	if sgs.Sanguosha:matchExpPattern(pattern,player,c)
		then return c:getEffectiveId() end
	end
    return "."
end

sgs.ai_skill_use["@@bf_tuxi"] = function(self,prompt)
	local valid = {}
	local player = self.player
	local destlist = player:getAliveSiblings()
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	for _,fp in sgs.list(destlist)do
		if #valid>0 then break end
		if self:isEnemy(fp)
		and fp:getCardCount()>0
		then
			table.insert(valid,fp:objectName())
		end
	end
	for _,fp in sgs.list(destlist)do
		if #valid>0 then break end
		if not self:isFriend(fp)
		and fp:getCardCount()>0
		then
			table.insert(valid,fp:objectName())
		end
	end
	return #valid>0 and string.format("#bf_tuxiCard:.:->%s",table.concat(valid,"+"))
end

sgs.ai_skill_askforyiji.bf_yiji = function(self,card_ids)
	return sgs.ai_skill_askforyiji.nosyiji(self,card_ids)
end

sgs.ai_view_as.bf_qingguo = function(card,player,card_place)
   	if card_place==sgs.Player_PlaceHand
	or card_place==sgs.Player_PlaceEquip
	then
		local usereason = sgs.Sanguosha:getCurrentCardUseReason()
    	if card:isBlack()
		and usereason==sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
    	then return ("jink:qingguo[no_suit:0]="..card:getEffectiveId()) end
	end
end

sgs.ai_skill_cardask.bf_tieji0 = function(self,data,pattern)
	local player = self.player
	local cards = player:getCards("he")
	cards = sgs.QList2Table(cards)
    self:sortByKeepValue(cards) -- 按保留值排序
   	for _,c in sgs.list(cards)do
    	if sgs.Sanguosha:matchExpPattern(pattern,player,c)
		then
			if self:getCardsNum("Jink","he")<1
			or (c:isKindOf("Jink") and self:getCardsNum("Jink","he")<2)
			then continue end
			return c:getEffectiveId()
		end
	end
    return "."
end

sgs.ai_use_revises.bf_wumou = function(self,card,use)
	local player = self.player
	if card:isKindOf("TrickCard")
	and player:getMark("@wrath")>0
	and player:getMark("@wrath")<=player:getHp()/2
	then return false end
end

sgs.ai_nullification.bf_wumou = function(self,trick,from,to,positive)
    if self.player:getMark("@wrath")<=self.player:getHp()/2
	and player:getMark("@wrath")>0
	then return false end
end

sgs.ai_use_revises.bf_wuqian = function(self,card,use)
	local player = self.player
	if card:isKindOf("Slash")
	and player:hasFlag("bf_wuqian")
	then
		local x = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,player,card)
		for _,ep in sgs.list(self.enemies)do
			if player:canSlash(ep,card)
			then
				card:setFlags("Qinggang") --添加青釭标志，后续决策时此牌视为无视防具
				use.card = card
				if use.to
				and use.to:length()<=x
				and not use.to:contains(ep)
				then use.to:append(ep) end
			end
		end
	end
end

sgs.ai_skill_invoke.bf_wuqian = function(self,data)
	local player = self.player
	for _,ep in sgs.list(self.enemies)do
		if player:canSlash(ep)
		and self:isWeak(ep)
		and player:getMark("@wrath")>2
		and self:getCardsNum("Slash","h")>0
		then return true end
	end
end

sgs.ai_skill_cardask.bf_shenfen = function(self,data,pattern,prompt)
	local player = self.player
    local parsed = prompt:split(":")
    if not self:isWeak(player)
	and player:hasSkill("bf_kuangbao")
	then
    	if parsed[1]=="slash-jink"
		then
	    	parsed = data:toSlashEffect()
			if self:canLoseHp(parsed.from,parsed.slash)
			then return false end
		else
	    	parsed = data:toCardEffect()
			local card = parsed.card
			if card and card:isDamageCard()
			and self:canLoseHp(parsed.from,parsed.card)
			then return false end
		end
	end
end

sgs.ai_use_revises.bf_keji = function(self,card,use)
	local player = self.player
	if player:hasFlag("bf_keji")
	or card:isKindOf("Armor")
	or card:isKindOf("DefensiveHorse")
	or card:getTypeId()==0 and card:subcardsLength()<1
	then return
	elseif card:isKindOf("Crossbow")
	then return self:getCardsNum("Slash","h")>player:getHp()
	elseif card:isKindOf("Slash")
	then
		for _,ep in sgs.list(self.enemies)do
			if player:canSlash(ep,card)
			and self:getCardsNum("Slash","h")>ep:getHp()
			and player:hasWeapon("crossbow")
			then return end
		end
	elseif card:isKindOf("Snatch")
	then
		if player:hasWeapon("crossbow")
		then return end
		for i,p in sgs.list(self.room:getOtherPlayers(player))do
			if p:hasWeapon("crossbow")
			then
				if CanToCard(card,player,p,use.to)
				then
					use.card = card
					if use.to then use.to:append(p) end
					return true
				else
					i = self:getCard("OffensiveHorse")
					if i then use.card = i return true
					else
						card = self:getCard("Dismantlement") or card
						return
					end
				end
			end
		end
	elseif card:isKindOf("Collateral")
	then
		if player:hasWeapon("crossbow")
		then return end
		for i,p in sgs.list(self.room:getOtherPlayers(player))do
			if p:hasWeapon("crossbow")
			and CanToCard(card,player,p,use.to)
			then
				for _,ep in sgs.list(self.enemies)do
					if p:canSlash(ep)
					then
						use.card = card
						if use.to
						then
							use.to:append(p)
							use.to:append(ep)
						end
						return true
					end
				end
				for _,ep in sgs.list(self.room:getOtherPlayers(p))do
					if p:canSlash(ep)
					then
						use.card = card
						if use.to
						then
							use.to:append(p)
							use.to:append(ep)
						end
						return true
					end
				end
			end
		end
	elseif card:isDamageCard()
	and player:getHandcardNum()>10
	then return
	elseif not card:isKindOf("Slash")
	and self:getCardsNum("Slash","h")>8
	then return end
	return false
end

sgs.card_value.bf_keji = {
	Slash = 5.9,
}

sgs.ai_skill_playerchosen.bf_shaoying = function(self,players)
	local player = self.player
	local destlist,a = players,false
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
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

sgs.ai_skill_cardask.bf_ganglie = function(self,data,pattern)
    local to = data:toPlayer()
	local player = self.player
	local cards = player:getCards("he")
	cards = sgs.QList2Table(cards)
    self:sortByKeepValue(cards) -- 按保留值排序
   	for _,c in sgs.list(cards)do
    	if sgs.Sanguosha:matchExpPattern(pattern,player,c)
		then
			if not self:isFriend(to)
			and not self:isWeak(to)
			then return c:getEffectiveId() end
			if self:isEnemy(to)
			then return c:getEffectiveId() end
		end
	end
    return "."
end

sgs.ai_use_revises.bf_xiaoji = function(self,card,use)
	local player = self.player
	if card:isKindOf("EquipCard")
	then use.card = card end
end

sgs.ai_skill_cardchosen.bf_qingnang = function(self,who,flags,method)
	if self.bf_qn
	then
		local bf_qn = self.bf_qn
		self.bf_qn = nil
		return bf_qn
	end
end

sgs.ai_useto_revises.bf_qingnang = function(self,card,use,to)--卡牌对场上某张牌的使用修正
	local player = self.player
	if self:isFriend(to)
	and not self.bf_qn
	and card:isBlack()
	and player:isWounded()
	and player:getHandcardNum()==1
	then
		self.bf_qn = card
		self.player:speak("神医救我啊")
		return false
	end
end

sgs.ai_skill_invoke.wushuang = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return not self:isFriend(to)
end

sgs.ai_skill_invoke.bf_wangzun = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return not self:isFriend(to)
	or to:getMaxCards()>2
end

sgs.ai_skill_invoke.bf_tongji = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return not self:isFriend(to)
	or to:getHp()>=player:getHp()
end

sgs.ai_skill_invoke.bf_qiaomeng = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return not self:isFriend(to)
end

sgs.ai_skill_use["@@bf_quanxue"] = function(self,prompt)
	local valid = {}
	local player = self.player
	local cards = sgs.QList2Table(self.player:getCards("he"))
    self:sortByKeepValue(cards) -- 按保留值排序
	local destlist = player:getAliveSiblings()
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	local can = true
	for _,fp in sgs.list(destlist)do
		if #valid>=#cards
		then break end
		if fp:getMark("&bf_xue+#"..player:objectName())>0
		then can = false end
		if self:isFriend(fp)
		and fp:getMark("&bf_xue+#"..player:objectName())<1
		then table.insert(valid,fp:objectName()) end
	end
	if can
	and #valid<1
	then
		for _,fp in sgs.list(destlist)do
			if #valid>=1
			then break end
			if fp:getMark("&bf_xue+#"..player:objectName())<1
			then table.insert(valid,fp:objectName()) end
		end
	end
	local give = {}
	for _,c in sgs.list(cards)do
		if #give>=#valid then break end
		table.insert(give,c:getEffectiveId())
	end
	return #valid>0 and string.format("#bf_quanxueCard:%s:->%s",table.concat(give,"+"),table.concat(valid,"+"))
end

sgs.ai_skill_playerchosen.bf_shehu = function(self,players)
	local player = self.player
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
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

sgs.ai_skill_use["@@bf_dingli"] = function(self,prompt)
	local valid = nil
	local player = self.player
	local cards = sgs.QList2Table(self.player:getCards("he"))
    self:sortByKeepValue(cards) -- 按保留值排序
	local destlist = player:getAliveSiblings()
	destlist:append(player)
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	for _,fp in sgs.list(destlist)do
		if self:isFriend(fp) and self:isWeak(fp)
		then valid = fp break end
	end
    self:sort(destlist,"handcard")
	for _,fp in sgs.list(destlist)do
		if self:isFriend(fp) and valid==nil
		then valid = fp break end
	end
	if valid==nil
	then return end
	local give = {}
	for _,c in sgs.list(cards)do
		if #give>=2 then break end
		if self:isWeak(valid)
		then
			table.insert(give,c:getEffectiveId())
		end
	end
	return string.format("#bf_dingliCard:%s:->%s",table.concat(give,"+"),valid:objectName())
end

sgs.ai_skill_invoke.bf_dingli = function(self,data)
    return true
end

--[[
sgs.ai_skill_invoke.shensu = function(self,data)
	local player = self.player
	local cards = sgs.QList2Table(player:getCards("he"))
	self:sortByKeepValue(cards)
	self.shensu_slash = nil
	for _,c in sgs.list(cards)do
		if c:getTypeId()~=3
		then continue end
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:setSkillName("_shensu")
		slash:addSubcard(c)
		slash = self:aiUseCard(slash)
		self.shensu_slash = slash
		if slash.card and slash.to
		then return true end
	end
end
--]]
sgs.ai_skill_use["@@bf_shensu"] = function(self,prompt)
	if self.player:getPhase()==sgs.Player_Draw
	and self:getCardsNum("Slash")>0 then return end
	local give = {}
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	for _,c in sgs.list(cards)do
		if c:getTypeId()~=3 then continue end
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:setSkillName("shensu")
		slash:addSubcard(c)
		local dummy = self:aiUseCard(slash)
		if dummy.card and dummy.to
		then
			for _,ep in sgs.list(dummy.to)do
				table.insert(give,ep:objectName())
			end
			return slash:toString().."->"..table.concat(give,"+")
		end
		slash:deleteLater()
	end
end

sgs.ai_skill_invoke.bf_juushou = function(self,data)
	local player = self.player
	local x = 1
	for _,fp in sgs.list(sgs.QList2Table(player:getAliveSiblings()))do
		if fp:getHp()>=player:getHp()
		then x = x+1 end
		if x>player:getAliveSiblings():length()
		or x>2 and self:isWeak()
		then return true end
	end
	return not player:faceUp()
end

sgs.ai_skill_cardask.bf_juushou = function(self,data,pattern,prompt)
	local player = self.player
    local parsed = prompt:split(":")
    if not self:isWeak(player)
	then
    	if parsed[1]=="slash-jink"
		then
	    	parsed = data:toSlashEffect()
			if self:canLoseHp(parsed.from,parsed.slash)
			then return false end
		else
	    	parsed = data:toCardEffect()
			local card = parsed.card
			if card and card:isDamageCard()
			and self:canLoseHp(parsed.from,parsed.card)
			then return false end
		end
	end
end

sgs.ai_skill_invoke.kuanggu = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return true
end

sgs.ai_skill_invoke.bf_kuanggu0 = function(self,data)
	local player = self.player
    return player:isWounded()
end

sgs.ai_skill_cardask.bf_yiji = function(self,data,pattern,prompt)
	local player = self.player
    local parsed = prompt:split(":")
    if not self:isWeak(player)
	then
    	if parsed[1]=="slash-jink"
		then
	    	parsed = data:toSlashEffect()
			if self:canLoseHp(parsed.from,parsed.slash)
			then return false end
		else
	    	parsed = data:toCardEffect()
			local card = parsed.card
			if card and card:isDamageCard()
			and self:canLoseHp(parsed.from,parsed.card)
			then return false end
		end
	end
end

sgs.ai_skill_cardask.bf_fangzhu = function(self,data,pattern,prompt)
	local player = self.player
    local parsed = prompt:split(":")
    if not self:isWeak(player)
	then
    	if parsed[1]=="slash-jink"
		then
	    	parsed = data:toSlashEffect()
			if self:canLoseHp(parsed.from,parsed.slash)
			and self:isEnemy(parsed.from)
			and parsed.from:faceUp()
			then return false end
		else
	    	parsed = data:toCardEffect()
			local card = parsed.card
			if card and card:isDamageCard()
			and self:canLoseHp(parsed.from,parsed.card)
			and self:isEnemy(parsed.from)
			and parsed.from:faceUp()
			then return false end
		end
	end
end

sgs.ai_skill_use["@@bf_tianxiang"] = function(self,prompt)
	local valid
	local player = self.player
	local cards = sgs.QList2Table(player:getCards("h"))
    self:sortByKeepValue(cards) -- 按保留值排序
	local destlist = player:getAliveSiblings()
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	for _,fp in sgs.list(destlist)do
		if valid then break end
		if self:isEnemy(fp) and self:isWeak(fp)
		and fp:getHp()>=player:getHp()
		then valid = fp:objectName() end
	end
	for _,fp in sgs.list(destlist)do
		if valid then break end
		if self:isEnemy(fp)
		and fp:getHp()>=player:getHp()
		then valid = fp:objectName() end
	end
	for _,fp in sgs.list(destlist)do
		if valid then break end
		if self:isFriend(fp) and not self:isWeak(fp)
		and fp:getHp()>=player:getHp()
		then valid = fp:objectName() end
	end
	for _,fp in sgs.list(destlist)do
		if valid then break end
		if not self:isFriend(fp)
		and fp:getHp()>=player:getHp()
		then valid = fp:objectName() end
	end
	local give
	for _,c in sgs.list(cards)do
		if give then break end
		if c:getSuit()==2
		then give = c:getEffectiveId() end
	end
	return valid and give and string.format("#bf_tianxiangCard:%s:->%s",give,valid)
end

sgs.card_value.bf_tianxiang = {
	heart = 4.9,
}

sgs.ai_skill_cardask.bf_tianxiang = function(self,data,pattern,prompt)
	local player = self.player
    local parsed,can = prompt:split(":"),true
   	if parsed[1]=="slash-jink"
	then
	   	parsed = data:toSlashEffect()
		if self:canLoseHp(parsed.from,parsed.slash)
		then can = false end
	else
	   	parsed = data:toCardEffect()
		if parsed.card and parsed.card:isDamageCard()
		and self:canLoseHp(parsed.from,parsed.card)
		then can = false end
	end
	parsed = nil
	for _,c in sgs.list(player:getCards("h"))do
		if c:getSuit()==2 then parsed = c end
	end
	for _,ep in sgs.list(self.enemies)do
		if self:isWeak(ep)
		then return can end
	end
end

sgs.ai_skill_playerchosen.bf_leiji = function(self,players)
	local player = self.player
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
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

sgs.ai_use_revises.bf_huangtianVS = function(self,card,use)
	local player = self.player
	if card:isKindOf("Slash")
	then
		local tos = sgs.QList2Table(self.room:getOtherPlayers(player))
		for _,ep in sgs.list(tos)do
			if player:canSlash(ep,card)
			and self:isFriend(ep)
			and (self.bf_huangtian_c and self.bf_huangtian_c:isKindOf("Jink") or ep:getHandcardNum()>2)
			and ep:hasLordSkill("bf_huangtian")
			and ep:hasSkill("bf_leiji")
			then
				use.card = card
				self.bf_huangtian_c = nil
				if use.to then use.to:append(ep) end
				return true
			end
		end
	end
end

sgs.ai_useto_revises.bf_leiji = function(self,card,use,to)
	local player = self.player
	if card:isKindOf("Slash")
	then
		if player:canSlash(to,card)
		and self:isFriend(to,player)
		and to:getHandcardNum()>2
		then
			use.card = card
			if use.to then use.to:append(to) end
			return true
		end
	end
end

sgs.card_value.bf_leiji = {
	Jink = 3.9,
}

sgs.ai_skill_use["@@bf_tianxing!"] = function(self,prompt)
	local player = self.player
	local cards = sgs.QList2Table(player:getCards("h"))
    self:sortByKeepValue(cards) -- 按保留值排序
	if player:hasFlag("luanji")
	then
		for i,c in sgs.list(cards)do
			for ii,cc in sgs.list(cards)do
				if i~=ii
				and c:getSuit()==cc:getSuit()
				then
					i = sgs.Sanguosha:cloneCard("archery_attack")
					i:addSubcard(c)
					i:addSubcard(cc)
					i:setSkillName("luanji")
					return i:isAvailable(player) and i:toString()
				end
			end
		end
	elseif player:hasFlag("nosrende")
	then
		local valid
		local destlist = player:getAliveSiblings()
		destlist = sgs.QList2Table(destlist) -- 将列表转换为表
		self:sort(destlist,"hp")
		for _,fp in sgs.list(destlist)do
			if valid then break end
			if self:isFriend(fp)
			and self:isWeak(fp)
			then valid = fp end
		end
		self:sort(destlist,"handcard")
		for _,fp in sgs.list(destlist)do
			if valid then break end
			if self:isFriend(fp)
			then valid = fp end
		end
		for _,fp in sgs.list(destlist)do
			if valid then break end
			if not self:isEnemy(fp)
			then valid = fp end
		end
		local give = {}
		for i,c in sgs.list(cards)do
			if math.mod(i,2)==1
			then table.insert(give,c:getEffectiveId()) end
		end
		valid = valid or destlist[1]
		return #give>0 and string.format("#nosrendeCard:%s:->%s",table.concat(give,"+"),valid:objectName())
	elseif player:hasFlag("zhiheng")
	then
		cards = sgs.QList2Table(player:getCards("he"))
		self:sortByKeepValue(cards) -- 按保留值排序
		local give = {}
		for _,c in sgs.list(cards)do
			if #give>=#cards/2
			then break end
			table.insert(give,c:getEffectiveId())
		end
		return #give>0 and string.format("#bf_jilveCard:%s:",table.concat(give,"+"))
	end
end

sgs.ai_skill_cardask.nosjianxiong = function(self,data,pattern,prompt)
    local parsed = prompt:split(":")
    if not self:isWeak()
--	and not self.player:isWounded()
	then
    	if parsed[1]=="slash-jink"
		then
	    	parsed = data:toSlashEffect()
			if self:canLoseHp(parsed.from,parsed.slash)
			then return false end
		else
	    	parsed = data:toCardEffect()
			local card = parsed.card
			if card and card:isDamageCard()
			and self:canLoseHp(parsed.from,parsed.card)
			then return false end
		end
	end
end

sgs.ai_skill_use["@@bf_jieming"] = function(self,prompt)
	local valid
	local player = self.player
	local cards = sgs.QList2Table(player:getCards("he"))
    self:sortByKeepValue(cards) -- 按保留值排序
	local destlist = player:getAliveSiblings()
	destlist:append(player)
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"handcard")
	for _,fp in sgs.list(destlist)do
		if valid then break end
		if self:isFriend(fp)
		and fp:getHandcardNum()<5
		and fp:getHandcardNum()<fp:getMaxHp()
		then valid = fp:objectName() end
	end
	valid = valid or player:objectName()
	return valid and #cards>0 and string.format("#bf_jiemingCard:%s:->%s",cards[1]:getEffectiveId(),valid)
end

sgs.ai_skill_cardask.bf_jieming = function(self,data,pattern,prompt)
	local player = self.player
	local destlist = player:getAliveSiblings()
	destlist:append(player)
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"handcard")
	local valid
	for _,fp in sgs.list(destlist)do
		if valid then break end
		if self:isFriend(fp)
		and fp:getHandcardNum()<5
		and fp:getHandcardNum()<fp:getMaxHp()
		then valid = fp:objectName() end
	end
	if player:getCardCount()>0
	and valid
	then
		return sgs.ai_skill_cardask.bf_yiji(self,data,pattern,prompt)
	end
end

sgs.ai_skill_invoke.bf_mengjin = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return self:isEnemy(to)
	and to:getHandcardNum()<3
	and player:getHp()>1
end

sgs.ai_nullification.bf_huoshou = function(self,trick,from,to,positive)
    if trick:isKindOf("SavageAssault")
	then return false end
end

sgs.ai_nullification.bf_juxiang = function(self,trick,from,to,positive)
    if trick:isKindOf("SavageAssault")
	and self:isFriend(to)
	then return false end
end

sgs.ai_skill_invoke.bf_lieren = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return not self:isFriend(to)
end

sgs.ai_skill_playerchosen.bf_yinghun = function(self,players)
	local player = self.player
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		then
	    	if target:getHandcardNum()<player:getHp()
			and player:getHp()>=player:getLostHp()
			then
	    		self.bf_yinghun_bool = true
				return target
			elseif target:getHandcardNum()<player:getLostHp()
			then
	    		self.bf_yinghun_bool = false
				return target
			end
		end
	end
    for _,target in sgs.list(destlist)do
    	if self:isEnemy(target)
		then
	    	if target:getHandcardNum()>player:getHp()
			and player:getHp()<=player:getLostHp()
			then
	    		self.bf_yinghun_bool = true
				return target
			elseif target:getHandcardNum()>player:getLostHp()
			then
	    		self.bf_yinghun_bool = false
				return target
			end
		end
	end
end

sgs.ai_skill_invoke.bf_yinghun = function(self,data)
	local player = self.player
    return self.bf_yinghun_bool
end

sgs.ai_skill_invoke.bf_haoshi = function(self,data)
	local player = self.player
	local players = player:getAliveSiblings()
	local least = 1000
	for _,p in sgs.list(players)do
		least = math.min(p:getHandcardNum(),least)
	end
	for _,p in sgs.list(players)do
		if p:getHandcardNum()==least
		then
			self.bf_hs_p = p
			if not self:isEnemy(p)
			then return true end
		end
	end
	return player:hasSkill("bf_dimeng")
	and players:length()>1
end

sgs.ai_skill_use["@@bf_haoshi!"] = function(self,prompt)
	local valid,to = {},self.bf_hs_p
	local player = self.player
	local cards = sgs.QList2Table(player:getCards("h"))
    self:sortByKeepValue(cards) -- 按保留值排序
	for i,c in sgs.list(cards)do
		if #valid>1 then break end
		if self:isFriend(to)
		then
			if math.mod(i,2)==1
			then table.insert(valid,c:getEffectiveId()) end
		else
			table.insert(valid,c:getEffectiveId())
		end
	end
	return #valid>1 and string.format("#bf_haoshiCard:%s:->%s",table.concat(valid,"+"),to:objectName())
end

sgs.ai_skill_invoke.bf_baonue = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return self:isFriend(to)
	and player:getCardCount()>1
	and to:isWounded()
end

sgs.ai_use_revises.bf_weimu = function(self,card,use)
	local player = self.player
	if card:isKindOf("Lightning")
	and card:isBlack()
	then
		for _,ep in sgs.list(self.friends_noself)do
			if self:isWeak(ep)
			then return end
		end
		use.card = card
	end
end

sgs.ai_skill_cardask.bf_qiaobian_c = function(self,data)
	local player = self.player
	local cards = sgs.QList2Table(player:getCards("h"))
	self:sortByKeepValue(cards)
	local change = data:toPhaseChange()
	change = change.to
	self.bfqb_tos = {}
	self.bfqb_tos.id = "."
	self.bfqb_tos.to = {}
	self:sort(self.friends,"hp")
	self:sort(self.enemies,"hp")
	for _,fp in sgs.list(self.friends)do
		local js = sgs.QList2Table(fp:getCards("j"))
		self:sortByKeepValue(js,true)
		for _,j in sgs.list(js)do
			for _,ep in sgs.list(self.enemies)do
				if player:isProhibited(ep,j)
				or ep:containsTrick(j:objectName())
				or change~=2
				then continue end
				self.bfqb_tos.id = j:getEffectiveId()
				self.bfqb_tos.to = {ep:objectName()}
				if self:isWeak(fp) or #cards>2
				then return cards[1] end
			end
		end
	end
	for _,ep in sgs.list(self.enemies)do
		for _,fp in sgs.list(self.friends)do
			self.bfqb_tos.to = {fp:objectName(),ep:objectName()}
			if ep:getHandcardNum()==1 and change==3
			then return cards[1] end
		end
	end
	for _,ep in sgs.list(self.enemies)do
		local es = sgs.QList2Table(ep:getCards("e"))
		self:sortByKeepValue(es,true)
		for i,e in sgs.list(es)do
			i = e:getRealCard():toEquipCard():location()
			for _,fp in sgs.list(self.friends)do
				if fp:getEquip(i)
				or change~=4
				then continue end
				self.bfqb_tos.id = e:getEffectiveId()
				self.bfqb_tos.to = {fp:objectName()}
				return cards[1]
			end
		end
	end
	local tos = sgs.QList2Table(self.room:getOtherPlayers(player))
	for _,ep in sgs.list(tos)do
		if not self:isFriend(ep)
		then
			self.bfqb_tos.to = {ep:objectName()}
			break
		end
	end
	for _,ep in sgs.list(tos)do
		if self:isEnemy(ep)
		then
			self.bfqb_tos.to = {ep:objectName()}
			break
		end
	end
	if change==5
	and player:getHandcardNum()>player:getMaxCards()
	then return cards[1] end
	return "."
end

sgs.ai_skill_use["@@bf_qiaobian"] = function(self,prompt)
	return string.format("#bf_qiaobianCard:%s:->%s",self.bfqb_tos.id,table.concat(self.bfqb_tos.to,"+"))
end

sgs.ai_skill_invoke.nostuxi = function(self,data)
	local player = self.player
	for _,ep in sgs.list(self.enemies)do
		if ep:getCardCount()>0
		then return true end
	end
end

sgs.ai_target_revises.bf_xiangle = function(to,card,self)
    if card:isKindOf("Slash")
	then
		return self:getCardsNum("BasicCard","h")<2
	end
end

sgs.ai_skill_use["@@bf_fangquan"] = function(self,prompt)
	local to,cid = nil,nil
	local player = self.player
	local cards = sgs.QList2Table(player:getCards("h"))
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,c in sgs.list(cards)do
		if cid then break end
		if c:isDamageCard()
		then
			cid = c:getEffectiveId()
			break
		end
	end
	local destlist = player:getAliveSiblings()
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"handcard",true)
	for _,fp in sgs.list(destlist)do
		if to then break end
		if self:isFriend(fp)
		and fp:getHandcardNum()>2
		then to = fp:objectName() end
	end
	return not self:isWeak()
	and cid and to
	and #self.enemies>0
	and string.format("#bf_fangquancard:%s:->%s",cid,to)
end

sgs.ai_skill_invoke.bf_zhiba = function(self,data)
	local player = self.player
	local items = data:toString():split(":")
    local to = self.room:findPlayerByObjectName(items[2])
    return self:isEnemy(to)
end

sgs.ai_skill_pindian.bf_zhiba = function(minusecard,self,to,maxcard,mincard)
	return maxcard and maxcard:getEffectiveId()
end

sgs.ai_skill_invoke.bf_guzheng = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return not self:isEnemy(to)
end

sgs.ai_skill_cardask.bf_beige0 = function(self,data,pattern)
	local player = self.player
	local cards = player:getCards("he")
	cards = sgs.QList2Table(cards)
    self:sortByKeepValue(cards) -- 按保留值排序
	local damage = data:toDamage()
   	for _,c in sgs.list(cards)do
    	if sgs.Sanguosha:matchExpPattern(pattern,player,c)
		then
			if self:isFriend(damage.to)
			then
				if damage.from
				then
					return not self:isFriend(damage.from) and c:getEffectiveId() or "."
				end
				return c:getEffectiveId()
			end
		end
	end
    return "."
end

sgs.ai_skill_invoke.bf_huashen = function(self,data)
	local player = self.player
    return true
end

sgs.ai_skill_choice.bf_huashen = function(self,choices,data)
	local player = self.player
	local items = choices:split("+")
	if table.contains(items,"bf_huashen2")
	then
		local skill_names = {}
		local Huashens = player:getTag("bf_huashenGenerals"):toString()
		for _,g_n in sgs.list(Huashens:split("+"))do
			g_n = sgs.Sanguosha:getGeneral(g_n)
			for _,skill in sgs.list(g_n:getVisibleSkillList())do
				if skill:isLordSkill() and not player:isLord()
				or table.contains(skill_names,skill:objectName())
				then continue end
				table.insert(skill_names,skill:objectName())
			end
		end
		Huashens = sgs.ai_skill_choice.huashen(self,table.concat(skill_names,"+"),data)
		if Huashens and player:hasSkill(Huashens)
		then return "bf_huashen1" end
		return "bf_huashen2"
	end
end

sgs.ai_skill_invoke.bf_wanglie = function(self,data)
	local player = self.player
	local c = player:getTag("bf_wanglie"):toCard()
    return c:isDamageCard() and c:objectName()~="fire_attack"
end

sgs.ai_skill_invoke.bf_zuilun = function(self,data)
	local player = self.player
	local n = 0
	if player:getMark("bf_zuilun_damage-Clear")>0
	then n = n+1 end
	if player:getMark("bf_zuilun_discard-Clear")<1
	then n = n+1 end
	local can = true
    for _,p in sgs.list(self.room:getAlivePlayers())do
		if p:getHandcardNum()<player:getHandcardNum()
		then can = false break end
	end
	if can then n = n+1 end
    return n>0 or player:getHp()>1
end

sgs.ai_skill_playerchosen.bf_zuilun = function(self,players)
	local player = self.player
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
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

sgs.ai_skill_playerchosen.bf_liangyin = function(self,players)
	local player = self.player
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
    	if self:isEnemy(target)
		and target:getHp()<player:getHp()
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isFriend(target)
		and target:getHp()<player:getHp()
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		and target:getHp()>player:getHp()
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isEnemy(target)
		and target:getHp()>player:getHp()
		then return target end
	end
end

sgs.ai_skill_use["@@bf_konglv"] = function(self,prompt)
	local valid,tocs = {},{}
	local player = self.player
	local cards = sgs.QList2Table(player:getCards("h"))
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,c in sgs.list(cards)do
		if tocs[c:objectName()]
		then continue end
		tocs[c:objectName()]=true
		if c:isAvailable(player)
		then
			table.insert(valid,c:getEffectiveId())
		end
	end
	if player:getPhase()==sgs.Player_Finish
	then
		cards = {}
		for _,id in sgs.list(sgs.QList2Table(player:getPile("bf_konglv")))do
			table.insert(cards,sgs.Sanguosha:getCard(id))
		end
		self:sortByKeepValue(cards)
		for i,c in sgs.list(cards)do
	    	if c:isAvailable(player)
			then
		    	i = sgs.ai_skill_use[c:toString()](self,prompt)
				if i then return i end
			end
		end
	else
		if #valid<1 and #cards>0
		then
			table.insert(valid,cards[1]:getEffectiveId())
		end
		return #valid>0 and string.format("#bf_konglvCard:%s:",table.concat(valid,"+"))
	end
end

sgs.ai_skill_choice.bf_jueyan = function(self,choices,data)
	local player = self.player
	local items = choices:split("+")
	return self.bf_jueyan_choice
end

sgs.ai_skill_playerchosen.bf_zhengu = function(self,players)
	local player = self.player
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"handcard",true)
    for _,target in sgs.list(destlist)do
    	if self:isEnemy(target)
		and target:getHandcardNum()>=player:getHandcardNum()
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isEnemy(target)
		then return target end
	end
end

sgs.ai_skill_invoke.bf_zhengrong = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return not self:isFriend(to)
end

sgs.ai_skill_askforyiji.bf_weidi = function(self,card_ids)
	local player = self.player
	for _,p in sgs.list(self.room:getOtherPlayers(player))do
	   	if p:getKingdom()~="qun"
		or p:hasFlag("no_bf_weidi")
		or self:isEnemy(p)
		then continue end
		return p,card_ids[1]
	end
end

sgs.ai_skill_askforyiji.bf_congjian = function(self,card_ids)
	local player = self.player
	local targets = player:getTag("bf_congjian"):toCardUse().to
	targets:removeOne(player)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards,true)
    targets = sgs.QList2Table(targets) -- 将列表转换为表
	self:sort(targets,"handcard")
	for _,p in sgs.list(targets)do
	   	if self:isFriend(p)
		then return p,cards[1]:getEffectiveId() end
	end
end

sgs.ai_use_revises.bf_tuntian = function(self,card,use)
	local player = self.player
	if player:getHandcardNum()-player:getMaxCards()==1
	and player:getHandcards():contains(card)
	then return false end
end

sgs.ai_skill_discard.bf_juzhan = function(self)
    local player = self.player
	local to_discard = {}
	local cards = player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if #cards>0
	then
    	if player:hasSkill("bf_juzhan")
		then
			for _,c in sgs.list(cards)do
				if #cards>1
				and #to_discard<1
				and c:objectName()~="jink"
				then
					table.insert(to_discard,cards[1]:getEffectiveId())
				end
			end
		else
			table.insert(to_discard,cards[1]:getEffectiveId())
		end
	end
	return to_discard
end

sgs.ai_skill_playerchosen.bf_weili = function(self,players)
	local player = self.player
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,to in sgs.list(destlist)do
    	if self:isFriend(to)
		and self:isWeak(to)
		and to:getHandcardNum()+to:getPile("wooden_ox"):length()<2
		then return to end
	end
end

sgs.ai_skill_invoke.bf_weili = function(self,data)
	local player = self.player
	local items = data:toString():split(":")
    local to = self.room:findPlayerByObjectName(items[2])
    return not self:isEnemy(to)
end

sgs.ai_skill_invoke.bf_zhenglun = function(self,data)
	local player = self.player
    return self:isWeak() or player:getHandcardNum()>2
end

sgs.ai_skill_use["@@bf_kuizhu"] = function(self,prompt)
	local player = self.player
	local valid,n = {},player:getMark("bf_kuizhu")
	local players = sgs.QList2Table(self.room:getAlivePlayers())
	self:sort(players,"hp")
	local x,cans = 0,{}
	local kuizhuTargets = function()
		local tos = {}
		for _,p in sgs.list(players)do
	    	if table.contains(cans,p:objectName())
			then continue end
			table.insert(tos,p)
		end
		return tos
	end
	for _,p in sgs.list(players)do
		cans = {}
		x = p:getHp()
		if self:isEnemy(p)
		and x<=n
		then
			table.insert(cans,p:objectName())
			for i=0,n do
				for _,to in sgs.list(kuizhuTargets())do
					x = x+p:getHp()
					if self:isEnemy(p)
					and x<=n
					then
						table.insert(cans,to:objectName())
					end
				end
			end
			if x==n
			then
				return #cans>0 and string.format("#bf_kuizhuCard:.:->%s",table.concat(cans,"+"))
			end
		end
	end
	for _,p in sgs.list(players)do
		cans = {}
		x = p:getHp()
		if not self:isFriend(p)
		and x<=n
		then
			table.insert(cans,p:objectName())
			for i=0,n do
				for _,to in sgs.list(kuizhuTargets())do
					x = x+p:getHp()
					if not self:isFriend(to)
					and x<=n
					then
						table.insert(cans,to:objectName())
					end
				end
			end
			if x==n
			then
				return #cans>0 and string.format("#bf_kuizhuCard:.:->%s",table.concat(cans,"+"))
			end
		end
	end
	for _,p in sgs.list(players)do
		if #valid>=n then continue end
		if self:isFriend(p) then table.insert(valid,p:objectName()) end
	end
	for _,p in sgs.list(players)do
		if table.contains(valid,p:objectName())
		or #valid>=n
		then continue end
		if not self:isEnemy(p) then table.insert(valid,p:objectName()) end
	end
	return #valid>1 and #valid==n and string.format("#bf_kuizhuCard:.:->%s",table.concat(valid,"+"))
end

sgs.ai_skill_cardask.bf_feijun0 = function(self,data,pattern)
	local player = self.player
	local cards = sgs.QList2Table(player:getCards("he"))
    self:sortByKeepValue(cards) -- 按保留值排序
   	for _,c in sgs.list(cards)do
    	if sgs.Sanguosha:matchExpPattern(pattern,player,c)
		then return c:getEffectiveId() end
	end
    return "."
end

sgs.ai_skill_playerchosen.bf_qizhi = function(self,players)
	local player = self.player
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
    	if self:isEnemy(target)
		and target:hasEquip()
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isFriend(target)
		and target:getHp()<=player:getHp()
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		and target:getHp()>=player:getHp()
		then return target end
	end
end

sgs.ai_skill_invoke.bf_jinqu = function(self,data)
	local player = self.player
	local n = math.min(player:getMaxHp(),player:getMark("&bf_jinqu-Clear"))
    return n>player:getHandcardNum()
end

sgs.ai_skill_playerchosen.bf_jianxiang = function(self,players)
	local player = self.player
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isEnemy(target)
		then return target end
	end
end

sgs.ai_skill_playerchosen.bf_shenshi = function(self,players)
	local player = self.player
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		and target:getHandcardNum()<3
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if self:isEnemy(target)
		and target:getHandcardNum()>3
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isEnemy(target)
		and target:getHandcardNum()<3
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isFriend(target)
		then return target end
	end
	return destlist[1]
end

sgs.ai_skill_invoke.bf_shenshi = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return player:getHandcardNum()<4
end

sgs.ai_skill_invoke.bf_mingren = function(self,data)
	local player = self.player
    return true
end

sgs.ai_skill_discard.bf_mingren = function(self,x,n,can)
    local player = self.player
	local discards = {}
	local cards = player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if #cards>0
	then
    	local bf_ren = player:getPile("bf_ren")
		if bf_ren:length()>0
		then
			for _,c in sgs.list(cards)do
				if player:getPhase()>5
				then
					for _,tc in sgs.list(bf_ren)do
						tc = sgs.Sanguosha:getCard(tc)
						if tc:isKindOf("BasicCard") and c:isKindOf("BasicCard")
						or tc:isKindOf("TrickCard") and c:isKindOf("TrickCard")
						then return {} end
					end
					if c:isKindOf("BasicCard") or c:isKindOf("TrickCard")
					then return {c:getEffectiveId()} end
				else
					for _,tc in sgs.list(bf_ren)do
						tc = sgs.Sanguosha:getCard(tc)
						if self:getKeepValue(c)<=self:getKeepValue(tc)
						then return {c:getEffectiveId()} end
					end
				end
			end
		else
			table.insert(discards,cards[1]:getEffectiveId())
		end
	end
	return discards
end

sgs.ai_skill_playerchosen.bf_zhenliang = function(self,players)
	local player = self.player
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isEnemy(target)
		then return target end
	end
end

sgs.ai_skill_invoke.bf_shicai = function(self,data)
	local player = self.player
	local items = data:toString():split(":")
    return true
end

sgs.ai_card_priority.bf_chenglve = function(self,card)
	if self.player:getMark(card:getSuitString().."bf_chenglve-PlayClear")>0
	then return 0.4 end
end

sgs.ai_skill_invoke.bf_mengyanchitu = function(self,data)
	local player = self.player
	local to = data:toPlayer()
	if self:isFriend(to)
	then
		if self:isWeak(to) and not self:isWeak()
		then return true end
		return self:isWeak(to) and self:getCardsNum("Jink")>0
	end
	if player:hasSkills("wuhun|bf_wuhun")
	and not self:isEnemy(to)
	then return true end
end

sgs.ai_skill_use["@@bf_shengyi"] = function(self,prompt)
	local c = sgs.Sanguosha:getCard(self.bf_shengyi_id)
	return sgs.ai_skill_use[c:toString()](self,prompt)
end

sgs.ai_skill_cardask.bf_zhenhunqin1 = function(self,data,pattern)
	local player = self.player
	local cards = player:getCards("h")
	cards = sgs.QList2Table(cards)
    self:sortByKeepValue(cards) -- 按保留值排序
	local to = data:toPlayer()
   	for _,c in sgs.list(cards)do
    	if sgs.Sanguosha:matchExpPattern(pattern,player,c)
		and self:isEnemy(to)
		then return c:getEffectiveId() end
	end
    return "."
end

sgs.ai_skill_cardask.bf_zhenhunqin2 = function(self,data,pattern)
	local player = self.player
	local cards = player:getCards("h")
	cards = sgs.QList2Table(cards)
    self:sortByKeepValue(cards) -- 按保留值排序
	local to = data:toPlayer()
   	for _,c in sgs.list(cards)do
    	if sgs.Sanguosha:matchExpPattern(pattern,player,c)
		and self:isFriend(to)
		then return c:getEffectiveId() end
	end
    return "."
end

sgs.ai_skill_invoke.bf_canglang = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return self:isFriend(to) and not self:isWeak(to) or not self:isFriend(to) or to
end

sgs.ai_skill_invoke.bf_longweiqiang = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return not self:isFriend(to) or to:getCardCount()>4
end

sgs.ai_skill_invoke.bf_dongxinjing = function(self,data)
	local player = self.player
	local to = data:toPlayer()
	self.bf_dongxinjing_to = to
    return to:getHandcardNum()>0
end

sgs.ai_skill_askforag.bf_dongxinjing = function(self,card_ids)
	local player = self.player
    local cards = {}
	for c,id in sgs.list(card_ids)do
		c = sgs.Sanguosha:getCard(id)
		table.insert(cards,c)
	end
    self:sortByKeepValue(cards,true) -- 按保留值排序
	if self:isFriend(self.bf_dongxinjing_to) then return "." end
	return self:getUseValue(cards[1])>5.5 and cards[1]:getEffectiveId() or "."
end

sgs.ai_skill_invoke.bf_xingyueshan = function(self,data)
    return true
end

sgs.ai_skill_invoke.bf_tianwuji = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return not self:isFriend(to)
end

sgs.ai_skill_invoke.bf_ganglie = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return not self:isFriend(to)
end

sgs.ai_skill_askforag.bf_shengyi = function(self,card_ids)
	for c,id in sgs.list(card_ids)do
		if self.bf_shengyi_id==id
		then return id end
	end
end

sgs.ai_target_revises.bf_ganglie = function(to,card,self)
    if card:isDamageCard()
	and to:getCardCount()>0
	and self:isEnemy(to,self.player)
	and to:inMyAttackRange(self.player)
	and self.player:getHp()<2 and to:getHp()>1
	then return true end
end

sgs.ai_skill_cardask.bf_ganglie = function(self,data,pattern,prompt)
    local parsed = prompt:split(":")
    if not self:isWeak()
	and self.player:getCardCount()>0
	then
    	if parsed[1]=="slash-jink"
		then
	    	parsed = data:toSlashEffect()
			if self:canLoseHp(parsed.from,parsed.slash)
			and self.player:inMyAttackRange(parsed.from)
			and self:isEnemy(parsed.from)
			then return false end
		else
	    	parsed = data:toCardEffect()
			local card = parsed.card
			if card and card:isDamageCard()
			and self:canLoseHp(parsed.from,parsed.card)
			and self.player:inMyAttackRange(parsed.from)
			and self:isEnemy(parsed.from)
			then return false end
		end
	end
end

sgs.ai_target_revises.bf_qicai = function(to,card,self)
    if card:isKindOf("Dismantlement")
	and to:getCards("hj"):length()<1
	then return true end
end

sgs.ai_skill_cardchosen["#bf_qicai"] = function(self,who,flags,method)
	if method==sgs.Card_MethodDiscard
	then return self:getCardRandomly(who,flags) end
end

sgs.ai_target_revises.bf_tianxiang = function(to,card,self)
    if card:isDamageCard()
	and to:getHandcardNum()>1
	and self:isEnemy(to,self.player)
	and self.player:getHp()<2
	then return true end
end

sgs.ai_target_revises.bf_weimu = function(to,card,self)
    if card:isBlack()
	and card:isKindOf("TrickCard")
	and to:objectName()~=self.player:objectName()
	then return true end
end

sgs.ai_target_revises.bf_duanchang = function(to,card,self)
    if card:isDamageCard() and to:getHp()<2
	and #HaveNoLabelSkills(self.player)>0
	then return true end
end

sgs.ai_target_revises.bf_fuyin = function(to,card,self)
    if card:isKindOf("Slash")
	and to:getMark("bf_fuyin_use-Clear")<1
	and self.player:getHandcardNum()-to:getHandcardNum()>1
	then return true end
end

sgs.ai_target_revises.bf_qixingpao = function(to,card,self)
    if card:isKindOf("Slash")
	and card:objectName()~="slash"
	then return true end
    if card:isKindOf("FireAttack")
	then return true end
end

sgs.ai_skill_invoke.bf_shenglu = function(self,data)
	local player = self.player
	local to = data:toPlayer()
    return not self:isEnemy(to)
end

sgs.ai_skill_choice.bf_shahui = function(self,choices,data)
	local player = self.player
	local items = choices:split("+")
	local to = data:toPlayer()
	if self:isFriend(to)
	then return "judge_area"
	elseif to:getEquips():length()>=to:getHandcardNum()
	then return "equip_area" end
	return "hand_area"
end

sgs.ai_skill_invoke.bf_zongnu = function(self,data)
	local player = self.player
	local event = player:getMark("bf_zongnu_event")
	if event==sgs.EnterDying
	then return self:getCardsNum("Analeptic")+self:getCardsNum("Peach")<1
	else return true end
end

sgs.ai_skill_use["@@bf_zongnu!"] = function(self,prompt)
	local items = prompt:split(":")
	local toc = sgs.Sanguosha:cloneCard(items[2])
	toc:setSkillName("_bf_zongnu")
	local dummy = self:aiUseCard(toc)
	if dummy.card and dummy.to
	then
		local tos = {}
		for i,to in sgs.list(dummy.to)do
			table.insert(tos,to:objectName())
		end
		return toc:toString().."->"..table.concat(tos,"+")
	end
	if toc:isKindOf("Analeptic")
	then return toc:toString()
	elseif toc:isKindOf("Slash")
	then
		local tos,cto = {},{}
		for i,to in sgs.list(self.room:getAlivePlayers())do
			if self:isEnemy(to)
			and CanToCard(toc,self.player,to,cto)
			then
				table.insert(tos,to:objectName())
				table.insert(cto,to)
			end
		end
		for i,to in sgs.list(self.room:getAlivePlayers())do
			if not self:isFriend(to)
			and CanToCard(toc,self.player,to,cto)
			then
				table.insert(tos,to:objectName())
				table.insert(cto,to)
			end
		end
		return #tos>0 and toc:toString().."->"..table.concat(tos,"+")
	elseif toc:isKindOf("Duel")
	then
		local tos,cto = {},{}
		for i,to in sgs.list(self.room:getAlivePlayers())do
			if self:isEnemy(to)
			and CanToCard(toc,self.player,to,cto)
			then
				table.insert(tos,to:objectName())
				table.insert(cto,to)
			end
		end
		for i,to in sgs.list(self.room:getAlivePlayers())do
			if not self:isFriend(to)
			and CanToCard(toc,self.player,to,cto)
			then
				table.insert(tos,to:objectName())
				table.insert(cto,to)
			end
		end
		return #tos>0 and toc:toString().."->"..table.concat(tos,"+")
	end
end

sgs.ai_skill_invoke.bf_godjueshi = function(self,data)
	local player = self.player
    return true
end

sgs.ai_skill_playerchosen.bf_godjueshi = function(self,players)
	local player = self.player
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"hp",true)
	if player:getMark("area")==2
	then
		for _,to in sgs.list(destlist)do
			if self:isFriend(to)
			then return to end
		end
		for _,to in sgs.list(destlist)do
			if not self:isEnemy(to)
			then return to end
		end
	else
		for _,to in sgs.list(destlist)do
			if self:isEnemy(to)
			then return to end
		end
		for _,to in sgs.list(destlist)do
			if not self:isFriend(to)
			then return to end
		end
	end
    return destlist[1]
end

sgs.ai_skill_playerchosen.bf_chansheng = function(self,players)
	local player = self.player
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"card")
	if player:hasFlag("bf_chansheng1")
	then
		for _,target in sgs.list(destlist)do
			if self:isFriend(target)
			then return target end
		end
		for _,target in sgs.list(destlist)do
			if not self:isEnemy(target)
			then return target end
		end
	else
		self:sort(destlist,"card",true)
		for _,target in sgs.list(destlist)do
			if self:isEnemy(target)
			then return target end
		end
		for _,target in sgs.list(destlist)do
			if not self:isFriend(target)
			then return target end
		end
	end
    return destlist[1]
end

sgs.ai_skill_use["@@bf_godjueshi"] = function(self,prompt)
	local player = self.player
	if player:getMark("bf_js-PlayClear")>0 then return end
	player:addMark("bf_js-PlayClear")
	local give,n = nil,player:getHp()
    local cards = sgs.QList2Table(player:getCards("h"))
	local js = player:getTag("bf_godjueshi"):toString():split("+")
   	for i,id in sgs.list(js)do
		table.insert(cards,sgs.Sanguosha:getCard(id))
	end
    self:sortByUseValue(cards)
    self:sortByKeepValue(cards)
	local function ZgJueshiIds(cs)
		if cs and #cs>=n
		then
			local ids = {}
			for _,c in sgs.list(cs)do
				if player:getCards("h"):contains(c)
				then
					for i,id in sgs.list(js)do
						if table.contains(ids,id)
						or table.contains(cs,sgs.Sanguosha:getCard(id))
						then continue end
						table.insert(ids,id)
						table.insert(ids,c:getId())
						break
					end
				end
			end
			return #ids>1
			and math.mod(#ids,2)~=1
			and string.format("#bf_godjueshiCard:%s:",table.concat(ids,"+"))
		end
	end
	for _,h1 in sgs.list(cards)do
		if n<2 or n>4 then break end
		local tocs = {}
		for _,h2 in sgs.list(cards)do
	    	if h1:getType()~=h2:getType() then continue end
			table.insert(tocs,h2)
		end
		if #tocs<n then continue end
		for _,h2 in sgs.list(tocs)do
			local cs = {}
			table.insert(cs,h2)
			for _,h3 in sgs.list(tocs)do
				if table.contains(cs,h3) then continue end
				table.insert(cs,h3)
				if #cs>=n
				then
					local x = 0
					for _,c in sgs.list(cs)do
			    		x = x+c:getNumber()
					end
					if x==18 then return ZgJueshiIds(cs) end
					break
				end
				for _,h4 in sgs.list(tocs)do
					if table.contains(cs,h4) then continue end
					table.insert(cs,h4)
					if #cs>=n
					then
						local x = 0
						for _,c in sgs.list(cs)do
							x = x+c:getNumber()
						end
						if x==18 then return ZgJueshiIds(cs) end
						break
					end
					for _,h5 in sgs.list(tocs)do
						if table.contains(cs,h5) then continue end
						table.insert(cs,h5)
						if #cs>=n
						then
							local x = 0
							for _,c in sgs.list(cs)do
								x = x+c:getNumber()
							end
			        		if x==18 then return ZgJueshiIds(cs) end
							break
						end
					end
				end
			end
		end
	end
	give = {}
	for _,c in sgs.list(cards)do
		table.insert(give,c)
	   	if #give>=n then return ZgJueshiIds(give) end
	end
end

sgs.ai_skill_invoke.bf_feitianyi = function(self,data)
	local player = self.player
	player:addMark("bf_feitianyi_invoke-Clear")
    return true
end

sgs.ai_use_revises.bf_feitianyi = function(self,card,use)
	local player = self.player
	if card:getTypeId()~=0
	and player:getMark("bf_feitianyi_invoke-Clear")<1
	then return false end
end
















addAiSkills("bf_zongnu").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
  	for d,c in sgs.list(cards)do
		if c:isKindOf("Slash")
		or c:isKindOf("Analeptic")
		then
			local duel = sgs.Sanguosha:cloneCard("duel")
			duel:setSkillName("bf_zongnu")
			duel:addSubcard(c)
			d = self:aiUseCard(duel)
			if d.card and d.to
			and duel:isAvailable(self.player)
			then return duel end
			duel:deleteLater()
		end
	end
  	for d,c in sgs.list(cards)do
		if c:isKindOf("Slash")
		or c:isKindOf("Duel")
		then
			local duel = sgs.Sanguosha:cloneCard("analeptic")
			duel:setSkillName("bf_zongnu")
			duel:addSubcard(c)
			d = self:aiUseCard(duel)
			if d.card and d.to
			and duel:isAvailable(self.player)
			then return duel end
			duel:deleteLater()
		end
	end
  	for d,c in sgs.list(cards)do
		if c:isKindOf("Duel")
		or c:isKindOf("Analeptic")
		then
			local duel = sgs.Sanguosha:cloneCard("slash")
			duel:setSkillName("bf_zongnu")
			duel:addSubcard(c)
			d = self:aiUseCard(duel)
			if d.card and d.to
			and duel:isAvailable(self.player)
			then return duel end
			duel:deleteLater()
		end
	end
	if self:isWeak()
	and #self.enemies<2
	and CardIsAvailable(self.player,"duel","bf_zongnu")
	and CardIsAvailable(self.player,"slash","bf_zongnu")
	and CardIsAvailable(self.player,"analeptic","bf_zongnu")
	then
		local parse = sgs.Card_Parse("#bf_zongnuCard:.:")
		assert(parse)
		for d,ep in sgs.list(self.enemies)do
			if self.player:canSlash(ep)
			and self:isWeak(ep)
			and ep:getHandcardNum()<3
			then
				local duel = sgs.Sanguosha:cloneCard("slash")
				duel:setSkillName("_bf_zongnu")
				duel:deleteLater()
				d = self:aiUseCard(duel)
				if d.card and d.to:contains(ep)
				then return parse end
			end
		end
	end
end

sgs.ai_skill_use_func["#bf_zongnuCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.bf_zongnuCard = 5.4
sgs.ai_use_priority.bf_zongnuCard = 2.8

sgs.ai_guhuo_card.bf_shengyi = function(self,toname,class_name)
	local ids = self.room:getNCards(3)
	self.room:returnToTopDrawPile(ids)
	for c,id in sgs.list(ids)do
		c = sgs.Sanguosha:getCard(id)
		if c:getSuit()==2
		and c:isKindOf(class_name)
		and sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
		then self.bf_shengyi_id = id return "#bf_shengyiCard:.:"..toname end
	end
end

addAiSkills("bf_shengyi").getTurnUseCard = function(self)
	local ids = self.room:getNCards(3)
	self.room:returnToTopDrawPile(ids)
	for c,id in sgs.list(ids)do
		c = sgs.Sanguosha:getCard(id)
		local can = self:aiUseCard(c)
		local parse = sgs.Card_Parse("#bf_shengyicard:.:")
		sgs.ai_use_priority.bf_shengyicard = sgs.ai_use_priority[c:getClassName()]
		assert(parse)
		if c:getSuit()==2 and c:isAvailable(self.player) and can.card and can.to
		then self.bf_shengyi_id = id return parse end
	end
end

sgs.ai_skill_use_func["#bf_shengyicard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.bf_shengyicard = 9.4
sgs.ai_use_priority.bf_shengyicard = 10.8

addAiSkills("bf_zhenliang").getTurnUseCard = function(self)
	local cards = self.player:getCards("he")
    local n = self.player:getChangeSkillState("bf_zhenliang")
	cards = self:sortByKeepValue(cards)
	local toids = {}
  	for _,c in sgs.list(cards)do
		for _,tc in sgs.list(self.player:getPile("bf_ren"))do
			tc = sgs.Sanguosha:getCard(tc)
			if c:getColor()==tc:getColor()
			then
				table.insert(toids,c:getEffectiveId())
				break
			end
		end
		local parse = sgs.Card_Parse("#bf_zhenliangCard:"..table.concat(toids,"+")..":")
		assert(parse)
		if n<2 and #toids>1 then return parse end
	end
end

sgs.ai_skill_use_func["#bf_zhenliangCard"] = function(card,use,self)
	local player = self.player
	self:sort(self.enemies,"hp")
	for _,ep in sgs.list(self.enemies)do
		if ep:getHp()>=player:getHp()
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.bf_zhenliangCard = 9.4
sgs.ai_use_priority.bf_zhenliangCard = 4.8

addAiSkills("bf_chenglve").getTurnUseCard = function(self)
	local parse = sgs.Card_Parse("#bf_chenglveCard:.:")
	assert(parse)
	return parse
end

sgs.ai_skill_use_func["#bf_chenglveCard"] = function(card,use,self)
	local player = self.player
    local n = player:getChangeSkillState("bf_chenglve")
	if n>2 and player:getCardCount()<2 then return end
	use.card = card
end

sgs.ai_use_value.bf_chenglveCard = 9.4
sgs.ai_use_priority.bf_chenglveCard = 4.8

addAiSkills("bf_shenshi").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
    local n = self.player:getChangeSkillState("bf_shenshi")
	self:sortByKeepValue(cards)
  	for _,c in sgs.list(cards)do
		local parse = sgs.Card_Parse("#bf_shenshiCard:"..c:getEffectiveId()..":")
		assert(parse)
		if n<2 then return parse end
	end
end

sgs.ai_skill_use_func["#bf_shenshiCard"] = function(card,use,self)
	local player = self.player
	local n = 0
	for _,p in sgs.list(player:getAliveSiblings())do
		n = math.max(n,p:getHandcardNum())
	end
	self:sort(self.enemies,"hp")
	for _,ep in sgs.list(self.enemies)do
		if ep:getHandcardNum()==n
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.bf_shenshiCard = 9.4
sgs.ai_use_priority.bf_shenshiCard = 4.8

addAiSkills("bf_feijun").getTurnUseCard = function(self)
	local parse = sgs.Card_Parse("#bf_feijunCard:.:")
	assert(parse)
	return parse
end

sgs.ai_skill_use_func["#bf_feijunCard"] = function(card,use,self)
	local player = self.player
	self:sort(self.enemies,"handcard")
	local cards = sgs.QList2Table(player:getCards("e"))
	self:sortByKeepValue(cards)
	for _,ep in sgs.list(self.enemies)do
		if #cards>0
		and ep:getEquips():length()>=#cards
		then
			use.card = sgs.Card_Parse("#bf_feijunCard:"..cards[1]:getEffectiveId()..":")
			if use.to then use.to:append(ep) end
			return
		end
	end
	cards = sgs.QList2Table(player:getCards("h"))
	self:sortByKeepValue(cards)
	for _,ep in sgs.list(self.enemies)do
		if #cards>0
		and ep:getHandcardNum()>=#cards
		then
			use.card = sgs.Card_Parse("#bf_feijunCard:"..cards[1]:getEffectiveId()..":")
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.bf_feijunCard = 9.4
sgs.ai_use_priority.bf_feijunCard = 5.8

addAiSkills("bf_xiongluan").getTurnUseCard = function(self)
	local parse = sgs.Card_Parse("#bf_xiongluanCard:.:")
	assert(parse)
	return parse
end

sgs.ai_skill_use_func["#bf_xiongluanCard"] = function(card,use,self)
	local player = self.player
	self:sort(self.enemies,"hp",true)
	for _,ep in sgs.list(self.enemies)do
		if ep:getHp()>1
		and player:inMyAttackRange(ep)
		and self:getCardsNum("Slash","h")>=ep:getHp()
		then
			local n = 0
			for i,c in sgs.list(self:getCards("Slash"))do
		    	i = self:aiUseCard(c)
				if i.card and i.to:contains(ep)
				then n = n+1 end
			end
			if n<ep:getHp()
			then continue end
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.bf_xiongluanCard = 9.4
sgs.ai_use_priority.bf_xiongluanCard = 7.8

addAiSkills("bf_qingce").getTurnUseCard = function(self)
	local cards = {}
  	for _,c in sgs.list(sgs.QList2Table(self.player:getPile("honor")))do
		table.insert(cards,sgs.Sanguosha:getCard(c))
	end
	if #cards<1 then return end
	self:sortByKeepValue(cards,true)
	local parse = sgs.Card_Parse("#bf_qingceCard:"..cards[1]:getEffectiveId()..":")
	assert(parse)
	return parse
end

sgs.ai_skill_use_func["#bf_qingceCard"] = function(card,use,self)
	local player = self.player
	for _,fp in sgs.list(self.friends)do
		if use.to
		and self:canDisCard(fp,"ej")
		then
			use.to:append(fp)
			use.card = card
			return
		end
	end
	for _,ep in sgs.list(self.enemies)do
		if use.to
		and ep:getCards("e"):length()>0
		then
			use.to:append(ep)
			use.card = card
			return
		end
	end
end

sgs.ai_use_value.bf_qingceCard = 9.4
sgs.ai_use_priority.bf_qingceCard = 5.8

addAiSkills("bf_jueyan").getTurnUseCard = function(self)
	local parse = sgs.Card_Parse("#bf_jueyanCard:.:")
	assert(parse)
	self.bf_jueyan_choice = "@Equip1lose"
	if self:isWeak()
	and self.player:hasEquipArea(1)
	then return parse end
	self.bf_jueyan_choice = "@Equip0lose"
	if self:getCardsNum("Slash","h")>0
	and not sgs.Slash_IsAvailable(self.player)
	and self.player:hasEquipArea(0)
	and #self.enemies>0
	then return parse end
	self.bf_jueyan_choice = "@Equip4lose"
	if self:getCardsNum("TrickCard","h")>2
	and self.player:hasEquipArea(4)
	then return parse end
	local can = true
  	for _,ep in sgs.list(self.enemies)do
    	if self.player:canSlash(ep)
		then can = false end
	end
	self.bf_jueyan_choice = "@Equip3lose"
	if can and self.player:hasEquipArea(3)
	then return parse end
	self.bf_jueyan_choice = "@Equip2lose"
	if can and self.player:hasEquipArea(2)
	then return parse end
end

sgs.ai_skill_use_func["#bf_jueyanCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.bf_jueyanCard = 6.4
sgs.ai_use_priority.bf_jueyanCard = 10.8

addAiSkills("bf_zhijian").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
  	for _,c in sgs.list(cards)do
		local parse = sgs.Card_Parse("#bf_zhijianCard:"..c:getEffectiveId()..":")
		assert(parse)
		if c:isAvailable(self.player)
		and c:isKindOf("EquipCard")
	   	then return parse end
	end
end

sgs.ai_skill_use_func["#bf_zhijianCard"] = function(card,use,self)
	local player = self.player
	for _,fp in sgs.list(self.friends_noself)do
		local c = sgs.Sanguosha:getCard(card:getSubcards():first())
		local index = c:getRealCard():toEquipCard():location()
		if fp:getEquip(index)==nil
		and fp:hasEquipArea(index)
		then
			use.card = card
			if use.to then use.to:append(fp) end
			return
		end
	end
end

sgs.ai_use_value.bf_zhijianCard = 9.4
sgs.ai_use_priority.bf_zhijianCard = 2.8

addAiSkills("bf_zhibaPindian").getTurnUseCard = function(self)
	local parse = sgs.Card_Parse("#bf_zhibaCard:.:")
	assert(parse)
	return parse
end

sgs.ai_skill_use_func["#bf_zhibaCard"] = function(card,use,self)
	local player = self.player
	self:sort(self.enemies,"handcard")
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	for _,ep in sgs.list(self.enemies)do
		if ep:hasLordSkill("bf_zhiba")
		and player:canPindian(ep)
		then
			for _,c in sgs.list(cards)do
				if c:getNumber()>11
				then
					use.card = sgs.Card_Parse("#bf_zhibaCard:"..c:getEffectiveId()..":")
					if use.to then use.to:append(ep) end
					return
				end
			end
		end
	end
	for _,fp in sgs.list(self.friends_noself)do
		if fp:hasLordSkill("bf_zhiba")
		and player:canPindian(fp)
		then
			for _,c in sgs.list(cards)do
				if c:getNumber()<6
				then
					use.card = sgs.Card_Parse("#bf_zhibaCard:"..c:getEffectiveId()..":")
					if use.to then use.to:append(fp) end
					return
				end
			end
		end
	end
end

sgs.ai_use_value.bf_zhibaCard = 9.4
sgs.ai_use_priority.bf_zhibaCard = 2.8

addAiSkills("bf_tiaoxin").getTurnUseCard = function(self)
	local parse = sgs.Card_Parse("#bf_tiaoxinCard:.:")
	assert(parse)
	return parse
end

sgs.ai_skill_use_func["#bf_tiaoxinCard"] = function(card,use,self)
	local player = self.player
	self:sort(self.enemies,"handcard")
	for _,ep in sgs.list(self.enemies)do
		if ep:inMyAttackRange(player)
		then
			if self:getCardsNum("Jink","h")>0
			or player:getHandcardNum()>ep:getHandcardNum()
			then
				use.card = card
				if use.to then use.to:append(ep) end
				break
			end
		end
	end
end

sgs.ai_use_value.bf_tiaoxinCard = 9.4
sgs.ai_use_priority.bf_tiaoxinCard = 4.8

addAiSkills("bf_jixi").getTurnUseCard = function(self)
  	for _,c in sgs.list(self.player:getPile("field"))do
	   	local fs = sgs.Sanguosha:cloneCard("snatch")
		fs:setSkillName("bf_jixi")
		fs:addSubcard(c)
		if fs:isAvailable(self.player)
	   	then return fs end
		fs:deleteLater()
	end
end

addAiSkills("bf_luanwu").getTurnUseCard = function(self)
	local parse = sgs.Card_Parse("#bf_luanwuCard:.:")
	assert(parse)
	return parse
end

sgs.ai_skill_use_func["#bf_luanwuCard"] = function(card,use,self)
	local player = self.player
	local x = 0
	for _,fp in sgs.list(self.enemies)do
		if self:isWeak(fp)
		then x = x+1 end
	end
	for _,fp in sgs.list(self.friends)do
		if self:isWeak()
		then x = x-1 end
	end
	if x>0 then use.card = card end
end

sgs.ai_use_value.bf_luanwuCard = 9.4
sgs.ai_use_priority.bf_luanwuCard = 3.8

addAiSkills("bf_jiuchi").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
  	for _,c in sgs.list(cards)do
	   	local fs = sgs.Sanguosha:cloneCard("analeptic")
		fs:setSkillName("jiuchi")
		fs:addSubcard(c)
		if fs:isAvailable(self.player)
		and c:getTypeId()==1
		and c:isBlack()
	   	then return fs end
		fs:deleteLater()
	end
end

sgs.ai_view_as.bf_jiuchi = function(card,player,card_place)
   	if card_place==sgs.Player_PlaceHand
	then
    	if card:isKindOf("BasicCard")
		and card:isBlack()
		then return ("analeptic:jiuchi[no_suit:0]="..card:getEffectiveId()) end
	end
end

addAiSkills("bf_dimeng").getTurnUseCard = function(self)
	local parse = sgs.Card_Parse("#bf_dimengCard:.:")
	assert(parse)
	return parse
end

sgs.ai_skill_use_func["#bf_dimengCard"] = function(card,use,self)
	local player = self.player
	local cards = sgs.QList2Table(player:getCards("he"))
	self:sortByKeepValue(cards)
	local tos = sgs.QList2Table(self.room:getOtherPlayers(player))
	self:sort(tos,"handcard")
	for _,ep in sgs.list(tos)do
		for _,fp in sgs.list(tos)do
	    	local n = ep:getHandcardNum()-fp:getHandcardNum()
			if n>0
			and n<=#cards
			and self:isFriend(fp)
			and not self:isFriend(ep)
			then
				local ids = {}
				for i=1,n do
					table.insert(ids,cards[i]:getEffectiveId())
				end
				use.card = sgs.Card_Parse("#bf_dimengCard:"..table.concat(ids,"+")..":")
				if use.to
				then
			    	use.to:append(ep)
			    	use.to:append(fp)
				end
				return
			end
		end
	end
	for _,ep in sgs.list(tos)do
		for _,fp in sgs.list(tos)do
	    	local n = ep:getHandcardNum()-fp:getHandcardNum()
			if n>=0
			and n<=#cards
			and self:isFriend(fp)
			and not self:isFriend(ep)
			then
				local ids = {}
				for i=1,n do
					table.insert(ids,cards[i]:getEffectiveId())
				end
				use.card = sgs.Card_Parse("#bf_dimengCard:"..table.concat(ids,"+")..":")
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

sgs.ai_use_value.bf_dimengCard = 9.4
sgs.ai_use_priority.bf_dimengCard = 1.8

addAiSkills("bf_shuangxiong").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
  	for i,c in sgs.list(cards)do
		for ii,cc in sgs.list(cards)do
			if ii==i
			or cc:getColor()~=c:getColor()
			then continue end
			local fs = sgs.Sanguosha:cloneCard("duel")
			fs:setSkillName("shuangxiong")
			fs:addSubcard(c)
			fs:addSubcard(cc)
			if fs:isAvailable(self.player)
			then return fs end
			fs:deleteLater()
		end
	end
end

addAiSkills("bf_tianyi").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
  	for _,c in sgs.list(cards)do
		local parse = sgs.Card_Parse("#bf_tianyiCard:"..c:getEffectiveId()..":")
		assert(parse)
		if c:getNumber()>9
		and self:getCardsNum("Slash","h")>0
	   	then return parse end
	end
	if #cards>0
	then
		sgs.ai_use_priority.bf_tianyiCard = -4.8
		local parse = sgs.Card_Parse("#bf_tianyiCard:"..cards[1]:getEffectiveId()..":")
		assert(parse)
	end
end

sgs.ai_skill_use_func["#bf_tianyiCard"] = function(card,use,self)
	local player = self.player
	local tos = sgs.QList2Table(self.room:getOtherPlayers(player))
	self:sort(tos,"handcard")
	for _,ep in sgs.list(tos)do
		if self:isEnemy(ep)
		and ep:canPindian()
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	for _,ep in sgs.list(tos)do
		if self:isFriend(ep)
		and ep:canPindian()
		and ep:getHandcardNum()>2
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	for _,ep in sgs.list(tos)do
		if not self:isFriend(ep)
		and ep:canPindian()
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
end

sgs.ai_use_value.bf_tianyiCard = 9.4
sgs.ai_use_priority.bf_tianyiCard = 4.8

addAiSkills("bf_mouxi").getTurnUseCard = function(self)
	local player = self.player
	local cards = sgs.QList2Table(self.player:getCards("e"))
	self:sortByKeepValue(cards)
	for _,name in sgs.list(patterns)do
		local card = sgs.Sanguosha:cloneCard(name)
		card:setSkillName("_bf_mouxi")
		if #cards>0
		and card:isAvailable(player)
		and card:getTypeId()==1
		and player:getMark(name.."_nomx")<1
		then
			local dummy = self:aiUseCard(card)
			self.bf_mouxi_c = dummy
			sgs.ai_use_priority.bf_mouxiCard = sgs.ai_use_priority[card:getClassName()]
			local parse = sgs.Card_Parse("#bf_mouxiCard:"..cards[1]:getEffectiveId()..":"..name)
			assert(parse)
			return dummy.card and dummy.to and parse
		end
		card:deleteLater()
	end
end

sgs.ai_guhuo_card.bf_mouxi = function(self,toname,class_name)
	local player = self.player
    local cards = sgs.QList2Table(player:getCards("e"))
    self:sortByKeepValue(cards) -- 按保留值排序
	local card = sgs.Sanguosha:cloneCard(toname)
	card:deleteLater()
	if #cards>0
	and card:getTypeId()==1
	and player:getMark(toname.."_nomx")<1
	and sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
	then return "#bf_mouxiCard:"..cards[1]:getEffectiveId()..":"..toname end
end

sgs.ai_skill_use_func["#bf_mouxiCard"] = function(card,use,self)
	local player = self.player
	use.card = card
	if use.to then use.to = self.bf_mouxi_c.to end
end

sgs.ai_use_value.bf_mouxiCard = 9.4
sgs.ai_use_priority.bf_mouxiCard = 5.8

addAiSkills("bf_liansuo").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
  	for _,c in sgs.list(cards)do
	   	local fs = sgs.Sanguosha:cloneCard("iron_chain")
		fs:setSkillName("bf_liansuo")
		fs:addSubcard(c)
		local dummy = self:aiUseCard(fs)
		local parse = sgs.Card_Parse("#bf_liansuoCard:"..c:getEffectiveId()..":")
		sgs.ai_use_priority.bf_liansuoCard = sgs.ai_use_priority[fs:getClassName()]
		self.bf_liansuo_c = dummy
		fs:deleteLater()
		assert(parse)
		if fs:isAvailable(self.player)
		and dummy.card
		and dummy.to:length()>1
	   	then return parse end
	end
end

sgs.ai_skill_use_func["#bf_liansuoCard"] = function(card,use,self)
	local player = self.player
	use.card = card
	if use.to then use.to = self.bf_liansuo_c.to end
end

sgs.ai_use_value.bf_liansuoCard = 9.4
sgs.ai_use_priority.bf_liansuoCard = 5.8

addAiSkills("bf_qiangxi").getTurnUseCard = function(self)
	local player = self.player
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	for _,c in sgs.list(cards)do
		if c:isKindOf("Weapon")
		then
			local parse = sgs.Card_Parse("#bf_qiangxiCard:"..c:getEffectiveId()..":")
			assert(parse)
			return parse
		end
	end
	self:sort(self.enemies,"hp")
	for _,fp in sgs.list(self.enemies)do
		if fp:getHp()<=player:getHp()
		and player:inMyAttackRange(fp)
		then
			local parse = sgs.Card_Parse("#bf_qiangxiCard:.:")
			assert(parse)
			return parse
		end
	end
end

sgs.ai_skill_use_func["#bf_qiangxiCard"] = function(card,use,self)
	local player = self.player
	self:sort(self.enemies,"hp")
	for _,fp in sgs.list(self.enemies)do
		if self:isWeak(fp)
		and player:inMyAttackRange(fp)
		then
			use.card = card
			if use.to
			then use.to:append(fp) end
			return
		end
	end
	for _,fp in sgs.list(self.enemies)do
		if not self:isWeak()
		and player:inMyAttackRange(fp)
		then
			use.card = card
			if use.to
			then use.to:append(fp) end
			return
		end
	end
end

sgs.ai_use_value.bf_jieyinCard = 9.4
sgs.ai_use_priority.bf_jieyinCard = 3.8

local bf_huangtianVS={}
bf_huangtianVS.name="bf_huangtianVS"
table.insert(sgs.ai_skills,bf_huangtianVS)
bf_huangtianVS.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	for _,c in sgs.list(cards)do
		if c:getSuit()==0
		or c:isKindOf("Jink")
		then
			self.bf_huangtian_c = c
			local parse = sgs.Card_Parse("#bf_huangtianCard:"..c:getEffectiveId()..":")
			assert(parse)
			return #cards>2 and parse
		end
	end
end

sgs.ai_skill_use_func["#bf_huangtianCard"] = function(card,use,self)
	local player = self.player
	local tos = sgs.QList2Table(self.room:getOtherPlayers(player))
	self:sort(tos,"hp")
	for _,ep in sgs.list(tos)do
		if self:isFriend(ep)
		and ep:hasLordSkill("bf_huangtian")
		then
			use.card = card
			if use.to then use.to:append(ep) end
			break
		end
	end
end

sgs.ai_use_value.bf_huangtianCard = 9.4
sgs.ai_use_priority.bf_huangtianCard = 2.8

local bf_lijian={}
bf_lijian.name="bf_lijian"
table.insert(sgs.ai_skills,bf_lijian)
bf_lijian.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	local parse = sgs.Card_Parse("#bf_lijianCard:"..cards[1]:getEffectiveId()..":")
    assert(parse)
	if #cards>0 then return parse end
end

sgs.ai_skill_use_func["#bf_lijianCard"] = function(card,use,self)
	local player = self.player
	local tos = sgs.QList2Table(self.room:getAlivePlayers())
	self:sort(tos,"hp")
	for _,ep in sgs.list(tos)do
		if self:isEnemy(ep)
		and ep:getGender()~=player:getGender()
		then
			if use.to
			and use.to:length()<2
			then use.to:append(ep) end
			if use.to:length()>=2
			then use.card = card end
		end
	end
	for _,ep in sgs.list(tos)do
		if not self:isEnemy(ep)
		and not self:isFriend(ep)
		and ep:getGender()~=player:getGender()
		then
			if use.to
			and use.to:length()<2
			then use.to:append(ep) end
			if use.to:length()>=2
			then use.card = card end
		end
	end
	for _,ep in sgs.list(tos)do
		if self:isFriend(ep)
		and ep:getGender()~=player:getGender()
		then
			if use.to
			and use.to:length()<2
			then use.to:append(ep) end
			if use.to:length()>=2
			then use.card = card end
		end
	end
end

sgs.ai_use_value.bf_lijianCard = 9.4
sgs.ai_use_priority.bf_lijianCard = 2.8

local bf_qingnang={}
bf_qingnang.name="bf_qingnang"
table.insert(sgs.ai_skills,bf_qingnang)
bf_qingnang.getTurnUseCard = function(self)
	local parse = sgs.Card_Parse("#bf_qingnangCard:.:")
    assert(parse)
	return parse
end

sgs.ai_skill_use_func["#bf_qingnangCard"] = function(card,use,self)
	local player = self.player
	self:sort(self.friends_noself,"hp")
	if self.bf_qn
	then
	   	local to = self.room:getCardOwner(self.bf_qn:getEffectiveId())
		if to
		and self:isFriend(to)
		and to:isWounded()
		and to:getCardCount()>0
		then
			use.card = card
			if use.to
			then
				use.to:append(to)
				return
			end
		end
	end
	self.bf_qn = nil
	for _,fp in sgs.list(self.friends_noself)do
		local es = sgs.QList2Table(fp:getCards("e"))
		self:sortByKeepValue(es)
		for _,e in sgs.list(es)do
	    	if e:isBlack()
			and self:isWeak(fp)
			then
				self.bf_qn = e
				use.card = card
				if use.to
				then
					use.to:append(fp)
					return
				end
			end
		end
	end
	if player:isWounded()
	then
		local es = sgs.QList2Table(player:getCards("he"))
		self:sortByKeepValue(es)
		for _,e in sgs.list(es)do
	    	if e:isBlack()
			then
				self.bf_qn = e
				use.card = card
				if use.to
				then
					use.to:append(player)
					return
				end
			end
		end
	end
	self:sort(self.enemies,"hp")
	for _,ep in sgs.list(self.enemies)do
		local es = sgs.QList2Table(ep:getCards("e"))
		for _,e in sgs.list(es)do
	    	if not e:isBlack()
			then
				self.bf_qn = e
				use.card = card
				if use.to
				then
					use.to:append(ep)
					return
				end
			end
		end
	end
	for _,ep in sgs.list(self.enemies)do
	   	if not ep:isWounded()
		and ep:getCardCount()>0
		then
			use.card = card
			if use.to
			then
				use.to:append(ep)
				return
			end
		end
	end
end

sgs.ai_use_value.bf_qingnangCard = 9.4
sgs.ai_use_priority.bf_qingnangCard = 2.8

local bf_jieyin={}
bf_jieyin.name="bf_jieyin"
table.insert(sgs.ai_skills,bf_jieyin)
bf_jieyin.getTurnUseCard = function(self)
	local valid = {}
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	for _,c in sgs.list(cards)do
		if #valid>=2 then break end
		table.insert(valid,c:getEffectiveId())
	end
	local parse = sgs.Card_Parse("#bf_jieyinCard:"..table.concat(valid,"+")..":")
    assert(parse)
	for _,fp in sgs.list(self.friends_noself)do
		if #cards>2
		and fp:isWounded()
		and self.player:isWounded()
		and self.player:getGender()~=fp:getGender()
		then return parse end
	end
end

sgs.ai_skill_use_func["#bf_jieyinCard"] = function(card,use,self)
	local player = self.player
	self:sort(self.friends_noself,"hp")
	for _,fp in sgs.list(self.friends_noself)do
		if fp:isWounded()
		and player:isWounded()
		and player:getGender()~=fp:getGender()
		then
			use.card = card
			if use.to
			then use.to:append(fp) end
			return
		end
	end
end

sgs.ai_use_value.bf_jieyinCard = 9.4
sgs.ai_use_priority.bf_jieyinCard = 3.8

local bf_fanjian={}
bf_fanjian.name="bf_fanjian"
table.insert(sgs.ai_skills,bf_fanjian)
bf_fanjian.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	local parse = sgs.Card_Parse("#bf_fanjianCard:"..cards[1]:getEffectiveId()..":")
    assert(parse)
	if #cards>1
	and #self.enemies>0
	then return parse end
end

sgs.ai_skill_use_func["#bf_fanjianCard"] = function(card,use,self)
	self:sort(self.enemies,"hp")
	if use.to
	and #self.enemies>0
	then
		use.card = card
		use.to:append(self.enemies[1])
	end
end

sgs.ai_use_value.bf_fanjianCard = 9.4
sgs.ai_use_priority.bf_fanjianCard = 1.8

local bf_kurou={}
bf_kurou.name="bf_kurou"
table.insert(sgs.ai_skills,bf_kurou)
bf_kurou.getTurnUseCard = function(self)
	local x = self:getCardsNum("Analeptic","h")+self:getCardsNum("Peach","h")
	local can = x>0 and self.player:getHp()<2 and #self.enemies>0 and sgs.Slash_IsAvailable(self.player)
	for _,ep in sgs.list(self.enemies)do
		if self:isWeak(ep)
		and not self:isWeak()
		and self.player:canSlash(ep)
		and self:getCardsNum("Slash","h")<1
		then x= x+2 end
	end
	can = can or x>1
	local parse = sgs.Card_Parse("#bf_kurouCard:.:")
    assert(parse)
    return can and parse
end

sgs.ai_skill_use_func["#bf_kurouCard"] = function(card,use,self)
	local player = self.player
	use.card = card
end

sgs.ai_use_value.bf_kurouCard = 9.4
sgs.ai_use_priority.bf_kurouCard = 4.8

local bf_qixi={}
bf_qixi.name="bf_qixi"
table.insert(sgs.ai_skills,bf_qixi)
bf_qixi.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
  	for _,c in sgs.list(cards)do
	   	local fs = sgs.Sanguosha:cloneCard("dismantlement")
		fs:setSkillName("qixi")
		fs:addSubcard(c)
		if c:isBlack()
		and fs:isAvailable(self.player)
	   	then return fs end
		fs:deleteLater()
	end
end

local bf_shenfen={}
bf_shenfen.name="bf_shenfen"
table.insert(sgs.ai_skills,bf_shenfen)
bf_shenfen.getTurnUseCard = function(self)
	local x = 1
	for _,ep in sgs.list(self.enemies)do
		if self:isWeak(ep)
		then x = x+1 end
	end
	for _,fp in sgs.list(self.friends_noself)do
		if fp:getHp()<2
		then x = x-1 end
	end
	local parse = sgs.Card_Parse("#bf_shenfencard:.:")
    assert(parse)
    return x>1 and parse
end

sgs.ai_skill_use_func["#bf_shenfencard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.bf_shenfencard = 9.4
sgs.ai_use_priority.bf_shenfencard = 4.8

local bf_longdan={}
bf_longdan.name="bf_longdan"
table.insert(sgs.ai_skills,bf_longdan)
bf_longdan.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
   	for _,c in sgs.list(cards)do
	   	local fs = sgs.Sanguosha:cloneCard("slash")
		fs:setSkillName("longdan")
		fs:addSubcard(c)
		if fs:isAvailable(self.player)
		and c:isKindOf("Jink")
	   	then return fs end
		fs:deleteLater()
	end
end

sgs.ai_view_as.bf_longdan = function(card,player,card_place)
   	if card_place==sgs.Player_PlaceHand
	then
    	if card:isKindOf("Jink")
		then return ("slash:longdan[no_suit:0]="..card:getEffectiveId())
		elseif card:isKindOf("Slash")
		then return ("jink:longdan[no_suit:0]="..card:getEffectiveId()) end
	end
end

sgs.ai_card_priority.bf_longdan = {
	longdan = 0.5
}

sgs.card_value.bf_longdan = {
	Slash = 3.9,
}

sgs.card_value.bf_paoxiao = {
	Slash = 2.9,
}

local bf_wusheng={}
bf_wusheng.name="bf_wusheng"
table.insert(sgs.ai_skills,bf_wusheng)
bf_wusheng.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
    for _,c in sgs.list(cards)do
	   	local fs = sgs.Sanguosha:cloneCard("slash")
		fs:setSkillName("wusheng")
		fs:addSubcard(c)
		if fs:isAvailable(self.player)
	   	then return fs end
		fs:deleteLater()
	end
end

sgs.ai_view_as.bf_wusheng = function(card,player,card_place)
   	if card_place==sgs.Player_PlaceHand
	then
    	return ("slash:wusheng[no_suit:0]="..card:getEffectiveId())
	end
end

sgs.ai_card_priority.bf_wusheng = {
	wusheng = 0.5
}

local bf_duanliang={}
bf_duanliang.name="bf_duanliang"
table.insert(sgs.ai_skills,bf_duanliang)
bf_duanliang.getTurnUseCard = function(self)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
	if #cards<1 then return end
    self:sortByKeepValue(cards) -- 按保留值排序
	for i,c in sgs.list(cards)do
		if c:isBlack()
		and (c:isKindOf("BasicCard") or c:isKindOf("EquipCard"))
		then
			local slash = sgs.Sanguosha:cloneCard("supply_shortage")
			slash:setSkillName("bf_duanliang")
			slash:addSubcard(c)
			return slash
		end
	end
end

local bf_jiufa={}
bf_jiufa.name="bf_jiufa"
table.insert(sgs.ai_skills,bf_jiufa)
bf_jiufa.getTurnUseCard = function(self)
	local player = self.player
	if player:getMaxHp()>9
	then
        local slash = sgs.Sanguosha:cloneCard("slash")
		slash:setSkillName("_bf_jiufa")
		slash:deleteLater()
		slash = self:aiUseCard(slash)
		local parse = sgs.Card_Parse("#bf_jiufaCard:.:")
        assert(parse)
        return slash.card and slash.to and parse
	end
end

sgs.ai_skill_use_func["#bf_jiufaCard"] = function(card,use,self)
	local player = self.player
	use.card = card
end

sgs.ai_use_value.bf_jiufaCard = 9.4
sgs.ai_use_priority.bf_jiufaCard = 2.8

local bf_huoxin={}
bf_huoxin.name="bf_huoxin"
table.insert(sgs.ai_skills,bf_huoxin)
bf_huoxin.getTurnUseCard = function(self)
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
	if #cards<2 then return end
	local give = {}
    self:sortByKeepValue(cards) -- 按保留值排序
	for i,c in sgs.list(cards)do
		if i<2
		or c:getColor()==cards[1]:getColor()
		then continue end
		if c:getNumber()>cards[1]:getNumber()
		then
			table.insert(give,c:getEffectiveId())
			table.insert(give,cards[1]:getEffectiveId())
		else
			table.insert(give,cards[1]:getEffectiveId())
			table.insert(give,c:getEffectiveId())
		end
		break
	end
	self.hx_to = {}
    local tos = sgs.QList2Table(self.room:getOtherPlayers(self.player)) -- 将列表转换为表
	for _,p in sgs.list(tos)do
		if self:isEnemy(p) and #self.hx_to==1
		then table.insert(self.hx_to,p) end
		if #self.hx_to<1 and not self:isEnemy(p)
		then table.insert(self.hx_to,p) end
	end
	for _,p in sgs.list(tos)do
		if not self:isFriend(p) and #self.hx_to==1
		and self.hx_to[1]~=p
		then table.insert(self.hx_to,p) end
		if #self.hx_to<1
		then table.insert(self.hx_to,p) end
	end
	if #self.hx_to<2
	or #give<2
	then return end
	local parse = sgs.Card_Parse("#bf_huoxinCard:"..table.concat(give,"+")..":")
	assert(parse)
	return parse
end

sgs.ai_skill_use_func["#bf_huoxinCard"] = function(card,use,self)
	use.card = card
	for _,to in sgs.list(self.hx_to)do
		if use.to
		and use.to:length()<2
		then use.to:append(to) end
	end
end

sgs.ai_use_value.bf_huoxinCard = 5.4
sgs.ai_use_priority.bf_huoxinCard = 2.4

--[[
local bf_tianxing={}
bf_tianxing.name="bf_tianxing"
table.insert(sgs.ai_skills,bf_tianxing)
bf_tianxing.getTurnUseCard = function(self)
	local player = self.player
    local stars = player:getPile("powerful")
    stars = sgs.QList2Table(stars) -- 将列表转换为表
	if #stars<2
	then return end
	local give = {}
	table.insert(give,stars[1])
	table.insert(give,stars[2])
    local cards = player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards>2
	and self:isWeak()
	and #self.friends_noself>0
	and #cards>=player:getMaxCards()
	then
		for i,c in sgs.list(cards)do
			if math.mod(i,2)~=1
			or c:isEquipped()
			then continue end
			table.insert(give,c:getEffectiveId())
		end
		self.bf_tianxing_choice = "nosrende"
		local parse = sgs.Card_Parse("#bf_tianxingCard:"..table.concat(give,"+")..":")
		assert(parse)
		if #give>3
		then return parse end
	end
	if player:usedTimes("#zhihengCard")<1
	then
		for _,c in sgs.list(cards)do
			if #give-2>=#cards/2
			then break end
			table.insert(give,c:getEffectiveId())
		end
		local parse = sgs.Card_Parse("#bf_tianxingCard:"..table.concat(give,"+")..":")
		assert(parse)
		self.bf_tianxing_choice = "zhiheng"
		if #give>3
		then return parse end
	end
	for _,c in sgs.list(cards)do
		if c:getEffectiveId()==cards[1]:getEffectiveId()
		or c:getType()~=cards[1]:getType()
		or c:isEquipped()
		then continue end
		stars = sgs.Sanguosha:cloneCard("archery_attack")
		stars:addSubcard(c)
		stars:addSubcard(cards[1])
		stars:deleteLater()
		stars = self:aiUseCard(stars)
		if stars.card
		then
			self.bf_tianxing_choice = "luanji"
	    	table.insert(give,cards[1]:getEffectiveId())
	    	table.insert(give,c:getEffectiveId())
			local parse = sgs.Card_Parse("#bf_tianxingCard:"..table.concat(give,"+")..":")
			assert(parse)
			return parse
		end
		break
	end
	if #cards>2
	and #self.friends_noself>0
	and #cards>=player:getMaxCards()
	then
		for i,c in sgs.list(cards)do
			if math.mod(i,2)~=1
			or c:isEquipped()
			then continue end
			table.insert(give,c:getEffectiveId())
		end
		self.bf_tianxing_choice = "nosrende"
		local parse = sgs.Card_Parse("#bf_tianxingCard:"..table.concat(give,"+")..":")
		assert(parse)
		if #give>3
		then return parse end
	end
end
--]]
local bf_tianxing={}
bf_tianxing.name="bf_tianxing"
table.insert(sgs.ai_skills,bf_tianxing)
bf_tianxing.getTurnUseCard = function(self)
    local stars = self.player:getPile("powerful")
    stars = sgs.QList2Table(stars) -- 将列表转换为表
	if #stars<1 then return end
    local cards = {}
	for i,id in sgs.list(stars)do
		table.insert(cards,sgs.Sanguosha:getCard(id))
	end
    self:sortByKeepValue(cards) -- 按保留值排序
	local parse = sgs.Card_Parse("#bf_tianxingCard:"..cards[#cards]:getEffectiveId()..":")
	assert(parse)
	if self:isWeak()
	and #self.friends_noself>0
	and self.player:getHandcardNum()>2
	and self.bf_tianxing_choice~="nosrende"
	then
		self.bf_tianxing_choice = "nosrende"
		return parse
	end
	stars = self.player:getHandcards()
	stars:append(cards[#cards])
	for i,c in sgs.list(sgs.QList2Table(stars))do
		if i>1
		and c:getSuit()==cards[1]:getSuit()
		then
			i = sgs.Sanguosha:cloneCard("archery_attack")
			i:addSubcard(c)
			i:addSubcard(cards[1])
			i:setSkillName("luanji")
			i = self:aiUseCard(i)
			if i.card
			then
				self.bf_tianxing_choice = "luanji"
				return parse
			end
		end
	end
	if self.player:usedTimes("#bf_jilveCard")<1
	and self.player:getCardCount()>0
	then
		self.bf_tianxing_choice = "zhiheng"
		return parse
	end
	if self.player:getHandcardNum()>self.player:getMaxCards()
	and self.bf_tianxing_choice~="nosrende"
	and #self.friends_noself>0
	then
		self.bf_tianxing_choice = "nosrende"
		return parse
	end
end

sgs.ai_skill_use_func["#bf_tianxingCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.bf_tianxingCard = 4.4
sgs.ai_use_priority.bf_tianxingCard = 4.4

local bf_zhanhuo={}
bf_zhanhuo.name="bf_zhanhuo"
table.insert(sgs.ai_skills,bf_zhanhuo)
bf_zhanhuo.getTurnUseCard = function(self)
	local can = 0
	if self.player:getMark("@junlve")<#self.enemies+1
	then return end
	for _,p in sgs.list(self.enemies)do
		if p:isChained()
		then can = can+2 end
		if self:isWeak(p)
		and p:isChained()
		then can = can+1 end
	end
	if can<=#self.enemies+1
	then return end
	local parse = sgs.Card_Parse("#bf_zhanhuoCard:.:")
	assert(parse)
	return parse
end

sgs.ai_skill_use_func["#bf_zhanhuoCard"] = function(card,use,self)
	local player = self.player
	self:sort(self.enemies,"hp")
	for _,to in sgs.list(self.enemies)do
		use.card = card
		if use.to
		and to:isChained()
		then
--			local n = math.max(to:getCardCount()/2,1)
--			for i=1,n do
		    	if use.to:length()>=player:getMark("@junlve")
				then return end
				use.to:append(to)
--			end
		end
	end
	--[[
	for i=1,player:getMark("@junlve")do
		for _,to in sgs.list(self.enemies)do
			use.card = card
			if use.to
			then
				if use.to:length()>=player:getMark("@junlve")
				then return end
				use.to:append(to)
			end
		end
	end--]]
end

sgs.ai_use_value.bf_zhanhuoCard = 3.4
sgs.ai_use_priority.bf_zhanhuoCard = 0.4

local bf_yingba={}
bf_yingba.name="bf_yingba"
table.insert(sgs.ai_skills,bf_yingba)
bf_yingba.getTurnUseCard = function(self)
	if self.player:getLostHp()<3
	then return end
	local parse = sgs.Card_Parse("#bf_yingbaCard:.:")
	assert(parse)
	for _,p in sgs.list(self.enemies)do
		if p:getHp()>self.player:getHp()
		and (not self:isWeak(p) or p:getLostHp()<2)
		then return parse end
	end
end

sgs.ai_skill_use_func["#bf_yingbaCard"] = function(card,use,self)
	local player = self.player
	self:sort(self.enemies,"hp")
	for _,to in sgs.list(self.enemies)do
		if to:getMark("&bf_pingding")<1
		and not self:isWeak(to)
		and to:getHp()>player:getHp()
		then
			use.card = card
		   	if use.to then use.to:append(to) end
			return
		end
	end
	for _,to in sgs.list(self.enemies)do
		if to:getHp()>player:getHp()
		then
			use.card = card
		   	if use.to then use.to:append(to) end
			return
		end
	end
end

sgs.ai_use_value.bf_yingbaCard = 3.4
sgs.ai_use_priority.bf_yingbaCard = 6.4

local bf_yeyan={}
bf_yeyan.name="bf_yeyan"
table.insert(sgs.ai_skills,bf_yeyan)
bf_yeyan.getTurnUseCard = function(self)
	local give,ids,can = {},{},0
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,c in sgs.list(cards)do
		if table.contains(give,c:getSuit())
		or #give>self.player:getHp()
		then continue end
    	table.insert(give,c:getSuit())
    	table.insert(ids,c:getEffectiveId())
	end
	for _,p in sgs.list(self.enemies)do
		if self:isWeak(p)
		then can = can+1 end
		if p:getHp()<2
		then can = can+2 end
	end
	if can<#self.enemies+1
	or #ids<3
	then return end
	local parse = sgs.Card_Parse("#bf_yeyanCard:"..table.concat(ids,"+")..":")
	assert(parse)
	return parse
end

sgs.ai_skill_use_func["#bf_yeyanCard"] = function(card,use,self)
	self:sort(self.enemies,"hp")
	for _,to in sgs.list(self.enemies)do
		if use.to
		then
			for i=1,to:getHp()do
		    	if use.to:length()>=card:subcardsLength()
				then return end
				use.to:append(to)
				use.card = card
			end
		end
	end
	for i=1,5 do
		for _,to in sgs.list(self.enemies)do
			if use.to
			then
				if use.to:length()>=card:subcardsLength()
				then return end
				use.card = card
				use.to:append(to)
			end
		end
	end
end

sgs.ai_use_value.bf_yeyanCard = 3.4
sgs.ai_use_priority.bf_yeyanCard = 2.4

local bf_jilve={}
bf_jilve.name="bf_jilve"
table.insert(sgs.ai_skills,bf_jilve)
bf_jilve.getTurnUseCard = function(self)
	local give,cns = {},{}
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards,false) -- 按保留值排序
	for _,c in sgs.list(cards)do
		if #give>=#cards/2 then break end
		if c:isKindOf("Lightning") and self.player:getMark("@bear")>1
		or c:isKindOf("WoodenOx") and self.player:getPile("wooden_ox"):length()>1
		then continue end
		if cns[c:objectName()]
		or self:getUseValue(c)<3
		then
			table.insert(give,c:getEffectiveId())
		end
		cns[c:objectName()] = true
	end
	if #give<2 then return end
	local parse = sgs.Card_Parse("#bf_jilveCard:"..table.concat(give,"+")..":")
	assert(parse)
	return parse
end

sgs.ai_skill_use_func["#bf_jilveCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.bf_jilveCard = 3.4
sgs.ai_use_priority.bf_jilveCard = 3.4

sgs.ai_view_as.bf_jilve = function(card,player,card_place)
   	if card_place==sgs.Player_PlaceHand
   	and player:getMark("@bear")>1
	and card:isBlack()
   	then
	   	return ("nullification:kanpo[no_suit:0]="..card:getEffectiveId())
	end
end

local bf_longhun_skill={}
bf_longhun_skill.name="bf_longhun"
table.insert(sgs.ai_skills,bf_longhun_skill)
bf_longhun_skill.getTurnUseCard = function(self)
	local n = math.max(1,self.player:getHp())
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	if n<3
	then
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:setSkillName("bf_longhun")
    	for _,c in sgs.list(cards)do
        	if slash:subcardsLength()>=n
			then return slash end
	    	if c:getSuit()==1
	    	then slash:addSubcard(c) end
	    end
       	slash:deleteLater()
	end
end

sgs.ai_view_as.bf_longhun = function(card,player,card_place,class_name)
	local n = math.max(1,player:getHp())
	if class_name=="Peach"
	and player:getMark("Global_PreventPeach")>0
	then return end
   	if (card_place==sgs.Player_PlaceHand
	or card_place==sgs.Player_PlaceEquip)
   	and n<2
	then
    	if card:getSuit()==sgs.Card_Heart
    	then return ("peach:bf_longhun[no_suit:0]="..card:getEffectiveId())
    	elseif card:getSuit()==sgs.Card_Spade
    	then return ("nullification:bf_longhun[no_suit:0]="..card:getEffectiveId())
    	elseif card:getSuit()==sgs.Card_Club
    	then return ("slash:bf_longhun[no_suit:0]="..card:getEffectiveId())
    	elseif card:getSuit()==sgs.Card_Diamond
    	then return ("jink:bf_longhun[no_suit:0]="..card:getEffectiveId()) end
	end
end

local bf_zuoxing={}
bf_zuoxing.name="bf_zuoxing"
table.insert(sgs.ai_skills,bf_zuoxing)
bf_zuoxing.getTurnUseCard = function(self)
    local cards = hasCard(self.player,"TrickCard")
    if not cards then return end
    cards = self:sortByKeepValue(cards) -- 按保留值排序
	for _,c in sgs.list(cards)do
		for _,name in sgs.list(patterns)do
           	local poi = sgs.Sanguosha:cloneCard(name)
			if poi:isKindOf("TrickCard")
			and c:objectName()~=name
			and poi:isDamageCard()
			then
				poi:addSubcard(c)
				poi:setSkillName("zuoxing")
				local dummy = self:aiUseCard(poi)
				if dummy.card and dummy.to
				then return poi end
			end
           	poi:deleteLater()
	   	end
	end
	for _,c in sgs.list(cards)do
		for _,name in sgs.list(patterns)do
           	local poi = sgs.Sanguosha:cloneCard(name)
			if poi:isKindOf("TrickCard")
			and c:objectName()~=name
			then
				poi:addSubcard(c)
				poi:setSkillName("zuoxing")
				local dummy = self:aiUseCard(poi)
				if dummy.card and dummy.to
				then return poi end
			end
           	poi:deleteLater()
	   	end
	end
end

sgs.ai_view_as.bf_zuoxing = function(card,player,card_place,class_name)
   	local pattern = PatternsCard(class_name)
    if not pattern
	or card_place~=sgs.Player_PlaceHand
	or player:getMark("bf_zuoxing-Clear")<1
	or card:objectName()==pattern:objectName()
	then return end
    if card:isKindOf("TrickCard")
    and pattern:isKindOf("TrickCard")
	then
       	return (pattern:objectName()..":zuoxing[no_suit:0]="..card:getEffectiveId())
    end
end

sgs.ai_skill_playerchosen.bf_huishi = function(self,players)
	local player = self.player
	local destlist,n = players,self:getCardsNum("Analeptic","he")+self:getCardsNum("Peach","he")
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		and self:isWeak(target)
		and target:isWounded()
		and target~=player
		and n>0
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		then
           	for _,sk in sgs.list(target:getVisibleSkillList())do
	           	if sk:getFrequency(target)==sgs.Skill_Wake
				and target:getMark(sk:objectName())<1
				and target:getHp()>0
				then return target end
            end
		end
	end
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		and target:isWounded()
		then
           	for _,sk in sgs.list(target:getVisibleSkillList())do
	           	if sk:getFrequency(target)==sgs.Skill_Wake
				and target:getMark(sk:objectName())>0
				then return target end
            end
		end
	end
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		and target:isWounded()
		and target~=player
		then return target end
	end
    return player
end

local bf_huizhi={}
bf_huizhi.name="bf_huizhi"
table.insert(sgs.ai_skills,bf_huizhi)
bf_huizhi.getTurnUseCard = function(self)
    local cards = sgs.QList2Table(self.player:getCards("h"))
    self:sortByKeepValue(cards) -- 按保留值排序
    for _,sk in sgs.list(self.player:getVisibleSkillList())do
	   	if sk:getFrequency(self.player)==sgs.Skill_Wake
		and self.player:getMark(sk:objectName())<1
		and self:getCardsNum("Analeptic","he")+self:getCardsNum("Peach","he")<1
		and self.player:getHp()<2
		then return end
    end
	local parse = sgs.Card_Parse("#bf_huizhicard:.:")
    assert(parse)
    return parse
end

sgs.ai_skill_use_func["#bf_huizhicard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.bf_huizhicard = 5.4
sgs.ai_use_priority.bf_huizhicard = 6.4

sgs.ai_skill_discard.lingce = function(self)
    local player = self.player
	local to_discard = {}
	local cards = player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if #cards>1
	and (bf_lingce_c.card:isDamageCard()
	or self:isEnemy(bf_lingce_c.from) and bf_lingce_c.card:isKindOf("SingleTargetTrick"))
	then
    	table.insert(to_discard,cards[1]:getEffectiveId())
	end
	return to_discard
end

function SmartAI:useCardQizhengxiangsheng(card,use)
	local player = self.player
	self:sort(self.enemies,"hp")
	for _,ep in sgs.list(self.enemies)do
		if CanToCard(card,player,ep,use.to)
		then
	       	use.card = card
	       	if use.to
	    	then use.to:append(ep) end
		end
	end
end
sgs.ai_use_priority.Qizhengxiangsheng = 5.4
sgs.ai_keep_value.Qizhengxiangsheng = 3.5
sgs.ai_use_value.Qizhengxiangsheng = 5.7

sgs.ai_skill_cardask["_qizhengxiangsheng_card"] = function(self,data)
	if self:getCardsNum("Jink","he")>1
	then return self:getCardId("Jink") end
    return self:getCardId("Slash") or "."
end

sgs.ai_skill_choice["_bf_qizhengxiangsheng"] = function(self,choices,data)
	local player = self.player
    local effect = data:toCardEffect()
	if effect.to:isKongcheng()
	and math.random()<0.7
	then return "zhengbing" end
	if effect.to:isNude()
	then return "zhengbing" end
end

function SmartAI:useCardBfPoison(card,use)
	local player = self.player
    local enemies = sgs.QList2Table(self.room:getOtherPlayers(player))
	self:sort(enemies,"handcard")
	for _,ep in sgs.list(enemies)do
		if CanToCard(card,player,ep,use.to)
		and self:isEnemy(ep)
		then
	       	use.card = card
	       	if use.to
	    	then use.to:append(ep) end
		end
	end
	for _,ep in sgs.list(enemies)do
		if CanToCard(card,player,ep,use.to)
		and not self:isFriend(ep)
		then
	       	use.card = card
	       	if use.to
	    	then use.to:append(ep) end
		end
	end
end
sgs.ai_use_priority.BfPoison = 3.4
sgs.ai_keep_value.BfPoison = 5
sgs.ai_use_value.BfPoison = 5.7

--[[
sgs.ai_skill_discard.bf_poison = function(self)
	local player = self.player
	local cards = player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _,c in sgs.list(cards)do
    	if c:getSuit()==player:getMark("bf_poison")
		then return c:getEffectiveId() end
	end
end
--]]

function SmartAI:useCardBfXiejiagt(card,use)
	local player = self.player
	self:sort(self.enemies,"hp")
	for _,ep in sgs.list(self.enemies)do
		if CanToCard(card,player,ep,use.to)
		then
	       	use.card = card
	       	if use.to
	    	then use.to:append(ep) end
		end
	end
	for _,ep in sgs.list(self.friends)do
		if CanToCard(card,player,ep,use.to)
		and ep:getEquips():length()>1
		and not self:isWeak(ep)
		then
	       	use.card = card
	       	if use.to
	    	then use.to:append(ep) end
		end
	end
end
sgs.ai_use_priority.BfXiejiagt = 4.4
sgs.ai_keep_value.BfXiejiagt = 2.5
sgs.ai_use_value.BfXiejiagt = 4.7

sgs.ai_nullification.BfXiejiagt = function(self,trick,from,to,positive)
    return self:isFriend(to)
	and to:getArmor()
	and self:isWeak(to)
	and positive
end










