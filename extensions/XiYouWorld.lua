extension = sgs.Package("XiYouWorld", sgs.Package_GeneralPack)
extension_x = sgs.Package("XiYouWorldCards", sgs.Package_CardPack)

--==地主专属武将·专属技能==--（孙悟空、东海龙王、涛神、李白(两个版本)）
xydizhusoul = sgs.CreateTriggerSkill {
	name = "xydizhusoul",
	priority = 9999,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.DrawInitialCards },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, self:objectName(), data) then
			if player:isLord() and player:hasSkill("feiyang") and player:hasSkill("bahu") then --地主
				local log = sgs.LogMessage()
				log.type = "$xydizhusoul_dz"
				log.from = player
				room:sendLog(log)
				data:setValue(data:toInt() + 2)
			else
				--======投掷骰子======--
				room:getThread():delay()
				local n = math.random(1, 6)
				------------------------
				local log = sgs.LogMessage()
				log.type = "$xydizhusoul_tz"
				log.arg2 = n
				log.from = player
				room:sendLog(log)
				if n == 6 then
					room:broadcastSkillInvoke(self:objectName())
					if room:askForSkillInvoke(player, "@xydizhusoul_imdz", data) then
						local mhp = player:getMaxHp() + 1
						room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp))
						local hp = player:getHp() + 1
						room:setPlayerProperty(player, "hp", sgs.QVariant(hp))
						room:acquireSkill(player, "feiyang")
						room:acquireSkill(player, "bahu")
					else
						local log = sgs.LogMessage()
						log.type = "$xydizhusoul_ndz"
						log.from = player
						room:sendLog(log)
						data:setValue(data:toInt() + 2)
					end
				else
					local log = sgs.LogMessage()
					log.type = "$xydizhusoul_ndz"
					log.from = player
					room:sendLog(log)
					data:setValue(data:toInt() + 2)
				end
			end
		end
	end,
}
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("xydizhusoul") then skills:append(xydizhusoul) end
--=========================--

--XYW01 孙悟空
xy_sunwukong = sgs.General(extension, "xy_sunwukong", "qun", 3, true)
xy_sunwukong:addSkill("xydizhusoul")

--[[xyjinjing = sgs.CreateTriggerSkill{
	name = "xyjinjing",
	global = true,
	priority = 666,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.EventAcquireSkill, sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:hasSkill(self:objectName()) then
				room:broadcastSkillInvoke(self:objectName())
				for _, yg in sgs.qlist(room:getOtherPlayers(player)) do
					room:setPlayerMark(player, "HandcardVisible_+" .. yg:objectName(), 1)
				end
			end
		elseif event == sgs.EventAcquireSkill then
			if data:toString() == self:objectName() then
				room:broadcastSkillInvoke(self:objectName())
				for _, yg in sgs.qlist(room:getOtherPlayers(player)) do
					room:setPlayerMark(player, "HandcardVisible_+" .. yg:objectName(), 1)
				end
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == self:objectName() then
				for _, yg in sgs.qlist(room:getOtherPlayers(player)) do
					room:setPlayerMark(player, "HandcardVisible_+" .. yg:objectName(), 0)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
xy_sunwukong:addSkill(xyjinjing)]]
xyjinjingCard = sgs.CreateSkillCard {
	name = "xyjinjingCard",
	target_fixed = false,
	view_filter = function(self, selected, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and not to_select:isKongcheng()
	end,
	on_use = function(self, room, source, targets)
		local yaoguai = targets[1]
		room:showAllCards(yaoguai, source)
	end,
}
xyjinjing = sgs.CreateZeroCardViewAsSkill {
	name = "xyjinjing",
	view_as = function()
		return xyjinjingCard:clone()
	end,
	enabled_at_play = function(self, player)
		return true
	end,
}
xyjinjingTrigger = sgs.CreateTriggerSkill { --参考了倚天包-贾文和的“洞察”
	name = "xyjinjingTrigger",
	global = true,
	priority = { 666, 666, 666, 666, 666 },
	frequency = sgs.Skill_Compulsory,
	events = { sgs.GameStart, sgs.EventPhaseStart, sgs.TargetConfirming, sgs.EventAcquireSkill, sgs.EventLoseSkill },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:hasSkill("xyjinjing") then
				room:setTag("Dongchaer", sgs.QVariant(player:objectName()))                                                              --真实现·透视挂
				local hyjj = room:askForPlayersChosen(player, room:getOtherPlayers(player), "xyjinjing", 0, 999,
					"@xyjinjing-toseeGMS", false, true)                                                                                  --目标角色多选
				if not hyjj:isEmpty() then
					room:sendCompulsoryTriggerLog(player, "xyjinjing")
					room:broadcastSkillInvoke("xyjinjing")
					for _, p in sgs.qlist(hyjj) do
						room:doAnimate(1, player:objectName(), p:objectName())
						room:showAllCards(p, player)
						room:getThread():delay()
					end
				end
				--if player:getSeat() == 1 then room:setPlayerFlag(player, "xyjinjingNonRepeat") end
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				for _, skw in sgs.qlist(room:findPlayersBySkillName("xyjinjing")) do
					local hyjj = room:askForPlayersChosen(skw, room:getOtherPlayers(skw), "xyjinjing", 0, 999,
						"@xyjinjing-tosee", false, true)
					if not hyjj:isEmpty() then
						room:sendCompulsoryTriggerLog(skw, "xyjinjing")
						room:broadcastSkillInvoke("xyjinjing")
						for _, p in sgs.qlist(hyjj) do
							room:doAnimate(1, skw:objectName(), p:objectName())
							room:showAllCards(p, skw)
							room:getThread():delay()
						end
					end
				end
			end
		elseif event == sgs.TargetConfirming then
			local use = data:toCardUse()
			if use.from and use.from:objectName() ~= player:objectName() and not use.from:isKongcheng() and player:hasSkill("xyjinjing") then
				room:sendCompulsoryTriggerLog(player, "xyjinjing")
				--room:broadcastSkillInvoke("xyjinjing") --无效化了，不然太鬼畜
				--room:doAnimate(1, player:objectName(), use.from:objectName())
				room:showAllCards(use.from, player)
			end
		elseif event == sgs.EventAcquireSkill then
			if data:toString() == "xyjinjing" then
				room:setTag("Dongchaer", sgs.QVariant(player:objectName()))
				local hyjj = room:askForPlayersChosen(player, room:getOtherPlayers(player), "xyjinjing", 0, 999,
					"@xyjinjing-tosee", false, true)
				if not hyjj:isEmpty() then
					room:sendCompulsoryTriggerLog(player, "xyjinjing")
					room:broadcastSkillInvoke("xyjinjing")
					for _, p in sgs.qlist(hyjj) do
						room:doAnimate(1, player:objectName(), p:objectName())
						room:showAllCards(p, player)
						room:getThread():delay()
					end
				end
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == "xyjinjing" then
				local other_skw = room:findPlayerBySkillName("xyjinjing")
				if not other_skw then
					room:setTag("Dongchaer", sgs.QVariant())
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
xy_sunwukong:addSkill(xyjinjing)
if not sgs.Sanguosha:getSkill("xyjinjingTrigger") then skills:append(xyjinjingTrigger) end

xycibei = sgs.CreateTriggerSkill {
	name = "xycibei",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.DamageCaused, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DamageCaused then
			local damage = data:toDamage()
			if damage.from:objectName() == player:objectName() and damage.to and damage.to:objectName() ~= damage.from:objectName()
				and damage.to:getMark(self:objectName()) == 0 and player:hasSkill(self:objectName()) then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:broadcastSkillInvoke(self:objectName())
					room:addPlayerMark(damage.to, self:objectName())
					room:drawCards(player, 5, self:objectName())
					return true
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, self:objectName(), 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
xy_sunwukong:addSkill(xycibei)

xyruyi = sgs.CreateFilterSkill {
	name = "xyruyi",
	view_filter = function(self, to_select)
		local room = sgs.Sanguosha:currentRoom()
		local place = room:getCardPlace(to_select:getEffectiveId())
		return to_select:isKindOf("Weapon") and place == sgs.Player_PlaceHand
	end,
	view_as = function(self, originalCard)
		local slash = sgs.Sanguosha:cloneCard("slash", originalCard:getSuit(), originalCard:getNumber())
		slash:setSkillName(self:objectName())
		local card = sgs.Sanguosha:getWrappedCard(originalCard:getId())
		card:takeOver(slash)
		return card
	end,
}
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

xyruyiJGB = sgs.CreateTriggerSkill {
	name = "xyruyiJGB",
	global = true,
	priority = { 13500, 13500, 13500, 13500, 13500 }, --如意金箍棒重[一万三千五百斤]（最高优先级，超越一切的存在！）
	frequency = sgs.Skill_Compulsory,
	events = { sgs.GameStart, sgs.EventAcquireSkill, sgs.EventLoseSkill, sgs.ObtainEquipArea, sgs.CardsMoveOneTime },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then --游戏开始，建立“如意宝库”并将金箍棒(攻击范围3)置入装备区
			for _, p in sgs.qlist(room:findPlayersBySkillName("xyruyi")) do
				if p:getPile("xyruyiBK"):length() < 4 and p:getWeapon() == nil then
					local cds = sgs.IntList()
					local one, two, three, four = 0, 0, 0, 0
					for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
						if sgs.Sanguosha:getEngineCard(id):isKindOf("XyRuyijingubangOne") and one < 1
							and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial and room:getCardPlace(id) ~= sgs.Player_PlaceEquip then
							cds:append(id)
							one = one + 1
						elseif sgs.Sanguosha:getEngineCard(id):isKindOf("XyRuyijingubangTwo") and two < 1
							and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial and room:getCardPlace(id) ~= sgs.Player_PlaceEquip then
							cds:append(id)
							two = two + 1
						elseif sgs.Sanguosha:getEngineCard(id):isKindOf("XyRuyijingubangThree") and three < 1
							and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial and room:getCardPlace(id) ~= sgs.Player_PlaceEquip then
							cds:append(id)
							three = three + 1
						elseif sgs.Sanguosha:getEngineCard(id):isKindOf("XyRuyijingubangFour") and four < 1
							and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial and room:getCardPlace(id) ~= sgs.Player_PlaceEquip then
							cds:append(id)
							four = four + 1
						end
					end
					if not cds:isEmpty() then
						p:addToPile("xyruyiBK", cds) --建立“如意宝库”储存(四种)金箍棒
					end
				end
				if p:getPile("xyruyiBK"):length() >= 4 then
					local cards, cards_copy = sgs.CardList(), sgs.CardList()
					for _, id in sgs.qlist(p:getPile("xyruyiBK")) do
						local card = sgs.Sanguosha:getCard(id)
						if card:isKindOf("XyRuyijingubangThree") then
							room:setTag("RYJGBthree_ID", sgs.QVariant(id))
							cards:append(card)
							cards_copy:append(card)
						else
							if card:isKindOf("XyRuyijingubangOne") then room:setTag("RYJGBone_ID", sgs.QVariant(id)) end
							if card:isKindOf("XyRuyijingubangTwo") then room:setTag("RYJGBtwo_ID", sgs.QVariant(id)) end
							if card:isKindOf("XyRuyijingubangFour") then room:setTag("RYJGBfour_ID", sgs.QVariant(id)) end
						end
					end
					if not cards:isEmpty() then
						local JGBthr
						while not JGBthr do
							if cards:isEmpty() then break end
							if not JGBthr then
								JGBthr = cards:at(math.random(0, cards:length() - 1))
								for _, card in sgs.qlist(cards_copy) do
									if card:getSubtype() == JGBthr:getSubtype() then
										cards:removeOne(card)
									end
								end
							end
						end
						if JGBthr then
							local Moves = sgs.CardsMoveList()
							local equip = JGBthr:getRealCard():toEquipCard()
							local equip_index = equip:location()
							if p:getEquip(equip_index) == nil and p:hasEquipArea(equip_index) then
								room:sendCompulsoryTriggerLog(p, "xyruyi")
								room:broadcastSkillInvoke("xyruyi")
								Moves:append(sgs.CardsMoveStruct(JGBthr:getId(), p, sgs.Player_PlaceEquip,
									sgs.CardMoveReason()))
							end
							room:moveCardsAtomic(Moves, true) --装备！
						end
					end
				end
				--此时，检测“如意宝库”是否是四种金箍棒各一张，将多余的牌清除（解决自定义模式的错乱问题）
				if p:getPile("xyruyiBK"):length() >= 4 then
					local o, t, tr, f = 0, 0, 0, 0
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					for _, id in sgs.qlist(p:getPile("xyruyiBK")) do
						local card = sgs.Sanguosha:getCard(id)
						if card:isKindOf("XyRuyijingubangOne") then
							if o > 1 then
								dummy:addSubcard(id)
							else
								o = o + 1
							end
						elseif card:isKindOf("XyRuyijingubangTwo") then
							if t > 1 then
								dummy:addSubcard(id)
							else
								t = t + 1
							end
						elseif card:isKindOf("XyRuyijingubangThree") then
							if tr > 1 then
								dummy:addSubcard(id)
							else
								tr = tr + 1
							end
						elseif card:isKindOf("XyRuyijingubangFour") then
							if f > 1 then
								dummy:addSubcard(id)
							else
								f = f + 1
							end
						end
					end
					room:throwCard(dummy, nil)
					dummy:deleteLater()
				end
			end
			--[[elseif event == sgs.EventLoseSkill then --将失去写在获得前，以更好兼容“夺锐”这类抢技能的
			if data:toString() == "xyruyi" then
				--清空“如意宝库”，但并不能卸掉玩家已装备的金箍棒，因为不再始终装备≠不能装备
				if player:getPile("xyruyiBK"):length() > 0 then
					local ids_tothrow = sgs.IntList()
					for _, id in sgs.qlist(player:getPile("xyruyiBK")) do
						ids_tothrow:append(id)
					end
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					dummy:addSubcards(getCardList(ids_tothrow))
					room:throwCard(dummy, nil)
					dummy:deleteLater()
				end
			end]]
		elseif event == sgs.EventAcquireSkill or event == sgs.ObtainEquipArea then --恢复装备栏时自然也要检查一下
			if (event == sgs.EventAcquireSkill and data:toString() == "xyruyi")
				or (event == sgs.ObtainEquipArea and player:hasSkill("xyruyi") and not player:hasFlag("xyruyi_OEAnonTrigger")) then
				local cds = sgs.IntList()
				local one, two, three, four = 0, 0, 0, 0
				--先检查玩家装备区有没有金箍棒
				if player:getWeapon() ~= nil and player:getWeapon():isKindOf("XyRuyijingubangOne") then one = one + 1 end
				if player:getWeapon() ~= nil and player:getWeapon():isKindOf("XyRuyijingubangTwo") then two = two + 1 end
				if player:getWeapon() ~= nil and player:getWeapon():isKindOf("XyRuyijingubangThree") then three = three +
					1 end
				if player:getWeapon() ~= nil and player:getWeapon():isKindOf("XyRuyijingubangFour") then four = four + 1 end
				--再检查“如意宝库”，上述两步都是为了防止重复获得同类金箍棒
				if player:getPile("xyruyiBK"):length() > 0 then
					for _, i in sgs.qlist(player:getPile("xyruyiBK")) do
						local crd = sgs.Sanguosha:getCard(i)
						if crd:isKindOf("XyRuyijingubangOne") then one = one + 1 end
						if crd:isKindOf("XyRuyijingubangTwo") then two = two + 1 end
						if crd:isKindOf("XyRuyijingubangThree") then three = three + 1 end
						if crd:isKindOf("XyRuyijingubangFour") then four = four + 1 end
					end
				end
				if player:getPile("xyruyiBK"):length() < 4 then
					for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
						if sgs.Sanguosha:getEngineCard(id):isKindOf("XyRuyijingubangOne") and one < 1
							and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial and room:getCardPlace(id) ~= sgs.Player_PlaceEquip then
							cds:append(id)
							one = one + 1
						elseif sgs.Sanguosha:getEngineCard(id):isKindOf("XyRuyijingubangTwo") and two < 1
							and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial and room:getCardPlace(id) ~= sgs.Player_PlaceEquip then
							cds:append(id)
							two = two + 1
						elseif sgs.Sanguosha:getEngineCard(id):isKindOf("XyRuyijingubangThree") and three < 1
							and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial and room:getCardPlace(id) ~= sgs.Player_PlaceEquip then
							cds:append(id)
							three = three + 1
						elseif sgs.Sanguosha:getEngineCard(id):isKindOf("XyRuyijingubangFour") and four < 1
							and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial and room:getCardPlace(id) ~= sgs.Player_PlaceEquip then
							cds:append(id)
							four = four + 1
						end
					end
					if not cds:isEmpty() then
						player:addToPile("xyruyiBK", cds)
					end
				end
				if player:getPile("xyruyiBK"):length() >= 4 then
					if player:getWeapon() ~= nil and player:getWeapon():isKindOf("XyRuyijingubangThree") then
						return false
					end --如果装备区里都有金箍棒(攻击范围3)了自然也就不用再继续执行置入代码了
					local cards, cards_copy = sgs.CardList(), sgs.CardList()
					for _, id in sgs.qlist(player:getPile("xyruyiBK")) do
						local card = sgs.Sanguosha:getCard(id)
						if card:isKindOf("XyRuyijingubangThree") then
							room:setTag("RYJGBthree_ID", sgs.QVariant(id))
							cards:append(card)
							cards_copy:append(card)
						else
							if card:isKindOf("XyRuyijingubangOne") then room:setTag("RYJGBone_ID", sgs.QVariant(id)) end
							if card:isKindOf("XyRuyijingubangTwo") then room:setTag("RYJGBtwo_ID", sgs.QVariant(id)) end
							if card:isKindOf("XyRuyijingubangFour") then room:setTag("RYJGBfour_ID", sgs.QVariant(id)) end
						end
					end
					if not cards:isEmpty() then
						local JGBthr
						while not JGBthr do
							if cards:isEmpty() then break end
							if not JGBthr then
								JGBthr = cards:at(math.random(0, cards:length() - 1))
								for _, card in sgs.qlist(cards_copy) do
									if card:getSubtype() == JGBthr:getSubtype() then
										cards:removeOne(card)
									end
								end
							end
						end
						if JGBthr then
							local Moves = sgs.CardsMoveList()
							local equip = JGBthr:getRealCard():toEquipCard()
							local equip_index = equip:location()
							if player:getEquip(equip_index) == nil and player:hasEquipArea(equip_index) then
								room:sendCompulsoryTriggerLog(player, "xyruyi")
								room:broadcastSkillInvoke("xyruyi")
								Moves:append(sgs.CardsMoveStruct(JGBthr:getId(), player, sgs.Player_PlaceEquip,
									sgs.CardMoveReason()))
							elseif player:getEquip(equip_index) ~= nil and player:hasEquipArea(equip_index) then
								room:setPlayerFlag(player, "xyruyi_OEAnonTrigger")
								player:throwEquipArea(equip_index)
								player:obtainEquipArea(equip_index)
								room:setPlayerFlag(player, "-xyruyi_OEAnonTrigger")
								room:sendCompulsoryTriggerLog(player, "xyruyi")
								room:broadcastSkillInvoke("xyruyi")
								Moves:append(sgs.CardsMoveStruct(JGBthr:getId(), player, sgs.Player_PlaceEquip,
									sgs.CardMoveReason()))
							end
							room:moveCardsAtomic(Moves, true)
						end
					end
				end
				if player:getPile("xyruyiBK"):length() >= 4 then --同样的，检测“如意宝库”是否正常（防自定义错乱）
					local o, t, tr, f = 0, 0, 0, 0
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					for _, id in sgs.qlist(player:getPile("xyruyiBK")) do
						local card = sgs.Sanguosha:getCard(id)
						if card:isKindOf("XyRuyijingubangOne") then
							if o > 1 then
								dummy:addSubcard(id)
							else
								o = o + 1
							end
						elseif card:isKindOf("XyRuyijingubangTwo") then
							if t > 1 then
								dummy:addSubcard(id)
							else
								t = t + 1
							end
						elseif card:isKindOf("XyRuyijingubangThree") then
							if tr > 1 then
								dummy:addSubcard(id)
							else
								tr = tr + 1
							end
						elseif card:isKindOf("XyRuyijingubangFour") then
							if f > 1 then
								dummy:addSubcard(id)
							else
								f = f + 1
							end
						end
					end
					room:throwCard(dummy, nil)
					dummy:deleteLater()
				end
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() ~= player:objectName() then return false end
			--先检查移的牌中有没有金箍棒
			local can_invoke = false
			for _, id in sgs.qlist(move.card_ids) do
				local card = sgs.Sanguosha:getCard(id)
				if card:isKindOf("XyRuyijingubangOne") or card:isKindOf("XyRuyijingubangTwo")
					or card:isKindOf("XyRuyijingubangThree") or card:isKindOf("XyRuyijingubangFour") then
					can_invoke = true
				end
			end
			if not can_invoke then return false end
			--1.金箍棒离开装备区
			if move.from_places:contains(sgs.Player_PlaceEquip) then
				--1.1 (在玩家有技能“如意”的情况下)不因“调整”攻击范围、武器栏被废除、玩家阵亡而离开装备区，立即置回
				if player:hasSkill("xyruyi") and (move.to_place ~= sgs.Player_PlaceSpecial or (move.to_place == sgs.Player_PlaceSpecial and move.to_pile_name ~= "xyruyiBK"))
					and player:hasEquipArea(0) and player:isAlive() then
					for _, id in sgs.qlist(move.card_ids) do
						local card = sgs.Sanguosha:getCard(id)
						if card:isKindOf("XyRuyijingubangOne") or card:isKindOf("XyRuyijingubangTwo")
							or card:isKindOf("XyRuyijingubangThree") or card:isKindOf("XyRuyijingubangFour") then
							local Moves = sgs.CardsMoveList()
							local equip = card:getRealCard():toEquipCard()
							local equip_index = equip:location()
							if player:getEquip(equip_index) ~= nil then
								room:setPlayerFlag(player, "xyruyi_OEAnonTrigger")
								player:throwEquipArea(equip_index)
								player:obtainEquipArea(equip_index)
								room:setPlayerFlag(player, "-xyruyi_OEAnonTrigger")
								room:sendCompulsoryTriggerLog(player, "xyruyi")
								room:broadcastSkillInvoke("xyruyi")
								Moves:append(sgs.CardsMoveStruct(card:getId(), player, sgs.Player_PlaceEquip,
									sgs.CardMoveReason()))
							else
								room:sendCompulsoryTriggerLog(player, "xyruyi")
								room:broadcastSkillInvoke("xyruyi")
								Moves:append(sgs.CardsMoveStruct(card:getId(), player, sgs.Player_PlaceEquip,
									sgs.CardMoveReason()))
							end
							room:moveCardsAtomic(Moves, true)
							break
						end
					end
					--1.2 因武器栏被废除/玩家阵亡而离开装备区(或离开装备区时玩家没有技能“如意”)，若玩家有技能“如意”且存活，置入“如意宝库”；否则立即销毁
				elseif (not player:hasEquipArea(0) and not player:hasFlag("xyruyi_OEAnonTrigger")) or not player:isAlive() or not player:hasSkill("xyruyi") then
					if player:hasSkill("xyruyi") and player:isAlive() then
						local cds = sgs.IntList()
						for _, id in sgs.qlist(move.card_ids) do
							local card = sgs.Sanguosha:getCard(id)
							if card:isKindOf("XyRuyijingubangOne") or card:isKindOf("XyRuyijingubangTwo")
								or card:isKindOf("XyRuyijingubangThree") or card:isKindOf("XyRuyijingubangFour") then
								cds:append(id)
							end
						end
						if not cds:isEmpty() then
							player:addToPile("xyruyiBK", cds)
						end
					else
						for _, id in sgs.qlist(move.card_ids) do
							local card = sgs.Sanguosha:getCard(id)
							if card:isKindOf("XyRuyijingubangOne") then destroyEquip(room, move, "RYJGBone_ID") end
							if card:isKindOf("XyRuyijingubangTwo") then destroyEquip(room, move, "RYJGBtwo_ID") end
							if card:isKindOf("XyRuyijingubangThree") then destroyEquip(room, move, "RYJGBthree_ID") end
							if card:isKindOf("XyRuyijingubangFour") then destroyEquip(room, move, "RYJGBfour_ID") end
						end
					end
				end
				--2.金箍棒离开的区域不是装备区：如果不是移到装备区，立即销毁
			elseif not move.from_places:contains(sgs.Player_PlaceEquip) and move.to_place ~= sgs.Player_PlaceEquip then
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if card:isKindOf("XyRuyijingubangOne") then destroyEquip(room, move, "RYJGBone_ID") end
					if card:isKindOf("XyRuyijingubangTwo") then destroyEquip(room, move, "RYJGBtwo_ID") end
					if card:isKindOf("XyRuyijingubangThree") then destroyEquip(room, move, "RYJGBthree_ID") end
					if card:isKindOf("XyRuyijingubangFour") then destroyEquip(room, move, "RYJGBfour_ID") end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
xy_sunwukong:addSkill(xyruyi)
if not sgs.Sanguosha:getSkill("xyruyiJGB") then skills:append(xyruyiJGB) end

--==专属装备·如意金箍棒（武器）==--
--专属技能·“调整”攻击范围”--
XyRuyijingubangsCard = sgs.CreateSkillCard {
	name = "XyRuyijingubangs",
	handling_method = sgs.Card_MethodNone,
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		local wp = source:getWeapon()
		source:addToPile("xyruyiBK", wp)
		--置换--
		local cards, cards_copy = sgs.CardList(), sgs.CardList()
		for _, id in sgs.qlist(self:getSubcards()) do
			local card = sgs.Sanguosha:getCard(id)
			if card:isKindOf("XyRuyijingubangOne") or card:isKindOf("XyRuyijingubangTwo")
				or card:isKindOf("XyRuyijingubangThree") or card:isKindOf("XyRuyijingubangFour") then
				cards:append(card)
				cards_copy:append(card)
			end
		end
		if not cards:isEmpty() then
			local JGB
			while not JGB do
				if cards:isEmpty() then break end
				if not JGB then
					JGB = cards:at(math.random(0, cards:length() - 1))
					for _, card in sgs.qlist(cards_copy) do
						if card:getSubtype() == JGB:getSubtype() then
							cards:removeOne(card)
						end
					end
				end
			end
			if JGB then
				local Moves = sgs.CardsMoveList()
				local equip = JGB:getRealCard():toEquipCard()
				local equip_index = equip:location()
				if source:getEquip(equip_index) == nil and source:hasEquipArea(equip_index) then
					room:broadcastSkillInvoke("xyruyi")
					Moves:append(sgs.CardsMoveStruct(JGB:getId(), source, sgs.Player_PlaceEquip, sgs.CardMoveReason()))
				elseif source:getEquip(equip_index) ~= nil and source:hasEquipArea(equip_index) then
					room:setPlayerFlag(source, "xyruyi_OEAnonTrigger")
					source:throwEquipArea(equip_index)
					source:obtainEquipArea(equip_index)
					room:setPlayerFlag(source, "-xyruyi_OEAnonTrigger")
					room:broadcastSkillInvoke("xyruyi")
					Moves:append(sgs.CardsMoveStruct(JGB:getId(), source, sgs.Player_PlaceEquip, sgs.CardMoveReason()))
				end
				room:moveCardsAtomic(Moves, true)
			end
		end
	end,
}
XyRuyijingubangs = sgs.CreateOneCardViewAsSkill {
	name = "XyRuyijingubangs&",
	filter_pattern = ".|.|.|xyruyiBK",
	expand_pile = "xyruyiBK",
	view_as = function(self, card)
		local bk = XyRuyijingubangsCard:clone()
		bk:addSubcard(card)
		return bk
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#XyRuyijingubangs") and player:getWeapon() ~= nil
			and (player:getWeapon():isKindOf("XyRuyijingubangOne") or player:getWeapon():isKindOf("XyRuyijingubangTwo")
				or player:getWeapon():isKindOf("XyRuyijingubangThree") or player:getWeapon():isKindOf("XyRuyijingubangFour"))
	end,
}
if not sgs.Sanguosha:getSkill("XyRuyijingubangs") then skills:append(XyRuyijingubangs) end
----
--攻击范围1：
XyRuyijingubangOne = sgs.CreateWeapon {
	name = "_xy_ruyijingubang_one",
	class_name = "XyRuyijingubangOne",
	range = 1,
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, "XyRuyijingubangs")
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "XyRuyijingubangs", false, true)
	end,
}
for i = 0, 1, 1 do
	local card = XyRuyijingubangOne:clone()
	card:setSuit(2)
	card:setNumber(9)
	card:setParent(extension_x)
end
xyruyiOne = sgs.CreateTargetModSkill { --距离为1的专属效果
	name = "xyruyiOne",
	residue_func = function(self, player)
		if player:getWeapon() ~= nil and player:getWeapon():isKindOf("XyRuyijingubangOne") then
			return 1000
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("xyruyiOne") then skills:append(xyruyiOne) end
--攻击范围2：
XyRuyijingubangTwo = sgs.CreateWeapon {
	name = "_xy_ruyijingubang_two",
	class_name = "XyRuyijingubangTwo",
	range = 2,
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, "XyRuyijingubangs")
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "XyRuyijingubangs", false, true)
	end,
}
for i = 0, 1, 1 do
	local card = XyRuyijingubangTwo:clone()
	card:setSuit(2)
	card:setNumber(9)
	card:setParent(extension_x)
end
xyruyiTwo = sgs.CreateTriggerSkill { --距离为2的专属效果
	name = "xyruyiTwo",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.ConfirmDamage },
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.card:isKindOf("Slash") then
			local hurt = damage.damage
			damage.damage = hurt + 1
			data:setValue(damage)
		end
	end,
	can_trigger = function(self, player)
		return player and player:getWeapon() ~= nil and player:getWeapon():isKindOf("XyRuyijingubangTwo")
	end,
}
if not sgs.Sanguosha:getSkill("xyruyiTwo") then skills:append(xyruyiTwo) end
--攻击范围3(初始装备)：
XyRuyijingubangThree = sgs.CreateWeapon {
	name = "_xy_ruyijingubang_three",
	class_name = "XyRuyijingubangThree",
	range = 3,
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, "XyRuyijingubangs")
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "XyRuyijingubangs", false, true)
	end,
}
for i = 0, 1, 1 do
	local card = XyRuyijingubangThree:clone()
	card:setSuit(2)
	card:setNumber(9)
	card:setParent(extension_x)
end
xyruyiThree = sgs.CreateTriggerSkill { --距离为3的专属效果
	name = "xyruyiThree",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.TargetSpecified },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") and use.from:objectName() == player:objectName() then
			local no_respond_list = use.no_respond_list
			for _, p in sgs.qlist(use.to) do
				room:sendCompulsoryTriggerLog(player, self:objectName())
				table.insert(no_respond_list, p:objectName())
			end
			use.no_respond_list = no_respond_list
			data:setValue(use)
		end
	end,
	can_trigger = function(self, player)
		return player:getWeapon() ~= nil and player:getWeapon():isKindOf("XyRuyijingubangThree")
	end,
}
if not sgs.Sanguosha:getSkill("xyruyiThree") then skills:append(xyruyiThree) end
--攻击范围4：
XyRuyijingubangFour = sgs.CreateWeapon {
	name = "_xy_ruyijingubang_four",
	class_name = "XyRuyijingubangFour",
	range = 4,
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, "XyRuyijingubangs")
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "XyRuyijingubangs", false, true)
	end,
}
for i = 0, 1, 1 do
	local card = XyRuyijingubangFour:clone()
	card:setSuit(2)
	card:setNumber(9)
	card:setParent(extension_x)
end
xyruyiFour = sgs.CreateTargetModSkill { --距离为4的专属效果
	name = "xyruyiFour",
	extra_target_func = function(self, player)
		if player:getWeapon() ~= nil and player:getWeapon():isKindOf("XyRuyijingubangFour") then
			return 1
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("xyruyiFour") then skills:append(xyruyiFour) end
--------


--

--XYW02 东海龙王
xy_donghailongwang = sgs.General(extension, "xy_donghailongwang", "qun", 3, true)
xy_donghailongwang:addSkill("xydizhusoul")

xylonggong = sgs.CreateTriggerSkill {
	name = "xylonggong",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.DamageInflicted, sgs.EventPhaseChanging },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DamageInflicted then
			local damage = data:toDamage()
			if damage.from and damage.to:objectName() == player:objectName()
				and player:getMark("&xylonggongUsed") == 0 and player:hasSkill(self:objectName()) then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:broadcastSkillInvoke(self:objectName())
					room:addPlayerMark(player, "&xylonggongUsed")
					local equips = {}
					for _, id in sgs.qlist(room:getDrawPile()) do
						local bingqi = sgs.Sanguosha:getCard(id)
						if bingqi:isKindOf("EquipCard") then
							table.insert(equips, bingqi)
						end
					end
					if #equips > 0 then
						local bq = equips[math.random(1, #equips)]
						if bq then room:obtainCard(damage.from, bq) end
					end
					return true
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, "&xylonggongUsed", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
xy_donghailongwang:addSkill(xylonggong)

function GetColor(card)
	if card:isRed() then return "red" elseif card:isBlack() then return "black" end
end

xysitianCard = sgs.CreateSkillCard {
	name = "xysitianCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		local tianqiyubao = { "1", "2", "3", "4", "5" }
		local n = 2
		while n >= 0 do
			local bukeneng = tianqiyubao[math.random(1, #tianqiyubao)]
			table.removeOne(tianqiyubao, bukeneng)
			n = n - 1
		end
		local choice = room:askForChoice(source, "xysitianTQYB", table.concat(tianqiyubao, "+"))
		if choice == "1" then --烈日
			room:broadcastSkillInvoke("xysitianAudio", 1)
			room:doLightbox("$xysitianAudio1")
			for _, p in sgs.qlist(room:getOtherPlayers(source)) do
				room:damage(sgs.DamageStruct("xysitian", source, p, 1, sgs.DamageStruct_Fire))
			end
		elseif choice == "2" then --雷电
			room:broadcastSkillInvoke("xysitianAudio", 2)
			room:doLightbox("$xysitianAudio2")
			for _, p in sgs.qlist(room:getOtherPlayers(source)) do
				local judge = sgs.JudgeStruct()
				judge.pattern = ".|spade|2~9"
				judge.good = true
				judge.reason = "xysitian"
				judge.who = p
				room:judge(judge)
				if judge:isGood() then
					room:broadcastSkillInvoke("xysitianAudio", 2) --surprise!
					room:damage(sgs.DamageStruct("xysitian", nil, p, 3, sgs.DamageStruct_Thunder))
				end
			end
		elseif choice == "3" then --大浪
			room:broadcastSkillInvoke("xysitianAudio", 3)
			room:doLightbox("$xysitianAudio3")
			for _, p in sgs.qlist(room:getOtherPlayers(source)) do
				if p:getEquips():length() > 0 then
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					for _, e in sgs.qlist(p:getEquips()) do
						dummy:addSubcard(e:getEffectiveId())
					end
					room:throwCard(dummy, p, source)
					dummy:deleteLater()
				else
					room:loseHp(p, 1)
				end
			end
		elseif choice == "4" then --暴雨
			room:broadcastSkillInvoke("xysitianAudio", 4)
			room:doLightbox("$xysitianAudio4")
			local victim = room:askForPlayerChosen(source, room:getAllPlayers(), "xysitian")
			if victim:isKongcheng() then
				room:loseHp(victim, 1)
			else
				room:throwCard(victim:wholeHandCards(), victim, source)
			end
		elseif choice == "5" then --大雾
			room:broadcastSkillInvoke("xysitianAudio", 5)
			room:doLightbox("$xysitianAudio5")
			for _, p in sgs.qlist(room:getOtherPlayers(source)) do
				room:setPlayerMark(p, "&xysitianDW", 1)
			end
		end
	end,
}
xysitian = sgs.CreateViewAsSkill {
	name = "xysitian",
	n = 2,
	waked_skills = "xysitianAudio",
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
			local st_card = xysitianCard:clone()
			st_card:addSubcard(cardA)
			st_card:addSubcard(cardB)
			st_card:setSkillName(self:objectName())
			return st_card
		end
	end,
	enabled_at_play = function(self, player)
		return player:getHandcardNum() >= 2
	end,
}
xysitianDaWu = sgs.CreateTriggerSkill { --“大雾”效果
	name = "xysitianDaWu",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.TargetConfirming, sgs.JinkEffect },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetConfirming then
			local use = data:toCardUse()
			if use.card and use.card:isKindOf("BasicCard") and use.from:getMark("&xysitianDW") > 0 then
				local aoguang = room:findPlayerBySkillName("xysitian")
				if aoguang then room:sendCompulsoryTriggerLog(aoguang, "xysitian") end
				room:setPlayerMark(use.from, "&xysitianDW", 0)
				local nullified_list = use.nullified_list
				table.insert(nullified_list, player:objectName())
				use.nullified_list = nullified_list
				data:setValue(use)
			end
		elseif event == sgs.JinkEffect then --专门处理【闪】无效化
			local cd = data:toCard()
			if cd:isKindOf("BasicCard") and player:getMark("&xysitianDW") > 0 then
				local aoguang = room:findPlayerBySkillName("xysitian")
				if aoguang then room:sendCompulsoryTriggerLog(aoguang, "xysitian") end
				room:setPlayerMark(player, "&xysitianDW", 0)
				return true
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
xy_donghailongwang:addSkill(xysitian)
xy_donghailongwang:addRelateSkill("xysitianAudio")
if not sgs.Sanguosha:getSkill("xysitianDaWu") then skills:append(xysitianDaWu) end
--“司天”配音（空壳）
xysitianAudio = sgs.CreateTriggerSkill {
	name = "xysitianAudio",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end,
}
if not sgs.Sanguosha:getSkill("xysitianAudio") then skills:append(xysitianAudio) end

--XYW03 涛神
xy_taoshen = sgs.General(extension, "xy_taoshen", "qun", 3, true)
xy_taoshen:addSkill("xydizhusoul")

xynutao = sgs.CreateTriggerSkill {
	name = "xynutao",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = { sgs.CardUsed, sgs.Damage, sgs.EventPhaseEnd },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.from:objectName() == player:objectName() and use.card:isKindOf("TrickCard") and player:hasSkill(self:objectName()) then
				local nts = {}
				for _, p in sgs.qlist(use.to) do
					if p:objectName() ~= player:objectName() then
						table.insert(nts, p)
					end
				end
				if #nts > 0 then
					local nt = nts[math.random(1, #nts)]
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
					room:damage(sgs.DamageStruct(self:objectName(), player, nt, 1, sgs.DamageStruct_Thunder))
				end
			end
		elseif event == sgs.Damage then
			local damage = data:toDamage()
			if damage.from:objectName() == player:objectName() and damage.nature == sgs.DamageStruct_Thunder
				and player:getPhase() == sgs.Player_Play and player:hasSkill(self:objectName()) then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(3, 4))
				room:addPlayerMark(player, "&xynutao")
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Play then
				room:setPlayerMark(player, "&xynutao", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
xynutaoo = sgs.CreateTargetModSkill {
	name = "xynutaoo",
	--pattern = "Slash",
	residue_func = function(self, player)
		local n = player:getMark("&xynutao")
		if n > 0 then
			return n
		else
			return 0
		end
	end,
}
xy_taoshen:addSkill(xynutao)
if not sgs.Sanguosha:getSkill("xynutaoo") then skills:append(xynutaoo) end

--XYW04 李白
sj_libai = sgs.General(extension, "sj_libai", "qun", 3, true)
sj_libai:addSkill("xydizhusoul")

sjjiuxian = sgs.CreateViewAsSkill {
	name = "sjjiuxian",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isKindOf("AOE") or to_select:isKindOf("GlobalEffect") or to_select:isKindOf("IronChain")
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local ana = sgs.Sanguosha:cloneCard("analeptic", cards[1]:getSuit(), cards[1]:getNumber())
			ana:setSkillName(self:objectName())
			ana:addSubcard(cards[1])
			return ana
		end
	end,
	enabled_at_play = function(self, player)
		local newana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
		if player:isCardLimited(newana, sgs.Card_MethodUse) or player:isProhibited(player, newana) then return false end
		return player:usedTimes("Analeptic") <=
		sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, player, newana)
	end,
	enabled_at_response = function(self, player, pattern)
		return string.find(pattern, "analeptic")
	end,
}
sjjiuxianMAX = sgs.CreateTargetModSkill {
	name = "sjjiuxianMAX",
	pattern = "Analeptic",
	residue_func = function(self, player)
		if player:hasSkill("sjjiuxian") then
			return 1000
		else
			return 0
		end
	end,
}
sj_libai:addSkill(sjjiuxian)
if not sgs.Sanguosha:getSkill("sjjiuxianMAX") then skills:append(sjjiuxianMAX) end

sjshixian = sgs.CreateTriggerSkill {
	name = "sjshixian",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.CardUsed, sgs.CardResponded, sgs.GameStart },
	waked_skills = "lb_yayunbiao",
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed or event == sgs.CardResponded then
			local card = nil
			if event == sgs.CardUsed then
				local use = data:toCardUse()
				card = use.card
			else
				local resp = data:toCardResponse()
				if resp.m_isUse then
					card = resp.m_card
				end
			end
			if card and not card:isKindOf("SkillCard") and card:getHandlingMethod() == sgs.Card_MethodUse
				and player:getMark(self:objectName()) == 0 then
				--==提取韵母==--
				--/a/:【杀(包括属性杀)】【万箭齐发】【藤甲】
				if card:isKindOf("Slash") or card:objectName() == "archery_attack" or card:objectName() == "vine" then
					if player:getMark("&yyb_a") > 0 then room:addPlayerMark(player, self:objectName()) end --押韵启动标记，同时防止套娃
					for _, yyb in sgs.list(player:getMarkNames()) do
						if string.find(yyb, "&yyb_") then
							room:setPlayerMark(player, yyb, 0)
						end
					end
					room:addPlayerMark(player, "&yyb_a")
					--/ai/：【黑光铠】
				elseif card:objectName() == "heiguangkai" then
					if player:getMark("&yyb_ai") > 0 then room:addPlayerMark(player, self:objectName()) end
					for _, yyb in sgs.list(player:getMarkNames()) do
						if string.find(yyb, "&yyb_") then
							room:setPlayerMark(player, yyb, 0)
						end
					end
					room:addPlayerMark(player, "&yyb_ai")
					--/an/：【闪】【兵粮寸断】【铁索连环】【闪电】【雌雄双股剑】【青釭剑】【寒冰剑】【朱雀羽扇】【爪黄飞电】【大宛】【逐近弃远】【随机应变】【乌铁锁链】【五行鹤翎扇】
				elseif card:objectName() == "jink" or card:objectName() == "supply_shortage" or card:objectName() == "iron_chain"
					or card:objectName() == "lightning" or card:objectName() == "double_sword" or card:objectName() == "qinggang_sword"
					or card:objectName() == "ice_sword" or card:objectName() == "fan" or card:objectName() == "zhuahuangfeidian"
					or card:objectName() == "dayuan" or card:objectName() == "zhujinqiyuan" or card:objectName() == "suijiyingbian"
					or card:objectName() == "wutiesuolian" or card:objectName() == "wuxinghelingshan" then
					if player:getMark("&yyb_an") > 0 then room:addPlayerMark(player, self:objectName()) end
					for _, yyb in sgs.list(player:getMarkNames()) do
						if string.find(yyb, "&yyb_") then
							room:setPlayerMark(player, yyb, 0)
						end
					end
					room:addPlayerMark(player, "&yyb_an")
					--/ang/：【顺手牵羊】
				elseif card:objectName() == "snatch" then
					if player:getMark("&yyb_ang") > 0 then room:addPlayerMark(player, self:objectName()) end
					for _, yyb in sgs.list(player:getMarkNames()) do
						if string.find(yyb, "&yyb_") then
							room:setPlayerMark(player, yyb, 0)
						end
					end
					room:addPlayerMark(player, "&yyb_ang")
					--/ao/：【桃】【过河拆桥】【青龙偃月刀】【丈八蛇矛】【古锭刀】
				elseif card:objectName() == "peach" or card:objectName() == "dismantlement" or card:objectName() == "blade"
					or card:objectName() == "spear" or card:objectName() == "guding_blade" then
					if player:getMark("&yyb_ao") > 0 then room:addPlayerMark(player, self:objectName()) end
					for _, yyb in sgs.list(player:getMarkNames()) do
						if string.find(yyb, "&yyb_") then
							room:setPlayerMark(player, yyb, 0)
						end
					end
					room:addPlayerMark(player, "&yyb_ao")
					--/en/：【借刀杀人】【八卦阵】
				elseif card:objectName() == "collateral" or card:objectName() == "eight_diagram" then
					if player:getMark("&yyb_en") > 0 then room:addPlayerMark(player, self:objectName()) end
					for _, yyb in sgs.list(player:getMarkNames()) do
						if string.find(yyb, "&yyb_") then
							room:setPlayerMark(player, yyb, 0)
						end
					end
					room:addPlayerMark(player, "&yyb_en")
					--/eng/：【五谷丰登】
				elseif card:objectName() == "amazing_grace" then
					if player:getMark("&yyb_eng") > 0 then room:addPlayerMark(player, self:objectName()) end
					for _, yyb in sgs.list(player:getMarkNames()) do
						if string.find(yyb, "&yyb_") then
							room:setPlayerMark(player, yyb, 0)
						end
					end
					room:addPlayerMark(player, "&yyb_eng")
					--/i/：【桃园结义】【无懈可击】【方天画戟】【白银狮子】【洞烛先机】【出其不意】
				elseif card:objectName() == "god_salvation" or card:objectName() == "nullification" or card:objectName() == "halberd"
					or card:objectName() == "silver_lion" or card:objectName() == "dongzhuxianji" or card:objectName() == "chuqibuyi" then
					if player:getMark("&yyb_i") > 0 then room:addPlayerMark(player, self:objectName()) end
					for _, yyb in sgs.list(player:getMarkNames()) do
						if string.find(yyb, "&yyb_") then
							room:setPlayerMark(player, yyb, 0)
						end
					end
					room:addPlayerMark(player, "&yyb_i")
					--/in/：【南蛮入侵】
				elseif card:objectName() == "savage_assault" then
					if player:getMark("&yyb_in") > 0 then room:addPlayerMark(player, self:objectName()) end
					for _, yyb in sgs.list(player:getMarkNames()) do
						if string.find(yyb, "&yyb_") then
							room:setPlayerMark(player, yyb, 0)
						end
					end
					room:addPlayerMark(player, "&yyb_in")
					--/ing/：【绝影】【紫骍】【护心镜】
				elseif card:objectName() == "jueying" or card:objectName() == "zixing" or card:objectName() == "huxinjing" then
					if player:getMark("&yyb_ing") > 0 then room:addPlayerMark(player, self:objectName()) end
					for _, yyb in sgs.list(player:getMarkNames()) do
						if string.find(yyb, "&yyb_") then
							room:setPlayerMark(player, yyb, 0)
						end
					end
					room:addPlayerMark(player, "&yyb_ing")
					--/iu+ou/：【酒】【骅骝】；【决斗】【无中生有】
				elseif card:objectName() == "analeptic" or card:objectName() == "hualiu"
					or card:objectName() == "duel" or card:objectName() == "ex_nihilo" then
					if player:getMark("&yyb_iuou") > 0 then room:addPlayerMark(player, self:objectName()) end
					for _, yyb in sgs.list(player:getMarkNames()) do
						if string.find(yyb, "&yyb_") then
							room:setPlayerMark(player, yyb, 0)
						end
					end
					room:addPlayerMark(player, "&yyb_iuou")
					--/ong/：【火攻】【麒麟弓】
				elseif card:objectName() == "fire_attack" or card:objectName() == "kylin_bow" then
					if player:getMark("&yyb_ong") > 0 then room:addPlayerMark(player, self:objectName()) end
					for _, yyb in sgs.list(player:getMarkNames()) do
						if string.find(yyb, "&yyb_") then
							room:setPlayerMark(player, yyb, 0)
						end
					end
					room:addPlayerMark(player, "&yyb_ong")
					--/u/：【乐不思蜀】【诸葛连弩】【贯石斧】【的卢】【赤兔】【天机图】【太公阴符】
				elseif card:objectName() == "indulgence" or card:objectName() == "crossbow" or card:objectName() == "axe" or card:objectName() == "dilu"
					or card:objectName() == "chitu" or card:objectName() == "tianjitu" or card:objectName() == "taigongyinfu" then
					if player:getMark("&yyb_u") > 0 then room:addPlayerMark(player, self:objectName()) end
					for _, yyb in sgs.list(player:getMarkNames()) do
						if string.find(yyb, "&yyb_") then
							room:setPlayerMark(player, yyb, 0)
						end
					end
					room:addPlayerMark(player, "&yyb_u")
					--/ue/：【铜雀】
				elseif card:objectName() == "tongque" then
					if player:getMark("&yyb_ue") > 0 then room:addPlayerMark(player, self:objectName()) end
					for _, yyb in sgs.list(player:getMarkNames()) do
						if string.find(yyb, "&yyb_") then
							room:setPlayerMark(player, yyb, 0)
						end
					end
					room:addPlayerMark(player, "&yyb_ue")
					--/un/：【仁王盾】【水淹七军】
				elseif card:objectName() == "renwang_shield" or card:objectName() == "drowning" then
					if player:getMark("&yyb_un") > 0 then room:addPlayerMark(player, self:objectName()) end
					for _, yyb in sgs.list(player:getMarkNames()) do
						if string.find(yyb, "&yyb_") then
							room:setPlayerMark(player, yyb, 0)
						end
					end
					room:addPlayerMark(player, "&yyb_un")
				else
					return false
				end
				----------------
				if player:getMark(self:objectName()) > 0 then
					if room:askForSkillInvoke(player, self:objectName(), data) then
						room:broadcastSkillInvoke(self:objectName())
						room:drawCards(player, 1, self:objectName())
						if event == sgs.CardUsed then
							local use = data:toCardUse()
							local can_useagain = false
							for _, p in sgs.qlist(use.to) do
								if not player:isProhibited(p, use.card) then
									can_useagain = true
								end
							end
							if can_useagain then
								use.card:cardOnUse(room, use)
							end
						end
						room:setPlayerMark(player, self:objectName(), 0)
					end
				end
			end
		elseif event == sgs.GameStart then
			if not player:hasSkill("lb_yayunbiao") then
				room:attachSkillToPlayer(player, "lb_yayunbiao")
			end
		end
	end,
}
sj_libai:addSkill(sjshixian)
sj_libai:addRelateSkill("lb_yayunbiao")
--【押韵表】--
lb_yayunbiao = sgs.CreateTriggerSkill {
	name = "lb_yayunbiao&",
	priority = 6,
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end,
}
lb_yayunbiaos = sgs.CreateTriggerSkill {
	name = "lb_yayunbiaos",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.EventAcquireSkill, sgs.EventLoseSkill },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventAcquireSkill then
			if data:toString() == "sjshixian" and not player:hasSkill("lb_yayunbiao") then
				room:attachSkillToPlayer(player, "lb_yayunbiao")
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == "sjshixian" and player:hasSkill("lb_yayunbiao") then
				room:detachSkillFromPlayer(player, "lb_yayunbiao", true)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("lb_yayunbiao") then skills:append(lb_yayunbiao) end
if not sgs.Sanguosha:getSkill("lb_yayunbiaos") then skills:append(lb_yayunbiaos) end

--XYW05 欢乐杀李白
sj_libai_joy = sgs.General(extension, "sj_libai_joy", "qun", 3, true)
sj_libai_joy:addSkill("xydizhusoul")

sjshixian_joy = sgs.CreateTriggerSkill {
	name = "sjshixian_joy",
	frequency = sgs.Skill_Compulsory,
	events = { sgs.EventPhaseStart },
	waked_skills = "sjshixian_jys, sjshixian_xln, sjshixian_jjj, sjshixian_xks",
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_RoundStart then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			if player:hasSkill("sjshixian_jys") then
				room:detachSkillFromPlayer(player, "sjshixian_jys", false, true)
			end
			if player:hasSkill("sjshixian_xln") then
				room:detachSkillFromPlayer(player, "sjshixian_xln", false, true)
			end
			if player:hasSkill("sjshixian_jjj") then
				room:detachSkillFromPlayer(player, "sjshixian_jjj", false, true)
			end
			if player:hasSkill("sjshixian_xks") then
				room:detachSkillFromPlayer(player, "sjshixian_xks", false, true)
			end
			local card_ids = room:getNCards(4)
			room:fillAG(card_ids)
			local jys, xln, jjj, xks = false, false, false, false
			for _, sp in sgs.qlist(card_ids) do
				local shipian = sgs.Sanguosha:getCard(sp)
				if shipian:getSuit() == sgs.Card_Heart then jys = true end
				if shipian:getSuit() == sgs.Card_Diamond then xln = true end
				if shipian:getSuit() == sgs.Card_Club then jjj = true end
				if shipian:getSuit() == sgs.Card_Spade then xks = true end
			end
			--创作《静夜思》
			if jys then
				room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
				if not player:hasSkill("sjshixian_jys") then room:acquireSkill(player, "sjshixian_jys") end
				room:getThread():delay()
			end
			--创作《行路难》
			if xln then
				room:broadcastSkillInvoke(self:objectName(), math.random(3, 6))
				if not player:hasSkill("sjshixian_xln") then room:acquireSkill(player, "sjshixian_xln") end
				room:getThread():delay()
			end
			--创作《将进酒》
			if jjj then
				room:broadcastSkillInvoke(self:objectName(), math.random(7, 10))
				if not player:hasSkill("sjshixian_jjj") then room:acquireSkill(player, "sjshixian_jjj") end
				room:getThread():delay()
			end
			--创作《侠客行》
			if xks then
				room:broadcastSkillInvoke(self:objectName(), math.random(11, 12))
				if not player:hasSkill("sjshixian_xks") then room:acquireSkill(player, "sjshixian_xks") end
				room:getThread():delay()
			end
			local to_get = sgs.IntList()
			local card_ids_ = card_ids
			for _, i in sgs.qlist(card_ids_) do --剔除所有点数不重复的牌
				local num = sgs.Sanguosha:getCard(i):getNumber()
				if num == 1 then       --不考虑范围不在1~13之内的点数了
					room:addPlayerMark(player, "sjsxjoyRPTA")
				elseif num == 2 then
					room:addPlayerMark(player, "sjsxjoyRPT2")
				elseif num == 3 then
					room:addPlayerMark(player, "sjsxjoyRPT3")
				elseif num == 4 then
					room:addPlayerMark(player, "sjsxjoyRPT4")
				elseif num == 5 then
					room:addPlayerMark(player, "sjsxjoyRPT5")
				elseif num == 6 then
					room:addPlayerMark(player, "sjsxjoyRPT6")
				elseif num == 7 then
					room:addPlayerMark(player, "sjsxjoyRPT7")
				elseif num == 8 then
					room:addPlayerMark(player, "sjsxjoyRPT8")
				elseif num == 9 then
					room:addPlayerMark(player, "sjsxjoyRPT9")
				elseif num == 10 then
					room:addPlayerMark(player, "sjsxjoyRPT10")
				elseif num == 11 then
					room:addPlayerMark(player, "sjsxjoyRPTJ")
				elseif num == 12 then
					room:addPlayerMark(player, "sjsxjoyRPTQ")
				elseif num == 13 then
					room:addPlayerMark(player, "sjsxjoyRPTK")
				end
			end
			for i = 0, 150 do
				for _, i in sgs.qlist(card_ids_) do
					local num = sgs.Sanguosha:getCard(i):getNumber()
					if (num == 1 and player:getMark("sjsxjoyRPTA") <= 1) or (num == 2 and player:getMark("sjsxjoyRPT2") <= 1) or (num == 3 and player:getMark("sjsxjoyRPT3") <= 1)
						or (num == 4 and player:getMark("sjsxjoyRPT4") <= 1) or (num == 5 and player:getMark("sjsxjoyRPT5") <= 1) or (num == 6 and player:getMark("sjsxjoyRPT6") <= 1)
						or (num == 7 and player:getMark("sjsxjoyRPT7") <= 1) or (num == 8 and player:getMark("sjsxjoyRPT8") <= 1) or (num == 9 and player:getMark("sjsxjoyRPT9") <= 1)
						or (num == 10 and player:getMark("sjsxjoyRPT10") <= 1) or (num == 11 and player:getMark("sjsxjoyRPTJ") <= 1) or (num == 12 and player:getMark("sjsxjoyRPTQ") <= 1)
						or (num == 13 and player:getMark("sjsxjoyRPTK") <= 1) then
						card_ids:removeOne(i)
					end
				end
			end
			room:setPlayerMark(player, "sjsxjoyRPTA", 0)
			room:setPlayerMark(player, "sjsxjoyRPT2", 0)
			room:setPlayerMark(player, "sjsxjoyRPT3", 0)
			room:setPlayerMark(player, "sjsxjoyRPT4", 0)
			room:setPlayerMark(player, "sjsxjoyRPT5", 0)
			room:setPlayerMark(player, "sjsxjoyRPT6", 0)
			room:setPlayerMark(player, "sjsxjoyRPT7", 0)
			room:setPlayerMark(player, "sjsxjoyRPT8", 0)
			room:setPlayerMark(player, "sjsxjoyRPT9", 0)
			room:setPlayerMark(player, "sjsxjoyRPT10", 0)
			room:setPlayerMark(player, "sjsxjoyRPTJ", 0)
			room:setPlayerMark(player, "sjsxjoyRPTQ", 0)
			room:setPlayerMark(player, "sjsxjoyRPTK", 0)
			while not card_ids:isEmpty() do
				for _, card_id in sgs.qlist(card_ids) do
					card_ids:removeOne(card_id)
					to_get:append(card_id)
				end
			end
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			if not to_get:isEmpty() then
				if room:askForSkillInvoke(player, "@sjshixian_joy_getCards", data) then
					dummy:addSubcards(to_get)
					player:obtainCard(dummy)
				else
					room:getThread():delay(2400)
				end
			end
			dummy:deleteLater()
			room:clearAG()
		end
	end,
}
sj_libai_joy:addSkill(sjshixian_joy)
sj_libai_joy:addRelateSkill("sjshixian_jys")
sj_libai_joy:addRelateSkill("sjshixian_xln")
sj_libai_joy:addRelateSkill("sjshixian_jjj")
sj_libai_joy:addRelateSkill("sjshixian_xks")
--《静夜思》
sjshixian_jysCard = sgs.CreateSkillCard {
	name = "sjshixian_jysCard",
	will_throw = false,
	filter = function(self, targets, to_select, player)
		local ids = self:getSubcards()
		local card = nil
		for _, id in sgs.qlist(ids) do
			card = sgs.Sanguosha:getCard(id)
		end
		if card and card:targetFixed() then
			return false
		end
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		if card and card:targetFilter(qtargets, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, qtargets) then
			return true
		end
		return false
	end,
	target_fixed = function(self)
		local ids = self:getSubcards()
		local card = nil
		for _, id in sgs.qlist(ids) do
			card = sgs.Sanguosha:getCard(id)
		end
		if card and card:targetFixed() then
			return true
		end
		return false
	end,
	feasible = function(self, targets)
		local ids = self:getSubcards()
		local card = nil
		for _, id in sgs.qlist(ids) do
			card = sgs.Sanguosha:getCard(id)
		end
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		if card and card:targetsFeasible(qtargets, sgs.Self) then
			return true
		end
		return false
	end,
	on_validate = function(self, cardUse)
		local source = cardUse.from
		local room = source:getRoom()
		local ids = self:getSubcards()
		local card = nil
		for _, id in sgs.qlist(ids) do
			card = sgs.Sanguosha:getCard(id)
		end
		room:broadcastSkillInvoke("sjshixian_joy", math.random(1, 2))
		return card
	end,
}
sjshixian_jysVS = sgs.CreateOneCardViewAsSkill {
	name = "sjshixian_jys",
	filter_pattern = ".|.|.|sjshixian_jys",
	expand_pile = "sjshixian_jys",
	view_as = function(self, originalCard)
		local jysCard = sjshixian_jysCard:clone()
		jysCard:addSubcard(originalCard)
		jysCard:setSkillName(self:objectName())
		return jysCard
	end,
	response_pattern = "@@sjshixian_jys",
}
sjshixian_jys = sgs.CreateTriggerSkill {
	name = "sjshixian_jys&",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.EventPhaseEnd },
	view_as_skill = sjshixian_jysVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke("sjshixian_joy", math.random(1, 2))
				local ids = room:getNCards(1, false)
				room:fillAG(ids, player)
				local card = sgs.Sanguosha:getCard(ids:first())
				player:addToPile("sjshixian_jys", ids)
				room:askForUseCard(player, "@@sjshixian_jys", "@sjshixian_jys-usecard:" .. card:objectName())
				if player:getPile("sjshixian_jys"):length() > 0 then
					local dummy_jys = sgs.Sanguosha:cloneCard("slash")
					dummy_jys:addSubcards(player:getPile("sjshixian_jys"))
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), nil, "", nil)
					room:moveCardTo(dummy_jys, nil, nil, sgs.Player_DrawPile, reason, true)
					dummy_jys:deleteLater()
				end
				room:clearAG()
			end
		elseif player:getPhase() == sgs.Player_Discard then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke("sjshixian_joy", math.random(1, 2))
			room:drawCards(player, 1, self:objectName(), false)
		end
	end,
}
if not sgs.Sanguosha:getSkill("sjshixian_jys") then skills:append(sjshixian_jys) end
--《行路难》
sjshixian_xln = sgs.CreateTriggerSkill {
	name = "sjshixian_xln&",
	global = true,
	priority = { 5, 5, 5 },
	frequency = sgs.Skill_Frequent,
	events = { sgs.TargetConfirming, sgs.CardFinished, sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.TargetConfirming then
			if use.card and use.card:isKindOf("Slash") and use.from:objectName() ~= player:objectName() and use.to:contains(player)
				and player:getPhase() == sgs.Player_NotActive and player:hasSkill(self:objectName()) and not player:hasFlag(self:objectName()) then
				room:setCardFlag(use.card, self:objectName())
				room:setPlayerFlag(player, self:objectName())
			end
		elseif event == sgs.CardFinished then
			if use.card and use.card:hasFlag(self:objectName()) then
				room:setCardFlag(use.card, "-sjshixian_xln")
				for _, p in sgs.qlist(use.to) do
					if p:hasFlag(self:objectName()) then
						room:setPlayerFlag(player, "-sjshixian_xln")
						if p:hasSkill(self:objectName()) then
							room:sendCompulsoryTriggerLog(p, self:objectName())
							room:broadcastSkillInvoke("sjshixian_joy", math.random(3, 6))
							room:addPlayerMark(p, "&sjshixian_xln")
						end
					end
				end
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				room:setPlayerMark(player, "&sjshixian_xln", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
sjshixian_xlnan = sgs.CreateDistanceSkill {
	name = "sjshixian_xlnan",
	correct_func = function(self, from, to)
		if to:getMark("&sjshixian_xln") > 0 then
			local n = to:getMark("&sjshixian_xln")
			return n
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("sjshixian_xln") then skills:append(sjshixian_xln) end
if not sgs.Sanguosha:getSkill("sjshixian_xlnan") then skills:append(sjshixian_xlnan) end
--《将进酒》
sjshixian_jjj = sgs.CreateTriggerSkill {
	name = "sjshixian_jjj&",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = { sgs.EventPhaseStart },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_RoundStart then
			for _, lbs in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if player:objectName() == lbs:objectName() or lbs:isKongcheng() then continue end
				local dis = room:askForDiscard(lbs, self:objectName(), 1, 1, true, false, "@sjshixian_jjj-distoivk")
				if dis then
					room:broadcastSkillInvoke("sjshixian_joy", math.random(7, 10))
					local choices = {}
					table.insert(choices, "1")
					if not player:isNude() then
						table.insert(choices, "2")
					end
					local choice = room:askForChoice(lbs, self:objectName(), table.concat(choices, "+"))
					if choice == "1" then
						room:broadcastSkillInvoke("sjshixian_joy", math.random(7, 10))
						if player:getEquips():length() > 0 then
							local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
							for _, e in sgs.qlist(player:getEquips()) do
								dummy:addSubcard(e:getEffectiveId())
							end
							room:throwCard(dummy, player, lbs)
							dummy:deleteLater()
						end
						local jjj_cards = {}
						local jjj_oc = 0
						for _, id in sgs.qlist(room:getDrawPile()) do
							if sgs.Sanguosha:getCard(id):isKindOf("Analeptic") and not table.contains(jjj_cards, id) and jjj_oc < 1 then
								jjj_oc = jjj_oc + 1
								table.insert(jjj_cards, id)
							end
						end
						local dummi = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
						for _, i in ipairs(jjj_cards) do
							dummi:addSubcard(i)
						end
						room:obtainCard(player, dummi)
						dummi:deleteLater()
					elseif choice == "2" then
						room:broadcastSkillInvoke("sjshixian_joy", math.random(7, 10))
						local jjj_getana = {}
						if not player:isKongcheng() then
							for _, c in sgs.qlist(player:getHandcards()) do
								if c:isKindOf("Analeptic") then
									table.insert(jjj_getana, c)
								end
							end
						end
						if #jjj_getana > 0 then
							local dumme = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
							for _, id in ipairs(jjj_getana) do
								dumme:addSubcard(id)
							end
							room:obtainCard(lbs, dumme)
							dumme:deleteLater()
						else
							local jjj_getcard = room:askForCardChosen(lbs, player, "he", self:objectName())
							room:obtainCard(lbs, jjj_getcard, false)
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("sjshixian_jjj") then skills:append(sjshixian_jjj) end
--《侠客行》
local function isCardOne(card, name)
	local c_name = sgs.Sanguosha:translate(card:objectName())
	if string.find(c_name, name) then return true end
	return false
end
sjshixian_xks = sgs.CreateTriggerSkill {
	name = "sjshixian_xks&",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.CardUsed, sgs.Damage },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card and use.card:isKindOf("Weapon") and isCardOne(use.card, "剑") then
				local wj = sgs.Sanguosha:cloneCard("archery_attack", sgs.Card_NoSuit, 0)
				wj:setSkillName(self:objectName())
				if wj:isAvailable(player) then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke("sjshixian_joy", math.random(11, 12))
					room:useCard(sgs.CardUseStruct(wj, player, nil))
				else
					wj:deleteLater()
				end
			end
		elseif event == sgs.Damage then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash") and player:getWeapon() ~= nil
				and not player:isKongcheng() and damage.to:isAlive() and not damage.to:isKongcheng() then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:broadcastSkillInvoke("sjshixian_joy", math.random(11, 12))
					local success = player:pindian(damage.to, self:objectName(), nil)
					if success then
						room:loseMaxHp(damage.to, 1)
					else
						local weapon = player:getWeapon()
						room:throwCard(weapon, player, player)
					end
				end
			end
		end
	end,
}
if not sgs.Sanguosha:getSkill("sjshixian_xks") then skills:append(sjshixian_xks) end

sgs.Sanguosha:addSkills(skills)
sgs.LoadTranslationTable {
	["XiYouWorld"] = "西游·世界",
	["XiYouWorldCards"] = "[西游·世界]扩展包专属卡牌",

	--地主专属武将·专属技能--
	--地主之魂
	["xydizhusoul"] = "地主之魂",
	[":xydizhusoul"] = "即将分发起始手牌时，你可以选择发动此技能，则你执行以下效果：\
	1.若你不为“地主”，你可以投掷一枚骰子，若点数为6，你可以加1点体力上限并加1点体力，获得地主专属技能“飞扬”、“跋扈”；否则（或点数为其他结果）你本局游戏起始手牌+2。\
	2.若你为“地主”，你本局游戏起始手牌+2。",
	["$xydizhusoul_dz"] = "【<font color='yellow'><b>地主之魂</b></font>】%from 身份为“<font color='yellow'><b>地主</b></font>”，本局游戏起始手牌+2",
	["$xydizhusoul_tz"] = "%from 发动“<font color='yellow'><b>地主之魂</b></font>”投掷一颗骰子，点数为<b>[<font color='yellow'>%arg2</font>]</b>",
	["$xydizhusoul_ndz"] = "%from 的“<font color='yellow'><b>地主之魂</b></font>”生效，本局游戏起始手牌+2",
	["@xydizhusoul_imdz"] = "[地主]？爷就是地主",
	["$xydizhusoul"] = "（恭喜你！骰子点数为6，你获得了“成为”【地主】的机会！）",
	------

	--孙悟空
	["xy_sunwukong"] = "孙悟空",
	["#xy_sunwukong"] = "斗战胜佛",
	["designer:xy_sunwukong"] = "官方(十周年)",
	["cv:xy_sunwukong"] = "官方",
	["illustrator:xy_sunwukong"] = "匠人绘",
	--金睛
	["xyjinjing"] = "金睛",
	["xyjinjingTrigger"] = "金睛",
	[":xyjinjing"] = "锁定技，其他角色的手牌<font color='yellow'><b>/</b></font><font color='red'><b>始终</b></font><font color='yellow'><b>/</b></font>对你可见。\
	--------\
	<font color='blue'><b>◆伪实现(如果你不能鼠标右键查看已知牌)：\
	1.出牌阶段可以随时<font color='green'><b>点击此按钮</b></font>选择其他角色查看其手牌；\
	2.<font color='orange'><b>游戏开始时</b></font>以及<font color='green'><b>每个角色的回合开始时</b></font>，" ..
		"你可以选择任意名其他角色，查看这些角色的手牌<font color='pink'>(留意文字信息播报界面)</font>；\
	3.当你成为其他角色使用牌的目标时，你可以看见其所有手牌。</b></font>\
	--------\
	<font color='red'><b>◆真实现(如果你可以鼠标右键查看已知牌)：\
	-->鼠标右键，点击“查看已知牌”，选择你要查看手牌的目标角色。</b></font>",
	["@xyjinjing-toseeGMS"] = "【<font color='yellow'><b>游戏开始</b></font>】你可以选择任意名其他角色，查看他们的手牌",
	["@xyjinjing-tosee"] = "你可以选择任意名其他角色，查看他们的手牌",
	["$xyjinjing1"] = "嗯？有妖气！",
	["$xyjinjing2"] = "溶石为甲，披焰成袍；火眼金睛，踏碎凌霄！",
	--慈悲
	["xycibei"] = "慈悲",
	[":xycibei"] = "<font color='green'><b>每个回合每名角色限一次，</b></font>当你对其他角色造成伤害时，你可以防止此伤害，摸五张牌。",
	["$xycibei1"] = "生亦何欢，死亦何苦。",
	["$xycibei2"] = "我欲成佛，天下无魔；我欲成魔，佛奈我何？",
	--如意
	["xyruyi"] = "如意",
	["xyruyiJGB"] = "如意",
	[":xyruyi"] = "锁定技，你<font color='yellow'><b>/</b></font><font color='red'><b>始终</b></font><font color='yellow'><b>/</b></font>" ..
		"装备【如意金箍棒】<font color='red'><b>(初始攻击范围为3)</b></font>；你手牌中的武器牌均视为【杀】。\
	<font color='blue'><b>◆伪实现：当【如意金箍棒】不因[销毁]或[“调整”攻击范围]离开你的装备区时，你立即将其置回。(除非此时你没有武器栏或没有该技能了)</b></font>\
	<font color='red'><b>！注意：不支持同将模式，或当场上超过两名角色有该技能时。</b></font>",
	["xyruyiBK"] = "如意宝库", --其实就是存放四种类型的金箍棒的
	["$xyruyi1"] = "俺老孙来也！",
	["$xyruyi2"] = "吃俺老孙一棒！",
	--阵亡
	["~xy_sunwukong"] = "曾经，有一整片蟠桃园在我面前，失去后才追悔莫及......",
	--==专属装备==--
	--<如意金箍棒>--
	["XyRuyijingubang"] = "如意金箍棒",
	["XyRuyijingubangs"] = "金箍棒",
	["xyruyijingubangs"] = "金箍棒",
	--攻击范围1：AK
	["_xy_ruyijingubang_one"] = "如意金箍棒[1]",
	["XyRuyijingubangOne"] = "如意金箍棒[1]",
	["xyruyiOne"] = "如意金箍棒[1]",
	[":_xy_ruyijingubang_one"] = "装备牌·武器<br /><b>攻击范围</b>：１\
	<b>武器技能</b>：出牌阶段限一次，你可以(点击武将头像左上方的“金箍棒”按钮)“调整”此武器牌的攻击范围（1~4）。若此牌的攻击范围为：\
	<font color='red'><b>1 你使用【杀】无次数限制；</b></font>\
	2 你使用【杀】造成的伤害+1；\
	3 你使用【杀】不能被响应；\
	4 你使用【杀】可以额外选择一个目标。",
	--攻击范围2：加伤
	["_xy_ruyijingubang_two"] = "如意金箍棒[2]",
	["XyRuyijingubangTwo"] = "如意金箍棒[2]",
	["xyruyiTwo"] = "如意金箍棒[2]",
	[":_xy_ruyijingubang_two"] = "装备牌·武器<br /><b>攻击范围</b>：２\
	<b>武器技能</b>：出牌阶段限一次，你可以(点击武将头像左上方的“金箍棒”按钮)“调整”此武器牌的攻击范围（1~4）。若此牌的攻击范围为：\
	1 你使用【杀】无次数限制；\
	<font color='red'><b>2 你使用【杀】造成的伤害+1；</b></font>\
	3 你使用【杀】不能被响应；\
	4 你使用【杀】可以额外选择一个目标。",
	--攻击范围3：强命
	["_xy_ruyijingubang_three"] = "如意金箍棒[3]", --初始
	["XyRuyijingubangThree"] = "如意金箍棒[3]",
	["xyruyiThree"] = "如意金箍棒[3]",
	[":_xy_ruyijingubang_three"] = "装备牌·武器<br /><b>攻击范围</b>：３\
	<b>武器技能</b>：出牌阶段限一次，你可以(点击武将头像左上方的“金箍棒”按钮)“调整”此武器牌的攻击范围（1~4）。若此牌的攻击范围为：\
	1 你使用【杀】无次数限制；\
	2 你使用【杀】造成的伤害+1；\
	<font color='red'><b>3 你使用【杀】不能被响应；</b></font>\
	4 你使用【杀】可以额外选择一个目标。",
	--攻击范围4：尿分叉
	["_xy_ruyijingubang_four"] = "如意金箍棒[4]",
	["XyRuyijingubangFour"] = "如意金箍棒[4]",
	["xyruyiFour"] = "如意金箍棒[4]",
	[":_xy_ruyijingubang_four"] = "装备牌·武器<br /><b>攻击范围</b>：４\
	<b>武器技能</b>：出牌阶段限一次，你可以(点击武将头像左上方的“金箍棒”按钮)“调整”此武器牌的攻击范围（1~4）。若此牌的攻击范围为：\
	1 你使用【杀】无次数限制；\
	2 你使用【杀】造成的伤害+1；\
	3 你使用【杀】不能被响应；\
	<font color='red'><b>4 你使用【杀】可以额外选择一个目标。</b></font>",
	--------
	["#DestroyEqiup"] = "%card 被销毁",

	--东海龙王
	["xy_donghailongwang"] = "东海龙王",
	--["&xy_donghailongwang"] = "敖广",
	["#xy_donghailongwang"] = "群龙之首",
	["designer:xy_donghailongwang"] = "官方(十周年)",
	["cv:xy_donghailongwang"] = "官方",
	["illustrator:xy_donghailongwang"] = "匠人绘",
	--龙宫
	["xylonggong"] = "龙宫",
	[":xylonggong"] = "每个回合限一次，当你受到伤害时，你可以防止此伤害，令伤害来源随机获得牌堆中一张装备牌。",
	["xylonggongUsed"] = "发过兵器了",
	["$xylonggong1"] = "停手，大哥！给东西能换条命不？",
	["$xylonggong2"] = "冤家宜解，不宜结，莫要伤了和气。",
	--司天
	["xysitian"] = "司天",
	["xysitianDaWu"] = "司天",
	[":xysitian"] = "出牌阶段，你可以弃置两张不同颜色的手牌，然后随机观看两种“天气”并选择一项：\
	<font color='orange'><b>烈日，</b></font>对所有其他角色各造成1点火焰伤害；\
	<font color='yellow'><b>雷电，</b></font>令所有其他角色各进行一次【闪电】判定；\
	<font color=\"#01A5AF\"><b>大浪，</b></font>弃置所有其他角色装备区里的所有牌（没有则改为失去1点体力）；\
	<font color='blue'><b>暴雨，</b></font>弃置一名角色的所有手牌（没有则改为失去1点体力）；\
	<font color='grey'><b>大雾，</b></font>所有其他角色使用下一张基本牌时，此牌无效。",
	["xysitianTQYB"] = "司天广播电视台——《天气预报》",
	["xysitianTQYB:1"] = "烈日(对所有其他角色各造成1点火焰伤害)",
	["xysitianTQYB:2"] = "雷电(令所有其他角色各进行一次【闪电】判定)",
	["xysitianTQYB:3"] = "大浪(弃置所有其他角色装备区里的所有牌,没有则改为失去1点体力)",
	["xysitianTQYB:4"] = "暴雨(弃置一名角色的所有手牌,没有则改为失去1点体力)",
	["xysitianTQYB:5"] = "大雾(所有其他角色使用下一张基本牌时，此牌无效)",
	["xysitianDW"] = "大雾天气", --与神诸葛的大雾标记区分开
	["$xysitian1"] = "观众朋友大家好，欢迎收看天气预报！", --有一开始的标准包武将台词内味了哈哈!O(∩_∩)O!
	["$xysitian2"] = "这一喷嚏，不知要掀起多少狂风暴雨。",
	--
	["xysitianAudio"] = "司天-天气",
	[":xysitianAudio"] = "[配音技]，此技能为“司天”的“天气”配音。",
	["$xysitianAudio1"] = "（烈日当空！）", --天气：烈日
	["$xysitianAudio2"] = "（电闪雷鸣！）", --天气：雷电
	["$xysitianAudio3"] = "（大浪滔天！）", --天气：大浪
	["$xysitianAudio4"] = "（暴雨倾盆！）", --天气：暴雨
	["$xysitianAudio5"] = "（大雾弥漫~.......）", --天气：大雾
	--阵亡
	["~xy_donghailongwang"] = "三年之期已到，哥们要回家啦√",

	--涛神
	["xy_taoshen"] = "涛神",
	["#xy_taoshen"] = "呼风唤雨",
	["designer:xy_taoshen"] = "官方(十周年[长赢演武])",
	["cv:xy_taoshen"] = "神刘备",
	["illustrator:xy_taoshen"] = "青学",
	--怒涛
	["xynutao"] = "怒涛",
	["xynutaoo"] = "怒涛",
	[":xynutao"] = "锁定技，当你使用锦囊牌指定目标时，你随机对一名其他目标角色造成1点雷电伤害；当你造成雷电伤害后，若此时为你的出牌阶段，你此阶段使用【杀】的次数上限+1。",
	["$xynutao1"] = "波澜逆转，攻守皆可！", --造成伤害
	["$xynutao2"] = "无虚怒涛，奔流不灭！", --造成伤害
	["$xynutao3"] = "波涛怒天，神力无边！", --加杀次数
	["$xynutao4"] = "志勇深沉，一世之雄！", --加杀次数
	--阵亡
	["~xy_taoshen"] = "马革裹尸，身沉江心......",

	--李白
	["sj_libai"] = "李白",
	["#sj_libai"] = "青莲居士",
	["designer:sj_libai"] = "官方(十周年)",
	["cv:sj_libai"] = "官方",
	["illustrator:sj_libai"] = "佚名",
	--酒仙
	["sjjiuxian"] = "酒仙",
	["sjjiuxianMAX"] = "酒仙",
	[":sjjiuxian"] = "你使用【酒】无次数限制；你可以将一张多目标锦囊牌当【酒】使用。",
	["$sjjiuxian1"] = "地若不爱酒，地应无酒泉。",
	["$sjjiuxian2"] = "天若不爱酒，酒心不在天。",
	--诗仙
	["sjshixian"] = "诗仙",
	[":sjshixian"] = "你使用牌时，若此牌与你使用的上一张<font color='red'><b>(在【押韵表】范围内的)</b></font>牌<font color=\"#01A5AF\"><b>//押韵//</b></font>（具体详见【押韵表】），你可以摸一张牌并令此牌额外结算一次。\
	<font color='blue'><b>◆操作提示：使用牌时，<font color='red'>(若此牌在【押韵表】范围内)</font>会给出此牌对应韵母的文字标记；游戏过程中，可以随时将鼠标悬停在武将头像左上角的“押韵表”技能按钮上，查看【押韵表】。</b></font>",
	["$sjshixian1"] = "武侯立岷蜀，壮志吞咸京。",
	["$sjshixian2"] = "鱼水三顾合，风云四海生。",
	--【押韵表】
	["lb_yayunbiao"] = "押韵表",
	["lb_yayunbiaos"] = "押韵表",
	[":lb_yayunbiao"] = "\
	  /a/:【杀(包括属性杀)】【万箭齐发】【藤甲】\
	  /ai/：【黑光铠】\
	  /an/：【闪】【兵粮寸断】【铁索连环】【闪电】【雌雄双股剑】【青釭剑】【寒冰剑】【朱雀羽扇】【爪黄飞电】【大宛】【逐近弃远】【随机应变】【乌铁锁链】【五行鹤翎扇】\
	  /ang/：【顺手牵羊】\
	  /ao/：【桃】【过河拆桥】【青龙偃月刀】【丈八蛇矛】【古锭刀】\
	  /en/：【借刀杀人】【八卦阵】\
	  /eng/：【五谷丰登】\
	  /i/：【桃园结义】【无懈可击】【方天画戟】【白银狮子】【洞烛先机】【出其不意】\
	  /in/：【南蛮入侵】\
	  /ing/：【绝影】【紫骍】【护心镜】\
	  /iu+ou/：【酒】【骅骝】；【决斗】【无中生有】\
	  /ong/：【火攻】【麒麟弓】\
	  /u/：【乐不思蜀】【诸葛连弩】【贯石斧】【的卢】【赤兔】【天机图】【太公阴符】\
	  /ue/：【铜雀】\
	  /un/：【仁王盾】【水淹七军】",
	["yyb_a"] = "押韵/a/",
	["yyb_ai"] = "押韵/ai/",
	["yyb_an"] = "押韵/an/",
	["yyb_ang"] = "押韵/ang/",
	["yyb_ao"] = "押韵/ao/",
	["yyb_en"] = "押韵/en/",
	["yyb_eng"] = "押韵/eng/",
	["yyb_i"] = "押韵/i/",
	["yyb_in"] = "押韵/in/",
	["yyb_ing"] = "押韵/ing/",
	["yyb_iuou"] = "押韵/iu+ou/",
	["yyb_ong"] = "押韵/ong/",
	["yyb_u"] = "押韵/u/",
	["yyb_ue"] = "押韵/ue/",
	["yyb_un"] = "押韵/un/",
	--阵亡
	["~sj_libai"] = "谁识卧龙客，长吟愁鬓斑......", --再来一杯吧......

	--李白(欢乐杀)
	["sj_libai_joy"] = "李白[欢乐杀]",
	["&sj_libai_joy"] = "欢乐李白",
	["#sj_libai_joy"] = "谪仙人",
	["designer:sj_libai_joy"] = "官方(欢乐杀)",
	["cv:sj_libai_joy"] = "时光流逝FC",
	["illustrator:sj_libai_joy"] = "欢乐杀",
	--诗仙
	["sjshixian_joy"] = "诗仙",
	[":sjshixian_joy"] = "锁定技，回合开始时，你清除已有的<font color=\"#01A5AF\"><b>诗篇</b></font>并展示牌堆顶的四张牌，" ..
		"根据其中出现的花色创作对应的<font color=\"#01A5AF\"><b>诗篇</b></font>。根据你创作的<font color=\"#01A5AF\"><b>诗篇</b></font>，你获得对应技能：\
	红桃，《静夜思》：出牌阶段结束时，你可以观看牌堆顶的一张牌并选择是否使用之；弃牌阶段结束时，你从牌堆底获得一张牌。\
	方块，《行路难》：若你于回合外成为其他角色使用【杀】的目标，则此【杀】结算结束后，其他角色计算与你的距离+1直到你的回合开始。\
	梅花，《将进酒》：其他角色的回合开始时，你可以弃置一张手牌并选择一项：1.弃置其装备区内的所有牌，然后令其从牌堆中获得一张【酒】；" ..
		"2.获得其手牌中的所有【酒】，若其手牌中没有【酒】则改为获得其一张牌。\
	黑桃，《侠客行》：当你使用牌名中含“剑”的武器牌后，你视为使用一张【万箭齐发】；当你的【杀】对一名角色造成伤害后，若你的装备区内有武器牌，你可以与其拼点：" ..
		"若你赢，其减1点体力上限；若你没赢，弃置你装备区内的武器牌。\
	然后你可以获得其中重复花色的牌。",
	["@sjshixian_joy_getCards"] = "[诗仙]获得重复花色的牌",
	--诗篇--
	--《静夜思》
	["sjshixian_jys"] = "静夜思",
	[":sjshixian_jys"] = "出牌阶段结束时，你可以观看牌堆顶的一张牌并选择是否使用之；弃牌阶段结束时，你从牌堆底获得一张牌。",
	["@sjshixian_jys-usecard"] = "你是否使用这张【<font color='yellow'><b>%src</b></font>】？",
	["$sjshixian_joy1"] = "床前明月光，疑是地上霜。",
	["$sjshixian_joy2"] = "举头望明月，低头思故乡。",
	--《行路难》
	["sjshixian_xln"] = "行路难",
	["sjshixian_xlnan"] = "行路难",
	[":sjshixian_xln"] = "若你于回合外成为其他角色使用【杀】的目标，则此【杀】结算结束后，其他角色计算与你的距离+1直到你的回合开始。",
	["$sjshixian_joy3"] = "停杯投箸不能食，拔剑四顾心茫然。",
	["$sjshixian_joy4"] = "欲渡黄河冰塞川，将登太行雪满山。",
	["$sjshixian_joy5"] = "闲来垂钓碧溪上，忽复乘舟梦日边。",
	["$sjshixian_joy6"] = "长风破浪会有时，直挂云帆济沧海。",
	--《将进酒》
	["sjshixian_jjj"] = "将进酒",
	[":sjshixian_jjj"] = "其他角色的回合开始时，你可以弃置一张手牌并选择一项：1.弃置其装备区内的所有牌，然后令其从牌堆中获得一张【酒】；" ..
		"2.获得其手牌中的所有【酒】，若其手牌中没有【酒】则改为获得其一张牌。",
	["@sjshixian_jjj-distoivk"] = "你可以弃置一张手牌，对当前回合角色发动“将进酒”",
	["sjshixian_jjj:1"] = "弃置其装备区内的所有牌，令其从牌堆中获得一张【酒】",
	["sjshixian_jjj:2"] = "获得其手牌中的所有【酒】(若其手牌中没有【酒】则改为获得其一张牌)",
	["$sjshixian_joy7"] = "君不见，黄河之水天上来，奔流到海不复回。",
	["$sjshixian_joy8"] = "君不见，高堂明镜悲白发，朝如青丝暮成雪。",
	["$sjshixian_joy9"] = "人生得意须尽欢，莫使金樽空对月。",
	["$sjshixian_joy10"] = "天生我材必有用，千金散尽还复来。",
	--《侠客行》
	["sjshixian_xks"] = "侠客行", --["sjshixian_xkx"] = "侠客行",
	[":sjshixian_xks"] = "当你使用牌名中含“剑”的武器牌后，你视为使用一张【万箭齐发】；当你的【杀】对一名角色造成伤害后，若你的装备区内有武器牌，你可以与其拼点：" ..
		"若你赢，其减1点体力上限；若你没赢，弃置你装备区内的武器牌。",
	["$sjshixian_joy11"] = "十步杀一人，千里不留行。",
	["$sjshixian_joy12"] = "事了拂衣去，深藏身与名。",
	----
	--阵亡
	["~sj_libai_joy"] = "我寄愁心与明月，随风直到夜郎西......",
}
return { extension, extension_x }
