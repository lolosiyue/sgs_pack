extension = sgs.Package("kancolle")

local json = require("json")

local event_history_kan = "event.json"


local skills = sgs.SkillList()

---@param room room
---@return boolean cvTakeOff
function canTakeOff(cv)
    if cv and cv:isAlive() and cv:getMark("kan_cat_cv") > 0 then
        if cv:getHp() > 2 or (cv:getHp() > 1 and isCVB(cv)) then
            return true
        end
    end
    return false
end

---@param cv serverplayer
---@return boolean CVB
function isCVB(cv)
    if cv then
        if cv:getMark("kan_cat_cvb") > 0 then
            return true
        end
    end
    return false
end

---@param kanmusu serverplayer
---@return boolean isKanmusu
function isKanmusu(kanmusu)
    if kanmusu then
        for _, mark in sgs.list(kanmusu:getMarkNames()) do
            if string.find(mark, "kan_cat_") and kanmusu:getMark(mark) > 0 then
                return true
            end
        end
    end
    return false
end

---@param shinkai serverplayer
---@return boolean isShinkai
function isShinkai(shinkai)
    if shinkai then
        for _, mark in sgs.list(shinkai:getMarkNames()) do
            if string.find(mark, "kan_shinkai") and shinkai:getMark(mark) > 0 then
                return true
            end
        end
    end
    return false
end

function CutInAnimate(kanmusu)
    local room = kanmusu:getRoom()
    local skill = kanmusu:getGeneralName() .. "_ci"
    local equips = kanmusu:getEquips()
    local equip = ""
    for _, card in sgs.qlist(equips) do
        equip = equip .. card:objectName()
    end

    local word = ""
    local index = -1
    local sources = skill:getSources()
    if #sources > 1 then index = math.random(1, #sources) end
    word = "$" .. skill:objectName() .. (index == -1 and "" or tostring(index))
    room:doAnimate(2,"skill=KanCI:"..equip..":"..math.random(0,11), word)
    local thread = room:getThread()
    thread:delay(1100)
    if skill then room:broadcastSkillInvoke(skill:objectName(), index) end
    thread:delay(2900)
end



kan_attackRange = sgs.CreateAttackRangeSkill
{
    name = "kan_attackRange",
    fixed_func = function(self,target)
        local attackRangeTable = {short = 1, middle = 2, long = 3, superlong = 4}
        local attackRange = 0
        for t, mark in sgs.list(target:getMarkNames()) do
            t = mark:split("+")[2]
            if string.find(mark, "kan_attackRange") and target:getMark(mark) > 0 and attackRangeTable[t] > 0 and attackRangeTable[t] > attackRange then
                attackRange = attackRangeTable[t]
            end
        end
        if attackRange > 0 then
            return attackRange
        end
    end,
}

kan_attackRangeShort = sgs.CreateGameStartSkill{
    name = "kan_attackRangeShort",
    frequency = sgs.Skill_Compulsory,
    on_gamestart = function(self, player)
        player:getRoom():addPlayerMark(player, "kan_attackRange+short")
        return false
    end
}
kan_attackRangeMiddle = sgs.CreateGameStartSkill{
    name = "kan_attackRangeMiddle",
    frequency = sgs.Skill_Compulsory,
    on_gamestart = function(self, player)
        player:getRoom():addPlayerMark(player, "kan_attackRange+middle")
        return false
    end
}
kan_attackRangeLong = sgs.CreateGameStartSkill{
    name = "kan_attackRangeLong",
    frequency = sgs.Skill_Compulsory,
    on_gamestart = function(self, player)
        player:getRoom():addPlayerMark(player, "kan_attackRange+long")
        return false
    end
}
kan_attackRangeSuperlong = sgs.CreateGameStartSkill{
    name = "kan_attackRangeSuperlong",
    frequency = sgs.Skill_Compulsory,
    on_gamestart = function(self, player)
        player:getRoom():addPlayerMark(player, "kan_attackRange+superlong")
        return false
    end
}

kan_cat_dd = sgs.CreateGameStartSkill{
    name = "kan_cat_dd",
    frequency = sgs.Skill_Compulsory,
    on_gamestart = function(self, player)
        player:getRoom():addPlayerMark(player, "kan_cat_dd")
        return false
    end
}
kan_cat_cl = sgs.CreateGameStartSkill{
    name = "kan_cat_cl",
    frequency = sgs.Skill_Compulsory,
    on_gamestart = function(self, player)
        player:getRoom():addPlayerMark(player, "kan_cat_cl")
        return false
    end
}
kan_cat_ca = sgs.CreateGameStartSkill{
    name = "kan_cat_ca",
    frequency = sgs.Skill_Compulsory,
    on_gamestart = function(self, player)
        player:getRoom():addPlayerMark(player, "kan_cat_ca")
        return false
    end
}
kan_cat_cav = sgs.CreateGameStartSkill{
    name = "kan_cat_cav",
    frequency = sgs.Skill_Compulsory,
    on_gamestart = function(self, player)
        player:getRoom():addPlayerMark(player, "kan_cat_cav")
        return false
    end
}
kan_cat_bb = sgs.CreateGameStartSkill{
    name = "kan_cat_bb",
    frequency = sgs.Skill_Compulsory,
    on_gamestart = function(self, player)
        player:getRoom():addPlayerMark(player, "kan_cat_bb")
        return false
    end
}
kan_cat_bbv = sgs.CreateGameStartSkill{
    name = "kan_cat_bbv",
    frequency = sgs.Skill_Compulsory,
    on_gamestart = function(self, player)
        player:getRoom():addPlayerMark(player, "kan_cat_bbv")
        return false
    end
}
kan_cat_fbb = sgs.CreateGameStartSkill{
    name = "kan_cat_fbb",
    frequency = sgs.Skill_Compulsory,
    on_gamestart = function(self, player)
        player:getRoom():addPlayerMark(player, "kan_cat_fbb")
        return false
    end
}
kan_cat_cv = sgs.CreateGameStartSkill{
    name = "kan_cat_cv",
    frequency = sgs.Skill_Compulsory,
    on_gamestart = function(self, player)
        player:getRoom():addPlayerMark(player, "kan_cat_cv")
        return false
    end
}
kan_cat_cvb = sgs.CreateGameStartSkill{
    name = "kan_cat_cvb",
    frequency = sgs.Skill_Compulsory,
    on_gamestart = function(self, player)
        player:getRoom():addPlayerMark(player, "kan_cat_cvb")
        return false
    end
}
kan_shinkai = sgs.CreateGameStartSkill{
    name = "kan_shinkai",
    frequency = sgs.Skill_Compulsory,
    on_gamestart = function(self, player)
        player:getRoom():addPlayerMark(player, "kan_shinkai")
        return false
    end
}



if not sgs.Sanguosha:getSkill("kan_attackRange") then skills:append(kan_attackRange) end
if not sgs.Sanguosha:getSkill("kan_attackRangeShort") then skills:append(kan_attackRangeShort) end
if not sgs.Sanguosha:getSkill("kan_attackRangeMiddle") then skills:append(kan_attackRangeMiddle) end
if not sgs.Sanguosha:getSkill("kan_attackRangeLong") then skills:append(kan_attackRangeLong) end
if not sgs.Sanguosha:getSkill("kan_attackRangeSuperlong") then skills:append(kan_attackRangeSuperlong) end
if not sgs.Sanguosha:getSkill("kan_cat_dd") then skills:append(kan_cat_dd) end
if not sgs.Sanguosha:getSkill("kan_cat_cl") then skills:append(kan_cat_cl) end
if not sgs.Sanguosha:getSkill("kan_cat_ca") then skills:append(kan_cat_ca) end
if not sgs.Sanguosha:getSkill("kan_cat_cav") then skills:append(kan_cat_cav) end
if not sgs.Sanguosha:getSkill("kan_cat_bb") then skills:append(kan_cat_bb) end
if not sgs.Sanguosha:getSkill("kan_cat_bbv") then skills:append(kan_cat_bbv) end
if not sgs.Sanguosha:getSkill("kan_cat_fbb") then skills:append(kan_cat_fbb) end
if not sgs.Sanguosha:getSkill("kan_cat_cv") then skills:append(kan_cat_cv) end
if not sgs.Sanguosha:getSkill("kan_cat_cvb") then skills:append(kan_cat_cvb) end
if not sgs.Sanguosha:getSkill("kan_shinkai") then skills:append(kan_shinkai) end




kan_audio = sgs.CreateTriggerSkill {
	name = "#kan_audio",
	events = { sgs.PreCardUsed, sgs.CardResponded,sgs.Damaged, sgs.EventPhaseStart, sgs.GameOverJudge,sgs.GameFinished },
	global = true,
	priority = 3,
	can_trigger = function(self, target)
		return target and isKanmusu(target)
	end,
	on_trigger = function(self, triggerEvent, player, data)
		local room = player:getRoom()
		if not string.find(room:getMode(), "p") then return end
		local x = 1
		if triggerEvent == sgs.PreCardUsed or triggerEvent == sgs.CardResponded then
			local card = nil
			if triggerEvent == sgs.PreCardUsed then
				card = data:toCardUse().card
			else
				card = data:toCardResponse().m_card
			end
			if card and card:isDamageCard() then
                local index = -1
                local skill = player:getGeneralName().. "_attack"
                local sources = skill:getSources()
                if #sources > 1 then index = math.random(1, #sources) end
                if skill then room:broadcastSkillInvoke(skill:objectName(), index) end
            elseif card and card:isKindOf("EquipCard") then
                local index = -1
                local skill = player:getGeneralName().. "_equip"
                local sources = skill:getSources()
                if #sources > 1 then index = math.random(1, #sources) end
                if skill then room:broadcastSkillInvoke(skill:objectName(), index) end
            end
		elseif triggerEvent == sgs.EventPhaseStart then
			if player and player:getPhase() == sgs.Player_Start then
				local index = -1
                local skill = player:getGeneralName().. "_start"
                local sources = skill:getSources()
                if #sources > 1 then index = math.random(1, #sources) end
                if skill then room:broadcastSkillInvoke(skill:objectName(), index) end
			end
		elseif triggerEvent == sgs.Damaged then
			local damage = data:toDamage()
			if damage.to and damage.to:isAlive() then
				local index = -1
                local skill = player:getGeneralName().. "_damaged"
                local sources = skill:getSources()
                if #sources > 1 then index = math.random(1, #sources) end
                if skill then room:broadcastSkillInvoke(skill:objectName(), index) end
			end
		elseif triggerEvent == sgs.GameOverJudge then
			local t = getWinner(room, death.who)
			if not t then return end
			local players = sgs.QList2Table(room:getAlivePlayers())
			local function loser(p)
				local tt = t:split("+")
				if not table.contains(tt, p:getRole()) then return true end
				return false
			end
			for _, p in ipairs(players) do
				if loser(p) then 
					table.removeOne(players, p)
				end
			end
			local comp = function(a,b)
				return a:getMark("mvpexp") > b:getMark("mvpexp")
			end
			if #players > 1 then
                table.sort(players,comp)
			end
			local index = -1
            local skill = players[1]:getGeneralName().. "_mvp"
            local sources = skill:getSources()
            if #sources > 1 then index = math.random(1, #sources) end
            if skill then room:broadcastSkillInvoke(skill:objectName(), index) end
            local thread = room:getThread()
            thread:delay(2900)
		end
		return false
	end
}


if not sgs.Sanguosha:getSkill("#kan_audio") then skills:append(kan_audio) end



kan_event = sgs.CreateTriggerSkill{
	name = "kan_event",
	events = {sgs.DamageCaused},
    global = true,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.DamageCaused
		then
            local damage = data:toDamage()
			if damage and damage.from and isKanmusu(damage.from) and isShinkai(damage.to) then
                local recordFile = assert(io.open(event_history_kan, "r"))
				local rf = recordFile:read("*all")
				recordFile:close()
				local eventdata = json.decode(rf)
                if #eventdata > 0 then
                for i, value in ipairs(eventdata.name) do
                    if value == damage.from:getGeneralName() then
                        local x = math.floor(math.random() * 2 + 1)
                        damage.damage = damage.damage + x 
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
		return false
	end
}


if not sgs.Sanguosha:getSkill("kan_event") then skills:append(kan_event) end



sgs.LoadTranslationTable{
    ["kancolle"] = "艦隊收藏",

    ["kan_attackRange"] = "射程",
    [":kan_attackRange"] = "",

    ["#kan_audio"] = "艦娘語音",
    [":#kan_audio"] = "",

    ["kan_attackRangeShort"] = "射程：短",
    [":kan_attackRangeShort"] = "",
    ["kan_attackRangeMiddle"] = "射程：中",
    [":kan_attackRangeMiddle"] = "",
    ["kan_attackRangeLong"] = "射程：長",
    [":kan_attackRangeLong"] = "",
    ["kan_attackRangeSuperlong"] = "射程：超長",
    [":kan_attackRangeSuperlong"] = "",

    ["kan_cat_dd"] = "艦種：驅逐艦",
    ["kan_cat_cl"] = "艦種：輕巡洋艦",
    ["kan_cat_ca"] = "艦種：重巡洋艦",
    ["kan_cat_cav"] = "艦種：巡空巡洋艦",
    ["kan_cat_bb"] = "艦種：戰艦",
    ["kan_cat_bbv"] = "艦種：航空戰艦",
    ["kan_cat_fbb"] = "艦種：高速戰艦",
    ["kan_cat_cv"] = "艦種：空母",
    ["kan_cat_cvb"] = "艦種：裝甲空母",
    ["kan_shinkai"] = "深海",
}



sgs.Sanguosha:addSkills(skills)

return {extension}