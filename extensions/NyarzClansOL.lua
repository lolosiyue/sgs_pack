extension = sgs.Package("NyarzClansOL", sgs.Package_GeneralPack)
local packages = {}
table.insert(packages, extension)

ny_clans = {}
ny_clan_heros = {}

--用于在lua中设置一名武将的宗族
function setGeneralClanNY(general, clan)
    assert(type(general) == "string")
    assert(type(clan) == "string")
    ny_clans[general] = clan
    table.insert(ny_clan_heros, general)
end

--获取一名武将的宗族（优先以游戏过程中设定的为准）
function getClanNameNY(player)
    local clan = nil
    if player:getMark("clanchange") > 0 then
        clan = player:property("nyclan"):toString()
    end
    if clan then return clan end
    if not table.contains(ny_clan_heros, player:getGeneralName()) then return "no_clans" end
    if ny_clans[player:getGeneralName()] then
        return ny_clans[player:getGeneralName()]
    else
        return "no_clans"
    end
end

--判断同族
function isSameClanNY(first_player, second_player)
    if first_player:objectName() == second_player:objectName() then return true end
    local first_clan = getClanNameNY(first_player)
    if (not first_clan) or first_clan == "no_clans" then return false end
    local second_clan = getClanNameNY(second_player)
    if (not second_clan) or second_clan == "no_clans" then return false end
    if first_clan == second_clan then
        return true
    else
        return false
    end
end

function tempChangeClanNY(room, player, newclan, setmark)
    local oldclan = player:property("nyclan"):toString()
    if oldclan then
        room:setPlayerMark(player, "&"..oldclan, 0)
    end
    room:setPlayerProperty(player, "nyclan", sgs.QVariant(newclan))
    room:setPlayerMark(player, "clanchange", 1)
    if setmark then
        room:setPlayerMark(player, "&"..newclan, 1)
    end
end

--用于宗族技语音
function broadcastClanSkillNY(room, player, skillname)
    local name = string.format("%s_%s", skillname, player:getGeneralName())
    room:broadcastSkillInvoke(name)
end

--原先的宗族技只是套个壳，用来放语音的
--套壳宗族技格式：“宗族技名称+武将名称”
function getRealClanSkillNY(self, event, player, data, skill)
    local room = player:getRoom()
    local can_invoke = false
    if event == sgs.GameStart then can_invoke = true end
    if event == sgs.EventAcquireSkill then
        if data:toString() == self:objectName() then can_invoke = true end
    end
    if not can_invoke then return false end
    room:detachSkillFromPlayer(player, self:objectName(), false, false, false)
    room:acquireSkill(player, skill, true, true, false)
end
clan_skill_event = {sgs.GameStart, sgs.EventAcquireSkill}

ny_chenliuwu_muying = sgs.CreateTriggerSkill{
    name = "ny_chenliuwu_muying",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.Player_Start then return false end
            local max = 0
            for _,target in sgs.qlist(room:getAlivePlayers()) do
                if target:getMaxCards() > max then max = target:getMaxCards() end
            end
            local targets = sgs.SPlayerList()
            for _,target in sgs.qlist(room:getAlivePlayers()) do
                if isSameClanNY(player, target) then
                    if target:getMaxCards() ~= max  then
                        targets:append(target)
                    end
                end
            end
            if targets:isEmpty() then return false end
            local target = room:askForPlayerChosen(player, targets, self:objectName(), "@ny_chenliuwu_muying", true, true)
            if target then
                broadcastClanSkillNY(room, player, self:objectName())
                room:addPlayerMark(target, "ny_chenliuwu_muying_max", 1)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_chenliuwu_muying_buff = sgs.CreateMaxCardsSkill
{
    name = "#ny_chenliuwu_muying_buff",
    extra_func = function(self, target)
        return target:getMark("ny_chenliuwu_muying_max")
    end,
}

ny_chenliuwu_muying_record = sgs.CreateTriggerSkill{
    name = "#ny_chenliuwu_muying_record",
    events = {sgs.EventAcquireSkill,sgs.EventLoseSkill,sgs.HpChanged,sgs.MarkChanged},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:hasSkill("ny_chenliuwu_muying") then
            room:setPlayerMark(player, "&ny_chenliuwu_muying_record", player:getMaxCards())
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

extension:insertRelatedSkills("ny_chenliuwu_muying", "#ny_chenliuwu_muying_buff")
extension:insertRelatedSkills("ny_chenliuwu_muying", "#ny_chenliuwu_muying_record")

ny_zuwuban = sgs.General(extension, "ny_zuwuban", "shu", 4, true, false, false)
setGeneralClanNY("ny_zuwuban", "ny_chenliuwushi")

ny_chenliuwu_muying_ny_zuwuban = sgs.CreateTriggerSkill{
    name = "ny_chenliuwu_muying_ny_zuwuban",
    events = clan_skill_event,
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        getRealClanSkillNY(self, event, player, data, "ny_chenliuwu_muying")
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_zhanding = sgs.CreateViewAsSkill
{
    name = "ny_zhanding",
    n = 999,
    view_filter = function(self, selected, to_select)
        return true
    end,
    view_as = function(self, cards)
        if #cards > 0 then
            local cc = ny_zhandingCard:clone()
            for _,card in ipairs(cards) do
                cc:addSubcard(card)
            end
            return cc
        end
    end,
    enabled_at_play = function(self, player)
        if player:getMaxCards() <= 0 then return false end
        local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
        slash:setSkillName(self:objectName())
        slash:deleteLater()
        return slash:isAvailable(player)
    end,
    enabled_at_response = function(self, player, pattern)
        if player:getMaxCards() <= 0 then return false end
        if sgs.Sanguosha:getCurrentCardUseReason() ~= sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then return false end
        return pattern == "slash" or pattern == "Slash"
    end,
}

ny_zhandingCard = sgs.CreateSkillCard
{
    name = "ny_zhanding",
    will_throw = false,
    filter = function(self, targets, to_select, player)
        local qtargets = sgs.PlayerList()
        for _,p in ipairs(targets) do
            qtargets:append(p)
        end
    
        local card = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
        card:setSkillName(self:objectName())

        if card:targetFixed() then return false end

        card:deleteLater()
        return card and card:targetFilter(qtargets, to_select, player) and not player:isProhibited(to_select, card, qtargets)
    end,
    feasible = function(self, targets, player)
        local use_card = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
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
        room:addPlayerMark(source, "ny_zhanding", 1)

        local card = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
        card:setSkillName(self:objectName())

        room:setCardFlag(card, "RemoveFromHistory")
        room:setCardFlag(card, "ny_zhanding_slash")

        return card
    end,
    on_validate_in_response = function(self, source)
        local room = source:getRoom()

        room:addPlayerMark(source, "ny_zhanding", 1)

        local card = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
        card:setSkillName(self:objectName())

        room:setCardFlag(card, "RemoveFromHistory")
        room:setCardFlag(card, "ny_zhanding_slash")

        return card
    end,
}

ny_zhanding_buff = sgs.CreateMaxCardsSkill{
    name = "#ny_zhanding_buff",
    extra_func = function(self, target)
        return (-1)*target:getMark("ny_zhanding")
    end,
}

ny_zhanding_cards = sgs.CreateTriggerSkill{
    name = "#ny_zhanding_cards",
    events = {sgs.Damage,sgs.CardFinished},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.Damage then
            local damage = data:toDamage()
            if damage.card and (not damage.card:isKindOf("SkillCard")) then
                room:setCardFlag(damage.card, "ny_zhanding_damage")
            end
        end
        if event == sgs.CardFinished then
            if player:isDead() then return false end
            local use = data:toCardUse()
            if use.from:objectName() == player:objectName()
            and use.card:hasFlag("ny_zhanding_slash") then else return false end

            if use.card:hasFlag("ny_zhanding_damage") then
                room:addPlayerHistory(player, "Slash", 1)
                if player:getHandcardNum() > player:getMaxCards() then
                    local n = player:getHandcardNum() - player:getMaxCards()
                    room:askForDiscard(player, "ny_zhanding", n, n, false, false)
                elseif player:getHandcardNum() < player:getMaxCards() then
                    local n = player:getMaxCards() - player:getHandcardNum()
                    player:drawCards(n, "ny_zhanding")
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_zuwuban:addSkill(ny_chenliuwu_muying_ny_zuwuban)
ny_zuwuban:addSkill(ny_zhanding)
ny_zuwuban:addSkill(ny_zhanding_buff)
ny_zuwuban:addSkill(ny_zhanding_cards)
extension:insertRelatedSkills("ny_zhanding", "#ny_zhanding_buff")
extension:insertRelatedSkills("ny_zhanding", "#ny_zhanding_cards")

ny_zuwuxian = sgs.General(extension, "ny_zuwuxian", "shu", 3, false, false, false)
setGeneralClanNY("ny_zuwuxian", "ny_chenliuwushi")

ny_yirong = sgs.CreateViewAsSkill
{
    name = "ny_yirong",
    n = 999,
    view_filter = function(self, selected, to_select)
        local player = sgs.Self
        if player:getHandcardNum() < player:getMaxCards() then return false end
        if not player:getHandcards():contains(to_select) then return false end
        return #selected < (player:getHandcardNum() - player:getMaxCards())
    end,
    view_as = function(self, cards)
        local cc = ny_yirongCard:clone()
        local player = sgs.Self
        if player:getHandcardNum() < player:getMaxCards() then return cc end
        if #cards ~= (player:getHandcardNum() - player:getMaxCards()) then return nil end
        for _,card in ipairs(cards) do
            cc:addSubcard(card)
        end
        return cc
    end,
    enabled_at_play = function(self, player)
        return (player:usedTimes("#ny_yirong") < 2) and (player:getHandcardNum() ~= player:getMaxCards())
    end,
}

ny_yirongCard = sgs.CreateSkillCard
{
    name = "ny_yirong",
    target_fixed = true,
    will_throw = true,
    on_use = function(self, room, source, targets)
        local room = source:getRoom()
        local n = self:subcardsLength()
        if n == 0 then
            local draw = source:getMaxCards() - source:getHandcardNum()
            source:drawCards(draw)
            room:setPlayerMark(source, "ny_yirongdown", source:getMark("ny_yirongdown")+1)
        else
            room:setPlayerMark(source, "ny_yirongup", source:getMark("ny_yirongup")+1)
        end
    end
}

ny_yirong_max = sgs.CreateMaxCardsSkill{
    name = "#ny_yirong_max",
    extra_func = function(self, target)
        local n = 0
        if target:hasSkill("ny_yirong") then
            n = n + target:getMark("ny_yirongup")
            n = n - target:getMark("ny_yirongdown")
        end
        return n
    end,
}

ny_guixiang = sgs.CreateTriggerSkill{
	name = "ny_guixiang" ,
	events = {sgs.EventPhaseStart} ,
	frequency = sgs.Skill_Compulsory ,
    priority = 4,
	on_trigger = function(self, event, player, data)
		if (player:getPhase() == sgs.Player_Start and player:getMaxCards() == 1)
        or (player:getPhase() == sgs.Player_Judge and player:getMaxCards() == 2) 
        or (player:getPhase() == sgs.Player_Draw and player:getMaxCards() == 3) 
        or (player:getPhase() == sgs.Player_Discard and player:getMaxCards() == 5) 
        or (player:getPhase() == sgs.Player_Finish and player:getMaxCards() == 6) then
			local room = player:getRoom()
			local thread = room:getThread()

            local log = sgs.LogMessage()
            log.type = "$ny_guixiangphase"
            log.arg = player:getGeneralName()
            log.arg3 = self:objectName()
            if player:getPhase() == sgs.Player_Start then
                log.arg2 = "start"
            elseif player:getPhase() == sgs.Player_Judge then
                log.arg2 = "judge"
            elseif player:getPhase() == sgs.Player_Draw then
                log.arg2 = "draw"
            elseif player:getPhase() == sgs.Player_Discard then
                log.arg2 = "discard"
            elseif player:getPhase() == sgs.Player_Finish then
                log.arg2 = "finish"
            end
            log.arg4 = "play"
            room:sendLog(log)

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
            return true
        end
	end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_guixiang_log = sgs.CreateTriggerSkill{
    name = "#ny_guixiang_log",
    events = {sgs.EventPhaseStart},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
            local log = sgs.LogMessage()
            log.type = "$ny_guixiangphasestart"
            log.arg = player:getGeneralName()
            if player:getPhase() == sgs.Player_Start then
                log.arg2 = "start"
            elseif player:getPhase() == sgs.Player_Judge then
                log.arg2 = "judge"
            elseif player:getPhase() == sgs.Player_Draw then
                log.arg2 = "draw"
            elseif player:getPhase() == sgs.Player_Discard then
                log.arg2 = "discard"
            elseif player:getPhase() == sgs.Player_Finish then
                log.arg2 = "finish"
            elseif player:getPhase() == sgs.Player_Play then
                log.arg2 = "play"
            else
                return false
            end
            room:sendLog(log)
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_chenliuwu_muying_ny_zuwuxian = sgs.CreateTriggerSkill{
    name = "ny_chenliuwu_muying_ny_zuwuxian",
    events = clan_skill_event,
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        getRealClanSkillNY(self, event, player, data, "ny_chenliuwu_muying")
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_zuwuxian:addSkill(ny_chenliuwu_muying_ny_zuwuxian)
ny_zuwuxian:addSkill(ny_yirong)
ny_zuwuxian:addSkill(ny_yirong_max)
ny_zuwuxian:addSkill(ny_guixiang)
ny_zuwuxian:addSkill(ny_guixiang_log)
extension:insertRelatedSkills("ny_yirong","#ny_yirong_max")
extension:insertRelatedSkills("ny_guixiang","#ny_guixiang_log")

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

ny_baozu = sgs.CreateTriggerSkill{
    name = "ny_baozu",
    events = {sgs.EnterDying},
    frequency = sgs.Skill_Limited,
    limit_mark = "@ny_baozu_mark",
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local dying = data:toDying()
        local victim = dying.who
        if victim:isChained() then return false end
        local prompt = string.format("invoke:%s:",victim:getGeneralName())
        for _,target in sgs.qlist(room:findPlayersBySkillName("ny_baozu")) do
            if victim:isChained() then return false end
            if isSameClanNY(victim, target) and target:getMark("@ny_baozu_mark") > 0 then
                room:setTag("ny_baozu_dying", data)

                if room:askForSkillInvoke(target, self:objectName(), sgs.QVariant(prompt)) then
                    broadcastClanSkillNY(room, target, self:objectName())
                    room:setPlayerMark(target, "@ny_baozu_mark", 0)
                    room:setPlayerChained(victim, true)
                    room:recover(victim, sgs.RecoverStruct(self:objectName(), target, 1))
                    if victim:getHp() > 0 then return false end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_zuzhonghui = sgs.General(extension, "ny_zuzhonghui", "wei", 4, true, false, false, 3)
setGeneralClanNY("ny_zuzhonghui", "ny_yingchuanzhongshi")

ny_baozu_ny_zuzhonghui = sgs.CreateTriggerSkill{
    name = "ny_baozu_ny_zuzhonghui",
    events = clan_skill_event,
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        getRealClanSkillNY(self, event, player, data, "ny_baozu")
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_xieshu = sgs.CreateTriggerSkill{
    name = "ny_xieshu",
    events = {sgs.Damage,sgs.Damaged},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:isDead() then return false end
        local damage = data:toDamage()
        if damage.card and (not damage.card:isKindOf("SkillCard")) then else return false end
        local dis = utf8len(sgs.Sanguosha:translate(damage.card:objectName()))
        if damage.card:isKindOf("Slash") then dis = 1 end
        local draw = player:getLostHp()
        local prompt = string.format("@ny_xieshu:%s::%s:", dis, draw)
        if room:askForDiscard(player, self:objectName(), dis, dis, true, true, prompt, ".", self:objectName()) then
            player:drawCards(draw, self:objectName())
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_yuzhi = sgs.CreateTriggerSkill{
    name = "ny_yuzhi",
    events = {sgs.RoundStart,sgs.RoundEnd,sgs.CardUsed,sgs.CardResponded},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.RoundStart then
            local name_number = 0
            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
            if player:getHandcardNum() > 0 then
                local cards = room:askForExchange(player, self:objectName(), 1, 1, false, "@ny_yuzhi", false)
                local card = cards:getSubcards():first()
                card = sgs.Sanguosha:getCard(card)
                room:showCard(player, card:getEffectiveId())
                name_number = utf8len(sgs.Sanguosha:translate(card:objectName()))
                if card:isKindOf("Slash") then name_number = 1 end
            end
            room:setPlayerMark(player, "ny_yuzhi_lastturn", player:getMark("ny_yuzhi_thisturn"))
            room:setPlayerMark(player, "ny_yuzhi_thisturn", name_number)
            room:setPlayerMark(player, "&ny_yuzhi+_lun", name_number)
            player:drawCards(name_number, self:objectName())
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
            room:addPlayerMark(player, "ny_yuzhi_used_lun", 1)
        end

        if event == sgs.RoundEnd then
            if player:getMark("ny_yuzhi_used_lun") < player:getMark("&ny_yuzhi+_lun")
            or player:getMark("ny_yuzhi_lastturn") < player:getMark("&ny_yuzhi+_lun") then
                local choices = {"hp"}
                if player:hasSkill("ny_baozu") then table.insert(choices, "skill") end
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
                if choice == "hp" then room:loseHp(player, 1) end
                if choice == "skill" then room:detachSkillFromPlayer(player, "ny_baozu") end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_zuzhonghui:addSkill(ny_baozu_ny_zuzhonghui)
ny_zuzhonghui:addSkill(ny_xieshu)
ny_zuzhonghui:addSkill(ny_yuzhi)

ny_zuzhongyu = sgs.General(extension, "ny_zuzhongyu", "wei", 3, true, false, false)
setGeneralClanNY("ny_zuzhongyu", "ny_yingchuanzhongshi")

ny_baozu_ny_zuzhongyu = sgs.CreateTriggerSkill{
    name = "ny_baozu_ny_zuzhongyu",
    events = clan_skill_event,
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        getRealClanSkillNY(self, event, player, data, "ny_baozu")
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_jiejian = sgs.CreateTriggerSkill{
    name = "ny_jiejian",
    events = {sgs.CardUsed, sgs.CardResponded, sgs.TargetConfirmed},
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
            local viewers = sgs.SPlayerList()
            viewers:append(player)
            room:addPlayerMark(player, "&ny_jiejian-Clear", 1, viewers)
        end
        if event == sgs.TargetConfirmed then
            local use = data:toCardUse()
            if use.from:objectName() == player:objectName() and (not use.card:isKindOf("SkillCard")) then else return false end
            if use.card:isKindOf("EquipCard") then return false end
            local n = player:getMark("&ny_jiejian-Clear")
            local num = utf8len(sgs.Sanguosha:translate(use.card:objectName()))
            if use.card:isKindOf("Slash") then num = 1 end
            if n == num then
                local target = room:askForPlayerChosen(player, use.to, self:objectName(), "@ny_jiejian:"..n, true, true)
                if target then
                    room:broadcastSkillInvoke(self:objectName())
                    target:drawCards(n, self:objectName())
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_huanghan = sgs.CreateTriggerSkill{
    name = "ny_huanghan",
    events = {sgs.Damaged},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local damage = data:toDamage()
        if (not damage.card) or damage.card:isKindOf("SkillCard") then return false end
        if player:isDead() then return false end

        local draw = utf8len(sgs.Sanguosha:translate(damage.card:objectName()))
        if damage.card:isKindOf("Slash") then draw = 1 end
        room:setPlayerMark(player, "ny_huanghan_draw", draw)

        local dis = player:getLostHp()
        local prompt = string.format("invoke:%s::%s:", draw, dis)
        if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant(prompt)) then
            room:broadcastSkillInvoke(self:objectName())

            local viewers = sgs.SPlayerList()
            viewers:append(player)
            room:addPlayerMark(player, "&ny_huanghan-Clear", 1, viewers)

            player:drawCards(draw, self:objectName())
            if player:isAlive() then room:askForDiscard(player, self:objectName(), dis, dis, false, true) end

            if player:getMark("&ny_huanghan-Clear") > 1 and player:getMark("@ny_baozu_mark") == 0
            and player:hasSkill("ny_baozu") then
                local log = sgs.LogMessage()
                log.type = "$ny_huanghan_new"
                log.from = player
                log.arg = "ny_baozu"
                room:sendLog(log)
                room:setPlayerMark(player, "@ny_baozu_mark", 1)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_zuzhongyu:addSkill(ny_baozu_ny_zuzhongyu)
ny_zuzhongyu:addSkill(ny_jiejian)
ny_zuzhongyu:addSkill(ny_huanghan)

ny_daojie = sgs.CreateTriggerSkill{
    name = "ny_daojie",
    events = {sgs.CardFinished},
    frequency = sgs.Skill_Compulsory,
    priority = 1,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:isDead() then return false end
        if player:getMark("ny_daojie-Clear") > 0 then return false end
        local use = data:toCardUse()
        if use.from:objectName() == player:objectName() and use.card:isKindOf("TrickCard")
        and (not use.card:isDamageCard()) then
            room:sendCompulsoryTriggerLog(player, self:objectName(), true)
            broadcastClanSkillNY(room, player, self:objectName())
            room:addPlayerMark(player, "ny_daojie-Clear", 1)
            local choice = room:askForChoice(player, self:objectName(), "hp+skill", data)
            if choice == "hp" then
                room:loseHp(player, 1)
            else
                local skills = {}
                for _,skill in sgs.qlist(player:getVisibleSkillList()) do
                    if (not skill:isAttachedLordSkill()) and (skill:getFrequency() == sgs.Skill_Compulsory) then
                        table.insert(skills, skill:objectName())
                    end
                end
                if #skills > 0 then
                    local deta = room:askForChoice(player, self:objectName(), table.concat(skills, "+"))
                    room:detachSkillFromPlayer(player, deta)
                end
            end
            if player:isAlive() --[[and (not use.card:isVirtualCard())]] then
                local targets = sgs.SPlayerList()
                for _,pl in sgs.qlist(room:getAlivePlayers()) do
                    if isSameClanNY(player, pl) then
                        targets:append(pl)
                    end
                end
                if targets:isEmpty() then return false end
                local target = room:askForPlayerChosen(player, targets, self:objectName(), "@ny_daojie:"..use.card:objectName(), false, true)
                if target then
                    room:obtainCard(target, use.card, true)
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_zuxunshu = sgs.General(extension, "ny_zuxunshu", "qun", 3, true, false, false)
setGeneralClanNY("ny_zuxunshu", "ny_yingchuanxunshi")

ny_daojie_ny_zuxunshu = sgs.CreateTriggerSkill{
    name = "ny_daojie_ny_zuxunshu",
    events = clan_skill_event,
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        getRealClanSkillNY(self, event, player, data, "ny_daojie")
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_balongVS = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_balong",
    frequency = sgs.Skill_Compulsory,
    view_as = function(self)
        return ny_balongCard:clone()
    end,
    enabled_at_play = function(self, player)
        return true
    end
}

ny_balongCard = sgs.CreateSkillCard
{
    name = "ny_balong",
    will_throw = false,
    target_fixed = true,
    about_to_use = function(self,room,use)
        local source = use.from
        if source:getMark("ny_balong_old") > 0 then
            room:setPlayerMark(source, "ny_balong_old", 0)
            room:askForChoice(source, self:objectName(), "ny_balong_new+cancel")
        else
            room:setPlayerMark(source, "ny_balong_old", 1)
            room:askForChoice(source, self:objectName(), "ny_balong_old+cancel")
        end
        --source:drawCards(1)
        return
    end,
    on_use = function(self, room, source, targets)
        return false
    end
}

ny_balong = sgs.CreateTriggerSkill{
    name = "ny_balong",
    events = {sgs.HpChanged},
    frequency = sgs.Skill_Compulsory,
    view_as_skill = ny_balongVS,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if player:isDead() then return false end
        if player:getMark("ny_balong-Clear") > 0 then return false end
        room:addPlayerMark(player, "ny_balong-Clear", 1)
        if player:isKongcheng() then return false end
        local trick = 0
        local equip = 0
        local basic = 0
        local show = sgs.IntList()
        for _,card in sgs.qlist(player:getHandcards()) do
            show:append(card:getId())
            if card:isKindOf("TrickCard") then trick = trick + 1
            elseif card:isKindOf("BasicCard") then basic = basic + 1
            elseif card:isKindOf("EquipCard") then equip = equip + 1 end
        end
        if trick > equip and trick > basic then
            room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
            room:showCard(player, show)
            local n = room:getAlivePlayers():length()
            if player:getState() == "robot" then n = 8 end
            if player:getMark("ny_balong_old") > 0 then n = 8 end
            if player:getHandcardNum() < n then
                player:drawCards(n - player:getHandcardNum(), self:objectName())
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_shenjunVS = sgs.CreateViewAsSkill
{
    name = "ny_shenjun",
    n = 999,
    response_pattern = "@@ny_shenjun",
    view_filter = function(self, selected, to_select)
        return #selected < sgs.Self:getMark("ny_shenjun")
    end,
    view_as = function(self, cards)
        local pattern = sgs.Self:property("ny_shenjun"):toString()
        if pattern and #cards == sgs.Self:getMark("ny_shenjun") then
            local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
            card:setSkillName("ny_shenjun")
            --local card = ny_shenjunCard:clone()
            for _,cc in ipairs(cards) do
                card:addSubcard(cc)
            end
            --card:setUserString(pattern)
            return card
        end
    end,
    enabled_at_play = function(self, player)
        return false 
    end,

}

ny_shenjunCard = sgs.CreateSkillCard{
	name = "ny_shenjun",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		local card = sgs.Sanguosha:cloneCard(self:getUserString(), sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
		card:setSkillName("ny_shenjun")

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
		card:setSkillName("ny_shenjun")

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
		card:setSkillName("ny_shenjun")
		return card
	end,
}


ny_shenjun = sgs.CreateTriggerSkill{
    name = "ny_shenjun",
    events = {sgs.CardUsed,sgs.CardResponded,sgs.EventPhaseEnd},
    frequency = sgs.Skill_NotFrequent,
    view_as_skill = ny_shenjunVS,
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
            if card and (card:isKindOf("Slash") or card:isNDTrick()) then else return false end
            if card:getSkillName() == self:objectName() then return false end
            for _,pl in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
                if pl:getHandcardNum() > 0 and pl:isAlive() then
                    local show = sgs.IntList()
                    for _,cc in sgs.qlist(pl:getHandcards()) do
                        if cc:objectName() == card:objectName()
                        or (cc:isKindOf("Slash") and card:isKindOf("Slash")) then
                            show:append(cc:getId())
                        end
                    end
                    if not show:isEmpty() then
                        room:sendCompulsoryTriggerLog(pl, self:objectName(), true, true)
                        room:setPlayerFlag(pl, "ny_shenjun")
                        room:showCard(pl, show)
                        for _,id in sgs.qlist(show) do
                            room:setCardFlag(id, "ny_shenjun")
                            room:setCardTip(id, "ny_shenjun")
                        end
                    end
                end
            end
        end
        if event == sgs.EventPhaseEnd then
            for _,pl in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
                if pl:getHandcardNum() > 0 and pl:isAlive() and pl:hasFlag("ny_shenjun") then
                    room:setPlayerFlag(pl, "-ny_shenjun")
                    local count = 0
                    local choices = {}
                    local cant = {}
                    for _,cc in sgs.qlist(pl:getHandcards()) do
                        if cc:hasFlag("ny_shenjun") then
                            count = count + 1
                            if (not table.contains(choices, cc:objectName())) then

                                table.insert(choices, cc:objectName())
                            end
                        end
                    end
                    if count > 0 then
                        room:setPlayerMark(pl, "ny_shenjun", count)
                        table.insert(choices, "cancel")
                        local choice = room:askForChoice(pl, self:objectName(), table.concat(choices, "+"), data, table.concat(cant, "+"))
                        if not string.find(choice, "cancel") then
                        --else
                            --pl:setTag("ny_shenjun", sgs.QVariant(choice))
                            room:setPlayerProperty(pl, "ny_shenjun", sgs.QVariant(choice))
                            local prompt = string.format("@ny_shenjun:%s::%s:", count, choice)
                            room:askForUseCard(pl, "@@ny_shenjun", prompt)
                        end
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target ~= nil
    end,
}

ny_zuxunshu:addSkill(ny_daojie_ny_zuxunshu)
ny_zuxunshu:addSkill(ny_balong)
ny_zuxunshu:addSkill(ny_balongVS)
ny_zuxunshu:addSkill(ny_shenjun)
ny_zuxunshu:addSkill(ny_shenjunVS)

ny_zuxunchen = sgs.General(extension, "ny_zuxunchen", "qun", 3, true, false, false)
setGeneralClanNY("ny_zuxunchen", "ny_yingchuanxunshi")

ny_daojie_ny_zuxunchen = sgs.CreateTriggerSkill{
    name = "ny_daojie_ny_zuxunchen",
    events = clan_skill_event,
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        getRealClanSkillNY(self, event, player, data, "ny_daojie")
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_sankuang = sgs.CreateTriggerSkill{
    name = "ny_sankuang",
    events = {sgs.CardFinished},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local use = data:toCardUse()
        --local ckind 
        if player:isDead() then return false end
        if use.card:isKindOf("SkillCard") then return false end
        if use.from:objectName() ~= player:objectName() then return false end
        if use.card:isKindOf("BasicCard") and player:getMark("ny_sankuang_basic_lun") == 0 then
            room:addPlayerMark(player, "ny_sankuang_basic_lun", 1)
        elseif use.card:isKindOf("TrickCard") and player:getMark("ny_sankuang_trick_lun") == 0 then
            room:addPlayerMark(player, "ny_sankuang_trick_lun", 1)
        elseif use.card:isKindOf("EquipCard") and player:getMark("ny_sankuang_equip_lun") == 0 then
            room:addPlayerMark(player, "ny_sankuang_equip_lun", 1)
        else
            return false 
        end
        room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
        player:setTag("ny_sankuang_use", data)
        local prompt = string.format("@ny_sankuang:%s:", use.card:objectName())
        local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), prompt, false, true)
        if player:getMark("ny_beishi_used") == 0 then
            room:setPlayerMark(player, "ny_beishi_used", 1)
            local viewers = sgs.SPlayerList()
            viewers:append(player)
            room:setPlayerMark(target, "&ny_beishi", 1, viewers)
            room:setPlayerMark(target, "ny_beishi_from"..player:objectName(), 1)
        end
        local min = 0
        if (not target:getCards("ej"):isEmpty()) then min = min + 1 end
        if target:isWounded() then min = min + 1 end
        if target:getHandcardNum() > target:getHp() then min = min + 1 end
        if (not target:isNude()) then
            local give_pro = string.format("ny_sankuang_give:%s::%s:",player:getGeneralName(),min)
            local give = room:askForExchange(target, self:objectName(), 999, min, true, give_pro, false)
            room:giveCard(target, player, give, self:objectName(), false)
        end
        if target:isAlive() then
            room:obtainCard(target, use.card, true)
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_beishi = sgs.CreateTriggerSkill{
    name = "ny_beishi",
    events = {sgs.BeforeCardsMove,sgs.CardsMoveOneTime},
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if not player:isWounded() then return false end
        if player:getMark("ny_beishi_used") == 0 then return false end

        if event == sgs.BeforeCardsMove then
            local move = data:toMoveOneTime()
            if not move.from then return false end
            local target = room:findPlayerByObjectName(move.from:objectName())
            if (not target) or target:isDead() then return false end
            if target:getMark("ny_beishi_from"..player:objectName()) > 0 then
                room:setPlayerMark(target, "ny_beishi", target:getHandcardNum())
            end
        end

        if event == sgs.CardsMoveOneTime then
            local move = data:toMoveOneTime()
            if not move.from then return false end
            local target = room:findPlayerByObjectName(move.from:objectName())
            if (not target) or target:isDead() then return false end
            if target:getMark("ny_beishi_from"..player:objectName()) > 0 then
                local n = target:getMark("ny_beishi")
                if n <= 0 then return false end
                for i = 0, move.card_ids:length() - 1, 1 do
                    if move.from_places:at(i) == sgs.Player_PlaceHand then
					    n = n - 1
				    end
                end
                if n <= 0 and player:isAlive() and player:isWounded()  then
                    room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                    room:recover(player, sgs.RecoverStruct(self:objectName(), player, 1))
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_zuxunchen:addSkill(ny_daojie_ny_zuxunchen)
ny_zuxunchen:addSkill(ny_sankuang)
ny_zuxunchen:addSkill(ny_beishi)

ny_zuxunyou = sgs.General(extension, "ny_zuxunyou", "wei", 3, true, false, false)
setGeneralClanNY("ny_zuxunyou", "ny_yingchuanxunshi")

ny_daojie_ny_zuxunyou = sgs.CreateTriggerSkill{
    name = "ny_daojie_ny_zuxunyou",
    events = clan_skill_event,
    frequency = sgs.Skill_Compulsory,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        getRealClanSkillNY(self, event, player, data, "ny_daojie")
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_baichu = sgs.CreateTriggerSkill{
    name = "ny_baichu",
    events = {sgs.CardFinished,sgs.RoundEnd,sgs.EventLoseSkill,sgs.GameStart,sgs.EventAcquireSkill},
    frequency = sgs.Skill_NotFrequent,
    waked_skills = "ny_zuqice",
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if use.card:isKindOf("SkillCard") then return false end
            if player:isDead() then return false end
            local ckind
            if use.card:isKindOf("BasicCard") then ckind = "BasicCard"
            elseif use.card:isKindOf("TrickCard") then ckind = "TrickCard"
            elseif use.card:isKindOf("EquipCard") then ckind = "EquipCard"
            else return false end
            local suits = {"spade", "diamond", "club", "heart"}
            local suit = use.card:getSuitString()
            --if not table.contains(suits, suit) then return false end

            local groups = player:getTag("ny_baichu_groups"):toString():split("+")
            if (not groups) or (#groups <= 0) then
                groups = {}
            end
            local records = player:getTag("ny_baichu_records"):toString():split("+")
            if (not records) or (#records <= 0) then
                records = {}
            end
            local invoke = true

            if table.contains(suits, suit) then
                local group = string.format("%s_%s", ckind, suit)
                if not table.contains(groups, group) then
                    room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                    invoke = false

                    table.insert(groups, group)
                    player:setTag("ny_baichu_groups", sgs.QVariant(table.concat(groups, "+")))

                    local all = {}
                    for _,id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
                        local card = sgs.Sanguosha:getEngineCard(id)
                        if card:isNDTrick() then
                            local name = card:objectName()
                            if (not table.contains(all, name)) and (not table.contains(records, name)) then
                                table.insert(all, name)
                            end
                        end
                    end
                
                    if #all > 0 then
                        local choice = room:askForChoice(player, self:objectName(), table.concat(all,"+"), data,
                        table.concat(records,"+"), "ny_baichu_record")

                        table.insert(records, choice)
                        player:setTag("ny_baichu_records", sgs.QVariant(table.concat(records, "+")))
                    end
                else
                    if not player:hasSkill("ny_zuqice") then
                        room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                        invoke = false

                        room:setPlayerMark(player, "ny_zuqice_lun", 1)
                        room:acquireSkill(player, "ny_zuqice", true)
                    end
                end
            end

            if table.contains(records, use.card:objectName()) then
                if invoke then
                    room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                end

                local choice
                if player:isWounded() then
                    choice = room:askForChoice(player, self:objectName(), "draw+recover", data)
                else
                    choice = "draw"
                end
                if choice == "draw" then
                    player:drawCards(1, self:objectName())
                else
                    room:recover(player, sgs.RecoverStruct(self:objectName(), player, 1))
                end
            end
        end

        if event == sgs.RoundEnd then
            if player:getMark("ny_zuqice_lun") > 0 and player:hasSkill("ny_zuqice") then
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                room:detachSkillFromPlayer(player, "ny_zuqice")
            end
        end

        if event == sgs.EventLoseSkill then
            if data:toString() == self:objectName() and player:hasSkill("ny_zuqice_lun") then
                room:sendCompulsoryTriggerLog(player, self:objectName(), true, true)
                room:detachSkillFromPlayer(player, "ny_zuqice_lun")
                room:setPlayerMark(player, "ny_zuqice_lun", 0)

                room:detachSkillFromPlayer(player, "ny_baichu_count", false, false, false)
            end
        end

        if event == sgs.GameStart or event == sgs.EventAcquireSkill then
            if not player:hasSkill("ny_baichu_count") then
                room:acquireSkill(player, "ny_baichu_count", true, false, false)
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

ny_zuqice = sgs.CreateZeroCardViewAsSkill{
    name = "ny_zuqice",
    view_as = function(self)
        local c = sgs.Self:getTag("ny_zuqice"):toCard()
        if c then
            local cc = ny_zuqiceCard:clone()
            for _,card in sgs.qlist(sgs.Self:getHandcards()) do
                cc:addSubcard(card)
            end
            cc:setUserString(c:objectName())
            return cc
        end
    end,
    enabled_at_play = function(self, player)
        return (not player:hasUsed("#ny_zuqice")) and (not player:isKongcheng())
    end
}
ny_zuqice:setGuhuoDialog("r")

ny_zuqiceCard = sgs.CreateSkillCard{
	name = "ny_zuqice",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		local card = sgs.Sanguosha:cloneCard(self:getUserString(), sgs.Card_SuitToBeDecided, -1)
        card:addSubcards(self:getSubcards())
		card:setSkillName("ny_zuqice")
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
		card:setSkillName("ny_zuqice")
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
		card:setSkillName("ny_zuqice")
		return card
	end,
}

ny_baichu_count = sgs.CreateZeroCardViewAsSkill
{
    name = "ny_baichu_count&",
    view_as = function(self)
        return ny_baichu_countCard:clone()
    end,
    enabled_at_play = function(self, player)
        return true
    end,
}

ny_baichu_countCard = sgs.CreateSkillCard
{
    name = "ny_baichu_count",
    target_fixed = true,
    about_to_use = function(self,room,use)
        local source = use.from
        local records = source:getTag("ny_baichu_records"):toString():split("+")
        if (not records) or (#records <= 0) then
            records = {}
        end
        table.insert(records, "cancel")
        local choice = room:askForChoice(source, "ny_baichu", table.concat(records, "+"))
    end,
}

ny_zuxunyou:addSkill(ny_daojie_ny_zuxunyou)
ny_zuxunyou:addSkill(ny_baichu)

local skills = sgs.SkillList()

if not sgs.Sanguosha:getSkill("ny_chenliuwu_muying") then skills:append(ny_chenliuwu_muying) end
if not sgs.Sanguosha:getSkill("#ny_chenliuwu_muying_buff") then skills:append(ny_chenliuwu_muying_buff) end
if not sgs.Sanguosha:getSkill("#ny_chenliuwu_muying_record") then skills:append(ny_chenliuwu_muying_record) end
if not sgs.Sanguosha:getSkill("ny_baozu") then skills:append(ny_baozu) end
if not sgs.Sanguosha:getSkill("ny_daojie") then skills:append(ny_daojie) end
if not sgs.Sanguosha:getSkill("ny_zuqice") then skills:append(ny_zuqice) end
if not sgs.Sanguosha:getSkill("ny_baichu_count") then skills:append(ny_baichu_count) end

sgs.Sanguosha:addSkills(skills)

sgs.LoadTranslationTable 
{
    ["NyarzClansOL"] = "门阀士族",

    ["no_clans"] = "非宗族武将",

    --陈留吴氏

    ["ny_chenliuwushi"] = "陈留吴氏",
    ["ny_chenliuwu_muying"] = "穆荫",
    [":ny_chenliuwu_muying"] = "宗族技，准备阶段，你可以令一名手牌上限不为全场最大的同族角色手牌上限+1。",
    ["@ny_chenliuwu_muying"] = "你可以令一名手牌上限不为全场最大的同族角色手牌上限+1",
    ["ny_chenliuwu_muying_record"] = "手牌上限",

    --族吴班

    ["ny_zuwuban"] = "族吴班-陈留吴氏",
    ["#ny_zuwuban"] = "豪侠督进",
    ["&ny_zuwuban"] = "吴班",

    ["ny_chenliuwu_muying_ny_zuwuban"] = "穆荫",
    [":ny_chenliuwu_muying_ny_zuwuban"] = "宗族技，准备阶段，你可以令一名手牌上限不为全场最大的同族角色手牌上限+1。",
    ["ny_zhanding"] = "斩钉",
    [":ny_zhanding"] = "你可以将任意张牌当【杀】使用并令你手牌上限-1，若此【杀】：造成伤害，你将手牌数调整至手牌上限；未造成伤害，此【杀】不计入次数。",

    ["$ny_chenliuwu_muying_ny_zuwuban1"] = "祖训秉心，其荫何能薄也？",
    ["$ny_chenliuwu_muying_ny_zuwuban2"] = "世代佐忠义，子孙何绝焉？",
    ["$ny_zhanding1"] = "汝颈硬，比之金铁何如？",
    ["$ny_zhanding2"] = "魍魉鼠辈，速速系劲伏首！",
    ["~ny_zuwuban"] = "无胆鼠辈，安敢暗箭伤人……",

    --族吴苋

    ["ny_zuwuxian"] = "族吴苋-陈留吴氏",
    ["&ny_zuwuxian"] = "吴苋",
    ["#ny_zuwuxian"] = "锦虎骧乐",

    ["ny_yirong"] = "移荣",
    [":ny_yirong"] = "出牌阶段限两次，你可以将手牌摸/弃至手牌上限并令你手牌上限-1/+1。", 
    ["ny_guixiang"] = "贵相",
    [":ny_guixiang"] = "锁定技，你回合内第X个阶段改为出牌阶段（X为你的手牌上限）。",
    ["$ny_guixiangphase"] = "%arg 的 %arg2 阶段因 %arg3 改为了 %arg4 阶段。",
    ["$ny_guixiangphasestart"] = "%arg 的 %arg2 阶段开始了。",
    ["ny_chenliuwu_muying_ny_zuwuxian"] = "穆荫",
    [":ny_chenliuwu_muying_ny_zuwuxian"] = "宗族技，准备阶段，你可以令一名手牌上限不为全场最大的同族角色手牌上限+1。",

    ["$ny_yirong1"] = "君之美我者，私也；我之美君者，情也。",
    ["$ny_yirong2"] = "人予悲哉之所因，我予人善哉之所果。",
    ["$ny_guixiang1"] = "命中之女，如剑分双刃，或为所用，或为所伤。",
    ["$ny_guixiang2"] = "余常闻，橘枳分南北，妻离夫亦当如是。",
    ["$ny_chenliuwu_muying_ny_zuwuxian1"] = "皇亲国戚之家，其食当珍馐，衣当锦丽。",
    ["$ny_chenliuwu_muying_ny_zuwuxian2"] = "所谓刑不上大夫，吴氏忠烈，不可等闲视之。",
    ["~ny_zuwuxian"] = "望兄懿、班，护我大汉。",

    --颍川钟氏

    ["ny_yingchuanzhongshi"] = "颍川钟氏",
    ["ny_baozu"] = "保族",
    [":ny_baozu"] = "宗族技，限定技，当一名同族角色进入濒死状态时，你可以令其横置并回复1点体力。",
    ["ny_baozu:invoke"] = "你可以发动“保族”令 %src 横置并回复1点体力",

    --族钟会

    ["ny_zuzhonghui"] = "族钟会-颍川钟氏",
    ["&ny_zuzhonghui"] = "钟会",
    ["#ny_zuzhonghui"] = "谋谟之勋",

    ["ny_baozu_ny_zuzhonghui"] = "保族",
    [":ny_baozu_ny_zuzhonghui"] = "宗族技，限定技，当一名同族角色进入濒死状态时，你可以令其横置并回复1点体力。",
    ["ny_xieshu"] = "挟术",
    [":ny_xieshu"] = "当你使用牌造成伤害后，或受到牌造成的伤害后，你可以弃置X张牌（X为此牌牌名字数）并摸等同于你已损失体力值数量张牌。",
    ["@ny_xieshu"] = "你可以发动“挟术”弃置 %src 张牌并摸 %arg 张牌",
    ["ny_yuzhi"] = "迂志",
    [":ny_yuzhi"] = "锁定技，①每轮游戏开始时，你展示一张手牌并摸X张牌（X为此牌牌名字数）；\
    ②每轮游戏结束时，若你本轮使用的牌数或上一轮因此技能摸的牌数小于X，你选择一项：1.失去1点体力；2.失去技能“保族”。",
    ["ny_yuzhi:hp"] = "失去1点体力",
    ["ny_yuzhi:skill"] = "失去技能“保族”",
    ["@ny_yuzhi"] = "请选择一张“迂志”展示的牌",

    ["$ny_baozu_ny_zuzhonghui1"] = "不为刀下脍，且做俎上刀。",
    ["$ny_baozu_ny_zuzhonghui2"] = "吾族恒大，谁敢欺之？",
    ["$ny_xieshu1"] = "今长缨在手，欲问鼎九州。",
    ["$ny_xieshu2"] = "我有佐国之术，可缚苍龙。",
    ["$ny_yuzhi1"] = "我欲行夏禹救世，为天下人。",
    ["$ny_yuzhi2"] = "汉鹿已失，魏牛犹在，吾欲执其耳。",
    ["~ny_zuzhonghui"] = "谋事在人，成事在天……",

    --族钟毓

    ["ny_zuzhongyu"] = "族钟毓-颍川钟氏",
    ["&ny_zuzhongyu"] = "钟毓",
    ["#ny_zuzhongyu"] = "础润殷忧",

    ["ny_baozu_ny_zuzhongyu"] = "保族",
    [":ny_baozu_ny_zuzhongyu"] = "宗族技，限定技，当一名同族角色进入濒死状态时，你可以令其横置并回复1点体力。",
    ["ny_jiejian"] = "捷谏",
    [":ny_jiejian"] = "当你于一回合内使用第X张牌指定目标后（X为此牌牌名字数），若此牌不为装备牌，你可以令其中一名目标角色摸X张牌。",
    ["@ny_jiejian"] = "你可以令一名目标角色摸 %src 张牌。",
    ["ny_huanghan"] = "惶汗",
    [":ny_huanghan"] = "当你受到牌造成的伤害后，你可以摸X张牌（X为此牌牌名字数）并弃置等同于你已损失体力值数量张牌。然后若你本回合发动此技能的次数大于1，你复原技能“保族”。",
    ["ny_huanghan:invoke"] = "你可以发动“惶汗”摸 %src 张牌然后弃置 %arg 张牌",
    ["$ny_huanghan_new"] = "%from 的 %arg 被复原",

    ["$ny_baozu_ny_zuzhongyu1"] = "弟会腹有恶谋，不可不防。",
    ["$ny_baozu_ny_zuzhongyu2"] = "会期大祸将至，请晋公恕之。",
    ["$ny_jiejian1"] = "庙胜之策，不临矢石。",
    ["$ny_jiejian2"] = "王者之兵，有征无战。",
    ["$ny_huanghan1"] = "居天子阶下，故诚惶诚恐。",
    ["$ny_huanghan2"] = "战战惶惶，汗出如浆。",
    ["~ny_zuzhongyu"] = "百年钟氏，一朝为尘矣。",

    --颍川荀氏

    ["ny_yingchuanxunshi"] = "颍川荀氏",
    ["ny_daojie"] = "蹈节",
    [":ny_daojie"] = "宗族技，锁定技，当你每回合首次使用非伤害锦囊牌后，你选择一项：1.失去1点体力；2.失去一个锁定技。然后令一名同族角色获得此牌。",
    ["ny_daojie:skill"] = "失去一个锁定技",
    ["ny_daojie:hp"] = "失去1点体力",
    ["@ny_daojie"] = "你须令一名同族角色获得此【%src】",

    --族荀淑

    ["ny_zuxunshu"] = "族荀淑-颍川荀氏",
    ["&ny_zuxunshu"] = "荀淑",
    ["#ny_zuxunshu"] = "鹤轸飞鸿",

    ["ny_daojie_ny_zuxunshu"] = "蹈节",
    [":ny_daojie_ny_zuxunshu"] = "宗族技，锁定技，当你每回合首次使用非伤害锦囊牌后，你选择一项：1.失去1点体力；2.失去一个锁定技。然后令一名同族角色获得此牌。",
    ["ny_balong"] = "八龙",
    [":ny_balong"] = "锁定技，当你每回合体力值首次变化后，若你手牌中锦囊牌为唯一最多的类别，你展示手牌并将手牌摸至场上角色数张。",
    ["ny_balong:ny_balong_old"] = "当前为旧版“八龙”",
    ["ny_balong:ny_balong_new"] = "当前为新版“八龙”",
    ["ny_shenjun"] = "神君",
    [":ny_shenjun"] = "当一名角色使用【杀】或普通锦囊牌时，你展示所有与此牌同名的手牌（称为“神君”牌），然后本阶段结束时，你可以将“神君”牌数张牌当任意“神君”牌使用。",
    ["@ny_shenjun"] = "你可以将 %src 张牌当作【%arg】使用",

    ["$ny_daojie_ny_zuxunshu1"] = "一枝寒梅，傲三九霜雪，引春风以致草长莺飞。",
    ["$ny_daojie_ny_zuxunshu2"] = "以我残躯，似高崖之火，此灯长明，可独耀万古！",
    ["$ny_balong1"] = "八子如龙，上可定社稷，下可安黎庶！",
    ["$ny_balong2"] = "八龙者，周穆之旅牡，神智之慧兽，荀氏之良才！",
    ["$ny_shenjun1"] = "蹈万物之妙法可窥神，定万世之太平可尊圣！",
    ["$ny_shenjun2"] = "餍欲之名于我如浮云尔，此间百味可长清风。",
    ["~ny_zuxunshu"] = "为何不见明主，扫清此间寰宇……",

    --族荀谌

    ["ny_zuxunchen"] = "族荀谌-颍川荀氏",
    ["&ny_zuxunchen"] = "荀谌",
    ["#ny_zuxunchen"] = "栖木之择",

    ["ny_daojie_ny_zuxunchen"] = "蹈节",
    [":ny_daojie_ny_zuxunchen"] = "宗族技，锁定技，当你每回合首次使用非伤害锦囊牌后，你选择一项：1.失去1点体力；2.失去一个锁定技。然后令一名同族角色获得此牌。",
    ["ny_sankuang"] = "三恇",
    [":ny_sankuang"] = "锁定技，当你每轮首次使用一种类别的牌后，你令一名角色交给你至少X张牌并获得你使用的牌（X为其满足的条件数）：1.场上有牌；2.已受伤；3.体力值小于手牌数。",
    ["@ny_sankuang"] = "你须令一名其他角色交给你X张牌并获得【%src】",
    ["ny_sankuang_give"] = "请交给%src至少%arg张牌",
    ["ny_beishi"] = "卑势",
    [":ny_beishi"] = "锁定技，当你首次发动“三恇”选择的角色失去最后的手牌后，你回复1点体力。",

    ["$ny_daojie_ny_zuxunchen1"] = "家风蔚然，不敢扰己心、辱门庭。",
    ["$ny_daojie_ny_zuxunchen2"] = "学成满腹之才，欲卖与天下有节高士。",
    ["$ny_sankuang1"] = "谋事兢兢，唯恐事败而使荀门蒙包庸之羞。",
    ["$ny_sankuang2"] = "与人言恐不尽，与人谋恐不全，与人事恐不成。",
    ["$ny_beishi1"] = "积锐蓄精，如虎卑势，可立天下之潮。",
    ["$ny_beishi2"] = "以身卑下，蓄势待发，长缨可缚苍龙。",
    ["~ny_zuxunchen"] = "谌有辱荀氏之名……",

    --族荀攸

    ["ny_zuxunyou"] = "族荀攸-颍川荀氏",
    ["&ny_zuxunyou"] = "荀攸",
    ["#ny_zuxunyou"] = "挥智千军",

    ["ny_daojie_ny_zuxunyou"] = "蹈节",
    [":ny_daojie_ny_zuxunyou"] = "宗族技，锁定技，当你每回合首次使用非伤害锦囊牌后，你选择一项：1.失去1点体力；2.失去一个锁定技。然后令一名同族角色获得此牌。",
    ["ny_baichu"] = "百出",
    [":ny_baichu"] = "当你使用牌结算结束后，若此牌：1.花色和类别的组合为你首次使用，你记录一个未被记录的普通锦囊牌的牌名，否则你本轮视为拥有技能“奇策”；2.为“百出”已记录的牌，你摸一张牌或回复1点体力。",
    ["ny_baichu:draw"] = "摸一张牌",
    ["ny_baichu:recover"] = "恢复一点体力",
    ["ny_baichu_record"] = "请记录一个未被记录的普通锦囊牌的牌名",
    ["ny_baichu_count"] = "百出",
    [":ny_baichu_count"] = "出牌阶段，你可以查看“百出”记录的牌名",
    ["ny_zuqice"] = "奇策",
    [":ny_zuqice"] = "出牌阶段限一次，你可以将所有手牌当任意一张普通锦囊牌使用。",

    ["$ny_daojie_ny_zuxunyou1"] = "神气千逼，当谋董贼之名，以大存名节也。",
    ["$ny_daojie_ny_zuxunyou2"] = "外愚内智，外怯内勇，智可及，愚不可及。",
    ["$ny_baichu1"] = "郃既不用，为郭逢所伤，含冤怒而来，君何疑？",
    ["$ny_baichu2"] = "绍运车旦暮至，其将韩猛锐而轻敌，击可破也。",
    ["$ny_zuqice1"] = "颜良兵围白马，今兵少不敌，分其势乃可。",
    ["$ny_zuqice2"] = "文丑疲军而来，此所以擒敌，奈何去之。",
    ["~ny_zuxunyou"] = "北雁南顾，当折彭䗍之滨……",
}
return packages