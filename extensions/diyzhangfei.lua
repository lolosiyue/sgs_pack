module("extensions.diyzhangfei", package.seeall)
extension = sgs.Package("diyzhangfei")

diyzhangfei = sgs.General(extension, "diyzhangfei", "shu", 4)

zfduanhecard = sgs.CreateSkillCard {
	name = "zfduanhe",
	will_throw = false,
	target_fixed = false,
	once = true,
	filter = function(self, targets, to_select, player)
		return #targets < 2 and to_select:objectName() ~= player:objectName()
	end,
	on_use = function(self, room, source, targets)
		local judge = sgs.JudgeStruct()
		judge.who = source
		judge.reason = "zfduanhe"
		judge.pattern = ".|heart"
		judge.good = false
		judge.play_animation = true
		room:judge(judge)
		if judge:isBad() and source:canDiscard(source, "he") then
			room:askForDiscard(source, "zfduanhe", 1, 1, false, true, "zfduanhe", ".")
		elseif judge:isGood() then
			for _, tg in ipairs(targets) do
				room:setPlayerMark(tg, "&zfduanhe+to+#" .. source:objectName().."-Clear", 1)
				room:setPlayerMark(tg, "@zfduanhe-Clear", 1)
				--room:setPlayerCardLimitation(tg, "use,response", "BasicCard", false)
			end
		end
	end,
}
zfduanhevs = sgs.CreateViewAsSkill {
	name = "zfduanhe",
	n = 0,
	view_as = function(self, cards)
		return zfduanhecard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#zfduanhe")
	end,
	enabled_at_response = function()
		return false
	end,
}
zfduanhe = sgs.CreateTriggerSkill {
	name = "zfduanhe",
	view_as_skill = zfduanhevs,
	events = { sgs.Damaged, sgs.EventPhaseStart },
	can_trigger = function()
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged then
			local damage = data:toDamage()
			if not damage.to or damage.to:isDead() then return false end
			for _, zhangfei in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				for _, mark in sgs.list(damage.to:getMarkNames()) do
					if string.find(mark, "&" .. self:objectName() .. "+to+#" .. zhangfei:objectName().."-Clear") and damage.to:getMark(mark) > 0 then
						room:setPlayerMark(damage.to, "&zfduanhe+to+#" .. zhangfei:objectName().."-Clear", 0)
						room:setPlayerMark(damage.to, "@zfduanhe-Clear", 0)
						--room:removePlayerCardLimitation(damage.to, "use,response", "BasicCard")
					end
				end
			end
		elseif event == sgs.EventPhaseStart and player:hasSkill(self:objectName()) and player:getPhase() == sgs.Player_NotActive then
			for _, to in sgs.qlist(room:getAlivePlayers()) do
				for _, mark in sgs.list(to:getMarkNames()) do
					if string.find(mark, "&" .. self:objectName() .. "+to+#" .. player:objectName().."-Clear") and to:getMark(mark) > 0 then
						room:setPlayerMark(to, "&zfduanhe+to+#" .. player:objectName().."-Clear", 0)
						room:setPlayerMark(to, "@zfduanhe-Clear", 0)
						--room:removePlayerCardLimitation(to, "use,response", "BasicCard")
					end
				end
			end
		end
	end,
}
zfduanhe_CardLimit = sgs.CreateCardLimitSkill{
	name = "#zfduanhe_CardLimit" ,
	limit_list = function(self,player)
		if player then 
			for _, mark in sgs.list(player:getMarkNames()) do
				if string.find(mark, "&zfduanhe+to+#") and player:getMark(mark) > 0 then
					return "use,response" end
				end
			end
		
			
	end,
	limit_pattern = function(self,player)
		if player then 
			for _, mark in sgs.list(player:getMarkNames()) do
				if string.find(mark, "&zfduanhe+to+#") and player:getMark(mark) > 0 then
					return "BasicCard" end
				end
			end
	end
}

diyzhangfei:addSkill(zfduanhe)
diyzhangfei:addSkill(zfduanhe_CardLimit)
extension:insertRelatedSkills("zfduanhe", "#zfduanhe_CardLimit")
sgs.LoadTranslationTable {
	["diyzhangfei"] = "张飞",

	["#diyzhangfei"] = "万夫莫敌",
	["zfduanhe"] = "断喝",
	[":zfduanhe"] = "<font color=\"green\"><b>出牌阶段限一次，</b></font>你可以指定至多两名其他角色，然后你进行一次判定，若判定结果为红桃，你弃置一张牌。否则，被指定的角色不能使用或打出基本牌，直到其受到一次伤害或你的回合结束。",
	["$zfduanhe1"] = "燕人张飞在此！",
	["$zfduanhe2"] = "手下败将，还敢负隅顽抗！",

	["designer:diyzhangfei"] = "wubuchenzhou",
}
