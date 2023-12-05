module("extensions.jz", package.seeall)
extension = sgs.Package("jz")
jz = sgs.General(extension, "jz", "shu", "4")
cuoyong = sgs.CreateTriggerSkill {
	name = "cuoyong",
	frequency = sgs.Skill_Frequent,
	events = { sgs.DrawNCards },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local n = math.min(player:getLostHp(), 2)
		if player:isWounded() then
			if room:askForSkillInvoke(player, "cuoyong", data) then
				local count = data:toInt() + n
				room:broadcastSkillInvoke("juejing")
				data:setValue(count)
			end
		end
	end
}
jz:addSkill(cuoyong)
jz:addSkill("longdan")
sgs.LoadTranslationTable {
	["jz"] = "赵云",
	["#jz"] = "顺平侯",
	["cuoyong"] = "挫勇",
	[":cuoyong"] = "摸牌阶段，你可额外摸X张牌（X为你已损失的体力值且至多为2） ",
	["$cuoyong"] = "龙战于野，其血玄黄",
	["$cuoyong2"] = "",
	["designer:jz"] = "轩辕夜",
	["cv:jz"] = "官方",
	["illustrator:jz"] = "官方",
}
return { extension }
