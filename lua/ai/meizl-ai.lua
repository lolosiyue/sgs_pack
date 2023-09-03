
if not sgs.ai_damage_effect then
	sgs.ai_damage_effect = {}
end


--MEIZL 001 大乔
--春深（大乔）
sgs.ai_skill_use["@@meizlchunshen"] = function(self, data, method)
	if not method then method = sgs.Card_MethodDiscard end
	local dmg
	local to_discard = {}
	
	if data == "@meizlchunshen-card" then
		dmg = self.room:getTag("meizlchunshenDamage"):toDamage()
	else
		dmg = data
	end

	if not dmg then self.room:writeToConsole(debug.traceback()) return "." end

	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards, true)
	self:sortByUseValue(cards, true)

	for _, card in ipairs(cards) do
			if not card:isKindOf("Peach")  then
				if #to_discard == 2 then break end
				table.insert(to_discard, card:getEffectiveId())
			end
		end
	if #to_discard < 2 then return "." end

	self:sort(self.enemies, "hp")

	for _, enemy in ipairs(self.enemies) do
		if ( enemy:isAlive()) and self.player:inMyAttackRange(enemy) and enemy:getHp() >= self.player:getHp() then
			if  self:canAttack(enemy, dmg.from or self.room:getCurrent(), dmg.nature)
				and not (dmg.card and dmg.card:getTypeId() == sgs.Card_TypeTrick and enemy:hasSkill("wuyan")) then
				
				return "#meizlchunshencard:"..table.concat(to_discard, "+")..":->" .. enemy:objectName()
			end
		end
	end

	for _, friend in ipairs(self.friends_noself) do
		if (friend:isAlive()) and self.player:inMyAttackRange(friend) and friend:getHp() >= self.player:getHp()  then
			if friend:isChained() and dmg.nature ~= sgs.DamageStruct_Normal and not self:isGoodChainTarget(friend, dmg.from, dmg.nature, dmg.damage, dmg.card) then
			elseif  (friend:hasSkills("yiji|buqu|nosbuqu|shuangxiong|zaiqi|yinghun|jianxiong|fangzhu")
						or self:getDamagedEffects(friend, dmg.from or self.room:getCurrent())
						or self:needToLoseHp(friend)) then
				return "#meizlchunshencard:"..table.concat(to_discard, "+").. "->" .. friend:objectName()
				elseif dmg.card and dmg.card:getTypeId() == sgs.Card_TypeTrick and friend:hasSkill("wuyan") and friend:getLostHp() > 1 then
					return "#meizlchunshencard:"..table.concat(to_discard, "+").."->" .. friend:objectName()
			elseif hasBuquEffect(friend) then return "#meizlchunshencard:" ..table.concat(to_discard, "+").. ":->" .. friend:objectName() end
		end
	end

	for _, enemy in ipairs(self.enemies) do
		if  enemy:isAlive() and self.player:inMyAttackRange(enemy) and enemy:getHp() >= self.player:getHp()  then
			if  self:canAttack(enemy, (dmg.from or self.room:getCurrent()), dmg.nature)
				and not (dmg.card and dmg.card:getTypeId() == sgs.Card_TypeTrick and enemy:hasSkill("wuyan")) then
				return "#meizlchunshencard:" ..table.concat(to_discard, "+").. ":->" .. enemy:objectName() end
		end
	end

	for i = #self.enemies, 1, -1 do
		local enemy = self.enemies[i]
		if not enemy:isWounded() and not self:hasSkills(sgs.masochism_skill, enemy) and enemy:isAlive() and self.player:inMyAttackRange(enemy) and enemy:getHp() >= self.player:getHp()
			and self:canAttack(enemy, dmg.from or self.room:getCurrent(), dmg.nature)
			and (not (dmg.card and dmg.card:getTypeId() == sgs.Card_TypeTrick and enemy:hasSkill("wuyan") and enemy:getLostHp() > 0) or self:isWeak()) then
			return "#meizlchunshencard:" ..table.concat(to_discard, "+").. ":->" .. enemy:objectName()
		end
	end

	return "."
end

sgs.ai_card_intention.meizlchunshencard = function(self, card, from, tos)
	local to = tos[1]
	if self:getDamagedEffects(to) or self:needToLoseHp(to) then return end
	local intention = 10
	if hasBuquEffect(to) then intention = 0
	elseif (to:getHp() >= 2 and to:hasSkills("yiji|shuangxiong|zaiqi|yinghun|jianxiong|fangzhu"))
		or (to:getHandcardNum() < 3 and (to:hasSkill("nosrende") or (to:hasSkill("rende") and not to:hasUsed("RendeCard")))) then
		intention = 0
	end
	sgs.updateIntention(from, to, intention)
end

function sgs.ai_slash_prohibit.meizlchunshen(self, from, to)
	if from:hasSkill("jueqing") or (from:hasSkill("nosqianxi") and from:distanceTo(to) == 1) then return false end
	if from:hasFlag("NosJiefanUsed") then return false end
	if self:isFriend(to, from) then return false end
	return self:cantbeHurt(to, from)
end


function sgs.ai_cardneed.meizlchunshen(to, card, self)
	return to:getHandcardNum() < 2
end





--MEIZL 003 王异

--奇计（王异）
sgs.ai_skill_discard["meizlqiji"] = function(self, discard_num, min_num, optional, include_equip)
	local usable_cards = sgs.QList2Table(self.player:getCards("he"))
	local damage = self.room:getTag("CurrentDamageStruct"):toDamage()
	local target = damage.from
	if target and  not self:isFriend(target) then  
	self:sortByKeepValue(usable_cards)
	local to_discard = {}
	for _,c in ipairs(usable_cards) do
		if #to_discard < discard_num and not c:isKindOf("Peach") then
			table.insert(to_discard, c:getEffectiveId())
		end
	end
	if #to_discard > 0 then
		return to_discard
		end
	end
	return {}
end



function sgs.ai_slash_prohibit.meizlqiji(self, from, to)
	if self:isFriend(from, to) then return false end
	if from:hasSkill("jueqing") or (from:hasSkill("nosqianxi") and from:distanceTo(to) == 1) then return false end
	if from:hasFlag("NosJiefanUsed") then return false end
	return  from:getHp() < 2
end


--忍辱（王异）
sgs.ai_skill_invoke.meizlrenru = function(self, data)
	return self:isWeak() or not self.player:faceUp()
end

meizlrenru_damageeffect = function(self, to, nature, from)
	if to:hasSkill("meizlrenru") and not to:faceUp() then return false end
	return true
end


table.insert(sgs.ai_damage_effect, meizlrenru_damageeffect)



--MEIZL 004　张春华
--闺怨（张春华）
sgs.ai_skill_invoke.meizlguiyuan = function(self, data)
	local current = self.room:getCurrent()
	if self:isEnemy(current) then
		if self:doNotDiscard(current) then
			return false
			else 
			return true
		end
	end
	if self:isFriend(current) then
		return self:needToThrowArmor(current) or self:doNotDiscard(current)
	end
	return not self:isFriend(current)
end
sgs.ai_choicemade_filter.cardChosen.meizlguiyuan = sgs.ai_choicemade_filter.cardChosen.snatch


--MEIZL 005 祝融
--飞刃（祝融）
sgs.ai_skill_invoke.meizlfeiren = function(self, data)
	local effect = data:toSlashEffect()
	if self:isEnemy(effect.to) then
		if self:doNotDiscard(effect.to) then
			return false
		end
	end
	return not self:isFriend(effect.to)
end

sgs.ai_choicemade_filter.cardChosen.meizlfeiren = sgs.ai_choicemade_filter.cardChosen.snatch

--MEIZL 006 糜夫人
--扶君（糜夫人）
sgs.ai_skill_playerchosen.meizlfujun = function(self, targets)
	local AssistTarget = self:AssistTarget()
	if AssistTarget and not self:willSkipPlayPhase(AssistTarget) then
		return AssistTarget
	end

	self:sort(self.friends_noself, "chaofeng")
	for _, target in ipairs(self.friends_noself) do
		if not target:hasSkill("dawu") and target:hasSkills("yongsi|zhiheng|" .. sgs.priority_skill .. "|shensu")
			and (not self:willSkipPlayPhase(target) or target:hasSkill("shensu")) then
			return target
		end
	end

	for _, target in ipairs(self.friends_noself) do
		if target:hasSkill("dawu") then
			local use = true
			for _, p in ipairs(self.friends_noself) do
				if p:getMark("@fog") > 0 then use = false break end
			end
			if use then
				return  target
			end
		else
			return  target
		end
	end
end
--让马（糜夫人）
sgs.ai_skill_playerchosen.meizlrangma = function(self, targets)
	local AssistTarget = self:AssistTarget()
	if AssistTarget and not self:willSkipPlayPhase(AssistTarget) then
		return AssistTarget
	end

	self:sort(self.friends_noself, "chaofeng")
	for _, target in ipairs(self.friends_noself) do
		if target:hasSkills(sgs.cardneed_skill)
			and (not self:willSkipPlayPhase(target) or target:hasSkill("shensu")) then
			return target
		end
	end
	for _, target in ipairs(self.friends_noself) do
		if target:hasSkills("yongsi|zhiheng|" .. sgs.priority_skill .. "|shensu")
			and (not self:willSkipPlayPhase(target) or target:hasSkill("shensu")) then
			return target
		end
	end

end
--托孤（糜夫人）
meizltuogu_skill = {}
meizltuogu_skill.name = "meizltuogu"
table.insert(sgs.ai_skills, meizltuogu_skill)
meizltuogu_skill.getTurnUseCard = function(self)
	if self.player:getMark("@meizltuogu") <= 0 then return end
	local good, bad = 0, 0
	local lord = self.room:getLord()
	if lord and self.role ~= "rebel" and self:isWeak(lord) and lord:getKingdom() ~= "shu" then return end
	for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if self:isWeak(player) then
			if self:isFriend(player) and player:getKingdom() ~= "shu" then bad = bad + 1
				if player:getKingdom() == "shu"  then
					good = good + 1
				end
			elseif player:getKingdom() ~= "shu" and not self:isFriend(player) then  good = good + 1
			end
		end
	end
	if good == 0 then return end

	for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		local hp = math.max(player:getHp(), 1)
		if getCardsNum("Analeptic", player) > 0 then
			if self:isFriend(player) and player:getKingdom() ~= "shu"  then good = good + 1.0 / hp
			elseif player:getKingdom() ~= "shu" and not self:isFriend(player) then bad = bad + 1.0 / hp
			end
		end

		if self:isFriend(player)  and player:getKingdom() ~= "shu"  then good = good + math.max(getCardsNum("Peach", player), 1)
		elseif player:getKingdom() ~= "shu" and not self:isFriend(player) then bad = bad + math.max(getCardsNum("Peach", player), 1)
		end

	end
	bad = bad + self.player:getHp()
	if good > bad then return sgs.Card_Parse("#meizltuogucard:.:") end
end

sgs.ai_skill_use_func.meizltuogucard=function(card,use,self)
	use.card = card
end

sgs.ai_skill_playerchosen.meizltuogu = function(self, targets)
	local arr1, arr2 = self:getWoundedFriend(false, false)
	local target = nil

	if #arr1 > 0 and (self:isWeak(arr1[1]) or self:getOverflow() >= 1) and arr1[1]:getHp() < getBestHp(arr1[1]) then target = arr1[1] end
	if target and  target:getKingdom() == "shu" then
		return target
	end
end

--MEIZL 007 貂蝉
--离魄（貂蝉）
local meizllipo_skill = {}
meizllipo_skill.name = "meizllipo"
table.insert(sgs.ai_skills, meizllipo_skill)
meizllipo_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#meizllipocard") or self.player:isKongcheng() then return end
	return sgs.Card_Parse("#meizllipocard:.:")
end
sgs.ai_skill_use_func["#meizllipocard"] = function(card,use,self)
	local targets = {}
	local target
	self:sort(self.enemies, "defense") 
	self:sort(self.friends_noself, "defense") 
	for _, friend in ipairs(self.friends_noself) do
		if friend:isMale() and not hasManjuanEffect(friend) then
			if friend:hasSkills("tuntian+zaoxian") and not hasManjuanEffect(friend) and friend:getPhase() == sgs.Player_NotActive and not friend:isKongcheng() then
				target = friend
				break
			end
			if friend:hasSkill("enyuan") and not friend:isKongcheng() then
				target = friend
				break
			end
		end
	end
	for _, enemy in ipairs(self.enemies) do
		if enemy:isMale() then
			if hasManjuanEffect(enemy) and  not enemy:isKongcheng() then
				target = enemy
				break
			end
			if not enemy:hasSkills("tuntian+zaoxian") and not enemy:isKongcheng() then
				target = enemy
				break
			end
		end
	end
	if  target then
		use.card = card
		if use.to then
			use.to:append(target)
		end
	end
end

sgs.ai_skill_discard["meizllipocard"] = function(self, discard_num, optional, include_equip)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	local to_discard = {}
	local compare_func = function(a, b)
		return self:getKeepValue(a) < self:getKeepValue(b)
	end
	table.sort(cards, compare_func)
	for _, card in ipairs(cards) do
		if #to_discard >= discard_num then break end
		table.insert(to_discard, card:getId())
	end

	return to_discard
end

--MEIZL 008 蔡夫人
--毒言（蔡夫人）
sgs.ai_skill_invoke.meizlduyan = function(self, data)
	--if self.player:getHandcardNum() <= (self:isWeak() and 2 or 1) then return false end
	local current = self.room:getCurrent()
	if not current or self:isFriend(current) then return false end

	local max_card = self:getMaxCard()
	local max_point = max_card:getNumber()
	if self.player:hasSkill("yingyang") then max_point = math.min(max_point + 3, 13) end
	if not (current:hasSkill("zhiji") and current:getMark("zhiji") == 0 and current:getHandcardNum() == 1) then
		local enemy_max_card = self:getMaxCard(current)
		local enemy_max_point = enemy_max_card and enemy_max_card:getNumber() or 100
		if enemy_max_card and current:hasSkill("yingyang") then enemy_max_point = math.min(enemy_max_point + 3, 13) end
		if max_point > enemy_max_point or max_point > 10 then
			return true
		end
	end
	return false
end

sgs.ai_skill_pindian["meizlduyan"] = function(minusecard, self, requestor, maxcard, mincard)
	return maxcard
end

--MEIZL 009 吴国太
--招婿（吴国太）

local meizlzhaoxu_skill = {}
meizlzhaoxu_skill.name = "meizlzhaoxu"
table.insert(sgs.ai_skills, meizlzhaoxu_skill)
meizlzhaoxu_skill.getTurnUseCard = function(self)
	if not self.player:isKongcheng() and not self.player:hasUsed("#meizlzhaoxucard") then
        return sgs.Card_Parse("#meizlzhaoxucard:.:")
    end
end

sgs.ai_skill_use_func["#meizlzhaoxucard"] = function(card,use,self)
	self:sort(self.friends_noself, "handcard")
	local has_red = false
	local cards=sgs.QList2Table(self.player:getHandcards())
	for _,acard in ipairs(cards) do
		if acard:isRed() then
			has_red = true
			break
		end
	end
	if has_red then
		for _, friend in ipairs(self.friends_noself) do
			if not self:needKongcheng(friend, true) and not hasManjuanEffect(friend) then
				if friend:hasSkills(sgs.cardneed_skill) then
					use.card = sgs.Card_Parse("#meizlzhaoxucard:.:")
					if use.to then use.to:append(friend) end
					return
				end
				if getCardsNum("Slash", friend, self.player)+self:getCardsNum("Slash")>1 then
					use.card = sgs.Card_Parse("#meizlzhaoxucard:.:")
					if use.to then use.to:append(friend) end
					return
				end
			end
		end
	end
end

sgs.ai_use_priority["meizlzhaoxucard"] = 10
sgs.ai_use_value["meizlzhaoxucard"] = 2.45
sgs.ai_card_intention.meizlzhaoxucard = -80

--助治（吴国太）
sgs.ai_skill_playerchosen.meizlzhuzhi = function(self, targets)

	local x = self.player:getMark("meizlzhuzhi")
	local n = x - 1
	self:updatePlayers()
	if x == 1 and #self.friends == 1 then
		for _, enemy in ipairs(self.enemies) do
			if hasManjuanEffect(enemy) then
				return enemy
			end
		end
		return nil
	end

	self.yinghun = nil
	local player = self:AssistTarget()

	if x == 1 then
		self:sort(self.friends_noself, "handcard")
		self.friends_noself = sgs.reverse(self.friends_noself)
		for _, friend in ipairs(self.friends_noself) do
			if self:hasSkills(sgs.lose_equip_skill, friend) and friend:getCards("e"):length() > 0
			  and not hasManjuanEffect(friend) then
				self.yinghun = friend
				break
			end
		end
		if not self.yinghun then
			for _, friend in ipairs(self.friends_noself) do
				if friend:hasSkills("tuntian+zaoxian") and not hasManjuanEffect(friend) and friend:getPhase() == sgs.Player_NotActive then
					self.yinghun = friend
					break
				end
			end
		end
		if not self.yinghun then
			for _, friend in ipairs(self.friends_noself) do
				if self:needToThrowArmor(friend) and not hasManjuanEffect(friend) then
					self.yinghun = friend
					break
				end
			end
		end
		if not self.yinghun then
			for _, enemy in ipairs(self.enemies) do
				if hasManjuanEffect(enemy) then
					return enemy
				end
			end
		end

		if not self.yinghun and player and not hasManjuanEffect(player) and player:getCardCount(true) > 0 and not self:needKongcheng(player, true) then
			self.yinghun = player
		end

		if not self.yinghun then
			for _, friend in ipairs(self.friends_noself) do
				if friend:getCards("he"):length() > 0 and not hasManjuanEffect(friend) then
					self.yinghun = friend
					break
				end
			end
		end

		if not self.yinghun then
			for _, friend in ipairs(self.friends_noself) do
				if not hasManjuanEffect(friend) then
					self.yinghun = friend
					break
				end
			end
		end
	elseif #self.friends > 1 then
		self:sort(self.friends_noself, "chaofeng")
		for _, friend in ipairs(self.friends_noself) do
			if self:hasSkills(sgs.lose_equip_skill, friend) and friend:getCards("e"):length() > 0
			  and not hasManjuanEffect(friend) then
				self.yinghun = friend
				break
			end
		end
		if not self.yinghun then
			for _, friend in ipairs(self.friends_noself) do
				if friend:hasSkills("tuntian+zaoxian") and not hasManjuanEffect(friend) and friend:getPhase() == sgs.Player_NotActive then
					self.yinghun = friend
					break
				end
			end
		end
		if not self.yinghun then
			for _, friend in ipairs(self.friends_noself) do
				if self:needToThrowArmor(friend) and not hasManjuanEffect(friend) then
					self.yinghun = friend
					break
				end
			end
		end
		if not self.yinghun and #self.enemies > 0 then
			local wf
			if self.player:isLord() then
				if self:isWeak() and (self.player:getHp() < 2 and self:getCardsNum("Peach") < 1) then
					wf = true
				end
			end
			if not wf then
				for _, friend in ipairs(self.friends_noself) do
					if self:isWeak(friend) then
						wf = true
						break
					end
				end
			end

			if not wf then
				self:sort(self.enemies, "chaofeng")
				for _, enemy in ipairs(self.enemies) do
					if enemy:getCards("he"):length() == n
						and not self:doNotDiscard(enemy, "nil", true, n) then
						self.yinghunchoice = "d1tx"
						return enemy
					end
				end
				for _, enemy in ipairs(self.enemies) do
					if enemy:getCards("he"):length() >= n
						and not self:doNotDiscard(enemy, "nil", true, n)
						and self:hasSkills(sgs.cardneed_skill, enemy) then
						self.yinghunchoice = "d1tx"
						return enemy
					end
				end
			end
		end

		if not self.yinghun and player and not hasManjuanEffect(player) and not self:needKongcheng(player, true) then
			self.yinghun = player
		end

		if not self.yinghun then
			self.yinghun = self:findPlayerToDraw(false, n)
		end
		if not self.yinghun then
			for _, friend in ipairs(self.friends_noself) do
				if not hasManjuanEffect(friend) then
					self.yinghun = friend
					break
				end
			end
		end
		if self.yinghun then self.yinghunchoice = "dxt1" end
	end
	if not self.yinghun and x > 1 and #self.enemies > 0 then
		self:sort(self.enemies, "handcard")
		for _, enemy in ipairs(self.enemies) do
			if enemy:getCards("he"):length() >= n
				and not self:doNotDiscard(enemy, "nil", true, n) then
				self.yinghunchoice = "d1tx"
				return enemy
			end
		end
		self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isNude()
				and not (self:hasSkills(sgs.lose_equip_skill, enemy) and enemy:getCards("e"):length() > 0)
				and not self:needToThrowArmor(enemy)
				and not (enemy:hasSkills("tuntian+zaoxian" and enemy:getPhase() == sgs.Player_NotActive)) then
				self.yinghunchoice = "d1tx"
				return enemy
			end
		end
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isNude()
				and not (self:hasSkills(sgs.lose_equip_skill, enemy) and enemy:getCards("e"):length() > 0)
				and not self:needToThrowArmor(enemy)
				and not (enemy:hasSkills("tuntian+zaoxian") and x < 3 and enemy:getCards("he"):length() < 2) then
				self.yinghunchoice = "d1tx"
				return enemy
			end
		end
	end

	return self.yinghun
end

sgs.ai_skill_choice.meizlzhuzhi = function(self, choices)
	return self.yinghunchoice
end

--MEIZL 010 卞夫人


--素贤（卞夫人）
sgs.ai_skill_invoke.meizlsuxian = function(self, data)
	local target = data:toDamage().from

	if self:isFriend(target) then
		if self:getOverflow(target) > 2 then return true
			else
			return false
			end
	end
	if self:isEnemy(target) then
		return true
	end
	return true
end

local meizlsuxian_skill = {}
meizlsuxian_skill.name = "meizlsuxian"
table.insert(sgs.ai_skills, meizlsuxian_skill)
meizlsuxian_skill.getTurnUseCard = function(self, inclusive)
if (self.player:getMark("meizlsuxian") > 0)  then
local cards = self.player:getCards("he")
	cards=sgs.QList2Table(cards)
	local use_card 
	local card_ex = sgs.Sanguosha:getCard(self.player:getMark("meizlsuxiancard"))
	self:sortByUseValue(cards,true)
	for _,card in ipairs(cards)  do
		if card:isRed()  and not card:isKindOf("Peach") then
			use_card = card
		end
	end
	if use_card then
		if card_ex:isAvailable(self.player) then 
			card_ex:setSkillName("meizlsuxian")
			card_ex:addSubcard(use_card)
			local card_str = string.format(card_ex:objectName() .. ":meizlsuxian:%s:", use_card:getEffectiveId())
			return sgs.Card_Parse(card_str)
		end
	end
	end
end

sgs.ai_cardsview["meizlsuxian"] = function(self, class_name, player)
	if not (sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE) then return end
	local classname2objectname = {
		["Slash"] = "slash", ["Jink"] = "jink",
		["Peach"] = "peach", ["Analeptic"] = "analeptic",
		["Nullification"] = "nullification",
		["FireSlash"] = "fire_slash", ["ThunderSlash"] = "thunder_slash"
	}
	local name = classname2objectname[class_name]
	if not name or not (self.player:getMark("meizlsuxian") > 0)  then return end
	local card_ex = sgs.Sanguosha:getCard(self.player:getMark("meizlsuxiancard"))
	if name ~= card_ex:objectName() then return end
	
	local no_have = true
	local cards = player:getCards("he")
	for _, id in sgs.qlist(player:getPile("wooden_ox")) do
		if sgs.Sanguosha:getCard(id):isRed() and not sgs.Sanguosha:getCard(id):isKindOf("Peach") then
			cards:prepend(sgs.Sanguosha:getCard(id))
		end
	end
	for _,c in sgs.qlist(cards) do
		if c:isKindOf(class_name) then
			no_have = false
			break
		end
	end
	if not no_have then return end
	if class_name == "Peach" and player:getMark("Global_PreventPeach") > 0 then return end
	cards = sgs.QList2Table(cards)
	local needed = {}
	for _,acard in ipairs(cards) do
		if  acard:isRed() then
			table.insert(needed, acard)
		end
	end
	self:sortByKeepValue(cards)
	if player:getPile("wooden_ox"):length() > 0 then
		for _, id in sgs.qlist(player:getPile("wooden_ox")) do
			if not sgs.Sanguosha:getCard(id):isKindOf("Peach") then
				cards[1] = sgs.Sanguosha:getCard(id)
			end
		end
	end
	if #cards == 0 then return end
	
	--if cards[1]:isKindOf("Peach") or cards[1]:isKindOf("Analeptic") then return end
--[[	if needed[1]:isKindOf("Peach")
	or needed[1]:isKindOf("Analeptic")
	or (needed[1]:isKindOf("Jink") and self:getCardsNum("Jink") == 1)
	or (needed[1]:isKindOf("Slash") and self:getCardsNum("Slash") == 1)
	or needed[1]:isKindOf("Nullification")
	or needed[1]:isKindOf("SavageAssault")
	or needed[1]:isKindOf("ArcheryAttack")
	or needed[1]:isKindOf("Duel")
	or needed[1]:isKindOf("ExNihilo")
	then
		return
	end]]

	local suit = needed[1]:getSuitString()
	local number = needed[1]:getNumberString()
	local card_id = needed[1]:getEffectiveId()
	if player:hasSkill("meizlsuxian") then
		return (name..":meizlsuxian[%s:%s]=%d"):format(suit, number, card_id)
	end
end

--慈悯（卞夫人）
sgs.ai_skill_invoke.meizlcimin = function(self, data)
	local target = data:toPlayer()
	if target and self:isFriend(target) then
		if self:needKongcheng(self.player) then return true end 
		if self:isWeak(self.player) then return false end
		if self:isWeak(target) then return true end
		if target:getHp() < getBestHp(target) then return true end
	end
	return false
end

sgs.ai_choicemade_filter.skillInvoke.meizlcimin = function(self, player, promptlist)
	local damage = self.room:getTag("CurrentDamageStruct"):toDamage()
	if damage.to then
		if promptlist[#promptlist] == "yes" then
				sgs.updateIntention(player, damage.to, -80)
		end
	end
end




--MEIZL 011 蔡文姬
--胡笳（蔡文姬）
local meizlhujia_skill = {}
meizlhujia_skill.name = "meizlhujia"
table.insert(sgs.ai_skills,meizlhujia_skill)
meizlhujia_skill.getTurnUseCard = function(self)
	if self:needBear() then return end
	if not self.player:hasUsed("#meizlhujiacard") and not self.player:isKongcheng() then return sgs.Card_Parse("#meizlhujiacard:.:") end
end

sgs.ai_skill_use_func["#meizlhujiacard"] = function(card,use,self)
	self:sort(self.enemies, "handcard")
	local max_card = self:getMaxCard(self.player)
	local max_point = max_card:getNumber()
	if self.player:hasSkill("kongcheng") and self.player:getHandcardNum() == 1 then
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isKongcheng() and self.player:canPindian(enemy) then
				use.card = sgs.Card_Parse("#meizlhujiacard:.:")
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
	if (self:getOverflow() > 0) or (max_point > 9) then
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isKongcheng() and self.player:canPindian(enemy) then
				use.card = sgs.Card_Parse("#meizlhujiacard:.:")
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

function sgs.ai_skill_pindian.meizlhujiacard(minusecard, self, requestor)
	if self:isFriend(requestor) then return minusecard end
	return self:getMaxCard()
end

--归汉（蔡文姬）
local meizlguihan_skill = {}
meizlguihan_skill.name = "meizlguihan"
table.insert(sgs.ai_skills, meizlguihan_skill)
meizlguihan_skill.getTurnUseCard = function(self, inclusive)
	if self.player:getMark("@meizlguihan") == 0 then return end
	return sgs.Card_Parse("#meizlguihancard:.:")
end

sgs.ai_skill_use_func["#meizlguihancard"] = function(card,use,self)
	if self:isWeak() then
		use.card = card
		if use.to then use.to:append(self.player) end
		return
	end
end

--魂逝（蔡文姬）
function sgs.ai_slash_prohibit.meizlhunshi(self, from, to)
	if from:hasSkill("jueqing") or (from:hasSkill("nosqianxi") and from:distanceTo(to) == 1) then return false end
	if from:hasFlag("NosJiefanUsed") then return false end
	if to:getHp() > 1 or #(self:getEnemies(from)) == 1 then return false end
	if from:getMaxHp() == 3 and from:getArmor() and from:getDefensiveHorse() then return false end
	if from:getMaxHp() <= 3 or (from:isLord() and self:isWeak(from)) then return true end
	if from:getMaxHp() <= 3 or (self.room:getLord() and from:getRole() == "renegade") then return true end
	return false
end

--MEIZL 012 黄月英
--流马（黄月英）
sgs.ai_skill_playerchosen.meizlliuma = function(self, targets)
	local max_diff = 0
	local target
	for _, splayer in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		local diff = 0
		if splayer:getHp() > splayer:getHandcardNum() then
			if self:isFriend(splayer) then
				diff = splayer:getHp() - splayer:getHandcardNum()
			end
		elseif splayer:getHp() < splayer:getHandcardNum() then
			if not self:isFriend(splayer) then
				diff = splayer:getHandcardNum() - splayer:getHp()
			end
		end
		if diff > max_diff then
			target = splayer
		end
	end
	if target then
		return target
	end
	return  nil
end

--智囊（黄月英）
local meizlzhinang_skill = {}
meizlzhinang_skill.name = "meizlzhinang"
table.insert(sgs.ai_skills, meizlzhinang_skill)
meizlzhinang_skill.getTurnUseCard = function(self)
	if not self.player:isKongcheng() and not self.player:hasUsed("#meizlzhinangcard") then
        return sgs.Card_Parse("#meizlzhinangcard:.:")
    end
end

sgs.ai_skill_use_func["#meizlzhinangcard"] = function(card,use,self)
	self:sort(self.enemies, "defense")
	local cards = self.player:getCards("he")
	cards=sgs.QList2Table(cards)
	local use_card 
	for _,card in ipairs(cards)  do
		if card:isKindOf("BasicCard") and not card:isKindOf("Peach") then
			use_card = card
		end
	end
	if use_card then
	for _, enemy in ipairs(self.enemies) do
		if self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and self:damageIsEffective(enemy) then
					use.card = sgs.Card_Parse("#meizlzhinangcard:" .. use_card:getEffectiveId()..":")
					if use.to then
						use.to:append(enemy)
					end
					break
			end
		end
	end
end


--MEIZL 013 马云禄

--域帼（马云禄）

sgs.ai_skill_invoke.meizlyuguo = function(self, data)
	return true
end
--戎装（马云禄）
sgs.ai_skill_invoke.meizlrongzhuang = function(self, data)
	return true
end
sgs.ai_skill_use["@@meizlrongzhuang"]=function(self,prompt)
    self:updatePlayers()
	local card = prompt:split(":")
	if card[2] == "slash" or card[2] == "fire_slash" or card[2] == "thunder_slash" then
	    self:sort(self.enemies, "defense")
		local targets = {}
		for _,enemy in ipairs(self.enemies) do
		    if (not self:slashProhibit(sgs.Sanguosha:getCard(card[5]), enemy)) and self.player:canSlash(enemy, sgs.Sanguosha:getCard(card[5])) then
				if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, sgs.Sanguosha:getCard(card[5])) then break end
				table.insert(targets,enemy:objectName())
			end
		end
		if #targets > 0 then
		    return card[5] .. "->" .. table.concat(targets,"+")
		else
		    return "."
		end
	end
	return "."
end


--MEIZL 015 王元姬
--睿目（王元姬）
sgs.ai_skill_use["@@meizlruimu"]=function(self,prompt)
   
	self:updatePlayers()
	self:sort(self.enemies, "hp")
	local cards = self.player:getCards("he")
	local to_discard = {}
	cards = sgs.QList2Table(cards)
	--self:sortByKeepValue(cards)
	self:sortByUseValue(cards, true)
	
	local  target
	for _, enemy in ipairs(self.enemies) do
		if  sgs.isGoodTarget(enemy, self.enemies, self) and (enemy:getHp() > 2) then
			target = enemy
		end
	end
	if  target then
		local needcard_num = 1
		for _, card in ipairs(cards) do
			if not card:isKindOf("Peach") and not card:isKindOf("EquipCard") and card:getSuit() == sgs.Card_Heart then
				if #to_discard == needcard_num then break end
				table.insert(to_discard, card:getEffectiveId())
			end
		end
		if #to_discard ~= needcard_num then
			for _, card in ipairs(cards) do
				if not card:isKindOf("Peach") and not table.contains(to_discard, card:getEffectiveId()) and card:getSuit() == sgs.Card_Heart then
					if #to_discard == needcard_num then break end
					table.insert(to_discard, card:getEffectiveId())
				end
			end
		end
        if #to_discard == 1 then
		return "#meizlruimucard:"..table.concat(to_discard, "+")..":->"..target:objectName()
        end
	end
return "."
end


--贤淑（王元姬）
sgs.ai_skill_invoke.meizlxianshu = function(self, data)
	local damage = data:toDamage()
	if damage.to:objectName() == self.player:objectName() and self.player:getHp() < getBestHp(self.player) then
		local cards=sgs.QList2Table(self.player:getHandcards())
		for _,acard in ipairs(cards) do
			if acard:isRed()  then
				return true
			end
		end
	end
	if self:isFriend(damage.to) and damage.to:getHp() < getBestHp(damage.to) then
		if damage.to:getHandcardNum() > 2 then
			return true 
		end
	else
		if not damage.to:isWounded() or  damage.to:getHandcardNum() <= 2 then
			return true
		end
	end
	return false
end

--MEIZL 016 陆郁生
--昭节（陆郁生）
local meizlzhaojie_skill = {}
meizlzhaojie_skill.name = "meizlzhaojie"
table.insert(sgs.ai_skills, meizlzhaojie_skill)
meizlzhaojie_skill.getTurnUseCard = function(self)
	if not self.player:isKongcheng() and not self.player:hasUsed("#meizlzhaojiecard") then
        return sgs.Card_Parse("#meizlzhaojiecard:.:")
    end
end

sgs.ai_skill_use_func["#meizlzhaojiecard"] = function(card,use,self)
	self:sort(self.friends_noself, "handcard")
	local cards=sgs.QList2Table(self.player:getCards("he"))
	local needed = {}
	if self.player:isWounded() then
		for _,acard in ipairs(cards) do
			if #needed < self.player:getHp() and acard:isRed() and not acard:isKindOf("Peach") then
				table.insert(needed, acard:getEffectiveId())
			end
		end
	else
		if (self:getOverflow() > 0) then
			for _,acard in ipairs(cards) do
				if #needed < self:getOverflow() and acard:isRed() and not acard:isKindOf("Peach") then
					table.insert(needed, acard:getEffectiveId())
				end
			end
		end
	end
	if #needed > 0 then
		for _, friend in ipairs(self.friends_noself) do
			if not self:needKongcheng(friend, true) and not hasManjuanEffect(friend) then
				if friend:hasSkills(sgs.cardneed_skill) or (friend:getHandcardNum() < 3) then
					use.card = sgs.Card_Parse("#meizlzhaojiecard:"..table.concat(needed,"+")..":")
					if use.to then use.to:append(friend) end
					return
				end
			end
		end
	end
end
sgs.ai_use_priority["meizlzhaojiecard"] = sgs.ai_use_priority.Peach + 0.1
sgs.ai_use_value["meizlzhaojiecard"] = 2.45
sgs.ai_card_intention.meizlzhaojiecard = -80

--MEIZL 017 杨婉



--请宴（杨婉）

local meizlqingyan_skill = {}
meizlqingyan_skill.name = "meizlqingyan"
table.insert(sgs.ai_skills, meizlqingyan_skill)
meizlqingyan_skill.getTurnUseCard = function(self)
	if not self.player:canDiscard(self.player,"he") then return end
	return sgs.Card_Parse("#meizlqingyancard:.:")
end

sgs.ai_skill_use_func["#meizlqingyancard"] = function(card, use, self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sort(self.enemies, "handcard")
	local slashcount = self:getCardsNum("Slash")
	self:sortByUseValue(cards,true)
	if slashcount > 0  then
		for _, card in ipairs(cards) do
				if (not card:isKindOf("Peach") and not card:isKindOf("ExNihilo") and not card:isKindOf("Jink")) or self:getOverflow() > 0 then
				local slash = self:getCard("Slash")
					assert(slash)
					local target
					local dummyuse = { isDummy = true, to = sgs.SPlayerList() }
						self:useBasicCard(slash, dummyuse)
						if not dummyuse.to:isEmpty() then
							for _, p in sgs.qlist(dummyuse.to) do
								if p:getMark("@meizlqingyan") == 0 then
								target = p
									break
								end
							end
						end
					--[[local dummy_use = {isDummy = true}
					self:useBasicCard(slash, dummy_use)
					local target
					for _, enemy in ipairs(self.enemies) do
						if self:canAttack(enemy, self.player)
							and not self:canLiuli(enemy, self.friends_noself) and not self:findLeijiTarget(enemy, 50, self.player)  then
							if enemy:getMark("muguan") == 0 then
							target = enemy
							else
								return
							end
						end
					end]]
						if target then
						use.card = sgs.Card_Parse("#meizlqingyancard:"..card:getId()..":")
								if use.to then use.to:append(target) end
								return
						end
				end
			end
	end
end

sgs.ai_card_intention["meizlqingyancard"] = 70


sgs.ai_use_value["meizlqingyancard"] = 9.2
sgs.ai_use_priority["meizlqingyancard"] = sgs.ai_use_priority.Slash + 0.1


--相接（杨婉）
sgs.ai_skill_invoke.meizlxiangjie = function(self, data)
		local hcards = self.player:getCards("h")
		hcards = sgs.QList2Table(hcards)
		self:sortByUseValue(hcards, true)
		local card
		for _, hcard in ipairs(hcards) do
			if hcard:isKindOf("Slash") then
					card = hcard
			end
		end
	if not card then
		return false
	end
	local target
	local friends = self.friends_noself
	local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
	self.meizlxiangjieTarget = nil
	local friend = self.room:getCurrent()
	if friend and self:isFriend(friend) then
	
		self:sort(self.enemies, "defense")
				for _, enemy in ipairs(self.enemies) do
					if friend:canSlash(enemy) and not self:slashProhibit(slash, enemy) and sgs.getDefenseSlash(enemy, self) <= 2
							and self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self)
							and enemy:objectName() ~= self.player:objectName() then
						self.meizlxiangjieTarget = enemy
						return true
					end
				end
	end
	return false
end

sgs.ai_skill_playerchosen.meizlxiangjie = function(self, targets)
	if self.meizlxiangjieTarget then return self.meizlxiangjieTarget end
	return sgs.ai_skill_playerchosen.zero_card_as_slash(self, targets)
end

sgs.ai_skill_cardask["@meizlxiangjie-slash"] = function(self, data, pattern)
	local hcards = self.player:getCards("h")
		hcards = sgs.QList2Table(hcards)
		self:sortByUseValue(hcards, true)
		local card
		for _, hcard in ipairs(hcards) do
			if hcard:isKindOf("Slash") then
					card = hcard
			end
		end
	if card then
	return "$" .. card:getEffectiveId()
	end
end


--MEIZL 018 王悦
--武姻（王悦）
local meizlwuyin_skill = {}
meizlwuyin_skill.name = "meizlwuyin"
table.insert(sgs.ai_skills, meizlwuyin_skill)
meizlwuyin_skill.getTurnUseCard = function(self)
	if not self.player:canDiscard(self.player,"he") then return end
	if self.player:hasUsed("#meizlwuyincard") then return end
	return sgs.Card_Parse("#meizlwuyincard:.:")
end

sgs.ai_skill_use_func["#meizlwuyincard"] = function(card, use, self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sort(self.enemies, "handcard")

	self:sortByUseValue(cards,true)
		for _, card in ipairs(cards) do
				if (not card:isKindOf("Peach") and not card:isKindOf("ExNihilo") and not card:isKindOf("Jink")) or (self:getOverflow() > 0) then
				local duel = sgs.Sanguosha:cloneCard("Duel")
					local target
					local dummyuse = { isDummy = true, to = sgs.SPlayerList() }
						self:useCardDuel(duel, dummyuse)
						if not dummyuse.to:isEmpty() then
							for _, p in sgs.qlist(dummyuse.to) do
								if p:isMale() then
								target = p
									break
									end
							end
						end
                        duel:deleteLater()
						if target then
						use.card = sgs.Card_Parse("#meizlwuyincard:"..card:getId()..":")
								if use.to then use.to:append(target) end
								return
						end
				end
			end
end


sgs.ai_use_value["meizlwuyincard"] = 3
sgs.ai_use_priority["meizlwuyincard"] = sgs.ai_use_priority.Duel

--MEIZL 019 杜氏
--迷魂（杜氏）

local meizlmihun_skill = {}
meizlmihun_skill.name = "meizlmihun"
table.insert(sgs.ai_skills, meizlmihun_skill)
meizlmihun_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#meizlmihuncard") or self.player:isNude() then
		return
	end
	local card_id = self:getLijianCard()
	if card_id then return sgs.Card_Parse("#meizlmihuncard:" .. card_id..":") end
end

sgs.ai_skill_use_func["#meizlmihuncard"] = function(card, use, self)
	local first, second
	local players = sgs.QList2Table(self.room:getOtherPlayers(self.player))
	for _,target in ipairs(players) do
		if self:isEnemy(target) and target:getHandcardNum() >= 1 and not (self:doNotDiscard(target) or self:needToThrowArmor(target)) then
			for _,target2 in ipairs(sgs.QList2Table(self.room:getOtherPlayers(target))) do
				if self:isEnemy(target2) then
					if target2:getHandcardNum() >= 1 and target:canDiscard(target2, "he") and target2:canDiscard(target, "he") and not (self:doNotDiscard(target2) or self:needToThrowArmor(target2)) then
						first = target
						second = target2
						break
					end
				end
			end
		end
		if can_use then table.insert(targets,target) end
	end
	if first and second then
		use.card = card
		if use.to then
			use.to:append(first)
			use.to:append(second)
		end
	end
end


--妖娆（杜氏）
sgs.ai_skill_invoke.meizlyaorao = function(self, data)
	if #self.enemies <= 1 then return false end
	for _, c in sgs.qlist(self.player:getHandcards()) do
        local x = nil
        if isCard("ArcheryAttack", c, self.player) then
            x = sgs.Sanguosha:cloneCard("ArcheryAttack")
        elseif isCard("SavageAssault", c, self.player) then
            x = sgs.Sanguosha:cloneCard("SavageAssault")
        else continue end

        local du = { isDummy = true }
        self:useTrickCard(x, du)
		if (du.card) and self.player:getHp() > 1 then return true end
        --if target and (du.card) and self.player:getHp() > 1 then use.card=acard end
    end
	if self:isWeak() then
		return true
	end
    if #self.enemies == 1 then return true end
	return false
end


--MEIZL 020 伏寿
--密笺（伏寿）

local meizlmijian_skill = {}
meizlmijian_skill.name = "meizlmijian"
table.insert(sgs.ai_skills, meizlmijian_skill)
meizlmijian_skill.getTurnUseCard = function(self)
	if not self.player:isKongcheng() and not self.player:hasUsed("#meizlmijiancard") then
        return sgs.Card_Parse("#meizlmijiancard:.:")
    end
end

sgs.ai_skill_use_func["#meizlmijiancard"] = function(card,use,self)
	self:sort(self.friends_noself, "handcard")
	local cards=sgs.QList2Table(self.player:getCards("he"))
	local needed = {}
	if self.player:isWounded() then
		for _,acard in ipairs(cards) do
			if #needed <= self.player:getHp()  then
				table.insert(needed, acard:getEffectiveId())
			end
		end
	else
		if (self.player:getHandcardNum() > 0) then
			for _,acard in ipairs(cards) do
				if #needed < self.player:getHandcardNum()  then
					table.insert(needed, acard:getEffectiveId())
				end
			end
		end
	end
	if #needed > 0 then
		for _, friend in ipairs(self.friends_noself) do
			if not self:needKongcheng(friend, true) and not hasManjuanEffect(friend) then
					use.card = sgs.Card_Parse("#meizlmijiancard:"..table.concat(needed,"+")..":")
					if use.to then use.to:append(friend) end
					return
			end
		end
	end
end
sgs.ai_use_priority["meizlmijiancard"] = sgs.ai_use_priority.Peach + 0.1
sgs.ai_use_value["meizlmijiancard"] = 2.45
sgs.ai_card_intention.meizlmijiancard = -10

sgs.ai_skill_use["@@meizlnibi"] = function(self, prompt)
	self:sort(self.friends_noself, "handcard")
	local cards=sgs.QList2Table(self.player:getCards("he"))
	local needed = {}
	if self.player:isWounded() then
		for _,acard in ipairs(cards) do
			if #needed <= self.player:getHp()  then
				table.insert(needed, acard:getEffectiveId())
			end
		end
	else
		if (self.player:getHandcardNum() > 0) then
			for _,acard in ipairs(cards) do
				if #needed < self.player:getHandcardNum()  then
					table.insert(needed, acard:getEffectiveId())
				end
			end
		end
	end
	if #needed > 0 then
		for _, friend in ipairs(self.friends_noself) do
			if not self:needKongcheng(friend, true) and not hasManjuanEffect(friend) then
					return "#meizlmijian:"..table.concat(needed, "+")..":->"..friend:objectName()
			end
		end
	end
return "."
end


--匿壁（伏寿）
sgs.ai_skill_invoke.meizlnibi = function(self, data)
	
	return true
end

--MEIZL 021 郭女王

--谮言（郭女王）
sgs.ai_skill_discard.meizlzenyan = function(self, discard_num, min_num, optional, include_equip)
	local current = self.room:getCurrent()
	if current and self:isEnemy(current) and current:getHandcardNum() - current:getHp() > 2 then 
	local to_discard = {}
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)

	table.insert(to_discard, cards[1]:getEffectiveId())

	return to_discard
	end
	return {}
end

--专宠（郭女王）
sgs.ai_skill_invoke.meizlzhuanchong = function(self, data)
	local target = data:toPlayer()
	if self:isFriend(target) then
		if not target:getCards("e"):isEmpty() then
			return true
		end
	else
		if  target:getCards("e"):isEmpty() then
			return true
		end
	end
	return false
end

sgs.ai_skill_cardask["@meizlzhuanchong"] = function(self,data,pattern,prompt)
    local cards = self.player:getCards("he")
    cards = self:sortByKeepValue(cards)
    for i,c in sgs.list(cards)do
        if c:isKindOf("EquipCard")
        then return c:getEffectiveId() end
    end
	return "."
end



--干政（郭女王）
meizlganzheng_skill={}
meizlganzheng_skill.name="meizlganzheng"
table.insert(sgs.ai_skills,meizlganzheng_skill)
meizlganzheng_skill.getTurnUseCard=function(self,inclusive)
	if self.player:getMark("@meizlganzheng") < 1 then return end
	if #self.friends_noself < 1 then return end
	local OK = false
	for _,p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if  self:isFriend(p) and p:getHp() == 1 then
			OK = true
		end
		if self:isFriend(p) and p:getHp() == 2 and self.player:getHp() == 1 and p:getMaxHp() == 3 then
			OK = true
		end
	end
	if OK then
		return sgs.Card_Parse("#meizlganzhengcard:.:")
	end
	return
end

sgs.ai_skill_use_func["#meizlganzhengcard"] = function(card,use,self)
	local target
	for _,p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if self:isFriend(p) and p:getHp() == 1 then
			target = p
		end
		if  self:isFriend(p) and p:getHp() == 2 and self.player:getHp() == 1 and p:getMaxHp() == 3 then
			target = p
		end
		if  self:isFriend(p) and p:getHp() == 1 and p:getMaxHp() == 3 then
			target = p
		end
	end
	if target then
		use.card = card
		if use.to then use.to:append(target) end
		return
	end
end

sgs.ai_use_value["meizlganzhengcard"] = 10
sgs.ai_use_priority["meizlganzhengcard"]  = 4
sgs.ai_card_intention.meizlganzhengcard = -100


--MEIZL 022 甄姬
--薄幸（甄姬）
sgs.ai_skill_invoke.meizlboxing = function(self, data)
	local hp = self.player:getHp()
	if self:getCardsNum("Peach") + self:getCardsNum("Analeptic")  >  1 - self.player:getHp() then
		return false
	end
	return true
end

--羞花
sgs.ai_slash_prohibit.meizlxiuhua = function(self, from, enemy, card)
	if enemy:hasSkill("meizlxiuhua") and card:isKindOf("NatureSlash") and enemy:distanceTo(from) <= 2 then return true end
	return
end

meizlxiuhua_damageeffect = function(self, to, nature, from)
	if to:hasSkill("meizlxiuhua") and nature ~= sgs.DamageStruct_Normal and to:distanceTo(from) <= 2 then return false end
	return true
end


table.insert(sgs.ai_damage_effect, meizlxiuhua_damageeffect)


--MEIZL 025 孙鲁班
--谗惑（孙鲁班）

local meizlchanhuo_skill = {}
meizlchanhuo_skill.name = "meizlchanhuo"
table.insert(sgs.ai_skills,meizlchanhuo_skill)
meizlchanhuo_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meizlchanhuocard") and not self.player:isKongcheng() then return sgs.Card_Parse("#meizlchanhuocard:.:") end
end

sgs.ai_skill_use_func["#meizlchanhuocard"] = function(card,use,self)
	self:sort(self.enemies, "handcard")
	local max_card = self:getMaxCard(self.player)
	local max_point = max_card:getNumber()
	if self.player:hasSkill("kongcheng") and self.player:getHandcardNum() == 1 then
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isKongcheng() and self.player:canPindian(enemy) and enemy:getHp() == 1 then
				use.card = sgs.Card_Parse("#meizlchanhuocard:.:")
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
	if  (max_point > 10) then
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isKongcheng() and self.player:canPindian(enemy) and enemy:getHp() == 1 then
				use.card = sgs.Card_Parse("#meizlchanhuocard:.:")
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

function sgs.ai_skill_pindian.meizlchanhuocard(minusecard, self, requestor)
	if self:isFriend(requestor) then return minusecard end
	return self:getMaxCard()
end


--谮毁（孙鲁班）
local meizlzenhui_skill = {}
meizlzenhui_skill.name = "meizlzenhui"
table.insert(sgs.ai_skills, meizlzenhui_skill)
meizlzenhui_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meizlzenhuicard") and not self.player:isKongcheng() then
		self:sort(self.enemies, "hp")
		for _, enemy in ipairs(self.enemies) do
			if not (enemy:hasSkill("kongcheng") and enemy:isKongcheng()) and self:isWeak(enemy) and self:damageMinusHp(enemy, 1) > 0
				and #self.enemies > 1 then
					if self.player:getMark("@meizlzenhui") == 0 then
						return sgs.Card_Parse("#meizlzenhuicard:.:")
				end
			end
		end
		if self.player:getMark("@meizlzenhui") == 1 then
			return sgs.Card_Parse("#meizlzenhuicard:.:")
		end
	end
end

sgs.ai_skill_use_func["#meizlzenhuicard"] = function(card,use,self)
	self:sort(self.enemies, "hp")
	local cards=sgs.QList2Table(self.player:getCards("h"))
	local needed = {}
		if (self.player:getHandcardNum() > 0) then
			for _,acard in ipairs(cards) do
				if #needed < 1  then
					table.insert(needed, acard:getEffectiveId())
				end
			end
		end
	if #needed > 0 then
		for _, enemy in ipairs(self.enemies) do
			if not (enemy:hasSkill("kongcheng") and enemy:isKongcheng()) and self:isWeak(enemy) and self:damageMinusHp(enemy, 1) > 0
				and #self.enemies > 1 then
					if self.player:getMark("@meizlzenhui") == 0 then
						use.card = sgs.Card_Parse("#meizlzenhuicard:"..table.concat(needed,"+")..":")
						return 
				end
			end
		end
		if self.player:getMark("@meizlzenhui") == 1 then
			use.card = sgs.Card_Parse("#meizlzenhuicard:"..table.concat(needed,"+")..":")
				return 
		end
	end
end
sgs.ai_use_priority["#meizlganzhengcard"]  = sgs.ai_use_priority.Slash + 0.1




--MEIZL 026 黄蝶舞

--箭舞（黄蝶舞）

local meizljianwu_skill = {}
meizljianwu_skill.name = "meizljianwu"
table.insert(sgs.ai_skills, meizljianwu_skill)
meizljianwu_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meizljianwucard") and not self.player:isKongcheng() then
		self:sort(self.enemies, "hp")
		for _, enemy in ipairs(self.enemies) do
			if  #self.enemies > 1 then
					if self.player:getMark("@meizljianwu") == 0 then
						return sgs.Card_Parse("#meizljianwucard:.:")
				end
			end
		end
	end
end

sgs.ai_skill_use_func["#meizljianwucard"] = function(card,use,self)
	self:sort(self.enemies, "hp")
	local cards=sgs.QList2Table(self.player:getCards("h"))
	local needed = {}
		if (self.player:getHandcardNum() > 0) then
			for _,acard in ipairs(cards) do
				if #needed < 1  then
					table.insert(needed, acard:getEffectiveId())
				end
			end
		end
	if #needed > 0 then
		for _, enemy in ipairs(self.enemies) do
			if #self.enemies > 1 then
					if self.player:getMark("@meizljianwu") == 0 then
						use.card = sgs.Card_Parse("#meizljianwucard:"..table.concat(needed,"+")..":")
						return 
				end
			end
		end
		
	end
end
sgs.ai_use_priority["meizljianwucard"]  = sgs.ai_use_priority.Slash + 0.1



sgs.ai_view_as.meizljianwuskill2 = function(card, player, card_place)
if sgs.Sanguosha:getCurrentCardUseReason() ~= sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then return end
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if (card_place ~= sgs.Player_PlaceSpecial or player:getPile("wooden_ox"):contains(card_id))
	and card:getTypeId() == sgs.Card_TypeEquip and not card:hasFlag("using")
	and not (card:isKindOf("WoodenOx") and player:getPile("wooden_ox"):length() > 0) then
		return ("slash:meizljianwuskill2[%s:%s]=%d"):format(suit, number, card_id)
	end
end

local meizljianwuskill2_skill = {}
meizljianwuskill2_skill.name = "meizljianwuskill2"
table.insert(sgs.ai_skills, meizljianwuskill2_skill)
meizljianwuskill2_skill.getTurnUseCard = function(self, inclusive)
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)

	if self.player:getPile("wooden_ox"):length() > 0 then
		for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
			table.insert(cards, sgs.Sanguosha:getCard(id))
		end
	end

	local equip_card
	self:sortByUseValue(cards, true)

	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeEquip and (self:getUseValue(card) < sgs.ai_use_value.Slash or inclusive)
		and not (card:isKindOf("WoodenOx") and self.player:getPile("wooden_ox"):length() > 0) then
			equip_card = card
			break
		end
	end

	if equip_card then
		local suit = equip_card:getSuitString()
		local number = equip_card:getNumberString()
		local card_id = equip_card:getEffectiveId()
		local card_str = ("slash:meizljianwuskill2[%s:%s]=%d"):format(suit, number, card_id)
		local slash = sgs.Card_Parse(card_str)

		assert(slash)

		return slash
	end
end


function sgs.ai_cardneed.meizljianwuskill2(to, card, self)
	return card:getTypeId() == sgs.Card_TypeEquip and getKnownCard(to, self.player, "EquipCard", true) == 0
end


--MEIZL 027 诸葛果
--禳斗（诸葛果）
local meizlrangdou_skill = {}
meizlrangdou_skill.name = "meizlrangdou"
table.insert(sgs.ai_skills, meizlrangdou_skill)
meizlrangdou_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meizlrangdoucard") and not self.player:isKongcheng() then
		if self:isWeak() and self.player:getMark("@meizlrangdou") == 0 then
						return sgs.Card_Parse("#meizlrangdoucard:.:")
			else
				if not self:isWeak() and self.player:getMark("@meizlrangdou") == 1 then
					return sgs.Card_Parse("#meizlrangdoucard:.:")
					end
		end
	end
end

sgs.ai_skill_use_func["#meizlrangdoucard"] = function(card,use,self)

	local cards=sgs.QList2Table(self.player:getCards("h"))
	local needed = {}
		if (self.player:getHandcardNum() > 0) then
			for _,acard in ipairs(cards) do
				if #needed < 1 and acard:isKindOf("BasicCard") then
					table.insert(needed, acard:getEffectiveId())
				end
			end
		end
	if #needed > 0 then
		for _, enemy in ipairs(self.enemies) do
			if self:isWeak() and self.player:getMark("@meizlrangdou") == 0 then
						use.card = sgs.Card_Parse("#meizlrangdoucard:"..table.concat(needed,"+")..":")
						return 
			else
				if not self:isWeak() and self.player:getMark("@meizlrangdou") == 1 then
					use.card = sgs.Card_Parse("#meizlrangdoucard:"..table.concat(needed,"+")..":")
						return 
					end
		end
		end
		
	end
end



--MEIZL 028 董白
--奢华（董白）
meizlshehua_skill={}
meizlshehua_skill.name="meizlshehua"
table.insert(sgs.ai_skills,meizlshehua_skill)
meizlshehua_skill.getTurnUseCard=function(self)
	local cards = self.player:getCards("h")
	cards=sgs.QList2Table(cards)

	if self.player:getPile("wooden_ox"):length() > 0 then
		for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
			table.insert(cards, sgs.Sanguosha:getCard(id))
		end
	end

	local card

	self:sortByUseValue(cards,true)

	for _,acard in ipairs(cards)  do
		if acard:isKindOf("EquipCard") then
			card = acard
			break
		end
	end

	if not card then return nil end
	local number = card:getNumberString()
	local suit = card:getSuitString()
	local card_id = card:getEffectiveId()
	local card_str = ("analeptic:meizlshehua[%s:%s]=%d"):format(suit, number, card_id)
	local analeptic = sgs.Card_Parse(card_str)

	if sgs.Analeptic_IsAvailable(self.player, analeptic) then
		assert(analeptic)
		return analeptic
	end
end

sgs.ai_view_as.meizlshehua = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place == sgs.Player_PlaceHand or player:getPile("wooden_ox"):contains(card_id) then
		if card:isKindOf("EquipCard") then
			return ("analeptic:meizlshehua[%s:%s]=%d"):format(suit, number, card_id)
		end
	end
end

--魔嗣（董白）
local meizlmosi_skill = {}--凤翼天翔
meizlmosi_skill.name = "meizlmosi"
table.insert(sgs.ai_skills, meizlmosi_skill)
meizlmosi_skill.getTurnUseCard = function(self, inclusive)
	if self.player:getMark("@meizlmosi") > 0  then
			local TH_skillcard = sgs.Card_Parse("#meizlmosicard:.:")
			return TH_skillcard
		end
end
sgs.ai_skill_use_func["#meizlmosicard"] = function(card, use, self)
	local jiu
	if not self.player:hasUsed("Analeptic") and self:getCard("Analeptic") then
		jiu = self:getCard("Analeptic")
	end
	local slash = sgs.Sanguosha:cloneCard("Slash")
    slash:deleteLater()
	if self:UseAoeSkillValue_mei(sgs.DamageStruct_Normal, nil, slash) > 0 or self:isWeak() then
		if jiu and not use.isDummy then use.card = jiu return end
		use.card = card
		return
	end
    
end

sgs.ai_use_priority["meizlmosicard"] = 3


--MEIZL 029 丁夫人
--哭骂（丁夫人）
sgs.ai_skill_invoke.meizlkuma = function(self, data)
	local damage = data:toDamage()
	if damage.from and self:isFriend(damage.from) then
		return false
	end
	return true
end

--离异（丁夫人）
function sgs.ai_slash_prohibit.meizlliyi(self, from, to)
	if from:hasSkill("jueqing") or (from:hasSkill("nosqianxi") and from:distanceTo(to) == 1) then return false end
	if from:hasFlag("NosJiefanUsed") then return false end
	if to:getHp() > 1 or #(self:getEnemies(from)) == 1 then return false end
	if from:getMaxHp() == 3 and from:getArmor() and from:getDefensiveHorse() then return false end
	if from:getMaxHp() <= 3 or (from:isLord() and self:isWeak(from)) then return true end
	if from:getMaxHp() <= 3 or (self.room:getLord() and from:getRole() == "renegade") then return true end
	return false
end

--欲绝（丁夫人）
local meizlyujue_skill = {}
meizlyujue_skill.name = "meizlyujue"
table.insert(sgs.ai_skills, meizlyujue_skill)
meizlyujue_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#meizlyujuecard") or self:isWeak() or self:getOverflow() > 0 then return end
	return sgs.Card_Parse("#meizlyujuecard:.:")
end
sgs.ai_skill_use_func["#meizlyujuecard"] = function(card,use,self)
	local targets = {}
	local target
	self:sort(self.enemies, "defense") 
	self:sort(self.friends_noself, "defense") 
	for _, enemy in ipairs(self.enemies) do
		if (not self:doNotDiscard(enemy) or self:getDangerousCard(enemy) or self:getValuableCard(enemy)) and not enemy:isNude()  then
			target = enemy
		end
	end
	if  target then
		use.card = card
		if use.to then
			use.to:append(target)
		end
	end
end



--MEIZL 030 辛宪英


--隐智（辛宪英）

sgs.ai_skill_use["@@meizlyinzhi"] = function(self, prompt)
	local cards=sgs.QList2Table(self.player:getCards("he"))
	local needed = {}
	self:sortByKeepValue(cards)
			for _,acard in ipairs(cards) do
				if #needed < 1  then
					table.insert(needed, acard:getEffectiveId())
				end
			end
	if #needed > 0 then
					return "#meizlyinzhicard:"..table.concat(needed, "+")..":"
	end
return "."
end
sgs.ai_skill_invoke.meizlyinzhi = function(self, data)
	local damage = data:toDamage()
	if damage.from and self:isFriend(damage.from) and sgs.Sanguosha:getCard(self.player:getPile("meizlyinzhi"):first()):isKindOf("EquipCard") then
		return false
	end
	return true
end


--MEIZL 031 孙茹

--娇娆（孙茹）
sgs.ai_skill_invoke.meizlfunei = function(self, data)
	local current = self.room:getCurrent()
	if current and self:isFriend(current) and not self:isWeak() and getCardsNum("Slash", current, self.player)>1 then
		return true
	end
	return false
end


sgs.ai_skill_choice.meizljiaorao = function(self, choices)
	return self.yinghunchoice
end

local meizljiaorao_skill = {}
meizljiaorao_skill.name = "meizljiaorao"
table.insert(sgs.ai_skills, meizljiaorao_skill)
meizljiaorao_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#meizljiaoraocard") or (self:getOverflow() ==  0) then return end
	return sgs.Card_Parse("#meizljiaoraocard:.:")
end
sgs.ai_skill_use_func["#meizljiaoraocard"] = function(card,use,self)
	self:sort(self.friends_noself, "handcard")
	local cards=sgs.QList2Table(self.player:getCards("he"))
	local needed = {}
		if (self:getOverflow() > 0) then
			for _,acard in ipairs(cards) do
				if #needed < self:getOverflow() and not acard:isKindOf("Peach") then
					table.insert(needed, acard:getEffectiveId())
				end
			end
		end
	if #needed > 0 then
		local x = #needed
	local n = x - 1
	self:updatePlayers()
	if x == 1 and #self.friends == 1 then
		for _, enemy in ipairs(self.enemies) do
			if hasManjuanEffect(enemy) then
				use.card = sgs.Card_Parse("#meizljiaoraocard:"..table.concat(needed,"+")..":")
					if use.to then use.to:append(enemy) end
					return
			end
		end
		return 
	end

	local target = nil
	local player = self:AssistTarget()

	if x == 1 then
		self:sort(self.friends_noself, "handcard")
		self.friends_noself = sgs.reverse(self.friends_noself)
		for _, friend in ipairs(self.friends_noself) do
			if self:hasSkills(sgs.lose_equip_skill, friend) and friend:getCards("e"):length() > 0
			  and not hasManjuanEffect(friend) then
				target = friend
				break
			end
		end
		if not target then
			for _, friend in ipairs(self.friends_noself) do
				if friend:hasSkills("tuntian+zaoxian") and not hasManjuanEffect(friend) and friend:getPhase() == sgs.Player_NotActive then
					target = friend
					break
				end
			end
		end
		if not target then
			for _, friend in ipairs(self.friends_noself) do
				if self:needToThrowArmor(friend) and not hasManjuanEffect(friend) then
					target = friend
					break
				end
			end
		end
		if not target then
			for _, enemy in ipairs(self.enemies) do
				if hasManjuanEffect(enemy) then
					use.card = sgs.Card_Parse("#meizljiaoraocard:"..table.concat(needed,"+")..":")
					if use.to then use.to:append(enemy) end
					return
				end
			end
		end

		if not target and player and not hasManjuanEffect(player) and player:getCardCount(true) > 0 and not self:needKongcheng(player, true) then
			target = player
		end

		if not target then
			for _, friend in ipairs(self.friends_noself) do
				if friend:getCards("he"):length() > 0 and not hasManjuanEffect(friend) then
					target = friend
					break
				end
			end
		end

		if not target then
			for _, friend in ipairs(self.friends_noself) do
				if not hasManjuanEffect(friend) then
					target = friend
					break
				end
			end
		end
	elseif #self.friends > 1 then
		self:sort(self.friends_noself, "chaofeng")
		for _, friend in ipairs(self.friends_noself) do
			if self:hasSkills(sgs.lose_equip_skill, friend) and friend:getCards("e"):length() > 0
			  and not hasManjuanEffect(friend) then
				target = friend
				break
			end
		end
		if not target then
			for _, friend in ipairs(self.friends_noself) do
				if friend:hasSkills("tuntian+zaoxian") and not hasManjuanEffect(friend) and friend:getPhase() == sgs.Player_NotActive then
					target = friend
					break
				end
			end
		end
		if not target then
			for _, friend in ipairs(self.friends_noself) do
				if self:needToThrowArmor(friend) and not hasManjuanEffect(friend) then
					target = friend
					break
				end
			end
		end
		if not target and #self.enemies > 0 then
			local wf
			if self.player:isLord() then
				if self:isWeak() and (self.player:getHp() < 2 and self:getCardsNum("Peach") < 1) then
					wf = true
				end
			end
			if not wf then
				for _, friend in ipairs(self.friends_noself) do
					if self:isWeak(friend) then
						wf = true
						break
					end
				end
			end

			if not wf then
				self:sort(self.enemies, "chaofeng")
				for _, enemy in ipairs(self.enemies) do
					if enemy:getCards("he"):length() == n
						and not self:doNotDiscard(enemy, "nil", true, n) then
						self.yinghunchoice = "d1tx"
						use.card = sgs.Card_Parse("#meizljiaoraocard:"..table.concat(needed,"+")..":")
						if use.to then use.to:append(enemy) end
						return
						end
				end
				for _, enemy in ipairs(self.enemies) do
					if enemy:getCards("he"):length() >= n
						and not self:doNotDiscard(enemy, "nil", true, n)
						and self:hasSkills(sgs.cardneed_skill, enemy) then
						self.yinghunchoice = "d1tx"
						use.card = sgs.Card_Parse("#meizljiaoraocard:"..table.concat(needed,"+")..":")
						if use.to then use.to:append(enemy) end
						return
						end
				end
			end
		end

		if not target and player and not hasManjuanEffect(player) and not self:needKongcheng(player, true) then
			target = player
		end

		if not target then
			target = self:findPlayerToDraw(false, n)
		end
		if not target then
			for _, friend in ipairs(self.friends_noself) do
				if not hasManjuanEffect(friend) then
					target = friend
					break
				end
			end
		end
		if target then self.yinghunchoice = "dxt1" 
		use.card = sgs.Card_Parse("#meizljiaoraocard:"..table.concat(needed,"+")..":")
						if use.to then use.to:append(target) end
						return
						end
	end
	if not target and x > 1 and #self.enemies > 0 then
		self:sort(self.enemies, "handcard")
		for _, enemy in ipairs(self.enemies) do
			if enemy:getCards("he"):length() >= n
				and not self:doNotDiscard(enemy, "nil", true, n) then
				self.yinghunchoice = "d1tx"
				use.card = sgs.Card_Parse("#meizljiaoraocard:"..table.concat(needed,"+")..":")
					if use.to then use.to:append(enemy) end
					return
			end
		end
		self.enemies = sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isNude()
				and not (self:hasSkills(sgs.lose_equip_skill, enemy) and enemy:getCards("e"):length() > 0)
				and not self:needToThrowArmor(enemy)
				and not (enemy:hasSkills("tuntian+zaoxian" and enemy:getPhase() == sgs.Player_NotActive)) then
				self.yinghunchoice = "d1tx"
				use.card = sgs.Card_Parse("#meizljiaoraocard:"..table.concat(needed,"+")..":")
					if use.to then use.to:append(enemy) end
					return
			end
		end
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isNude()
				and not (self:hasSkills(sgs.lose_equip_skill, enemy) and enemy:getCards("e"):length() > 0)
				and not self:needToThrowArmor(enemy)
				and not (enemy:hasSkills("tuntian+zaoxian") and x < 3 and enemy:getCards("he"):length() < 2) then
				self.yinghunchoice = "d1tx"
				use.card = sgs.Card_Parse("#meizljiaoraocard:"..table.concat(needed,"+")..":")
					if use.to then use.to:append(enemy) end
					return
			end
		end
	end
	
	end
end

--MEIZL 032 樊氏
--择夫（樊氏）
local meizlzefu_skill = {}
meizlzefu_skill.name = "meizlzefu"
table.insert(sgs.ai_skills, meizlzefu_skill)
meizlzefu_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meizlzefucard") then
        return sgs.Card_Parse("#meizlzefucard:.:")
    end
end

sgs.ai_skill_use_func["#meizlzefucard"] = function(card,use,self)
	self:sort(self.friends_noself, "handcard")
	local has_red = false
		for _, friend in ipairs(self.friends_noself) do
			if not self:needKongcheng(friend, true) and not hasManjuanEffect(friend) then
				if (friend:getHandcardNum()  > self.player:getHandcardNum()) and (friend:getHp()  > self.player:getHp()) and (friend:getAttackRange()  > self.player:getAttackRange()) then
					use.card = sgs.Card_Parse("#meizlzefucard:.:")
					if use.to then use.to:append(friend) end
					return
				end
			end
		end
end

sgs.ai_use_priority["meizlzefucard"] = 10
sgs.ai_use_value["meizlzefucard"] = 2.45
sgs.ai_card_intention.meizlzefucard = -80


--MEIZL 033 严氏
--哭诉（严氏）
sgs.ai_skill_invoke.meizlkusu = function(self, data)
	local target = data:toPlayer()

	if self:isFriend(target) then
		if self:getOverflow(target) > 2 then return true 
		else 
			return false
		end
	end
	if self:isEnemy(target) then
		return true
	end
	return true
end

sgs.ai_skill_use["TrickCard+^Nullification|.|.|hand"] = function(self, prompt, method)
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card  and dummy_use and dummy_use.to then
				self.jiewei_type = sgs.Card_TypeTrick
				if dummy_use.to:isEmpty() and not card:isKindOf("IronChain") then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		end
	end
	return "."
end



--持家（严氏）

sgs.ai_skill_playerchosen.meizlchijia = function(self, targets)
	targets = sgs.QList2Table(targets)
	self:sort(targets,"defense")
	for _, enemy in ipairs(self.enemies) do
		if (not self:doNotDiscard(enemy) or self:getDangerousCard(enemy) or self:getValuableCard(enemy)) and not enemy:isNude() then
			return enemy
		end
	end
	for _, friend in ipairs(self.friends) do
		if (self:hasSkills(sgs.lose_equip_skill, friend) and not friend:getEquips():isEmpty())
		--or (self:needToThrowArmor(friend) and friend:getArmor()) or self:doNotDiscard(friend) then
		or (self:needToThrowArmor(friend) and friend:getArmor()) then
			return friend
		end
	end
	return nil
end

--MEIZLG 001 神孙尚香
--梦缘（神孙尚香）
sgs.ai_skill_invoke.meizlmengyuan = function(self, data)
	local target = data:toPlayer()
	if target and self:isFriend(target) and (target:getMaxHp() < 4) then
		return  true
	end
	return false
end

--曼舞（神貂蝉）
sgs.ai_skill_cardask["@meizlmanwu"] = function(self, data)
    local cards = sgs.QList2Table(self.player:getHandcards())
    if #cards <= 1 and self.player:getPile("meizlmanwu"):length() == 1 then return "." end
local good_enemies = {}
    for _, enemy in ipairs(self.enemies) do
        if enemy:isMale() and enemy:getCardCount()>0 then
            table.insert(good_enemies, enemy)
        end
    end
    if #good_enemies == 0 and (self.player:getPile("meizlmanwu"):length() == 2 ) then return "." end

    self:sortByKeepValue(cards)
    local xwcard = nil
    for _, card in ipairs(cards) do
		if card:isRed() then
			if isCard("Jink", card, self.player) then
				if not xwcard and self:getCardsNum("Jink") >= 2 then
					xwcard = card
				end
			elseif self:getOverflow() >= 0
					or (not isCard("Peach", card, self.player) and not (self:isWeak() and isCard("Analeptic", card, self.player))) then
				xwcard = card
			end
			if xwcard then
				break
			end
		end
    end
    if xwcard then return "$" .. xwcard:getEffectiveId() else return "." end
end

sgs.ai_skill_playerchosen.meizlmanwu = function(self, targets)
    local good_enemies = {}
    for _, enemy in ipairs(self.enemies) do
        if enemy:isMale() then
            table.insert(good_enemies, enemy)
        end
    end
    if #good_enemies == 0 then return targets:first() end

    local getCmpValue = function(enemy)
        local value = 0
      
        if not enemy:getEquips():isEmpty() then
            local len = enemy:getEquips():length()
            if enemy:hasSkills(sgs.lose_equip_skill) then value = value - 0.6 * len end
            if enemy:getArmor() and self:needToThrowArmor() then value = value - 1.5 end
            if enemy:hasArmorEffect("silver_lion") then value = value - 0.5 end

            if enemy:getWeapon() then value = value + 0.8 end
            if enemy:getArmor() then value = value + 1 end
            if enemy:getDefensiveHorse() then value = value + 0.9 end
            if enemy:getOffensiveHorse() then value = value + 0.7 end
            if self:getDangerousCard(enemy) then value = value + 0.3 end
            if self:getValuableCard(enemy) then value = value + 0.15 end
        end
        return value
    end

    local cmp = function(a, b)
        return getCmpValue(a) > getCmpValue(b)
    end
    table.sort(good_enemies, cmp)
    return good_enemies[1]
end

sgs.ai_playerchosen_intention.meizlmanwu = 80

--落红（神貂蝉）
local meizlluohong_skill = {}
meizlluohong_skill.name = "meizlluohong"
table.insert(sgs.ai_skills, meizlluohong_skill)
meizlluohong_skill.getTurnUseCard = function(self)
	if not self.player:isKongcheng() and not self.player:hasUsed("#meizlluohongcard") then
        return sgs.Card_Parse("#meizlluohongcard:.:")
    end
end

sgs.ai_skill_use_func["#meizlluohongcard"] = function(card,use,self)
	self:sort(self.friends_noself, "handcard")
	local cards=sgs.QList2Table(self.player:getCards("he"))
	local needed = {}
	if self.player:isWounded() then
		for _,acard in ipairs(cards) do
			if #needed < self.player:getHp() and acard:isBlack() and not acard:isKindOf("Peach") then
				table.insert(needed, acard:getEffectiveId())
			end
		end
	else
		if (self:getOverflow() > 0) then
			for _,acard in ipairs(cards) do
				if #needed < self:getOverflow() and acard:isBlack() and not acard:isKindOf("Peach") then
					table.insert(needed, acard:getEffectiveId())
				end
			end
		end
	end
	if #needed > 0 then
		
					use.card = sgs.Card_Parse("#meizlluohongcard:"..table.concat(needed,"+")..":")
					return
	end
end






--MEIZLG 003 神甄姬
--惊鸿（神甄姬）
sgs.ai_skill_discard.meizljinghong = function(self, discard_num, min_num, optional, include_equip)
	local current = self.room:getCurrent()
	if current and self:isEnemy(current) then 
	local to_discard = {}
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _, fcard in ipairs(cards) do
		if  #to_discard < discard_num then
	table.insert(to_discard, fcard:getEffectiveId())
	end
	end
	return to_discard
	end
	return {}
end

--玉殒（神甄姬）
sgs.ai_skill_invoke.meizlyuyundying = function(self, data)
	return true
end

sgs.ai_skill_use["@@meizlyuyun"] = function(self, prompt, method, data)
	local first_card, second_card
	local first_found, second_found = false, false
	local use_card = {}
	if self.player:getHandcardNum() >= 2 then
		local cards = self.player:getHandcards()
		cards = sgs.QList2Table(cards)
		
		
		self:sortByKeepValue(cards)
		local useAll = false
		for _, fcard in ipairs(cards) do
			local fvalueCard = (isCard("Peach", fcard, self.player) or isCard("ExNihilo", fcard, self.player))
			if not fvalueCard then
				first_card = fcard
				first_found = true
				for _, scard in ipairs(cards) do
					local svalueCard = (isCard("Peach", scard, self.player) or isCard("ExNihilo", scard, self.player))
					if first_card ~= scard and (scard:getSuit() == first_card:getSuit() ) then
						if not svalueCard then
							second_card = scard
							second_found = true
							break
						end
					end
				end
				if second_card then break end
			end
		end
	end
	local target = self.room:getCurrentDyingPlayer()
	if first_found and second_found and target and self:isFriend(target) then
		table.insert(use_card, first_card:getEffectiveId())
		table.insert(use_card, second_card:getEffectiveId())
		return "#meizlyuyuncard:".. table.concat(use_card, "+") ..":"
	end
	
	return "."
end


--MEIZLG 004 神关银屏


--虎魂（神关银屏）
sgs.ai_skill_use["@@meizlhuhun"] = function(self, prompt)
	local target
	self:updatePlayers()
	self:sort(self.enemies,"defense")

	if self:needBear() then return "." end

	local selfSub = self.player:getHp() - self.player:getHandcardNum()
	local selfDef = sgs.getDefense(self.player)
    local slash = sgs.Sanguosha:cloneCard("slash")
    slash:deleteLater()
	for _,enemy in ipairs(self.enemies) do
		local def = sgs.getDefenseSlash(enemy, self)
		
		local eff = self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self)

		if not self.player:canSlash(enemy, slash, false) then
		elseif self:slashProhibit(nil, enemy) then
		elseif def < 6 and eff then return "#meizlhuhuncard:.:->"..enemy:objectName()

		elseif selfSub >= 2 then return "."
		elseif selfDef < 6 then return "." end
	end

	for _,enemy in ipairs(self.enemies) do
		local def=sgs.getDefense(enemy)
		local eff = self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self) and self.player:inMyAttackRange(enemy)

		if not self.player:canSlash(enemy, slash, false) then
		elseif self:slashProhibit(nil, enemy) then
		elseif eff and def < 8 then return "#meizlhuhuncard:.:->"..enemy:objectName()
		else return "." end
	end
	return "."
end
sgs.ai_skill_invoke.meizlhuhun = function(self, data)
	return true
end



--雪雠（神关银屏）
sgs.ai_skill_invoke.meizlxuechou = function(self, data)
	local slash = sgs.Sanguosha:cloneCard("slash")
	local current = self.room:getCurrent()
	if current:objectName() == self.player:objectName() then
		return true
	end
	if self:isEnemy(current) and self:slashIsEffective(slash, current) and sgs.isGoodTarget(current, self.enemies, self) then
		return true
	end
	return false
end


--MEIZLG 005 神黄月英


--木牛（神黄月英）
sgs.ai_skill_invoke.meizlmuniu = function(self, data)
	local cards = self.player:getHandcards()
		cards = sgs.QList2Table(cards)	
		self:sortByKeepValue(cards)
		for _, fcard in ipairs(cards) do
			if fcard:isKindOf("TrickCard") then
				return true
			end
		end
	return false
end

--隐才（神黄月英）

local meizlyincai_skill = {}
meizlyincai_skill.name = "meizlyincai"
table.insert(sgs.ai_skills, meizlyincai_skill)
meizlyincai_skill.getTurnUseCard = function(self, inclusive)
	if self.player:getMark("@meizlyincai") > 0  then
			local use_card = sgs.Card_Parse("#meizlyincaicard:.:")
			return use_card
		end
end
sgs.ai_skill_use_func["#meizlyincaicard"] = function(card, use, self)
		use.card = card
		return
end
sgs.ai_use_value.meizlyincaicard = 4.4
sgs.ai_use_priority.meizlyincaicard = 2.8

--智袭（神黄月英）
local meizlzhixi_skill = {}
meizlzhixi_skill.name = "meizlzhixi"
table.insert(sgs.ai_skills, meizlzhixi_skill)
meizlzhixi_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meizlzhixicard") and not self.player:isKongcheng() then
        return sgs.Card_Parse("#meizlzhixicard:.:")
    end
end

sgs.ai_skill_use_func["#meizlzhixicard"] = function(card,use,self)
	self:sort(self.enemies, "handcard")
	local cards=sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
		for _, enemy in ipairs(self.enemies) do
			if enemy:getPile("meizlzhixi"):isEmpty() then
					use.card = sgs.Card_Parse("#meizlzhixicard:"..cards[1]:getEffectiveId()..":")
					if use.to then use.to:append(enemy) end
					return
				end
			end
end

sgs.ai_skill_playerchosen.meizlzhixi = function(self, targets)
  targets = sgs.QList2Table(targets)
	for _, target in ipairs(targets) do
		if self:isEnemy(target)  then
			return target
		end
	end
    return nil
end




--MEIZLG 006 神王异

--贞誓（神王异）
local meizlzhenshi_skill = {}
meizlzhenshi_skill.name = "meizlzhenshi"
table.insert(sgs.ai_skills, meizlzhenshi_skill)
meizlzhenshi_skill.getTurnUseCard = function(self)
	if not self.player:isWounded() and not self.player:hasUsed("#meizlzhenshicard") then
        return sgs.Card_Parse("#meizlzhenshicard:.:")
    end
end

sgs.ai_skill_use_func["#meizlzhenshicard"] = function(card,use,self)
	self:sort(self.friends_noself, "handcard")
	local cards=sgs.QList2Table(self.player:getCards("he"))

	if self:isWeak() then
		if self.player:getEquips():length() < 2 then
					use.card = sgs.Card_Parse("#meizlzhenshicard:.:")
					return
		end
		if not (self.player:getHandcardNum() > 4) then
			use.card = sgs.Card_Parse("#meizlzhenshicard:.:")
					return
		end
	end
end
sgs.ai_skill_choice.meizlzhenshi = function(self, choices, data)
	if self:isWeak() then
		if self.player:getEquips():length() < 2 then
			return "meizlzhenshie"
		end
		if not (self.player:getHandcardNum() > 4) then
			return "meizlzhenshih"
		end
	end
end

--缓计（神王异）
sgs.ai_skill_invoke.meizlhuanji = function(self, data)
	local dying = 0
	local handang = self.room:findPlayerBySkillName("nosjiefan")
	for _, aplayer in sgs.qlist(self.room:getAlivePlayers()) do
		if aplayer:getHp() < 1 and not aplayer:hasSkill("nosbuqu") then dying = 1 break end
	end
	if handang and self:isFriend(handang) and dying > 0 then return false end

	
	--隊友要鐵鎖連環殺自己時不用八卦陣
	local current = self.room:getCurrent()
	if current and self:isFriend(current) and self.player:isChained() and self:isGoodChainTarget(self.player, current) then return false end	--內奸跳反會有問題，非屬性殺也有問題。但狀況特殊，八卦陣原碼資訊不足，暫時這樣寫。

	if self.player:getHandcardNum() == 1 and self:getCardsNum("Jink") == 1 and self.player:hasSkills("zhiji|beifa") and self:needKongcheng() then
		local enemy_num = self:getEnemyNumBySeat(self.room:getCurrent(), self.player, self.player)
		if self.player:getHp() > enemy_num and enemy_num <= 1 then return false end
	end
	if handang and self:isFriend(handang) and dying > 0 then return false end
	if self:getDamagedEffects(self.player, nil, true) or self:needToLoseHp(self.player, nil, true, true) then return false end
	if self:getCardsNum("Jink") == 0 then return true end
	
	return true
end


--犒赏（神王异）
sgs.ai_skill_use["@@meizlkaoshang"] = function(self, prompt)
	self:sort(self.friends_noself, "handcard")
	local cards=sgs.QList2Table(self.player:getCards("he"))
	
	local equips = {}
	for _, card in sgs.qlist(self.player:getHandcards()) do
		if card:isKindOf("Armor") or card:isKindOf("Weapon") then
			if not self:getSameEquip(card) then
			elseif card:isKindOf("GudingBlade") and self:getCardsNum("Slash") > 0 then
				local HeavyDamage
				local slash = self:getCard("Slash")
				for _, enemy in ipairs(self.enemies) do
					if self.player:canSlash(enemy, slash, true) and not self:slashProhibit(slash, enemy) and
						self:slashIsEffective(slash, enemy) and not self.player:hasSkill("jueqing") and enemy:isKongcheng() then
							HeavyDamage = true
							break
					end
				end
				if not HeavyDamage then table.insert(equips, card) end
			else
				table.insert(equips, card)
			end
		elseif card:getTypeId() == sgs.Card_TypeEquip then
			table.insert(equips, card)
		end
	end
		local ecards = self.player:getCards("e")
		ecards = sgs.QList2Table(ecards)

		for _, ecard in ipairs(ecards) do
			if ecard:isKindOf("Weapon") or ecard:isKindOf("OffensiveHorse") then
				table.insert(equips, ecard)
			end
		end

	if #equips == 0 then return "." end

	local select_equip, target
	for _, friend in ipairs(self.friends_noself) do
		for _, equip in ipairs(equips) do
			local equip_index = equip:getRealCard():toEquipCard():location()
			if not self:getSameEquip(equip, friend) and self:hasSkills(sgs.need_equip_skill .. "|" .. sgs.lose_equip_skill, friend) and friend:getEquip(equip_index) == nil and friend:hasEquipArea(equip_index) then
			
			
				for _, enemy in ipairs(self.enemies) do
					if (enemy:objectName() ~= friend:objectName())	and friend:distanceTo(enemy) <= friend:getAttackRange() and  not self:cantbeHurt(enemy) and self:damageIsEffective(enemy)  then
						target = friend
						select_equip = equip
						break
					end
				end
			
			end
		end
		if target then break end
		for _, equip in ipairs(equips) do
			local equip_index = equip:getRealCard():toEquipCard():location()
			if not self:getSameEquip(equip, friend) and friend:getEquip(equip_index) == nil and friend:hasEquipArea(equip_index) then
				for _, enemy in ipairs(self.enemies) do
					if (enemy:objectName() ~= friend:objectName())	and friend:distanceTo(enemy) <= friend:getAttackRange() and  not self:cantbeHurt(enemy) and self:damageIsEffective(enemy)  then
						target = friend
						select_equip = equip
						break
					end
				end
			end
		end
		if target then break end
	end
	
	
	
	if target and select_equip  then
								return "#meizlkaoshangcard:"..select_equip:getId() ..":->"..target:objectName()
							end
			return "."
end

sgs.ai_skill_playerchosen.meizlkaoshangcard = sgs.ai_skill_playerchosen.damage



--MEIZLG 007 神张星彩
--庇荫（神张星彩）
function sgs.ai_slash_prohibit.meizlbiyin(self, from, to, card)
	if to:hasSkill("meizlbiyinx") and to:getMark("@meizlbiyinx") > 0  then return true end
end
local meizlbiyin_skill = {}
meizlbiyin_skill.name = "meizlbiyin"
table.insert(sgs.ai_skills, meizlbiyin_skill)
meizlbiyin_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meizlbiyincard") and not self.player:isKongcheng() and self.player:getMark("@meizlbiyin") > 0 then
        return sgs.Card_Parse("#meizlbiyincard:.:")
    end
end

sgs.ai_skill_use_func["#meizlbiyincard"] = function(card,use,self)

	self:sort(self.friends, "hp")
	local targets = {}
	local lord = self.room:getLord()
	self:sort(self.friends,"defense")
	if lord and lord:getMark("@meizlbiyinx") == 0 and self:isFriend(lord) and not sgs.isLordHealthy() and not self.player:isLord() and not lord:hasSkill("buqu")
		and not (lord:hasSkill("hunzi") and lord:getMark("hunzi") == 0 and lord:getHp() > 1) then
			table.insert(targets, lord)
	else
		for _, friend in ipairs(self.friends) do
			if friend:getMark("@meizlbiyinx") == 0 and self:isWeak(friend) and not friend:hasSkill("buqu")
				and not (friend:hasSkill("hunzi") and friend:getMark("hunzi") == 0 and friend:getHp() > 1) then
					table.insert(targets, friend)
					break
			end
		end
	end
	if  self:isWeak() then table.insert(targets, self.player) end
	if #targets > 0 then
		local cards=sgs.QList2Table(self.player:getHandcards())
		self:sortByUseValue(cards)
		use.card = sgs.Card_Parse("#meizlbiyincard:"..cards[1]:getEffectiveId()..":")
					if use.to then use.to:append(targets[1]) end
					return
	end
	
end

--匡济（神张星彩）
local meizlkuangji_skill = {}
meizlkuangji_skill.name = "meizlkuangji"
table.insert(sgs.ai_skills, meizlkuangji_skill)
meizlkuangji_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meizlkuangjicard") and not self.player:isNude() then
		if self.player:getMark("@meizlbiyin") == 0  and  self.player:getLostHp() < 2  and self.player:getMark("@meizlkuangji") == 0 then
						return sgs.Card_Parse("#meizlkuangjicard:.:")
		end
	end
end

sgs.ai_skill_use_func["#meizlkuangjicard"] = function(card,use,self)

	local cards=sgs.QList2Table(self.player:getCards("h"))
	local needed = {}
		if (self.player:getHandcardNum() > 0) then
			for _,acard in ipairs(cards) do
				if #needed < 1 and not acard:isKindOf("Peach") then
					table.insert(needed, acard:getEffectiveId())
				end
			end
		end
	if #needed > 0 then
		for _, enemy in ipairs(self.enemies) do
		if self.player:getMark("@meizlbiyin") == 0  and  self.player:getLostHp() < 2  and self.player:getMark("@meizlkuangji") == 0 then
					use.card = sgs.Card_Parse("#meizlkuangjicard:"..table.concat(needed,"+")..":")
						return 
					end
		end
	end
end



--MEIZLG 008A 神大乔
--比翼（神大乔、神小乔）
local meizlbiyi_skill = {}
meizlbiyi_skill.name = "meizlbiyi"
table.insert(sgs.ai_skills, meizlbiyi_skill)
meizlbiyi_skill.getTurnUseCard = function(self)
	if  (self.player:getMark("@meizlbiyi") > 0)  then
        return sgs.Card_Parse("#meizlbiyicard:.:")
    end
end

sgs.ai_skill_use_func["#meizlbiyicard"] = function(card,use,self)
					use.card = sgs.Card_Parse("#meizlbiyicard:.:")
					return
end


--羞涩（神小乔）
sgs.ai_skill_invoke.meizlxiuse = function(self, data)
	if #self.friends_noself > 0 then
		return true
	end
	return false
end

sgs.ai_skill_playerchosen.meizlxiuse = function(self, targets)
	targets = sgs.QList2Table(targets)
	self:sort(targets,"defense")
	local max = 0
	local target
	for _, friend in ipairs(self.friends_noself) do
		local x = self:ImitateResult_DrawNCards(friend, friend:getVisibleSkillList(true))
		if x > max then
			target = friend
			max = x
		end
	end
	if target then 
	return target
	end
	return targets[1]
end
sgs.ai_playerchosen_intention["meizlxiuse"] = -80
--MEIZLG 008 神大乔＆小乔



--花舞
local meizlhuawu_skill  = {}
meizlhuawu_skill.name = "meizlhuawu"
table.insert(sgs.ai_skills, meizlhuawu_skill)
meizlhuawu_skill.getTurnUseCard = function(self)
	if self:needBear() then return end

	local n = self.player:getHandcardNum()
	if n < 1 then return end
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	local usecards = {}
	local getOverflow = math.max(self:getOverflow(), 0)
	local discards = self:askForDiscard("dummyreason", math.min(getOverflow, 5), math.min(getOverflow, 5))
	if self:needKongcheng() and n < 6 then
		for _, card in ipairs(cards) do
			table.insert(usecards, card:getId())
		end
	else
		for _, card in ipairs(discards) do
			table.insert(usecards, card)
		end
	end
	if #usecards > 0 then
		return sgs.Card_Parse("#meizlhuawucard:" .. table.concat(usecards, "+")..":")
	end
	return nil
end

sgs.ai_skill_use_func["#meizlhuawucard"] = function(card, use, self)
			use.card = card
			return
end



--嫣红
sgs.ai_skill_use["@@meizlyanhong"] = function(self, prompt)
	
	local cards=sgs.QList2Table(self.player:getCards("he"))
	self:sortByUseValue(cards)
	local current = self.room:getCurrent()
	if current then
		if self:isFriend(current) then
			if (current:getJudgingArea():length() > 0) then
				for _, card in ipairs(cards) do
					if card:getSuit() == sgs.Card_Diamond then
						return "#meizlyanhongcard:"..card:getId() ..":"
					end
				end
			end
			if (self:getOverflow(current, true)> 1 and (self.player:getHandcardNum() > 2)) then
				for _, card in ipairs(cards) do
					if card:getSuit() == sgs.Card_Heart and not card:isKindOf("Peach") then
						return "#meizlyanhongcard:"..card:getId() ..":"
					end
				end
			end
		elseif self:isEnemy(current) then
			if (self:getOverflow(current, true)> 0 ) then
				for _, card in ipairs(cards) do
					if card:getSuit() == sgs.Card_Spade  then
						return "#meizlyanhongcard:"..card:getId() ..":"
					end
				end
			end
			if (current:getHandcardNum() < 2) then
				for _, card in ipairs(cards) do
					if card:getSuit() == sgs.Card_Club  then
						return "#meizlyanhongcard:"..card:getId() ..":"
					end
				end
			end
		end
	end
	
			return "."
end



--扬袖
local meizlyangxiu_skill  = {}
meizlyangxiu_skill.name = "meizlyangxiu"
table.insert(sgs.ai_skills, meizlyangxiu_skill)
meizlyangxiu_skill.getTurnUseCard = function(self)
	if self.player:getMark("@meizlyangxiu") == 0 then return nil end
	if #self.enemies == 0 then return nil end
	if not ((self.player:getPile("meizlshan"):length() > 0) and (self.player:getPile("meizlqun"):length() > 0) and (self.player:getPile("meizlhua"):length() > 0))  then return nil end
	if self:isWeak() or (self.player:getPile("meizlhua"):length() > 2) then
        return sgs.Card_Parse("#meizlyangxiucard:.:")
	end
	return nil
end

sgs.ai_skill_use_func["#meizlyangxiucard"] = function(card, use, self)
	local targets = sgs.SPlayerList()
	self:sort(self.enemies, "defense")
	for _, enemy in ipairs(self.enemies) do
		if (targets:length() < self.player:getPile("meizlqun"):length()) then
			if (self:damageIsEffective(enemy) and not self:cantbeHurt(enemy, self.player, 2)) and self.player:inMyAttackRange(enemy) then
				targets:append(enemy)
			end
		else
			break
		end
	end
				use.card = card
				if use.to then use.to = targets end
end

--MEISP 001 娘-赵云



--梨舞（娘-赵云）
local meispliwu_skill = {}
meispliwu_skill.name = "meispliwu"
table.insert(sgs.ai_skills, meispliwu_skill)
meispliwu_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meispliwucard")  then
		if self.player:getMark("@meispliwuprevent") == 0 and self.player:getMark("@meispfeng") >= 2 and self.player:getKingdom() == "shu"  then
				return sgs.Card_Parse("#meispliwucard:.:")
		end
	end
end

sgs.ai_skill_use_func["#meispliwucard"] = function(card,use,self)
					use.card = card
					return
end
--梨舞效果
local meispliwuskill2_skill={}
meispliwuskill2_skill.name="meispliwuskill2"
table.insert(sgs.ai_skills,meispliwuskill2_skill)
meispliwuskill2_skill.getTurnUseCard=function(self)
	local cards = self.player:getCards("h")
	cards=sgs.QList2Table(cards)

	if self.player:getPile("wooden_ox"):length() > 0 then
		for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
			table.insert(cards, sgs.Sanguosha:getCard(id))
		end
	end

	local jink_card

	self:sortByUseValue(cards,true)

	for _,card in ipairs(cards)  do
		if card:isKindOf("Jink") then
			jink_card = card
			break
		end
	end

	if not jink_card then return nil end
	local suit = jink_card:getSuitString()
	local number = jink_card:getNumberString()
	local card_id = jink_card:getEffectiveId()
	local card_str = ("slash:meispliwuskill2[%s:%s]=%d"):format(suit, number, card_id)
	local slash = sgs.Card_Parse(card_str)
	assert(slash)

	return slash

end

sgs.ai_view_as.meispliwuskill2 = function(card, player, card_place)
	if sgs.Sanguosha:getCurrentCardUseReason() ~= sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then return end
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place == sgs.Player_PlaceHand or player:getPile("wooden_ox"):contains(card_id) then
		if card:isKindOf("Jink") then
			return ("slash:meispliwuskill2[%s:%s]=%d"):format(suit, number, card_id)
		elseif card:isKindOf("Slash") then
			return ("jink:meispliwuskill2[%s:%s]=%d"):format(suit, number, card_id)
		end
	end
end


sgs.ai_use_value["meispliwucard"] = 2 --卡牌使用价值
sgs.ai_use_priority["meispliwucard"] = 3.5 --卡牌使用优先级


--瑞雪


local meispruixue_skill = {}
meispruixue_skill.name = "meispruixue"
table.insert(sgs.ai_skills, meispruixue_skill)
meispruixue_skill.getTurnUseCard = function(self)
	if not (self.player:getMark("@meispruixue") >  0 and self.player:getKingdom() == "qun") then return end
	return sgs.Card_Parse("#meispruixuecard:.:")
end
sgs.ai_skill_use_func["#meispruixuecard"] = function(card, use, self)
	self:updatePlayers()
	self:sort(self.enemies,"defense")
	local acard = sgs.Card_Parse("#meispruixuecard:.:") --根据卡牌构成字符串产生实际将使用的卡牌
	assert(acard)
	local defense = 6
	local selfSub = self.player:getHandcardNum() - self.player:getHp()
	if #self.enemies <= 1 then return "." end
	for _, enemy in ipairs(self.enemies) do
		local def = sgs.getDefense(enemy)
		local slash = sgs.Sanguosha:cloneCard("slash")
		local eff = self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self) and self.player:distanceTo(enemy) - math.min(self.player:getHp()-1, self:getCardsNum("Slash")) <= 1
	
		if not self.player:canSlash(enemy, slash, false) then
		elseif throw_weapon and enemy:hasArmorEffect("vine") and not self.player:hasSkill("zonghuo") then
		elseif self:slashProhibit(nil, enemy) then
		elseif eff then
			if enemy:getHp() == 1 and getCardsNum("Jink", enemy) == 0 then best_target = enemy break end
			if def < defense then
				best_target = enemy
				defense = def
			end
			target = enemy
		end
		if selfSub < 0 then return "." end
	end
	if best_target then
		if self:getCardsNum("Slash") > 1  then
			use.card=acard
		end
	end
	if target then
		if self:getCardsNum("Slash") > 1  then
			use.card=acard
		end
	end
	for _, c in sgs.qlist(self.player:getHandcards()) do
        local x = nil
        if isCard("ArcheryAttack", c, self.player) then
            x = sgs.Sanguosha:cloneCard("ArcheryAttack")
        elseif isCard("SavageAssault", c, self.player) then
            x = sgs.Sanguosha:cloneCard("SavageAssault")
        else continue end

        local du = { isDummy = true }
        self:useTrickCard(x, du)
        x:deleteLater()
		if (du.card) and self.player:getHp() > 1 then use.card=acard end
        --if target and (du.card) and self.player:getHp() > 1 then use.card=acard end
    end
end

sgs.ai_use_value["meispruixuecard"] = 2 --卡牌使用价值
sgs.ai_use_priority["meispruixuecard"] = 3 --卡牌使用优先级



local meichunjiefuli_skill = {}
meichunjiefuli_skill.name = "meichunjiefuli"
table.insert(sgs.ai_skills, meichunjiefuli_skill)
meichunjiefuli_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meichunjiefulicard")  then
		if  (self.player:getMark("@meispfeng") > 0) and self.player:getKingdom() ~= "shu"   then
				return sgs.Card_Parse("#meichunjiefulicard:.:")
		end
		if (self.player:getMark("@meispruixue") > 0)  and self.player:getKingdom() ~= "qun"   then
				return sgs.Card_Parse("#meichunjiefulicard:.:")
		end
	end
end

sgs.ai_skill_use_func["#meichunjiefulicard"] = function(card,use,self)
					use.card = card
					return
end

sgs.ai_skill_choice["meispniangzhaoyunkingdom"] = function(self, choices)
	local items = choices:split("+")
    if #items == 1 then
        return items[1]
	else
		if  (self.player:getMark("@meispfeng") > 0 ) and self.player:getKingdom() ~= "shu"   then
			return "shu"
		end
		if (self.player:getMark("@meispruixue") > 0) and self.player:getKingdom() ~= "qun" then
			local defense = 6
			local selfSub = self.player:getHandcardNum() - self.player:getHp()
			if #self.enemies <= 1 then return "shu" end
            local slash = sgs.Sanguosha:cloneCard("slash")
            slash:deleteLater()
			for _, enemy in ipairs(self.enemies) do
				local def = sgs.getDefense(enemy)
				
				local eff = self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self) and self.player:distanceTo(enemy) - math.min(self.player:getHp()-1, self:getCardsNum("Slash")) <= 1
			
				if not self.player:canSlash(enemy, slash, false) then
				elseif throw_weapon and enemy:hasArmorEffect("vine") and not self.player:hasSkill("zonghuo") then
				elseif self:slashProhibit(nil, enemy) then
				elseif eff then
					if enemy:getHp() == 1 and getCardsNum("Jink", enemy) == 0 then best_target = enemy break end
					if def < defense then
						best_target = enemy
						defense = def
					end
					target = enemy
				end
				if selfSub < 0 then return "." end
			end
			if best_target then
				if self:getCardsNum("Slash") > 1  then
					return "qun"
				end
			end
			if target then
				if self:getCardsNum("Slash") > 1  then
					return "qun"
				end
			end
			for _, c in sgs.qlist(self.player:getHandcards()) do
				local x = nil
				if isCard("ArcheryAttack", c, self.player) then
					x = sgs.Sanguosha:cloneCard("ArcheryAttack")
				elseif isCard("SavageAssault", c, self.player) then
					x = sgs.Sanguosha:cloneCard("SavageAssault")
				else continue end

				local du = { isDummy = true }
				self:useTrickCard(x, du)
                x:deleteLater()
				if (du.card) and self.player:getHp() > 1 then return "qun" end
				--if target and (du.card) and self.player:getHp() > 1 then use.card=acard end
			end
		end
    end
    return "shu"
end
sgs.ai_use_value["meichunjiefulicard"] = 2 --卡牌使用价值
sgs.ai_use_priority["meichunjiefulicard"] = 3.5 --卡牌使用优先级








--MEISP 002 SP貂蝉
--拜月（SP貂蝉）
sgs.ai_skill_use["@@meispbaiyue"] = function(self, prompt)
	self:sort(self.friends_noself, "handcard")
	local cards=sgs.QList2Table(self.player:getCards("he"))
	local values, range = {}, self.player:getAttackRange()
	local nplayer = self.player
	for i = 1, self.player:aliveCount() do
		local fediff, add, isfriend = 0, 0
		local np = nplayer
		for value = #self.friends_noself, 1, -1 do
			np = np:getNextAlive()
			if np:objectName() == self.player:objectName() then
				if self:isFriend(nplayer) then fediff = fediff + value
				else fediff = fediff - value
				end
			else
				if self:isFriend(np) then
					fediff = fediff + value
					if isfriend then add = add + 1
					else isfriend = true end
				elseif self:isEnemy(np) then
					fediff = fediff - value
					isfriend = false
				end
			end
		end
		values[nplayer:objectName()] = fediff + add
		nplayer = nplayer:getNextAlive()
	end
	local function get_value(a)
	local ret = 0
		for _, enemy in ipairs(self.enemies) do
			if a:objectName() ~= enemy:objectName() and a:distanceTo(enemy) <= range then ret = ret + 1 end
		end
		return ret
	end
	local function compare_func(a,b)
		if values[a:objectName()] ~= values[b:objectName()] then
			return values[a:objectName()] > values[b:objectName()]
		else
			return get_value(a) > get_value(b)
		end
	end
	local players = sgs.QList2Table(self.room:getAlivePlayers())
	table.sort(players, compare_func)
	if values[players[1]:objectName()] > 0 and players[1]:objectName() ~= self.player:objectName() then
		return "#meispbaiyuecard:.:->"..players[1]:objectName()
	end
			return "."
end


--梳妆（SP貂蝉）
sgs.ai_skill_playerchosen["meispshuzhuang"] = function(self, targets)
	local targets = sgs.QList2Table(targets)
	self:sort(targets, "hp")
	for _,p in ipairs(targets) do
		if self:isEnemy(p) then
			return p
		end
	end
	for _,p in ipairs(targets) do
		return p
	end
end
sgs.ai_playerchosen_intention["meispshuzhuang"] = 80


--MEISP 003 娘‧吕布
--虓姬（娘‧吕布）
sgs.ai_skill_invoke.meispxiaoji = function(self, data)
	local target = data:toPlayer()
	if self:isEnemy(target) then
		if self:doNotDiscard(target) then
			return false
		end
	end
	return not self:isFriend(target)
end

sgs.ai_skill_use["@@meispxiaoji"] = function(self, prompt)
	local cards = sgs.QList2Table(self.player:getHandcards())
	local card
	if (self.player:getHandcardNum() > 3) then
		self:sortByKeepValue(cards)
		for _, cd in ipairs(cards) do
			if not cd:isKindOf("Peach") then 
				card = cd
				break
			end
		end
	local target 
	local slash = sgs.Sanguosha:cloneCard("slash")
    slash:deleteLater()
	local dummyuse = { isDummy = true, to = sgs.SPlayerList() }
	self:useBasicCard(slash, dummyuse)
	if not dummyuse.to:isEmpty() then
		for _, p in sgs.qlist(dummyuse.to) do
			target = p
		end
	end
	if target and card then
		return "#meispxiaojicard:"..card:getEffectiveId()..":->"..target:objectName()
	end
else
		for _, enemy in ipairs(self.enemies) do
			if (enemy:getPile("meispji"):length() > 0) and not enemy:isNude() then
				local ints = sgs.QList2Table(enemy:getPile("meispji"))
				local x = math.min(enemy:getPile("meispji"):length(), enemy:getCards("he"):length())
				local cardx = {}
				for _, key in sgs.list(enemy:getPileNames()) do
					for _, id in sgs.qlist(enemy:getPile(key)) do
						cards:append(sgs.Sanguosha:getCard(id))
					end
				end
				for i = 1, x, 1 do
					table.insert(cardx, tostring(enemy:getPile("meispji")[i]))
				end
				return "#meispxiaojicard:"..table.concat(cardx, "+")..":->"..enemy:objectName()
			end
		end
end
return "."
end

--掷戟（娘‧吕布）
sgs.ai_skill_invoke.meispzhiji = function(self, data)
	local target = data:toPlayer()
	local Piles =  target:getPileNames()
	local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
    dummy:deleteLater()
	for i=1,#Piles do 
		for _,cd in sgs.qlist(target:getPile(Piles[i])) do
			dummy:addSubcard(cd)
		end
	end
	if self:isEnemy(target) then
		if (target:getPile("meispji"):length() > 0) then
			return false
		end
		if dummy:subcardsLength()> 1 then
			return true
		end
		return false
	end
	if self:isFriend(target) then
		if (target:getPile("meispji"):length() > 0) then
			return true
		end
		if dummy:subcardsLength()> 0 then
			return false
		end
		return true
	end
	return false
end



sgs.ai_skill_use["@@meispzhiji"] = function(self, prompt)
	local targets = {}
	for _,enemy in ipairs(self.enemies) do
		for _, key in sgs.list(enemy:getPileNames()) do
            for _, id in sgs.qlist(enemy:getPile(key)) do
				if not table.contains(targets, enemy) then
					table.insert(targets, enemy)
				end
            end
        end
	end
	local target = self:findPlayerToDiscard("he", false, true, targets, false)
	if target then
		return "#meispzhijicard:.:->"..target:objectName()
	end
			return "."
end


--珠联璧合 SP貂蝉 — 娘-吕布
--拜月（珠联璧合 SP貂蝉 — 娘-吕布）

sgs.ai_skill_invoke.meispzlbhbaiyue = function(self, data)
	local slash = sgs.Sanguosha:cloneCard("Slash")
    slash:deleteLater()
	if self:UseAoeSkillValue_mei(sgs.DamageStruct_Normal, nil, slash) > 0 or self:isWeak() then
		return true
	end
	return false
end

sgs.ai_skill_playerchosen.meispzlbhshuzhuang = function(self, targets)
	self:sort(self.enemies, "hp")
	for _, enemy in ipairs(self.enemies) do
		return enemy
	end
	return targets[1]
end


sgs.ai_playerchosen_intention["meispzlbhshuzhuang"] = function(self, from, to)
	sgs.updateIntention(from, to, 80)
end



--MEISE 001 魔界七将‧玛门‧郭女王

--掠夺（魔界七将‧玛门‧郭女王）

sgs.ai_skill_cardask["@meizlselueduo"] = function(self, data)
    local cards = sgs.QList2Table(self.player:getHandcards())
	
    local current = self.room:getCurrent()
	local xwcard = nil
	if current and self:isEnemy(current) and current:getHandcardNum() - current:getHp() > 2 then 
	--local cards = self.player:getCards("h")
	--cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)

    for _, card in ipairs(cards) do
		if card:isKindOf("TrickCard") then
				xwcard = card
			end
			if xwcard then
				break
			end
		end
    end
    if xwcard then return "$" .. xwcard:getEffectiveId() 
	else 
		return "."
	end
end


sgs.ai_skill_invoke.meizlselueduo = function(self, data)
	local target = data:toPlayer()
	if target and self:isEnemy(target) and target:getHandcardNum() - target:getHp() > 2 then 
		return not self:isWeak()
	end
	return false
end

sgs.ai_choicemade_filter.skillInvoke.meizlselueduo = function(self, player, promptlist)
	local current = self.room:getCurrent()
	if current then
		if promptlist[#promptlist] == "yes" and player:getMark("@meizlsetanlan") == 0 then
			sgs.updateIntention(player, current, 80)
		end
	end
end

sgs.ai_choicemade_filter.cardResponded["@meizlselueduo"] = function(self, player, promptlist)
	if promptlist[#promptlist] ~= "_nil_" then
		--local current = self.player:getTag("sidi_target"):toPlayer()
		local current = self.room:getCurrent()
		if not current then return end
		sgs.updateIntention(player, current, 80)
	end
end

--贪婪（魔界七将‧玛门‧郭女王）

local meizlsetanlan_skill = {}
meizlsetanlan_skill.name = "meizlsetanlan"
table.insert(sgs.ai_skills, meizlsetanlan_skill)
meizlsetanlan_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meizlsetanlancard")  then
		if self.player:getMark("@meizlsetanlan") == 0 and self.player:getHp() <= 2   then
				return sgs.Card_Parse("#meizlsetanlancard:.:")
		end
	end
end

sgs.ai_skill_use_func["#meizlsetanlancard"] = function(card,use,self)
					use.card = card
					return
end

--诱杀（魔界七将‧玛门‧郭女王）
function SmartAI:findyoushaTarget(card_name, use)
local lord = self.room:getLord()
	local duel = sgs.Sanguosha:cloneCard("duel")


	if self.role == "rebel" or (self.role == "renegade" and sgs.current_mode_players["loyalist"] + 1 > sgs.current_mode_players["rebel"]) then

		if lord and lord:isMale() and not lord:isNude() and lord:objectName() ~= self.player:objectName() then      -- 优先离间1血忠和主
			self:sort(self.enemies, "handcard")
			local e_peaches = 0
			local loyalist

			for _, enemy in ipairs(self.enemies) do
				e_peaches = e_peaches + getCardsNum("Peach", enemy)
				if enemy:getHp() == 1  and enemy:objectName() ~= lord:objectName()
				and enemy:isMale() and not loyalist then
					loyalist = enemy
					break
				end
			end

			if loyalist and e_peaches < 1 then return loyalist, lord end
		end

		if #self.friends_noself >= 2 and self:getAllPeachNum() < 1 then     --收友方反
			local nextplayerIsEnemy
			local nextp = self.player:getNextAlive()
			for i = 1, self.room:alivePlayerCount() do
				if not self:willSkipPlayPhase(nextp) then
					if not self:isFriend(nextp) then nextplayerIsEnemy = true end
					break
				else
					nextp = nextp:getNextAlive()
				end
			end
			if nextplayerIsEnemy then
				local round = 50
				local to_die, nextfriend
				self:sort(self.enemies, "hp")

				for _, a_friend in ipairs(self.friends_noself) do   -- 目标1：寻找1血友方
					if a_friend:getHp() == 1 and a_friend:isKongcheng() and not self:hasSkills("kongcheng|yuwen", a_friend) and a_friend:isMale() then
						for _, b_friend in ipairs(self.friends_noself) do       --目标2：寻找位于我之后，离我最近的友方
							if b_friend:objectName() ~= a_friend:objectName() and b_friend:isMale() and self:playerGetRound(b_friend) < round then

								round = self:playerGetRound(b_friend)
								to_die = a_friend
								nextfriend = b_friend

							end
						end
						if to_die and nextfriend then break end
					end
				end

				if to_die and nextfriend then return to_die, nextfriend end
			end
		end
	end

	if lord and self:isFriend(lord) and lord:hasSkill("hunzi") and lord:getHp() == 2 and lord:getMark("hunzi") == 0 and lord:objectName() ~= self.player:objectName() then
		local enemycount = self:getEnemyNumBySeat(self.player, lord)
		local peaches = self:getAllPeachNum()
		if peaches >= enemycount then
			local f_target, e_target
			for _, ap in sgs.qlist(self.room:getOtherPlayers(self.player)) do
				if ap:objectName() ~= lord:objectName() and ap:isMale()  then
					if self:hasSkills("jiang|nosjizhi|jizhi", ap) and self:isFriend(ap)  then
						if not use.isDummy then lord:setFlags("AIGlobal_NeedToWake") end
						return lord, ap
					elseif self:isFriend(ap) then
						f_target = ap
					else
						e_target = ap
					end
				end
			end
			if f_target or e_target then
				local target
				if f_target  then
					target = f_target
				elseif e_target  then
					target = e_target
				end
				if target then
					if not use.isDummy then lord:setFlags("AIGlobal_NeedToWake") end
					return lord, target
				end
			end
		end
	end

	local shenguanyu = self.room:findPlayerBySkillName("wuhun")
	if shenguanyu and shenguanyu:isMale() and shenguanyu:objectName() ~= self.player:objectName() then
		if self.role == "rebel" and lord and lord:isMale() and lord:objectName() ~= self.player:objectName() and not lord:hasSkill("jueqing")  then
			return shenguanyu, lord
		elseif self:isEnemy(shenguanyu) and #self.enemies >= 2 then
			for _, enemy in ipairs(self.enemies) do
				if enemy:objectName() ~= shenguanyu:objectName() and enemy:isMale()		 then
					return shenguanyu, enemy
				end
			end
		end
	end

	if not self.player:hasUsed(card_name) then
		self:sort(self.enemies, "defense")
		local males, others = {}, {}
		local first, second
		local zhugeliang_kongcheng, xunyu

		for _, enemy in ipairs(self.enemies) do
			if enemy:isMale()  then
				if enemy:hasSkill("kongcheng") and enemy:isKongcheng() then zhugeliang_kongcheng = enemy
				elseif enemy:hasSkill("jieming") then xunyu = enemy
				else
					for _, anotherenemy in ipairs(self.enemies) do
						if anotherenemy:isMale() and anotherenemy:objectName() ~= enemy:objectName() then
							if #males == 0  then
								if not (enemy:hasSkill("hunzi") and enemy:getMark("hunzi") < 1 and enemy:getHp() == 2) then
									table.insert(males, enemy)
								else
									table.insert(others, enemy)
								end
							end
							if #males == 1  then
								if not anotherenemy:hasSkills("nosjizhi|jizhi|jiang") then
									table.insert(males, anotherenemy)
								else
									table.insert(others, anotherenemy)
								end
								if #males >= 2 then break end
							end
						end
					end
				end
				if #males >= 2 then break end
			end
		end

		if #males >= 1 and sgs.ai_role[males[1]:objectName()] == "rebel" and males[1]:getHp() == 1 then
			if lord and self:isFriend(lord) and lord:isMale() and lord:objectName() ~= males[1]:objectName()  and lord:objectName() ~= self.player:objectName() and lord:isAlive()		then
				return males[1], lord
			end

		end

		if #males == 1 then
			if isLord(males[1]) and sgs.turncount <= 1 and self.role == "rebel" and self.player:aliveCount() >= 3 then
				local p_slash, max_p, max_pp = 0
				for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
					if p:isMale() and not self:isFriend(p) and p:objectName() ~= males[1]:objectName()  then
						if p:getKingdom() == males[1]:getKingdom() then
							max_p = p
							break
						elseif not max_pp then
							max_pp = p
						end
					end
				end
				if max_p then table.insert(males, max_p) end
				if max_pp and #males == 1 then table.insert(males, max_pp) end
			end
		end

		if #males == 1 then
			if #others >= 1  then
				table.insert(males, others[1])
			elseif xunyu  then
				if getCardsNum("Slash", males[1]) < 1 then
					table.insert(males, xunyu)
				else
					local drawcards = 0
					for _, enemy in ipairs(self.enemies) do
						local x = enemy:getMaxHp() > enemy:getHandcardNum() and math.min(5, enemy:getMaxHp() - enemy:getHandcardNum()) or 0
						if x > drawcards then drawcards = x end
					end
					if drawcards <= 2 then
						table.insert(males, xunyu)
					end
				end
			end
		end

		if #males == 1 and #self.friends_noself > 0 then
			self:log("Only 1")
			first = males[1]
			if zhugeliang_kongcheng  then
				table.insert(males, zhugeliang_kongcheng)
			end
		end

		if #males >= 2 then
			first = males[1]
			second = males[2]
			if lord and first:getHp() <= 1 then
				if lord:isMale()  then
					if self.role=="rebel" and not first:isLord()  then
						second = lord
					else
						if ( (self.role == "loyalist" or self.role == "renegade") and not self:hasSkills("ganglie|enyuan|neoganglie|nosenyuan", first) )  then
							second = lord
						end
					end
				end
			end
		end
		if first and second and first:objectName() ~= second:objectName() then
				return first, second
			end
	end
end

function SmartAI:getLijianCard()
	local card_id
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local lightning = self:getCard("Lightning")

	if self:needToThrowArmor() then
		card_id = self.player:getArmor():getId()
	elseif self.player:getHandcardNum() > self.player:getHp() then
		if lightning and not self:willUseLightning(lightning) then
			card_id = lightning:getEffectiveId()
		else
			for _, acard in ipairs(cards) do
				if (acard:isKindOf("BasicCard") or acard:isKindOf("EquipCard") or acard:isKindOf("AmazingGrace"))
					and not acard:isKindOf("Peach") then
					card_id = acard:getEffectiveId()
					break
				end
			end
		end
	elseif not self.player:getEquips():isEmpty() then
		local player = self.player
		if player:getWeapon() then card_id = player:getWeapon():getId()
		elseif player:getOffensiveHorse() then card_id = player:getOffensiveHorse():getId()
		elseif player:getDefensiveHorse() then card_id = player:getDefensiveHorse():getId()
		elseif player:getArmor() and player:getHandcardNum() <= 1 then card_id = player:getArmor():getId()
		end
	end
	if not card_id then
		if lightning and not self:willUseLightning(lightning) then
			card_id = lightning:getEffectiveId()
		else
			for _, acard in ipairs(cards) do
				if (acard:isKindOf("BasicCard") or acard:isKindOf("EquipCard") or acard:isKindOf("AmazingGrace"))
				  and not acard:isKindOf("Peach") then
					card_id = acard:getEffectiveId()
					break
				end
			end
		end
	end
	return card_id
end


local meizlseyousha_skill = {}
meizlseyousha_skill.name = "meizlseyousha"
table.insert(sgs.ai_skills, meizlseyousha_skill)
meizlseyousha_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#meizlseyoushacard") or self.player:isNude() then
		return
	end
	local card_id = self:getLijianCard()
	if card_id then return sgs.Card_Parse("#meizlseyoushacard:" .. card_id..":") end
end

sgs.ai_skill_use_func["#meizlseyoushacard"] = function(card, use, self)
	local first, second = self:findyoushaTarget("meizlseyoushacard", use)
	
	
	if first and second then
		use.card = card
		if use.to then
			use.to:append(first)
			use.to:append(second)
		end
	end
end

sgs.ai_use_value["#meizlseyoushacard"] = 8.5
sgs.ai_use_priority["#meizlseyoushacard"] = 4






--MEISE 002 魔界七将‧萨麦尔‧董白
function SmartAI:UseAoeSkillValue_mei(element, players, card)
	element = element or sgs.DamageStruct_Normal
	local friends = {}
	local enemies = {}
	local good = 0

	players = players or sgs.QList2Table(self.room:getOtherPlayers(self.player))

	for _, ap in ipairs(players) do
		if self:isFriend(ap) then table.insert(friends, ap)
		else table.insert(enemies, ap) end
	end

	good = (#enemies - #friends) * 2
	if #enemies == 0 then return -100 end
	if element == sgs.DamageStruct_Thunder then
		for _, ap in sgs.qlist(self.room:getAlivePlayers()) do
			if ap:hasSkill("TH_yuyiruokong") then
				if self:isFriend(ap) then good = good + ap:getCardCount(true)
				else good = good - ap:getCardCount(true)
				end
			end
		end
	end
	if element == sgs.DamageStruct_Fire then
		for _,ap in sgs.qlist(self.room:getAlivePlayers()) do
			if ap:hasSkill("TH_Meltdown") then
				for _, friend in ipairs(friends) do
					if friend:getHandcardNum() > 0 then good = good - 0.5 end
				end
				for _, enemy in ipairs(enemies) do
					if enemy:getHandcardNum() > 0 then good = good + 0.5 end
				end
			end
		end
	end




	if self.player:hasSkill("TH_hongsehuanxiangxiang") then good = good + 1 end

	if self.player:getRole() == "renegade" then good = good + 0.5 end
	if self.player:getRole() == "rebel" then good = good + 0.8 end

	local who
	for _, player in ipairs(players) do
		if player:isChained() and self:damageIsEffective(player, element) and not who then who = player end
		local value = 0
		if player:getRole() == "lord" then value = value - 0.5 end
		if not self:damageIsEffective(player, element) then
			value = value + 1
			if self:isEnemy(player) and #enemies == 1 or self:isFriend(player) and #friends == 1 then value = value + 100 end
		end
		if player:getHp() == 1 and self:getAllPeachNum() == 0 then
			if player:getRole() == "lord" then value = value - 100 else value = value - 2 end
		end
		if self:getDamagedEffects(player, self.player) or self:needToLoseHp(player, self.player) then value = value + 0.5 end
		--if self:undeadplayer(player) then value = value + 0.5 end
		--if self:saveplayer(player) then value = value + 0.5 end

		if self:isFriend(player) then good = good + value else good = good - value end
	end





--	if who and not self.player:hasSkill("jueqing") and (element == sgs.DamageStruct_Thunder or element == sgs.DamageStruct_Fire) then
		-- local damage = {}
		-- damage.from = self.player
		-- damage.to = who
		-- damage.nature = element
		-- damage.card = card
		-- damage.damage = 1
		-- good = good + self:isGoodChain(damage)
	--	good = good + self:isGoodChainTarget(who, self.player, element, 1, nil, true)
--	end
	return good
end

--炼狱（魔界七将‧萨麦尔‧董白）
local meizlselianyu_skill = {}--凤翼天翔
meizlselianyu_skill.name = "meizlselianyu"
table.insert(sgs.ai_skills, meizlselianyu_skill)
meizlselianyu_skill.getTurnUseCard = function(self, inclusive)
	if not self.player:hasUsed("#meizlselianyucard") and (self.player:getMark("@meizlselianyu") > 0 or self.player:getMark("@meizlsebaonu") > 0) then
			local TH_skillcard = sgs.Card_Parse("#meizlselianyucard:.:")
			return TH_skillcard
	end
end
sgs.ai_skill_use_func["#meizlselianyucard"] = function(card, use, self)--凤翼天翔
	local jiu
	if not self.player:hasUsed("Analeptic") and self:getCard("Analeptic") then
		jiu = self:getCard("Analeptic")
	end
	local fs = self:getCard("FireSlash")
	if self:UseAoeSkillValue_mei(sgs.DamageStruct_Fire, nil, fs) > 0 then
		if jiu and not use.isDummy then use.card = jiu return end
		use.card = card
		return
	end
end

sgs.ai_use_priority["meizlselianyucard"] = 3


--暴怒（魔界七将‧萨麦尔‧董白）

local meizlsebaonu_skill = {}
meizlsebaonu_skill.name = "meizlsebaonu"
table.insert(sgs.ai_skills, meizlsebaonu_skill)
meizlsebaonu_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meizlsebaonucard")  then
		if self.player:getMark("@meizlsebaonu") == 0 and self.player:isKongcheng() and  self.player:getMark("@meizlselianyu") == 0  then
				return sgs.Card_Parse("#meizlsebaonucard:.:")
		end
	end
end

sgs.ai_skill_use_func["#meizlsebaonucard"] = function(card,use,self)
					use.card = card
					return
end




--MEISE 003 魔界七将‧利维坦‧张春华

--惭恚（魔界七将‧利维坦‧张春华）

sgs.ai_skill_playerchosen.meizlsecanhui = function(self, targets)
	local targets = sgs.QList2Table(targets)
	self:sort(targets, "defense")
	for _, p in ipairs(targets) do
		if self:isEnemy(p) then
			return p
		end
	end
    return nil
end


--嫉妒（魔界七将‧利维坦‧张春华）
local meizlsejidu_skill = {}
meizlsejidu_skill.name = "meizlsejidu"
table.insert(sgs.ai_skills, meizlsejidu_skill)
meizlsejidu_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meizlsejiducard")  then
		if self.player:getMark("@meizlsejidu") == 0 and not self.player:isKongcheng() then
				return sgs.Card_Parse("#meizlsejiducard:.:")
		end
	end
end

sgs.ai_skill_use_func["#meizlsejiducard"] = function(card,use,self)
	local spade = {}
	local heart = {}
	local club = {}
	local diamond = {}
	local cards = sgs.QList2Table(self.player:getCards("he"))
	for _,card in ipairs(cards) do
		if card:getSuit() == sgs.Card_Spade and (#spade < 4)  then
		table.insert(spade, card:getEffectiveId())
		elseif card:getSuit() == sgs.Card_Heart and (#heart < 4) then
		table.insert(heart, card:getEffectiveId())
		elseif card:getSuit() == sgs.Card_Club and (#club < 4) then
		table.insert(club, card:getEffectiveId())
		elseif card:getSuit() == sgs.Card_Diamond and (#diamond < 4)  then
		table.insert(diamond, card:getEffectiveId())
		end
	end
	local card_str
	local can_use  =false
	if (#spade > 3) then
		card_str = string.format("#meizlsejiducard:%s:", table.concat(spade, "+"))
		can_use = true
	elseif (#club > 3) then
		card_str = string.format("#meizlsejiducard:%s:", table.concat(club, "+"))
		can_use = true
	elseif (#diamond > 3) then
		card_str = string.format("#meizlsejiducard:%s:", table.concat(diamond, "+"))
		can_use = true
	elseif (#heart > 3) then
		card_str = string.format("#meizlsejiducard:%s:", table.concat(heart, "+"))
		can_use = true
	end
			if can_use then
			local acard = sgs.Card_Parse(card_str)
			use.card = acard
					return
					end
end

sgs.ai_use_value["meizlsejiducard"] = sgs.ai_use_value.ExNihilo - 0.1
sgs.ai_use_priority["meizlsejiducard"] = sgs.ai_use_priority.ExNihilo - 0.1






--MEISE 004 魔界七将‧阿斯莫德‧孙鲁班

--荡漾（魔界七将‧阿斯莫德‧孙鲁班）
local meizlsedangyang_skill = {}
meizlsedangyang_skill.name = "meizlsedangyang"
table.insert(sgs.ai_skills, meizlsedangyang_skill)
meizlsedangyang_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meizlsedangyangcard")  then
				return sgs.Card_Parse("#meizlsedangyangcard:.:")
	end
end

sgs.ai_skill_use_func["#meizlsedangyangcard"] = function(card,use,self)
					use.card = card
					return
end

sgs.ai_use_value["meizlsedangyangcard"] = sgs.ai_use_value.ExNihilo - 0.1
sgs.ai_use_priority["meizlsedangyangcard"] = sgs.ai_use_priority.ExNihilo - 0.1

--淫欲（魔界七将‧阿斯莫德‧孙鲁班）

local meizlseyinyu_skill = {}
meizlseyinyu_skill.name = "meizlseyinyu"
table.insert(sgs.ai_skills, meizlseyinyu_skill)
meizlseyinyu_skill.getTurnUseCard = function(self)
	if self.player:getMark("@meizlseyinyu") == 0 and self.player:getMark("meizlseyaohuo") > 0  then
				return sgs.Card_Parse("#meizlseyinyucard:.:")
	end
end

sgs.ai_skill_use_func["#meizlseyinyucard"] = function(card,use,self)
					use.card = card
					return
end



sgs.ai_use_value["meizlsejiducard"] =  sgs.ai_use_value.ExNihilo
sgs.ai_use_priority["meizlsejiducard"] =  sgs.ai_use_priority.ExNihilo




--MEISE 005 魔界七将‧路西法‧蔡夫人

--破晓（魔界七将‧路西法‧蔡夫人）
meizlsepoxiao_skill ={}
meizlsepoxiao_skill.name = "meizlsepoxiao"
table.insert(sgs.ai_skills,meizlsepoxiao_skill)
meizlsepoxiao_skill.getTurnUseCard = function(self,inclusive)
	if self:needBear() then return end
	if self.player:getMark("@meizlseaoman") > 0 then
		if not self.player:hasUsed("#meizlsepoxiaocard") and not self.player:isKongcheng() then return sgs.Card_Parse("#meizlsepoxiaocard:.:") end
	else
		for _,p in ipairs(self.enemies) do
			if p:getMark("@meizlsepoxiaotarget") < 1 and not p:isKongcheng() then
				return sgs.Card_Parse("#meizlsepoxiaocard:.:")
			end
		end
	end
end

sgs.ai_skill_use_func["#meizlsepoxiaocard"] = function(card, use, self)
	 local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByUseValue(cards,true)
	self:sort(self.enemies, "handcard")
	for _, enemy in ipairs(self.enemies) do
		if self.player:canPindian(enemy) and ((enemy:getMark("@meizlsepoxiaotarget") < 1) or (self.player:getMark("@meizlseaoman") > 0 )) and not enemy:isKongcheng()  then
			if use.to then use.to:append(enemy) break end
		end
	end
	for _, card in ipairs(cards) do
		if not card:isKindOf("Peach") and not card:isKindOf("ExNihilo") and not card:isKindOf("Jink") then
			use.card = sgs.Card_Parse("#meizlsepoxiaocard:"..card:getId()..":")
		end
	end
	if use.to and use.to:length() > 0 then return end
	return nil
end



function sgs.ai_skill_pindian.meizlsepoxiao(minusecard, self, requestor)
	if requestor:getHandcardNum() == 1 then
		local cards = sgs.QList2Table(self.player:getHandcards())
		self:sortByKeepValue(cards)
		return cards[1]
	end
	local maxcard = self:getMaxCard()
	return self:isFriend(requestor) and self:getMinCard() or ( maxcard:getNumber() < 6 and  minusecard or maxcard )
end


--傲慢（魔界七将‧路西法‧蔡夫人）
local meizlseaoman_skill = {}
meizlseaoman_skill.name = "meizlseaoman"
table.insert(sgs.ai_skills, meizlseaoman_skill)
meizlseaoman_skill.getTurnUseCard = function(self)
	if self.player:getMark("@meizlseaoman") == 0 and self.player:getHp() == 1  then
				return sgs.Card_Parse("#meizlseaomancard:.:")
	end
end

sgs.ai_skill_use_func["#meizlseaomancard"] = function(card,use,self)
					use.card = card
					return
end


--MEISE 006 魔界七将‧别西卜‧吕玲琦
--暴食（魔界七将‧别西卜‧吕玲琦）
local meizlsebaoshi_skill = {}
meizlsebaoshi_skill.name = "meizlsebaoshi"
table.insert(sgs.ai_skills, meizlsebaoshi_skill)
meizlsebaoshi_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meizlsebaoshicard")  then
		if self.player:getMark("@meizlsebaoshi") == 0 and not self.player:isKongcheng() then
				return sgs.Card_Parse("#meizlsebaoshicard:.:")
		end
	end
end

sgs.ai_skill_use_func["#meizlsebaoshicard"] = function(card,use,self)
	local use_card = {}
	local cards = sgs.QList2Table(self.player:getCards("he"))
	for _,card in ipairs(cards) do
		if card:isKindOf("EquipCard") and (#use_card < 4)  then
		table.insert(use_card, card:getEffectiveId())
		end
	end
	local card_str
	local can_use  =false
	if (#use_card > 3) then
		card_str = string.format("#meizlsebaoshicard:%s:", table.concat(use_card, "+"))
			local acard = sgs.Card_Parse(card_str)
			use.card = acard
					return
					end
end

sgs.ai_use_value["meizlsebaoshicard"] = sgs.ai_use_value.ExNihilo - 0.1
sgs.ai_use_priority["meizlsebaoshicard"] = sgs.ai_use_priority.ExNihilo - 0.1

--MEISE 007 魔界七将‧贝尔芬格‧大乔
local meizlselanduo_skill = {}
meizlselanduo_skill.name = "meizlselanduo"
table.insert(sgs.ai_skills, meizlselanduo_skill)
meizlselanduo_skill.getTurnUseCard = function(self)
	if self.player:getMark("@meizlselanduo") == 0 and self.player:getHandcardNum() >= 10  then
				return sgs.Card_Parse("#meizlselanduocard:.:")
	end
end

sgs.ai_skill_use_func["#meizlselanduocard"] = function(card,use,self)
					use.card = card
					return
end



sgs.ai_use_value["meizlselanduocard"] = sgs.ai_use_value.ExNihilo - 0.1
sgs.ai_use_priority["meizlselanduocard"] = sgs.ai_use_priority.ExNihilo - 0.1





--大乔‧升华
sgs.ai_skill_use["@@meizlshchunshen"] = function(self, data, method)
	if not method then method = sgs.Card_MethodDiscard end
	local dmg
	
	if data == "@meizlshchunshen-card" then
		dmg = self.room:getTag("meizlshchunshenDamage"):toDamage()
	else
		dmg = data
	end

	if not dmg then self.room:writeToConsole(debug.traceback()) return "." end

	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards, true)
	self:sortByUseValue(cards, true)

	

	self:sort(self.enemies, "hp")

	for _, enemy in ipairs(self.enemies) do
		if ( enemy:isAlive()) and (self.player:distanceTo(enemy)== 1) and enemy:getHp() >= self.player:getHp() then
			if  self:canAttack(enemy, dmg.from or self.room:getCurrent(), dmg.nature)
				and not (dmg.card and dmg.card:getTypeId() == sgs.Card_TypeTrick and enemy:hasSkill("wuyan")) then
				
				return "#meizlshchunshencard:.:->" .. enemy:objectName()
			end
		end
	end

	for _, friend in ipairs(self.friends_noself) do
		if (friend:isAlive()) and (self.player:distanceTo(friend)== 1) and friend:getHp() >= self.player:getHp()  then
			if friend:isChained() and dmg.nature ~= sgs.DamageStruct_Normal and not self:isGoodChainTarget(friend, dmg.from, dmg.nature, dmg.damage, dmg.card) then
			elseif  (friend:hasSkills("yiji|buqu|nosbuqu|shuangxiong|zaiqi|yinghun|jianxiong|fangzhu")
						or self:getDamagedEffects(friend, dmg.from or self.room:getCurrent())
						or self:needToLoseHp(friend)) then
				return "#meizlshchunshencard:.:->" .. friend:objectName()
				elseif dmg.card and dmg.card:getTypeId() == sgs.Card_TypeTrick and friend:hasSkill("wuyan") and friend:getLostHp() > 1 then
					return "#meizlshchunshencard:.:->" .. friend:objectName()
			elseif hasBuquEffect(friend) then return "#meizlshchunshencard:.:->" .. friend:objectName() end
		end
	end

	for _, enemy in ipairs(self.enemies) do
		if  enemy:isAlive() and (self.player:distanceTo(enemy)== 1) and enemy:getHp() >= self.player:getHp()  then
			if  self:canAttack(enemy, (dmg.from or self.room:getCurrent()), dmg.nature)
				and not (dmg.card and dmg.card:getTypeId() == sgs.Card_TypeTrick and enemy:hasSkill("wuyan")) then
				return "#meizlshchunshencard:.:->" .. enemy:objectName() end
		end
	end

	for i = #self.enemies, 1, -1 do
		local enemy = self.enemies[i]
		if not enemy:isWounded() and not self:hasSkills(sgs.masochism_skill, enemy) and enemy:isAlive() and (self.player:distanceTo(enemy)== 1) and enemy:getHp() >= self.player:getHp()
			and self:canAttack(enemy, dmg.from or self.room:getCurrent(), dmg.nature)
			and (not (dmg.card and dmg.card:getTypeId() == sgs.Card_TypeTrick and enemy:hasSkill("wuyan") and enemy:getLostHp() > 0) or self:isWeak()) then
			return "#meizlshchunshencard:.:->" .. enemy:objectName()
		end
	end

	return "."
end

sgs.ai_card_intention.meizlshchunshencard = function(self, card, from, tos)
	local to = tos[1]
	if self:getDamagedEffects(to) or self:needToLoseHp(to) then return end
	local intention = 10
	if hasBuquEffect(to) then intention = 0
	elseif (to:getHp() >= 2 and to:hasSkills("yiji|shuangxiong|zaiqi|yinghun|jianxiong|fangzhu"))
		or (to:getHandcardNum() < 3 and (to:hasSkill("nosrende") or (to:hasSkill("rende") and not to:hasUsed("RendeCard")))) then
		intention = 0
	end
	sgs.updateIntention(from, to, intention)
end

function sgs.ai_slash_prohibit.meizlshchunshen(self, from, to)
	if from:hasSkill("jueqing") or (from:hasSkill("nosqianxi") and from:distanceTo(to) == 1) then return false end
	if from:hasFlag("NosJiefanUsed") then return false end
	if self:isFriend(to, from) then return false end
	return self:cantbeHurt(to, from)
end


function sgs.ai_cardneed.meizlshchunshen(to, card, self)
	return to:getHandcardNum() < 2
end


--落英缤纷
meizlluoyingbinfen_skill = {}
meizlluoyingbinfen_skill.name = "meizlluoyingbinfen"
table.insert(sgs.ai_skills, meizlluoyingbinfen_skill)
meizlluoyingbinfen_skill.getTurnUseCard = function(self)
	if self.player:getMark("@meizldaqiaomark") < 15 then return end
	if self.room:getMode() == "_mini_13" then return sgs.Card_Parse("#meizlluoyingbinfencard:.:") end
	local good, bad = 1, 0
	local lord = self.room:getLord()
	if lord and self.role ~= "rebel" and (lord:getHandcardNum() > lord:getHp()) and lord:isMale() then return end
	for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if (player:getHandcardNum() > 0) and player:isMale() then
			if self:isFriend(player) then bad = bad + 1
			else good = good + 1
			end
		end
	end
	if good == 0 then return end

	for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if player:isMale() then
		local hp = math.max(player:getHp(), 1)
			if getCardsNum("Analeptic", player) > 0 then
				if self:isFriend(player) then good = good + 1.0 / hp
				else bad = bad + 1.0 / hp
				end
			end
				if self:isFriend(player) then good = good + math.max(getCardsNum("Peach", player), 1)
				else bad = bad + math.max(getCardsNum("Peach", player), 1)
				end
		end
		
	end

	if good > bad then return sgs.Card_Parse("#meizlluoyingbinfencard:.:") end
end

sgs.ai_skill_use_func["#meizlluoyingbinfencard"]=function(card,use,self)
	use.card = card
end

sgs.dynamic_value.damage_card["#meizlluoyingbinfencard"] = true



-- 蔡文姬‧升华
--胡笳‧升华

local meizlshhujia_skill = {}
meizlshhujia_skill.name = "meizlshhujia"
table.insert(sgs.ai_skills,meizlshhujia_skill)
meizlshhujia_skill.getTurnUseCard = function(self)
	if self:needBear() then return end
	if not self.player:hasUsed("#meizlshhujiacard") and not self.player:isKongcheng() then return sgs.Card_Parse("#meizlshhujiacard:.:") end
end

sgs.ai_skill_use_func["#meizlshhujiacard"] = function(card,use,self)
	self:sort(self.enemies, "handcard")
	local max_card = self:getMaxCard(self.player)
	local max_point = max_card:getNumber()
	if self.player:hasSkill("kongcheng") and self.player:getHandcardNum() == 1 then
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isKongcheng() and self.player:canPindian(enemy) then
				use.card = sgs.Card_Parse("#meizlshhujiacard:.:")
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
	if (self:getOverflow() > 0) or (max_point > 9) then
		for _, enemy in ipairs(self.enemies) do
			if not enemy:isKongcheng() and self.player:canPindian(enemy) then
				use.card = sgs.Card_Parse("#meizlshhujiacard:.:")
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end

function sgs.ai_skill_pindian.meizlshhujia(minusecard, self, requestor)
	if self:isFriend(requestor) then return minusecard end
	return self:getMaxCard()
end

--归汉‧升华

local meizlshguihan_skill = {}
meizlshguihan_skill.name = "meizlshguihan"
table.insert(sgs.ai_skills, meizlshguihan_skill)
meizlshguihan_skill.getTurnUseCard = function(self, inclusive)
	if self.player:getMark("@meizlshguihan") == 0 then return end
	return sgs.Card_Parse("#meizlshguihancard:.:")
end

sgs.ai_skill_use_func["#meizlshguihancard"] = function(card,use,self)
	if self:isWeak() then
		use.card = card
		if use.to then use.to:append(self.player) end
		return
	end
end

sgs.ai_use_value["meizlshguihancard"] = sgs.ai_use_value.ExNihilo - 0.1
sgs.ai_use_priority["meizlshguihancard"] = sgs.ai_use_priority.ExNihilo - 0.1

--魂逝（蔡文姬）
function sgs.ai_slash_prohibit.meizlshhunshi(self, from, to)
	if from:hasSkill("jueqing") or (from:hasSkill("nosqianxi") and from:distanceTo(to) == 1) then return false end
	if from:hasFlag("NosJiefanUsed") then return false end
	if to:getHp() > 1 or #(self:getEnemies(from)) == 1 then return false end
	if from:getMaxHp() == 3 and from:getArmor() and from:getDefensiveHorse() then return false end
	if from:getMaxHp() <= 3 or (from:isLord() and self:isWeak(from)) then return true end
	if from:getMaxHp() <= 3 or (self.room:getLord() and from:getRole() == "renegade") then return true end
	return false
end

local meizlzhenhunqu_skill = {}
meizlzhenhunqu_skill.name = "meizlzhenhunqu"
table.insert(sgs.ai_skills, meizlzhenhunqu_skill)
meizlzhenhunqu_skill.getTurnUseCard = function(self)
	if  self.player:getMark("@meizlcaiwenjimark") >= 5 then
        return sgs.Card_Parse("#meizlzhenhunqucard:.:")
    end
end

sgs.ai_skill_use_func["#meizlzhenhunqucard"] = function(card,use,self)
	self:sort(self.enemies, "defense")

	for _, enemy in ipairs(self.enemies) do
		if self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) then
					use.card = sgs.Card_Parse("#meizlzhenhunqucard:.:")
					if use.to then
						use.to:append(enemy)
					end
					break
			end
	end
end


-- 杨婉‧升华
--请宴‧升华
local meizlshqingyan_skill = {}
meizlshqingyan_skill.name = "meizlshqingyan"
table.insert(sgs.ai_skills, meizlshqingyan_skill)
meizlshqingyan_skill.getTurnUseCard = function(self)
	if not self.player:canDiscard(self.player,"he") then return end
	return sgs.Card_Parse("#meizlshqingyancard:.:")
end

sgs.ai_skill_use_func["#meizlshqingyancard"] = function(card, use, self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sort(self.enemies, "handcard")
	local slashcount = self:getCardsNum("Slash")
	self:sortByUseValue(cards,true)
	if slashcount > 0  then
		for _, card in ipairs(cards) do
				if (not card:isKindOf("Peach") and not card:isKindOf("ExNihilo") and not card:isKindOf("Jink")) or self:getOverflow() > 0 then
				local slash = self:getCard("Slash")
					assert(slash)
					local target
					local dummyuse = { isDummy = true, to = sgs.SPlayerList() }
						self:useBasicCard(slash, dummyuse)
						if not dummyuse.to:isEmpty() then
							for _, p in sgs.qlist(dummyuse.to) do
								if p:getMark("@meizlshqingyan") == 0 then
								target = p
									break
								end
							end
						end
					--[[local dummy_use = {isDummy = true}
					self:useBasicCard(slash, dummy_use)
					local target
					for _, enemy in ipairs(self.enemies) do
						if self:canAttack(enemy, self.player)
							and not self:canLiuli(enemy, self.friends_noself) and not self:findLeijiTarget(enemy, 50, self.player)  then
							if enemy:getMark("muguan") == 0 then
							target = enemy
							else
								return
							end
						end
					end]]
						if target then
						use.card = sgs.Card_Parse("#meizlshqingyancard:"..card:getId()..":")
								if use.to then use.to:append(target) end
								return
						end
				end
			end
	end
    if self:getOverflow() > 0 then
        for _, card in ipairs(cards) do
				if (not card:isKindOf("Peach") and not card:isKindOf("ExNihilo") and not card:isKindOf("Jink")) or self:getOverflow() > 0 then
					local target
                    self:sort(self.enemies, "handcard")
                    self.enemies = sgs.reverse(self.enemies)
                    for _, p in ipairs(self.enemies) do
                        if p:getMark("@meizlshqingyan") == 0 then
                        target = p
                            break
                        end
                    end
						if target then
						use.card = sgs.Card_Parse("#meizlshqingyancard:"..card:getId()..":")
								if use.to then use.to:append(target) end
								return
						end
				end
			end
    end
    
    
    
    
    
end

sgs.ai_card_intention["meizlshqingyancard"] = 70


sgs.ai_use_value["meizlshqingyancard"] = 9.2
sgs.ai_use_priority["meizlshqingyancard"] = sgs.ai_use_priority.Slash + 0.1


--相接（杨婉）
sgs.ai_skill_invoke.meizlshxiangjie = function(self, data)
		local hcards = self.player:getCards("h")
		hcards = sgs.QList2Table(hcards)
		self:sortByUseValue(hcards, true)
		local card
		for _, hcard in ipairs(hcards) do
			if hcard:isKindOf("Slash") then
					card = hcard
			end
		end
	if not card then
		return false
	end
	local target
	local friends = self.friends_noself
	local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
    slash:deleteLater()
	self.meizlxiangjieTarget = nil
	local friend = self.room:getCurrent()
	if friend and self:isFriend(friend) then
	
		self:sort(self.enemies, "defense")
				for _, enemy in ipairs(self.enemies) do
					if friend:canSlash(enemy, slash, false) and not self:slashProhibit(slash, enemy) and sgs.getDefenseSlash(enemy, self) <= 2
							and self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self)
							and enemy:objectName() ~= self.player:objectName() then
						self.meizlxiangjieTarget = enemy
						return true
					end
				end
	end
	return false
end

sgs.ai_skill_playerchosen.meizlshxiangjie = function(self, targets)
	if self.meizlxiangjieTarget then return self.meizlxiangjieTarget end
	return sgs.ai_skill_playerchosen.zero_card_as_slash(self, targets)
end

sgs.ai_skill_cardask["@meizlshxiangjie-slash"] = function(self, data, pattern)
	local hcards = self.player:getCards("h")
		hcards = sgs.QList2Table(hcards)
		self:sortByUseValue(hcards, true)
		local card
		for _, hcard in ipairs(hcards) do
			if hcard:isKindOf("Slash") then
					card = hcard
			end
		end
	if card then
	return "$" .. card:getEffectiveId()
	end
end




local meizlmengshilong_skill = {}
meizlmengshilong_skill.name = "meizlmengshilong"
table.insert(sgs.ai_skills, meizlmengshilong_skill)
meizlmengshilong_skill.getTurnUseCard = function(self)
	if  self.player:getMark("@meizlyangwanmark") >= 4 then
        return sgs.Card_Parse("#meizlmengshilongcard:.:")
    end
end

sgs.ai_skill_use_func["#meizlmengshilongcard"] = function(card,use,self)
	self:sort(self.enemies, "defense")
	local target
	if self.role == "rebel" then 
		local lord = self.room:getLord()
		target = lord
	end
	if target  then 
		use.card = sgs.Card_Parse("#meizlmengshilongcard:.:")
		if use.to then
			use.to:append(target)
		end
		else
			for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 3 then
						use.card = sgs.Card_Parse("#meizlmengshilongcard:.:")
						if use.to then
							use.to:append(enemy)
						end
						break
				end
		end
	end
	
end



local meizlshzefu_skill = {}
meizlshzefu_skill.name = "meizlshzefu"
table.insert(sgs.ai_skills, meizlshzefu_skill)
meizlshzefu_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meizlshzefucard") then
        return sgs.Card_Parse("#meizlshzefucard:.:")
    end
end

sgs.ai_skill_use_func["#meizlshzefucard"] = function(card,use,self)
	self:sort(self.friends_noself, "handcard")
	local has_red = false
		for _, friend in ipairs(self.friends_noself) do
			if not self:needKongcheng(friend, true) and not hasManjuanEffect(friend) then
				if (friend:getHandcardNum()  > self.player:getHandcardNum()) and (friend:getHp()  > self.player:getHp()) and (friend:getAttackRange()  > self.player:getAttackRange()) then
					use.card = sgs.Card_Parse("#meizlshzefucard:.:")
					if use.to then use.to:append(friend) end
					return
				end
			end
		end
end

sgs.ai_use_priority["meizlshzefucard"] = 10
sgs.ai_use_value["meizlshzefucard"] = 2.45
sgs.ai_card_intention.meizlshzefucard = -80



local meizlyanranyixiao_skill = {}
meizlyanranyixiao_skill.name = "meizlyanranyixiao"
table.insert(sgs.ai_skills, meizlyanranyixiao_skill)
meizlyanranyixiao_skill.getTurnUseCard = function(self)
	if self.player:getMark("@meizlfanshimark") >= 8 and not self.player:hasUsed("#meizlyanranyixiaocard")  then
				return sgs.Card_Parse("#meizlyanranyixiaocard:.:")
	end
end

sgs.ai_skill_use_func["#meizlyanranyixiaocard"] = function(card,use,self)
					use.card = card
					return
end



sgs.ai_use_value["meizlyanranyixiaocard"] = sgs.ai_use_value.ExNihilo - 0.1
sgs.ai_use_priority["meizlyanranyixiaocard"] = sgs.ai_use_priority.ExNihilo - 0.1






sgs.ai_slash_prohibit.meizlshxiuhua = function(self, from, enemy, card)
	if enemy:hasSkill("meizlshxiuhua") and card:isKindOf("NatureSlash") then return true end
	return
end

meizlshxiuhua_damageeffect = function(self, to, nature, from)
	if to:hasSkill("meizlshxiuhua") and nature ~= sgs.DamageStruct_Normal then return false end
	return true
end


table.insert(sgs.ai_damage_effect, meizlshxiuhua_damageeffect)




local meizlyuezhanyueqiang_skill = {}
meizlyuezhanyueqiang_skill.name = "meizlyuezhanyueqiang"
table.insert(sgs.ai_skills, meizlyuezhanyueqiang_skill)
meizlyuezhanyueqiang_skill.getTurnUseCard = function(self)
	if self.player:getMark("@meizlmayunlumark") >= 4 and not self.player:hasUsed("#meizlyuezhanyueqiangcard")  then
				return sgs.Card_Parse("#meizlyuezhanyueqiangcard:.:")
	end
end

sgs.ai_skill_use_func["#meizlyuezhanyueqiangcard"] = function(card,use,self)
					use.card = card
					return
end



sgs.ai_use_value["meizlyuezhanyueqiangcard"] = sgs.ai_use_value.ExNihilo - 0.1
sgs.ai_use_priority["meizlyuezhanyueqiangcard"] = sgs.ai_use_priority.ExNihilo - 0.1


sgs.ai_skill_invoke.meizlshyuguo = function(self, data)
	return true
end



sgs.ai_skill_invoke.meizlshrongzhuang = function(self, data)
	return true
end
sgs.ai_skill_use["@@meizlshrongzhuang"]=function(self,prompt)
    self:updatePlayers()
	local card = prompt:split(":")
	if card[2] == "slash" or card[2] == "fire_slash" or card[2] == "thunder_slash" then
	    self:sort(self.enemies, "defense")
		local targets = {}
		for _,enemy in ipairs(self.enemies) do
		    if (not self:slashProhibit(sgs.Sanguosha:getCard(card[5]), enemy)) and self.player:canSlash(enemy, sgs.Sanguosha:getCard(card[5])) then
				if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, sgs.Sanguosha:getCard(card[5])) then break end
				table.insert(targets,enemy:objectName())
			end
		end
		if #targets > 0 then
		    return card[5] .. "->" .. table.concat(targets,"+")
		else
		    return "."
		end
	end
	return "."
end



local meizlwuzhijingjichang_skill = {}
meizlwuzhijingjichang_skill.name = "meizlwuzhijingjichang"
table.insert(sgs.ai_skills, meizlwuzhijingjichang_skill)
meizlwuzhijingjichang_skill.getTurnUseCard = function(self)
	if (self.player:getMark("@meizllvlingqimark") < 5) or (self.player:getMark("@meizlwuzhijingjichang") > 0) then return end
	return sgs.Card_Parse("#meizlwuzhijingjichangcard:.:")
end
sgs.ai_skill_use_func["#meizlwuzhijingjichangcard"] = function(card, use, self)
	self:updatePlayers()
	self:sort(self.enemies,"defense")
	local acard = sgs.Card_Parse("#meizlwuzhijingjichangcard:.:") --根据卡牌构成字符串产生实际将使用的卡牌
	assert(acard)
	local defense = 6
	local selfSub = self.player:getHandcardNum() - self.player:getHp()
	if #self.enemies <= 1 then return "." end
	for _, enemy in ipairs(self.enemies) do
		local def = sgs.getDefense(enemy)
		local slash = sgs.Sanguosha:cloneCard("slash")
		local eff = self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self) 
	
		if not self.player:canSlash(enemy, slash, false) then
		elseif throw_weapon and enemy:hasArmorEffect("vine") and not self.player:hasSkill("zonghuo") then
		elseif self:slashProhibit(nil, enemy) then
		elseif eff then
			if enemy:getHp() == 1 and getCardsNum("Jink", enemy) == 0 then best_target = enemy break end
			if def < defense then
				best_target = enemy
				defense = def
			end
			target = enemy
		end
		if selfSub < 0 then return "." end
	end
	if best_target then
		if self:getCardsNum("Slash") > 1 and self.player:getHp() > 1 then
			use.card=acard
			if use.to then use.to:append(best_target) end
			return
		end
	end
	if target then
		if self:getCardsNum("Slash") > 1 and self.player:getHp() > 2 then
			use.card=acard
			if use.to then use.to:append(target) end
			return
		end
	end
	--[[for _, c in sgs.qlist(self.player:getHandcards()) do
        local x = nil
        if isCard("ArcheryAttack", c, self.player) then
            x = sgs.Sanguosha:cloneCard("ArcheryAttack")
        elseif isCard("SavageAssault", c, self.player) then
            x = sgs.Sanguosha:cloneCard("SavageAssault")
        else continue end

        local du = { isDummy = true }
        self:useTrickCard(x, du)
		if (du.card) and self.player:getHp() > 1 then use.card=acard end
        --if target and (du.card) and self.player:getHp() > 1 then use.card=acard end
    end]]
end

sgs.ai_use_value["meizlwuzhijingjichangcard"] = 2 --卡牌使用价值
sgs.ai_use_priority["meizlwuzhijingjichangcard"] = 3 --卡牌使用优先级



--扶君（糜夫人）
sgs.ai_skill_playerchosen.meizlshfujun = function(self, targets)
	local AssistTarget = self:AssistTarget()
	if AssistTarget and not self:willSkipPlayPhase(AssistTarget) then
		return AssistTarget
	end

	self:sort(self.friends_noself, "chaofeng")
	for _, target in ipairs(self.friends_noself) do
		if not target:hasSkill("dawu") and target:hasSkills("yongsi|zhiheng|" .. sgs.priority_skill .. "|shensu")
			and (not self:willSkipPlayPhase(target) or target:hasSkill("shensu")) then
			return target
		end
	end

	for _, target in ipairs(self.friends_noself) do
		if target:hasSkill("dawu") then
			local use = true
			for _, p in ipairs(self.friends_noself) do
				if p:getMark("@fog") > 0 then use = false break end
			end
			if use then
				return  target
			end
		else
			return  target
		end
	end
end
--让马（糜夫人）
sgs.ai_skill_playerchosen.meizlshrangma = function(self, targets)
	local AssistTarget = self:AssistTarget()
	if AssistTarget and not self:willSkipPlayPhase(AssistTarget) then
		return AssistTarget
	end

	self:sort(self.friends_noself, "chaofeng")
	for _, target in ipairs(self.friends_noself) do
		if target:hasSkills(sgs.cardneed_skill)
			and (not self:willSkipPlayPhase(target) or target:hasSkill("shensu")) then
			return target
		end
	end
	for _, target in ipairs(self.friends_noself) do
		if target:hasSkills("yongsi|zhiheng|" .. sgs.priority_skill .. "|shensu")
			and (not self:willSkipPlayPhase(target) or target:hasSkill("shensu")) then
			return target
		end
	end
	for _, target in ipairs(self.friends_noself) do
			return target
	end
end
--托孤（糜夫人）
meizlshtuogu_skill = {}
meizlshtuogu_skill.name = "meizlshtuogu"
table.insert(sgs.ai_skills, meizlshtuogu_skill)
meizlshtuogu_skill.getTurnUseCard = function(self)
	if self.player:getMark("@meizlshtuogu") <= 0 then return end
	local good, bad = 0, 0
	local lord = self.room:getLord()
	if lord and self.role ~= "rebel" and self:isWeak(lord) and lord:getKingdom() ~= "shu" then return end
	for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if self:isWeak(player) then
			if self:isFriend(player) and player:getKingdom() ~= "shu" then bad = bad + 1
				if player:getKingdom() == "shu"  then
					good = good + 1
				end
			elseif player:getKingdom() ~= "shu" and not self:isFriend(player) then  good = good + 1
			end
		end
	end
	if good == 0 then return end

	for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		local hp = math.max(player:getHp(), 1)
		if getCardsNum("Analeptic", player) > 0 then
			if self:isFriend(player) and player:getKingdom() ~= "shu"  then good = good + 1.0 / hp
			elseif player:getKingdom() ~= "shu" and not self:isFriend(player) then bad = bad + 1.0 / hp
			end
		end

		if self:isFriend(player)  and player:getKingdom() ~= "shu"  then good = good + math.max(getCardsNum("Peach", player), 1)
		elseif player:getKingdom() ~= "shu" and not self:isFriend(player) then bad = bad + math.max(getCardsNum("Peach", player), 1)
		end

	end
	bad = bad + self.player:getHp()
	if good > bad then return sgs.Card_Parse("#meizlshtuogucard:.:") end
end

sgs.ai_skill_use_func.meizlshtuogucard=function(card,use,self)
	use.card = card
end

sgs.ai_skill_playerchosen.meizlshtuogucard = function(self, targets)
	local arr1, arr2 = self:getWoundedFriend(false, false)
	local target = nil

	if #arr1 > 0 and (self:isWeak(arr1[1]) or self:getOverflow() >= 1) and arr1[1]:getHp() < getBestHp(arr1[1]) then target = arr1[1] end
	if target and  target:getKingdom() == "shu" then
		return target
	end
end




local meizlkujingguhun_skill = {}
meizlkujingguhun_skill.name = "meizlkujingguhun"
table.insert(sgs.ai_skills, meizlkujingguhun_skill)
meizlkujingguhun_skill.getTurnUseCard = function(self)
	if  self.player:getMark("@meizlmifurenmark") >= 1 and not self.player:hasUsed("#meizlkujingguhuncard") then
        return sgs.Card_Parse("#meizlkujingguhuncard:.:")
    end
end

sgs.ai_skill_use_func["#meizlkujingguhuncard"] = function(card,use,self)
	self:sort(self.enemies, "defense")
	local target
	if self.role == "rebel" then 
		local lord = self.room:getLord()
		target = lord
	end
	if target  then 
		use.card = sgs.Card_Parse("#meizlkujingguhuncard:.:")
		if use.to then
			use.to:append(target)
		end
		else
			for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 3 then
						use.card = sgs.Card_Parse("#meizlkujingguhuncard:.:")
						if use.to then
							use.to:append(enemy)
						end
						break
				end
		end
	end
end



sgs.ai_skill_playerchosen.meizlkujingguhuncard = function(self, targets)
	local target
	if self.role == "rebel" then 
		local lord = self.room:getLord()
		return lord
	end
	self:sort(self.enemies, "hp")
	for _, enemy in ipairs(self.enemies) do
		return enemy
	end
	return targets[1]
end




--梨舞（娘-赵云）
local meispshliwu_skill = {}
meispshliwu_skill.name = "meispshliwu"
table.insert(sgs.ai_skills, meispshliwu_skill)
meispshliwu_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#meispshliwucard")  then
		if self.player:getMark("@meispshliwuprevent") == 0 and self.player:getMark("@meispshfeng") >= 1 and self.player:getKingdom() == "shu"  then
				return sgs.Card_Parse("#meispshliwucard:.:")
		end
	end
end

sgs.ai_skill_use_func["#meispshliwucard"] = function(card,use,self)
					use.card = card
					return
end
--梨舞效果
local meispshliwuskill2_skill={}
meispshliwuskill2_skill.name="meispshliwuskill2"
table.insert(sgs.ai_skills,meispshliwuskill2_skill)
meispshliwuskill2_skill.getTurnUseCard=function(self)
	local cards = self.player:getCards("h")
	cards=sgs.QList2Table(cards)

	if self.player:getPile("wooden_ox"):length() > 0 then
		for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
			table.insert(cards, sgs.Sanguosha:getCard(id))
		end
	end

	local jink_card

	self:sortByUseValue(cards,true)

	for _,card in ipairs(cards)  do
		if card:isKindOf("Jink") then
			jink_card = card
			break
		end
	end

	if not jink_card then return nil end
	local suit = jink_card:getSuitString()
	local number = jink_card:getNumberString()
	local card_id = jink_card:getEffectiveId()
	local card_str = ("slash:meispshliwuskill2[%s:%s]=%d"):format(suit, number, card_id)
	local slash = sgs.Card_Parse(card_str)
	assert(slash)

	return slash

end

sgs.ai_view_as.meispshliwuskill2 = function(card, player, card_place)
	if sgs.Sanguosha:getCurrentCardUseReason() ~= sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then return end
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place == sgs.Player_PlaceHand or player:getPile("wooden_ox"):contains(card_id) then
		if card:isKindOf("Jink") then
			return ("slash:meispshliwuskill2[%s:%s]=%d"):format(suit, number, card_id)
		elseif card:isKindOf("Slash") then
			return ("jink:meispshliwuskill2[%s:%s]=%d"):format(suit, number, card_id)
		end
	end
end


sgs.ai_use_value["meispliwucard"] = 2 --卡牌使用价值
sgs.ai_use_priority["meispliwucard"] = 3.5 --卡牌使用优先级







local meispshruixuecard_skill = {}
meispshruixuecard_skill.name = "meispshruixuecard"
table.insert(sgs.ai_skills, meispshruixuecard_skill)
meispshruixuecard_skill.getTurnUseCard = function(self)
	if not (self.player:getMark("@meispshruixue") >  0 and self.player:getKingdom() == "qun") then return end
	return sgs.Card_Parse("#meispshruixuecard:.:")
end
sgs.ai_skill_use_func["#meispshruixuecard"] = function(card, use, self)
	self:updatePlayers()
	self:sort(self.enemies,"defense")
	local acard = sgs.Card_Parse("#meispshruixuecard:.:") --根据卡牌构成字符串产生实际将使用的卡牌
	assert(acard)
	local defense = 6
	local selfSub = self.player:getHandcardNum() - self.player:getHp()
	if #self.enemies <= 1 then return "." end
	for _, enemy in ipairs(self.enemies) do
		local def = sgs.getDefense(enemy)
		local slash = sgs.Sanguosha:cloneCard("slash")
		local eff = self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self) and self.player:distanceTo(enemy) - math.min(self.player:getHp()-1, self:getCardsNum("Slash")) <= 1
	
		if not self.player:canSlash(enemy, slash, false) then
		elseif throw_weapon and enemy:hasArmorEffect("vine") and not self.player:hasSkill("zonghuo") then
		elseif self:slashProhibit(nil, enemy) then
		elseif eff then
			if enemy:getHp() == 1 and getCardsNum("Jink", enemy) == 0 then best_target = enemy break end
			if def < defense then
				best_target = enemy
				defense = def
			end
			target = enemy
		end
		if selfSub < 0 then return "." end
	end
	if best_target then
		if self:getCardsNum("Slash") > 1  then
			use.card=acard
		end
	end
	if target then
		if self:getCardsNum("Slash") > 1  then
			use.card=acard
		end
	end
	for _, c in sgs.qlist(self.player:getHandcards()) do
        local x = nil
        if isCard("ArcheryAttack", c, self.player) then
            x = sgs.Sanguosha:cloneCard("ArcheryAttack")
        elseif isCard("SavageAssault", c, self.player) then
            x = sgs.Sanguosha:cloneCard("SavageAssault")
        else continue end

        local du = { isDummy = true }
        self:useTrickCard(x, du)
		if (du.card) and self.player:getHp() > 1 then use.card=acard end
        --if target and (du.card) and self.player:getHp() > 1 then use.card=acard end
    end
end

sgs.ai_use_value["meispshruixuecard"] = 2 --卡牌使用价值
sgs.ai_use_priority["meispshruixuecard"] = 3 --卡牌使用优先级







sgs.ai_skill_invoke.feiren = function(self, data)
	local target = data:toPlayer()
	if not self:isEnemy(target) then return false end

	if self.player:getHandcardNum() == 1 then
		if (self:needKongcheng() or not self:hasLoseHandcardEffective()) and not self:isWeak() then return true end
		local card  = self.player:getHandcards():first()
		if card:isKindOf("Jink") or card:isKindOf("Peach") then return end
	end

	if  (self:needKongcheng() and self.player:getHandcardNum() == 1) or not self:hasLoseHandcardEffective()
		and not self:doNotDiscard(target, "h", true)  then
			return true
	end
	if self:doNotDiscard(target, "h", true, 2) then return false end
	return false
end



sgs.ai_skill_invoke.yuxiang = function(self, data)
local savage_assault=sgs.Sanguosha:cloneCard("savage_assault",sgs.Card_NoSuit,0)
		savage_assault:setSkillName("yuxiang")
        savage_assault:deleteLater()
		if  self:getAoeValue(savage_assault) > 0  then
			return true
		end
	return false
end



sgs.ai_skill_invoke.guihans = function(self, data)
	return true
end

sgs.ai_skill_invoke.hujias = function(self, data)
	return true
end

function sgs.ai_slash_prohibit.hujiajh(self, from, to)
	if from:hasSkill("jueqing") or (from:hasSkill("nosqianxi") and from:distanceTo(to) == 1) then return false end
	if from:hasFlag("NosJiefanUsed") then return false end
	if to:getHp() > 1 or #(self:getEnemies(from)) == 1 then return false end
	if from:getMaxHp() == 3 and from:getArmor() and from:getDefensiveHorse() then return false end
	if from:getMaxHp() <= 3 or (from:isLord() and self:isWeak(from)) then return true end
	if from:getMaxHp() <= 3 or (self.room:getLord() and from:getRole() == "renegade") then return true end
	return false
end




local guyan_skill = {}
guyan_skill.name= "guyan"
table.insert(sgs.ai_skills,guyan_skill)
guyan_skill.getTurnUseCard=function(self)
	if not self.player:hasUsed("#guyan") then
		return sgs.Card_Parse("#guyan:.:")
	end
end

sgs.ai_skill_use_func["#guyan"] = function(card, use, self)
		self:sort(self.enemies, "hp")
		for _, enemy in ipairs(self.enemies) do
			if self:objectiveLevel(enemy) > 3 and not self:cantbeHurt(enemy) and self:damageIsEffective(enemy) then
					use.card = sgs.Card_Parse("#guyan:.:")
					if use.to then
						use.to:append(enemy)
					end
					return
			end
		end
end


sgs.ai_skill_invoke.hujias = function(self, data)
	return true
end


sgs.ai_skill_invoke.guyanjh = function(self, data)
	local damage = data:toDamage()
	if damage.from and self:isEnemy(damage.from) then
		local to_discard = self:askForDiscard("beige", 1, 1, false, true)
			if #to_discard > 0 then
				return true
			end
	end
	return false
end

sgs.ai_skill_discard["guyanjh"] = function(self, discard_num, min_num, optional, include_equip)
	local usable_cards = sgs.QList2Table(self.player:getCards("he"))
	local damage = self.room:getTag("CurrentDamageStruct"):toDamage()
	local target = damage.from
	if target and  not self:isFriend(target) then  
	self:sortByKeepValue(usable_cards)
	local to_discard = {}
	for _,c in ipairs(usable_cards) do
		if #to_discard < discard_num and not c:isKindOf("Peach") then
			table.insert(to_discard, c:getEffectiveId())
		end
	end
    return to_discard
	end
	return {}
end




sgs.ai_skill_invoke.xiehou = function(self, data)
	return true
end



sgs.ai_skill_cardask["@huixue"] = function(self, data, pattern)
	local hcards = self.player:getCards("h")
		hcards = sgs.QList2Table(hcards)
		self:sortByUseValue(hcards, true)
		local card
		for _, hcard in ipairs(hcards) do
			if hcard:isKindOf("BasicCard") then
					card = hcard
			end
		end
	if card and getBestHp(self.player) >= self.player:getHp() then
	return "$" .. card:getEffectiveId()
	end
end



sgs.ai_skill_invoke.luoshenjh = function(self, data)
	return true
end

sgs.ai_skill_invoke.huixuejh = function(self, data)
	return true
end


sgs.ai_skill_invoke.shenfu = function(self, data)
	return true
end


sgs.ai_skill_invoke.biyues = function(self, data)
	local damage = data:toDamage()
	if damage.from and self:isEnemy(damage.from) then
		if damage.from:isKongcheng() and (damage.from:getEquips():length() > 0) and (self:hasSkills(sgs.lose_equip_skill, damage.from)) then
			return false
		end
		return true
	end
	return false
end


sgs.ai_skill_invoke.luoshenjhnd = function(self, data)
	return true
end


sgs.ai_skill_invoke.biyuejh = function(self, data)
	local damage = data:toDamage()
	if damage.from and self:isEnemy(damage.from) then
		if damage.from:isKongcheng() and (damage.from:getEquips():length() > 0) and (self:hasSkills(sgs.lose_equip_skill, damage.from)) then
			return false
		end
		return true
	end
	return false
end


local shijun_skill = {}
shijun_skill.name = "shijun"
table.insert(sgs.ai_skills, shijun_skill)
shijun_skill.getTurnUseCard = function(self)
	if not self.player:canDiscard(self.player,"he") then return end
	return sgs.Card_Parse("#shijun:.:")
end

sgs.ai_skill_use_func["#shijun"] = function(card, use, self)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sort(self.enemies, "handcard")
	local slashcount = self:getCardsNum("Slash")
	self:sortByUseValue(cards,true)
	if slashcount > 0  then
		for _, card in ipairs(cards) do
				if (not card:isKindOf("Peach") and not card:isKindOf("ExNihilo") and not card:isKindOf("Jink")) or self:getOverflow() > 0 then
				local slash = self:getCard("Slash")
					assert(slash)
					local dummy_use = {isDummy = true}
					self:useBasicCard(slash, dummy_use)
					local target
					for _, enemy in ipairs(self.enemies) do
						if self:canAttack(enemy, self.player)
							and not self:canLiuli(enemy, self.friends_noself) and not self:findLeijiTarget(enemy, 50, self.player)  then
							if self.player:distanceTo(enemy) ~= 1 then
							target = enemy
							else
								return
							end
						end
					end
						if target then
						use.card = sgs.Card_Parse("#shijun:"..card:getId()..":")
								if use.to then use.to:append(target) end
								return
						end
				end
			end
	end
end

sgs.ai_card_intention["shijun"] = 70


sgs.ai_use_value["shijun"] = 9.2
sgs.ai_use_priority["shijun"] = sgs.ai_use_priority.Slash + 0.1



sgs.ai_skill_invoke.shixiang = function(self, data)
	if self.player:getHandcardNum() == 3 then
	return true
	end
	return false
end


