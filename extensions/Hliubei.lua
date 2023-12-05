module("extensions.Hliubei", package.seeall)
extension = sgs.Package("Hliubei")
luaHliubei = sgs.General(extension, "luaHliubei$", "god", 4)
dj = sgs.CreateTriggerSkill {
	frequency = sgs.Skill_Frequent,
	name = "dj",
	events = { sgs.EventPhaseStart, sgs.FinishJudge },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local x = player:getLostHp()
		local w = 0
		if (event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Start) and (x >= 1) then
			while (player:askForSkillInvoke("dj")) do
				room:broadcastSkillInvoke("jijiang", math.random(1, 2))
				w = w + 1
				local judge = sgs.JudgeStruct()
				judge.pattern = "."
				judge.good = true
				judge.reason = "dj"
				judge.who = player
				room:judge(judge)
				if (w == x) then break end
			end
		end
		if (event == sgs.FinishJudge) then
			judge = data:toJudge()
			if (judge.reason == "dj") then
				room:setPlayerMark(player, self:objectName(), 1)
				if (judge.card:getSuit() == sgs.Card_Club) and (not player:hasSkill("paoxiao")) then
					room:acquireNextTurnSkills(player, self:objectName(), "paoxiao")
				end
				if (judge.card:getSuit() == sgs.Card_Spade) and (not player:hasSkill("liegong")) then
					if (judge.card:getNumber() <= 6) then
						room:acquireNextTurnSkills(player, self:objectName(), "liegong")
					elseif not player:hasSkill("tieji") then
						room:acquireNextTurnSkills(player, self:objectName(), "tieji")
					end
				end

				if (judge.card:getSuit() == sgs.Card_Heart) and (not player:hasSkill("wusheng")) then
					room:acquireNextTurnSkills(player, self:objectName(), "wusheng")
				end
				if (judge.card:getSuit() == sgs.Card_Diamond) and (not player:hasSkill("longdan")) then
					room:acquireNextTurnSkills(player, self:objectName(), "longdan")
				end
			end
		end
	end,
}
pj = sgs.CreateTriggerSkill {
	frequency = sgs.Skill_Frequent,
	name = "pj",
	events = { sgs.EventPhaseStart, sgs.FinishJudge },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local x = player:getLostHp()
		local w = 0
		if (event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Finish) and (x >= 1) then
			while (player:askForSkillInvoke("pj")) do
				room:broadcastSkillInvoke("rende")
				w = w + 1
				local judge = sgs.JudgeStruct()
				judge.pattern = "."
				judge.good = true
				judge.reason = "pj"
				judge.who = player
				room:judge(judge)
				if (w == x) then break end
			end
		end
		if (event == sgs.FinishJudge) then
			judge = data:toJudge()
			if (judge.reason == "pj") then
				room:setPlayerMark(player, self:objectName(), 1)
				if (judge.card:getSuit() == sgs.Card_Club) and (not player:hasSkill("kongcheng")) then
					room:acquireNextTurnSkills(player, self:objectName(), "kongcheng")
				end
				if (judge.card:getSuit() == sgs.Card_Spade) and (not player:hasSkill("wuyan")) then
					room:acquireNextTurnSkills(player, self:objectName(), "wuyan")
				end

				if (judge.card:getSuit() == sgs.Card_Heart) and (not player:hasSkill("enyuan")) then
					room:acquireNextTurnSkills(player, self:objectName(), "enyuan")
				end
				if (judge.card:getSuit() == sgs.Card_Diamond) and (not player:hasSkill("bazhen")) then
					room:acquireNextTurnSkills(player, self:objectName(), "bazhen")
				end
			end
		end
	end,
}
sgs.LoadTranslationTable {
	["Hliubei"] = "尘包",
	["luaHliubei"] = "刘备",
	["#luaHliubei"] = "蜀汉之主",
	["dj"] = "点将",
	[":dj"] = "回合开始时，若你已受伤，可以进行x次判定：♣~获得技能“咆哮”直到回合结束；♥~获得技能“武圣”直到回合结束；♦~获得技能“龙胆”直到回合结束；♠1~♠6获得技能“烈弓”直到回合结束 ；♠7~♠k获得技能“铁骑”（x为你已损失的体力值）。",
	["pj"] = "辅翼",
	[":pj"] = "回合结束时，若你已受伤，可以进行x次判定：♣~获得技能“空城”直到下回合开始；♥~获得技能“恩怨”直到下回合开始；♦~获得技能“八阵”直到下回合开始；♠~获得技能“无言”直到下回合开始（x为你已损失的体力值）。 ",
	["cv:luaHliubei"] = "",
	["designer:luaHliubei"] = "紫陌易尘",
	["~spmenghuo"] = "刘主阵亡",

}
luaHliubei:addSkill(dj)
luaHliubei:addSkill(pj)
luaHliubei:addRelateSkill("bazhen")
luaHliubei:addRelateSkill("wuyan")
luaHliubei:addRelateSkill("enyuan")
luaHliubei:addRelateSkill("kongcheng")
luaHliubei:addRelateSkill("longdan")
luaHliubei:addRelateSkill("wusheng")
luaHliubei:addRelateSkill("tieji")
luaHliubei:addRelateSkill("paoxiao")
luaHliubei:addRelateSkill("liegong")


return { extension }
