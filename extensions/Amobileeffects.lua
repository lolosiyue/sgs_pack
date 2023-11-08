extension = sgs.Package("mobileeffects", sgs.Package_GeneralPack)

--语音鉴赏（承载手杀特效的相关语音，可在武将一览界面中进行收听）
n_MEanjiang = sgs.General(extension, "n_MEanjiang", "god", 1, true, true)
--手杀特效--
n_mobile_effect = sgs.CreateTriggerSkill{
    name = "n_mobile_effect",
    global = true,
	priority = 9,
	events = {sgs.Damage, sgs.DamageComplete, sgs.EnterDying, sgs.GameOverJudge, sgs.EventPhaseStart},
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
		local function damage_effect(n)
			if n == 3 then
				room:doAnimate(2, "skill=Rampage:mbjs", "") --癫狂屠戮！
				room:broadcastSkillInvoke(self:objectName(), 1)
				room:getThread():delay(3325)
            elseif n >= 4 then
                room:doAnimate(2, "skill=Violence:mbjs", "") --无双！万军取首！
				room:broadcastSkillInvoke(self:objectName(), 2)
				room:getThread():delay(4000)
			end
		end
        if event == sgs.Damage then
            local damage = data:toDamage()
            if damage.from and damage.from:getMark("mobile_damage") == 0 then
				damage_effect(damage.damage)
			end
		elseif event == sgs.EnterDying then
			local damage = data:toDying().damage
            if damage and damage.from and damage.to:isAlive() then
				if damage.damage >= 3 then
					damage_effect(damage.damage)
					room:addPlayerMark(damage.from, "mobile_damage")
				end
			end
		elseif event == sgs.DamageComplete then
			local damage = data:toDamage()
			if damage.from then room:setPlayerMark(damage.from, "mobile_damage", 0) end
		elseif event == sgs.GameOverJudge then
            local current = room:getCurrent()
			room:addPlayerMark(current, "havekilled", 1)
			local x = current:getMark("havekilled")
			if not room:getTag("FirstBlood"):toBool() then
                room:setTag("FirstBlood", sgs.QVariant(true))
				room:doAnimate(2, "skill=FirstBlood:mbjs", "") --一破，卧龙出山！
				room:broadcastSkillInvoke(self:objectName(), 3)
				room:getThread():delay(2500)
			end
			if x == 2 then
                room:doAnimate(2, "skill=DoubleKill:mbjs", "") --双连，一战成名！
				room:broadcastSkillInvoke(self:objectName(), x + 2)
				room:getThread():delay(2800)
            elseif x == 3 then
                room:doAnimate(2, "skill=TripleKill:mbjs", "") --三连，举世皆惊！
				room:broadcastSkillInvoke(self:objectName(), x + 2)
				room:getThread():delay(2800)
            elseif x == 4 then
                room:doAnimate(2, "skill=QuadraKill:mbjs", "") --四连，天下无敌！
				room:broadcastSkillInvoke(self:objectName(), x + 2)
				room:getThread():delay(3500)
            elseif x >= 5 and x <= 7 then
                room:doAnimate(2, "skill=MoreKill:" .. x, "") --五连/六连/七连，诛天灭地！
				room:broadcastSkillInvoke(self:objectName(), x + 2)
				room:getThread():delay(4000)
            elseif x > 7 then --9人局/10人局
				room:doAnimate(2, "skill=MoreKill:" .. 7, "")
				room:broadcastSkillInvoke(self:objectName(), 9)
				room:getThread():delay(4000)
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_NotActive then
				room:setPlayerMark(player, "havekilled", 0)
			end
		end
    end,
}
--n_MEanjiang:addSkill(n_mobile_effect)

sgs.LoadTranslationTable{
    ["mobileeffects"] = "手杀特效",
	
	--语音鉴赏
	["n_MEanjiang"] = "语音鉴赏",
	  --手杀特效
	["n_mobile_effect"] = "手杀特效",
	["$n_mobile_effect1"] = "癫狂屠戮！",
	["$n_mobile_effect2"] = "无双！万军取首！",
	["$n_mobile_effect3"] = "一破，卧龙出山！",
	["$n_mobile_effect4"] = "双连，一战成名！",
	["$n_mobile_effect5"] = "三连，举世皆惊！",
	["$n_mobile_effect6"] = "四连，天下无敌！",
	["$n_mobile_effect7"] = "五连，诛天灭地！",
	["$n_mobile_effect8"] = "六连，诛天灭地！",
	["$n_mobile_effect9"] = "七连，诛天灭地！",
	
}
return {extension} 