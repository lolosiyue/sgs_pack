sgs.ai_skill_playerchosen.wuhun = function(self,targets)
	local targetlist=self:sort(targets,"hp")
	local target
	local lord
	for _,player in sgs.list(targetlist)do
		if player:isLord() then lord = player end
		if self:isEnemy(player) and (not target or target:getHp()<player:getHp()) then
			target = player
		end
	end
	if self.role=="rebel" and lord then return lord end
	if target then return target end
	
	if self.player:getRole()=="loyalist" and targetlist[1]:isLord() then return targetlist[2] end
	return targetlist[1]
end

function SmartAI:getWuhunRevengeTargets()
	local targets = {}
	local maxcount = 0
	for _,p in sgs.list(self.room:getAlivePlayers())do
		local count = p:getMark("&nightmare")
		if count>maxcount then
			targets = { p }
			maxcount = count
		elseif count==maxcount and maxcount>0 then
			table.insert(targets,p)
		end
	end
	return targets
end

function sgs.ai_slash_prohibit.wuhun(self,from,to)
	if from:hasSkill("jueqing") then return false end
	if from:hasFlag("NosJiefanUsed") then return false end
	local damageNum = self:ajustDamage(from,to,1,dummyCard())

	local maxfriendmark = 0
	local maxenemymark = 0
	for _,friend in sgs.list(self:getFriends(from))do
		local friendmark = friend:getMark("&nightmare")
		if friendmark>maxfriendmark then maxfriendmark = friendmark end
	end
	for _,enemy in sgs.list(self:getEnemies(from))do
		local enemymark = enemy:getMark("&nightmare")
		if enemymark>maxenemymark and enemy:objectName()~=to:objectName() then maxenemymark = enemymark end
	end
	if self:isEnemy(to,from) and not (to:isLord() and from:getRole()=="rebel") then
		if (maxfriendmark+damageNum>=maxenemymark) and not (#(self:getEnemies(from))==1 and #(self:getFriends(from))+#(self:getEnemies(from))==self.room:alivePlayerCount()) then
			if not (from:getMark("&nightmare")==maxfriendmark and from:getRole()=="loyalist") then
				return true
			end
		end
	end
end

function SmartAI:cantbeHurt(player,from,damageNum)
	from = from or self.player
	if hasJueqingEffect(from,player) then return false end
	damageNum = damageNum or 1
	if player:hasSkill("wuhun") and not player:isLord() and #self:getFriendsNoself(player)>0
	then
		local maxfriendmark,maxenemymark = 0,0
		for friendmark,friend in sgs.list(self:getFriends(from))do
            friendmark = friend:getMark("&nightmare")
			if friendmark>maxfriendmark then maxfriendmark = friendmark end
		end
		for enemymark,enemy in sgs.list(self:getEnemies(from))do
            enemymark = enemy:getMark("&nightmare")
			if enemymark>maxenemymark and enemy:objectName()~=player:objectName()
			then maxenemymark = enemymark end
		end
		if self:isEnemy(player,from)
		then
			if maxfriendmark+damageNum-player:getHp()/2>=maxenemymark
			and not (#self:getEnemies(from)==1 and #self:getFriends(from)+#self:getEnemies(from)==self.room:alivePlayerCount())
            and not (from:getMark("&nightmare")==maxfriendmark and from:getRole()=="loyalist")
			then return true end
		elseif maxfriendmark+damageNum-player:getHp()/2>maxenemymark
		then return true end
	end
	if player:hasSkill("duanchang") and not player:isLord() and #self:getFriendsNoself(player)>0 and player:getHp()<=1
	then
		if not (from:getMaxHp()==3 and from:getArmor() and from:getDefensiveHorse())
		then
			if from:getMaxHp()<=3 or from:isLord() and self:isWeak(from) then return true end
			if from:getMaxHp()<=3 or self.room:getLord() and from:getRole()=="renegade" then return true end
		end
	end
	if player:hasSkill("tianxiang")
	and getKnownCard(player,from,"diamond,club",false)<player:getHandcardNum()
	then
		for _,friend in sgs.list(self:getFriends(from))do
			if friend:getHp()+getCardsNum("Peach",from,self.player)<2
			and player:getHandcardNum()>0
			then return true end
		end
	end
	return false
end

function SmartAI:needDeath(player)
	player = player or self.player
	if player:hasSkill("wuhun") and #self:getFriendsNoself(player)>0
	then
		local maxfriendmark,maxenemymark = 0,0
		for m,ap in sgs.list(self.room:getAlivePlayers())do
            m = ap:getMark("&nightmare")
			if self:isFriend(player,ap) and player:objectName()~=ap:objectName()
			and m>maxfriendmark then maxfriendmark = m end
			if self:isEnemy(player,ap) and m>maxenemymark
			then maxenemymark = m end
			if maxfriendmark>maxenemymark then return false
			elseif maxenemymark<1 then return false
			else return true end
		end
	end
	return false
end

function SmartAI:doNotSave(player)
	if (player:hasSkill("niepan") and player:getMark("@nirvana")>0 and player:getCards("e"):length()<2)
		or (player:hasSkill("fuli") and player:getMark("@laoji")>0 and player:getCards("e"):length()<2) then
		return true
	end
	if player:hasFlag("AI_doNotSave") then return true end
	return false
end




sgs.ai_skill_invoke.shelie = true

local gongxin_skill={}
gongxin_skill.name="gongxin"
table.insert(sgs.ai_skills,gongxin_skill)
gongxin_skill.getTurnUseCard=function(self)
	return sgs.Card_Parse("@GongxinCard=.")
end

sgs.ai_skill_use_func.GongxinCard=function(card,use,self)
	self:sort(self.enemies,"handcard")
	self.enemies = sgs.reverse(self.enemies)

	for _,enemy in sgs.list(self.enemies)do
		if not enemy:isKongcheng() and self:objectiveLevel(enemy)>0
			and (self:hasSuit("heart",false,enemy) or self:getKnownNum(eneny)~=enemy:getHandcardNum()) then
			use.card = card
			if use.to then
				use.to:append(enemy)
			end
			return
		end
	end
end

sgs.ai_skill_askforag.gongxin = function(self,card_ids)
	self.gongxinchoice = nil
	local target = self.player:getTag("gongxin"):toPlayer()
	if not target or self:isFriend(target) then return -1 end
	local nextAlive = self.player
	repeat
		nextAlive = nextAlive:getNextAlive()
	until nextAlive:faceUp()

	local peach,ex_nihilo,jink,nullification,slash
	local valuable
	for _,id in sgs.list(card_ids)do
		local card = sgs.Sanguosha:getCard(id)
		if card:isKindOf("Peach") then peach = id end
		if card:isKindOf("ExNihilo") then ex_nihilo = id end
		if card:isKindOf("Jink") then jink = id end
		if card:isKindOf("Nullification") then nullification = id end
		if card:isKindOf("Slash") then slash = id end
	end
	valuable = peach or ex_nihilo or jink or nullification or slash or card_ids[1]
	local card = sgs.Sanguosha:getCard(valuable)
	if self:isEnemy(target) and target:hasSkill("tuntian") then
		local zhangjiao = self.room:findPlayerBySkillName("guidao")
		if zhangjiao and self:isFriend(zhangjiao,target) and self:canRetrial(zhangjiao,target) and self:isValuableCard(card,zhangjiao) then
			self.gongxinchoice = "discard"
		else
			self.gongxinchoice = "put"
		end
		return valuable
	end

	local willUseExNihilo,willRecast
	if self:getCardsNum("ExNihilo")>0 then
		local ex_nihilo = self:getCard("ExNihilo")
		if ex_nihilo then
			local dummy_use = { isDummy = true }
			self:useTrickCard(ex_nihilo,dummy_use)
			if dummy_use.card then willUseExNihilo = true end
		end
	elseif self:getCardsNum("IronChain")>0 then
		local iron_chain = self:getCard("IronChain")
		if iron_chain then
			local dummy_use = { to = sgs.SPlayerList(),isDummy = true }
			self:useTrickCard(iron_chain,dummy_use)
			if dummy_use.card and dummy_use.to:isEmpty() then willRecast = true end
		end
	end
	if willUseExNihilo or willRecast then
		local card = sgs.Sanguosha:getCard(valuable)
		if card:isKindOf("Peach") then
			self.gongxinchoice = "put"
			return valuable
		end
		if card:isKindOf("TrickCard") or card:isKindOf("Indulgence") or card:isKindOf("SupplyShortage") then
			local dummy_use = { isDummy = true }
			self:useTrickCard(card,dummy_use)
			if dummy_use.card then
				self.gongxinchoice = "put"
				return valuable
			end
		end
		if card:isKindOf("Jink") and self:getCardsNum("Jink")==0 then
			self.gongxinchoice = "put"
			return valuable
		end
		if card:isKindOf("Nullification") and self:getCardsNum("Nullification")==0 then
			self.gongxinchoice = "put"
			return valuable
		end
		if card:isKindOf("Slash") and self:slashIsAvailable() then
			local dummy_use = { isDummy = true }
			self:useBasicCard(card,dummy_use)
			if dummy_use.card then
				self.gongxinchoice = "put"
				return valuable
			end
		end
		self.gongxinchoice = "discard"
		return valuable
	end

	local hasLightning,hasIndulgence,hasSupplyShortage
	local tricks = nextAlive:getJudgingArea()
	if not tricks:isEmpty() and not nextAlive:containsTrick("YanxiaoCard") then
		local trick = tricks:at(tricks:length()-1)
		if self:hasTrickEffective(trick,nextAlive) then
			if trick:isKindOf("Lightning") then hasLightning = true
			elseif trick:isKindOf("Indulgence") then hasIndulgence = true
			elseif trick:isKindOf("SupplyShortage") then hasSupplyShortage = true
			end
		end
	end

	if self:isEnemy(nextAlive) and nextAlive:hasSkill("luoshen") and valuable then
		self.gongxinchoice = "put"
		return valuable
	end
	if nextAlive:hasSkill("yinghun") and nextAlive:isWounded() then
		self.gongxinchoice = self:isFriend(nextAlive) and "put" or "discard"
		return valuable
	end
	if target:hasSkill("hongyan") and hasLightning and self:isEnemy(nextAlive) and not (nextAlive:hasSkill("qiaobian") and nextAlive:getHandcardNum()>0) then
		for _,id in sgs.list(card_ids)do
			local card = sgs.Sanguosha:getEngineCard(id)
			if card:getSuit()==sgs.Card_Spade and card:getNumber()>=2 and card:getNumber()<=9 then
				self.gongxinchoice = "put"
				return id
			end
		end
	end
	if hasIndulgence and self:isFriend(nextAlive) then
		self.gongxinchoice = "put"
		return valuable
	end
	if hasSupplyShortage and self:isEnemy(nextAlive) and not (nextAlive:hasSkill("qiaobian") and nextAlive:getHandcardNum()>0) then
		local enemy_null = 0
		for _,p in sgs.list(self.room:getOtherPlayers(self.player))do
			if self:isFriend(p) then enemy_null = enemy_null-getCardsNum("Nullification",p) end
			if self:isEnemy(p) then enemy_null = enemy_null+getCardsNum("Nullification",p) end
		end
		enemy_null = enemy_null-self:getCardsNum("Nullification")
		if enemy_null<0.8 then
			self.gongxinchoice = "put"
			return valuable
		end
	end

	if self:isFriend(nextAlive) and not self:willSkipDrawPhase(nextAlive) and not self:willSkipPlayPhase(nextAlive)
		and not nextAlive:hasSkill("luoshen")
		and not nextAlive:hasSkill("tuxi") and not (nextAlive:hasSkill("qiaobian") and nextAlive:getHandcardNum()>0) then
		if (peach and valuable==peach) or (ex_nihilo and valuable==ex_nihilo) then
			self.gongxinchoice = "put"
			return valuable
		end
		if jink and valuable==jink and getCardsNum("Jink",nextAlive)<1 then
			self.gongxinchoice = "put"
			return valuable
		end
		if nullification and valuable==nullification and getCardsNum("Nullification",nextAlive)<1 then
			self.gongxinchoice = "put"
			return valuable
		end
		if slash and valuable==slash and self:hasCrossbowEffect(nextAlive) then
			self.gongxinchoice = "put"
			return valuable
		end
	end

	local card = sgs.Sanguosha:getCard(valuable)
	local keep = false
	if card:isKindOf("Slash") or card:isKindOf("Jink")
		or card:isKindOf("EquipCard")
		or card:isKindOf("Disaster") or card:isKindOf("GlobalEffect") or card:isKindOf("Nullification")
		or target:isLocked(card) then
		keep = true
	end
	self.gongxinchoice = (target:objectName()==nextAlive:objectName() and keep) and "put" or "discard"
	return valuable
end

sgs.ai_skill_choice.gongxin = function(self,choices)
	return self.gongxinchoice or "discard"
end

sgs.ai_use_value.GongxinCard = 8.5
sgs.ai_use_priority.GongxinCard = 9.5
sgs.ai_card_intention.GongxinCard = 80

sgs.ai_skill_invoke.qinyin = function(self,data)
	self:sort(self.friends,"hp")
	self:sort(self.enemies,"hp")
	local up = 0
	local down = 0

	for _,friend in sgs.list(self.friends)do
		down = down-10
		up = up+(friend:isWounded() and 10 or 0)
		if self:hasSkills(sgs.masochism_skill,friend) then
			down = down-5
			if friend:isWounded() then up = up+5 end
		end
		if self:needToLoseHp(friend,nil,nil,true) then down = down+5 end
		if self:needToLoseHp(friend,nil,nil,true,true) and friend:isWounded() then up = up-5 end

		if self:isWeak(friend) then
			if friend:isWounded() then up = up+10+(friend:isLord() and 20 or 0) end
			down = down-10-(friend:isLord() and 40 or 0)
			if friend:getHp()<=1 and not friend:hasSkill("buqu") or friend:getPile("buqu"):length()>4 then
				down = down-20-(friend:isLord() and 40 or 0)
			end
		end
	end

	for _,enemy in sgs.list(self.enemies)do
		down = down+10
		up = up-(enemy:isWounded() and 10 or 0)
		if self:hasSkills(sgs.masochism_skill,enemy) then
			down = down+10
			if enemy:isWounded() then up = up-10 end
		end
		if self:needToLoseHp(enemy,nil,nil,true) then down = down-5 end
		if self:needToLoseHp(enemy,nil,nil,true,true) and enemy:isWounded() then up = up-5 end

		if self:isWeak(enemy) then
			if enemy:isWounded() then up = up-10 end
			down = down+10
			if enemy:getHp()<=1 and not enemy:hasSkill("buqu") then
				down = down+10+((enemy:isLord() and #self.enemies>1) and 20 or 0)
			end
		end
	end

	if down>0 then
		sgs.ai_skill_choice.qinyin = "down"
		return true
	elseif up>0 then
		sgs.ai_skill_choice.qinyin = "up"
		return true
	end
	return false
end

local yeyan_skill = {}
yeyan_skill.name = "yeyan"
table.insert(sgs.ai_skills,yeyan_skill)
yeyan_skill.getTurnUseCard = function(self)
	if self.player:getHandcardNum()>=4 then
		local spade,club,heart,diamond
		for _,card in sgs.list(self.player:getHandcards())do
			if card:getSuit()==sgs.Card_Spade then spade = true
			elseif card:getSuit()==sgs.Card_Club then club = true
			elseif card:getSuit()==sgs.Card_Heart then heart = true
			elseif card:getSuit()==sgs.Card_Diamond then diamond = true
			end
		end
		if spade and club and diamond and heart then
			self:sort(self.enemies,"hp")
			local target_num = 0
			for _,enemy in sgs.list(self.enemies)do
				if ((enemy:hasArmorEffect("vine") or enemy:getHp()<=3) and not enemy:isChained())
				or (enemy:isChained() and self:isGoodChainTarget(enemy,nil,nil,3))
				then target_num = target_num+1 end
			end
			if target_num>=1 then
				return sgs.Card_Parse("@GreatYeyanCard=.")
			end
		end
	end

	self.yeyanchained = false
	if self.player:getHp()+self:getCardsNum("Peach")+self:getCardsNum("Analeptic")<=2 then
		return sgs.Card_Parse("@SmallYeyanCard=.")
	end
	local target_num = 0
	local chained = 0
	for _,enemy in sgs.list(self.enemies)do
                if ((enemy:hasArmorEffect("vine") or enemy:getMark("&kuangfeng")>0) or enemy:getHp()<=1)
			and not (self.role=="renegade" and enemy:isLord()) then
			target_num = target_num+1
		end
	end
	for _,enemy in sgs.list(self.enemies)do
		if enemy:isChained() and self:isGoodChainTarget(enemy)
		then
			if chained==0 then target_num = target_num +1 end
			chained = chained+1
		end
	end
	self.yeyanchained = (chained>1)
	if target_num>2 or (target_num>1 and self.yeyanchained) or
	(#self.enemies+1==self.room:alivePlayerCount() and self.room:alivePlayerCount()<sgs.Sanguosha:getPlayerCount(self.room:getMode())) then
		return sgs.Card_Parse("@SmallYeyanCard=.")
	end
end

sgs.ai_skill_use_func.GreatYeyanCard = function(card,use,self)
	if self.role=="lord" and (sgs.turncount<=1 or sgs.playerRoles["rebel"]>#self:getChainedEnemies() or self:getAllPeachNum()<4-self.player:getHp()) then
		return
	end
	if self.role=="renegade" and self.player:aliveCount()>2 and self:getCardsNum("Peach")<3-self.player:getHp() then return end
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards,true)
	local need_cards = {}
	local spade,club,heart,diamond
	for _,card in sgs.list(cards)do
		if card:getSuit()==sgs.Card_Spade and not spade then spade = true table.insert(need_cards,card:getId())
		elseif card:getSuit()==sgs.Card_Club and not club then club = true table.insert(need_cards,card:getId())
		elseif card:getSuit()==sgs.Card_Heart and not heart then heart = true table.insert(need_cards,card:getId())
		elseif card:getSuit()==sgs.Card_Diamond and not diamond then diamond = true table.insert(need_cards,card:getId())
		end
	end
	if #need_cards<4 then return end
	local greatyeyan = sgs.Card_Parse("@GreatYeyanCard="..table.concat(need_cards,"+"))
	assert(greatyeyan)

	local first
	self:sort(self.enemies,"hp")
	for _,enemy in sgs.list(self.enemies)do
		if not enemy:hasArmorEffect("silver_lion") and self:objectiveLevel(enemy)>3
		and self:damageIsEffective(enemy,sgs.DamageStruct_Fire)
		and not (enemy:hasSkill("tianxiang") and enemy:getHandcardNum()>0)
		and enemy:isChained() and self:isGoodChainTarget(enemy,nil,nil,3)
		then
            if enemy:hasArmorEffect("vine") or enemy:getMark("&kuangfeng")>0
			then
				use.card = greatyeyan
				if use.to then
					use.to:append(enemy)
					use.to:append(enemy)
					use.to:append(enemy)
				end
				return
			elseif not first then first = enemy end
		end
	end
	if first then
		use.card = greatyeyan
		if use.to then
			use.to:append(first)
			use.to:append(first)
			use.to:append(first)
		end
		return
	end

	local second
	for _,enemy in sgs.list(self.enemies)do
		if not enemy:hasArmorEffect("silver_lion") and self:objectiveLevel(enemy)>3 and self:damageIsEffective(enemy,sgs.DamageStruct_Fire)
			and not (enemy:hasSkill("tianxiang") and enemy:getHandcardNum()>0) and not enemy:isChained() then
                        if enemy:hasArmorEffect("vine") or enemy:getMark("&kuangfeng")>0 then
				use.card = greatyeyan
				if use.to then
					use.to:append(enemy)
					use.to:append(enemy)
					use.to:append(enemy)
				end
				return
			elseif not second then second = enemy end
		end
	end
	if second then
		use.card = greatyeyan
		if use.to then
			use.to:append(second)
			use.to:append(second)
			use.to:append(second)
		end
		return
	end
end

sgs.ai_use_value.GreatYeyanCard = 8
sgs.ai_use_priority.GreatYeyanCard = 9

sgs.ai_card_intention.GreatYeyanCard = 200

sgs.ai_skill_use_func.SmallYeyanCard = function(card,use,self)
	if self.player:getMark("@flame")==0 then return end
	local targets = sgs.SPlayerList()
	self:sort(self.enemies,"hp")
	for _,enemy in sgs.list(self.enemies)do
		if not (enemy:hasSkill("tianxiang") and enemy:getHandcardNum()>0) and self:damageIsEffective(enemy,sgs.DamageStruct_Fire)
        and enemy:isChained() and self:isGoodChainTarget(enemy) and (enemy:hasArmorEffect("vine") or enemy:getMark("&kuangfeng")>0)
		then
			targets:append(enemy)
			if targets:length()>=3 then break end
		end
	end
	if targets:length()<3 then
		for _,enemy in sgs.list(self.enemies)do
			if not targets:contains(enemy)
			and not (enemy:hasSkill("tianxiang") and enemy:getHandcardNum()>0)
			and self:damageIsEffective(enemy,sgs.DamageStruct_Fire)
			and enemy:isChained() and self:isGoodChainTarget(enemy)
			then
				targets:append(enemy)
				if targets:length()>=3 then break end
			end
		end
	end
	if targets:length()<3 then
		for _,enemy in sgs.list(self.enemies)do
			if not targets:contains(enemy)
				and not (enemy:hasSkill("tianxiang") and enemy:getHandcardNum()>0) and self:damageIsEffective(enemy,sgs.DamageStruct_Fire)
                                and not enemy:isChained() and (enemy:hasArmorEffect("vine") or enemy:getMark("&kuangfeng")>0) then
				targets:append(enemy)
				if targets:length()>=3 then break end
			end
		end
	end
	if targets:length()<3 then
		for _,enemy in sgs.list(self.enemies)do
			if not targets:contains(enemy)
				and not (enemy:hasSkill("tianxiang") and enemy:getHandcardNum()>0) and self:damageIsEffective(enemy,sgs.DamageStruct_Fire)
				and not enemy:isChained() then
				targets:append(enemy)
				if targets:length()>=3 then break end
			end
		end
	end
	if targets:length()>0 then
		use.card = card
		if use.to then use.to = targets end
	end
end

sgs.ai_card_intention.SmallYeyanCard = 80
sgs.ai_use_priority.SmallYeyanCard = 2.3

sgs.ai_skill_discard.qixing = function(self,discard_num,optional,include_equip)
	local cards = sgs.QList2Table(self.player:getHandcards())
	local to_discard = {}
	local compare_func = function(a,b)
		return self:getKeepValue(a)<self:getKeepValue(b)
	end
	table.sort(cards,compare_func)
	for _,card in sgs.list(cards)do
		if #to_discard>=discard_num then break end
		table.insert(to_discard,card:getId())
	end

	return to_discard
end
sgs.ai_skill_use["@@qixing"] = function(self,prompt)
	local pile = self.player:getPile("stars")
	local piles = {}
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	local max_num = math.min(pile:length(),#cards)
	if pile:isEmpty() or (#cards==0) then
		return "."
	end
	for _,card_id in sgs.list(pile)do
		table.insert(piles,sgs.Sanguosha:getCard(card_id))
	end
	local exchange_to_pile = {}
	local exchange_to_handcard = {}
	self:sortByCardNeed(cards)
	self:sortByCardNeed(piles)
	for i = 1 ,max_num,1 do
		if self:cardNeed(piles[#piles])>self:cardNeed(cards[1]) then
			table.insert(exchange_to_handcard,piles[#piles])
			table.insert(exchange_to_pile,cards[1])
			table.removeOne(piles,piles[#piles])
			table.removeOne(cards,cards[1])
		else
			break
		end
	end
	if #exchange_to_handcard==0 then return "." end
	local exchange = {}

	for _,c in sgs.list(exchange_to_handcard)do
		table.insert(exchange,c:getId())
	end

	for _,c in sgs.list(exchange_to_pile)do
		table.insert(exchange,c:getId())
	end

	return "@QixingCard="..table.concat(exchange,"+")
end

sgs.ai_skill_use["@@kuangfeng"] = function(self,prompt)
	local friendly_fire
	for _,friend in sgs.list(self.friends_noself)do
                if friend:getMark("&kuangfeng")==0 and self:damageIsEffective(friend,sgs.DamageStruct_Fire) and friend:faceUp() and not self:willSkipPlayPhase(friend)
			and (friend:hasSkill("huoji") or friend:hasWeapon("fan") or (friend:hasSkill("yeyan") and friend:getMark("@flame")>0)) then
			friendly_fire = true
			break
		end
	end

	local is_chained = 0
	local target = {}
	for _,enemy in sgs.list(self.enemies)do
                if enemy:getMark("&kuangfeng")==0 and self:damageIsEffective(enemy,sgs.DamageStruct_Fire) then
			if enemy:isChained() then
				is_chained = is_chained+1
				table.insert(target,enemy)
			elseif enemy:hasArmorEffect("vine") then
				table.insert(target,1,enemy)
				break
			end
		end
	end
	local usecard=false
	if friendly_fire and is_chained>1 then usecard=true end
	self:sort(self.friends,"hp")
	if target[1] and not self:isWeak(self.friends[1]) then
		if target[1]:hasArmorEffect("vine") and friendly_fire then usecard = true end
	end
	if usecard then
		if not target[1] then table.insert(target,self.enemies[1]) end
		if target[1] then return "@KuangfengCard="..self.player:getPile("stars"):first().."->"..target[1]:objectName() else return "." end
	else
		return "."
	end
end

sgs.ai_card_intention.KuangfengCard = 80

sgs.ai_skill_use["@@dawu"] = function(self,prompt)
	self:sort(self.friends_noself,"hp")
	local targets = {}
	local lord = self.room:getLord()
	self:sort(self.friends_noself,"defense")
        if lord and lord:getMark("&dawu")==0 and self:isFriend(lord) and not sgs.isLordHealthy() and not self.player:isLord() and not lord:hasSkill("buqu")
		and not (lord:hasSkill("hunzi") and lord:getMark("hunzi")==0 and lord:getHp()>1) then
			table.insert(targets,lord:objectName())
	else
		for _,friend in sgs.list(self.friends_noself)do
                        if friend:getMark("&dawu")==0 and self:isWeak(friend) and not friend:hasSkill("buqu")
				and not (friend:hasSkill("hunzi") and friend:getMark("hunzi")==0 and friend:getHp()>1) then
					table.insert(targets,friend:objectName())
					break
			end
		end
	end
	if self.player:getPile("stars"):length()>#targets and self:isWeak() then table.insert(targets,self.player:objectName()) end
	if #targets>0 then
		local s = sgs.QList2Table(self.player:getPile("stars"))
		local length = #targets
		for i = 1,#s-length do
			table.remove(s,#s)
		end
		return "@DawuCard="..table.concat(s,"+").."->"..table.concat(targets,"+")
	end
	return "."
end

sgs.ai_card_intention.DawuCard = -70

function getGuixinValue(self,player)
	if player:isAllNude() then return 0 end
	local card_id = self:askForCardChosen(player,"hej","dummy")
	if self:isEnemy(player) then
		for _,card in sgs.list(player:getJudgingArea())do
			if card:getEffectiveId()==card_id then
				if card:isKindOf("YanxiaoCard") then return 0
				elseif card:isKindOf("Lightning") then
					if self:hasWizard(self.enemies,true) then return 0.8
					elseif self:hasWizard(self.friends,true) then return 0.4
					else return 0.5*(#self.friends)/(#self.friends+#self.enemies) end
				else
					return -0.2
				end
			end
		end
		for i = 0,3 do
			local card = player:getEquip(i)
			if card and card:getEffectiveId()==card_id then
				if card:isKindOf("Armor") and self:needToThrowArmor(player) then return 0 end
				local value = 0
				if self:getDangerousCard(player)==card_id then value = 1.5
				elseif self:getValuableCard(player)==card_id then value = 1.1
				elseif i==1 then value = 1
				elseif i==2 then value = 0.8
				elseif i==0 then value = 0.7
				elseif i==3 then value = 0.5
				end
				if player:hasSkills(sgs.lose_equip_skill) or self:doNotDiscard(player,"e",true) then value = value-0.2 end
				return value
			end
		end
		if self:needKongcheng(player) and player:getHandcardNum()==1 then return 0 end
		if not self:hasLoseHandcardEffective() then return 0.1
		else
			local index = player:hasSkills("jijiu|qingnang|leiji|nosleiji|jieyin|beige|kanpo|liuli|qiaobian|zhiheng|guidao|longhun|xuanfeng|tianxiang|noslijian|lijian") and 0.7 or 0.6
			local value = 0.2+index/(player:getHandcardNum()+1)
			if self:doNotDiscard(player,"h",true) then value = value-0.1 end
			return value
		end
	elseif self:isFriend(player) then
		for _,card in sgs.list(player:getJudgingArea())do
			if card:getEffectiveId()==card_id then
				if card:isKindOf("YanxiaoCard") then return 0
				elseif card:isKindOf("Lightning") then
					if self:hasWizard(self.enemies,true) then return 1
					elseif self:hasWizard(self.friends,true) then return 0.8
					else return 0.4*(#self.enemies)/(#self.friends+#self.enemies) end
				else
					return 1.5
				end
			end
		end
		for i = 0,3 do
			local card = player:getEquip(i)
			if card and card:getEffectiveId()==card_id then
				if card:isKindOf("Armor") and self:needToThrowArmor(player) then return 0.9 end
				local value = 0
				if i==1 then value = 0.1
				elseif i==2 then value = 0.2
				elseif i==0 then value = 0.25
				elseif i==3 then value = 0.25
				end
				if player:hasSkills(sgs.lose_equip_skill) then value = value+0.1 end
				if player:hasSkills("tuntian+zaoxian") then value = value+0.1 end
				return value
			end
		end
		if self:needKongcheng(player,true) and player:getHandcardNum()==1 then return 0.5
		elseif self:needKongcheng(player) and player:getHandcardNum()==1 then return 0.3 end
		if not self:hasLoseHandcardEffective() then return 0.2
		else
			local index = player:hasSkills("jijiu|qingnang|leiji|nosleiji|jieyin|beige|kanpo|liuli|qiaobian|zhiheng|guidao|longhun|xuanfeng|tianxiang|noslijian|lijian") and 0.5 or 0.4
			local value = 0.2-index/(player:getHandcardNum()+1)
			if player:hasSkills("tuntian+zaoxian") then value = value+0.1 end
			return value
		end
	end
	return 0.3
end

sgs.ai_skill_invoke.guixin = function(self,data)
	local damage = data:toDamage()
	local diaochans = self.room:findPlayersBySkillName("lihun")
	local lihun_eff = false
	for _,diaochan in sgs.list(diaochans)do
		if self:isEnemy(diaochan) then
			lihun_eff = true
			break
		end
	end
	local manjuan_eff = hasManjuanEffect(self.player)
	if lihun_eff and not manjuan_eff then return false end
	if not self.player:faceUp() then return true
	else
		if manjuan_eff then return false end
		local value = 0
		for _,player in sgs.list(self.room:getOtherPlayers(self.player))do
			value = value+getGuixinValue(self,player)
		end
		local left_num = damage.damage-self.player:getMark("guixinTimes")
		return value>=1.3 or left_num>0
	end
end

sgs.ai_need_damaged.guixin = function(self,attacker,player)
	if self.room:alivePlayerCount()<=3 or player:hasSkill("manjuan") then return false end
	local diaochan = self.room:findPlayerBySkillName("lihun")
	local drawcards = 0
	for _,aplayer in sgs.list(self.room:getOtherPlayers(player))do
		if aplayer:getCards("hej"):length()>0 then drawcards = drawcards+1 end
	end
	return not self:isLihunTarget(player,drawcards)
end

sgs.ai_skill_invoke.newguixin = function(self,data)
	local damage = data:toDamage()
	local diaochans = self.room:findPlayersBySkillName("lihun")
	local lihun_eff = false
	for _,diaochan in sgs.list(diaochans)do
		if self:isEnemy(diaochan) then
			lihun_eff = true
			break
		end
	end
	local manjuan_eff = hasManjuanEffect(self.player)
	if lihun_eff and not manjuan_eff then return false end
	if not self.player:faceUp() then return true
	else
		if manjuan_eff then return false end
		local value = 0
		for _,player in sgs.list(self.room:getOtherPlayers(self.player))do
			value = value+getGuixinValue(self,player)
		end
		local left_num = damage.damage-self.player:getMark("newguixinTimes")
		return value>=1.3 or left_num>0
	end
end

sgs.ai_need_damaged.newguixin = function(self,attacker,player)
	return sgs.ai_need_damaged.guixin(self,attacker,player)
end

sgs.ai_skill_choice.wumou = function(self,choices)
        if self.player:getMark("&wrath")>6 then return "discard" end
	if self.player:getHp()+self:getCardsNum("Peach")>3 then return "losehp"
	else return "discard"
	end
end

sgs.ai_use_revises.wumou = function(self,card,use)
	if card:isNDTrick() and self.player:getMark("&wrath")<7
	then
        if not (card:isKindOf("AOE") or card:isKindOf("IronChain") or card:isKindOf("Drowning"))
        and not (card:isKindOf("Duel") and self.player:getMark("&wrath")>0)
		then return false end
	end
end

local wuqian_skill = {}
wuqian_skill.name = "wuqian"
table.insert(sgs.ai_skills,wuqian_skill)
wuqian_skill.getTurnUseCard = function(self)
    if self.player:getMark("&wrath")<2 then return end
	return sgs.Card_Parse("@WuqianCard=.")
end

sgs.ai_skill_use_func.WuqianCard = function(wuqiancard,use,self)
	if self:getCardsNum("Slash")>0 and not self.player:hasSkill("wushuang") then
		for _,card in sgs.list(self.player:getHandcards())do
			if isCard("Duel",card,self.player) then
				local dummy_use = { isDummy = true,isWuqian = true,to = sgs.SPlayerList() }
				local duel = dummyCard("duel")
				self:useCardDuel(duel,dummy_use)
				if dummy_use.card and dummy_use.to:length()>0 and (self:isWeak(dummy_use.to:first()) and dummy_use.to:first():getHp()==1 or dummy_use.to:length()>1) then
					use.card = wuqiancard
					if use.to then use.to:append(dummy_use.to:first()) end
					return
				end
			end
		end
	end
end

sgs.ai_use_value.WuqianCard = 5
sgs.ai_use_priority.WuqianCard = 10
sgs.ai_card_intention.WuqianCard = 80

local shenfen_skill = {}
shenfen_skill.name = "shenfen"
table.insert(sgs.ai_skills,shenfen_skill)
shenfen_skill.getTurnUseCard = function(self)
	return sgs.Card_Parse("@ShenfenCard=.")
end

function SmartAI:canSaveSelf(player)
	if hasBuquEffect(player) then return true end
	if getCardsNum("Analeptic",player,self.player)>0 then return true end
	if player:hasSkills("jiushi|mobilejiushi") and player:faceUp() then return true end
	if player:hasSkills("jiuchi|mobilejiuchi|oljiuchi") then
		for _,c in sgs.list(player:getHandcards())do
			if c:getSuit()==sgs.Card_Spade then return true end
		end
	end
	return false
end

local function getShenfenUseValueOfHECards(self,to)
	local value = 0
	-- value of handcards
	local value_h = 0
	local hcard = to:getHandcardNum()
	if to:hasSkill("lianying") then
		hcard = hcard-0.9
	elseif to:hasSkills("shangshi|nosshangshi") then
		hcard = hcard-0.9*to:getLostHp()
	else
		local jwfy = self.room:findPlayerBySkillName("shoucheng")
		if jwfy and self:isFriend(jwfy,to) and (not self:isWeak(jwfy) or jwfy:getHp()>1) then hcard = hcard-0.9 end
	end
	value_h = (hcard>4) and 16/hcard or hcard
	if to:hasSkills("tuntian+zaoxian") then value = value*0.95 end
	if (to:hasSkill("kongcheng") or (to:hasSkill("zhiji") and to:getHp()>2 and to:getMark("zhiji")==0)) and not to:isKongcheng() then value_h = value_h*0.7 end
	if to:hasSkills("jijiu|qingnang|leiji|nosleiji|jieyin|beige|kanpo|liuli|qiaobian|zhiheng|guidao|longhun|xuanfeng|tianxiang|noslijian|lijian") then value_h = value_h*0.95 end
	value = value+value_h

	-- value of equips
	local value_e = 0
	local equip_num = to:getEquips():length()
	if to:hasArmorEffect("silver_lion") and to:isWounded() then equip_num = equip_num-1.1 end
	value_e = equip_num*1.1
	if to:hasSkills("kofxiaoji|xiaoji") then value_e = value_e*0.7 end
	if to:hasSkill("nosxuanfeng") then value_e = value_e*0.85 end
	if to:hasSkills("bazhen|yizhong") and to:getArmor() then value_e = value_e-1 end
	value = value+value_e

	return value
end

local function getDangerousShenGuanYu(self)
	local most = -100
	local target
	for _,player in sgs.list(self.room:getAllPlayers())do
                local nm_mark = player:getMark("&nightmare")
		if player:objectName()==self.player:objectName() then nm_mark = nm_mark+1 end
		if nm_mark>0 and nm_mark>most or (nm_mark==most and self:isEnemy(player)) then
			most = nm_mark
			target = player
		end
	end
	if target and self:isEnemy(target) then return true end
	return false
end

sgs.ai_skill_use_func.ShenfenCard = function(card,use,self)
	if (self.role=="loyalist" or self.role=="renegade") and self.room:getLord() and self:isWeak(self.room:getLord()) and not self.player:isLord() then return end
	local benefit = 0
	for _,player in sgs.list(self.room:getOtherPlayers(self.player))do
		if self:isFriend(player) then benefit = benefit-getShenfenUseValueOfHECards(self,player) end
		if self:isFriend(player) then benefit = benefit+getShenfenUseValueOfHECards(self,player) end
	end
	local friend_save_num = self:getSaveNum(true)
	local enemy_save_num = self:getSaveNum(false)
	local others = 0
	for _,player in sgs.list(self.room:getOtherPlayers(self.player))do
		if self:damageIsEffective(player,sgs.DamageStruct_Normal) then
			others = others+1
			local value_d = 3.5/math.max(player:getHp(),1)
			if player:getHp()<=1 then
				if player:hasSkill("wuhun") then
					local can_use = getDangerousShenGuanYu(self)
					if not can_use then return else value_d = value_d*0.1 end
				end
				if self:canSaveSelf(player) then
					value_d = value_d*0.9
				elseif self:isFriend(player) and friend_save_num>0 then
					friend_save_num = friend_save_num-1
					value_d = value_d*0.9
				elseif self:isEnemy(player) and enemy_save_num>0 then
					enemy_save_num = enemy_save_num-1
					value_d = value_d*0.9
				end
			end
			if player:hasSkill("fankui") then value_d = value_d*0.8 end
			if player:hasSkill("guixin") then
				if not player:faceUp() then
					value_d = value_d*0.4
				else
					value_d = value_d*0.8*(1.05-self.room:alivePlayerCount()/15)
				end
			end
			if self:needToLoseHp(player,self.player) or getBestHp(player)==player:getHp()-1 then value_d = value_d*0.8 end
			if self:isFriend(player) then benefit = benefit-value_d end
			if self:isEnemy(player) then benefit = benefit+value_d end
		end
	end
	if not self.player:faceUp() or self.player:hasSkills("jushou|nosjushou|neojushou|kuiwei") then
		benefit = benefit+1
	else
		local help_friend = false
		for _,friend in sgs.list(self.friends_noself)do
			if self:hasSkills("fangzhu|jilve",friend) then
				help_friend = true
				benefit = benefit+1
				break
			end
		end
		if not help_friend then benefit = benefit-0.5 end
	end
	if self.player:getKingdom()=="qun" then
		for _,player in sgs.list(self.room:getOtherPlayers(self.player))do
			if player:hasLordSkill("baonue") and self:isFriend(player) then
				benefit = benefit+0.2*self.room:alivePlayerCount()
				break
			end
		end
	end
	benefit = benefit+(others-7)*0.05
	if benefit>0 then
		use.card = card
	end
end

sgs.ai_use_value.ShenfenCard = 8
sgs.ai_use_priority.ShenfenCard = 5.3

sgs.dynamic_value.damage_card.ShenfenCard = true
sgs.dynamic_value.control_card.ShenfenCard = true

local longhun_skill={}
longhun_skill.name="longhun"
table.insert(sgs.ai_skills,longhun_skill)
longhun_skill.getTurnUseCard = function(self)
	if self.player:getHp()>1 then return end
	local cards = self:addHandPile("he")
	self:sortByUseValue(cards,true)
	for _,card in sgs.list(cards)do
		if card:getSuit()==sgs.Card_Diamond and self:slashIsAvailable() then
			return sgs.Card_Parse(("fire_slash:longhun[%s:%s]=%d"):format(card:getSuitString(),card:getNumberString(),card:getId()))
		end
	end
end

sgs.ai_view_as.longhun = function(card,player,card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if player:getHp()>1 or card_place==sgs.Player_PlaceSpecial then return end
	if card:getSuit()==sgs.Card_Diamond then
		return ("fire_slash:longhun[%s:%s]=%d"):format(suit,number,card_id)
	elseif card:getSuit()==sgs.Card_Club then
		return ("jink:longhun[%s:%s]=%d"):format(suit,number,card_id)
	elseif card:getSuit()==sgs.Card_Heart then
		return ("peach:longhun[%s:%s]=%d"):format(suit,number,card_id)
	elseif card:getSuit()==sgs.Card_Spade then
		return ("nullification:longhun[%s:%s]=%d"):format(suit,number,card_id)
	end
end

sgs.longhun_suit_value = {
	heart = 6.7,
	spade = 5,
	club = 4.2,
	diamond = 3.9,
}

function sgs.ai_cardneed.longhun(to,card,self)
	if to:getCardCount()>3 then return false end
	if to:isNude() then return true end
	return card:getSuit()==sgs.Card_Heart or card:getSuit()==sgs.Card_Spade
end

sgs.ai_skill_invoke.lianpo = true

function SmartAI:needBear(player)
	player = player or self.player
    return player:hasSkills("renjie+baiyin") and not player:hasSkill("jilve") and player:getMark("&bear")<4
end

sgs.ai_use_revises.renjie = function(self,card)
	if self.player:hasSkill("baiyin")
	and not self.player:hasSkill("jilve") and self.player:getMark("&bear")<4
	then
		if (card:isKindOf("Peach") or card:isKindOf("Armor")) and self.player:getLostHp()>1
		or card:isKindOf("TrickCard") and (card:targetFixed() and not card:isDamageCard() or card:canRecast() or ("snatch|collateral"):match(card:objectName()))
		then return end
		return false
	end
end

sgs.ai_skill_invoke.jilve_jizhi = function(self,data)
	local n = self.player:getMark("&bear")
	local use = (n>2 or self:getOverflow()>0)
	local card = data:toCardResponse().m_card
	card = card or data:toCardUse().card
	return use or card:isKindOf("ExNihilo")
end

sgs.ai_skill_invoke.jilve_guicai = function(self,data)
	local n = self.player:getMark("&bear")
	local use = (n>2 or self:getOverflow()>0)
	local judge = data:toJudge()
	if not self:needRetrial(judge) then return false end
	return (use or judge.who==self.player or judge.reason=="lightning")
	and self:getRetrialCardId(sgs.QList2Table(self.player:getHandcards()),judge)~=-1
end

sgs.ai_skill_invoke.jilve_fangzhu = function(self,data)
	return sgs.ai_skill_playerchosen.fangzhu(self,self.room:getOtherPlayers(self.player))~=nil
	or sgs.ai_skill_playerchosen.mobilefangzhu(self,self.room:getOtherPlayers(self.player))~=nil
end

sgs.ai_skill_choice._jilve = function(self,choices)
	choices = choices:split("+")
	if table.contains(choices,"jilve_tenyearjizhi") then return "jilve_tenyearjizhi" end
	if table.contains(choices,"jilve_mobilefangzhu") then
		if sgs.ai_skill_playerchosen.mobilefangzhu(self,self.room:getOtherPlayers(self.player))~=nil then
			return "jilve_mobilefangzhu"
		end
		return "fangzhu"
	end
	return choices[2]
end

local jilve_skill = {}
jilve_skill.name = "jilve"
table.insert(sgs.ai_skills,jilve_skill)
jilve_skill.getTurnUseCard = function(self)
	local wanshadone = self.player:hasFlag("JilveWansha")
	if not wanshadone and not self.player:hasSkills("wansha|olwansha")
	then
		self:sort(self.enemies,"hp")
		for _,enemy in sgs.list(self.enemies)do
			if not (enemy:hasSkill("kongcheng") and enemy:isKongcheng()) and self:isWeak(enemy) and self:damageMinusHp(enemy,1)>0
			and #self.enemies>1
			then
				sgs.ai_skill_choice.jilve = (sgs.Sanguosha:getSkill("olwansha") and "jilve_olwansha") or "wansha"
				sgs.ai_use_priority.JilveCard = 8
				return sgs.Card_Parse("@JilveCard=.")
			end
		end
	end
	if not self.player:hasFlag("JilveZhiheng")
	then
		sgs.ai_skill_choice.jilve = "jilve_tenyearzhiheng"
		sgs.ai_use_priority.JilveCard = sgs.ai_use_priority.TenyearZhihengCard
		local card = sgs.Card_Parse("@TenyearZhihengCard=.")
		local dummy_use = {isDummy = true}
		self:useSkillCard(card,dummy_use)
		if dummy_use.card then return sgs.Card_Parse("@JilveCard=.") end
	elseif not wanshadone and not self.player:hasSkill("wansha")
	then
		self:sort(self.enemies,"hp")
		for _,enemy in sgs.list(self.enemies)do
			if not (enemy:hasSkill("kongcheng") and enemy:isKongcheng())
			and self:isWeak(enemy) and self:damageMinusHp(enemy,1)>0
			and #self.enemies>1
			then
				sgs.ai_skill_choice.jilve = "wansha"
				sgs.ai_use_priority.JilveCard = 8
				return sgs.Card_Parse("@JilveCard=.")
			end
		end
	end
end

sgs.ai_skill_use_func.JilveCard=function(card,use,self)
	use.card = card
end

sgs.ai_skill_use["@zhiheng"]=function(self,prompt)
	local card=sgs.Card_Parse("@ZhihengCard=.")
	local dummy_use={isDummy=true}
	self:useSkillCard(card,dummy_use)
	if dummy_use.card then return (dummy_use.card):toString().."->." end
	return "."
end

sgs.ai_skill_use["@tenyearzhiheng"]=function(self,prompt)
	local card=sgs.Card_Parse("@TenyearZhihengCard=.")
	local dummy_use={isDummy=true}
	self:useSkillCard(card,dummy_use)
	if dummy_use.card then return (dummy_use.card):toString().."->." end
	return "."
end

sgs.ai_suit_priority.wushen= "club|spade|diamond|heart"

--结营
sgs.ai_skill_playerchosen.jieying = function(self,targets)
	self:sort(self.enemies,"defense")
	for _,enemy in sgs.list(self.enemies)do
		if not enemy:isChained() and enemy:hasSkill("lianhuo") then return enemy end
	end
	for _,enemy in sgs.list(self.enemies)do
		if not enemy:isChained() then return enemy end
	end
	targets = sgs.QList2Table(targets)
	for _,enemy in sgs.list(targets)do
		if not self:isFriend(enemy) and not enemy:isChained() then return enemy end
	end
	return targets[1]
end

sgs.ai_target_revises.jieying = function(to,card,self,use)
    if card:isKindOf("IronChain")
	then return true end
end

--摧克
sgs.ai_skill_playerchosen.cuike = function(self,targets)
	local mark = self.player:getMark("&junlve")
	if mark % 2==1 then
		local target = self:findPlayerToDamage(1,self.player,sgs.DamageStruct_Normal,targets,true)
		if target then return target end
		self:sort(self.enemies,"hp")
		for _,enemy in sgs.list(self.enemies)do
			if self:canDamage(enemy) then return enemy end
		end
		for _,friend in sgs.list(self.friends)do
			if self:canDamage(friend) then return friend end
		end
	else
		self:sort(self.enemies,"defense")
		for _,friend in sgs.list(self.friends_noself)do
			if self:needToThrowCard(friend,"j") then
				return friend
			end
		end
		for _,enemy in sgs.list(self.enemies)do
			if not self:doNotDiscard(enemy) and not enemy:isChained() and not enemy:hasSkills("qianjie|jieying") then
				return enemy
			end
		end
		for _,enemy in sgs.list(self.enemies)do
			if not self:doNotDiscard(enemy) then
				return enemy
			end
		end
		for _,friend in sgs.list(self.friends_noself)do
			if self:needToThrowCard(friend,"hej",true) and friend:isChained() then
				return friend
			end
		end
	end
	return nil
end

sgs.ai_skill_invoke.cuike = function(self,data)
	self:updatePlayers()
	self:sort(self.friends_noself,"hp")
	
	local has_weak_friend = false
	for _,friend in sgs.list(self.friends_noself)do
		if self:isWeak(friend) then
			has_weak_friend = true
		end
	end
	
	if self.player:getRole()=="renegade" then return not self:isWeak(self.room:getLord()) end
	if self.player:getRole()=="loyalist" or self.player:isLord() then return not has_weak_friend end
	if self.player:getRole()=="rebel" then
		if has_weak_friend then
			local friend_peach_num = 0
			local one_hp_friend_analeptic_num = 0
			local one_hp_friend_num = 0
			local has_analeptic_friend = {}
			for _,friend in sgs.list(self.friends)do
				for _,c in sgs.list(friend:getCards("h"))do
					if c:isKindOf("Peach") then
						friend_peach_num = friend_peach_num+1
					end
				end
			end
			for _,friend in sgs.list(self.friends_noself)do
				if friend:getHp()==1 then
					one_hp_friend_num = one_hp_friend_num+1
					for _,c in sgs.list(friend:getCards("h"))do
						if c:isKindOf("Analeptic") and not table.contains(has_analeptic_friend,friend) then
							table.insert(has_analeptic_friend,friend)
						end
					end
				end
			end
			if friend_peach_num<one_hp_friend_num and #has_analeptic_friend<one_hp_friend_num then return true end
			return false
		end
	end
	return true
end

--绽火
local zhanhuo_skill = {}
zhanhuo_skill.name = "zhanhuo"
table.insert(sgs.ai_skills,zhanhuo_skill)
zhanhuo_skill.getTurnUseCard = function(self,inclusive)
	for _,friend in sgs.list(self.friends)do
		if self:isWeak(friend) and friend:isChained()
		and self:damageIsEffective(friend,sgs.DamageStruct_Fire,self.player)
		then return end
	end
	return sgs.Card_Parse("@ZhanhuoCard=.")
end

sgs.ai_skill_use_func.ZhanhuoCard = function(card,use,self)
	self:updatePlayers()
	local can_zhanhuo = false
	self:sort(self.enemies,"hp")
	for _,enemy in sgs.list(self.enemies)do
		if enemy:isChained() and self:canDamage(enemy,self.player,false,sgs.DamageStruct_Fire) then
			if enemy:getHp()<2 and self:isWeak(enemy) then
				can_zhanhuo = true
				break
			elseif self:isWeak() then
				can_zhanhuo = true
				break
			end
		end
	end
	if not can_zhanhuo then return end
	local targets = {}
	for _,enemy in sgs.list(self.enemies)do
		if #targets<self.player:getMark("&junlve") and enemy:isChained() and not self:doNotDiscard(enemy,"e") and
			self:canDamage(enemy,self.player,false,sgs.DamageStruct_Fire) then
			table.insert(targets,enemy)
		end
	end
	for _,friend in sgs.list(self.friends)do
		if #targets<self.player:getMark("&junlve") and friend:isChained() and not self:keepWoodenOx(friend)
		and self:needToThrowCard(friend,"e") then
			table.insert(targets,friend)
		end
	end
	if #targets==0 then return end
	use.card = card
	if use.to then
		for i = 1,#targets,1 do
			use.to:append(targets[i])
		end
	end
end

sgs.ai_skill_playerchosen.zhanhuo = function(self,targets)
	local target = self:findPlayerToDamage(1,self.player,sgs.DamageStruct_Fire,targets,true)
	if target then return target end
	return target:first()
end

sgs.ai_use_priority.ZhanhuoCard = 3
sgs.ai_use_value.ZhanhuoCard = 3

--夺锐
sgs.ai_skill_invoke.duorui = function(self,data)
	local player = data:toPlayer()
	if self:isFriend(player) then return false end
	local name = player:getGeneralName()
	local g = sgs.Sanguosha:getGeneral(name)
	if not g then return false end
	--[[if self:isFriend(player) then
		for _,sk in sgs.list(g:getSkillList())do
			if not sk:isVisible() then continue end
			if sk:isLimitedSkill() then continue end
			if sk:getFrequency()==sgs.Skill_Wake then continue end
			if sk:isLordSkill() then continue end
			if string.find(sgs.bad_skills,sk:objectName()) and player:hasSkill(sk) then return true end
		end
		if player:getGeneral2() then
			local name2 = player:getGeneral2Name()
			local g2 = sgs.Sanguosha:getGeneral(name2)
			if g2 then
				for _,sk in sgs.list(g2:getSkillList())do
					if not sk:isVisible() then continue end
					if sk:isLimitedSkill() then continue end
					if sk:getFrequency()==sgs.Skill_Wake then continue end
					if sk:isLordSkill() then continue end
					if string.find(sgs.bad_skills,sk:objectName()) and player:hasSkill(sk) then return true end
				end
			end
		end
	end]]
	if not self:isFriend(player) then
		for _,sk in sgs.list(g:getSkillList())do
			if not sk:isVisible() then continue end
			if sk:isLimitedSkill() then continue end
			if sk:getFrequency()==sgs.Skill_Wake then continue end
			if sk:isLordSkill() then continue end
			if string.find(sgs.bad_skills,sk:objectName()) then continue end
			return true
		end
		if player:getGeneral2() then
			local name2 = player:getGeneral2Name()
			local g2 = sgs.Sanguosha:getGeneral(name2)
			if g2 then
				for _,sk in sgs.list(g2:getSkillList())do
					if not sk:isVisible() then continue end
					if sk:isLimitedSkill() then continue end
					if sk:getFrequency()==sgs.Skill_Wake then continue end
					if sk:isLordSkill() then continue end
					if string.find(sgs.bad_skills,sk:objectName()) then continue end
					return true
				end
			end
		end
	end
	return false
end

sgs.ai_skill_choice.duorui_area = function(self,choices,data)
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
end

sgs.ai_skill_choice.duorui = function(self,choices,data)
	local player = data:toDamage().to
	local skills = choices:split("+")
	--[[if self:isFriend(player) then
		for _,sk in sgs.list(skills)do
			if string.find(sgs.bad_skills,sk) and player:hasSkill(sk) then return sk end
		end
		return skills[1]
	end]]
	
	for _,sk in sgs.list(skills)do
		if self:isValueSkill(sk,player,true) then
			return sk
		end
	end
	
	for _,sk in sgs.list(skills)do
		if self:isValueSkill(sk,player) then
			return sk
		end
	end
	
	local not_bad_skills = {}
	for _,sk in sgs.list(skills)do
		if string.find(sgs.bad_skills,sk) then continue end
		table.insert(not_bad_skills,sk)
	end
	if #not_bad_skills>0 then
		return not_bad_skills[math.random(1,#not_bad_skills)]
	end
	
	return skills[math.random(1,#skills)]
end

--止啼
sgs.ai_skill_choice.zhiti = function(self,choices,data)
	local items = choices:split("+")
	if not self.player:hasEquipArea(1) then
		return "1"
	elseif not self.player:hasEquipArea(0) then
		return "0"
	elseif not self.player:hasEquipArea(2) then
		return "2"
	elseif not self.player:hasEquipArea(3) then
		return "3"
	elseif not self.player:hasEquipArea(4) then
		return "4"
	else
		return items[1]
	end
end

--魄袭
local poxi_skill = {}
poxi_skill.name = "poxi"
table.insert(sgs.ai_skills,poxi_skill)
poxi_skill.getTurnUseCard = function(self,inclusive)
	return sgs.Card_Parse("@PoxiCard=.")
end

sgs.ai_skill_use_func.PoxiCard = function(card,use,self)
	self:updatePlayers()
	if #self.enemies<=0 then return end
	local target = nil
	self:sort(self.enemies,"handcard")
	self.enemies = sgs.reverse(self.enemies)
	for _,p in sgs.list(self.enemies)do
		if self:doNotDiscard(p,"h") then continue end
		target = p
		break
	end
	if not target then return end
	self.poxi_target = nil
	if target:getHandcardNum()>0 then
		use.card = card
		self.poxi_target = target
		if use.to then use.to:append(target) end
	end
end

sgs.ai_skill_use["@@poxi"] = function(self,prompt)
	if self.poxi_target then
		local target_handcards = sgs.QList2Table(self.poxi_target:getCards("h"))
		self:sortByUseValue(target_handcards,inverse)
		local handcards = sgs.QList2Table(self.player:getCards("h"))
		local discard_cards = {}
		local spade_check = true
		local heart_check = true
		local club_check = true
		local diamond_check = true
		local target_discard_count = 0
		
		for _,c in sgs.list(target_handcards)do
			if spade_check and c:getSuit()==sgs.Card_Spade then
				spade_check = false
				table.insert(discard_cards,c:getEffectiveId())
			elseif heart_check and c:getSuit()==sgs.Card_Heart then
				heart_check = false
				table.insert(discard_cards,c:getEffectiveId())
			elseif club_check and c:getSuit()==sgs.Card_Club then
				club_check = false
				table.insert(discard_cards,c:getEffectiveId())
			elseif diamond_check and c:getSuit()==sgs.Card_Diamond then
				diamond_check = false
				table.insert(discard_cards,c:getEffectiveId())
			end
			target_discard_count = #discard_cards
		end
		
		for _,c in sgs.list(handcards)do
			if not c:isKindOf("Peach")
			and not c:isKindOf("Duel")
			and not c:isKindOf("Indulgence")
			and not c:isKindOf("SupplyShortage")
			and not (self:getCardsNum("Jink")==1 and c:isKindOf("Jink"))
			and not (self:getCardsNum("Analeptic")==1 and c:isKindOf("Analeptic"))
			then
				if spade_check and c:getSuit()==sgs.Card_Spade then
					spade_check = false
					table.insert(discard_cards,c:getEffectiveId())
				elseif heart_check and c:getSuit()==sgs.Card_Heart then
					heart_check = false
					table.insert(discard_cards,c:getEffectiveId())
				elseif club_check and c:getSuit()==sgs.Card_Club then
					club_check = false
					table.insert(discard_cards,c:getEffectiveId())
				elseif diamond_check and c:getSuit()==sgs.Card_Diamond then
					diamond_check = false
					table.insert(discard_cards,c:getEffectiveId())
				end
			end
		end
		
		if target_discard_count==4 and not self.player:isWounded() then return "." end
		if 4-target_discard_count==1 and self.player:getHandcardNum()>self.player:getMaxCards() then return "." end
		
		if #discard_cards==4 then
			return "@PoxiDisCard="..table.concat(discard_cards,"+")
		end
	end
	return "."
end

sgs.ai_use_priority.PoxiCard = 3
sgs.ai_use_value.PoxiCard = 3
sgs.ai_card_intention.PoxiCard = 50

--劫营
sgs.ai_skill_playerchosen.jieyingg = function(self,targets)
	self:updatePlayers()
	self:sort(self.enemies,"handcard")
	self.enemies = sgs.reverse(self.enemies)
	
	for _,enemy in sgs.list(self.enemies)do
		if enemy:containsTrick("indulgence") then
			return enemy
		end
	end
	local second
	for _,enemy in sgs.list(self.enemies)do
		if enemy:faceUp() and not enemy:hasSkills("tenyearliegong|tieji") and not self:needKongcheng(enemy) 
		and not (enemy:hasSkills("rende|nosrende|olrende|tenyearrende|mingjian|newmingjian|mizhao") and self:findFriendsByType(sgs.Friend_Draw,enemy)) then
			if not enemy:inMyAttackRange(self.player) or enemy:getHandcardNum()>3 or self:hasSkills(sgs.notActive_cardneed_skill,enemy) then return enemy end
			if not second then second = enemy end
		end
	end
	self:sort(self.friends_noself,"handcard")
	for _,friend in sgs.list(self.friends_noself)do
		if self:needKongcheng(friend) or friend:hasSkills("tenyearliegong|tieji|rende|nosrende|olrende|tenyearrende|mingjian|newmingjian|mizhao") then
			return friend
		end
	end
	if second then return second end
	return nil
end

--OL武神
sgs.ai_suit_priority.olwushen= "club|spade|diamond|heart"

--新龙魂
local newlonghun_skill = {}
newlonghun_skill.name = "newlonghun"
table.insert(sgs.ai_skills,newlonghun_skill)
newlonghun_skill.getTurnUseCard = function(self,inclusive)
	local usable_cards = self:addHandPile()
	local equips = sgs.QList2Table(self.player:getCards("e"))
	for _,e in sgs.list(equips)do
		if e:isKindOf("DefensiveHorse") or e:isKindOf("OffensiveHorse") then
			table.insert(usable_cards,e)
		end
	end
	for _,id in sgs.list(self.player:getHandPile())do
		table.insert(usable_cards,sgs.Sanguosha:getCard(id))
	end
	self:sortByUseValue(usable_cards,true)
	local two_diamond_cards = {}
	for _,c in sgs.list(usable_cards)do
		if c:getSuit()==sgs.Card_Diamond and #two_diamond_cards<2 and not c:isKindOf("Peach") and not (c:isKindOf("WoodenOx") and self.player:getPile("wooden_ox"):length()>0) then
			table.insert(two_diamond_cards,c:getEffectiveId())
		end
	end
	if #two_diamond_cards==2 and self:slashIsAvailable() and self:getOverflow()>1 then
		return sgs.Card_Parse(("fire_slash:newlonghun[%s:%s]=%d+%d"):format("to_be_decided",0,two_diamond_cards[1],two_diamond_cards[2]))
	end
	for _,c in sgs.list(usable_cards)do
		if c:getSuit()==sgs.Card_Diamond and self:slashIsAvailable() and not c:isKindOf("Peach") and not (c:isKindOf("Jink") and self:getCardsNum("Jink")<3) and not (c:isKindOf("WoodenOx") and self.player:getPile("wooden_ox"):length()>0) then
			return sgs.Card_Parse(("fire_slash:newlonghun[%s:%s]=%d"):format(c:getSuitString(),c:getNumberString(),c:getEffectiveId()))
		end
	end
	for _,c in sgs.list(usable_cards)do
		if c:getSuit()==sgs.Card_Heart and self.player:getMark("Global_PreventPeach")==0 and not c:isKindOf("Peach") then
			return sgs.Card_Parse(("peach:newlonghun[%s:%s]=%d"):format(c:getSuitString(),c:getNumberString(),c:getEffectiveId()))
		end
	end
end

sgs.ai_view_as.newlonghun = function(card,player,card_place,class_name)
	if card_place==sgs.Player_PlaceSpecial then return end
	local current = player:getRoom():getCurrent()
	local usable_cards = sgs.QList2Table(player:getCards("he"))
	for _,id in sgs.list(player:getHandPile())do
		table.insert(usable_cards,sgs.Sanguosha:getCard(id))
	end
	local two_club_cards = {}
	local two_heart_cards = {}
	for _,c in sgs.list(usable_cards)do
		if c:getSuit()==sgs.Card_Club and #two_club_cards<2 then
			table.insert(two_club_cards,c:getEffectiveId())
		elseif c:getSuit()==sgs.Card_Heart and #two_heart_cards<2 then
			table.insert(two_heart_cards,c:getEffectiveId())
		end
	end
	
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	
	if #two_club_cards==2 and current and not current:isNude() and current:getWeapon() and current:getWeapon():isKindOf("Crossbow") then
		return ("jink:newlonghun[%s:%s]=%d+%d"):format("to_be_decided",0,two_club_cards[1],two_club_cards[2])
	elseif card:getSuit()==sgs.Card_Club then
		return ("jink:newlonghun[%s:%s]=%d"):format(suit,number,card_id)
	end
	
	local dying = player:getRoom():getCurrentDyingPlayer()
	if #two_heart_cards==2 and dying and not dying:hasSkill("newjuejing") then
		return ("peach:newlonghun[%s:%s]=%d+%d"):format("to_be_decided",0,two_heart_cards[1],two_heart_cards[2])
	elseif card:getSuit()==sgs.Card_Heart and player:getMark("Global_PreventPeach")==0 then
		return ("peach:newlonghun[%s:%s]=%d"):format(suit,number,card_id)
	end
	
	if card:getSuit()==sgs.Card_Diamond and not (card:isKindOf("WoodenOx") and player:getPile("wooden_ox"):length()>0) then
		return ("fire_slash:newlonghun[%s:%s]=%d"):format(suit,number,card_id)
	elseif card:getSuit()==sgs.Card_Spade then
		return ("nullification:newlonghun[%s:%s]=%d"):format(suit,number,card_id)
	end
end

sgs.newlonghun_suit_value = sgs.longhun_suit_value

function sgs.ai_cardneed.newlonghun(to,card,self)
	if to:getCardCount()>3 then return false end
	if to:isNude() then return true end
	return card:getSuit()==sgs.Card_Heart or card:getSuit()==sgs.Card_Spade
end

sgs.ai_need_damaged.newlonghun = function(self,attacker,player)
	if player:getHp()>1 and player:hasSkill("newjuejing") then return true end
end

--OL夺锐
sgs.ai_skill_invoke.olduorui = function(self,data)
	local player = data:toPlayer()
	if self:isFriend(player) then return false end
	local name = player:getGeneralName()
	local g = sgs.Sanguosha:getGeneral(name)
	if not g then return false end
	for _,sk in sgs.list(g:getSkillList())do
		if not sk:isVisible() then continue end
		if string.find(sgs.bad_skills,sk:objectName()) then continue end
		return true
	end
	if player:getGeneral2() then
		local name2 = player:getGeneral2Name()
		local g2 = sgs.Sanguosha:getGeneral(name2)
		if g2 then
			for _,sk in sgs.list(g2:getSkillList())do
				if not sk:isVisible() then continue end
				if string.find(sgs.bad_skills,sk:objectName()) then continue end
				return true
			end
		end
	end
	return false
end

sgs.ai_skill_choice.olduorui = function(self,choices,data)
	local player = data:toDamage().to
	local skills = choices:split("+")
	
	for _,sk in sgs.list(skills)do
		if self:isValueSkill(sk,player,true) then
			return sk
		end
	end
	
	for _,sk in sgs.list(skills)do
		if self:isValueSkill(sk,player) then
			return sk
		end
	end
	
	local not_bad_skills = {}
	for _,sk in sgs.list(skills)do
		if string.find(sgs.bad_skills,sk) then continue end
		table.insert(not_bad_skills,sk)
	end
	if #not_bad_skills>0 then
		return not_bad_skills[math.random(1,#not_bad_skills)]
	end
	
	return skills[math.random(1,#skills)]
end

--OL止啼
function getEquipAreaNum(player)
	local num = 0
	if player:hasEquipArea(0) then num = num+1 end
	if player:hasEquipArea(1) then num = num+1 end
	if player:hasEquipArea(2) then num = num+1 end
	if player:hasEquipArea(3) then num = num+1 end
	if player:hasEquipArea(4) then num = num+1 end
	return num
end

function hasOnlyEquipArea(player,area)
	if not area then return false end
	if not player:hasEquipArea(area) then return false end
	for i = 0,4 do
		if i==area then continue end
		if player:hasEquipArea(i) then return false end
	end
	return true
end

function getOnlyEquipArea(player)
	local num = -1
	for i = 0,4 do
		if hasOnlyEquipArea(player,i) then return i end
	end
	return num
end

sgs.ai_skill_playerchosen.olzhiti = function(self,targets)
	local players = {}
	for _,p in sgs.list(targets)do
		if self:isFriend(p) and hasOnlyEquipArea(p,1) and p:getEquip(1) and self:needToThrowArmor(p) then return p end
		if self:isEnemy(p) and getOnlyEquipArea(p)>-1 and p:getEquip(getOnlyEquipArea(p)) and not self:doNotDiscard(p,"e") then
			table.insert(players,p)
		end
	end
	if #players>0 then
		self:sort(players,"defense")
		return players[1]
	end
	
	for _,p in sgs.list(targets)do
		if self:isEnemy(p) and p:hasEquipArea() and p:getEquips():isEmpty() and getOnlyEquipArea(p)>-1 then
			table.insert(players,p)
		end
	end
	if #players>0 then
		self:sort(players,"defense")
		return players[1]
	end
	
	for _,p in sgs.list(targets)do
		if self:isEnemy(p) and p:hasEquipArea() and p:getEquips():isEmpty() and p:hasSkills(sgs.lose_equip_skill) then
			table.insert(players,p)
		end
	end
	if #players>0 then
		self:sort(players,"defense")
		return players[1]
	end
	
	for _,p in sgs.list(targets)do
		if self:isEnemy(p) and p:hasEquipArea() and p:getEquips():isEmpty() then
			table.insert(players,p)
		end
	end
	if #players>0 then
		self:sort(players,"defense")
		return players[1]
	end
	
	for _,p in sgs.list(targets)do
		if self:isEnemy(p) and getEquipAreaNum(p)<=2*p:getEquips():length() and not self:doNotDiscard(p,"e") then
			table.insert(players,p)
		end
	end
	if #players>0 then
		self:sort(players,"defense")
		return players[1]
	end
	
	for _,p in sgs.list(targets)do
		if self:isEnemy(p) and getEquipAreaNum(p)<=2*p:getEquips():length() then
			table.insert(players,p)
		end
	end
	if #players>0 then
		self:sort(players,"defense")
		return players[1]
	end
	
	return nil
end

--储元
sgs.ai_skill_invoke.chuyuan = function(self,data)
	local player = data:toPlayer()
	if self.player:getPile("cychu"):length()==2 then
		if self.player:hasSkill("dengji") and self.player:getMark("dengji")<=0 then return self.player:getMaxHp()>1 end
		if self.player:hasSkill("tianxing") and self.player:getMark("tianxing")<=0 then return self.player:getMaxHp()>1 end
	end
	if self:doNotDiscard(player,"h") then return false end
	return true
end

sgs.ai_skill_discard.chuyuan = function(self,discard_num,min_num,optional,include_equip)
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	return {cards[1]:getEffectiveId()}
end

--天行
sgs.ai_skill_choice.tianxing = function(self,choices,data)  --待补充
	local skills = choices:split("+")
	local skills2 = {}
	if table.contains(skills,"tenyearzhiheng") then table.insert(skills2,"tenyearzhiheng") end
	if table.contains(skills,"olluanji") then table.insert(skills2,"olluanji") end
	if #self.friends_noself<=0 and #skills2>0 then
		return skills2[math.random(1,#skills2)]
	end
	return skills[math.random(1,#skills)]
end

--神赋
sgs.ai_skill_playerchosen.shenfu_ji = function(self,targets)
	local targets_table = self:findPlayerToDamage(1,self.player,sgs.DamageStruct_Thunder,targets,false,0,true)
	if #targets_table<=0 then return nil end
	if not self.player:isChained() or not self:isWeak() or not self:damageIsEffective(self.player,sgs.DamageStruct_Thunder,self.player) then return targets_table[1] end
	for _,p in sgs.list(targets_table)do
		if p:isChained() then continue end
		return p
	end
	return nil
end

sgs.ai_skill_playerchosen.shenfu_ou = function(self,targets)
	local targets_table1,targets_table2 = {},{}
	for _,target in sgs.list(targets)do
		if math.abs(target:getHandcardNum()-target:getHp())==1 then
			table.insert(targets_table1,target)
		else
			if self:isFriend(target) or (self:isEnemy(target) and not target:isKongcheng()) or (self:isEnemy(target) and self:needKongcheng(target,true)) then
				table.insert(targets_table2,target)
			end
		end
	end
	if #targets_table1>0 then
		self:sort(targets_table1,"defense")
		return targets_table1[1]
	end
	if #targets_table2>0 then
		self:sort(targets_table2,"defense")
		return targets_table2[1]
	end
	return nil
end

sgs.ai_skill_choice.shenfu = function(self,choices,data)
	local player = data:toPlayer()
	if self:isFriend(player) then
		if player:hasSkills("tuntian|mobiletuntian|oltuntian") and player:getHandcardNum()-player:getHp()==1 then
			return "discard"
		end
		return "draw"
	end
	if self:needKongcheng(player,true) then return "draw" end
	return "discard"
end

--神躯
sgs.ai_skill_choice.shenqu = function(self,choices,data)
	return true
end

--极武
function CanUsejiwu(self)
	if self:needBear() and self.player:getHandcardNum()>self.player:getMaxCards() then return false end
	
	if not self.player:hasSkill("xuanfeng",true) and self.player:getEquips():length()>0 then return true end
	if not self.player:hasSkill("lieren",true) and self:getCardsNum("Slash")>0 and
		(self.player:getHandcardNum()-self:getCardsNum("Peach")-self:getCardsNum("Slash")>0) then return true end
	local candis = false
	for _,c in sgs.list(self.player:getCards("he"))do
		if c:isKindOf("Weapon") and self.player:canDiscard(self.player,c:getEffectiveId()) then
			candis = true
			break
		end
	end
	if not self.player:hasSkill("qiangxi",true) and (self.player:getHp()>3 or self:getCardsNum("Peach")>0 or candis) then return true end
	self:sort(self.enemies,"hp")
	if not self.player:hasSkill("wansha",true) then
		for _,enemy in sgs.list(self.enemies)do
			if not (enemy:hasSkill("kongcheng") and enemy:isKongcheng()) and self:isWeak(enemy) and self:damageMinusHp(enemy,1)>0 and #self.enemies>1 then
				return true
			end
			if self.player:hasSkill("qiangxi") and self:isWeak(enemy) and self:damageMinusHp(enemy,1)>0 then
				return true
			end
		end
	end
	
	if self:needToThrowArmor() and self.player:canDiscard(self.player,self.player:getArmor():getEffectiveId()) then return true end
	
	local num = 0
	if not self.player:hasSkill("xuanfeng",true) then num = num+1 end
	if not self.player:hasSkill("lieren",true) then num = num+1 end
	if not self.player:hasSkill("qiangxi",true) then num = num+1 end
	if not self.player:hasSkill("wansha",true) then num = num+1 end
	if self:needKongcheng(self.player,true) and self.player:getHandcardNum()<=num and num>0 then return true end
	
	return false
end

local jiwu_skill = {}
jiwu_skill.name = "jiwu"
table.insert(sgs.ai_skills,jiwu_skill)
jiwu_skill.getTurnUseCard = function(self,inclusive)
	if not CanUsejiwu(self) then return end
	return sgs.Card_Parse("@JiwuCard=.")
end

sgs.ai_skill_use_func.JiwuCard = function(card,use,self)
	local usable_cards = self.player:getCards("h")
	local use_card = {}
	for _,c in sgs.list(usable_cards)do
		if not c:isKindOf("Peach") and not c:isKindOf("ExNihilo") then
			table.insert(use_card,c)
		end
	end
	if #use_card==0 then return end
	self:sortByKeepValue(use_card)
	use.card = sgs.Card_Parse("@JiwuCard="..use_card[1]:getEffectiveId())
end

sgs.ai_skill_choice.jiwu = function(self,choices,data)
	if self.player:getHandcardNum()-self:getCardsNum("Peach")>0 then
		if not self.player:hasSkill("xuanfeng",true) and self.player:getEquips():length()>0 then
			return "xuanfeng"
		end
		if not self.player:hasSkill("lieren",true) and self:getCardsNum("Slash")>0 and (self.player:getHandcardNum()-self:getCardsNum("Peach")-self:getCardsNum("Slash")>0) then
			return "lieren"
		end
		
		local candis = false
		for _,c in sgs.list(self.player:getCards("he"))do
			if c:isKindOf("Weapon") and self.player:canDiscard(self.player,c:getEffectiveId()) then
				candis = true
				break
			end
		end
		if not self.player:hasSkill("qiangxi",true) and (self.player:getHp()>3 or self:getCardsNum("Peach")>0 or candis) then
			return "qiangxi"
		end
		
		self:sort(self.enemies,"hp")
		if not self.player:hasSkill("wansha",true) then
			for _,enemy in sgs.list(self.enemies)do
				if not (enemy:hasSkill("kongcheng") and enemy:isKongcheng()) and self:isWeak(enemy) and self:damageMinusHp(enemy,1)>0 and #self.enemies>1 then
					return "wansha"
				end
				if self.player:hasSkill("qiangxi") and self:isWeak(enemy) and self:damageMinusHp(enemy,1)>0 then
					return "wansha"
				end
			end
		end
	else
		if not self.player:hasSkill("xuanfeng",true) then
			return "xuanfeng"
		end
		if not self.player:hasSkill("lieren",true) then
			return "lieren"
		end
		if not self.player:hasSkill("qiangxi",true) then
			return "qiangxi"
		end
		if not self.player:hasSkill("wansha",true) then
			return "wansha"
		end
	end
	return choices:split("+")[1]
end

sgs.ai_use_priority.JiwuCard = sgs.ai_use_priority.Slash+0.1
sgs.ai_use_value.JiwuCard = 3

addAiSkills("pingxiang").getTurnUseCard = function(self)
	if self.player:getMaxHp()>9
	then
		return sgs.Card_Parse("@PingxiangCard=.")
	end
end

sgs.ai_skill_use_func["PingxiangCard"] = function(card,use,self)
	local fs = dummyCard("fire_slash")
	fs:setSkillName("_pingxiang")
	fs = self:aiUseCard(fs)
	if fs.card and fs.to
	then
		use.card = card
		sgs.ai_use_priority.PingxiangCard = sgs.ai_use_priority.Slash-0.3
	end
end

sgs.ai_use_value.PingxiangCard = 9.4
sgs.ai_use_priority.PingxiangCard = 2.8

sgs.ai_skill_use["@@pingxiang"] = function(self,prompt)
	local fs = dummyCard("fire_slash")
	fs:setSkillName("_pingxiang")
    local dummy = self:aiUseCard(fs)
    local tos = {}
   	if dummy.card
   	and dummy.to
   	then
       	for _,p in sgs.list(dummy.to)do
       		table.insert(tos,p:objectName())
       	end
       	return fs:toString().."->"..table.concat(tos,"+")
    end
	dummy = sgs.SPlayerList()
	self:sort(self.enemies,"hp")
	for _,p in sgs.list(self.enemies)do
		if CanToCard(fs,self.player,p,dummy)
		and self:slashIsEffective(fs,p)
		then
			table.insert(tos,p:objectName())
			dummy:append(p)
		end
	end
	local OP = self.room:getOtherPlayers(self.player)
	OP = self:sort(OP,"hp")
	for _,p in sgs.list(OP)do
		if CanToCard(fs,self.player,p,dummy)
		and self:slashIsEffective(fs,p)
		and not self:isFriend(p)
		then
			table.insert(tos,p:objectName())
			dummy:append(p)
		end
	end
   	if #tos>0
   	then
       	return fs:toString().."->"..table.concat(tos,"+")
    end
end

addAiSkills("shouli").getTurnUseCard = function(self)
	local cards = {}
  	for i,p in sgs.list(self.room:getAlivePlayers())do
		for d,c in sgs.list(p:getCards("ej"))do
			if c:isKindOf("OffensiveHorse")
			then table.insert(cards,c) end
		end
	end
	self:sortByKeepValue(cards,nil,"l")
  	for d,c in sgs.list(cards)do
		local dc = dummyCard()
		dc:setSkillName("shouli")
		dc:addSubcard(c)
		d = self:aiUseCard(dc)
		if d.card and d.to
		and dc:isAvailable(self.player)
		then
			self.shouli_to = d.to
			sgs.ai_use_priority.ShouliCard = sgs.ai_use_priority.Slash+0.6
			return sgs.Card_Parse("@ShouliCard="..c:getEffectiveId()..":slash")
		end
	end
end

sgs.ai_skill_use_func["ShouliCard"] = function(card,use,self)
	if self.shouli_to
	then
		use.card = card
		if use.to then use.to = self.shouli_to end
	end
end

sgs.ai_use_value.ShouliCard = 5.4
sgs.ai_use_priority.ShouliCard = 2.8

sgs.ai_guhuo_card.shouli = function(self,toname,class_name)
	local cards = {}
  	for i,p in sgs.list(self.room:getAlivePlayers())do
		for d,c in sgs.list(p:getCards("ej"))do
			if c:isKindOf("OffensiveHorse") and class_name=="Slash"
			or c:isKindOf("DefensiveHorse") and class_name=="Jink"
			then table.insert(cards,c) end
		end
	end
	self:sortByKeepValue(cards,nil,"l")
  	for d,c in sgs.list(cards)do
		if self:getCardsNum(class_name)>0 then break end
		return "@ShouliCard="..c:getEffectiveId()..":"..toname
	end
end

addAiSkills("shencai").getTurnUseCard = function(self)
	return sgs.Card_Parse("@ShencaiCard=.")
end

sgs.ai_skill_use_func["ShencaiCard"] = function(card,use,self)
	self:sort(self.enemies,"hp")
	for _,ep in sgs.list(self.enemies)do
		if ep:getHp()>=self.player:getHp()
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	self:sort(self.enemies,"card",true)
	for _,ep in sgs.list(self.enemies)do
		if ep:getHandcardNum()>=self.player:getHandcardNum()
		then
			use.card = card
			if use.to then use.to:append(ep) end
			return
		end
	end
	for _,ep in sgs.list(self.enemies)do
		use.card = card
		if use.to then use.to:append(ep) end
		return
	end
end

sgs.ai_use_value.ShencaiCard = 9.4
sgs.ai_use_priority.ShencaiCard = 4.8

sgs.ai_skill_playerschosen["#xunshi"] = function(self,players,x,n)
	local destlist = sgs.QList2Table(players) -- 将列表转换为表
	self:sort(destlist,"card")
	local tos = {}
	local use = {to = sgs.SPlayerList(),card = dummyCard()}
	use.card:setSkillName("xunshi")
	for _,p in sgs.list(self.room:getAllPlayers())do
		if players:contains(p) then continue end
		if use.to then use.to:append(p) end
	end
    for _,target in sgs.list(destlist)do
		if #tos>=x then break end
		if self:isEnemy(target) and self:canCanmou(target,use)
		then table.insert(tos,target) end
	end
    for _,target in sgs.list(destlist)do
		if #tos>=2 then break end
		if self:canCanmou(target,use)
		and not self:isFriend(target)
		and not table.contains(tos,target)
		then table.insert(tos,target) end
	end
	return tos
end



























