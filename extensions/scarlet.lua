extension = sgs.Package("scarlet")
sgs.LoadTranslationTable {
    ["scarlet"] = "時語"
}
-- useful function


function RIGHT(self, player)
    if player and player:isAlive() and player:hasSkill(self:objectName()) then
        return true
    else
        return false
    end
end

---@param room room
---@return int輪次數
function getRoundCount(room)
    local n = 15
    for _, p in sgs.qlist(room:getAlivePlayers()) do
        n = math.min(p:getSeat(), n)
    end
    for _, player in sgs.qlist(room:getAlivePlayers()) do
        if player:getSeat() == n then
            local x = player:getMark("Global_TurnCount") + 1
            return x
        end
    end
end

---@param self string_boolean_number
---@return sgs.QVariant
function ToQVData(self)
    local data = sgs.QVariant()
    if type(self) == "string" or type(self) == "boolean" or type(self) == "number" then
        data = sgs.QVariant(self)
    elseif self ~= nil then
        data:setValue(self)
    end
    return data
end

listIndexOf = function(theqlist, theitem)
    local index = 0
    for _, item in sgs.qlist(theqlist) do
        if item == theitem then
            return index
        end
        index = index + 1
    end
end

--作用：将currentplayer转换成serverplayer
---@param room room
---@param player player
---@return serverplayer
player2serverplayer = function(room, player)
    local players = room:getPlayers()
    for _, p in sgs.qlist(players) do
        if p:objectName() == player:objectName() then
            return p
        end
    end
end


function getCardDamageNature(from, to, card)
    local nature = sgs.DamageStruct_Normal
    if card then
        if card:isKindOf("FireAttack") or card:isKindOf("FireSlash") then
            nature = sgs.DamageStruct_Fire
        elseif card:isKindOf("drowning") or card:isKindOf("ThunderSlash") then
            nature = sgs.DamageStruct_Thunder
        elseif card:isKindOf("IceSlash") then
            nature = sgs.DamageStruct_Ice
        end
    end
    if hasWulingEffect("@fire") then
        nature = sgs.DamageStruct_Fire
    end
    return nature
end

function ChoiceLog(player, choice, to)
    local log = sgs.LogMessage()
    log.type = "#choice"
    log.from = player
    log.arg = choice
    if to then
        log.to:append(to)
    end
    player:getRoom():sendLog(log)
end

function GetColor(card)
    if card:isRed() then return "red" elseif card:isBlack() then return "black" else return "nosuitcolor" end
end

-- common prompt
sgs.LoadTranslationTable {
    ["#skill_add_damage"] = "%from的技能【<font color=\"yellow\"><b> %arg </b></font>】被触发，%from对%to造成的伤害增加至%arg2点。", -- add
    ["#skill_add_damage_byother1"] = "%from的技能【<font color=\"yellow\"><b> %arg </b></font>】被触发，", -- add
    ["#skill_add_damage_byother2"] = "%from 对%to造成的伤害增加至%arg点。", -- add
    ["#skill_cant_jink"] = "%from的技能【<font color=\"yellow\"><b> %arg </b></font>】被触发，%to 不能使用【闪】响应 %from 对 %to 使用的【杀】。", -- add
    ["#BecomeTargetBySkill"] = "%from的技能【<font color=\"yellow\"><b> %arg </b></font>】被触发，%to 成为了 %card 的目标", -- add
    ["#ArmorNullifyDamage"] = "%from 的防具【%arg】效果被触发，抵消 %arg2 點傷害", -- add
    ["#SkillNullifyDamage"] = "%from 的技能【%arg】效果被触发，抵消 %arg2 點傷害", -- add
    ["#ChooseSkill"] = "%from 的技能 %arg 选择了 %arg2",
    ["#choice"] = "%from 选择了 %arg",
}
s4_cloud_zhangliao = sgs.General(extension, "s4_cloud_zhangliao", "wei", 4, false, false, false, 3)

s4_cloud_tuxi = sgs.CreateTriggerSkill {
    name = "s4_cloud_tuxi",
    events = { sgs.EventPhaseStart },
    -- events = { sgs.EventPhaseStart, sgs.CardFinished },
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data, room)
        local room = player:getRoom()
        for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
            if p and p:objectName() ~= player:objectName() and
                room:askForSkillInvoke(p, self:objectName(), ToQVData(player)) then
                room:broadcastSkillInvoke(self:objectName())
                if room:askForDiscard(p, self:objectName(), 999, 1, true, true, "@s4_cloud_tuxi:" .. player:objectName()) then
                else
                    local lose_num = {}
                    for i = 1, p:getHp() do
                        table.insert(lose_num, tostring(i))
                    end
                    local choice = room:askForChoice(p, "s4_cloud_tuxi", table.concat(lose_num, "+"))
                    room:loseHp(p, tonumber(choice))
                end
                if p:isAlive() then
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
        end
    end,
    can_trigger = function(self, target)
        return target and target:getPhase() == sgs.Player_Play and target:isAlive()
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
                room:broadcastSkillInvoke(self:objectName())
                local count = data:toInt()
                data:setValue(count - 1)
                room:setFixedDistance(player, target, 1);
                room:setPlayerMark(player, self:objectName() .. target:objectName(), 1)
                room:addPlayerMark(target, "&" .. self:objectName() .. "+to+#" .. player:objectName())
                local assignee_list = player:property("extra_slash_specific_assignee"):toString():split("+")
                table.insert(assignee_list, target:objectName())
                room:setPlayerProperty(player, "extra_slash_specific_assignee",
                    sgs.QVariant(table.concat(assignee_list, "+")))
            end
        elseif event == sgs.TargetConfirmed then
            local use = data:toCardUse()
            if use.card and not use.card:isKindOf("SkillCard") and use.from and player:objectName() ==
                use.from:objectName() then
                for _, p in sgs.qlist(use.to) do
                    if p:objectName() ~= use.from:objectName() and p:getMark(self:objectName() .. player:objectName()) >
                        0 and room:askForSkillInvoke(p, self:objectName()) then
                        p:drawCards(1)
                        room:broadcastSkillInvoke(self:objectName())
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
    name = "#s4_cloud_yongqianClear",
    events = { sgs.EventPhaseChanging },
    on_trigger = function(self, event, player, data, room)
        if event == sgs.EventPhaseChanging then
            if data:toPhaseChange().to == sgs.Player_Start then
                local assignee_list = player:property("extra_slash_specific_assignee"):toString():split("+")
                for _, p in sgs.qlist(room:getAllPlayers()) do
                    if player:getMark("s4_cloud_yongqian" .. p:objectName()) > 0 then
                        table.removeOne(assignee_list, p:objectName())
                        room:setFixedDistance(player, p, -1);
                        room:setPlayerMark(player, "s4_cloud_yongqian" .. p:objectName(), 0)
                        room:setPlayerMark(p, "&s4_cloud_yongqian+to+#" .. player:objectName(), 0)
                    end
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
    ["~s4_cloud_zhangliao"] = "孙权小儿",
    ["designer:s4_cloud_zhangliao"] = "终极植物",
    ["cv:s4_cloud_zhangliao"] = "三国杀瑞宝",
    ["illustrator:s4_cloud_zhangliao"] = "云崖",

    ["@s4_cloud_tuxi"] = "你可以弃置至少一张牌或失去至少1点体力，对 %src 使用突襲",
    ["s4_cloud_tuxi"] = "突襲",
    -- [":s4_cloud_tuxi"] = "当一名其他角色出牌阶段开始时或当一名其他角色于其出牌阶段使用的一张牌结算结束后，你可以弃置至少一张牌或失去至少1点体力，然后若其手牌数不小于你，你获得其一张手牌；若其装备数不小于你，你弃置其一张牌；若其体力值不小于你，你获得1点护甲，对其造成1点伤害。",
    [":s4_cloud_tuxi"] = "当一名其他角色出牌阶段开始时，你可以弃置至少一张牌或失去至少1点体力，然后若其手牌数不小于你，你获得其一张手牌；若其装备数不小于你，你弃置其一张牌；若其体力值不小于你，你获得1点护甲，对其造成1点伤害。",
    ["$s4_cloud_tuxi1"] = "江东小儿，安敢啼哭？",
    ["$s4_cloud_tuxi2"] = "八百虎贲踏江去，十万吴兵丧胆还！",

    ["s4_cloud_yongqian-invoke"] = "你可以发动“勇前”<br/> <b>操作提示</b>: 选择一名其他角色→点击确定<br/>",
    ["s4_cloud_yongqian"] = "勇前",
    [":s4_cloud_yongqian"] = "摸牌阶段，你可以少摸一张牌，然后选择一名其他角色，直到你下回合开始，你对其使用牌无距离和次数限制，当其使用牌指定你为目标后，你可以摸一张牌。",
    ["$s4_cloud_yongqian1"] = "千围万困，吾亦能来去自如！",
    ["$s4_cloud_yongqian2"] = "敌军虽百倍于我，破之易而。"

}

s4_cloud_huangzhong = sgs.General(extension, "s4_cloud_huangzhong", "shu", 3, false)

s4_cloud_liegong = sgs.CreateTriggerSkill {
    name = "s4_cloud_liegong",
    events = { sgs.TargetConfirmed, sgs.DamageCaused },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.TargetConfirmed then
            local use = data:toCardUse()
            if not use.from or (player:objectName() ~= use.from:objectName()) or not use.card:isKindOf("Slash") then
                return false
            end
            local jink_table = sgs.QList2Table(player:getTag("Jink_" .. use.card:toString()):toIntList())
            local index = 1
            for _, p in sgs.qlist(use.to) do
                if p:getHandcardNum() >= player:getHp() or p:getHandcardNum() <= player:getAttackRange() then
                    if player:askForSkillInvoke(self:objectName(), ToQVData(p)) then
                        room:broadcastSkillInvoke(self:objectName())
                        local log = sgs.LogMessage()
                        log.type = "#skill_cant_jink"
                        log.from = player
                        log.to:append(p)
                        log.arg = self:objectName()
                        room:sendLog(log)
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
            if damage.card and damage.card:isKindOf("Slash") and damage.from and damage.by_user and (not damage.chain) and
                (not damage.transfer) then
                if damage.to and (damage.to:getHp() >= player:getHp() or damage.to:getHp() <= player:getAttackRange()) then
                    if player:askForSkillInvoke(self:objectName(), ToQVData(damage.to)) then
                        room:broadcastSkillInvoke(self:objectName())
                        damage.damage = damage.damage + 1
                        local log = sgs.LogMessage()
                        log.type = "#skill_add_damage"
                        log.from = damage.from
                        log.to:append(damage.to)
                        log.arg = self:objectName()
                        log.arg2 = damage.damage
                        room:sendLog(log)
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
        local x = math.max(#record, 1)
        if target:hasSkill("s4_cloud_yongyi") then
            return x
        else
            return 0
        end
    end
}
s4_cloud_yongyiAnaleptic = sgs.CreateTargetModSkill {
    name = "#s4_cloud_yongyiAnaleptic",
    pattern = "Analeptic",
    residue_func = function(self, player, card)
        if player:hasSkill(self:objectName()) and card:getSkillName() == "s4_cloud_yongyi" then
            return 1000
        end
    end
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
            local card = nil
            card = sgs.Sanguosha:cloneCard("analeptic")
            card:setSkillName("_s4_cloud_yongyi")
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
        local use_card = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
        if not use_card then
            return nil
        end
        use_card:setSkillName("s4_cloud_yongyi")
        -- use_card:deleteLater()
        room:setCardFlag(use_card, "RemoveFromHistory")
        room:addPlayerHistory(source, use_card:getClassName(), -1)
        room:addPlayerMark(source, "s4_cloud_yongyi_used-Clear")
        local record = source:property("s4_cloud_yongyiRecords"):toString()
        local records
        if (record) then
            records = record:split(",")
        end
        local suit = room:askForChoice(source, "s4_cloud_yongyi", table.concat(records, "+"), sgs.QVariant())
        if records and (table.contains(records, suit)) then
            table.removeOne(records, suit)
        end
        room:setPlayerProperty(source, "s4_cloud_yongyiRecords", sgs.QVariant(table.concat(records, ",")));
        for _, mark in sgs.list(source:getMarkNames()) do
            if (string.startsWith(mark, "&s4_cloud_yongyi+#record") and source:getMark(mark) > 0) then
                room:setPlayerMark(source, mark, 0)
            end
        end
        local mark = "&s4_cloud_yongyi+#record"
        for _, suit in ipairs(records) do
            mark = mark .. "+" .. suit .. "_char"
        end
        room:setPlayerMark(source, mark, 1)
        -- room:setCardFlag(use_card, "RemoveFromHistory")
        return use_card
    end,
    on_validate_in_response = function(self, source)
        local room = source:getRoom()
        local use_card = sgs.Sanguosha:cloneCard("analeptic")
        if not use_card then
            return nil
        end
        use_card:setSkillName("s4_cloud_yongyi")
        room:setCardFlag(use_card, "RemoveFromHistory")
        room:addPlayerMark(source, "s4_cloud_yongyi_used-Clear")
        room:addPlayerHistory(source, use_card:getClassName(), -1)

        local record = source:property("s4_cloud_yongyiRecords"):toString()
        local records
        if (record) then
            records = record:split(",")
        end
        local suit = room:askForChoice(source, "s4_cloud_yongyi", table.concat(records, "+"), sgs.QVariant())
        if records and (table.contains(records, suit)) then
            table.removeOne(records, suit)
        end
        room:setPlayerProperty(source, "s4_cloud_yongyiRecords", sgs.QVariant(table.concat(records, ",")));
        for _, mark in sgs.list(source:getMarkNames()) do
            if (string.startsWith(mark, "&s4_cloud_yongyi+#record") and source:getMark(mark) > 0) then
                room:setPlayerMark(source, mark, 0)
            end
        end
        local mark = "&s4_cloud_yongyi+#record"
        for _, suit in ipairs(records) do
            mark = mark .. "+" .. suit .. "_char"
        end
        room:setPlayerMark(source, mark, 1)
        -- room:setCardFlag(use_card, "RemoveFromHistory")
        -- use_card:deleteLater()
        return use_card
    end
}

s4_cloud_yongyiVS = sgs.CreateZeroCardViewAsSkill {
    name = "s4_cloud_yongyi",
    view_as = function(self, card)
        if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or
            sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
            local c = s4_cloud_yongyiCard:clone()
            c:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
            return c
        end

        local ccc = sgs.Sanguosha:cloneCard("analeptic")
        ccc:setSkillName("s4_cloud_yongyi")
        if ccc and ccc:isAvailable(sgs.Self) then
            local c = s4_cloud_yongyiCard:clone()
            c:setUserString(ccc:objectName())
            return c
        end
        return nil
    end,
    enabled_at_play = function(self, player)
        local newanal = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
        newanal:setSkillName(self:objectName())
        newanal:deleteLater()
        return #player:property("s4_cloud_yongyiRecords"):toString():split(",") > 0 and
            player:getMark("s4_cloud_yongyi_used-Clear") == 0 and player:usedTimes("Analeptic") <=
            sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, player, newanal)
    end,
    enabled_at_response = function(self, player, pattern)
        return #player:property("s4_cloud_yongyiRecords"):toString():split(",") > 0 and
            string.find(pattern, "analeptic") and player:getMark("s4_cloud_yongyi_used-Clear") == 0
    end
}

s4_cloud_yongyi = sgs.CreateTriggerSkill {
    name = "s4_cloud_yongyi",
    view_as_skill = s4_cloud_yongyiVS,
    events = { sgs.CardUsed, sgs.CardResponded, sgs.TargetConfirmed },
    on_trigger = function(self, event, player, data, room)
        local card = nil
        if (event == sgs.CardUsed) then
            local use = data:toCardUse()
            card = use.card
        elseif (event == sgs.CardResponded) then
            local res = data:toCardResponse()
            if (not res.m_isUse) then
                return false
            end
            card = res.m_card
        elseif (event == sgs.TargetConfirmed) then
            local use = data:toCardUse()
            if (use.from == player or not use.to:contains(player)) then
                return false
            end
            card = use.card;
        end
        if (not card or card:isKindOf("SkillCard")) then
            return false
        end
        local record = player:property("s4_cloud_yongyiRecords"):toString()
        local suit = card:getSuitString()
        local records
        if (record) then
            records = record:split(",")
        end
        if records and (table.contains(records, suit) or not card:hasSuit()) then
            local x = math.max(1, #records)
            if player:askForSkillInvoke(self:objectName(), ToQVData(card)) then
                player:drawCards(x)
                room:broadcastSkillInvoke(self:objectName())
                if card:hasSuit() then
                    table.removeOne(records, suit)
                end
            end
        else
            table.insert(records, suit)
        end
        room:setPlayerProperty(player, "s4_cloud_yongyiRecords", sgs.QVariant(table.concat(records, ",")));
        for _, mark in sgs.list(player:getMarkNames()) do
            if (string.startsWith(mark, "&s4_cloud_yongyi+#record") and player:getMark(mark) > 0) then
                room:setPlayerMark(player, mark, 0)
            end
        end
        local mark = "&s4_cloud_yongyi+#record"
        for _, suit in ipairs(records) do
            mark = mark .. "+" .. suit .. "_char"
        end
        room:setPlayerMark(player, mark, 1)
        return false
    end
}
s4_cloud_huangzhong:addSkill(s4_cloud_liegong)
s4_cloud_huangzhong:addSkill(s4_cloud_yongyi)
s4_cloud_huangzhong:addSkill(s4_cloud_yongyiAnaleptic)
s4_cloud_huangzhong:addSkill(s4_cloud_yongyiAttackRange)
extension:insertRelatedSkills("s4_cloud_yongyi", "#s4_cloud_yongyiAttackRange")
extension:insertRelatedSkills("s4_cloud_yongyi", "#s4_cloud_yongyiAnaleptic")
sgs.LoadTranslationTable {
    ["s4_cloud_huangzhong"] = "谋黄忠",
    ["#s4_cloud_huangzhong"] = "没金铩羽",
    ["~s4_cloud_huangzhong"] = "弦断弓藏，将老孤亡。",
    ["designer:s4_cloud_huangzhong"] = "终极植物",
    ["cv:s4_cloud_huangzhong"] = "予安",
    ["illustrator:s4_cloud_huangzhong"] = "云崖",

    ["$s4_cloud_liegong"] = "矢贯坚石，劲冠三军。",
    ["s4_cloud_liegong"] = "烈弓",
    [":s4_cloud_liegong"] = "当你使用【杀】指定目标后，你可以根据下列条件执行相应的效果：1.若其手牌数不小于你的体力值或不大于你的攻击范围，你可以令其不能响应此【杀】；2.若其体力值不小于你的体力值或不大于你的攻击范围，你可以令此【杀】伤害+1。",
    ["$s4_cloud_yongyi"] = "吾虽年迈，箭矢犹锋。",
    ["s4_cloud_yongyi"] = "勇毅",
    [":s4_cloud_yongyi"] = "你使用牌时或成为其他角色使用牌的目标后，若此牌有花色且花色未被“勇毅”记录，则记录此花色；否则，你可以摸X张牌，若如此做，移除此花色记录。你的攻击范围加X（X为“勇毅”记录的花色数且至少为1）。每回合限一次，你可以移除一种花色记录，视为使用一张无次数限制的【酒】。"
}

s4_cloud_sunquan = sgs.General(extension, "s4_cloud_sunquan", "wu", 3, false)

s4_cloud_yingzi = sgs.CreateTriggerSkill {
    name = "s4_cloud_yingzi",
    frequency = sgs.Skill_Compulsory,
    events = { sgs.DrawNCards },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local x = 0
        if player:getHandcardNum() >= 2 then
            x = x + 1
        end
        if player:getHp() >= 2 then
            x = x + 1
        end
        if player:getEquips():length() >= 1 then
            x = x + 1
        end
        if x > 0 then
            local count = data:toInt() + x
            data:setValue(count)
            room:addMaxCards(player, x, true)
            room:addPlayerMark(player, "&s4_cloud_yingzi-Clear", x)
        end
    end
}

s4_cloud_sunquan:addSkill(s4_cloud_yingzi)
s4_cloud_sunquan:addSkill("tenyearzhiheng")
s4_cloud_sunquan:addSkill("mobilemoujiuyuan")

sgs.LoadTranslationTable {
    ["s4_cloud_sunquan"] = "孙权",
    ["#s4_cloud_sunquan"] = "东吴大帝",
    ["~s4_cloud_sunquan"] = "",
    ["designer:s4_cloud_sunquan"] = "终极植物",
    ["cv:s4_cloud_sunquan"] = "",
    ["illustrator:s4_cloud_sunquan"] = "云崖",

    ["s4_cloud_yingzi"] = "英姿",
    [":s4_cloud_yingzi"] = "锁定技，摸牌阶段，你多摸X张牌且你本回合的手牌上限+X（X为你满足的条件数：手牌数不小于2、体力值不小于2、装备区的牌数不小于1）。"
}
----------------------------------------------------------------
-- https://tieba.baidu.com/p/8501081538
----------------------------------------------------------------

s4_lubu = sgs.General(extension, "s4_lubu", "qun", 5)
s4_xianfeng = sgs.CreateTriggerSkill {
    name = "s4_xianfeng",
    events = { sgs.TargetSpecified },
    on_trigger = function(self, event, player, data, room)
        if event == sgs.TargetSpecified then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("Slash") then
                local invoke = false
                for _, to in sgs.qlist(use.to) do
                    if player:distanceTo(to) <= 1 then
                        invoke = true
                        break
                    end
                end
                if invoke then
                    room:broadcastSkillInvoke(self:objectName())
                    room:sendCompulsoryTriggerLog(player, self:objectName())
                    room:addPlayerHistory(player, use.card:getClassName(), -1)
                end
            end
        end
        return false
    end
}
s4_xianfeng_TM = sgs.CreateTargetModSkill {
    name = "#s4_xianfeng_TM",
    pattern = "Slash",
    residue_func = function(self, from, card, to)
        local n = 0
        if from:hasSkill("s4_xianfeng") and to and from:distanceTo(to) <= 1 then
            n = 999
        end
        return n
    end
}
s4_xianfeng_D = sgs.CreateDistanceSkill {
    name = "#s4_xianfeng_D",
    correct_func = function(self, from, to)
        if from:hasSkill("s4_xianfeng") then
            return -1
        end
    end
}

s4_jiwu = sgs.CreateTriggerSkill {
    name = "s4_jiwu",
    events = { sgs.TargetConfirmed, sgs.CardFinished },
    on_trigger = function(self, event, player, data, room)
        if event == sgs.TargetConfirmed then
            local use = data:toCardUse()
            if use.from and use.from:isAlive() and use.card and
                (use.card:isKindOf("Slash") or use.card:isKindOf("Duel")) and use.from:objectName() ==
                player:objectName() then
                for _, lubu in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
                    if lubu and lubu:distanceTo(use.from) <= 1 then
                        local choicelist = {}
                        table.insert(choicelist, "s4_jiwu_no_respond_list")
                        table.insert(choicelist, "s4_jiwu_draw")

                        if lubu:getMark("&s4_jiwu_used+analeptic") == 0 then
                            table.insert(choicelist, "s4_jiwu_nullified")
                        end
                        table.insert(choicelist, "cancel")
                        room:setTag("CurrentUseStruct", data)
                        local x = 0
                        while #choicelist > 1 do
                            local choice = room:askForChoice(lubu, self:objectName(), table.concat(choicelist, "+"),
                                data)
                            if choice == "cancel" then
                                break
                            end
                            x = x + 1
                            if choice == "s4_jiwu_no_respond_list" then
                                local list = use.no_respond_list
                                for _, to in sgs.qlist(use.to) do
                                    table.insert(list, to:objectName())
                                end
                                use.no_respond_list = list
                                room:setCardFlag(use.card, "s4_jiwu_no_respond")
                                table.removeOne(choicelist, "s4_jiwu_no_respond_list")
                                room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
                            elseif choice == "s4_jiwu_draw" then
                                room:setCardFlag(use.card, self:objectName())
                                room:setPlayerMark(lubu, "s4_jiwu_" .. use.card:getEffectiveId(), 1)
                                table.removeOne(choicelist, "s4_jiwu_draw")
                                room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
                                lubu:drawCards(2)
                            elseif choice == "s4_jiwu_nullified" then
                                room:broadcastSkillInvoke(self:objectName(), 3)
                                local nullified_list = use.nullified_list
                                for _, to in sgs.qlist(use.to) do
                                    table.insert(nullified_list, to:objectName())
                                end
                                use.nullified_list = nullified_list
                                room:addPlayerMark(lubu, "&s4_jiwu_used+analeptic")
                                table.removeOne(choicelist, "s4_jiwu_nullified")
                                local analeptic = sgs.Sanguosha:cloneCard("analeptic")
                                analeptic:setSkillName(self:objectName())
                                analeptic:deleteLater()
                                local useEX = sgs.CardUseStruct()
                                useEX.from = lubu
                                useEX.card = analeptic
                                room:useCard(useEX, false)
                                useEX.from = use.from
                                room:useCard(useEX, false)
                                room:setCardFlag(use.card, "s4_jiwu_nullified")
                            end
                            local log = sgs.LogMessage()
                            log.type = "#ChooseSkill"
                            log.from = lubu
                            log.arg = self:objectName()
                            log.arg2 = choice
                            room:sendLog(log)
                        end
                        if x > 0 then
                            local card = room:askForDiscard(lubu, "s4_jiwu_invoke", x, x, true, true, "@s4_jiwu:" .. x)
                            if card then
                            else
                                room:loseHp(lubu, 1)
                            end
                        end
                        data:setValue(use)
                        room:notifySkillInvoked(player, self:objectName())
                        room:removeTag("CurrentUseStruct")
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}
s4_jiwuClear = sgs.CreateTriggerSkill {
    name = "#s4_jiwuClear",
    events = { sgs.CardUsed, sgs.CardResponded, sgs.EventPhaseStart, sgs.CardOffset },
    can_trigger = function(self, target)
        return target
    end,
    on_trigger = function(self, event, player, data, room)
        if (event == sgs.CardUsed or event == sgs.CardResponded) then
            local card
            local cardEX
            if event == sgs.CardResponded then
                card = data:toCardResponse().m_toCard
                cardEX = data:toCardResponse().m_Card
            else
                card = data:toCardUse().whocard
                cardEX = data:toCardUse().card
            end

            if not card or not card:hasFlag("s4_jiwu") then
                return
            end
            if not cardEX or not cardEX:isKindOf("Nullification") then
                return
            end
            for _, lubu in sgs.qlist(room:findPlayersBySkillName("s4_jiwu")) do
                if lubu and lubu:getMark("s4_jiwu_" .. card:getEffectiveId()) > 0 then
                    room:setPlayerMark(lubu, "s4_jiwu_" .. card:getEffectiveId(), 0)
                    room:sendCompulsoryTriggerLog(lubu, "s4_jiwu")
                    room:askForDiscard(lubu, "s4_jiwu", 2, 2, false, true)
                    room:broadcastSkillInvoke("s4_jiwu", 4)
                end
            end
        elseif event == sgs.EventPhaseStart then
            if player:getPhase() == sgs.Player_Start and player:hasSkill("s4_jiwu") then
                if player:getMark("&s4_jiwu_used+analeptic") > 0 then
                    room:setPlayerMark(player, "&s4_jiwu_used+analeptic", 0)
                end
            end
        elseif event == sgs.CardOffset then
            local effect = data:toCardEffect()
            if effect.card and effect.card:isKindOf("Slash") and effect.card:hasFlag("s4_jiwu") then
                for _, lubu in sgs.qlist(room:findPlayersBySkillName("s4_jiwu")) do
                    if lubu and lubu:getMark("s4_jiwu_" .. effect.card:getEffectiveId()) > 0 then
                        room:setPlayerMark(lubu, "s4_jiwu_" .. effect.card:getEffectiveId(), 0)
                        room:sendCompulsoryTriggerLog(lubu, "s4_jiwu")
                        room:askForDiscard(lubu, "s4_jiwu", 2, 2, false, true)
                        room:broadcastSkillInvoke("s4_jiwu", 4)
                    end
                end
            end
        end
        return false
    end
}
s4_lubu:addSkill(s4_xianfeng)
s4_lubu:addSkill(s4_xianfeng_TM)
s4_lubu:addSkill(s4_xianfeng_D)
extension:insertRelatedSkills("s4_xianfeng", "#s4_xianfeng_TM")
extension:insertRelatedSkills("s4_xianfeng", "#s4_xianfeng_D")
s4_lubu:addSkill(s4_jiwu)
s4_lubu:addSkill(s4_jiwuClear)
extension:insertRelatedSkills("s4_jiwu", "#s4_jiwuClear")

sgs.LoadTranslationTable {
    ["s4_lubu"] = "吕布",
    ["#s4_lubu"] = "飛將",
    ["~s4_lubu"] = "",
    ["designer:s4_lubu"] = "终极植物",
    ["cv:s4_lubu"] = "",
    ["illustrator:s4_lubu"] = "",

    ["s4_xianfeng"] = "陷锋",
    ["#s4_xianfeng_D"] = "陷锋",
    [":s4_xianfeng"] = "锁定技，你计算与其他角色的距离-1；你对距离1以内的角色使用【杀】不计入限制的次数且无次数限制。",
    ["$s4_xianfeng1"] = "",
    ["$s4_xianfeng2"] = "",

    ["@s4_jiwu"] = "你可以发动“极武”弃置 %src 张牌或失去1点体力",
    ["s4_jiwu_used"] = "极武",
    ["s4_jiwu_invoke"] = "极武",
    ["s4_jiwu_no_respond_list"] = "此【杀】或【决斗】不能被响应",
    ["s4_jiwu_draw"] = "摸两张牌，当此【杀】或【决斗】被抵消时，你弃置两张牌",
    ["s4_jiwu_nullified"] = "此【杀】或【决斗】无效，你与此牌使用者各视为使用一张无次数限制的【酒】，然后移除此选项直到你下回合开始。",
    ["s4_jiwu"] = "极武",
    [":s4_jiwu"] = "当距离1以内的一名角色使用【杀】或【决斗】指定目标时，你可以选择任意项并弃置等量张牌或失去1点体力：1.此【杀】或【决斗】不能被响应；2.摸两张牌，当此【杀】或【决斗】被抵消时，你弃置两张牌；3.此【杀】或【决斗】无效，你与此牌使用者各视为使用一张无次数限制的【酒】，然后移除此选项直到你下回合开始。",
    ["$s4_jiwu1"] = "",
    ["$s4_jiwu2"] = "",
    ["$s4_jiwu3"] = "",
    ["$s4_jiwu4"] = ""

}
----------------------------------------------------------------
-- https://tieba.baidu.com/p/8519622496
----------------------------------------------------------------

s4_zhaoyun = sgs.General(extension, "s4_zhaoyun", "shu", 4)

s4_jiuzhu = sgs.CreateTriggerSkill {
    name = "s4_jiuzhu",
    events = { sgs.CardsMoveOneTime, sgs.EventPhaseChanging },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardsMoveOneTime then
            local current = room:getCurrent()
            if not player or not player:hasSkill(self:objectName()) then return false end
            if not current or current:getPhase() == sgs.Player_NotActive then return false end
            local move = data:toMoveOneTime()
            local reason = move.reason.m_reason
            if bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD then
                if move.to_place == sgs.Player_DiscardPile then
                    local ids, disabled = sgs.IntList(), sgs.IntList()
                    local all_ids = move.card_ids
                    for _, id in sgs.qlist(move.card_ids) do
                        local card = sgs.Sanguosha:getCard(id)
                        if card and card:isKindOf("BasicCard") and room:getCardPlace(id) == sgs.Player_DiscardPile and player:getMark("&s4_jiuzhu-Clear") == 0 then
                            ids:append(id)
                        else
                            disabled:append(id)
                        end
                    end
                    if ids:isEmpty() then return false end
                    if not ids:isEmpty() then
                        room:fillAG(all_ids, player, disabled)
                        local only = (all_ids:length() == 1)
                        local card_id = -1
                        if only then
                            card_id = ids:first()
                        else
                            card_id = room:askForAG(player, ids, true, self:objectName())
                        end
                        room:clearAG(player)
                        if card_id == -1 then return false end
                        if only then
                            player:setMark("YanyuOnlyId", card_id + 1)
                        end
                        local card = sgs.Sanguosha:getCard(card_id)
                        local target = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(),
                            string.format("@yanyu-give:::%s:%s\\%s", card:objectName(), card:getSuitString() .. "_char"
                            , card:getNumberString()), only, true)
                        player:setMark("YanyuOnlyId", 0)
                        if target then
                            local index = move.card_ids:indexOf(card_id)
                            local place = move.from_places:at(index)
                            -- move.from_places:removeAt(index)
                            -- move.card_ids:removeOne(card_id)
                            -- data:setValue(move)
                            ids:removeOne(card_id)
                            disabled:append(card_id)

                            -- if move.from and move.from:objectName() == target:objectName() and place ~= sgs.Player_PlaceTable then
                            --     local log = sgs.LogMessage()
                            --     log.type = "$MoveCard"
                            --     log.from = target
                            --     log.to:append(target)
                            --     log.card_str = tostring(card_id)
                            --     room:sendLog(log)
                            -- end
                            local card = room:askForDiscard(player, "s4_jiuzhu_invoke", x, x, true, true,
                                "@s4_jiuzhu:" .. target:objectName())
                            if card then
                            else
                                room:loseHp(player, 1)
                            end
                            target:obtainCard(card)
                            room:addPlayerMark(player, "&s4_jiuzhu-Clear")
                            if player:getPhase() ~= sgs.Player_NotActive then
                                if room:askForSkillInvoke(player, self:objectName()) then
                                    player:drawCards(2, self:objectName())
                                end
                            else
                                if not current:isNude() then
                                    --if room:askForSkillInvoke(player, self:objectName()) then
                                    local id = room:askForCardChosen(player, current, "he", self:objectName())
                                    if id ~= -1 then
                                        room:obtainCard(player, id, false)
                                    end
                                    --end
                                end
                            end
                        else
                            return false
                        end
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end
}
s4_zhaoyun:addSkill(s4_jiuzhu)

sgs.LoadTranslationTable {
    ["s4_zhaoyun"] = "赵云",
    ["#s4_zhaoyun"] = "七進七出",
    ["~s4_zhaoyun"] = "",
    ["designer:s4_zhaoyun"] = "终极植物",
    ["cv:s4_zhaoyun"] = "",
    ["illustrator:s4_zhaoyun"] = "",

    ["s4_jiuzhu"] = "救主",
    [":s4_jiuzhu"] = "每回合限一次，当一张基本牌进入弃牌堆后，你可以弃置一张牌或失去1点体力，令一名角色获得此基本牌。然后若此时是你的回合，你可以摸两张牌；若不是，你可以获得当前回合角色一张牌。",
    ["$s4_jiuzhu1"] = "",
    ["$s4_jiuzhu2"] = "",

}
----------------------------------------------------------------
-- https://tieba.baidu.com/p/8628062146
----------------------------------------------------------------



local s4_skillList = sgs.SkillList()

s4_txbw_disgeneralCard = sgs.CreateSkillCard {
    name = "s4_txbw_disgeneral",
    target_fixed = true,
    will_throw = false,
    on_use = function(self, room, source, targets)
        room:setPlayerMark(source, "@s4_txbw_general", 0)
    end
}
s4_txbw_disgeneral = sgs.CreateViewAsSkill {
    name = "s4_txbw_disgeneral&",
    n = 0,
    view_as = function(self, cards)
        if #cards == 0 then
            local card = s4_txbw_disgeneralCard:clone()
            return card
        end
    end,
    enabled_at_play = function(self, player)
        return player:getMark("@s4_txbw_general") > 0
    end
}

s4_txbw_general_gain = sgs.CreateTriggerSkill {
    name = "s4_txbw_general_gain&",
    frequency = sgs.Skill_Compulsory,
    events = { sgs.GameStart },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        room:addPlayerMark(player, "@s4_txbw_general")
        return false
    end
}

s4_txbw_general_limit = sgs.CreateCardLimitSkill {
    name = "s4_txbw_general_limit",
    limit_list = function(self, player)
        if player and player:getMark("@s4_txbw_general") > 0 and player:getPhase() == sgs.Player_Play and
            not player:hasFlag("s4_txbw_general_duel") then
            return "use"
        end
    end,
    limit_pattern = function(self, player)
        if player and player:getMark("@s4_txbw_general") > 0 and player:getPhase() == sgs.Player_Play and
            not player:hasFlag("s4_txbw_general_duel") then
            return "Slash"
        end
    end
}

s4_txbw_general = sgs.CreateTriggerSkill {
    name = "s4_txbw_general",
    global = true,
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.GameStart },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.GameStart then
            for _, p in sgs.qlist(room:getAlivePlayers()) do
                if p:getMark("@s4_txbw_general") > 0 then
                    room:attachSkillToPlayer(p, "s4_txbw_disgeneral")
                    room:attachSkillToPlayer(p, "s4_txbw_general_duel")
                    room:attachSkillToPlayer(p, "s4_txbw_general_duel_rule")
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}

s4_txbw_general_duelCard = sgs.CreateSkillCard {
    name = "s4_txbw_general_duel_start",
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
        msg.type = "#s4_txbw_general_duel_start"
        msg.from = source
        msg.to:append(target)
        room:sendLog(msg)
        room:setPlayerFlag(target, "s4_txbw_general_duel_victim")
        room:setPlayerFlag(source, "s4_txbw_general_duel_start")
        room:setPlayerFlag(source, "s4_txbw_general_duel")
        source:setTag("s4_txbw_general_duel", ToQVData(target))
        target:setTag("s4_txbw_general_duel", ToQVData(source))
        if target:getMark("@s4_txbw_general") > 0 then
            if source:isKongcheng() then
                source:drawCards(2)
            else
                source:drawCards(1)
            end
        end
        if source:getMark("s4_txbw_general_duel_slash-Clear") == 0 then
            room:addPlayerMark(source, "s4_txbw_general_duel_slash-Clear")
            room:addPlayerHistory(source, "Slash", 1)
        end
    end
}
s4_txbw_general_duel_chooseCard = sgs.CreateSkillCard {
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
        local card_v
        if source:isKongcheng() then
            card_s = sgs.Sanguosha:getCard(room:getNCards(1):first())
        else
            card_s = room:askForCard(source, ".|.|.|hand!", "s4_txbw_general_duel", sgs.QVariant(), sgs.Card_MethodNone,
                source,
                false, "s4_txbw_general_duel", true)
        end
        room:setTag("s4_txbw_general_duel_s", sgs.QVariant(card_s:getId()))
        if target:isKongcheng() then
            --card_v = room:drawCards(1)
            card_v = sgs.Sanguosha:getCard(room:getNCards(1):first())
        else
            card_v = room:askForCard(target, ".|.|.|hand!", "s4_txbw_general_duel", sgs.QVariant(), sgs.Card_MethodNone,
                source,
                false, "s4_txbw_general_duel", true)
        end
        room:setTag("s4_txbw_general_duel_v", sgs.QVariant(card_v:getId()))
    end
}
s4_txbw_general_duel_showCard = sgs.CreateSkillCard {
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
        room:setPlayerMark(source, "s4_txbw_general_duel", card_s:getNumber())
        room:setPlayerMark(target, "s4_txbw_general_duel", card_v:getNumber())
        local msg1 = sgs.LogMessage()
        msg1.type = "#s4_txbw_general_duel_show_card"
        msg1.from = source
        msg1.card_str = card_s:objectName()
        room:sendLog(msg1)
        local msg2 = sgs.LogMessage()
        msg2.type = "#s4_txbw_general_duel_show_card"
        msg2.from = target
        msg2.card_str = card_v:objectName()
        room:sendLog(msg2)
        room:moveCardTo(card_s, nil, nil, sgs.Player_DiscardPile, sgs.CardMoveReason(
            sgs.CardMoveReason_S_REASON_RULEDISCARD, "", "s4_txbw_general_duel", ""))
        room:moveCardTo(card_v, nil, nil, sgs.Player_DiscardPile, sgs.CardMoveReason(
            sgs.CardMoveReason_S_REASON_RULEDISCARD, "", "s4_txbw_general_duel", ""))
    end
}
s4_txbw_general_duel_calCard = sgs.CreateSkillCard {
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
        room:sendLog(msg1)
        local msg2 = sgs.LogMessage()
        msg2.type = "#s4_txbw_general_duel_cal_point"
        msg2.from = target
        msg2.arg = victim
        room:sendLog(msg2)
    end
}
s4_txbw_general_duel_resultCard = sgs.CreateSkillCard {
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
        room:sendLog(msg1)
        room:sendLog(msg2)
        local winner = sgs.QVariant()
        local loser = sgs.QVariant()
        local winCard
        if (start > victim) or source:hasFlag("s4_txbw_general_duel_force_win") then
            winner:setValue(source)
            loser:setValue(target)
            winCard = room:getTag("s4_txbw_general_duel_s"):toInt()
            local msg = sgs.LogMessage()
            msg.type = "#s4_txbw_general_duel_Success"
            msg.from = source
            msg.to:append(target)
            room:sendLog(msg)
            room:setEmotion(source, "success")
        elseif start < victim or source:hasFlag("s4_txbw_general_duel_force_win") then
            winCard = room:getTag("s4_txbw_general_duel_v"):toInt()
            winner:setValue(target)
            loser:setValue(source)
            local msg = sgs.LogMessage()
            msg.type = "#s4_txbw_general_duel_Success"
            msg.from = target
            msg.to:append(source)
            room:sendLog(msg)
            room:setEmotion(target, "success")
            room:setPlayerFlag(source, "s4_txbw_general_duel_not_win")
        else
            room:setPlayerFlag(source, "s4_txbw_general_duel_not_win")
        end
        room:setTag("s4_txbw_general_duel_winner", winner)
        room:setTag("s4_txbw_general_duel_wincard", sgs.QVariant(winCard))
        room:setTag("s4_txbw_general_duel_loser", loser)
    end
}
s4_txbw_general_duel_finishCard = sgs.CreateSkillCard {
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
            local jink = room:askForCard(loser, "jink", "@s4_txbw_general_duel-jink:" .. winner:objectName(),
                sgs.QVariant(), sgs.Card_MethodResponse, nil, false, "", true)
            if jink then
            else
                local duel_damage = 1 + winner:getMark("s4_txbw_general_duel_damage") +
                    winner:getMark("s4_txbw_general_duel_damage-Clear")
                local damage = sgs.DamageStruct()
                damage.card = nil
                damage.from = winner
                damage.to = loser
                damage.reason = "s4_txbw_general_duel"
                damage.damage = duel_damage

                local winCard = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_wincard"):toInt())
                if winCard:isKindOf("ThunderSlash") or winCard:isKindOf("Lighting") then
                    damage.nature = sgs.DamageStruct_Thunder
                end
                if winCard:isKindOf("FireSlash") or winCard:isKindOf("FireAttack") then
                    damage.nature = sgs.DamageStruct_Fire
                end
                room:damage(damage)
            end
        end
    end
}

s4_txbw_general_duel = sgs.CreateViewAsSkill {
    name = "s4_txbw_general_duel&",
    n = 0,
    view_as = function(self, cards)
        if #cards == 0 then
            local card = s4_txbw_general_duelCard:clone()
            card:setSkillName("s4_txbw_general_duel_start")
            return card
        end
    end,
    enabled_at_play = function(self, player)
        return player:getMark("@s4_txbw_general") > 0 and player:usedTimes("#s4_txbw_general_duel_start") < 1 +
            player:getMark("s4_txbw_general_duel_extra") + player:getMark("s4_txbw_general_duel_extra-Clear")
    end
}

s4_txbw_general_duel_rule = sgs.CreateTriggerSkill {
    name = "s4_txbw_general_duel_rule&",
    global = true,
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.CardFinished },
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
                    use.from:removeTag("s4_txbw_general_duel")
                    use.to:first():removeTag("s4_txbw_general_duel")
                    room:setPlayerFlag(use.from, "-s4_txbw_general_duel_not_win")
                    room:setPlayerFlag(use.to:first(), "-s4_txbw_general_duel_not_win")
                    room:setPlayerFlag(use.from, "-s4_txbw_general_duel_force_win")
                    room:setPlayerFlag(use.to:first(), "-s4_txbw_general_duel_force_win")
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}

local skill = sgs.Sanguosha:getSkill("s4_txbw_general_gain")
if not skill then
    local skillList = sgs.SkillList()
    skillList:append(s4_txbw_general_gain)
    sgs.Sanguosha:addSkills(skillList)
end
local skill = sgs.Sanguosha:getSkill("s4_txbw_general")
if not skill then
    local skillList = sgs.SkillList()
    skillList:append(s4_txbw_general)
    sgs.Sanguosha:addSkills(skillList)
end
local skill = sgs.Sanguosha:getSkill("s4_txbw_disgeneral")
if not skill then
    local skillList = sgs.SkillList()
    skillList:append(s4_txbw_disgeneral)
    sgs.Sanguosha:addSkills(skillList)
end
local skill = sgs.Sanguosha:getSkill("s4_txbw_general_duel_rule")
if not skill then
    local skillList = sgs.SkillList()
    skillList:append(s4_txbw_general_duel_rule)
    sgs.Sanguosha:addSkills(skillList)
end
local skill = sgs.Sanguosha:getSkill("s4_txbw_general_duel")
if not skill then
    local skillList = sgs.SkillList()
    skillList:append(s4_txbw_general_duel)
    sgs.Sanguosha:addSkills(skillList)
end
local skill = sgs.Sanguosha:getSkill("s4_txbw_general_limit")
if not skill then
    local skillList = sgs.SkillList()
    skillList:append(s4_txbw_general_limit)
    sgs.Sanguosha:addSkills(skillList)
end
sgs.LoadTranslationTable {
    ["s4_txbw_general_gain"] = "武将",
    ["@s4_txbw_general"] = "武将",
    ["s4_txbw_disgeneral"] = "弃武从文",
    [":s4_txbw_disgeneral"] = "出牌阶段，你可以移除武将标签。若如此做，你不再是武将，失去所有和对决相关的技能。",
    ["s4_txbw_general_duel_rule"] = "武将規則",
    [":s4_txbw_general_duel_rule"] = "1.发起对决:\
    ①武将A指定一名目标B。\
    ②若B也为武将，执行犒赏:\
    若此时你有至少一张手牌，摸1张牌;\
    若此时你没有手牌，摸2张牌。\
    双方各将一张手牌背面向上置于桌面。这张牌称为对决牌。\
    无手牌的角色改为将牌堆顶的一张牌作为对决牌扣置。\
    根据双方的对决点数，判定对决胜负。\
若A的对决点数大于B的对决点数，视为A赢，B没赢，A执行胜利效果。\
若A的对决点数等于B的对决点数，视为A、B都没赢，不执行胜利效果。\
    ",
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
    ["s4_txbw_general_duel_start"] = "发起对决",
    ["#s4_txbw_general_duel_choose"] = "%from 和 %to 扣置对决牌",
    ["s4_txbw_general_duel_choose"] = "扣置对决牌",
    ["#s4_txbw_general_duel_show"] = "%from 和 %to 亮出对决牌",
    ["s4_txbw_general_duel_show"] = "亮出对决牌",
    ["#s4_txbw_general_duel_show_card"] = "%from 的对决牌为 %card ",
    ["#s4_txbw_general_duel_cal"] = "%from 和 %to 计算对决牌点数",
    ["s4_txbw_general_duel_cal"] = "计算对决牌点数",
    ["#s4_txbw_general_duel_cal_point"] = "%from 的对决牌点数为 %arg ",
    ["#s4_txbw_general_duel_result"] = "%from 和 %to 判定对决胜负。",
    ["s4_txbw_general_duel_result"] = "判定对决胜负",
    ["#s4_txbw_general_duel_result_point"] = "%from 的对决牌点数为 %arg ",
    ["#s4_txbw_general_duel_Success"] = "%from 在 %to 对决中获胜。",
    ["#s4_txbw_general_duel_finish"] = "%from 和 %to 执行对决胜利效果。",
    ["s4_txbw_general_duel_finish"] = "执行对决胜利效果",
    ["#s4_txbw_general_duel_cal_point_add"] = "%from 的技能 %arg 被触发，对决牌点数上升至 %arg2 点",

    ["@s4_txbw_general_duel-jink"] = " %src 对决中获胜，你需使用一张【闪】，否则受到 %src 对你造成的1点对决伤害。"

}

s4_txbw_xuchu = sgs.General(extension, "s4_txbw_xuchu", "wei", 4, true)

s4_txbw_luoyiBuff = sgs.CreateTriggerSkill {
    name = "#s4_txbw_luoyiBuff",
    frequency = sgs.Skill_Frequent,
    events = { sgs.DamageCaused, sgs.EventPhaseChanging },
    on_trigger = function(self, event, player, data, room)
        if event == sgs.DamageCaused then
            local damage = data:toDamage()
            if damage.chain or damage.transfer or (not damage.by_user) then
                return false
            end
            local reason = damage.reason
            if reason and reason == "s4_txbw_general_duel" then
                room:sendCompulsoryTriggerLog(player, "s4_txbw_luoyi", true)
                damage.damage = damage.damage + 1
                data:setValue(damage)
            end
        elseif event == sgs.EventPhaseChanging then
            local change = data:toPhaseChange()
            if change.to == sgs.Player_Start then
                room:setPlayerMark(player, "&s4_txbw_luoyi", 0)
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target and target:getMark("&s4_txbw_luoyi") > 0 and target:isAlive()
    end
}
s4_txbw_luoyi = sgs.CreateTriggerSkill {
    name = "s4_txbw_luoyi",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.EventPhaseChanging },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local change = data:toPhaseChange()
        if change.to == sgs.Player_Draw and not player:isSkipped(sgs.Player_Draw) and
            player:askForSkillInvoke(self:objectName()) then
            room:broadcastSkillInvoke(self:objectName())
            player:skip(change.to)
            local ids = room:showDrawPile(player, 3, self:objectName())

            room:fillAG(ids, player)
            room:clearAG(player)
            local max = 0
            for _, id in sgs.qlist(ids) do
                local card = sgs.Sanguosha:getCard(id);
                if card:getNumber() > max then
                    max = card:getNumber()
                end
            end
            local card_to_throw = sgs.IntList()
            local card_to_gotback = sgs.IntList()
            for _, id in sgs.qlist(ids) do
                local card = sgs.Sanguosha:getCard(id);
                if (card:isKindOf("Weapon") or card:getNumber() == max) then
                    card_to_gotback:append(id)
                else
                    if (room:getCardPlace(id) == sgs.Player_PlaceTable) then
                        card_to_throw:append(id)
                    end
                end
            end
            if (not card_to_throw:isEmpty()) then
                local dummy = dummyCard()
                for _, id in sgs.qlist(card_to_throw) do
                    dummy:addSubcard(id)
                end
                local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(),
                    "jianyan", nil)
                room:throwCard(dummy, reason, nil)
            end
            if (not card_to_gotback:isEmpty()) then
                local dummy = dummyCard()
                for _, id in sgs.qlist(card_to_gotback) do
                    dummy:addSubcard(id)
                end

                room:obtainCard(player, dummy)
            end
            room:addPlayerMark(player, "&" .. self:objectName())
        end
    end
}

s4_txbw_xuchu:addSkill("s4_txbw_general_gain")
--s4_txbw_xuchu:addSkill("s4_txbw_general")
s4_txbw_xuchu:addSkill(s4_txbw_luoyi)
s4_txbw_xuchu:addSkill(s4_txbw_luoyiBuff)
extension:insertRelatedSkills("s4_txbw_luoyi", "#s4_txbw_luoyiBuff")

sgs.LoadTranslationTable {
    ["s4_txbw_xuchu"] = "许褚",
    ["&s4_txbw_xuchu"] = "许褚",
    ["#s4_txbw_xuchu"] = "虎痴",
    ["~s4_txbw_xuchu"] = "",
    ["designer:s4_txbw_xuchu"] = "",
    ["cv:s4_txbw_xuchu"] = "",
    ["illustrator:s4_txbw_xuchu"] = "",

    ["s4_txbw_luoyi"] = "裸衣",
    [":s4_txbw_luoyi"] = "你可以跳过摸牌阶段。若如此做，亮出牌堆顶三张牌，然后获得其中点数最大的牌和武器牌，直到你的下回合开始，你的对决伤害+1。"

}

s4_txbw_dianwei = sgs.General(extension, "s4_txbw_dianwei", "wei", 4, true)

s4_txbw_feidang = sgs.CreateTriggerSkill {
    name = "s4_txbw_feidang",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.CardFinished },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_result" then
                    if player:hasFlag("s4_txbw_general_duel_not_win") and player:hasSkill(self:objectName()) then
                        if room:askForSkillInvoke(player, self:objectName(), ToQVData(winner)) then
                            if room:askForCard(player, "Weapon", "s4_txbw_feidang:" .. winner:objectName(),
                                    ToQVData(winner)) then
                            else
                                room:loseHp(player, 1)
                            end
                            local damage = sgs.DamageStruct()
                            damage.card = nil
                            damage.from = player
                            damage.to = winner
                            damage.reason = "s4_txbw_general_duel"
                            damage.damage = 1
                            room:damage(damage)
                            room:removeTag("s4_txbw_general_duel_wincard")
                            room:removeTag("s4_txbw_general_duel_winner")
                            room:removeTag("s4_txbw_general_duel_loser")
                        end
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}
s4_txbw_dianwei:addSkill("s4_txbw_general_gain")
s4_txbw_dianwei:addSkill(s4_txbw_feidang)
sgs.LoadTranslationTable {
    ["s4_txbw_dianwei"] = "典韦",
    ["&s4_txbw_dianwei"] = "典韦",
    ["#s4_txbw_dianwei"] = "淯水芳魂",
    ["~s4_txbw_dianwei"] = "",
    ["designer:s4_txbw_dianwei"] = "",
    ["cv:s4_txbw_dianwei"] = "",
    ["illustrator:s4_txbw_dianwei"] = "",

    ["s4_txbw_feidang"] = "飞当",
    [":s4_txbw_feidang"] = "若对决没赢，你可以失去1点体力或弃置一张武器牌。若如此做，该对决无效，你对对方造成1点对决伤害。"

}

s4_txbw_zhangliao = sgs.General(extension, "s4_txbw_zhangliao", "wei", 4, true)

s4_txbw_tuxiClear = sgs.CreateTriggerSkill {
    name = "#s4_txbw_tuxiClear",
    events = { sgs.EventPhaseChanging },
    on_trigger = function(self, event, player, data, room)
        if event == sgs.EventPhaseChanging then
            if data:toPhaseChange().to == sgs.Player_NotActive then
                for _, p in sgs.qlist(room:getAllPlayers()) do
                    if player:getMark("s4_txbw_tuxi" .. p:objectName()) > 0 then
                        room:setFixedDistance(player, p, -1);
                        room:setPlayerMark(player, "s4_txbw_tuxi" .. p:objectName(), 0)
                        room:setPlayerMark(p, "&s4_txbw_tuxi+to+#" .. player:objectName(), 0)
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}
s4_txbw_tuxi = sgs.CreateTriggerSkill {
    name = "s4_txbw_tuxi",
    events = { sgs.DrawNCards },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.DrawNCards then
            local targets = sgs.SPlayerList()
            for _, p in sgs.qlist(room:getOtherPlayers(player)) do
                if not p:isKongcheng() then
                    targets:append(p)
                end
            end
            if not targets:isEmpty() then
                local target = room:askForPlayerChosen(player, targets, self:objectName(), "s4_txbw_tuxi-invoke", true,
                    true)
                if target then
                    local card_id = room:askForCardChosen(player, target, "h", "s4_txbw_tuxi")
                    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, self:objectName())
                    room:moveCardTo(sgs.Sanguosha:getCard(card_id), player, sgs.Player_PlaceHand, reason)
                    local count = data:toInt()
                    data:setValue(count - 1)
                    room:setFixedDistance(player, target, 1);
                    room:setPlayerMark(player, self:objectName() .. target:objectName(), 1)
                    room:addPlayerMark(target, "&" .. self:objectName() .. "+to+#" .. player:objectName())
                end
            end
        end
    end
}
s4_txbw_husha = sgs.CreateTriggerSkill {
    name = "s4_txbw_husha",
    events = { sgs.PreCardUsed, sgs.EventPhaseChanging },
    on_trigger = function(self, event, player, data, room)
        if event == sgs.PreCardUsed then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_start" then
                    room:addPlayerMark(player, "s4_txbw_general_duel_slash-Clear")
                end
            end
        elseif event == sgs.EventPhaseChanging then
            local change = data:toPhaseChange()
            if change.to == sgs.Player_Play and not player:isSkipped(sgs.Player_Play) then
                room:setPlayerFlag(player, "s4_txbw_general_duel")
            end
        end
    end
}

s4_txbw_zhangliao:addSkill("s4_txbw_general_gain")
s4_txbw_zhangliao:addSkill(s4_txbw_tuxi)
s4_txbw_zhangliao:addSkill(s4_txbw_husha)
sgs.LoadTranslationTable {
    ["s4_txbw_zhangliao"] = "张辽",
    ["&s4_txbw_zhangliao"] = "张辽",
    ["#s4_txbw_zhangliao"] = "雷奔云谲",
    ["~s4_txbw_zhangliao"] = "",
    ["designer:s4_txbw_zhangliao"] = "",
    ["cv:s4_txbw_zhangliao"] = "",
    ["illustrator:s4_txbw_zhangliao"] = "",

    ["s4_txbw_tuxi"] = "突袭",
    [":s4_txbw_tuxi"] = "摸牌阶段，你可以少摸一张牌并获得一名其他角色一张手牌。若如此做，本回合你计算与其的距离视为1。",
    ["s4_txbw_tuxi-invoke"] = "你可以发动“突袭”，获得一名其他角色一张手牌",
    ["s4_txbw_husha"] = "虎杀",
    [":s4_txbw_husha"] = "锁定技，你发起的对决不计入【杀】的使用次数，你使用【杀】不受对决发起的限制。"

}

s4_txbw_pangde = sgs.General(extension, "s4_txbw_pangde", "wei", 4, true)

s4_txbw_juesi = sgs.CreateTriggerSkill {
    name = "s4_txbw_juesi",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.CardFinished },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_result" then
                    local winner = room:getTag("s4_txbw_general_duel_winner"):toPlayer()
                    local loser = room:getTag("s4_txbw_general_duel_loser"):toPlayer()
                    if winner and loser and winner:isAlive() and loser:isAlive() and loser:objectName() ==
                        player:objectName() and player:hasSkill(self:objectName()) then
                        local card_s = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_s"):toInt())
                        local card_v = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_v"):toInt())
                        local card
                        if player:hasFlag("s4_txbw_general_duel_victim") then
                            card = card_v
                        elseif player:hasFlag("s4_txbw_general_duel_start") then
                            card = card_s
                        end
                        if card then
                            room:obtainCard(player, card)
                            if player:hasFlag("s4_txbw_general_duel_start") and
                                player:usedTimes("#s4_txbw_general_duel") == 0 then
                                room:addPlayerMark(player, "s4_txbw_general_duel_extra-Clear")
                            end
                        end
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}
s4_txbw_pangde:addSkill("s4_txbw_general_gain")
s4_txbw_pangde:addSkill(s4_txbw_juesi)
s4_txbw_pangde:addSkill("mashu")
sgs.LoadTranslationTable {
    ["s4_txbw_pangde"] = "庞德",
    ["&s4_txbw_pangde"] = "庞德",
    ["#s4_txbw_pangde"] = "戎昭果毅",
    ["~s4_txbw_pangde"] = "",
    ["designer:s4_txbw_pangde"] = "",
    ["cv:s4_txbw_pangde"] = "",
    ["illustrator:s4_txbw_pangde"] = "",

    ["s4_txbw_juesi"] = "决死",
    [":s4_txbw_juesi"] = "锁定技，若对决没赢，你获得你的对决牌，若之为你出牌阶段发起的第一次对决，本回合你发起对决的次数限制+1。"

}

s4_txbw_dengai = sgs.General(extension, "s4_txbw_dengai", "wei", 4, true)
s4_txbw_motian = sgs.CreateTriggerSkill {
    name = "s4_txbw_motian",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.CardFinished },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_cal" then
                    local card_s = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_s"):toInt())
                    local card_v = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_v"):toInt())
                    local card
                    if player and player:hasSkill(self:objectName()) then
                        if player:hasFlag("s4_txbw_general_duel_victim") then
                            card = card_v
                        elseif player:hasFlag("s4_txbw_general_duel_start") then
                            card = card_s
                        end
                        if card then
                            local n = room:getTag("TurnLengthCount"):toInt();
                            room:addPlayerMark(player, "s4_txbw_general_duel", n)
                            local msg = sgs.LogMessage()
                            msg.type = "#s4_txbw_general_duel_cal_point_add"
                            msg.from = player
                            msg.arg = self:objectName()
                            msg.arg2 = player:getMark("s4_txbw_general_duel")
                            room:sendLog(msg)
                        end
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}
s4_txbw_zhenyueCard = sgs.CreateSkillCard {
    name = "s4_txbw_zhenyue",
    will_throw = true,
    target_fixed = true,
    on_use = function(self, room, source, targets)
        source:drawCards(source:getMark("&s4_txbw_zhenyue"))
        room:addPlayerMark(source, "&s4_txbw_zhenyue")
    end
}
s4_txbw_zhenyueVS = sgs.CreateOneCardViewAsSkill {
    name = "s4_txbw_zhenyue",
    -- response_or_use = true,
    view_filter = function(self, card)
        local x = sgs.Self:getMark("&s4_txbw_zhenyue")
        return card:getNumber() == x
    end,
    view_as = function(self, card)
        local cards = s4_txbw_zhenyueCard:clone()
        cards:addSubcard(card)
        return cards
    end,
    enabled_at_play = function(self, player)
        local n = 0
        local players = player:getAliveSiblings()
        players:append(player)
        for _, p in sgs.qlist(players) do
            if p:getMark("Global_TurnCount") > 0 then
                n = p:getMark("Global_TurnCount")
                break
            end
        end
        return player:canDiscard(player, "he") and player:getMark("&s4_txbw_zhenyue") <= n + 1
    end
}
s4_txbw_zhenyue = sgs.CreateTriggerSkill {
    name = "s4_txbw_zhenyue",
    view_as_skill = s4_txbw_zhenyueVS,
    events = { sgs.GameStart },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.GameStart then
            room:addPlayerMark(player, "&s4_txbw_zhenyue")
        end
    end
}
s4_txbw_dengai:addSkill("s4_txbw_general_gain")
s4_txbw_dengai:addSkill(s4_txbw_motian)
s4_txbw_dengai:addSkill(s4_txbw_zhenyue)
sgs.LoadTranslationTable {
    ["s4_txbw_dengai"] = "邓艾",
    ["&s4_txbw_dengai"] = "邓艾",
    ["#s4_txbw_dengai"] = "彼岸无明",
    ["~s4_txbw_dengai"] = "",
    ["designer:s4_txbw_dengai"] = "",
    ["cv:s4_txbw_dengai"] = "",
    ["illustrator:s4_txbw_dengai"] = "",

    ["s4_txbw_motian"] = "摩天",
    [":s4_txbw_motian"] = "锁定技，对决点数+X（X为轮次数）。",
    ["s4_txbw_zhenyue"] = "震岳",
    [":s4_txbw_zhenyue"] = "出牌阶段，若括号中的数字不大于轮次数，你可以弃置一张点数为（1）的牌，然后摸（1）张牌，并令括号中的数字+1。"

}

s4_txbw_caocao = sgs.General(extension, "s4_txbw_caocao$", "wei", 4, true)

s4_txbw_huibianCard = sgs.CreateSkillCard {
    name = "s4_txbw_huibian",
    filter = function(self, targets, to_select)
        if #targets == 0 then
            return to_select:getHp() > 1
        elseif #targets == 1 then
            return to_select:isWounded() and to_select:objectName() ~= #targets[1]:objectName()
        end
        return #targets < 2
    end,
    feasible = function(self, targets)
        return #targets == 2
    end,
    on_use = function(self, room, source, targets)
        local first = targets[1]
        local second = targets[2]
        local damage = sgs.DamageStruct()
        damage.from = source
        damage.to = first
        room:damage(damage)
        first:drawCards(2)
        local recover = sgs.RecoverStruct()
        recover.who = source
        recover.recover = 1
        room:recover(second, recover, true)
    end
}
s4_txbw_huibian = sgs.CreateZeroCardViewAsSkill {
    name = "s4_txbw_huibian",
    view_as = function(self, card)
        local s4_txbw_huibian_card = s4_txbw_huibianCard:clone()
        return s4_txbw_huibian_card
    end,
    enabled_at_play = function(self, player)
        return not player:hasUsed("#s4_txbw_huibian") and player:getAliveSiblings():length() > 0
    end
}
s4_txbw_hujia = sgs.CreateTriggerSkill {
    name = "s4_txbw_hujia$",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.PreCardUsed },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.PreCardUsed then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel" then
                    for _, to in sgs.qlist(use.to) do
                        if to:hasLordSkill(self:objectName()) then
                            local plist = room:getLieges("wei", to)
                            for _, p in sgs.list(plist) do
                                if room:askForSkillInvoke(p, self:objectName(), ToQVData(to)) then
                                    use.to:removeOne(to)
                                    use.to:append(p)
                                    data:setValue(use)
                                end
                            end
                        end
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}

s4_txbw_caocao:addSkill(s4_txbw_huibian)
s4_txbw_caocao:addSkill(s4_txbw_hujia)
s4_txbw_caocao:addSkill("hujia")


sgs.LoadTranslationTable {
    ["s4_txbw_caocao"] = "曹操",
    ["&s4_txbw_caocao"] = "曹操",
    ["#s4_txbw_caocao"] = "挟天负绝",
    ["~s4_txbw_caocao"] = "",
    ["designer:s4_txbw_caocao"] = "",
    ["cv:s4_txbw_caocao"] = "",
    ["illustrator:s4_txbw_caocao"] = "",

    ["s4_txbw_huibian"] = "挥鞭",
    [":s4_txbw_huibian"] = "出牌阶段限一次，你可以选择一名体力值大于1的角色和另一名已受伤的角色，你对前者造成1点伤害并令其摸两张牌，然后令后者回复1点体力。",
    ["s4_txbw_hujia"] = "护驾",
    [":s4_txbw_hujia"] = "主公技，魏势力角色可以替你出【闪】；魏武将可以替你成为对决目标。"

}

s4_txbw_yujin = sgs.General(extension, "s4_txbw_yujin", "wei", 4, true)

s4_txbw_yizhong = sgs.CreateTriggerSkill {
    name = "s4_txbw_yizhong",
    frequency = sgs.Skill_Compulsory,
    events = { sgs.CardEffected },
    on_trigger = function(self, event, player, data)
        local effect = data:toCardEffect()
        if effect.card and effect.card:isKindOf("Slash") and effect.card:isBlack() then
            player:getRoom():notifySkillInvoked(player, self:objectName())
            return true
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil and target:isAlive() and target:hasSkill(self:objectName()) and (target:getArmor() == nil)
    end
}
s4_txbw_yizhong_duel = sgs.CreateTriggerSkill {
    name = "#s4_txbw_yizhong",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.CardFinished },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_cal" then
                    local card_s = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_s"):toInt())
                    local card_v = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_v"):toInt())
                    local card
                    if player:hasFlag("s4_txbw_general_duel_victim") then
                        card = card_s
                    elseif player:hasFlag("s4_txbw_general_duel_start") then
                        card = card_v
                    end
                    if card and card:isBlack() then
                        local msg = sgs.LogMessage()
                        msg.type = "#s4_txbw_general_duel_cal_point_add"
                        msg.from = player
                        msg.arg = self:objectName()
                        msg.arg2 = player:getMark("s4_txbw_general_duel")
                        room:addPlayerMark(player, "s4_txbw_general_duel", player:getHp())
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}
s4_txbw_niansheng = sgs.CreateTriggerSkill {
    name = "s4_txbw_niansheng",
    events = { sgs.EnterDying },
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data, room)
        local target = room:getCurrentDyingPlayer()
        if not target then
            return false
        end
        for _, yujin in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
            if yujin:getMark("@s4_txbw_general") > 0 then
                if room:askForSkillInvoke(yujin, self:objectName(), ToQVData(target)) then
                    yujin:peiyin(self)
                    room:setPlayerMark(yujin, "@s4_txbw_general", 0)
                    room:addPlayerMark(target, "&s4_txbw_niansheng+to+#" .. yujin:objectName())
                    local recover = sgs.RecoverStruct()
                    recover.who = yujin
                    recover.recover = 1 - target:getHp()
                    room:recover(target, recover)
                end
            end
        end

        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}
s4_txbw_nianshengClear = sgs.CreateTriggerSkill {
    name = "#s4_txbw_nianshengClear",
    frequency = sgs.Skill_Compulsory,
    events = { sgs.DamageInflicted, sgs.EventPhaseStart },
    on_trigger = function(self, event, player, data, room)
        if event == sgs.DamageInflicted then
            local damage = data:toDamage()
            if damage.to and damage.to:isAlive() then
                for _, p in sgs.list(room:getAlivePlayers()) do
                    if damage.to:getMark("&s4_txbw_niansheng+to+#" .. p:objectName()) > 0 then
                        room:sendCompulsoryTriggerLog(p, "s4_txbw_niansheng")
                        local log = sgs.LogMessage()
                        log.type = "$DamageRevises2"
                        log.from = p
                        log.arg = damage.damage
                        log.arg3 = "normal_nature"
                        if damage.nature == sgs.DamageStruct_Fire then
                            log.arg3 = "fire_nature"
                        elseif damage.nature == sgs.DamageStruct_Thunder then
                            log.arg3 = "thunder_nature"
                        elseif damage.nature == sgs.DamageStruct_Ice then
                            log.arg3 = "ice_nature"
                        end
                        room:sendLog(log)
                        return true
                    end
                end
            end
        elseif event == sgs.EventPhaseStart then
            if player:getPhase() == sgs.Player_Start then
                for _, p in sgs.list(room:getAlivePlayers()) do
                    if player:getMark("&s4_txbw_niansheng+to+#" .. p:objectName()) > 0 then
                        room:setPlayerMark(player, "&s4_txbw_niansheng+to+#" .. p:objectName(), 0)
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}


s4_txbw_yujin:addSkill("s4_txbw_general_gain")
s4_txbw_yujin:addSkill(s4_txbw_yizhong)
s4_txbw_yujin:addSkill(s4_txbw_yizhong_duel)
extension:insertRelatedSkills("s4_txbw_yizhong", "#s4_txbw_yizhong_duel")
s4_txbw_yujin:addSkill(s4_txbw_niansheng)
s4_txbw_yujin:addSkill(s4_txbw_nianshengClear)
extension:insertRelatedSkills("s4_txbw_niansheng", "#s4_txbw_nianshengClear")
sgs.LoadTranslationTable {
    ["s4_txbw_yujin"] = "于禁",
    ["&s4_txbw_yujin"] = "于禁",
    ["#s4_txbw_yujin"] = "难终良将",
    ["~s4_txbw_yujin"] = "",
    ["designer:s4_txbw_yujin"] = "",
    ["cv:s4_txbw_yujin"] = "",
    ["illustrator:s4_txbw_yujin"] = "",

    ["s4_txbw_yizhong"] = "毅重",
    [":s4_txbw_yizhong"] = "锁定技，黑色【杀】对你无效。若对方对决牌为黑色，对决点数+X（X为你的体力值）。",
    ["s4_txbw_niansheng"] = "念生",
    [":s4_txbw_niansheng"] = "当一名角色进入濒死状态时，你可以移除武将标签并令其体力值回复至1，然后防止其受到的所有伤害直到其下回合开始。"

}

s4_txbw_simayi = sgs.General(extension, "s4_txbw_simayi", "wei", 3, true)

s4_txbw_jingzhe = sgs.CreateTriggerSkill {
    name = "s4_txbw_jingzhe",
    frequency = sgs.Skill_Compulsory,
    events = { sgs.DamageInflicted, sgs.GameStart, sgs.TurnStart },
    on_trigger = function(self, event, player, data, room)
        if event == sgs.DamageInflicted then
            local damage = data:toDamage()
            if damage.to and damage.to:isAlive() and damage.to:hasSkill(self:objectName()) then
                local n = 15
                for _, p in sgs.qlist(room:getAlivePlayers()) do
                    n = math.min(p:getSeat(), n)
                end
                if player:getSeat() == n then
                    local x = getRoundCount(room)
                    if x < 5 then
                        for _, simayi in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
                            if simayi:objectName() == damage.to:objectName() then
                                local ids = room:showDrawPile(simayi, 1, self:objectName())
                                local card_to_throw = sgs.IntList()
                                card_to_throw:append(ids:first())

                                if (not card_to_throw:isEmpty()) then
                                    local dc = dummyCard()
                                    dc:addSubcard(sgs.Sanguosha:getCard(card_to_throw:first()))
                                    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER,
                                        simayi:objectName(), "s4_txbw_jingzhe", nil)
                                    room:throwCard(dc, reason, nil)
                                end
                                if sgs.Sanguosha:getCard(ids:first()):isBlack() then
                                    damage.damage = damage.damage - 1
                                    damage.prevented = damage.damage < 1
                                    data:setValue(damage)
                                    if damage.damage < 1 then
                                        return true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        elseif event == sgs.TurnStart then
            local x = getRoundCount(room)
            if x > 5 then
                for _, simayi in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
                    room:handleAcquireDetachSkills(simayi, "s4_txbw_lianpo")
                end
            end
        elseif event == sgs.GameStart then
            local n = 15
            for _, p in sgs.qlist(room:getAlivePlayers()) do
                n = math.min(p:getSeat(), n)
            end
            if player:getSeat() == n and not room:getTag("ExtraTurn"):toBool() then
                for _, simayi in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
                    room:addPlayerMark(player, "Global_TurnCount")
                    if (room:getTag("TurnLengthCount") ~= nil) then
                        room:setTag("TurnLengthCount", ToQVData(room:getTag("TurnLengthCount"):toInt() + 1));
                    else
                        room:setTag("TurnLengthCount", 1)
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target and target:isAlive()
    end
}
s4_txbw_taohui = sgs.CreateTriggerSkill {
    name = "s4_txbw_taohui",
    events = { sgs.EventPhaseChanging },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local change = data:toPhaseChange()
        if change.to ~= sgs.Player_Play then
            return false
        end
        if player:isSkipped(sgs.Player_Play) then
            return false
        end
        if player:isSkipped(sgs.Player_Discard) then
            return false
        end
        local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(),
            "s4_txbw_taohui-invoke", true, true)
        if not target then
            return false
        end
        player:skip(sgs.Player_Play)
        player:skip(sgs.Player_Discard)
        room:setTag("s4_txbw_taohui", ToQVData(target))
        return false
    end
}
s4_txbw_taohuiGive = sgs.CreateTriggerSkill {
    name = "#s4_txbw_taohuiGive",
    events = { sgs.EventPhaseStart },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if room:getTag("s4_txbw_taohui") then
            local target = room:getTag("s4_txbw_taohui"):toPlayer()
            room:removeTag("s4_txbw_taohui")
            if target and target:isAlive() then
                local phslist = sgs.PhaseList()
                phslist:append(sgs.Player_Play)
                target:play(phslist)
                --target:play(sgs.Player_Play)
                local phslist2 = sgs.PhaseList()
                phslist2:append(sgs.Player_Discard)
                target:play(phslist2)
                --target:play(sgs.Player_Discard)
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target and (target:getPhase() == sgs.Player_NotActive)
    end,
    priority = 1
}

s4_txbw_lianpo = sgs.CreateTriggerSkill {
    name = "s4_txbw_lianpo",
    events = { sgs.EventPhaseChanging, sgs.EventAcquireSkill, sgs.GameStart },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.GameStart or (event == sgs.EventAcquireSkill and data:toString() == "s4_txbw_lianpo") then
            room:setPlayerMark(player, "&s4_txbw_lianpo", 1)
        else
            local change = data:toPhaseChange()
            if change.to ~= sgs.Player_NotActive then
                return false
            end
            local x = getRoundCount(room)
            if player:getMark("&s4_txbw_lianpo") <= x then
                local card = room:askForCard(player, ".|.|" .. player:getMark("&s4_txbw_lianpo"),
                    "@s4_txbw_lianpo:" .. player:getMark("&s4_txbw_lianpo"), data, sgs.Card_MethodDiscard)
                if card then
                    room:setTag("s4_txbw_lianpo", ToQVData(player))
                    room:addPlayerMark(player, "&s4_txbw_lianpo")
                end
            end
        end

        return false
    end
}
s4_txbw_lianpoGive = sgs.CreateTriggerSkill {
    name = "#s4_txbw_lianpoGive",
    events = { sgs.EventPhaseStart },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if room:getTag("s4_txbw_lianpo") then
            local target = room:getTag("s4_txbw_lianpo"):toPlayer()
            room:removeTag("s4_txbw_lianpo")
            if target and target:isAlive() then
                target:gainAnExtraTurn()
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target and (target:getPhase() == sgs.Player_NotActive)
    end,
    priority = 1
}

s4_txbw_simayi:addSkill(s4_txbw_jingzhe)
s4_txbw_simayi:addSkill(s4_txbw_taohui)
s4_txbw_simayi:addSkill(s4_txbw_taohuiGive)
extension:insertRelatedSkills("s4_txbw_taohui", "#s4_txbw_taohuiGive")
if not sgs.Sanguosha:getSkill("s4_txbw_lianpo") then
    s4_skillList:append(s4_txbw_lianpo)
end
if not sgs.Sanguosha:getSkill("#s4_txbw_lianpoGive") then
    s4_skillList:append(s4_txbw_lianpoGive)
end
extension:insertRelatedSkills("s4_txbw_lianpo", "#s4_txbw_lianpoGive")
s4_txbw_simayi:addRelateSkill("s4_txbw_lianpo")


sgs.LoadTranslationTable {
    ["s4_txbw_simayi"] = "司马懿",
    ["&s4_txbw_simayi"] = "司马懿",
    ["#s4_txbw_simayi"] = "时雨上方谷",
    ["~s4_txbw_simayi"] = "",
    ["designer:s4_txbw_simayi"] = "",
    ["cv:s4_txbw_simayi"] = "",
    ["illustrator:s4_txbw_simayi"] = "",

    ["s4_txbw_jingzhe"] = "惊蛰",
    [":s4_txbw_jingzhe"] = "锁定技，本局游戏轮次数+1。轮次数不大于5时，你受到伤害时从牌堆里亮出一张牌，若为黑色，此伤害-1；轮次数大于5时，你获得“连破”。",
    ["s4_txbw_taohui"] = "韬晦",
    [":s4_txbw_taohui"] = "你可以跳过出牌阶段和弃牌阶段，令一名其他角色依次执行一个出牌阶段和弃牌阶段。",
    ["s4_txbw_lianpo"] = "连破",
    [":s4_txbw_lianpo"] = "回合结束时，若括号中的数字不大于轮次数，你可以弃置一张点数为（1）的牌，然后开始一个新的回合，并令括号中的数字+1。"

}

s4_txbw_xuhuang = sgs.General(extension, "s4_txbw_xuhuang", "wei", 4, true)

s4_txbw_wanpo = sgs.CreateTriggerSkill {
    name = "s4_txbw_wanpo",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.CardFinished, sgs.DamageCaused },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_cal" then
                    local target = player:getTag("s4_txbw_general_duel"):toPlayer()

                    if target and not target:isWounded() then
                        local x = 0
                        for _, p in sgs.qlist(room:getAlivePlayers()) do
                            if target:inMyAttackRange(p) then
                                x = x + 1
                            end
                        end

                        room:addPlayerMark(player, "s4_txbw_general_duel", x)
                        local msg = sgs.LogMessage()
                        msg.type = "#s4_txbw_general_duel_cal_point_add"
                        msg.from = player
                        msg.arg = self:objectName()
                        msg.arg2 = player:getMark("s4_txbw_general_duel")
                        room:sendLog(msg)
                    end
                end
            end
        elseif event == sgs.DamageCaused then
            local damage = data:toDamage()
            if damage.chain or damage.transfer or (not damage.by_user) then
                return false
            end
            local reason = damage.reason
            if reason and reason == "s4_txbw_general_duel"
                and damage.from and RIGHT(self, player) and damage.from:objectName() == player:objectName()
                and damage.to and not damage.to:isWounded() then
                damage.damage = damage.damage + 1
                local log = sgs.LogMessage()
                log.type = "#skill_add_damage"
                log.from = damage.from
                log.to:append(damage.to)
                log.arg  = self:objectName()
                log.arg2 = damage.damage
                room:sendLog(log)
                data:setValue(damage)
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}

s4_txbw_yanglei = sgs.CreateTriggerSkill {
    name = "s4_txbw_yanglei",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.Damage },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.Damage then
            local damage = data:toDamage()
            if damage.to and damage.from and damage.from:isAlive() then
                for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
                    if p:distanceTo(damage.from) <= 1 then
                        local choicelist = "cancel"
                        choicelist = string.format("%s+%s", choicelist,
                            "s4_txbw_yanglei_recover=" .. damage.from:objectName())
                        choicelist = string.format("%s+%s", choicelist,
                            "s4_txbw_yanglei_draw=" .. damage.from:objectName())
                        local choice = room:askForChoice(p, "s4_txbw_yanglei", choicelist, data)
                        if choice ~= "cancel" then
                            if string.startsWith(choice, "s4_txbw_yanglei_recover") then
                                local recover = sgs.RecoverStruct()
                                recover.who = p

                                room:recover(damage.from, recover)
                            elseif string.startsWith(choice, "s4_txbw_yanglei_draw") then
                                damage.from:drawCards(2)
                            end

                            local card = sgs.Sanguosha:getCard(room:getNCards(1):first())
                            local supply_shortage = sgs.Sanguosha:cloneCard("supply_shortage", card:getSuit(),
                                card:getNumber())
                            supply_shortage:addSubcard(card)
                            supply_shortage:setSkillName("s4_txbw_yanglei")
                            supply_shortage:deleteLater()
                            room:useCard(sgs.CardUseStruct(supply_shortage, p, damage.from))
                        end
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}
s4_txbw_xuhuang:addSkill("s4_txbw_general_gain")
s4_txbw_xuhuang:addSkill(s4_txbw_wanpo)
s4_txbw_xuhuang:addSkill(s4_txbw_yanglei)

sgs.LoadTranslationTable {
    ["s4_txbw_xuhuang"] = "徐晃",
    ["&s4_txbw_xuhuang"] = "徐晃",
    ["#s4_txbw_xuhuang"] = "进驱襄樊",
    ["~s4_txbw_xuhuang"] = "",
    ["designer:s4_txbw_xuhuang"] = "",
    ["cv:s4_txbw_xuhuang"] = "",
    ["illustrator:s4_txbw_xuhuang"] = "",

    ["s4_txbw_wanpo"] = "完破",
    [":s4_txbw_wanpo"] = "锁定技，若对方未受伤，对决点数+X（X为其攻击范围内角色数），且你的对决伤害+1。",
    ["s4_txbw_yanglei"] = "佯垒",
    [":s4_txbw_yanglei"] = "每当你距离1以内的角色造成伤害后，你可以令其回复1点体力或摸两张牌，然后将牌堆顶的一张牌当【兵粮寸断】置于其判定区内。",
    ["s4_txbw_yanglei_recover"] = "令 %src 回复1点体力",
    ["s4_txbw_yanglei_draw"] = "令 %src 摸两张牌",

}

s4_txbw_caoren = sgs.General(extension, "s4_txbw_caoren", "wei", 4, true)

s4_txbw_jushou = sgs.CreatePhaseChangeSkill {
    name = "s4_txbw_jushou",

    on_phasechange = function(self, player)
        local room = player:getRoom()
        if player:getPhase() == sgs.Player_Finish then
            local target = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(),
                "s4_txbw_jushou-invoke", true, true)
            if target then
                local x = 2
                if player:hasFlag("s4_txbw_general_duel") and player:hasFlag("s4_txbw_general_duel_lose") then
                    x = 3
                end
                target:drawCards(x)
                player:turnOver()
            end
        end
    end
}
s4_txbw_jushouClear = sgs.CreateTriggerSkill {
    name = "#s4_txbw_jushouClear",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.CardFinished },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_result" then
                    local winner = room:getTag("s4_txbw_general_duel_winner"):toPlayer()
                    local loser = room:getTag("s4_txbw_general_duel_loser"):toPlayer()
                    if ((winner and loser and winner:isAlive() and loser:isAlive() and loser:objectName() ==
                            player:objectName()) or (not winner and not loser)) and player:hasSkill("s4_txbw_jushou") then
                        room:setPlayerFlag(player, "s4_txbw_general_duel_lose")
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}

s4_txbw_chiliVS = sgs.CreateViewAsSkill {
    name = "s4_txbw_chili",
    n = 0,
    view_as = function(self, cards)
        local c = sgs.Sanguosha:cloneCard("nullification")
        c:setSkillName("s4_txbw_chili")
        return c
    end,
    enabled_at_play = function(self, player)
        return false
    end,
    enabled_at_response = function(self, player, pattern)
        if pattern ~= "nullification" then
            return
        end
        return player:getMark("@s4_txbw_general") > 0
    end,
    enabled_at_nullification = function(self, player)
        return player:getMark("@s4_txbw_general") > 0
    end
}
s4_txbw_chili = sgs.CreateTriggerSkill {
    name = "s4_txbw_chili",
    events = { sgs.TurnedOver, sgs.CardUsed },
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = s4_txbw_chiliVS,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.TurnedOver then
            if not player:faceUp() then
                return false
            end
            if not room:askForSkillInvoke(player, self:objectName()) then
                return false
            end
            room:setPlayerMark(player, "@s4_txbw_general", 1)

            local targets = sgs.SPlayerList()
            for _, p in sgs.qlist(room:getAlivePlayers()) do
                if player:canDiscard(p, "je") then
                    targets:append(p)
                end
            end

            if targets:isEmpty() then
                return false
            end
            local to_discard = room:askForPlayerChosen(player, targets, self:objectName(), "@s4_txbw_chili-discard",
                true)
            if to_discard then
                local id = room:askForCardChosen(player, to_discard, "ej", self:objectName(), false,
                    sgs.Card_MethodDiscard)
                room:throwCard(id, to_discard, player)
            end
        elseif (event == sgs.CardUsed) then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("Nullification") and use.card:getSkillName() == self:objectName() then
                room:setPlayerMark(player, "@s4_txbw_general", 0)
                local list = use.no_offset_list
                table.insert(list, "_ALL_TARGETS")
                use.no_offset_list = list
                data:setValue(use)
            end
        end

        return false
    end
}

s4_txbw_caoren:addSkill("s4_txbw_general_gain")
s4_txbw_caoren:addSkill(s4_txbw_jushou)
s4_txbw_caoren:addSkill(s4_txbw_jushouClear)
extension:insertRelatedSkills("s4_txbw_jushou", "#s4_txbw_jushouClear")
s4_txbw_caoren:addSkill(s4_txbw_chili)

sgs.LoadTranslationTable {
    ["s4_txbw_caoren"] = "曹仁",
    ["&s4_txbw_caoren"] = "曹仁",
    ["#s4_txbw_caoren"] = "天将临城",
    ["~s4_txbw_caoren"] = "",
    ["designer:s4_txbw_caoren"] = "",
    ["cv:s4_txbw_caoren"] = "",
    ["illustrator:s4_txbw_caoren"] = "",

    ["s4_txbw_jushou"] = "据守",
    [":s4_txbw_jushou"] = "结束阶段，你可以翻面并令一名角色摸两张牌，若你该回合发起的对决没赢，改为摸三张牌。",
    ["s4_txbw_chili"] = "饬厉",
    [":s4_txbw_chili"] = "你可以扣置武将标签并视为使用一张无法被抵消的【无懈可击】。当你从背面翻至正面时，你可以重置武将标签并弃置场上一张牌。"

}

s4_txbw_zhanghe = sgs.General(extension, "s4_txbw_zhanghe", "wei", 4, true)

s4_txbw_yishi = sgs.CreateTriggerSkill {
    name = "s4_txbw_yishi",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.CardFinished },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") and RIGHT(self, player) then
                if use.card:getSkillName() == "s4_txbw_general_duel_choose" then
                    local card_v = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_v"):toInt())
                    local card_s = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_s"):toInt())
                    if room:askForSkillInvoke(player, self:objectName()) then
                        room:removeTag("s4_txbw_general_duel_v")
                        room:removeTag("s4_txbw_general_duel_s")
                        room:setTag("s4_txbw_general_duel_s", sgs.QVariant(card_v:getId()))
                        room:setTag("s4_txbw_general_duel_v", sgs.QVariant(card_s:getId()))
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}

s4_txbw_zhanghe:addSkill("s4_txbw_general_gain")
s4_txbw_zhanghe:addSkill(s4_txbw_yishi)

sgs.LoadTranslationTable {
    ["s4_txbw_zhanghe"] = "张郃",
    ["&s4_txbw_zhanghe"] = "张郃",
    ["#s4_txbw_zhanghe"] = "弹指千钧",
    ["~s4_txbw_zhanghe"] = "",
    ["designer:s4_txbw_zhanghe"] = "",
    ["cv:s4_txbw_zhanghe"] = "",
    ["illustrator:s4_txbw_zhanghe"] = "",

    ["s4_txbw_yishi"] = "易势",
    [":s4_txbw_yishi"] = "对决牌扣置后，你可以与对方交换之。",
    ["s4_txbw_qiaobian"] = "巧变",
    [":s4_txbw_qiaobian"] = "出牌阶段限X次，你可以交换两名角色相同区域里一张牌（X为你已损失的体力值）。"

}

s4_txbw_yuejin = sgs.General(extension, "s4_txbw_yuejin", "wei", 4, true)

s4_txbw_hongwu = sgs.CreateTriggerSkill {
    name = "s4_txbw_hongwu",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.CardFinished },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_start" then
                    if use.from and use.from:isAlive() then
                        for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
                            local card = room:askForCard(p, ".Basic", self:objectName(), ToQVData(use.from),
                                sgs.Card_MethodDiscard,
                                p,
                                false, "@s4_txbw_hongwu", true)
                            if card then
                                room:setPlayerMark(use.from, "&" .. self:objectName() .. "+to+#" .. p:objectName(),
                                    card:getNumber())
                            end
                        end
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}
s4_txbw_hongwuClear = sgs.CreateTriggerSkill {
    name = "#s4_txbw_hongwuClear",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.CardFinished },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_cal" then
                    for _, p in sgs.qlist(room:findPlayersBySkillName("s4_txbw_hongwu")) do
                        if player:getMark("&s4_txbw_hongwu+to+#" .. p:objectName()) > 0 then
                            room:sendCompulsoryTriggerLog(p, "s4_txbw_hongwu")

                            room:addPlayerMark(player, "s4_txbw_general_duel",
                                player:getMark("&s4_txbw_hongwu+to+#" .. p:objectName()))
                            room:setPlayerMark(player, "&s4_txbw_hongwu+to+#" .. p:objectName(), 0)
                            local msg = sgs.LogMessage()
                            msg.type = "#s4_txbw_general_duel_cal_point_add"
                            msg.from = player
                            msg.arg = self:objectName()
                            msg.arg2 = player:getMark("s4_txbw_general_duel")
                            room:sendLog(msg)
                        end
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}


s4_txbw_xiaoguo = sgs.CreatePhaseChangeSkill {
    name = "s4_txbw_xiaoguo",
    frequency = sgs.Skill_NotFrequent,
    on_phasechange = function(self, player)
        if player:getPhase() == sgs.Player_Finish then
            local room = player:getRoom()
            if room:askForSkillInvoke(player, self:objectName()) then
                room:showAllCards(player)
                local can_invoke = true
                local cards = player:getHandcards()
                for _, card in sgs.qlist(cards) do
                    if card:isKindOf("BasicCard") then
                        can_invoke = false
                        break
                    end
                end
                if can_invoke then
                    if player:getHandcardNum() < player:getMaxHp() then
                        player:drawCards(player:getMaxHp() - player:getHandcardNum())
                    end
                end
            end
        end
        return false
    end
}

s4_txbw_yuejin:addSkill("s4_txbw_general_gain")
s4_txbw_yuejin:addSkill(s4_txbw_hongwu)
s4_txbw_yuejin:addSkill(s4_txbw_hongwuClear)
extension:insertRelatedSkills("s4_txbw_hongwu", "#s4_txbw_hongwuClear")
s4_txbw_yuejin:addSkill(s4_txbw_xiaoguo)

sgs.LoadTranslationTable {
    ["s4_txbw_yuejin"] = "乐进",
    ["&s4_txbw_yuejin"] = "乐进",
    ["#s4_txbw_yuejin"] = "奋强突固",
    ["~s4_txbw_yuejin"] = "",
    ["designer:s4_txbw_yuejin"] = "",
    ["cv:s4_txbw_yuejin"] = "",
    ["illustrator:s4_txbw_yuejin"] = "",

    ["s4_txbw_hongwu"] = "弘武",
    [":s4_txbw_hongwu"] = "一名角色发起对决后，你可以弃置一张基本牌。若如此做，其本次对决点数+X（X为你弃置牌的点数）。",

    ["s4_txbw_xiaoguo"] = "骁果",
    [":s4_txbw_xiaoguo"] = "结束阶段，你可以展示所有手牌，若不含基本牌，你将手牌补至体力上限。",


}

s4_txbw_wei_guanyu = sgs.General(extension, "s4_txbw_wei_guanyu", "wei", 5, true)

s4_txbw_shenwei = sgs.CreateTriggerSkill {
    name = "s4_txbw_shenwei",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.PreCardUsed, sgs.CardFinished },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.PreCardUsed then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") and RIGHT(self, player) then
                if use.card:getSkillName() == "s4_txbw_general_duel_show" then
                    local target = player:getTag("s4_txbw_general_duel"):toPlayer()

                    local dest = sgs.QVariant()
                    dest:setValue(target)
                    local choice = room:askForChoice(player, self:objectName(), "red+black+cancel", dest)
                    if choice ~= "cancel" then
                        room:setPlayerMark(player, "&" .. self:objectName() .. "+" .. choice, 1)
                    end
                end
            end
        elseif event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_show" then
                    local card_s = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_s"):toInt())
                    local card_v = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_v"):toInt())
                    local card
                    if player and player:hasSkill(self:objectName()) then
                        if player:hasFlag("s4_txbw_general_duel_victim") then
                            card = card_v
                        elseif player:hasFlag("s4_txbw_general_duel_start") then
                            card = card_s
                        end
                        if card then
                            if (card:isRed() and player:getMark("&" .. self:objectName() .. "+red")) or
                                (card:isBlack() and player:getMark("&" .. self:objectName() .. "+black")) then
                                room:sendCompulsoryTriggerLog(player, self:objectName())
                                room:setPlayerFlag(player, "s4_txbw_general_duel_force_win")
                                room:setPlayerMark(player, "&" .. self:objectName() .. "+red", 0)
                                room:setPlayerMark(player, "&" .. self:objectName() .. "+black", 0)
                            end
                        end
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}

s4_txbw_tianjian = sgs.CreateTriggerSkill {
    name = "s4_txbw_tianjian",
    frequency = sgs.Skill_Compulsory,
    events = { sgs.CardFinished },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_result" then
                    if not player:hasFlag("s4_txbw_general_duel_not_win") and player:hasSkill(self:objectName()) then
                        room:sendCompulsoryTriggerLog(player, self:objectName())
                        local target = player:getTag("s4_txbw_general_duel"):toPlayer()

                        if target and target:isAlive() then
                            local result = room:askForChoice(target, self:objectName(), "hp+maxhp")
                            if result == "hp" then
                                room:loseHp(target)
                            else
                                room:loseMaxHp(target)
                            end
                            room:removeTag("s4_txbw_general_duel_wincard")
                            room:removeTag("s4_txbw_general_duel_winner")
                            room:removeTag("s4_txbw_general_duel_loser")
                        end
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}

s4_txbw_wei_guanyu:addSkill("s4_txbw_general_gain")
s4_txbw_wei_guanyu:addSkill(s4_txbw_shenwei)
s4_txbw_wei_guanyu:addSkill(s4_txbw_tianjian)
sgs.LoadTranslationTable {
    ["s4_txbw_wei_guanyu"] = "关羽",
    ["&s4_txbw_wei_guanyu"] = "关羽",
    ["#s4_txbw_wei_guanyu"] = "义薄云天",
    ["~s4_txbw_wei_guanyu"] = "",
    ["designer:s4_txbw_wei_guanyu"] = "",
    ["cv:s4_txbw_wei_guanyu"] = "",
    ["illustrator:s4_txbw_wei_guanyu"] = "",

    ["s4_txbw_shenwei"] = "神威",
    [":s4_txbw_shenwei"] = "对决牌亮出前，你可以声明一种颜色。对方的对决牌亮出后，若颜色与之相同，视为你已在对决中获胜。",

    ["s4_txbw_tianjian"] = "天鉴",
    [":s4_txbw_tianjian"] = "锁定技，对决获胜时，改为令对方选择一项：失去1点体力；减1点体力上限。",


}


s4_txbw_guohuai = sgs.General(extension, "s4_txbw_guohuai", "wei", 4, true)


s4_txbw_zhisun = sgs.CreateTriggerSkill {
    name = "s4_txbw_zhisun",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.CardFinished },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_show" then
                    local card_s = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_s"):toInt())
                    local card_v = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_v"):toInt())
                    local card
                    if player and player:hasSkill(self:objectName()) then
                        if player:hasFlag("s4_txbw_general_duel_victim") then
                            card = card_v
                        elseif player:hasFlag("s4_txbw_general_duel_start") then
                            card = card_s
                        end
                        if card then
                            if not player:isNude() then
                                local new_card = room:askForCard(player, ".|.|.|hand", "s4_txbw_zhisun", sgs.QVariant(),
                                    sgs.Card_MethodNone,
                                    player,
                                    false, "s4_txbw_general_duel", true)
                                if new_card then
                                    if player:hasFlag("s4_txbw_general_duel_victim") then
                                        room:removeTag("s4_txbw_general_duel_v")
                                        room:setTag("s4_txbw_general_duel_v", sgs.QVariant(new_card:getId()))
                                    elseif player:hasFlag("s4_txbw_general_duel_start") then
                                        room:removeTag("s4_txbw_general_duel_s")
                                        room:setTag("s4_txbw_general_duel_s", sgs.QVariant(new_card:getId()))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}


s4_txbw_guohuai:addSkill("s4_txbw_general_gain")
s4_txbw_guohuai:addSkill(s4_txbw_zhisun)
s4_txbw_guohuai:addSkill("jingce")


sgs.LoadTranslationTable {
    ["s4_txbw_guohuai"] = "郭淮",
    ["&s4_txbw_guohuai"] = "郭淮",
    ["#s4_txbw_guohuai"] = "垂问秦雍",
    ["~s4_txbw_guohuai"] = "",
    ["designer:s4_txbw_guohuai"] = "",
    ["cv:s4_txbw_guohuai"] = "",
    ["illustrator:s4_txbw_guohuai"] = "",

    ["s4_txbw_zhisun"] = "止损",
    [":s4_txbw_zhisun"] = "对决牌亮出后，你可以打出一张牌替换之。",


}


s4_txbw_zhangfei = sgs.General(extension, "s4_txbw_zhangfei", "shu", 4, true)

s4_txbw_paoxiao = sgs.CreateTriggerSkill {
    name = "s4_txbw_paoxiao",
    frequency = sgs.Skill_Compulsory,
    events = { sgs.CardsMoveOneTime },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardsMoveOneTime then
            local move = data:toMoveOneTime()
            if (move.from and (move.from:objectName() == player:objectName()) and (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip))) and not (move.to and (move.to:objectName() == player:objectName() and (move.to_place == sgs.Player_PlaceHand or move.to_place == sgs.Player_PlaceEquip))) then
                room:addPlayerMark(player, "s4_txbw_paoxiao-Clear", move.card_ids:length())
                if player:getMark("s4_txbw_paoxiao-Clear") >= player:getHp() then
                    room:setPlayerMark(player, "&s4_txbw_paoxiao-Clear", 1)
                    room:addPlayerMark(player, "s4_txbw_general_duel_extra-Clear")
                    room:sendCompulsoryTriggerLog(player, self:objectName())
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:isAlive()
            and target:hasSkill(self:objectName())
            and target:getPhase() == sgs.Player_Play
            and target:getMark("&s4_txbw_paoxiao-Clear") == 0
    end
}


s4_txbw_duanhe = sgs.CreateTriggerSkill {
    name = "s4_txbw_duanhe",
    frequency = sgs.Skill_Compulsory,
    events = { sgs.CardFinished, sgs.EventLoseSkill, sgs.CardsMoveOneTime },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_show" then
                    local card_s = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_s"):toInt())
                    local card_v = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_v"):toInt())
                    local card
                    if player and player:hasSkill(self:objectName()) then
                        if player:hasFlag("s4_txbw_general_duel_victim") then
                            card = card_v
                        elseif player:hasFlag("s4_txbw_general_duel_start") then
                            card = card_s
                        end
                        if card then
                            for _, p in sgs.qlist(room:getOtherPlayers(player)) do
                                room:setPlayerCardLimitation(p, "use,response", ".|" .. card:getSuitString() .. "|.|.|",
                                    true)
                            end
                            room:setPlayerMark(player, "&" .. self:objectName() .. "+" .. card:getSuitString() ..
                                "+-Clear", 1)
                        end
                    end
                end
            end
        elseif event == sgs.EventLoseSkill
        then
            if data:toString() == "s4_txbw_duanhe"
            then
                for _, mark in sgs.list(player:getMarkNames()) do
                    if string.find(mark, "s4_txbw_duanhe") and player:getMark(mark) > 0 then
                        local suit = mark:split("+")[2]
                        for _, p in sgs.qlist(room:getOtherPlayers(player)) do
                            local hw = sgs.CardList()
                            for _, c in sgs.list(player:getHandcards()) do
                                if c:getSuitString() == suit or c:getSkillName() == "s4_txbw_duanhe"
                                then
                                    hw:append(c)
                                end
                            end
                            if hw:length() > 0
                            then
                                room:filterCards(p, hw, true)
                                room:removePlayerCardLimitation(p, "use,response", ".|" .. suit .. "|.|.|")
                            end
                        end
                    end
                end
            end
        else
            for _, mark in sgs.list(player:getMarkNames()) do
                if string.find(mark, "s4_txbw_duanhe") and player:getMark(mark) > 0 then
                    local suit = mark:split("+")[2]
                    for _, p in sgs.qlist(room:getOtherPlayers(player)) do
                        local hw = sgs.CardList()
                        for _, c in sgs.list(player:getHandcards()) do
                            if c:getSuitString() == suit or c:getSkillName() == "s4_txbw_duanhe"
                            then
                                hw:append(c)
                            end
                        end
                        if hw:length() > 0
                        then
                            for _, c in sgs.list(hw) do
                                --local toc = sgs.Sanguosha:cloneCard(can, c:getSuit(), c:getNumber())
                                --toc:setSkillName("jl_sstj")
                                --local wrap = sgs.Sanguosha:getWrappedCard(c:getEffectiveId())
                                --wrap:takeOver(toc)

                                local id = c:getEffectiveId()
                                local new_card = sgs.Sanguosha:getWrappedCard(id)
                                new_card:setSkillName(self:objectName())
                                new_card:setNumber(1)
                                new_card:setModified(true)
                                room:notifyUpdateCard(player, c:getEffectiveId(), wrap)
                            end
                            --[[local toc = sgs.Sanguosha:cloneCard("slash", 2, c:getNumber())
                            toc:setSkillName("s4_txbw_duanhe")
                            local wrap = sgs.Sanguosha:getWrappedCard(c:getEffectiveId())
                            wrap:takeOver(toc)
                            room:notifyUpdateCard(player, c:getEffectiveId(), wrap)]]
                        end
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}

s4_txbw_zhangfei:addSkill("s4_txbw_general_gain")
--s4_txbw_zhangfei:addSkill(s4_txbw_paoxiao)
--s4_txbw_zhangfei:addSkill(s4_txbw_duanhe)


sgs.LoadTranslationTable {
    ["s4_txbw_zhangfei"] = "张飞",
    ["&s4_txbw_zhangfei"] = "张飞",
    ["#s4_txbw_zhangfei"] = "万夫之雄",
    ["~s4_txbw_zhangfei"] = "",
    ["designer:s4_txbw_zhangfei"] = "",
    ["cv:s4_txbw_zhangfei"] = "",
    ["illustrator:s4_txbw_zhangfei"] = "",

    ["s4_txbw_paoxiao"] = "咆哮",
    [":s4_txbw_paoxiao"] = "锁定技，若你于出牌阶段失去的牌数不小于你的体力值，本回合发起对决的次数限制+1。",

    ["s4_txbw_duanhe"] = "断喝",
    [":s4_txbw_duanhe"] = "锁定技，对决牌亮出后，直到该回合结束，其他角色与之相同花色的牌点数均视为1，且无法使用或打出这些牌。",

}


s4_txbw_guanyu = sgs.General(extension, "s4_txbw_guanyu", "shu", 5, true)


s4_txbw_wusheng = sgs.CreateTriggerSkill {
    name = "s4_txbw_wusheng",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.CardFinished },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_cal" then
                    local card_s = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_s"):toInt())
                    local card_v = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_v"):toInt())
                    local card
                    if player:hasFlag("s4_txbw_general_duel_victim") then
                        card = card_v
                    elseif player:hasFlag("s4_txbw_general_duel_start") then
                        card = card_s
                    end
                    local target = player:getTag("s4_txbw_general_duel"):toPlayer()
                    if card and card:isRed() and target then
                        room:addPlayerMark(player, "s4_txbw_general_duel", target:getHp())
                        local msg = sgs.LogMessage()
                        msg.type = "#s4_txbw_general_duel_cal_point_add"
                        msg.from = player
                        msg.arg = self:objectName()
                        msg.arg2 = player:getMark("s4_txbw_general_duel")
                        room:sendLog(msg)
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}

s4_txbw_yijue = sgs.CreateTriggerSkill {
    name = "s4_txbw_yijue",
    frequency = sgs.Skill_Compulsory,
    events = { sgs.CardFinished },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_result" then
                    if not player:hasFlag("s4_txbw_general_duel_not_win") and player:hasSkill(self:objectName()) then
                        local target = player:getTag("s4_txbw_general_duel"):toPlayer()

                        if target and target:isAlive() then
                            if room:askForSkillInvoke(player, self:objectName()) then
                                if target:getHp() >= player:getHp() then
                                    room:setPlayerMark(target, "&" .. self:objectName() .. "+to+#" .. player:objectName(),
                                        1)
                                    room:addPlayerMark(target, "@skill_invalidity")
                                    room:setPlayerCardLimitation(target, "use,response", ".|.|.|hand", false)
                                else
                                    local recover = sgs.RecoverStruct()
                                    recover.who = player
                                    room:recover(target, recover)
                                end
                            end
                        end
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}
s4_txbw_yijueClear = sgs.CreateTriggerSkill {
    name = "#s4_txbw_yijueClear",
    frequency = sgs.Skill_Frequent,
    events = { sgs.EventPhaseChanging },
    on_trigger = function(self, event, player, data, room)
        if event == sgs.EventPhaseChanging then
            local change = data:toPhaseChange()
            if change.to == sgs.Player_NotActive then
                for _, p in sgs.qlist(room:getAlivePlayers()) do
                    if p:getMark("&s4_txbw_yijue+to+#" .. player:objectName()) > 0 then
                        room:setPlayerMark(p, "&s4_txbw_yijue+to+#" .. player:objectName(), 0)
                        room:setPlayerMark(p, "@skill_invalidity", 0)
                        room:removePlayerCardLimitation(p, "use,response", ".|.|.|hand")
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}


s4_txbw_huwei = sgs.CreateTriggerSkill {
    name = "s4_txbw_huwei",
    frequency = sgs.Skill_Frequent,
    events = { sgs.PreCardUsed },
    priority = -1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.PreCardUsed then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_finish" then
                    if not player:hasFlag("s4_txbw_general_duel_not_win") and player:hasSkill(self:objectName()) then
                        local target = player:getTag("s4_txbw_general_duel"):toPlayer()

                        if target and target:isAlive() then
                            local result = room:askForChoice(target, self:objectName(),
                                "s4_txbw_huwei_fire+s4_txbw_huwei_thunder+cancel")
                            if result ~= "cancel" then
                                --local winCard = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_wincard"):toInt())
                                room:removeTag("s4_txbw_general_duel_wincard")
                                if result == "s4_txbw_huwei_fire" then
                                    local fire_slash = sgs.Sanguosha:cloneCard("fire_slash")
                                    room:setTag("s4_txbw_general_duel_wincard", ToQVData(fire_slash:getEffectiveId()))
                                elseif result == "s4_txbw_huwei_thunder" then
                                    local thunder_slash = sgs.Sanguosha:cloneCard("thunder_slash")
                                    room:setTag("s4_txbw_general_duel_wincard", ToQVData(thunder_slash:getEffectiveId()))
                                end
                            end
                        end
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}


s4_txbw_guanyu:addSkill("s4_txbw_general_gain")
s4_txbw_guanyu:addSkill(s4_txbw_wusheng)
s4_txbw_guanyu:addSkill(s4_txbw_yijue)
s4_txbw_guanyu:addSkill(s4_txbw_yijueClear)
extension:insertRelatedSkills("s4_txbw_yijue", "#s4_txbw_yijueClear")
s4_txbw_guanyu:addSkill(s4_txbw_huwei)

sgs.LoadTranslationTable {
    ["s4_txbw_guanyu"] = "关羽",
    ["&s4_txbw_guanyu"] = "关羽",
    ["#s4_txbw_guanyu"] = "威震华夏",
    ["~s4_txbw_guanyu"] = "",
    ["designer:s4_txbw_guanyu"] = "",
    ["cv:s4_txbw_guanyu"] = "",
    ["illustrator:s4_txbw_guanyu"] = "",

    ["s4_txbw_wusheng"] = "武圣",
    [":s4_txbw_wusheng"] = "锁定技，你的对决牌若为红色，对决点数+X（X为对方体力值）。",

    ["s4_txbw_yijue"] = "义绝",
    [":s4_txbw_yijue"] = "对决获胜时，若对方体力值不小于你，你可以令其非锁定技失效且无法使用或打出牌直到当前回合结束；若对方体力值不大于你，你可以改为令其回复1点体力。",

    ["s4_txbw_huwei"] = "虎威",
    [":s4_txbw_huwei"] = "你可以令你的对决伤害为火属性或雷属性。",
    ["s4_txbw_huwei_thunder"] = "虎威:雷属性",
    ["s4_txbw_huwei_fire"] = "虎威:火属性",

}


s4_txbw_zhaoyun = sgs.General(extension, "s4_txbw_zhaoyun", "shu", 4, true)

s4_txbw_longdan = sgs.CreateTriggerSkill {
    name = "s4_txbw_longdan",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.CardFinished },
    priority = -3,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card and use.card:isKindOf("SkillCard") then
                if use.card:getSkillName() == "s4_txbw_general_duel_cal" then
                    local card_s = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_s"):toInt())
                    local card_v = sgs.Sanguosha:getCard(room:getTag("s4_txbw_general_duel_v"):toInt())
                    local card
                    if player:hasFlag("s4_txbw_general_duel_victim") then
                        card = card_v
                    elseif player:hasFlag("s4_txbw_general_duel_start") then
                        card = card_s
                    end
                    local target = room:getTag("s4_txbw_general_duel"):toPlayer()
                    if card and target then
                        if room:askForSkillInvoke(player, self:objectName()) then
                            --room:addPlayerMark(player, "s4_txbw_general_duel", target:getHp())
                            local start_point = player:getMark("s4_txbw_general_duel")
                            local victim_point = target:getMark("s4_txbw_general_duel")
                            room:setPlayerMark(player, "s4_txbw_general_duel", victim_point)
                            room:setPlayerMark(target, "s4_txbw_general_duel", start_point)
                            room:loseMaxHp(player, 1)
                        end
                    end
                end
            end
        end
        return false
    end,
    can_trigger = function(self, target)
        return target
    end
}

s4_txbw_nilinCard = sgs.CreateSkillCard {
    name = "s4_txbw_nilin",
    will_throw = false,
    filter = function(self, targets, to_select)
        return #targets < 0
    end,
    on_use = function(self, room, source, targets)
        if sgs.Sanguosha:getCurrentCardUsePattern() == "@@s4_txbw_nilin" then
            for _, id in sgs.qlist(self:getSubcards()) do
                room:setCardFlag(sgs.Sanguosha:getCard(id), "s4_txbw_nilin")
            end
        end
    end,
}
s4_txbw_nilinVS = sgs.CreateViewAsSkill {
    name = "s4_txbw_nilin",
    n = 999,
    view_filter = function(self, selected, to_select, player)
        if sgs.Sanguosha:getCurrentCardUsePattern() == "@@s4_txbw_nilin" then
            local x = player:getMark("s4_txbw_nilin_dis")
            local suits = {}

            for _, c in sgs.list(selected) do
                if not table.contains(suits, c:getSuitString()) then
                    table.insert(suits, c:getSuitString())
                end
            end
            if #suits == x then
                for _, c in sgs.list(selected) do
                    if c:getSuit() ~= to_select:getSuit() then return false end
                end
            end
            return not to_select:isEquipped() and not sgs.Self:isJilei(to_select)
        end
        return true
    end,
    view_as = function(self, cards)
        if sgs.Sanguosha:getCurrentCardUsePattern() == "@@s4_txbw_nilin" then
            if #cards > 0 then
                local skillcard = s4_txbw_nilinCard:clone()
                local suits = {}
                for _, c in ipairs(cards) do
                    if not table.contains(suits, c:getSuitString()) then
                        table.insert(suits, c:getSuitString())
                    end
                end
                for _, c in ipairs(cards) do
                    skillcard:addSubcard(c)
                end
                if #suits == sgs.Self:getMark("s4_txbw_nilin_dis") then
                    return skillcard
                end
            end
        end
    end,
    enabled_at_play = function(self, player)
        return false
    end,
    enabled_at_response = function(self, player, pattern)
        return pattern == "@@s4_txbw_nilin"
    end,
}
s4_txbw_nilin = sgs.CreateTriggerSkill {
    name = "s4_txbw_nilin",
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = s4_txbw_nilinVS,
    events = { sgs.TargetSpecified, sgs.EventPhaseChanging },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.TargetSpecified then
            local use = data:toCardUse()
            if use.card and not use.card:isKindOf("SkillCard") and use.from:objectName() == player:objectName() and player:hasSkill(self:objectName()) then
                if use.from:getMark("used-Clear") == player:getMaxHp() then
                    if not use.from:isAllNude() then
                        if room:askForSkillInvoke(player, self:objectName()) then
                            local card_id = room:askForCardChosen(player, use.from, "hej", self:objectName())
                            if card_id then
                                if room:getCardPlace(id) == sgs.Player_PlaceHand then
                                    room:obtainCard(player, card_id)
                                else
                                    room:throwCard(card_id, use.from, player)
                                end
                            end
                        end
                    end
                end
            end
        elseif event == sgs.EventPhaseChanging then
            local change = data:toPhaseChange()
            if change.to == sgs.Player_Discard then
                if not player:isSkipped(sgs.Player_Discard) then
                    if room:askForSkillInvoke(player, self:objectName()) then
                        player:skip(sgs.Player_Discard)
                        room:showAllCards(player)
                        local suits = {}
                        for _, id in sgs.qlist(player:handCards()) do
                            local card = sgs.Sanguosha:getCard(id)
                            if not table.contains(suits, card:getSuitString()) then
                                table.insert(suits, card:getSuitString())
                            end
                        end
                        if #suits > player:getHp() then
                            room:setPlayerMark(player, "s4_txbw_nilin_dis", #suits - player:getHp())
                            local invoke = room:askForUseCard(player, "@@s4_txbw_nilin", "@s4_txbw_nilin")
                            room:setPlayerMark(player, "s4_txbw_nilin_dis", 0)
                            if invoke then
                                local dummy = sgs.Sanguosha:cloneCard("slash")
                                dummy:deleteLater()
                                for _, id in sgs.qlist(player:handCards()) do
                                    if sgs.Sanguosha:getCard(id):hasFlag("s4_txbw_nilin") then
                                        dummy:addSubcard(id)
                                        room:setCardFlag(sgs.Sanguosha:getCard(id), "-s4_txbw_nilin")
                                    end
                                end
                                if dummy:subcardsLength() > 0 then
                                    room:throwCard(dummy, player)
                                end
                            end
                        end
                    end
                end
            end
        end
    end,
    can_trigger = function(self, player)
        return player
    end,
}

s4_txbw_zhaoyun:addSkill("s4_txbw_general_gain")
s4_txbw_zhaoyun:addSkill(s4_txbw_longdan)
s4_txbw_zhaoyun:addSkill(s4_txbw_nilin)

sgs.LoadTranslationTable {
    ["s4_txbw_zhaoyun"] = "赵云",
    ["&s4_txbw_zhaoyun"] = "赵云",
    ["#s4_txbw_zhaoyun"] = "见龙卸甲",
    ["~s4_txbw_zhaoyun"] = "",
    ["designer:s4_txbw_zhaoyun"] = "",
    ["cv:s4_txbw_zhaoyun"] = "",
    ["illustrator:s4_txbw_zhaoyun"] = "",

    ["s4_txbw_longdan"] = "龙胆",
    [":s4_txbw_longdan"] = "对决胜负判定前，你可以失去1点体力上限，然后与对方交换点数。",

    ["s4_txbw_nilin"] = "逆鳞",
    [":s4_txbw_nilin"] = "其他角色于其回合内使用第X张牌时，你可以弃置其场上的一张牌或获得其一张手牌。你可以跳过弃牌阶段，然后展示手牌并弃置至最多含X种花色（X为你的体力上限）。",


}






















sgs.Sanguosha:addSkills(s4_skillList)


--[[
function addWeiTerritoryPile(card, player, self)
    local room = player:getRoom()
    card = type(card) == "number" and sgs.Sanguosha:getCard(card) or card
    self = type(self) == "string" and self or self and self:objectName() or ""
    if card:getEffectiveId() < 0 then
        return
    end

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
    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECYCLE, player:objectName(), "", self,
        "addWeiTerritoryPile")
    room:moveCardTo(c, nil, sgs.Player_PlaceTable, reason, true)
    WeiTerritoryPile = room:getTag("WeiTerritoryPile"):toString():split("+")
    for _, p in sgs.list(room:getAlivePlayers()) do
        if p:getMark("&WeiTerritoryPile") > 0 then
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
        if player:getPhase() == sgs.Player_Start and player:askForSkillInvoke(self:objectName()) then
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
        if (use.card and use.card:getTypeId() == sgs.Card_TypeTrick and player:getMark("&s4_weiT_adviser-Clear") == 0 and
                getWeiTerritoryPile(player):length() > 0) and player:askForSkillInvoke(self:objectName()) then
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
        if not damage.card or not damage.card:isKindOf("Slash") then
            return false
        end
        if player:getMark("&s4_weiT_gerenal-Clear") == 0 and getWeiTerritoryPile(player):length() > 0 and
            player:askForSkillInvoke(self:objectName()) then
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
    [":s4_weiT_gerenal"] = "天赋技，每回合一次，当你使用【杀】造成伤害后，你可以从【魏领土】中获得一张牌。"

}

s4_weiT_caocao = sgs.General(extension, "s4_weiT_caocao", "wei", 4, true)
s4_weiT_naxian = sgs.CreateTriggerSkill {
    name = "s4_weiT_naxian",
    events = { sgs.Damaged, sgs.DrawNCards, sgs.GameStart },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.Damaged then
            local damage = data:toDamage()
            room:setPlayerMark(player, "&" .. self:objectName(),
                math.max(math.min(player:getHp(), player:getMark("&" .. self:objectName())), 2))
        elseif event == sgs.DrawNCards then
            local x = player:getMark("&" .. self:objectName())
            if room:askForSkillInvoke(player, self:objectName()) then
                local card_ids = room:getNCards(x)
                local obtained = sgs.IntList()
                room:fillAG(card_ids, player)
                local id1 = room:askForAG(player, card_ids, false, self:objectName())
                card_ids:removeOne(id1)
                obtained:append(id1)
                room:takeAG(player, id1, false)
                local id2 = room:askForAG(player, card_ids, true, self:objectName())
                if id2 ~= -1 then
                    card_ids:removeOne(id2)
                    obtained:append(id2)
                end
                room:clearAG(player)
                addWeiTerritoryPile(card_ids, player, self)
                local dummy = sgs.Sanguosha:cloneCard("jink", sgs.Card_NoSuit, 0)
                for _, id in sgs.qlist(obtained) do
                    dummy:addSubcard(id)
                end
                player:obtainCard(dummy, false)
                dummy:deleteLater()
            end
        elseif event == sgs.GameStart then
            room:setPlayerMark(player, "&" .. self:objectName(), player:getHp())
        end
    end
}
s4_weiT_xionglue = sgs.CreateTriggerSkill {
    name = "s4_weiT_xionglue",
    events = { sgs.Damaged },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.Damaged then
            local damage = data:toDamage()
            if getWeiTerritoryPile(player):length() > 0 and player:askForSkillInvoke(self:objectName()) then
                gainWeiTerritoryPile(getWeiTerritoryPile(player), player, self)
            end
        end
    end
}

s4_weiT_caocao:addSkill(s4_weiT_naxian)
s4_weiT_caocao:addSkill(s4_weiT_xionglue)
s4_weiT_caocao:addSkill("s4_weiT_lord")

sgs.LoadTranslationTable {
    ["s4_weiT_caocao"] = "曹操",
    ["#s4_weiT_caocao"] = "",

    ["s4_weiT_naxian"] = "纳贤",
    [":s4_weiT_naxian"] = "摸牌阶段，你可以改为观看牌堆顶X张牌，然后你可以获得其中至多两张牌，并将其余的牌置于【魏领土】。X为你本局游戏体力最小值且至少为2。",
    ["s4_weiT_xionglue"] = "雄略",
    [":s4_weiT_xionglue"] = "当你受到一次伤害后，你可以从【魏领土】中获得一张牌。"

}

s4_weiT_xiahoudun = sgs.General(extension, "s4_weiT_xiahoudun", "wei", 4, true)

s4_weiT_ganglie = sgs.CreateTriggerSkill {
    name = "s4_weiT_ganglie",
    events = { sgs.Damage, sgs.Damaged },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local damage = data:toDamage()
        local target = nil
        if event == sgs.Damage then
            target = damage.to
        else
            target = damage.from
        end
        if not target or target:objectName() == player:objectName() then
            return false
        end
        if not damage.card or not damage.card:isKindOf("Slash") then
            return false
        end
        local players = sgs.SPlayerList()
        if room:askForSkillInvoke(player, self:objectName(), ToQVData(target)) then
            local judge = sgs.JudgeStruct()
            judge.pattern = ".|black"
            judge.good = true
            judge.reason = self:objectName()
            judge.who = player
            room:judge(judge)
            if judge:isGood() and target:isAlive() and not target:isNude() then
                local card_id = room:askForCardChosen(player, target, "he", self:objectName())
                room:obtainCard(player, card_id)
            elseif judge:isBad() and damage.to:isAlive() and damage.from and damage.from:isAlive() then
                room:damage(sgs.DamageStruct(self, damage.to, damage.from, 1, sgs.DamageStruct_Normal))
            end
        end
    end
}

s4_weiT_qingjian = sgs.CreateTriggerSkill {
    name = "s4_weiT_qingjian",
    events = { sgs.CardsMoveOneTime },
    on_trigger = function(self, event, player, data)
        local move = data:toMoveOneTime()
        local room = player:getRoom()
        if not room:getTag("FirstRound"):toBool() and player:getPhase() ~= sgs.Player_Draw and move.to and
            move.to:objectName() == player:objectName() then
            local ids = sgs.IntList()
            for _, id in sgs.qlist(move.card_ids) do
                if room:getCardOwner(id) == player and room:getCardPlace(id) == sgs.Player_PlaceHand then
                    ids:append(id)
                end
            end
            if ids:isEmpty() then
                return false
            end
            local cards = room:askForExchange(player, self:objectName(), 1, 999, false, "@s4_weiT_qingjian")
                :getSubcards()
            if cards then
                addWeiTerritoryPile(cards, player, self)
            end
        end
        return false
    end
}

s4_weiT_xiahoudun:addSkill(s4_weiT_ganglie)
s4_weiT_xiahoudun:addSkill(s4_weiT_qingjian)
s4_weiT_xiahoudun:addSkill("s4_weiT_gerenal")

sgs.LoadTranslationTable {
    ["s4_weiT_xiahoudun"] = "夏侯惇",
    ["#s4_weiT_xiahoudun"] = "",

    ["s4_weiT_ganglie"] = "刚烈",
    [":s4_weiT_ganglie"] = "当你使用【杀】造成伤害或受到【杀】造成的伤害后，你可以作一次判定，若结果为黑色，你获得其一张牌，否则受伤角色对对方造成1点伤害。",
    ["s4_weiT_qingjian"] = "清俭",
    [":s4_weiT_qingjian"] = "你可将摸牌阶段外获得的牌置于【魏领土】中。"

}]]


s4_huaxiong = sgs.General(extension, "s4_huaxiong", "qun", 6, true)


s4_shiyong = sgs.CreateTriggerSkill {
    name = "s4_shiyong",
    frequency = sgs.Skill_NotFrequent,
    events = { sgs.Damage, sgs.CardsMoveOneTime },
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.Damage then
            local x = player:getHp() - player:getHandcardNum()
            if player:getMark("&" .. self:objectName() .. "damage" .. "+_biu") > 0 then return end

            if x > 0 and room:askForSkillInvoke(player, self:objectName(), data) then
                room:addPlayerMark(player, "&" .. self:objectName() .. "damage" .. "+_biu")
                player:drawCards(x)
                room:broadcastSkillInvoke(self:objectName())
            end
        elseif event == sgs.CardsMoveOneTime then
            local move = data:toMoveOneTime()
            local dest = move.to
            local hand = move.to_place
            local fromplace = move.from_places
            local cards = move.card_ids
            local reason = move.reason
            local count = cards:length()
            if player:getPhase() == sgs.Player_Draw then return end
            if player:getMark("&" .. self:objectName() .. "+_biu") > 0 then return end

            if not room:getTag("FirstRound"):toBool() then
                if (dest and dest:objectName() == player:objectName() and hand == sgs.Player_PlaceHand) or
                    (move.from and move.from:objectName() == player:objectName() and
                        (fromplace:contains(sgs.Player_PlaceEquip) or fromplace:contains(sgs.Player_PlaceHand))
                        and not (hand == sgs.Player_PlaceEquip or hand == sgs.Player_PlaceHand)) then
                    if count >= 2 then
                        local x = count / 2

                        room:sendCompulsoryTriggerLog(player, self:objectName(), true)
                        for i = 0, x - 1, 1 do
                            room:loseHp(player, 1)
                            break
                        end
                        room:addPlayerMark(player, "&" .. self:objectName() .. "+_biu")

                        room:broadcastSkillInvoke(self:objectName())
                    end
                end
            end
        end
    end,
}
s4_huaxiong:addSkill(s4_shiyong)

--https://tieba.baidu.com/p/3472257233#61764205069l
sgs.LoadTranslationTable {
    ["s4_huaxiong"] = "华雄",
    ["&s4_huaxiong"] = "华雄",
    ["#s4_huaxiong"] = "魔将",
    ["~s4_huaxiong"] = "",
    ["designer:s4_huaxiong"] = "联合复兴",
    ["cv:s4_huaxiong"] = "",
    ["illustrator:s4_huaxiong"] = "",

    ["s4_shiyongdamage"] = "恃勇:造成伤害",
    ["s4_shiyong"] = "恃勇",
    [":s4_shiyong"] = "每阶段各限一次，你每造成一次伤害，可以将手牌数补充至与体力值相同的张数。锁定技，摸牌阶段以外，你每获得或失去不少于两张牌，你失去一点体力。",

}


return { extension }
