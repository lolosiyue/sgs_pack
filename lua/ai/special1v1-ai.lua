function SmartAI:useCardDrowning(card,use)
	self:sort(self.enemies)
	local equip_enemy = {}
	local extraTarget = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,self.player,card)
	if use.extra_target then extraTarget = extraTarget+use.extra_target end
	for _,enemy in sgs.list(self.enemies)do
		if use.current_targets and table.contains(use.current_targets,enemy:objectName()) then continue end
		if self:isGoodTarget(enemy,self.enemies,card)
		then
			if enemy:isChained()
			then
				if self:isGoodChainTarget(enemy,card)
				then else continue end
			end
			if enemy:hasEquip() then table.insert(equip_enemy,enemy)
			elseif use.to and CanToCard(card,self.player,enemy)
			then
				use.card = card
				use.to:append(enemy)
				if use.to:length()>extraTarget
				then return end
			end
		end
	end
	if #equip_enemy>0
	then
		self:sort(equip_enemy,"equip",true)
		for _,enemy in sgs.list(equip_enemy)do
			if #self:poisonCards("e",enemy)<enemy:getEquips():length()/2
			and use.to and CanToCard(card,self.player,enemy)
			and self:isGoodTarget(enemy,self.enemies,card)
			then
				use.card = card
				use.to:append(enemy)
				if use.to:length()>extraTarget
				then return end
			end
		end
	end
	for _,friend in sgs.list(self.friends_noself)do
		if use.current_targets and table.contains(use.current_targets,friend:objectName()) then continue end
		local n = 0
		for _,e in sgs.list(friend:getEquips())do
			if self:canDisCard(friend,e:getEffectiveId())
			then n = n+1 else n = n-1 end
		end
		if friend:isChained()
		then
			if self:isGoodChainTarget(friend,card)
			and self:damageIsEffective(friend,card,self.player)
			then else continue end
		elseif n<1 then continue end
		if use.to and CanToCard(card,self.player,friend)
		then
			use.card = card
			use.to:append(friend)
			if use.to:length()>extraTarget
			then return end
		end
	end
end

sgs.ai_card_intention.Drowning = function(self,card,from,tos)
	for _,to in sgs.list(tos)do
		if not self:hasTrickEffective(card,to,from)
		or self:needToThrowArmor(to) then
		else
			sgs.updateIntention(from,to,80)
		end
	end
end

sgs.ai_use_value.Drowning = 5
sgs.ai_use_priority.Drowning = 7

sgs.card_damage_nature.Drowning = "T"

sgs.ai_skill_choice.drowning = function(self,choices,data)
	local effect = data:toCardEffect()
	if not self:damageIsEffective(self.player,sgs.DamageStruct_Thunder,effect.from)
	or self:needToLoseHp(self.player,effect.from,effect.card)
	then return "damage" end
	if self:isWeak() and not self:needDeath() then return "throw" end
	local value = 0
	if self.player:isChained()
	and self:isGoodChainTarget(self.player,effect.card,effect.from)
	then
		if self:isFriend(effect.from) then value = 99
		else value = -7 end
	end
	for _,equip in sgs.list(self.player:getEquips())do
		value = value+self:evaluateArmor(equip)
		if equip:isKindOf("Weapon") then value = value+self:evaluateWeapon(equip)
		elseif equip:isKindOf("OffensiveHorse") then value = value+2.5
		elseif equip:isKindOf("DefensiveHorse") then value = value+5 end
	end
	if value<8 then return "throw" else return "damage" end
end

sgs.ai_skill_playerchosen.koftuxi = function(self,targets)
	local cardstr = sgs.ai_skill_use["@@nostuxi"](self,"@nostuxi")
	if cardstr:match("->") then
		local targetstr = cardstr:split("->")[2]:split("+")
		if #targetstr>0 then
			local target = findPlayerByObjectName(self.room,targetstr[1])
			return target
		end
	end
	return nil
end

sgs.ai_playerchosen_intention.koftuxi = function(self,from,to)
	local lord = self.room:getLord()
	if sgs.ai_role[from:objectName()]=="neutral" and sgs.ai_role[to:objectName()]=="neutral"
		and lord and not lord:isKongcheng()
		and not self:doNotDiscard(lord,"h",true) and from:aliveCount()>=4 then
		sgs.updateIntention(from,lord,-35)
		return
	end
	if from:getState()=="online" then
		if (to:hasSkills("kongcheng|zhiji|noslianying") and to:getHandcardNum()==1) or to:hasSkills("tuntian+zaoxian") then
		else
			sgs.updateIntention(from,to,80)
		end
	else
		local intention = from:hasFlag("tuxi_isfriend_"..to:objectName()) and -5 or 80
		sgs.updateIntention(from,to,intention)
	end
end

sgs.ai_nullification.Drowning = function(self,trick,from,to,positive,null_num)
	if self:needToThrowArmor(to)
	then return false
	elseif positive
	then
        if null_num>1
		then
			return self:isFriend(to) and (to:getEquips():length()>1 or to:getEquips():length()<1)
			or to:objectName()==self.player:objectName()
		else
			return self:isFriend(to) and self:isWeak(to)
			and (to:getEquips():length()>1 or to:getEquips():length()<1)
			or to:objectName()==self.player:objectName()
		end
	else
        if null_num>1
		then
			return self:isEnemy(to)
			and (to:getEquips():length()>1 or to:getEquips():length()<1)
		else
			return self:isEnemy(to)
			and (to:getEquips():length()>1 or to:getEquips():length()<1)
			and self:isWeak(to)
		end
	end
end


xiechan_skill = {}
xiechan_skill.name = "xiechan"
table.insert(sgs.ai_skills,xiechan_skill)
xiechan_skill.getTurnUseCard = function(self)
	self:sort(self.enemies,"handcard")
	if self.player:hasSkill("nosluoyi") and not self.player:hasFlag("nosluoyi") then return end
	return sgs.Card_Parse("@XiechanCard=.")
end

sgs.ai_skill_use_func.XiechanCard = function(card,use,self)
	self.player:setFlags("AI_XiechanUsing")
	local max_card = self:getMaxCard()
	self.player:setFlags("-AI_XiechanUsing")
	if max_card:isKindOf("Slash") and self:getCardsNum("Slash")<=2 then return end
	local max_point = max_card:getNumber()

	local dummy_use = { isDummy = true,xiechan = true,to = sgs.SPlayerList() }
	local duel = sgs.Sanguosha:cloneCard("Duel")
	self:useCardDuel(duel,dummy_use)
	if not dummy_use.card or not dummy_use.card:isKindOf("Duel") then return end
	for _,enemy in sgs.list(dummy_use.to)do
		if self.player:canPindian(enemy) and not (enemy:hasSkill("kongcheng") and enemy:getHandcardNum()==1) then
			local enemy_max_card = self:getMaxCard(enemy)
			local enemy_max_point = enemy_max_card and enemy_max_card:getNumber() or 100
			if max_point>enemy_max_point then
				self.xiechan_card = max_card:getId()
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

sgs.ai_view_as.kofqingguo = function(card,player,card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place==sgs.Player_PlaceEquip then
		return ("jink:kofqingguo[%s:%s]=%d"):format(suit,number,card_id)
	end
end

function sgs.ai_cardneed.kofqingguo(to,card)
	if card:isKindOf("Weapon") then return not to:getWeapon()
	elseif card:isKindOf("Armor") then return not to:getArmor()
	elseif card:isKindOf("OffensiveHorse") then return not to:getOffensiveHorse()
	elseif card:isKindOf("DefensiveHorse") then return not to:getDefensiveHorse()
	end
	return false
end


sgs.ai_skill_invoke.kofliegong = sgs.ai_skill_invoke.liegong

function sgs.ai_cardneed.kofliegong(to,card,self)
	return isCard("Slash",card,to) and getKnownCard(to,self.player,"Slash",true)==0
end

sgs.ai_skill_invoke.yinli = sgs.ai_skill_invoke.luoying

sgs.ai_skill_askforag.yinli = function(self,card_ids)
	if self:needKongcheng(self.player,true) then return card_ids[1] else return -1 end
end

sgs.ai_skill_choice.kofxiaoji = function(self,choices)
	if choices:match("recover") then return "recover" else return "draw" end
end

sgs.kofxiaoji_keep_value = sgs.xiaoji_keep_value

sgs.ai_cardneed.kofxiaoji = sgs.ai_cardneed.equip

sgs.ai_skill_invoke.suzi = true
sgs.ai_skill_invoke.cangji = true

sgs.ai_skill_use["@@cangji"] = function(self,prompt)
	for i = 0,3,1 do
		local equip = self.player:getEquip(i)
		if not equip then continue end
		self:sort(self.friends_noself)
		if i==0 then
			if equip:isKindOf("Crossbow") or equip:isKindOf("Blade") then
				for _,friend in sgs.list(self.friends_noself)do
					if not self:getSameEquip(equip) and not self:hasCrossbowEffect(friend) and getCardsNum("Slash",friend,self.player)>1 then
						return "@CangjiCard="..equip:getEffectiveId().."->"..friend:objectName()
					end
				end
			elseif equip:isKindOf("Axe") then
				for _,friend in sgs.list(self.friends_noself)do
					if not self:getSameEquip(equip)
						and (friend:getCardCount()>=4
							or (friend:getCardCount()>=2 and self:ajustDamage(friend,nil,1,dummyCard()))>1) then
						return "@CangjiCard="..equip:getEffectiveId().."->"..friend:objectName()
					end
				end
			end
		end
		for _,friend in sgs.list(self.friends_noself)do
			if not self:getSameEquip(equip,friend) and not (i==1 and (self:evaluateArmor(equip,friend)<=0 or friend:hasSkills("bazhen|yizhong"))) then
				return "@CangjiCard="..equip:getEffectiveId().."->"..friend:objectName()
			end
		end
		if equip:isKindOf("SilverLion") then
			for _,enemy in sgs.list(self.enemies)do
				if not enemy:getArmor() and enemy:hasSkills("bazhen|yizhong") then
					return "@CangjiCard="..equip:getEffectiveId().."->"..enemy:objectName()
				end
			end
		end
	end
	return "."
end

sgs.ai_card_intention.CangjiCard = function(self,card,from,tos)
	local to = tos[1]
	local equip = sgs.Sanguosha:getCard(card:getEffectiveId())
	if equip:isKindOf("SilverLion") and to:hasSkills("bazhen|yizhong") then
		sgs.updateIntention(from,to,40)
	else
		sgs.updateIntention(from,to,-40)
	end
end

sgs.ai_skill_invoke.huwei = function(self,data)
	local drowning = sgs.Sanguosha:cloneCard("drowning")
	local dummy_use = { isDummy = true }
	self:useTrickCard(drowning,dummy_use)
	return (dummy_use.card~=nil)
end

sgs.ai_skill_invoke.xiaoxi = function(self,data)
	local slash = sgs.Sanguosha:cloneCard("slash")
	local dummy_use = { isDummy = true }
	self:useBasicCard(slash,dummy_use)
	return (dummy_use.card~=nil)
end

sgs.ai_skill_invoke.manyi = function(self,data)
	local sa = sgs.Sanguosha:cloneCard("savage_assault")
	local dummy_use = { isDummy = true }
	self:useTrickCard(sa,dummy_use)
	return (dummy_use.card~=nil)
end

local mouzhu_skill = {}
mouzhu_skill.name = "mouzhu"
table.insert(sgs.ai_skills,mouzhu_skill)
mouzhu_skill.getTurnUseCard = function(self)
	return sgs.Card_Parse("@MouzhuCard=.")
end

sgs.ai_skill_use_func.MouzhuCard = function(card,use,self)

	local canleiji
	if self:findLeijiTarget(self.player,50)
		and ((self.player:hasSkill("leiji") and self:hasSuit("spade",true))
			or (self.player:hasSkill("nosleiji") and self:hasSuit("black",true))) then
		canleiji = true
		self:sort(self.friends_noself,"handcard")
		self.friends_noself = sgs.reverse(self.friends_noself)
		for _,friend in sgs.list(self.friends_noself)do
			if not friend:isKongcheng() and friend:getHandcardNum()<self.player:getHandcardNum()+2
				and (self:getCardsNum("Jink")>0 or (not friend:hasWeapon("qinggang_sword") and not self:isWeak() and self:hasEightDiagramEffect())) then
				use.card = card
				if use.to then use.to:append(friend) end
				return
			end
		end
	end

	for _,enemy in sgs.list(self.enemies)do
		if enemy:getHandcardNum()>0 and  self:needToLoseHp(self.player,enemy,card) then
			use.card = card
			if use.to then use.to:append(enemy) end
			return
		end
	end

	local first,second,third,fourth
	local slash = self:getCard("Slash")
	local slash_nosuit = sgs.Sanguosha:cloneCard("slash")
	for _,enemy in sgs.list(self.enemies)do
		if enemy:getHandcardNum()>=self.player:getHandcardNum()+2 then
			first = enemy
			break
		elseif enemy:getHandcardNum()>0 then
			if not self:slashIsEffective(slash_nosuit,self.player,nil,enemy) and self:getCardsNum("Slash")>getCardsNum("Slash",enemy) and not second then
				second = enemy
			elseif not enemy:hasSkills("wushuang|mengjin|tieji|nostieji")
				and not ((enemy:hasSkill("roulin") or enemy:hasWeapon("double_sword")) and enemy:getGender()~=self.player:getGender()) then

				if enemy:getHandcardNum()==1 and slash and not third and self.player:inMyAttackRange(enemy)
				and (self:ajustDamage(self.player,enemy,1,slash)>1 or self.player:hasWeapon("guding_blade") and not self:needKongcheng(enemy))
				and (not self:isWeak() or self:getCardsNum("Peach")+self:getCardsNum("Analeptic")>0)
				then
					third = enemy
				elseif self:getCardsNum("Jink")>0 and self:getCardsNum("Slash")>getCardsNum("Slash",enemy) and not fourth then
					fourth = enemy
				end
			end
		end
	end

	local target
	if canleiji then
		target = fourth and third or first or second
	else
		target = first or second or third or fourth
	end
	if target then
		use.card = card
		if use.to then use.to:append(target) end
		return
	end

end

sgs.ai_skill_cardask["@mouzhu-give"] = function(self,data)
	local target = self.room:getCurrent()
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByKeepValue(cards)
	if self:isFriend(target) then
		if target:hasSkill("nosleiji") then
			local jink,spade
			for _,c in sgs.list(cards)do
				if isCard("Jink",c,target) then jink = c:getEffectiveId() end
				if c:getSuit()==sgs.Card_Spade then spade = c:getEffectiveId() end
			end
			if self:hasSuit("spade",true,target) and jink then return jink
			elseif not self:hasEightDiagramEffect(target) and jink then return jink
			elseif spade or jink then return spade or jink
			end
		elseif target:hasSkill("leiji") then
			local jink,black
			for _,c in sgs.list(cards)do
				if isCard("Jink",c,target) then jink = c:getEffectiveId() end
				if c:isBlack() then black = c:getEffectiveId() end
			end
			if self:hasSuit("black",true,target) and jink then return jink
			elseif not self:hasEightDiagramEffect(target) and jink then return jink
			elseif black or jink then return black or jink
			end
		end
	else
		if target:hasSkill("nosleiji") then
			for _,c in sgs.list(cards)do
				if not c:isKindOf("Peach") and not c:isKindOf("Jink") and c:getSuit()~=sgs.Card_Spade then
					return c:getEffectiveId()
				end
			end
		elseif target:hasSkill("leiji") then
			for _,c in sgs.list(cards)do
				if not c:isKindOf("Peach") and not c:isKindOf("Jink") and not c:isBlack() then
					return c:getEffectiveId()
				end
			end
		end
		for _,c in sgs.list(cards)do
			if not c:isKindOf("Peach") then return c:getEffectiveId() end
		end
	end

	return cards[1]:getEffectiveId()
end

sgs.ai_skill_choice.mouzhu = function(self,choices)
	local target = self.room:getCurrent()
	local slash = sgs.Sanguosha:cloneCard("slash")
	if target:hasSkills("leiji|nosleiji") then
		if self:isFriend(target) then
			if choices:match("slash") then return "slash" end
		else
			if choices:match("duel") then return "duel" end
		end
	end

	if self:isFriend(target) then
		if (target:hasSkills("leiji|nosleiji") or not self:slashIsEffective(slash,target)) and choices:match("slash") then return "slash" end
		if self:needToLoseHp(self.player,target) and getCardsNum("Slash",target,self.player)>=1 and choices:match("duel") then return "duel" end
	else
		if target:hasSkills("leiji|nosleiji") and choices:match("duel") then return "duel" end
		if self:getCardsNum("Slash")>getCardsNum("Slash",target,self.player) and choices:match("duel") then return "duel" end
	end

	if choices:match("slash") then return "slash" else return "duel" end
end

sgs.ai_use_priority.MouzhuCard = 5.5

sgs.ai_card_intention.MouzhuCard = function(self,card,from,tos)
	if not self.player:hasSkills("leiji|nosleiji") then sgs.updateIntention(from,tos[1],30) end
end

sgs.ai_skill_invoke.yanhuo = function(self,data)
	local opponent = self.room:getOtherPlayers(self.player,true):first()
	return opponent:isAlive() and not self:doNotDiscard(opponent)
end

sgs.ai_skill_playerchosen.yanhuo = function(self,targets)
	local target = self:findPlayerToDiscard(nil,nil,true,targets)
	if target and target:objectName()~=self.player:objectName() then return target end
end

sgs.ai_skill_invoke.kofkuanggu = function(self,data)
	local zhangbao = self.room:findPlayerBySkillName("yingbing")
	if zhangbao and self:isEnemy(zhangbao)
		and self.player:getPile("incantation"):length()>0 and sgs.Sanguosha:getCard(self.player:getPile("incantation"):first()):isRed()
		and not self:hasWizard(self.friends) then return false end
	if self.player:isWounded() then return true end
	local zhangjiao = self.room:findPlayerBySkillName("guidao")
	return zhangjiao and self:isFriend(zhangjiao) and not zhangjiao:isNude()
end

local puji_skill = {}
puji_skill.name = "puji"
table.insert(sgs.ai_skills,puji_skill)
puji_skill.getTurnUseCard = function(self,inclusive)

	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards,true)

	if self:needToThrowArmor() then return sgs.Card_Parse("@PujiCard="..self.player:getArmor():getEffectiveId()) end
	for _,card in sgs.list(cards)do
		if not self:isValuableCard(card) then
			if card:getSuit()==sgs.Card_Spade then return sgs.Card_Parse("@PujiCard="..card:getEffectiveId()) end
		end
	end
	for _,card in sgs.list(cards)do
		if not self:isValuableCard(card) and not (self.player:hasSkill("jijiu") and card:isRed() and self:getOverflow()<2) then
			if card:getSuit()==sgs.Card_Spade then return sgs.Card_Parse("@PujiCard="..card:getEffectiveId()) end
		end
	end
end

sgs.ai_skill_use_func.PujiCard = function(card,use,self)
	self.puji_id_choice = nil
	local players = self:findPlayerToDiscard("he",false,true,nil,true)
	for _,p in sgs.list(players)do
		local id = self:askForCardChosen(p,"he","dummyreason",sgs.Card_MethodDiscard)
		local chosen_card
		if id then chosen_card = sgs.Sanguosha:getCard(id) end
		if id and chosen_card and (self:isFriend(p) or not p:hasEquip(chosen_card) or sgs.Sanguosha:getCard(id):getSuit()~=sgs.Card_Spade) then
			self.puji_id_choice = id
			use.card = card
			if use.to then use.to:append(p) end
			return
		end
	end
end

sgs.ai_use_value.PujiCard = 5
sgs.ai_use_priority.PujiCard = 4.6

sgs.ai_card_intention.PujiCard = function(self,card,from,tos)
	if not self.puji_id_choice then return end
	local to = tos[1]
	local em_prompt = { "cardChosen","puji",tostring(self.puji_id_choice),from:objectName(),to:objectName() }
	sgs.ai_choicemade_filter.cardChosen.snatch(self,nil,em_prompt)
end

sgs.ai_skill_use["@@niluan"] = function(self,prompt)
	return sgs.ai_skill_use.slash(self,prompt)
end

sgs.ai_skill_cardask["@niluan-slash"] = function(self,data,pattern,target,target2)
	if target and self:isFriend(target) and not self:findLeijiTarget(target,50,self.player) then
		return "."
	end
	if not self.player:canSlash(target,false) then return "." end

	local black_card
	if not target:hasSkill("yizhong") and not target:hasArmorEffect("renwang_shield") and not target:hasArmorEffect("vine") then
		local cards = sgs.QList2Table(self.player:getHandcards())
		self:sortByKeepValue(cards)
		local slash = sgs.Sanguosha:cloneCard("slash")
		for _,card in sgs.list(cards)do
			if card:isBlack() and self:getKeepValue(card,cards)<=self:getKeepValue(slash,cards) then
				local black_slash = sgs.Sanguosha:cloneCard("slash",sgs.Card_SuitToBeDecided,-1)
				black_slash:addSubcard(card)
				if self:slashIsEffective(black_slash,target) then
					black_card = card
					break
				end
			end
		end
		if not black_card then
			local offensive_horse = self.player:getOffensiveHorse()
			if offensive_horse and offensive_horse:isBlack() then
				local black_slash = sgs.Sanguosha:cloneCard("slash",sgs.Card_SuitToBeDecided,-1)
				black_slash:addSubcard(offensive_horse)
				if self:slashIsEffective(black_slash,target) then
					black_card = offensive_horse
				end
			end
		end
	end
	if self:needToThrowArmor() and self.player:getArmor():isBlack() then black_card = self.player:getArmor()
	elseif self:needKongcheng(self.player,true) and self.player:getHandcardNum()==1 and self.player:getHandcards():first():isBlack() then
		black_card = self.player:getHandcards():first()
	end
	if black_card then
		local black_slash = sgs.Sanguosha:cloneCard("slash",sgs.Card_SuitToBeDecided,-1)
		black_slash:setSkillName("niluan")
		black_slash:addSubcard(black_card)
		return black_slash:toString()
	end
	return "."
end

sgs.ai_skill_invoke.renwang = function(self,data)
	local use = data:toCardUse()
	if self:isFriend(use.from) then
		local id = self:askForCardChosen(use.from,"he","dummy",sgs.Card_MethodDiscard)
		return self:needToThrowArmor(use.from) and id==use.from:getArmor():getEffectiveId()
	elseif not self:doNotDiscard(use.from,"he") and use.from:getCardCount()>0 then
		return true
	end
	return
end
