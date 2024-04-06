extension = sgs.Package("nybeauty", sgs.Package_GeneralPack)
local packages = {}
table.insert(packages, extension)

local function getTypeString(card)
    local cardtype = nil
    local types = { "BasicCard", "TrickCard", "EquipCard" }
    for _, p in ipairs(types) do
        if card:isKindOf(p) then
            cardtype = p
            break
        end
    end
    return cardtype
end

local function CreateDamageLog(damage, changenum, reason, up)
    if up == nil then up = true end
    local log = sgs.LogMessage()
    if damage.from then
        log.type = "$nyarzdamagechange"
        log.from = damage.from
        log.arg5 = damage.to:getGeneralName()
    else
        log.type = "$nyarzdamagechangenofrom"
        log.from = damage.to
    end
    log.arg = reason
    log.arg2 = damage.damage
    if up then
        log.arg3 = "nyarzdamageup"
        log.arg4 = damage.damage + changenum
    else
        log.arg3 = "nyarzdamagedown"
        log.arg4 = damage.damage - changenum
    end
    return log
end

sgs.LoadTranslationTable
{
    ["$nyarzdamagechange"] = "%from 对 %arg5 造成的伤害因 %arg 的效果由 %arg2 点 %arg3 到了 %arg4 点。",
    ["$nyarzdamagechangenofrom"] = "%from 受到的伤害因 %arg 的效果由 %arg2 点 %arg3 到了 %arg4 点。",
    ["nyarzdamageup"] = "增加",
    ["nyarzdamagedown"] = "减少",
}


nycaojinyu = sgs.General(extension, "nycaojinyu", "wei", 3, false, false, false)

nyyuqi = sgs.CreateViewAsSkill
    {
        name = "nyyuqi",
        n = 1,
        expand_pile = "#nyyuqi",
        response_pattern = "@@nyyuqi",
        view_filter = function(self, selected, to_select)
            if sgs.Self:hasFlag("nyyuqiview") then
                if not to_select:isAvailable(sgs.Self) then return false end
                return #selected < 1 and sgs.Self:getPile("#nyyuqi"):contains(to_select:getId())
            end
            return false
        end,
        view_as = function(self, cards)
            if sgs.Self:hasFlag("nyyuqiview") then
                if #cards == 0 then return nil end
                return sgs.Sanguosha:getCard(cards[1]:getId())
            end
            return nyyuqiCard:clone()
        end,
        enabled_at_play = function(self, player)
            if player:getMark("nyyuqicant-PlayClear") > 0 then return false end
            return player:getMark("nyyuqi-PlayClear") < player:getMaxHp()
        end,
    }

nyyuqiCard = sgs.CreateSkillCard
    {
        name = "nyyuqi",
        target_fixed = true,
        on_use = function(self, room, source, targets)
            local room = source:getRoom()
            local n = source:getMaxHp() - source:getMark("nyyuqi-PlayClear")
            local view_cards = room:getNCards(n)
            room:returnToTopDrawPile(view_cards)

            local log = sgs.LogMessage()
            log.type = "$nyyuqiview"
            log.from = source
            log.arg = n
            log.arg2 = self:objectName()
            room:sendLog(log)

            local se = sgs.LogMessage()
            local names = {}
            for _, id in sgs.qlist(view_cards) do
                table.insert(names, id)
            end
            se.type = "$nyyuqiselfview"
            se.arg = n
            se.card_str = table.concat(names, "+")
            room:sendLog(se, source)

            local tag = sgs.QVariant()
            tag:setValue(view_cards)
            source:setTag("nyyuqiuse", tag)

            room:setPlayerFlag(source, "nyyuqiview")
            room:notifyMoveToPile(source, view_cards, "nyyuqi", sgs.Player_DrawPile, true)
            local card = room:askForUseCard(source, "@@nyyuqi", "@nyyuqi")
            room:setPlayerFlag(source, "-nyyuqiview")
            room:notifyMoveToPile(source, view_cards, "nyyuqi", sgs.Player_DrawPile, false)

            if not card then
                room:setPlayerMark(source, "nyyuqicant-PlayClear", 1)
            end
        end,
    }

nyyuqidamage = sgs.CreateTriggerSkill {
    name = "#nyyuqidamage",
    events = { sgs.CardFinished, sgs.Damage, sgs.PreCardUsed },
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.Damage then
            local damage = data:toDamage()
            if damage.card then
                local card_ids = player:getTag("nyyuqiuse"):toIntList()
                if card_ids:contains(damage.card:getId()) then
                    room:setCardFlag(damage.card, "nyyuqidamage")
                end
            end
        elseif event == sgs.CardFinished then
            local card = data:toCardUse().card
            local card_ids = player:getTag("nyyuqiuse"):toIntList()
            if card_ids:contains(card:getId()) and card:hasFlag("nyyuqidamage") then
                room:setPlayerMark(player, "nyyuqi-PlayClear", player:getMark("nyyuqi-PlayClear") + 1)
            end
        elseif event == sgs.PreCardUsed then
            local card = data:toCardUse().card
            local card_ids = player:getTag("nyyuqiuse"):toIntList()
            if room:getCardPlace(card:getId()) == sgs.Player_PlaceHand and card_ids:length() > 0 then
                player:removeTag("nyyuqiuse")
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill("nyyuqi")
    end,
}

nyshanshen = sgs.CreateProhibitSkill {
    name = "nyshanshen",
    is_prohibited = function(self, from, to, card)
        if to:hasSkill("nyshanshen") and to:getMark("&nyshanshen-Clear") > 0 then
            return card:isKindOf("Slash") or card:isKindOf("TrickCard")
        end
        return false
    end,
}

nyshanshenbuff = sgs.CreateTriggerSkill {
    name = "#nyshanshenbuff",
    events = { sgs.Dying },
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local dying = data:toDying()
        room:setPlayerFlag(dying.who, "nyshanshentarget")
        local prompt = string.format("dying:%s:", dying.who:getGeneralName())
        if room:askForSkillInvoke(player, "nyshanshen", sgs.QVariant(prompt)) then
            room:broadcastSkillInvoke("nyshanshen")
            room:setPlayerMark(player, "nyshanshenused_lun", 1)
            room:setPlayerMark(player, "&nyshanshenused+_lun", 1)
            local recover = sgs.RecoverStruct(player, nil, 1)
            room:recover(dying.who, recover)
            if dying.who:objectName() == player:objectName() then
                room:setPlayerMark(player, "&nyshanshen-Clear", 1)
            end
        end
        room:setPlayerFlag(dying.who, "-nyshanshentarget")
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill("nyshanshen") and target:getMark("nyshanshenused_lun") == 0
    end,
}

nyxianjing = sgs.CreateTriggerSkill {
    name = "nyxianjing",
    events = { sgs.EventPhaseStart },
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local n = 3
        if not player:isWounded() then n = 5 end
        local prompt = string.format("view:%s:", n)
        if not room:askForSkillInvoke(player, self:objectName(), sgs.QVariant(prompt)) then return false end
        room:broadcastSkillInvoke(self:objectName())
        local view_cards = room:getNCards(n)
        room:askForGuanxing(player, view_cards)
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName()) and target:getPhase() == sgs.Player_Play
    end,
}

nycaojinyu:addSkill(nyyuqi)
nycaojinyu:addSkill(nyyuqidamage)
nycaojinyu:addSkill(nyshanshen)
nycaojinyu:addSkill(nyshanshenbuff)
nycaojinyu:addSkill(nyxianjing)
extension:insertRelatedSkills("nyyuqi", "#nyyuqidamage")
extension:insertRelatedSkills("nyshanshen", "#nyshanshenbuff")

nyshunhanhua = sgs.General(extension, "nyshunhanhua", "wu", 3, false, false, false)

nymiaojian = sgs.CreateZeroCardViewAsSkill
    {
        name = "nymiaojian",
        view_as = function(self)
            return nymiaojianCard:clone()
        end,
        enabled_at_play = function(self, player)
            return not player:hasUsed("#nymiaojian")
        end,
    }

nymiaojianCard = sgs.CreateSkillCard
    {
        name = "nymiaojian",
        filter = function(self, targets, to_select)
            local player = sgs.Self
            local qtargets = sgs.PlayerList()
            for _, p in ipairs(targets) do
                qtargets:append(p)
            end
            local card = sgs.Sanguosha:cloneCard("_stabs_slash", sgs.Card_SuitToBeDecided, -1)
            card:setSkillName(self:objectName())
            card:deleteLater()
            return card and card:targetFilter(qtargets, to_select, player) and
                not player:isProhibited(to_select, card, qtargets)
        end,
        on_validate = function(self, cardUse)
            local source = cardUse.from
            local room = source:getRoom()
            local card = sgs.Sanguosha:cloneCard("_stabs_slash", sgs.Card_SuitToBeDecided, -1)
            card:setSkillName(self:objectName())
            room:setCardFlag(card, "RemoveFromHistory")
            return card
        end,
    }

nymiaojianda = sgs.CreateTriggerSkill {
    name = "#nymiaojianda",
    events = { sgs.Damage },
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local damage = data:toDamage()
        if damage.card:getSkillName() == "nymiaojian" and (not damage.to:isNude()) and (damage.to:isAlive()) then
            room:sendCompulsoryTriggerLog(player, "nymiaojian")
            local card = room:askForExchange(damage.to, "nymiaojian", 1, 1, true, "@nymiaojian:" ..
                player:getGeneralName(), false)
            room:obtainCard(player, card, false)
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill("nymiaojian")
    end,
}

nymiaojianbuff = sgs.CreateTargetModSkill {
    name = "#nymiaojianbuff",
    residue_func = function(self, from, card)
        if card:getSkillName() == "nymiaojian" then return 1000 end
        return 0
    end,
    distance_limit_func = function(self, from, card)
        if card:getSkillName() == "nymiaojian" then return 1000 end
        return 0
    end,
}

nylianhua = sgs.CreateTriggerSkill {
    name = "nylianhua",
    events = { sgs.Dying },
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local dying = data:toDying()
        if dying.who:objectName() == player:objectName() then
            local rec = player:getMaxHp() - player:getHp()
            local n = 0
            if player:getHandcardNum() < player:getMaxHp() then
                n = player:getMaxHp() - player:getHandcardNum()
            end
            local prompt = string.format("dying:%s::%s:", rec, n)
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant(prompt)) then
                room:setPlayerMark(player, "nylianhua_lun", 1)
                room:setPlayerMark(player, "&nylianhua+_lun", 1)
                room:broadcastSkillInvoke(self:objectName())
                local recover = sgs.RecoverStruct(player, nil, rec)
                room:recover(player, recover)
                player:drawCards(n)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName()) and target:getMark("nylianhua_lun") == 0
    end,
}

nylianhuada = sgs.CreateTriggerSkill {
    name = "#nylianhuada",
    events = { sgs.DamageInflicted },
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local damage = data:toDamage()

        local log = sgs.LogMessage()
        log.type = "$nylianhuadaup"
        log.from = player
        log.arg = "nylianhua"
        log.arg2 = damage.damage
        log.arg3 = damage.damage + 1
        room:sendLog(log)

        room:broadcastSkillInvoke("nylianhua")

        damage.damage = damage.damage + 1
        data:setValue(damage)
    end,
    can_trigger = function(self, target)
        return target and target:getMark("nylianhua_lun") > 0
    end,
}

nychongxu = sgs.CreateTriggerSkill {
    name = "nychongxu",
    events = { sgs.EnterDying },
    frequency = sgs.Skill_Compulsory,
    priority = 4,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local dying = data:toDying()
        if dying.damage and dying.damage.from and dying.damage.from:hasSkill(self:objectName()) then
            room:sendCompulsoryTriggerLog(dying.damage.from, self:objectName(), true, true)

            local log = sgs.LogMessage()
            log.type = "$nychongxukill"
            log.arg = dying.damage.from:getGeneralName()
            log.arg2 = dying.who:getGeneralName()
            log.arg3 = self:objectName()
            room:sendLog(log)
            room:getThread():delay(1000)

            room:killPlayer(dying.who, dying.damage)
            room:gainMaxHp(dying.damage.from, 1, self:objectName())
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

nyshunhanhua:addSkill(nymiaojian)
nyshunhanhua:addSkill(nymiaojianda)
nyshunhanhua:addSkill(nymiaojianbuff)
nyshunhanhua:addSkill(nylianhua)
nyshunhanhua:addSkill(nylianhuada)
nyshunhanhua:addSkill(nychongxu)
extension:insertRelatedSkills("nymiaojian", "#nymiaojianda")
extension:insertRelatedSkills("nymiaojian", "#nymiaojianbuff")
extension:insertRelatedSkills("nylianhua", "#nylianhuada")

nydaqiao = sgs.General(extension, "nydaqiao", "wu", 3, false, false, false)

nyguose = sgs.CreateZeroCardViewAsSkill
    {
        name = "nyguose",
        view_as = function(self)
            return nyguoseCard:clone()
        end,
        enabled_at_play = function(self, player)
            return player:canPindian()
        end
    }

nyguoseCard = sgs.CreateSkillCard
    {
        name = "nyguose",
        filter = function(self, targets, to_select, player)
            if not player:canPindian(to_select) then return false end
            if to_select:isKongcheng() then return false end
            if to_select:objectName() == player:objectName() then return false end
            if to_select:getMark("nyguosefrom" .. sgs.Self:objectName() .. "-PlayClear") > 0 then return false end
            return #targets == 0 and (not player:isPindianProhibited(to_select))
        end,
        on_effect = function(self, effect)
            local room = effect.from:getRoom()
            local success = effect.from:pindian(effect.to, "nyguose", nil)
            if success then
                room:setPlayerMark(effect.to, "nyguosefrom" .. effect.from:objectName() .. "-PlayClear", 1)
                room:setPlayerMark(effect.to, "&nyguose+to+#" .. effect.from:objectName() .. "-PlayClear", 1)
            end
        end
    }

nyguoseelse = sgs.CreateTriggerSkill {
    name = "#nyguoseelse",
    events = { sgs.Pindian },
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.Pindian then
            local pindian = data:toPindian()
            if pindian.reason == "nyguose" then
                local target = pindian.from
                if pindian.success then
                    target:obtainCard(pindian.to_card)
                    local choices = {}
                    if pindian.to:getJudgingArea():length() > 0 then
                        table.insert(choices, string.format("get=%s", pindian.to:getGeneralName()))
                    end
                    if pindian.to:hasJudgeArea() and (not pindian.to:containsTrick("indulgence")) then
                        table.insert(choices, string.format("give=%s", pindian.to:getGeneralName()))
                    end
                    if #choices == 0 then return false end

                    room:setPlayerFlag(pindian.to, "nyguosetarget")

                    local choice = room:askForChoice(pindian.from, "nyguose", table.concat(choices, "+"))

                    room:setPlayerFlag(pindian.to, "-nyguosetarget")

                    if string.find(choice, "get") then
                        local card = room:askForCardChosen(pindian.from, pindian.to, "j", "nyguose")
                        room:obtainCard(pindian.from, card, true)
                    end

                    if string.find(choice, "give") then
                        local card = pindian.from_card
                        room:obtainCard(pindian.from, card, false)

                        local id = card:getId()
                        local indulgence = sgs.Sanguosha:cloneCard("indulgence", card:getSuit(), card:getNumber())
                        indulgence:setSkillName("nyguose")
                        local ccc = sgs.Sanguosha:getWrappedCard(card:getId())
                        ccc:takeOver(indulgence)
                        room:broadcastUpdateCard(room:getAllPlayers(true), id, ccc)

                        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, pindian.from:objectName(),
                            "nyguose", "")
                        room:moveCardTo(ccc, nil, pindian.to, sgs.Player_PlaceDelayedTrick, reason)
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill("nyguose")
    end,
}

nyliuli = sgs.CreateTriggerSkill {
    name = "nyliuli",
    events = { sgs.TargetConfirming },
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local use = data:toCardUse()
        if use.card:isKindOf("Slash") or use.card:isKindOf("Duel") then
            if player:getMark("nyliuli1-Clear") == 0 then
                local tran = string.format("tran:%s:", use.card:objectName())
                if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant(tran)) then
                    room:broadcastSkillInvoke(self:objectName())
                    room:setPlayerFlag(player, "nyliulitarget")

                    if use.card:isKindOf("Slash") then
                        room:setPlayerFlag(player, "nyliulislash")
                    else
                        room:setPlayerFlag(player, "nyliuliduel")
                    end

                    local choices = {}
                    local prompt = string.format("replace=%s=%s", player:getGeneralName(), use.card:objectName())
                    table.insert(choices, prompt)
                    table.insert(choices, "cancel")

                    local target = nil
                    nextp = player:getNextAlive()
                    while (true) do
                        if (not use.to:contains(nextp)) and (use.from:objectName() ~= nextp:objectName())
                            and (not room:isProhibited(use.from, nextp, use.card)) then
                            local choice = room:askForChoice(nextp, self:objectName(), table.concat(choices, "+"))
                            if string.find(choice, "replace") then
                                target = nextp
                                break
                            end
                        end
                        nextp = nextp:getNextAlive()
                        if nextp:objectName() == player:objectName() then break end
                    end

                    room:setPlayerFlag(player, "-nyliulitarget")
                    if use.card:isKindOf("Slash") then
                        room:setPlayerFlag(player, "-nyliulislash")
                    else
                        room:setPlayerFlag(player, "-nyliuliduel")
                    end

                    if target then
                        player:drawCards(1)
                        target:drawCards(1)

                        local log = sgs.LogMessage()
                        log.type = "$nyliulireplace"
                        log.arg = target:getGeneralName()
                        log.arg2 = player:getGeneralName()
                        log.card_str = use.card:toString()
                        room:sendLog(log)

                        use.to:removeOne(player)
                        use.to:append(target)
                        room:sortByActionOrder(use.to)
                        data:setValue(use)
                        room:getThread():trigger(sgs.TargetConfirming, room, target, data)
                    else
                        player:drawCards(2)
                        room:setPlayerMark(player, "nyliuli1-Clear", 1)
                    end
                end
            end
            if player:getMark("nyliuli2-Clear") == 0 and player:getJudgingArea():length() > 0 then
                if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("get")) then
                    room:broadcastSkillInvoke(self:objectName())
                    room:setPlayerMark(player, "nyliuli2-Clear", 1)
                    local card = room:askForCardChosen(player, player, "j", self:objectName())
                    room:obtainCard(player, card, true)
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

nydaqiao:addSkill(nyguose)
nydaqiao:addSkill(nyguoseelse)
nydaqiao:addSkill(nyliuli)
extension:insertRelatedSkills("nyguose", "#nyguoseelse")

nyzhangxuan = sgs.General(extension, "nyzhangxuan", "wu", 4, false, false, false)

nytongli = sgs.CreateViewAsSkill
    {
        name = "nytongli",
        n = 1,
        response_pattern = "@@nytongli",
        view_filter = function(self, selected, to_select)
            local suit = sgs.Self:property("nytonglisuit"):toString()
            if not sgs.Self:getHandcards():contains(to_select) then return false end
            return to_select:getSuitString() == suit and #selected < 1
        end,
        view_as = function(self, cards)
            if #cards == 0 then return nil end
            local pattern = sgs.Self:property("nytonglipattern"):toString()
            local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
            card:setSkillName("nytongli")
            card:addSubcard(cards[1])
            return card
        end,
        enabled_at_play = function(self, player)
            return false
        end,
    }

nytonglibuff = sgs.CreateTriggerSkill {
    name = "#nytonglibuff",
    events = { sgs.PreCardUsed, sgs.CardFinished },
    frequency = sgs.Skill_NotFrequent,
    priority = 10,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()

        if event == sgs.PreCardUsed then
            local use = data:toCardUse()
            if use.card:getSkillName() == "nytongli" then
                room:sendCompulsoryTriggerLog(player, "nytongli")
                player:drawCards(1)
            end
        end

        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card:isKindOf("SkillCard") then return false end
            if use.card:isKindOf("EquipCard") then return false end
            if use.from:objectName() == player:objectName() then
                local card = sgs.Sanguosha:cloneCard(use.card:objectName(), sgs.Card_SuitToBeDecided, -1)
                card:setSkillName("nytongli")
                if card:isAvailable(player) then
                    card:deleteLater()
                    local prompt = string.format("nytongliuse:%s::%s:", use.card:getSuitString(), use.card:objectName())
                    room:setPlayerProperty(player, "nytonglisuit", sgs.QVariant(use.card:getSuitString()))
                    room:setPlayerProperty(player, "nytonglipattern", sgs.QVariant(use.card:objectName()))

                    local origin = player:getTag("nytongliorigin"):toCard()
                    if (not origin) or origin:objectName() ~= use.card:objectName() then
                        room:setPlayerMark(player, "nytonglitimes", 0)
                        local tag = sgs.QVariant()
                        tag:setValue(use.card)
                        player:setTag("nytongliorigin", tag)
                    else
                        room:setPlayerMark(player, "nytonglitimes", player:getMark("nytonglitimes") + 1)
                    end

                    room:askForUseCard(player, "@@nytongli", prompt)
                else
                    card:deleteLater()
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill("nytongli")
    end,
}

nytonglielse = sgs.CreateTargetModSkill {
    name = "#nytonglielse",
    pattern = "BasicCard,TrickCard",
    residue_func = function(self, from, card)
        if card:getSkillName() == "nytongli" then return 1000 end
        return 0
    end,
}

nyshezhang = sgs.CreateTriggerSkill {
    name = "nyshezhang",
    events = { sgs.DamageInflicted },
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        for _, p in sgs.qlist(room:getAlivePlayers()) do
            if p:hasSkill("nyshezhang") and p:getMark("nyshezhang-Clear") < 2 then
                local suits = {}
                for _, card in sgs.qlist(p:getHandcards()) do
                    if not table.contains(suits, card:getSuitString()) then
                        table.insert(suits, card:getSuitString())
                    end
                end
                local prompt
                if #suits >= 4 then
                    prompt = "draw"
                else
                    prompt = string.format("get:%s:", 4 - #suits)
                end
                if room:askForSkillInvoke(p, self:objectName(), sgs.QVariant(prompt)) then
                    room:broadcastSkillInvoke(self:objectName())
                    room:addPlayerMark(p, "&" .. self:objectName() .. "-Clear")
                    if #suits >= 4 then
                        room:setPlayerMark(p, "nyshezhang-Clear", p:getMark("nyshezhang-Clear") + 1)
                        p:drawCards(1)
                        if p:getMark("nyshezhang-Clear") == 1 then
                            local log = sgs.LogMessage()
                            log.type = "$nyshezhangtwice"
                            log.arg = p:getGeneralName()
                            log.arg2 = "nyshezhang"
                            room:sendLog(log)
                        end
                    else
                        room:setPlayerMark(p, "nyshezhang-Clear", 2)
                        local get = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, -1)
                        for _, id in sgs.qlist(room:getDrawPile()) do
                            local card = sgs.Sanguosha:getCard(id)
                            if not table.contains(suits, card:getSuitString()) then
                                table.insert(suits, card:getSuitString())
                                get:addSubcard(card)
                                if #suits >= 4 then break end
                            end
                        end
                        room:obtainCard(p, get, true)
                        get:deleteLater()
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target
    end,
}

nyzhangxuan:addSkill(nytongli)
nyzhangxuan:addSkill(nytonglibuff)
nyzhangxuan:addSkill(nytonglielse)
nyzhangxuan:addSkill(nyshezhang)
extension:insertRelatedSkills("nytongli", "#nytonglibuff")
extension:insertRelatedSkills("nytongli", "#nytonglielse")

nydiaochan = sgs.General(extension, "nydiaochan", "qun", 3, false, false, false)

nybiyue = sgs.CreateTriggerSkill {
    name = "nybiyue",
    events = { sgs.EventPhaseStart },
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:getPhase() == sgs.Player_Start then
            if player:getMark("&nybiyue") > 0 then
                room:setPlayerMark(player, "&nybiyue", 0)
                if player:getHandcardNum() > player:getMaxHp() then
                    local n = player:getHandcardNum() - player:getMaxHp()
                    room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                    room:askForDiscard(player, self:objectName(), n, n, false, false)
                end
            end
        end

        if player:getPhase() == sgs.Player_Finish then
            room:setPlayerMark(player, "&nybiyue", 0)
            local n = 1
            if player:isWounded() then n = n * 2 end
            if player:getHandcardNum() >= player:getHp() then n = n * 2 end
            if player:getMark("damage_point_round") == 0 then n = n * 2 end
            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
            if n == 8 then
                local log = sgs.LogMessage()
                log.type = "$nybiyuediscard"
                log.from = player
                room:sendLog(log)
                room:setPlayerMark(player, "&nybiyue", 1)
            end
            player:drawCards(n)
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

nylijian = sgs.CreateZeroCardViewAsSkill
    {
        name = "nylijian",
        view_as = function(self)
            return nylijianCard:clone()
        end,
        enabled_at_play = function(self, player)
            return player:usedTimes("#nylijian") < 2
        end
    }

local function nylijiangetcard(pattern, cards)
    if not pattern then return nil end
    local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
    card:setSkillName("_nylijian")
    if #cards > 0 then
        local n = #cards
        for i = 1, n, 1 do
            card:addSubcard(cards[i])
        end
    end
    return card
end

local function nylijiancanuse(from, to, cards)
    local room = sgs.Sanguosha:currentRoom()
    local canuse = {}
    local slash = nylijiangetcard("slash", cards)
    if not room:isProhibited(from, to, slash) then
        table.insert(canuse, "slash")
        table.insert(canuse, "fire_slash")
        table.insert(canuse, "thunder_slash")
    end
    slash:deleteLater()
    local duel = nylijiangetcard("duel", cards)
    if not room:isProhibited(from, to, duel) then
        duel:deleteLater()
        table.insert(canuse, "duel")
    end
    duel:deleteLater()
    return canuse
end

nylijianCard = sgs.CreateSkillCard {
    name = "nylijian",
    filter = function(self, targets, to_select, player)
        return #targets < 2
    end,
    feasible = function(self, targets, player)
        return #targets == 2
    end,
    on_use = function(self, room, source, targets)
        local room = source:getRoom()
        local cards = {}
        for _, p in ipairs(targets) do
            if not p:isNude() then
                local id = room:askForCardChosen(source, p, "he", "nylijian")
                table.insert(cards, sgs.Sanguosha:getCard(id))
                room:throwCard(id, p, source)
            end
        end
        local players = sgs.SPlayerList()
        local a = targets[1]
        local b = targets[2]
        local atob = nylijiancanuse(a, b, cards)
        if #atob > 0 then
            players:append(a)
        end
        local btoa = nylijiancanuse(b, a, cards)
        if #btoa > 0 then
            players:append(b)
        end
        if players:length() > 0 then
            local n = #cards
            local ta = room:askForPlayerChosen(source, players, self:objectName(), "@nylijian:" .. n, true, true)
            if ta then
                local pattern
                local from
                local to
                if ta:objectName() == a:objectName() then
                    from = a
                    to = b
                    room:setPlayerMark(from, "nylijian", 1)
                    room:setPlayerMark(to, "nylijian", 2)
                    pattern = room:askForChoice(source, self:objectName(), table.concat(atob, "+"))
                elseif ta:objectName() == b:objectName() then
                    from = b
                    to = a
                    room:setPlayerMark(from, "nylijian", 1)
                    room:setPlayerMark(to, "nylijian", 2)
                    pattern = room:askForChoice(source, self:objectName(), table.concat(btoa, "+"))
                end
                room:setPlayerMark(from, "nylijian", 0)
                room:setPlayerMark(to, "nylijian", 0)

                local card = nylijiangetcard(pattern, cards)
                room:setCardFlag(card, "nylijianfrom" .. source:objectName())
                local use = sgs.CardUseStruct(card, from, to, false, self, source)
                room:useCard(use)
            end
        end
    end
}

nylijianbuff = sgs.CreateTriggerSkill {
    name = "#nylijianbuff",
    events = { sgs.Damage },
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local damage = data:toDamage()
        if (not damage.card) or (damage.card:getSkillName() ~= "nylijian") then return false end
        for _, p in sgs.qlist(room:getAlivePlayers()) do
            if damage.card:hasFlag("nylijianfrom" .. p:objectName()) then
                room:addPlayerHistory(p, "#nylijian", 1)
            end
        end
    end,
    can_trigger = function(self, target)
        return target
    end,
}

nydiaochan:addSkill(nybiyue)
nydiaochan:addSkill(nylijian)
nydiaochan:addSkill(nylijianbuff)
extension:insertRelatedSkills("nylijian", "#nylijianbuff")

nyxiahouzie = sgs.General(extension, "nyxiahouzie", "qun", 4, false, false, false, 3)

nyduoren = sgs.CreateTriggerSkill {
    name = "nyduoren",
    events = { sgs.EnterDying },
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local dying = data:toDying()
        if dying.damage and dying.damage.from
            and dying.damage.from:objectName() ~= dying.who:objectName()
            and dying.damage.from:hasSkill(self:objectName()) then
            local source = dying.damage.from
            local to = dying.who
            local skills = to:getVisibleSkillList()
            local can = {}
            for _, p in sgs.qlist(skills) do
                local skillname = p:objectName()
                if (not source:hasSkill(skillname)) and (not string.find(skillname, "&")) then
                    table.insert(can, skillname)
                end
            end
            if #can == 0 then return false end
            local prompt = string.format("get:%s:", to:getGeneralName())
            if room:askForSkillInvoke(source, self:objectName(), sgs.QVariant(prompt)) then
                room:broadcastSkillInvoke(self:objectName())
                room:loseMaxHp(source, 1)

                local old = source:getTag("nyduorenskills"):toString():split("+")
                if old then
                    for _, skill in ipairs(old) do
                        if source:hasSkill(skill) then
                            room:detachSkillFromPlayer(source, skill)
                        end
                    end
                end

                can = {}
                for _, p in sgs.qlist(skills) do
                    local skillname = p:objectName()
                    if (not source:hasSkill(skillname)) and (not string.find(skillname, "&")) then
                        table.insert(can, skillname)
                    end
                end
                for _, skill in ipairs(can) do
                    room:acquireSkill(source, skill)
                end

                local oldtarget = source:property("nyduorentarget"):toString()
                if oldtarget then room:setPlayerMark(source, "&nyduoren+:+" .. oldtarget, 0) end
                room:setPlayerMark(source, "&nyduoren+:+" .. to:getGeneralName(), 1)

                source:setTag("nyduorenskills", sgs.QVariant(table.concat(can, "+")))
                room:setPlayerProperty(source, "nyduorentarget", sgs.QVariant(to:getGeneralName()))
            end
        end
    end,
    can_trigger = function(self, target)
        return target
    end,
}

nyxuechang = sgs.CreateZeroCardViewAsSkill
    {
        name = "nyxuechang",
        view_as = function(self)
            return nyxuechangCard:clone()
        end,
        enabled_at_play = function(self, player)
            return player:getMark("nyxuechangfailed-PlayClear") == 0
        end
    }

nyxuechangCard = sgs.CreateSkillCard
    {
        name = "nyxuechang",
        filter = function(self, targets, to_select, player)
            if not player:canPindian(to_select) then return false end
            --if to_select:isKongcheng() then return false end
            --if to_select:objectName() == player:objectName() then return false end
            if to_select:getMark("nyxuechangfrom" .. player:objectName() .. "-PlayClear") > 0 then return false end
            return #targets == 0 and (not player:isPindianProhibited(to_select))
        end,
        on_effect = function(self, effect)
            local room = effect.from:getRoom()
            local success = effect.from:pindian(effect.to, "nyxuechang", nil)
            room:setPlayerMark(effect.to, "nyxuechangfrom" .. effect.from:objectName() .. "-PlayClear", 1)
            room:addPlayerMark(effect.to, "&nyxuechang+to+#" .. effect.from:objectName() .. "-PlayClear")
            if not success then
                room:setPlayerMark(effect.from, "nyxuechangfailed-PlayClear", 1)
                room:setPlayerMark(effect.to, "&nyxuechang", effect.to:getMark("&nyxuechang") + 1)
                room:setPlayerMark(effect.from, "&nyxuechangused-Clear", 1)
                room:setPlayerMark(effect.to, "nyxuechangtarget" .. effect.from:objectName(),
                    effect.to:getMark("nyxuechangtarget" .. effect.from:objectName()) + 1)
            end
            if success then
                if not effect.to:isNude() then
                    local card = room:askForCardChosen(effect.from, effect.to, "he", self:objectName())
                    room:obtainCard(effect.from, card, false)
                else
                    local log = sgs.LogMessage()
                    log.type = "$nyxuechangnotcard"
                    log.arg = effect.to:getGeneralName()
                    room:sendLog(log)
                end
                local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
                slash:setSkillName("_nyxuechang")
                if room:isProhibited(effect.from, effect.to, slash) then
                    slash:deleteLater()
                    local log = sgs.LogMessage()
                    log.type = "$nyxuechangnotslash"
                    log.arg = effect.to:getGeneralName()
                    room:sendLog(log)
                else
                    room:setCardFlag(slash, "RemoveFromHistory")
                    local use = sgs.CardUseStruct(slash, effect.from, effect.to)
                    room:useCard(use)
                end
            end
        end
    }

nyxuechangbuff = sgs.CreateTriggerSkill {
    name = "#nyxuechangbuff",
    events = { sgs.DamageCaused },
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local damage = data:toDamage()
        if damage.to:getMark("nyxuechangtarget" .. damage.from:objectName()) > 0 then
            local n = damage.to:getMark("nyxuechangtarget" .. damage.from:objectName())
            room:sendCompulsoryTriggerLog(damage.from, "nyxuechang", true, true)
            local log = CreateDamageLog(damage, n, "nyxuechang", true)
            room:sendLog(log)
            damage.damage = damage.damage + n
            room:setPlayerMark(damage.to, "&nyxuechang", damage.to:getMark("&nyxuechang") - n)
            room:setPlayerMark(damage.to, "nyxuechangtarget" .. damage.from:objectName(), 0)
            data:setValue(damage)
        end
    end,
    can_trigger = function(self, target)
        return target
    end,
}

nyxiahouzie:addSkill(nyduoren)
nyxiahouzie:addSkill(nyxuechang)
nyxiahouzie:addSkill(nyxuechangbuff)
extension:insertRelatedSkills("nyxuechang", "#nyxuechangbuff")

nymusiccaiwenji = sgs.General(extension, "nymusiccaiwenji", "qun", 3, false, false, false)

nyshuangjia = sgs.CreateTriggerSkill {
    name = "nyshuangjia",
    events = { sgs.RoundStart },
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if not player:isAlive() then return false end
        room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)

        if player:getPile("nyhujia"):length() > 0 then
            local dummy = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, -1)
            dummy:addSubcards(player:getPile("nyhujia"))
            room:obtainCard(player, dummy, true)
            dummy:deleteLater()
        end

        local suits = {}
        local new_cards = sgs.IntList()
        for _, id in sgs.qlist(room:getDrawPile()) do
            local card = sgs.Sanguosha:getCard(id)
            local suit = card:getSuitString()
            if not table.contains(suits, suit) then
                table.insert(suits, suit)
                new_cards:append(id)
            end
        end
        if new_cards:length() > 0 then
            player:addToPile("nyhujia", new_cards)
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

nyshuangjiadistance = sgs.CreateDistanceSkill {
    name = "#nyshuangjiadistance",
    correct_func = function(self, from, to)
        if to:getPile("nyhujia"):length() > 0 then
            return 1
        end
        return 0
    end,
}

nybeifenVS = sgs.CreateViewAsSkill
    {
        name = "nybeifen",
        expand_pile = "nyhujia",
        n = 1,
        response_pattern = "@@nybeifen",
        view_filter = function(self, selected, to_select)
            return #selected == 0 and sgs.Self:getPile("nyhujia"):contains(to_select:getId())
        end,
        view_as = function(self, cards)
            if #cards == 0 then return nil end
            local card = nybeifenCard:clone()
            card:addSubcard(cards[1])
            return card
        end,
        enabled_at_play = function(self, player)
            return false
        end
    }

nybeifenCard = sgs.CreateSkillCard
    {
        name = "nybeifen",
        will_throw = false,
        filter = function(self, targets, to_select, player)
            if not player:hasFlag("nybeifencan") then
                return to_select:hasFlag("nybeifentarget")
            end
            return #targets == 0
        end,
        on_use = function(self, room, source, targets)
            local room = source:getRoom()
            local card_id = self:getSubcards():first()
            local card = sgs.Sanguosha:getCard(card_id)
            targets[1]:obtainCard(self, true)
            room:setCardFlag(card_id, "nybeifen")
            room:setCardTip(card_id, "nyhujia")

            local tag1 = sgs.QVariant()
            tag1:setValue(source)
            local tag2 = sgs.QVariant()
            tag2:setValue(targets[1])

            card:setTag("nybeifen", tag1)
            card:setTag("nybeifendraw", tag2)
        end
    }

nybeifen = sgs.CreateTriggerSkill {
    name = "nybeifen",
    events = { sgs.EventPhaseStart, sgs.Damaged, sgs.CardsMoveOneTime },
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = nybeifenVS,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()

        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.Player_Play then return false end
            if player:getPile("nyhujia"):length() == 0 or (not player:hasSkill("nybeifen")) then return false end
            room:setPlayerFlag(player, "nybeifencan")
            room:askForUseCard(player, "@@nybeifen", "@nybeifen")
            room:setPlayerFlag(player, "-nybeifencan")
        end

        if event == sgs.Damaged then
            if not player:isAlive() then return false end
            local targets = room:findPlayersBySkillName("nybeifen")
            if targets:length() == 0 then return false end
            room:setPlayerFlag(player, "nybeifentarget")
            for _, p in sgs.qlist(targets) do
                if p:getPile("nyhujia"):length() > 0 then
                    room:askForUseCard(p, "@@nybeifen", "nybeifengive:" .. player:getGeneralName())
                end
                if not player:isAlive() then
                    room:setPlayerFlag(player, "-nybeifentarget")
                    return false
                end
            end
            room:setPlayerFlag(player, "-nybeifentarget")
        end

        if event == sgs.CardsMoveOneTime then
            local move = data:toMoveOneTime()
            if (not move.from) then return false end
            if not move.from_places:contains(sgs.Player_PlaceHand) then return false end
            local cards = {}
            for _, id in sgs.qlist(move.card_ids) do
                local card = sgs.Sanguosha:getCard(id)
                if card:hasFlag("nybeifen") or card:getTag("nybeifendraw"):toPlayer() then
                    table.insert(cards, card)
                end
            end
            for _, card in ipairs(cards) do
                local target = card:getTag("nybeifendraw"):toPlayer()
                card:removeTag("nybeifendraw")
                local source = card:getTag("nybeifen"):toPlayer()
                card:removeTag("nybeifen")
                if target and target:isAlive() then
                    room:sendCompulsoryTriggerLog(source, "nybeifen", true, true)
                    local suits = {}
                    table.insert(suits, card:getSuitString())
                    local get = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, -1)
                    for _, id in sgs.qlist(room:getDrawPile()) do
                        local cc = sgs.Sanguosha:getCard(id)
                        if not table.contains(suits, cc:getSuitString()) then
                            table.insert(suits, cc:getSuitString())
                            get:addSubcard(cc)
                        end
                    end
                    room:obtainCard(target, get, true)
                    get:deleteLater()
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target
    end,
}

nymusiccaiwenji:addSkill(nyshuangjia)
nymusiccaiwenji:addSkill(nyshuangjiadistance)
nymusiccaiwenji:addSkill(nybeifen)
nymusiccaiwenji:addSkill(nybeifenVS)
extension:insertRelatedSkills("nyshuangjia", "#nyshuangjiadistance")

nyzhangyao = sgs.General(extension, "nyzhangyao", "wu", 3, false, false, false)

nyyuanyu = sgs.CreateZeroCardViewAsSkill
    {
        name = "nyyuanyu",
        view_as = function(self)
            return nyyuanyuCard:clone()
        end,
        enabled_at_play = function(self, player)
            return not player:hasUsed("#nyyuanyu")
        end,
    }

nyyuanyuCard = sgs.CreateSkillCard
    {
        name = "nyyuanyu",
        target_fixed = true,
        will_throw = false,
        on_use = function(self, room, source, targets)
            local room = source:getRoom()
            source:drawCards(1)
            if not source:isNude() and source:isAlive() then
                local card = room:askForExchange(source, self:objectName(), 1, 1, true, "nyzhangyaoput:1", false)
                source:addToPile("nyyuan", card)
                room:getThread():delay(300)
            end
            if source:isAlive() then
                local target = room:askForPlayerChosen(source, room:getOtherPlayers(source), self:objectName(),
                    "@nyyuanyu", true, true)
                if not target then return false end
                if target:getMark("nyyuanyufrom" .. source:objectName()) > 0 then
                    local log = sgs.LogMessage()
                    log.type = "$nyyuanyuremove"
                    log.from = target
                    log.arg = self:objectName()
                    room:sendLog(log)
                else
                    room:addPlayerMark(target, "nyyuanyufrom" .. source:objectName())
                    room:addPlayerMark(target, "&nyyuanyu")
                end
            end
        end
    }

nyyuanyubuff = sgs.CreateTriggerSkill {
    name = "#nyyuanyubuff",
    events = { sgs.EventPhaseStart, sgs.CardUsed, sgs.CardResponded },
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.Player_Discard then return false end
            if player:getHandcardNum() <= player:getHp() then return false end
            local n = player:getHandcardNum() - player:getHp()
            local targets = room:findPlayersBySkillName("nyyuanyu")
            for _, p in sgs.qlist(targets) do
                if player:getMark("nyyuanyufrom" .. p:objectName()) > 0 then
                    room:sendCompulsoryTriggerLog(p, "nyyuanyu", true, true)
                    local card = room:askForExchange(player, "nyyuanyu", n, n, true, "nyzhangyaoput:" .. n, false)
                    p:addToPile("nyyuan", card)
                    n = player:getHandcardNum() - player:getHp()
                    room:getThread():delay(300)
                end
                if n <= 0 then return false end
            end
        end

        if event == sgs.CardUsed or event == sgs.CardResponded then
            if player:isNude() then return false end
            local card
            if event == sgs.CardUsed then
                card = data:toCardUse().card
            elseif event == sgs.CardResponded then
                local response = data:toCardResponse()
                if response.m_isUse then
                    card = response.m_card
                end
            end
            if (not card) or card:isKindOf("SkillCard") then return false end
            local targets = room:findPlayersBySkillName("nyyuanyu")
            for _, p in sgs.qlist(targets) do
                if player:getMark("nyyuanyufrom" .. p:objectName()) > 0 then
                    local can = false
                    if p:getPile("nyyuan"):length() > 0 then
                        for _, id in sgs.qlist(p:getPile("nyyuan")) do
                            local compare = sgs.Sanguosha:getCard(id)
                            if compare:getSuitString() == card:getSuitString() then
                                can = true
                                break
                            end
                        end
                        if can and (not player:isNude()) then
                            room:sendCompulsoryTriggerLog(p, "nyyuanyu", true, true)
                            local card = room:askForExchange(player, "nyyuanyu", 1, 1, true, "nyzhangyaoput:1", false)
                            p:addToPile("nyyuan", card)
                            room:getThread():delay(300)
                        end
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:getMark("&nyyuanyu") > 0
    end,
}

nyxiyanVS = sgs.CreateViewAsSkill
    {
        name = "nyxiyan",
        n = 4,
        expand_pile = "nyyuan",
        response_pattern = "@@nyxiyan",
        view_filter = function(self, selected, to_select)
            for _, p in ipairs(selected) do
                if to_select:getSuitString() == p:getSuitString() then return false end
            end
            return #selected < 4 and sgs.Self:getPile("nyyuan"):contains(to_select:getEffectiveId())
        end,
        enabled_at_play = function(self)
            return false
        end,
        view_as = function(self, cards)
            if #cards < 4 then return nil end
            local card = nyxiyanCard:clone()
            for _, cc in ipairs(cards) do
                card:addSubcard(cc)
            end
            return card
        end,
    }

nyxiyanCard = sgs.CreateSkillCard
    {
        name = "nyxiyan",
        target_fixed = true,
        will_throw = false,
        on_use = function(self, room, source, targets)
            local room = source:getRoom()
            room:obtainCard(source, self, true)
        end
    }

nyxiyan = sgs.CreateTriggerSkill {
    name = "nyxiyan",
    events = { sgs.TargetConfirmed, sgs.EventPhaseStart },
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = nyxiyanVS,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.TargetConfirmed then
            local use = data:toCardUse()
            if use.to:contains(player) and (use.card:isKindOf("Slash") or use.card:isKindOf("Duel")) then
                if not use.from:isNude() then
                    room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                    local card = room:askForExchange(use.from, self:objectName(), 1, 1, true, "nyzhangyaoput:1", false)
                    player:addToPile("nyyuan", card)
                    room:getThread():delay(300)
                end
            end
        end

        if event == sgs.EventPhaseStart then
            if player:getPhase() == sgs.Player_Start or player:getPhase() == sgs.Player_Finish then
                local suits = {}
                for _, id in sgs.qlist(player:getPile("nyyuan")) do
                    local card = sgs.Sanguosha:getCard(id)
                    if not table.contains(suits, card:getSuitString()) then
                        table.insert(suits, card:getSuitString())
                    end
                end
                if #suits >= 4 then
                    room:askForUseCard(player, "@@nyxiyan", "@nyxiyan")
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName()) and target:isAlive()
    end,
}

nyzhangyao:addSkill(nyxiyan)
nyzhangyao:addSkill(nyxiyanVS)
nyzhangyao:addSkill(nyyuanyu)
nyzhangyao:addSkill(nyyuanyubuff)
extension:insertRelatedSkills("nyyuanyu", "#nyyuanyubuff")

sgs.LoadTranslationTable
{
    ["nybeauty"] = "绝代佳人",

    ["nycaojinyu"] = "曹金玉",
    ["#nycaojinyu"] = "惊鸿倩影",
    ["nyyuqi"] = "隅泣",
    [":nyyuqi"] = "出牌阶段，你可以观看牌堆顶的X张牌（X为你的体力上限），然后你可以使用其中一张牌。\
    ①若你未使用牌，此技能于本阶段内失效。\
    ②若你使用了牌且造成了伤害，本阶段内此技能观看数量-1。",
    ["@nyyuqi"] = "你可以使用其中一张牌",
    ["#nyyuqi"] = "隅泣",
    ["$nyyuqiview"] = "%from 发动 %arg2 观看了牌堆顶的 %arg 张牌。",
    ["$nyyuqiselfview"] = "牌堆顶的 %arg 张牌为 %card。",
    ["nyshanshen"] = "善身",
    ["nyshanshenused"] = "善身:已使用",
    [":nyshanshen"] = "每轮限一次，一名角色处于濒死状态时，你可以令其回复一点体力。若该角色为你，你本回合不能成为【杀】或锦囊牌的目标。",
    ["nyshanshen:dying"] = "你可以发动“善身”令 %src 回复一点体力",
    ["nyxianjing"] = "娴静",
    [":nyxianjing"] = "出牌阶段开始时，你可以观看牌堆顶的3张牌并以任意顺序放回牌堆顶或牌堆底。若你未受伤，改为观看5张。",
    ["nyxianjing:view"] = "你可以发动“娴静”观看牌堆顶的%src张牌并以任意顺序放回牌堆顶或牌堆底",

    ["nyshunhanhua"] = "孙寒华",
    ["#nyshunhanhua"] = "莲华熠熠",
    ["nymiaojian"] = "妙剑",
    [":nymiaojian"] = "出牌阶段限一次，你可以视为使用了一张无距离和次数限制的【刺杀】。若此牌造成了伤害，令目标交给你一张牌。",
    ["@nymiaojian"] = "请交给 %src 一张牌",
    ["nylianhua"] = "莲华",
    [":nylianhua"] = "每轮限一次，当你处于濒死状态时，你可以将体力值回复至体力上限，将手牌摸至体力上限。本轮游戏中，你受到的伤害+1。",
    ["nylianhua:dying"] = "你可以发动“莲华”回复%src点体力并摸%arg张牌",
    ["$nylianhuadaup"] = "%from 受到的伤害因 %arg 由 %arg2 点增加到 %arg3 点。",
    ["nychongxu"] = "冲虚",
    [":nychongxu"] = "锁定技，在你造成的伤害令一名其他角色进入濒死状态后，令其跳过濒死结算，然后你加一点体力上限。",
    ["$nychongxukill"] = "%arg 击杀了 %arg2 , %arg2 因 %arg3 的效果无力回天。",

    ["nydaqiao"] = "大乔",
    ["#nydaqiao"] = "清萧清丽",
    ["nyguose"] = "国色",
    [":nyguose"] = "出牌阶段，你可以与一名其他角色拼点，若你赢，你获得对方拼点牌并选择一项：\
    ①获得对方判定区的一张牌；\
    ②将你的拼点牌当作【乐不思蜀】置入对方判定区。\
    选择完成后，你此阶段内不能再对该角色发动【国色】。",
    ["nyguose:get"] = "获得 %src 判定区的一张牌",
    ["nyguose:give"] = "将你的拼点牌当作【乐不思蜀】置入 %src 判定区",
    ["nyliuli"] = "流离",
    [":nyliuli"] = "当你成为【杀】或【决斗】的目标时，你可以\
    ①令其他角色依次选择是否代替你成为此牌目标并与你各摸一张牌。若无人响应，你摸两张牌然后你本回合不能再发动此效果。\
    ②每回合限一次，你可以获得你判定区内的一张牌。",
    ["nyliuli:replace"] = "代替%src成为【%arg】的目标并与其各摸一张牌",
    ["nyliuli:tran"] = "你可以发动“流离”令其他角色选择是否与你各摸一张牌并代替你成为【%src】的目标",
    ["nyliuli:get"] = "你可以发动“流离”获得你判定区的一张牌",
    ["$nyliulireplace"] = "%arg 代替 %arg2 成为了 %card 的目标。",

    ["nyzhangxuan"] = "张嫙",
    ["#nyzhangxuan"] = "涟漪夏梦",
    ["nytongli"] = "同礼",
    [":nytongli"] = "当你使用的牌结算后，你可以将一张相同花色的手牌当作这张牌使用并摸一张牌。",
    ["nytongliuse"] = "你可以将一张 %src 手牌当作【%arg】 使用并摸一张牌。",
    ["nyshezhang"] = "奢葬",
    [":nyshezhang"] = "每回合限一次，一名角色即将受到伤害时，你可以从牌堆获得你手牌中缺少的花色的牌各一张。若你的手牌包含全部四种花色，改为摸一张牌并令此技能于本回合内改为每回合限两次。",
    ["nyshezhang:draw"] = "你可以发动“奢葬”摸一张牌并令此技能于本回合内改为每回合限两次",
    ["nyshezhang:get"] = "你可以发动“奢葬”从牌堆获得你手牌中缺少的花色的牌各一张（共 %src 张）",
    ["$nyshezhangtwice"] = "%arg 的 %arg2 于本回合内改为了每回合限两次。",

    ["nydiaochan"] = "貂蝉",
    ["#nydiaochan"] = "舞惑群心",
    ["nybiyue"] = "闭月",
    [":nybiyue"] = "锁定技，结束阶段，你摸1张牌。\
    以下条件每满足一项，摸牌数便增加一倍。\
    ①你已受伤。\
    ②本回合内未造成过伤害。\
    ③手牌数不小于体力值。\
    若全部满足，你的下个准备阶段须将手牌弃至体力上限。",
    ["$nybiyuediscard"] = "%from 于其下个准备阶段需将手牌弃至体力上限。",
    ["nylijian"] = "离间",
    [":nylijian"] = "出牌阶段限一次，你可以选择两名角色，你弃置这些角色各一张牌，然后你可以令其中一名角色将这两张牌当作【杀】或【决斗】对另一名角色使用。若没有角色因此受到伤害，此技能于本阶段内改为出牌阶段限两次。",
    ["@nylijian"] = "你可以令其中一名角色将这%src张牌当作【杀】或【决斗】对另一名角色使用",

    ["nyxiahouzie"] = "夏侯紫萼",
    ["#nyxiahouzie"] = "孤草飘零",
    ["nyduoren"] = "夺刃",
    [":nyduoren"] = "在你令一名其他角色进入濒死状态后，你可以减少1点体力上限并失去上次以此法获得的技能，然后获得该角色的所有技能。",
    ["nyduoren:get"] = "你可以发动“夺刃”减1点体力上限并获得%src的全部技能",
    ["nyxuechang"] = "血偿",
    ["nyxuechangused"] = "血偿:失效",
    [":nyxuechang"] = "出牌阶段每名其他角色限一次，你可以与一名其他角色拼点。\
    ①若你赢，你获得其一张牌并且视为对其使用了一张【杀】。\
    ②若你没赢，你对其造成的下次伤害+1，然后此技能于本阶段内失效。",
    ["$nyxuechangnotcard"] = "没有可以从 %arg 处获得的牌。",
    ["$nyxuechangnotslash"] = "不能对 %arg 使用【杀】。",

    ["nymusiccaiwenji"] = "乐蔡文姬",
    ["&nymusiccaiwenji"] = "蔡文姬",
    ["#nymusiccaiwenji"] = "姝丽风华",
    ["nyshuangjia"] = "霜笳",
    [":nyshuangjia"] = "锁定技，每轮游戏开始时，你获得所有武将牌上的“胡笳”，然后从牌堆中将四张不同花色的牌置于你的武将牌上，称为“胡笳”。\
    若你的武将牌上有“胡笳”，其他角色与你计算距离时+1。",
    ["nyhujia"] = "胡笳",
    ["nybeifen"] = "悲愤",
    [":nybeifen"] = "出牌阶段开始时或一名角色受到伤害后，你可以令一名角色/受伤角色获得一张“胡笳”。\
    当该角色失去“胡笳”时，其从牌堆中获得三张花色各不相同且与失去的“胡笳”花色不同的牌。",
    ["@nybeifen"] = "你可以令一名角色获得一张“胡笳”",
    ["nybeifengive"] = "你可以令 %src 获得一张“胡笳”",

    ["nyzhangyao"] = "张媱",
    ["#nyzhangyao"] = "琼楼孤蒂",
    ["nyxiyan"] = "夕颜",
    [":nyxiyan"] = "准备阶段或结束阶段，你可以获得四张花色各不相同的“怨”。\
    当你成为【杀】或【决斗】的目标时，使用者须放置一张“怨”。",
    ["nyzhangyaoput"] = "请放置 %src 张“怨”",
    ["@nyxiyan"] = "你可以获得四张花色各不相同的“怨”",
    ["nyyuan"] = "怨",
    ["nyyuanyu"] = "怨语",
    [":nyyuanyu"] = "出牌阶段限一次，你可以摸一张牌并将一张牌置于武将牌上，称为“怨”，然后你可以选择一名其他角色，令其获得或失去以下效果：\
    ①使用与“怨”花色相同的牌时，须放置一张“怨”。\
    ②弃牌阶段开始时，若手牌数大于体力值，须放置相当于超出数量的“怨”。",
    ["$nyyuanyuremove"] = "%from 现在不再受 %arg 影响。",
    ["@nyyuanyu"] = "你可以选择一名角色，使其受到或失去“怨语”影响。",
}
return packages
