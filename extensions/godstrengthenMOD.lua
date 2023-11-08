extension = sgs.Package("godstrengthenMOD", sgs.Package_GeneralPack)
extension_on = sgs.Package("godstrengthenMODs", sgs.Package_CardPack)
--[[《目录》
1、小型场景：诸神黄昏（新增三位此模式专属武将：神关羽-无武魂版、神-基尔什塔利亚·沃戴姆、神-戴比特·泽姆·沃伊德）
2、特殊场景：天使的遗物（新增一位此模式专属武将(BOSS)：魔-戴比特·泽姆·沃伊德；赠送一位双头武将：戴比特&基尔什塔利亚）
  2.5、特殊场景：天使的遗物（里主线）
3、<环境改造>包（目前更新至第一季）
4、特殊场景：海洋双雄（新增两位此模式专属武将(BOSS)：神-巨齿耳齿鲨、神-利维坦·梅尔维尔(梅鲸)）
5、游戏关卡：新·虎牢关模式（新增一位此模式专属武将(BOSS)：新虎牢关吕布[十周年]）
6、思考中......
]]






--

--（借鉴(chao'xi)了一下学佬的极乐包“缤纷模式”代码）
--[[godstrengthenMODon = sgs.CreateTriggerSkill{
	name = "godstrengthenMODon",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data, room)
		room:setTag("godstrengthenMOD", ToData(true))
	end,
	can_trigger = function(self, target)
		if table.contains(sgs.Sanguosha:getBanPackages(), "godstrengthenMOD")
		or target:getRoom():getTag("godstrengthenMOD"):toBool()
		or target:getState() == "robot"
		then return end
		return target:isAlive()
	end,
}]]
local skills = sgs.SkillList()
--if not sgs.Sanguosha:getSkill("godstrengthenMODon") then skills:append(godstrengthenMODon) end

--1.小型场景：诸神黄昏--
godRule = sgs.General(extension, "godRule", "god", 5, true, true)

GODSstart = sgs.CreateTriggerSkill{
    name = "GODSstart",
	priority = -1,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		for _, p in sgs.qlist(room:getAllPlayers()) do --粗略检测当前游戏房间是否为“诸神黄昏”
			if p:getKingdom() ~= "god" then
				room:addPlayerMark(player, "itsnotRagnarokr")
				break
			end
		end
		if player:getMark("itsnotRagnarokr") > 0 then return false end
		room:addPlayerMark(player, "&godRule") --表明身份为“神之审判”
		room:setPlayerFlag(player, "GODevent_judge_delay") --此标志是为了事件神之审判
		for _, p in sgs.qlist(room:getAllPlayers()) do
			room:addPlayerMark(p, "GODlessMaxCards") --此标记是为了实现手牌上限-2
		end
		if player:getState() == "online" then
			room:doLightbox("$eventOne_GODevent_change") --事件1：神之幻化
			local log = sgs.LogMessage()
			log.type = "$GODSstart_change"
			log.from = player
			room:sendLog(log)
			room:setPlayerFlag(player, "banWodimeSkills") --此标志是为了防止队长因回血而触发技能
			room:changeHero(player, "godWodime", false, true, false, true)
			room:removePlayerMark(player, "&kwxingkong", 3)
			room:changeHero(player, "godDaybit", false, true, true, true)
		end
	end,
}
GODRULEskip = sgs.CreateTriggerSkill{
    name = "GODRULEskip",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.GameStart then
			player:throwAllHandCardsAndEquips()
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			--[[if not player:isSkipped(change.to) and change.to == sgs.Player_RoundStart then
				player:skip(change.to)
			end]]
			if not player:isSkipped(change.to) and change.to == sgs.Player_Start then
				player:skip(change.to)
			end
			if not player:isSkipped(change.to) and change.to == sgs.Player_Judge then
				player:skip(change.to)
			end
			if not player:isSkipped(change.to) and change.to == sgs.Player_Draw then
				player:skip(change.to)
			end
			if not player:isSkipped(change.to) and change.to == sgs.Player_Play then
				player:skip(change.to)
			end
			if not player:isSkipped(change.to) and change.to == sgs.Player_Discard then
				player:skip(change.to)
			end
			if not player:isSkipped(change.to) and change.to == sgs.Player_Finish then
				player:skip(change.to)
			end
			--[[if not player:isSkipped(change.to) and change.to == sgs.Player_NotActive then
				player:skip(change.to)
			end]]
		end
	end,
	can_trigger = function(self, player)
	    return player:getMark("&godRule") > 0 and player:getState() == "robot"
	end,
}
local function isSpecialOne(player, name)
	local g_name = sgs.Sanguosha:translate(player:getGeneralName())
	if string.find(g_name, name) then return true end
	if player:getGeneral2() then
		g_name = sgs.Sanguosha:translate(player:getGeneral2Name())
		if string.find(g_name, name) then return true end
	end
	return false
end
GODReviseHp = sgs.CreateTriggerSkill{ --将体力上限和体力值重置为二者之和
    name = "GODReviseHp",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		for _, g in sgs.qlist(room:getAllPlayers()) do
			if isSpecialOne(g, "神之审判") and isSpecialOne(g, "士兵") then
				room:setPlayerProperty(g, "maxhp", sgs.QVariant(11)) --主公体力上限+1
				room:setPlayerProperty(g, "hp", sgs.QVariant(11))
				--[[local r = g:getHp()
				local recover = sgs.RecoverStruct()
				recover.who = g
				recover.recover = 11 - r
				room:recover(g, recover)]]
			end
			if isSpecialOne(g, "基尔什塔利亚") and isSpecialOne(g, "戴比特") then
				room:setPlayerProperty(g, "maxhp", sgs.QVariant(11)) --主公体力上限+1
				room:setPlayerProperty(g, "hp", sgs.QVariant(11))
				--[[local r = g:getHp()
				local recover = sgs.RecoverStruct()
				recover.who = g
				recover.recover = 11 - r
				room:recover(g, recover)
				room:setPlayerFlag(g, "-banWodimeSkills")]]
			end
			if isSpecialOne(g, "神关羽") and isSpecialOne(g, "神吕蒙") then
				room:setPlayerProperty(g, "maxhp", sgs.QVariant(8))
				room:setPlayerProperty(g, "hp", sgs.QVariant(8))
				--[[local r = g:getHp()
				local recover = sgs.RecoverStruct()
				recover.who = g
				recover.recover = 8 - r
				room:recover(g, recover)]]
			end
			if isSpecialOne(g, "神周瑜") and isSpecialOne(g, "神诸葛亮") then
				room:setPlayerProperty(g, "maxhp", sgs.QVariant(7))
				room:setPlayerProperty(g, "hp", sgs.QVariant(7))
				--[[local r = g:getHp()
				local recover = sgs.RecoverStruct()
				recover.who = g
				recover.recover = 7 - r
				room:recover(g, recover)]]
			end
			if isSpecialOne(g, "神曹操") and isSpecialOne(g, "神吕布") then
				room:setPlayerProperty(g, "maxhp", sgs.QVariant(8))
				room:setPlayerProperty(g, "hp", sgs.QVariant(8))
				--[[local r = g:getHp()
				local recover = sgs.RecoverStruct()
				recover.who = g
				recover.recover = 8 - r
				room:recover(g, recover)]]
			end
			if isSpecialOne(g, "神赵云") and isSpecialOne(g, "神司马懿") then
				room:setPlayerProperty(g, "maxhp", sgs.QVariant(6))
				room:setPlayerProperty(g, "hp", sgs.QVariant(6))
				--[[local r = g:getHp()
				local recover = sgs.RecoverStruct()
				recover.who = g
				recover.recover = 6 - r
				room:recover(g, recover)]]
			end
			if isSpecialOne(g, "神刘备") and isSpecialOne(g, "神陆逊") then
				room:setPlayerProperty(g, "maxhp", sgs.QVariant(10))
				room:setPlayerProperty(g, "hp", sgs.QVariant(10))
				--[[local r = g:getHp()
				local recover = sgs.RecoverStruct()
				recover.who = g
				recover.recover = 10 - r
				room:recover(g, recover)]]
			end
			if isSpecialOne(g, "神张辽") and isSpecialOne(g, "神甘宁") then
				room:setPlayerProperty(g, "maxhp", sgs.QVariant(10))
				room:setPlayerProperty(g, "hp", sgs.QVariant(7))
				--[[local r = g:getHp()
				local recover = sgs.RecoverStruct()
				recover.who = g
				recover.recover = 7 - r
				room:recover(g, recover)]]
			end
			if isSpecialOne(g, "魏武帝") and isSpecialOne(g, "晋宣帝") then
				room:setPlayerProperty(g, "maxhp", sgs.QVariant(7))
				room:setPlayerProperty(g, "hp", sgs.QVariant(7))
				--[[local r = g:getHp()
				local recover = sgs.RecoverStruct()
				recover.who = g
				recover.recover = 7 - r
				room:recover(g, recover)]]
			end
		end
		room:addPlayerMark(player, "GODReviseHp_Invoked")
	end,
	can_trigger = function(self, player)
	    return player:getMark("&godRule") > 0 and player:getMark("GODReviseHp_Invoked") == 0 and player:getPhase() == sgs.Player_RoundStart
	end,
}
GODevent_down = sgs.CreateTriggerSkill{ --事件2：神之覆灭
    name = "GODevent_down",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then
			return false
		end
		room:doLightbox("$eventTwo_GODevent_down")
		for _, othergod in sgs.qlist(room:getOtherPlayers(player)) do
            if math.random() > 0.5 then
		        room:setPlayerProperty(othergod, "role", sgs.QVariant("rebel"))
				room:drawCards(othergod, 3, "GODevent_down")
				room:setPlayerProperty(othergod, "kingdom", sgs.QVariant("devil"))
			end
		end
		local r = 0
		for _, d in sgs.qlist(room:getAllPlayers()) do
            if d:getRole() == "rebel" then
				r = r + 2
			end
		end
		room:drawCards(player, r, self:objectName())
		room:addPlayerMark(player, "GODevent_down_invoked")
	end,
	can_trigger = function(self, player)
	    return player:getState() == "online" and player:getMark("&godRule") > 0 and player:getMark("itsnotRagnarokr") == 0 and player:getMark("GODevent_down_invoked") == 0
	end,
}
GOD_Killdevil = sgs.CreateTriggerSkill{ --玩家因“神之覆灭”获得的效果
    name = "GOD_Killdevil",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() == sgs.Player_RoundStart then
			local r = 0
			for _, d in sgs.qlist(room:getAllPlayers()) do
            	if d:isAlive() and d:getRole() == "rebel" then
					r = r + 1
				end
			end
			room:drawCards(player, r, self:objectName())
		end
		room:addPlayerMark(player, "GODevent_down_invoked")
	end,
	can_trigger = function(self, player)
	    return player:getMark("GODevent_down_invoked") > 0
	end,
}
GODevent_judge = sgs.CreateTriggerSkill{ --事件3：神之审判
    name = "GODevent_judge",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TurnStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:doLightbox("$eventThree_GODevent_judge")
		local judge = sgs.JudgeStruct()
		judge.pattern = ".|.|2~9"
		judge.good = true
		judge.play_animation = true
		judge.time_consuming = true
		judge.who = player
		judge.reason = self:objectName()
		room:judge(judge)
		if judge:isGood() then
			if judge.card:getSuit() == sgs.Card_Heart then --鸿运当头
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					local recover = sgs.RecoverStruct()
					recover.recover = math.random(0,3)
					recover.who = p
					room:recover(p, recover)
				end
			elseif judge.card:getSuit() == sgs.Card_Diamond then --神临天启
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					room:drawCards(p, math.random(0,3), self:objectName())
				end
			elseif judge.card:getSuit() == sgs.Card_Club then --阴雨连绵
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					local dsc = math.random(0,3)
					room:askForDiscard(p, self:objectName(), dsc, dsc)
				end
			elseif judge.card:getSuit() == sgs.Card_Spade then --电闪雷鸣
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					room:damage(sgs.DamageStruct(self:objectName(), nil, p, math.random(0,3), sgs.DamageStruct_Thunder))
				end
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:getState() == "robot" and player:getMark("&godRule") > 0 and player:getMark("itsnotRagnarokr") == 0 and not player:hasFlag("GODevent_judge_delay")
	end,
}
KillGOD = sgs.CreateTriggerSkill{
	name = "KillGOD",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local lord = room:getLord()
		if lord:getMark("&godRule") == 0 then return false end
		local damage = data:toDamage()
		if lord:objectName() == player:objectName() and player:getState() == "robot" then
			return true
		else
			if not player:hasSkill("guixin") then
				damage.damage = damage.damage + 1
				data:setValue(damage)
			else
				room:loseHp(player, 1)
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getKingdom() == "god"
	end,
}
GODsurroundingDraw = sgs.CreateTriggerSkill{ --摸牌阶段摸牌数+2
	name = "GODsurroundingDraw",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local lord = room:getLord()
		if lord:getMark("&godRule") == 0 then return false end
		local count = data:toInt() + 2
		data:setValue(count)
	end,
	can_trigger = function(self, player)
	    return true
	end,
}
GODsurroundingMaxCards = sgs.CreateMaxCardsSkill{ --手牌上限-2
    name = "GODsurroundingMaxCards",
	extra_func = function(self, target)
	    --[[if target:getMark("&godRule") > 0 and target:getState() == "robot" then
		    return -1000
		else]]if target:getMark("GODlessMaxCards") > 0 then
		    return -2
		else
		    return 0
		end
	end,
}
GODend = sgs.CreateTriggerSkill{
    name = "GODend",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local death = data:toDeath()
		local gr = room:findPlayerBySkillName(self:objectName())
		if not gr or gr:getState() == "online" then return false end
		local count = room:alivePlayerCount()
		if count < 3 then
			room:loseMaxHp(gr, 100) --以最简单粗暴的方式强制结束游戏
		end
		--[[local count = room:alivePlayerCount()
		if count < 3 then
			for _, p in sgs.qlist(room:getOtherPlayers(gr)) do
				room:gameOver(p)
			end
		end]]
	end,
	can_trigger = function(self, player)
		return true
	end,
}
godRule:addSkill(GODSstart)
if not sgs.Sanguosha:getSkill("GODRULEskip") then skills:append(GODRULEskip) end
if not sgs.Sanguosha:getSkill("GODReviseHp") then skills:append(GODReviseHp) end
if not sgs.Sanguosha:getSkill("GODevent_down") then skills:append(GODevent_down) end
if not sgs.Sanguosha:getSkill("GOD_Killdevil") then skills:append(GOD_Killdevil) end
if not sgs.Sanguosha:getSkill("GODevent_judge") then skills:append(GODevent_judge) end
if not sgs.Sanguosha:getSkill("KillGOD") then skills:append(KillGOD) end
if not sgs.Sanguosha:getSkill("GODsurroundingDraw") then skills:append(GODsurroundingDraw) end
if not sgs.Sanguosha:getSkill("GODsurroundingMaxCards") then skills:append(GODsurroundingMaxCards) end
godRule:addSkill(GODend)
--处理神诸葛亮在小型场景开场没有“星”的BUG
qixingSupplement = sgs.CreateTriggerSkill{
	name = "qixingSupplement",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:sendCompulsoryTriggerLog(player, "qixing")
		room:broadcastSkillInvoke("qixing")
		room:drawCards(player, 7, self:objectName())
		local exc_card = room:askForExchange(player, "qixing", 7, 7)
		player:addToPile("stars", exc_card:getSubcards(), false)
		exc_card:deleteLater()
	end,
	can_trigger = function(self, player)
		return player:hasSkill("qixing") and player:getPile("stars"):length() == 0
	end,
}
if not sgs.Sanguosha:getSkill("qixingSupplement") then skills:append(qixingSupplement) end
--

--“诸神黄昏”模式专用神关羽：神关羽-无武魂版
shenguanyu_nowuhun = sgs.General(extension, "shenguanyu_nowuhun", "god", 5, true)

Nwushen = sgs.CreateFilterSkill{
	name = "Nwushen",
	view_filter = function(self, to_select)
		local room = sgs.Sanguosha:currentRoom()
		local place = room:getCardPlace(to_select:getEffectiveId())
		return to_select:getSuit() == sgs.Card_Heart and place == sgs.Player_PlaceHand
	end,
	view_as = function(self, originalCard)
		local slash = sgs.Sanguosha:cloneCard("slash", originalCard:getSuit(), originalCard:getNumber())
		slash:setSkillName(self:objectName())
		local card = sgs.Sanguosha:getWrappedCard(originalCard:getId())
		card:takeOver(slash)
		return card
	end,
}
NwushenDuel = sgs.CreateFilterSkill{
	name = "#NwushenDuel",
	view_filter = function(self, to_select)
		local room = sgs.Sanguosha:currentRoom()
		local place = room:getCardPlace(to_select:getEffectiveId())
		return to_select:getSuit() == sgs.Card_Diamond and place == sgs.Player_PlaceHand
	end,
	view_as = function(self, originalCard)
		local duel = sgs.Sanguosha:cloneCard("duel", originalCard:getSuit(), originalCard:getNumber())
		duel:setSkillName("Nwushen")
		local card = sgs.Sanguosha:getWrappedCard(originalCard:getId())
		card:takeOver(duel)
		return card
	end,
}
NwushenDR = sgs.CreateTargetModSkill{
	name = "NwushenDR",
	distance_limit_func = function(self, player, card)
		if player:hasSkill("Nwushen") and card:getSuit() == sgs.Card_Heart then
			return 1000
		else
			return 0
		end
	end,
	residue_func = function(self, player, card)
		if player:hasSkill("Nwushen") and card:getSuit() == sgs.Card_Heart then
			return 1000
		else
			return 0
		end
	end,
}
NwushenQM = sgs.CreateTriggerSkill{
    name = "NwushenQM",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecified},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:getSkillName() == "Nwushen" and player:hasSkill("Nwushen") then
			room:sendCompulsoryTriggerLog(player, "Nwushen")
			local no_respond_list = use.no_respond_list
			for _, slm in sgs.qlist(use.to) do
				table.insert(no_respond_list, slm:objectName())
			end
			use.no_respond_list = no_respond_list
			data:setValue(use)
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
shenguanyu_nowuhun:addSkill(Nwushen)
shenguanyu_nowuhun:addSkill(NwushenDuel)
if not sgs.Sanguosha:getSkill("NwushenDR") then skills:append(NwushenDR) end
if not sgs.Sanguosha:getSkill("NwushenQM") then skills:append(NwushenQM) end


--

--神-基尔什塔利亚·沃戴姆
godWodime = sgs.General(extension, "godWodime", "god", 3, true, true)

kwhuilu = sgs.CreateTriggerSkill{
	name = "kwhuilu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.Damage, sgs.Damaged, sgs.HpRecover},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			player:gainMark("&kwxingkong", 3)
		elseif event == sgs.Damage or event == sgs.Damaged then
			local damage = data:toDamage()
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			player:gainMark("&kwxingkong", damage.damage)
			room:notifySkillInvoked(player, self:objectName())
		elseif event == sgs.HpRecover and not player:hasFlag("banWodimeSkills") then
			local recover = data:toRecover()
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			player:gainMark("&kwxingkong", recover.recover)
			room:notifySkillInvoked(player, self:objectName())
		end
	end,
}
godWodime:addSkill(kwhuilu)

kwzhanxing = sgs.CreateTriggerSkill{
	name = "kwzhanxing",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Start then
			local room = player:getRoom()
			if room:askForSkillInvoke(player, self:objectName(), data) then
			    room:broadcastSkillInvoke(self:objectName())
				local n = player:getMark("&kwxingkong")
				if n > 5 then
				    n = 5
				end
				if n > 0 then
				    local cards = room:getNCards(n)
				    room:askForGuanxing(player, cards)
				end
				room:drawCards(player, 1, self:objectName())
			end
		end
	end,
}
kwzhanxing_MaxCards = sgs.CreateMaxCardsSkill{
	name = "kwzhanxing_MaxCards",
	extra_func = function(self, target)
		if target:hasSkill("kwzhanxing") then
			return 1
		else
			return 0
		end
	end,
}
godWodime:addSkill(kwzhanxing)
if not sgs.Sanguosha:getSkill("kwzhanxing_MaxCards") then skills:append(kwzhanxing_MaxCards) end

kwwanrenCard = sgs.CreateSkillCard{
    name = "kwwanrenCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		if source:getMark("kwwanren_skillget") == 0 then
			room:addPlayerMark(source, "kwwanren_skillget")
		end
		local choices = {}
		if not source:hasSkill("kwduizhang") then
			table.insert(choices, "kwduizhang")
		end
		if not source:hasSkill("kwshencai") then
			table.insert(choices, "kwshencai")
		end
		if not source:hasSkill("kwtianbuxuan") then
			table.insert(choices, "kwtianbuxuan")
		end
		if not source:hasSkill("kwyindao") then
			table.insert(choices, "kwyindao")
		end
		if not source:hasSkill("kwfengshou") then
			table.insert(choices, "kwfengshou")
		end
		if not source:hasSkill("kwzhushen") then
		    table.insert(choices, "kwzhushen")
		end
		if not source:hasSkill("kwdenghuo") then
		    table.insert(choices, "kwdenghuo")
		end
		table.insert(choices, "cancel")
		local choice = room:askForChoice(source, "kwwanren", table.concat(choices, "+"))
		if choice == "kwduizhang" then
			room:acquireSkill(source, "kwduizhang")
		elseif choice == "kwshencai" then
			room:acquireSkill(source, "kwshencai")
		elseif choice == "kwtianbuxuan" then
			room:acquireSkill(source, "kwtianbuxuan")
		elseif choice == "kwyindao" then
			room:acquireSkill(source, "kwyindao")
		elseif choice == "kwfengshou" then
			room:acquireSkill(source, "kwfengshou")
		elseif choice == "kwzhushen" then
			room:acquireSkill(source, "kwzhushen")
		elseif choice == "kwdenghuo" then
			room:acquireSkill(source, "kwdenghuo")
		elseif choice == "cancel" then
		    if source:getMark("kwwanren_skillget") > 0 then
			    room:removePlayerMark(source, "kwwanren_skillget")
			end
		end
	end,
}
kwwanren = sgs.CreateZeroCardViewAsSkill{
    name = "kwwanren",
	waked_skills = "kwduizhang, kwshencai, kwtianbuxuan, kwdibudong, kwqiangyun, kwyindao, kwfengshou, kwzhushen, kwdenghuo, kwdulv",
	view_as = function()
		return kwwanrenCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("&kwxingkong") >= 1
	end,
}
kwwanren_SkillClear = sgs.CreateTriggerSkill{
	name = "kwwanren_SkillClear",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play then
			if player:hasSkill("kwduizhang") then
		    	room:detachSkillFromPlayer(player, "kwduizhang", false, true)
			end
			if player:hasSkill("kwshencai") then
		    	room:detachSkillFromPlayer(player, "kwshencai", false, true)
			end
			if player:hasSkill("kwtianbuxuan") then
		    	room:detachSkillFromPlayer(player, "kwtianbuxuan", false, true)
			end
			if player:hasSkill("kwyindao") then
		    	room:detachSkillFromPlayer(player, "kwyindao", false, true)
			end
			if player:hasSkill("kwfengshou") then
		    	room:detachSkillFromPlayer(player, "kwfengshou", false, true)
			end
			if player:hasSkill("kwzhushen") then
		    	room:detachSkillFromPlayer(player, "kwzhushen", false, true)
			end
			if player:hasSkill("kwdenghuo") then
		    	room:detachSkillFromPlayer(player, "kwdenghuo", false, true)
			end
			room:removePlayerMark(player, "xinghan_skillget")
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("kwwanren") and player:getMark("kwwanren_skillget") >= 1
	end,
}
godWodime:addSkill(kwwanren)
godWodime:addRelateSkill("kwduizhang")
godWodime:addRelateSkill("kwshencai")
godWodime:addRelateSkill("kwtianbuxuan")
godWodime:addRelateSkill("kwdibudong")
godWodime:addRelateSkill("kwqiangyun")
godWodime:addRelateSkill("kwyindao")
godWodime:addRelateSkill("kwfengshou")
godWodime:addRelateSkill("kwzhushen")
godWodime:addRelateSkill("kwdenghuo")
godWodime:addRelateSkill("kwdulv")
if not sgs.Sanguosha:getSkill("kwwanren_SkillClear") then skills:append(kwwanren_SkillClear) end
--以下是队长“完人”提到的十个小技能--
  --“队长”
kwduizhangCard = sgs.CreateSkillCard{
    name = "kwduizhangCard",
    target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
	    return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
        local num = source:getMark("&kwxingkong")
        if num >= 1 then
	        local benefit = targets[1]
	        local rec = sgs.RecoverStruct()
		    rec.recover = 1
		    rec.who = benefit
		    room:recover(benefit, rec)
            room:drawCards(benefit, 1, "kwduizhang")
			room:broadcastSkillInvoke(self:objectName())
		    source:loseMark("&kwxingkong")
        end
    end,
}
kwduizhang = sgs.CreateViewAsSkill{
    name = "kwduizhang",
    n = 1,
	view_filter = function(self, selected, to_select)
	    return not to_select:isEquipped()
	end,
    view_as = function(self, cards)
	    if #cards == 0 then return end
		local vs_card = kwduizhangCard:clone()
		vs_card:addSubcard(cards[1])
		return vs_card
	end,
	    enabled_at_play = function(self, player)
		return player:getMark("&kwxingkong") >= 1 and not player:hasUsed("#kwduizhangCard")
	end,
}
if not sgs.Sanguosha:getSkill("kwduizhang") then skills:append(kwduizhang) end
  --“神才”
kwshencaiCard = sgs.CreateSkillCard{
    name = "kwshencaiCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
	    return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
	    local source = effect.from
        local num = source:getMark("&kwxingkong")
        if num >= 1 then
		    local benefit = effect.to
			benefit:obtainCard(self, false)
			local room = source:getRoom()
		    room:drawCards(source, 1, "kwshencai")
			room:broadcastSkillInvoke(self:objectName())
		    source:loseMark("&kwxingkong")
		end
	end,
}
kwshencai = sgs.CreateViewAsSkill{
    name = "kwshencai",
    n = 1,
	view_filter = function(self, selected, to_select)
	    return true
	end,
    view_as = function(self, cards)
	    if #cards == 0 then return end
		local vs_card = kwshencaiCard:clone()
		vs_card:addSubcard(cards[1])
		return vs_card
	end,
	    enabled_at_play = function(self, player)
	    return player:getMark("&kwxingkong") >= 1 and not player:hasUsed("#kwshencaiCard")
	end,
}
if not sgs.Sanguosha:getSkill("kwshencai") then skills:append(kwshencai) end
  --“天不旋”
kwtianbuxuanCard = sgs.CreateSkillCard{
	name = "kwtianbuxuanCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		effect.from:loseMark("&kwxingkong")
		effect.from:setFlags("kwtianbuxuanSource")
		effect.to:setFlags("kwtianbuxuanTarget")
		room:addPlayerMark(effect.to, "@skill_invalidity")
	end,
}
kwtianbuxuan = sgs.CreateZeroCardViewAsSkill{
	name = "kwtianbuxuan",
	view_as = function()
		return kwtianbuxuanCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("&kwxingkong") >= 1
	end,
}
kwtianbuxuan_Clear = sgs.CreateTriggerSkill{
	name = "kwtianbuxuan_Clear",
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
			if p:hasFlag("kwtianbuxuanTarget") then
				p:setFlags("-kwtianbuxuanTarget")
				if p:getMark("@skill_invalidity") then
				    local n = p:getMark("@skill_invalidity")
					room:removePlayerMark(p, "@skill_invalidity", n)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasFlag("kwtianbuxuanSource")
	end,
}
if not sgs.Sanguosha:getSkill("kwtianbuxuan") then skills:append(kwtianbuxuan) end
if not sgs.Sanguosha:getSkill("kwtianbuxuan_Clear") then skills:append(kwtianbuxuan_Clear) end
  --“地不动”
kwdibudong = sgs.CreateTriggerSkill{
    name = "kwdibudong",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.HpChanged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:askForSkillInvoke(self:objectName(), data) then
		    room:broadcastSkillInvoke(self:objectName())
            if player:isChained() then
				room:setPlayerProperty(player, "chained", sgs.QVariant(false))
			end
			if not player:faceUp() then
				player:turnOver()
			end
			room:drawCards(player, 1, self:objectName())
			player:loseMark("&kwxingkong")
        end
    end,
	can_trigger = function(self, player)
	    return player:hasSkill("kwwanren") and player:getMark("&kwxingkong") >= 1 and not player:hasFlag("banWodimeSkills")
	end,
}
if not sgs.Sanguosha:getSkill("kwdibudong") then skills:append(kwdibudong) end
  --“强运”
kwqiangyun = sgs.CreateTriggerSkill{
	name = "kwqiangyun",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.AskForRetrial},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local judge = data:toJudge()
		if judge.who:objectName() ~= player:objectName() then return false end
		local prompt_list = {
			"@kwqiangyun-card",
			judge.who:objectName(),
			self:objectName(),
			judge.reason,
			tostring(judge.card:getEffectiveId())
		}
		local prompt = table.concat(prompt_list, ":")
		local card = room:askForCard(player, "..", prompt, data, sgs.Card_MethodResponse, judge.who, true)
		if card then
			room:retrial(card, player, judge, self:objectName(), true)
			player:loseMark("&kwxingkong")
			room:broadcastSkillInvoke(self:objectName())
		end
	end,
	can_trigger = function(self, player)
		if not (player and player:isAlive() and player:hasSkill("kwwanren") and player:getMark("&kwxingkong") >= 1) then return false end
		if player:isKongcheng() then
			local has_card = false
			for i = 0, 3, 1 do
				local equip = player:getEquip(i)
				if equip then has_card = true
					break
				end
			end
			return has_card
		else
			return true
		end
	end,
}
if not sgs.Sanguosha:getSkill("kwqiangyun") then skills:append(kwqiangyun) end
  --“引导”
kwyindao = sgs.CreateViewAsSkill{
	name = "kwyindao",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isKindOf("TrickCard") and to_select:isBlack()
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local chain = sgs.Sanguosha:cloneCard("iron_chain", cards[1]:getSuit(), cards[1]:getNumber())
			chain:addSubcard(cards[1])
			chain:setSkillName(self:objectName())
			return chain
		end
	end,
	enabled_at_play = function(self, player)
	    return player:getMark("&kwxingkong") >= 1 and not player:hasFlag("kwyindao_used")
	end,
}
if not sgs.Sanguosha:getSkill("kwyindao") then skills:append(kwyindao) end
  --“丰收”
kwfengshou = sgs.CreateViewAsSkill{
	name = "kwfengshou",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isKindOf("TrickCard") and to_select:isRed()
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local grace = sgs.Sanguosha:cloneCard("amazing_grace", cards[1]:getSuit(), cards[1]:getNumber())
			grace:addSubcard(cards[1])
			grace:setSkillName(self:objectName())
			return grace
		end
	end,
	enabled_at_play = function(self, player)
	    return player:getMark("&kwxingkong") >= 1 and not player:hasFlag("kwfengshou_used")
	end,
}
if not sgs.Sanguosha:getSkill("kwfengshou") then skills:append(kwfengshou) end
    --实现“引导”和“丰收”出牌阶段限一次
kwyindao_kwfengshou_limited = sgs.CreateTriggerSkill{
    name = "kwyindao_kwfengshou_limited",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
	    local card = data:toCardUse().card
		if player:getPhase() == sgs.Player_Play then
	        if player:hasSkill("kwyindao") and card:getSkillName() == "kwyindao" then
		        room:setPlayerFlag(player, "kwyindao_used")
		    elseif player:hasSkill("kwfengshou") and card:getSkillName() == "kwfengshou" then
		        room:setPlayerFlag(player, "kwfengshou_used")
			end
		end
	end,
	can_trigger = function(self, player)
	    return true
	end,
}
if not sgs.Sanguosha:getSkill("kwyindao_kwfengshou_limited") then skills:append(kwyindao_kwfengshou_limited) end
  --“诸神”
kwzhushenCard = sgs.CreateSkillCard{
    name = "kwzhushenCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
	    local num = source:getMark("&kwxingkong")
        if num >= 1 then
		    room:broadcastSkillInvoke(self:objectName())
		    source:loseMark("&kwxingkong")
			local benefit = room:getAllPlayers()
			for _, player in sgs.qlist(benefit) do
				room:recover(player, sgs.RecoverStruct(source))
			end
			for _, player in sgs.qlist(benefit) do
			    if not player:isNude() then
				    room:askForDiscard(player, "kwzhushen", 1, 1, false, true)
			    end
			end
		end
	end,
}
kwzhushen = sgs.CreateZeroCardViewAsSkill{
    name = "kwzhushen",
	view_as = function()
	    return kwzhushenCard:clone()
	end,
	enabled_at_play = function(self, player)
	    return player:getMark("&kwxingkong") >= 1 and not player:hasUsed("#kwzhushenCard")
	end,
}
if not sgs.Sanguosha:getSkill("kwzhushen") then skills:append(kwzhushen) end
  --“灯火”
kwdenghuoCard = sgs.CreateSkillCard{
    name = "kwdenghuoCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
	    return #targets == 0
	end,
	on_use = function(self, room, source, targets)
	    local num = source:getMark("&kwxingkong")
        if num >= 1 then
		    room:broadcastSkillInvoke(self:objectName())
		    source:loseMark("&kwxingkong")
	        local dest = targets[1]
		    local damage = sgs.DamageStruct()
		    damage.from = source
		    damage.to = dest
		    damage.nature = sgs.DamageStruct_Fire
		    room:damage(damage)
            room:drawCards(dest, 1, "kwdenghuo")
		end
	end,
}
kwdenghuo = sgs.CreateZeroCardViewAsSkill{
    name = "kwdenghuo",
	view_as = function()
	    return kwdenghuoCard:clone()
	end,
	enabled_at_play = function(self, player)
	    return player:getMark("&kwxingkong") >= 1 and not player:hasUsed("#kwdenghuoCard")
	end,
}
if not sgs.Sanguosha:getSkill("kwdenghuo") then skills:append(kwdenghuo) end
  --“独旅”
kwdulv = sgs.CreateTriggerSkill{
	name = "kwdulv",
	global = true,
	frequency = sgs.Skill_Frequent, --直接不询问了，防止重复询问，点【取消】=不选择发动
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local death = data:toDeath()
		if death.who:objectName() == player:objectName() then
		return false end
		local choices = {}
		table.insert(choices, "draw2cards")
		table.insert(choices, "recover1hp")
		table.insert(choices, "cancel")
		local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
		if choice ~= "cancel" then player:loseMark("&kwxingkong") end
		if choice == "draw2cards" then
			player:drawCards(2, self:objectName())
		elseif choice == "recover1hp" then
			local recover = sgs.RecoverStruct()
			recover.who = player
			room:recover(player, recover)
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("kwwanren") and player:getMark("&kwxingkong") > 0
	end,
}
if not sgs.Sanguosha:getSkill("kwdulv") then skills:append(kwdulv) end
----------

kwfulinCard = sgs.CreateSkillCard{
	name = "kwfulinCard",
	skill_name = "kwfulin",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
	    room:broadcastSkillInvoke(self:objectName())
	    source:loseMark("&kwxingkong", 3)
		room:removePlayerMark(source, "@kwfulin")
		local benefit = targets[1]
		local count = benefit:getMaxHp()
		local mhp = sgs.QVariant()
		mhp:setValue(count + 1)
		room:setPlayerProperty(benefit, "maxhp", mhp)
		local recover = sgs.RecoverStruct()
		recover.who = benefit
		room:recover(benefit, recover)
		benefit:throwJudgeArea()
	end,
}
kwfulinVS = sgs.CreateZeroCardViewAsSkill{
	name = "kwfulin",
	view_as = function()
		return kwfulinCard:clone()
	end,
	    enabled_at_play = function(self, player)
		return player:getMark("&kwxingkong") >= 3 and player:getMark("@kwfulin") > 0
	end,
}
kwfulin = sgs.CreateTriggerSkill{
	name = "kwfulin",
	frequency = sgs.Skill_Limited,
	limit_mark = "@kwfulin",
	view_as_skill = kwfulinVS,
	on_trigger = function()
	end,
}
godWodime:addSkill(kwfulin)

--『冠位指定/人理保障天球』--
GrandOrder_AnimaAnimusphere = function(player, target, damagePoint)
	local damage = sgs.DamageStruct()
	damage.from = player
	damage.to = target
	damage.damage = damagePoint
	damage.nature = sgs.DamageStruct_Fire
	player:getRoom():damage(damage)
end
-------
kwjiyunCard = sgs.CreateSkillCard{
	name = "kwjiyunCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		source:setFlags("kwjiyunUsing")
		source:setFlags("kwtianbuxuanSource") --配合回合结束清除非锁失效标记
		room:doLightbox("$GrandOrder_AnimaAnimusphere")
		source:loseMark("&kwxingkong", 7)
		room:loseMaxHp(source, 1)
		local players = room:getOtherPlayers(source)
		for _, Chaldea in sgs.qlist(players) do
		    if Chaldea:isAlive() then
				if Chaldea:getMark("@skill_invalidity") == 0 then
				    Chaldea:setFlags("kwtianbuxuanTarget") --配合回合结束清除非锁失效标记
				    room:addPlayerMark(Chaldea, "@skill_invalidity")
				end
				Chaldea:throwAllEquips()
			end
		end
		for _, Chaldea in sgs.qlist(players) do
			GrandOrder_AnimaAnimusphere(source, Chaldea, 1)
		end
		source:setFlags("-kwjiyunUsing")
	end,
}
kwjiyun = sgs.CreateZeroCardViewAsSkill{
	name = "kwjiyun",
	view_as = function()
		return kwjiyunCard:clone()
	end,
	enabled_at_play = function(self,player)
		return player:getMark("&kwxingkong") >= 7 and not player:hasUsed("#kwjiyunCard")
	end,
}
godWodime:addSkill(kwjiyun)

--神-戴比特·泽姆·沃伊德
godDaybit = sgs.General(extension, "godDaybit", "god", 7, true, true)

voidkongdongCard = sgs.CreateSkillCard{
	name = "voidkongdongCard",
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
		local _card = sgs.Self:getTag("voidkongdong"):toCard()
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
		local _card = sgs.Self:getTag("voidkongdong"):toCard()
		if _card == nil then
			return false
		end
		local card = sgs.Sanguosha:cloneCard(_card)
		card:setCanRecast(false)
		card:deleteLater()
		return card and card:targetsFeasible(players, sgs.Self)
	end,
	on_validate = function(self, card_use)
		local dbt = card_use.from
		local room = dbt:getRoom()
		room:loseHp(dbt, 1)
		room:setPlayerFlag(dbt, "voidkongdongUsed")
		local user_string = self:getUserString()
		if (string.find(user_string, "slash") or string.find(user_string, "Slash")) and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
        	local slashs = sgs.Sanguosha:getSlashNames()
        	user_string = room:askForChoice(dbt, "voidkongdong_slash", table.concat(slashs, "+"))
    	end
    	local use_card = sgs.Sanguosha:cloneCard(user_string)
		if not use_card then return nil end
    	use_card:setSkillName("_voidkongdong")
    	use_card:deleteLater()
    	return use_card
	end,
	on_validate_in_response = function(self, dbt)
		local room = dbt:getRoom()
		room:loseHp(dbt, 1)
		room:setPlayerFlag(dbt, "voidkongdongUsed")
		local to_voidkongdong = ""
		if self:getUserString() == "peach+analeptic" then
			local voidkongdong_list = {}
			table.insert(voidkongdong_list, "peach")
			local sts = sgs.GetConfig("BanPackages", "")
			if not string.find(sts, "maneuvering") then
				table.insert(voidkongdong_list, "analeptic")
			end
			to_voidkongdong = room:askForChoice(dbt, "voidkongdong_saveself", table.concat(voidkongdong_list, "+"))
			dbt:setTag("voidkongdongSaveSelf", sgs.QVariant(to_voidkongdong))
		elseif self:getUserString() == "slash" then
			local voidkongdong_list = {}
			table.insert(voidkongdong_list, "slash")
			local sts = sgs.GetConfig("BanPackages", "")
			if not string.find(sts, "maneuvering") then
				table.insert(voidkongdong_list, "normal_slash")
				table.insert(voidkongdong_list, "fire_slash")
				table.insert(voidkongdong_list, "thunder_slash")
				table.insert(voidkongdong_list, "ice_slash")
			end
			to_voidkongdong = room:askForChoice(dbt, "voidkongdong_slash", table.concat(voidkongdong_list, "+"))
			dbt:setTag("voidkongdongSlash", sgs.QVariant(to_voidkongdong))
		else
			to_voidkongdong = self:getUserString()
		end
		local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		local user_str = ""
		if to_voidkongdong == "slash" then
			if card:isKindOf("Slash") then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		elseif to_voidkongdong == "normal_slash" then
			user_str = "slash"
		else
			user_str = to_voidkongdong
		end
		local use_card = sgs.Sanguosha:cloneCard(user_str)
		use_card:setSkillName("voidkongdong")
		use_card:deleteLater()
		return use_card
	end,
}
voidkongdong = sgs.CreateZeroCardViewAsSkill{
	name = "voidkongdong",
	response_or_use = true,
	view_as = function(self, cards)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or
			sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
        	local c = voidkongdongCard:clone()
			c:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
			return c
		end
		local card = sgs.Self:getTag("voidkongdong"):toCard()
		if card and card:isAvailable(sgs.Self) then
			local c = voidkongdongCard:clone()
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
		return not player:hasFlag("voidkongdongUsed")
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
		if player:hasFlag("voidkongdongUsed") or string.sub(pattern, 1, 1) == "." or string.sub(pattern, 1, 1) == "@" then
            return false
		end
        if pattern == "peach" and player:getMark("Global_PreventPeach") > 0 then return false end
        if string.find(pattern, "[%u%d]") then return false end
		return true
	end,
	enabled_at_nullification = function(self, player)
		local current = player:getRoom():getCurrent()
		if not current or current:isDead() or current:getPhase() == sgs.Player_NotActive then return false end
		return not player:hasFlag("voidkongdongUsed")
	end,
}
voidkongdongFlagClear = sgs.CreateTriggerSkill{
    name = "voidkongdongFlagClear",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TurnStart, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TurnStart then
			if player:hasFlag("voidkongdongUsed") then
				room:setPlayerFlag(player, "-voidkongdongUsed")
			end
		else
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				for _, v in sgs.qlist(room:getAlivePlayers()) do
                	if v:hasFlag("voidkongdongUsed") then
                    	room:setPlayerFlag(v, "-voidkongdongUsed")
					end
				end
            end
        end
	end,
	can_trigger = function(self, player)
		return player:hasFlag("voidkongdongUsed")
	end,
}
voidkongdongAOE = sgs.CreateTriggerSkill{
    name = "voidkongdongAOE",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("AOE") and use.card:getSkillName() == "voidkongdong" then
			if math.random() > 0.5 then
				room:broadcastSkillInvoke("voidkongdong", 3)
				room:doLightbox("$voidkongdong3")
			else
				room:broadcastSkillInvoke("voidkongdong", 4)
				room:doLightbox("$voidkongdong4")
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
voidkongdong:setGuhuoDialog("lr")
godDaybit:addSkill(voidkongdong)
if not sgs.Sanguosha:getSkill("voidkongdongFlagClear") then skills:append(voidkongdongFlagClear) end
if not sgs.Sanguosha:getSkill("voidkongdongAOE") then skills:append(voidkongdongAOE) end

voidRuleReverseCard = sgs.CreateSkillCard{
	name = "voidRuleReverseCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		source:loseMark("@VOID")
		room:broadcastSkillInvoke("voidRuleReverse")
		--1.0 人理烧却
		local va = room:askForPlayerChosen(source, room:getAllPlayers(), "voidRuleReverse", "voidRuleReverse-invokeA", true, true)
		if va then
			room:setPlayerChained(va)
			room:damage(sgs.DamageStruct("voidRuleReverse", source, va, 1, sgs.DamageStruct_Fire))
			room:loseMaxHp(source, 1)
		else
			room:setPlayerFlag(source, "voidRuleReverse_notdoAll")
		end
		--2.0 人理冻结
		local vb = room:askForPlayerChosen(source, room:getAllPlayers(), "voidRuleReverse", "voidRuleReverse-invokeB", true, true)
		if vb then
			vb:turnOver()
			room:damage(sgs.DamageStruct("voidRuleReverse", source, vb, 1, sgs.DamageStruct_Ice))
			room:loseMaxHp(source, 1)
		else
			room:setPlayerFlag(source, "voidRuleReverse_notdoAll")
		end
		--2.1永久冻土帝国/2.2无间冰焰世纪
		local vc = room:askForPlayerChosen(source, room:getAllPlayers(), "voidRuleReverse", "voidRuleReverse-invokeC", true, true)
		if vc then
			if not vc:isAllNude() then
				local id1 = room:askForCardChosen(source, vc, "hej", "voidRuleReverse")
				room:throwCard(id1, vc, source)
			end
			room:damage(sgs.DamageStruct("voidRuleReverse", source, vc, 1, sgs.DamageStruct_Thunder))
			room:loseMaxHp(source, 1)
		else
			room:setPlayerFlag(source, "voidRuleReverse_notdoAll")
		end
		--2.3人智统合真国/2.4创世灭亡轮回
		local vd = room:askForPlayerChosen(source, room:getAllPlayers(), "voidRuleReverse", "voidRuleReverse-invokeD", true, true)
		if vd then
			if not vd:isAllNude() then
				local id2 = room:askForCardChosen(source, vd, "hej", "voidRuleReverse")
				room:obtainCard(source, id2, false)
			end
			room:damage(sgs.DamageStruct("voidRuleReverse", source, vd, 1, sgs.DamageStruct_Poison))
			room:loseMaxHp(source, 1)
		else
			room:setPlayerFlag(source, "voidRuleReverse_notdoAll")
		end
		--2.51 神代巨神海洋
		local islands = sgs.SPlayerList()
		for _, i in sgs.qlist(room:getAllPlayers()) do
			if i:getEquips():length() > 0 then
				islands:append(i)
			end
		end
		local from
		if islands:length() > 1 then
			from = room:askForPlayerChosen(source, islands, "voidRuleReverse", "voidRuleReverse_Equip", true, true)
		elseif islands:length() == 1 then
			for _, i in sgs.qlist(room:getAllPlayers()) do
				if i:getEquips():length() > 0 then
					from = i
					break
				end
			end
		end
		if from and from:getEquips():length() > 0 then
			local card_id = room:askForCardChosen(source, from, "e", "voidRuleReverse", false, sgs.Card_MethodNone, sgs.IntList(), true)
			if card_id >= 0 then
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
				room:setTag("voidRuleReverseEquipTarget", tag)
				local to = room:askForPlayerChosen(source, tos, "voidRuleReverse", "@voidRuleReverse_Equip-to:" .. card:objectName())
				if to then
					room:moveCardTo(card, from, to, place, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, source:objectName(), "voidRuleReverse", ""))
				end
				room:removeTag("voidRuleReverseEquipTarget")
				room:setPlayerFlag(source, "voidRuleReverseMove_do")
			end
		end
		--2.52 星间都市山脉
		local MG = sgs.SPlayerList()
		for _, m in sgs.qlist(room:getAllPlayers()) do
			if m:getJudgingArea():length() > 0 then
				MG:append(m)
			end
		end
		local from
		if MG:length() > 1 then
			from = room:askForPlayerChosen(source, MG, "voidRuleReverse", "voidRuleReverse_Judge", true, true)
		elseif MG:length() == 1 then
			for _, m in sgs.qlist(room:getAllPlayers()) do
				if m:getJudgingArea():length() > 0 then
					from = m
					break
				end
			end
		end
		if from and from:getJudgingArea():length() > 0 then
			local card_id = room:askForCardChosen(source, from, "j", "voidRuleReverse", false, sgs.Card_MethodNone, sgs.IntList(), true)
			if card_id >= 0 then
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
				room:setTag("voidRuleReverseJudgeTarget", tag)
				local to = room:askForPlayerChosen(source, tos, "voidRuleReverse", "@voidRuleReverse_Judge-to:" .. card:objectName())
				if to then
					room:moveCardTo(card, from, to, place, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, source:objectName(), "voidRuleReverse", ""))
				end
				room:removeTag("voidRuleReverseJudgeTarget")
				if not source:hasFlag("voidRuleReverseMove_do") then rom:setPlayerFlag(source, "voidRuleReverseMove_do") end
			end
		end
		if source:hasFlag("voidRuleReverseMove_do") then --检测是否执行了第五项
			room:loseMaxHp(source, 1)
		else
			room:setPlayerFlag(source, "voidRuleReverse_notdoAll")
		end
		  --星间都市山脉:击落神明之日
		local ve = room:askForPlayerChosen(source, room:getAllPlayers(), "voidRuleReverse", "voidRuleReverse-invokeF", true, true)
		if ve then
			local x = ve:getMaxHp()
			local y = ve:getHp()
			local z = x - y
			local recover = sgs.RecoverStruct()
			recover.who = ve
			recover.recover = z
			room:recover(ve, recover)
			local w = x - ve:getHandcardNum()
			room:drawCards(ve, w, "voidRuleReverse")
			room:loseMaxHp(source, 1)
		else
			room:setPlayerFlag(source, "voidRuleReverse_notdoAll")
		end
		----
		--2.6 妖精圆桌领域
		local vf = room:askForPlayerChosen(source, room:getAllPlayers(), "voidRuleReverse", "voidRuleReverse-invokeG1", true, true)
		if vf then
			local vg = room:askForPlayerChosen(source, room:getOtherPlayers(vf), "voidRuleReverse", "voidRuleReverse-invokeG2")
			room:swapSeat(vf, vg)
			room:loseMaxHp(source, 1)
		else
			room:setPlayerFlag(source, "voidRuleReverse_notdoAll")
		end
		--2.7 黄金树海纪行
		local vh = room:askForPlayerChosen(source, room:getAllPlayers(), "voidRuleReverse", "voidRuleReverse-invokeH", true, true)
		if vh then
			vh:throwEquipArea()
			room:drawCards(vh, 2, "voidRuleReverse")
			local recover = sgs.RecoverStruct()
			recover.recover = 2
			recover.who = vh
			room:recover(vh, recover)
			room:loseMaxHp(source, 1)
		else
			room:setPlayerFlag(source, "voidRuleReverse_notdoAll")
		end
		--2023：没想到这中间还插入了间章......
		
		--2.0终章 终极大招
		if not source:hasFlag("voidRuleReverse_notdoAll") or math.random() < 0.2 then
			room:broadcastSkillInvoke("voidRuleReverse_FINAL")
			for _, frls in sgs.qlist(room:getOtherPlayers(source)) do
				room:damage(sgs.DamageStruct("voidRuleReverse", source, frls, math.random(1,7), sgs.DamageStruct_Normal))
			end
			room:loseMaxHp(source, 1)
		end
	end,
}
voidRuleReverseVS = sgs.CreateZeroCardViewAsSkill{
	name = "voidRuleReverse",
	view_as = function()
		return voidRuleReverseCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@VOID") > 0 and not player:hasFlag("voidRuleReverse_limited") --不加这个标志出牌阶段可以按此按钮主动发动......
	end,
	response_pattern = "@@voidRuleReverse",
}
voidRuleReverse = sgs.CreateTriggerSkill{
	name = "voidRuleReverse",
	frequency = sgs.Skill_Limited,
	waked_skills = "voidRuleReverse_FINAL",
	limit_mark = "@VOID",
	view_as_skill = voidRuleReverseVS,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play and player:getMark("@VOID") > 0 then
			if not room:askForUseCard(player, "@@voidRuleReverse", "@voidRuleReverse-card") then
				room:setPlayerFlag(player, "voidRuleReverse_limited")
			end
		end
	end,
}
godDaybit:addSkill(voidRuleReverse)
voidRuleReverse_FINAL = sgs.CreateTriggerSkill{
	name = "voidRuleReverse_FINAL",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end,
}
godDaybit:addRelateSkill("voidRuleReverse_FINAL")
if not sgs.Sanguosha:getSkill("voidRuleReverse_FINAL") then skills:append(voidRuleReverse_FINAL) end

--==2.【特殊场景：天使的遗物】==--
--BOSS：魔-戴比特·泽姆·沃伊德
devilDaybit = sgs.General(extension, "devilDaybit", "devil", 7, true, true)

--游戏开始时，神戴比特与魔戴比特可以互相更换：
Daybit_exchange = sgs.CreateTriggerSkill{
	name = "Daybit_exchange",
	global = true,
	priority = 10, --对应10岁的小泽姆
	frequency = sgs.Skill_Frequent,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local can_invoke = true
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:getMark("&godRule") > 0 or p:getMark("MOD_AngelsRelics") > 0 or p:getMark(self:objectName()) > 0 then --若处于小型场景“诸神黄昏”以及特殊场景“天使的遗物”中，不可更换
				can_invoke = false
			end
			if can_invoke and ((p:getGeneralName() == "godDaybit" or p:getGeneral2Name() == "godDaybit")
			or (p:getGeneralName() == "devilDaybit" or p:getGeneral2Name() == "devilDaybit")) then
				local choices = {}
				if p:getGeneralName() == "godDaybit" or p:getGeneral2Name() == "godDaybit" then
					table.insert(choices, "AngelsRelics")
				end
				if p:getGeneralName() == "devilDaybit" or p:getGeneral2Name() == "devilDaybit" then
					table.insert(choices, "TreeSeaRuins")
				end
				table.insert(choices, "cancel")
				local choice = room:askForChoice(p, self:objectName(), table.concat(choices, "+"))
				if choice == "AngelsRelics" then
					if p:getGeneralName() == "godDaybit" then
						room:changeHero(p, "devilDaybit", false, false, false, true)
					elseif p:getGeneral2Name() == "godDaybit" then
						room:changeHero(p, "devilDaybit", false, false, true, true)
					end
					if not p:hasSkill("voidRuleReverse") then room:setPlayerMark(p, "@VOID", 0) end
				elseif choice == "TreeSeaRuins" then
					if p:getGeneralName() == "devilDaybit" then
						room:changeHero(p, "godDaybit", false, false, false, true)
					elseif p:getGeneral2Name() == "devilDaybit" then
						room:changeHero(p, "godDaybit", false, false, true, true)
					end
				end
				room:addPlayerMark(p, self:objectName())
			end
		end
	end,
	can_trigger = function(self, player)
		return player and player:getSeat() == 1 and player:getMark("&godRule") == 0 and player:getMark("MOD_AngelsRelics") == 0
	end,
}
if not sgs.Sanguosha:getSkill("Daybit_exchange") then skills:append(Daybit_exchange) end

voidObserveUniverse = sgs.CreateTargetModSkill{
    name = "voidObserveUniverse",
	pattern = "Card",
	distance_limit_func = function(self, from)
	    if from:hasSkill(self:objectName()) then
			return 1000
		else
			return 0
		end
	end,
}
voidObserveUniverseSC = sgs.CreateTriggerSkill{
	name = "voidObserveUniverseSC",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			--if use.card and not use.card:isKindOf("SkillCard") and use.from:objectName() == player:objectName() and player:hasSkill("voidObserveUniverse") then
			if use.card and use.from:objectName() == player:objectName() and player:hasSkill("voidObserveUniverse") then
				for _, p in sgs.qlist(use.to) do
					if p:objectName() ~= player:objectName() and not p:hasFlag(self:objectName()) and not p:isKongcheng() then
						room:sendCompulsoryTriggerLog(player, "voidObserveUniverse")
						room:broadcastSkillInvoke("voidObserveUniverse")
						local ids = sgs.IntList()
						for _, card in sgs.qlist(p:getHandcards()) do
							if card then
								ids:append(card:getEffectiveId())
							end
						end
						local card_id = room:doGongxin(player, p, ids)
						if (card_id == 0) then return end
						room:setPlayerFlag(p, self:objectName())
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag(self:objectName()) then
					room:setPlayerFlag(p, "-voidObserveUniverseSC")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
devilDaybit:addSkill(voidObserveUniverse)
if not sgs.Sanguosha:getSkill("voidObserveUniverseSC") then skills:append(voidObserveUniverseSC) end

voidtongxinGMS = sgs.CreateTriggerSkill{
	name = "voidtongxinGMS",
	global = true,
	priority = -100,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local n = 0
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if p then n = n + 1 end
		end
		room:sendCompulsoryTriggerLog(player, "voidtongxin")
		player:gainMark("&AngelsRelics", n)
		room:broadcastSkillInvoke("voidtongxin", 1)
		room:getThread():delay(13500) --等魔戴比特把开场语音说完
	end,
	can_trigger = function(self, player)
		return player:hasSkill("voidtongxin")
	end,
}
voidtongxinCard = sgs.CreateSkillCard{
	name = "voidtongxinCard",
	skill_name = "voidtongxin",
	target_fixed = false,
	mute = true,
	filter = function(self, targets, to_select, player)
		local n = player:getMark("&AngelsRelics") - 1
		return #targets < n and to_select:objectName() ~= sgs.Self:objectName() and to_select:getMark("&AngelsRelics") == 0
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		for _, p in pairs(targets) do
			source:loseMark("&AngelsRelics", 1)
			p:gainMark("&AngelsRelics", 1)
		end
	end,
}
voidtongxinVS = sgs.CreateZeroCardViewAsSkill{
	name = "voidtongxin",
	view_as = function()
		return voidtongxinCard:clone()
	end,
	response_pattern = "@@voidtongxin",
}
voidtongxin = sgs.CreateTriggerSkill{
	name = "voidtongxin",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed, sgs.TurnStart, sgs.EventPhaseStart},
	view_as_skill = voidtongxinVS,
	waked_skills = "voidAngelsRelics",
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:getSkillName() == self:objectName() then
				room:broadcastSkillInvoke(self:objectName(), 2)
			end
		elseif event == sgs.TurnStart then
			if player:getMark("&AngelsRelics") > 1 and player:getMark("voidtongxin_FirstUsed") > 0 then
				room:askForUseCard(player, "@@voidtongxin", "@voidtongxin-card")
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_RoundStart then return false end
			if player:getMark("voidtongxin_FirstUsed") == 0 then --处理第一个回合开始前不发动的问题
				room:askForUseCard(player, "@@voidtongxin", "@voidtongxin-card")
				room:addPlayerMark(player, "voidtongxin_FirstUsed")
			end
			if player:getMark("voidtongxinTurn") < 6 then room:addPlayerMark(player, "voidtongxinTurn")
			else return false end
			local AngelsRelics = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("&AngelsRelics") > 0 then
					AngelsRelics:append(p)
				end
			end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			if player:getMark("voidtongxinTurn") == 1 then room:broadcastSkillInvoke(self:objectName(), 3) --第一个回合
			elseif player:getMark("voidtongxinTurn") == 2 then room:broadcastSkillInvoke(self:objectName(), 4) --第二个回合
			elseif player:getMark("voidtongxinTurn") == 3 then room:broadcastSkillInvoke(self:objectName(), 5) --第三个回合
			elseif player:getMark("voidtongxinTurn") == 4 then room:broadcastSkillInvoke(self:objectName(), 6) --第四个回合
			elseif player:getMark("voidtongxinTurn") == 5 then room:broadcastSkillInvoke(self:objectName(), 7) --第五个回合
			elseif player:getMark("voidtongxinTurn") == 6 then room:broadcastSkillInvoke(self:objectName(), 8) --第六个回合
			end
			room:getThread():delay(2000)
			for _, p in sgs.qlist(AngelsRelics) do
				if player:getMark("voidtongxinTurn") == 1 then
					p:gainMark("@voidtongxin_WSFY", 3)
					room:drawCards(p, 1, self:objectName())
				elseif player:getMark("voidtongxinTurn") == 2 then
					p:gainMark("@voidtongxin_BJLv", 3)
					room:drawCards(p, 1, self:objectName())
				elseif player:getMark("voidtongxinTurn") == 3 then
					p:gainMark("@voidtongxin_GJL", 3)
					room:drawCards(p, 1, self:objectName())
				elseif player:getMark("voidtongxinTurn") == 4 then
					p:gainMark("@voidtongxin_BJWL", 3)
					room:drawCards(p, 1, self:objectName())
				elseif player:getMark("voidtongxinTurn") == 5 then
					p:gainMark("@voidtongxin_WDGT", 3)
					room:drawCards(p, 1, self:objectName())
				elseif player:getMark("voidtongxinTurn") == 6 then
					room:drawCards(p, 5, self:objectName())
					if p:isChained() then room:setPlayerChained(p) end
			    	if not p:faceUp() then p:turnOver() end
					room:drawCards(p, 1, self:objectName())
				end
			end
		end
	end,
}
devilDaybit:addSkill(voidtongxin)
devilDaybit:addRelateSkill("voidAngelsRelics")
if not sgs.Sanguosha:getSkill("voidtongxinGMS") then skills:append(voidtongxinGMS) end

--==指令(BUFF)效果区==--
--第一个回合：造成伤害时(有20%的概率)无视护甲。
voidtongxinOne = sgs.CreateTriggerSkill{
	name = "voidtongxinOne",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageCaused, sgs.DamageComplete},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if event == sgs.DamageCaused then
			if damage.from:objectName() ~= player:objectName() or player:getMark("&AngelsRelics") == 0 or player:getMark("@voidtongxin_WSFY") == 0
			or damage.to:getHujia() == 0 or math.random() > 0.2 then return false end
			local n = damage.to:getHujia()
			room:setPlayerMark(damage.to, "voidtongxinOne_Hujias", n)
			room:sendCompulsoryTriggerLog(player, self:objectName())
			damage.to:loseAllHujias()
		elseif event == sgs.DamageComplete then
			if damage.to:getMark("voidtongxinOne_Hujias") == 0 then return false end
			local n = damage.to:getMark("voidtongxinOne_Hujias")
			damage.to:gainHujia(n)
			room:setPlayerMark(damage.to, "voidtongxinOne_Hujias", 0)
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("voidtongxinOne") then skills:append(voidtongxinOne) end
--第二个回合：造成的伤害有10%的概率暴击。
voidtongxinTwo = sgs.CreateTriggerSkill{
	name = "voidtongxinTwo",
	global = true,
	priority = 2,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.from:objectName() ~= player:objectName() or math.random() > 0.1 then return false end
		room:sendCompulsoryTriggerLog(player, self:objectName())
		damage.damage = damage.damage*2
		data:setValue(damage)
	end,
	can_trigger = function(self, player)
		return player:getMark("&AngelsRelics") > 0 and player:getMark("@voidtongxin_BJLv") > 0
	end,
}
if not sgs.Sanguosha:getSkill("voidtongxinTwo") then skills:append(voidtongxinTwo) end
--第三个回合：使用伤害类卡牌时有30%的概率弃置目标一张牌。
voidtongxinThree = sgs.CreateTriggerSkill{
	name = "voidtongxinThree",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.from:objectName() ~= player:objectName() or not use.card:isDamageCard() or math.random() > 0.3 then return false end
		room:sendCompulsoryTriggerLog(player, self:objectName())
		for _, p in sgs.qlist(use.to) do
			if not p:isNude() and player:canDiscard(p, "he") then
				local card = room:askForCardChosen(player, p, "he", self:objectName(), false, sgs.Card_MethodDiscard) room:throwCard(card, p, player)
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&AngelsRelics") > 0 and player:getMark("@voidtongxin_GJL") > 0
	end,
}
if not sgs.Sanguosha:getSkill("voidtongxinThree") then skills:append(voidtongxinThree) end
--第四个回合：造成的伤害有60%的概率+1。
voidtongxinFour = sgs.CreateTriggerSkill{
	name = "voidtongxinFour",
	global = true,
	priority = 4,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.from:objectName() ~= player:objectName() or math.random() > 0.6 then return false end
		room:sendCompulsoryTriggerLog(player, self:objectName())
		damage.damage = damage.damage + 1
		data:setValue(damage)
	end,
	can_trigger = function(self, player)
		return player:getMark("&AngelsRelics") > 0 and player:getMark("@voidtongxin_BJWL") > 0
	end,
}
if not sgs.Sanguosha:getSkill("voidtongxinFour") then skills:append(voidtongxinFour) end
--第五个回合：使用伤害类卡牌时令目标的非锁定技失效，且不可被响应，直到卡牌结算结束。
voidtongxinFive = sgs.CreateTriggerSkill{
	name = "voidtongxinFive",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecified, sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.TargetSpecified then
			if use.from:objectName() ~= player:objectName() or not use.card:isDamageCard() then return false end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			local no_respond_list = use.no_respond_list
			for _, p in sgs.qlist(use.to) do
				room:addPlayerMark(p, "@skill_invalidity")
				table.insert(no_respond_list, p:objectName())
			end
			use.no_respond_list = no_respond_list
			data:setValue(use)
		elseif event == sgs.CardFinished then
			for _, p in sgs.qlist(use.to) do
				if p:getMark("@skill_invalidity") > 0 then room:removePlayerMark(p, "@skill_invalidity") end --不清空，防止误清其他方式给予的非锁失效标记
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&AngelsRelics") > 0 and player:getMark("@voidtongxin_WDGT") > 0
	end,
}
if not sgs.Sanguosha:getSkill("voidtongxinFive") then skills:append(voidtongxinFive) end
  --效果持续三个回合：
voidtongxinContinue = sgs.CreateTriggerSkill{
	name = "voidtongxinContinue",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then return false end
		if player:getMark("@voidtongxin_WSFY") > 0 then player:loseMark("@voidtongxin_WSFY", 1) end
		if player:getMark("@voidtongxin_BJLv") > 0 then player:loseMark("@voidtongxin_BJLv", 1) end
		if player:getMark("@voidtongxin_GJL") > 0 then player:loseMark("@voidtongxin_GJL", 1) end
		if player:getMark("@voidtongxin_BJWL") > 0 then player:loseMark("@voidtongxin_BJWL", 1) end
		if player:getMark("@voidtongxin_WDGT") > 0 then player:loseMark("@voidtongxin_WDGT", 1) end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("voidtongxinContinue") then skills:append(voidtongxinContinue) end

--“天使的遗物”
voidAngelsRelicsSkillChanged = sgs.CreateTriggerSkill{ --技能的动态获得与失去
	name = "voidAngelsRelicsSkillChanged",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.MarkChanged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local mark = data:toMark()
		if mark.name == "&AngelsRelics" and mark.who:objectName() == player:objectName() then
			if mark.gain > 0 then
				if not player:hasSkill("voidAngelsRelics") then
					room:acquireSkill(player, "voidAngelsRelics")
				end
			elseif mark.gain < 0 and player:getMark("&AngelsRelics") == 0 then
				if player:hasSkill("voidAngelsRelics") then
					room:detachSkillFromPlayer(player, "voidAngelsRelics")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("voidAngelsRelicsSkillChanged") then skills:append(voidAngelsRelicsSkillChanged) end
  ----
voidAngelsRelics = sgs.CreateTriggerSkill{
	name = "voidAngelsRelics",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageCaused, sgs.DamageInflicted, sgs.EnterDying},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		--准恒星电波
		if event == sgs.DamageCaused then
			local n = 0.2
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:getMark("&AngelsRelics") > 0 then
					n = n + 0.1
				end
			end
			if math.random() <= n then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				damage.to:gainMark("@voidAngelsRelics_ZS")
			end
			local m = 0.1
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:getMark("&AngelsRelics") > 0 then
					m = m + 0.05
				end
			end
			if math.random() <= m then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				damage.to:gainMark("@voidAngelsRelics_DD")
			end
		elseif event == sgs.DamageInflicted then
			local n = 0.2
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:getMark("&AngelsRelics") > 0 then
					n = n + 0.1
				end
			end
			if math.random() <= n then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				damage.from:gainMark("@voidAngelsRelics_ZS")
			end
			local m = 0.1
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:getMark("&AngelsRelics") > 0 then
					m = m + 0.05
				end
			end
			if math.random() <= m then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				damage.from:gainMark("@voidAngelsRelics_DD")
			end
		elseif event == sgs.EnterDying then
			local dying = data:toDying()
			if player:getMark("voidAngelsRelics_EDfqc") < 2 then
			room:addPlayerMark(player, "voidAngelsRelics_EDfqc")
			else return false end
			--光不至领域
			if player:getMark("voidAngelsRelics_EDfqc") == 1 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				local maxhp = player:getMaxHp()
				local hp = math.min(1, maxhp)
				room:setPlayerProperty(player, "hp", sgs.QVariant(hp))
				if dying.damage.from and not dying.damage.from:isNude() then
					room:askForDiscard(dying.damage.from, self:objectName(), 4, 4, false, true) --dying.damage.from:throwAllHandCardsAndEquips()
				end
			--彼方外宇宙
			elseif player:getMark("voidAngelsRelics_EDfqc") == 2 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				local maxhp = player:getMaxHp()
				local hp = math.min(1, maxhp)
				room:setPlayerProperty(player, "hp", sgs.QVariant(hp))
				player:gainHujia(3)
				if player:isChained() then room:setPlayerChained(player) end
			    if not player:faceUp() then player:turnOver() end
			end
		end
	end,
}
if not sgs.Sanguosha:getSkill("voidAngelsRelics") then skills:append(voidAngelsRelics) end
--“灼伤”：回合结束时，受到1点无来源的火焰伤害。
voidAngelsRelics_ZS = sgs.CreateTriggerSkill{
	name = "voidAngelsRelics_ZS",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then return false end
		room:sendCompulsoryTriggerLog(player, self:objectName())
		room:damage(sgs.DamageStruct(self:objectName(), nil, player, 1, sgs.DamageStruct_Fire))
		player:loseMark("@voidAngelsRelics_ZS", 1)
	end,
	can_trigger = function(self, player)
		return player:getMark("@voidAngelsRelics_ZS") > 0
	end,
}
if not sgs.Sanguosha:getSkill("voidAngelsRelics_ZS") then skills:append(voidAngelsRelics_ZS) end
--“带电”：回合结束时有50%的概率触发，其距离为1及以内的所有其他角色各受到1点无来源的雷电伤害并有30%的概率获得“带电”状态。
voidAngelsRelics_DD = sgs.CreateTriggerSkill{
	name = "voidAngelsRelics_DD",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive or math.random() > 0.5 then return false end
		room:sendCompulsoryTriggerLog(player, self:objectName())
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if player:distanceTo(p) <= 1 then
				room:damage(sgs.DamageStruct(self:objectName(), nil, p, 1, sgs.DamageStruct_Thunder))
				if math.random() <= 0.3 then
					p:gainMark("@voidAngelsRelics_DD", 1)
				end
			end
		end
		player:loseMark("@voidAngelsRelics_DD", 1)
	end,
	can_trigger = function(self, player)
		return player:getMark("@voidAngelsRelics_DD") > 0
	end,
}
if not sgs.Sanguosha:getSkill("voidAngelsRelics_DD") then skills:append(voidAngelsRelics_DD) end

--================================================================ 主 体 内 容 ================================================================--
f_MOD_common = {}
f_MOD_2people = {}
f_MOD_3people = {}
f_MOD_4people = {}
f_MOD_5people = {}
f_MOD_6people = {}
f_MOD_7people = {}
f_MOD_8people = {}
f_MOD_9people = {}
f_MOD_10people = {}
f_MOD_all = {}
f_MODon = {}
f_MODon["cancel"] = function(player)
end
--选择副本
godstrengthenMODon = sgs.CreateTriggerSkill{
	name = "godstrengthenMODon",
	global = true,
	priority = 100000,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawInitialCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local choices = {}
		if room:getTag("godstrengthenMODon"):toBool() or table.contains(sgs.Sanguosha:getBanPackages(), "godstrengthenMODs") then return false end
		for _, c in ipairs(f_MOD_all) do
			table.insert(choices, c)
		end
		if string.find(room:getMode(), "p") then
			for _, c in ipairs(f_MOD_common) do
				table.insert(choices, c)
			end
			local mode = room:alivePlayerCount()
			if mode == 2 then --room:getMode() == "02p" then
				for _, c in ipairs(f_MOD_2people) do
					table.insert(choices, c)
				end
			elseif mode == 3 then --room:getMode() == "03p" then
				for _, c in ipairs(f_MOD_3people) do
					table.insert(choices, c)
				end
			elseif mode == 4 then --room:getMode() == "04p" then
				for _, c in ipairs(f_MOD_4people) do
					table.insert(choices, c)
				end
			elseif mode == 5 then --room:getMode() == "05p" then
				for _, c in ipairs(f_MOD_5people) do
					table.insert(choices, c)
				end
			elseif mode == 6 then --room:getMode() == "06p" then
				for _, c in ipairs(f_MOD_6people) do
					table.insert(choices, c)
				end
			elseif mode == 7 then --room:getMode() == "07p" then
				for _, c in ipairs(f_MOD_7people) do
					table.insert(choices, c)
				end
			elseif mode == 8 then --room:getMode() == "08p" then
				for _, c in ipairs(f_MOD_8people) do
					table.insert(choices, c)
				end
			elseif mode == 9 then --room:getMode() == "09p" then
				for _, c in ipairs(f_MOD_9people) do
					table.insert(choices, c)
				end
			elseif mode == 10 then --room:getMode() == "10p" then
				for _, c in ipairs(f_MOD_10people) do
					table.insert(choices, c)
				end
			end
		end
		table.insert(choices, "cancel") --正常开游戏
		if player:getState() == "online" then
			local choice = room:askForChoice(player, "godstrengthenMODchoice", table.concat(choices, "+"), data)
			if choice ~= "MOD_EnvironmentRedevelop" then
				room:setTag("godstrengthenMODon", sgs.QVariant(true))
			end
			f_MODon[choice](player)
		end
		--[[特殊场景：天使的遗物-->人理方增加起始手牌
		local mdbt, ar_dic = room:getLord(), 0
		if mdbt:getMark("MOD_AngelsRelics") == 0 then return false end
		if mbdt:getMark("MOD_AngelsRelics_renli") == 1 or mdbt:getMark("MOD_AngelsRelics_boss") == 5 then ar_dic = 4
		elseif mbdt:getMark("MOD_AngelsRelics_renli") == 2 or mdbt:getMark("MOD_AngelsRelics_boss") == 4 then ar_dic = 3
		elseif mbdt:getMark("MOD_AngelsRelics_renli") == 3 or mdbt:getMark("MOD_AngelsRelics_boss") == 3 then ar_dic = 2
		elseif mbdt:getMark("MOD_AngelsRelics_renli") == 4 or mdbt:getMark("MOD_AngelsRelics_boss") == 2 then ar_dic = 1
		elseif mbdt:getMark("MOD_AngelsRelics_renli") == 5 or mdbt:getMark("MOD_AngelsRelics_boss") == 1 then ar_dic = 0
		end
		if ar_dic > 0 and player:getRoleEnum() == sgs.Player_Rebel then data:setValue(data:toInt() + ar_dic) end]]
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("godstrengthenMODon") then skills:append(godstrengthenMODon) end

function getStringLength(inputstr)
    if not inputstr or type(inputstr) ~= "string" or #inputstr <= 0 then
        return nil
    end
    local length = 0
    local i = 1
    while true do
        local curByte = string.byte(inputstr, i)
        local byteCount = 1
        if curByte > 239 then
            byteCount = 4  -- 4字节字符
        elseif curByte > 223 then
            byteCount = 3  -- 汉字
        elseif curByte > 128 then
            byteCount = 2  -- 双字节字符
        else
            byteCount = 1  -- 单字节字符
        end
        i = i + byteCount
        length = length + 1
        if i > #inputstr then
            break
        end
    end
    return length
end

function f_MODplayConversation(room, general_name, log, audio_type) --“脑洞包”的剧情对话框，膜拜N神
	if type(audio_type) ~= "string" then audio_type = "dun" end
	room:doAnimate(2, "skill=Conversation:" .. general_name, log)
	local thread = room:getThread()
	thread:delay(295)
	local i = getStringLength(sgs.Sanguosha:translate(log))
	for a = 1, i do
		room:broadcastSkillInvoke(audio_type, "system")
		thread:delay(80)
	end
	thread:delay(1100)
end







--

--载入副本：天使的遗物
do
table.insert(f_MOD_2people, "MOD_AngelsRelics")
table.insert(f_MOD_4people, "MOD_AngelsRelics")
table.insert(f_MOD_6people, "MOD_AngelsRelics")
table.insert(f_MOD_8people, "MOD_AngelsRelics")
table.insert(f_MOD_10people, "MOD_AngelsRelics")
f_dontchangeHero = sgs.General(extension, "f_dontchangeHero", "god", 5, true, true, true) --一个作为选项存在的工具人武将（doge

f_MODon["MOD_AngelsRelics"] = function(player)
	local room = player:getRoom()
	local mode = room:alivePlayerCount()
	room:doLightbox("$MOD_AngelsRelics")
	local log = sgs.LogMessage()
	log.type = "$EnterMOD_AngelsRelics"
	room:sendLog(log)
	for _, p in sgs.qlist(room:getAllPlayers()) do
		room:setPlayerMark(p, "MOD_AngelsRelics", 1)
	end
	--1.重新分配身份
	local mdbt = room:getLord() --主公(BOSS)身份不变
	if not mdbt then --若场上没有主公，1号位成为主公(BOSS)
		for _, p in sgs.qlist(room:getAllPlayers()) do
			p:setRole("lord")
			room:setPlayerProperty(p, "role", sgs.QVariant("lord"))
			room:broadcastProperty(p, "role")
			room:resetAI(p)
			mdbt = p
			break
		end
	end
	if mode == 2 then --room:getMode() == "02p" then --2人场
		for _, p in sgs.qlist(room:getOtherPlayers(mdbt)) do
			p:setRole("rebel")
			room:setPlayerProperty(p, "role", sgs.QVariant("rebel"))
			room:broadcastProperty(p, "role")
			room:resetAI(p)
		end
	elseif mode == 4 then --room:getMode() == "04p" then --4人场
		for _, p in sgs.qlist(room:getOtherPlayers(mdbt)) do
			if p:getSeat() == 4 then
				p:setRole("loyalist")
				room:setPlayerProperty(p, "role", sgs.QVariant("loyalist"))
				room:broadcastProperty(p, "role")
				room:resetAI(p)
			else
				p:setRole("rebel")
				room:setPlayerProperty(p, "role", sgs.QVariant("rebel"))
				room:broadcastProperty(p, "role")
				room:resetAI(p)
			end
		end
	elseif mode == 6 then --room:getMode() == "06p" then --6人场
		for _, p in sgs.qlist(room:getOtherPlayers(mdbt)) do
			if p:getSeat() == 2 or p:getSeat() == 6 then
				p:setRole("loyalist")
				room:setPlayerProperty(p, "role", sgs.QVariant("loyalist"))
				room:broadcastProperty(p, "role")
				room:resetAI(p)
			else
				p:setRole("rebel")
				room:setPlayerProperty(p, "role", sgs.QVariant("rebel"))
				room:broadcastProperty(p, "role")
				room:resetAI(p)
			end
		end
	elseif mode == 8 then --room:getMode() == "08p" then --8人场
		for _, p in sgs.qlist(room:getOtherPlayers(mdbt)) do
			if p:getSeat() == 2 or p:getSeat() == 7 or p:getSeat() == 8 then
				p:setRole("loyalist")
				room:setPlayerProperty(p, "role", sgs.QVariant("loyalist"))
				room:broadcastProperty(p, "role")
				room:resetAI(p)
			else
				p:setRole("rebel")
				room:setPlayerProperty(p, "role", sgs.QVariant("rebel"))
				room:broadcastProperty(p, "role")
				room:resetAI(p)
			end
		end
	elseif mode == 10 then --room:getMode() == "10p" then --10人场
		--[[if mdbt:getSeat() == player:getSeat() then
			room:setPlayerMark(player, "MOD_AngelsRelics_hidden", 1) --用于后续触发里主线剧情
		end]]
		for _, p in sgs.qlist(room:getOtherPlayers(mdbt)) do
			if p:getSeat() == 2 or p:getSeat() == 3 or p:getSeat() == 9 or p:getSeat() == 10 then
				p:setRole("loyalist")
				room:setPlayerProperty(p, "role", sgs.QVariant("loyalist"))
				room:broadcastProperty(p, "role")
				room:resetAI(p)
			else
				p:setRole("rebel")
				room:setPlayerProperty(p, "role", sgs.QVariant("rebel"))
				room:broadcastProperty(p, "role")
				room:resetAI(p)
			end
		end
	end
	--room:updateStateItem()
	--2.难度选择
	local choices = {}
	if player:getRoleEnum() == sgs.Player_Rebel then --人理方
		table.insert(choices, "1")
		table.insert(choices, "3")
		table.insert(choices, "5")
		table.insert(choices, "7")
		table.insert(choices, "9")
		table.insert(choices, "11")
	elseif player:getRoleEnum() == sgs.Player_Lord or player:getRoleEnum() == sgs.Player_Loyalist then --BOSS方
		table.insert(choices, "2")
		table.insert(choices, "4")
		table.insert(choices, "6")
		table.insert(choices, "8")
		table.insert(choices, "10")
		table.insert(choices, "12")
	end
	local choice = room:askForChoice(player, "MOD_AngelsRelics_diffi", table.concat(choices, "+"))
	if choice == "11" or choice == "12" then
		if choice == "11" then room:setPlayerMark(mdbt, "MOD_AngelsRelics_renli", math.random(1,5))
		elseif choice == "12" then room:setPlayerMark(mdbt, "MOD_AngelsRelics_boss", math.random(1,5)) end --判断是选择了哪个难度
	end
	if choice == "1" or mdbt:getMark("MOD_AngelsRelics_renli") == 1 then --人理方，新手教学
		room:setPlayerMark(mdbt, "MOD_AngelsRelics_renli", 1)
		if math.random() <= 0.05 then room:setPlayerMark(mdbt, "MOD_AngelsRelics_dev", 1) end --用于后续触发隐藏事件
	elseif choice == "3" or mdbt:getMark("MOD_AngelsRelics_renli") == 2 then --人理方，简单难度
		room:setPlayerMark(mdbt, "MOD_AngelsRelics_renli", 2)
		if math.random() <= 0.1 then room:setPlayerMark(mdbt, "MOD_AngelsRelics_dev", 1) end
	elseif choice == "5" or mdbt:getMark("MOD_AngelsRelics_renli") == 3 then --人理方，中等难度
		room:setPlayerMark(mdbt, "MOD_AngelsRelics_renli", 3)
		if math.random() <= 0.15 then room:setPlayerMark(mdbt, "MOD_AngelsRelics_dev", 1) end
	elseif choice == "7" or mdbt:getMark("MOD_AngelsRelics_renli") == 4 then --人理方，困难难度
		room:setPlayerMark(mdbt, "MOD_AngelsRelics_renli", 4)
		if math.random() <= 0.2 then room:setPlayerMark(mdbt, "MOD_AngelsRelics_dev", 1) end
	elseif choice == "9" or mdbt:getMark("MOD_AngelsRelics_renli") == 5 then --人理方，超高难度
		room:setPlayerMark(mdbt, "MOD_AngelsRelics_renli", 5)
		if math.random() <= 0.25 then room:setPlayerMark(mdbt, "MOD_AngelsRelics_dev", 1) end
	elseif choice == "2" then --BOSS方，新手教学
		room:setPlayerMark(mdbt, "MOD_AngelsRelics_boss", 1)
	elseif choice == "4" then --BOSS方，简单难度
		room:setPlayerMark(mdbt, "MOD_AngelsRelics_boss", 2)
	elseif choice == "6" then --BOSS方，中等难度
		room:setPlayerMark(mdbt, "MOD_AngelsRelics_boss", 3)
	elseif choice == "8" then --BOSS方，困难难度
		room:setPlayerMark(mdbt, "MOD_AngelsRelics_boss", 4)
	elseif choice == "10" then --BOSS方，超高难度
		room:setPlayerMark(mdbt, "MOD_AngelsRelics_boss", 5)
	end
	--3.武将重置
	  --(0)载入(BOSS方的)武将池
	local MOD_AngelsRelics_c = {"nos_guanyu", "nos_zhangfei", "nos_zhaoyun", "huangzhong", "nos_machao",
	"nos_luxun", "nos_caoren", "weiyan", "nos_zhoutai", "nos_zhangjiao", "gongsunzan", "yujin", "masu",
	"nos_yuji", "sunce", "zhonghui", "mobileren_xujing", "shenguanyu", "sujiang", "sujiangf"} --新手教学(人理方)/超高难度(BOSS方)
	local MOD_AngelsRelics_b = {"yuanshu", "bgm_zhaoyun", "yuanshao", "yin_xuyou", "nos_zhangchunhua", "nos_madai", "nos_caochong", "nos_fuhuanghou",
	"tenyear_guanyu", "machao", "tenyear_sunquan", "tenyear_lvbu", "ol_zhangjiao", "ol_weiyan", "ol_xunyu", "ol_zuoci",
	"mobile_xusheng", "mobile_zhonghui", "mobile_liaohua", "new_mobile_maliang"} --简单难度(人理方)/困难难度(BOSS方)
	local MOD_AngelsRelics_a = {"boss_chi", "boss_mei", "boss_wang", "boss_liang", "shenlvbu1",
	"yangbiao", "tenyear_lingtong", "tenyear_liuzan", "guozhao", "zhangxuan"} --中等难度
	local MOD_AngelsRelics_s = {"boss_niutou", "boss_mamian", "ol_shenguanyu", "shencaocao", "new_shencaocao",
	"shenlvbu", "shenzhaoyun", "shenganning", "shenguanyu_nowuhun", "wolongfengchu"} --困难难度(人理方)/简单难度(BOSS方)
	local MOD_AngelsRelics_ex = {"boss_luocha", "boss_yecha", "boss_heiwuchang", "boss_baiwuchang", "gaodayihao",
	"shenlvbu2", "shenlvbu3", "shenjiangwei", "shenmachao", "shenxunyu"} --超高难度(人理方)/新手教学(BOSS方)
	local luakzPackage = sgs.Sanguosha:getLimitedGeneralNames()
	for _, name in ipairs(luakzPackage) do
		--补充扩展包武将以及20230705版本开始才有的武庙诸葛亮
		if (name == "mou_huangzhong_formal" or name == "mou_liuchengg" or name == "mou_zhangfeii" or name == "mou_machaoo" or name == "mou_lvmengg")
		and not table.contains(MOD_AngelsRelics_b, name) then
			table.insert(MOD_AngelsRelics_b, name)
		end
		if (name == "f_shentaishicii" or name == "zhangzhongjing_first" or name == "os_shenlvmeng" or name == "joy_shenzhangliao" or name == "joy_shendianwei"
		or name == "joy_shenerqiao" or name == "mou_huaxiong_nine" or name == "mou_zhaoyunnEX" or name == "fc_mou_guanyu" or name == "mou_huanggaii"
		or name == "sgkgodlvmeng" or name == "sgkgodzhangliao" or name == "sgkgodluxun" or name == "sgkgodliubei" or name == "sgkgodzhangfei"
		or name == "sgkgodganning" or name == "sgkgoddianwei" or name == "sgkgodxiahoudun" or name == "sgkgodxuchu" or name == "shenyingzheng")
		and not table.contains(MOD_AngelsRelics_a, name) then
			table.insert(MOD_AngelsRelics_a, name)
		end
		if (name == "f_shenguojia" or name == "f_shensunce" or name == "os_shenguanyu" or name == "ty_shenzhangjiao" or name == "ol_shenzhenji"
		or name == "joy_shendiaochan" or name == "f_shenpangtong" or name == "mou_huangzhongg" or name == "fc_mou_huangzhong" or name == "fc_wenyang"
		or name == "sgkgodyueying" or name == "sgkgodzhangjiao" or name == "sgkgodzhaoyun" or name == "sgkgodlvbu" or name == "sgkgodguanyu"
		or name == "sgkgodcaocao" or name == "sgkgodzhuge" or name == "sgkgodzhouyu" or name == "sgkgodjiaxu" or name == "sgkgodsunquan"
		or name == "sgkgodsimahui" or name == "sgkgoddiaochan" or name == "sgkgodsunshangxiang" or name == "sgkgoddaqiao" or name == "sgkgodhuangzhong")
		and not table.contains(MOD_AngelsRelics_s, name) then
			table.insert(MOD_AngelsRelics_s, name)
		end
		if (name == "wumiao_zhugeliang" or name == "f_shenxunyu" --[[or name == "ty_shenjiangweiBN"]] or name == "ty_shenjiangwei" or name == "ty_shenmachao" or name == "ty_shenzhangfei"
		or name == "ol_shencaopi" or name == "joy_shenhuatuo" --[[or name == "f_shenliubeiEX"]] or name == "f_shenzuoci" or name == "TheKingOfUnderworld" or name == "fc_mou_jiangwei"
		or name == "sgkgodsima" or name == "sgkgodspzhuge" or name == "sgkgodsplvbu" or name == "sgkgodspzhangjiao" or name == "sgkgodspzhangliao" or name == "sgkgodspganning"
		--[[or name == "sy_lvbu2" or name == "sy_dongzhuo2" or name == "sy_zhangjiao2" or name == "sy_zhangrang2" or name == "sy_weiyan2" or name == "sy_sunhao2"
		or name == "sy_sunhao3" or name == "sy_caifuren2" or name == "sy_simayi2" or name == "sy_miku2" or name == "sy_simashi2" or name == "sy_xusheng2")]]
		or name == "shensimashi" or name == "mo_sunhao" or name == "mo_simayi" or name == "mo_zhangjiao" or name == "mo_dongzhuo"
		or name == "mo_weiyan" or name == "mo_zhangrang" or name == "mo_caifuren" or name == "mo_lvbu")
		and not table.contains(MOD_AngelsRelics_ex, name) then
			table.insert(MOD_AngelsRelics_ex, name)
		end
	end
	  --(1)主公(BOSS)
	room:changeHero(mdbt, "devilDaybit", false, true, false, false)
	if mdbt:getGeneral2Name() ~= "" then
		local boss_change
		if mdbt:getMark("MOD_AngelsRelics_renli") == 1 or mdbt:getMark("MOD_AngelsRelics_boss") == 5 then
			boss_change = MOD_AngelsRelics_c[math.random(1, #MOD_AngelsRelics_c)]
			table.removeOne(MOD_AngelsRelics_c, boss_change)
		elseif mdbt:getMark("MOD_AngelsRelics_renli") == 2 or mdbt:getMark("MOD_AngelsRelics_boss") == 4 then
			boss_change = MOD_AngelsRelics_b[math.random(1, #MOD_AngelsRelics_b)]
			table.removeOne(MOD_AngelsRelics_b, boss_change)
		elseif mdbt:getMark("MOD_AngelsRelics_renli") == 3 or mdbt:getMark("MOD_AngelsRelics_boss") == 3 then
			boss_change = MOD_AngelsRelics_a[math.random(1, #MOD_AngelsRelics_a)]
			table.removeOne(MOD_AngelsRelics_a, boss_change)
		elseif mdbt:getMark("MOD_AngelsRelics_renli") == 4 or mdbt:getMark("MOD_AngelsRelics_boss") == 2 then
			boss_change = MOD_AngelsRelics_s[math.random(1, #MOD_AngelsRelics_s)]
			table.removeOne(MOD_AngelsRelics_s, boss_change)
		elseif mdbt:getMark("MOD_AngelsRelics_renli") == 5 or mdbt:getMark("MOD_AngelsRelics_boss") == 1 then
			boss_change = MOD_AngelsRelics_ex[math.random(1, #MOD_AngelsRelics_ex)]
			table.removeOne(MOD_AngelsRelics_ex, boss_change)
		end
		room:changeHero(mdbt, boss_change, true, false, true, false)
	end
	room:setPlayerProperty(mdbt, "maxhp", sgs.QVariant(8))
	room:setPlayerProperty(mdbt, "hp", sgs.QVariant(8))
	  --(2)忠臣(BOSS方)
	for _, zc in sgs.qlist(room:getOtherPlayers(mdbt)) do
		if zc:getRoleEnum() ~= sgs.Player_Loyalist then continue end
		local loyal_change1
		if mdbt:getMark("MOD_AngelsRelics_renli") == 1 or mdbt:getMark("MOD_AngelsRelics_boss") == 5 then
			loyal_change1 = MOD_AngelsRelics_c[math.random(1, #MOD_AngelsRelics_c)]
			table.removeOne(MOD_AngelsRelics_c, loyal_change1)
		elseif mdbt:getMark("MOD_AngelsRelics_renli") == 2 or mdbt:getMark("MOD_AngelsRelics_boss") == 4 then
			loyal_change1 = MOD_AngelsRelics_b[math.random(1, #MOD_AngelsRelics_b)]
			table.removeOne(MOD_AngelsRelics_b, loyal_change1)
		elseif mdbt:getMark("MOD_AngelsRelics_renli") == 3 or mdbt:getMark("MOD_AngelsRelics_boss") == 3 then
			loyal_change1 = MOD_AngelsRelics_a[math.random(1, #MOD_AngelsRelics_a)]
			table.removeOne(MOD_AngelsRelics_a, loyal_change1)
		elseif mdbt:getMark("MOD_AngelsRelics_renli") == 4 or mdbt:getMark("MOD_AngelsRelics_boss") == 2 then
			loyal_change1 = MOD_AngelsRelics_s[math.random(1, #MOD_AngelsRelics_s)]
			table.removeOne(MOD_AngelsRelics_s, loyal_change1)
		elseif mdbt:getMark("MOD_AngelsRelics_renli") == 5 or mdbt:getMark("MOD_AngelsRelics_boss") == 1 then
			loyal_change1 = MOD_AngelsRelics_ex[math.random(1, #MOD_AngelsRelics_ex)]
			table.removeOne(MOD_AngelsRelics_ex, loyal_change1)
		end
		room:changeHero(zc, loyal_change1, true, false, false, false)
		if zc:getGeneral2Name() ~= "" then
			local loyal_change2
			if mdbt:getMark("MOD_AngelsRelics_renli") == 1 or mdbt:getMark("MOD_AngelsRelics_boss") == 5 then
				loyal_change2 = MOD_AngelsRelics_c[math.random(1, #MOD_AngelsRelics_c)]
				table.removeOne(MOD_AngelsRelics_c, loyal_change2)
			elseif mdbt:getMark("MOD_AngelsRelics_renli") == 2 or mdbt:getMark("MOD_AngelsRelics_boss") == 4 then
				loyal_change2 = MOD_AngelsRelics_b[math.random(1, #MOD_AngelsRelics_b)]
				table.removeOne(MOD_AngelsRelics_b, loyal_change2)
			elseif mdbt:getMark("MOD_AngelsRelics_renli") == 3 or mdbt:getMark("MOD_AngelsRelics_boss") == 3 then
				loyal_change2 = MOD_AngelsRelics_a[math.random(1, #MOD_AngelsRelics_a)]
				table.removeOne(MOD_AngelsRelics_a, loyal_change2)
			elseif mdbt:getMark("MOD_AngelsRelics_renli") == 4 or mdbt:getMark("MOD_AngelsRelics_boss") == 2 then
				loyal_change2 = MOD_AngelsRelics_s[math.random(1, #MOD_AngelsRelics_s)]
				table.removeOne(MOD_AngelsRelics_s, loyal_change2)
			elseif mdbt:getMark("MOD_AngelsRelics_renli") == 5 or mdbt:getMark("MOD_AngelsRelics_boss") == 1 then
				loyal_change2 = MOD_AngelsRelics_ex[math.random(1, #MOD_AngelsRelics_ex)]
				table.removeOne(MOD_AngelsRelics_ex, loyal_change2)
			end
			room:changeHero(zc, loyal_change2, true, false, true, false)
		end
	end
	  --(3)反贼(人理方)
	for _, rl in sgs.qlist(room:getOtherPlayers(mdbt)) do
		if rl:getRoleEnum() ~= sgs.Player_Rebel then continue end
		local yinglingzuo = sgs.Sanguosha:getLimitedGeneralNames() --并不限制一定不能与BOSS方已选的角色不一样，且不限制人理方一定得选不同的
		table.removeOne(yinglingzuo, "f_dontchangeHero") --布怕一万，纸怕万一
		local rl_general = {}
		for i = 1, 7 do
			local yingling = yinglingzuo[math.random(1, #yinglingzuo)]
			table.insert(rl_general, yingling)
			table.removeOne(yinglingzuo, yingling)
		end
		table.insert(rl_general, "f_dontchangeHero")
		local rl_new_generals = table.concat(rl_general, "+")
		local rl_new_general = room:askForGeneral(rl, rl_new_generals)
		if rl_new_general ~= "f_dontchangeHero" then
			room:changeHero(rl, rl_new_general, true, false, false, false)
		end
		if rl:getGeneral2Name() ~= "" then
			local yinglingzuo2 = sgs.Sanguosha:getLimitedGeneralNames()
			table.removeOne(yinglingzuo2, "f_dontchangeHero")
			local rl_general2 = {}
			for i = 1, 7 do
				local yingling2 = yinglingzuo2[math.random(1, #yinglingzuo2)]
				table.insert(rl_general2, yingling2)
				table.removeOne(yinglingzuo2, yingling2)
			end
			table.insert(rl_general2, "f_dontchangeHero")
			local rl_new_generals2 = table.concat(rl_general2, "+")
			local rl_new_general2 = room:askForGeneral(rl, rl_new_generals2)
			if rl_new_general2 ~= "f_dontchangeHero" then
				room:changeHero(rl, rl_new_general2, true, false, true, false)
			end
		end
	end
	--4.获得阵营技能/效果
	if mode ~= 2 then --room:getMode() ~= "02p" then
		--if player:getRoleEnum() == sgs.Player_Rebel then --人理方
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getRoleEnum() ~= sgs.Player_Rebel then continue end
				if mdbt:getMark("MOD_AngelsRelics_renli") == 1 or mdbt:getMark("MOD_AngelsRelics_boss") == 1 then --人理的守护者 C
					local log = sgs.LogMessage()
					log.type = "$MOD_AngelsRelics_renli_c"
					log.from = p
					room:sendLog(log)
					sgs.Sanguosha:playSystemAudioEffect("godstrengthenMOD/WsrGuardians")
					p:gainHujia(1)
				elseif mdbt:getMark("MOD_AngelsRelics_renli") == 2 or mdbt:getMark("MOD_AngelsRelics_boss") == 2 then --人理的守护者 B
					local log = sgs.LogMessage()
					log.type = "$MOD_AngelsRelics_renli_b"
					log.from = p
					room:sendLog(log)
					sgs.Sanguosha:playSystemAudioEffect("godstrengthenMOD/WsrGuardians")
					p:gainHujia(2)
					room:setPlayerProperty(p, "maxhp", sgs.QVariant(p:getMaxHp()+1))
				elseif mdbt:getMark("MOD_AngelsRelics_renli") == 3 or mdbt:getMark("MOD_AngelsRelics_boss") == 3 then --人理的守护者 A
					local log = sgs.LogMessage()
					log.type = "$MOD_AngelsRelics_renli_a"
					log.from = p
					room:sendLog(log)
					sgs.Sanguosha:playSystemAudioEffect("godstrengthenMOD/WsrGuardians")
					p:gainHujia(3)
					room:setPlayerProperty(p, "maxhp", sgs.QVariant(p:getMaxHp()+2))
					room:setPlayerProperty(p, "hp", sgs.QVariant(p:getHp()+1))
				elseif mdbt:getMark("MOD_AngelsRelics_renli") == 4 or mdbt:getMark("MOD_AngelsRelics_boss") == 4 then --人理的守护者 A+
					local log = sgs.LogMessage()
					log.type = "$MOD_AngelsRelics_renli_s"
					log.from = p
					room:sendLog(log)
					sgs.Sanguosha:playSystemAudioEffect("godstrengthenMOD/WsrGuardians")
					p:gainHujia(3)
					room:setPlayerProperty(p, "maxhp", sgs.QVariant(p:getMaxHp()+3))
					room:setPlayerProperty(p, "hp", sgs.QVariant(p:getHp()+2))
					if mode == 6 or mode == 8 or mode == 10 then
					--if room:getMode() == "06p" or room:getMode() == "08p" or room:getMode() == "10p" then
						local s_choices = {} if p:getState() ~= "robot" then table.insert(s_choices, "cancel") end
						local s = 5
						while s > 0 do
							local yinglingzuos = sgs.Sanguosha:getLimitedGeneralNames()
							local yinglingzuos_skfr = {}
							local yinglings = yinglingzuos[math.random(1, #yinglingzuos)]
							table.insert(yinglingzuos_skfr, yinglings)
							local servants = table.concat(yinglingzuos_skfr, "+")
							local servant = sgs.Sanguosha:getGeneral(room:askForGeneral(p, servants))
							local yinglingzuos_skns = {}
							for _, skill in sgs.qlist(servant:getVisibleSkillList()) do
								table.insert(yinglingzuos_skns, skill:objectName())
							end
							if #yinglingzuos_skns > 0 then
								local one = yinglingzuos_skns[math.random(1, #yinglingzuos_skns)]
								table.insert(s_choices, one)
								s = s - 1
							end
						end
						local s_choice = room:askForChoice(p, "@MOD_AngelsRelics_renli", table.concat(s_choices, "+"))
						if s_choice ~= "cancel" then
							room:acquireSkill(p, s_choice)
						end
					end
				elseif mdbt:getMark("MOD_AngelsRelics_renli") == 5 or mdbt:getMark("MOD_AngelsRelics_boss") == 5 then --人理的守护者 EX
					local log = sgs.LogMessage()
					log.type = "$MOD_AngelsRelics_renli_ex"
					log.from = p
					room:sendLog(log)
					sgs.Sanguosha:playSystemAudioEffect("godstrengthenMOD/WsrGuardians")
					p:gainHujia(3)
					room:setPlayerProperty(p, "maxhp", sgs.QVariant(p:getMaxHp()+3))
					room:setPlayerProperty(p, "hp", sgs.QVariant(p:getHp()+3))
					if mode == 4 then --room:getMode() == "04p" then
						local e_choices = {} if p:getState() ~= "robot" then table.insert(e_choices, "cancel") end
						local e = 6
						while e > 0 do
							local yinglingzuoe = sgs.Sanguosha:getLimitedGeneralNames()
							local yinglingzuoe_skfr = {}
							local yinglinge = yinglingzuoe[math.random(1, #yinglingzuoe)]
							table.insert(yinglingzuoe_skfr, yinglinge)
							local servante = table.concat(yinglingzuoe_skfr, "+")
							local servantt = sgs.Sanguosha:getGeneral(room:askForGeneral(p, servante))
							local yinglingzuoe_skns = {}
							for _, skill in sgs.qlist(servantt:getVisibleSkillList()) do
								table.insert(yinglingzuoe_skns, skill:objectName())
							end
							if #yinglingzuoe_skns > 0 then
								local only = yinglingzuoe_skns[math.random(1, #yinglingzuoe_skns)]
								table.insert(e_choices, only)
								e = e - 1
							end
						end
						local e_choice = room:askForChoice(p, "@MOD_AngelsRelics_renli", table.concat(e_choices, "+"))
						if e_choice ~= "cancel" then
							room:acquireSkill(p, e_choice)
						end
					elseif mode == 6 or mode == 8 or mode == 10 then
					--elseif room:getMode() == "06p" or room:getMode() == "08p" or room:getMode() == "10p" then
						local ex_choices = {} if p:getState() ~= "robot" then table.insert(ex_choices, "cancel") end
						local ex = 7
						while ex > 0 do
							local yinglingzuoex = sgs.Sanguosha:getLimitedGeneralNames()
							local yinglingzuoex_skfr = {}
							local yinglingex = yinglingzuoex[math.random(1, #yinglingzuoex)]
							table.insert(yinglingzuoex_skfr, yinglingex)
							local servantex = table.concat(yinglingzuoex_skfr, "+")
							local servantx = sgs.Sanguosha:getGeneral(room:askForGeneral(p, servantex))
							local yinglingzuoex_skns = {}
							for _, skill in sgs.qlist(servantx:getVisibleSkillList()) do
								table.insert(yinglingzuoex_skns, skill:objectName())
							end
							if #yinglingzuoex_skns > 0 then
								local first = yinglingzuoex_skns[math.random(1, #yinglingzuoex_skns)]
								table.insert(ex_choices, first)
								ex = ex - 1
							end
						end
						while ex < 2 do
							local ex_choice = room:askForChoice(p, "@MOD_AngelsRelics_renli", table.concat(ex_choices, "+"))
							if ex_choice == "cancel" then break end
							room:acquireSkill(p, ex_choice)
							table.removeOne(ex_choices, ex_choice)
							ex = ex + 1
						end
					end
				end
				if mdbt:getMark("MOD_AngelsRelics_renli") == 1 or mdbt:getMark("MOD_AngelsRelics_boss") == 5 then room:drawCards(p, 4)
				elseif mdbt:getMark("MOD_AngelsRelics_renli") == 2 or mdbt:getMark("MOD_AngelsRelics_boss") == 4 then room:drawCards(p, 3)
				elseif mdbt:getMark("MOD_AngelsRelics_renli") == 3 or mdbt:getMark("MOD_AngelsRelics_boss") == 3 then room:drawCards(p, 2)
				elseif mdbt:getMark("MOD_AngelsRelics_renli") == 4 or mdbt:getMark("MOD_AngelsRelics_boss") == 2 then room:drawCards(p, 1) end
			end
		--elseif player:getRoleEnum() == sgs.Player_Lord or player:getRoleEnum() == sgs.Player_Loyalist then --BOSS方
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getRoleEnum() ~= sgs.Player_Lord and p:getRoleEnum() ~= sgs.Player_Loyalist then continue end
				sgs.Sanguosha:playSystemAudioEffect("godstrengthenMOD/XRNSthings")
				if mdbt:getMark("MOD_AngelsRelics_renli") == 1 or mdbt:getMark("MOD_AngelsRelics_boss") == 1 then --夏尔诺斯之物 C
					room:setPlayerMark(p, "@MOD_AngelsRelics_xrns", 11)
					room:acquireSkill(p, "MOD_AngelsRelics_xrns_c")
				elseif mdbt:getMark("MOD_AngelsRelics_renli") == 2 or mdbt:getMark("MOD_AngelsRelics_boss") == 2 then --夏尔诺斯之物 B
					room:setPlayerMark(p, "@MOD_AngelsRelics_xrns", 7)
					room:acquireSkill(p, "MOD_AngelsRelics_xrns_b")
				elseif mdbt:getMark("MOD_AngelsRelics_renli") == 3 or mdbt:getMark("MOD_AngelsRelics_boss") == 3 then --夏尔诺斯之物 A
					room:setPlayerMark(p, "@MOD_AngelsRelics_xrns", 4)
					room:acquireSkill(p, "MOD_AngelsRelics_xrns_a")
				elseif mdbt:getMark("MOD_AngelsRelics_renli") == 4 or mdbt:getMark("MOD_AngelsRelics_boss") == 4 then --夏尔诺斯之物 A+
					room:setPlayerMark(p, "@MOD_AngelsRelics_xrns", 2)
					room:acquireSkill(p, "MOD_AngelsRelics_xrns_s")
				elseif mdbt:getMark("MOD_AngelsRelics_renli") == 5 or mdbt:getMark("MOD_AngelsRelics_boss") == 5 then --夏尔诺斯之物 EX
					room:setPlayerMark(p, "@MOD_AngelsRelics_xrns", 1)
					room:acquireSkill(p, "MOD_AngelsRelics_xrns_ex")
				end
			end
		--end
	end
	--5.隐藏事件：开发组的加护
	local can_invoke = false
	for _, sj in sgs.qlist(room:getAllPlayers()) do --粗略检测是否为双将模式
		if sj:getGeneral2Name() == "" then
			can_invoke = true
		end
	end
	if player:getRoleEnum() ~= sgs.Player_Rebel then --检测玩家是否为人理方
		can_invoke = false
	end
	if can_invoke and player:getMark("MOD_AngelsRelics_dev") > 0 then --触发事件
		--载入所有开发组大神（包括衍生武将“付尼玛”）
		local DEVs = {"dev_cheshen", "dev_hmqgg", "dev_jiaqi", "dev_funima", "dev_tak", "dev_zhangzheng", "dev_tan", "dev_lzx", "dev_fsu", "dev_rara",
		"dev_db", "dev_zy", "dev_jiaoshen", "dev_36li", "dev_para", "dev_yuanjiati", "dev_dudu", "dev_chongmei", "dev_yizhiyongheng", "dev_duguanhe",
		"dev_amira", "dev_mye", "dev_xusine"} --, "dev_luas", "dev_xkj"}
		sgs.Sanguosha:playSystemAudioEffect("godstrengthenMOD/DEVsHelp")
		for _, m in sgs.qlist(room:getOtherPlayers(mdbt)) do
			if m:getRoleEnum() ~= sgs.Player_Rebel then continue end
			local mhp = m:getMaxHp()
			local hp = m:getHp()
			local DEV = DEVs[math.random(1, #DEVs)]
			room:changeHero(m, DEV, true, false, true, true)
			table.removeOne(DEVs, DEV)
			if m:getMaxHp() ~= mhp then room:setPlayerProperty(m, "maxhp", sgs.QVariant(mhp)) end
			if m:getHp() ~= hp then room:setPlayerProperty(m, "hp", sgs.QVariant(hp)) end
		end
	end
	--6.给个启动标记，准备开启剧情
	room:setPlayerMark(player, "MOD_AngelsRelics_start", 1)
end

MOD_AngelsRelics_start = sgs.CreateTriggerSkill{
	name = "MOD_AngelsRelics_start",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.MarkChanged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local mark = data:toMark()
		if mark.name == "MOD_AngelsRelics_start" and mark.gain > 0 and mark.who:objectName() == player:objectName() then
			if room:askForSkillInvoke(player, self:objectName(), ToData("MOD_AngelsRelics_story")) then
				local twlx, dbt = nil, nil --对话的两个人物（“主人公”和魔戴比特）
				if player:getRoleEnum() == sgs.Player_Rebel then --玩家为人理方，则玩家为“主人公”
					twlx = player
				elseif player:getRoleEnum() == sgs.Player_Lord or player:getRoleEnum() == sgs.Player_Loyalist then --玩家为BOSS方，则随机挑选一名人理方角色当“主人公”
					local renlis = {}
					for _, gd in sgs.qlist(room:getOtherPlayers(player)) do
						if gd:getRoleEnum() == sgs.Player_Rebel then
							table.insert(renlis, gd)
						end
					end
					if #renlis > 0 then twlx = renlis[math.random(1, #renlis)] end
				end
				local boss = room:getLord()
				if boss:getGeneralName() == "devilDaybit" then dbt = boss end
				if twlx and dbt then --开始播放剧情
					local gd = twlx:getGeneralName()
					sgs.Sanguosha:playSystemAudioEffect("godstrengthenMOD/MOD_AngelsRelics_story1")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story1")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story2")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story3")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story4")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story5")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story6")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story7")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story8")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story9")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story10")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story11")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story12")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story13")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story14")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story15")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story16")
					room:doLightbox("MOD_AngelsRelics_storyAnimate")
					room:getThread():delay()
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story17")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story18")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story19")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story20")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story21")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story22")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story23")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story24")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story25")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story26")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story27")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story28")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story29")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story30")
					if room:alivePlayerCount() ~= 2 then --room:getMode() ~= "02p" then
						f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story31")
					else
						f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story31ex")
					end
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story32")
					room:getThread():delay()
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story33")
					sgs.Sanguosha:playSystemAudioEffect("godstrengthenMOD/MOD_AngelsRelics_story2")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story34")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story35")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story36")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story37")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story38")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story39")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story40")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story41")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story42")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story43")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story44")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story45")
					sgs.Sanguosha:playSystemAudioEffect("godstrengthenMOD/MOD_AngelsRelics_story3")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story46")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story47")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story48")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story49")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story50")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story51")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story52")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story53")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story54")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story55")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story56")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story57")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story58")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story59")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story60")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story61")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story62")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story63")
					if math.random() > 0.23 then
						f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story64")
					else
						f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story64cd")
					end
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story65")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story66")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story67")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story68")
					f_MODplayConversation(room, "devilDaybit", "#MOD_AngelsRelics_story69")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story70")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story71")
					f_MODplayConversation(room, gd, "#MOD_AngelsRelics_story72")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("MOD_AngelsRelics_start") then skills:append(MOD_AngelsRelics_start) end

--

--夏尔诺斯之物
MOD_AngelsRelics_xrnsLoss = sgs.CreateTriggerSkill{
	name = "MOD_AngelsRelics_xrnsLoss",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.RoundStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getMark(self:objectName()) == 0 then
			room:addPlayerMark(player, self:objectName())
		else
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("@MOD_AngelsRelics_xrns") == 0 then continue end
				room:removePlayerMark(p, "@MOD_AngelsRelics_xrns")
				if p:getMark("@MOD_AngelsRelics_xrns") == 0 then
					sgs.Sanguosha:playSystemAudioEffect("godstrengthenMOD/XRNSdown") --失去抛瓦
					if p:hasSkill("MOD_AngelsRelics_xrns_c") then room:detachSkillFromPlayer(p, "MOD_AngelsRelics_xrns_c", false, true) end
					if p:hasSkill("MOD_AngelsRelics_xrns_b") then room:detachSkillFromPlayer(p, "MOD_AngelsRelics_xrns_b", false, true) end
					if p:hasSkill("MOD_AngelsRelics_xrns_a") then room:detachSkillFromPlayer(p, "MOD_AngelsRelics_xrns_a", false, true) end
					if p:hasSkill("MOD_AngelsRelics_xrns_s") then room:detachSkillFromPlayer(p, "MOD_AngelsRelics_xrns_s", false, true) end
					if p:hasSkill("MOD_AngelsRelics_xrns_ex") then room:detachSkillFromPlayer(p, "MOD_AngelsRelics_xrns_ex", false, true) end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getSeat() == 1
	end,
}
if not sgs.Sanguosha:getSkill("MOD_AngelsRelics_xrnsLoss") then skills:append(MOD_AngelsRelics_xrnsLoss) end

--五档技能（是的，你没看错，全是空壳）
MOD_AngelsRelics_xrns_c = sgs.CreateTriggerSkill{
	name = "MOD_AngelsRelics_xrns_c&",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end,
}
MOD_AngelsRelics_xrns_b = sgs.CreateTriggerSkill{
	name = "MOD_AngelsRelics_xrns_b&",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end,
}
MOD_AngelsRelics_xrns_a = sgs.CreateTriggerSkill{
	name = "MOD_AngelsRelics_xrns_a&",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end,
}
MOD_AngelsRelics_xrns_s = sgs.CreateTriggerSkill{
	name = "MOD_AngelsRelics_xrns_s&",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end,
}
MOD_AngelsRelics_xrns_ex = sgs.CreateTriggerSkill{
	name = "MOD_AngelsRelics_xrns_ex&",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()
	end,
}
if not sgs.Sanguosha:getSkill("MOD_AngelsRelics_xrns_c") then skills:append(MOD_AngelsRelics_xrns_c) end
if not sgs.Sanguosha:getSkill("MOD_AngelsRelics_xrns_b") then skills:append(MOD_AngelsRelics_xrns_b) end
if not sgs.Sanguosha:getSkill("MOD_AngelsRelics_xrns_a") then skills:append(MOD_AngelsRelics_xrns_a) end
if not sgs.Sanguosha:getSkill("MOD_AngelsRelics_xrns_s") then skills:append(MOD_AngelsRelics_xrns_s) end
if not sgs.Sanguosha:getSkill("MOD_AngelsRelics_xrns_ex") then skills:append(MOD_AngelsRelics_xrns_ex) end

MOD_AngelsRelics_xrnsBuff_c = sgs.CreateMaxCardsSkill{ --手牌上限+1
	name = "MOD_AngelsRelics_xrnsBuff_c",
	extra_func = function(self, player)
		if (player:hasSkill("MOD_AngelsRelics_xrns_c") or player:hasSkill("MOD_AngelsRelics_xrns_b") or player:hasSkill("MOD_AngelsRelics_xrns_a")
		or player:hasSkill("MOD_AngelsRelics_xrns_s") or player:hasSkill("MOD_AngelsRelics_xrns_ex")) and player:getMark("@MOD_AngelsRelics_xrns") > 0 then
			return 1
		else
			return 0
		end
	end,
}
MOD_AngelsRelics_xrnsBuff_b = sgs.CreateTriggerSkill{ --摸牌阶段摸牌数+1
	name = "MOD_AngelsRelics_xrnsBuff_b",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:sendCompulsoryTriggerLog(player, "MOD_AngelsRelics_xrns")
		local count = data:toInt() + 1
		data:setValue(count)
	end,
	can_trigger = function(self, player)
		return (player:hasSkill("MOD_AngelsRelics_xrns_b") or player:hasSkill("MOD_AngelsRelics_xrns_a") or player:hasSkill("MOD_AngelsRelics_xrns_s")
		or player:hasSkill("MOD_AngelsRelics_xrns_ex")) and player:getMark("@MOD_AngelsRelics_xrns") > 0
	end,
}
MOD_AngelsRelics_xrnsBuff_a = sgs.CreateTargetModSkill{ --使用牌的距离与次数上限+1
    name = "MOD_AngelsRelics_xrnsBuff_a",
	pattern = "Card",
	distance_limit_func = function(self, player, card)
	    if (player:hasSkill("MOD_AngelsRelics_xrns_a") or player:hasSkill("MOD_AngelsRelics_xrns_s") or player:hasSkill("MOD_AngelsRelics_xrns_ex"))
		and player:getMark("@MOD_AngelsRelics_xrns") > 0 and not card:isKindOf("SkillCard") then --防火防盗防技能卡
			return 1
		else
			return 0
		end
	end,
	residue_func = function(self, player, card)
		if (player:hasSkill("MOD_AngelsRelics_xrns_a") or player:hasSkill("MOD_AngelsRelics_xrns_s") or player:hasSkill("MOD_AngelsRelics_xrns_ex"))
		and player:getMark("@MOD_AngelsRelics_xrns") > 0 and not card:isKindOf("SkillCard") then
			return 1
		else
			return 0
		end
	end,
}
MOD_AngelsRelics_xrnsBuff_s = sgs.CreateTriggerSkill{ --伤害量与回复量+1
	name = "MOD_AngelsRelics_xrnsBuff_s",
	global = true,
	events = {sgs.ConfirmDamage, sgs.PreHpRecover},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.card and not damage.card:isKindOf("SkillCard") then
				local log = sgs.LogMessage()
				log.type = "$MOD_AngelsRelics_xrnsBuff_s_dmg"
				log.from = player
				log.card_str = damage.card:toString()
				room:sendLog(log)
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		elseif event == sgs.PreHpRecover then
			local rec = data:toRecover()
			if rec.card and not rec.card:isKindOf("SkillCard") then
				local log = sgs.LogMessage()
				log.type = "$MOD_AngelsRelics_xrnsBuff_s_rec"
				log.from = player
				log.card_str = rec.card:toString()
				room:sendLog(log)
				rec.recover = rec.recover + 1
				data:setValue(rec)
			end
		end
	end,
	can_trigger = function(self, player)
		return (player:hasSkill("MOD_AngelsRelics_xrns_s") or player:hasSkill("MOD_AngelsRelics_xrns_ex"))
		and player:getMark("@MOD_AngelsRelics_xrns") > 0
	end,
}
MOD_AngelsRelics_xrnsBuff_ex = sgs.CreateTriggerSkill{ --每造成或受到一次伤害，摸一张牌
	name = "MOD_AngelsRelics_xrnsBuff_ex",
	global = true,
	events = {sgs.Damage, sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		room:sendCompulsoryTriggerLog(player, "MOD_AngelsRelics_xrns")
		room:drawCards(player, 1, "MOD_AngelsRelics_xrns_ex")
	end,
	can_trigger = function(self, player)
		return player:hasSkill("MOD_AngelsRelics_xrns_ex")
		and player:getMark("@MOD_AngelsRelics_xrns") > 0
	end,
}
if not sgs.Sanguosha:getSkill("MOD_AngelsRelics_xrnsBuff_c") then skills:append(MOD_AngelsRelics_xrnsBuff_c) end
if not sgs.Sanguosha:getSkill("MOD_AngelsRelics_xrnsBuff_b") then skills:append(MOD_AngelsRelics_xrnsBuff_b) end
if not sgs.Sanguosha:getSkill("MOD_AngelsRelics_xrnsBuff_a") then skills:append(MOD_AngelsRelics_xrnsBuff_a) end
if not sgs.Sanguosha:getSkill("MOD_AngelsRelics_xrnsBuff_s") then skills:append(MOD_AngelsRelics_xrnsBuff_s) end
if not sgs.Sanguosha:getSkill("MOD_AngelsRelics_xrnsBuff_ex") then skills:append(MOD_AngelsRelics_xrnsBuff_ex) end

--BOSS为电脑，于第一个回合开始时自动给BOSS方上标记
MOD_AngelsRelics_givebuffs = sgs.CreateTriggerSkill{
	name = "MOD_AngelsRelics_givebuffs",
	global = true,
	priority = 6,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_RoundStart then
			room:addPlayerMark(player, self:objectName())
			room:broadcastSkillInvoke("voidtongxin", 2)
			for _, ts in sgs.qlist(room:getOtherPlayers(player)) do
				if ts:getRoleEnum() ~= sgs.Player_Loyalist then continue end
				player:loseMark("&AngelsRelics", 1)
				ts:gainMark("&AngelsRelics", 1)
				if player:getMark("&AngelsRelics") == 0 then break end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:isLord() and player:getGeneralName() == "devilDaybit" and player:getMark("MOD_AngelsRelics") > 0
		and player:getState() == "robot" and player:getMark(self:objectName()) == 0
	end,
}
if not sgs.Sanguosha:getSkill("MOD_AngelsRelics_givebuffs") then skills:append(MOD_AngelsRelics_givebuffs) end

--奖惩机制
MOD_AngelsRelics_bury = sgs.CreateTriggerSkill{
	name = "MOD_AngelsRelics_bury",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		local can_invoke = false
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:getMark("MOD_AngelsRelics") > 0 then
				can_invoke = true
			end
		end
		if can_invoke and death.who and death.who:objectName() == player:objectName() then
			if player:getRoleEnum() == sgs.Player_Loyalist and death.damage.from then
				room:drawCards(death.damage.from, 2, self:objectName())
				if death.damage.from:isWounded() then
					room:recover(death.damage.from, sgs.RecoverStruct(death.damage.from))
				else
					death.damage.from:gainHujia(1)
				end
			elseif player:getRoleEnum() == sgs.Player_Rebel then
				local mdbt = room:getLord()
				local r, b = mdbt:getMark("MOD_AngelsRelics_renli"), mdbt:getMark("MOD_AngelsRelics_boss")
				for _, q in sgs.qlist(room:getAlivePlayers()) do
					if q:getRoleEnum() ~= sgs.Player_Rebel then continue end
					if r == 1 or b == 5 then
						room:drawCards(q, 5, self:objectName())
					elseif r == 2 or b == 4 then
						room:drawCards(q, 4, self:objectName())
					elseif r == 3 or b == 3 then
						room:drawCards(q, 3, self:objectName())
					elseif r == 4 or b == 2 then
						room:drawCards(q, 2, self:objectName())
					elseif r == 5 or b == 1 then
						room:drawCards(q, 1, self:objectName())
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("MOD_AngelsRelics_bury") then skills:append(MOD_AngelsRelics_bury) end
end

--里主线剧情（待实装......）










--=============================================================================================================================================--

--戴比特&基尔什塔利亚
Daybit_Kirschtaria = sgs.General(extension, "Daybit_Kirschtaria", "qun", 7, true, false, false, 5)
Daybit_Kirschtaria_tcz = sgs.General(extension, "Daybit_Kirschtaria_tcz", "qun", 7, true, true, true, 5)

dk_guanceCard = sgs.CreateSkillCard{ --星夜
    name = "dk_guanceCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, player, targets)
	    local x, y = 7 + player:getMark("dk_guance_xyx"), 2 + player:getMark("dk_guance_xyy")
		local card_ids = room:getNCards(x, false)
		room:fillAG(card_ids, player)
		local to_get = sgs.IntList()
		local gcz = 0
		while y > 0 do
			local card_id = room:askForAG(player, card_ids, false, "dk_guance")
			card_ids:removeOne(card_id)
			to_get:append(card_id)
			local num = sgs.Sanguosha:getCard(card_id):getNumber()
			gcz = gcz + num
			room:takeAG(player, card_id, false)
			y = y - 1
		end
		local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		if not to_get:isEmpty() then
			for _, id in sgs.qlist(to_get) do
				dummy:addSubcard(id)
			end
			room:obtainCard(player, dummy, false)
			room:addPlayerMark(player, "&dk_guancezhi", gcz)
		end
		dummy:deleteLater()
		room:clearAG()
		if not card_ids:isEmpty() then
			room:askForGuanxing(player, card_ids)
		end
		--获取此时“观测值”的个位数
		local z = player:getMark("&dk_guancezhi")
		if z == 10000 then z = 0 end --不会吧，不会真的有人观测到1w吧（害怕
		--观测值上千(上限:9999)-->处理成千以下的数字
		if z >= 1000 and z < 2000 then z = z - 1000
		elseif z >= 2000 and z < 3000 then z = z - 2000
		elseif z >= 3000 and z < 4000 then z = z - 3000
		elseif z >= 4000 and z < 5000 then z = z - 4000
		elseif z >= 5000 and z < 6000 then z = z - 5000
		elseif z >= 6000 and z < 7000 then z = z - 6000
		elseif z >= 7000 and z < 8000 then z = z - 7000
		elseif z >= 8000 and z < 9000 then z = z - 8000
		elseif z >= 9000 and z < 10000 then z = z - 9000
		end
		--观测值上百-->处理成百以下的数字
		if z >= 100 and z < 200 then z = z - 100
		elseif z >= 200 and z < 300 then z = z - 200
		elseif z >= 300 and z < 400 then z = z - 300
		elseif z >= 400 and z < 500 then z = z - 400
		elseif z >= 500 and z < 600 then z = z - 500
		elseif z >= 600 and z < 700 then z = z - 600
		elseif z >= 700 and z < 800 then z = z - 700
		elseif z >= 800 and z < 900 then z = z - 800
		elseif z >= 900 and z < 1000 then z = z - 900
		end
		--再提取出个位
		if z >= 10 and z < 20 then z = z - 10
		elseif z >= 20 and z < 30 then z = z - 20
		elseif z >= 30 and z < 40 then z = z - 30
		elseif z >= 40 and z < 50 then z = z - 40
		elseif z >= 50 and z < 60 then z = z - 50
		elseif z >= 60 and z < 70 then z = z - 60
		elseif z >= 70 and z < 80 then z = z - 70
		elseif z >= 80 and z < 90 then z = z - 80
		elseif z >= 90 and z < 100 then z = z - 90
		end
		-----
		if z == 7 then
			if not player:isKongcheng() then
				room:askForUseCard(player, "@@dk_guance_xy!", "@dk_guance_xy-show")
			end
			local choices = {"3", "4", "cancel"}
			if player:getMark("dk_guance_xyy") >= 7 then table.removeOne(choices, "4") end
			local choice = room:askForChoice(player, "dk_guance", table.concat(choices, "+"))
			if choice == "3" then
				room:addPlayerMark(player, "dk_guance_xyx")
			elseif choice == "4" then
				room:addPlayerMark(player, "dk_guance_xyy")
			end
			room:setPlayerMark(player, "&dk_guancezhi", 0)
			room:setChangeSkillState(player, "dk_guance", 1)
			local mhp = player:getMaxHp()
			local hp = player:getHp()
			if player:getGeneralName() == "Daybit_Kirschtaria_tcz" then
				room:changeHero(player, "Daybit_Kirschtaria", false, false, false, false)
			elseif player:getGeneral2Name() == "Daybit_Kirschtaria_tcz" then
				room:changeHero(player, "Daybit_Kirschtaria", false, false, true, false)
			end
			if player:getMaxHp() ~= mhp then room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp)) end
			if player:getHp() ~= hp then room:setPlayerProperty(player, "hp", sgs.QVariant(hp)) end
		end
	end,
}
dk_guanceVS = sgs.CreateViewAsSkill{
    name = "dk_guance",
	n = 2,
	view_filter = function(self, selected, to_select)
	    return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
	    if #cards ~= 2 then return nil end
		local card = dk_guanceCard:clone()
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end,
	enabled_at_play = function(self, player)
		return player:getChangeSkillState("dk_guance") == 2 and not player:isKongcheng() and not player:hasUsed("#dk_guanceCard")
	end,
}
dk_guance = sgs.CreateTriggerSkill{ --极光
    name = "dk_guance",
	change_skill = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards},
	view_as_skill = dk_guanceVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getChangeSkillState("dk_guance") == 1 then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				data:setValue(-1000)
				local x, y = 7 + player:getMark("dk_guance_jgx"), 2 + player:getMark("dk_guance_jgy")
				local card_ids = room:getNCards(x, false)
				room:fillAG(card_ids, player)
				local to_get = sgs.IntList()
				local gcz = 0
				while y > 0 do
					local card_id = room:askForAG(player, card_ids, false, self:objectName())
					card_ids:removeOne(card_id)
					to_get:append(card_id)
					local num = sgs.Sanguosha:getCard(card_id):getNumber()
					gcz = gcz + num
					room:takeAG(player, card_id, false)
					y = y - 1
				end
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				if not to_get:isEmpty() then
					for _, id in sgs.qlist(to_get) do
						dummy:addSubcard(id)
					end
					room:obtainCard(player, dummy, false)
					room:addPlayerMark(player, "&dk_guancezhi", gcz)
				end
				dummy:deleteLater()
				room:clearAG()
				if not card_ids:isEmpty() then
					room:askForGuanxing(player, card_ids)
				end
				--获取此时“观测值”的个位数
				local z = player:getMark("&dk_guancezhi")
				if z == 10000 then z = 0 end --不会吧，不会真的有人观测到1w吧（害怕
				--观测值上千(上限:9999)-->处理成千以下的数字
				if z >= 1000 and z < 2000 then z = z - 1000
				elseif z >= 2000 and z < 3000 then z = z - 2000
				elseif z >= 3000 and z < 4000 then z = z - 3000
				elseif z >= 4000 and z < 5000 then z = z - 4000
				elseif z >= 5000 and z < 6000 then z = z - 5000
				elseif z >= 6000 and z < 7000 then z = z - 6000
				elseif z >= 7000 and z < 8000 then z = z - 7000
				elseif z >= 8000 and z < 9000 then z = z - 8000
				elseif z >= 9000 and z < 10000 then z = z - 9000
				end
				--观测值上百-->处理成百以下的数字
				if z >= 100 and z < 200 then z = z - 100
				elseif z >= 200 and z < 300 then z = z - 200
				elseif z >= 300 and z < 400 then z = z - 300
				elseif z >= 400 and z < 500 then z = z - 400
				elseif z >= 500 and z < 600 then z = z - 500
				elseif z >= 600 and z < 700 then z = z - 600
				elseif z >= 700 and z < 800 then z = z - 700
				elseif z >= 800 and z < 900 then z = z - 800
				elseif z >= 900 and z < 1000 then z = z - 900
				end
				--再提取出个位
				if z >= 10 and z < 20 then z = z - 10
				elseif z >= 20 and z < 30 then z = z - 20
				elseif z >= 30 and z < 40 then z = z - 30
				elseif z >= 40 and z < 50 then z = z - 40
				elseif z >= 50 and z < 60 then z = z - 50
				elseif z >= 60 and z < 70 then z = z - 60
				elseif z >= 70 and z < 80 then z = z - 70
				elseif z >= 80 and z < 90 then z = z - 80
				elseif z >= 90 and z < 100 then z = z - 90
				end
				-----
				if z == 5 then
					room:drawCards(player, 2, self:objectName())
					if player:isWounded() then
						room:recover(player, sgs.RecoverStruct(player))
					end
					local choices = {"1", "2", "cancel"}
					if player:getMark("dk_guance_jgy") >= 7 then table.removeOne(choices, "2") end
					local choice = room:askForChoice(player, "dk_guance", table.concat(choices, "+"))
					if choice == "1" then
						room:addPlayerMark(player, "dk_guance_jgx")
					elseif choice == "2" then
						room:addPlayerMark(player, "dk_guance_jgy")
					end
					room:setPlayerMark(player, "&dk_guancezhi", 0)
					room:setChangeSkillState(player, self:objectName(), 2)
					local mhp = player:getMaxHp()
					local hp = player:getHp()
					if player:getGeneralName() == "Daybit_Kirschtaria" then
						room:changeHero(player, "Daybit_Kirschtaria_tcz", false, false, false, false)
					elseif player:getGeneral2Name() == "Daybit_Kirschtaria" then
						room:changeHero(player, "Daybit_Kirschtaria_tcz", false, false, true, false)
					end
					if player:getMaxHp() ~= mhp then room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp)) end
					if player:getHp() ~= hp then room:setPlayerProperty(player, "hp", sgs.QVariant(hp)) end
				end
			end
		end
	end,
}
Daybit_Kirschtaria:addSkill(dk_guance)
Daybit_Kirschtaria_tcz:addSkill("dk_guance")
--“星夜”技能卡及加成效果
  --展示
dk_guance_xyCard = sgs.CreateSkillCard{
    name = "dk_guance_xyCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
        for _, id in sgs.qlist(self:getSubcards()) do
            room:showCard(source, id)
			local name = sgs.Sanguosha:getCard(id):objectName()
			if name ~= "jink" and name ~= "nullification" and name ~= "jl_wuxiesy" then
				room:setPlayerProperty(source, "dk_guance_xy", sgs.QVariant(name))
				if name == "analeptic" and not source:hasFlag("dk_guance_xyu_anaNoLimit") then
					room:setPlayerFlag(source, "dk_guance_xyu_anaNoLimit") --专门处理【酒】的不计次
				end
				room:askForUseCard(source, "@@dk_guance_xyu", "@dk_guance_xyu-touse:" .. name)
				room:setPlayerProperty(source, "dk_guance_xy", sgs.QVariant(false))
			end
        end
	end,
}
dk_guance_xy = sgs.CreateViewAsSkill{
	name = "dk_guance_xy",
	n = 1,
	view_filter = function(self, selected, to_select)
		return (to_select:isKindOf("BasicCard") or to_select:isNDTrick()) and not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local xyCard = dk_guance_xyCard:clone()
			xyCard:addSubcard(cards[1])
			return xyCard
		end
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@dk_guance_xy")
	end,
}
  --使用
dk_guance_xyu = sgs.CreateZeroCardViewAsSkill{
	name = "dk_guance_xyu",
	view_as = function(self, card)
		local pattern = sgs.Self:property("dk_guance_xy"):toString()
		local cd = sgs.Sanguosha:cloneCard(pattern, sgs.Card_NoSuit, 0)
		cd:setSkillName(self:objectName())
		return cd
	end,
	response_pattern = "@@dk_guance_xyu",
}
  --加成
dk_guance_xyu_useNoLimit = sgs.CreateTargetModSkill{
	name = "dk_guance_xyu_useNoLimit",
	pattern = "Card",
	distance_limit_func = function(self, player, card)
		if card and card:getSkillName() == "dk_guance_xyu" then
		    return 1000
		else
		    return 0
		end
	end,
	residue_func = function(self, player, card)
		if player:hasFlag("dk_guance_xyu_anaNoLimit") and card and card:isKindOf("Analeptic") then
		    return 1000
		else
		    return 0
		end
	end,
}
dk_guance_xyu_useNoLimitt = sgs.CreateTriggerSkill{
	name = "dk_guance_xyu_useNoLimitt",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.CardUsed then
			if use.from and use.from:objectName() == player:objectName() and use.card and use.card:getSkillName() == "dk_guance_xyu"
			and use.m_addHistory then
				room:addPlayerHistory(player, use.card:getClassName(), -1)
			end
		elseif event == sgs.CardFinished then
			if use.from and use.from:objectName() == player:objectName() and player:hasFlag("dk_guance_xyu_anaNoLimit")
			and use.card and use.card:isKindOf("Analeptic") and use.card:getSkillName() ~= "dk_guance_xyu" then --不是通过“观测”视为使用的【酒】
				room:setPlayerFlag(player, "-dk_guance_xyu_anaNoLimit")
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("dk_guance_xy") then skills:append(dk_guance_xy) end
if not sgs.Sanguosha:getSkill("dk_guance_xyu") then skills:append(dk_guance_xyu) end
if not sgs.Sanguosha:getSkill("dk_guance_xyu_useNoLimit") then skills:append(dk_guance_xyu_useNoLimit) end
if not sgs.Sanguosha:getSkill("dk_guance_xyu_useNoLimitt") then skills:append(dk_guance_xyu_useNoLimitt) end

--==【环境<|改造|>包】==--
do
table.insert(f_MOD_all, "MOD_EnvironmentRedevelop")

f_MODon["MOD_EnvironmentRedevelop"] = function(player)
	local room = player:getRoom()
	local choices = {"MOD_EnvironmentRedevelop_s1",
	"MOD_EnvironmentRedevelop_END"}
	while true do
		local choice = room:askForChoice(player, "MOD_EnvironmentRedevelop", table.concat(choices, "+"))
		if choice == "MOD_EnvironmentRedevelop_END" then break end
		if choice == "MOD_EnvironmentRedevelop_s1" then
			local choices1 = {"MOD_EnvironmentRedevelop_END", "MOD_EnvironmentRedevelop_Return",
			"1", "2", "3", "4", "5", "6", "7", "8", "9"}
			if not player:hasFlag("MOD_EnvironmentRedevelop_s1_remove10") then
				table.insert(choices1, "10")
			end
			if not player:hasFlag("MOD_EnvironmentRedevelop_s1_remove11") then
				table.insert(choices1, "11")
			end
			if not player:hasFlag("MOD_EnvironmentRedevelop_s1_remove12") then
				table.insert(choices1, "12")
			end
			if player:hasFlag("MOD_EnvironmentRedevelop_forME") then
				table.insert(choices1, "MOD_EnvironmentRedevelop_forALL")
			else
				table.insert(choices1, "MOD_EnvironmentRedevelop_forME")
			end
			while true do
				local choice1 = room:askForChoice(player, "MOD_EnvironmentRedevelop_s1", table.concat(choices1, "+"))
				if choice1 == "MOD_EnvironmentRedevelop_END" then
					room:setPlayerFlag("MOD_EnvironmentRedevelop_END")
				break end
				if choice1 == "MOD_EnvironmentRedevelop_Return" then break end
				if choice1 == "MOD_EnvironmentRedevelop_forME" then
					room:setPlayerFlag(player, "MOD_EnvironmentRedevelop_forME")
					table.removeOne(choices1, "MOD_EnvironmentRedevelop_forME")
					table.insert(choices1, "MOD_EnvironmentRedevelop_forALL")
				elseif choice1 == "MOD_EnvironmentRedevelop_forALL" then
					room:setPlayerFlag(player, "-MOD_EnvironmentRedevelop_forME")
					table.removeOne(choices1, "MOD_EnvironmentRedevelop_forALL")
					table.insert(choices1, "MOD_EnvironmentRedevelop_forME")
				end
				if choice1 == "1" then
					room:addPlayerMark(player, "ER_jiadi")
					local log = sgs.LogMessage()
					log.type = "#ER_jiadi2"
					log.from = player
					if not player:hasFlag("MOD_EnvironmentRedevelop_forME") then
						log.type = "#ER_jiadi1"
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							room:addPlayerMark(p, "ER_jiadi")
						end
					end
					room:sendLog(log)
				elseif choice1 == "2" then
					room:addPlayerMark(player, "ER_tunliang")
					local log = sgs.LogMessage()
					log.type = "#ER_tunliang2"
					log.from = player
					if not player:hasFlag("MOD_EnvironmentRedevelop_forME") then
						log.type = "#ER_tunliang1"
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							room:addPlayerMark(p, "ER_tunliang")
						end
					end
					room:sendLog(log)
				elseif choice1 == "3" then
					room:addPlayerMark(player, "ER_yingzi")
					local log = sgs.LogMessage()
					log.type = "#ER_yingzi2"
					log.from = player
					if not player:hasFlag("MOD_EnvironmentRedevelop_forME") then
						log.type = "#ER_yingzi1"
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							room:addPlayerMark(p, "ER_yingzi")
						end
					end
					room:sendLog(log)
				elseif choice1 == "4" then
					room:addPlayerMark(player, "ER_shuangdao")
					local log = sgs.LogMessage()
					log.type = "#ER_shuangdao2"
					log.from = player
					if not player:hasFlag("MOD_EnvironmentRedevelop_forME") then
						log.type = "#ER_shuangdao1"
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							room:addPlayerMark(p, "ER_shuangdao")
						end
					end
					room:sendLog(log)
				elseif choice1 == "5" then
					room:addPlayerMark(player, "ER_shouchang")
					local log = sgs.LogMessage()
					log.type = "#ER_shouchang2"
					log.from = player
					if not player:hasFlag("MOD_EnvironmentRedevelop_forME") then
						log.type = "#ER_shouchang1"
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							room:addPlayerMark(p, "ER_shouchang")
						end
					end
					room:sendLog(log)
				elseif choice1 == "6" then
					room:addPlayerMark(player, "ER_bingfen")
					local log = sgs.LogMessage()
					log.type = "#ER_bingfen2"
					log.from = player
					if not player:hasFlag("MOD_EnvironmentRedevelop_forME") then
						log.type = "#ER_bingfen1"
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							room:addPlayerMark(p, "ER_bingfen")
						end
					end
					room:sendLog(log)
				elseif choice1 == "7" then
					room:addPlayerMark(player, "ER_zhongzhuang")
					local log = sgs.LogMessage()
					log.type = "#ER_zhongzhuang2"
					log.from = player
					if not player:hasFlag("MOD_EnvironmentRedevelop_forME") then
						log.type = "#ER_zhongzhuang1"
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							room:addPlayerMark(p, "ER_zhongzhuang")
						end
					end
					room:sendLog(log)
				elseif choice1 == "8" then
					room:addPlayerMark(player, "ER_yishu")
					local log = sgs.LogMessage()
					log.type = "#ER_yishu2"
					log.from = player
					if not player:hasFlag("MOD_EnvironmentRedevelop_forME") then
						log.type = "#ER_yishu1"
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							room:addPlayerMark(p, "ER_yishu")
						end
					end
					room:sendLog(log)
				elseif choice1 == "9" then
					room:addPlayerMark(player, "ER_shijiu")
					local log = sgs.LogMessage()
					log.type = "#ER_shijiu2"
					log.from = player
					if not player:hasFlag("MOD_EnvironmentRedevelop_forME") then
						log.type = "#ER_shijiu1"
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							room:addPlayerMark(p, "ER_shijiu")
						end
					end
					room:sendLog(log)
				elseif choice1 == "10" then
					room:addPlayerMark(player, "ER_weizhen")
					local log = sgs.LogMessage()
					log.type = "#ER_weizhen2"
					log.from = player
					if not player:hasFlag("MOD_EnvironmentRedevelop_forME") then
						log.type = "#ER_weizhen1"
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							room:addPlayerMark(p, "ER_weizhen")
						end
					end
					room:sendLog(log)
					room:setPlayerFlag(player, "MOD_EnvironmentRedevelop_s1_remove10")
					table.removeOne(choices1, "10")
				elseif choice1 == "11" then
					room:addPlayerMark(player, "ER_dujie")
					local log = sgs.LogMessage()
					log.type = "#ER_dujie2"
					log.from = player
					if not player:hasFlag("MOD_EnvironmentRedevelop_forME") then
						log.type = "#ER_dujie1"
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							room:addPlayerMark(p, "ER_dujie")
						end
					end
					room:sendLog(log)
					room:setPlayerFlag(player, "MOD_EnvironmentRedevelop_s1_remove11")
					table.removeOne(choices1, "11")
				elseif choice1 == "12" then
					room:addPlayerMark(player, "ER_guoqing")
					if not player:hasFlag("MOD_EnvironmentRedevelop_forME") then
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							room:addPlayerMark(p, "ER_guoqing")
						end
					end
					room:setPlayerFlag(player, "MOD_EnvironmentRedevelop_s1_remove12")
					table.removeOne(choices1, "12")
				end
			end
			if player:hasFlag("MOD_EnvironmentRedevelop_END") then
				room:setPlayerFlag(player, "-MOD_EnvironmentRedevelop_END")
			break end
		end
	end
end
--==第一季==--
--家底
ER_jiadi = sgs.CreateTriggerSkill{
	name = "ER_jiadi",
	global = true,
	priority = -1,
	events = {sgs.DrawInitialCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local n = player:getMark(self:objectName())
		data:setValue(data:toInt() + n)
	end,
	can_trigger = function(self, player)
		return player:getMark(self:objectName()) > 0
	end,
}
if not sgs.Sanguosha:getSkill("ER_jiadi") then skills:append(ER_jiadi) end
--囤粮
ER_tunliang = sgs.CreateMaxCardsSkill{
	name = "ER_tunliang",
	extra_func = function(self, player)
		if player:getMark(self:objectName()) > 0 then
			local n = player:getMark(self:objectName())
			return n
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("ER_tunliang") then skills:append(ER_tunliang) end
--英姿
ER_yingzi = sgs.CreateTriggerSkill{
	name = "ER_yingzi",
	global = true,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local n = player:getMark(self:objectName())
		data:setValue(data:toInt() + n)
	end,
	can_trigger = function(self, player)
		return player:getMark(self:objectName()) > 0
	end,
}
if not sgs.Sanguosha:getSkill("ER_yingzi") then skills:append(ER_yingzi) end
--双刀
ER_shuangdao = sgs.CreateTargetModSkill{
	name = "ER_shuangdao",
	pattern = "Slash",
	residue_func = function(self, player)
		if player:getMark(self:objectName()) > 0 then
			local n = player:getMark(self:objectName())
			return n
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("ER_shuangdao") then skills:append(ER_shuangdao) end
--手长
ER_shouchang = sgs.CreateTargetModSkill{
	name = "ER_shouchang",
	pattern = "Slash",
	distance_limit_func = function(self, player)
		if player:getMark(self:objectName()) > 0 then
			local n = player:getMark(self:objectName())
			return n
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("ER_shouchang") then skills:append(ER_shouchang) end
--兵分
ER_bingfen = sgs.CreateTargetModSkill{
	name = "ER_bingfen",
	pattern = "Slash",
	extra_target_func = function(self, player)
		if player:getMark(self:objectName()) > 0 then
			local n = player:getMark(self:objectName())
			return n
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("ER_bingfen") then skills:append(ER_bingfen) end
--重装
ER_zhongzhuang = sgs.CreateTriggerSkill{
	name = "ER_zhongzhuang",
	global = true,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if not damage.card or not damage.card:isKindOf("Slash") then return false end
		local n = player:getMark(self:objectName())
		damage.damage = damage.damage + n
		data:setValue(damage)
	end,
	can_trigger = function(self, player)
		return player:getMark(self:objectName()) > 0
	end,
}
if not sgs.Sanguosha:getSkill("ER_zhongzhuang") then skills:append(ER_zhongzhuang) end
--医术
ER_yishu = sgs.CreateTriggerSkill{
	name = "ER_yishu",
	global = true,
	events = {sgs.PreHpRecover},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local recover = data:toRecover()
		if not recover.card or not recover.card:isKindOf("Peach") then return false end
		local n = player:getMark(self:objectName())
		recover.recover = recover.recover + n
		data:setValue(recover)
	end,
	can_trigger = function(self, player)
		return player:getMark(self:objectName()) > 0
	end,
}
if not sgs.Sanguosha:getSkill("ER_yishu") then skills:append(ER_yishu) end
--嗜酒
ER_shijiu = sgs.CreateTargetModSkill{
	name = "ER_shijiu",
	pattern = "Analeptic",
	residue_func = function(self, player)
		if player:getMark(self:objectName()) > 0 then
			local n = player:getMark(self:objectName())
			return n
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("ER_shijiu") then skills:append(ER_shijiu) end
--威震
ER_weizhen = sgs.CreateTargetModSkill{
	name = "ER_weizhen",
	pattern = "Slash",
	distance_limit_func = function(self, player, card)
		if player:getMark(self:objectName()) > 0 and card and card:isRed() then
			return 1000
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("ER_weizhen") then skills:append(ER_weizhen) end
--渡劫
ER_dujie = sgs.CreateTriggerSkill{
	name = "ER_dujie",
	global = true,
	events = {sgs.RoundStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:getMark(self:objectName()) == 0 then continue end
			local judge = sgs.JudgeStruct()
			judge.pattern = ".|spade|2~9"
			judge.good = true
			judge.reason = self:objectName()
			judge.who = p
			room:judge(judge)
			if judge:isGood() then
				room:broadcastSkillInvoke(self:objectName())
				room:damage(sgs.DamageStruct(self:objectName(), nil, p, 3, sgs.DamageStruct_Thunder))
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getSeat() == 1
	end,
}
if not sgs.Sanguosha:getSkill("ER_dujie") then skills:append(ER_dujie) end
--🎁国庆小礼
ER_guoqing = sgs.CreateTriggerSkill{
	name = "ER_guoqing",
	global = true,
	priority = {10, 1},
	events = {sgs.GameStart, sgs.CardUsed, sgs.CardResponded},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart and player:getSeat() == 1 then
			local can_invoke = false
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark(self:objectName()) > 0 then
					can_invoke = true
				end
			end
			if can_invoke then
				room:doLightbox("$ER_happyNationalDay")
				for _, p in sgs.qlist(room:getAllPlayers()) do
					room:addPlayerMark(p, "ER_guoqingDraw")
				end
			end
		elseif event == sgs.CardUsed or event == sgs.CardResponded then
			local card = nil
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else 
				local resp = data:toCardResponse()
				card = resp.m_card
			end
			if card and (card:getNumber() == 10 or card:getNumber() == 1) and player:getMark("ER_guoqingDraw") > 0 then
				room:drawCards(player, 1, self:objectName())
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("ER_guoqing") then skills:append(ER_guoqing) end

--==第二季==--

end
--======================--


--

sgs.Sanguosha:addSkills(skills)
sgs.LoadTranslationTable{
	["godstrengthenMOD"] = "游戏副本扩展",
	["godstrengthenMODs"] = "游戏副本扩展(开关)",
	
	["godstrengthenMODon"] = "开启：游戏副本扩展",
	["godstrengthenMODchoice"] = "请选择要进入的游戏副本",
	--
	["godstrengthenMODchoice:MOD_AngelsRelics"] = "特殊场景：天使的遗物",
	["godstrengthenMODchoice:MOD_AngelsRelics_hidden"] = "特殊场景：天使的遗物（里主线）",
	["godstrengthenMODchoice:MOD_EnvironmentRedevelop"] = "环境改造包",
	  ["MOD_EnvironmentRedevelop:MOD_EnvironmentRedevelop_s1"] = "环境改造包（第一季）",
	  ["MOD_EnvironmentRedevelop:MOD_EnvironmentRedevelop_s2"] = "环境改造包（第二季）",
	--
	
	--==诸神黄昏==--
	--神之审判
	["godRule"] = "神之审判",
	["GODSstart"] = "诸神黄昏：开幕",
	["GODRULEskip"] = "",
	["GODReviseHp"] = "",
	["GODevent_down"] = "事件:神之覆灭",
	["GOD_Killdevil"] = "诛魔",
	["GODevent_judge"] = "事件:神之审判",
	["KillGOD"] = "弑神",
	["GODsurroundingDraw"] = "",
	["GODsurroundingMaxCards"] = "",
	[":GODSstart"] = "\
	《<font color='orange'><b>小型场景：诸神黄昏</b></font>》\
	<font color='blue'><b>身份配置</b></font>\
	<font color='red'><b>主公</b></font>1名：神之审判/士兵[男]\
	<font color='blue'><b>内奸</b></font>7名：神关羽-无武魂版/神吕蒙(风)、神周瑜/神诸葛亮(火)、神曹操/神吕布(林)、新神赵云/神司马懿(山)、神刘备/神陆逊(阴)、神张辽/神甘宁(雷)、魏武帝/晋宣帝(神杀倚天包)\
	<font color='blue'><b>行动顺序</b></font>\
	8人局随机位置\
	<font color='blue'><b>游戏开始</b></font>\
	双将体力/体力上限取体力值/体力上限之和；按照身份场的规则进行游戏。\
	<font color='grey'><b>事件1：神之幻化</b></font>\
	如果玩家抽到了“神之审判”进行游戏，玩家会在游戏开始后幻化为（主将：神-基尔什塔利亚·沃戴姆/副将：神-戴比特·泽姆·沃伊德），然后继续游戏。\
	<font color='purple'><b>事件2：神之覆灭</b></font>\
	如果“神之审判”为玩家，则在其第一个回合结束时，其他角色将会有一定概率变成<font color='green'><b>反贼</b></font>，摸三张牌并将势力更改为“魔”。然后玩家获得以下效果：\
	立即摸等同于场上反贼数量X2的牌；之后的每个回合开始时，摸等同于场上反贼数量的牌。\
	<font color='yellow'><b>事件3：神之审判</b></font>\
	如果“神之审判”为AI，则在其第二个及之后的回合开始前，其进行判定：\
	鸿运当头：判定结果为红桃2~9，所有其他角色随机回复0~3点体力；\
	神临天启：判定结果为方块2~9，所有其他角色随机摸0~3张牌；\
	阴雨连绵：判定结果为梅花2~9，所有其他角色需弃置随机0~3张牌；\
	电闪雷鸣：判定结果为黑桃2~9，所有其他角色受到无来源的随机0~3点雷电伤害。\
	若是其他判定结果则无事发生。\
	<font color='blue'><b>场上共有效果</b></font>\
	1.<font color='red'><b>弑神</b></font>：当“神”势力角色受到伤害时，此伤害+1（如果其有“归心”，则改为受到伤害并失去1点体力）。\
	2.<font color='green'><b>神之庭园</b></font>：场上所有角色摸牌阶段摸牌数+2，手牌上限-2。\
	<font color='blue'><b>玩家胜利条件</b></font>\
	1.如果玩家是“神之审判”：\
	所有其他角色阵亡且自己存活，获得胜利；\
	2.如果玩家是其他角色：\
	除“神之审判”之外的所有其他角色先于“神之审判”阵亡且自己存活，获得胜利。\
	<font color='blue'><b>游戏结束结算</b></font>\
	1.“神之审判”为AI，则其不参与胜利的争夺，不会受到伤害且没有回合（起始手牌为0），除其之外最后一位存活的角色胜利；\
	2.“神之审判”为玩家，如果“神之审判”死亡且场上至少有一位存活反贼或反贼全部阵亡但场上存活人数大于1，反贼阵营胜利；如果只剩一位存活的非反贼角色，该角色胜利。",
	--3.“神之审判”在不满足上述条件的情况下死亡，全员失败。",
	["$GODSstart_change"] = "%from 为 <font color='red'><b>玩家</b></font>，将进行 <font color='grey'><b>幻化</b></font>",
	["itsnotRagnarokr"] = "",
	["GODlessMaxCards"] = "",
	["GODReviseHp_Invoked"] = "",
	["GODevent_down_invoked"] = "",
	["$eventOne_GODevent_change"] = "事件：神之幻化",
	["$eventTwo_GODevent_down"] = "事件：神之覆灭",
	["$eventThree_GODevent_judge"] = "事件：神之审判",
	["GODend"] = "诸神黄昏：落幕",
	[":GODend"] = "锁定技，（如果你不是玩家，）当场上除你之外只剩一名角色时，其胜利。",
	["qixingSupplement"] = "七星",
	
	--神关羽（此模式专用的无武魂版，避免影响游戏体验）
	["shenguanyu_nowuhun"] = "神关羽-无武魂版",
	["#shenguanyu_nowuhun"] = "玉泉山显圣",
	["&shenguanyu_nowuhun"] = "神关羽",
	  --武神
	["Nwushen"] = "武神",
	["NwushenDuel"] = "武神",
	["NwushenDR"] = "武神",
	["NwushenQM"] = "武神",
	[":Nwushen"] = "锁定技，你的红桃手牌视为无距离和次数限制的普通【杀】，你的方块手牌视为【决斗】；你以此法使用的牌不可被响应。",
	["$Nwushen1"] = "武神现世，天下莫敌！",
	["$Nwushen2"] = "战意，化为青龙翱翔吧！",
	  --阵亡
	["~shenguanyu_nowuhun"] = "桃园之梦，再也不会回来了......",
	
	--神之审判幻化后的主将：神-基尔什塔利亚·沃戴姆
	["godWodime"] = "神-基尔什塔利亚·沃戴姆",
	["&godWodime"] = "神队长",
	["#godWodime"] = "人理的新生",
	["designer:godWodime"] = "Fate/GO,时光流逝FC",
	["cv:godWodime"] = "齐藤壮马,芳贺敬太",
	["illustrator:godWodime"] = "原画：小山广和",
	  --回路
	["kwhuilu"] = "回路",
	[":kwhuilu"] = "锁定技，游戏开始时，你获得3枚“星空”标记；每当你造成1点伤害、受到1点伤害或回复1点体力，你获得1枚“星空”标记。",
	["kwxingkong"] = "星空",
	["$kwhuilu1"] = "这倒是确实有点做过头了啊。",
	["$kwhuilu2"] = "还是希望您别要过于强迫人了啊。",
	  --占星
	["kwzhanxing"] = "占星",
	[":kwzhanxing"] = "准备阶段开始时，你观看牌堆顶的X张牌，将其中任意数量的牌以任意顺序置于牌堆顶，其余的以任意顺序置于牌堆底，然后你摸一张牌（X为你于此时的“星空”标记的数量且至多为5）；锁定技，你的手牌上限+1。",
	["$kwzhanxing1"] = "Stars. Cosmos. Gods. Animus. Antrum. Unbirth. Anima, Animusphere!",
	["$kwzhanxing2"] = "星之型。宙之型。神之型。吾之型。天体即为空洞。空洞即为虚空。虚空存之以神。",
	  --完人
	["kwwanren"] = "完人",
	--[":kwwanren"] = "<b>说明技，</b>在合适的时机，你可以移去1枚“星空”标记，发动以下技能其中之一（技能按钮在武将头像左上方）：“队长”、“神才”、“天不旋”、“地不动”、“强运”、“引导”、“丰收”、“诸神”、“灯火”、“独旅”。",
	--说明技：与要说明的相关技能没有任何关联。即使该说明技失效了，其说明的相关技能也不会受到任何影响。
	[":kwwanren"] = "在合适的时机，你可以移去1枚“星空”标记，发动以下技能其中之一：“队长”、“神才”、“天不旋”、“地不动”、“强运”、“引导”、“丰收”、“诸神”、“灯火”、“独旅”。\
	◆出牌阶段，你可以<font color='green'><b>点击此按钮</b></font>，获得上述于出牌阶段主动发动的其中一个技能直到此阶段结束：“队长”、“神才”、“天不旋”、“引导”、“丰收”、“诸神”、“灯火”。",
	["kwwanren_SkillClear"] = "完人",
	["kwwanren_skillget"] = "",
	["cancel"] = "取消",
	  ----------
	["kwduizhang"] = "队长",
	[":kwduizhang"] = "[移去1枚“星空”标记]出牌阶段限一次，你弃置一张手牌，令一名其他角色回复1点体力并摸一张牌。",
	--["$kwduizhang"] = "我是为了守护人理而战斗的，A组的队长！",
	["kwshencai"] = "神才",
	[":kwshencai"] = "[移去1枚“星空”标记]出牌阶段限一次，你交给一名其他角色一张牌，然后你摸一张牌。",
	["$kwshencai"] = "虚空之神啊，现在我宣布人智的败北。",
	["kwtianbuxuan"] = "天不旋",
	["kwtianbuxuan_Clear"] = "天不旋",
	[":kwtianbuxuan"] = "[移去1枚“星空”标记]出牌阶段，你令一名其他角色的非锁定技失效，直到回合结束。",
	["$kwtianbuxuan"] = "天不旋。",
	["kwdibudong"] = "地不动",
	[":kwdibudong"] = "[移去1枚“星空”标记]每当你的体力值变化时，你可以复原你的武将牌并摸一张牌。",
	["$kwdibudong"] = "地不动。",
	["kwqiangyun"] = "强运",
	[":kwqiangyun"] = "[移去1枚“星空”标记]当你的判定牌生效前，你可以打出一张牌替换之。",
	["@kwqiangyun-card"] = "你可以打出一张牌替换原先的判定牌作为新的判定牌",
	["$kwqiangyun"] = "强运之星辰。",
	["kwyindao"] = "引导",
	[":kwyindao"] = "[移去1枚“星空”标记]出牌阶段限一次，你将一张黑色锦囊牌当作【铁索连环】使用或重铸。",
	["$kwyindao"] = "明星之引导。",
	["kwfengshou"] = "丰收",
	[":kwfengshou"] = "[移去1枚“星空”标记]出牌阶段限一次，你将一张红色锦囊牌当作【五谷丰登】使用。",
	["$kwfengshou"] = "丰收之预兆。",
	["kwzhushen"] = "诸神",
	[":kwzhushen"] = "[移去1枚“星空”标记]出牌阶段限一次，你令所有角色回复1点体力并弃一张牌。",
	["$kwzhushen"] = "天穹的诸神啊！",
	["kwdenghuo"] = "灯火",
	[":kwdenghuo"] = "[移去1枚“星空”标记]出牌阶段限一次，你令一名角色受到1点火焰伤害并摸一张牌。",
	["$kwdenghuo"] = "迦勒底的灯火啊。",
	["kwdulv"] = "独旅", --一次又一次地，带A组除戴比特之外的五个人加自己走完6次人理拯救模拟的旅途，每次到了第六章和第七章时都已是孤身一人。
	["#kwdulv"] = "独旅",
	[":kwdulv"] = "[移去1枚“星空”标记]每有一名其他玩家死亡时，你可以摸两张牌或回复1点体力。",
	["draw2cards"] = "摸两张牌",
	["recover1hp"] = "回复1点体力",
	  ----------
	  --赋灵
	["kwfulin"] = "赋灵", --技能灵感来源于迦勒底御主与队长+凯妮斯的御主战，队长可以直接给凯妮斯加血槽。
	[":kwfulin"] = "限定技，出牌阶段，你弃置3枚“星空”标记，令一名其他角色加1点体力上限、回复1点体力并废除其判定区。",
	["@kwfulin"] = "赋灵",
	["$kwfulin"] = "赋予汝之灵魂以黄金的骄傲",
	  --极陨
	["kwjiyun"] = "极陨", --队长的宝具：『冠位指定/人理保障天球（Grand Order/Anima Animusphere）』
	["$GrandOrder_AnimaAnimusphere"] = "『冠位指定/人理保障天球』！",
	[":kwjiyun"] = "出牌阶段限一次，你弃置7枚“星空”标记，减1点体力上限，令所有其他角色的非锁定技失效直到回合结束且装备区清空，再对所有其他角色各造成1点火焰伤害。", --“减1点体力上限”：队长通常状态下为3点体力上限，如此可还原队长行星轰只能施展两次的设定。
	["$kwjiyun"] = "（宝具【冠位指定/人理保障天球】的背景音乐）",
	  --阵亡
	["~godWodime"] = "不能倒下，绝对，不能倒下......", -- “迦勒底的灯火啊，请再次指引旅人前进的道路。”
	--什么嘛，只不过是一次两次的失败而已，人的价值是不会下降的......
	
	--神之审判幻化后的副将：神-戴比特·泽姆·沃伊德
	["godDaybit"] = "神-戴比特·泽姆·沃伊德",
	["&godDaybit"] = "神戴比特",
	["#godDaybit"] = "孤世之天才",
	["designer:godDaybit"] = "时光流逝FC,Fate/GO",
	["cv:godDaybit"] = "石川界人,芳贺敬太",
	["illustrator:godDaybit"] = "高桥庆太郎",
	  --孔洞
	["voidkongdong"] = "孔洞",
	["voidkongdongFlagClear"] = "孔洞",
	["voidkongdongAOE"] = "孔洞",
	[":voidkongdong"] = "回合内和回合外各限一次，你可以失去1点体力，视为使用一种基本牌或普通锦囊牌。",
	["voidkongdong_list"] = "孔洞",
	["voidkongdong_slash"] = "孔洞",
	["voidkongdong_saveself"] = "孔洞",
	["$voidkongdong1"] = "迦勒底的指定到此结束。",
	["$voidkongdong2"] = "就让我作为人类的敌人，告诉你们真相。",
	["$voidkongdong3"] = "（BGM:黄金树海纪行-地图背景音乐）你们几个都活下来了吗。虽说是未来的预支，\
	居然会在地球终结的瞬间跟你们对峙，真是坎坷的命运。", --放AOE（文字播放）
	["$voidkongdong4"] = "（BGM:黄金树海纪行-地图背景音乐）我要完成隐匿者的职责。在一切都化为『空洞』之前，破坏这颗行星。", --放AOE（文字播放）
	  --天逆
	["voidRuleReverse"] = "天逆",
	["voidrulereverse"] = "天逆",
	[":voidRuleReverse"] = "限定技，出牌阶段开始时可选择发动，则你依次执行以下效果（每一项可选择是否执行；每执行完一项，你减1点体力上限）：\
	1.横置一名角色并对其造成1点火焰伤害；\
	2.令一名角色翻面并对其造成1点冰冻伤害；\
	3.弃置一名角色区域里的一张牌并对其造成1点雷电伤害；\
	4.获得一名角色区域里的一张牌并对其造成1点毒素伤害；\
	5.移动场上的一张装备区里的牌和一张判定区里的牌(不得替换原装备栏已有的牌/原判定区已有的同名牌)；\
	6.令一名角色回满体力并将手牌补至体力上限；\
	7.令两名角色交换座位；\
	8.废除一名角色的装备区，然后其摸两张牌并回复2点体力；\
	9.(若前面所有选项皆选择执行必触发此项，否则有20%概率触发此项)对所有其他角色各造成随机1~7点伤害。",
	["@voidRuleReverse-card"] = "你是否发动技能“天逆”？",
	["~voidRuleReverse"] = "若发动则点【确定】，然后根据提示执行相应的操作",
	["voidRuleReverse-invokeA"] = "[1.0 人理烧却]你可以横置一名角色并对其造成1点火焰伤害",
	["voidRuleReverse-invokeB"] = "[2.0 人理冻结]你可以令一名角色翻面并对其造成1点冰冻伤害",
	["voidRuleReverse-invokeC"] = "[2.1永久冻土帝国/2.2无间冰焰世纪]你可以弃置一名角色区域里的一张牌并对其造成1点雷电伤害",
	["voidRuleReverse-invokeD"] = "[2.3人智统合真国/2.4创世灭亡轮回]你可以获得一名角色区域里的一张牌并对其造成1点毒素伤害",
	--["voidRuleReverse-invokeE"] = "天逆(移动场上的牌)",
	["voidRuleReverse_Equip"] = "[2.51 神代巨神海洋]你可以选择一名场上装备区里有牌的角色",
	["@voidRuleReverse_Equip-to"]  = "请选择移动的目标角色",
	["voidRuleReverse_Judge"] = "[2.52 星间都市山脉]你可以选择一名场上判定区里有牌的角色",
	["@voidRuleReverse_Judge-to"]  = "请选择移动的目标角色",
	["voidRuleReverse-invokeF"] = "{星间都市山脉:击落神明之日}你可以令一名角色回满体力并将手牌补至体力上限",
	["voidRuleReverse-invokeG1"] = "[2.6 妖精圆桌领域]你可以选择要交换座位的其中一名角色",
	["voidRuleReverse-invokeG2"] = "请选择另一名角色",
	["voidRuleReverse-invokeH"] = "[2.7 黄金树海纪行]你可以废除一名角色的装备区，然后其摸两张牌并回复2点体力",
	--["voidRuleReverse-invokeI"] = "[2.0终章]你是否选择发动“天逆”的终极大招？",
	["@VOID"] = "虚无",
	["$voidRuleReverse"] = "（BGM:Cosmos in the Lostbelt）",
	  --“天逆”最终大招专用音效
	["voidRuleReverse_FINAL"] = "天逆-终",
	[":voidRuleReverse_FINAL"] = "[配音技]，此技能为“天逆”最后一项的专用配音。",
	["$voidRuleReverse_FINAL"] = "（BGM:Fate/Grand Order）",
	  --阵亡
	["~godDaybit"] = "空想之梦陨落。最后的希望消失于虚空之中。",
	
	--==天使的遗物==--
	--==神-戴比特·泽姆·沃伊德-->“天使的遗物”-->魔-戴比特·泽姆·沃伊德==--（特殊场景:天使的遗物-BOSS）
	["MOD_AngelsRelics"] = "天使的遗物",
	["Daybit_exchange"] = "？",
	["AngelsRelics"] = "天使的遗物",
	["TreeSeaRuins"] = "树海之遗迹",
	["devilDaybit"] = "魔-戴比特·泽姆·沃伊德",
	["&devilDaybit"] = "魔戴比特",
	["#devilDaybit"] = "宇宙之视角",
	["designer:devilDaybit"] = "Fate/GO,时光流逝FC",
	["cv:devilDaybit"] = "石川界人,芳贺敬太,永田大祐",
	["illustrator:devilDaybit"] = "高桥庆太郎",
	  --全宇宙观测
	["voidObserveUniverse"] = "全宇宙观测",
	[":voidObserveUniverse"] = "锁定技，你使用牌无距离限制；你使用牌指定一名其他角色为目标时，若你于此回合未通过此技能观看过其手牌，你观看其手牌。<font color='red'><b>（注意：包括技能卡牌）</b></font>",
	  --通信
	["voidtongxin"] = "通信",
	["voidtongxinGMS"] = "通信",
	["voidtongxinOne"] = "通信-无视护甲",
	["voidtongxinTwo"] = "通信-概率暴击",
	["voidtongxinThree"] = "通信-概率穿透",
	["voidtongxinFour"] = "通信-概率加伤",
	["voidtongxinFive"] = "通信-锁技强命",
	["voidtongxinContinue"] = "通信",
	[":voidtongxin"] = "锁定技，游戏开始后，你获得X个“天使的遗物”标记物（X为场上其他角色数）。回合开始前，若你的“天使的遗物”标记物数量大于1，你可以选择数量少于Y的任意名没有被标记为“天使的遗物”的其他角色（Y为你的“天使的遗物”标记物数量），" ..
	"将“天使的遗物”标记物移交给这些角色各一个。(全局生效)场上有“天使的遗物”标记物的角色，视为被标记为【<font color='orange'><b>天使的遗物</b></font>】，且拥有专属技能“天使的遗物”。\
	锁定技，你的第Z个回合开始时，你对场上所有【<font color='orange'><b>天使的遗物</b></font>】发送如下指令(只要其被标记为【<font color='orange'><b>天使的遗物</b></font>】就生效)：\
	Z=1，(效果持续其三个回合)造成伤害时<font color='red'><b>有20%的概率</b></font>无视护甲；\
	Z=2，(效果持续其三个回合)造成的伤害有10%的概率暴击；\
	Z=3，(效果持续其三个回合)使用伤害类卡牌时有30%的概率弃置目标一张牌；\
	Z=4，(效果持续其三个回合)造成的伤害有60%的概率+1(优先于暴击计算)；\
	Z=5，(效果持续其三个回合)使用伤害类卡牌时令目标的非锁定技失效，且不可被响应，直到卡牌结算结束；\
	Z=6，摸五张牌并复原武将牌。\
	所有【<font color='orange'><b>天使的遗物</b></font>】在收到一次指令后，摸一张牌。",
	["voidtongxin_FirstUsed"] = "",
	["@voidtongxin-card"] = "你可以选择数量少于你所拥有的“天使的遗物”标记物数量的其他角色，将这些角色标记为【<font color='orange'><b>天使的遗物</b></font>】",
	["~voidtongxin"] = "那么，开始摇人。",
	["voidtongxinTurn"] = "",
	["@voidtongxin_WSFY"] = "无视护甲",
	["@voidtongxin_BJLv"] = "概率暴击",
	["@voidtongxin_GJL"] = "概率穿透",
	["@voidtongxin_BJWL"] = "概率加伤",
	["@voidtongxin_WDGT"] = "锁技强命",
	["voidtongxinOne_Hujias"] = "",
	["$voidtongxin1"] = "不好意思，卡多克赶不过来的。你们迦勒底的残党，以及“异星之神”的计划，都在这里终结吧。那么，开始通信。", --游戏开始
	["$voidtongxin2"] = "那么，开始通信。", --标记
	["$voidtongxin3"] = "开启。", --第1个回合上buff
	["$voidtongxin4"] = "10亿光年。", --第2个回合上buff
	["$voidtongxin5"] = "30亿光年。", --第3个回合上buff
	["$voidtongxin6"] = "60亿光年。", --第4个回合上buff
	["$voidtongxin7"] = "135亿光年。", --第5个回合上buff
	["$voidtongxin8"] = "爆破。", --第6个回合上buff
	    --天使的遗物
	  ["voidAngelsRelics"] = "天使的遗物",
	  ["voidAngelsRelicsSkillChanged"] = "天使的遗物",
	  [":voidAngelsRelics"] = "锁定技，你拥有如下效果：\
	  ○准恒星电波：造成伤害/受到伤害时，有概率对伤害目标/伤害来源附加“灼伤”(概率:20%+10%*T)或“带电”(概率:10%+5%*T)状态。（T为场上其他【<font color='orange'><b>天使的遗物</b></font>】的数量）\
	    -><font color='red'>灼伤：(初始效果持续一个回合,每叠加一个延长一回合)回合结束时，受到1点无来源的火焰伤害。</font>\
	    -><font color='blue'>带电：(初始限触发一次,每叠加一个增加一次)回合结束时有50%的概率触发，其距离为1及以内的所有其他角色各受到1点无来源的雷电伤害并有30%的概率获得“带电”状态。</font>\
	  ○光不至领域：第一次进入濒死状态时，将体力调整至1点，然后令伤害来源弃置<font color='blue'><s>所有</s></font><font color='red'><b>四张</b></font>牌。\
	  ○彼方外宇宙：第二次进入濒死状态时，将体力调整至1点，然后获得3点护甲并复原武将牌。",
	  ["@voidAngelsRelics_ZS"] = "灼伤",
	  ["voidAngelsRelics_ZS"] = "天使的遗物-灼伤",
	  ["@voidAngelsRelics_DD"] = "带电",
	  ["voidAngelsRelics_DD"] = "天使的遗物-带电",
	  ["voidAngelsRelics_EDfqc"] = "",
	  ["$voidAngelsRelics"] = "（被附加“灼烧”或“带电”状态的音效）",
	  --阵亡
	["~devilDaybit"] = "而你们居然要作为新迦勒底，去与旧迦勒底战斗......“新·迦勒底”吗？是个好名字啊。（转身离去）\
	（等等，戴比特！）\
	???????：别叫住他。你打算连败者退场的机会都要剥夺吗？...这时候就目送他吧。现在那家伙正适合米克特兰帕......",
	--================================================================ 主 体 内 容 ================================================================--
	["$MOD_AngelsRelics"] = "特殊场景：天使的遗物",
	["$EnterMOD_AngelsRelics"] = "<b><font color=\"#4DB873\">游戏副本1</font>：“<font color='yellow'>特殊场景</font>：" ..
	"<font color='purple'>天使的遗物</font>” <font color='red'>开启</font>！</b>",
	["MOD_AngelsRelics_diffi"] = "请选择难度",
	--人理方
	["MOD_AngelsRelics_diffi:1"] = "新手教学",
	["MOD_AngelsRelics_diffi:3"] = "简单难度",
	["MOD_AngelsRelics_diffi:5"] = "中等难度",
	["MOD_AngelsRelics_diffi:7"] = "困难难度",
	["MOD_AngelsRelics_diffi:9"] = "超高难度",
	["MOD_AngelsRelics_diffi:11"] = "选择困难症，随机安排吧！",
	--BOSS方
	["MOD_AngelsRelics_diffi:2"] = "新手教学",
	["MOD_AngelsRelics_diffi:4"] = "简单难度",
	["MOD_AngelsRelics_diffi:6"] = "中等难度",
	["MOD_AngelsRelics_diffi:8"] = "困难难度",
	["MOD_AngelsRelics_diffi:10"] = "超高难度",
	["MOD_AngelsRelics_diffi:12"] = "选择困难症，随机安排吧！",
	--
	["f_dontchangeHero"] = "不更换武将",
	["@MOD_AngelsRelics_renli"] = "人理的守护者",
	["MOD_AngelsRelics_renli"] = "人理的守护者",
	["$MOD_AngelsRelics_renli_c"] = "%from 的技能“<font color='yellow'><b>人理的守护者 C</b></font>”被触发",
	["$MOD_AngelsRelics_renli_b"] = "%from 的技能“<font color='yellow'><b>人理的守护者 B</b></font>”被触发",
	["$MOD_AngelsRelics_renli_a"] = "%from 的技能“<font color='yellow'><b>人理的守护者 A</b></font>”被触发",
	["$MOD_AngelsRelics_renli_s"] = "%from 的技能“<font color='yellow'><b>人理的守护者 A+</b></font>”被触发",
	["$MOD_AngelsRelics_renli_ex"] = "%from 的技能“<font color='yellow'><b>人理的守护者 EX</b></font>”被触发",
	["@MOD_AngelsRelics_xrns"] = "夏尔诺斯之物",
	["MOD_AngelsRelics_xrns"] = "夏尔诺斯之物",
	["MOD_AngelsRelics_xrns_c"] = "夏尔诺斯之物 C",
	[":MOD_AngelsRelics_xrns_c"] = "锁定技，你的手牌上限+1。",
	["MOD_AngelsRelics_xrns_b"] = "夏尔诺斯之物 B",
	[":MOD_AngelsRelics_xrns_b"] = "锁定技，你的手牌上限+1、摸牌阶段摸牌数+1。",
	["MOD_AngelsRelics_xrns_a"] = "夏尔诺斯之物 A",
	[":MOD_AngelsRelics_xrns_a"] = "锁定技，你的手牌上限+1、摸牌阶段摸牌数+1、使用牌的距离与次数上限+1。",
	["MOD_AngelsRelics_xrns_s"] = "夏尔诺斯之物 A+",
	[":MOD_AngelsRelics_xrns_s"] = "锁定技，你的手牌上限+1、摸牌阶段摸牌数+1、使用牌的距离与次数上限+1、伤害量与回复量+1。",
	["MOD_AngelsRelics_xrns_ex"] = "夏尔诺斯之物 EX",
	[":MOD_AngelsRelics_xrns_ex"] = "锁定技，你的手牌上限+1、摸牌阶段摸牌数+1、使用牌的距离与次数上限+1、伤害量与回复量+1、每造成或受到一次伤害，摸一张牌。",
	--["$MOD_AngelsRelics_ff"] = "<font color=\"#00FFFF\"><b>人理方</b></font> 触发了技能“<font color='yellow'><b>来自泛人类史 ???</b></font>”",
	["MOD_AngelsRelics_start"] = "天使的遗物", --，启动！
	["MOD_AngelsRelics_start:MOD_AngelsRelics_story"] = "你是否观看“<font color='purple'><b>天使的遗物</b></font>”主线剧情？",
	--剧情内容--
	--戴比特：
	["#MOD_AngelsRelics_story1"] = "终究是来到了这里吗？虽然我一直觉得你很能干——",
	["#MOD_AngelsRelics_story2"] = "然而亲眼见到之后，感觉还是很震撼啊。",
	["#MOD_AngelsRelics_story3"] = "就像把“自认为我是SGS的大神”而骄傲自满的事实摆在我眼前似的。",
	--“主人公”：
	["#MOD_AngelsRelics_story4"] = "别再往前了，停下！",
	--戴比特：
	["#MOD_AngelsRelics_story5"] = "我没理由停下。若想阻止我，就靠实力来阻止。",
	["#MOD_AngelsRelics_story6"] = "我刚刚抵达这里。“灭世之因”的沉眠之地就在你们背后。",
	["#MOD_AngelsRelics_story7"] = "直线距离还剩20米。然后这颗行星就将终结，GK的馬也将不复存在。",
	["#MOD_AngelsRelics_story8"] = "我已经做好了启动“灭世之因”的准备。",
	--“主人公”：
	["#MOD_AngelsRelics_story9"] = "你真的打算破坏这颗行星吗？你戴比特可是生于这颗行星的人！",
	["#MOD_AngelsRelics_story10"] = "就为了这，就要毁灭自己的世界吗？",
	--戴比特：
	["#MOD_AngelsRelics_story11"] = "——动机是有的。我就是为此才潜入总部的。",
	["#MOD_AngelsRelics_story12"] = "话说回来，居然说我是“这颗行星的人”吗。我看起来，像是这颗行星的人类吗？",
	--“主人公”：
	["#MOD_AngelsRelics_story13"] = "......不知道。我对你一无所知。",
	--戴比特：
	["#MOD_AngelsRelics_story14"] = "原来如此。迄今为止已无数次听闻的无聊回答。",
	["#MOD_AngelsRelics_story15"] = "很抱歉，但我没时间了。今天可能剩余不到1分钟了。",
	["#MOD_AngelsRelics_story16"] = "生熏鱼、神马超、潘淑他们已经被我搅碎成肉末了。接下来，该是把你们切成肉片的时候了。",
	  ["MOD_AngelsRelics_storyAnimate"] = "image=image/animate/MOD_AngelsRelics_story.png",
	--“主人公”：
	["#MOD_AngelsRelics_story17"] = "（从者......！？戴比特不是无法召唤英灵的吗？）",
	["#MOD_AngelsRelics_story18"] = "（......不对。那不是英灵。根本不是属于这个宇宙的生命。）",
	["#MOD_AngelsRelics_story19"] = "（在140亿光年之外的彼方——在宇宙大爆炸时，弹飞到宇宙之外的“暗黑星”之终端。）",
	["#MOD_AngelsRelics_story20"] = "（但为什么？为什么这家伙连接着这颗行星上连光都无法抵达，比140亿年更古老的电波源啊？）",
	--戴比特：
	["#MOD_AngelsRelics_story21"] = "原来如此。真不愧是拯救过世界的人啊。一眼就看穿了在我背后的这些家伙的真面目。",
	--“主人公”：
	["#MOD_AngelsRelics_story22"] = " ... ？！",
	--戴比特：
	["#MOD_AngelsRelics_story23"] = "不对，你一直都是这么聪明。只是，GK太能搞了而已。",
	["#MOD_AngelsRelics_story24"] = "无能之人是无法让SGS差评冠绝于这个世界的。无能之人也是不会站在这里准备要击倒我的。",
	["#MOD_AngelsRelics_story25"] = "那个时候GK的手段，建立阴灵殿，大肆吸收钞能力，企图抹除全世界生灵的阴谋本可以说是完美了......",
	["#MOD_AngelsRelics_story26"] = "然而其中称得上是奇迹一手的，就是你对SGS的感情。",
	["#MOD_AngelsRelics_story27"] = "如果没有这个，我们就不会有逆转之路。稀世珍宝界徐盛。不，阎王阴神徐盛。", --联动一下司马子元大佬新写的BOSS神徐盛
	["#MOD_AngelsRelics_story28"] = "他在一次次古锭酒雷杀万军取首的时候，也催生了“人理的守护者”。",
	--“主人公”：
	["#MOD_AngelsRelics_story29"] = "你这家伙......一副你跟我很熟的口吻......",
	["#MOD_AngelsRelics_story30"] = "但这些根本无关紧要！",
	["#MOD_AngelsRelics_story31"] = "大家，准备动手！如果让这家伙继续前进，我们就输了！这就是终末之战了，全力应战！", --非2人场出现
	["#MOD_AngelsRelics_story31ex"] = "如果让你继续前进，我们就输了！这就是终末之战了，你，只能到此为止了！", --2人场出现
	["#MOD_AngelsRelics_story32"] = "绝不能让你唤醒“灭世之因”，就让我们，在这里镇压你！",
	["#MOD_AngelsRelics_story33"] = "（戴比特就像面镜子一样......我们有多少战力，戴比特就能召唤出多少战力。因此这场战斗根本占不到人数的便宜......）",
	--（略去戴比特的回忆以及诉说掏U奥心窝子的那一部分）
	--戴比特：
	["#MOD_AngelsRelics_story34"] = "......嗯。直到与我交手，才毕露锋芒吗。",
	["#MOD_AngelsRelics_story35"] = "我知道原因了。“平衡”的游戏一直都是你的处世之道。SGS也一样。风火林山时代，令不少人怀念的辉煌。",
	["#MOD_AngelsRelics_story36"] = "“如果能保持那样的环境，一直和朋友们快乐的面杀就好了”。",
	["#MOD_AngelsRelics_story37"] = "多么，愚蠢啊。那样的世界，早已是梦幻泡影......",
	--“主人公”：
	["#MOD_AngelsRelics_story38"] = "戴比特！！！",
	--戴比特：
	["#MOD_AngelsRelics_story39"] = "真是可笑啊。太迟了。当我踏上这片土地的这一刻。你们人理方早就已经输了。",
	["#MOD_AngelsRelics_story40"] = "在消灭你之前，让我来解开你一直以来心中的疑惑吧，曾经的救世主，现在也自以为“是”的“救世主”。",
	["#MOD_AngelsRelics_story41"] = "我的目的是“维持秩序”。我判断这无论是对于人类，还是对于这个宇宙，都是好事。",
	["#MOD_AngelsRelics_story42"] = "当这个世界的钞能力被阴灵殿吸得一干二净的时候，GK那家伙的宏图伟业就完成了。那是足以主宰宇宙的力量。",
	["#MOD_AngelsRelics_story43"] = "这样一来，这颗行星的人类就会背上横跨138亿光年的罪名吧。被评为“这个宇宙最为卑劣的生命体”。",
	["#MOD_AngelsRelics_story44"] = "我要在这个无法设想的后果诞生之前毁掉这颗星球。因为要终结GK的馬......",
	["#MOD_AngelsRelics_story45"] = "让身为元凶的GK从这个宇宙上消失，只有这个办法。",
	--“主人公”：
	["#MOD_AngelsRelics_story46"] = "——。戴比特。你刚刚，在......说什么——",
	["#MOD_AngelsRelics_story47"] = "阻止GK的阴谋，绝不可能只有这个代价最不可估量的办法......",
	--戴比特：
	["#MOD_AngelsRelics_story48"] = "哪怕再怎么百般唾骂，哪怕再怎么深恶痛绝。你们，还是爱着SGS这款游戏的。你们，还是会献上自己的钞能力。",
	["#MOD_AngelsRelics_story49"] = "你认为，能彻底阻止GK，既可以拯救SGS，又可以拯救GK？",
	["#MOD_AngelsRelics_story50"] = "未免太天真过头了。你不也是“旧日杀”的忠实玩家吗？", --我知道你看不懂这句，因为我自己也看不懂
	["#MOD_AngelsRelics_story51"] = "GK是因SGS才诞生的存在。而一切的阴谋都是总部早已研究好，并即将画上圆满句号的计划。",
	["#MOD_AngelsRelics_story52"] = "十周年......十五周年。我们隐匿者(Crypter)，就是为“SGS十五周年”而被召集起来的棋子。",
	--“主人公”：
	["#MOD_AngelsRelics_story53"] = "少废话了，戴比特！我们世界的未来不是你用来同归于尽的砝码！不仅仅是要阻止GK，更重要的是，守护这个世界。",
	--戴比特：
	["#MOD_AngelsRelics_story54"] = "或许吧。一切的秘密都应该自己去亲自探索。",
	--（略去保护迦勒底亚斯的部分，感觉不太好改编QAQ）
	["#MOD_AngelsRelics_story55"] = "说回来，你们至今为止的行动都全部是正确的。",
	["#MOD_AngelsRelics_story56"] = "你们讨伐了无数阴兵，让世人认清GK的种种真面目。",
	["#MOD_AngelsRelics_story57"] = "虽然对于GK来说，这只不过是微不足道的茶余饭后的谈资罢了。",
	--“主人公”：
	["#MOD_AngelsRelics_story58"] = "你不会还想说......我们也是让SGS变成如今这般境地的罪魁祸首之一吧。",
	["#MOD_AngelsRelics_story59"] = "我们只是想GK似罢了，但是我们无法离开SGS。GK运营着SGS，掌控着一切的一切。实际的结果是GK一直都是这么猖狂。",
	["#MOD_AngelsRelics_story60"] = "照你的意思，被打倒的“恶”，反而应该是我们才对？",
	--戴比特：
	["#MOD_AngelsRelics_story61"] = "不。实际上，你们也确实拯救了人类。你们在GK吞没一切的洪流中让更多的人冷静下来。这是值得骄傲的事情。",
	["#MOD_AngelsRelics_story62"] = "虽然SGS玩家是原因之一，但是元凶肯定不是你们。你们从来就没有和GK穿一条裤子过。",
	["#MOD_AngelsRelics_story63"] = "以“热爱SGS，并为SGS的存续尽心奉献”的角度来看，你们是最棒的大神。",
	["#MOD_AngelsRelics_story64"] = "我和高达一号都不会否定你们的意志。所以——",
	["#MOD_AngelsRelics_story64cd"] = "无论是我、高达一号，还是珂神都不会否定你们的意志。所以——", --23%彩蛋
	["#MOD_AngelsRelics_story65"] = "如果真的有那0.01%的可能阻止了我启动“灭世之因”，并且认为你们的理想就是那空洞的未来的话，那就去航舟吧。",
	["#MOD_AngelsRelics_story66"] = "那里就是你们旅途的终点。与GK，与SGS的诀别之地。",
	["#MOD_AngelsRelics_story67"] = "好了，该说的基本都说了。这是我与高达一号的约定。虽然都只是内心的想法，但彼此都是这样想的。",
	["#MOD_AngelsRelics_story68"] = "“当我们其中之一留到最后，准备打倒最大的障碍之时，将这个世界的真相告诉他们”",
	["#MOD_AngelsRelics_story69"] = "虚无缥缈的理想终究抵不过残酷的现实。就让我用我的灵魂，与已经无法剥离GK的世界，做出最后的诀别......",
	--“主人公”：
	["#MOD_AngelsRelics_story70"] = "SGS终将走向结束。50亿年后，太阳熄灭，世界也终会有一天迎来终结。",
	["#MOD_AngelsRelics_story71"] = "但是，至少一定不会是现在！",
	["#MOD_AngelsRelics_story72"] = "GK的阴谋，世界的存续。如果此时要我选择，我的心中一直都会只有这一个答案——",
	------------
	["$MOD_AngelsRelics_xrnsBuff_s_dmg"] = "因为<font color='purple'>“</font><font color='yellow'><b>夏尔诺斯之物</b></font>" ..
	"<font color='purple'>”</font>的效果，%from 的 %card 的伤害量+1。",
	["$MOD_AngelsRelics_xrnsBuff_s_rec"] = "因为<font color='purple'>“</font><font color='yellow'><b>夏尔诺斯之物</b></font>" ..
	"<font color='purple'>”</font>的效果，%from 的 %card 的回复量+1。",
	
	--==【里主线剧情】==--
	["MOD_AngelsRelics_hidden"] = "天使的遗物【里主线剧情】",
	--......
	--==================--
	--=============================================================================================================================================--
	
	--戴比特&基尔什塔利亚
	["Daybit_Kirschtaria"] = "戴比特＆基尔什塔利亚",
	["&Daybit_Kirschtaria"] = "天才组",
	["Daybit_Kirschtaria_tcz"] = "戴比特＆基尔什塔利亚",
	["&Daybit_Kirschtaria_tcz"] = "天才组",
	["#Daybit_Kirschtaria"] = "天之裂谷",
	["designer:Daybit_Kirschtaria"] = "时光流逝FC",
	["cv:Daybit_Kirschtaria"] = "无",
	["illustrator:Daybit_Kirschtaria"] = "兔ろうと(USAGIROUTO),网络",
	  --观测
	["dk_guance"] = "观测",
	["dk_guance_xy"] = "观测",
	["dk_guance_xyu"] = "观测",
	["dk_guance_xyu_useNoLimit"] = "观测",
	["dk_guance_xyu_useNoLimitt"] = "观测",
	[":dk_guance"] = "转换技，\
	①[极光]摸牌阶段，你可以放弃摸牌，改为观看牌堆顶的「7」张牌，获得其中的[2]张牌并将此次以此法获得牌的点数值之和记入“观测值”，其余牌以任意顺序置于牌堆顶或牌堆底。" ..
	"然后若此时你“观测值”的个位数为5，你摸两张牌并回复1点体力，且可以选择令此技能“「」”或“[]”中的数值+1(“[]”中的数值最大为7)。然后你清空“观测值”、转换状态；\
	②[星夜]出牌阶段限一次，你可以弃置两张手牌，观看牌堆顶的《7》张牌，获得其中的{2}张牌并将此次以此法获得牌的点数值之和记入“观测值”，其余牌以任意顺序置于牌堆顶或牌堆底。" ..
	"然后若此时你“观测值”的个位数为7，你展示一张基本或普通锦囊手牌并可以视为使用一张与之同名的牌（无距离限制且不计次），且可以选择令此技能“《》”或“{}”中的数值+1(“{}”中的数值最大为7)。然后你清空“观测值”、转换状态。",
	[":dk_guance1"] = "转换技，\
	①[极光]摸牌阶段，你可以放弃摸牌，改为观看牌堆顶的「7」张牌，获得其中的[2]张牌并将此次以此法获得牌的点数值之和记入“观测值”，其余牌以任意顺序置于牌堆顶或牌堆底。" ..
	"然后若此时你“观测值”的个位数为5，你摸两张牌并回复1点体力，且可以选择令此技能“「」”或“[]”中的数值+1(“[]”中的数值最大为7)。然后你清空“观测值”、转换状态；\
	<font color=\"#01A5AF\"><s>②[星夜]出牌阶段限一次，你可以弃置两张手牌，观看牌堆顶的《7》张牌，获得其中的{2}张牌并将此次以此法获得牌的点数值之和记入“观测值”，其余牌以任意顺序置于牌堆顶或牌堆底。" ..
	"然后若此时你“观测值”的个位数为7，你展示一张基本或普通锦囊手牌并可以视为使用一张与之同名的牌（无距离限制且不计次），且可以选择令此技能“《》”或“{}”中的数值+1(“{}”中的数值最大为7)。然后你清空“观测值”、转换状态。</s></font>",
	[":dk_guance2"] = "转换技，\
	<font color=\"#01A5AF\"><s>①[极光]摸牌阶段，你可以放弃摸牌，改为观看牌堆顶的「7」张牌，获得其中的[2]张牌并将此次以此法获得牌的点数值之和记入“观测值”，其余牌以任意顺序置于牌堆顶或牌堆底。" ..
	"然后若此时你“观测值”的个位数为5，你摸两张牌并回复1点体力，且可以选择令此技能“「」”或“[]”中的数值+1(“[]”中的数值最大为7)。然后你清空“观测值”、转换状态；</s></font>\
	②[星夜]出牌阶段限一次，你可以弃置两张手牌，观看牌堆顶的《7》张牌，获得其中的{2}张牌并将此次以此法获得牌的点数值之和记入“观测值”，其余牌以任意顺序置于牌堆顶或牌堆底。" ..
	"然后若此时你“观测值”的个位数为7，你展示一张基本或普通锦囊手牌并可以视为使用一张与之同名的牌（无距离限制且不计次），且可以选择令此技能“《》”或“{}”中的数值+1(“{}”中的数值最大为7)。然后你清空“观测值”、转换状态。",
	["dk_guancezhi"] = "观测值",
	["dk_guance:1"] = "令“观测”「」中的数值+1",
	["dk_guance:2"] = "令“观测” [] 中的数值+1",
	["dk_guance:3"] = "令“观测”《》中的数值+1",
	["dk_guance:4"] = "令“观测” {} 中的数值+1",
	["@dk_guance_xy-show"] = "请展示一张基本或普通锦囊手牌",
	["~dk_guance_xy"] = "然后可以视为使用一张与展示的牌同名的牌，无距离限制且不计次",
	["@dk_guance_xyu-touse"] = "你可以视为使用一张【<font color='yellow'><b>%src</b></font>】", --虚空印卡，最为致命
	["~dk_guance_xyu"] = "“我要去看许多美丽的事物。毕竟，我正是因此而诞生的。”",
	  --阵亡
	["~Daybit_Kirschtaria"] = "5分钟的天体观测。宛如，回到了年少时光......",
	["~Daybit_Kirschtaria_tcz"] = "5分钟的梦之回忆。再也，回不到年少时光......",
	--==背景故事==--
	--[[
	「抓紧时间，戴比特，这种好机会可不会再有了！」
	他喘息急促，
	用毫不掩饰期待与兴奋的声音呼唤着我。
	「不过，没想到接下来竟然会有5分钟的晴天啊！
	　这简直就像台风眼一样！」
	他从房间里飞奔而出的时候，
	正好撞上了走廊中的我，
	向我说明完情况，就直接拉着我的手跑了出去。
	无数光带悬挂在黑暗的天空中。
	而他始终一脸满足地看着空中弥漫的极光。
	快乐的感慨不仅仅是说给自己，
	也是送给身边的友人，
	与早已留在远方、但却始终不曾忘怀的
	小小的友人的礼物。
	「我要去看许多美丽的事物。
	　毕竟，我正是因此而诞生的。」
	“诞生”大概算是某种比喻吧。
	他的价值观或曾一度死去，随后又迎来新生。
	彼时诞生的欲望一直推动着他。
	理解到这一点以后，我也说出了自己的感想。
	我们说得起劲，聊起了梦想。
	虽然彼此的方法与思想都不同，
	但我们并没有否定对方，
	只是一起笑着说“要是能实现就好了啊”。
	5分钟的天体观测。
	宛如，回到了年少时光。
	]]
	----------------
	
	--<环境改造>包
	["MOD_EnvironmentRedevelop"] = "环境改造包",
	["MOD_EnvironmentRedevelop_END"] = "【结束改造】",
	["MOD_EnvironmentRedevelop_Return"] = "//返回到上一界面//",
	["MOD_EnvironmentRedevelop_forME"] = "后续的改造效果改为我一人独享",
	["MOD_EnvironmentRedevelop_forALL"] = "后续的改造效果改为全场共享",
	  --第一季
	["MOD_EnvironmentRedevelop_s1"] = "环境改造包（第一季）",
	["MOD_EnvironmentRedevelop_s1:1"] = "[家底]起始手牌+1(可叠加)",
	["MOD_EnvironmentRedevelop_s1:2"] = "[囤粮]手牌上限+1(可叠加)",
	["MOD_EnvironmentRedevelop_s1:3"] = "[英姿]摸牌阶段摸牌数+1(可叠加)",
	["MOD_EnvironmentRedevelop_s1:4"] = "[双刀]使用【杀】的次数上限+1(可叠加)",
	["MOD_EnvironmentRedevelop_s1:5"] = "[手长]使用【杀】的距离上限+1(可叠加)",
	["MOD_EnvironmentRedevelop_s1:6"] = "[兵分]使用【杀】的目标上限+1(可叠加)",
	["MOD_EnvironmentRedevelop_s1:7"] = "[重装]使用【杀】的伤害量+1(可叠加)",
	["MOD_EnvironmentRedevelop_s1:8"] = "[医术]使用【桃】的回复量+1(可叠加)",
	["MOD_EnvironmentRedevelop_s1:9"] = "[嗜酒]使用【酒】的次数上限+1(可叠加)",
	["MOD_EnvironmentRedevelop_s1:10"] = "[威震]使用红色【杀】无距离限制",
	["MOD_EnvironmentRedevelop_s1:11"] = "[渡劫]每轮开始时，依次执行一次【闪电】判定",
	["MOD_EnvironmentRedevelop_s1:12"] = "？？？", --🎁国庆小礼：使用或打出点数为10或1(A)的牌时，摸一张牌
	["ER_jiadi"] = "家底",
	["#ER_jiadi1"] = "本局游戏，全场的起始手牌+1",
	["#ER_jiadi2"] = "本局游戏，%from 的起始手牌+1",
	["ER_tunliang"] = "囤粮",
	["#ER_tunliang1"] = "本局游戏，全场的手牌上限+1",
	["#ER_tunliang2"] = "本局游戏，%from 的手牌上限+1",
	["ER_yingzi"] = "英姿",
	["#ER_yingzi1"] = "本局游戏，全场的摸牌阶段摸牌数+1",
	["#ER_yingzi2"] = "本局游戏，%from 的摸牌阶段摸牌数+1",
	["ER_shuangdao"] = "双刀",
	["#ER_shuangdao1"] = "本局游戏，全场使用【<font color='yellow'><b>杀</b></font>】的次数上限+1",
	["#ER_shuangdao2"] = "本局游戏，%from 使用【<font color='yellow'><b>杀</b></font>】的次数上限+1",
	["ER_shouchang"] = "手长",
	["#ER_shouchang1"] = "本局游戏，全场使用【<font color='yellow'><b>杀</b></font>】的距离上限+1",
	["#ER_shouchang2"] = "本局游戏，%from 使用【<font color='yellow'><b>杀</b></font>】的距离上限+1",
	["ER_bingfen"] = "兵分",
	["#ER_bingfen1"] = "本局游戏，全场使用【<font color='yellow'><b>杀</b></font>】的目标上限+1",
	["#ER_bingfen2"] = "本局游戏，%from 使用【<font color='yellow'><b>杀</b></font>】的目标上限+1",
	["ER_zhongzhuang"] = "重装",
	["#ER_zhongzhuang1"] = "本局游戏，全场使用【<font color='yellow'><b>杀</b></font>】的伤害量+1",
	["#ER_zhongzhuang2"] = "本局游戏，%from 使用【<font color='yellow'><b>杀</b></font>】的伤害量+1",
	["ER_yishu"] = "医术",
	["#ER_yishu1"] = "本局游戏，全场使用【<font color='yellow'><b>桃</b></font>】的回复量+1",
	["#ER_yishu2"] = "本局游戏，%from 使用【<font color='yellow'><b>桃</b></font>】的回复量+1",
	["ER_shijiu"] = "嗜酒",
	["#ER_shijiu1"] = "本局游戏，全场使用【<font color='yellow'><b>酒</b></font>】的次数上限+1",
	["#ER_shijiu2"] = "本局游戏，%from 使用【<font color='yellow'><b>酒</b></font>】的次数上限+1",
	["ER_weizhen"] = "威震",
	["#ER_weizhen1"] = "本局游戏，全场使用<font color='red'><b>红色</b></font>【<font color='yellow'><b>杀</b></font>】无距离限制",
	["#ER_weizhen2"] = "本局游戏，%from 使用<font color='red'><b>红色</b></font>【<font color='yellow'><b>杀</b></font>】无距离限制",
	["ER_dujie"] = "渡劫",
	["$ER_dujie"] = "（被自然之力选中，开始渡劫！）",
	["#ER_dujie1"] = "本局游戏，全场于每轮开始时依次执行一次【<font color='yellow'><b>闪电</b></font>】判定",
	["#ER_dujie2"] = "本局游戏，%from 于每轮开始时执行一次【<font color='yellow'><b>闪电</b></font>】判定",
	["ER_guoqing"] = "国庆快乐",
	["ER_guoqingDraw"] = "国庆小礼",
	["$ER_happyNationalDay"] = "祝大家2023国庆节快乐！游戏过程中，当大家使用或打出\
	  点数为10或A的牌时，将会摸一张牌作为奖励。",
	  --第二季
	["MOD_EnvironmentRedevelop_s2"] = "环境改造包（第二季）",
	
	  --（未完待续......）
	--
}
return {extension, extension_on}