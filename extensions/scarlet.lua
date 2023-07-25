extension = sgs.Package("scarlet")
sgs.LoadTranslationTable {
    ["scarlet"] = "時語",
}

function RIGHT(self, player)
    if player and player:isAlive() and player:hasSkill(self:objectName()) then return true else return false end
end

s4_cloud_zhangliao = sgs.General(extension, "s4_cloud_zhangliao", "wei", 4, false, false, false, 3)


s4_cloud_tuxi = sgs.CreateTriggerSkill {
    name = "s4_cloud_tuxi",
    events = { sgs.EventPhaseStart, sgs.CardFinished },
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data, room)
        local room = player:getRoom()
        for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
            local dest = sgs.QVariant()
            dest:setValue(player)
            if p and p:objectName() ~= player:objectName() and room:askForSkillInvoke(p, self:objectName(), dest) then
                if room:askForDiscard(p, self:objectName(), 999, 1, true, true, "@s4_cloud_tuxi" .. player:objectName()) then
                else
                    local lose_num = {}
                    for i = 1, p:getHp() do
                        table.insert(lose_num, tostring(i))
                    end
                    local choice = room:askForChoice(p, "s4_cloud_tuxi", table.concat(lose_num, "+"))
                    room:loseHp(p, tonumber(choice))
                end
                if player:getHandcardNum() >= p:getHandcardNum() and not player:isKongcheng() then
                    local card_id = room:askForCardChosen(p, player, "h", self:objectName())
                    room:obtainCard(p, card_id)
                end
                if player:getEquips():length() >= p:getEquips():length() and p:canDiscard(player, "he") then
                    local card_id = room:askForCardChosen(p, player, "he", self:objectName())
                    room:throwCard(sgs.Sanguosha:getCard(card_id), player, p)
                end
                if player:getHp() >= p:getHp() then
                    p:gainHujia(1)
                    local damage = sgs.DamageStruct()
                    damage.from = p
                    damage.to = player
                    room:damage(damage)
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:getPhase() == sgs.Player_Play
    end
}


s4_cloud_yongqian = sgs.CreateTriggerSkill {
    name = "s4_cloud_yongqian",
    events = { sgs.DrawNCards, sgs.TargetConfirmed },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.DrawNCards and RIGHT(self, player) then
            local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(),
                "s4_cloud_yongqian-invoke", true, true)
            if target then
                local count = data:toInt()
                data:setValue(count - 1)
                room:setPlayerMark(player, self:objectName() .. target:objectName(), 1)
                room:addPlayerMark(target, "&" .. self:objectName() .. "+to+#" .. player:objectName())
                local assignee_list = player:property("extra_slash_specific_assignee"):toString():split("+")
                table.insert(assignee_list, target:objectName())
                room:setPlayerProperty(player, "extra_slash_specific_assignee",
                    sgs.QVariant(table.concat(assignee_list, "+")))
            end
        elseif event == sgs.TargetConfirmed then
            local use = data:toCardUse()
            if use.card and not use.card:isKindOf("SkillCard") then
                for _, p in sgs.qlist(use.to) do
                    if use.from and p:objectName() ~= use.from:objectName() and p:getMark(self:objectName() .. player:objectName()) > 0 and room:askForSkillInvoke(p, self:objectName()) then
                        p:drawCards(1)
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target
    end
}




s4_cloud_yongqianClear = sgs.CreateTriggerSkill {
    name = "#s4_cloud_yongqian-clear",
    events = { sgs.EventPhaseChanging },
    on_trigger = function(self, event, player, data, room)
        if event == sgs.EventPhaseChanging then
            if data:toPhaseChange().to == sgs.Player_Start then
                local assignee_list = player:property("extra_slash_specific_assignee"):toString():split("+")
                for _, p in sgs.qlist(room:getAllPlayers()) do
                    if player:getMark("s4_cloud_yongqian" .. p:objectName()) == 0 then continue end
                    table.removeOne(assignee_list, p:objectName())
                    room:setPlayerMark(player, "s4_cloud_yongqian" .. p:objectName(), 0)
                    room:setPlayerMark(p, "&s4_cloud_yongqian+to+#" .. player:objectName(), 0)
                end
                room:setPlayerProperty(player, "extra_slash_specific_assignee",
                    sgs.QVariant(table.concat(assignee_list, "+")))
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}

s4_cloud_zhangliao:addSkill(s4_cloud_tuxi)
s4_cloud_zhangliao:addSkill(s4_cloud_yongqian)
s4_cloud_zhangliao:addSkill(s4_cloud_yongqianClear)
extension:insertRelatedSkills("s4_cloud_yongqian", "#s4_cloud_yongqianClear")


sgs.LoadTranslationTable {
    ["s4_cloud_zhangliao"] = "张辽",
    ["&s4_cloud_zhangliao"] = "张辽",
    ["#s4_cloud_zhangliao"] = "威震江东",
    ["designer:s4_cloud_zhangliao"] = "",

    ["s4_cloud_tuxi"] = "突襲",
    [":s4_cloud_tuxi"] = "当一名其他角色出牌阶段开始时或当一名其他角色于其出牌阶段使用的一张牌结算结束后，你可以弃置至少一张牌或失去至少1点体力，然后若其手牌数不小于你，你获得其一张手牌；若其装备数不小于你，你弃置其一张牌；若其体力值不小于你，你获得1点护甲，对其造成1点伤害。",
    ["s4_cloud_yongqian"] = "勇前",
    [":s4_cloud_yongqian"] = "摸牌阶段，你可以少摸一张牌，然后选择一名其他角色，直到你下回合开始，你对其使用牌无距离和次数限制，当其使用牌指定你为目标后，你可以摸一张牌。",
}


s4_cloud_huangzhong = sgs.General(extension, "s4_cloud_huangzhong", "shu", 3, false)

s4_cloud_liegong = sgs.CreateTriggerSkill {
    name = "s4_cloud_liegong",
    events = { sgs.TargetConfirmed, sgs.DamageCaused },
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

s4_cloud_yongyiAttackRange = sgs.CreateAttackRangeSkill {
    name = "#s4_cloud_yongyiAttackRange",
    extra_func = function(self, target)
        local record = target:property("s4_cloud_yongyiRecords"):toString():split(",")
        local x = #record
        if record
        then
            return x
        end
    end,
}

s4_cloud_yongyiCard = sgs.CreateSkillCard {
    name = "s4_cloud_yongyi",
    handling_method = sgs.Card_MethodUse,
    filter = function(self, targets, to_select, player)
        local qtargets = sgs.PlayerList()
        for _, p in ipairs(targets) do
            qtargets:append(p)
        end
        if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
            local card, user_string = nil, self:getUserString()
            if user_string ~= "" then
                card = sgs.Sanguosha:cloneCard(user_string:split("+")[1])
                card:setSkillName("_s4_cloud_yongyi")
            end
            return card and card:targetFilter(qtargets, to_select, player) and
                not player:isProhibited(to_select, card, qtargets)
        end

        local card = sgs.Sanguosha:cloneCard("analeptic")
        card:setSkillName("_s4_cloud_yongyi")
        if card and card:targetFixed() then
            return card:isAvailable(player)
        end
        return card and card:targetFilter(qtargets, to_select, player) and
            not player:isProhibited(to_select, card, qtargets)
    end,
    feasible = function(self, targets, player)
        local card = sgs.Sanguosha:cloneCard("analeptic")
        if card then
            card:setSkillName("_s4_cloud_yongyi")
        end
        local qtargets = sgs.PlayerList()
        for _, p in ipairs(targets) do
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

s4_cloud_yongyiVS = sgs.CreateZeroCardViewAsSkill {
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
        return #player:property("s4_cloud_yongyiRecords"):toString():split(",") > 0 and
            player:getMark("s4_cloud_yongyi-Clear") == 0
    end,
    enabled_at_response = function(self, player, pattern)
        return #player:property("s4_cloud_yongyiRecords"):toString():split(",") > 0 and string.find(pattern, "analeptic") and
            player:getMark("s4_cloud_yongyi-Clear") == 0
    end
}

s4_cloud_yongyi = sgs.CreateTriggerSkill {
    name = "s4_cloud_yongyi",
    view_as_skill = s4_cloud_yongyiVS,
    events = { sgs.CardUsed, sgs.CardResponded, sgs.TargetConfirmed },
    on_trigger = function(self, event, player, data, room)
        if event == sgs.CardUsed then
            local card = nil
            if (event == sgs.CardUsed) then
                local use = data:toCardUse()
                card = use.card
            elseif (event == sgs.CardResponded) then
                local res = data:toCardResponse()
                if (not res.m_isUse) then return false end
                card = res.m_card
            elseif (event == sgs.TargetConfirmed) then
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
            for n, m in sgs.list(player:getMarkNames()) do
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
s4_cloud_huangzhong:addSkill(s4_cloud_liegong)
s4_cloud_huangzhong:addSkill(s4_cloud_yongyi)
s4_cloud_huangzhong:addSkill(s4_cloud_yongyiAttackRange)
extension:insertRelatedSkills("s4_cloud_yongyi", "#s4_cloud_yongyiAttackRange")
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



s4_txbw_disgeneralCard = sgs.CreateSkillCard{
    name = "s4_txbw_disgeneral",
    target_fixed = true,
    will_throw = false,
    on_use = function(self, room, source, targets)
        room:setPlayerMark(source, "@s4_txbw_general", 0)
    end,
}
s4_txbw_disgeneral = sgs.CreateViewAsSkill{
    name = "s4_txbw_disgeneral",
    n = 0,
    view_as = function(self, cards)
        if #cards == 0 then
            local card = s4_txbw_disgeneralCard:clone()
            return card
        end
    end,
    enabled_at_play = function(self, player)
        return player:getMark("@s4_txbw_general") > 0
    end,
}


s4_txbw_general = sgs.CreateTriggerSkill{
    name = "s4_txbw_general",
    global = true,
    frequency = sgs.Skill_NotFrequent,
    events = {sgs.GameStart, sgs.EventPhaseChanging},  
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.GameStart then
            for _,p in sgs.qlist(room:getAlivePlayers()) do
                if p:getMark("@s4_txbw_general") > 0 then
                    room:attachSkillToPlayer(p, "s4_txbw_disgeneral")
                    room:attachSkillToPlayer(p, "s4_txbw_general_duel")
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}


s4_txbw_general_duelCard = sgs.CreateSkillCard{
    name = "s4_txbw_general_duel",
    target_fixed = false,
    will_throw = false,
    filter = function(self, targets, to_select)
        if to_select:objectName() ~= sgs.Self:objectName()  then
            return #targets == 0
        end
        return false
    end,
    on_effect = function(self, effect)
        local source = effect.from
        local target = effect.to
        local room = source:getRoom()
        local msg = sgs.LogMessage()
        msg.type = "#s4_txbw_general_duel_start"
        msg.from = source
        msg.to:append(target)
        room:sendLog(msg)
        room:setPlayerFlag(target, "s4_txbw_general_duel_victim")
        room:setPlayerFlag(source, "s4_txbw_general_duel_start")
        if target:getMark("@s4_txbw_general") > 0 then
            if source:isKongcheng() then
                source:drawCards(2)
            else
                source:drawCards(1)
            end
        end
        if source:getMark("s4_txbw_general_duel_slash-Clear") == 0 then
            room:addPlayerMark(source, "s4_txbw_general_duel_slash-Clear")
            room:addPlayerHistory(source, "slash",1)
        end
    end,
}
s4_txbw_general_duel_chooseCard = sgs.CreateSkillCard{
    name = "s4_txbw_general_duel_choose",
    target_fixed = false,
    will_throw = false,
    filter = function(self, targets, to_select)
        if to_select:objectName() ~= sgs.Self:objectName() then
            return #targets == 0
        end
        return false
    end,
    on_effect = function(self, effect)
        local source = effect.from
        local target = effect.to
        local room = source:getRoom()
        local msg = sgs.LogMessage()
        msg.type = "#s4_txbw_general_duel_choose"
        msg.from = source
        msg.to:append(target)
        room:sendLog(msg)
       
        local card_s
        if source:isKongcheng() then
            card_s = room:drawCards(1)
        else
            card_s = room:askForCard(source, ".!", "s4_txbw_general_duel", sgs.QVariant(), sgs.Card_MethodNone,source,false,"s4_txbw_general_duel",true)
        end
        room:setTag("s4_txbw_general_duel_s", sgs.QVariant(card_s:getId()))
        if target:isKongcheng() then
            card_v = room:drawCards(1)
        else
            card_v = room:askForCard(target, ".!", "s4_txbw_general_duel", sgs.QVariant(), sgs.Card_MethodNone,source,false,"s4_txbw_general_duel",true)
        end
        room:setTag("s4_txbw_general_duel_v", sgs.QVariant(card_v:getId()))
    end,
}
s4_txbw_general_duel_showCard = sgs.CreateSkillCard{
    name = "s4_txbw_general_duel_show",
    target_fixed = false,
    will_throw = false,
    filter = function(self, targets, to_select)
        if to_select:objectName() ~= sgs.Self:objectName() then
            return #targets == 0
        end
        return false
    end,
    on_effect = function(self, effect)
        local source = effect.from
        local target = effect.to
        local room = source:getRoom()
        local msg = sgs.LogMessage()
        msg.type = "#s4_txbw_general_duel_show"
        msg.from = source
        msg.to:append(target)
        room:sendLog(msg)


        local card_s = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_s"):toInt())
        local card_v = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_v"):toInt())
        room:setPlayerMark(source, "s4_txbw_general_duel",card_s:getNumberString())
        room:setPlayerMark(target, "s4_txbw_general_duel",card_v:getNumberString())
        local msg1 = sgs.LogMessage()
        msg1.type = "#s4_txbw_general_duel_show_card"
        msg1.from = source
        msg1.arg = card_s:objectName()
        local msg2 = sgs.LogMessage()
        msg2.type = "#s4_txbw_general_duel_show_card"
        msg2.from = target
        msg2.arg = card_v:objectName()
        room:moveCardTo(card_s, source, nil, sgs.Player_DiscardPile,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RULEDISCARD, source:objectName(), "s4_txbw_general_duel", ""))
        room:moveCardTo(card_v, target, nil, sgs.Player_DiscardPile,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RULEDISCARD, target:objectName(), "s4_txbw_general_duel", ""))
   
    end,
}
s4_txbw_general_duel_calCard = sgs.CreateSkillCard{
    name = "s4_txbw_general_duel_cal",
    target_fixed = false,
    will_throw = false,
    filter = function(self, targets, to_select)
        if to_select:objectName() ~= sgs.Self:objectName() then
            return #targets == 0
        end
        return false
    end,
    on_effect = function(self, effect)
        local source = effect.from
        local target = effect.to
        local room = source:getRoom()
        local msg = sgs.LogMessage()
        msg.type = "#s4_txbw_general_duel_cal"
        msg.from = source
        msg.to:append(target)
        room:sendLog(msg)


        local start = source:getMark("s4_txbw_general_duel")
        local victim = target:getMark("s4_txbw_general_duel")
        local msg1 = sgs.LogMessage()
        msg1.type = "#s4_txbw_general_duel_cal_point"
        msg1.from = source
        msg1.arg = start
        local msg2 = sgs.LogMessage()
        msg2.type = "#s4_txbw_general_duel_cal_point"
        msg2.from = target
        msg2.arg = victim
    end,
}
s4_txbw_general_duel_resultCard = sgs.CreateSkillCard{
    name = "s4_txbw_general_duel_result",
    target_fixed = false,
    will_throw = false,
    filter = function(self, targets, to_select)
        if to_select:objectName() ~= sgs.Self:objectName() then
            return #targets == 0
        end
        return false
    end,
    on_effect = function(self, effect)
        local source = effect.from
        local target = effect.to
        local room = source:getRoom()
        local msg = sgs.LogMessage()
        msg.type = "#s4_txbw_general_duel_result"
        msg.from = source
        msg.to:append(target)
        room:sendLog(msg)


        local start = source:getMark("s4_txbw_general_duel")
        local victim = target:getMark("s4_txbw_general_duel")
        local msg1 = sgs.LogMessage()
        msg1.type = "#s4_txbw_general_duel_result_point"
        msg1.from = source
        msg1.arg = start
        local msg2 = sgs.LogMessage()
        msg2.type = "#s4_txbw_general_duel_result_point"
        msg2.from = target
        msg2.arg = victim
        local winner = sgs.QVariant()
        local loser = sgs.QVariant()
        local winCard
        if start > victim then
            winner:setValue(start)
            loser:setValue(victim)
            winCard = room:getTag("s4_txbw_general_duel_s"):toInt()
            local msg = sgs.LogMessage()
            msg.type = "#s4_txbw_general_duel_Success"
            msg.from = source
            msg.to:append(target)
            room:sendLog(msg)
            room:setEmotion(source, "success")
        elseif start < victim then
            winCard = room:getTag("s4_txbw_general_duel_v"):toInt()
            winner:setValue(victim)
            loser:setValue(start)
            local msg = sgs.LogMessage()
            msg.type = "#s4_txbw_general_duel_Success"
            msg.from = target
            msg.to:append(source)
            room:sendLog(msg)
            room:setEmotion(target, "success")
        end
        room:setTag("s4_txbw_general_duel_winner", winner)
        room:setTag("s4_txbw_general_duel_wincard", sgs.QVariant(winCard))
        room:setTag("s4_txbw_general_duel_loser", loser)
    end,
}
s4_txbw_general_duel_finishCard = sgs.CreateSkillCard{
    name = "s4_txbw_general_duel_finish",
    target_fixed = false,
    will_throw = false,
    filter = function(self, targets, to_select)
        if to_select:objectName() ~= sgs.Self:objectName() then
            return #targets == 0
        end
        return false
    end,
    on_effect = function(self, effect)
        local source = effect.from
        local target = effect.to
        local room = source:getRoom()
        local msg = sgs.LogMessage()
        msg.type = "#s4_txbw_general_duel_finish"
        msg.from = source
        msg.to:append(target)
        room:sendLog(msg)
        local winner = room:getTag("s4_txbw_general_duel_winner"):toPlayer()
        local loser = room:getTag("s4_txbw_general_duel_loser"):toPlayer()
        if winner and winner:isAlive() and loser and loser:isAlive() then
            local jink = room:askForCard(loser,"jink","@s4_txbw_general_duel-jink:"..winner:objectName(),sgs.QVariant(),sgs.Card_MethodResponse,nil,false,"",true)
            if jink then
            else
                local duel_damage = 1 + winner:getMark("s4_txbw_general_duel_damage") + winner:getMark("s4_txbw_general_duel_damage-Clear")
                local damage = sgs.DamageStruct()
                damage.card = nil
                damage.from = winner
                damage.to = loser
                damage.damage = duel_damage
                   
                local winCard = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_wincard"):toInt())
                if winCard:isKindOf("ThunderSlash") or  winCard:isKindOf("Lighting") then
                    damage.nature = sgs.DamageStruct_Thunder
                end
                if winCard:isKindOf("FireSlash") or  winCard:isKindOf("FireAttack") then
                    damage.nature = sgs.DamageStruct_Fire
                end
                room:damage(damage)
            end
           
        end
    end,
}


s4_txbw_general_duel = sgs.CreateViewAsSkill{
    name = "s4_txbw_general_duel",
    n = 0,
    view_as = function(self, cards)
        if #cards == 0 then
            local card = s4_txbw_general_duelCard:clone()
            card:setSkillName("s4_txbw_general_duel_start")
            return card
        end
    end,
    enabled_at_play = function(self, player)
        return player:getMark("@s4_txbw_general") > 0 and player:usedTimes("#s4_txbw_general_duel") < 1 + player:getMark("s4_txbw_general_duel_extra")
    end,
}


s4_txbw_general_duel_rule = sgs.CreateTriggerSkill{
    name = "s4_txbw_general_duel",
    global = true,
    frequency = sgs.Skill_NotFrequent,
    events = {sgs.CardFinished},  
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_start" then
                    local card = s4_txbw_general_duel_chooseCard:clone()
                    card:setSkillName("s4_txbw_general_duel_choose")
                    local use_ex = sgs.CardUseStruct()
                    use_ex.card = card
                    use_ex.from = player
                    use_ex.to = use.to
                    room:useCard(use_ex)
                elseif use.card:getSkillName() == "s4_txbw_general_duel_choose" then
                    local card = s4_txbw_general_duel_showCard:clone()
                    card:setSkillName("s4_txbw_general_duel_show")
                    local use_ex = sgs.CardUseStruct()
                    use_ex.card = card
                    use_ex.from = player
                    use_ex.to = use.to
                    room:useCard(use_ex)
                elseif use.card:getSkillName() == "s4_txbw_general_duel_show" then
                    local card = s4_txbw_general_duel_calCard:clone()
                    card:setSkillName("s4_txbw_general_duel_cal")
                    local use_ex = sgs.CardUseStruct()
                    use_ex.card = card
                    use_ex.from = player
                    use_ex.to = use.to
                    room:useCard(use_ex)
                elseif use.card:getSkillName() == "s4_txbw_general_duel_cal" then
                    local card = s4_txbw_general_duel_resultCard:clone()
                    card:setSkillName("s4_txbw_general_duel_result")
                    local use_ex = sgs.CardUseStruct()
                    use_ex.card = card
                    use_ex.from = player
                    use_ex.to = use.to
                    room:useCard(use_ex)
                elseif use.card:getSkillName() == "s4_txbw_general_duel_result" then
                    local card = s4_txbw_general_duel_finishCard:clone()
                    card:setSkillName("s4_txbw_general_duel_finish")
                    local use_ex = sgs.CardUseStruct()
                    use_ex.card = card
                    use_ex.from = player
                    use_ex.to = use.to
                    room:useCard(use_ex)
                elseif use.card:getSkillName() == "s4_txbw_general_duel_finish" then
                    room:setPlayerMark(use.from, "s4_txbw_general_duel", 0)
                    room:setPlayerMark(use.to:first(), "s4_txbw_general_duel", 0)
                    room:removeTag("s4_txbw_general_duel_s")
                    room:removeTag("s4_txbw_general_duel_v")
                    room:removeTag("s4_txbw_general_duel_winner")
                    room:removeTag("s4_txbw_general_duel_loser")
                    room:removeTag("s4_txbw_general_duel_wincard")
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}

sgs.LoadTranslationTable {
    ["@s4_txbw_general"] = "武将",
    ["s4_txbw_disgeneral"] = "弃武从文",
    [":s4_txbw_disgeneral"] = "出牌阶段，你可以移除武将标签。若如此做，你不再是武将，失去所有和对决相关的技能。",
    ["s4_txbw_general"] = "武将規則",
    ["s4_txbw_general_duel"] = "对决",
    [":s4_txbw_general_duel"] = "出牌阶段，你可以指定一名其他角色，发起对决。 \
    出牌阶段，\
    ①如果未发起对决，便不能使用【杀】。\
    ②如无特殊说明，发起对决的次数限制为1。\
    ③发起对决(无论多少次)会占用一次使用【杀】的次数。\
    双方各将一张手牌背面向上置于桌面。这张牌称为对决牌。\
    无手牌的角色改为将牌堆顶的一张牌作为对决牌扣置。\
    若A赢，B需使用一张【闪】，若B不如此做，受到A对其造成的1点对决伤害。\
    若A的对决牌为【火杀】【火攻】，该对决伤害为火属性。\
    若A的对决牌为【雷杀】【闪电】，该对决伤害为雷属性。",

    ["#s4_txbw_general_duel_start"] = "%from 向 %to 发起了对决",
    ["#s4_txbw_general_duel_choose"] = "%from 和 %to 扣置对决牌",
    ["#s4_txbw_general_duel_show"] = "%from 和 %to 亮出对决牌",
    ["#s4_txbw_general_duel_show_card"] = "%from 的对决牌为 %card ",
    ["#s4_txbw_general_duel_cal"] = "%from 和 %to 计算对决牌点数",
    ["#s4_txbw_general_duel_cal_point"] = "%from 的对决牌点数为 %arg ",
    ["#s4_txbw_general_duel_result"] = "%from 和 %to 判定对决胜负。",
    ["#s4_txbw_general_duel_result_point"] = "%from 的对决牌点数为 %arg ",
    ["#s4_txbw_general_duel_Success"] = "%from 在 %to 对决中获胜。",
    ["#s4_txbw_general_duel_finish"] = "%from 和 %to 执行对决胜利效果。",

    ["@s4_txbw_general_duel-jink"] = " %src 对决中获胜，你需使用一张【闪】，否则受到 %src 对你造成的1点对决伤害。",



}















function addWeiTerritoryPile(card, player, self)
    local room = player:getRoom()
    card = type(card) == "number" and sgs.Sanguosha:getCard(card) or card
    self = type(self) == "string" and self or self and self:objectName() or ""
    if card:getEffectiveId() < 0 then return end

    local WeiTerritoryPile = room:getTag("WeiTerritoryPile"):toString():split("+")
    if #WeiTerritoryPile >= 13 then
        local log = sgs.LogMessage()
        log.type = "$addWeiTerritoryPileFailture"
        log.from = player
        log.arg = "WeiTerritoryPile"
        local toids = {}
        local c = dummyCard()
        for _, id in sgs.list(card:getSubcards()) do
            table.insert(toids, id)
            c:addSubcard(id)
        end
        log.card_str = table.concat(toids, "+")
        room:sendLog(log)
        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, nil, nil,
            "addWeiTerritoryPileFailture", nil)
        room:throwCard(c, reason, nil)
        return
    end
    local log = sgs.LogMessage()
    log.type = "$addWeiTerritoryPile"
    log.from = player
    log.arg = "WeiTerritoryPile"
    local toids = {}
    local c = dummyCard()
    for _, id in sgs.list(card:getSubcards()) do
        table.insert(WeiTerritoryPile, id)
        table.insert(toids, id)
        c:addSubcard(id)
    end
    log.card_str = table.concat(toids, "+")
    room:sendLog(log)
    room:setTag("WeiTerritoryPile", sgs.QVariant(table.concat(WeiTerritoryPile, "+")))
    log = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECYCLE, player:objectName(), "", self, "addWeiTerritoryPile")
    room:moveCardTo(c, nil, sgs.Player_PlaceTable, log, true)
    WeiTerritoryPile = room:getTag("WeiTerritoryPile"):toString():split("+")
    for _, p in sgs.list(room:getAlivePlayers()) do
        if p:getMark("&WeiTerritoryPile") > 0
        then
            room:setPlayerMark(p, "&WeiTerritoryPile", #WeiTerritoryPile)
            return
        end
    end
    room:setPlayerMark(player, "&WeiTerritoryPile", #WeiTerritoryPile)
end

function getWeiTerritoryPile(player)
    local WeiTerritoryPile = player:getRoom():getTag("WeiTerritoryPile"):toString():split("+")
    local toid = sgs.IntList()
    for _, id in sgs.list(WeiTerritoryPile) do
        toid:append(id)
    end
    return toid
end

function gainWeiTerritoryPile(cards, player, self)
    if player:getKingdom() == "wei" then
        local room = player:getRoom()
        room:fillAG(cards, player)
        local card_id = room:askForAG(player, cards, false, self:objectName())
        room:obtainCard(player, card_id, false)
        room:clearAG(player)
    end
end

s4_weiT_lord = sgs.CreateTriggerSkill {
    name = "s4_weiT_lord&",
    events = sgs.EventPhaseStart,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:getPhase() == sgs.Player_Start then
            addWeiTerritoryPile(room:getNCards(2), player, self)
        end
    end
}
addToSkills(s4_weiT_lord)

s4_weiT_adviser = sgs.CreateTriggerSkill {
    name = "s4_weiT_adviser&",
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
addToSkills(s4_weiT_adviser)
s4_weiT_gerenal = sgs.CreateTriggerSkill {
    name = "s4_weiT_gerenal&",
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
addToSkills(s4_weiT_gerenal)


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

s4_weiT_caocao = sgs.General(extension, "s4_weiT_caocao", "wei", 4, true)
s4_weiT_naxian = sgs.CreateTriggerSkill {
    name = "s4_weiT_naxian",
    events = {sgs.Damaged, sgs.DrawNCards, sgs.GameStart},
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.Damaged then
        local damage = data:toDamage()
        room:setPlayerMark(player, "&"..self:objectName(), math.max(math.min(player:getHp(), player:getMark("&"..self:objectName())), 2))
    elseif event == sgs.DrawNCards then
        local x = player:getMark("&"..self:objectName())
        if room:askForSkillInvoke(player, self:objectName()) then
            --xuxu
        end
    elseif event == sgs.GameStart then
        room:setPlayerMark(player, "&"..self:objectName(), player:getHp())
    end
    end
}
s4_weiT_xionglue = sgs.CreateTriggerSkill {
    name = "s4_weiT_xionglue",
    events = {sgs.Damaged},
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.Damaged then
        local damage = data:toDamage()
        if  getWeiTerritoryPile(player):length() > 0 and player:askForSkillInvoke(self:objectName()) then 
            gainWeiTerritoryPile(getWeiTerritoryPile(player), player, self)
        end
    end
    end
}

s4_weiT_caocao:addSkill(s4_weiT_naxian)
s4_weiT_caocao:addSkill(s4_weiT_xionglue)
s4_weiT_caocao:addSkill("s4_weiT_lord&")

sgs.LoadTranslationTable {
    ["s4_weiT_caocao"] = "曹操",
    ["#s4_weiT_caocao"] = "",

    ["s4_weiT_naxian"] = "纳贤",
    [":s4_weiT_naxian"] = "摸牌阶段，你可以改为观看牌堆顶X张牌，然后你可以获得其中至多两张牌，并将其余的牌置于【魏领土】。X为你本局游戏体力最小值且至少为2。",
    ["s4_weiT_xionglue"] = "雄略",
    [":s4_weiT_xionglue"] = "当你受到一次伤害后，你可以从【魏领土】中获得一张牌。",

}

s4_weiT_xiahoudun = sgs.General(extension, "s4_weiT_xiahoudun", "wei", 4, true)





sgs.LoadTranslationTable {
    ["s4_weiT_xiahoudun"] = "夏侯惇",
    ["#s4_weiT_xiahoudun"] = "",

    ["s4_weiT_ganglie"] = "刚烈",
    [":s4_weiT_ganglie"] = "当你使用【杀】造成伤害或受到【杀】造成的伤害后，你可以作一次判定，若结果为黑色，你获得其一张牌，否则受伤角色对对方造成1点伤害。",

    ["s4_weiT_qingjian"] = "清俭",
    [":s4_weiT_qingjian"] = "你可将摸牌阶段外获得的牌置于【魏领土】中。",


}























return { extension }
