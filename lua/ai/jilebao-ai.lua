



sgs.ai_skill_invoke.jl_qingshen = function(self,data)
	local target = self.player
	return true
end

sgs.ai_skill_invoke.jl_liyue = function(self,data)
	local target = self.player
	return true
end

sgs.ai_skill_invoke.jl_xiaoyin = function(self,data)
	local target = self.player
	return true
end

sgs.ai_skill_invoke.jl_guikui = function(self,data)
	local target = self.player
   	local damage = data:toDamage()
	return damage.from and not self:isFriend(damage.from)
end

sgs.ai_skill_invoke.jl_tianji = function(self,data)
	local target = self.player
	return true
end

sgs.ai_skill_playerchosen.jl_quming = function(self,players)
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"handcard")
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		and target:getHandcardNum()<target:getMaxHp()
		then
            return target
		end
	end
    return nil
end

sgs.ai_skill_invoke.jl_luoshi = function(self,data)
	local target = self.player
	return true
end

sgs.ai_skill_invoke.jl_shangqing = function(self,data)
	local target = self.player
	return true
end

sgs.ai_skill_playerchosen.jl_leidao = function(self,players)
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
    	if self:isEnemy(target)
		then
            return target
		end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isFriend(target)
		then
            return target
		end
	end
    return nil
end

sgs.ai_skill_invoke.jl_zhizheng = function(self,data)
	local cards = self.player:getTag("jl_zhizheng"):toString():split("+")
	local target = data:toPlayer()
	return self:isFriend(target) or #cards>1
end

sgs.ai_skill_askforag.jl_zhizheng = function(self,card_ids)
	return sgs.ai_skill_askforag.guzheng(self,card_ids)
end

sgs.ai_skill_playerchosen.jl_weimou = function(self,players)
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		and target:getHandcardNum()<target:getMaxHp()
		then
            return target
		end
	end
    return nil
end

sgs.ai_skill_invoke.jl_weimou = function(self,data)
	local target = self.player
	return true
end

sgs.ai_skill_invoke.jl_yingjian = function(self,data)
	local target = self.player
	return true
end

sgs.ai_skill_invoke.jl_haomeng = function(self,data)
	local least = 1000
	for _,p in sgs.list(self.player:getAliveSiblings())do
		least = math.min(p:getHandcardNum(),least)
	end
	for _,p in sgs.list(self.player:getAliveSiblings())do
		if p:getHandcardNum()==least
		and not self:isEnemy(p)
		then return true end
	end
	if self.player:getHandcardNum()+5<6 then return true end
end

sgs.ai_skill_invoke.jl_qianying = function(self,data)
	local target = self.player
	return true
end

sgs.ai_skill_invoke.jl_wangba = function(self,data)
	local target = self.player
	return true
end

sgs.ai_skill_invoke.jl_yushanss = function(self,data)
	return sgs.ai_skill_invoke.jl_guanbingcj(self,data)
end

sgs.ai_skill_invoke.jl_chengcha = function(self,data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end

sgs.ai_skill_playerchosen.jl_jianjie = function(self,players)
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
    	if self:isEnemy(target)
		then
            return target
		end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isFriend(target)
		then
            return target
		end
	end
    return destlist[1]
end

sgs.ai_skill_invoke.yinshi = function(self,data)
	return true
end

sgs.ai_skill_playerchosen.jianyan = function(self,players)
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
    	if self:isFriend(target)
		and target:isMale()
		then
            return target
		end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isEnemy(target)
		and target:isMale()
		then
            return target
		end
	end
    return destlist[1]
end

sgs.ai_skill_playerchosen.jl_yinbing = function(self,players)
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
    	if self:isEnemy(target)
		then
            return target
		end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isFriend(target)
		then
            return target
		end
	end
    return destlist[1]
end

sgs.ai_skill_invoke.jl_fuhun = function(self,data)
	local target = self.player
	return self:getCardsNum("Slash","h")>1
	and self:getCardsNum("Spear","he")>0
	and #self.enemies>0
end

sgs.ai_skill_invoke.jl_yangguang = function(self,data)
	local target = data:toPlayer()
	return self:isFriend(target) or self:getCardsNum("Jink","h")<2
end

sgs.ai_skill_invoke.jl_zhenggong = function(self,data)
	return self.player:hasSkill("nosjushou") or sgs.ai_skill_invoke.zhenggong(self,data)
end

sgs.ai_skill_invoke.jl_kuangcai = function(self,data)
	local target = self.player
	return true
end

sgs.ai_skill_invoke.jl_guanbingcj = function(self,data)
	local items = data:toString():split(":")
	if table.contains(items,"choice1")
	then
    	local target = self.room:findPlayerByObjectName(items[2])
    	return not self:isFriend(target)
	end
	if table.contains(items,"choice2")
	then
	   	local slash = dummyCard()
    	for _,fp in sgs.list(items[2]:split("+"))do
        	fp = self.room:findPlayerByObjectName(fp)
            for _,s in sgs.list(sgs.getPlayerSkillList(fp))do
                s = s:objectName()
				local sk = sgs.ai_target_revises[s]
	        	if type(sk)=="function" and sk(fp,slash)
	           	then return false end
			end
    	end
		if self.to_fire_slash
		then
			self.to_fire_slash = false
			return true
		end
	end
	if table.contains(items,"choice3")
	then
    	local target = self.room:findPlayerByObjectName(items[2])
    	return self:isFriend(target) or target:getHp()>4
	end
	if table.contains(items,"choice4")
	then
    	local target = self.room:findPlayerByObjectName(items[2])
        local cards = target:getCards("he")
        cards = sgs.QList2Table(cards) -- 将列表转换为表
		items = self.player:getTag("SlashDamage"):toDamage()
		items = items.card:subcardsLength()
     	return self:isFriend(target) or (target:getHp()>4 and #cards>3)
		and items<2
	end
end

sgs.ai_skill_invoke.jl_bingyuegong = function(self,data)
	return sgs.ai_skill_invoke.jl_guanbingcj(self,data)
end

sgs.ai_skill_invoke.jl_yanlinmao = function(self,data)
	return sgs.ai_skill_invoke.jl_guanbingcj(self,data)
end

sgs.ai_skill_cardask["@jl_zhugong-card"] = function(self,data)
	local dama = data:toPlayer()
	if not self:isFriend(dama)
	then return "." end
end

sgs.ai_skill_invoke.jl_fengliang = function(self,data)
	return self.player:isWounded()
end

sgs.ai_skill_playerchosen.jl_fengliang = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp",true)
    for _,target in sgs.list(destlist)do
    	if self:isEnemy(target)
		then
            return target
		end
	end
    for _,target in sgs.list(destlist)do
    	if not self:isFriend(target)
		then
            return target
		end
	end
    return destlist[1]
end

sgs.ai_skill_invoke.jl_lijie = function(self,data)
	return math.random()<1/3
end

sgs.ai_skill_invoke.jl_lijies = function(self,data)
	return math.random()<1/3
end

sgs.ai_skill_playerchosen.jl_yinghun = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard",false)
    for _,target in sgs.list(destlist)do
    	self.jl_yinghun_invoke = false
		if self:isEnemy(target)
		and self.player:getLostHp()<target:getHandcardNum()
		then return target end
	end
    for _,target in sgs.list(destlist)do
    	self.jl_yinghun_invoke = true
    	if self:isFriend(target)
		and self.player:getLostHp()>target:getHandcardNum()
		then return target end
	end
end

sgs.ai_skill_invoke.jl_yinghun = function(self,data)
	return self.jl_yinghun_invoke
end

sgs.ai_skill_invoke.jl_shanjia = function(self,data)
	local target = self.player
	return true
end

sgs.ai_skill_invoke.jl_guiying = function(self,data)
	return self.player:getMark("jl_jinghun_1")<5
	or self.player:getMark("jl_jinghun_2")<5
	or self.player:getMark("jl_jinghun_4")<5
end

sgs.ai_skill_choice.jl_guiying = function(self,choices)
	local items = choices:split("+")
	for _,h in sgs.list(items)do
     	local x = math.random(1,#items)
    	if items[x]~="jl_jinghun_3"
    	then return items[x] end
	end
end

sgs.ai_skill_invoke.jl_jinghun = function(self,data)
	local target = data:toPlayer()
	return self:isFriend(target)
	or self.player:getMark("jl_jinghun_3")<self.player:getMark("jl_jinghun_2")
end

sgs.ai_skill_invoke.koulve = function(self,data)
	local target = data:toPlayer()
	return not self:isFriend(target)
	and target:getHandcardNum()>2
end

sgs.ai_skill_playerchosen.suirenq = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
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

sgs.ai_skill_invoke.chexuan = function(self,data)
	return true
end

sgs.ai_skill_invoke["_feilunzhanyu"] = function(self,data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end

sgs.ai_skill_invoke["_tiejixuanyu"] = function(self,data)
	local target = data:toPlayer()
	return self:isEnemy(target)
	and (target:getHandcardNum()>1
	or target:hasEquip())
end

sgs.ai_skill_invoke["_sichengliangyu"] = function(self,data)
	return true
end

sgs.ai_skill_invoke.zhenting1 = function(self,data)
	local items = data:toString():split(":")
    local target = self.room:findPlayerByObjectName(items[2])
	if self:isFriend(target)
	then return target
	else
    	if target:getHandcardNum()>3
		then return target end
	end
end

sgs.ai_skill_playerchosen.jl_xingtuo = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard")
    for _,target in sgs.list(destlist)do
		if self:isWeak(target)
		and target:isWounded()
		and self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if target:isWounded()
		and self:isFriend(target)
		then return target end
	end
    return self.player
end

sgs.ai_skill_playerchosen.jl_xianchou = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card")
	local card = self.player:getTag("JudgeCard_jl_xianchou"):toCard()
	if card and card:isRed()
	then
        for _,target in sgs.list(destlist)do
	    	if self:isWeak(target)
	    	and self:isFriend(target)
	    	then return target end
    	end
        for _,target in sgs.list(destlist)do
	    	if self:isFriend(target)
	    	then return target end
    	end
	else
		for _,target in sgs.list(destlist)do
	    	if not self:isFriend(target) then continue end
           	if target:containsTrick("__jl_mu")
			or target:containsTrick("jl_shunshoubl")
			or target:containsTrick("jl_lebucq")
			or target:containsTrick("indulgence")
			or target:containsTrick("supply_shortage")
			or self:doDisCard(target,"ej")
			then return target end
    	end
        card = dummyCard("dismantlement")
		card = self:aiUseCard(card)
		if card.card and card.to and card.to:length()>0
		then return card.to:at(0) end
		for _,target in sgs.list(destlist)do
	    	if not self:isFriend(target) then continue end
           	for _,j in sgs.list(target:getJudgingArea())do
		    	if self:isWeak(target) and j:isDamageCard()
				then return target
				elseif not j:isDamageCard()
				then return target end
			end
    	end
        for _,target in sgs.list(destlist)do
	    	if self:isWeak(target)
	    	and self:isEnemy(target)
			and not target:isNude()
	    	then return target end
    	end
        for _,target in sgs.list(destlist)do
	    	if not self:isFriend(target)
			and self:doDisCard(target,"ej")
	    	then return target end
    	end
        for _,target in sgs.list(destlist)do
	    	if not self:isFriend(target)
			and self:doDisCard(target,"hej")
	    	then return target end
    	end
        for _,target in sgs.list(destlist)do
	    	if self:doDisCard(target,"hej")
	    	then return target end
    	end
        for _,target in sgs.list(destlist)do
	    	if self:isFriend(target)
			and self:doDisCard(target,"ej")
	    	then return target end
    	end
        for _,target in sgs.list(destlist)do
	    	if target:getCardCount(true,true)>0
	    	then return target end
    	end
	end
    return destlist[1]
end

sgs.ai_skill_invoke.jl_xingtuo0 = function(self,data)
	local items = data:toString():split(":")
    local target = self.room:findPlayerByObjectName(items[2])
	local num = self:getCardsNum("Peach")
	if self:isFriend(target)
	then
		return target:getHp()<1
		and self.player:getHp()>1
		and num<1
	end
end

sgs.ai_skill_invoke.jl_xingtuo = function(self,data)
	return self:getCardsNum("Peach")<1
	and self:getCardsNum("Analeptic")<1
end

sgs.ai_skill_invoke.guhuo_question = function(self,data)
	local sk = data:toString():split(":")
	local from = self.room:findPlayerByObjectName(sk[2])
	if self:isFriend(from) then return false end
	if not self:isEnemy(from)
	and self:isWeak(self.player)
	then return false end
	local card = dummyCard(sk[3])
	local guhuotype = card:getClassName()
	if self:getRestCardsNum(guhuotype,from)<1
	and self:isEnemy(from)
	and self.player:getHp()>1
	then return true
	elseif guhuotype=="AmazingGrace"
	then return false
	elseif guhuotype:match("Slash")
	then
		if from:getState()~="robot"
		and math.random(0,4)<2
		then return true end
		if not self:hasCrossbowEffect(from)
		then return false end
	end
	local x = 4
	if sk[3]=="peach"
	or sk[3]=="ex_nihilo"
	then
		x = 3
		if getKnownCard(from,self.player,guhuotype,false)>0
		then x = x*2 end
	end
	if self:isEnemy(from)
	and card:isDamageCard()
	then x = x-1 end
	if math.random(0,x)<2
	then return true end
	if math.random(0,(self.player:getHp()/2)+1)<2
	then return false
	else return true end
end

sgs.ai_skill_invoke.jl_yegui = function(self,data)
	local items = data:toString():split(":")
	if items[1]=="jl_yegui2"
	or items[1]=="jl_yegui3"
	or items[1]=="jl_yegui4"
	or items[1]=="jl_yegui5"
	then return true end
end

sgs.ai_skill_choice.jl_xianfa = function(self,choices)
	local items = choices:split("+")
	if table.contains(items,self.xf_to_name)
	then return self.xf_to_name end
	return items[1]
end

sgs.ai_skill_discard.jl_yegui = function(self)
	local cards = self.player:handCards()
	cards = sgs.QList2Table(cards)
	return cards
end

sgs.ai_skill_invoke.jl_yachai = function(self,data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end

sgs.ai_skill_playerchosen.jl_mingqi = function(self,players)
	local n = self.player:getMark("jl_mingqiChosen")
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard")
	if n<1
	then
    	n = sgs.ai_skill_playerchosen.qizhi(self,players)
	elseif n<5
	then
		n = self.player:getTag("jl_mingqi_daiyan"):toString()
		for _,target in sgs.list(destlist)do
			if target:objectName()~=n
			and self:isFriend(target)
			then return target end
		end
		return nil
	elseif n<8
	then
    	local c = self.player:getTag("jl_mingqi"):toString()
		c = dummyCard(c)
		c:setSkillName("_jl_mingqi")
		local dummy = self:aiUseCard(c)
		n = nil
		if dummy.card
		and dummy.to
		then
			for _,target in sgs.list(destlist)do
				if target:getHandcardNum()>0
				and self:isFriend(target)
				then return target end
			end
			return n
		end
	end
    return n
end

sgs.ai_skill_invoke.jl_mingqi = function(self,data)
	local items = data:toString():split(":")
	if items[1]=="jl_mingqi5"
	then
        local target = self.room:findPlayerByObjectName(items[2])
		if self:isFriend(target)
		then
			for _,ep in sgs.list(self.enemies)do
				if self:isWeak(ep)
				and target:canSlash(ep)
				then return true end
			end
		end
	elseif items[1]=="jl_mingqi1"
	then
     	local c = dummyCard(items[2])
		local dummy = self:aiUseCard(c)
		if self.player:isWounded()
		and c:isDamageCard()
		and dummy.card
		and dummy.to
		then
			for _,ep in sgs.list(self.enemies)do
				if self:isWeak(ep)
				then return true end
			end
		end
	elseif items[1]=="jl_mingqi2"
	then
    	if self.player:getHandcardNum()>1
		then return true end
	end
end

sgs.ai_skill_choice.jl_mingqi = function(self,choices)
	local items = choices:split("+")
	local to = jl_mingqi_damage.to
	return not self:isFriend(to) and #items>2 and items[#items-1] or "cancel"
end

sgs.ai_skill_invoke.jl_neifa = function(self,data)
	return true
end

sgs.ai_skill_invoke.jl_jianxiong = function(self,data)
	local damage = data:toDamage()
	return damage.from and not self:isFriend(damage.from)
	or damage.card and damage.card:getSubcards():length()>0
end

sgs.ai_skill_invoke.jl_bianjie = function(self,data)
	return true
end

sgs.ai_skill_invoke.jl_jianshi = function(self,data)
	local items = data:toString():split(":")
	if items[1]=="jl_jianshi0"
	then
        local target = self.room:findPlayerByObjectName(items[2])
    	local slash = sgs.Sanguosha:cloneCard("slash")
		slash = self:aiUseCard(slash)
		if slash.card and slash.to
		then
			return slash.to:contains(target)
		end
	end
end

sgs.ai_skill_playerchosen.jl_shewei = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"handcard")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
end

sgs.ai_skill_invoke.jl_jixu = function(self,data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end

sgs.ai_skill_invoke.jl_mengsha = function(self,data)
   	local target = self.room:getCurrent()
	return not self:isFriend(target)
end

sgs.ai_skill_playerchosen.jl_luanpei = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and (self:isWeak(target) and target:isWounded() or target:isWounded())
		then return target end
	end
	return self.player
end

sgs.ai_skill_invoke.jl_jiejun = function(self,data)
	local use = data:toCardUse()
	return not self:isFriend(use.to:at(0))
end

sgs.ai_skill_playerchosen.jl_jiejun = function(self,players)
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

sgs.ai_skill_playerchosen.jl_chousi = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
	local c = self.player:getTag("JudgeCard_jl_chousi"):toCard()
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and c:isRed()
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and c:isBlack()
		and target:getCardCount()>0
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		and c:isBlack()
		and target:getCardCount()>0
		then return target end
	end
	return destlist[1]
end

sgs.ai_skill_invoke.jl_jice = function(self,data)
	local target = self.player
	local use = data:toCardUse()
	return not self:isFriend(use.to:at(0))
end

sgs.ai_skill_playerchosen.jl_yangxi = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and self:isWeak(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		and not self:isWeak(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		then return target end
	end
end

sgs.ai_skill_playerchosen.jl_shiyi = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if not self:isFriend(target)
		then return target end
	end
end

sgs.ai_skill_choice.jl_jiuxue = function(self,choices)
	local items,ns = choices:split("+"),{}
	for _,c in sgs.list(items)do
		if c-self.player:getHandcardNum()>0
		and c-self.room:getDrawPile():length()<0
		then table.insert(ns,c) end
	end
	local func =function(a,b)
		return a-b>0
	end
	table.sort(ns,func)
	return ns[1]
end

sgs.ai_skill_invoke.jl_shiyi = function(self,data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end

sgs.ai_skill_choice.jl_jiuxuevs = function(self,choices)
	local items,ns = choices:split("+"),self.jl_jiuxuevs_choice
	if ns then return ns
	elseif math.random()>0.7
	then
		self.jl_jiuxuevs_choice = 1.5
		return 1.5
	end
end

sgs.ai_skill_invoke.jl_zhendian = function(self,data)
    return self.player:hasEquip() and self:isWeak() or #self.enemies>0
end

function canZhengsu(self,player)
	local player = player or self.player
    local handcards = sgs.QList2Table(player:getCards("h"))
    self:sortByUsePriority(handcards)
	local tocs,ns = {},sgs.IntList()
   	for d,h in sgs.list(handcards)do
		if h:isAvailable(player)
		then
			d = self:aiUseCard(h)
			if d.card and d.to
			then table.insert(tocs,h) end
		end
	end
   	for d,h in sgs.list(tocs)do
		if ns:contains(h:getNumber()) then continue end
		ns:append(h:getNumber())
	end
	if ns:length()>2
	then
		self.zhengsu_choice = "zhengsu1"
		return true
	end
   	for d,h in sgs.list(tocs)do
		ns = 0
		for _,h1 in sgs.list(tocs)do
			if h:getSuit()==h1:getSuit()
			then ns = ns+1 end
		end
		if ns>2
		then
			self.zhengsu_choice = "zhengsu2"
			return true
		end
	end
	if #handcards-player:getMaxCards()>2
	and #handcards-player:getMaxCards()<5
	then
		self.zhengsu_choice = "zhengsu3"
		return true
	end
end

sgs.ai_skill_choice.zhengsu = function(self,choices)
	return self.zhengsu_choice
end

sgs.ai_skill_choice.jl_zhendian = function(self,choices)
	local items = choices:split("+")
	if self.player:hasEquip() and self:isWeak()
	and table.contains(items,"jl_zhendian2")
	then return "jl_zhendian2" end
	if (self.player:getHandcardNum()<3 or #self.enemies>0)
	and table.contains(items,"jl_zhendian1")
	then return "jl_zhendian1" end
	if canZhengsu(self) and #items>2
	and items[3]:startsWith("beishui_choice")
	then return items[3] end
    local ecards = sgs.QList2Table(self.player:getCards("e"))
    self:sortByKeepValue(ecards) -- 按保留值排序
	if #ecards>0 and self:isWeak()
	then
		for i,c in sgs.list(ecards)do
			i = c:getRealCard():toEquipCard():location()
			if self.player:getEquip(i)
			and table.contains(items,"@Equip"..i.."lose")
			then return "@Equip"..i.."lose" end
		end
	end
	for i,c in sgs.list(ecards)do
		i = c:getRealCard():toEquipCard():location()
		if self.player:getEquip(i)
		or self.player:hasEquipArea(i)
		then continue end
		return "@Equip"..i.."lose"
	end
end

sgs.ai_use_revises.jl_zhendian = function(self,card,use)
	local n = self.player:getMark("jl_zhendian_zhengsu-Clear")
	if n>0 and card:getTypeId()~=0
	then
		local ids = self.player:getTag("zhengsu-"..n):toString():split("+")
		if n<2
		then
			if #ids>0
			and ids[#ids]~=""
			and tostring(card:getNumber())<=ids[#ids]
			then return false end
		elseif n<3
		then
			if #ids>0
			and ids[#ids]~=""
			and tostring(card:getSuit())~=ids[#ids]
			then return false end
		elseif n>2
		then
			local handcards = sgs.QList2Table(self.player:getCards("h"))
			self:sortByKeepValue(handcards) -- 按保留值排序
			if #handcards-self.player:getMaxCards()==2
			then
				n = sgs.IntList()
				for _,h in sgs.list(handcards)do
					if n:contains(h:getSuit())
					then continue end
					n:append(h:getSuit())
				end
				if n:length()>1
				then return false end
			end
		end
	end
end

sgs.ai_skill_cardask.jl_zhendian3 = function(self,data,pattern,prompt)
	local handcards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(handcards) -- 按保留值排序
	local ids = {}
	for _,h in sgs.list(handcards)do
    	if sgs.Sanguosha:matchExpPattern(pattern,self.player,h)
		then table.insert(ids,h:getEffectiveId()) end
	end
	return #ids>1 and ids[1]
end

sgs.ai_skill_discard.jl_qianxue = function(self)
	local cards = {}
    local handcards = sgs.QList2Table(self.player:getCards("he"))
    self:sortByKeepValue(handcards) -- 按保留值排序
   	for _,h in sgs.list(handcards)do
		if #cards>2 or #cards>#handcards/2
		then break end
		table.insert(cards,h:getEffectiveId())
	end
	return cards
end

sgs.ai_skill_playerchosen.jl_chailu = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card",true)
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and target:getCardCount()>3
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if target:getCardCount()<4
		then return target end
	end
	return destlist[1]
end

sgs.ai_skill_invoke.jl_zhendianvs = function(self,data)
	return #self.enemies>0
end

sgs.ai_skill_invoke.Exchange = function(self,data)
	return #self.enemies>0 or #self.friends>1
end

sgs.ai_skill_discard.jl_zebing = function(self,m,x)
    local handcards = sgs.QList2Table(self.player:getCards("he"))
    self:sortByKeepValue(handcards) -- 按保留值排序
	local items = self.player:getTag("PreviewCards"):toString():split(",")
	local cards = {}
	if #items>0
	then
		local cs = {}
		for _,id in sgs.list(items)do
			table.insert(cs,sgs.Sanguosha:getCard(id))
		end
		self:sortByKeepValue(cs,true)
		for _,h in sgs.list(cs)do
			if #cards>=x then break end
			table.insert(cards,h:getEffectiveId())
		end
	else
		for _,h in sgs.list(handcards)do
			if #cards>=#handcards/2 or #cards>1 or #cards>=x then break end
			table.insert(cards,h:getEffectiveId())
		end
	end
	return cards
end

sgs.ai_skill_playerchosen.jl_zebing = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card",true)
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and target:getKingdom()=="shu"
		and target:getCardCount()>3
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and target:getKingdom()=="shu"
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
	return destlist[1]
end

sgs.ai_skill_invoke.jl_zebing11 = function(self,data)
	local items = data:toString():split(":")
	if items[1]=="jl_zebing13"
	then
        local target = self.room:findPlayerByObjectName(items[2])
    	return self:isFriend(target)
	end
end

sgs.ai_skill_invoke.jl_zebing = function(self,data)
	return self.player:getCardCount()>3
end

sgs.ai_skill_invoke.jl_chengxiang = function(self,data)
	return true
end

sgs.ai_skill_playerchosen.jl_chengxiang = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card",true)
	if self.cx_n-14<0
	then
		for _,target in sgs.list(destlist)do
			if self:isFriend(target)
			and target:getCardCount()<3
			then return target end
		end
		for _,target in sgs.list(destlist)do
			if self:isFriend(target)
			then return target end
		end
	else
		for _,target in sgs.list(destlist)do
			if self:isEnemy(target)
			and target:getCardCount()>0
			then return target end
		end
		for _,target in sgs.list(destlist)do
			if not self:isFriend(target)
			and target:getCardCount()>0
			then return target end
		end
		for _,target in sgs.list(destlist)do
			if not self:isFriend(target)
			then return target end
		end
	end
	return destlist[1]
end

sgs.ai_skill_choice.jl_chengxiang = function(self,choices)
	local items = choices:split("+")
	items = items[math.random(1,#items)]
	self.cx_n = string.sub(items,7,-1)
	return items
end

sgs.ai_skill_choice.jl_renxin = function(self,choices)
	local items,ns = choices:split("+"),{}
	for _,c in sgs.list(items)do
		ns[c] = string.sub(choices,7,-1)
	end
	local func =function(a,b)
		return a-b<=0
	end
	table.sort(ns,func)
	for _,c in sgs.list(ns)do
		return c
	end
end

sgs.ai_skill_choice.jl_zebing = function(self,choices)
	local items = choices:split("+")
	if table.contains(items,"jl_zebing20")
	then return "jl_zebing20" end
	if table.contains(items,"jl_zebing1")
	then return "jl_zebing1" end
end

sgs.ai_skill_playerchosen.jl_wuliang = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card",true)
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

sgs.ai_skill_invoke.jl_weiye = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return self:isFriend(target)
	end
	local items = data:toString():split(":")
    target = self.room:findPlayerByObjectName(items[2])
	if target
	then
		return self:isFriend(target)
	end
	return true
end

sgs.ai_skill_invoke.jl_wuce = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return self:isFriend(target)
	end
end

sgs.ai_skill_invoke.jl_qunli = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return self:isFriend(target)
	end
end

sgs.ai_skill_invoke.jl_leiji = function(self,data)
    return true
end

sgs.ai_skill_playerchosen.jl_leiji = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"hp")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and target:isWounded()
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if not self:isEnemy(target)
		then return target end
	end
end

sgs.ai_skill_cardask["jl_guidao0"] = function(self,data)
	local judge = data:toJudge()
	local all_cards = self.player:getCards("he")
	for _,id in sgs.list(self.player:getPile("wooden_ox"))do
		all_cards:prepend(sgs.Sanguosha:getCard(id))
	end
	if all_cards:isEmpty() then return "." end
	local cards = {}
	for _,c in sgs.list(all_cards)do
		if c:isRed()
		then
			table.insert(cards,c)
		end
	end
	if #cards<1 then return "." end
	local id = self:getRetrialCardId(cards,judge,nil,true)--从输入的牌表中选择一张可改判的牌的id并输出
	if id~=-1
	then
    	if self:needRetrial(judge)
		or self:getKeepValue(judge.card)>self:getKeepValue(sgs.Sanguosha:getCard(id))
		then return id end
	end
    return "."
end

sgs.ai_skill_invoke.jl_fenwei = function(self,data)
	local use = self.player:getTag("jl_fenwei"):toCardUse()
	if use.card:isDamageCard()
	then
		for _,to in sgs.list(use.to)do
			if self:isFriend(to)
			and self:isWeak(to)
			then return true end
		end
	end
end

sgs.ai_skill_invoke.jl_pangshu = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return not self:isFriend(target)
	end
end

sgs.ai_skill_choice["#n_ModeStart"] = function(self,choices)
	local items = choices:split("+")
	return items[#items]
end

sgs.ai_skill_invoke.jl_duzhan1 = function(self,data)
	local items = data:toString():split(":")
    local target = self.room:findPlayerByObjectName(items[2])
	if target
	then
		return not self:isFriend(target) or not self:isWeak(target)
	end
end

sgs.ai_skill_playerchosen.jl_xiance = function(self,players)
	return sgs.ai_skill_playerchosen.jl_xianchou(self,players)
end

sgs.jlUsePrioritys = {}

sgs.ai_event_callback[sgs.CardFinished].jl_bingfen = function(self,player,data)
	if sgs.jl_bingfen
	then
		local use = data:toCardUse()
		if sgs.bingfenTo
		and use.to:contains(sgs.bingfenTo)
		then
			sgs.JLBFto = player
			sgs.bingfenTo = nil
		end
		if use.m_reason==sgs.CardUseStruct_CARD_USE_REASON_PLAY
		then
			local ni,nf,ne = math.random(),{},{}
			for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
				if not self:isFriend(p) then table.insert(nf,p) end
				if not self:isEnemy(p) then table.insert(ne,p) end
			end
			function listRevises(is,to)
				if table.contains(is,to)
				then table.removeOne(is,to) end
				return is
			end
			self:updatePlayers()
			if ni<(0.05*self.player:aliveCount())
			and #ne>0
			then
				sgs.bingfenTo = ne[math.random(1,#ne)]
				self.friends = listRevises(self.friends,sgs.bingfenTo)
				self.friends_noself = listRevises(self.friends_noself,sgs.bingfenTo)
				table.insert(self.enemies,sgs.bingfenTo)
			elseif ni>(1-(0.05*self.player:aliveCount()))
			and #nf>0
			then
				sgs.bingfenTo = nf[math.random(1,#nf)]
				self.enemies = listRevises(self.enemies,sgs.bingfenTo)
				table.insert(self.friends_noself,sgs.bingfenTo)
				table.insert(self.friends,sgs.bingfenTo)
			end
			ni = math.random()
			if ni>0.9
			then
				self.room:setPlayerFlag(player,"Global_PlayPhaseTerminated")
				ni = jl_bingfen2[math.random(0,#jl_bingfen2+3)]
				if ni then self.player:speak(ni) end
			elseif ni<0.2
			then
				for cn,h in sgs.list(self:addHandPile())do
					cn = h:getClassName()
					sgs.jlUsePrioritys[cn] = sgs.jlUsePrioritys[cn] or sgs.ai_use_priority[cn]
					sgs.ai_use_priority[cn] = math.random(0,9)+math.random()
				end
			end
		else
			for cn,v in pairs(sgs.jlUsePrioritys)do
				sgs.ai_use_priority[cn] = v
			end
		end
	end
end

local bFto = function(self,player,data)
	if sgs.JLBFto
	then
		for sk,p in sgs.list(self.room:getOtherPlayers(sgs.JLBFto))do
			if math.random()>1/(sgs.turncount+1)
			and math.random()>0.8
			then
				if self:isFriend(sgs.JLBFto)
				and jl_bingfen4
				then
					sk = jl_bingfen4[math.random(1,#jl_bingfen4)]
					if sk then p:speak(sk) end
				elseif self:isEnemy(sgs.JLBFto)
				and jl_bingfen5
				then
					sk = jl_bingfen5[math.random(1,#jl_bingfen5)]
					if sk then p:speak(sk) end
				end
			end
		end
		sgs.JLBFto = nil
	end
end
sgs.ai_event_callback[sgs.ChoiceMade].bFto = bFto
sgs.ai_event_callback[sgs.CardFinished].bFto = bFto

sgs.ai_skill_invoke.jlZHjianren = function(self,data)
	return self:canDraw()
end

sgs.ai_skill_invoke.jlZHxiangzun = function(self,data)
	return self:canDraw()
end

sgs.ai_skill_playerchosen.jlZHyinhun = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
		if self:isEnemy(target)
		and self.player:getLostHp()<1
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		and self.player:getLostHp()>0
		then return target end
	end
end

sgs.ai_skill_playerchosen.jlZHrangli = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target) and self:isWeak(target)
		and self.player:getHandcardNum()>2
		and target:getHandcardNum()<2
		then return target end
	end
end

sgs.ai_skill_playerchosen.jlZHmoufa = function(self,players)
	local cs = hasCard(self.player,"Slash")
	if cs
	then
		local destlist = sgs.QList2Table(players) -- 将列表转换为表
		self:sort(destlist,"hp")
		for _,target in sgs.list(destlist)do
			if self:isEnemy(target)
			then
				local n = 0
				for _,c in sgs.list(cs)do
					if self:hasTrickEffective(c,target,self.player)
					then n = n+1 end
				end
				if n>=target:getHp()
				then return target end
			end
		end
		for _,target in sgs.list(destlist)do
			if self:isEnemy(target)
			then
				local n = 0
				for _,c in sgs.list(cs)do
					if self:hasTrickEffective(c,target,self.player)
					then n = n+1 end
				end
				if n>target:getHp()/2
				then return target end
			end
		end
	end
end

sgs.ai_skill_playerchosen.jlZHyingjie = function(self,players)
    for _,target in sgs.list(players)do
		if self:isFriend(target)
		and target:getHandcardNum()>2
		then return target end
	end
	return self.player
end

sgs.ai_skill_invoke.jlZHzhaonan = function(self,data)
	local target = data:toPlayer()
	if target
	then
		if self:isFriend(target) then return self:doDisCard(target,"e",true)
		else return self:doDisCard(target,"he",true) end
	end
end

sgs.ai_skill_askforyiji.jl_yishi = function(self,card_ids)
    return sgs.ai_skill_askforyiji.nosyiji(self,card_ids)
end

sgs.ai_skill_choice.jl_chenshou_ChooseKingdom = function(self,choices)
	local items = choices:split("+")
--	return "jin"
end

sgs.ai_skill_playerchosen.jl_mingzhi = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
		if self:isFriend(target)
		then return target end
	end
    for _,target in sgs.list(destlist)do
		if target:getGeneralName():match("simazhao")
		or target:getGeneral2Name():match("simazhao")
		then return target end
	end
end

sgs.ai_skill_invoke.jl_changqu = function(self,data)
	return true
end













--所有新增接口均在《ai补充包》覆盖后方可使用

sgs.ai_guhuo_card.jl_daoshu = function(self,toname,class_name)--新增蛊惑类技能卡接口（不包含主动使用技能卡）
    local handcards = self.player:getCards("h")
    handcards = self:sortByKeepValue(handcards,nil,"l") -- 按保留值排序
	if #handcards>0
	then
        local num = self:getCardsNum(class_name)
       	for _,hcard in sgs.list(handcards)do
           	if hcard:isKindOf(class_name)
			and num>1
	       	then
               	return "#nosguhuocard:"..hcard:getEffectiveId()..":"..toname
           	end
       	end
       	for _,hcard in sgs.list(handcards)do
           	if hcard:isKindOf(class_name)
			and hcard:getSuitString()=="heart"
	       	then
               	return "#nosguhuocard:"..hcard:getEffectiveId()..":"..toname
           	end
       	end
		num = self:getCardsNum("Analeptic")
		num = self:getCardsNum("Peach")+num
       	if (toname=="peach" or toname=="analeptic")
		and self.player:getHp()<1 and num>1
       	then
            return "#nosguhuocard:"..handcards[1]:getEffectiveId()..":"..toname
       	end
		num = 0
       	for _,ep in sgs.list(self.enemies)do
	    	if self:isWeak(ep)
			then num = num+1 end
		end
       	for _,hcard in sgs.list(handcards)do
           	if hcard:isKindOf(class_name)
			and num>=#self.enemies/2
	       	then
               	return "#nosguhuocard:"..hcard:getEffectiveId()..":"..toname
           	end
       	end
       	if #handcards>2
		and math.random(0,#self.enemies+2)<#self.enemies+1
       	then
            return "#nosguhuocard:"..handcards[1]:getEffectiveId()..":"..toname
       	end
	end
end

sgs.ai_guhuo_card.jl_zhugong = function(self,toname,class_name)
	if self.player:hasLordSkill("jl_zhugong")
	then return "#jl_zhugongCard:.:"..toname end
end

sgs.ai_guhuo_card.jl_qiangji = function(self,toname,class_name)
    if class_name=="Slash"
    then
	  	for _,owner in sgs.list(self.room:findPlayersBySkillName("jl_qiangji"))do
            return "#jl_qiangjiCard:.:"..toname
       	end
	end
end

sgs.ai_use_revises.jl_kuangcai = function(self,card,use)--新增技能（装备）对卡牌使用修正接口
	if self.player:getMark("jl_kuangcai-PlayClear")>0
	and card:isKindOf("EquipCard")
	then
     	for _,h in sgs.list(self.player:getCards("h"))do
          	if h:isKindOf("EquipCard")
			then continue end
			local dummy = self:aiUseCard(h)
    		if dummy.card and dummy.to
	     	then return false end
			--狂才在有其他牌可使用时不使用装备
		end
	end
	--返回 true 则直接使用，返回 false 则不使用,返回 nil 或不返回则继续进行默认决策
	
	--因为这个 aiUseCard 函数包含 ai_use_revises 函数，
	--所以不能进行嵌套使用，
	--如果你调用了 aiUseCard 函数，aiUseCard 函数会调用 ai_use_revises 函数，
	--为防止重复，不能让这两个函数同时检测相同的牌，
	--例如现在 ai_use_revises 询问的是 EquipCard 的使用，
	--则你不能再用 aiUseCard 询问 EquipCard 的使用，会出现重复递归，无穷无尽.....
end

sgs.ai_use_revises.jl_shuijing = function(self,card,use)
	if self.player:getMark("&dragon_signet")+self.player:getMark("&phoenix_signet")<1
	and card:isKindOf("Armor")
	then return false end
end

sgs.ai_target_revises.jl_shuijing = function(to,card)--新增技能（装备）对卡牌目标修正接口
    --在 to 就要成为 card 的使用目标时
	if to:getArmor()==nil
	and card:isDamageCard()
	and to:getMark("&dragon_signet")+to:getMark("&phoenix_signet")<1
	then
    	if card:isKindOf("NatureSlash")-- and card:objectName()~="slash"
		or card:isKindOf("TrickCard")
		then return true end --隐士就要成为属性杀或伤害锦囊目标时取消
	end
	--返回 true 则取消 to 为目标
end

sgs.ai_can_damagehp.jl_shuijing = function(self,from,card,to)--类卖血技能决策
    if not to:getArmor() and to:getMark("&dragon_signet")+to:getMark("&phoenix_signet")<1
	then --先判断是否可以隐士
    	if card --再判断是否是牌的伤害
		then
			if card:isKindOf("NatureSlash") --隐士受到属性杀时不闪
			or card:isKindOf("TrickCard") and card:isDamageCard()--隐士受到伤害锦囊时不响应
			then
				return self:canLoseHp(from,card,to)--规避掉一些特殊技能，例如绝情，来保证是会造成伤害
			end
		end
		--返回 true 则不响应任何请求使用、打出或弃置（包含无懈）
		
		--返回 false 则不再进行后续决策，返回空（nil）则继续进行后续决策
		--因为可能后面自己的其他技能还会有用这个函数进行决策
	end
	--这个就是利用类卖血技能ai函数来保证隐士将受到属性伤害或锦囊伤害时，不需要出牌响应
	--这个考虑了牌，所以只有来自牌的请求才不响应，来自技能的请求还是会响应的
end

sgs.ai_can_damagehp.jl_xianchou = function(self,from,card,to)
	return self:canLoseHp(from,card,to)--这个就是只要我不是残血状态，我都不响应（极致卖血）
	and to:getHp()+self:getAllPeachNum()*2-self:ajustDamage(from,to,1,card)*2>0
	--这个就什么都不考虑，所以只要请求，都不响应
end

sgs.ai_can_damagehp.jl_chaixie = function(self,from,card,to)
	return not self:isWeak(to)
	and self:canLoseHp(from,card,to)
end

sgs.ai_can_damagehp.jl_yachai = function(self,from,card,to)
	if from and not self:isWeak(to)
	and self:canLoseHp(from,card,to)
	then
		return not self:isFriend(from)
	end--这个就是在有伤害来源时，只有来源不是友军时才不响应
	--因为这类技能在卖血后，会对来源造成不好的影响
end

sgs.ai_guhuo_card.jl_xishua = function(self,toname,class_name)
	return sgs.ai_guhuo_card.jl_daoshu(self,toname,class_name)
end

sgs.ai_target_revises.jl_wangba = function(to,card)
    if card:isKindOf("Slash")
	then
		if card:isBlack()
    	or not card:isKindOf("NatureSlash")
		then return true end
	end
end

sgs.ai_use_revises.jl_judao = function(self,card,use)
	if self.player:hasSkill("mobilepojun")
	and card:isKindOf("Weapon")
	then return false end
end

sgs.card_value.jl_xianchou = {--新增技能对卡牌保留值修正接口
	Peach = 5.9,
	--桃在原本的保留值上再加上5.9，多个技能对桃的保留值修正时会被平均，例如另一个技能也修正了5.9，那么最终只会修正5.9，而不是11.8
	Analeptic = 4.9,
--	heart = 4.4,还可以修正花色
--	9 = 5.5,或者点数
--  这里的值出现重合时会直接相加，例如♥9的桃修正后的价值会是 5.9+4.4+5.5 = 15.8
}

sgs.ai_use_revises.jl_xianchou = function(self,card,use)
	if (card:isKindOf("Armor") or card:isKindOf("DefensiveHorse"))
	and not self:isWeak() then return false end
end

sgs.ai_guhuo_card.jl_zebing = function(self,toname,class_name)
    local ids = self.player:getPile("jl_liang")
	if ids:length()>0 and sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
	then
        if string.find(toname,"jink")
		or string.find(toname,"peach")
		or string.find(toname,"analeptic")
		or string.find(toname,"nullification")
	    then
           	return "#jl_zebingcard:"..ids:at(0)..":"..toname
        end
	end
end

sgs.ai_skill_cardask.jl_chengxiang = function(self,data,pattern,prompt)
    local parsed = prompt:split(":")
	local choices = {}
	for i = 1,26 do
		if self.player:getTag("jlcx_="..i):toBool() then continue end
		table.insert(choices,"jlcx_="..i)
	end
    if self.player:getHp()>0
	and #choices>2
	then
    	if parsed[1]=="slash-jink"
		then
	    	parsed = data:toSlashEffect()
			if self:canLoseHp(parsed.from,parsed.slash,parsed.to)
			then return false end
		else
	    	parsed = data:toCardEffect()
			local card = parsed.card
			if card and card:isDamageCard()
			and self:canLoseHp(parsed.from,parsed.card,parsed.to)
			then return false end
		end
	end
end

sgs.ai_skill_cardask.jl_weiye_card = function(self,data,pattern,prompt)
    local parsed = data:toPlayer()
    if self:isFriend(parsed)
	then return true end
	return "."
end

sgs.ai_skill_cardask.jl_shuitu_card = function(self,data,pattern,prompt)
    local parsed = data:toPlayer()
    if self:isFriend(parsed)
	then return true end
	return "."
end

sgs.ai_guhuo_card.jl_weiye = function(self,toname,class_name)
    if self.player:hasFlag("nojl_weiye") then return end
	for _,p in sgs.list(self.player:getAliveSiblings())do
		if p:getKingdom()=="wei" and class_name=="Jink"
		then return "#jl_weiyeCard:.:"..toname end
	end
end

sgs.ai_guhuo_card.jl_shuitu = function(self,toname,class_name)
    if self.player:hasFlag("nojl_shuitu") then return end
	for _,p in sgs.list(self.player:getAliveSiblings())do
		if p:getKingdom()=="shu" and class_name=="Slash"
		then return "#jl_shuituCard:.:"..toname end
	end
end

sgs.ai_can_damagehp.jl_xiance = function(self,from,card,to)
	return card and card:isDamageCard() and self:canLoseHp(from,card,to)
	and to:getHp()+self:getAllPeachNum()-self:ajustDamage(from,to,1,card)>0
end

sgs.ai_can_damagehp.tianxiang = function(self,from,card,to)
	if not self.player:hasSkill("tianxiang") then return end
	local cards = self.player:getCards("h")
	cards = self:sortByKeepValue(cards)
	local can = nil
	for _,c in sgs.list(cards)do
		if c:getSuit()==2 then can = true break end
	end
	for _,ep in sgs.list(self.enemies)do
		if can and self:canLoseHp(from,card,to)
		and self:ajustDamage(from,to,1,card)>0
		and ep:getHp()<2 then return true end
	end
end

--yongjian-ai.lua 里有关于负面卡牌的决策说明


sgs.ai_armor_value.jl_beiju = function(player,self,card)
   	local target = self.room:getCurrent()
	if not self:isFriend(target)
	and player:getEquips():contains(card)
	then return -7 end
	--杯具在对手回合时为负面卡牌，将优先卸掉
end




sgs.ai_fill_skill.jlZHwuyong = function(self)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	local ids = {}
	for _,c1 in sgs.list(cards)do
		local ids2 = {}
		table.insert(ids2,c1:getId())
		for _,c2 in sgs.list(cards)do
			if c1:getId()~=c2:getId()
			and c1:getColor()==c2:getColor()
			then
				table.insert(ids2,c2:getId())
			end
			if #ids2>2 then break end
		end
		if #ids2>2 then ids = ids2 break end
	end
	if #ids<3 then return end
	local can = dummyCard()
	can:setSkillName("_jlZHwuyong")
	can:addSubcard(ids[1])
	can:addSubcard(ids[2])
	can:addSubcard(ids[3])
	can = self:aiUseCard(can)
	if can.card
	then
		self.jlZHwuyong_to = can.to
		return sgs.Card_Parse("#jlZHwuyongCard:"..table.concat(ids,"+")..":slash")
	end
end

sgs.ai_skill_use_func["#jlZHwuyongCard"] = function(card,use,self)
	use.card = card
	if use.to then use.to = self.jlZHwuyong_to end
end

sgs.ai_use_value.jlZHwuyongCard = 3.4
sgs.ai_use_priority.jlZHwuyongCard = 3.2


--[[
local jl_huangtianvs={}
jl_huangtianvs.name="jl_huangtianvs"
table.insert(sgs.ai_skills,jl_huangtianvs)
jl_huangtianvs.getTurnUseCard = function(self)

end
以下的这个 sgs.ai_fill_skill 函数可以代替上面这个比较复杂的原函数
--]]
sgs.ai_fill_skill.jl_huangtianvs = function(self)
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,c in sgs.list(cards)do
	   	if table.contains(self.toUse,c) then continue end
		self:sort(self.friends_noself,"hp")
		for _,ep in sgs.list(self.friends_noself)do
			if ep:hasLordSkill("jl_huangtian") and c:isKindOf("Slash")
			and ep:getMark("jl_huangtian-PlayClear")<1
			then
				self.ht_to=ep
				return sgs.Card_Parse("#jl_huangtianCard:"..c:getEffectiveId()..":")
			end
		end
	end
	--[[
	同时这些函数发动条件可以不写
	例如现在的函数对应的技能效果是：男性角色出牌阶段限一次，你可以将一张杀交给“凰天”角色。
	这些函数已经自动判定了前置条件：你是男性角色且未在出牌阶段发动过这个技能。
	也就是这个函数只有预先通过技能的 enabled_at_play 检测
	函数才会进行到这里来获取下一步需要使用的技能卡
	
	其他技能卡转化响应的ai函数也做了预先检测
	例如杜预的灭吴，会自动先检测杜预有没有武库标记和本回合用没有过灭吴
	也就是这个函数只有预先通过技能的 enabled_at_response 检测
	才会进入下一步
	
	所以我们写这些代码时，只需要写必要条件
	就是我们只要写要不要发动，不用考虑可不可以发动
	--]]
end

sgs.ai_skill_use_func["#jl_huangtianCard"] = function(card,use,self)
	use.card = card
	if use.to then use.to:append(self.ht_to) end
end

sgs.ai_use_value.jl_huangtianCard = 3.4
sgs.ai_use_priority.jl_huangtianCard = 2.2


sgs.ai_fill_skill.jl_changqu = function(self)
	return sgs.Card_Parse("#jl_changquCard:.:")
end

sgs.ai_skill_use_func["#jl_changquCard"] = function(card,use,self)
	self:sort(self.enemies,"hp")
	for _,ep in sgs.list(self.enemies)do
		if use.to
		then
			if use.to:isEmpty()
			then
				use.card = card
				use.to:append(ep)
			else
				for _,p in sgs.list(use.to)do
					if p:isAdjacentTo(ep)
					then use.to:append(ep) break end
				end
			end
		end
	end
end

sgs.ai_use_value.jl_changquCard = 3.4
sgs.ai_use_priority.jl_changquCard = 6.2

sgs.ai_fill_skill.jl_huiwan = function(self)
	local can = canAiSkills("zhiheng")
	can = can.ai_fill_skill
	if can
	then
		can = can(self)
		if can
		then
			can = self:aiUseCard(can)
			if can.card
			then
				can = InsertList({},can.card:getSubcards())
				return sgs.Card_Parse("#jl_huiwanCard:"..table.concat(can,"+")..":")
			end
		end
	end
end

sgs.ai_skill_use_func["#jl_huiwanCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_huiwanCard = 3.4
sgs.ai_use_priority.jl_huiwanCard = 6.2

sgs.ai_fill_skill.jlZHwuyong = function(self)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	local ids = {}
	for _,c1 in sgs.list(cards)do
		local ids2 = {}
		table.insert(ids2,c1:getId())
		for _,c2 in sgs.list(cards)do
			if c1:getId()~=c2:getId()
			and c1:getColor()==c2:getColor()
			then
				table.insert(ids2,c2:getId())
			end
			if #ids2>2 then break end
		end
		if #ids2>2 then ids = ids2 break end
	end
	if #ids<3 then return end
	local can = dummyCard()
	can:setSkillName("_jlZHwuyong")
	can:addSubcard(ids[1])
	can:addSubcard(ids[2])
	can:addSubcard(ids[3])
	can = self:aiUseCard(can)
	if can.card
	then
		self.jlZHwuyong_to = can.to
		return sgs.Card_Parse("#jlZHwuyongCard:"..table.concat(ids,"+")..":slash")
	end
end

sgs.ai_skill_use_func["#jlZHwuyongCard"] = function(card,use,self)
	use.card = card
	if use.to then use.to = self.jlZHwuyong_to end
end

sgs.ai_use_value.jlZHwuyongCard = 3.4
sgs.ai_use_priority.jlZHwuyongCard = 3.2

sgs.ai_fill_skill.jlZHcongjiVS = function(self)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,c1 in sgs.list(cards)do
		if table.contains(self.toUse,c1) then continue end
		if c1:isKindOf("Slash") then return sgs.Card_Parse("#jlZHcongjiCard:"..c1:getId()..":") end
	end
end

sgs.ai_skill_use_func["#jlZHcongjiCard"] = function(card,use,self)
	for _,p in sgs.list(self.room:findPlayersBySkillName("jlZHcongji"))do
		if self:isFriend(p) and p:getMark("jlZHcongji-PlayClear")<1
		then
			use.card = card
			if use.to then use.to:append(p) end
			break
		end
	end
end

sgs.ai_use_value.jlZHcongjiCard = 3.4
sgs.ai_use_priority.jlZHcongjiCard = 6.2

sgs.ai_fill_skill.jlZHjieming = function(self)
    return sgs.Card_Parse("#jlZHjiemingCard:.:")
end

sgs.ai_skill_use_func["#jlZHjiemingCard"] = function(card,use,self)
	self:sort(self.enemies,"handcard")
	for _,p in sgs.list(self.enemies)do
		use.card = card
		if use.to then use.to:append(p) end
		return
	end
end

sgs.ai_use_value.jlZHjiemingCard = 3.4
sgs.ai_use_priority.jlZHjiemingCard = 4.2

sgs.ai_fill_skill.jlZHjingbing = function(self)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards,nil,"j") -- 按保留值排序
	local ids = {}
	for _,c1 in sgs.list(cards)do
		if table.contains(self.toUse,c1)
		or self:getKeepValue(c1)>6
		then continue end
		table.insert(ids,c1:getId())
		if #ids>1 then return sgs.Card_Parse("#jlZHjingbingCard:"..table.concat(ids,"+")..":") end
	end
end

sgs.ai_skill_use_func["#jlZHjingbingCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jlZHjingbingCard = 3.4
sgs.ai_use_priority.jlZHjingbingCard = 6.2

sgs.ai_fill_skill.jlZHcaifei = function(self)
    return sgs.Card_Parse("#jlZHcaifeiCard:.:")
end

sgs.ai_skill_use_func["#jlZHcaifeiCard"] = function(card,use,self)
	local mc = self:getMaxCard()
	if mc and mc:getNumber()>10 then else return end
	self:sort(self.enemies,"handcard")
	for _,p in sgs.list(self.enemies)do
		if self.player:canPindian(p)
		then
			use.card = card
			if use.to then use.to:append(p) end
			return
		end
	end
	for _,p in sgs.list(self:sort(self.room:getOtherPlayers(self.player),"handcard"))do
		if self.player:canPindian(p)
		and not self:isFriend(p)
		then
			use.card = card
			if use.to then use.to:append(p) end
			return
		end
	end
end

sgs.ai_use_value.jlZHcaifeiCard = 3.4
sgs.ai_use_priority.jlZHcaifeiCard = 4.2

sgs.ai_fill_skill.jlZHmubing = function(self)
    return sgs.Card_Parse("#jlZHmubingCard::")
end

sgs.ai_skill_use_func["#jlZHmubingCard"] = function(card,use,self)
	self:sort(self.enemies,"handcard",true)
	for _,p in sgs.list(self.enemies)do
		if p:getHandcardNum()>0
		then
			use.card = card
			if use.to then use.to:append(p) end
			return
		end
	end
	for _,p in sgs.list(self:sort(self.room:getOtherPlayers(self.player),"handcard",true))do
		if p:getHandcardNum()>0
		and not self:isFriend(p)
		then
			use.card = card
			if use.to then use.to:append(p) end
			return
		end
	end
end

sgs.ai_use_value.jlZHmubingCard = 3.4
sgs.ai_use_priority.jlZHmubingCard = 8.2

sgs.ai_fill_skill.jlZHluanda = function(self)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards,nil,"l") -- 按保留值排序
	local ids = {}
	for _,c1 in sgs.list(cards)do
		for _,c2 in sgs.list(cards)do
			if c1:getId()~=c2:getId()
			and c1:getSuit()==c2:getSuit()
			then
				table.insert(ids,c1:getId())
				table.insert(ids,c2:getId())
				break
			end
		end
		if #ids>1 then break end
	end
	if #ids<2 then return end
	for _,ep in sgs.list(self.room:getAlivePlayers())do
		if self.player:inMyAttackRange(ep) then continue end
		ep:setProperty("aiNoTo",ToData(true))
	end
	local can = dummyCard("archery_attack")
	can:addSubcard(ids[1])
	can:addSubcard(ids[2])
	can = self:getAoeValue(can)>0
	for _,ep in sgs.list(self.room:getAlivePlayers())do
		ep:setProperty("aiNoTo",ToData(false))
	end
	if can
	then
		return sgs.Card_Parse("#jlZHluandaCard:"..table.concat(ids,"+")..":")
	end
end

sgs.ai_skill_use_func["#jlZHluandaCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jlZHluandaCard = 3.4
sgs.ai_use_priority.jlZHluandaCard = 3.2

sgs.ai_fill_skill.jl_taodong = function(self)
    if self.player:getMark("&jlZH")>2
	then
		return sgs.Card_Parse("#jl_taodongCard:.:")
	end
end

sgs.ai_skill_use_func["#jl_taodongCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_taodongCard = 3.4
sgs.ai_use_priority.jl_taodongCard = 8.2

sgs.ai_fill_skill.jl_hexin = function(self)
	local cards = self:addHandPile("he")
	self:sortByKeepValue(cards,nil,"l")
	local cs = {}
	local toc = InsertList({},cards)
   	for _,c in sgs.list(cards)do
		table.removeOne(toc,c)
		if #toc<1 or #cs>=#toc then break end
		local fs = sgs.Sanguosha:cloneCard("archery_attack")
		fs:setSkillName("jl_hexin")
		fs:addSubcard(toc[1])
		fs:addSubcard(c)
		table.insert(cs,fs)
	end
	self.player:addMark("AI_fangjian-Clear")
	return #cs>0 and cs
end

local jl_juehun={}
jl_juehun.name="jl_juehun"
table.insert(sgs.ai_skills,jl_juehun)
jl_juehun.getTurnUseCard = function(self)
	local cards = self:addHandPile()
	self:sortByKeepValue(cards)
	local cs = {}
   	for _,c in sgs.list(cards)do
		if c:getSuit()==3
		then
			local fs = sgs.Sanguosha:cloneCard("fire_slash")
			fs:setSkillName("jl_juehun")
			fs:addSubcard(c)
			table.insert(cs,fs)
		end
		if c:getSuit()==2
		then
			local peach = sgs.Sanguosha:cloneCard("peach")
			peach:setSkillName("jl_juehun")
			peach:addSubcard(c)
			table.insert(cs,peach)
		end
	end
	return #cs>0 and cs
end

sgs.ai_view_as.jl_juehun = function(card,player,card_place)
   	if card_place==sgs.Player_PlaceHand
	or card_place==sgs.Player_PlaceEquip
	then
    	if card:getSuit()==2
    	then return ("peach:jl_juehun[no_suit:0]="..card:getEffectiveId())
    	elseif card:getSuit()==0
    	then return ("nullification:jl_juehun[no_suit:0]="..card:getEffectiveId())
    	elseif card:getSuit()==3
    	then return ("fire_slash:jl_juehun[no_suit:0]="..card:getEffectiveId())
    	elseif card:getSuit()==1
    	then return ("jink:jl_juehun[no_suit:0]="..card:getEffectiveId()) end
	end
end


local jl_qiangzheng={}
jl_qiangzheng.name="jl_qiangzheng"
table.insert(sgs.ai_skills,jl_qiangzheng)
jl_qiangzheng.getTurnUseCard = function(self)
	local n = 0
	for d,p in sgs.list(self.room:getAlivePlayers())do
		if p:getMark("jl_shouling")>0 and p:getCardCount()>1 then n = n+1 end
		if self:isWeak() and n>=self.player:aliveCount()/2
		or n>self.player:aliveCount()/2
		then
			return sgs.Card_Parse("#jl_qiangzhengCard:.:")
		end
	end
end

sgs.ai_skill_use_func["#jl_qiangzhengCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_qiangzhengCard = 3.4
sgs.ai_use_priority.jl_qiangzhengCard = 2.2

local jl_gaojian={}
jl_gaojian.name="jl_gaojian"
table.insert(sgs.ai_skills,jl_gaojian)
jl_gaojian.getTurnUseCard = function(self)
	for _,p in sgs.list(patterns)do
		local toc = sgs.Sanguosha:cloneCard(p)
		if toc
		then
			toc:setSkillName("jl_gaojian")
			if toc:isKindOf("BasicCard")
			and toc:isAvailable(self.player)
			and self.player:getMark("&jl_youshi")>1
			and self:aiUseCard(toc).card
			then return toc end
			toc:deleteLater()
		end
	end
end

function sgs.ai_cardsview.jl_gaojian(self,class_name,player)
	local c = PatternsCard(class_name)
	if c and c:isKindOf("BasicCard")
	then return (c:objectName()..":jl_gaojian[no_suit:0]=.") end
end

local jl_qixi={}
jl_qixi.name="jl_qixi"
table.insert(sgs.ai_skills,jl_qixi)
jl_qixi.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	for _,c in sgs.list(cards)do
		if not c:isBlack() then continue end
		local toc = sgs.Sanguosha:cloneCard("dismantlement")
		toc:setSkillName("jl_qixi")
		toc:addSubcard(c)
		local dummy = self:aiUseCard(toc)
		if dummy.card and dummy.to 
		then return toc end
		toc:deleteLater()
	end
end

local jl_qunlivs={}
jl_qunlivs.name="jl_qunlivs"
table.insert(sgs.ai_skills,jl_qunlivs)
jl_qunlivs.getTurnUseCard = function(self)
	local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,c in sgs.list(cards)do
	   	self:sort(self.friends_noself,"hp")
		for _,ep in sgs.list(self.friends_noself)do
			if (c:isKindOf("Jink") and self:getCardsNum("Jink","h")>1 or c:isKindOf("Lightning"))
			and ep:getMark("jl_qunli-PlayClear")<1
			and ep:hasSkill("jl_qunli")
			then
				self.ql_to=ep
				return sgs.Card_Parse("#jl_qunliCard:"..c:getEffectiveId()..":")
			end
		end
	end
end

sgs.ai_skill_use_func["#jl_qunliCard"] = function(card,use,self)
	use.card = card
	if use.to then use.to:append(self.ql_to) end
end

sgs.ai_use_value.jl_qunliCard = 6.4
sgs.ai_use_priority.jl_qunliCard = 2.5

local jl_wucevs={}
jl_wucevs.name="jl_wucevs"
table.insert(sgs.ai_skills,jl_wucevs)
jl_wucevs.getTurnUseCard = function(self)
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,c in sgs.list(cards)do
	   	self:sort(self.enemies,"hp")
		for _,ep in sgs.list(self.enemies)do
			if c:getNumber()>9
			and self.player:canPindian(ep)
			then
				self.wc_to=ep
				return sgs.Card_Parse("#jl_wuceCard:.:")
			end
		end
	end
	for _,c in sgs.list(cards)do
	   	self:sort(self.friends_noself,"hp")
		for _,ep in sgs.list(self.friends_noself)do
			if c:getNumber()<6
			and self.player:canPindian(ep)
			then
				self.wc_to=ep
				return sgs.Card_Parse("#jl_wuceCard:.:")
			end
		end
	end
end

sgs.ai_skill_use_func["#jl_wuceCard"] = function(card,use,self)
	use.card = card
	if use.to then use.to:append(self.wc_to) end
end

sgs.ai_use_value.jl_wuceCard = 6.4
sgs.ai_use_priority.jl_wuceCard = 2.5

local jl_shuitu={}
jl_shuitu.name="jl_shuitu"
table.insert(sgs.ai_skills,jl_shuitu)
jl_shuitu.getTurnUseCard = function(self)
	for i,p in sgs.list(self.player:getAliveSiblings())do
		if p:getKingdom()=="shu"
		and sgs.Slash_IsAvailable(self.player)
		then
            i = self:aiUseCard(dummyCard())
			if i.card and i.to:length()>0
			then
				self.st_to = i.to
				return sgs.Card_Parse("#jl_shuituCard:.:")
			end
		end
	end
end

sgs.ai_skill_use_func["#jl_shuituCard"] = function(card,use,self)
	use.card = card
	if use.to then use.to = self.st_to end
end

sgs.ai_use_value.jl_shuituCard = 6.4
sgs.ai_use_priority.jl_shuituCard = 3.4

local jl_zebing={}
jl_zebing.name="jl_zebing"
table.insert(sgs.ai_skills,jl_zebing)
jl_zebing.getTurnUseCard = function(self)
	local ids = sgs.QList2Table(self.player:getPile("jl_mou"))
	local c_names = {"savage_assault","archery_attack","collateral","iron_chain","amazing_grace"}
	if #ids>0
	then
		for d,n in sgs.list(c_names)do
			d = CardIsAvailable(self.player,n)
			if d==nil then continue end
			d = self:aiUseCard(d)
			if d.card and d.to
			then
	           	if d.card:canRecast()
				and d.to:length()<1
				then continue end
				self.zb_to = d.to
				return sgs.Card_Parse("#jl_zebingcard:"..ids[1]..":"..n)
			end
		end
	end
	c_names = {"peach","analeptic"}
    ids = sgs.QList2Table(self.player:getPile("jl_liang"))
	if #ids>0
	then
		for d,n in sgs.list(c_names)do
			d = CardIsAvailable(self.player,n)
			if d==nil then continue end
			d = self:aiUseCard(d)
			if d.card and d.to
			then
				self.zb_to = d.to
				return sgs.Card_Parse("#jl_zebingcard:"..ids[1]..":"..n)
			end
		end
	end
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for d,c in sgs.list(cards)do
		if c:hasFlag("jl_zebing")
		then
			local peach = sgs.Sanguosha:cloneCard("peach")
			peach:setSkillName("_jl_zebing")
            peach:addSubcard(c)
			d = self:aiUseCard(peach)
			if d.card then return peach end
			peach:deleteLater()
			for i,f in sgs.list(self.friends_noself)do
				if f:getKingdom()=="shu"
				then
					return sgs.Card_Parse("#jl_zebingCard:"..c:getEffectiveId()..":")
				end
			end
		end
	end
	local shu = self.room:getLieges("shu",self.player)
	for i,id in sgs.list(self.player:getPile("jl_bing"))do
		if shu:length()>0 then table.insert(ids,id) end
	end
	for i,id in sgs.list(self.player:getPile("jl_mou"))do
		if shu:length()>0 then table.insert(ids,id) end
	end
	for i,id in sgs.list(self.player:getPile("jl_qi"))do
		table.insert(ids,id)
	end
	if #ids<1 then return end
	ids = RandomList(ids)
	return sgs.Card_Parse("#jl_zebingCard:"..ids[1]..":")
end

sgs.ai_skill_use_func["#jl_zebingcard"] = function(card,use,self)
	use.card = card
	if use.to then use.to = self.zb_to end
end

sgs.ai_use_value.jl_zebingcard = 6.4
sgs.ai_use_priority.jl_zebingcard = 6.4

sgs.ai_skill_use_func["#jl_zebingCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_priority.jl_zebingCard = 4.4

local jl_yisuan={}
jl_yisuan.name="jl_yisuan"
table.insert(sgs.ai_skills,jl_yisuan)
jl_yisuan.getTurnUseCard = function(self)
    return sgs.Card_Parse("#jl_yisuan:.:")
end

sgs.ai_skill_use_func["#jl_yisuan"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_yisuan = 6.4
sgs.ai_use_priority.jl_yisuan = 6.4

local jl_kuangshe={}
jl_kuangshe.name="jl_kuangshe"
table.insert(sgs.ai_skills,jl_kuangshe)
jl_kuangshe.getTurnUseCard = function(self)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<1 then return end
	for _,c in sgs.list(cards)do
		if c:isRed()
		and #self.enemies>0
		and sgs.Slash_IsAvailable(self.player)
		then
            return sgs.Card_Parse("#jl_kuangsheCard:"..c:getEffectiveId()..":")
		end
	end
end

sgs.ai_skill_use_func["#jl_kuangsheCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_kuangsheCard = 6.4
sgs.ai_use_priority.jl_kuangsheCard = 3.4

local jl_xiongyi={}
jl_xiongyi.name="jl_xiongyi"
table.insert(sgs.ai_skills,jl_xiongyi)
jl_xiongyi.getTurnUseCard = function(self)
	for _,ep in sgs.list(self.enemies)do
		if self:isWeak(ep) then return sgs.Card_Parse("#jl_xiongyi:.:") end
	end
end

sgs.ai_skill_use_func["#jl_xiongyi"] = function(card,use,self)
	use.card = card
	for _,ep in sgs.list(self.enemies)do
		if self:isWeak(ep)
		and use.to and use.to:length()<1
		then use.to:append(ep) end
	end
end

sgs.ai_use_value.jl_xiongyi = 5.4
sgs.ai_use_priority.jl_xiongyi = 2.4

local jl_chousi={}
jl_chousi.name="jl_chousi"
table.insert(sgs.ai_skills,jl_chousi)
jl_chousi.getTurnUseCard = function(self)
	if self.player:getHp()>1
	then
        return sgs.Card_Parse("#jl_chousi:.:")
	end
end

sgs.ai_skill_use_func["#jl_chousi"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_chousi = 7.4
sgs.ai_use_priority.jl_chousi = 5.4

local jl_neifa={}
jl_neifa.name="jl_neifa"
table.insert(sgs.ai_skills,jl_neifa)
jl_neifa.getTurnUseCard = function(self)
	return sgs.Card_Parse("#jl_neifa:.:")
end

sgs.ai_skill_use_func["#jl_neifa"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_neifa = 5.4
sgs.ai_use_priority.jl_neifa = 5.4

local jl_daoshu={}
jl_daoshu.name="jl_daoshu"
table.insert(sgs.ai_skills,jl_daoshu)
jl_daoshu.getTurnUseCard = function(self)
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<1 then return end
	local can = #cards>2
	for _,ep in sgs.list(self.enemies)do
    	if self:isWeak(ep)
		then can = ep end
	end
	for _,h in sgs.list(cards)do
		if can and h:isAvailable(self.player)
		and (h:isKindOf("BasicCard") or h:isNDTrick())
		then
         	local dummy = self:aiUseCard(h)
    		if dummy.card
	    	and dummy.to
	     	then
	           	if h:canRecast()
				and dummy.to:length()<1
				then continue end
                self.gh_to = dummy.to
				return sgs.Card_Parse("#nosguhuocard:"..h:getEffectiveId()..":"..h:objectName())
			end
		end
	end
	for _,h in sgs.list(cards)do
		if h:isAvailable(self.player)
		and h:getSuitString()=="heart"
		and (h:isKindOf("BasicCard") or h:isNDTrick())
		then
         	local dummy = self:aiUseCard(h)
    		if dummy.card
	    	and dummy.to
	     	then
	           	if h:canRecast()
				and dummy.to:length()<1
				then continue end
                self.gh_to = dummy.to
                return sgs.Card_Parse("#nosguhuocard:"..h:getEffectiveId()..":"..h:objectName())
			end
		end
	end
	can = #cards>2
	for _,ep in sgs.list(self.enemies)do
    	if ep:getHp()>1
		then can = false end
	end
	for _,name in sgs.list(patterns)do
        local c = dummyCard(name)
		if c and can and c:isAvailable(self.player)
		and math.random(0,4)<2
		and self.player:getMark(name.."-PlayClear")<1
		and (c:isKindOf("BasicCard") or c:isNDTrick())
		then
         	local dummy = self:aiUseCard(c)
    		if dummy.card
	    	and dummy.to
	     	then
	           	if c:canRecast()
				and dummy.to:length()<1
				then continue end
				self.gh_to = dummy.to
				self.player:addMark(name.."-PlayClear")
				return sgs.Card_Parse("#nosguhuocard:"..cards[1]:getEffectiveId()..":"..name)
			end
		end
	end
	can = false
	for _,ep in sgs.list(self.enemies)do
		local j = ep:getJudgingArea()
		if ep:getPile("incantation"):isEmpty()
		and not j:isEmpty()
		then
	    	self.gh_to = ep
			if j:at(0):isKindOf("Indulgence")
			then
                for _,h in sgs.list(cards)do
					if h:getSuitString()~="heart"
					then can = h:getEffectiveId() break end
            	end
	    	elseif j:at(0):isKindOf("Lightning")
			then
                for _,h in sgs.list(cards)do
					if h:getSuitString()=="spade"
					and h:getNumber()>1
					and h:getNumber()<10
					then can = h:getEffectiveId() break end
            	end
	    	elseif j:at(0):isKindOf("SupplyShortage")
	    	then
                for _,h in sgs.list(cards)do
					if h:getSuitString()~="club"
					then can = h:getEffectiveId() break end
            	end
			end
		end
    end
	for _,fp in sgs.list(self.friends_noself)do
		local j = fp:getJudgingArea()
		if fp:getPile("incantation"):isEmpty()
		and not j:isEmpty()
		then
	    	self.gh_to = fp
			if j:at(0):isKindOf("Indulgence")
			then
                for _,h in sgs.list(cards)do
					if h:getSuitString()=="heart"
					then can = h:getEffectiveId() break end
            	end
	    	elseif j:at(0):isKindOf("Lightning")
			then
                for _,h in sgs.list(cards)do
					if h:getSuitString()~="spade"
					then can = h:getEffectiveId() break end
            	end
	    	elseif j:at(0):isKindOf("SupplyShortage")
	    	then
                for _,h in sgs.list(cards)do
					if h:getSuitString()=="club"
					then can = h:getEffectiveId() break end
            	end
			end
		end
    end
	if can
	then
		return sgs.Card_Parse("#zhoufucard:"..can..":")
	end
end

sgs.ai_skill_use_func["#nosguhuocard"] = function(card,use,self)
	use.card = card
	if use.to then use.to = self.gh_to end
	if math.random(0,4)<2
	then
    	self.player:speak("发牌了！发牌了！")
	elseif math.random(0,3)<2
	then
    	self.player:speak("赶紧质疑啊！")
	elseif math.random(0,2)<2
	then
    	self.player:speak("好好想想！")
	end
end

sgs.ai_use_value.nosguhuocard = 10.4
sgs.ai_use_priority.nosguhuocard = 10.4

sgs.ai_skill_use_func["#zhoufucard"] = function(card,use,self)
	use.card = card
	if use.to then use.to:append(self.gh_to) end
end

sgs.ai_use_value.zhoufucard = -0.4
sgs.ai_use_priority.zhoufucard = -0.4

local jl_xishua={}
jl_xishua.name="jl_xishua"
table.insert(sgs.ai_skills,jl_xishua)
jl_xishua.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	local cs = {}
	for _,id in sgs.list(self.player:getPile("field"))do
		if self.room:getCardPlace(id)~=sgs.Player_PlaceSpecial
		then continue end
		local toc = sgs.Sanguosha:cloneCard("snatch")
		toc:setSkillName("jl_jixi")
		toc:addSubcard(id)
		table.insert(cs,toc)
	end
	local toc = jl_daoshu.getTurnUseCard(self)
	if toc and toc:objectName()=="nosguhuocard"
	then table.insert(cs,toc) end
	for _,c in sgs.list(cards)do
		if c:getSuit()==1
		then
         	toc = sgs.Sanguosha:cloneCard("iron_chain")
			toc:setSkillName("lianhuan")
			toc:addSubcard(c)
			table.insert(cs,toc)
		end
		if c:isRed()
		then
         	toc = sgs.Sanguosha:cloneCard("slash")
			toc:setSkillName("wusheng")
			toc:addSubcard(c)
			table.insert(cs,toc)
		end
		if c:isKindOf("Jink")
		then
         	toc = sgs.Sanguosha:cloneCard("slash")
			toc:setSkillName("longdan")
			toc:addSubcard(c)
			table.insert(cs,toc)
		end
		if c:getSuit()==2
		and self.player:getHp()<2
		then
         	toc = sgs.Sanguosha:cloneCard("peach")
			toc:setSkillName("longhun")
			toc:addSubcard(c)
			table.insert(cs,toc)
		end
		if c:getSuit()==3
		and self.player:getHp()<2
		then
         	toc = sgs.Sanguosha:cloneCard("fire_slash")
			toc:setSkillName("longhun")
			toc:addSubcard(c)
			table.insert(cs,toc)
		end
		if c:getSuit()==3
		then
         	toc = sgs.Sanguosha:cloneCard("indulgence")
			toc:setSkillName("nosguose")
			toc:addSubcard(c)
			table.insert(cs,toc)
		end
		if c:isBlack()
		then
         	toc = sgs.Sanguosha:cloneCard("dismantlement")
			toc:setSkillName("qixi")
			toc:addSubcard(c)
			table.insert(cs,toc)
		end
		if c:isBlack()
		and (c:isKindOf("BasicCard") or c:isKindOf("EquipCard"))
		then
         	toc = sgs.Sanguosha:cloneCard("supply_shortage")
			toc:setSkillName("duanliang")
			toc:addSubcard(c)
			table.insert(cs,toc)
		end
		if self.player:getEquips():contains(c)
		then continue end
		if c:getSuit()==0
		then
         	toc = sgs.Sanguosha:cloneCard("analeptic")
			toc:setSkillName("jiuchi")
			toc:addSubcard(c)
			table.insert(cs,toc)
		end
		for _,c1 in sgs.list(cards)do
			if self.player:getEquips():contains(c1)
			then continue end
			if c:getSuit()==c1:getSuit()
			and c:getEffectiveId()~=c1:getEffectiveId()
			then
				toc = sgs.Sanguosha:cloneCard("archery_attack")
				toc:setSkillName("luanji")
				toc:addSubcard(c)
				toc:addSubcard(c1)
				table.insert(cs,toc)
			end
		end
		if c:isRed()
		then
         	toc = sgs.Sanguosha:cloneCard("fire_attack")
			toc:setSkillName("huoji")
			toc:addSubcard(c)
			table.insert(cs,toc)
		end
		if c:getColorString()~=self.player:getTag("xishua_shuangxiong"):toString()
		and self.player:getMark("xishua_shuangxiong-Clear")>0
		then
         	toc = sgs.Sanguosha:cloneCard("duel")
			toc:setSkillName("shuangxiong")
			toc:addSubcard(c)
			table.insert(cs,toc)
		end
	end
	for _,name in sgs.list(patterns)do
        if self.player:getMark("xishua_qice-PlayClear")>0
		or self.player:getHandcardNum()<1
		then break end
		toc = sgs.Sanguosha:cloneCard(name)
		if toc==nil or name=="fire_attack"
		then continue end
		toc:setSkillName("qice")
		toc:addSubcards(self.player:getHandcards())
		if toc:isAvailable(self.player)
		and toc:isDamageCard()
		and toc:isNDTrick()
		then
			table.insert(cs,toc)
		end
	end
	return #cs>0 and cs
end

sgs.ai_view_as.jl_xishua = function(card,player,card_place,class_name)
	if class_name=="Nullification"
	then
		if card:isBlack() and card_place==sgs.Player_PlaceHand
		then return ("nullification:kanpo[no_suit:0]="..card:getEffectiveId()) end
	  	if card:getSuit()==0 and player:getHp()<2 and card_place~=sgs.Player_PlaceSpecial
		then return ("nullification:longhun[no_suit:0]="..card:getEffectiveId()) end
	elseif name=="Slash"
	then
		if card:isRed() and card_place~=sgs.Player_PlaceSpecial
		then return ("slash:wusheng[no_suit:0]="..card:getEffectiveId()) end
	  	if card:isKindOf("Jink") and card_place~=sgs.Player_PlaceSpecial
		then return ("slash:longdan[no_suit:0]="..card:getEffectiveId()) end
	  	if card:getSuit()==3 and player:getHp()<2 and card_place~=sgs.Player_PlaceSpecial
		then return ("fire_slash:longhun[no_suit:0]="..card:getEffectiveId()) end
	elseif name=="Jink"
	then
		if card:isBlack() and card_place==sgs.Player_PlaceHand
		then return ("jink:qingguo[no_suit:0]="..card:getEffectiveId()) end
	  	if card:isKindOf("Slash") and card_place~=sgs.Player_PlaceSpecial
		then return ("jink:longdan[no_suit:0]="..card:getEffectiveId()) end
	  	if card:getSuit()==1 and player:getHp()<2 and card_place~=sgs.Player_PlaceSpecial
		then return ("jink:longhun[no_suit:0]="..card:getEffectiveId()) end
	elseif name=="Peach"
	then
	  	if card:isRed() and card_place~=sgs.Player_PlaceSpecial and player:getPhase()==sgs.Player_NotActive
		then return ("peach:jijiu[no_suit:0]="..card:getEffectiveId()) end
	  	if card:getSuit()==2 and card_place~=sgs.Player_PlaceSpecial and player:getHp()<2
		then return ("peach:longhun[no_suit:0]="..card:getEffectiveId()) end
	elseif name=="Analeptic"
	then
	  	if card:getSuit()==0 and card_place==sgs.Player_PlaceHand
		then return ("analeptic:jiuchi[no_suit:0]="..card:getEffectiveId()) end
	end
end

local jl_jiaoxin={}
jl_jiaoxin.name="jl_jiaoxin"
table.insert(sgs.ai_skills,jl_jiaoxin)
jl_jiaoxin.getTurnUseCard = function(self)
    return sgs.Card_Parse("#jl_jiaoxin:.:")
end

sgs.ai_skill_use_func["#jl_jiaoxin"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_jiaoxin = 5.4
sgs.ai_use_priority.jl_jiaoxin = 5.4

local jl_qingtan={}
jl_qingtan.name="jl_qingtan"
table.insert(sgs.ai_skills,jl_qingtan)
jl_qingtan.getTurnUseCard = function(self)
	local can = true
	for _,fp in sgs.list(self.friends_noself)do
		if fp:getHandcardNum()==1
		and self:isWeak(fp)
		then can = false end
	end
	if can
	then
        return sgs.Card_Parse("#jl_qingtancard:.:")
	end
end

sgs.ai_skill_use_func["#jl_qingtancard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_qingtancard = 5.4
sgs.ai_use_priority.jl_qingtancard = 5.4

local jl_yegui={}
jl_yegui.name="jl_yegui"
table.insert(sgs.ai_skills,jl_yegui)
jl_yegui.getTurnUseCard = function(self)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<1 then return end
	self.jl_yg_sks = {}
	for _,ep in sgs.list(self.enemies)do
		if ep:getMark("jl_yg_sks-PlayClear")<1
		and self.player:isAdjacentTo(ep)
		then
			self.jl_yg_sks.to = ep
            return sgs.Card_Parse("#jl_yeguiCard:.:")
		end
	end
end

sgs.ai_skill_use_func["#jl_yeguiCard"] = function(card,use,self)
	use.card = card
   	if use.to
  	then
	   	use.to:append(self.jl_yg_sks.to)
		self.jl_yg_sks.to:addMark("jl_yg_sks-PlayClear")
   	end
end

sgs.ai_use_value.jl_yeguiCard = 6.4
sgs.ai_use_priority.jl_yeguiCard = 6.4


sgs.ai_skill_choice.jl_shenzhu = function(self,choices)
	return self.jl_sz_sks.choices
end

local jl_shenzhu={}
jl_shenzhu.name="jl_shenzhu"
table.insert(sgs.ai_skills,jl_shenzhu)
jl_shenzhu.getTurnUseCard = function(self)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<1 then return end
	self.jl_sz_sks = {}
	for _,ep in sgs.list(self.enemies)do
        local alive = self.player:getAliveSiblings()
		alive:append(self.player)
		local can = true
		if self.player:getMark("sanyao_hp-PlayClear")<1
		then
			for _,p in sgs.list(alive)do
            	if p:getHp()>ep:getHp()
            	then can = false break end
         	end
			if can
			then
				self.jl_sz_sks.to = ep
				self.jl_sz_sks.choices = "sanyao_hp"
                return sgs.Card_Parse("#jl_shenzhucard:"..cards[1]:getEffectiveId()..":")
			end
		end
		if self.player:getMark("sanyao_hand-PlayClear")<1
		then
			can = true
			for _,p in sgs.list(alive)do
            	if p:getHandcardNum()>ep:getHandcardNum()
            	then can = false break end
         	end
			if can
			then
				self.jl_sz_sks.to = ep
				self.jl_sz_sks.choices = "sanyao_hand"
                return sgs.Card_Parse("#jl_shenzhucard:"..cards[1]:getEffectiveId()..":")
			end
		end
	end
	for _,c in sgs.list(cards)do
    	for _,fp in sgs.list(self.friends_noself)do
			if c:isKindOf("Slash")
			then
				if fp:getMark("fuman_to")<1
				then
					self.jl_sz_sks.to = fp
					self.jl_sz_sks.choices = "fuman_to"
					sgs.ai_use_priority.jl_shenzhucard = 0.4
					return sgs.Card_Parse("#jl_shenzhucard:"..c:getEffectiveId()..":")
				end
			end
		end
	end
end

sgs.ai_skill_use_func["#jl_shenzhucard"] = function(card,use,self)
	use.card = card
   	if use.to
  	then
	   	use.to:append(self.jl_sz_sks.to)
   	end
end

sgs.ai_use_value.jl_shenzhucard = 4.4
sgs.ai_use_priority.jl_shenzhucard = 4.4

local jl_xianfa={}
jl_xianfa.name="jl_xianfa"
table.insert(sgs.ai_skills,jl_xianfa)
jl_xianfa.getTurnUseCard = function(self)
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<2 then return end
	local id = "."
	for _,h in sgs.list(cards)do
		if h:isBlack()
		then
    		id = h:getEffectiveId()
			break
		end
	end
	local can
	for _,fp in sgs.list(self.friends)do
    	if self:isWeak(fp)
    	and fp:getHandcardNum()<3
		and self.player:getMark("@arise")>0
		then
    		can = fp
            self.xf_to_name = "xiongyi"
		end
	end
	local ps = self.room:getOtherPlayers(self.player)
    ps = sgs.QList2Table(ps) -- 将列表转换为表
	local to1
	for _,ep in sgs.list(ps)do
    	if to1
		then
	    	if to1:canPindian(ep)
	    	and not self:isFriend(ep)
			and ep:inMyAttackRange(to1)
			then
        		can = ep
                self.xf_to_name = "jianshu"
			end
		elseif self:isWeak(ep)
		and self:isEnemy(ep)
		and self.player:getMark("@jianshuMark")>0
		and ep:canPindian()
    	and id~="."
		then
    		to1 = ep
		end
	end
	
	for _,ep in sgs.list(self.enemies)do
    	if self:isWeak(ep)
		and self.player:getMark("@burn")>0
		then
    		can = ep
            self.xf_to_name = "fencheng"
		end
	end
	for _,ep in sgs.list(self.enemies)do
    	if self:isWeak(ep)
		and self.player:getMark("@chaos")>0
		then
    		can = ep
            self.xf_to_name = "luanwu"
		end
	end
	if can
	then
        return sgs.Card_Parse("#jl_xianfacard:.:")
	end
end

sgs.ai_skill_use_func["#jl_xianfacard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_xianfacard = -0.4
sgs.ai_use_priority.jl_xianfacard = -0.4

sgs.ai_skill_use["@@jl_xianfa"] = function(self,prompt)
	local valid = {}
	local ps = self.room:getOtherPlayers(self.player)
    ps = sgs.QList2Table(ps) -- 将列表转换为表
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	local id,to1 = ".",nil
	for _,h in sgs.list(cards)do
		if h:isBlack()
		then
    		id = h:getEffectiveId()
			break
		end
	end
	for _,ep in sgs.list(ps)do
    	if self:isWeak(ep)
		and not self:isFriend(ep)
    	and self.xf_to_name=="jianshu"
		and #valid<2
		then
    		if to1
			then
		    	if to1:canPindian(ep)
				and ep:inMyAttackRange(to1)
				then
		         	table.insert(valid,to1:objectName())
		         	table.insert(valid,ep:objectName())
				end
			else
		    	to1 = ep
			end
		end
    	if self:isWeak(ep)
		and self:isFriend(ep)
    	and self.xf_to_name=="xiongyi"
		then
    		table.insert(valid,ep:objectName())
		end
	end
	for _,ep in sgs.list(ps)do
    	if not self:isFriend(ep)
    	and self.xf_to_name=="jianshu"
		and not table.contains(valid,ep:objectName())
		and #valid<2
		then
    		if to1
			and to1:canPindian(ep)
			then
		    	table.insert(valid,to1:objectName())
		    	table.insert(valid,ep:objectName())
			else
		    	to1 = ep
			end
		end
 	end
	for _,ep in sgs.list(ps)do
    	if self.xf_to_name=="jianshu"
		and not table.contains(valid,ep:objectName())
		and #valid<2
		then
    		if to1
			and to1:canPindian(ep)
			then
		    	table.insert(valid,to1:objectName())
		    	table.insert(valid,ep:objectName())
			else
		    	to1 = ep
			end
		end
 	end
	if #valid<1
   	and self.xf_to_name=="jianshu"
	and id=="."
	then return end
	return string.format("#jl_xianfaCard:%s:->%s",id,table.concat(valid,"+"))
end

local jl_sexiang={}
jl_sexiang.name="jl_sexiang"
table.insert(sgs.ai_skills,jl_sexiang)
jl_sexiang.getTurnUseCard = function(self)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<3
	or self.player:isWounded()
	or self.player:containsTrick("indulgence")
	then return end
	for _,h in sgs.list(cards)do
		if h:getSuitString()=="diamond"
		then
            return sgs.Card_Parse("#jl_sexiangCard:"..h:getEffectiveId()..":")
		end
	end
end

sgs.ai_skill_use_func["#jl_sexiangCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_sexiangCard = -0.4
sgs.ai_use_priority.jl_sexiangCard = -0.4

local jl_yanyin={}
jl_yanyin.name="jl_yanyin"
table.insert(sgs.ai_skills,jl_yanyin)
jl_yanyin.getTurnUseCard = function(self)
    local cards = self.player:getCards("h")
    cards = self:sortByKeepValue(cards) -- 按保留值排序
   	if #cards<2 then return end
   	local give = {}
   	for _,h in sgs.list(cards)do
      	if #give>1 then break end
      	table.insert(give,h:getEffectiveId())
  	end
   	local can
   	for _,ep in sgs.list(self.enemies)do
    	if self:isWeak(ep)
		then
	    	can = ep
			self._yanyin_name = "jl_yanyin1"
		end
	end
	if #cards>self.player:getHp()
	then
	   	can = self.player
		self._yanyin_name = "jl_yanyin1"
	end
   	for _,ep in sgs.list(self.friends)do
    	if self:isWeak(ep)
		then
	    	can = ep
			self._yanyin_name = "jl_yanyin2"
		end
	end
	if can
	and #give>1
	then
        return sgs.Card_Parse("#jl_yanyinCard:"..table.concat(give,"+")..":")
	end
end

sgs.ai_skill_use_func["#jl_yanyinCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_yanyinCard = 3
sgs.ai_use_priority.jl_yanyinCard = 4

sgs.ai_skill_choice.jl_yanyin = function(self,choices)
	return self._yanyin_name
end

local jl_shehuo={}
jl_shehuo.name="jl_shehuo"
table.insert(sgs.ai_skills,jl_shehuo)
jl_shehuo.getTurnUseCard = function(self)
	if self.player:getMaxCards()>0
	and self.player:getHandcardNum()<self.player:getHp()
	then
        return sgs.Card_Parse("#jishecard:.:")
	end
end

sgs.ai_skill_use_func["#jishecard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jishecard = 6.4
sgs.ai_use_priority.jishecard = 6.4

local jl_chaixie={}
jl_chaixie.name="jl_chaixie"
table.insert(sgs.ai_skills,jl_chaixie)
jl_chaixie.getTurnUseCard = function(self)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
    for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
      	if self.player:usedTimes("#tiaoxincard")<1
		and p:inMyAttackRange(self.player)
		and not self:isFriend(p)
		and not p:isNude()
    	then
            self.jl_cx_to = p
            return sgs.Card_Parse("#tiaoxincard:.:")
		end
	end
    local cards = self.player:getPile("field")
    for _,id in sgs.list(cards)do
       	local poi = dummyCard("snatch")
	   	poi:addSubcard(id)
       	local dummy = self:aiUseCard(poi)
		if dummy.card and dummy.to
		then
        	return sgs.Card_Parse("snatch:jl_jixi[no_suit:0]="..id)
		end
	end
    cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if h:isBlack()
		then
        	return sgs.Card_Parse("dismantlement:qixi[no_suit:0]="..h:getEffectiveId())
		end
	end
end

sgs.ai_skill_use_func["#tiaoxincard"] = function(card,use,self)
	use.card = card
    if use.to
	then
    	use.to:append(self.jl_cx_to)
	end
end

sgs.ai_use_value.tiaoxincard = 3.4
sgs.ai_use_priority.tiaoxincard = 3.4

local jl_qiangxuan={}
jl_qiangxuan.name="jl_qiangxuan"
table.insert(sgs.ai_skills,jl_qiangxuan)
jl_qiangxuan.getTurnUseCard = function(self)
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if self.player:getTreasure() then return end
	for _,h in sgs.list(cards)do
		if h:isBlack()
		then
            return sgs.Card_Parse("#chexuancard:"..h:getEffectiveId()..":")
		end
	end
end

sgs.ai_skill_use_func["#chexuancard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.chexuancard = 0.4
sgs.ai_use_priority.chexuancard = 0.4


local jl_kunfen={}
jl_kunfen.name="jl_kunfen"
table.insert(sgs.ai_skills,jl_kunfen)
jl_kunfen.getTurnUseCard = function(self)
	local valid = {}
    local cards,n = self.player:getCards("h"),0
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<2 then return end
	for _,h in sgs.list(cards)do
		if #valid>1 then break end
		table.insert(valid,h:getEffectiveId())
	end
    for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
      	if p:getHp()<4
		and self:isEnemy(p)
    	then n = n+1 end
	end
	if n<1 then return end
    return sgs.Card_Parse("#jl_kunfencard:"..table.concat(valid,"+")..":")
end

sgs.ai_skill_use_func["#jl_kunfencard"] = function(card,use,self)
	use.card = card
	local destlist = sgs.QList2Table(self.room:getOtherPlayers(self.player))
	self:sort(destlist,"card")
	for _,to in sgs.list(destlist)do
     	if self:isEnemy(to)
		and use.to and use.to:length()<1
	   	then use.to:append(to) end
   	end
	self:sort(destlist,"card",true)
	for _,to in sgs.list(destlist)do
     	if not self:isFriend(to)
		and use.to
      	and use.to:length()<1
	   	then use.to:append(to) end
   	end
end

sgs.ai_use_value.jl_kunfencard = 3.4
sgs.ai_use_priority.jl_kunfencard = 3.4

local jl_zhugong={}
jl_zhugong.name="jl_zhugong"
table.insert(sgs.ai_skills,jl_zhugong)
jl_zhugong.getTurnUseCard = function(self)
    if #self.friends<2 then return end
   	local poi = dummyCard()
   	local dummy = self:aiUseCard(poi)
 	if poi:isAvailable(self.player)
	and hasToGenerals(self.player)
	and dummy.card and dummy.to:length()>0
  	then
       	return sgs.Card_Parse("#jl_zhugongCard:.:")
	end
end

sgs.ai_skill_use_func["#jl_zhugongCard"] = function(card,use,self)
	local poi = dummyCard()
   	local dummy = self:aiUseCard(poi)
	if dummy.card then use.card = card end
	if use.to and dummy.to then use.to = dummy.to end
end

sgs.ai_use_value.jl_zhugongCard = 4
sgs.ai_use_priority.jl_zhugongCard = 4

local jl_qiangjiVS={}
jl_qiangjiVS.name="jl_qiangjiVS"
table.insert(sgs.ai_skills,jl_qiangjiVS)
jl_qiangjiVS.getTurnUseCard = function(self)
  	for _,owner in sgs.list(self.room:findPlayersBySkillName("jl_qiangji"))do
        return sgs.Card_Parse("#jl_qiangjiCard:.:")
	end
end

sgs.ai_skill_use_func["#jl_qiangjiCard"] = function(card,use,self)
	local poi = dummyCard("slash")
   	local dummy = self:aiUseCard(poi)
	if dummy.card and dummy.to
	and poi:isAvailable(self.player)
	then
		use.card = card
		if use.to then use.to = dummy.to end
	end
end

sgs.ai_use_value.jl_qiangjiCard = 4.4
sgs.ai_use_priority.jl_qiangjiCard = 3


function sgs.ai_cardsview.jl_qingshen(self,class_name,player)
   	local cards = sgs.QList2Table(player:getCards("h"))
    self:sortByKeepValue(cards)
	if #cards>0
	then
		for _,card in sgs.list(cards)do
        	if card:isBlack()
	    	then
	    		return ("jink:jl_qingshen[no_suit:0]="..card:getEffectiveId())
	    	end
		end
	end
end

function sgs.ai_cardsview.jl_luoshi(self,class_name,player)
	if player:faceUp()
	then
     	return ("analeptic:jl_luoshi[no_suit:0]=.")
	end
end

local jl_liyue={}
jl_liyue.name="jl_liyue"
table.insert(sgs.ai_skills,jl_liyue)
jl_liyue.getTurnUseCard = function(self)
    local cards,n = self.player:getCards("h"),0
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<1 then return end
    for _,p in sgs.list(self.player:getAliveSiblings())do
      	if p:isMale()
    	then n = n+1 end
	end
	if n<2 then return end
    return sgs.Card_Parse("#jl_liyueCard:"..cards[1]:getEffectiveId()..":")
end

sgs.ai_skill_use_func["#jl_liyueCard"] = function(card,use,self)
	local player,n = self.player,0
	use.card = card
	local destlist = sgs.QList2Table(self.room:getOtherPlayers(player))
	self:sort(destlist,"card")
	for _,to in sgs.list(destlist)do
     	if to:isMale()
		and not self:isFriend(to)
	   	then n = n+1 end
   	end
	if n>1
	then
    	for _,to in sgs.list(destlist)do
         	if to:isMale()
		    and not self:isFriend(to)
	    	and use.to
         	and use.to:length()<2
	     	then use.to:append(to) end
	    end
	end
	self:sort(destlist,"card",true)
	for _,to in sgs.list(destlist)do
     	if to:isMale()
		and self:isFriend(to)
		and use.to
      	and use.to:length()<2
	   	then use.to:append(to) end
   	end
	self:sort(destlist,"card")
	for _,to in sgs.list(destlist)do
     	if to:isMale()
		and not self:isFriend(to)
		and use.to
      	and use.to:length()<2
	   	then use.to:append(to) end
   	end
end

sgs.ai_use_value.jl_liyueCard = 5.4
sgs.ai_use_priority.jl_liyueCard = 5.4

local jl_liuse={}
jl_liuse.name="jl_liuse"
table.insert(sgs.ai_skills,jl_liuse)
jl_liuse.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	for _,card in sgs.list(cards)do
		if card:getSuitString()=="diamond"
		then
        	return sgs.Card_Parse("indulgence:jl_liuse[no_suit:0]="..card:getEffectiveId())
		end
	end
end

sgs.ai_skill_use["@@jl_liuse"] = function(self,prompt)
	local valid = nil
	local destlist = self.room:getOtherPlayers(self.player)
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	for _,friend in sgs.list(destlist)do
		if valid then break end
		if not self:isFriend(friend)
		and friend:hasFlag("liuse")
		then valid = friend:objectName() end
	end
    self:sort(destlist,"hp",true)
	for _,friend in sgs.list(destlist)do
		if valid then break end
		if friend:hasFlag("liuse")
		then valid = friend:objectName() end
	end
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if valid and #cards>0
	then
    	return string.format("#jl_liuseCard:%s:->%s",cards[1]:getEffectiveId(),valid)
	end
end

sgs.ai_skill_use["@@jl_tianyanbf"] = function(self,prompt)
	local valid = nil
	local destlist = self.room:getOtherPlayers(self.player)
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")--losthp
	for _,friend in sgs.list(destlist)do
		if valid then break end
		if self:isEnemy(friend)
		and friend:getHp()<2
		then valid = friend:objectName() end
	end
    self:sort(destlist,"losthp")
	for _,friend in sgs.list(destlist)do
		if valid then break end
		if not self:isFriend(friend)
		then valid = friend:objectName() end
	end
    self:sort(destlist,"hp",true)
	for _,friend in sgs.list(destlist)do
		if valid then break end
		valid = friend:objectName()
	end
    local cards,heart = self.player:getCards("h"),nil
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if h:getSuit()==sgs.Card_Heart
		then heart = h:getEffectiveId() break end
	end
	if valid
	and heart
	then
    	return string.format("#jl_tianyanbfCard:%s:->%s",heart,valid)
	end
end

sgs.ai_skill_use["@@jl_haomeng!"] = function(self,prompt)
	local valid = {}
	local destlist = self.room:getOtherPlayers(self.player)
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if #valid>=math.floor(#cards/2) then break end
    	table.insert(valid,h:getEffectiveId())
	end
	if #valid<1 then return end
	for _,friend in sgs.list(destlist)do
		if self:isFriend(friend) and friend:getHandcardNum()==self.player:getMark("jl_haomeng")
		then
           	return string.format("#jl_haomengCard:%s:->%s",table.concat(valid,"+"),friend:objectName())
		end
	end
	for _,friend in sgs.list(destlist)do
		if not self:isEnemy(friend) and friend:getHandcardNum()==self.player:getMark("jl_haomeng")
		then
           	return string.format("#jl_haomengCard:%s:->%s",table.concat(valid,"+"),friend:objectName())
		end
	end
	for _,friend in sgs.list(destlist)do
		if friend:getHandcardNum()==self.player:getMark("jl_haomeng")
		then
           	return string.format("#jl_haomengCard:%s:->%s",table.concat(valid,"+"),friend:objectName())
		end
	end
end

sgs.ai_skill_use["@@jl_jianjie"] = function(self,prompt)
	local valid,plists = {},false
	local destlist = self.room:getAllPlayers()
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	for _,to in sgs.list(destlist)do
	   	if to:getMark("&jl_longyin")>0
	    or to:getMark("&jl_fengyin")>0
		then plists = true end
	end
	if plists
	then
    	for _,to in sgs.list(destlist)do
	    	if to:getMark("&jl_longyin")+to:getMark("&jl_fengyin")>0
			and #valid<1 and self:isFriend(to)
	    	then table.insert(valid,to:objectName()) end
    	end
    	for _,to in sgs.list(destlist)do
	    	if #valid>1 then break end
	    	if self:isEnemy(to) and #valid>0 and to:objectName()~=valid[1]
	    	then table.insert(valid,to:objectName()) end
    	end
    	for _,to in sgs.list(destlist)do
	    	if #valid>1 then break end
	    	if not self:isFriend(to) and #valid>0 and to:objectName()~=valid[1]
	    	then table.insert(valid,to:objectName()) end
    	end
	else
    	for _,to in sgs.list(destlist)do
	    	if #valid>1 then break end
	    	if self:isEnemy(to) then table.insert(valid,to:objectName()) end
    	end
    	for _,to in sgs.list(destlist)do
	    	if #valid>1 then break end
	    	if not (self:isFriend(to) or table.contains(valid,to:objectName()))
			then table.insert(valid,to:objectName()) end
    	end
    	for _,to in sgs.list(destlist)do
	    	if #valid>1 then break end
			if table.contains(valid,to:objectName()) then continue end
	    	table.insert(valid,to:objectName())
    	end
	end
	if #valid<2 then return end
	return string.format("#jl_jianjieCard:.:->%s",table.concat(valid,"+"))
end

sgs.ai_skill_use["@@jl_bajun"] = function(self,prompt)
	local valid = {}
    for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
       	for _,e in sgs.list(p:getEquipsId())do
			if self:doDisCard(p,e,true)
			then table.insert(valid,e) end
       	end
	end
	if #valid<1 then return end
	return string.format("#jl_bajunCard:%s:",table.concat(valid,"+"))
end

sgs.ai_skill_use["@@jl_jinghun!"] = function(self,prompt)
	local valid,cs = {},{}
	local yuqi_help = self.player:getTag("jl_jinghunForAI"):toIntList()
    for _,id in sgs.list(yuqi_help)do
      	table.insert(cs,sgs.Sanguosha:getCard(id))
	end
    self:sortByKeepValue(cs) -- 按保留值排序
	for _,c in sgs.list(cs)do
      	if self:isFriend(self.player:getTag("jl_jinghun"):toPlayer())
    	then
        	if #valid<#cs-1
			or #valid<self.player:getMark("jl_jinghun_3")
			then table.insert(valid,c:getEffectiveId()) end
		else
        	if #valid<self.player:getMark("jl_jinghun_3")
			then table.insert(valid,c:getEffectiveId()) end
		end
	end
	if #valid<1 then return end
	return string.format("#jl_jinghunCard:%s:",table.concat(valid,"+"))
end

sgs.ai_skill_use["@@jl_jinghun"] = function(self,prompt)
	local valid = {}
	local yuqi_help = self.player:getTag("jinghuncardForAI"):toIntList()
    for _,id in sgs.list(yuqi_help)do
      	table.insert(valid,id)
	end
	if #valid<1 then return end
	return string.format("#jl_jinghunCard:%s:",table.concat(valid,"+"))
end

sgs.ai_skill_use["@@jl_mingqi!"] = function(self,prompt)
    local c = self.player:getTag("jl_mingqi"):toString()
	c = sgs.Sanguosha:cloneCard(c)
	c:setSkillName("_jl_mingqi")
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

sgs.ai_skill_use["@@jl_neifa1!"] = function(self,prompt)
	local valid,ts = {},sgs.IntList()
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if ts:contains(h:getTypeId())
		or not h:isBlack()
		then continue end
    	table.insert(valid,h:getEffectiveId())
		ts:append(h:getTypeId())
	end
	return string.format("#jl_bajunCard:%s:",table.concat(valid,"+"))
end

sgs.ai_skill_use["@@jl_poying"] = function(self,prompt)
	local valid = {}
	local destlist = self.player:getAliveSiblings()
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
    self:sort(destlist,"hp")
	for _,friend in sgs.list(destlist)do
		if #valid>1 then break end
		if not self:isFriend(friend)
		and self.player:canSlash(friend,jl_poying_s)
		and friend:getMark("no_s")<1
		then table.insert(valid,friend:objectName()) end
	end
	if #valid>0
	then
    	return string.format("#jl_poyingCard:.:->%s",table.concat(valid,"+"))
	end
end

sgs.ai_skill_use["@@jl_shenji"] = function(self,prompt)
	local valid,to = {},nil
    for _,p in sgs.list(self.player:getAliveSiblings())do
      	if not self:isFriend(p) and self:isWeak(p)
    	then to = p break end
	end
    for _,p in sgs.list(self.player:getAliveSiblings())do
      	if self:isEnemy(p) and self:isWeak(p)
    	then to = p break end
	end
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if #valid>=to:getCardCount()
		or to==nil
		then break end
    	table.insert(valid,h:getEffectiveId())
	end
	if #valid<1 then return end
	return string.format("#jl_shenjiCard:%s:->%s",table.concat(valid,"+"),to:objectName())
end

sgs.ai_skill_use["@@jl_gaojian"] = function(self,prompt)
	local valid,to = {},nil
	local players = self.player:getAliveSiblings()
    self:sort(players,"handcard")
    for _,p in sgs.list(players)do
      	if not self:isEnemy(p) and self:isWeak(p)
    	then to = p break end
	end
    for _,p in sgs.list(players)do
      	if self:isFriend(p) then to = p break end
	end
	if not to then return end
    local cards = self.player:getCards("he")
    cards = self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if #valid>=to:getMark("&jl_shouling") then break end
    	table.insert(valid,h:getEffectiveId())
	end
	return string.format("#jl_gaojianCard:%s:->%s",table.concat(valid,"+"),to:objectName())
end

sgs.ai_skill_use["@@jl_duzhan"] = function(self,prompt)
	local valid = {}
	local destlist = self.player:getAliveSiblings()
    destlist = self:sort(destlist,"hp")
	for _,to in sgs.list(destlist)do
		if #valid>1 then break end
		if to:getKingdom()==self.player:getKingdom()
		then
			for _,p in sgs.list(destlist)do
				if p==to then continue end
				if self:isEnemy(p)
				and to:inMyAttackRange(p)
				and to:canSlash(p)
				then
					table.insert(valid,p:objectName())
					table.insert(valid,to:objectName())
					break
				end
			end
			if #valid>1 then break end
			for _,p in sgs.list(destlist)do
				if p==to then continue end
				if not self:isFriend(p)
				and to:inMyAttackRange(p)
				and to:canSlash(p)
				then
					table.insert(valid,p:objectName())
					table.insert(valid,to:objectName())
					break
				end
			end
		end
	end
	if #valid>1
	then
    	return string.format("#jl_duzhanCard:.:->%s",table.concat(valid,"+"))
	end
end


sgs.ai_skill_cardask["jl_chailu1"] = function(self,data,pattern)
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
    self:sortByKeepValue(cards) -- 按保留值排序
   	for _,c in sgs.list(cards)do
    	if sgs.Sanguosha:matchExpPattern(pattern,self.player,c)
		and c:getTypeId()~=1 then return c:getEffectiveId() end
	end
    return "."
end






sgs.ai_skill_use["jl_wuxiesy-use"] = function(self,prompt,method,pattern)--请求使用卡扩加
	
	--可以通过 prompt 里的第一个变量接入 ai_skill_use 同时增加 pattern 接口
	--例如现在的请求函数为 room:askForUseCard(player,pattern,"jl_wuxiesy-use:xxx:xxx")
	
	local c = self:getCard("JlWuxiesy")
	local effect = self.player:getTag("jl_wuxiesy"):toCardEffect()
	if self:isFriend(effect.to) and effect.card:isDamageCard()
	or effect.from and self:isEnemy(effect.from) and not effect.multiple
	then return c and c:toString() or "." end
    return "."
end

sgs.ai_keep_value.JlWuxiesy = 4

sgs.ai_skill_cardask["jl_sexiang0"] = function(self,data)
    local damage = data:toDamage()
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if h:getSuitString()=="heart"
		and self:isFriend(damage.to)
	    and self:isWeak(damage.to)
    	then return h:getEffectiveId() end
	end
    return "."
end

sgs.ai_skill_cardask["jl_huguan0"] = function(self,data)
    local use = data:toCardUse()
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards>2
	and self:isFriend(use.from)
  	then return cards[1]:getEffectiveId() end
    return "."
end

sgs.ai_skill_askforyiji.jl_yangguang = function(self,card_ids)
	local to = self.player:getTag("jl_yangguang"):toPlayer()
	for _,id in sgs.list(card_ids)do
    	id = sgs.Sanguosha:getCard(id)
		if self:isFriend(to)
		and ((id:isKindOf("Jink") and to:getHp()<3)
		or (id:isKindOf("TrickCard") and to:getHp()>2))
		then return to,id:getEffectiveId() end
	end
end

sgs.ai_skill_askforyiji.jl_tianji = function(self,card_ids)
    return sgs.ai_skill_askforyiji.nosyiji(self,card_ids)
end

sgs.ai_skill_cardask["jl_luanpei0"] = function(self,data,pattern)
	local target = self.room:getCurrent()
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if sgs.Sanguosha:matchExpPattern(pattern,self.player,h)
		and (self:isFriend(target) and target:isWounded()
	    or self.player:isWounded()
		or self.player:getHandcardNum()<target:getHandcardNum())
    	then return h:getEffectiveId() end
	end
    return "."
end





--addAiSkills(name).getTurnUseCard
--稍微简化了 getTurnUseCard 添加进 sgs.ai_skills 的过程
addAiSkills("jl_wusheng").getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	for _,h in sgs.list(cards)do
		if h:isRed()
		then
			local slash = sgs.Sanguosha:cloneCard("slash")
			slash:setSkillName("wusheng")
			slash:addSubcard(h)
			local dummy = self:aiUseCard(slash)
			--self:aiUseCard(card)
			--简化了使用某张卡的判定
			--如果输出了 dummy.card 和 dummy.to
			--则表示这张卡ai将会使用（前提是这张卡有写使用的ai）
			--主要用于进行转化卡的决策（例如现在的红牌当杀）
			--这个 dummy 直接包含了使用的数据
			if dummy.card and dummy.to
			and slash:isAvailable(self.player)
			then return slash end
			slash:deleteLater()
		end
	end
end

sgs.ai_view_as.jl_wusheng = function(card,player,card_place,class_name)
	if card:isRed()
	and card_place~=sgs.Player_PlaceSpecial
	then
    	return ("slash:wusheng[no_suit:0]="..card:getEffectiveId())
	end
end

local jl_xiaoyin={}
jl_xiaoyin.name="jl_xiaoyin"
table.insert(sgs.ai_skills,jl_xiaoyin)
jl_xiaoyin.getTurnUseCard = function(self)
	local valid = {}
    local cards,n = self.player:getCards("h"),0
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<2 then return end
	for _,h in sgs.list(cards)do
		if #valid>1 then break end
		table.insert(valid,h:getEffectiveId())
	end
    for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
      	if p:isMale()
		and p:isWounded()
		and self:isFriend(p)
    	then n = n+1 end
	end
	if n<1 then return end
    return sgs.Card_Parse("#jl_xiaoyinCard:"..table.concat(valid,"+")..":")
end

sgs.ai_skill_use_func["#jl_xiaoyinCard"] = function(card,use,self)
	use.card = card
	local destlist = sgs.QList2Table(self.room:getOtherPlayers(self.player))
	self:sort(destlist,"card")
	for _,to in sgs.list(destlist)do
     	if to:isMale()
		and to:isWounded()
		and self:isFriend(to)
		and use.to
      	and use.to:length()<1
	   	then use.to:append(to) end
   	end
	self:sort(destlist,"card",true)
	for _,to in sgs.list(destlist)do
     	if to:isMale()
		and to:isWounded()
		and not self:isEnemy(to)
		and use.to
      	and use.to:length()<1
	   	then use.to:append(to) end
   	end
end

sgs.ai_use_value.jl_xiaoyinCard = 6.4
sgs.ai_use_priority.jl_xiaoyinCard = 6.4

sgs.ai_skill_cardask["@jl_guikui-card"] = function(self,data)--改判系武将的ai
	local cards = self.player:getCards("h")
	for _,id in sgs.list(self.player:getPile("wooden_ox"))do
		cards:prepend(sgs.Sanguosha:getCard(id))
	end
	if cards:isEmpty() then return "." end
	cards = sgs.QList2Table(cards)
    local judge = data:toJudge()
	local id = self:getRetrialCardId(cards,judge)--从输入的牌表中选择一张可改判的牌的id并输出
    if id~=-1 --输出-1则表示没有可改判的牌，所以需要排除
	then
		if self:needRetrial(judge)--判定是否要改判
		then return id end
		--米妹的改判逻辑也是类似的，但比较复杂，暂不讨论
	end
    return "."
end

sgs.ai_skill_cardask["@jl_leidaocard"] = function(self,data)--鬼道类的替换判定牌ai
	local all_cards = self.player:getCards("he")
	for _,id in sgs.list(self.player:getPile("wooden_ox"))do
		all_cards:prepend(sgs.Sanguosha:getCard(id))
	end
	if all_cards:isEmpty() then return "." end
	local cards = {}
	for _,card in sgs.list(all_cards)do
		if card:isBlack()
		then
			table.insert(cards,card)
		end
	end
	if #cards<1 then return "." end
	local judge = data:toJudge()
	local id = self:getRetrialCardId(cards,judge,nil,true)--从输入的牌表中选择一张可改判的牌的id并输出
    if id~=-1 --输出-1则表示没有可改判的牌，所以需要排除
	then
		if self:needRetrial(judge)--判定是否要改判
		or judge.card:getSuit()==sgs.Card_Spade and self:getSuitNum("spade",true)<1 --或者判定牌价值较高就替换
       	or judge.card:isKindOf("Jink") and self:getCardsNum("Jink","h")<1
		or self:getUseValue(judge.card)>self:getUseValue(sgs.Sanguosha:getCard(id))
	   	then return id end
	end
    return "."
end

local jl_quming={}
jl_quming.name="jl_quming"
table.insert(sgs.ai_skills,jl_quming)
jl_quming.getTurnUseCard = function(self)
    local cards,n = self.player:getCards("h"),0
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<1 then return end
    for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
      	if p:getHp()>self.player:getHp()
		and p:canPindian()
    	then
            for _,to in sgs.list(self.room:getOtherPlayers(p))do
		    	if p:inMyAttackRange(to)
	        	and not self:isFriend(to)
				then n = n+1 end
			end
		end
	end
	if n<1 then return end
    return sgs.Card_Parse("#jl_qumingCard:"..cards[1]:getEffectiveId()..":")
end

sgs.ai_skill_use_func["#jl_qumingCard"] = function(card,use,self)
	use.card = card
	local destlist = sgs.QList2Table(self.room:getOtherPlayers(self.player))
	self:sort(destlist,"card")
	for _,to in sgs.list(destlist)do
     	if to:getHp()>self.player:getHp()
		and to:canPindian()
		and not self:isFriend(to)
	   	then
            for _,p in sgs.list(self.room:getOtherPlayers(to))do
		    	if to:inMyAttackRange(p)
	        	and not self:isFriend(p)
	         	and use.to
               	and use.to:length()<1
				then use.to:append(to) end
			end
	   	end
   	end
	self:sort(destlist,"card",true)
	for _,to in sgs.list(destlist)do
     	if to:getHp()>self.player:getHp()
		and to:canPindian()
		and self:isFriend(to)
	   	then
            for _,p in sgs.list(self.room:getOtherPlayers(to))do
		    	if to:inMyAttackRange(p)
	        	and not self:isFriend(p)
	         	and use.to
               	and use.to:length()<1
				then use.to:append(to) end
			end
	   	end
   	end
end

sgs.ai_use_value.jl_qumingCard = 5.4
sgs.ai_use_priority.jl_qumingCard = 5.4

local jl_zhizheng={}
jl_zhizheng.name="jl_zhizheng"
table.insert(sgs.ai_skills,jl_zhizheng)
jl_zhizheng.getTurnUseCard = function(self)
    local cards,n = self.player:getCards("h"),0
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if h:isKindOf("EquipCard")
		then
	    	n = h:getRealCard():toEquipCard():location()
            for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
               	if self:isFriend(p) and p:getEquip(n)==nil
            	then
                    return sgs.Card_Parse("#jl_zhizhengCard:"..h:getEffectiveId()..":")
                end
           	end
	   	end
   	end
end

sgs.ai_skill_use_func["#jl_zhizhengCard"] = function(card,use,self)
	use.card = card
    local cards,n = self.player:getCards("h"),0
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,h in sgs.list(cards)do
		if h:isKindOf("EquipCard")
		then
	    	n = h:getRealCard():toEquipCard():location()
            for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
               	if self:isFriend(p)
				and p:getEquip(n)==nil and use.to
				then use.to:append(p) return end
           	end
	   	end
   	end
end

sgs.ai_use_value.jl_zhizhengCard = 6.4
sgs.ai_use_priority.jl_zhizhengCard = 6.4

local jl_yingjian={}
jl_yingjian.name="jl_yingjian"
table.insert(sgs.ai_skills,jl_yingjian)
jl_yingjian.getTurnUseCard = function(self)
	local valid = {}
    local cards,n = self.player:getCards("h"),0
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<1 or #self.enemies<1 then return end
    return sgs.Card_Parse("#jl_yingjianCard:.:")
end

sgs.ai_skill_use_func["#jl_yingjianCard"] = function(card,use,self)
	use.card = card
	local destlist = sgs.QList2Table(self.room:getOtherPlayers(self.player))
	self:sort(destlist,"hp")
	for _,to in sgs.list(destlist)do
     	if self:isEnemy(to)
		and use.to
      	and use.to:length()<1
	   	then
	      	use.to:append(to)
	   	end
   	end
end

sgs.ai_use_value.jl_yingjianCard = 6.4
sgs.ai_use_priority.jl_yingjianCard = 6.4

local jl_haomeng={}
jl_haomeng.name="jl_haomeng"
table.insert(sgs.ai_skills,jl_haomeng)
jl_haomeng.getTurnUseCard = function(self)
	local valid = {}
    local cards,n = self.player:getCards("h"),0
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<1 then return end
    for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
      	if not self:isEnemy(p)
    	then
            for _,p2 in sgs.list(self.room:getOtherPlayers(self.player))do
            	n = math.abs(p:getHandcardNum()-p2:getHandcardNum())
				if self:isEnemy(p2)
				and p:getHandcardNum()<p:getHandcardNum()
				and n<=#cards
            	then
                	for _,h in sgs.list(cards)do
                		if #valid>=n then break end
                		table.insert(valid,h:getEffectiveId())
                	end
                    return sgs.Card_Parse("#jl_haomengCard:"..table.concat(valid,"+")..":")
	    		end
			end
		end
	end
end

sgs.ai_skill_use_func["#jl_haomengCard"] = function(card,use,self)
	use.card = card
	local destlist = sgs.QList2Table(self.room:getOtherPlayers(self.player))
	self:sort(destlist,"card")
    local cards,n = self.player:getCards("h"),0
    cards = sgs.QList2Table(cards) -- 将列表转换为表
   	for _,p in sgs.list(destlist)do
      	if not self:isEnemy(p)
    	then
         	for _,p2 in sgs.list(destlist)do
            	n = math.abs(p:getHandcardNum()-p2:getHandcardNum())
				if self:isEnemy(p2)
				and p:getHandcardNum()<p:getHandcardNum()
				and n<=#cards
	        	and use.to
            	then
	            	use.to:append(p)
	            	use.to:append(p2)
					return
	    		end
			end
		end
	end
end

sgs.ai_use_value.jl_haomengCard = 2.4
sgs.ai_use_priority.jl_haomengCard = 2.4

local jl_hongfa={}
jl_hongfa.name="jl_hongfa"
table.insert(sgs.ai_skills,jl_hongfa)
jl_hongfa.getTurnUseCard = function(self)
    local cards = self.player:getCards("he")
    cards = self:sortByKeepValue(cards) -- 将列表转换为表
	local valid = {}
	if #cards<3
	or #self.friends<2
	or self.player:getHp()>2
	then return end
	for _,h in sgs.list(cards)do
		table.insert(valid,h:getEffectiveId())
	end
   	for _,name in sgs.list(patterns)do
   		local poi = dummyCard(name)
	   	if poi and poi:isAvailable(self.player)
	   	and poi:isKindOf("BasicCard")
	   	then
         	local dummy = self:aiUseCard(poi)
	       	if dummy.card
           	and dummy.to
	       	then
				self.jl_hongfa_name = dummy
                return sgs.Card_Parse("#jl_hongfacard:"..table.concat(valid,"+")..":")
	    	end
		end
	end
end

sgs.ai_skill_use_func["#jl_hongfacard"] = function(card,use,self)
	use.card = card
	local destlist = sgs.QList2Table(self.room:getOtherPlayers(self.player))
	self:sort(destlist,"handcard")
	for _,to in sgs.list(destlist)do
     	if self:isFriend(to)
		and use.to and use.to:length()<1
	   	then use.to:append(to) end
   	end
end

sgs.ai_use_value.jl_hongfacard = 2.4
sgs.ai_use_priority.jl_hongfacard = 2.4

sgs.ai_skill_use["@@jl_hongfa!"] = function(self,prompt)
   	local dummy = self.jl_hongfa_name
	dummy.card:setSkillName("_jl_hongfa")
	if dummy.card
	and dummy.to
	then
		local tos = {}
		for _,p in sgs.list(dummy.to)do
			table.insert(tos,p:objectName())
		end
       	return dummy.card:toString().."->"..table.concat(tos,"+")
	end
end

local jl_qiefudao={}
jl_qiefudao.name="jl_qiefudao"
table.insert(sgs.ai_skills,jl_qiefudao)
jl_qiefudao.getTurnUseCard = function(self)
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
    local j = self:getCardsNum("Jink")
	for _,h in sgs.list(cards)do
		if h:isKindOf("Slash")
		and sgs.Slash_IsAvailable(self.player)
	   	and not self.player:isProhibited(self.player,h)
		then
	    	if self.player:hasSkills("guixin|jieming|yiji|nosyiji|chengxiang|noschengxiang")
			and self.player:getHp()>1
	    	then
                return sgs.Card_Parse("#jl_qiefudaocard:"..h:getEffectiveId()..":")
			end
	    	if self.player:hasSkills("leiji|nosleiji")
			and j>0
	    	then
                return sgs.Card_Parse("#jl_qiefudaocard:"..h:getEffectiveId()..":")
			end
	   	end
   	end
end

sgs.ai_skill_use_func["#jl_qiefudaocard"] = function(card,use,self)
	use.card = card
	if use.to
	then
        use.to:append(self.player)
	end
end

sgs.ai_use_value.jl_qiefudaocard = 6.4
sgs.ai_use_priority.jl_qiefudaocard = 6.4

local jl_bingyuegong={}
jl_bingyuegong.name="jl_bingyuegong"
table.insert(sgs.ai_skills,jl_bingyuegong)
jl_bingyuegong.getTurnUseCard = function(self)
   	return turnUse_spear(self,"jl_bingyuegong")
end

function sgs.ai_cardsview.jl_bingyuegong(self,class_name,player)
	if class_name=="Slash"
	then
		return cardsView_spear(self,player,player:getWeapon():objectName())
	end
end

sgs.ai_keep_value.JlBingyuegong = 3
sgs.ai_use_priority.JlBingyuegong = 4.9
sgs.ai_use_value.JlBingyuegong = 7.6

sgs.ai_use_priority.jl_bajun = 8.4


sgs.ai_use_revises.jl_wangba = function(self,card,use)
	if card:isKindOf("Armor")
	then return false end
end

sgs.ai_use_revises.jl_bajun = function(self,card,use)
	local player,n = self.player,0
	for _,ep in sgs.list(self.enemies)do
		n = n+ep:getEquips():length()
	end
	if n>#self.enemies
	and card:isKindOf("DefensiveHorse")
	then use.card = card end
end

sgs.ai_use_revises.jl_bingyuegong = function(self,card,use)--新增技能（装备）对卡牌使用修正接口
	if card:isKindOf("Weapon")
	then return false end -- 已装备冰月弓时将要使用其他的武器，返回 false 取消之
	if not card:isKindOf("Slash")--不是杀的牌结束后续修正（不要返回 true 或 false）
	then return end
	local x = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
	self:sort(self.enemies,"hp")
	--冰月弓有破甲效果，可以正常对有防具的角色使用杀。（黑杀依旧打仁王盾）
	--不考虑人亡禁---人王禁是目标修正的事，这里是使用修正
	for _,ep in sgs.list(self.enemies)do
		if self.player:canSlash(ep,card)
		then
	    	card:setFlags("Qinggang") --添加青釭标志，后续决策时此牌视为无视防具
			use.card = card
	    	if use.to
			and use.to:length()<=x
			and not use.to:contains(ep)
			then use.to:append(ep) end
		end
	end
	if card:objectName()=="slash"
	then --普通【杀】转化火【杀】
		self.to_fire_slash = false
    	local fs = sgs.Sanguosha:cloneCard("fire_slash")
		if card:isVirtualCard()
		then fs:addSubcards(card:getSubcards())
		else fs:addSubcard(card) end
		fs:setSkillName(self.player:getWeapon():objectName())
        local dummy = self:aiUseCard(fs)
		if dummy.card
		and dummy.to:length()>0
		and fs:subcardsLength()>0
    	and fs:isAvailable(self.player)
		then
	    	card = fs --将检测的卡改成火【杀】，因为后续还会对这张卡进行检测，不改则还会按普【杀】进行决策
			use.card = fs
	    	use.to = dummy.to
			self.to_fire_slash = true --用于决策是否发动转化
	    	card:setFlags("Qinggang")
			return true
		end
		fs:deleteLater()
	end
end

local jl_yanlinmao={}
jl_yanlinmao.name="jl_yanlinmao"
table.insert(sgs.ai_skills,jl_yanlinmao)
jl_yanlinmao.getTurnUseCard = function(self)
   	return turnUse_spear(self,"jl_yanlinmao")
end

function sgs.ai_cardsview.jl_yanlinmao(self,class_name,player)
	return sgs.ai_cardsview.jl_bingyuegong(self,class_name,player)
end

sgs.ai_keep_value.JlYanlinmao = 3
sgs.ai_use_priority.JlYanlinmao = 4.9
sgs.ai_use_value.JlYanlinmao = 7.6

sgs.ai_use_revises.jl_yanlinmao = function(self,card,use)
	if card:isKindOf("Weapon") then return false end
	return sgs.ai_use_revises.jl_bingyuegong(self,card,use)
end

sgs.ai_keep_value.JlWangba = 5
sgs.ai_use_priority.JlWangba = 8.9

sgs.ai_keep_value.JlQiefudao = -1
sgs.ai_use_priority.JlQiefudao = 0.9
sgs.ai_use_value.JlQiefudao = 4.6

local jl_yushanss={}
jl_yushanss.name="jl_yushanss"
table.insert(sgs.ai_skills,jl_yushanss)
jl_yushanss.getTurnUseCard = function(self)
   	return turnUse_spear(self,"jl_yushanss")
end

function sgs.ai_cardsview.jl_yushanss(self,class_name,player)
	return sgs.ai_cardsview.jl_bingyuegong(self,class_name,player)
end

sgs.ai_keep_value.JlYushanss = 3
sgs.ai_use_priority.JlYushanss = 5.9
sgs.ai_use_value.JlYushanss = 5.6

sgs.ai_use_revises.jl_yushanss = function(self,card,use)
	if card:isKindOf("Weapon")
	then
    	if card:objectName()~="jl_yanlinmao"
    	and card:objectName()~="jl_bingyuegong"
    	then return false end
	end
	if card:objectName()=="slash"
	then
		self.to_fire_slash = false
    	local fs = sgs.Sanguosha:cloneCard("fire_slash")
		fs:setSkillName("jl_yushanss")
		if card:isVirtualCard()
		then fs:addSubcards(card:getSubcards())
		else fs:addSubcard(card) end
        local dummy = self:aiUseCard(fs)
		if dummy.card
		and dummy.to:length()>0
		and fs:subcardsLength()>0
    	and fs:isAvailable(self.player)
		then
	    	card = fs
			use.card = fs
	    	use.to = dummy.to
			self.to_fire_slash = true
			return true
		end
		fs:deleteLater()
	end
end

sgs.ai_use_revises.jl_guanbingcj = function(self,card,use)
	if card:isKindOf("Weapon")
	then 
    	if card:objectName()~="jl_yanlinmao"
    	and card:objectName()~="jl_bingyuegong"
    	then return false end
	elseif not card:isKindOf("Slash")
	then return end
	local x = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
	self:sort(self.enemies,"hp")
	for _,ep in sgs.list(self.enemies)do
		if card:isAvailable(self.player)
--	   	and not self:slashProhibit(card,ep,player)
		and self.player:canSlash(ep,card)
		then
	    	card:setFlags("Qinggang")
	    	use.card = card
	    	if use.to and use.to:length()<=x
			and not use.to:contains(ep)
			then use.to:append(ep) end
		end
	end
end

local jl_deren={}
jl_deren.name="jl_deren"
table.insert(sgs.ai_skills,jl_deren)
jl_deren.getTurnUseCard = function(self)
	for _,h in sgs.list(self.enemies)do
		if h:getMark("jl_deren-PlayClear")<2
		then
            return sgs.Card_Parse("#jl_derenCard:.:")
		end
	end
end

sgs.ai_skill_use_func["#jl_derenCard"] = function(card,use,self)
	use.card = card
	self:sort(self.enemies,"handcard")
	for _,to in sgs.list(self.enemies)do
     	if to:getMark("jl_deren-PlayClear")<2
		and use.to and use.to:length()<1
	   	then use.to:append(to) end
   	end
end

sgs.ai_use_value.jl_derenCard = 7.4
sgs.ai_use_priority.jl_derenCard = 7.4

sgs.ai_skill_discard.jl_deren = function(self)
	local to_cards = {}
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if self.player:getMark("jl_deren-PlayClear")>1
	then return to_cards end
   	for _,hcard in sgs.list(cards)do
   		if #to_cards>1 or #cards<2 then break end
     	table.insert(to_cards,hcard:getEffectiveId())
	end
	return to_cards
end

sgs.ai_skill_discard.jl_guanbingcj = function(self)
	local axe = sgs.ai_skill_cardask["@axe"](self,self.player:getTag("SlashData"),".")
	local to_cards = {}
	if axe and axe~="."
	then
		axe = string.gsub(axe,"$","")
		for _,id in sgs.list(axe:split("+"))do
			table.insert(to_cards,tonumber(id))
		end
	end
	return #to_cards>1 and to_cards
end

sgs.ai_skill_discard.jl_bingyuegong = function(self)
	return sgs.ai_skill_discard.jl_guanbingcj(self)
end

sgs.ai_skill_discard.jl_yanlinmao = function(self)
	return sgs.ai_skill_discard.jl_guanbingcj(self)
end

sgs.ai_skill_discard.jl_jiang = function(self)
	local to_cards,use = {},self.player:getTag("jl_jiang"):toCardUse()
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
   	for _,h in sgs.list(cards)do
   		if h:getSuit()==use.card:getSuit()
		and #to_cards<1
		then
         	table.insert(to_cards,h:getEffectiveId())
		end
	end
	for _,to in sgs.list(use.to)do
		if to:isAlive() and self:isEnemy(to)
		then return to_cards end
	end
	if use.from:isAlive() and self:isEnemy(use.from)
	then return to_cards end
	return {}
end

sgs.ai_skill_discard.jl_jianzheng = function(self)
	local to_cards,use = {},self.player:getTag("jl_jianzheng"):toCardUse()
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if #cards<2 then return {} end
   	table.insert(to_cards,cards[1]:getEffectiveId())
	if use.from and self:isEnemy(use.from)
	and ((use.card:isKindOf("Slash") and self:getCardsNum("Jink","h")>0)
	or (use.card:isKindOf("Duel") and self:getCardsNum("Slash","h")>0))
	then return to_cards end
end

sgs.ai_skill_discard.jl_mingqi = function(self,max,min,optional)
	local to_cards = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
   	for _,hcard in sgs.list(cards)do
   		if #to_cards>=min
		then break end
     	table.insert(to_cards,hcard:getEffectiveId())
	end
	local to = self.room:getCurrent()
	if not optional or self:isFriend(to)
	then return to_cards end
	return {}
end

sgs.ai_skill_discard.jl_daishou = function(self,max,min)
	local to_cards = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
   	for _,hcard in sgs.list(cards)do
   		if #to_cards>min
		then break end
		if self:isWeak()
		then
         	table.insert(to_cards,hcard:getEffectiveId())
		end
	end
	return to_cards
end

sgs.ai_skill_cardask.jl_jiang0 = function(self,data)
	local cards = self.player:getCards("e")
    cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local use,id = data:toCardUse(),"."
   	for _,h in sgs.list(cards)do
   		if h:getSuit()==use.card:getSuit()
		then id = h:getEffectiveId() break end
	end
	for _,to in sgs.list(use.to)do
		if to:isAlive()
		and self:isEnemy(to)
		then return id end
	end
	if use.from:isAlive()
	and self:isEnemy(use.from)
	then return id end
end

sgs.ai_skill_cardask.jlhuodou2 = function(self,data)
    return true
end

sgs.ai_skill_cardask["@jl_wanxiangqq"] = function(self,data,pattern)
	local id = "."
	if string.find(pattern,"slash")
	and self:getCardId("Slash")
	and self:getCardId("Jink")
	then id = self:getCardId("Slash")
	elseif string.find(pattern,"jink")
	then id = self:getCardId("Jink") end
	return id or "."
end

sgs.ai_skill_discard.jl_longjiang = function(self)
	local to_cards = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if self.player:getJudgingArea():isEmpty()
	then return to_cards end
   	for _,c in sgs.list(cards)do
		if #to_cards>1 then break end
		for _,j in sgs.list(self.player:getCards("j"))do
			if j:getColor()==c:getColor()
			then
	    		table.insert(to_cards,c:getEffectiveId())
				break
			end
		end
	end
	return to_cards
end












local jl_longjiang={}
jl_longjiang.name="jl_longjiang"
table.insert(sgs.ai_skills,jl_longjiang)
jl_longjiang.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	for _,h in sgs.list(cards)do
		if h:getTypeId()~=1
		then continue end
		for _,name in sgs.list(patterns)do
			local slash = sgs.Sanguosha:cloneCard(name)
	    	if slash:getTypeId()~=1
			then continue end
			slash:setSkillName("jl_longjiang")
			slash:addSubcard(h)
			local dummy = self:aiUseCard(slash)
			if dummy.card and dummy.to
			and slash:isKindOf("BasicCard")
			then
				if slash:canRecast()
				and dummy.to:length()<1
				then continue end
				return slash
			end
			slash:deleteLater()
		end
	end
end

sgs.ai_view_as.jl_longjiang = function(card,player,card_place,class_name)
	if card_place==sgs.Player_PlaceSpecial
	or not class_name or class_name==""
	then return end
	if card:isKindOf("BasicCard")
	then
     	local slash = PatternsCard(class_name)
    	return slash:isKindOf("BasicCard") and (slash:objectName()..":jl_longjiang[no_suit:0]="..card:getEffectiveId())
	end
end

local jl_wolong={}
jl_wolong.name="jl_wolong"
table.insert(sgs.ai_skills,jl_wolong)
jl_wolong.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	for _,h in sgs.list(cards)do
		if h:isRed() and not self.player:isJilei(h)
		then
        	return sgs.Card_Parse("fire_attack:huoji[no_suit:0]="..h:getEffectiveId())
		end
	end
end

sgs.ai_view_as.jl_wolong = function(card,player,card_place)
	if card:isBlack()
	and card_place==sgs.Player_PlaceHand
	then
    	return ("nullification:kanpo[no_suit:0]="..card:getEffectiveId())
	end
end

local jl_fengcu={}
jl_fengcu.name="jl_fengcu"
table.insert(sgs.ai_skills,jl_fengcu)
jl_fengcu.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	for _,h in sgs.list(cards)do
		if h:getSuitString()=="club"
		and not self.player:isJilei(h)
		then
            local card = dummyCard("iron_chain")
            card:addSubcard(h)
            card:setSkillName("lianhuan")
         	local dummy = self:aiUseCard(card)
			if dummy.card and dummy.to:length()<1
			and self:getUseValue(h)>self:getUseValue(card)
			then
    			dummy = self:aiUseCard(h)
				if dummy.card and dummy.to
				then continue end
			end
        	return sgs.Card_Parse("iron_chain:lianhuan[no_suit:0]="..h:getEffectiveId())
		end
	end
end

local jl_xuanjian={}
jl_xuanjian.name="jl_xuanjian"
table.insert(sgs.ai_skills,jl_xuanjian)
jl_xuanjian.getTurnUseCard = function(self)
    return sgs.Card_Parse("#jl_jianyanCard:.:")
end

sgs.ai_skill_use_func["#jl_jianyanCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_jianyanCard = 6.4
sgs.ai_use_priority.jl_jianyanCard = 6.4

local jl_jianxi={}
jl_jianxi.name="jl_jianxi"
table.insert(sgs.ai_skills,jl_jianxi)
jl_jianxi.getTurnUseCard = function(self)
	for _,ep in sgs.list(self.enemies)do
        return sgs.Card_Parse("#jl_jianyuCard:.:")
	end
end

sgs.ai_skill_use_func["#jl_jianyuCard"] = function(card,use,self)
	use.card = card
	self:sort(self.enemies,"card")
	for _,to in sgs.list(self.enemies)do
     	if use.to and use.to:length()<1
	   	then use.to:append(to) end
   	end
	self:sort(self.friends,"card")
	for _,to in sgs.list(self.friends)do
     	if use.to and use.to:length()<2
	   	then use.to:append(to) end
   	end
end

sgs.ai_use_value.jl_jianyuCard = -0.4
sgs.ai_use_priority.jl_jianyuCard = -0.4

local jl_yinbing={}
jl_yinbing.name="jl_yinbing"
table.insert(sgs.ai_skills,jl_yinbing)
jl_yinbing.getTurnUseCard = function(self)
   	for _,name in sgs.list(patterns)do
     	local c = dummyCard(name)
      	local dummy = self:aiUseCard(c)
    	if dummy.card and dummy.to
    	and (c:isNDTrick() or c:isKindOf("BasicCard"))
	    then
	       	if c:canRecast()
    		and dummy.to:length()<1
	   		then continue end
        	return sgs.Card_Parse(name..":jl_yinbing[no_suit:0]=.")
    	end
	end
end

sgs.ai_view_as.jl_yinbing = function(card,player,card_place,class_name)
	local c = sgs.patterns[class_name]
	if not c then return end
	return (c..":jl_yinbing[no_suit:0]=.")
end

sgs.ai_skill_invoke.jl_pianke = function(self,data)
	local target = self.room:getCurrent()
	return not self:isFriend(target)
end

local jl_pianke={}
jl_pianke.name="jl_pianke"
table.insert(sgs.ai_skills,jl_pianke)
jl_pianke.getTurnUseCard = function(self)
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
   	if #cards>0
	then
    	local give = {}
       	for _,hcard in sgs.list(cards)do
          	if #give>math.min(#cards/2,self.player:getHp()) then break end
	     	table.insert(give,hcard:getEffectiveId())
     	end
        return sgs.Card_Parse("#jl_piankecard:"..table.concat(give,"+")..":")
	end
end

sgs.ai_skill_use_func["#jl_piankecard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_piankecard = 0
sgs.ai_use_priority.jl_piankecard = 0

local jl_weihe={}
jl_weihe.name="jl_weihe"
table.insert(sgs.ai_skills,jl_weihe)
jl_weihe.getTurnUseCard = function(self)
	if self.player:getHandcardNum()<100 or self.player:getMark("@jl_weihe")<1 then return end
    return sgs.Card_Parse("#jl_weihecard:.:")
end

sgs.ai_skill_use_func["#jl_weihecard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_weihecard = 8.4
sgs.ai_use_priority.jl_weihecard = 8.4

local jl_yedu={}
jl_yedu.name="jl_yedu"
table.insert(sgs.ai_skills,jl_yedu)
jl_yedu.getTurnUseCard = function(self)
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,ep in sgs.list(self.room:getOtherPlayers(player))do
		if cards[1]:getNumber()>7
		then
            return sgs.Card_Parse("#jl_yeducard:"..cards[1]:getEffectiveId()..":")
		end
	end
end

sgs.ai_skill_use_func["#jl_yeducard"] = function(card,use,self)
	use.card = card
	local destlist = sgs.QList2Table(self.room:getOtherPlayers(self.player))
	self:sort(destlist,"card")
	for _,to in sgs.list(destlist)do
     	if use.to
		and to:getMark("jl_yeduto")<1
		and self:isEnemy(to)
      	and use.to:length()<1
	   	then use.to:append(to) end
   	end
	for _,to in sgs.list(destlist)do
     	if use.to and use.to:length()<1
		and not self:isFriend(to)
	   	then use.to:append(to) end
   	end
	for _,to in sgs.list(destlist)do
     	if use.to and use.to:length()<1
	   	then use.to:append(to) end
   	end
end

sgs.ai_use_value.jl_yeducard = 4.4
sgs.ai_use_priority.jl_yeducard = 4.4

local jl_yedus={}
jl_yedus.name="jl_yedus"
table.insert(sgs.ai_skills,jl_yedus)
jl_yedus.getTurnUseCard = function(self)
	for _,ep in sgs.list(self.enemies)do
		if ep:getHp()<3
		then
            return sgs.Card_Parse("#jl_yeduscard:.:")
		end
	end
end

sgs.ai_skill_use_func["#jl_yeduscard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_yeduscard = 2.4
sgs.ai_use_priority.jl_yeduscard = 2.4

local jl_limu={}
jl_limu.name="jl_limu"
table.insert(sgs.ai_skills,jl_limu)
jl_limu.getTurnUseCard = function(self)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if self.player:containsTrick("__jl_mu")
	or #cards<3 then return end
   	return sgs.Card_Parse("__jl_mu:jl_limu[no_suit:0]="..cards[1]:getEffectiveId())
end

local jl_zhijun={}
jl_zhijun.name="jl_zhijun"
table.insert(sgs.ai_skills,jl_zhijun)
jl_zhijun.getTurnUseCard = function(self)
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	for _,c in sgs.list(cards)do
    	if c:getSuit()==0
		or c:getSuit()==1
		then
	    	local slash = sgs.Sanguosha:cloneCard("__jl_sha")
			slash:addSubcard(c)
			slash:setSkillName("jl_zhijun")
        	if slash:isAvailable(self.player)
			then return slash end
			slash:deleteLater()
		end
	end
end

sgs.ai_view_as.jl_zhijun = function(card,player,card_place,class_name)
	if card_place==sgs.Player_PlaceSpecial
	then return end
	if (class_name=="Slash" or class_name=="Jink")
	and (card:getSuit()==0 or card:getSuit()==1)
	and sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
	then
    	return ("__jl_sha:jl_zhijun[no_suit:0]="..card:getEffectiveId())
	end
end

local jl_fushi={}
jl_fushi.name="jl_fushi"
table.insert(sgs.ai_skills,jl_fushi)
jl_fushi.getTurnUseCard = function(self)
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	local ts,give = sgs.IntList(),{}
	for _,c in sgs.list(cards)do
    	if ts:contains(c:getSuit())
		then continue end
		ts:append(c:getSuit())
	   	table.insert(give,c:getEffectiveId())
		if self:isWeak() and #give>1
		then self.jl_fushi_c = "up_hp" break
		else self.jl_fushi_c = "draw" end
	end
	if #give>1
	then
        return sgs.Card_Parse("#jl_fushiCard:"..table.concat(give,"+")..":")
	end
end

sgs.ai_skill_use_func["#jl_fushiCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.jl_fushiCard = 4.4
sgs.ai_use_priority.jl_fushiCard = 5.4

sgs.ai_skill_choice.jl_fushi = function(self,choices)
	local items = choices:split("+")
	return self.jl_fushi_c or items[1]
end

--sgs.ai_use_value.Duel = 3.7 使用价值
--sgs.ai_use_priority.Duel = 2.9 使用优先
--sgs.ai_keep_value.Duel = 3.42 保存价值
function SmartAI:useCardJlSha(card,use)
	self:sort(self.enemies,"hp")
	local users = dummyCard()
	users:addSubcards(card:getSubcards())
	local dummy = self:aiUseCard(users)
	if dummy.card and dummy.to:length()>0
	then
       	use.card = card
    	sgs.ai_use_priority.JlSha = sgs.ai_use_priority.Slash
		if use.to then use.to = dummy.to end
	end
end
sgs.ai_use_priority.JlSha = 3.4
sgs.ai_keep_value.JlSha = 4
sgs.ai_use_value.JlSha = 5.7

sgs.ai_card_intention.JlSha = 22

function SmartAI:useCardJlSstj(card,use)
	local users = dummyCard("analeptic")
	users:addSubcards(card:getSubcards())
	if users:isAvailable(self.player)
	and self:aiUseCard(users).card
	then
		use.card = card
		sgs.ai_use_priority.Jlsstj = sgs.ai_use_priority.Analeptic
		self.jl_sstj_choice = "analeptic"
		return
	end
	users = dummyCard()
	users:addSubcards(card:getSubcards())
	if users:isAvailable(self.player)
	then
		users = self:aiUseCard(users)
		if users.card and users.to
		then
			use.card = card
			sgs.ai_use_priority.Jlsstj = sgs.ai_use_priority.Slash
			if use.to then use.to = users.to end
			return
		end
	end
	users = dummyCard("peach")
	users:addSubcards(card:getSubcards())
	if users:isAvailable(self.player)
	and self:aiUseCard(users).card
	then
		use.card = card
		sgs.ai_use_priority.Jlsstj = sgs.ai_use_priority.Peach
		self.jl_sstj_choice = "peach"
		return
	end
end
sgs.ai_use_priority.JlSstj = 3.4
sgs.ai_keep_value.JlSstj = 4
sgs.ai_use_value.JlSstj = 5.7

sgs.ai_skill_choice.jl_sstj = function(self,choices)
	return self.jl_sstj_choice 
end

sgs.ai_judgestring.jl_lebucq = "heart"

function SmartAI:useCardJlLebucq(card,use)
	local x = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)--卡牌可额外选择的人数
	self:sort(self.enemies,"hp")--self.enemies（敌人）按hp由小到大排列
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if not ep:containsTrick("jl_lebucq")--ep没有【jl_lebucq】
	   	and not self.player:isProhibited(ep,card)--不是禁止对ep使用
		then
			use.card = card --载入使用卡
	    	if use.to --有目标
			and use.to:length()<=x --目标数小于等于x
			then use.to:append(ep) end --添加ep为目标
		end
	end
end
sgs.ai_use_priority.JlLebucq = 4.4 --使用优先度
sgs.ai_keep_value.JlLebucq = 2 --保留价值
sgs.ai_use_value.JlLebucq = 5.7 --使用价值

sgs.ai_card_intention.JlLebucq = 33

sgs.ai_useto_revises.jl_lebucq = function(self,card,use,to)--卡牌对场上某张牌的使用修正
	-- 在 to 装备区或判定区有【jl_lebucq】时
	local x = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
  	if self.player:isProhibited(to,card) -- player 不能对 to 使用 card
	or not self:isFriend(to) -- to 不是友军
	or to:getHandcardNum()<2 -- to 手牌数过少
	then return end
	if card:isKindOf("Dismantlement") -- 是使用过河拆桥
	or card:isKindOf("Snatch") -- 是使用顺手牵羊
	or card:isKindOf("Zhujinqiyuan") --- 是使用逐近弃远
	then
		if to:containsTrick("jl_lebucq") -- to 判定区有【jl_lebucq】
		and card:targetFilter(sgs.PlayerList(),to,self.player) -- player 可以对 to 使用 card （考虑距离限制）
		then
			use.card = card
			if use.to and use.to:length()<=x
			then use.to:append(to) end
		end --添加 to 为目标
	end
	--最终效果就是 to 为友军且手牌数不少被贴上了【jl_lebucq】时，对他使用过河顺手逐弃
end

sgs.ai_nullification.JlLebucq = function(self,trick,from,to,positive)--新增无懈可击对卡牌使用接口
    if positive--判断使用无懈是抵消JlLebucq效果
	then
		if self:isFriend(to) --乐不拆桥目标是友方时使用
		and to:getCardCount()>2
		then
			return true
		end
	else--否则无懈是防止JlLebucq效果被抵消
		if self:isEnemy(to) --乐不拆桥目标是敌方时使用
		and to:getCardCount()>3
		then
			return true
		end
	end
	--返回 true 则直接使用，返回 false 则不使用，返回空（nil）则进行原本的决策（没有原本的决策就默认不使用）
end

function SmartAI:useCardJlShunshoubl(card,use)
	self:sort(self.enemies,"hp")
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if not ep:containsTrick("jl_shunshoubl")
	   	and CanToCard(card,self.player,ep,use.to)
		then
	    	use.card = card
	    	if use.to
			then use.to:append(ep) end
		end
	end
end
sgs.ai_use_priority.JlShunshoubl = 3.4
sgs.ai_keep_value.JlShunshoubl = 4
sgs.ai_use_value.JlShunshoubl = 5.7

sgs.ai_card_intention.JlShunshoubl = 33

sgs.ai_useto_revises.jl_shunshoubl = function(self,card,use,to)
	local x = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
  	if self.player:isProhibited(to,card)
	or not self:isFriend(to)
	or to:getHandcardNum()>2
	then return end
	if card:isKindOf("Dismantlement")
	or card:isKindOf("Snatch")
	or card:isKindOf("Zhujinqiyuan")
	then
		if to:containsTrick("jl_shunshoubl")
		and card:targetFilter(sgs.PlayerList(),to,self.player)
		then
			use.card = card
			if use.to
			and use.to:length()<=x
			then use.to:append(to) end
		end --添加 to 为目标
	end
end

sgs.ai_nullification.JlShunshoubl = function(self,trick,from,to,positive)
    return self:isFriend(to)
	and not to:isNude()
	and positive
end

sgs.ai_judgestring.jl_shunshoubl = "club"

sgs.ai_judgestring.jl_diansha = "heart+diamond+no_suit+club"

sgs.ai_use_value.JlWangba = 7.6

sgs.ai_useto_revises.jl_diansha = function(self,card,use,to)
  	if self.player:isProhibited(to,card)
	or not self:isFriend(to)
	or to:getHp()>1
	then return end
	if card:isKindOf("Dismantlement")
	or card:isKindOf("Snatch")
	or card:isKindOf("Zhujinqiyuan")
	then
		if to:containsTrick("jl_diansha")
		and card:targetFilter(sgs.PlayerList(),to,self.player)
		then
			use.card = card
			if use.to
			then
    			use.to:append(to)
			end
		end --添加 to 为目标
	end
end

function SmartAI:useCardJlLianhuansr(card,use)
	self:sort(self.enemies,"hp")
   	use.card = card
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if ep:getWeapon()
	   	and not self.player:isProhibited(ep,card)
		then
        	for _,ep1 in sgs.list(self.enemies)do
	    		if ep:inMyAttackRange(ep1)
	 	    	then
	        		if use.to
					then
	            		use.to:append(ep)
	            		use.to:append(ep1)
	            		return false
					end
		    	end
        	end
		end
	end
	self:sort(self.friends_noself,"handcard",true)
	for _,ep in sgs.list(self.friends_noself)do
		if isCurrent(use.current_targets,ep) then continue end
		if ep:getWeapon()
	   	and not self.player:isProhibited(ep,card)
		then
        	for _,ep1 in sgs.list(self.enemies)do
	    		if ep:inMyAttackRange(ep1)
	 	    	then
	        		if use.to
					then
	            		use.to:append(ep)
	            		use.to:append(ep1)
	            		return false
					end
		    	end
        	end
		end
	end
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if ep:getWeapon()
	   	and not self.player:isProhibited(ep,card)
		then
        	for _,fp in sgs.list(self.friends)do
	    		if ep:inMyAttackRange(fp)
				and ep:getHandcardNum()<=fp:getHandcardNum()
	 	    	then
	        		if use.to
					then
	            		use.to:append(ep)
	            		use.to:append(fp)
	            		return false
					end
		    	end
        	end
		end
	end
end
sgs.ai_use_priority.JlLianhuansr = 5.4
sgs.ai_keep_value.JlLianhuansr = 2
sgs.ai_use_value.JlLianhuansr = 5
sgs.ai_nullification.JlLianhuansr = function(self,trick,from,to,positive)
    return self:isFriend(to)
	and self:isEnemy(from)
	and to:getWeapon()
	and positive
end

function SmartAI:useCardJlHuodou(card,use)
	self:sort(self.enemies,"hp")
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if (ep:getHandcardNum()<self.player:getHandcardNum() or ep:getHandcardNum()<2)
	   	and CanToCard(card,self.player,ep,use.to)
		then
	    	use.card = card
	    	if use.to then use.to:append(ep) end
		end
	end
end
sgs.ai_use_priority.JlHuodou = 4.4
sgs.ai_keep_value.JlHuodou = 4
sgs.ai_use_value.JlHuodou = 3.7
sgs.ai_nullification.JlHuodou = function(self,trick,from,to,positive)
    return self:isFriend(to)
	and to:getHandcardNum()<4
	and positive
end

sgs.ai_card_intention.JlHuodou = 66

sgs.card_damage_nature.JlHuodou = "F"

function SmartAI:useCardJlTaoyuanfd(card,use)
	self:sort(self.friends,"hp")
	for _,ep in sgs.list(self.friends)do
		if self:isWeak(ep)
	   	and CanToCard(card,self.player,ep,use.to)
		then use.card = card end
	end
end
sgs.ai_use_priority.JlTaoyuanfd = 1.4
sgs.ai_keep_value.JlTaoyuanfd = 4
sgs.ai_use_value.JlTaoyuanfd = 3.7
sgs.ai_nullification.JlTaoyuanfd = function(self,trick,from,to,positive)
    local null_num = self:getCardsNum("Nullification")
	if null_num>1
	then
        return self:isEnemy(to)
    	and to:isWounded()
    	and positive
	else
        return self:isEnemy(to)
    	and self:isWeak(to)
     	and to:isWounded()
    	and positive
	end
end

sgs.ai_card_intention.JlTaoyuanfd = function(self,card,from,tos)
	for _,to in sgs.list(tos)do
		if to:isWounded() and not self:isEnemy(from) and self:isFriend(to)
		then sgs.updateIntention(from,to,-10) end
	end
end

function SmartAI:useCardJlMu(card,use)
    local s = self:getCardsNum("Slash")
	self:sort(self.enemies,"hp")
	for _,ep in sgs.list(self.enemies)do
     	if ep:getHp()<s
		then
           	if self.player:hasSkill("jl_limu")
			and not self.player:containsTrick("__jl_mu")
           	and not self.player:isProhibited(self.player,card)
        	then use.card = card end
		end
	end
	sgs.ai_judgestring["__jl_mu"] = card:getColorString()
end
sgs.ai_use_priority.JlMu = 5.4
sgs.ai_keep_value.JlMu = 0
sgs.ai_use_value.JlMu = 0.7
sgs.ai_useto_revises["__jl_mu"] = function(self,card,use,to)
	if card:isKindOf("Dismantlement")
	or card:isKindOf("Snatch")
	or card:isKindOf("Zhujinqiyuan")
	then
		if self:isFriend(to)
		and to:containsTrick("__jl_mu")
	   	and CanToCard(card,self.player,to,use.to)
		then
			use.card = card
			if use.to then use.to:append(to) end
		end --添加 to 为目标
	end
end

sgs.ai_nullification.JlMu = function(self,trick,from,to,positive)
    return self:isFriend(to) and positive
end

sgs.ai_card_intention.JlMu = 77

function SmartAI:useCardJlQiefudao(card,use)
    if self.player:hasSkills("guixin|jieming|yiji|nosyiji|chengxiang|noschengxiang")
	then use.card = card end
	return true
end
sgs.ai_use_priority.JlQiefudao = 3.5

function SmartAI:useCardJlSdjls(card,use)
	self:sort(self.enemies,"hp")
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if CanToCard(card,self.player,ep,use.to)
		then
	    	use.card = card
	    	if use.to then use.to:append(ep) end
		end
	end
end
sgs.ai_use_priority.JlSdjls = 2.5
sgs.ai_keep_value.JlSdjls = 4
sgs.ai_use_value.JlSdjls = 3.7

sgs.ai_card_intention.JlSdjls = 99

sgs.card_damage_nature.JlSdjls = "T"

local gdlonghun_skill={}
gdlonghun_skill.name="gdlonghun"
table.insert(sgs.ai_skills,gdlonghun_skill)
gdlonghun_skill.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	if sgs.Slash_IsAvailable(self.player)
	then
    	for _,c in sgs.list(cards)do
	    	local fs = sgs.Sanguosha:cloneCard("fire_slash")
			fs:setSkillName("gdlonghun")
			fs:addSubcard(c)
			if c:getSuit()==3
			and fs:isAvailable(self.player)
	    	then return fs end
			fs:deleteLater()
	    end
	end
end

sgs.ai_view_as.gdlonghun = function(card,player,card_place)
   	if card_place==sgs.Player_PlaceHand
	or card_place==sgs.Player_PlaceEquip
	then
    	if card:getSuit()==2
    	then return ("peach:gdlonghun[no_suit:0]="..card:getEffectiveId())
    	elseif card:getSuit()==0
    	then return ("nullification:gdlonghun[no_suit:0]="..card:getEffectiveId())
    	elseif card:getSuit()==3
    	then return ("fire_slash:gdlonghun[no_suit:0]="..card:getEffectiveId())
    	elseif card:getSuit()==1
    	then return ("jink:gdlonghun[no_suit:0]="..card:getEffectiveId()) end
	end
end

