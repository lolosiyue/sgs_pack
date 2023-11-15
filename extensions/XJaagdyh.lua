extension = sgs.Package("XJaagdyh", sgs.Package_GeneralPack)

--XJ01 测试-高达一号
xj_gaodayihao = sgs.General(extension, "xj_gaodayihao", "god", 1, true)

xj_juejing = sgs.CreateTriggerSkill {
	name = "xj_juejing",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.CardsMoveOneTime, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			local source = move.from
			local target = move.to
			if not source or source:objectName() ~= player:objectName() then
				if not target or target:objectName() ~= player:objectName() then
					return false
				end
			end
			if move.to_place ~= sgs.Player_PlaceHand then
				if not move.from_places:contains(sgs.Player_PlaceHand) then
					return false
				end
			end
			if player:getPhase() == sgs.Player_Discard then
				return false
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			local nextphase = change.to
			if nextphase == sgs.Player_Draw then
				player:getRoom():broadcastSkillInvoke(self:objectName())
				player:skip(nextphase)
				return false
			elseif nextphase ~= sgs.Player_Finish then
				return false
			end
		end
		local count = player:getHandcardNum()
		if count == 4 then
			return false
		elseif count < 4 then
			player:drawCards(4 - count)
		elseif count > 4 then
			local room = player:getRoom()
			room:askForDiscard(player, self:objectName(), count - 4, count - 4)
		end
		return false
	end,
}
xj_gaodayihao:addSkill(xj_juejing)

xj_longhun = sgs.CreateViewAsSkill {
	name = "xj_longhun",
	n = 1,
	view_filter = function(self, selected, to_select)
		if (#selected >= 1) or to_select:hasFlag("using") then return false end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			if sgs.Self:isWounded() and (to_select:getSuit() == sgs.Card_Heart) then
				return true
			elseif sgs.Slash_IsAvailable(sgs.Self) and (to_select:getSuit() == sgs.Card_Diamond) then
				if sgs.Self:getWeapon() and (to_select:getEffectiveId() == sgs.Self:getWeapon():getId())
					and to_select:isKindOf("Crossbow") then
					return sgs.Self:canSlashWithoutCrossbow()
				else
					return true
				end
			else
				return false
			end
		elseif (sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE)
			or (sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE) then
			local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if pattern == "nullification" then
				return to_select:getSuit() == sgs.Card_Spade
			elseif pattern == "jink" then
				return to_select:getSuit() == sgs.Card_Club
			elseif string.find(pattern, "peach") then
				return to_select:getSuit() == sgs.Card_Heart
			elseif pattern == "slash" then
				return to_select:getSuit() == sgs.Card_Diamond
			end
			return false
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local card = cards[1]
		local new_card = nil
		if card:getSuit() == sgs.Card_Spade then
			new_card = sgs.Sanguosha:cloneCard("nullification", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Club then
			new_card = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Heart then
			new_card = sgs.Sanguosha:cloneCard("peach", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Diamond then
			new_card = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, 0)
		end
		if new_card then
			new_card:setSkillName(self:objectName())
			for _, c in ipairs(cards) do
				new_card:addSubcard(c)
			end
		end
		return new_card
	end,
	enabled_at_play = function(self, player)
		return player:isWounded() or sgs.Slash_IsAvailable(player)
	end,
	enabled_at_response = function(self, player, pattern)
		return (pattern == "slash")
			or (pattern == "jink")
			or (string.find(pattern, "peach") and (not player:hasFlag("Global_PreventPeach")))
			or (pattern == "nullification")
	end,
	enabled_at_nullification = function(self, player)
		local count = 0
		for _, card in sgs.qlist(player:getHandcards()) do
			if card:getSuit() == sgs.Card_Spade then count = count + 1 end
			if count >= 1 then return true end
		end
		for _, card in sgs.qlist(player:getEquips()) do
			if card:getSuit() == sgs.Card_Spade then count = count + 1 end
			if count >= 1 then return true end
		end
	end,
}
--新“龙魂”
xj_newlonghun = sgs.CreateViewAsSkill {
	name = "xj_newlonghun",
	n = 2,
	response_or_use = true,
	view_filter = function(self, selected, to_select)
		if (#selected > 1) or to_select:hasFlag("using") then return false end
		if #selected > 0 then
			return to_select:getSuit() == selected[1]:getSuit()
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			if sgs.Self:isWounded() or (to_select:getSuit() == sgs.Card_Heart) then
				return true
			elseif sgs.Slash_IsAvailable(sgs.Self) and (to_select:getSuit() == sgs.Card_Diamond) then
				if sgs.Self:getWeapon() and (to_select:getEffectiveId() == sgs.Self:getWeapon():getId())
					and to_select:isKindOf("Crossbow") then
					return sgs.Self:canSlashWithoutCrossbow()
				else
					return true
				end
			else
				return false
			end
		elseif (sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE)
			or (sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE) then
			local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if pattern == "nullification" then
				return to_select:getSuit() == sgs.Card_Spade
			elseif pattern == "jink" then
				return to_select:getSuit() == sgs.Card_Club
			elseif string.find(pattern, "peach") then
				return to_select:getSuit() == sgs.Card_Heart
			elseif pattern == "slash" then
				return to_select:getSuit() == sgs.Card_Diamond
			end
			return false
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards ~= 1 and #cards ~= 2 then return nil end
		local card = cards[1]
		local new_card = nil
		if card:getSuit() == sgs.Card_Spade then
			new_card = sgs.Sanguosha:cloneCard("nullification", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Club then
			new_card = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Heart then
			new_card = sgs.Sanguosha:cloneCard("peach", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Diamond then
			new_card = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, 0)
		end
		if new_card then
			if #cards == 1 then
				new_card:setSkillName(self:objectName())
			else
				new_card:setSkillName("xj_newlonghunBuff")
			end
			for _, c in ipairs(cards) do
				new_card:addSubcard(c)
			end
		end
		return new_card
	end,
	enabled_at_play = function(self, player)
		return player:isWounded() or sgs.Slash_IsAvailable(player)
	end,
	enabled_at_response = function(self, player, pattern)
		return (pattern == "slash")
			or (pattern == "jink")
			or (string.find(pattern, "peach") and (not player:hasFlag("Global_PreventPeach")))
			or (pattern == "nullification")
	end,
	enabled_at_nullification = function(self, player)
		local count = 0
		for _, card in sgs.qlist(player:getHandcards()) do
			if card:getSuit() == sgs.Card_Spade then count = count + 1 end
			if count >= 1 then return true end
		end
		for _, card in sgs.qlist(player:getEquips()) do
			if card:getSuit() == sgs.Card_Spade then count = count + 1 end
			if count >= 1 then return true end
		end
	end,
}
xj_newlonghunBuff = sgs.CreateTriggerSkill {
	name = "xj_newlonghunBuff",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.PreHpRecover, sgs.ConfirmDamage, sgs.CardUsed, sgs.CardResponded },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.PreHpRecover then
			local rec = data:toRecover()
			if rec.card and rec.card:getSkillName() == "xj_newlonghunBuff" then
				local log = sgs.LogMessage()
				log.type = "$xj_newlonghunREC"
				log.from = player
				room:sendLog(log)
				rec.recover = rec.recover + 1
				data:setValue(rec)
			end
		elseif event == sgs.ConfirmDamage then
			local dmg = data:toDamage()
			if dmg.card and dmg.card:getSkillName() == "xj_newlonghunBuff" then
				local log = sgs.LogMessage()
				log.type = "$xj_newlonghunDMG"
				log.from = player
				room:sendLog(log)
				dmg.damage = dmg.damage + 1
				data:setValue(dmg)
			end
		else
			local card
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else
				card = data:toCardResponse().m_card
			end
			if card and card:isBlack() and card:getSkillName() == "xj_newlonghunBuff" then
				local current = room:getCurrent()
				if current:isNude() then return false end
				room:doAnimate(1, player:objectName(), current:objectName())
				local id = room:askForCardChosen(player, current, "he", "xj_newlonghun", false, sgs.Card_MethodDiscard)
				room:throwCard(id, current, player)
			end
		end
		return false
	end,
}
xj_tonewlonghunCard = sgs.CreateSkillCard {
	name = "xj_tonewlonghunCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:detachSkillFromPlayer(source, "xj_longhun", true)
		room:attachSkillToPlayer(source, "xj_newlonghun")
	end,
}
xj_tonewlonghunVS = sgs.CreateZeroCardViewAsSkill {
	name = "xj_tonewlonghun",
	view_as = function()
		return xj_tonewlonghunCard:clone()
	end,
	response_pattern = "@@xj_tonewlonghun",
}
xj_tonewlonghun = sgs.CreateTriggerSkill {
	name = "xj_tonewlonghun",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.GameStart },
	view_as_skill = xj_tonewlonghunVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			room:askForUseCard(player, "@@xj_tonewlonghun", "@xj_tonewlonghun")
		end
		return false
	end,
	can_trigger = function(self, player)
		return (player:getGeneralName() == "xj_gaodayihao" or player:getGeneral2Name() == "xj_gaodayihao") and
		player:hasSkill("xj_longhun")
	end,
}
----
--“龙魂”配音（改二重奏了，四重奏听起来太刺耳了）
xj_loonghun = sgs.CreateTriggerSkill {
	name = "xj_loonghun",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.CardUsed, sgs.CardResponded },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local card = nil
		if event == sgs.CardUsed then
			card = data:toCardUse().card
		else
			card = data:toCardResponse().m_card
		end
		if card and card:isKindOf("Nullification") and (card:getSkillName() == "xj_longhun"
				or card:getSkillName() == "xj_newlonghun" or card:getSkillName() == "xj_newlonghunBuff") then
			room:broadcastSkillInvoke(self:objectName(), 1)
			room:broadcastSkillInvoke(self:objectName(), 1)
		elseif card and card:isKindOf("Jink") and (card:getSkillName() == "xj_longhun"
				or card:getSkillName() == "xj_newlonghun" or card:getSkillName() == "xj_newlonghunBuff") then
			room:broadcastSkillInvoke(self:objectName(), 2)
			room:broadcastSkillInvoke(self:objectName(), 2)
		elseif card and card:isKindOf("Peach") and (card:getSkillName() == "xj_longhun"
				or card:getSkillName() == "xj_newlonghun" or card:getSkillName() == "xj_newlonghunBuff") then
			room:broadcastSkillInvoke(self:objectName(), 3)
			room:broadcastSkillInvoke(self:objectName(), 3)
		elseif card and card:isKindOf("FireSlash") and (card:getSkillName() == "xj_longhun"
				or card:getSkillName() == "xj_newlonghun" or card:getSkillName() == "xj_newlonghunBuff") then
			room:broadcastSkillInvoke(self:objectName(), 4)
			room:broadcastSkillInvoke(self:objectName(), 4)
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("xj_longhun") or player:hasSkill("xj_newlonghun")
	end,
}
----
xj_gaodayihao:addSkill(xj_longhun)
xj_gaodayihao:addRelateSkill("xj_loonghun")

local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("xj_newlonghun") then skills:append(xj_newlonghun) end
if not sgs.Sanguosha:getSkill("xj_newlonghunBuff") then skills:append(xj_newlonghunBuff) end
if not sgs.Sanguosha:getSkill("xj_tonewlonghun") then skills:append(xj_tonewlonghun) end
if not sgs.Sanguosha:getSkill("xj_loonghun") then skills:append(xj_loonghun) end

xj_zhanjiang = sgs.CreateTriggerSkill {
	name = "xj_zhanjiang",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Start then
			local room = player:getRoom()
			local other = room:getOtherPlayers(player)
			for _, p in sgs.qlist(other) do
				local weapon = p:getWeapon()
				if weapon and weapon:objectName() == "QinggangSword" then
					if room:askForSkillInvoke(player, self:objectName(), data) then
						player:obtainCard(weapon)
					end
				end
			end
		end
		return false
	end,
}
xj_gaodayihao:addSkill(xj_zhanjiang)

sgs.LoadTranslationTable {
	--["XJaagdyh"] = "仙界武将-高达一号",
	["XJaagdyh"] = "仙界武将",
	----
	["xj_gaodayihao"] = "[高达一号]初代神赵云",
	["&xj_gaodayihao"] = "高达一号",
	["#xj_gaodayihao"] = "仙界起源",
	["designer:xj_gaodayihao"] = "官方测试",
	["cv:xj_gaodayihao"] = "猎狐",
	["illustrator:xj_gaodayihao"] = "巴萨小马",
	--绝境
	["xj_juejing"] = "绝境",
	[":xj_juejing"] = "锁定技，你始终跳过你的摸牌阶段；你的手牌数恒定为4。",
	["$xj_juejing"] = "龙战于野，其血玄黄。",
	--龙魂
	["xj_longhun"] = "龙魂",
	["xj_tonewlonghun"] = "龙魂",
	[":xj_longhun"] = "你可以将你的一张牌按以下规则使用或打出：♥当【桃】；♦当火【杀】；♣当【闪】；♠当【无懈可击】。游戏开始时，你可以将此技能替换成“新龙魂”。",
	["@xj_tonewlonghun"] = "你可以将“龙魂”替换成“新龙魂”",
	--新龙魂
	["xj_newlonghun"] = "龙魂",
	["xj_newlonghunBuff"] = "龙魂",
	[":xj_newlonghun"] = "你可以将你的至多两张同花色的牌按以下规则使用或打出：♥当【桃】；♦当火【杀】；♣当【闪】；♠当【无懈可击】。若你以此法使用了两张红色牌，此牌回复值或伤害值+1；若你以此法使用了两张黑色牌，你弃置当前回合角色的一张牌。",
	["$xj_newlonghunREC"] = "%from 发动“<font color='yellow'><b>龙魂</b></font>”使用了两张<font color='red'><b>红色</b></font>牌，此【<font color='yellow'><b>桃</b></font>】的回复值+1",
	["$xj_newlonghunDMG"] = "%from 发动“<font color='yellow'><b>龙魂</b></font>”使用了两张<font color='red'><b>红色</b></font>牌，此【<font color='yellow'><b>杀</b></font>】的伤害值+1",
	["xj_loonghun"] = "龙魂-配音",
	[":xj_loonghun"] = "\
	<font color='black'>通过“龙魂”使用【无懈可击】——>金甲映日，驱邪祛秽</font>\
	<font color=\"#00FFFF\">通过“龙魂”使用/打出【闪】——>腾龙行云，首尾不见</font>\
	<font color='pink'>通过“龙魂”使用【桃】——>潜龙于渊，涉灵愈伤</font>\
	<font color='red'>通过“龙魂”使用/打出火【杀】——>千里一怒，红莲灿世</font>",
	["$xj_loonghun1"] = "金甲映日，驱邪祛秽。",
	["$xj_loonghun2"] = "腾龙行云，首尾不见。",
	["$xj_loonghun3"] = "潜龙于渊，涉灵愈伤。",
	["$xj_loonghun4"] = "千里一怒，红莲灿世！",
	--斩将
	["xj_zhanjiang"] = "斩将",
	[":xj_zhanjiang"] = "准备阶段，若场上有【青釭剑】，你可以获得之。",
	--阵亡
	["~xj_gaodayihao"] = "血染鳞甲，龙坠九天.........",
}

--XJ02 新杀-曹金玉
xj_caojinyu = sgs.General(extension, "xj_caojinyu", "wei", 3, false)

xj_yuqi = sgs.CreateTriggerSkill {
	name = "xj_yuqi",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.GameStart, sgs.Damaged, sgs.EventPhaseStart, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:hasSkill(self:objectName()) then
				room:setPlayerMark(player, "&yq_distance", 0)
				room:setPlayerMark(player, "&yq_see", 3)
				room:setPlayerMark(player, "&yq_give", 1)
				room:setPlayerMark(player, "&yq_get", 1)
			end
		elseif event == sgs.Damaged then
			local damage = data:toDamage()
			if damage.to:objectName() ~= player:objectName() or not player:isAlive() then return false end
			for _, c in sgs.qlist(room:getAllPlayers()) do
				local d = c:getMark("yq_distance")
				if (d == 0 and c:objectName() ~= player:objectName()) or (d > 0 and c:distanceTo(player) > d) or c:getMark("xj_yuqiFQC") == 0 then continue end
				if not room:askForSkillInvoke(c, self:objectName(), data) then continue end
				room:broadcastSkillInvoke(self:objectName())
				room:setPlayerFlag(player, "xj_yuqiDamagedTarget")
				--看牌
				local s = c:getMark("yq_see") + 3
				local card_ids = room:getNCards(s, false)
				--c:addToPile(self:objectName(), card_ids, false)
				c:addToPile(self:objectName(), card_ids)
				--给牌
				room:askForUseCard(c, "@@xj_yuqiGive", "@xj_yuqiGive-card")
				--得牌
				if c:getPile(self:objectName()):length() > 0 then
					room:askForUseCard(c, "@@xj_yuqiGet", "@xj_yuqiGet-card")
				end
				--放回
				if c:getPile(self:objectName()):length() > 0 then
					local dummy = sgs.Sanguosha:cloneCard("slash")
					dummy:addSubcards(c:getPile(self:objectName()))
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, c:objectName(), nil,
						self:objectName(), nil)
					room:moveCardTo(dummy, c, nil, sgs.Player_DrawPile, reason, false)
				end
				room:setPlayerFlag(player, "-xj_yuqiDamagedTarget")
				room:removePlayerMark(c, "xj_yuqiFQC")
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					room:setPlayerMark(p, "xj_yuqiFQC", 2)
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("xj_yuqiFQC") > 0 then
					room:setPlayerMark(p, "xj_yuqiFQC", 0)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
--给牌
xj_yuqiGiveCard = sgs.CreateSkillCard {
	name = "xj_yuqiGiveCard",
	will_throw = false,
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:hasFlag("xj_yuqiDamagedTarget")
	end,
	on_use = function(self, room, source, targets)
		local heyan = targets[1]
		heyan:obtainCard(self, false)
	end,
}
xj_yuqiGive = sgs.CreateViewAsSkill {
	name = "xj_yuqiGive",
	n = 999,
	expand_pile = "xj_yuqi",
	view_filter = function(self, selected, to_select)
		local x = sgs.Self:getMark("yq_give") + 1
		local y = sgs.Self:getPile("xj_yuqi"):length()
		if x > y then x = y end
		if #selected >= x then return end
		return sgs.Self:getPile("xj_yuqi"):contains(to_select:getId())
	end,
	view_as = function(self, cards)
		local x = sgs.Self:getMark("yq_give") + 1
		local y = sgs.Self:getPile("xj_yuqi"):length()
		if x > y then x = y end
		if #cards >= 1 and #cards <= x then
			local c = xj_yuqiGiveCard:clone()
			for _, card in ipairs(cards) do
				c:addSubcard(card)
			end
			return c
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	response_pattern = "@@xj_yuqiGive", --[[enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@xj_yuqiGive")
	end,]]
}
--得牌
xj_yuqiGetCard = sgs.CreateSkillCard {
	name = "xj_yuqiGetCard",
	will_throw = false,
	target_fixed = true,
	on_use = function(self, room, source, targets)
		source:obtainCard(self, false)
	end,
}
xj_yuqiGet = sgs.CreateViewAsSkill {
	name = "xj_yuqiGet",
	n = 999,
	expand_pile = "xj_yuqi",
	view_filter = function(self, selected, to_select)
		local x = sgs.Self:getMark("yq_get") + 1
		local y = sgs.Self:getPile("xj_yuqi"):length()
		if x > y then x = y end
		if #selected >= x then return end
		return sgs.Self:getPile("xj_yuqi"):contains(to_select:getId())
	end,
	view_as = function(self, cards)
		local x = sgs.Self:getMark("yq_get") + 1
		local y = sgs.Self:getPile("xj_yuqi"):length()
		if x > y then x = y end
		if #cards >= 1 and #cards <= x then
			local c = xj_yuqiGetCard:clone()
			for _, card in ipairs(cards) do
				c:addSubcard(card)
			end
			return c
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	response_pattern = "@@xj_yuqiGet", --[[enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@xj_yuqiGet")
	end,]]
}
xj_caojinyu:addSkill(xj_yuqi)
--local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("xj_yuqiGive") then skills:append(xj_yuqiGive) end
if not sgs.Sanguosha:getSkill("xj_yuqiGet") then skills:append(xj_yuqiGet) end

xj_shanshen = sgs.CreateTriggerSkill {
	name = "xj_shanshen",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.Damage, sgs.Death },
	--events = {sgs.Damage, sgs.AskForPeachesDone},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damage then
			local damage = data:toDamage()
			if player:hasSkill(self:objectName()) and damage.to:getMark("xj_shanshenEye") == 0 then
				room:addPlayerMark(damage.to, "xj_shanshenEye")
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then return false end
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if not p:hasSkill(self:objectName()) or not room:askForSkillInvoke(p, self:objectName(), data) then continue end
				room:broadcastSkillInvoke(self:objectName())
				local d = p:getMark("yq_distance")
				local s = p:getMark("yq_see") + 3
				local i = p:getMark("yq_give") + 1
				local e = p:getMark("yq_get") + 1
				if d < 5 or s < 5 or i < 5 or e < 5 then
					local choices = {}
					if d == 0 then
						table.insert(choices, "yq_distance2")
					elseif d == 1 then
						table.insert(choices, "yq_distance3")
					elseif d == 2 then
						table.insert(choices, "yq_distance4")
					elseif d >= 3 and d < 5 then
						table.insert(choices, "yq_distance5")
					end
					if s >= 3 and s < 5 then
						table.insert(choices, "yq_see5")
					end
					if i == 1 then
						table.insert(choices, "yq_give3")
					elseif i == 2 then
						table.insert(choices, "yq_give4")
					elseif i >= 3 and i < 5 then
						table.insert(choices, "yq_give5")
					end
					if e == 1 then
						table.insert(choices, "yq_get3")
					elseif e == 2 then
						table.insert(choices, "yq_get4")
					elseif e >= 3 and e < 5 then
						table.insert(choices, "yq_get5")
					end
					local choice = room:askForChoice(p, self:objectName(), table.concat(choices, "+"))
					if choice == "yq_distance2" then
						room:setPlayerMark(p, "&yq_distance", 2)
						room:setPlayerMark(p, "yq_distance", 2)
					elseif choice == "yq_distance3" then
						room:setPlayerMark(p, "&yq_distance", 3)
						room:setPlayerMark(p, "yq_distance", 3)
					elseif choice == "yq_distance4" then
						room:setPlayerMark(p, "&yq_distance", 4)
						room:setPlayerMark(p, "yq_distance", 4)
					elseif choice == "yq_distance5" then
						room:setPlayerMark(p, "&yq_distance", 5)
						room:setPlayerMark(p, "yq_distance", 5)
					elseif choice == "yq_see5" then
						room:setPlayerMark(p, "&yq_see", 5)
						room:setPlayerMark(p, "yq_see", 2)
					elseif choice == "yq_give3" then
						room:setPlayerMark(p, "&yq_give", 3)
						room:setPlayerMark(p, "yq_give", 2)
					elseif choice == "yq_give4" then
						room:setPlayerMark(p, "&yq_give", 4)
						room:setPlayerMark(p, "yq_give", 3)
					elseif choice == "yq_give5" then
						room:setPlayerMark(p, "&yq_give", 5)
						room:setPlayerMark(p, "yq_give", 4)
					elseif choice == "yq_get3" then
						room:setPlayerMark(p, "&yq_get", 3)
						room:setPlayerMark(p, "yq_get", 2)
					elseif choice == "yq_get4" then
						room:setPlayerMark(p, "&yq_get", 4)
						room:setPlayerMark(p, "yq_get", 3)
					elseif choice == "yq_get5" then
						room:setPlayerMark(p, "&yq_get", 5)
						room:setPlayerMark(p, "yq_get", 4)
					end
				end
				if player:getMark("xj_shanshenEye") == 0 and p:isWounded() then
					room:recover(p, sgs.RecoverStruct(p))
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
xj_caojinyu:addSkill(xj_shanshen)

xj_xianjing = sgs.CreateTriggerSkill {
	name = "xj_xianjing",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseProceeding },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase == sgs.Player_Start then
			local d = player:getMark("yq_distance")
			local s = player:getMark("yq_see") + 3
			local i = player:getMark("yq_give") + 1
			local e = player:getMark("yq_get") + 1
			if d >= 5 and s >= 5 and i >= 5 and e >= 5 then return false end
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName())
				while player:getMark("xj_xianjingStop") < 2 do
					local d = player:getMark("yq_distance")
					local s = player:getMark("yq_see") + 3
					local i = player:getMark("yq_give") + 1
					local e = player:getMark("yq_get") + 1
					local choices = {}
					if d == 0 then
						table.insert(choices, "yq_distance1")
					elseif d == 1 then
						table.insert(choices, "yq_distance2")
					elseif d == 2 then
						table.insert(choices, "yq_distance3")
					elseif d == 3 then
						table.insert(choices, "yq_distance4")
					elseif d == 4 then
						table.insert(choices, "yq_distance5")
					end
					if s == 3 then
						table.insert(choices, "yq_see4")
					elseif s == 4 then
						table.insert(choices, "yq_see5")
					end
					if i == 1 then
						table.insert(choices, "yq_give2")
					elseif i == 2 then
						table.insert(choices, "yq_give3")
					elseif i == 3 then
						table.insert(choices, "yq_give4")
					elseif i == 4 then
						table.insert(choices, "yq_give5")
					end
					if e == 1 then
						table.insert(choices, "yq_get2")
					elseif e == 2 then
						table.insert(choices, "yq_get3")
					elseif e == 3 then
						table.insert(choices, "yq_get4")
					elseif e == 4 then
						table.insert(choices, "yq_get5")
					end
					local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
					if choice == "yq_distance1" then
						room:setPlayerMark(player, "&yq_distance", 1)
						room:setPlayerMark(player, "yq_distance", 1)
					elseif choice == "yq_distance2" then
						room:setPlayerMark(player, "&yq_distance", 2)
						room:setPlayerMark(player, "yq_distance", 2)
					elseif choice == "yq_distance3" then
						room:setPlayerMark(player, "&yq_distance", 3)
						room:setPlayerMark(player, "yq_distance", 3)
					elseif choice == "yq_distance4" then
						room:setPlayerMark(player, "&yq_distance", 4)
						room:setPlayerMark(player, "yq_distance", 4)
					elseif choice == "yq_distance5" then
						room:setPlayerMark(player, "&yq_distance", 5)
						room:setPlayerMark(player, "yq_distance", 5)
					elseif choice == "yq_see4" then
						room:setPlayerMark(player, "&yq_see", 4)
						room:setPlayerMark(player, "yq_see", 1)
					elseif choice == "yq_see5" then
						room:setPlayerMark(player, "&yq_see", 5)
						room:setPlayerMark(player, "yq_see", 2)
					elseif choice == "yq_give2" then
						room:setPlayerMark(player, "&yq_give", 2)
						room:setPlayerMark(player, "yq_give", 1)
					elseif choice == "yq_give3" then
						room:setPlayerMark(player, "&yq_give", 3)
						room:setPlayerMark(player, "yq_give", 2)
					elseif choice == "yq_give4" then
						room:setPlayerMark(player, "&yq_give", 4)
						room:setPlayerMark(player, "yq_give", 3)
					elseif choice == "yq_give5" then
						room:setPlayerMark(player, "&yq_give", 5)
						room:setPlayerMark(player, "yq_give", 4)
					elseif choice == "yq_get2" then
						room:setPlayerMark(player, "&yq_get", 2)
						room:setPlayerMark(player, "yq_get", 1)
					elseif choice == "yq_get3" then
						room:setPlayerMark(player, "&yq_get", 3)
						room:setPlayerMark(player, "yq_get", 2)
					elseif choice == "yq_get4" then
						room:setPlayerMark(player, "&yq_get", 4)
						room:setPlayerMark(player, "yq_get", 3)
					elseif choice == "yq_get5" then
						room:setPlayerMark(player, "&yq_get", 5)
						room:setPlayerMark(player, "yq_get", 4)
					end
					if player:isWounded() then
						room:addPlayerMark(player, "xj_xianjingStop", 2)
					else
						room:addPlayerMark(player, "xj_xianjingStop", 1)
					end
				end
				room:setPlayerMark(player, "xj_xianjingStop", 0)
			end
		end
	end,
}
xj_caojinyu:addSkill(xj_xianjing)

sgs.LoadTranslationTable {
	--["XJabcjy"] = "仙界武将-曹金玉",
	----
	["xj_caojinyu"] = "曹金玉",
	["#xj_caojinyu"] = "金玉大帝",
	["designer:xj_caojinyu"] = "官方(十周年)",
	["cv:xj_caojinyu"] = "官方",
	["illustrator:xj_caojinyu"] = "木美人", --皮肤：惊鸿倩影
	--隅泣
	["xj_yuqi"] = "隅泣",
	["xj_yuqiGive"] = "隅泣",
	["xj_yuqigive"] = "隅泣",
	["xj_yuqiGet"] = "隅泣",
	["xj_yuqiget"] = "隅泣",
	[":xj_yuqi"] = "<font color='green'><b>每个回合限两次，</b></font>当你距离【0】以内的一名角色受到伤害后，你可以观看牌堆顶的【3】张牌，将其中至多【1】张牌交给受伤角色，获得至多【1】张牌，剩余的牌放回牌堆顶。（【】内的数字至多为5）",
	----数字变动区----
	--当你距离【0】以内的一名角色受到伤害后
	["yq_distance"] = "隅泣:距离",
	["yq_distance1"] = "当你距离【1】以内的一名角色受到伤害后",
	["yq_distance2"] = "当你距离【2】以内的一名角色受到伤害后",
	["yq_distance3"] = "当你距离【3】以内的一名角色受到伤害后",
	["yq_distance4"] = "当你距离【4】以内的一名角色受到伤害后",
	["yq_distance5"] = "当你距离【5】以内的一名角色受到伤害后",
	--你可以观看牌堆顶的【3】张牌
	["yq_see"] = "隅泣:观顶",
	["yq_see4"] = "你可以观看牌堆顶的【4】张牌",
	["yq_see5"] = "你可以观看牌堆顶的【5】张牌",
	--将其中至多【1】张牌交给受伤角色
	["yq_give"] = "隅泣:交予",
	["yq_give2"] = "将其中至多【2】张牌交给受伤角色",
	["yq_give3"] = "将其中至多【3】张牌交给受伤角色",
	["yq_give4"] = "将其中至多【4】张牌交给受伤角色",
	["yq_give5"] = "将其中至多【5】张牌交给受伤角色",
	--获得至多【1】张牌
	["yq_get"] = "隅泣:获得",
	["yq_get2"] = "获得至多【2】张牌",
	["yq_get3"] = "获得至多【3】张牌",
	["yq_get4"] = "获得至多【4】张牌",
	["yq_get5"] = "获得至多【5】张牌",
	-------------------
	["xj_yuqiFQC"] = "",
	["@xj_yuqiGive-card"] = "你可以将合法数量范围内的牌交给该受伤角色",
	["~xj_yuqiGive"] = "武将头像上的[隅泣:交予]标记数为给牌的最大数量",
	["@xj_yuqiGet-card"] = "你可以将合法数量范围内的牌交给自己",
	["~xj_yuqiGet"] = "武将头像上的[隅泣:获得]标记数为可获得牌的最大数量",
	["$xj_yuqi1"] = "泪眼婆娑泣，伊人憔悴消。",
	["$xj_yuqi2"] = "柔情愁肠断，寂寞梧桐落。",
	--善身
	["xj_shanshen"] = "善身",
	[":xj_shanshen"] = "当有角色死亡时，你可令“隅泣”描述中【】内的一个数字+2。然后若你未对其造成过伤害，你回复1点体力。",
	["xj_shanshenEye"] = "恶业",
	["$xj_shanshen1"] = "天子之家，需守心静身。",
	["$xj_shanshen2"] = "心清则明，积善则安。",
	--娴静
	["xj_xianjing"] = "娴静",
	[":xj_xianjing"] = "准备阶段，你可令“隅泣”描述中【】内的一个数字+1。若你未受伤，你可再令“隅泣”描述中【】内的一个数字+1。",
	["$xj_xianjing1"] = "娴雅淑静，冰清玉洁。",
	["$xj_xianjing2"] = "媖娴美好，典雅温蕴。",
	--阵亡
	["~xj_caojinyu"] = "余香空留此，玉指轻揉散。",
}

--XJ03 新杀-管宁
xj_guanning = sgs.General(extension, "xj_guanning", "qun", 7, true, false, false, 3)

xj_dunshiCard = sgs.CreateSkillCard { --使用杀/桃/酒
	name = "xj_dunshiCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local basic = { "slash", "peach", "analeptic", "cancel" }
		local who = room:getCurrentDyingPlayer()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if who then
			table.removeOne(basic, "slash")
			if source:getMark("xj_dunshiCantUsePeach") > 0 or source:getMark("Global_PreventPeach") > 0 then
				table.removeOne(basic, "peach")
			end
			if source:getMark("xj_dunshiCantUseAnaleptic") > 0 or who:objectName() ~= source:objectName() then
				table.removeOne(basic, "analeptic")
			end
		else
			if source:getMark("xj_dunshiCantUseSlash") > 0 or not sgs.Slash_IsAvailable(source) then
				table.removeOne(basic, "slash")
			end
			if source:getMark("xj_dunshiCantUsePeach") > 0 or source:getMark("Global_PreventPeach") > 0 or not source:isWounded() or pattern == "slash" then
				table.removeOne(basic, "peach")
			end
			if source:getMark("xj_dunshiCantUseAnaleptic") > 0 or not sgs.Analeptic_IsAvailable(source) or pattern == "slash" then
				table.removeOne(basic, "analeptic")
			end
		end
		local choice = room:askForChoice(source, "xj_dunshi", table.concat(basic, "+"))
		local current = room:getCurrent()
		if choice == "slash" then
			room:setPlayerFlag(source, "xj_dunshiUsed")
			room:setPlayerFlag(current, "xj_dunshiBeingInvoke")
			if not room:askForUseCard(source, "@@xj_dunshiNormalSlash", "@xj_dunshiNormalSlash") then --将使用卡牌置于获得使用标志之后，以及时触发“遁世”选项
				room:setPlayerFlag(source, "-xj_dunshiUsed")                                 --给容错
				room:setPlayerFlag(current, "-xj_dunshiBeingInvoke")
			end
		elseif choice == "peach" then
			room:setPlayerFlag(source, "xj_dunshiUsed")
			room:setPlayerFlag(current, "xj_dunshiBeingInvoke")
			local peach = sgs.Sanguosha:cloneCard("Peach", sgs.Card_NoSuit, 0)
			peach:setSkillName("xj_dunshi")
			if who then
				room:useCard(sgs.CardUseStruct(peach, source, who, false))
			else
				room:useCard(sgs.CardUseStruct(peach, source, source, false))
			end
		elseif choice == "analeptic" then
			room:setPlayerFlag(source, "xj_dunshiUsed")
			room:setPlayerFlag(current, "xj_dunshiBeingInvoke")
			local analeptic = sgs.Sanguosha:cloneCard("Analeptic", sgs.Card_NoSuit, 0)
			analeptic:setSkillName("xj_dunshi")
			room:useCard(sgs.CardUseStruct(analeptic, source, source, false))
			--[[elseif choice == "cancel" then
			if who or pattern == "slash" then
				room:setPlayerFlag(source, "xj_dunshiUsed") --原本是为了防止只要一直点取消可以无限点击按钮，但后来想想要是当前回合还需要用到“遁世”呢？
			end]]
		end
	end,
}
xj_dunshi = sgs.CreateZeroCardViewAsSkill {
	name = "xj_dunshi",
	view_as = function()
		return xj_dunshiCard:clone()
	end,
	enabled_at_play = function(self, player)
		if player:hasFlag("xj_dunshiUsed") then return false end
		return (player:isWounded() or sgs.Slash_IsAvailable(player) or sgs.Analeptic_IsAvailable(player))
			and
			not (player:getMark("xj_dunshiCantUseSlash") > 0 and player:getMark("xj_dunshiCantUsePeach") > 0 and player:getMark("xj_dunshiCantUseAnaleptic") > 0)
	end,
	enabled_at_response = function(self, player, pattern)
		if player:hasFlag("xj_dunshiUsed") then return false end
		return (pattern == "slash" and player:getMark("xj_dunshiCantUseSlash") == 0)
			or
			(string.find(pattern, "peach") and (player:getMark("Global_PreventPeach") == 0 and player:getMark("xj_dunshiCantUsePeach") == 0) or player:getMark("xj_dunshiCantUseAnaleptic") == 0)
			or (string.find(pattern, "analeptic") and player:getMark("xj_dunshiCantUseAnaleptic") == 0)
	end,
}
--“普通杀”技能卡
xj_dunshiNormalSlashCard = sgs.CreateSkillCard {
	name = "xj_dunshiNormalSlashCard",
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return sgs.Self:canSlash(to_select, nil)
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("xj_dunshi")
		local use = sgs.CardUseStruct()
		use.card = slash
		use.from = source
		for _, p in pairs(targets) do
			use.to:append(p)
		end
		room:useCard(use)
		room:addPlayerHistory(source, use.card:getClassName())
	end,
}
xj_dunshiNormalSlash = sgs.CreateZeroCardViewAsSkill {
	name = "xj_dunshiNormalSlash",
	view_as = function()
		return xj_dunshiNormalSlashCard:clone()
	end,
	enabled_at_play = function()
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@xj_dunshiNormalSlash"
	end,
}
----
xj_dunshiTrigger = sgs.CreateTriggerSkill { --杀/闪响应
	name = "xj_dunshiTrigger",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.CardAsked },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local pattern = data:toStringList()[1]
		local current = room:getCurrent()
		if (pattern == "slash" or pattern == "jink") then
			if pattern == "slash" and player:getMark("xj_dunshiCantUseSlash") == 0 then
				if not room:askForSkillInvoke(player, "xj_dunshi", data) then return false end
				room:setPlayerFlag(player, "xj_dunshiUsed")
				room:setPlayerFlag(current, "xj_dunshiBeingInvoke")
				local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				slash:setSkillName("xj_dunshi")
				room:provide(slash)
				room:broadcastSkillInvoke("xj_dunshi")
			elseif pattern == "jink" and player:getMark("xj_dunshiCantUseJink") == 0 then
				if not room:askForSkillInvoke(player, "xj_dunshi", data) then return false end
				room:setPlayerFlag(player, "xj_dunshiUsed")
				room:setPlayerFlag(current, "xj_dunshiBeingInvoke")
				local jink = sgs.Sanguosha:cloneCard("jink", sgs.Card_NoSuit, 0)
				jink:setSkillName("xj_dunshi")
				room:provide(jink)
				room:broadcastSkillInvoke("xj_dunshi")
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("xj_dunshi") and not player:hasFlag("xj_dunshiUsed")
	end,
}
xj_dunshii = sgs.CreateTriggerSkill {
	name = "xj_dunshii",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.DamageCaused, sgs.PreCardUsed, sgs.CardResponded, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DamageCaused then
			local damage = data:toDamage()
			if damage.from:objectName() ~= player:objectName() or not player:hasFlag("xj_dunshiBeingInvoke") then return false end
			room:setPlayerFlag(player, "-xj_dunshiBeingInvoke")
			for _, gn in sgs.qlist(room:findPlayersBySkillName("xj_dunshi")) do
				if gn:hasFlag("xj_dunshiUsed") then
					room:broadcastSkillInvoke("xj_dunshi")
					while gn:getMark("xj_dunshiChoice") < 2 do
						local choices = {}
						if not gn:hasFlag("xj_dunshi_AddSkillChoiced") and not (player:hasSkill("tenyearrende")
								and player:hasSkill("renxin") and player:hasSkill("renzheng") and player:hasSkill("yicong")
								and player:hasSkill("tenyearyijue") and player:hasSkill("yishe") and player:hasSkill("tenyearyixiang")
								and player:hasSkill("juyi") and player:hasSkill("tianyi") and player:hasSkill("lilu")
								and player:hasSkill("tenyearlixia") and player:hasSkill("weili") and player:hasSkill("zhichi")
								and player:hasSkill("zhiyu") and player:hasSkill("tenyearjizhi") and player:hasSkill("spqianxin")
								and player:hasSkill("tongli") and player:hasSkill("chongyi")) then
							table.insert(choices, "1=" .. player:objectName())
						end
						if not gn:hasFlag("xj_dunshi_LoseMaxHpChoiced") then
							table.insert(choices, "2")
						end
						if not (gn:getMark("xj_dunshiCantUseSlash") > 0 and gn:getMark("xj_dunshiCantUseJink") > 0
								and gn:getMark("xj_dunshiCantUsePeach") > 0 and gn:getMark("xj_dunshiCantUseAnaleptic") > 0)
							and not gn:hasFlag("xj_dunshi_DeleteCardChoiced") then
							if gn:hasFlag("xj_dunshiUseSlash") and gn:getMark("xj_dunshiCantUseSlash") == 0 then
								table.insert(choices, "3_Slash")
							elseif gn:hasFlag("xj_dunshiUseJink") and gn:getMark("xj_dunshiCantUseJink") == 0 then
								table.insert(choices, "3_Jink")
							elseif gn:hasFlag("xj_dunshiUsePeach") and gn:getMark("xj_dunshiCantUsePeach") == 0 then
								table.insert(choices, "3_Peach")
							elseif gn:hasFlag("xj_dunshiUseAnaleptic") and gn:getMark("xj_dunshiCantUseAnaleptic") == 0 then
								table.insert(choices, "3_Analeptic")
							end
						end
						local choice = room:askForChoice(gn, "xj_dunshi", table.concat(choices, "+"))
						if choice == "1=" .. player:objectName() then
							room:setPlayerFlag(gn, "xj_dunshi_AddSkillChoiced")
							room:addPlayerMark(gn, "xj_dunshiChoice")
							local choicess = {}
							--仁（界仁德、仁心、仁政）
							local choicess_ren = {}
							if not player:hasSkill("tenyearrende") then
								table.insert(choicess_ren, "tenyearrende")
							end
							if not player:hasSkill("renxin") then
								table.insert(choicess_ren, "renxin")
							end
							if not player:hasSkill("renzheng") then
								table.insert(choicess_ren, "renzheng")
							end
							if #choicess_ren > 0 then
								local choicee_ren = choicess_ren[math.random(1, #choicess_ren)]
								table.insert(choicess, choicee_ren)
							end
							--义（义从、界义绝、义舍、义襄-十周年、举义、天义、崇义）
							local choicess_yi = {}
							if not player:hasSkill("yicong") then
								table.insert(choicess_yi, "yicong")
							end
							if not player:hasSkill("tenyearyijue") then
								table.insert(choicess_yi, "tenyearyijue")
							end
							if not player:hasSkill("yishe") then
								table.insert(choicess_yi, "yishe")
							end
							if not player:hasSkill("tenyearyixiang") then
								table.insert(choicess_yi, "tenyearyixiang")
							end
							if not player:hasSkill("juyi") then
								table.insert(choicess_yi, "juyi")
							end
							if not player:hasSkill("tianyi") then
								table.insert(choicess_yi, "tianyi")
							end
							if not player:hasSkill("chongyi") then
								table.insert(choicess_yi, "chongyi")
							end
							if #choicess_yi > 0 then
								local choicee_yi = choicess_yi[math.random(1, #choicess_yi)]
								table.insert(choicess, choicee_yi)
							end
							--礼（礼赂、界礼下、遗礼、同礼）
							local choicess_li = {}
							if not player:hasSkill("lilu") then
								table.insert(choicess_li, "lilu")
							end
							if not player:hasSkill("tenyearlixia") then
								table.insert(choicess_li, "tenyearlixia")
							end
							if not player:hasSkill("weili") then
								table.insert(choicess_li, "weili")
							end
							if not player:hasSkill("tongli") then
								table.insert(choicess_li, "tongli")
							end
							if #choicess_li > 0 then
								local choicee_li = choicess_li[math.random(1, #choicess_li)]
								table.insert(choicess, choicee_li)
							end
							--智（智迟、智愚、界集智）
							local choicess_zhi = {}
							if not player:hasSkill("zhichi") then
								table.insert(choicess_zhi, "zhichi")
							end
							if not player:hasSkill("zhiyu") then
								table.insert(choicess_zhi, "zhiyu")
							end
							if not player:hasSkill("tenyearjizhi") then
								table.insert(choicess_zhi, "tenyearjizhi")
							end
							if #choicess_zhi > 0 then
								local choicee_zhi = choicess_zhi[math.random(1, #choicess_zhi)]
								table.insert(choicess, choicee_zhi)
							end
							--信（遣信）
							local choicess_xin = {}
							if not player:hasSkill("spqianxin") then
								table.insert(choicess_xin, "spqianxin")
							end
							if #choicess_xin > 0 then
								local choicee_xin = choicess_xin[math.random(1, #choicess_xin)]
								table.insert(choicess, choicee_xin)
							end
							local choicee = room:askForChoice(gn, "xj_dunshi", table.concat(choicess, "+"))
							room:broadcastSkillInvoke("xj_dunshi")
							if choicee == "tenyearrende" and not player:hasSkill("tenyearrende") then
								room:acquireSkill(player, "tenyearrende")
							elseif choicee == "renxin" and not player:hasSkill("renxin") then
								room:acquireSkill(player, "renxin")
							elseif choicee == "renzheng" and not player:hasSkill("renzheng") then
								room:acquireSkill(player, "renzheng")
							elseif choicee == "yicong" and not player:hasSkill("yicong") then
								room:acquireSkill(player, "yicong")
							elseif choicee == "tenyearyijue" and not player:hasSkill("tenyearyijue") then
								room:acquireSkill(player, "tenyearyijue")
							elseif choicee == "yishe" and not player:hasSkill("yishe") then
								room:acquireSkill(player, "yishe")
							elseif choicee == "tenyearyixiang" and not player:hasSkill("tenyearyixiang") then
								room:acquireSkill(player, "tenyearyixiang")
							elseif choicee == "juyi" and not player:hasSkill("juyi") then
								room:acquireSkill(player, "juyi")
							elseif choicee == "tianyi" and not player:hasSkill("tianyi") then
								room:acquireSkill(player, "tianyi")
							elseif choicee == "lilu" and not player:hasSkill("lilu") then
								room:acquireSkill(player, "lilu")
							elseif choicee == "tenyearlixia" and not player:hasSkill("tenyearlixia") then
								room:acquireSkill(player, "tenyearlixia")
							elseif choicee == "weili" and not player:hasSkill("weili") then
								room:acquireSkill(player, "weili")
							elseif choicee == "zhichi" and not player:hasSkill("zhichi") then
								room:acquireSkill(player, "zhichi")
							elseif choicee == "zhiyu" and not player:hasSkill("zhiyu") then
								room:acquireSkill(player, "zhiyu")
							elseif choicee == "tenyearjizhi" and not player:hasSkill("tenyearjizhi") then
								room:acquireSkill(player, "tenyearjizhi")
							elseif choicee == "spqianxin" and not player:hasSkill("spqianxin") then
								room:acquireSkill(player, "spqianxin")
							elseif choicee == "tongli" and not player:hasSkill("tongli") then
								room:acquireSkill(player, "tongli")
							elseif choicee == "chongyi" and not player:hasSkill("chongyi") then
								room:acquireSkill(player, "chongyi")
							end
							----
							if gn:getMark("xj_dunshiChoice") < 2 then
								table.removeOne(choices, "1=" .. player:objectName())
								local choicex = room:askForChoice(gn, "xj_dunshi", table.concat(choices, "+"))
								if choicex == "2" then
									room:setPlayerFlag(gn, "xj_dunshi_LoseMaxHpChoiced")
									room:addPlayerMark(gn, "xj_dunshiChoice")
									room:loseMaxHp(gn, 1)
									local n = gn:getMark("xj_dunshi_choose3")
									if n > 0 then
										room:drawCards(gn, n, self:objectName())
									end
									room:broadcastSkillInvoke("xj_dunshi")
								elseif choicex == "3_Slash" then
									room:setPlayerFlag(gn, "xj_dunshi_DeleteCardChoiced")
									room:addPlayerMark(gn, "xj_dunshiChoice")
									room:broadcastSkillInvoke("xj_dunshi")
									room:addPlayerMark(gn, "xj_dunshiCantUseSlash")
									room:addPlayerMark(gn, "xj_dunshi_choose3")
									local log = sgs.LogMessage()
									log.type = "$xj_dunshiDeleteSlash"
									log.from = gn
									room:sendLog(log)
								elseif choicex == "3_Jink" then
									room:setPlayerFlag(gn, "xj_dunshi_DeleteCardChoiced")
									room:addPlayerMark(gn, "xj_dunshiChoice")
									room:broadcastSkillInvoke("xj_dunshi")
									room:addPlayerMark(gn, "xj_dunshiCantUseJink")
									room:addPlayerMark(gn, "xj_dunshi_choose3")
									local log = sgs.LogMessage()
									log.type = "$xj_dunshiDeleteJink"
									log.from = gn
									room:sendLog(log)
								elseif choicex == "3_Peach" then
									room:setPlayerFlag(gn, "xj_dunshi_DeleteCardChoiced")
									room:addPlayerMark(gn, "xj_dunshiChoice")
									room:broadcastSkillInvoke("xj_dunshi")
									room:addPlayerMark(gn, "xj_dunshiCantUsePeach")
									room:addPlayerMark(gn, "xj_dunshi_choose3")
									local log = sgs.LogMessage()
									log.type = "$xj_dunshiDeletePeach"
									log.from = gn
									room:sendLog(log)
								elseif choicex == "3_Analeptic" then
									room:setPlayerFlag(gn, "xj_dunshi_DeleteCardChoiced")
									room:addPlayerMark(gn, "xj_dunshiChoice")
									room:broadcastSkillInvoke("xj_dunshi")
									room:addPlayerMark(gn, "xj_dunshiCantUseAnaleptic")
									room:addPlayerMark(gn, "xj_dunshi_choose3")
									local log = sgs.LogMessage()
									log.type = "$xj_dunshiDeleteAnaleptic"
									log.from = gn
									room:sendLog(log)
								end
							end
							room:setPlayerFlag(gn, "-xj_dunshi_AddSkillChoiced")
							room:setPlayerFlag(gn, "-xj_dunshi_LoseMaxHpChoiced")
							room:setPlayerFlag(gn, "-xj_dunshi_DeleteCardChoiced")
							room:setPlayerMark(gn, "xj_dunshiChoice", 0)
							----
							return true --因此代码会返回一切，故如若还要做一次选项则需补一次选择，并及时清除标记
						elseif choice == "2" then
							room:setPlayerFlag(gn, "xj_dunshi_LoseMaxHpChoiced")
							room:addPlayerMark(gn, "xj_dunshiChoice")
							room:loseMaxHp(gn, 1)
							local n = gn:getMark("xj_dunshi_choose3")
							if n > 0 then
								room:drawCards(gn, n, self:objectName())
							end
							room:broadcastSkillInvoke("xj_dunshi")
						elseif choice == "3_Slash" then
							room:setPlayerFlag(gn, "xj_dunshi_DeleteCardChoiced")
							room:addPlayerMark(gn, "xj_dunshiChoice")
							room:broadcastSkillInvoke("xj_dunshi")
							room:addPlayerMark(gn, "xj_dunshiCantUseSlash")
							room:addPlayerMark(gn, "xj_dunshi_choose3")
							local log = sgs.LogMessage()
							log.type = "$xj_dunshiDeleteSlash"
							log.from = gn
							room:sendLog(log)
						elseif choice == "3_Jink" then
							room:setPlayerFlag(gn, "xj_dunshi_DeleteCardChoiced")
							room:addPlayerMark(gn, "xj_dunshiChoice")
							room:broadcastSkillInvoke("xj_dunshi")
							room:addPlayerMark(gn, "xj_dunshiCantUseJink")
							room:addPlayerMark(gn, "xj_dunshi_choose3")
							local log = sgs.LogMessage()
							log.type = "$xj_dunshiDeleteJink"
							log.from = gn
							room:sendLog(log)
						elseif choice == "3_Peach" then
							room:setPlayerFlag(gn, "xj_dunshi_DeleteCardChoiced")
							room:addPlayerMark(gn, "xj_dunshiChoice")
							room:broadcastSkillInvoke("xj_dunshi")
							room:addPlayerMark(gn, "xj_dunshiCantUsePeach")
							room:addPlayerMark(gn, "xj_dunshi_choose3")
							local log = sgs.LogMessage()
							log.type = "$xj_dunshiDeletePeach"
							log.from = gn
							room:sendLog(log)
						elseif choice == "3_Analeptic" then
							room:setPlayerFlag(gn, "xj_dunshi_DeleteCardChoiced")
							room:addPlayerMark(gn, "xj_dunshiChoice")
							room:broadcastSkillInvoke("xj_dunshi")
							room:addPlayerMark(gn, "xj_dunshiCantUseAnaleptic")
							room:addPlayerMark(gn, "xj_dunshi_choose3")
							local log = sgs.LogMessage()
							log.type = "$xj_dunshiDeleteAnaleptic"
							log.from = gn
							room:sendLog(log)
						end
					end
					room:setPlayerFlag(gn, "-xj_dunshi_AddSkillChoiced")
					room:setPlayerFlag(gn, "-xj_dunshi_LoseMaxHpChoiced")
					room:setPlayerFlag(gn, "-xj_dunshi_DeleteCardChoiced")
					room:setPlayerMark(gn, "xj_dunshiChoice", 0)
				end
			end
		elseif event == sgs.PreCardUsed or event == sgs.CardResponded then
			local card
			if event == sgs.PreCardUsed then
				card = data:toCardUse().card
			else
				card = data:toCardResponse().m_card
			end
			if card and card:getSkillName() == "xj_dunshi" then
				if card:isKindOf("Slash") then
					room:setPlayerFlag(player, "xj_dunshiUseSlash")
				elseif card:isKindOf("Jink") then
					room:setPlayerFlag(player, "xj_dunshiUseJink")
				elseif card:isKindOf("Peach") then
					room:setPlayerFlag(player, "xj_dunshiUsePeach")
				elseif card:isKindOf("Analeptic") then
					room:setPlayerFlag(player, "xj_dunshiUseAnaleptic")
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("xj_dunshiUsed") then
					room:setPlayerFlag(p, "-xj_dunshiUsed")
				end
				if p:hasFlag("xj_dunshiBeingInvoke") then
					room:setPlayerFlag(p, "-xj_dunshiBeingInvoke")
				end
				if p:hasFlag("xj_dunshiUseSlash") then
					room:setPlayerFlag(p, "-xj_dunshiUseSlash")
				end
				if p:hasFlag("xj_dunshiUseJink") then
					room:setPlayerFlag(p, "-xj_dunshiUseJink")
				end
				if p:hasFlag("xj_dunshiUsePeach") then
					room:setPlayerFlag(p, "-xj_dunshiUsePeach")
				end
				if p:hasFlag("xj_dunshiUseAnaleptic") then
					room:setPlayerFlag(p, "-xj_dunshiUseAnaleptic")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
xj_guanning:addSkill(xj_dunshi)
--local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("xj_dunshiNormalSlash") then skills:append(xj_dunshiNormalSlash) end
if not sgs.Sanguosha:getSkill("xj_dunshiTrigger") then skills:append(xj_dunshiTrigger) end
if not sgs.Sanguosha:getSkill("xj_dunshii") then skills:append(xj_dunshii) end
---“遁世”技能池---
--“仁”
xj_guanning:addRelateSkill("tenyearrende") --界仁德
xj_guanning:addRelateSkill("renxin")       --仁心
--“仁政”
lt_renzhengBefore = sgs.CreateTriggerSkill {
	name = "lt_renzhengBefore",
	global = true,
	priority = 100,            --确保最高优先级，记录伤害
	frequency = sgs.Skill_Compulsory,
	events = { sgs.DamageForseen }, --可算是找到了一个合适的时机
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local lt = room:findPlayerBySkillName("lt_renzheng")
		if not lt then return false end
		room:setPlayerMark(damage.to, "renzhengDMGget", damage.damage) --将记录本应造成伤害值的标记给受到伤害者，以应对无伤害来源的情况
	end,
	can_trigger = function(self, player)
		return true --这里不能return player，因为伤害可能无来源
	end,
}
lt_renzheng = sgs.CreateTriggerSkill {
	name = "lt_renzheng",
	global = true,
	priority = -100, --确保最低优先级，计算伤害
	frequency = sgs.Skill_Compulsory,
	events = { sgs.DamageInflicted, sgs.DamageComplete },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local lt = room:findPlayerBySkillName("lt_renzheng")
		if not lt or damage.to:objectName() ~= player:objectName() then return false end
		if event == sgs.DamageInflicted then --伤害被减少
			local n = player:getMark("renzhengDMGget")
			if n < damage.damage then
				room:removePlayerMark(player, "renzhengDMGget", n)
			else
				room:removePlayerMark(player, "renzhengDMGget", damage.damage)
			end
			if player:getMark("renzhengDMGget") > 0 then --还有此标记，即标记没清干净，证明此时伤害已经没有准备确定时多了
				for _, lts in sgs.qlist(room:findPlayersBySkillName("lt_renzheng")) do
					room:sendCompulsoryTriggerLog(lts, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:drawCards(lts, 2, self:objectName())
				end
				room:setPlayerMark(player, "renzhengDMGget", 0)
			end
		elseif event == sgs.DamageComplete then --伤害被防止
			if player:getMark("renzhengDMGget") > 0 then
				for _, lts in sgs.qlist(room:findPlayersBySkillName("lt_renzheng")) do
					room:sendCompulsoryTriggerLog(lts, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:drawCards(lts, 2, self:objectName())
				end
				room:setPlayerMark(player, "renzhengDMGget", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("lt_renzheng") then skills:append(lt_renzheng) end
if not sgs.Sanguosha:getSkill("lt_renzhengBefore") then skills:append(lt_renzhengBefore) end
--xj_guanning:addRelateSkill("lt_renzheng")
----
xj_guanning:addRelateSkill("renzheng") --仁政
--xj_guanning:addRelateSkill("")
--......
--“义”
xj_guanning:addRelateSkill("yicong")         --义从
xj_guanning:addRelateSkill("tenyearyijue")   --界义绝
xj_guanning:addRelateSkill("yishe")          --义舍
xj_guanning:addRelateSkill("tenyearyixiang") --义襄-十周年
xj_guanning:addRelateSkill("juyi")           --举义
xj_guanning:addRelateSkill("tianyi")         --天义
xj_guanning:addRelateSkill("chongyi")        --崇义
--xj_guanning:addRelateSkill("")
--......
--“礼”
xj_guanning:addRelateSkill("lilu")         --礼赂
xj_guanning:addRelateSkill("tenyearlixia") --界礼下
xj_guanning:addRelateSkill("weili")        --遗礼
xj_guanning:addRelateSkill("tongli")       --同礼
--xj_guanning:addRelateSkill("")
--......
--“智”
xj_guanning:addRelateSkill("zhichi")       --智迟
xj_guanning:addRelateSkill("zhiyu")        --智愚
xj_guanning:addRelateSkill("tenyearjizhi") --界集智
--xj_guanning:addRelateSkill("")
--......
--“信”
xj_guanning:addRelateSkill("spqianxin") --遣信
--xj_guanning:addRelateSkill("")
--......


------------------

sgs.LoadTranslationTable {
	--["XJacgn"] = "仙界武将-管宁",
	----
	["xj_guanning"] = "管宁",
	["#xj_guanning"] = "永世玄武",
	["designer:xj_guanning"] = "官方(十周年)",
	["cv:xj_guanning"] = "官方",
	["illustrator:xj_guanning"] = "游漫美绘",
	--遁世
	["xj_dunshi"] = "遁世",
	["xj_dunshiNormalSlash"] = "遁世",
	["xj_dunshinormalslash"] = "遁世",
	["xj_dunshiTrigger"] = "遁世",
	["xj_dunshii"] = "遁世",
	[":xj_dunshi"] = "每个回合限一次，你可视为使用或打出一张普通【杀】、【闪】、【桃】或【酒】。然后当前回合角色本回合下次造成伤害时，你选择两项：\
	1.防止此伤害，选择1个包含“仁/义/礼/智/信”的技能(技能池:三国杀十周年2022年12月)令其获得<font color='red'><b>（从[仁/义/礼/智/信]中各随机抽取一个其未拥有的技能供选择）</b></font>；\
	2.减1点体力上限并摸X张牌（X为你选择3的次数）；\
	3.删除你本次视为使用的牌名。",
	["cancel"] = "取消",
	["@xj_dunshiNormalSlash"] = "你可以视为使用一张【杀】",
	["~xj_dunshiNormalSlash"] = "选择目标角色，点【确定】",
	["xj_dunshiChoice"] = "",
	["xj_dunshi:1"] = "防止此伤害，选择1个包含“仁/义/礼/智/信”的技能令%src获得",
	["xj_dunshi:2"] = "减1点体力上限并根据你选择[删除牌名]的次数来摸牌",
	["xj_dunshi:3_Slash"] = "删除你本次视为使用的牌名：【杀】",
	["xj_dunshi:3_Jink"] = "删除你本次视为使用的牌名：【闪】",
	["xj_dunshi:3_Peach"] = "删除你本次视为使用的牌名：【桃】",
	["xj_dunshi:3_Analeptic"] = "删除你本次视为使用的牌名：【酒】",
	["xj_dunshi_choose3"] = "",
	["$xj_dunshiDeleteSlash"] = "%from <font color='red'>删除</font>了通过“<font color='yellow'><b>遁世</b></font>”可视为使用或打出的牌：【<font color='yellow'><b>杀</b></font>】",
	["$xj_dunshiDeleteJink"] = "%from <font color='red'>删除</font>了通过“<font color='yellow'><b>遁世</b></font>”可视为使用或打出的牌：【<font color='yellow'><b>闪</b></font>】",
	["$xj_dunshiDeletePeach"] = "%from <font color='red'>删除</font>了通过“<font color='yellow'><b>遁世</b></font>”可视为使用或打出的牌：【<font color='yellow'><b>桃</b></font>】",
	["$xj_dunshiDeleteAnaleptic"] = "%from <font color='red'>删除</font>了通过“<font color='yellow'><b>遁世</b></font>”可视为使用或打出的牌：【<font color='yellow'><b>酒</b></font>】",
	["$xj_dunshi1"] = "失路青山隐，藏名白水游。",
	["$xj_dunshi2"] = "隐居青松畔，遁走孤竹丘。",
	--新杀骆统技能：仁政（20221231版已写有，故不再采用）
	["lt_renzheng"] = "仁政",
	["lt_renzhengBefore"] = "仁政",
	[":lt_renzheng"] = "锁定技，当有伤害被减少或防止时，你摸两张牌。",
	["renzhengDMGget"] = "",
	--阵亡
	["~xj_guanning"] = "高节始终，无憾矣......",
}

--XJ04 新杀-周宣
xj_zhouxuan = sgs.General(extension, "xj_zhouxuan", "wei", 3, true)

xj_wumei = sgs.CreateTriggerSkill {
	name = "xj_wumei",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.RoundStart, sgs.TurnStart, sgs.EventPhaseChanging, sgs.Death },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.RoundStart then
			room:setPlayerMark(player, "xj_wumeiUsed", 0)
		elseif event == sgs.TurnStart then
			if player:getMark("xj_wumeiUsed") > 0 or not player:hasSkill(self:objectName()) then return false end
			if not room:askForSkillInvoke(player, self:objectName(), data) then return false end
			room:addPlayerMark(player, "xj_wumeiUsed")
			local caopi = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName(), "@xj_wumei-to")
			for _, p in sgs.qlist(room:getAllPlayers()) do
				local hp = p:getHp()
				room:setPlayerMark(p, "&xj_wumei", hp)
			end
			room:broadcastSkillInvoke(self:objectName())
			if not caopi:hasFlag(self:objectName()) then
				room:setPlayerFlag(caopi, self:objectName())
			end
			caopi:gainAnExtraTurn()
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive or not player:hasFlag(self:objectName()) then return false end
			room:setPlayerFlag(player, "-xj_wumei")
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				local hp = p:getMark("&xj_wumei")
				if hp > 0 then
					room:setPlayerMark(p, "&xj_wumei", 0)
					room:setPlayerProperty(p, "hp", sgs.QVariant(hp))
				end
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() == player:objectName() and player:hasSkill(self:objectName()) then
				local ozx = room:findPlayerBySkillName(self:objectName())
				if ozx then return false end
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					local hp = p:getMark("&xj_wumei")
					if hp > 0 then
						room:setPlayerMark(p, "&xj_wumei", 0)
						--room:setPlayerProperty(p, "hp", sgs.QVariant(hp))
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
xj_zhouxuan:addSkill(xj_wumei)

xj_zhanmeng = sgs.CreateTriggerSkill {
	name = "xj_zhanmeng",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.CardUsed, sgs.CardResponded, sgs.EventPhaseChanging, sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed or event == sgs.CardResponded then
			local card = nil
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and card:getHandlingMethod() == sgs.Card_MethodUse then
				local name = card:objectName()
				--1.记录牌
				local names = player:property("xj_zhanmengLastRecord"):toString():split("+")
				if not table.contains(names, name) and player:hasSkill(self:objectName()) then
					table.insert(names, name)
					room:setPlayerProperty(player, "xj_zhanmengLastRecord", sgs.QVariant(table.concat(names, "+"))) --记录牌，然后回合结束时统一存档用于下回合选项1检索
				end
				--2.看能否触发选项2的收益
				for _, zx in sgs.qlist(room:getAllPlayers()) do
					if zx:hasSkill(self:objectName()) and zx:getMark("&xj_zhanmeng+" .. name) > 0 then --记录着上回合通过选项2记录的牌的文字标记
						room:setPlayerMark(zx, "&xj_zhanmeng+" .. name, 0)
						local xj_zhanmengTwo_cards = {}
						local xj_zhanmengTwo_one_count = 0
						for _, id in sgs.qlist(room:getDrawPile()) do
							if sgs.Sanguosha:getCard(id):isDamageCard() and not table.contains(xj_zhanmengTwo_cards, id) and xj_zhanmengTwo_one_count < 1 then
								xj_zhanmengTwo_one_count = xj_zhanmengTwo_one_count + 1
								table.insert(xj_zhanmengTwo_cards, id)
							end
						end
						local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
						for _, id in ipairs(xj_zhanmengTwo_cards) do
							dummy:addSubcard(id)
						end
						room:sendCompulsoryTriggerLog(zx, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						room:obtainCard(zx, dummy, false)
					end
				end
				--3.发动技能选择
				if not player:hasSkill(self:objectName()) then return false end
				if player:getMark("xj_zhanmengOne") > 0 and player:getMark("xj_zhanmengTwo") > 0 and player:getMark("xj_zhanmengThree") > 0 then return false end
				if not room:askForSkillInvoke(player, self:objectName(), data) then return false end
				local nemes = player:property("xj_zhanmengDataRecord"):toString():split("+") --上回合使用牌的存档
				local choices = {}
				if not table.contains(nemes, name) and player:getMark("xj_zhanmengOne") == 0 then
					table.insert(choices, "1")
				end
				if player:getMark("xj_zhanmengTwo") == 0 then
					table.insert(choices, "2")
				end
				if player:getMark("xj_zhanmengThree") == 0 then
					table.insert(choices, "3")
				end
				table.insert(choices, "cancel")
				local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
				room:broadcastSkillInvoke(self:objectName())
				if choice == "1" then
					room:addPlayerMark(player, "xj_zhanmengOne")
					local xj_zhanmengOne_cards = {}
					local xj_zhanmengOne_one_count = 0
					for _, id in sgs.qlist(room:getDrawPile()) do
						if not sgs.Sanguosha:getCard(id):isDamageCard() and not table.contains(xj_zhanmengOne_cards, id) and xj_zhanmengOne_one_count < 1 then
							xj_zhanmengOne_one_count = xj_zhanmengOne_one_count + 1
							table.insert(xj_zhanmengOne_cards, id)
						end
					end
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					for _, id in ipairs(xj_zhanmengOne_cards) do
						dummy:addSubcard(id)
					end
					room:obtainCard(player, dummy, false)
				elseif choice == "2" then
					room:addPlayerMark(player, "xj_zhanmengTwo")
					room:addPlayerMark(player, "xj_zhanmeng+" .. name) --通过标记记录此牌名，然后下回合开始时转录成文字标记用于下回合选项2触发
				elseif choice == "3" then
					room:addPlayerMark(player, "xj_zhanmengThree")
					local emeng = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName())
					if not emeng:isNude() then
						local em_cards = room:askForDiscard(emeng, self:objectName(), 2, 2, false, true)
						if em_cards then
							local num = 0
							--[[local n = sgs.Sanguosha:getCard(em_cards:getSubcards():at(0)):getNumber()
							if em_cards:getSubcards():length() > 1 then
								local m = sgs.Sanguosha:getCard(em_cards:getSubcards():at(1)):getNumber()
							end
							num = n + m]]
							for _, c in sgs.qlist(em_cards:getSubcards()) do
								local cd = sgs.Sanguosha:getCard(c)
								local n = cd:getNumber()
								num = num + n
							end
							if num > 10 then
								room:damage(sgs.DamageStruct(self:objectName(), player, emeng, 1, sgs.DamageStruct_Fire))
							end
						end
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, zx in sgs.qlist(room:getAllPlayers()) do
				--==选项1==--
				local names = zx:property("xj_zhanmengLastRecord"):toString():split("+") --读取当回合记录
				local nemes = zx:property("xj_zhanmengDataRecord"):toString():split("+") --读取每回合存档
				--1.清空旧存档
				local record1, cards1 = sgs.IntList(), {}
				for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
					local c = sgs.Sanguosha:getEngineCard(id)
					if table.contains(cards1, c:objectName()) then continue end
					table.insert(cards1, c:objectName())
					if table.contains(nemes, c:objectName()) then
						record1:append(id)
					end
				end
				if not record1:isEmpty() then
					for _, rid in sgs.qlist(record1) do
						local name1 = sgs.Sanguosha:getEngineCard(rid):objectName()
						table.removeOne(nemes, name1)
						room:setPlayerProperty(zx, "xj_zhanmengDataRecord", sgs.QVariant(table.concat(nemes, "+")))
					end
				end
				--2.更新新存档，同时清空当回合记录
				local record2, cards2 = sgs.IntList(), {}
				for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
					local c = sgs.Sanguosha:getEngineCard(id)
					if table.contains(cards2, c:objectName()) then continue end
					table.insert(cards2, c:objectName())
					if table.contains(names, c:objectName()) then
						record2:append(id)
					end
				end
				if not record2:isEmpty() then
					for _, rid in sgs.qlist(record2) do
						local name2 = sgs.Sanguosha:getEngineCard(rid):objectName()
						table.insert(nemes, name2)
						room:setPlayerProperty(zx, "xj_zhanmengDataRecord", sgs.QVariant(table.concat(nemes, "+")))
						table.removeOne(names, name2)
						room:setPlayerProperty(zx, "xj_zhanmengLastRecord", sgs.QVariant(table.concat(names, "+")))
					end
				end
				----
				--==选项2==--
				--清空当回合残余的文字标记，以保证有效期仅持续一回合
				for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
					local c = sgs.Sanguosha:getEngineCard(id)
					local cnm = c:objectName()
					room:setPlayerMark(zx, "&xj_zhanmeng+" .. cnm, 0)
				end
				----
				room:setPlayerMark(zx, "xj_zhanmengOne", 0)
				room:setPlayerMark(zx, "xj_zhanmengTwo", 0)
				room:setPlayerMark(zx, "xj_zhanmengThree", 0)
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_RoundStart then return false end
			for _, zx in sgs.qlist(room:getAllPlayers()) do
				for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
					local c = sgs.Sanguosha:getEngineCard(id)
					local cnm = c:objectName()
					if zx:getMark("xj_zhanmeng+" .. cnm) > 0 then
						room:setPlayerMark(zx, "xj_zhanmeng+" .. cnm, 0)
						room:addPlayerMark(zx, "&xj_zhanmeng+" .. cnm) --将上回合通过选项2记录牌的标记转录为文字标记
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
xj_zhouxuan:addSkill(xj_zhanmeng)

sgs.LoadTranslationTable {
	["xj_zhouxuan"] = "周宣",
	["#xj_zhouxuan"] = "大梦初醒",
	["designer:xj_zhouxuan"] = "官方(十周年)",
	["cv:xj_zhouxuan"] = "官方",
	["illustrator:xj_zhouxuan"] = "Thinking", --皮肤：玄占幻卜
	--寤寐
	["xj_wumei"] = "寤寐",
	[":xj_wumei"] = "每轮限一次，回合开始前，你可以令一名角色执行一个额外的回合：该回合结束时，将所有存活角色的体力值调整为此额外回合开始时的数值。",
	["xj_wumeiUsed"] = "寤寐",
	["@xj_wumei-to"] = "请选择一名“寤寐”目标，其将执行一个额外的回合",
	["$xj_wumei1"] = "大梦三千如幻，所思方寸之间。",
	["$xj_wumei2"] = "身居南山之隅，梦拥九天星辰。",
	--占梦
	["xj_zhanmeng"] = "占梦",
	[":xj_zhanmeng"] = "你使用牌时，可以执行以下一项（每回合每项各限一次）：\
	1.上一回合内，若没有同名牌被使用，你获得一张非伤害牌；\
	2.下一回合内，当同名牌首次被使用后，你获得一张伤害牌。\
	3.令一名其他角色弃置两张牌<font color='red'><b>(若不足则全弃)</b></font>，若点数之和大于10，你对其造成1点火焰伤害。",
	["xj_zhanmeng:1"] = "获得一张非伤害牌(上一回合内没有与此牌同名的牌被使用)",
	["xj_zhanmeng:2"] = "下一回合内，当与此牌同名的牌首次被使用后，获得一张伤害牌",
	["xj_zhanmeng:3"] = "令一名其他角色弃置两张牌(若这两张牌点数之和大于10，你对其造成1点火焰伤害)",
	["xj_zhanmengOne"] = "",
	["xj_zhanmengTwo"] = "",
	["xj_zhanmengThree"] = "",
	["$xj_zhanmeng1"] = "此为国梦，非君家之事也。",
	["$xj_zhanmeng2"] = "梦刍狗吠，君欲得美食耳。",
	--阵亡
	["~xj_zhouxuan"] = "夜梦玉京，今可去兮......",
}

--XJ04.5（武庙诸葛亮）
--==武庙诸葛亮美化包==--
wmzgl_better = sgs.Package("wmzgl_better", sgs.Package_CardPack)

--1.皮肤更换
wmzgl_SkinChange = sgs.CreateTriggerSkill {
	name = "wmzgl_SkinChange",
	global = true,
	priority = 7,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.AfterDrawInitialCards },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getGeneralName() == "wumiao_zhugeliang" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "wumiao_zhugeliang_qg1x", false, true, false, false)
			if not player:hasSkill("wmzgl_SkinChange_Button") then room:attachSkillToPlayer(player,
					"wmzgl_SkinChange_Button") end
		end
		if player:getGeneral2Name() == "wumiao_zhugeliang" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "wumiao_zhugeliang_qg1x", false, true, true, false)
			if not player:hasSkill("wmzgl_SkinChange_Button") then room:attachSkillToPlayer(player,
					"wmzgl_SkinChange_Button") end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("wmzgl_SkinChange") then skills:append(wmzgl_SkinChange) end
-------
wumiao_zhugeliang_qg1x = sgs.General(extension, "wumiao_zhugeliang_qg1x", "shu", 7, true, true, true, 4)
wumiao_zhugeliang_qg1x:addSkill("myjincui")
wumiao_zhugeliang_qg1x:addSkill("qingshi")
wumiao_zhugeliang_qg1x:addSkill("zhizhe")
wumiao_zhugeliang_wake = sgs.General(extension, "wumiao_zhugeliang_wake", "shu", 7, true, true, true, 4)
wumiao_zhugeliang_wake:addSkill("myjincui")
wumiao_zhugeliang_wake:addSkill("qingshi")
wumiao_zhugeliang_wake:addSkill("zhizhe")
-------
wmzgl_SkinChange_ButtonCard = sgs.CreateSkillCard {
	name = "wmzgl_SkinChange_ButtonCard",
	target_fixed = true,
	on_use = function(self, room, player, targets)
		local mhp = player:getMaxHp()
		local hp = player:getHp()
		if player:getGeneralName() == "wumiao_zhugeliang" or player:getGeneralName() == "wumiao_zhugeliang_qg1x" then
			local n = player:getMark("@zhizheMark")
			local choice = room:askForChoice(player, self:objectName(), "wmyh+qgyx")
			if choice == "wmyh" then
				room:changeHero(player, "wumiao_zhugeliang", false, false, false, false)
			else
				room:changeHero(player, "wumiao_zhugeliang_qg1x", false, false, false, false)
			end
			room:setPlayerMark(player, "@zhizheMark", n)
		end
		if player:getGeneral2Name() == "wumiao_zhugeliang_qg1x" or player:getGeneral2Name() == "wumiao_zhugeliang_qg1x" then
			local n = player:getMark("@zhizheMark")
			local choice = room:askForChoice(player, self:objectName(), "wmyh+qgyx")
			if choice == "wmyh" then
				room:changeHero(player, "wumiao_zhugeliang", false, false, true, false)
			else
				room:changeHero(player, "wumiao_zhugeliang_qg1x", false, false, true, false)
			end
			room:setPlayerMark(player, "@zhizheMark", n)
		end
		if player:getMaxHp() ~= mhp then room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp)) end
		if player:getHp() ~= hp then room:setPlayerProperty(player, "hp", sgs.QVariant(hp)) end
	end,
}
wmzgl_SkinChange_Button = sgs.CreateZeroCardViewAsSkill {
	name = "wmzgl_SkinChange_Button&",
	view_as = function()
		return wmzgl_SkinChange_ButtonCard:clone()
	end,
}
if not sgs.Sanguosha:getSkill("wmzgl_SkinChange_Button") then skills:append(wmzgl_SkinChange_Button) end

--2.隐藏皮肤
wmzgl_hideskin = sgs.CreateTriggerSkill {
	name = "wmzgl_hideskin",
	global = true,
	priority = -7,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.EventPhaseEnd },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start and player:getHp() <= 1
			and not table.contains(sgs.Sanguosha:getBanPackages(), "wmzgl_better") then
			--sgs.Sanguosha:stopSystemAudioEffect()
			sgs.Sanguosha:playSystemAudioEffect("wm_zhugeliang_wake")
			room:doLightbox("$wmzglWake")
			local mhp = player:getMaxHp()
			local hp = player:getHp()
			if player:getGeneralName() == "wumiao_zhugeliang" or player:getGeneralName() == "wumiao_zhugeliang_qg1x" then
				local n = player:getMark("@zhizheMark")
				room:changeHero(player, "wumiao_zhugeliang_wake", false, false, false, false)
				room:setPlayerMark(player, "@zhizheMark", n)
			end
			if player:getGeneral2Name() == "wumiao_zhugeliang_qg1x" or player:getGeneral2Name() == "wumiao_zhugeliang_qg1x" then
				local n = player:getMark("@zhizheMark")
				room:changeHero(player, "wumiao_zhugeliang_wake", false, false, true, false)
				room:setPlayerMark(player, "@zhizheMark", n)
			end
			if player:getMaxHp() ~= mhp then room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp)) end
			if player:getHp() ~= hp then room:setPlayerProperty(player, "hp", sgs.QVariant(hp)) end
			if player:hasSkill("wmzgl_SkinChange_Button") then room:detachSkillFromPlayer(player,
					"wmzgl_SkinChange_Button", true) end
		end
	end,
	can_trigger = function(self, player)
		return player:getGeneralName() == "wumiao_zhugeliang" or player:getGeneral2Name() == "wumiao_zhugeliang"
			or player:getGeneralName() == "wumiao_zhugeliang_qg1x" or
			player:getGeneral2Name() == "wumiao_zhugeliang_qg1x"
	end,
}
if not sgs.Sanguosha:getSkill("wmzgl_hideskin") then skills:append(wmzgl_hideskin) end

--==3.专属锦囊：鞠躬尽瘁==--
WmJugongjincui = sgs.CreateTrickCard {
	name = "_wm_jugongjincui",
	class_name = "WmJugongjincui",
	target_fixed = true,
	can_recast = false,
	available = true,
	is_cancelable = false, --不可被无懈
	damage_card = false,
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	on_use = function(self, room, source, targets)
		room:addPlayerMark(source, "&WmJugongjincui") --效果启动开关
	end,
}
for i = 0, 0, 1 do
	local card = WmJugongjincui:clone()
	card:setSuit(3)
	card:setNumber(i + 1)
	card:setParent(wmzgl_better)
end
for i = 0, 0, 1 do
	local card = WmJugongjincui:clone()
	card:setSuit(2)
	card:setNumber(i + 13)
	card:setParent(wmzgl_better)
end
WmJugongjincuiBuff = sgs.CreateTriggerSkill {
	name = "WmJugongjincuiBuff",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.EventPhaseChanging, sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_Start or change.to == sgs.Player_Judge or change.to == sgs.Player_Draw
				or change.to == sgs.Player_Discard or change.to == sgs.Player_Finish then
				if player:getMark("WmJugongjincui") == 0 then return false end
				player:setPhase(sgs.Player_Play)
				room:broadcastProperty(player, "phase")
				local thread = room:getThread()
				if not thread:trigger(sgs.EventPhaseStart, room, player) then
					thread:trigger(sgs.EventPhaseProceeding, room, player)
				end
				thread:trigger(sgs.EventPhaseEnd, room, player)
				player:setPhase(sgs.Player_Play)
				room:broadcastProperty(player, "phase")
				if not (change.to == sgs.Player_Start and player:isSkipped(sgs.Player_Start))
					and not (change.to == sgs.Player_Judge and player:isSkipped(sgs.Player_Judge))
					and not (change.to == sgs.Player_Draw and player:isSkipped(sgs.Player_Draw))
					and not (change.to == sgs.Player_Discard and player:isSkipped(sgs.Player_Discard))
					and not (change.to == sgs.Player_Finish and player:isSkipped(sgs.Player_Finish)) then
					player:skip(change.to)
				end
			elseif change.to == sgs.Player_NotActive then
				if player:getMark("WmJugongjincui") == 0 then
					room:setPlayerMark(player, "WmJugongjincui", 1) --控制效果发动
					player:gainAnExtraTurn()
				else
					room:removePlayerMark(player, "&WmJugongjincui")
					if player:getMark("&WmJugongjincui") == 0 then
						room:setPlayerMark(player, "WmJugongjincui", 0)
					else --得考虑叠加效果
						player:gainAnExtraTurn()
					end
				end
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart or player:getPhase() == sgs.Player_NotActive then return false end
			if player:getMark("WmJugongjincui") == 0 then return false end
			room:sendCompulsoryTriggerLog(player, "WmJugongjincui")
			if player:getHp() > 1 then
				room:loseHp(player, 1)
				room:drawCards(player, 1, "WmJugongjincui")
			else
				if not player:hasFlag("wmJGJC_end") then
					room:doLightbox("$wmJGJC")
					room:setPlayerFlag(player, "wmJGJC_end")
				end
				--强制终结此新回合
				room:setPlayerFlag(player, "Global_PlayPhaseTerminated")
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&WmJugongjincui") > 0
	end,
}
if not sgs.Sanguosha:getSkill("WmJugongjincuiBuff") then skills:append(WmJugongjincuiBuff) end

--==4.专属装备：出师表、八阵图、孔明灯、火兽、七星灯==--
--1.出师表
WmChushibiaos = sgs.CreateTriggerSkill {
	name = "WmChushibiao",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:removePlayerMark(player, "WmChushibiao")
				local n = player:getHp()
				if n > 6 then n = 6 end
				local card_ids = room:getNCards(n)
				room:fillAG(card_ids)
				local houzhu = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName())
				--(1)《出师表》对象收益
				local to_get = sgs.IntList()
				local to_use = sgs.IntList()
				while not card_ids:isEmpty() do
					local card_id = room:askForAG(houzhu, card_ids, false, self:objectName())
					card_ids:removeOne(card_id)
					to_get:append(card_id)
					local card = sgs.Sanguosha:getCard(card_id)
					local type = card:getTypeId()
					room:takeAG(houzhu, card_id, false)
					local _card_ids = card_ids
					for i = 0, 150 do
						for _, id in sgs.qlist(_card_ids) do
							local c = sgs.Sanguosha:getCard(id)
							if c:getTypeId() == type then
								card_ids:removeOne(id)
								room:takeAG(nil, id, false)
								to_use:append(id)
							end
						end
					end
				end
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				if not to_get:isEmpty() then
					dummy:addSubcards(getCardList(to_get))
					houzhu:obtainCard(dummy)
				end
				dummy:clearSubcards()
				room:clearAG()
				--(2)《出师表》作者输出
				while not to_use:isEmpty() do
					room:fillAG(to_use)
					local card_use = room:askForAG(player, to_use, false, self:objectName())
					to_use:removeOne(card_use)
					local uscard = sgs.Sanguosha:getCard(card_use)
					if uscard:isKindOf("Jink") or uscard:isKindOf("Nullification") or uscard:isKindOf("JlWuxiesy") then --不能主动使用的直接丢入弃牌堆
						room:throwCard(uscard, nil)
					else
						local pattern = {}
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							if not sgs.Sanguosha:isProhibited(player, p, uscard) and uscard:isAvailable(player) then
								table.insert(pattern, uscard:getEffectiveId())
							end
						end
						if #pattern > 0 then
							room:obtainCard(player, uscard)
							room:setPlayerFlag(player, "WmChushibiao_useNoLimit")
							local csb = room:askForUseCard(player, table.concat(pattern, ","),
								"@WmChushibiao_use:" .. uscard:objectName(), -1)
							if csb then
								if not player:hasFlag("WmChushibiao_anaNoLimit") then room:setPlayerFlag(player,
										"WmChushibiao_anaNoLimit") end                                                  --专门处理【酒】的不计次
							else
								room:throwCard(uscard, nil)
							end
							room:setPlayerFlag(player, "-WmChushibiao_useNoLimit")
						else
							room:throwCard(uscard, nil)
						end
					end
					room:clearAG()
				end
				--(3)《出师表》完笔结算
				if player:getMark("WmChushibiao") == 0 then
					local csb = player:getWeapon()
					if csb:isKindOf("WmChushibiao") then
						room:throwCard(csb, nil)
						if player:hasSkill("zhizhe") then
							room:addPlayerMark(player, "@zhizheMark") --再印一张，又何妨？
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player and player:getWeapon() and player:getWeapon():isKindOf("WmChushibiao") and
		player:getMark("WmChushibiao") > 0
	end,
}
WmChushibiao_useNoLimit = sgs.CreateTargetModSkill {
	name = "WmChushibiao_useNoLimit",
	pattern = "Card",
	distance_limit_func = function(self, player, card)
		if player:hasFlag("WmChushibiao_useNoLimit") and card and not card:isVirtualCard() then
			return 1000
		else
			return 0
		end
	end,
	residue_func = function(self, player, card)
		if player:hasFlag("WmChushibiao_anaNoLimit") and card:isKindOf("Analeptic") then
			return 1000
		else
			return 0
		end
	end,
}
WmChushibiao = sgs.CreateWeapon {
	name = "_wm_chushibiao",
	class_name = "WmChushibiao",
	range = 6,
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, WmChushibiaos, false, true, false)
		room:setPlayerMark(player, "WmChushibiao", 2) --记录技能发动次数，限制至多两次
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "WmChushibiao", true, true)
		room:setPlayerMark(player, "WmChushibiao", 0)
	end,
}
WmChushibiao:clone(sgs.Card_Heart, 6):setParent(wmzgl_better)
if not sgs.Sanguosha:getSkill("WmChushibiao") then skills:append(WmChushibiaos) end
if not sgs.Sanguosha:getSkill("WmChushibiao_useNoLimit") then skills:append(WmChushibiao_useNoLimit) end
--
WM_anaNoLimit = sgs.CreateTriggerSkill { --清除【酒】的不计次标志
	name = "WM_anaNoLimit",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.CardFinished },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.from:objectName() == player:objectName() and use.card:isKindOf("Analeptic")
			and (player:hasFlag("WmChushibiao_anaNoLimit") and not player:hasFlag("WmChushibiao_useNoLimit")) --不是通过【出师表】使用的【酒】
			and (player:hasFlag("WmQixingdeng_anaNoLimit") and not player:hasFlag("WmQixingdeng_useNoLimit")) --不是通过【七星灯】使用的【酒】
		then
			if player:hasFlag("WmChushibiao_anaNoLimit") then room:setPlayerFlag(player, "-WmChushibiao_anaNoLimit") end
			if player:hasFlag("WmQixingdeng_anaNoLimit") then room:setPlayerFlag(player, "-WmQixingdeng_anaNoLimit") end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("WM_anaNoLimit") then skills:append(WM_anaNoLimit) end
--2.八阵图
WmBazhentus = sgs.CreateTriggerSkill {
	name = "WmBazhentu",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.TargetConfirming, sgs.CardAsked },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetConfirming then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") and use.from and use.to and use.to:contains(player) and use.to:length() == 1
				and (player:getMark(self:objectName()) == 0 or player:getMark("WmBazhentu_lun") > 0) and not player:isKongcheng() and player:canDiscard(player, "h") then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:addPlayerMark(player, self:objectName())
					local card = room:askForCardShow(player, player, self:objectName())
					local cd = card:getEffectiveId()
					room:showCard(player, cd)
					room:throwCard(card, player, player)
					local suit = card:getSuit()
					local num = card:getNumber()
					if suit == sgs.Card_NoSuit then --随机阵
						room:setPlayerMark(player, "wmBZT_zf", math.random(1, 8))
						room:addPlayerMark(player, "WmBazhentu_lun")
					else --根据花色与点数列阵
						if num >= 8 and num <= 13 then
							if suit == sgs.Card_Heart then
								room:setPlayerMark(player, "wmBZT_zf", 1)
							elseif suit == sgs.Card_Diamond then
								room:setPlayerMark(player, "wmBZT_zf", 2)
							elseif suit == sgs.Card_Club then
								room:setPlayerMark(player, "wmBZT_zf", 3)
							elseif suit == sgs.Card_Spade then
								room:setPlayerMark(player, "wmBZT_zf", 4)
							end
						elseif num >= 1 and num <= 7 then
							if suit == sgs.Card_Heart then
								room:setPlayerMark(player, "wmBZT_zf", 5)
							elseif suit == sgs.Card_Diamond then
								room:setPlayerMark(player, "wmBZT_zf", 6)
							elseif suit == sgs.Card_Club then
								room:setPlayerMark(player, "wmBZT_zf", 7)
							elseif suit == sgs.Card_Spade then
								room:setPlayerMark(player, "wmBZT_zf", 8)
							end
						end
					end
					if player:getMark("wmBZT_zf") == 1 then --☯天覆阵☯
						local zeijun = use.from
						local log = sgs.LogMessage()
						log.type = "$wmBZT_tfz"
						log.from = player
						log.to:append(zeijun)
						log.card_str = use.card:getEffectiveId()
						room:sendLog(log)
						for _, p in sgs.qlist(use.to) do
							use.to:removeOne(p)
						end
						use.from = player
						use.to:append(zeijun)
						room:doAnimate(1, player:objectName(), zeijun:objectName())
						if use.card:objectName() == "slash" then
							if player:isMale() then
								sgs.Sanguosha:playAudioEffect("audio/card/male/slash.ogg", false)
							elseif player:isFemale() then
								sgs.Sanguosha:playAudioEffect("audio/card/female/slash.ogg", false)
							end
							if use.card:isRed() then
								room:setEmotion(player, "slash_red")
							elseif use.card:isBlack() then
								room:setEmotion(player, "slash_black")
							end
						elseif use.card:isKindOf("FireSlash") then
							if player:isMale() then
								sgs.Sanguosha:playAudioEffect("audio/card/male/fire_slash.ogg", false)
							elseif player:isFemale() then
								sgs.Sanguosha:playAudioEffect("audio/card/female/fire_slash.ogg", false)
							end
							room:setEmotion(player, "fire_slash")
						elseif use.card:isKindOf("ThunderSlash") then
							if player:isMale() then
								sgs.Sanguosha:playAudioEffect("audio/card/male/thunder_slash.ogg", false)
							elseif player:isFemale() then
								sgs.Sanguosha:playAudioEffect("audio/card/female/thunder_slash.ogg", false)
							end
							room:setEmotion(player, "thunder_slash")
						elseif use.card:isKindOf("IceSlash") then
							if player:isMale() then
								sgs.Sanguosha:playAudioEffect("audio/card/male/ice_slash.ogg", false)
							elseif player:isFemale() then
								sgs.Sanguosha:playAudioEffect("audio/card/female/ice_slash.ogg", false)
							end
							if use.card:isRed() then
								room:setEmotion(player, "slash_red")
							elseif use.card:isBlack() then
								room:setEmotion(player, "slash_black")
							end
						end
						data:setValue(use)
					elseif player:getMark("wmBZT_zf") == 2 then --☯地载阵☯
						player:gainHujia(1)
						room:drawCards(player, 2, self:objectName())
					elseif player:getMark("wmBZT_zf") == 3 then --☯风扬阵☯
						if not use.from:isNude() and player:canDiscard(use.from, "he") then
							local fytt = room:askForCardChosen(player, use.from, "he", self:objectName(), false,
								sgs.Card_MethodDiscard)
							room:throwCard(fytt, use.from, player)
						end
					elseif player:getMark("wmBZT_zf") == 4 then --☯云垂阵☯
						room:setPlayerFlag(player, "wmBZT_bgz")
					elseif player:getMark("wmBZT_zf") == 5 then --☯龙飞阵☯
						if player:canSlash(use.from, nil, false) then
							local lf_slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
							lf_slash:setSkillName(self:objectName())
							room:useCard(sgs.CardUseStruct(lf_slash, player, use.from))
						end
					elseif player:getMark("wmBZT_zf") == 6 then --☯虎翼阵☯
						room:setPlayerFlag(player, "wmBZT_hyzPFfrom")
						room:setPlayerFlag(use.from, "wmBZT_hyzPFto")
						local hy_slash = room:askForUseSlashTo(player, use.from,
							"@wmBZT_hyz-slash:" .. use.from:objectName(), true)
						if not hy_slash then
							room:setPlayerFlag(player, "-wmBZT_hyzPFfrom")
							room:setPlayerFlag(use.from, "-wmBZT_hyzPFto")
						end
					elseif player:getMark("wmBZT_zf") == 7 then --☯鸟翔阵☯
						local ny_cards = room:getNCards(3)
						room:fillAG(ny_cards)
						room:getThread():delay()
						local jinks = sgs.IntList()
						for _, nyid in sgs.qlist(ny_cards) do
							local nycard = sgs.Sanguosha:getCard(nyid)
							if nycard:isKindOf("Jink") then
								jinks:append(nyid)
							end
						end
						local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
						if not jinks:isEmpty() then
							room:clearAG()
							room:fillAG(jinks)
							local id1 = room:askForAG(player, jinks, true, self:objectName())
							dummy:addSubcard(id1)
						end
						room:clearAG()
						if dummy:subcardsLength() > 0 then
							player:obtainCard(dummy, true)
						end
						dummy:deleteLater()
					elseif player:getMark("wmBZT_zf") == 8 then --☯蛇蟠阵☯
						if not use.from:isKongcheng() then
							local sb_card = room:askForCardShow(use.from, player, self:objectName())
							local sbcd = sb_card:getEffectiveId()
							room:showCard(use.from, sbcd)
							if sb_card:isKindOf("Jink") then
								room:setPlayerFlag(player, "wmBZT_sbz")
							end
						end
					end
					room:setPlayerMark(player, "wmBZT_zf", 0)
				end
			end
		elseif event == sgs.CardAsked then --黑桃阵，启动！
			local pattern = data:toStringList()[1]
			if pattern ~= "jink" then return false end
			if player:hasFlag("wmBZT_bgz") then
				room:setPlayerFlag(player, "-wmBZT_bgz")
				local judge = sgs.JudgeStruct()
				judge.pattern = ".|red"
				judge.good = true
				judge.reason = "eight_diagram"
				judge.who = player
				judge.play_animation = true
				room:judge(judge)
				if judge:isGood() then
					sgs.Sanguosha:playAudioEffect("audio/equip/eight_diagram.ogg", false)
					room:setEmotion(player, "armor/eight_diagram")
					local jink = sgs.Sanguosha:cloneCard("jink", sgs.Card_NoSuit, 0)
					jink:setSkillName(self:objectName())
					room:provide(jink)
					return true
				end
			elseif player:hasFlag("wmBZT_sbz") then
				room:setPlayerFlag(player, "-wmBZT_sbz")
				local jink = sgs.Sanguosha:cloneCard("jink", sgs.Card_NoSuit, 0)
				jink:setSkillName(self:objectName())
				room:provide(jink)
				return true
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getArmor():isKindOf("WmBazhentu") and ArmorNotNullified(player)
	end,
}
WmBazhentu_PFandClear = sgs.CreateTriggerSkill {
	name = "WmBazhentu_PFandClear",
	global = true,
	priority = { -1, -1, -1 },
	frequency = sgs.Skill_Compulsory,
	events = { sgs.TargetConfirming, sgs.CardFinished, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.TargetConfirming then
			if use.card:isKindOf("Slash") and use.from:hasFlag("wmBZT_hyzPFfrom") then
				for _, p in sgs.qlist(use.to) do
					if p:hasFlag("wmBZT_hyzPFto") then
						room:addPlayerMark(p, "Armor_Nullified")
					end
				end
				data:setValue(use)
			end
		elseif event == sgs.CardFinished and use.card:isKindOf("Slash") then
			if not player:hasFlag("wmBZT_hyzPFfrom") then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("wmBZT_hyzPFto") then
					p:setFlags("-wmBZT_hyzPFto")
					if p:getMark("Armor_Nullified") then
						room:removePlayerMark(p, "Armor_Nullified")
					end
				end
			end
			player:setFlags("-wmBZT_hyzPFfrom")
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, "WmBazhentu", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
WmBazhentu = sgs.CreateArmor {
	name = "_wm_bazhentu",
	class_name = "WmBazhentu",
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, WmBazhentus, false, true, false)
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "WmBazhentu", true, true)
	end,
}
WmBazhentu:clone(sgs.Card_Spade, 2):setParent(wmzgl_better)
if not sgs.Sanguosha:getSkill("WmBazhentu") then skills:append(WmBazhentus) end
if not sgs.Sanguosha:getSkill("WmBazhentu_PFandClear") then skills:append(WmBazhentu_PFandClear) end
--3.孔明灯
local _wm_kongmingdeng = sgs.Sanguosha:cloneCard("DefensiveHorse", sgs.Card_Club, 12)
_wm_kongmingdeng:setObjectName("_wm_kongmingdeng")
_wm_kongmingdeng:setParent(wmzgl_better)
WmKongmingdeng = sgs.CreateTriggerSkill {
	name = "WmKongmingdeng",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseStart, sgs.EventPhaseEnd },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play and player:isWounded() and not player:isKongcheng() then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				local yuanjun = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(),
					"WmKongmingdeng-invoke", true, true)                                                                                  --改成可不选是为了AI
				if yuanjun then
					local kmd = room:askForExchange(player, self:objectName(), 1, 1, false,
						"#WmKongmingdeng:" .. yuanjun:getGeneralName())
					if kmd then
						room:obtainCard(yuanjun, kmd,
							sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, yuanjun:objectName(),
								player:objectName(), self:objectName(), ""), false)
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player and player:getDefensiveHorse() and player:getDefensiveHorse():objectName() == "_wm_kongmingdeng"
	end,
}
if not sgs.Sanguosha:getSkill("WmKongmingdeng") then skills:append(WmKongmingdeng) end
--4.火兽
local _wm_huoshou = sgs.Sanguosha:cloneCard("OffensiveHorse", sgs.Card_Diamond, 9)
_wm_huoshou:setObjectName("_wm_huoshou")
_wm_huoshou:setParent(wmzgl_better)
WmHuoshou = sgs.CreateTriggerSkill {
	name = "WmHuoshou",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.DamageCaused, sgs.Damage },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if event == sgs.DamageCaused then
			if damage.from and damage.from:objectName() == player:objectName() and player:getOffensiveHorse() and player:getOffensiveHorse():objectName() == "_wm_huoshou"
				and damage.to:objectName() ~= player:objectName() and damage.to:getArmor() ~= nil then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					sgs.Sanguosha:playAudioEffect("audio/skill/_wm_huoshou.ogg", false)
					room:setEmotion(damage.to, "_wm_huoshou")
					room:setPlayerFlag(player, "WmHuoshou_drstroyArmor")
					room:setPlayerFlag(damage.to, "WmHuoshou_loseArmor")
					if damage.nature ~= sgs.DamageStruct_Fire then damage.nature = sgs.DamageStruct_Fire end
					damage.damage = damage.damage + 1
					data:setValue(damage)
				end
			end
		elseif event == sgs.Damage then
			if damage.from:objectName() == player:objectName() and player:hasFlag("WmHuoshou_drstroyArmor") and damage.to and damage.to:hasFlag("WmHuoshou_loseArmor") then
				room:setPlayerFlag(player, "-WmHuoshou_drstroyArmor")
				room:setPlayerFlag(damage.to, "-WmHuoshou_loseArmor")
				local amr = damage.to:getArmor()
				if amr ~= nil and player:canDiscard(damage.to, "e") then
					room:throwCard(amr, damage.to, player)
				end
			end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("WmHuoshou_drstroyArmor") then room:setPlayerFlag(p, "-WmHuoshou_drstroyArmor") end
				if p:hasFlag("WmHuoshou_loseArmor") then room:setPlayerFlag(p, "-WmHuoshou_loseArmor") end
			end
		end
	end,
	can_trigger = function(self, player)
		return player --:getOffensiveHorse():objectName() == "_wm_huoshou"
	end,
}
if not sgs.Sanguosha:getSkill("WmHuoshou") then skills:append(WmHuoshou) end
--5.七星灯
function destroyEquip(room, move, tag_name) --销毁装备
	local id = room:getTag(tag_name):toInt()
	if move.to_place == sgs.Player_DiscardPile and id > 0 and move.card_ids:contains(id) then
		local move1 = sgs.CardsMoveStruct(id, nil, nil, room:getCardPlace(id), sgs.Player_PlaceTable,
			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, nil, "destroy_equip", ""))
		local card = sgs.Sanguosha:getCard(id)
		local log = sgs.LogMessage()
		log.type = "#DestroyEqiup"
		log.card_str = card:toString()
		room:sendLog(log)
		room:moveCardsAtomic(move1, true)
		room:removeTag(card:getClassName())
	end
end

WmQixingdengs = sgs.CreateTriggerSkill {
	name = "WmQixingdeng",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.DrawInitialCards, sgs.EventPhaseStart, sgs.DamageInflicted, sgs.EventPhaseChanging, sgs.CardsMoveOneTime },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawInitialCards then
			if player:getTreasure() == nil or not player:getTreasure():isKindOf("WmQixingdeng") then return false end
			data:setValue(7)
		elseif event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_RoundStart then
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:getTreasure() == nil or not p:getTreasure():isKindOf("WmQixingdeng") or p:getPile("WmQixingdeng"):length() == 0 then continue end
				local random_get = {}
				for _, c in sgs.qlist(p:getPile("WmQixingdeng")) do
					local qxd = sgs.Sanguosha:getCard(c)
					table.insert(random_get, qxd)
				end
				local qxd_card = random_get[math.random(1, #random_get)]
				room:obtainCard(p, qxd_card)
				local pattern = {}
				for _, q in sgs.qlist(room:getOtherPlayers(p)) do
					if not sgs.Sanguosha:isProhibited(p, q, qxd_card) and qxd_card:isAvailable(p) then
						table.insert(pattern, qxd_card:getEffectiveId())
					end
				end
				if #pattern > 0 then
					room:setPlayerFlag(p, "WmQixingdeng_useNoLimit")
					local qxds = room:askForUseCard(p, table.concat(pattern, ","),
						"@WmQixingdeng_use:" .. qxd_card:objectName(), -1)
					if qxds then
						if not p:hasFlag("WmQixingdeng_anaNoLimit") then room:setPlayerFlag(p, "WmQixingdeng_anaNoLimit") end --专门处理【酒】的不计次
					end
					room:setPlayerFlag(p, "-WmQixingdeng_useNoLimit")
				end
			end
			if player:getMark(self:objectName()) == 0 then
				room:addPlayerMark(player, self:objectName())
			else
				if player:getTreasure() == nil or not player:getTreasure():isKindOf("WmQixingdeng") then return false end
				local zdhz = 0
				if player:getPile("WmQixingdeng"):length() > 0 then
					for _, c in sgs.qlist(player:getPile("WmQixingdeng")) do
						local qxd = sgs.Sanguosha:getCard(c)
						if qxd:getNumber() == 7 then zdhz = zdhz + 1 end
					end
				end
				if zdhz > 0 then --含有“主灯”
					local amh = 0
					for _, c in sgs.qlist(player:getPile("WmQixingdeng")) do
						local qxd = sgs.Sanguosha:getCard(c)
						if qxd:getNumber() == 7 then
							room:throwCard(qxd, nil)
						else
							amh = amh + 1
						end
					end
					room:gainMaxHp(player, amh, self:objectName())
					local svids = sgs.IntList()
					for _, id in sgs.qlist(room:getDiscardPile()) do
						local svd = sgs.Sanguosha:getCard(id)
						if svd:getNumber() == 7 then svids:append(id) end
					end
					room:shuffleIntoDrawPile(player, svids, self:objectName(), false)
				else --不含“主灯”
					room:loseHp(player, 1)
					if player:isAlive() then
						local hp = player:getHp()
						local hc = player:getHandcardNum()
						if hp < hc then
							local n = hc - hp
							room:askForDiscard(player, self:objectName(), n, n)
						end
					end
					room:setPlayerFlag(player, "WmQixingdeng_skip")
				end
				if player:getPile("WmQixingdeng"):length() > 0 then
					local dummy = sgs.Sanguosha:cloneCard("slash")
					dummy:addSubcards(player:getPile("WmQixingdeng"))
					room:throwCard(dummy, nil)
					dummy:deleteLater()
				end
				local wm_qxd = player:getTreasure()
				if wm_qxd ~= nil and wm_qxd:isKindOf("WmQixingdeng") then
					room:setPlayerFlag(player, "destroyQXD")
					room:throwCard(wm_qxd, nil) --创造销毁的时机
				end
			end
		elseif event == sgs.DamageInflicted then
			local damage = data:toDamage()
			if damage.to:objectName() ~= player:objectName() or player:getTreasure() == nil or not player:getTreasure():isKindOf("WmQixingdeng")
				or player:getPile("WmQixingdeng"):length() == 0 then
				return false
			end
			local random_get = {}
			for _, c in sgs.qlist(player:getPile("WmQixingdeng")) do
				local qxd = sgs.Sanguosha:getCard(c)
				table.insert(random_get, qxd)
			end
			local qxd_card = random_get[math.random(1, #random_get)]
			room:obtainCard(player, qxd_card)
			local pattern = {}
			for _, q in sgs.qlist(room:getOtherPlayers(player)) do
				if not sgs.Sanguosha:isProhibited(player, q, qxd_card) and qxd_card:isAvailable(player) then
					table.insert(pattern, qxd_card:getEffectiveId())
				end
			end
			if #pattern > 0 then
				room:setPlayerFlag(player, "WmQixingdeng_useNoLimit")
				local qxds = room:askForUseCard(player, table.concat(pattern, ","),
					"@WmQixingdeng_use:" .. qxd_card:objectName(), -1)
				if qxds then
					if not player:hasFlag("WmQixingdeng_anaNoLimit") then room:setPlayerFlag(player,
							"WmQixingdeng_anaNoLimit") end                                                           --专门处理【酒】的不计次
				end
				room:setPlayerFlag(player, "-WmQixingdeng_useNoLimit")
			end
		elseif event == sgs.EventPhaseChanging then
			if data:toPhaseChange().to == sgs.Player_Start and player:hasFlag("WmQixingdeng_skip") then
				room:setPlayerFlag(player, "-WmQixingdeng_skip")
				player:skip(sgs.Player_Start)
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName() and player:hasFlag("destroyQXD") then
				room:setPlayerFlag(player, "-destroyQXD")
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if card:isKindOf("WmQixingdeng") then
						destroyEquip(room, move, "QXD_ID") --销毁
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
WmQixingdeng_useNoLimit = sgs.CreateTargetModSkill {
	name = "WmQixingdeng_useNoLimit",
	pattern = "Card",
	distance_limit_func = function(self, player, card)
		if player:hasFlag("WmQixingdeng_useNoLimit") and card and not card:isVirtualCard() then
			return 1000
		else
			return 0
		end
	end,
	residue_func = function(self, player, card)
		if player:hasFlag("WmQixingdeng_anaNoLimit") and card:isKindOf("Analeptic") then
			return 1000
		else
			return 0
		end
	end,
}
WmQixingdeng = sgs.CreateTreasure {
	name = "_wm_qixingdeng",
	class_name = "WmQixingdeng",
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, WmQixingdengs, false, true, false)
		local ids, zd, fd = sgs.IntList(), 1, 6
		for _, id in sgs.qlist(room:getDrawPile()) do
			local cd = sgs.Sanguosha:getCard(id)
			if cd:getNumber() == 7 and zd > 0 then
				ids:append(id)
				zd = zd - 1
			elseif cd:getNumber() ~= 7 and fd > 0 then
				ids:append(id)
				fd = fd - 1
			end
		end
		if not ids:isEmpty() then
			player:addToPile("WmQixingdeng", ids)
		end
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "WmQixingdeng", true, true)
		if player:getPile("WmQixingdeng"):length() > 0 then
			local dummy = sgs.Sanguosha:cloneCard("slash")
			dummy:addSubcards(player:getPile("WmQixingdeng"))
			room:throwCard(dummy, nil)
			dummy:deleteLater()
		end
	end,
}
WmQixingdeng:clone(sgs.Card_Club, 7):setParent(wmzgl_better)
if not sgs.Sanguosha:getSkill("WmQixingdeng") then skills:append(WmQixingdengs) end
if not sgs.Sanguosha:getSkill("WmQixingdeng_useNoLimit") then skills:append(WmQixingdeng_useNoLimit) end

--5.加入专属卡牌
WM_addCards = sgs.CreateTriggerSkill {
	name = "WM_addCards",
	global = true,
	priority = { 5, 5 },
	frequency = sgs.Skill_Compulsory,
	events = { sgs.DrawInitialCards, sgs.CardsMoveOneTime },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawInitialCards then
			if table.contains(sgs.Sanguosha:getBanPackages(), "wmzgl_better") or player:getSeat() ~= 1 then return false end --判断座位以防止循环
			local online = {}
			local robots = {}
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if (p:getGeneralName() == "wumiao_zhugeliang" or p:getGeneral2Name() == "wumiao_zhugeliang")
					or (p:getGeneralName() == "wumiao_zhugeliang_qg1x" or p:getGeneral2Name() == "wumiao_zhugeliang_qg1x") then
					if p:getState() == "online" then
						table.insert(online, p)
					elseif p:getState() == "robot" then
						table.insert(online, p)
					end
				end
			end
			local wzg = nil
			if #online > 0 then
				wzg = online[math.random(1, #online)]
			end
			if wzg == nil and #robots > 0 then
				wzg = robots[math.random(1, #robots)]
			end
			if wzg == nil then return false end
			local choice = room:askForChoice(wzg, self:objectName(), "addQxd+noQxd")
			local cds = sgs.IntList()
			for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
				local wmcd = sgs.Sanguosha:getEngineCard(id)
				if (wmcd:isKindOf("WmJugongjincui") or wmcd:isKindOf("WmChushibiao") or wmcd:isKindOf("WmBazhentu")
						or wmcd:objectName() == "_wm_kongmingdeng" or wmcd:objectName() == "_wm_huoshou") and room:getCardPlace(id) ~= sgs.Player_DrawPile then
					cds:append(id)
				elseif choice == "addQxd" and wmcd:isKindOf("WmQixingdeng") and room:getCardPlace(id) ~= sgs.Player_DrawPile then
					cds:append(id)
				end
			end
			if not cds:isEmpty() then
				room:shuffleIntoDrawPile(wzg, cds, self:objectName(), true)
				--1.出师表
				local cards, cards_copy = sgs.CardList(), sgs.CardList()
				for _, id in sgs.qlist(room:getDrawPile()) do
					local card = sgs.Sanguosha:getCard(id)
					if card:isKindOf("WmChushibiao") then
						room:setTag("CSB_ID", sgs.QVariant(id))
						cards:append(card)
						cards_copy:append(card)
					end
				end
				if not cards:isEmpty() then
					local equipA
					while not equipA do
						if cards:isEmpty() then break end
						if not equipA then
							equipA = cards:at(math.random(0, cards:length() - 1))
							for _, card in sgs.qlist(cards_copy) do
								if card:getSubtype() == equipA:getSubtype() then
									cards:removeOne(card)
								end
							end
						end
					end
					if equipA then
						local Moves = sgs.CardsMoveList()
						local equip = equipA:getRealCard():toEquipCard()
						local equip_index = equip:location()
						if wzg:getEquip(equip_index) == nil and wzg:hasEquipArea(equip_index) then
							sgs.Sanguosha:playAudioEffect("audio/card/common/armor.ogg", false)
							Moves:append(sgs.CardsMoveStruct(equipA:getId(), wzg, sgs.Player_PlaceEquip,
								sgs.CardMoveReason()))
						else
							Moves:append(sgs.CardsMoveStruct(equipA:getId(), wzg, sgs.Player_PlaceHand,
								sgs.CardMoveReason()))
						end
						room:moveCardsAtomic(Moves, true)
					end
				end
				--2.八阵图
				local cards, cards_copy = sgs.CardList(), sgs.CardList()
				for _, id in sgs.qlist(room:getDrawPile()) do
					local card = sgs.Sanguosha:getCard(id)
					if card:isKindOf("WmBazhentu") then
						room:setTag("BZT_ID", sgs.QVariant(id))
						cards:append(card)
						cards_copy:append(card)
					end
				end
				if not cards:isEmpty() then
					local equipA
					while not equipA do
						if cards:isEmpty() then break end
						if not equipA then
							equipA = cards:at(math.random(0, cards:length() - 1))
							for _, card in sgs.qlist(cards_copy) do
								if card:getSubtype() == equipA:getSubtype() then
									cards:removeOne(card)
								end
							end
						end
					end
					if equipA then
						local Moves = sgs.CardsMoveList()
						local equip = equipA:getRealCard():toEquipCard()
						local equip_index = equip:location()
						if wzg:getEquip(equip_index) == nil and wzg:hasEquipArea(equip_index) then
							sgs.Sanguosha:playAudioEffect("audio/card/common/armor.ogg", false)
							Moves:append(sgs.CardsMoveStruct(equipA:getId(), wzg, sgs.Player_PlaceEquip,
								sgs.CardMoveReason()))
						else
							Moves:append(sgs.CardsMoveStruct(equipA:getId(), wzg, sgs.Player_PlaceHand,
								sgs.CardMoveReason()))
						end
						room:moveCardsAtomic(Moves, true)
					end
				end
				--3.孔明灯
				local cards, cards_copy = sgs.CardList(), sgs.CardList()
				for _, id in sgs.qlist(room:getDrawPile()) do
					local card = sgs.Sanguosha:getCard(id)
					if card:objectName() == "_wm_kongmingdeng" then
						room:setTag("KMD_ID", sgs.QVariant(id))
						cards:append(card)
						cards_copy:append(card)
					end
				end
				if not cards:isEmpty() then
					local equipA
					while not equipA do
						if cards:isEmpty() then break end
						if not equipA then
							equipA = cards:at(math.random(0, cards:length() - 1))
							for _, card in sgs.qlist(cards_copy) do
								if card:getSubtype() == equipA:getSubtype() then
									cards:removeOne(card)
								end
							end
						end
					end
					if equipA then
						local Moves = sgs.CardsMoveList()
						local equip = equipA:getRealCard():toEquipCard()
						local equip_index = equip:location()
						if wzg:getEquip(equip_index) == nil and wzg:hasEquipArea(equip_index) then
							sgs.Sanguosha:playAudioEffect("audio/card/common/armor.ogg", false)
							Moves:append(sgs.CardsMoveStruct(equipA:getId(), wzg, sgs.Player_PlaceEquip,
								sgs.CardMoveReason()))
						else
							Moves:append(sgs.CardsMoveStruct(equipA:getId(), wzg, sgs.Player_PlaceHand,
								sgs.CardMoveReason()))
						end
						room:moveCardsAtomic(Moves, true)
					end
				end
				--4.火兽
				local cards, cards_copy = sgs.CardList(), sgs.CardList()
				for _, id in sgs.qlist(room:getDrawPile()) do
					local card = sgs.Sanguosha:getCard(id)
					if card:objectName() == "_wm_huoshou" then
						room:setTag("HS_ID", sgs.QVariant(id))
						cards:append(card)
						cards_copy:append(card)
					end
				end
				if not cards:isEmpty() then
					local equipA
					while not equipA do
						if cards:isEmpty() then break end
						if not equipA then
							equipA = cards:at(math.random(0, cards:length() - 1))
							for _, card in sgs.qlist(cards_copy) do
								if card:getSubtype() == equipA:getSubtype() then
									cards:removeOne(card)
								end
							end
						end
					end
					if equipA then
						local Moves = sgs.CardsMoveList()
						local equip = equipA:getRealCard():toEquipCard()
						local equip_index = equip:location()
						if wzg:getEquip(equip_index) == nil and wzg:hasEquipArea(equip_index) then
							sgs.Sanguosha:playAudioEffect("audio/card/common/armor.ogg", false)
							Moves:append(sgs.CardsMoveStruct(equipA:getId(), wzg, sgs.Player_PlaceEquip,
								sgs.CardMoveReason()))
						else
							Moves:append(sgs.CardsMoveStruct(equipA:getId(), wzg, sgs.Player_PlaceHand,
								sgs.CardMoveReason()))
						end
						room:moveCardsAtomic(Moves, true)
					end
				end
				--5.(可能的)七星灯
				local cards, cards_copy = sgs.CardList(), sgs.CardList()
				for _, id in sgs.qlist(room:getDrawPile()) do
					local card = sgs.Sanguosha:getCard(id)
					if card:isKindOf("WmQixingdeng") then
						room:setTag("QXD_ID", sgs.QVariant(id))
						cards:append(card)
						cards_copy:append(card)
					end
				end
				if not cards:isEmpty() then
					local equipA
					while not equipA do
						if cards:isEmpty() then break end
						if not equipA then
							equipA = cards:at(math.random(0, cards:length() - 1))
							for _, card in sgs.qlist(cards_copy) do
								if card:getSubtype() == equipA:getSubtype() then
									cards:removeOne(card)
								end
							end
						end
					end
					if equipA then
						local Moves = sgs.CardsMoveList()
						local equip = equipA:getRealCard():toEquipCard()
						local equip_index = equip:location()
						if wzg:getEquip(equip_index) == nil and wzg:hasEquipArea(equip_index) then
							sgs.Sanguosha:playAudioEffect("audio/card/common/armor.ogg", false)
							Moves:append(sgs.CardsMoveStruct(equipA:getId(), wzg, sgs.Player_PlaceEquip,
								sgs.CardMoveReason()))
						else
							Moves:append(sgs.CardsMoveStruct(equipA:getId(), wzg, sgs.Player_PlaceHand,
								sgs.CardMoveReason()))
						end
						room:moveCardsAtomic(Moves, true)
					end
				end
			end
		elseif event == sgs.CardsMoveOneTime then --【八阵图】与【七星灯】在即将离开“武庙诸葛亮”的区域且进入其他角色的区域时销毁
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName()
				and ((player:getGeneralName() == "wumiao_zhugeliang" or player:getGeneral2Name() == "wumiao_zhugeliang")
					or (player:getGeneralName() == "wumiao_zhugeliang_qg1x" or player:getGeneral2Name() == "wumiao_zhugeliang_qg1x")
					or (player:getGeneralName() == "wumiao_zhugeliang_wake" or player:getGeneral2Name() == "wumiao_zhugeliang_wake"))
				and move.to and move.to:objectName() ~= player:objectName() then
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if card:isKindOf("WmBazhentu") then
						destroyEquip(room, move, "BZT_ID")
					end
					if card:isKindOf("WmQixingdeng") then
						destroyEquip(room, move, "QXD_ID")
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("WM_addCards") then skills:append(WM_addCards) end

sgs.LoadTranslationTable {
	["wmzgl_better"] = "武庙诸葛亮美化包",
	--尽瘁
	["$myjincui1"] = "情寄三顾之恩，亮必继之以死。",
	["$myjincui2"] = "身负六尺之孤，臣当鞠躬尽瘁。",
	["$myjincui3"] = "此身抱薪，可付丹鼎，五十四年春秋昭炎汉长明。",
	["$myjincui4"] = "南征北伐，誓还旧都，二十四代王业不偏安一隅。",
	--情势
	["$qingshi1"] = "兵者，行霸道之势，彰王道之实。",
	["$qingshi2"] = "将为军魂，可因势而袭，其有战无类。",
	["$qingshi3"] = "平二川，定三足，恍惚草堂梦里，挥斥千古风流。",
	["$qingshi4"] = "战群儒，守空城，今摆乱石八阵，笑谈将军死生。",
	--智哲
	["$zhizhe1"] = "轻舟载浊酒，此去，我欲借箭十万。",
	["$zhizhe2"] = "主公有多大胆略，亮便有多少谋略。",
	["$zhizhe3"] = "三顾之谊铭心，隆中之言在耳，请托臣讨贼兴复之效。",
	["$zhizhe4"] = "著大义于四海，揽天下之弼士，诚如是，则汉室可兴。",
	--阵亡
	["~wumiao_zhugeliang"] = "天下事，了犹未了，终以不了了之......",
	--
	["wmzgl_SkinChange"] = "更换武将皮肤",
	["wmzgl_SkinChange_Button"] = "换皮",
	["wmzgl_skinchange_button"] = "更换武将皮肤",
	["wmzgl_SkinChange_ButtonCard"] = "更换武将皮肤",
	["wmyh"] = "原画",
	["qgyx"] = "千古一相",
	["wumiao_zhugeliang_qg1x"] = "武庙诸葛亮",
	["&wumiao_zhugeliang_qg1x"] = "诸葛亮",
	["~wumiao_zhugeliang_qg1x"] = "一别隆中三十载，归来犹唱梁甫吟......",
	["wmzgl_hideskin"] = "",
	["$wmzglWake"] = "\
	  三顾频烦天下计\
	  两朝开济老臣心\
	  出师未捷身先死\
	  长使英雄泪满襟\
	    --《蜀相》[唐]杜甫",
	["wumiao_zhugeliang_wake"] = "武庙诸葛亮",
	["&wumiao_zhugeliang_wake"] = "诸葛亮",
	["~wumiao_zhugeliang_wake"] = "天下事，了犹未了，终以不了了之......",

	["wmzgl_trick"] = "武庙诸葛亮专属锦囊",
	--鞠躬尽瘁（♦A/♥K）
	["_wm_jugongjincui"] = "鞠躬尽瘁",
	["WmJugongjincui"] = "鞠躬尽瘁",
	["WmJugongjincuiBuff"] = "鞠躬尽瘁",
	[":_wm_jugongjincui"] = "锦囊牌\
	<b>加入</b>：即将分发起始手牌时，若场上有“武庙诸葛亮”，洗入牌堆\
	<b>时机</b>：出牌阶段\
	<b>目标</b>：自己\
	<b>效果</b>：出牌阶段，对自己使用，则此回合结束后，你进行一个新回合：该回合所有阶段改为出牌阶段，且每阶段开始时，<font color='red'><b>若你的体力值大于1，</b></font>" ..
		"你失去1点体力并摸一张牌；<font color='red'><b>否则你结束此回合的所有阶段</b></font>。<br/> <font color=\"#990000\"><b>/死而后已/</b></font>锁定技，此锦囊牌不可被【无懈可击】响应。",
	["$wmJGJC"] = "\
	  臣鞠躬尽力，死而后已。\
	  至于成败利钝，非臣之明所能逆睹也。\
	    --《后出师表》[蜀汉]诸葛亮",

	["wmzgl_equips"] = "武庙诸葛亮专属装备",
	--武器：出师表（♥6）
	["_wm_chushibiao"] = "出师表",
	["WmChushibiao"] = "出师表",
	["WmChushibiao_useNoLimit"] = "出师表",
	[":_wm_chushibiao"] = "装备牌·武器<br /><b>攻击范围</b>：6\
	<b>装备时机</b>：即将分发起始手牌时，置入“武庙诸葛亮”的装备区。\
	<b>装备限制</b>：无\
	<b>武器技能</b>：准备阶段开始时，你可以亮出牌堆顶的X张牌(X为你的当前体力值且至多为6)，然后选择一名其他角色：其获得其中不同类别的牌各一张，剩余的牌你依次使用之" ..
		"（无距离限制且不计次，若不使用或无法使用则置入弃牌堆）。若你为第二次发动此武器技能，技能效果结算结束后此武器将被置入弃牌堆，且若你有技能“智哲”，本局游戏你“智哲”可发动次数+1。",
	["@WmChushibiao_use"] = "请使用这张【<font color='yellow'><b>%src</b></font>】",
	--防具：八阵图（♠2）
	["_wm_bazhentu"] = "八阵图",
	["WmBazhentu"] = "八阵图",
	["WmBazhentu_PFandClear"] = "八阵图",
	[":_wm_bazhentu"] = "装备牌·防具\
	<b>装备时机</b>：即将分发起始手牌时，置入“武庙诸葛亮”的装备区。\
	<b>装备限制</b>：于离开“武庙诸葛亮”的区域并即将进入其他角色的区域时销毁。\
	<b>防具技能</b>：每个回合限一次，当你成为【杀】的唯一目标时，你可以展示并弃置一张手牌，根据此牌的花色与点数，执行相应阵法：\
	红桃8~K<b>☯天覆阵☯</b>：改为你成为此【杀】的使用者，对方成为此【杀】的目标；\
	方块8~K<b>☯地载阵☯</b>：你获得1点护甲并摸两张牌；\
	梅花8~K<b>☯风扬阵☯</b>：你弃置对方的一张牌；\
	黑桃8~K<b>☯云垂阵☯</b>：你发动“八卦阵”技能；\
	红桃A~7<b>☯龙飞阵☯</b>：视为你对其使用一张【杀】（无视距离）；\
	方块A~7<b>☯虎翼阵☯</b>：你可以立即对其使用一张【杀】（无视防具）；\
	梅花A~7<b>☯鸟翔阵☯</b>：你亮出牌堆顶的三张牌，获得其中的一张【闪】；\
	黑桃A~7<b>☯蛇蟠阵☯</b>：你展示其一张手牌，若为【闪】，视为你使用了一张【闪】；\
	<b>无色</b>：你随机执行一种阵法，且本轮可发动此防具技能次数+1。",
	["wmBZT_zf"] = "",
	["$wmBZT_tfz"] = "%from 布置的 <font color='yellow'><b>[</b></font><font color='red'><b>天覆阵</b></font><font color='yellow'><b>]</b></font> 将法则改变，" ..
		"%from 成为 %card 的使用者，目标为 %to",
	["@wmBZT_hyz-slash"] = "你可以对 %src 使用一张【杀】（无视防具）",
	--防御坐骑：孔明灯（♣Q）
	["_wm_kongmingdeng"] = "孔明灯",
	["WmKongmingdeng"] = "孔明灯",
	[":_wm_kongmingdeng"] = "装备牌·防御坐骑\
	<b>装备时机</b>：即将分发起始手牌时，置入“武庙诸葛亮”的装备区。\
	<b>装备限制</b>：无\
	<b>坐骑技能</b>：锁定技，其他角色与你的距离+1；出牌阶段开始/结束时，若你已受伤，你可以将一张手牌交给一名其他角色。",
	["WmKongmingdeng-invoke"] = "请选择你需要通过【孔明灯】传递“信息”的援军",
	["#WmKongmingdeng"] = "[孔明灯]请将你的一张手牌交给%src",
	--进攻坐骑：火兽（♦9）
	["_wm_huoshou"] = "火兽",
	["WmHuoshou"] = "火兽",
	[":_wm_huoshou"] = "装备牌·进攻坐骑\
	<b>装备时机</b>：即将分发起始手牌时，置入“武庙诸葛亮”的装备区。\
	<b>装备限制</b>：无\
	<b>坐骑技能</b>：锁定技，你与其他角色的距离-1；当你对一名有防具的其他角色造成伤害时，你可以令此伤害+1且改为火焰伤害，然后于造成伤害后弃置其防具。",
	--宝物：七星灯（♣7）
	["_wm_qixingdeng"] = "七星灯",
	["WmQixingdeng"] = "七星灯",
	["WmQixingdeng_useNoLimit"] = "七星灯",
	[":_wm_qixingdeng"] = "装备牌·宝物\
	<b>装备时机</b>：即将分发起始手牌时，“武庙诸葛亮”可选择将此牌置入装备区。\
	<b>装备限制</b>：于离开“武庙诸葛亮”的区域并即将进入其他角色的区域时销毁。\
	<b>宝物技能</b>：锁定技，你的起始手牌数改为7；此牌进入你的装备区时，你将牌堆中随机的一张点数为7的牌与六张点数不为7的牌置于武将牌上，" ..
		"称为“七星灯”（其中点数为7的牌称为“主灯”）。一名其他角色的回合开始时或当你受到伤害时，你随机获得“七星灯”中的一张牌，并可立即使用之（无距离限制且不计次）。" ..
		"你的非首个回合开始时，若你“七星灯”中：\
	1.含有“主灯”，你将“主灯”牌置入弃牌堆并增加X点体力上限，然后将弃牌堆中所有点数为7的牌洗入牌堆；\
	2.不含“主灯”，你失去1点体力、将手牌弃至数量等同于你的当前体力值，然后跳过本回合的准备阶段。\
	（X为此时“七星灯”中的牌数；“主灯”检测结算结束后，所有“七星灯”牌将被置入弃牌堆，此宝物销毁）",
	["@WmQixingdeng_use"] = "你可以使用这张【<font color='yellow'><b>%src</b></font>】",
	["#DestroyEqiup"] = "%card 被销毁",

	["WM_addCards"] = "加入[武庙诸葛亮专属卡牌]",
	["WM_addCards:addQxd"] = "将【七星灯】置入我的装备区",
	["WM_addCards:noQxd"] = "算了",
}
--====================--

--XJ05 新杀-孙翎鸾
xj_sunlingluan = sgs.General(extension, "xj_sunlingluan", "wu", 3, false)

xj_lingyue = sgs.CreateTriggerSkill {
	name = "xj_lingyue",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.Damage, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damage then
			local damage = data:toDamage()
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:addPlayerMark(p, "xj_lingyue_DMG", damage.damage) --记录该回合伤害总值（大家一起记录，避免存档丢失）
			end
			local ltd = room:findPlayerBySkillName(self:objectName())
			if ltd then
				local current = room:getCurrent()
				room:setPlayerMark(current, "&xj_lingyue_DMG", current:getMark("xj_lingyue_DMG")) --方便玩家查看用
			end
			if damage.from and damage.from:isAlive() and not damage.from:hasFlag("xj_lingyue_FD") then
				room:setPlayerFlag(damage.from, "xj_lingyue_FD") --标明该角色于该回合造成过伤害
			end
			if player:getMark("xj_lingyue_lun") > 0 then return false end --判断是否为该轮首次造成伤害
			room:setPlayerMark(player, "xj_lingyue_lun", 1)
			if ltd then room:setPlayerMark(player, "&xjly_lun", 1) end --方便玩家查看用
			local n = 1
			if player:getPhase() == sgs.Player_NotActive then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					n = p:getMark("xj_lingyue_DMG")
					break
				end
			end
			for _, ltds in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				room:sendCompulsoryTriggerLog(ltds, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:drawCards(ltds, n, self:objectName())
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, "xj_lingyue_DMG", 0)
				room:setPlayerMark(p, "&xj_lingyue_DMG", 0)
				if p:hasFlag("xj_lingyue_FD") then
					room:setPlayerFlag(p, "-xj_lingyue_FD")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
xj_sunlingluan:addSkill(xj_lingyue)

xj_pandiCard = sgs.CreateSkillCard {
	name = "xj_pandiCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and
		not to_select:hasFlag("xj_lingyue_FD")
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		for _, p in sgs.qlist(room:getAllPlayers()) do
			room:setPlayerMark(p, "&xj_pandi", 0)
		end
		room:setPlayerMark(effect.to, "&xj_pandi", 1) --锁定为使用来源
		room:setPlayerMark(effect.from, "xj_pandi", 1)
	end,
}
xj_pandi = sgs.CreateZeroCardViewAsSkill {
	name = "xj_pandi",
	view_as = function()
		return xj_pandiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return true
	end,
}
xj_pandid = sgs.CreateTriggerSkill {
	name = "xj_pandid",
	global = true,
	priority = 8100,
	frequency = sgs.Skill_Frequent,
	events = { sgs.PreCardUsed, sgs.EventPhaseEnd },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.PreCardUsed then
			local use = data:toCardUse()
			if use.from and use.from:objectName() == player:objectName() and player:getMark("xj_pandi") > 0
				and use.card and not use.card:isKindOf("SkillCard") then
				room:setPlayerMark(player, "xj_pandi", 0)
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:getMark("&xj_pandi") > 0 then
						local log = sgs.LogMessage()
						log.type = "$xj_pandiUseFromChanged"
						log.from = p
						log.card_str = use.card:toString()
						room:sendLog(log)
						room:broadcastSkillInvoke("xj_pandi")
						room:setPlayerMark(p, "&xj_pandi", 0)
						use.from = p
						--目标仅限于自己的牌(比如酒、无中、装备牌等)：将使用目标改为该角色
						if use.to and use.to:length() == 1 and use.to:contains(player) then
							use.to:removeOne(player)
							use.to:append(p)
							--AOE牌：将该角色移出使用目标，你加入使用目标
						elseif use.card:isKindOf("AOE") then
							if use.to:contains(p) then use.to:removeOne(p) end
							if not use.to:contains(player) then use.to:append(player) end
						end
						data:setValue(use)
						break
					end
				end
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Play then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					room:setPlayerMark(p, "&xj_pandi", 0)
					room:setPlayerMark(p, "xj_pandi", 0)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
xj_pandiOther = sgs.CreateTargetModSkill {
	name = "xj_pandiOther",
	pattern = "Card",
	distance_limit_func = function(self, player, card)
		if player:getMark("xj_pandi") > 0 and card and not card:isKindOf("SkillCard") then
			return 1000
		else
			return 0
		end
	end,
	residue_func = function(self, player, card)
		if player:getMark("xj_pandi") > 0 and card and not card:isKindOf("SkillCard") then
			return 1000
		else
			return 0
		end
	end,
}
xj_sunlingluan:addSkill(xj_pandi)
if not sgs.Sanguosha:getSkill("xj_pandid") then skills:append(xj_pandid) end
if not sgs.Sanguosha:getSkill("xj_pandiOther") then skills:append(xj_pandiOther) end

sgs.LoadTranslationTable {
	["xj_sunlingluan"] = "孙翎鸾",
	["#xj_sunlingluan"] = "独断万古", --军一缔造之神，翎天帝！
	["designer:xj_sunlingluan"] = "官方(十周年)",
	["cv:xj_sunlingluan"] = "官方",
	["illustrator:xj_sunlingluan"] = "蛋蛋", --皮肤：青翎和鸣
	--聆乐
	["xj_lingyue"] = "聆乐",
	[":xj_lingyue"] = "锁定技，当一名角色于一轮内首次造成伤害后，你摸X张牌（X为1；若此时为该角色回合外，X改为当前回合造成的伤害值之和）。",
	["xj_lingyue_DMG"] = "聆乐之伤",
	["xjly"] = "聆乐已伤",
	["$xj_lingyue1"] = "既存慧心，则虫石草木之声皆为仙乐。",
	["$xj_lingyue2"] = "金珠坠玉盘，其声若击磬、灵同鸣佩。",
	--盻睇
	["xj_pandi"] = "盻睇",
	["xj_pandiOther"] = "盻睇",
	[":xj_pandi"] = "出牌阶段，你可以选择一名本回合未造成过伤害的其他角色，若如此做，你于本阶段使用的下一张牌视为由其使用。\
	<b><font color=\"#4DB873\">（</font><font color='red'>不受距离和次数限制</font><font color=\"#4DB873\">）</font></b>",
	["$xj_pandiUseFromChanged"] = "因为“<font color='yellow'><b>盻睇</b></font>”的效果，%from 成为 %card 的使用者",
	["$xj_pandi1"] = "摩由逻入浮屠，拜遍千尊，只求一人之心。",
	["$xj_pandi2"] = "南客闻笙歌管弦，必盼睇而舞，若有意焉。",
	--阵亡
	["~xj_sunlingluan"] = "愿以千世轮回，换一世厮守......",
}
-----
sgs.Sanguosha:addSkills(skills)
return { extension, wmzgl_better }
