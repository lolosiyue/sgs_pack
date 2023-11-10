extension = sgs.Package("mobileeffectst", sgs.Package_GeneralPack)
extension_x = sgs.Package("mobileeffectst_on", sgs.Package_CardPack)
--语音鉴赏2（承载手杀特效的相关语音，可在武将一览界面中进行收听）
f_MEanjiang = sgs.General(extension, "f_MEanjiang", "god", 1, true, true)
--手杀特效2：医术高超、妙手回春--
f_mobile_effect = sgs.CreateTriggerSkill{
    name = "f_mobile_effect",
    global = true,
	priority = {-9, -9, -9, -9},
	events = {sgs.HpRecover, sgs.PreHpRecover, sgs.QuitDying, sgs.EventPhaseChanging},
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
		local recover = data:toRecover()
		if event == sgs.HpRecover then
			if recover.who and recover.who:objectName() == player:objectName()
			and recover.card and recover.card:isKindOf("Peach")
			and player:getPhase() ~= sgs.Player_NotActive then
				local rec = recover.recover
				room:addPlayerMark(player, "f_YSGC", rec)
				if player:getMark("f_YSGC") >= 3 then
					room:setPlayerMark(player, "f_YSGC", 0)
					--医术高超
					room:broadcastSkillInvoke(self:objectName(), 1)
					room:doLightbox("f_mobile_effect_YSGC")
				end
			end
		elseif event == sgs.PreHpRecover then
			if recover.who and recover.who:objectName() ~= player:objectName()
			and recover.card and recover.card:isKindOf("Peach")
			and player:hasFlag("Global_Dying") then
				room:addPlayerMark(recover.who, "f_MSHCfor+" .. player:objectName())
			end
		elseif event == sgs.QuitDying then
			local dying = data:toDying()
			if dying.who and dying.who:objectName() == player:objectName() then
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:getMark("f_MSHCfor+" .. player:objectName()) >= 3 then
						room:setPlayerMark(p, "f_MSHCfor+" .. player:objectName(), 0)
						--妙手回春
						room:broadcastSkillInvoke(self:objectName(), 2)
						room:doLightbox("f_mobile_effect_MSHC")
						break
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, "f_YSGC", 0)
			end
		end
    end,
	can_trigger = function(self, player)
		return player
	end,
}
f_MEanjiang:addSkill(f_mobile_effect)

--手杀互动：砸蛋（包括扔拖鞋）、送花--
f_mobile_efs = sgs.CreateTriggerSkill{
	name = "f_mobile_efs",
	global = true,
	priority = {100, 100, 100},
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.GameStart, sgs.Dying, sgs.Death, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if table.contains(sgs.Sanguosha:getBanPackages(), "extension_x") then return false end
		if event == sgs.GameStart then --游戏开始时给按钮
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if not p:hasSkill("f_mobile_efs_egg") then
					room:attachSkillToPlayer(p, "f_mobile_efs_egg")
				end
				room:setPlayerMark(p, "f_mobile_efs_egg", 10)
				--
				if not p:hasSkill("f_mobile_efs_flower") then
					room:attachSkillToPlayer(p, "f_mobile_efs_flower")
				end
				room:setPlayerMark(p, "f_mobile_efs_flower", 1)
			end
		elseif event == sgs.Dying or event == sgs.Death then --进入濒死、死亡时询问发动砸蛋/送花
			if event == sgs.Dying then
				local dying = data:toDying()
				--if dying.who:objectName() ~= player:objectName() then return false end
				local onlines = 0
				for _, q in sgs.qlist(room:getAllPlayers()) do
					if q:getState() == "online" then
						onlines = onlines + 1
					end
				end
				if onlines < 2 then return false end
				if player:getSeat() == 1 then
					for _, p in sgs.qlist(room:getAllPlayers()) do
						if p:getState() ~= "online" or p:hasFlag("f_mobile_efs_DyingUsed") then continue end
						if not room:askForSkillInvoke(p, "@f_mobile_efs_d", ToData("interaction")) then continue end
						room:setPlayerFlag(p, "f_mobile_efs_DyingUsed")
						local choices = {"f_mobile_efs_egg", "f_mobile_efs_flower", "cancel"}
						local n = 2
						while n > 0 do
							local choice = room:askForChoice(p, self:objectName(), table.concat(choices, "+"))
							if choice == "cancel" then n = 0 break end
							if choice == "f_mobile_efs_egg" then
								room:askForUseCard(p, "@@f_mobile_efs_egg", "@f_mobile_efs_egg")
								table.removeOne(choices, "f_mobile_efs_egg")
							elseif choice == "f_mobile_efs_flower" then
								room:askForUseCard(p, "@@f_mobile_efs_flower", "@f_mobile_efs_flower")
								table.removeOne(choices, "f_mobile_efs_flower")
							end
							n = n - 1
						end
					end
				end
			else
				local death = data:toDeath()
				if death.who:objectName() ~= player:objectName() or player:getState() == "robot" then return false end
				if not room:askForSkillInvoke(player, "@f_mobile_efs_d", ToData("interaction")) then return false end
				local choices = {"f_mobile_efs_egg", "f_mobile_efs_flower", "cancel"}
				local n = 2
				while n > 0 do
					local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
					if choice == "cancel" then n = 0 break end
					if choice == "f_mobile_efs_egg" then
						room:askForUseCard(player, "@@f_mobile_efs_egg", "@f_mobile_efs_egg")
						table.removeOne(choices, "f_mobile_efs_egg")
					elseif choice == "f_mobile_efs_flower" then
						room:askForUseCard(player, "@@f_mobile_efs_flower", "@f_mobile_efs_flower")
						table.removeOne(choices, "f_mobile_efs_flower")
					end
					n = n - 1
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("f_mobile_efs_DyingUsed") then
					room:setPlayerFlag(p, "-f_mobile_efs_DyingUsed")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_MEanjiang:addSkill(f_mobile_efs)
--

--砸蛋
f_mobile_efs_eggCard = sgs.CreateSkillCard{
	name = "f_mobile_efs_eggCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return true
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		local self_tz = false
		local m = 0
		for _, p in pairs(targets) do
			m = m + 1
			if source:objectName() == p:objectName() then
				m = m - 1
				self_tz = true
				table.removeOne(targets, p)
			end
		end
		if self_tz then
			local choice = room:askForChoice(source, "f_mobile_efs_egg", "1+2+3+4+5+none")
			if choice == "1" then
				room:setPlayerMark(source, "f_mobile_efs_egg", 1)
			elseif choice == "2" then
				room:setPlayerMark(source, "f_mobile_efs_egg", 5)
			elseif choice == "3" then
				room:setPlayerMark(source, "f_mobile_efs_egg", 10)
			elseif choice == "4" then
				room:setPlayerMark(source, "f_mobile_efs_egg", 20)
			elseif choice == "5" then
				room:setPlayerMark(source, "f_mobile_efs_egg", 50)
			end
		end
		local n = source:getMark("f_mobile_efs_egg")
		while n > 0 do
			for _, p in pairs(targets) do
				if math.random() <= 0.5 then room:broadcastSkillInvoke("f_mobile_efs", 1)
				else room:broadcastSkillInvoke("f_mobile_efs", 2) end
				room:setEmotion(p, "xys_egg")
				if source:getMark("f_mobile_efs_egg") > 1 then
					if m >= 5 then
						room:getThread():delay(25)
					elseif m > 2 and m < 5 then
						room:getThread():delay(50)
					else
						room:getThread():delay(75)
					end
				else
					room:getThread():delay(75)
				end
			end
			n = n - 1
		end
		--追加扔拖鞋
		if source:getMark("f_mobile_efs_egg") > 1 then
			for _, p in pairs(targets) do
				room:broadcastSkillInvoke("f_mobile_efs", 5)
				room:setEmotion(p, "xys_shoe")
			end
		end
	end,
}
f_mobile_efs_egg = sgs.CreateZeroCardViewAsSkill{
	name = "f_mobile_efs_egg&",
	view_as = function()
		return f_mobile_efs_eggCard:clone()
	end,
	enabled_at_play = function(self, player)
		return true
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@f_mobile_efs_egg" --[[or (pattern == "slash" or pattern == "jink"
		or string.find(pattern, "peach") or pattern == "nullification")]]
	end,
}
--送花
f_mobile_efs_flowerCard = sgs.CreateSkillCard{
	name = "f_mobile_efs_flowerCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return true
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		local self_tz = false
		for _, p in pairs(targets) do
			if source:objectName() == p:objectName() then
				self_tz = true
				table.removeOne(targets, p)
			end
		end
		if self_tz then
			local choice = room:askForChoice(source, "f_mobile_efs_flower", "1+2+3+4+5+none")
			if choice == "1" then
				room:setPlayerMark(source, "f_mobile_efs_flower", 1)
			elseif choice == "2" then
				room:setPlayerMark(source, "f_mobile_efs_flower", 5)
			elseif choice == "3" then
				room:setPlayerMark(source, "f_mobile_efs_flower", 10)
			elseif choice == "4" then
				room:setPlayerMark(source, "f_mobile_efs_flower", 20)
			elseif choice == "5" then
				room:setPlayerMark(source, "f_mobile_efs_flower", 50)
			end
		end
		local n = source:getMark("f_mobile_efs_flower")
		while n > 0 do
			for _, p in pairs(targets) do
				if math.random() <= 0.5 then room:broadcastSkillInvoke("f_mobile_efs", 3)
				else room:broadcastSkillInvoke("f_mobile_efs", 4) end
				room:setEmotion(p, "xys_flower")
				room:getThread():delay(75)
			end
			n = n - 1
		end
	end,
}
f_mobile_efs_flower = sgs.CreateZeroCardViewAsSkill{
	name = "f_mobile_efs_flower&",
	view_as = function()
		return f_mobile_efs_flowerCard:clone()
	end,
	enabled_at_play = function(self, player)
		return true
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@f_mobile_efs_flower" --[[or (pattern == "slash" or pattern == "jink"
		or string.find(pattern, "peach") or pattern == "nullification")]]
	end,
}
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("f_mobile_efs_egg") then skills:append(f_mobile_efs_egg) end
if not sgs.Sanguosha:getSkill("f_mobile_efs_flower") then skills:append(f_mobile_efs_flower) end

--属性特殊音效（包括酒杀）--
f_mobile_nature = sgs.CreateTriggerSkill{
    name = "f_mobile_nature",
    global = true,
	priority = {-3000, -3000},
	events = {sgs.PreCardUsed, sgs.PreDamageDone},
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
		local damage = data:toDamage()
		if event == sgs.PreCardUsed then
			local use = data:toCardUse()
			if use.card and use.from and use.from:objectName() == player:objectName() then
				if use.card:isKindOf("FireSlash") then
					room:broadcastSkillInvoke(self:objectName(), 1)
				elseif use.card:isKindOf("ThunderSlash") then
					room:broadcastSkillInvoke(self:objectName(), 2)
				elseif use.card:isKindOf("IceSlash") then
					room:broadcastSkillInvoke(self:objectName(), 3)
				end
			end
		elseif event == sgs.PreDamageDone then
			if damage.to and damage.to:objectName() == player:objectName() and damage.damage > 0 then
				if player:getHujia() == 0 then
					if damage.damage == 1 then
						if damage.nature == sgs.DamageStruct_Fire then
							room:broadcastSkillInvoke(self:objectName(), 4)
						elseif damage.nature == sgs.DamageStruct_Thunder then
							room:broadcastSkillInvoke(self:objectName(), 6)
						elseif damage.nature == sgs.DamageStruct_Ice then
							room:broadcastSkillInvoke(self:objectName(), 8)
						else
							sgs.Sanguosha:playAudioEffect("audio/skill/f_normal_injure1.ogg", true)
						end
					elseif damage.damage > 1 then
						if damage.nature == sgs.DamageStruct_Fire then
							room:broadcastSkillInvoke(self:objectName(), 5)
						elseif damage.nature == sgs.DamageStruct_Thunder then
							room:broadcastSkillInvoke(self:objectName(), 7)
						elseif damage.nature == sgs.DamageStruct_Ice then
							room:broadcastSkillInvoke(self:objectName(), 9)
						else
							if damage.damage == 2 then
								sgs.Sanguosha:playAudioEffect("audio/skill/f_normal_injure2.ogg", true)
							else
								sgs.Sanguosha:playAudioEffect("audio/skill/f_normal_injure3.ogg", true)
							end
						end
					end
					if damage.nature == sgs.DamageStruct_Poison then
						if player:isMale() then
							room:broadcastSkillInvoke(self:objectName(), 10)
						elseif player:isFemale() then
							room:broadcastSkillInvoke(self:objectName(), 11)
						end
					end
				else
					if damage.damage == 1 then
						if damage.nature == sgs.DamageStruct_Fire then
							room:broadcastSkillInvoke(self:objectName(), 13)
						elseif damage.nature == sgs.DamageStruct_Thunder then
							room:broadcastSkillInvoke(self:objectName(), 15)
						else
							room:broadcastSkillInvoke(self:objectName(), 17)
						end
					elseif damage.damage > 1 then
						if damage.nature == sgs.DamageStruct_Fire then
							room:broadcastSkillInvoke(self:objectName(), 14)
						elseif damage.nature == sgs.DamageStruct_Thunder then
							room:broadcastSkillInvoke(self:objectName(), 16)
						else
							room:broadcastSkillInvoke(self:objectName(), 18)
						end
					end
				end
				if damage.card and damage.card:isKindOf("Slash") and damage.card:hasFlag("drank") then --酒杀
					room:broadcastSkillInvoke(self:objectName(), 12)
				end
			end
		end
    end,
	can_trigger = function(self, player)
		return player
	end,
}
f_MEanjiang:addSkill(f_mobile_nature)

--死亡之声--
f_mobile_death = sgs.CreateTriggerSkill{
    name = "f_mobile_death",
    global = true,
	priority = 9000,
	events = {sgs.GameOverJudge},
    on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_MEanjiang:addSkill(f_mobile_death)

--==【ai聊天扩展包】(不断更新)==--
local function isSpecialOne(player, name)
	local g_name = sgs.Sanguosha:translate(player:getGeneralName())
	if string.find(g_name, name) then return true end
	if player:getGeneral2() then
		g_name = sgs.Sanguosha:translate(player:getGeneral2Name())
		if string.find(g_name, name) then return true end
	end
	return false
end
f_mobile_chat_normal = sgs.CreateTriggerSkill{
    name = "f_mobile_chat_normal",
    global = true,
	events = {sgs.EventPhaseStart, sgs.SlashMissed, sgs.CardUsed, sgs.Damaged, sgs.Dying, sgs.AskForPeachesDone, sgs.Death, sgs.Revive, sgs.CardFinished, sgs.EventPhaseChanging},
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			--武将可能随机播报自己的技能语音(不适用单语音技能或超过四个语音的技能)
			if math.random() > 0.99 then --概率控死，不然过吵了就不好了
				local otrs = {}
				for _, p in sgs.qlist(room:getAllPlayers()) do
					table.insert(otrs, p)
				end
				local otr = otrs[math.random(1, #otrs)]
				local skill_names = {}
				for _, skill in sgs.qlist(otr:getVisibleSkillList()) do
					table.insert(skill_names, skill:objectName())
				end
				if #skill_names > 0 then
					local broadcast = skill_names[math.random(1, #skill_names)]
					local bc = math.random(0,3)
					if bc > 0 then
						local x, n = math.random(1,2), math.random(1,5)
						otr:speak("$" .. broadcast .. ":" .. x)
						if n == 1 then room:broadcastSkillInvoke(broadcast, x) end
					else
						local y, m = math.random(1,4), math.random(1,5)
						otr:speak("$" .. broadcast .. ":" .. y)
						if m == 1 then room:broadcastSkillInvoke(broadcast, y) end
					end
				end
			end
			if player:getPhase() == sgs.Player_RoundStart then
				local jb = math.random(1,100)
				if jb >= 95 then
					local otrs = {}
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						table.insert(otrs, p)
					end
					local otr = otrs[math.random(1, #otrs)]
					if isSpecialOne(player, "zy") or isSpecialOne(player, "ZY") then
						otr:speak("" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，你就是鸽78")
					else
						if player:isMale() then
							if player:getWeapon() ~= nil then
								otr:speak("" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，你就是个戟把")
							else
								local jbs = math.random(0,3) --继续压概率
								if jbs == 0 then
									otr:speak("" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，你就是个寄吧")
								elseif jbs == 1 then
									player:speak("吾儿" .. sgs.Sanguosha:translate(otr:getGeneralName()) .. "何在？")
								elseif jbs == 2 then
									local gz = math.random(0,2)
									if gz == 0 then
										otr:speak("十夫长" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，出列！跪下！")
									elseif gz == 1 then
										otr:speak("百夫长" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，出列！稍息！")
									elseif gz == 2 then
										otr:speak("" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，你这校尉还真是有意思")
									end
								elseif jbs == 3 then
									if otr:getKingdom() == "wei" then
										otr:speak("" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，到许昌了指定没你好果汁吃嗷")
									elseif otr:getKingdom() == "shu" then
										otr:speak("" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，到成都了指定没你好果汁吃嗷")
									elseif otr:getKingdom() == "wu" then
										otr:speak("" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，到建业了指定没你好果汁吃嗷")
									elseif isSpecialOne(otr, "董卓") then
										otr:speak("" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，到长安了指定没你好果汁吃嗷")
									else
										otr:speak("" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，到洛阳了指定没你好果汁吃嗷")
									end
								end
							end
						else
							otr:speak("" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，你就是歌姬吧")
						end
					end
				elseif jb <= 5 then
					local dlxy = math.random(1,100)
					if dlxy >= 87 then
						player:speak("OK兄弟们，全体目光向我看齐嗷")
					elseif dlxy <= 13 then
						player:speak("看我看我，我宣布个事儿：我就是个_ _")
					end
				end
				if player:isFemale() and math.random() > 0.97 then --七夕特辑！
					local males = {}
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if p:isMale() then
							table.insert(males, p)
						end
					end
					if #males > 0 then
						local male = males[math.random(1, #males)]
						local loves = {"我爱你，" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，嫁给我吧",
						"" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，我和你缠缠绵绵翩翩飞，飞跃这红尘永相随",
						"" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，怎么冷酷却仍然美丽，得不到的，从来矜贵",
						"" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，即使恶梦你仍然绮丽，甘心垫底，衬你的高贵",
						"" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，我要变成童话里，你爱的那个天使",
						"" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，我爱你，爱着你，就像老鼠爱大米",
						"" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，你说你，想要逃，偏偏注定要落脚",
						"" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，忘记你我做不到，不去天涯海角......",
						"" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，好想好想，和你在一起......",
						"" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，我们的爱，过了就不再回来......",
						"" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，你是如此的难以忘记，浮浮沉沉的在我心里",
						"" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，你喜欢大海，我爱过你",
						"" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，我好不容易心动一次，你却让我输得这么彻底，呵哈哈哈哈哈......",
						"" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，我们的关系进一步没资格......",
						"关关雎鸠，在河之洲；窈窕淑女，君子好逑。",
						"爱恨情仇一念生一念灭！岁月如花一边开一边谢~",
						"袖中的剑，指间的刀，无法割断，尘世中情怨~",
						"忘川的水，彼岸的花，无法阻挡轮回千年修的姻缘~",
						"情缘的茧，时光的沙，无法隔绝，我对你思念~",
						"饮尽桃花树下埋好的醉，忘记梦里遭遇了谁~",
						"都说人生难免波折吊诡，我与我周旋又落下眼泪~",
						"我藏起一切炫耀的美，用灵魂赌一场爱的纯粹~"
						}
						local love = loves[math.random(1, #loves)]
						male:speak(love)
					end
				end
			end
		elseif event == sgs.SlashMissed then
			local effect = data:toSlashEffect()
			if effect.from and effect.to and player:getMark("SlashMissed_ji") < 3 then
				if math.random() > 0.9 then
					local jz = math.random(0,1)
					if jz > 0 then
						effect.to:speak("就这？就这？")
					else
						effect.to:speak("" .. sgs.Sanguosha:translate(player:getGeneralName()) .. "，就这啊？")
					end
				end
				room:addPlayerMark(player, "SlashMissed_ji")
			end
			if effect.from and effect.to and player:getMark("SlashMissed_ji") >= 3 then
				room:setPlayerMark(player, "SlashMissed_ji", 0)
				local jl = math.random(0,1)
				if jl > 0 then
					effect.to:speak("急了，急了")
				else
					effect.to:speak("你看，又急")
				end
			end
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card and (use.card:objectName() == "peach" or use.card:objectName() == "ex_nihilo" or use.card:objectName() == "dongzhuxianji") then
				room:addPlayerMark(player, "kaile_" .. use.card:objectName())
				if player:getMark("kaile_" .. use.card:objectName()) >= 3 then
					room:setPlayerMark(player, "kaile_" .. use.card:objectName(), 0)
					local otrs = {}
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						table.insert(otrs, p)
					end
					local otr = otrs[math.random(1, #otrs)]
					otr:speak("开了？")
					if #otrs > 1 then table.removeOne(otrs, otr) end
					if math.random() > 0.8 then
						local otrr = otrs[math.random(1, #otrs)]
						otrr:speak("关了吧，没意思")
					end
				end
			end
			if use.card and use.card:isKindOf("Collateral") and math.random() > 0.95 then
				for _, p in sgs.qlist(use.to) do
					p:speak("你在教我做事？")
					break
				end
			end
			if use.card and use.card:isKindOf("Duel") and math.random() > 0.9 then
				room:setPlayerFlag(player, "lzgsm")
			end
		elseif event == sgs.Damaged then
			local damage = data:toDamage()
			if damage.to:objectName() == player:objectName() and damage.from and damage.from:objectName() ~= player:objectName() then
				room:addPlayerMark(player, "nglmy_" .. damage.from:objectName(), damage.damage)
			end
			if damage.to:objectName() == player:objectName() and player:hasFlag("lzgsm")
			and damage.from and damage.from:objectName() ~= player:objectName() then
				room:setPlayerFlag(player, "-lzgsm")
				damage.from:speak("李在赣神魔")
			end
			if damage.to:objectName() == player:objectName() and damage.damage > 2 and math.random() > 0.95 then
				player:speak("6")
			end
		elseif event == sgs.Dying then
			local dying = data:toDying()
			if dying.who:objectName() == player:objectName() and player:getHp() < 0 and player:getHandcardNum() < 3
			and math.random() > 0.95 then
				p:speak("完了，芭比Q了")
			end
		elseif event == sgs.AskForPeachesDone then
			local dying = data:toDying()
			if dying.who:objectName() == player:objectName() and player:getHp() <= 0
			and dying.damage and dying.damage.from and dying.damage.from:objectName() ~= player:objectName() then
				if dying.damage.from:getMark("nglmy_" .. player:objectName()) >= 3 then
					room:removePlayerMark(dying.damage.from, "nglmy_" .. player:objectName(), 3)
					dying.damage.from:speak("闹够了没有")
				end
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() == player:objectName() and (player:getRoleEnum() == "rebel" or player:getRoleEnum() == "renegade")
			and death.damage.from and death.damage.from:objectName() ~= player:objectName() and math.random() > 0.95 then
				death.damage.from:speak("任何邪恶，终将绳之以法！")
			end
		elseif event == sgs.Revive then
			if player:isFemale() then
				local males = {}
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:isMale() then
						table.insert(males, p)
					end
				end
				if #males > 0 then
					local male = males[math.random(1, #males)]
					male:speak("复活吧，我的爱人！")
				end
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.card and use.card:isKindOf("Duel") and player:hasFlag("lzgsm") then
				room:setPlayerFlag(player, "-lzgsm")
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					room:setPlayerMark(p, "SlashMissed_ji", 0)
					room:setPlayerMark(p, "kaile_peach", 0)
					room:setPlayerMark(p, "kaile_ex_nihilo", 0)
					room:setPlayerMark(p, "kaile_dongzhuxianji", 0)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}






--

f_mobile_chat_general = sgs.CreateTriggerSkill{
    name = "f_mobile_chat_general",
    global = true,
	events = {sgs.CardUsed, sgs.CardResponded, sgs.SlashMissed, sgs.TurnStart, sgs.EventPhaseStart, sgs.Damage, sgs.Damaged, sgs.Dying, sgs.Death, sgs.GameStart},
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card and use.card:getSkillName() == "tenyearzhiheng" then
				local qcsj = math.random(0,15)
				local qcsjj = math.random(1,5)
				if qcsj == 0 then
					if qcsjj == 1 then player:speak("感觉不如界孙权，精品第一、史诗质检员")
					elseif qcsjj == 2 then player:speak("回合内小制衡找顺拆卡距离随便打")
					elseif qcsjj == 3 then player:speak("不好打的制衡找无懈闪桃")
					elseif qcsjj == 4 then player:speak("下回合找顺拆继续打")
					elseif qcsjj == 5 then player:speak("对爆也是界权优") end
				elseif qcsj == 1 then
					if qcsjj == 1 then player:speak("君言甚妙，但余窃以为差界权甚矣")
					elseif qcsjj == 2 then player:speak("全扩之鳌首、阴间之巅峰")
					elseif qcsjj == 3 then player:speak("待大制衡神技，顺拆乐马五中等尽入囊中")
					elseif qcsjj == 4 then player:speak("卡敌之距离，去敌之珍牌")
					elseif qcsjj == 5 then player:speak("神郭、神荀、神甘俯首帖耳，\
					况区区文鸯、大宝、杨彪、杜预之流！") end
				elseif qcsj == 2 then
					if qcsjj == 1 then player:speak("卿言是，然知不若界权")
					elseif qcsjj == 2 then player:speak("于精品榜首，乃史诗之质检")
					elseif qcsjj == 3 then player:speak("自回合内彼伺其技大制衡")
					elseif qcsjj == 4 then player:speak("寻顺拆，卡敌之击距，轻肆殴之")
					elseif qcsjj == 5 then player:speak("与敌之多力，权仍胜之") end
				elseif qcsj == 3 then
					if qcsjj == 1 then player:speak("你说对，但不如，界孙权")
					elseif qcsjj == 2 then player:speak("精品中，数第一，史诗将，质检员")
					elseif qcsjj == 3 then player:speak("大制衡，找拆牵，卡距离，随便打")
					elseif qcsjj == 4 then player:speak("如不行，找闪桃，下回合，继续打")
					elseif qcsjj == 5 then player:speak("对爆时，权亦优") end
				end
			end
			if use.card and use.card:isKindOf("Slash") and isSpecialOne(player, "法正") and use.to:length() == 1 and math.random() > 0.85 then
				local zjgbs = math.random(0,1)
				if zjgbs > 0 then
					player:speak("再叫")
				else
					player:speak("狗再叫")
				end
				room:getThread():delay()
				for _, p in sgs.qlist(use.to) do
					p:speak("狗别怂")
				end
			end
		elseif event == sgs.CardResponded then
			local resp = data:toCardResponse()
			if resp.m_card and resp.m_card:isKindOf("Jink") then
				if ((isSpecialOne(player, "郭嘉") and not isSpecialOne(player, "神郭嘉"))
				or (isSpecialOne(player, "荀彧") and not isSpecialOne(player, "神荀彧")))
				and math.random() > 0.85 then
					player:speak("没事掉什么血")
				end
			end
		elseif event == sgs.SlashMissed then
			local effect = data:toSlashEffect()
			if effect.from and isSpecialOne(player, "刘备") and not isSpecialOne(player, "神刘备")
			and effect.to and isSpecialOne(effect.to, "荀彧") and not isSpecialOne(effect.to, "神荀彧")
			and player:getRoleEnum() == effect.to:getRoleEnum() and math.random() > 0.5 then
				effect.to:speak("杀队友能赢？")
			end
		elseif event == sgs.TurnStart then
			if (player:getGeneralName() == "nos_luxun" or player:getGeneral2Name() == "nos_luxun") and not player:isLord() and math.random() > 0.666 then
				player:speak("我觉得当忠臣，个人能力要强")
			end
			if isSpecialOne(player, "钟会") and not player:isLord() and math.random() > 0.85 then
				local dl = math.random(0,10)
				if dl > 6 then
					player:speak("像我这样个人能力强的忠臣，主公打着灯笼都找不到")
				else
					player:speak("我这种个人能力强的忠臣你上哪找？")
				end
			end
			if player:getGeneralName() ~= "machao" and player:getGeneral2Name() ~= "machao" then
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					local jhc = math.random(0,10)
					if jhc == 0 and isSpecialOne(p, "曹冲") then
						p:speak("界马超摧毁一切，每次碰到棘手局面就特别怀念马超")
					elseif jhc == 1 and (p:getGeneralName() == "machao" or p:getGeneral2Name() == "machao") then
						p:speak("马超就是神")
					elseif jhc == 2 and (p:getGeneralName() == "machao" or p:getGeneral2Name() == "machao") then
						p:speak("选马超单纯因为强度高")
					elseif jhc == 3 and isSpecialOne(p, "张角") and not isSpecialOne(p, "神张角") then
						p:speak("为什么不用马超")
					end
				end
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				if (player:getGeneralName() == "xizhicai" or player:getGeneral2Name() == "xizhicai")
				and player:getMark("gxc_wms") == 0 and math.random() > 0.3 then
					local gj, cr = 0, 0
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if p:getGeneralName() == "nos_guojia" or p:getGeneral2Name() == "nos_guojia" then
							gj = gj + 1
						end
						if isSpecialOne(p, "曹叡") then
							cr = cr + 1
						end
					end
					if gj >= 1 and cr >= 1 then
						local nos_guojias = {}
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							if p:getGeneralName() == "nos_guojia" or p:getGeneral2Name() == "nos_guojia" then
								table.insert(nos_guojias, p)
							end
						end
						local nos_guojia = nos_guojias[math.random(1, #nos_guojias)]
						nos_guojia:speak("咱们三人太强了")
						room:getThread():delay()
						player:speak("你强nmlgb")
						room:addPlayerMark(player, "gxc_wms")
					end
				end
				if isSpecialOne(player, "马忠") and player:getKingdom() == "shu" and math.random() > 0.8 then
					player:speak("这把稳了")
				end
				if player:hasSkill("bazhen") and player:getArmor() ~= nil and player:getArmor():isKindOf("SilverLion") and player:getMark("bz_amsl") then
					player:speak("你们打游戏能不能动动脑子？")
					room:addPlayerMark(player, "bz_amsl")
				end
			end
			if player:getPhase() == sgs.Player_Play then
				if isSpecialOne(player, "手杀界徐盛") or isSpecialOne(player, "界黄忠") or isSpecialOne(player, "谋黄忠")
				or isSpecialOne(player, "马超") or isSpecialOne(player, "麹义") then
					local zhangjiaos = {}
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if isSpecialOne(p, "张角") and not isSpecialOne(p, "神张角") then
							table.insert(zhangjiaos, p)
						end
					end
					if #zhangjiaos > 0 then
						local zhangjiao = zhangjiaos[math.random(1, #zhangjiaos)]
						zhangjiao:speak("杀我")
					end
				end
				if (player:getGeneralName() == "machao" or player:getGeneral2Name() == "machao") and player:getMark("mtx_tqwx") == 0 then
					local xzc = player:getNextAlive()
					if (xzc:getGeneralName() == "xizhicai" or xzc:getGeneral2Name() == "xizhicai") and math.random() > 0.5 then
						player:speak("戏子，给我补牌，不然铁骑你")
						room:getThread():delay()
						xzc:speak("看hs去了")
						room:getThread():delay()
						player:speak("网站发我，不然铁骑你")
						room:addPlayerMark(player, "mtx_tqwx")
					end
				end
				if isSpecialOne(player, "刘焉") and player:getMark("lts_bzxwdnw") == 0 then
					local sunluyus = {}
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if isSpecialOne(p, "孙鲁育") then --懒得判断是不是能给止息的小虎了
							table.insert(sunluyus, p)
						end
					end
					if #sunluyus > 0 then
						local sunluyu = sunluyus[math.random(1, #sunluyus)]
						player:speak("别止息我带你玩")
						room:getThread():delay()
						sunluyu:speak("你不用说了") --懒得判断是不是发动魅步了
						room:addPlayerMark(player, "lts_bzxwdnw")
					end
				end
				if (player:getGeneralName() == "ol_weiyan" or player:getGeneral2Name() == "ol_weiyan") and player:isLord()
				and player:hasSkill("olqimou") and player:getMark("@olqimouMark") > 0 and player:getMark("ojwy_scqzd") == 0 and math.random() > 0.5 then
					player:speak("这里谁充钱最多？")
					local yuefus = {}
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if p:getGeneralName() == "huangchengyan" or p:getGeneral2Name() == "huangchengyan" then
							table.insert(yuefus, p)
						end
					end
					if #yuefus > 0 then
						room:getThread():delay()
						local yuefu = yuefus[math.random(1, #yuefus)]
						yuefu:speak("这里我充钱最多")
					end
					room:addPlayerMark(player, "ojwy_scqzd")
				end
				if (player:getGeneralName() == "yuanshao" or player:getGeneral2Name() == "yuanshao") and player:getHandcardNum() >= 6 then
					local ys = player:getHandcardNum()
					if math.random() <= ys/30 then
						player:speak("袁神，启动！")
					end
				end
				if isSpecialOne(player, "曹叡") and math.random() > 0.9 then
					player:speak("打游戏还要脑子，那我不如去搞学习")
				end
				if isSpecialOne(player, "刘焉") and player:isLord() then
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if isSpecialOne(p, "张松") and p:hasSkill("xiantu") and math.random() > 0.8 then
							p:speak("红桃闪来喽")
							break
						end
					end
				end
				if isSpecialOne(player, "神刘备") and player:hasSkill("longnu") then
					if player:getHandcardNum() > 6 and math.random() > 0.8 then
						player:speak("准备收场了我")
					end
				end
				if isSpecialOne(player, "孙翎鸾") then
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if (p:getGeneralName() == "liuba" or p:getGeneral2Name() == "liuba") and math.random() > 0.7 then
							p:speak("孙翎鸾？巴神我的星怒罢了")
							break
						end
					end
				end
				if isSpecialOne(player, "武") and isSpecialOne(player, "陆逊") then
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						local pj = math.random(0,15)
						if pj == 0 then
							p:speak("害怕")
						elseif pj == 1 then
							p:speak("兄弟萌，等会可以准备点托管了")
						elseif pj == 2 then
							p:speak("玩个锤子，我先开润了")
						elseif pj == 3 then
							p:speak("又撞到这个比，玩NM，劳资投降还不行嘛")
						elseif pj == 4 then
							p:speak("捏嘛嘛的有话好说，别又摸空牌堆了")
						end
					end
				end
			end
			if player:getPhase() == sgs.Player_Judge then
				if (player:getGeneralName() == "jiangwei" or player:getGeneral2Name() == "jiangwei") and player:hasSkill("guanxing") then
					local can_speak = false
					for _, c in sgs.qlist(player:getJudgingArea()) do
						if c:isKindOf("Lightning") then
							can_speak = true
						end
					end
					if can_speak and math.random() > 0.75 then
						player:speak("全是2-9，你信么，真的好恐怖")
						player:setFlags("jiangwei_zbks")
					end
				end
			end
			if player:getPhase() == sgs.Player_Finish then
				if player:getKingdom() == "wu" and isSpecialOne(room:getLord(), "界孙权") then
					--[[if math.random() > 0.3 then
						player:speak("曾经有教育家做了一个实验")
						room:getThread():delay()
						player:speak("给魏蜀国孩子和吴国孩子一手牌")
						room:getThread():delay()
						player:speak("让他们不用制冷器就让水结成冰")
						room:getThread():delay()
						player:speak("吴国孩子玩界孙权，使用大制衡\
						找寒冰箭直接把水冻结了，赢")
						room:getThread():delay()
						player:speak("而魏蜀国的孩子不玩界孙权，直接认输")
						room:getThread():delay()
						player:speak("可见从小培养玩界孙权的意识，比任何教育都重要")
					else]]
					local sq = math.random(0,30)
					if sq == 0 then player:speak("思权拳 思如泉涌!👊😭👊")
					elseif sq == 1 then player:speak("念权剑 念念不忘!!🗡😭🗡")
					elseif sq == 2 then player:speak("界权掌 生生世世!!!✋😭✋")
					elseif sq == 3 then player:speak("会玩、会玩、会玩！")
					elseif sq == 4 then player:speak("璀璨中的凋零、制衡联合！😊👉👈😊")
					elseif sq == 5 then player:speak("极冻中的炽烈、纵横捭阖！😚☺👦👧")
					elseif sq == 6 then player:speak("虚无中的真言、容我三思！😁👍💪😁")
					elseif sq == 7 then player:speak("冰霜中的独舞、则吴盛可期！😍👼👼😍")
					end
				end
				if ((player:getGeneralName() == "lvmeng" or player:getGeneral2Name() == "lvmeng")
				or (player:getGeneralName() == "ol_lvmeng" or player:getGeneral2Name() == "ol_lvmeng"))
				and player:getHandcardNum() >= 10 and player:getMark("jlm_kjmw") == 0 then
					player:speak("知道什么叫后期英雄吗")
					room:getThread():delay()
					local chenlin = 0
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if isSpecialOne(p, "陈琳") then
							chenlin = chenlin + 1
							p:speak("你信不信游戏结束你都没出过一张杀")
							break
						end
					end
					if chenlin == 0 then
						local otrs = {}
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							table.insert(otrs, p)
						end
						local otr = otrs[math.random(1, #otrs)]
						otr:speak("你信不信游戏结束你都没出过一张杀")
					end
					room:getThread():delay()
					player:speak("我为什么要出杀")
					room:getThread():delay()
					player:speak("只要我活着就能让对方恐惧")
					room:addPlayerMark(player, "jlm_kjmw")
				end
			end
		elseif event == sgs.Damage then
			local damage = data:toDamage()
			if damage.from and isSpecialOne(player, "吕布") and damage.to and (isSpecialOne(damage.to, "丁原") or isSpecialOne(damage.to, "董卓")) then
				local otrs = {}
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					table.insert(otrs, p)
				end
				local otr = otrs[math.random(1, #otrs)]
				otr:speak("孝死我了")
			end
		elseif event == sgs.Damaged then
			local damage = data:toDamage()
			if damage.nature == sgs.DamageStruct_Thunder and player:getPhase() == sgs.Player_Judge and player:hasFlag("jiangwei_zbks") then
				player:setFlags("-jiangwei_zbks")
				player:speak("这不科学")
			end
		elseif event == sgs.Dying then
			local dying = data:toDying()
			if dying.who and dying.who:objectName() == player:objectName() and (player:getGeneralName() == "xuchu" or player:getGeneral2Name() == "xuchu")
			or (player:getGeneralName() == "tenyear_xuchu" or player:getGeneral2Name() == "tenyear_xuchu") and math.random() <= 0.2 then
				player:speak("小几把 还挺会玩")
			end
			if dying.who and dying.who:objectName() == player:objectName() and isSpecialOne(player, "张春华") and (player:getSeat() == 2 or player:getSeat() == room:alivePlayerCount())
			and player:getRoleEnum() == sgs.Player_Loyalist and dying.damage.from and dying.damage.from:isLord()
			and (isSpecialOne(dying.damage.from, "曹丕") or isSpecialOne(dying.damage.from, "曹叡")) then
				if math.random() > 0.75 then player:speak("明反不搞，把我往死里盲") --实际可能会有些牛头不对马嘴
				else player:speak("我不知道我哪里跳反了") end
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who and death.who:objectName() == player:objectName() and isSpecialOne(player, "朱治") and math.random() > 0.8 then
				player:speak("充那么多钱，我cnm")
			end
			if death.who and death.who:objectName() == player:objectName() and (player:getGeneralName() == "machao" or player:getGeneral2Name() == "machao")
			and player:getRoleEnum() == sgs.Player_Loyalist and death.damage.from and death.damage.from:isLord()
			and (isSpecialOne(death.damage.from, "曹丕") or isSpecialOne(death.damage.from, "曹叡")) then
				if math.random() > 0.5 then player:speak("强忠没见过？")
				else player:speak("选个有攻击力点的有什么问题") end
			end
		elseif event == sgs.GameStart then
			if room:alivePlayerCount() == 8 and isSpecialOne(player, "神荀彧") and math.random() > 0.8 then
				player:speak("都选这么阴间的武将，你们良心不会痛吗？")
			end
			if isSpecialOne(player, "张嫙") and math.random() > 0.95 then
				player:speak("戴比特...一个听起来似乎有点印象的名字.......")
			end
			if isSpecialOne(player, "武") and isSpecialOne(player, "陆逊") and math.random() > 0.85 then
				player:speak("不好意思，我不是针对谁，我是说")
				room:getThread():delay()
				player:speak("在座的各位，都是垃圾")
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("f_mobile_chat_normal") then skills:append(f_mobile_chat_normal) end
if not sgs.Sanguosha:getSkill("f_mobile_chat_general") then skills:append(f_mobile_chat_general) end
--====================--

--

sgs.Sanguosha:addSkills(skills)
sgs.LoadTranslationTable{
    ["mobileeffectst"] = "手杀特效2",
	["mobileeffectst_on"] = "手杀特效2(互动功能开关)",
	["cancel"] = "取消",
	
	--语音鉴赏
	["f_MEanjiang"] = "语音鉴赏2",
	  --手杀特效2
	["f_mobile_effect"] = "手杀特效2",
	["$f_mobile_effect1"] = "医术高超~", --于回合内使用【桃】给自己回复了每三点体力
	["f_mobile_effect_YSGC"] = "image=image/animate/f_YSGC.png",
	["$f_mobile_effect2"] = "妙手回春~", --一局中连续三次使用【桃】将同一名其他角色从濒死中救活
	["f_mobile_effect_MSHC"] = "image=image/animate/f_MSHC.png",
	  --手杀互动（砸蛋+送花）
	["f_mobile_efs"] = "手杀互动",
	[":f_mobile_efs"] = "可以于出牌阶段点击相应按钮发动；一名角色进入濒死状态时(每个回合限发动一次,仅限联机模式)或你死亡时会询问你是否发动。\
	发动时，若选择有自己，可以调整砸蛋/送花的设定数量（1、5、10、20、50；默认初始为10(砸蛋)/1(送花)次；多次砸蛋会追加扔拖鞋）。",
	["@f_mobile_efs_d:interaction"] = "你可以进行互动：[砸蛋,送花]",
	["$f_mobile_efs1"] = "（砸蛋声）",
	["$f_mobile_efs2"] = "（砸蛋声）",
	["$f_mobile_efs3"] = "（送花声）",
	["$f_mobile_efs4"] = "（送花声）",
	["$f_mobile_efs5"] = "（扔拖鞋声）",
	    --砸蛋
	  ["f_mobile_efs_egg"] = "砸蛋",
	  [":f_mobile_efs_egg"] = "可以于出牌阶段<font color='green'><b>点击此按钮</b></font>发动；一名角色进入濒死状态时(每个回合限发动一次,仅限联机模式)或你死亡时会询问你是否发动。\
	  发动时，若选择有自己，可以调整砸蛋的设定数量（1、5、10、20、50；默认初始为10次；多次砸蛋会追加扔拖鞋）。",
	  ["f_mobile_efs_egg:1"] = "砸1个",
	  ["f_mobile_efs_egg:2"] = "砸5个",
	  ["f_mobile_efs_egg:3"] = "砸10个",
	  ["f_mobile_efs_egg:4"] = "砸20个",
	  ["f_mobile_efs_egg:5"] = "砸50个",
	  ["f_mobile_efs_egg:none"] = "不调整",
	  ["@f_mobile_efs_egg"] = "请选择目标，进行砸蛋",
	    --送花
	  ["f_mobile_efs_flower"] = "送花",
	  [":f_mobile_efs_flower"] = "可以于出牌阶段<font color='green'><b>点击此按钮</b></font>发动；一名角色进入濒死状态时(每个回合限发动一次,仅限联机模式)或你死亡时会询问你是否发动。\
	  发动时，若选择有自己，可以调整送花的设定数量（1、5、10、20、50；默认初始为1次）。",
	  ["f_mobile_efs_flower:1"] = "送1朵",
	  ["f_mobile_efs_flower:2"] = "送5朵",
	  ["f_mobile_efs_flower:3"] = "送10朵",
	  ["f_mobile_efs_flower:4"] = "送20朵",
	  ["f_mobile_efs_flower:5"] = "送50朵",
	  ["f_mobile_efs_flower:none"] = "不调整",
	  ["@f_mobile_efs_flower"] = "请选择目标，进行送花",
	  --属性特殊音效
	["f_mobile_nature"] = "属性特殊音效",
	["$f_mobile_nature1"] = "（使用火杀）",
	["$f_mobile_nature2"] = "（使用雷杀）",
	["$f_mobile_nature3"] = "（使用冰杀）",
	["$f_mobile_nature4"] = "（受到火焰伤害(1点)）",
	["$f_mobile_nature5"] = "（受到火焰伤害(大于1点)）",
	["$f_mobile_nature6"] = "（受到雷电伤害(1点)）",
	["$f_mobile_nature7"] = "（受到雷电伤害(大于1点)）",
	["$f_mobile_nature8"] = "（受到冰冻伤害(1点)）",
	["$f_mobile_nature9"] = "（受到冰冻伤害(大于1点)）",
	["$f_mobile_nature10"] = "（受到毒素伤害(男性)）",
	["$f_mobile_nature11"] = "（受到毒素伤害(女性)）",
	["$f_mobile_nature12"] = "（受到酒杀伤害）",
	["$f_mobile_nature13"] = "（火焰伤害(1点)破护甲）",
	["$f_mobile_nature14"] = "（火焰伤害(大于1点)破护甲）",
	["$f_mobile_nature15"] = "（雷电伤害(1点)破护甲）",
	["$f_mobile_nature16"] = "（雷电伤害(大于1点)破护甲）",
	["$f_mobile_nature17"] = "（其他伤害(1点)破护甲）",
	["$f_mobile_nature18"] = "（其他伤害(大于1点)破护甲）",
	  --死亡之声
	["f_mobile_death"] = "死亡之声",
	["$f_mobile_death"] = "（死亡之声）",
	
	--==ai聊天扩展包==--
	["f_mobile_chat_normal"] = "ai聊天扩展包-通常",
	["f_mobile_chat_general"] = "ai聊天扩展包-武将专属",
	--================--
}
return {extension, extension_x}