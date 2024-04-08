extension = sgs.Package("extra", sgs.Package_GeneralPack)
function listIndexOf(theqlist, theitem)
	local index = 0
	for _, item in sgs.qlist(theqlist) do
		if item == theitem then return index end
		index = index + 1
	end
end

turn_length = sgs.CreateTriggerSkill {
	name = "turn_length",
	global = true,
	events = { sgs.TurnStart },
	on_trigger = function(self, event, player, data, room)
		local n = 15
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			n = math.min(p:getSeat(), n)
		end
		if player:getSeat() == n and not room:getTag("ExtraTurn"):toBool() then
			room:setPlayerMark(player, "@clock_time", room:getTag("TurnLengthCount"):toInt() + 1)
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				for _, mark in sgs.list(p:getMarkNames()) do
					if string.find(mark, "_lun") and p:getMark(mark) > 0 then
						room:setPlayerMark(p, mark, 0)
					end
				end
			end
		end
		return false
	end
}

clear_mark = sgs.CreateTriggerSkill {
	name = "clear_mark",
	global = true,
	priority = -100,
	events = { sgs.EventPhaseChanging },
	on_trigger = function(self, event, splayer, data, room)
		local change = data:toPhaseChange()
		for _, player in sgs.qlist(room:getAlivePlayers()) do
			for _, mark in sgs.list(player:getMarkNames()) do
				if string.find(mark, "_biu") and player:getMark(mark) > 0 then
					room:setPlayerMark(player, mark, 0)
				end
			end
		end
		if change.to == sgs.Player_NotActive then
			for _, player in sgs.qlist(room:getAlivePlayers()) do
				for _, skill in sgs.qlist(player:getSkillList(false, false)) do
					if string.find(skill:objectName(), "_clear") then
						room:detachSkillFromPlayer(player, skill:objectName(), true)
						room:filterCards(player, player:getCards("h"), true)
					end
				end
				if player:getMark("ol_huxiao-Clear") > 0 then
					local assignee_list = room:getCurrent():property("extra_slash_specific_assignee"):toString():split(
						"+")
					table.removeOne(assignee_list, player:objectName())
					room:setPlayerProperty(room:getCurrent(), "extra_slash_specific_assignee",
						sgs.QVariant(table.concat(assignee_list, "+")))
				end
				if player:getMark("funan-Clear") > 0 then
					room:removePlayerCardLimitation(player, "use,response", card:toString())
				end
				if player:getMark("@weilu-Clear") > 0 then
					room:recover(player, sgs.RecoverStruct(player, nil, player:getMark("@weilu-Clear")))
				end
				if player:getMark("lijun_limit") > 0 then
					room:removePlayerMark(player, "lijun_limit")
				end
				if player:getMark("ban_ur") > 0 then
					room:removePlayerMark(player, "ban_ur")
					room:removePlayerCardLimitation(player, "use,response", ".|.|.|hand")
				end
				for _, mark in sgs.list(player:getMarkNames()) do
					if player:getMark(mark) > 0 and string.find(mark, "_skillClear") then
						if player:hasSkill(string.sub(mark, 1, string.len(mark) - 11)) then
							room:detachSkillFromPlayer(player, string.sub(mark, 1, string.len(mark) - 11))
							room:filterCards(player, player:getCards("h"), true)
						end
						room:setPlayerMark(player, mark, 0)
					end
					if splayer:objectName() == player:objectName() then
						if string.find(mark, "_flag") and player:getMark(mark) > 0 then
							room:setPlayerMark(player, mark, 0)
						end
						if string.find(mark, "_manmanlai") and player:getMark(mark) > 0 then
							room:removePlayerMark(player, mark)
						end
						local duoruis = {}
						for _, skill in sgs.qlist(player:getVisibleSkillList()) do
							if player:getMark("Duorui" .. skill:objectName() .. "from") > 0 then
								table.insert(duoruis, "-" .. skill:objectName())
								room:setPlayerMark(player, "Duorui" .. skill:objectName() .. "from", 0)
							end
						end
						if #duoruis > 0 then
							room:handleAcquireDetachSkills(player, table.concat(duoruis, "|"))
						end
						for _, skill in sgs.qlist(player:getVisibleSkillList()) do
							if player:getMark("Duorui" .. skill:objectName()) > 0 then
								room:removePlayerMark(player, "Qingcheng" .. skill:objectName())
								room:removePlayerMark(player, "Duorui" .. skill:objectName())
							end
							if player:getMark("Duorui_sec_rev_to" .. skill:objectName()) > 0 then
								room:removePlayerMark(player, "Qingcheng" .. skill:objectName())
								room:removePlayerMark(player, "Duorui_sec_rev_to" .. skill:objectName())
							end
							if player:getMark("ol_Duorui_to" .. skill:objectName()) > 0 then
								room:removePlayerMark(player, "Qingcheng" .. skill:objectName())
								room:removePlayerMark(player, "ol_Duorui_to" .. skill:objectName())
							end
						end
					end
					if string.find(mark, "-Clear") and player:getMark(mark) > 0 then
						if mark == "turnOver-Clear" and player:getMark("turnOver-Clear") > 1 and player:faceUp() then
							room:addPlayerMark(player, "stop")
						end
						if string.find(mark, "funan") then
							room:removePlayerCardLimitation(player, "use,response",
								sgs.Sanguosha:getCard(tonumber(string.sub(mark, 6, string.len(mark) - 6))):toString())
						end
						room:setPlayerMark(player, mark, 0)
					end
				end
			end
		elseif change.to == sgs.Player_Play then
			for _, player in sgs.qlist(room:getAlivePlayers()) do
				for _, mark in sgs.list(player:getMarkNames()) do
					if splayer:objectName() == player:objectName() and string.find(mark, "_play") and player:getMark(mark) > 0 then
						room:setPlayerMark(player, mark, 0)
					end
					if string.find(mark, "_Play") and player:getMark(mark) > 0 then
						if mark == "zhongjian_Play" then
							sgs.Sanguosha:addTranslationEntry(":zhongjian",
								"" ..
								string.gsub(sgs.Sanguosha:translate(":zhongjian"), sgs.Sanguosha:translate(":zhongjian"),
									sgs.Sanguosha:translate(":zhongjian")))
						end
						if mark == "ol_zhongjian_Play" then
							sgs.Sanguosha:addTranslationEntry(":ol_zhongjian",
								"" ..
								string.gsub(sgs.Sanguosha:translate(":ol_zhongjian"),
									sgs.Sanguosha:translate(":ol_zhongjian"), sgs.Sanguosha:translate(":ol_zhongjian")))
						end
						room:setPlayerMark(player, mark, 0)
					end
				end
			end
			--add
		elseif change.from == sgs.Player_Play then
			for _, player in sgs.qlist(room:getAlivePlayers()) do
				for _, mark in sgs.list(player:getMarkNames()) do
					if splayer:objectName() == player:objectName() and string.find(mark, "_endplay") and player:getMark(mark) > 0 then
						room:setPlayerMark(player, mark, 0)
					end
				end
			end
		elseif change.to == sgs.Player_Discard then
			for _, player in sgs.qlist(room:getAlivePlayers()) do
				if room:getCurrent():objectName() == player:objectName() then
					for _, card in sgs.list(player:getHandcards()) do
						if player:getMark("luoshen" .. card:getId() .. "-Clear") > 0 then
							room:setPlayerCardLimitation(player, "discard",
								sgs.Sanguosha:getCard(card:getId()):toString(), false)
						end
					end
				end
			end
			--		elseif change.to == sgs.Player_Start then
			--			if splayer:getMark("ol_hunshang-Clear") > 0 and change.to == sgs.Player_Start and splayer:isWounded() then
			--				local to = room:askForPlayerChosen(splayer, room:getOtherPlayers(splayer), "yinghun", "yinghun-invoke", true, true)
			--				local x = splayer:getLostHp()
			--				local choices = {"yinghun1"}
			--				if to then
			--					if not to:isNude() and x ~= 1 then
			--						table.insert(choices, "yinghun2")
			--					end
			--					local choice = room:askForChoice(splayer, "yinghun", table.concat(choices, "+"))
			--					ChoiceLog(splayer, choice)
			--					if choice == "yinghun1" then
			--						to:drawCards(1)
			--						room:askForDiscard(to, self:objectName(), x, x, false, true)
			--						room:broadcastSkillInvoke("yinghun", 3)
			--					else
			--						to:drawCards(x)
			--						room:askForDiscard(to, self:objectName(), 1, 1, false, true)
			--						room:broadcastSkillInvoke("yinghun", 4)
			--					end
			--				end
			--			end
		elseif change.to == sgs.Player_RoundStart then
			for _, player in sgs.qlist(room:getAlivePlayers()) do
				if room:getCurrent():objectName() == player:objectName() then
					room:addPlayerMark(player, "turn")
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end
}

card_used = sgs.CreateTriggerSkill {
	name = "card_used",
	events = { sgs.PreCardUsed, sgs.PreCardResponded },
	global = true,
	priority = -1,
	on_trigger = function(self, event, player, data, room)
		local card
		local invoke = true
		if event == sgs.PreCardUsed then
			card = data:toCardUse().card
		else
			if data:toCardResponse().m_isUse then
				card = data:toCardResponse().m_card
			else
				invoke = false
			end
		end
		if card and not card:isKindOf("SkillCard") then
			if card:getSubcards():length() > 1 or (player:getMark("used_Play") > 0 and player:getMark("used-before-Clear") - 1 ~= card:getSuit()) or card:getSuit() > 3 then
				room:addPlayerMark(player, "guanwei_break-Clear")
			end
			room:setPlayerMark(player, "used-before-Clear", card:getSuit() + 1)
			if invoke then
				room:addPlayerMark(player, "used-Clear")
				if player:getPhase() == sgs.Player_Play then
					room:addPlayerMark(player, "used_Play")
				end
			end
			room:addPlayerMark(player, "us-Clear")
			if player:getPhase() == sgs.Player_Play then
				room:addPlayerMark(player, "us_Play")
			end
			if card:isKindOf("Slash") then
				room:addPlayerMark(player, "used_slash-Clear")
				room:addPlayerMark(player, "used_slashcount")
				if player:getPhase() == sgs.Player_Play then
					room:addPlayerMark(player, "used_slash_Play")
				end
			end
		end
		return false
	end
}

damage_record = sgs.CreateTriggerSkill {
	name = "damage_record",
	events = { sgs.DamageComplete },
	global = true,
	on_trigger = function(self, event, player, data, room)
		if data:toDamage().from then
			room:addPlayerMark(data:toDamage().from, self:objectName(), data:toDamage().damage)
			room:addPlayerMark(data:toDamage().from, self:objectName() .. "-Clear", data:toDamage().damage)
			if data:toDamage().from:getPhase() == sgs.Player_Play then
				room:addPlayerMark(data:toDamage().from, self:objectName() .. "play-Clear", data:toDamage().damage)
			end
		end
	end
}

damage_card_record = sgs.CreateTriggerSkill {
	name = "damage_card_record",
	events = { sgs.DamageComplete, sgs.CardFinished },
	priority = -1,
	global = true,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.DamageComplete then
			local damage = data:toDamage()
			if damage.card then
				room:setCardFlag(damage.card, "damage_record")
			end
		else
			local use = data:toCardUse()
			if use.card then
				room:setCardFlag(use.card, "-damage_record")
			end
		end
	end
}
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("damage_card_record") then skills:append(damage_card_record) end
if not sgs.Sanguosha:getSkill("damage_record") then skills:append(damage_record) end
if not sgs.Sanguosha:getSkill("card_used") then skills:append(card_used) end
if not sgs.Sanguosha:getSkill("clear_mark") then skills:append(clear_mark) end
if not sgs.Sanguosha:getSkill("turn_length") then skills:append(turn_length) end

sgs.Sanguosha:addSkills(skills)
sgs.LoadTranslationTable {
	["extra"] = "ZY",
	["-_endplay"] = "",
	["_lun"] = "",
	["-_flag"] = "",
	["_flag"] = "",
	["_biu"] = "",
	["-PlayClear"] = "",
	["fail"] = "失效",
	["used"] = "已使用",
}
function RIGHT(self, player)
	if player and player:isAlive() and player:hasSkill(self:objectName()) then return true else return false end
end

player2serverplayer = function(room, player) --啦啦SLG (OTZ--ORZ--Orz) --作用：将currentplayer转换成serverplayer
	local players = room:getPlayers()
	for _, p in sgs.qlist(players) do
		if p:objectName() == player:objectName() then
			return p
		end
	end
end





return { extension }
