extension = sgs.Package("sgs10th", sgs.Package_GeneralPack)
local packages = {}
table.insert(packages, extension)
--local json = require ("json")

local function cardsChosen(room, player, target, reason, flag, num)
    local maxhand = target:getHandcardNum()
    local hand = 0
    local chosen = sgs.IntList()
    local cards = sgs.QList2Table(target:getCards(flag))
    local max = math.min(#cards, num)
    for i = 1, max, 1 do
        if hand >= maxhand then
            local newflag
            if string.find(flag, "e") then
                if string.find(flag, "j") then
                    newflag = "ej"
                else
                    newflag = "e"
                end
            else
                newflag = "j"
            end

            local id = room:askForCardChosen(player, target, newflag, reason, false, sgs.Card_MethodNone, chosen)
            chosen:append(id)
        else
            local id = room:askForCardChosen(player, target, flag, reason, false, sgs.Card_MethodNone, chosen)
            if room:getCardPlace(id) == sgs.Player_PlaceHand then
                hand = hand + 1
            else
                chosen:append(id)
            end
        end
    end
    if hand > 0 then
        cards = sgs.QList2Table(target:getHandcards())
        for i = 1, hand, 1 do
            chosen:append(cards[i]:getId())
        end
    end
    return chosen
end

ny_10th_xujing = sgs.General(extension, "ny_10th_xujing", "shu", 3, true, false, false)

ny_10th_caixia = sgs.CreateTriggerSkill{
    name = "ny_10th_caixia",
    events = {sgs.CardUsed,sgs.CardResponded,sgs.Damage,sgs.Damaged},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardUsed or event == sgs.CardResponded then
            if player:getMark("&ny_10th_caixia") == 0 then return false end
            local card = nil
            if event == sgs.CardUsed then
                card = data:toCardUse().card
            else
                local response = data:toCardResponse()
                if response.m_isUse then
                    card = response.m_card
                end
            end
            if (not card) or (card:isKindOf("SkillCard")) then return false end
            room:removePlayerMark(player, "&ny_10th_caixia", 1)
        end
        if event == sgs.Damage or event == sgs.Damaged then
            if player:isDead() then return false end
            if player:getMark("&ny_10th_caixia") > 0 then return false end
            if room:askForSkillInvoke(player, self:objectName(), data) then
                room:broadcastSkillInvoke(self:objectName())
                local all = room:getAllPlayers(true):length()
                all = math.min(5,all)
                local choices = {}
                for i = 1, all, 1 do
                    table.insert(choices, string.format("%d",i))
                end
                local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
                local n = tonumber(choice)
                room:addPlayerMark(player, "&ny_10th_caixia", n)
                player:drawCards(n, self:objectName())
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_shangyu = sgs.CreateTriggerSkill{
    name = "ny_10th_shangyu",
    events = {sgs.GameStart,sgs.CardsMoveOneTime},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.GameStart then
            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
            for _,id in sgs.qlist(room:getDrawPile()) do
                local card = sgs.Sanguosha:getCard(id)
                if card:isKindOf("Slash") then
                    room:setPlayerMark(player, "ny_10th_shangyu_slash", id)
                    room:obtainCard(player, card, true)
                    room:setCardTip(id, "ny_10th_shangyu")
                    local target = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), "@ny_10th_shangyu", false, true)
                    if target:objectName() ~= player:objectName() then
                        room:obtainCard(target, card, true)
                        room:setCardTip(id, "ny_10th_shangyu")
                    end
                    break
                end
            end
        end
        if event == sgs.CardsMoveOneTime then
            local move = data:toMoveOneTime()
            if not player:hasSkill(self:objectName()) then return false end
            if player:isDead() then return false end
            if move.to_place == sgs.Player_DiscardPile then
                for _,id in sgs.qlist(move.card_ids) do
                    local card = sgs.Sanguosha:getCard(id)
                    if player:getMark("ny_10th_shangyu_slash") == id then
                        room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                        local all = sgs.SPlayerList()
                        for _,p in sgs.qlist(room:getAlivePlayers()) do
                            if p:getMark("ny_10th_shangyu_"..player:objectName().."-Clear") == 0 then
                                all:append(p)
                            end
                        end
                        if all:isEmpty() then return false end
                        local give = room:askForPlayerChosen(player, all, self:objectName(), "@ny_10th_shangyu", false, true)
                        room:setPlayerMark(give, "ny_10th_shangyu_"..player:objectName().."-Clear", 1)
                        room:obtainCard(give, id, true)
                        room:clearCardTip(id)
                        room:setCardTip(id, "ny_10th_shangyu")
                        break
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_shangyu_damage = sgs.CreateTriggerSkill{
    name = "#ny_10th_shangyu_damage",
    events = {sgs.Damage},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local damage = data:toDamage()
        if damage.card then
            for _,p in sgs.qlist(room:findPlayersBySkillName("ny_10th_shangyu")) do
                if p:getMark("ny_10th_shangyu_slash") == damage.card:getId() then
                    room:sendCompulsoryTriggerLog(p, "ny_10th_shangyu", true, true)
                    damage.from:drawCards(1, "ny_10th_shangyu")
                    p:drawCards(1, "ny_10th_shangyu")
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_10th_xujing:addSkill(ny_10th_caixia)
ny_10th_xujing:addSkill(ny_10th_shangyu)
ny_10th_xujing:addSkill(ny_10th_shangyu_damage)
extension:insertRelatedSkills("ny_10th_shangyu", "#ny_10th_shangyu_damage")

ny_10th_lezhoufei = sgs.General(extension, "ny_10th_lezhoufei", "wu", 3, false, false, false)

ny_10th_lingkong = sgs.CreateTriggerSkill{
    name = "ny_10th_lingkong",
    events = {sgs.GameStart,sgs.CardsMoveOneTime,sgs.EventPhaseChanging},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.GameStart then
            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
            for _,card in sgs.qlist(player:getHandcards()) do
                room:setCardFlag(card, "ny_10th_konghou")
                room:setCardTip(card:getId(), "ny_10th_konghou")
            end
        end
        if event == sgs.CardsMoveOneTime then
            if player:getPhase() ~= sgs.Player_NotActive then return false end
            local move = data:toMoveOneTime()
            if move.to and move.to:objectName() == player:objectName()
            and move.to_place == sgs.Player_PlaceHand then
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                local ids = sgs.QList2Table(move.card_ids)
                local id = ids[math.random(1,#ids)]
                room:setCardFlag(sgs.Sanguosha:getCard(id), "ny_10th_konghou")
                room:setCardTip(id, "ny_10th_konghou")
            end
        end
        if event == sgs.EventPhaseChanging then
            local change = data:toPhaseChange()
            if change.to == sgs.Player_Discard then
                for _,card in sgs.qlist(player:getHandcards()) do
                    if card:hasFlag("ny_10th_konghou") then
                        room:clearCardTip(card:getId())
                        room:setCardTip(card:getId(), "ny_10th_konghou")
                        room:ignoreCards(player, card)
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_xianshu = sgs.CreateViewAsSkill
{
    name = "ny_10th_xianshu",
    n = 99,
    view_filter = function(self, selected, to_select)
        return to_select:hasFlag("ny_10th_konghou") and #selected == 0
    end,
    view_as = function(self, cards)
        if #cards == 1 then
            local cc = ny_10th_xianshuCard:clone()
            cc:addSubcard(cards[1])
            return cc
        end
    end,
    enabled_at_play = true,
}

ny_10th_xianshuCard = sgs.CreateSkillCard
{
    name = "ny_10th_xianshu",
    will_throw = false,
    filter = function(self, targets, to_select)
        return #targets == 0 and sgs.Self:objectName() ~= to_select:objectName()
    end,
    on_effect = function(self, effect)
        local room = effect.from:getRoom()
        local id = self:getSubcards():first()
        room:showCard(effect.from, id)
        room:obtainCard(effect.to, id, true)
        local card = sgs.Sanguosha:getCard(id)
        if card:isRed() and effect.to:getHp() <= effect.from:getHp() then
            room:recover(effect.to, sgs.RecoverStruct(effect.from, nil, 1))
        elseif card:isBlack() and effect.to:getHp() >= effect.from:getHp() then
            room:loseHp(effect.to, 1)
        end
        if effect.to:isAlive() and effect.from:isAlive() then
            local n = effect.to:getHp() - effect.from:getHp()
            n = math.abs(n)
            n = math.min(n,5)
            effect.from:drawCards(n, self:objectName())
        end
    end
}

ny_10th_lezhoufei:addSkill(ny_10th_lingkong)
ny_10th_lezhoufei:addSkill(ny_10th_xianshu)

ny_10th_donghuan = sgs.General(extension, "ny_10th_donghuan", "qun", 3, false, false, false)

ny_10th_shengdu = sgs.CreateTriggerSkill{
    name = "ny_10th_shengdu",
    events = {sgs.EventPhaseStart,sgs.CardsMoveOneTime},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.Player_RoundStart then return false end
            local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "@ny_10th_shengdu", true, true)
            if target then
                room:broadcastSkillInvoke(self:objectName())
                room:setPlayerMark(target, "&ny_10th_shengdu", 1)
                room:setPlayerMark(target, "ny_10th_shengdu_from_"..player:objectName(), 1)
            end
        end
        if event == sgs.CardsMoveOneTime then
            local move = data:toMoveOneTime()
            if move.to and move.to:getPhase() == sgs.Player_Draw and move.to_place == sgs.Player_PlaceHand then
                if move.to:getMark("ny_10th_shengdu_from_"..player:objectName()) > 0 then
                    room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                    player:drawCards(move.card_ids:length(), self:objectName())
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_shengdu_clear = sgs.CreateTriggerSkill{
    name = "#ny_10th_shengdu_clear",
    events = {sgs.EventPhaseEnd},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:getPhase() == sgs.Player_Draw and player:getMark("&ny_10th_shengdu") > 0 then
            room:setPlayerMark(player, "&ny_10th_shengdu", 0)
            for _,p in sgs.qlist(room:getAlivePlayers()) do
                room:setPlayerMark(player, "ny_10th_shengdu_from_"..p:objectName(), 0)
            end
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_10th_jieling = sgs.CreateViewAsSkill
{
    name = "ny_10th_jieling",
    n = 99,
    view_filter = function(self, selected, to_select)
        if #selected == 0 then
            return sgs.Self:getHandcards():contains(to_select)
        elseif #selected == 1 then
            return sgs.Self:getHandcards():contains(to_select) and (not to_select:sameColorWith(selected[1]))
        else
            return false
        end
    end,
    view_as = function(self, cards)
        if #cards == 2 then
            local cc = ny_10th_jielingCard:clone()
            cc:addSubcard(cards[1])
            cc:addSubcard(cards[2])
            return cc
        end
    end,
    enabled_at_play = function(self, player)
        return not player:hasUsed("#ny_10th_jieling")
    end,
}

ny_10th_jielingCard = sgs.CreateSkillCard
{
    name = "ny_10th_jieling",
    will_throw = false,
    filter = function(self, targets, to_select, player)
        local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
        slash:setSkillName(self:objectName())
        slash:addSubcards(self:getSubcards())

        local qtargets = sgs.PlayerList()
        for _,p in ipairs(targets) do
            qtargets:append(p)
        end

        slash:deleteLater()
        return slash and slash:targetFilter(qtargets, to_select, player) and not player:isProhibited(to_select, slash, qtargets)
    end,
    feasible = function(self, targets, player)
        local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
        slash:setSkillName(self:objectName())
        slash:addSubcards(self:getSubcards())
        slash:deleteLater()

        local qtargets = sgs.PlayerList()
        for _,p in ipairs(targets) do
            qtargets:append(p)
        end
        return slash and slash:targetsFeasible(qtargets, player)
    end,
    on_validate = function(self, cardUse)
        local source = cardUse.from
        local room = source:getRoom()

        local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
        slash:setSkillName(self:objectName())
        slash:addSubcards(self:getSubcards())
        room:setCardFlag(slash, "RemoveFromHistory")
        room:setCardFlag(slash, "ny_10th_jieling_slash")
        return slash
    end,
}

ny_10th_jieling_buff = sgs.CreateTriggerSkill{
    name = "#ny_10th_jieling_buff",
    events = {sgs.CardFinished,sgs.Damage},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.Damage then
            local damage = data:toDamage()
            if damage.card and damage.card:hasFlag("ny_10th_jieling_slash") then
                room:setCardFlag(damage.card, "ny_10th_jieling_success")
                if damage.to:isAlive() then
                    room:sendCompulsoryTriggerLog(player, "ny_10th_jieling", true)
                    room:loseHp(damage.to)
                end
            end
        end
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            local card = use.card
            if card:getSkillName() == "ny_10th_jieling" and (not card:hasFlag("ny_10th_jieling_success")) then
                room:sendCompulsoryTriggerLog(player, "ny_10th_jieling", true)
                local log = sgs.LogMessage()
                log.type = "#ChoosePlayerWithSkill"
                log.from = player
                log.arg = "ny_10th_shengdu"
                log.to = use.to
                room:sendLog(log)
                room:broadcastSkillInvoke("ny_10th_shengdu")

                for _,target in sgs.qlist(use.to) do
                    if target:isAlive() then
                        room:setPlayerMark(target, "&ny_10th_shengdu", 1)
                        room:setPlayerMark(target, "ny_10th_shengdu_from_"..player:objectName(), 1)
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_jieling_target = sgs.CreateTargetModSkill{
    name = "#ny_10th_jieling_target",
    residue_func = function(self, from, card)
        if card:getSkillName() == "ny_10th_jieling" then return 1000 end 
        return 0
    end,
    distance_limit_func = function(self, from, card)
        if card:getSkillName() == "ny_10th_jieling" then return 1000 end 
        return 0
    end,
}

ny_10th_donghuan:addSkill(ny_10th_shengdu)
ny_10th_donghuan:addSkill(ny_10th_shengdu_clear)
ny_10th_donghuan:addSkill(ny_10th_jieling)
ny_10th_donghuan:addSkill(ny_10th_jieling_buff)
ny_10th_donghuan:addSkill(ny_10th_jieling_target)
extension:insertRelatedSkills("ny_10th_shengdu", "#ny_10th_shengdu_clear")
extension:insertRelatedSkills("ny_10th_jieling", "#ny_10th_jieling_buff")
extension:insertRelatedSkills("ny_10th_jieling", "#ny_10th_jieling_target")

ny_10th_gaoxiang = sgs.General(extension, "ny_10th_gaoxiang", "shu", 4, true, false, false)

ny_10th_chiying = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_10th_chiying",
    view_as = function(self)
        return ny_10th_chiyingCard:clone()
    end,
    enabled_at_play = function(self, player)
        return not player:hasUsed("#ny_10th_chiying")
    end
}

ny_10th_chiyingCard = sgs.CreateSkillCard
{
    name = "ny_10th_chiying",
    filter = function(self, targets, to_select)
        return to_select:getHp() <= sgs.Self:getHp() and #targets == 0
    end,
    on_effect = function(self, effect)
        local room = effect.from:getRoom()
        local get = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, -1)
        local will = false
        if effect.from:objectName() ~= effect.to:objectName() then will = true end
        
        for _,other in sgs.qlist(room:getOtherPlayers(effect.to)) do
            if effect.from:objectName() ~= other:objectName() and effect.to:inMyAttackRange(other)
            and (not other:isNude()) then
                local card = room:askForDiscard(other, self:objectName(), 1, 1, false, true)
                if will then
                    if sgs.Sanguosha:getCard(card:getSubcards():first()):isKindOf("BasicCard") then
                        get:addSubcard(card)
                    end
                end
            end
        end

        if effect.to:isAlive() and will and get:subcardsLength() > 0 then
            room:obtainCard(effect.to, get, true)
        end
        get:deleteLater()
    end,
}

ny_10th_gaoxiang:addSkill(ny_10th_chiying)

ny_10th_wangrui = sgs.General(extension, "ny_10th_wangrui", "qun", 4, true, false, false)

ny_10th_tongye = sgs.CreateTriggerSkill{
    name = "ny_10th_tongye",
    events = {sgs.GameStart,sgs.Death,sgs.DrawNCards},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.GameStart or event == sgs.Death then
            if event == sgs.Death then
                local death = data:toDeath()
                if death.who:objectName() == player:objectName() then return false end
            end

            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
            local kingdoms = {}
            for _,p in sgs.qlist(room:getAlivePlayers()) do
                local kingdom = p:getKingdom()
                if not table.contains(kingdoms,kingdom) then
                    table.insert(kingdoms,kingdom)
                end
            end

            local log = sgs.LogMessage()
            log.type = "$ny_10th_tongye_kingdoms"
            log.arg = #kingdoms
            room:sendLog(log)

            room:setPlayerMark(player, "&ny_10th_tongye", #kingdoms)
        end

        if event == sgs.DrawNCards then
            if player:getMark("&ny_10th_tongye") == 1 then
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                local log = sgs.LogMessage()
                log.type = "$ny_10th_tongye_draw"
                log.from = player
                log.arg = self:objectName()
                log.arg2 = 3
                room:sendLog(log)

                local count = data:toInt() + 3
                data:setValue(count)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_tongye_maxcards = sgs.CreateMaxCardsSkill
{
    name = "#ny_10th_tongye_maxcards",
    extra_func = function(self, target)
        if target:hasSkill("ny_10th_tongye") and target:getMark("&ny_10th_tongye") <= 4 
        and target:getMark("&ny_10th_tongye") > 0 then return 3 end
        return 0
    end,
}

ny_10th_tongye_range = sgs.CreateAttackRangeSkill
{
    name = "#ny_10th_tongye_range",
    extra_func = function(self, target, include_weapon)
        if target:hasSkill("ny_10th_tongye") and target:getMark("&ny_10th_tongye") <= 3 
        and target:getMark("&ny_10th_tongye") > 0 then return 3 end
        return 0
    end,
}

ny_10th_tongye_slash = sgs.CreateTargetModSkill
{
    name = "#ny_10th_tongye_slash",
    residue_func = function(self, target, card)
        if target:hasSkill("ny_10th_tongye") and target:getMark("&ny_10th_tongye") <= 2 
        and target:getMark("&ny_10th_tongye") > 0 then return 3 end
        return 0
    end,
}

ny_10th_changqu = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_10th_changqu",
    view_as = function(self)
        return ny_10th_changquCard:clone()
    end,
    enabled_at_play = function(self, player)
        return not player:hasUsed("#ny_10th_changqu")
    end,
}

ny_10th_changquCard = sgs.CreateSkillCard
{
    name = "ny_10th_changqu",
    filter = function(self, targets, to_select)
       return sgs.Self:isAdjacentTo(to_select) and #targets == 0
    end,
    on_use = function(self, room, source, targets)
        local room = source:getRoom()
        local move = 1
        if source:getNextAlive(1):objectName() ~= targets[1]:objectName() then move = room:getAlivePlayers():length() - 1 end

        if move > 0 then 
            room:setPlayerMark(source, "ny_10th_changqu_right", 1)
        else
            room:setPlayerMark(source, "ny_10th_changqu_right", 0)
        end

        local finish = room:askForPlayerChosen(source, room:getOtherPlayers(source), self:objectName(), "@ny_10th_changqu", false, false)
        local log = sgs.LogMessage()
        log.type = "$ny_10th_changqu_finish"
        log.to:append(finish)
        room:sendLog(log)

        local n = 0
        local now = targets[1]
        while(true) do
            local get_num = math.max(n,1)
            local prompt
            if now:objectName() == finish:objectName() then
                prompt = string.format("ny_10th_changqu_finish:%s::%d:", source:getGeneralName(), get_num)
            else
                prompt = string.format("ny_10th_changqu_move:%s::%d:",source:getGeneralName(), get_num)
            end
            local get = room:askForExchange(now, self:objectName(), get_num, get_num, false, prompt, true)
            if get and get:subcardsLength() > 0 then
                room:obtainCard(source, get, false)
                n = n + 1
                if now:objectName() ~= finish:objectName() then
                    now = now:getNextAlive(move)
                else
                    break
                end
            else
                room:addPlayerMark(now, "&ny_10th_changqu", get_num)
                local log2 = sgs.LogMessage()
                log2.type = "$ny_10th_changqu_willdamgage"
                log2.from = now
                log2.arg = get_num
                room:sendLog(log2)
                room:setPlayerChained(now, true)
                break
            end
        end
    end
}

ny_10th_changqu_damage = sgs.CreateTriggerSkill{
    name = "#ny_10th_changqu",
    events = {sgs.DamageInflicted},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local damage = data:toDamage()
        if damage.nature ~= sgs.DamageStruct_Normal then
            room:broadcastSkillInvoke("ny_10th_changqu")
            local log = sgs.LogMessage()
            log.type = "$ny_10th_changqu_damage"
            log.from = player
            log.arg = "ny_10th_changqu"
            log.arg2 = damage.damage
            log.arg3 = damage.damage + player:getMark("&ny_10th_changqu")
            room:sendLog(log)
            damage.damage= damage.damage + player:getMark("&ny_10th_changqu")
            room:setPlayerMark(player, "&ny_10th_changqu", 0)
            data:setValue(damage)
        end
    end,
    can_trigger = function(self, target)
        return target and target:getMark("&ny_10th_changqu") > 0
    end,
}

ny_10th_wangrui:addSkill(ny_10th_tongye)
ny_10th_wangrui:addSkill(ny_10th_tongye_maxcards)
ny_10th_wangrui:addSkill(ny_10th_tongye_range)
ny_10th_wangrui:addSkill(ny_10th_tongye_slash)
ny_10th_wangrui:addSkill(ny_10th_changqu)
ny_10th_wangrui:addSkill(ny_10th_changqu_damage)
extension:insertRelatedSkills("ny_10th_tongye","#ny_10th_tongye_maxcards")
extension:insertRelatedSkills("ny_10th_tongye","#ny_10th_tongye_range")
extension:insertRelatedSkills("ny_10th_tongye","#ny_10th_tongye_slash")
extension:insertRelatedSkills("ny_10th_changqu","#ny_10th_changqu_damage")

ny_10th_dongxie = sgs.General(extension, "ny_10th_dongxie", "qun", 4, false, false, false)

ny_10th_jiaoxia = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_10th_jiaoxia",
    response_pattern = "@@ny_10th_jiaoxia",
    view_as = function(self)
        local card = sgs.Sanguosha:getCard(sgs.Self:getMark("ny_10th_jiaoxia_card"))
        return card
    end,
    enabled_at_play = function(self, player)
        return false
    end,
}

ny_10th_jiaoxia_trigger = sgs.CreateTriggerSkill
{
    name = "ny_10th_jiaoxia",
    events = {sgs.EventPhaseStart,sgs.EventPhaseEnd,sgs.EventLoseSkill,sgs.Damage,sgs.CardFinished,sgs.CardUsed},
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = ny_10th_jiaoxia,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card:hasFlag("ny_10th_jiaoxia_damage") then
                room:setCardFlag(use.card, "-ny_10th_jiaoxia_damage")
                local card_id = use.card:getId()
                local card = sgs.Sanguosha:getCard(card_id)
                room:setPlayerMark(player, "ny_10th_jiaoxia_card", card_id)
                if card:isAvailable(player) then
                    room:askForUseCard(player, "@@ny_10th_jiaoxia", "@ny_10th_jiaoxia:"..card:objectName())
                    
                end
            end
        end
        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.EventPhaseStart then return false end
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("slash")) then
                room:broadcastSkillInvoke(self:objectName())
                room:setPlayerMark(player, "&ny_10th_jiaoxia-PlayClear", 1)
                if not player:hasSkill("ny_10th_jiaoxia_filter") then
                    room:acquireSkill(player, "ny_10th_jiaoxia_filter", false)
                end
                room:filterCards(player, player:getCards("h"), true)
            end
        end
        if event == sgs.EventPhaseEnd or event == sgs.EventLoseSkill then
            if event == sgs.EventPhaseEnd and player:getPhase() ~= sgs.Player_Play then return false end
            room:setPlayerMark(player, "&ny_10th_jiaoxia-PlayClear", 0)
            room:filterCards(player, player:getCards("h"), true)
        end
        if event == sgs.Damage then
            local damage = data:toDamage()
            if damage.card and damage.card:getSkillName() == "ny_10th_jiaoxia" then
                room:setCardFlag(damage.card, "ny_10th_jiaoxia_damage")
            end
        end
        if event == sgs.CardUsed then
            local use = data:toCardUse()
            if use.card:isKindOf("Slash") then
                for _,p in sgs.qlist(use.to) do
                    room:setPlayerMark(p, "ny_10th_jiaoxia_used-PlayClear", 1)
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_jiaoxia_filter = sgs.CreateFilterSkill{
    name = "ny_10th_jiaoxia_filter",
    view_filter = function(self, to_select)
        local room = sgs.Sanguosha:currentRoom()
		local place = room:getCardPlace(to_select:getEffectiveId())
        local player = room:getCardOwner(to_select:getEffectiveId())
		return (place == sgs.Player_PlaceHand) and player:getMark("&ny_10th_jiaoxia-PlayClear") > 0
    end,
    view_as = function(self, card)
        local slash = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber())
		slash:setSkillName("ny_10th_jiaoxia")
		local _card = sgs.Sanguosha:getWrappedCard(card:getId())
		_card:takeOver(slash)
		return _card
    end,
}

ny_10th_jiaoxia_buff = sgs.CreateTargetModSkill
{
    name = "#ny_10th_jiaoxia_buff",
    residue_func = function(self, from, card, to)
        if from:hasSkill("ny_10th_jiaoxia") and to and to:getMark("ny_10th_jiaoxia_used-PlayClear") == 0 then return 1000 end
        return 0
    end,
}

ny_10th_humei = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_10th_humei",
    tiansuan_type = "draw,give,recover",
    view_as = function(self)
        local cc = ny_10th_humeiCard:clone()
        cc:setUserString(sgs.Self:getTag("ny_10th_humei"):toString())
        return cc
    end,
    enabled_at_play = function(self, player)
        local choices = {"draw", "give", "recover"}
        for _,p in ipairs(choices) do
            if player:getMark("ny_10th_humei_tiansuan_remove_"..p.."-PlayClear") == 0 then
                return true
            end
        end
    end,
}

ny_10th_humeiCard = sgs.CreateSkillCard
{
    name = "ny_10th_humei",
    filter = function(self, targets, to_select)
        local choice = self:getUserString()
        if choice == "give" and to_select:isNude() then return false end
        if choice == "give" and to_select:objectName() == sgs.Self:objectName() then return false end
        if choice == "recover" and (not to_select:isWounded()) then return false end
        return to_select:getHp() <= sgs.Self:getMark("&ny_10th_humei-PlayClear") and #targets == 0
    end,
    on_effect = function(self, effect)
        local room = effect.from:getRoom()
        local choice = self:getUserString()
        room:setPlayerMark(effect.from, "ny_10th_humei_tiansuan_remove_"..choice.."-PlayClear", 1)
        if choice == "draw" then
            effect.to:drawCards(1, self:objectName())
        end
        if choice == "give" then
            local obtain = room:askForExchange(effect.to, self:objectName(), 1, 1, true, "@ny_10th_humei:"..effect.from:getGeneralName(), false)
            room:obtainCard(effect.from, obtain, false)
        end
        if choice == "recover" then
            room:recover(effect.to, sgs.RecoverStruct(effect.from, self, 1))
        end
    end
}

ny_10th_humei_damage = sgs.CreateTriggerSkill{
    name = "#ny_10th_humei_damage",
    events = {sgs.Damage},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        room:addPlayerMark(player, "&ny_10th_humei-PlayClear", 1)
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName()) 
        and target:isAlive() and target:getPhase() == sgs.Player_Play
    end,
}

ny_10th_dongxie:addSkill(ny_10th_jiaoxia_trigger)
ny_10th_dongxie:addSkill(ny_10th_jiaoxia)
ny_10th_dongxie:addSkill(ny_10th_jiaoxia_buff)
ny_10th_dongxie:addSkill(ny_10th_humei)
ny_10th_dongxie:addSkill(ny_10th_humei_damage)
extension:insertRelatedSkills("ny_10th_jiaoxia","ny_10th_jiaoxia_buff")
extension:insertRelatedSkills("ny_10th_humei","#ny_10th_humei_damage")

ny_10th_peiyuanshao = sgs.General(extension, "ny_10th_peiyuanshao", "qun", 4, true, false, false)

ny_10th_moyu = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_10th_moyu",
    view_as = function(self)
        return ny_10th_moyuCard:clone()
    end,
    enabled_at_play = function(self,player)
        return player:getMark("ny_10th_moyu_damage-Clear") == 0
    end
}

ny_10th_moyuCard = sgs.CreateSkillCard
{
    name = "ny_10th_moyu",
    filter = function(self, targets, to_select)
        return to_select:objectName() ~= sgs.Self:objectName() and (not to_select:isAllNude()) 
        and to_select:getMark("ny_10th_moyu_chosen-PlayClear") == 0 and #targets == 0
    end,
    on_effect = function(self, effect)
        local room = effect.from:getRoom()
        local card = room:askForCardChosen(effect.from, effect.to, "hej", self:objectName())
        room:obtainCard(effect.from, card, false)
        room:addPlayerMark(effect.from, "&ny_10th_moyu-Clear", 1)
        room:addPlayerMark(effect.to,"ny_10th_moyu_chosen-PlayClear", 1)
        local prompt = string.format("@ny_10th_moyu:%s::%s:", effect.from:getGeneralName(), effect.from:getMark("&ny_10th_moyu-Clear"))
        room:askForUseSlashTo(effect.to, effect.from, prompt, false, false, false, effect.from, self, "ny_10th_moyu_slash")
    end
}

ny_10th_moyu_damage = sgs.CreateTriggerSkill{
    name = "#ny_10th_moyu_damage",
    events = {sgs.DamageInflicted, sgs.Damaged},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.DamageInflicted then
            local damage = data:toDamage()
            if damage.card and damage.card:hasFlag("ny_10th_moyu_slash") then
                if player:getMark("&ny_10th_moyu-Clear") > 1 then
                    local log = sgs.LogMessage()
                    log.type = "$ny_10th_moyu_damage_add"
                    log.from = player
                    log.arg = "ny_10th_moyu"
                    log.arg2 = damage.damage
                    log.arg3 = damage.damage + player:getMark("&ny_10th_moyu-Clear") - 1
                    room:sendLog(log)

                    damage.damage = damage.damage + player:getMark("&ny_10th_moyu-Clear") - 1
                    data:setValue(damage)
                end
            end
        end
        if event == sgs.Damaged then
            local damage = data:toDamage()
            if damage.card and damage.card:hasFlag("ny_10th_moyu_slash") then
                if player:isAlive() then
                    room:setPlayerMark(player, "ny_10th_moyu_damage-Clear", 1)
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_peiyuanshao:addSkill(ny_10th_moyu)
ny_10th_peiyuanshao:addSkill(ny_10th_moyu_damage)
extension:insertRelatedSkills("ny_10th_moyu", "#ny_10th_moyu_damage")

ny_10th_sunlinluan = sgs.General(extension, "ny_10th_sunlinluan", "wu", 3, false, false, false)

ny_10th_lingyue = sgs.CreateTriggerSkill{
    name = "ny_10th_lingyue",
    events = {sgs.Damage, sgs.EventPhaseStart},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.Player_NotActive then return false end
            room:setTag("ny_10th_lingyue_damage", sgs.QVariant(0))
        end
        if event == sgs.Damage then
            local damage = data:toDamage()
            local sum = room:getTag("ny_10th_lingyue_damage"):toInt()
            if (not sum) or sum == 0 then sum = damage.damage 
            else sum = sum + damage.damage end
            room:setTag("ny_10th_lingyue_damage", sgs.QVariant(sum))

            if player:getMark("ny_10th_lingyue_first_lun") == 0 then
                room:setPlayerMark(player, "ny_10th_lingyue_first_lun", 1)
                local draw = 1
                if player:getPhase() == sgs.Player_NotActive then draw = sum end
                for _,p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
                    if p:isAlive() then
                        room:sendCompulsoryTriggerLog(p, self:objectName(), true, true)
                        p:drawCards(draw, self:objectName())
                        room:getThread():delay(500)
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_pandi_tenth = sgs.CreateViewAsSkill
{
    name = "ny_pandi_tenth",
    n = 99,
    response_pattern = "@@ny_pandi_tenth",
    view_filter = function(self, selected, to_select)
        if sgs.Self:hasFlag("ny_pandi_tenth_using") then
            if not sgs.Self:getHandcards():contains(to_select) then return false end
            if #selected >= 1 then return false end
            local target
            local others = sgs.Self:getAliveSiblings()
            for _,other in sgs.qlist(others) do
                if other:hasFlag("ny_pandi_tenth_target") then
                    target = other
                    break
                end
            end
            return to_select:isAvailable(target)
        end
        return false
    end,
    view_as = function(self, cards)
        if sgs.Self:hasFlag("ny_pandi_tenth_using") then
            if #cards == 1 then
                local cc = ny_pandi_tenth_useCard:clone()
                cc:addSubcard(cards[1])
                return cc
            end
        else
            if #cards == 0 then
                return ny_pandi_tenthCard:clone()
            end
        end
    end,
    enabled_at_play = function(self, player)
        return player:getMark("ny_pandi_tenth_notcard-PlayClear") == 0
    end,
}

ny_pandi_tenthCard = sgs.CreateSkillCard
{
    name = "ny_pandi_tenth",
    filter = function(self, targets, to_select)
        return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
        and to_select:getMark("ny_pandi_tenth_damage-Clear") == 0
    end,
    on_use = function(self, room, source, targets)
        local room = source:getRoom()

        room:setPlayerFlag(source, "ny_pandi_tenth_using")
        room:setPlayerFlag(targets[1], "ny_pandi_tenth_target")
        local use_card = room:askForUseCard(source, "@@ny_pandi_tenth", "@ny_pandi_tenth:"..targets[1]:getGeneralName())
        room:setPlayerFlag(source, "-ny_pandi_tenth_using")
        room:setPlayerFlag(targets[1], "-ny_pandi_tenth_target")

        if use_card then
            local realcard = use_card:getSubcards():first()
            realcard = sgs.Sanguosha:getCard(realcard)
            if realcard:targetFixed() then
                local usecardlog = sgs.LogMessage()
                usecardlog.type = "$ny_pandi_tenth_usecard_targetfixed"
                usecardlog.from = source
                usecardlog.to:append(targets[1])
                usecardlog.card_str = realcard:toString()
                room:sendLog(usecardlog)

                room:useCard(sgs.CardUseStruct(realcard, targets[1], sgs.SPlayerList(), false, self, source), true)
            else
                local useto = sgs.SPlayerList()
                for _,player in sgs.qlist(room:getAlivePlayers()) do
                    if player:hasFlag("ny_pandi_tenth_useto") then
                        room:setPlayerFlag(player, "-ny_pandi_tenth_useto")
                        useto:append(player)
                    end
                end

                local usecardlog = sgs.LogMessage()
                usecardlog.type = "$ny_pandi_tenth_usecard_nottargetfixed"
                usecardlog.from = source
                usecardlog.to = useto
                usecardlog.arg = targets[1]:getGeneralName()
                usecardlog.card_str = realcard:toString()
                room:sendLog(usecardlog)
                room:useCard(sgs.CardUseStruct(realcard, targets[1], useto, false, self, source), true)
            end
        end
        if not use_card then
            room:setPlayerMark(source, "ny_pandi_tenth_notcard-PlayClear", 1)
        end
    end
}

ny_pandi_tenth_useCard = sgs.CreateSkillCard
{
    name = "ny_pandi_tenth_use",
    will_throw = false,
    filter = function(self, targets, to_select, player) 
        local card = self:getSubcards():first()
        card = sgs.Sanguosha:getCard(card)
		if card and card:targetFixed() then
			return false
		end

        local target
        local others = sgs.Self:getAliveSiblings()
        for _,other in sgs.qlist(others) do
            if other:hasFlag("ny_pandi_tenth_target") then
                target = other
                break
            end
        end

		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		if card and card:targetFilter(qtargets, to_select, target) and not target:isProhibited(to_select, card, qtargets) then
            return true
        end
        return false 
	end,
    target_fixed = function(self)		
		local card = self:getSubcards():first()
        card = sgs.Sanguosha:getCard(card)
        if card and card:targetFixed() then
            return true
        end
        return false
	end,
	feasible = function(self, targets)	
		local card = self:getSubcards():first()
        card = sgs.Sanguosha:getCard(card)

        local target
        local others = sgs.Self:getAliveSiblings()
        for _,other in sgs.qlist(others) do
            if other:hasFlag("ny_pandi_tenth_target") then
                target = other
                break
            end
        end

		local qtargets = sgs.PlayerList()
		for _,p in ipairs(targets) do
			qtargets:append(p)
		end
		if card and card:targetsFeasible(qtargets, target) then
            return true
        end
        return false
	end,
    on_use = function(self, room, source, targets)
        local room = source:getRoom()
        for _,player in ipairs(targets) do
            room:setPlayerFlag(player, "ny_pandi_tenth_useto")
        end
    end,
}

ny_pandi_tenth_damage = sgs.CreateTriggerSkill{
    name = "#ny_pandi_tenth_damage",
    events = {sgs.Damage},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        room:setPlayerMark(player, "ny_pandi_tenth_damage-Clear", 1)
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_10th_sunlinluan:addSkill(ny_10th_lingyue)
ny_10th_sunlinluan:addSkill(ny_pandi_tenth)
ny_10th_sunlinluan:addSkill(ny_pandi_tenth_damage)
extension:insertRelatedSkills("ny_pandi_tenth", "#ny_pandi_tenth_damage")

ny_10th_lelin = sgs.General(extension, "ny_10th_lelin", "wei", 4, true, false, false)

ny_tenth_poruiVS = sgs.CreateViewAsSkill
{
    name = "ny_tenth_porui",
    n = 1,
    response_pattern = "@@ny_tenth_porui",
    view_filter = function(self, selected, to_select)
        return #selected == 0
    end,
    view_as = function(self, cards)
        if #cards == 1 then 
            local cc = ny_tenth_poruiCard:clone()
            cc:addSubcard(cards[1])
            return cc
        end
    end,
    enabled_at_play = false,
}

ny_tenth_poruiCard = sgs.CreateSkillCard
{
    name = "ny_tenth_porui",
    will_throw = true,
    filter = function(self, targets, to_select)
        return to_select:objectName() ~= sgs.Self:objectName() and to_select:getMark("&ny_tenth_porui-Clear") > 0
        and to_select:getPhase() == sgs.Player_NotActive
    end,
    on_use = function(self, room, source, targets)
        local room = source:getRoom()
        room:addPlayerMark(source, "ny_tenth_porui_used_lun", 1)
        local target = targets[1]
        local n = target:getMark("&ny_tenth_porui-Clear")
        n = math.min(n,5)
        for i = 1, n+1, 1 do
            if source:isDead() or target:isDead() then break end
            local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
            slash:setSkillName("_ny_tenth_porui")
            if not source:isProhibited(target, slash) then
                room:useCard(sgs.CardUseStruct(slash, source, target, true))
                room:getThread():delay(500)
            else
                break
            end
        end
        if source:isAlive() and target:isAlive() and source:getMark("ny_10th_gonghu_damage") == 0 then
            local prompt = string.format("ny_tenth_porui_give:%s::%s:", target:getGeneralName(), n)
            local give = room:askForExchange(source, self:objectName(), n, n, false, prompt, false)
            if give then
                room:obtainCard(target, give, false)
            end
        end
    end
}


ny_tenth_porui = sgs.CreateTriggerSkill{
    name = "ny_tenth_porui",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = ny_tenth_poruiVS,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:getPhase() ~= sgs.Player_Finish then return false end
        for _,p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
            if p:getPhase() ~= sgs.Player_Finish 
            and ((p:getMark("ny_tenth_porui_used_lun") < 1) 
            or (p:getMark("ny_tenth_porui_used_lun") < 2 and p:getMark("ny_10th_gonghu_lose") > 0)) then
                room:askForUseCard(p, "@@ny_tenth_porui", "@ny_tenth_porui")
            end
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_tenth_porui_lose = sgs.CreateTriggerSkill{
    name = "#ny_tenth_porui_lose",
    events = {sgs.CardsMoveOneTime},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local move = data:toMoveOneTime()
        if move.from and move.from:objectName() == player:objectName() then else return false end
        if move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip) then else return false end
        local num = move.card_ids:length()
        room:addPlayerMark(player, "&ny_tenth_porui-Clear", num, room:findPlayersBySkillName("ny_tenth_porui"))
    end,
    can_trigger = function(self, target)
        local room = target:getRoom()
        if room:getTag("FirstRound"):toBool() then return false end
        return target:getPhase() == sgs.Player_NotActive
    end,
}

ny_10th_gonghu = sgs.CreateTriggerSkill{
    name = "ny_10th_gonghu",
    events = {sgs.CardsMoveOneTime, sgs.Damage, sgs.Damaged, sgs.CardUsed, sgs.PreCardUsed},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardsMoveOneTime then
            if player:getMark("ny_10th_gonghu_lose") > 0 then return false end
            if player:getPhase() ~= sgs.Player_NotActive then return false end
            local move = data:toMoveOneTime()
            if move.from and move.from:objectName() == player:objectName() then else return false end
            if move.from_places:contains(sgs.Player_PlaceHand) then else return false end
            local n = player:getMark("ny_10th_gonghu_lose_count-Clear")
            for _,id in sgs.qlist(move.card_ids) do
                if sgs.Sanguosha:getCard(id):isKindOf("BasicCard") then
                    n = n + 1
                end
                if n >= 2 then break end
            end
            if n >= 2 then
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                room:addPlayerMark(player, "ny_10th_gonghu_lose", 1)
                if player:getMark("ny_10th_gonghu_damage") == 0 then
                    room:changeTranslation(player, "ny_tenth_porui", 1)
                else
                    room:changeTranslation(player, "ny_tenth_porui", 3)
                end
            else
                room:setPlayerMark(player, "ny_10th_gonghu_lose_count-Clear", n)
            end
        end
        if event == sgs.Damage or event == sgs.Damaged then
            if player:getMark("ny_10th_gonghu_damage") > 0 then return false end
            local n = player:getMark("ny_10th_gonghu_damage_count-Clear")
            local damage = data:toDamage()
            n = n + damage.damage
            if n >= 2 then
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                room:addPlayerMark(player, "ny_10th_gonghu_damage", 1)
                if player:getMark("ny_10th_gonghu_lose") == 0 then
                    room:changeTranslation(player, "ny_tenth_porui", 2)
                else
                    room:changeTranslation(player, "ny_tenth_porui", 3)
                end
            else
                room:setPlayerMark(player, "ny_10th_gonghu_damage_count-Clear", n)
            end
        end
        if event == sgs.CardUsed then
            if player:getMark("ny_10th_gonghu_damage") == 0
            or player:getMark("ny_10th_gonghu_lose") == 0 then return false end
            local use = data:toCardUse()
            if use.card:isKindOf("BasicCard") and use.card:isRed() then
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)

                local log = sgs.LogMessage()
                log.type = "$ny_10th_gonghu_noresponse"
                log.from = player
                log.arg = self:objectName()
                log.card_str = use.card:toString()
                room:sendLog(log)

                local no_respond_list = use.no_respond_list
                table.insert(no_respond_list, "_ALL_TARGETS")
                use.no_respond_list = no_respond_list
                data:setValue(use)
            end
        end
        if event == sgs.PreCardUsed then
            if player:getMark("ny_10th_gonghu_damage") == 0
            or player:getMark("ny_10th_gonghu_lose") == 0 then return false end
            local use = data:toCardUse()
            if use.card:isKindOf("TrickCard") and use.card:isRed() and use.card:isNDTrick() then
                local targets = room:getCardTargets(player, use.card, use.to)
                if not targets:isEmpty() then
                    room:setPlayerMark(player, "ny_10th_gonghu_card", use.card:getId())

                    local target = room:askForPlayerChosen(player, targets, self:objectName(), "@ny_10th_gonghu:"..use.card:objectName(), true, false)
                    if target then 
                        room:broadcastSkillInvoke(self:objectName())
                        use.to:append(target)
                        data:setValue(use)
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName()) and target:isAlive()
    end,
}

ny_10th_lelin:addSkill(ny_tenth_porui)
ny_10th_lelin:addSkill(ny_tenth_poruiVS)
ny_10th_lelin:addSkill(ny_tenth_porui_lose)
ny_10th_lelin:addSkill(ny_10th_gonghu)
extension:insertRelatedSkills("ny_tenth_porui", "#ny_tenth_porui_lose")

ny_10th_duyu = sgs.General(extension, "ny_10th_duyu", "wei", 4, true, false, false)

ny_10th_jianguo = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_10th_jianguo",
    view_as = function(self)
        return ny_10th_jianguoCard:clone()
    end,
    enabled_at_play = function(self, player)
        return not player:hasUsed("#ny_10th_jianguo")
    end,
}

ny_10th_jianguoCard = sgs.CreateSkillCard
{
    name = "ny_10th_jianguo",
    filter = function(self, targets, to_select)
        return #targets == 0
    end,
    on_effect = function(self, effect)
        local room = effect.from:getRoom()
        local choices = "draw+dis"
        local _data = sgs.QVariant()
        _data:setValue(effect.to)
        local choice = room:askForChoice(effect.from, self:objectName(), choices, _data)
        if choice == "draw" then
            room:askForDiscard(effect.to, self:objectName(), 1, 1, false, true)
            if effect.to:isAlive() then
                effect.to:drawCards(math.floor(effect.to:getHandcardNum()/2), self:objectName())
            end
        elseif choice == "dis" then
            effect.to:drawCards(1, self:objectName())
            if effect.to:isAlive() then
                room:askForDiscard(effect.to, self:objectName(), math.floor(effect.to:getHandcardNum()/2), math.floor(effect.to:getHandcardNum()/2), false, false)
            end
        end
    end
}

ny_10th_qinshi = sgs.CreateTriggerSkill{
    name = "ny_10th_qinshi",
    events = {sgs.CardUsed, sgs.CardResponded,sgs.TargetConfirmed},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event ~= sgs.TargetConfirmed then
            local card = nil
            if event == sgs.CardUsed then
                card = data:toCardUse().card
            else
                local response = data:toCardResponse()
                if response.m_isUse then
                    card = response.m_card
                end
            end
            if card and (not card:isKindOf("SkillCard")) then
                room:addPlayerMark(player, "&ny_10th_qinshi-Clear", 1)
            end
        end
        if event == sgs.TargetConfirmed then
            if player:getMark("&ny_10th_qinshi-Clear") ~= player:getHandcardNum() then return false end
            local targets = sgs.SPlayerList()
            local use = data:toCardUse()
            if use.from:objectName() ~= player:objectName() then return false end
            if use.card:isKindOf("SkillCard") then return false end
            for _,p in sgs.qlist(use.to) do
                if p:objectName() ~= player:objectName() then
                    targets:append(p)
                end
            end
            if targets:isEmpty() then return false end
            local target = room:askForPlayerChosen(player, targets, self:objectName(), "@ny_10th_qinshi", true, true)
            if target then 
                room:broadcastSkillInvoke(self:objectName())
                room:damage(sgs.DamageStruct(self:objectName(), player, target, 1, sgs.DamageStruct_Normal))
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName()) and target:getPhase() ~= sgs.Player_NotActive
    end,
}

ny_10th_duyu:addSkill(ny_10th_jianguo)
ny_10th_duyu:addSkill(ny_10th_qinshi)

ny_10th_sunhanhua = sgs.General(extension, "ny_10th_sunhanhua", "wu", 3, false, false, false)

ny_10th_huiling = sgs.CreateTriggerSkill{
    name = "ny_10th_huiling",
    events = {sgs.CardUsed, sgs.CardResponded},
    frequency = sgs.Skill_Compulsory,
    waked_skills = "ny_10th_taji,ny_10th_qinghuang",
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local card = nil
        if event == sgs.CardUsed then
            card = data:toCardUse().card
        else
            local response = data:toCardResponse()
            if response.m_isUse then
                card = response.m_card
            end
        end
        if card and (not card:isKindOf("SkillCard")) then else return false end
        local red = 0
        local black = 0
        for _,id in sgs.qlist(room:getDiscardPile()) do
            if sgs.Sanguosha:getCard(id):isRed() then
                red = red + 1
            elseif sgs.Sanguosha:getCard(id):isBlack() then
                black = black + 1
            end
        end
        if red > black then
            if player:isWounded() then
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                room:recover(player, sgs.RecoverStruct(player, nil, 1))
            end
            if card:isBlack() then
                room:addPlayerMark(player, "&ny_10th_huiling_ling", 1)
            end
        elseif black > red then
            local targets = sgs.SPlayerList()
            for _,p in sgs.qlist(room:getOtherPlayers(player)) do
                if not p:isNude() then
                    targets:append(p)
                end
            end
            if not targets:isEmpty() then
                local target = room:askForPlayerChosen(player, targets, self:objectName(), "@ny_10th_huiling", true, true)
                if target then
                    room:broadcastSkillInvoke(self:objectName())
                    local dis = room:askForCardChosen(player, target, "he", self:objectName())
                    room:throwCard(dis, target, player)
                end
            end
            if card:isRed() then
                room:addPlayerMark(player, "&ny_10th_huiling_ling", 1)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_chongxu = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_10th_chongxu",
    frequency = sgs.Skill_Limited,
    limit_mark = "@ny_10th_chongxu_mark",
    view_as = function(self)
        return ny_10th_chongxuCard:clone()
    end,
    enabled_at_play = function(self, player)
        return player:getMark("&ny_10th_huiling_ling") >= 4 and player:getMark("@ny_10th_chongxu_mark") > 0
    end,
}

ny_10th_chongxuCard = sgs.CreateSkillCard
{
    name = "ny_10th_chongxu",
    target_fixed = true,
    on_use = function(self, room, source, targets)
        local room = source:getRoom()
        room:setPlayerMark(source, "@ny_10th_chongxu_mark", 0)
        room:detachSkillFromPlayer(source, "ny_10th_huiling")
        room:gainMaxHp(source, source:getMark("&ny_10th_huiling_ling"), self:objectName())
        room:setPlayerMark(source, "&ny_10th_huiling_ling", 0)--清除所有“灵”，防止ai反复使用此技能
        room:acquireSkill(source, "ny_10th_taji", true)
        room:acquireSkill(source, "ny_10th_qinghuang", true)
    end
}

ny_10th_taji = sgs.CreateTriggerSkill{
    name = "ny_10th_taji",
    events = {sgs.CardsMoveOneTime, sgs.DamageCaused},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardsMoveOneTime then
            local move = data:toMoveOneTime()
            if move.from and move.from:objectName() == player:objectName()
            and move.from_places:contains(sgs.Player_PlaceHand) then else return false end
            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)

            local all = {"use", "response", "discard", "other"}
            local now = {}

            if (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_USE) then
                table.removeOne(all, "use")
                table.insert(now, "use")
            elseif (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_RESPONSE) then
                table.removeOne(all, "response")
                table.insert(now, "response")
            elseif (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD) then
                table.removeOne(all, "discard")
                table.insert(now, "discard")
            else
                table.removeOne(all, "other")
                table.insert(now, "other")
            end

            if player:getMark("&ny_10th_qinghuang-PlayClear") > 0 then
                room:sendCompulsoryTriggerLog(player, "ny_10th_qinghuang", true)
                local add = all[math.random(1,#all)]
                table.insert(now, add)

                local log = sgs.LogMessage()
                log.type = "$ny_10th_qinghuang_add"
                log.from = player
                log.arg = "ny_10th_taji:"..add
                room:sendLog(log)
            end

            for _,p in ipairs(now) do
                if p == "use" then
                    local targets = sgs.SPlayerList()
                    for _,p in sgs.qlist(room:getOtherPlayers(player)) do
                        if not p:isNude() then
                            targets:append(p)
                        end
                    end
                    if not targets:isEmpty() then
                        local target = room:askForPlayerChosen(player, targets, self:objectName(), "@ny_10th_taji", true, true)
                        if target then
                            room:broadcastSkillInvoke(self:objectName())
                            local dis = room:askForCardChosen(player, target, "he", self:objectName())
                            room:throwCard(dis, target, player)
                        end
                    end
                end
                if p == "response" then
                    player:drawCards(1, self:objectName())
                end
                if p == "discard" then
                    if player:isWounded() then
                        room:recover(player, sgs.RecoverStruct(player, nil, 1))
                    end
                end
                if p == "other" then
                    room:addPlayerMark(player, "&ny_10th_taji", 1)
                end
            end
        end
        if event == sgs.DamageCaused then
            if player:getMark("&ny_10th_taji") == 0 then return false end
            local damage = data:toDamage()
            if damage.to:objectName() ~= player:objectName() then
                local log = sgs.LogMessage()
                log.type = "$ny_10th_taji_damage"
                log.from = player
                log.to:append(damage.to)
                log.arg = self:objectName()
                log.arg2 = damage.damage
                log.arg3 = damage.damage + player:getMark("&ny_10th_taji")
                room:sendLog(log)

                room:broadcastSkillInvoke(self:objectName())
                damage.damage = damage.damage + player:getMark("&ny_10th_taji")
                room:setPlayerMark(player, "&ny_10th_taji", 0)
                data:setValue(damage)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_qinghuang = sgs.CreateTriggerSkill{
    name = "ny_10th_qinghuang",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:getPhase() == sgs.Player_Play then
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("invoke")) then
                room:broadcastSkillInvoke(self:objectName())
                room:setPlayerMark(player, "&ny_10th_qinghuang-PlayClear", 1)
                room:loseMaxHp(player, 1)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_sunhanhua:addSkill(ny_10th_huiling)
ny_10th_sunhanhua:addSkill(ny_10th_chongxu)
--[[
ny_10th_huiling_record = sgs.CreateTriggerSkill{
    name = "#ny_10th_huiling_record",
    events = {sgs.CardsMoveOneTime,sgs.EventLoseSkill},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local marks = {"&ny_10th_huiling_red", "&ny_10th_huiling_black", "&ny_10th_huiling_same"}
        if event == sgs.EventLoseSkill then
            if data:toString() == "ny_10th_huiling" then
                for _,mark in ipairs(marks) do
                    room:setPlayerMark(player, mark, 0)
                end
            end
            return false
        end
        local move = data:toMoveOneTime()
        if move.to_place == sgs.Player_DiscardPile or move.from_places:contains(sgs.Player_DiscardPile) then else return false end
        local red = 0
        local black = 0
        for _,id in sgs.qlist(room:getDiscardPile()) do
            local card = sgs.Sanguosha:getCard(id)
            if card:isRed() then
                red = red + 1
            elseif card:isBlack() then
                black = black + 1
            end
        end
        for _,mark in ipairs(marks) do
            room:setPlayerMark(player, mark, 0)
        end
        if red > black then 
            room:setPlayerMark(player, "&ny_10th_huiling_red", 1)
        elseif red < black then
            room:setPlayerMark(player, "&ny_10th_huiling_black", 1)
        else
            room:setPlayerMark(player, "&ny_10th_huiling_same", 1)
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill("ny_10th_huiling")
    end,
}

ny_10th_sunhanhua:addSkill(ny_10th_huiling_record)
extension:insertRelatedSkills("ny_10th_huiling", "#ny_10th_huiling_record")

sgs.LoadTranslationTable{
    ["ny_10th_huiling_red"] = "红色较多",
    ["ny_10th_huiling_black"] = "黑色较多",
    ["ny_10th_huiling_same"] = "红黑相等",
}
]]--
ny_10th_chentai = sgs.General(extension, "ny_10th_chentai", "wei", 4, true, false, false)

ny_10th_jiuxian = sgs.CreateViewAsSkill
{
    name = "ny_10th_jiuxian",
    n = 999,
    view_filter = function(self, selected, to_select)
        return sgs.Self:getHandcards():contains(to_select)
        and #selected < math.ceil(sgs.Self:getHandcardNum()/2)
    end,
    view_as = function(self, cards)
        if #cards > 0 and #cards == math.ceil(sgs.Self:getHandcardNum()/2) then
            local cc = ny_10th_jiuxianCard:clone()
            for _,card in ipairs(cards) do
                cc:addSubcard(card)
            end
            return cc
        end
    end,
    enabled_at_play = function(self, player)
        return not player:hasUsed("#ny_10th_jiuxian")
    end,
}

ny_10th_jiuxianCard = sgs.CreateSkillCard
{
    name = "ny_10th_jiuxian",
    will_throw = false,
    handling_method = sgs.Card_MethodRecast,
    filter = function(self, targets, to_select, player)
        local qtargets = sgs.PlayerList()
        for _,p in ipairs(targets) do
            qtargets:append(p)
        end
    
        local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_SuitToBeDecided, -1)
        duel:setSkillName("ny_10th_jiuxian")

        duel:deleteLater()
        return duel and duel:targetFilter(qtargets, to_select, player) and not player:isProhibited(to_select, duel, qtargets)
    end,
    feasible = function(self, targets, player)
        local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_SuitToBeDecided, -1)
        duel:setSkillName("ny_10th_jiuxian")
        duel:deleteLater()
        local qtargets = sgs.PlayerList()
        for _,p in ipairs(targets) do
            qtargets:append(p)
        end
        return duel and duel:targetsFeasible(qtargets, player)
    end,
    on_validate = function(self, cardUse)
        local source = cardUse.from
        local room = source:getRoom()

        local skill_log = sgs.LogMessage()
        skill_log.type = "#InvokeSkill"
        skill_log.from = source
        skill_log.arg = self:objectName()
        room:sendLog(skill_log)

        local log = sgs.LogMessage()
        log.from = source
        log.type = "$RecastCard"
        log.card_str = table.concat(sgs.QList2Table(self:getSubcards()), "+")
        room:sendLog(log)

        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECAST, source:objectName(), self:objectName(), "")
        room:moveCardTo(self, nil, nil, sgs.Player_DiscardPile, reason)

        source:drawCards(self:subcardsLength(), "recast")

        local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_SuitToBeDecided, -1)
        duel:setSkillName("_ny_10th_jiuxian")
        return duel
    end,
}

ny_10th_jiuxian_buff = sgs.CreateTriggerSkill{
    name = "#ny_10th_jiuxian_buff",
    events = {sgs.TargetConfirmed, sgs.Damage},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.TargetConfirmed then
            local use = data:toCardUse()
            if use.card:isKindOf("Duel") and use.card:getSkillName() == "ny_10th_jiuxian" then
                local names = {}
                for _,p in sgs.qlist(use.to) do
                    room:setCardFlag(use.card, "ny_10th_jiuxian_target_"..p:objectName())
                end
            end
        end
        if event == sgs.Damage then
            local damage = data:toDamage()
            if damage.card and damage.card:hasFlag("ny_10th_jiuxian_target_"..damage.to:objectName()) then
                local targets = sgs.SPlayerList()
                for _,p in sgs.qlist(room:getOtherPlayers(damage.to)) do
                    if p:isWounded() and damage.to:inMyAttackRange(p) and p:objectName() ~= player:objectName() then
                        targets:append(p)
                    end
                end
                if not targets:isEmpty() then
                    local target = room:askForPlayerChosen(player, targets, "ny_10th_jiuxian", 
                    "@ny_10th_jiuxian:"..damage.to:getGeneralName(), true, true)
                    if target then
                        room:broadcastSkillInvoke("ny_10th_jiuxian")
                        room:recover(target, sgs.RecoverStruct(player, nil, 1))
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_chenyong = sgs.CreateTriggerSkill{
    name = "ny_10th_chenyong",
    events = {sgs.CardUsed, sgs.CardResponded, sgs.EventPhaseStart},
    frequency = sgs.Skill_Frequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event ~= sgs.EventPhaseStart then
            local card = nil
            if event == sgs.CardUsed then
                card = data:toCardUse().card
            elseif event == sgs.CardResponded then
                local respose = data:toCardResponse()
                if respose.m_isUse then
                    card = respose.m_card
                end
            end
            if (not card) or (card:isKindOf("SkillCard")) then return false end
            local types = {"BasicCard", "TrickCard", "EquipCard"}
            for _,cardtype in ipairs(types) do
                if card:isKindOf(cardtype) and player:getMark("ny_10th_chenyong_"..cardtype.."-Clear") == 0 then
                    room:setPlayerMark(player, "ny_10th_chenyong_"..cardtype.."-Clear", 1)
                    room:addPlayerMark(player, "&ny_10th_chenyong-Clear", 1)
                end
            end
        end

        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.Player_Finish then return false end
            if player:getMark("&ny_10th_chenyong-Clear") <= 0 then return false end
            local prompt = string.format("draw:%s:", player:getMark("&ny_10th_chenyong-Clear"))
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant(prompt)) then
                room:broadcastSkillInvoke(self:objectName())
                player:drawCards(player:getMark("&ny_10th_chenyong-Clear"), self:objectName())
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName()) and target:getPhase() ~= sgs.Player_NotActive
    end,
}

ny_10th_chentai:addSkill(ny_10th_jiuxian)
ny_10th_chentai:addSkill(ny_10th_jiuxian_buff)
ny_10th_chentai:addSkill(ny_10th_chenyong)
extension:insertRelatedSkills("ny_10th_jiuxian", "#ny_10th_jiuxian_buff")

ny_10th_huanfan = sgs.General(extension, "ny_10th_huanfan", "wei", 3, true, false, false)

ny_10th_fumou = sgs.CreateTriggerSkill{
    name = "ny_10th_fumou",
    events = {sgs.Damaged},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local n = player:getLostHp()
        local targets = room:askForPlayersChosen(player, room:getAlivePlayers(),
        self:objectName(), 0, n, "@ny_10th_fumou:"..n, true, true)
        if targets and (not targets:isEmpty()) then
            room:broadcastSkillInvoke(self:objectName())
            for _,target in sgs.qlist(targets) do
                local choices = {"discard"}
                local cant = {}
                if (not target:getEquips():isEmpty()) and target:isWounded() then
                    table.insert(choices, "recover")
                else
                    table.insert(cant, "recover")
                end
                if room:canMoveField("ej") then
                    table.insert(choices, "move")
                else
                    table.insert(cant, "move")
                end
                local choice = room:askForChoice(target, self:objectName(), table.concat(choices, "+"), sgs.QVariant(), table.concat(cant, "+"), nil)
                
                local chosenlog = sgs.LogMessage()
                chosenlog.type = "$ny_10th_fumou_chosen"
                chosenlog.from = target
                chosenlog.arg = "ny_10th_fumou:"..choice
                room:sendLog(chosenlog)
                
                if choice == "discard" then
                    local num = target:getHandcardNum()
                    room:askForDiscard(target, self:objectName(), num, num, false, false)
                    target:drawCards(2, self:objectName())
                end
                if choice == "move" then
                    room:moveField(target, self:objectName(), true, "ej")
                end
                if choice == "recover" then
                    local equips = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, -1)
                    equips:deleteLater()
                    equips:addSubcards(target:getEquipsId())

                    local log = sgs.LogMessage()
                    log.type = "$DiscardCard"
                    log.from = target
                    log.card_str = table.concat(sgs.QList2Table(target:getEquipsId()), "+")
                    room:sendLog(log)

                    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISCARD, target:objectName(), self:objectName(), "")
                    room:moveCardTo(equips, nil, nil, sgs.Player_DiscardPile, reason)
                    room:recover(target, sgs.RecoverStruct(player, nil, 1))
                end
            end
        end         
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName()) and target:isAlive()
    end,
}

ny_tenth_jianzheng = sgs.CreateViewAsSkill
{
    name = "ny_tenth_jianzheng",
    n = 99,
    response_pattern = "@@ny_tenth_jianzheng",
    expand_pile = "#ny_tenth_jianzheng",
    view_filter = function(self, selected, to_select)
        if sgs.Self:hasFlag("ny_tenth_jianzheng_using") then
            if not sgs.Self:getPile("#ny_tenth_jianzheng"):contains(to_select:getId()) then return false end
            if #selected >= 1 then return false end
            return to_select:isAvailable(sgs.Self)
        end
        return false
    end,
    view_as = function(self, cards)
        if sgs.Self:hasFlag("ny_tenth_jianzheng_using") then
            if #cards == 1 then
                local cc = ny_tenth_jianzheng_useCard:clone()
                cc:addSubcard(cards[1])
                return cc
            end
        else
            if #cards == 0 then
                return ny_tenth_jianzhengCard:clone()
            end
        end
    end,
    enabled_at_play = function(self, player)
        return not player:hasUsed("#ny_tenth_jianzheng")
    end,
}

ny_tenth_jianzhengCard = sgs.CreateSkillCard
{
    name = "ny_tenth_jianzheng",
    filter = function(self, targets, to_select)
        return #targets < 1 and to_select:objectName() ~= sgs.Self:objectName() and (not to_select:isKongcheng())
    end,
    on_use = function(self, room, source, targets)
        local room = source:getRoom()

        local view_cards = sgs.IntList()
        for _,card in sgs.qlist(targets[1]:getHandcards()) do
            view_cards:append(card:getId())
        end

        local view_log_forself = sgs.LogMessage()
        view_log_forself.type = "$ViewAllCards"
        view_log_forself.from = source
        view_log_forself.to:append(targets[1])
        view_log_forself.card_str = table.concat(sgs.QList2Table(view_cards), "+")
        room:sendLog(view_log_forself, source)

        local view_log_forothers = sgs.LogMessage()
        view_log_forothers.type = "#ViewAllCards"
        view_log_forothers.from = source
        view_log_forothers.to:append(targets[1])
        room:sendLog(view_log_forothers, room:getOtherPlayers(source))

        room:setPlayerFlag(source, "ny_tenth_jianzheng_using")
        room:notifyMoveToPile(source, view_cards, "ny_tenth_jianzheng", sgs.Player_PlaceHand, true)
        room:setPlayerFlag(targets[1], "ny_tenth_jianzheng_target")
        local use_card = room:askForUseCard(source, "@@ny_tenth_jianzheng", "@ny_tenth_jianzheng:"..targets[1]:getGeneralName())
        room:setPlayerFlag(targets[1], "-ny_tenth_jianzheng_target")
        room:notifyMoveToPile(source, view_cards, "ny_tenth_jianzheng", sgs.Player_PlaceHand, false)
        room:setPlayerFlag(source, "-ny_tenth_jianzheng_using")

        if use_card then
            local realcard = use_card:getSubcards():first()
            realcard = sgs.Sanguosha:getCard(realcard)
            local owner = room:getCardOwner(realcard:getId())
            if realcard:targetFixed() then
                local usecardlog = sgs.LogMessage()
                usecardlog.type = "$ny_tenth_jianzheng_usecard_targetfixed"
                usecardlog.from = source
                usecardlog.arg = owner:getGeneralName()
                usecardlog.card_str = realcard:toString()
                room:sendLog(usecardlog)

                for _,player in sgs.qlist(room:getAlivePlayers()) do
                    if player:hasFlag("ny_tenth_jianzheng_useto") then
                        room:setPlayerFlag(player, "-ny_tenth_jianzheng_useto")
                    end
                end
                room:obtainCard(source, realcard, true)
                room:setCardFlag(realcard, "ny_tenth_jianzheng_card")
                room:setPlayerFlag(targets[1], "ny_tenth_jianzheng_target")
                room:useCard(sgs.CardUseStruct(realcard, source, sgs.SPlayerList(), false, self, source), true)
                room:setCardFlag(realcard, "-ny_tenth_jianzheng_card")
                room:setPlayerFlag(targets[1], "-ny_tenth_jianzheng_target")
            else
                local useto = sgs.SPlayerList()
                for _,player in sgs.qlist(room:getAlivePlayers()) do
                    if player:hasFlag("ny_tenth_jianzheng_useto") then
                        room:setPlayerFlag(player, "-ny_tenth_jianzheng_useto")
                        useto:append(player)
                    end
                end

                local usecardlog = sgs.LogMessage()
                usecardlog.type = "$ny_tenth_jianzheng_usecard_nottargetfixed"
                usecardlog.from = source
                usecardlog.to = useto
                usecardlog.arg = targets[1]:getGeneralName()
                usecardlog.card_str = realcard:toString()
                room:sendLog(usecardlog)

                room:obtainCard(source, realcard, true)
                room:setCardFlag(realcard, "ny_tenth_jianzheng_card")
                room:setPlayerFlag(targets[1], "ny_tenth_jianzheng_target")
                room:useCard(sgs.CardUseStruct(realcard, source, useto, false, self, source), true)
                room:setCardFlag(realcard, "-ny_tenth_jianzheng_card")
                room:setPlayerFlag(targets[1], "-ny_tenth_jianzheng_target")
            end
        end
    end,
}

ny_tenth_jianzheng_useCard = sgs.CreateSkillCard
{
    name = "ny_tenth_jianzheng_use",
    will_throw = false,
    filter = function(self, targets, to_select, player) 
        local card = self:getSubcards():first()
        card = sgs.Sanguosha:getCard(card)
		if card and card:targetFixed() then
			return false
		end

        local target = sgs.Self

		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		if card and card:targetFilter(qtargets, to_select, target) and not target:isProhibited(to_select, card, qtargets) then
            return true
        end
        return false 
	end,
    target_fixed = function(self)		
		local card = self:getSubcards():first()
        card = sgs.Sanguosha:getCard(card)
        if card and card:targetFixed() then
            return true
        end
        return false
	end,
	feasible = function(self, targets)	
		local card = self:getSubcards():first()
        card = sgs.Sanguosha:getCard(card)

        local target = sgs.Self

		local qtargets = sgs.PlayerList()
		for _,p in ipairs(targets) do
			qtargets:append(p)
		end
		if card and card:targetsFeasible(qtargets, target) then
            return true
        end
        return false
	end,
    on_use = function(self, room, source, targets)
        local room = source:getRoom()
        for _,player in ipairs(targets) do
            room:setPlayerFlag(player, "ny_tenth_jianzheng_useto")
        end
    end,
}

ny_tenth_jianzheng_buff = sgs.CreateTriggerSkill{
    name = "#ny_tenth_jianzheng",
    events = {sgs.TargetConfirmed},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local use = data:toCardUse()
        if use.card:hasFlag("ny_tenth_jianzheng_card") then
            for _,p in sgs.qlist(use.to) do
                if p:hasFlag("ny_tenth_jianzheng_target") then
                    room:setPlayerChained(player, true)
                    room:setPlayerChained(p, true)

                    local log = sgs.LogMessage()
                    log.type = "#ViewAllCards"
                    log.from = p
                    log.to:append(player)
                    room:sendLog(log)

                    room:showAllCards(player, p)
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_huanfan:addSkill(ny_10th_fumou)
ny_10th_huanfan:addSkill(ny_tenth_jianzheng)
ny_10th_huanfan:addSkill(ny_tenth_jianzheng_buff)
extension:insertRelatedSkills("ny_tenth_jianzheng", "#ny_tenth_jianzheng_buff")

ny_10th_yuecaiwenji = sgs.General(extension, "ny_10th_yuecaiwenji", "qun", 3, false, false, false)

ny_10th_shuangjia = sgs.CreateTriggerSkill{
    name = "ny_10th_shuangjia",
    events = {sgs.GameStart, sgs.CardsMoveOneTime,sgs.EventPhaseChanging},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.GameStart then
            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
            local n = 0
            for _,card in sgs.qlist(player:getHandcards()) do
                room:setCardFlag(card, "ny_10th_hujia")
                room:setCardTip(card:getId(), "ny_10th_hujia")
                n = n + 1
            end
            room:setPlayerMark(player, "&ny_10th_shuangjia", n)
        end
        if event == sgs.CardsMoveOneTime then
            if player:getMark("&ny_10th_shuangjia") == 0 then return false end
            local move = data:toMoveOneTime()
            if move.from and move.from:objectName() == player:objectName() then else return false end
            local n = 0
            for _,card in sgs.qlist(player:getHandcards()) do
                if card:hasFlag("ny_10th_hujia") then n = n + 1 end
            end
            room:setPlayerMark(player, "&ny_10th_shuangjia", n)
        end
        if event == sgs.EventPhaseChanging then
            if player:getMark("&ny_10th_shuangjia") == 0 then return false end
            local change = data:toPhaseChange()
            if change.to ~= sgs.Player_Discard then return false end
            for _,card in sgs.qlist(player:getHandcards()) do
                if card:hasFlag("ny_10th_hujia") then room:ignoreCards(player, card) end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_shuangjia_distance = sgs.CreateDistanceSkill{
    name = "#ny_10th_shuangjia_distance",
    correct_func = function(self, from, to)
        if to:hasSkill("ny_10th_shuangjia") then 
            return math.min(to:getMark("&ny_10th_shuangjia"), 5)
        end
        return 0
    end,
}

ny_10th_beifen = sgs.CreateTriggerSkill
{
    name = "ny_10th_beifen",
    events = {sgs.CardsMoveOneTime},
    frequency = sgs.Skill_Compulsory,
    priority = 99,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardsMoveOneTime then
            if player:getMark("&ny_10th_shuangjia") == 0 then return false end
            local move = data:toMoveOneTime()
            if move.from and move.from:objectName() == player:objectName() then else return false end
            if move.from_places:contains(sgs.Player_PlaceHand) then else return false end
            local will_invoke = false
            for _,id in sgs.qlist(move.card_ids) do
                if sgs.Sanguosha:getCard(id):hasFlag("ny_10th_hujia") then 
                    will_invoke = true
                    break
                end
            end
            if not will_invoke then return false end
            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
            local suits = {}
            local get = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, -1)
            get:deleteLater()
            local n = 0
            for _,card in sgs.qlist(player:getHandcards()) do
                if card:hasFlag("ny_10th_hujia") then
                    n = n + 1
                    if not table.contains(suits, card:getSuitString()) then
                        table.insert(suits, card:getSuitString())
                    end
                end
            end
            room:setPlayerMark(player, "&ny_10th_shuangjia", n)

            for _,id in sgs.qlist(room:getDrawPile()) do
                local card = sgs.Sanguosha:getCard(id)
                if not table.contains(suits, card:getSuitString()) then
                    table.insert(suits, card:getSuitString())
                    get:addSubcard(card)
                end
            end
            if get:subcardsLength() > 0 then
                room:obtainCard(player, get, true)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_beifen_buff = sgs.CreateTargetModSkill{
    name = "#ny_10th_beifen_buff",
    pattern = ".",
    residue_func = function(self, from, card)
        if from:hasSkill("ny_10th_beifen") and from:getMark("&ny_10th_shuangjia")*2 < from:getHandcardNum() then return 1000 end
        return 0
    end,
    distance_limit_func = function(self, from, card)
        if from:hasSkill("ny_10th_beifen") and from:getMark("&ny_10th_shuangjia")*2 < from:getHandcardNum() then return 1000 end
        return 0
    end,
}

ny_10th_yuecaiwenji:addSkill(ny_10th_shuangjia)
ny_10th_yuecaiwenji:addSkill(ny_10th_shuangjia_distance)
ny_10th_yuecaiwenji:addSkill(ny_10th_beifen)
ny_10th_yuecaiwenji:addSkill(ny_10th_beifen_buff)
extension:insertRelatedSkills("ny_10th_shuangjia", "#ny_10th_shuangjia_distance")
extension:insertRelatedSkills("ny_10th_beifen", "#ny_10th_beifen_buff")

ny_10th_yuanji = sgs.General(extension, "ny_10th_yuanji", "wu", 3, false, false, false)

ny_10th_fangdu = sgs.CreateTriggerSkill{
    name = "ny_10th_fangdu",
    events = {sgs.Damaged},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:getPhase() ~= sgs.Player_NotActive then return false end
        local damage = data:toDamage()
        if damage.nature == sgs.DamageStruct_Normal then
            if player:getMark("ny_10th_fangdu_normal-Clear") == 0 then
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                room:setPlayerMark(player, "ny_10th_fangdu_normal-Clear", 1)
                room:recover(player, sgs.RecoverStruct(player, nil, 1))
            end
        else
            if player:getMark("ny_10th_fangdu_unnormal-Clear") == 0 then
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                room:setPlayerMark(player, "ny_10th_fangdu_unnormal-Clear", 1)
                if damage.from:objectName() ~= player:objectName() and ( not damage.from:isKongcheng()) then
                    local cards = sgs.QList2Table(damage.from:getHandcards())
                    room:obtainCard(player, cards[math.random(1, #cards)], false)
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName()) and target:isAlive()
    end,
}

ny_10th_jiexing = sgs.CreateTriggerSkill{
    name = "ny_10th_jiexing",
    events = {sgs.HpChanged,sgs.EventPhaseChanging},
    frequency = sgs.Skill_Frequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.HpChanged then
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("draw")) then
                room:broadcastSkillInvoke(self:objectName())
                local card_ids = player:drawCardsList(1, self:objectName())
                for _,id in sgs.qlist(card_ids) do
                    local card = sgs.Sanguosha:getCard(id)
                    room:setCardFlag(card, "ny_10th_jiexing")
                    room:setCardTip(id, "ny_10th_jiexing")
                end
            end
        end
        if event == sgs.EventPhaseChanging then
            local change = data:toPhaseChange()
            if change.to == sgs.Player_Discard then
                for _,card in sgs.qlist(player:getHandcards()) do
                    if card:hasFlag("ny_10th_jiexing") then room:ignoreCards(player, card) end
                end
            end
            if change.from == sgs.Player_NotActive or change.to == sgs.Player_NotActive then
                for _,card in sgs.qlist(player:getHandcards()) do
                    if card:hasFlag("ny_10th_jiexing") then 
                        room:setCardFlag(card, "-ny_10th_jiexing")
                        room:setCardTip(card:getId(), "-ny_10th_jiexing")
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_yuanji:addSkill(ny_10th_fangdu)
ny_10th_yuanji:addSkill(ny_10th_jiexing)

ny_10th_shenzhangjiao = sgs.General(extension, "ny_10th_shenzhangjiao", "god", 3, true, false, false)

ny_10th_yizhao = sgs.CreateTriggerSkill{
    name = "ny_10th_yizhao",
    events = {sgs.CardUsed,sgs.CardResponded},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local card
        local n = player:getMark("&ny_10th_huang")
        if event == sgs.CardUsed then
            local use = data:toCardUse()
            card = use.card
        end
        if event == sgs.CardResponded then
            local respond = data:toCardResponse()
            card = respond.m_card
        end
        if card:isKindOf("SkillCard") then return false end
        local num = card:getNumber()
        local m = n + num
        room:setPlayerMark(player, "&ny_10th_huang", m)
        if m < 10 then return false end
        local change = math.floor(m/10) - math.floor(n/10)
        if change == 0 then return false end
        room:sendCompulsoryTriggerLog(player, self:objectName())
        room:broadcastSkillInvoke(self:objectName())
        for _,id in sgs.qlist(room:getDrawPile()) do
            local get = sgs.Sanguosha:getCard(id)
            local can = math.floor(m/10)
            while(can > 10) do
                can = can - 10
            end
            if get:getNumber() == can then
                room:obtainCard(player, get, false)
                break
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_sijun = sgs.CreateTriggerSkill{
    name = "ny_10th_sijun",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:getPhase() ~= sgs.Player_Start then return false end
        local num = room:getDrawPile():length()
        if player:getMark("&ny_10th_huang") <= num then return false end 
        if not room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("draw")) then return false end
        room:broadcastSkillInvoke(self:objectName())

        local drawpile = sgs.Sanguosha:cloneCard("jink",sgs.Card_NoSuit,0)
        for _,id in sgs.qlist(room:getDrawPile()) do
            drawpile:addSubcard(id)
        end

        room:moveCardTo(drawpile, nil, sgs.Player_DiscardPile)
        drawpile:deleteLater()
        room:swapPile()

        room:setPlayerMark(player, "&ny_10th_huang", 0)
        local obtained = sgs.IntList()
        local n = 36
        for _,id in sgs.qlist(room:getDrawPile()) do
            local card = sgs.Sanguosha:getCard(id):getNumber()
            if card <= n then
                obtained:append(id)
                n = n - card
            end
            if n == 0 then break end
        end
        local dummy = sgs.Sanguosha:cloneCard("jink",sgs.Card_NoSuit,0)
        for _,id in sgs.qlist(obtained) do
            dummy:addSubcard(id)
        end
        player:obtainCard(dummy,false)
        dummy:deleteLater()
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_sanshou = sgs.CreateTriggerSkill{
    name = "ny_10th_sanshou",
    events = {sgs.DamageForseen},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if room:askForSkillInvoke(player, self:objectName(), data) then
            room:broadcastSkillInvoke(self:objectName())
            local can = false

            local types = room:getTag("ny_10th_sanshou_cardtypes"):toString():split("+")
            if (not types) then types = {} end
            local card_ids = room:getNCards(3)
            local reason1 = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), self:objectName(), "")
            local move1 = sgs.CardsMoveStruct(card_ids, nil, sgs.Player_PlaceTable, reason1)
            room:moveCardsAtomic(move1, true)

            for _,id in sgs.qlist(card_ids) do
                local find = false
                for _,ctype in ipairs(types) do
                    if sgs.Sanguosha:getCard(id):isKindOf(ctype) then 
                        find = true
                        break
                    end
                end
                if not find then 
                    can = true 
                    break
                end
            end

            if can then
                local damage = data:toDamage().damage
                local log = sgs.LogMessage()
                log.type = "$ny_10th_sanshou_damage"
                log.from = player
                log.arg = self:objectName()
                log.arg2 = damage
                room:sendLog(log)
            end

            local log = sgs.LogMessage()
            log.type = "$MoveToDiscardPile"
            log.from = player
            log.card_str = table.concat(sgs.QList2Table(card_ids), "+")
            room:sendLog(log)

            local reason2 = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), self:objectName(), "")
            local move2 = sgs.CardsMoveStruct(card_ids, nil, sgs.Player_DiscardPile, reason2)
            room:moveCardsAtomic(move2, true)

            return can
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_sanshou_record = sgs.CreateTriggerSkill{
    name = "#ny_10th_sanshou_record",
    events = {sgs.CardUsed, sgs.CardResponded, sgs.EventPhaseChanging},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardUsed or event == sgs.CardResponded then
            local card 
            if event == sgs.CardUsed then
                card = data:toCardUse().card
            else
                local response = data:toCardResponse()
                if response.m_isUse then
                    card = response.m_card
                end
            end
            if (not card) or card:isKindOf("SkillCard") then return false end

            local types = room:getTag("ny_10th_sanshou_cardtypes"):toString():split("+")
            if (not types) then types = {} end
            local alltypes = {"BasicCard", "TrickCard", "EquipCard"}
            for _,ctype in ipairs(alltypes) do
                if card:isKindOf(ctype) then
                    if not table.contains(types, ctype) then
                        table.insert(types, ctype)
                    end
                    break
                end
            end

            room:setTag("ny_10th_sanshou_cardtypes", sgs.QVariant(table.concat(types, "+")))
        end
        if event == sgs.EventPhaseChanging then
            local change = data:toPhaseChange()
            if change.to == sgs.Player_NotActive then
                room:removeTag("ny_10th_sanshou_cardtypes")
            end
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_10th_tianjie = sgs.CreateTriggerSkill{
    name = "ny_10th_tianjie",
    events = {sgs.EventPhaseChanging, sgs.SwappedPile},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseChanging then
            if player:getMark("ny_10th_tianjie_finish-Clear") <= 0 then return false end
            local change = data:toPhaseChange()
            if change.to ~= sgs.Player_NotActive then return false end
            for _,p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
                if p:isAlive() then
                    local targets = room:askForPlayersChosen(player, room:getOtherPlayers(p),
                    self:objectName(), 0, 3, "@ny_10th_tianjie", true, true)
                    if targets and (not targets:isEmpty()) then
                        room:broadcastSkillInvoke(self:objectName())

                        for _,target in sgs.qlist(targets) do
                            if target:isAlive() then
                                local jink = 0
                                for _,card in sgs.qlist(target:getHandcards()) do
                                    if card:isKindOf("Jink") then jink = jink + 1 end
                                end
                                jink = math.max(1, jink)
                                room:damage(sgs.DamageStruct(self:objectName(), p, target, 1, sgs.DamageStruct_Thunder))
                            end
                        end
                    end
                end
            end
        end
        if event == sgs.SwappedPile then
            for _,p in sgs.qlist(room:getAllPlayers()) do
                room:setPlayerMark(p, "ny_10th_tianjie_finish-Clear", 1)
            end
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_10th_shenzhangjiao:addSkill(ny_10th_yizhao)
ny_10th_shenzhangjiao:addSkill(ny_10th_sijun)
ny_10th_shenzhangjiao:addSkill(ny_10th_sanshou)
ny_10th_shenzhangjiao:addSkill(ny_10th_sanshou_record)
ny_10th_shenzhangjiao:addSkill(ny_10th_tianjie)
extension:insertRelatedSkills("ny_10th_sanshou", "#ny_10th_sanshou_record")

ny_10th_zhangfen = sgs.General(extension, "ny_10th_zhangfen", "wu", 4, true, false, false)

ny_tenth_dagongche = sgs.CreateTreasure
{
	name = "_ny_tenth_dagongche",
	class_name = "NyDagongche",
    suit = sgs.Card_Spade,
    number = 9,
	target_fixed = true,
    subtype = "ny_tenth_zhangfen_card",
	on_install = function(self,player)
		local room = player:getRoom()
		room:acquireSkill(player, "ny_tenth_dagongche_slashtr", false, false, false)
        room:acquireSkill(player, "ny_tenth_dagongche_slash", false, false, false)
        room:acquireSkill(player, "ny_tenth_dagongche_buff", false, false, false)
        room:acquireSkill(player, "ny_tenth_dagongche_destory", false, false, false)
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "ny_tenth_dagongche_slashtr", true, true, false)
        room:detachSkillFromPlayer(player, "ny_tenth_dagongche_slash", true, true, false)
        room:setPlayerMark(player, "SkillDescriptionArg1_ny_tenth_xianzhu", 0)
        room:setPlayerMark(player, "SkillDescriptionArg2_ny_tenth_xianzhu", 0)
        room:setPlayerMark(player, "ny_tenth_xianzhu_ignore", 0)
        if player:hasSkill("ny_tenth_xianzhu") then
            room:changeTranslation(player, "ny_tenth_xianzhu", 1)
        end
        if player:hasSkill("ny_tenth_chaixie") then
            room:sendCompulsoryTriggerLog(player, "ny_tenth_chaixie", true, true)
            player:drawCards(player:getMark("&ny_tenth_xianzhu_update"), "ny_tenth_chaixie")
        end
        room:setPlayerMark(player, "&ny_tenth_xianzhu_update", 0)
	end,
}
ny_tenth_dagongche:setParent(extension)

ny_tenth_dagongche_slash = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_tenth_dagongche_slash",
    response_pattern = "@@ny_tenth_dagongche_slash",
    view_as = function(self)
        return ny_tenth_dagongche_slashCard:clone()
    end,
    enabled_at_play = function(self, player)
        return false
    end
}

ny_tenth_dagongche_slashCard = sgs.CreateSkillCard
{
    name = "ny_tenth_dagongche_slash",
    will_throw = false,
    filter = function(self, targets, to_select, player)
        local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
        slash:setSkillName("_ny_tenth_dagongche")

        local qtargets = sgs.PlayerList()
        for _,p in ipairs(targets) do
            qtargets:append(p)
        end

        slash:deleteLater()
        return slash and slash:targetFilter(qtargets, to_select, player) and not player:isProhibited(to_select, slash, qtargets)
    end,
    feasible = function(self, targets, player)
        local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
        slash:setSkillName("_ny_tenth_dagongche")
        slash:deleteLater()

        local qtargets = sgs.PlayerList()
        for _,p in ipairs(targets) do
            qtargets:append(p)
        end
        return slash and slash:targetsFeasible(qtargets, player)
    end,
    on_validate = function(self, cardUse)
        local source = cardUse.from
        local room = source:getRoom()

        if source:getMark("ny_tenth_xianzhu_ignore") > 0 then
            for _,p in sgs.qlist(cardUse.to) do
                room:addPlayerMark(p, "Armor_Nullified", 1)
                room:setPlayerFlag(p, "ny_tenth_dagongche_target")
            end
        end

        local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
        slash:setSkillName("_ny_tenth_dagongche")
        room:setCardFlag(slash, "RemoveFromHistory")
        room:setCardFlag(slash, "ny_tenth_dagongche_slash")
        return slash
    end,
}

--借用一下手杀界破军的fakemove

ny_tenth_dagongche_slashtr = sgs.CreateTriggerSkill{
    name = "ny_tenth_dagongche_slashtr",
    events = {sgs.EventPhaseStart, sgs.Damage},
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = ny_tenth_dagongche_slash,
    priority = 2,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.Player_Play then return false end
            local more = player:getMark("SkillDescriptionArg2_ny_tenth_xianzhu")
            room:askForUseCard(player, "@@ny_tenth_dagongche_slash", "@ny_tenth_dagongche_slash:"..more)
            for _,p in sgs.qlist(room:getAlivePlayers()) do
                if p:hasFlag("ny_tenth_dagongche_target") then
                    room:removePlayerMark(p, "Armor_Nullified", 1)
                    room:setPlayerFlag(p, "-ny_tenth_dagongche_target")
                end
            end
        end
        if event == sgs.Damage then
            local damage = data:toDamage()
            if damage.to:isDead() then return false end
            if damage.to:isNude() then return false end
            if damage.card and damage.card:hasFlag("ny_tenth_dagongche_slash") then
                local max = math.max(1, player:getMark("SkillDescriptionArg1_ny_tenth_xianzhu"))
                --[[local places = {}
                local discards = sgs.IntList()
                room:setPlayerFlag(damage.to, "mobilepojun_InTempMoving")
                for i = 1, max, 1 do
                    if not damage.to:isNude() then
                        local id = room:askForCardChosen(player, damage.to, "he", "ny_tenth_dagongche")
                        discards:append(id)
                        table.insert(places, room:getCardPlace(id))
                        damage.to:addToPile("#ny_tenth_dagongche", id, false)
                    end
                end
                local i = 1
                for _,id in sgs.qlist(discards) do
                    room:moveCardTo(sgs.Sanguosha:getCard(id), damage.to, places[i], false)
                    i = i + 1
                end
                room:setPlayerFlag(damage.to, "-mobilepojun_InTempMoving")]]--

                local discards = cardsChosen(room, player, damage.to, "ny_tenth_dagongche", "he", max)

                room:throwCard(discards, "ny_tenth_dagongche", damage.to, player)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
        and target:getEquip(4) and target:getEquip(4):objectName() == "_ny_tenth_dagongche"
    end,
}

ny_tenth_dagongche_destory = sgs.CreateTriggerSkill{
    name = "ny_tenth_dagongche_destory",
    events = {sgs.BeforeCardsMove},
    frequency = sgs.Skill_Compulsory,
    priority = 50,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local move = data:toMoveOneTime()
        if move.from and move.from:objectName() == player:objectName() then else return false end
        local card = nil
        if move.from_places:contains(sgs.Player_PlaceEquip) and move.to_place ~= sgs.Player_PlaceTable then
            for _,id in sgs.qlist(move.card_ids) do
                if sgs.Sanguosha:getCard(id):objectName() == "_ny_tenth_dagongche" then
                    card = sgs.Sanguosha:getCard(id)
                    move.card_ids:removeOne(id)
                end
            end
        end
        if card then
            if (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD) 
            and player:getMark("&ny_tenth_xianzhu_update") == 0 then else
                local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), "ny_tenth_dagongche","")
                local new_move = sgs.CardsMoveStruct(card:getId(), nil, sgs.Player_PlaceTable, reason)
                room:moveCardsAtomic(new_move, true)
            end
            data:setValue(move)
        end
    end,
}

ny_tenth_dagongche_buff = sgs.CreateTargetModSkill{
    name = "ny_tenth_dagongche_buff",
    distance_limit_func = function(self, from, card)
        if card:getSkillName() == "ny_tenth_dagongche"
        and from:getMark("ny_tenth_xianzhu_ignore") > 0 then return 1000 end
        return 0
    end,
    extra_target_func = function(self, from, card)
        if card:getSkillName() == "ny_tenth_dagongche" then
            return from:getMark("SkillDescriptionArg2_ny_tenth_xianzhu")
        end
        return 0
    end,
}

ny_tenth_wanglu = sgs.CreateTriggerSkill{
    name = "ny_tenth_wanglu",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.Player_Start then return false end
            if ((not player:getEquip(4)) 
            or (player:getEquip(4) and player:getEquip(4):objectName() ~= "_ny_tenth_dagongche" ))
            and player:hasEquipArea(4) then
                local card = nil
                for _,id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
                    if sgs.Sanguosha:getEngineCard(id):isKindOf("NyDagongche") then
                        card = sgs.Sanguosha:getEngineCard(id)
                        break
                    end
                end
                if card then
                    room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)

                    if player:getEquip(4) then
                        room:throwCard(player:getEquip(4), player, player)
                    end

                    local log = sgs.LogMessage()
                    log.type = "$ny_tenth_wanglu_get"
                    log.from = player
                    log.arg = self:objectName()
                    log.card_str = card:toString()
                    room:sendLog(log)

                    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), self:objectName(), "")
                    room:moveCardTo(card, nil, player, sgs.Player_PlaceEquip, reason)
                end
            else
                local log = sgs.LogMessage()
                log.type = "$ny_tenth_wanglu_phase"
                log.from = player
                log.arg = self:objectName()
                log.arg2 = "play"
                room:sendLog(log)

                local thread = room:getThread()
                local old_phase = player:getPhase()
			    player:setPhase(sgs.Player_Play)
			    room:broadcastProperty(player, "phase")
                room:broadcastSkillInvoke(self:objectName())
			    if not thread:trigger(sgs.EventPhaseStart, room, player) then
				    thread:trigger(sgs.EventPhaseProceeding, room, player)
			    end
			    thread:trigger(sgs.EventPhaseEnd, room, player)
                player:setPhase(old_phase)
                room:broadcastProperty(player, "phase")
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_tenth_xianzhu = sgs.CreateTriggerSkill{
    name = "ny_tenth_xianzhu",
    events = {sgs.Damage},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if ((not player:getEquip(4)) 
            or (player:getEquip(4) and player:getEquip(4):objectName() ~= "_ny_tenth_dagongche" )) then return false end
        if player:getMark("&ny_tenth_xianzhu_update") >= 5 then return false end
        local damage = data:toDamage()
        if damage.card and damage.card:isKindOf("Slash") then
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("update")) then
                room:broadcastSkillInvoke(self:objectName())
                room:addPlayerMark(player, "&ny_tenth_xianzhu_update", 1)
                local choices = {"discards", "targets", "ignore"}
                local except = {}
                if player:getMark("ny_tenth_xianzhu_ignore") > 0 then
                    table.removeOne(choices, "ignore")
                    table.insert(except, "ignore")
                end
                local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"), sgs.QVariant(),
                table.concat(except, "+"), nil)
                
                if player:getMark("SkillDescriptionArg1_ny_tenth_xianzhu") == 0 then
                    room:addPlayerMark(player, "SkillDescriptionArg1_ny_tenth_xianzhu", 1)
                end

                if choice == "ignore" then
                    room:setPlayerMark(player, "ny_tenth_xianzhu_ignore", 1)
                end
                if choice == "discards" then
                    room:addPlayerMark(player, "SkillDescriptionArg1_ny_tenth_xianzhu", 1)
                end
                if choice == "targets" then
                    room:addPlayerMark(player, "SkillDescriptionArg2_ny_tenth_xianzhu", 1)
                end

                if player:getMark("ny_tenth_xianzhu_ignore") > 0 then
                    room:changeTranslation(player, "ny_tenth_xianzhu", 3)
                else
                    room:changeTranslation(player, "ny_tenth_xianzhu", 2)
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_tenth_chaixie = sgs.CreateTriggerSkill{
    name = "ny_tenth_chaixie",
    events = {},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_zhangfen:addSkill(ny_tenth_wanglu)
ny_10th_zhangfen:addSkill(ny_tenth_xianzhu)
ny_10th_zhangfen:addSkill(ny_tenth_chaixie)

ny_10th_jiezhonghui = sgs.General(extension, "ny_10th_jiezhonghui", "wei", 4, true, false, false)

ny_10th_quanji = sgs.CreateTriggerSkill{
    name = "ny_10th_quanji",
    events = {sgs.Damaged, sgs.CardsMoveOneTime},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local n = 1
        if event == sgs.Damaged then
            n = data:toDamage().damage
        elseif event == sgs.CardsMoveOneTime then
            local move = data:toMoveOneTime()
            if move.from and move.from:objectName() == player:objectName()
            and move.to_place == sgs.Player_PlaceHand
            and move.to and move.to:objectName() ~= player:objectName()
            and (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip)) then
                n = 1
            else
                return false
            end
        end

        for i = 1, n, 1 do
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("draw")) then
                room:broadcastSkillInvoke(self:objectName())
                player:drawCards(1)
                local quan = room:askForExchange(player, self:objectName(), 1, 1, false, "@ny_10th_quanji", false)
                if quan and quan:subcardsLength() > 0 then
                    player:addToPile("ny_10th_quan", quan)
                end
            end
            if player:isDead() then return false end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
        and target:isAlive()
    end,
}

ny_10th_quanji_maxcard = sgs.CreateMaxCardsSkill{
    name = "#ny_10th_quanji_maxcard",
    extra_func = function(self, target)
        if target:hasSkill("ny_10th_quanji") then
            return target:getPile("ny_10th_quan"):length()
        end
        return 0
    end,
}

ny_10th_zili = sgs.CreateTriggerSkill{
    name = "ny_10th_zili",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_Wake,
    waked_skills = "ny_10th_paiyi",
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
        room:setPlayerMark(player, "ny_10th_zili_waked", 1)
        room:recover(player, sgs.RecoverStruct(player, nil, 1))
        player:drawCards(2, self:objectName())
        room:loseMaxHp(player, 1)
        room:acquireSkill(player, "ny_10th_paiyi")
    end,
    can_wake = function(self, event, player, data, room)
        local room = player:getRoom()
        if player:canWake(self:objectName()) then return true end
        return player:getMark("ny_10th_zili_waked") == 0
        and player:getPile("ny_10th_quan"):length() >= 3
        and player:getPhase() == sgs.Player_Start
    end,
}

ny_10th_paiyi = sgs.CreateViewAsSkill
{
    name = "ny_10th_paiyi",
    n = 99,
    expand_pile = "ny_10th_quan",
    tiansuan_type = "draw,damage",
    view_filter = function(self, selected, to_select)
        return sgs.Self:getPile("ny_10th_quan"):contains(to_select:getId())
        and #selected < 1
    end,
    view_as = function(self, cards)
        if #cards == 1 then
            local cc = ny_10th_paiyiCard:clone()
            cc:addSubcard(cards[1])
            cc:setUserString(sgs.Self:getTag("ny_10th_paiyi"):toString())
            return cc
        end
    end,
    enabled_at_play = function(self, player)
        local choices = {"draw","damage"}
        for _,choice in ipairs(choices) do
            if player:getMark("ny_10th_paiyi_tiansuan_remove_"..choice.."-PlayClear") == 0 then
                return true
            end
        end
    end,
}

ny_10th_paiyiCard = sgs.CreateSkillCard
{
    name = "ny_10th_paiyi",
    will_throw = true,
    filter = function(self, targets, to_select)
        local choice = self:getUserString()
        if choice == "draw" then
            return #targets == 0
        else
            return #targets < (sgs.Self:getPile("ny_10th_quan"):length() - 1)
        end
    end,
    feasible = function(self, targets, player)
        return #targets ~= 0
    end,
    on_use = function(self, room, source, targets)
        local room = source:getRoom()
        local choice = self:getUserString()
        room:setPlayerMark(source, "ny_10th_paiyi_tiansuan_remove_"..choice.."-PlayClear", 1)

        local log = sgs.LogMessage()
        log.type = "$ny_10th_paiyi_chosen"
        log.from = source
        log.arg = "ny_10th_paiyi:"..choice
        room:sendLog(log)

        if choice == "draw" then
            targets[1]:drawCards(source:getPile("ny_10th_quan"):length(), self:objectName())
        else
            for _,target in ipairs(targets) do
                room:damage(sgs.DamageStruct(self:objectName(), source, target, 1, sgs.DamageStruct_Normal))
                room:getThread():delay(500)
            end
        end
    end,
}

ny_10th_jiezhonghui:addSkill(ny_10th_quanji)
ny_10th_jiezhonghui:addSkill(ny_10th_quanji_maxcard)
ny_10th_jiezhonghui:addSkill(ny_10th_zili)
extension:insertRelatedSkills("ny_10th_quanji", "#ny_10th_quanji_maxcard")

ny_10th_jindiancaocao = sgs.General(extension, "ny_10th_jindiancaocao", "wei", 4, true, false, false)

ny_10th_jingdianjianxiong = sgs.CreateTriggerSkill{
    name = "ny_10th_jingdianjianxiong",
    events = {sgs.Damaged},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local n = player:getMark("SkillDescriptionArg1_ny_10th_jingdianjianxiong")
        n = math.max(1,n)
        local damage = data:toDamage()
        local card = damage.card
        local prompt
        if card and room:getCardPlace(card:getEffectiveId()) == sgs.Player_PlaceTable 
        and (not card:isKindOf("SkillCard")) then
            prompt = string.format("draw:%s::%s:", card:objectName(), n)
        else
            prompt = string.format("draw:%s::%s:", "ny_10th_jingdianjianxiong_nocard", n)
        end
        if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant(prompt)) then
            room:broadcastSkillInvoke(self:objectName())
            if card and room:getCardPlace(card:getEffectiveId()) == sgs.Player_PlaceTable 
            and (not card:isKindOf("SkillCard")) then
                room:obtainCard(player, card, true)
            end
            player:drawCards(n, self:objectName())
            if n < 5 then
                n = n + 1
                room:setPlayerMark(player, "SkillDescriptionArg1_ny_10th_jingdianjianxiong", n)
                room:setPlayerMark(player, "&ny_10th_jingdianjianxiong_draw", n)
                room:changeTranslation(player, "ny_10th_jingdianjianxiong", 1)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_jindiancaocao:addSkill(ny_10th_jingdianjianxiong)

ny_10th_jingdiansunquan = sgs.General(extension, "ny_10th_jingdiansunquan", "wu", 4, true, false, false)

ny_10th_jingdianzhiheng = sgs.CreateViewAsSkill
{
    name = "ny_10th_jingdianzhiheng",
    n = 999,
    view_filter = function(self, selected, to_select)
        return true
    end,
    view_as = function(self, cards)
        if #cards > 0 then
            local cc = ny_10th_jingdianzhihengCard:clone()
            for _,card in ipairs(cards) do
                cc:addSubcard(card)
            end
            return cc
        end
    end,
    enabled_at_play = function(self, player)
        return player:usedTimes("#ny_10th_jingdianzhiheng") < (1 + player:getMark("&ny_10th_jingdianzhiheng-Clear"))
    end,
}

ny_10th_jingdianzhihengCard = sgs.CreateSkillCard
{
    name = "ny_10th_jingdianzhiheng",
    target_fixed = true,
    will_throw = true,
    on_use = function(self, room, source, targets)
        local room = source:getRoom()
        local n = self:subcardsLength()
        if source:getMark("ny_10th_jingdianzhiheng_all") > 0 then
            room:setPlayerMark(source, "ny_10th_jingdianzhiheng_all", 0)
            n = n + 1
        end
        source:drawCards(n, self:objectName())
    end
}

ny_10th_jingdianzhiheng_buff = sgs.CreateTriggerSkill{
    name = "#ny_10th_jingdianzhiheng_buff",
    events = {sgs.Damage, sgs.PreCardUsed},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.PreCardUsed then
            local card = data:toCardUse().card
            if card:isKindOf("SkillCard") and card:getSkillName() == "ny_10th_jingdianzhiheng" then
                if player:getHandcardNum() == 0 then return end
                local ids = card:getSubcards()
                for _,cc in sgs.qlist(player:getHandcards()) do
                    local id = cc:getId()
                    if not ids:contains(id) then return end
                end
                room:setPlayerMark(player, "ny_10th_jingdianzhiheng_all", 1)
            end
        end
        if event == sgs.Damage then
            if player:getPhase() == sgs.Player_NotActive then return false end
            local damage = data:toDamage()
            if damage.to:objectName() ~= player:objectName()
            and damage.to:getMark("ny_10th_jingdianzhiheng_trigger_"..player:objectName().."-Clear") == 0 then
                room:setPlayerMark(damage.to, "ny_10th_jingdianzhiheng_trigger_"..player:objectName().."-Clear", 1)
                room:addPlayerMark(player, "&ny_10th_jingdianzhiheng-Clear", 1)
            end
        end

    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_jingdiansunquan:addSkill(ny_10th_jingdianzhiheng)
ny_10th_jingdiansunquan:addSkill(ny_10th_jingdianzhiheng_buff)
extension:insertRelatedSkills("ny_10th_jingdianzhiheng", "#ny_10th_jingdianzhiheng_buff")

ny_10th_jingdianliubei = sgs.General(extension, "ny_10th_jingdianliubei", "shu", 4, true, false, false)

ny_tenth_jingdianrende = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_tenth_jingdianrende",
    response_pattern = "@@ny_tenth_jingdianrende",
    view_as = function(self)
        if sgs.Self:hasFlag("ny_tenth_jingdianrende_basic") then
            return ny_tenth_jingdianrende_basicCard:clone()
        end
        return ny_tenth_jingdianrendeCard:clone()
    end,
    enabled_at_play = function(self, player)
        return true
    end
}

ny_tenth_jingdianrendeCard = sgs.CreateSkillCard
{
    name = "ny_tenth_jingdianrende",
    filter = function(self, targets, to_select)
        return #targets < 1 and to_select:objectName() ~= sgs.Self:objectName()
        and to_select:getHandcardNum() > 0
        and to_select:getMark("ny_tenth_jingdianrende_get-PlayClear") == 0
    end,
    on_effect = function(self, effect)
        local room = effect.from:getRoom()
        room:setPlayerMark(effect.to, "ny_tenth_jingdianrende_get-PlayClear", 1)

        local cards = effect.to:getHandcards()
        local ran_cards = sgs.QList2Table(cards)
        local get = {}
        local n = math.min(effect.to:getHandcardNum(), 2)
        for i = 1, n, 1 do
            local one = ran_cards[math.random(1,#ran_cards)]
            table.removeOne(ran_cards, one)
            table.insert(get, one)
        end
        local obtain = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, -1)
        obtain:deleteLater()
        for _,card in ipairs(get) do
            obtain:addSubcard(card)
        end
        room:obtainCard(effect.from, obtain, false)

        if effect.from:isAlive() then
            local patterns = {"slash", "thunder_slash", "fire_slash", "peach", "analeptic", "jink"}
            local can = {}
            local cant = {}
            for _,pattern in ipairs(patterns) do
                local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
                if card:isAvailable(effect.from) then
                    table.insert(can, pattern)
                else
                    table.insert(cant, pattern)
                end
            end
            table.insert(can, "cancel")
            local choice = room:askForChoice(effect.from, self:objectName(), table.concat(can, "+"), sgs.QVariant(),
            table.concat(cant, "+"), "ny_tenth_jingdianrende_choice")
            if choice == "cancel" then 
                return false
            else
                room:setPlayerProperty(effect.from, "ny_tenth_jingdianrende_card", sgs.QVariant(choice))
                room:setPlayerFlag(effect.from, "ny_tenth_jingdianrende_basic")
                room:askForUseCard(effect.from, "@@ny_tenth_jingdianrende", "@ny_tenth_jingdianrende:"..choice)
                room:setPlayerFlag(effect.from, "-ny_tenth_jingdianrende_basic")
            end
        end
    end
}

ny_tenth_jingdianrende_basicCard = sgs.CreateSkillCard
{
    handling_method = sgs.Card_MethodUse,
    mute = true,
    name = "ny_tenth_jingdianrende_basic",
    filter = function(self, targets, to_select, player) 
		local pattern = player:property("ny_tenth_jingdianrende_card"):toString()
		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
		card:setSkillName("ny_tenth_jingdianrende")
		if card and card:targetFixed() then
			return false
		end
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		return card and card:targetFilter(qtargets, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, qtargets)
	end,
    target_fixed = function(self)		
		local pattern = sgs.Self:property("ny_tenth_jingdianrende_card"):toString()
		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
        card:setSkillName("ny_tenth_jingdianrende")
		return card and card:targetFixed()
	end,
	feasible = function(self, targets)	
		local pattern = sgs.Self:property("ny_tenth_jingdianrende_card"):toString()
		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
		card:setSkillName("ny_tenth_jingdianrende")
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		return card and card:targetsFeasible(qtargets, sgs.Self)
	end,
    on_validate = function(self, card_use)
		local xunyou = card_use.from
		local room = xunyou:getRoom()
		local pattern = xunyou:property("ny_tenth_jingdianrende_card"):toString()
		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
        card:setSkillName("ny_tenth_jingdianrende")
		return card	
	end	
}

ny_10th_jingdianliubei:addSkill(ny_tenth_jingdianrende)

ny_10th_quanhuijie = sgs.General(extension, "ny_10th_quanhuijie", "wu", 3, false, false, false)

ny_tenth_huishu = sgs.CreateTriggerSkill{
    name = "ny_tenth_huishu",
    events = {sgs.EventPhaseEnd, sgs.CardsMoveOneTime},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseEnd then
            if player:getPhase() ~= sgs.Player_Draw then return false end
            local draw = player:getMark("SkillDescriptionArg1_ny_tenth_huishu")
            if draw == 0 then
                room:setPlayerMark(player, "SkillDescriptionArg1_ny_tenth_huishu", 3)
                room:setPlayerMark(player, "SkillDescriptionArg2_ny_tenth_huishu", 1)
                room:setPlayerMark(player, "SkillDescriptionArg3_ny_tenth_huishu", 2)
                room:changeTranslation(player, "ny_tenth_huishu", 1)
                draw = 3
            end
            local discard = player:getMark("SkillDescriptionArg2_ny_tenth_huishu")
            local get = player:getMark("SkillDescriptionArg3_ny_tenth_huishu")

            local prompt = string.format("draw:%s::%s:", draw, discard)
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant(prompt)) then
                room:broadcastSkillInvoke(self:objectName())
                room:setPlayerMark(player, "&ny_tenth_huishu_target-Clear", get+1)
                player:drawCards(draw, self:objectName())
                room:askForDiscard(player, self:objectName(), discard, discard, false, false)
            end
        end
        if event == sgs.CardsMoveOneTime then
            if player:getMark("&ny_tenth_huishu_target-Clear") == 0 then return false end
            if player:isDead() then return false end
            local move = data:toMoveOneTime()
            if move.from and move.from:objectName() == player:objectName()
            and (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD)
            and (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip)) then
                room:addPlayerMark(player, "&ny_tenth_huishu_now-Clear", move.card_ids:length())
                if player:getMark("&ny_tenth_huishu_now-Clear") >= player:getMark("&ny_tenth_huishu_target-Clear") then
                    room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                    local n = player:getMark("&ny_tenth_huishu_target-Clear") - 1
                    room:setPlayerMark(player, "&ny_tenth_huishu_target-Clear", 0)
                    room:setPlayerMark(player, "&ny_tenth_huishu_now-Clear", 0)
                    local get = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, -1)
                    local all = {}
                    for _,id in sgs.qlist(room:getDiscardPile()) do
                        local card = sgs.Sanguosha:getCard(id)
                        if card:isKindOf("BasicCard") then else
                            table.insert(all, card)
                        end
                    end
                    if #all > 0 then
                        while((#all > 0) and (n > 0)) do
                            local card = all[math.random(1,#all)]
                            get:addSubcard(card)
                            table.removeOne(all, card)
                            n = n - 1
                        end
                        room:obtainCard(player, get, false)
                    end
                    get:deleteLater()
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_yishu = sgs.CreateTriggerSkill{
    name = "ny_10th_yishu",
    events = {sgs.CardsMoveOneTime},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardsMoveOneTime then
            local move = data:toMoveOneTime()
            if move.from and move.from:objectName() == player:objectName()
            and (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip)) then
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                local draw = player:getMark("SkillDescriptionArg1_ny_tenth_huishu")
                if draw == 0 then
                    room:setPlayerMark(player, "SkillDescriptionArg1_ny_tenth_huishu", 3)
                    room:setPlayerMark(player, "SkillDescriptionArg2_ny_tenth_huishu", 1)
                    room:setPlayerMark(player, "SkillDescriptionArg3_ny_tenth_huishu", 2)
                    draw = 3
                end
                local discard = player:getMark("SkillDescriptionArg2_ny_tenth_huishu")
                local get = player:getMark("SkillDescriptionArg3_ny_tenth_huishu")

                local max = math.max(draw, discard, get)
                local changemax = {}
                if max == draw then table.insert(changemax, "draw="..max) end
                if max == discard then table.insert(changemax, "discard="..discard) end
                if max == get then table.insert(changemax, "get="..get) end

                local min = math.min(draw, discard, get)
                local changemin = {}
                if min == draw then table.insert(changemin, "draw="..draw) end
                if min == discard then table.insert(changemin, "discard="..discard) end
                if min == get then table.insert(changemin, "get="..get) end
                
                local cmax = room:askForChoice(player, self:objectName(), table.concat(changemax, "+"), sgs.QVariant("max"), nil, "ny_10th_yishu_add")
                local cmin = room:askForChoice(player, self:objectName(), table.concat(changemin, "+"), sgs.QVariant("min"), nil, "ny_10th_yishu_remove")

                if string.find(cmax, "draw") then room:addPlayerMark(player, "SkillDescriptionArg1_ny_tenth_huishu", -1) end
                if string.find(cmax, "discard") then room:addPlayerMark(player, "SkillDescriptionArg2_ny_tenth_huishu", -1) end
                if string.find(cmax, "get") then room:addPlayerMark(player, "SkillDescriptionArg3_ny_tenth_huishu", -1) end

                if string.find(cmin, "draw") then room:addPlayerMark(player, "SkillDescriptionArg1_ny_tenth_huishu", 2) end
                if string.find(cmin, "discard") then room:addPlayerMark(player, "SkillDescriptionArg2_ny_tenth_huishu", 2) end
                if string.find(cmin, "get") then room:addPlayerMark(player, "SkillDescriptionArg3_ny_tenth_huishu", 2) end

                room:changeTranslation(player, "ny_tenth_huishu", 1)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
        and target:getPhase() ~= sgs.Player_Play and target:hasSkill("ny_tenth_huishu")
    end,
}

ny_10th_ligong = sgs.CreateTriggerSkill{
    name = "ny_10th_ligong",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_Wake,
    priority = 4,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
        room:setPlayerMark(player, "ny_10th_ligong_waked", 1)
        room:gainMaxHp(player, 1, self:objectName())
        room:recover(player, sgs.RecoverStruct(player, nil, 1))
        room:detachSkillFromPlayer(player, "ny_10th_yishu")
        local names = {}
        local all = sgs.Sanguosha:getLimitedGeneralNames("wu")
        local count = 1000
        local find = 4
        while(find > 0) do
            local name = all[math.random(1, #all)]
            local selected = sgs.Sanguosha:getGeneral(name)
            if selected:isFemale() then
                local skill = selected:getVisibleSkillList()
                local get = false
                for _,p in sgs.qlist(skill) do
                    local na = p:objectName()
                    if not player:hasSkill(na) then
                        get = true
                        table.insert(names, name)
                        break
                    end
                end
                if get then find = find - 1 end
            end
            count = count - 1
            if count <= 0 then break end
        end
        if #names == 0 then 
            player:drawCards(3, self:objectName())
            return false
        end
        for i = 1, 2, 1 do
            local hero = sgs.Sanguosha:getGeneral(room:askForGeneral(player, table.concat(names, "+")))
            local skills = hero:getVisibleSkillList()
            local skillnames = {}
            for _,s in sgs.qlist(skills) do
                local skillname = s:objectName()
                if not player:hasSkill(skillname) then
                    table.insert(skillnames,skillname)
                end
            end
            table.insert(skillnames, "cancel")
            local choices = table.concat(skillnames, "+")
            local skill = room:askForChoice(player, self:objectName(), choices)
            if skill == "cancel" then
                if i == 1 then player:drawCards(3, self:objectName()) end
                return false
            else
                if i == 1 then
                    room:detachSkillFromPlayer(player, "ny_tenth_huishu")
                end
                room:acquireSkill(player, skill)
            end
        end
    end,
    can_wake = function(self, event, player, data, room)
        local room = player:getRoom()
        if player:canWake(self:objectName()) then return true end
        if not player:hasSkill("ny_tenth_huishu") then return false end
        if player:getMark("SkillDescriptionArg1_ny_tenth_huishu") < 5
        and player:getMark("SkillDescriptionArg2_ny_tenth_huishu") < 5
        and player:getMark("SkillDescriptionArg3_ny_tenth_huishu") < 5
        then return false end
        return player:getMark("ny_10th_ligong_waked") == 0
        and player:getPhase() == sgs.Player_Start
    end,
}

ny_10th_quanhuijie:addSkill(ny_tenth_huishu)
ny_10th_quanhuijie:addSkill(ny_10th_yishu)
ny_10th_quanhuijie:addSkill(ny_10th_ligong)

ny_10th_jxqunhuangyueying = sgs.General(extension, "ny_10th_jxqunhuangyueying", "qun", 3, false, false, false)

ny_10th_jiqiao = sgs.CreateTriggerSkill{
    name = "ny_10th_jiqiao",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local card = room:askForDiscard(player, self:objectName(), 999, 1, true, true, "@ny_10th_jiqiao", ".", self:objectName())
        if card and card:subcardsLength() > 0 then
            --room:broadcastSkillInvoke(self:objectName())
            local n = card:subcardsLength()
            for _,id in sgs.qlist(card:getSubcards()) do
                if sgs.Sanguosha:getCard(id):isKindOf("EquipCard") then
                    n = n + 1
                end
            end
            local card_ids = room:getNCards(n)
            local reason1 = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), self:objectName(), "")
            local move1 = sgs.CardsMoveStruct(card_ids, nil, sgs.Player_PlaceTable, reason1)
            room:moveCardsAtomic(move1, true)

            local get = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, -1)
            for _,id in sgs.qlist(card_ids) do
                if not sgs.Sanguosha:getCard(id):isKindOf("EquipCard") then
                    get:addSubcard(sgs.Sanguosha:getCard(id))
                end
            end
            if get:subcardsLength() > 0 then 
                room:obtainCard(player, get, true) 

                for _,id in sgs.qlist(get:getSubcards()) do
                    card_ids:removeOne(id)
                end
            end
            get:deleteLater()

            if not card_ids:isEmpty() then
                local log = sgs.LogMessage()
                log.type = "$MoveToDiscardPile"
                log.from = player
                log.card_str = table.concat(sgs.QList2Table(card_ids), "+")
                room:sendLog(log)

                local reason2 = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), self:objectName(), "")
                local move2 = sgs.CardsMoveStruct(card_ids, nil, sgs.Player_DiscardPile, reason2)
                room:moveCardsAtomic(move2, true)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
        and target:getPhase() == sgs.Player_Play
    end,
}

ny_10th_linglong = sgs.CreateTriggerSkill{
    name = "ny_10th_linglong",
    events = {sgs.GameStart,sgs.EventAcquireSkill,sgs.EventLoseSkill,sgs.CardsMoveOneTime,sgs.CardUsed, sgs.InvokeSkill},
    frequency = sgs.Skill_Compulsory,
    waked_skills = "qicai",
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.GameStart or event == sgs.EventAcquireSkill then
            if event == sgs.EventAcquireSkill then
                local name = data:toString()
                if name ~= self:objectName() then return false end
            end
            if player:getTreasure() then return false end
            if not player:hasSkill("qicai") then
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                room:setPlayerMark(player, "ny_10th_linglong_qicai", 1)
                room:acquireSkill(player, "qicai")
            end
        end
        if event == sgs.EventLoseSkill then
            local name = data:toString()
            if name == self:objectName() and player:getMark("ny_10th_linglong_qicai") > 0
            and player:hasSkill("qicai") then
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                room:setPlayerMark(player, "ny_10th_linglong_qicai", 0)
                room:detachSkillFromPlayer(player, "qicai")
            end
            if name == "qicai" then
                if player:getTreasure() then return false end
                if player:hasSkill("qicai") then return false end
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                room:setPlayerMark(player, "ny_10th_linglong_qicai", 1)
                room:acquireSkill(player, "qicai")
            end
        end
        if event == sgs.CardsMoveOneTime then
            if player:getMark("ny_10th_linglong_qicai") == 0 then
                if player:getTreasure() then return false end
                if player:hasSkill("qicai") then return false end
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                room:setPlayerMark(player, "ny_10th_linglong_qicai", 1)
                room:acquireSkill(player, "qicai")
            end
            if player:getMark("ny_10th_linglong_qicai") > 0 then
                if not player:getTreasure() then return false end
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                room:setPlayerMark(player, "ny_10th_linglong_qicai", 0)
                room:detachSkillFromPlayer(player, "qicai")
            end
        end
        if event == sgs.CardUsed then
            if (not player:getTreasure()) and (not player:getArmor())
            and (not player:getDefensiveHorse()) and (not player:getOffensiveHorse()) then
                local use = data:toCardUse()
                if use.card:isKindOf("Slash") or use.card:isNDTrick() then
                    room:broadcastSkillInvoke(self:objectName())

                    local log = sgs.LogMessage()
                    log.type = "$ny_10th_linglong_noresponse"
                    log.from = player
                    log.arg = self:objectName()
                    log.card_str = use.card:toString()
                    room:sendLog(log)

                    local no_respond_list = use.no_respond_list
                    table.insert(no_respond_list, "_ALL_TARGETS")
                    use.no_respond_list = no_respond_list
                    data:setValue(use)
                end
            end
        end
        if event == sgs.InvokeSkill then
            if data:toString() == "eight_diagram" then
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_linglong_max = sgs.CreateMaxCardsSkill{
    name = "#ny_10th_linglong_max",
    extra_func = function(self, target)
        local player = target
        if target:hasSkill("ny_10th_linglong") 
        and (not player:getDefensiveHorse()) and (not player:getOffensiveHorse()) then
            return 2
        end
        return 0
    end,
}

ny_10th_linglong_armor = sgs.CreateViewAsEquipSkill{
    name = "#ny_10th_linglong_armor",
	view_as_equip = function(self,target)
		if target:getArmor() == nil and target:hasSkill("ny_10th_linglong")
		then
	    	return "eight_diagram"
		end
	end 
}

ny_10th_jxqunhuangyueying:addSkill(ny_10th_jiqiao)
ny_10th_jxqunhuangyueying:addSkill(ny_10th_linglong)
ny_10th_jxqunhuangyueying:addSkill(ny_10th_linglong_max)
ny_10th_jxqunhuangyueying:addSkill(ny_10th_linglong_armor)
extension:insertRelatedSkills("ny_10th_linglong", "#ny_10th_linglong_armor")
extension:insertRelatedSkills("ny_10th_linglong", "#ny_10th_linglong_max")

ny_10th_zhangmancheng = sgs.General(extension, "ny_10th_zhangmancheng", "qun", 4, true, false, false)

ny_10th_zhongji = sgs.CreateTriggerSkill{
    name = "ny_10th_zhongji",
    events = {sgs.CardUsed, sgs.CardResponded},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local card
        if event == sgs.CardUsed then
            card = data:toCardUse().card
        else
            local response = data:toCardResponse()
            if response.m_isUse then
                card = response.m_card
            end
        end
        if (not card) or (card and card:isKindOf("SkillCard")) then return false end
        if player:getHandcardNum() >= player:getMaxHp() then return false end
        for _,cc in sgs.qlist(player:getHandcards()) do
            if cc:getSuit() == card:getSuit() then return false end
        end

        local draw = player:getMaxHp() - player:getHandcardNum()
        local dis = 1 + player:getMark("&ny_10th_zhongji-Clear")
        local prompt = string.format("draw:%s::%s:", draw, dis)
        if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant(prompt)) then
            room:broadcastSkillInvoke(self:objectName())
            room:addPlayerMark(player, "&ny_10th_zhongji-Clear", 1)
            player:drawCards(draw, self:objectName())
            if player:isAlive() then
                room:askForDiscard(player, self:objectName(), dis, dis, false, true)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_lvecheng = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_10th_lvecheng",
    view_as = function(self)
        return ny_10th_lvechengCard:clone()
    end,
    enabled_at_play = function(self, player)
        return not player:hasUsed("#ny_10th_lvecheng")
    end
}

ny_10th_lvechengCard = sgs.CreateSkillCard
{
    name = "ny_10th_lvecheng",
    filter = function(self, targets, to_select)
        return #targets < 1 and to_select:objectName() ~= sgs.Self:objectName()
    end,
    on_effect = function(self, effect)
        local room = effect.from:getRoom()
        for _,card in sgs.qlist(effect.from:getHandcards()) do
            if card:isKindOf("Slash") then
                room:setCardFlag(card, "ny_10th_lvecheng")
                room:setCardTip(card:getEffectiveId(), "ny_10th_lvecheng")
            end
        end
        room:setPlayerMark(effect.to, "&ny_10th_lvecheng-Clear", 1)
        room:setPlayerMark(effect.to, "ny_10th_lvecheng_from"..effect.from:objectName().."-Clear", 1)
    end
}

ny_10th_lvecheng_buff = sgs.CreateTriggerSkill{
    name = "#ny_10th_lvecheng_buff",
    events = {sgs.EventPhaseChanging},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local change = data:toPhaseChange()
        if change.to == sgs.Player_NotActive then
            room:setPlayerFlag(player, "ny_10th_lvecheng")
            for _,card in sgs.qlist(player:getHandcards()) do
                if card:hasFlag("ny_10th_lvecheng") then
                    room:setCardFlag(card, "-ny_10th_lvecheng")
                    room:setCardTip(card:getEffectiveId(), "-ny_10th_lvecheng")
                end
            end
            for _,p in sgs.qlist(room:getOtherPlayers(player)) do
                if p:getMark("ny_10th_lvecheng_from"..player:objectName().."-Clear") > 0 
                and p:getHandcardNum() > 0 then
                    room:sendCompulsoryTriggerLog(player, "ny_10th_lvecheng", true, true)
                    room:showAllCards(p)
                    local slashs = {}
                    for _,card in sgs.qlist(p:getHandcards()) do
                        if card:isKindOf("Slash") then
                            table.insert(slashs, card)
                        end
                    end

                    if #slashs > 0 then
                        local pormpt = string.format("use:%s:", player:getGeneralName())
                        if room:askForSkillInvoke(p, "ny_10th_lvecheng", sgs.QVariant(prompt), false) then
                            for _,slash in ipairs(slashs) do
                                if not p:isProhibited(player, slash) then
                                    room:useCard(sgs.CardUseStruct(slash, p, player))
                                end
                                if player:isDead() then return false end
                            end
                        end
                    end
                end
                if player:isDead() then return false end
            end
            room:setPlayerFlag(player, "-ny_10th_lvecheng")
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_lvecheng_target = sgs.CreateTargetModSkill{
    name = "#ny_10th_lvecheng_target",
    residue_func = function(self, from, card, to)
        if card:hasFlag("ny_10th_lvecheng") and to and to:getMark("ny_10th_lvecheng_from"..from:objectName().."-Clear") > 0 then
            return 1000
        end
        return 0
    end,
}

ny_10th_zhangmancheng:addSkill(ny_10th_zhongji)
ny_10th_zhangmancheng:addSkill(ny_10th_lvecheng)
ny_10th_zhangmancheng:addSkill(ny_10th_lvecheng_buff)
ny_10th_zhangmancheng:addSkill(ny_10th_lvecheng_target)
extension:insertRelatedSkills("ny_10th_lvecheng", "#ny_10th_lvecheng_buff")
extension:insertRelatedSkills("ny_10th_lvecheng", "#ny_10th_lvecheng_target")

ny_10th_luyi = sgs.General(extension, "ny_10th_luyi", "qun", 3, false, false, false)

local function yaoyiChangeState(player)
    if not player then return 2 end
    for _,skill in sgs.qlist(player:getVisibleSkillList()) do
        if (not skill:isAttachedLordSkill()) and skill:isChangeSkill() then
            if player:getChangeSkillState(skill:objectName()) <= 1 then
                return 0
            else
                return 1
            end
        end
    end
    return 2
end

ny_10th_yaoyi = sgs.CreateProhibitSkill{
    name = "ny_10th_yaoyi",
    is_prohibited = function(self, from, to, card)
        if from:objectName() == to:objectName() then return false end
        local find = false
        if from:hasSkill("ny_10th_yaoyi") then
            find = true
        else
            for _,player in sgs.qlist(from:getAliveSiblings()) do
                if player:hasSkill("ny_10th_yaoyi") then
                    find = true
                    break
                end
            end
        end
        if not find then return false end
        local st1 = yaoyiChangeState(from)
        local st2 = yaoyiChangeState(to)
        if st1 == 2 or st2 == 2 then return false end
        if card and (not card:isKindOf("SkillCard")) and (st1 == st2) then return true end
        return false
    end,
}

ny_10th_yaoyi_start = sgs.CreateTriggerSkill{
    name = "#ny_10th_yaoyi_start",
    events = {sgs.GameStart},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        room:broadcastSkillInvoke("ny_10th_yaoyi")
        for _,target in sgs.qlist(room:getAlivePlayers()) do
            local cfind = true
            for _,skill in sgs.qlist(target:getVisibleSkillList()) do
                if (not skill:isAttachedLordSkill()) and skill:isChangeSkill() then
                    cfind = false
                    break
                end
            end
            if cfind then
                room:acquireSkill(target, "ny_10th_shoutan")
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_shoutan = sgs.CreateViewAsSkill
{
    name = "ny_10th_shoutan",
    n = 99,
    view_filter = function(self, selected, to_select)
        if not sgs.Self:getHandcards():contains(to_select) then return false end
        if sgs.Self:hasSkill("ny_10th_yaoyi") then return false end
        if sgs.Self:getChangeSkillState(self:objectName()) <= 1 then
            return  #selected < 1 and (not to_select:isBlack())
        elseif sgs.Self:getChangeSkillState(self:objectName()) == 2 then
            return  #selected < 1 and to_select:isBlack()
        end
	end,
    view_as = function(self, cards)
        if #cards == 0 and (not sgs.Self:hasSkill("ny_10th_yaoyi")) then return nil end 
        local cc = ny_10th_shoutanCard:clone()
        if sgs.Self:hasSkill("ny_10th_yaoyi") then return cc end
        for _,card in ipairs(cards) do
            cc:addSubcard(card)
        end
        return cc
    end,
    enabled_at_play = function(self, player)
        if player:hasSkill("ny_10th_yaoyi") then 
            return true
        else
            return not player:hasUsed("#ny_10th_shoutan")
        end
    end,
}

ny_10th_shoutantr = sgs.CreateTriggerSkill{
    name = "ny_10th_shoutan",
    events = {},
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = ny_10th_shoutan,
    change_skill = true,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}


ny_10th_shoutanCard = sgs.CreateSkillCard
{
    name = "ny_10th_shoutan",
    will_throw = true,
    target_fixed = true,
    on_use = function(self, room, source, targets)
        local room = source:getRoom()
        if source:hasSkill("ny_10th_yaoyi") then
            room:broadcastSkillInvoke("ny_10th_yaoyi")
        end
        if source:getChangeSkillState(self:objectName()) <= 1 then
            room:setChangeSkillState(source, self:objectName(), 2)
        elseif source:getChangeSkillState(self:objectName()) == 2 then
            room:setChangeSkillState(source, self:objectName(), 1)
        end
    end
}

ny_tenth_fuxueVS = sgs.CreateViewAsSkill
{
    name = "ny_tenth_fuxue",
    n = 99,
    response_pattern = "@@ny_tenth_fuxue",
    expand_pile = "#ny_tenth_fuxue",
    view_filter = function(self, selected, to_select)
        if  (not sgs.Self:getPile("#ny_tenth_fuxue"):contains(to_select:getId())) then return false end
        return #selected < sgs.Self:getHp()
    end,
    view_as = function(self, cards)
        local card = ny_tenth_fuxueCard:clone()
        if #cards == 0 then return nil end
            for _,p in ipairs(cards) do
                card:addSubcard(p)
            end
        return card
    end,
    enabled_at_play = function(self,player)
        return false
    end,
}

ny_tenth_fuxueCard = sgs.CreateSkillCard
{
    name = "ny_tenth_fuxue",
    will_throw = false,
    target_fixed = true,
    on_use = function(self, room, source, targets)
        return false
    end
}

ny_tenth_fuxue = sgs.CreateTriggerSkill{
    name = "ny_tenth_fuxue",
    view_as_skill = ny_tenth_fuxueVS,
    events = {sgs.EventPhaseStart, sgs.CardsMoveOneTime},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardsMoveOneTime then
            local move = data:toMoveOneTime()
            if move.to_place ~= sgs.Player_DiscardPile then return false end
            if (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_USE) then return false end
            local old_cards = player:getTag("ny_tenth_fuxue_cards"):toIntList()
            if not old_cards then
                old_cards = move.card_ids
            else
                for _,id in sgs.qlist(move.card_ids) do
                    old_cards:append(id)
                end
            end
            local tag = sgs.QVariant()
            tag:setValue(old_cards)
            player:setTag("ny_tenth_fuxue_cards", tag)
        end
        if event == sgs.EventPhaseStart then
            if player:getPhase() == sgs.Player_Start then
                local all = player:getTag("ny_tenth_fuxue_cards"):toIntList()
                if (not all) or (all:isEmpty()) then return false end
                local now = sgs.IntList()
                for _,id in sgs.qlist(room:getDiscardPile()) do
                    if all:contains(id) then
                        now:append(id)
                    end
                end
                if now:isEmpty() then
                    player:removeTag("ny_tenth_fuxue_cards")
                    return false
                end
                local tag = sgs.QVariant()
                tag:setValue(now)
                player:setTag("ny_tenth_fuxue_cards", tag)

                room:notifyMoveToPile(player, now, "ny_tenth_fuxue", sgs.Player_DiscardPile, true)
                local card = room:askForUseCard(player, "@@ny_tenth_fuxue", "@ny_tenth_fuxue:"..player:getHp())
                room:notifyMoveToPile(player, now, "ny_tenth_fuxue", sgs.Player_DiscardPile, false)

                if card then
                    local get = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, -1)
                    get:addSubcards(card:getSubcards())
                    for _,c in sgs.qlist(card:getSubcards()) do
                        now:removeOne(c)
                    end
                    room:obtainCard(player, get, false)
                    for _,cc in sgs.qlist(player:getHandcards()) do
                        if get:getSubcards():contains(cc:getId()) then
                            room:setCardTip(cc:getEffectiveId(),"ny_tenth_fuxue")
                            room:setCardFlag(cc, "ny_tenth_fuxue")
                        end
                    end
                    get:deleteLater()
                    player:removeTag("ny_tenth_fuxue_cards")
                    local newtag = sgs.QVariant()
                    newtag:setValue(now)
                    player:setTag("ny_tenth_fuxue_cards", newtag)
                end
            end
            if player:getPhase() == sgs.Player_Finish then
                local can = false
                for _,card in sgs.qlist(player:getHandcards()) do
                    if card:hasFlag("ny_tenth_fuxue") then 
                        can = true
                        room:setCardTip(card:getEffectiveId(),"-ny_tenth_fuxue")
                        room:setCardFlag(card, "-ny_tenth_fuxue")
                    end
                end
                if can then return false end
                local prompt = string.format("draw:%d:",player:getHp())
                if not room:askForSkillInvoke(player, self:objectName(), sgs.QVariant(prompt)) then return false end
                room:broadcastSkillInvoke(self:objectName())
                player:drawCards(player:getHp(), self:objectName())
            end
            if player:getPhase() == sgs.Player_NotActive then
                for _,card in sgs.qlist(player:getHandcards()) do
                    if card:hasFlag("ny_tenth_fuxue") then 
                        room:setCardTip(card:getEffectiveId(),"-ny_tenth_fuxue")
                        room:setCardFlag(card, "-ny_tenth_fuxue")
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_luyi:addSkill(ny_10th_yaoyi)
ny_10th_luyi:addSkill(ny_10th_yaoyi_start)
ny_10th_luyi:addSkill(ny_tenth_fuxue)
ny_10th_luyi:addSkill(ny_tenth_fuxueVS)
extension:insertRelatedSkills("ny_10th_yaoyi", "#ny_10th_yaoyi_start")

ny_10th_xingcaoren = sgs.General(extension, "ny_10th_xingcaoren", "wei", 4, true, false, false)

ny_10th_sujun = sgs.CreateTriggerSkill{
    name = "ny_10th_sujun",
    events = {sgs.CardUsed, sgs.CardResponded},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local card
        if event == sgs.CardUsed then
            card = data:toCardUse().card
        elseif event == sgs.CardResponded then
            local response = data:toCardResponse()
            if response.m_isUse then
                card = response.m_card
            end
        end
        if (not card) or (card:isKindOf("SkillCard")) then return false end
        local basic = 0
        local nobasic = 0
        for _,cc in sgs.qlist(player:getHandcards()) do
            if cc:isKindOf("BasicCard") then
                basic = basic + 1
            else
                nobasic = nobasic + 1
            end
        end
        if basic ~= nobasic then return false end
        if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("draw")) then
            room:broadcastSkillInvoke(self:objectName())
            player:drawCards(2, self:objectName())
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_lifeng = sgs.CreateViewAsSkill{
    name = "ny_10th_lifeng",
    n = 99,
    view_filter = function(self, selected, to_select)
        if (not sgs.Self:getHandcards():contains(to_select)) then return false end
        if #selected >= 1 then return false end
        if to_select:isRed() and sgs.Self:getMark("ny_10th_lifeng_red-Clear") == 1 then return false end
        if to_select:isBlack() and sgs.Self:getMark("ny_10th_lifeng_black-Clear") == 1 then return false end
        if (not to_select:isRed()) and (not to_select:isBlack()) 
        and sgs.Self:getMark("ny_10th_lifeng_nocolor-Clear") == 1 then return false end
        return true
    end,
    view_as = function(self, cards)
        local card
        if sgs.Sanguosha:getCurrentCardUseReason() ~= sgs.CardUseStruct_CARD_USE_REASON_PLAY then
            local pattern = sgs.Sanguosha:getCurrentCardUsePattern():split("+")
            card = sgs.Sanguosha:cloneCard(pattern[1], sgs.Card_SuitToBeDecided, -1)
        end
        if #cards == 1 then
            local cc = ny_10th_lifengCard:clone()
            cc:addSubcard(cards[1])
            if card then cc:setUserString(card:objectName()) end
            return cc
        end
    end,
    enabled_at_play = function(self, player)
        return true
    end,
    enabled_at_nullification = function(self, player)
        return true
    end,
    enabled_at_response = function(self, player, pattern)
        if sgs.Sanguosha:getCurrentCardUseReason() ~= sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then return false end
        return pattern == "slash" or pattern == "Slash" or pattern == "nullification"
    end,
}

ny_10th_lifengCard = sgs.CreateSkillCard
{
    name = "ny_10th_lifeng",
    will_throw = false,
    filter = function(self, targets, to_select, player)
        local qtargets = sgs.PlayerList()
        for _,p in ipairs(targets) do
            qtargets:append(p)
        end
    
        local pattern = "slash"
        local user_string = self:getUserString()
        if user_string and user_string == "nullification" then
            pattern = "nullification"
        end
        local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
        card:setSkillName(self:objectName())

        if card:targetFixed() then return false end

        card:deleteLater()
        return card and card:targetFilter(qtargets, to_select, player) and not player:isProhibited(to_select, card, qtargets)
    end,
    feasible = function(self, targets, player)
        local user_string = "slash"
        if self:getUserString() and self:getUserString() == "nullification" then
            user_string = "nullification"
        end
        local use_card = sgs.Sanguosha:cloneCard(user_string, sgs.Card_SuitToBeDecided, -1)
        use_card:addSubcards(self:getSubcards())
        use_card:setSkillName(self:objectName())
        use_card:deleteLater()

        local qtargets = sgs.PlayerList()
        for _,p in ipairs(targets) do
            qtargets:append(p)
        end

        if use_card and use_card:canRecast() and #targets == 0 then
			return false
		end

        return use_card and use_card:targetsFeasible(qtargets, player) 
    end,
    on_validate = function(self, cardUse)
        local source = cardUse.from
        local room = source:getRoom()

        local pattern = "slash"
        local user_string = self:getUserString()
        if user_string and user_string == "nullification" then
            pattern = "nullification"
        end

        local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
        card:setSkillName(self:objectName())

        room:setCardFlag(card, "RemoveFromHistory")
        return card
    end,
    on_validate_in_response = function(self, source)
        local room = source:getRoom()
        local pattern = "slash"

        local user_string = self:getUserString()
        if user_string and user_string == "nullification" then
            pattern = "nullification"
        end

        local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
        card:setSkillName(self:objectName())

        room:setCardFlag(card, "RemoveFromHistory")

        return card
    end,
}

ny_10th_lifeng_record = sgs.CreateTriggerSkill{
    name = "#ny_10th_lifeng_record",
    events = {sgs.CardUsed, sgs.CardResponded},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local card
        if event == sgs.CardUsed then
            card = data:toCardUse().card
        elseif event == sgs.CardResponded then
            local response = data:toCardResponse()
            if response.m_isUse then
                card = response.m_card
            end
        end
        if (not card) or (card:isKindOf("SkillCard")) then return false end
        if card:isRed() then
            for _,target in sgs.qlist(room:findPlayersBySkillName("ny_10th_lifeng")) do
                room:setPlayerMark(target, "ny_10th_lifeng_red-Clear", 1)
            end
        elseif card:isBlack() then
            for _,target in sgs.qlist(room:findPlayersBySkillName("ny_10th_lifeng")) do
                room:setPlayerMark(target, "ny_10th_lifeng_black-Clear", 1)
            end
        else
            for _,target in sgs.qlist(room:findPlayersBySkillName("ny_10th_lifeng")) do
                room:setPlayerMark(target, "ny_10th_lifeng_nocolor-Clear", 1)
            end
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_10th_lifeng_buff = sgs.CreateTargetModSkill{
    name = "#ny_10th_lifeng_buff",
    residue_func = function(self, from, card)
        if card:getSkillName() == "ny_10th_lifeng" then return 1000 end
        return 0
    end,
}

ny_10th_xingcaoren:addSkill(ny_10th_sujun)
ny_10th_xingcaoren:addSkill(ny_10th_lifeng)
ny_10th_xingcaoren:addSkill(ny_10th_lifeng_record)
ny_10th_xingcaoren:addSkill(ny_10th_lifeng_buff)
extension:insertRelatedSkills("ny_10th_lifeng", "#ny_10th_lifeng_record")
extension:insertRelatedSkills("ny_10th_lifeng", "#ny_10th_lifeng_buff")

ny_10th_jiezhangsong = sgs.General(extension, "ny_10th_jiezhangsong", "shu", 3, true, false, false)

ny_10th_jxxiantu = sgs.CreateTriggerSkill{
    name = "ny_10th_jxxiantu",
    events = {sgs.EventPhaseStart,sgs.EventPhaseEnd,sgs.Damage},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseStart then
            for _,p in sgs.qlist(room:getOtherPlayers(player)) do
                if p:hasSkill(self:objectName()) and p:getMark("ny_10th_jxxiantufail-PlayClear") == 0 then
                    local prompt = string.format("draw:%s:",player:getGeneralName())
                    if room:askForSkillInvoke(p, self:objectName(), sgs.QVariant(prompt)) then
                        room:broadcastSkillInvoke(self:objectName())
                        room:setPlayerMark(p, "&ny_10th_jxxiantu-PlayClear", 1)
                        p:drawCards(2, self:objectName())
                        local give = room:askForExchange(p, self:objectName(), 2, 2, true, "@ny_10th_jxxiantu:"..player:getGeneralName(), false)
                        if give then
                            player:obtainCard(give, false)
                        end
                    else
                        room:setPlayerMark(p, "ny_10th_jxxiantufail-PlayClear", 1)
                    end
                end
            end
        end
        if event == sgs.Damage then
            room:setPlayerMark(player, "ny_10th_jxxiantuda-PlayClear", 1)
        end
        if event == sgs.EventPhaseEnd then
            if player:getMark("ny_10th_jxxiantuda-PlayClear") > 0 then return false end
            for _,p in sgs.qlist(room:getOtherPlayers(player)) do
                if p:hasSkill(self:objectName()) and p:getMark("&ny_10th_jxxiantu-PlayClear") > 0 then
                    room:broadcastSkillInvoke(self:objectName())
                    room:setPlayerMark(p, "&ny_10th_jxxiantu-PlayClear", 0)
                    room:sendCompulsoryTriggerLog(p, self:objectName())
                    room:loseHp(p, 1)
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target:getPhase() == sgs.Player_Play
    end,
}

local function getTypeString(card)
    local cardtype = nil
    local types = {"BasicCard","TrickCard","EquipCard"}
    for _,p in ipairs(types) do
        if card:isKindOf(p) then
            cardtype = p
            break
        end
    end
    return cardtype
end

ny_10th_jxqiangzhi = sgs.CreateTriggerSkill{
    name = "ny_10th_jxqiangzhi",
    events = {sgs.EventPhaseStart,sgs.CardUsed,sgs.CardResponded},
    frequency = sgs.Skill_Frequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseStart then
            local tas = sgs.SPlayerList()
            for _,p in sgs.qlist(room:getOtherPlayers(player)) do
                if p:getHandcardNum() > 0 then
                    tas:append(p)
                end
            end
            local ta = room:askForPlayerChosen(player, tas, self:objectName(), "@ny_10th_jxqiangzhi", true, true)
            if not ta then return false end
            room:broadcastSkillInvoke(self:objectName())
            local show = room:askForCardChosen(player, ta, "h", self:objectName())
            local showc = sgs.Sanguosha:getCard(show)
            local ctype = getTypeString(showc)
            room:setPlayerMark(player, "&ny_10th_jxqiangzhi+"..ctype.."-PlayClear", 1)
            room:showCard(ta, show)
            return false
        end
        local card = nil
        if event == sgs.CardUsed then
            card = data:toCardUse().card
        elseif event == sgs.CardResponded then
            local res = data:toCardResponse()
            if res.m_isUse then
                card = res.m_card
            end
        end
        if not card then return false end
        local ctype = getTypeString(card)
        if player:getMark("&ny_10th_jxqiangzhi+"..ctype.."-PlayClear") == 0 then return false end
        if not room:askForSkillInvoke(player, self:objectName(), data) then return false end
        room:broadcastSkillInvoke(self:objectName())
        player:drawCards(1, self:objectName())
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName()) and target:getPhase() == sgs.Player_Play
    end,
}

ny_10th_jiezhangsong:addSkill(ny_10th_jxxiantu)
ny_10th_jiezhangsong:addSkill(ny_10th_jxqiangzhi)

ny_10th_caochun = sgs.General(extension, "ny_10th_caochun", "wei", 4, true, false, false)

ny_tenth_shanjiaVS = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_tenth_shanjia",
    response_pattern = "@@ny_tenth_shanjia",
    view_as = function(self)
        local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
        slash:setSkillName(self:objectName())
        return slash
    end,
    enabled_at_play = function(self, player)
        return false
    end,
}

ny_tenth_shanjia = sgs.CreateTriggerSkill{
    name = "ny_tenth_shanjia",
    events = {sgs.CardsMoveOneTime, sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = ny_tenth_shanjiaVS,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardsMoveOneTime then
            local move = data:toMoveOneTime()
            if player:getMark("&ny_tenth_shanjia") >= 3 then return false end
            if move.from and move.from:objectName() == player:objectName()
            and (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip))
            then else return false end
            if (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_USE) then return false end
            local n = player:getMark("&ny_tenth_shanjia")
            for _,id in sgs.qlist(move.card_ids) do
                if sgs.Sanguosha:getCard(id):isKindOf("EquipCard") then
                    n = n + 1
                end
            end
            n = math.min(n, 3)
            room:setPlayerMark(player, "&ny_tenth_shanjia", n)
        end
        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.Player_Play then return false end
            local n = 3 - player:getMark("&ny_tenth_shanjia")
            n = math.max(n,0)
            local prompt = string.format("draw:%s:", n)
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant(prompt)) then
                room:broadcastSkillInvoke(self:objectName())
                player:drawCards(3, self:objectName())
                
                local canslash = true
                room:setPlayerMark(player, "ny_tenth_shanjia_slash-PlayClear", 1)
                room:setPlayerMark(player, "ny_tenth_shanjia_distance-PlayClear", 1)

                local dis
                if n > 0 then
                    dis = room:askForDiscard(player, self:objectName(), n, n, false, true)
                end
                if dis then
                    for _,id in sgs.qlist(dis:getSubcards()) do
                        if sgs.Sanguosha:getCard(id):isKindOf("BasicCard") then
                            room:setPlayerMark(player, "ny_tenth_shanjia_slash-PlayClear", 0)
                            canslash = false
                        end
                        if sgs.Sanguosha:getCard(id):isKindOf("TrickCard") then
                            room:setPlayerMark(player, "ny_tenth_shanjia_distance-PlayClear", 0)
                            canslash = false
                        end
                    end
                end
                if canslash then
                    room:askForUseCard(player, "@@ny_tenth_shanjia", "@ny_tenth_shanjia", -1,
                    sgs.Card_MethodUse, false, nil, nil, "RemoveFromHistory")
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_tenth_shanjia_buff = sgs.CreateTargetModSkill{
    name = "#ny_tenth_shanjia_buff",
    pattern = ".",
    residue_func = function(self, from, card)
        if from:getMark("ny_tenth_shanjia_slash-PlayClear") > 0 
        and card and card:isKindOf("Slash") then return 1 end
        return 0
    end,
    distance_limit_func = function(self, from, card)
        if from:getMark("ny_tenth_shanjia_distance-PlayClear") > 0 then return 1000 end
        return 0
    end,
}

ny_10th_caochun:addSkill(ny_tenth_shanjia)
ny_10th_caochun:addSkill(ny_tenth_shanjiaVS)
ny_10th_caochun:addSkill(ny_tenth_shanjia_buff)
extension:insertRelatedSkills("ny_tenth_shanjia", "#ny_tenth_shanjia_buff")

ny_10th_liuye = sgs.General(extension, "ny_10th_liuye", "wei", 3, true, false, false)

ny_tenth_piliche = sgs.CreateTreasure
{
	name = "_ny_tenth_piliche",
	class_name = "NyPiliche",
    suit = sgs.Card_Diamond,
    number = 9,
	target_fixed = true,
    subtype = "ny_10th_liuye_card",
	on_install = function(self,player)
		local room = player:getRoom()
        room:acquireSkill(player, "ny_tenth_piliche_target", false, false, false)
        room:acquireSkill(player, "ny_tenth_piliche_buff", false, false, false)
        room:acquireSkill(player, "ny_tenth_piliche_destory", false, false, false)
        room:acquireSkill(player, "ny_tenth_piliche_recover", false, false, false)
	end,
	on_uninstall = function(self,player)
		local room = player:getRoom()
        room:detachSkillFromPlayer(player, "ny_tenth_piliche_target", true, true, false)
        room:detachSkillFromPlayer(player, "ny_tenth_piliche_buff", true, true, false)
        room:detachSkillFromPlayer(player, "ny_tenth_piliche_recover", true, true, false)
        --room:detachSkillFromPlayer(player, "ny_tenth_piliche_buff", true, true, false)
	end,
}
ny_tenth_piliche:setParent(extension)

ny_tenth_piliche_target = sgs.CreateTargetModSkill{
    name = "ny_tenth_piliche_target",
    pattern = "BasicCard",
    distance_limit_func = function(self, from, card)
        if from:getEquip(4) and from:getEquip(4):objectName() == "_ny_tenth_piliche" 
        and from:getPhase() ~= sgs.Player_NotActive then return 1000 end
        return 0
    end,
}

ny_tenth_piliche_buff = sgs.CreateTriggerSkill{
    name = "ny_tenth_piliche_buff",
    events = {sgs.CardUsed, sgs.CardResponded, sgs.DamageCaused},
    frequency = sgs.Skill_Compulsory,
    priority = 10,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardUsed or event == sgs.CardResponded then
            local card
            if event == sgs.CardUsed then
                card = data:toCardUse().card
            elseif event == sgs.CardResponded then
                card = data:toCardResponse().m_card
            end
            if (not card) or (not card:isKindOf("BasicCard")) then return false end
            if player:getPhase() == sgs.Player_NotActive then
                room:sendCompulsoryTriggerLog(player, "_ny_tenth_piliche", true)
                player:drawCards(1, self:objectName())
            end
            if player:getPhase() ~= sgs.Player_NotActive then
                if card:isKindOf("Analeptic") and player:getHp() >= 1 then
                    local ana = player:getMark("drank")
                    ana = ana + 1
                    room:setPlayerMark(player, "drank", ana)
                end
                room:setCardFlag(card, "ny_tenth_piliche_buff")
            end
        end
        if event == sgs.DamageCaused then
            local damage = data:toDamage()
            if damage.chain then return false end
            if player:getPhase() == sgs.Player_NotActive then return false end
            if damage.card and damage.card:isKindOf("BasicCard") then
                local log = sgs.LogMessage()
                log.type = "$ny_tenth_piliche_damage"
                log.from = damage.from
                log.arg = "_ny_tenth_piliche"
                log.arg2 = damage.damage
                log.arg3 = damage.damage + 1
                log.card_str = damage.card:toString()
                room:sendLog(log)

                damage.damage = damage.damage + 1
                data:setValue(damage)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
        and target:getEquip(4) and target:getEquip(4):objectName() == "_ny_tenth_piliche"
    end,
}

ny_tenth_piliche_recover = sgs.CreateTriggerSkill{
    name = "ny_tenth_piliche_recover",
    events = {sgs.PreHpRecover},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.PreHpRecover then
            local recover = data:toRecover()
            if recover.card and recover.card:hasFlag("ny_tenth_piliche_buff") then
                local log = sgs.LogMessage()
                log.type = "$ny_tenth_piliche_recover"
                log.from = recover.from
                log.arg = "_ny_tenth_piliche"
                log.arg2 = recover.recover
                log.arg3 = recover.recover + 1
                log.card_str = recover.card:toString()
                room:sendLog(log)

                recover.recover = recover.recover + 1
                data:setValue(recover)
            end
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_tenth_piliche_destory = sgs.CreateTriggerSkill{
    name = "ny_tenth_piliche_destory",
    events = {sgs.BeforeCardsMove},
    frequency = sgs.Skill_Compulsory,
    priority = 50,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local move = data:toMoveOneTime()
        if move.from and move.from:objectName() == player:objectName() then else return false end
        local card = nil
        if move.from_places:contains(sgs.Player_PlaceEquip) and move.to_place ~= sgs.Player_PlaceTable then
            for _,id in sgs.qlist(move.card_ids) do
                if sgs.Sanguosha:getCard(id):objectName() == "_ny_tenth_piliche" then
                    card = sgs.Sanguosha:getCard(id)
                    move.card_ids:removeOne(id)
                end
            end
        end
        if card then
            room:sendCompulsoryTriggerLog(player, "_ny_tenth_piliche", true, true)
            local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), "ny_tenth_piliche","")
            local new_move = sgs.CardsMoveStruct(card:getId(), nil, sgs.Player_PlaceTable, reason)
            room:moveCardsAtomic(new_move, true)
            data:setValue(move)
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_poyuan = sgs.CreateTriggerSkill{
    name = "ny_10th_poyuan",
    events = {sgs.GameStart, sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    waked_skills = "_ny_tenth_piliche",
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.Player_RoundStart then return false end
        end
        if ((not player:getEquip(4)) 
            or (player:getEquip(4) and player:getEquip(4):objectName() ~= "_ny_tenth_piliche" ))
            and player:hasEquipArea(4) then
                local card = nil
                for _,id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
                    if sgs.Sanguosha:getEngineCard(id):isKindOf("NyPiliche") then
                        card = sgs.Sanguosha:getEngineCard(id)
                        break
                    end
                end
                if card then
                    if not room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("put")) then return false end
                    room:broadcastSkillInvoke(self:objectName())

                    if player:getEquip(4) then
                        room:throwCard(player:getEquip(4), player, player)
                    end

                    local log = sgs.LogMessage()
                    log.type = "$ny_10th_poyuan_get"
                    log.from = player
                    log.arg = self:objectName()
                    log.card_str = card:toString()
                    room:sendLog(log)

                    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), self:objectName(), "")
                    room:moveCardTo(card, nil, player, sgs.Player_PlaceEquip, reason)
                end
        else
                local targets = sgs.SPlayerList()
                for _,target in sgs.qlist(room:getOtherPlayers(player)) do
                    if (not target:isNude()) then
                        targets:append(target)
                    end
                end
                if targets:isEmpty() then return false end
                local target = room:askForPlayerChosen(player, targets, self:objectName(), "@@ny_10th_poyuan", true, true)
                if not target then return false end
                room:broadcastSkillInvoke(self:objectName())

                local choices = "1"
                if target:getCards("he"):length() > 1 then
                    choices = "1+2"
                end
                local max = tonumber(room:askForChoice(player, self:objectName(), choices, sgs.QVariant(), nil, "ny_10th_poyuan_dis"))

                --[[local places = {}
                local discards = sgs.IntList()
                room:setPlayerFlag(target, "mobilepojun_InTempMoving")
                for i = 1, max, 1 do
                    if not target:isNude() then
                        --local id = room:askForCardChosen(player, target, "he", "ny_10th_poyuan")
                        local id = room:askForCardChosen(player, target, "he", self:objectName(),
                        false, sgs.Card_MethodDiscard, sgs.IntList(), false)
                        discards:append(id)
                        table.insert(places, room:getCardPlace(id))
                        target:addToPile("#ny_10th_poyuan", id, false)
                    end
                end
                local i = 1
                for _,id in sgs.qlist(discards) do
                    room:moveCardTo(sgs.Sanguosha:getCard(id), target, places[i], false)
                    i = i + 1
                end
                room:setPlayerFlag(target, "-mobilepojun_InTempMoving")]]--

                local discards = cardsChosen(room, player, target, self:objectName(), "he", max)

                room:throwCard(discards, "ny_10th_poyuan", target, player)
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_huace = sgs.CreateViewAsSkill{
    name = "ny_10th_huace",
    n = 99,
    view_filter = function(self, selected, to_select)
        return #selected < 1 and sgs.Self:getHandcards():contains(to_select)
    end,
    view_as = function(self, cards)
        if #cards > 0 then
            local c = sgs.Self:getTag("ny_10th_huace"):toCard()
            if c then
                local cc = ny_10th_huaceCard:clone()
                cc:addSubcard(cards[1])
                cc:setUserString(c:objectName())
                return cc
            end
        end
    end,
    enabled_at_play = function(self, player)
        return not player:hasUsed("#ny_10th_huace")
    end
}
ny_10th_huace:setGuhuoDialog("r")

ny_10th_huaceCard = sgs.CreateSkillCard{
	name = "ny_10th_huace",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		local card = sgs.Sanguosha:cloneCard(self:getUserString(), sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
		card:setSkillName("ny_10th_huace")

		if card and card:targetFixed() then
			return false
		end
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		return card and card:targetFilter(qtargets, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, qtargets)
	end,
	feasible = function(self, targets)
		local card = sgs.Sanguosha:cloneCard(self:getUserString(), sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
		card:setSkillName("ny_10th_huace")

		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		if card and card:canRecast() and #targets == 0 then
			return false
		end
		return card and card:targetsFeasible(qtargets, sgs.Self)
	end,
	on_validate = function(self, card_use)
		local player = card_use.from
		local card = sgs.Sanguosha:cloneCard(self:getUserString(), sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
		card:setSkillName("ny_10th_huace")
		return card
	end,
}

ny_10th_huace_record = sgs.CreateTriggerSkill{
    name = "#ny_10th_huace_record",
    events = {sgs.CardUsed, sgs.CardResponded,sgs.RoundStart,sgs.GameStart,sgs.EventAcquireSkill},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local card 
        if event == sgs.CardUsed or event == sgs.CardResponded then
            if event == sgs.CardUsed then
                card = data:toCardUse().card
            else
                local response = data:toCardResponse()
                if response.m_isUse then
                    card = response.m_card
                end
            end
            if (not card) or (not card:isKindOf("TrickCard")) then return false end
            local used = room:getTag("ny_10th_huace_uesd"):toString():split("+")
            if not used then
                used = {}
            end
            if not table.contains(used, card:objectName()) then
                table.insert(used, card:objectName())
            end
            room:setTag("ny_10th_huace_uesd", sgs.QVariant(table.concat(used, "+")))
        end
        if event == sgs.RoundStart then
            local used = room:getTag("ny_10th_huace_uesd"):toString():split("+")
            if not used then return false end
            room:removeTag("ny_10th_huace_uesd")
            for _,target in sgs.qlist(room:getAlivePlayers()) do
                for _,name in ipairs(used) do
                    local mark = string.format("ny_10th_huace_guhuo_remove_%s_lun", name)
                    room:setPlayerMark(target, mark, 1)
                end
            end
        end
        if event == sgs.GameStart or event == sgs.EventAcquireSkill then
            if event == sgs.EventAcquireSkill then
                if data:toString() ~= "ny_10th_huace" then return false end
            end
            local tag = room:getTag("ny_10th_huace_cards")
            --if tag then return false end
            local names = {}
            for _,id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
                local card = sgs.Sanguosha:getEngineCard(id)
                if card:isNDTrick() then
                    local name = card:objectName()
                    if not table.contains(names, name) then
                        table.insert(names, name)
                    end
                end
            end
            room:setTag("ny_10th_huace_cards", sgs.QVariant(table.concat(names, "+")))
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_10th_liuye:addSkill(ny_10th_poyuan)
ny_10th_liuye:addSkill(ny_10th_huace)
ny_10th_liuye:addSkill(ny_10th_huace_record)
extension:insertRelatedSkills("ny_10th_huace", "#ny_10th_huace_record")

ny_10th_zhangjinyun = sgs.General(extension, "ny_10th_zhangjinyun", "shu", 3, false, false, false)

ny_10th_huizhi = sgs.CreateTriggerSkill{
    name = "ny_10th_huizhi",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.Player_Start then return false end
            if not room:askForSkillInvoke(player, self:objectName()) then return false end
            room:broadcastSkillInvoke(self:objectName())
            room:askForDiscard(player, self:objectName(), 999, 0, false, false, "@ny_10th_huizhi", ".", self:objectName())
            if player:isDead() then return false end
            local max = 0
            for _,target in sgs.qlist(room:getAlivePlayers()) do
                if target:getHandcardNum() > max then
                    max = target:getHandcardNum()
                end
            end
            if max <= player:getHandcardNum() then
                player:drawCards(1, self:objectName())
            else
                local draw = max - player:getHandcardNum()
                draw = math.min(draw, 5)
                player:drawCards(draw, self:objectName())
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_jijiao = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_10th_jijiao",
    limit_mark = "@ny_10th_jijiao_mark",
    frequency = sgs.Skill_Limited,
    view_as = function(self, player)
        return ny_10th_jijiaoCard:clone()
    end,
    enabled_at_play = function(self, player)
        return player:getMark("@ny_10th_jijiao_mark") > 0
        and player:getMark("ny_10th_jijiao_usedcard") > 0
    end
}

ny_10th_jijiaoCard = sgs.CreateSkillCard
{
    name = "ny_10th_jijiao",
    filter = function(self, targets, to_select)
        return #targets < 1
    end,
    on_effect = function(self, effect)
        local room = effect.from:getRoom()
        room:removePlayerMark(effect.from, "@ny_10th_jijiao_mark", 1)
        local ids = effect.from:getTag("ny_10th_jijiao_cards"):toIntList()
        local get = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, -1)
        get:deleteLater()
        for _,id in sgs.qlist(room:getDiscardPile()) do
            if ids:contains(id) then
                get:addSubcard(sgs.Sanguosha:getCard(id))
            end
        end
        if get:subcardsLength() == 0 then return false end
        room:obtainCard(effect.to, get, true)
        if effect.to:isDead() then return false end
        for _,id in sgs.qlist(get:getSubcards()) do
            local card = sgs.Sanguosha:getCard(id)
            room:setCardFlag(card, "ny_10th_jijiao")
            room:setCardTip(id, "ny_10th_jijiao")
        end
    end
}

ny_10th_jijiao_record = sgs.CreateTriggerSkill{
    name = "#ny_10th_jijiao_record",
    events = {sgs.CardsMoveOneTime},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local move = data:toMoveOneTime()
        if move.from and move.from:objectName() == player:objectName() then else return false end
        local ids = player:getTag("ny_10th_jijiao_cards"):toIntList()
        if not ids then ids = sgs.IntList() end

        if (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_USE) then
        elseif (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD) then
        else return false end

        for _,id in sgs.qlist(move.card_ids) do
            if sgs.Sanguosha:getCard(id):isNDTrick() and (not ids:contains(id)) then
                ids:append(id)
                room:setPlayerMark(player, "ny_10th_jijiao_usedcard", 1)
            end
        end

        local tag = sgs.QVariant()
        tag:setValue(ids)
        player:setTag("ny_10th_jijiao_cards", tag)

    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_jijiao_buff = sgs.CreateTriggerSkill{
    name = "#ny_10th_jijiao_buff",
    events = {sgs.EventPhaseChanging, sgs.Death, sgs.CardUsed, sgs.SwappedPile},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.Death or event == sgs.SwappedPile then
            for _,target in sgs.qlist(room:getAlivePlayers()) do
                room:setPlayerMark(target, "ny_10th_jijiao_new-Clear", 1)
            end
        end
        if event == sgs.EventPhaseChanging then
            local change = data:toPhaseChange()
            if change.to ~= sgs.Player_NotActive then return false end
            if player:getMark("ny_10th_jijiao_new-Clear") == 0 then return false end
            for _,skiller in sgs.qlist(room:findPlayersBySkillName("ny_10th_jijiao")) do
                if skiller:getMark("@ny_10th_jijiao_mark") == 0 then
                    room:setPlayerMark(skiller, "@ny_10th_jijiao_mark", 1)
                    room:broadcastSkillInvoke("ny_10th_jijiao")
                    local log = sgs.LogMessage()
                    log.type = "$ny_10th_jijiao_renew"
                    log.from = skiller
                    log.arg = "ny_10th_jijiao"
                    room:sendLog(log)
                end
            end
        end
        if event == sgs.CardUsed then
            local use = data:toCardUse()
            if use.card and use.card:hasFlag("ny_10th_jijiao") then
                local log = sgs.LogMessage()
                log.type = "$ny_10th_jijiao_nooffset"
                log.from = use.from
                log.arg = "ny_10th_jijiao"
                log.card_str = use.card:toString()
                room:sendLog(log)

                local no_offset_list = use.no_offset_list
                table.insert(no_offset_list, "_ALL_TARGETS")
                use.no_offset_list = no_offset_list
                data:setValue(use)
            end
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_10th_zhangjinyun:addSkill(ny_10th_huizhi)
ny_10th_zhangjinyun:addSkill(ny_10th_jijiao)
ny_10th_zhangjinyun:addSkill(ny_10th_jijiao_record)
ny_10th_zhangjinyun:addSkill(ny_10th_jijiao_buff)
extension:insertRelatedSkills("ny_10th_jijiao","#ny_10th_jijiao_record")
extension:insertRelatedSkills("ny_10th_jijiao","#ny_10th_jijiao_buff")

ny_10th_chenshi = sgs.General(extension, "ny_10th_chenshi", "shu", 4, true, false, false)

local function ny_10th_qingbei_log(chosen, player)
    local log = sgs.LogMessage()
    log.type = "$ny_10th_qingbei_chosen"..#chosen
    log.from = player
    log.arg = "ny_10th_qingbei"
    if #chosen >= 1 then log.arg2 = chosen[1] end
    if #chosen >= 2 then log.arg3 = chosen[2] end
    if #chosen >= 3 then log.arg4 = chosen[3] end
    if #chosen >= 4 then log.arg5 = chosen[4] end
    return log
end

ny_10th_qingbei = sgs.CreateTriggerSkill{
    name = "ny_10th_qingbei",
    events = {sgs.RoundStart, sgs.CardUsed, sgs.CardResponded, --[[sgs.PreCardResponded, sgs.PreCardUsed]]},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.RoundStart then
            local suits = {"heart","diamond","spade","club","cancel"}
            local chosen = {}
            while( #suits > 0) do
                local suit = room:askForChoice(player, self:objectName(), table.concat(suits, "+"), sgs.QVariant(), table.concat(chosen, "+"))
                if suit == "cancel" then
                    break
                else
                    table.insert(chosen, suit)
                    table.removeOne(suits, suit)
                end
            end
            if #chosen == 0 then return false end
            local log = ny_10th_qingbei_log(chosen, player)
            room:sendLog(log)
            room:broadcastSkillInvoke(self:objectName())

            local mark = "&ny_10th_qingbei+:"
            for _,suit in ipairs(chosen) do
                room:setPlayerMark(player, string.format("ny_10th_qingbei_mark_%s_lun", suit), 1)
                mark = mark.."+"..suit.."_char"
            end
            room:setPlayerMark(player, mark.."+_lun", 1)
            room:setPlayerMark(player, "ny_10th_qingbei+_lun", #chosen)
        end

        if event == sgs.CardUsed or event == sgs.CardResponded then
            if player:getMark("ny_10th_qingbei+_lun") <= 0 then return false end
            local caninvoke = false
            if event == sgs.CardUsed then
                --card = data:toCardUse().card
                local use = data:toCardUse()
                if (not use.card:isKindOf("SkillCard")) and use.m_isHandcard then caninvoke = true end
            else
                local response = data:toCardResponse()
                if (not response.m_card) or response.m_card:isKindOf("SkillCard") then return false end
                if response.m_isUse and response.m_isHandcard then
                    caninvoke = true
                end
            end
            if not caninvoke then return false end
            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
            player:drawCards(player:getMark("ny_10th_qingbei+_lun"), self:objectName())
        end

        --[[if event == sgs.PreCardUsed or event == sgs.PreCardResponded then
            if player:getMark("ny_10th_qingbei+_lun") <= 0 then return false end
            local card
            if event == sgs.PreCardUsed then
                card = data:toCardUse().card
            else
                local response = data:toCardResponse()
                if response.m_isUse then
                    card = response.m_card
                end
            end
            if (not card) or (card:isKindOf("SkillCard")) then return false end
            if card:isVirtualCard() then return false end
            if room:getCardPlace(card:getEffectiveId()) ~= sgs.Player_PlaceHand then return false end
            room:setCardFlag(card, "ny_10th_qingbei")
        end]]

    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_qingbei_limit = sgs.CreateCardLimitSkill
{
    name = "#ny_10th_qingbei_limit",
    limit_list = function(self, player)
        if player:getMark("ny_10th_qingbei+_lun") > 0 then 
            return "use"
        else
            return ""
        end
    end,
    limit_pattern = function(self, player)
        if player:getMark("ny_10th_qingbei+_lun") > 0 then 
            local suits = {"heart","diamond","spade","club","cancel"}
            local limits = {}
            for _,suit in ipairs(suits) do
                if player:getMark(string.format("ny_10th_qingbei_mark_%s_lun", suit)) > 0 then
                    table.insert(limits, suit)
                end
            end
            local limit = string.format(".|%s|.|.",table.concat(limits,","))
            return limit
        else
            return ""
        end
    end,
}

ny_10th_chenshi:addSkill(ny_10th_qingbei)
ny_10th_chenshi:addSkill(ny_10th_qingbei_limit)
extension:insertRelatedSkills("ny_10th_qingbei", "#ny_10th_qingbei_limit")

ny_10th_ruanji = sgs.General(extension, "ny_10th_ruanji", "wei", 3, true, false, false)

ny_10th_jiudun = sgs.CreateTriggerSkill{
    name = "ny_10th_jiudun",
    events = {sgs.TargetConfirmed},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.TargetConfirmed then
            local use = data:toCardUse()
            if (not use.to:contains(player)) then return false end
            if player:isDead() then return false end
            if use.from:objectName() ~= player:objectName() and (not use.card:isKindOf("SkillCard"))
            and use.card:isBlack() then else return false end

            if player:getMark("drank") == 0 then
                if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("draw")) then
                    room:broadcastSkillInvoke(self:objectName())
                    player:drawCards(1, self:objectName())
                    if player:isDead() then return false end
                    local usec = sgs.CardUseStruct()
                    local analeptic = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_SuitToBeDecided, -1)
                    analeptic:setSkillName("_"..self:objectName())
                    if not analeptic:isAvailable(player) then 
                        analeptic:deleteLater()
                        return false
                    end
                    usec.card = analeptic
                    usec.from = player
                    usec.to:append(player)
                    room:useCard(usec, false)
                end
            else
                local prompt = string.format("@ny_10th_jiudun:%s:", use.card:objectName())
                room:setTag("ny_10th_jiudun_card", data)
                if room:askForDiscard(player, self:objectName(), 1, 1, true, false, prompt, ".", self:objectName()) then
                    local nullified_list = use.nullified_list
		            table.insert(nullified_list, player:objectName())
		            use.nullified_list = nullified_list
		            data:setValue(use)
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_jiudun_buff = sgs.CreateTriggerSkill{
    name = "#ny_10th_jiudun_buff",
    events = {sgs.EventPhaseChanging},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseChanging then
            local change = data:toPhaseChange()
            if change.to == sgs.Player_NotActive then
                for _,target in sgs.qlist(room:getAlivePlayers()) do
                    if target:hasSkill("ny_10th_jiudun") and target:getMark("drank") > 0 then
                        room:addPlayerMark(target, "ny_10th_jiudun", target:getMark("drank"))
                        room:setPlayerMark(target, "drank", 0)
                    end
                end
            end
            if change.from == sgs.Player_NotActive then
                for _,target in sgs.qlist(room:getAlivePlayers()) do
                    if target:hasSkill("ny_10th_jiudun") and target:getMark("ny_10th_jiudun") > 0 then
                        room:addPlayerMark(target, "drank", target:getMark("ny_10th_jiudun"))
                        room:setPlayerMark(target,"ny_10th_jiudun", 0)
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_10th_zhaowenVS = sgs.CreateViewAsSkill{
    name = "ny_10th_zhaowen",
    n = 1,
    guhuo_type = "r",
    view_filter = function(self, selected, to_select)
        return to_select:isBlack() and #selected < 1
        and sgs.Self:getHandcards():contains(to_select)
        and to_select:hasFlag("ny_10th_zhaowen")
    end,
    view_as = function(self, cards)
        if #cards > 0 then
            local c = sgs.Self:getTag("ny_10th_zhaowen"):toCard()
            if c then
                local cc = ny_10th_zhaowenCard:clone()
                cc:addSubcard(cards[1])
                cc:setUserString(c:objectName())
                return cc
            end
        end
    end,
    enabled_at_play = function(self, player)
        return true
    end,
}

ny_10th_zhaowenCard = sgs.CreateSkillCard{
	name = "ny_10th_zhaowen",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		local card = sgs.Sanguosha:cloneCard(self:getUserString(), sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
		card:setSkillName("ny_10th_zhaowen")
        card:deleteLater()

		if card and card:targetFixed() then
			return false
		end
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		return card and card:targetFilter(qtargets, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, qtargets)
	end,
	feasible = function(self, targets)
		local card = sgs.Sanguosha:cloneCard(self:getUserString(), sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
		card:setSkillName("ny_10th_zhaowen")
        card:deleteLater()

		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		if card and card:canRecast() and #targets == 0 then
			return false
		end
		return card and card:targetsFeasible(qtargets, sgs.Self)
	end,
	on_validate = function(self, card_use)
		local player = card_use.from
		local card = sgs.Sanguosha:cloneCard(self:getUserString(), sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
		card:setSkillName("ny_10th_zhaowen")

        local room = player:getRoom()
        room:setPlayerMark(player, "ny_10th_zhaowen_guhuo_remove_"..self:getUserString().."-Clear", 1)
		return card
	end,
}

ny_10th_zhaowen = sgs.CreateTriggerSkill{
    name = "ny_10th_zhaowen",
    events = {sgs.EventPhaseStart, sgs.CardUsed,sgs.CardResponded},
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = ny_10th_zhaowenVS,
    guhuo_type = "r",
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.Player_Play then return false end
            if player:isKongcheng() then return false end
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("show")) then
                room:broadcastSkillInvoke(self:objectName())
                local ids = sgs.IntList()
                for _,card in sgs.qlist(player:getHandcards()) do
                    ids:append(card:getId())
                end
                room:showCard(player, ids)
                for _,card in sgs.qlist(player:getHandcards()) do
                    room:setCardFlag(card, "ny_10th_zhaowen")
                    room:setCardTip(card:getEffectiveId(), "ny_10th_zhaowen")
                end
            end
        end
        if event == sgs.CardUsed or event == sgs.CardResponded then
            local card
            if event == sgs.CardUsed then
                card = data:toCardUse().card
            else
                local response = data:toCardResponse()
                if response.m_isUse then
                    card = response.m_card
                end
            end
            if (not card) or card:isKindOf("SkillCard") then return false end
            if (not card:isRed()) or (not card:hasFlag("ny_10th_zhaowen")) then return false end
            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
            player:drawCards(1, self:objectName())
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_zhaowen_clear = sgs.CreateTriggerSkill{
    name = "#ny_10th_zhaowen_clear",
    events = {sgs.EventPhaseChanging,sgs.GameStart,sgs.EventAcquireSkill},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseChanging then
            local change = data:toPhaseChange()
            if change.to == sgs.Player_NotActive then
                for _,card in sgs.qlist(player:getHandcards()) do
                    room:setCardFlag(card, "-ny_10th_zhaowen")
                    room:setCardTip(card:getEffectiveId(), "-ny_10th_zhaowen")
                end
            end
        end

        --给ai认牌的
        if event == sgs.GameStart or event == sgs.EventAcquireSkill then
            if event == sgs.EventAcquireSkill then
                if data:toString() ~= "ny_10th_zhaowen" then return false end
            end
            --local tag = room:getTag("ny_10th_zhaowen_cards")
            --if tag then return false end
            local names = {}
            for _,id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
                local card = sgs.Sanguosha:getEngineCard(id)
                if card:isNDTrick() then
                    local name = card:objectName()
                    if not table.contains(names, name) then
                        table.insert(names, name)
                    end
                end
            end
            room:setTag("ny_10th_zhaowen_cards", sgs.QVariant(table.concat(names, "+")))
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_ruanji:addSkill(ny_10th_jiudun)
ny_10th_ruanji:addSkill(ny_10th_jiudun_buff)
ny_10th_ruanji:addSkill(ny_10th_zhaowen)
ny_10th_ruanji:addSkill(ny_10th_zhaowenVS)
ny_10th_ruanji:addSkill(ny_10th_zhaowen_clear)
extension:insertRelatedSkills("ny_10th_jiudun", "#ny_10th_jiudun_buff")
extension:insertRelatedSkills("ny_10th_zhaowen", "#ny_10th_zhaowen_clear")

ny_10th_liuhui = sgs.General(extension, "ny_10th_liuhui", "qun", 4, true, false, false)

local function ny_gusuan_chosen(player, selected, num)
    local room = player:getRoom()
    local targets =  sgs.SPlayerList()
    for _,target in sgs.qlist(room:getAlivePlayers()) do
        if not selected:contains(target) then
            targets:append(target)
        end
    end
    if targets:isEmpty() then return nil end
    local prompt
    if num == 1 then prompt = "ny_10th_gusuan_draw"
    elseif num == 2 then prompt = "ny_10th_gusuan_discard"
    elseif num == 3 then prompt = "ny_10th_gusuan_change" end
    
    room:setPlayerFlag(player, prompt)
    local target = room:askForPlayerChosen(player, targets, "ny_10th_geyuan", prompt, true, true)
    room:broadcastSkillInvoke("ny_10th_gusuan")
    room:setPlayerFlag(player, "-"..prompt)
    return target
end

ny_10th_geyuan = sgs.CreateTriggerSkill{
    name = "ny_10th_geyuan",
    events = {sgs.GameStart,sgs.CardsMoveOneTime,sgs.EventForDiy},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.GameStart then
            local allnums = {}
            for i = 1, 13, 1 do
                table.insert(allnums, i)
            end
            local circle = {}
            while(#allnums > 0) do
                local num = allnums[math.random(1,#allnums)]
                table.insert(circle, num)
                table.removeOne(allnums, num)
            end
            room:broadcastSkillInvoke(self:objectName())
            room:setPlayerMark(player, "&ny_10th_geyuan_last", #circle)
            player:setTag("ny_10th_geyuan_circle", sgs.QVariant(table.concat(circle, "+")))
        end
        if event == sgs.CardsMoveOneTime then
            local move = data:toMoveOneTime()
            if player:hasFlag("ny_10th_gusuan") then return false end
            if move.to_place ~= sgs.Player_DiscardPile then return false end
            local circle = player:getTag("ny_10th_geyuan_circle"):toString():split("+")
            if (not circle) or (#circle <= 0) then return false end
            if player:getMark("&ny_10th_geyuan_last") == #circle then
                for _,id in sgs.qlist(move.card_ids) do
                    local num = sgs.Sanguosha:getCard(id):getNumber()
                    if table.contains(circle, string.format("%d", num)) then
                        room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                        room:setPlayerMark(player, "ny_10th_geyuan_cf", num)
                        local nowcircle = {}
                        local position = -1
                        for i = 1, #circle, 1 do
                            if tonumber(circle[i]) == num then
                                position = i
                            end
                            if (i ~= position) and (position ~= -1) then
                                table.insert(nowcircle, circle[i])
                            end
                        end
                        for i = 1, position - 1, 1 do
                            table.insert(nowcircle, circle[i])
                        end
                        room:setPlayerMark(player, "&ny_10th_geyuan_last", #nowcircle)
                        room:setPlayerMark(player, "&ny_10th_geyuan_head", nowcircle[1])
                        room:setPlayerMark(player, "&ny_10th_geyuan_tail", nowcircle[#nowcircle])
                        player:setTag("ny_10th_geyuan_circle_now", sgs.QVariant(table.concat(nowcircle, "+")))
                        break
                    end
                end
            else
                local nowcircle = player:getTag("ny_10th_geyuan_circle_now"):toString():split("+")
                if (not nowcircle) or (#nowcircle <= 0) then return false end
                local finish = -1
                if #nowcircle > 1 then
                    local first = false
                    local last = false
                    for _,id in sgs.qlist(move.card_ids) do
                        local num = sgs.Sanguosha:getCard(id):getNumber()
                        if (not first) and num == tonumber(nowcircle[1]) then
                            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                            first = true
                            if #nowcircle == 1 then
                                finish = num
                            end
                            table.removeOne(nowcircle, nowcircle[1])
                        end
                        if (not last) and num == tonumber(nowcircle[#nowcircle]) then
                            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                            last = true
                            if #nowcircle == 1 then
                                finish = num
                            end
                            table.removeOne(nowcircle, nowcircle[#nowcircle])
                        end
                        if first and last then break end
                    end
                    if (first or last) and (#nowcircle > 0) then
                        room:setPlayerMark(player, "&ny_10th_geyuan_last", #nowcircle)
                        room:setPlayerMark(player, "&ny_10th_geyuan_head", nowcircle[1])
                        room:setPlayerMark(player, "&ny_10th_geyuan_tail", nowcircle[#nowcircle])
                        player:setTag("ny_10th_geyuan_circle_now", sgs.QVariant(table.concat(nowcircle, "+")))
                    elseif (#nowcircle == 0) then
                        room:setPlayerMark(player, "&ny_10th_geyuan_last", 0)
                        room:setPlayerMark(player, "&ny_10th_geyuan_head", 0)
                        room:setPlayerMark(player, "&ny_10th_geyuan_tail", 0)
                        player:removeTag("ny_10th_geyuan_circle_now")
                    end
                else
                    local en = false
                    for _,id in sgs.qlist(move.card_ids) do
                        local num = sgs.Sanguosha:getCard(id):getNumber()
                        if num == tonumber(nowcircle[1]) and (not en) then
                            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                            en = true
                            finish = num
                            table.removeOne(nowcircle, nowcircle[1])
                            break
                        end
                    end
                    if en then
                        room:setPlayerMark(player, "&ny_10th_geyuan_last", 0)
                        room:setPlayerMark(player, "&ny_10th_geyuan_head", 0)
                        room:setPlayerMark(player, "&ny_10th_geyuan_tail", 0)
                        player:removeTag("ny_10th_geyuan_circle_now")
                    end
                end
                if finish > 0 then
                    room:setPlayerMark(player, "ny_10th_geyuan_cn", finish)
                    room:getThread():trigger(sgs.EventForDiy, room, player, sgs.QVariant("ny_10th_geyuan_finish"))
                end
            end
        end
        if event == sgs.EventForDiy then
            local str = data:toString()
            if string.find(str, "ny_10th_geyuan_finish") then
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                if player:getMark("ny_10th_gusuan") == 0 then
                    local num1 = player:getMark("ny_10th_geyuan_cn")
                    local num2 = player:getMark("ny_10th_geyuan_cf")
                    local get = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, -1)
                    for _,id in sgs.qlist(room:getDrawPile()) do
                        local num = sgs.Sanguosha:getCard(id):getNumber()
                        if num == num1 or num == num2 then
                            get:addSubcard(sgs.Sanguosha:getCard(id))
                        end
                    end
                    for _,pl in sgs.qlist(room:getAlivePlayers()) do
                        for _,card in sgs.qlist(pl:getCards("ej")) do
                            local num = card:getNumber()
                            if num == num1 or num == num2 then
                                get:addSubcard(card)
                            end
                        end
                    end
                    if get:subcardsLength() > 0 then
                        room:obtainCard(player, get, false)
                    end
                    get:deleteLater()
                    local circle = player:getTag("ny_10th_geyuan_circle"):toString():split("+")
                    table.removeOne(circle, string.format("%d", num1))
                    table.removeOne(circle, string.format("%d", num2))
                    room:setPlayerMark(player, "&ny_10th_geyuan_last", #circle)
                    player:setTag("ny_10th_geyuan_circle", sgs.QVariant(table.concat(circle, "+")))
                else
                    room:setPlayerFlag(player, "ny_10th_gusuan")
                    
                    local selected = sgs.SPlayerList()
                    local target1 = ny_gusuan_chosen(player, selected, 1)
                    local target2
                    local target3
                    if target1 then 
                        selected:append(target1)
                        target1:drawCards(3,self:objectName())
                        target2 = ny_gusuan_chosen(player, selected, 2)
                        if target2 then
                            selected:append(target2)
                            room:askForDiscard(target2, self:objectName(), 4, 4, false, true)
                            target3 = ny_gusuan_chosen(player, selected, 3)
                            if target3 and (not target3:isKongcheng()) then
                                local get = room:getNCards(5, false, false)
                                room:returnToEndDrawPile(get)
                                local hand = sgs.IntList()
                                for _,card in sgs.qlist(target3:getHandcards()) do
                                    hand:append(card:getId())
                                end
                                room:moveCardsToEndOfDrawpile(target3, hand, self:objectName())
                                if target3:isAlive() then
                                    local dummy = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, -1)
                                    dummy:addSubcards(get)
                                    room:obtainCard(target3, dummy, false)
                                end
                            end
                        end
                    end

                    room:setPlayerFlag(player, "-ny_10th_gusuan")
                    local circle = player:getTag("ny_10th_geyuan_circle"):toString():split("+")
                    room:setPlayerMark(player, "&ny_10th_geyuan_last", #circle)
                    player:setTag("ny_10th_geyuan_circle", sgs.QVariant(table.concat(circle, "+")))
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
        and target:isAlive()
    end,
}

ny_10th_jieshu = sgs.CreateTriggerSkill{
    name = "ny_10th_jieshu",
    events = {sgs.CardUsed,sgs.CardResponded,sgs.EventPhaseChanging},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseChanging then
            local change = data:toPhaseChange()
            if change.to ~= sgs.Player_Discard then return false end
            local circle = player:getTag("ny_10th_geyuan_circle"):toString():split("+")
            if (not circle) or (#circle <= 0) then return false end
            local circlenum = {}
            for _,num in ipairs(circle) do
                table.insert(circlenum, tonumber(num))
            end
            for _,card in sgs.qlist(player:getHandcards()) do
                if (not table.contains(circlenum, card:getNumber())) then
                    room:ignoreCards(player, card)
                end
            end
        end
        if event == sgs.CardUsed or event == sgs.CardResponded then
            local card
            if event == sgs.CardUsed then
                card = data:toCardUse().card
            else
                card = data:toCardResponse().m_card
            end
            if (not card) or (card:isKindOf("SkillCard")) then return false end
            if card:getNumber() <= 0 then return false end
            local circle = player:getTag("ny_10th_geyuan_circle"):toString():split("+")
            if (not circle) or (#circle <= 0) then return false end
            if player:getMark("&ny_10th_geyuan_last") == #circle then
                if  table.contains(circle, tostring(card:getNumber())) then
                    room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                    player:drawCards(1, self:objectName())
                end
            else
                if card:getNumber() == player:getMark("&ny_10th_geyuan_head")
                or card:getNumber() == player:getMark("&ny_10th_geyuan_tail") then
                    room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                    player:drawCards(1, self:objectName())
                end
            end
        end       
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_gusuan = sgs.CreateTriggerSkill{
    name = "ny_10th_gusuan",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_Wake,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        for _,p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
            local circle = player:getTag("ny_10th_geyuan_circle"):toString():split("+")
            if (not circle) or (#circle <= 0) then circle = {} end
            if  p:getMark("ny_10th_gusuan") == 0 and p:isAlive()
            and (p:canWake(self:objectName()) or #circle == 3) then
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                room:setPlayerMark(player, "ny_10th_gusuan", 1)
                room:loseMaxHp(p, 1)
            end
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_10th_liuhui:addSkill(ny_10th_geyuan)
ny_10th_liuhui:addSkill(ny_10th_jieshu)
ny_10th_liuhui:addSkill(ny_10th_gusuan)

ny_10th_sufei = sgs.General(extension, "ny_10th_sufei", "wu", 4, true, false, false)

ny_tenth_shujian = sgs.CreateViewAsSkill
{
    name = "ny_tenth_shujian",
    response_pattern = "@@ny_tenth_shujian",
    n = 999,
    view_filter = function(self, selected, to_select)
        if sgs.Self:hasFlag("ny_tenth_shujian") then return false end
        return #selected < 1
    end,
    view_as = function(self,cards)
        if (not sgs.Self:hasFlag("ny_tenth_shujian")) then
            if #cards > 0 then
                local card = ny_tenth_shujianCard:clone()
                card:addSubcard(cards[1])
                return card
            end
            return nil
        else
            local card = sgs.Sanguosha:cloneCard("dismantlement", sgs.Card_SuitToBeDecided, -1)
            card:setSkillName("_ny_tenth_shujian")
            return card
        end
    end,
    enabled_at_play = function(self, player)
        return (player:usedTimes("#ny_tenth_shujian") < 3) and player:getMark("ny_tenth_shujian_failed-PlayClear") == 0
    end,
}

ny_tenth_shujianCard = sgs.CreateSkillCard
{
    name = "ny_tenth_shujian",
    will_throw = false,
    filter = function(self, targets, to_select)
        return #targets < 1 and to_select:objectName() ~= sgs.Self:objectName()
    end,
    on_effect = function(self, effect)
        local room = effect.from:getRoom()
        room:obtainCard(effect.to, self, false)
        local n = 3 - effect.from:getMark("ny_tenth_shujian-PlayClear")
        room:addPlayerMark(effect.from, "ny_tenth_shujian-PlayClear", 1)
        local choices = {}
        table.insert(choices, string.format("draw=%d=%d", n, n - 1))
        table.insert(choices, string.format("dis=%d", n))
        local choice = ""
        local data = sgs.QVariant()
        data:setValue(effect.from)
        if effect.to:isAlive() then choice = room:askForChoice(effect.to, self:objectName(), table.concat(choices, "+"), data) end
        if effect.from:isAlive() and string.find(choice, "draw") then
            effect.from:drawCards(n, self:objectName())
            room:askForDiscard(effect.from, self:objectName(), n-1, n-1, false, true)
        end
        if effect.to:isAlive() and string.find(choice, "dis") then
            room:addPlayerMark(effect.from, "ny_tenth_shujian_failed-PlayClear", 1)
            room:setPlayerFlag(effect.to, "ny_tenth_shujian")
            for i = 1, n, 1 do
                local prompt = string.format("@ny_tenth_shujian:%s::%s:", i, n)
                if not room:askForUseCard(effect.to, "@@ny_tenth_shujian", prompt) then break end
                if effect.to:isDead() then break end
            end
        end
    end

}

ny_10th_sufei:addSkill(ny_tenth_shujian)

ny_10th_wuban = sgs.General(extension, "ny_10th_wuban", "shu", 4, true, false, false)

ny_10th_youzhan = sgs.CreateTriggerSkill{
    name = "ny_10th_youzhan",
    events = {sgs.CardsMoveOneTime,sgs.EventPhaseStart},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardsMoveOneTime then
            if player:getPhase() == sgs.Player_NotActive then return false end
            local move = data:toMoveOneTime()
            if move.from and move.from:objectName() ~= player:objectName() then else return false end
            if move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip) then else return false end
            local target = room:findPlayerByObjectName(move.from:objectName())
            if (not target) or target:isDead() then return false end
            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
            room:addPlayerMark(target, "&ny_10th_youzhan-Clear", 1)
            room:addPlayerMark(target, "ny_10th_youzhan_damageup-Clear", 1)
            local cards = player:drawCardsList(1, self:objectName())
            for _,id in sgs.qlist(cards) do
                local card = sgs.Sanguosha:getCard(id)
                room:setCardFlag(card, "ny_10th_youzhan")
                room:setCardTip(id, "ny_10th_youzhan")
            end
            room:ignoreCards(player, cards)
        end
        if event == sgs.EventPhaseStart then
            if player:getPhase() == sgs.Player_NotActive then
                for _,card in sgs.qlist(player:getHandcards()) do
                    local id = card:getId()
                    room:setCardFlag(card, "-ny_10th_youzhan")
                    room:setCardTip(id, "-ny_10th_youzhan")
                end
            end
            if player:getPhase() == sgs.Player_Finish then
                local send = true
                for _,p in sgs.qlist(room:getOtherPlayers(player)) do
                    if p:getMark("&ny_10th_youzhan-Clear") > 0 and p:getMark("ny_10th_youzhan_damaged-Clear") == 0 then
                        if send then 
                            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                            send = false
                        end
                        local n = math.min(p:getMark("&ny_10th_youzhan-Clear"), 3)
                        p:drawCards(n, self:objectName())
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_youzhan_buff = sgs.CreateTriggerSkill{
    name = "#ny_10th_youzhan_buff",
    events = {sgs.Damaged,sgs.DamageInflicted},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.Damaged then
            room:addPlayerMark(player, "ny_10th_youzhan_damaged-Clear", 1)
        end
        if event == sgs.DamageInflicted then
            if player:getMark("ny_10th_youzhan_damageup-Clear") == 0 then return false end
            local n = player:getMark("ny_10th_youzhan_damageup-Clear")
            room:setPlayerMark(player, "ny_10th_youzhan_damageup-Clear", 0)
            local damage = data:toDamage()

            local log = sgs.LogMessage()
            log.type = "$ny_10th_youzhan_damage"
            log.from = player
            log.arg = "ny_10th_youzhan"
            log.arg2 = damage.damage
            log.arg3 = damage.damage + n
            room:sendLog(log)
            room:broadcastSkillInvoke("ny_10th_youzhan")

            damage.damage = damage.damage + n
            data:setValue(damage)
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_10th_wuban:addSkill(ny_10th_youzhan)
ny_10th_wuban:addSkill(ny_10th_youzhan_buff)
extension:insertRelatedSkills("ny_10th_youzhan", "#ny_10th_youzhan_buff")

ny_10th_guannin = sgs.General(extension, "ny_10th_guannin", "shu", 3, true, false, false)

ny_tenth_xiuwen = sgs.CreateTriggerSkill{
    name = "ny_tenth_xiuwen",
    events = {sgs.CardUsed,sgs.CardResponded},
    frequency = sgs.Skill_Frequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local card
        if event == sgs.CardUsed then
            card = data:toCardUse().card
        else
            local response = data:toCardResponse()
            if response.m_isUse then 
                card = response.m_card
            end
        end
        if (not card) or (card:isKindOf("SkillCard")) then return false end
        local mark = string.format("ny_tenth_xiuwen_%s", card:objectName())
        if player:getMark(mark) == 0 then
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("draw")) then
                room:broadcastSkillInvoke(self:objectName())
                room:addPlayerMark(player, mark, 1)
                player:drawCards(1, self:objectName())
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_tenth_longsongVS = sgs.CreateViewAsSkill{
    name = "ny_tenth_longsong",
    response_pattern = "@@ny_tenth_longsong",
    n = 99,
    view_filter = function(self, selected, to_select)
        return to_select:isRed() and #selected < 1
    end,
    view_as = function(self, cards)
        if #cards == 1 then
            local card = ny_tenth_longsongCard:clone()
            card:addSubcard(cards[1])
            return card
        end
    end,
    enabled_at_play = function(self, player)
        return false
    end
}

ny_tenth_longsongCard = sgs.CreateSkillCard
{
    name = "ny_tenth_longsong",
    will_throw = false,
    filter = function(self, targets, to_select)
        return #targets < 1 and to_select:objectName() ~= sgs.Self:objectName()
    end,
    on_effect = function(self, effect)
        local room = effect.from:getRoom()
        effect.to:obtainCard(self, false)
        local skills = effect.to:getVisibleSkillList()
        local skillnames = {}
        for _,s in sgs.qlist(skills) do
            local skillname = s:objectName()
            if (not s:isAttachedLordSkill()) and (not effect.from:hasSkill(skillname)) then
                local translation = sgs.Sanguosha:translate(":"..skillname)
                if string.find(translation,"出牌阶段") then
                    table.insert(skillnames,skillname)
                    room:acquireSkill(effect.from, skillname)
                end
            end
        end
        if #skillnames > 0 then
            effect.from:setTag("ny_tenth_longsong_skills", sgs.QVariant(table.concat(skillnames,"+")))
        end
    end
}

ny_tenth_longsong = sgs.CreateTriggerSkill{
    name = "ny_tenth_longsong",
    events = {sgs.EventPhaseStart,sgs.EventPhaseEnd,sgs.InvokeSkill,sgs.CardUsed,sgs.CardResponded},
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = ny_tenth_longsongVS,
    priority = 1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.Player_Play then return false end
            room:askForUseCard(player, "@@ny_tenth_longsong", "@ny_tenth_longsong")
        end
        if event == sgs.InvokeSkill then
            if player:getPhase() ~= sgs.Player_Play then return false end
            local skillname = data:toString()
            local skills = player:getTag("ny_tenth_longsong_skills"):toString():split("+")
            if (not skills) or (#skills <= 0) then return false end
            for _,skill in ipairs(skills) do
                if string.find(skillname, skill) and player:hasSkill(skill) then
                    local log = sgs.LogMessage()
                    log.type = "#InvokeSkill"
                    log.from = player
                    log.arg = skillname
                    room:sendLog(log)

                    room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                    room:detachSkillFromPlayer(player, skill)
                    table.removeOne(skills, skill)
                    break
                end
            end
            if #skills <= 0 then player:removeTag("ny_tenth_longsong_skills")
            else player:setTag("ny_tenth_longsong_skills", sgs.QVariant(table.concat(skills,"+"))) end
        end
        if event == sgs.EventPhaseEnd then
            if player:getPhase() ~= sgs.Player_Play then return false end
            local skills = player:getTag("ny_tenth_longsong_skills"):toString():split("+")
            if (not skills) or (#skills <= 0) then return false end
            local send = true
            for _,skill in ipairs(skills) do
                if player:hasSkill(skill) then
                    if send then
                        room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                        send = false
                    end
                    room:detachSkillFromPlayer(player, skill)
                end
            end
            player:removeTag("ny_tenth_longsong_skills")
        end
        if event == sgs.CardUsed or event == sgs.CardResponded then
            if player:getPhase() ~= sgs.Player_Play then return false end
            local card 
            if event == sgs.CardUsed then
                card = data:toCardUse().card
            else
                card = data:toCardResponse().m_card
            end
            if (not card)  then return false end
            local skillname = card:getSkillName()
            local skills = player:getTag("ny_tenth_longsong_skills"):toString():split("+")
            if (not skills) or (#skills <= 0) then return false end
            for _,skill in ipairs(skills) do
                if string.find(skillname, skill) and player:hasSkill(skill) then
                    room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                    room:detachSkillFromPlayer(player, skill)
                    table.removeOne(skills, skill)
                    break
                end
            end
            if #skills <= 0 then player:removeTag("ny_tenth_longsong_skills")
            else player:setTag("ny_tenth_longsong_skills", sgs.QVariant(table.concat(skills,"+"))) end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_guannin:addSkill(ny_tenth_xiuwen)
ny_10th_guannin:addSkill(ny_tenth_longsong)
ny_10th_guannin:addSkill(ny_tenth_longsongVS)

ny_10th_sunhuan = sgs.General(extension, "ny_10th_sunhuan", "wu", 4, true, false, false)

ny_tenth_nijiVS = sgs.CreateViewAsSkill
{
    name = "ny_tenth_niji",
    response_pattern = "@@ny_tenth_niji",
    n = 1,
    view_filter = function(self, selected, to_select)
        return #selected < 1 and to_select:isAvailable(sgs.Self)
        and to_select:hasFlag("ny_tenth_niji")
    end,
    view_as = function(self, cards)
        if #cards == 1 then
            return cards[1]
        end
    end,
    enabled_at_play = function(self, player)
        return false 
    end
}

ny_tenth_niji = sgs.CreateTriggerSkill{
    name = "ny_tenth_niji",
    events = {sgs.TargetConfirmed},
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = ny_tenth_nijiVS,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.TargetConfirmed then
            if player:isDead() then return false end
            local use = data:toCardUse()
            if (use.card:isKindOf("BasicCard") or use.card:isKindOf("TrickCard"))
            and use.to:contains(player) then
                if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("draw")) then
                    room:broadcastSkillInvoke(self:objectName())
                    local cards = player:drawCardsList(1,self:objectName())
                    for _,id in sgs.qlist(cards) do
                        room:setCardFlag(id, "ny_tenth_niji")
                        room:setCardTip(id, "ny_tenth_niji")
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

local function ny_tenth_niji_usecard(player)
    local room = player:getRoom()
    room:setPlayerFlag(player, "ny_tenth_niji")
    --if not player:hasSkill("ny_tenth_niji") then return false end
    local has = false
    for _,card in sgs.qlist(player:getHandcards()) do
        if card:hasFlag("ny_tenth_niji") then
            room:sendCompulsoryTriggerLog(player, "ny_tenth_niji", true, true)
            has = true
            break
        end
    end
    if not has then return false end
    room:askForUseCard(player, "@@ny_tenth_niji", "@ny_tenth_niji")
    if player:isAlive() then
        local card_ids = sgs.IntList()
        for _,card in sgs.qlist(player:getHandcards()) do
            if card:hasFlag("ny_tenth_niji") then
                card_ids:append(card:getId())
            end
        end
        if card_ids:isEmpty() then return false end

        local log = sgs.LogMessage()
        log.type = "$DiscardCard"
        log.from = player
        log.card_str = table.concat(sgs.QList2Table(card_ids), "+")
        room:sendLog(log)

        local reason2 = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISCARD, player:objectName(), "ny_tenth_niji", "")
        local move2 = sgs.CardsMoveStruct(card_ids, nil, sgs.Player_DiscardPile, reason2)
        room:moveCardsAtomic(move2, true)
    end
end

ny_tenth_niji_buff = sgs.CreateTriggerSkill{
    name = "#ny_tenth_niji_buff",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:getPhase() ~= sgs.Player_Finish then return false end
        local nextp = player:getNextAlive(1)
        ny_tenth_niji_usecard(player)
        while(not nextp:hasFlag("ny_tenth_niji")) do
            ny_tenth_niji_usecard(nextp)
            nextp = nextp:getNextAlive(1)
        end
        for _,pl in sgs.qlist(room:getAlivePlayers()) do
            room:setPlayerFlag(pl, "-ny_tenth_niji")
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_10th_sunhuan:addSkill(ny_tenth_niji)
ny_10th_sunhuan:addSkill(ny_tenth_nijiVS)
ny_10th_sunhuan:addSkill(ny_tenth_niji_buff)
extension:insertRelatedSkills("ny_tenth_niji", "#ny_tenth_niji_buff")

ny_10th_jiachong = sgs.General(extension, "ny_10th_jiachong", "wei", 3, true, false, false)

ny_10th_beini = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_10th_beini",
    view_as = function(self)
        return ny_10th_beiniCard:clone()
    end,
    enabled_at_play = function(self, player)
        return (not player:hasUsed("#ny_10th_beini"))
    end
}

ny_10th_beiniCard = sgs.CreateSkillCard
{
    name = "ny_10th_beini",
    filter = function(self, targets, to_select)
        return #targets < 2
    end,
    feasible = function(self, targets, player)
        return #targets == 2
    end,
    about_to_use = function(self,room,use)
        local source = use.from
        local tos = {}
        table.insert(tos, use.to:at(0):objectName())
        table.insert(tos, use.to:at(1):objectName())
        source:setTag("ny_10th_beini", sgs.QVariant(table.concat(tos, "+")))
        self:cardOnUse(room,use)
    end,
    on_use = function(self, room, source, targets)
        local room = source:getRoom()
        if source:getHandcardNum() > source:getMaxHp() then
            local n = source:getHandcardNum() - source:getMaxHp()
            room:askForDiscard(source, self:objectName(), n, n, false, false)
        elseif source:getMaxHp() > source:getHandcardNum() then
            local n = source:getMaxHp() - source:getHandcardNum()
            source:drawCards(n, self:objectName())
        end
        
        for _,target in ipairs(targets) do
            if target and target:isAlive() then
                room:addPlayerMark(target, "@skill_invalidity")
                room:addPlayerMark(target, "&ny_10th_beini")
            end
        end

        local tos = source:getTag("ny_10th_beini"):toString():split("+")
        local from = room:findPlayerByObjectName(tos[1])
        local to = room:findPlayerByObjectName(tos[2])

        if from and from:isAlive() and to and to:isAlive() 
        and from:canSlash(to, false) then
            local patterns = {"slash", "fire_slash", "thunder_slash"}
            local pattern = room:askForChoice(source, self:objectName(), table.concat(patterns, "+"))
            local slash = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
            slash:setSkillName("_ny_10th_beini_slash")
            room:useCard(sgs.CardUseStruct(slash, from, to, false))
        end
    end
}

ny_10th_beini_clear = sgs.CreateTriggerSkill{
    name = "#ny_10th_beini_clear",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:getPhase() == sgs.Player_NotActive then
            for _,pl in sgs.qlist(room:getAlivePlayers()) do
                if pl:getMark("&ny_10th_beini") > 0 then
                    room:removePlayerMark(pl, "@skill_invalidity", pl:getMark("&ny_10th_beini"))
                    room:setPlayerMark(pl, "&ny_10th_beini", 0)
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

--[[ny_10th_beini_invalid = sgs.CreateInvaliditySkill
{
    name = "#ny_10th_beini_invalid",
    skill_valid = function(self, player, skill)
        --return true
        return (player and player:getMark("&ny_10th_beini") == 0)
        or skill:getFrequency() == sgs.Skill_Compulsory
        or (not skill:isVisible())
        or skill:isAttachedLordSkill()
    end,
}]]

--[[local ny_10th_beini_invalid = sgs.LuaInvaliditySkill("#ny_10th_beini_invalid",sgs.Skill_Compulsory)
ny_10th_beini_invalid.skill_valid = function(self, player, skill)
    --return true
    return (player and player:getMark("&ny_10th_beini") == 0)
    or skill:getFrequency() == sgs.Skill_Compulsory
    or (not skill:isVisible())
    or skill:isAttachedLordSkill()
end]]


ny_tenth_shizong = sgs.CreateViewAsSkill{
    name = "ny_tenth_shizong",
    n = 999,
    response_pattern = "@@ny_tenth_shizong!",
    view_filter = function(self, selected, to_select)
        local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
        if pattern == "@@ny_tenth_shizong!" then
            return #selected < (sgs.Self:getMark("&ny_tenth_shizong-Clear") + 1)
        end
        return false
    end,
    view_as = function(self, cards)
        local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
        if pattern == "@@ny_tenth_shizong!" then
            if #cards == (sgs.Self:getMark("&ny_tenth_shizong-Clear") + 1) then
                local card = ny_tenth_shizong_giveCard:clone()
                for _,cc in ipairs(cards) do
                    card:addSubcard(cc)
                end
                return card
            end
        else
            if sgs.Sanguosha:getCurrentCardUseReason()==sgs.CardUseStruct_CARD_USE_REASON_PLAY
		    then
			    local card = sgs.Self:getTag("ny_tenth_shizong"):toCard()
			    pattern = card:objectName()
		    end
            local card = ny_tenth_shizongCard:clone()
            local names = pattern:split("+")
            if #names ~= 1 then pattern = names[1] end
            if pattern == "Slash" then pattern = "slash" end
            if pattern == "Jink" then pattern = "jink" end
            card:setUserString(pattern)
            return card
        end
    end,
    enabled_at_play = function(self, player)
        if player:getMark("ny_tenth_shizong_disable-Clear") > 0 then return false end
        local num = player:getHandcardNum() + player:getEquips():length()
        return num >= (player:getMark("&ny_tenth_shizong-Clear") + 1)
    end,
    enabled_at_response = function(self,player,pattern)
        if player:getMark("ny_tenth_shizong_disable-Clear") > 0 then return false end
        if pattern == "@@ny_tenth_shizong!" then return true end
        if sgs.Sanguosha:getCurrentCardUseReason()~=sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then return false end
        local basics = {"slash", "jink", "peach", "analeptic", "Jink", "Slash"}
        for _,basic in ipairs(basics) do
            if string.find(pattern, basic) then
                local num = player:getHandcardNum() + player:getEquips():length()
                return num >= (player:getMark("&ny_tenth_shizong-Clear") + 1)
            end
        end
        return false
    end
}
ny_tenth_shizong:setGuhuoDialog("l")

ny_tenth_shizongCard = sgs.CreateSkillCard
{
    name = "ny_tenth_shizong",
    will_throw = false,
    filter = function(self, targets, to_select)
        local pattern = self:getUserString()
		if pattern=="normal_slash" then pattern = "slash" end

		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
		card:setSkillName("ny_tenth_shizong")
        card:deleteLater()

		if card and card:targetFixed() then
			return false
		end
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		return card and card:targetFilter(qtargets, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, qtargets)
	end,
	feasible = function(self, targets)
		local pattern = self:getUserString()
		if pattern=="normal_slash" then pattern = "slash" end

		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
		card:setSkillName("ny_tenth_shizong")
        card:deleteLater()

		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		if card and card:canRecast() and #targets == 0 then
			return false
		end
		return card and card:targetsFeasible(qtargets, sgs.Self) --and card:isAvailable(sgs.Self)
	end,
	on_validate = function(self, card_use)
		local player = card_use.from
        local room = player:getRoom()

        local pattern = self:getUserString()
		if pattern=="normal_slash" then pattern = "slash" end

        room:broadcastSkillInvoke(self:objectName())
        local log = sgs.LogMessage()
        log.type = "$ny_tenth_shizong_log"
        log.from = card_use.from
        log.arg = self:objectName()
        log.arg2 = pattern
        room:sendLog(log)

        player:setTag("ny_tenth_shizong_used", sgs.QVariant(pattern))

        local prompt = string.format("ny_tenth_shizong_give:%s:", player:getMark("&ny_tenth_shizong-Clear")+1)
        room:askForUseCard(player, "@@ny_tenth_shizong!", prompt)

        local viewers = sgs.SPlayerList()
        viewers:append(player)
        room:addPlayerMark(player, "&ny_tenth_shizong-Clear", 1, viewers)

        if player:hasFlag("ny_tenth_shizong_success") then
            room:setPlayerFlag(player, "-ny_tenth_shizong_success")
		    local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
		    card:setSkillName("_ny_tenth_shizong")
		    return card
        end
        return nil
	end,
    on_validate_in_response = function(self, player)
        local room = player:getRoom()

        local pattern = self:getUserString()
		if pattern=="normal_slash" then pattern = "slash" end

        room:broadcastSkillInvoke(self:objectName())
        local log = sgs.LogMessage()
        log.type = "$ny_tenth_shizong_log"
        log.from = player
        log.arg = self:objectName()
        log.arg2 = pattern
        room:sendLog(log)

        player:setTag("ny_tenth_shizong_used", sgs.QVariant(pattern))

        local prompt = string.format("ny_tenth_shizong_give:%s:", player:getMark("&ny_tenth_shizong-Clear")+1)
        room:askForUseCard(player, "@@ny_tenth_shizong!", prompt)

        local viewers = sgs.SPlayerList()
        viewers:append(player)
        room:addPlayerMark(player, "&ny_tenth_shizong-Clear", 1, viewers)

        if player:hasFlag("ny_tenth_shizong_success") then
            room:setPlayerFlag(player, "-ny_tenth_shizong_success")
		    local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
		    card:setSkillName("_ny_tenth_shizong")
		    return card
        end
        return nil
    end
}

ny_tenth_shizong_giveCard = sgs.CreateSkillCard
{
    name = "ny_tenth_shizong_give",
    will_throw = false,
    filter = function(self, targets, to_select)
        return #targets < 1 and to_select:objectName() ~= sgs.Self:objectName()
    end,
    about_to_use = function(self,room,use)
        room:obtainCard(use.to:at(0), self, false)

        local data = sgs.QVariant()
        data:setValue(use.from)
        use.to:at(0):setTag("ny_tenth_shizong_from", data)

        if use.to:at(0):getPhase() == sgs.Player_NotActive then
            room:addPlayerMark(use.from, "ny_tenth_shizong_disable-Clear", 1)
        end

        local prompt = string.format("@ny_tenth_shizong:%s::%s:", use.from:getGeneralName(),use.from:getTag("ny_tenth_shizong_used"):toString())
        local down = room:askForExchange(use.to:at(0), "ny_tenth_shizong", 1, 1, true, prompt, true)
        if down then
            room:setPlayerFlag(use.from, "ny_tenth_shizong_success")
            room:moveCardsToEndOfDrawpile(use.to:at(0), down:getSubcards(), "ny_tenth_shizong")
        end
    end,
}

ny_10th_jiachong:addSkill(ny_10th_beini)
ny_10th_jiachong:addSkill(ny_10th_beini_clear)
--ny_10th_jiachong:addSkill(ny_10th_beini_invalid)
ny_10th_jiachong:addSkill(ny_tenth_shizong)
extension:insertRelatedSkills("ny_10th_beini", "#ny_10th_beini_clear")
--extension:insertRelatedSkills("ny_10th_beini", "#ny_10th_beini_invalid")

ny_10th_dongzhao = sgs.General(extension, "ny_10th_dongzhao", "wei", 3, true, false, false)

ny_10th_yijia = sgs.CreateTriggerSkill{
    name = "ny_10th_yijia",
    events = {sgs.Damaged},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:isDead() then return false end
        for _,skiller in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
            if player:isDead() then return false end
            if skiller:isAlive() and skiller:distanceTo(player) <= 1 then
                local inrange = 0

                local targets = sgs.SPlayerList()
                for _,p in sgs.qlist(room:getOtherPlayers(player)) do
                    for _,card in sgs.qlist(p:getEquips()) do
                        local equip_index = card:getRealCard():toEquipCard():location()
                        if player:hasEquipArea(equip_index) then
                            targets:append(p)
                            break
                        end
                    end
                    if p:inMyAttackRange(player) then inrange = inrange + 1 end
                end
                if targets:isEmpty() then return false end

                skiller:removeTag("ny_10th_yijia")
                skiller:setTag("ny_10th_yijia", sgs.QVariant(player:objectName()))
                local target = room:askForPlayerChosen(skiller, targets, self:objectName(), "@ny_10th_yijia:"..player:getGeneralName(), true, true)
                if target then
                    room:broadcastSkillInvoke(self:objectName())
                    local disable_ids = sgs.IntList()
                    for _,card in sgs.qlist(target:getEquips()) do
                        local equip_index = card:getRealCard():toEquipCard():location()
                        if not player:hasEquipArea(equip_index) then
                            disable_ids:append(card:getId())
                        end
                    end
                    local id = room:askForCardChosen(skiller, target, "e", self:objectName(), false, sgs.Card_MethodNone, disable_ids)

                    local equip_index = sgs.Sanguosha:getCard(id):getRealCard():toEquipCard():location()

                    local moves = sgs.CardsMoveList()

                    if player:getEquip(equip_index) then
                        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_CHANGE_EQUIP, skiller:objectName(), self:objectName(), "")
                        local move = sgs.CardsMoveStruct(player:getEquip(equip_index):getEffectiveId(), nil, sgs.Player_DiscardPile, reason)
                        moves:append(move)
                    end

                    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, skiller:objectName(), self:objectName(), "")
                    local move = sgs.CardsMoveStruct(id, player, sgs.Player_PlaceEquip, reason)
                    moves:append(move)

                    if (not moves:isEmpty()) then
                        room:moveCardsAtomic(moves, true)
                    end

                    if skiller:isAlive() then
                        local inrange2 = 0
                        for _,p in sgs.qlist(room:getOtherPlayers(player)) do
                            if p:inMyAttackRange(player) then inrange2 = inrange2 + 1 end
                        end
                        if inrange2 < inrange then skiller:drawCards(1, self:objectName()) end
                    end
                end
            end
        end                      
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_tenth_dingjiVS = sgs.CreateViewAsSkill
{
    name = "ny_tenth_dingji",
    n = 99,
    response_pattern = "@@ny_tenth_dingji",
    view_filter = function(self, selected, to_select)
        return (to_select:isKindOf("BasicCard") or to_select:isNDTrick())
        and to_select:isAvailable(sgs.Self) and sgs.Self:getHandcards():contains(to_select)
        and #selected < 1
    end,
    view_as = function(self, cards)
        if #cards == 1 then
            local card = sgs.Sanguosha:cloneCard(cards[1]:objectName(), sgs.Card_SuitToBeDecided, -1)
            card:setSkillName("_ny_tenth_dingji")
            return card
        end
    end,
    enabled_at_play = function(self, player)
        return false
    end
}

ny_tenth_dingji = sgs.CreateTriggerSkill{
    name = "ny_tenth_dingji",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = ny_tenth_dingjiVS,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:getPhase() ~= sgs.Player_Start then return false end
        local target = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), "ny_tenth_dingji_change", true, true)
        if target then
            room:broadcastSkillInvoke(self:objectName())
            if target:getHandcardNum() > 5 then
                local n = target:getHandcardNum() - 5
                room:askForDiscard(target, self:objectName(), n, n, false, false)
            elseif 5 > target:getHandcardNum() then
                local n = 5 - target:getHandcardNum()
                target:drawCards(n, self:objectName())
            end
            if target:isDead() then return false end
            if target:isKongcheng() then return false end
            local show = sgs.IntList()
            local canuse = true
            local names = {}
            for _,card in sgs.qlist(target:getHandcards()) do
                show:append(card:getId())
                local name = card:objectName()
                if card:isKindOf("Slash") then name = "slash" end
                if not table.contains(names, name) then
                    table.insert(names, name)
                else
                    canuse = false
                end
            end
            room:showCard(target, show)
            if canuse then
                room:askForUseCard(target, "@@ny_tenth_dingji", "@ny_tenth_dingji")
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_dongzhao:addSkill(ny_10th_yijia)
ny_10th_dongzhao:addSkill(ny_tenth_dingji)
ny_10th_dongzhao:addSkill(ny_tenth_dingjiVS)

ny_10th_malingli = sgs.General(extension, "ny_10th_malingli", "shu", 3, false, false, false)

ny_10th_lima = sgs.CreateDistanceSkill{
    name = "ny_10th_lima",
    correct_func = function(self, from, to)
        if from and from:hasSkill(self:objectName()) then
            local num = 0
            if from:getOffensiveHorse() then num = num - 1 end
            if from:getDefensiveHorse() then num = num - 1 end
            for _,other in sgs.qlist(from:getAliveSiblings()) do
                if other:getOffensiveHorse() then num = num - 1 end
                if other:getDefensiveHorse() then num = num - 1 end
            end
            if num == 0 then num = -1 end
            return num
        end
        return 0
    end,
}

ny_tenth_xiaoyinVS = sgs.CreateViewAsSkill
{
    name = "ny_tenth_xiaoyin",
    response_pattern = "@@ny_tenth_xiaoyin",
    expand_pile = "#ny_tenth_xiaoyin",
    n = 99,
    view_filter = function(self, selected, to_select)
        if sgs.Self:hasFlag("ny_tenth_xiaoyin_add") then
            if #selected == 0 then return true end
            if #selected == 1 then
                local ctypes = {"BasicCard","TrickCard", "EquipCard"}
                for _,ctype in ipairs(ctypes) do
                    if selected[1]:isKindOf(ctype) and (not to_select:isKindOf(ctype)) then return false end
                end
                if sgs.Self:getPile("#ny_tenth_xiaoyin"):contains(selected[1]:getId()) then
                    return not sgs.Self:getPile("#ny_tenth_xiaoyin"):contains(to_select:getId())
                else
                    return sgs.Self:getPile("#ny_tenth_xiaoyin"):contains(to_select:getId())
                end
            end
            return false
        end

        if sgs.Self:hasFlag("ny_tenth_xiaoyin_change") then
            return sgs.Self:getPile("#ny_tenth_xiaoyin"):contains(to_select:getId()) and #selected < 1
        end

        if to_select:hasFlag("ny_tenth_xiaoyin") then return false end
        return to_select:isBlack() and sgs.Self:getPile("#ny_tenth_xiaoyin"):contains(to_select:getId())
        and #selected < 1
    end,
    view_as = function(self, cards)
        if sgs.Self:hasFlag("ny_tenth_xiaoyin_add") then
            if #cards == 2 then
                local card = ny_tenth_xiaoyin_buffCard:clone()
                card:addSubcard(cards[1])
                card:addSubcard(cards[2])
                return card
            end
            return nil
        end

        if sgs.Self:hasFlag("ny_tenth_xiaoyin_change") then
            if #cards == 1 then
                local card = ny_tenth_xiaoyin_buffCard:clone()
                card:addSubcard(cards[1])
                return card
            end
            return nil
        end


        if #cards == 1 then
            local card = ny_tenth_xiaoyinCard:clone()
            card:addSubcard(cards[1])
            return card
        end
    end,
    enabled_at_play = function(self, player)
        return false
    end,
}

ny_tenth_xiaoyinCard = sgs.CreateSkillCard
{
    name = "ny_tenth_xiaoyin",
    will_throw = false,
    filter = function(self, targets, to_select)
        if #targets >= 1 then return false end
        if to_select:hasFlag("ny_tenth_xiaoyin") then return false end
        if to_select:objectName() == sgs.Self:objectName() then return false end
        local inneed = true
        for _,other in sgs.qlist(to_select:getAliveSiblings()) do
            if other:hasFlag("ny_tenth_xiaoyin") then inneed = false end
        end
        if inneed then return true end
        for _,other in sgs.qlist(to_select:getAliveSiblings()) do
            if other:hasFlag("ny_tenth_xiaoyin") and to_select:isAdjacentTo(other) then return true end
        end
        return false
    end,
    about_to_use = function(self,room,use)
        local player = use.from
        local target = use.to:at(0)
        local _player = sgs.SPlayerList()
        _player:append(player)
        room:setPlayerMark(target, "&ny_tenth_xiaoyin", 1, _player)
        room:setPlayerFlag(target, "ny_tenth_xiaoyin")
        local id = self:getSubcards():at(0)
        local card = sgs.Sanguosha:getCard(id)

        local data_other = sgs.QVariant()
        data_other:setValue(card)
        target:setTag("ny_tenth_xiaoyin_put", data_other)
        room:setCardFlag(card, "ny_tenth_xiaoyin")
    end,
}

ny_tenth_xiaoyin_buffCard = sgs.CreateSkillCard
{
    name = "ny_tenth_xiaoyin_buff",
    target_fixed = true,
    will_throw = false,
    about_to_use = function(self,room,use)
        return false
    end
}

ny_tenth_xiaoyin = sgs.CreateTriggerSkill{
    name = "ny_tenth_xiaoyin",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = ny_tenth_xiaoyinVS,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.Player_Start then return false end
            if not player:hasSkill(self:objectName()) then return false end
            local n = 1
            for _,other in sgs.qlist(room:getOtherPlayers(player)) do
                if player:distanceTo(other) <= 1 then
                    n = n + 1
                end
            end
            local prompt = string.format("show:%s:", n)
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant(prompt)) then
                room:broadcastSkillInvoke(self:objectName())

                local card_ids = room:getNCards(n)
                local reason1 = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), self:objectName(), "")
                local move1 = sgs.CardsMoveStruct(card_ids, nil, sgs.Player_PlaceTable, reason1)
                room:moveCardsAtomic(move1, true)

                for _,p in sgs.qlist(room:getAlivePlayers()) do
                    p:removeTag("ny_tenth_xiaoyin_put")
                end

                local _data = sgs.QVariant()
                _data:setValue(card_ids)
                player:setTag("ny_tenth_xiaoyin_tem", _data)

                room:notifyMoveToPile(player, card_ids, "ny_tenth_xiaoyin", sgs.Player_PlaceTable, true)
                while(room:askForUseCard(player, "@@ny_tenth_xiaoyin", "@ny_tenth_xiaoyin")) do end
                room:notifyMoveToPile(player, card_ids, "ny_tenth_xiaoyin", sgs.Player_PlaceTable, false)

                local get = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, -1)
                local discard = sgs.IntList()

                for _,id in sgs.qlist(card_ids) do
                    local card = sgs.Sanguosha:getCard(id)
                    if card:isRed() then get:addSubcard(card)
                    else discard:append(id) end
                end

                if get:subcardsLength() > 0 then room:obtainCard(player, get, true) end
                get:deleteLater()

                room:setPlayerFlag(player, "ny_tenth_xiaoyin_finish")
                local nextp = player:getNextAlive(1)
                while(not nextp:hasFlag("ny_tenth_xiaoyin_finish")) do
                    if nextp:hasFlag("ny_tenth_xiaoyin") then
                        local card = nextp:getTag("ny_tenth_xiaoyin_put"):toCard()
                        if card then
                            nextp:addToPile("ny_tenth_xiaoyin", card, true)
                            discard:removeOne(card:getId())
                            room:setCardFlag(card, "-ny_tenth_xiaoyin")
                        end
                    end
                    room:setPlayerFlag(nextp, "ny_tenth_xiaoyin_finish")
                    nextp = nextp:getNextAlive(1)
                end

                for _,p in sgs.qlist(room:getAlivePlayers()) do
                    room:setPlayerFlag(p, "-ny_tenth_xiaoyin_finish")
                    room:setPlayerFlag(p, "-ny_tenth_xiaoyin")
                    room:setPlayerMark(p, "&ny_tenth_xiaoyin", 0)
                end

                if not discard:isEmpty() then
                    local log = sgs.LogMessage()
                    log.type = "$MoveToDiscardPile"
                    log.from = player
                    log.card_str = table.concat(sgs.QList2Table(discard), "+")
                    room:sendLog(log)

                    local reason2 = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), self:objectName(), "")
                    local move2 = sgs.CardsMoveStruct(discard, nil, sgs.Player_DiscardPile, reason2)
                    room:moveCardsAtomic(move2, true)
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

local function ny_tenth_xiaoyin_move(room, player, to, card_ids, inc)
    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_UNKNOWN, player:objectName(), "ny_tenth_xiaoyin", "")
    local move
    if (inc) then
        move = sgs.CardsMoveStruct(card_ids, to, player, sgs.Player_PlaceSpecial, sgs.Player_PlaceSpecial, reason)
        move.from_pile_name = "ny_tenth_xiaoyin"
        move.to_pile_name = "#ny_tenth_xiaoyin"
        local data = sgs.QVariant()
        data:setValue(card_ids)
        player:setTag("ny_tenth_xiaoyin_tem", data)
    else
        move = sgs.CardsMoveStruct(card_ids, player, to, sgs.Player_PlaceSpecial, sgs.Player_PlaceSpecial, reason)
        move.from_pile_name = "#ny_tenth_xiaoyin"
        move.to_pile_name = "ny_tenth_xiaoyin"
    end

    local moves = sgs.CardsMoveList()
    moves:append(move)
    local _player = sgs.SPlayerList()
    _player:append(player)
    room:notifyMoveCards(true, moves, true, _player)
    room:notifyMoveCards(false, moves, true, _player)
end

ny_tenth_xiaoyin_buff = sgs.CreateTriggerSkill{
    name = "#ny_tenth_xiaoyin_buff",
    events = {sgs.DamageCaused},
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = ny_tenth_xiaoyinVS,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.DamageCaused then
            local damage = data:toDamage()
            if damage.to:getPile("ny_tenth_xiaoyin"):isEmpty() then return false end
            player:setTag("ny_tenth_xiaoyin_buff", data)
            if damage.nature == sgs.DamageStruct_Fire then
                local card_ids = damage.to:getPile("ny_tenth_xiaoyin")
                local prompt = string.format("ny_tenth_xiaoyin_add:%s:", damage.to:getGeneralName())
                local place = room:getCardPlace(card_ids:at(0))

                room:setPlayerFlag(player, "ny_tenth_xiaoyin_add")
                --room:notifyMoveToPile(player, card_ids, "ny_tenth_xiaoyin", place, true)
                ny_tenth_xiaoyin_move(room, player, damage.to, card_ids, true)
                local card = room:askForUseCard(player, "@@ny_tenth_xiaoyin", prompt)
                --room:notifyMoveToPile(player, card_ids, "ny_tenth_xiaoyin", place, false)
                ny_tenth_xiaoyin_move(room, player, damage.to, card_ids, false)
                room:setPlayerFlag(player, "-ny_tenth_xiaoyin_add")

                if card then
                    room:sendCompulsoryTriggerLog(player, "ny_tenth_xiaoyin", true, true)
                    
                    for _,id in sgs.qlist(card:getSubcards()) do
                        if room:getCardPlace(id) == sgs.Player_PlaceHand
                        or room:getCardPlace(id) == sgs.Player_PlaceEquip then
                            local log = sgs.LogMessage()
                            log.type = "$DiscardCard"
                            log.from = player
                            log.card_str = sgs.Sanguosha:getCard(id):toString()
                            room:sendLog(log)

                            local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_THROW, player:objectName(), "ny_tenth_xiaoyin", "")
                            local move = sgs.CardsMoveStruct(id, nil, sgs.Player_DiscardPile, reason)
                            room:moveCardsAtomic(move, true)
                        else
                            local log = sgs.LogMessage()
                            log.type = "$MoveToDiscardPile"
                            log.from = player
                            log.card_str = sgs.Sanguosha:getCard(id):toString()
                            room:sendLog(log)
                            local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), "ny_tenth_xiaoyin", "")
                            local move = sgs.CardsMoveStruct(id, nil, sgs.Player_DiscardPile, reason)
                            room:moveCardsAtomic(move, true)
                        end
                    end

                    local log = sgs.LogMessage()
                    log.type = "$ny_tenth_xiaoyin_buff_add"
                    log.from = player
                    log.arg = damage.to:getGeneralName()
                    log.arg2 = "ny_tenth_xiaoyin"
                    log.arg3 = damage.damage
                    log.arg4 = damage.damage + 1
                    room:sendLog(log)

                    damage.damage = damage.damage + 1
                    data:setValue(damage)
                end
            else
                local card_ids = damage.to:getPile("ny_tenth_xiaoyin")
                local prompt = string.format("ny_tenth_xiaoyin_change:%s:", damage.to:getGeneralName())

                local place = room:getCardPlace(card_ids:at(0))

                room:setPlayerFlag(player, "ny_tenth_xiaoyin_change")
                --room:notifyMoveToPile(player, card_ids, "ny_tenth_xiaoyin", place, true)
                ny_tenth_xiaoyin_move(room, player, damage.to, card_ids, true)
                local card = room:askForUseCard(player, "@@ny_tenth_xiaoyin", prompt)
                --room:notifyMoveToPile(player, card_ids, "ny_tenth_xiaoyin", place, false)
                ny_tenth_xiaoyin_move(room, player, damage.to, card_ids, false)
                room:setPlayerFlag(player, "-ny_tenth_xiaoyin_change")

                if card then
                    room:sendCompulsoryTriggerLog(player, "ny_tenth_xiaoyin", true, true)
                    
                    --room:obtainCard(player, card, true)
                    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GOTCARD, player:objectName(), "ny_tenth_xiaoyin", "")
                    local move = sgs.CardsMoveStruct(card:getSubcards(), player, sgs.Player_PlaceHand, reason)
                    room:moveCardsAtomic(move, true)

                    local log = sgs.LogMessage()
                    log.type = "$ny_tenth_xiaoyin_buff_change"
                    log.from = player
                    log.arg = damage.to:getGeneralName()
                    log.arg2 = "ny_tenth_xiaoyin"
                    log.arg3 = "fire_nature"
                    room:sendLog(log)

                    damage.nature = sgs.DamageStruct_Fire
                    data:setValue(damage)
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_tenth_huahuo = sgs.CreateViewAsSkill{
    name = "ny_tenth_huahuo",
    n = 99,
    view_filter = function(self, selected, to_select)
        return to_select:isRed() and #selected < 1
        and sgs.Self:getHandcards():contains(to_select)
    end,
    view_as = function(self, cards)
        if #cards == 1 then
            local card = ny_tenth_huahuoCard:clone()
            card:addSubcard(cards[1])
            return card
        end
    end,
    enabled_at_play = function(self, player)
        return not player:hasUsed("#ny_tenth_huahuo")
    end,
    enabled_at_response = function(self, player, pattern)
        if player:getPhase() ~= sgs.Player_Play then return false end
        if player:hasUsed("#ny_tenth_huahuo") then return false end
        if sgs.Sanguosha:getCurrentCardUseReason() ~= sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then return false end
        return pattern == "slash" or pattern == "Slash"
    end,
}

ny_tenth_huahuoCard = sgs.CreateSkillCard
{
    name = "ny_tenth_huahuo",
    will_throw = false,
    filter = function(self, targets, to_select, player)
        local qtargets = sgs.PlayerList()
        for _,p in ipairs(targets) do
            qtargets:append(p)
        end
    
        local card = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
        card:setSkillName(self:objectName())

        card:deleteLater()
        return card and card:targetFilter(qtargets, to_select, player) and not player:isProhibited(to_select, card, qtargets)
    end,
    feasible = function(self, targets, player)
        local use_card = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, -1)
        use_card:addSubcards(self:getSubcards())
        use_card:setSkillName(self:objectName())
        use_card:deleteLater()

        local qtargets = sgs.PlayerList()
        for _,p in ipairs(targets) do
            qtargets:append(p)
        end

        if use_card and use_card:canRecast() and #targets == 0 then
			return false
		end

        return use_card and use_card:targetsFeasible(qtargets, player) 
    end,
    on_validate = function(self, cardUse)
        local source = cardUse.from
        local player = cardUse.from
        local room = source:getRoom()

        local card = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
        card:setSkillName(self:objectName())

        local choices = "cancel"
        for _,to in sgs.qlist(cardUse.to) do
            if not to:getPile("ny_tenth_xiaoyin"):isEmpty() then 
                choices = "change+cancel" 
                break
            end
        end

        local choice = room:askForChoice(player, self:objectName(), choices)
        if choice == "change" then
            cardUse.to = sgs.SPlayerList()
            for _,other in sgs.qlist(room:getOtherPlayers(player)) do
                if (not other:getPile("ny_tenth_xiaoyin"):isEmpty())
                and (not player:isProhibited(other, card)) then 
                    cardUse.to:append(other)
                end
            end
            room:sortByActionOrder(cardUse.to)
        end

        room:setCardFlag(card, "ny_tenth_huahuo")
        room:setCardFlag(card, "RemoveFromHistory")
        return card
    end,
    on_validate_in_response = function(self, source)
        local room = source:getRoom()

        local card = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
        card:setSkillName(self:objectName())

        room:setCardFlag(card, "RemoveFromHistory")

        return card
    end,
}

ny_10th_malingli:addSkill(ny_10th_lima)
ny_10th_malingli:addSkill(ny_tenth_xiaoyin)
ny_10th_malingli:addSkill(ny_tenth_xiaoyinVS)
ny_10th_malingli:addSkill(ny_tenth_xiaoyin_buff)
ny_10th_malingli:addSkill(ny_tenth_huahuo)
extension:insertRelatedSkills("ny_tenth_xiaoyin", "#ny_tenth_xiaoyin_buff")

ny_10th_xielingyu = sgs.General(extension, "ny_10th_xielingyu", "wu", 3, false, false, false)

ny_10th_yuandi = sgs.CreateTriggerSkill{
    name = "ny_10th_yuandi",
    events = {sgs.CardUsed},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local use = data:toCardUse()
        if use.card:isKindOf("SkillCard") then return false end
        if player:getMark("ny_10th_yuandi-PlayClear") > 0 then return false end
        room:addPlayerMark(player, "ny_10th_yuandi-PlayClear", 1)
        for _,to in sgs.qlist(use.to) do
            if to:objectName() ~= player:objectName() then return false end
        end

        for _,p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
            if p:isAlive() and p:objectName() ~= player:objectName() then
                local _data = sgs.QVariant()
                _data:setValue(player)
                if room:askForSkillInvoke(p, self:objectName(), _data) then
                    room:broadcastSkillInvoke(self:objectName())
                    local choices = {"draw="..player:getGeneralName(), "discard="..player:getGeneralName()}
                    local choice = room:askForChoice(p, self:objectName(), table.concat(choices, "+"), _data)
                    if string.find(choice, "draw") then
                        player:drawCards(1, self:objectName())
                        p:drawCards(1, self:objectName())
                    elseif string.find(choice, "discard") and (not player:isKongcheng()) then
                        local card = room:askForCardChosen(p, player, "h", self:objectName())
                        room:throwCard(card, player, p)
                    end
                end
            end
            if player:isDead() then return false end
        end
    end,
    can_trigger = function(self, target)
        return target:getPhase() == sgs.Player_Play and target:isAlive()
    end,
}

ny_10th_xinyou = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_10th_xinyou",
    view_as = function(self)
        return ny_10th_xinyouCard:clone()
    end,
    enabled_at_play = function(self, player)
        return not player:hasUsed("#ny_10th_xinyou")
    end
}

ny_10th_xinyouCard = sgs.CreateSkillCard
{
    name = "ny_10th_xinyou",
    target_fixed = true,
    on_use = function(self, room, source, targets)
        local room = source:getRoom()
        if source:isWounded() then
            room:recover(source, sgs.RecoverStruct(self:objectName(), source, source:getLostHp()))
            room:addPlayerMark(source, "ny_10th_xinyou_recover-Clear", 1)
        end
        if source:getHandcardNum() < source:getMaxHp() then
            local n = source:getMaxHp()- source:getHandcardNum()
            source:drawCards(n, self:objectName())
            if n > 2 then
                room:addPlayerMark(source, "ny_10th_xinyou_draw-Clear", 1)
            end
        end
    end
}

ny_10th_xinyou_buff = sgs.CreateTriggerSkill{
    name = "#ny_10th_xinyou_buff",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:getPhase() ~= sgs.Player_Finish then return false end
        if player:getMark("ny_10th_xinyou_recover-Clear") == 0
        and player:getMark("ny_10th_xinyou_draw-Clear") == 0 then return false end
        room:sendCompulsoryTriggerLog(player, "ny_10th_xinyou", true, true)
        if player:getMark("ny_10th_xinyou_draw-Clear") > 0 then
            room:loseHp(player, 1)
        end
        if player:getMark("ny_10th_xinyou_recover-Clear") > 0 then
            room:askForDiscard(player, "ny_10th_xinyou", 1, 1, false, true)
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_10th_xielingyu:addSkill(ny_10th_yuandi)
ny_10th_xielingyu:addSkill(ny_10th_xinyou)
ny_10th_xielingyu:addSkill(ny_10th_xinyou_buff)
extension:insertRelatedSkills("ny_10th_xinyou","#ny_10th_xinyou_buff")

ny_10th_mouzhouyu = sgs.General(extension, "ny_10th_mouzhouyu", "wu", 4, true, false, false)

ny_10th_ronghuo = sgs.CreateTriggerSkill{
    name = "ny_10th_ronghuo",
    events = {sgs.DamageCaused},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.DamageCaused then
            local damage = data:toDamage()
            if damage.card and (damage.card:objectName() == "fire_slash" or damage.card:objectName() == "fire_attack")
            and (not damage.chain) then
                room:broadcastSkillInvoke(self:objectName())
                local kingdoms = {}
                for _,p in sgs.qlist(room:getAlivePlayers()) do
                    if not table.contains(kingdoms, p:getKingdom()) then
                        table.insert(kingdoms, p:getKingdom())
                    end
                end
                local n = #kingdoms - 1 + damage.damage

                local log = sgs.LogMessage()
                log.type = "$ny_10th_ronghuo_damage"
                log.from = player
                --log.to = sgs.SPlayerList()
                log.to:append(damage.to)
                log.arg = self:objectName()
                log.arg2 = damage.damage
                log.arg3 = n
                room:sendLog(log)

                damage.damage = n
                data:setValue(damage)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_yingmou = sgs.CreateTriggerSkill{
    name = "ny_10th_yingmou",
    events = {sgs.CardFinished},
    frequency = sgs.Skill_NotFrequent,
    change_skill = true,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.from:objectName() ~= player:objectName() then return false end
            if not use.card or use.card:isKindOf("SkillCard") then return false end
            local targets = sgs.SPlayerList()
            for _,p in sgs.qlist(use.to) do
                if (p:objectName() ~= player:objectName()) and p:isAlive() then targets:append(p) end
            end
            if targets:isEmpty() then return false end
            if player:getChangeSkillState(self:objectName()) <= 1 then
                local target = room:askForPlayerChosen(player, targets, self:objectName(), "ny_10th_yingmou_first", true, true)
                if not target then return false end
                room:broadcastSkillInvoke(self:objectName())
                room:setChangeSkillState(player, self:objectName(), 2)
                room:addPlayerMark(player, "ny_10th_yingmou-Clear", 1)

                if target:getHandcardNum() > player:getHandcardNum() then
                    local n = target:getHandcardNum() - player:getHandcardNum()
                    if n > 5 then n = 5 end
                    player:drawCards(n, self:objectName())
                end
                local fire_attack = sgs.Sanguosha:cloneCard("fire_attack", sgs.Card_SuitToBeDecided, -1)
                fire_attack:setSkillName("_"..self:objectName())
                if player:isAlive() and target:isAlive() and player:canUse(fire_attack, target) then
                    room:useCard(sgs.CardUseStruct(fire_attack, player, target, true))
                else
                    fire_attack:deleteLater()
                end
            elseif player:getChangeSkillState(self:objectName()) == 2 then
                local target = room:askForPlayerChosen(player, targets, self:objectName(), "ny_10th_yingmou_second_first", true, true)
                if not target then return false end
                room:broadcastSkillInvoke(self:objectName())
                room:setChangeSkillState(player, self:objectName(), 1)
                room:addPlayerMark(player, "ny_10th_yingmou-Clear", 1)

                room:setPlayerFlag(player, "ny_10th_yingmou_second_second")
                local max = 0
                local tas = sgs.SPlayerList()
                for _,p in sgs.qlist(room:getAlivePlayers()) do
                    if p:getHandcardNum() > max then max = p:getHandcardNum() end
                end
                for _,p in sgs.qlist(room:getAlivePlayers()) do
                    if p:getHandcardNum() == max then tas:append(p) end
                end
                local from = room:askForPlayerChosen(player, tas, self:objectName(), "ny_10th_yingmou_second_second", false, true)
                room:setPlayerFlag(player, "-ny_10th_yingmou_second_second")

                local discard = true
                room:setPlayerFlag(from, "ny_10th_yingmou")
                for _,card in sgs.qlist(from:getHandcards()) do
                    if from:isDead() then break end
                    if target:isDead() then break end
                    if card:isDamageCard() and from:canUse(card, target) then
                        room:useCard(sgs.CardUseStruct(card, from, target, true))
                        discard = false
                    end
                end
                room:setPlayerFlag(from, "-ny_10th_yingmou")

                if discard and player:isAlive() and from:isAlive() and from:getHandcardNum() > player:getHandcardNum() then
                    local dis = from:getHandcardNum() - player:getHandcardNum()
                    room:askForDiscard(from, self:objectName(), dis, dis, false, false)
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
        and target:isAlive() and target:getMark("ny_10th_yingmou-Clear") == 0
    end,
}

ny_10th_yingmou_buff = sgs.CreateTargetModSkill{
    name = "#ny_10th_yingmou_buff",
    pattern = ".",
    residue_func = function(self, from, card)
        if from:hasFlag("ny_10th_yingmou") then return 1000 end
        return 0
    end,
    distance_limit_func = function(self, from, card)
        if from:hasFlag("ny_10th_yingmou") then return 1000 end
        return 0
    end,
}

ny_10th_mouzhouyu:addSkill(ny_10th_ronghuo)
ny_10th_mouzhouyu:addSkill(ny_10th_yingmou)
ny_10th_mouzhouyu:addSkill(ny_10th_yingmou_buff)
extension:insertRelatedSkills("ny_10th_yingmou", "#ny_10th_yingmou_buff")

ny_10th_sunchen = sgs.General(extension, "ny_10th_sunchen", "wu", 4, true, false, false)

ny_10th_zuowei = sgs.CreateTriggerSkill{
    name = "ny_10th_zuowei",
    events = {sgs.CardUsed,sgs.CardResponded},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local card
        if event == sgs.CardUsed then
            card = data:toCardUse().card
        else
            local response = data:toCardResponse()
            if response.m_isUse then
                card = response.m_card
            end
        end
        if (not card) or card:isKindOf("SkillCard") then return false end
        local n = math.max(player:getEquips():length(), 1)
        if player:getHandcardNum() > n then
            local prompt = string.format("noresponse:%s:",card:objectName())
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant(prompt)) then
                room:broadcastSkillInvoke(self:objectName())
                local log = sgs.LogMessage()
                log.type = "$ny_10th_zuowei_noresponse"
                log.from = player
                log.arg = self:objectName()
                log.card_str = card:toString()
                room:sendLog(log)

                if event == sgs.CardUsed then
                    local use = data:toCardUse()
                    local no_respond_list = use.no_respond_list
                    table.insert(no_respond_list, "_ALL_TARGETS")
                    use.no_respond_list = no_respond_list
                    data:setValue(use)
                end
            end
        elseif player:getHandcardNum() == n then
            local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "@ny_10th_zuowei", true, true)
            if target then
                room:broadcastSkillInvoke(self:objectName())
                room:damage(sgs.DamageStruct(self:objectName(), player, target, 1, sgs.DamageStruct_Normal))
            end
        elseif player:getHandcardNum() < n then
            if player:getMark("ny_10th_zuowei-Clear") > 0 then return false end
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("draw")) then
                room:broadcastSkillInvoke(self:objectName())
                room:addPlayerMark(player, "ny_10th_zuowei-Clear", 1)
                player:drawCards(2,self:objectName())
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
        and target:getPhase() ~= sgs.Player_NotActive
    end,
}

ny_10th_zigu = sgs.CreateViewAsSkill
{
    name = "ny_10th_zigu",
    n = 99,
    view_filter = function(self, selected, to_select)
        return #selected < 1
    end,
    view_as = function(self, cards)
        if #cards == 1 then
            local card = ny_10th_ziguCard:clone()
            card:addSubcard(cards[1])
            return card
        end
    end,
    enabled_at_play = function(self, player)
        return not player:hasUsed("#ny_10th_zigu")
    end
}

ny_10th_ziguCard = sgs.CreateSkillCard
{
    name = "ny_10th_zigu",
    handling_method = sgs.Card_MethodDiscard,
    filter = function(self, targets, to_select)
        return #targets < 1 and (not to_select:getEquips():isEmpty())
    end,
    on_effect = function(self, effect)
        local room = effect.from:getRoom()
        local player = effect.from
        local to = effect.to
        if (not to:getEquips():isEmpty()) then
            local card = room:askForCardChosen(player, to, "e", self:objectName())
            room:obtainCard(player, card, true)
        else
            player:drawCards(1, self:objectName())
        end
        if player:isAlive() and player:objectName() == to:objectName() then
            player:drawCards(1, self:objectName())
        end
    end
}

ny_10th_sunchen:addSkill(ny_10th_zuowei)
ny_10th_sunchen:addSkill(ny_10th_zigu)

ny_10th_sunce_shuangbi = sgs.General(extension, "ny_10th_sunce_shuangbi", "wu", 4, true, false, false)

ny_tenth_shuangbi = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_tenth_shuangbi",
    response_pattern = "@@ny_tenth_shuangbi",
    view_as = function(self)
        if sgs.Self:hasFlag("ny_tenth_shuangbi") then
            return ny_tenth_shuangbiSlash:clone()
        else
            return ny_tenth_shuangbiCard:clone()
        end
    end,
    enabled_at_play = function(self, player)
        return not player:hasUsed("#ny_tenth_shuangbi")
    end
}

ny_tenth_shuangbiCard = sgs.CreateSkillCard
{
    name = "ny_tenth_shuangbi",
    target_fixed = true,
    mute = true,
    on_use = function(self, room, source, targets)
        local room = source:getRoom()
        room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
        local n = room:getAlivePlayers():length()
        local choices = string.format("draw=%s+damage=%s+slash=%s",n,n,n)
        local choice = room:askForChoice(source, self:objectName(), choices, sgs.QVariant(1))
        if string.find(choice, "draw") then
            room:broadcastSkillInvoke(self:objectName(), math.random(1,2)+2)
            source:drawCards(n, self:objectName())
            room:addPlayerMark(source, "&ny_tenth_shuangbi-Clear", n)
        elseif string.find(choice, "damage") then
            room:broadcastSkillInvoke(self:objectName(), math.random(1,2)+4)
            local prompt = string.format("ny_tenth_shuangbi_discard:%s:",n)
            local card = room:askForDiscard(source, self:objectName(), n, 1, true, true, prompt)
            if card then
                for i = 1,card:subcardsLength(),1 do
                    local all = sgs.QList2Table(room:getOtherPlayers(source))
                    local target = all[math.random(1,#all)]
                    room:damage(sgs.DamageStruct(self:objectName(), source, target, 1, sgs.DamageStruct_Fire))
                end
            end
        elseif string.find(choice, "slash") then
            room:broadcastSkillInvoke(self:objectName(), math.random(1,2)+6)
            for i = 1,n,1 do
                local pattern = room:askForChoice(source, self:objectName(), "fire_slash+fire_attack+cancel", sgs.QVariant(2))
                if pattern == "cancel" then break end
                room:setPlayerProperty(source, "ny_tenth_shuangbi_card", sgs.QVariant(pattern))
                room:setPlayerFlag(source, "ny_tenth_shuangbi")
                local use = room:askForUseCard(source, "@@ny_tenth_shuangbi", "@ny_tenth_shuangbi:"..pattern)
                room:setPlayerFlag(source, "-ny_tenth_shuangbi")
                if not use then break end
            end
        end
    end
}

ny_tenth_shuangbiSlash = sgs.CreateSkillCard
{
    handling_method = sgs.Card_MethodUse,
    mute = true,
    name = "ny_tenth_shuangbi_card",
    filter = function(self, targets, to_select, player) 
		local pattern = player:property("ny_tenth_shuangbi_card"):toString()
		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
		card:setSkillName("ny_tenth_shuangbi_mouzhouyu")
		if card and card:targetFixed() then
			return false
		end
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		return card and card:targetFilter(qtargets, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, qtargets)
	end,
    target_fixed = function(self)		
		local pattern = sgs.Self:property("ny_tenth_shuangbi_card"):toString()
		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
        card:setSkillName("ny_tenth_shuangbi_mouzhouyu")
		return card and card:targetFixed()
	end,
	feasible = function(self, targets)	
		local pattern = sgs.Self:property("ny_tenth_shuangbi_card"):toString()
		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
		card:setSkillName("ny_tenth_shuangbi_mouzhouyu")
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		return card and card:targetsFeasible(qtargets, sgs.Self)
	end,
    on_validate = function(self, card_use)
		local player = card_use.from
		local room = player:getRoom()
		local pattern = player:property("ny_tenth_shuangbi_card"):toString()
		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
        card:setSkillName("_ny_tenth_shuangbi_mouzhouyu")
        room:setCardFlag(card, "RemoveFromHistory")
		return card	
	end
}

ny_tenth_shuangbi_max = sgs.CreateMaxCardsSkill{
    name = "#ny_tenth_shuangbi_max",
    extra_func = function(self, target)
        return target:getMark("&ny_tenth_shuangbi-Clear")
    end,
}

ny_tenth_shuangbi_buff = sgs.CreateTargetModSkill{
    name = "#ny_tenth_shuangbi_buff",
    residue_func = function(self, from, card)
        if card:getSkillName() == "ny_tenth_shuangbi_mouzhouyu" then return 1000 end
        return 0
    end,
}

ny_10th_sunce_shuangbi:addSkill(ny_tenth_shuangbi)
ny_10th_sunce_shuangbi:addSkill(ny_tenth_shuangbi_max)
ny_10th_sunce_shuangbi:addSkill(ny_tenth_shuangbi_buff)
extension:insertRelatedSkills("ny_tenth_shuangbi","#ny_tenth_shuangbi_max")
extension:insertRelatedSkills("ny_tenth_shuangbi","#ny_tenth_shuangbi_buff")

ny_10th_caoyi = sgs.General(extension, "ny_10th_caoyi", "wei", 4, false, false, false)
ny_10th_caoyi_tiger = sgs.General(extension, "ny_10th_caoyi_tiger", "wei", 4, false, true, true)

ny_10th_miyi = sgs.CreateTriggerSkill{
    name = "ny_10th_miyi",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseStart then
            if player:getPhase() == sgs.Player_Start then
                if room:askForSkillInvoke(player, self:objectName(), data, false) then
                    local choice = room:askForChoice(player, self:objectName(), "damage+recover+cancel")
                    if choice == "cancel" then return false end
                    room:setPlayerFlag(player, "ny_10th_miyi_"..choice)

                    local targets = room:askForPlayersChosen(player, room:getAlivePlayers(),
                    self:objectName(), 0, 999, "@ny_10th_miyi:"..self:objectName().."_"..choice,
                    false, true)

                    room:setPlayerFlag(player, "-ny_10th_miyi_"..choice)
                    if (not targets) or (targets:isEmpty()) then return false end

                    local log = sgs.LogMessage()
                    log.type = "$ny_10th_miyi_chosen"
                    log.from = player
                    log.arg = self:objectName()
                    log.arg2 = string.format("%s:%s", self:objectName(), choice)
                    log.to = targets
                    room:sendLog(log)
                    room:broadcastSkillInvoke(self:objectName())

                    if choice == "damage" then
                        for _,target in sgs.qlist(targets) do
                            if target:isAlive() then
                                room:addPlayerMark(target, "&ny_10th_miyi-Clear", 1)
                                room:addPlayerMark(target, "ny_10th_miyi_recover-Clear", 1)
                                room:damage(sgs.DamageStruct(self:objectName(), player, target, 1, sgs.DamageStruct_Normal))
                            end
                        end
                    else
                        for _,target in sgs.qlist(targets) do
                            if target:isAlive() then
                                room:addPlayerMark(target, "&ny_10th_miyi-Clear", 1)
                                room:addPlayerMark(target, "ny_10th_miyi_damage-Clear", 1)
                                if target:isWounded() then
                                    room:recover(target, sgs.RecoverStruct(self:objectName(), player, 1))
                                end
                            end
                        end
                    end
                end
            end
            if player:getPhase() == sgs.Player_Finish then
                local first = true
                for _,target in sgs.qlist(room:getAlivePlayers()) do
                    if target:isAlive() and target:getMark("ny_10th_miyi_recover-Clear") > 0 then
                        if first then 
                            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true) 
                            first = false
                        end
                        if target:isWounded() then
                            room:recover(target, sgs.RecoverStruct(self:objectName(), player, 1))
                        end
                    end
                    if target:isAlive() and target:getMark("ny_10th_miyi_damage-Clear") > 0 then
                        if first then 
                            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true) 
                            first = false
                        end
                        room:damage(sgs.DamageStruct(self:objectName(), player, target, 1, sgs.DamageStruct_Normal))
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_yinjun = sgs.CreateTriggerSkill{
    name = "ny_10th_yinjun",
    events = {sgs.CardFinished,sgs.Predamage},
    frequency = sgs.Skill_NotFrequent,
    priority = 1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and (use.card:isKindOf("Slash") or use.card:isKindOf("TrickCard")) then else return false end
            if player:getMark("ny_10th_yinjun_finish-Clear") > 0 then return false end
            if not use.m_isHandcard then return false end
            if use.to:length() ~= 1 then return false end
            local target = use.to:at(0)
            if (not target) or (target:objectName() == player:objectName()) then return false end
            if target:isDead() then return false end
            local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
            slash:setSkillName("_ny_10th_yinjun")
            room:setCardFlag(slash, "ny_10th_yinjun")
            if player:isProhibited(target, slash) then 
                slash:deleteLater()
                return false
            end

            player:setTag("ny_10th_yinjun", data)
            local prompt = string.format("slash:%s:", target:getGeneralName())
            if not room:askForSkillInvoke(player, self:objectName(), sgs.QVariant(prompt)) then 
                slash:deleteLater()
                return false
            end

            room:addPlayerMark(player, "&ny_10th_yinjun-Clear", 1)
            if player:getMark("&ny_10th_yinjun-Clear") > player:getHp() then 
                room:addPlayerMark(player, "ny_10th_yinjun_finish-Clear", 1)
            end

            local change = false
            if player:getGeneralName() == "ny_10th_caoyi" then
                change = true
                room:changeHero(player, "ny_10th_caoyi_tiger", false, false)
            end

            room:getThread():delay(200)
            room:useCard(sgs.CardUseStruct(slash, player, target))
            room:getThread():delay(200)

            if change then room:changeHero(player, "ny_10th_caoyi", false, false) end
        end
        if event == sgs.Predamage then
            local damage = data:toDamage()
            if (not damage.from) or (damage.from:objectName() ~= player:objectName()) then return false end
            if damage.card and damage.card:hasFlag("ny_10th_yinjun") then
                damage.from = nil
                data:setValue(damage)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_caoyi:addSkill(ny_10th_miyi)
ny_10th_caoyi_tiger:addSkill(ny_10th_miyi)
ny_10th_caoyi:addSkill(ny_10th_yinjun)
ny_10th_caoyi_tiger:addSkill(ny_10th_yinjun)

ny_10th_zhugeruoxue = sgs.General(extension, "ny_10th_zhugeruoxue", "wei", 3, false, false, false)

ny_10th_qiongying = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_10th_qiongying",
    view_as = function(self)
        return ny_10th_qiongyingCard:clone()
    end,
    enabled_at_play = function(self, player)
        return (not player:hasUsed("#ny_10th_qiongying"))
    end
}

ny_10th_qiongyingCard = sgs.CreateSkillCard
{
    name = "ny_10th_qiongying",
    filter = function(self, targets, to_select)
        if #targets >= 1 then return false end
        return (not to_select:getEquips():isEmpty()) or (not to_select:getJudgingArea():isEmpty())
    end,
    feasible = function(self, targets)
        if #targets <= 0 then return false end
        local target = targets[1]
        local others = target:getAliveSiblings()
        for _,card in sgs.qlist(target:getEquips()) do
            local equip_index = card:getRealCard():toEquipCard():location()
            for _,other in sgs.qlist(others) do
                if other:hasEquipArea(equip_index) and (not other:getEquip(equip_index)) then
                    return true
                end
            end
        end
        for _,card in sgs.qlist(target:getJudgingArea()) do
            for _,other in sgs.qlist(others) do
                if other:hasJudgeArea() and (not other:containsTrick(card:objectName())) then
                    return true
                end
            end
        end
        return false
    end,
    on_effect = function(self, effect)
        local room = effect.from:getRoom()
        local player = effect.from
        local target = effect.to
        if target:getCards("ej"):isEmpty() then return false end
        local disable_ids = sgs.IntList()
        local others = room:getOtherPlayers(target)
        
        for _,card in sgs.qlist(target:getEquips()) do
            local equip_index = card:getRealCard():toEquipCard():location()
            local cant = true
            for _,other in sgs.qlist(others) do
                if other:hasEquipArea(equip_index) and (not other:getEquip(equip_index)) then
                    cant = false
                    break
                end
            end
            if cant then disable_ids:append(card:getEffectiveId()) end
        end
        for _,card in sgs.qlist(target:getJudgingArea()) do
            local cant = true
            for _,other in sgs.qlist(others) do
                if other:hasJudgeArea() and (not other:containsTrick(card:objectName())) then
                    cant = false
                    break
                end
            end
            if cant then disable_ids:append(card:getEffectiveId()) end
        end

        local card_id = room:askForCardChosen(player, target, "ej", self:objectName(), false, sgs.Card_MethodNone, disable_ids, false)
        if (not card_id) or (card_id < 0) then return false end
        local card = sgs.Sanguosha:getCard(card_id)

        local tos = sgs.SPlayerList()
        if card:isKindOf("EquipCard") then
            local equip_index = card:getRealCard():toEquipCard():location()
            for _,other in sgs.qlist(others) do
                if other:hasEquipArea(equip_index) and (not other:getEquip(equip_index)) then
                    tos:append(other)
                end
            end
        else
            for _,other in sgs.qlist(others) do
                if other:hasJudgeArea() and (not other:containsTrick(card:objectName())) then
                    tos:append(other)
                end
            end
        end

        local to = room:askForPlayerChosen(player, tos, self:objectName(), "@ny_10th_qiongying:"..card:objectName(), false, false)
        if not to then return false end
        if not card:isKindOf("EquipCard") then
            local log = sgs.LogMessage()
            log.type = "$LightningMove"
            log.from = target
            log.to:append(to)
            log.card_str = card:toString()
            room:sendLog(log)
        end

        local place = sgs.Player_PlaceEquip
        if card:isKindOf("TrickCard") then place = sgs.Player_PlaceJudge end
        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, target:objectName(), self:objectName(), "")
        room:moveCardTo(card, to, place, reason)

        if player:isDead() or player:isKongcheng() then return false end
        local pattern = string.format(".|%s|.|.", card:getSuitString())
        local dis = room:askForDiscard(player, self:objectName(), 1, 1, false, false, "ny_10th_qiongying_discard:"..card:getSuitString(), pattern)
        if not dis then room:showAllCards(player) end
    end
}

ny_tenth_nuanhuiVS = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_tenth_nuanhui",
    response_pattern = "@@ny_tenth_nuanhui",
    view_as = function(self, cards)
        --return ny_tenth_nuanhuiCard:clone()
        local pattern = sgs.Self:property("ny_tenth_nuanhui_card"):toString()
		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
        card:setSkillName(self:objectName())
        return card
    end,
    enabled_at_play = function(self, player)
        return false
    end
}

ny_tenth_nuanhuiCard = sgs.CreateSkillCard
{
    handling_method = sgs.Card_MethodUse,
    mute = true,
    name = "ny_tenth_nuanhui",
    filter = function(self, targets, to_select, player) 
		local pattern = player:property("ny_tenth_nuanhui_card"):toString()
		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
		card:setSkillName(self:objectName())
        card:deleteLater()

		if card and card:targetFixed() then
			return false
		end
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		return card and card:targetFilter(qtargets, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, qtargets)
	end,
    target_fixed = function(self)		
		local pattern = sgs.Self:property("ny_tenth_nuanhui_card"):toString()
		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
        card:setSkillName(self:objectName())
        card:deleteLater()
		return card and card:targetFixed()
	end,
	feasible = function(self, targets)	
		local pattern = sgs.Self:property("ny_tenth_nuanhui_card"):toString()
		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
		card:setSkillName(self:objectName())
        card:deleteLater()

		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		return card and card:targetsFeasible(qtargets, sgs.Self)
	end,
    on_validate = function(self, card_use)
		local player = card_use.from
		local room = player:getRoom()
		local pattern = player:property("ny_tenth_nuanhui_card"):toString()
		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
        card:setSkillName(self:objectName())
        
		return card	
	end
}

ny_tenth_nuanhui = sgs.CreateTriggerSkill{
    name = "ny_tenth_nuanhui",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = ny_tenth_nuanhuiVS,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.Player_Finish then return false end
            local targets = sgs.SPlayerList()
            for _,p in sgs.qlist(room:getAlivePlayers()) do
                if (not p:getEquips():isEmpty()) then
                    targets:append(p)
                end
            end
            if targets:isEmpty() then return false end
            local target = room:askForPlayerChosen(player, targets, self:objectName(), "ny_tenth_nuanhui_chosen", true, true)
            if not target then return false end
            room:broadcastSkillInvoke(self:objectName())
            local n = target:getEquips():length()
            local u = 0
            local choices = "slash+fire_slash+thunder_slash+peach+analeptic+jink+cancel"
            for i = 1, n, 1 do
                room:setPlayerMark(target, "ny_tenth_nuanhui", i)
                local pattern = room:askForChoice(target, self:objectName(), choices)
                if pattern == "cancel" then break end
                local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
                card:deleteLater()
                if (not card:isAvailable(target)) then break end

                room:setPlayerProperty(target, "ny_tenth_nuanhui_card", sgs.QVariant(pattern))
                local prompt = string.format("@ny_tenth_nuanhui:%s::%s:", pattern, i)
                local use = room:askForUseCard(target, "@@ny_tenth_nuanhui", prompt)
                if use then u = u + 1
                else break end
                if target:isDead() then return false end
            end
            if u > 1 and target:isAlive() and (not target:getEquips():isEmpty()) then
                local card_ids = target:getEquipsId()
                local reason2 = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISCARD, target:objectName(), "ny_tenth_nuanhui", "")
                local move2 = sgs.CardsMoveStruct(card_ids, nil, sgs.Player_DiscardPile, reason2)
                room:moveCardsAtomic(move2, true)
            end
        end 
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_10th_zhugeruoxue:addSkill(ny_10th_qiongying)
ny_10th_zhugeruoxue:addSkill(ny_tenth_nuanhui)

ny_10th_xiahoumao = sgs.General(extension, "ny_10th_xiahoumao", "wei", 4, true, false, false)

ny_10th_tongwei = sgs.CreateViewAsSkill
{
    name = "ny_10th_tongwei",
    n = 2,
    view_filter = function(self, selected, to_select)
        return #selected < 2 
    end,
    view_as = function(self, cards)
        if #cards == 2 then
            local card = ny_10th_tongweiCard:clone()
            for _,cc in ipairs(cards) do
                card:addSubcard(cc)
            end
            return card
        end
    end,
    enabled_at_play = function(self, player)
        return not player:hasUsed("#ny_10th_tongwei")
    end
}

ny_10th_tongweiCard = sgs.CreateSkillCard
{
    name = "ny_10th_tongwei",
    will_throw = false,
    filter = function(self, targets, to_select)
        return to_select:objectName() ~= sgs.Self:objectName()
        and #targets < 1
    end,
    on_effect = function(self, effect)
        local room = effect.from:getRoom()
        local source = effect.from

        local log = sgs.LogMessage()
        log.from = source
        log.type = "$RecastCard"
        log.card_str = table.concat(sgs.QList2Table(self:getSubcards()), "+")
        room:sendLog(log)

        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECAST, source:objectName(), self:objectName(), "")
        room:moveCardTo(self, nil, nil, sgs.Player_DiscardPile, reason)

        if source:isDead() then return false end

        source:drawCards(self:subcardsLength(), "recast")
        
        if source:isDead() then return false end
        if effect.to:isDead() then return false end

        if effect.to:getMark("ny_10th_tongwei+"..source:objectName()) > 0 then
            local max = effect.to:getMark("ny_10th_tongwei_max+"..source:objectName())
            local min = effect.to:getMark("ny_10th_tongwei_min+"..source:objectName())
            local mark = string.format("&ny_10th_tongwei+%s+~+%s+#%s",min,max,source:objectName())
            room:setPlayerMark(effect.to, mark, 0)
            room:removePlayerMark(effect.to, "ny_10th_tongwei", 1)
        end

        local first = sgs.Sanguosha:getCard(self:getSubcards():at(0)):getNumber()
        local second = sgs.Sanguosha:getCard(self:getSubcards():at(1)):getNumber()
        local max = math.max(first, second)
        local min = math.min(first, second)

        local mark = string.format("&ny_10th_tongwei+%s+~+%s+#%s",min,max,source:objectName())
        room:setPlayerMark(effect.to, mark, 1)
        room:setPlayerMark(effect.to, "ny_10th_tongwei+"..source:objectName(), 1)
        room:addPlayerMark(effect.to, "ny_10th_tongwei", 1)
        room:setPlayerMark(effect.to, "ny_10th_tongwei_max+"..source:objectName(), max)
        room:setPlayerMark(effect.to, "ny_10th_tongwei_min+"..source:objectName(), min)
    end
}

ny_10th_tongwei_buff = sgs.CreateTriggerSkill{
    name = "#ny_10th_tongwei_buff",
    events = {sgs.CardFinished},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local use = data:toCardUse()
        if use.card:isKindOf("SkillCard") then return false end
        local num = use.card:getNumber()
        room:setPlayerMark(player, "ny_10th_tongwei", 0)

        for _,p in sgs.qlist(room:getOtherPlayers(player)) do
            if p:isAlive() and player:getMark("ny_10th_tongwei+"..p:objectName()) > 0 then
                room:setPlayerMark(player, "ny_10th_tongwei+"..p:objectName(), 0)
                room:sendCompulsoryTriggerLog(p, "ny_10th_tongwei", true)

                local max = player:getMark("ny_10th_tongwei_max+"..p:objectName())
                local min = player:getMark("ny_10th_tongwei_min+"..p:objectName())
                local mark = string.format("&ny_10th_tongwei+%s+~+%s+#%s",min,max,p:objectName())
                room:setPlayerMark(player, mark, 0)

                if num >= min and num <= max then
                    local choices = "slash+dismantlement"
                    local pattern = room:askForChoice(p, "ny_10th_tongwei", choices, data)
                    local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
                    card:setSkillName("_ny_10th_tongwei")
                    room:useCard(sgs.CardUseStruct(card, p, player))
                else
                    room:broadcastSkillInvoke("ny_10th_tongwei")
                end
            end
            if player:isDead() then return false end
        end
    end,
    can_trigger = function(self, target)
        return target and target:isAlive() and target:getMark("ny_10th_tongwei") > 0
    end,
}

ny_10th_cuguo = sgs.CreateTriggerSkill{
    name = "ny_10th_cuguo",
    events = {sgs.CardOffset},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local effect = data:toCardEffect()
        if effect.card:isKindOf("SkillCard") then return false end
        room:addPlayerMark(player, "ny_10th_cuguo-Clear", 1)

        if effect.card:hasFlag("ny_10th_cuguo_"..effect.to:objectName()) then
            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
            room:setCardFlag(effect.card, "-ny_10th_cuguo_"..effect.to:objectName())
            room:loseHp(player, 1)
        end

        if player:isNude() then return false end
        if effect.to:isDead() then return false end

        if player:getMark("ny_10th_cuguo-Clear") == 1 then
            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
            room:askForDiscard(player, self:objectName(), 1, 1, false, true)

            if effect.to:isDead() then return false end

            room:setCardFlag(effect.card, "ny_10th_cuguo_"..effect.to:objectName())
            room:cardEffect(effect.card, player, effect.to)
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName()) and target:isAlive()
    end,
}

ny_10th_xiahoumao:addSkill(ny_10th_tongwei)
ny_10th_xiahoumao:addSkill(ny_10th_tongwei_buff)
ny_10th_xiahoumao:addSkill(ny_10th_cuguo)
extension:insertRelatedSkills("ny_10th_tongwei", "#ny_10th_tongwei_buff")

local skills = sgs.SkillList()

if not sgs.Sanguosha:getSkill("ny_10th_jiaoxia_filter") then skills:append(ny_10th_jiaoxia_filter) end
if not sgs.Sanguosha:getSkill("ny_10th_taji") then skills:append(ny_10th_taji) end
if not sgs.Sanguosha:getSkill("ny_10th_qinghuang") then skills:append(ny_10th_qinghuang) end
if not sgs.Sanguosha:getSkill("ny_tenth_dagongche_slash") then skills:append(ny_tenth_dagongche_slash) end
if not sgs.Sanguosha:getSkill("ny_tenth_dagongche_slashtr") then skills:append(ny_tenth_dagongche_slashtr) end
if not sgs.Sanguosha:getSkill("ny_tenth_dagongche_destory") then skills:append(ny_tenth_dagongche_destory) end
if not sgs.Sanguosha:getSkill("ny_tenth_dagongche_buff") then skills:append(ny_tenth_dagongche_buff) end
if not sgs.Sanguosha:getSkill("ny_10th_paiyi") then skills:append(ny_10th_paiyi) end
if not sgs.Sanguosha:getSkill("ny_10th_shoutan") then skills:append(ny_10th_shoutantr) end
if not sgs.Sanguosha:getSkill("ny_tenth_piliche_target") then skills:append(ny_tenth_piliche_target) end
if not sgs.Sanguosha:getSkill("ny_tenth_piliche_buff") then skills:append(ny_tenth_piliche_buff) end
if not sgs.Sanguosha:getSkill("ny_tenth_piliche_destory") then skills:append(ny_tenth_piliche_destory) end
if not sgs.Sanguosha:getSkill("ny_tenth_piliche_recover") then skills:append(ny_tenth_piliche_recover) end

sgs.Sanguosha:addSkills(skills)

sgs.LoadTranslationTable 
{
    ["sgs10th"] = "三国杀十周年",

--许靖
    ["ny_10th_xujing"] = "许靖-十周年", 
	["&ny_10th_xujing"] = "许靖",
    ["#ny_10th_xujing"] = "丹枫盈瞳",
    ["designer:ny_10th_xujing"] = "官方",
	["cv:ny_10th_xujing"] = "官方",
	["illustrator:ny_10th_xujing"] = "官方",

    ["ny_10th_caixia"] = "才瑕",
    [":ny_10th_caixia"] = "当你造成或受到伤害后，你可摸至多x张牌（x为游戏人数且最多为5）。若如此做，你无法发动此技能，直到你累计使用了等量的牌。",
    ["ny_10th_shangyu"] = "赏誉",
    [":ny_10th_shangyu"] = "锁定技，游戏开始时你获得一张【杀】并标记之，然后将之交给一名角色。此【杀】造成伤害后你和使用者各摸一张牌；进入弃牌堆后你将之交给一名本回合未以此法指定过的角色。",
    ["@ny_10th_shangyu"] = "请将此【杀】交给一名本回合未以此法指定过的角色",

    ["$ny_10th_caixia1"] = "四时钟灵，金秋独桂，品丹桂而闻雨露秋风。",
	["$ny_10th_caixia2"] = "晚木萧萧，雁归衡阳，一叶落而天下知秋。",
	["$ny_10th_shangyu1"] = "君子撷翠屏，盈锦绣大道，诵万世太平。",
	["$ny_10th_shangyu2"] = "野陌有丹桂，沐金秋银露，梦白鹿青崖。",
    ["~ny_10th_xujing"] = "蜀中离客撷银杏，寄君中原一枝秋。",

--周妃
    ["ny_10th_lezhoufei"] = "乐周妃-十周年",
    ["&ny_10th_lezhoufei"] = "周妃",
    ["#ny_10th_lezhoufei"] = "濯荷涤音",
    ["designer:ny_10th_lezhoufei"] = "官方",
	["cv:ny_10th_lezhoufei"] = "官方",
	["illustrator:ny_10th_lezhoufei"] = "官方",

    ["ny_10th_lingkong"] = "灵箜",
    [":ny_10th_lingkong"] = "锁定技，游戏开始时，你的初始手牌增加“箜篌”标记且不计入手牌上限。你于回合外获得牌后，随机将其中一张标记为“箜篌”牌。",
    ["ny_10th_konghou"] = "箜篌",
    ["ny_10th_xianshu"] = "贤淑",
    [":ny_10th_xianshu"] = "出牌阶段，你可以展示一张“箜篌”牌并交给一名其他角色。\
    若此牌为红色，且该角色体力值小于等于你，该角色回复1点体力；\
    若此牌为黑色，且该角色体力值大于等于你，该角色失去1点体力。\
    然后，你摸X张牌（X为你与该角色体力值之差且至多为5）。",

    ["$ny_10th_lingkong1"] = "灵箜有意解相思，夕照独倚楼外楼。",
	["$ny_10th_lingkong2"] = "青山不解秋心意，绿衣落华秋色收。",
	["$ny_10th_xianshu1"] = "飞燕倚新装，剪双翼而引春回江南。",
	["$ny_10th_xianshu2"] = "浣纱弄碧水，女子有仪而无分贵贱。",
    ["~ny_10th_lezhoufei"] = "天薄我以寿，我馈君以情。",

--董绾
    ["ny_10th_donghuan"] = "董绾-十周年",
    ["&ny_10th_donghuan"] = "董绾",
    ["#ny_10th_donghuan"] = "蜜言如鸠",
    ["designer:ny_10th_donghuan"] = "官方",
	["cv:ny_10th_donghuan"] = "官方",
	["illustrator:ny_10th_donghuan"] = "官方",

    ["ny_10th_shengdu"] = "生妒",
    [":ny_10th_shengdu"] = "回合开始时，你可以选择一名角色，该角色下个摸牌阶段摸牌后，你摸等量的牌。",
    ["@ny_10th_shengdu"] = "你可以选择一名角色，该角色下个摸牌阶段摸牌后，你摸等量的牌",
    ["ny_10th_jieling"] = "介绫",
    [":ny_10th_jieling"] = "出牌阶段限一次，你可以将两张颜色不同的手牌当无距离和次数限制的【杀】使用。若此【杀】：造成伤害，其失去1点体力；没造成伤害，你对其发动一次“生妒”。",
   
    ["$ny_10th_shengdu1"] = "姐姐不予妹妹雨露，妹妹必夺姐姐恩宠。",
	["$ny_10th_shengdu2"] = "我家君上人龙之姿，居椒舍我其谁？",
	["$ny_10th_jieling1"] = "白绫一丈胜软红，此间最毒妇人心。",
	["$ny_10th_jieling2"] = "妹妹欲借姐姐性命一用，有借而无还。",
    ["~ny_10th_donghuan"] = "乱世求一自保，何错之过。",
    
--高翔
    ["ny_10th_gaoxiang"] = "高翔-十周年",
    ["&ny_10th_gaoxiang"] = "高翔",
    ["#ny_10th_gaoxiang"] = "引兵为战",
    ["designer:ny_10th_gaoxiang"] = "官方",
	["cv:ny_10th_gaoxiang"] = "官方",
	["illustrator:ny_10th_gaoxiang"] = "官方",

    ["ny_10th_chiying"] = "驰应",
    [":ny_10th_chiying"] = "出牌阶段限一次，你可以选择一名体力值小于等于你的角色，令其攻击范围的其他角色各弃置一张牌。若你选择的是其他角色，其获得其中的基本牌。",
 
    ["$ny_10th_chiying1"] = "街亭危在旦夕，当合兵一道急援。",
	["$ny_10th_chiying2"] = "子龙勿忧，某助将军来擒姜维。",
    ["~ny_10th_gaoxiang"] = "将者无功，何颜顾后。",

    --王濬

    ["ny_10th_wangrui"] = "王濬-十周年",
    ["&ny_10th_wangrui"] = "王濬",
    ["#ny_10th_wangrui"] = "艨艟破浪",
    ["designer:ny_10th_wangrui"] = "官方",
	["cv:ny_10th_wangrui"] = "官方",
	["illustrator:ny_10th_wangrui"] = "官方",

    ["ny_10th_tongye"] = "统业",
    [":ny_10th_tongye"] = "锁定技，游戏开始时/有角色死亡后，若场上现存势力数：\
    小于等于4：你手牌上限+3；\
    小于等于3：你攻击范围+3；\
    小于等于2：你出牌阶段出【杀】次数+3；\
    为1：你摸牌阶段摸牌数+3。 ",
    ["$ny_10th_tongye_kingdoms"] = "当前场上现存势力数为 %arg",
    ["$ny_10th_tongye_draw"] = "%from 因 %arg 的效果将多摸 %arg2 张牌",
    ["ny_10th_changqu"] = "长驱",
    [":ny_10th_changqu"] = "出牌阶段限一次，你可以从你的上家或下家起选择任意名座位连续的其他角色，第一个目标角色获得战舰标记。获得战舰标记的角色需要选择一项 ：\
    1.交给你X张手牌，然后将战舰标记移动到下个目标；\
    2.下次受到的属性伤害+X，然后横置自身。\
    （X为选项一被选择的次数且至少为1）",
    ["@ny_10th_changqu"] = "请选择战舰标记的终点",
    ["$ny_10th_changqu_finish"] = "战舰的终点是 %to",
    ["$ny_10th_changqu_willdamgage"] = "%from 下次受到的属性伤害将增加 %arg 点",
    ["$ny_10th_changqu_damage"] = "%from 受到的属性伤害因 %arg 的效果由 %arg2 点增加到 %arg3 点",
    ["ny_10th_changqu_finish"] = "请交给 %src 共计 %arg 张手牌，或横置自身并使下次受到的属性伤害 +%arg",
    ["ny_10th_changqu_move"] = "请交给 %src 共计 %arg 张手牌,然后将战舰标记移动给下一名角色，或横置自身并使下次受到的属性伤害 +%arg",
   
    ["$ny_10th_tongye1"] = "北马临江，曳江北春风，抚江南之锦绣。",
	["$ny_10th_tongye2"] = "老骥扶剑，奋暮年壮志，益堪舆之万里。",
	["$ny_10th_changqu1"] = "过巫峡、至秭归，焚铁索于一炬，执长缨缚苍龙。",
	["$ny_10th_changqu2"] = "破荆门、克三山，巨舰蔽江，请降幡出石头。",
    ["~ny_10th_wangrui"] = "扫六合、全金瓯，虽死而无憾。",

--董翓   
    ["ny_10th_dongxie"] = "董翓-十周年",
    ["&ny_10th_dongxie"] = "董翓",
    ["#ny_10th_dongxie"] = "月辉映荼",
    ["designer:ny_10th_dongxie"] = "官方",
	["cv:ny_10th_dongxie"] = "官方",
	["illustrator:ny_10th_dongxie"] = "官方",

    ["ny_10th_jiaoxia"] = "狡黠",
    [":ny_10th_jiaoxia"] = "出牌阶段开始时，你可令你此阶段所有手牌视为【杀】。以此法使用的【杀】若造成伤害，你可于此【杀】结算完毕后使用原卡牌。出牌阶段，你对每名其他角色使用的第一张【杀】无次数限制。\
    注释：视为使用卡牌时须点一下技能才能选择目标[找到了原因，但先不修复]",
    ["ny_10th_jiaoxia:slash"] = "你可令你此阶段所有手牌视为【杀】",
    ["ny_10th_jiaoxia_filter"] = "手牌视为【杀】",
    ["@ny_10th_jiaoxia"] = "你可以视为使用了 【%src】", 
    ["ny_10th_humei"] = "狐魅",
    [":ny_10th_humei"] = "出牌阶段每项限一次，你可令一名体力值至多为x的角色（x为你本阶段造成的伤害次数）：1、摸一张牌；2、交给你一张牌；3、回复1点体力。",
    ["@ny_10th_humei"] = "请交给 %src 一张牌",
    ["ny_10th_humei:draw"] = "摸一张牌",
    ["ny_10th_humei:give"] = "交给你一张牌",
    ["ny_10th_humei:recover"] = "回复1点体力",

    ["$ny_10th_jiaoxia1"] = "青锋绕指柔，将军可愿提头来见？",
	["$ny_10th_jiaoxia2"] = "我视诸君如豕犬，杀剐不过覆手之间。",
	["$ny_10th_humei1"] = "狐假虎威，以巡山林，可使百兽折膝。",
	["$ny_10th_humei2"] = "狐鸣青丘，其声呦呦，自有英雄入幕。",
    ["~ny_10th_dongxie"] = "新人胜旧人，现在叫人家牛夫人。",

--裴元绍      
    ["ny_10th_peiyuanshao"] = "裴元绍-十周年",
    ["&ny_10th_peiyuanshao"] = "裴元绍",
    ["#ny_10th_peiyuanshao"] = "买椟还珠",
    ["designer:ny_10th_peiyuanshao"] = "官方",
	["cv:ny_10th_peiyuanshao"] = "官方",
	["illustrator:ny_10th_peiyuanshao"] = "官方",

    ["ny_10th_moyu"] = "没欲",
    [":ny_10th_moyu"] = "出牌阶段，你可获得本阶段未以此法指定过的一名其他角色区域内的一张牌，然后该角色可选择是否对你使用一张【杀】，此【杀】伤害值为x（x为此技能本回合发动次数）。若此【杀】对你造成伤害，此技能本回合失效。",
    ["@ny_10th_moyu"] = "你可以对 %src 使用一张伤害为 %arg 的【杀】",
    ["$ny_10th_moyu_damage_add"] = "%from 受到的伤害因 %arg 的效果由 %arg2 点增加到了 %arg3 点",

	["$ny_10th_moyu1"] = "人之所有，我之所欲。",
	["$ny_10th_moyu2"] = "胸有欲壑千丈，自当饥不择食。",
    ["~ny_10th_peiyuanshao"] = "好生厉害的白袍小将。",

--孙翎鸾
    ["ny_10th_sunlinluan"] = "孙翎鸾-十周年",
    ["&ny_10th_sunlinluan"] = "孙翎鸾",
    ["#ny_10th_sunlinluan"] = "青翎和鸣",
    ["designer:ny_10th_sunlinluan"] = "官方",
	["cv:ny_10th_sunlinluan"] = "官方",
	["illustrator:ny_10th_sunlinluan"] = "官方",

    ["ny_10th_lingyue"] = "聆乐",
    [":ny_10th_lingyue"] = "锁定技，一名角色在本轮首次造成伤害后，你摸1张牌。若此时是该角色回合外，改为摸X张牌（X为本回合全场造成的伤害值）。",
    ["ny_pandi_tenth"] = "盼睇",
    ["ny_pandi_tenth_use"] = "盼睇",
    [":ny_pandi_tenth"] = "出牌阶段，你可以选择一名本回合未造成过伤害的其他角色，你此阶段使用的下一张牌，视为该角色使用。",
    ["@ny_pandi_tenth"] = "你可以为 %src 使用一张手牌",
    ["$ny_pandi_tenth_usecard_targetfixed"] = "%from 令 %to 使用了 %card",
    ["$ny_pandi_tenth_usecard_nottargetfixed"] = "%from 令 %arg 使用了 %card, 目标是 %to",

    ["$ny_10th_lingyue1"] = "既存慧心，则虫石草木之声皆为仙乐。",
	["$ny_10th_lingyue2"] = "金珠坠玉盘，其声若击磬、灵同鸣佩。",
	["$ny_pandi_tenth1"] = "摩由逻入浮屠，拜遍千尊，只求一人之心。",
	["$ny_pandi_tenth2"] = "南客闻笙歌管弦，必盼睇而舞，若有意焉。",
    ["~ny_10th_sunlinluan"] = "愿以千世轮回，换一世厮守。",

--乐綝
    ["ny_10th_lelin"] = "乐綝-十周年",
    ["&ny_10th_lelin"] = "乐綝",
    ["#ny_10th_lelin"] = "广昌亭侯",
    ["designer:ny_10th_lelin"] = "官方",
	["cv:ny_10th_lelin"] = "官方",
	["illustrator:ny_10th_lelin"] = "官方",

    ["ny_tenth_porui"] = "破锐",
    [":ny_tenth_porui"] = "每轮限一次，其他角色的结束阶段，你可以弃置一张牌并选择一名此回合内失去过牌的另一名其他角色，你视为对该角色依次使用X+1张【杀】，然后你交给其X张手牌（X为其失去的牌数且最多为5，手牌不足X张则全给）。",
    [":ny_tenth_porui1"] = "每轮限两次，其他角色的结束阶段，你可以弃置一张牌并选择一名此回合内失去过牌的另一名其他角色，你视为对该角色依次使用X+1张【杀】，然后你交给其X张手牌（X为其失去的牌数且最多为5，手牌不足X张则全给）。",
    [":ny_tenth_porui2"] = "每轮限一次，其他角色的结束阶段，你可以弃置一张牌并选择一名此回合内失去过牌的另一名其他角色，你视为对该角色依次使用X+1张【杀】（X为其失去的牌数且最多为5，手牌不足X张则全给）。",
    [":ny_tenth_porui3"] = "每轮限两次，其他角色的结束阶段，你可以弃置一张牌并选择一名此回合内失去过牌的另一名其他角色，你视为对该角色依次使用X+1张【杀】（X为其失去的牌数且最多为5，手牌不足X张则全给）。",
    ["@ny_tenth_porui"] = "你可以弃置一张牌并选择一名此回合内失去过牌的另一名其他角色，你视为对该角色依次使用X+1张【杀】",
    ["ny_tenth_porui_give"] = "请交给 %src 共计 %arg 张手牌",
    ["ny_10th_gonghu"] = "共护",
    [":ny_10th_gonghu"] = "锁定技，你的回合外，当你于一回合内失去超过1张基本牌后，{破锐}改为每轮限2次；当你于一回合内造成或受到超过1点伤害后，你将{破锐}中的“交给”的效果删除。若以上两个效果均已触发，则你本局游戏接下来你使用红色基本牌无法响应，使用红色普通锦囊牌可以额外指定一个目标。",
    ["$ny_10th_gonghu_noresponse"] = "%from 使用的 %card 因 %arg 的效果不可被响应",
    ["@ny_10th_gonghu"] = "你可以为【%src】增加一个目标",

    ["$ny_tenth_porui1"] = "承父勇烈，问此间谁堪敌手。",
	["$ny_tenth_porui2"] = "敌锋虽锐，吾亦击之如破卵。",
	["$ny_10th_gonghu1"] = "大都督中伏，吾等当舍命救之。",
	["$ny_10th_gonghu2"] = "袍泽临难，但有共死而无坐视。",
    ["~ny_10th_lelin"] = "天下犹魏，公休何故如此？",

--杜预
    ["ny_10th_duyu"] = "杜预-十周年",
    ["&ny_10th_duyu"] = "杜预",
    ["#ny_10th_duyu"] = "文成武德",
    ["designer:ny_10th_duyu"] = "官方",
	["cv:ny_10th_duyu"] = "官方",
	["illustrator:ny_10th_duyu"] = "官方",

    ["ny_10th_jianguo"] = "谏国",
    [":ny_10th_jianguo"] = "出牌阶段限一次，你可以选择一项：令一名角色摸一张牌然后弃置一半的手牌（向下取整）；令一名角色弃置一张牌然后摸与当前手牌数一半数量的牌（向下取整）。",
    ["ny_10th_jianguo:draw"] = "令其弃置一张牌然后摸与当前手牌数一半数量的牌（向下取整）",
    ["ny_10th_jianguo:dis"] = "令其摸一张牌然后弃置一半的手牌（向下取整）",
    ["ny_10th_qinshi"] = "倾势",
    [":ny_10th_qinshi"] = "当你于回合内使用【杀】或锦囊牌指定一名其他角色为目标后，若此牌是你本回合使用的第X张牌，你可对其中一名目标角色造成一点伤害。（X为你的手牌数）",
    ["@ny_10th_qinshi"] = "你可对其中一名目标角色造成一点伤害",

    ["$ny_10th_jianguo1"] = "彭蠡雁惊，此诚平吴之时。",
	["$ny_10th_jianguo2"] = "奏三陈之诏，谏一国之弊。",
	["$ny_10th_qinshi1"] = "潮起万丈之仞，可阻江南春风。",
	["$ny_10th_qinshi2"] = "缮甲兵，耀威武，伐吴指日可待。",
    ["~ny_10th_duyu"] = "六合即归一统，奈何寿数已尽。",

--孙寒华
    ["ny_10th_sunhanhua"] = "孙寒华-十周年",
    ["&ny_10th_sunhanhua"] = "孙寒华",
    ["#ny_10th_sunhanhua"] = "莲漪清荷",
    ["designer:ny_10th_sunhanhua"] = "官方",
	["cv:ny_10th_sunhanhua"] = "官方",
	["illustrator:ny_10th_sunhanhua"] = "官方",

    ["ny_10th_huiling"] = "汇灵",
    [":ny_10th_huiling"] = "锁定技，弃牌堆中的红色牌数量多于黑色牌时，你使用牌时回复1点体力；弃牌堆中黑色牌数量多于红色牌时，你使用牌时可弃置一名其他角色一张牌；你使用弃牌堆中颜色较少的牌时获得一个“灵”标记。",
    ["@ny_10th_huiling"] = "你可弃置一名其他角色一张牌",
    ["ny_10th_huiling_ling"] = "灵",
    ["ny_10th_chongxu"] = "冲虚",
    [":ny_10th_chongxu"] = "限定技，出牌阶段，若“灵”的数量大于等于4，你可以失去“汇灵”，增加等量的体力上限，并获得“踏寂”和“清荒”。",
    ["ny_10th_taji"] = "踏寂",
    [":ny_10th_taji"] = "你失去手牌时，根据此牌的失去方式执行以下效果：使用，弃置其他角色一张牌；打出，摸一张牌；弃置，回复1点体力；其他,你下次对其他角色造成的伤害+1。",
    ["@ny_10th_taji"] = "你可弃置一名其他角色一张牌",
    ["$ny_10th_qinghuang_add"] = "“清荒”为 %from 增加的额外效果为 %arg",
    ["$ny_10th_taji_damage"] = "%from 对 %to 造成的伤害因 %arg 由 %arg2 点增加到 %arg3 点",
    ["ny_10th_taji:use"] = "弃置其他角色一张牌",
    ["ny_10th_taji:response"] = "摸一张牌",
    ["ny_10th_taji:discard"] = "回复1点体力",
    ["ny_10th_taji:other"] = "你下次对其他角色造成的伤害+1",
    ["ny_10th_qinghuang"] = "清荒",
    [":ny_10th_qinghuang"] = "出牌阶段开始时，你可以减1点体力上限，然后你此阶段失去牌时触发“踏寂”随机额外获得一种效果。",
    ["ny_10th_qinghuang:invoke"] = "你可以减1点体力上限，然后你此阶段失去牌时触发“踏寂”随机额外获得一种效果",

    ["$ny_10th_huiling1"] = "金丹坎离，太上忘夏，老君以何长生？",
	["$ny_10th_huiling2"] = "夏荷日长，暑气渐生，可采金乌入药。",
	["$ny_10th_chongxu1"] = "三伏暑气盛，若心静之，则不为扰之。",
	["$ny_10th_chongxu2"] = "我欲冲虚而去，效后羿挽弓，逐烈日于人间。",
    ["$ny_10th_taji1"] = "夏蝉鸣更寂，譬如仙途，只闻风雷。",
	["$ny_10th_taji2"] = "小荷落渊潭，碧波涤岸，一点心有灵犀。",
    ["$ny_10th_qinghuang1"] = "君不见三九之凋木，向来皆裹盎然之翠。",
	["$ny_10th_qinghuang2"] = "夏荷长于红壤，其历三伏而茁盈仓之谷。",
    ["~ny_10th_sunhanhua"] = "暑气升腾，欲离人间往广寒。",

    --陈泰

    ["ny_10th_chentai"] = "陈泰-十周年",
    ["&ny_10th_chentai"] = "陈泰",
    ["#ny_10th_chentai"] = "断围破蜀",
    ["designer:ny_10th_chentai"] = "官方",
	["cv:ny_10th_chentai"] = "官方",
	["illustrator:ny_10th_chentai"] = "官方",

    ["ny_10th_jiuxian"] = "救陷",
    [":ny_10th_jiuxian"] = "出牌阶段限一次，你可以重铸一半数量的手牌（向上取整），然后视为使用一张【决斗】。此牌对目标角色造成伤害后，你可令其攻击范围内的一名其他角色回复1点体力。",
    ["@ny_10th_jiuxian"] = "你可以令 %src 攻击范围内的一名其他角色回复一点体力",
    ["ny_10th_chenyong"] = "沉勇",
    [":ny_10th_chenyong"] = "结束阶段，你可以摸x张牌。（x为本回合你使用过牌的类型数）",
    ["ny_10th_chenyong:draw"] = "你可以发动“沉勇”摸 %src 张牌",

    ["$ny_10th_jiuxian1"] = "今袍泽陷于敌阵，我辈岂能坐视。",
    ["$ny_10th_jiuxian2"] = "军中一体，荣损与共，约为兄弟。",
    ["$ny_10th_chenyong1"] = "今临危致命，当志在高构，尽力及礼。",
    ["$ny_10th_chenyong2"] = "明统简志，方能立功、立事。",
    ["~ny_10th_chentai"] = "今帝身死，泰千古之罪。",

    --桓范

    ["ny_10th_huanfan"] = "桓范-十周年",
    ["&ny_10th_huanfan"] = "桓范",
    ["#ny_10th_huanfan"] = "墨染山河",
    ["designer:ny_10th_huanfan"] = "官方",
	["cv:ny_10th_huanfan"] = "官方",
	["illustrator:ny_10th_huanfan"] = "官方",

    ["ny_10th_fumou"] = "腹谋",
    [":ny_10th_fumou"] = "当你受到伤害后，你可令至多X名角色依次选择一项(X为你已损失的体力值):1.移动场上一张牌；2.弃置所有手牌并摸两张牌；3.弃置装备区所有牌并回复1点体力。",
    ["@ny_10th_fumou"] = "你可以对至多 %src 名角色发动 “腹谋”",
    ["$ny_10th_fumou_chosen"] = "%from 选择了 %arg",
    ["ny_10th_fumou:move"] = "移动场上一张牌",
    ["ny_10th_fumou:discard"] = "弃置所有手牌并摸两张牌",
    ["ny_10th_fumou:recover"] = "弃置装备区所有牌并回复1点体力",
    ["ny_tenth_jianzheng"] = "谏诤",
    [":ny_tenth_jianzheng"] = "出牌阶段限一次，你可观看一名其他角色的手牌，然后若其中有你可以使用的牌，你可以获得并使用其中一张。若此牌指定了该角色为目标，则横置你与其的武将牌，然后其观看你的手牌。",
    ["ny_tenth_jianzheng_use"] = "谏诤",
    ["#ny_tenth_jianzheng"] = "谏诤",
    ["@ny_tenth_jianzheng"] = "你可以获得并使用 %src 的一张手牌",
    ["$ny_tenth_jianzheng_usecard_targetfixed"] = "%from 将获得并使用 %arg 的 %card",
    ["$ny_tenth_jianzheng_usecard_nottargetfixed"] = "%from 将获得并使用 %arg 的 %card , 目标是 %to",

    ["$ny_10th_fumou1"] = "腹有良谋万千，可以一策而倾万丈之高楼。",
    ["$ny_10th_fumou2"] = "吾为君家之智囊，定不使社稷丧于奴隶之手。",
    ["$ny_tenth_jianzheng1"] = "谏言如药，虽苦而利于身，君奈何讳苦忌医？",
    ["$ny_tenth_jianzheng2"] = "将军受遗命托孤，岂能视怀异之臣而不理？",
    ["~ny_10th_huanfan"] = "若将军用吾之计，何至于此。",

    --乐蔡文姬

    ["ny_10th_yuecaiwenji"] = "乐蔡文姬-十周年",
    ["&ny_10th_yuecaiwenji"] = "蔡文姬",
    ["#ny_10th_yuecaiwenji"] = "姝丽风华",
    ["designer:ny_10th_yuecaiwenji"] = "官方",
	["cv:ny_10th_yuecaiwenji"] = "官方",
	["illustrator:ny_10th_yuecaiwenji"] = "官方",

    ["ny_10th_shuangjia"] = "霜笳",
    [":ny_10th_shuangjia"] = "锁定技，游戏开始时，你将初始手牌标记为“胡笳”牌（“胡笳”牌不计入你的手牌上限；其他角色计算与你的距离增加“胡笳”牌数，至多+5）。",
    ["ny_10th_hujia"] = "胡笳",
    ["ny_10th_beifen"] = "悲愤",
    [":ny_10th_beifen"] = "锁定技，当你失去”胡笳“后，你获得与手中“胡笳”花色均不同的牌各一张。你手中“胡笳”少于其他牌时，你使用牌无距离和次数限制。",

    ["$ny_10th_shuangjia1"] = "暮云深锁归乡路，南不见长安，唯叹笳声肃。",
    ["$ny_10th_shuangjia2"] = "昔年行兰舟，芦花妆橹，今遗霜泪染胡笳。",
    ["$ny_10th_beifen1"] = "残雪碎珠玉，望断南归路，不知春在谁家。",
    ["$ny_10th_beifen2"] = "红萼向边庭，空有慧剑，难斩千缕离愁。",
    ["~ny_10th_yuecaiwenji"] = "一生坎坷诉霜雪，一曲断肠付笳声。",

    --袁姬

    ["ny_10th_yuanji"] = "袁姬-十周年",
    ["&ny_10th_yuanji"] = "袁姬",
    ["#ny_10th_yuanji"] = "银瞳缤纷",
    ["designer:ny_10th_yuanji"] = "官方",
	["cv:ny_10th_yuanji"] = "官方",
	["illustrator:ny_10th_yuanji"] = "官方",

    ["ny_10th_fangdu"] = "芳妒",
    [":ny_10th_fangdu"] = "锁定技，你的回合外，每回合你第一次受到普通伤害后回复1点体力，你第一次受到属性伤害后随机获得伤害来源一张手牌。",
    ["ny_10th_jiexing"] = "节行",
    [":ny_10th_jiexing"] = "当你的体力值发生变化后，你可以摸一张牌，且此牌不计入本回合的手牌上限。",
    ["ny_10th_jiexing:draw"] = "你可以摸一张牌，且此牌不计入本回合的手牌上限",

    ["$ny_10th_fangdu1"] = "清荷本天作之美，淤泥何能染之。",
    ["$ny_10th_fangdu2"] = "一觞盈袖兰香尽，三千愁肠系东篱。",
    ["$ny_10th_jiexing1"] = "我本淮南仲家凤，虽坠东海羽不凌。",
    ["$ny_10th_jiexing2"] = "诸卿美若瑶娥，袁氏之遗珠何能及也。",
    ["~ny_10th_yuanji"] = "向阳之草木，终做零落之红泥。",

    --神张角

    ["ny_10th_shenzhangjiao"] = "神张角-十周年",
    ["&ny_10th_shenzhangjiao"] = "张角",
    ["#ny_10th_shenzhangjiao"] = "驭道震泽",
    ["designer:ny_10th_shenzhangjiao"] = "官方",
	["cv:ny_10th_shenzhangjiao"] = "官方",
	["illustrator:ny_10th_shenzhangjiao"] = "官方",

    ["ny_10th_yizhao"] = "异兆",
    [":ny_10th_yizhao"] = "锁定技，你使用或打出一张牌后，获得等于此牌点数的“黄”标记。每次“黄”的十位数因此变化时，你获得牌堆中一张与变化后十位数点数相同的牌。",
    ["ny_10th_huang"] = "黄",
    ["ny_10th_sijun"] = "肆军",
    [":ny_10th_sijun"] = "准备阶段，若“黄”标记数量大于牌堆的牌数，你可以移去所有“黄”并洗牌，然后获得随机获得点数之和为36的牌。",
    ["ny_10th_sijun:draw"] = "你可以移去所有“黄”并洗牌，然后获得随机获得点数之和为36的牌",
    ["ny_10th_sanshou"] = "三首",
    [":ny_10th_sanshou"] = "当你受到伤害时，你可以亮出牌堆顶的三张牌，若其中有本回合未使用过的牌的类型，防止此伤害。",
    ["$ny_10th_sanshou_damage"] = "%from 因 %arg 的效果防止了即将受到的 %arg2 点伤害",
    ["ny_10th_tianjie"] = "天劫",
    [":ny_10th_tianjie"] = "一名角色的回合结束时，若本回合牌堆进行过洗牌，你可以对至多三名其他角色各造成X点雷电伤害（X为其手牌中【闪】的数量，且至少为1）。",
    ["@ny_10th_tianjie"] = "你可以对至多 3 名其他角色发动 “天劫”",

    ["$ny_10th_yizhao1"] = "苍天离析，汉祚倾颓，逢甲子之岁可问道太平。",
    ["$ny_10th_yizhao2"] = "紫薇离北，七杀掠日，此天地欲复以吾为刍狗。",
    ["$ny_10th_sijun1"] = "苍天已被吾泪没，且看黄天昭太平！",
    ["$ny_10th_sijun2"] = "黄巾覆首，联方数万，此击可撼百年之炎汉。",
    ["$ny_10th_sanshou1"] = "贫道所求之道，匪富贵，匪长生，唯愿天下太平。",
    ["$ny_10th_sanshou2"] = "诸君刀利，可斩百头、万头，然可绝太平于人间否？",
    ["$ny_10th_tianjie1"] = "雷池铸剑，今霜刃即成，当振天下于大白。",
    ["$ny_10th_tianjie2"] = "汝辈食民脂、靡民膏，当受天劫而死！",
    ["~ny_10th_shenzhangjiao"] = "书中皆记王侯事，青史不载人间名。",

    --张奋

    ["ny_10th_zhangfen"] = "张奋-十周年",
    ["&ny_10th_zhangfen"] = "张奋",
    ["#ny_10th_zhangfen"] = "天工神机",
    ["designer:ny_10th_zhangfen"] = "官方",
	["cv:ny_10th_zhangfen"] = "官方",
	["illustrator:ny_10th_zhangfen"] = "官方",

    ["_ny_tenth_dagongche"] = "大攻车",
    ["ny_tenth_dagongche"] = "大攻车",
    [":_ny_tenth_dagongche"] = "装备牌·宝物<br /><b>装备效果</b>：出牌阶段开始时，你可以视为使用了一张【杀】（不计入次数限制），若以此法造成伤害，你弃置目标一张牌。\
    若未升级，此牌无法被弃置；\
    此宝物离开装备区时销毁。\
    升级选项：无视距离和防具；目标数+1；弃牌数+1。",
    ["ny_tenth_zhangfen_card"] = "张奋专属",
    ["@ny_tenth_dagongche_slash"] = "你可以视为使用了一张不计入次数限制的【杀】(可以有额外的 %src 个目标)",
    ["ny_tenth_wanglu"] = "望橹",
    [":ny_tenth_wanglu"] = "锁定技，准备阶段，若你的装备区里没有【大攻车】，则将之置入你的装备区，否则你执行一个额外的出牌阶段。",
    ["$ny_tenth_wanglu_get"] = "%from 发动 %arg 将 %card 置入了装备区",
    ["$ny_tenth_wanglu_phase"] = "%from 因 %arg 的效果将执行一个额外的 %arg2 阶段",
    ["ny_tenth_xianzhu"] = "陷筑",
    [":ny_tenth_xianzhu"] = "每当你的【杀】造成伤害后，你可升级【大攻车】（每个【大攻车】 最多升5次）。",
    [":ny_tenth_xianzhu1"] = "每当你的【杀】造成伤害后，你可升级【大攻车】（每个【大攻车】 最多升5次）。",
    [":ny_tenth_xianzhu2"] = "每当你的【杀】造成伤害后，你可升级【大攻车】（每个【大攻车】 最多升5次）。\
    当前升级：可以弃置 %arg1 张牌，可以指定 %arg2 个额外目标",
    [":ny_tenth_xianzhu3"] = "每当你的【杀】造成伤害后，你可升级【大攻车】（每个【大攻车】 最多升5次）。\
    当前升级：可以弃置 %arg1 张牌，可以指定 %arg2 个额外目标 ， 无距离限制且无视目标防具",
    ["ny_tenth_xianzhu:update"] = "你可发动“陷筑”升级【大攻车】",
    ["ny_tenth_xianzhu:discards"] = "额外弃置一张牌",
    ["ny_tenth_xianzhu:targets"] = "额外指定一名目标",
    ["ny_tenth_xianzhu:ignore"] = "无距离限制且无视目标防具",
    ["ny_tenth_xianzhu_update"] = "升级次数",
    ["ny_tenth_chaixie"] = "拆械",
    [":ny_tenth_chaixie"] = "锁定技，当【大攻车】销毁后，你摸X张牌（X为该【大攻车】的升级次数）。",

    ["$ny_tenth_wanglu1"] = "大攻既出，何城可当？试问天下枭雄！",
    ["$ny_tenth_wanglu2"] = "将有作于上者，可得吾器而存之！",
    ["$ny_tenth_xianzhu1"] = "金石筑城，若阙一砖片瓦，虽坚亦可陷筑！",
    ["$ny_tenth_xianzhu2"] = "土木作车，虽无利刃坚甲，执素亦摄群雄！",
    ["$ny_tenth_chaixie1"] = "拆补折合之术，似流水之无形，其以退为进！",
    ["$ny_tenth_chaixie2"] = "昔大鲸落而万物生，今大攻拆可盈三军！",
    ["~ny_10th_zhangfen"] = "江南好，最好是青翎。",

    --界钟会

    ["ny_10th_jiezhonghui"] = "界钟会-十周年",
    ["&ny_10th_jiezhonghui"] = "钟会",
    ["#ny_10th_jiezhonghui"] = "纵恣挥军",
    ["designer:ny_10th_jiezhonghui"] = "官方",
	["cv:ny_10th_jiezhonghui"] = "官方",
	["illustrator:ny_10th_jiezhonghui"] = "官方",

    ["ny_10th_quanji"] = "权计",
    [":ny_10th_quanji"] = "当你的牌被其他角色获得或你受到1点伤害后，你可以摸一张牌，然后你将一张手牌置于武将牌上，称为“权”；你的手牌上限+X（X为“权”的数量）",
    ["ny_10th_quanji:draw"] = "你可以发动“权计”摸一张牌，然后你将一张手牌置于武将牌上",
    ["@ny_10th_quanji"] = "请将一张手牌当作“权”移出游戏",
    ["ny_10th_quan"] = "权",
    ["ny_10th_zili"] = "自立",
    [":ny_10th_zili"] = "觉醒技，准备阶段，若“权”的数量大于等于3，你回复1点体力并摸两张牌，然后减1点体力上限，获得“排异”。",
    ["ny_10th_paiyi"] = "排异",
    [":ny_10th_paiyi"] = "出牌阶段每项限一次，你可以移去一张“权”， 然后选择一项：1.令一名角色摸X张牌；2.对X名角色各造成1点伤害。（X为“权”的数量且至少为1）",
    ["$ny_10th_paiyi_chosen"] = "%from 选择了 %arg",
    ["ny_10th_paiyi:draw"] = "令一名角色摸X张牌",
    ["ny_10th_paiyi:damage"] = "对X名角色各造成1点伤害",

    ["$ny_10th_quanji1"] = "精练策数，料敌制胜！",
    ["$ny_10th_quanji2"] = "算无遗策，晋道克昌，皆吾之力也！",
    ["$ny_10th_zili1"] = "功高名盛，安得善终，唯自立也！",
    ["$ny_10th_zili2"] = "今奉郭皇后遗诏，起兵讨伐司马乱臣。",
    ["$ny_10th_paiyi1"] = "铲除异己，方可酣睡！",
    ["$ny_10th_paiyi2"] = "党同伐异，决不姑息！",
    ["~ny_10th_jiezhonghui"] = "不学陶朱法，游魂归故乡！",

    --经典曹操

    ["ny_10th_jindiancaocao"] = "经典曹操-十周年",
    ["&ny_10th_jindiancaocao"] = "曹操",
    ["#ny_10th_jindiancaocao"] = "魏武帝",
    ["designer:ny_10th_jindiancaocao"] = "官方",
	["cv:ny_10th_jindiancaocao"] = "官方",
	["illustrator:ny_10th_jindiancaocao"] = "官方",

    ["ny_10th_jingdianjianxiong"] = "奸雄",
    [":ny_10th_jingdianjianxiong"] = "当你受到伤害后，你可以摸1张牌，并获得造成此伤害的牌。每次发动此技能，摸牌数永久+1（至多为5）。",
    [":ny_10th_jingdianjianxiong1"] = "当你受到伤害后，你可以摸 %arg1 张牌，并获得造成此伤害的牌。每次发动此技能，摸牌数永久+1（至多为5）。",
    ["ny_10th_jingdianjianxiong:draw"] = "你可以获得【%src】并摸%arg张牌",
    ["ny_10th_jingdianjianxiong_nocard"] = "没有卡牌",
    ["ny_10th_jingdianjianxiong_draw"] = "奸雄摸牌数",

    ["$ny_10th_jingdianjianxiong1"] = "宁教我负天下人，休教天下人负我！",
    ["$ny_10th_jingdianjianxiong2"] = "吾好梦中杀人！",
    ["~ny_10th_jindiancaocao"] = "霸业未成…未成啊！",

    --经典孙权

    ["ny_10th_jingdiansunquan"] = "经典孙权-十周年",
    ["&ny_10th_jingdiansunquan"] = "孙权",
    ["#ny_10th_jingdiansunquan"] = "年轻的贤君",
    ["designer:ny_10th_jingdiansunquan"] = "官方",
	["cv:ny_10th_jingdiansunquan"] = "官方",
	["illustrator:ny_10th_jingdiansunquan"] = "官方",

    ["ny_10th_jingdianzhiheng"] = "制衡",
    [":ny_10th_jingdianzhiheng"] = "出牌阶段限一次，你可以弃置任意张牌，然后摸等量的牌。若你以此法弃置了所有的手牌，额外摸1张牌。\
    你的回合内每名其他角色每回合限一次，你对其他角色造成伤害后，本回合此技能发动次数+1。",

    ["$ny_10th_jingdianzhiheng1"] = "容我三思！",
    ["$ny_10th_jingdianzhiheng2"] = "且慢！",
    ["~ny_10th_jingdiansunquan"] = "父亲，大哥，仲谋愧矣。",

    --经典刘备

    ["ny_10th_jingdianliubei"] = "经典刘备-十周年",
    ["&ny_10th_jingdianliubei"] = "刘备",
    ["#ny_10th_jingdianliubei"] = "乱世的枭雄",
    ["designer:ny_10th_jingdianliubei"] = "官方",
	["cv:ny_10th_jingdianliubei"] = "官方",
	["illustrator:ny_10th_jingdianliubei"] = "官方",

    ["ny_tenth_jingdianrende"] = "仁德",
    [":ny_tenth_jingdianrende"] = "出牌阶段每名其他角色限一次，你可以获得一名其他角色两张手牌，然后视为使用一张基本牌。",
    ["@ny_tenth_jingdianrende"] = "你可以视为使用了【%src】",
    ["ny_tenth_jingdianrende_choice"] = "请选择要使用的基本牌",

    ["$ny_tenth_jingdianrende1"] = "惟贤惟德，能服于人。",
    ["$ny_tenth_jingdianrende2"] = "以德服人。",
    ["~ny_10th_jingdianliubei"] = "这就是，桃园吗？",

    --全惠解

    ["ny_10th_quanhuijie"] = "全惠解-十周年",
    ["&ny_10th_quanhuijie"] = "全惠解",
    ["#ny_10th_quanhuijie"] = "沄英沐鲤",
    ["designer:ny_10th_quanhuijie"] = "官方",
	["cv:ny_10th_quanhuijie"] = "官方",
	["illustrator:ny_10th_quanhuijie"] = "银色骐骥",

    ["ny_tenth_huishu"] = "慧淑",
    [":ny_tenth_huishu"] = "摸牌阶段结束时，你可以摸3张牌，然后弃置1张手牌。若如此做，当你本回合弃置超过2张牌时，你从弃牌堆中获得等量非基本牌。",
    [":ny_tenth_huishu1"] = "摸牌阶段结束时，你可以摸%arg1张牌，然后弃置%arg2张手牌。若如此做，当你本回合弃置超过%arg3张牌时，你从弃牌堆中获得等量非基本牌。",
    ["ny_tenth_huishu_now"] = "慧淑已弃置",
    ["ny_tenth_huishu_target"] = "慧淑目标",
    ["ny_tenth_huishu:draw"] = "你可以发动“慧淑”摸%src张牌并弃置%arg张手牌",
    ["ny_10th_yishu"] = "易数",
    [":ny_10th_yishu"] = "锁定技，当你于出牌阶段外失去牌后，“慧淑”中最小的一个数字+2且最大的一个数字-1。\
    <font color=\"red\"><b>请注意：没有“慧淑”技能时不会触发这个技能！！！</b></font>",
    ["ny_10th_yishu_add"] = "请选择要减小的数字",
    ["ny_10th_yishu_remove"] = "请选择要增加的数字",
    ["ny_10th_yishu:draw"] = "摸牌数(当前为%src)",
    ["ny_10th_yishu:discard"] = "摸牌后弃牌数(当前为%src)",
    ["ny_10th_yishu:get"] = "获得非基本牌所需弃牌数(当前为%src)",
    ["ny_10th_ligong"] = "离宫",
    [":ny_10th_ligong"] = "觉醒技，准备阶段，若“慧淑”有数字达到5，你加1点体力上限并回复1点体力，失去技能“易数”，然后随机抽取四个吴国女性武将，且可以获得其中两个技能。若你以此法获得了技能，则你失去技能“慧淑”，否则你摸三张牌。\
    <font color=\"red\"><b>不想拿技能可以随便选一名武将然后选取消</b></font>",

    ["$ny_tenth_huishu1"] = "白鹿呦呦，宿野之秋，闻伊在水，如云出岫。",
    ["$ny_tenth_huishu2"] = "淑女于沚，君子逑之，其生漫漫，白首偕之。",
    ["$ny_10th_yishu1"] = "既已失之东隅，万不可再阙之桑榆。",
    ["$ny_10th_yishu2"] = "姻缘如线，愿易外物得系君在之彼。",
    ["$ny_10th_ligong1"] = "锦衣玉食可离，海誓山盟不移！",
    ["$ny_10th_ligong2"] = "宁泊江湖之远，不栖庙堂之高。",
    ["~ny_10th_quanhuijie"] = "为何你我未生于寻常百姓家？",

    --界群黄月英

    ["ny_10th_jxqunhuangyueying"] = "界群黄月英-十周年",
    ["&ny_10th_jxqunhuangyueying"] = "黄月英",
    ["#ny_10th_jxqunhuangyueying"] = "沄英沐鲤",
    ["designer:ny_10th_jxqunhuangyueying"] = "官方",
	["cv:ny_10th_jxqunhuangyueying"] = "官方",
	["illustrator:ny_10th_jxqunhuangyueying"] = "枭瞳",

    ["ny_10th_jiqiao"] = "机巧",
    [":ny_10th_jiqiao"] = "出牌阶段开始时，你可以弃置任意张牌，亮出牌堆顶的等量张牌，然后获得其中的非装备牌。你每以此法弃置一张装备牌，本次便多亮出一张牌。",
    ["@ny_10th_jiqiao"] = "你可以发动“机巧”弃置任意张牌",
    ["ny_10th_linglong"] = "玲珑",
    [":ny_10th_linglong"] = "锁定技，若你的装备区里没有：防具牌，你视为装备着【八卦阵】；坐骑牌，你的手牌上限+2；宝物牌，你视为拥有技能“奇才”；均满足，你使用的【杀】或普通锦囊牌不能被响应。",
    ["$ny_10th_linglong_noresponse"] = "%from 使用的 %card 因 %arg 的效果不可被响应",

    ["$ny_10th_jiqiao1"] = "手作木牛替青鸟，与君情牵九连环。",
    ["$ny_10th_jiqiao2"] = "愿提连弩射秋风，从此不寒五丈原。",
    ["$ny_10th_linglong1"] = "我知君心独向我，我心悦君君可知？",
    ["$ny_10th_linglong2"] = "相思红豆点绛唇，玲珑心思为君顾。",
    ["~ny_10th_jxqunhuangyueying"] = "身居隆中庐，望断五丈秋。",

    --张曼成

    ["ny_10th_zhangmancheng"] = "张曼成-十周年",
    ["&ny_10th_zhangmancheng"] = "张曼成",
    ["#ny_10th_zhangmancheng"] = "所欲无度",
    ["designer:ny_10th_zhangmancheng"] = "官方",
	["cv:ny_10th_zhangmancheng"] = "官方",
	["illustrator:ny_10th_zhangmancheng"] = "鬼画府",

    ["ny_10th_zhongji"] = "螽集",
    [":ny_10th_zhongji"] = "当你使用牌时，若你没有与此牌花色相同的手牌且你的手牌数小于体力上限，你可以将手牌摸至体力上限，然后弃置X张牌（X为你本回合发动此技能的次数）。",
    ["ny_10th_zhongji:draw"] = "你可以发动“螽集”摸%src张牌并弃置%arg张牌",
    ["ny_10th_lvecheng"] = "掠城",
    [":ny_10th_lvecheng"] = "出牌阶段限一次，你可以选择一名其他角色，你本回合对其使用当前手牌中的【杀】无次数限制。若如此做，回合结束时，该角色展示手牌：若其中有【杀】，其可选择对你依次使用手牌中所有的【杀】。",
    ["ny_10th_lvecheng:use"] = "你可以对 %src 使用手牌中所有的【杀】",

    ["$ny_10th_zhongji1"] = "椿木不病而不生螟蛾，尔等岂能罪我？",
    ["$ny_10th_zhongji2"] = "朱紫视吾为蝼蚁，其可知蝼蚁之怒乎？",
    ["$ny_10th_lvecheng1"] = "乡野匹夫杀万户之城，前者快、后者哀！",
    ["$ny_10th_lvecheng2"] = "以无生之志击有业之家，自当无往不利！",
    ["~ny_10th_zhangmancheng"] = "青天死而不僵，我等徒做伥鬼。",

    --卢弈

    ["ny_10th_luyi"] = "卢弈-十周年",
    ["&ny_10th_luyi"] = "卢弈",
    ["#ny_10th_luyi"] = "瑶颜如玉",
    ["designer:ny_10th_luyi"] = "官方",
	["cv:ny_10th_luyi"] = "官方",
	["illustrator:ny_10th_luyi"] = "木美人",

    ["ny_10th_yaoyi"] = "邀弈",
    [":ny_10th_yaoyi"] = "锁定技，①游戏开始时，你令全场没有转换技的角色获得技能“手谈”（你发动“手谈”无需弃置牌且无次数限制）；\
    ②所有角色不能对除自己外转换技状态与自己相同的角色使用牌。",
    ["ny_10th_shoutan"] = "手谈",
    [":ny_10th_shoutan"] = "转换技，出牌阶段限一次，\
    阳：你可以弃置一张非黑色手牌；\
    阴：你可以弃置一张黑色手牌。",
    [":ny_10th_shoutan1"] = "转换技，出牌阶段限一次，\
    阳：你可以弃置一张非黑色手牌；\
    <font color=\"#01A5AF\"><s>阴：你可以弃置一张黑色手牌。</s></font>",
    [":ny_10th_shoutan2"] = "转换技，出牌阶段限一次，\
    <font color=\"#01A5AF\"><s>阳：你可以弃置一张非黑色手牌；</s></font>\
    阴：你可以弃置一张黑色手牌。",
    ["ny_tenth_fuxue"] = "复学",
    [":ny_tenth_fuxue"] = "准备阶段，你可以选择并获得弃牌堆中的至多X张不因使用而置入的牌;\
    结束阶段，若你的手牌中没有以此法获得的牌，你摸X张牌。（X为你的体力值）",
    ["@ny_tenth_fuxue"] = "你可以从弃牌堆中获得 %src 张不因使用而置入的牌",
    ["ny_tenth_fuxue:draw"] = "你可以发动“复学”摸 %src 张牌",
    ["#ny_tenth_fuxue"] = "复学",

    ["$ny_10th_yaoyi1"] = "拈花为棋问风月，仙翁散子胜负分。",
    ["$ny_10th_yaoyi2"] = "人生百年若棋局，落子无悔叹烂柯。",
    ["$ny_10th_shoutan1"] = "落子宫商角徵羽，无言春夏与秋冬。",
    ["$ny_10th_shoutan2"] = "掌中藏春风秋月，可以落子而言之。",
    ["$ny_tenth_fuxue1"] = "君看上谷方寸地，犹有寒梅傲雪中！",
    ["$ny_tenth_fuxue2"] = "三九霜寒卷江北，书生零落徙野陌。",
    ["~ny_10th_luyi"] = "落子棋局终，惊鸿留归羽。",

    --星曹仁

    ["ny_10th_xingcaoren"] = "星曹仁-十周年",
    ["&ny_10th_xingcaoren"] = "曹仁",
    ["#ny_10th_xingcaoren"] = "伏波四方",
    ["designer:ny_10th_xingcaoren"] = "官方",
	["cv:ny_10th_xingcaoren"] = "官方",
	["illustrator:ny_10th_xingcaoren"] = "游卡桌游",

    ["ny_10th_sujun"] = "肃军",
    [":ny_10th_sujun"] = "当你使用一张牌时，若你手牌中基本牌与非基本牌的数量相等，你可以摸两张牌。",
    ["ny_10th_sujun:draw"] = "你可以发动“肃军”摸两张牌",
    ["ny_10th_lifeng"] = "砺锋",
    [":ny_10th_lifeng"] = "你可将一张本回合未使用过的颜色的手牌当不计次数的【杀】或【无懈可击】使用。",

    ["$ny_10th_sujun1"] = "将为军魂，需以身作则。",
    ["$ny_10th_sujun2"] = "整肃三军，可御虎贲。",
    ["$ny_10th_lifeng1"] = "锋出百砺，健卒亦如是。",
    ["$ny_10th_lifeng2"] = "强军者，必校之以三九，炼之三伏。",
    ["~ny_10th_xingcaoren"] = "濡须之败，此生之耻。",

    --界张松

    ["ny_10th_jiezhangsong"] = "界张松-十周年",
    ["&ny_10th_jiezhangsong"] = "张松",
    ["#ny_10th_jiezhangsong"] = "献州投诚",
    ["designer:ny_10th_jiezhangsong"] = "官方",
	["cv:ny_10th_jiezhangsong"] = "官方",
	["illustrator:ny_10th_jiezhangsong"] = "枭瞳",

    ["ny_10th_jxxiantu"] = "献图",
    [":ny_10th_jxxiantu"] = "其他角色的出牌阶段开始时，你可以摸两张牌，然后将两张牌交给该角色，若如此做，此阶段结束时，若其于此阶段内没有造成过伤害，你失去1点体力。",
    ["ny_10th_jxxiantu:draw"] = "你可以发动“献图”摸两张牌并交给 %src 两张牌",
    ["@ny_10th_jxxiantu"] = "请交给 %src 两张牌",
    ["ny_10th_jxqiangzhi"] = "强识",
    [":ny_10th_jxqiangzhi"] = "出牌阶段开始时，你可以展示一名其他角色的一张手牌，若如此做，每当你于此阶段内使用与之类别相同的牌时，你可以摸一张牌。",
    ["@ny_10th_jxqiangzhi"] = "你可以发动“强识”展示一名其他角色的一张手牌",

    ["$ny_10th_jxxiantu1"] = "宝地当能者居之，愿为将军引路入川！",
    ["$ny_10th_jxxiantu2"] = "此图献与吾主，鼎立大业可期！",
    ["$ny_10th_jxqiangzhi1"] = "目略韦编三百卷，成竹在胸一瞬间！",
    ["$ny_10th_jxqiangzhi2"] = "蜀川千里之地，尽在吾胸腹之中！",
    ["~ny_10th_jiezhangsong"] = "纵万死，亦当献图于明主！",

    --曹纯

    ["ny_10th_caochun"] = "曹纯-十周年",
    ["&ny_10th_caochun"] = "曹纯",
    ["#ny_10th_caochun"] = "虎啸龙渊",
    ["designer:ny_10th_caochun"] = "官方",
	["cv:ny_10th_caochun"] = "官方",
	["illustrator:ny_10th_caochun"] = "凡果",

    ["ny_tenth_shanjia"] = "缮甲",
    [":ny_tenth_shanjia"] = "出牌阶段开始时，你可以摸三张牌，然后弃置X张牌（X为3减去你于本局游戏内不因使用装备牌而失去过装备牌的数量）。若你以此法弃置的牌中没有：基本牌，你本阶段使用【杀】的次数上限+1；锦囊牌，你本阶段使用牌无距离限制；两项均满足，你可以视为使用一张不计入次数的【杀】。",
    ["ny_tenth_shanjia:draw"] = "你可以发动“缮甲”摸3张牌然后弃置 %src 张牌",
    ["@ny_tenth_shanjia"] = "你可以视为使用了一张【杀】",

    ["$ny_tenth_shanjia1"] = "激水漂石，鸷鸟毁折，势如彍弩，勇而不乱。",
    ["$ny_tenth_shanjia2"] = "破军罢马，丢盔失甲，疲兵残阵，何以御我？",
    ["~ny_10th_caochun"] = "我有如此之势，不可能输！",

    --刘晔第二版

    ["ny_10th_liuye"] = "刘晔第二版-十周年",
    ["&ny_10th_liuye"] = "刘晔",
    ["#ny_10th_liuye"] = "石破天惊",
    ["designer:ny_10th_liuye"] = "官方",
	["cv:ny_10th_liuye"] = "官方",
	["illustrator:ny_10th_liuye"] = "小新",

    ["ny_10th_poyuan"] = "破垣",
    [":ny_10th_poyuan"] = "游戏开始时或回合开始时，若你的装备区内没有【霹雳车】，你可以将【霹雳车】置于你的装备区；若你的装备区内有【霹雳车】，你可以弃置一名其他角色的至多两张牌。",
    ["ny_10th_poyuan:put"] = "你可以发动“破垣”将【霹雳车】置入装备区",
    ["@@ny_10th_poyuan"] = "你可以发动“破垣”弃置一名其他角色的至多两张牌",
    ["$ny_10th_poyuan_get"] = "%from 发动 %arg 将 %card 置入了装备区",
    ["ny_10th_poyuan_dis"] = "请选择要弃置的牌数",
    ["_ny_tenth_piliche"] = "霹雳车",
    ["ny_tenth_piliche"] = "霹雳车",
    ["ny_10th_liuye_card"] = "刘晔专属",
    [":_ny_tenth_piliche"] = "装备牌·宝物<br /><b>装备效果</b>：你于回合内使用基本牌造成的伤害或回复+1且无距离限制，你于回合外使用或打出基本牌时摸1张牌。\
    此牌离开你的装备区时销毁。",
    ["$ny_tenth_piliche_damage"] = "%from 使用 %card 造成的伤害因 %arg 的效果由 %arg2 点增加到了 %arg3 点",
    ["$ny_tenth_piliche_recover"] = "%from 使用 %card 的治疗量因 %arg 的效果由 %arg2 点增加到了 %arg3 点",
    ["ny_10th_huace"] = "画策",
    [":ny_10th_huace"] = "出牌阶段限一次，你可以将一张手牌当作上一轮没有角色使用过的普通锦囊牌使用。",

    ["$ny_10th_poyuan1"] = "霹雳车下，金刚城郭如土城泥垣。",
    ["$ny_10th_poyuan2"] = "纵有坚城壁垒，吾亦视之如草芥。",
    ["$ny_10th_huace1"] = "公孙氏世权日久，今若不诛，后必生患。",
    ["$ny_10th_huace2"] = "先其不意，以兵临之，开设赏募，可不劳师而定也。",
    ["~ny_10th_liuye"] = "有策而不用，致使丧师辱国，奈何、奈何！",

    --张瑾云第二版

    ["ny_10th_zhangjinyun"] = "张瑾云第二版-十周年",
    ["&ny_10th_zhangjinyun"] = "张瑾云",
    ["#ny_10th_zhangjinyun"] = "暖枫袅袅",
    ["designer:ny_10th_zhangjinyun"] = "官方",
	["cv:ny_10th_zhangjinyun"] = "官方",
	["illustrator:ny_10th_zhangjinyun"] = "阿敦",

    ["ny_10th_huizhi"] = "蕙质",
    [":ny_10th_huizhi"] = "准备阶段，你可以弃置任意张手牌，然后将手牌摸至与全场手牌最多的角色相同。（最少摸一张，最多摸五张）",
    ["@ny_10th_huizhi"] = "你可以弃置任意张手牌，然后将手牌摸至与全场手牌最多的角色相同",
    ["ny_10th_jijiao"] = "继椒",
    [":ny_10th_jijiao"] = "限定技，出牌阶段，你可以令一名角色获得弃牌堆中你本局游戏内使用和弃置的全部普通锦囊牌（这些牌不能被【无懈可击】响应）。每个回合结束时，若本回合内牌堆洗切过或有角色死亡，此技能视为未发动过。",
    ["$ny_10th_jijiao_renew"] = "%from 的 %arg 被重置",
    ["$ny_10th_jijiao_nooffset"] = "%from 使用的 %card 因 %arg 的效果无法被【无懈可击】响应",

    ["$ny_10th_huizhi1"] = "妾视君为天地，愿将一腔心血作春雨泽润四方。",
    ["$ny_10th_huizhi2"] = "书中多绮丽，书外亦如是，谁可识陛下锦绣？",
    ["$ny_10th_jijiao1"] = "凤冠妆霞帔，一曰荣、二曰任，妾当承其重。",
    ["$ny_10th_jijiao2"] = "吾父效桃园之义，吾姊守贞良之节，妾幸继之。",
    ["~ny_10th_zhangjinyun"] = "今日离故土，何日不思蜀？",

    --陈式

    ["ny_10th_chenshi"] = "陈式-十周年",
    ["&ny_10th_chenshi"] = "陈式",
    ["#ny_10th_chenshi"] = "裨将可期",
    ["designer:ny_10th_chenshi"] = "官方",
	["cv:ny_10th_chenshi"] = "官方",
	["illustrator:ny_10th_chenshi"] = "游漫美绘",

    ["ny_10th_qingbei"] = "擎北",
    [":ny_10th_qingbei"] = "每轮开始时，你选择任意种花色令你于本轮无法使用，然后本轮你使用一张手牌后，摸本轮“擎北”选择过的花色数的牌。",
    ["$ny_10th_qingbei_chosen1"] = "%from 发动 %arg 选择了 %arg2",
    ["$ny_10th_qingbei_chosen2"] = "%from 发动 %arg 选择了 %arg2,%arg3",
    ["$ny_10th_qingbei_chosen3"] = "%from 发动 %arg 选择了 %arg2,%arg3,%arg4",
    ["$ny_10th_qingbei_chosen4"] = "%from 发动 %arg 选择了 %arg2,%arg3,%arg4,%arg5",

    ["$ny_10th_qingbei1"] = "待追上那司马懿，定教他没好果子吃！",
    ["$ny_10th_qingbei2"] = "身若不周，吾一人可作擎北之柱。",
    ["~ny_10th_chenshi"] = "丞相、丞相！是魏延指使我的！",

    --阮籍

    ["ny_10th_ruanji"] = "阮籍-十周年",
    ["&ny_10th_ruanji"] = "阮籍",
    ["#ny_10th_ruanji"] = "浣溪濯涟",
    ["designer:ny_10th_ruanji"] = "官方",
	["cv:ny_10th_ruanji"] = "官方",
	["illustrator:ny_10th_ruanji"] = "奶老板",

    ["ny_10th_jiudun"] = "酒遁",
    [":ny_10th_jiudun"] = "①你使用的【酒】的效果不会因回合结束而消失；\
    ②当你成为其他角色使用黑色牌的目标后，若你不处于【酒】的状态，则你可以摸一张牌并视为使用一张不计入次数限制的【酒】，否则你可以弃置一张手牌令此牌对你无效。",
    ["ny_10th_jiudun:draw"] = "你可以发动“酒遁”摸一张牌并视为使用一张不计入次数限制的【酒】",
    ["@ny_10th_jiudun"] = "你可以发动“酒遁”弃置一张手牌令【%src】对你无效",
    ["ny_10th_zhaowen"] = "昭文",
    [":ny_10th_zhaowen"] = "出牌阶段开始时，你可以展示所有手牌。若如此做，你本回合：可以将其中的黑色牌当任意一张普通锦囊牌使用（每种牌名每回合限一次）；使用其中的红色牌时摸一张牌。",
    ["ny_10th_zhaowen:show"] = "你可以发动“昭文”展示所有手牌",

    ["$ny_10th_jiudun1"] = "世间百味寡淡，唯酒可嗅二三。",
    ["$ny_10th_jiudun2"] = "我有一觞佳酿，欲宴天地同醉。",
    ["$ny_10th_zhaowen1"] = "登临山水，经日忘归，醉自然之乐。",
    ["$ny_10th_zhaowen2"] = "谈玄析理，论道以儒，真名士风流。",
    ["~ny_10th_ruanji"] = "大醉离殇，不知所云。",

    --刘徽

    ["ny_10th_liuhui"] = "刘徽-十周年",
    ["&ny_10th_liuhui"] = "刘徽",
    ["#ny_10th_liuhui"] = "周天古率",
    ["designer:ny_10th_liuhui"] = "官方",
	["cv:ny_10th_liuhui"] = "官方",
	["illustrator:ny_10th_liuhui"] = "凡果",

    ["ny_10th_geyuan"] = "割圆",
    [":ny_10th_geyuan"] = "锁定技，游戏开始时，将A~K的所有点数随机排列成一个圆环：\
    1.当一张或多张牌置入弃牌堆时，记录其中满足圆环进度的点数；\
    2.当圆环的点数均被记录后，你获得牌堆中与场上所有此圆环最初和最后记录的点数的牌，然后从圆环中移除这两个点数，重新开始圆环点数的记录。",
    ["ny_10th_geyuan_last"] = "圆环剩余",
    ["ny_10th_geyuan_head"] = "圆环首",
    ["ny_10th_geyuan_tail"] = "圆环尾",
    ["ny_10th_jieshu"] = "解术",
    [":ny_10th_jieshu"] = "锁定技，①圆环中被移除的点数的牌不计入你的手牌上限；\
    ②当你使用或打出一张牌时，若此牌满足圆环进度点数，你摸一张牌。",
    ["ny_10th_gusuan"] = "股算",
    [":ny_10th_gusuan"] = "觉醒技，一名角色的回合结束时，若圆环剩余点数为3个，你减1点体力上限，并将“割圆”的最后部分修改为：\
    •当圆环的点数均被记录后，你依次选择至多三名角色。你选择的第一名角色摸三张牌，第二名角色弃置四张牌，第三名角色用所有手牌替换牌堆底的五张牌。全部结算结束后，重新开始圆环点数的记录。",
    ["ny_10th_gusuan_draw"] = "你可以令一名角色摸三张牌",
    ["ny_10th_gusuan_discard"] = "你可以令一名角色弃置四张牌",
    ["ny_10th_gusuan_change"] = "你可以令一名角色用所有手牌替换牌堆底的五张牌",

    ["$ny_10th_geyuan1"] = "绘同径之矩，置内圆而割之。",
    ["$ny_10th_geyuan2"] = "矩割弥细，圆失弥少，以至不可割。",
    ["$ny_10th_jieshu1"] = "累乘除以成九数者，可以加减解之。",
    ["$ny_10th_jieshu2"] = "数有其理，见筹一可知沙数。",
    ["$ny_10th_gusuan1"] = "幻中容横，股中容直，可知其玄五。",
    ["$ny_10th_gusuan2"] = "累矩连索，类推衍化，开立而得法。",
    ["~ny_10th_liuhui"] = "算学如海，穷我一生，只得杯水。",

    --苏飞

    ["ny_10th_sufei"] = "苏飞-十周年",
    ["&ny_10th_sufei"] = "苏飞",
    ["#ny_10th_sufei"] = "遏浪惊涛",
    ["designer:ny_10th_sufei"] = "官方",
	["cv:ny_10th_sufei"] = "官方",
	["illustrator:ny_10th_sufei"] = "SHEO",

    ["ny_tenth_shujian"] = "数荐",
    [":ny_tenth_shujian"] = "出牌阶段限三次，你可以交给一名其他角色一张牌，令其选择一项：1.令你摸3张牌并弃置2张牌；2.视为使用3张【过河拆桥】且你本回合不能再发动此技能。选择完成后，本阶段中此技能中的数字-1。",
    ["ny_tenth_shujian:draw"] = "令其摸%src张牌并弃置%arg张牌",
    ["ny_tenth_shujian:dis"] = "视为使用了%src张【过河拆桥】",
    ["@ny_tenth_shujian"] = "你可以视为使用了一张【过河拆桥】（第%src张，共%arg张）",

    ["$ny_tenth_shujian1"] = "君蕴大才，可为万夫之长，焉居庸人之下。",
    ["$ny_tenth_shujian2"] = "日月逾迈，人生几何，卿宜远图，或可遇知己。",
    ["~ny_10th_sufei"] = "彼时各为其主，焉存苟利之心。",

    --吴班

    ["ny_10th_wuban"] = "吴班-十周年",
    ["&ny_10th_wuban"] = "吴班",
    ["#ny_10th_wuban"] = "酣琼畅怀",
    ["designer:ny_10th_wuban"] = "官方",
	["cv:ny_10th_wuban"] = "官方",
	["illustrator:ny_10th_wuban"] = "吕金宝",

    ["ny_10th_youzhan"] = "诱战",
    [":ny_10th_youzhan"] = "锁定技，其他角色在你的回合失去牌后，你摸一张牌且此牌本回合不计手牌上限，其本回合下次受到伤害+1。结束阶段，若该角色本回合未受伤，其摸X张牌（X为其本回合失去的牌的次数且最多为3）。",
    ["$ny_10th_youzhan_damage"] = "%from 受到的伤害因 %arg 的效果由 %arg2 点增加到了 %arg3 点",

    ["$ny_10th_youzhan1"] = "吠！尔等之胆略尚不如蜀地小儿。",
    ["$ny_10th_youzhan2"] = "我等引兵叫阵，魏狗必衔尾而来。",
    ["~ny_10th_wuban"] = "前负先主，后愧丞相。",

    --关宁

    ["ny_10th_guannin"] = "关宁-十周年",
    ["&ny_10th_guannin"] = "关宁",
    ["#ny_10th_guannin"] = "荫福泽远",
    ["designer:ny_10th_guannin"] = "官方",
	["cv:ny_10th_guannin"] = "官方",
	["illustrator:ny_10th_guannin"] = "匠人绘",

    ["ny_tenth_xiuwen"] = "修文",
    [":ny_tenth_xiuwen"] = "当你使用一张牌时，你可以摸一张牌（每种牌名每局游戏限一次）。",
    ["ny_tenth_xiuwen:draw"] = "你可以发动“修文”摸一张牌",
    ["ny_tenth_longsong"] = "龙诵",
    [":ny_tenth_longsong"] = "出牌阶段开始时，你可以交给一名其他角色一张红色牌，然后你本阶段视为拥有该角色的“出牌阶段”的技能直到你发动之。\
    <font color=\"red\"><b>有的时候可能发动后不会失去，属正常bug，不用报给作者，修不了谢谢！！！</b></font>",
    ["@ny_tenth_longsong"] = "你可以交给一名其他角色一张红色牌，然后你本阶段视为拥有该角色的“出牌阶段”的技能直到你发动之。",

    ["$ny_tenth_xiuwen1"] = "关氏之大义，其皆在武夫之身乎？",
    ["$ny_tenth_xiuwen2"] = "习武可杀千人，然修文可庇万民。",
    ["$ny_tenth_longsong1"] = "满朝朱紫聒噪，尔等皆忘关氏之声乎？",
    ["$ny_tenth_longsong2"] = "青龙偃月啸沙场，其有后人唳朝堂。",
    ["~ny_10th_guannin"] = "死时方知，百无一用是书生。",

    --孙桓

    ["ny_10th_sunhuan"] = "孙桓-十周年",
    ["&ny_10th_sunhuan"] = "孙桓",
    ["#ny_10th_sunhuan"] = "威凛沙场",
    ["designer:ny_10th_sunhuan"] = "官方",
	["cv:ny_10th_sunhuan"] = "官方",
	["illustrator:ny_10th_sunhuan"] = "君桓文化",

    ["ny_tenth_niji"] = "逆击",
    [":ny_tenth_niji"] = "当你成为基本牌或锦囊牌的目标后，你可以摸一张牌；\
    一名角色的结束阶段，你弃置本回合以此法摸的所有牌。（你可以先使用其中一张牌）",
    ["ny_tenth_niji:draw"] = "你可以发动“逆击”摸一张牌",
    ["@ny_tenth_niji"] = "你可以使用一张本回合因“逆击”获得的牌",

    ["$ny_tenth_niji1"] = "将者临战，谋先定而后动兵戈。",
    ["$ny_tenth_niji2"] = "沙场交兵，先击未中者命悬矣。",
    ["~ny_10th_sunhuan"] = "烈马迷山径，少年白发生。",

    --贾充

    ["ny_10th_jiachong"] = "贾充-十周年",
    ["&ny_10th_jiachong"] = "贾充",
    ["#ny_10th_jiachong"] = "妄锋斩龙",
    ["designer:ny_10th_jiachong"] = "官方",
	["cv:ny_10th_jiachong"] = "官方",
	["illustrator:ny_10th_jiachong"] = "鬼画府",

    ["ny_10th_beini"] = "悖逆",
    [":ny_10th_beini"] = "出牌阶段限一次，你可以将手牌摸至或弃置至体力上限，选择两名角色，令这两名角色本回合非锁定技失效，然后令一名角色对另一名角色使用一张【杀】。",
    ["ny_10th_beini_slash"] = "悖逆",
    ["ny_tenth_shizong"] = "恃纵",
    [":ny_tenth_shizong"] = "当你需要使用一张基本牌时，你可以交给一名其他角色X张牌（X为此技能本回合发动次数），其可以将一张牌置于牌堆底，然后你视为使用需要的基本牌。若其不为当前回合角色，此技能本回合失效。",
    ["ny_tenth_shizong_give"] = "请将 %src 张牌交给一名其他角色",
    ["@ny_tenth_shizong"] = "你可以将一张牌置于牌堆底，视为 %src 使用了一张 %arg",
    ["$ny_tenth_shizong_log"] = "%from 发动 %arg 声明要使用 【%arg2】",

    ["$ny_10th_beini1"] = "当日魏家文武欺山阳公甚，吾不过其二三矣。",
    ["$ny_10th_beini2"] = "晋公有伊尹、霍光之贤，何不取曹而代之？",
    ["$ny_tenth_shizong1"] = "衮衮诸公，得晋公之赏者，瞩我其谁？",
    ["$ny_tenth_shizong2"] = "恃宠而不骄者，其与锦衣夜行之徒何异。",
    ["~ny_10th_jiachong"] = "尔等皆知司马昭之心，何故怨我？",

    --董昭

    ["ny_10th_dongzhao"] = "董昭-十周年",
    ["&ny_10th_dongzhao"] = "董昭",
    ["#ny_10th_dongzhao"] = "谋谛先机",
    ["designer:ny_10th_dongzhao"] = "官方",
	["cv:ny_10th_dongzhao"] = "官方",
	["illustrator:ny_10th_dongzhao"] = "官方",

    ["ny_10th_yijia"] = "移驾",
    [":ny_10th_yijia"] = "当一名距离1以内的角色受到伤害后，你可以将场上的一张装备牌移至其装备区（可替换原装备）。若其因此脱离了一名角色的攻击范围，你摸一张牌。",
    ["@ny_10th_yijia"] = "你可以发动“移驾”将场上一张装备牌移动至 %src 装备区内",
    ["ny_tenth_dingji"] = "定基",
    [":ny_tenth_dingji"] = "准备阶段，你可以令一名角色将手牌调整至五张，然后其展示所有手牌，若牌名均不同，该角色可以视为使用其中的一张基本牌或普通锦囊牌。",
    ["ny_tenth_dingji_change"] = "你可以发动“定基”令一名角色将手牌调整至五张",
    ["@ny_tenth_dingji"] = "你可以视为使用手牌中的一张基本牌或普通锦囊牌",

    ["$ny_10th_yijia1"] = "放眼天下，邺居北而远，荆居南而鄙，唯许可赴。",
    ["$ny_10th_yijia2"] = "许者，言之午也，其当应陛下中兴之志。",
    ["$ny_tenth_dingji1"] = "公胜人臣之势，德美过于伊周，此万民之望也。",
    ["$ny_tenth_dingji2"] = "明公忠节颖露，天威在颜，当为千万人计！",
    ["~ny_10th_dongzhao"] = "魏武长逝，魏文溘然，此天罚也。",

    --马伶俐

    ["ny_10th_malingli"] = "马伶俐-十周年",
    ["&ny_10th_malingli"] = "马伶俐",
    ["#ny_10th_malingli"] = "星语灵犀",
    ["designer:ny_10th_malingli"] = "官方",
	["cv:ny_10th_malingli"] = "官方",
	["illustrator:ny_10th_malingli"] = "VE",

    ["ny_10th_lima"] = "骊马",
    [":ny_10th_lima"] = "锁定技，你计算与其他角色的距离-X（X为场上的坐骑牌数，至少为1）。",
    ["ny_tenth_xiaoyin"] = "硝引",
    ["#ny_tenth_xiaoyin"] = "硝引",
    [":ny_tenth_xiaoyin"] = "准备阶段，你可以亮出牌堆顶你距离1以内的角色数张牌，获得其中的红色牌，将其中任意张黑色牌置于等量名连续的其他角色武将牌上（当有“硝引”牌的角色受到伤害时，若此伤害为火焰伤害，则伤害来源可以移去一张“硝引”牌且弃置一张与此牌类别相同的牌并令此伤害+1，否则伤害来源可以获得一张“硝引”牌并将此伤害改为火焰伤害）。\
    <font color=\"red\"><b>有一定bug，但不修！！！</b></font>",
    ["ny_tenth_xiaoyin:show"] = "你可以发动“硝引”亮出牌堆顶的 %src 张牌",
    ["@ny_tenth_xiaoyin"] = "你可以将一张黑色牌置于其他角色武将牌上",
    ["$ny_tenth_xiaoyin_buff_add"] = "%from 对 %arg 造成的伤害因 %arg2 的效果由 %arg3 点增加到 %arg4 点",
    ["$ny_tenth_xiaoyin_buff_change"] = "%from 对 %arg 造成的伤害因 %arg2 的效果被改为 %arg3",
    ["ny_tenth_xiaoyin_add"] = "你可以移去一张“硝引”牌且弃置一张与此牌类别相同的牌并令你对 %src 造成的伤害+1",
    ["ny_tenth_xiaoyin_change"] = "你可以获得一张“硝引”牌并将你对 %src 造成的伤害改为火焰伤害",
    ["ny_tenth_huahuo"] = "花火",
    [":ny_tenth_huahuo"] = "出牌阶段限一次，你可以将一张红色手牌当不计入次数限制的火【杀】使用（若目标角色有“硝引”牌，你可以改为指定所有拥有“硝引”牌的角色为目标）。",
    ["ny_tenth_huahuo:change"] = "将目标改为所有拥有“硝引”牌的角色为目标",

    ["$ny_tenth_xiaoyin1"] = "爆竹似惊雷，春雷响，万物生。",
    ["$ny_tenth_xiaoyin2"] = "燃香灼硝引，掷爆竹于殿后，声声脆。",
    ["$ny_tenth_huahuo1"] = "心系故乡明月夜，花火摇曳耀星辰。",
    ["$ny_tenth_huahuo2"] = "烟花璀璨，火焰暖燃，乐趣无穷。",
    ["~ny_10th_malingli"] = "灿烂刹那，万籁俱寂。",

    --谢灵毓

    ["ny_10th_xielingyu"] = "谢灵毓-十周年",
    ["&ny_10th_xielingyu"] = "谢灵毓",
    ["#ny_10th_xielingyu"] = "淑静才媛",
    ["designer:ny_10th_xielingyu"] = "官方",
	["cv:ny_10th_xielingyu"] = "官方",
	["illustrator:ny_10th_xielingyu"] = "官方",

    ["ny_10th_yuandi"] = "元嫡",
    [":ny_10th_yuandi"] = "当其他角色于其出牌阶段使用第一张牌时，若此牌没有指定除其以外的角色为目标，你可以选择一项：1.弃置其一张手牌；2.令你与其各摸一张牌。",
    ["ny_10th_yuandi:draw"] = "与 %src 各摸一张牌",
    ["ny_10th_yuandi:discard"] = "弃置 %src 一张手牌",
    ["ny_10th_xinyou"] = "心幽",
    [":ny_10th_xinyou"] = "出牌阶段限一次，你可以回满体力并将手牌摸至体力上限。若你因此摸超过两张牌，结束阶段你失去１点体力；若你因此回复体力，结束阶段你弃置一张牌。",

    ["$ny_10th_yuandi1"] = "此生与君为好，共结连理。",
    ["$ny_10th_yuandi2"] = "结发元嫡，其情唯衷孙郎。",
    ["$ny_10th_xinyou1"] = "我有幽月一斛，可醉十里春风。",
    ["$ny_10th_xinyou2"] = "心在方外，故而不闻市井之声。",
    ["~ny_10th_xielingyu"] = "翠瓦红墙处，最折意中人。",

    --谋周瑜

    ["ny_10th_mouzhouyu"] = "谋周瑜-十周年",
    ["&ny_10th_mouzhouyu"] = "谋周瑜",
    ["#ny_10th_mouzhouyu"] = "江山如画",
    ["designer:ny_10th_mouzhouyu"] = "官方",
	["cv:ny_10th_mouzhouyu"] = "官方",
	["illustrator:ny_10th_mouzhouyu"] = "官方",

    ["ny_10th_ronghuo"] = "融火",
    [":ny_10th_ronghuo"] = "锁定技，你使用火【杀】或【火攻】造成的伤害改为X（X为全场势力数）。",
    ["$ny_10th_ronghuo_damage"] = "%from 对 %to 造成的伤害因 %arg 的效果由 %arg2 点改为 %arg3 点",
    ["ny_10th_yingmou"] = "英谋",
    [":ny_10th_yingmou"] = "转换技，每回合限一次，当你对其他角色使用牌后，你可以选择其中一名目标角色，\
    阳：你将手牌摸至与其相同（至多摸五张），然后视为对其使用一张【火攻】；\
    阴：你选择全场手牌数最多的另一名角色，若其手牌中有【杀】或伤害类锦囊牌，则其对该目标角色使用这些牌，否则其将手牌弃置至与你相同。",
    [":ny_10th_yingmou1"] = "转换技，每回合限一次，当你对其他角色使用牌后，你可以选择其中一名目标角色，\
    阳：你将手牌摸至与其相同（至多摸五张），然后视为对其使用一张【火攻】；\
    <font color=\"#01A5AF\"><s>阴：你选择全场手牌数最多的另一名角色，若其手牌中有【杀】或伤害类锦囊牌，则其对该目标角色使用这些牌，否则其将手牌弃置至与你相同。</s></font>",
    [":ny_10th_yingmou2"] = "转换技，每回合限一次，当你对其他角色使用牌后，你可以选择其中一名目标角色，\
    <font color=\"#01A5AF\"><s>阳：你将手牌摸至与其相同（至多摸五张），然后视为对其使用一张【火攻】；</s></font>\
    阴：你选择全场手牌数最多的另一名角色，若其手牌中有【杀】或伤害类锦囊牌，则其对该目标角色使用这些牌，否则其将手牌弃置至与你相同。",
    ["ny_10th_yingmou_first"] = "你可以视为对其中一名目标角色使用了【火攻】",
    ["ny_10th_yingmou_second_first"] = "你可以令全场手牌最多的角色对该角色使用手牌中的伤害类牌",
    ["ny_10th_yingmou_second_second"] = "请选择一名手牌最多的角色",
 
    ["$ny_10th_ronghuo1"] = "红莲生碧波，水火相融之际、吴钩刈将之时。",
    ["$ny_10th_ronghuo2"] = "千帆载丹鼎，万军为薪，一焚可引振翼之金乌。",
    ["$ny_10th_yingmou1"] = "年少立志三千里，会当击水，屈指问东风！",
    ["$ny_10th_yingmou2"] = "君子行陌路，振翅破樊笼，何妨天涯万里。",
    ["~ny_10th_mouzhouyu"] = "人生不如意事十之八九，如何不恨？",

    --孙綝

    ["ny_10th_sunchen"] = "孙綝-十周年",
    ["&ny_10th_sunchen"] = "孙綝",
    ["#ny_10th_sunchen"] = "凶竖盈溢",
    ["designer:ny_10th_sunchen"] = "官方",
	["cv:ny_10th_sunchen"] = "官方",
	["illustrator:ny_10th_sunchen"] = "官方",

    ["ny_10th_zuowei"] = "作威",
    [":ny_10th_zuowei"] = "当你于回合内使用牌时，若你的手牌数：大于X，你可以令此牌不能被响应；等于X，你可以对一名其他角色造成1点伤害；小于X，你可以摸两张牌且本回合不能再发动此项效果（X为你装备区里的牌数，至少为1）。",
    ["ny_10th_zuowei:noresponse"] = "你可以发动“作威”令【%src】不可响应",
    ["ny_10th_zuowei:draw"] = "你可以发动“作威”摸两张牌",
    ["@ny_10th_zuowei"] = "你可以发动“作威”对一名其他角色造成1点伤害",
    ["$ny_10th_zuowei_noresponse"] = "%from 使用的 %card 因 %arg 不可被响应",
    ["ny_10th_zigu"] = "自固",
    [":ny_10th_zigu"] = "出牌阶段限一次，你可以弃置一张牌，获得场上的一张装备牌。若你没有以此法获得其他角色的牌，你摸一张牌。",

    ["$ny_10th_zuowei1"] = "不顺我意者，当填在野之壑。",
    ["$ny_10th_zuowei2"] = "吾令不从者，当膏霜锋之锷。",
    ["$ny_10th_zigu1"] = "卿有成材良木，可妆吾家江山。",
    ["$ny_10th_zigu2"] = "吾好锦衣玉食，卿家可愿割爱否？",
    ["~ny_10th_sunchen"] = "臣家火起，请离席救之。",

    --双壁·孙策

    ["ny_10th_sunce_shuangbi"] = "双壁·孙策-十周年",
    ["&ny_10th_sunce_shuangbi"] = "孙策",
    ["#ny_10th_sunce_shuangbi"] = "江东小霸王",
    ["designer:ny_10th_sunce_shuangbi"] = "官方",
	["cv:ny_10th_sunce_shuangbi"] = "官方",
	["illustrator:ny_10th_sunce_shuangbi"] = "官方",

    ["ny_tenth_shuangbi"] = "双壁",
    [":ny_tenth_shuangbi"] = "出牌阶段限一次，你可以选择一名“周瑜”助战：\
    界周瑜：摸X张牌，本回合手牌上限+X；\
    神周瑜：弃置至多X张牌，随机造成等量火焰伤害；\
    谋周瑜：视为使用X张火【杀】或【火攻】。\
    X为存活人数。",
    ["ny_tenth_shuangbi:draw"] = "界周瑜：摸%src张牌，本回合手牌上限+%src",
    ["ny_tenth_shuangbi:damage"] = "神周瑜：弃置至多%src张牌，随机造成等量火焰伤害",
    ["ny_tenth_shuangbi:slash"] = "谋周瑜：视为使用%src张火【杀】或【火攻】",
    ["ny_tenth_shuangbi_discard"] = "你可以弃置至多%src张牌，然后随机造成等量火焰伤害",
    ["@ny_tenth_shuangbi"] = "请使用 【%src】",
    ["ny_tenth_shuangbi_mouzhouyu"] = "双壁·谋周瑜",

    ["$ny_tenth_shuangbi1"] = "有公瑾在，无后顾之忧。",
    ["$ny_tenth_shuangbi2"] = "公瑾良策，解我围困。",
    ["$ny_tenth_shuangbi3"] = "将相本无种，男儿当自强。",
    ["$ny_tenth_shuangbi4"] = "乱世出英杰，江东生异彩。",
    ["$ny_tenth_shuangbi5"] = "红莲业火，焚汝残躯。",
    ["$ny_tenth_shuangbi6"] = "神火天降，樯橹灰飞烟灭。",
    ["$ny_tenth_shuangbi7"] = "火莲绽江矶，炎映三千弱水。",
    ["$ny_tenth_shuangbi8"] = "奇志吞樯橹，潮平百万寇贼。",
    ["~ny_10th_sunce_shuangbi"] = "恕反复无常，岂可信。",

    --曹轶

    ["ny_10th_caoyi"] = "曹轶-十周年",
    ["&ny_10th_caoyi"] = "曹轶",
    ["#ny_10th_caoyi"] = "锦阑贺岁",
    ["designer:ny_10th_caoyi"] = "官方",
	["cv:ny_10th_caoyi"] = "官方",
	["illustrator:ny_10th_caoyi"] = "官方",
    ["ny_10th_caoyi_tiger"] = "曹轶的小老虎",
    ["&ny_10th_caoyi_tiger"] = "寅君",

    ["ny_10th_miyi"] = "蜜饴",
    [":ny_10th_miyi"] = "准备阶段，你可以选择一项并令任意名角色执行之：1.回复1点体力；2.受到1点你造成的伤害。若如此做，本回合的结束阶段，这些角色执行另一项。",
    ["ny_10th_miyi:recover"] = "回复1点体力",
    ["ny_10th_miyi:damage"] = "受到1点伤害",
    ["$ny_10th_miyi_chosen"] = "%from 发动 %arg 选择了 %arg2, 目标是 %to",
    ["@ny_10th_miyi"] = "你可以令任意名角色 %src",
    ["ny_10th_miyi_recover"] = "回复1点体力",
    ["ny_10th_miyi_damage"] = "受到1点伤害",
    ["$ny_10th_miyi_chosen"] = "%from 发动 %arg 选择了 %arg2, 目标是 %to",
    ["ny_10th_yinjun"] = "寅君",
    [":ny_10th_yinjun"] = "当你对其他角色使用手牌中唯一目标的【杀】或锦囊牌结算后，可以视为对其使用一张【杀】（此杀造成的伤害无来源）。若你此技能本回合发动次数大于你当前体力值，此技能本回合失效。",
    ["ny_10th_yinjun:slash"] = "你可以发动“寅君”令小老虎对 %src 使用一张【杀】",

    ["$ny_10th_miyi1"] = "粟脂享饧，万户曈曈日，满园春色千岁好。",
    ["$ny_10th_miyi2"] = "宴饴邀客，腾龙降瑞雪，一年新岁百日甜。",
    ["$ny_10th_yinjun1"] = "新桃绽锦符，元日群虎驱年兽，共收天下太平。",
    ["$ny_10th_yinjun2"] = "寅虎迎金龙，一夕落星雨，人间千树沐东风。",
    ["~ny_10th_caoyi"] = "合十乞星宿，愿君岁岁得平安。",

    --诸葛若雪

    ["ny_10th_zhugeruoxue"] = "诸葛若雪-十周年",
    ["&ny_10th_zhugeruoxue"] = "诸葛若雪",
    ["#ny_10th_zhugeruoxue"] = "玉榭霑露",
    ["designer:ny_10th_zhugeruoxue"] = "官方",
	["cv:ny_10th_zhugeruoxue"] = "官方",
	["illustrator:ny_10th_zhugeruoxue"] = "官方",

    ["ny_10th_qiongying"] = "琼英",
    [":ny_10th_qiongying"] = "出牌阶段限一次，你可以移动场上的一张牌，然后你弃置一张此花色的手牌，不能弃置则你展示所有手牌。",
    ["@ny_10th_qiongying"] = "请将 【%src】 移动给一名角色",
    ["ny_10th_qiongying_discard"] = "请弃置一张 %src 牌",
    ["ny_tenth_nuanhui"] = "暖惠",
    [":ny_tenth_nuanhui"] = "结束阶段，你可以选择一名角色，该角色可以视为使用X张基本牌（X为其装备区里的牌数）。若其以此法使用的牌数大于1，其弃置装备区里的所有牌。",
    ["ny_tenth_nuanhui_chosen"] = "你可以令一名角色可以视为使用X张基本牌（X为其装备区里的牌数）",
    ["@ny_tenth_nuanhui"] = "请使用 【%src】（当前第 %arg 张）",

    ["$ny_10th_qiongying1"] = "冰心碎玉壶，光转琼英灿。",
    ["$ny_10th_qiongying2"] = "玉心玲珑意，撷英倚西楼。",
    ["$ny_tenth_nuanhui1"] = "暖阳映雪，可照八九之风光。",
    ["$ny_tenth_nuanhui2"] = "晓风和畅，吹融附柳之霜雪。",
    ["~ny_10th_zhugeruoxue"] = "自古佳人叹白头。",

    --夏侯楙

    ["ny_10th_xiahoumao"] = "夏侯楙-十周年",
    ["&ny_10th_xiahoumao"] = "夏侯楙",
    ["#ny_10th_xiahoumao"] = "束甲之鸟",
    ["designer:ny_10th_xiahoumao"] = "官方",
	["cv:ny_10th_xiahoumao"] = "官方",
	["illustrator:ny_10th_xiahoumao"] = "官方",

    ["ny_10th_tongwei"] = "统围",
    [":ny_10th_tongwei"] = "出牌阶段限一次，你可以选择一名其他角色并重铸两张牌。当其下一次使用牌结算结束后，若此牌点数处于你这两张牌之间，你视为对其使用一张【杀】或【过河拆桥】。",
    ["ny_10th_cuguo"] = "蹙国",
    [":ny_10th_cuguo"] = "锁定技，当你每回合第一次使用牌被抵消后，你弃置一张牌，令此牌对目标角色再结算一次，然后若仍被抵消，你失去1点体力。",

    ["$ny_10th_tongwei1"] = "今统虎贲十万，必困金龙于斯。",
    ["$ny_10th_tongwei2"] = "昔年将军七出长坂，今尚能饭否？",
    ["$ny_10th_cuguo1"] = "本欲开疆拓土，奈何丧师辱国。",
    ["$ny_10th_cuguo2"] = "千里锦绣之地，皆亡逆贼之手。",
    ["~ny_10th_xiahoumao"] = "志大才疏，以致今日之祸。",
}
return packages