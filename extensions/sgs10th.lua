extension = sgs.Package("sgs10th", sgs.Package_GeneralPack)
local packages = {}
table.insert(packages, extension)

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
    waked_skills = "ny_10th_taji,ny_10th_qingny_10th_huang",
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
        room:setPlayerMark(source, "&ny_10th_huiling_ling", 0)
        room:acquireSkill(source, "ny_10th_taji", true)
        room:acquireSkill(source, "ny_10th_qingny_10th_huang", true)
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

            if player:getMark("&ny_10th_qingny_10th_huang-PlayClear") > 0 then
                room:sendCompulsoryTriggerLog(player, "ny_10th_qingny_10th_huang", true)
                local add = all[math.random(1,#all)]
                table.insert(now, add)

                local log = sgs.LogMessage()
                log.type = "$ny_10th_qingny_10th_huang_add"
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

ny_10th_qingny_10th_huang = sgs.CreateTriggerSkill{
    name = "ny_10th_qingny_10th_huang",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:getPhase() == sgs.Player_Play then
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("invoke")) then
                room:broadcastSkillInvoke(self:objectName())
                room:setPlayerMark(player, "&ny_10th_qingny_10th_huang-PlayClear", 1)
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
                local places = {}
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
                room:setPlayerFlag(damage.to, "-mobilepojun_InTempMoving")

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

local skills = sgs.SkillList()

if not sgs.Sanguosha:getSkill("ny_10th_jiaoxia_filter") then skills:append(ny_10th_jiaoxia_filter) end
if not sgs.Sanguosha:getSkill("ny_10th_taji") then skills:append(ny_10th_taji) end
if not sgs.Sanguosha:getSkill("ny_10th_qingny_10th_huang") then skills:append(ny_10th_qingny_10th_huang) end
if not sgs.Sanguosha:getSkill("ny_tenth_dagongche_slash") then skills:append(ny_tenth_dagongche_slash) end
if not sgs.Sanguosha:getSkill("ny_tenth_dagongche_slashtr") then skills:append(ny_tenth_dagongche_slashtr) end
if not sgs.Sanguosha:getSkill("ny_tenth_dagongche_destory") then skills:append(ny_tenth_dagongche_destory) end
if not sgs.Sanguosha:getSkill("ny_tenth_dagongche_buff") then skills:append(ny_tenth_dagongche_buff) end
if not sgs.Sanguosha:getSkill("ny_10th_paiyi") then skills:append(ny_10th_paiyi) end

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
    ["$ny_10th_qingny_10th_huang_add"] = "“清荒”为 %from 增加的额外效果为 %arg",
    ["$ny_10th_taji_damage"] = "%from 对 %to 造成的伤害因 %arg 由 %arg2 点增加到 %arg3 点",
    ["ny_10th_taji:use"] = "弃置其他角色一张牌",
    ["ny_10th_taji:response"] = "摸一张牌",
    ["ny_10th_taji:discard"] = "回复1点体力",
    ["ny_10th_taji:other"] = "你下次对其他角色造成的伤害+1",
    ["ny_10th_qingny_10th_huang"] = "清荒",
    [":ny_10th_qingny_10th_huang"] = "出牌阶段开始时，你可以减1点体力上限，然后你此阶段失去牌时触发“踏寂”随机额外获得一种效果。",
    ["ny_10th_qingny_10th_huang:invoke"] = "你可以减1点体力上限，然后你此阶段失去牌时触发“踏寂”随机额外获得一种效果",

    ["$ny_10th_huiling1"] = "金丹坎离，太上忘夏，老君以何长生？",
	["$ny_10th_huiling2"] = "夏荷日长，暑气渐生，可采金乌入药。",
	["$ny_10th_chongxu1"] = "三伏暑气盛，若心静之，则不为扰之。",
	["$ny_10th_chongxu2"] = "我欲冲虚而去，效后羿挽弓，逐烈日于人间。",
    ["$ny_10th_taji1"] = "夏蝉鸣更寂，譬如仙途，只闻风雷。",
	["$ny_10th_taji2"] = "小荷落渊潭，碧波涤岸，一点心有灵犀。",
    ["$ny_10th_qingny_10th_huang1"] = "君不见三九之凋木，向来皆裹盎然之翠。",
	["$ny_10th_qingny_10th_huang2"] = "夏荷长于红壤，其历三伏而茁盈仓之谷。",
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
}
return packages