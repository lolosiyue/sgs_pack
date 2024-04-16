--穆荫

sgs.ai_skill_playerchosen.ny_chenliuwu_muying = function(self, targets)
    local min = -1
    local selected = nil
    for _,target in sgs.qlist(targets) do
        if self:isFriend(target) then
            if target:hasSkill("ny_guixiang") and target:getMaxCards() == 2 then continue end--防止穆荫导致贵相跳了摸牌阶段
            if min < 0 or min > target:getMaxCards() then 
                min = target:getMaxCards() 
                selected = target
            end
        end
    end
    return selected
end

--斩钉

local ny_zhanding_skill = {}
ny_zhanding_skill.name = "ny_zhanding"
table.insert(sgs.ai_skills, ny_zhanding_skill)
ny_zhanding_skill.getTurnUseCard = function(self, inclusive)
    if self.player:getMaxCards() <= 0 then return end
    local cards = sgs.QList2Table(self.player:getHandcards())
    self:sortByKeepValue(cards)
    if self:getCardsNum("Slash") > 0 and self.player:getHandcardNum() > self.player:getMaxCards() then return end
	for _,card in ipairs(cards) do
        
        local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
        slash:addSubcard(card)
        slash:setSkillName("ny_zhanding")
        slash:deleteLater()

        if not slash:isAvailable(self.player) then continue end

        local usec = {isDummy=true,to=sgs.SPlayerList()}
        self:useCardByClassName(slash, usec)
        if  usec.card then
            self.ny_zhanding_to = usec.to
            local card_str = string.format("#ny_zhanding:%s:", card:getEffectiveId())
            return sgs.Card_Parse(card_str)
        end
    end
end

sgs.ai_skill_use_func["#ny_zhanding"] = function(card, use, self)
	use.card = card
    if use.to then use.to = self.ny_zhanding_to end
end

--移荣

local ny_yirong_skill = {}
ny_yirong_skill.name = "ny_yirong"
table.insert(sgs.ai_skills, ny_yirong_skill)
ny_yirong_skill.getTurnUseCard = function(self, inclusive)
	if (self.player:usedTimes("#ny_yirong") < 2) and (self.player:getHandcardNum() ~= self.player:getMaxCards()) then
		return sgs.Card_Parse("#ny_yirong:.:")
	end
end

sgs.ai_skill_use_func["#ny_yirong"] = function(card, use, self)

	if self.player:getHandcardNum() > self.player:getMaxCards() then
		local n = self.player:getHandcardNum() - self.player:getMaxCards()
		local cards = sgs.QList2Table(self.player:getCards("h"))
		self:sortByKeepValue(cards)
		local to_discard = {}
		for _,card in ipairs(cards) do
			table.insert(to_discard,card:getEffectiveId())
			n = n - 1
			if n <= 0 then break end
		end
	
		local card_str = "#ny_yirong:"..table.concat(to_discard, "+")..":"
		local acard = sgs.Card_Parse(card_str)
		assert(acard)
		use.card = acard
	else
		use.card = card
	end
end

--保族

sgs.ai_skill_invoke.ny_baozu = function(self, data)
    local dying = self.room:getTag("ny_baozu_dying"):toDying()
    return dying.who and self:isFriend(dying.who)
end

--迂志

sgs.ai_skill_choice["ny_yuzhi"] = function(self, choices, data)
    local items = choices:split("+")

    if table.contains(items, "skill") and self.player:getMark("@ny_baozu_mark") == 0
    and self.player:getHp() == 1 then return "skill" end

    if self.player:isChained() and self.player:getHp() == 1
    and self:getCardsNum("Peach") + self:getCardsNum("Analeptic") <= 0
    and table.contains(items, "skill") then return "skill" end

    return "hp"
end

local function chsize(tmp)
	if not tmp then
		return 0
    elseif tmp > 240 then
        return 4
    elseif tmp > 225 then
        return 3
    elseif tmp > 192 then
        return 2
    else
        return 1
    end
end

local function utf8len(str)
	local length = 0
	local currentIndex = 1
	while currentIndex <= #str do
		local tmp = string.byte(str, currentIndex)
		currentIndex  = currentIndex + chsize(tmp)
		length = length + 1
	end
	return length
end

sgs.ai_skill_discard.ny_yuzhi = function(self,max,min)
    if self.player:isKongcheng() then return {} end
    local max = 0
    local card = {}
    local now
    for _,c in sgs.qlist(self.player:getHandcards()) do
        local n = utf8len(sgs.Sanguosha:translate(c:objectName()))
        if c:isKindOf("Slash") then n = 1 end
        if n >= 4 then 
            table.insert(card, c:getEffectiveId())
            return card
        end
        if n > max then
            max = n
            now = c
        end
    end
    table.insert(card, now:getEffectiveId())
    return card
end

--挟术

sgs.ai_skill_discard.ny_xieshu = function(self,max,min)
    if self.player:getLostHp() < max then return {} end
    local discards = {}
    local n = max
    local cards = sgs.QList2Table(self.player:getCards("he"))
    self:sortByCardNeed(cards)
    for _,card in ipairs(cards) do
        table.insert(discards, card:getEffectiveId())
        n = n - 1
        if n <= 0 then return discards end
    end
    if n > 0 then return {} end
    return discards
end

--捷谏

sgs.ai_skill_playerchosen.ny_jiejian = function(self, targets)
    local fri = {}
    for _,target in sgs.qlist(targets) do
        if self:isFriend(target) then
            table.insert(fri, target)
        end
    end
    if #fri == 0 then return nil end
    self:sort(fri, "handcard")
    return fri[1]
end

--惶汗

sgs.ai_skill_invoke.ny_huanghan = function(self, data)
    local draw = self.player:getMark("ny_huanghan_draw")
    local dis = self.player:getLostHp()
    if self.player:isNude() then return true end

    if self.player:getMark("&ny_huanghan-Clear") > 0 
    and self.player:hasSkill("ny_baozu") and self.player:getMark("@ny_baozu_mark") == 0 then
        return (draw + 2 >= dis) or (self.player:getCards("he"):length() <= 2)
    end
    return draw >= dis
end

--蹈节

sgs.ai_skill_choice["ny_daojie"] = function(self, choices, data)
	if string.find(choices, "ny_daojie") then return "ny_daojie" end
    if self.player:getHp() + self:getCardsNum("Peach") + self:getCardsNum("Analeptic") > 1 then return "hp" end
    return "skill"
end

sgs.ai_skill_playerchosen.ny_daojie = function(self, targets)
    local fri = {}
    for _,target in sgs.qlist(targets) do
        if self:isFriend(target) then
            table.insert(fri, target)
        end
    end
    --if #fri == 0 then return nil end
    if #fri > 0 then
        self:sort(fri, "handcard")
        return fri[1]
    end
    for _,target in sgs.qlist(targets) do
        return target
    end
    return self.player
end

--神君

sgs.ai_skill_choice["ny_shenjun"] = function(self, choices, data)
    local cards = sgs.QList2Table(self.player:getHandcards())
    self:sortByUseValue(cards)
	for _,card in ipairs(cards) do
        if card:hasFlag("ny_shenjun") then
            local usec = {isDummy=true,to=sgs.SPlayerList()}
            self:useCardByClassName(card, usec)
            if usec.card and string.find(choices, card:objectName()) then
                return card:objectName()
            end
        end
    end
    return "cancel"
end

sgs.ai_skill_use["@@ny_shenjun"] = function(self, prompt)
    local need = self.player:getMark("ny_shenjun")
    --if need >= (self.player:getHandcardNum() - 1) and self.player:getPhase() == sgs.Player_NotActive then return false end
    local cards = sgs.QList2Table(self.player:getCards("he"))
    self:sortByCardNeed(cards)

    local pattern = self.player:property("ny_shenjun"):toString()
    local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
    card:setSkillName("ny_shenjun")
    for _,cc in ipairs(cards) do
        card:addSubcard(cc)
        need = need - 1
        if need <= 0 then break end
    end

    local use = {isDummy=true,to=sgs.SPlayerList()}
    self:useCardByClassName(card, use)
    if use.card then
        local tos = {}
        for _,p in sgs.qlist(use.to) do
            table.insert(tos, p:objectName())
        end
        return card:toString().."->"..table.concat(tos,"+")
    end
    card:deleteLater()
end

--八龙

--[[local ny_balong_skill = {}
ny_balong_skill.name = "ny_balong"
table.insert(sgs.ai_skills, ny_balong_skill)
ny_balong_skill.getTurnUseCard = function(self, inclusive)
    if self.player:getMark("ny_balong_old") > 0 then return end
    return sgs.Card_Parse("#ny_balong:.:")
end

sgs.ai_skill_use_func["#ny_balong"] = function(card,use,self)
    use.card = card
end

sgs.ai_use_priority.ny_balong = 10]]

--三恇

sgs.ai_skill_playerchosen.ny_sankuang = function(self, targets)
    local use = self.player:getTag("ny_sankuang_use"):toCardUse()
    local give = use.card:subcardsLength()
    if self.player:hasSkill("ny_daojie")and (not use.card:isDamageCard())
    and use.card:isKindOf("TrickCard") and self.player:getMark("ny_daojie-Clear") == 0 then
        give = 0
    end
    local max = -99
    local rtarget
    for _,target in sgs.qlist(targets) do
        local min = 0
        if (not target:getCards("ej"):isEmpty()) then min = min + 1 end
        if target:isWounded() then min = min + 1 end
        if target:getHandcardNum() > target:getHp() then min = min + 1 end
        min = math.min(min, target:getCards("he"):length())
        local value = min*1.2 - give
        if self:isFriend(target) then value = (-1)*value end
        if value > max then
            max = value
            rtarget = target
        end
    end
    return rtarget
end

--百出

sgs.ai_skill_choice["ny_baichu"] = function(self, choices, data)
	if string.find(choices, "recover") then return "recover" end
    local items = choices:split("+")
    return items[math.random(1,#items)]
end

--奇策

local ny_zuqice_skill = {}
ny_zuqice_skill.name = "ny_zuqice"
table.insert(sgs.ai_skills, ny_zuqice_skill)
ny_zuqice_skill.getTurnUseCard = function(self, inclusive)
    if self.player:isKongcheng() then return end
    if self.player:hasUsed("#ny_zuqice") then return end
    local records = self.player:getTag("ny_baichu_records"):toString():split("+")
    if (not records) or (#records <= 0) then return end

    local rand_patterns = {}
    local n = 12
    while(#records > 0)do
        local pattern = records[math.random(1, #records)]
        table.insert(rand_patterns, pattern)
        table.removeOne(records, pattern)
        n = n - 1
        if n <= 0 then break end
    end

	for _,pattern in ipairs(rand_patterns) do
        local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
        
        for _,cc in sgs.qlist(self.player:getHandcards()) do
            card:addSubcard(cc)
        end

        card:setSkillName("ny_zuqice")
        card:deleteLater()
 
        local cc = ny_zuqiceCard:clone()
        cc:addSubcards(card:getSubcards())
        cc:setUserString(pattern)

        if card:isAvailable(self.player) then
            local usec = {isDummy=true,to=sgs.SPlayerList()}
            self:useCardByClassName(card, usec)
            if usec.card and (not (card:canRecast() and usec.to:length() < 1)) then
                self.ny_zuqice_to = usec.to
                --local card_str = string.format("#ny_zuqice:%s:%s:", cards[1]:getEffectiveId(), pattern)
                local card_str = cc:toString()
                return sgs.Card_Parse(card_str)
            end
        end
    end
end

sgs.ai_skill_use_func["#ny_zuqice"] = function(card, use, self)
	use.card = card
    if use.to then use.to = self.ny_zuqice_to end
end