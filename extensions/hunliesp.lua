extension = sgs.Package("hunliesp", sgs.Package_GeneralPack)


sgs.LoadTranslationTable{
	["hunliesp"] = "魂烈SP神",
}

do
    require  "lua.config"
	local config = config
	local kingdoms = config.kingdoms
	        table.insert(kingdoms, "sy_god")
	config.color_de = "#74029D"
end


sgs.LoadTranslationTable{
	["sy_god"] = "神",
}


function forbidAllCurrentSkills(vic, trigger_name)
	local room = vic:getRoom()
	local skill_list = {}
	for _, sk in sgs.qlist(vic:getVisibleSkillList()) do
		if not table.contains(skill_list, sk:objectName()) then table.insert(skill_list, sk:objectName()) end
	end
	if #skill_list > 0 then
		vic:setTag("Qingcheng", sgs.QVariant(table.concat(skill_list, "+")))
		for _, skill_qc in ipairs(skill_list) do
			room:addPlayerMark(vic, "Qingcheng"..skill_qc)
			room:addPlayerMark(vic, trigger_name..skill_qc)
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:filterCards(p, p:getCards("he"), true)
			end
		end
	end
end

function forbidNonCompulsorySkills(vic, trigger_name)
	local room = vic:getRoom()
	local skill_list = {}
	for _, sk in sgs.qlist(vic:getVisibleSkillList()) do
		if not table.contains(skill_list, sk:objectName()) then 
			if sk:getFrequency() ~= sgs.Skill_Compulsory and sk:getFrequency() ~= sgs.Skill_Wake then
				table.insert(skill_list, sk:objectName())
			end
		end
	end
	if #skill_list > 0 then
		vic:setTag("Qingcheng", sgs.QVariant(table.concat(skill_list, "+")))
		for _, skill_qc in ipairs(skill_list) do
			room:addPlayerMark(vic, "Qingcheng"..skill_qc)
			room:addPlayerMark(vic, trigger_name..skill_qc)
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:filterCards(p, p:getCards("he"), true)
			end
		end
	end
end

function activateAllSkills(vic, trigger_name)
	local room = vic:getRoom()
	local Qingchenglist = vic:getTag("Qingcheng"):toString():split("+")
	if #Qingchenglist > 0 then
		for _, name in ipairs(Qingchenglist) do
			room:setPlayerMark(vic, "Qingcheng"..name, 0)
			room:setPlayerMark(vic, trigger_name..name, 0)
		end
		vic:removeTag("Qingcheng")
		for _, t in sgs.qlist(room:getAllPlayers()) do
			room:filterCards(t, t:getCards("he"), true)
		end
	end
end


function forbidAllSkillsWithException(vic, except_skillName)
	local room = vic:getRoom()
	local skill_list = {}
	for _, sk in sgs.qlist(vic:getVisibleSkillList()) do
		if  sk:objectName() ~= except_skillName and (not table.contains(skill_list, sk:objectName())) then
			table.insert(skill_list, sk:objectName())
		end
	end
	if #skill_list > 0 then
		vic:setTag("Qingcheng", sgs.QVariant(table.concat(skill_list, "+")))
		for _, skill_qc in ipairs(skill_list) do
			room:addPlayerMark(vic, "Qingcheng"..skill_qc)
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:filterCards(p, p:getCards("he"), true)
			end
		end
	end
end


--全局配置类技能
shajue_slash = sgs.CreateTriggerSkill{
	name = "shajue_slash",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end
}

sgkgodmaxcards = sgs.CreateMaxCardsSkill{
	name = "#sgkgodmaxcards",
	extra_func = function(self, target)
		local n = 0
		return n
	end
}

yinyang_lose = sgs.CreateTriggerSkill{
	name = "#yinyang_lose",
	frequency = sgs.Skill_Compulsory,
	global = true,
	events = {sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data, room)
		if data:toString() == "sgkgodjiyang" then
			if player:getMark("&jiyang_positive") > 0 then player:loseAllMarks("&jiyang_positive") end
		end
		if data:toString() == "sgkgodjiyin" then
			if player:getMark("&jiyin_negative") > 0 then player:loseAllMarks("&jiyin_negative") end
		end
		if data:toString() == "sgkgodxiangsheng" then
			if player:getMark("&xiangsheng_balance") > 0 then player:loseAllMarks("&xiangsheng_balance") end
		end
	end
}

hunliesp_global_drawcards = sgs.CreateDrawCardsSkill{
	name = "#hunliesp_global_drawcards",
	global = true,
	draw_num_func = function(self, player, n)
		local room = player:getRoom()
		local x = 0
		for _, t in sgs.qlist(room:getAllPlayers()) do
			if t:hasSkill("sgkgodzhiti") then
				local enabled_items = player:property(""..t:objectName().."_ZhitiEnabled"):toString():split("+")
				if #enabled_items > 0 then
					if table.contains(enabled_items, "spgodzl_stealOneDraw") then x = x - 1 end
				end
			end
		end
		if player:getMark("zhiti_exdraw") > 0 then x = x + player:getMark("zhiti_exdraw") end
		return n + x
	end
}

hunliesp_global_clear = sgs.CreateTriggerSkill{
	name = "#hunliesp_global_clear",
	global = true,
	can_trigger = function(self, target)
		return true
	end,
	priority = 1,
	events = {sgs.EventPhaseChanging, sgs.PreHpRecover, sgs.PreHpLost, sgs.HpChanged, sgs.MaxHpChange, sgs.MaxHpChanged, sgs.Dying, sgs.BeforeCardsMove, sgs.DamageInflicted, sgs.Dying},
	on_trigger = function(self, event, player, data, room)
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:getMark("jieying_rob_temp") > 0 then room:setPlayerMark(p, "jieying_rob_temp", 0) end
		end
	end
}


local sgkgodhidden = sgs.SkillList()
if not sgs.Sanguosha:getSkill("shajue_slash") then sgkgodhidden:append(shajue_slash) end
if not sgs.Sanguosha:getSkill("#sgkgodmaxcards") then sgkgodhidden:append(sgkgodmaxcards) end
if not sgs.Sanguosha:getSkill("#yinyang_lose") then sgkgodhidden:append(yinyang_lose) end
if not sgs.Sanguosha:getSkill("#hunliesp_global_drawcards") then sgkgodhidden:append(hunliesp_global_drawcards) end
if not sgs.Sanguosha:getSkill("#hunliesp_global_clear") then sgkgodhidden:append(hunliesp_global_clear) end
sgs.Sanguosha:addSkills(sgkgodhidden)


sgs.LoadTranslationTable{
	["shajue_slash"] = "杀绝",
}


--SP神诸葛亮
sgkgodspzhuge = sgs.General(extension, "sgkgodspzhuge", "sy_god", 7)


local json = require ("json")
function isNormalGameMode(mode_name)
	return mode_name:endsWith("p") or mode_name:endsWith("pd") or mode_name:endsWith("pz")
end
function getZhitianSkills()
	local room = sgs.Sanguosha:currentRoom()
	local Huashens = {}
	local generals = sgs.Sanguosha:getLimitedGeneralNames()
	local banned = {"zuoci", "guzhielai", "dengshizai", "jiangboyue", "bgm_xiahoudun"}
	local zhitian_skills = {}
	local alives = room:getAlivePlayers()
	for _,p in sgs.qlist(alives) do
		if not table.contains(banned, p:getGeneralName()) then
			table.insert(banned, p:getGeneralName())
		end
		if p:getGeneral2() and not table.contains(banned, p:getGeneral2Name()) then
			table.insert(banned, p:getGeneral2Name())
		end
	end
	if (isNormalGameMode(room:getMode()) or room:getMode():find("_mini_")or room:getMode() == "custom_scenario") then
		table.removeTable(generals, sgs.GetConfig("Banlist/Roles", ""):split(","))
	elseif (room:getMode() == "04_1v3") then
		table.removeTable(generals, sgs.GetConfig("Banlist/HulaoPass", ""):split(","))
	elseif (room:getMode() == "06_XMode") then
		table.removeTable(generals, sgs.GetConfig("Banlist/XMode", ""):split(","))
		for _,p in sgs.qlist(room:getAlivePlayers())do
			table.removeTable(generals, (p:getTag("XModeBackup"):toStringList()) or {})
		end
	elseif (room:getMode() == "02_1v1") then
		table.removeTable(generals, sgs.GetConfig("Banlist/1v1", ""):split(","))
		for _,p in sgs.qlist(room:getAlivePlayers())do
			table.removeTable(generals, (p:getTag("1v1Arrange"):toStringList()) or {})
		end
	end
	for i=1, #generals, 1 do
		if table.contains(banned, generals[i]) then
			table.remove(generals, i)
		end
	end
	for i=1, #generals, 1 do
		local ageneral = sgs.Sanguosha:getGeneral(generals[i])
		if ageneral ~= nil then 
			local N = ageneral:getVisibleSkillList():length()
			local x = 0
			for _, pe in sgs.qlist(room:getAlivePlayers()) do
				for _, sk in sgs.qlist(ageneral:getVisibleSkillList()) do
					if pe:hasSkill(sk:objectName()) then x = x + 1 end
				end
			end
			if x == N then table.remove(generals, i) end
		end
	end
	if #generals > 0 then
		for i=1, #generals, 1 do
			table.insert(Huashens, generals[i])
		end
	end
	if #Huashens > 0 then
		for _, general_name in ipairs(Huashens) do
			local general = sgs.Sanguosha:getGeneral(general_name)		
			for _, sk in sgs.qlist(general:getVisibleSkillList()) do
				table.insert(zhitian_skills, sk:objectName())
			end
		end
	end
	if #zhitian_skills > 0 then
		for _, pe in sgs.qlist(room:getAlivePlayers()) do
			for _, gsk in sgs.qlist(pe:getVisibleSkillList()) do
				if table.contains(zhitian_skills, gsk:objectName()) then table.removeOne(zhitian_skills, gsk:objectName()) end
			end
		end
	end
	if #zhitian_skills > 0 then
		return zhitian_skills
	else
		return {}
	end
end


--参数1：n，返回的table中技能的数量，Number类型（比如填3则最终的table里装填3个技能）
--参数2/3/4：description，所需的技能描述，String类型，一般利用string.find(skill:getDescription(), description)判断，彼此为并集。若无描述要求则填-1
--参数5：includeLord，是否包括主公技，Bool类型，true则包括，false则不包括
function getSpecificDescriptionSkills(n, description1, description2, description3, includeLord)
	local skill_table = {}  --这个用来存放初选满足函数要求的技能
	local output_table = {}  --这个用来存放最终满足函数要求的技能
	local d_paras = {description1, description2, description3}
	local d_needs = {}
	for i = 1, #d_paras do
		if d_paras[i] ~= -1 then table.insert(d_needs, d_paras[i]) end
	end
	local skills = getZhitianSkills()
	for _, _sk in ipairs(skills) do
		local _skill = sgs.Sanguosha:getSkill(_sk)
		local critical_des = string.sub(_skill:getDescription(), 1, 42)
		if #d_needs > 0 then
			for _, _des in ipairs(d_needs) do
				if string.find(critical_des, _des, 1) then
					if includeLord == false then
						if (not _skill:isLordSkill()) and (not _skill:isAttachedLordSkill()) and _skill:getFrequency() ~= sgs.Skill_Wake then
							table.insert(skill_table, _sk)
							break
						end
					elseif includeLord == true then
						table.insert(skill_table, _sk)
						break
					end
				end
			end
		else
			if includeLord == false then
				if (not _skill:isLordSkill()) and (not _skill:isAttachedLordSkill()) and _skill:getFrequency() ~= sgs.Skill_Wake then
					table.insert(skill_table, _sk)
					break
				end
			elseif includeLord == true then
				table.insert(skill_table, _sk)
				break
			end
		end
	end
	if #skill_table > 0 then  --整理，准备导出最终满足的技能table
		for i = 1, n do
			local j = math.random(1, #skill_table)
			table.insert(output_table, skill_table[j])
			table.removeOne(skill_table, skill_table[j])
			if #skill_table == 0 then break end
		end
	end
	return output_table
end


--[[
	技能名：妖智
	相关武将：SP神诸葛亮
	技能描述：回合开始阶段，回合结束阶段，出牌阶段限一次，当你受到伤害后，你可以摸一张牌，然后从随机三个能在此时机发动的技能中选择一个并发动。
	引用：sgkgodyaozhi
]]--
sgkgodyaozhi = sgs.CreateTriggerSkill{
	name = "sgkgodyaozhi",
	frequency = sgs.Skill_NotFrequent,
	priority = 5,
	events = {sgs.GameStart, sgs.EventAcquireSkill, sgs.EventLoseSkill, sgs.EventPhaseStart, sgs.Damaged, sgs.DamageComplete, sgs.CardFinished, sgs.EventPhaseEnd, sgs.MarkChanged},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.GameStart then
			local yaozhi_gained = {}
			player:setTag("yaozhi_gained", sgs.QVariant(table.concat(yaozhi_gained, "+")))
		elseif event == sgs.EventAcquireSkill then
			if data:toString() == self:objectName() then
				local yaozhi_gained = {}
				player:setTag("yaozhi_gained", sgs.QVariant(table.concat(yaozhi_gained, "+")))
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == self:objectName() then
				player:removeTag("yaozhi_gained")
				player:removeTag("yaozhi_temp_skill")
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start then
				if player:askForSkillInvoke(self:objectName(), data) then
					room:addPlayerMark(player, self:objectName().."engine")
					if player:getMark(self:objectName().."engine") > 0 then
						room:broadcastSkillInvoke(self:objectName())
						player:drawCards(1, self:objectName())
						local yaozhi_gained = player:getTag("yaozhi_gained"):toString():split("+")
						local yaozhi_playerstart = getSpecificDescriptionSkills(3, "准备阶段，", "回合开始阶段，", "准备阶段开始时，", false)
						if #yaozhi_playerstart > 0 then
							local yaozhi = room:askForChoice(player, self:objectName(), table.concat(yaozhi_playerstart, "+"), data)
							if not table.contains(yaozhi_gained, yaozhi) then table.insert(yaozhi_gained, yaozhi) end
							player:setTag("yaozhi_gained", sgs.QVariant(table.concat(yaozhi_gained, "+")))
							local temp_msg = sgs.LogMessage()
							temp_msg.from = player
							temp_msg.arg = yaozhi
							temp_msg.type = "#YaozhiTempSkill"
							room:sendLog(temp_msg)
							room:acquireSkill(player, yaozhi)
							player:setTag("yaozhi_temp_skill", sgs.QVariant("yaozhi_temp_"..yaozhi))
						end
						room:removePlayerMark(player, self:objectName().."engine")
					end
				end
			end
			if player:getPhase() == sgs.Player_Play then
				if player:askForSkillInvoke(self:objectName(), data) then
					room:addPlayerMark(player, self:objectName().."engine")
					if player:getMark(self:objectName().."engine") > 0 then
						room:broadcastSkillInvoke(self:objectName())
						player:drawCards(1, self:objectName())
						local yaozhi_gained = player:getTag("yaozhi_gained"):toString():split("+")
						local yaozhi_playerplay = getSpecificDescriptionSkills(3, "出牌阶段，", "阶段技，", "出牌阶段限一次，", false)
						if #yaozhi_playerplay > 0 then
							local yaozhi = room:askForChoice(player, self:objectName(), table.concat(yaozhi_playerplay, "+"), data)
							if not table.contains(yaozhi_gained, yaozhi) then table.insert(yaozhi_gained, yaozhi) end
							player:setTag("yaozhi_gained", sgs.QVariant(table.concat(yaozhi_gained, "+")))
							local temp_msg = sgs.LogMessage()
							temp_msg.from = player
							temp_msg.arg = yaozhi
							temp_msg.type = "#YaozhiTempSkill"
							room:sendLog(temp_msg)
							room:acquireSkill(player, yaozhi)
							player:setTag("yaozhi_temp_skill", sgs.QVariant("yaozhi_temp_"..yaozhi))
						end
						room:removePlayerMark(player, self:objectName().."engine")
					end
				end
			end
			if player:getPhase() == sgs.Player_Finish then
				if player:askForSkillInvoke(self:objectName(), data) then
					room:addPlayerMark(player, self:objectName().."engine")
					if player:getMark(self:objectName().."engine") > 0 then
						room:broadcastSkillInvoke(self:objectName())
						player:drawCards(1, self:objectName())
						local yaozhi_gained = player:getTag("yaozhi_gained"):toString():split("+")
						local yaozhi_playerfinish = getSpecificDescriptionSkills(3, "结束阶段，", "结束阶段开始时，", -1, false)
						if #yaozhi_playerfinish > 0 then
							local yaozhi = room:askForChoice(player, self:objectName(), table.concat(yaozhi_playerfinish, "+"), data)
							if not table.contains(yaozhi_gained, yaozhi) then table.insert(yaozhi_gained, yaozhi) end
							player:setTag("yaozhi_gained", sgs.QVariant(table.concat(yaozhi_gained, "+")))
							local temp_msg = sgs.LogMessage()
							temp_msg.from = player
							temp_msg.arg = yaozhi
							temp_msg.type = "#YaozhiTempSkill"
							room:sendLog(temp_msg)
							room:acquireSkill(player, yaozhi)
							player:setTag("yaozhi_temp_skill", sgs.QVariant("yaozhi_temp_"..yaozhi))
						end
						room:removePlayerMark(player, self:objectName().."engine")
					end
				end
			end
		elseif event == sgs.Damaged then
			local damage = data:toDamage()
			if damage.damage > 0 and player:askForSkillInvoke(self:objectName(), data) then
				room:addPlayerMark(player, self:objectName().."engine")
				if player:getMark(self:objectName().."engine") > 0 then
					room:broadcastSkillInvoke(self:objectName())
					player:drawCards(1, self:objectName())
					local yaozhi_gained = player:getTag("yaozhi_gained"):toString():split("+")
					local yaozhi_damaged = getSpecificDescriptionSkills(3, "你受到伤害后", "你受到1点伤害后", "你受到一次伤害", false)
					if #yaozhi_damaged > 0 then
						local yaozhi = room:askForChoice(player, self:objectName(), table.concat(yaozhi_damaged, "+"), data)
						if not table.contains(yaozhi_gained, yaozhi) then table.insert(yaozhi_gained, yaozhi) end
						player:setTag("yaozhi_gained", sgs.QVariant(table.concat(yaozhi_gained, "+")))
						local temp_msg = sgs.LogMessage()
						temp_msg.from = player
						temp_msg.arg = yaozhi
						temp_msg.type = "#YaozhiTempSkill"
						room:sendLog(temp_msg)
						room:acquireSkill(player, yaozhi)
						player:setTag("yaozhi_temp_skill", sgs.QVariant("yaozhi_temp_"..yaozhi))
					end
					room:removePlayerMark(player, self:objectName().."engine")
				end
			end
		elseif event == sgs.DamageComplete then
			local temp_ta = player:getTag("yaozhi_temp_skill"):toString():split("+")
			if #temp_ta > 0 then
				local yaozhi_temp = string.sub(temp_ta[1], 13)
				if player:hasSkill(yaozhi_temp) then
					room:handleAcquireDetachSkills(player, "-"..yaozhi_temp)
					player:removeTag("yaozhi_temp_skill")
				end
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			local temp_ta = player:getTag("yaozhi_temp_skill"):toString():split("+")
			if #temp_ta > 0 then
				local yaozhi_temp = string.sub(temp_ta[1], 13)
				if use.card and (use.card:isVirtualCard() or use.card:getTypeId() == sgs.Card_TypeSkill) and string.find(temp_ta[1], use.card:getSkillName()) then
					if player:hasSkill(use.card:getSkillName()) or player:hasSkill(yaozhi_temp) then
						room:handleAcquireDetachSkills(player, "-"..yaozhi_temp)
						player:removeTag("yaozhi_temp_skill")
					end
				end
			end
		elseif event == sgs.EventPhaseEnd then
			local phase = player:getPhase()
			if phase == sgs.Player_Start or phase == sgs.Player_Play or phase == sgs.Player_Finish then
				local temp_ta = player:getTag("yaozhi_temp_skill"):toString():split("+")
				if #temp_ta > 0 then
					local yaozhi_temp = string.sub(temp_ta[1], 13)
					if player:hasSkill(yaozhi_temp) then room:handleAcquireDetachSkills(player, "-"..yaozhi_temp) end
				end
				player:removeTag("yaozhi_temp_skill")
			end
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			local temp_ta = player:getTag("yaozhi_temp_skill"):toString():split("+")
			if #temp_ta > 0 then
				local temp_sk = string.sub(temp_ta[1], 13)
				if string.find(mark.name, temp_sk) and mark.gain == -1 and sgs.Sanguosha:getViewAsSkill(temp_sk) == nil then
					room:handleAcquireDetachSkills(player, "-"..temp_sk)
					room:removeTag("yaozhi_temp_skill")
				end
			end
		end
		return false
	end
}


sgkgodspzhuge:addSkill(sgkgodyaozhi)


--[[
	技能名：星陨
	相关武将：SP神诸葛亮
	技能描述：锁定技，回合结束后，你减1点体力上限，然后获得因“妖智”选择过的一个技能。
	引用：sgkgodxingyun
]]--
sgkgodxingyun = sgs.CreateTriggerSkill{
	name = "sgkgodxingyun",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	priority = 0,
	on_trigger = function(self, event, player, data, room)
		local change = data:toPhaseChange()
		if change.from == sgs.Player_Finish then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			room:loseMaxHp(player)
			if player:isAlive() then
				local yaozhi_gained = player:getTag("yaozhi_gained"):toString():split("+")
				if #yaozhi_gained > 0 then
					local xingyun = room:askForChoice(player, self:objectName(), table.concat(yaozhi_gained, "+"), data)
					room:handleAcquireDetachSkills(player, xingyun)
					table.removeOne(yaozhi_gained, xingyun)
					player:setTag("yaozhi_gained", sgs.QVariant(table.concat(yaozhi_gained, "+")))
				end
			end
		end
	end
}


sgkgodspzhuge:addSkill(sgkgodxingyun)


sgs.LoadTranslationTable{
    ["sgkgodspzhuge"] = "SP神诸葛亮",
	["&sgkgodspzhuge"] = "神诸葛亮",
	["#sgkgodspzhuge"] = "绝代智谋",
	["~sgkgodspzhuge"] = "七星灯灭，魂归九州……",
	["sgkgodyaozhi"] = "妖智",
	[":sgkgodyaozhi"] = "准备阶段，结束阶段，出牌阶段限一次，当你受到伤害后，你可以摸一张牌，然后从随机三个能在此时机发动的技能中选择一个并发动。",
	["$sgkgodyaozhi1"] = "星辰之力，助我灭敌！",
	["$sgkgodyaozhi2"] = "世间计谋，尽在掌控。",
	["#YaozhiTempSkill"] = "%from 临时获得技能“%arg”",
	["sgkgodxingyun"] = "星陨",
	[":sgkgodxingyun"] = "锁定技，回合结束后，你减1点体力上限，然后获得因“妖智”选择过的一个技能。",
	["$sgkgodxingyun1"] = "七星不灭，法力不竭！",
	["$sgkgodxingyun2"] = "斗转星移，七星借命！",
	["designer:sgkgodspzhuge"] = "魂烈",
	["illustrator:sgkgodspzhuge"] = "魂烈",
	["cv:sgkgodspzhuge"] = "魂烈",
}


--SP神吕布
sgkgodsplvbu = sgs.General(extension, "sgkgodsplvbu", "sy_god", 2)


function getSlashRelatedSkills(n, includeWake)
	local skill_table = {}  --这个用来存放初选满足函数要求的技能
	local output_table = {}  --这个用来存放最终满足函数要求的技能
	local skills = getZhitianSkills()
	for _, _sk in ipairs(skills) do
		local _skill = sgs.Sanguosha:getSkill(_sk)
		if string.find(_skill:getDescription(), "【杀】") then
			if (not _skill:isLordSkill()) and (not _skill:isAttachedLordSkill()) then
				if includeWake == true then
					table.insert(skill_table, _sk)
				else
					if _skill:getFrequency() ~= sgs.Skill_Wake then table.insert(skill_table, _sk) end
				end
			end
		end
	end
	if #skill_table > 0 then  --整理，准备导出最终满足的技能table
		for i = 1, n do
			local j = math.random(1, #skill_table)
			table.insert(output_table, skill_table[j])
			table.removeOne(skill_table, skill_table[j])
			if #skill_table == 0 then break end
		end
	end
	return output_table
end


--[[
	技能名：罗刹
	相关武将：SP神吕布
	技能描述：锁定技，游戏开始时，你随机获得3个与【杀】有关的技能。当其他角色进入濒死状态时，你摸两张牌，然后随机获得1个与【杀】有关的技能。
	引用：sgkgodluocha
]]--
sgkgodluocha = sgs.CreateTriggerSkill{
	name = "sgkgodluocha",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.FetchDrawPileCard, sgs.Dying},
	priority = 10,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.GameStart or event == sgs.FetchDrawPileCard then
			room:addPlayerMark(player, self:objectName().."engine")
			if player:getMark(self:objectName().."engine") > 0 then
				room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
				room:sendCompulsoryTriggerLog(player, self:objectName())
				local slash_skills = getSlashRelatedSkills(3, true)
				room:handleAcquireDetachSkills(player, table.concat(slash_skills, "|"))
				room:removePlayerMark(player, self:objectName().."engine")
			end
		elseif event == sgs.Dying then
			local dying = data:toDying()
			local vic = dying.who
			if player:getSeat() ~= vic:getSeat() then
				room:addPlayerMark(player, self:objectName().."engine")
				if player:getMark(self:objectName().."engine") > 0 then
					room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
					room:sendCompulsoryTriggerLog(player, self:objectName())
					player:drawCards(2, self:objectName())
					local slash_sk = getSlashRelatedSkills(1, true)
					room:handleAcquireDetachSkills(player, slash_sk[1])
					room:removePlayerMark(player, self:objectName().."engine")
				end
			end
		end
		return false
	end
}


sgkgodsplvbu:addSkill(sgkgodluocha)


--[[
	技能名：杀绝
	相关武将：SP神吕布
	技能描述：出牌阶段限一次，你可以失去1点体力并选择一名其他角色，若如此做，你将随机一张手牌当随机属性且无视防具的【杀】对其使用，你重复此流程直至失去这些牌或该角色死亡。
	引用：sgkgodshajue
]]--
function random_nature()
	local k = math.random(1, 3)
	if k == 1 then
		return "slash"
	elseif k == 2 then
		return "fire_slash"
	elseif k == 3 then
		return "thunder_slash"
	end
end

function randomTable(_table, _num)  --把一个table中的所有序数打乱
	local _result = {}
	local _index = 1
	local _num = _num or #_table
	while #_table ~= 0 do
		local ran = math.random(0, #_table)
		if _table[ran] ~= nil then
			_result[_index] = _table[ran]
			table.remove(_table, ran)
			_index = _index + 1
			if _index > _num then break end
		end
	end
	return _result
end

sgkgodshajueCard = sgs.CreateSkillCard{
	name = "sgkgodshajueCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
        if #targets == 0 then
		    return to_select:getSeat() ~= sgs.Self:getSeat() and sgs.Self:canSlash(to_select, nil, false)
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		room:addPlayerMark(source, "sgkgodshajue".."engine")
		if source:getMark("sgkgodshajue".."engine") > 0 then
			room:loseHp(source, 1, true)
			local vic = targets[1]
			local inicards = sgs.CardList()
			for _, c in sgs.qlist(source:getCards("h")) do
				inicards:append(c)
			end
			inicards = sgs.QList2Table(inicards)
			local N = #inicards
			for i = 1, N do
				if vic:isDead() then break end
				local t = math.random(1, #inicards)
				if room:getCardPlace(inicards[t]:getEffectiveId()) == sgs.Player_PlaceHand then
					local random_slash = sgs.Sanguosha:cloneCard(random_nature(), sgs.Card_SuitToBeDecided, -1)
					random_slash:addSubcard(inicards[t])
					random_slash:setSkillName("shajue_slash")
					random_slash:deleteLater()
					table.removeOne(inicards, inicards[t])
					vic:addQinggangTag(random_slash)
					local use = sgs.CardUseStruct()
					use.from = source
					use.to:append(vic)
					use.card = random_slash
					room:useCard(use, false)
				end
				if #inicards == 0 then break end
			end
			room:removePlayerMark(source, "sgkgodshajue".."engine")
		end
	end
}

sgkgodshajue = sgs.CreateZeroCardViewAsSkill{
	name = "sgkgodshajue",
	view_as = function()
		return sgkgodshajueCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#sgkgodshajueCard") and not player:isKongcheng()
	end
}


sgkgodsplvbu:addSkill(sgkgodshajue)


--[[
	技能名：鬼驱
	相关武将：SP神吕布
	技能描述：锁定技，你的手牌上限为你的技能数。当你处于濒死状态时，你可以失去一个技能，视为使用【桃】。
	引用：sgkgodguiqu
]]--
sgkgodguiqu = sgs.CreateMaxCardsSkill{
	name = "sgkgodguiqu",
	extra_func = function(self, target)
		if target:hasSkill(self:objectName()) then return math.max(0, target:getVisibleSkillList():length() - target:getHp()) end
	end
}


sgkgodguiquPeachVS = sgs.CreateZeroCardViewAsSkill{
	name = "sgkgodguiquPeach",
	view_as = function(self, cards)
		local peach = sgs.Sanguosha:cloneCard("peach", sgs.Card_NoSuit, 0)
		peach:setSkillName("sgkgodguiqu")
		return peach
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		if player:hasFlag("Global_Dying") then
			return string.find(pattern, "peach")
		end
		return false
	end
}

sgkgodguiquPeach = sgs.CreateTriggerSkill{
	name = "sgkgodguiquPeach",
	view_as_skill = sgkgodguiquPeachVS,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data, room)
		local use = data:toCardUse()
		if use.card and use.card:isKindOf("Peach") and use.card:getSkillName() == "sgkgodguiqu" then
			room:addPlayerMark(player, "sgkgodguiqu".."engine")
			if player:getMark("sgkgodguiqu".."engine") > 0 then
				local my_skills = {}
				for _, skill in sgs.qlist(player:getVisibleSkillList()) do
					table.insert(my_skills, skill:objectName())
				end
				local to_lose = room:askForChoice(player, "sgkgodguiqu", table.concat(my_skills, "+"))
				room:handleAcquireDetachSkills(player, "-"..to_lose)
				room:removePlayerMark(player, "sgkgodguiqu".."engine")
			end
		end
	end
}


sgkgodsplvbu:addSkill(sgkgodguiqu)
sgkgodsplvbu:addSkill(sgkgodguiquPeach)
extension:insertRelatedSkills("sgkgodguiqu", "sgkgodguiquPeach")


sgs.LoadTranslationTable{
    ["sgkgodsplvbu"] = "SP神吕布",
	["&sgkgodsplvbu"] = "神吕布",
	["#sgkgodsplvbu"] = "罗刹天",
	["~sgkgodsplvbu"] = "不……我是不朽的！",
	["sgkgodluocha"] = "罗刹",
	[":sgkgodluocha"] = "锁定技，游戏开始时，你随机获得3个与【杀】有关的技能。当其他角色进入濒死状态时，你摸两张牌，然后随机获得1个与【杀】有关的技能。",
	["$sgkgodluocha1"] = "超越，死亡的，恐惧！",
	["$sgkgodluocha2"] = "我，即是，不灭！",
	["sgkgodshajue"] = "杀绝",
	[":sgkgodshajue"] = "出牌阶段限一次，你可以失去1点体力并选择一名其他角色，若如此做，你将随机一张手牌当随机属性且无视防具的【杀】对其使用，你重复此流程"..
	"直至失去这些牌或该角色死亡。",
	["$sgkgodshajue1"] = "不死不休！",
	["$sgkgodshajue2"] = "这，就是地狱！",
	["sgkgodguiqu"] = "鬼驱",
	[":sgkgodguiqu"] = "锁定技，你的手牌上限为你的技能数。当你处于濒死状态时，你可以失去一个技能，视为使用【桃】。",
	["sgkgodguiquPeach"] = "鬼驱",
	[":sgkgodguiquPeach"] = "锁定技，你的手牌上限为你的技能数。当你处于濒死状态时，你可以失去一个技能，视为使用【桃】。",
	["$sgkgodguiqu1"] = "天雷？吾亦不惧！",
	["$sgkgodguiqu2"] = "鬼神之驱，怎能被凡人摧毁！",
	["designer:sgkgodsplvbu"] = "魂烈",
	["illustrator:sgkgodsplvbu"] = "魂烈",
	["cv:sgkgodsplvbu"] = "魂烈",
}


--SP神张角
--游走于生死界限的带阴阳师
sgkgodspzhangjiao = sgs.General(extension, "sgkgodspzhangjiao", "sy_god", 3)


--[[
	技能名：极阳
	相关武将：SP神张角
	技能描述：锁定技，当你获得/失去“极阳”时，你获得3个/弃置所有“阳”标记。当你失去红色牌后，你选择是否弃置1个“阳”标记，若为是，你令一名角色回复1点体力，若其
	未受伤，改为加1点体力上限。
	引用：sgkgodjiyang
]]--
local zhangjiao_yinyangskills = sgs.SkillList()
sgkgodjiyang = sgs.CreateTriggerSkill{
	name = "sgkgodjiyang",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventAcquireSkill, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventAcquireSkill then
			if data:toString() == self:objectName() then player:gainMark("&jiyang_positive", 3) end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if player:getMark("&jiyang_positive") == 0 then return false end
			if move.from and move.from:hasSkill(self:objectName()) and move.from:objectName() == player:objectName() then
				if move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip) then
					local can_do = false
					for _, id in sgs.qlist(move.card_ids) do
						if sgs.Sanguosha:getCard(id):isRed() then
							can_do = true
							break
						end
					end
					if can_do then
						local target = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), "@jiyang-recover", true, false)
						if target then
							room:broadcastSkillInvoke(self:objectName())
							room:sendCompulsoryTriggerLog(player, self:objectName())
							player:loseMark("&jiyang_positive")
							room:doAnimate(1, player:objectName(), target:objectName())
							if target:isWounded() then
								local yinyangrec = sgs.RecoverStruct()
								yinyangrec.recover = 1
								yinyangrec.who = player
								room:recover(target, yinyangrec, true)
							else
								local msg = sgs.LogMessage()
								msg.type = "#GainMaxHp"
								msg.from = target
								msg.arg = "1"
								room:sendLog(msg)
								room:setPlayerProperty(target, "maxhp", sgs.QVariant(target:getMaxHp() + 1))
							end
						end
					end
				end
			end
		end
		return false
	end
}


if not sgs.Sanguosha:getSkill("sgkgodjiyang") then zhangjiao_yinyangskills:append(sgkgodjiyang) end


--[[
	技能名：极阴
	相关武将：SP神张角
	技能描述：锁定技，当你获得/失去“极阴”时，你获得3个/弃置所有“阴”标记。当你失去黑色牌后，你选择是否弃置1个“阴”标记，若为是，你对一名角色造成1点雷电伤害，
	若其已受伤，改为减1点体力上限。
	引用：sgkgodjiyin
]]--
sgkgodjiyin = sgs.CreateTriggerSkill{
	name = "sgkgodjiyin",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventAcquireSkill, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventAcquireSkill then
			if data:toString() == self:objectName() then player:gainMark("&jiyin_negative", 3) end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if player:getMark("&jiyin_negative") == 0 then return false end
			if move.from and move.from:hasSkill(self:objectName()) and move.from:objectName() == player:objectName() then
				if move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip) then
					local can_do = false
					for _, id in sgs.qlist(move.card_ids) do
						if sgs.Sanguosha:getCard(id):isBlack() then
							can_do = true
							break
						end
					end
					if can_do then
						local target = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), "@jiyin-thunder", true, false)
						if target then
							room:broadcastSkillInvoke(self:objectName())
							room:sendCompulsoryTriggerLog(player, self:objectName())
							player:loseMark("&jiyin_negative")
							room:doAnimate(1, player:objectName(), target:objectName())
							if target:isWounded() then
								room:loseMaxHp(target)
							else
								room:damage(sgs.DamageStruct(self:objectName(), player, target, 1, sgs.DamageStruct_Thunder))
							end
						end
					end
				end
			end
		end
		return false
	end
}


if not sgs.Sanguosha:getSkill("sgkgodjiyin") then zhangjiao_yinyangskills:append(sgkgodjiyin) end


--[[
	技能名：相生
	相关武将：SP神张角
	技能描述：锁定技，当你获得/失去“相生”时，你获得6个/弃置所有“生”标记。当你失去黑色/红色牌后，你弃置1个“生”标记，从牌堆或弃牌堆中随机获得一张红色/黑色牌。
	引用：sgkgodxiangsheng
]]--
sgkgodxiangsheng = sgs.CreateTriggerSkill{
	name = "sgkgodxiangsheng",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventAcquireSkill, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventAcquireSkill then
			if data:toString() == self:objectName() then player:gainMark("&xiangsheng_balance", 6) end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if player:getMark("&xiangsheng_balance") == 0 then return false end
			if move.from and move.from:hasSkill(self:objectName()) and move.from:objectName() == player:objectName() then
				if move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip) or move.from_places:contains(sgs.Player_PlaceDelayedTrick) then
					local can_getred = false
					local can_getblack = false
					for _, id in sgs.qlist(move.card_ids) do
						if sgs.Sanguosha:getCard(id):isBlack() then
							can_getred = true
							break
						end
					end
					for _, id in sgs.qlist(move.card_ids) do
						if sgs.Sanguosha:getCard(id):isRed() then
							can_getblack = true
							break
						end
					end
					local rcards, bcards = sgs.CardList(), sgs.CardList()
					if not room:getDrawPile():isEmpty() then
						for _, id in sgs.qlist(room:getDrawPile()) do
							local icard = sgs.Sanguosha:getCard(id)
							if icard:isRed() then
								rcards:append(icard)
							elseif icard:isBlack() then
								bcards:append(icard)
							end
						end
					end
					if not room:getDiscardPile():isEmpty() then
						for _, id in sgs.qlist(room:getDiscardPile()) do
							local icard = sgs.Sanguosha:getCard(id)
							if icard:isRed() then
								rcards:append(icard)
							elseif icard:isBlack() then
								bcards:append(icard)
							end
						end
					end
					if (can_getred and rcards:length() > 0) or (can_getblack and bcards:length() > 0) then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						player:loseMark("&xiangsheng_balance")
						local jink = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, -1)
						if can_getred and rcards:length() > 0 then
							rcards = sgs.QList2Table(rcards)
							local random_red = rcards[math.random(1, #rcards)]
							jink:addSubcard(random_red)
						end
						if can_getblack and bcards:length() > 0 then
							bcards = sgs.QList2Table(bcards)
							local random_black = bcards[math.random(1, #bcards)]
							jink:addSubcard(random_black)
						end
						room:obtainCard(player, jink, false)
						jink:deleteLater()
					end
				end
			end
		end
		return false
	end
}


if not sgs.Sanguosha:getSkill("sgkgodxiangsheng") then zhangjiao_yinyangskills:append(sgkgodxiangsheng) end
sgs.Sanguosha:addSkills(zhangjiao_yinyangskills)


--[[
	技能名：阴阳
	相关武将：SP神张角
	技能描述：锁定技，若你的体力值：多于已损失体力，你拥有“极阳”；少于已损失体力，你拥有“极阴”；等于已损失体力，你拥有“相生”。
	引用：sgkgodyinyang
]]--
function getYinyangState(player)
	if player:getHp() > player:getLostHp() then  --体力值大于损失体力，阳
		return "hp_Yang"
	end
	if player:getHp() == player:getLostHp() then  --体力值等于损失体力，生
		return "hp_Sheng"
	end
	if player:getHp() < player:getLostHp() then  --体力值小于损失体力，阴
		return "hp_Yin"
	end
end

function YinyangChange(room, player, yinyang_flag, skill_name)
	local spyinyang_skills = player:getTag("SPYinyangSkills"):toString():split("+")
	if not player:isAlive() then return false end
	if getYinyangState(player) == yinyang_flag then
		if not table.contains(spyinyang_skills, skill_name) then
			room:notifySkillInvoked(player, "sgkgodyinyang")
			room:broadcastSkillInvoke("sgkgodyinyang")
			room:sendCompulsoryTriggerLog(player, "sgkgodyinyang")
			table.insert(spyinyang_skills, skill_name)
			room:handleAcquireDetachSkills(player, skill_name)
		end
	else
		if table.contains(spyinyang_skills, skill_name) then
			room:handleAcquireDetachSkills(player, "-"..skill_name)
			table.removeOne(spyinyang_skills, skill_name)
		end
	end
	player:setTag("SPYinyangSkills", sgs.QVariant(table.concat(spyinyang_skills, "+")))
end

sgkgodyinyang = sgs.CreateTriggerSkill{
	name = "sgkgodyinyang",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TurnStart, sgs.HpChanged, sgs.MaxHpChanged, sgs.EventAcquireSkill, sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.TurnStart then
			if not room:findPlayerBySkillName(self:objectName()) then return false end
			local spzhangjiao = room:findPlayerBySkillName(self:objectName())
			if not spzhangjiao or (not spzhangjiao:isAlive()) then return false end
			YinyangChange(room, spzhangjiao, "hp_Yang", "sgkgodjiyang")
			YinyangChange(room, spzhangjiao, "hp_Sheng", "sgkgodxiangsheng")
			YinyangChange(room, spzhangjiao, "hp_Yin", "sgkgodjiyin")
		end
		if event == sgs.EventLoseSkill then
			if data:toString() == self:objectName() then
				local spyinyang_skills = player:getTag("SPYinyangSkills"):toString():split("+")
				local to_detach = {}
				for _, sk in ipairs(spyinyang_skills) do
					table.insert(to_detach, "-"..sk)
				end
				room:handleAcquireDetachSkills(player, table.concat(to_detach, "|"))
				player:setTag("SPYinyangSkills", sgs.QVariant())
			end
			return false
		elseif event == sgs.EventAcquireSkill then
			if data:toString() ~= self:objectName() then return false end
		end
		if not player:isAlive() or (not player:hasSkill(self:objectName())) then return false end
		YinyangChange(room, player, "hp_Yang", "sgkgodjiyang")
		YinyangChange(room, player, "hp_Sheng", "sgkgodxiangsheng")
		YinyangChange(room, player, "hp_Yin", "sgkgodjiyin")
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end
}


sgkgodspzhangjiao:addSkill(sgkgodyinyang)


--[[
	技能名：定命
	相关武将：SP神张角
	技能描述：准备阶段，或当你受到其他角色造成的伤害后，你可交换体力与已损失体力，然后若你的体力多于已损失体力，你减1点体力上限；当你对其他角色造成伤害后，可
	令其交换体力与已损失体力，然后若其体力少于已损失体力，你减1点体力上限。若如此做，你摸X张牌（X为交换的体力与已损失体力的差）。
	交换形式：多体力与少损失体力交换，流失差额体力；少体力与多损失体力交换，回复差额体力。
	引用：sgkgoddingming
]]--
function exchangeYinYang(from, target)  --“交换”一名角色的体力与损失体力
	local room = from:getRoom()
	local x = math.abs(target:getHp() - target:getLostHp())  --先计算目标体力与已损失体力的差（取绝对值）
	if x > 0 then
		if getYinyangState(target) == "hp_Yang" then  --阳：体力大于已损失体力，则以体力流失的形式，失去等同于差额值的体力
			room:doAnimate(1, from:objectName(), target:objectName())
			room:loseHp(target, x, true)
		elseif getYinyangState(target) == "hp_Yin" then  --阴：体力小于已损失体力，则回复等同于差额值的体力
			room:doAnimate(1, from:objectName(), target:objectName())
			local yinyangrec = sgs.RecoverStruct()
			yinyangrec.recover = x
			yinyangrec.who = from
			room:recover(target, yinyangrec, true)
		end
	end
	--生：体力等于已损失体力，什么也不触发
end


sgkgoddingming = sgs.CreateTriggerSkill{
	name = "sgkgoddingming",
	events = {sgs.EventPhaseStart, sgs.Damaged, sgs.Damage},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start and getYinyangState(player) ~= "hp_Sheng" then  --你都“相生”了还交换个锤子啊
				local _data = sgs.QVariant()
				_data:setValue(player)
				if player:isAlive() and player:askForSkillInvoke(self:objectName(), _data) then
					room:broadcastSkillInvoke(self:objectName())
					local x = math.abs(player:getHp() - player:getLostHp())
					exchangeYinYang(player, player)
					if getYinyangState(player) == "hp_Yang" then room:loseMaxHp(player) end
					if player:isAlive() then player:drawCards(x, self:objectName()) end
				end
			end
		elseif event == sgs.Damaged then
			local damage = data:toDamage()
			if not damage.from then return false end
			if getYinyangState(player) ~= "hp_Sheng" then  --你都“相生”了还交换个锤子啊
				local _data = sgs.QVariant()
				_data:setValue(player)
				if player:isAlive() and player:askForSkillInvoke(self:objectName(), _data) then
					room:broadcastSkillInvoke(self:objectName())
					local x = math.abs(player:getHp() - player:getLostHp())
					exchangeYinYang(player, player)
					if getYinyangState(player) == "hp_Yang" then room:loseMaxHp(player) end
					if player:isAlive() then player:drawCards(x, self:objectName()) end
				end
			end
		elseif event == sgs.Damage then
			local damage = data:toDamage()
			if damage.to and damage.to:getSeat() ~= player:getSeat() and getYinyangState(damage.to) ~= "hp_Sheng" then  --你都“相生”了还交换个锤子啊
				local _data = sgs.QVariant()
				_data:setValue(damage.to)
				if damage.to:isAlive() and player:askForSkillInvoke(self:objectName(), _data) then
					room:broadcastSkillInvoke(self:objectName())
					local x = math.abs(damage.to:getHp() - damage.to:getLostHp())
					exchangeYinYang(player, damage.to)
					if getYinyangState(damage.to) == "hp_Yin" then room:loseMaxHp(player) end
					if player:isAlive() and damage.to:isAlive() then player:drawCards(x, self:objectName()) end
				end
			end
		end
		return false
	end
}


sgkgodspzhangjiao:addSkill(sgkgoddingming)
sgkgodspzhangjiao:addRelateSkill("sgkgodjiyang")
sgkgodspzhangjiao:addRelateSkill("sgkgodjiyin")
sgkgodspzhangjiao:addRelateSkill("sgkgodxiangsheng")

sgs.LoadTranslationTable{
    ["sgkgodspzhangjiao"] = "SP神张角",
	["&sgkgodspzhangjiao"] = "神张角",
	["#sgkgodspzhangjiao"] = "大道无常",
	["~sgkgodspzhangjiao"] = "为何苍天……还没死……",
	["sgkgodyinyang"] = "阴阳",
	[":sgkgodyinyang"] = "锁定技，若你的体力值：多于已损失体力，你拥有“极阳”；少于已损失体力，你拥有“极阴”；等于已损失体力，你拥有“相生”。",
	["$sgkgodyinyang1"] = "世间万物，皆有阴阳之道。",
	["$sgkgodyinyang2"] = "一阴一阳，道用无穷。",
	["sgkgoddingming"] = "定命",
	[":sgkgoddingming"] = "准备阶段，或当你受到其他角色造成的伤害后，你可交换体力与已损失体力，然后若你的体力多于已损失体力，你减1点体力上限；当你对其他角色"..
	"造成伤害后，可令其交换体力与已损失体力，然后若其体力少于已损失体力，你减1点体力上限。若如此做，你摸X张牌（X为交换的体力与已损失体力的差）。",
	["$sgkgoddingming1"] = "苍天不复，黄天立命！",
	["$sgkgoddingming2"] = "窥晓阴阳，逆天改命！",
	["sgkgodjiyang"] = "极阳",
	["jiyang_positive"] = "阳",
	[":sgkgodjiyang"] = "锁定技，当你获得/失去“极阳”时，你获得3个/弃置所有“阳”标记。当你失去红色牌后，你选择是否弃置1个“阳”标记，若为是，你令一名角色回复1点"..
	"体力，若其未受伤，改为加1点体力上限。",
	["@jiyang-recover"] = "【极阳】选择一名已受伤/未受伤的角色令其回复1点体力/加1点体力上限<br/> <b>操作提示</b>: 选择一名需要“极阳”治疗的（友方）角色→点击确定<br/>",
	["$sgkgodjiyang1"] = "极阳之力，救苍生万民。",
	["$sgkgodjiyang2"] = "道以扬善，平天下乱世。",
	["sgkgodjiyin"] = "极阴",
	["jiyin_negative"] = "阴",
	[":sgkgodjiyin"] = "锁定技，当你获得/失去“极阴”时，你获得3个/弃置所有“阴”标记。当你失去黑色牌后，你选择是否弃置1个“阴”标记，若为是，你对一名角色造成1点雷"..
	"电伤害，若其已受伤，改为减1点体力上限。",
	["@jiyin-thunder"] = "【极阴】选择一名已受伤/未受伤的角色令其减1点体力上限/受到1点雷电伤害<br/> <b>操作提示</b>: 选择一名需要“极阴”打击的（敌方）角色→点击确定<br/>",
	["$sgkgodjiyin1"] = "极阴之力，毁灭一切！",
	["$sgkgodjiyin2"] = "阴雷诛灭，电纵九天！",
	["sgkgodxiangsheng"] = "相生",
	["xiangsheng_balance"] = "生",
	[":sgkgodxiangsheng"] = "锁定技，当你获得/失去“相生”时，你获得6个/弃置所有“生”标记。当你失去黑色/红色牌后，你弃置1个“生”标记，从牌堆或弃牌堆中随机获得一"..
	"张红色/黑色牌。",
	["$sgkgodxiangsheng1"] = "阴阳相生，道法自然。",
	["$sgkgodxiangsheng2"] = "周而复始，生生不息。",
	["designer:sgkgodspzhangjiao"] = "魂烈",
	["illustrator:sgkgodspzhangjiao"] = "魂烈",
	["cv:sgkgodspzhangjiao"] = "魂烈",
}


--SP神张辽
--物理意义上的刑天梦魇
sgkgodspzhangliao = sgs.General(extension, "sgkgodspzhangliao", "sy_god", 4)


--[[
	技能名：锋影
	相关武将：SP神张辽
	技能描述：当你摸一张牌前，你可改为视为对一名其他角色使用【雷杀】（无距离限制），每回合限四次。
	引用：sgkgodfengying, sgkgodfengyingClear
]]--
sgkgodfengying = sgs.CreateTriggerSkill{
	name = "sgkgodfengying",
	events = {sgs.BeforeCardsMove},
	on_trigger = function(self, event, player, data, room)
		local move = data:toMoveOneTime()
		if room:getTag("FirstRound"):toBool() then return false end
		if not player:hasSkill(self:objectName()) then return false end
	    if not move.from_places:contains(sgs.Player_DrawPile) or move.from then return false end
	    if move.to_place == sgs.Player_PlaceHand and move.to:objectName() == player:objectName() 
	            and (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DRAW 
			    or move.reason.m_reason == sgs.CardMoveReason_S_REASON_DRAW) then
			if player:getMark("&"..self:objectName()) >= 4 then return false end
			local thunder_slash = sgs.Sanguosha:cloneCard("thunder_slash", sgs.Card_NoSuit, 0)
			thunder_slash:setSkillName(self:objectName())
			thunder_slash:deleteLater()
			local targets = sgs.SPlayerList()
			for _, pe in sgs.qlist(room:getOtherPlayers(player)) do
				if not sgs.Sanguosha:isProhibited(player, pe, thunder_slash) then targets:append(pe) end
			end
			if targets:isEmpty() then
				return false
			else
				local k = move.card_ids:length()
				for _, id in sgs.qlist(move.card_ids) do
					local target = room:askForPlayerChosen(player, targets, self:objectName(), "@fengying-target", true, true)
					if target then
						room:addPlayerMark(player, "&"..self:objectName())
						room:addPlayerMark(player, "fengying_tempcount")
						local use = sgs.CardUseStruct()
						use.from = player
						use.to:append(target)
						use.card = thunder_slash
						room:useCard(use, true)
						if player:getMark("&"..self:objectName()) >= 4 then break end
					else
						break
					end
				end
				if player:getMark("fengying_tempcount") > 0 then
					local final_ids = sgs.IntList()
					local x = k - player:getMark("fengying_tempcount")
					if room:getDrawPile():length() < x then room:swapPile() end
					for i = 1, x do
						final_ids:append(room:getDrawPile():at(i-1))
					end
					move.card_ids = final_ids
					data:setValue(move)
				end
				room:setPlayerMark(player, "fengying_tempcount", 0)
			end
		end
	end
}

sgkgodfengyingClear = sgs.CreateTriggerSkill{
	name = "#sgkgodefengyingClear",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging, sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				if room:findPlayersBySkillName("sgkgodfengying"):isEmpty() then return false end
				for _, zl in sgs.qlist(room:findPlayersBySkillName("sgkgodfengying")) do
					if zl:getMark("&sgkgodfengying") > 0 then room:setPlayerMark(zl, "&sgkgodfengying", 0) end
				end
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == "sgkgodfengying" then
				if room:findPlayersBySkillName("sgkgodfengying"):isEmpty() then return false end
				for _, zl in sgs.qlist(room:findPlayersBySkillName("sgkgodfengying")) do
					if zl:getMark("&sgkgodfengying") > 0 then room:setPlayerMark(zl, "&sgkgodfengying", 0) end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}


sgkgodspzhangliao:addSkill(sgkgodfengying)
sgkgodspzhangliao:addSkill(sgkgodfengyingClear)
extension:insertRelatedSkills("sgkgodfengying", "#sgkgodfengyingClear")


--[[
	技能名：止啼
	相关武将：SP神张辽
	技能描述：当你对其他角色即将造成伤害时，你可选择一项：①偷取其1点体力和体力上限；②偷取其摸牌阶段的1摸牌数；③偷取其1个技能；④令其不能使用装备牌；⑤令其翻面。
	每项对每名其他角色限一次。
	引用：sgkgodzhiti
]]--
sgkgodzhiti = sgs.CreateTriggerSkill{
	name = "sgkgodzhiti",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data, room)
		local damage = data:toDamage()
		if damage.to:getSeat() == player:getSeat() then return false end
		local zhiti_items = {"spgodzl_stealOneHpAndMaxhp", "spgodzl_stealOneDraw", "spgodzl_stealOneSkill", "spgodzl_banEquip", "spgodzl_turnOver"}
		local enabled_items = damage.to:property(""..player:objectName().."_ZhitiEnabled"):toString():split("+")
		local rest_items = {}
		if #enabled_items > 0 then
			for i = 1, #zhiti_items, 1 do
				if not table.contains(enabled_items, zhiti_items[i]) then table.insert(rest_items, zhiti_items[i]) end
			end
		else
			for i = 1, #zhiti_items, 1 do
				table.insert(rest_items, zhiti_items[i])
			end
		end
		if #rest_items > 0 then
			local _data = sgs.QVariant()
			_data:setValue(damage.to)
			if player:askForSkillInvoke(self:objectName(), _data) then
				local choice = room:askForChoice(player, self:objectName(), table.concat(rest_items, "+"), _data)
				room:doAnimate(1, player:objectName(), damage.to:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
				if choice == "spgodzl_stealOneHpAndMaxhp" then
					local msg1 = sgs.LogMessage()
					msg1.from = player
					msg1.to:append(damage.to)
					msg1.type = "#SPGodZhiti1"
					room:sendLog(msg1)
					room:loseHp(damage.to, 1, true)
					room:loseMaxHp(damage.to, 1)
					room:gainMaxHp(player, 1)
					if player:isWounded() then
						local rec = sgs.RecoverStruct()
						rec.recover = 1
						rec.who = player
						room:recover(player, rec, true)
					end
					table.insert(enabled_items, choice)
					room:setPlayerProperty(damage.to, ""..player:objectName().."_ZhitiEnabled", sgs.QVariant(table.concat(enabled_items, "+")))
				elseif choice == "spgodzl_stealOneDraw" then
					room:addPlayerMark(player, "zhiti_exdraw")
					local msg2 = sgs.LogMessage()
					msg2.from = player
					msg2.to:append(damage.to)
					msg2.type = "#SPGodZhiti2"
					room:sendLog(msg2)
					table.insert(enabled_items, choice)
					room:setPlayerProperty(damage.to, ""..player:objectName().."_ZhitiEnabled", sgs.QVariant(table.concat(enabled_items, "+")))
				elseif choice == "spgodzl_stealOneSkill" then
					local msg3 = sgs.LogMessage()
					msg3.from = player
					msg3.to:append(damage.to)
					msg3.type = "#SPGodZhiti3"
					room:sendLog(msg3)
					local to_steal = {}
					for _, _skill in sgs.qlist(damage.to:getVisibleSkillList()) do
						table.insert(to_steal, _skill:objectName())
					end
					if #to_steal > 0 then
						local askill = room:askForChoice(player, "zhiti_stealWhat", table.concat(to_steal, "+"), _data)
						room:handleAcquireDetachSkills(damage.to, "-"..askill)
						if not player:hasSkill(askill) then room:handleAcquireDetachSkills(player, askill) end
					end
					table.insert(enabled_items, choice)
					room:setPlayerProperty(damage.to, ""..player:objectName().."_ZhitiEnabled", sgs.QVariant(table.concat(enabled_items, "+")))
				elseif choice == "spgodzl_banEquip" then
					local msg4 = sgs.LogMessage()
					msg4.from = player
					msg4.to:append(damage.to)
					msg4.type = "#SPGodZhiti4"
					room:sendLog(msg4)
					room:setPlayerCardLimitation(damage.to, "use,response", "EquipCard|.|.|hand", false)
					table.insert(enabled_items, choice)
					room:setPlayerProperty(damage.to, ""..player:objectName().."_ZhitiEnabled", sgs.QVariant(table.concat(enabled_items, "+")))
				elseif choice == "spgodzl_turnOver" then
					local msg5 = sgs.LogMessage()
					msg5.from = player
					msg5.to:append(damage.to)
					msg5.type = "#SPGodZhiti5"
					room:sendLog(msg5)
					damage.to:turnOver()
					table.insert(enabled_items, choice)
					room:setPlayerProperty(damage.to, ""..player:objectName().."_ZhitiEnabled", sgs.QVariant(table.concat(enabled_items, "+")))
				end
			end
		end
	end
}


sgkgodspzhangliao:addSkill(sgkgodzhiti)


sgs.LoadTranslationTable{
    ["sgkgodspzhangliao"] = "SP神张辽",
	["&sgkgodspzhangliao"] = "神张辽",
	["#sgkgodspzhangliao"] = "雁门之刑天",
	["~sgkgodspzhangliao"] = "患病之躯，亦当战死沙场……",
	["sgkgodfengying"] = "锋影",
	[":sgkgodfengying"] = "当你摸一张牌前，你可改为视为对一名其他角色使用【雷杀】（无距离限制），每回合限四次。",
	["$sgkgodfengying1"] = "刀锋如影，破敌无形！",
	["$sgkgodfengying2"] = "东吴十万，吾，亦可夺之锐气！",
	["@fengying-target"] = "你可以发动“锋影”不摸这张牌，视为对一名其他角色使用【雷杀】<br/> <b>操作提示</b>: 选择一名其他角色→点击确定<br/>",
	["sgkgodzhiti"] = "止啼",
	[":sgkgodzhiti"] = "当你对其他角色即将造成伤害时，你可选择一项：①偷取其1点体力和体力上限；②偷取其摸牌阶段的1摸牌数；③偷取其1个技能；④令其不能使用装备牌"..
	"；⑤令其翻面。每项对每名其他角色限一次。",
	["$sgkgodzhiti1"] = "江东小儿，安敢啼哭！",
	["$sgkgodzhiti2"] = "吾便是，东吴的梦魇！",
	["spgodzl_stealOneHpAndMaxhp"] = "止啼1：偷取其1点体力和体力上限",
	["spgodzl_stealOneDraw"] = "止啼2：偷取其摸牌阶段的1摸牌数",
	["spgodzl_stealOneSkill"] = "止啼3：偷取其1个技能",
	["spgodzl_banEquip"] = "止啼4：令其不能使用装备牌",
	["spgodzl_turnOver"] = "止啼5：令其翻面",
	["zhiti_stealWhat"] = "选择偷取的技能",
	["#SPGodZhiti1"] = "%from 偷取了 %to 的 <font color = 'yellow'><b>1</b></font> 点体力和 <font color = 'yellow'><b>1</b></font> 点体力上限",
	["#SPGodZhiti2"] = "%from 偷取了 %to 的摸牌阶段的 <font color = 'yellow'><b>1</b></font> 摸牌数",
	["#SPGodZhiti3"] = "%from 偷取了 %to 的 <font color = 'yellow'><b>1</b></font> 个武将技能",
	["#SPGodZhiti4"] = "%from 令 %to 直至本局游戏结束都不能使用 <font color = 'yellow'><b>装备牌</b></font>",
	["#SPGodZhiti5"] = "%from 令 %to 将其武将牌翻面",
	["designer:sgkgodspzhangliao"] = "魂烈",
	["illustrator:sgkgodspzhangliao"] = "魂烈",
	["cv:sgkgodspzhangliao"] = "魂烈",
}


--什么都抢的锦翎大盗
--SP神甘宁
sgkgodspganning = sgs.General(extension, "sgkgodspganning", "sy_god", 4)


--[[
	技能名：劫营
	相关武将：SP神甘宁
	技能描述：摸牌阶段，你可以放弃摸牌，然后令一名未拥有“劫营”标记的其他角色获得3个“劫营”标记。则拥有“劫营”标记的角色摸牌/回复体力/加体力上限/执行额外回合/
	获得技能前，其移去1个“劫营”标记，改为由你执行对应的效果。
	引用：sgkgodjieying, sgkgodjieyingRob
]]--
sgkgodjieying = sgs.CreateTriggerSkill{
	name = "sgkgodjieying",
	events = {sgs.EventPhaseStart, sgs.Death, sgs.BeforeCardsMove},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Draw then
				local can_invoke = false
				local targets = sgs.SPlayerList()
				for _, pe in sgs.qlist(room:getOtherPlayers(player)) do
					if pe:getMark("&"..self:objectName()) == 0 then targets:append(pe) end
				end
				if not targets:isEmpty() then can_invoke = true end
				if can_invoke and player:askForSkillInvoke(self:objectName()) then
					local target = room:askForPlayerChosen(player, targets, self:objectName())
					room:doAnimate(1, player:objectName(), target:objectName())
					room:broadcastSkillInvoke(self:objectName())
					target:gainMark("&"..self:objectName(), 3)
					return true
				end
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who:hasSkill(self:objectName()) and death.who:objectName() == player:objectName() then
				for _, pe in sgs.qlist(room:getAllPlayers()) do
					room:setPlayerMark(pe, "&"..self:objectName(), 0)
				end
			end
		elseif event == sgs.BeforeCardsMove then  --偷摸牌
			local move = data:toMoveOneTime()
			if move.to_place == sgs.Player_PlaceHand and move.to:getMark("&"..self:objectName()) > 0 and move.to:objectName() ~= player:objectName()
	            and (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DRAW 
			    or move.reason.m_reason == sgs.CardMoveReason_S_REASON_DRAW) then
				room:broadcastSkillInvoke(self:objectName())
				local to = -1
				for _, pe in sgs.qlist(room:getOtherPlayers(player)) do
					if move.to:objectName() == pe:objectName() then
						to = pe
						break
					end
				end
				to:loseMark("&"..self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				move.to = player
				data:setValue(move)
				local msg = sgs.LogMessage()
				msg.from = player
				msg.type = "#jieyingRobCard"
				msg.to:append(to)
				msg.arg = "sgkgodjieying"
				msg.arg2 = tostring(move.card_ids:length())
				room:sendLog(msg)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target:hasSkill(self:objectName())
	end
}

--劫营的抢劫部分
sgkgodjieyingRob = sgs.CreateTriggerSkill{
	name = "#sgkgodjieyingRob",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreHpRecover, sgs.MaxHpChanged, sgs.TurnStart, sgs.EventAcquireSkill},
	priority = {10, 100, 100, 100},
	global = true,
	on_trigger = function(self, event, player, data, room)
		if not room:findPlayerBySkillName("sgkgodjieying") then return false end
		local sgn = room:findPlayerBySkillName("sgkgodjieying")
		if event == sgs.PreHpRecover then  --偷体力回复
			local rec = data:toRecover()
			local x = rec.recover
			local source = rec.from
			if player:getMark("&sgkgodjieying") > 0 then
				room:broadcastSkillInvoke("sgkgodjieying")
				player:loseMark("&sgkgodjieying")
				if sgn:isWounded() then
					local rec = sgs.RecoverStruct()
					rec.recover = x
					rec.who = source
					room:recover(sgn, rec, true)
				end
				room:broadcastSkillInvoke("sgkgodjieying")
				local msg = sgs.LogMessage()
				msg.from = sgn
				msg.type = "#jieyingRobRecover"
				msg.to:append(player)
				msg.arg = "sgkgodjieying"
				msg.arg2 = tostring(x)
				room:sendLog(msg)
				return true
			end
		elseif event == sgs.MaxHpChanged then  --偷体力上限
			if player:getMark("&sgkgodjieying") > 0 then
				local n = player:getMaxHp() - player:getTag("hunlie_global_MaxHp"):toInt()
				if n > 0 then
					room:broadcastSkillInvoke("sgkgodjieying")
					player:loseMark("&sgkgodjieying")
					forbidAllCurrentSkills(player, "sgkgodjieying")
					room:setPlayerProperty(player, "maxhp", sgs.QVariant(player:getMaxHp()-n))
					activateAllSkills(player, "sgkgodjieying")
					local msg = sgs.LogMessage()
					msg.from = sgn
					msg.type = "#jieyingRobMaxHp"
					msg.to:append(player)
					msg.arg = "sgkgodjieying"
					msg.arg2 = tostring(n)
					room:sendLog(msg)
					room:gainMaxHp(sgn, n)
				end
			end
			player:setTag("hunlie_global_MaxHp", sgs.QVariant(player:getMaxHp()))
		elseif event == sgs.TurnStart then  --偷额外回合
			if player:getMark("&sgkgodjieying") > 0 and player:getMark("@extra_turn") > 0 then
				room:removePlayerMark(player, "@extra_turn")
				room:broadcastSkillInvoke("sgkgodjieying")
				player:loseMark("&sgkgodjieying")
				local msg = sgs.LogMessage()
				msg.from = sgn
				msg.type = "#jieyingRobExtraTurn"
				msg.to:append(player)
				msg.arg = "sgkgodjieying"
				room:sendLog(msg)
				sgn:gainAnExtraTurn()
				return true
			end
		elseif event == sgs.EventAcquireSkill then  --偷技能
			local skill = data:toString()
			if player:getMark("&sgkgodjieying") > 0 or (player:getMark("&sgkgodjieying") == 0 and sgn:getMark("jieying_rob_temp") > 0 and player:objectName() ~= sgn:objectName()) then
				if sgn:getMark("jieying_rob_temp") == 0 then
					room:addPlayerMark(sgn, "jieying_rob_temp")
					player:loseMark("&sgkgodjieying")
				end
				room:handleAcquireDetachSkills(player, "-"..skill, false, true, false)
				if not sgn:hasSkill(skill) then
					local msg = sgs.LogMessage()
					msg.from = sgn
					msg.type = "#jieyingRobSkill"
					msg.to:append(player)
					msg.arg = "sgkgodjieying"
					msg.arg2 = skill
					room:sendLog(msg)
					room:handleAcquireDetachSkills(sgn, ""..skill)
				end
			end
		end
		return false
	end			
}


sgkgodspganning:addSkill(sgkgodjieying)
sgkgodspganning:addSkill(sgkgodjieyingRob)
extension:insertRelatedSkills("sgkgodjieying", "#sgkgodjieyingRob")


--[[
	技能名：锦龙
	相关武将：SP神甘宁
	技能描述：锁定技，当一张装备牌被你获得或进入弃牌堆后，你将其置于武将牌上并摸1张牌，且视为拥有这些装备牌的技能。
	引用：sgkgodjinlong, sgkgodjinlongEquip
]]--
sgkgodjinlong = sgs.CreateViewAsEquipSkill{
	name = "sgkgodjinlong",
	view_as_equip = function(self, player)
		return "" .. player:property("jinlong_record"):toString()
	end
}

sgkgodjinlongEquip = sgs.CreateTriggerSkill{
	name = "#sgkgodjinlongEquip",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime},
	priority = -2,
	on_trigger = function(self, event, player, data, room)
		local move = data:toMoveOneTime()
		if room:getTag("FirstRound"):toBool() then return false end
		local jl = player:property("SkillDescriptionRecord_sgkgodjinlong"):toString():split("+")
		if (move.to and move.to:objectName() == player:objectName() and (move.to_place == sgs.Player_PlaceHand or move.to_place == sgs.Player_PlaceEquip))
			or move.to_place == sgs.Player_DiscardPile then
			local contains_eq = false
			for _, id in sgs.qlist(move.card_ids) do
				if sgs.Sanguosha:getCard(id):isKindOf("EquipCard") then
					contains_eq = true
					break
				end
			end
			if contains_eq then
				room:sendCompulsoryTriggerLog(player, "sgkgodjinlong")
				room:broadcastSkillInvoke("sgkgodjinlong")
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					local place = room:getCardPlace(card:getEffectiveId())
					if card:isKindOf("EquipCard") then
						if place == sgs.Player_PlaceHand or place == sgs.Player_PlaceEquip or place == sgs.Player_DiscardPile then
							local name = sgs.Sanguosha:getEngineCard(id):objectName()
							if not table.contains(jl, name) then
								table.insert(jl, name)
								local msg = sgs.LogMessage()
								msg.from = player
								msg.type = "#jinlongEquip"
								msg.card_str = card:toString()
								room:sendLog(msg)
								room:setPlayerProperty(player, "jinlong_record", sgs.QVariant(table.concat(jl, ",")))
								room:setPlayerProperty(player, "SkillDescriptionRecord_sgkgodjinlong", sgs.QVariant(table.concat(jl, "+")))
								room:changeTranslation(player, "sgkgodjinlong", 11)
							end
							player:addToPile("jinlong_equips", card)
							player:drawCards(1, "sgkgodjinlong")
						end
					end
				end
			end
		end
	end
}


sgkgodspganning:addSkill(sgkgodjinlong)
sgkgodspganning:addSkill(sgkgodjinlongEquip)
extension:insertRelatedSkills("sgkgodjinlong", "#sgkgodjinlongEquip")


sgs.LoadTranslationTable{
    ["sgkgodspganning"] = "SP神甘宁",
	["&sgkgodspganning"] = "神甘宁",
	["#sgkgodspganning"] = "锦翎如龙",
	["~sgkgodspganning"] = "神乌啼鸣尽悲哀，梧桐树下待涅槃!",
	["sgkgodjieying"] = "劫营",
	[":sgkgodjieying"] = "摸牌阶段，你可以放弃摸牌，然后令一名未拥有“劫营”标记的其他角色获得3个“劫营”标记。则拥有“劫营”标记的角色摸牌/回复体力/加体力上限/"..
	"执行额外回合/获得技能前，其移去1个“劫营”标记，改为由你执行对应的效果。",
	["$sgkgodjieying1"] = "劫寨将轻骑，驱兵饮巨瓯！",
	["$sgkgodjieying2"] = "衔枚夜袭觇敌向，如若万鬼临人间！",
	["#jieyingRobCard"] = "%from 的“%arg”被触发，抢走了 %to 本应该摸的 %arg2 张牌",
	["#jieyingRobRecover"] = "%from 的“%arg”被触发，抢走了 %to 本应该回复的 %arg2 点体力",
	["#jieyingRobMaxHp"] = "%from 的“%arg”被触发，抢走了 %to 本应该增加的 %arg2 点体力上限",
	["#jieyingRobExtraTurn"] = "%from 的“%arg”被触发，抢走了 %to 本应该进行的额外回合",
	["#jieyingRobSkill"] = "%from 的“%arg”被触发，抢走了 %to 本应该获得的技能“%arg2”",
	["sgkgodjinlong"] = "锦龙",
	[":sgkgodjinlong"] = "锁定技，当一张装备牌被你获得或进入弃牌堆后，你将其置于武将牌上并摸1张牌，且视为拥有这些装备牌的技能。",
	[":sgkgodjinlong11"] = "锁定技，当一张装备牌被你获得或进入弃牌堆后，你将其置于武将牌上并摸1张牌，且视为拥有这些装备牌的技能\
	<font color=\"#9400D3\">“锦龙”记录的装备：%arg11</font>",
	["jinlong_equips"] = "锦龙",
	["#jinlongEquip"] = "%from 获得了装备牌 %card 的技能",
	["$sgkgodjinlong1"] = "身披锦衣卧沙场，银铃声声似龙吟！",
	["$sgkgodjinlong2"] = "锦龙锐甲，金鳞为开！",
	["designer:sgkgodspganning"] = "魂烈",
	["illustrator:sgkgodspganning"] = "魂烈",
	["cv:sgkgodspganning"] = "魂烈",
}
return {extension}