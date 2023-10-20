extension = sgs.Package("zz")
local debug = false
savedata = "save.json" --存档
readData = function()
    local json = require "json"
    local record = io.open(savedata, "r")
    local t = { Record = {} }
    if record ~= nil then
        local content = record:read("*all")
        t = json.decode(content) or t
        record:close()
    end
    return t
end
writeData = function(t)
    local record = assert(io.open(savedata, "w"))
    local order = { "Record"}
    setmetatable(order, { __index = table })
    local content = json.encode(t, { indent = true, level = 1, keyorder = order })
    record:write(content)
    record:close()
end
saveRecord = function(player, record_type) --record_type: 0. +1 gameplay , 1. +1 win , 2. +1 win & +1 gameplay
    assert(record_type >= 0 and record_type <= 2, "record_type should be 0, 1 or 2")

    local t = readData()

    local all = sgs.Sanguosha:getLimitedGeneralNames()
    for _, name in pairs(all) do
        local general = sgs.Sanguosha:getGeneral(name)
        local package = general:getPackage()
        if t.Record[package] == nil then
            t.Record[package] = { }
        end
        if t.Record[package][name] == nil then
            t.Record[package][name] = { 0, 0 } 
        end
    end

    local name = player:getGeneralName()
    local package = player:getGeneral():getPackage()
    local package2 = ""
    local name2 = ""
    if player:getGeneral2() then
        name2 = player:getGeneral2Name()
        package2 = player:getGeneral2():getPackage()
    end
    if record_type ~= 0 then -- record_type 1 or 2
        if t.Record[package][name] then
            t.Record[package][name][1] = t.Record[package][name][1] + 1
        end
        if name2 ~= "" and name ~= name2 and t.Record[package2][name2] then
            t.Record[package2][name2][1] = t.Record[package2][name2][1] + 1
        end
    end
    if record_type ~= 1 then -- record_type 0 or 2
        if t.Record[package][name] then
            t.Record[package][name][2] = t.Record[package][name][2] + 1
        end
        if name2 ~= "" and name ~= name2 and t.Record[package2][name2] then
            t.Record[package2][name2][2] = t.Record[package2][name2][2] + 1
        end
    end

    writeData(t)
end


allrecord = sgs.CreateTriggerSkill {
    --[[Rule: 1. single mode +1 gameplay when game STARTED & +1 win (if win) when game FINISHED;
		2. online mode +1 gameplay & +1 win (if win) simultaneously when game FINISHED;
		3. single mode escape CAN +1 gameplay, online mode escape CANNOT +1 gameplay;
		4. +1 win (if win) when game FINISHED (no escape);
		5. online mode trust when game FINISHED CANNOT +1 neither gameplay nor win
		
	规则：1. 单机模式在游戏开始时+1游玩次数 & 在游戏结束时+1胜利次数（如果胜利）；
		2. 联机模式在游戏结束时同时+1游玩次数 & +1胜利次数（如果胜利）；
		3. 单机模式逃跑可以+1游玩次数，联机模式逃跑则不能+1游玩次数；
		4. 游戏结束时依然存在的玩家（没有逃跑）才会+1胜利次数（如果胜利）；
		5. 联机模式在游戏结束时托管的玩家不会记录游玩次数和胜利次数
]]
    name = "allrecord",
    events = { sgs.GameOverJudge },
    global = true,
    priority = 0,
    can_trigger = function(self, player)
        return true
    end,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if debug then return end
        local t = getWinner(room, player)
        if not t then return end
        local function loser(role)
            local tt = t:split("+")
            if not table.contains(tt, role) then return true end
            return false
        end

        local owner = room:getOwner()
        local ip = owner:getIp()
        --if ip ~= "" and string.find(ip, "127.0.0.1") and player:objectName() == owner:objectName() then
        for _, p in sgs.qlist(room:getAllPlayers(true)) do
            if loser(p:getRole()) then
                saveRecord(p, 0)
            else
                saveRecord(p, 2)
            end
        end
        --end
    end
}


addToSkills(allrecord)
winshow = sgs.General(extension, "winshow", "", 0, true, true, false)
winshow:setGender(sgs.General_Sexless)
winrate = sgs.CreateMasochismSkill {
    name = "winrate",
    on_damaged = function()
    end
}
winshow:addSkill(winrate)

--【显示胜率】（置于页底以确保武将名翻译成功）
local g_property = "<font color='red'><b>胜率</b></font>"


local t = readData()

if next(t.Record) ~= nil then
    local round = function(num, idp)
        local mult = 10 ^ (idp or 0)
        return math.floor(num * mult + 0.5) / mult
    end
    for package, contents  in pairs(t.Record) do
        for key, rate in pairs(contents) do
            local general = sgs.Sanguosha:getGeneral(key)
                local text = rate[1] .. "/" .. rate[2]
                if rate[2] == 0 then
                    rate = "未知"
                else
                    rate = round(rate[1] / rate[2] * 100) .. "%"
                end
                if key ~= "GameTimes" then
                    local translateName = sgs.Sanguosha:translate(key)
                   
                    local translatePackage = sgs.Sanguosha:translate(package)

                    g_property = g_property .. "\n" .. translateName
                    g_property = g_property .. "[" .. translatePackage.."]"
                    
                    g_property = g_property .. " = " .. text .. " <b>(" .. rate .. ")</b>"
                end
        end
    end
end
sgs.LoadTranslationTable {
    ["zz"] = "胜率",
    ["winshow"] = "胜率",
    ["#winshow"] = "角色资讯",
    ["designer:winshow"] = "高达杀制作组",
    ["cv:winshow"] = "贴吧：高达杀s吧",
    ["illustrator:winshow"] = "QQ群：565837324",
    ["winrate"] = "胜率",
    [":winrate"] = g_property
}
return { extension }
