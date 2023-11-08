extension = sgs.Package("mobileRealDynamicSkin", sgs.Package_GeneralPack)

--==登场动画==--（设置成仅作为主将可以触发，避免与其他动皮武将双将时的动画冲突）
mrds_ComeOnStage = sgs.CreateTriggerSkill{
	name = "mrds_ComeOnStage",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		--神甘宁（万人辟易）
		if player:getGeneralName() == "mrds_shenganning" then
			room:setEmotion(player, "MRDS/mrds_shenganning/mrds_shenganning_cos")
		--界徐盛（破军杀将）
		elseif player:getGeneralName() == "mrds_jiexusheng" then
			room:setEmotion(player, "MRDS/mrds_jiexusheng/mrds_jiexusheng_cos")
		--神赵云（战龙在野）
		elseif player:getGeneralName() == "mrds_shenzhaoyun" then
			room:setEmotion(player, "MRDS/mrds_shenzhaoyun/mrds_shenzhaoyun_cos")
		--界关羽（啸风从龙）
		elseif player:getGeneralName() == "mrds_jieguanyu" then
			room:setEmotion(player, "MRDS/mrds_jieguanyu/mrds_jieguanyu_cos")
		--界李儒（鸩杀少帝）
		elseif player:getGeneralName() == "mrds_jieliru" then
			room:setEmotion(player, "MRDS/mrds_jieliru/mrds_jieliru_cos")
		--留赞（灵魂歌王）
		
		--......
		end
	end,
	can_trigger = function(self, player)
		return player:getGeneralName() == "mrds_shenganning" or player:getGeneralName() == "mrds_jiexusheng"
		or player:getGeneralName() == "mrds_shenzhaoyun" or player:getGeneralName() == "mrds_jieguanyu"
		or player:getGeneralName() == "mrds_jieliru"
	end,
}
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("mrds_ComeOnStage") then skills:append(mrds_ComeOnStage) end
--==技能发动动画==--（已写进武将技能里）
--[[mrds_SkillInvoke = sgs.CreateTriggerSkill{
	name = "mrds_SkillInvoke",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end,
}
if not sgs.Sanguosha:getSkill("mrds_SkillInvoke") then skills:append(mrds_SkillInvoke) end]]
--==攻击特效==--（设置成仅作为主将可以触发，避免与其他动皮武将双将时的动画冲突）
mrds_Attack = sgs.CreateTriggerSkill{
	name = "mrds_Attack",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if (use.card:isKindOf("Slash") or use.card:isKindOf("Duel") or use.card:isKindOf("AOE"))
		and use.from:objectName() == player:objectName() then
			--神甘宁（万人辟易）
			if player:getGeneralName() == "mrds_shenganning" then
				room:broadcastSkillInvoke(self:objectName(), 1)
				room:setEmotion(player, "MRDS/mrds_shenganning/mrds_shenganning_atk")
				room:getThread():delay(1000)
			--界徐盛（破军杀将）
			elseif player:getGeneralName() == "mrds_jiexusheng" then
				room:broadcastSkillInvoke(self:objectName(), 2)
				room:setEmotion(player, "MRDS/mrds_jiexusheng/mrds_jiexusheng_atk")
				if use.card:isKindOf("Slash") then room:getThread():delay(3000)
				else room:getThread():delay(1000) end
			--神赵云（战龙在野）
			elseif player:getGeneralName() == "mrds_shenzhaoyun" then
				room:broadcastSkillInvoke(self:objectName(), 3)
				room:setEmotion(player, "MRDS/mrds_shenzhaoyun/mrds_shenzhaoyun_atk")
				if use.card:isKindOf("Slash") and (use.card:getSkillName() == "mrds_longhun" or use.card:getSkillName() == "mrds_longhunBuff") then room:getThread():delay(2700)
				else room:getThread():delay(1000) end
			--界关羽（啸风从龙）
			elseif player:getGeneralName() == "mrds_jieguanyu" then
				room:broadcastSkillInvoke(self:objectName(), 4)
				room:setEmotion(player, "MRDS/mrds_jieguanyu/mrds_jieguanyu_atk")
				if use.card:isKindOf("Slash") and use.card:getSkillName() == "mrds_wusheng" then room:getThread():delay(2400)
				else room:getThread():delay(1000) end
			--界李儒（鸩杀少帝）
			elseif player:getGeneralName() == "mrds_jieliru" then
				room:broadcastSkillInvoke(self:objectName(), 5)
				room:setEmotion(player, "MRDS/mrds_jieliru/mrds_jieliru_atk")
				room:getThread():delay(1000)
			--留赞（灵魂歌王）
			
			--......
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getGeneralName() == "mrds_shenganning" or player:getGeneralName() == "mrds_jiexusheng"
		or player:getGeneralName() == "mrds_shenzhaoyun" or player:getGeneralName() == "mrds_jieguanyu"
		or player:getGeneralName() == "mrds_jieliru"
	end,
}
if not sgs.Sanguosha:getSkill("mrds_Attack") then skills:append(mrds_Attack) end
------







--

--神甘宁（万人辟易）
mrds_shenganning = sgs.General(extension, "mrds_shenganning", "god", 6, true, false, false, 3)

mrds_poxiCard = sgs.CreateSkillCard{
	name = "mrds_poxi",
	will_throw = false,
	filter = function(self, targets, to_select)
		if sgs.Sanguosha:getCurrentCardUsePattern() == "@mrds_poxi" or sgs.Sanguosha:getCurrentCardUsePattern() == "@mrds_poxi_less" then
			return #targets < 0
		end
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and not to_select:isKongcheng()
	end,
	feasible = function(self, targets)
		if sgs.Sanguosha:getCurrentCardUsePattern() == "@mrds_poxi" or sgs.Sanguosha:getCurrentCardUsePattern() == "@mrds_poxi_less" then
			return #targets == 0
		end
		return #targets == 1
	end,
	on_use = function(self, room, source, targets)
		if sgs.Sanguosha:getCurrentCardUsePattern() == "@mrds_poxi" then
			for _, id in sgs.qlist(self:getSubcards()) do
				room:setCardFlag(sgs.Sanguosha:getCard(id), "mrds_poxi")
			end
		else
			if targets[1] then
				room:broadcastSkillInvoke(self:objectName())
				room:setEmotion(source, "MRDS/mrds_shenganning/mrds_shenganning_skivk")
				local ids = targets[1]:handCards()
				local _guojia = sgs.SPlayerList()
				_guojia:append(source)
				local move = sgs.CardsMoveStruct(ids, targets[1], source, sgs.Player_PlaceHand, sgs.Player_PlaceHand, sgs.CardMoveReason())
				local moves = sgs.CardsMoveList()
				moves:append(move)
				room:notifyMoveCards(true, moves, false, _guojia)
				room:notifyMoveCards(false, moves, false, _guojia)
				local invoke = room:askForUseCard(source, "@mrds_poxi", "@mrds_poxi")
				local idt = sgs.IntList()
				for _, id in sgs.qlist(targets[1]:handCards()) do
					if ids:contains(id) then
						idt:append(id)
					end
				end
				local move_to = sgs.CardsMoveStruct(idt, source, targets[1], sgs.Player_PlaceHand, sgs.Player_PlaceHand, sgs.CardMoveReason())
				local moves_to = sgs.CardsMoveList()
				moves_to:append(move_to)
				room:notifyMoveCards(true, moves_to, false, _guojia)
				room:notifyMoveCards(false, moves_to, false, _guojia)
				if invoke then
					local dummy = sgs.Sanguosha:cloneCard("slash")
					local dummy_target = sgs.Sanguosha:cloneCard("slash")
					if source:getHandcardNum() + targets[1]:getHandcardNum() >= 4 then
						for _, id in sgs.qlist(source:handCards()) do
							if sgs.Sanguosha:getCard(id):hasFlag("mrds_poxi") then
								dummy:addSubcard(id)
								room:setCardFlag(sgs.Sanguosha:getCard(id), "-mrds_poxi")
							end
						end
						for _, id in sgs.qlist(targets[1]:handCards()) do
							if sgs.Sanguosha:getCard(id):hasFlag("mrds_poxi") then
								dummy_target:addSubcard(id)
								room:setCardFlag(sgs.Sanguosha:getCard(id), "-mrds_poxi")
							end
						end
						if dummy:subcardsLength() > 0 then
							room:throwCard(dummy, source)
						end
						if dummy_target:subcardsLength() > 0 then
							room:throwCard(dummy_target, targets[1], source)
						end
					end
					if dummy:subcardsLength() == 0 then
						room:loseMaxHp(source)
					elseif dummy:subcardsLength() == 1 then
						room:setPlayerFlag(source, "Global_PlayPhaseTerminated")
						room:setPlayerFlag(source, "mrds_poxi_handcardDown")
					elseif dummy:subcardsLength() == 3 then
						room:recover(source, sgs.RecoverStruct(source))
					elseif dummy:subcardsLength() == 4 then
						source:drawCards(4, self:objectName())
					end
				end
			end
		end
	end,
}
mrds_poxi = sgs.CreateViewAsSkill{
	name = "mrds_poxi",
	n = 4,
	view_filter = function(self, selected, to_select)
		if sgs.Sanguosha:getCurrentCardUsePattern() == "@mrds_poxi" then
			for _, c in sgs.list(selected) do
				if c:getSuit() == to_select:getSuit() then return false end
			end
			return not to_select:isEquipped() and not sgs.Self:isJilei(to_select)
		end
		return true
	end,
	view_as = function(self, cards)
		if sgs.Sanguosha:getCurrentCardUsePattern() == "@mrds_poxi" then
			if #cards ~= 4 then return nil end
			local skillcard = mrds_poxiCard:clone()
			for _, c in ipairs(cards) do
				skillcard:addSubcard(c)
			end
			return skillcard
		else
			if #cards ~= 0 then return nil end
			return mrds_poxiCard:clone()
		end
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#mrds_poxi")
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@mrds_poxi"
	end,
}
mrds_poxi_handcardDown = sgs.CreateMaxCardsSkill{
	name = "mrds_poxi_handcardDown",
	extra_func = function(self, player)
		if player:hasFlag("mrds_poxi_handcardDown") then
			return -1
		else
			return 0
		end
	end,
}
mrds_shenganning:addSkill(mrds_poxi)
if not sgs.Sanguosha:getSkill("mrds_poxi_handcardDown") then skills:append(mrds_poxi_handcardDown) end

mrds_jieying = sgs.CreateTriggerSkill{
	name = "mrds_jieying",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.TurnStart, sgs.EventPhaseStart, sgs.EventPhaseChanging, sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging and data:toPhaseChange().to == sgs.Player_NotActive then
			for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if p and p:isAlive() and p:objectName() ~= player:objectName() and player:getMark("&y_thiefed") > 0 then
					player:loseMark("&y_thiefed")
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:setEmotion(p, "MRDS/mrds_shenganning/mrds_shenganning_skivk")
					room:obtainCard(p, player:wholeHandCards(), false)
				end
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() == player:objectName()
			and player:hasSkill(self:objectName()) then
				local can_invoke = true
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if p:hasSkill(self:objectName()) then
						can_invoke = false
					end
				end
				if can_invoke then
					for _, p in sgs.qlist(room:getAlivePlayers()) do
						if p:getMark("&y_thiefed") > 0 then
							room:setPlayerMark(p, "&y_thiefed", 0)
						end
					end
				end
			end
		else
			local players, targets = sgs.SPlayerList(), sgs.SPlayerList()
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if p:getMark("&y_thiefed") == 0 then
					players:append(p)
				else
					targets:append(p)
				end
			end
			if event == sgs.TurnStart and targets:isEmpty() and player:hasSkill(self:objectName()) then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:setEmotion(player, "MRDS/mrds_shenganning/mrds_shenganning_skivk")
				player:gainMark("&y_thiefed")
			elseif event == sgs.EventPhaseStart and not players:isEmpty() and player:hasSkill(self:objectName())
			and player:getMark("&y_thiefed") > 0 and player:getPhase() == sgs.Player_Finish then
				local target = room:askForPlayerChosen(player, players, self:objectName(), "mrds_jieying-invoke", true, true)
				if target then
					player:loseMark("&y_thiefed")
					room:broadcastSkillInvoke(self:objectName())
					room:setEmotion(player, "MRDS/mrds_shenganning/mrds_shenganning_skivk")
					target:gainMark("&y_thiefed")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
--“营”标记效果：
mrds_jieyingD = sgs.CreateTriggerSkill{
    name = "mrds_jieyingD",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local sgn = room:findPlayerBySkillName("mrds_jieying")
		if sgn then
			room:sendCompulsoryTriggerLog(sgn, "mrds_jieying")
		end
		local count = data:toInt() + 1
		data:setValue(count)
	end,
	can_trigger = function(self, player)
	    return player:getMark("&y_thiefed") > 0
	end,
}
mrds_jieyingS = sgs.CreateTargetModSkill{
	name = "mrds_jieyingS",
	frequency = sgs.Skill_Compulsory,
	residue_func = function(self, player, card)
		if player:getMark("&y_thiefed") > 0 and card:isKindOf("Slash") then
		    return 1
		else
			return 0
		end
	end,
}
mrds_jieyingC = sgs.CreateMaxCardsSkill{
    name = "mrds_jieyingC",
    extra_func = function(self, player)
	    if player:getMark("&y_thiefed") > 0 then
		    return 1
		else
			return 0
		end
	end,
}
mrds_jieyingAudio = sgs.CreateTriggerSkill{
    name = "mrds_jieyingAudio",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Draw or player:getPhase() == sgs.Player_Discard then
			local sgn = room:findPlayerBySkillName("mrds_jieying")
			if sgn then
				room:sendCompulsoryTriggerLog(sgn, "mrds_jieying")
				--room:setEmotion(sgn, "MRDS/mrds_shenganning/mrds_shenganning_skivk")
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:getMark("&y_thiefed") > 0
	end,
}
mrds_shenganning:addSkill(mrds_jieying)
if not sgs.Sanguosha:getSkill("mrds_jieyingD") then skills:append(mrds_jieyingD) end
if not sgs.Sanguosha:getSkill("mrds_jieyingS") then skills:append(mrds_jieyingS) end
if not sgs.Sanguosha:getSkill("mrds_jieyingC") then skills:append(mrds_jieyingC) end
if not sgs.Sanguosha:getSkill("mrds_jieyingAudio") then skills:append(mrds_jieyingAudio) end

--界徐盛（破军杀将）
mrds_jiexusheng = sgs.General(extension, "mrds_jiexusheng", "wu", 4, true)

mrds_pojun = sgs.CreateTriggerSkill{
	name = "mrds_pojun",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetSpecified, sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.card and use.card:isKindOf("Slash") then
				for _, t in sgs.qlist(use.to) do
					local n = math.min(t:getCards("he"):length(), t:getHp())
					local _data = sgs.QVariant()
					_data:setValue(t)
					if n > 0 and player:askForSkillInvoke(self:objectName(), _data) then
						room:broadcastSkillInvoke(self:objectName())
						room:setEmotion(player, "MRDS/mrds_jiexusheng/mrds_jiexusheng_skivk")
						room:doAnimate(1, player:objectName(), t:objectName())
						local dis_num = {}
						for i = 1, n do
							table.insert(dis_num, tostring(i))
						end
						local discard_n = tonumber(room:askForChoice(player, self:objectName() .. "_num", table.concat(dis_num, "+"))) - 1
						local orig_places = sgs.PlaceList()
						local cards = sgs.IntList()
						t:setFlags("mrds_pojun_InTempMoving")
						for i = 0, discard_n do
							local id = room:askForCardChosen(player, t, "he", self:objectName() .. "_dis", false, sgs.Card_MethodNone)
							local place = room:getCardPlace(id)
							orig_places:append(place)
							cards:append(id)
							t:addToPile("#mrds_pojun", id, false)
						end
						for i = 0, discard_n do
							room:moveCardTo(sgs.Sanguosha:getCard(cards:at(i)), t, orig_places:at(i), false)
						end
						t:setFlags("-mrds_pojun_InTempMoving")
						local dummy = sgs.Sanguosha:cloneCard("slash")
						dummy:addSubcards(cards)
						local tt = sgs.SPlayerList()
						tt:append(t)
						t:addToPile("mrds_pojun", dummy, false, tt)
					end
				end
			end
		else
			local damage = data:toDamage()
			local to = damage.to
			if damage.card and damage.card:isKindOf("Slash") and to and to:isAlive() then
				if to:getHandcardNum() > player:getHandcardNum() or to:getEquips():length() > player:getEquips():length() then return false end
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:setEmotion(player, "MRDS/mrds_jiexusheng/mrds_jiexusheng_skivk")
				room:doAnimate(1, player:objectName(), to:objectName())
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		end
	end,
}
mrds_pojunReturn = sgs.CreateTriggerSkill{
	name = "mrds_pojunReturn",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if data:toPhaseChange().to == sgs.Player_NotActive then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if not p:getPile("mrds_pojun"):isEmpty() then
					local dummy = sgs.Sanguosha:cloneCard("slash")
					dummy:addSubcards(p:getPile("mrds_pojun"))
					room:obtainCard(p, dummy, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXCHANGE_FROM_PILE, p:objectName(), self:objectName(), ""), false)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mrds_pojunFakeMove = sgs.CreateTriggerSkill{
	name = "mrds_pojunFakeMove",
	global = true,
	priority = 10,
	frequency = sgs.Skill_Frequent,
	events = {sgs.BeforeCardsMove, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasFlag("mrds_pojun_InTempMoving") then
				return true
			end
		end
		return false
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mrds_jiexusheng:addSkill(mrds_pojun)
if not sgs.Sanguosha:getSkill("mrds_pojunReturn") then skills:append(mrds_pojunReturn) end
if not sgs.Sanguosha:getSkill("mrds_pojunFakeMove") then skills:append(mrds_pojunFakeMove) end

--神赵云（战龙在野）
mrds_shenzhaoyun = sgs.General(extension, "mrds_shenzhaoyun", "god", 2, true)

mrds_juejing = sgs.CreateTriggerSkill{
	name = "mrds_juejing",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EnterDying, sgs.QuitDying},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:sendCompulsoryTriggerLog(player, self:objectName())
		room:broadcastSkillInvoke(self:objectName())
		room:setEmotion(player, "MRDS/mrds_shenzhaoyun/mrds_shenzhaoyun_skivk")
		room:drawCards(player, 1, self:objectName())
	end,
}
mrds_juejing_moreCards = sgs.CreateMaxCardsSkill{
	name = "mrds_juejing_moreCards",
	extra_func = function(self, player)
		local n = 0
		if player:hasSkill("mrds_juejing") then
			n = n + 2
		end
		return n
	end,
}
mrds_juejing_moreCards_audio = sgs.CreateTriggerSkill{
	name = "mrds_juejing_moreCards_audio",
	global = true,
	priority = -1,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:sendCompulsoryTriggerLog(player, "mrds_juejing")
		room:broadcastSkillInvoke("mrds_juejing")
		room:setEmotion(player, "MRDS/mrds_shenzhaoyun/mrds_shenzhaoyun_skivk")
	end,
	can_trigger = function(self, player)
		return player:getPhase() == sgs.Player_Discard and player:hasSkill("mrds_juejing")
	end,
}
mrds_shenzhaoyun:addSkill(mrds_juejing)
if not sgs.Sanguosha:getSkill("mrds_juejing_moreCards") then skills:append(mrds_juejing_moreCards) end
if not sgs.Sanguosha:getSkill("mrds_juejing_moreCards_audio") then skills:append(mrds_juejing_moreCards_audio) end

mrds_longhun = sgs.CreateViewAsSkill{
	name = "mrds_longhun",
	n = 2,
	mute = true,
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
				new_card:setSkillName("mrds_longhunBuff")
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
mrds_longhunBuff = sgs.CreateTriggerSkill{
	name = "mrds_longhunBuff",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.PreHpRecover, sgs.ConfirmDamage, sgs.CardUsed, sgs.CardResponded},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.PreHpRecover then
			local rec = data:toRecover()
			if rec.card and rec.card:getSkillName() == "mrds_longhunBuff" then
				local log = sgs.LogMessage()
				log.type = "$mrds_longhunREC"
				log.from = player
				room:sendLog(log)
				rec.recover = rec.recover + 1
				data:setValue(rec)
			end
		elseif event == sgs.ConfirmDamage then
			local dmg = data:toDamage()
			if dmg.card and dmg.card:getSkillName() == "mrds_longhunBuff" then
				local log = sgs.LogMessage()
				log.type = "$mrds_longhunDMG"
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
			--“龙魂”技能语音
			if card and (card:getSkillName() == "mrds_longhun" or card:getSkillName() == "mrds_longhunBuff") then
				room:broadcastSkillInvoke("mrds_longhun")
				room:setEmotion(player, "MRDS/mrds_shenzhaoyun/mrds_shenzhaoyun_skivk")
			end
			if card and card:isBlack() and card:getSkillName() == "mrds_longhunBuff" then
				local current = room:getCurrent()
				if current:isNude() then return false end
				room:doAnimate(1, player:objectName(), current:objectName())
				local id = room:askForCardChosen(player, current, "he", "mrds_longhun", false, sgs.Card_MethodDiscard)
				room:throwCard(id, current, player)
			end
		end
	end,
}
mrds_shenzhaoyun:addSkill(mrds_longhun)
if not sgs.Sanguosha:getSkill("mrds_longhunBuff") then skills:append(mrds_longhunBuff) end

--界关羽（啸风从龙）
mrds_jieguanyu = sgs.General(extension, "mrds_jieguanyu", "shu", 4, true)

mrds_wusheng = sgs.CreateOneCardViewAsSkill{
	name = "mrds_wusheng",
	response_or_use = true,
	view_filter = function(self, card)
		if not card:isRed() then return false end
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
mrds_wushengD = sgs.CreateTargetModSkill{
	name = "mrds_wushengD",
	distance_limit_func = function(self, from, card)
		if from:hasSkill("mrds_wusheng") and card:isKindOf("Slash") and card:getSuit() == sgs.Card_Diamond then
			return 1000
		else
			return 0
		end
	end,
}
mrds_wushengUR = sgs.CreateTriggerSkill{
	name = "mrds_wushengUR",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.CardResponded},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local card = nil
		if event == sgs.CardUsed then
			card = data:toCardUse().card
		else
			local response = data:toCardResponse()
			card = response.m_card
		end
		if card and card:getSkillName() == "mrds_wusheng" then
			room:setEmotion(player, "MRDS/mrds_jieguanyu/mrds_jieguanyu_skivk")
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("mrds_wusheng")
	end,
}
mrds_jieguanyu:addSkill(mrds_wusheng)
if not sgs.Sanguosha:getSkill("mrds_wushengD") then skills:append(mrds_wushengD) end
if not sgs.Sanguosha:getSkill("mrds_wushengUR") then skills:append(mrds_wushengUR) end

mrds_yijueCard = sgs.CreateSkillCard{
	name = "mrds_yijueCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and not to_select:isKongcheng()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local data = sgs.QVariant()
		data:setValue(effect.to)
		room:setEmotion(effect.from, "MRDS/mrds_jieguanyu/mrds_jieguanyu_skivk")
		local card = room:askForCardShow(effect.to, effect.to, "mrds_yijue")
		local cd = card:getEffectiveId()
		room:showCard(effect.to, cd)
		if card:isBlack() then
			room:broadcastSkillInvoke("mrds_yijue", 2)
			--room:setEmotion(effect.from, "MRDS/mrds_jieguanyu/mrds_jieguanyu_skivk")
			effect.from:setFlags("mrds_yijueSource")
			effect.to:gainMark("&mrds_yijue")
			room:addPlayerMark(effect.to, "@skill_invalidity")
			room:setPlayerCardLimitation(effect.to, "use,response", ".|.|.|hand", false)
		elseif card:isRed() then
			--room:setEmotion(effect.from, "MRDS/mrds_jieguanyu/mrds_jieguanyu_skivk")
			room:obtainCard(effect.from, card, true)
			if effect.to:isWounded() and room:askForSkillInvoke(effect.from, "mrds_yijue", ToData("mrds_yijue-Recover:"..effect.to:objectName())) then
				room:broadcastSkillInvoke("mrds_yijue", 1)
				--room:setEmotion(effect.from, "MRDS/mrds_jieguanyu/mrds_jieguanyu_skivk")
				room:recover(effect.to, sgs.RecoverStruct(effect.from))
			end
		end
	end,
}
mrds_yijue = sgs.CreateOneCardViewAsSkill{
	name = "mrds_yijue",
	view_filter = function(self, to_select)
		return true
	end,
    view_as = function(self, cards)
		local my_card = mrds_yijueCard:clone()
		my_card:addSubcard(cards)
		return my_card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#mrds_yijueCard") and not player:isNude()
	end,
}
mrds_yijueBuffANDClear = sgs.CreateTriggerSkill{
	name = "mrds_yijueBuffANDClear",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.ConfirmDamage, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.from:objectName() == player:objectName() and player:hasSkill("mrds_yijue") and damage.to:getMark("&mrds_yijue") > 0
			and damage.card:isKindOf("Slash") and damage.card:getSuit() == sgs.Card_Heart then
				room:sendCompulsoryTriggerLog(player, "mrds_yijue")
				room:broadcastSkillInvoke("mrds_yijue")
				room:setEmotion(player, "MRDS/mrds_jieguanyu/mrds_jieguanyu_skivk")
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("&mrds_yijue") > 0 then
					room:setPlayerMark(p, "&mrds_yijue", 0)
					if p:getMark("@skill_invalidity") > 0 then
						room:setPlayerMark(p, "@skill_invalidity", 0)
					end
					room:removePlayerCardLimitation(p, "use,response", ".|.|.|hand")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mrds_jieguanyu:addSkill(mrds_yijue)
if not sgs.Sanguosha:getSkill("mrds_yijueBuffANDClear") then skills:append(mrds_yijueBuffANDClear) end

--界李儒（鸩杀少帝）
mrds_jieliru = sgs.General(extension, "mrds_jieliru", "qun", 3, true)

mrds_juece = sgs.CreateTriggerSkill{
	name = "mrds_juece",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime, sgs.EventPhaseProceeding, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if (move.from and move.from:objectName() == player:objectName() and (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip)))
			and not (move.to and move.to:objectName() == player:objectName() and (move.to_place == sgs.Player_PlaceHand or move.to_place == sgs.Player_PlaceEquip))
			and not player:hasFlag("mrds_jueceTarget") then
				room:setPlayerFlag(player, "mrds_jueceTarget")
			end
		elseif event == sgs.EventPhaseProceeding then
			local phase = player:getPhase()
			if phase == sgs.Player_Finish and player:hasSkill(self:objectName()) then
				local JueCers = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:hasFlag("mrds_jueceTarget") then
						JueCers:append(p)
					end
				end
				local victim
				if JueCers:length() > 0 then
					if room:askForSkillInvoke(player, self:objectName(), data) then
						if JueCers:length() > 1 then
							victim = room:askForPlayerChosen(player, JueCers, self:objectName(), "mrds_jueces")
						elseif JueCers:length() == 1 then
							for _, p in sgs.qlist(room:getOtherPlayers(player)) do
								if p:hasFlag("mrds_jueceTarget") then
									victim = p
									break
								end
							end
						end
						room:broadcastSkillInvoke(self:objectName())
						room:setEmotion(player, "MRDS/mrds_jieliru/mrds_jieliru_skivk")
						room:damage(sgs.DamageStruct(self:objectName(), player, victim))
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:hasFlag("mrds_jueceTarget") then
						room:setPlayerFlag(p, "-mrds_jueceTarget")
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
mrds_jieliru:addSkill(mrds_juece)

local function hasTrickCard(player)
	if player:isDead() then return false end
	local hTC = false
	for _, c in sgs.qlist(player:getHandcards()) do
		if c:isKindOf("TrickCard") then
			hTC = true
			break
		end
	end
	return hTC
end
local function hasNonTrickCard(player)
	if player:isDead() then return false end
	local hNTC = false
	for _, c in sgs.qlist(player:getHandcards()) do
		if not c:isKindOf("TrickCard") then
			hNTC = true
			break
		end
	end
	return hNTC
end
mrds_miejiCard = sgs.CreateSkillCard{
	name = "mrds_miejiCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and not to_select:isNude()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		room:setEmotion(effect.from, "MRDS/mrds_jieliru/mrds_jieliru_skivk")
		local cd = self:getEffectiveId()
		room:showCard(effect.from, cd)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, effect.from:objectName(), nil, "mrds_mieji", nil)
		room:moveCardTo(self, effect.from, nil, sgs.Player_DrawPile, reason, true)
		local choices = {}
		if hasTrickCard(effect.to) then
			table.insert(choices, "1=" .. effect.from:objectName())
		end
		if hasNonTrickCard(effect.to) and effect.to:canDiscard(effect.to, "he") then
			table.insert(choices, "2")
		end
		local choice = room:askForChoice(effect.to, "mrds_mieji", table.concat(choices, "+"))
		if choice == "2" then
			local n = 0
			for _, cd in sgs.qlist(effect.to:getCards("he")) do
				if not cd:isKindOf("TrickCard") then
					n = n + 1
				end
			end
			if n > 1 then
				room:askForDiscard(effect.to, "mrds_mieji", 2, 2, false, true, "@mrds_mieji-nontrick2", "BasicCard,EquipCard")
			else
				room:askForDiscard(effect.to, "mrds_mieji", 1, 1, false, true, "@mrds_mieji-nontrick1", "BasicCard,EquipCard")
			end
		else
			if effect.to:getState() == "robot" then
				local mjtk_gives = {}
				for _, t in sgs.qlist(effect.to:getHandcards()) do
					if t:isKindOf("TrickCard") then
					table.insert(mjtk_gives, t) end
				end
				local mj_card = mjtk_gives[math.random(1, #mjtk_gives)]
				effect.from:obtainCard(mj_card)
			else
				local data = sgs.QVariant()
				data:setValue(effect.to)
				local mj_card = room:askForCard(effect.to, ".Trick", "@mrds_mieji-givetrick:" .. effect.from:objectName(), data, sgs.Card_MethodNone)
				effect.from:obtainCard(mj_card)
			end
		end
	end,
}
mrds_mieji = sgs.CreateOneCardViewAsSkill{
	name = "mrds_mieji",
	view_filter = function(self, to_select)
		return to_select:isBlack() and to_select:isKindOf("TrickCard")
	end,
    view_as = function(self, cards)
		local meji_card = mrds_miejiCard:clone()
		meji_card:addSubcard(cards)
		return meji_card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#mrds_miejiCard") and not player:isKongcheng()
	end,
}
mrds_jieliru:addSkill(mrds_mieji)

mrds_fenchengCard = sgs.CreateSkillCard{
	name = "mrds_fenchengCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@mrds_fencheng")
		room:broadcastSkillInvoke("mrds_Attack", 5)
		room:doLightbox("$MRDSfencheng", 4000)
		--
		local n = 1
		for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			if p:getCards("he"):length() < n or not p:canDiscard(p, "he") then
				room:broadcastSkillInvoke("mrds_Attack", 5)
				room:setEmotion(source, "MRDS/mrds_jieliru/mrds_jieliru_atk") --开始装逼
				room:damage(sgs.DamageStruct("mrds_fencheng", source, p, 2, sgs.DamageStruct_Fire))
				n = 1
			else
				local dis = room:askForDiscard(p, "mrds_fencheng", 999, n, true, true)
				if dis then
					n = dis:getSubcards():length() + 1
				else
					room:broadcastSkillInvoke("mrds_Attack", 5)
					room:setEmotion(source, "MRDS/mrds_jieliru/mrds_jieliru_atk")
					room:damage(sgs.DamageStruct("mrds_fencheng", source, p, 2, sgs.DamageStruct_Fire))
					n = 1
				end
			end
		end
	end,
}
mrds_fencheng = sgs.CreateZeroCardViewAsSkill{
	name = "mrds_fencheng",
	frequency = sgs.Skill_Limited,
	limit_mark = "@mrds_fencheng",
	view_as = function()
		return mrds_fenchengCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@mrds_fencheng") > 0
	end,
}
mrds_jieliru:addSkill(mrds_fencheng)





--

--留赞（灵魂歌王）
--mrds_liuzan = sgs.General(extension, "mrds_liuzan", "wu", 4, true)






--

sgs.Sanguosha:addSkills(skills)
sgs.LoadTranslationTable{
    ["mobileRealDynamicSkin"] = "手杀传说真动皮乐园",
	
	["mrds_ComeOnStage"] = "", --登场动画
	["mrds_SkillInvoke"] = "", --技能发动动画
	["mrds_Attack"] = "", --攻击特效
	
	--神甘宁（万人辟易）
	["mrds_shenganning"] = "神甘宁",
	--["&mrds_shenganning"] = "大鬼",
	["#mrds_shenganning"] = "万人辟易",
	["designer:mrds_shenganning"] = "官方",
	["cv:mrds_shenganning"] = "官方",
	["illustrator:mrds_shenganning"] = "鬼画府,手杀(动画)",
	  --魄袭
	["mrds_poxi"] = "魄袭",
	["mrds_poxi_handcardDown"] = "魄袭",
	[":mrds_poxi"] = "出牌阶段限一次，你可以观看一名其他角色的手牌，然后你可以弃置你与其手里的四张牌（必须为四张且花色各不相同）。若如此做，根据此次弃置你的牌数量执行以下效果：" ..
	"没有，体力上限减1；一张，结束出牌阶段且本回合手牌上限-1；三张，回复1点体力；四张，摸四张牌。",
	["@mrds_poxi"] = "你可以发动“魄袭”",
	["@mrds_poxi_less"] = "你可以发动“魄袭”",
	["~mrds_poxi"] = "选择四张花色不同的手牌→点击确定",
	["~mrds_poxi_less"] = "点击技能→点击确定",
	["$mrds_poxi1"] = "战胜群敌，展江东豪杰之魄！",
	["$mrds_poxi2"] = "此次进击，定要丧敌胆魄！",
	  --劫营
	["mrds_jieying"] = "劫营",
	["mrds_jieyingD"] = "劫营",
	["mrds_jieyingS"] = "劫营",
	["mrds_jieyingC"] = "劫营",
	["mrds_jieyingAudio"] = "劫营",
	[":mrds_jieying"] = "回合开始时，若全场没有有“营”的角色，你获得一个“营”标记；结束阶段，你可以将“营”放到一名其他角色武将旁：有“营”的角色摸牌阶段多摸一张牌、出牌阶段可多使用一张【杀】、手牌上限+1。" ..
	"有“营”的其他角色的回合结束后，移去“营”，所有手牌交给你。",
	["y_thiefed"] = "营",
	["mrds_jieying-invoke"] = "你可以发动“劫营”<br/> <b>操作提示</b>: 选择一名角色→点击确定<br/>",
	["$mrds_jieying1"] = "劫敌营寨，以破其胆！",
	["$mrds_jieying2"] = "百骑劫魏营，功震天下英！",
	  --阵亡
	["~mrds_shenganning"] = "神鸦不佑，此身竟陨......",
	
	--界徐盛（破军杀将）
	["mrds_jiexusheng"] = "界徐盛",
	--["&mrds_jiexusheng"] = "大宝",
	["#mrds_jiexusheng"] = "破军杀将",
	["designer:mrds_jiexusheng"] = "官方",
	["cv:mrds_jiexusheng"] = "官方",
	["illustrator:mrds_jiexusheng"] = "凡果,手杀",
	  --破军
	["mrds_pojun"] = "破军",
	["mrds_pojunReturn"] = "破军",
	["mrds_pojunFakeMove"] = "破军",
	[":mrds_pojun"] = "当你使用【杀】指定一个目标后，你可以发动此技能，将其至多X张牌扣置于该角色的武将牌旁（X为其体力值）；若如此做，当前回合结束后，该角色获得这些牌。" ..
	"你使用【杀】对手牌数与装备数均不大于你的角色造成伤害时，此伤害+1。",
	["mrds_pojun_num"] = "破军-移除数",
	["mrds_pojun_dis"] = "破军-选择牌",
	["$mrds_pojun1"] = "战将临阵，斩关刈城！",
	["$mrds_pojun2"] = "区区数百魏军，看我一击灭之！",
	  --阵亡
	["~mrds_jiexusheng"] = "来世...愿再为我江东之臣！......",
	
	--神赵云（战龙在野）
	["mrds_shenzhaoyun"] = "神赵云",
	--["&mrds_shenzhaoyun"] = "宇宙云",
	["#mrds_shenzhaoyun"] = "战龙在野",
	["designer:mrds_shenzhaoyun"] = "官方",
	["cv:mrds_shenzhaoyun"] = "官方",
	["illustrator:mrds_shenzhaoyun"] = "铁杵文化,手杀/大梦与初(动画)",
	  --绝境
	["mrds_juejing"] = "绝境",
	["mrds_juejing_moreCards"] = "绝境",
	["mrds_juejing_moreCards_audio"] = "绝境",
	[":mrds_juejing"] = "锁定技，你的手牌上限+2；当你进入或脱离濒死状态时，你摸一张牌。",
	["$mrds_juejing1"] = "......还不可以认输！",
	["$mrds_juejing2"] = "绝望中，仍存有一线生机！",
	  --龙魂
	["mrds_longhun"] = "龙魂",
	["mrds_longhunBuff"] = "龙魂",
	[":mrds_longhun"] = "你可以将至多两张同花色的牌按以下规则使用或打出：♥当【桃】；♦当火【杀】；♣当【闪】；♠当【无懈可击】。若你以此法使用了两张红色牌，则此牌回复值或伤害值+1。若你以此法使用了两张黑色牌，则你弃置当前回合角色一张牌。",
	["$mrds_longhunREC"] = "%from 发动“<font color='yellow'><b>龙魂</b></font>”使用了两张<font color='red'><b>红色</b></font>牌，此【<font color='yellow'><b>桃</b></font>】的回复值+1",
	["$mrds_longhunDMG"] = "%from 发动“<font color='yellow'><b>龙魂</b></font>”使用了两张<font color='red'><b>红色</b></font>牌，此【<font color='yellow'><b>杀</b></font>】的伤害值+1",
	["$mrds_longhun1"] = "潜龙勿用，藏锋守拙！",
	["$mrds_longhun2"] = "龙战于野，其血玄黄！",
	  --阵亡
	["~mrds_shenzhaoyun"] = "龙鳞崩损，坠于九天！......",
	
	--界关羽（啸风从龙）
	["mrds_jieguanyu"] = "界关羽",
	--["&mrds_jieguanyu"] = "大风车",吱呀吱哟哟地转......
	["#mrds_jieguanyu"] = "啸风从龙",
	["designer:mrds_jieguanyu"] = "官方",
	["cv:mrds_jieguanyu"] = "官方",
	["illustrator:mrds_jieguanyu"] = "鬼画府,手杀(动画)",
	  --武圣
	["mrds_wusheng"] = "武圣",
	["mrds_wushengD"] = "武圣",
	["mrds_wushengUR"] = "武圣",
	[":mrds_wusheng"] = "你可以将一张红色牌当普通【杀】使用或打出。你使用♦【杀】无距离限制。",
	["$mrds_wusheng1"] = "敌酋虽勇，亦非关某一合之将！",
	["$mrds_wusheng2"] = "酒且斟下，关某片刻便归！",
	  --义绝
	["mrds_yijue"] = "义绝",
	[":mrds_yijue"] = "出牌阶段限一次，你可以弃置一张牌，然后令一名其他角色展示一张手牌。若此牌为黑色，则其本回合非锁定技失效且不能使用或打出手牌，你对其使用的♥【杀】伤害+1；" ..
	"若此牌为红色，则你获得之，然后你可令该角色回复1点体力。",
	["mrds_yijue:mrds_yijue-Recover"] = "[义绝]你可以令%src回复1点体力",
	["$mrds_yijue1"] = "大丈夫处事，只以忠义为先！",
	["$mrds_yijue2"] = "马行忠魂路，刀斩不义敌！",
	  --阵亡
	["~mrds_jieguanyu"] = "大哥知遇之恩，云长来世再报了......",
	
	--界李儒（鸩杀少帝）
	["mrds_jieliru"] = "界李儒",
	--["&mrds_jieliru"] = "时代的骄傲",
	["#mrds_jieliru"] = "鸩杀少帝",
	["designer:mrds_jieliru"] = "官方",
	["cv:mrds_jieliru"] = "官方",
	["illustrator:mrds_jieliru"] = "YOKO,手杀",
	  --绝策
	["mrds_juece"] = "绝策",
	[":mrds_juece"] = "结束阶段，你可以对本回合失去过牌的一名其他角色造成1点伤害。",
	["mrds_jueces"] = "[绝策]请选择一名其他角色，对其造成1点伤害",
	["$mrds_juece1"] = "让你品尝下，绝望的滋味。",
	["$mrds_juece2"] = "闭目等死，是你能做的最后一件事。",
	  --灭计
	["mrds_mieji"] = "灭计",
	[":mrds_mieji"] = "出牌阶段限一次，你可以展示一张黑色锦囊牌并将之置于牌堆顶并令一名有牌的其他角色选择一项：交给你一张锦囊牌；或弃置两张非锦囊牌（不足则只需弃一张）。",
	["mrds_mieji:1"] = "交给%src一张锦囊牌",
	["mrds_mieji:2"] = "弃置两张非锦囊牌(不足则只需弃一张)",
	["@mrds_mieji-givetrick"] = "请将一张锦囊牌交给 %src",
	["@mrds_mieji-nontrick1"] = "请弃置一张锦囊牌",
	["@mrds_mieji-nontrick2"] = "请弃置两张锦囊牌",
	["$mrds_mieji1"] = "我的计策，绝不留下一丝希望。",
	["$mrds_mieji2"] = "现在后悔已经太晚啦。",
	  --焚城
	["mrds_fencheng"] = "焚城",
	[":mrds_fencheng"] = "限定技，出牌阶段，你可以令所有其他角色依次选择一项：1.弃置至少X张牌（X为发动此技能时该角色的上家以此法弃置牌的数量+1）；2.受到你造成的2点火焰伤害。",
	["@mrds_fencheng"] = "焚城",
	["$MRDSfencheng"] = "anim=MRDS/mrds_jieliru/MRDSfencheng",
	["$mrds_fencheng1"] = "能留下的，只有哀嚎与断壁残垣！",
	["$mrds_fencheng2"] = "如此宏伟的城池，马上便是一片灰烬！",
	  --阵亡
	["~mrds_jieliru"] = "这就是所谓的......报应吗......",
	
	--留赞（灵魂歌王）
	["mrds_liuzan"] = "留赞",
	--["&mrds_liuzan"] = "腾格尔",
	["#mrds_liuzan"] = "灵魂歌王",
	["designer:mrds_liuzan"] = "官方",
	["cv:mrds_liuzan"] = "官方",
	["illustrator:mrds_liuzan"] = "酸包,手杀",
	  --奋音
	["mrds_fenyin"] = "奋音",
	[":mrds_fenyin"] = "你的回合内，每当你使用了一张与上一张颜色不同的牌时，你摸一张牌。",
	["$mrds_fenyin1"] = "阵前亢歌，以振军心！",
	["$mrds_fenyin2"] = "吾军杀声震天，则敌心必乱！",
	  --阵亡
	["~mrds_liuzan"] = "贼子们，来吧！啊~......",
}
return {extension} 