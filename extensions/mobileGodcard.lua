--游戏开始时，开启询问加入【神武将专属卡牌】的提示：
ngCRemoverAsk = sgs.CreateTriggerSkill{
    name = "ngCRemoverAsk",
	global = true,
	priority = 100,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DrawInitialCards},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:addPlayerMark(player, self:objectName())
	end,
	can_trigger = function(self, player)
	    return player:getState() == "online"
	end,
}
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("ngCRemoverAsk") then skills:append(ngCRemoverAsk) end

sgs.Sanguosha:addSkills(skills)
sgs.LoadTranslationTable{
    ["ngCRemoverAsk"] = "",
}