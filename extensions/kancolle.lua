extension = sgs.Package("kancolle")

do
    require  "lua.config" 
	local config = config
	local kingdoms = config.kingdoms
            table.insert(kingdoms,"kancolle")
	config.color_de = "#9AC0CD"
end

local json = require("json")
--[[ 
    kanEvent = 活動圖 
    point 點
    shinkai 深海名稱 
    rewards 獎勵
    kanmusu 倍卡
    equips 倍卡裝
    route 帶路 limit -至少 +最多
    ArmorBreak Trick 解迷/削甲
 ]]
local kanEvent = "kanEvent.json"
--[[ 
    養成艦娘
    level
 ]]
local kanRaise = "kanRaise.json"
salvage = true --撈船
local kanEquip = "kanEquip.json"


local skills = sgs.SkillList()

---@param room room
---@return boolean cvTakeOff
function canTakeOff(cv)
    if cv and cv:isAlive() and cv:getMark("kan_cat_cv") > 0 then
        if cv:getHp() > 2 or (cv:getHp() > 1 and isCVB(cv)) then
            return not isFire(cv)
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


isFire = function(player)
	if player:getMark("@FireCaused") > 0 then
		return true
	else
		return false
	end
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

readData = function(section)
	local json = require "json"
	local record = io.open(testdata, "r")
	local t = {[section] = {}}
	if record ~= nil then
		local content = record:read("*all")
		t = json.decode(content) or t
		if t[section] == nil and section ~= "*" then
			t[section] = {}
		end
		record:close()
	end
	return t
end


writeData = function(t)
	local record = assert(io.open(testdata, "w"))
	local order = {"Record", "Item","Daily", "GameTimes"}
	setmetatable(order, { __index = table})
	local content = json.encode(t, {indent = true, level = 1, keyorder = order})
	record:write(content)
	record:close()
end

saveRecord = function(player, record_type) --record_type: 0. +1 gameplay , 1. +1 win , 2. +1 win & +1 gameplay
	assert(record_type >= 0 and record_type <= 2, "record_type should be 0, 1 or 2")
	
	local t = readData("Record")

	if t["Record"]["GameTimes"] == nil then
		t["Record"]["GameTimes"] = {0, 0}
	end
	
	local all = sgs.Sanguosha:getLimitedGeneralNames()
	for _,name in pairs(all) do
		if sgs.Sanguosha:getGeneral(name):getPackage() == "levelup" and t["Record"][name] == nil then
			t["Record"][name] = {0, 0}
		end
	end
	
	local name = player:getGeneralName()
	local skin_id = string.find(name, "_skin") --?株甇血?雿輻??霈啣???(g_skin)
	if skin_id then
		name = string.sub(name, 1, skin_id - 1)
	end
	
	local name2 = ""
	if player:getGeneral2() then
		name2 = player:getGeneral2Name()
		local skin_id2 =  string.find(name2, "_skin")
		if skin_id2 then
			name2 = string.sub(name2, 1, skin_id2 - 1)
		end
	end
		
	if record_type ~= 0 then -- record_type 1 or 2
		t["Record"]["GameTimes"][1] = t["Record"]["GameTimes"][1] + 1
		if t["Record"][name] then
			t["Record"][name][1] = t["Record"][name][1] + 1
		end
		if name2 ~= "" and name ~= name2 and t["Record"][name2] then
			t["Record"][name2][1] = t["Record"][name2][1] + 1
		end
	end
	if record_type ~= 1 then -- record_type 0 or 2
		t["Record"]["GameTimes"][2] = t["Record"]["GameTimes"][2] + 1
		if t["Record"][name] then
			t["Record"][name][2] = t["Record"][name][2] + 1
		end
		if name2 ~= "" and name ~= name2 and t["Record"][name2] then
			t["Record"][name2][2] = t["Record"][name2][2] + 1
		end
	end
	
	writeData(t)
end



saveItem = function(item_type, item_name, add_num)
	local t = readData(item_type)
	local repeated = false

	if t[item_type][item_name] then
		if t[item_type][item_name] > 0 then repeated = true end
		t[item_type][item_name] = t[item_type][item_name] + add_num
	else
		if not t[item_type] then
			t[item_type] = {}
		end
		t[item_type][item_name] = add_num
	end
	
	writeData(t)
	
	return repeated
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
        room:writeToConsole(room:getMode())
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



kan_event_damage = sgs.CreateTriggerSkill{
	name = "kan_event_damage",
	events = {sgs.DamageCaused},
    global = true,
	on_trigger = function(self,event,player,data,room)
		if event==sgs.DamageCaused
		then
            local damage = data:toDamage()
			if damage and damage.from and isKanmusu(damage.from) and isShinkai(damage.to) then
                local recordFile = assert(io.open(kanEvent, "r"))
				local rf = recordFile:read("*all")
				recordFile:close()
				local eventdata = json.decode(rf)
                assert(eventdata)
                if #eventdata > 0 then
                for i, value in ipairs(eventdata.data.level.kanmusus) do
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

kan_event_game_end = sgs.CreateTriggerSkill{
	name = "kan_event_gameend",
	global = true,
	events = {sgs.GameOverJudge},
	on_trigger = function(self, event, splayer, data, room)
		if not room:getTag("InEvent"):toBool() then return false end
		for _, p in sgs.qlist(room:getAllPlayers(true)) do
			if not p:getTag("Kanmusu"):toBool() then continue end
			local recordFile = assert(io.open(GER, "r"))
			local level = recordFile:read("*l"):split("=")
			level = tonumber(level[2])
			recordFile:close()
			local record = assert(io.open(GER, "w"))
			if p:isDead() or level == 6 then
				record:write("level=1")
				record:close()
				if p:isAlive() and level == 6 then
					local winFile = assert(io.open(winTimes, "r"))
					local win_count = winFile:read("*l")
					winFile:close()
					local winRecord = assert(io.open(winTimes, "w"))
					if win_count == nil then
						winRecord:write("1")
					else
						local chance = 0
						if p:getMark("easy") > 0 then chance = 40
						elseif p:getMark("normal") > 0 then chance = 70
						elseif p:getMark("insane") > 0 then chance = 100
						end
						if math.random(1, 100) <= chance then
							local count = math.min(3, (tonumber(win_count) + 1))
							winRecord:write("" .. count)
							local msg = sgs.LogMessage()
							msg.type = "#showWinCount"
							msg.arg = count
							room:sendLog(msg)
						else
							winRecord:write("" .. math.min(3, tonumber(win_count)))
						end
					end
					winRecord:close()
				end
				return false
			end
			record:write("level=" .. tostring(level + 1) .. "\n")
			record:write("general=" .. p:getGeneralName() .. "\n")
			local skill_table = {}
			for _, skill in sgs.qlist(p:getVisibleSkillList()) do
				if not ((skill:objectName() == "niepan" and p:getTag("niepan_thisGame"):toBool()) or skill:isAttachedLordSkill()) then
					table.insert(skill_table, skill:objectName())
				end
			end
			record:write("hp=" .. tostring(p:getHp()) .. "/" .. tostring(p:getMaxHp()) .. "\n")
			record:write("skills=" .. checkLength(skill_table) .. "\n")
			local equips, hand = sgs.IntList(), sgs.IntList()
			for _, card in sgs.qlist(p:getCards("he")) do
				local id = card:getEffectiveId()
				if room:getCardPlace(id) == sgs.Player_PlaceEquip then
					equips:append(id)
				elseif room:getCardPlace(id) == sgs.Player_PlaceHand then
					hand:append(id)
				end
			end
			record:write("equip_ids=" .. checkLength(sgs.QList2Table(equips)) .. "\n")
			record:write("hand_ids=" .. checkLength(sgs.QList2Table(hand)) .. "\n")
			local chained = p:isChained() and "1" or "0"
			record:write("isChained=" .. chained .. "\n")
			local faceDown = p:faceUp() and "0" or "1"
			record:write("faceDown=" .. faceDown .. "\n")
			local mark_table, mark_num = {}, {}
			for _, mark in sgs.list(p:getMarkNames()) do
				if (table.contains(ban_marks, mark) or not (string.startsWith(mark, "@") or (p:hasSkill(mark) and
					sgs.Sanguosha:getSkill(mark):getFrequency() == sgs.Skill_Wake))) and not table.contains(difficulty_marks, mark) then continue end
				local n = p:getMark(mark)
				if n > 0 then
					table.insert(mark_table, mark)
					table.insert(mark_num, tostring(n))
				end
			end
			record:write("marks=" .. checkLength(mark_table) .. "\n")
			record:write("marks_num=" .. checkLength(mark_num) .. "\n")
			local pile_names, pile_cards = p:getPileNames(), sgs.IntList()
			if #pile_names > 0 then
				for i = 1, #pile_names do
					if table.contains(ban_piles, pile_names[i]) then continue end
					pile_cards = p:getPile(pile_names[i])
					if pile_cards:length() == 0 then continue end
					record:write(pile_names[i] .. "=" .. checkLength(sgs.QList2Table(pile_cards)) .. "\n")
				end
			end
			record:close()
			break
		end
		return false
	end
}


kan_event_game_start = sgs.CreateTriggerSkill{
	name = "kan_event_game_start",
	events = {sgs.GameStart, sgs.TurnStart, sgs.DrawInitialCards, sgs.AfterDrawInitialCards},
	global = true,
	priority = 10,
	on_trigger = function(self, event, splayer, data, room)
		if event == sgs.GameStart then
			if room:getMode() == "02p" and room:alivePlayerCount() == 2 and not room:getTag("InEvent"):toBool() then
				local player, robot = nil, nil
				for _, p in sgs.list(room:getAlivePlayers()) do
					if p:getState() ~= "robot" then
						player = p
					else
						robot = p
					end
				end
				local recordFile = assert(io.open(GER, "r"))
				local rf = recordFile:read("*all"):split("\n")
				recordFile:close()
				local level = tonumber(rf[1]:split("=")[2])
				if player and robot and player:objectName() == splayer:objectName() then
					if level < 1 or level > 6 or #rf < 11 then
						local record = assert(io.open(GER, "w"))
						record:write("level=1")
						record:close()
						level = 1
					end
					if not player:isLord() then
						player:setRole("lord")
						robot:setRole("rebel")
						room:setPlayerProperty(player, "role", sgs.QVariant("lord"))
						room:setPlayerProperty(robot, "role", sgs.QVariant("rebel"))
						room:updateStateItem()
					end
					if level ~= 1 then
						local general_name = rf[2]:split("=")[2]
						room:changeHero(player, general_name, false, false)
						local total_hp = rf[3]:split("=")[2]
						local hp, maxhp = tonumber(total_hp:split("/")[1]), tonumber(total_hp:split("/")[2])
						room:setPlayerProperty(player, "maxhp", sgs.QVariant(maxhp))
						room:setPlayerProperty(player, "hp", sgs.QVariant(hp))
						local skill_list = rf[4]:split("=")[2]
						if skill_list ~= "NULL" then
							local skillList = skill_list:split(",")
							local skillstring = table.concat(skillList, "|")
							room:handleAcquireDetachSkills(player, skillstring)
						end
						local equip_ids = rf[5]:split("=")[2]
						local moves = sgs.CardsMoveList()
						if equip_ids ~= "NULL" then
							local move_e = sgs.CardsMoveStruct(Table2IntList(equip_ids:split(",")), nil, player, sgs.Player_DrawPile, sgs.Player_PlaceEquip,
								sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), ""))
							moves:append(move_e)
						end
						local hand_ids = rf[6]:split("=")[2]
						if hand_ids ~= "NULL" then
							local move_h = sgs.CardsMoveStruct(Table2IntList(hand_ids:split(",")), nil, player, sgs.Player_DrawPile, sgs.Player_PlaceHand,
								sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), ""))
							moves:append(move_h)
						end
						local isChained = rf[7]:split("=")[2]
						if isChained == "1" then
							player:setChained(true)
							room:broadcastProperty(player, "chained")
						end
						local faceDown = rf[8]:split("=")[2]
						if faceDown == "1" then
							player:setFaceUp(false)
							room:broadcastProperty(player, "faceup")
						end
						room:moveCardsAtomic(moves, false)
						local marks = rf[9]:split("=")[2]
						if marks ~= "NULL" then
							local markList = marks:split(",")
							local marks_num = rf[10]:split("=")[2]
							local num = Table2IntList(marks_num:split(","))
							for i = 1, #markList do
								room:setPlayerMark(player, markList[i], num:at(i - 1))
							end
						end
						if #rf > 11 then
							for i = 11, #rf - 1 do
								local pile_name, ids_string = rf[i]:split("=")[1], rf[i]:split("=")[2]
								local pile_ids = Table2IntList(ids_string:split(","))
								player:addToPile(pile_name, pile_ids)
							end
						end
					end
					room:setTag("InEvent", sgs.QVariant(true))
					player:setTag("Kanmusu", sgs.QVariant(true))
					room:doLightbox("$WelcomeToRAFTOM", 3000)
					local msg = sgs.LogMessage()
					msg.type = "$AppendSeparator"
					room:sendLog(msg)
					msg.type = "#RAFTOMStart"
					room:sendLog(msg)
					local choice = nil
					if level > 1 and level < 6 then
						local choiceList, types = {}, {}
						for _, t in pairs(reward_types) do
							table.insert(types, t)
						end
						math.random()
						for i = 1, 3 do
							if #types == 0 then break end
							local reward_type = types[math.random(1, #types)]
							table.insert(choiceList, reward_type)
							table.removeOne(types, reward_type)
						end
						if #choiceList > 0 then
							choice = room:askForChoice(player, "reward", table.concat(choiceList, "+"))
						end
					elseif level == 1 then
						selectHero(player, player, 7)
						local difficulty = room:askForChoice(player, "select_dif", "easy+normal+insane")
						if difficulty == "easy" then
							room:setPlayerProperty(player, "maxhp", sgs.QVariant(player:getMaxHp() + 2))
							judgeHp(player, player:getGeneralName(), 2)
						elseif difficulty == "normal" then
							room:setPlayerProperty(player, "maxhp", sgs.QVariant(player:getMaxHp() + 1))
							judgeHp(player, player:getGeneralName(), 1)
						else
							player:speak("rua")
						end
						room:setPlayerMark(player, difficulty, 1)
					end
					if level ~= 6 then
						selectHero(player, robot, 3, player:getGeneralName())
					else
						room:changeHero(robot, "caiyang", false, false)
					end
					enemyBuff(robot, level)
					if choice then
						robot:setTag("reward_type", sgs.QVariant(choice))
					end
				end
			end
		elseif event == sgs.DrawInitialCards then
			local recordFile = assert(io.open(GER, "r"))
			local level = recordFile:read("*l"):split("=")
			level = tonumber(level[2])
			recordFile:close()
			if splayer:getTag("Kanmusu"):toBool() and level ~= 1 then
				data:setValue(0)
			end
			if splayer:getTag("enemy_buff"):toInt() > 0 then
				data:setValue(data:toInt() + splayer:getTag("enemy_buff"):toInt())
			end
		else
			local reward_type = splayer:getTag("reward_type"):toString()
			if reward_type ~= "" and table.contains(reward_types, reward_type) then
				reward(splayer:getNextAlive(), splayer, reward_type)
				splayer:removeTag("reward_type")
			end
		end
		return false
	end
}


--if not sgs.Sanguosha:getSkill("kan_event_damage") then skills:append(kan_event_damage) end
--if not sgs.Sanguosha:getSkill("kan_event_gameend") then skills:append(kan_event_gameend) end



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
    
    ["kan_event_damage"] = "倍卡",

    ["kan_anjiang"] ="系統設置",
}
kan_anjiang = sgs.General(extension, "kan_anjiang", "kancolle", 4, false, true)
--------------------------------------------------------------------------------------------------------------------------
--kanmusu
--kan_yudachi = sgs.General(extension, "kan_yudachi", "kancolle", 4, false, salvage, salvage)
--kan_yudachi_kai2 = sgs.General(extension, "kan_yudachi_kai2", "kancolle", 3, false,true,salvage)
kan_yudachi = sgs.General(extension, "kan_yudachi", "kancolle", 4, false )
kan_yudachi_kai2 = sgs.General(extension, "kan_yudachi_kai2", "kancolle", 3, false)
--噩梦
kan_emeng = sgs.CreateTriggerSkill{
	name = "kan_emeng", 
	frequency = sgs.Skill_Wake, 
	events = {sgs.EventPhaseStart}, 
    can_wake = function(self, event, player, data, room)
		if player:getPhase() ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		return player:getHp() <= 1
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if 	room:changeMaxHpForAwakenSkill(player, -1) then 
		room:broadcastSkillInvoke(self:objectName())
		room:doLightbox("kan_suo$", 500)
		room:doLightbox("kan_luo$", 500)
		room:doLightbox("kan_men$", 1000)
		room:doLightbox("kan_wo$", 300)
		room:doLightbox("kan_you$", 300)
		room:doLightbox("kan_hui$", 300)
		room:doLightbox("kan_lai$", 300)
		room:doLightbox("kan_le$", 300)
		room:doLightbox("kan_a$", 1000)
		room:doLightbox("kan_emeng$", 2000)
		if player:getGeneralName() == "kan_yudachi" then
			room:changeHero(player, "kan_yudachi_kai2",false, false, false, false)
		elseif player:getGeneral2Name() == "kan_yudachi" then
			room:changeHero(player, "kan_yudachi_kai2",false, false, true, false)
		else 
		room:handleAcquireDetachSkills(player, "kan_yingzi")
		room:handleAcquireDetachSkills(player, "kan_paoxiao")
		room:handleAcquireDetachSkills(player, "kan_chongzhuang")
		end
		room:addPlayerMark(player, "kan_emeng")
		local list = room:getAlivePlayers()
		for _,p in sgs.qlist(list) do
			room:setFixedDistance(player, p, 1)
			room:setFixedDistance(p, player, 1)
		end
		end
		return false
	end, 
}
--狂犬
kan_kuangquan = sgs.CreateTriggerSkill{
	name = "kan_kuangquan",  
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.DamageCaused}, 
	priority = -3,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		if damage.from:hasSkill(self:objectName()) and damage.card and damage.card:isKindOf("Slash") and damage.from:distanceTo(damage.to) <= 1 then
			if not damage.from:askForSkillInvoke(self:objectName(), data) then return end
			room:broadcastSkillInvoke(self:objectName())
			room:doLightbox("kan_kuangquan$", 1000)
			room:loseMaxHp(damage.to, 1)
		end
	end, 
	can_trigger = function(self, target)
		return target
	end
}

--冲撞
kan_chongzhuang = sgs.CreateTriggerSkill{
	name = "kan_chongzhuang", 
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.Dying},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying_data = data:toDying()
		local source = dying_data.who
		if source:hasSkill(self:objectName()) then
			if not source:askForSkillInvoke(self:objectName(), data) then return end
			local target = room:askForPlayerChosen(source, room:getOtherPlayers(source), "kan_chongzhuang")
			if not target then return end
			while target:objectName() ~= source:getNextAlive():objectName() do
				room:getThread():delay(100)
				room:swapSeat(source, source:getNextAlive())
			end
			room:doLightbox("kan_chongzhuang$", 1500)
			local card = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			card:setSkillName(self:objectName())		
			local use = sgs.CardUseStruct()
			use.from = source
			use.to:append(target)
			use.card = card
			room:useCard(use, false)
		end
	end
}

--英姿
kan_yingzi = sgs.CreateTriggerSkill{
    name = "kan_yingzi",
    frequency = sgs.Skill_Frequent,
    events = {sgs.DrawNCards},
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if room:askForSkillInvoke(player, "kan_yingzi", data) then
        	room:broadcastSkillInvoke("kan_emeng")
        	local num = math.random(1, 100)
            local count = data:toInt()  + 1
            if num > 70 then
            	count = count + 1
            elseif num > 92 then
            	count = count + 2
            elseif num > 98 then
            	count = count + 4
            end
            data:setValue(count)
        end
    end
}

--咆哮
kan_paoxiao = sgs.CreateTargetModSkill{
    name = "kan_paoxiao",
    pattern = "Slash",
    residue_func = function(self, player)
        if player:hasSkill(self:objectName()) then
            return 1000
        end
    end,
}

kan_yudachi:addSkill("kan_cat_dd")
kan_yudachi:addSkill("kan_attackRangeShort")
kan_yudachi:addSkill(kan_emeng)
kan_yudachi:addSkill(kan_kuangquan)
kan_yudachi:addRelateSkill("kan_yingzi")
kan_yudachi:addRelateSkill("kan_chongzhuang")
kan_yudachi:addRelateSkill("kan_paoxiao")
kan_yudachi_kai2:addSkill("kan_cat_dd")
kan_yudachi_kai2:addSkill("kan_attackRangeShort")
kan_yudachi_kai2:addSkill(kan_yingzi)
kan_yudachi_kai2:addSkill(kan_paoxiao)
kan_yudachi_kai2:addSkill(kan_chongzhuang)
kan_yudachi_kai2:addSkill(kan_kuangquan)

sgs.LoadTranslationTable{
	["kan_yudachi"] = "夕立", 
	["&kan_yudachi"] = "夕立", 
	["#kan_yudachi"] = "所罗门的噩梦", 
	["~kan_yudachi"] = "真、真是笨蛋！这样就没法战斗了poi！？", 
	["designer:kan_yudachi"] = "Sword Elucidator",
	["cv:kan_yudachi"] = "谷边由美",
	["illustrator:kan_yudachi"] = "リン☆ユウ",
	["$kan_yudachi_start"] = "",
	["$kan_yudachi_equip"] = "",
	["$kan_yudachi_damaged"] = "",
	["$kan_yudachi_attack"] = "",

	["kan_yudachi_kai2"] = "夕立改二", 
	["&kan_yudachi_kai2"] = "夕立改二", 
	["#kan_yudachi_kai2"] = "所罗门的噩梦", 
	["~kan_yudachi_kai2"] = "真、真是笨蛋！这样就没法战斗了poi！？", 
	["designer:kan_yudachi_kai2"] = "Sword Elucidator",
	["cv:kan_yudachi_kai2"] = "谷边由美",
	["illustrator:kan_yudachi_kai2"] = "",

	["kan_emeng"] = "噩梦「所罗门的噩梦poi」",
	["$kan_emeng1"] = "所罗门的噩梦，让你们见识一下！",
	["$kan_emeng2"] = "那么，让我们举办一场华丽的派对吧！",
	["$kan_emeng3"] = "夕立、突击poi。",
	[":kan_emeng"] = "<font color=\"purple\"><b>觉醒技，</b></font>回合开始时，若你的体力值不大于1，你失去一点体力上限并获得技能【英姿】【咆哮】和【冲撞】（当你进入濒死时，移动到一名其他角色的左侧并视为对其使用一张【杀】。），你与所有角色计算距离时为1，其他角色与你计算距离时为1。",
	["kan_emeng$"] = "image=image/animate/kan_emeng.png",

	["kan_suo$"] = "所    ",
	["kan_luo$"] = "  罗  ",
	["kan_men$"] = "    门",
	["kan_wo$"] = "\n我          ",
	["kan_you$"] = "\n  又        ",
	["kan_hui$"] = "\n    回      ",
	["kan_lai$"] = "\n      来    ",
	["kan_le$"] = "\n        了  ",
	["kan_a$"] = "\n          啊",

	["kan_kuangquan"] = "狂犬「咬死你poi」",
	["$kan_kuangquan1"] = "随便找一个打了poi？",
	["$kan_kuangquan2"] = "首先从哪里开始打呢？",
	[":kan_kuangquan"] = "你对距离为1的角色使用【杀】造成伤害时，可以令目标失去失去一点体力上限。",
	["kan_kuangquan$"] = "image=image/animate/kan_kuangquan.png",

	["kan_chongzhuang"] = "冲撞「风帆突击」",
	["$kan_chongzhuang"] = "即使是把打开船帆，也要继续战斗！",
	[":kan_chongzhuang"] = "当你进入濒死时，移动到一名其他角色的左侧并视为对其使用一张【杀】。",
	["kan_chongzhuang$"] = "image=image/animate/kan_chongzhuang.png",

	["kan_yingzi"] = "英姿「孤舰突击」",
	[":kan_yingzi"] = "摸牌阶段，你可以额外摸一些牌。",
	["kan_paoxiao"] = "咆哮「噩梦般的雷击」",
	[":kan_paoxiao"] = "你在出牌阶段内使用【杀】时无次数限制。",

}

--kan_kongou = sgs.General(extension, "kan_kongou", "kancolle", 4, false, salvage, salvage)
kan_kongou = sgs.General(extension, "kan_kongou", "kancolle", 4, false )


kan_nuequ = sgs.CreateViewAsSkill{
	name = "kan_nuequ",
	n = 1,
	response_or_use = true,
		view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end, 
	view_as = function(self, cards)
	if #cards == 1 then 
		local card = kan_nuequcard:clone()
		card:addSubcard(cards[1])
		card:setSkillName(self:objectName())
		return card
		end
	end,
	enabled_at_play = function(self, player)
		return not sgs.Self:hasUsed("#kan_nuequ")
	end,
}

kan_nuequcard = sgs.CreateSkillCard{
	name = "kan_nuequ",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select) --必须
	local card = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, -1)
	card:setSkillName(self:objectName())
	local min_hp = 999
	local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		for _, p in sgs.qlist(sgs.Self:getAliveSiblings()) do
			min_hp = math.min(min_hp, p:getHp())
		end
		if to_select:objectName() ~= sgs.Self:objectName() and sgs.Self:canSlash(to_select, card,false)  then
			return card:targetFilter(qtargets, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, qtargets) and to_select:getHp() == min_hp 
		end
	end,
	on_use = function(self, room, source, targets) 
		if #targets > 0 then
			local card = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_NoSuit, 0)
			card:setSkillName(self:objectName())
			card:addSubcard(self:getSubcards():first())
			local use = sgs.CardUseStruct()
			use.from = source
			for _,target in ipairs(targets) do
				use.to:append(target)
			end
			use.card = card
			room:useCard(use, false)
		end
	end,
}

kan_BurningLove = sgs.CreateTriggerSkill{
	name = "kan_BurningLove",  
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.DamageCaused},  
	on_trigger = function(self, event, player, data) 
		local room = player:getRoom()
		local damage = data:toDamage()
		if event == sgs.DamageCaused then
				if damage.from and damage.from:isAlive() and damage.from:hasSkill(self:objectName()) and damage.nature == sgs.DamageStruct_Fire and 
				damage.to and damage.to:isAlive() and 
				damage.card and damage.card:isKindOf("FireSlash") and  room:askForSkillInvoke(player, self:objectName(), data) then
				room:notifySkillInvoked(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
							local re = sgs.RecoverStruct()
						re.who = player	
						room:recover(damage.to,re,true)
						return true
						end	
		end
		return false
	end,
}

kan_kongou:addSkill("kan_cat_fbb")
kan_kongou:addSkill("kan_attackRangeLong")
kan_kongou:addSkill(kan_nuequ)
kan_kongou:addSkill(kan_BurningLove)

sgs.LoadTranslationTable{
	["kan_kongou"] = "金剛",
	["&kan_kongou"] = "金剛",
	["@Kongou"] = "艦隊collection",
	["#kan_kongou"] = "大傻",
	["~kan_kongou"] = "Shit！从提督那里得到的重要装备啊！",
	["designer:kan_kongou"] = "Sword Elucidator",
	["cv:kan_kongou"] = "東山奈央",
	["illustrator:kan_kongou"] = "",
	["$kan_kongou_start"] = "",
	["$kan_kongou_equip"] = "",
	["$kan_kongou_damaged"] = "",
	["$kan_kongou_attack"] = "",

	["kan_nuequ"] = "杀驱「傻级只会打驱逐舰吧？」",
	["$kan_nuequ1"] = "射击！Fire～！",
	["$kan_nuequ2"] = "全火炮！开火！",
	[":kan_nuequ"] = "<font color=\"green\"><b>出牌阶段限一次，</b></font>你可以将一张手牌视为对场上体力最少的一名角色使用一张火属性的【杀】。该【杀】不计入出牌阶段次数限制。",
	["kan_BurningLove"] = "Burning Love！",
	["$kan_BurningLove1"] = "Burning Love！！",
	["$kan_BurningLove2"] = "Burning Valentine Love！！",
	[":kan_BurningLove"] = "每当你使用火属性的【杀】造成伤害时，你可以令该伤害改为回复一点体力。",
	["BLRecover"] = "令该伤害改为回复一点体力",
	["BLDamage"] = "令该伤害+1",
	
	
	
}



--kan_kongou = sgs.General(extension, "kan_kongou", "kancolle", 4, false, salvage, salvage)
kan_kongou = sgs.General(extension, "kan_kongou", "kancolle", 4, false )

sgs.LoadTranslationTable{
	
	["fanghuo"] = "放火「烧甲板」",
	["#fanghuo"] = " %from 的【着火】 标记被触发，受到自身造成的一点火焰伤害，",
	["@FireCaused"] = "着火",
	["$fanghuo1"] = "最上，出击了哟。",
	["$fanghuo2"] = "敌舰发现！攻击—！",
	[":fanghuo"] = "你使用的【杀】造成伤害时，你可以令目标附加一个【着火】标记。\n\n着火：\n拥有【着火】标记的角色出牌阶段结束时，受到自身造成的一点火焰伤害，然后有25%的概率失去一个【着火】标记。\n拥有【着火】标记时，舰载机类技能无法使用。",
	["jianhun"] = "舰魂",
	["$jianhun1"] = "好痛痛痛…我要生气了！",
	["$jianhun2"] = "痛…我要生气了哦！",
	["$jianhun3"] = " 要上的话就尽管来吧。",
	[":jianhun"] = "若场上「西村舰队（最上，时雨）」角色失去的总体力值不少于2，或你拥有【着火】标记，你可以将一张牌当做无视使用次数限制和距离的【杀】使用或打出。",
	["Mogami"] = "最上",
	["&Mogami"] = "最上",
	["@Mogami"] = "舰队collection/wows",
	["#Mogami"] = "最爹",
	["~Mogami"] = "唔…这下要是继续战斗的话就困难了。",
	["designer:Mogami"] = "Sword Elucidator",
	["cv:Mogami"] = "洲崎綾",
	["illustrator:Mogami"] = "ケースワベ【K-SUWABE】",
	
	
}





sgs.Sanguosha:addSkills(skills)

return {extension}