extension = sgs.Package("nywuluxun", sgs.Package_GeneralPack)
local packages = {}
table.insert(packages, extension)

nywuluxun = sgs.General(extension, "nywuluxun", "wu", 3, true, false, false)

ny_xiongmu = sgs.CreateTriggerSkill{
    name = "ny_xiongmu",
    events = {sgs.DamageInflicted,sgs.RoundStart,sgs.EventPhaseChanging},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.DamageInflicted then
            if player:getMark("ny_xiongmu-Clear") > 0 then return false end
            room:setPlayerMark(player, "ny_xiongmu-Clear", 1)
            room:setPlayerMark(player, "&ny_xiongmu+-Clear", 1)
            if player:getHandcardNum() > player:getHp() then return false end
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("reduce")) then else return false end
            room:broadcastSkillInvoke(self:objectName())

            local damage = data:toDamage()
            damage.damage = damage.damage - 1

            local log = sgs.LogMessage()
            log.type = "$ny_xiongmu_reduce"
            log.from = player
            log.arg = damage.damage + 1
            log.arg2 = damage.damage
            room:sendLog(log)

            if damage.damage <= 0 then return true end
            data:setValue(damage)
        end

        if event == sgs.RoundStart then
            if not room:askForSkillInvoke(player, self:objectName(), data) then return false end
            room:broadcastSkillInvoke(self:objectName())

            if player:getHandcardNum() < player:getMaxHp() then 
                player:drawCards(player:getMaxHp() - player:getHandcardNum(), self:objectName())
            end

            local shuffle_cards = room:askForExchange(player, self:objectName(), 999, 0, true, "@ny_xiongmu", false)
            local n = shuffle_cards:subcardsLength()
            if n == 0 then return false end

            room:shuffleIntoDrawPile(player, shuffle_cards:getSubcards(), self:objectName(), true)
            
            local get = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, -1)
            for _,id in sgs.qlist(room:getDrawPile()) do
                local card = sgs.Sanguosha:getCard(id)
                if card:getNumber() == 8 then
                    get:addSubcard(card)
                    n = n - 1
                end
                if n <= 0 then break end
            end
            if n > 0 then
                for _,id in sgs.qlist(room:getDiscardPile()) do
                    local card = sgs.Sanguosha:getCard(id)
                    if card:getNumber() == 8 then
                        get:addSubcard(card)
                        n = n - 1
                    end
                    if n <= 0 then break end
                end
            end
            room:obtainCard(player, get, false)
            for _,id in sgs.qlist(get:getSubcards()) do
                if room:getCardOwner(id):objectName() == player:objectName() then
                    room:setCardFlag(sgs.Sanguosha:getCard(id), "ny_xiongmu")
                    room:setCardTip(id, self:objectName())
                end
            end
            get:deleteLater()
        end

        if event == sgs.EventPhaseChanging then
            local change = data:toPhaseChange()
            if change.to == sgs.Player_Discard then
                for _,cc in sgs.qlist(player:getHandcards()) do
                    if cc:hasFlag("ny_xiongmu") then
                        room:ignoreCards(player, cc)
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_zhangcai = sgs.CreateTriggerSkill{
    name = "ny_zhangcai",
    events = {sgs.CardUsed,sgs.CardResponded},
    frequency = sgs.Skill_Frequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local card = nil
        if event == sgs.CardUsed then 
            card = data:toCardUse().card
        else
            card = data:toCardResponse().m_card
        end
        if card:isKindOf("SkillCard") then return false end
        if card:getNumber() == 8 or player:getMark("&ny_ruxian") > 0 then else return false end
        local n = 0
        for _,cc in sgs.qlist(player:getHandcards()) do
            if cc:getNumber() == card:getNumber() then
                n = n + 1
            end
        end
        n = math.max(1,n)
        if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("draw:"..n)) then
            room:broadcastSkillInvoke(self:objectName())
            player:drawCards(n, self:objectName())
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_ruxian = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_ruxian",
    frequency = sgs.Skill_Limited,
    view_as = function(self)
        return ny_ruxianCard:clone()
    end,
    enabled_at_play = function(self,player)
        return player:getMark("ny_ruxian_limit") == 0
    end
}

ny_ruxianCard = sgs.CreateSkillCard
{
    name = "ny_ruxian",
    target_fixed = true,
    on_use = function(self, room, source, targets)
        room:setPlayerMark(source, "&ny_ruxian", 1)
        room:setPlayerMark(source, "ny_ruxian_limit", 1)
    end
}

ny_ruxian_clear = sgs.CreateTriggerSkill{
    name = "#ny_ruxian_clear",
    events = {sgs.EventPhaseChanging},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local change = data:toPhaseChange()
        if change.from == sgs.Player_NotActive then
            room:setPlayerMark(player, "&ny_ruxian", 0)
        end
    end,
    can_trigger = function(self, target)
        return target
    end,
}

nywuluxun:addSkill(ny_xiongmu)
nywuluxun:addSkill(ny_zhangcai)
nywuluxun:addSkill(ny_ruxian)
nywuluxun:addSkill(ny_ruxian_clear)
extension:insertRelatedSkills("ny_ruxian","#ny_ruxian_clear")

sgs.LoadTranslationTable{
    ["nywuluxun"] = "武陆逊",
    ["#nywuluxun"] = "释武怀儒",
    ["&nywuluxun"] = "陆逊",
    ["ny_xiongmu"] = "雄幕",
    [":ny_xiongmu"] = "每轮开始时，你可以将手牌摸至体力上限，然后将任意张牌洗入牌堆，从牌堆或弃牌堆中获得等量点数为8的牌，这些牌不计入你的手牌上限。\
    你每回合首次受到伤害时，若你的手牌数不大于体力值，此伤害-1。",
    ["@ny_xiongmu"] = "请将任意张牌洗入牌堆并获得等量点数为8的牌",
    ["ny_xiongmu:reduce"] = "你可以发动“雄幕”令此伤害-1",
    ["$ny_xiongmu_reduce"] = "%from 受到的伤害由 %arg 点减少到了 %arg2 点",
    ["ny_zhangcai"] = "彰才",
    [":ny_zhangcai"] = "你使用或打出点数为8的牌时，可以摸X张牌。（X为手牌中与此牌点数相同的牌且至少为1）",
    ["ny_zhangcai:draw"] = "你可以发动“彰才”摸 %src 张牌",
    ["ny_ruxian"] = "儒贤",
    [":ny_ruxian"] = "限定技，出牌阶段，你可以令“彰才”改为所有点数均可触发直到你的下个回合开始。",
}

return packages