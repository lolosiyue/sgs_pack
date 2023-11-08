
function SmartAI:useCardYjPoison(card,use)
	self:sort(self.enemies,"hp")
	for _,ep in sgs.list(self.enemies)do
		if CanToCard(card,self.player,ep,use.to)
		then
	    	use.card = card
	    	if use.to then use.to:append(ep) end
		end
	end
end

sgs.ai_use_priority.YjPoison = 4.4
sgs.ai_keep_value.YjPoison = 4
sgs.ai_use_value.YjPoison = 1.7

--直接给【毒】设定为负面卡牌（无论任何情况）
--ai会优先将负面卡牌给对手，五谷选择牌时也不会优先选择这些牌
sgs.ai_poison_card.yj_poison = true

sgs.ai_skill_discard.yj_stabs_slash = function(self,max,min)
	local to_cards = {}
	local cards = self.player:getCards("h")
	cards = self:sortByKeepValue(cards,nil,"j")
   	for _,h in sgs.list(cards)do
   		if #to_cards>=min then break end
		table.insert(to_cards,h:getEffectiveId())
	end
	return to_cards
end

function SmartAI:useCardYjChenhuodajie(card,use)
	self:sort(self.enemies,"hp")
	local extraTarget = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
	if use.extra_target then extraTarget = extraTarget+use.extra_target end
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
		and self:needToLoseHp(ep,self.player,card,true)
		then
	    	use.card = card
			use.to:append(ep)
	    	if use.to:length()>extraTarget
			then return end
		end
	end
end
sgs.ai_use_priority.YjChenhuodajie = 5.4
sgs.ai_keep_value.YjChenhuodajie = 2
sgs.ai_use_value.YjChenhuodajie = 3.7
sgs.ai_card_intention.YjChenhuodajie = 33

sgs.ai_nullification.YjChenhuodajie = function(self,trick,from,to,positive)
    return self:isFriend(to) and not self:isFriend(from)
	and self:isWeak() and positive
end

sgs.ai_skill_cardask["yj_chenhuodajie0"] = function(self,data,pattern,prompt)
	local c = sgs.Sanguosha:getCard(pattern)
	if c
	then
		local effect = data:toCardEffect()
		local n = self:ajustDamage(effect.from,effect.to,1,effect.card)
		if n<2 and (self:isWeak() and c:isKindOf("Analeptic") or self:getKeepValue(c)>5.3)
		or n==0 then return "." end
		return c:getEffectiveId()
	end
end

function SmartAI:useCardYjGuaguliaodu(card,use)
	self:sort(self.friends,"hp")
	local extraTarget = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
	if use.extra_target then extraTarget = extraTarget+use.extra_target end
	for _,ep in sgs.list(self.friends)do
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
sgs.ai_use_priority.YjGuaguliaodu = 2.4
sgs.ai_keep_value.YjGuaguliaodu = 2.2
sgs.ai_use_value.YjGuaguliaodu = 4.7
sgs.ai_card_intention.YjGuaguliaodu = -33

sgs.ai_nullification.YjGuaguliaodu = function(self,trick,from,to,positive)
	if positive
	then
		return self:isEnemy(to)
		and (self:isWeak(to) or self:getCardsNum("Nullification")>1)
	else
		return self:isFriend(to)
		and (self:isWeak(to) or self:getCardsNum("Nullification")>1)
	end 
end

sgs.ai_skill_cardask["yj_guaguliaodu0"] = function(self,data,pattern,prompt)
	return true
end

sgs.ai_skill_cardask["yj_yitianjian0"] = function(self,data,pattern,prompt)
	return true
end

sgs.ai_use_priority.YjYitianjian = 3

function SmartAI:useCardYjShushangkaihua(card,use)
	local n = #self:poisonCards("e")
	for _,c in sgs.list(self.player:getHandcards())do
		if table.contains(self.toUse,c)
		or self:getKeepValue(c)>6
		then else n = n+1 end
		if n>1 then use.card = card break end
	end
end
sgs.ai_use_priority.YjShushangkaihua = 3.4
sgs.ai_keep_value.YjShushangkaihua = 2.2
sgs.ai_use_value.YjShushangkaihua = 4.7
sgs.ai_card_intention.YjShushangkaihua = -22

sgs.ai_skill_discard.yj_shushangkaihua = function(self)
	local cards = self.player:getCards("h")
	cards = self:sortByCardNeed(cards,nil,"j")
	local discard = {}
	for i,c in sgs.list(cards)do
		if #discard<2 and self.player:hasEquip(c) and self:evaluateArmor(c)<-5
		then table.insert(discard,c:getEffectiveId()) continue end
		if #cards/2>i and #discard<1 and c:isKindOf("EquipCard")
		then table.insert(discard,c:getEffectiveId()) end
	end
	cards = self.player:getCards("he")
	cards = self:sortByKeepValue(cards,nil,"j")
	for i,c in sgs.list(cards)do
		if table.contains(discard,c:getEffectiveId()) then continue end
		if #discard<2 then table.insert(discard,c:getEffectiveId()) end
	end
	return discard
end

function SmartAI:useCardYjTuixinzhifu(card,use)
	self:sort(self.friends_noself,"hp")
	local extraTarget = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
	if use.extra_target then extraTarget = extraTarget+use.extra_target end
	for _,ep in sgs.list(self.friends_noself)do
		if isCurrent(use.current_targets,ep) then continue end
		if use.to and CanToCard(card,self.player,ep)
		and self:doDisCard(ep,"ej")
		then
	    	use.card = card
			use.to:append(ep)
	    	if use.to:length()>extraTarget
			then return end
		end
	end
	self:sort(self.enemies,"hp")
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if use.to and CanToCard(card,self.player,ep)
		and self:doDisCard(ep,"ej")
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
		and self:doDisCard(ep,"hej")
		then
	    	use.card = card
			use.to:append(ep)
	    	if use.to:length()>extraTarget
			then return end
		end
	end
	local tos = self.room:getAlivePlayers()
	tos = self:sort(tos,"card",true)
	for _,ep in sgs.list(tos)do
		if isCurrent(use.current_targets,ep) then continue end
		if use.to and CanToCard(card,self.player,ep)
		and ep:getCardCount()>1
		then
	    	use.card = card
			use.to:append(ep)
	    	if use.to:length()>extraTarget
			then return end
		end
	end
end
sgs.ai_use_priority.YjTuixinzhifu = 5.4
sgs.ai_keep_value.YjTuixinzhifu = 2.2
sgs.ai_use_value.YjTuixinzhifu = 4.7

sgs.ai_skill_cardchosen.yj_tuixinzhifu = function(self,who)
	for i,c in sgs.list(who:getCards("ej"))do
		i = c:getEffectiveId()
		if self:doDisCard(who,i,true)
		then return i end
	end
	for i=1,who:getHandcardNum()do
		i = who:getRandomHandCardId()
		if self.disabled_ids:contains(i)
		then continue end
		return i
	end
	for i=1,99 do
		i = self:getCardRandomly(who,"hej")
		if self.disabled_ids:contains(i)
		then continue end
		if self:doDisCard(who,i,true)
		then return i end
	end
	return -1
end

sgs.ai_skill_discard.yj_tuixinzhifu = function(self,x,n)
	local to_cards = {}
	local target = self.player:getTag("yj_tuixinzhifu"):toPlayer()
	local cards = self.player:getHandcards()
	cards = self:sortByKeepValue(cards)
   	for _,h in sgs.list(cards)do
   		if #to_cards>=n then return to_cards end
		if table.contains(self:poisonCards(),h) and not self:isFriend(target)
		then table.insert(to_cards,h:getEffectiveId()) end
	end
   	for i,h in sgs.list(cards)do
   		if #to_cards>=n then return to_cards end
		if table.contains(to_cards,h:getEffectiveId()) then continue end
		if i>=#cards/2 and self:isFriend(target)
		then table.insert(to_cards,h:getEffectiveId()) end
	end
   	for _,h in sgs.list(cards)do
   		if #to_cards>=n then return to_cards end
		if table.contains(to_cards,h:getEffectiveId()) then continue end
       	table.insert(to_cards,h:getEffectiveId())
	end
end

sgs.ai_nullification.YjTuixinzhifu = function(self,trick,from,to,positive)
    local n = self:getCardsNum("Nullification")
	if n>1
	and (to:hasEquip() or to:getJudgingArea():length()>0)
	then
		if positive 
		then
			return self:isFriend(to)
			and self:isEnemy(from)
		else
			return self:isEnemy(to)
			and self:isEnemy(from)
		end
	elseif to:getCardCount(true,true)>0
	and (to:getArmor() or to:getDefensiveHorse() or to:getHandcardNum()<2 or to:getJudgingArea():length()>0)
	then
		if positive 
		then
			return self:isFriend(to)
			and self:isEnemy(from)
		else
			return self:isEnemy(to)
			and self:isEnemy(from)
		end
	end
end

function SmartAI:useCardYjNvzhuang(card,use)
	return true
end

function SmartAI:useCardYjYinfengyi(card,use)
	return true
end

function SmartAI:useCardYjZheji(card,use)
	return true
end

function SmartAI:useCardYjQixingbaodao(card,use)
	if self.player:getEquips():isEmpty() then use.card = nil end
	if self.player:getEquips():length()<=self.player:getJudgingArea():length()
	then use.card = card end
	return true
end

function SmartAI:useCardOffensiveHorse(card,use)
	if card:objectName()=="yj_numa"
	then return true end
end

--给在装备区特定的牌设定为负面卡牌；需要设定的值小于-5
--ai会优先将负面装备卸掉，ai队友也会优先帮你拆顺掉这些装备
--同时对手也不会优先去卸掉你的这些装备
sgs.ai_armor_value.yj_yinfengyi = -9
sgs.ai_armor_value.yj_zheji = -7.6
sgs.ai_armor_value.yj_numa = -7
sgs.ai_armor_value.yj_nvzhuang = -8

addAiSkills("yj_xinge").getTurnUseCard = function(self)
	local cards = self.player:getHandcards()
	self.yjxg_to = nil
	self:sort(self.enemies,"hp")
	self:sort(self.friends_noself,"hp")
  	for _,c in sgs.list(self:sortByKeepValue(cards))do
		if table.contains(self:poisonCards(),c)
		then self.yjxg_to = self.enemies[1]
		elseif c:isKindOf("Slash")
		then
			if table.contains(self.toUse,c)
			or self.player:getHandcardNum()<2 then continue end
			self.yjxg_to = self.friends_noself[1]
		elseif c:isKindOf("Jink")
		then
			if self:getCardsNum("Jink","h")<1 then continue end
			self.yjxg_to = self.friends_noself[1]
		elseif c:isKindOf("Peach")
		then
			if self:isWeak() and table.contains(self.toUse,c) then continue end
			self.yjxg_to = self.friends_noself[1]
		elseif self.player:getHandcardNum()>self.player:getMaxCards()
		then self.yjxg_to = self.friends_noself[1] end
		if not self.yjxg_to then continue end
		return sgs.Card_Parse("#yj_xingecard:"..c:getEffectiveId()..":")
	end
	local c,p = self:getCardNeedPlayer()
	if c and p
	then
		self.yjxg_to = p
		return sgs.Card_Parse("#yj_xingecard:"..c:getEffectiveId()..":")		
	end
end

sgs.ai_skill_use_func["#yj_xingecard"] = function(card,use,self)
	if self.yjxg_to:isAlive()
	then
		use.card = card
		if use.to then use.to:append(self.yjxg_to) end
	end
end

sgs.ai_use_value.yj_xingecard = 5.4
sgs.ai_use_priority.yj_xingecard = 3.8

sgs.ai_armor_value.zl_yinfengjia = -8
sgs.ai_armor_value.zl_wufengjian = -6

sgs.ai_poison_card.zl_wufengjian = function(self,c,player)
	if player:hasEquip(c) then return getCardsNum("Slash",player,self.player)>0 end
end

sgs.ai_poison_card.zl_jinhe = function(self,c,player)
	if player:hasEquip(c) then return player:getHandcardNum()<1 end
end

sgs.ai_poison_card.zl_nvzhuang = function(self,c,player)
	if not player:hasEquip(c) then return player:isMale() end
end

sgs.ai_poison_card.zl_numa = function(self,c,player)
	return not player:hasEquip(c) and player:hasEquip()
end

function SmartAI:useCardZlCaochuanjiejian(card,use)
	local ce = self.player:getTag("ZlCaochuanjiejian"):toCardEffect()
	if ce and ce.card and not self:canDamageHp(ce.from,ce.card,ce.to)
	then use.card = card end
end
sgs.ai_keep_value.ZlCaochuanjiejian = 9.6
sgs.ai_use_value.ZlCaochuanjiejian = 6.9
sgs.ai_use_priority.ZlCaochuanjiejian = 6.6

sgs.ai_nullification.ZlCaochuanjiejian = function(self,trick,from,to,positive,null_num)
	if positive
	then
		return self:isEnemy(from)
		and (self:isWeak(from) or null_num>1)
	else
		return self:isFriend(from)
		and self:isWeak(from)
	end 
end

function SmartAI:useCardZlJiejiaguitian(card,use)
	self:sort(self.friends,"hp")
	local extraTarget = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
	if use.extra_target then extraTarget = extraTarget+use.extra_target end
	for _,ep in sgs.list(self.friends)do
		if isCurrent(use.current_targets,ep) then continue end
		if use.to and CanToCard(card,self.player,ep)
		and #self:poisonCards("e",ep)>=ep:getEquips():length()/2
		then
	    	use.card = card
			use.to:append(ep)
	    	if use.to:length()>extraTarget
			then return end
		end
	end
	function equipValue(p)
		local x = p:getEquips():length()
		local pc = self:poisonCards("e",p)
		for _,e in sgs.list(p:getEquips())do
			if table.contains(pc,e)
			then x = x-2 continue end
			if e:isKindOf("Weapon")
			or e:isKindOf("OffensiveHorse") then x = x+2
			elseif e:isKindOf("Armor") then x = x+4
			elseif e:isKindOf("DefensiveHorse") then x = x+3
			else x = x+1+p:getPile("wooden_ox"):length() end
		end
		return x
	end
	local function func(a,b)
		return equipValue(a)>equipValue(b)
	end
	table.sort(self.enemies,func)
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if use.to and CanToCard(card,self.player,ep)
		and #self:poisonCards("e",ep)<=ep:getEquips():length()/2
		then
	    	use.card = card
			use.to:append(ep)
	    	if use.to:length()>extraTarget
			then return end
		end
	end
	local tos = self.room:getAlivePlayers()
	tos = self:sort(tos,"card",true)
	table.sort(tos,func)
	for _,ep in sgs.list(tos)do
		if isCurrent(use.current_targets,ep) then continue end
		if use.to and CanToCard(card,self.player,ep)
		and #self:poisonCards("e",ep)<ep:getEquips():length()/2
		and not self:isFriend(ep)
		then
	    	use.card = card
			use.to:append(ep)
	    	if use.to:length()>extraTarget
			then return end
		end
	end
end
sgs.ai_use_priority.ZlJiejiaguitian = 4.4
sgs.ai_keep_value.ZlJiejiaguitian = 1.2
sgs.ai_use_value.ZlJiejiaguitian = 2.7
sgs.ai_card_intention.ZlJiejiaguitian = function(self,card,from,tos)
    for n,to in sgs.list(tos)do
		local pc,e = self:poisonCards("e",to),to:getEquips():length()/2
		if #pc>e then n = 33 elseif #pc<=e then n = -22 end
		sgs.updateIntention(from,to,n)
    end
end

function SmartAI:useCardZlZhulutianxia(card,use)
	self:useCardAmazingGrace(card,use)
end
sgs.ai_use_priority.ZlZhulutianxia = 2.4
sgs.ai_keep_value.ZlZhulutianxia = 1.2
sgs.ai_use_value.ZlZhulutianxia = 4.7

sgs.ai_nullification.ZlZhulutianxia = function(self,trick,from,to,positive,null_num)
	if positive
	then
        local ids = self.room:getTag("ZlZhulutianxia"):toIntList()
		if self:isEnemy(to)
		then
            local NP = to:getNextAlive()
            if not self:isEnemy(NP)
			then
                for _,c in sgs.list(ids)do
                    c = sgs.Sanguosha:getCard(c)
                    if isCard("Crossbow",c,NP)
					and to:hasEquipArea(0)
					then
                        for _,enemy in sgs.list(self.enemies)do
                            if getCardsNum("Slash",enemy,self.player)>1
							then
                                local slash = dummyCard()
                                for _,friend in sgs.list(self.friends)do
                                    if enemy:distanceTo(friend)==1
									and self:slashIsEffective(slash,friend,enemy)
									then return true end
                                end
                            end
                        end
					end
                end
            end
		elseif self:isFriend(to)
		then
			local c = sgs.ais[to:objectName()]:askForAG(sgs.QList2Table(ids),false,"zl_zhulutianxia")
			c = sgs.Sanguosha:getCard(c)
			local pc = sgs.ais[to:objectName()]:poisonCards(ids)
			if table.contains(pc,c) or sgs.ais[to:objectName()]:evaluateArmor(c)<-5
			then return self:isWeak(to) or null_num>1 end
        end
		
	else
		
	end 
end

sgs.ai_skill_askforag.zl_zhulutianxia = function(self,card_ids)
	local pc = self:poisonCards(card_ids)
	local cs = {}
	for c,id in sgs.list(card_ids)do
		c = sgs.Sanguosha:getCard(id)
		local n = c:getRealCard():toEquipCard():location()
		if self.player:hasEquipArea(n)
		then table.insert(cs,c) end
	end
	self:sortByUseValue(cs)
	for n,c in sgs.list(cs)do
		if table.contains(pc,c)
		or self:evaluateArmor(c)<-5
		then continue end
		n = c:getRealCard():toEquipCard():location()
		n = self.player:getEquip(n)
		if n and self:evaluateArmor(n)>-5
		then continue end
		if n and self:evaluateArmor(n)<-5
		then return c:getEffectiveId() end
	end
	for n,c in sgs.list(cs)do
		if table.contains(pc,c)
		or self:evaluateArmor(c)<-5
		then continue end
		n = c:getRealCard():toEquipCard():location()
		n = self.player:getEquip(n)
		if n and self:evaluateArmor(n)>-5
		then continue end
		if self:aiUseCard(c).card
		then return c:getEffectiveId() end
	end
	for n,c in sgs.list(cs)do
		if table.contains(pc,c)
		or self:evaluateArmor(c)<-5
		then continue end
		if self.player:getPhase()<=sgs.Player_Play
		and self:aiUseCard(c).card
		then return c:getEffectiveId() end
	end
	for n,c in sgs.list(cs)do
		if table.contains(pc,c)
		or self:evaluateArmor(c)<-5
		then continue end
		n = c:getRealCard():toEquipCard():location()
		n = self.player:getEquip(n)
		if n and self:evaluateArmor(n)>-5
		then continue end
		return c:getEffectiveId()
	end
	for n,c in sgs.list(cs)do
		if table.contains(pc,c)
		or self:evaluateArmor(c)<-5
		then continue end
		return c:getEffectiveId()
	end
	return #cs>0 and cs[1]:getEffectiveId()
end

sgs.ai_target_revises.zl_yexingyi = function(to,card)
    if card:isKindOf("TrickCard") and card:isBlack()
	then return true end
end

sgs.ai_skill_invoke.zl_yajiaoqiang = true
sgs.ai_armor_value.zl_yajiaoqiang = 2
sgs.ai_card_priority.zl_yajiaoqiang = function(self,card)
	if self.player:getPhase()==sgs.Player_NotActive
	and card:isBlack() and self.player:getMark("zl_yajiaoqiang-Clear")<1
	then return 3 end
end

addAiSkills("zl_jinhe").getTurnUseCard = function(self)
	local zl_li = self.player:getPile("zl_li")
  	if zl_li:length()>0 and #self.enemies>0
	and (self.player:getHandcardNum()<2 or self.player:getHandcardNum()>self.player:getMaxCards())
	then return sgs.Card_Parse("#zl_jinheCard:"..zl_li:at(0)..":") end
end

sgs.ai_skill_use_func["#zl_jinheCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_value.zl_jinheCard = -5.4
sgs.ai_use_priority.zl_jinheCard = -4.8



sgs.ai_skill_invoke.zd_xunzhi = function(self,data)
	return not self:isWeak() and self:getOverflow()>1
end

sgs.ai_fill_skill.zd_fenyue = function(self)
    return sgs.Card_Parse("#zd_fenyueCard:.:")
end

sgs.ai_skill_use_func["#zd_fenyueCard"] = function(card,use,self)
	local mc = self:getMaxCard()
	if mc
	then
		self:sort(self.enemies,"handcard")
		for _,p in sgs.list(self.enemies)do
			local emc = self:getMaxCard(p)
			if emc and emc:getNumber()<mc:getNumber()
			then
				use.card = card
				if use.to then use.to:append(p) end
				return
			end
		end
	end
end

sgs.ai_use_value.zd_fenyueCard = 3.4
sgs.ai_use_priority.zd_fenyueCard = 5.2

sgs.ai_skill_choice.zd_fenyue = function(self,choices,data)
	local target = data:toPlayer()
	local items = choices:split("+")
	if table.contains(items,"zd_fenyue2")
	then
		local d = dummyCard()
		d:setSkillName("_zd_fenyue")
		local use = {card=d,from=self.player}
		if self:canCanmou(target,use)
		then
			return "zd_fenyue2"
		end
	end
	if target:getHandcardNum()>0
	then
		return "zd_fenyue1"
	end
end

sgs.ai_skill_playerchosen.zd_dongcha = function(self,players)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card")
    for _,target in sgs.list(destlist)do
		if self:doDisCard(target,"ej",true)
		then return target end
	end
end



function SmartAI:useCardZdShengdongjixi(card,use)
	if self.player:getHandcardNum()<2 then return end
	local toList = self:sort(self.room:getAlivePlayers(),"handcard",true)
	local fromList = sgs.QList2Table(self.room:getOtherPlayers(self.player))
	local extraTarget = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
	if use.extra_target then extraTarget = extraTarget+use.extra_target end
	extraTarget = extraTarget*2
	for _,enemy in ipairs(fromList)do
		if isCurrent(use.current_targets,enemy) or use.to and use.to:contains(enemy) then continue end
		if CanToCard(card,self.player,enemy) and self:objectiveLevel(enemy)>=0
		and not(enemy:hasEquip() and self:loseEquipEffect(enemy) or enemy:hasSkill("tuntian+zaoxian"))
		and #self:poisonCards("he",enemy)<1
		and enemy:getCardCount()>0
		then
			for _,p in ipairs(toList)do
				if self:isFriend(p)
				and enemy~=p
				and use.to
				then
					use.card = card
					use.to:append(enemy)
					use.to:append(p)
					if use.to:length()>extraTarget
					then return end
					break
				end
			end
		end
	end
	for _,friend in ipairs(fromList)do
		if isCurrent(use.current_targets,friend) or use.to and use.to:contains(friend) then continue end
		if CanToCard(card,self.player,friend) and self:objectiveLevel(friend)<0
		and #self:poisonCards("h",friend)>0
		then
			for _,enemy in ipairs(toList)do
				if self:objectiveLevel(enemy)>1
				and enemy~=friend
				and use.to
				then
					use.card = card
					use.to:append(friend)
					use.to:append(enemy)
					if use.to:length()>extraTarget
					then return end
					break
				end
			end
		end
	end
	for _,friend in ipairs(fromList)do
		if isCurrent(use.current_targets,friend) or use.to and use.to:contains(friend) then continue end
		if CanToCard(card,self.player,friend) and self:objectiveLevel(friend)<0
		and #self:poisonCards("e",friend)>0
		then
			for _,p in sgs.list(self.room:getAlivePlayers())do
				if self:objectiveLevel(p)<=0
				and p~=friend
				and use.to
				then
					use.card = card
					use.to:append(friend)
					use.to:append(p)
					if use.to:length()>extraTarget
					then return end
					break
				end
			end
		end
	end
	for _,friend in ipairs(fromList)do
		if isCurrent(use.current_targets,friend) or use.to and use.to:contains(friend) then continue end
		if CanToCard(card,self.player,friend) and self:objectiveLevel(friend)<=0
		and #self:poisonCards("h",friend)<1
		then
			for _,p in ipairs(toList)do
				if self:objectiveLevel(p)<0
				and p~=friend
				and use.to
				then
					use.card = card
					use.to:append(friend)
					use.to:append(p)
					if use.to:length()>extraTarget
					then return end
					break
				end
			end
		end
	end
end

sgs.ai_use_value.ZdShengdongjixi = 5.8
sgs.ai_use_priority.ZdShengdongjixi = 4.75
sgs.ai_keep_value.ZdShengdongjixi = 3.40

sgs.ai_nullification.ZdShengdongjixi = function(self,trick,from,to,positive,null_num)
	if positive
	then
		if self:isEnemy(from) and (self:isFriend(to) or self:isEnemy(to))
		and (null_num>1 or self:isWeak(to) or to==self.player)
        then return true end
	else
		
	end
end

function SmartAI:useCardZdCaomujiebing(card,use)
	self:sort(self.enemies,"hp",true)
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if CanToCard(card,self.player,ep)
		then
	    	use.card = card
	    	if use.to then use.to:append(ep) end
			break
		end
	end
end
sgs.ai_use_priority.ZdCaomujiebing = 0.4
sgs.ai_keep_value.ZdCaomujiebing = 2
sgs.ai_use_value.ZdCaomujiebing = 5.7

sgs.ai_nullification.ZdCaomujiebing = function(self,trick,from,to,positive,null_num)
	if positive
	then
		if to==self.player
		or self:isFriend(to) and (null_num>1 or self:isWeak(to))
        then return true end
	else
		if self:isEnemy(to)
		and (null_num>1 or self:isWeak(to))
        then return true end
	end
end

function SmartAI:useCardZdzengbingjianzao(card,use)
	self:sort(self.friends,"handcard",true)
	local extraTarget = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
	if use.extra_target then extraTarget = extraTarget+use.extra_target end
	for _,fp in sgs.list(self.friends)do
		if isCurrent(use.current_targets,fp) then continue end
		if CanToCard(card,self.player,fp)
		and use.to and not use.to:contains(fp)
		and self:isWeak(fp)
		then
	    	use.card = card
	    	use.to:append(fp)
			if use.to:length()>extraTarget
			then return end
		end
	end
	if self:getCardsNum("EquipCard,TrickCard","he")>1
	then
		if CanToCard(card,self.player,self.player)
		and use.to and not use.to:contains(self.player)
		then
	    	use.card = card
	    	use.to:append(self.player)
			if use.to:length()>extraTarget
			then return end
		end
	end
	self:sort(self.friends,"handcard")
	for _,fp in sgs.list(self.friends)do
		if isCurrent(use.current_targets,fp) then continue end
		if CanToCard(card,self.player,fp)
		and use.to and not use.to:contains(fp)
		then
	    	use.card = card
	    	use.to:append(fp)
			if use.to:length()>extraTarget
			then return end
		end
	end
end
sgs.ai_use_priority.Zdzengbingjianzao = 9.4
sgs.ai_keep_value.Zdzengbingjianzao = 6
sgs.ai_use_value.Zdzengbingjianzao = 5.7

sgs.ai_nullification.ZdCaomujiebing = function(self,trick,from,to,positive,null_num)
	if positive
	then
		if self:isEnemy(to)
		and (null_num>1 or self:isWeak(to))
        then return true end
	else
		if to==self.player
		or self:isFriend(to) and (null_num>1 or self:isWeak(to))
        then return true end
	end
end

sgs.ai_skill_use["@@ZdZengbing!"] = function(self,prompt)
	for _,h in sgs.list(self:sortByKeepValue(self.player:getCards("he")))do
		if h:getTypeId()<2 then continue end
    	return "#ZdZengbingCard:"..h:getId()..":"
	end
end

function SmartAI:useCardZdQijiayebing(card,use)
	self:sort(self.enemies,"equip")
	local extraTarget = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
	if use.extra_target then extraTarget = extraTarget+use.extra_target end
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if CanToCard(card,self.player,ep)
		and use.to and not use.to:contains(ep)
		and (ep:getTreasure()==nil or ep:getEquips():length()>1)
		and self:isWeak(ep)
		then
	    	use.card = card
	    	use.to:append(ep)
			if use.to:length()>extraTarget
			then return end
		end
	end
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if CanToCard(card,self.player,ep)
		and use.to and not use.to:contains(ep)
		then
	    	use.card = card
	    	use.to:append(ep)
			if use.to:length()>extraTarget
			then return end
		end
	end
end
sgs.ai_use_priority.ZdQijiayebing = 8.4
sgs.ai_keep_value.ZdQijiayebing = 3
sgs.ai_use_value.ZdQijiayebing = 5.7

sgs.ai_skill_choice.zd_qijiayebing = function(self,choices)
	if self:getCardsNum("Weapon,OffensiveHorse","he")>self:getCardsNum("Armor,DefensiveHorse","he")
	then return "ZdQijia2" end
	return "ZdQijia1"
end

sgs.ai_skill_use["ZdJinchan0"] = function(self,prompt)
	for _,h in sgs.list(self:getCard("ZdJinchantuoqiao",true))do
		if self.player:isLocked(h) then continue end
    	return h:toString()
	end
end

sgs.ai_nullification.ZdJinchantuoqiao = function(self,trick,from,to,positive,null_num)
	if positive
	then
		if self:isEnemy(from)
		and (null_num>1 or self:isWeak(from))
        then return true end
	else
		if from==self.player
		or self:isFriend(from) and (null_num>1 or self:isWeak(from))
        then return true end
	end
end

sgs.ai_keep_value.ZdJinchantuoqiao = 2
sgs.ai_use_value.ZdJinchantuoqiao = 9.7

function SmartAI:useCardZdFulei(card,use)
	if self:willUseLightning(card)
	then use.card = card end
end
sgs.ai_use_priority.ZdFulei = -4
sgs.ai_keep_value.ZdFulei = 1
sgs.ai_use_value.ZdFulei = 1.7

function sgs.ai_cardsview.zd_lanyinjia(self,class_name,player)
	if class_name=="Jink"
	then
		for d,h in sgs.list(self:sortByKeepValue(player:getCards("h")))do
			d = dummyCard("jink")
			d:setSkillName("zd_lanyinjia")
			d:addSubcard(h)
			if player:isLocked(d,true)
			then continue end
			return d:toString()
		end
	end
end

sgs.ai_skill_invoke.zd_zhungangshuo = function(self,data)
	local target = data:toPlayer()
	if target and target:getHandcardNum()>0
	then
		if self:isEnemy(target)
		then return self:doDisCard(target,"h",true) end
	end
end



function SmartAI:useCardWlLuanwu(card,use)
	if #self.enemies>#self.friends_noself
	or self:isWeak(self.enemies)
	then use.card = card end
end
sgs.ai_use_priority.WlLuanwu = 4
sgs.ai_keep_value.WlLuanwu = 1
sgs.ai_use_value.WlLuanwu = 1.7

function SmartAI:useCardWlDouzhuanxingyi(card,use)
	local extraTarget = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
	if use.extra_target then extraTarget = extraTarget+use.extra_target end
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if CanToCard(card,self.player,ep)
		and use.to and not use.to:contains(ep)
		and ep:getHp()>self.player:getHp()
		and self.player:isWounded()
		and self:isWeak(ep)
		then
	    	use.card = card
	    	use.to:append(ep)
			if use.to:length()>extraTarget
			then return end
		end
	end
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if CanToCard(card,self.player,ep)
		and use.to and not use.to:contains(ep)
		and ep:getHp()>=self.player:getHp()
		and self.player:isWounded()
		and self:isWeak(ep)
		then
	    	use.card = card
	    	use.to:append(ep)
			if use.to:length()>extraTarget
			then return end
		end
	end
end
sgs.ai_use_priority.WlDouzhuanxingyi = 4.5
sgs.ai_keep_value.WlDouzhuanxingyi = 1
sgs.ai_use_value.WlDouzhuanxingyi = 1.7

function SmartAI:useCardWlLidaitaojing(card,use)
	local extraTarget = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
	if use.extra_target then extraTarget = extraTarget+use.extra_target end
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if CanToCard(card,self.player,ep)
		and use.to and not use.to:contains(ep)
		and ep:getHandcardNum()>self.player:getHandcardNum()
		and self:isWeak(ep)
		then
	    	use.card = card
	    	use.to:append(ep)
			if use.to:length()>extraTarget
			then return end
		end
	end
	for _,ep in sgs.list(self.enemies)do
		if isCurrent(use.current_targets,ep) then continue end
		if CanToCard(card,self.player,ep)
		and use.to and not use.to:contains(ep)
		and ep:getHandcardNum()>=self.player:getHandcardNum()
		then
	    	use.card = card
	    	use.to:append(ep)
			if use.to:length()>extraTarget
			then return end
		end
	end
end
sgs.ai_use_priority.WlLidaitaojing = 5.5
sgs.ai_keep_value.WlLidaitaojing = 3
sgs.ai_use_value.WlLidaitaojing = 1.7

function SmartAI:useCardWlToulianghuanzhu(card,use)
	for _,ep in sgs.list(self.enemies)do
		if ep:getEquips():length()>self.player:getEquips():length()
		then
	    	use.card = card
			break
		end
	end
end
sgs.ai_use_priority.WlToulianghuanzhu = 3.5
sgs.ai_keep_value.WlToulianghuanzhu = 2
sgs.ai_use_value.WlToulianghuanzhu = 1.7









function SmartAI:AlPresentCardTo(c,enemie)
	local tos = enemie and self.enemies or self.friends_noself
  	for _,to in sgs.list(tos)do
		if to:getDefensiveHorse()
		and to:getDefensiveHorse():objectName()=="yj_zhanxiang"
		and math.random()<0.8 then continue end
		if c:isKindOf("EquipCard")
		then
			local e = c:getRealCard():toEquipCard():location()
			if to:hasEquipArea(e) then else continue end
			e = to:getEquip(e)
			if e
			then
				e = self:evaluateArmor(e,to)
				if e<=-5 and enemie
				then continue end
			end
		elseif hasManjuanEffect(to)
		then continue end
		if c:isKindOf("YjQixingbaodao")
		then
			if enemie and to:getEquips():isEmpty() then continue end
			if not enemie and to:getEquips():length()>to:getJudgingArea():length() then continue end
		end
		if c:objectName()=="zl_numa"
		and to:getEquips():length()<2
		then continue end
		if c:isKindOf("YjPoison")
		then
			if enemie and to:getTreasure()
			and to:getTreasure():isKindOf("YjXinge") then continue end
		end
		if c:isKindOf("YjNvzhuang")
		or c:isKindOf("ZlNvzhuang")
		then
			if to:isMale() then else continue end
		end
		return to
	end
end

addAiSkills("yj_zhengyu").getTurnUseCard = function(self)
	sgs.ai_use_priority.yj_zhengyuCard = 0.8
	self.yjzy_to = nil
  	for _,c in sgs.list(self:sortByKeepValue(self.player:getHandcards()))do
		if CardIsPresent(c)
		then
			if c:isKindOf("Slash")
			then
				if table.contains(self.toUse,c)
				or self:getCardsNum("Slash")<2 and self:getOverflow()<1
				then continue end
				self.yjzy_to = self:AlPresentCardTo(c)
			elseif c:isKindOf("Jink")
			then
				if self:getCardsNum("Jink","h")<1 then continue end
				self.yjzy_to = self:AlPresentCardTo(c)
			elseif c:isKindOf("Peach")
			then
				if self:getCardsNum("Peach")<2
				and table.contains(self.toUse,c)
				then continue end
				self.yjzy_to = self:AlPresentCardTo(c)
			elseif c:isKindOf("YjPoison")
			then
				local can = self:isWeak() and math.random()<0.97
				local n = self.player:getHandcardNum()-self.player:getMaxCards()
				if n>0
				then
					n = self:askForDiscard("YjPoison",n,n)
					if table.contains(n,c:getEffectiveId())
					then can = false end
				end
				if can then continue end
				if self.player:hasArmorEffect("yj_yinfengyi")
				and (self.player:getHp()<4 or self.player:getMaxCards()>=self.player:getHandcardNum()/2)
				and math.random()<0.9 then continue end
				self.yjzy_to = self:AlPresentCardTo(c,true)
				sgs.ai_use_priority.yj_zhengyuCard = 0.8
			elseif c:isKindOf("YjQixingbaodao")
			then self.yjzy_to = self:AlPresentCardTo(c,true) or self:AlPresentCardTo(c)
			elseif c:isKindOf("EquipCard")
			then
				if table.contains(self.toUse,c) then continue end
				local enemie = sgs.ai_poison_card[c:objectName()] or self:evaluateArmor(c)<-5
				self.yjzy_to = self:AlPresentCardTo(c,enemie)
				sgs.ai_use_priority.yj_zhengyuCard = 8
			else
				if table.contains(self.toUse,c) then continue end
				self.yjzy_to = self:AlPresentCardTo(c,sgs.ai_poison_card[c:objectName()])
			end
			if self.yjzy_to==nil then continue end
			return sgs.Card_Parse("#yj_zhengyuCard:"..c:getEffectiveId()..":")
		end
	end
end

sgs.ai_skill_use_func["#yj_zhengyuCard"] = function(card,use,self)
	if self.yjzy_to
	then
		use.card = card
		if use.to then use.to:append(self.yjzy_to) end
	end
end

sgs.ai_use_value.yj_zhengyuCard = 5.4
sgs.ai_use_priority.yj_zhengyuCard = 0.8
