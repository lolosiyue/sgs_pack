extension = sgs.Package("fcDIY", sgs.Package_GeneralPack)
xiangyuEquip = sgs.Package("xiangyuEquip", sgs.Package_CardPack)

--==V1.0==--
--1 神貂蝉-自改版
shendiaochan_change = sgs.General(extension, "shendiaochan_change", "god", 3, false)

f_meihun = sgs.CreateTriggerSkill{
    name = "f_meihun",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.TargetConfirmed},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Finish then
		    if room:askForSkillInvoke(player, self:objectName(), data) then
			    local plist = room:getOtherPlayers(player)
				local victim = room:askForPlayerChosen(player, plist, self:objectName())
				if victim:isNude() then return false end
				local suit = room:askForSuit(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), 1)
				room:getThread():delay()
				if suit == sgs.Card_Heart then
				    local card = room:askForCard(victim, ".|heart", "@f_meihun-suit", data, sgs.Card_MethodNone)
					player:obtainCard(card)
					if not card then
				        if not victim:isKongcheng() then
					        local ids = sgs.IntList()
				            for _, c in sgs.qlist(victim:getHandcards()) do
					            if c then
						            ids:append(c:getEffectiveId())
					            end
				            end
						    local card_id = room:doGongxin(player, victim, ids)
				            if (card_id == -1) then return end
						    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, player:objectName(), nil, self:objectName(), nil)
					        room:throwCard(sgs.Sanguosha:getCard(card_id), reason, victim, player)
					    end
						local judge = sgs.JudgeStruct()
			    		judge.pattern = ".|red"
			    		judge.good = true
			    		judge.play_animation = true
			    		judge.who = player
			    		judge.reason = "f_huoxin"
			    		room:judge(judge)
						if judge:isGood() then
			        		victim:gainMark("&f_meihuo")
							room:broadcastSkillInvoke("f_huoxin", 1)
						end
					end
					return false
				elseif suit == sgs.Card_Diamond then
				    local card = room:askForCard(victim, ".|diamond", "@f_meihun-suit", data, sgs.Card_MethodNone)
					player:obtainCard(card)
					if not card then
				        if not victim:isKongcheng() then
					        local ids = sgs.IntList()
				            for _, c in sgs.qlist(victim:getHandcards()) do
					            if c then
						            ids:append(c:getEffectiveId())
					            end
				            end
						    local card_id = room:doGongxin(player, victim, ids)
				            if (card_id == -1) then return end
						    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, player:objectName(), nil, self:objectName(), nil)
					        room:throwCard(sgs.Sanguosha:getCard(card_id), reason, victim, player)
					    end
						local judge = sgs.JudgeStruct()
			    		judge.pattern = ".|red"
			    		judge.good = true
			    		judge.play_animation = true
			    		judge.who = player
			    		judge.reason = "f_huoxin"
			    		room:judge(judge)
						if judge:isGood() then
			        		victim:gainMark("&f_meihuo")
							room:broadcastSkillInvoke("f_huoxin", 1)
						end
				    end
					return false
				elseif suit == sgs.Card_Club then
				    local card = room:askForCard(victim, ".|club", "@f_meihun-suit", data, sgs.Card_MethodNone)
					player:obtainCard(card)
					if not card then
				        if not victim:isKongcheng() then
					        local ids = sgs.IntList()
				            for _, c in sgs.qlist(victim:getHandcards()) do
					            if c then
						            ids:append(c:getEffectiveId())
					            end
				            end
						    local card_id = room:doGongxin(player, victim, ids)
				            if (card_id == -1) then return end
						    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, player:objectName(), nil, self:objectName(), nil)
					        room:throwCard(sgs.Sanguosha:getCard(card_id), reason, victim, player)
					    end
						local judge = sgs.JudgeStruct()
			    		judge.pattern = ".|red"
			    		judge.good = true
			    		judge.play_animation = true
			    		judge.who = player
			    		judge.reason = "f_huoxin"
			    		room:judge(judge)
						if judge:isGood() then
			        		victim:gainMark("&f_meihuo")
							room:broadcastSkillInvoke("f_huoxin", 1)
						end
				    end
					return false
				elseif suit == sgs.Card_Spade then
				    local card = room:askForCard(victim, ".|spade", "@f_meihun-suit", data, sgs.Card_MethodNone)
					player:obtainCard(card)
					if not card then
				        if not victim:isKongcheng() then
					        local ids = sgs.IntList()
				            for _, c in sgs.qlist(victim:getHandcards()) do
					            if c then
						            ids:append(c:getEffectiveId())
					            end
				            end
						    local card_id = room:doGongxin(player, victim, ids)
				            if (card_id == -1) then return end
						    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, player:objectName(), nil, self:objectName(), nil)
					        room:throwCard(sgs.Sanguosha:getCard(card_id), reason, victim, player)
					    end
						local judge = sgs.JudgeStruct()
			    		judge.pattern = ".|red"
			    		judge.good = true
			    		judge.play_animation = true
			    		judge.who = player
			    		judge.reason = "f_huoxin"
			    		room:judge(judge)
						if judge:isGood() then
			        		victim:gainMark("&f_meihuo")
							room:broadcastSkillInvoke("f_huoxin", 1)
						end
				    end
					return false
				end
			end
		elseif event == sgs.TargetConfirmed then
		    local use = data:toCardUse()
			if use.card:isKindOf("Slash") and use.to:contains(player) then
			    if room:askForSkillInvoke(player, self:objectName(), data) then
			        local plist = room:getOtherPlayers(player)
				    local victim = room:askForPlayerChosen(player, plist, self:objectName())
				    if victim:isNude() then return false end
				    local suit = room:askForSuit(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName(), 2)
				    room:getThread():delay()
				    if suit == sgs.Card_Heart then
				        local card = room:askForCard(victim, ".|heart", "@f_meihun-suit", data, sgs.Card_MethodNone)
					    player:obtainCard(card)
					    if not card then
				            if not victim:isKongcheng() then
					            local ids = sgs.IntList()
				                for _, c in sgs.qlist(victim:getHandcards()) do
					                if c then
						                ids:append(c:getEffectiveId())
					                end
				                end
						        local card_id = room:doGongxin(player, victim, ids)
				                if (card_id == -1) then return end
						        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, player:objectName(), nil, self:objectName(), nil)
					            room:throwCard(sgs.Sanguosha:getCard(card_id), reason, victim, player)
					        end
							local judge = sgs.JudgeStruct()
			    			judge.pattern = ".|red"
			    			judge.good = true
			    			judge.play_animation = true
			    			judge.who = player
			    			judge.reason = "f_huoxin"
			    			room:judge(judge)
							if judge:isGood() then
			        			victim:gainMark("&f_meihuo")
								room:broadcastSkillInvoke("f_huoxin", 1)
							end
				        end
					    return false
				    elseif suit == sgs.Card_Diamond then
				        local card = room:askForCard(victim, ".|diamond", "@f_meihun-suit", data, sgs.Card_MethodNone)
					    player:obtainCard(card)
					    if not card then
				            if not victim:isKongcheng() then
					            local ids = sgs.IntList()
				                for _, c in sgs.qlist(victim:getHandcards()) do
					                if c then
						                ids:append(c:getEffectiveId())
					                end
				                end
						        local card_id = room:doGongxin(player, victim, ids)
				                if (card_id == -1) then return end
						        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, player:objectName(), nil, self:objectName(), nil)
					            room:throwCard(sgs.Sanguosha:getCard(card_id), reason, victim, player)
					        end
							local judge = sgs.JudgeStruct()
			    			judge.pattern = ".|red"
			    			judge.good = true
			    			judge.play_animation = true
			    			judge.who = player
			    			judge.reason = "f_huoxin"
			    			room:judge(judge)
							if judge:isGood() then
			        			victim:gainMark("&f_meihuo")
								room:broadcastSkillInvoke("f_huoxin", 1)
							end
				        end
					    return false
				    elseif suit == sgs.Card_Club then
				        local card = room:askForCard(victim, ".|club", "@f_meihun-suit", data, sgs.Card_MethodNone)
					    player:obtainCard(card)
					    if not card then
				            if not victim:isKongcheng() then
					            local ids = sgs.IntList()
				                for _, c in sgs.qlist(victim:getHandcards()) do
					                if c then
						                ids:append(c:getEffectiveId())
					                end
				                end
						        local card_id = room:doGongxin(player, victim, ids)
				                if (card_id == -1) then return end
						        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, player:objectName(), nil, self:objectName(), nil)
					            room:throwCard(sgs.Sanguosha:getCard(card_id), reason, victim, player)
					        end
							local judge = sgs.JudgeStruct()
			    			judge.pattern = ".|red"
			    			judge.good = true
			    			judge.play_animation = true
			    			judge.who = player
			    			judge.reason = "f_huoxin"
			    			room:judge(judge)
							if judge:isGood() then
			        			victim:gainMark("&f_meihuo")
								room:broadcastSkillInvoke("f_huoxin", 1)
							end
				        end
					    return false
				    elseif suit == sgs.Card_Spade then
				        local card = room:askForCard(victim, ".|spade", "@f_meihun-suit", data, sgs.Card_MethodNone)
					    player:obtainCard(card)
					    if not card then
				            if not victim:isKongcheng() then
					            local ids = sgs.IntList()
				                for _, c in sgs.qlist(victim:getHandcards()) do
					                if c then
						                ids:append(c:getEffectiveId())
					                end
				                end
						        local card_id = room:doGongxin(player, victim, ids)
				                if (card_id == -1) then return end
						        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, player:objectName(), nil, self:objectName(), nil)
					            room:throwCard(sgs.Sanguosha:getCard(card_id), reason, victim, player)
					        end
							local judge = sgs.JudgeStruct()
			    			judge.pattern = ".|red"
			    			judge.good = true
			    			judge.play_animation = true
			    			judge.who = player
			    			judge.reason = "f_huoxin"
			    			room:judge(judge)
							if judge:isGood() then
			        			victim:gainMark("&f_meihuo")
								room:broadcastSkillInvoke("f_huoxin", 1)
							end
				        end
					    return false
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill(self:objectName())
	end,
}
shendiaochan_change:addSkill(f_meihun)

f_huoxinCard = sgs.CreateSkillCard{ --选择拼点牌
    name = "f_huoxinCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
	    if #targets == 2 then return false end
		return to_select:objectName() ~= sgs.Self:objectName()
	end,
	feasible = function(self, targets)
		return #targets == 2
	end,
	on_use = function(self, room, source, targets)
	    local lb = targets[1]
		local dz = targets[2]
		room:setPlayerFlag(lb, "f_huoxin_pindiantargets")
		room:setPlayerFlag(dz, "f_huoxin_pindiantargets")
		local card_id = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		if card_id then
			card_id:deleteLater()
			card_id = self
		end
		source:addToPile("f_huoxinPindianCard", card_id)
	end,
}
f_huoxin = sgs.CreateViewAsSkill{
    name = "f_huoxin",
	n = 2,
	view_filter = function(self, selected, to_select)
		if #selected == 0 then
			return not to_select:isEquipped()
		elseif #selected == 1 then
			local card = selected[1]
			if to_select:getSuit() == card:getSuit() then
				return not to_select:isEquipped()
			end
		else
			return false
		end
	end,
	view_as = function(self, cards)
	    if #cards == 2 then
			local cardA = cards[1]
			local cardB = cards[2]
			local hx = f_huoxinCard:clone()
		    hx:addSubcard(cardA)
			hx:addSubcard(cardB)
			hx:setSkillName(self:objectName())
			return hx
		end
	end,
	enabled_at_play = function(self, player)
		return player:hasSkill(self:objectName()) and player:getHandcardNum() > 1 and not player:hasUsed("#f_huoxinCard")
	end,
}
f_huoxinGPCCard = sgs.CreateSkillCard{ --给出拼点牌
    name = "f_huoxinGPCCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:hasFlag("f_huoxin_pindiantargets") and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
		targets[1]:obtainCard(self, true)
		if not source:hasFlag("f_huoxinGPC_distinguish") then
			room:setPlayerFlag(targets[1], "-f_huoxin_pindiantargets")
			room:setPlayerFlag(targets[1], "f_huoxin_pindiantargets1")
			room:setPlayerFlag(source, "f_huoxinGPC_distinguish")
		else
			room:setPlayerFlag(targets[1], "-f_huoxin_pindiantargets")
			room:setPlayerFlag(targets[1], "f_huoxin_pindiantargets2")
			room:setPlayerFlag(source, "-f_huoxinGPC_distinguish")
			for _, otr in sgs.qlist(room:getOtherPlayers(source)) do --找到先给牌的对象直接进行拼点
				if otr:hasFlag("f_huoxin_pindiantargets1") then
					room:setPlayerFlag(otr, "f_huoxin_pindiantargets1")
					room:setPlayerFlag(targets[1], "f_huoxin_pindiantargets2")
					room:broadcastSkillInvoke("f_huoxin", 2)
					otr:pindian(targets[1], "f_huoxin", nil)
					break
				end
			end
		end
	end,
}
f_huoxinGPCVS = sgs.CreateOneCardViewAsSkill{
    name = "f_huoxinGPC",
	filter_pattern =  ".|.|.|f_huoxinPindianCard",
	expand_pile = "f_huoxinPindianCard",
	view_as = function(self, originalCard)
	    local pd_card = f_huoxinGPCCard:clone()
		pd_card:addSubcard(originalCard:getId())
		return pd_card
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@f_huoxinGPC")
	end,
}
f_huoxinGPC = sgs.CreateTriggerSkill{
    name = "f_huoxinGPC",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardFinished},
	view_as_skill = f_huoxinGPCVS,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:getSkillName() == "f_huoxin" then
			room:askForUseCard(player, "@@f_huoxinGPC!", "@f_huoxinGPC-card1")
			room:askForUseCard(player, "@@f_huoxinGPC!", "@f_huoxinGPC-card2")
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_huoxin")
	end,
}
f_huoxinPindian = sgs.CreateTriggerSkill{ --拼点结算
    name = "f_huoxinPindian",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Pindian},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local pindian = data:toPindian()
		if pindian.reason == "f_huoxin" then
			local fromNumber = pindian.from_card:getNumber()
			local toNumber = pindian.to_card:getNumber()
			if fromNumber ~= toNumber then
				local winner
				local loser
				if fromNumber > toNumber then
					winner = pindian.from
					loser = pindian.to
				else
					winner = pindian.to
					loser = pindian.from
				end
				loser:gainMark("&f_meihuo")
			else
			    pindian.from:gainMark("&f_meihuo")
				pindian.to:gainMark("&f_meihuo")
			end
			room:broadcastSkillInvoke("f_huoxin", 1)
		end
	end,
	can_trigger = function(self, player)
	    return true
	end,
}
f_huoxinGetTurn = sgs.CreateTriggerSkill{
    name = "f_huoxinGetTurn",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TurnStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local sdc = room:findPlayerBySkillName("f_huoxin")
		if not sdc then return false end
		if sdc and room:askForSkillInvoke(sdc, "f_huoxin", data) then
			if not sdc:isKongcheng() then
			    local hc = sdc:getHandcardNum()
		        local card_id = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		        if card_id then
			        card_id:deleteLater()
					card_id = room:askForExchange(sdc, self:objectName(), hc, hc, false, "")
		        end
		        sdc:addToPile("f_huoxin", card_id, false)
			end
			if not player:isKongcheng() then
			    room:obtainCard(sdc, player:wholeHandCards(), false)
			end
			room:broadcastSkillInvoke("f_huoxin", 3)
			player:loseAllMarks("&f_meihuo")
			room:addPlayerMark(player, "f_huoxin_skip")
			room:addPlayerMark(sdc, "&f_huoxin_GetTurn")
			sdc:gainAnExtraTurn() --以此写法，先进行额外回合，再取消目标的回合
		end
	end,
	can_trigger = function(self, player)				
	    return player:getMark("&f_meihuo") >= 2
	end,
}
f_huoxinEndTurn = sgs.CreateTriggerSkill{
    name = "f_huoxinEndTurn",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then
			return false
		end
		local plist = room:getAlivePlayers()
		for _, dmd in sgs.qlist(plist) do
            if dmd:getMark("f_huoxin_skip") > 0 and not player:isKongcheng() then
		        room:obtainCard(dmd, player:wholeHandCards(), false)
			end
		end
		if player:getPile("f_huoxin"):length() > 0 then
		    local dummy = sgs.Sanguosha:cloneCard("slash")
		    dummy:addSubcards(player:getPile("f_huoxin"))
		    room:obtainCard(player, dummy, false)
			dummy:deleteLater()
		end
		if player:getMark("&f_huoxin_GetTurn") > 0 then
			room:removePlayerMark(player, "&f_huoxin_GetTurn")
		end
	end,
	can_trigger = function(self, player)				
	    return player:hasSkill("f_huoxin") and player:getMark("&f_huoxin_GetTurn") > 0
	end,
}
f_huooxin = sgs.CreateTriggerSkill{ --配音专用
	name = "f_huooxin",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end,
}
shendiaochan_change:addSkill(f_huoxin)
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("f_huoxinGPC") then skills:append(f_huoxinGPC) end
if not sgs.Sanguosha:getSkill("f_huoxinPindian") then skills:append(f_huoxinPindian) end
if not sgs.Sanguosha:getSkill("f_huoxinGetTurn") then skills:append(f_huoxinGetTurn) end
if not sgs.Sanguosha:getSkill("f_huoxinEndTurn") then skills:append(f_huoxinEndTurn) end
if not sgs.Sanguosha:getSkill("f_huooxin") then skills:append(f_huooxin) end

--跳过回合：
f_huoxin_skip = sgs.CreateTriggerSkill{ --没找到直接跳过回合的函数，那就自己写个跳过回合内的所有阶段的技能吧
	name = "f_huoxin_skip",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data, room)
	    if data:toPhaseChange().to == sgs.Player_Start then
			player:skip(sgs.Player_Start)
		end
		if data:toPhaseChange().to == sgs.Player_Judge then
			player:skip(sgs.Player_Judge)
		end
		if data:toPhaseChange().to == sgs.Player_Draw then
			player:skip(sgs.Player_Draw)
		end
		if data:toPhaseChange().to == sgs.Player_Play then
			player:skip(sgs.Player_Play)
		end
		if data:toPhaseChange().to == sgs.Player_Discard then
			player:skip(sgs.Player_Discard)
		end
		if data:toPhaseChange().to == sgs.Player_Finish then
			player:skip(sgs.Player_Finish)
		end
		if data:toPhaseChange().to ~= sgs.Player_NotActive then return false end
		if player:getMark("f_huoxin_skip") > 0 then
			local n = player:getMark("f_huoxin_skip")
			room:removePlayerMark(player, "f_huoxin_skip", n)
		end
	end,
	can_trigger = function(self, player)
	    return player:getMark("f_huoxin_skip") > 0
	end,
}
if not sgs.Sanguosha:getSkill("f_huoxin_skip") then skills:append(f_huoxin_skip) end

--2 神张角
f_shenzhangjiao = sgs.General(extension, "f_shenzhangjiao", "god", 4, true)

f_taiping = sgs.CreateTriggerSkill{
    name = "f_taiping",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:hasSkill(self:objectName()) and player:getPhase() == sgs.Player_Start and room:askForSkillInvoke(player, self:objectName(), data) then
		    local plist = room:getAllPlayers()
			local target = room:askForPlayerChosen(player, plist, self:objectName())
			if room:askForChoice(player, self:objectName(), "tpChain+tpRestore") == "tpChain" then
			    if not target:isChained() then
					room:setPlayerChained(target)
				end
			    room:broadcastSkillInvoke(self:objectName(), 1)
			else
			    if target:isChained() then
				    room:setPlayerChained(target)
			    end
			    if not target:faceUp() then
				    target:turnOver()
			    end
				room:broadcastSkillInvoke(self:objectName(), 2)
			end
		end
	end,
}
f_shenzhangjiao:addSkill(f_taiping)

f_yaoshuCard = sgs.CreateSkillCard{
	name = "f_yaoshuCard",
	skill_name = "f_yaoshu",
	target_fixed = false,
	filter = function(self, targets, to_select)
	    if to_select:objectName() == sgs.Self:objectName() then return false end
		return #targets < 3
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
	    room:doLightbox("f_yaoshuAnimate")
	    for _, ct in sgs.list(targets) do
			ct:turnOver()
			room:loseHp(ct, 1)
		end
		room:removePlayerMark(source, "@f_yaoshu")
		room:setPlayerFlag(source, "f_yaoshu_used")
	end,
}
f_yaoshuVS = sgs.CreateZeroCardViewAsSkill{
	name = "f_yaoshu",
	view_as = function()
		return f_yaoshuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@f_yaoshu") > 0
	end,
}
f_yaoshu = sgs.CreateTriggerSkill{
	name = "f_yaoshu",
	frequency = sgs.Skill_Limited,
	limit_mark = "@f_yaoshu",
	view_as_skill = f_yaoshuVS,
	on_trigger = function()
	end,
}
f_shenzhangjiao:addSkill(f_yaoshu)

f_luoleiCard = sgs.CreateSkillCard{
	name = "f_luoleiCard",
	skill_name = "f_luolei",
	target_fixed = false,
	filter = function(self, targets, to_select)
	    return #targets == 0
	end,
	on_use = function(self, room, source, targets)
	    room:doLightbox("f_luoleiAnimate")
		local dest = targets[1]
		if not dest:isChained() then
			room:setPlayerChained(dest)
		end
	    room:damage(sgs.DamageStruct("f_luolei", source, dest, 2, sgs.DamageStruct_Thunder))
		room:broadcastSkillInvoke("sp_guimen") --借一下鬼门的配音QVQ
		local plist = room:getOtherPlayers(dest)
		for _, ct in sgs.qlist(plist) do
			if ct:distanceTo(dest) == 1 then
				Thunder(source, ct, 1)
				room:broadcastSkillInvoke("f_luoleiYD")
			end
		end
		room:removePlayerMark(source, "@f_luolei")
		room:setPlayerFlag(source, "f_luolei_used")
	end,
}
f_luoleiVS = sgs.CreateZeroCardViewAsSkill{
	name = "f_luolei",
	view_as = function()
		return f_luoleiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@f_luolei") > 0
	end,
}
f_luolei = sgs.CreateTriggerSkill{
	name = "f_luolei",
	frequency = sgs.Skill_Limited,
	limit_mark = "@f_luolei",
	view_as_skill = f_luoleiVS,
	on_trigger = function()
	end,
}
f_luoleiYD = sgs.CreateTriggerSkill{ --配音专用
	name = "f_luoleiYD",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end,
}
f_shenzhangjiao:addSkill(f_luolei)
if not sgs.Sanguosha:getSkill("f_luoleiYD") then skills:append(f_luoleiYD) end

SZJLimitSkillSideEffect = sgs.CreateTriggerSkill{ --“妖术”和“落雷”的副作用
    name = "SZJLimitSkillSideEffect",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play then
			if player:hasSkill("f_yaoshu") and player:hasFlag("f_yaoshu_used") then
			    room:loseHp(player, 1)
			end
			if player:hasSkill("f_luolei") and player:hasFlag("f_luolei_used") then
			    room:loseMaxHp(player, 1)
			end
		end
	end,
	can_trigger = function(self, player)
	    return true
	end,
}
if not sgs.Sanguosha:getSkill("SZJLimitSkillSideEffect") then skills:append(SZJLimitSkillSideEffect) end



--

--3 神张飞
f_shenzhangfei = sgs.General(extension, "f_shenzhangfei", "god", 4, true)

f_doushenCard = sgs.CreateSkillCard{
	name = "f_doushenCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
	    room:removePlayerMark(source, "@f_doushen")
		room:setPlayerFlag(source, "f_doushenBuff")
	end,
}
f_doushenVS = sgs.CreateZeroCardViewAsSkill{
    name = "f_doushen",
	view_as = function()
		return f_doushenCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@f_doushen") > 0
	end,
}
f_doushen = sgs.CreateTriggerSkill{
	name = "f_doushen",
	frequency = sgs.Skill_Limited,
	limit_mark = "@f_doushen",
	view_as_skill = f_doushenVS,
	on_trigger = function()
	end,
}
f_doushenBuff = sgs.CreateTargetModSkill{
	name = "f_doushenBuff",
	pattern = "Card",
	residue_func = function(self, from, card, to)
		local n = 0
		if from:hasSkill("f_doushen") and from:hasFlag("f_doushenBuff") then
			n = n + 1000
		end
		return n
	end,
}
f_shenzhangfei:addSkill(f_doushen)
if not sgs.Sanguosha:getSkill("f_doushenBuff") then skills:append(f_doushenBuff) end

f_jiuwei = sgs.CreateViewAsSkill{
	name = "f_jiuwei",
	n = 1,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local analeptic = sgs.Sanguosha:cloneCard("analeptic", cards[1]:getSuit(), cards[1]:getNumber())
			analeptic:setSkillName(self:objectName())
			analeptic:addSubcard(cards[1])
			return analeptic
		end
	end,
	enabled_at_play = function(self, player)
		local newana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
		if player:isCardLimited(newana, sgs.Card_MethodUse) or player:isProhibited(player, newana) then return false end
		return player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, player, newana)
	end,
	enabled_at_response = function(self, player, pattern)
		return string.find(pattern, "analeptic")
	end,
}
f_jiuwei_getBuff = sgs.CreateTriggerSkill{
    name = "f_jiuwei_getBuff",
	global = true,
	frequency = sgs.Skill_Compulsory,
    events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local card = nil
		if player:hasSkill("f_jiuwei") and player:getPhase() == sgs.Player_Play then
			local use = data:toCardUse()
		    if use.card and use.card:isKindOf("Analeptic") then
			    room:broadcastSkillInvoke("f_jiuwei", 1)
			    room:setPlayerFlag(player, "f_jiuwei_throwBuff")
				room:setPlayerFlag(player, "f_jiuwei_maxdistance")
			end
		end
	end,
}
f_jiuwei_DistanceBuff = sgs.CreateTargetModSkill{
	name = "f_jiuwei_DistanceBuff",
	distance_limit_func = function(self, from, card)
		if from:hasSkill("f_jiuwei") and card:isKindOf("Slash") and from:hasFlag("f_jiuwei_maxdistance") then
		    return 1000
		else
		    return 0
		end
	end,
}
f_jiuwei_removeflag = sgs.CreateTriggerSkill{
    name = "f_jiuwei_removeflag",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") and use.from:objectName() == player:objectName() and player:hasFlag("f_jiuwei_maxdistance") then
		    room:setPlayerFlag(player, "-f_jiuwei_maxdistance")
		end
	end,
	can_trigger = function(self, player)
	    return true
	end,
}
f_jiuwei_DamageBuff = sgs.CreateTriggerSkill{
	name = "f_jiuwei_DamageBuff",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:hasSkill("f_jiuwei") then
			local damage = data:toDamage()
			local card = damage.card
			if card then
				if card:hasFlag("drank") then
				    room:broadcastSkillInvoke("f_jiuwei", 2)
				    local log = sgs.LogMessage()
				    log.type = "$f_jiuwei_Damage"
				    log.from = player
				    room:sendLog(log)
					local xiahoujie = damage.damage
					damage.damage = xiahoujie + 1
					data:setValue(damage)
					player:setFlags("-f_jiuwei_throwBuff")
				end
			end
	    end
    end,
}
f_jiuwei_throwBuff = sgs.CreateTriggerSkill{
	name = "f_jiuwei_throwBuff",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.SlashMissed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local effect = data:toSlashEffect()
		if effect.to:isAlive() and player:canDiscard(effect.to, "he") then
		    room:broadcastSkillInvoke("f_jiuwei", 3)
			local log = sgs.LogMessage()
		    log.type = "$f_jiuwei_Miss"
		    log.from = player
		    room:sendLog(log)
			local to_throw = room:askForCardChosen(player, effect.to, "he", "f_jiuwei", false, sgs.Card_MethodDiscard)
			room:throwCard(sgs.Sanguosha:getCard(to_throw), effect.to, player)
			player:setFlags("-f_jiuwei_throwBuff")
		else
		    --保险的一步，确保一定得用酒【杀】才能有此效果
			player:setFlags("-f_jiuwei_throwBuff")
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_jiuwei") and player:hasFlag("f_jiuwei_throwBuff")
	end,
}
f_shenzhangfei:addSkill(f_jiuwei)
if not sgs.Sanguosha:getSkill("f_jiuwei_getBuff") then skills:append(f_jiuwei_getBuff) end
if not sgs.Sanguosha:getSkill("f_jiuwei_DistanceBuff") then skills:append(f_jiuwei_DistanceBuff) end
if not sgs.Sanguosha:getSkill("f_jiuwei_removeflag") then skills:append(f_jiuwei_removeflag) end
if not sgs.Sanguosha:getSkill("f_jiuwei_DamageBuff") then skills:append(f_jiuwei_DamageBuff) end
if not sgs.Sanguosha:getSkill("f_jiuwei_throwBuff") then skills:append(f_jiuwei_throwBuff) end

--

--4 神马超
f_shenmachao = sgs.General(extension, "f_shenmachao", "god", 4, true)

f_shenqi = sgs.CreateDistanceSkill{ --马术加强版
	name = "f_shenqi",
	correct_func = function(self, from)
		if from:hasSkill(self:objectName()) then
			return -2
		else
			return 0
		end
	end,
}
f_shenmachao:addSkill(f_shenqi)

f_shenlinCard = sgs.CreateSkillCard{
	name = "f_shenlinCard",
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		effect.from:setFlags("f_shenlinSource")
		effect.to:setFlags("f_shenlinTarget")
		room:addPlayerMark(effect.to, "@skill_invalidity")
		room:addPlayerMark(effect.to, "Armor_Nullified")
	end,
}
f_shenlin = sgs.CreateViewAsSkill{
	name = "f_shenlin",
	n = 1,
	view_filter = function(self, selected, to_select)
	    return not to_select:isKindOf("BasicCard")
	end,
    view_as = function(self, cards)
	    if #cards == 0 then return end
		local vs_card = f_shenlinCard:clone()
		vs_card:addSubcard(cards[1])
		return vs_card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#f_shenlinCard")
	end,
}
f_shenlin_Clear = sgs.CreateTriggerSkill{
	name = "f_shenlin_Clear",
	global = true,
	events = {sgs.EventPhaseChanging, sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
		end
		if event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then
				return false
			end
		end
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasFlag("f_shenlinTarget") then
				p:setFlags("-f_shenlinTarget")
				if p:getMark("@skill_invalidity") then
					room:removePlayerMark(p, "@skill_invalidity")
				end
				if p:getMark("Armor_Nullified") then
					room:removePlayerMark(p, "Armor_Nullified")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasFlag("f_shenlinSource")
	end,
}
f_shenmachao:addSkill(f_shenlin)
if not sgs.Sanguosha:getSkill("f_shenlin_Clear") then skills:append(f_shenlin_Clear) end

f_shennuCard = sgs.CreateSkillCard{
    name = "f_shennuCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
	    room:damage(sgs.DamageStruct("f_shennu", source, source, 1, sgs.DamageStruct_Normal))
		room:drawCards(source, 1, "f_shennu")
	    room:setPlayerFlag(source, "shenzhinuhuo")
		room:broadcastSkillInvoke("f_shennu")
	end,
}
f_shennu = sgs.CreateZeroCardViewAsSkill{
    name = "f_shennu",
	view_as = function()
		return f_shennuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#f_shennuCard")
	end,
}
f_shenmachao:addSkill(f_shennu)
--来感受神之怒火吧！
Table2IntList = function(theTable)
	local result = sgs.IntList()
	for i = 1, #theTable, 1 do
		result:append(theTable[i])
	end
	return result
end
f_shennu_youcantjink = sgs.CreateTriggerSkill{
    name = "f_shennu_youcantjink",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecified},
	on_trigger = function(self, event, player, data)
		if event == sgs.TargetSpecified then
		    local use = data:toCardUse()
		    if use.card:isKindOf("Slash") then
		        local jink_table = sgs.QList2Table(player:getTag("Jink_" .. use.card:toString()):toIntList())
			    local index = 1
			    for _, p in sgs.qlist(use.to) do
		            local _data = sgs.QVariant()
			        _data:setValue(p)
				    jink_table[index] = 0
				    index = index + 1
				end
				local jink_data = sgs.QVariant()
			    jink_data:setValue(Table2IntList(jink_table))
			    player:setTag("Jink_" .. use.card:toString(), jink_data)
			    return false
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasFlag("shenzhinuhuo")
	end,
}
f_shennu_slashmore = sgs.CreateTargetModSkill{
	name = "f_shennu_slashmore",
	global = true,
	frequency = sgs.Skill_Compulsory,
	residue_func = function(self, player, card)
		if player:hasFlag("shenzhinuhuo") and card:isKindOf("Slash") then
			return 1
		else
			return 0
		end
	end,
}
f_shennu_caozeijianzeiezeinizei = sgs.CreateTriggerSkill{
	name = "f_shennu_caozeijianzeiezeinizei",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local card = damage.card
		local doublefuck = damage.to
		if card:isKindOf("Slash") then
			local caozei = damage.damage
			if card:isRed() and doublefuck:hasFlag("suodingcaozei") then
			    room:sendCompulsoryTriggerLog(player, "f_shennu")
			    damage.damage = caozei + 2
				data:setValue(damage)
				room:setPlayerFlag(doublefuck, "-suodingcaozei")
			elseif card:isRed() and not doublefuck:hasFlag("suodingcaozei") then
			    room:sendCompulsoryTriggerLog(player, "f_shennu")
			    damage.damage = caozei + 1
				data:setValue(damage)
			elseif not card:isRed() and doublefuck:hasFlag("suodingcaozei") then
			    room:sendCompulsoryTriggerLog(player, "f_shennu")
			    damage.damage = caozei + 1
				data:setValue(damage)
				room:setPlayerFlag(doublefuck, "-suodingcaozei")
			end
        end
	end,
	can_trigger = function(self, player)
	    return player:hasFlag("shenzhinuhuo")
	end,
}
f_shennu_gexuqipao = sgs.CreateTriggerSkill{
    name = "f_shennu_gexuqipao",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") then
			room:sendCompulsoryTriggerLog(player, "f_shennu")
			for _, p in sgs.qlist(use.to) do
		        local _data = sgs.QVariant()
				_data:setValue(p)
				if not p:isNude() then
		            room:askForDiscard(p, "@f_shennu_gexuqipao", 1, 1, false, true)
				else
				    room:setPlayerFlag(p, "suodingcaozei")
				end
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasFlag("shenzhinuhuo")
	end,
}
if not sgs.Sanguosha:getSkill("f_shennu_youcantjink") then skills:append(f_shennu_youcantjink) end
if not sgs.Sanguosha:getSkill("f_shennu_slashmore") then skills:append(f_shennu_slashmore) end
if not sgs.Sanguosha:getSkill("f_shennu_caozeijianzeiezeinizei") then skills:append(f_shennu_caozeijianzeiezeinizei) end
if not sgs.Sanguosha:getSkill("f_shennu_gexuqipao") then skills:append(f_shennu_gexuqipao) end

local function isSpecialOne(player, name)
	local g_name = sgs.Sanguosha:translate(player:getGeneralName())
	if string.find(g_name, name) then return true end
	if player:getGeneral2() then
		g_name = sgs.Sanguosha:translate(player:getGeneral2Name())
		if string.find(g_name, name) then return true end
	end
	return false
end
f_caohen = sgs.CreateTriggerSkill{
	name = "f_caohen",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local caocao = damage.to
		if isSpecialOne(caocao, "曹操") or (caocao:getKingdom() == "wei" and caocao:isLord()) then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			local caocaosima = damage.damage
			damage.damage = caocaosima + 1
			data:setValue(damage)
			room:broadcastSkillInvoke(self:objectName())
		end
	end,
}
f_shenmachao:addSkill(f_caohen)

--5 神姜维
f_shenjiangwei = sgs.General(extension, "f_shenjiangwei", "god", 7, true, false, false, 4)

f_beifaCard = sgs.CreateSkillCard{
	name = "f_beifaCard",
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		room:acquireSkill(effect.from, "mobiletiaoxin")
		effect.from:gainMark("&Xing")
		effect.from:setFlags("f_beifaSource")
		effect.to:setFlags("f_beifaTarget")
		room:addPlayerMark(effect.to, "@skill_invalidity")
	end,
}
f_beifa = sgs.CreateViewAsSkill{
	name = "f_beifa",
	n = 1,
	view_filter = function(self, selected, to_select)
	    return true
	end,
    view_as = function(self, cards)
	    if #cards == 0 then return end
		local vs_card = f_beifaCard:clone()
		vs_card:addSubcard(cards[1])
		return vs_card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#f_beifaCard")
	end,
}
f_beifa_Clear = sgs.CreateTriggerSkill{
	name = "f_beifa_Clear",
	global = true,
	events = {sgs.EventPhaseChanging, sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
		end
		if event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then
				return false
			end
		end
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasFlag("f_beifaTarget") then
				p:setFlags("-f_beifaTarget")
				if p:getMark("@skill_invalidity") then
					room:removePlayerMark(p, "@skill_invalidity")
				end
			end
		end
		room:detachSkillFromPlayer(player, "mobiletiaoxin", false, true)
	end,
	can_trigger = function(self, player)
		return player:hasFlag("f_beifaSource")
	end,
}
f_shenjiangwei:addSkill(f_beifa)
if not sgs.Sanguosha:getSkill("f_beifa_Clear") then skills:append(f_beifa_Clear) end

f_fuzhi_Trigger = sgs.CreateTriggerSkill{
    name = "f_fuzhi_Trigger",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damage, sgs.Damaged},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local damage = data:toDamage()
		room:sendCompulsoryTriggerLog(player, "f_fuzhi")
		player:gainMark("&Xing", damage.damage)
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_fuzhi")
	end,
}
f_fuzhi = sgs.CreateTriggerSkill{
    name = "f_fuzhi",
	priority = 6, --设置优先级在“志继”之前
	frequency = sgs.Skill_Wake,
	waked_skills = "olzhiji_sjwUse, fz_zhiyong, fz_mouxing",
	events = {sgs.EventPhaseStart},
	can_wake = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start and player:getPhase() ~= sgs.Player_Finish then return false end
		if player:getMark("@WAKEDD") > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getMark("&Xing") < 3 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		room:doLightbox("$f_fuzhi")
		room:loseMaxHp(player, 1)
		if not player:hasSkill("olzhiji_sjwUse") then
		    room:acquireSkill(player, "olzhiji_sjwUse")
		end
		if not player:hasSkill("fz_zhiyong") then
		    room:acquireSkill(player, "fz_zhiyong")
		end
		if not player:hasSkill("fz_mouxing") then
		    room:acquireSkill(player, "fz_mouxing")
		end
		player:gainMark("@WAKEDD") --大觉醒标记
	end,
	can_trigger = function(self, player)
	    return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
f_shenjiangwei:addSkill(f_fuzhi)
f_shenjiangwei:addRelateSkill("olzhiji_sjwUse")
f_shenjiangwei:addRelateSkill("fz_zhiyong")
f_shenjiangwei:addRelateSkill("fz_mouxing")
if not sgs.Sanguosha:getSkill("f_fuzhi_Trigger") then skills:append(f_fuzhi_Trigger) end
--☆“志继”（20220124版本的OL界志继源码有结束阶段不能触发觉醒的BUG，这里自己写一个供神姜维使用）
olzhiji_sjwUse = sgs.CreateTriggerSkill{
	name = "olzhiji_sjwUse",
	priority = 5, --设置优先级在地主技能“跋扈”之前
	frequency = sgs.Skill_Wake,
	waked_skills = "tenyearguanxing",
	events = {sgs.EventPhaseStart},
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start and player:getPhase() ~= sgs.Player_Finish then return false end
		if player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if not player:isKongcheng() then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke("olzhiji")
		room:doSuperLightbox("f_shenjiangwei", "olzhiji_sjwUse")
		if player:isWounded() then
			if room:askForChoice(player, self:objectName(), "recover+draw") == "recover" then
				local recover = sgs.RecoverStruct()
				recover.who = player
				room:recover(player, recover)
			else
				room:drawCards(player, 2, self:objectName())
			end
		else
			room:drawCards(player, 2, self:objectName())
		end
		room:addPlayerMark(player, self:objectName())
		if room:changeMaxHpForAwakenSkill(player) then
			room:acquireSkill(player, "tenyearguanxing")
		end
	end,
	can_trigger = function(self, player)
	    return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
if not sgs.Sanguosha:getSkill("olzhiji_sjwUse") then skills:append(olzhiji_sjwUse) end
f_shenjiangwei:addRelateSkill("tenyearguanxing")
--☆“智勇”
fz_zhiyong = sgs.CreateTriggerSkill{
    name = "fz_zhiyong",
	frequency = sgs.Skill_Wake,
	waked_skills = "olkanpo, ollongdan",
	events = {sgs.EventPhaseStart},
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if not player:isWounded() then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:doLightbox("$fz_zhiyong")
	    room:broadcastSkillInvoke(self:objectName())
		room:loseMaxHp(player, 1)
		local recover = sgs.RecoverStruct()
		recover.recover = 1
		recover.who = player
		room:recover(player, recover)
		room:drawCards(player, 1, self:objectName())
		if not player:hasSkill("olkanpo") then
		    room:acquireSkill(player, "olkanpo")
		end
		if not player:hasSkill("ollongdan") then
		    room:acquireSkill(player, "ollongdan")
		end
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
	end,
	can_trigger = function(self, player)
	    return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
if not sgs.Sanguosha:getSkill("fz_zhiyong") then skills:append(fz_zhiyong) end
f_shenjiangwei:addRelateSkill("olkanpo")
f_shenjiangwei:addRelateSkill("ollongdan")
--☆“谋兴”
mouxingDying = sgs.CreateTriggerSkill{
    name = "mouxingDying",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EnterDying},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:addPlayerMark(player, "mouxingDying")
	end,
	can_trigger = function(self, player)
	    return player:isAlive() and player:getMark("mouxingDying") == 0
	end,
}
fz_mouxing = sgs.CreateTriggerSkill{
    name = "fz_mouxing",
	frequency = sgs.Skill_Wake,
	waked_skills = "mx_xinghan, mx_hanhun",
	events = {sgs.EventPhaseStart},
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getMark("mouxingDying") < 1 and player:getMark("&Xing") < 12 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:doLightbox("$fz_mouxing")
		room:broadcastSkillInvoke(self:objectName())
        room:loseMaxHp(player, 1)
		room:drawCards(player, 3, self:objectName())
		if not player:hasSkill("mx_xinghan") then
		    room:acquireSkill(player, "mx_xinghan")
		end
		if not player:hasSkill("mx_hanhun") then
		    room:acquireSkill(player, "mx_hanhun")
		end
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
	end,
	can_trigger = function(self, player)
	    return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
if not sgs.Sanguosha:getSkill("mouxingDying") then skills:append(mouxingDying) end
if not sgs.Sanguosha:getSkill("fz_mouxing") then skills:append(fz_mouxing) end
f_shenjiangwei:addRelateSkill("mx_xinghan")
f_shenjiangwei:addRelateSkill("mx_hanhun")
  --“兴汉”
mx_xinghanCard = sgs.CreateSkillCard{
    name = "mx_xinghanCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
	    local num = source:getMark("&Xing")
        if num >= 1 then
		    if source:getMark("xinghan_skillget") == 0 then
			    room:addPlayerMark(source, "xinghan_skillget")
			end
		    local choices = {}
			if not source:hasSkill("tenyearrende") then
			    table.insert(choices, "addskill_rende")
			end
			if not source:hasSkill("kongcheng") then
			    table.insert(choices, "addskill_kongcheng")
			end
			if not source:hasSkill("tenyearwusheng") then
			    table.insert(choices, "addskill_wusheng")
			end
			if not source:hasSkill("olpaoxiao") then
			    table.insert(choices, "addskill_paoxiao")
			end
			if not source:hasSkill("olyajiao") then
			    table.insert(choices, "addskill_yajiao")
			end
			if not source:hasSkill("tenyearliegong") then
			    table.insert(choices, "addskill_liegong")
			end
			if not source:hasSkill("tieji") then
			    table.insert(choices, "addskill_tieqi")
			end
			table.insert(choices, "cancel")
			local choice = room:askForChoice(source, "mx_xinghan", table.concat(choices, "+"))
			if choice == "addskill_rende" then
			    room:broadcastSkillInvoke("mx_xinghan")
				room:acquireSkill(source, "tenyearrende")
				source:loseMark("&Xing")
			elseif choice == "addskill_kongcheng" then
			    room:broadcastSkillInvoke("mx_xinghan")
				room:acquireSkill(source, "kongcheng")
				source:loseMark("&Xing")
			elseif choice == "addskill_wusheng" then
			    room:broadcastSkillInvoke("mx_xinghan")
				room:acquireSkill(source, "tenyearwusheng")
				source:loseMark("&Xing")
			elseif choice == "addskill_paoxiao" then
			    room:broadcastSkillInvoke("mx_xinghan")
				room:acquireSkill(source, "olpaoxiao")
				source:loseMark("&Xing")
			elseif choice == "addskill_yajiao" then
			    room:broadcastSkillInvoke("mx_xinghan")
				room:acquireSkill(source, "olyajiao")
				source:loseMark("&Xing")
			elseif choice == "addskill_liegong" then
			    room:broadcastSkillInvoke("mx_xinghan")
				room:acquireSkill(source, "tenyearliegong")
				source:loseMark("&Xing")
			elseif choice == "addskill_tieqi" then
			    room:broadcastSkillInvoke("mx_xinghan")
				room:acquireSkill(source, "tieji")
				source:loseMark("&Xing")
			elseif choice == "cancel" then
			    if source:getMark("xinghan_skillget") > 0 then
				    room:removePlayerMark(source, "xinghan_skillget")
				end
			end
		end
	end,
}
mx_xinghan = sgs.CreateZeroCardViewAsSkill{
    name = "mx_xinghan",
	view_as = function()
		return mx_xinghanCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("&Xing") >= 1
	end,
}
mx_xinghan_SkillClear = sgs.CreateTriggerSkill{
	name = "mx_xinghan_SkillClear",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TurnStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:hasSkill("tenyearrende") then
		    room:detachSkillFromPlayer(player, "tenyearrende", false, true)
		end
		if player:hasSkill("kongcheng") then
		    room:detachSkillFromPlayer(player, "kongcheng", false, true)
		end
		if player:hasSkill("tenyearwusheng") then
		    room:detachSkillFromPlayer(player, "tenyearwusheng", false, true)
		end
		if player:hasSkill("olpaoxiao") then
		    room:detachSkillFromPlayer(player, "olpaoxiao", false, true)
		end
		if player:hasSkill("olyajiao") then
		    room:detachSkillFromPlayer(player, "olyajiao", false, true)
		end
		if player:hasSkill("tenyearliegong") then
		    room:detachSkillFromPlayer(player, "tenyearliegong", false, true)
		end
		if player:hasSkill("tieji") then
		    room:detachSkillFromPlayer(player, "tieji", false, true)
		end
		room:removePlayerMark(player, "xinghan_skillget")
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("mx_xinghan") and player:getMark("xinghan_skillget") >= 1
	end,
}
if not sgs.Sanguosha:getSkill("mx_xinghan") then skills:append(mx_xinghan) end
if not sgs.Sanguosha:getSkill("mx_xinghan_SkillClear") then skills:append(mx_xinghan_SkillClear) end
  --“汉魂”
mx_hanhunCard = sgs.CreateSkillCard{
	name = "mx_hanhunCard",
	will_throw = true,
	target_fixed = false,
	 filter = function(self, targets, to_select)
	    return #targets == 0 and (not to_select:isLord())
	end,
	on_use = function(self, room, source, targets)
	    room:doLightbox("$mx_hanhun")
		room:removePlayerMark(source, "@mx_hanhun")
		room:loseHp(source, 1)
		local hanhun = targets[1]
        room:addPlayerMark(hanhun, "@ZhanDouXuXing")
		if source:getMark("@ZhanDouXuXing") == 0 then
		    room:killPlayer(source)
		end
	end,
}
mx_hanhunVS = sgs.CreateViewAsSkill{
	name = "mx_hanhun",
	n = 3,
	view_filter = function(self, selected, to_select)
	    if #selected == 0 then
			return not to_select:isEquipped()
		elseif #selected == 1 then
			local card = selected[1]
			if to_select:getTypeId() ~= card:getTypeId() then
				return not to_select:isEquipped()
			end
		elseif #selected == 2 then
		    local card1 = selected[1]
			local card2 = selected[2]
			if to_select:getTypeId() ~= card1:getTypeId() and to_select:getTypeId() ~= card2:getTypeId() then
				return not to_select:isEquipped()
			end
		else
			return false
		end
	end,
	view_as = function(self, cards)
	    if #cards == 3 then
			local cardA = cards[1]
			local cardB = cards[2]
			local cardC = cards[3]
			local hh = mx_hanhunCard:clone()
		    hh:addSubcard(cardA)
			hh:addSubcard(cardB)
			hh:addSubcard(cardC)
			hh:setSkillName(self:objectName())
			return hh
		end
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@mx_hanhun") > 0
	end,
}
mx_hanhun = sgs.CreateTriggerSkill{
	name = "mx_hanhun",
	frequency = sgs.Skill_Limited,
	limit_mark = "@mx_hanhun",
	view_as_skill = mx_hanhunVS,
	on_trigger = function()
	end,
}
f_hanhunRevive = sgs.CreateTriggerSkill{
    name = "f_hanhunRevive",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local death = data:toDeath()
		local hanhun = death.who
		if hanhun:getMark("@ZhanDouXuXing") > 0 and hanhun:getMaxHp() > 0 then
		    room:sendCompulsoryTriggerLog(player, "mx_hanhun")
			local m = hanhun:getHp()
		    room:revivePlayer(hanhun)
			local n = hanhun:getMaxHp()
			local rec = sgs.RecoverStruct()
			rec.who = hanhun
			rec.recover = n - m
			room:recover(hanhun, rec)
			room:broadcastSkillInvoke(self:objectName())
			room:removePlayerMark(hanhun, "@ZhanDouXuXing")
			room:drawCards(hanhun, 4, "mx_hanhun")
	    	room:setPlayerProperty(hanhun, "kingdom", sgs.QVariant("shu"))
			room:acquireSkill(hanhun, "f_hunsan")
		end
	end,
	can_trigger = function(self, player)
	    return player:getMark("@ZhanDouXuXing") > 0
	end,
}
    --“魂散”
f_hunsan = sgs.CreateTriggerSkill{
    name = "f_hunsan",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
	    if player:getPhase() == sgs.Player_Finish then
		    room:sendCompulsoryTriggerLog(player, self:objectName())
		    room:loseHp(player, 1)
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_hunsan")
	end,
}
if not sgs.Sanguosha:getSkill("mx_hanhun") then skills:append(mx_hanhun) end
if not sgs.Sanguosha:getSkill("f_hanhunRevive") then skills:append(f_hanhunRevive) end
if not sgs.Sanguosha:getSkill("f_hunsan") then skills:append(f_hunsan) end

--6 神邓艾
f_shendengai = sgs.General(extension, "f_shendengai", "god", 6, true, false, false, 2)

f_zhiqu = sgs.CreateTargetModSkill{
	name = "f_zhiqu",
	global = true,
	pattern = "Card",
	distance_limit_func = function(self, from, card)
		if from:getMark("&mark_zhanshan") > 0 and from:hasFlag("f_zhiqu_blackBuff") and card:isBlack() then
			return 1000
		else
			return 0
		end
	end,
}
f_zhiquu = sgs.CreateTriggerSkill{
	name = "f_zhiquu",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart, sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Play and player:getMark("&mark_zhanshan") > 0 then
		    room:setPlayerFlag(player, "f_zhiqu_blackBuff")
		else
		    if room:getCurrent():objectName() == player:objectName() and player:getMark("&mark_zhanshan") > 0 then
		        local use = data:toCardUse()
				local di = room:findPlayerBySkillName("f_zhiqu")
			    if not di then return false end
				if not use.card then return false end
				if use.card:isBlack() then
				    room:sendCompulsoryTriggerLog(di, "f_zhiqu")
			        room:broadcastSkillInvoke("f_zhiqu", 1)
				elseif use.card:isRed() then
				    room:sendCompulsoryTriggerLog(di, "f_zhiqu")
			        room:drawCards(player, 1, "f_zhiqu")
				    room:broadcastSkillInvoke("f_zhiqu", 2)
				end
			end
		end
	end,
	can_trigger = function(self, player)
	    return player and player:getMark("&mark_zhanshan") > 0
	end,
}
f_shendengai:addSkill(f_zhiqu)
if not sgs.Sanguosha:getSkill("f_zhiquu") then skills:append(f_zhiquu) end

f_zhanshan_GMS = sgs.CreateTriggerSkill{
    name = "f_zhanshan_GMS",
	global = true,
	priority = 10,
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawInitialCards}, --时机：分发起始手牌时
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:hasSkill("f_zhanshan") then
		    data:setValue(data:toInt() + 2)
			local count = room:alivePlayerCount()
		    player:gainMark("&mark_zhanshan", count)
		    room:broadcastSkillInvoke("f_zhanshan", 1)
		    room:sendCompulsoryTriggerLog(player, "f_zhanshan")
		end
	end,
}
f_zhanshan_Trigger = sgs.CreateTriggerSkill{
    name = "f_zhanshan_Trigger",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:hasSkill("f_zhanshan") and player:getPhase() == sgs.Player_Start and player:getMark("&mark_zhanshan") == 0 and room:askForSkillInvoke(player, self:objectName(), data) then
				room:loseMaxHp(player, 1)
			    player:gainMark("&mark_zhanshan")
				room:broadcastSkillInvoke("f_zhanshan", 2)
			end
		elseif event == sgs.Death then
		    local di = room:findPlayersBySkillName("f_zhanshan")
			if not di then return false end
		    local death = data:toDeath()
		    if death.who:objectName() == player:objectName() then return false end
            for _, p in sgs.qlist(di) do
			    if room:askForSkillInvoke(p, self:objectName(), data) then
                    p:gainMark("&mark_zhanshan")
                    room:broadcastSkillInvoke("f_zhanshan", 3)
				end
            end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_zhanshan")
	end,
}
f_zhanshanCard = sgs.CreateSkillCard{
    name = "f_zhanshanCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
	    return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
	    local num = source:getMark("&mark_zhanshan")
        if num >= 1 then
		    room:broadcastSkillInvoke("f_zhanshan", 4)
		    source:loseMark("&mark_zhanshan")
			local weibing = targets[1]
			weibing:gainMark("&mark_zhanshan")
		end
	end,
}
f_zhanshan = sgs.CreateZeroCardViewAsSkill{
    name = "f_zhanshan",
	view_as = function()
	    return f_zhanshanCard:clone()
	end,
	enabled_at_play = function(self, player)
	    return player:hasSkill(self:objectName()) and player:getMark("&mark_zhanshan") >= 1
	end,
}
f_zhanshanbuff = sgs.CreateTriggerSkill{
    name = "f_zhanshanbuff",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local damage = data:toDamage()
		if damage.nature == sgs.DamageStruct_Normal and damage.to:getMark("&mark_zhanshan") > 0 then
		    room:broadcastSkillInvoke("f_zhanshan", 5)
			player:loseMark("&mark_zhanshan")
		    return damage.damage
		end
	end,
	can_trigger = function(self, player)
		return player ~= nil and player:getMark("&mark_zhanshan") > 0
	end,
}
f_shendengai:addSkill(f_zhanshan)
if not sgs.Sanguosha:getSkill("f_zhanshan_GMS") then skills:append(f_zhanshan_GMS) end
if not sgs.Sanguosha:getSkill("f_zhanshan_Trigger") then skills:append(f_zhanshan_Trigger) end
if not sgs.Sanguosha:getSkill("f_zhanshanbuff") then skills:append(f_zhanshanbuff) end

--7 <汉中王>神刘备
hzw_shenliubei = sgs.General(extension, "hzw_shenliubei$", "god", 5, true, false, false, 3)

f_jieyiCard = sgs.CreateSkillCard{
	name = "f_jieyiCard",
	skill_name = "f_jieyi",
	target_fixed = false,
	filter = function(self, targets, to_select)
	    if to_select:objectName() == sgs.Self:objectName() then return false end
		return #targets < 2
	end,
	feasible = function(self, targets)
		return #targets == 2
	end,
	on_use = function(self, room, source, targets)
	    room:doLightbox("f_jieyiAnimate")
		local guanyu = targets[1]
		local zhangfei = targets[2]
		room:addPlayerMark(source, "&XD")
		room:addPlayerMark(guanyu, "&XD")
		room:addPlayerMark(zhangfei, "&XD")
		if not source:hasSkill("jy_yizhi") then
		    room:acquireSkill(source, "jy_yizhi")
		end
		if not guanyu:hasSkill("jy_yizhi") then
		    room:acquireSkill(guanyu, "jy_yizhi")
		end
		if not zhangfei:hasSkill("jy_yizhi") then
		    room:acquireSkill(zhangfei, "jy_yizhi")
		end
		room:removePlayerMark(source, "@f_jieyi")
		--room:broadcastSkillInvoke("f_jieyi")
	end,
}
f_jieyiVS = sgs.CreateZeroCardViewAsSkill{
	name = "f_jieyi",
	view_as = function()
		return f_jieyiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@f_jieyi") > 0
	end,
}
f_jieyi = sgs.CreateTriggerSkill{
	name = "f_jieyi",
	frequency = sgs.Skill_Limited,
	limit_mark = "@f_jieyi",
	view_as_skill = f_jieyiVS,
	on_trigger = function()
	end,
}
hzw_shenliubei:addSkill(f_jieyi)
jy_yizhi = sgs.CreateTriggerSkill{ --为了符合“义志”的“全局生效”而做出的空壳
	name = "jy_yizhi",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end,
}
yizhiDraw = sgs.CreateTriggerSkill{
	name = "yizhiDraw",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local count = data:toInt() + 1
		data:setValue(count)
	end,
	can_trigger = function(self, player)
	    return player:getMark("&XD") > 0
	end,
}
yizhiLoyalCard = sgs.CreateSkillCard{
    name = "yizhiLoyalCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
	    return #targets == 0 and to_select:getMark("&XD") > 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
	    targets[1]:obtainCard(self, false)
		room:broadcastSkillInvoke("jy_yizhi")
	end,
}
yizhiLoyalVS = sgs.CreateViewAsSkill{
    name = "yizhiLoyal",
	n = 1,
	view_filter = function(self, selected, to_select)
	    return true
	end,
    view_as = function(self, cards)
	    if #cards == 0 then return end
		local vs_card = yizhiLoyalCard:clone()
		vs_card:addSubcard(cards[1])
		return vs_card
	end,
	response_pattern = "@@yizhiLoyal",
}
yizhiLoyal = sgs.CreateTriggerSkill{
    name = "yizhiLoyal",
	global = true,
	events = {sgs.EventPhaseEnd},
	view_as_skill = yizhiLoyalVS,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() == sgs.Player_Draw then
		    room:askForUseCard(player, "@@yizhiLoyal", "@yizhiLoyal-card1")
		    room:askForUseCard(player, "@@yizhiLoyal", "@yizhiLoyal-card2")
		end
	end,
	can_trigger = function(self, player)
	    return player:getMark("&XD") > 0
	end,
}
yizhiRescue = sgs.CreateTriggerSkill{
    name = "yizhiRescue",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreHpRecover},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local rec = data:toRecover()
		if rec.card:isKindOf("Peach") and rec.who:getMark("&XD") > 0 and rec.who:objectName() ~= player:objectName() then
			local log = sgs.LogMessage()
			log.type = "$yizhiREC"
			log.from = player
			room:sendLog(log)
			rec.recover = rec.recover + 1
			data:setValue(rec)
			room:broadcastSkillInvoke("jy_yizhi")
		end
	end,
	can_trigger = function(self, player)
	    return player:getMark("&XD") > 0
	end,
}
if not sgs.Sanguosha:getSkill("jy_yizhi") then skills:append(jy_yizhi) end
if not sgs.Sanguosha:getSkill("yizhiDraw") then skills:append(yizhiDraw) end
if not sgs.Sanguosha:getSkill("yizhiLoyal") then skills:append(yizhiLoyal) end
if not sgs.Sanguosha:getSkill("yizhiRescue") then skills:append(yizhiRescue) end

f_renyiCard = sgs.CreateSkillCard{
    name = "f_renyiCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
	    room:setPlayerFlag(source, "f_renyiX_Trigger")
		room:drawCards(source, 3, "f_renyi")
	end,
}
f_renyi = sgs.CreateZeroCardViewAsSkill{
    name = "f_renyi",
	view_as = function()
		return f_renyiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#f_renyiCard")
	end,
}
f_renyiXCard = sgs.CreateSkillCard{
    name = "f_renyiXCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
	    return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
	    targets[1]:obtainCard(self, false)
		room:broadcastSkillInvoke("f_renyi", math.random(1,2))
		if targets[1]:getMark("&XD") > 0 then
		    room:addPlayerMark(targets[1], "f_renyiBUFF")
		end
		if source:isKongcheng() then
		    room:drawCards(source, 2, "f_renyi")
		end
		if source:getEquips():isEmpty() then
		    local recover = sgs.RecoverStruct()
			recover.who = source
			room:recover(source, recover)
		end
	end,
}
f_renyiXVS = sgs.CreateViewAsSkill{
    name = "f_renyiX",
	n = 6,
	view_filter = function(self, selected, to_select)
	    return true
	end,
	view_as = function(self, cards)
	    if #cards == 0 then return nil end
		local RX_card = f_renyiXCard:clone()
		for _, c in pairs(cards) do
			RX_card:addSubcard(c)
		end
		RX_card:setSkillName("f_renyi")
		return RX_card
	end,
	enabled_at_play = function(self, player)
		return player:hasSkill("f_renyi") and player:canDiscard(player, "he")
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@f_renyiX")
	end,
}
f_renyiX = sgs.CreateTriggerSkill{
    name = "f_renyiX",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime},
	view_as_skill = f_renyiXVS,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.to and move.to:objectName() == player:objectName() and player:hasFlag("f_renyiX_Trigger") then
		    room:setPlayerFlag(player, "-f_renyiX_Trigger")
		    room:askForUseCard(player, "@@f_renyiX!", "@f_renyiX-card")
			if player:getState() == "robot" and not room:askForUseCard(player, "@@f_renyiX!", "@f_renyiX-card") then --这里是为了AI
			    local jh = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName())
			    local id = room:askForCardChosen(player, player, "h", self:objectName())
			    room:obtainCard(jh, id, false)
				if jh:getMark("&XD") > 0 then
		    		room:addPlayerMark(jh, "f_renyiBUFF")
				end
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_renyi") and player:hasFlag("f_renyiX_Trigger")
	end,
}
f_renyiBuff = sgs.CreateTriggerSkill{
    name = "f_renyiBuff",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.ConfirmDamage, sgs.CardFinished},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if player:getMark("f_renyiBUFF") > 0 and damage.card:isDamageCard() then
		    	local ren = damage.damage
				local n = player:getMark("f_renyiBUFF")
				damage.damage = ren + n
				data:setValue(damage)
				room:broadcastSkillInvoke("f_renyi", 3)
				local log = sgs.LogMessage()
				log.type = "$f_renyiBufff"
				log.from = player
				log.arg2 = n
				room:sendLog(log)
				room:removePlayerMark(player, "f_renyiBUFF", n)
			end
		elseif event == sgs.CardFinished then
		    local use = data:toCardUse()
			if player:getMark("f_renyiBUFF") > 0 and use.card:isDamageCard() then
				local m = player:getMark("f_renyiBUFF")
				room:removePlayerMark(player, "f_renyiBUFF", m)
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:getMark("&XD") > 0 and player:getMark("f_renyiBUFF") > 0
	end,
}
hzw_shenliubei:addSkill(f_renyi)
if not sgs.Sanguosha:getSkill("f_renyiX") then skills:append(f_renyiX) end
if not sgs.Sanguosha:getSkill("f_renyiBuff") then skills:append(f_renyiBuff) end

f_chengwang_DamageRecord = sgs.CreateTriggerSkill{
    name = "f_chengwang_DamageRecord",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local damage = data:toDamage()
		local LiuXD = room:findPlayerBySkillName("f_chengwang")
		if not LiuXD:isLord() or LiuXD:hasSkill("bahu") then return false end
		LiuXD:gainMark("&f_chengwang_DR", damage.damage)
	end,
	can_trigger = function(self, player)
	    return player:getMark("&XD") > 0 or player:hasSkill("f_chengwang")
	end,
}
f_chengwang = sgs.CreateTriggerSkill{
    name = "f_chengwang$",
	frequency = sgs.Skill_Wake,
	waked_skills = "f_hanzhongwang",
	events = {sgs.EventPhaseStart},
	can_wake = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() == sgs.Player_NotActive or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getMark("@f_jieyi") > 0 or player:getMark("&f_chengwang_DR") < 12 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:loseMaxHp(player)
		local recover = sgs.RecoverStruct()
		recover.who = player
		room:recover(player, recover)
		room:setPlayerProperty(player, "kingdom", sgs.QVariant("shu"))
		room:broadcastSkillInvoke(self:objectName())
		room:doSuperLightbox("hzw_shenliubei", self:objectName())
		if not player:hasSkill("f_hanzhongwang") then
		    room:acquireSkill(player, "f_hanzhongwang")
		end
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
	end,
	can_trigger = function(self, player)
	    return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
hzw_shenliubei:addSkill(f_chengwang)
hzw_shenliubei:addRelateSkill("f_hanzhongwang")
if not sgs.Sanguosha:getSkill("f_chengwang_DamageRecord") then skills:append(f_chengwang_DamageRecord) end
--“汉中王”
f_hanzhongwangCard = sgs.CreateSkillCard{
    name = "f_hanzhongwangCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
	    return to_select:getKingdom() == "shu" and to_select:objectName() ~= sgs.Self:objectName() and not to_select:isAllNude()
	end,
	on_effect = function(self, effect)
	    local room = effect.from:getRoom()
		if effect.from:isAlive() and effect.to:isAlive() and not effect.to:isAllNude() then
			local card_id = room:askForCardChosen(effect.from, effect.to, "hej", "f_hanzhongwang")
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, effect.from:objectName())
			room:obtainCard(effect.from, sgs.Sanguosha:getCard(card_id), reason, false)
			room:broadcastSkillInvoke("f_hanzhongwang", 2)
			room:addPlayerMark(effect.to, "f_hanzhongwangBUFF")
		end
	end,
}
f_hanzhongwangVS = sgs.CreateZeroCardViewAsSkill{
    name = "f_hanzhongwang",
    view_as = function()
		return f_hanzhongwangCard:clone()
	end,
	response_pattern = "@@f_hanzhongwang",
}
f_hanzhongwang = sgs.CreateTriggerSkill{
    name = "f_hanzhongwang",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = f_hanzhongwangVS,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start and room:askForSkillInvoke(player, "@hzw_zhaomu", data) then
		    local plist1 = room:getOtherPlayers(player)
			local rencai = room:askForPlayerChosen(player, plist1, self:objectName())
			room:setPlayerProperty(rencai, "kingdom", sgs.QVariant("shu"))
			room:broadcastSkillInvoke(self:objectName(), 1)
		elseif player:getPhase() == sgs.Player_Play and room:askForSkillInvoke(player, "@hzw_haozhao", data) then
		    room:askForUseCard(player, "@@f_hanzhongwang", "@f_hanzhongwang-card")
		end
	end,
}
f_hanzhongwang_BuffandClear = sgs.CreateTriggerSkill{
    name = "f_hanzhongwang_BuffandClear",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local damage = data:toDamage()
		if event == sgs.ConfirmDamage then
		    if player:getPhase() ~= sgs.Player_NotActive and player:getMark("f_hanzhongwangBUFF") > 0 then
			    local dmg = damage.damage
				damage.damage = dmg + 1
			    data:setValue(damage)
			    room:broadcastSkillInvoke("f_hanzhongwang", 3)
			end
		elseif event == sgs.EventPhaseChanging then
		    local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			if player:isAlive() and player:getMark("f_hanzhongwangBUFF") > 0 then
			    room:removePlayerMark(player, "f_hanzhongwangBUFF")
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:getMark("f_hanzhongwangBUFF") > 0
	end,
}
if not sgs.Sanguosha:getSkill("f_hanzhongwang") then skills:append(f_hanzhongwang) end
if not sgs.Sanguosha:getSkill("f_hanzhongwang_BuffandClear") then skills:append(f_hanzhongwang_BuffandClear) end

--8 神黄忠
f_shenhuangzhong = sgs.General(extension, "f_shenhuangzhong", "god", 4, true)

f_shengong = sgs.CreateTriggerSkill{
    name = "f_shengong",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:sendCompulsoryTriggerLog(player, self:objectName())
		room:drawCards(player, 10, self:objectName())
		room:broadcastSkillInvoke(self:objectName(), 1)
		if not player:isKongcheng() then
		    local card_id = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		        if card_id then
				card_id:deleteLater()
			    card_id = room:askForExchange(player, self:objectName(), 10, 10, false, "f_shengongPush")
			end
			player:addToPile("ShenJian", card_id)
			room:addPlayerMark(player, "f_shengong_triggered")
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill(self:objectName()) and player:getMark("f_shengong_triggered") == 0 and player:getPhase() == sgs.Player_RoundStart
	end,
}
f_shenhuangzhong:addSkill(f_shengong)
--根据“神箭”数量拥有对应效果：
f_shengongBuff_4SJ = sgs.CreateTargetModSkill{
    name = "f_shengongBuff_4SJ",
	pattern = "Slash",
	distance_limit_func = function(self, from)
	    if from:hasSkill("f_shengong") and from:getPile("ShenJian"):length() >= 4 then
			return 1000
		else
			return 0
		end
	end,
}
f_shengongBuff_8SJ = sgs.CreateTriggerSkill{
    name = "f_shengongBuff_8SJ",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecified},
	on_trigger = function(self, event, player, data)
		if event == sgs.TargetSpecified then
		    local use = data:toCardUse()
		    if use.card:isKindOf("Slash") then
		        local jink_table = sgs.QList2Table(player:getTag("Jink_" .. use.card:toString()):toIntList())
			    local index = 1
			    for _, p in sgs.qlist(use.to) do
		            local _data = sgs.QVariant()
			        _data:setValue(p)
				    jink_table[index] = 0
				    index = index + 1
				end
				local jink_data = sgs.QVariant()
			    jink_data:setValue(Table2IntList(jink_table))
			    player:setTag("Jink_" .. use.card:toString(), jink_data)
			    return false
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_shengong") and player:getPile("ShenJian"):length() >= 8
	end,
}
f_shengongBuff_12SJ = sgs.CreateTriggerSkill{
	name = "f_shengongBuff_12SJ",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local card = damage.card
		if card:isKindOf("Slash") then
		    room:sendCompulsoryTriggerLog(player, "f_shengong")
			local xiahouyuan = damage.damage
			damage.damage = xiahouyuan + 1
			data:setValue(damage)
			room:broadcastSkillInvoke("f_shengong", 2)
			room:sendCompulsoryTriggerLog(player, "f_shengong")
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_shengong") and player:getPile("ShenJian"):length() >= 12
	end,
}
f_shengongBuff_16SJ = sgs.CreateTriggerSkill{
	name = "f_shengongBuff_16SJ",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local card = nil
		local use = data:toCardUse()
		card = use.card
		if card:isKindOf("Slash") then
		    room:sendCompulsoryTriggerLog(player, "f_shengong")
			room:drawCards(player, 1, "f_shengong")
			room:broadcastSkillInvoke("f_shengong", 2)
			if not player:isKongcheng() then
				local card_id = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				if card_id then
				    card_id:deleteLater()
					card_id = room:askForExchange(player, self:objectName(), 1, 1, false, "f_shengong16SJPush")
				end
				player:addToPile("ShenJian", card_id)
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_shengong") and player:getPile("ShenJian"):length() >= 16
	end,
}
if not sgs.Sanguosha:getSkill("f_shengongBuff_4SJ") then skills:append(f_shengongBuff_4SJ) end
if not sgs.Sanguosha:getSkill("f_shengongBuff_8SJ") then skills:append(f_shengongBuff_8SJ) end
if not sgs.Sanguosha:getSkill("f_shengongBuff_12SJ") then skills:append(f_shengongBuff_12SJ) end
if not sgs.Sanguosha:getSkill("f_shengongBuff_16SJ") then skills:append(f_shengongBuff_16SJ) end

--“定军”（修改前）
f_dingjunCard = sgs.CreateSkillCard{ --配合触发视为技
    name = "f_dingjunCard",
	target_fixed = true,
	on_use = function()
	end,
}
f_dingjun = sgs.CreateZeroCardViewAsSkill{
    name = "f_dingjun",
	waked_skills = "tenyearliegong, f_luanshe",
	view_as = function()
		return f_dingjunCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasFlag("f_dingjunCard_used")
	end,
}
f_dingjunTrigger = sgs.CreateTriggerSkill{
    name = "f_dingjunTrigger",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	view_as_skill = getFShenJianSkillVS,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:getSkillName() == "f_dingjun" then
		    local choices = {}
		    if player:getMark("DJSZhanGong") == 0 and not player:hasFlag("f_dingjunCard_used") and player:getPile("ShenJian"):length() >= 4 then
			    table.insert(choices, "get4ShenJian")
		    end
		    if player:getMark("DJSZhanGong") == 0 and not player:hasFlag("f_dingjunCard_used") and player:getHandcardNum() >= 4 then
			    table.insert(choices, "add4ShenJian")
		    end
		    table.insert(choices, "cancel")
		    local choice = room:askForChoice(player, "f_dingjun", table.concat(choices, "+"))
		    if choice == "get4ShenJian" then
			    if room:askForUseCard(player, "@@getFShenJianSkill", "@getFShenJianSkill-card") then
				    room:setPlayerFlag(player, "f_dingjunCard_used")
			    end
		    elseif choice == "add4ShenJian" then
			    local card_id = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			    if card_id then
				    card_id:deleteLater()
				    card_id = room:askForExchange(player, "f_dingjun", 4, 4, false, "f_dingjunA4Push")
			    end
			    player:addToPile("ShenJian", card_id)
			    room:acquireSkill(player, "f_luanshe")
			    room:setPlayerFlag(player, "f_dingjunCard_used")
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_dingjun")
	end,
}
f_shenhuangzhong:addSkill(f_dingjun)
f_shenhuangzhong:addRelateSkill("tenyearliegong")
f_shenhuangzhong:addRelateSkill("f_luanshe")
if not sgs.Sanguosha:getSkill("f_dingjunTrigger") then skills:append(f_dingjunTrigger) end
--“定军”（修改后）
f_newdingjunCard = sgs.CreateSkillCard{
    name = "f_newdingjunCard",
	target_fixed = true,
	on_use = function()
	end,
}
f_newdingjun = sgs.CreateZeroCardViewAsSkill{
    name = "f_newdingjun",
	view_as = function()
		return f_newdingjunCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasFlag("get1to4ShenJian_used") or not player:hasFlag("add1to4ShenJian_used")
	end,
}
f_newdingjunTrigger = sgs.CreateTriggerSkill{
    name = "f_newdingjunTrigger",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	view_as_skill = getOTFShenJianSkillVS,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:getSkillName() == "f_newdingjun" then
		    local choices = {}
		    if player:getMark("DJSZhanGong") > 0 and not player:hasFlag("get1to4ShenJian_used") and player:getPile("ShenJian"):length() >= 1 then
			    table.insert(choices, "get1to4ShenJian")
		    end
		    if player:getMark("DJSZhanGong") > 0 and not player:hasFlag("add1to4ShenJian_used") and not player:isKongcheng() then
			    table.insert(choices, "add1to4ShenJian")
		    end
		    table.insert(choices, "cancel")
		    local choice = room:askForChoice(player, "f_newdingjun", table.concat(choices, "+"))
		    if choice == "get1to4ShenJian" then
			    if room:askForUseCard(player, "@@getOTFShenJianSkill", "@getOTFShenJianSkill-card") then
				    room:setPlayerFlag(player, "get1to4ShenJian_used")
			    end
		    elseif choice == "add1to4ShenJian" then
			    local card_id = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			    if card_id then
				    card_id:deleteLater()
				    card_id = room:askForExchange(player,  "f_newdingjun", 4, 1, false, "f_dingjunA1to4Push")
			    end
			    player:addToPile("ShenJian", card_id)
			    room:acquireSkill(player, "f_luanshe")
			    room:setPlayerFlag(player, "add1to4ShenJian_used")
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_newdingjun")
	end,
}
if not sgs.Sanguosha:getSkill("f_newdingjun") then skills:append(f_newdingjun) end
if not sgs.Sanguosha:getSkill("f_newdingjunTrigger") then skills:append(f_newdingjunTrigger) end
----
  --为选项1（未修改）写的技能卡牌：
getFShenJianSkillCard = sgs.CreateSkillCard{
    name = "getFShenJianSkillCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
	    source:obtainCard(self, false)
		if not source:hasSkill("tenyearliegong") then
		    room:acquireSkill(source, "tenyearliegong")
		end
	end,
}
getFShenJianSkillVS = sgs.CreateViewAsSkill{
    name = "getFShenJianSkill",
    n = 4,
	expand_pile = "ShenJian",
	view_filter = function(self, selected, to_select)
	    return sgs.Self:getPile("ShenJian"):contains(to_select:getId())
	end,
    view_as = function(self, cards)
	    if #cards == 4 then
		    local cardA = cards[1]
		    local cardB = cards[2]
		    local cardC = cards[3]
		    local cardD = cards[4]
		    local vs = getFShenJianSkillCard:clone()
		    vs:addSubcard(cardA)
		    vs:addSubcard(cardB)
		    vs:addSubcard(cardC)
		    vs:addSubcard(cardD)
		    vs:setSkillName("f_dingjun")
		    return vs
		end
	end,
	enabled_at_play = function(self, player)
	    return player:hasSkill("f_dingjun") and not player:hasUsed("#getFShenJianSkillCard") and player:getPile("ShenJian"):length() >= 4
	end,
	response_pattern = "@@getFShenJianSkill",
}
if not sgs.Sanguosha:getSkill("getFShenJianSkill") then skills:append(getFShenJianSkillVS) end
  --为选项1（修改后）写的技能卡牌：
getOTFShenJianSkillCard = sgs.CreateSkillCard{
    name = "getOTFShenJianSkillCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
	    source:obtainCard(self, false)
		if not source:hasSkill("tenyearliegong") then
		    room:acquireSkill(source, "tenyearliegong")
		end
	end,
}
getOTFShenJianSkillVS = sgs.CreateViewAsSkill{
    name = "getOTFShenJianSkill",
    n = 4,
	expand_pile = "ShenJian",
	view_filter = function(self, selected, to_select)
	    return sgs.Self:getPile("ShenJian"):contains(to_select:getId())
	end,
    view_as = function(self, cards)
	    if #cards >= 1 and #cards <= 4 then
			local c = getOTFShenJianSkillCard:clone()
			for _, card in ipairs(cards) do
				c:addSubcard(card)
			end
			return c
		end
		return nil
	end,
	enabled_at_play = function(self, player)
	    return player:hasSkill("f_newdingjun") and not player:hasUsed("#getOTFShenJianSkillCard") and player:getPile("ShenJian"):length() >= 1
	end,
	response_pattern = "@@getOTFShenJianSkill",
}
if not sgs.Sanguosha:getSkill("getOTFShenJianSkill") then skills:append(getOTFShenJianSkillVS) end
----
f_dingjun_SkillClear = sgs.CreateTriggerSkill{
    name = "f_dingjun_SkillClear",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play then
		    if player:hasFlag("f_dingjunCard_used") or player:hasFlag("get1to4ShenJian_used") or player:hasFlag("f_dingjun_SkillClear") then
			    if player:hasSkill("tenyearliegong") then
			        room:detachSkillFromPlayer(player, "tenyearliegong", false, true)
				end
			end
			if player:hasSkill("f_luanshe") and (player:hasFlag("f_dingjunCard_used") or player:hasFlag("add1to4ShenJian_used") or player:hasFlag("f_dingjun_SkillClear")) then
			    room:detachSkillFromPlayer(player, "f_luanshe", false, true)
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_dingjun") or player:hasSkill("f_newdingjun")
	end,
}
if not sgs.Sanguosha:getSkill("f_dingjun_SkillClear") then skills:append(f_dingjun_SkillClear) end
--“乱射”
f_luanshe = sgs.CreateViewAsSkill{
	name = "f_luanshe",
	n = 999,
	expand_pile = "ShenJian",
	view_filter = function(self, selected, to_select)
	    local x = math.max(1, sgs.Self:getHp())
		local y = x + x
		if #selected >= y then return false end
		return sgs.Self:getPile("ShenJian"):contains(to_select:getId())
	end,
	view_as = function(self, cards)
	    local x = math.max(1, sgs.Self:getHp())
		local y = x + x
		if #cards ~= y then return end
	    local ls_card = sgs.Sanguosha:cloneCard("archery_attack", sgs.Card_NoSuit, 0)
		if ls_card then
			ls_card:setSkillName(self:objectName())
			for _, z in ipairs(cards) do
				ls_card:addSubcard(z)
			end
		end
		return ls_card
	end,
	enabled_at_play = function(self, player)
		return not player:hasFlag("f_luanshe_used") and player:getPile("ShenJian"):length() >= 1
	end,
}
f_luansheX = sgs.CreateTriggerSkill{
	name = "f_luansheX",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.ConfirmDamage, sgs.Damage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
		    local card = data:toCardUse().card
			if player:getPhase() == sgs.Player_Play and card:getSkillName() == "f_luanshe" then
		        room:setPlayerFlag(player, "f_luanshe_used")
			end
		elseif event == sgs.ConfirmDamage then
		    local damage = data:toDamage()
			local card = damage.card
		    if card:isKindOf("ArcheryAttack") and card:getSkillName() == "f_luanshe" then
		        local CH = damage.damage
				--暴击
				if math.random() > 0.5 then
			        damage.damage = CH + CH
				end
			    data:setValue(damage)
			end
		elseif event == sgs.Damage then
		    local damage = data:toDamage()
			local card = damage.card
			if card:isKindOf("ArcheryAttack") and card:getSkillName() == "f_luanshe" then
		        room:drawCards(player, damage.damage, "f_luanshe")
		        if not player:isKongcheng() then
			        local card_id = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			        if card_id then
				        card_id:deleteLater()
						card_id = room:askForExchange(player, "f_luanshe", damage.damage, damage.damage, false, "f_luansheXPush")
			        end
			        player:addToPile("ShenJian", card_id)
				end
			end
			room:broadcastSkillInvoke("f_luanshe")
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_luanshe")
	end,
}
if not sgs.Sanguosha:getSkill("f_luanshe") then skills:append(f_luanshe) end
if not sgs.Sanguosha:getSkill("f_luansheX") then skills:append(f_luansheX) end

f_huanghansheng = sgs.CreateTriggerSkill{
	name = "f_huanghansheng",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Death, sgs.AskForPeaches},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Death then
		    local death = data:toDeath()
		    if death.who:objectName() ~= player:objectName() then
		        local killer
		        if death.damage then
			        killer = death.damage.from
		        else
			        killer = nil
		        end
		        local current = room:getCurrent()
		        if killer:hasSkill(self:objectName()) and killer:getMark("DJSZhanGong") == 0 and (current:isAlive() or current:objectName() == death.who:objectName()) and killer:getMark("hhh_triggered") == 0 then
			        --使命成功
					room:broadcastSkillInvoke(self:objectName(), 1)
					room:doLightbox("$DJSZhanGong")
					local log = sgs.LogMessage()
				    log.type = "$hanshengSUC"
				    log.from = killer
				    room:sendLog(log)
				    room:drawCards(killer, 4, self:objectName())
			        killer:addMark("DJSZhanGong")
					if killer:hasSkill("f_dingjun") then
					    room:detachSkillFromPlayer(killer, "f_dingjun", true)
					end
					room:attachSkillToPlayer(killer, "f_newdingjun")
					if killer:hasFlag("f_dingjunCard_used") then
						room:setPlayerFlag(killer, "-f_dingjunCard_used")
						room:setPlayerFlag(killer, "f_dingjun_SkillClear")
					end
		        end
			end
		elseif event == sgs.AskForPeaches then
			local dying = data:toDying()
			if dying.who:objectName() == player:objectName() and player:hasSkill(self:objectName()) and player:getMark("DJSZhanGong") == 0 and player:getMark("hhh_triggered") == 0 then
			    --使命失败
				local log = sgs.LogMessage()
				log.type = "$hanshengFAL"
				log.from = player
				room:sendLog(log)
			    local maxhp = player:getMaxHp()
				local recover = math.min(1 - player:getHp(), maxhp - player:getHp()) --local hp = math.min(1, maxhp)
				room:recover(player, sgs.RecoverStruct(player, nil, recover)) --room:setPlayerProperty(player, "hp", sgs.QVariant(hp))
				player:throwEquipArea()
				room:broadcastSkillInvoke(self:objectName(), 2)
				room:addPlayerMark(player, "hhh_triggered")
			end
		end   
	end,
}
f_shenhuangzhong:addSkill(f_huanghansheng)

--9 神项羽
f_shenxiangyu = sgs.General(extension, "f_shenxiangyu", "god", 4, true)

f_bawangCard = sgs.CreateSkillCard{
    name = "f_bawangCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
	    if #targets == 1 then return false
		else return true
		end
	end,
	on_use = function(self, room, source, targets)
	    local dest = targets[1]
		local damage = sgs.DamageStruct()
		damage.from = source
		damage.to = dest
		damage.nature = sgs.DamageStruct_Normal
		room:damage(damage)
		room:broadcastSkillInvoke(self:objectName())
        room:drawCards(source, 1, "f_bawang")
	end,
}
f_bawang = sgs.CreateViewAsSkill{
    name = "f_bawang",
	n = 1,
	view_filter = function(self, selected, to_select)
	    return to_select:isKindOf("BasicCard")
	end,
	view_as = function(self, cards)
	    if #cards == 0 then return end
		local vs_card = f_bawangCard:clone()
		vs_card:addSubcard(cards[1])
		return vs_card
	end,
	enabled_at_play = function(self, player)
	    return not player:hasUsed("#f_bawangCard")
	end,
}
f_bawangCard_used = sgs.CreateTriggerSkill{
    name = "f_bawangCard_used",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
	    local card = data:toCardUse().card
		if player:hasSkill("f_bawang") and player:getPhase() == sgs.Player_Play and card:isKindOf("Slash") then
		    room:setPlayerFlag(player, "f_bawang_used")
		end
	end,
}
f_bawangMaxCards = sgs.CreateMaxCardsSkill{
	name = "f_bawangMaxCards",
	extra_func = function(self, target)
		if target:hasSkill("f_bawang") and target:hasFlag("f_bawang_used") then
			return -1
		else
			return 0
		end
	end,
}
f_shenxiangyu:addSkill(f_bawang)
if not sgs.Sanguosha:getSkill("f_bawangCard_used") then skills:append(f_bawangCard_used) end
if not sgs.Sanguosha:getSkill("f_bawangMaxCards") then skills:append(f_bawangMaxCards) end

f_zhuifeng = sgs.CreateTargetModSkill{
	name = "f_zhuifeng",
	distance_limit_func = function(self, from, card)
		if from:hasSkill(self:objectName()) and from:getWeapon() == nil and card:isKindOf("Slash") then
		local hp = from:getLostHp()
		    return 1 + hp
		else
		    return 0
		end
	end,
}
f_zhuifengX = sgs.CreateTargetModSkill{
	name = "f_zhuifengX",
	extra_target_func = function(self, from, card)
		if from:hasSkill("f_zhuifeng") and from:getArmor() == nil then
		local hp = from:getLostHp()
		    return 1 + hp
		else
			return 0
		end
	end,
}
f_zhuifengAudio = sgs.CreateTriggerSkill{
    name = "f_zhuifengAudio",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
        local use = data:toCardUse()
		if player:hasSkill("f_zhuifeng") and use.card:isKindOf("Slash") then
			room:broadcastSkillInvoke("f_zhuifeng")
		end
	end,
}
f_shenxiangyu:addSkill(f_zhuifeng)
if not sgs.Sanguosha:getSkill("f_zhuifengX") then skills:append(f_zhuifengX) end
if not sgs.Sanguosha:getSkill("f_zhuifengAudio") then skills:append(f_zhuifengAudio) end

f_wuzhui = sgs.CreateDistanceSkill{
	name = "f_wuzhui",
	correct_func = function(self, from)
		if from:hasSkill(self:objectName()) and from:getOffensiveHorse() == nil then
			return -1
		else
			return 0
		end
	end,
}
f_wuzhuiMaxCards = sgs.CreateMaxCardsSkill{
	name = "f_wuzhuiMaxCards",
	extra_func = function(self, target)
		if target:hasSkill("f_wuzhui") and target:getDefensiveHorse() == nil then
			return 1
		else
			return 0
		end
	end,
}
f_shenxiangyu:addSkill(f_wuzhui)
if not sgs.Sanguosha:getSkill("f_wuzhuiMaxCards") then skills:append(f_wuzhuiMaxCards) end

f_pofuchenzhou = sgs.CreateTriggerSkill{
    name = "f_pofuchenzhou",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start and player:isKongcheng() then
		    room:drawCards(player, 2, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
		elseif player:getPhase() == sgs.Player_Finish and player:isKongcheng() and room:askForSkillInvoke(player, self:objectName(), data) then
		    local Qinarmy = room:getOtherPlayers(player)
			local victim = room:askForPlayerChosen(player, Qinarmy, self:objectName())
			local damage = sgs.DamageStruct()
		    damage.from = player
		    damage.to = victim
		    damage.nature = sgs.DamageStruct_Normal
		    room:damage(damage)
			room:broadcastSkillInvoke(self:objectName())
		end
	end,
}
f_shenxiangyu:addSkill(f_pofuchenzhou)

--10 神孙悟空
f_shensunwukong = sgs.General(extension, "f_shensunwukong", "god", 4, true)

f_bianhua = sgs.CreateTriggerSkill{
	name = "f_bianhua",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DrawNCards, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawNCards then
			local count = data:toInt() - 1000
			if count < 0 then
			    count = 0
			end
			data:setValue(count)
		elseif event == sgs.EventPhaseStart then
		    --为了防止鬼畜六重奏，将准备阶段与其他阶段分开写，仅在准备阶段开始时播放语音（要是和庞德公组双将那就是于摸牌阶段开始时播放）。
			if player:getPhase() == sgs.Player_Start then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
			    room:broadcastSkillInvoke(self:objectName())
				room:drawCards(player, 1, self:objectName())
			elseif player:getPhase() == sgs.Player_Draw and player:hasSkill("yinshiy") then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
			    room:broadcastSkillInvoke(self:objectName())
				room:drawCards(player, 1, self:objectName())
			elseif player:getPhase() == sgs.Player_Judge or player:getPhase() == sgs.Player_Draw or player:getPhase() == sgs.Player_Play
			or player:getPhase() == sgs.Player_Discard or player:getPhase() == sgs.Player_Finish then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:drawCards(player, 1, self:objectName())
			end
		end
	end,
}
f_shensunwukong:addSkill(f_bianhua)

f_doufaCard = sgs.CreateSkillCard{
    name = "f_doufaCard",
    target_fixed = false,
	filter = function(self, targets, to_select)
	    if #targets == 1 then return false
		else return true
		end
	end,
	on_use = function(self, room, source, targets)
	    local dest = targets[1]
		local df = math.random(0,3)
		local choices = {}
		table.insert(choices, "f_doufaFire")
		table.insert(choices, "f_doufaThunder")
		table.insert(choices, "f_doufaIce")
		table.insert(choices, "f_doufaPoison")
		table.insert(choices, "f_doufaNormal")
		if df == 0 then
		    table.insert(choices, "f_doufalosehp")
		end
		local choice = room:askForChoice(source, "f_doufa", table.concat(choices, "+"))
		if choice == "f_doufaFire" then
		    room:damage(sgs.DamageStruct("f_doufa", source, dest, 2, sgs.DamageStruct_Fire))
		elseif choice == "f_doufaThunder" then
		    room:damage(sgs.DamageStruct("f_doufa", source, dest, 2, sgs.DamageStruct_Thunder))
		elseif choice == "f_doufaIce" then
		    room:damage(sgs.DamageStruct("f_doufa", source, dest, 2, sgs.DamageStruct_Ice))
		elseif choice == "f_doufaPoison" then
		    room:damage(sgs.DamageStruct("f_doufa", source, dest, 2, sgs.DamageStruct_Poison))
		elseif choice == "f_doufaNormal" then
		    room:damage(sgs.DamageStruct("f_doufa", source, dest, 2, sgs.DamageStruct_Normal))
		elseif choice == "f_doufalosehp" then
		    room:loseHp(dest, 2)
		end
	end,
}
f_doufa = sgs.CreateViewAsSkill{
    name = "f_doufa",
	n = 999,
	view_filter = function(self, selected, to_select)
		local n = math.max(1, sgs.Self:getHp())
		if #selected >= n then return false end
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
	    local n = math.max(1, sgs.Self:getHp())
		if #cards ~= n then return end
	    local f_doufa_card = f_doufaCard:clone()
		if f_doufa_card then
			f_doufa_card:setSkillName(self:objectName())
			for _, c in ipairs(cards) do
				f_doufa_card:addSubcard(c)
			end
		end
		return f_doufa_card
	end,
	enabled_at_play = function(self, target)
	    return not target:hasUsed("#f_doufaCard")
	end,
}
f_shensunwukong:addSkill(f_doufa)
--

--11 神·君王霸王龙
f_Trex = sgs.General(extension, "f_Trex$", "god", 6, true)

f_diyuxiCard = sgs.CreateSkillCard{
    name = "f_diyuxiCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
	    local choices = {}
		if not source:hasFlag("L1D1SD1_used") then
			table.insert(choices, "L1D1SD1")
		end
		if not source:hasFlag("LM1D2D1_used") then
			table.insert(choices, "LM1D2D1")
		end
		table.insert(choices, "cancel")
		local choice = room:askForChoice(source, "f_diyuxi", table.concat(choices, "+"))
		
		if choice == "L1D1SD1" then
			room:broadcastSkillInvoke("f_diyuxi")
			room:loseHp(source, 1)
			room:drawCards(source, 1, "f_diyuxi")
			room:setPlayerFlag(source, "L1D1SD1_BUFF")
			room:setPlayerFlag(source, "L1D1SD1_used")
		elseif choice == "LM1D2D1" then
			room:broadcastSkillInvoke("f_diyuxi")
			room:loseMaxHp(source, 1)
			room:drawCards(source, 2, "f_diyuxi")
			room:setPlayerFlag(source, "LM1D2D1_BUFF")
			room:setPlayerFlag(source, "LM1D2D1_used")
		end
	end,
}
f_diyuxi = sgs.CreateZeroCardViewAsSkill{
    name = "f_diyuxi",
	view_as = function()
		return f_diyuxiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasFlag("L1D1SD1_used") or not player:hasFlag("LM1D2D1_used")
	end,
}
f_diyuxiBUFF = sgs.CreateTriggerSkill{
	name = "f_diyuxiBUFF",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.ConfirmDamage and (player:hasFlag("L1D1SD1_BUFF") or player:hasFlag("LM1D2D1_BUFF")) then
		    local damage = data:toDamage()
		    local card = damage.card
			local hurt = damage.damage
			if player:hasFlag("L1D1SD1_BUFF") and card and card:isKindOf("Slash") then
			    local log = sgs.LogMessage()
				log.type = "$f_diyuxibuff1"
				log.from = player
				log.to:append(damage.to)
				room:sendLog(log)
			    damage.damage = hurt + 1
			end
		    if player:hasFlag("LM1D2D1_BUFF") then
			    local log = sgs.LogMessage()
				log.type = "$f_diyuxibuff2"
				log.from = player
				log.to:append(damage.to)
				room:sendLog(log)
				local hurtt = damage.damage
			    damage.damage = hurtt + 1
			end
			data:setValue(damage)
			room:broadcastSkillInvoke("f_diyuxi")
		elseif event == sgs.EventPhaseStart then
		    if player:getPhase() == sgs.Player_Finish and ((not player:hasFlag("L1D1SD1_used") and not player:hasFlag("LM1D2D1_used")) or (player:hasFlag("L1D1SD1_used") and player:hasFlag("LM1D2D1_used"))) then
			    room:loseHp(player, 1)
			end
		end
    end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_diyuxi")
	end,
}
f_Trex:addSkill(f_diyuxi)
if not sgs.Sanguosha:getSkill("f_diyuxiBUFF") then skills:append(f_diyuxiBUFF) end

f_moshi = sgs.CreateTriggerSkill{
    name = "f_moshi$",
	frequency = sgs.Skill_Wake,
	waked_skills = "f_kuanglong",
	events = {sgs.EventPhaseEnd},
	can_wake = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getMark("&f_moshiFQC") < 6 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		room:doLightbox("$f_moshi")
		if player:hasSkill("f_diyuxi") then
		    room:detachSkillFromPlayer(player, "f_diyuxi")
		end
		room:drawCards(player, 2, self:objectName())
		if not player:hasSkill("f_kuanglong") then
		    room:acquireSkill(player, "f_kuanglong")
		end
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
		local n = player:getMark("&f_moshiFQC")
		room:removePlayerMark(player, "&f_moshiFQC", n)
	end,
	can_trigger = function(self, player)
	    return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
f_moshiX = sgs.CreateTriggerSkill{
	name = "f_moshiX",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged, sgs.HpLost},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:addPlayerMark(player, "&f_moshiFQC")
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_moshi") and player:getMark("f_moshi") == 0
		and player:isLord() and not player:hasSkill("bahu")
	end,
}
f_Trex:addSkill(f_moshi)
f_Trex:addRelateSkill("f_kuanglong")
if not sgs.Sanguosha:getSkill("f_moshiX") then skills:append(f_moshiX) end
--“狂龙”
f_kuanglong = sgs.CreateTriggerSkill{
    name = "f_kuanglong",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local hp = player:getLostHp()
		local extra = (hp / 2)
		room:sendCompulsoryTriggerLog(player, self:objectName())
		local count = data:toInt() + extra
		data:setValue(count)
	end,
	can_trigger = function(self, player)
	    return player:hasSkill(self:objectName())
	end,
}
f_kuanglongS = sgs.CreateTargetModSkill{
	name = "f_kuanglongS",
	global = true,
	frequency = sgs.Skill_Compulsory,
	residue_func = function(self, player, card)
		if player:hasSkill("f_kuanglong") and card:isKindOf("Slash") then
		    local hp = player:getLostHp()
			local extra = (hp / 2)
		    return extra
		else
			return 0
		end
	end,
}
f_kuanglongC = sgs.CreateMaxCardsSkill{
    name = "f_kuanglongC",
    extra_func = function(self, target)
	    if target:hasSkill("f_kuanglong") then
		    local hp = target:getLostHp()
			local extra = (hp / 2)
		    return extra
		else
			return 0
		end
	end,
}
f_kuanglongAudio = sgs.CreateTriggerSkill{
    name = "f_kuanglongAudio",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Draw or player:getPhase() == sgs.Player_Discard then
			room:broadcastSkillInvoke("f_kuanglong")
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_kuanglong")
	end,
}
if not sgs.Sanguosha:getSkill("f_kuanglong") then skills:append(f_kuanglong) end
if not sgs.Sanguosha:getSkill("f_kuanglongS") then skills:append(f_kuanglongS) end
if not sgs.Sanguosha:getSkill("f_kuanglongC") then skills:append(f_kuanglongC) end
if not sgs.Sanguosha:getSkill("f_kuanglongAudio") then skills:append(f_kuanglongAudio) end



--

--12 神·鲲鹏
f_kunpeng = sgs.General(extension, "f_kunpeng", "god", 24, true, false, false, 6)

f_juxingCard = sgs.CreateSkillCard{
    name = "f_juxingCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
	    return #targets == 0 and to_select:getMark("&KunPeng") == 0 and not to_select:hasSkill("f_juxing")
	end,
	on_use = function(self, room, source, targets)
	    local DaSheng = targets[1]
		DaSheng:gainMark("&KunPeng")
		room:broadcastSkillInvoke("f_juxing", 1)
	end,
}
f_juxingVS = sgs.CreateZeroCardViewAsSkill{
    name = "f_juxing",
    view_as = function()
		return f_juxingCard:clone()
	end,
	response_pattern = "@@f_juxing",
}
f_juxing = sgs.CreateTriggerSkill{
    name = "f_juxing",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = f_juxingVS,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start and room:askForSkillInvoke(player, self:objectName(), data) then
		    room:askForUseCard(player, "@@f_juxing", "@f_juxing-card")
		end
	end,
}
f_juxingMarkSkill = sgs.CreateTriggerSkill{
    name = "f_juxingMarkSkill",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local damage = data:toDamage()
		local plist = room:getAllPlayers()
		for _, f_kunpeng in sgs.qlist(plist) do
            if f_kunpeng:hasSkill("f_juxing") then
		        room:loseMaxHp(f_kunpeng, damage.damage)
				room:addPlayerMark(f_kunpeng, "&f_juxing_trigger")
				room:sendCompulsoryTriggerLog(f_kunpeng, "f_juxing")
				room:broadcastSkillInvoke("f_juxing", 2)
			end
		end
		if damage.to:hasSkill("f_juxing") or damage.to:getMark("&KunPeng") > 0 then
		    room:sendCompulsoryTriggerLog(player, "f_juxing")
		    return damage.damage
		end
	end,
	can_trigger = function(self, player)
		return player ~= nil and (player:hasSkill("f_juxing") or player:getMark("&KunPeng") > 0)
	end,
}
f_juxingClearMark = sgs.CreateTriggerSkill{ --鲲鹏阵亡后，如果场上无人有技能“鲲鹏”，清除场上的“鲲鹏”标记
    name = "f_juxingClearMark",
	global = true,
	frequency = sgs.Skill_Compulsory,
    events = {sgs.Death},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local death = data:toDeath()
		if death.who:objectName() == player:objectName() then
		    local plist = room:getOtherPlayers(player)
			local can_invoke = true
			for _, p in sgs.qlist(plist) do
			    if p:hasSkill("f_juxing") then
				    can_invoke = false
				end
			end
			
			if can_invoke then
		        for _, p in sgs.qlist(plist) do
			        if p:getMark("&KunPeng") > 0 then
				        local n = p:getMark("&KunPeng")
						room:removePlayerMark(p, "&KunPeng", n)
					end
				end
			end
		end
    end,
	can_trigger = function(self, player)
		return player:hasSkill("f_juxing")
	end,
}
f_kunpeng:addSkill(f_juxing)
if not sgs.Sanguosha:getSkill("f_juxingMarkSkill") then skills:append(f_juxingMarkSkill) end
if not sgs.Sanguosha:getSkill("f_juxingClearMark") then skills:append(f_juxingClearMark) end

f_jiutianCard = sgs.CreateSkillCard{
    name = "f_jiutianCard",
    target_fixed = true,
    on_use = function(self, room, source, targets)
	    room:loseMaxHp(source)
		room:removePlayerMark(source, "&f_juxing_trigger")
		room:broadcastSkillInvoke("f_jiutian", 1)
	end,
}
f_jiutian = sgs.CreateZeroCardViewAsSkill{
    name = "f_jiutian",
	view_as = function()
		return f_jiutianCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("&f_juxing_trigger") >= 1
	end,
}
f_jiutianContinue = sgs.CreateTriggerSkill{
    name = "f_jiutianContinue",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed, sgs.EventPhaseStart, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
		    local use = data:toCardUse()
		    if use.card:getSkillName() == "f_jiutian" and player:hasSkill("f_jiutian") then			
			    local ids = room:getNCards(1, false)
				local move = sgs.CardsMoveStruct()
				move.card_ids = ids
				move.to = player
				move.to_place = sgs.Player_PlaceTable
				move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), self:objectName(), nil)
				room:moveCardsAtomic(move, true)
				local id = ids:first()
				local card = sgs.Sanguosha:getCard(id)
				if card:isRed() then
				    local plistR = room:getAllPlayers()
					local beneficiaryR = room:askForPlayerChosen(player, plistR, self:objectName())
					beneficiaryR:obtainCard(card)
					room:broadcastSkillInvoke("f_jiutian", 2)
				elseif card:isBlack() then
				    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), nil)
					room:throwCard(card, reason, nil)
					local plistB = room:getAllPlayers()
					local beneficiaryB = room:askForPlayerChosen(player, plistB, self:objectName())
					local choice = room:askForChoice(player, self:objectName(), "RecoverHim+HeDrawCard")
					if choice == "RecoverHim" then
					    local rec = sgs.RecoverStruct()
		                rec.who = beneficiaryB
		                room:recover(beneficiaryB, rec)
					elseif choice == "HeDrawCard" then
					    room:drawCards(beneficiaryB, 1, "f_jiutian")
					end
					room:broadcastSkillInvoke("f_jiutian", 3)
				end
			end
		elseif event == sgs.EventPhaseStart then
		    if player:getPhase() == sgs.Player_Finish and player:getMark("&f_juxing_trigger") > 0 then
		        local m = player:getMark("&f_juxing_trigger")
			    room:loseMaxHp(player, m)
			end
		elseif event == sgs.EventPhaseChanging then
		    local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
                return false
            end
            for _, f_kunpeng in sgs.qlist(room:getAllPlayers()) do
			    if f_kunpeng:getMark("&f_juxing_trigger") > 0 then
				    local n = f_kunpeng:getMark("&f_juxing_trigger")
					room:removePlayerMark(f_kunpeng, "&f_juxing_trigger", n)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_jiutian")
    end,
}
f_kunpeng:addSkill(f_jiutian)
if not sgs.Sanguosha:getSkill("f_jiutianContinue") then skills:append(f_jiutianContinue) end

--

--13 FC神吕蒙
fc_shenlvmeng = sgs.General(extension, "fc_shenlvmeng", "god", 3, true)

function getCardList(intlist)
	local ids = sgs.CardList()
	for _, id in sgs.qlist(intlist) do
		ids:append(sgs.Sanguosha:getCard(id))
	end
	return ids
end
fcshelie = sgs.CreateTriggerSkill{
	name = "fcshelie",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() ~= sgs.Player_Draw then return false end
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName(), data) then return false end
		local card_ids = room:getNCards(5)
		room:broadcastSkillInvoke(self:objectName())
		room:fillAG(card_ids)
		local to_get = sgs.IntList()
		local to_throw = sgs.IntList()
		while not card_ids:isEmpty() do
			local card_id = room:askForAG(player, card_ids, false, "shelie")
			card_ids:removeOne(card_id)
			to_get:append(card_id)
			local card = sgs.Sanguosha:getCard(card_id)
			local suit = card:getSuit()
			room:takeAG(player, card_id, false)
			local _card_ids = card_ids
			for i = 0, 150 do
				for _, id in sgs.qlist(_card_ids) do
					local c = sgs.Sanguosha:getCard(id)
					if c:getSuit() == suit then
						card_ids:removeOne(id)
						room:takeAG(nil, id, false)
						to_throw:append(id)
					end
				end
			end
		end
		local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		if not to_get:isEmpty() then
			dummy:addSubcards(getCardList(to_get))
			player:obtainCard(dummy)
		end
		dummy:clearSubcards()
		if not to_throw:isEmpty() then
			dummy:addSubcards(getCardList(to_throw))
			if room:askForSkillInvoke(player, "@fcshelieGC", data) then
			    local sq = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName())
			    room:obtainCard(sq, dummy, true)
				room:broadcastSkillInvoke(self:objectName())
			else
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), "")
				room:throwCard(dummy, reason, nil)
			end
		end
		dummy:deleteLater()
		room:clearAG()
		return true
	end,
}
fc_shenlvmeng:addSkill(fcshelie)

fcgongxinCard = sgs.CreateSkillCard{
	name = "fcgongxinCard",
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		if not effect.to:isKongcheng() then
			local ids = sgs.IntList()
			for _, card in sgs.qlist(effect.to:getHandcards()) do
				ids:append(card:getEffectiveId())
			end
			local card_id = room:doGongxin(effect.from, effect.to, ids)
			if (card_id == -1) then return end
			local result = room:askForChoice(effect.from, "fcgongxin", "discard+put")
			effect.from:removeTag("fcgongxin")
			if result == "discard" then
				if sgs.Sanguosha:getCard(card_id):getSuit() == sgs.Card_Heart then
				    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, effect.from:objectName())
					room:obtainCard(effect.from, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
				else
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, effect.from:objectName(), nil, "fcgongxin", nil)
					room:throwCard(sgs.Sanguosha:getCard(card_id), reason, effect.to, effect.from)
				end
			else
				effect.from:setFlags("Global_GongxinOperatorr")
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, effect.from:objectName(), nil, "fcgongxin", nil)
				room:moveCardTo(sgs.Sanguosha:getCard(card_id), effect.to, nil, sgs.Player_DrawPile, reason, true)
				effect.from:setFlags("-Global_GongxinOperatorr")
			end
		end
	end,
}
fcgongxin = sgs.CreateZeroCardViewAsSkill{
	name = "fcgongxin",
	view_as = function()
		return fcgongxinCard:clone()
	end,
	enabled_at_play = function(self, target)
		return not target:hasUsed("#fcgongxinCard")
	end,
}
fc_shenlvmeng:addSkill(fcgongxin)

--14 FC神赵云
fc_shenzhaoyun = sgs.General(extension, "fc_shenzhaoyun", "god", 2, true)

fcweijing = sgs.CreateTriggerSkill{
	name = "fcweijing",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EnterDying, sgs.QuitDying},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.EnterDying then
		    local x = player:getLostHp()
	        room:broadcastSkillInvoke(self:objectName(), 3)
		    room:sendCompulsoryTriggerLog(player, self:objectName())
		    player:drawCards(x, self:objectName())
		elseif event == sgs.QuitDying then
		    local y = player:getHp()
	        room:broadcastSkillInvoke(self:objectName(), 3)
		    room:sendCompulsoryTriggerLog(player, self:objectName())
		    player:drawCards(y, self:objectName())
		end
	end,
}
fcweijing_MaxCards = sgs.CreateMaxCardsSkill{
	name = "fcweijing_MaxCards",
	extra_func = function(self, target)
		if target:hasSkill("fcweijing") then
			return target:getLostHp() + target:getHp()
		else
			return 0
		end
	end,
}
fcweijing_MaxCards_Audio = sgs.CreateTriggerSkill{
    name = "fcweijing_MaxCards_Audio",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:hasSkill("fcweijing") and player:getPhase() == sgs.Player_Discard then
			room:broadcastSkillInvoke("fcweijing", 2)
		end
	end,
}
fcweijing_Draw = sgs.CreateDrawCardsSkill{
	name = "fcweijing_Draw",
    global = true,
	frequency = sgs.Skill_Compulsory,
	draw_num_func = function(self, player, n)
	    if player:hasSkill("fcweijing") then
		    if player:isWounded() then
			    player:getRoom():sendCompulsoryTriggerLog(player, "fcweijing")
		    end
		    return n + player:getLostHp()
		end
		return n
	end,
}
fcweijing_Draw_Audio = sgs.CreateTriggerSkill{
    name = "fcweijing_Draw_Audio",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:hasSkill("fcweijing") and player:getPhase() == sgs.Player_Draw then
			room:broadcastSkillInvoke("fcweijing", 1)
		end
	end,
}
fc_shenzhaoyun:addSkill(fcweijing)
if not sgs.Sanguosha:getSkill("fcweijing_MaxCards") then skills:append(fcweijing_MaxCards) end
if not sgs.Sanguosha:getSkill("fcweijing_Draw") then skills:append(fcweijing_Draw) end
if not sgs.Sanguosha:getSkill("fcweijing_MaxCards_Audio") then skills:append(fcweijing_MaxCards_Audio) end
if not sgs.Sanguosha:getSkill("fcweijing_Draw_Audio") then skills:append(fcweijing_Draw_Audio) end

fclongming = sgs.CreateViewAsSkill{
	name = "fclongming",
	n = 2,
	response_or_use = true,
	waked_skills = "fclongmingx",
	view_filter = function(self, selected, to_select)
		if #selected > 1 or to_select:hasFlag("using") then return false end
		if #selected > 0 then
			return to_select:getSuit() == selected[1]:getSuit()
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			if sgs.Self:isWounded() or to_select:getSuit() == sgs.Card_Heart or to_select:getSuit() == sgs.Card_Spade then
				return true
			elseif sgs.Slash_IsAvailable(sgs.Self) and to_select:getSuit() == sgs.Card_Club then
				if sgs.Self:getWeapon() and to_select:getEffectiveId() == sgs.Self:getWeapon():getId()
						and to_select:isKindOf("Crossbow") then
					return sgs.Self:canSlashWithoutCrossbow()
				else
					return true
				end
			else
				return false
			end
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if string.find(pattern, "peach") then
				return to_select:getSuit() == sgs.Card_Heart or (to_select:getSuit() == sgs.Card_Spade and sgs.Self:hasFlag("Global_Dying"))
			elseif pattern == "jink" then
				return to_select:getSuit() == sgs.Card_Diamond
			elseif pattern == "slash" then
				return to_select:getSuit() == sgs.Card_Club
			end
			return false
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards ~= 1 and #cards ~= 2 then return nil end
		local card = cards[1]
		local new_card = nil
		if card:getSuit() == sgs.Card_Heart then
			new_card = sgs.Sanguosha:cloneCard("peach", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Diamond then
			new_card = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Club then
			new_card = sgs.Sanguosha:cloneCard("thunder_slash", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Spade then
			new_card = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_SuitToBeDecided, 0)
		end
		if new_card then
			if #cards == 1 then
				new_card:setSkillName(self:objectName())
			else
				new_card:setSkillName("fclongmingBuff")
			end
			for _, c in ipairs(cards) do
				new_card:addSubcard(c)
			end
		end
		return new_card
	end,
	enabled_at_play = function(self, player)
	    local newana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_SuitToBeDecided, 0)
		return player:isWounded() or sgs.Slash_IsAvailable(player)
		or player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, player, newana)
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "slash" or pattern == "jink"
		or (string.find(pattern, "peach") and not player:hasFlag("Global_PreventPeach")) or string.find(pattern, "analeptic")
	end,
}
fclongmingBuff = sgs.CreateTriggerSkill{
	name = "fclongmingBuff",
	global = true,
	events = {sgs.ConfirmDamage, sgs.PreHpRecover, sgs.CardUsed, sgs.CardResponded},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.card and damage.card:isBlack() and damage.card:getSkillName() == "fclongmingBuff" then
				local log = sgs.LogMessage()
				log.type = "$fclongmingDMG"
				log.from = player
				room:sendLog(log)
				if player:hasFlag("fclongmingANA_Buff") then
				    damage.damage = damage.damage + 2
				else
				    damage.damage = damage.damage + 1
				end
				data:setValue(damage)
				player:setFlags("-fclongmingANA_Buff")
			elseif damage.card and damage.card:isKindOf("Slash") then
			    if player:hasFlag("fclongmingANA_Buff") then
				    damage.damage = damage.damage + 1
					data:setValue(damage)
				end
				player:setFlags("-fclongmingANA_Buff")
			end
		elseif event == sgs.PreHpRecover then
			local rec = data:toRecover()
			if rec.card and rec.card:isRed() and rec.card:isKindOf("Peach") and rec.card:getSkillName() == "fclongmingBuff" then
				local log = sgs.LogMessage()
				log.type = "$fclongmingPREC"
				log.from = player
				room:sendLog(log)
				rec.recover = rec.recover + 1
				data:setValue(rec)
			elseif rec.card and rec.card:isBlack() and rec.card:isKindOf("Analeptic") and rec.card:getSkillName() == "fclongmingBuff" then
				local log = sgs.LogMessage()
				log.type = "$fclongmingAREC"
				log.from = player
				room:sendLog(log)
				rec.recover = rec.recover + 1
				data:setValue(rec)
			end
		else
			local card
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else
				card = data:toCardResponse().m_card
			end
			if card and card:isRed() and card:isKindOf("Jink") and card:getSkillName() == "fclongmingBuff" then
				local current = room:getCurrent()
				if current:isNude() then return false end
				room:doAnimate(1, player:objectName(), current:objectName())
				local card_id = room:askForCardChosen(player, current, "he", "fclongmingBuff")
			    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
			    room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
				local log = sgs.LogMessage()
				log.type = "$fclongmingJNK"
				log.from = player
				room:sendLog(log)
			end
			if card and card:isKindOf("Analeptic") and card:getSkillName() == "fclongmingBuff" then
			    local log = sgs.LogMessage()
				log.type = "$fclongmingANA"
				log.from = player
				room:sendLog(log)
				room:setPlayerFlag(player, "fclongmingANA_Buff")
			end
		end
	end,
}
fc_shenzhaoyun:addSkill(fclongming)
fc_shenzhaoyun:addRelateSkill("fclongmingx")
if not sgs.Sanguosha:getSkill("fclongmingBuff") then skills:append(fclongmingBuff) end
--“龙鸣”配音区--
fclongmingx = sgs.CreateTriggerSkill{
	name = "fclongmingx",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end,
}
fclongming_Audio = sgs.CreateTriggerSkill{
    name = "fclongming_Audio",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed, sgs.CardResponded},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local card = nil
		if event == sgs.CardUsed then
			card = data:toCardUse().card
		else
			card = data:toCardResponse().m_card
		end
		if card and card:isKindOf("Peach") and (card:getSkillName() == "fclongming" or card:getSkillName() == "fclongmingBuff") then
		    room:broadcastSkillInvoke("fclongmingx", 1)
		elseif card and card:isKindOf("Jink") and (card:getSkillName() == "fclongming" or card:getSkillName() == "fclongmingBuff") then
		    room:broadcastSkillInvoke("fclongmingx", 2)
		elseif card and card:isKindOf("ThunderSlash") and (card:getSkillName() == "fclongming" or card:getSkillName() == "fclongmingBuff") then
		    room:broadcastSkillInvoke("fclongmingx", 3)
		elseif card and card:isKindOf("Analeptic") and (card:getSkillName() == "fclongming" or card:getSkillName() == "fclongmingBuff") then
		    room:broadcastSkillInvoke("fclongmingx", 4)
		end
		if card and card:isRed() and card:getSkillName() == "fclongmingBuff" then
		    room:broadcastSkillInvoke("fclongmingx", 5)
		elseif card and card:isBlack() and card:getSkillName() == "fclongmingBuff" then
		    room:broadcastSkillInvoke("fclongmingx", 6)
		end
		--彩蛋：
		if card and card:isKindOf("FireSlash") then
		    room:broadcastSkillInvoke("fclongmingx", 7)
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("fclongming")
	end,
}
----
if not sgs.Sanguosha:getSkill("fclongmingx") then skills:append(fclongmingx) end
if not sgs.Sanguosha:getSkill("fclongming_Audio") then skills:append(fclongming_Audio) end

--15 FC神刘备
fc_shenliubei = sgs.General(extension, "fc_shenliubei", "god", 6, true)

fc_shenliubei:addSkill("longnu")

fcjieying_GMS = sgs.CreateTriggerSkill{
	name = "fcjieying_GMS",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.ChainStateChange},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.GameStart then
			if player:hasSkill("fcjieying") and not player:isChained() then
				room:setPlayerChained(player)
			end
		end
		if event == sgs.ChainStateChange and player:isChained() then
			return true
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("fcjieying")
	end,
}
fcjieying_MoreSlashUsed = sgs.CreateTargetModSkill{
	name = "fcjieying_MoreSlashUsed",
	global = true,
	frequency = sgs.Skill_Compulsory,
	residue_func = function(self, player, card)
	    local n = 0
		if card:isKindOf("Slash") then
		    if player:hasSkill("fcjieying") and player:isChained() then
			    n = n + 1
		    end
		    for _, p in sgs.qlist(player:getAliveSiblings()) do
			    if p:hasSkill("fcjieying") and player:isChained() then
			        n = n + 1
			    end
			end
		end
		return n
	end,
}
fcjieying_MaxCards = sgs.CreateMaxCardsSkill{
	name = "fcjieying_MaxCards",
	extra_func = function(self, target)
		local n = 0
		if target:hasSkill("fcjieying") and target:isChained() then
			n = n - 2 + 3
			--n = n + 1
		end
		for _, p in sgs.qlist(target:getAliveSiblings()) do
			if p:hasSkill("fcjieying") and target:isChained() then
				n = n - 2
			end
		end
		return n
	end,
}
fcjieying = sgs.CreateTriggerSkill{
	name = "fcjieying",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data, room)
		if player:getPhase() == sgs.Player_Finish and room:askForSkillInvoke(player, self:objectName(), data) then
			local targets = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if not p:isChained() then
					targets:append(p)
				end
			end
			if not targets:isEmpty() then
				local target = room:askForPlayerChosen(player, targets, self:objectName(), "fcjieying-invoke", false, true)
				if target then
					room:broadcastSkillInvoke(self:objectName())
					room:addPlayerMark(player, self:objectName().."engine")
					if player:getMark(self:objectName().."engine") > 0 then
						room:setPlayerChained(target)
						room:removePlayerMark(player, self:objectName().."engine")
					end
				end
			end
		end
	end,
}
fc_shenliubei:addSkill(fcjieying)
if not sgs.Sanguosha:getSkill("fcjieying_GMS") then skills:append(fcjieying_GMS) end
if not sgs.Sanguosha:getSkill("fcjieying_MoreSlashUsed") then skills:append(fcjieying_MoreSlashUsed) end
if not sgs.Sanguosha:getSkill("fcjieying_MaxCards") then skills:append(fcjieying_MaxCards) end

--[[fclongni = sgs.CreateTriggerSkill{
    name = "fclongni",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local damage = data:toDamage()
		if damage.nature == sgs.DamageStruct_Fire or damage.nature == sgs.DamageStruct_Thunder or damage.nature == sgs.DamageStruct_Ice or damage.nature == sgs.DamageStruct_Poison then
		    room:sendCompulsoryTriggerLog(player, self:objectName())
		    local rec = sgs.RecoverStruct()
			rec.who = player
			room:recover(player, rec)
		end
	end,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill("longnu")
	end,
}
fc_shenliubei:addSkill(fclongni)]]

--16 FC神张辽
fc_shenzhangliao = sgs.General(extension, "fc_shenzhangliao", "god", 4, true)

fcduorui = sgs.CreateTriggerSkill{
    name = "fcduorui",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play then
		    local damage = data:toDamage()
			local victim = damage.to
			if victim:objectName() == player:objectName() then return end
			if victim:isAlive() and not victim:isNude() and room:askForSkillInvoke(player, self:objectName(), data) then
			    local choices = {}
		        table.insert(choices, "obtain1card")
			    table.insert(choices, "CleanUpHandArea")
		        table.insert(choices, "CleanUpEquipArea")
				table.insert(choices, "cancel")
                local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			    if choice == "obtain1card" then
			        local id = room:askForCardChosen(player, victim, "he", self:objectName())
				    room:obtainCard(player, id, false)
				    room:broadcastSkillInvoke(self:objectName())
			    elseif choice == "CleanUpHandArea" then
			        victim:throwAllHandCards()
                    room:broadcastSkillInvoke(self:objectName())
				    player:turnOver()
				    room:setPlayerFlag(player, "fcduorui_c2_used")
			    elseif choice == "CleanUpEquipArea" then
			        victim:throwAllEquips()
				    room:broadcastSkillInvoke(self:objectName())
				    room:setPlayerFlag(player, "Global_PlayPhaseTerminated")
				end
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("fcduorui") and not player:hasFlag("fcduorui_c2_used")
	end,
}
fc_shenzhangliao:addSkill(fcduorui)

fczhiti = sgs.CreateTriggerSkill{
	name = "fczhiti",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end,
}
fczhitiX = sgs.CreateMaxCardsSkill{
	name = "fczhitiX",
	extra_func = function(self, target)
		local n = 0
		for _, p in sgs.qlist(target:getAliveSiblings()) do
			if p:hasSkill("fczhiti") and p:inMyAttackRange(target) and target:isWounded() and target:objectName() ~= p:objectName() then
				n = n - 1
			end
		end
		return n
	end,
}
fczhitiFlag = sgs.CreateTriggerSkill{
    name = "fczhitiFlag",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start then
			local plist = room:getAlivePlayers()
			local wdd = 0
			for _, p in sgs.qlist(plist) do
				if p:isWounded() then
					wdd = wdd + 1
				end
			end
			if wdd >= 1 then
				room:setPlayerFlag(player, "fczhiti_1wdd")
			end
			if wdd >= 3 then
				room:setPlayerFlag(player, "fczhiti_3wdd")
			end
			if wdd >= 5 then
				room:setPlayerFlag(player, "fczhiti_5wdd")
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("fczhiti")
	end,
}
fc_shenzhangliao:addSkill(fczhiti)
if not sgs.Sanguosha:getSkill("fczhitiX") then skills:append(fczhitiX) end
if not sgs.Sanguosha:getSkill("fczhitiFlag") then skills:append(fczhitiFlag) end
--“止啼”具体加成一览：
fczhiti_MaxCard = sgs.CreateMaxCardsSkill{
    name = "fczhiti_MaxCard",
    extra_func = function(self, target)
	    if target:hasSkill("fczhiti") and target:hasFlag("fczhiti_1wdd") then
		    return 1
	    else
		    return 0
	    end
	end,
}
fczhiti_MoreDistance = sgs.CreateTargetModSkill{
    name = "fczhiti_MoreDistance",
	pattern = "Card",
	distance_limit_func = function(self, from)
	    if from:hasSkill("fczhiti") and from:hasFlag("fczhiti_1wdd") then
			return 1
		else
			return 0
		end
	end,
}
fczhiti_DrawMoreCard = sgs.CreateTriggerSkill{
	name = "fczhiti_DrawMoreCard",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:hasSkill("fczhiti") and player:hasFlag("fczhiti_3wdd") then
			room:sendCompulsoryTriggerLog(player, "fczhiti")
			local count = data:toInt() + 1
			data:setValue(count)
		end
	end,
}
fczhiti_MoreSlashUsed = sgs.CreateTargetModSkill{
	name = "fczhiti_MoreSlashUsed",
	global = true,
	frequency = sgs.Skill_Compulsory,
	residue_func = function(self, player, card)
		if player:hasSkill("fczhiti") and player:hasFlag("fczhiti_3wdd") and card:isKindOf("Slash") then
			return 1
		else
			return 0
		end
	end,
}
fczhiti_throwEquipArea_Damage = sgs.CreateTriggerSkill{
    name = "fczhiti_throwEquipArea_Damage",
	global = true,
	frequency = sgs.Skill_NotFrequent,
    events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() == sgs.Player_Finish and player:hasSkill("fczhiti") and player:hasFlag("fczhiti_5wdd") and room:askForSkillInvoke(player, "fczhiti", data) then
		    local plist = room:getOtherPlayers(player)
			local sunwu = room:askForPlayerChosen(player, plist, "fczhiti")
		    if sunwu:hasEquipArea() then
			    sunwu:throwEquipArea()
				room:addPlayerMark(sunwu, "EquipArea_lose")
			end
			local damage = sgs.DamageStruct()
		    damage.from = player
		    damage.to = sunwu
		    damage.nature = sgs.DamageStruct_Normal
		    room:damage(damage)
		    room:broadcastSkillInvoke(self:objectName())
		end
	end,
}
fczhiti_obtainEquipArea = sgs.CreateTriggerSkill{ --恢复装备区
    name = "fczhiti_obtainEquipArea",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then
            return false
        end
        for _, sunwu in sgs.qlist(room:getAllPlayers()) do
			if sunwu:getMark("EquipArea_lose") > 0 then
			    if not sunwu:hasEquipArea() then
				    sunwu:obtainEquipArea()
				end
			    local n = sunwu:getMark("EquipArea_lose")
			    room:removePlayerMark(sunwu, "EquipArea_lose", n)
			end
		end
	end,
	can_trigger = function(self, targets)
	    return targets:getMark("EquipArea_lose") > 0
	end,
}
fczhiti_Audio = sgs.CreateTriggerSkill{
    name = "fczhiti_Audio",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
	    local damage = data:toDamage()
		if player:hasSkill("fczhiti") and (player:getPhase() == sgs.Player_Draw or player:getPhase() == sgs.Player_Discard) then
		    room:broadcastSkillInvoke("fczhiti")
		end
	end,
}
if not sgs.Sanguosha:getSkill("fczhiti_MaxCard") then skills:append(fczhiti_MaxCard) end
if not sgs.Sanguosha:getSkill("fczhiti_MoreDistance") then skills:append(fczhiti_MoreDistance) end
if not sgs.Sanguosha:getSkill("fczhiti_DrawMoreCard") then skills:append(fczhiti_DrawMoreCard) end
if not sgs.Sanguosha:getSkill("fczhiti_MoreSlashUsed") then skills:append(fczhiti_MoreSlashUsed) end
if not sgs.Sanguosha:getSkill("fczhiti_throwEquipArea_Damage") then skills:append(fczhiti_throwEquipArea_Damage) end
if not sgs.Sanguosha:getSkill("fczhiti_obtainEquipArea") then skills:append(fczhiti_obtainEquipArea) end
if not sgs.Sanguosha:getSkill("fczhiti_Audio") then skills:append(fczhiti_Audio) end

--斗地主模式纪念--
--17 地主
f_landlord = sgs.General(extension, "f_landlord", "qun", 4, true)

f_feiyangCard = sgs.CreateSkillCard{
	name = "f_feiyang",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local judge = room:askForCardChosen(source, source, "j", self:objectName(), false, sgs.Card_MethodDiscard)
		room:throwCard(judge, source, source)
	end,
}
f_feiyangVS = sgs.CreateViewAsSkill{
	name = "f_feiyang",
	n = 2,
	view_filter = function(self, selected, to_select)
		return #selected <= 2 and not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards ~= 2 then return nil end
		local c = f_feiyangCard:clone()
		for _, card in ipairs(cards) do
			c:addSubcard(card)
		end
		return c
	end,
	response_pattern = "@@f_feiyang",
}
f_feiyang = sgs.CreatePhaseChangeSkill{
	name = "f_feiyang",
	frequency = sgs.Skill_NotFrequent,
	view_as_skill = f_feiyangVS,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Judge and player:getJudgingArea():length() > 0 and player:getHandcardNum() >= 2 then
			room:askForUseCard(player, "@@f_feiyang", "@f_feiyang")
		end
	end,
}
f_landlord:addSkill(f_feiyang)

f_bahu = sgs.CreatePhaseChangeSkill{
	name = "f_bahu",
	frequency = sgs.Skill_Compulsory,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			player:drawCards(1, self:objectName())
		end
	end,
}
f_bahuSlashMore = sgs.CreateTargetModSkill{
	name = "f_bahuSlashMore",
	frequency = sgs.Skill_Compulsory,
	pattern = "Slash",
	residue_func = function(self, player)
		if player:hasSkill("f_bahu") then
			return 1
		end
		return 0
	end,
}
f_landlord:addSkill(f_bahu)
if not sgs.Sanguosha:getSkill("f_bahuSlashMore") then skills:append(f_bahuSlashMore) end

f_yinfu = sgs.CreateTriggerSkill{
    name = "f_yinfu",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.TurnStart, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
	    if event == sgs.TurnStart then
			local n = 15
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				n = math.min(p:getSeat(), n)
			end
			if player:getSeat() == n and not room:getTag("ExtraTurn"):toBool() then
				room:setPlayerMark(player, "f_yinfuTurn", player:getMark("Global_TurnCount") + 1)
				--[[for _, p in sgs.qlist(room:getAlivePlayers()) do
					for _, mark in sgs.list(p:getMarkNames()) do
						if string.find(mark, "_lun") and p:getMark(mark) > 0 then --乱抄代码，终造此祸
							room:setPlayerMark(p, mark, 0)
						end
					end
				end]]
			end
		elseif event == sgs.EventPhaseStart then
			if player:hasSkill(self:objectName()) and player:getPhase() == sgs.Player_RoundStart then
				local hp = player:getLostHp()
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if p:getMark("f_yinfuTurn") > 0 then
						local n = p:getMark("f_yinfuTurn")
						if hp >= n then
							room:sendCompulsoryTriggerLog(player, self:objectName())
							room:recover(player, sgs.RecoverStruct(player, nil, 1))
							room:addPlayerMark(player, "f_yinfuTriggered")
						end
					end
				end
				if player:getMark("f_yinfuTriggered") >= 3 then
					local m = player:getMark("f_yinfuTriggered")
					room:removePlayerMark(player, "f_yinfuTriggered", m)
					room:detachSkillFromPlayer(player, self:objectName())
				end
			end
		end
	end,
}
f_landlord:addSkill(f_yinfu)





--

--18 农民
f_farmer = sgs.General(extension, "f_farmer", "qun", 3, true)

f_gengzhongCard = sgs.CreateSkillCard{
    name = "f_gengzhongCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		source:addToPile("NT", self)
		---
		local Set = function(list)
			local set = {}
			for _, l in ipairs(list) do set[l] = true end
			return set
		end
		---
		local basic = {"slash", "normal_slash", "fire_slash", "thunder_slash", "ice_slash", "peach", "analeptic", "cancel"}
		for _, patt in ipairs(basic) do
			local poi = sgs.Sanguosha:cloneCard(patt, sgs.Card_NoSuit, -1)
			if poi and (not poi:isAvailable(source)) or (patt == "peach" and not source:isWounded()) then
				table.removeOne(basic, patt)
				if patt == "slash" then
					table.removeOne(basic, "normal_slash")
					table.removeOne(basic, "fire_slash")
					table.removeOne(basic, "thunder_slash")
					table.removeOne(basic, "ice_slash")
				end
			end
		end
		local choice = room:askForChoice(source, self:objectName(), table.concat(basic, "+"))
		if choice ~= "cancel" then
			--必须排除满血能吃桃的情况
			if choice == "peach" and not source:isWounded() then
			return false end
			room:setPlayerProperty(source, "f_gengzhong", sgs.QVariant(choice))
			room:askForUseCard(source, "@@f_gengzhong", "@f_gengzhong", -1, sgs.Card_MethodUse)
			room:setPlayerProperty(source, "f_gengzhong", sgs.QVariant())
		end
	end,
}
f_gengzhong = sgs.CreateViewAsSkill{
	name = "f_gengzhong",
	n = 1,
	view_filter = function(self, selected, to_select)
		if sgs.Sanguosha:getCurrentCardUsePattern() == "@@f_gengzhong" then return false end
		return true
	end,
	view_as = function(self, cards)
		if sgs.Sanguosha:getCurrentCardUsePattern() == "@@f_gengzhong" then
			if #cards == 0 then
				local name = sgs.Self:property("f_gengzhong"):toString()
				local card = sgs.Sanguosha:cloneCard(name, sgs.Card_NoSuit, 0)
				card:setSkillName("_f_gengzhong")
				return card
			end
		else
			if #cards > 0 then
				local NTcard = f_gengzhongCard:clone()
				for _, c in ipairs(cards) do
					NTcard:addSubcard(c)
				end
				NTcard:setSkillName("f_gengzhong")
				return NTcard
			end
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isNude() and not player:hasUsed("#f_gengzhongCard")
	end,
	response_pattern = "@@f_gengzhong",
}
f_gengzhongNTGet = sgs.CreateTriggerSkill{
    name = "f_gengzhongNTGet",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
	    if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart and room:askForSkillInvoke(player, "@f_gengzhongNTGet", data) then
				local NT = sgs.Sanguosha:cloneCard("slash")
				NT:addSubcards(player:getPile("NT"))
				room:obtainCard(player, NT)
				NT:deleteLater()
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			if room:askForSkillInvoke(player, "@f_gengzhongNTGet", data) then
				local NT = sgs.Sanguosha:cloneCard("slash")
				NT:addSubcards(player:getPile("NT"))
				room:obtainCard(player, NT)
				NT:deleteLater()
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_gengzhong") and player:getPile("NT"):length() > 0
	end,
}
f_farmer:addSkill(f_gengzhong)
if not sgs.Sanguosha:getSkill("f_gengzhongNTGet") then skills:append(f_gengzhongNTGet) end

f_gongkangCard = sgs.CreateSkillCard{
	name = "f_gongkangCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets < 1 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		room:removePlayerMark(effect.from, "@f_gongkang")
		room:doSuperLightbox("f_farmer", "f_gongkang")
		if not effect.to:hasSkill("f_gengzhong") then room:acquireSkill(effect.to, "f_gengzhong") end
		if not effect.from:hasSkill("f_tongxin") then room:acquireSkill(effect.from, "f_tongxin") end
		if not effect.to:hasSkill("f_tongxin") then room:acquireSkill(effect.to, "f_tongxin") end
	end,
}
f_gongkangVS = sgs.CreateZeroCardViewAsSkill{
	name = "f_gongkang",
	view_as = function()
		return f_gongkangCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@f_gongkang") > 0
	end,
}
f_gongkang = sgs.CreateTriggerSkill{
	name = "f_gongkang",
	frequency = sgs.Skill_Limited,
	waked_skills = "f_tongxin",
	limit_mark = "@f_gongkang",
	view_as_skill = f_gongkangVS,
	on_trigger = function()
	end,
}
f_farmer:addSkill(f_gongkang)
f_farmer:addRelateSkill("f_tongxin")
--“同心”
f_tongxin = sgs.CreateTriggerSkill{
    name = "f_tongxin",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
	    local death = data:toDeath()
		if death.who:objectName() == player:objectName() or not death.who:hasSkill(self:objectName()) then return false end
		if room:askForSkillInvoke(player, self:objectName(), data) then
			local choices = {}
			table.insert(choices, "1")
			if player:isWounded() then
				table.insert(choices, "2")
			end
			table.insert(choices, "cancel")
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			if choice == "1" then
				room:drawCards(player, 2, self:objectName())
			elseif choice == "2" then
				room:recover(player, sgs.RecoverStruct(player))
			end
			if death.damage.from:objectName() == player:objectName() then
				room:broadcastSkillInvoke("f_tongxinCDAudio")
			end
		end
	end,
}
f_tongxinCDAudio = sgs.CreateTriggerSkill{
	name = "f_tongxinCDAudio",
	on_trigger = function()
	end,
}
if not sgs.Sanguosha:getSkill("f_tongxin") then skills:append(f_tongxin) end
if not sgs.Sanguosha:getSkill("f_tongxinCDAudio") then skills:append(f_tongxinCDAudio) end

--J.SP赵云强化
chixinDrawANDGiveCard = sgs.CreateSkillCard{
    name = "chixinDrawANDGiveCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
	    return #targets == 0
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("chixin")
		targets[1]:obtainCard(self, true)
	end,
}
chixinDrawANDGiveVS = sgs.CreateViewAsSkill{
    name = "chixinDrawANDGive",
	n = 1,
	view_filter = function(self, selected, to_select)
	    return true
	end,
	view_as = function(self, cards)
	    if #cards == 1 then
			local cx_card = chixinDrawANDGiveCard:clone()
			cx_card:addSubcard(cards[1])
			return cx_card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng()
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@chixinDrawANDGive")
	end,
}
chixinDrawANDGive = sgs.CreateTriggerSkill{
	name = "chixinDrawANDGive",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.CardResponded},
	view_as_skill = chixinDrawANDGiveVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local card = nil
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			card = use.card
		else
			local resp = data:toCardResponse()
			card = resp.m_card
		end
		if card:getSkillName() == "chixin" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:broadcastSkillInvoke("chixin")
			room:drawCards(player, 1, "chixin")
			room:askForUseCard(player, "@@chixinDrawANDGive!", "@chixinDrawANDGive-card")
			if player:getState() == "robot" and not room:askForUseCard(player, "@@chixinDrawANDGive!", "@chixinDrawANDGive-card") then
			    local beneficiary = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName())
			    local id = room:askForCardChosen(player, player, "he", self:objectName())
			    room:obtainCard(beneficiary, id, true)
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("chixin")
	end,
}
suirenChangeKingdom = sgs.CreateTriggerSkill{
	name = "suirenChangeKingdom",
	global = true,
	priority = -1, --需要保证优先级比“随仁”原部分低，以满足此部分技能的触发条件
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start then
			room:setPlayerProperty(player, "kingdom", sgs.QVariant("shu"))
			room:addPlayerMark(player, "sCKinvoked")
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("suiren") and player:getKingdom() == "qun"
		and player:getMark("@suiren") == 0 and player:getMark("sCKinvoked") == 0
	end,
}
if not sgs.Sanguosha:getSkill("chixinDrawANDGive") then skills:append(chixinDrawANDGive) end
if not sgs.Sanguosha:getSkill("suirenChangeKingdom") then skills:append(suirenChangeKingdom) end
--

--项羽专属装备：乌骓马
local wuzhuii = sgs.Sanguosha:cloneCard("OffensiveHorse", sgs.Card_Spade, 5)
wuzhuii:setObjectName("wuzhuii")
--wuzhuii:setClassName("Wuzhuii")
wuzhuii:setParent(xiangyuEquip)
----


--

--============（V2.0）神话再临十二神将<<DIY翻创版本来袭!>>============--
extension_G = sgs.Package("fcDIY_twelveGod", sgs.Package_GeneralPack)

--19 武神·关羽
sp_shenguanyu = sgs.General(extension_G, "sp_shenguanyu", "god", 6, true, false, false, 5)

sp_taoyuanyi = sgs.CreateOneCardViewAsSkill{
	name = "sp_taoyuanyi",
	filter_pattern = ".|heart|.|hand",
	view_as = function(self, card)
		local suit = card:getSuit()
		local point = card:getNumber()
		local id = card:getId()
		local gs = sgs.Sanguosha:cloneCard("god_salvation", suit, point)
		gs:setSkillName(self:objectName())
		gs:addSubcard(id)
		return gs
	end,
	enabled_at_play = function(self, player)
	    return not player:hasFlag("sp_taoyuanyi_used")
	end,
}
sp_taoyuanyi_buffANDlimited = sgs.CreateTriggerSkill{
    name = "sp_taoyuanyi_buffANDlimited",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.HpRecover, sgs.CardUsed},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.HpRecover then
			local recover = data:toRecover()
			if recover.who:hasSkill("sp_taoyuanyi") and recover.card:isKindOf("GodSalvation") then
				room:sendCompulsoryTriggerLog(recover.who, "sp_taoyuanyi")
				room:broadcastSkillInvoke("sp_taoyuanyi")
				local n = math.random(1,3)
				if n == 1 then
					room:drawCards(recover.who, 1, "sp_taoyuanyi")
				elseif n == 2 then
					local rec = sgs.RecoverStruct()
					rec.who = recover.who
					room:recover(recover.who, rec)
				elseif n == 3 then
					local count = recover.who:getMaxHp()
					local mhp = sgs.QVariant()
					mhp:setValue(count + 1)
					room:setPlayerProperty(recover.who, "maxhp", mhp)
				end
			end
		elseif event == sgs.CardUsed then
	    	local use = data:toCardUse()
			if player:getPhase() == sgs.Player_Play and player:hasSkill("sp_taoyuanyi") and use.card:getSkillName() == "sp_taoyuanyi" then
		        room:setPlayerFlag(player, "sp_taoyuanyi_used")
			end
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
sp_shenguanyu:addSkill(sp_taoyuanyi)
if not sgs.Sanguosha:getSkill("sp_taoyuanyi_buffANDlimited") then skills:append(sp_taoyuanyi_buffANDlimited) end

sp_guoguanzhanjiang = sgs.CreateTriggerSkill{
    name = "sp_guoguanzhanjiang",
	frequency = sgs.Skill_Frequent,
	waked_skills = "sp_qianlixing",
	events = {sgs.EventPhaseStart, sgs.DamageCaused, sgs.Death},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_RoundStart then
			local can_invoke = true
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:getMark("&alreadyPASSlevel") == 0 then
					can_invoke = true
					break
				end
			end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("&LeVeL") > 0 then
					can_invoke = false
					break
				end
			end
			if can_invoke then
				local levels = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:getMark("&alreadyPASSlevel") == 0 then
						levels:append(p)
					end
				end
				local all_alive_players = {}
				for _, p in sgs.qlist(levels) do
					table.insert(all_alive_players, p)
				end
				local random_target = all_alive_players[math.random(1, #all_alive_players)]
				random_target:gainMark("&LeVeL", 1)
				if not player:hasSkill("sp_qianlixing") then
					room:acquireSkill(player, "sp_qianlixing")
				end
			end
		elseif event == sgs.DamageCaused then --过关
	    	local damage = data:toDamage()
			if damage.from:objectName() == player:objectName() and damage.to:getMark("&LeVeL") > 0 then
				local log = sgs.LogMessage()
				log.type = "$ggzz_guoguan"
				log.from = player
				log.to:append(damage.to)
				room:sendLog(log)
				room:broadcastSkillInvoke(self:objectName(), 1)
				if player:hasSkill("sp_qianlixing") then
					room:detachSkillFromPlayer(player, "sp_qianlixing", false, true)
				end
				damage.to:loseMark("&LeVeL")
				room:addPlayerMark(damage.to, "&alreadyPASSlevel")
				player:gainMark("&PASSlevel", 1)
				room:setPlayerFlag(player, "PASSlevel")
				local c = room:alivePlayerCount() - 1
				if c > 5 then c = 5 end
				if player:getMark("&PASSlevel") >= c then
					room:addPlayerMark(player, "ggzz_punishlose") --惩罚失效
				end
			end
		elseif event == sgs.Death then --斩将
			local death = data:toDeath()
		    if death.who:objectName() ~= player:objectName() then
		        local killer
		        if death.damage then
			        killer = death.damage.from
		        else
			        killer = nil
		        end
		        local current = room:getCurrent()
		        if killer:hasSkill(self:objectName()) and death.who:getMark("&alreadyPASSlevel") > 0 then
					local log = sgs.LogMessage()
					log.type = "$ggzz_zhanjiang"
					log.from = killer
					room:sendLog(log)
					room:broadcastSkillInvoke(self:objectName(), 2)
					killer:gainMark("&KILLgeneral", 1)
				end
			end
		end
	end,
}
sp_shenguanyu:addSkill(sp_guoguanzhanjiang)
--“千里行”
sp_qianlixing = sgs.CreateOneCardViewAsSkill{
	name = "sp_qianlixing",
	response_or_use = true,
	view_filter = function(self, card)
		if not card:isRed() then return false end
		if not (card:isKindOf("BasicCard") or card:isKindOf("EquipCard")) then return false end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
			slash:addSubcard(card:getEffectiveId())
			slash:deleteLater()
			return slash:isAvailable(sgs.Self)
		end
		return true
	end,
	view_as = function(self, card)
		local slash = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber())
		slash:addSubcard(card:getId())
		slash:setSkillName(self:objectName())
		return slash
	end,
	enabled_at_play = function(self, player)
		return sgs.Slash_IsAvailable(player)
	end, 
	enabled_at_response = function(self, player, pattern)
		return pattern == "slash"
	end,
}
sp_qianlixingMD = sgs.CreateTargetModSkill{
	name = "sp_qianlixingMD",
	distance_limit_func = function(self, from, card)
		if from:hasSkill("sp_qianlixing") and from:getPhase() == sgs.Player_Play and card:getSkillName() == "sp_qianlixing" then
			return 1000
		else
			return 0
		end
	end,
}
sp_qianlixingPF = sgs.CreateTriggerSkill{
    name = "sp_qianlixingPF",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
        local use = data:toCardUse()
		if event == sgs.CardUsed and player:getPhase() == sgs.Player_Play and use.card:getSkillName() == "sp_qianlixing" then
			player:setFlags("sp_qianlixingPFfrom")
			for _, p in sgs.qlist(use.to) do
				p:setFlags("sp_qianlixingPFto")
				room:addPlayerMark(p, "Armor_Nullified")
			end
		elseif event == sgs.CardFinished and use.card:getSkillName() == "sp_qianlixing" then
		    if not player:hasFlag("sp_qianlixingPFfrom") then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("sp_qianlixingPFto") then
					p:setFlags("-sp_qianlixingPFto")
					if p:getMark("Armor_Nullified") then
						room:removePlayerMark(p, "Armor_Nullified")
					end
				end
			end
			player:setFlags("-sp_qianlixingPFfrom")
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("sp_qianlixing")
	end,
}
if not sgs.Sanguosha:getSkill("sp_qianlixing") then skills:append(sp_qianlixing) end
if not sgs.Sanguosha:getSkill("sp_qianlixingMD") then skills:append(sp_qianlixingMD) end
if not sgs.Sanguosha:getSkill("sp_qianlixingPF") then skills:append(sp_qianlixingPF) end
sp_shenguanyu:addRelateSkill("sp_qianlixing")
sp_guoguanzhanjiang_RAP = sgs.CreateTriggerSkill{
    name = "sp_guoguanzhanjiang_RAP",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
                return false
            end
			for _, spsgy in sgs.qlist(room:getAllPlayers()) do
			    if spsgy:hasSkill("sp_guoguanzhanjiang") then
					if spsgy:hasFlag("PASSlevel") then --过关奖励
				    	room:sendCompulsoryTriggerLog(player, self:objectName())
						room:broadcastSkillInvoke(self:objectName(), 1)
						local n = spsgy:getMark("&PASSlevel")
						room:drawCards(spsgy, n, self:objectName())
					elseif not spsgy:hasFlag("PASSlevel") and spsgy:getMark("ggzz_punishlose") == 0 then --惩罚
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:loseMaxHp(spsgy, 1)
					end
					break
				end
			end
		elseif event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Play and player:getMark("&KILLgeneral") > 0 then --斩将奖励
	    	room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName(), 2)
			local n = player:getMark("&KILLgeneral")
			room:drawCards(player, n, "sp_guoguanzhanjiang_RAP")
			if n > 1 then
				local rec = sgs.RecoverStruct()
				rec.who = player
				rec.recover = n - 1
				room:recover(player, rec)
			end
			if n > 2 then
				local count = player:getMaxHp()
				local mhp = sgs.QVariant()
				mhp:setValue(count + n - 2)
				room:setPlayerProperty(player, "maxhp", mhp)
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("sp_guoguanzhanjiang")
	end,
}
if not sgs.Sanguosha:getSkill("sp_guoguanzhanjiang_RAP") then skills:append(sp_guoguanzhanjiang_RAP) end

sp_weizhen = sgs.CreateViewAsSkill{
	name = "sp_weizhen",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isBlack() and (to_select:getTypeId() == sgs.Card_TypeBasic or to_select:getTypeId() == sgs.Card_TypeTrick)
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local DWN = sgs.Sanguosha:cloneCard("drowning", cards[1]:getSuit(), cards[1]:getNumber())
			DWN:addSubcard(cards[1])
			DWN:setSkillName(self:objectName())
			return DWN
		end
	end,
	enabled_at_play = function(self, player)
	    return player:hasSkill(self:objectName())
	end,
}
sp_weizhen_limited = sgs.CreateTriggerSkill{
    name = "sp_weizhen_limited",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.from:objectName() == player:objectName() and use.card:getSkillName() == "sp_weizhen" then
				room:addPlayerMark(player, "sp_weizhen_used")
				local n = player:getMark("sp_weizhen_used")
				if n == 2 then
					room:loseHp(player, 1)
				elseif n >= 3 then
					room:loseMaxHp(player, 1)
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
                return false
            end
			for _, spsgy in sgs.qlist(room:getAllPlayers()) do
			    if spsgy:getMark("sp_weizhen_used") > 0 then
				    local m = spsgy:getMark("sp_weizhen_used")
					room:removePlayerMark(spsgy, "sp_weizhen_used", m)
					break
				end
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("sp_weizhen")
	end,
}
sp_shenguanyu:addSkill(sp_weizhen)
if not sgs.Sanguosha:getSkill("sp_weizhen_limited") then skills:append(sp_weizhen_limited) end

sp_xianshengCard = sgs.CreateSkillCard{
    name = "sp_xianshengCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets < 3 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		for _, p in sgs.list(targets) do
		    room:drawCards(p, 2, "sp_xiansheng")
			local recover = sgs.RecoverStruct()
			recover.who = p
			room:recover(p, recover)
		end
	end,
}
sp_xianshengVS = sgs.CreateZeroCardViewAsSkill{
    name = "sp_xiansheng",
    view_as = function()
		return sp_xianshengCard:clone()
	end,
	response_pattern = "@@sp_xiansheng",
}
sp_xiansheng = sgs.CreateTriggerSkill{
	name = "sp_xiansheng",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Death},
	view_as_skill = sp_xianshengVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		if death.who:objectName() ~= player:objectName() then return false end
		if room:askForSkillInvoke(player, self:objectName(), data) then
			room:askForUseCard(player, "@@sp_xiansheng", "@sp_xiansheng-card")
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill(self:objectName())
	end,
}
sp_shenguanyu:addSkill(sp_xiansheng)

--20 风神·吕蒙
sp_shenlvmeng = sgs.General(extension_G, "sp_shenlvmeng", "god", 4, true)

sp_guamuCard = sgs.CreateSkillCard{
	name = "sp_guamuCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
	    return #targets == 0
	end,
	on_use = function(self, room, source, targets)
	    local choice1 = room:askForChoice(targets[1], "sp_guamu", "sp_guamuBasic+sp_guamuTrick+sp_guamuEquip")
		if choice1 == "sp_guamuBasic" then
			room:setPlayerFlag(source, "sp_guamuBasic")
			local log = sgs.LogMessage()
			log.type = "$sp_guamuBasic"
			log.from = targets[1]
			room:sendLog(log)
		elseif choice1 == "sp_guamuTrick" then
			room:setPlayerFlag(source, "sp_guamuTrick")
			local log = sgs.LogMessage()
			log.type = "$sp_guamuTrick"
			log.from = targets[1]
			room:sendLog(log)
		elseif choice1 == "sp_guamuEquip" then
			room:setPlayerFlag(source, "sp_guamuEquip")
			local log = sgs.LogMessage()
			log.type = "$sp_guamuEquip"
			log.from = targets[1]
			room:sendLog(log)
		end
		local card_ids = room:getNCards(3)
		room:fillAG(card_ids)
		room:broadcastSkillInvoke("sp_guamu", 1)
		room:getThread():delay()
		local to_get = sgs.IntList()
		local to_throw = sgs.IntList()
		for _, c in sgs.qlist(card_ids) do
			local card = sgs.Sanguosha:getCard(c)
			if source:hasFlag("sp_guamuBasic") then
				if card:isKindOf("BasicCard") then
					to_get:append(c)
					room:addPlayerMark(source, "&sp_guamu")
				else
					to_throw:append(c)
				end
			end
			if source:hasFlag("sp_guamuTrick") then
				if card:isKindOf("TrickCard") then
					to_get:append(c)
					room:addPlayerMark(source, "&sp_guamu")
				else
					to_throw:append(c)
				end
			end
			if source:hasFlag("sp_guamuEquip") then
				if card:isKindOf("EquipCard") then
					to_get:append(c)
					room:addPlayerMark(source, "&sp_guamu")
				else
					to_throw:append(c)
				end
			end
		end
		local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		if not to_get:isEmpty() then
			for _, id in sgs.qlist(to_get) do
				dummy:addSubcard(id)
			end
			if targets[1]:objectName() ~= source:objectName() then
				local choice2 = room:askForChoice(source, "sp_guamu", "1+2")
				if choice2 == "1" then
					targets[1]:obtainCard(dummy)
				elseif choice2 == "2" then
					source:obtainCard(dummy)
				end
			else
				room:getThread():delay()
				source:obtainCard(dummy)
			end
		end
		dummy:clearSubcards()
		if not to_throw:isEmpty() then
			dummy:addSubcards(getCardList(to_throw))
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, source:objectName(), "sp_guamu", "")
			room:throwCard(dummy, reason, nil)
		end
		room:clearAG()
		local n = source:getMark("&sp_guamu")
		if n >= 1 then
			room:broadcastSkillInvoke("sp_guamu", 2)
			room:drawCards(source, 1, "sp_guamu")
			local choice3 = room:askForChoice(source, "sp_guamuONE", "sp_guamuONEthrow+sp_guamuONEput")
			if choice3 == "sp_guamuONEthrow" then
				room:askForDiscard(source, "sp_guamu", 1, 1, false, true)
			elseif choice3 == "sp_guamuONEput" then
				local cardd = room:askForCardChosen(source, source, "he", "sp_guamu")
				if cardd then
					room:setPlayerFlag(source, "sp_guamuPUT")
					local reasonx = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, source:objectName(), nil, "sp_guamu", nil)
					room:moveCardTo(sgs.Sanguosha:getCard(cardd), source, nil, sgs.Player_DrawPile, reasonx, false)
					room:setPlayerFlag(source, "-sp_guamuPUT")
				end
			end
		end
		if n >= 2 then
			room:broadcastSkillInvoke("sp_guamu", 3)
			local recover = sgs.RecoverStruct()
			recover.who = source
			room:recover(source, recover)
		end
		if n >= 3 then
			room:broadcastSkillInvoke("sp_guamu", 4)
			room:acquireOneTurnSkills(source, "sp_guamu", "gongxin")
		end
		room:removePlayerMark(source, "&sp_guamu", n)
	end,
}
sp_guamu = sgs.CreateZeroCardViewAsSkill{
    name = "sp_guamu",
	view_as = function()
		return sp_guamuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#sp_guamuCard")
	end,
}
sp_shenlvmeng:addSkill(sp_guamu)

sp_dujiangCard = sgs.CreateSkillCard{
	name = "sp_dujiangCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
	    return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
	    local room = effect.to:getRoom()
		room:setPlayerFlag(effect.from, "sp_dujiangSource")
		room:setPlayerFlag(effect.to, "sp_dujiangTarget")
		room:setFixedDistance(effect.from, effect.to, 1)
		local new_data = sgs.QVariant()
		new_data:setValue(effect.to)
		effect.from:setTag("sp_dujiang", new_data)
	end,
}
sp_dujiang = sgs.CreateOneCardViewAsSkill{
    name = "sp_dujiang",
	filter_pattern = "EquipCard",
	view_as = function(self, card)
		local boat = sp_dujiangCard:clone()
		boat:addSubcard(card:getId())
		boat:setSkillName(self:objectName())
		return boat
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#sp_dujiangCard")
	end,
}
sp_dujiangxijing = sgs.CreateTargetModSkill{
	name = "sp_dujiangxijing",
	residue_func = function(self, from, card, to)
		if from and from:hasFlag("sp_dujiangSource") and card and to and to:hasFlag("sp_dujiangTarget") then
			return 1000
		else
			return 0
		end
	end,
}
--重置距离
sp_dujiangFixedDistanceClear = sgs.CreateTriggerSkill{
	name = "sp_dujiangFixedDistanceClear",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then
			return false
		end
		local jingzhou = player:getTag("sp_dujiang"):toPlayer() 
		if jingzhou then
			room:setFixedDistance(player, jingzhou, -1)
		end
		player:removeTag("sp_dujiang")
	end,
	can_trigger = function(self, player)
		return player
	end,
}
sp_shenlvmeng:addSkill(sp_dujiang)
if not sgs.Sanguosha:getSkill("sp_dujiangxijing") then skills:append(sp_dujiangxijing) end
if not sgs.Sanguosha:getSkill("sp_dujiangFixedDistanceClear") then skills:append(sp_dujiangFixedDistanceClear) end





--

--21 火神·周瑜
sp_shenzhouyu = sgs.General(extension_G, "sp_shenzhouyu", "god", 4, true)

sp_qinmo = sgs.CreateTriggerSkill{
    name = "sp_qinmo",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
	    if player:getPhase() == sgs.Player_Play and room:askForSkillInvoke(player, self:objectName(), data) then
		    local choices = {}
			table.insert(choices, "sp_qinmoloseHp")
			table.insert(choices, "sp_qinmoaddHp")
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			if choice == "sp_qinmoloseHp" then
			    local plistls = room:getAllPlayers()
				local victim = room:askForPlayerChosen(player, plistls, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:loseHp(victim, 1)
				room:setPlayerFlag(player, "Global_PlayPhaseTerminated")
			elseif choice == "sp_qinmoaddHp" then
			    local plistad = room:getAllPlayers()
				local beneficiary = room:askForPlayerChosen(player, plistad, self:objectName())
                local recover = sgs.RecoverStruct()
				recover.who = beneficiary
				room:recover(beneficiary, recover)
				room:broadcastSkillInvoke(self:objectName())
                room:setPlayerFlag(player, "Global_PlayPhaseTerminated")
            end
        end
    end,
}
sp_shenzhouyu:addSkill(sp_qinmo)

sp_huoshen = sgs.CreateTriggerSkill{
	name = "sp_huoshen",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local caobs = damage.to
		if player:hasSkill(self:objectName()) and player:inMyAttackRange(caobs) and damage.nature == sgs.DamageStruct_Fire then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			local fire = damage.damage
			damage.damage = fire + 1
			data:setValue(damage)
			room:broadcastSkillInvoke(self:objectName())
		end
	end,
}
sp_shenzhouyu:addSkill(sp_huoshen)

Fire = function(player, target, damagePoint)
	local damage = sgs.DamageStruct()
	damage.from = player
	damage.to = target
	damage.damage = damagePoint
	damage.nature = sgs.DamageStruct_Fire
	player:getRoom():damage(damage)
end
function toSet(self)
	local set = {}
	for _, ele in pairs(self) do
		if not table.contains(set, ele) then
			table.insert(set, ele)
		end
	end
	return set
end
sp_chibiCard = sgs.CreateSkillCard{
	name = "sp_chibiCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
	    room:removePlayerMark(source, "@sp_chibi")
		room:addPlayerMark(source, "sp_chibi_using")
	    room:broadcastSkillInvoke("sp_chibi")
		room:doLightbox("sp_chibiAnimate")
		local players = room:getOtherPlayers(source)
		for _, player in sgs.qlist(players) do
			Fire(source, player, 1)
		end
		if source:getMark("sp_chibikill") > 0 then
		    source:drawCards(4, "sp_chibi")
		end
		room:removePlayerMark(source, "sp_chibi_using")
		room:addPlayerMark(source, "sp_chibi_used")
	end,
}
sp_chibiVS = sgs.CreateZeroCardViewAsSkill{
    name = "sp_chibi",
	view_as = function()
		return sp_chibiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@sp_chibi") > 0
	end,
}
sp_chibi = sgs.CreateTriggerSkill{
	name = "sp_chibi",
	frequency = sgs.Skill_Limited,
	limit_mark = "@sp_chibi",
	view_as_skill = sp_chibiVS,
	on_trigger = function()
	end,
}
sp_chibiCount = sgs.CreateTriggerSkill{
	name = "sp_chibiCount",
	events = {sgs.Death},
	global = true,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		if death.who:objectName() ~= player:objectName() then return false end
		local killer
		if death.damage then
			killer = death.damage.from
		else
			killer = nil
		end
		local current = room:getCurrent()
		if killer and killer:getMark("sp_chibi_using") > 0 and current and (current:isAlive() or current:objectName() == death.who:objectName()) then
			killer:addMark("sp_chibikill")
		end
	end,
}
sp_shenzhouyu:addSkill(sp_chibi)
if not sgs.Sanguosha:getSkill("sp_chibiCount") then skills:append(sp_chibiCount) end

sp_qiangu = sgs.CreateTriggerSkill{
    name = "sp_qiangu",
	frequency = sgs.Skill_Wake,
	waked_skills = "sp_shenzi",
	events = {sgs.EventPhaseStart},
	can_wake = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getMark("sp_chibi_used") < 1 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		room:doLightbox("$sp_qiangu")
		room:loseMaxHp(player, 1)
		if not player:hasSkill("sp_shenzi") then
		    room:acquireSkill(player, "sp_shenzi")
		end
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
	end,
	can_trigger = function(self, player)
	    return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
sp_shenzhouyu:addSkill(sp_qiangu)
sp_shenzhouyu:addRelateSkill("sp_shenzi")
--“神姿”
sp_shenzi = sgs.CreateTriggerSkill{
    name = "sp_shenzi",
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, "sp_shenzi", data) then
		    local choices = {}
			table.insert(choices, "sp_shenzi3cards")
			table.insert(choices, "sp_shenzi4cards")
			table.insert(choices, "sp_shenzi1card")
			table.insert(choices, "sp_shenzi0card")
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			
			if choice == "sp_shenzi3cards" then
			    local count3 = data:toInt() + 1
			    data:setValue(count3)
				room:broadcastSkillInvoke(self:objectName())
			elseif choice == "sp_shenzi4cards" then
			    local count4 = data:toInt() + 2
			    data:setValue(count4)
				room:setPlayerFlag(player, "sp_shenzi_4cards")
				room:broadcastSkillInvoke(self:objectName())
			elseif choice == "sp_shenzi1card" then
			    local count1 = data:toInt() - 1
				if count1 < 0 then
				    count1 = 0
				end
			    data:setValue(count1)
				room:setPlayerFlag(player, "sp_shenzi_1card")
				room:broadcastSkillInvoke(self:objectName())
			elseif choice == "sp_shenzi0card" then
			    local count0 = data:toInt() - 2
				if count0 < 0 then
				    count0 = 0
				end
			    data:setValue(count0)
				local plist = room:getOtherPlayers(player)
		        local victim = room:askForPlayerChosen(player, plist, self:objectName())
		        local damage = sgs.DamageStruct()
		        damage.from = player
		        damage.to = victim
		        damage.nature = sgs.DamageStruct_Fire
		        room:damage(damage)
				room:broadcastSkillInvoke(self:objectName())
			end
		end
	end,
}
sp_shenzi4c = sgs.CreateMaxCardsSkill{
	name = "sp_shenzi4c",
	extra_func = function(self, target)
		if target:hasSkill("sp_shenzi") and target:hasFlag("sp_shenzi_4cards") then
			return -1
		else
			return 0
		end
	end,
}
sp_shenzi1c = sgs.CreateMaxCardsSkill{
	name = "sp_shenzi1c",
	extra_func = function(self, target)
		if target:hasSkill("sp_shenzi") and target:hasFlag("sp_shenzi_1card") then
			return 2
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("sp_shenzi") then skills:append(sp_shenzi) end
if not sgs.Sanguosha:getSkill("sp_shenzi4c") then skills:append(sp_shenzi4c) end
if not sgs.Sanguosha:getSkill("sp_shenzi1c") then skills:append(sp_shenzi1c) end

--22 天神·诸葛
sp_shenzhuge = sgs.General(extension_G, "sp_shenzhuge", "god", 4, true)

sp_zhishen = sgs.CreateTriggerSkill{
	name = "sp_zhishen",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isNDTrick() and use.card:isRed() then
			player:gainMark("&ShenZhi", 2)
			room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
		elseif use.card:isNDTrick() and use.card:isBlack() then
			player:gainMark("&ShenZhi", 1)
			room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
		elseif use.card:isKindOf("DelayedTrick") then
			player:drawCards(3, self:objectName())
			room:broadcastSkillInvoke(self:objectName(), 3)
		end
	end,
}
sp_zhishenX = sgs.CreateProhibitSkill{
	name = "sp_zhishenX",
	global = true,
	is_prohibited = function(self, from, to, card)
		return to:hasSkill("sp_zhishen") and card:isKindOf("DelayedTrick")
	end,
}
sp_shenzhuge:addSkill(sp_zhishen)
if not sgs.Sanguosha:getSkill("sp_zhishenX") then skills:append(sp_zhishenX) end

sp_zhengshen = sgs.CreateTriggerSkill{
	name = "sp_zhengshen",
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, "sp_zhengshen", data) then
			local count = data:toInt() + 2
			data:setValue(count)
			room:broadcastSkillInvoke(self:objectName())
			room:addPlayerMark(player, "sp_zhengshen_used")
		end
	end,
}
sp_zhengshenGCCard = sgs.CreateSkillCard{
    name = "sp_zhengshenGCCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
	    return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
	    targets[1]:obtainCard(self, false)
	end,
}
sp_zhengshenGCVS = sgs.CreateViewAsSkill{
    name = "sp_zhengshenGC",
	n = 1,
	view_filter = function(self, selected, to_select)
	    return not to_select:isEquipped()
	end,
    view_as = function(self, cards)
	    if #cards == 0 then return end
		local vs_card = sp_zhengshenGCCard:clone()
		vs_card:addSubcard(cards[1])
		return vs_card
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@sp_zhengshenGC")
	end,
}
sp_zhengshenGC = sgs.CreateTriggerSkill{
    name = "sp_zhengshenGC",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = sp_zhengshenGCVS,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play and player:getMark("sp_zhengshen_used") > 0 then
		    if room:askForSkillInvoke(player, "@sp_zhengshenGC", data) then
		        room:askForUseCard(player, "@@sp_zhengshenGC!", "@sp_zhengshenGC-card1")
		        room:askForUseCard(player, "@@sp_zhengshenGC!", "@sp_zhengshenGC-card2")
				room:removePlayerMark(player, "sp_zhengshen_used")
			else
			    room:askForDiscard(player, self:objectName(), 2, 2)
			    room:removePlayerMark(player, "sp_zhengshen_used")
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:getMark("sp_zhengshen_used") > 0
	end,
}
sp_shenzhuge:addSkill(sp_zhengshen)
if not sgs.Sanguosha:getSkill("sp_zhengshenGC") then skills:append(sp_zhengshenGC) end

sp_junshen = sgs.CreateDistanceSkill{
	name = "sp_junshen",
	correct_func = function(self, from, to)
		if from:hasSkill(self:objectName()) then
			local equips = from:getEquips()
			local length = equips:length()
			return -length
		end
	end,
}
sp_shenzhuge:addSkill(sp_junshen)

sp_qitian = sgs.CreateTriggerSkill{
    name = "sp_qitian",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:hasSkill(self:objectName()) then
		    
			for _, tszg in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
		        if tszg:getMark("&ShenZhi") > 0 and tszg:getPhase() == sgs.Player_Judge and room:askForSkillInvoke(tszg, self:objectName(), data) then
			        room:addPlayerMark(tszg, self:objectName().."engine")
				    if tszg:getMark(self:objectName().."engine") > 0 then
					    local choices = {}
					    if tszg:getMark("&ShenZhi") >= 1 then
					        table.insert(choices, "remove1szmark")
					    end
					    if tszg:getMark("&ShenZhi") >= 2 then
					        table.insert(choices, "remove2szmarks")
					    end
					    if tszg:getMark("&ShenZhi") >= 3 then
					        table.insert(choices, "remove3szmarks")
					    end
						if tszg:getMark("&ShenZhi") >= 4 then
					        table.insert(choices, "remove4szmarks")
					    end
						table.insert(choices, "cancel")
						local choice = room:askForChoice(tszg, self:objectName(), table.concat(choices, "+"))
						if choice == "remove1szmark" then
						    room:removePlayerMark(tszg, "&ShenZhi", 1)
						    local judge = sgs.JudgeStruct()
						    judge.pattern = "."
						    judge.good = true
						    judge.play_animation = false
						    judge.who = tszg
						    judge.reason = self:objectName()
						    room:judge(judge)
						    local suit = judge.card:getSuit()
						    if suit == sgs.Card_Heart then --摸1、弃2、回1
							    tszg:drawCards(1, self:objectName())
								room:askForDiscard(tszg, self:objectName(), 2, 2, false, true)
								local recover1 = sgs.RecoverStruct()
				                recover1.who = tszg
				                room:recover(tszg, recover1)
								room:broadcastSkillInvoke("sp_qitian", 1)
						    elseif suit == sgs.Card_Diamond then --获得4枚“神智”标记，获得“界火计”
							    tszg:gainMark("&ShenZhi", 4)
								if not tszg:hasSkill("olhuoji") then
								    room:acquireSkill(tszg, "olhuoji")
									room:addPlayerMark(tszg, "sp_qitianaddskill_data") --防止原本有“界火计”的武将于回合结束被误删技能
								end
								room:broadcastSkillInvoke("sp_qitian", 2)
						    elseif suit == sgs.Card_Club then --令目标(永久)获得1枚“狂风”标记
							    local plist1c = room:getAllPlayers()
								local victim1c = room:askForPlayerChosen(tszg, plist1c, self:objectName())
							    victim1c:gainMark("@sp_crazywind") --为了防止与神诸葛亮同时在场时“狂风”标记于其回合开始时被清掉，另设了一个和原“狂风”标记(@gale)中文名称和用处都一样，但时效不一样的“狂风”标记(@sp_crazywind)。
								room:broadcastSkillInvoke("sp_qitian", 3)
						    elseif suit == sgs.Card_Spade then --弃置目标1张牌，再自弃1张牌
							    local plist1s = room:getAllPlayers()
					            local victim1s = room:askForPlayerChosen(tszg, plist1s, self:objectName())
								if not victim1s:isNude() then
			                        local id1s = room:askForCardChosen(tszg, victim1s, "he", self:objectName())
					                room:throwCard(id1s, victim1s, tszg)
								end
							    room:askForDiscard(tszg, self:objectName(), 1, 1, false, true)
							end
						elseif choice == "remove2szmarks" then
						    room:removePlayerMark(tszg, "&ShenZhi", 2)
						    local judge = sgs.JudgeStruct()
						    judge.pattern = "."
						    judge.good = true
						    judge.play_animation = false
						    judge.who = tszg
						    judge.reason = self:objectName()
						    room:judge(judge)
						    local suit = judge.card:getSuit()
						    if suit == sgs.Card_Heart then --摸2、弃2、回1
							    tszg:drawCards(2, self:objectName())
								room:askForDiscard(tszg, self:objectName(), 2, 2, false, true)
								local recover2 = sgs.RecoverStruct()
				                recover2.who = tszg
				                room:recover(tszg, recover2)
								room:broadcastSkillInvoke("sp_qitian", 1)
						    elseif suit == sgs.Card_Diamond then --获得4枚“神智”标记，获得“界火计”
							    tszg:gainMark("&ShenZhi", 4)
								if not tszg:hasSkill("olhuoji") then
								    room:acquireSkill(tszg, "olhuoji")
									room:addPlayerMark(tszg, "sp_qitianaddskill_data")
								end
								room:broadcastSkillInvoke("sp_qitian", 2)
						    elseif suit == sgs.Card_Club then --令目标(永久)获得1枚“狂风”标记
							    local plist2c = room:getAllPlayers()
								local victim2c = room:askForPlayerChosen(tszg, plist2c, self:objectName())
							    victim2c:gainMark("@sp_crazywind")
								room:broadcastSkillInvoke("sp_qitian", 3)
						    elseif suit == sgs.Card_Spade then --对目标造成1点雷电伤害，然后弃置其1张牌，再自弃2张牌
							    local plist2s = room:getAllPlayers()
					            local victim2s = room:askForPlayerChosen(tszg, plist2s, self:objectName())
								room:broadcastSkillInvoke("sp_qitian", 4)
								room:damage(sgs.DamageStruct(self:objectName(), tszg, victim2s, 1, sgs.DamageStruct_Thunder))
								if victim2s:isAlive() and not victim2s:isNude() then
			                        local id2s = room:askForCardChosen(tszg, victim2s, "he", self:objectName())
					                room:throwCard(id2s, victim2s, tszg)
								end
							    room:askForDiscard(tszg, self:objectName(), 2, 2, false, true)
							end
						elseif choice == "remove3szmarks" then
						    room:removePlayerMark(tszg, "&ShenZhi", 3)
						    local judge = sgs.JudgeStruct()
						    judge.pattern = "."
						    judge.good = true
						    judge.play_animation = false
						    judge.who = tszg
						    judge.reason = self:objectName()
						    room:judge(judge)
						    local suit = judge.card:getSuit()
						    if suit == sgs.Card_Heart then --摸3、弃2、回1
							    tszg:drawCards(3, self:objectName())
								room:askForDiscard(tszg, self:objectName(), 2, 2, false, true)
								local recover3 = sgs.RecoverStruct()
				                recover3.who = tszg
				                room:recover(tszg, recover3)
								room:broadcastSkillInvoke("sp_qitian", 1)
						    elseif suit == sgs.Card_Diamond then --获得4枚“神智”标记，获得“界火计”
							    tszg:gainMark("&ShenZhi", 4)
								if not tszg:hasSkill("olhuoji") then
								    room:acquireSkill(tszg, "olhuoji")
									room:addPlayerMark(tszg, "sp_qitianaddskill_data")
								end
								room:broadcastSkillInvoke("sp_qitian", 2)
						    elseif suit == sgs.Card_Club then --令目标(永久)获得1枚“狂风”标记
							    local plist3c = room:getAllPlayers()
								local victim3c = room:askForPlayerChosen(tszg, plist3c, self:objectName())
							    victim3c:gainMark("@sp_crazywind")
								room:broadcastSkillInvoke("sp_qitian", 3)
						    elseif suit == sgs.Card_Spade then --对目标造成2点雷电伤害，然后弃置其1张牌，再自弃3张牌
							    local plist3s = room:getAllPlayers()
					            local victim3s = room:askForPlayerChosen(tszg, plist3s, self:objectName())
								room:broadcastSkillInvoke("sp_qitian", 4)
								room:damage(sgs.DamageStruct(self:objectName(), tszg, victim3s, 2, sgs.DamageStruct_Thunder))
								if victim3s:isAlive() and not victim3s:isNude() then
			                        local id3s = room:askForCardChosen(tszg, victim3s, "he", self:objectName())
					                room:throwCard(id3s, victim3s, tszg)
								end
							    room:askForDiscard(tszg, self:objectName(), 3, 3, false, true)
							end
						elseif choice == "remove4szmarks" then
						    room:removePlayerMark(tszg, "&ShenZhi", 4)
						    local judge = sgs.JudgeStruct()
						    judge.pattern = "."
						    judge.good = true
						    judge.play_animation = false
						    judge.who = tszg
						    judge.reason = self:objectName()
						    room:judge(judge)
						    local suit = judge.card:getSuit()
						    if suit == sgs.Card_Heart then --摸4、弃2、回1
							    tszg:drawCards(4, self:objectName())
								room:askForDiscard(tszg, self:objectName(), 2, 2, false, true)
								local recover4 = sgs.RecoverStruct()
				                recover4.who = tszg
				                room:recover(tszg, recover4)
								room:broadcastSkillInvoke("sp_qitian", 1)
						    elseif suit == sgs.Card_Diamond then --获得4枚“神智”标记，获得“界火计”
							    tszg:gainMark("&ShenZhi", 4)
								if not tszg:hasSkill("olhuoji") then
								    room:acquireSkill(tszg, "olhuoji")
									room:addPlayerMark(tszg, "sp_qitianaddskill_data")
								end
								room:broadcastSkillInvoke("sp_qitian", 2)
						    elseif suit == sgs.Card_Club then --令目标(永久)获得1枚“狂风”标记，然后对其造成1点火焰伤害
							    local plist4c = room:getAllPlayers()
								local victim4c = room:askForPlayerChosen(tszg, plist4c, self:objectName())
							    victim4c:gainMark("@sp_crazywind")
								room:broadcastSkillInvoke("sp_qitian", 3)
								room:damage(sgs.DamageStruct(self:objectName(), tszg, victim4c, 1, sgs.DamageStruct_Fire))
						    elseif suit == sgs.Card_Spade then --对目标造成3点雷电伤害，然后弃置其2张牌，再自弃4张牌
							    local plist4s = room:getAllPlayers()
					            local victim4s = room:askForPlayerChosen(tszg, plist4s, self:objectName())
								room:broadcastSkillInvoke("sp_qitian", 4)
								room:damage(sgs.DamageStruct(self:objectName(), tszg, victim4s, 3, sgs.DamageStruct_Thunder))
								if victim4s:isAlive() and not victim4s:isNude() then
			                        local id4s1 = room:askForCardChosen(tszg, victim4s, "he", self:objectName())
					                room:throwCard(id4s1, victim4s, tszg)
									if not victim4s:isNude() then
								        local id4s2 = room:askForCardChosen(tszg, victim4s, "he", self:objectName())
								        room:throwCard(id4s2, victim4s, tszg)
									end
								end
							    room:askForDiscard(tszg, self:objectName(), 4, 4, false, true)
							end
						end
					end
					room:removePlayerMark(tszg, self:objectName().."engine")
				end
			end
			
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill(self:objectName()) and player:getMark("&ShenZhi") >= 1
    end,
}
sp_qitian_crazywind = sgs.CreateTriggerSkill{ --赋予“狂风”标记相应的技能
	name = "sp_qitian_crazywind",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageForseen},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local n = player:getMark("@sp_crazywind")
		if damage.nature == sgs.DamageStruct_Fire then
			damage.damage = damage.damage + n --火焰伤害会随着“狂风”标记的叠加而叠加
			data:setValue(damage)
		end
	end,
	can_trigger = function(self, player)
		return player ~= nil and player:getMark("@sp_crazywind") > 0
	end,
}
sp_qitian_SkillClear = sgs.CreateTriggerSkill{
    name = "sp_qitian_SkillClear",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then
			return false
		end
		local plist = room:getAllPlayers()
		for _, p in sgs.qlist(plist) do
		    if player:hasSkill("olhuoji") and player:getMark("sp_qitianaddskill_data") > 0 then
			    room:detachSkillFromPlayer(player, "olhuoji", false, true)
				room:removePlayerMark(player, "sp_qitianaddskill_data")
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("sp_qitian") and player:getMark("sp_qitianaddskill_data") > 0
	end,
}
sp_shenzhuge:addSkill(sp_qitian)
if not sgs.Sanguosha:getSkill("sp_qitian_crazywind") then skills:append(sp_qitian_crazywind) end
if not sgs.Sanguosha:getSkill("sp_qitian_SkillClear") then skills:append(sp_qitian_SkillClear) end

sp_zhijueDying = sgs.CreateTriggerSkill{
    name = "sp_zhijueDying",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EnterDying},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:addPlayerMark(player, "sp_zhijueDying")
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("sp_zhijue") and player:isAlive() and player:getMark("sp_zhijueDying") == 0
	end,
}
sp_zhijue = sgs.CreateTriggerSkill{
	name = "sp_zhijue",
	frequency = sgs.Skill_Wake,
	waked_skills = "bazhen, sp_guimen",
	events = {sgs.EventPhaseStart},
	can_wake = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getHp() == 1 and player:getHandcardNum() <= 1 then return true end
		if player:getHp() == 1 and player:getMark("sp_zhijueDying") >= 1 then return true end
		if player:getHandcardNum() <= 1 and player:getMark("sp_zhijueDying") >= 1 then return true end
		return false
	end,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:doLightbox("$sp_zhijue")
		room:loseMaxHp(player, 1)
		player:gainMark("@sp_fog")
		if not player:hasSkill("bazhen") then
		    room:acquireSkill(player, "bazhen")
		end
		if not player:hasSkill("sp_guimen") then
		    room:acquireSkill(player, "sp_guimen")
		end
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
	end,
	can_trigger = function(self, player)
	    return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
sp_zhijue_fog = sgs.CreateTriggerSkill{ --赋予“大雾”标记相应的技能
	name = "sp_zhijue_fog",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageForseen},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.nature ~= sgs.DamageStruct_Thunder then
			return true
		else
			return false
		end
	end,
	can_trigger = function(self, player)
		return player ~= nil and player:getMark("@sp_fog") > 0
	end,
}
fog_Clear = sgs.CreateTriggerSkill{ --清除“大雾”标记
    name = "fog_Clear",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TurnStart},
	on_trigger = function(self, event, player, data)
		player:loseMark("@sp_fog")
	end,
	can_trigger = function(self, player)
		return player:getMark("@sp_fog") > 0
	end,
}
sp_shenzhuge:addSkill(sp_zhijue)
sp_shenzhuge:addRelateSkill("bazhen")
sp_shenzhuge:addRelateSkill("sp_guimen")
if not sgs.Sanguosha:getSkill("sp_zhijueDying") then skills:append(sp_zhijueDying) end
if not sgs.Sanguosha:getSkill("sp_zhijue_fog") then skills:append(sp_zhijue_fog) end
if not sgs.Sanguosha:getSkill("fog_Clear") then skills:append(fog_Clear) end
--“鬼门”
Thunder = function(player, target, damagePoint)
	local damage = sgs.DamageStruct()
	damage.from = player
	damage.to = target
	damage.damage = damagePoint
	damage.nature = sgs.DamageStruct_Thunder
	player:getRoom():damage(damage)
end
function toSet(self)
	local set = {}
	for _, ele in pairs(self) do
		if not table.contains(set, ele) then
			table.insert(set, ele)
		end
	end
	return set
end
sp_guimenCard = sgs.CreateSkillCard{
    name = "sp_guimenCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:doLightbox("$sp_guimenn")
		local n = source:getMark("&ShenZhi")
		room:removePlayerMark(source, "&ShenZhi", n)
		for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			Thunder(source, p, math.random(1,3))
		end
	end,
}
sp_guimen = sgs.CreateZeroCardViewAsSkill{
	name = "sp_guimen",
	view_as = function()
		return sp_guimenCard:clone()
	end,
	    enabled_at_play = function(self, player)
		return not player:hasUsed("#sp_guimenCard") and player:getMark("&ShenZhi") > 9
	end,
}
if not sgs.Sanguosha:getSkill("sp_guimen") then skills:append(sp_guimen) end

--23 君神·曹操
sp_shencaocao = sgs.General(extension_G, "sp_shencaocao", "god", 4, true, false, false, 3)

sp_zhujiuStartandEnd = sgs.CreateTriggerSkill{
	name = "sp_zhujiuStartandEnd",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart and player:hasSkill("sp_zhujiu") then
			if player:getPhase() == sgs.Player_Play and room:askForSkillInvoke(player, "sp_zhujiu", data) then
				room:drawCards(player, 2, "sp_zhujiu")
				local liubei = room:askForPlayerChosen(player, room:getOtherPlayers(player), "sp_zhujiu", "CaL_zhujiuLYX")
				room:broadcastSkillInvoke("sp_zhujiu")
				player:gainMark("&qingmei_zhujiu", 1)
				liubei:gainMark("&qingmei_zhujiu", 1)
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Play then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:getMark("&qingmei_zhujiu") > 0 then
						p:loseAllMarks("&qingmei_zhujiu")
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
sp_zhujiuCard = sgs.CreateSkillCard{
    name = "sp_zhujiuCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and to_select:getMark("&qingmei_zhujiu") > 0 and not to_select:isKongcheng()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		effect.from:pindian(effect.to, "sp_zhujiu", nil)
		if effect.from:getMark("&sp_zhujiuFQC") <= 10 and effect.from:getMark("@duangexing") > 0 then
			room:addPlayerMark(effect.from, "&sp_zhujiuFQC")
		end
	end,
}
sp_zhujiu = sgs.CreateZeroCardViewAsSkill{
    name = "sp_zhujiu",
    view_as = function()
		return sp_zhujiuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("&qingmei_zhujiu") > 0 and not player:isKongcheng() and not player:hasFlag("sp_zhujiulimited")
	end,
}
sp_zhujiuPindian = sgs.CreateTriggerSkill{
    name = "sp_zhujiuPindian",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.Pindian},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.Pindian then
			local pindian = data:toPindian()
			if pindian.reason == "sp_zhujiu" and pindian.from:objectName() == player:objectName() then
				local fromNumber = pindian.from_card:getNumber()
				local toNumber = pindian.to_card:getNumber()
				if not player:hasFlag("sp_zhujiugetPindianCards_used") then
					if room:askForSkillInvoke(player, "@sp_zhujiugetPindianCards", data) then
						room:broadcastSkillInvoke("sp_zhujiu")
						room:obtainCard(player, pindian.from_card)
						room:obtainCard(player, pindian.to_card)
						room:setPlayerFlag(player, "sp_zhujiugetPindianCards_used")
					end
				end
				if fromNumber > toNumber then
					local ana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
					ana:setSkillName("sp_zhujiu")
					room:useCard(sgs.CardUseStruct(ana, player, player, false))
					if (player:getMark("&sp_zhujiuFQC") <= 10 and player:getMark("@duangexing") > 0) then
					room:addPlayerMark(player, "&sp_zhujiuFQC") end
					room:broadcastSkillInvoke("sp_zhujiu")
				else
					room:setPlayerFlag(player, "sp_zhujiuPDlose")
					player:turnOver()
					if player:hasFlag("sp_zhujiuPDlose") and not player:faceUp() then
						if not player:isKongcheng() then
							room:askForDiscard(player, "sp_zhujiu", 1, 1)
						end
						room:setPlayerFlag(player, "-sp_zhujiuPDlose")
					elseif player:hasFlag("sp_zhujiuPDlose") and player:faceUp() then
						if not player:isNude() then
							local id = room:askForCardChosen(pindian.to, player, "he", "sp_zhujiu", false, sgs.Card_MethodDiscard)
							room:throwCard(id, player, pindian.to)
						end
						room:setPlayerFlag(player, "sp_zhujiulimited")
						room:setPlayerFlag(player, "-sp_zhujiuPDlose")
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
sp_shencaocao:addSkill(sp_zhujiu)
if not sgs.Sanguosha:getSkill("sp_zhujiuStartandEnd") then skills:append(sp_zhujiuStartandEnd) end
if not sgs.Sanguosha:getSkill("sp_zhujiuPindian") then skills:append(sp_zhujiuPindian) end

sp_gexingCard = sgs.CreateSkillCard{
    name = "sp_gexingCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@duangexing")
		room:doLightbox("$duangexing")
		room:loseMaxHp(source, 1)
		room:acquireSkill(source, "sp_tianxia")
		local n = source:getMark("&sp_zhujiuFQC")
		room:removePlayerMark(source, "&sp_zhujiuFQC", n)
	end,
}
sp_gexingVS = sgs.CreateZeroCardViewAsSkill{
	name = "sp_gexing",
	view_as = function()
		return sp_gexingCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@duangexing") > 0 and player:getMark("&sp_zhujiuFQC") >= 10 and not player:hasFlag("sp_gexing_limited") and not player:getPhase() == sgs.Player_Play
	end,
	response_pattern = "@@sp_gexing",
}
sp_gexing = sgs.CreateTriggerSkill{
	name = "sp_gexing",
	frequency = sgs.Skill_Limited,
	waked_skills = "sp_tianxia",
	limit_mark = "@duangexing",
	view_as_skill = sp_gexingVS,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start and player:getMark("@duangexing") > 0 and player:getMark("&sp_zhujiuFQC") >= 10 then
			if not room:askForUseCard(player, "@@sp_gexing", "@sp_gexing-card") then
				room:setPlayerFlag(player, "sp_gexing_limited")
			end
		end
	end,
}
sp_shencaocao:addSkill(sp_gexing)
sp_shencaocao:addRelateSkill("sp_tianxia")
--“天下”
sp_tianxiaCard = sgs.CreateSkillCard{
	name = "sp_tianxiaCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local choice = room:askForChoice(source, "sp_tianxia", "1+2+3+cancel")
		if choice == "1" then
			room:loseHp(source, 1)
			room:broadcastSkillInvoke("sp_tianxia", 1)
			for _, t in sgs.qlist(room:getOtherPlayers(source)) do
		    	local choices = {}
				if not t:isNude() then
					table.insert(choices, "1")
				end
				table.insert(choices, "2")
				local choiceO = room:askForChoice(t, "sp_tianxiaOther", table.concat(choices, "+"))
				if choiceO == "1" then
			    	local card = room:askForCardChosen(t, t, "he", "sp_tianxia")
					room:obtainCard(source, card, false)
				else
			    	room:damage(sgs.DamageStruct("sp_tianxia", source, t, 1, sgs.DamageStruct_Normal))
				end
			end
		elseif choice == "2" then
			room:addPlayerMark(source, "&SkipPlayerPlay")
			room:setPlayerFlag(source, "SkipPlayerPlayDoNotClear")
			room:broadcastSkillInvoke("sp_tianxia", 2)
			for _, t in sgs.qlist(room:getOtherPlayers(source)) do
		    	local choices = {}
				if not t:isAllNude() then
					table.insert(choices, "1")
				end
				table.insert(choices, "2")
				local choiceF = room:askForChoice(source, "sp_tianxiaSelf", table.concat(choices, "+"))
				if choiceF == "1" then
			    	local card = room:askForCardChosen(source, t, "hej", "sp_tianxia")
					room:obtainCard(source, card, false)
				else
			    	room:damage(sgs.DamageStruct("sp_tianxia", source, t, 1, sgs.DamageStruct_Normal))
				end
			end
		elseif choice == "3" then
			room:loseMaxHp(source, 1)
			--执行第一项
			room:loseHp(source, 1)
			room:broadcastSkillInvoke("sp_tianxia", 1)
			for _, t in sgs.qlist(room:getOtherPlayers(source)) do
		    	local choices = {}
				if not t:isNude() then
					table.insert(choices, "1")
				end
				table.insert(choices, "2")
				local choiceO = room:askForChoice(t, "sp_tianxiaOther", table.concat(choices, "+"))
				if choiceO == "1" then
			    	local card1 = room:askForCardChosen(t, t, "he", "sp_tianxia")
					room:obtainCard(source, card1, false)
				else
			    	room:damage(sgs.DamageStruct("sp_tianxia", source, t, 1, sgs.DamageStruct_Normal))
				end
			end
			--执行第二项
			room:addPlayerMark(source, "&SkipPlayerPlay")
			room:setPlayerFlag(source, "SkipPlayerPlayDoNotClear")
			room:broadcastSkillInvoke("sp_tianxia", 2)
			for _, t in sgs.qlist(room:getOtherPlayers(source)) do
		    	local choicess = {}
				if not t:isAllNude() then
					table.insert(choicess, "1")
				end
				table.insert(choicess, "2")
				local choiceF = room:askForChoice(source, "sp_tianxiaSelf", table.concat(choicess, "+"))
				if choiceF == "1" then
			    	local card2 = room:askForCardChosen(source, t, "hej", "sp_tianxia")
					room:obtainCard(source, card2, false)
				else
			    	room:damage(sgs.DamageStruct("sp_tianxia", source, t, 1, sgs.DamageStruct_Normal))
				end
			end
			room:broadcastSkillInvoke("sp_tianxia", 3)
		end
	end,
}
sp_tianxia = sgs.CreateZeroCardViewAsSkill{
    name = "sp_tianxia",
	view_as = function()
		return sp_tianxiaCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#sp_tianxiaCard")
	end,
}
if not sgs.Sanguosha:getSkill("sp_tianxia") then skills:append(sp_tianxia) end
--跳过出牌阶段--（通用代码）
SkipPlayerPlay = sgs.CreateTriggerSkill{
	name = "SkipPlayerPlay",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if not player:isSkipped(change.to) and change.to == sgs.Player_Play then
			player:skip(change.to)
		end
		if change.to == sgs.Player_NotActive then
			for _, p in sgs.qlist(room:getAllPlayers()) do
            	if p:getMark("&SkipPlayerPlay") > 0 and not p:hasFlag("SkipPlayerPlayDoNotClear") then
		        	room:removePlayerMark(p, "&SkipPlayerPlay")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&SkipPlayerPlay") > 0
	end,
}
if not sgs.Sanguosha:getSkill("SkipPlayerPlay") then skills:append(SkipPlayerPlay) end

--

--24 战神·吕布
sp_shenlvbuu = sgs.General(extension_G, "sp_shenlvbuu", "god", 6, true)

sp_wujiChoice = sgs.CreateTriggerSkill{
	name = "sp_wujiChoice",
	global = true,
	priority = 4,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, "sp_wuji", data) then
			local choice = room:askForChoice(player, "sp_wuji", "1+2+cancel")
			if choice == "1" then
				room:loseMaxHp(player, 1)
				room:drawCards(player, 2, "sp_wuji")
				room:askForDiscard(player, "sp_wuji", 1, 1, false, true)
				room:broadcastSkillInvoke("sp_wuji", 1)
				room:acquireOneTurnSkills(player, "sp_wuji", "wushuang|sp_feijiang")
			elseif choice == "2" then
				room:loseMaxHp(player, 1)
				room:drawCards(player, 1, "sp_wuji")
				room:askForDiscard(player, "sp_wuji", 2, 2, false, true)
				room:broadcastSkillInvoke("sp_wuji", 2)
				room:acquireOneTurnSkills(player, "sp_wuji", "wushuang|sp_feijiang|sp_mengguan|sp_duyong")
				if player:getMark("sp_wuji") == 0 then
					room:addPlayerMark(player, "&sp_wujiAnger")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("sp_wuji") and player:getPhase() == sgs.Player_Play
	end,
}
sp_wuji = sgs.CreateTriggerSkill{
	name = "sp_wuji",
	frequency = sgs.Skill_Wake,
	waked_skills = "wushuang, sp_feijiang, sp_mengguan, sp_duyong, sp_hengsaoqianjun",
	events = {sgs.EventPhaseStart},
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Play or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getMark("&sp_wujiAnger") < 3 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName(), 3)
		room:doSuperLightbox("sp_shenlvbuu", "sp_wuji")
		room:acquireSkill(player, "sp_hengsaoqianjun")
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
		local n = player:getMark("&sp_wujiAnger")
		if n > 0 then room:removePlayerMark(player, "&sp_wujiAnger", n) end
	end,
	can_trigger = function(self, player)
	    return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
if not sgs.Sanguosha:getSkill("sp_wujiChoice") then skills:append(sp_wujiChoice) end
sp_shenlvbuu:addSkill(sp_wuji)
sp_shenlvbuu:addRelateSkill("wushuang")
sp_shenlvbuu:addRelateSkill("sp_feijiang")
sp_shenlvbuu:addRelateSkill("sp_mengguan")
sp_shenlvbuu:addRelateSkill("sp_duyong")
sp_shenlvbuu:addRelateSkill("sp_hengsaoqianjun")
--“无双”（即吕布的技能“无双”）
--“飞将”
sp_feijiangCard = sgs.CreateSkillCard{
    name = "sp_feijiangCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and not to_select:isKongcheng()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local success = effect.from:pindian(effect.to, "sp_feijiang", nil)
		if success then
			if effect.from:hasFlag("drank") then
				room:setPlayerFlag(effect.from, "-drank")
			end
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			slash:setSkillName("sp_feijiang")
			room:useCard(sgs.CardUseStruct(slash, effect.from, effect.to), false)
		else
			if not effect.to:isAllNude() then
				local card = room:askForCardChosen(effect.from, effect.to, "hej", "sp_feijiang")
				room:obtainCard(effect.from, card, false)
			end
			room:setPlayerFlag(effect.from, "Global_PlayPhaseTerminated")
		end
	end,
}
sp_feijiang = sgs.CreateZeroCardViewAsSkill{
    name = "sp_feijiang",
    view_as = function()
		return sp_feijiangCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#sp_feijiangCard") and not player:isKongcheng()
	end,
}
--“猛冠”
sp_mengguan = sgs.CreateViewAsSkill{
    name = "sp_mengguan",
	n = 1,
	view_filter = function(self, selected, to_select)
	    return to_select:isKindOf("Weapon")
	end,
	view_as = function(self, cards)
	    if #cards == 0 then return
		elseif #cards == 1 then
		    local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local id = card:getId()
			local mg_card = sgs.Sanguosha:cloneCard("duel", suit, point)
			mg_card:addSubcard(id)
			mg_card:setSkillName(self:objectName())
			return mg_card
		end
	end,
}
--“独勇”
sp_duyong = sgs.CreateTriggerSkill{
	name = "sp_duyong",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.from:objectName() == player:objectName() and player:hasSkill(self:objectName())
		and (damage.card:isKindOf("Slash") or damage.card:isKindOf("Duel")) and not player:isNude() then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:askForDiscard(player, self:objectName(), 1, 1, false, true)
				room:broadcastSkillInvoke(self:objectName())
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		end
	end,
}
if not sgs.Sanguosha:getSkill("sp_feijiang") then skills:append(sp_feijiang) end
if not sgs.Sanguosha:getSkill("sp_mengguan") then skills:append(sp_mengguan) end
if not sgs.Sanguosha:getSkill("sp_duyong") then skills:append(sp_duyong) end

--“横扫千军”
sp_hengsaoqianjun = sgs.CreateViewAsSkill{
    name = "sp_hengsaoqianjun",
	response_or_use = true,
	n = 2,
	view_filter = function(self, selected, to_select)
		if #selected == 0 then
			return not to_select:isEquipped()
		elseif #selected == 1 then
			local card = selected[1]
			if GetColor(to_select) ~= GetColor(card) then
				return not to_select:isEquipped()
			end
		else
			return false
		end
	end,
	view_as = function(self, cards)
	    if #cards == 2 then
			local cardA = cards[1]
			local cardB = cards[2]
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		    slash:addSubcard(cardA)
			slash:addSubcard(cardB)
			slash:setSkillName(self:objectName())
			return slash
		end
	end,
	enabled_at_play = function(self, player)
		return sgs.Slash_IsAvailable(player)
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "slash"
	end,
}
sp_hengsaoqianjunBUFFCard = sgs.CreateSkillCard{
	name = "sp_hengsaoqianjunBUFFCard",
	mute = true,
	filter = function(self, targets, to_select, player)
		return #targets < 2 and to_select:hasFlag("sp_hengsaoqianjunBUFF")
	end,
	about_to_use = function(self, room, use)
		for _, p in sgs.qlist(use.to) do
			room:setPlayerFlag(p, "sp_hengsaoqianjunBUFF_slash")
		end
	end,
}
sp_hengsaoqianjunBUFFVS = sgs.CreateZeroCardViewAsSkill{
	name = "sp_hengsaoqianjunBUFF",
	view_as = function()
		return sp_hengsaoqianjunBUFFCard:clone()
	end,
	response_pattern = "@@sp_hengsaoqianjunBUFF",
}
sp_hengsaoqianjunBUFF = sgs.CreateTriggerSkill{
	name = "sp_hengsaoqianjunBUFF",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.PreCardUsed, sgs.ConfirmDamage},
	view_as_skill = sp_hengsaoqianjunBUFFVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.PreCardUsed then
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash") or use.card:getSkillName() ~= "sp_hengsaoqianjun" or use.from:objectName() ~= player:objectName() then return false end
			local choice = room:askForChoice(player, "sp_hengsaoqianjun", "1+2+3+cancel")
			if choice == "1" then
				room:broadcastSkillInvoke("sp_hengsaoqianjun")
				room:setPlayerFlag(player, "sp_hengsaoqianjunDMGbuff")
			else
				if choice == "cancel" then return false end
				if choice == "3" then
					room:loseMaxHp(player, 1)
					room:broadcastSkillInvoke("sp_hengsaoqianjun")
					room:setPlayerFlag(player, "sp_hengsaoqianjunDMGbuff")
				end
				local extra_targets = room:getCardTargets(player, use.card, use.to)
				if extra_targets:isEmpty() then return false end
				for _, p in sgs.qlist(extra_targets) do
					room:setPlayerFlag(p, "sp_hengsaoqianjunBUFF")
				end
				room:askForUseCard(player, "@@sp_hengsaoqianjunBUFF", "@sp_hengsaoqianjunBUFF:" .. use.card:objectName() .. "::" .. 2, -1, sgs.Card_MethodNone)
				local adds = sgs.SPlayerList()
				for _, p in sgs.qlist(extra_targets) do
					room:setPlayerFlag(p, "-sp_hengsaoqianjunBUFF")
					if p:hasFlag("sp_hengsaoqianjunBUFF_slash") then
						room:setPlayerFlag(p, "-sp_hengsaoqianjunBUFF_slash")
						use.to:append(p)
						adds:append(p)
					end
				end
				if adds:isEmpty() then return false end
				room:sortByActionOrder(adds)
				room:sortByActionOrder(use.to)
				data:setValue(use)
				local log = sgs.LogMessage()
				log.type = "#QiaoshuiAdd"
				log.from = player
				log.to = adds
				log.card_str = use.card:toString()
				log.arg = "sp_hengsaoqianjun"
				room:sendLog(log)
				for _, p in sgs.qlist(adds) do
					room:doAnimate(1, player:objectName(), p:objectName())
				end
				room:notifySkillInvoked(player, self:objectName())
				room:broadcastSkillInvoke("sp_hengsaoqianjun")
			end
		else
			local damage = data:toDamage()
			if damage.from:objectName() == player:objectName() and player:hasFlag("sp_hengsaoqianjunDMGbuff")
			and damage.card and damage.card:isKindOf("Slash") and damage.card:getSkillName() == "sp_hengsaoqianjun" then
				local log = sgs.LogMessage()
				log.type = "$sp_hengsaoqianjunDMG"
				log.from = player
				log.to:append(damage.to)
				log.card_str = damage.card:toString()
				log.arg = "sp_hengsaoqianjun"
				room:sendLog(log)
				damage.damage = damage.damage + 1
				data:setValue(damage)
				room:broadcastSkillInvoke("sp_hengsaoqianjun")
				room:setPlayerFlag(player, "-sp_hengsaoqianjunDMGbuff")
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("sp_hengsaoqianjun")
	end,
}
if not sgs.Sanguosha:getSkill("sp_hengsaoqianjun") then skills:append(sp_hengsaoqianjun) end
if not sgs.Sanguosha:getSkill("sp_hengsaoqianjunBUFF") then skills:append(sp_hengsaoqianjunBUFF) end

sp_xixu = sgs.CreateTriggerSkill{
	name = "sp_xixu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage, sgs.Damage}, --根据技能描述，需要分开为两个时机
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.from:objectName() == player:objectName() then
				if player:getMaxHp() < damage.to:getMaxHp() then
					room:setPlayerFlag(player, "sp_xixu")
				end
			end
		elseif event == sgs.Damage then
			local damage = data:toDamage()
			if damage.from:objectName() == player:objectName() then
				if player:hasFlag("sp_xixu") then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					local count = player:getMaxHp()
					local mhp = sgs.QVariant()
					mhp:setValue(count + 1)
					room:setPlayerProperty(player, "maxhp", mhp)
					room:setPlayerFlag(player, "-sp_xixu")
				end
			end
		end
	end,
}
sp_shenlvbuu:addSkill(sp_xixu)

--25 枪神·赵云
sp_shenzhaoyun = sgs.General(extension_G, "sp_shenzhaoyun", "god", 8, true)

sp_qijinCard = sgs.CreateSkillCard{
	name = "sp_qijinCard",
    will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		local players = sgs.PlayerList()
		for i = 1 , #targets do
			players:append(targets[i])
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card = nil
			if self:getUserString() and self:getUserString() ~= "" then
				card = sgs.Sanguosha:cloneCard(self:getUserString():split("+")[1])
				return card and card:targetFilter(players, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, players)
			end
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return false
		end
		local _card = sgs.Self:getTag("sp_qijin"):toCard()
		if _card == nil then
			return false
		end
		local card = sgs.Sanguosha:cloneCard(_card)
		card:setCanRecast(false)
		card:deleteLater()
		return card and card:targetFilter(players, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, players)
	end,
	feasible = function(self, targets)
		local players = sgs.PlayerList()
		for i = 1 , #targets do
			players:append(targets[i])
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card = nil
			if self:getUserString() and self:getUserString() ~= "" then
				card = sgs.Sanguosha:cloneCard(self:getUserString():split("+")[1])
				return card and card:targetsFeasible(players, sgs.Self)
			end
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return true
		end
		local _card = sgs.Self:getTag("sp_qijin"):toCard()
		if _card == nil then
			return false
		end
		local card = sgs.Sanguosha:cloneCard(_card)
		card:setCanRecast(false)
		card:deleteLater()
		return card and card:targetsFeasible(players, sgs.Self)
	end,
	on_validate = function(self, card_use)
		local spszy = card_use.from
		local room = spszy:getRoom()
		room:loseMaxHp(spszy, 1)
		room:removePlayerMark(spszy, "&canuse_qijin")
		--[[local to_sp_qijin = self:getUserString()
		if to_sp_qijin == "slash" and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local sp_qijin_list = {}
			table.insert(sp_qijin_list, "slash")
			local sts = sgs.GetConfig("BanPackages", "")
			if not string.find(sts, "maneuvering") then
				table.insert(sp_qijin_list, "normal_slash")
				table.insert(sp_qijin_list, "fire_slash")
				table.insert(sp_qijin_list, "thunder_slash")
				table.insert(sp_qijin_list, "ice_slash")
			end
			to_sp_qijin = room:askForChoice(spszy, "sp_qijin_slash", table.concat(sp_qijin_list, "+"))
			spszy:setTag("sp_qijinSlash", sgs.QVariant(to_sp_qijin))
		end
		local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		local user_str = ""
		if to_sp_qijin == "slash" then
			if card:isKindOf("Slash") then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		elseif to_sp_qijin == "normal_slash" then
			user_str = "slash"
		else
			user_str = to_sp_qijin
		end
		local use_card = sgs.Sanguosha:cloneCard(user_str)
		use_card:setSkillName("sp_qijin")
		use_card:deleteLater()
		local tos = card_use.to
		for _, to in sgs.qlist(tos) do
			local skill = room:isProhibited(spszy, to, use_card)
			if skill then
				card_use.to:removeOne(to)
			end
		end
		return use_card
	end,]]
		local user_string = self:getUserString()
		if (string.find(user_string, "slash") or string.find(user_string, "Slash")) and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
        	local slashs = sgs.Sanguosha:getSlashNames()
        	user_string = room:askForChoice(spszy, "sp_qijin_slash", table.concat(slashs, "+"))
    	end
    	local use_card = sgs.Sanguosha:cloneCard(user_string)
		if not use_card then return nil end
    	use_card:setSkillName("_sp_qijin")
    	use_card:deleteLater()
    	return use_card
	end,
	on_validate_in_response = function(self, spszy)
		local room = spszy:getRoom()
		room:loseMaxHp(spszy, 1)
		room:removePlayerMark(spszy, "&canuse_qijin")
		local to_sp_qijin = ""
		if self:getUserString() == "peach+analeptic" then
			local sp_qijin_list = {}
			table.insert(sp_qijin_list, "peach")
			local sts = sgs.GetConfig("BanPackages", "")
			if not string.find(sts, "maneuvering") then
				table.insert(sp_qijin_list, "analeptic")
			end
			to_sp_qijin = room:askForChoice(spszy, "sp_qijin_saveself", table.concat(sp_qijin_list, "+"))
			spszy:setTag("sp_qijinSaveSelf", sgs.QVariant(to_sp_qijin))
		elseif self:getUserString() == "slash" then
			local sp_qijin_list = {}
			table.insert(sp_qijin_list, "slash")
			local sts = sgs.GetConfig("BanPackages", "")
			if not string.find(sts, "maneuvering") then
				table.insert(sp_qijin_list, "normal_slash")
				table.insert(sp_qijin_list, "fire_slash")
				table.insert(sp_qijin_list, "thunder_slash")
				table.insert(sp_qijin_list, "ice_slash")
			end
			to_sp_qijin = room:askForChoice(spszy, "sp_qijin_slash", table.concat(sp_qijin_list, "+"))
			spszy:setTag("sp_qijinSlash", sgs.QVariant(to_sp_qijin))
		else
			to_sp_qijin = self:getUserString()
		end
		local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		local user_str = ""
		if to_sp_qijin == "slash" then
			if card:isKindOf("Slash") then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		elseif to_sp_qijin == "normal_slash" then
			user_str = "slash"
		else
			user_str = to_sp_qijin
		end
		local use_card = sgs.Sanguosha:cloneCard(user_str)
		use_card:setSkillName("_sp_qijin")
		use_card:deleteLater()
		return use_card
	end,
}
sp_qijin = sgs.CreateZeroCardViewAsSkill{
	name = "sp_qijin",
	response_or_use = true,
	view_as = function(self, cards)
		--[[if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card = sp_qijinCard:clone()
			card:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
			return card
		end
		local c = sgs.Self:getTag("sp_qijin"):toCard()
        if c then
            local card = sp_qijinCard:clone()
            if not string.find(c:objectName(), "slash") then
                card:setUserString(c:objectName())
            else
				card:setUserString(sgs.Self:getTag("sp_qijinSlash"):toString())
			end
			return card
        else
			return nil
		end
	end,]]
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or
			sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
        	local c = sp_qijinCard:clone()
			c:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
			return c
		end
	
		local card = sgs.Self:getTag("sp_qijin"):toCard()
		if card and card:isAvailable(sgs.Self) then
			local c = sp_qijinCard:clone()
			c:setUserString(card:objectName())
			return c
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		local current = false
		local players = player:getAliveSiblings()
		players:append(player)
		for _, p in sgs.qlist(players) do
			if p:getPhase() ~= sgs.Player_NotActive then
				current = true
				break
			end
		end
		if not current then return false end
		return player:getMark("&canuse_qijin") > 0
	end,
	enabled_at_response = function(self, player, pattern)
		local current = false
		local players = player:getAliveSiblings()
		players:append(player)
		for _, p in sgs.qlist(players) do
			if p:getPhase() ~= sgs.Player_NotActive then
				current = true
				break
			end
		end
		if not current then return false end
		if player:getMark("&canuse_qijin") == 0 or string.sub(pattern, 1, 1) == "." or string.sub(pattern, 1, 1) == "@" then
            return false
		end
        if pattern == "peach" and player:getMark("Global_PreventPeach") > 0 then return false end
        if string.find(pattern, "[%u%d]") then return false end
		return true
	end,
	enabled_at_nullification = function(self, player)
		local current = player:getRoom():getCurrent()
		if not current or current:isDead() or current:getPhase() == sgs.Player_NotActive then return false end
		return player:getMark("&canuse_qijin") > 0
	end,
}
sp_qijinKey = sgs.CreateTriggerSkill{
    name = "sp_qijinKey",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.EventPhaseStart, sgs.MaxHpChanged, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart and player:hasSkill("sp_qichu") then
			local n = player:getMaxHp()
			room:addPlayerMark(player, "sp_qichuMHP_Start", n) --记录游戏开始时SP神赵云的体力上限值
			room:addPlayerMark(player, "sp_qichuMHP", n) --SP神赵云体力上限实时动态记录
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				for _, p in sgs.qlist(room:findPlayersBySkillName("sp_qijin")) do
					if p:getMark("&canuse_qijin") == 0 then
						room:addPlayerMark(p, "&canuse_qijin")
					end
				end
				if player:hasSkill("sp_qijin") and player:getMaxHp() > 1 then
					room:sendCompulsoryTriggerLog(player, "sp_qijin")
					room:broadcastSkillInvoke("sp_qijin")
					room:loseMaxHp(player, 1)
					room:drawCards(player, 1, "sp_qijin")
				end
			end
		elseif event == sgs.MaxHpChanged then
			local m = player:getMaxHp()
			local n = player:getMark("sp_qichuMHP")
			if n > 0 then --粗略判断是否为SP神赵云
				if m < n then
					if player:hasSkill("sp_qijin") then
						room:addPlayerMark(player, "sp_qichuMHP_reduse") --记录SP神赵云体力上限减少的次数
					end
					room:removePlayerMark(player, "sp_qichuMHP", n-m)
				elseif m > n then
					room:addPlayerMark(player, "sp_qichuMHP", m-n)
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:getMark("&canuse_qijin") > 0 then
						local m = p:getMark("&canuse_qijin")
						room:removePlayerMark(p, "&canuse_qijin", m)
					end
				end
				if player:hasSkill("sp_qijin") and player:getMaxHp() > 1 then
					room:sendCompulsoryTriggerLog(player, "sp_qijin")
					room:broadcastSkillInvoke("sp_qijin")
					room:loseMaxHp(player, 1)
					local n = player:getMark("sp_qichuMHP_reduse")
					if n > 4 then n = 4 end
					room:drawCards(player, n, "sp_qijin")
				end
            end
        end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
sp_qijin:setGuhuoDialog("lr")
sp_shenzhaoyun:addSkill(sp_qijin)
if not sgs.Sanguosha:getSkill("sp_qijinKey") then skills:append(sp_qijinKey) end

sp_qichu = sgs.CreateTriggerSkill{
	name = "sp_qichu",
	frequency = sgs.Skill_Wake,
	waked_skills = "sp_danqi, sp_gudan, sp_lingyun",
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd},
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start and player:getPhase() ~= sgs.Player_Finish then return false end
		if player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getMaxHp() ~= 1 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Start) or (event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Finish) then
			room:broadcastSkillInvoke(self:objectName())
			room:doLightbox("sp_qichuAnimate")
			if player:hasSkill("sp_qijin") then
				room:detachSkillFromPlayer(player, "sp_qijin")
				room:removePlayerMark(player, "&canuse_qijin")
			end
			local n = player:getMark("sp_qichuMHP_Start")
			room:setPlayerProperty(player, "maxhp", sgs.QVariant(n))
			room:recover(player, sgs.RecoverStruct(player, nil, 1))
			room:acquireSkill(player, "sp_danqi")
			room:addPlayerMark(player, "&canuse_danqi")
			room:acquireSkill(player, "sp_gudan")
			room:acquireSkill(player, "sp_lingyun")
			room:addPlayerMark(player, self:objectName())
			room:addPlayerMark(player, "@waked")
		end
	end,
	can_trigger = function(self, player)
	    return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
sp_shenzhaoyun:addSkill(sp_qichu)
sp_shenzhaoyun:addRelateSkill("sp_danqi")
sp_shenzhaoyun:addRelateSkill("sp_gudan")
sp_shenzhaoyun:addRelateSkill("sp_lingyun")
--“单骑”
sp_danqi = sgs.CreateViewAsSkill{
	name = "sp_danqi",
	n = 2,
	response_or_use = true,
	view_filter = function(self, selected, to_select)
		if (#selected > 0) and sgs.Self:getMaxHp() <= 1 and sgs.Self:getMark("@sp_lingyunAI") > 0 then return false end
		if (#selected > 0) and sgs.Self:getMaxHp() <= 2 and sgs.Self:getMark("@sp_lingyunAI") > 0 and sgs.Self:getMark("&canuse_danqi") == 0 then return false end
		if (#selected > 1) or to_select:hasFlag("using") then return false end
		if #selected > 0 then
			if selected[1]:isKindOf("Slash") then
				return to_select:isKindOf("Slash")
			elseif selected[1]:isKindOf("Jink") then
				return to_select:isKindOf("Jink")
			elseif selected[1]:isKindOf("Peach") then
				return to_select:isKindOf("Peach")
			elseif selected[1]:isKindOf("Analeptic") then
				return to_select:isKindOf("Analeptic")
			end
		end
		local usereason = sgs.Sanguosha:getCurrentCardUseReason()
		if usereason == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			return to_select:isKindOf("Jink") or to_select:isKindOf("Peach") or to_select:isKindOf("Analeptic")
		elseif usereason == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or usereason == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if pattern == "slash" then
				return to_select:isKindOf("Analeptic")
			elseif pattern == "jink" then
				return to_select:isKindOf("Slash")
			elseif string.find(pattern, "peach") then
				return to_select:isKindOf("Jink") or to_select:isKindOf("Peach")
			end
		else
			return false
		end
	end,
	view_as = function(self, cards)
		if #cards ~= 1 and #cards ~= 2 then return nil end
		local card = cards[1]
		local new_card = nil
		if card:isKindOf("Slash") then
			new_card = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, 0)
		elseif card:isKindOf("Jink") then
			new_card = sgs.Sanguosha:cloneCard("peach", sgs.Card_SuitToBeDecided, 0)
		elseif card:isKindOf("Peach") then
			new_card = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_SuitToBeDecided, 0)
		elseif card:isKindOf("Analeptic") then
			new_card = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, 0)
		end
		if new_card then
			if #cards == 1 then
				new_card:setSkillName(self:objectName())
			else
				new_card:setSkillName("sp_danqi_buffs")
			end
			for _, c in ipairs(cards) do
				new_card:addSubcard(c)
			end
		end
		return new_card
	end,
	enabled_at_play = function(self, target)
		local newana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_SuitToBeDecided, 0)
		return not target:hasFlag("sp_danqiCardUsedTwice") and not (target:getMark("&canuse_danqi") == 0 and not target:hasSkill("sp_lingyun")) and not (target:getMark("&canuse_danqi") == 0 and target:getMark("@sp_lingyunAI") > 0 and target:getMaxHp() <= 1)
		and (target:isWounded() or sgs.Slash_IsAvailable(target) or target:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, target, newana))
	end,
	enabled_at_response = function(self, target, pattern)
		return pattern == "slash" or pattern == "jink" or (string.find(pattern, "peach") and not target:hasFlag("Global_PreventPeach")) or string.find(pattern, "analeptic")
	end,
}
sp_danqi_buffs = sgs.CreateTriggerSkill{
    name = "sp_danqi_buffs",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart, sgs.EventPhaseChanging, sgs.CardUsed, sgs.CardResponded, sgs.ConfirmDamage, sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				for _, p in sgs.qlist(room:findPlayersBySkillName("sp_danqi")) do
					if p:getMark("&canuse_danqi") == 0 then
						room:addPlayerMark(p, "&canuse_danqi")
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:getMark("&canuse_danqi") > 0 then
						local n = p:getMark("&canuse_danqi")
						room:removePlayerMark(p, "&canuse_danqi", n)
					end
					if p:hasFlag("sp_danqiCardUsedTwice") then
						room:setPlayerFlag(p, "-sp_danqiCardUsedTwice")
					end
					local s = p:getMark("sp_danqi_SlashBuff")
					local a = p:getMark("sp_danqi_AnalepticBuff")
					if s > 0 then room:removePlayerMark(p, "sp_danqi_SlashBuff", s) end
					if a > 0 then room:removePlayerMark(p, "sp_danqi_AnalepticBuff", a) end
				end
            end
		elseif event == sgs.CardUsed or event == sgs.CardResponded then
			local card
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else
				card = data:toCardResponse().m_card
			end
			if card then
				if (card:getSkillName() == "sp_danqi" or card:getSkillName() == "sp_danqi_buffs") and player:getMark("&canuse_danqi") == 0 then
					room:loseMaxHp(player, 1) --发动“凌云”额外使用一次，但减体力上限
					room:setPlayerFlag(player, "sp_danqiCardUsedTwice")
				end
				if player:hasSkill("sp_lingyun") and card:getSkillName() == "sp_danqi_buffs" then
					room:sendCompulsoryTriggerLog(player, "sp_lingyun")
					room:broadcastSkillInvoke("sp_lingyun")
					room:loseMaxHp(player, 1)
				end
				--【闪】--
				if card:isKindOf("Jink") and (card:getSkillName() == "sp_danqi" or card:getSkillName() == "sp_danqi_buffs") and data:toCardResponse().m_who then
					room:removePlayerMark(player, "&canuse_danqi")
					local choicesJ = {}
					if card:getSkillName() ~= "sp_danqi_buffs" then
						table.insert(choicesJ, "jink1")
					end
					if not (card:getSkillName() == "sp_danqi" and not player:hasSkill("sp_lingyun")) and not (card:getSkillName() == "sp_danqi" and player:getMark("@sp_lingyunAI") > 0 and player:getMaxHp() <= 1) then
						table.insert(choicesJ, "jink2")
					end
					if player:hasSkill("sp_lingyun") and card:getSkillName() == "sp_danqi_buffs" and not (player:getMark("@sp_lingyunAI") > 0 and player:getMaxHp() <= 1) then
						table.insert(choicesJ, "jink3")
					end
					table.insert(choicesJ, "cancel")
					local choiceJ = room:askForChoice(player, "sp_danqi", table.concat(choicesJ, "+"))
					if choiceJ == "jink1" then
						room:broadcastSkillInvoke("sp_danqi")
						if data:toCardResponse().m_who:isAlive() and not data:toCardResponse().m_who:isNude() then
							local id = room:askForCardChosen(player, data:toCardResponse().m_who, "he", self:objectName())
					        room:throwCard(id, data:toCardResponse().m_who, player)
						end
					elseif choiceJ == "jink2" then
						room:broadcastSkillInvoke("sp_danqi")
						if card:getSkillName() == "sp_danqi" then
							room:sendCompulsoryTriggerLog(player, "sp_lingyun")
							room:broadcastSkillInvoke("sp_lingyun")
							room:loseMaxHp(player, 1)
						end
						if data:toCardResponse().m_who:isAlive() and not data:toCardResponse().m_who:isNude() then
							local id1 = room:askForCardChosen(player, data:toCardResponse().m_who, "he", self:objectName())
					        room:throwCard(id1, data:toCardResponse().m_who, player)
						end
						if data:toCardResponse().m_who:isAlive() and not data:toCardResponse().m_who:isNude() then
							local id2 = room:askForCardChosen(player, data:toCardResponse().m_who, "he", self:objectName())
					        room:throwCard(id2, data:toCardResponse().m_who, player)
						end
					elseif choiceJ == "jink3" then
						room:broadcastSkillInvoke("sp_danqi")
						room:sendCompulsoryTriggerLog(player, "sp_lingyun")
						room:broadcastSkillInvoke("sp_lingyun")
						room:loseMaxHp(player, 1)
						if data:toCardResponse().m_who:isAlive() and not data:toCardResponse().m_who:isNude() then
							local id1 = room:askForCardChosen(player, data:toCardResponse().m_who, "he", self:objectName())
					        room:throwCard(id1, data:toCardResponse().m_who, player)
						end
						if data:toCardResponse().m_who:isAlive() and not data:toCardResponse().m_who:isNude() then
							local id2 = room:askForCardChosen(player, data:toCardResponse().m_who, "he", self:objectName())
					        room:throwCard(id2, data:toCardResponse().m_who, player)
						end
						if data:toCardResponse().m_who:isAlive() and not data:toCardResponse().m_who:isNude() then
							local id3 = room:askForCardChosen(player, data:toCardResponse().m_who, "he", self:objectName())
					        room:throwCard(id3, data:toCardResponse().m_who, player)
						end
					end
				--【桃】--
				elseif card:isKindOf("Peach") and (card:getSkillName() == "sp_danqi" or card:getSkillName() == "sp_danqi_buffs") and data:toCardUse().to then
					room:removePlayerMark(player, "&canuse_danqi")
					local choicesP = {}
					if card:getSkillName() ~= "sp_danqi_buffs" then
						table.insert(choicesP, "peach1")
					end
					if not (card:getSkillName() == "sp_danqi" and not player:hasSkill("sp_lingyun")) and not (card:getSkillName() == "sp_danqi" and player:getMark("@sp_lingyunAI") > 0 and player:getMaxHp() <= 1) then
						table.insert(choicesP, "peach2")
					end
					if player:hasSkill("sp_lingyun") and card:getSkillName() == "sp_danqi_buffs" and not (player:getMark("@sp_lingyunAI") > 0 and player:getMaxHp() <= 1) then
						table.insert(choicesP, "peach3")
					end
					table.insert(choicesP, "cancel")
					local choiceP = room:askForChoice(player, "sp_danqi", table.concat(choicesP, "+"))
					if choiceP == "peach1" then
						room:broadcastSkillInvoke("sp_danqi")
						for _, p in sgs.qlist(data:toCardUse().to) do
							room:drawCards(p, 1, self:objectName())
						end
					elseif choiceP == "peach2" then
						room:broadcastSkillInvoke("sp_danqi")
						if card:getSkillName() == "sp_danqi" then
							room:sendCompulsoryTriggerLog(player, "sp_lingyun")
							room:broadcastSkillInvoke("sp_lingyun")
							room:loseMaxHp(player, 1)
						end
						for _, p in sgs.qlist(data:toCardUse().to) do
							room:drawCards(p, 2, self:objectName())
						end
					elseif choiceP == "peach3" then
						room:broadcastSkillInvoke("sp_danqi")
						room:sendCompulsoryTriggerLog(player, "sp_lingyun")
						room:broadcastSkillInvoke("sp_lingyun")
						room:loseMaxHp(player, 1)
						for _, p in sgs.qlist(data:toCardUse().to) do
							room:drawCards(p, 3, self:objectName())
						end
					end
				--【酒】--
				elseif card:isKindOf("Analeptic") and (card:getSkillName() == "sp_danqi" or card:getSkillName() == "sp_danqi_buffs") then
					room:removePlayerMark(player, "&canuse_danqi")
					local choicesA = {}
					if not (card:getSkillName() == "sp_danqi" and not player:hasSkill("sp_lingyun")) and not (card:getSkillName() == "sp_danqi" and player:getMark("@sp_lingyunAI") > 0 and player:getMaxHp() <= 1) then
						table.insert(choicesA, "analeptic1")
					end
					if player:hasSkill("sp_lingyun") and card:getSkillName() == "sp_danqi_buffs" and not (player:getMark("@sp_lingyunAI") > 0 and player:getMaxHp() <= 1) then
						table.insert(choicesA, "analeptic2")
					end
					table.insert(choicesA, "cancel")
					local choiceA = room:askForChoice(player, "sp_danqi", table.concat(choicesA, "+"))
					if choiceA == "analeptic1" then
						room:broadcastSkillInvoke("sp_danqi")
						if card:getSkillName() == "sp_danqi" then
							room:sendCompulsoryTriggerLog(player, "sp_lingyun")
							room:broadcastSkillInvoke("sp_lingyun")
							room:loseMaxHp(player, 1)
						end
						room:addPlayerMark(player, "sp_danqi_AnalepticBuff", 1)
						local log = sgs.LogMessage()
						log.type = "$sp_danqi_AnalepticADD"
						log.from = player
						log.card_str = card:toString()
						log.arg2 = 1
						room:sendLog(log)
					elseif choiceA == "analeptic2" then
						room:broadcastSkillInvoke("sp_danqi")
						room:sendCompulsoryTriggerLog(player, "sp_lingyun")
						room:broadcastSkillInvoke("sp_lingyun")
						room:loseMaxHp(player, 1)
						room:addPlayerMark(player, "sp_danqi_AnalepticBuff", 2)
						local log = sgs.LogMessage()
						log.type = "$sp_danqi_AnalepticADD"
						log.from = player
						log.card_str = card:toString()
						log.arg2 = 2
						room:sendLog(log)
					end
				--【杀】--
				elseif card:isKindOf("Slash") and (card:getSkillName() == "sp_danqi" or card:getSkillName() == "sp_danqi_buffs") then
					player:setFlags("sp_danqiSlashfrom")
					for _, p in sgs.qlist(data:toCardUse().to) do
						p:setFlags("sp_danqiSlashto")
						room:addPlayerMark(p, "Armor_Nullified")
					end
					room:removePlayerMark(player, "&canuse_danqi")
					local choicesS = {}
					if not (card:getSkillName() == "sp_danqi" and not player:hasSkill("sp_lingyun")) and not (card:getSkillName() == "sp_danqi" and player:getMark("@sp_lingyunAI") > 0 and player:getMaxHp() <= 1) then
						table.insert(choicesS, "slash1")
					end
					if player:hasSkill("sp_lingyun") and card:getSkillName() == "sp_danqi_buffs" and not (player:getMark("@sp_lingyunAI") > 0 and player:getMaxHp() <= 1) then
						table.insert(choicesS, "slash2")
					end
					table.insert(choicesS, "cancel")
					local choiceS = room:askForChoice(player, "sp_danqi", table.concat(choicesS, "+"))
					if choiceS ~= "cancel" then room:setCardFlag(card, self:objectName()) end
					if choiceS == "slash1" then
						room:broadcastSkillInvoke("sp_danqi")
						if card:getSkillName() == "sp_danqi" then
							room:sendCompulsoryTriggerLog(player, "sp_lingyun")
							room:broadcastSkillInvoke("sp_lingyun")
							room:loseMaxHp(player, 1)
						end
						room:addPlayerMark(player, "sp_danqi_SlashBuff", 1)
						local log = sgs.LogMessage()
						log.type = "$sp_danqi_SlashADD"
						log.from = player
						log.card_str = card:toString()
						log.arg2 = 1
						room:sendLog(log)
					elseif choiceS == "slash2" then
						room:broadcastSkillInvoke("sp_danqi")
						room:sendCompulsoryTriggerLog(player, "sp_lingyun")
						room:broadcastSkillInvoke("sp_lingyun")
						room:loseMaxHp(player, 1)
						room:addPlayerMark(player, "sp_danqi_SlashBuff", 2)
						local log = sgs.LogMessage()
						log.type = "$sp_danqi_SlashADD"
						log.from = player
						log.card_str = card:toString()
						log.arg2 = 2
						room:sendLog(log)
					end
				end
			end
		elseif event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.card:isKindOf("Slash") then
				local s = player:getMark("sp_danqi_SlashBuff")
				local a = player:getMark("sp_danqi_AnalepticBuff")
				if s > 0 then
					local log = sgs.LogMessage()
					log.type = "$sp_danqi_SlashDMG"
					log.from = player
					log.to:append(damage.to)
					log.card_str = damage.card:toString()
					log.arg2 = s
					room:sendLog(log)
				end
				if damage.card:hasFlag("drank") then
					damage.damage = damage.damage + a
				end
				if damage.card:hasFlag(self:objectName()) then
					damage.damage = damage.damage + s
				end
				data:setValue(damage)
				room:removePlayerMark(player, "sp_danqi_SlashBuff", s)
				room:removePlayerMark(player, "sp_danqi_AnalepticBuff", a)
			end
        elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if player:hasFlag("sp_danqiSlashfrom") and (use.card:getSkillName() == "sp_danqi" or use.card:getSkillName() == "sp_danqi_buffs") then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:hasFlag("sp_danqiSlashto") then
						p:setFlags("-sp_danqiSlashto")
						if p:getMark("Armor_Nullified") then
							room:removePlayerMark(p, "Armor_Nullified")
						end
					end
				end
				player:setFlags("-sp_danqiSlashfrom")
			end
			if use.card:isKindOf("Slash") then
				local s = player:getMark("sp_danqi_SlashBuff")
				local a = player:getMark("sp_danqi_AnalepticBuff")
				if s > 0 then room:removePlayerMark(player, "sp_danqi_SlashBuff", s) end
				if a > 0 then room:removePlayerMark(player, "sp_danqi_AnalepticBuff", a) end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("sp_danqi") then skills:append(sp_danqi) end
if not sgs.Sanguosha:getSkill("sp_danqi_buffs") then skills:append(sp_danqi_buffs) end
--“孤胆”
sp_gudanCard = sgs.CreateSkillCard{
    name = "sp_gudanCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
	    return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
		targets[1]:obtainCard(self, false)
	end,
}
sp_gudanVS = sgs.CreateViewAsSkill{
    name = "sp_gudan",
	n = 1,
	view_filter = function(self, selected, to_select)
	    return true
	end,
	view_as = function(self, cards)
	    if #cards == 1 then
			local gd_card = sp_gudanCard:clone()
			gd_card:addSubcard(cards[1])
			return gd_card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isNude()
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@sp_gudan")
	end,
}
sp_gudan = sgs.CreateTriggerSkill{
    name = "sp_gudan",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.HpChanged},
	view_as_skill = sp_gudanVS,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local choices = {}
		table.insert(choices, "1and0")
		if player:hasSkill("sp_lingyun") and not (player:getMark("@sp_lingyunAI") > 0 and player:getMaxHp() <= 1) then
			table.insert(choices, "1and1")
			table.insert(choices, "2and0")
		end
		if player:hasSkill("sp_lingyun") and not (player:getMark("@sp_lingyunAI") > 0 and player:getMaxHp() <= 2) then
			table.insert(choices, "2and1")
		end
		local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
		if choice == "1and0" then
			room:broadcastSkillInvoke(self:objectName())
			room:drawCards(player, 1, self:objectName())
		elseif choice == "1and1" then
			room:broadcastSkillInvoke(self:objectName())
			room:sendCompulsoryTriggerLog(player, "sp_lingyun")
			room:broadcastSkillInvoke("sp_lingyun")
			room:loseMaxHp(player, 1)
			room:drawCards(player, 1, self:objectName())
			room:askForUseCard(player, "@@sp_gudan!", "@sp_gudan-card")
			if player:getState() == "robot" and not room:askForUseCard(player, "@@sp_gudan!", "@sp_gudan-card") then
			    local beneficiary = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName())
			    local id = room:askForCardChosen(player, player, "he", self:objectName())
			    room:obtainCard(beneficiary, id, false)
			end
		elseif choice == "2and0" then
			room:broadcastSkillInvoke(self:objectName())
			room:sendCompulsoryTriggerLog(player, "sp_lingyun")
			room:broadcastSkillInvoke("sp_lingyun")
			room:loseMaxHp(player, 1)
			room:drawCards(player, 2, self:objectName())
		elseif choice == "2and1" then
			room:broadcastSkillInvoke(self:objectName())
			room:sendCompulsoryTriggerLog(player, "sp_lingyun")
			room:broadcastSkillInvoke("sp_lingyun")
			room:loseMaxHp(player, 2)
			room:drawCards(player, 2, self:objectName())
			room:askForUseCard(player, "@@sp_gudan!", "@sp_gudan-card")
			if player:getState() == "robot" and not room:askForUseCard(player, "@@sp_gudan!", "@sp_gudan-card") then
			    local beneficiary = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName())
			    local id = room:askForCardChosen(player, player, "he", self:objectName())
			    room:obtainCard(beneficiary, id, false)
			end
		end
	end,
}
if not sgs.Sanguosha:getSkill("sp_gudan") then skills:append(sp_gudan) end
--“凌云”（主体部分已写在“单骑”与“孤胆”中，该部分为智能操作的切换）
sp_lingyunCard = sgs.CreateSkillCard{
	name = "sp_lingyunCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		if source:getMark("@sp_lingyunAI") > 0 then
			room:removePlayerMark(source, "@sp_lingyunAI")
		else
			room:addPlayerMark(source, "@sp_lingyunAI")
		end
	end,
}
sp_lingyun = sgs.CreateZeroCardViewAsSkill{
	name = "sp_lingyun",
	view_as = function()
		return sp_lingyunCard:clone()
	end,
	enabled_at_play = function(self, player)
		return true
	end,
}
if not sgs.Sanguosha:getSkill("sp_lingyun") then skills:append(sp_lingyun) end


--

--26 暗神·司马
sp_shensima = sgs.General(extension_G, "sp_shensima", "god", 1, true)

sp_zhuangbing = sgs.CreateTriggerSkill{
    name = "sp_zhuangbing",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Appear},
	hide_skill = true, --隐匿技
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local current = room:getCurrent()
		if current:objectName() == player:objectName() then return false end
		if room:askForSkillInvoke(player, self:objectName(), data) then
		    room:broadcastSkillInvoke(self:objectName())
			room:setPlayerFlag(current, "sp_zhuangbingTarget")
			room:setPlayerCardLimitation(current, "use,response", ".|.|.|hand", false)
		end
	end,
}
sp_zhuangbingg = sgs.CreateTriggerSkill{
    name = "sp_zhuangbingg",
	global = true,
	priority = 4,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Appear, sgs.EventPhaseChanging, sgs.TurnedOver, sgs.EventLoseSkill, sgs.EventAcquireSkill, sgs.DamageInflicted, sgs.PreHpLost},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.Appear and player:hasSkill("sp_zhuangbing") then
			room:sendCompulsoryTriggerLog(player, "sp_zhuangbing")
			room:broadcastSkillInvoke("sp_zhuangbing")
			player:turnOver()
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:hasFlag("sp_zhuangbingTarget") then
						room:removePlayerCardLimitation(p, "use,response", ".|.|.|hand")
						room:setPlayerFlag(p, "sp_zhuangbingTarget")
					end
				end
            end
		elseif event == sgs.TurnedOver and player:hasSkill("sp_zhuangbing") then
			if not player:faceUp() then
				room:setPlayerCardLimitation(player, "use,response", ".|.|.|hand", false)
			else
				room:removePlayerCardLimitation(player, "use,response", ".|.|.|hand")
			end
		elseif event == sgs.EventLoseSkill then --若期间失去“装病”，武将牌为背面时的效果不再生效
			if data:toString() == "sp_zhuangbing" then
				if not player:faceUp() then
					room:removePlayerCardLimitation(player, "use,response", ".|.|.|hand")
					room:addPlayerMark(player, "sp_zhuangbingLose") --“防伪”标记
				end
			end
		elseif event == sgs.EventAcquireSkill then --若期间重新获得“装病”，武将牌为背面时的效果再度生效
			if data:toString() == "sp_zhuangbing" and player:getMark("sp_zhuangbingLose") > 0 then
				if not player:faceUp() then
					room:setPlayerCardLimitation(player, "use,response", ".|.|.|hand", false)
					room:removePlayerMark(player, "sp_zhuangbingLose")
				end
			end
		elseif event == sgs.DamageInflicted then
			local damage = data:toDamage()
			if player:hasSkill("sp_zhuangbing") and not player:faceUp() then
				room:sendCompulsoryTriggerLog(player, "sp_zhuangbing")
				room:broadcastSkillInvoke("sp_zhuangbing")
				return true
			end
		--[[elseif event == sgs.PreHpLost then local int = data:toInt()
			if player:hasSkill("sp_zhuangbing") and not player:faceUp() then
				room:sendCompulsoryTriggerLog(player, "sp_zhuangbing")
				room:broadcastSkillInvoke("sp_zhuangbing")
				return true
			end]]
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
sp_shensima:addSkill(sp_zhuangbing)
if not sgs.Sanguosha:getSkill("sp_zhuangbingg") then skills:append(sp_zhuangbingg) end

sp_xiongxin = sgs.CreateTriggerSkill{
	name = "sp_xiongxin",
	priority = 5,
	frequency = sgs.Skill_Wake,
	waked_skills = "sp_yinren, sp_shenmou, sp_yinyang",
	events = {sgs.TurnedOver},
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		if player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:faceUp() or player:canWake(self:objectName()) then
			room:broadcastSkillInvoke(self:objectName())
			room:doSuperLightbox("sp_shensima", self:objectName())
			local count = player:getMaxHp()
			room:setPlayerProperty(player, "maxhp", sgs.QVariant(count+3))
			room:recover(player, sgs.RecoverStruct(player, nil, 3))
			room:drawCards(player, 3, self:objectName())
			room:acquireSkill(player, "sp_yinren")
			room:acquireSkill(player, "sp_shenmou")
			room:acquireSkill(player, "sp_yinyang")
			room:addPlayerMark(player, self:objectName())
			room:addPlayerMark(player, "@waked")
		end
	end,
	can_trigger = function(self, player)
	    return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
sp_shensima:addSkill(sp_xiongxin)
sp_shensima:addRelateSkill("sp_yinren")
sp_shensima:addRelateSkill("sp_shenmou")
sp_shensima:addRelateSkill("sp_yinyang")
--“隐忍”
sp_yinren = sgs.CreateTriggerSkill{
    name = "sp_yinren",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() == sgs.Player_RoundStart then
			if room:askForSkillInvoke(player, self:objectName(), data) then
		    	room:broadcastSkillInvoke(self:objectName())
				local hc = player:getHandcardNum()
	            local card_id = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		        if card_id then
				    card_id:deleteLater()
			        card_id = room:askForExchange(player, self:objectName(), hc, hc, false, "")
		        end
		        player:addToPile(self:objectName(), card_id, false)
				player:turnOver()
			end
		end
	end,
}
if not sgs.Sanguosha:getSkill("sp_yinren") then skills:append(sp_yinren) end
--“深谋”
sp_shenmouCard = sgs.CreateSkillCard{
	name = "sp_shenmouCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local cards = room:getNCards(3)
		local right = cards
		local tricks = sgs.IntList()
		local non_tricks = sgs.IntList()
		for _, card_id in sgs.qlist(cards) do
			local card = sgs.Sanguosha:getCard(card_id)
			if card:isKindOf("TrickCard") then
				tricks:append(card_id)
			else
				non_tricks:append(card_id)
			end
		end
		local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		if not tricks:isEmpty() then
			room:fillAG(right, source, non_tricks)
			local id1 = room:askForAG(source, tricks, true, "sp_shenmou")
			tricks:removeOne(id1)
			right:removeOne(id1)
			dummy:addSubcard(id1)
		end
		room:clearAG(source)
		if dummy:subcardsLength() > 0 then
			source:obtainCard(dummy, false)
		end
		room:askForGuanxing(source, right, sgs.Room_GuanxingUpOnly)
	end,
}
sp_shenmou = sgs.CreateZeroCardViewAsSkill{
	name = "sp_shenmou",
	view_as = function()
		return sp_shenmouCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#sp_shenmouCard")
	end,
}
if not sgs.Sanguosha:getSkill("sp_shenmou") then skills:append(sp_shenmou) end
--“阴养”
sp_yinyang = sgs.CreateTriggerSkill{
    name = "sp_yinyang",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to == sgs.Player_NotActive then
			for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				local current = room:getCurrent()
				if current:objectName() ~= p:objectName() then break end
				if room:askForSkillInvoke(p, self:objectName(), data) then
					local ss = room:askForPlayerChosen(p, room:getOtherPlayers(p), self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					local id = room:askForCardChosen(p, ss, "he", self:objectName())
					ss:addToPile("sp_ss", id, false)
					if not ss:hasSkill("sp_sishi") then
						room:attachSkillToPlayer(ss, "sp_sishi") --给目标角色可以执行【出牌阶段可以失去1点体力并获得所有“死士”牌】的技能按钮（在其武将头像左上方）
					end
				end
				break
			end
		end
	end,
}
sp_yinyangSSJQ = sgs.CreateTriggerSkill{
	name = "sp_yinyangSSJQ",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Predamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		room:loseHp(damage.to, damage.damage)
		return true
	end,
	can_trigger = function(self, player)
		return player:getPile("sp_ss"):length() > 0
	end,
}
  --“死士”技能按钮（出牌阶段可以失去1点体力并获得所有“死士”牌）
sp_sishiCard = sgs.CreateSkillCard{
	name = "sp_sishiCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:loseHp(source, 1)
		local dummy = sgs.Sanguosha:cloneCard("slash")
		dummy:addSubcards(source:getPile("sp_ss"))
		room:obtainCard(source, dummy, false)
		dummy:deleteLater()
		room:detachSkillFromPlayer(source, "sp_sishi", true)
	end,
}
sp_sishi = sgs.CreateZeroCardViewAsSkill{
	name = "sp_sishi&",
	view_as = function()
		return sp_sishiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getPile("sp_ss"):length() > 0
	end,
}
if not sgs.Sanguosha:getSkill("sp_yinyang") then skills:append(sp_yinyang) end
if not sgs.Sanguosha:getSkill("sp_yinyangSSJQ") then skills:append(sp_yinyangSSJQ) end
if not sgs.Sanguosha:getSkill("sp_sishi") then skills:append(sp_sishi) end

sp_zhengbianCard = sgs.CreateSkillCard{
	name = "sp_zhengbianCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@sp_zhengbian")
		room:doSuperLightbox("sp_shensima", "sp_zhengbian")
		if source:hasSkill("sp_zhuangbing") then
			room:detachSkillFromPlayer(source, "sp_zhuangbing")
		end
		if source:hasSkill("sp_yinren") then
			room:detachSkillFromPlayer(source, "sp_yinren", false, true)
		end
		if source:hasSkill("sp_shenmou") then
			room:detachSkillFromPlayer(source, "sp_shenmou", false, true)
		end
		if source:hasSkill("sp_yinyang") then
			room:detachSkillFromPlayer(source, "sp_yinyang", false, true)
		end
		local dummy = sgs.Sanguosha:cloneCard("slash")
		dummy:addSubcards(source:getPile("sp_yinren"))
		local x = source:getPile("sp_yinren"):length()
		room:obtainCard(source, dummy, false)
		dummy:deleteLater()
		room:addPlayerMark(source, "&sp_zhengbian", x)
		room:setPlayerFlag(source, "sp_zhengbianTurn")
		local count = source:getMaxHp()
		room:setPlayerProperty(source, "maxhp", sgs.QVariant(count+x))
		local caoshuang = room:askForPlayerChosen(source, room:getOtherPlayers(source), "sp_zhengbian", "sp_zhengbianToDo")
		room:broadcastSkillInvoke("sp_zhengbian")
		room:addPlayerMark(caoshuang, "&sp_zhengbianTarget")
	end,
}
sp_zhengbianVS = sgs.CreateZeroCardViewAsSkill{
	name = "sp_zhengbian",
	view_as = function()
		return sp_zhengbianCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@sp_zhengbian") > 0
	end,
}
sp_zhengbian = sgs.CreateTriggerSkill{
	name = "sp_zhengbian",
	frequency = sgs.Skill_Limited,
	waked_skills = "sp_kongju",
	limit_mark = "@sp_zhengbian",
	view_as_skill = sp_zhengbianVS,
	on_trigger = function()
	end,
}
sp_zhengbianBuff_distance = sgs.CreateDistanceSkill{
	name = "sp_zhengbianBuff_distance",
	correct_func = function(self, from, to)
		if from:hasSkill("sp_zhengbian") and from:hasFlag("sp_zhengbianTurn") and to and to:getMark("&sp_zhengbianTarget") > 0 then
			local n = from:getMark("&sp_zhengbian")
			return -n
		else
			return 0
		end
	end,
}
sp_zhengbianBuff_slashmore = sgs.CreateTargetModSkill{
	name = "sp_zhengbianBuff_slashmore",
	global = true,
	frequency = sgs.Skill_NotCompulsory,
	residue_func = function(self, from, card, to)
		if from:hasSkill("sp_zhengbian") and from:hasFlag("sp_zhengbianTurn") and card:isKindOf("Slash") and to and to:getMark("&sp_zhengbianTarget") > 0 then
			local n = from:getMark("&sp_zhengbian")
			return n
		else
			return 0
		end
	end,
}
sp_zhengbianClear = sgs.CreateTriggerSkill{
	name = "sp_zhengbianClear",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to == sgs.Player_NotActive then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("&sp_zhengbianTarget") > 0 then
					local n = p:getMark("&sp_zhengbianTarget")
					room:removePlayerMark(p, "&sp_zhengbianTarget", n)
				end
			end
			for _, q in sgs.qlist(room:getAllPlayers()) do
				if q:hasFlag("sp_zhengbianTurn") then
					room:setPlayerFlag(q, "-sp_zhengbianTurn")
					if q:hasSkill("sp_zhengbian") then
						room:sendCompulsoryTriggerLog(q, "sp_zhengbian")
						room:broadcastSkillInvoke("sp_zhengbian")
						room:acquireSkill(q, "sp_kongju")
						q:gainAnExtraTurn()
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
sp_shensima:addSkill(sp_zhengbian)
sp_shensima:addRelateSkill("sp_kongju")
if not sgs.Sanguosha:getSkill("sp_zhengbianBuff_distance") then skills:append(sp_zhengbianBuff_distance) end
if not sgs.Sanguosha:getSkill("sp_zhengbianBuff_slashmore") then skills:append(sp_zhengbianBuff_slashmore) end
if not sgs.Sanguosha:getSkill("sp_zhengbianClear") then skills:append(sp_zhengbianClear) end
--“控局”
sp_kongjuCard = sgs.CreateSkillCard{
	name = "sp_kongjuCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
	    local plist = room:getAllPlayers()
		local choice = room:askForChoice(source, "sp_kongju", "lose1MaxHptochosetodo+randomtodo")
		
		if choice == "lose1MaxHptochosetodo" then
		    room:loseMaxHp(source, 1)
			local choicees = {}
			table.insert(choicees, "one")
			table.insert(choicees, "two")
			if source:hasEquipArea() then
				table.insert(choicees, "three")
			end
			table.insert(choicees, "fail")
			local choicee = room:askForChoice(source, "sp_kongju", table.concat(choicees, "+"))
			if choicee == "one" then
			    local can_invoke = false
				for _, p in sgs.qlist(plist) do
				    if p:getEquips():length() > 0 or p:getJudgingArea():length() > 0 then
					    can_invoke = true
						break
					end
				end
				if can_invoke then
				    local from = room:askForPlayerChosen(source, plist, "sp_kongju", "sp_kongjuOne")
					if from:getEquips():length() == 0 and from:getJudgingArea():length() == 0 then return false end
					local card_id = room:askForCardChosen(source, from, "ej", "sp_kongju")
					local card = sgs.Sanguosha:getCard(card_id)
					local place = room:getCardPlace(card_id)
					local equip_index = -1
					if place == sgs.Player_PlaceEquip then
						local equip = card:getRealCard():toEquipCard()
						equip_index = equip:location()
					end
					local tos = sgs.SPlayerList()
					local list = room:getAlivePlayers()
					for _, p in sgs.qlist(list) do
						if equip_index ~= -1 then
							if not p:getEquip(equip_index) then
								tos:append(p)
							end
						else
							if not source:isProhibited(p, card) and not p:containsTrick(card:objectName()) then
								tos:append(p)
							end
						end
					end
					local tag = sgs.QVariant()
					tag:setValue(from)
					room:setTag("sp_kongjuOneTarget", tag)
					local to = room:askForPlayerChosen(source, tos, "sp_kongju", "@sp_kongjuOne-to:" .. card:objectName())
					if to then
						room:moveCardTo(card, from, to, place, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, source:objectName(), "sp_kongju", ""))
					end
					room:removeTag("sp_kongjuOneTarget")
				else
				    local log = sgs.LogMessage()
				    log.type = "$sp_kongjuFail"
				    log.from = source
				    room:sendLog(log)
					room:setPlayerFlag(source, "Global_PlayPhaseTerminated")
				end
			elseif choicee == "two" then
			    local can_invoke = false
				for _, p in sgs.qlist(plist) do
				    if not p:isKongcheng() then
					    can_invoke = true
						break
					end
				end
				if can_invoke then
				    local from = room:askForPlayerChosen(source, plist, "sp_kongju", "sp_kongjuTwoF")
					if from:isKongcheng() then return false end
					local card = room:askForCardChosen(source, from, "h", "sp_kongju")
					local plistTwo = room:getOtherPlayers(from)
					local to = room:askForPlayerChosen(source, plistTwo, "sp_kongju", "sp_kongjuTwoT")
					room:obtainCard(to, card, false)
				else
				    local log = sgs.LogMessage()
				    log.type = "$sp_kongjuFail"
				    log.from = source
				    room:sendLog(log)
					room:setPlayerFlag(source, "Global_PlayPhaseTerminated")
				end
			elseif choicee == "three" then
			    local can_invoke = false
				if source:hasEquipArea() then can_invoke = true end
				if can_invoke then
				    local choices = {}
					for i = 0, 4 do
				        if source:hasEquipArea(i) then
					        table.insert(choices, i)
				        end
			        end
					if choices == "" then return false end
					local choiceee = room:askForChoice(source, "sp_kongju", table.concat(choices, "+"))
					local area = tonumber(choiceee), 0
					source:throwEquipArea(area)
					local dmd = room:askForPlayerChosen(source, plist, "sp_kongju", "sp_kongjuThree")
					dmd:throwAllMarks(true)
				else
				    local log = sgs.LogMessage()
				    log.type = "$sp_kongjuFail"
				    log.from = source
				    room:sendLog(log)
					room:setPlayerFlag(source, "Global_PlayPhaseTerminated")
				end
			elseif choicee == "fail" then
			    local log = sgs.LogMessage()
				log.type = "$sp_kongjuFail"
				log.from = source
				room:sendLog(log)
				room:setPlayerFlag(source, "Global_PlayPhaseTerminated")
			end
		elseif choice == "randomtodo" then
		    local n = math.random(1,4)
			if n == 1 then
			    local can_invoke = false
				for _, p in sgs.qlist(plist) do
				    if p:getEquips():length() > 0 or p:getJudgingArea():length() > 0 then
					    can_invoke = true
						break
					end
				end
				if can_invoke then
				    local from = room:askForPlayerChosen(source, plist, "sp_kongju", "sp_kongjuOne")
					if from:getEquips():length() == 0 and from:getJudgingArea():length() == 0 then return false end
					local card_id = room:askForCardChosen(source, from, "ej", "sp_kongju")
					local card = sgs.Sanguosha:getCard(card_id)
					local place = room:getCardPlace(card_id)
					local equip_index = -1
					if place == sgs.Player_PlaceEquip then
						local equip = card:getRealCard():toEquipCard()
						equip_index = equip:location()
					end
					local tos = sgs.SPlayerList()
					local list = room:getAlivePlayers()
					for _, p in sgs.qlist(list) do
						if equip_index ~= -1 then
							if not p:getEquip(equip_index) then
								tos:append(p)
							end
						else
							if not source:isProhibited(p, card) and not p:containsTrick(card:objectName()) then
								tos:append(p)
							end
						end
					end
					local tag = sgs.QVariant()
					tag:setValue(from)
					room:setTag("sp_kongjuOneTarget", tag)
					local to = room:askForPlayerChosen(source, tos, "sp_kongju", "@sp_kongjuOne-to:" .. card:objectName())
					if to then
						room:moveCardTo(card, from, to, place, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, source:objectName(), "sp_kongju", ""))
					end
					room:removeTag("sp_kongjuOneTarget")
				else
				    local log = sgs.LogMessage()
				    log.type = "$sp_kongjuFail"
				    log.from = source
				    room:sendLog(log)
					room:setPlayerFlag(source, "Global_PlayPhaseTerminated")
				end
			elseif n == 2 then
			    local can_invoke = false
				for _, p in sgs.qlist(plist) do
				    if not p:isKongcheng() then
					    can_invoke = true
						break
					end
				end
				if can_invoke then
				    local from = room:askForPlayerChosen(source, plist, "sp_kongju", "sp_kongjuTwoF")
					if from:isKongcheng() then return false end
					local card = room:askForCardChosen(source, from, "h", "sp_kongju")
					local plistTwo = room:getOtherPlayers(from)
					local to = room:askForPlayerChosen(source, plistTwo, "sp_kongju", "sp_kongjuTwoT")
					room:obtainCard(to, card, false)
				else
				    local log = sgs.LogMessage()
				    log.type = "$sp_kongjuFail"
				    log.from = source
				    room:sendLog(log)
					room:setPlayerFlag(source, "Global_PlayPhaseTerminated")
				end
			elseif n == 3 then
			    local can_invoke = false
				if source:hasEquipArea() then can_invoke = true end
				if can_invoke then
				    local choices = {}
					for i = 0, 4 do
				        if source:hasEquipArea(i) then
					        table.insert(choices, i)
				        end
			        end
					if choices == "" then return false end
					local choiceee = room:askForChoice(source, "sp_kongju", table.concat(choices, "+"))
					local area = tonumber(choiceee), 0
					source:throwEquipArea(area)
					local dmd = room:askForPlayerChosen(source, plist, "sp_kongju", "sp_kongjuThree")
					dmd:throwAllMarks(true)
				else
				    local log = sgs.LogMessage()
				    log.type = "$sp_kongjuFail"
				    log.from = source
				    room:sendLog(log)
					room:setPlayerFlag(source, "Global_PlayPhaseTerminated")
				end
			elseif n == 4 then
			    local log = sgs.LogMessage()
				log.type = "$sp_kongjuFail"
				log.from = source
				room:sendLog(log)
				room:setPlayerFlag(source, "Global_PlayPhaseTerminated")
			end
		end
	end,
}
sp_kongju = sgs.CreateZeroCardViewAsSkill{
	name = "sp_kongju",
	view_as = function()
		return sp_kongjuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return true
	end,
}
if not sgs.Sanguosha:getSkill("sp_kongju") then skills:append(sp_kongju) end

sp_tuntian = sgs.CreateTriggerSkill{
	name = "sp_tuntian",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		if death.who:objectName() ~= player:objectName() then
		    local killer
		    if death.damage then
			    killer = death.damage.from
		    else
			    killer = nil
		    end
		    local current = room:getCurrent()
		    if killer:hasSkill(self:objectName()) and (current:isAlive() or current:objectName() == death.who:objectName()) then
				room:sendCompulsoryTriggerLog(killer, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local count = killer:getMaxHp()
				room:setPlayerProperty(killer, "maxhp", sgs.QVariant(count+1))
			end
		end   
	end,
}
sp_shensima:addSkill(sp_tuntian)

--27 剑神·刘备
sp_shenliubei = sgs.General(extension_G, "sp_shenliubei", "god", 3, true)

sp_yingjieCard = sgs.CreateSkillCard{
    name = "sp_yingjieCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
	    targets[1]:obtainCard(self, false)
	end,
}
sp_yingjieVS = sgs.CreateViewAsSkill{
    name = "sp_yingjie",
	n = 1,
	view_filter = function(self, selected, to_select)
	    return true
	end,
	view_as = function(self, cards)
	    if #cards == 1 then
			local zhangyi_card = sp_yingjieCard:clone()
			zhangyi_card:addSubcard(cards[1])
			return zhangyi_card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isNude()
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@sp_yingjie")
	end,
}
sp_yingjie = sgs.CreateTriggerSkill{
	name = "sp_yingjie",
	priority = {3, 2},
	change_skill = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed, sgs.CardResponded},
	view_as_skill = sp_yingjieVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local card = nil
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			card = use.card
		else
			local response = data:toCardResponse()
			if response.m_isUse then
				card = response.m_card
			end
		end
		
		local n = player:getChangeSkillState(self:objectName())
		if card and not card:isKindOf("SkillCard") and player:hasSkill(self:objectName()) then
		    if n == 1 then
			    if room:askForSkillInvoke(player, "@sp_yingjie-xingxia", data) then
					local xingxia = room:getAllPlayers()
					local xiongdi = room:askForPlayerChosen(player, xingxia, self:objectName(), "sp_yingjie-invoke")
					room:drawCards(xiongdi, math.random(1,3))
					room:broadcastSkillInvoke(self:objectName())
					room:setChangeSkillState(player, self:objectName(), 2) --切换为“仗义”
				end
			elseif n == 2 then
                if not player:isNude() and room:askForSkillInvoke(player, "@sp_yingjie-zhangyi", data) then
					room:askForUseCard(player, "@@sp_yingjie!", "@sp_yingjie-card")
					if player:getState() == "robot" and not room:askForUseCard(player, "@@sp_yingjie!", "@sp_yingjie-card") then
						local zhangyi = room:getOtherPlayers(player)
						local xiongdi = room:askForPlayerChosen(player, zhangyi, "sp_yingjiee")
						local card = room:askForCardChosen(player, player, "he", self:objectName())
						room:obtainCard(xiongdi, card, false)
					end
					local recover = sgs.RecoverStruct()
					recover.recover = math.random(0,1)
					recover.who = player
					room:recover(player, recover)
					room:setChangeSkillState(player, self:objectName(), 1) --切换为“行侠”
				end
			end
		end
	end,
}
sp_shenliubei:addSkill(sp_yingjie)

sp_yuanzhiCard = sgs.CreateSkillCard{
	name = "sp_yuanzhiCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and not to_select:isKongcheng() and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
		local success = source:pindian(targets[1], "sp_yuanzhi", nil)
		if success then
			room:drawCards(source, 1)
			room:addPlayerMark(source, "&sp_yuanzhiFQC")
			room:addPlayerMark(source, "sp_yuanzhiUF")
		else
			room:addPlayerMark(source, "sp_yuanzhiUF")
			room:addPlayerMark(source, "sp_yuanzhiFail")
			local choice = room:askForChoice(source, "sp_yuanzhi", "1+2")
			if choice == "1" then
				local n = source:getMark("sp_yuanzhiFail")
				if not source:isNude() then
					room:askForDiscard(source, "sp_yuanzhi", n, n, false, true)
				end
				room:removePlayerMark(source, "&sp_yuanzhiFQC")
			elseif choice == "2" then
			    local n = source:getMark("&sp_yuanzhiFQC")
				room:removePlayerMark(source, "&sp_yuanzhiFQC", n)
				room:addPlayerMark(source, "sp_yuanzhiTR", 2) --获得两枚此标记是为了下回合出牌阶段结束重置“远志”次数
			end
		end
	end,
}
sp_yuanzhi = sgs.CreateZeroCardViewAsSkill{
	name = "sp_yuanzhi",
	view_as = function()
		return sp_yuanzhiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("&sp_yuanzhiFQC") > player:getMark("sp_yuanzhiUF") and not player:isKongcheng()
	end,
}
sp_yuanzhiExtra = sgs.CreateTriggerSkill{
    name = "sp_yuanzhiExtra",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.EventPhaseChanging, sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:hasSkill("sp_rongma") then room:addPlayerMark(player, "sp_rongmaTrigger") end --游戏开始后，才能触发“戎马”
			if player:hasSkill("sp_yuanzhi") then room:addPlayerMark(player, "&sp_yuanzhiFQC") end
		elseif event == sgs.EventPhaseChanging then
		    local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("sp_yuanzhiUF") > 0 then
					local n = p:getMark("sp_yuanzhiUF")
					room:removePlayerMark(p, "sp_yuanzhiUF", n)
				end
			end
		elseif event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Play then
		    if player:getMark("sp_yuanzhiTR") == 1 then
			    room:removePlayerMark(player, "sp_yuanzhiTR")
				if player:getMark("&sp_yuanzhiFQC") > 0 then --保证是让“远志”次数重置为1
					local n = player:getMark("&sp_yuanzhiFQC")
					room:removePlayerMark(player, "&sp_yuanzhiFQC", n)
				end
				room:addPlayerMark(player, "&sp_yuanzhiFQC")
			elseif player:getMark("sp_yuanzhiTR") == 2 then
			    room:removePlayerMark(player, "sp_yuanzhiTR")
				return false
			end
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
sp_shenliubei:addSkill(sp_yuanzhi)
if not sgs.Sanguosha:getSkill("sp_yuanzhiExtra") then skills:append(sp_yuanzhiExtra) end

sp_rongma = sgs.CreateTriggerSkill{
    name = "sp_rongma",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damage, sgs.Damaged, sgs.BeforeCardsMove, sgs.MarkChanged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damage or event == sgs.Damaged then
			local damage = data:toDamage()
			room:sendCompulsoryTriggerLog(player, self:objectName())
			player:gainMark("&sp_rongma")
		elseif event == sgs.BeforeCardsMove then
		    local move = data:toMoveOneTime()
			if move.to and move.to:objectName() == player:objectName() and move.reason.m_reason == sgs.CardMoveReason_S_REASON_DRAW and player:getMark("sp_rongmaTrigger") > 0 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				player:gainMark("&sp_rongma")
			end
		else
			local mark = data:toMark()
			if mark.name == "&sp_rongma" and mark.who:hasSkill(self:objectName()) and mark.who:objectName() == player:objectName() then
				if player:getMark("&sp_rongma") >= 10 and player:getMark("sp_rongma10triggered") == 0 then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName(), 1)
					room:addPlayerMark(player, "&sp_yuanzhiFQC", 2)
					room:addPlayerMark(player, "sp_rongma10triggered")
				end
				if player:getMark("&sp_rongma") >= 20 and player:getMark("sp_rongma20triggered") == 0 then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName(), 2)
					room:addPlayerMark(player, "sp_rongma20triggered") --必须写在摸牌前面，否则会无限触发“戎马”直接暴毙
					room:drawCards(player, 3, self:objectName())
				end
				if player:getMark("&sp_rongma") >= 30 and player:getMark("sp_rongma30triggered") == 0 then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName(), 3)
					local mhp = player:getMaxHp()
					room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp+1))
					room:recover(player, sgs.RecoverStruct(player))
					room:addPlayerMark(player, "sp_rongma30triggered")
				end
				
				if player:getMark("&sp_rongma") >= 40 then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:killPlayer(player)
				end
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill(self:objectName())
	end,
}
sp_shenliubei:addSkill(sp_rongma)



--

--28 军神·陆逊
sp_shenluxun = sgs.General(extension_G, "sp_shenluxun", "god", 3, true)

sp_zaoyan = sgs.CreateTriggerSkill{
	name = "sp_zaoyan",
	global = true,
	priority = {3, 2},
	change_skill = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirming},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.to:length() ~= 1 then return false end
		if use.card and (use.card:isKindOf("Slash") or use.card:isNDTrick()) then
			for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				local n = p:getChangeSkillState(self:objectName())
				if n == 1 and use.card:isRed() and p:getMark("&sp_zaoyanLast") > 0 then
					if p:hasFlag("sp_zaoyan_dontAskMore") then return false end
					if room:askForSkillInvoke(p, "@sp_zaoyan-yang", data) then
						room:setChangeSkillState(p, self:objectName(), 2)
						room:removePlayerMark(p, "&sp_zaoyanLast")
						room:drawCards(p, 1, self:objectName())
						local cardR = room:askForCard(p, ".|red|.|.", "@sp_zaoyan-red", data, self:objectName())
						if cardR then
							for _, to in sgs.qlist(use.to) do
								local nullified_list = use.nullified_list
								table.insert(nullified_list, to:objectName())
								use.nullified_list = nullified_list
								data:setValue(use)
								room:damage(sgs.DamageStruct(self:objectName(), use.from, to, 1, sgs.DamageStruct_Fire))
							end
							room:broadcastSkillInvoke(self:objectName(), 1)
						end
					else
						room:setPlayerFlag(p, "sp_zaoyan_dontAskMore") --防止重复询问
					end
				elseif n == 2 and use.card:isBlack() and p:getMark("&sp_zaoyanLast") > 0 and p:canDiscard(p, "he") then
					if p:hasFlag("sp_zaoyan_dontAskMore") then return false end
					if room:askForSkillInvoke(p, "@sp_zaoyan-yin", data) then
						local cardB = room:askForCard(p, ".|black|.|.", "@sp_zaoyan-black", data, self:objectName())
						if cardB then
							room:setChangeSkillState(p, self:objectName(), 1)
							room:removePlayerMark(p, "&sp_zaoyanLast")
							room:drawCards(p, 1, self:objectName())
							for _, to in sgs.qlist(use.to) do
								local nullified_list = use.nullified_list
								table.insert(nullified_list, to:objectName())
								use.nullified_list = nullified_list
								data:setValue(use)
								room:loseHp(to, 1)
							end
							room:broadcastSkillInvoke(self:objectName(), 2)
						end
					else
						room:setPlayerFlag(p, "sp_zaoyan_dontAskMore")
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
sp_zaoyanClear = sgs.CreateTriggerSkill{
    name = "sp_zaoyanClear",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.TargetConfirmed},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasFlag("sp_zaoyan_dontAskMore") then
				room:setPlayerFlag(p, "-sp_zaoyan_dontAskMore")
			end
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
sp_zaoyanTime = sgs.CreateTriggerSkill{
    name = "sp_zaoyanTime",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.GameStart, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.GameStart then
		    if player:hasSkill("sp_zaoyan") then
				room:sendCompulsoryTriggerLog(player, "sp_zaoyan")
				room:broadcastSkillInvoke("sp_zaoyan", 3)
				room:addPlayerMark(player, "&sp_zaoyanLast")
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_NotActive then
				for _, p in sgs.qlist(room:findPlayersBySkillName("sp_zaoyan")) do
					if p:getMark("&sp_zaoyanLast") < 4 then
						room:sendCompulsoryTriggerLog(p, "sp_zaoyan")
						room:broadcastSkillInvoke("sp_zaoyan", 3)
						room:addPlayerMark(p, "&sp_zaoyanLast")
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
sp_shenluxun:addSkill(sp_zaoyan)
if not sgs.Sanguosha:getSkill("sp_zaoyanClear") then skills:append(sp_zaoyanClear) end
if not sgs.Sanguosha:getSkill("sp_zaoyanTime") then skills:append(sp_zaoyanTime) end

sp_fenyingCard = sgs.CreateSkillCard{
	name = "sp_fenyingCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
	    return #targets < self:subcardsLength()
	end,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@sp_fenying")
		room:doSuperLightbox("sp_shenluxun", "sp_fenying")
		for _, sj in ipairs(targets) do
			room:setPlayerChained(sj)
		end
	end,
}
sp_fenyingVS = sgs.CreateViewAsSkill{
	name = "sp_fenying",
	n = 999,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
	    local card = sp_fenyingCard:clone()
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@sp_fenying") > 0 and player:hasFlag("sp_fenying_CanUse")
	end,
	response_pattern = "@@sp_fenying",
}
sp_fenying = sgs.CreateTriggerSkill{
	name = "sp_fenying",
	global = true,
	frequency = sgs.Skill_Limited,
	limit_mark = "@sp_fenying",
	view_as_skill = sp_fenyingVS,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.nature ~= sgs.DamageStruct_Fire then return false end
		for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
			if p:getMark("@sp_fenying") > 0 then
				room:setPlayerFlag(p, "sp_fenying_CanUse")
				if not room:askForUseCard(p, "@@sp_fenying", "@sp_fenying-card") then
					room:setPlayerFlag(p, "-sp_fenying_CanUse")
				else
					local ly = damage.damage
					if p:getEquips():length() >= ly and p:canDiscard(p, "e") then
						if p:getEquips():length() == ly then
							p:throwAllEquips()
						else
							local ec1 = room:askForCardChosen(p, p, "e", self:objectName())
							room:throwCard(ec1, p, p)
							if ly >= 2 then
								local ec2 = room:askForCardChosen(p, p, "e", self:objectName())
								room:throwCard(ec2, p, p)
							end
							if ly >= 3 then
								local ec3 = room:askForCardChosen(p, p, "e", self:objectName())
								room:throwCard(ec3, p, p)
							end
							if ly >= 4 then
								local ec4 = room:askForCardChosen(p, p, "e", self:objectName())
								room:throwCard(ec4, p, p)
							end
						end
						damage.damage = ly*2
						local log = sgs.LogMessage()
						log.type = "$sp_fenyingDMG"
						log.from = p
						log.to:append(damage.to)
						log.arg = ly
						log.arg2 = damage.damage
						room:sendLog(log)
						data:setValue(damage)
						room:broadcastSkillInvoke(self:objectName())
					end
					local n = p:getMark("&sp_zaoyanLast")
					if n > 0 then
						room:removePlayerMark(p, "&sp_zaoyanLast", n)
						room:drawCards(p, n, self:objectName())
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
sp_shenluxun:addSkill(sp_fenying)

--29 孤神·张辽
sp_shenzhangliao = sgs.General(extension_G, "sp_shenzhangliao", "god", 4, true)

sp_qiangxiCard = sgs.CreateSkillCard{
	name = "sp_qiangxiCard",
	filter = function(self, targets, to_select)
		if #targets >= sgs.Self:getMark("sp_qiangxi") or to_select:objectName() == sgs.Self:objectName() then return false end
		return not to_select:isNude()
	end,
	on_effect = function(self, effect)
		effect.to:setFlags("sp_qiangxiTarget")
	end,
}
sp_qiangxiVS = sgs.CreateZeroCardViewAsSkill{
	name = "sp_qiangxi",
	view_as = function() 
		return sp_qiangxiCard:clone()
	end,
	response_pattern = "@@sp_qiangxi",
}
sp_qiangxi = sgs.CreateDrawCardsSkill{
	name = "sp_qiangxi",
	priority = 1,
	view_as_skill = sp_qiangxiVS,
	draw_num_func = function(self, player, n)
		local room = player:getRoom()
		local targets = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			targets:append(p)
		end
		local num = math.min(targets:length(), n)
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			p:setFlags("-sp_qiangxiTarget")
		end
		if num > 0 then
			room:setPlayerMark(player, "sp_qiangxi", num)
			local count = 0
			if room:askForUseCard(player, "@@sp_qiangxi", "@sp_qiangxi-card:::" .. tostring(num)) then
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:hasFlag("sp_qiangxiTarget") then
						count = count + 1
					end
				end
			else 
				room:setPlayerMark(player, "sp_qiangxi", 0)
			end
			return n - count
		else
			return n
		end
	end,
}
sp_qiangxiAct = sgs.CreateTriggerSkill{
	name = "sp_qiangxiAct",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.AfterDrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getMark("sp_qiangxi") == 0 then return false end
		room:setPlayerMark(player, "sp_qiangxi", 0)
		local targets = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:hasFlag("sp_qiangxiTarget") then
				p:setFlags("-sp_qiangxiTarget")
				targets:append(p)
			end
		end
		for _, p in sgs.qlist(targets) do
			if not player:isAlive() then
				break
			end
			if p:isAlive() and not p:isNude() then
				local card_id = room:askForCardChosen(player, p, "he", "sp_qiangxi")
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
				room:broadcastSkillInvoke("sp_qiangxi")
				room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, false)
				room:damage(sgs.DamageStruct("sp_qiangxi", player, p, 1, sgs.DamageStruct_Normal))
			end
		end
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end,
}
sp_shenzhangliao:addSkill(sp_qiangxi)
if not sgs.Sanguosha:getSkill("sp_qiangxiAct") then skills:append(sp_qiangxiAct) end

sp_liaolai = sgs.CreateTriggerSkill{
	name = "sp_liaolai",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local sunshiwan = damage.to
		if sunshiwan:getKingdom() == "wu" then
			local n = 0
			if player:getHp() < sunshiwan:getHp() then n = n + 1 end
			if player:getHandcardNum() < sunshiwan:getHandcardNum() then n = n + 1 end
			if n > 0 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local sqxr = damage.damage
				damage.damage = sqxr + n
				data:setValue(damage)
			end
		end
	end,
}
sp_shenzhangliao:addSkill(sp_liaolai)





--

--30 奇神·甘宁
sp_shenganning = sgs.General(extension_G, "sp_shenganning", "god", 4, true)

sp_lvezhenCard = sgs.CreateSkillCard{
    name = "sp_lvezhenCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
	    local n = source:getChangeSkillState("sp_lvezhen")
		if n == 1 then
			room:setChangeSkillState(source, "sp_lvezhen", 2)
			room:addPlayerMark(source, "sp_lvezhenFQC")
			local choices = {}
			for i = 0, 4 do
				if source:hasEquipArea(i) then
					table.insert(choices, i)
				end
			end
			if choices == "" then return false end
			local choice = room:askForChoice(source, "sp_lvezhen", table.concat(choices, "+"))
			local area = tonumber(choice), 0
			source:throwEquipArea(area)
			room:askForUseCard(source, "@@sp_lvezhen_SSQY", "@sp_lvezhen_SSQY-yang")
		elseif n == 2 then
			room:setChangeSkillState(source, "sp_lvezhen", 1)
			room:addPlayerMark(source, "sp_lvezhenFQC")
			local choices = {}
			for i = 0, 4 do
				if source:hasEquipArea(i) then
					table.insert(choices, i)
				end
			end
			if choices == "" then return false end
			local choice = room:askForChoice(source, "sp_lvezhen", table.concat(choices, "+"))
			local area = tonumber(choice), 0
			source:throwEquipArea(area)
			room:askForUseCard(source, "@@sp_lvezhen_GHCQ", "@sp_lvezhen_GHCQ-yin")
		end
	end,
}
sp_lvezhenVS = sgs.CreateZeroCardViewAsSkill{
    name = "sp_lvezhen",
	view_as = function()
		return sp_lvezhenCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:hasEquipArea() and player:getMark("sp_lvezhenFQC") < 2
	end,
}
sp_lvezhen = sgs.CreatePhaseChangeSkill{
    name = "sp_lvezhen",
	change_skill = true,
	frequency = sgs.Skill_NotFrequent,
	view_as_skill = sp_lvezhenVS,
	on_phasechange = function()
	end,
}
sp_lvezhenFQC_Clear = sgs.CreateTriggerSkill{
	name = "sp_lvezhenFQC_Clear",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then
			return false
		end
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:getMark("sp_lvezhenFQC") > 0 then
				local n = p:getMark("sp_lvezhenFQC")
				room:removePlayerMark(p, "sp_lvezhenFQC", n)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
sp_shenganning:addSkill(sp_lvezhen)
if not sgs.Sanguosha:getSkill("sp_lvezhenFQC_Clear") then skills:append(sp_lvezhenFQC_Clear) end
--==“掠阵”技能卡==--
--“阳”状态技能卡：
sp_lvezhen_SSQY = sgs.CreateOneCardViewAsSkill{
	name = "sp_lvezhen_SSQY",
	filter_pattern = ".|red",
	view_as = function(self, card)
		local acard = sgs.Sanguosha:cloneCard("snatch", card:getSuit(), card:getNumber())
		acard:addSubcard(card:getId())
		acard:setSkillName("sp_lvezhen")
		return acard
	end,
	response_pattern = "@@sp_lvezhen_SSQY",
}
--“阴”状态技能卡：
sp_lvezhen_GHCQ = sgs.CreateOneCardViewAsSkill{
	name = "sp_lvezhen_GHCQ",
	filter_pattern = ".|black",
	view_as = function(self, card)
		local icard = sgs.Sanguosha:cloneCard("dismantlement", card:getSuit(), card:getNumber())
		icard:addSubcard(card:getId())
		icard:setSkillName("sp_lvezhen")
		return icard
	end,
	response_pattern = "@@sp_lvezhen_GHCQ",
}
--技能卡效果：
sp_lvezhen_SSQY_moredistance = sgs.CreateTargetModSkill{
	name = "sp_lvezhen_SSQY_moredistance",
	pattern = "Snatch",
	distance_limit_func = function(self, from, card)
		if from and card:getSkillName() == "sp_lvezhen" then
			return 1
		else
			return 0
		end
	end,
}
sp_lvezhen_SkillCardBuffCard = sgs.CreateSkillCard{
	name = "sp_lvezhen_SkillCardBuffCard",
	mute = true,
	filter = function(self, targets, to_select, player)
		return #targets < 1 and to_select:hasFlag("sp_lvezhen_SkillCardBuff")
	end,
	about_to_use = function(self, room, use)
		for _, p in sgs.qlist(use.to) do
			room:setPlayerFlag(p, "sp_lvezhen_SkillCardBuff_GHCQ")
		end
	end,
}
sp_lvezhen_SkillCardBuffVS = sgs.CreateZeroCardViewAsSkill{
	name = "sp_lvezhen_SkillCardBuff",
	view_as = function()
		return sp_lvezhen_SkillCardBuffCard:clone()
	end,
	response_pattern = "@@sp_lvezhen_SkillCardBuff",
}
sp_lvezhen_SkillCardBuff = sgs.CreateTriggerSkill{
	name = "sp_lvezhen_SkillCardBuff",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.PreCardUsed, sgs.CardFinished},
	view_as_skill = sp_lvezhen_SkillCardBuffVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.PreCardUsed then
			local use = data:toCardUse()
			if use.card:isKindOf("Dismantlement") and use.card:getSkillName() == "sp_lvezhen" then
				local extra_targets = room:getCardTargets(player, use.card, use.to)
				if extra_targets:isEmpty() then return false end
				for _, p in sgs.qlist(extra_targets) do
					room:setPlayerFlag(p, "sp_lvezhen_SkillCardBuff")
				end
				room:askForUseCard(player, "@@sp_lvezhen_SkillCardBuff", "@sp_lvezhen_SkillCardBuff:" .. use.card:objectName() .. "::" .. 1, -1, sgs.Card_MethodNone)
				local adds = sgs.SPlayerList()
				for _, p in sgs.qlist(extra_targets) do
					room:setPlayerFlag(p, "-sp_lvezhen_SkillCardBuff")
					if p:hasFlag("sp_lvezhen_SkillCardBuff_GHCQ") then
						room:setPlayerFlag(p, "-sp_lvezhen_SkillCardBuff_GHCQ")
						use.to:append(p)
						adds:append(p)
					end
				end
				if adds:isEmpty() then return false end
				room:sortByActionOrder(adds)
				room:sortByActionOrder(use.to)
				data:setValue(use)
				local log = sgs.LogMessage()
				log.type = "#QiaoshuiAdd"
				log.from = player
				log.to = adds
				log.card_str = use.card:toString()
				log.arg = "sp_lvezhen"
				room:sendLog(log)
				for _, p in sgs.qlist(adds) do
					room:doAnimate(1, player:objectName(), p:objectName())
				end
				room:notifySkillInvoked(player, self:objectName())
				room:broadcastSkillInvoke("sp_lvezhen")
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.card:getSkillName() ~= "sp_lvezhen" then return false end
			if use.card:isKindOf("Snatch") then
				for _, p in sgs.qlist(use.to) do
					if not p:isKongcheng() then
						local card = room:askForCardChosen(player, p, "h", "sp_lvezhen")
						room:obtainCard(player, card, false)
						room:broadcastSkillInvoke("sp_lvezhen")
					end
				end
			elseif use.card:isKindOf("Dismantlement") then
				for _, p in sgs.qlist(use.to) do
					if not p:isAllNude() then
						local card = room:askForCardChosen(player, p, "hej", "sp_lvezhen")
						room:throwCard(card, p, player)
						room:broadcastSkillInvoke("sp_lvezhen")
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("sp_lvezhen")
	end,
}
--
----
if not sgs.Sanguosha:getSkill("sp_lvezhen_SSQY") then skills:append(sp_lvezhen_SSQY) end
if not sgs.Sanguosha:getSkill("sp_lvezhen_GHCQ") then skills:append(sp_lvezhen_GHCQ) end
if not sgs.Sanguosha:getSkill("sp_lvezhen_SSQY_moredistance") then skills:append(sp_lvezhen_SSQY_moredistance) end
if not sgs.Sanguosha:getSkill("sp_lvezhen_SkillCardBuff") then skills:append(sp_lvezhen_SkillCardBuff) end

sp_xiyingCard = sgs.CreateSkillCard{
	name = "sp_xiyingCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets < 1 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		room:removePlayerMark(effect.from, "@sp_xiying")
		room:doSuperLightbox("sp_shenganning", "sp_xiying")
		room:setPlayerFlag(effect.from, "sp_xiyingSource")
		room:addPlayerMark(effect.to, "&sp_xiyingTarget")
		effect.from:throwAllHandCards()
		if not effect.to:isKongcheng() then
			room:obtainCard(effect.from, effect.to:wholeHandCards(), false)
		end
		room:setFixedDistance(effect.from, effect.to, 1)
		local new_data = sgs.QVariant()
		new_data:setValue(effect.to)
		effect.from:setTag("sp_xiying", new_data)
	end,
}
sp_xiyingVS = sgs.CreateZeroCardViewAsSkill{
	name = "sp_xiying",
	view_as = function()
		return sp_xiyingCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@sp_xiying") > 0
	end,
}
sp_xiying = sgs.CreateTriggerSkill{
	name = "sp_xiying",
	frequency = sgs.Skill_Limited,
	limit_mark = "@sp_xiying",
	view_as_skill = sp_xiyingVS,
	on_trigger = function()
	end,
}
sp_xiyingSettle = sgs.CreateTriggerSkill{
	name = "sp_xiyingSettle",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damage, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damage then
			local damage = data:toDamage()
			if damage.from:objectName() == player:objectName() and player:hasFlag("sp_xiyingSource") and damage.to and damage.to:getMark("&sp_xiyingTarget") > 0 then
				room:broadcastSkillInvoke("sp_xiying")
				room:addPlayerMark(player, "&sp_xiyingDMG", damage.damage)
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			local caoying = player:getTag("sp_xiying"):toPlayer() 
			if caoying then room:setFixedDistance(player, caoying, -1)
			end
			player:removeTag("sp_xiying")
			if not player:hasFlag("sp_xiyingSource") then return false end
			for _, cy in sgs.qlist(room:getOtherPlayers(player)) do
				if cy:isAlive() and cy:getMark("&sp_xiyingTarget") > 0 then
					if not player:isKongcheng() then
						room:obtainCard(cy, player:wholeHandCards(), false)
					end
					room:removePlayerMark(cy, "&sp_xiyingTarget")
				end
			end
			local n = player:getMark("&sp_xiyingDMG")
			room:drawCards(player, n, "sp_xiying")
			room:broadcastSkillInvoke("sp_xiying")
			room:removePlayerMark(player, "&sp_xiyingDMG", n)
			room:setPlayerFlag(player, "-sp_xiyingSource")
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("sp_xiying")
	end,
}
sp_shenganning:addSkill(sp_xiying)
if not sgs.Sanguosha:getSkill("sp_xiyingSettle") then skills:append(sp_xiyingSettle) end

sp_shenya = sgs.CreateTriggerSkill{
    name = "sp_shenya",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damage, sgs.EventPhaseChanging, sgs.AskForPeachesDone},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.Damage then
			local damage = data:toDamage()
			if damage.from:objectName() == player:objectName() and player:getPhase() ~= sgs.Player_NotActive and not player:hasFlag("sp_shenyaDMGCaused") then
				room:setPlayerFlag(player, "sp_shenyaDMGCaused")
			end
		elseif event == sgs.EventPhaseChanging then
		    local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			if not player:hasFlag("sp_shenyaDMGCaused") then return false end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			local choices = {}
			for i = 0, 4 do
				if not player:hasEquipArea(i) then
					table.insert(choices, i)
				end
			end
			if choices == "" then return false end
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			local area = tonumber(choice), 0
			player:obtainEquipArea(area)
		elseif event == sgs.AskForPeachesDone then
			local dying = data:toDying()
			if player:getHp() <= 0 and dying.damage and dying.damage.from then
				room:killPlayer(dying.who)
				room:setTag("SkipGameRule", sgs.QVariant(true))
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
			end
		end
	end,
}
sp_shenganning:addSkill(sp_shenya)

--战神·吕布“横扫千军”的颜色函数
function GetColor(card)
	if card:isRed() then return "red" elseif card:isBlack() then return "black" end
end
--

--==（V3.0）DIY界限突破包==--
extension_J = sgs.Package("fcDIY_jxtp", sgs.Package_GeneralPack)

--31 界刘繇
fcj_liuyao = sgs.General(extension_J, "fcj_liuyao", "qun", 4, true)

fcj_kannanCard = sgs.CreateSkillCard{
	name = "fcj_kannanCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and not to_select:hasFlag("fcj_kannanSelected") and not to_select:isKongcheng()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local kn = effect.from:pindian(effect.to, self:objectName(), nil)
		if kn then
			room:broadcastSkillInvoke("fcj_kannan")
			room:addPlayerMark(effect.from, "&fcj_kannan", 1)
		else
			room:broadcastSkillInvoke("fcj_kannan")
			room:addPlayerMark(effect.to, "&fcj_kannan", 1)
		end
		room:addPlayerMark(effect.from, "fcj_kannanUsed")
		room:setPlayerFlag(effect.to, "fcj_kannanSelected")
		local choice = room:askForChoice(effect.from, "fcj_kannan", "1+2+3+cancel")
		if choice == "1" then
			room:broadcastSkillInvoke("fcj_kannan")
			room:drawCards(effect.from, 1, "fcj_kannan")
		elseif choice == "2" then
			room:broadcastSkillInvoke("fcj_kannan")
			room:removePlayerMark(effect.from, "fcj_kannanUsed")
		elseif choice == "3" then
			room:broadcastSkillInvoke("fcj_kannan")
			room:setPlayerFlag(effect.to, "-fcj_kannanSelected")
		end
	end,
}
fcj_kannan = sgs.CreateZeroCardViewAsSkill{
	name = "fcj_kannan",
	view_as = function()
		return fcj_kannanCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("fcj_kannanUsed") < player:getHp() and not player:isKongcheng()
	end,
}
fcj_kannanBUFF = sgs.CreateTriggerSkill{
    name = "fcj_kannanBUFF",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.ConfirmDamage, sgs.EventPhaseChanging, sgs.Death},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash") and damage.from:objectName() == player:objectName() and player:getMark("&fcj_kannan") > 0 then
				local jly = room:findPlayerBySkillName("fcj_kannan")
				if not jly then return false end
				room:sendCompulsoryTriggerLog(jly, "fcj_kannan")
				room:broadcastSkillInvoke("fcj_kannan")
				local n = player:getMark("&fcj_kannan")
				damage.damage = damage.damage + n
				room:setPlayerMark(player, "&fcj_kannan", 0)
				data:setValue(damage)
			end
		elseif event == sgs.EventPhaseChanging or event == sgs.Death then
		    if event == sgs.EventPhaseChanging then
				local change = data:toPhaseChange()
				if change.to ~= sgs.Player_NotActive then return false end
				for _, p in sgs.qlist(room:getAllPlayers()) do
					room:setPlayerMark(p, "fcj_kannanUsed", 0)
					if p:hasFlag("fcj_kannanSelected") then room:setPlayerFlag(p, "-fcj_kannanSelected") end
				end
			end
			if event == sgs.Death then
				local death = data:toDeath()
				if death.who:objectName() ~= player:objectName() then return false end
				local jly = room:findPlayerBySkillName("fcj_kannan")
				if jly then return false end
				for _, p in sgs.qlist(room:getAllPlayers()) do
					room:setPlayerMark(p, "&fcj_kannan", 0)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
fcj_liuyao:addSkill(fcj_kannan)
if not sgs.Sanguosha:getSkill("fcj_kannanBUFF") then skills:append(fcj_kannanBUFF) end

--32 界庞德公
fcj_pangdegong = sgs.General(extension_J, "fcj_pangdegong", "qun", 3, true)

fcj_pingcaiCard = sgs.CreateSkillCard{
	name = "fcj_pingcaiCard",
	skill_name = "fcj_pingcai",
	target_fixed = true,
	mute = true, --关闭技能卡牌声音，防止乱报语音
	on_use = function(self, room, source, targets)
		room:getThread():delay(4500) --等开始评价语音说完
		local choice = room:askForChoice(source, "@fcj_pingcai-ChooseTreasure", "wolong+fengchu+shuijing+xuanjian")
		--卧龙
		if choice == "wolong" then
			local log = sgs.LogMessage()
			log.type = "$fcj_pingcai-ChooseTreasure_wolong"
			log.from = source
			room:sendLog(log)
			if not room:askForUseCard(source, "@@fcj_pingcaiWolong", "@fcj_pingcaiWolong-card") then return false end
			local wl = 0
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if isSpecialOne(p, "卧龙诸葛亮") then
					local log = sgs.LogMessage()
					log.type = "$fcj_pingcaiWolong"
					log.from = source
					log.to:append(p)
					room:sendLog(log)
					wl = wl + 1
					break
				end
			end
			if wl > 0 then
				room:askForUseCard(source, "@@fcj_pingcaiWolong", "@fcj_pingcaiWolong-card")
			end
		--凤雏
		elseif choice == "fengchu" then
			local log = sgs.LogMessage()
			log.type = "$fcj_pingcai-ChooseTreasure_fengchu"
			log.from = source
			room:sendLog(log)
			if not room:askForUseCard(source, "@@fcj_pingcaiFengchu", "@fcj_pingcaiFengchu-card") then return false end
			local fcu = 0
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if isSpecialOne(p, "庞统") then
					local log = sgs.LogMessage()
					log.type = "$fcj_pingcaiFengchu"
					log.from = source
					log.to:append(p)
					room:sendLog(log)
					fcu = fcu + 1
					break
				end
			end
			if fcu > 0 then
				room:askForUseCard(source, "@@fcj_pingcaiFengchu", "@fcj_pingcaiFengchu-card")
			end
		--水镜
		elseif choice == "shuijing" then
			local log = sgs.LogMessage()
			log.type = "$fcj_pingcai-ChooseTreasure_shuijing"
			log.from = source
			room:sendLog(log)
			if not room:askForUseCard(source, "@@fcj_pingcaiShuijing", "@fcj_pingcaiShuijing-card") then return false end
			local sj = 0
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if isSpecialOne(p, "司马徽") then
					local log = sgs.LogMessage()
					log.type = "$fcj_pingcaiFengchu"
					log.from = source
					log.to:append(p)
					room:sendLog(log)
					sj = sj + 1
					break
				end
			end
			if sj > 0 then
				room:askForUseCard(source, "@@fcj_pingcaiShuijing", "@fcj_pingcaiShuijing-card")
			end
		--玄剑
		elseif choice == "xuanjian" then
			local log = sgs.LogMessage()
			log.type = "$fcj_pingcai-ChooseTreasure_xuanjian"
			log.from = source
			room:sendLog(log)
			if not room:askForUseCard(source, "@@fcj_pingcaiXuanjian", "@fcj_pingcaiXuanjian-card") and source:getState() == "online" then return false
			elseif source:getState() == "robot" then --AI用
				local beneficiary = room:askForPlayerChosen(source, room:getAllPlayers(), "fcj_pingcaiXuanjian")
				room:addPlayerMark(source, "fcj_pingcaiRXJ") --播放语音用
				room:removePlayerMark(source, "fcj_pingcaiRXJ")
				room:drawCards(beneficiary, 1, "fcj_pingcaiXuanjian")
				room:recover(beneficiary, sgs.RecoverStruct(source))
				room:drawCards(source, 1, "fcj_pingcaiXuanjian")
			end
			local xj = 0
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if isSpecialOne(p, "徐庶") then
					local log = sgs.LogMessage()
					log.type = "$fcj_pingcaiFengchu"
					log.from = source
					log.to:append(p)
					room:sendLog(log)
					xj = xj + 1
					break
				end
			end
			if xj > 0 then
				if source:getState() == "online" then room:askForUseCard(source, "@@fcj_pingcaiXuanjian", "@fcj_pingcaiXuanjian-card")
				elseif source:getState() == "robot" then --AI用
					local beneficiary = room:askForPlayerChosen(source, room:getAllPlayers(), "fcj_pingcaiXuanjian")
					room:addPlayerMark(source, "fcj_pingcaiRXJ") --播放语音用
					room:removePlayerMark(source, "fcj_pingcaiRXJ")
					room:drawCards(beneficiary, 1, "fcj_pingcaiXuanjian")
					room:recover(beneficiary, sgs.RecoverStruct(source))
					room:drawCards(source, 1, "fcj_pingcaiXuanjian")
				end
			end
		end
	end,
}
fcj_pingcai = sgs.CreateZeroCardViewAsSkill{
	name = "fcj_pingcai",
	view_as = function()
		return fcj_pingcaiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#fcj_pingcaiCard")
	end,
}
fcj_pingcaiIDO = sgs.CreateTriggerSkill{
    name = "fcj_pingcaiIDO",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.PreCardUsed, sgs.MarkChanged},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.PreCardUsed then
			local use = data:toCardUse()
			if use.from:objectName() == player:objectName() and use.card:getSkillName() == "fcj_pingcai" then
				room:broadcastSkillInvoke("fcj_pingcai", 1)
			end
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			if mark.name == "fcj_pingcaiRXJ" then
				room:broadcastSkillInvoke("fcj_pingcai", 4)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
fcj_pangdegong:addSkill(fcj_pingcai)
if not sgs.Sanguosha:getSkill("fcj_pingcaiIDO") then skills:append(fcj_pingcaiIDO) end
--“卧龙”：对至多两名角色各造成1点火焰伤害。（因缘人物：卧龙诸葛亮）
fcj_pingcaiWolongCard = sgs.CreateSkillCard{
	name = "fcj_pingcaiWolongCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets < 2
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		for _, p in pairs(targets) do
			room:damage(sgs.DamageStruct("fcj_pingcaiWolong", source, p, 1, sgs.DamageStruct_Fire))
			room:broadcastSkillInvoke("fcj_pingcai", 2)
		end
	end,
}
fcj_pingcaiWolong = sgs.CreateZeroCardViewAsSkill{
	name = "fcj_pingcaiWolong",
	view_as = function()
		return fcj_pingcaiWolongCard:clone()
	end,
	response_pattern = "@@fcj_pingcaiWolong",
}
if not sgs.Sanguosha:getSkill("fcj_pingcaiWolong") then skills:append(fcj_pingcaiWolong) end
--“凤雏”：让至多四名角色进入连环状态。（因缘人物：庞统）
fcj_pingcaiFengchuCard = sgs.CreateSkillCard{
	name = "fcj_pingcaiFengchuCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets < 4
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		for _, p in pairs(targets) do
			if not p:isChained() then room:setPlayerChained(p) end
			room:broadcastSkillInvoke("fcj_pingcai", 3)
		end
	end,
}
fcj_pingcaiFengchu = sgs.CreateZeroCardViewAsSkill{
	name = "fcj_pingcaiFengchu",
	view_as = function()
		return fcj_pingcaiFengchuCard:clone()
	end,
	response_pattern = "@@fcj_pingcaiFengchu",
}
if not sgs.Sanguosha:getSkill("fcj_pingcaiFengchu") then skills:append(fcj_pingcaiFengchu) end
--“水镜”：将一名角色装备区内的一张牌移动到另一名角色的相应位置。（因缘人物：司马徽）
fcj_pingcaiShuijingCard = sgs.CreateSkillCard{
	name = "fcj_pingcaiShuijingCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:getEquips():length() > 0
	end,
	on_use = function(self, room, source, targets)
		local card_id = room:askForCardChosen(source, targets[1], "e", "fcj_pingcaiShuijing")
		local card = sgs.Sanguosha:getCard(card_id)
		local place = room:getCardPlace(card_id)
		local equip_index = -1
		if place == sgs.Player_PlaceEquip then
			local equip = card:getRealCard():toEquipCard()
			equip_index = equip:location()
		end
		local tos = sgs.SPlayerList()
		local list = room:getAlivePlayers()
		for _, p in sgs.qlist(list) do
			if equip_index ~= -1 then
				if not p:getEquip(equip_index) then
					tos:append(p)
				end
			else
				if not source:isProhibited(p, card) and not p:containsTrick(card:objectName()) then
					tos:append(p)
				end
			end
		end
		local tag = sgs.QVariant()
		tag:setValue(targets[1])
		room:setTag("fcj_pingcaiShuijingEquipTarget", tag)
		local to = room:askForPlayerChosen(source, tos, "fcj_pingcaiShuijing", "@fcj_pingcaiShuijing_Equip-to:" .. card:objectName())
		if to then
			room:moveCardTo(card, targets[1], to, place, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, source:objectName(), "fcj_pingcaiShuijing", ""))
			room:broadcastSkillInvoke("fcj_pingcai", 4)
		end
		room:removeTag("fcj_pingcaiShuijingEquipTarget")
		room:setPlayerFlag(source, "fcj_pingcaiShuijingMove_do")
	end,
}
fcj_pingcaiShuijing = sgs.CreateZeroCardViewAsSkill{
	name = "fcj_pingcaiShuijing",
	view_as = function()
		return fcj_pingcaiShuijingCard:clone()
	end,
	response_pattern = "@@fcj_pingcaiShuijing",
}
if not sgs.Sanguosha:getSkill("fcj_pingcaiShuijing") then skills:append(fcj_pingcaiShuijing) end
--“玄剑”：令一名角色摸一张牌并回复1点体力，然后你摸一张牌。（因缘人物：徐庶）
fcj_pingcaiXuanjianCard = sgs.CreateSkillCard{
	name = "fcj_pingcaiXuanjianCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("fcj_pingcai", 5)
		room:drawCards(targets[1], 1, "fcj_pingcaiXuanjian")
		room:recover(targets[1], sgs.RecoverStruct(source))
		room:broadcastSkillInvoke("fcj_pingcai", 5)
		room:drawCards(source, 1, "fcj_pingcaiXuanjian")
	end,
}
fcj_pingcaiXuanjian = sgs.CreateZeroCardViewAsSkill{
	name = "fcj_pingcaiXuanjian",
	view_as = function()
		return fcj_pingcaiXuanjianCard:clone()
	end,
	response_pattern = "@@fcj_pingcaiXuanjian",
}
if not sgs.Sanguosha:getSkill("fcj_pingcaiXuanjian") then skills:append(fcj_pingcaiXuanjian) end
----

fcj_pangdegong:addSkill("yinshiy")

--33 界陈到
fcj_chendao = sgs.General(extension_J, "fcj_chendao", "shu", 4, true)

fcj_wanglie = sgs.CreateTriggerSkill{
	name = "fcj_wanglie",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed, sgs.TargetSpecified, sgs.ConfirmDamage, sgs.CardFinished, sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.CardUsed then
			if use.from:objectName() == player:objectName() and use.card and not use.card:isKindOf("SkillCard") and player:getPhase() == sgs.Player_Play then
				if player:getMark("fcj_wanglieFQC") < 2 then
					room:addPlayerMark(player, "fcj_wanglieFQC")
				end
				if player:getMark("fcj_wanglieFQC") == 1 then --第一张牌：不计入次数
					room:broadcastSkillInvoke(self:objectName())
					if use.card:isKindOf("Analeptic") then
						room:setPlayerFlag(player, "fcj_wanglie_AnaRmvHsty") --处理不计使用次数代码对【酒】不生效的问题
					elseif not use.card:isKindOf("Analeptic") and use.m_addHistory then
						room:addPlayerHistory(player, use.card:getClassName(), -1)
					end
				end
				if player:getMark("fcj_wanglieFQC") > 1 and use.card:isKindOf("Analeptic") and player:hasFlag("fcj_wanglie_AnaRmvHsty") then
					room:setPlayerFlag(player, "-fcj_wanglie_AnaRmvHsty")
				end
				if player:hasFlag("fcj_wanglie_cantchooseHit") and player:hasFlag("fcj_wanglie_cantchooseDamage")
				and player:hasFlag("fcj_wanglie_cantchooseBeishui") then return false end
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:broadcastSkillInvoke(self:objectName())
					local choices = {}
					if not player:hasFlag("fcj_wanglie_cantchooseHit") then
						table.insert(choices, "Hit")
					end
					if not player:hasFlag("fcj_wanglie_cantchooseDamage") then
						table.insert(choices, "Damage")
					end
					if not player:hasFlag("fcj_wanglie_cantchooseBeishui") then
						table.insert(choices, "Beishui")
					end
					table.insert(choices, "cancel")
					local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
					if choice == "Hit" then
						room:setCardFlag(use.card, "fcj_wanglieHit")
						room:setPlayerFlag(player, "fcj_wanglie_cantchooseHit")
					elseif choice == "Damage" then
						room:setCardFlag(use.card, "fcj_wanglieDamage")
						room:setPlayerFlag(player, "fcj_wanglie_cantchooseDamage")
					elseif choice == "Beishui" then
						room:setCardFlag(use.card, "fcj_wanglieHit")
						room:setCardFlag(use.card, "fcj_wanglieDamage")
						room:broadcastSkillInvoke(self:objectName())
						room:setPlayerCardLimitation(player, "use,response", ".|.|.|hand", false)
						room:setPlayerFlag(player, "fcj_wanglie_cantchooseBeishui")
					end
				end
			end
		
		elseif event == sgs.TargetSpecified then --不能被响应
			if use.card:hasFlag("fcj_wanglieHit") then
				room:setCardFlag(use.card, "-fcj_wanglieHit")
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local no_respond_list = use.no_respond_list
				for _, p in sgs.qlist(use.to) do
					table.insert(no_respond_list, p:objectName())
				end
				use.no_respond_list = no_respond_list
				data:setValue(use)
			end
		elseif event == sgs.ConfirmDamage then --伤害+1
			local damage = data:toDamage()
			if damage.card:hasFlag("fcj_wanglieDamage") then
				room:setCardFlag(damage.card, "-fcj_wanglieDamage")
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		elseif event == sgs.CardFinished then
			if use.card:hasFlag("fcj_wanglieHit") then room:setCardFlag(use.card, "-fcj_wanglieHit") end
			if use.card:hasFlag("fcj_wanglieDamage") then room:setCardFlag(use.card, "-fcj_wanglieDamage") end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Play then
				room:setPlayerMark(player, "fcj_wanglieFQC", 0)
				if player:hasFlag("fcj_wanglie_AnaRmvHsty") then room:setPlayerFlag(player, "-fcj_wanglie_AnaRmvHsty") end
				if player:hasFlag("fcj_wanglie_cantchooseHit") then room:setPlayerFlag(player, "-fcj_wanglie_cantchooseHit") end
				if player:hasFlag("fcj_wanglie_cantchooseDamage") then room:setPlayerFlag(player, "-fcj_wanglie_cantchooseDamage") end
				if player:hasFlag("fcj_wanglie_cantchooseBeishui") then
					room:removePlayerCardLimitation(player, "use,response", ".|.|.|hand")
					room:setPlayerFlag(player, "-fcj_wanglie_cantchooseBeishui")
				end
			end
		end
	end,
}
fcj_wanglieSecondCard = sgs.CreateTargetModSkill{ --第二张牌：无距离限制
	name = "fcj_wanglieSecondCard",
	distance_limit_func = function(self, from, card)
		if from:hasSkill("fcj_wanglie") and from:getPhase() == sgs.Player_Play and from:getMark("fcj_wanglieFQC") == 1
		and card and not card:isKindOf("SkillCard") then
			return 1000
		else
			return 0
		end
	end,
}
fcj_wanglieAnaleptic = sgs.CreateTargetModSkill{ --第一张牌为【酒】不计入次数，可以再(无次数限制地)使用一张【酒】
	name = "fcj_wanglieAnaleptic",
	pattern = "Analeptic",
	residue_func = function(self, player)
		if player:hasSkill("fcj_wanglie") and player:hasFlag("fcj_wanglie_AnaRmvHsty") then
			return 1000
		else
			return 0
		end
	end,
}
fcj_chendao:addSkill(fcj_wanglie)
if not sgs.Sanguosha:getSkill("fcj_wanglieSecondCard") then skills:append(fcj_wanglieSecondCard) end
if not sgs.Sanguosha:getSkill("fcj_wanglieAnaleptic") then skills:append(fcj_wanglieAnaleptic) end

--34 界赵统赵广
fcj_zhaotongzhaoguang = sgs.General(extension_J, "fcj_zhaotongzhaoguang", "shu", 4, true)

fcj_zhaotongzhaoguang:addSkill("yizan")
fcj_zhaotongzhaoguang:addSkill("longyuan")

fcj_yunxing = sgs.CreateTriggerSkill{
	name = "fcj_yunxing",
	frequency = sgs.Skill_Frequent,
	events = {sgs.GameStart, sgs.CardUsed, sgs.CardResponded, sgs.EventPhaseStart, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			local fcj_yunxing_cards = {}
			local fcj_yunxing_one_basic_count = 0
			for _, id in sgs.qlist(room:getDrawPile()) do
				if sgs.Sanguosha:getCard(id):isKindOf("BasicCard") and not table.contains(fcj_yunxing_cards, id) and fcj_yunxing_one_basic_count < 1 then
					fcj_yunxing_one_basic_count = fcj_yunxing_one_basic_count + 1
					table.insert(fcj_yunxing_cards, id)
				end
			end
			local fcj_yunxing_one_weapon_count = 0
			for _, id in sgs.qlist(room:getDrawPile()) do
				if sgs.Sanguosha:getCard(id):isKindOf("Weapon") and not table.contains(fcj_yunxing_cards, id) and fcj_yunxing_one_weapon_count < 1 then
					fcj_yunxing_one_weapon_count = fcj_yunxing_one_weapon_count + 1
					table.insert(fcj_yunxing_cards, id)
				end
			end
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, id in ipairs(fcj_yunxing_cards) do
				dummy:addSubcard(id)
			end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			room:obtainCard(player, dummy, false)
		elseif event == sgs.CardUsed or event == sgs.CardResponded then
			local card
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				card = response.m_card
			end
			if card and card:getSkillName() == "yizan" then
				room:addPlayerMark(player, "&fcj_yunxing")
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_RoundStart then return false end
			local n = player:getMark("&fcj_yunxing")
			if n <= 0 then return false end
			local fcj_yunxing_cards = {}
			local fcj_yunxing_basic_count = 0
			for _, id in sgs.qlist(room:getDrawPile()) do
				if sgs.Sanguosha:getCard(id):isKindOf("BasicCard") and not table.contains(fcj_yunxing_cards, id) and fcj_yunxing_basic_count < n then
					fcj_yunxing_basic_count = fcj_yunxing_basic_count + 1
					table.insert(fcj_yunxing_cards, id)
				end
			end
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, id in ipairs(fcj_yunxing_cards) do
				dummy:addSubcard(id)
			end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			room:obtainCard(player, dummy, false)
			room:setPlayerMark(player, "&fcj_yunxing", 0)
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			local n = player:getMark("&fcj_yunxing")
			if n <= 0 then return false end
			local fcj_yunxing_cards = {}
			local fcj_yunxing_basic_count = 0
			for _, id in sgs.qlist(room:getDrawPile()) do
				if sgs.Sanguosha:getCard(id):isKindOf("BasicCard") and not table.contains(fcj_yunxing_cards, id) and fcj_yunxing_basic_count < n then
					fcj_yunxing_basic_count = fcj_yunxing_basic_count + 1
					table.insert(fcj_yunxing_cards, id)
				end
			end
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, id in ipairs(fcj_yunxing_cards) do
				dummy:addSubcard(id)
			end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			room:obtainCard(player, dummy, false)
			room:setPlayerMark(player, "&fcj_yunxing", 0)
		end
	end,
}
fcj_zhaotongzhaoguang:addSkill(fcj_yunxing)





--

--35 界于禁-旧
fcj_yujin_old = sgs.General(extension_J, "fcj_yujin_old", "wei", 4, true)

local function fcjyzCandiscard(player)
	if player:isDead() then return false end
	local can_dis = false
	for _, c in sgs.qlist(player:getHandcards()) do
		if c:isBlack() and player:canDiscard(player, c:getEffectiveId()) then
			can_dis = true
			break
		end
	end
	return can_dis
end
fcj_yizhong = sgs.CreateTriggerSkill{
	name = "fcj_yizhong",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.SlashEffected, sgs.TargetSpecified, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.SlashEffected then
			local effect = data:toSlashEffect()
			if effect.slash:isBlack() then
				room:notifySkillInvoked(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				return true
			end
		elseif event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") and use.card:isBlack() and use.from:objectName() == player:objectName() then
				local no_respond_list = use.no_respond_list
				for _, p in sgs.qlist(use.to) do
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					table.insert(no_respond_list, p:objectName())
				end
				use.no_respond_list = no_respond_list
				data:setValue(use)
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_Finish or not fcjyzCandiscard(player) then return false end
			if not room:askForSkillInvoke(player, self:objectName(), data) then return false end
			local card = room:askForCard(player, ".|black", "@fcj_yizhong-invoke", data, sgs.Card_MethodDiscard)
			if card then
				local other = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "@fcj_yizhong-choose")
				room:broadcastSkillInvoke(self:objectName())
				if not other:hasSkill(self:objectName()) then
					room:addPlayerMark(other, self:objectName())
					room:acquireSkill(other, self:objectName())
				end
			end
		end
	end,
}
fcj_yizhongLS = sgs.CreateTriggerSkill{
	name = "fcj_yizhongLS",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then return false end
		room:detachSkillFromPlayer(player, "fcj_yizhong", false, true)
		room:setPlayerMark(player, "fcj_yizhong", 0)
	end,
	can_trigger = function(self, player)
		return player:hasSkill("fcj_yizhong") and player:getMark("fcj_yizhong") > 0
	end,
}
fcj_yujin_old:addSkill(fcj_yizhong)
if not sgs.Sanguosha:getSkill("fcj_yizhongLS") then skills:append(fcj_yizhongLS) end






--

--36 界曹昂
fcj_caoang = sgs.General(extension_J, "fcj_caoang", "wei", 4, true)

fcj_kangkai = sgs.CreateTriggerSkill{
	name = "fcj_kangkai",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirmed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isDamageCard() then
			local n = 0
			if use.card:isKindOf("Slash") then n = 1 end
			for _, to in sgs.qlist(use.to) do
				if not player:isAlive() then break end
				if player:distanceTo(to) <= n+1 and player:hasSkill(self:objectName()) then
					player:setTag("fcj_kangkaiSlash", data)
					local to_data = sgs.QVariant()
					to_data:setValue(to)
					local will_use = room:askForSkillInvoke(player, self:objectName(), to_data)
					player:removeTag("fcj_kangkaiSlash")
					if will_use then
						room:broadcastSkillInvoke(self:objectName())
						player:drawCards(1, self:objectName())
						if not player:isNude() --[[and player:objectName() ~= to:objectName()]] then
							local card = nil
							if player:getCardCount() > 1 then
								card = room:askForCard(player, "..!", "@fcj_kangkai-give:" .. to:objectName(), data, sgs.Card_MethodNone);
								if not card then
									card = player:getCards("he"):at(math.random(player:getCardCount()))
								end
							else
								card = player:getCards("he"):first()
							end
							to:obtainCard(card)
							if to:objectName() == player:objectName() then room:showCard(to, card:getEffectiveId()) end
							if card:isKindOf("BasicCard") or card:isKindOf("Nullification") then
								if room:askForSkillInvoke(player, "fcj_kangkai_hedraw", data) then
									to:drawCards(1, self:objectName())
								end
							elseif not card:isKindOf("BasicCard") and not card:isKindOf("Nullification")
							and room:getCardOwner(card:getEffectiveId()):objectName() == to:objectName() and not to:isLocked(card) then
								local xdata = sgs.QVariant()
								xdata:setValue(card)
								to:setTag("fcj_kangkaiSlash", data)
								to:setTag("fcj_kangkaiGivenCard", xdata)
								local will_use = room:askForSkillInvoke(to, "fcj_kangkai_use", sgs.QVariant("use"))
								to:removeTag("fcj_kangkaiSlash")
								to:removeTag("fcj_kangkaiGivenCard")
								if will_use then
									if to:getState() == "robot" and card:isKindOf("EquipCard") then
										room:useCard(sgs.CardUseStruct(card, to, to))
									else
										--[[local pattern = "|.|.|.|."
										for _, p in sgs.qlist(room:getOtherPlayers(to)) do
											if not sgs.Sanguosha:isProhibited(to, p, card) then
												pattern = card:getClassName()..pattern
												break
											end
										end
										if pattern ~= "|.|.|.|." then
											room:askForUseCard(to, pattern, "@fcj_kangkai_ut:"..card:objectName(), -1)
										end]]
										local pattern = {}
										for _, p in sgs.qlist(room:getOtherPlayers(to)) do
											if not sgs.Sanguosha:isProhibited(to, p, card)
											and card:isAvailable(to)then
												table.insert(pattern, card:getEffectiveId())
											end
										end
										if #pattern > 0 then
											room:askForUseCard(to, table.concat(pattern, ","), "@fcj_kangkai_ut:"..card:objectName(), -1)
										end
									end
								end							
							end
						end
					end
				end
			end
		end
	end,
}
fcj_caoang:addSkill(fcj_kangkai)




--

--37 界吕岱
fcj_lvdai = sgs.General(extension_J, "fcj_lvdai", "wu", 4, true)

fcj_qinguoCard = sgs.CreateSkillCard{
	name = "fcj_qinguoCard",
	filter = function(self, targets, to_select)
		local targets_list = sgs.PlayerList()
		for _, target in ipairs(targets) do
			targets_list:append(target)
		end
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("fcj_qinguo")
		slash:deleteLater()
		return slash:targetFilter(targets_list, to_select, sgs.Self)
	end,
	on_use = function(self, room, source, targets)
		local targets_list = sgs.SPlayerList()
		for _, target in ipairs(targets) do
			if source:canSlash(target, nil, false) then
				targets_list:append(target)
			end
		end
		if not targets_list:isEmpty() then
			room:broadcastSkillInvoke("fcj_qinguo")
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			slash:setSkillName("fcj_qinguo")
			room:useCard(sgs.CardUseStruct(slash, source, targets_list), false)
		end
	end,
}
fcj_qinguoVS = sgs.CreateZeroCardViewAsSkill{
	name = "fcj_qinguo",
	view_as = function()
		return fcj_qinguoCard:clone()
	end,
	enabled_at_play = function()
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@fcj_qinguo"
	end,
}
fcj_qinguo = sgs.CreateTriggerSkill{
	name = "fcj_qinguo",
	frequency = sgs.Skill_Frequent,
	events = {sgs.BeforeCardsMove, sgs.CardsMoveOneTime, sgs.CardFinished},
	view_as_skill = fcj_qinguoVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.BeforeCardsMove then
			local move = data:toMoveOneTime()
			room:setPlayerMark(player, self:objectName(), player:getEquips():length())
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if (move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceEquip)
			or (move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceEquip)) then 
				local n = 0
				if player:getHp() == player:getEquips():length() then n = n + 1 end
				if player:getEquips():length() ~= player:getMark(self:objectName()) then n = n + 1 end
				if n > 0 then
					while n > 0 do
						room:broadcastSkillInvoke(self:objectName())
						if player:isWounded() then
							room:recover(player, sgs.RecoverStruct(player))
						end
						room:drawCards(player, 1, self:objectName())
						n = n - 1
					end
				end
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.card:isKindOf("EquipCard") then
				room:askForUseCard(player, "@@fcj_qinguo", "@fcj_qinguo-slash")
			end
		end
	end,
}
fcj_lvdai:addSkill(fcj_qinguo)

--38 界陆抗
fcj_lukang = sgs.General(extension_J, "fcj_lukang", "wu", 4, true)

fcj_lukang:addSkill("qianjie")

function fcjjyThrowEquipArea(self, player, cancel, hourse)
	local choices = {}
	for i = 0, 4 do
		if player:hasEquipArea(i) and (horse or (i ~= 3 and i ~= 2)) then
			table.insert(choices, "fcj_jueyan"..i)
		end
	end
	if not horse and (player:hasEquipArea(2) or player:hasEquipArea(3)) then
		table.insert(choices, "fcj_jueyan"..2)
	end
	--if cancel then
		table.insert(choices, "cancel")
	--end
	local choice = player:getRoom():askForChoice(player, self:objectName(), table.concat(choices, "+"))
	if choice ~= "cancel" then
		--lazy(self, player:getRoom(), player, choice, true)
		local x = tonumber(string.sub(choice, string.len(choice), string.len(choice)))
		player:throwEquipArea(x)
		if x == 2 and not horse then
			player:throwEquipArea(3)
		end
		return x
	end
	return -1
end
fcj_jueyanCard = sgs.CreateSkillCard{
	name = "fcj_jueyan",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local x = fcjjyThrowEquipArea(self, source)
		room:addPlayerMark(source, "fcj_jueyan"..x.."-Clear")
		if x == 1 then
			source:drawCards(3, self:objectName()) --废除防具栏：摸三张牌
		end
		local log = sgs.LogMessage()
		if x == 0 then log.type = "$fcj_jueyan-0"
		elseif x == 1 then log.type = "$fcj_jueyan-1"
		elseif x == 2 then log.type = "$fcj_jueyan-2"
		elseif x == 4 then log.type = "$fcj_jueyan-4"
		end
		log.from = source
		room:sendLog(log)
	end,
}
fcj_jueyanVS = sgs.CreateZeroCardViewAsSkill{
	name = "fcj_jueyan",
	view_as = function()
		return fcj_jueyanCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:hasEquipArea()
	end,
}
fcj_jueyan = sgs.CreateTriggerSkill{
	name = "fcj_jueyan",
	global = true,
	--frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.EventPhaseChanging},
	view_as_skill = fcj_jueyanVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then --废除宝物栏：本回合视为拥有“界集智”
			local use = data:toCardUse()
			local jizhi = sgs.Sanguosha:getTriggerSkill("tenyearjizhi")
			if jizhi and use.card and player:getMark("fcj_jueyan4-Clear") > 0 then
				jizhi:trigger(event, room, player, data)
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			room:setPlayerMark(player, "fcj_jueyan0-Clear", 0)
			room:setPlayerMark(player, "fcj_jueyan1-Clear", 0)
			room:setPlayerMark(player, "fcj_jueyan2-Clear", 0)
			room:setPlayerMark(player, "fcj_jueyan4-Clear", 0)
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
fcj_jueyanWeapon = sgs.CreateTargetModSkill{ --废除武器栏：本回合杀次数+3
	name = "fcj_jueyanWeapon",
	residue_func = function(self, player)
		if player:getMark("fcj_jueyan0-Clear") > 0 then
			return 3
		else
			return 0
		end
	end
}
fcj_jueyanArmor = sgs.CreateMaxCardsSkill{ --废除防具栏：本回合手牌上限+3
	name = "fcj_jueyanArmor",
	extra_func = function(self, player)
		if player:getMark("fcj_jueyan1-Clear") > 0 then
			return 3
		else
			return 0
		end
	end,
}
fcj_jueyanHorse = sgs.CreateTargetModSkill{ --废除坐骑栏：使用牌无距离限制
	name = "fcj_jueyanHorse",
	pattern = "Card",
	distance_limit_func = function(self, player, card)
		if player:getMark("fcj_jueyan2-Clear") > 0 and not card:isKindOf("SkillCard") then
			return 1000
		else
			return 0
		end
	end,
}
fcj_lukang:addSkill(fcj_jueyan)
if not sgs.Sanguosha:getSkill("fcj_jueyanWeapon") then skills:append(fcj_jueyanWeapon) end
if not sgs.Sanguosha:getSkill("fcj_jueyanArmor") then skills:append(fcj_jueyanArmor) end
if not sgs.Sanguosha:getSkill("fcj_jueyanHorse") then skills:append(fcj_jueyanHorse) end

fcj_poshi = sgs.CreateTriggerSkill{
    name = "fcj_poshi",
	frequency = sgs.Skill_Wake,
	events = {sgs.EventPhaseStart},
	waked_skills = "ps_huairou",
	can_wake = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:hasEquipArea() and player:getHp() ~= 1 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		room:doSuperLightbox("fcj_lukang", self:objectName())
		room:addPlayerMark(player, self:objectName())
		if room:changeMaxHpForAwakenSkill(player) then
			local n = player:getMaxHp() - player:getHandcardNum()
			for i = 0, 4 do
				if player:hasEquipArea(i) then
					n = n + 1
				end
			end
			if n > 0 then
				room:drawCards(player, n, self:objectName())
			end
			if player:hasSkill("fcj_jueyan") then
				room:detachSkillFromPlayer(player, "fcj_jueyan")
			end
			if not player:hasSkill("ps_huairou") then
				room:acquireSkill(player, "ps_huairou")
			end
		end
	end,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
fcj_lukang:addSkill(fcj_poshi)
fcj_lukang:addRelateSkill("ps_huairou")
--“怀柔”
ps_huairouCard = sgs.CreateSkillCard{
	name = "ps_huairou",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		room:moveCardTo(self, source, nil, sgs.Player_DiscardPile, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECAST, source:objectName(), self:objectName(), ""))
		room:broadcastSkillInvoke("@recast")
		local log = sgs.LogMessage()
		log.type = "#UseCard_Recast"
		log.from = source
		log.card_str = tostring(self:getSubcards():first())
		room:sendLog(log)
		room:drawCards(source, 1, "recast")
		room:addPlayerMark(source, "&ps_huairou", 1)
	end,
}
ps_huairou = sgs.CreateOneCardViewAsSkill{
	name = "ps_huairou",
	filter_pattern = "EquipCard",
	view_as = function(self, card)
		local skill_card = ps_huairouCard:clone()
		skill_card:addSubcard(card)
		skill_card:setSkillName(self:objectName())
		return skill_card
	end,
}
ps_huairou_qicai = sgs.CreateTargetModSkill{
	name = "ps_huairou_qicai",
	pattern = "Slash",
	distance_limit_func = function(self, from)
		local n = from:getMark("&ps_huairou")
		if n > 0 then
			return n
		else
			return 0
		end
	end,
}
ps_huairouEnd = sgs.CreateTriggerSkill{
	name = "ps_huairouEnd",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:setPlayerMark(player, "&ps_huairou", 0)
	end,
	can_trigger = function(self, player)
		return player:getMark("&ps_huairou") > 0
	end,
}
if not sgs.Sanguosha:getSkill("ps_huairou") then skills:append(ps_huairou) end
if not sgs.Sanguosha:getSkill("ps_huairou_qicai") then skills:append(ps_huairou_qicai) end
if not sgs.Sanguosha:getSkill("ps_huairouEnd") then skills:append(ps_huairouEnd) end

--

--39 界麹义

--40 界司马徽

--41 界马良

--42 界马忠

--

sgs.Sanguosha:addSkills(skills)
sgs.LoadTranslationTable{
    ["fcDIY"] = "FC·DIY扩展包",
	["fcDIY_twelveGod"] = "FC·DIY十二神将",
	["fcDIY_jxtp"] = "FC·DIY界限突破",
	
	--神貂蝉-自改版
	["shendiaochan_change"] = "神貂蝉-自改版",
	["#shendiaochan_change"] = "欲界非天",
	["designer:shendiaochan_change"] = "面杀",
	["cv:shendiaochan_change"] = "英雄杀",
	["&shendiaochan_change"] = "神貂蝉",
	["f_meihun"] = "魅魂",
	[":f_meihun"] = "结束阶段开始时或当你成为【杀】的目标后，你可以令一名其他角色交给你一张你声明的花色的牌，若其没有或拒绝则你观看其手牌然后弃置其中一张，且你进行判定：若判定结果为红色，你令其获得1枚“魅惑”标记。",
	["@f_meihun-suit"] = "请交给其一张与其声明花色相同的牌",
	["$f_meihun1"] = "膜拜吧~", --结束阶段
	["$f_meihun2"] = "哼，不怕你！", --成为【杀】的目标
	["f_huoxin"] = "惑心", --由操控回合改为夺取回合
	["f_huoxinGPC"] = "惑心",
	["f_huoxingpc"] = "惑心",
	["f_huoxinPindian"] = "惑心",
	["f_huoxinGetTurn"] = "惑心",
	["f_huoxinEndTurn"] = "惑心",
	[":f_huoxin"] = "出牌阶段限一次，你可以将两张花色相同的手牌展示并分别交给两名其他角色，然后令这两名角色拼点，没赢的角色获得1枚“魅惑”标记（你先选择交给牌的角色会成为发起拼点的对象；若拼点点数相等，则二者都算没赢）。\
	拥有2枚或更多“魅惑”标记的角色回合开始前，你可以将所有手牌扣置于武将牌上并获得其所有手牌，取消其回合，改为由你进行一个新回合，并移除其所有“魅惑”标记。此回合结束时，你将所有手牌返还给其，再获得通过此技能扣置于你武将牌上的所有牌。",
	["f_meihuo"] = "魅惑",
	["f_huoxinPindianCard"] = "惑心拼点",
	["@f_huoxinGPC-card1"] = "请选择其中一名角色，交给其一张牌",
	["@f_huoxinGPC-card2"] = "请选择另一名角色，交给其一张牌",
	["~f_huoxinGPC"] = "你先选择交给牌的角色会成为发起拼点的对象",
	["f_huoxin_GetTurn"] = "惑心额外回合",
	["f_huoxin_skip"] = "",
	["$f_huoxin"] = "嗯呵呵~~呵呵~~", --一名角色获得“魅惑”标记
	["f_huooxin"] = "", --惑心配音
	["$f_huooxin1"] = "谁，更勇猛呢？", --拼点
	["$f_huooxin2"] = "我，漂亮吗？", --夺取回合
	["~shendiaochan_change"] = "奉先，妾身随你而去......",
	
	--神张角
	["f_shenzhangjiao"] = "神张角",
	["#f_shenzhangjiao"] = "乱世之始",
	["designer:f_shenzhangjiao"] = "时光流逝FC",
	["cv:f_shenzhangjiao"] = "Benoitm,官方,网络",
	["illustrator:f_shenzhangjiao"] = "LiuHeng",
	["f_taiping"] = "太平",
	[":f_taiping"] = "准备阶段开始时，你可以选择一项：横置一名角色，或复原一名角色的武将牌。",
	["tpChain"] = "横置该角色",
	["tpRestore"] = "复原该角色的武将牌",
	["$f_taiping1"] = "太平天数，一统天下！", --横置
	["$f_taiping2"] = "黄天在上，福佑万民！", --复原
	["f_yaoshu"] = "妖术",
	[":f_yaoshu"] = "限定技，出牌阶段，你令至多三名其他角色翻面并失去1点体力。若如此做，出牌阶段结束时，你失去1点体力。",
	["@f_yaoshu"] = "妖术",
	["f_yaoshuAnimate"] = "image=image/animate/f_yaoshu.png",
	["$f_yaoshu"] = "鬼道大开，峰回路转！",
	["f_luolei"] = "落雷",
	[":f_luolei"] = "限定技，出牌阶段，你横置一名角色并对其造成2点雷电伤害，再对与其距离为1的所有角色各造成1点雷电伤害。若如此做，出牌阶段结束时，你减1点体力上限。",
	["@f_luolei"] = "落雷",
	["f_luoleiAnimate"] = "image=image/animate/f_luolei.png",
	["$f_luolei1"] = "（雷电声中）雷~公~助~我~！",
	["$f_luolei2"] = "（雷电声中）电闪雷鸣，改天换日！",
	["f_luoleiYD"] = "",
	["$f_luoleiYD"] = "（爆炸的电流声）",
	["SZJLimitSkillSideEffect"] = "",
	["~f_shenzhangjiao"] = "逆天而行，必遭天谴呐！...",
	
	--神张飞
	["f_shenzhangfei"] = "神张飞",
	["#f_shenzhangfei"] = "万人敌",
	["designer:f_shenzhangfei"] = "时光流逝FC",
	["cv:f_shenzhangfei"] = "官方,英雄杀",
	["illustrator:f_shenzhangfei"] = "鬼画府",
	["f_doushen"] = "斗神",
	["f_doushenBuff"] = "斗神",
	[":f_doushen"] = "限定技，出牌阶段，你令你于此回合使用牌无次数限制。",
	["@f_doushen"] = "斗神",
	["$f_doushen"] = "谁，还敢过来一战？！",
	["f_jiuwei"] = "酒威",
	["f_jiuwei_getBuff"] = "酒威",
	["f_jiuwei_DistanceBuff"] = "酒威",
	["f_jiuwei_DamageBuff"] = "酒威",
	["f_jiuwei_throwBuff"] = "酒威",
	["f_jiuwei_removeflag"] = "",
	[":f_jiuwei"] = "你可以将你的任意一张牌当作【酒】使用；锁定技，你的有【酒】加成的【杀】无距离限制且：命中，伤害+1；未命中，你弃置目标的一张牌。",
	["$f_jiuwei1"] = "燕人张飞在此！", --喝酒
	["$f_jiuwei2"] = "今，必斩汝（于）马下！", --酒杀命中
	["$f_jiuwei_Damage"] = "%from 酒杀命中，此【<font color='yellow'><b>杀</b></font>】伤害+1",
	["$f_jiuwei3"] = "谁来与我大战三百回合？！", --酒杀未命中
	["$f_jiuwei_Miss"] = "%from 酒杀未命中，弃置目标的一张牌",
	["~f_shenzhangfei"] = "饮酒误事啊！",
	
	--神马超
	["f_shenmachao"] = "神马超",
	["#f_shenmachao"] = "神威天将军",
	["designer:f_shenmachao"] = "时光流逝FC",
	["cv:f_shenmachao"] = "官方",
	["illustrator:f_shenmachao"] = "Asker",
	["f_shenqi"] = "神骑",
	[":f_shenqi"] = "锁定技，你计算与其他角色的距离-2。",
	["f_shenlin"] = "神临",
	["f_shenlin_Clear"] = "神临",
	[":f_shenlin"] = "出牌阶段限一次，你可以弃置一张非基本牌并选择一名其他角色，则该角色的非锁定技和防具失效，直到回合结束。",
	["$f_shenlin"] = "目标敌阵，全军突击！",
	["f_shennu"] = "神怒",
	["f_shennu_youcantjink"] = "神怒",
	["f_shennu_slashmore"] = "神怒",
	["f_shennu_caozeijianzeiezeinizei"] = "神怒",
	["f_shennu_gexuqipao"] = "神怒",
	[":f_shennu"] = "出牌阶段限一次，你可以对自己造成1点伤害并摸一张牌，然后你获得以下效果直到回合结束：你的【杀】不可被【闪】响应且使用次数+1、你的红色【杀】伤害+1、你的【杀】的目标需弃置一张牌（只要有牌就必须执行），若无法做到则此【杀】伤害+1。",
	["@f_shennu_gexuqipao"] = "您必须弃置一张牌，若无牌可弃则此【杀】伤害+1",
	["$f_shennu"] = "敌人阵型已乱，随我杀！！",
	--["$f_shennu"] = "你可闪得过此一击！",
	["f_caohen"] = "曹恨",
	[":f_caohen"] = "<b>联动技，</b>锁定技，你对“曹操”或主公身份的魏势力角色造成伤害时，此伤害+1。",
	["$f_caohen"] = "灭族之恨，不共戴天！",
	["~f_shenmachao"] = "请将我，葬在西凉......",
	
	--神姜维
	["f_shenjiangwei"] = "神姜维",
	["#f_shenjiangwei"] = "麒麟儿",
	["designer:f_shenjiangwei"] = "时光流逝FC",
	["cv:f_shenjiangwei"] = "官方,Jr.Wakaran",
	["illustrator:f_shenjiangwei"] = "斗破苍穹",
	["f_beifa"] = "北伐！",
	["f_beifa_Clear"] = "北伐！",
	[":f_beifa"] = "出牌阶段限一次，你可以弃置一张牌并选择一名其他角色，则你获得“手杀界挑衅”，且该角色的非锁定技失效，直到回合结束。",
	["$f_beifa1"] = "克复中原，指日可待！",
	["$f_beifa2"] = "贼将早降，可免一死。",
	["f_fuzhi"] = "复志",
	["f_fuzhi_Trigger"] = "复志",
	[":f_fuzhi"] = "锁定技，你每造成、受到1点伤害或发动一次“北伐！”，获得1枚“兴”标记；觉醒技，准备阶段开始时或结束阶段开始时，若你的“兴”标记不少于3枚，你减1点体力上限，获得技能“OL界志继”、“智勇”、“谋兴”。",
	["Xing"] = "兴",
	["@WAKEDD"] = "大觉醒",
	["$f_fuzhi"] = "...今虽穷极，然先帝之志，丞相之托，维..岂敢忘！",
	  ["olzhiji_sjwUse"] = "志继",
	  [":olzhiji_sjwUse"] = "觉醒技，准备阶段/结束阶段开始时，若你没有手牌，你回复1点体力或摸两张牌，然后你减1点体力上限并获得技能“界观星”。",
	  ["recover"] = "回复",
	  ["olzhiji_sjwUse:recover"] = "回复1点体力",
	  ["olzhiji_sjwUse:draw"] = "摸两张牌",
	  ["fz_zhiyong"] = "智勇",
	  [":fz_zhiyong"] = "觉醒技，准备阶段开始时，若你体力值未满，你减1点体力上限，回复1点体力并摸一张牌，获得技能“界看破”、“OL界龙胆”。",
	  ["$fz_zhiyong"] = "继丞相之智慧，负子龙之忠胆！",
	  ["fz_mouxing"] = "谋兴",
	  ["mouxingDying"] = "谋兴",
	  [":fz_mouxing"] = "觉醒技，准备阶段开始时，若你于本局进入过濒死状态或“兴”标记不少于12枚，你减1点体力上限并摸三张牌，获得技能“兴汉”、“汉魂”。",
	  ["$fz_mouxing"] = "臣欲使社稷危而复安，日月幽而复明！",
		["mx_xinghan"] = "兴汉",
		["mx_xinghan_SkillClear"] = "兴汉",
		[":mx_xinghan"] = "出牌阶段，你可以移去1枚“兴”标记，获得以下技能其一直到下回合开始（各技能不可重复存在）：“界仁德”、“空城”、“界武圣”、“OL界咆哮”、“OL涯角”、“界烈弓”、“铁骑”。",
		["xinghan_skillget"] = "",
		["addskill_rende"] = "界仁德",
		["addskill_kongcheng"] = "空城",
		["addskill_wusheng"] = "界武圣",
		["addskill_paoxiao"] = "OL界咆哮",
		["addskill_yajiao"] = "OL涯角",
		["addskill_liegong"] = "界烈弓",
		["addskill_tieqi"] = "铁骑",
		["$mx_xinghan"] = "继丞相之遗志，讨篡汉之逆贼！",
		["mx_hanhun"] = "汉魂", --以此纪念大汉的最后一位大将姜维。姜维死，汉室亡。
		[":mx_hanhun"] = "限定技，出牌阶段，你弃置不同类别的手牌各一张并失去1点体力，选择一名非主公身份的存活角色，则该角色于之后死亡时获得以下效果：立即复活并回复至满体力，摸四张牌，势力变更为“蜀”，获得技能“魂散”。若如此做，除非你选择的角色为你自己，否则你立即死亡。",
		["$mx_hanhun"] = "只有如此了！愿以吾之魂魄，复兴季汉！",
		["@mx_hanhun"] = "汉魂",
		["@ZhanDouXuXing"] = "",
	    ["f_hanhunRevive"] = "汉魂重生",
	    ["$f_hanhunRevive"] = "", --复活音效
		  ["f_hunsan"] = "魂散",
		  [":f_hunsan"] = "锁定技，结束阶段结束时，你失去1点体力。",
	["~f_shenjiangwei"] = "愧丞相，今生无法完成夙愿；愿来生，大汉一统，大好河山再现......", --暂无语音
	
	--神邓艾
	["f_shendengai"] = "神邓艾",
	["#f_shendengai"] = "破蜀奇功",
	["designer:f_shendengai"] = "时光流逝FC",
	["cv:f_shendengai"] = "官方,阿澈",
	["illustrator:f_shendengai"] = "小肚皮",
	["f_zhiqu"] = "直取",
	["f_zhiquu"] = "直取",
	[":f_zhiqu"] = "锁定技，一名有“毡衫”标记的角色于其回合内：使用黑色牌无距离限制；每使用一张红色牌，摸一张牌。",
	["$f_zhiqu1"] = "偷渡阴平，直取蜀汉！", --使用黑色牌
	["$f_zhiqu2"] = "屯田日久，当建奇功！", --使用红色牌
	["f_zhanshan"] = "毡衫",
	["f_zhanshan_GMS"] = "毡衫",
	["f_zhanshan_Trigger"] = "毡衫",
	["f_zhanshanbuff"] = "毡衫",
	[":f_zhanshan"] = "游戏开始时，你起始手牌数+2且获得等同于游戏人数的“毡衫”标记；准备阶段开始时，若你没有“毡衫”标记，你可以减1点体力上限并获得1枚“毡衫”标记；每当有一名其他角色阵亡后，你可以获得1枚“毡衫”标记。出牌阶段，你可以将你的1枚“毡衫”标记移交给一名其他角色；有“毡衫”标记的角色即将受到普通伤害时，其弃置1枚“毡衫”标记，防止此伤害（若你死亡或全场没有技能“毡衫”，“毡衫”标记依然生效）。",
	["mark_zhanshan"] = "毡衫",
	["$f_zhanshan1"] = "已至马革山，宜速进军破蜀！", --游戏开始
	["$f_zhanshan2"] = "奇兵正功，敌何能为？", --准备阶段开始时发动
	["$f_zhanshan3"] = "蹇利西南，不利东北；破蜀功高，难以北回！", --其他角色阵亡时发动
	["$f_zhanshan4"] = "攻其不备，出其不意！", --出牌阶段发动
	["$f_zhanshan5"] = "用兵以险，则战之以胜！", --免伤
	["~f_shendengai"] = "吾破蜀克敌，竟葬于奸贼之手！",
	
	--<汉中王>神刘备
	["hzw_shenliubei"] = "<汉中王>神刘备",
	["#hzw_shenliubei"] = "仁贯终生",
	["designer:hzw_shenliubei"] = "时光流逝FC",
	["cv:hzw_shenliubei"] = "官方,三国演义影视作品",
	["illustrator:hzw_shenliubei"] = "DH",
	["&hzw_shenliubei"] = "神刘备",
	["f_jieyi"] = "结义",
	[":f_jieyi"] = "限定技，出牌阶段，你选择两名其他角色，则本局你们三人结为“兄弟”，且你们获得技能“义志”（你于摸牌阶段多摸一张牌，并可于摸牌阶段结束时将至多两张牌分配给其他“兄弟”；你对其他“兄弟”使用【桃】时，此【桃】回复量+1）且全局生效。",
	["@f_jieyi"] = "结义",
	["XD"] = "兄弟",
	["f_jieyiAnimate"] = "image=image/animate/f_jieyi.png",
	["$f_jieyi1"] = "不求同年同月同日生，但愿同年同月同日死！", --新三国
	["$f_jieyi2"] = "我们兄弟三人，不求同年同月同日生，但愿同年同月同日死！", --三国演义动画片
	  ["jy_yizhi"] = "义志",
	  ["yizhiDraw"] = "义志",
	  ["yizhiLoyal"] = "义志",
	  ["yizhiloyal"] = "义志",
	  ["yizhiRescue"] = "义志",
	  [":jy_yizhi"] = "(此技能全局生效)你于摸牌阶段多摸一张牌，并可于摸牌阶段结束时将至多两张牌分配给其他“兄弟”；你对其他“兄弟”使用【桃】时，此【桃】回复量+1。",
	  ["@yizhiLoyal-card1"] = "你可以选择其中一个“兄弟”，给其一张牌(第一张)",
	  ["@yizhiLoyal-card2"] = "你可以选择其中一个“兄弟”，给其一张牌(第二张)",
	  ["~yizhiLoyal"] = "点击一名可被选择的角色，点【确定】",
	  ["$yizhiREC"] = "其他兄弟对 %from 使用了【<font color='yellow'><b>桃</b></font>】，此【<font color='yellow'><b>桃</b></font>】的回复量+1",
	  ["$jy_yizhi1"] = "桃园结义，营一世之交。",
	  ["$jy_yizhi2"] = "兄弟三人结义志，桃园英气久长存。",
	["f_renyi"] = "仁义",
	["f_renyiX"] = "仁义",
	["f_renyix"] = "仁义",
	["f_renyiBuff"] = "仁义",
	[":f_renyi"] = "出牌阶段限一次，你可以摸三张牌，然后将你的1~6张牌交给一名其他角色。若你选择的目标角色是“兄弟”，则其下一张伤害牌造成的伤害+1。然后若此时：你没有手牌，摸两张牌；你没有装备牌，回复1点体力。",
	["f_renyiBUFF"] = "",
	["@f_renyiX-card"] = "请选择一名其他角色并选择你要给的牌，若选择的是“兄弟”则有额外效果",
	["~f_renyiX"] = "选择1~6张牌，点击一名可被选择的角色，点【确定】",
	["$f_renyiBufff"] = "因为“<font color='yellow'><b>仁义</b></font>”的加成，%from 使用的此伤害牌造成的伤害 + %arg2",
	["$f_renyi1"] = "以德服人。",
	["$f_renyi2"] = "惟贤惟德，能服于人。", --(语音1,2)给牌
	["$f_renyi3"] = "同心同德，救困扶危！", --兄弟造成伤害
	["f_chengwang"] = "称王",
	["f_chengwang_DamageRecord"] = "称王",
	["f_chengwang_DR"] = "战功",
	[":f_chengwang"] = "主公技，觉醒技，回合内的任意阶段开始时，若你已发动“结义”并于之后与其他“兄弟”累计造成了至少12点伤害，你减1点体力上限并回复1点体力，势力重置为“蜀”，获得技能“汉中王”。",
	["$f_chengwang"] = "杀出重围，成王者霸业！",
	  ["f_hanzhongwang"] = "汉中王",
	  ["f_hanzhongwang_BuffandClear"] = "汉中王",
	  [":f_hanzhongwang"] = "准备阶段开始时，你可以将一名其他角色的势力变更为“蜀”；出牌阶段开始时，你可以选择任意名其他“蜀”势力角色并获得他们区域里的一张牌，若如此做，则他们在其下回合造成的伤害+1。",
	  ["f_hanzhongwangBUFF"] = "兴复汉室",
	  ["@hzw_zhaomu"] = "[招募]您可以将一名其他角色的势力变更为“蜀”势力",
	  ["@hzw_haozhao"] = "[汉中王]号令群臣，兴复汉室！",
	  ["@f_hanzhongwang-card"] = "请选择任意名“蜀”势力的其他角色",
	  ["~f_hanzhongwang"] = "臣法正，参见汉中王！",
	  ["$f_hanzhongwang1"] = "物尽其用，方可人尽其才。", --改势力
	  ["$f_hanzhongwang2"] = "上报国家，下安黎庶！", --收保护费
	  ["$f_hanzhongwang3"] = "夺得首功者，封侯拜将！", --伤害+1
	["~hzw_shenliubei"] = "（新三国BGM：白帝城托孤）",
	
	--神黄忠
	["f_shenhuangzhong"] = "神黄忠",
	["#f_shenhuangzhong"] = "定军山斩夏侯",
	["designer:f_shenhuangzhong"] = "时光流逝FC",
	["cv:f_shenhuangzhong"] = "官方,新三国电视剧",
	["illustrator:f_shenhuangzhong"] = "福州光域",
	["f_shengong"] = "神弓",
	["f_shengongBuff_4SJ"] = "神弓",
	["f_shengongBuff_8SJ"] = "神弓",
	["f_shengongBuff_12SJ"] = "神弓",
	["f_shengongBuff_16SJ"] = "神弓",
	[":f_shengong"] = "锁定技，你的第一个回合开始时，摸十张牌，然后将你的十张手牌置于武将牌上，称为“神箭”。锁定技，若你的“神箭”数量：不少于4，你的【杀】无距离限制；不少于8，你的【杀】不可被【闪】响应；不少于12，你的【杀】伤害+1；不少于16，你每使用一张【杀】，摸一张牌并将你的一张手牌转化为“神箭”。",
	["ShenJian"] = "神箭",
	["f_shengongPush"] = "请选择将总计10张手牌置于武将牌上",
	["f_shengong_triggered"] = "",
	["f_shengong16SJPush"] = "请选择您的一张手牌置于武将牌上",
	["$f_shengong1"] = "哈哈哈哈哈哈哈哈哈哈......哈哈哈哈哈哈哈", --第一个回合获得“神箭”
	["$f_shengong2"] = "中！", --触发效果
	["f_dingjun"] = "定军", --修改前
	["f_dingjunTrigger"] = "定军",
	["f_dingjun_SkillClear"] = "定军",
	[":f_dingjun"] = "出牌阶段限一次(修改后:出牌阶段每个选项限一次)，你可以选择一项：1.获得四张(修改后:获得1~4张)“神箭”，然后获得“界烈弓”直到此阶段结束；2.将四张牌(修改后:将1~4张牌)转化为“神箭”，然后获得“乱射”直到此阶段结束。",
	--[":f_dingjun"] = "出牌阶段限一次，你可以选择一项：1.获得四张“神箭”，然后获得“界烈弓”直到此阶段结束；2.将四张牌转化为“神箭”，然后获得“乱射”直到此阶段结束。",
	["get4ShenJian"] = "获得四张“神箭”，获得“界烈弓”",
	["add4ShenJian"] = "装上四张“神箭”，获得“乱射”",
	["f_dingjunA4Push"] = "请选择您的四张手牌置于武将牌上",
	["getFShenJianSkill"] = "定军(获得“神箭”)",
	["getfshenjianskill"] = "定军(获得“神箭”)",
	["@getFShenJianSkill-card"] = "请选择四张“神箭”获得",
	["$f_dingjun"] = "弓不离手，自有转机！",
	  ["f_luanshe"] = "乱射",
	  ["f_luansheX"] = "乱射",
	  [":f_luanshe"] = "出牌阶段限一次，你可以将2X张“神箭”当【万箭齐发】使用（造成伤害时，有一定概率暴击）；你每以此法造成1点伤害，可以摸一张牌并将你的一张手牌转化为“神箭”。（暴击：伤害翻倍；X为你的当前体力值）",
	  ["f_luansheXPush"] = "请选择等同于伤害量的手牌置于武将牌上",
	  ["$f_luanshe"] = "箭阵开道，所向无敌！",
	["f_newdingjun"] = "定军", --修改后
	["f_newdingjunTrigger"] = "定军",
	[":f_newdingjun"] = "出牌阶段每个选项限一次，你可以选择一项：1.获得1~4张“神箭”，然后获得“界烈弓”直到此阶段结束；2.将1~4张牌转化为“神箭”，然后获得“乱射”直到此阶段结束。",
	["get1to4ShenJian"] = "获得1~4张“神箭”，获得“界烈弓”",
	["add1to4ShenJian"] = "装上1~4张“神箭”，获得“乱射”",
	["f_dingjunA1to4Push"] = "请选择您的1~4张手牌置于武将牌上",
	["getOTFShenJianSkill"] = "定军(获得“神箭”)",
	["getotfshenjianskill"] = "定军(获得“神箭”)",
	["@getOTFShenJianSkill-card"] = "请选择1~4张“神箭”获得",
	["$f_newdingjun"] = "弓不离手，自有转机！",
	["f_huanghansheng"] = "汉升",
	[":f_huanghansheng"] = "<font color='yellow'><b>使命技，</b></font>你需要于第一次进入濒死状态之前杀死一名其他角色。若使命：成功，你摸四张牌并修改“定军”；失败，你废除装备栏并将体力值回复至1点。",
	["DJSZhanGong"] = "定军山战功",
	["$DJSZhanGong"] = "老将说黄忠，收川立大功。重披金锁甲，双挽铁胎弓！",
	["$hanshengSUC"] = "%from 使命成功，摸四张牌并修改“<font color='yellow'><b>定军</b></font>”",
	["$hanshengFAL"] = "%from 使命失败，废除装备栏并将体力值回复至1点",
	["hhh_triggered"] = "",
	["$f_huanghansheng1"] = "主公啊，哈哈哈哈哈哈！主公，定军山被攻下来了！", --使命成功
	["$f_huanghansheng2"] = "不得不服老了...", --使命失败
	["~f_shenhuangzhong"] = "你服不服啊！呃哈哈哈哈..呃啊",
	
	--神项羽
	["f_shenxiangyu"] = "神项羽",
	["#f_shenxiangyu"] = "千古无二",
	["designer:f_shenxiangyu"] = "时光流逝FC",
	["cv:f_shenxiangyu"] = "英雄杀,神赵云,张学友", --神项羽的阵亡语音节选自张学友/夏妙然的《霸王别姬》
	["illustrator:f_shenxiangyu"] = "英雄杀",
	["f_bawang"] = "霸王",
	["f_bawangCard_used"] = "霸王",
	["f_bawangMaxCards"] = "霸王",
	[":f_bawang"] = "出牌阶段限一次，你可以弃置一张基本牌并指定一名角色，对其造成1点伤害，然后你摸一张牌。若如此做，除非你于此阶段未使用过【杀】，否则本回合你的手牌上限-1。",
	["$f_bawang"] = "挡我者死！",
	["f_zhuifeng"] = "追风",
	["f_zhuifengX"] = "追风",
	["f_zhuifengAudio"] = "追风（配音）",
	[":f_zhuifeng"] = "锁定技，当你的装备区里没有武器牌时，你的攻击范围+X；当你的装备区里没有防具牌时，你的【杀】可额外指定X个目标。（X为1+你已损失的体力值）",
	["$f_zhuifeng"] = "杀啊~！",
	["f_wuzhui"] = "乌骓",
	["f_wuzhuiMaxCards"] = "乌骓",
	[":f_wuzhui"] = "锁定技，当你的装备区里没有-1马时，你计算与其他角色的距离-1；当你的装备区里没有+1马时，你的手牌上限+1。",
	["f_pofuchenzhou"] = "决意 破釜沉舟",
	[":f_pofuchenzhou"] = "[破釜]准备阶段开始时，若你没有手牌，你摸两张牌。\
	[沉舟]结束阶段开始时，若你没有手牌，你可以对一名其他角色造成1点伤害。",
	["$f_pofuchenzhou1"] = "背水一战，不胜便死！",
	["$f_pofuchenzhou2"] = "置于死地，方能后生！",
	["~f_shenxiangyu"] = "力拔山兮气盖世，时不利兮骓不逝。... 骓不逝兮可奈何，虞兮虞兮奈若何。",
	
	--神孙悟空
	["f_shensunwukong"] = "神孙悟空",
	["#f_shensunwukong"] = "齐天大圣",
	["designer:f_shensunwukong"] = "时光流逝FC",
	["cv:f_shensunwukong"] = "86西游记电视剧,戴荃",
	["illustrator:f_shensunwukong"] = "网络",
	["f_bianhua"] = "变化",
	[":f_bianhua"] = "锁定技，你不于摸牌阶段内摸牌，改为在你回合内的每个阶段开始时，你摸一张牌。",
	["$f_bianhua1"] = "（西游记电视剧主题曲前奏）",
	["$f_bianhua2"] = "刚擒住了几个妖，又降住了几个魔，魑魅魍魉怎么它就这么多（嘿嘿，吃俺老孙一棒！）",
	["f_doufa"] = "斗法",
	[":f_doufa"] = "出牌阶段限一次，你弃置X张手牌，对一名角色造成2点任意属性（包括无属性）的伤害或令其失去2点体力(有25%的可能出现)（类型自选；X为你的当前体力值且至少为1）。",
	["f_doufaFire"] = "火焰伤害",
	["f_doufaThunder"] = "雷电伤害",
	["f_doufaIce"] = "冰冻伤害",
	["f_doufaPoison"] = "毒素伤害",
	["f_doufaNormal"] = "普通伤害",
	["f_doufalosehp"] = "失去体力",
	["$f_doufa1"] = "（齐天大圣，登场！）",
	["$f_doufa2"] = "踏碎凌霄，放肆桀骜；世恶道险，终究难逃~",
	["~f_shensunwukong"] = "五百年了.....", --暂无语音
	
	--霸霸
	["f_Trex"] = "[神]君王霸王龙",
	["#f_Trex"] = "恐龙之王",
	["designer:f_Trex"] = "时光流逝FC",
	["cv:f_Trex"] = "霸王龙吼声还原,亿载龙殿",
	["illustrator:f_Trex"] = "网络",
	["&f_Trex"] = "君王霸王龙",
	["f_diyuxi"] = "地狱溪",
	["f_diyuxiBUFF"] = "地狱溪",
	[":f_diyuxi"] = "出牌阶段每个选项限一次：1.失去1点体力并摸一张牌，则你本回合【杀】的伤害+1；2.减1点体力上限并摸两张牌，则你本回合造成的伤害+1。结束阶段开始时，若你于此回合的出牌阶段没作出选择或两项皆选，你失去1点体力。",
	["L1D1SD1"] = "失去1点体力并摸一张牌，本回合【杀】的伤害+1",
	["LM1D2D1"] = "减1点体力上限并摸两张牌，本回合造成的伤害+1",
	["$f_diyuxibuff1"] = "因为“<font color='yellow'><b>地狱溪</b></font>”的效果，%from 的【<font color='yellow'><b>杀</b></font>】对 %to 造成的伤害+1",
	["$f_diyuxibuff2"] = "因为“<font color='yellow'><b>地狱溪</b></font>”的效果，%from 对 %to 造成的伤害+1",
	["$f_diyuxi1"] = "（低沉的吼声）",
	["$f_diyuxi2"] = "（高昂的吼声）",
	["f_moshi"] = "末世",
	["f_moshiX"] = "末世",
	[":f_moshi"] = "主公技，觉醒技，准备阶段结束时，若你已于本局受到/失去过伤害/体力的次数之和至少为6，你失去技能“地狱溪”，摸两张牌，获得技能“狂龙”。",
	["f_moshiFQC"] = "末世次数",
	["$f_moshi"] = "地狱溪畔，末代辉煌，千古留名自霸王；金甲钢矛皆避让，地狱溪主称帝皇！", --“附歌词：金甲钢矛皆避让，恐龙帝皇~”
	  ["f_kuanglong"] = "狂龙",
	  ["f_kuanglongS"] = "狂龙",
	  ["f_kuanglongC"] = "狂龙",
	  [":f_kuanglong"] = "锁定技，你于摸牌阶段多摸X张牌，出牌阶段可使用【杀】的次数+X，手牌上限+X。（X为你已损失的体力值/2，向下取整）",
	  ["$f_kuanglong1"] = "（低沉的吼声）",
	  ["$f_kuanglong2"] = "（高昂的吼声）", --1,2皆同“地狱溪”的技能配音
	["~f_Trex"] = "飞越六世的跌宕，魂断百年的疯狂；一朝巧缘换兽王，再难思量......",
	
	--鲲鹏
	["f_kunpeng"] = "[神]鲲鹏",
	["#f_kunpeng"] = "天地之间",
	["designer:f_kunpeng"] = "时光流逝FC",
	["cv:f_kunpeng"] = "网络",
	["illustrator:f_kunpeng"] = "网络",
	["&f_kunpeng"] = "鲲鹏",
	["KunPeng"] = "鲲鹏",
	["f_juxing"] = "巨形",
	["f_juxingMarkSkill"] = "巨形",
	["f_juxingClearMark"] = "巨形",
	[":f_juxing"] = "准备阶段开始时，你可以选择一名其他（没有“鲲鹏”标记的）角色，其获得1枚“鲲鹏”标记。锁定技，每当你或拥有“鲲鹏”标记的角色受到伤害时，你防止此伤害，改为你减少与伤害值等量的体力上限。",
	["KunPeng"] = "鲲鹏",
	["@f_juxing-card"] = "请选择一名没有“鲲鹏”标记的其他角色",
	["~f_juxing"] = "点击一名可被选择的角色，点【确定】",
	["f_juxing_trigger"] = "九天",
	["$f_juxing1"] = "", --给“鲲鹏”标记
	["$f_juxing2"] = "", --防止伤害
	["f_jiutian"] = "九天",
	["f_jiutianContinue"] = "九天",
	[":f_jiutian"] = "<font color='green'><b>出牌阶段限X次，</b></font>你可以减1点体力上限，展示牌堆顶的一张牌：若为红色牌，你将其交给一名角色；若为黑色牌，你弃置之，令一名角色回复1点体力或摸一张牌。锁定技，结束阶段开始时，你减Y点体力上限。（X为你从上轮回合结束至本回合内触发“巨形”[锁定技部分]的次数；Y=X-本回合你发动“九天”[主动技部分]的次数）",
	["RecoverHim"] = "令其回复1点体力",
	["HeDrawCard"] = "令其摸一张牌",
	["$f_jiutian1"] = "", --出牌阶段发动技能减体力上限
	["$f_jiutian2"] = "", --翻开是红色牌并交给一名角色
	["$f_jiutian3"] = "", --翻开是黑色牌弃置并让一名角色回复体力或摸牌
	["~f_kunpeng"] = "（飞离声）",
	
	--FC神吕蒙
	["fc_shenlvmeng"] = "FC神吕蒙",
	["#fc_shenlvmeng"] = "兼资文武",
	["designer:fc_shenlvmeng"] = "时光流逝FC",
	["cv:fc_shenlvmeng"] = "官方",
	["illustrator:fc_shenlvmeng"] = "小牛",
	["&fc_shenlvmeng"] = "☆神吕蒙",
	["fcshelie"] = "涉猎",
	[":fcshelie"] = "摸牌阶段开始时，你可以放弃摸牌，改为亮出牌堆顶的五张牌：若如此做，你获得其中每种花色的牌各一张，然后将其余的牌置入弃牌堆或交给一名其他角色。",
	["@fcshelieGC"] = "[涉猎]将剩余的牌交给一名其他角色",
	["$fcshelie1"] = "尘世之间，岂有吾所未闻之事。",
	["$fcshelie2"] = "往事皆知，未来尽料！",
	["fcgongxin"] = "攻心",
	[":fcgongxin"] = "出牌阶段限一次，你可以观看一名其他角色的手牌，然后你可以展示其中一张牌并选择一项：弃置之（若此牌花色为红桃，改为获得之），或将之置于牌堆顶。",
	["fcgongxin:discard"] = "弃置(若此牌为♥则获得之)",
	["fcgongxin:put"] = "置于牌堆顶",
	["$fcgongxin1"] = "知敌所欲为，则此战，已尽在掌握。",
	["$fcgongxin2"] = "敌将虽有破军之勇，然未必有弑神之心。",
	["~fc_shenlvmeng"] = "吾能已通神，却难逆天命。",
	
	--FC神赵云
	["fc_shenzhaoyun"] = "FC神赵云",
	["#fc_shenzhaoyun"] = "天神下凡",
	["designer:fc_shenzhaoyun"] = "时光流逝FC",
	["cv:fc_shenzhaoyun"] = "极略三国,神赵云皮肤",
	["illustrator:fc_shenzhaoyun"] = "三国志幻想大陆",
	["&fc_shenzhaoyun"] = "☆神赵云",
	["fcweijing"] = "危境",
	["fcweijing_MaxCards"] = "危境",
	["fcweijing_MaxCards_Audio"] = "危境",
	["fcweijing_Draw"] = "危境",
	["fcweijing_Draw_Audio"] = "危境",
	[":fcweijing"] = "锁定技，你于摸牌阶段额外摸X张牌；你的手牌上限为你的体力上限+Y；当你进入/脱离濒死状态时，你摸X/Y张牌。（X为你已损失的体力值；Y为你的当前体力值）",
	["$fcweijing1"] = "龙战于野，其血玄黄!!", --摸牌阶段额外摸牌
	["$fcweijing2"] = "腾龙行云，首尾不见！", --弃牌阶段
	["$fcweijing3"] = "常山赵子龙在此！", --进入/脱离濒死状态
	["fclongming"] = "龙鸣",
	["fclongmingBuff"] = "龙鸣",
	[":fclongming"] = "你可以将至多两张花色相同的牌按以下规则使用或打出：红桃当【桃】；方块当【闪】；梅花当雷【杀】；黑桃当【酒】。若你以此法使用了两张牌且花色为：红桃，回复值+1；方块，获得当前回合角色的一张牌；梅花，伤害值+1；黑桃，效果量+1。",
	["$fclongmingPREC"] = "通过发动“<font color='yellow'><b>龙鸣</b></font>”使用两张红桃牌，此【<font color='yellow'><b>桃</b></font>】对 %from 的回复值+1",
	["$fclongmingJNK"] = "%from 发动“<font color='yellow'><b>龙鸣</b></font>”使用了两张方块牌，获得当前回合角色的一张牌",
	["$fclongmingDMG"] = "%from 发动“<font color='yellow'><b>龙鸣</b></font>”使用了两张梅花牌，此【<font color='yellow'><b>杀</b></font>】的伤害值+1",
	["$fclongmingANA"] = "%from 发动“<font color='yellow'><b>龙鸣</b></font>”使用了两张黑桃牌，此【<font color='yellow'><b>酒</b></font>】的伤害加成值+1",
	["$fclongmingAREC"] = "%from 发动“<font color='yellow'><b>龙鸣</b></font>”使用了两张黑桃牌，此【<font color='yellow'><b>酒</b></font>】的回复值+1",
	["fclongmingx"] = "配音-龙鸣", --“龙鸣”的专属配音技能
	["fclongming_Audio"] = "配音-龙鸣",
	[":fclongmingx"] = "[配音技]此技能为“龙鸣”的专属配音。",
	["$fclongmingx1"] = "潜龙于渊，涉灵愈伤。", -- ♥
	["$fclongmingx2"] = "潜龙勿用，藏锋守拙！", -- ♦
	["$fclongmingx3"] = "（雷电声）", -- ♣
	["$fclongmingx4"] = "金甲映日，驱邪祛秽！", -- ♠
	["$fclongmingx5"] = "龙战于野，其血玄黄！", -- 两张红色牌
	["$fclongmingx6"] = "来感受这，降世神龙的力量吧！", -- 两张黑色牌
	  ["$fclongmingx7"] = "千里一怒，红莲灿世！", --彩蛋：使用火【杀】
	["~fc_shenzhaoyun"] = "龙身虽死，魂魄不灭！",
	
	--FC神刘备
	["fc_shenliubei"] = "FC神刘备",
	["#fc_shenliubei"] = "昭烈怒火",
	["designer:fc_shenliubei"] = "时光流逝FC",
	["cv:fc_shenliubei"] = "官方",
	["illustrator:fc_shenliubei"] = "佚名",
	["&fc_shenliubei"] = "☆神刘备",
	["$longnu3"] = "怒伤心肝，也阻止不了这复仇之火！",
	["$longnu4"] = "灼艾分痛失，虽万劫，亦杀之！",
	["fcjieying"] = "结营",
	["fcjieying_GMS"] = "结营",
	["fcjieying_MoreSlashUsed"] = "结营",
	["fcjieying_MaxCards"] = "结营",
	[":fcjieying"] = "锁定技，你始终处于横置状态；已横置的角色出牌阶段可额外使用一张【杀】、手牌上限-2；你的手牌上限+3。结束阶段开始时，你可以横置一名其他角色。",
	["fcjieying-invoke"] = "你发动了技能“结营”<br/> <b>操作提示</b>: 选择一名不处于连环状态的角色→点击确定<br/>",
	["$fcjieying1"] = "结连营之策，拒暴虐之贼。",
	["$fcjieying2"] = "兄弟三人结义志，桃园英气久长存。",
	["~fc_shenliubei"] = "鹡鸰在原，来生再聚......",
	
	--FC神张辽
	["fc_shenzhangliao"] = "FC神张辽",
	["#fc_shenzhangliao"] = "威震逍遥津",
	["designer:fc_shenzhangliao"] = "时光流逝FC",
	["cv:fc_shenzhangliao"] = "官方",
	["illustrator:fc_shenzhangliao"] = "未知",
	["&fc_shenzhangliao"] = "☆神张辽",
	["fcduorui"] = "夺锐",
	[":fcduorui"] = "当你于出牌阶段对一名其他角色造成伤害后，你可以选择一项：1.获得其一张牌；2.清空其手牌区，然后你翻面，且于此阶段内你不能再发动“夺锐”；3.清空其装备区，然后（在所有结算完成后）结束你的出牌阶段。",
	["obtain1card"] = "获得其一张牌",
	["CleanUpHandArea"] = "清空其手牌区",
	["CleanUpEquipArea"] = "清空其装备区",
	["$fcduorui1"] = "夺敌军锐气，杀敌方士气！",
	["$fcduorui2"] = "尖锐之势，吾亦可一人夺之！",
	["fczhiti"] = "止啼",
	["fczhitiX"] = "止啼",
	["fczhiti_Audio"] = "止啼",
	[":fczhiti"] = "锁定技，你攻击范围内已受伤的角色手牌上限-1；准备阶段开始时，若场上已受伤的角色数：不少于1，本回合你的手牌上限+1、使用牌的距离+1；不少于3，摸牌阶段你的摸牌数+1、出牌阶段你可使用【杀】的次数+1；不少于5，结束阶段开始时你可以废除一名其他角色的装备区（直到其下回合结束）并对其造成1点伤害。",
	["fczhitiFlag"] = "止啼",
	["fcweijing_MaxCards"] = "止啼",
	["fczhiti_MoreDistance"] = "止啼",
	["fczhiti_DrawMoreCard"] = "止啼",
	["fczhiti_MoreSlashUsed"] = "止啼",
	["fczhiti_throwEquipArea_Damage"] = "止啼",
	["fczhiti_obtainEquipArea"] = "止啼",
	["$fczhiti1"] = "江东小儿，安敢啼哭？！",
	["$fczhiti2"] = "娃闻名止啼，孙损十万休！",
	["~fc_shenzhangliao"] = "我也有被孙仲谋所伤之时？！",
	
	--地主
	["f_landlord"] = "地主",
	["#f_landlord"] = "豆递主",
	["designer:f_landlord"] = "时光流逝FC",
	["cv:f_landlord"] = "祖茂",
	["illustrator:f_landlord"] = "欢乐斗地主",
	["f_feiyang"] = "飞扬",
	[":f_feiyang"] = "判定阶段开始时，若你的判定区有牌，你可以弃置两张手牌，弃置你判定区的其中一张牌。",
	["@f_feiyang"] = "你可以弃置两张手牌来弃置你判定区里的一张牌",
	["~f_feiyang"] = "选择两张手牌→点击确定",
	["f_bahu"] = "跋扈",
	["f_bahuSlashMore"] = "跋扈",
	[":f_bahu"] = "锁定技，准备阶段，你摸一张牌；你出牌阶段使用【杀】的次数上限+1。",
	["f_yinfu"] = "殷富",
	[":f_yinfu"] = "回合开始时，若你已损失的体力值不小于游戏轮次，你回复1点体力。此技能发动三次后，你失去此技能。",
	["f_yinfuTurn"] = "",
	["f_yinfuTriggered"] = "",
	["~f_landlord"] = "将军走此小道：（托管中... 逃跑）",
	
	--农民
	["f_farmer"] = "农民",
	["#f_farmer"] = "逗地主",
	["designer:f_farmer"] = "时光流逝FC",
	["cv:f_farmer"] = "邓艾,??",
	["illustrator:f_farmer"] = "欢乐斗地主",
	["f_gengzhong"] = "耕种",
	["f_gengzhongCard"] = "耕种",
	["f_gengzhongNTGet"] = "耕种",
	[":f_gengzhong"] = "出牌阶段限一次，你可以将一张牌置于武将牌上，称为“农田”，然后你可以视为使用一种(官方)基本牌(<font color='red'><b>注意！：满血选择【桃】，视为点【取消】</b></font>)；回合开始时或回合结束时，你可以获得你武将牌上的所有“农田”。",
	["NT"] = "农田",
	["@f_gengzhong"] = "你可以视为使用【杀】",
	["~f_gengzhong"] = "选择目标角色→点击确定",
	["@f_gengzhongNTGet"] = "[耕种]获得所有“农田”",
	["$f_gengzhong"] = "锄禾日当午，汗滴禾下土。",
	["f_gongkang"] = "共抗",
	[":f_gongkang"] = "限定技，出牌阶段，你选择一名其他角色，则其获得技能“耕种”且你们获得技能“同心”。",
	["@f_gongkang"] = "共抗",
	["f_tongxin"] = "同心",
	[":f_tongxin"] = "当一名有此技能的角色死亡后，场上其他有此技能的角色可选择一项：摸两张牌，或回复1点体力(彩蛋：如果伤害来源有此技能，会触发隐藏语音)。",
	["f_tongxin:1"] = "摸两张牌",
	["f_tongxin:2"] = "回复1点体力",
	["f_tongxinCDAudio"] = "同心-彩蛋",
	["$f_tongxinCDAudio"] = "无用之人，死！",
	["~f_farmer"] = "（砸蛋砸蛋砸蛋砸蛋砸蛋）哥，你不刷个桃的吗？",
	
	--J.SP赵云强化
	["chixinDrawANDGive"] = "赤心",
	["chixindrawandgive"] = "赤心",
	["@chixinDrawANDGive-card"] = "请将你的一张牌正面朝上交给一名角色",
	["~chixinDrawANDGive"] = "选择一张牌，点【确定】",
	["suirenChangeKingdom"] = "随仁",
	["sCKinvoked"] = "",
	["$chixin1"] = "匹马单枪出重围，英风锐气敌胆寒！",
	["$chixin2"] = "八面威风杀气飘，擎王保驾显功劳！",
	["$suiren"] = "纵死侠骨香，不愧知遇恩！",
	["~jsp_zhaoyun"] = "魂归在何处，仰天长问三两声......",
	
	--项羽专属装备：乌骓马（正好与防御马数量4:4对齐，强迫症福音）
	["xiangyuEquip"] = "项羽专属装备",
	["wuzhuii"] = "乌骓",
	--["Wuzhuii"] = "乌骓",
	[":wuzhuii"] = "[进攻马]锁定技，你与其他角色的距离-1。",
	
	--==DIY十二神将==--
	--武神·关羽
	["sp_shenguanyu"] = "武神·关羽",
	["&sp_shenguanyu"] = "武神关羽",
	["#sp_shenguanyu"] = "威震华夏",
	["designer:sp_shenguanyu"] = "时光流逝FC",
	["cv:sp_shenguanyu"] = "官方,三国志13",
	["illustrator:sp_shenguanyu"] = "Thinking",
	  --桃园义
	["sp_taoyuanyi"] = "桃园义", --刘关张三人桃园结义
	["sp_taoyuanyi_buffANDlimited"] = "桃园义",
	[":sp_taoyuanyi"] = "出牌阶段限一次，你可以将一张红桃手牌当【桃园结义】使用；你使用的【桃园结义】每让一名角色回复体力，你随机执行一项：1.摸一张牌；2.回复1点体力；3.加1点体力上限。",
	["$sp_taoyuanyi1"] = "策马挥刀，安天下，复汉室！",
	["$sp_taoyuanyi2"] = "忠心赤胆，青龙啸天！",
	  --[决意]过关斩将
	["sp_guoguanzhanjiang"] = "决意 过关斩将", --过五关，斩六将
	[":sp_guoguanzhanjiang"] = "[过关]回合开始时，若场上没有“关”标记，随机一名未获得过“关”标记的其他角色获得1枚“关”标记。然后你拥有技能“千里行”直到你对其造成伤害。然后你弃置其“关”标记，视为对其完成一次“过关”。\
	[斩将]你每杀死一名角色且该角色为你对其完成“过关”的角色，你视为完成一次“斩将”。\
	<font color='purple'><b>奖惩结算</b></font>：\
	<font color=\"#66FF66\"><b>奖励</b></font>：锁定技，回合结束时，若你于本回合完成“过关”，你摸X张牌（X为你累计完成“过关”的次数）；出牌阶段开始时，你摸Y张牌、回复Y-1点体力、加Y-2点体力上限（Y为你累计完成“斩将”的次数）；\
	<font color='red'><b>惩罚</b></font>：锁定技，回合结束时，若你未于本回合完成“过关”，你减1点体力上限。当你累计完成Z次“过关”后，此惩罚失效。（Z为此时场上其他角色的数量且至多为5）",
	["LeVeL"] = "关",
	["alreadyPASSlevel"] = "已过关",
	["PASSlevel"] = "过关",
	["KILLgeneral"] = "斩将",
	["$ggzz_guoguan"] = "%from 已成功完成对 %to 的 <font color='orange'><b>过关</b></font>！",
	["$ggzz_zhanjiang"] = "%from 成功完成一次 <font color='red'><b>斩将</b></font>！",
	["ggzz_punishlose"] = "",
	["$sp_guoguanzhanjiang1"] = "关某向来恩怨分明！", --过关
	["$sp_guoguanzhanjiang2"] = "又一个刀下亡魂！", --斩将
	    --千里行
	  ["sp_qianlixing"] = "千里行", --三国志12关羽战法
	  ["sp_qianlixingMD"] = "千里行",
	  ["sp_qianlixingPF"] = "千里行",
	  [":sp_qianlixing"] = "你可以将一张红色基本牌或装备牌当【杀】使用或打出：若此时是你的出牌阶段，你以此法使用的【杀】无距离限制且无视防具。",
	  ["$sp_qianlixing"] = "刀锋所向，战无不克！",
	    --（奖惩结算）
	  ["sp_guoguanzhanjiang_RAP"] = "过关斩将:奖惩结算",
	  [":sp_guoguanzhanjiang_RAP"] = "\
	  <font color='purple'><b>奖惩结算</b></font>：\
	  <font color=\"#66FF66\"><b>奖励</b></font>：锁定技，回合结束时，若你于本回合完成“过关”，你摸X张牌（X为你累计完成“过关”的次数）；出牌阶段开始时，你摸Y张牌、回复Y-1点体力、加Y-2点体力上限（Y为你累计完成“斩将”的次数）；\
	  <font color='red'><b>惩罚</b></font>：锁定技，回合结束时，若你未于本回合完成“过关”，你减1点体力上限。当你累计完成Z次“过关”后，此惩罚失效。（Z为此时场上其他角色的数量且至多为5）",
	  ["$sp_guoguanzhanjiang_RAP1"] = "过关斩将:过关奖励音效",
	  ["$sp_guoguanzhanjiang_RAP2"] = "过关斩将:斩将奖励音效",
	  --威震
	["sp_weizhen"] = "威震", --水淹七军，斩庞德，擒于禁，威震华夏！
	["sp_weizhen_limited"] = "威震",
	[":sp_weizhen"] = "出牌阶段，你可以将一张黑色基本牌或锦囊牌当【水淹七军】使用。若你于一个出牌阶段使用此技能的次数达到：2次，失去1点体力；3次及以上，每使用一次减1点体力上限。",
	["sp_weizhen_used"] = "",
	["$sp_weizhen1"] = "以义传魂，以武入圣！",
	["$sp_weizhen2"] = "义击逆流，武安黎庶！",
	  --显圣
	["sp_xiansheng"] = "显圣", --玉泉山关公显圣
	[":sp_xiansheng"] = "你死亡时，可以选择至多三名其他角色，若如此做，这些角色于你死亡后摸两张牌并回复1点体力。",
	["@sp_xiansheng-card"] = "桃园梦，忠义魂，玉泉山关公显圣",
	["~sp_xiansheng"] = "你可以选择至多三名其他角色",
	["$sp_xiansheng"] = "（赤面秉赤心，骑赤兔追风，驰不忘先帝。青灯观青史，仗青龙偃月，隐不愧青天！）",
	  --阵亡
	["~sp_shenguanyu"] = "桃园之梦，再也不会回来了...",
	
	--风神·吕蒙
	["sp_shenlvmeng"] = "风神·吕蒙",
	["&sp_shenlvmeng"] = "风神吕蒙",
	["#sp_shenlvmeng"] = "渡江夺荆",
	["designer:sp_shenlvmeng"] = "时光流逝FC",
	["cv:sp_shenlvmeng"] = "官方",
	["illustrator:sp_shenlvmeng"] = "biou09",
	  --刮目
	["sp_guamu"] = "刮目", --士别三日，当刮目相待
	[":sp_guamu"] = "出牌阶段限一次，你可以令一名角色选择一种牌的类别，然后你展示牌堆顶的三张牌：你将其中所有与选择类别相同的牌交给其或你，将其余的置入弃牌堆。然后根据此次获得的牌数：\
	至少一张，你摸一张牌并将你的一张牌弃置或置于牌堆顶；\
	至少两张，你回复1点体力；\
	至少三张，你获得技能“攻心”直到回合结束。",
	["sp_guamuBasic"] = "基本牌",
	["sp_guamuTrick"] = "锦囊牌",
	["sp_guamuEquip"] = "装备牌",
	["$sp_guamuBasic"] = "%from 选择了 <font color='yellow'><b>基本牌</b></font>",
	["$sp_guamuTrick"] = "%from 选择了 <font color='yellow'><b>锦囊牌</b></font>",
	["$sp_guamuEquip"] = "%from 选择了 <font color='yellow'><b>装备牌</b></font>",
	["sp_guamu:1"] = "交给其",
	["sp_guamu:2"] = "交给你",
	["sp_guamuONE"] = "刮目",
	["sp_guamuONEthrow"] = "弃置一张牌",
	["sp_guamuONEput"] = "将一张牌置于牌堆顶",
	["$sp_guamu1"] = "还有什么我不知道的。", --展示
	["$sp_guamu2"] = "书读五车，云开见日。", --至少一张
	["$sp_guamu3"] = "心里如何想的，我已知八九。", --至少两张
	["$sp_guamu4"] = "在我的眼中，你没有秘密。", --至少三张
	  --渡江
	["sp_dujiang"] = "渡江", --白衣渡江
	["sp_dujiangxijing"] = "渡江",
	["sp_dujiangFixedDistanceClear"] = "渡江",
	[":sp_dujiang"] = "出牌阶段限一次，你可以弃置一张装备牌并选择一名其他角色，则直到回合结束，你与其距离视为1且对其使用牌无次数限制。",
	["$sp_dujiang1"] = "快舟轻甲，速袭其后！",
	["$sp_dujiang2"] = "白衣摇橹，昼夜兼行！",
	  --阵亡
	["~sp_shenlvmeng"] = "而我，又何去何从。",
	
	--火神·周瑜
	["sp_shenzhouyu"] = "火神·周瑜",
	["&sp_shenzhouyu"] = "火神周瑜",
	["#sp_shenzhouyu"] = "人间英才",
	["designer:sp_shenzhouyu"] = "时光流逝FC",
	["cv:sp_shenzhouyu"] = "官方,血桜の涙",
	["illustrator:sp_shenzhouyu"] = "木美人",
	  --琴魔
	["sp_qinmo"] = "琴魔", --曲有误，周郎顾
	[":sp_qinmo"] = "出牌阶段开始时，你可以令一名角色失去或回复1点体力。若如此做，结束你的出牌阶段。",
	["sp_qinmoloseHp"] = "令一名角色失去1点体力",
	["sp_qinmoaddHp"] = "令一名角色回复1点体力",
	["$sp_qinmo"] = "（琴声）",
	  --火神
	["sp_huoshen"] = "火神", --三国志11周瑜特技
	[":sp_huoshen"] = "锁定技，你对一名在你攻击范围内的其他角色造成火焰伤害时，此伤害+1。",
	["$sp_huoshen"] = "让这熊熊业火，焚尽你的罪恶！",
	  --赤壁
	["sp_chibi"] = "赤壁", --赤壁之战
	["sp_chibiCount"] = "赤壁",
	[":sp_chibi"] = "限定技，出牌阶段，你对所有其他角色各造成1点火焰伤害。若你以此法造成有角色死亡，在所有伤害结算完成后你摸四张牌。",
	["@sp_chibi"] = "赤壁",
	["sp_chibiAnimate"] = "image=image/animate/sp_chibi.png",
	["$sp_chibi"] = "红莲业火，焚尽世间万物！",
	  --千古
	["sp_qiangu"] = "千古", --大江东去，浪淘尽，千古风流人物
	[":sp_qiangu"] = "觉醒技，准备阶段开始时，若你已发动过“赤壁”，你减1点体力上限，获得技能“神姿”。",
	["$sp_qiangu"] = "逝者不死，浴火重生......",
	    --神姿
	  ["sp_shenzi"] = "神姿", --对应“英姿”
	  [":sp_shenzi"] = "摸牌阶段，你可以选择一项：1.多摸一张牌；2.多摸两张牌，本回合手牌上限-1；3.少摸一张牌，本回合手牌上限+2；4.少摸两张牌，对一名其他角色造成1点火焰伤害。",
	  ["sp_shenzi3cards"] = "多摸一张牌",
	  ["sp_shenzi4cards"] = "多摸两张牌，本回合手牌上限-1",
	  ["sp_shenzi1card"] = "少摸一张牌，本回合手牌上限+2",
	  ["sp_shenzi0card"] = "少摸两张牌，对一名其他角色造成1点火焰伤害",
	  ["$sp_shenzi"] = "哈哈哈哈哈哈哈哈",
	  --阵亡
	["~sp_shenzhouyu"] = "天下已三分，我的使命..已结束了...",
	
	--天神·诸葛
	["sp_shenzhuge"] = "天神·诸葛",
	["&sp_shenzhuge"] = "天神诸葛",
	["#sp_shenzhuge"] = "天之骄子",
	["designer:sp_shenzhuge"] = "时光流逝FC",
	["cv:sp_shenzhuge"] = "官方,英雄杀,背后灵",
	["illustrator:sp_shenzhuge"] = "网络",
	  --智神
	["sp_zhishen"] = "智神",
	["sp_zhishenX"] = "智神",
	[":sp_zhishen"] = "你每使用一张非延时锦囊牌，可以获得X枚“神智”标记（若使用的是红色牌X为2，否则为1）；你每使用一张延时锦囊牌，可以摸三张牌；锁定技，你不能成为延时锦囊牌的目标。",
	["ShenZhi"] = "神智",
	["$sp_zhishen1"] = "淡泊以明志，宁静以致远。",
	["$sp_zhishen2"] = "志，当存高远；静，以修身。", --(语音1,2)使用非延时锦囊牌
	["$sp_zhishen3"] = "七星皆明，此战定胜。", --使用延时锦囊牌
	  --政神
	["sp_zhengshen"] = "政神",
	["sp_zhengshenGC"] = "政神",
	["sp_zhengshengc"] = "政神",
	[":sp_zhengshen"] = "摸牌阶段，你可以多摸两张牌，若如此做，出牌阶段开始时，你选择一项：依次将总计两张手牌交给一或两名其他角色，或弃置两张手牌。",
	["sp_zhengshen_used"] = "",
	["@sp_zhengshenGC"] = "[政神]你需要将两张手牌分配给其他角色，若点【取消】则弃置两张手牌",
	["@sp_zhengshenGC-card1"] = "请选择一名其他角色，给第一张牌",
	["@sp_zhengshenGC-card2"] = "请选择一名其他角色，给第二张牌",
	["~sp_zhengshenGC"] = "点击一名可被选择的角色，点击要交给其的牌，点【确定】",
	["$sp_zhengshen"] = "伏望天恩，兴汉破曹。",
	  --军神
	["sp_junshen"] = "军神",
	[":sp_junshen"] = "锁定技，你计算与其他角色的距离-Y。（Y为你装备区里的装备牌数）",
	  --祈天
	["sp_qitian"] = "祈天", --设七星坛祭风
	["sp_qitian_SkillClear"] = "祈天",
	[":sp_qitian"] = "判定阶段开始时，你可以弃置Z枚“神智”标记（1≤Z≤4）进行判定，根据判定的花色执行相应效果：\
	红桃，你摸Z张牌，弃两张牌，回复1点体力；\
	方块，你获得4枚“神智”标记，获得“界火计”直到回合结束；\
	梅花，你令一名角色获得1枚“狂风”标记，然后若Z=4，你对其造成1点火焰伤害（“狂风”标记：你受到的火焰伤害+1）；\
	黑桃，你对一名角色造成Z-1点雷电伤害，然后你弃置其Z-2张牌（至少一张），再自弃Z张牌。",
	["remove1szmark"] = "弃置1枚“神智”标记",
	["remove2szmarks"] = "弃置2枚“神智”标记",
	["remove3szmarks"] = "弃置3枚“神智”标记",
	["remove4szmarks"] = "弃置4枚“神智”标记",
	["sp_qitianaddskill_data"] = "",
	["$sp_qitian1"] = "伏望天慈，延我之寿。", --判定结果：♥
	["$sp_qitian2"] = "知天易，逆天难。", --判定结果：♦
	["$sp_qitian3"] = "风......~起......！", --判定结果：♣
	["@sp_crazywind"] = "狂风",
	["sp_qitian_crazywind"] = "祈天-狂风",
	["$sp_qitian4"] = "（电闪，雷鸣！）", --判定结果：♠
	  --智绝
	["sp_zhijue"] = "智绝", --《三国演义》“三绝”其一
	[":sp_zhijue"] = "觉醒技，准备阶段开始时，若你满足以下三个条件其二（1.体力值为1；2.手牌数≤1；3.于本局进入过濒死状态），你减1点体力上限，获得1枚“大雾”标记（“大雾”标记：直到你的下回合开始前，防止你受到的非雷电伤害），获得技能“八阵”、“鬼门”。",
	["@sp_fog"] = "大雾",
	["sp_zhijue_fog"] = "智绝-大雾",
	["fog_Clear"] = "",
	["$sp_zhijue"] = "庶竭驽钝，攘除奸凶；兴复汉室，还于旧都！",
	    --鬼门
	  ["sp_guimen"] = "鬼门", --三国志11的一种特技
	  [":sp_guimen"] = "出牌阶段限一次，若你的“神智”标记有十位数，你可以弃置所有“神智”标记对所有其他角色各造成随机1~3点雷电伤害。",
	  ["$sp_guimen"] = "（恸天之雷霆！！！）",
	  ["$sp_guimenn"] = "鬼门大开，天地重启！！！",
	  --阵亡
	["~sp_shenzhuge"] = "今当远离..临表涕零...不知所言....",
	
	--君神·曹操
	["sp_shencaocao"] = "君神·曹操",
	["&sp_shencaocao"] = "君神曹操",
	["#sp_shencaocao"] = "一统北方",
	["designer:sp_shencaocao"] = "时光流逝FC",
	["cv:sp_shencaocao"] = "官方,军师联盟",
	["illustrator:sp_shencaocao"] = "网络",
	  --煮酒
	["sp_zhujiu"] = "煮酒", --煮酒论英雄
	["sp_zhujiuStartandEnd"] = "煮酒",
	["sp_zhujiuPindian"] = "煮酒",
	[":sp_zhujiu"] = "出牌阶段开始时，你可以<font color='red'><b>摸两张牌</b></font>并选择一名其他角色。则本回合的出牌阶段，你可以与其拼点：若你赢，你视为使用了【酒】（以此法使用的【酒】无次数限制）；若你没赢，你将武将牌翻面，若你以此法翻为：背面，你弃置一张手牌；正面，其弃置你一张牌且你不能再发动此技能直到回合结束。出牌阶段限一次，你可以获得你与目标以此法拼点的牌。",
	["CaL_zhujiuLYX"] = "选择一名其他角色，煮酒论英雄！",
	["qingmei_zhujiu"] = "青梅煮酒",
	["@sp_zhujiugetPindianCards"] = "[煮酒]获得双方拼点的牌",
	["sp_zhujiuFQC"] = "煮酒次数",
	["$sp_zhujiu1"] = "奸略逐鹿原，雄才扫狼烟！",
	["$sp_zhujiu2"] = "量小非君子，无奸不成雄！",
	  --歌行
	["sp_gexing"] = "歌行", --《短歌行》
	[":sp_gexing"] = "限定技，准备阶段结束时，若你于本局<font color='red'><b>通过“煮酒”的拼点次数与通过“煮酒”使用【酒】的次数之和</b></font>至少为10，你可以减1点体力上限，获得技能“天下”。", --10：袁术、袁绍、刘表、孙策、刘璋、张绣、张鲁、韩遂、刘备、曹操
	["@duangexing"] = "短歌行",
	["@sp_gexing-card"] = "已达成发动条件，你是否发动技能“歌行”？",
	["$duangexing"] = "青青子衿，悠悠我心；\
	但为君故，沉吟至今。",
	["$sp_gexing1"] = "明明如月，何时可掇~",
	["$sp_gexing2"] = "忧从中来，不可断绝~",
	  --天下
	  ["sp_tianxia"] = "天下", --曹操欲通过赤壁之战实现一统天下的抱负
	  [":sp_tianxia"] = "出牌阶段限一次，你可以选择一项：\
	  1.失去1点体力，令所有其他角色各选择一项：交给你一张牌(必须有牌)，或受到你造成的1点伤害。\
	  2.跳过下回合的出牌阶段，对所有其他角色依次执行一项：获得其区域里的一张牌，或对其造成1点伤害。\
	  3.减1点体力上限，依次执行前两项。",
	  ["sp_tianxia:1"] = "失去1点体力，令所有其他角色做出选择",
	  ["sp_tianxia:2"] = "跳过下回合的出牌阶段，对所有其他角色做出选择",
	  ["sp_tianxia:3"] = "减1点体力上限，依次执行前两项",
	  ["sp_tianxiaOther"] = "天下",
	  ["sp_tianxiaOther:1"] = "交给其一张牌",
	  ["sp_tianxiaOther:2"] = "受到其造成的1点伤害",
	  ["sp_tianxiaSelf"] = "天下",
	  ["sp_tianxiaSelf:1"] = "获得其区域里的一张牌",
	  ["sp_tianxiaSelf:2"] = "对其造成1点伤害",
	  ["SkipPlayerPlay"] = "跳过出牌阶段", --通用
	  ["$sp_tianxia1"] = "即便背负骂名，我也是为这天下！", --执行第一项
	  ["$sp_tianxia2"] = "天下人才，皆入我麾下！", --执行第二项
	  ["$sp_tianxia3"] = "挟天子以令诸侯，握敕令以致四方！", --两项皆执行
	  --阵亡
	["~sp_shencaocao"] = "平生诸憾，终不可追......",
	
	--战神·吕布
	["sp_shenlvbuu"] = "战神·吕布",
	["&sp_shenlvbuu"] = "战神吕布",
	["#sp_shenlvbuu"] = "独战六将",
	["designer:sp_shenlvbuu"] = "时光流逝FC",
	["cv:sp_shenlvbuu"] = "官方",
	["illustrator:sp_shenlvbuu"] = "魔奇士",
	  --武极
	["sp_wuji"] = "武极", --三国（演义）武力的顶点
	["sp_wujiChoice"] = "武极",
	[":sp_wuji"] = "出牌阶段开始时，你可以减1点体力上限并选择一项：摸两张牌，弃一张牌；或摸一张牌，弃两张牌。\
	◆若你选择前者，你获得技能“无双”、“飞将”，直到回合结束；\
	◆若你选择后者，你获得技能“无双”、“飞将”、“猛冠”、“独勇”，直到回合结束。觉醒技，若你本局累计至少三次选择此项，你获得技能“横扫千军”。",
	["sp_wuji:1"] = "摸两张牌，弃一张牌",
	["sp_wuji:2"] = "摸一张牌，弃两张牌",
	["sp_wujiAnger"] = "武极怒气",
	["$sp_wuji1"] = "谁能挡我？", --选前者
	["$sp_wuji2"] = "神挡杀神，佛挡杀佛！", --选后者
	["$sp_wuji3"] = "且断轮回化魔躯，不擒汝首誓不还！", --觉醒
	    --飞将
	  ["sp_feijiang"] = "飞将", --吕布的称号
	  [":sp_feijiang"] = "出牌阶段限一次，你可以与一名其他角色拼点：若你赢，视为你对其使用一张（无距离限制且不计次的）【杀】；若你没赢，你获得其区域里的一张牌，然后结束出牌阶段。",
	  ["$sp_feijiang1"] = "沉沦吧，在这无边的恐惧！",
	  ["$sp_feijiang2"] = "项上人头，待我来取！",
	    --猛冠
	  ["sp_mengguan"] = "猛冠", --吕布的头冠，修饰吕布的勇猛
	  [":sp_mengguan"] = "出牌阶段，你可以将一张武器牌当作【决斗】使用。",
	  ["$sp_mengguan1"] = "蚍蜉撼树，不自量力！",
	  ["$sp_mengguan2"] = "让你见识一下，什么才是天下无双！",
	    --独勇
	  ["sp_duyong"] = "独勇", --独战曹营六将
	  [":sp_duyong"] = "当你的【杀】或【决斗】即将造成伤害时，你可以弃置一张牌，令此伤害+1。",
	  ["$sp_duyong1"] = "汝等纵有万军，也难挡我吕布一人！",
	  ["$sp_duyong2"] = "戟间血未冷，再添马下魂！",
	    --横扫千军
	  ["sp_hengsaoqianjun"] = "横扫千军", --源自于英雄杀吕布的技能
	  ["sp_hengsaoqianjunBUFF"] = "横扫千军",
	  ["sp_hengsaoqianjunbuff"] = "横扫千军",
	  [":sp_hengsaoqianjun"] = "你可以将两张不同颜色的手牌当作【杀】使用或打出；你以此法使用【杀】时，你可以选择一项：\
	  1.伤害+1；\
	  2.额外选择至多两个目标；\
	  3.减1点体力上限，依次执行前两项。",
	  ["sp_hengsaoqianjun:1"] = "此【杀】伤害+1",
	  ["sp_hengsaoqianjun:2"] = "此【杀】额外选择目标",
	  ["sp_hengsaoqianjun:3"] = "减1点体力上限，依次执行前两项",
	  ["@sp_hengsaoqianjunBUFF"] = "你可以为【%src】选择至多两名额外目标",
	  ["$sp_hengsaoqianjunDMG"] = "%from 的 %card 对 %to 造成的伤害+1",
	  ["$sp_hengsaoqianjun1"] = "千钧之势，力贯苍穹！",
	  ["$sp_hengsaoqianjun2"] = "风扫六合，威震八荒！",
	  --袭徐
	["sp_xixu"] = "袭徐", --趁刘备与袁术交战时袭取徐州
	[":sp_xixu"] = "锁定技，当你对体力上限大于你的角色造成伤害后，你加1点体力上限。",
	["$sp_xixu1"] = "乱世天下，唯利当先！",
	["$sp_xixu2"] = "汝为江山，吾为名利！",
	  --阵亡
	["~sp_shenlvbuu"] = "我在修罗炼狱，等着你们！呵呵呵哈哈哈哈......",
	
	--枪神·赵云
	["sp_shenzhaoyun"] = "枪神·赵云",
	["&sp_shenzhaoyun"] = "枪神赵云",
	["#sp_shenzhaoyun"] = "单骑救主",
	["designer:sp_shenzhaoyun"] = "时光流逝FC",
	["cv:sp_shenzhaoyun"] = "官方,暴走大事件MC子龙",
	["illustrator:sp_shenzhaoyun"] = "秋呆呆",
	  --七进
	["sp_qijin"] = "七进", --[七进]七出
	["sp_qijinKey"] = "七进",
	[":sp_qijin"] = "每个回合限一次，你可以减1点体力上限，视为使用一种基本牌或普通锦囊牌。锁定技，回合开始时，若你的体力上限大于1，你减1点体力上限并摸一张牌；回合结束时，若你的体力上限大于1，你减1点体力上限并摸X张牌（X为你减体力上限的次数<font color='red'><b>且至多为4</b></font>）。",
	["sp_qijin_list"] = "七进",
	["sp_qijin_slash"] = "七进",
	["sp_qijin_saveself"] = "七进",
	["canuse_qijin"] = "可使用七进",
	["sp_qichuMHP_Start"] = "",
	["sp_qichuMHP"] = "",
	["sp_qichuMHP_reduse"] = "",
	["$sp_qijin1"] = "乐昌笃实，不屈不挠！",
	["$sp_qijin2"] = "以身报君，不求偷生！",
	  --七出
	["sp_qichu"] = "七出", --七进[七出]
	[":sp_qichu"] = "觉醒技，准备阶段开始时或结束阶段结束时，若你的体力上限为1，你失去技能“七进”，将体力上限重置至与游戏开始时相同并回复<font color='red'><b>1</b></font>点体力，获得技能“单骑”、“孤胆”、“凌云”。",
	["sp_qichuAnimate"] = "image=image/animate/sp_qichu.png",
	["$sp_qichu"] = "单骑救主敌胆寒，常山赵云威名传！",
	    --单骑
	  ["sp_danqi"] = "单骑", --长坂坡单骑救主
	  ["sp_danqi_buffs"] = "单骑",
	  [":sp_danqi"] = "<font color='green'><b>每个回合限【1】次，</b></font>你可以将【1】张（同名）基本牌按以下规则使用或打出：\
	  杀->闪；闪->桃；桃->酒；酒->(普通)杀。\
	  若你以此法使用或打出了：\
	  <font color=\"#00FFFF\">[闪]弃置对方【Y】张牌</font>\
	  <font color='pink'>[桃]令目标摸【Y】张牌</font>\
	  <font color='black'>[酒]伤害加成值+【Y-1】</font>\
	  <font color='red'>[杀]无视防具且伤害值+【Y-1】</font>\
	  Y为你以此法使用或打出的牌数（注：可不选择执行）。",
	  ["canuse_danqi"] = "可使用单骑",
	  --["@sp_danqiJink"] = "单骑-闪",
	  --["@sp_danqiPeach"] = "单骑-桃",
	  --["@sp_danqiAnaleptic"] = "单骑-酒",
	  --["@sp_danqiSlash"] = "单骑-杀",
	  ["$sp_danqi_AnalepticADD"] = "%from 发动“<font color='yellow'><b>单骑</b></font>”将 %card 当作【<font color='yellow'><b>酒</b></font>】使用，此【<font color='yellow'><b>酒</b></font>】伤害加成值 + %arg2",
	  ["$sp_danqi_SlashADD"] = "%from 发动“<font color='yellow'><b>单骑</b></font>”将 %card 当作【<font color='yellow'><b>杀</b></font>】使用，此【<font color='yellow'><b>杀</b></font>】伤害值 + %arg2",
	  ["$sp_danqi_SlashDMG"] = "因为“<font color='yellow'><b>单骑</b></font>”的加成，%from 使用的 %card 对 %to 造成的伤害 + %arg2",
	  ["@sp_lingyunUTA"] = "凌云(增加“单骑”使用次数)",
	  ------------
	    --【闪】
	  ["sp_danqi:jink1"] = "弃置对方1张牌",
	  ["sp_danqi:jink2"] = "弃置对方2张牌",
	  ["sp_danqi:jink3"] = "弃置对方3张牌",
	    --【桃】
	  ["sp_danqi:peach1"] = "令目标摸1张牌",
	  ["sp_danqi:peach2"] = "令目标摸2张牌",
	  ["sp_danqi:peach3"] = "令目标摸3张牌",
	    --【酒】
	  ["sp_danqi:analeptic1"] = "伤害加成值+1",
	  ["sp_danqi:analeptic2"] = "伤害加成值+2",
	    --【杀】
	  ["sp_danqi:slash1"] = "伤害值+1",
	  ["sp_danqi:slash2"] = "伤害值+2",
	  ------------
	  ["$sp_danqi1"] = "龙魂之力，百战皆克！",
	  ["$sp_danqi2"] = "龙游中原，魂魄不息！",
	    --孤胆
	  ["sp_gudan"] = "孤胆", --源自于神赵云皮肤“孤胆救主”
	  [":sp_gudan"] = "锁定技，每当你的体力值变化后，你摸【1】张牌并将【0】张牌交给一名其他角色。",
	  ["sp_gudan:1and0"] = "摸 1 张牌",
	  ["sp_gudan:1and1"] = "摸 1 张牌并将 1 张牌交给一名其他角色",
	  ["sp_gudan:2and0"] = "摸 2 张牌",
	  ["sp_gudan:2and1"] = "摸 2 张牌并将 1 张牌交给一名其他角色",
	  ["@sp_gudan-card"] = "请将你的一张牌交给一名其他角色",
	  ["~sp_gudan"] = "选择一张牌，选择要交给的角色，点【确定】",
	  ["$sp_gudan1"] = "横枪勒马，舍我其谁！",
	  ["$sp_gudan2"] = "枪挑四海，咫尺天涯！",
	    --凌云
	  ["sp_lingyun"] = "凌云", --壮志凌云
	  [":sp_lingyun"] = "在合适的时机下，你可以令“单骑”、“孤胆”描述中“【】”+1直到对应效果结算结束（不可叠加）。若如此做，你减1点体力上限。\
	  <font color='blue'>◆智能操作：出牌阶段，你可以按此按钮，切换为智能操作（不会出现不小心将体力上限扣减为0的失误）/纯人工操作。</font>", --我小高达模仿一下金玉大帝怎么了？:)
	  ["@sp_lingyunAI"] = "智能",
	  ["$sp_lingyun1"] = "破阵御敌，傲然屹立！",
	  ["$sp_lingyun2"] = "平战乱，享太平！",
	  --阵亡
	["~sp_shenzhaoyun"] = "来生，愿再遇主公。",
	
	--暗神·司马
	["sp_shensima"] = "暗神·司马",
	["&sp_shensima"] = "暗神司马",
	["#sp_shensima"] = "政变吞天",
	["designer:sp_shensima"] = "时光流逝FC",
	["cv:sp_shensima"] = "官方",
	["illustrator:sp_shensima"] = "墨三千",
	  --装病
	["sp_zhuangbing"] = "装病", --装病骗曹爽
	["sp_zhuangbingg"] = "装病",
	[":sp_zhuangbing"] = "隐匿技，当你于其他角色的回合登场后，你可以令当前回合角色不能使用或打出手牌直到其回合结束。锁定技，当你登场后，你翻面；若你的武将牌为背面，你不能使用或打出手牌，并防止一切伤害。",
	["sp_zhuangbingLose"] = "",
	["$sp_zhuangbing1"] = "老夫患病在身，恕不见客！",
	["$sp_zhuangbing2"] = "小不忍则乱大谋。",
	  --雄心
	["sp_xiongxin"] = "雄心", --源自于晋司马懿技能名“雄志”
	[":sp_xiongxin"] = "觉醒技，当你的武将牌翻为正面后，你加3点体力上限、回复3点体力并摸三张牌。然后你获得技能“隐忍”、“深谋”、“阴养”。",
	["$sp_xiongxin1"] = "养兵千日，用在一时。",
	["$sp_xiongxin2"] = "天赐良机，岂能逆天而行？",
	    --隐忍
	  ["sp_yinren"] = "隐忍", --隐忍装病等待翻盘曹爽的时机
	  [":sp_yinren"] = "回合开始时，你可以将你的所有手牌扣置于武将牌上并将你的武将牌翻面。",
	  ["$sp_yinren1"] = "忍一时，风平浪静~",
	  ["$sp_yinren2"] = "退一步，海阔天空~",
	    --深谋
	  ["sp_shenmou"] = "深谋", --深谋远虑
	  [":sp_shenmou"] = "出牌阶段限一次，你可以观看牌堆顶的三张牌，获得其中的一张锦囊牌，将其余牌以任意顺序置于牌堆顶。",
	  ["$sp_shenmou1"] = "天之道，轮回也~",
	  ["$sp_shenmou2"] = "顺应天意，得道多助~",
	    --阴养
	  ["sp_yinyang"] = "阴养", --司马懿与其子司马师阴养三千死士
	  ["sp_yinyangSSJQ"] = "阴养",
	  [":sp_yinyang"] = "回合结束时，你可以将一名其他角色的一张牌扣置于其武将牌上，称为“死士”。拥有“死士”的角色造成的伤害视为体力流失，且在其出牌阶段可以失去1点体力并获得所有“死士”牌。",
	  ["sp_ss"] = "死士",
	    ["sp_sishi"] = "死士",
		[":sp_sishi"] = "出牌阶段，你可以失去1点体力，获得所有扣置于你武将牌上的“死士”牌。",
	  ["$sp_yinyang1"] = "是福不是祸，是祸躲不过~",
	  ["$sp_yinyang2"] = "天时不如地利，地利不如人和~",
	  --政变
	["sp_zhengbian"] = "政变", --高平陵事变
	["sp_zhengbianBuff_distance"] = "政变",
	["sp_zhengbianBuff_slashmore"] = "政变",
	["sp_zhengbianClear"] = "政变",
	[":sp_zhengbian"] = "限定技，出牌阶段，你失去技能“装病”、“隐忍”、“深谋”、“阴养”，获得所有你因“隐忍”扣置于你武将牌上的牌，将以此法获得的牌数记录为X。然后你加X点体力上限，选择一名其他角色：直到回合结束，你与其距离-X，你可多对其使用X张【杀】。\
	然后于回合结束时，你获得技能“控局”并获得额外的一个回合。",
	["@sp_zhengbian"] = "政变",
	["sp_zhengbianToDo"] = "请选择一名其他角色作为你发动政变的对象",
	["sp_zhengbianTarget"] = "政变对象",
	["$sp_zhengbian1"] = "一鼓作气，破敌制胜！",
	["$sp_zhengbian2"] = "天要亡你，谁人能救？",
	    --控局
	  ["sp_kongju"] = "控局", --发动事变后掌控曹魏军政大权
	  [":sp_kongju"] = "出牌阶段，你可以减1点体力上限并选择执行一项，或直接随机执行一项：\
	  1、移动场上的一张牌；（若场上没有牌则控局失败，结束出牌阶段）\
	  2、将一名角色的一张手牌背面朝上移交给另一名角色；（若没有角色有手牌则控局失败，结束出牌阶段）\
	  3、废除自己的一个装备栏，令两名角色交换座位；（若你没有装备栏则控局失败，结束出牌阶段）\
	  4、控局失败，结束出牌阶段。",
	  ["lose1MaxHptochosetodo"] = "减1点体力上限并选择执行一项",
	  ["randomtodo"] = "随机执行一项",
	  ["sp_kongju:one"] = "移动场上的一张牌",
	  ["sp_kongju:two"] = "将一名角色的一张手牌背面朝上移交给另一名角色",
	  ["sp_kongju:three"] = "废除一个装备栏，令两名角色交换座位",
	  ["sp_kongju:fail"] = "控局失败，结束出牌阶段",
	  ["sp_kongjuOne"] = "请选择一名场上区域里有牌的角色",
	  ["@sp_kongjuOne-to"]  = "请选择移动的目标角色",
	  ["sp_kongjuTwoF"] = "请选择一名有手牌的角色",
	  ["sp_kongjuTwoT"] = "请选择移交手牌的目标角色",
	  ["sp_kongju:0"] = "废除武器栏",
	  ["sp_kongju:1"] = "废除防具栏",
	  ["sp_kongju:2"] = "废除+1马栏",
	  ["sp_kongju:3"] = "废除-1马栏",
	  ["sp_kongju:4"] = "废除宝物栏",
	  ["sp_kongjuThreeOne"] = "请选择要交换座位的其中一名角色",
	  ["sp_kongjuThreeTwo"] = "请选择另一名角色",
	  ["$sp_kongjuFail"] = "%from 控局失败，结束出牌阶段",
	  ["$sp_kongju1"] = "老夫需再做权衡。",
	  ["$sp_kongju2"] = "用兵勿要弄险，细节决定成败！",
	  --吞天
	["sp_tuntian"] = "吞天", --司马家族的狼子野心
	[":sp_tuntian"] = "锁定技，你每杀死一名角色，加1点体力上限。",
	["sp_tuntian_kill"] = "",
	["$sp_tuntian1"] = "受命于天，既寿永昌！",
	["$sp_tuntian2"] = "老夫即是天命！",
	  --阵亡
	["~sp_shensima"] = "鼎足三分已成梦，一切，都结束了......",
	
	--剑神·刘备
	["sp_shenliubei"] = "剑神·刘备",
	["&sp_shenliubei"] = "剑神刘备",
	["#sp_shenliubei"] = "刘郎才气", --求田问舍，怕应羞见，刘郎才气
	["designer:sp_shenliubei"] = "时光流逝FC",
	["cv:sp_shenliubei"] = "官方",
	["illustrator:sp_shenliubei"] = "时空立方",
	  --英杰
	["sp_yingjie"] = "英杰", --忠胆英杰（bushi
	[":sp_yingjie"] = "转换技，①行侠：你每使用一张牌，可以令一名角色随机摸1~3张牌；②仗义：你每使用一张牌，可以交给一名其他角色一张牌，然后随机回复0~1点体力。",
	[":sp_yingjie1"] = "转换技，①行侠：你每使用一张牌，可以令一名角色随机摸1~3张牌；<font color=\"#01A5AF\"><s>②仗义：你每使用一张牌，可以交给一名其他角色一张牌，然后随机回复0~1点体力</s></font>。",
	[":sp_yingjie2"] = "转换技，<font color=\"#01A5AF\"><s>①行侠：你每使用一张牌，可以令一名角色随机摸1~3张牌</s></font>；②仗义：你每使用一张牌，可以交给一名其他角色一张牌，然后随机回复0~1点体力。",
	["@sp_yingjie-xingxia"] = "[英杰]行侠",
	["sp_yingjie-invoke"] = "选择一名角色，令其摸牌",
	["@sp_yingjie-zhangyi"] = "[英杰]仗义",
	["@sp_yingjie-card"] = "选择一名角色，交给其一张牌",
	["$sp_yingjie1"] = "备，愿结交天下豪杰！",
	["$sp_yingjie2"] = "得人心者，得天下！",
	  --远志
	["sp_yuanzhi"] = "远志", --远大的志向
	["sp_yuanzhiExtra"] = "远志",
	[":sp_yuanzhi"] = "<font color='green'><b>出牌阶段限X次，</b></font>（X>=0且X初始值为1）你可以与一名其他角色拼点。若你赢，你摸一张牌并令X+1；若你没赢，你选择一项：弃置Y张牌并令X-1(Y为你<font color='red'><b>本局累计</b></font>以此法拼点没赢的次数)，或将X归0直到下回合的出牌阶段结束，将X重置为1。",
	["sp_yuanzhiFQC"] = "远志次数",
	["sp_yuanzhiUF"] = "",
	["sp_yuanzhi:1"] = "弃置牌并令“远志”的出牌阶段可使用次数-1（提示：注意不要让可使用次数永久为0）",
	["sp_yuanzhi:2"] = "将“远志”的出牌阶段可使用次数归0（于下回合的出牌阶段结束再将次数重置为1）",
	["sp_yuanzhiFail"] = "",
	["sp_yuanzhiTR"] = "",
	["$sp_yuanzhi1"] = "举大事者，必以民为本！",
	["$sp_yuanzhi2"] = "建功立业，正在此时！",
	  --戎马
	["sp_rongma"] = "戎马", --刘备戎马一生，终于白帝城
	[":sp_rongma"] = "锁定技，你每造成/受到一次伤害或摸一次牌时，获得1枚“戎马”标记。当你的“戎马”标记累计达到：10枚，你令“远志”中的X+2；20枚，你摸三张牌；30枚，你加1点体力上限并回复1点体力；40枚，你死亡。",
	["sp_rongmaTrigger"] = "",
	--[[（暂无语音）
	["$sp_rongma1"] = "", --10枚
	["$sp_rongma2"] = "", --20枚
	["$sp_rongma3"] = "", --30枚
	]]
	  --阵亡
	["~sp_shenliubei"] = "夷陵之火，焚尽了我一生心力......",
	
	--军神·陆逊
	["sp_shenluxun"] = "军神·陆逊",
	["&sp_shenluxun"] = "军神陆逊",
	["#sp_shenluxun"] = "火烧连营",
	["designer:sp_shenluxun"] = "时光流逝FC",
	["cv:sp_shenluxun"] = "官方",
	["illustrator:sp_shenluxun"] = "木美人",
	  --燥炎
	["sp_zaoyan"] = "燥炎", --陆逊沉住气并以逸待劳，抓住酷暑季节蜀军斗志涣散松懈的时机（技能内容灵感源自于极略三国神陆逊的技能“劫焰”）
	["sp_zaoyanTime"] = "燥炎",
	[":sp_zaoyan"] = "转换技，<font color='green'><b>剩余可用X次，</b></font>①当一名角色成为红色【杀】或红色普通锦囊牌的唯一目标时，你可以摸一张牌并弃置一张红色牌。若如此做，取消之，改为该角色受到此牌使用者的1点火焰伤害；②当一名角色成为黑色【杀】或黑色普通锦囊牌的唯一目标时，你可以弃置一张黑色牌并摸一张牌。若如此做，取消之，改为该角色失去1点体力。（X初始为1且至多为4；每名角色的回合结束后，X加1）",
	[":sp_zaoyan1"] = "转换技，<font color='green'><b>剩余可用X次，</b></font>①当一名角色成为红色【杀】或红色普通锦囊牌的唯一目标时，你可以摸一张牌并弃置一张红色牌。若如此做，取消之，改为该角色受到此牌使用者的1点火焰伤害；<font color=\"#01A5AF\"><s>②当一名角色成为黑色【杀】或黑色普通锦囊牌的唯一目标时，你可以弃置一张黑色牌并摸一张牌。若如此做，取消之，改为该角色失去1点体力</s></font>。（X初始为1且至多为4；每名角色的回合结束后，X加1）",
	[":sp_zaoyan2"] = "转换技，<font color='green'><b>剩余可用X次，</b></font><font color=\"#01A5AF\"><s>①当一名角色成为红色【杀】或红色普通锦囊牌的唯一目标时，你可以摸一张牌并弃置一张红色牌。若如此做，取消之，改为该角色受到此牌使用者的1点火焰伤害</s></font>；②当一名角色成为黑色【杀】或黑色普通锦囊牌的唯一目标时，你可以弃置一张黑色牌并摸一张牌。若如此做，取消之，改为该角色失去1点体力。（X初始为1且至多为4；每名角色的回合结束后，X加1）",
	["sp_zaoyanLast"] = "燥炎剩余",
	["@sp_zaoyan-yang"] = "燥炎[阳]",
	["@sp_zaoyan-red"] = "请弃置一张红色牌",
	["@sp_zaoyan-yin"] = "燥炎[阴]",
	["@sp_zaoyan-black"] = "请弃置一张黑色牌",
	["$sp_zaoyan1"] = "摧敌军阵，克敌锋锐。", --阳
	["$sp_zaoyan2"] = "动敌阵，乱敌心，此战已胜。", --阴
	["$sp_zaoyan3"] = "三军用备，吾有何忧？", --增加次数
	  --焚营
	["sp_fenying"] = "焚营", --火烧连营七百里（技能名同极略三国神陆逊）
	[":sp_fenying"] = "限定技，当一名角色即将受到火焰伤害时，你可以弃置任意张手牌令等量的角色横置（若其已横置，则重置之），然后弃置Y张装备区里的牌令该伤害翻倍。若如此做，你移除所有“燥炎”剩余可使用次数并摸等同于以此法移除的“燥炎”剩余可使用次数的牌。（Y为该角色即将受到的伤害值）",
	["@sp_fenying"] = "焚营",
	["@sp_fenying-card"] = "你可以发动技能“焚营”",
	["~sp_fenying"] = "选择任意张手牌并选择等量的角色，点【确定】",
	["$sp_fenyingDMG"] = "%from 发动了“<font color='yellow'><b>焚营</b></font>”，%to 受到的火焰伤害由 %arg 点翻倍为 %arg2 点",
	["$sp_fenying1"] = "业火绽放，敌营尽焚！",
	["$sp_fenying2"] = "这红莲，为大吴的胜利而绽放！",
	  --阵亡
	["~sp_shenluxun"] = "虽大败蜀军，却未能破孔明之策吗......",
	
	--孤神·张辽
	["sp_shenzhangliao"] = "孤神·张辽",
	["&sp_shenzhangliao"] = "孤神张辽",
	["#sp_shenzhangliao"] = "白狼声,逍遥名",
	["designer:sp_shenzhangliao"] = "时光流逝FC",
	["cv:sp_shenzhangliao"] = "官方",
	["illustrator:sp_shenzhangliao"] = "云涯",
	  --强袭
	["sp_qiangxi"] = "强袭", --三国志12张辽战法
	["sp_qiangxiAct"] = "强袭",
	[":sp_qiangxi"] = "摸牌阶段，你可以少摸任意张牌，获得等量的其他角色的各一张<font color='red'><b>牌</b></font>并各造成1点伤害。",
	["@sp_qiangxi-card"] = "你可以发动“强袭”，选择至多 %arg 名其他角色",
	["~sp_qiangxi"] = "选择合法数量内的其他角色→点击【确定】",
	["$sp_qiangxi1"] = "八百虎贲踏江去，十万吴兵丧胆还！",
	["$sp_qiangxi2"] = "虎啸逍遥震千里，江东碧眼犹梦惊！",
	  --辽来
	["sp_liaolai"] = "辽来", --（在东吴）用来吓小孩不哭的用语
	[":sp_liaolai"] = "锁定技，当你对“吴”势力角色造成伤害时，若：1.你的体力值小于其；2.你的手牌数小于其，每满足一项，此伤害就+1。",
	["$sp_liaolai1"] = "敌无心恋战，亦无力嚎哭乎？",
	["$sp_liaolai2"] = "定教吴儿，闻名止啼！",
	  --阵亡
	["~sp_shenzhangliao"] = "不擒碧眼儿，岂能罢休！......",
	
	--奇神·甘宁
	["sp_shenganning"] = "奇神·甘宁",
	["&sp_shenganning"] = "奇神甘宁",
	["#sp_shenganning"] = "蚀灵的神鸦",
	["designer:sp_shenganning"] = "时光流逝FC",
	["cv:sp_shenganning"] = "官方",
	["illustrator:sp_shenganning"] = "未知",
	  --掠阵
	["sp_lvezhen"] = "掠阵", --同极略三国神甘宁的技能名
	["sp_lvezhenFQC_Clear"] = "掠阵",
	["sp_lvezhen_SSQY"] = "掠阵",
	["sp_lvezhen_GHCQ"] = "掠阵",
	["sp_lvezhen_SSQY_moredistance"] = "掠阵",
	["sp_lvezhen_SkillCardBuff"] = "掠阵",
	[":sp_lvezhen"] = "转换技，<font color='green'><b>出牌阶段限两次，</b></font>①你可以废除一个装备栏，将一张红色牌当作使用距离+1的【顺手牵羊】使用，然后于结算结束后获得目标的一张手牌；②你可以废除一个装备栏，将一张黑色牌当作可选择目标+1的【过河拆桥】使用，然后于结算结束后弃置目标区域里的一张牌。",
	[":sp_lvezhen1"] = "转换技，<font color='green'><b>出牌阶段限两次，</b></font>①你可以废除一个装备栏，将一张红色牌当作使用距离+1的【顺手牵羊】使用，然后于结算结束后获得目标的一张手牌；<font color=\"#01A5AF\"><s>②你可以废除一个装备栏，将一张黑色牌当作可选择目标+1的【过河拆桥】使用，然后于结算结束后弃置目标区域里的一张牌</s></font>。",
	[":sp_lvezhen2"] = "转换技，<font color='green'><b>出牌阶段限两次，</b></font><font color=\"#01A5AF\"><s>①你可以废除一个装备栏，将一张红色牌当作使用距离+1的【顺手牵羊】使用，然后于结算结束后获得目标的一张手牌</s></font>；②你可以废除一个装备栏，将一张黑色牌当作可选择目标+1的【过河拆桥】使用，然后于结算结束后弃置目标区域里的一张牌。",
	["sp_lvezhen:0"] = "废除武器栏",
	["sp_lvezhen:1"] = "废除防具栏",
	["sp_lvezhen:2"] = "废除+1马栏",
	["sp_lvezhen:3"] = "废除-1马栏",
	["sp_lvezhen:4"] = "废除宝物栏",
	["sp_lvezhenFQC"] = "",
	["@sp_lvezhen_SSQY-yang"] = "请将你的一张红色牌当作【顺手牵羊】使用（可使用距离+1）",
	["@sp_lvezhen_GHCQ-yin"] = "请将你的一张黑色牌当作【过河拆桥】使用（可选择目标+1）",
	["@sp_lvezhen_SkillCardBuff"] = "你可以为【%src】选择一名额外目标",
	["$sp_lvezhen1"] = "战胜群敌，展江东豪杰之魄！",
	["$sp_lvezhen2"] = "此次进击，定要丧敌胆魄！",
	  --袭营
	["sp_xiying"] = "袭营", --百骑劫曹营
	["sp_xiyingSettle"] = "袭营",
	[":sp_xiying"] = "限定技，出牌阶段，你弃置所有手牌，获得一名其他角色的所有手牌，然后你与其距离视为1直到回合结束。回合结束时，其获得你所有手牌，然后你摸X张牌（X为你从发动此技能至回合结束对其造成的伤害值）。",
	["@sp_xiying"] = "袭营",
	["sp_xiyingTarget"] = "被袭营",
	["sp_xiyingDMG"] = "袭营伤害",
	["$sp_xiying1"] = "劫敌营寨，以破其胆！",
	["$sp_xiying2"] = "百骑劫魏营，功震天下英！",
	  --神鸦
	["sp_shenya"] = "神鸦", --神鸦能显圣，香火永千秋
	[":sp_shenya"] = "锁定技，回合结束时，若你于本回合造成了伤害，你恢复一个装备栏；杀死你的角色不执行奖惩。",
	["sp_shenya:0"] = "恢复武器栏",
	["sp_shenya:1"] = "恢复防具栏",
	["sp_shenya:2"] = "恢复+1马栏",
	["sp_shenya:3"] = "恢复-1马栏",
	["sp_shenya:4"] = "恢复宝物栏",
	["$sp_shenya"] = "（群鸦齐鸣）",
	  --阵亡
	["~sp_shenganning"] = "神鸦不佑，此身竟陨......",
	
	--==DIY界限突破==--
	--界刘繇
	["fcj_liuyao"] = "界刘繇",
	["#fcj_liuyao"] = "雨凄悲流",
	["designer:fcj_liuyao"] = "时光流逝FC",
	["cv:fcj_liuyao"] = "官方",
	["illustrator:fcj_liuyao"] = "DH",
	  --戡难
	["fcj_kannan"] = "戡难",
	["fcj_kannanCard"] = "“戡难”拼点",
	["fcj_kannanBUFF"] = "戡难",
	[":fcj_kannan"] = "出牌阶段，若你于此阶段内发动过此技能的次数<font color='red'><b>不大于</b></font>X（X为你的体力值），你可与你于此阶段内未以此法拼点过的一名其他角色拼点。" ..
						"若：你赢，你使用的下一张<font color='red'><b>造成伤害的</b></font>【杀】伤害+1；其赢，其使用的下一张<font color='red'><b>造成伤害的</b></font>【杀】伤害+1。" ..
						"<font color='red'><b>然后你选择一项：1.摸一张牌；2.此次发动此技能不计入次数；3.视为此阶段内未与该角色以此法拼点。</b></font>",
	["fcj_kannanUsed"] = "",
	["fcj_kannan:1"] = "摸一张牌",
	["fcj_kannan:2"] = "此次发动此技能不计入次数",
	["fcj_kannan:3"] = "视为此阶段内未与该角色以此法拼点",
	["$fcj_kannan1"] = "避公明谋乱，逐公明心腹。",
	["$fcj_kannan2"] = "权贵争斗，吾只求戡难。",
	  --阵亡
	["~fcj_liuyao"] = "固守一方，果不是长久之法......",
	
	--界庞德公
	["fcj_pangdegong"] = "界庞德公",
	["#fcj_pangdegong"] = "超脱于世",
	["designer:fcj_pangdegong"] = "时光流逝FC",
	["cv:fcj_pangdegong"] = "官方",
	["illustrator:fcj_pangdegong"] = "JanusLausDeo",
	  --评才
	["fcj_pingcai"] = "评才",
	["fcj_pingcaiIDO"] = "评才",
	[":fcj_pingcai"] = "出牌阶段限一次，你可以挑选一个宝物，并根据宝物类型执行对应的效果：\
	<font color='red'><b>[卧龙]</b></font>对至多<font color='red'><b>两</b></font>名角色各造成1点火焰伤害。（因缘人物：卧龙诸葛亮）\
	<font color='orange'><b>[凤雏]</b></font>让至多<font color='red'><b>四</b></font>名角色进入连环状态。（因缘人物：庞统）\
	<font color=\"#00FFFF\"><b>[水镜]</b></font>将一名角色装备区内的<font color='red'><b>一张牌</b></font>移动到另一名角色的相应位置。（因缘人物：司马徽）\
	<font color=\"#4DB873\"><b>[玄剑]</b></font>令一名角色摸一张牌并回复1点体力，<font color='red'><b>然后你摸一张牌。</b></font>（因缘人物：徐庶）\
	<font color='red'><b>执行一次相应效果后，若场上有存活的对应“因缘人物”，则可以再执行一次对应效果。</b></font>",
	["@fcj_pingcai-ChooseTreasure"] = "请挑选一个宝物",
	["@fcj_pingcai-ChooseTreasure:wolong"] = "卧龙",
	["$fcj_pingcai-ChooseTreasure_wolong"] = "%from 选择了宝物【<font color='red'><b>东官苍龙·卧龙</b></font>】",
	["@fcj_pingcai-ChooseTreasure:fengchu"] = "凤雏",
	["$fcj_pingcai-ChooseTreasure_fengchu"] = "%from 选择了宝物【<font color='orange'><b>南官朱雀·凤雏</b></font>】",
	["@fcj_pingcai-ChooseTreasure:shuijing"] = "水镜",
	["$fcj_pingcai-ChooseTreasure_shuijing"] = "%from 选择了宝物【<font color=\"#00FFFF\"><b>北官玄武·水镜</b></font>】",
	["@fcj_pingcai-ChooseTreasure:xuanjian"] = "玄剑",
	["$fcj_pingcai-ChooseTreasure_xuanjian"] = "%from 选择了宝物【<font color=\"#4DB873\"><b>西官白虎·玄剑</b></font>】",
	["fcj_pingcaiRXJ"] = "",
	["$fcj_pingcai1"] = "时值乱世，当出奇才。", --开始评价
	    --卧龙
	  ["$fcj_pingcai2"] = "东官苍龙，动则烈火焚天。", --卧龙
	  ["fcj_pingcaiWolong"] = "评才-卧龙",
	  ["fcj_pingcaiwolong"] = "评才-卧龙",
	  ["@fcj_pingcaiWolong-card"] = "你可以选择至多两名角色，对他们各造成1点火焰伤害",
	  ["$fcj_pingcaiWolong"] = "因为场上有因缘人物 %to 存活，%from 可以再发动一次宝物【<font color='red'><b>东官苍龙·卧龙</b></font>】的效果",
	    --凤雏
	  ["$fcj_pingcai3"] = "南官朱雀，舞则人间血海。", --凤雏
	  ["fcj_pingcaiFengchu"] = "评才-凤雏",
	  ["fcj_pingcaifengchu"] = "评才-凤雏",
	  ["@fcj_pingcaiFengchu-card"] = "你可以横置至多四名角色",
	  ["$fcj_pingcaiFengchu"] = "因为场上有因缘人物 %to 存活，%from 可以再发动一次宝物【<font color='orange'><b>南官朱雀·凤雏</b></font>】的效果",
	    --水镜
	  ["$fcj_pingcai4"] = "北官玄武，伏则隐士于野。", --水镜
	  ["fcj_pingcaiShuijing"] = "评才-水镜",
	  ["fcj_pingcaishuijing"] = "评才-水镜",
	  ["@fcj_pingcaiShuijing-card"] = "你可以将场上装备区的一张牌移动到另一个合法位置",
	  ["@fcj_pingcaiShuijing_Equip-to"]  = "请选择移动的目标角色",
	  ["$fcj_pingcaiShuijing"] = "因为场上有因缘人物 %to 存活，%from 可以再发动一次宝物【<font color=\"#00FFFF\"><b>北官玄武·水镜</b></font>】的效果",
	    --玄剑
	  ["$fcj_pingcai5"] = "西官白虎，出则平乱济世。", --玄剑
	  ["fcj_pingcaiXuanjian"] = "评才-玄剑",
	  ["fcj_pingcaixuanjian"] = "评才-玄剑",
	  ["@fcj_pingcaiXuanjian-card"] = "你可以令一名角色摸一张牌并回复1点体力",
	  ["~fcj_pingcaiXuanjian"] = "然后你也可以摸一张牌",
	  ["$fcj_pingcaiXuanjian"] = "因为场上有因缘人物 %to 存活，%from 可以再发动一次宝物【<font color=\"#4DB873\"><b>西官白虎·玄剑</b></font>】的效果",
	  --隐世（同原版）
	  --阵亡
	["~fcj_pangdegong"] = "身处乱世，还是当效仿戒子之道......",
	
	--界陈到
	["fcj_chendao"] = "界陈到",
	["#fcj_chendao"] = "忠勇敢战",
	["designer:fcj_chendao"] = "时光流逝FC",
	["cv:fcj_chendao"] = "官方",
	["illustrator:fcj_chendao"] = "梦回唐朝·久吉",
	  --往烈
	["fcj_wanglie"] = "往烈",
	["fcj_wanglieSecondCard"] = "往烈",
	["fcj_wanglieAnaleptic"] = "往烈",
	[":fcj_wanglie"] = "出牌阶段，你使用的第一张牌<font color='red'><b>不计入次数限制</b></font>、<font color='red'><b>第二张牌无距离限制</b></font>。当你于出牌阶段使用一张牌时，" ..
	"你可令此牌：1.不能被响应；<font color='red'><b>2.伤害+1；3.[背水]依次执行前两项，若如此做，此阶段你不能再使用牌。（每个出牌阶段每项各限选择一次）</b></font>",
	["fcj_wanglieFQC"] = "",
	["fcj_wanglie:Hit"] = "令此牌不能被响应",
	["fcj_wanglie:Damage"] = "令此牌伤害+1",
	["fcj_wanglie:Beishui"] = "[背水]依次执行前两项(强命+加伤)，此阶段不能再使用牌",
	["$fcj_wanglie1"] = "精锐之师，何人能挡？",
	["$fcj_wanglie2"] = "击敌百里，一往无前！",
	  --阵亡
	["~fcj_chendao"] = "由来征战地，不见有人还......",
	
	--界赵统赵广
	["fcj_zhaotongzhaoguang"] = "界赵统赵广",
	["#fcj_zhaotongzhaoguang"] = "子承父业",
	["designer:fcj_zhaotongzhaoguang"] = "时光流逝FC",
	["cv:fcj_zhaotongzhaoguang"] = "官方",
	["illustrator:fcj_zhaotongzhaoguang"] = "云涯",
	  --翊赞、龙渊（同手杀原版）
	  --云兴
	["fcj_yunxing"] = "云兴", --<font color='red'><b>云兴</b></font>",
	[":fcj_yunxing"] = "<font color='red'><b>游戏开始时，你从牌堆随机获得一张基本牌和一张武器牌。回合开始时/回合结束时，你从牌堆随机获得X/Y张基本牌。（X为你上轮回合外发动“翊赞”的次数；Y为你本回合发动“翊赞”的次数）</b></font>",
	["$fcj_yunxing1"] = "我们兄弟齐心合力，也能和父亲一样！", --这一切，都是为了护佑大汉！
	["$fcj_yunxing2"] = "是时候让敌人见识赵家真正的本领了！", --我们的武艺，已经足够精进了！
	  --阵亡
	["~fcj_zhaotongzhaoguang"] = "可惜，看不到伯约大人成功了......",
	
	--界于禁-旧
	["fcj_yujin_old"] = "界于禁-旧",
	["&fcj_yujin_old"] = "界于禁",
	["#fcj_yujin_old"] = "魏武之强", --三国志12曹操：？
	["designer:fcj_yujin_old"] = "时光流逝FC",
	["cv:fcj_yujin_old"] = "官方",
	["illustrator:fcj_yujin_old"] = "XXX", --难道画师真的是叫这个名字
	  --毅重
	["fcj_yizhong"] = "毅重",
	["fcj_yizhongLS"] = "毅重",
	[":fcj_yizhong"] = "锁定技，<font color='blue'><s>若你的装备区里没有防具牌，</s></font>黑色【杀】对你无效；<font color='black'><b>你的黑色【杀】不可被响应。" ..
	"结束阶段开始时，你可以弃置一张黑色牌，令一名其他角色获得此技能直到其下回合结束。</b></font>",
	["@fcj_yizhong-invoke"] = "请弃置一张黑色牌",
	["@fcj_yizhong-choose"] = "请选择一名其他角色，令其获得“毅重”直到其下回合结束",
	["$fcj_yizhong1"] = "有我坐镇，岂会有所差池！",
	["$fcj_yizhong2"] = "持军严整，镇威御敌！",
	  --阵亡
	["~fcj_yujin_old"] = "若不降蜀，此节可保......",
	
	--界曹昂
	["fcj_caoang"] = "界曹昂",
	["#fcj_caoang"] = "竭战鳞伤",
	["designer:fcj_caoang"] = "时光流逝FC",
	["cv:fcj_caoang"] = "官方",
	["illustrator:fcj_caoang"] = "tswck",
	  --慷忾
	["fcj_kangkai"] = "慷忾",
	[":fcj_kangkai"] = "每当一名距离<font color='red'><b>X</b></font>以内的角色成为<font color='red'><b>伤害类卡牌</b></font>的目标后<font color='red'><b>（X为1；若该牌为【杀】，则改为2）</b></font>，" ..
	"你可以摸一张牌，然后正面朝上交给该角色<font color='red'><b>(注:若交给自己则改为展示之)</b></font>一张牌：<font color='red'><b>若此牌为基本牌或【无懈可击】，你可以令该角色摸一张牌；否则该角色可以使用之。</b></font>",
	["@fcj_kangkai-give"] = "请选择一张牌交给 %src",
	["fcj_kangkai_hedraw"] = "[慷忾]令其摸一张牌",
	["fcj_kangkai_use:use"] = "[慷忾]你是否要使用这张交给你的牌？<br/>\
	注：点【确定】->可以使用这张牌<br/>\
	点【取消】->不使用这张牌",
	["@fcj_kangkai_ut"] = "你可以使用这张【<font color='yellow'><b>%src</b></font>】",
	["$fcj_kangkai1"] = "能与典将军一同杀敌，实在痛快！",
	["$fcj_kangkai2"] = "岂能让尔等轻易得逞？",
	  --阵亡
	["~fcj_caoang"] = "典将军，还请...保护好父亲......",
	
	--界吕岱
	["fcj_lvdai"] = "界吕岱",
	["#fcj_lvdai"] = "交趾震威",
	["designer:fcj_lvdai"] = "时光流逝FC",
	["cv:fcj_lvdai"] = "官方",
	["illustrator:fcj_lvdai"] = "福州光域",
	  --勤国
	["fcj_qinguo"] = "勤国",
	[":fcj_qinguo"] = "当你<font color='blue'><s>于回合内</s></font>使用装备牌结算结束后，你可视为使用一张<font color='red'><b>无距离限制且</b></font>不计次的【杀】。" ..
	"当你装备区里的牌移动后或有装备牌移至你的装备区后，若你装备区里的牌数：1.与你的体力值相等；2.与此次移动之前你装备区里的牌数不等，" ..
	"<font color='red'><b>每满足一项，</b></font>你回复1点体力<font color='red'><b>并摸一张牌</b></font>。",
	["@fcj_qinguo-slash"] = "你可以视为使用一张无距离限制且不计次的【杀】",
	["~fcj_qinguo"] = "选择一名可被选择的目标角色，点【确定】",
	["$fcj_qinguo1"] = "戮力奉公，勤心侍国！",
	["$fcj_qinguo2"] = "忠心为国，有国奉公！",
	  --阵亡
	["~fcj_lvdai"] = "我..还想守护这山河......",
	
	--界陆抗
	["fcj_lukang"] = "界陆抗",
	["#fcj_lukang"] = "毁堰破晋",
	["designer:fcj_lukang"] = "时光流逝FC",
	["cv:fcj_lukang"] = "官方",
	["illustrator:fcj_lukang"] = "第七个桔子",
	  --谦节（同原版）
	  --决堰
	["fcj_jueyan"] = "决堰",
	["fcj_jueyanWeapon"] = "决堰",
	["fcj_jueyanArmor"] = "决堰",
	["fcj_jueyanHorse"] = "决堰",
	[":fcj_jueyan"] = "出牌阶段<font color='blue'><s>限一次</s></font>，你可以废除你装备区里的一个装备栏，然后执行对应的一项：\
	武器栏，本回合你可以多使用三张【杀】；\
	防具栏，摸三张牌，本回合你的手牌上限+3；\
	两个坐骑栏，本回合你使用牌无距离限制；\
	宝物栏，本回合你视为拥有“<font color='red'><b>界</b></font>集智”。",
	["fcj_jueyan0"] = "武器栏",
	["fcj_jueyan1"] = "防具栏",
	["fcj_jueyan2"] = "两个坐骑栏",
	["fcj_jueyan4"] = "宝物栏",
	["$fcj_jueyan-0"] = "%from 发动“<font color='yellow'><b>决堰</b></font>”废除了 <font color='red'><b>武器栏</b></font> ，本回合可以多使用三张【<font color='yellow'><b>杀</b></font>】",
	["$fcj_jueyan-1"] = "%from 发动“<font color='yellow'><b>决堰</b></font>”废除了 <font color='red'><b>防具栏</b></font> ，本回合手牌上限+3",
	["$fcj_jueyan-2"] = "%from 发动“<font color='yellow'><b>决堰</b></font>”废除了 <font color='red'><b>两个坐骑栏</b></font> ，本回合使用牌无距离限制",
	["$fcj_jueyan-4"] = "%from 发动“<font color='yellow'><b>决堰</b></font>”废除了 <font color='red'><b>宝物栏</b></font> ，本回合视为拥有“<font color='yellow'><b>集智</b></font>”",
	["$fcj_jueyan1"] = "毁堰废坝，阻晋军粮道。",
	["$fcj_jueyan2"] = "吾已毁堰阻碍，晋军有计也难施！",
	  --破势
	["fcj_poshi"] = "破势",
	[":fcj_poshi"] = "觉醒技，准备阶段<font color='red'>开始时</font>，若你的装备栏均被废除或体力值为1，你减1点体力上限，然后将手牌补至<font color='red'><b>X（X为你的体力上限+你未被废除的装备栏数）</b></font>，失去技能“决堰”并获得技能“怀柔”。",
	["$fcj_poshi1"] = "良谋益策，破敌腹背。",
	["$fcj_poshi2"] = "破晋军雄威，断敌心谋略！",
	    --怀柔
	  ["ps_huairou"] = "怀柔",
	  ["ps_huairou_qicai"] = "怀柔",
	  ["ps_huairouEnd"] = "怀柔",
	  [":ps_huairou"] = "出牌阶段，你可以重铸装备牌，<font color='red'><b>若如此做，此阶段你的攻击范围+1。</b></font>",
	  ["$ps_huairou1"] = "一邑一乡，不可以无信义。",
	  ["$ps_huairou2"] = "彼专为德我专为暴，是不战而自服也！",
	  --阵亡
	["~fcj_lukang"] = "唉，陛下不听，社稷恐有危难......",
	
	--界麹义
	
	--界司马徽
	
	--界马良
	
	--界马忠
	
}
return {extension, xiangyuEquip, extension_G, extension_J}