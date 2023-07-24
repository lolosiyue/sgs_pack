extension = sgs.Package("scarlet")
s4_cloud_huangzhong = sgs.General(extension, "s4_cloud_huangzhong", "shu", 3, false)

s4_cloud_liegong = sgs.CreateTriggerSkill {
    name = "s4_cloud_liegong",
    events = {sgs.TargetConfirmed, sgs.DamageCaused},
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.TargetConfirmed then
            local use = data:toCardUse()
            if (player:objectName() ~= use.from:objectName()) or not use.card:isKindOf("Slash") then
                return false
            end
            local jink_table = sgs.QList2Table(player:getTag("Jink_" .. use.card:toString()):toIntList())
            local index = 1
            for _, p in sgs.qlist(use.to) do
                if p:getHandcardNum() >= player:getHp() or p:getHandcardNum() <= player:getAttackRange() then
                    local _data = sgs.QVariant()
                    _data:setValue(p)
                    if player:askForSkillInvoke(self:objectName(), _data) then
                        room:broadcastSkillInvoke(self:objectName())
                        jink_table[index] = 0
                    end
                end
                index = index + 1

            end
            local jink_data = sgs.QVariant()
            jink_data:setValue(table2IntList(jink_table))
            player:setTag("Jink_" .. use.card:toString(), jink_data)
            return false
        elseif event == sgs.DamageCaused then
            local damage = data:toDamage()
            if damage.card and damage.card:isKindOf("Slash") and damage.from then
                if damage.to and (damage.to:getHp() >= player:getHp() or damage.to:getHp() <= player:getAttackRange()) then
                    local _data = sgs.QVariant()
                    _data:setValue(damage.to)
                    if player:askForSkillInvoke(self:objectName(), _data) then
                        room:broadcastSkillInvoke(self:objectName())
                        damage.damage = damage.damage + 1
                        data:setValue(damage)
                    end
                end
            end
        end
    end
}
s4_cloud_yongyi = sgs.CreateTriggerSkill {
    name = "s4_cloud_yongyi",
    events = {sgs.CardUsed , sgs.CardResponded , sgs.TargetConfirmed},
    on_trigger = function(self, event, player, data, room)
        if event == sgs.CardUsed then
            local card = nil
            if (event == CardUsed) then
                local use = data:toCardUse()
                card = use.card
            elseif (event == CardResponded) then
                local res = data:toCardResponse()
                if (not res.m_isUse) then return false end
                card = res.m_card
            elseif (event == TargetConfirmed) then
                local use = data:toCardUse()
                if (use.from == player or not use.to.contains(player)) then return false end
                card = use.card;
            end
            if (not card or card:isKindOf("SkillCard")) then return false end
            local record = player:property("s4_cloud_yongyiRecords"):toString()
            local suit = card:getSuitString()
            local records
            if (not record.isEmpty()) then
                records = record:split(",")
            end
            if (records.contains(suit)) or not card:hasSuit() then 
                local x = math.max(1, #records)
                if player:askForSkillInvoke(self:objectName()) then
                    player:drawCards(x)
                    if card:hasSuit() then
                    table.removeOne(records, suit)
                    end
                end
            else
                table.insert(records, suit)
                
                end
                room:setPlayerProperty(player, "s4_cloud_yongyiRecords", records.join(","));
                for n,m in sgs.list(player:getMarkNames())do
                    if (not m.startsWith("&s4_cloud_yongyi+#record") or player:getMark(m) <= 0) then continue end
                    room:setPlayerMark(player, m, 0);
                end
                local mark = "&s4_cloud_yongyi+#record";
                for _, suit in ipairs(records) do
                    mark = mark + "+" + suit + "_char"
                end
                room:setPlayerMark(player, mark, 1)
            
        end
        return false
    end
}
s4_cloud_yongyiAttackRange = sgs.CreateAttackRangeSkill{
	name = "#s4_cloud_yongyiAttackRange",
    extra_func = function(self,target)
        local record = target:property("s4_cloud_yongyiRecords"):toString():split(",")
        local x = #record
		if record
		then return x end
	end,
}

s4_cloud_yongyiCard = sgs.CreateSkillCard {
    name = "s4_cloud_yongyi",
    handling_method = sgs.Card_MethodUse,
    filter = function(self, targets, to_select, player)
        local qtargets = sgs.PlayerList()
        for _,p in ipairs(targets) do
            qtargets:append(p)
        end
        if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
            local card, user_string = nil, self:getUserString()
            if user_string ~= "" then
                card = sgs.Sanguosha:cloneCard(user_string:split("+")[1])
                card:setSkillName("_s4_cloud_yongyi")
            end
            return card and card:targetFilter(qtargets, to_select, player) and not player:isProhibited(to_select, card, qtargets)
        end
    
        local card = sgs.Sanguosha:cloneCard("analeptic")
        card:setSkillName("_s4_cloud_yongyi")
        if card and card:targetFixed() then
            return card:isAvailable(player)
        end
        return card and card:targetFilter(qtargets, to_select, player) and not player:isProhibited(to_select, card, qtargets)
    end,
    feasible = function(self, targets, player)
        local card = sgs.Sanguosha:cloneCard("analeptic")
        if card then
            card:setSkillName("_s4_cloud_yongyi")
        end
        local qtargets = sgs.PlayerList()
        for _,p in ipairs(targets) do
            qtargets:append(p)
        end
        return card and card:targetsFeasible(qtargets, player)
    end,
    on_validate = function(self, cardUse)
        local source = cardUse.from
        local room = source:getRoom()
        
        local user_string = self:getUserString()
        local use_card = sgs.Sanguosha:cloneCard(user_string, self:getSuit(), self:getNumber())
        if not use_card then return nil end
        use_card:setSkillName("s4_cloud_yongyi")
        use_card:deleteLater()
        room:setCardFlag(use_card, "RemoveFromHistory")
        room:addPlayerMark(source, "s4_cloud_yongyi-Clear")
        return use_card
    end,
    on_validate_in_response = function(self, source)
        local room = source:getRoom()
        local user_string = self:getUserString()
        if user_string == "peach+analeptic" then
            user_string = "analeptic"
        end
        local use_card = sgs.Sanguosha:cloneCard(user_string, self:getSuit(), self:getNumber())
        if not use_card then return nil end
        use_card:setSkillName("s4_cloud_yongyi")
        room:setCardFlag(use_card, "RemoveFromHistory")
        room:addPlayerMark(source, "s4_cloud_yongyi-Clear")
        use_card:deleteLater()
        return use_card
    end
    }
    
s4_cloud_yongyiVS = sgs.CreateZeroCardViewAsSkill{
    name = "s4_cloud_yongyi",
    view_as = function(self, card)
        if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or
            sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
            local c = s4_cloud_yongyiCard:clone()
            c:addSubcard(card)
            c:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
            return c
        end
        
        local ccc = sgs.Sanguosha:cloneCard("analeptic")
        if ccc and ccc:isAvailable(sgs.Self) then
            local c = s4_cloud_yongyiCard:clone()
            c:setUserString(ccc:objectName())
            return c
        end
        return nil
    end,
    enabled_at_play = function(self, player)
        return #player:property("s4_cloud_yongyiRecords"):toString():split(",") > 0 and player:getMark("s4_cloud_yongyi-Clear") == 0
    end,
    enabled_at_response = function(self, player, pattern)
        return #player:property("s4_cloud_yongyiRecords"):toString():split(",") > 0 and string.find(pattern, "analeptic") and player:getMark("s4_cloud_yongyi-Clear") == 0
    end
}
    


function addWeiTerritoryPile(card,player,self)
	local room = player:getRoom()
	card = type(card)=="number" and sgs.Sanguosha:getCard(card) or card
	self = type(self)=="string" and self or self and self:objectName() or ""
	if card:getEffectiveId()<0 then return end

	local WeiTerritoryPile = room:getTag("WeiTerritoryPile"):toString():split("+")
    if #WeiTerritoryPile >= 13 then  
        local log = sgs.LogMessage()
        log.type = "$addWeiTerritoryPileFailture"
        log.from = player
        log.arg = "WeiTerritoryPile"
        local toids = {}
        local c = dummyCard()
        for _,id in sgs.list(card:getSubcards())do
            table.insert(toids,id)
            c:addSubcard(id)
        end
        log.card_str = table.concat(toids,"+")
        room:sendLog(log)
        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER,nil,nil,"addWeiTerritoryPileFailture",nil)
        room:throwCard(c,reason,nil)
        return 
    end
	local log = sgs.LogMessage()
	log.type = "$addWeiTerritoryPile"
	log.from = player
	log.arg = "WeiTerritoryPile"
	local toids = {}
	local c = dummyCard()
	for _,id in sgs.list(card:getSubcards())do
		table.insert(WeiTerritoryPile,id)
		table.insert(toids,id)
		c:addSubcard(id)
	end
   	log.card_str = table.concat(toids,"+")
   	room:sendLog(log)
	room:setTag("WeiTerritoryPile",sgs.QVariant(table.concat(WeiTerritoryPile,"+")))
   	log = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECYCLE,player:objectName(),"",self,"addWeiTerritoryPile")
   	room:moveCardTo(c,nil,sgs.Player_PlaceTable,log,true)
    WeiTerritoryPile = room:getTag("WeiTerritoryPile"):toString():split("+")
   	for _,p in sgs.list(room:getAlivePlayers())do
    	if p:getMark("&WeiTerritoryPile")>0
		then
	    	room:setPlayerMark(p,"&WeiTerritoryPile",#WeiTerritoryPile)
			return
		end
	end
	room:setPlayerMark(player,"&WeiTerritoryPile",#WeiTerritoryPile)
end
function getWeiTerritoryPile(player)
	local WeiTerritoryPile = player:getRoom():getTag("WeiTerritoryPile"):toString():split("+")
	local toid = sgs.IntList()
   	for _,id in sgs.list(WeiTerritoryPile)do
		toid:append(id)
	end
	return toid
end
function gainWeiTerritoryPile(cards, player, self)
    if player:getKingdom() == "wei" then
    local room = player:getRoom()
    room:fillAG(cards,player)
    local card_id = room:askForAG(player,cards,false,self:objectName())
    room:obtainCard(player,card_id,false)
    room:clearAG(player)
    end
end

s4_weiT_lord = sgs.CreateTriggerSkill{
	name = "s4_weiT_lord",
	events = sgs.EventPhaseStart,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start then
			addWeiTerritoryPile(room:getNCards(2), player, self)
		end
	end
}


s4_weiT_adviser = sgs.CreateTriggerSkill{
	name = "s4_weiT_adviser",
	events = sgs.CardUsed,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if (use.card and use.card:getTypeId() == sgs.Card_TypeTrick and player:getMark("&s4_weiT_adviser-Clear") == 0 and getWeiTerritoryPile(player):length() > 0) and player:askForSkillInvoke(self:objectName()) then
			gainWeiTerritoryPile(getWeiTerritoryPile(player), player, self)
            room:addPlayerMark(player, "&s4_weiT_adviser-Clear")
		end
	end
}

s4_weiT_gerenal = sgs.CreateTriggerSkill{
	name = "s4_weiT_gerenal",
	events = sgs.Damage,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
        if not damage.card or not damage.card:isKindOf("Slash") then return false end
		if player:getMark("&s4_weiT_gerenal-Clear") == 0 and getWeiTerritoryPile(player):length() > 0 and player:askForSkillInvoke(self:objectName()) then
			gainWeiTerritoryPile(getWeiTerritoryPile(player), player, self)
            room:addPlayerMark(player, "&s4_weiT_gerenal-Clear")
		end
	end
}

sgs.LoadTranslationTable {
    ["s4_cloud_huangzhong"] = "谋黄忠",
    ["designer:s4_cloud_huangzhong"] = "",
    ["~s4_cloud_huangzhong"] = "",
    ["#s4_cloud_huangzhong"] = "",

    ["s4_cloud_liegong"] = "烈弓",
    [":s4_cloud_liegong"] = "当你使用【杀】指定目标后，你可以根据下列条件执行相应的效果：1.若其手牌数不小于你的体力值或不大于你的攻击范围，你可以令其不能响应此【杀】；2.若其体力值不小于你的体力值或不大于你的攻击范围，你可以令此【杀】伤害+1。",

    ["s4_cloud_yongyi"] = "勇毅",
    [":s4_cloud_yongyi"] = "你使用牌时或成为其他角色使用牌的目标后，若此牌有花色且花色未被“勇毅”记录，则记录此花色；否则，你可以摸X张牌，若如此做，移除此花色记录。你的攻击范围加X（X为“勇毅”记录的花色数且至少为1）。每回合限一次，你可以移除一种花色记录，视为使用一张无次数限制的【酒】。",
}

sgs.LoadTranslationTable {
    ["addWeiTerritoryPile"] = "添加至魏领土",
	["WeiTerritoryPile"] = "魏领土",
	["$addWeiTerritoryPile"] = "%from 将 %card 置入“%arg”区",

    ["s4_weiT_lord"] = "君主",
    [":s4_weiT_lord"] = "天赋技，回合开始时，可将牌堆顶两牌置于【魏领土】。",
    ["s4_weiT_adviser"] = "谋臣",
    [":s4_weiT_adviser"] = "天赋技，每回合一次，当你使用一张锦囊牌时，可从【魏领土】中获得一张牌。",
    ["s4_weiT_gerenal"] = "功勋",
    [":s4_weiT_gerenal"] = "天赋技，每回合一次，当你使用【杀】造成伤害后，你可以从【魏领土】中获得一张牌。",


}
return {extension}

