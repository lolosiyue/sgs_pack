--善身

sgs.ai_skill_invoke.nyshanshen = function(self, data)
    local target = nil
    for _,p in sgs.qlist(self.room:getAlivePlayers()) do
        if p:hasFlag("nyshanshentarget") then
            target = p
            break
        end
    end
    if self:isFriend(target) then return true end
    return false
end

--隅泣

local nyyuqi_skill = {}
nyyuqi_skill.name = "nyyuqi"
table.insert(sgs.ai_skills, nyyuqi_skill)
nyyuqi_skill.getTurnUseCard = function(self, inclusive)
    if self.player:getMark("nyyuqicant-PlayClear") > 0 then return end
    if self.player:getMark("nyyuqi-PlayClear") >= self.player:getMaxHp() then return end
	return sgs.Card_Parse("#nyyuqi:.:")
end

sgs.ai_skill_use_func["#nyyuqi"] = function(card, use, self)
    use.card = card
end

sgs.ai_skill_use["@@nyyuqi"] = function(self, prompt)
    local card_ids = self.player:getTag("nyyuqiuse"):toIntList()
    local canuse = {}
    for _,id in sgs.qlist(card_ids) do
        local card = sgs.Sanguosha:getCard(id)
        if card:isAvailable(self.player) then
            table.insert(canuse, card)
        end
    end
    if #canuse == 0 then return "." end
    self:sortByCardNeed(canuse, true, true)
    for _,card in ipairs(canuse) do
        local use = self:aiUseCard(card)
        if use.card then
            if use.to and use.to:length() > 0 then
                local tos = {}
                for _,p in sgs.qlist(use.to) do
                    table.insert(tos, p:objectName())
                end
                return card:toString().."->"..table.concat(tos,"+")
            end
        end
    end
    return "."
end

--娴静

sgs.ai_skill_invoke.nyxianjing = true

--妙剑

local nymiaojian_skill = {}
nymiaojian_skill.name = "nymiaojian"
table.insert(sgs.ai_skills, nymiaojian_skill)
nymiaojian_skill.getTurnUseCard = function(self, inclusive)
    if self.player:hasUsed("#nymiaojian") then return end
	return sgs.Card_Parse("#nymiaojian:.:")
end

sgs.ai_skill_use_func["#nymiaojian"] = function(card, use, self)
	self:sort(self.enemies, "defense")
	local targets = {}
    local qtargets = sgs.PlayerList()
    local players = sgs.SPlayerList()
	local usecard = sgs.Sanguosha:cloneCard("_stabs_slash", sgs.Card_SuitToBeDecided, -1)
    usecard:setSkillName("nymiaojian")
	for _, enemy in ipairs(self.enemies) do
		local player = self.player
		if usecard:targetFilter(qtargets, enemy, player) and (not player:isProhibited(enemy, usecard, qtargets)) 
        and (not enemy:hasArmorEffect("vine")) then
			table.insert(targets, enemy:objectName())
            qtargets:append(enemy)
            players:append(enemy)
		end
	end
	usecard:deleteLater()
	if #targets > 0 then
		local card_str = string.format("#nymiaojian:.:->%s", table.concat(targets, "+"))
		local acard = sgs.Card_Parse(card_str)
		assert(acard)
		use.card = acard
		if use.to then
			use.to = players
		end
	end
end

sgs.ai_use_priority.nymiaojian = sgs.ai_use_priority.Slash-0.1

--莲华

sgs.ai_skill_invoke.nylianhua = function(self, data)
    local n = 1- self.player:getHp()
    local peachs = self:getCardsNum("Analeptic") + self:getCardsNum("Peach")
    if n > peachs then return true end
    return false
end

--国色

sgs.ai_card_intention.nyguose = function(self, card, from, tos)
    for _,to in ipairs(tos) do
        if to:getJudgingArea():length() == 0 then
		    sgs.updateIntention(from, to, 20)
        end
	end
end

local nyguose_skill = {}
nyguose_skill.name = "nyguose"
table.insert(sgs.ai_skills, nyguose_skill)
nyguose_skill.getTurnUseCard = function(self, inclusive)
    if not self.player:canPindian() then return end
    if self.player:getHandcardNum() < 2 then return end
    if self.player:getHandcardNum() <= self.player:getMaxCards() - 1 then return end
	return sgs.Card_Parse("#nyguose:.:")
end

sgs.ai_skill_use_func["#nyguose"] = function(card, use, self)
    local target = nil
	for _,friend in ipairs(self.friends) do
        if friend:getJudgingArea():length() > 0 and self.player:objectName() ~= friend:objectName() and (not self.player:isPindianProhibited(friend)) and friend:getHandcardNum() > 0 
        and (friend:getMark("nyguosefrom"..self.player:objectName().."-PlayClear") == 0) then
            local min = 14
            for _,mcard in sgs.qlist(friend:getHandcards()) do
                if mcard:getNumber() < min then min = mcard:getNumber() end
            end
            if self:getMaxCard():getNumber() > min then target = friend end
        end
        if target then break end
    end

    if not target then
        self:sort(self.enemies, "handcard")
	    self.enemies = sgs.reverse(self.enemies)
	    for _,p in ipairs(self.enemies) do
		    if p:hasJudgeArea() and (not p:containsTrick("indulgence")) and (not self.player:isPindianProhibited(p)) and p:getHandcardNum() > 0 
            and p:getMark("nyguosefrom"..self.player:objectName().."-PlayClear") == 0 then
                target = p
                break
            end
            if target then break end
	    end
    end
    if not target then return end
    if target then
		local card_str = "#nyguose:.:->"..target:objectName()
		local acard = sgs.Card_Parse(card_str)
		assert(acard)
		use.card = acard
		if use.to then
			use.to:append(target)
		end
	end
end

sgs.ai_skill_pindian.nyguose = function(minusecard, self, requestor)
    local maxcard = self:getMaxCard()
    if self:isFriend(requestor) then 
        return self:getMinCard() 
    else
        if maxcard:getNumber() < 6 then
            return minusecard or self:getMaxCard()
        else
            return self:getMaxCard()
        end
    end
end

sgs.ai_skill_choice["nyguose"] = function(self, choices, data)
    local target = nil
    choices = choices:split("+")
    if #choices == 1 then return choices[1] end
    for _,p in sgs.qlist(self.room:getAlivePlayers()) do
        if p:hasFlag("nyguosetarget") then
            target = p
            break
        end
    end
    if target and self:isFriend(target) then
        for _,choice in ipairs(choices) do
            if string.find(choice, "get") then
                return choice
            end
        end
    elseif target and self:isEnemy(target) then
        for _,choice in ipairs(choices) do
            if string.find(choice, "give") then
                return choice
            end
        end
    end
    return choices[math.random(1, #choices)]
end

sgs.ai_use_priority.nyguose = sgs.ai_use_priority.Slash - 0.1

--流离

sgs.ai_skill_invoke.nyliuli = true

sgs.ai_skill_choice["nyliuli"] = function(self, choices, data)
    local target = nil
    for _,p in sgs.qlist(self.room:getAlivePlayers()) do
        if p:hasFlag("nyliulitarget") then
            target = p
            break
        end
    end
    if not self:isFriend(target) then return "cancel" end
    local will = false
    choices = choices:split("+")
    if self.player:getHp() > target:getHp() then will = true end
    if self.player:getHp() < target:getHp() and target:isWounded() and self.player:getHandcardNum() >= target:getHandcardNum() then
        if target:hasFlag("nyliulislash") and self:getCardsNum("Jink") > 0 then will = true end
        if target:hasFlag("nyliuliduel") and self:getCardsNum("Slash") > 1 then will = true end
    end
    if self.player:getHp() == target:getHp() then
        if target:hasFlag("nyliulislash") and self:getCardsNum("Jink") > 0 then will = true end
        if target:hasFlag("nyliuliduel") and self:getCardsNum("Slash") > 1 then will = true end
    end
    if will then
        for _,choice in ipairs(choices) do
            if string.find(choice, "replace") then
                return choice
            end
        end
    end
    return "cancel"
end

--奢葬

sgs.ai_skill_invoke.nyshezhang = true

--同礼

sgs.ai_skill_use["@@nytongli"] = function(self, prompt)
    if self.player:getMark("nytonglitimes") > 8 then return "." end
    local suit = self.player:property("nytonglisuit"):toString()
    local can = {}
    for _,card in sgs.qlist(self.player:getHandcards()) do
        if card:getSuitString() == suit then
            table.insert(can, card)
        end
        if #can >= 5 then break end
    end
    if #can == 0 then return "." end

    local pattern = self.player:property("nytonglipattern"):toString()
    local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
    card:setSkillName("nytongli")
    local find = false
    local findcard = nil
    self:sortByCardNeed(can)

    local origin = self.player:getTag("nytongliorigin"):toCard()

    for _,c in ipairs(can) do
        if self:getUseValue(c) <= self:getUseValue(origin) then
            card:addSubcard(c)
            findcard = c
            find = true
            break
        end
    end
    if not find then return "." end

    local use = self:aiUseCard(card)
    if use.card then
        if use.to and use.to:length() > 0 then
            local tos = {}
            for _,p in sgs.qlist(use.to) do
                table.insert(tos, p:objectName())
            end
            return card:toString().."->"..table.concat(tos,"+")
        end
    end
    return "."
end

--离间

local nylijian_skill = {}
nylijian_skill.name = "nylijian"
table.insert(sgs.ai_skills, nylijian_skill)
nylijian_skill.getTurnUseCard = function(self, inclusive)
    if self.player:usedTimes("#nylijian") >= 2 then return end
	return sgs.Card_Parse("#nylijian:.:")
end

sgs.ai_skill_use_func["#nylijian"] = function(card, use, self)
    local targets = {}
    local to = sgs.SPlayerList()
    self:sort(self.enemies, "defense")
    for _, p in ipairs(self.enemies) do
        if #targets < 2 then
            table.insert(targets, p:objectName())
            to:append(p)
        end
    end
    if #targets < 2 then
        local others = {}
        for _,p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
            if (not table.contains(targets, p:objectName())) and (not self:isFriend(p)) then
                table.insert(others, p)
            end
        end
        self:sort(others, "defense")
        for _, p in ipairs(others) do
            if #targets < 2 then
                table.insert(targets, p:objectName())
                to:append(p)
            end
        end
    end
    if #targets < 2 and #targets == 1 then
        self:sort(self.friends, "handcard",true)
        for _, p in ipairs(self.friends) do
            if #targets < 2 and (not table.contains(targets, p:objectName())) then
                table.insert(targets, p:objectName())
                to:append(p)
            end
        end
    end
    if #targets < 2 then
        return "."
    else
        local card_str = string.format("#nylijian:.:->%s", table.concat(targets, "+"))
		local acard = sgs.Card_Parse(card_str)
		assert(acard)
		use.card = acard
		if use.to then
			use.to = to
		end
    end
end

sgs.ai_skill_playerchosen.nylijian = function(self, targets)
    for _,target in sgs.qlist(targets) do
		if self:isFriend(target) or target:objectName() == self.player:objectName() then
			return target
		end
	end
    local can = {}
    for _,target in sgs.qlist(targets) do
		table.insert(can, target)
	end
    self:sort(can, "defense")
    return can[#can]
end

sgs.ai_skill_choice["nylijian"] = function(self, choices, data)
    choices = choices:split("+")
    local from
    local to
    for _,p in sgs.qlist(self.room:getAlivePlayers()) do
        if p:getMark("nylijian") == 1 then
            from = p
        elseif p:getMark("nylijian") == 2 then
            to = p
        end
    end
    if self:isFriend(from) then
        if to:hasArmorEffect("vine") then
            for _,choice in ipairs(choices) do
                if string.find(choice, "fire_slash") then
                    return choice
                end
            end
        end
        for _,choice in ipairs(choices) do
            if string.find(choice, "slash") then
                return choice
            end
        end
    end
    if (not self:isFriend(from)) and (self.player:usedTimes("#nylijian") >= 2) then
        if table.contains(choices, "duel") then
            return "duel"
        end
    end
    if to:hasArmorEffect("vine") then
        for _,choice in ipairs(choices) do
            if string.find(choice, "fire_slash") then
                return choice
            end
        end
    end
    if to:isChained() or (self.player:usedTimes("#nylijian") < 2) then
        if table.contains(choices, "slash") then
            return "slash"
        end
    end
    return choices[math.random(1, #choices)]
end

sgs.ai_card_intention.nylijian = function(self, card, from, tos)
    for _,to in ipairs(tos) do
		sgs.updateIntention(from, to, 60)
	end
end

sgs.ai_playerchosen_intention.nylijian = function(self, from, to)
	sgs.updateIntention(from, to, -30)
end

sgs.ai_use_priority.nylijian = sgs.ai_use_priority.Slash + 0.1

--夺刃

sgs.ai_skill_invoke.nyduoren = function(self, data)
    if self.player:getMaxHp() <= 3 then return false end
    return true
end

--血偿

local nyxuechang_skill = {}
nyxuechang_skill.name = "nyxuechang"
table.insert(sgs.ai_skills, nyxuechang_skill)
nyxuechang_skill.getTurnUseCard = function(self, inclusive)
    if not self.player:canPindian() then return end
    if self.player:getMark("nyxuechangfailed-PlayClear") > 0 then return end
    if self.player:getHandcardNum() < 2 then return end
    if self.player:getHandcardNum() <= self.player:getMaxCards() - 1 then return end
	return sgs.Card_Parse("#nyxuechang:.:")
end

sgs.ai_skill_use_func["#nyxuechang"] = function(card, use, self)
    local target = nil
    self:sort(self.enemies, "defense")
	for _,p in ipairs(self.enemies) do
		if self.player:canPindian(p) and p:getMark("nyxuechangfrom"..self.player:objectName().."-PlayClear") == 0 then
            target = p
            break
        end
	end
    if not target then return end
    if target then
		local card_str = "#nyxuechang:.:->"..target:objectName()
		local acard = sgs.Card_Parse(card_str)
		assert(acard)
		use.card = acard
		if use.to then
			use.to:append(target)
		end
	end
end

sgs.ai_use_priority.nyxuechang = sgs.ai_use_priority.Slash + 0.1

--悲愤

sgs.ai_skill_use["@@nybeifen"] = function(self, prompt)
    local target = nil
    for _,p in sgs.qlist(self.room:getAlivePlayers()) do
        if p:hasFlag("nybeifentarget") then
            target = p
            break
        end
    end
    if target and (not self:isFriend(target)) then return "." end

    local usecard = {}
    local cards = {}
    local card_ids = self.player:getPile("nyhujia")
    for _,id in sgs.qlist(card_ids) do
        local card = sgs.Sanguosha:getCard(id)
        table.insert(cards, card)
    end
    self:sortByCardNeed(cards)
    usecard = cards[#cards]

    if not target then
        self:sort(self.friends, "defense")
        target = self.friends[1]
    end

    if target then
        local card_str = string.format("#nybeifen:%s:->%s", usecard:getEffectiveId(), target:objectName())
        return card_str
    end
    return "."
end

sgs.ai_card_intention.nybeifen = function(self, card, from, tos)
    for _,to in ipairs(tos) do
		sgs.updateIntention(from, to, -80)
	end
end

--怨语

local nyyuanyu_skill = {}
nyyuanyu_skill.name = "nyyuanyu"
table.insert(sgs.ai_skills, nyyuanyu_skill)
nyyuanyu_skill.getTurnUseCard = function(self, inclusive)
	if not self.player:hasUsed("#nyyuanyu") then
		return sgs.Card_Parse("#nyyuanyu:.:")
	end
end

sgs.ai_skill_use_func["#nyyuanyu"] = function(card, use, self)
	use.card = card
end

sgs.ai_skill_playerchosen.nyyuanyu = function(self, targets)
    for _,target in sgs.qlist(targets) do
		if self:isFriend(target) and target:getMark("nyyuanyufrom"..self.player:objectName()) > 0 then
			return target
		end
	end
    for _,target in sgs.qlist(targets) do
		if self:isEnemy(target) and target:getMark("nyyuanyufrom"..self.player:objectName()) == 0 then
			return target
		end
	end
    return nil
end

sgs.ai_use_priority.nyyuanyu = 10

sgs.ai_playerchosen_intention.nyyuanyu = function(self, from, to)
    if to:getMark("nyyuanyufrom"..from:objectName()) > 0 then
	    sgs.updateIntention(from, to, -40)
    else
        sgs.updateIntention(from, to, 80)
    end
end

--夕颜

sgs.ai_skill_use["@@nyxiyan"] = function(self, prompt)
    local card_ids = self.player:getPile("nyyuan")
    local spade = {}
    local diamond = {}
    local heart = {}
    local club = {}
    local all = {}
    for _,id in sgs.qlist(card_ids) do
        local c = sgs.Sanguosha:getCard(id)
        if c:getSuit() == sgs.Card_Spade then
            table.insert(spade, c)
        elseif c:getSuit() == sgs.Card_Heart then
            table.insert(heart, c)
        elseif c:getSuit() == sgs.Card_Club then
            table.insert(club, c)
        elseif c:getSuit() == sgs.Card_Diamond then
            table.insert(diamond, c)
        end
        table.insert(all, c)
    end
    if #spade < 2 or #diamond < 2 or #heart < 2 or #club < 2 then return "." end
    local get = {}
    local suits = {}
    self:sortByCardNeed(all)
    for _,card in ipairs(all) do
        if not table.contains(suits, card:getSuitString()) then
            table.insert(get, card:getEffectiveId())
            table.insert(suits, card:getSuitString())
        end
    end
    if #suits >= 4 then
        local card_str = string.format("#nyxiyan:%s:", table.concat(get, "+"))
        return card_str
    end
    return "."
end
