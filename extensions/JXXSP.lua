module("extensions.JXXSP", package.seeall)
extension = sgs.Package("JXXSP")

JXXSPZhaoyun = sgs.General(extension, "JXXSPZhaoyun", "shu", "3", true)



LuaZhaoyunFG = sgs.CreateTargetModSkill{
        name = "LuaZhaoyunFG",
        frequency = sgs.Skill_NotFrequent,
        pattern = "Slash",
        extra_target_func = function(self, player, card)
            if player:hasSkill(self:objectName()) and card:isRed() then
                return 1
            else
                return 0
            end
        end,
        distance_limit_func = function(self, player,card)
            if player:hasSkill(self:objectName()) and card:isBlack() then
                return 1000
            else
                return 0
            end
        end,

        residue_func = function(self, player)
            if player:hasSkill(self:objectName()) then
                return 1
            else
                return 0
            end
        end,
    }

LuaJuecaiA = sgs.CreateTriggerSkill{
	name = "LuaJuecaiA",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damaged,sgs.HpRecover},
	on_trigger = function(self, event, player, data)
	local room = player:getRoom()
	if event == sgs.Damaged then
		local damage = data:toDamage()
		local victim = damage.to
		if damage then
			local list = room:findPlayersBySkillName(self:objectName())
			for _,p in sgs.qlist(list) do
			if not room:getCurrent():hasFlag(self:objectName()..p:objectName().."A") then
					if p:askForSkillInvoke(self:objectName(), data) then
					room:getCurrent():setFlags(self:objectName()..p:objectName().."A")
						room:broadcastSkillInvoke("LuaJuecaiA", math.random(1,5))
						--room:drawCards(p, 1)
                        p:drawCards(1, self:objectName())
						end
				end
			end
		end
	elseif event == sgs.HpRecover then
		local recover = data:toRecover()
		if recover then
			local room = player:getRoom()
			local list = room:findPlayersBySkillName(self:objectName())
			for _,p in sgs.qlist(list) do
				if p:canDiscard(player, "he") then --裸的
					if not room:getCurrent():hasFlag(self:objectName()..p:objectName().."B") then
						local dest = sgs.QVariant()
						dest:setValue(player)
						if p:askForSkillInvoke("LuaJuecaiB", dest) then
						room:getCurrent():setFlags(self:objectName()..p:objectName().."B")
							room:broadcastSkillInvoke("LuaJuecaiA",math.random(1,5))
							local id = room:askForCardChosen(p,player,"he","LuaJuecaiA")
							room:throwCard(id,player,p)
						end
					end
					end
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end
}


JXXSPZhaoyun:addSkill(LuaZhaoyunFG)
JXXSPZhaoyun:addSkill(LuaJuecaiA)

sgs.LoadTranslationTable{
--【武将相关】--

["JXXSP"]="界限☆SP",
["JXXSPZhaoyun"]="界限☆SP赵云",
["&JXXSPZhaoyun"]="赵云",
["#JXXSPZhaoyun"]="龙啸九天",
["designer:JXXSPZhaoyun"]="花飞羽落",
["cv:JXXSPZhaoyun"]="眼泪",
["illustrator:JXXSPZhaoyun"]="Feimo非墨",

["LuaZhaoyunFG"]="银枪",
[":LuaZhaoyunFG"]="你使用的红杀可以额外指定一个目标，你使用的黑杀无视距离，你可以额外使用一张杀。",
["LuaJuecaiA"]="绝才",
["LuaJuecaiB"]="绝才",
[":LuaJuecaiA"]="当一名角色恢复体力时，你可以弃置其一张牌，每个角色回合限一次；当一名角色受到伤害时，你可以摸一张牌，每个角色回合限一次。",


["$LuaZhaoyunFG1"]="龙啸九天，银枪破阵。",
["$LuaZhaoyunFG2"]="冲锋陷阵，谁与争锋。",
["$LuaJuecaiA1"]="破釜沉舟，背水一战。",
["$LuaJuecaiA2"]="此等把戏，不足为惧。",
["~JXXSPZhaoyun"]="孔明先生，子龙，尽力了......",
}