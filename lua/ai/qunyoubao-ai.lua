
SelfUseCard = function(self,card)
    local dummy = { isDummy = true,to = sgs.SPlayerList(),current_targets = {} }
	if card:isKindOf("BasicCard")
	then self:useBasicCard(card,dummy)
	elseif card:isKindOf("TrickCard")
	then self:useTrickCard(card,dummy)
	elseif card:isKindOf("EquipCard")
	then self:useEquipCard(card,dummy)
	end
	if dummy.card
	then
    	return dummy
	end
    self:useCardByClassName(card,dummy)
	return dummy
end





sgs.ai_skill_invoke.qy_jingxin = function(self,data)
	local player = self.player
    return self.invoke_jingxin
end

local qy_jingxin={}
qy_jingxin.name="qy_jingxin"
table.insert(sgs.ai_skills,qy_jingxin)
qy_jingxin.getTurnUseCard = function(self)
	local player = self.player
	self:sort(self.friends,"hp")
	if player:getPile("qy_wu"):isEmpty()
	then return end
	local id = player:getPile("qy_wu"):at(0)
   	for _,fp in ipairs(self.friends) do
   		if not fp:hasFlag("no_jx-PlayClear")
		and fp:isWounded()
	   	then
            local parse = sgs.Card_Parse("#qy_jingxinCard:"..id..":")
            assert (parse)
            return parse
      	end
    end
	self:sort(self.enemies,"hp")
   	for _,ep in ipairs(self.enemies) do
   		if not ep:hasFlag("no_jx-PlayClear")
	   	then
            local parse = sgs.Card_Parse("#qy_jingxinCard:"..id..":")
            assert (parse)
            return parse
      	end
	end
end

sgs.ai_skill_use_func["#qy_jingxinCard"] = function(card,use,self)
	local player = self.player
   	self:sort(self.friends,"hp")
   	use.card = card
	self.invoke_jingxin = true
   	for _,fp in ipairs(self.friends) do
    	if use.to
		and not fp:hasFlag("no_jx-PlayClear")
		and fp:isWounded()
    	then
	       	use.to:append(fp)
	    	return false
	   	end
   	end
	self.invoke_jingxin = false
   	self:sort(self.enemies,"hp")
   	for _,ep in ipairs(self.enemies) do
    	if use.to
		and not ep:hasFlag("no_jx-PlayClear")
      	then
	       	use.to:append(ep)
	      	return false
		end
	end
end

sgs.ai_use_value.qy_jingxinCard = 0.4
sgs.ai_use_priority.qy_jingxinCard = 0.4

sgs.ai_skill_choice.qy_juanshen_xg = function(self,choices)
	local player = self.player
    return self.choice_juanshen
end

sgs.ai_skill_invoke.qy_juanshen = function(self,data)
	local player = self.player
	local use = data:toCardUse()
	if use.card:isKindOf("Peach")
	then
        if player:getLostHp() > 1
		then
	    	self.choice_juanshen = "qy_juanshen3"
		else
	    	self.choice_juanshen = "qy_juanshen1"
		end
		return use
	end
	if use.card:isKindOf("Analeptic")
	then
        if player:isWounded()
		then
	    	self.choice_juanshen = "qy_juanshen3"
		else
	    	self.choice_juanshen = "qy_juanshen1"
		end
		return use
	end
	if use.card:isKindOf("Slash")
	or use.card:isKindOf("DelayedTrick")
	then
	   	self.choice_juanshen = "qy_juanshen4"
		return use
	end
	if use.card:isKindOf("SingleTargetTrick")
	then
        if self:isFriend(use.to:at(0))
		then
	    	if use.to:at(0):isWounded()
			then
		    	self.choice_juanshen = "qy_juanshen3"
			else
		    	self.choice_juanshen = "qy_juanshen1"
			end
		else
	    	self.choice_juanshen = "qy_juanshen4"
		end
		return use
	end
	if use.card:isKindOf("AOE")
	then
       	for _,to in sgs.qlist(use.to) do
	    	if self:isEnemy(to)
			and to:getHp() < 2
			then
		    	self.choice_juanshen = "qy_juanshen4"
				return use
			end
		end
	end
end

sgs.ai_skill_discard.qy_zhuangmeng = function(self)
    local player = self.player
	local to_cards = {}
	local cards = player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
   	for _,h in ipairs(cards) do
   	   	if #to_cards < 1
		and #cards > 1
	   	then table.insert(to_cards,h:getId()) end
    end
	return #to_cards > 0 and to_cards or {}
end

sgs.ai_skill_invoke.qy_shenjin = function(self,data)
	local player = self.player
	local dama = data:toPlayer()
    return not self:isFriend(dama) and dama:getHandcardNum() >= player:getHandcardNum()
end


sgs.ai_skill_playerchosen.qy_cuoluan = function(self,players)
	local player = self.player
	local destlist = players
    destlist = sgs.QList2Table(destlist) -- 将列表转换为表
	self:sort(destlist,"handcard")
    local effect = player:getTag("qy_cuoluan"):toCardEffect()
    for _,target in ipairs(destlist) do
    	if self:isEnemy(target)
		and effect.card:isDamageCard()
		then return target end
	end
    for _,target in ipairs(destlist) do
    	if not self:isEnemy(target)
		and (effect.card:isKindOf("Peach")
		or effect.card:isKindOf("ExNihilo"))
		then return target end
	end
	self:sort(destlist,"handcard",true)
    return destlist[1]
end

sgs.ai_skill_invoke.qy_qiujiao = function(self,data)
	local player = self.player
	local items = data:toString():split(":")
   	local target = self.room:findPlayerByObjectName(items[2])
	if not self:isEnemy(target)
	or player:getHandcardNum() < 3
	then return target end
end

local qy_qiujiao={}
qy_qiujiao.name="qy_qiujiao"
table.insert(sgs.ai_skills,qy_qiujiao)
qy_qiujiao.getTurnUseCard = function(self)
	local player = self.player
	local destlist = sgs.QList2Table(self.room:getOtherPlayers(player))
 	for _,ep in ipairs(destlist) do
       	if player:usedTimes("#qy_qiujiaocard") < 1
		then
            local parse = sgs.Card_Parse("#qy_qiujiaocard:.:")
            assert (parse)
            return parse
		end
	end
    local cards = player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
    if #cards < 1
	then return end
    for _,name in ipairs(patterns) do
       	local poi = sgs.Sanguosha:cloneCard(name)
		if player:getMark(name.."_qj") > 0
		and player:getMark(name.."_qj_no") < 1
		and poi
		then
	   	poi:addSubcard(cards[1])
       	local dummy = SelfUseCard(self,poi)
       	if poi:isAvailable(player)
	   	and dummy.card
       	and dummy.to
	   	then
	       	if poi:isKindOf("IronChain")
	    	or poi:isKindOf("JlLianhuansr")
			then
		    	if dummy.to:length() < 1 --该死的使用重铸
				then return end
			end
			local arch = sgs.Card_Parse(name..":qy_qiujiao[no_suit:0]="..cards[1]:getId())
	       	assert(arch)
	        return arch
			end
       	poi:deleteLater()
       	end
    end
end

sgs.ai_skill_use_func["#qy_qiujiaocard"] = function(card,use,self)
	local player = self.player
	self.zg_bian_suit = card:getSuitString()
    local cards = sgs.QList2Table(player:getCards("h"))
	use.card = card
	local destlist = sgs.QList2Table(self.room:getOtherPlayers(player))
	for _,ep in ipairs(destlist) do
       	if not ep:isNude()
		then
	    	if not self:isEnemy(ep)
            then
             	if use.to
	        	then
	            	use.to:append(ep)
	               	return false
	          	end
	    	end
		end
   	end
	for _,ep in ipairs(destlist) do
       	if not ep:isNude()
		then
          	if use.to
	       	then
	           	use.to:append(ep)
	           	return false
	      	end
		end
   	end
	for _,ep in ipairs(destlist) do
      	if use.to
	   	then
	       	use.to:append(ep)
	       	return false
		end
   	end
end

sgs.ai_use_value.qy_qiujiaocard = 8.4
sgs.ai_use_priority.qy_qiujiaocard = 8.4

sgs.ai_skill_invoke.qy_zongguan = function(self,data)
	local player = self.player
	local dama = data:toPlayer()
    return self:isFriend(dama)
end

local qy_zongguan={}
qy_zongguan.name="qy_zongguan"
table.insert(sgs.ai_skills,qy_zongguan)
qy_zongguan.getTurnUseCard = function(self)
	local player = self.player
    for _,fp in ipairs(self.friends) do
	   	if fp:hasSkill("qy_zongguan")
		and not player:hasFlag("use_zongguan-Clear")
	   	then
           	local parse = sgs.Card_Parse("#qy_zongguanCard:.:")
           	assert (parse)
           	return parse
    	end
	end
end

local qy_zongguanVS={}
qy_zongguanVS.name="qy_zongguanVS"
table.insert(sgs.ai_skills,qy_zongguanVS)
qy_zongguanVS.getTurnUseCard = function(self)
	local player = self.player
   for _,fp in ipairs(self.friends) do
	   	if fp:hasSkill("qy_zongguan")
		and not player:hasFlag("use_zongguan-Clear")
	   	then
           	local parse = sgs.Card_Parse("#qy_zongguanCard:.:")
           	assert (parse)
           	return parse
    	end
	end
end

sgs.ai_skill_use_func["#qy_zongguanCard"] = function(card,use,self)
	local player = self.player
	use.card = card
	local destlist = self.friends
	self:sort(destlist,"handcard")
	for _,fp in ipairs(destlist) do
		if use.to
		and fp:hasSkill("qy_zongguan")
		then
			use.to:append(fp)
			break
		end
	end
end

sgs.ai_use_value.qy_zongguanCard = 7.5
sgs.ai_use_priority.qy_zongguanCard = 7.5

sgs.ai_skill_discard.qy_fujia = function(self)
    local player = self.player
	local to_cards = {}
	local cards = player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local da = player:getTag("qy_fujia"):toDamage()
	if da
	then
    	da = da.to
      	for _,h in ipairs(cards) do
   	    	if #to_cards < 2
			and self:isEnemy(da)
	    	then table.insert(to_cards,h:getId()) end
    	end
	end
	local re = player:getTag("qy_fujia"):toRecover()
	if re
	then
    	re = re.who
      	for _,h in ipairs(cards) do
   	    	if #to_cards < 2
			and self:isFriend(re)
			and re:isWounded()
	    	then table.insert(to_cards,h:getId()) end
    	end
	end
	return #to_cards > 1 and to_cards or {}
end

sgs.ai_skill_invoke.qy_jihao = function(self,data)
	local player = self.player
	local dama = data:toPlayer()
    return not self:isEnemy(dama)
	or player:getHandcardNum() < 3
end

local qy_yinyou={}
qy_yinyou.name="qy_yinyou"
table.insert(sgs.ai_skills,qy_yinyou)
qy_yinyou.getTurnUseCard = function(self)
	local player = self.player
	local destlist = sgs.QList2Table(self.room:getOtherPlayers(player))
 	for _,ep in ipairs(destlist) do
       	if not ep:hasFlag("no_yy-PlayClear")
		and not ep:isNude()
		then
	    	if ep:getGender() == player:getGender()
            then
                
				local parse = sgs.Card_Parse("#qy_yinyoucard:.:")
                assert (parse)
                return parse
	    	end
		end
	end
end

sgs.ai_skill_use_func["#qy_yinyoucard"] = function(card,use,self)
	local player = self.player
	self.zg_bian_suit = card:getSuitString()
    local cards = sgs.QList2Table(player:getCards("h"))
	use.card = card
	local destlist = sgs.QList2Table(self.room:getOtherPlayers(player))
	for _,ep in ipairs(destlist) do
       	if not ep:hasFlag("no_yy-PlayClear")
		and not ep:isNude()
		then
	    	if ep:getGender() == player:getGender()
            then
             	if use.to
	        	then
	            	use.to:append(ep)
	               	return false
	          	end
			elseif self:isEnemy(ep)
			and ep:getHandcardNum() < 2
			and player:getHp() > 1
			then
             	if use.to
	        	then
	            	use.to:append(ep)
	               	return false
	          	end
	    	end
		end
   	end
end

sgs.ai_use_value.qy_yinyoucard = 7.4
sgs.ai_use_priority.qy_yinyoucard = 7.4

sgs.ai_skill_invoke.qy_yinyou = function(self,data)
	local player = self.player
	local items = data:toString():split(":")
   	local target = self.room:findPlayerByObjectName(items[2])
	if self:isFriend(target)
	then
    	return target:getHp() > 1
		or target:getHandcardNum() < player:getHandcardNum()
	end
	return target
end

sgs.ai_skill_cardask["@qy_weiti"] = function(self,data)
    local player = self.player
	local cards = sgs.QList2Table(player:getCards("he"))
	self:sortByKeepValue(cards)
    local to = data:toPlayer()
 	if self:isFriend(to)
 	then return cards[1]:getId() end
    return "."
end

sgs.ai_skill_cardask["@qy_elun"] = function(self,data)
    local player = self.player
	local cards = sgs.QList2Table(player:getCards("he"))
	self:sortByKeepValue(cards)
    local damage = data:toDamage()
	for _,card in ipairs(cards) do
		if card:getType() == damage.card:getType()
		then
	    	if not self:isFriend(damage.to)
	    	then return card:getId() end
		end
	end
    return "."
end

local qy_tumou={}
qy_tumou.name="qy_tumou"
table.insert(sgs.ai_skills,qy_tumou)
qy_tumou.getTurnUseCard = function(self)
    local player = self.player
    local cards = player:getCards("h")
    cards = sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
    if #cards < 1
	or player:hasFlag("no_qy_tumou-Clear")
	then return end
    for _,h in ipairs(cards) do
    	if h:isKindOf("BasicCard")
		then
            for _,name in ipairs(patterns) do
            	local poi = sgs.Sanguosha:cloneCard(name)
	        	poi:addSubcard(h)
            	local dummy = SelfUseCard(self,poi)
             	poi:deleteLater()
             	if not player:hasFlag(name.."_tumou-Clear")
				and not poi:isDamageCard()
				and poi:isAvailable(player)
	         	and poi:isNDTrick()
	        	and dummy.card
            	and dummy.to
	         	then
	             	if poi:isKindOf("IronChain")
					or poi:isKindOf("JlLianhuansr")
					then
				    	if dummy.to:length() < 1 --该死的使用重铸
						then return end
					end
					local arch = sgs.Card_Parse(name..":qy_tumou[no_suit:0]="..h:getId())
	             	assert(arch)
	                return arch
             	end
         	end
            for _,name in ipairs(patterns) do
            	local poi = sgs.Sanguosha:cloneCard(name)
	        	poi:addSubcard(h)
            	local dummy = SelfUseCard(self,poi)
             	poi:deleteLater()
             	if not player:hasFlag(name.."_tumou-Clear")
				and poi:isDamageCard()
				and poi:isAvailable(player)
	         	and poi:isNDTrick()
	        	and dummy.card
            	and dummy.to
	         	then
	             	local arch = sgs.Card_Parse(name..":qy_tumou[no_suit:0]="..h:getId())
	             	assert(arch)
	                return arch
             	end
         	end
		end
	end
end

sgs.ai_view_as.qy_tumou = function(card,player,card_place)
	if card_place ~= sgs.Player_PlaceHand
	or player:hasFlag("no_qy_tumou-Clear")
	or player:hasFlag("nullification_tumou-Clear")
	then return end
	if card:isKindOf("BasicCard")
	then
    	return ("nullification:qy_tumou[no_suit:0]="..card:getId())
	end
end
