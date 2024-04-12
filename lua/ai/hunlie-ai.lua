--知命
sgs.ai_skill_cardask["@sgkgodzhiming"] = function(self, data, pattern, target)
    local current = self.room:getCurrent()
	if self:isEnemy(current) and not self.player:isKongcheng() then
	    local cards = sgs.QList2Table(self.player:getHandcards())
		self:sortByKeepValue(cards)
		return "$" .. cards[1]:getId()
	else
		return "."
	end
end

sgs.ai_skill_choice["sgkgodzhiming"] = function(self, choices, data)
	local room = self.room
	local current = room:getCurrent()
	if current:getHandcardNum() >= current:getHp() then
	    return "sgkgodzhimingplay"
	end
	if (current:hasSkills("yongsi|haoshi|juejing|yingzi|nosyingzi|tuxi|nostuxi") and current:getHandcardNum() <= 2) or current:isKongcheng() 
	        or current:getHp() > current:getHandcardNum() then
		return "sgkgodzhimingdraw"
	end
	return "sgkgodzhimingplay"
end


--夙隐
sgs.ai_skill_playerchosen.sgkgodsuyin = function(self, targets)
    local target = {}
	for _, t in sgs.qlist(targets) do
	    if self:isEnemy(t) and t:faceUp() then
		    table.insert(target, t)
		end
		if self:isFriend(t) and (not t:faceUp()) then
		    table.insert(target, t)
		end
	end
	if #target > 0 then
	    self:sort(target, "defense")
		return target[1]
	end
end

sgs.ai_skill_invoke.sgkgodsuyin = function(self, data)
    local a = 0
	for _, t in ipairs(self.enemies) do
	    if t:faceUp() then a = a + 1 end
	end
	for _, p in ipairs(self.friends_noself) do
	    if not p:faceUp() then a = a + 1 end
	end
	if a > 0 then return true end
	return false
end


--虎踞
sgs.ai_skill_choice["sgkgodhuju"] = function(self, choices, data)
    local huju = choices:split("+")
	if self:getCardsNum("Peach") >= self.player:getLostHp() or self.player:getLostHp() == 1 then
	    return huju[1]
	end
	return huju[2]
end


--虎缚
sgkgodhufu_skill={}
sgkgodhufu_skill.name="sgkgodhufu"
table.insert(sgs.ai_skills, sgkgodhufu_skill)
sgkgodhufu_skill.getTurnUseCard=function(self, inclusive)
    if self.player:hasUsed("#sgkgodhufuCard") then return end
	if #self.enemies <= 0 then return end 
	return sgs.Card_Parse("#sgkgodhufuCard:.:")
end

sgs.ai_skill_use_func["#sgkgodhufuCard"] = function(card, use, self)
    local targets = {}
	for _, p in ipairs(self.enemies) do
	    if p:getEquips():length() >= 1 then
	        table.insert(targets, p)
		end
	end
	if #targets == 0 then return nil end
	local target = targets[math.random(1, #targets)]
	use.card = card
	if use.to then use.to:append(target) end
	return
end

sgs.ai_use_value["sgkgodhufuCard"] = 8
sgs.ai_use_priority["sgkgodhufuCard"] = 8
sgs.ai_card_intention["sgkgodhufuCard"]  = 80


--制衡（虎踞）
local hujuzhiheng_skill = {}
hujuzhiheng_skill.name = "hujuzhiheng"
table.insert(sgs.ai_skills, hujuzhiheng_skill)
hujuzhiheng_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#hujuzhihengCard") then
		return sgs.Card_Parse("#hujuzhihengCard:.:")
	end
end

sgs.ai_skill_use_func["#hujuzhihengCard"] = function(card, use, self)
	local unpreferedCards = {}
	local cards = sgs.QList2Table(self.player:getHandcards())

	if self.player:getHp() < 3 then
		local zcards = self.player:getCards("he")
		local use_slash, keep_jink, keep_analeptic, keep_weapon = false, false, false
		local keep_slash = self.player:getTag("JilveWansha"):toBool()
		for _, zcard in sgs.qlist(zcards) do
			if not isCard("Peach", zcard, self.player) and not isCard("ExNihilo", zcard, self.player) then
				local shouldUse = true
				if isCard("Slash", zcard, self.player) and not use_slash then
					local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
					self:useBasicCard(zcard, dummy_use)
					if dummy_use.card then
						if keep_slash then shouldUse = false end
						if dummy_use.to then
							for _, p in sgs.qlist(dummy_use.to) do
								if p:getHp() <= 1 then
									shouldUse = false
									if self.player:distanceTo(p) > 1 then keep_weapon = self.player:getWeapon() end
									break
								end
							end
							if dummy_use.to:length() > 1 then shouldUse = false end
						end
						if not self:isWeak() then shouldUse = false end
						if not shouldUse then use_slash = true end
					end
				end
				if zcard:getTypeId() == sgs.Card_TypeTrick then
					local dummy_use = { isDummy = true }
					self:useTrickCard(zcard, dummy_use)
					if dummy_use.card then shouldUse = false end
				end
				if zcard:getTypeId() == sgs.Card_TypeEquip and not self.player:hasEquip(zcard) then
					local dummy_use = { isDummy = true }
					self:useEquipCard(zcard, dummy_use)
					if dummy_use.card then shouldUse = false end
					if keep_weapon and zcard:getEffectiveId() == keep_weapon:getEffectiveId() then shouldUse = false end
				end
				if self.player:hasEquip(zcard) and zcard:isKindOf("Armor") and not self:needToThrowArmor() then shouldUse = false end
				if self.player:hasEquip(zcard) and zcard:isKindOf("DefensiveHorse") and not self:needToThrowArmor() then shouldUse = false end
				if isCard("Jink", zcard, self.player) and not keep_jink then
					keep_jink = true
					shouldUse = false
				end
				if self.player:getHp() == 1 and isCard("Analeptic", zcard, self.player) and not keep_analeptic then
					keep_analeptic = true
					shouldUse = false
				end
				if shouldUse then table.insert(unpreferedCards, zcard:getId()) end
			end
		end
	end

	if #unpreferedCards == 0 then
		local use_slash_num = 0
		self:sortByKeepValue(cards)
		for _, card in ipairs(cards) do
			if card:isKindOf("Slash") then
				local will_use = false
				if use_slash_num <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, card) then
					local dummy_use = { isDummy = true }
					self:useBasicCard(card, dummy_use)
					if dummy_use.card then
						will_use = true
						use_slash_num = use_slash_num + 1
					end
				end
				if not will_use then table.insert(unpreferedCards, card:getId()) end
			end
		end

		local num = self:getCardsNum("Jink") - 1
		if self.player:getArmor() then num = num + 1 end
		if num > 0 then
			for _, card in ipairs(cards) do
				if card:isKindOf("Jink") and num > 0 then
					table.insert(unpreferedCards, card:getId())
					num = num - 1
				end
			end
		end
		for _, card in ipairs(cards) do
			if (card:isKindOf("Weapon") and self.player:getHandcardNum() < 3) or card:isKindOf("OffensiveHorse")
				or self:getSameEquip(card, self.player) or card:isKindOf("AmazingGrace") then
				table.insert(unpreferedCards, card:getId())
			elseif card:getTypeId() == sgs.Card_TypeTrick then
				local dummy_use = { isDummy = true }
				self:useTrickCard(card, dummy_use)
				if not dummy_use.card then table.insert(unpreferedCards, card:getId()) end
			end
		end

		if self.player:getWeapon() and self.player:getHandcardNum() < 3 then
			table.insert(unpreferedCards, self.player:getWeapon():getId())
		end

		if self:needToThrowArmor() then
			table.insert(unpreferedCards, self.player:getArmor():getId())
		end

		if self.player:getOffensiveHorse() and self.player:getWeapon() then
			table.insert(unpreferedCards, self.player:getOffensiveHorse():getId())
		end
	end

	local use_cards = {}
	for index = #unpreferedCards, 1, -1 do
		if not self.player:isJilei(sgs.Sanguosha:getCard(unpreferedCards[index])) then table.insert(use_cards, unpreferedCards[index]) end
	end

	if #use_cards > 0 then
		if self.room:getMode() == "02_1v1" and sgs.GetConfig("1v1/Rule", "Classical") ~= "Classical" then
			local use_cards_kof = { use_cards[1] }
			if #use_cards > 1 then table.insert(use_cards_kof, use_cards[2]) end
			use.card = sgs.Card_Parse("#hujuzhihengCard:" .. table.concat(use_cards_kof, "+") .. ":")
			return
		else
			use.card = sgs.Card_Parse("#hujuzhihengCard:" .. table.concat(use_cards, "+") .. ":")
			return
		end
	end
end

sgs.ai_use_value["hujuzhihengCard"] = 9
sgs.ai_use_priority["hujuzhihengCard"] = 2.61
sgs.dynamic_value.benefit["hujuzhihengCard"] = true


function sgs.ai_cardneed.hujuzhiheng(to, card)
	return not card:isKindOf("Jink")
end


--天姿
sgs.ai_skill_invoke.sgkgodtianzi = function(self, data)
    local room = self.player:getRoom()
	local n = room:getAlivePlayers():length() - 1
	return n >= 2
end

sgs.ai_skill_choice["sgkgodtianzi"] = function(self, choices, data)
    local tianzi = choices:split("+")
	local diaochan = self.room:findPlayerBySkillName("sgkgodtianzi")
	if self:isEnemy(diaochan) then
	    return tianzi[2]
	else
	    return tianzi[math.random(1, #tianzi)]
	end
end


--魅心
local sgkgodmeixin_skill = {}
sgkgodmeixin_skill.name = "sgkgodmeixin"
table.insert(sgs.ai_skills, sgkgodmeixin_skill)
sgkgodmeixin_skill.getTurnUseCard = function(self, inclusive)
    if self.player:hasUsed("#sgkgodmeixinCard") then return nil end
	if #self.enemies == 0 then return nil end
	local a = 0
	for _, p in ipairs(self.enemies) do
	    if p:isMale() then a = a+1 end
	end
	if a <= 0 then return nil end
	return sgs.Card_Parse("#sgkgodmeixinCard:.:")
end

sgs.ai_skill_use_func["#sgkgodmeixinCard"] = function(card, use, self)
    local target
	self:sort(self.enemies, "threat")
	for _, enemy in ipairs(self.enemies) do
	    if enemy:isMale() then
		    target = enemy
			break
		end
	end
	if not target then return nil end
	if target then
	    use.card = card
		if use.to then use.to:append(target) end
	end
end

sgs.ai_use_value["sgkgodmeixinCard"] = 10
sgs.ai_use_priority["sgkgodmeixinCard"] = 10
sgs.ai_card_intention["sgkgodmeixinCard"]  = 80


--电界
sgs.ai_skill_invoke.sgkgoddianjie = function(self, data)
    local a = math.abs(self.player:getHandcardNum()-self.player:getHp())
	if #self.enemies == 0 then
	    if self.player:hasSkill("sgkgodleihun") and not self.player:hasSkill("jueqing") then
	        if not self.player:isWounded() then
		        return false
	        else
	            if a <= 2 then return true end
		    end
		end
	else
	    if self.player:getHp() <= 1 then return true end
		if a <= 1 then return true end
	end
end

sgs.ai_skill_playerchosen.sgkgoddianjie = function(self, targets)
	local target = nil
	for _, t in sgs.qlist(targets) do
		if t:hasSkill("sgkgodleihun") and (not t:hasSkill("jueqing")) and t:objectName() == self.player:objectName() and self.player:getHp() <= 1 then
			target = t
			break
		end
	end
	if not target then
		local leihun = {}
		for _, _player in sgs.qlist(targets) do
			if self:isEnemy(_player) then
				table.insert(leihun, _player)
			end
		end
		if #leihun == 0 then return nil end
		self:sort(leihun, "hp")
		target = leihun[1]
	end
	return target
end

sgs.ai_skill_use["@@sgkgoddianjie"] = function(self, prompt)
    if #self.enemies <= 0 then return "." end
    local tos = {}
	for _, enemy in ipairs(self.enemies) do
	    if not enemy:isChained() then table.insert(tos, enemy:objectName()) end
	end
	if not self.player:isChained() and not self.player:hasSkill("jueqing") and self.player:hasSkill("sgkgodleihun") then table.insert(self.player:objectName()) end
	if #tos > 1 then return "#sgkgoddianjieCard:.:->" .. table.concat(tos, "+") else return "." end
end

--神道
sgs.ai_skill_invoke.sgkgodshendao = function(self, data)
    local judge = data:toJudge()
	local targets = sgs.SPlayerList()
	for _, p in sgs.qlist(self.room:getAlivePlayers()) do
		if p:getCards("ej"):length() > 0 then  --场上有牌的角色
			targets:append(p)
		end
	end
	local judge_fromhandcardmyself = false
	local to = {}
	if self:needRetrial(judge) then
	    for _, t in sgs.qlist(targets) do
	        if self.player:objectName() == t:objectName() and self:getRetrialCardId(sgs.QList2Table(t:getCards("ej")), judge) ~= -1 then table.insert(to, t) end
		    if self:isEnemy(t) then
		        if self:getRetrialCardId(sgs.QList2Table(t:getCards("e")), judge) ~= -1 then table.insert(to, t) end
		    else
		        if self:getRetrialCardId(sgs.QList2Table(t:getCards("ej")), judge) ~= -1 then table.insert(to, t) end
			end
		end
		if self:getRetrialCardId(sgs.QList2Table(self.player:getHandcards()), judge) ~= -1 then judge_fromhandcardmyself = true end
	end
	if judge_fromhandcardmyself or #to > 0 then
	    if judge:isGood() and self:isEnemy(judge.who) then return true end
	    if judge:isBad() and self:isFriend(judge.who) then return true end
	end
	return false
end

sgs.ai_skill_choice["sgkgodshendao"] = function(self, choices, data)
	local judge = data:toJudge()
	local targets = sgs.SPlayerList()
	for _, p in sgs.qlist(self.room:getAlivePlayers()) do
		if p:getCards("ej"):length() > 0 then  --场上有牌的角色
			targets:append(p)
		end
	end
	local judge_fromhandcardmyself = false
	local to = {}
	if self:needRetrial(judge) then
	    for _, t in sgs.qlist(targets) do
	        if self.player:objectName() == t:objectName() and self:getRetrialCardId(sgs.QList2Table(t:getCards("ej")), judge) ~= -1 then table.insert(to, t) end
		    if self:isEnemy(t) then
		        if self:getRetrialCardId(sgs.QList2Table(t:getCards("e")), judge) ~= -1 then table.insert(to, t) end
		    else
		        if self:getRetrialCardId(sgs.QList2Table(t:getCards("ej")), judge) ~= -1 then table.insert(to, t) end
			end
		end
		if self:getRetrialCardId(sgs.QList2Table(self.player:getHandcards()), judge) ~= -1 then judge_fromhandcardmyself = true end
		if #to > 0 and (not judge_fromhandcardmyself) then return "shendao_wholearea" end
		if #to <= 0 and judge_fromhandcardmyself then return "shendao_selfhandcard" end
		if #to > 0 and judge_fromhandcardmyself then
		    local shendao = choices:split("+")
			return shendao[math.random(1, #shendao)]
		end
	end
end

sgs.ai_skill_cardask["@shendao-card"]=function(self, data)
	local judge = data:toJudge()
	if self.room:getMode():find("_mini_46") and not judge:isGood() then 
		return "$" .. self.player:handCards():first() end
	if self:needRetrial(judge) then
		local cards = sgs.QList2Table(self.player:getHandcards())
		local card_id = self:getRetrialCardId(cards, judge)
		if card_id ~= -1 then
			return "$" .. card_id
		end
	end
	return "."
end

sgs.ai_skill_cardchosen.sgkgodshendao = function(self, who, flags)
	local cards = {}
	local judge = self.player:getTag("shendao_judge"):toJudge()
	local to = judge.who
	local card = judge.card
	local reason = judge.reason
	if self:needRetrial(judge) then
		if self:isFriend(who) then
		    if who:getCards("j"):length() > 0 then
			    cards = sgs.QList2Table(who:getCards("j"))
			else
			    cards = sgs.QList2Table(who:getCards("ej"))
			end
		elseif self:isEnemy(who) then
		    if who:getCards("e"):length() > 0 then
			    cards = sgs.QList2Table(who:getCards("e"))
			end
			if who:hasSkills("guidao|guicai|sr_guicai|hongyan|wuyan|nosguicai|huanshi") then  --如果有能改判的技能或者是不怕闪电的敌人挂了闪电，那么条件允许的情况下，拿闪电改判
			    if who:getCards("e") > 0 then
				    for _, icard in sgs.qlist(who:getCards("e")) do
					    table.insert(cards, icard)
					end
				end
				if who:getCards("j") > 0 then
				    for _, c in sgs.qlist(who:getCards("j")) do
					    if c:isKindOf("Lightning") then table.insert(cards, c) end
					end
				end
			end
		end
		self:sortByKeepValue(cards)
		local card_id = self:getRetrialCardId(cards, judge)
		if card_id ~= -1 then return card_id end
	end
end

sgs.ai_skill_playerchosen.sgkgodshendao = function(self, targets)
    local judge = self.player:getTag("shendao_judge"):toJudge()
	local who = judge.who
	local card = judge.card
	local to = {}
	if self:needRetrial(judge) then
	    for _, t in sgs.qlist(targets) do
	        if self.player:objectName() == t:objectName() then table.insert(to, t) end
		    if self:isEnemy(t) then
		        if self:getRetrialCardId(sgs.QList2Table(t:getCards("e")), judge) ~= -1 then table.insert(to, t) end
		    else
		        if self:getRetrialCardId(sgs.QList2Table(t:getCards("ej")), judge) ~= -1 then table.insert(to, t) end
			end
		end
		if #to > 0 then
	        self:sort(to, "value")
		    return #to[1]
	    end
	end
	return
end


--雷魂
sgs.ai_slash_prohibit.sgkgodleihun = function(self, from, to, card)
	if to:hasSkill("sgkgodleihun") and card:isKindOf("ThunderSlash") then 
	    if not from:hasSkill("jueqing") then 
		    return true 
		else
		    return false
		end
	end
end


--摧锋
local sgkgodcuifeng_skill = {}
sgkgodcuifeng_skill.name = "sgkgodcuifeng"
table.insert(sgs.ai_skills, sgkgodcuifeng_skill)
sgkgodcuifeng_skill.getTurnUseCard = function(self, inclusive)
    if self.player:hasUsed("#sgkgodcuifengCard") then return nil end
	if #self.enemies == 0 then return nil end
	return sgs.Card_Parse("#sgkgodcuifengCard:.:")
end

sgs.ai_skill_use_func["#sgkgodcuifengCard"] = function(card, use, self)
    local target
	self:sort(self.friends, "defense")
	for _, friend in ipairs(self.friends) do
	    if friend:getMark("&nizhan") > 0 then
		    target = friend
			break
		end
	end
	if not target then
		self:sort(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if enemy:getMark("&nizhan") > 0 then
				target = enemy
				break
			end
		end
	end
	if target then
	    use.card = card
		if use.to then use.to:append(target) end
	end
end

sgs.ai_skill_playerchosen["sgkgodcuifeng"] = function(self, targets)
	local players = {}
	for _, p in sgs.qlist(targets) do
		if self:isEnemy(p) then table.insert(players, p) end
	end
	if #players > 0 then
	    self:sort(players, "hp")
		return players[1]
	else
	    self:sort(self.enemies, "hp")
		return self.enemies[1]
	end
end

sgs.ai_use_value["sgkgodcuifengCard"] = 8
sgs.ai_use_priority["sgkgodcuifengCard"] = 6


--君望
sgs.ai_skill_cardask["@junwang"] = function(self, data, pattern)
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByKeepValue(cards)
	local liubei = self.room:findPlayerBySkillName("sgkgodjunwang")
	local junwangcard
	if self:isEnemy(liubei) or (not self:isFriend(liubei))then
		if self:getCardsNum("Peach") + self:getCardsNum("Analeptic") == #cards then
			junwangcard = cards[math.random(1, #cards)]
		else
			local bc
			for _, card in ipairs(cards) do
				if (not card:isKindOf("Peach")) and (not card:isKindOf("Analeptic")) then
					bc = card
					break
				end
			end
			junwangcard = bc
		end
	else
		if self:isFriend(liubei) then
			if (liubei:containsTrick("SupplyShortage") or liubei:containsTrick("Indulgence")) and self:getCardsNum("Nullification") > 0 then
				for _, card in ipairs(cards) do
					if card:isKindOf("Nullification") then
						junwangcard = card
						break
					end
				end
			end
			if not junwangcard then
				if self:isWeak(liubei) and (self:getCardsNum("Peach") > 0 or self:getCardsNum("Analeptic") > 0) then
					for _, card in ipairs(cards) do
						if card:isKindOf("Peach") or card:isKindOf("Analeptic") then
							junwangcard = card
							break
						end
					end
				end
			end
			if not junwangcard then
				if liubei:hasSkills("jizhi|nosjizhi") then
					for _, card in ipairs(cards) do
						if card:isNDTrick() then
							junwangcard = card
							break
						end
					end
				end
			end
			if not junwangcard then
				if liubei:hasSkills("qiangxi|sgkgodzhiji") then
					for _, card in ipairs(cards) do
						if card:isKindOf("Weapon") then
							junwangcard = card
							break
						end
					end
				end
			end
			if not junwangcard then
				junwangcard = cards[math.random(1, #cards)]
			end
		end
	end
	if not junwangcard then
		junwangcard = cards[math.random(1, #cards)]
	end
	return "$" .. junwangcard:getEffectiveId()
end


--激诏
local sgkgodjizhao_skill = {}
sgkgodjizhao_skill.name = "sgkgodjizhao"
table.insert(sgs.ai_skills, sgkgodjizhao_skill)
sgkgodjizhao_skill.getTurnUseCard = function(self, inclusive)
    if self.player:isKongcheng() then return false end
	if #self.enemies <= 0 then return nil end
	if self.player:getHandcardNum() - self:getCardsNum("Peach") - self:getCardsNum("Analeptic") <= 0 then return nil end
	if self.player:getHandcardNum() <= 2 and self.player:getHp() <= 2 then return nil end
	return sgs.Card_Parse("#sgkgodjizhaoCard:.:")
end

sgs.ai_skill_use_func["#sgkgodjizhaoCard"] = function(card, use, self)
    if #self.enemies == 0 then return nil end
    local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local targets = {}
	for _, p in ipairs(self.enemies) do
	    if p:getMark("&zhao") <= 0 and (not self:isWeak(self.player)) then
		    table.insert(targets, p)
		end
	end
	if #targets == 0 then return nil end
	self:sort(targets, "defense")
	local target = targets[1]
	if target then
	    local jizhao_card
		if self:isEnemy(target) then
		    for _, card in ipairs(cards) do
			    if (not card:isKindOf("Peach")) and (not card:isKindOf("Analeptic")) then
				    jizhao_card = card
					break
				end
			end
		end
		if jizhao_card then
	        use.card = sgs.Card_Parse("#sgkgodjizhaoCard:" .. jizhao_card:getEffectiveId() .. ":")
		    if use.to then use.to:append(target) end
		end
		return
	end
end

sgs.ai_use_value["sgkgodjizhaoCard"] = 9
sgs.ai_use_priority["sgkgodjizhaoCard"] = 3


--杀意
local sgkgodshayi_skill = {}
sgkgodshayi_skill.name = "sgkgodshayi"
table.insert(sgs.ai_skills, sgkgodshayi_skill)
sgkgodshayi_skill.getTurnUseCard = function(self)
    if self.player:getMark("shayi") <= 0 then return nil end
	local cards = self.player:getCards("he")	
	cards=sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	local shayi_slash
	for _, card in ipairs(cards) do
	    if card:isBlack() then
		    shayi_slash = card
			break
		end
	end
	if not shayi_slash then return nil end
	local suit = shayi_slash:getSuitString()
	local number = shayi_slash:getNumberString()
	local card_id = shayi_slash:getEffectiveId()
	local card_str = ("slash:sgkgodshayi[%s:%s]=%d"):format(suit, number, card_id)
	local slash = sgs.Card_Parse(card_str)
	assert(slash)
	return slash
end

sgs.ai_view_as["sgkgodshayi"] = function(card, player, card_place)
    local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card:isBlack() and player:getMark("shayi") > 0 then
		return ("slash:sgkgodshayi[%s:%s]=%d"):format(suit, number, card_id)
	end
end


--震魂
local sgkgodzhenhun_skill = {}
sgkgodzhenhun_skill.name = "sgkgodzhenhun"
table.insert(sgs.ai_skills, sgkgodzhenhun_skill)
sgkgodzhenhun_skill.getTurnUseCard = function(self, inclusive)
    if #self.enemies == 0 then return nil end
	if self.player:isNude() then return nil end
	if self.player:hasUsed("#sgkgodzhenhunCard") then return nil end
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	if self:needToThrowArmor() then
		return sgs.Card_Parse("#sgkgodzhenhunCard:" .. self.player:getArmor():getEffectiveId() .. ":")
	end
	return sgs.Card_Parse("#sgkgodzhenhunCard:"..cards[1]:getEffectiveId()..":")
end

sgs.ai_skill_use_func["#sgkgodzhenhunCard"] = function(card, use, self)
    use.card = card
end

sgs.ai_use_value["sgkgodzhenhunCard"] = 10
sgs.ai_use_priority["sgkgodzhenhunCard"] = 8.5


--掠阵
sgs.ai_skill_invoke.sgkgodluezhen = function(self, data)
    local use = data:toCardUse()
	local ganning = self.room:findPlayerBySkillName("sgkgodluezhen")
	if use.card:isKindOf("Slash") and use.from:objectName() == ganning:objectName() and not use.to:contains(ganning) then
	    for _, t in sgs.qlist(use.to) do
		    if self:isEnemy(t) then
			    return true
			end
		end
	end
	return false
end


--游龙
local sgkgodyoulong_skill = {}
sgkgodyoulong_skill.name = "sgkgodyoulong"
table.insert(sgs.ai_skills, sgkgodyoulong_skill)
sgkgodyoulong_skill.getTurnUseCard = function(self, inclusive)
    if self.player:getMark("youlong") == 0 then return nil end
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards,true)
	local youlong_black
	for _, card in ipairs(cards) do
	    if card:isBlack() and ((self:getUseValue(card) < sgs.ai_use_value.Snatch) or inclusive) then
		    local shouldUse = true
			if card:isKindOf("Slash") then
				local dummy_use = {isDummy = true}
				if self:getCardsNum("Slash") == 1 then
					self:useBasicCard(card, dummy_use)
					if dummy_use.card then shouldUse = false end
				end
			end
			if self:getUseValue(card) > sgs.ai_use_value.Snatch and card:isKindOf("TrickCard") then
				local dummy_use = {isDummy = true}
				self:useTrickCard(card, dummy_use)
				if dummy_use.card then shouldUse = false end
			end
			if shouldUse then
				youlong_black = card
				break
			end
		end
	end
	if youlong_black then
		local suit = youlong_black:getSuitString()
		local number = youlong_black:getNumberString()
		local card_id = youlong_black:getEffectiveId()
		local card_str = ("snatch:sgkgodyoulong[%s:%s]=%d"):format(suit, number, card_id)
		local youlong_snatch = sgs.Card_Parse(card_str)
		assert(youlong_snatch)
		return youlong_snatch
	end
end

sgs.sgkgodyoulong_suit_value = {
	spade = 3.9,
	club = 3.9
}

function sgs.ai_cardneed.sgkgodyoulong(to, card)
	return card:isBlack() and not card:isEquipped()
end


--通天
local sgkgodtongtian_skill = {}
sgkgodtongtian_skill.name = "sgkgodtongtian"
table.insert(sgs.ai_skills, sgkgodtongtian_skill)
sgkgodtongtian_skill.getTurnUseCard = function(self, inclusive)
    if self.player:isKongcheng() then return nil end
	if self.player:getMark("@tian") <= 0 then return nil end
	local suits = {}
	for _, card in sgs.qlist(self.player:getCards("he")) do
	    if card:getSuit() == sgs.Card_Spade then
		    table.insert(suits, card:getSuitString())
			break
		end
	end
	for _, card in sgs.qlist(self.player:getCards("he")) do
	    if card:getSuit() == sgs.Card_Heart then
		    table.insert(suits, card:getSuitString())
			break
		end
	end
	for _, card in sgs.qlist(self.player:getCards("he")) do
	    if card:getSuit() == sgs.Card_Club then
		    table.insert(suits, card:getSuitString())
			break
		end
	end
	for _, card in sgs.qlist(self.player:getCards("he")) do
	    if card:getSuit() == sgs.Card_Diamond then
		    table.insert(suits, card:getSuitString())
			break
		end
	end
	if #suits > 3 then
	    return sgs.Card_Parse("#sgkgodtongtianCard:.:")
	end
end

sgs.ai_skill_use_func["#sgkgodtongtianCard"] = function(card, use, self)
    local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards, false, true)
	local need_cards = {}
	local spade, club, heart, diamond
	for _, card in ipairs(cards) do
	    if card:getSuit() == sgs.Card_Spade then
		    if (not self.player:hasSkills("fankui|nosfankui")) and (not spade) then
			    spade = true
				table.insert(need_cards, card:getId())
			end
		elseif card:getSuit() == sgs.Card_Heart then
		    if (not self.player:hasSkill("guanxing")) and (not heart) then
			    heart = true
				table.insert(need_cards, card:getId())
			end
		elseif card:getSuit() == sgs.Card_Club then
		    if (not self.player:hasSkill("wansha")) and (not club) then
			    club = true
				table.insert(need_cards, card:getId())
			end
		elseif card:getSuit() == sgs.Card_Diamond then
		    if (not self.player:hasSkills("zhiheng|hujuzhiheng")) and (not diamond) then
			    diamond = true
				table.insert(need_cards, card:getId())
			end
		end
	end
	if #need_cards < 4 then return nil end
	local tongtian_cards = sgs.Card_Parse("#sgkgodtongtianCard:" .. table.concat(need_cards, "+") .. ":")
	assert(tongtian_cards)
	use.card = tongtian_cards
end


sgs.ai_use_value["sgkgodtongtianCard"] = 10
sgs.ai_use_priority["sgkgodtongtianCard"] = 9  --强行改动：没有四张花色，打死不【通天】。


--制衡（通天）
local tongtian_zhiheng_skill = {}
tongtian_zhiheng_skill.name = "tongtian_zhiheng"
table.insert(sgs.ai_skills, tongtian_zhiheng_skill)
tongtian_zhiheng_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#tongtian_zhihengCard") then
		return sgs.Card_Parse("#tongtian_zhihengCard:.:")
	end
end

sgs.ai_skill_use_func["#tongtian_zhihengCard"] = function(card, use, self)
	local unpreferedCards = {}
	local cards = sgs.QList2Table(self.player:getHandcards())

	if self.player:getHp() < 3 then
		local zcards = self.player:getCards("he")
		local use_slash, keep_jink, keep_analeptic, keep_weapon = false, false, false
		local keep_slash = self.player:getTag("JilveWansha"):toBool()
		for _, zcard in sgs.qlist(zcards) do
			if not isCard("Peach", zcard, self.player) and not isCard("ExNihilo", zcard, self.player) then
				local shouldUse = true
				if isCard("Slash", zcard, self.player) and not use_slash then
					local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
					self:useBasicCard(zcard, dummy_use)
					if dummy_use.card then
						if keep_slash then shouldUse = false end
						if dummy_use.to then
							for _, p in sgs.qlist(dummy_use.to) do
								if p:getHp() <= 1 then
									shouldUse = false
									if self.player:distanceTo(p) > 1 then keep_weapon = self.player:getWeapon() end
									break
								end
							end
							if dummy_use.to:length() > 1 then shouldUse = false end
						end
						if not self:isWeak() then shouldUse = false end
						if not shouldUse then use_slash = true end
					end
				end
				if zcard:getTypeId() == sgs.Card_TypeTrick then
					local dummy_use = { isDummy = true }
					self:useTrickCard(zcard, dummy_use)
					if dummy_use.card then shouldUse = false end
				end
				if zcard:getTypeId() == sgs.Card_TypeEquip and not self.player:hasEquip(zcard) then
					local dummy_use = { isDummy = true }
					self:useEquipCard(zcard, dummy_use)
					if dummy_use.card then shouldUse = false end
					if keep_weapon and zcard:getEffectiveId() == keep_weapon:getEffectiveId() then shouldUse = false end
				end
				if self.player:hasEquip(zcard) and zcard:isKindOf("Armor") and not self:needToThrowArmor() then shouldUse = false end
				if self.player:hasEquip(zcard) and zcard:isKindOf("DefensiveHorse") and not self:needToThrowArmor() then shouldUse = false end
				if isCard("Jink", zcard, self.player) and not keep_jink then
					keep_jink = true
					shouldUse = false
				end
				if self.player:getHp() == 1 and isCard("Analeptic", zcard, self.player) and not keep_analeptic then
					keep_analeptic = true
					shouldUse = false
				end
				if shouldUse then table.insert(unpreferedCards, zcard:getId()) end
			end
		end
	end

	if #unpreferedCards == 0 then
		local use_slash_num = 0
		self:sortByKeepValue(cards)
		for _, card in ipairs(cards) do
			if card:isKindOf("Slash") then
				local will_use = false
				if use_slash_num <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, card) then
					local dummy_use = { isDummy = true }
					self:useBasicCard(card, dummy_use)
					if dummy_use.card then
						will_use = true
						use_slash_num = use_slash_num + 1
					end
				end
				if not will_use then table.insert(unpreferedCards, card:getId()) end
			end
		end

		local num = self:getCardsNum("Jink") - 1
		if self.player:getArmor() then num = num + 1 end
		if num > 0 then
			for _, card in ipairs(cards) do
				if card:isKindOf("Jink") and num > 0 then
					table.insert(unpreferedCards, card:getId())
					num = num - 1
				end
			end
		end
		for _, card in ipairs(cards) do
			if (card:isKindOf("Weapon") and self.player:getHandcardNum() < 3) or card:isKindOf("OffensiveHorse")
				or self:getSameEquip(card, self.player) or card:isKindOf("AmazingGrace") then
				table.insert(unpreferedCards, card:getId())
			elseif card:getTypeId() == sgs.Card_TypeTrick then
				local dummy_use = { isDummy = true }
				self:useTrickCard(card, dummy_use)
				if not dummy_use.card then table.insert(unpreferedCards, card:getId()) end
			end
		end

		if self.player:getWeapon() and self.player:getHandcardNum() < 3 then
			table.insert(unpreferedCards, self.player:getWeapon():getId())
		end

		if self:needToThrowArmor() then
			table.insert(unpreferedCards, self.player:getArmor():getId())
		end

		if self.player:getOffensiveHorse() and self.player:getWeapon() then
			table.insert(unpreferedCards, self.player:getOffensiveHorse():getId())
		end
	end

	local use_cards = {}
	for index = #unpreferedCards, 1, -1 do
		if not self.player:isJilei(sgs.Sanguosha:getCard(unpreferedCards[index])) then table.insert(use_cards, unpreferedCards[index]) end
	end

	if #use_cards > 0 then
		if self.room:getMode() == "02_1v1" and sgs.GetConfig("1v1/Rule", "Classical") ~= "Classical" then
			local use_cards_kof = { use_cards[1] }
			if #use_cards > 1 then table.insert(use_cards_kof, use_cards[2]) end
			use.card = sgs.Card_Parse("#tongtian_zhihengCard:" .. table.concat(use_cards_kof, "+") .. ":")
			return
		else
			use.card = sgs.Card_Parse("#tongtian_zhihengCard:" .. table.concat(use_cards, "+") .. ":")
			return
		end
	end
end

sgs.ai_use_value["tongtian_zhihengCard"] = 9
sgs.ai_use_priority["tongtian_zhihengCard"] = 2.61
sgs.dynamic_value.benefit["tongtian_zhihengCard"] = true


function sgs.ai_cardneed.tongtian_zhiheng(to, card)
	return not card:isKindOf("Jink")
end


--反馈
sgs.ai_skill_invoke.tongtian_fankui = function(self, data)
    local damage = data:toDamage()
	if self:isEnemy(damage.from) then
	    return true
	end
	return false
end


--观星
dofile "lua/ai/guanxing-ai.lua"


--极略
local sgkgodjilue_skill = {}
sgkgodjilue_skill.name = "sgkgodjilue"
table.insert(sgs.ai_skills, sgkgodjilue_skill)
sgkgodjilue_skill.getTurnUseCard = function(self, inclusive)
    if self.player:hasFlag("jiluefailed") then return nil end
	return sgs.Card_Parse("#sgkgodjilueCard:.:")
end

sgs.ai_skill_use_func["#sgkgodjilueCard"] = function(card, use, self)
    if self.player:hasFlag("jiluefailed") then return nil end
	use.card = card
end

sgs.ai_use_value["sgkgodjilueCard"] = 10
sgs.ai_use_priority["sgkgodjilueCard"] = 8
sgs.dynamic_value.benefit["sgkgodjilueCard"] = true


--第一部分：含有锦囊牌的pattern
--1-1：锦囊牌、杀
sgs.ai_skill_use["TrickCard+^Nullification,Slash,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Slash") then
			    local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    if not dummy_use.to:isEmpty() then
				        local target_objectname = {}
					    for _, p in sgs.qlist(dummy_use.to) do
						    table.insert(target_objectname, p:objectName())
					    end
					    return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
					end
				end
			end
		end
	end
	return "."
end

--1-2：锦囊牌、杀、装备牌
sgs.ai_skill_use["TrickCard+^Nullification,Slash,EquipCard,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		elseif card:getTypeId() == sgs.Card_TypeEquip and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if dummy_use.card then
				return dummy_use.card:toString()
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Slash") then
			    local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    if not dummy_use.to:isEmpty() then
				        local target_objectname = {}
					    for _, p in sgs.qlist(dummy_use.to) do
						    table.insert(target_objectname, p:objectName())
					    end
					    return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
					end
				end
			end
		end
	end
	return "."
end

--1-3：锦囊牌、杀、酒
sgs.ai_skill_use["TrickCard+^Nullification,Slash,Analeptic,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Slash") then
			    local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    if not dummy_use.to:isEmpty() then
				        local target_objectname = {}
					    for _, p in sgs.qlist(dummy_use.to) do
						    table.insert(target_objectname, p:objectName())
					    end
					    return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
					end
				end
			elseif card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--1-4：锦囊牌、杀、酒、装备牌
sgs.ai_skill_use["TrickCard+^Nullification,Slash,Analeptic,EquipCard,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		elseif card:getTypeId() == sgs.Card_TypeEquip and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if dummy_use.card then
				return dummy_use.card:toString()
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Slash") then
			    local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    if not dummy_use.to:isEmpty() then
				        local target_objectname = {}
					    for _, p in sgs.qlist(dummy_use.to) do
						    table.insert(target_objectname, p:objectName())
					    end
					    return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
					end
				end
			elseif card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--1-5：锦囊牌、桃
sgs.ai_skill_use["TrickCard+^Nullification,Peach,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Peach") then
			    local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    return dummy_use.card:toString()
				end
			end
		end
	end
	return "."
end

--1-6：锦囊牌、桃、装备牌
sgs.ai_skill_use["TrickCard+^Nullification,Peach,EquipCard,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		elseif card:getTypeId() == sgs.Card_TypeEquip and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if dummy_use.card then
				return dummy_use.card:toString()
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Peach") then
			    local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    return dummy_use.card:toString()
				end
			end
		end
	end
	return "."
end

--1-7：锦囊牌、桃、酒
sgs.ai_skill_use["TrickCard+^Nullification,EquipCard,Slash,Peach,Analeptic|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Peach") then
			    local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    return dummy_use.card:toString()
				end
			elseif card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--1-8：锦囊牌、桃、酒、装备牌
sgs.ai_skill_use["TrickCard+^Nullification,Peach,Analeptic,EquipCard,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		elseif card:getTypeId() == sgs.Card_TypeEquip then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if dummy_use.card then
				return dummy_use.card:toString()
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic then
		    if card:isKindOf("Peach") then
			    local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    return dummy_use.card:toString()
				end
			elseif card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--1-9：锦囊牌、桃、杀
sgs.ai_skill_use["TrickCard+^Nullification,Peach,Slash,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Peach") then
			    local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    return dummy_use.card:toString()
				end
			elseif card:isKindOf("Slash") then
			    local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    if not dummy_use.to:isEmpty() then
				        local target_objectname = {}
					    for _, p in sgs.qlist(dummy_use.to) do
						    table.insert(target_objectname, p:objectName())
					    end
					    return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
					end
				end
			end
		end
	end
	return "."
end

--1-10：锦囊牌、桃、杀、装备牌
sgs.ai_skill_use["TrickCard+^Nullification,Peach,Slash,EquipCard,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		elseif card:getTypeId() == sgs.Card_TypeEquip and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if dummy_use.card then
				return dummy_use.card:toString()
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Peach") then
			    local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    return dummy_use.card:toString()
				end
			elseif card:isKindOf("Slash") then
			    local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    if not dummy_use.to:isEmpty() then
				        local target_objectname = {}
					    for _, p in sgs.qlist(dummy_use.to) do
						    table.insert(target_objectname, p:objectName())
					    end
					    return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
					end
				end
			end
		end
	end
	return "."
end

--1-11：锦囊牌、基本牌（除闪）
sgs.ai_skill_use["TrickCard+^Nullification,Peach,Slash,Analeptic,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Peach") then
			    local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    return dummy_use.card:toString()
				end
			elseif card:isKindOf("Slash") then
			    local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    if not dummy_use.to:isEmpty() then
				        local target_objectname = {}
					    for _, p in sgs.qlist(dummy_use.to) do
						    table.insert(target_objectname, p:objectName())
					    end
					    return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
					end
				end
			elseif card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--1-12：锦囊牌、基本牌（除闪）、装备牌
sgs.ai_skill_use["TrickCard+^Nullification,Peach,Slash,Analeptic,EquipCard,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		elseif card:getTypeId() == sgs.Card_TypeEquip and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if dummy_use.card then
				return dummy_use.card:toString()
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Peach") then
			    local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    return dummy_use.card:toString()
				end
			elseif card:isKindOf("Slash") then
			    local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    if not dummy_use.to:isEmpty() then
				        local target_objectname = {}
					    for _, p in sgs.qlist(dummy_use.to) do
						    table.insert(target_objectname, p:objectName())
					    end
					    return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
					end
				end
			elseif card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--1-13：锦囊牌、酒
sgs.ai_skill_use["TrickCard+^Nullification,Analeptic,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--1-14：锦囊牌、酒、装备牌
sgs.ai_skill_use["TrickCard+^Nullification,Analeptic,EquipCard,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		elseif card:getTypeId() == sgs.Card_TypeEquip and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if dummy_use.card then
				return dummy_use.card:toString()
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--1-15：锦囊牌、装备牌
sgs.ai_skill_use["TrickCard+^Nullification,EquipCard,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		elseif card:getTypeId() == sgs.Card_TypeEquip and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if dummy_use.card then
				return dummy_use.card:toString()
			end
		end
	end
	return "."
end

--1-16：锦囊牌
sgs.ai_skill_use["TrickCard+^Nullification,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
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

--第二部分：无锦囊牌的pattern
--2-1：杀
sgs.ai_skill_use["Slash,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Slash") then
			    local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    if not dummy_use.to:isEmpty() then
				        local target_objectname = {}
					    for _, p in sgs.qlist(dummy_use.to) do
						    table.insert(target_objectname, p:objectName())
					    end
					    return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
					end
				end
			end
		end
	end
	return "."
end

--2-2：杀、装备牌
sgs.ai_skill_use["Slash,EquipCard,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeEquip and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if dummy_use.card then
				return dummy_use.card:toString()
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Slash") then
			    local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    if not dummy_use.to:isEmpty() then
				        local target_objectname = {}
					    for _, p in sgs.qlist(dummy_use.to) do
						    table.insert(target_objectname, p:objectName())
					    end
					    return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
					end
				end
			end
		end
	end
	return "."
end

--2-3：杀，酒
sgs.ai_skill_use["Slash,Analeptic,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Slash") then
			    local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    if not dummy_use.to:isEmpty() then
				        local target_objectname = {}
					    for _, p in sgs.qlist(dummy_use.to) do
						    table.insert(target_objectname, p:objectName())
					    end
					    return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
					end
				end
			elseif card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--2-4：杀、酒、装备牌
sgs.ai_skill_use[" Slash,Analeptic,EquipCard,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeEquip and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if dummy_use.card then
				return dummy_use.card:toString()
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Slash") then
			    local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    if not dummy_use.to:isEmpty() then
				        local target_objectname = {}
					    for _, p in sgs.qlist(dummy_use.to) do
						    table.insert(target_objectname, p:objectName())
					    end
					    return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
					end
				end
			elseif card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--2-5：桃
sgs.ai_skill_use["Peach,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Peach") then
			    local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    return dummy_use.card:toString()
				end
			end
		end
	end
	return "."
end

--2-6：桃、装备牌
sgs.ai_skill_use["Peach,EquipCard,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeEquip and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if dummy_use.card then
				return dummy_use.card:toString()
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Peach") then
			    local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    return dummy_use.card:toString()
				end
			end
		end
	end
	return "."
end

--2-7：桃、酒
sgs.ai_skill_use["Peach,Analeptic,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Peach") then
			    local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    return dummy_use.card:toString()
				end
			elseif card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--2-8：桃、酒、装备牌
sgs.ai_skill_use["Peach,Analeptic,EquipCard|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeEquip and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if dummy_use.card then
				return dummy_use.card:toString()
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Peach") then
			    local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    return dummy_use.card:toString()
				end
			elseif card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--2-9：桃、杀
sgs.ai_skill_use["Peach,Slash,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Peach") then
			    local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    return dummy_use.card:toString()
				end
			elseif card:isKindOf("Slash") then
			    local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    if not dummy_use.to:isEmpty() then
				        local target_objectname = {}
					    for _, p in sgs.qlist(dummy_use.to) do
						    table.insert(target_objectname, p:objectName())
					    end
					    return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
					end
				end
			end
		end
	end
	return "."
end

--2-10：桃、杀、装备牌
sgs.ai_skill_use["Peach,Slash,EquipCard|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and not card:isKindOf("Nullification") and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				if dummy_use.to:isEmpty() then
					return dummy_use.card:toString()
				else
					local target_objectname = {}
					for _, p in sgs.qlist(dummy_use.to) do
						table.insert(target_objectname, p:objectName())
					end
					return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
				end
			end
		elseif card:getTypeId() == sgs.Card_TypeEquip and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if dummy_use.card then
				return dummy_use.card:toString()
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Peach") then
			    local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    return dummy_use.card:toString()
				end
			elseif card:isKindOf("Slash") then
			    local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    if not dummy_use.to:isEmpty() then
				        local target_objectname = {}
					    for _, p in sgs.qlist(dummy_use.to) do
						    table.insert(target_objectname, p:objectName())
					    end
					    return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
					end
				end
			elseif card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--2-11：除了闪的基本牌
sgs.ai_skill_use["Peach,Slash,Analeptic,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Peach") then
			    local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    return dummy_use.card:toString()
				end
			elseif card:isKindOf("Slash") then
			    local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    if not dummy_use.to:isEmpty() then
				        local target_objectname = {}
					    for _, p in sgs.qlist(dummy_use.to) do
						    table.insert(target_objectname, p:objectName())
					    end
					    return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
					end
				end
			elseif card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--2-12：基本牌（除闪）、装备牌
sgs.ai_skill_use["Peach,Slash,Analeptic,EquipCard|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeEquip and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if dummy_use.card then
				return dummy_use.card:toString()
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Peach") then
			    local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    return dummy_use.card:toString()
				end
			elseif card:isKindOf("Slash") then
			    local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
				    if not dummy_use.to:isEmpty() then
				        local target_objectname = {}
					    for _, p in sgs.qlist(dummy_use.to) do
						    table.insert(target_objectname, p:objectName())
					    end
					    return dummy_use.card:toString() .. "->" .. table.concat(target_objectname, "+")
					end
				end
			elseif card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--2-13：酒
sgs.ai_skill_use[" Analeptic,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--2-14：酒、装备牌
sgs.ai_skill_use["Analeptic,EquipCard|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeEquip and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if dummy_use.card then
				return dummy_use.card:toString()
			end
		elseif card:getTypeId() == sgs.Card_TypeBasic and not self.player:isLocked(card) then
		    if card:isKindOf("Analeptic") then
			    local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
				if not self.player:isCardLimited(ana, sgs.Card_MethodUse) and not self.player:isProhibited(self.player, ana) then
				    if self.player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, ana) then
					    if sgs.Analeptic_IsAvailable(self.player) then
						    local dummy_use = { isDummy = true }
				                self:useBasicCard(card, dummy_use)
				            if dummy_use.card then
				                return dummy_use.card:toString()
				            end
						end
					end
				end
			end
		end
	end
	return "."
end

--2-15：装备牌
sgs.ai_skill_use["EquipCard,|.|.|.|."] = function(self, prompt, method)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeEquip and not self.player:isLocked(card) then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if dummy_use.card then
				return dummy_use.card:toString()
			end
		end
	end
	return "."
end


--湮灭
local sgkgodyanmie_skill = {}
sgkgodyanmie_skill.name = "sgkgodyanmie"
table.insert(sgs.ai_skills, sgkgodyanmie_skill)
sgkgodyanmie_skill.getTurnUseCard = function(self, inclusive)
    if #self.enemies == 0 then return nil end
	if self.player:isKongcheng() then return nil end
	return sgs.Card_Parse("#sgkgodyanmieCard:.:")
end

sgs.ai_skill_use_func["#sgkgodyanmieCard"] = function(card, use, self)
    if #self.enemies == 0 then return nil end
	if self.player:isKongcheng() then return nil end
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local target
	for _, enemy in ipairs(self.enemies) do
	    if (not enemy:hasSkill("manjuan")) and (not enemy:isKongcheng()) and enemy:getHandcardNum() - 3*enemy:getHp() >= 0 then
		    target = enemy
			break
		end
	end
	if not target then
	    for _, enemy in ipairs(self.enemies) do
		    if (not enemy:hasSkill("manjuan")) and (not enemy:isKongcheng()) and enemy:getHandcardNum() > enemy:getHp() then
			    target = enemy
				break
			end
		end
	end
	if not target then
	    for _, enemy in ipairs(self.enemies) do
		    if (not enemy:hasSkill("manjuan")) and (not enemy:isKongcheng()) and enemy:getHandcardNum() >= 3 then
			    target = enemy
				break
			end
		end
	end
	if not target then return nil end
	if target then
	    local yanmie_use
		for _, _card in ipairs(cards) do
		    if _card:getSuit() == sgs.Card_Spade then
			    yanmie_use = _card
				break
			end
		end
		if yanmie_use then
		    use.card = sgs.Card_Parse("#sgkgodyanmieCard:" .. yanmie_use:getEffectiveId() .. ":")
			if use.to then use.to:append(target) end
		end
	end
end

sgs.sgkgodyanmie_suit_value = {
	spade = 4
}

sgs.ai_skill_choice["sgkgodyanmie"] = function(self, choices, data)
    return "dis-yanmie"
end


sgs.ai_use_value["sgkgodyanmieCard"] = 10
sgs.ai_use_priority["sgkgodyanmieCard"] = 7.5
sgs.ai_card_intention["sgkgodyanmieCard"] = 300


--顺世
sgs.ai_skill_use["@@sgkgodshunshi"] = function(self, prompt)
    if #self.enemies <= 1 then return "." end
    local shunshi_card = self.room:getTag("shunshi_tag"):toString()
	local upperlimit = self.player:getMark("shunshi")
	if shunshi_card == "shunshi_slash" then
	    local targetsA = {}
		for _, enemy in ipairs(self.enemies) do
		    if enemy:getMark("shunshi_from") <= 0 and (not enemy:hasSkill("liuli")) then table.insert(targetsA, enemy:objectName()) end
			if #targetsA == upperlimit then break end
		end
		if #targetsA > 0 then return "#sgkgodshunshiCard:.:->" .. table.concat(targetsA, "+") else return "." end
	end
	if shunshi_card == "shunshi_peach" then
	    local targetsB = {}
		for _, friend in ipairs(self.friends_noself) do
		    if friend:getMark("shunshi_from") <= 0 then table.insert(targetsB, friend:objectName()) end
			if #targetsB == upperlimit then break end
		end
		if #targetsB > 0 then return "#sgkgodshunshiCard:.:->" .. table.concat(targetsB, "+") else return "." end
	end
	return "."
end


--归心
function sgkgodguixinValue(self, player)
	if player:isAllNude() then return 0 end
	local card_id = self:askForCardChosen(player, "hej", "dummy")
	if self:isEnemy(player) then
		for _, card in sgs.qlist(player:getJudgingArea()) do
			if card:getEffectiveId() == card_id then
				if card:isKindOf("YanxiaoCard") then return 0
				elseif card:isKindOf("Lightning") then
					if self:hasWizard(self.enemies, true) then return 0.8
					elseif self:hasWizard(self.friends, true) then return 0.4
					else return 0.5 * (#self.friends) / (#self.friends + #self.enemies) end
				else
					return -0.2
				end
			end
		end
		for i = 0, 3 do
			local card = player:getEquip(i)
			if card and card:getEffectiveId() == card_id then
				if card:isKindOf("Armor") and self:needToThrowArmor(player) then return 0 end
				local value = 0
				if self:getDangerousCard(player) == card_id then value = 1.5
				elseif self:getValuableCard(player) == card_id then value = 1.1
				elseif i == 1 then value = 1
				elseif i == 2 then value = 0.8
				elseif i == 0 then value = 0.7
				elseif i == 3 then value = 0.5
				end
				if player:hasSkills(sgs.lose_equip_skill) or self:doNotDiscard(player, "e", true) then value = value - 0.2 end
				return value
			end
		end
		if self:needKongcheng(player) and player:getHandcardNum() == 1 then return 0 end
		if not self:hasLoseHandcardEffective() then return 0.1
		else
			local index = player:hasSkills("jijiu|qingnang|leiji|nosleiji|jieyin|beige|kanpo|liuli|qiaobian|zhiheng|guidao|longhun|xuanfeng|tianxiang|noslijian|lijian") and 0.7 or 0.6
			local value = 0.2 + index / (player:getHandcardNum() + 1)
			if self:doNotDiscard(player, "h", true) then value = value - 0.1 end
			return value
		end
	elseif self:isFriend(player) then
		for _, card in sgs.qlist(player:getJudgingArea()) do
			if card:getEffectiveId() == card_id then
				if card:isKindOf("YanxiaoCard") then return 0
				elseif card:isKindOf("Lightning") then
					if self:hasWizard(self.enemies, true) then return 1
					elseif self:hasWizard(self.friends, true) then return 0.8
					else return 0.4 * (#self.enemies) / (#self.friends + #self.enemies) end
				else
					return 1.5
				end
			end
		end
		for i = 0, 3 do
			local card = player:getEquip(i)
			if card and card:getEffectiveId() == card_id then
				if card:isKindOf("Armor") and self:needToThrowArmor(player) then return 0.9 end
				local value = 0
				if i == 1 then value = 0.1
				elseif i == 2 then value = 0.2
				elseif i == 0 then value = 0.25
				elseif i == 3 then value = 0.25
				end
				if player:hasSkills(sgs.lose_equip_skill) then value = value + 0.1 end
				if player:hasSkills("tuntian+zaoxian") then value = value + 0.1 end
				return value
			end
		end
		if self:needKongcheng(player, true) and player:getHandcardNum() == 1 then return 0.5
		elseif self:needKongcheng(player) and player:getHandcardNum() == 1 then return 0.3 end
		if not self:hasLoseHandcardEffective() then return 0.2
		else
			local index = player:hasSkills("jijiu|qingnang|leiji|nosleiji|jieyin|beige|kanpo|liuli|qiaobian|zhiheng|guidao|longhun|xuanfeng|tianxiang|noslijian|lijian") and 0.5 or 0.4
			local value = 0.2 - index / (player:getHandcardNum() + 1)
			if player:hasSkills("tuntian+zaoxian") then value = value + 0.1 end
			return value
		end
	end
	return 0.3
end

sgs.ai_skill_invoke.sgkgodguixin = function(self, data)
	local damage = data:toDamage()
	local diaochan = self.room:findPlayerBySkillName("lihun")
	local lihun_eff = (diaochan and self:isEnemy(diaochan))
	local manjuan_eff = hasManjuanEffect(self.player)
	if lihun_eff and not manjuan_eff then return false end
	local players = self.room:getPlayers()
	local t = 0
	for _, _player in sgs.qlist(players) do
	    if _player:objectName() ~= self.player:objectName() and _player:getCards("hej"):length() > 0 then t = t + 1 end
		if _player:isDead() then t = t + 1 end
	end
	if not self.player:faceUp() then return true
	else
		if manjuan_eff then return false end
		if t >= 3 then return true end
		local value = 0
		for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			value = value + sgkgodguixinValue(self, player)
		end
		local left_num = damage.damage - self.player:getMark("guixin_times")
		return value >= 1.3 or left_num > 0
	end
end

sgs.ai_need_damaged.sgkgodguixin = function(self, attacker, player)
	if self.room:alivePlayerCount() <= 3 or player:hasSkill("manjuan") then return false end
	local diaochan = self.room:findPlayerBySkillName("lihun")
	local drawcards = 0
	for _, aplayer in sgs.qlist(self.room:getOtherPlayers(player)) do
		if aplayer:getCards("hej"):length() > 0 then drawcards = drawcards + 1 end
	end
	for _, aaplayer in sgs.qlist(self.room:getPlayers()) do
	    if aaplayer:isDead() then drawcards = drawcards + 1 end
	end
	return not self:isLihunTarget(player, drawcards)
end


--知天
sgs.ai_skill_playerchosen.sgkgodzhitian = function(self, targets)
	local zhitian = {}
	for _, _player in sgs.qlist(targets) do
	    if self:isFriend(_player) then table.insert(zhitian, _player) end
	end
	self:sort(zhitian, "value")
	if #zhitian > 0 then
	    self:sort(zhitian, "value")
	    return zhitian[1]
	end
end


--掷戟
local sgkgodzhiji_skill = {}
sgkgodzhiji_skill.name = "sgkgodzhiji"
table.insert(sgs.ai_skills, sgkgodzhiji_skill)
sgkgodzhiji_skill.getTurnUseCard = function(self, inclusive)
    if #self.enemies == 0 then return nil end
	if self.player:hasUsed("#sgkgodzhijiCard") then return nil end
	if self.player:isNude() then return nil end
	return sgs.Card_Parse("#sgkgodzhijiCard:.:")
end

sgs.ai_skill_use_func["#sgkgodzhijiCard"] = function(card, use, self)
    if #self.enemies == 0 then return nil end
	if self.player:isNude() then return nil end
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	local zhiji_weapons = {}
	for _, c in ipairs(cards) do
	    if c:isKindOf("Weapon") then table.insert(zhiji_weapons, c:getEffectiveId()) end
	end
	if #zhiji_weapons > 0 then
		use.card = sgs.Card_Parse("#sgkgodzhijiCard:" .. table.concat(zhiji_weapons, "+") .. ":")
		if use.to then
			for _, enemy in ipairs(self.enemies) do
				if self:damageIsEffective(enemy) then
					if #zhiji_weapons > 1 and not enemy:hasArmorEffect("silver_lion") then
						use.to:append(enemy)
						if use.to:length() == #zhiji_weapons then break end
					elseif #zhiji_weapons == 1 then
						use.to:append(enemy)
						if use.to:length() == #zhiji_weapons then break end
					end
				end
			end
			assert(use.to:length() > 0)
		end
	end
end


sgs.ai_use_value["sgkgodzhijiCard"] = 5
sgs.ai_use_priority["sgkgodzhijiCard"] = sgs.ai_use_priority.Slash - 0.1
sgs.ai_card_intention["sgkgodzhijiCard"] = 200
sgs.ai_cardneed.sgkgodzhiji = sgs.ai_cardneed.weapon

sgs.ai_skill_invoke.sgkgodzhiji = true

sgs.sgkgodzhiji_keep_value = {
    weapon = 5.5
}


--涉猎
sgs.ai_skill_choice.sgkgodshelie = function(self, choices)
    local shelie = choices:split("+")
	return shelie[math.random(1, #shelie)]
end


--攻心
local sgkgodgongxin_skill= {}
sgkgodgongxin_skill.name = "sgkgodgongxin"
table.insert(sgs.ai_skills, sgkgodgongxin_skill)
sgkgodgongxin_skill.getTurnUseCard = function(self)
    if #self.enemies == 0 then return nil end
	if self.player:hasUsed("#sgkgodgongxinCard") then return nil end
	local sgkgodgongxin_card = sgs.Card_Parse("#sgkgodgongxinCard:.:")
	assert(sgkgodgongxin_card)
	return sgkgodgongxin_card
end

sgs.ai_skill_use_func["#sgkgodgongxinCard"] = function(card, use, self)
    self:sort(self.enemies, "handcard")
	self.enemies = sgs.reverse(self.enemies)
	for _, enemy in ipairs(self.enemies) do
		if not enemy:isKongcheng() and self:objectiveLevel(enemy) > 0
			and (self:hasSuit("heart", false, enemy) or self:getKnownNum(eneny) ~= enemy:getHandcardNum()) then
			use.card = card
			if use.to then
				use.to:append(enemy)
			end
			return
		end
	end
end

sgs.ai_use_value["sgkgodgongxinCard"] = 8.5
sgs.ai_use_priority["sgkgodgongxinCard"] = 9.5
sgs.ai_card_intention["sgkgodgongxinCard"] = 80


--啖睛
sgs.ai_skill_playerchosen["sgkgoddanjing_damage"] = function(self, targets)
    local damage = self.player:getTag("danjing_damage"):toDamage()
	local players = {}
	for _, t in sgs.qlist(targets) do
		if self:isEnemy(t) and self:damageIsEffective(t, damage.nature) then
		    table.insert(players, t)
		end
	end
	if #players > 0 then
		self:sort(players, "threat")
		return players[1]
	end
	return nil
end

sgs.ai_skill_playerchosen["sgkgoddanjing_lose"] = function(self, targets)
    local damage = self.player:getTag("danjing_damage"):toDamage()
	local players = {}
	for _, t in sgs.qlist(targets) do
		if self:isEnemy(t) and self:damageIsEffective(t, damage.nature) then
		    table.insert(players, t)
		end
	end
	if #players > 0 then
		self:sort(players, "threat")
		return players[1]
	end
	return nil
end

sgs.ai_skill_playerchosen["sgkgoddanjing_lose"] = function(self, targets)
	local players = {}
	for _, t in sgs.qlist(targets) do
		if self:isEnemy(t) then
		    table.insert(players, t)
		end
	end
	if #players > 0 then
		self:sort(players, "threat")
		return players[1]
	end
	return nil
end

sgs.ai_skill_playerchosen["sgkgoddanjing_discard"] = function(self, targets)
	local players = {}
	for _, t in sgs.qlist(targets) do
		if self:isEnemy(t) then
		    table.insert(players, t)
		end
	end
	if #players > 0 then
		self:sort(players, "defense")
		players = sgs.reverse(players)
		return players[1]
	end
	return nil
end

sgs.ai_skill_playerchosen["sgkgoddanjing_maxhp"] = function(self, targets)
	local players = {}
	for _, t in sgs.qlist(targets) do
		if self:isEnemy(t) then
		    table.insert(players, t)
		end
	end
	if #players > 0 then
		self:sort(players, "threat")
		return players[1]
	end
	return nil
end


--忠魂
local sgkgodzhonghun_skill = {}
sgkgodzhonghun_skill.name = "sgkgodzhonghun"
table.insert(sgs.ai_skills, sgkgodzhonghun_skill)
sgkgodzhonghun_skill.getTurnUseCard = function(self)
    if #self.friends_noself == 0 then return nil end
	if self.player:getMark("sgkgodzhonghun") > 0 then return nil end
	return sgs.Card_Parse("#sgkgodzhonghunCard:.:")
end

sgs.ai_skill_use_func["#sgkgodzhognhunCard"] = function(card, use, self)
	local target
	for _, friend in ipairs(self.friends_noself) do
		if self.player:getRole() == "loyalist" and friend:isLord() and friend:getMark("&sgkgodzhonghun") == 0 then
			target = friend
			break
		end
	end
	if not target then
		self:sort(self.friends_noself, "chaofeng")
		for _, friend in pairs(self.friends_noself) do
			if friend:getMark("&sgkgodzhonghun") == 0 then
				target = friend
				break
			end
		end
	end
	if target then
		use.card = card
		if use.to then use.to:append(target) end
	end
end

sgs.ai_skill_use["@@sgkgodzhonghun"] = function(self, prompt)
	if #self.friends_noself == 0 then return "." end
	if self.player:getMark("sgkgodzhonghun") > 0 then return "." end
	local target
	for _, friend in ipairs(self.friends_noself) do
		if self.player:getRole() == "loyalist" and friend:isLord() and friend:getMark("&sgkgodzhonghun") == 0 then
			target = friend
			break
		end
	end
	if not target then
		self:sort(self.friends_noself, "chaofeng")
		for _, friend in pairs(self.friends_noself) do
			if friend:getMark("&sgkgodzhonghun") == 0 then
				target = friend
				break
			end
		end
	end
	if target then return "#sgkgodzhonghunCard:.:->" .. target:objectName() else return "." end
end


sgs.ai_use_value["sgkgodzhonghunCard"] = 10
sgs.ai_use_priority["sgkgodzhonghunCard"] = 10
sgs.ai_card_intention["sgkgodzhonghunCard"]  = -100


--龙魂
local sgkgodlonghun_skill = {}
sgkgodlonghun_skill.name = "sgkgodlonghun"
table.insert(sgs.ai_skills, sgkgodlonghun_skill)
sgkgodlonghun_skill.getTurnUseCard = function(self)
    if self.player:getHp()>1 then return end
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByUseValue(cards,true)
	for _, card in ipairs(cards) do
		if card:getSuit() == sgs.Card_Diamond and self:slashIsAvailable() then
			return sgs.Card_Parse(("fire_slash:sgkgodlonghun[%s:%s]=%d"):format(card:getSuitString(), card:getNumberString(), card:getId()))
		end
	end
end

sgs.ai_view_as["sgkgodlonghun"] = function(card, player, card_place)
    local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if player:getHp() > 1 or card_place == sgs.Player_PlaceSpecial then return end
	if card:getSuit() == sgs.Card_Diamond then
		return ("fire_slash:sgkgodlonghun[%s:%s]=%d"):format(suit, number, card_id)
	elseif card:getSuit() == sgs.Card_Club then
		return ("jink:sgkgodlonghun[%s:%s]=%d"):format(suit, number, card_id)
	elseif card:getSuit() == sgs.Card_Heart and player:getMark("Global_PreventPeach") == 0 then
		return ("peach:sgkgodlonghun[%s:%s]=%d"):format(suit, number, card_id)
	elseif card:getSuit() == sgs.Card_Spade then
		return ("nullification:sgkgodlonghun[%s:%s]=%d"):format(suit, number, card_id)
	end
end

sgs.sgkgodlonghun_suit_value = {
    heart = 6.7,
	spade = 5,
	club = 4.2,
	diamond = 3.9,
}

function sgs.ai_cardneed.sgkgodlonghun(to, card, self)
	if to:getCardCount() > 3 then return false end
	if to:isNude() then return true end
	return card:getSuit() == sgs.Card_Heart or card:getSuit() == sgs.Card_Spade
end


--七星
sgs.ai_skill_use["@@sgkgodqixing"] = function(self, prompt)
	local pile = self.player:getPile("xing")
	local piles = {}
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	local max_num = math.max(pile:length(), #cards)
	if pile:isEmpty() or (#cards == 0) then
		return "."
	end
	for _, card_id in sgs.qlist(pile) do
		table.insert(piles, sgs.Sanguosha:getCard(card_id))
	end
	local exchange_to_pile = {}
	local exchange_to_handcard = {}
	self:sortByCardNeed(cards)
	self:sortByCardNeed(piles)
	for i = 1 , max_num, 1 do
		if self:cardNeed(piles[#piles]) > self:cardNeed(cards[1]) then
			table.insert(exchange_to_handcard, piles[#piles])
			table.insert(exchange_to_pile, cards[1])
			table.removeOne(piles, piles[#piles])
			table.removeOne(cards, cards[1])
		else
			break
		end
	end
	if #exchange_to_handcard == 0 then return "." end
	local exchange = {}
	for _, id in sgs.qlist(pile) do
		table.insert(exchange, id)
	end
	
	for _, c in ipairs(exchange_to_handcard) do
		table.removeOne(exchange, c:getId())
	end
	
	for _, c in ipairs(exchange_to_pile) do
		table.insert(exchange, c:getId())
	end
	
	return "#sgkgodqixingCard:" .. table.concat(exchange, "+") .. ":"
end


--狂风
sgs.ai_skill_use["@@sgkgodkuangfeng"] = function(self,prompt)
	if #self.enemies == 0 then return "." end
	local friendly_fire
	for _, friend in ipairs(self.friends_noself) do
		if friend:getMark("&gale") == 0 and self:damageIsEffective(friend, sgs.DamageStruct_Fire) and friend:faceUp() and not self:willSkipPlayPhase(friend)
			and (friend:hasSkill("huoji") or friend:hasWeapon("fan") or (friend:hasSkill("yeyan") and friend:getMark("@flame") > 0)) then
			friendly_fire = true
			break
		end
	end
	local is_chained = 0
	local target = {}
	for _, enemy in ipairs(self.enemies) do
		if enemy:getMark("&gale") == 0 and self:damageIsEffective(enemy, sgs.DamageStruct_Fire) then
			if enemy:isChained() then
				is_chained = is_chained + 1
				table.insert(target, enemy)
			elseif enemy:hasArmorEffect("vine") then
				table.insert(target, 1, enemy)
				break
			end
		end
		if self:isWeak(enemy) or self:damageIsEffective(enemy) then table.insert(target, enemy) end
	end
	local usecard = false
	if (friendly_fire and is_chained > 1) or #target > 0 then usecard = true end
	self:sort(self.friends, "hp")
	self:sort(self.enemies, "defense")
	if usecard then
		if not target[1] then table.insert(target, self.enemies[1]) end
		if target[1] then return "#sgkgodkuangfengCard:" .. self.player:getPile("xing"):first() .. ":->" .. target[1]:objectName() else return "." end
	else
		return "."
	end
end


sgs.ai_card_intention["#sgkgodkuangfengCard"] = 120


--大雾
sgs.ai_skill_use["@@sgkgoddawu"] = function(self, prompt)
	if #self.friends == 0 then return "." end
	self:sort(self.friends_noself, "hp")
	local targets = {}
	local lord = self.room:getLord()
	self:sort(self.friends_noself, "defense")
	if lord and lord:getMark("&fog") == 0 and self:isFriend(lord) and not sgs.isLordHealthy() and not self.player:isLord() and not lord:hasSkill("buqu")
		and not (lord:hasSkill("hunzi") and lord:getMark("hunzi") == 0 and lord:getHp() > 1) then
			table.insert(targets, lord:objectName())
	else
		for _, friend in ipairs(self.friends_noself) do
			if friend:getMark("&fog") == 0 and self:isWeak(friend) and not friend:hasSkill("buqu")
				and not (friend:hasSkill("hunzi") and friend:getMark("hunzi") == 0 and friend:getHp() > 1) then
					table.insert(targets, friend:objectName())
					break
			end
		end
	end
	if self.player:getPile("xing"):length() > #targets and self:isWeak() then table.insert(targets, self.player:objectName()) end
	if #targets > 0 then
		local s = sgs.QList2Table(self.player:getPile("xing"))
		local length = #targets
		for i = 1, #s - length do
			table.remove(s, #s)
		end
		return "#sgkgoddawuCard:" .. table.concat(s, "+") .. ":" .. "->" .. table.concat(targets, "+")
	end
	return "."
end


sgs.ai_card_intention["#sgkgoddawuCard"] = -100


--无谋
sgs.ai_skill_choice.sgkgodwumou = function(self, choices)
	if self.player:getMark("&fierce") > 6 then
	    if self:isWeak() then return "loseonemark" else return "getdamaged" end
	end
	if self.player:getHp() + self:getCardsNum("Peach") > 3 then return "getdamaged" else return "loseonemark" end
	if self.player:hasSkill("sgkgodyinshi") and not self.player:hasSkill("jueqing") then return "getdamaged" end
end


--无前
local sgkgodwuqian_skill = {}
sgkgodwuqian_skill.name = "sgkgodwuqian"
table.insert(sgs.ai_skills, sgkgodwuqian_skill)
sgkgodwuqian_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#sgkgodwuqianCard") or self.player:getMark("&fierce") < 2 then return nil end
	if self.player:hasUsed("#sgkgodshenfenCard") then return nil end
	return sgs.Card_Parse("#sgkgodwuqianCard:.:")
end

sgs.ai_skill_use_func["#sgkgodwuqianCard"] = function(card, use, self)
	if self.player:getMark("&fierce") >= 8 and #self.enemies > 0 then
	    use.card = card
	end
end


sgs.ai_use_value["sgkgodwuqianCard"] = 6
sgs.ai_use_priority["sgkgodwuqianCard"] = 9
sgs.ai_card_intention["sgkgodwuqianCard"] = 80


--神愤
local sgkgodshenfen_skill = {}
sgkgodshenfen_skill.name = "sgkgodshenfen"
table.insert(sgs.ai_skills, sgkgodshenfen_skill)
sgkgodshenfen_skill.getTurnUseCard = function(self)
	if #self.enemies == 0 then return nil end
	if self.player:hasUsed("#sgkgodshenfenCard") or self.player:getMark("&fierce") < 6 then return nil end
	return sgs.Card_Parse("#sgkgodshenfenCard:.:")
end

function SmartAI:getSaveNum(isFriend)
	local num = 0
	for _, player in sgs.qlist(self.room:getAllPlayers()) do
		if (isFriend and self:isFriend(player)) or (not isFriend and self:isEnemy(player)) then
			if not self.player:hasSkill("wansha") or player:objectName() == self.player:objectName() then
				if player:hasSkill("jijiu") then
					num = num + self:getSuitNum("heart", true, player)
					num = num + self:getSuitNum("diamond", true, player)
					num = num + player:getHandcardNum() * 0.4
				end
				if player:hasSkill("nosjiefan") and getCardsNum("Slash", player, self.player) > 0 then
					if self:isFriend(player) or self:getCardsNum("Jink") == 0 then num = num + getCardsNum("Slash", player, self.player) end
				end
				num = num + getCardsNum("Peach", player, self.player)
			end
			if player:hasSkill("buyi") and not player:isKongcheng() then num = num + 0.3 end
			if player:hasSkill("chunlao") and not player:getPile("wine"):isEmpty() then num = num + player:getPile("wine"):length() end
			if player:hasSkill("jiuzhu") and player:getHp() > 1 and not player:isNude() then
				num = num + 0.9 * math.max(0, math.min(player:getHp() - 1, player:getCardCount()))
			end
			if player:hasSkill("renxin") and player:objectName() ~= self.player:objectName() and not player:isKongcheng() then num = num + 1 end
		end
	end
	return num
end

function SmartAI:canSaveSelf(player)
	if hasBuquEffect(player) then return true end
	if getCardsNum("Analeptic", player, self.player) > 0 then return true end
	if player:hasSkill("jiushi") and player:faceUp() then return true end
	if player:hasSkill("jiuchi") then
		for _, c in sgs.qlist(player:getHandcards()) do
			if c:getSuit() == sgs.Card_Spade then return true end
		end
	end
	return false
end

local function getShenfenUseValueOfHECards(self, to)
	local value = 0
	-- value of handcards
	local value_h = 0
	local hcard = to:getHandcardNum()
	if to:hasSkill("lianying") then
		hcard = hcard - 0.9
	elseif to:hasSkills("shangshi|nosshangshi") then
		hcard = hcard - 0.9 * to:getLostHp()
	else
		local jwfy = self.room:findPlayerBySkillName("shoucheng")
		if jwfy and self:isFriend(jwfy, to) and (not self:isWeak(jwfy) or jwfy:getHp() > 1) then hcard = hcard - 0.9 end
	end
	value_h = (hcard > 4) and 16 / hcard or hcard
	if to:hasSkills("tuntian+zaoxian") then value = value * 0.95 end
	if (to:hasSkill("kongcheng") or (to:hasSkill("zhiji") and to:getHp() > 2 and to:getMark("zhiji") == 0)) and not to:isKongcheng() then value_h = value_h * 0.7 end
	if to:hasSkills("jijiu|qingnang|leiji|nosleiji|jieyin|beige|kanpo|liuli|qiaobian|zhiheng|guidao|longhun|xuanfeng|tianxiang|noslijian|lijian") then value_h = value_h * 0.95 end
	value = value + value_h

	-- value of equips
	local value_e = 0
	local equip_num = to:getEquips():length()
	if to:hasArmorEffect("silver_lion") and to:isWounded() then equip_num = equip_num - 1.1 end
	value_e = equip_num * 1.1
	if to:hasSkills("kofxiaoji|xiaoji") then value_e = value_e * 0.7 end
	if to:hasSkill("nosxuanfeng") then value_e = value_e * 0.85 end
	if to:hasSkills("bazhen|yizhong") and to:getArmor() then value_e = value_e - 1 end
	value = value + value_e

	return value
end

local function getDangerousShenGuanYu(self)
	local most = -100
	local target
	for _, player in sgs.qlist(self.room:getAllPlayers()) do
		local nm_mark = player:getMark("&nightmare")
		if player:objectName() == self.player:objectName() then nm_mark = nm_mark + 1 end
		if nm_mark > 0 and nm_mark > most or (nm_mark == most and self:isEnemy(player)) then
			most = nm_mark
			target = player
		end
	end
	if target and self:isEnemy(target) then return true end
	return false
end

sgs.ai_skill_use_func["#sgkgodshenfenCard"] = function(card, use, self)
	if (self.role == "loyalist" or self.role == "renegade") and self.room:getLord() and self:isWeak(self.room:getLord()) and not self.player:isLord() then return end
	local benefit = 0
	for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if self:isFriend(player) then benefit = benefit - getShenfenUseValueOfHECards(self, player) end
		if self:isFriend(player) then benefit = benefit + getShenfenUseValueOfHECards(self, player) end
	end
	local friend_save_num = self:getSaveNum(true)
	local enemy_save_num = self:getSaveNum(false)
	local others = 0
	for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if self:damageIsEffective(player, sgs.DamageStruct_Normal) then
			others = others + 1
			local value_d = 3.5 / math.max(player:getHp(), 1)
			if player:getHp() <= 1 then
				if player:hasSkill("wuhun") then
					local can_use = getDangerousShenGuanYu(self)
					if not can_use then return else value_d = value_d * 0.1 end
				end
				if self:canSaveSelf(player) then
					value_d = value_d * 0.9
				elseif self:isFriend(player) and friend_save_num > 0 then
					friend_save_num = friend_save_num - 1
					value_d = value_d * 0.9
				elseif self:isEnemy(player) and enemy_save_num > 0 then
					enemy_save_num = enemy_save_num - 1
					value_d = value_d * 0.9
				end
			end
			if player:hasSkill("fankui") then value_d = value_d * 0.8 end
			if player:hasSkill("guixin") then
				if not player:faceUp() then
					value_d = value_d * 0.4
				else
					value_d = value_d * 0.8 * (1.05 - self.room:alivePlayerCount() / 15)
				end
			end
			if self:getDamagedEffects(player, self.player) or getBestHp(player) == player:getHp() - 1 then value_d = value_d * 0.8 end
			if self:isFriend(player) then benefit = benefit - value_d end
			if self:isEnemy(player) then benefit = benefit + value_d end
		end
	end
	if not self.player:faceUp() or self.player:hasSkills("jushou|nosjushou|neojushou|kuiwei") then
		benefit = benefit + 1
	else
		local help_friend = false
		for _, friend in ipairs(self.friends_noself) do
			if self:hasSkills("fangzhu|jilve", friend) then
				help_friend = true
				benefit = benefit + 1
				break
			end
		end
		if not help_friend then benefit = benefit - 0.5 end
	end
	if self.player:getKingdom() == "qun" then
		for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if player:hasLordSkill("baonue") and self:isFriend(player) then
				benefit = benefit + 0.2 * self.room:alivePlayerCount()
				break
			end
		end
	end
	benefit = benefit + (others - 7) * 0.05
	if benefit > 0 then
		use.card = card
	end
end

sgs.ai_use_value["sgkgodshenfenCard"] = 8
sgs.ai_use_priority["sgkgodshenfenCard"] = 5.3

sgs.dynamic_value.damage_card["sgkgodshenfenCard"] = true
sgs.dynamic_value.control_card["sgkgodshenfenCard"] = true


--劫焰
sgs.ai_skill_invoke.sgkgodjieyan = function(self, data)
    local use = data:toCardUse()
	if use.to:length() ~= 1 then return false end
	local to = use.to:at(0)
	if self:isFriend(to) then return false end
	if self.player:isKongcheng() then return false end
	if use.card and use.card:isRed() and (use.card:isKindOf("Slash") or use.card:isNDTrick()) then
	    if self:damageIsEffective(to, sgs.DamageStruct_Fire) and self:objectiveLevel(to) > 3 then return true else return false end
	end
	return false
end

sgs.ai_skill_cardask["@sgkgodjieyan"] = function(self, data, pattern)
    local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	local c
	for _, card in ipairs(cards) do
	    if not card:isKindOf("Peach") then
		    c = card
			break
		end
	end
	if c then
	    return "$"..c:getEffectiveId()
	else
	    return "$"..cards[math.random(1,#cards)]:getEffectiveId()
	end
end


--焚营
sgs.ai_skill_invoke.sgkgodfenying = function(self, data)
    local damage = data:toDamage()
	local distance = 1000
	for _, p in sgs.qlist(self.room:getOtherPlayers(damage.to)) do
		if p:distanceTo(damage.to) < distance then
			distance = p:distanceTo(damage.to)
		end
	end
	local all = {}
	for _, p in sgs.qlist(self.room:getOtherPlayers(damage.to)) do
		if p:distanceTo(damage.to) == distance and self:isEnemy(p) and self:damageIsEffective(to, sgs.DamageStruct_Fire) then
			table.insert(all, p)
		end
	end
	if self:isEnemy(damage.to) then table.insert(all, damage.to) end
	return #all > 0
end

sgs.ai_skill_cardask["@sgkgodfenying"] = function(self, data, pattern)
    local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	local c
	for _, card in ipairs(cards) do
	    if card:isRed() then
		    c = card
			break
		end
	end
	if c then
	    return "$"..c:getEffectiveId()
	else
	    return nil
	end
end

sgs.ai_skill_playerchosen.sgkgodfenying = function(self, targets)
    local fenying = {}
	for _, t in sgs.qlist(targets) do
	    if self:isEnemy(t) and self:damageIsEffective(t, sgs.DamageStruct_Fire) then
		    table.insert(fenying, t)
		end
		if self:isEnemy(t) and t:hasArmorEffect("vine") or (t:getMark("&gale") > 0 and t:getMark("&fog") == 0) or (t:isKongcheng() and t:hasSkill("chouhai")) then
		    table.insert(fenying, 1, t)
		end
	end
	return fenying[1]
end


--天机
sgs.ai_skill_invoke.sgkgodtianji = true


--天启
local sgkgodtianqi_skill = {}
sgkgodtianqi_skill.name = "sgkgodtianqi"
table.insert(sgs.ai_skills, sgkgodtianqi_skill)
sgkgodtianqi_skill.getTurnUseCard = function(self, inclusive)
    if self.player:hasFlag("tianqi_used") then return nil end
    if self.player:hasFlag("Global_Dying") then return nil end
	if not self.player:isAlive() then return nil end
	local tianqiTrickCard_str = {}
	local tianqiBasicCard_str = {}
	local top = self.player:getTag("top_card"):toString()
	if #self.enemies == 0 then
		if top == "TrickCard" then
			return sgs.Card_Parse("#sgkgodtianqi:.:" .. "dongzhuxianji")
		else
			if self:getCardsNum("Peach") > 0 then
				return sgs.Card_Parse("#sgkgodtianqi:.:" .. "dongzhuxianji")
			end
		end
	end
	if self.player:isWounded() and self:getCardsNum("Peach") == 0 then
		if top == "BasicCard" then
			local card = sgs.Card_Parse("#sgkgodtianqi:.:" .. "peach")
			local peach = sgs.Sanguosha:cloneCard("peach")
			local dummyuse = { isDummy = true }
			self:useBasicCard(peach, dummyuse)
			if dummyuse.card then return card end
		end
	end
	local tricks ={"zhujinqiyuan", "amazing_grace", "archery_attack", "savage_assault", "iron_chain", "dongzhuxianji"}
	local names = {}
	if top ~= nil then
		if top == "TrickCard" then
			for _, name in ipairs(tricks) do
				local drawpile = sgs.QList2Table(self.room:getDrawPile())
				if #drawpile > 0 then
					local c = sgs.Sanguosha:getCard(drawpile[1])
					local card = sgs.Sanguosha:cloneCard(name, c:getSuit(), c:getNumber())
					local dummyuse = { isDummy = true }
					self:useTrickCard(card, dummyuse)
					if dummyuse.card then
						table.insert(tianqiTrickCard_str, "#sgkgodtianqi:.:" .. card:objectName())
						if not table.contains(names, name) then table.insert(names, name) end
					end
				end
			end
		end
		if top == "BasicCard" then
			if self.player:isWounded() then
				local peach_str = "#sgkgodtianqi:.:" .. "peach"
				table.insert(tianqiBasicCard_str, peach_str)
				if not table.contains(names, "peach") then table.insert(names, "peach") end
			end
		end
	end
	local function filter_tianqi(objectName)
		local fakeCard
		local tianqi = "peach|dongzhuxianji|zhujinqiyuan|amazing_grace|archery_attack|savage_assault"
		local ban = table.concat(sgs.Sanguosha:getBanPackages(), "|")
		if not ban:match("maneuvering") then tianqi = tianqi .. "|fire_attack" end
		local tianqis = tianqi:split("|")
		for i = 1, #tianqis do
			local forbidden = tianqis[i]
			local forbid = sgs.Sanguosha:cloneCard(forbidden)
			if self.player:isLocked(forbid) then
				table.remove(tianqis, i)
				i = i - 1
			end
		end
		for i=1, 20 do
			local newtianqi = objectName or tianqis[math.random(1, #tianqis)]
			local tianqicard = sgs.Sanguosha:cloneCard(newtianqi)
			if tianqicard:isKindOf(top) or top == nil or (not tianqicard:isKindOf(top) and (not self:isWeak()) and math.random(1, 4) == 1) then
				local dummyuse = {isDummy = true}
				if newtianqi == "peach" then self:useBasicCard(tianqicard, dummyuse) else self:useTrickCard(tianqicard, dummyuse) end
				if dummyuse.card then
					fakeCard = sgs.Card_Parse("#sgkgodtianqi:.:" .. newtianqi)
					break
				end
			end
		end
		return fakeCard
	end
	if #tianqiTrickCard_str > 0 and not self:isWeak() then
		local tianqi_trickstr = tianqiTrickCard_str[math.random(1, #tianqiTrickCard_str)]
		if top and top == "TrickCard" then
			if #self.enemies == 0 then
				local fake_exnihilo = filter_tianqi("dongzhuxianji")
				if fake_exnihilo then return fake_exnihilo end
			end
			return sgs.Card_Parse(tianqi_trickstr)
		end
	else
		if #tianqiBasicCard_str > 0 then
			if top == "BasicCard" and self.player:isWounded() then
				local card = sgs.Card_Parse("#sgkgodtianqi:.:" .. "peach")
				local peach = sgs.Sanguosha:cloneCard("peach")
				local dummyuse = { isDummy = true }
				self:useBasicCard(peach, dummyuse)
				if dummyuse.card then return card end
			end
		end
	end
	if top == nil and self.player:isWounded() then
		local card = sgs.Card_Parse("#sgkgodtianqi:.:" .. "peach")
		local peach = sgs.Sanguosha:cloneCard("peach")
		local dummyuse = { isDummy = true }
		self:useBasicCard(peach, dummyuse)
		if dummyuse.card then return card end
	end
	local can_slash = (top and top == "BasicCard" and self:getCardsNum("Slash") == 0) or
		(not top and self.player:getHp() >= 2 and self:getCardsNum("Slash") == 0 and math.random(1, 300) <= 108)
	if can_slash and self:slashIsAvailable() then
		local card = sgs.Card_Parse("#sgkgodtianqi:.:" .. "slash")
		local slash = sgs.Sanguosha:cloneCard("slash")
		local dummyuse = { isDummy = true }
		self:useBasicCard(slash, dummyuse)
		if dummyuse.card then return card end
	end
end

sgs.ai_skill_use_func["#sgkgodtianqi"] = function(card, use, self)
    if self.player:hasFlag("tianqi_used") then return nil end
	if self.player:hasFlag("Global_Dying") then return nil end
	if self.player:getMark("Global_Dying") > 0 then return nil end
	local userstring=card:toString()
	userstring=(userstring:split(":.:"))[2]
	local tianqicard=sgs.Sanguosha:cloneCard(userstring)
	tianqicard:setSkillName("sgkgodtianqi")
	if tianqicard:getTypeId() == sgs.Card_TypeBasic then
		if not use.isDummy and use.card and tianqicard:isKindOf("Slash") and ((not use.to) or (use.to:isEmpty())) then return end
		self:useBasicCard(tianqicard, use)
	else
		assert(tianqicard)
		self:useTrickCard(tianqicard, use)
	end
	if not use.card then return end
	use.card=card
end

function sgs.ai_cardsview_valuable.sgkgodtianqi(self, class_name, player)
	if player:hasFlag("Global_Dying") then return end
	if player:hasFlag("tianqi_used") then return end
	if player:getMark("Global_Dying") > 0 then return nil end
	if not player:isAlive() then return end
	local top = player:getTag("top_card"):toString()
	if class_name == "Slash" and top == "BasicCard" and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
		return "#sgkgodtianqi:.:slash"
	elseif (class_name == "Peach" and player:getMark("Global_PreventPeach") == 0) or class_name == "Analeptic" and top == "BasicCard" then
		local dying = self.room:getCurrentDyingPlayer()
		if dying and dying:objectName() ~= player:objectName() and player:getMark("Global_PreventPeach") == 0 then
			return "#sgkgodtianqi:.:peach"
		else
			local user_string
			if class_name == "Analeptic" then user_string = "analeptic" else user_string = "peach" end
			return "#sgkgodtianqi:.:" .. user_string
		end
	end
	if math.random(1, 3) <= 1 and self:getCardsNum(class_name) == 0 then return "#sgkgodtianqi:.:" .. class_name end
end

sgs.ai_use_priority["sgkgodtianqi"] = sgs.ai_use_priority.ExNihilo - 0.1


--天机
sgs.ai_skill_choice["sgkgodtianji"] = function(self, choices, data)
    local tianji = choices:split("+")
	local ids = self.room:getNCards(1, true)
	local card = sgs.Sanguosha:getCard(ids:first())
	local canget = self.player:getTag("tianji_canget"):toBool()
	if not self:needKongcheng(self.player) then return "tianji_obtain" end
	if card:isKindOf("Peach") or card:isKindOf("ExNihilo") or card:isKindOf("Jink") or card:isKindOf("Slash") or card:isKindOf("Nullification") then
	    if canget then return "tianji_obtain" else return "tianji_exchange" end
	end
	if card:isKindOf("Analeptic") then
	    if self:isWeak() then
		    if canget then return "tianji_obtain" else return "tianji_exchange" end
		else
		    if canget then return tianji[math.random(1, 2)] else return "tianji_obtain" end
		end
	end
	if canget then return tianji[math.random(1, 2)] end
	return tianji[math.random(1, #tianji)]
end

sgs.ai_skill_cardask["@tianji_exchange"] = function(self, data, pattern)
    local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByKeepValue(cards)
	if self.room:getCurrent():getSeat() == self.player:getSeat() then
		if self:getCardsNum("Peach") == 0 and self.player:isWounded() then
			local card
			for _, c in ipairs(cards) do
				if c:isKindOf("BasicCard") then
					card = c
					break
				end
			end
			return "$" .. card:getEffectiveId()
		end
		if #self.enemies == 0 then
			local card
			for _, c in ipairs(cards) do
				if c:isKindOf("TrickCard") and not c:isKindOf("ExNihilo") then
					card = c
					break
				end
			end
			return "$" .. card:getEffectiveId()
		end
	end
	return "$"..cards[1]:getEffectiveId()
end


--琴音
sgs.ai_skill_invoke.sgkgodqinyin = function(self, data)
    self:sort(self.friends, "hp")
	self:sort(self.enemies, "hp")
	local up = 0
	local down = 0
	for _, friend in ipairs(self.friends) do
		down = down - 10
		up = up + (friend:isWounded() and 10 or 0)
		if self:hasSkills(sgs.masochism_skill, friend) then
			down = down - 5
			if friend:isWounded() then up = up + 5 end
		end
		if self:needToLoseHp(friend, nil, nil, true) then down = down + 5 end
		if self:needToLoseHp(friend, nil, nil, true, true) and friend:isWounded() then up = up - 5 end
		if self:isWeak(friend) then
			if friend:isWounded() then up = up + 10 + (friend:isLord() and 20 or 0) end
			down = down - 10 - (friend:isLord() and 40 or 0)
			if friend:getHp() <= 1 and not friend:hasSkill("buqu") or friend:getPile("buqu"):length() > 4 then
				down = down - 20 - (friend:isLord() and 40 or 0)
			end
		end
	end
	for _, enemy in ipairs(self.enemies) do
		down = down + 10
		up = up - (enemy:isWounded() and 10 or 0)
		if self:hasSkills(sgs.masochism_skill, enemy) then
			down = down + 10
			if enemy:isWounded() then up = up - 10 end
		end
		if self:needToLoseHp(enemy, nil, nil, true) then down = down - 5 end
		if self:needToLoseHp(enemy, nil, nil, true, true) and enemy:isWounded() then up = up - 5 end

		if self:isWeak(enemy) then
			if enemy:isWounded() then up = up - 10 end
			down = down + 10
			if enemy:getHp() <= 1 and not enemy:hasSkill("buqu") then
				down = down + 10 + ((enemy:isLord() and #self.enemies > 1) and 20 or 0)
			end
		end
	end
	if self:isWeak() and self.player:getCards("he"):length() >= 2 then
	    sgs.ai_skill_choice.sgkgodqinyin = "qinyin_allrecover"
		return true
	end
	if down > 0 then
		sgs.ai_skill_choice.sgkgodqinyin = "qinyin_alllose"
		return true
	elseif up > 0 then
		sgs.ai_skill_choice.sgkgodqinyin = "qinyin_allrecover"
		return true
	else
	    if not self:isWeak() then
	        sgs.ai_skill_choice.sgkgodqinyin = "qinyin_alllose" --报复社会
		    return true
		end
	end
	return false
end


--业炎
local sgkgodyeyan_skill = {}
sgkgodyeyan_skill.name = "sgkgodyeyan"
table.insert(sgs.ai_skills, sgkgodyeyan_skill)
sgkgodyeyan_skill.getTurnUseCard = function(self, inclusive)
    if self.player:isKongcheng() then return nil end
	if self.player:getMark("@sk_fire") <= 0 then return nil end
	local suits = {}
	for _, card in sgs.qlist(self.player:getCards("h")) do
	    if card:getSuit() == sgs.Card_Spade then
		    table.insert(suits, card:getSuitString())
			break
		end
	end
	for _, card in sgs.qlist(self.player:getCards("h")) do
	    if card:getSuit() == sgs.Card_Heart then
		    table.insert(suits, card:getSuitString())
			break
		end
	end
	for _, card in sgs.qlist(self.player:getCards("h")) do
	    if card:getSuit() == sgs.Card_Club then
		    table.insert(suits, card:getSuitString())
			break
		end
	end
	for _, card in sgs.qlist(self.player:getCards("h")) do
	    if card:getSuit() == sgs.Card_Diamond then
		    table.insert(suits, card:getSuitString())
			break
		end
	end
	if #suits >= 1 then
	    return sgs.Card_Parse("#sgkgodyeyanCard:.:")
	end
end

sgs.ai_skill_use_func["#sgkgodyeyanCard"] = function(card, use, self)
    local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards, false, true)
	local need_cards = {}
	local spade, club, heart, diamond
	for _, card in ipairs(cards) do
	    if card:getSuit() == sgs.Card_Spade then
		    if not spade then
			    spade = true
				table.insert(need_cards, card:getId())
			end
		elseif card:getSuit() == sgs.Card_Heart then
		    if not heart then
			    heart = true
				table.insert(need_cards, card:getId())
			end
		elseif card:getSuit() == sgs.Card_Club then
		    if not club then
			    club = true
				table.insert(need_cards, card:getId())
			end
		elseif card:getSuit() == sgs.Card_Diamond then
		    if not diamond then
			    diamond = true
				table.insert(need_cards, card:getId())
			end
		end
	end
	if #need_cards == 0 then return end
	local can_yeyan = {}
	local to_use = false
	for _, enemy in ipairs(self.enemies) do
	    if #need_cards >= 2 and not enemy:hasArmorEffect("silver_lion") and self:objectiveLevel(enemy) > 3 and self:damageIsEffective(enemy, sgs.DamageStruct_Fire)
        and not (enemy:hasSkill("tianxiang") and enemy:getHandcardNum() > 0) then
		    if enemy:isChained() and self:isGoodChainTarget(enemy, nil, nil, #need_cards) then
                if enemy:hasArmorEffect("vine") or enemy:getMark("&gale") > 0 then
			        table.insert(can_yeyan, enemy)
				end
			elseif enemy:getHp() <= #need_cards then
				table.insert(can_yeyan, enemy)
			else
				if enemy then table.insert(can_yeyan, enemy) end
			end
		end
		if #need_cards == 1 then
		    if self:damageIsEffective(enemy, sgs.DamageStruct_Fire) and not enemy:hasSkill("tianxiang") and self:objectiveLevel(enemy) > 3 then
			    if enemy:getHp() <= 1 then table.insert(can_yeyan, enemy) end
				if self:isWeak(enemy) then table.insert(can_yeyan, enemy) end
			end
		end
	end
	if #can_yeyan > 0 then to_use = true end
	self:sort(can_yeyan, "hp")
	if to_use then
	    use.card = sgs.Card_Parse("#sgkgodyeyanCard:" .. table.concat(need_cards, "+") .. ":")
		if use.to then
		    for _, enemy in ipairs(can_yeyan) do
			    use.to:append(enemy)
				if use.to:length() == 2 then break end
			end
			assert(use.to:length() > 0)
		end
	end
end


sgs.ai_use_value["sgkgodyeyanCard"] = 8
sgs.ai_use_priority["sgkgodyeyanCard"] = sgs.ai_use_priority.ExNihilo - 0.3
sgs.ai_card_intention["sgkgodyeyanCard"] = 300


--贤助
sgs.ai_skill_invoke.sgkgodxianzhu = function(self, data)
	local player = data:toPlayer()
	return self:isFriend(player)
end


--良缘
local sgkgodliangyuan_skill = {}
sgkgodliangyuan_skill.name = "sgkgodliangyuan"
table.insert(sgs.ai_skills, sgkgodliangyuan_skill)
sgkgodliangyuan_skill.getTurnUseCard = function(self, inclusive)
    if self.player:hasUsed("#sgkgodliangyuan") then return nil end
	if self.player:getMark("@liangyuan") == 0 then return nil end
	if #self.friends_noself == 0 then return nil end
	local a = 0
	for _, p in ipairs(self.friends_noself) do
	    if p:isMale() then a = a+1 end
	end
	if a <= 0 then return nil end
	return sgs.Card_Parse("#sgkgodliangyuan:.:")
end

sgs.ai_skill_use_func["#sgkgodliangyuan"] = function(card, use, self)
    local liangyuan_male
	--优先确保男性主公
	local lord = self.room:getLord()
	if self.player:isFemale() and lord:isMale() and self.player:getRole() == "loyalist" then liangyuan_male = lord end
	if not liangyuan_male then
		self:sort(self.friends_noself, "chaofeng")
		for _, target in ipairs(self.friends_noself) do
			if not target:hasSkill("dawu") and target:hasSkills("yongsi|zhiheng|sgkgodjilue|sk_diezhang|sk_yaoming" .. sgs.priority_skill .. "|shensu")
				and (not self:willSkipPlayPhase(target) or target:hasSkill("shensu")) and target:isMale() then
				liangyuan_male = target
				break
			end
		end
	end
	if not liangyuan_male then
		self:sort(self.friends_noself, "chaofeng")
		for _, target in ipairs(self.friends_noself) do
			liangyuan_male = target
			break
		end
	end
	if liangyuan_male then
	    use.card = card
		if use.to then use.to:append(liangyuan_male) end
	end
end

sgs.ai_use_value["sgkgodliangyuan"] = 10
sgs.ai_use_priority["sgkgodliangyuan"] = 10
sgs.ai_card_intention["sgkgodliangyuan"]  = -100


--望月
sgs.ai_skill_playerchosen["sgkgodwangyue_draw"] = function(self, targets)
	targets = sgs.QList2Table(targets)
	self:sort(targets, "defense")
	local x = self.player:getTag("wangyue_value"):toInt()
	if x >= 2 then
		local target
		for _, pe in ipairs(targets) do
			if self:isWeak(target) and self:isFriend(target) then
				target = pe
				break
			end
		end
		if not target then
			if self:isWeak() then target = self.player end
		end
		return target
	end
	return self.player
end

sgs.ai_skill_playerchosen["sgkgodwangyue_rec"] = function(self, targets)
	targets = sgs.QList2Table(targets)
	self:sort(targets, "hp")
	local target
	for _, pe in ipairs(targets) do
		if self:isFriend(pe) and pe:isWounded() and self:isWeak(pe) then
			target = pe
			break
		end
	end
	if not target then
		--特例：即将觉醒的孙策
		for _, pe in ipairs(targets) do
			if pe:hasSkill("hunzi") and pe:getHp() <= 1 and pe:getMark("@waked") == 0 and (not self:isWeak()) then
				target = pe
				break
			end
		end
	end
	return target
end

sgs.ai_skill_playerchosen["sgkgodwangyue_maxhp"] = function(self, targets)
	targets = sgs.QList2Table(targets)
	self:sort(targets)
	local target
	--优先选择技能与体力上限有关的友方角色
	for _, pe in ipairs(targets) do
		if self:isFriend(pe) and pe:hasSkills("f_pinghe|sgkgodyinyang|quedi|zaiqi|fangzhu|jilve|yinghun|shangshi|weizhong|yizheng|poxi|hunzi|jintairan|yingzi|miji|sgkgodxingyun") then
			target = pe
			break
		end
	end
	--其次选择友方不多于3体力上限的脆皮角色
	if not target then
		for _, pe in ipairs(targets) do
			if self:isFriend(pe) and pe:getMaxHp() <= 3 then
				target = pe
				break
			end
		end
	end
	--再其次选择友方状态良好但需要扩容的角色
	if not target then
		for _, pe in ipairs(targets) do
			if self:isFriend(pe) and pe:getLostHp() <= 2 then
				target = pe
				break
			end
		end
	end
	--最后，无脑选大乔自己，给自己蓄爆
	if not target then
		target = self.player
	end
	return target
end


--落雁
function isDangerousCaopi(enemy)
	return (enemy:hasSkills("fangzhu|jilve|sy_renji")) and enemy:getMaxHp() <= 4
end

function canUseMoreCards(target)
	return target:hasSkills("fenyin|sgkgodjilue|tyyizhao|jieyingg|dl_quandao|jizhi|nosjizhi|sr_qicai|tenyearzhiheng|zhiheng|f_lingce|pianchong|f_huishi|sgkgodguixin")
end

sgs.ai_skill_invoke.sgkgodluoyan = function(self, data)
	if #self.enemies == 0 then return false end
	if #self.enemies == 1 and self.room:getAlivePlayers():length() > 2 and isDangerousCaopi(self.enemies[1]) then return false end
	return true
end

sgs.ai_skill_playerchosen.sgkgodluoyan = function(self, targets)
	targets = sgs.QList2Table(targets)
	local target
	--优先选1体力上限神将
	for _, pe in ipairs(targets) do
		if self:isEnemy(pe) and pe:getMaxHp() <= 2 then
			target = pe
			break
		end
	end
	--次选2体力上限但有减1体力上限觉醒技的神将
	if not target then
		for _, pe in ipairs(targets) do
			if self:isEnemy(pe) and pe:getMaxHp() <= 2 and pe:hasSkills("zaoxian|zili|hunzi|zhiji|yizheng") then
				target = pe
				break
			end
		end
	end
	--再考虑有大过牌技能的敌人
	if not target then 
		for _, pe in ipairs(targets) do
			if self:isEnemy(pe) and (not pe:containsTrick("indulgence")) and pe:getHandcardNum() >= 2 and (not isDangerousCaopi(pe)) then
				if canUseMoreCards(pe) then 
					target = pe
					break
				end
			end
		end
	end
	--最后考虑一般情况下的敌人
	if not target then
		self:sort(targets, "defense")
		for _, pe in ipairs(targets) do
			if self:isEnemy(pe) and (not pe:containsTrick("indulgence")) and pe:getHandcardNum() >= 2 then
				target = pe
				break
			end
		end
	end
	return target
end


local sgkgodliegong_skill = {}
sgkgodliegong_skill.name = "sgkgodliegong"
table.insert(sgs.ai_skills, sgkgodliegong_skill)
sgkgodliegong_skill.getTurnUseCard = function(self, inclusive)
	local x = 1
	if self.player:isWounded() then x = 2 end
	if self.player:getMark("lg_fire_time") >= x then return end
	if #self.enemies == 0 then return end
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByUseValue(cards, true)
	local need_ids = {}
	for _, c in ipairs(cards) do
		if c:getSuit() == sgs.Card_Spade and not c:isKindOf("Analeptic") then
			table.insert(need_ids, c:getEffectiveId())
			break
		end
	end
	for _, c in ipairs(cards) do
		if c:getSuit() == sgs.Card_Heart and not c:isKindOf("ExNihilo") then
			table.insert(need_ids, c:getEffectiveId())
			break
		end
	end
	for _, c in ipairs(cards) do
		if c:getSuit() == sgs.Card_Club then
			table.insert(need_ids, c:getEffectiveId())
			break
		end
	end
	for _, c in ipairs(cards) do
		if c:getSuit() == sgs.Card_Diamond and not c:isKindOf("Analeptic") then
			table.insert(need_ids, c:getEffectiveId())
			break
		end
	end
	if #need_ids > 0 then
		if #need_ids == 1 then
			local c = sgs.Sanguosha:getCard(need_ids[1])
			return sgs.Card_Parse(("fire_slash:sgkgodliegong[%s:%s]=%d"):format(c:getSuitString(), c:getNumberString(), c:getEffectiveId()))
		end
		if #need_ids == 2 then return sgs.Card_Parse(("fire_slash:sgkgodliegong[%s:%s]=%d+%d"):format("to_be_decided", 0, need_ids[1], need_ids[2])) end
		if #need_ids == 3 then return sgs.Card_Parse(("fire_slash:sgkgodliegong[%s:%s]=%d+%d+%d"):format("to_be_decided", 0, need_ids[1], need_ids[2], need_ids[3])) end
		if #need_ids == 4 then return sgs.Card_Parse(("fire_slash:sgkgodliegong[%s:%s]=%d+%d+%d+%d"):format("to_be_decided", 0, need_ids[1], need_ids[2], need_ids[3], need_ids[4])) end
	end
end

sgs.ai_view_as["sgkgodliegong"] = function(card, player, card_place, class_name)
	local cards = sgs.QList2Table(player:getCards("h"))
	local x = 1
	if player:isWounded() then x = 2 end
	if player:getMark("lg_fire_time") >= x then return end
	local need_ids = {}
	for _, c in ipairs(cards) do
		if c:getSuit() == sgs.Card_Spade and not c:isKindOf("Analeptic") then
			table.insert(need_ids, c:getEffectiveId())
			break
		end
	end
	for _, c in ipairs(cards) do
		if c:getSuit() == sgs.Card_Heart and not c:isKindOf("ExNihilo") then
			table.insert(need_ids, c:getEffectiveId())
			break
		end
	end
	for _, c in ipairs(cards) do
		if c:getSuit() == sgs.Card_Club then
			table.insert(need_ids, c:getEffectiveId())
			break
		end
	end
	for _, c in ipairs(cards) do
		if c:getSuit() == sgs.Card_Diamond and not c:isKindOf("Analeptic") then
			table.insert(need_ids, c:getEffectiveId())
			break
		end
	end
	if #need_ids >= 2 then
		if #need_ids == 2 then
			return ("fire_slash:sgkgodliegong[%s:%s]=%d+%d"):format("to_be_decided", 0, need_ids[1], need_ids[2])
		elseif #need_ids == 3 then
			return ("fire_slash:sgkgodliegong[%s:%s]=%d+%d+%d"):format("to_be_decided", 0, need_ids[1], need_ids[2], need_ids[3])
		elseif #need_ids == 4 then
			return ("fire_slash:sgkgodliegong[%s:%s]=%d+%d+%d+%d"):format("to_be_decided", 0, need_ids[1], need_ids[2], need_ids[3], need_ids[4])
		end
	else
		local suit = card:getSuitString()
		local number = card:getNumberString()
		local card_id = card:getEffectiveId()
		return ("fire_slash:sgkgodliegong[%s:%s]=%d"):format(suit, number, card_id)
	end
end