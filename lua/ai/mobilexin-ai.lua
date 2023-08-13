

local mobilexinyinju={}
mobilexinyinju.name="mobilexinyinju"
table.insert(sgs.ai_skills,mobilexinyinju)
mobilexinyinju.getTurnUseCard = function(self)
	if self:getCardsNum("Jink")<1 and self.player:getMark("mobilexinchijie-Clear")>0
	then return end
	return sgs.Card_Parse("@MobileXinYinjuCard=.")
end

sgs.ai_skill_use_func["MobileXinYinjuCard"] = function(card,use,self)
	for _,ep in sgs.list(self.enemies)do
		if ep:canSlash(self.player,true) then continue end
		use.card = card
		if use.to
		then
			use.to:append(ep)
			return
		end
	end
	for _,ep in sgs.list(self.enemies)do
		use.card = card
		if use.to
		then
			use.to:append(ep)
			return
		end
	end
end

sgs.ai_use_value.MobileXinYinjuCard = 3.4
sgs.ai_use_priority.MobileXinYinjuCard = 2.2

sgs.ai_skill_invoke.mobilexinchijie = function(self,data)
	local use = data:toCardUse()
	if use.card:isDamageCard()
	or self:isEnemy(use.from)
	then return true end
end

local mobilexincunsi={}
mobilexincunsi.name="mobilexincunsi"
table.insert(sgs.ai_skills,mobilexincunsi)
mobilexincunsi.getTurnUseCard = function(self)
	if not self.player:faceUp() then return end
	return sgs.Card_Parse("@MobileXinCunsiCard=.")
end

sgs.ai_skill_use_func["MobileXinCunsiCard"] = function(card,use,self)
	for _,ep in sgs.list(self.enemies)do
		if self:isWeak(ep)
		and ep:getHandcardNum()<2
		then
			for _,fp in sgs.list(self.friends)do
				if fp:canSlash(ep)
				then
					if fp==self.player
					then
						if self:getCardsNum("Slash")>0
						then return end
					end
					use.card = card
					if use.to
					then
						use.to:append(fp)
						return
					end
				end
			end
		end
	end
end

sgs.ai_use_value.MobileXinCunsiCard = 3.4
sgs.ai_use_priority.MobileXinCunsiCard = 2.8

sgs.ai_skill_cardask.mobilexinguixiu = function(self,data,pattern,prompt)
    local parsed = prompt:split(":")
    if not self:isWeak(self.player)
	and not self.player:faceUp()
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

sgs.ai_nullification.mobilexinguixiu = function(self,trick,from,to,positive)
    if to:hasSkill("mobilexinguixiu")
	and self:isFriend(to)
	and to:getHp()>1
	and trick:isDamageCard()
	and self:canLoseHp(from,trick,to)
	and not to:faceUp()
	then return false end
end

sgs.ai_skill_invoke.secondmobilexinxuancun = function(self,data)
	local target = data:toPlayer()
	if target
	then
		return self:isFriend(target)
	end
end

local mobilexinmouli={}
mobilexinmouli.name="mobilexinmouli"
table.insert(sgs.ai_skills,mobilexinmouli)
mobilexinmouli.getTurnUseCard = function(self)
    local cards = self.player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
	if #cards<1 then return end
	return sgs.Card_Parse("@MobileXinMouliCard="..cards[1]:getEffectiveId())
end

sgs.ai_skill_use_func["MobileXinMouliCard"] = function(card,use,self)
	for _,ep in sgs.list(self.friends_noself)do
		if self:isWeak(ep) then continue end
		use.card = card
		if use.to then use.to:append(ep) end
		return
	end
end

sgs.ai_use_value.MobileXinMouliCard = 6.4
sgs.ai_use_priority.MobileXinMouliCard = 2.5

function sgs.ai_cardsview.mobilexinmouli_effect(self,class_name,player)
   	local cards = sgs.QList2Table(player:getCards("he"))
    self:sortByKeepValue(cards)
	if class_name=="Jink"
	then
		for _,card in sgs.list(cards)do
        	if card:isRed()
	    	then
	    		return ("jink:mobilexinmouli_effect[no_suit:0]="..card:getEffectiveId())
			end
		end
	end
	if class_name=="Slash"
	then
        for _,card in sgs.list(cards)do
        	if card:isBlack()
	    	then
	        	return ("slash:mobilexinmouli_effect[no_suit:0]="..card:getEffectiveId())
			end
		end
	end
end

sgs.ai_skill_invoke.secondmobilexinxingqi = function(self,data)
	local bei = self.player:property("second_mobilexin_wangling_bei"):toString():split("+")
	local cards = {}
	for cs,name in sgs.list(bei)do
		cs = PatternsCard(name,true)
		if #cs>1 then table.insert(cards,cs[1]) end
	end
	self:sortByKeepValue(cards,true)
	sgs.ai_skill_choice.secondmobilexinxingqi = cards[1]:objectName()
	return #cards>1
end

addAiSkills("secondmobilexinmouli").getTurnUseCard = function(self)
	local bei = self.player:property("second_mobilexin_wangling_bei"):toString():split("+")
	if #bei<2 then return end
	return sgs.Card_Parse("@SecondMobileXinMouliCard=.")
end

sgs.ai_skill_use_func["SecondMobileXinMouliCard"] = function(card,use,self)
	self:sort(self.friends_noself,"hp")
	for _,ep in sgs.list(self.friends_noself)do
		use.card = card
		if use.to then use.to:append(ep) end
		return
	end
end

sgs.ai_use_value.SecondMobileXinMouliCard = 3.4
sgs.ai_use_priority.SecondMobileXinMouliCard = 6.2

sgs.ai_skill_choice.secondmobilexinmouli = function(self,choices,data)
	local cards = {}
	local bei = choices:split("+")
	for cs,name in sgs.list(bei)do
		cs = PatternsCard(name,true)
		if #cs>1 then table.insert(cards,cs[1]) end
	end
	self:sortByKeepValue(cards,true)
	return #cards>1 and cards[1]:objectName() or bei[1]
end



addAiSkills("mobilexinchuhai").getTurnUseCard = function(self)
	return sgs.Card_Parse("@MobileXinChuhaiCard=.")
end

sgs.ai_skill_use_func["MobileXinChuhaiCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.MobileXinChuhaiCard = 3.4
sgs.ai_use_priority.MobileXinChuhaiCard = 5.2

sgs.ai_skill_playerchosen.mobilexinchuhai = function(self,players)
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
	return destlist[1]
end

addAiSkills("mobilexinlirang").getTurnUseCard = function(self)
	if self.player:getHandcardNum()<self.player:getHp()
	or self.player:getHandcardNum()>2
	or #self.friends_noself<1
	then return end
	return sgs.Card_Parse("@MobileXinLirangCard=.")
end

sgs.ai_skill_use_func["MobileXinLirangCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.MobileXinLirangCard = 3.4
sgs.ai_use_priority.MobileXinLirangCard = 5.2

sgs.ai_skill_askforyiji.mobilexinlirang = function(self,card_ids)
    local to,id = sgs.ai_skill_askforyiji.nosyiji(self,card_ids)
	if to and id then return to,id end
	to = self.friends_noself[1]
	return to,card_ids[1]
end

sgs.ai_skill_cardask["@mobilexinmingfa-show"] = function(self,data,pattern)
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
    self:sortByKeepValue(cards) -- 按保留值排序
   	for _,c in sgs.list(cards)do
    	if c:getNumber()>8
		then return c:getEffectiveId() end
	end
    return "."
end

sgs.ai_skill_playerchosen.mobilexinmingfa = function(self,players)
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
	return destlist[1]
end

addAiSkills("mobilexinrongbei").getTurnUseCard = function(self)
	if math.random()>0.8 then return end
	return sgs.Card_Parse("@MobileXinRongbeiCard=.")
end

sgs.ai_skill_use_func["MobileXinRongbeiCard"] = function(card,use,self)
	self:sort(self.friends,"equip")
	for _,ep in sgs.list(self.friends)do
		if ep:getEquips():length()>3 then continue end
		use.card = card
		if use.to then use.to:append(ep) end
		return
	end
end

sgs.ai_use_value.MobileXinRongbeiCard = 6.4
sgs.ai_use_priority.MobileXinRongbeiCard = 7.2


