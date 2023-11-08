extension = sgs.Package("mobileGod", sgs.Package_GeneralPack)
extension_t = sgs.Package("tenyearGod", sgs.Package_GeneralPack)
extension_o = sgs.Package("OLGod", sgs.Package_GeneralPack)
extension_j = sgs.Package("joyGod", sgs.Package_GeneralPack)
extension_w = sgs.Package("wxGod", sgs.Package_GeneralPack)
extension_jl = sgs.Package("jlsgGod", sgs.Package_GeneralPack)
extension_ofl = sgs.Package("offlineGod", sgs.Package_GeneralPack)
extension_f = sgs.Package("FCGod", sgs.Package_GeneralPack)
newgodsCard = sgs.Package("newgodsCard", sgs.Package_CardPack)
--[[《目录》
手杀神武将（始计篇10位，附赠1位，海外服2位）：
  神郭嘉(智,已界)、神荀彧(智,已界)、神太史慈(信,初已界)、神孙策(信,已界)、???(仁)、???(仁)、???(勇)、???(勇)、???(严)、???(严)（附赠张仲景(仁,测试初版)）；
  神关羽(海外服)、神吕蒙(海外服)
十周年神武将（6）：
  神姜维(神·武,已界,附赠爆料魔改版)、神马超(神·武)、神张飞(神·武)、神张角(神·武)、神邓艾(神·武)、神典韦(神·武,魔改)
OL神武将（5）：
  神曹丕(神武再世)、神甄姬(神武再世)、神孙权、神张角(已界)、神典韦(魔改)
欢乐杀神武将（目前有26位，我只是写了其中一部分(除神张辽外的神话再临11神将补完中，技能重复的不写，充当皮肤；[神郭嘉/神孙策/神甄姬/神张角/神张飞/神姜维/神荀彧]不写，充当皮肤)）：
  神关羽、神吕蒙、神周瑜、神诸葛亮
  神孙权、神张辽、神典韦、神华佗、神貂蝉、神-大乔&小乔、孙悟空(附赠威力加强版)、嫦娥
(微信)小程序神武将（3，神话再临12神将补完中，技能重复的不写，如果与原画有区别的会充当皮肤）：
  神关羽、神吕蒙、神诸葛亮(附赠威力加强版)
极略三国神武将（3，纯随缘更新）
  神黄忠、神黄盖、神华佗
线下神武将（6）：
  神姜维(官盗)、新神马超(官方)、神郭嘉(官方)、神荀彧(官方)、长坂坡模式·神赵云(民间,附赠威力加强版)、长坂坡模式·神张飞(民间,附赠威力加强版)
自己/吧友DIY的神武将（19）：
  神司马师(自)、神刘三刀(自)、神刘备-威力加强版、神董卓、神罗贯中(自)、神左慈(自)、神刘禅(包括新版)、神曹仁、神赵云&陈到(自)、神孙尚香(自)、神于吉、神庞统、神蒲元(自)、神马钧(自)、神司马炎(两个版本)、神刘协；
  神-曹丕&甄姬、十长逝、神袁绍
天才包专属神武将（1）：
  神祝融
]]

--==手杀神武将==--
--(界)神郭嘉（智）
f_shenguojia = sgs.General(extension, "f_shenguojia", "god", 3, true)

f_huishiCard = sgs.CreateSkillCard{
    name = "f_huishiCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
	    if source:getPile("HandcarddataHS"):length() > 0 then
			local dummy = sgs.Sanguosha:cloneCard("slash")
		    dummy:addSubcards(source:getPile("HandcarddataHS"))
			local cg = room:askForPlayerChosen(source, room:getAllPlayers(), "f_huishi", "f_huishi-give")
		    room:obtainCard(cg, dummy, true)
			dummy:deleteLater()
			local can_invoke = true
		    for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			    if source:getHandcardNum() <= p:getHandcardNum() then
				    can_invoke = false
				    break
			    end
		    end
		    if can_invoke then
		        --room:loseMaxHp(source, 1)
				local choice = room:askForChoice(source, "@f_huishiLose", "mhp+hp")
				if choice == "mhp" then
					room:loseMaxHp(source, 1)
				else
					room:loseHp(source, 1)
				end
		    end
		end
	end,
}
f_huishi = sgs.CreateZeroCardViewAsSkill{
    name = "f_huishi",
	view_as = function()
		return f_huishiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#f_huishiCard") and player:getMaxHp() < 10
	end,
}
f_huishiContinue = sgs.CreateTriggerSkill{
    name = "f_huishiContinue",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		--皇甫道长捉妖标志代码：DaoZhang_ZhuoYao
		--第一次判定
		if use.card:getSkillName() == "f_huishi" and player:getMaxHp() < 10 and not player:hasFlag("DaoZhang_ZhuoYao") then
		    --[[local hc = player:getHandcardNum()
		    if hc > 0 then
	            local card_id = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		        if card_id then
				    card_id:deleteLater()
			        card_id = room:askForExchange(player, "f_huishi", hc, hc, false, "")
		        end
		        player:addToPile("HandcarddataHS", card_id, false)
			end]]
			local judge = sgs.JudgeStruct()
			judge.pattern = "."
			judge.good = true
			judge.play_animation = false
			judge.who = player
			judge.reason = "f_huishi"
			room:judge(judge)
			if player:hasFlag("DaoZhang_ZhuoYao") then room:setPlayerFlag(player, "-DaoZhang_ZhuoYao") return false end
			local card1 = judge.card
			local card_id1 = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		    if card_id1 then
				card_id1:deleteLater()
			    card_id1 = card1
		    end
		    player:addToPile("HandcarddataHS", card_id1, true)
			--[[local c1 = player:getMaxHp()
		    local mhp1 = sgs.QVariant()
		    mhp1:setValue(c1 + 1)
		    room:setPlayerProperty(player, "maxhp", mhp1)]]
			local choice = room:askForChoice(player, "@f_huishiAdd", "mhp+hp")
			if choice == "mhp" then
				room:gainMaxHp(player, 1, "f_huishi")
			else
				room:recover(player, sgs.RecoverStruct(player))
			end
		    --第二次判定
		    if player:getMaxHp() < 10 and room:askForSkillInvoke(player, "@f_huishi_continue", data) and not player:hasFlag("DaoZhang_ZhuoYao") then room:broadcastSkillInvoke("f_huishi")
			    local judge = sgs.JudgeStruct()
			    judge.pattern = "."
			    judge.good = true
			    judge.play_animation = false
			    judge.who = player
			    judge.reason = "f_huishi"
			    room:judge(judge)
				if player:hasFlag("DaoZhang_ZhuoYao") then room:setPlayerFlag(player, "-DaoZhang_ZhuoYao") return false end
		        local card2 = judge.card
                if card2:getSuit() == card1:getSuit() then
				    local card_id2 = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		    	    if card_id2 then
					    card_id2:deleteLater()
			    	    card_id2 = card2
		    	    end
		    	    player:addToPile("HandcarddataHS", card_id2, true)
			        return false
                else
			        local card_id2 = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		    	    if card_id2 then
					    card_id2:deleteLater()
			    	    card_id2 = card2
		    	    end
		    	    player:addToPile("HandcarddataHS", card_id2, true)
					--[[local c2 = player:getMaxHp()
		            local mhp2 = sgs.QVariant()
		            mhp2:setValue(c2 + 1)
		            room:setPlayerProperty(player, "maxhp", mhp2)]]
					local choice = room:askForChoice(player, "@f_huishiAdd", "mhp+hp")
					if choice == "mhp" then
						room:gainMaxHp(player, 1, "f_huishi")
					else
						room:recover(player, sgs.RecoverStruct(player))
					end
			    end
		        --第三次判定
		        if player:getMaxHp() < 10 and room:askForSkillInvoke(player, "@f_huishi_continue", data) and not player:hasFlag("DaoZhang_ZhuoYao") then room:broadcastSkillInvoke("f_huishi")
			        local judge = sgs.JudgeStruct()
			        judge.pattern = "."
			        judge.good = true
			        judge.play_animation = false
			        judge.who = player
			        judge.reason = "f_huishi"
			        room:judge(judge)
		            if player:hasFlag("DaoZhang_ZhuoYao") then room:setPlayerFlag(player, "-DaoZhang_ZhuoYao") return false end
					local card3 = judge.card
                    if card3:getSuit() == card2:getSuit() or card3:getSuit() == card1:getSuit() then
				        local card_id3 = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		    	    	if card_id3 then
					    	card_id3:deleteLater()
			    	    	card_id3 = card3
		    	    	end
		    	    	player:addToPile("HandcarddataHS", card_id3, true)
			            return false
                    else
			            local card_id3 = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		    	    	if card_id3 then
					    	card_id3:deleteLater()
			    	    	card_id3 = card3
		    	    	end
		    	    	player:addToPile("HandcarddataHS", card_id3, true)
						--[[local c3 = player:getMaxHp()
		                local mhp3 = sgs.QVariant()
		                mhp3:setValue(c3 + 1)
		                room:setPlayerProperty(player, "maxhp", mhp3)]]
						local choice = room:askForChoice(player, "@f_huishiAdd", "mhp+hp")
						if choice == "mhp" then
							room:gainMaxHp(player, 1, "f_huishi")
						else
							room:recover(player, sgs.RecoverStruct(player))
						end
			        end
			        --第四次判定
			        if player:getMaxHp() < 10 and room:askForSkillInvoke(player, "@f_huishi_continue", data) and not player:hasFlag("DaoZhang_ZhuoYao") then room:broadcastSkillInvoke("f_huishi")
					    local judge = sgs.JudgeStruct()
			            judge.pattern = "."
			            judge.good = true
			            judge.play_animation = false
			            judge.who = player
			            judge.reason = "f_huishi"
			            room:judge(judge)
		                if player:hasFlag("DaoZhang_ZhuoYao") then room:setPlayerFlag(player, "-DaoZhang_ZhuoYao") return false end
						local card4 = judge.card
            	        if card4:getSuit() == card3:getSuit() or card4:getSuit() == card2:getSuit() or card4:getSuit() == card1:getSuit() then
					        local card_id4 = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		    	    		if card_id4 then
					    		card_id4:deleteLater()
			    	    		card_id4 = card4
		    	    		end
		    	    		player:addToPile("HandcarddataHS", card_id4, true)
			                return false
            	        else
			    	        local card_id4 = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		    	    		if card_id4 then
					    		card_id4:deleteLater()
			    	    		card_id4 = card4
		    	    		end
		    	    		player:addToPile("HandcarddataHS", card_id4, true)
							--[[local c4 = player:getMaxHp()
		                    local mhp4 = sgs.QVariant()
		                    mhp4:setValue(c4 + 1)
		                    room:setPlayerProperty(player, "maxhp", mhp4)]]
							local choice = room:askForChoice(player, "@f_huishiAdd", "mhp+hp")
							if choice == "mhp" then
								room:gainMaxHp(player, 1, "f_huishi")
							else
								room:recover(player, sgs.RecoverStruct(player))
							end
				        end
				        --第五次判定（也是最后一次，因为这一次必撞花色）
				        if player:getMaxHp() < 10 and room:askForSkillInvoke(player, "@f_huishi_continue", data) and not player:hasFlag("DaoZhang_ZhuoYao") then room:broadcastSkillInvoke("f_huishi")
							local judge = sgs.JudgeStruct()
			            	judge.pattern = "."
			            	judge.good = true
			            	judge.play_animation = false
			            	judge.who = player
			            	judge.reason = "f_huishi"
			            	room:judge(judge)
		                	if player:hasFlag("DaoZhang_ZhuoYao") then room:setPlayerFlag(player, "-DaoZhang_ZhuoYao") return false end
							local card5 = judge.card
					        local card_id5 = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		    	    		if card_id5 then
					    		card_id5:deleteLater()
			    	    		card_id5 = card5
		    	    		end
		    	    		player:addToPile("HandcarddataHS", card_id5, true)
			                return false
						else
			                return false
						end
					else
			            return false
					end
				else
			        return false
				end
			else
			    return false
			end
		end
		--清除捉妖标志
		if player:hasFlag("DaoZhang_ZhuoYao") then
			room:setPlayerFlag(player, "-DaoZhang_ZhuoYao")
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_huishi") and player:getMaxHp() < 10
	end,
}
f_shenguojia:addSkill(f_huishi)
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("f_huishiContinue") then skills:append(f_huishiContinue) end

f_tianyiDamageTake = sgs.CreateTriggerSkill{
    name = "f_tianyiDamageTake",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local damage = data:toDamage()
		local sgj = room:findPlayerBySkillName("f_tianyi")
		if not sgj then return false end
		if player:getMark("f_tianyiDamageTake") == 0 then
		    room:addPlayerMark(player, "f_tianyiDamageTake")
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
f_tianyi = sgs.CreateTriggerSkill{
    name = "f_tianyi",
	frequency = sgs.Skill_Wake,
	waked_skills = "ty_zuoxing",
	events = {sgs.EventPhaseStart},
	can_wake = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		--if player:getMark("&f_tianyi_Trigger") > 0 then return true end
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:getMark("f_tianyiDamageTake") == 0 then
				return false
			end
		end
		return true
	end,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		if player:getGeneralName() == "f_shenguojia_d1" or player:getGeneral2Name() == "f_shenguojia_d1" then --双形态皮肤：由第一形态切换至第二形态
			room:doLightbox("f_tianyiAnimate_yxzy")
			local n = player:getMark("@f_huishii")
			if player:getGeneralName() == "f_shenguojia_d1" then
				room:changeHero(player, "f_shenguojia_d2", false, false, false, false)
			elseif player:getGeneral2Name() == "f_shenguojia_d1" then
				room:changeHero(player, "f_shenguojia_d2", false, false, true, false)
			end
			room:setPlayerMark(player, "@f_huishii", n)
		else
			room:doLightbox("f_tianyiAnimate")
		end
		--[[local c = player:getMaxHp()
		local mhp = sgs.QVariant()
		mhp:setValue(c + 2)
		room:setPlayerProperty(player, "maxhp", mhp)
		local recover = sgs.RecoverStruct()
		recover.who = player
		room:recover(player, recover)]]
		room:gainMaxHp(player, 2, self:objectName())
		room:recover(player, sgs.RecoverStruct(player))
		local beneficiary = room:askForPlayerChosen(player, room:getAllPlayers(), "@f_tianyi", "f_tianyi-invoke")
		room:addPlayerMark(player, "ty_zuoxingFrom")
		if not beneficiary:hasSkill("ty_zuoxing") then
		    room:acquireSkill(beneficiary, "ty_zuoxing")
		end
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
		if player:getMark("&f_tianyi_Trigger") > 0 then
		    room:removePlayerMark(player, "&f_tianyi_Trigger")
		end
	end,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
f_shenguojia:addSkill(f_tianyi)
f_shenguojia:addRelateSkill("ty_zuoxing")
if not sgs.Sanguosha:getSkill("f_tianyiDamageTake") then skills:append(f_tianyiDamageTake) end

--“佐幸”
ty_zuoxingCard = sgs.CreateSkillCard{
	name = "ty_zuoxingCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		local card = sgs.Self:getTag("ty_zuoxing"):toCard()
		card:setSkillName("ty_zuoxing")
		if card and card:targetFixed() then
			return false
		end
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		return card and card:targetFilter(qtargets, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, qtargets)
	end,
	feasible = function(self, targets)
		local card = sgs.Self:getTag("ty_zuoxing"):toCard()
		card:setSkillName("ty_zuoxing")
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		if card and card:canRecast() and #targets == 0 then
			return false
		end
		return card and card:targetsFeasible(qtargets, sgs.Self)
	end,
	on_validate = function(self, card_use)
		local player = card_use.from
		local room = player:getRoom()
	    local can_invoke = false
	    for _, n in sgs.qlist(room:getAllPlayers()) do
		    if n:getMark("ty_zuoxingFrom") > 0 and n:isAlive() and n:getMaxHp() > 1 then
				can_invoke = true
			    room:loseMaxHp(n, 1)
			    break
		    end
	    end
	    if can_invoke then
			local use_card = sgs.Sanguosha:cloneCard(self:getUserString())
		    use_card:setSkillName("ty_zuoxing")
		    local available = true
		    for _, p in sgs.qlist(card_use.to) do
			    if player:isProhibited(p, use_card) then
				    available = false
				    break
			    end
		    end
		    available = available and use_card:isAvailable(player)
		    if not available then return nil end
			use_card:deleteLater()
		    return use_card
		end
	end,
}
ty_zuoxing = sgs.CreateViewAsSkill{
	name = "ty_zuoxing",
	n = 0,
	view_filter = function(self, selected, to_select)
		return false
	end,
	view_as = function(self, cards)
		local c = sgs.Self:getTag("ty_zuoxing"):toCard()
		if c then
			local card = ty_zuoxingCard:clone()
			card:setUserString(c:objectName())	
			return card
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#ty_zuoxingCard")
	end,
}
ty_zuoxing:setGuhuoDialog("r")
if not sgs.Sanguosha:getSkill("ty_zuoxing") then skills:append(ty_zuoxing) end

f_huishiiCard = sgs.CreateSkillCard{
	name = "f_huishiiCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0
	end,
	on_use = function(self, room, source, targets)
		--[[local count = room:alivePlayerCount()
		local mhp = source:getMaxHp()
		if targets[1]:getGeneralName() == source:getGeneralName() and source:getMark("f_tianyi") == 0 and mhp >= count then
		    room:addPlayerMark(targets[1], "&f_tianyi_Trigger")
		else
		    room:drawCards(targets[1], 4, self:objectName())
		end
		room:loseMaxHp(source, 2)]]
		room:doSuperLightbox("f_shenguojia", "f_huishii")
		room:removePlayerMark(source, "@f_huishii")
		--于是乎，就这样直接将妹神的代码给借鉴，哦不抄过来了
		local skills = {}
		for _, sk in sgs.qlist(targets[1]:getVisibleSkillList()) do
			if sk:getFrequency(targets[1]) ~= sgs.Skill_Wake or targets[1]:getMark(sk:objectName()) > 0 then continue end
			table.insert(skills, sk:objectName())
		end
		if #skills > 0 and source:getMaxHp() >= room:alivePlayerCount() then
			local data = sgs.QVariant()
			data:setValue(targets[1])
			local skill = room:askForChoice(source, self:objectName(), table.concat(skills, "+"), data)
			targets[1]:setCanWake("f_huishii", skill)
		else
			targets[1]:drawCards(4, "f_huishii")
		end
		if source:isDead() then return end
		room:loseMaxHp(source, 2, self:objectName())
	end,
}
f_huishiiVS = sgs.CreateZeroCardViewAsSkill{
	name = "f_huishii",
	view_as = function()
		return f_huishiiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@f_huishii") > 0
	end,
}
f_huishii = sgs.CreateTriggerSkill{
	name = "f_huishii",
	frequency = sgs.Skill_Limited,
	limit_mark = "@f_huishii",
	view_as_skill = f_huishiiVS,
	on_trigger = function()
	end,
}
f_shenguojia:addSkill(f_huishii)


--

--(界)神荀彧（智）
f_shenxunyu = sgs.General(extension, "f_shenxunyu", "god", 3, true)

--==神荀彧专属锦囊：奇正相生==--
f_qizhengxiangsheng = sgs.CreateTrickCard{
    name = "f_qizhengxiangsheng",
	class_name = "Fqizhengxiangsheng",
	subtype = "f_shenxunyuTrick",
	target_fixed = false,
	can_recast = false,
	available = true,
	is_cancelable = true,
	damage_card = true,
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	filter = function(self, targets, to_select, player)
	    return #targets == 0 and to_select:objectName() ~= player:objectName() and not player:isCardLimited(self, sgs.Card_MethodUse) and not player:isProhibited(to_select, self)
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local data = sgs.QVariant()
		--以下是神荀彧“天佐”的部分，写进此锦囊里了--
		local f_shenxunyu = room:findPlayersBySkillName("f_tianzuo")
		for _, sxy in sgs.qlist(f_shenxunyu) do
			if sxy and sxy:getMark("@skill_invalidity") == 0 then
            	if room:askForSkillInvoke(sxy, "f_tianzuo", data) then
		        	room:broadcastSkillInvoke("f_tianzuo")
		        	if not effect.to:isKongcheng() then
			        	local ids = sgs.IntList()
				    	for _, c in sgs.qlist(effect.to:getHandcards()) do
					    	if c then
						    	ids:append(c:getEffectiveId())
					    	end
				    	end
			        	local card_id = room:doGongxin(sxy, effect.to, ids)
				    	if (card_id == 0) then return end
					end
					--电脑神荀彧对[体力值<=1的无手牌角色]&[无手牌与装备牌的角色]必“奇兵”
					if effect.from:objectName() == sxy:objectName() and effect.from:getState() == "robot" and ((effect.to:getHp() <= 1 and effect.to:isKongcheng()) or (effect.to:isNude())) then
			    		if effect.from:hasFlag("youcantchoseqibing") then
							room:setPlayerFlag(effect.from, "-youcantchoseqibing")
						end
						if effect.from:hasFlag("youcantchosezhengbing") then
							room:setPlayerFlag(effect.from, "-youcantchosezhengbing")
						end
						room:setPlayerFlag(effect.from, "youcantchosezhengbing")
					--电脑神荀彧成为目标时，若自己无牌/体力值<=1，选“正兵”（但还不够智能）
					elseif effect.to:objectName() == sxy:objectName() and effect.to:getState() == "robot" and (effect.to:isNude() or effect.to:getHp() < 1) then
			    		if effect.from:hasFlag("youcantchoseqibing") then
							room:setPlayerFlag(effect.from, "-youcantchoseqibing")
						end
						if effect.from:hasFlag("youcantchosezhengbing") then
							room:setPlayerFlag(effect.from, "-youcantchosezhengbing")
						end
						room:setPlayerFlag(effect.from, "youcantchoseqibing")
					else
		        		local choice = room:askForChoice(sxy, "f_tianzuo", "zhengbing+qibing", data)
			    		if choice == "zhengbing" then
			        		if effect.from:hasFlag("youcantchoseqibing") then
						   		room:setPlayerFlag(effect.from, "-youcantchoseqibing")
							end
							if effect.from:hasFlag("youcantchosezhengbing") then
						    	room:setPlayerFlag(effect.from, "-youcantchosezhengbing")
							end
							room:setPlayerFlag(effect.from, "youcantchoseqibing")
			    		elseif choice == "qibing" then
			        		if effect.from:hasFlag("youcantchoseqibing") then
						    	room:setPlayerFlag(effect.from, "-youcantchoseqibing")
							end
							if effect.from:hasFlag("youcantchosezhengbing") then
						    	room:setPlayerFlag(effect.from, "-youcantchosezhengbing")
							end
							room:setPlayerFlag(effect.from, "youcantchosezhengbing")
						end
			    	end
				end
			end
		end
		----
		--除非被“天佐”限制，否则电脑对[体力值<=1的无手牌角色]&[无手牌与装备牌的角色]必“奇兵”
		if effect.from:getState() == "robot" and ((effect.to:getHp() <= 1 and effect.to:isKongcheng()) or (effect.to:isNude())) and not effect.from:hasFlag("youcantchosezhengbing") and not effect.from:hasFlag("youcantchoseqibing") then
		    room:setPlayerFlag(effect.from, "youcantchosezhengbing")
		end
		local choices = {}
		if not effect.from:hasFlag("youcantchosezhengbing") then
		    table.insert(choices, "buyaosong")
		end
		if not effect.from:hasFlag("youcantchoseqibing") then
		    table.insert(choices, "touxi!")
		end
		local choicee = room:askForChoice(effect.from, self:objectName(), table.concat(choices, "+"))
		if choicee == "buyaosong" then
		    local choice1 = room:askForChoice(effect.to, self:objectName(), "yingduiqibing+yingduizhengbing+wobuyingdui", data)
			if choice1 == "yingduiqibing" then
			    room:askForCard(effect.to, "slash", "f_qizhengxiangsheng-slash:"..effect.from:objectName(), sgs.QVariant(), sgs.Card_MethodResponse)
				if not effect.to:isNude() then
				    local card_id = room:askForCardChosen(effect.from, effect.to, "he", self:objectName())
			        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, effect.from:objectName())
			        room:obtainCard(effect.from, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
				end
			elseif choice1 == "yingduizhengbing" then
			    if not room:askForCard(effect.to, "jink", "f_qizhengxiangsheng-jink:"..effect.from:objectName(), sgs.QVariant(), sgs.Card_MethodResponse) then
				    if not effect.to:isNude() then
				        local card_id = room:askForCardChosen(effect.from, effect.to, "he", self:objectName())
			            local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, effect.from:objectName())
			            room:obtainCard(effect.from, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
				    end
				end
			elseif choice1 == "wobuyingdui" then
			    if not effect.to:isNude() then
				    local card_id = room:askForCardChosen(effect.from, effect.to, "he", self:objectName())
			        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, effect.from:objectName())
			        room:obtainCard(effect.from, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
				end
			end
		elseif choicee == "touxi!" then
		    local choice2 = room:askForChoice(effect.to, self:objectName(), "yingduiqibing+yingduizhengbing+wobuyingdui", data)
			if choice2 == "yingduiqibing" then
			    if not room:askForCard(effect.to, "slash", "f_qizhengxiangsheng-slash:"..effect.from:objectName(), sgs.QVariant(), sgs.Card_MethodResponse) then
				    if effect.to:isAlive() then
					    local damage = sgs.DamageStruct()
						damage.from = effect.from
						damage.to = effect.to
						damage.card = self
						room:damage(damage)
					end
				end
			elseif choice2 == "yingduizhengbing" then
			    room:askForCard(effect.to, "jink", "f_qizhengxiangsheng-jink:"..effect.from:objectName(), sgs.QVariant(), sgs.Card_MethodResponse)
				if effect.to:isAlive() then
				    local damage = sgs.DamageStruct()
					damage.from = effect.from
					damage.to = effect.to
					damage.card = self
					room:damage(damage)
				end
			elseif choice2 == "wobuyingdui" then
			    if effect.to:isAlive() then
				    local damage = sgs.DamageStruct()
					damage.from = effect.from
					damage.to = effect.to
					damage.card = self
					room:damage(damage)
				end
			end
		end
		if effect.from:hasFlag("youcantchosezhengbing") then
		    room:setPlayerFlag(effect.from, "-youcantchosezhengbing")
		end
		if effect.from:hasFlag("youcantchoseqibing") then
		    room:setPlayerFlag(effect.from, "-youcantchoseqibing")
		end
	end,
}
--【奇正相生】花色与点数：♠2/♣3/♠4/♣5/♠6/♣7/♠8/♣9
for i = 0, 0, 1 do
    local card = f_qizhengxiangsheng:clone()
	card:setSuit(0)
	card:setNumber(i+2)
	card:setParent(newgodsCard)
end
for i = 0, 0, 1 do
    local card = f_qizhengxiangsheng:clone()
	card:setSuit(1)
	card:setNumber(i+3)
	card:setParent(newgodsCard)
end
for i = 0, 0, 1 do
    local card = f_qizhengxiangsheng:clone()
	card:setSuit(0)
	card:setNumber(i+4)
	card:setParent(newgodsCard)
end
for i = 0, 0, 1 do
    local card = f_qizhengxiangsheng:clone()
	card:setSuit(1)
	card:setNumber(i+5)
	card:setParent(newgodsCard)
end
for i = 0, 0, 1 do
    local card = f_qizhengxiangsheng:clone()
	card:setSuit(0)
	card:setNumber(i+6)
	card:setParent(newgodsCard)
end
for i = 0, 0, 1 do
    local card = f_qizhengxiangsheng:clone()
	card:setSuit(1)
	card:setNumber(i+7)
	card:setParent(newgodsCard)
end
for i = 0, 0, 1 do
    local card = f_qizhengxiangsheng:clone()
	card:setSuit(0)
	card:setNumber(i+8)
	card:setParent(newgodsCard)
end
for i = 0, 0, 1 do
    local card = f_qizhengxiangsheng:clone()
	card:setSuit(1)
	card:setNumber(i+9)
	card:setParent(newgodsCard)
end
----==========================----
function removeCard(room, move, tag_name) --删除卡牌
	local id = room:getTag(tag_name):toInt()
	if move.to_place == sgs.Player_DiscardPile and id > 0 and move.card_ids:contains(id) then
		local move1 = sgs.CardsMoveStruct(id, nil, nil, room:getCardPlace(id), sgs.Player_PlaceTable,
			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, nil, "remove_card", ""))
		local card = sgs.Sanguosha:getCard(id)
		room:moveCardsAtomic(move1, true)
		room:removeTag(card:getClassName())
	end
end
ngCRemoverCard = sgs.CreateSkillCard{
    name = "ngCRemoverCard",
	target_fixed = true,
	on_use = function()
	end,
}
ngCRemoverVS = sgs.CreateZeroCardViewAsSkill{
    name = "ngCRemover",
	view_as = function()
		return ngCRemoverCard:clone()
	end,
	response_pattern = "@@ngCRemover",
}
ngCRemover = sgs.CreateTriggerSkill{ --如果不选择加入【神武将专属卡牌】，将其移出游戏（如果场上有将其中某种卡牌加入游戏的技能，则对应卡牌不会被移除）
	name = "ngCRemover",
	global = true,
	priority = {10, 10},
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawInitialCards, sgs.CardsMoveOneTime},
	view_as_skill = ngCRemoverVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawInitialCards then
			if player:getState() == "online" then
			    if player:getMark("ngCRemoverAsk") > 0 and not table.contains(sgs.Sanguosha:getBanPackages(), "newgodsCard") then
					if not room:askForUseCard(player, "@@ngCRemover", "@ngCRemover") then  --玩家选择是否加入【神武将专属卡牌】
						room:setPlayerMark(player, "ngCRemoverAsk", 0)
						for _, id in sgs.qlist(room:getDrawPile()) do
							--奇正相生
							if sgs.Sanguosha:getCard(id):isKindOf("Fqizhengxiangsheng") then
								local tz = room:findPlayerBySkillName("f_tianzuo")
								if tz then continue end
								room:setTag("QZXS_ID", sgs.QVariant(id))
								local move = sgs.CardsMoveStruct(id, nil, nil, sgs.Player_DrawPile, sgs.Player_PlaceTable,
									sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, nil, self:objectName(), ""))
								room:moveCardsAtomic(move, false)
							--调剂盐梅
							--[[elseif sgs.Sanguosha:getCard(id):isKindOf("Ftiaojiyanmei") then
								room:setTag("TJYM_ID", sgs.QVariant(id))
								local move = sgs.CardsMoveStruct(id, nil, nil, sgs.Player_DrawPile, sgs.Player_PlaceTable,
									sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, nil, self:objectName(), ""))
								room:moveCardsAtomic(move, false)
							--远交近攻
							elseif sgs.Sanguosha:getCard(id):isKindOf("Fyuanjiaojingong") then
								room:setTag("YJJG_ID", sgs.QVariant(id))
								local move = sgs.CardsMoveStruct(id, nil, nil, sgs.Player_DrawPile, sgs.Player_PlaceTable,
									sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, nil, self:objectName(), ""))
								room:moveCardsAtomic(move, false)]]
							--三首
							elseif sgs.Sanguosha:getCard(id):isKindOf("OlSanshou") then
								local ss = room:findPlayerBySkillName("olsanshou")
								if ss then continue end
								room:setTag("OLSS_ID", sgs.QVariant(id))
								local move = sgs.CardsMoveStruct(id, nil, nil, sgs.Player_DrawPile, sgs.Player_PlaceTable,
									sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, nil, self:objectName(), ""))
								room:moveCardsAtomic(move, false)
							end
						end
					end
				else --直接移除
					for _, id in sgs.qlist(room:getDrawPile()) do
						--奇正相生
						if sgs.Sanguosha:getCard(id):isKindOf("Fqizhengxiangsheng") then
							local tz = room:findPlayerBySkillName("f_tianzuo")
							if tz then continue end
							room:setTag("QZXS_ID", sgs.QVariant(id))
							local move = sgs.CardsMoveStruct(id, nil, nil, sgs.Player_DrawPile, sgs.Player_PlaceTable,
								sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, nil, self:objectName(), ""))
							room:moveCardsAtomic(move, false)
						--调剂盐梅
						--[[elseif sgs.Sanguosha:getCard(id):isKindOf("Ftiaojiyanmei") then
							room:setTag("TJYM_ID", sgs.QVariant(id))
							local move = sgs.CardsMoveStruct(id, nil, nil, sgs.Player_DrawPile, sgs.Player_PlaceTable,
								sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, nil, self:objectName(), ""))
							room:moveCardsAtomic(move, false)
						--远交近攻
						elseif sgs.Sanguosha:getCard(id):isKindOf("Fyuanjiaojingong") then
							room:setTag("YJJG_ID", sgs.QVariant(id))
							local move = sgs.CardsMoveStruct(id, nil, nil, sgs.Player_DrawPile, sgs.Player_PlaceTable,
								sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, nil, self:objectName(), ""))
							room:moveCardsAtomic(move, false)]]
						--三首
						elseif sgs.Sanguosha:getCard(id):isKindOf("OlSanshou") then
							local ss = room:findPlayerBySkillName("olsanshou")
							if ss then continue end
							room:setTag("OLSS_ID", sgs.QVariant(id))
							local move = sgs.CardsMoveStruct(id, nil, nil, sgs.Player_DrawPile, sgs.Player_PlaceTable,
								sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, nil, self:objectName(), ""))
							room:moveCardsAtomic(move, false)
						end
					end
				end
			end
		else
			if player:objectName() == room:getCurrent():objectName() then
				local move = data:toMoveOneTime()
				removeCard(room, move, "QZXS_ID")
				removeCard(room, move, "TJYM_ID")
				removeCard(room, move, "YJJG_ID")
				removeCard(room, move, "OLSS_ID")
			end
		end
		return false
	end,
}
if not sgs.Sanguosha:getSkill("ngCRemover") then skills:append(ngCRemover) end


--

f_tianzuo = sgs.CreateTriggerSkill{ --一个空壳，“天佐”的所有技能内容皆在锦囊【奇正相生】里。
	name = "f_tianzuo",
	priority = 102,
	frequency = sgs.Skill_NotFrequent,
	events = {},
	on_trigger = function()
	end,
}
f_shenxunyu:addSkill(f_tianzuo)

f_lingce = sgs.CreateTriggerSkill{
	name = "f_lingce",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		local sxys = room:findPlayersBySkillName("f_lingce")
		if not sxys then return false end
		for _, sxy in sgs.qlist(sxys) do
			if use.card:isKindOf("TrickCard") then
		    	if (--[[use.card:isKindOf("ExNihilo") or]] use.card:isKindOf("Dismantlement") or use.card:isKindOf("Nullification"))
				or (use.card:isKindOf("Collateral") or use.card:isKindOf("ExNihilo") or use.card:isKindOf("Snatch") or use.card:isKindOf("IronChain"))
				or (use.card:isKindOf("Fqizhengxiangsheng") or use.card:isKindOf("Qizhengxiangsheng")) then
			    	room:sendCompulsoryTriggerLog(sxy, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:drawCards(sxy, 1, self:objectName())
				end
				if --[[(use.card:isKindOf("Dismantlement") and sxy:getMark("ghcq") > 0) or]] (use.card:isKindOf("SavageAssault") and sxy:getMark("nmrq") > 0) or (use.card:isKindOf("ArcheryAttack") and sxy:getMark("wjqf") > 0)
			    	or (use.card:isKindOf("AmazingGrace") and sxy:getMark("wgfd") > 0) or (use.card:isKindOf("GodSalvation") and sxy:getMark("tyjy") > 0) or (use.card:isKindOf("Duel") and sxy:getMark("jd") > 0)
					--[[or (use.card:isKindOf("Nullification") and sxy:getMark("wxkj") > 0)]] or (use.card:isKindOf("Indulgence") and sxy:getMark("lbss") > 0) or (use.card:isKindOf("Lightning") and sxy:getMark("sd") > 0)
					or (use.card:isKindOf("FireAttack") and sxy:getMark("hg") > 0) or (use.card:isKindOf("SupplyShortage") and sxy:getMark("blcd") > 0) or (use.card:isKindOf("Drowning") and sxy:getMark("syqj") > 0)
					or (use.card:isKindOf("Dongzhuxianji") and sxy:getMark("dzxj") > 0) or (use.card:isKindOf("Zhujinqiyuan") and sxy:getMark("zjqy") > 0) or (use.card:isKindOf("Chuqibuyi") and sxy:getMark("cqby") > 0)
					or (use.card:isKindOf("Suijiyingbian") and sxy:getMark("sjyb") > 0) or (use.card:isKindOf("Earthquake") and sxy:getMark("dz") > 0) or (use.card:isKindOf("Typhoon") and sxy:getMark("tf") > 0)
					or (use.card:isKindOf("Deluge") and sxy:getMark("hsi") > 0) or (use.card:isKindOf("Vulcano") and sxy:getMark("hsn") > 0) or (use.card:isKindOf("Mudslide") and sxy:getMark("nsl") > 0) then
					room:sendCompulsoryTriggerLog(sxy, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:drawCards(sxy, 1, self:objectName())
				end
			end
		end
	end,
}
f_shenxunyu:addSkill(f_lingce)

f_dinghan = sgs.CreateTriggerSkill{
	name = "f_dinghan",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.TargetConfirming},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		local card = use.card
		if use.to:contains(player) and card:isKindOf("TrickCard") then
		    --过河拆桥
			if card:isKindOf("Dismantlement") and player:getMark("ghcq") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
			    room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "ghcq")
			--顺手牵羊
			elseif card:isKindOf("Snatch") and player:getMark("ssqy") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "ssqy")
			--借刀杀人
			elseif card:isKindOf("Collateral") and player:getMark("jdsr") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "jdsr")
			--无中生有
			elseif card:isKindOf("ExNihilo") and player:getMark("wzsy") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "wzsy")
			--南蛮入侵
			elseif card:isKindOf("SavageAssault") and player:getMark("nmrq") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "nmrq")
			--万箭齐发
			elseif card:isKindOf("ArcheryAttack") and player:getMark("wjqf") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "wjqf")
			--五谷丰登
			elseif card:isKindOf("AmazingGrace") and player:getMark("wgfd") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "wgfd")
			--桃园结义
			elseif card:isKindOf("GodSalvation") and player:getMark("tyjy") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "tyjy")
			--决斗
			elseif card:isKindOf("Duel") and player:getMark("jd") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "jd")
			--无懈可击
			elseif card:isKindOf("Nullification") and player:getMark("wxkj") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "wxkj")
			--乐不思蜀
			elseif card:isKindOf("Indulgence") and player:getMark("lbss") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "lbss")
			--闪电
			elseif card:isKindOf("Lightning") and player:getMark("sd") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "sd")
			--铁索连环
			elseif card:isKindOf("IronChain") and player:getMark("tslh") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "tslh")
			--火攻
			elseif card:isKindOf("FireAttack") and player:getMark("hg") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "hg")
			--兵粮寸断
			elseif card:isKindOf("SupplyShortage") and player:getMark("blcd") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "blcd")
			--水淹七军
			elseif card:isKindOf("Drowning") and player:getMark("syqj") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "syqj")
			--洞烛先机
			elseif card:isKindOf("Dongzhuxianji") and player:getMark("dzxj") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "dzxj")
			--逐近弃远
			elseif card:isKindOf("Zhujinqiyuan") and player:getMark("zjqy") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "zjqy")
			--出其不意
			elseif card:isKindOf("Chuqibuyi") and player:getMark("cqby") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "cqby")
			--随机应变
			elseif card:isKindOf("Suijiyingbian") and player:getMark("sjyb") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "sjyb")
			--奇正相生
			elseif (card:isKindOf("Fqizhengxiangsheng") or card:isKindOf("Qizhengxiangsheng")) and player:getMark("qzxs") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "qzxs")
			--地震
			elseif card:isKindOf("Earthquake") and player:getMark("dz") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "dz")
			--台风
			elseif card:isKindOf("Typhoon") and player:getMark("tf") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "tf")
			--洪水
			elseif card:isKindOf("Deluge") and player:getMark("hsi") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "hsi")
			--火山
			elseif card:isKindOf("Vulcano") and player:getMark("hsn") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "hsn")
			--泥石流
			elseif card:isKindOf("Mudslide") and player:getMark("nsl") == 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			    local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
				room:addPlayerMark(player, "nsl")
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill(self:objectName())
	end,
}
f_dinghanMR = sgs.CreateTriggerSkill{
    name = "f_dinghanMR",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		--if player:getPhase() == sgs.Player_RoundStart and room:askForSkillInvoke(player, "f_dinghan", data) then
		if player:getPhase() == sgs.Player_RoundStart and room:askForSkillInvoke(player, self:objectName(), data) then
		    room:broadcastSkillInvoke("f_dinghan", 3)
			--增加或移除锦囊记录
		    local choice = room:askForChoice(player, "f_dinghan", "addtrickcard+rmvtrickcard+cancel", data)
			if choice == "addtrickcard" then
			    local choices = {}
				--【延时锦囊】
				if not (player:getMark("lbss") > 0 and player:getMark("sd") > 0 and player:getMark("blcd") > 0 and player:getMark("dz") > 0 and player:getMark("tf") > 0
				    and player:getMark("hsi") > 0 and player:getMark("hsn") > 0 and player:getMark("nsl") > 0) then
				    table.insert(choices, "dly")
				end
				--过河拆桥
			    if player:getMark("ghcq") == 0 then
		    	    table.insert(choices, "ghcq")
			    end
				--顺手牵羊
			    if player:getMark("ssqy") == 0 then
		    	    table.insert(choices, "ssqy")
			    end
				--借刀杀人
			    if player:getMark("jdsr") == 0 then
		    	    table.insert(choices, "jdsr")
			    end
				--无中生有
				if player:getMark("wzsy") == 0 then
		    	    table.insert(choices, "wzsy")
			    end
				--南蛮入侵
			    if player:getMark("nmrq") == 0 then
		    	    table.insert(choices, "nmrq")
			    end
				--万箭齐发
			    if player:getMark("wjqf") == 0 then
		    	    table.insert(choices, "wjqf")
			    end
				--五谷丰登
				if player:getMark("wgfd") == 0 then
		    	    table.insert(choices, "wgfd")
			    end
				--桃园结义
			    if player:getMark("tyjy") == 0 then
		    	    table.insert(choices, "tyjy")
			    end
				--决斗
			    if player:getMark("jd") == 0 then
		    	    table.insert(choices, "jd")
			    end
				--无懈可击
			    if player:getMark("wxkj") == 0 then
		    	    table.insert(choices, "wxkj")
			    end
				--铁索连环
			    if player:getMark("tslh") == 0 then
		    	    table.insert(choices, "tslh")
			    end
				--火攻
			    if player:getMark("hg") == 0 then
		    	    table.insert(choices, "hg")
			    end
				--水淹七军
				if player:getMark("syqj") == 0 then
		    	    table.insert(choices, "syqj")
			    end
				--洞烛先机
			    if player:getMark("dzxj") == 0 then
		    	    table.insert(choices, "dzxj")
			    end
				--逐近弃远
			    if player:getMark("zjqy") == 0 then
		    	    table.insert(choices, "zjqy")
			    end
				--出其不意
			    if player:getMark("cqby") == 0 then
		    	    table.insert(choices, "cqby")
			    end
				--随机应变
				if player:getMark("sjyb") == 0 then
		    	    table.insert(choices, "sjyb")
			    end
				--奇正相生
			    if player:getMark("qzxs") == 0 then
		    	    table.insert(choices, "qzxs")
			    end
				table.insert(choices, "cancel")
			    local choicee = room:askForChoice(player, "@f_dinghan1", table.concat(choices, "+"))
				if choicee == "dly" then
				    local choicess = {}
					--乐不思蜀
			    	if player:getMark("lbss") == 0 then
		    	    	table.insert(choicess, "lbss")
			    	end
					--闪电
					if player:getMark("sd") == 0 then
		    	    	table.insert(choicess, "sd")
			    	end
					--兵粮寸断
			    	if player:getMark("blcd") == 0 then
		    	    	table.insert(choicess, "blcd")
			    	end
					--地震
			    	if player:getMark("dz") == 0 then
		    	    	table.insert(choicess, "dz")
			    	end
					--台风
			    	if player:getMark("tf") == 0 then
		    	    	table.insert(choicess, "tf")
			    	end
					--洪水
			    	if player:getMark("hsi") == 0 then
		    	    	table.insert(choicess, "hsi")
			    	end
					--火山
					if player:getMark("hsn") == 0 then
		    	    	table.insert(choicess, "hsn")
			    	end
					--泥石流
			    	if player:getMark("nsl") == 0 then
		    	    	table.insert(choicess, "nsl")
			    	end
					table.insert(choicess, "cancel")
					local choicec = room:askForChoice(player, "@f_dinghand1", table.concat(choicess, "+"))
					--增加乐不思蜀
					if choicec == "lbss" then
				    	room:addPlayerMark(player, "lbss")
					--增加闪电
					elseif choicec == "sd" then
				    	room:addPlayerMark(player, "sd")
					--增加兵粮寸断
					elseif choicee == "blcd" then
				    	room:addPlayerMark(player, "blcd")
					--增加地震
					elseif choicee == "dz" then
				    	room:addPlayerMark(player, "dz")
					--增加台风
					elseif choicee == "tf" then
				    	room:addPlayerMark(player, "tf")
					--增加洪水
					elseif choicee == "hsi" then
				    	room:addPlayerMark(player, "hsi")
					--增加火山
					elseif choicee == "hsn" then
				    	room:addPlayerMark(player, "hsn")
					--增加泥石流
					elseif choicee == "nsl" then
				    	room:addPlayerMark(player, "nsl")
					end
				--增加过河拆桥
				elseif choicee == "ghcq" then
				    room:addPlayerMark(player, "ghcq")
				--增加顺手牵羊
				elseif choicee == "ssqy" then
				    room:addPlayerMark(player, "ssqy")
				--增加借刀杀人
				elseif choicee == "jdsr" then
				    room:addPlayerMark(player, "jdsr")
				--增加无中生有
				elseif choicee == "wzsy" then
				    room:addPlayerMark(player, "wzsy")
				--增加南蛮入侵
				elseif choicee == "nmrq" then
				    room:addPlayerMark(player, "nmrq")
				--增加万箭齐发
				elseif choicee == "wjqf" then
				    room:addPlayerMark(player, "wjqf")
				--增加五谷丰登
				elseif choicee == "wgfd" then
				    room:addPlayerMark(player, "wgfd")
				--增加桃园结义
				elseif choicee == "tyjy" then
				    room:addPlayerMark(player, "tyjy")
				--增加决斗
				elseif choicee == "jd" then
				    room:addPlayerMark(player, "jd")
				--增加无懈可击
				elseif choicee == "wxkj" then
				    room:addPlayerMark(player, "wxkj")
				--增加铁索连环
				elseif choicee == "tslh" then
				    room:addPlayerMark(player, "tslh")
				--增加火攻
				elseif choicee == "hg" then
				    room:addPlayerMark(player, "hg")
				--增加水淹七军
				elseif choicee == "syqj" then
				    room:addPlayerMark(player, "syqj")
				--增加洞烛先机
				elseif choicee == "dzxj" then
				    room:addPlayerMark(player, "dzxj")
				--增加逐近弃远
				elseif choicee == "zjqy" then
				    room:addPlayerMark(player, "zjqy")
				--增加出其不意
				elseif choicee == "cqby" then
				    room:addPlayerMark(player, "cqby")
				--增加随机应变
				elseif choicee == "sjyb" then
				    room:addPlayerMark(player, "sjyb")
				--增加奇正相生
				elseif choicee == "qzxs" then
				    room:addPlayerMark(player, "qzxs")
				end
			elseif choice == "rmvtrickcard" then
			    local choices = {}
				--【延时锦囊】
				if not (player:getMark("lbss") == 0 and player:getMark("sd") == 0 and player:getMark("blcd") == 0 and player:getMark("dz") == 0 and player:getMark("tf") == 0
				    and player:getMark("hsi") == 0 and player:getMark("hsn") == 0 and player:getMark("nsl") == 0) then
				    table.insert(choices, "dly")
				end
				--过河拆桥
			    if player:getMark("ghcq") > 0 then
		    	    table.insert(choices, "ghcq")
			    end
				--顺手牵羊
			    if player:getMark("ssqy") > 0 then
		    	    table.insert(choices, "ssqy")
			    end
				--借刀杀人
			    if player:getMark("jdsr") > 0 then
		    	    table.insert(choices, "jdsr")
			    end
				--无中生有
				if player:getMark("wzsy") > 0 then
		    	    table.insert(choices, "wzsy")
			    end
				--南蛮入侵
			    if player:getMark("nmrq") > 0 then
		    	    table.insert(choices, "nmrq")
			    end
				--万箭齐发
			    if player:getMark("wjqf") > 0 then
		    	    table.insert(choices, "wjqf")
			    end
				--五谷丰登
				if player:getMark("wgfd") > 0 then
		    	    table.insert(choices, "wgfd")
			    end
				--桃园结义
			    if player:getMark("tyjy") > 0 then
		    	    table.insert(choices, "tyjy")
			    end
				--决斗
			    if player:getMark("jd") > 0 then
		    	    table.insert(choices, "jd")
			    end
				--无懈可击
			    if player:getMark("wxkj") > 0 then
		    	    table.insert(choices, "wxkj")
			    end
				--铁索连环
			    if player:getMark("tslh") > 0 then
		    	    table.insert(choices, "tslh")
			    end
				--火攻
			    if player:getMark("hg") > 0 then
		    	    table.insert(choices, "hg")
			    end
				--水淹七军
				if player:getMark("syqj") > 0 then
		    	    table.insert(choices, "syqj")
			    end
				--洞烛先机
			    if player:getMark("dzxj") > 0 then
		    	    table.insert(choices, "dzxj")
			    end
				--逐近弃远
			    if player:getMark("zjqy") > 0 then
		    	    table.insert(choices, "zjqy")
			    end
				--出其不意
			    if player:getMark("cqby") > 0 then
		    	    table.insert(choices, "cqby")
			    end
				--随机应变
				if player:getMark("sjyb") > 0 then
		    	    table.insert(choices, "sjyb")
			    end
				--奇正相生
			    if player:getMark("qzxs") > 0 then
		    	    table.insert(choices, "qzxs")
			    end
				table.insert(choices, "cancel")
			    local choicee = room:askForChoice(player, "@f_dinghan2", table.concat(choices, "+"))
				if choicee == "dly" then
				    local choicess = {}
					--乐不思蜀
			    	if player:getMark("lbss") > 0 then
		    	    	table.insert(choicess, "lbss")
			    	end
					--闪电
					if player:getMark("sd") > 0 then
		    	    	table.insert(choicess, "sd")
			    	end
					--兵粮寸断
			    	if player:getMark("blcd") > 0 then
		    	    	table.insert(choicess, "blcd")
			    	end
					--地震
			    	if player:getMark("dz") > 0 then
		    	    	table.insert(choicess, "dz")
			    	end
					--台风
			    	if player:getMark("tf") > 0 then
		    	    	table.insert(choicess, "tf")
			    	end
					--洪水
			    	if player:getMark("hsi") > 0 then
		    	    	table.insert(choicess, "hsi")
			    	end
					--火山
					if player:getMark("hsn") > 0 then
		    	    	table.insert(choicess, "hsn")
			    	end
					--泥石流
			    	if player:getMark("nsl") > 0 then
		    	    	table.insert(choicess, "nsl")
			    	end
					table.insert(choicess, "cancel")
					local choicec = room:askForChoice(player, "@f_dinghand2", table.concat(choicess, "+"))
					--移除乐不思蜀
					if choicec == "lbss" then
				    	room:removePlayerMark(player, "lbss")
					--移除闪电
					elseif choicec == "sd" then
				    	room:removePlayerMark(player, "sd")
					--移除兵粮寸断
					elseif choicee == "blcd" then
				    	room:removePlayerMark(player, "blcd")
					--移除加地震
					elseif choicee == "dz" then
				    	room:removePlayerMark(player, "dz")
					--移除台风
					elseif choicee == "tf" then
				    	room:removePlayerMark(player, "tf")
					--移除洪水
					elseif choicee == "hsi" then
				    	room:removePlayerMark(player, "hsi")
					--移除火山
					elseif choicee == "hsn" then
				    	room:removePlayerMark(player, "hsn")
					--移除泥石流
					elseif choicee == "nsl" then
				    	room:removePlayerMark(player, "nsl")
					end
				--移除过河拆桥
				elseif choicee == "ghcq" then
				    room:removePlayerMark(player, "ghcq")
				--移除顺手牵羊
				elseif choicee == "ssqy" then
				    room:removePlayerMark(player, "ssqy")
				--移除借刀杀人
				elseif choicee == "jdsr" then
				    room:removePlayerMark(player, "jdsr")
				--移除无中生有
				elseif choicee == "wzsy" then
				    room:removePlayerMark(player, "wzsy")
				--移除南蛮入侵
				elseif choicee == "nmrq" then
				    room:removePlayerMark(player, "nmrq")
				--移除万箭齐发
				elseif choicee == "wjqf" then
				    room:removePlayerMark(player, "wjqf")
				--移除五谷丰登
				elseif choicee == "wgfd" then
				    room:removePlayerMark(player, "wgfd")
				--移除桃园结义
				elseif choicee == "tyjy" then
				    room:removePlayerMark(player, "tyjy")
				--移除决斗
				elseif choicee == "jd" then
				    room:removePlayerMark(player, "jd")
				--移除无懈可击
				elseif choicee == "wxkj" then
				    room:removePlayerMark(player, "wxkj")
				--移除铁索连环
				elseif choicee == "tslh" then
				    room:removePlayerMark(player, "tslh")
				--移除火攻
				elseif choicee == "hg" then
				    room:removePlayerMark(player, "hg")
				--移除水淹七军
				elseif choicee == "syqj" then
				    room:removePlayerMark(player, "syqj")
				--移除洞烛先机
				elseif choicee == "dzxj" then
				    room:removePlayerMark(player, "dzxj")
				--移除逐近弃远
				elseif choicee == "zjqy" then
				    room:removePlayerMark(player, "zjqy")
				--移除出其不意
				elseif choicee == "cqby" then
				    room:removePlayerMark(player, "cqby")
				--移除随机应变
				elseif choicee == "sjyb" then
				    room:removePlayerMark(player, "sjyb")
				--移除奇正相生
				elseif choicee == "qzxs" then
				    room:removePlayerMark(player, "qzxs")
				end
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_dinghan")
	end,
}
f_shenxunyu:addSkill(f_dinghan)
if not sgs.Sanguosha:getSkill("f_dinghanMR") then skills:append(f_dinghanMR) end



--

--(界)神太史慈（信）
f_shentaishici = sgs.General(extension, "f_shentaishici", "god", 4, true)

f_dulie = sgs.CreateTriggerSkill{
	name = "f_dulie",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.TargetConfirming},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
		    room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			for _, w in sgs.qlist(room:getOtherPlayers(player)) do
			    w:gainMark("&WEI", math.random(0,1))
			end
		elseif event == sgs.TargetConfirming then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") and use.from:getMark("&WEI") == 0 and use.to:contains(player) then
			    local judge = sgs.JudgeStruct()
			    judge.pattern = ".|heart"
			    judge.good = true
			    judge.play_animation = true
			    judge.who = player
			    judge.reason = "f_dulie"
			    room:judge(judge)
				if judge:isGood() then
				    local nullified_list = use.nullified_list
				    table.insert(nullified_list, player:objectName())
				    use.nullified_list = nullified_list
				    data:setValue(use)
					room:broadcastSkillInvoke(self:objectName())
				end
			end
		end
	end,
}
f_dulieEXS = sgs.CreateTargetModSkill{
    name = "f_dulieEXS",
	distance_limit_func = function(self, from, card, to)
	    if from:hasSkill("f_dulie") and to and to:getMark("&WEI") == 0 then
			return 1000
		else
			return 0
		end
	end,
}
f_shentaishici:addSkill(f_dulie)
if not sgs.Sanguosha:getSkill("f_dulieEXS") then skills:append(f_dulieEXS) end

f_powei = sgs.CreateTriggerSkill{
	name = "f_powei",
	frequency = sgs.Skill_Frequent,
	waked_skills = "f_shenzhuo",
	events = {sgs.DamageCaused, sgs.CardFinished, sgs.Dying},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DamageCaused then
		    local damage = data:toDamage()
			if damage.card:isKindOf("Slash") and damage.from:hasSkill(self:objectName()) and damage.to:getMark("&WEI") > 0 then
			    room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), 1)
			    damage.to:loseMark("&WEI")
				room:addPlayerMark(player, "f_poweisdc")
				return true
			end
		elseif event == sgs.CardFinished then
		    local use = data:toCardUse()
			if use.card:isKindOf("Slash") and player:getMark("f_powei_success") == 0 and player:getMark("f_powei_fail") == 0 then
				local can_invoke = true
		    	for _, w in sgs.qlist(room:getAllPlayers()) do
			    	if w:getMark("&WEI") > 0 then
				    	can_invoke = false
				    	break
			    	end
		    	end
				if can_invoke then
					--使命成功
					room:broadcastSkillInvoke(self:objectName(), 1)
					room:doLightbox("$f_powei")
			    	local log = sgs.LogMessage()
					log.type = "$f_poweiSUC"
					log.from = player
					room:sendLog(log)
					local s = player:getMark("f_poweisdc")
					room:drawCards(player, s, self:objectName())
					room:acquireSkill(player, "f_shenzhuo")
					room:addPlayerMark(player, "f_powei_success")
				end
			end
		elseif event == sgs.Dying then
			local dying = data:toDying()
			if dying.who:objectName() == player:objectName() and player:hasSkill(self:objectName()) and player:getMark("f_powei_success") == 0 and player:getMark("f_powei_fail") == 0 then
			    --使命失败
				local log = sgs.LogMessage()
				log.type = "$f_poweiFAL"
				log.from = player
				room:sendLog(log)
			    local maxhp = player:getMaxHp()
				local recover = math.min(1 - player:getHp(), maxhp - player:getHp()) --local hp = math.min(1, maxhp)
				room:recover(player, sgs.RecoverStruct(player, nil, recover)) --room:setPlayerProperty(player, "hp", sgs.QVariant(hp))
				player:throwAllEquips()
				room:broadcastSkillInvoke(self:objectName(), 2)
				room:addPlayerMark(player, "f_powei_fail")
			end
		end
	end,
}
f_shentaishici:addSkill(f_powei)
f_shentaishici:addRelateSkill("f_shenzhuo")
--“神著”
--[[f_shenzhuo = sgs.CreateTriggerSkill{
    name = "f_shenzhuo",
	frequency = sgs.Skill_Frequent,
	events = {sgs.BeforeCardsMove},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.from:objectName() == player:objectName() and move.card_ids:length() == 1 and move.from_places:contains(sgs.Player_PlaceTable) and move.reason.m_reason == sgs.CardMoveReason_S_REASON_USE then
			local card = sgs.Sanguosha:getCard(move.card_ids:first())
			if card:isKindOf("Slash") and not move.card_ids:isEmpty() then
		    	room:sendCompulsoryTriggerLog(player, self:objectName())
		    	room:broadcastSkillInvoke(self:objectName())
		    	room:drawCards(player, 1, self:objectName())
				data:setValue(move)
			end
		end
	end,
}]]
f_shenzhuo = sgs.CreateTriggerSkill{
	name = "f_shenzhuo",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if not use.card:isKindOf("Slash") or use.card:isVirtualCard() then return false end
		room:sendCompulsoryTriggerLog(player, self:objectName())
		room:broadcastSkillInvoke(self:objectName())
		room:drawCards(player, 1, self:objectName())
	end,
}
f_shenzhuoMAXS = sgs.CreateTargetModSkill{
	name = "f_shenzhuoMAXS",
	frequency = sgs.Skill_NotCompulsory,
	residue_func = function(self, player)
		if player:hasSkill("f_shenzhuo") then
			return 1000
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("f_shenzhuo") then skills:append(f_shenzhuo) end
if not sgs.Sanguosha:getSkill("f_shenzhuoMAXS") then skills:append(f_shenzhuoMAXS) end

--纪念再也不会出现的“荡魔”
f_dangmo = sgs.CreateTargetModSkill{
	name = "f_dangmo",
	extra_target_func = function(self, from, card)
		if from:hasSkill(self:objectName()) and not from:hasFlag("f_dangmo_Triggered") then
			local hp = from:getHp()
			if hp < 1 then
		    	hp = 1
			end
		    return hp - 1
		else
			return 0
		end
	end,
	distance_limit_func = function(self, from, card)
		if from:hasSkill(self:objectName()) and not from:hasFlag("f_dangmo_Triggered") then
			local hp = from:getLostHp()
			return hp
		else
			return 0
		end
	end,
}
f_shentaishici:addSkill(f_dangmo)

stscAudio = sgs.CreateTriggerSkill{ --完美“混音”，极致享受
    name = "stscAudio",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") then
		    if player:hasSkill("f_dulie") and player:getMark("&WEI") == 0 then
		        room:broadcastSkillInvoke("f_dulie")
			end
		    if player:hasSkill("f_dangmo") and player:getPhase() == sgs.Player.Play and not player:hasFlag("f_dangmo_Triggered") then
			    room:broadcastSkillInvoke("f_dangmo")
				room:setPlayerFlag(player, "f_dangmo_Triggered")
			end
			if player:hasSkill("f_shenzhuo") and player:getPhase() == sgs.Player.Play then
			    if not player:hasFlag("f_shenzhuo_MoreSlash") then
				    room:setPlayerFlag(player, "f_shenzhuo_MoreSlash")
				elseif player:hasFlag("f_shenzhuo_MoreSlash") then
				    room:broadcastSkillInvoke("f_shenzhuo")
				end
			end	
		end
	end,
}
if not sgs.Sanguosha:getSkill("stscAudio") then skills:append(stscAudio) end

--

--神太史慈-第二版
f_shentaishicii = sgs.General(extension, "f_shentaishicii", "god", 4, true)

f_duliee = sgs.CreateTriggerSkill{
	name = "f_duliee",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetConfirming},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") and use.to:contains(player) and use.from:getHp() > player:getHp() then
			local judge = sgs.JudgeStruct()
			judge.pattern = ".|heart"
			judge.good = true
			judge.play_animation = true
			judge.who = player
			judge.reason = "f_duliee"
			room:judge(judge)
			if judge:isGood() then
				local nullified_list = use.nullified_list
				table.insert(nullified_list, player:objectName())
				use.nullified_list = nullified_list
				data:setValue(use)
				room:broadcastSkillInvoke(self:objectName())
			end
		end
	end,
}
f_shentaishicii:addSkill(f_duliee)

f_poweii = sgs.CreateTriggerSkill{
	name = "f_poweii",
	global = true,
	frequency = sgs.Skill_Frequent,
	waked_skills = "f_shenzhuoo",
	events = {sgs.GameStart, sgs.Damaged, sgs.EventPhaseStart, sgs.Dying, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart and player:hasSkill(self:objectName()) then
		    room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName(), 1)
			for _, w in sgs.qlist(room:getOtherPlayers(player)) do
			    room:addPlayerMark(w, "&WEII")
			end
		elseif event == sgs.Damaged then
		    local damage = data:toDamage()
			if damage.to:getMark("&WEII") > 0 then
			    local stsc = room:findPlayerBySkillName(self:objectName())
				room:sendCompulsoryTriggerLog(stsc, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), 2)
			    damage.to:loseMark("&WEII")
			end
		elseif event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_RoundStart then
		    if player:hasSkill(self:objectName()) then
				for _, w in sgs.qlist(room:getAllPlayers()) do
			    	if w:getMark("&WEII") > 0 then
				    	room:setPlayerFlag(player, "WEIImove")
				    	break
			    	end
		    	end
				if player:hasFlag("WEIImove") then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName(), 1)
					local can_invoke = false
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if p:getMark("&WEII") == 0 then
							room:setPlayerFlag(p, "WEIIcantmove")
							can_invoke = true
						end
					end
					if can_invoke then
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			    			if p:getMark("&WEII") > 0 and not p:hasFlag("WEIIcantmove") then
				    			room:removePlayerMark(p, "&WEII")
								if not p:getNextAlive():hasFlag("WEIImove") then
									room:addPlayerMark(p:getNextAlive(), "&WEII")
								else
									local q = p:getNextAlive()
									room:addPlayerMark(q:getNextAlive(), "&WEII")
								end
			    			end
		    			end
					end
				else
					if player:getMark("f_poweii_success") == 0 and player:getMark("f_poweii_fail") == 0 then
						--使命成功
						room:broadcastSkillInvoke(self:objectName(), 2)
						room:doLightbox("$f_poweii")
			    		local log = sgs.LogMessage()
						log.type = "$f_poweiiSUC"
						log.from = player
						room:sendLog(log)
						room:acquireSkill(player, "f_shenzhuoo")
						room:addPlayerMark(player, "f_poweii_success")
					end
				end
			elseif player:getMark("&WEII") > 0 then
				local st = room:findPlayersBySkillName(self:objectName())
				if not st then return false end
				for _, sts in sgs.qlist(st) do
					if sts:objectName() ~= player:objectName() then
						local choices = {}
						if not sts:isKongcheng() then
		        			table.insert(choices, "1")
						end
						if not player:isKongcheng() and player:getHp() <= sts:getHp() then
			    			table.insert(choices, "2")
						end
						table.insert(choices, "cancel")
                		local choice = room:askForChoice(sts, self:objectName(), table.concat(choices, "+"))
						if choice == "1" then
							room:askForDiscard(sts, self:objectName(), 1, 1)
							room:broadcastSkillInvoke(self:objectName(), 1)
							room:damage(sgs.DamageStruct(self:objectName(), sts, player, 1, sgs.DamageStruct_Normal))
							room:setPlayerFlag(player, "iARPfrom")
							room:setPlayerFlag(sts, "iARPto")
							room:insertAttackRangePair(player, sts)
						elseif choice == "2" then
							room:broadcastSkillInvoke(self:objectName(), 1)
							local id = room:askForCardChosen(sts, player, "h", self:objectName())
				    		room:obtainCard(sts, id, false)
							room:setPlayerFlag(player, "iARPfrom")
							room:setPlayerFlag(sts, "iARPto")
							room:insertAttackRangePair(player, sts)
						end
					end
				end
			end
		elseif event == sgs.Dying then
			local dying = data:toDying()
			if dying.who:objectName() == player:objectName() and player:hasSkill(self:objectName()) and player:getMark("f_poweii_success") == 0 and player:getMark("f_poweii_fail") == 0 then
			    --使命失败
				local log = sgs.LogMessage()
				log.type = "$f_poweiiFAL"
				log.from = player
				room:sendLog(log)
			    local maxhp = player:getMaxHp()
				local recover = math.min(1 - player:getHp(), maxhp - player:getHp()) --local hp = math.min(1, maxhp)
				room:recover(player, sgs.RecoverStruct(player, nil, recover)) --room:setPlayerProperty(player, "hp", sgs.QVariant(hp))
				for _, w in sgs.qlist(room:getAllPlayers()) do
			    	if w:getMark("&WEII") > 0 then
				    	local x = w:getMark("&WEII")
						room:removePlayerMark(w, "&WEII", x)
			    	end
		    	end
				player:throwAllEquips()
				room:broadcastSkillInvoke(self:objectName(), 3)
				room:addPlayerMark(player, "f_poweii_fail")
			end
		elseif event == sgs.EventPhaseChanging and player:hasFlag("iARPfrom") then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
            	return false
        	end
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			    if p:hasFlag("iARPto") then
					room:removeAttackRangePair(player, p)
		    	end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_shentaishicii:addSkill(f_poweii)
f_shentaishicii:addRelateSkill("f_shenzhuoo")
--“神著”
--[[f_shenzhuoo = sgs.CreateTriggerSkill{
    name = "f_shenzhuoo",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.BeforeCardsMove, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.BeforeCardsMove then
			local move = data:toMoveOneTime()
			if move.from:objectName() == player:objectName() and move.card_ids:length() == 1 and move.from_places:contains(sgs.Player_PlaceTable) and move.reason.m_reason == sgs.CardMoveReason_S_REASON_USE then
				local card = sgs.Sanguosha:getCard(move.card_ids:first())
				if card:isKindOf("Slash") and not move.card_ids:isEmpty() then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					local choice = room:askForChoice(player, self:objectName(), "1+2")
					if choice == "1" then
		    			room:broadcastSkillInvoke(self:objectName())
		    			room:drawCards(player, 1, self:objectName())
						room:addPlayerMark(player, "szSlashaddOne")
					else
						room:broadcastSkillInvoke(self:objectName())
		    			room:drawCards(player, 3, self:objectName())
						room:setPlayerCardLimitation(player, "use", "Slash", true)
					end
					data:setValue(move)
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
			for _, p in sgs.qlist(room:getAllPlayers()) do
		    	local n = p:getMark("szSlashaddOne")
				room:removePlayerMark(player, "szSlashaddOne", n)
			end
		end
	end,
}]]
f_shenzhuoo = sgs.CreateTriggerSkill{
	name = "f_shenzhuoo",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardFinished, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardFinished then
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash") or use.card:isVirtualCard() then return false end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			local choice = room:askForChoice(player, self:objectName(), "1+2")
			if choice == "1" then
		    	room:broadcastSkillInvoke(self:objectName())
		    	room:drawCards(player, 1, self:objectName())
				room:addPlayerMark(player, "szSlashaddOne")
			else
				room:broadcastSkillInvoke(self:objectName())
		    	room:drawCards(player, 3, self:objectName())
				room:setPlayerCardLimitation(player, "use", "Slash", true)
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
			for _, p in sgs.qlist(room:getAllPlayers()) do
		    	local n = p:getMark("szSlashaddOne")
				room:removePlayerMark(player, "szSlashaddOne", n)
			end
		end
	end,
}
f_shenzhuooMAXS = sgs.CreateTargetModSkill{
	name = "f_shenzhuooMAXS",
	frequency = sgs.Skill_Compulsory,
	residue_func = function(self, player)
		if player:hasSkill("f_shenzhuoo") then
			local n = player:getMark("szSlashaddOne")
			return n
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("f_shenzhuoo") then skills:append(f_shenzhuoo) end
if not sgs.Sanguosha:getSkill("f_shenzhuooMAXS") then skills:append(f_shenzhuooMAXS) end

--(界)神孙策（信）
f_shensunce = sgs.General(extension, "f_shensunce", "god", 6, true, false, false, 1)

imbaCard = sgs.CreateSkillCard{
	name = "imbaCard",
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:getMaxHp() > 1 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
		local yuji = targets[1]
		room:loseMaxHp(yuji, 1)
		yuji:gainMark("&PingDing")
		room:loseMaxHp(source, 1)
	end,
}
--yingba
imba = sgs.CreateZeroCardViewAsSkill{
	name = "imba",
	view_as = function()
		return imbaCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#imbaCard")
	end,
}
imbaMaxDistance = sgs.CreateTargetModSkill{
    name = "imbaMaxDistance",
	pattern = "Card",
	distance_limit_func = function(self, from, card, to)
	    local n = 0
		if from:hasSkill("imba") and to and to:getMark("&PingDing") > 0 then
			n = n + 1000
		end
		return n
	end,
}
imbaNoLimit = sgs.CreateTargetModSkill{
	name = "imbaNoLimit",
	pattern = "Card",
	residue_func = function(self, from, card, to)
		local n = 0
		if from:hasSkill("imba") and to and to:getMark("&PingDing") > 0 then
			local m = to:getMark("&PingDing")
			n = n + m
		end
		return n
	end,
}
f_shensunce:addSkill(imba)
if not sgs.Sanguosha:getSkill("imbaMaxDistance") then skills:append(imbaMaxDistance) end
if not sgs.Sanguosha:getSkill("imbaNoLimit") then skills:append(imbaNoLimit) end

f_fuhai = sgs.CreateTriggerSkill{
	name = "f_fuhai",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecified, sgs.EventPhaseChanging, sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetSpecified then
		    local use = data:toCardUse()
			if use.card and not use.card:isKindOf("SkillCard") and use.from:objectName() == player:objectName() and player:hasSkill(self:objectName()) then
				local no_respond_list = use.no_respond_list
				for _, p in sgs.qlist(use.to) do
				    if p:getMark("&PingDing") > 0 then
						table.insert(no_respond_list, p:objectName())
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
					end
					use.no_respond_list = no_respond_list
					data:setValue(use)
					if p:getMark("&PingDing") > 0 and player:getMark("f_fuhaiDraw") < 2 then
						room:drawCards(player, 1, self:objectName())
						room:addPlayerMark(player, "f_fuhaiDraw")
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
		    local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("f_fuhaiDraw") > 0 then
					local n = p:getMark("f_fuhaiDraw")
					room:removePlayerMark(p, "f_fuhaiDraw", n)
				end
			end
		elseif event == sgs.Death then
		    local death = data:toDeath()
		    if death.who:objectName() ~= player:objectName() and death.who:getMark("&PingDing") > 0 and player:hasSkill(self:objectName()) then  
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), 3)
				local y = death.who:getMark("&PingDing")
				local count = player:getMaxHp()
				local mhp = sgs.QVariant()
				mhp:setValue(count + y)
				room:setPlayerProperty(player, "maxhp", mhp)
				room:drawCards(player, y, self:objectName())
			end
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
f_shensunce:addSkill(f_fuhai)

f_pinghe = sgs.CreateMaxCardsSkill{
    name = "f_pinghe",
    extra_func = function(self, player)
	    if player:hasSkill(self:objectName()) then
		    local hp = player:getLostHp()
			local hpx = player:getHp()
			return hp - hpx
	    else
		    return 0
	    end
	end,
}
f_pingheDefuseDamageCard = sgs.CreateSkillCard{
    name = "f_pingheDefuseDamageCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
	    return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
	    local zhouyu = targets[1]
		zhouyu:obtainCard(self, false)
	end,
}
f_pingheDefuseDamageVS = sgs.CreateViewAsSkill{
    name = "f_pingheDefuseDamage",
	n = 1,
	view_filter = function(self, selected, to_select)
	    return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
	    if #cards == 1 then
			local DD_card = f_pingheDefuseDamageCard:clone()
			DD_card:addSubcard(cards[1])
			return DD_card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng()
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@f_pingheDefuseDamage")
	end,
}
f_pingheDefuseDamage = sgs.CreateTriggerSkill{
    name = "f_pingheDefuseDamage",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted, sgs.HpRecover},
	view_as_skill = f_pingheDefuseDamageVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DamageInflicted then
			local damage = data:toDamage()
			if damage.from:objectName() ~= player:objectName() and not player:isKongcheng() and player:getMaxHp() > 1 then
		    	room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke("f_pinghe")
				room:loseMaxHp(player, 1)
				room:askForUseCard(player, "@@f_pingheDefuseDamage!", "@f_pingheDefuseDamage-card")
				if player:getState() == "robot" and not room:askForUseCard(player, "@@f_pingheDefuseDamage!", "@f_pingheDefuseDamage-card") then --这里是为了AI
			    	local zy = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName())
			    	local id = room:askForCardChosen(player, player, "h", self:objectName())
			    	room:obtainCard(zy, id, false)
				end
				if player:hasSkill("imba") then
					damage.from:gainMark("&PingDing")
				end
				return true
			end
		elseif event == sgs.HpRecover then
			local recover = data:toRecover()
			if player:getHp() > 1 then
				room:sendCompulsoryTriggerLog(player, "f_pinghe")
				room:broadcastSkillInvoke("f_pinghe")
				room:loseHp(player, 1)
				room:drawCards(player, player:getHp(), "f_pinghe")
			end
		end
	end,
	can_trigger = function(self, player)
	    return player:hasSkill("f_pinghe")
	end,
}
f_pingheAudio = sgs.CreateTriggerSkill{
    name = "f_pingheAudio",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:hasSkill("f_pinghe") and player:getPhase() == sgs.Player_Discard then
			room:sendCompulsoryTriggerLog(player, "f_pinghe")
			room:broadcastSkillInvoke("f_pinghe")
		end
	end,
}
f_shensunce:addSkill(f_pinghe)
if not sgs.Sanguosha:getSkill("f_pingheDefuseDamage") then skills:append(f_pingheDefuseDamage) end
if not sgs.Sanguosha:getSkill("f_pingheAudio") then skills:append(f_pingheAudio) end

--附赠：
  --张仲景-测试初版
zhangzhongjing_first = sgs.General(extension, "zhangzhongjing_first", "qun", 3, true)

f_jishi = sgs.CreateTriggerSkill{
    name = "f_jishi",
	priority = {-100, -100}, --优先级降到最低，给其他捡垃圾技能让路
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreCardUsed, sgs.CardResponded, sgs.Damage, sgs.Damaged, sgs.CardsMoveOneTime, sgs.CardFinished},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.PreCardUsed or event == sgs.CardResponded then
			local card = nil
			if event == sgs.PreCardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and card:getHandlingMethod() == sgs.Card_MethodUse then
				room:setCardFlag(card, "f_jishiwillTrigger")
			end
		elseif event == sgs.Damage or event == sgs.Damaged then --防决斗自伤
			local damage = data:toDamage()
			if damage.card and damage.card:hasFlag("f_jishiwillTrigger") then
				room:setCardFlag(damage.card, "-f_jishiwillTrigger")
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from:objectName() == player:objectName() and move.to_place == sgs.Player_DiscardPile then
				for _, i in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(i)
					if card:hasFlag("f_jishiwillTrigger") then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						player:addToPile("f_REN", card)
					end
				end
			elseif move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceSpecial) and table.contains(move.from_pile_names, "f_REN") then --实测仅“疗疫”给“仁”有效，故其他本应满足此条件的时机需要硬核添加
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:drawCards(player, 1, self:objectName())
			end
		end
	end,
}
zhangzhongjing_first:addSkill(f_jishi)
--当“仁”溢出：
--[[f_RENareaThrowCard = sgs.CreateSkillCard{
    name = "f_RENareaThrowCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		if source:hasSkill("f_jishi") then
			room:sendCompulsoryTriggerLog(source, "f_jishi")
			room:broadcastSkillInvoke("f_jishi")
			room:drawCards(source, 1, "f_jishi")
		end
	end,
}
f_RENareaThrowVS = sgs.CreateViewAsSkill{
    name = "f_RENareaThrow",
	n = 999,
	expand_pile = "f_REN",
    view_filter = function(self, selected, to_select)
		local n = sgs.Self:getPile("f_REN"):length()
		if #selected >= n-6 then return false end
		return sgs.Self:getPile("f_REN"):contains(to_select:getId())
	end,
	view_as = function(self, cards)
		local n = sgs.Self:getPile("f_REN"):length()
		if #cards ~= n-6 then return end
	    local vs_card = f_RENareaThrowCard:clone()
		if vs_card then
			vs_card:setSkillName(self:objectName())
			for _, v in ipairs(cards) do
				vs_card:addSubcard(v)
			end
		end
		return vs_card
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@f_RENareaThrow")
	end,
}]]
f_RENareaThrow = sgs.CreateTriggerSkill{ --“仁”区通用机制，设置成全局技能
    name = "f_RENareaThrow",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime},
	view_as_skill = f_RENareaThrowVS,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceSpecial and player:getPile("f_REN"):length() > 6 then
			--room:askForUseCard(player, "@@f_RENareaThrow!", "@f_RENareaThrow-card")
			--考虑点：一般情况下，“仁”最多能瞬间涨到10张（封顶6+疗疫4）
			local card1 = player:getPile("f_REN"):first()
			room:throwCard(card1, player, nil)
			if player:getPile("f_REN"):length() > 6 then
				local card2 = player:getPile("f_REN"):first()
				room:throwCard(card2, player, nil)
			end
			if player:getPile("f_REN"):length() > 6 then
				local card3 = player:getPile("f_REN"):first()
				room:throwCard(card3, player, nil)
			end
			if player:getPile("f_REN"):length() > 6 then
				local card4 = player:getPile("f_REN"):first()
				room:throwCard(card4, player, nil)
			end
			--再给两个容错：
			if player:getPile("f_REN"):length() > 6 then
				local card5 = player:getPile("f_REN"):first()
				room:throwCard(card5, player, nil)
			end
			if player:getPile("f_REN"):length() > 6 then
				local card6 = player:getPile("f_REN"):first()
				room:throwCard(card6, player, nil)
			end
			if player:hasSkill("f_jishi") then
				room:sendCompulsoryTriggerLog(player, "f_jishi")
				room:broadcastSkillInvoke("f_jishi")
				room:drawCards(player, 1, "f_jishi")
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("f_RENareaThrow") then skills:append(f_RENareaThrow) end

f_liaoyiCard = sgs.CreateSkillCard{
    name = "f_liaoyi",
    target_fixed = true,
	will_throw = false,
    on_use = function(self, room, source, targets)
	    local current = room:getCurrent()
		room:obtainCard(current, self)
		local n = source:getMark("f_liaoyiGive")
		room:removePlayerMark(source, "f_liaoyiGive", n)
	end,
}
f_liaoyiVS = sgs.CreateViewAsSkill{
    name = "f_liaoyi",
	n = 999,
	expand_pile = "f_REN",
	view_filter = function(self, selected, to_select)
		local n = sgs.Self:getMark("f_liaoyiGive")
		if #selected >= n then return false end
		return sgs.Self:getPile("f_REN"):contains(to_select:getId())
	end,
	view_as = function(self, cards)
		local n = sgs.Self:getMark("f_liaoyiGive")
		if #cards ~= n then return end
	    local vs_card = f_liaoyiCard:clone()
		if vs_card then
			vs_card:setSkillName(self:objectName())
			for _, v in ipairs(cards) do
				vs_card:addSubcard(v)
			end
		end
		return vs_card
	end,
	response_pattern = "@@f_liaoyi",
}
f_liaoyi = sgs.CreateTriggerSkill{
    name = "f_liaoyi",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd},
	view_as_skill = f_liaoyiVS,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_RoundStart then
			local zjj = room:findPlayersBySkillName(self:objectName())
			if not zjj then return false end
			local hc = player:getHandcardNum()
			local hp = player:getHp()
			if hc == hp then return false end
			local n
			if hc > hp then
				n = hc - hp
			elseif hc < hp then
				n = hp - hc
			end
			if n > 4 then n = 4 end
			for _, zj in sgs.qlist(zjj) do
				if zj:objectName() ~= player:objectName() and zj:getPile("f_REN"):length() >= n then
					if room:askForSkillInvoke(zj, self:objectName(), data) then
						if zj:hasFlag("f_liaoyiUsed") then return false end
						if hc < hp and zj:getPile("f_REN"):length() >= n then
							room:addPlayerMark(zj, "f_liaoyiGive", n)
							room:askForUseCard(zj, "@@f_liaoyi", "@f_liaoyi-card")
						elseif hc > hp then
							local zcard = room:askForExchange(player, self:objectName(), n, n, true, "f_liaoyiPut")
							zj:addToPile("f_REN", zcard)
							room:broadcastSkillInvoke(self:objectName())
						end
					end
				else
					room:setPlayerFlag(zj, "f_liaoyiUsed")
				end
			end
		elseif event == sgs.EventPhaseEnd then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("f_liaoyiUsed") then
					room:setPlayerFlag(p, "-f_liaoyiUsed")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
zhangzhongjing_first:addSkill(f_liaoyi)

f_binglunCard = sgs.CreateSkillCard{
    name = "f_binglunCard",
    target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
	    return #targets == 0
	end,
    on_effect = function(self, effect)
	    local room = effect.to:getRoom()
		if effect.from:hasSkill("f_jishi") then
			room:sendCompulsoryTriggerLog(effect.from, "f_jishi")
			room:broadcastSkillInvoke("f_jishi")
			room:drawCards(effect.from, 1, "f_jishi")
		end
		local choice = room:askForChoice(effect.to, "f_binglun", "1+2")
		if choice == "1" then
			room:drawCards(effect.to, 1, "f_binglun")
		elseif choice == "2" then
			room:addPlayerMark(effect.to, "&f_binglunREC")
		end
	end,
}
f_binglun = sgs.CreateOneCardViewAsSkill{
    name = "f_binglun",
	filter_pattern = ".|.|.|f_REN",
	expand_pile = "f_REN",
	view_as = function(self, originalCard)
	    local tCm_card = f_binglunCard:clone()
		tCm_card:addSubcard(originalCard:getId())
		return tCm_card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#f_binglunCard") and player:getPile("f_REN"):length() >= 1
	end,
}
f_binglunRecover = sgs.CreateTriggerSkill{
    name = "f_binglunRecover",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then return false end
		local zj = room:findPlayerBySkillName("f_binglun")
		if zj then
			room:sendCompulsoryTriggerLog(zj, "f_binglun")
			room:broadcastSkillInvoke("f_binglun")
		end
		room:recover(player, sgs.RecoverStruct(player))
		room:removePlayerMark(player, "&f_binglunREC")
	end,
	can_trigger = function(self, player)
		return player:getMark("&f_binglunREC") > 0
	end,
}
zhangzhongjing_first:addSkill(f_binglun)
if not sgs.Sanguosha:getSkill("f_binglunRecover") then skills:append(f_binglunRecover) end

--神关羽（海外服）
os_shenguanyu = sgs.General(extension, "os_shenguanyu", "god", 5, true)

oswushen = sgs.CreateFilterSkill{
	name = "oswushen",
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
oswushenNDL = sgs.CreateTargetModSkill{
	name = "oswushenNDL",
	distance_limit_func = function(self, from, card)
		if from:hasSkill("oswushen") and card:getSuit() == sgs.Card_Heart then
			return 1000
		else
			return 0
		end
	end,
}
oswushenNRL = sgs.CreateTargetModSkill{
	name = "oswushenNRL",
	residue_func = function(self, player, card)
		if player:hasSkill("oswushen") and card:getSuit() == sgs.Card_Heart then
			return 1000
		else
			return 0
		end
	end,
}
oswushenInvoke = sgs.CreateTriggerSkill{
    name = "oswushenInvoke",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreCardUsed, sgs.TargetSpecified, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.PreCardUsed then
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash") or use.card:getSuit() ~= sgs.Card_Heart or use.from:objectName() ~= player:objectName() or not player:hasSkill("oswushen") then return false end
			local extra_targets = room:getCardTargets(player, use.card, use.to)
			if extra_targets:isEmpty() then return false end
			local adds = sgs.SPlayerList()
			for _, p in sgs.qlist(extra_targets) do
				if p:getMark("&EMeng") > 0 then
					use.to:append(p)
					adds:append(p)
				end
			end
			if adds:isEmpty() then return false end
			room:sortByActionOrder(adds)
			room:sortByActionOrder(use.to)
			data:setValue(use)
			local log = sgs.LogMessage()
			log.type = "#QiaoshuiAdd"
			log.from = player
			log.to = adds
			log.card_str = use.card:toString()
			log.arg = "oswushen"
			room:sendLog(log)
			for _, p in sgs.qlist(adds) do
				room:doAnimate(1, player:objectName(), p:objectName())
			end
			room:notifySkillInvoked(player, self:objectName())
			room:broadcastSkillInvoke("olwushen")
		elseif event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") and player:hasSkill("oswushen") and not player:hasFlag("oswushenNotFirstSlash") then
			    room:sendCompulsoryTriggerLog(player, "oswushen")
				room:broadcastSkillInvoke("oswushen")
				local no_respond_list = use.no_respond_list
				for _, lm in sgs.qlist(use.to) do
					table.insert(no_respond_list, lm:objectName())
				end
				use.no_respond_list = no_respond_list
				data:setValue(use)
				room:setPlayerFlag(player, "oswushenNotFirstSlash")
			end
		else
			local change = data:toPhaseChange()
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("oswushenNotFirstSlash") then
					room:setPlayerFlag(p, "-oswushenNotFirstSlash")
				end
			end
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
os_shenguanyu:addSkill(oswushen)
if not sgs.Sanguosha:getSkill("oswushenNDL") then skills:append(oswushenNDL) end
if not sgs.Sanguosha:getSkill("oswushenNRL") then skills:append(oswushenNRL) end
if not sgs.Sanguosha:getSkill("oswushenInvoke") then skills:append(oswushenInvoke) end

oswuhun = sgs.CreateTriggerSkill{
	name = "oswuhun",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged, sgs.Damage},
	view_as_skill = oswuhunVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if event == sgs.Damaged then
			if damage.from and damage.from:objectName() ~= player:objectName() then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), 1)
				damage.from:gainMark("&EMeng", damage.damage)
			end
		elseif event == sgs.Damage then
			if damage.from and damage.from:objectName() == player:objectName() and damage.to and damage.to:getMark("&EMeng") > 0 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), 2)
				damage.to:gainMark("&EMeng", 1)
			end
		end
	end,
}
oswuhunDeathCard = sgs.CreateSkillCard{
    name = "oswuhunDeathCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
	    return to_select:getMark("&EMeng") > 0
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
	    for _, p in pairs(targets) do
			local n = p:getMark("&EMeng")
			room:loseHp(p, n)
			--room:removePlayerMark(p, "&EMeng", n)
		end
	end,
}
oswuhunDeathVS = sgs.CreateZeroCardViewAsSkill{
    name = "oswuhun",
	view_as = function()
	    return oswuhunDeathCard:clone()
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@oswuhunDeath")
	end,
}
oswuhunDeath = sgs.CreateTriggerSkill{
	name = "oswuhunDeath",
	global = true,
	--frequency = sgs.Skill_Compulsory, --设置成锁定技无法触发
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Death},
	view_as_skill = oswuhunDeathVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		if death.who:objectName() ~= player:objectName() then return false end
		local can_invoke = false
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:getMark("&EMeng") > 0 then
				can_invoke = true
				break
			end
		end
		if can_invoke then
			if room:askForSkillInvoke(player, "oswuhunDeathJudge", data) then
				local judge = sgs.JudgeStruct()
				judge.pattern = "Peach,GodSalvation"
				judge.good = true
				judge.negative = true
				judge.reason = "oswuhun"
				judge.who = player
				room:judge(judge)
				if judge:isBad() then
					room:broadcastSkillInvoke("oswuhun", 3)
					room:askForUseCard(player, "@@oswuhunDeath!", "@oswuhunDeath-card")
				else
					room:broadcastSkillInvoke("oswuhun", 4)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("oswuhun")
	end,
}
os_shenguanyu:addSkill(oswuhun)
if not sgs.Sanguosha:getSkill("oswuhunDeath") then skills:append(oswuhunDeath) end



--

--神吕蒙（海外服）
os_shenlvmeng = sgs.General(extension, "os_shenlvmeng", "god", 3, true)

function getCardList(intlist)
	local ids = sgs.CardList()
	for _, id in sgs.qlist(intlist) do
		ids:append(sgs.Sanguosha:getCard(id))
	end
	return ids
end
osshelie = sgs.CreateTriggerSkill{
	name = "osshelie",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart, sgs.EventPhaseChanging, sgs.TurnStart, sgs.CardUsed, sgs.CardResponded},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_Draw then return false end
			if not player:askForSkillInvoke(self:objectName(), data) then return false end
			local card_ids = room:getNCards(5)
			room:broadcastSkillInvoke(self:objectName())
			room:fillAG(card_ids)
			local to_get = sgs.IntList()
			local to_throw = sgs.IntList()
			while not card_ids:isEmpty() do
				local card_id = room:askForAG(player, card_ids, false, "shelie")
				card_ids:removeOne(card_id)
				to_get:append(card_id)
				local card = sgs.Sanguosha:getCard(card_id)
				local suit = card:getSuit()
				room:takeAG(player, card_id, false)
				local _card_ids = card_ids
				for i = 0, 150 do
					for _, id in sgs.qlist(_card_ids) do
						local c = sgs.Sanguosha:getCard(id)
						if c:getSuit() == suit then
							card_ids:removeOne(id)
							room:takeAG(nil, id, false)
							to_throw:append(id)
						end
					end
				end
			end
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			if not to_get:isEmpty() then
				dummy:addSubcards(getCardList(to_get))
				player:obtainCard(dummy)
			end
			dummy:clearSubcards()
			if not to_throw:isEmpty() then
				dummy:addSubcards(getCardList(to_throw))
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), "")
				room:throwCard(dummy, reason, nil)
			end
			dummy:deleteLater()
			room:clearAG()
			return true
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive or player:getMark(self:objectName()) > 0 then return false end
			if player:getMark("&osshelieSuits") >= player:getHp() then
				room:setPlayerMark(player, "&osshelieSuits", 0)
				room:addPlayerMark(player, self:objectName())
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local choice = room:askForChoice(player, self:objectName(), "1+2+cancel")
				if choice == "1" then
					player:setPhase(sgs.Player_Draw)
					room:broadcastProperty(player, "phase")
					local thread = room:getThread()
					if not thread:trigger(sgs.EventPhaseStart, room, player) then
						thread:trigger(sgs.EventPhaseProceeding, room, player)
					end
					thread:trigger(sgs.EventPhaseEnd, room, player)
					player:setPhase(sgs.Player_NotActive)
					room:broadcastProperty(player, "phase")
				elseif choice == "2" then
					player:setPhase(sgs.Player_Play)
					room:broadcastProperty(player, "phase")
					local thread = room:getThread()
					if not thread:trigger(sgs.EventPhaseStart, room, player) then
						thread:trigger(sgs.EventPhaseProceeding, room, player)
					end
					thread:trigger(sgs.EventPhaseEnd, room, player)
					player:setPhase(sgs.Player_NotActive)
					room:broadcastProperty(player, "phase")
				end
			end
			room:setPlayerMark(player, "&osshelieSuits", 0)
		elseif event == sgs.TurnStart then room:setPlayerMark(player, self:objectName(), 0)
		else
			local card = nil
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and card:getHandlingMethod() == sgs.Card_MethodUse and not card:isKindOf("SkillCard") and player:getPhase() ~= sgs.Player_NotActive then
				if card:getSuit() == sgs.Card_Heart and not player:hasFlag("osshelieHeart") then
					room:setPlayerFlag(player, "osshelieHeart")
					room:addPlayerMark(player, "&osshelieSuits")
				elseif card:getSuit() == sgs.Card_Diamond and not player:hasFlag("osshelieDiamond") then
					room:setPlayerFlag(player, "osshelieDiamond")
					room:addPlayerMark(player, "&osshelieSuits")
				elseif card:getSuit() == sgs.Card_Club and not player:hasFlag("osshelieClub") then
					room:setPlayerFlag(player, "osshelieClub")
					room:addPlayerMark(player, "&osshelieSuits")
				elseif card:getSuit() == sgs.Card_Spade and not player:hasFlag("osshelieSpade") then
					room:setPlayerFlag(player, "osshelieSpade")
					room:addPlayerMark(player, "&osshelieSuits")
				elseif card:getSuit() == sgs.Card_NoSuit and not player:hasFlag("osshelieNoSuit") then
					room:setPlayerFlag(player, "osshelieNoSuit")
					room:addPlayerMark(player, "&osshelieSuits")
				end
			end
		end
	end,
}
os_shenlvmeng:addSkill(osshelie)

osgongxinCard = sgs.CreateSkillCard{
	name = "osgongxinCard",
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		if not effect.to:isKongcheng() then
			local ids = sgs.IntList()
			for _, card in sgs.qlist(effect.to:getHandcards()) do
				ids:append(card:getEffectiveId())
				--同时也记录其手牌的花色情况
				if card:getSuit() == sgs.Card_Heart and not effect.to:hasFlag("osgongxinHeart") then
					room:setPlayerFlag(effect.to, "osgongxinHeart")
				elseif card:getSuit() == sgs.Card_Diamond and not effect.to:hasFlag("osgongxinDiamond") then
					room:setPlayerFlag(effect.to, "osgongxinDiamond")
				elseif card:getSuit() == sgs.Card_Club and not effect.to:hasFlag("osgongxinClub") then
					room:setPlayerFlag(effect.to, "osgongxinClub")
				elseif card:getSuit() == sgs.Card_Spade and not effect.to:hasFlag("osgongxinSpade") then
					room:setPlayerFlag(effect.to, "osgongxinSpade")
				end
			end
			local card_id = room:doGongxin(effect.from, effect.to, ids)
			if (card_id == -1) then return end
			local result = room:askForChoice(effect.from, "osgongxin", "discard+put")
			effect.from:removeTag("osgongxin")
			if result == "discard" then
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, effect.from:objectName(), nil, "osgongxin", nil)
				room:throwCard(sgs.Sanguosha:getCard(card_id), reason, effect.to, effect.from)
			else
				effect.from:setFlags("Global_GongxinOperatorr")
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, effect.from:objectName(), nil, "osgongxin", nil)
				room:moveCardTo(sgs.Sanguosha:getCard(card_id), effect.to, nil, sgs.Player_DrawPile, reason, true)
				effect.from:setFlags("-Global_GongxinOperatorr")
			end
			for _, card in sgs.qlist(effect.to:getHandcards()) do --执行操作后，再次结算其手牌的花色情况
				if card:getSuit() == sgs.Card_Heart and effect.to:hasFlag("osgongxinHeart") then
					room:setPlayerFlag(effect.to, "-osgongxinHeart")
				elseif card:getSuit() == sgs.Card_Diamond and effect.to:hasFlag("osgongxinDiamond") then
					room:setPlayerFlag(effect.to, "-osgongxinDiamond")
				elseif card:getSuit() == sgs.Card_Club and effect.to:hasFlag("osgongxinClub") then
					room:setPlayerFlag(effect.to, "-osgongxinClub")
				elseif card:getSuit() == sgs.Card_Spade and effect.to:hasFlag("osgongxinSpade") then
					room:setPlayerFlag(effect.to, "-osgongxinSpade")
				end
			end
			if effect.to:hasFlag("osgongxinHeart") or effect.to:hasFlag("osgongxinDiamond")
			or effect.to:hasFlag("osgongxinClub") or effect.to:hasFlag("osgongxinSpade") then --若仍残存有标志，证明某些花色因“攻心”而失去，逃过了结算的标志清除
				local choice = room:askForChoice(effect.from, "osgongxin", "red+black+cancel")
				if choice == "red" then
					room:broadcastSkillInvoke("osgongxin")
					room:setPlayerFlag(effect.to, "osgongxinCardLimited-RED") --回合结束解除限制用
					room:setPlayerCardLimitation(effect.to, "use,response", ".|red|.|.", false)
				elseif choice == "black" then
					room:broadcastSkillInvoke("osgongxin")
					room:setPlayerFlag(effect.to, "osgongxinCardLimited-BLACK") --回合结束解除限制用
					room:setPlayerCardLimitation(effect.to, "use,response", ".|black|.|.", false)
				end
			end
			if effect.to:hasFlag("osgongxinHeart") then room:setPlayerFlag(effect.to, "-osgongxinHeart") end
			if effect.to:hasFlag("osgongxinDiamond") then room:setPlayerFlag(effect.to, "-osgongxinDiamond") end
			if effect.to:hasFlag("osgongxinClub") then room:setPlayerFlag(effect.to, "-osgongxinClub") end
			if effect.to:hasFlag("osgongxinSpade") then room:setPlayerFlag(effect.to, "-osgongxinSpade") end
		end
	end,
}
osgongxin = sgs.CreateZeroCardViewAsSkill{
	name = "osgongxin",
	view_as = function()
		return osgongxinCard:clone()
	end,
	enabled_at_play = function(self, target)
		return not target:hasUsed("#osgongxinCard")
	end,
}
osgongxinClear = sgs.CreateTriggerSkill{
	name = "osgongxinClear",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging, sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then return false end
		end
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:hasFlag("osgongxinCardLimited-RED") then
				room:removePlayerCardLimitation(p, "use,response", ".|red|.|.")
				room:setPlayerFlag(p, "-osgongxinCardLimited-RED")
			end
			if p:hasFlag("osgongxinCardLimited-BLACK") then
				room:removePlayerCardLimitation(p, "use,response", ".|black|.|.")
				room:setPlayerFlag(p, "-osgongxinCardLimited-BLACK")
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
os_shenlvmeng:addSkill(osgongxin)
if not sgs.Sanguosha:getSkill("osgongxinClear") then skills:append(osgongxinClear) end

--==十周年神武将==--
--神姜维(神·武)
  --爆料版->怒麟燎原
ty_shenjiangweiBN = sgs.General(extension_t, "ty_shenjiangweiBN", "god", 4, true, true)

tyjiufaBN = sgs.CreateTriggerSkill{
    name = "tyjiufaBN",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.CardResponded, sgs.MarkChanged},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.CardUsed or event == sgs.CardResponded then
			local card = nil
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and card:getHandlingMethod() == sgs.Card_MethodUse and not card:isKindOf("SkillCard") then
				local names, name = player:property("tyjiufaBNRecord"):toString():split("+"), card:objectName()
				if table.contains(names, name) then return false end
				table.insert(names, name)
				room:setPlayerProperty(player, "tyjiufaBNRecord", sgs.QVariant(table.concat(names, "+"))) --记录牌名
				room:addPlayerMark(player, "&tyjiufaBNRecord")
				room:broadcastSkillInvoke(self:objectName())
			end
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			if mark.name == "&tyjiufaBNRecord" and mark.who and mark.who:getMark("&tyjiufaBNRecord") >= 9 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local card_ids = room:getNCards(9)
				room:fillAG(card_ids)
				local to_get = sgs.IntList()
				local to_throw = sgs.IntList()
				while not card_ids:isEmpty() do
					local card_id = room:askForAG(player, card_ids, false, self:objectName())
					card_ids:removeOne(card_id)
					to_get:append(card_id)
					local card = sgs.Sanguosha:getCard(card_id)
					local number = card:getNumber()
					room:takeAG(player, card_id, false)
					local _card_ids = card_ids
					for i = 0, 150 do
						for _, id in sgs.qlist(_card_ids) do
							local c = sgs.Sanguosha:getCard(id)
							if c:getNumber() == number then
								card_ids:removeOne(id)
								room:takeAG(nil, id, false)
								to_throw:append(id)
							end
						end
					end
				end
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				if not to_get:isEmpty() then
					dummy:addSubcards(getCardList(to_get))
					player:obtainCard(dummy)
				end
				dummy:clearSubcards()
				if not to_throw:isEmpty() then
					dummy:addSubcards(getCardList(to_throw))
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), "")
					room:throwCard(dummy, reason, nil)
				end
				dummy:deleteLater()
				room:clearAG()
				local record, tyjiufaBN, cards = sgs.IntList(), player:property("tyjiufaBNRecord"):toString():split("+"), {}
				for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
					local c = sgs.Sanguosha:getEngineCard(id)
					if table.contains(cards, c:objectName()) then continue end
					table.insert(cards, c:objectName())
					if table.contains(tyjiufaBN, c:objectName()) then
						record:append(id)
					end
				end
				for _, rid in sgs.qlist(record) do
					local name = sgs.Sanguosha:getEngineCard(rid):objectName()
					table.removeOne(tyjiufaBN, name)
					room:setPlayerProperty(player, "tyjiufaBNRecord", sgs.QVariant(table.concat(tyjiufaBN, "+")))
				end
				local n = player:getMark("&tyjiufaBNRecord")
				room:removePlayerMark(player, "&tyjiufaBNRecord", n)
			end
		end
	end,
}
ty_shenjiangweiBN:addSkill(tyjiufaBN)

--[[tytianrenBN = sgs.CreateTriggerSkill{
    name = "tytianrenBN",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreCardUsed, sgs.CardResponded, sgs.BeforeCardsMove, sgs.CardsMoveOneTime, sgs.MarkChanged},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.PreCardUsed or event == sgs.CardResponded then
			local card = nil
			if event == sgs.PreCardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and card:getHandlingMethod() == sgs.Card_MethodUse then
				room:setCardFlag(card, "tytianrenBNUse")
			end
		elseif event == sgs.BeforeCardsMove then --防止重复触发
			local move = data:toMoveOneTime()
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("tytianrenBNTriggered") then
					room:setPlayerFlag(p, "-tytianrenBNTriggered")
				end
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.to_place == sgs.Player_DiscardPile then
				local can_invoke = false
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if (card:isKindOf("BasicCard") or card:isNDTrick()) and not card:hasFlag("tytianrenBNUse") then
						can_invoke = true
					end
				end
				if can_invoke then
					for _, tysjw in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
						if tysjw:hasFlag("tytianrenBNTriggered") then return false end
						room:sendCompulsoryTriggerLog(tysjw, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						tysjw:gainMark("&tytianrenBN")
						room:setPlayerFlag(tysjw, "tytianrenBNTriggered")
					end
				end
			end
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			if mark.name == "&tytianrenBN" and mark.who:getMark("&tytianrenBN") >= mark.who:getMaxHp() and mark.who:objectName() == player:objectName() and player:hasSkill(self:objectName()) then
				local mhp = player:getMaxHp()
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp+1))
				player:loseMark("&tytianrenBN", mhp)
				room:drawCards(player, 2, self:objectName())
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}]]
tytianrenBN = sgs.CreateTriggerSkill{
    name = "tytianrenBN",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreCardUsed, sgs.CardResponded, sgs.BeforeCardsMove, sgs.CardsMoveOneTime, sgs.MarkChanged},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.PreCardUsed or event == sgs.CardResponded then
			local card = nil
			if event == sgs.PreCardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and card:getHandlingMethod() == sgs.Card_MethodUse then
				room:setCardFlag(card, "tytianrenBNUse")
			end
		elseif event == sgs.BeforeCardsMove then --防止重复触发
			local move = data:toMoveOneTime()
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("tytianrenBNTriggered") then
					room:setPlayerFlag(p, "-tytianrenBNTriggered")
				end
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.to_place == sgs.Player_DiscardPile then
				local can_invoke = false
				local n = 0
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if (card:isKindOf("BasicCard") or card:isNDTrick()) and not card:hasFlag("tytianrenBNUse") then
						can_invoke = true
						n = n + 1
					end
				end
				if can_invoke then
					for _, tysjw in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
						if tysjw:hasFlag("tytianrenBNTriggered") then return false end
						room:sendCompulsoryTriggerLog(tysjw, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						tysjw:gainMark("&tytianrenBN", n)
						room:setPlayerFlag(tysjw, "tytianrenBNTriggered")
					end
				end
			end
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			if mark.name == "&tytianrenBN" and mark.who:getMark("&tytianrenBN") >= mark.who:getMaxHp() and mark.who:objectName() == player:objectName() and player:hasSkill(self:objectName()) then
				local mhp = player:getMaxHp()
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp+1))
				player:loseMark("&tytianrenBN", mhp)
				room:drawCards(player, 2, self:objectName())
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
ty_shenjiangweiBN:addSkill(tytianrenBN)

typingxiangBNCard = sgs.CreateSkillCard{ --全扩最强大招
	name = "typingxiangBNCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets < 9 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@typingxiangBN")
		room:loseMaxHp(source, 9)
		if not source:isAlive() then return false end
		room:broadcastSkillInvoke("typingxiangBN")
		room:doSuperLightbox("ty_shenjiangweiBN", "typingxiangBN")
		for _, p in pairs(targets) do
			if p then
				room:addPlayerMark(source, "typingxiangBNTargets") --检测选了多少人
			end
		end
		local n = source:getMark("typingxiangBNTargets")
		if n == 9 then --9人，1人1点
			for _, p in pairs(targets) do
				room:damage(sgs.DamageStruct("typingxiangBN", source, p, 1, sgs.DamageStruct_Normal))
			end
		elseif n == 1 then --1人，直接9点
			for _, p in pairs(targets) do
				room:damage(sgs.DamageStruct("typingxiangBN", source, p, 9, sgs.DamageStruct_Normal))
			end
		else
			room:addPlayerMark(source, "typingxiangBNLastDamageDbt", 9) --后续分配伤害用
			--其他情况，需要分配伤害
			for _, p in pairs(targets) do
				local choices = {}
				if source:getMark("typingxiangBNTargets") > 1 then --仅剩一名已选择目标且此时仍未分配完伤害时，必须分配有伤害
					table.insert(choices, "0")
				end
				if source:getMark("typingxiangBNTargets") > 1 or source:getMark("typingxiangBNLastDamageDbt")/source:getMark("typingxiangBNTargets") <= 1 then
					table.insert(choices, "1")
				end
				if (source:getMark("typingxiangBNTargets") > 1 or source:getMark("typingxiangBNLastDamageDbt")/source:getMark("typingxiangBNTargets") <= 2)
				and source:getMark("typingxiangBNLastDamageDbt") >= 2 then
					table.insert(choices, "2")
				end
				if (source:getMark("typingxiangBNTargets") > 1 or source:getMark("typingxiangBNLastDamageDbt")/source:getMark("typingxiangBNTargets") <= 3)
				and source:getMark("typingxiangBNLastDamageDbt") >= 3 then
					table.insert(choices, "3")
				end
				if (source:getMark("typingxiangBNTargets") > 1 or source:getMark("typingxiangBNLastDamageDbt")/source:getMark("typingxiangBNTargets") <= 4)
				and source:getMark("typingxiangBNLastDamageDbt") >= 4 then
					table.insert(choices, "4")
				end
				if (source:getMark("typingxiangBNTargets") > 1 or source:getMark("typingxiangBNLastDamageDbt")/source:getMark("typingxiangBNTargets") <= 5)
				and source:getMark("typingxiangBNLastDamageDbt") >= 5 then
					table.insert(choices, "5")
				end
				if (source:getMark("typingxiangBNTargets") > 1 or source:getMark("typingxiangBNLastDamageDbt")/source:getMark("typingxiangBNTargets") <= 6)
				and source:getMark("typingxiangBNLastDamageDbt") >= 6 then
					table.insert(choices, "6")
				end
				if (source:getMark("typingxiangBNTargets") > 1 or source:getMark("typingxiangBNLastDamageDbt")/source:getMark("typingxiangBNTargets") <= 7)
				and source:getMark("typingxiangBNLastDamageDbt") >= 7 then
					table.insert(choices, "7")
				end
				if source:getMark("typingxiangBNLastDamageDbt") >= 8 and source:getMark("typingxiangBNLastDamageDbt")/source:getMark("typingxiangBNTargets") <= 8 then
					table.insert(choices, "8")
				end
				if source:getMark("typingxiangBNLastDamageDbt") == 9 then
					table.insert(choices, "9")
				end
				local choice = room:askForChoice(source, "typingxiangBNDamageDbt", table.concat(choices, "+"))
				if choice == "1" then
					room:addPlayerMark(p, "typingxiangBNDMG") --先给标记记录伤害值后续再统一造成伤害，防止根据场上形势确定分配量
					room:removePlayerMark(source, "typingxiangBNLastDamageDbt")
				elseif choice == "2" then
					room:addPlayerMark(p, "typingxiangBNDMG", 2)
					room:removePlayerMark(source, "typingxiangBNLastDamageDbt", 2)
				elseif choice == "3" then
					room:addPlayerMark(p, "typingxiangBNDMG", 3)
					room:removePlayerMark(source, "typingxiangBNLastDamageDbt", 3)
				elseif choice == "4" then
					room:addPlayerMark(p, "typingxiangBNDMG", 4)
					room:removePlayerMark(source, "typingxiangBNLastDamageDbt", 4)
				elseif choice == "5" then
					room:addPlayerMark(p, "typingxiangBNDMG", 5)
					room:removePlayerMark(source, "typingxiangBNLastDamageDbt", 5)
				elseif choice == "6" then
					room:addPlayerMark(p, "typingxiangBNDMG", 6)
					room:removePlayerMark(source, "typingxiangBNLastDamageDbt", 6)
				elseif choice == "7" then
					room:addPlayerMark(p, "typingxiangBNDMG", 7)
					room:removePlayerMark(source, "typingxiangBNLastDamageDbt", 7)
				elseif choice == "8" then
					room:addPlayerMark(p, "typingxiangBNDMG", 8)
					room:removePlayerMark(source, "typingxiangBNLastDamageDbt", 8)
				elseif choice == "9" then
					room:addPlayerMark(p, "typingxiangBNDMG", 9)
					room:removePlayerMark(source, "typingxiangBNLastDamageDbt", 9)
				end
				room:removePlayerMark(source, "typingxiangBNTargets")
				if source:getMark("typingxiangBNLastDamageDbt") == 0 then break end
			end
			for _, p in pairs(targets) do
				local d = p:getMark("typingxiangBNDMG")
				if d > 0 then
					room:damage(sgs.DamageStruct("typingxiangBN", source, p, d, sgs.DamageStruct_Normal))
					room:removePlayerMark(p, "typingxiangBNDMG", d)
				end
			end
		end
		local m = source:getMark("typingxiangBNTargets")
		room:removePlayerMark(source, "typingxiangBNTargets", m)
		if source:hasSkill("tyjiufaBN") then
			room:detachSkillFromPlayer(source, "tyjiufaBN")
		end
	end,
}
typingxiangBNVS = sgs.CreateZeroCardViewAsSkill{
	name = "typingxiangBN",
	view_as = function()
		return typingxiangBNCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@typingxiangBN") > 0
	end,
}
typingxiangBN = sgs.CreateTriggerSkill{
	name = "typingxiangBN",
	frequency = sgs.Skill_Limited,
	limit_mark = "@typingxiangBN",
	view_as_skill = typingxiangBNVS,
	on_trigger = function()
	end,
}
ty_shenjiangweiBN:addSkill(typingxiangBN)

  --正式版(界)
ty_shenjiangwei = sgs.General(extension_t, "ty_shenjiangwei", "god", 4, true)

tyjiufa = sgs.CreateTriggerSkill{
    name = "tyjiufa",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.CardResponded, sgs.MarkChanged},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.CardUsed or event == sgs.CardResponded then
			local card = nil
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				--if response.m_isUse then
					card = response.m_card
				--end
			end
			if card --[[and card:getHandlingMethod() == sgs.Card_MethodUse]] and not card:isKindOf("SkillCard") then
				local names, name = player:property("tyjiufaRecord"):toString():split("+"), card:objectName()
				if table.contains(names, name) then return false end
				table.insert(names, name)
				room:setPlayerProperty(player, "tyjiufaRecord", sgs.QVariant(table.concat(names, "+"))) --记录牌名
				room:addPlayerMark(player, "&tyjiufaRecord")
				if player:getGeneralName() == "ty_shenjiangwei_1" or player:getGeneral2Name() == "ty_shenjiangwei_1" then
					room:broadcastSkillInvoke(self:objectName(), math.random(3,4))
				else
					room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
				end
			end
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			if mark.name == "&tyjiufaRecord" and mark.who and mark.who:getMark("&tyjiufaRecord") >= 9 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				if player:getGeneralName() == "ty_shenjiangwei_1" or player:getGeneral2Name() == "ty_shenjiangwei_1" then
					room:broadcastSkillInvoke(self:objectName(), math.random(3,4))
				else
					room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
				end
				local card_ids = room:getNCards(9)
				room:fillAG(card_ids)
				local to_get = sgs.IntList()
				local to_throw = sgs.IntList()
				local card_ids_ = card_ids
				for _, i in sgs.qlist(card_ids_) do --第一步：剔除所有点数不重复的牌
					local num = sgs.Sanguosha:getCard(i):getNumber()
					if num == 1 then --不考虑范围不在1~13之内的点数了
						room:addPlayerMark(player, "tyjiufaRPTA")
					elseif num == 2 then
						room:addPlayerMark(player, "tyjiufaRPT2")
					elseif num == 3 then
						room:addPlayerMark(player, "tyjiufaRPT3")
					elseif num == 4 then
						room:addPlayerMark(player, "tyjiufaRPT4")
					elseif num == 5 then
						room:addPlayerMark(player, "tyjiufaRPT5")
					elseif num == 6 then
						room:addPlayerMark(player, "tyjiufaRPT6")
					elseif num == 7 then
						room:addPlayerMark(player, "tyjiufaRPT7")
					elseif num == 8 then
						room:addPlayerMark(player, "tyjiufaRPT8")
					elseif num == 9 then
						room:addPlayerMark(player, "tyjiufaRPT9")
					elseif num == 10 then
						room:addPlayerMark(player, "tyjiufaRPT10")
					elseif num == 11 then
						room:addPlayerMark(player, "tyjiufaRPTJ")
					elseif num == 12 then
						room:addPlayerMark(player, "tyjiufaRPTQ")
					elseif num == 13 then
						room:addPlayerMark(player, "tyjiufaRPTK")
					end
				end
				for i = 0, 150 do --果然，不加这句必定会有BUG，写“涉猎”代码的前辈yyds
					for _, i in sgs.qlist(card_ids_) do
						local num = sgs.Sanguosha:getCard(i):getNumber()
						if (num == 1 and player:getMark("tyjiufaRPTA") <= 1) or (num == 2 and player:getMark("tyjiufaRPT2") <= 1) or (num == 3 and player:getMark("tyjiufaRPT3") <= 1)
						or (num == 4 and player:getMark("tyjiufaRPT4") <= 1) or (num == 5 and player:getMark("tyjiufaRPT5") <= 1) or (num == 6 and player:getMark("tyjiufaRPT6") <= 1)
						or (num == 7 and player:getMark("tyjiufaRPT7") <= 1) or (num == 8 and player:getMark("tyjiufaRPT8") <= 1) or (num == 9 and player:getMark("tyjiufaRPT9") <= 1)
						or (num == 10 and player:getMark("tyjiufaRPT10") <= 1) or (num == 11 and player:getMark("tyjiufaRPTJ") <= 1) or (num == 12 and player:getMark("tyjiufaRPTQ") <= 1)
						or (num == 13 and player:getMark("tyjiufaRPTK") <= 1) then
							card_ids:removeOne(i)
							room:takeAG(nil, i, false)
							to_throw:append(i)
						end
					end
				end
				room:setPlayerMark(player, "tyjiufaRPTA", 0)
				room:setPlayerMark(player, "tyjiufaRPT2", 0)
				room:setPlayerMark(player, "tyjiufaRPT3", 0)
				room:setPlayerMark(player, "tyjiufaRPT4", 0)
				room:setPlayerMark(player, "tyjiufaRPT5", 0)
				room:setPlayerMark(player, "tyjiufaRPT6", 0)
				room:setPlayerMark(player, "tyjiufaRPT7", 0)
				room:setPlayerMark(player, "tyjiufaRPT8", 0)
				room:setPlayerMark(player, "tyjiufaRPT9", 0)
				room:setPlayerMark(player, "tyjiufaRPT10", 0)
				room:setPlayerMark(player, "tyjiufaRPTJ", 0)
				room:setPlayerMark(player, "tyjiufaRPTQ", 0)
				room:setPlayerMark(player, "tyjiufaRPTK", 0)
				while not card_ids:isEmpty() do --第二步：从剩余的牌中选择点数不同的牌各一张
					local card_id = room:askForAG(player, card_ids, false, self:objectName())
					card_ids:removeOne(card_id)
					to_get:append(card_id)
					local card = sgs.Sanguosha:getCard(card_id)
					local number = card:getNumber()
					room:takeAG(player, card_id, false)
					local _card_ids = card_ids
					for i = 0, 150 do
						for _, id in sgs.qlist(_card_ids) do
							local c = sgs.Sanguosha:getCard(id)
							if c:getNumber() == number then
								card_ids:removeOne(id)
								room:takeAG(nil, id, false)
								to_throw:append(id)
							end
						end
					end
				end
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				if not to_get:isEmpty() then
					dummy:addSubcards(getCardList(to_get))
					player:obtainCard(dummy)
				end
				dummy:clearSubcards()
				if not to_throw:isEmpty() then
					dummy:addSubcards(getCardList(to_throw))
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), "")
					room:throwCard(dummy, reason, nil)
				end
				dummy:deleteLater()
				room:clearAG()
				local record, tyjiufa, cards = sgs.IntList(), player:property("tyjiufaRecord"):toString():split("+"), {}
				for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
					local c = sgs.Sanguosha:getEngineCard(id)
					if table.contains(cards, c:objectName()) then continue end
					table.insert(cards, c:objectName())
					if table.contains(tyjiufa, c:objectName()) then
						record:append(id)
					end
				end
				for _, rid in sgs.qlist(record) do
					local name = sgs.Sanguosha:getEngineCard(rid):objectName()
					table.removeOne(tyjiufa, name)
					room:setPlayerProperty(player, "tyjiufaRecord", sgs.QVariant(table.concat(tyjiufa, "+")))
				end
				local n = player:getMark("&tyjiufaRecord")
				room:removePlayerMark(player, "&tyjiufaRecord", n)
			end
		end
	end,
}
ty_shenjiangwei:addSkill(tyjiufa)

tytianren = sgs.CreateTriggerSkill{
    name = "tytianren",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreCardUsed, sgs.CardResponded, sgs.BeforeCardsMove, sgs.CardsMoveOneTime, sgs.MarkChanged},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.PreCardUsed or event == sgs.CardResponded then
			local card = nil
			if event == sgs.PreCardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and card:getHandlingMethod() == sgs.Card_MethodUse then
				room:setCardFlag(card, "tytianrenUse")
			end
		elseif event == sgs.BeforeCardsMove then --防止重复触发
			local move = data:toMoveOneTime()
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("tytianrenTriggered") then
					room:setPlayerFlag(p, "-tytianrenTriggered")
				end
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.to_place == sgs.Player_DiscardPile then
				local can_invoke = false
				local n = 0
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if (card:isKindOf("BasicCard") or card:isNDTrick()) and not card:hasFlag("tytianrenUse") then
						can_invoke = true
						n = n + 1
					end
				end
				if can_invoke then
					for _, tysjw in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
						if tysjw:hasFlag("tytianrenTriggered") then return false end
						room:sendCompulsoryTriggerLog(tysjw, self:objectName())
						if tysjw:getGeneralName() == "ty_shenjiangwei_1" or tysjw:getGeneral2Name() == "ty_shenjiangwei_1" then
							room:broadcastSkillInvoke(self:objectName(), math.random(3,4))
						else
							room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
						end
						tysjw:gainMark("&tytianren", n)
						room:setPlayerFlag(tysjw, "tytianrenTriggered")
					end
				end
			end
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			if mark.name == "&tytianren" and mark.who:getMark("&tytianren") >= mark.who:getMaxHp() and mark.who:objectName() == player:objectName() and player:hasSkill(self:objectName()) then
				local mhp = player:getMaxHp()
				room:sendCompulsoryTriggerLog(player, self:objectName())
				if player:getGeneralName() == "ty_shenjiangwei_1" or player:getGeneral2Name() == "ty_shenjiangwei_1" then
					room:broadcastSkillInvoke(self:objectName(), math.random(3,4))
				else
					room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
				end
				room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp+1))
				player:loseMark("&tytianren", mhp)
				room:drawCards(player, 2, self:objectName())
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
ty_shenjiangwei:addSkill(tytianren)

--虚拟火【杀】
typingxiangFireSlashCard = sgs.CreateSkillCard{
	name = "typingxiangFireSlashCard",
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return sgs.Self:canSlash(to_select, nil)
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local fs = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_NoSuit, 0)
		fs:setSkillName("typingxiangFireSlash")
		local use = sgs.CardUseStruct()
		use.card = fs
		use.from = source
		for _, p in pairs(targets) do
			use.to:append(p)
		end
		room:useCard(use)
	end,
}
typingxiangFireSlash = sgs.CreateZeroCardViewAsSkill{
	name = "typingxiangFireSlash",
	view_as = function()
		return typingxiangFireSlashCard:clone()
	end,
	enabled_at_play = function()
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@typingxiangFireSlash"
	end,
}
typingxiangCard = sgs.CreateSkillCard{ --全扩最燃大招
	name = "typingxiangCard",
	target_fixed = true,
	mute = true,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@typingxiang")
		if source:getGeneralName() == "ty_shenjiangwei_1" or source:getGeneral2Name() == "ty_shenjiangwei_1" then
			room:doSuperLightbox("ty_shenjiangwei_1", "typingxiang")
		else
			room:doSuperLightbox("ty_shenjiangwei", "typingxiang")
		end
		local mhp = source:getMaxHp() - 1
		if mhp > 9 then mhp = 9 end
		local choices = {}
		for i = 1, mhp do
			table.insert(choices, i)
		end
		local choice = room:askForChoice(source, "typingxiang", table.concat(choices, "+"))
		local n = tonumber(choice)
		room:loseMaxHp(source, n)
		while n > 0 and not source:hasFlag("typingxiangFSstop") and source:isAlive() do
			if room:askForUseCard(source, "@@typingxiangFireSlash", "@typingxiangFireSlash") then
				n = n - 1
			else
				room:setPlayerFlag(source, "typingxiangFSstop")
			end
		end
		if source:hasFlag("typingxiangFSstop") then room:setPlayerFlag(source, "-typingxiangFSstop") end
		if source:hasSkill("tyjiufa") then
			room:detachSkillFromPlayer(source, "tyjiufa")
		end
		room:addPlayerMark(source, "typingxiangMaxCards")
	end,
}
typingxiangVS = sgs.CreateZeroCardViewAsSkill{
	name = "typingxiang",
	view_as = function()
		return typingxiangCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@typingxiang") > 0 and player:getMaxHp() > 1
	end,
}
typingxiang = sgs.CreateTriggerSkill{
	name = "typingxiang",
	frequency = sgs.Skill_Limited,
	limit_mark = "@typingxiang",
	view_as_skill = typingxiangVS,
	events = {sgs.CardUsed}, --专门播报语音
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if (use.card:getSkillName() == "typingxiang" or use.card:getSkillName() == "typingxiangfireslash")
		and use.from:objectName() == player:objectName() then
			if player:getGeneralName() == "ty_shenjiangwei_1" or player:getGeneral2Name() == "ty_shenjiangwei_1" then
				room:broadcastSkillInvoke(self:objectName(), math.random(3,4))
			else
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
			end
		end
	end,
}
typingxiangMaxCards = sgs.CreateMaxCardsSkill{
    name = "typingxiangMaxCards",
	fixed_func = function(self, player)
		if player:getMark("typingxiangMaxCards") > 0 then
			return player:getMaxHp()
		end
		return -1
	end,
}
ty_shenjiangwei:addSkill(typingxiang)
if not sgs.Sanguosha:getSkill("typingxiangFireSlash") then skills:append(typingxiangFireSlash) end
if not sgs.Sanguosha:getSkill("typingxiangMaxCards") then skills:append(typingxiangMaxCards) end


--

--神马超(神·武)
ty_shenmachao = sgs.General(extension_t, "ty_shenmachao", "god", 4, true)

function useHorse(room, player) --全自动送马
	local horses = {}
	for _, id in sgs.qlist(room:getDrawPile()) do
		if sgs.Sanguosha:getCard(id):isKindOf("Horse") then
			table.insert(horses, sgs.Sanguosha:getCard(id))
		end
	end
	if #horses > 0 then
		local card = horses[math.random(1, #horses)]
		local equip_index = card:getRealCard():toEquipCard():location()
		if player:hasEquipArea(equip_index) then
			room:useCard(sgs.CardUseStruct(card, player, player))
			return card
		end
	end
	return nil
end
tyshouliGMS = sgs.CreateTriggerSkill{
    name = "tyshouliGMS",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:sendCompulsoryTriggerLog(player, "tyshouli")
		room:broadcastSkillInvoke("tyshouli", math.random(1,2))
		local p1 = player:getNextAlive()
		useHorse(room, p1)
		local p2 = p1:getNextAlive()
		useHorse(room, p2)
		if p2:objectName() == player:objectName() then return false end --双人局
		local p3 = p2:getNextAlive()
		useHorse(room, p3)
		if p3:objectName() == player:objectName() then return false end --三人局
		local p4 = p3:getNextAlive()
		useHorse(room, p4)
		if p4:objectName() == player:objectName() then return false end --四人局
		local p5 = p4:getNextAlive()
		useHorse(room, p5)
		if p5:objectName() == player:objectName() then return false end --五人局
		local p6 = p5:getNextAlive()
		useHorse(room, p6)
		if p6:objectName() == player:objectName() then return false end --六人局
		local p7 = p6:getNextAlive()
		useHorse(room, p7)
		if p7:objectName() == player:objectName() then return false end --七人局
		local p8 = p7:getNextAlive()
		useHorse(room, p8)
		if p8:objectName() == player:objectName() then return false end --八人局
		local p9 = p8:getNextAlive()
		useHorse(room, p9)
		if p9:objectName() == player:objectName() then return false end --九人局
		local p10 = p9:getNextAlive()
		useHorse(room, p10)
		if p10:objectName() == player:objectName() then return false end --十人局
	end,
	can_trigger = function(self, player)
		return player:hasSkill("tyshouli")
	end,
}
if not sgs.Sanguosha:getSkill("tyshouliGMS") then skills:append(tyshouliGMS) end
--主动使用【杀】
tyshouliCard = sgs.CreateSkillCard{
	name = "tyshouliCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
	    return to_select:getOffensiveHorse() ~= nil
	end,
	on_use = function(self, room, source, targets)
        local nmml = targets[1]
		room:setPlayerFlag(source, "tyshouliSource")
		if nmml:objectName() ~= source:objectName() then
			room:addPlayerMark(source, "&tyshouli")
			room:addPlayerMark(nmml, "&tyshouli")
			room:addPlayerMark(nmml, "@skill_invalidity")
			room:setPlayerFlag(nmml, "tyshouliTarget")
		else
			room:addPlayerMark(source, "&tyshouli")
			room:addPlayerMark(source, "@skill_invalidity") --我封我自己
			room:setPlayerFlag(source, "tyshouliTarget")
		end
		local card_slash = nmml:getOffensiveHorse()
		room:obtainCard(source, card_slash)
		room:setCardFlag(card_slash, "tyshouli")
		room:askForUseCard(source, "@@tyshouliSlash!", "@tyshouli_useSlash")
	end,
}
tyshouli = sgs.CreateZeroCardViewAsSkill{
	name = "tyshouli",
	view_as = function()
		return tyshouliCard:clone()
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "slash"
	end,
}
--使用/打出【杀/闪】以响应需求
tyshouliTrigger = sgs.CreateTriggerSkill{
	name = "tyshouliTrigger",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardAsked},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local pattern = data:toStringList()[1]
		if (pattern == "slash" or pattern == "jink") then
			if pattern == "slash" then
				local MA = sgs.SPlayerList()
				for _, m in sgs.qlist(room:getAllPlayers()) do
					if m:getOffensiveHorse() ~= nil then
						MA:append(m)
					end
				end
				if MA:isEmpty() then return false end
				if room:askForSkillInvoke(player, "tyshouli", data) then
					local nmml = room:askForPlayerChosen(player, MA, "tyshouli", "tyshouli_OT")
					room:setPlayerFlag(player, "tyshouliSource")
					if nmml:objectName() ~= player:objectName() then
						room:addPlayerMark(player, "&tyshouli")
						room:addPlayerMark(nmml, "&tyshouli")
						room:addPlayerMark(nmml, "@skill_invalidity")
						room:setPlayerFlag(nmml, "tyshouliTarget")
					else
						room:addPlayerMark(player, "&tyshouli")
						room:addPlayerMark(player, "@skill_invalidity")
						room:setPlayerFlag(player, "tyshouliTarget")
					end
					local card_slash = nmml:getOffensiveHorse()
					room:obtainCard(player, card_slash)
					room:broadcastSkillInvoke("tyshouli", 1)
					room:setCardFlag(card_slash, "tyshouli")
					if room:askForUseCard(player, "@@tyshouliSlashed!", "@tyshouli_respSlash") then
						local slash = sgs.Sanguosha:cloneCard("slash", card_slash:getSuit(), card_slash:getNumber())
						slash:addSubcard(card_slash:getId())
						slash:setSkillName("tyshoulii")
						room:provide(slash)
						room:broadcastSkillInvoke("tyshouli", 3)
					end
				end
			elseif pattern == "jink" then
				local MA = sgs.SPlayerList()
				for _, m in sgs.qlist(room:getAllPlayers()) do
					if m:getDefensiveHorse() ~= nil then
						MA:append(m)
					end
				end
				if MA:isEmpty() then return false end
				if room:askForSkillInvoke(player, "tyshouli", data) then
					local nmml = room:askForPlayerChosen(player, MA, "tyshouli", "tyshouli_DT")
					room:setPlayerFlag(player, "tyshouliSource")
					if nmml:objectName() ~= player:objectName() then
						room:addPlayerMark(player, "&tyshouli")
						room:addPlayerMark(nmml, "&tyshouli")
						room:addPlayerMark(nmml, "@skill_invalidity")
						room:setPlayerFlag(nmml, "tyshouliTarget")
					else
						room:addPlayerMark(player, "&tyshouli")
						room:addPlayerMark(player, "@skill_invalidity")
						room:setPlayerFlag(player, "tyshouliTarget")
					end
					local card_jink = nmml:getDefensiveHorse()
					room:obtainCard(player, card_jink)
					room:broadcastSkillInvoke("tyshouli", 2)
					room:setCardFlag(card_jink, "tyshouli")
					if room:askForUseCard(player, "@@tyshouliJink!", "@tyshouli_useJink") then
						local jink = sgs.Sanguosha:cloneCard("jink", card_jink:getSuit(), card_jink:getNumber())
						jink:addSubcard(card_jink:getId())
						jink:setSkillName("tyshoulii")
						room:provide(jink)
						room:broadcastSkillInvoke("tyshouli", 4)
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("tyshouli")
	end,
}
ty_shenmachao:addSkill(tyshouli)
if not sgs.Sanguosha:getSkill("tyshouliTrigger") then skills:append(tyshouliTrigger) end
--【杀】技能卡（使用）
tyshouliSlash = sgs.CreateOneCardViewAsSkill{
	name = "tyshouliSlash",
	response_or_use = true,
	view_filter = function(self, card)
		if not card:hasFlag("tyshouli") then return false end
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
		slash:setSkillName("tyshoulii") --特意设置成此名与技能卡"tyshouli"区分开，用于横骛
		return slash
	end,
	--[[enabled_at_play = function(self, player)
		return sgs.Slash_IsAvailable(player)
	end,]]
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@tyshouliSlash")
	end,
}
--【杀】技能卡（打出）
tyshouliSlashedCard = sgs.CreateSkillCard{
	name = "tyshouliSlashedCard",
	target_fixed = true,
	will_throw = false,
	on_use = function()
	end,
}
tyshouliSlashed = sgs.CreateOneCardViewAsSkill{
	name = "tyshouliSlashed",
	view_filter = function(self, to_select)
		return to_select:hasFlag("tyshouli")
	end,
	view_as = function(self, card)
		local sha_card = tyshouliSlashedCard:clone()
		sha_card:addSubcard(card:getId())
		return sha_card
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@tyshouliSlashed")
	end,
}
--【闪】技能卡
tyshouliJinkCard = sgs.CreateSkillCard{
	name = "tyshouliJinkCard",
	target_fixed = true,
	will_throw = false,
	on_use = function()
	end,
}
tyshouliJink = sgs.CreateOneCardViewAsSkill{
	name = "tyshouliJink",
	view_filter = function(self, to_select)
		return to_select:hasFlag("tyshouli")
	end,
	view_as = function(self, card)
		local jk_card = tyshouliJinkCard:clone()
		jk_card:addSubcard(card:getId())
		return jk_card
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@tyshouliJink")
	end,
}
----
if not sgs.Sanguosha:getSkill("tyshouliSlash") then skills:append(tyshouliSlash) end
if not sgs.Sanguosha:getSkill("tyshouliSlashed") then skills:append(tyshouliSlashed) end
if not sgs.Sanguosha:getSkill("tyshouliJink") then skills:append(tyshouliJink) end

tyshouliBuffANDClear = sgs.CreateTriggerSkill{
	name = "tyshouliBuffANDClear",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.CardResponded, sgs.DamageInflicted, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed or event == sgs.CardResponded then
			local card
			if event == sgs.CardUsed then
				card = data:toCardUse().card
				if data:toCardUse().m_addHistory and card:getSkillName() == "tyshoulii" then room:addPlayerHistory(player, card:getClassName(), -1) end
			else
				card = data:toCardResponse().m_card
			end
			if card and card:hasFlag("tyshouli") then
				room:setCardFlag(card, "-tyshouli")
			end
		elseif event == sgs.DamageInflicted then
			local damage = data:toDamage()
			if damage.to:objectName() == player:objectName() and player:getMark("&tyshouli") > 0 then
				local n = player:getMark("&tyshouli")
				local log = sgs.LogMessage()
				log.type = "$tyshouliMoreDamage"
				log.to:append(player)
				log.arg2 = n
				room:sendLog(log)
				room:broadcastSkillInvoke("tyshouli", math.random(3,4))
				if damage.nature ~= sgs.DamageStruct_Thunder then damage.nature = sgs.DamageStruct_Thunder end
				damage.damage = damage.damage + n
				data:setValue(damage)
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("&tyshouli") > 0 then
					room:setPlayerMark(p, "&tyshouli", 0)
				end
				if p:hasFlag("tyshouliTarget") then
					p:setFlags("-tyshouliTarget")
					if p:getMark("@skill_invalidity") > 0 then
						room:setPlayerMark(p, "@skill_invalidity", 0)
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("tyshouliBuffANDClear") then skills:append(tyshouliBuffANDClear) end

tyhengwu = sgs.CreateTriggerSkill{
	name = "tyhengwu",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.CardResponded},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local card
		if event == sgs.CardUsed then
			card = data:toCardUse().card
		else
			card = data:toCardResponse().m_card
		end
		if card and not (card:isKindOf("SkillCard") and card:getSkillName() ~= "tyshoulii") then
			local suit = card:getSuit()
			for _, p in sgs.qlist(player:getCards("h")) do
				if p:getSuit() == suit then
					return false
				end
			end
			local n = 0
			for _, p in sgs.qlist(room:getAllPlayers()) do
				for _, e in sgs.qlist(p:getCards("e")) do
					if e:getSuit() == suit then
						n = n + 1
					end
				end
			end
			if n == 0 then return false end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			room:drawCards(player, n, self:objectName())
		end
	end,
}
ty_shenmachao:addSkill(tyhengwu)

--神张飞(神·武)
ty_shenzhangfei = sgs.General(extension_t, "ty_shenzhangfei", "god", 4, true)

tyshencaiCard = sgs.CreateSkillCard{
	name = "tyshencaiCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
	    return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
        local prisoner = targets[1]
		local judge = sgs.JudgeStruct()
		judge.pattern = "."
		judge.good = true
		judge.play_animation = false
		judge.who = prisoner
		judge.reason = "tyshencai"
		room:judge(judge)
		room:obtainCard(source, judge.card)
		if judge.card:isKindOf("Peach") or judge.card:isKindOf("Analeptic") or judge.card:isKindOf("GodSalvation")
		or judge.card:isKindOf("SilverLion") or judge.card:isKindOf("Huxinjing") then --笞
			room:setPlayerMark(prisoner, "&tyscCHI", 0)
			room:setPlayerMark(prisoner, "&tyscZHANG", 0)
			room:setPlayerMark(prisoner, "&tyscTU", 0)
			room:setPlayerMark(prisoner, "&tyscLIU", 0)
			prisoner:gainMark("&tyscCHI")
			if not source:hasFlag("tyshencaiJudge") then room:setPlayerFlag(source, "tyshencaiJudge") end
		end
		if judge.card:isKindOf("Weapon") or judge.card:isKindOf("Collateral") then --杖
			room:setPlayerMark(prisoner, "&tyscCHI", 0)
			room:setPlayerMark(prisoner, "&tyscZHANG", 0)
			room:setPlayerMark(prisoner, "&tyscTU", 0)
			room:setPlayerMark(prisoner, "&tyscLIU", 0)
			prisoner:gainMark("&tyscZHANG")
			if not source:hasFlag("tyshencaiJudge") then room:setPlayerFlag(source, "tyshencaiJudge") end
		end
		if judge.card:isKindOf("SavageAssault") or judge.card:isKindOf("ArcheryAttack") or judge.card:isKindOf("Duel") or judge.card:isKindOf("Spear")
		or judge.card:isKindOf("MoonSpear") or judge.card:objectName() == "sp_moonspear" or judge.card:isKindOf("EightDiagram") or judge.card:isKindOf("Suijiyingbian") then --徒
			room:setPlayerMark(prisoner, "&tyscCHI", 0)
			if not judge.card:isKindOf("Spear") and not judge.card:isKindOf("MoonSpear") and not judge.card:objectName() == "sp_moonspear" then room:setPlayerMark(prisoner, "&tyscZHANG", 0) end --判定出【丈八蛇矛】或【银月枪】可以同时获得“杖”和“徒”标记，这里是防止把刚刚获得的“杖”标记给清了
			room:setPlayerMark(prisoner, "&tyscTU", 0)
			room:setPlayerMark(prisoner, "&tyscLIU", 0)
			prisoner:gainMark("&tyscTU")
			if not source:hasFlag("tyshencaiJudge") then room:setPlayerFlag(source, "tyshencaiJudge") end
		end
		if judge.card:isKindOf("Snatch") or judge.card:isKindOf("SupplyShortage") or judge.card:isKindOf("Horse") or judge.card:isKindOf("Zhujinqiyuan") then --流
			room:setPlayerMark(prisoner, "&tyscCHI", 0)
			room:setPlayerMark(prisoner, "&tyscZHANG", 0)
			room:setPlayerMark(prisoner, "&tyscTU", 0)
			room:setPlayerMark(prisoner, "&tyscLIU", 0)
			prisoner:gainMark("&tyscLIU")
			if not source:hasFlag("tyshencaiJudge") then room:setPlayerFlag(source, "tyshencaiJudge") end
		end
		if not source:hasFlag("tyshencaiJudge") then --不包含上述内容，获得“死”标记
			prisoner:gainMark("&tyscDIE")
			if prisoner:isAlive() and not prisoner:isAllNude() then
				local yichan = room:askForCardChosen(source, prisoner, "hej", "tyshencai")
				room:obtainCard(source, yichan, false)
			end
		else
			room:setPlayerFlag(source, "-tyshencaiJudge")
		end
		room:addPlayerMark(source, "tyshencai")
	end,
}
tyshencai = sgs.CreateZeroCardViewAsSkill{
	name = "tyshencai",
	view_as = function()
		return tyshencaiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark(self:objectName()) <= player:getMark("&tyshencaiAdd")
	end,
}
tyshencaiClear = sgs.CreateTriggerSkill{
	name = "tyshencaiClear",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play then room:setPlayerMark(player, "tyshencai", 0) end
	end,
	can_trigger = function(self, player)
		return player:getMark("tyshencai") > 0
	end,
}
ty_shenzhangfei:addSkill(tyshencai)
if not sgs.Sanguosha:getSkill("tyshencaiClear") then skills:append(tyshencaiClear) end
-----==“神裁”相关标记效果==-----
--1.“笞”标记：每次受到伤害后失去等量体力。
tyshencai_CHI = sgs.CreateTriggerSkill{
	name = "tyshencai_CHI",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local n = damage.damage
		local log = sgs.LogMessage()
		log.type = "$tyshencai_CHI"
		log.to:append(player)
		log.arg2 = n
		room:sendLog(log)
		room:broadcastSkillInvoke("tyshencai")
		room:loseHp(player, n)
	end,
	can_trigger = function(self, player)
		return player:getMark("&tyscCHI") > 0
	end,
}
if not sgs.Sanguosha:getSkill("tyshencai_CHI") then skills:append(tyshencai_CHI) end
--2.“杖”标记：无法响应【杀】。
tyshencai_ZHANG = sgs.CreateTriggerSkill{
    name = "tyshencai_ZHANG",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.TargetSpecified},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") and use.from:objectName() == player:objectName() then
			local no_respond_list = use.no_respond_list
			for _, fjzd in sgs.qlist(use.to) do
				if fjzd:getMark("&tyscZHANG") > 0 then
					local log = sgs.LogMessage()
					log.type = "$tyshencai_ZHANG"
					log.from = player
					log.to:append(fjzd)
					log.card_str = use.card:toString()
					room:sendLog(log)
					room:broadcastSkillInvoke("tyshencai")
					table.insert(no_respond_list, fjzd:objectName())
				end
			end
			use.no_respond_list = no_respond_list
			data:setValue(use)
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("tyshencai_ZHANG") then skills:append(tyshencai_ZHANG) end
--3.“徒”标记：以此法外失去手牌后随机弃置一张手牌。
tyshencai_TU = sgs.CreateTriggerSkill{
	name = "tyshencai_TU",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local move = data:toMoveOneTime()
		if (move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceHand))
		and not (move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceHand) then
			if move.reason.m_skillName ~= self:objectName() and not player:isKongcheng() then
				local log = sgs.LogMessage()
				log.type = "$tyshencai_TU"
				log.to:append(player)
				room:sendLog(log)
				room:broadcastSkillInvoke("tyshencai")
				local suijithrow = {}
				for _, c in sgs.qlist(player:getHandcards()) do
					table.insert(suijithrow, c)
				end
				local random_card = suijithrow[math.random(1, #suijithrow)]
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), "")
				room:throwCard(random_card, reason, nil)
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&tyscTU") > 0
	end,
}
if not sgs.Sanguosha:getSkill("tyshencai_TU") then skills:append(tyshencai_TU) end
--4.“流”标记：结束阶段将武将牌翻面。
tyshencai_LIU = sgs.CreateTriggerSkill{
	name = "tyshencai_LIU",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to == sgs.Player_Finish then
			local log = sgs.LogMessage()
			log.type = "$tyshencai_LIU"
			log.to:append(player)
			room:sendLog(log)
			room:broadcastSkillInvoke("tyshencai")
			player:turnOver()
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&tyscLIU") > 0
	end,
}
if not sgs.Sanguosha:getSkill("tyshencai_LIU") then skills:append(tyshencai_LIU) end
--5.“死”标记：手牌上限减少，且进入死亡倒计时。
tyshencai_DIE = sgs.CreateMaxCardsSkill{
	name = "tyshencai_DIE",
	extra_func = function(self, player)
		if player:getMark("&tyscDIE") > 0 then
            local n = player:getMark("&tyscDIE")
			return -n
        else
            return 0
		end
	end,
}
tyshencai_DYING = sgs.CreateTriggerSkill{ --大哥自己死，二哥带别人死，我等你死
	name = "tyshencai_DYING",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local change = data:toPhaseChange()
		local n = player:getMark("&tyscDIE")
		local m = room:alivePlayerCount()
		if change.to == sgs.Player_NotActive and n > m then
			local log = sgs.LogMessage()
			log.type = "$tyshencai_DIE"
			log.to:append(player)
			log.arg2 = n
			log.arg3 = m
			room:sendLog(log)
			room:broadcastSkillInvoke("tyshencai")
			room:killPlayer(player)
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&tyscDIE") > 0
	end,
}
if not sgs.Sanguosha:getSkill("tyshencai_DIE") then skills:append(tyshencai_DIE) end
if not sgs.Sanguosha:getSkill("tyshencai_DYING") then skills:append(tyshencai_DYING) end
--------------------------------

tyxunshi = sgs.CreateFilterSkill{
	name = "tyxunshi",
	view_filter = function(self, to_select)
		local room = sgs.Sanguosha:currentRoom()
		local place = room:getCardPlace(to_select:getEffectiveId())
		return to_select:isKindOf("AOE") or to_select:isKindOf("GlobalEffect") or to_select:isKindOf("IronChain")
		--return to_select:isKindOf("TrickCard") and not to_select:isKindOf("SingleTargetTrick")
	end,
	view_as = function(self, originalCard)
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, originalCard:getNumber())
		slash:setSkillName(self:objectName())
		local card = sgs.Sanguosha:getWrappedCard(originalCard:getId())
		card:takeOver(slash)
		return card
	end,
}
tyxunshiExtreme = sgs.CreateTargetModSkill{
	name = "tyxunshiExtreme",
	pattern = "Card",
	distance_limit_func = function(self, player, card)
		if player:hasSkill("tyxunshi") and card:getSuit() == sgs.Card_NoSuit and not card:isKindOf("SkillCard") then
		    return 1000
		else
		    return 0
		end
	end,
	residue_func = function(self, player, card)
		if player:hasSkill("tyxunshi") and card:getSuit() == sgs.Card_NoSuit and not card:isKindOf("SkillCard") then
			return 1000
		else
			return 0
		end
	end,
	extra_target_func = function(self, player, card)
		if player:hasSkill("tyxunshi") and card:getSuit() == sgs.Card_NoSuit and not card:isKindOf("SkillCard") then
		    return 1000
		else
			return 0
		end
	end,
}
tyxunshiSCLevelUp = sgs.CreateTriggerSkill{
	name = "tyxunshiSCLevelUp",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:getSuit() == sgs.Card_NoSuit and not use.card:isKindOf("SkillCard")
		and use.from:objectName() == player:objectName() and player:getMark("&tyshencaiAdd") < 4 then
			room:sendCompulsoryTriggerLog(player, "tyxunshi")
			room:broadcastSkillInvoke("tyxunshi")
			room:addPlayerMark(player, "&tyshencaiAdd")
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("tyxunshi")
	end,
}
ty_shenzhangfei:addSkill(tyxunshi)
if not sgs.Sanguosha:getSkill("tyxunshiExtreme") then skills:append(tyxunshiExtreme) end
if not sgs.Sanguosha:getSkill("tyxunshiSCLevelUp") then skills:append(tyxunshiSCLevelUp) end

--语音隐藏彩蛋(神张飞专属)
local function isSpecialOne(player, name)
	local g_name = sgs.Sanguosha:translate(player:getGeneralName())
	if string.find(g_name, name) then return true end
	if player:getGeneral2() then
		g_name = sgs.Sanguosha:translate(player:getGeneral2Name())
		if string.find(g_name, name) then return true end
	end
	return false
end
tyszfAudioCD = sgs.CreateTriggerSkill{
	name = "tyszfAudioCD",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed, sgs.Pindian},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:isKindOf("AmazingGrace") and use.from:objectName() == player:objectName() then
				room:broadcastSkillInvoke(self:objectName(), 1) --俺颇有家资！
			end
		elseif event == sgs.Pindian then
			local pindian = data:toPindian()
			if pindian.from:objectName() ~= player:objectName() and pindian.to:objectName() ~= player:objectName() then return false end
			if pindian.from_number == pindian.to_number then
				room:broadcastSkillInvoke(self:objectName(), 2) --俺也一样！
			end
		end
	end,
	can_trigger = function(self, player)
		return isSpecialOne(player, "神张飞") and isSpecialOne(player, "十周年")
		--[[(player:getGeneralName() == "ty_shenzhangfei" or player:getGeneral2Name() == "ty_shenzhangfei")
		or (player:getGeneralName() == "ty_shenzhangfei_1" or player:getGeneral2Name() == "ty_shenzhangfei_1")]]
	end,
}
if not sgs.Sanguosha:getSkill("tyszfAudioCD") then skills:append(tyszfAudioCD) end






--

--神张角(神·武)
ty_shenzhangjiao = sgs.General(extension_t, "ty_shenzhangjiao", "god", 3, true)

tyyizhao = sgs.CreateTriggerSkill{
	name = "tyyizhao",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed, sgs.CardResponded, sgs.MarkChanged},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.CardUsed or event == sgs.CardResponded then
			local card = nil
			if event == sgs.CardUsed then
				local use = data:toCardUse()
				card = use.card
			else
				card = data:toCardResponse().m_card
			end
			if card and not card:isKindOf("SkillCard") and player:hasSkill(self:objectName()) then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local n = card:getNumber()
				local m = player:getMark("&tyHuang")
				room:setPlayerMark(player, "tyHuang", m) --此隐藏标记是用以记录标记变化之前玩家的标记数，用以判断标记十位数是否变化
				player:gainMark("&tyHuang", n)
			end
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			if mark.name == "&tyHuang" and mark.who:hasSkill(self:objectName()) and mark.who:objectName() == player:objectName() then
				local m = player:getMark("tyHuang")
				local n = player:getMark("&tyHuang")
				--==究极枚举·“黄”标记十位数计算库==--
				local x, y
				--处理标记上百的情况（上限:999）
				if m >= 100 and m < 200 then m = m - 100
				elseif m >= 200 and m < 300 then m = m - 200
				elseif m >= 300 and m < 400 then m = m - 300
				elseif m >= 400 and m < 500 then m = m - 400
				elseif m >= 500 and m < 600 then m = m - 500
				elseif m >= 600 and m < 700 then m = m - 600
				elseif m >= 700 and m < 800 then m = m - 700
				elseif m >= 800 and m < 900 then m = m - 800
				elseif m >= 900 and m < 1000 then m = m - 900
				--......
				end
				if n >= 100 and n < 200 then n = n - 100
				elseif n >= 200 and n < 300 then n = n - 200
				elseif n >= 300 and n < 400 then n = n - 300
				elseif n >= 400 and n < 500 then n = n - 400
				elseif n >= 500 and n < 600 then n = n - 500
				elseif n >= 600 and n < 700 then n = n - 600
				elseif n >= 700 and n < 800 then n = n - 700
				elseif n >= 800 and n < 900 then n = n - 800
				elseif n >= 900 and n < 1000 then n = n - 900
				--......
				end
				--(硬核)提取出十位数
				if m >= 0 and m < 10 then x = 0
				elseif m >= 10 and m < 20 then x = 1
				elseif m >= 20 and m < 30 then x = 2
				elseif m >= 30 and m < 40 then x = 3
				elseif m >= 40 and m < 50 then x = 4
				elseif m >= 50 and m < 60 then x = 5
				elseif m >= 60 and m < 70 then x = 6
				elseif m >= 70 and m < 80 then x = 7
				elseif m >= 80 and m < 90 then x = 8
				elseif m >= 90 and m < 100 then x = 9
				end
				if n >= 0 and n < 10 then y = 0
				elseif n >= 10 and n < 20 then y = 1
				elseif n >= 20 and n < 30 then y = 2
				elseif n >= 30 and n < 40 then y = 3
				elseif n >= 40 and n < 50 then y = 4
				elseif n >= 50 and n < 60 then y = 5
				elseif n >= 60 and n < 70 then y = 6
				elseif n >= 70 and n < 80 then y = 7
				elseif n >= 80 and n < 90 then y = 8
				elseif n >= 90 and n < 100 then y = 9
				end
				--=================================--
				if x ~= y then
				--[[if m/10 ~= n/10 then --向下取整，得出十位数
					local num = n/10]]
					--if num == 0 then return false end
					local tyyizhao_cards = {}
					local tyyizhao_one_count = 0
					for _, id in sgs.qlist(room:getDrawPile()) do
						if sgs.Sanguosha:getCard(id):getNumber() == y and not table.contains(tyyizhao_cards, id) and tyyizhao_one_count < 1 then
							tyyizhao_one_count = tyyizhao_one_count + 1
							table.insert(tyyizhao_cards, id)
						end
					end
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					for _, id in ipairs(tyyizhao_cards) do
						dummy:addSubcard(id)
					end
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:obtainCard(player, dummy, false)
				end
			end
		end
	end,
}
ty_shenzhangjiao:addSkill(tyyizhao)

tysanshou = sgs.CreateTriggerSkill{
	name = "tysanshou",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local damage = data:toDamage()
		if room:askForSkillInvoke(player, self:objectName(), data) then
			local card_ids = room:getNCards(3)
			room:fillAG(card_ids)
			room:getThread():delay()
			local can_invoke = false
			for _, c in sgs.qlist(card_ids) do
				local card = sgs.Sanguosha:getCard(c)
				if (card:isKindOf("BasicCard") and not player:hasFlag("tysanshou_basic")) or (card:isKindOf("TrickCard") and not player:hasFlag("tysanshou_trick"))
				or (card:isKindOf("EquipCard") and not player:hasFlag("tysanshou_equip")) then
					can_invoke = true
				end
			end
			room:clearAG()
			if can_invoke then
				local log = sgs.LogMessage()
				log.type = "$tysanshouPrevent"
				log.from = player
				room:sendLog(log)
				room:broadcastSkillInvoke(self:objectName())
				room:setEmotion(player, "skill_nullify")
				return true
			end
		end
	end,
}
tysanshouCardUsed = sgs.CreateTriggerSkill{
	name = "tysanshouCardUsed",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.CardResponded, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.CardUsed or event == sgs.CardResponded then
			local card = nil
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and card:getHandlingMethod() == sgs.Card_MethodUse then
				for _, p in sgs.qlist(room:findPlayersBySkillName("tysanshou")) do
					if card:isKindOf("BasicCard") and not p:hasFlag("tysanshou_basic") then
						room:setPlayerFlag(p, "tysanshou_basic")
					end
					if card:isKindOf("TrickCard") and not p:hasFlag("tysanshou_trick") then
						room:setPlayerFlag(p, "tysanshou_trick")
					end
					if card:isKindOf("EquipCard") and not p:hasFlag("tysanshou_equip") then
						room:setPlayerFlag(p, "tysanshou_equip")
					end
				end
			end
		else
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("tysanshou_basic") then room:setPlayerFlag(p, "-tysanshou_basic") end
				if p:hasFlag("tysanshou_trick") then room:setPlayerFlag(p, "-tysanshou_trick") end
				if p:hasFlag("tysanshou_equip") then room:setPlayerFlag(p, "-tysanshou_equip") end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
ty_shenzhangjiao:addSkill(tysanshou)
if not sgs.Sanguosha:getSkill("tysanshouCardUsed") then skills:append(tysanshouCardUsed) end

tysijun = sgs.CreateTriggerSkill{
	name = "tysijun",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local phase = player:getPhase()
		if phase ~= sgs.Player_Start then return false end
		local n = player:getMark("&tyHuang")
		local m = room:getDrawPile():length()
		if n <= m then return false end
		if room:askForSkillInvoke(player, self:objectName(), data) then
			room:setPlayerMark(player, "tyHuang", 0)
			player:loseAllMarks("&tyHuang")
			--性感法王，在线洗牌--
			local ids = sgs.IntList()
			for _, id in sgs.qlist(room:getDrawPile()) do
				ids:append(id)
			end
			for _, id in sgs.qlist(room:getDiscardPile()) do
				ids:append(id)
			end
			room:shuffleIntoDrawPile(player, ids, self:objectName(), false)
			if not player:hasFlag("tytianjieInvoked") then
				room:setPlayerFlag(player, "tytianjieInvoked") --因为这种属于伪洗牌，不属于洗牌时机，得手动加标志提醒“天劫”的发动才行
			end
			----
			local tysijun_cards = {}
			local tysijun_one_count = 36
			--以下代码默认一张牌的点数不超过13
			while tysijun_one_count > 13 do
				local tysijun_this_count = 0
				for _, id in sgs.qlist(room:getDrawPile()) do
					if not table.contains(tysijun_cards, id) and tysijun_this_count < 1 then
						local num = sgs.Sanguosha:getCard(id):getNumber()
						tysijun_one_count = tysijun_one_count - num
						tysijun_this_count = tysijun_this_count + 1
						table.insert(tysijun_cards, id)
					end
				end
			end
			--当“tysijun_one_count”计数已减至不超过13且不为0时，精准拿最后一张点数已定死的牌
			local tysijun_last_count = 0
			if tysijun_one_count > 0 then
				for _, id in sgs.qlist(room:getDrawPile()) do
					if sgs.Sanguosha:getCard(id):getNumber() == tysijun_one_count and not table.contains(tysijun_cards, id) and tysijun_last_count < 1 then
						tysijun_last_count = tysijun_last_count + 1
						table.insert(tysijun_cards, id)
					end
				end
			end
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, id in ipairs(tysijun_cards) do
				dummy:addSubcard(id)
			end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			room:obtainCard(player, dummy, false)
		end
	end,
}
ty_shenzhangjiao:addSkill(tysijun)

tytianjieCard = sgs.CreateSkillCard{
	name = "tytianjieCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets < 3 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		local x = math.random(1,2)
		for _, p in pairs(targets) do
			local n = 0
			for _, c in sgs.qlist(p:getHandcards()) do
				if c:isKindOf("Jink") then n = n + 1 end
			end
			if n < 1 then n = 1 end
			room:damage(sgs.DamageStruct("tytianjie", source, p, n, sgs.DamageStruct_Thunder))
			if x == 1 then room:broadcastSkillInvoke(self:objectName(), 1)
			else room:broadcastSkillInvoke(self:objectName(), 2) end --电音起来！
		end
	end,
}
tytianjieVS = sgs.CreateZeroCardViewAsSkill{
	name = "tytianjie",
	view_as = function()
		return tytianjieCard:clone()
	end,
	response_pattern = "@@tytianjie",
}
tytianjie = sgs.CreateTriggerSkill{
	name = "tytianjie",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseChanging, sgs.SwappedPile}, --“sgs.SwappedPile”为20221231版本新增时机，为“洗牌后”
	view_as_skill = tytianjieVS,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if not p:hasFlag("tytianjieInvoked") then continue end
				if not room:askForSkillInvoke(p, self:objectName(), data) then continue end
				room:askForUseCard(p, "@@tytianjie", "@tytianjie-card")
			end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("tytianjieInvoked") then
					room:setPlayerFlag(p, "-tytianjieInvoked")
				end
			end
		elseif event == sgs.SwappedPile then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if not p:hasFlag("tytianjieInvoked") then
					room:setPlayerFlag(p, "tytianjieInvoked")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
ty_shenzhangjiao:addSkill(tytianjie)

--隐藏彩蛋(神张角专属)
--[[shenzhangjiao_HTDL = sgs.CreateTriggerSkill{
	name = "shenzhangjiao_HTDL",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.MarkChanged},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local mark = data:toMark()
		if mark.name == "&tyHuang" and mark.gain > 0 and mark.who:objectName() == player:objectName() then
			--“黄”标记上限为184，对应黄巾起义的年份(184年)
			if player:getMark("&tyHuang") > 184 then
				room:setPlayerMark(player, "&tyHuang", 184)
			end
		end
	end,
	can_trigger = function(self, player)
		return isSpecialOne(player, "神张角[十周年]") or isSpecialOne(player, "神张角[OL]")
	end,
}
if not sgs.Sanguosha:getSkill("shenzhangjiao_HTDL") then skills:append(shenzhangjiao_HTDL) end]]





--

--神邓艾(神·武)
ty_shendengai = sgs.General(extension_t, "ty_shendengai", "god", 4, true)

tytuoyuCard = sgs.CreateSkillCard{ --查看各手牌副区域分配情况用
    name = "tytuoyuCard",
	target_fixed = true,
	mute = true,
	on_use = function(self, room, source, targets)
	    local choices = {}
		if source:getMark("@tyty_Fengtian") > 0 then
			table.insert(choices, "see_tyty_Fengtian")
		end
		if source:getMark("@tyty_Qingqu") > 0 then
			table.insert(choices, "see_tyty_Qingqu")
		end
		if source:getMark("@tyty_Junshan") > 0 then
			table.insert(choices, "see_tyty_Junshan")
		end
		table.insert(choices, "cancel")
		local choice = room:askForChoice(source, "tytuoyu", table.concat(choices, "+"))
		if choice == "see_tyty_Fengtian" then
			room:askForUseCard(source, "@@tytuoyu_seeft", "@tytuoyu_seeft")
		elseif choice == "see_tyty_Qingqu" then
			room:askForUseCard(source, "@@tytuoyu_seeqq", "@tytuoyu_seeqq")
		elseif choice == "see_tyty_Junshan" then
			room:askForUseCard(source, "@@tytuoyu_seejs", "@tytuoyu_seejs")
		end
	end,
}
tytuoyuVS = sgs.CreateZeroCardViewAsSkill{
    name = "tytuoyu",
	view_as = function()
	    return tytuoyuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng() and (player:getMark("@tyty_Fengtian") > 0 or player:getMark("@tyty_Qingqu") > 0 or player:getMark("@tyty_Junshan") > 0)
	end,
	enabled_at_response = function(self, player, pattern)
		if player:isKongcheng() or (player:getMark("@tyty_Fengtian") == 0 or player:getMark("@tyty_Qingqu") == 0 or player:getMark("@tyty_Junshan") == 0)
		then return false
		else return pattern == "slash" or pattern == "jink" or pattern == "peach" or pattern == "nullification"
		end
	end,
}
--查看【丰田】
tytuoyu_seeftCard = sgs.CreateSkillCard{
    name = "tytuoyu_seeftCard",
	target_fixed = true,
	will_throw = false,
	on_use = function()
	end,
}
tytuoyu_seeft = sgs.CreateViewAsSkill{
    name = "tytuoyu_seeft",
	n = 999,
	view_filter = function(self, selected, to_select)
	    return to_select:hasFlag("tyty_Fengtian")
	end,
	view_as = function(self, cards)
	    if #cards == 1000 then --届不到的确定
			local card = tytuoyu_seeftCard:clone()
			for _, c in ipairs(cards) do
				c:addSubcard(card)
			end
			return card
		end
		return nil
	end,
	response_pattern = "@@tytuoyu_seeft",
}
if not sgs.Sanguosha:getSkill("tytuoyu_seeft") then skills:append(tytuoyu_seeft) end
--查看【清渠】
tytuoyu_seeqqCard = sgs.CreateSkillCard{
    name = "tytuoyu_seeqqCard",
	target_fixed = true,
	will_throw = false,
	on_use = function()
	end,
}
tytuoyu_seeqq = sgs.CreateViewAsSkill{
    name = "tytuoyu_seeqq",
	n = 999,
	view_filter = function(self, selected, to_select)
	    return to_select:hasFlag("tyty_Qingqu")
	end,
	view_as = function(self, cards)
	    if #cards == 1000 then --届不到的确定
			local card = tytuoyu_seeqqCard:clone()
			for _, c in ipairs(cards) do
				c:addSubcard(card)
			end
			return card
		end
		return nil
	end,
	response_pattern = "@@tytuoyu_seeqq",
}
if not sgs.Sanguosha:getSkill("tytuoyu_seeqq") then skills:append(tytuoyu_seeqq) end
--查看【峻山】
tytuoyu_seejsCard = sgs.CreateSkillCard{
    name = "tytuoyu_seejsCard",
	target_fixed = true,
	will_throw = false,
	on_use = function()
	end,
}
tytuoyu_seejs = sgs.CreateViewAsSkill{
    name = "tytuoyu_seejs",
	n = 999,
	view_filter = function(self, selected, to_select)
	    return to_select:hasFlag("tyty_Junshan")
	end,
	view_as = function(self, cards)
	    if #cards == 1000 then --届不到的确定
			local card = tytuoyu_seejsCard:clone()
			for _, c in ipairs(cards) do
				c:addSubcard(card)
			end
			return card
		end
		return nil
	end,
	response_pattern = "@@tytuoyu_seejs",
}
if not sgs.Sanguosha:getSkill("tytuoyu_seejs") then skills:append(tytuoyu_seejs) end
---
tytuoyu = sgs.CreateTriggerSkill{
	name = "tytuoyu",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd, sgs.CardsMoveOneTime, sgs.PreCardUsed},
	view_as_skill = tytuoyuVS,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		if (event == sgs.EventPhaseStart or event == sgs.EventPhaseEnd) and player:hasSkill(self:objectName())
		and player:getPhase() == sgs.Player_Play and not player:isKongcheng() then
			for _, cd in sgs.qlist(player:getHandcards()) do --先将标志全部清理，以准备重新分配
				if cd:hasFlag("tyty_Fengtian") then room:setCardFlag(cd, "-tyty_Fengtian") end
				if cd:hasFlag("tyty_Qingqu") then room:setCardFlag(cd, "-tyty_Qingqu") end
				if cd:hasFlag("tyty_Junshan") then room:setCardFlag(cd, "-tyty_Junshan") end
			end
			--开始重新分配
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			local choices = {}
			if player:getMark("@tyty_Fengtian") > 0 and not player:hasFlag("tyty_Fengtiand") then
				table.insert(choices, "tyty_Fengtian")
			end
			if player:getMark("@tyty_Qingqu") > 0 and not player:hasFlag("tyty_Qingqud") then
				table.insert(choices, "tyty_Qingqu")
			end
			if player:getMark("@tyty_Junshan") > 0 and not player:hasFlag("tyty_Junshand") then
				table.insert(choices, "tyty_Junshan")
			end
			table.insert(choices, "endput")
			while #choices > 0 do
				local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
				if choice == "endput" then break end
				if choice == "tyty_Fengtian" then --分配至【丰田】
					room:setPlayerFlag(player, "tyty_Fengtiand")
					--room:askForUseCard(player, "@@tyty_ptft", "@tyty_ptft")
					local ids, dtbt = sgs.IntList(), 5
					for _, cd in sgs.qlist(player:getHandcards()) do
						if not cd:hasFlag("tyty_Fengtian") and not cd:hasFlag("tyty_Qingqu") and not cd:hasFlag("tyty_Junshan") then
							ids:append(cd:getEffectiveId())
						end
					end
					while not ids:isEmpty() and dtbt > 0 do
						room:fillAG(ids, player)
						local card_id = room:askForAG(player, ids, true, self:objectName())--"tyty_PutToFengtian")
						if card_id == -1 then room:clearAG(player) break end
						local card = sgs.Sanguosha:getCard(card_id)
						room:setCardFlag(card, "tyty_Fengtian")
						ids:removeOne(card_id)
						dtbt = dtbt - 1
						room:clearAG(player)
					end
					table.removeOne(choices, "tyty_Fengtian")
				elseif choice == "tyty_Qingqu" then --分配至【清渠】
					room:setPlayerFlag(player, "tyty_Qingqud")
					--room:askForUseCard(player, "@@tyty_ptqq", "@tyty_ptqq")
					local ids, dtbt = sgs.IntList(), 5
					for _, cd in sgs.qlist(player:getHandcards()) do
						if not cd:hasFlag("tyty_Fengtian") and not cd:hasFlag("tyty_Qingqu") and not cd:hasFlag("tyty_Junshan") then
							ids:append(cd:getEffectiveId())
						end
					end
					while not ids:isEmpty() and dtbt > 0 do
						room:fillAG(ids, player)
						local card_id = room:askForAG(player, ids, true, self:objectName())--"tyty_PutToQingqu")
						if card_id == -1 then room:clearAG(player) break end
						local card = sgs.Sanguosha:getCard(card_id)
						room:setCardFlag(card, "tyty_Qingqu")
						ids:removeOne(card_id)
						dtbt = dtbt - 1
						room:clearAG(player)
					end
					table.removeOne(choices, "tyty_Qingqu")
				elseif choice == "tyty_Junshan" then --分配至【峻山】
					room:setPlayerFlag(player, "tyty_Junshand")
					--room:askForUseCard(player, "@@tyty_ptjs", "@tyty_ptjs")
					local ids, dtbt = sgs.IntList(), 5
					for _, cd in sgs.qlist(player:getHandcards()) do
						if not cd:hasFlag("tyty_Fengtian") and not cd:hasFlag("tyty_Qingqu") and not cd:hasFlag("tyty_Junshan") then
							ids:append(cd:getEffectiveId())
						end
					end
					while not ids:isEmpty() and dtbt > 0 do
						room:fillAG(ids, player)
						local card_id = room:askForAG(player, ids, true, self:objectName())--"tyty_PutToJunshan")
						if card_id == -1 then room:clearAG(player) break end
						local card = sgs.Sanguosha:getCard(card_id)
						room:setCardFlag(card, "tyty_Junshan")
						ids:removeOne(card_id)
						dtbt = dtbt - 1
						room:clearAG(player)
					end
					table.removeOne(choices, "tyty_Junshan")
				end
				local ctn = 0
				for _, cd in sgs.qlist(player:getHandcards()) do
					if not cd:hasFlag("tyty_Fengtian") and not cd:hasFlag("tyty_Qingqu") and not cd:hasFlag("tyty_Junshan") then
						ctn = ctn + 1
					end
				end
				if ctn == 0 then break end --表明已没有可分配的手牌
			end
			if player:hasFlag("tyty_Fengtiand") then room:setPlayerFlag(player, "-tyty_Fengtiand") end
			if player:hasFlag("tyty_Qingqud") then room:setPlayerFlag(player, "-tyty_Qingqud") end
			if player:hasFlag("tyty_Junshand") then room:setPlayerFlag(player, "-tyty_Junshand") end
		elseif event == sgs.CardsMoveOneTime then --确保是在手牌区才能生效
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceHand)
			and (((not move.to or move.to:objectName() ~= player:objectName()) and move.to_place ~= sgs.Player_PlaceTable)
			or (move.to and (move.to:objectName() == player:objectName() and move.to_place ~= sgs.Player_PlaceHand))) then
				for _, id in sgs.qlist(move.card_ids) do
					local cd = sgs.Sanguosha:getCard(id)
					if cd:hasFlag("tyty_Fengtian") then room:setCardFlag(cd, "-tyty_Fengtian") end
					if cd:hasFlag("tyty_Qingqu") then room:setCardFlag(cd, "-tyty_Qingqu") end
					if cd:hasFlag("tyty_Junshan") then room:setCardFlag(cd, "-tyty_Junshan") end
				end
			end
		elseif event == sgs.PreCardUsed then --保险起见
			if use.card then
				if use.card:hasFlag("tyty_Fengtian") then
					room:setCardFlag(use.card, "-tyty_Fengtian")
					room:setCardFlag(use.card, "tyty_Fengtian_buff")
				end
				--[[if use.card:hasFlag("tyty_Qingqu") then
					room:setCardFlag(use.card, "-tyty_Qingqu")
					room:setCardFlag(use.card, "tyty_Qingqu_buff")
				end]]
				if use.card:hasFlag("tyty_Junshan") then
					room:setCardFlag(use.card, "-tyty_Junshan")
					room:setCardFlag(use.card, "tyty_Junshan_buff")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
ty_shendengai:addSkill(tytuoyu)
--手牌副区域【丰田】：伤害值与回复值+1
--[[tyty_ptftCard = sgs.CreateSkillCard{
    name = "tyty_ptftCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		for _, id in sgs.qlist(self:getSubcards()) do
			local ft_card = sgs.Sanguosha:getCard(id)
			room:setCardFlag(ft_card, "tyty_Fengtian")
		end
	end,
}
tyty_ptft = sgs.CreateViewAsSkill{
    name = "tyty_ptft",
	n = 5,
	view_filter = function(self, selected, to_select)
	    return not to_select:isEquipped() and not to_select:hasFlag("tyty_Fengtian")
		and not to_select:hasFlag("tyty_Qingqu") and not to_select:hasFlag("tyty_Junshan")
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local card = tyty_ptftCard:clone()
			for _, c in ipairs(cards) do
				c:addSubcard(card)
			end
			return card
		end
		return nil
	end,
	response_pattern = "@@tyty_ptft",
}]]
tytuoyuACAbuff_ft = sgs.CreateTriggerSkill{
	name = "tytuoyuACAbuff_ft",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage, sgs.PreHpRecover},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.card and damage.card:hasFlag("tyty_Fengtian_buff") then
				local log = sgs.LogMessage()
				log.type = "$tytuoyuACAbuff_ft_dmg"
				log.card_str = damage.card:toString()
				room:sendLog(log)
				room:broadcastSkillInvoke("tytuoyu")
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		elseif event == sgs.PreHpRecover then
			local rec = data:toRecover()
			if rec.card and rec.card:hasFlag("tyty_Fengtian_buff") then
				local log = sgs.LogMessage()
				log.type = "$tytuoyuACAbuff_ft_rec"
				log.card_str = rec.card:toString()
				room:sendLog(log)
				room:broadcastSkillInvoke("tytuoyu")
				rec.recover = rec.recover + 1
				data:setValue(rec)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
--if not sgs.Sanguosha:getSkill("tyty_ptft") then skills:append(tyty_ptft) end
if not sgs.Sanguosha:getSkill("tytuoyuACAbuff_ft") then skills:append(tytuoyuACAbuff_ft) end
--手牌副区域【清渠】：无距离与次数限制
--[[tyty_ptqqCard = sgs.CreateSkillCard{
    name = "tyty_ptqqCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		for _, id in sgs.qlist(self:getSubcards()) do
			local qq_card = sgs.Sanguosha:getCard(id)
			room:setCardFlag(qq_card, "tyty_Qingqu")
		end
	end,
}
tyty_ptqq = sgs.CreateViewAsSkill{
    name = "tyty_ptqq",
	n = 5,
	view_filter = function(self, selected, to_select)
	    return not to_select:isEquipped() and not to_select:hasFlag("tyty_Qingqu")
		and not to_select:hasFlag("tyty_Junshan") and not to_select:hasFlag("tyty_Fengtian")
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local card = tyty_ptqqCard:clone()
			for _, c in ipairs(cards) do
				c:addSubcard(card)
			end
			return card
		end
		return nil
	end,
	response_pattern = "@@tyty_ptqq",
}]]
tytuoyuACAbuff_qq = sgs.CreateTargetModSkill{
	name = "tytuoyuACAbuff_qq",
	pattern = "Card",
	distance_limit_func = function(self, from, card)
		if card and card:hasFlag("tyty_Qingqu") then
			return 1000
		else
			return 0
		end
	end,
	residue_func = function(self, from, card)
		if card and card:hasFlag("tyty_Qingqu") then
			return 1000
		else
			return 0
		end
	end,
}
--if not sgs.Sanguosha:getSkill("tyty_ptqq") then skills:append(tyty_ptqq) end
if not sgs.Sanguosha:getSkill("tytuoyuACAbuff_qq") then skills:append(tytuoyuACAbuff_qq) end
--手牌副区域【峻山】：不能被响应
--[[tyty_ptjsCard = sgs.CreateSkillCard{
    name = "tyty_ptjsCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		for _, id in sgs.qlist(self:getSubcards()) do
			local js_card = sgs.Sanguosha:getCard(id)
			room:setCardFlag(js_card, "tyty_Junshan")
		end
	end,
}
tyty_ptjs = sgs.CreateViewAsSkill{
    name = "tyty_ptjs",
	n = 5,
	view_filter = function(self, selected, to_select)
	    return not to_select:isEquipped() and not to_select:hasFlag("tyty_Junshan")
		and not to_select:hasFlag("tyty_Fengtian") and not to_select:hasFlag("tyty_Qingqu")
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local card = tyty_ptjsCard:clone()
			for _, c in ipairs(cards) do
				c:addSubcard(card)
			end
			return card
		end
		return nil
	end,
	response_pattern = "@@tyty_ptjs",
}]]
tytuoyuACAbuff_js = sgs.CreateTriggerSkill{
	name = "tytuoyuACAbuff_js",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecified},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		if use.card and use.card:hasFlag("tyty_Junshan_buff") then
			local log = sgs.LogMessage()
			log.type = "$tytuoyuACAbuff_js"
			log.card_str = use.card:toString()
			room:sendLog(log)
			room:broadcastSkillInvoke("tytuoyu")
			local no_respond_list = use.no_respond_list
			for _, sj in sgs.qlist(room:getAllPlayers()) do
				table.insert(no_respond_list, sj:objectName())
			end
			use.no_respond_list = no_respond_list
			data:setValue(use)
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
--if not sgs.Sanguosha:getSkill("tyty_ptjs") then skills:append(tyty_ptjs) end
if not sgs.Sanguosha:getSkill("tytuoyuACAbuff_js") then skills:append(tytuoyuACAbuff_js) end
---
tyxianjin = sgs.CreateTriggerSkill{
	name = "tyxianjin",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damage, sgs.Damaged},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local damage = data:toDamage()
		if event == sgs.Damage then
			room:addPlayerMark(player, "&tyxianjin_zs")
		elseif event == sgs.Damaged then
			room:addPlayerMark(player, "&tyxianjin_ss")
		end
		local n, m = player:getMark("&tyxianjin_zs"), player:getMark("&tyxianjin_ss")
		if n >= 2 or m >= 2 then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			local choices = {}
			if player:getMark("@tyty_Fengtian") == 0 then
				table.insert(choices, "kfFengtian")
			end
			if player:getMark("@tyty_Qingqu") == 0 then
				table.insert(choices, "kfQingqu")
			end
			if player:getMark("@tyty_Junshan") == 0 then
				table.insert(choices, "kfJunshan")
			end
			if #choices > 0 then
				room:broadcastSkillInvoke(self:objectName())
				local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
				if choice == "kfFengtian" then
					local log = sgs.LogMessage()
					log.type = "$tyxianjin_kfFengtian"
					log.from = player
					room:sendLog(log)
					player:gainMark("@tyty_Fengtian")
				elseif choice == "kfQingqu" then
					local log = sgs.LogMessage()
					log.type = "$tyxianjin_kfQingqu"
					log.from = player
					room:sendLog(log)
					player:gainMark("@tyty_Qingqu")
				elseif choice == "kfJunshan" then
					local log = sgs.LogMessage()
					log.type = "$tyxianjin_kfJunshan"
					log.from = player
					room:sendLog(log)
					player:gainMark("@tyty_Junshan")
				end
			end
			local draw, mxhc = 0, 0
			if player:getMark("@tyty_Fengtian") > 0 then draw = draw + 1 end
			if player:getMark("@tyty_Qingqu") > 0 then draw = draw + 1 end
			if player:getMark("@tyty_Junshan") > 0 then draw = draw + 1 end
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:getHandcardNum() >= player:getHandcardNum() then --找到不比神邓艾手牌数少的
					mxhc = mxhc + 1
				end
			end
			if mxhc == 0 then draw = 1 end --证明神邓艾手牌数为全场唯一最多
			room:broadcastSkillInvoke(self:objectName())
			room:drawCards(player, draw, self:objectName())
			if n >= 2 then
				room:setPlayerMark(player, "&tyxianjin_zs", 0)
			elseif m >= 2 then
				room:setPlayerMark(player, "&tyxianjin_ss", 0)
			end
		end
	end,
}
ty_shendengai:addSkill(tyxianjin)

tyqijing = sgs.CreateTriggerSkill{
	name = "tyqijing",
	global = true,
	frequency = sgs.Skill_Wake,
	events = {sgs.EventPhaseChanging},
	waked_skills = "qj_cuixin",
	--[[can_wake = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then return false end
		for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
			if p:getMark(self:objectName()) > 0 then continue end
			if p:canWake(self:objectName()) then room:addPlayerMark(p, self:objectName()) end
			if p:getMark("@tyty_Fengtian") == 0 or p:getMark("@tyty_Qingqu") == 0 or p:getMark("@tyty_Junshan") == 0 then continue end
		end
		return true
	end,]]
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
			if p:getMark(self:objectName()) > 0 then continue end
			if (p:getMark("@tyty_Fengtian") == 0 or p:getMark("@tyty_Qingqu") == 0 or p:getMark("@tyty_Junshan") == 0)
			and not p:canWake(self:objectName()) then continue end
			room:broadcastSkillInvoke(self:objectName())
			room:doSuperLightbox("ty_shendengai", self:objectName())
			room:loseMaxHp(p, 1)
			room:addPlayerMark(p, self:objectName())
			room:addPlayerMark(p, "@waked")
			if room:alivePlayerCount() > 3 then --2人根本就不满足条件；3人移动也无意义，因为自己本来就是在其他两名相邻角色之间
				local tyqijings = sgs.SPlayerList()
				for _, q in sgs.qlist(room:getOtherPlayers(p)) do
					if p:getNextAlive():objectName() ~= q:objectName() then --后续将会让玩家选择移动后自己的下家，故先行排除掉玩家自己的下家
						tyqijings:append(q)
					end
				end
				if not tyqijings:isEmpty() then
					local tyqijinger
					if tyqijings:length() == 1 then
						tyqijinger = tyqijings:first()
					else
						tyqijinger = room:askForPlayerChosen(p, tyqijings, self:objectName(), "@tyqijing-nextalivechoice")
					end
					if tyqijinger then
						room:setPlayerFlag(tyqijinger, "tyqijing_nextalive")
						--开始穿越！
						local tyqijingend = 0
						while tyqijingend <= 0 do
							local na1 = p:getNextAlive()
							room:swapSeat(p, na1)
							local na2 = p:getNextAlive()
							if na2:hasFlag("tyqijing_nextalive") then --找到路标，抵达终点
								room:setPlayerFlag(na2, "-tyqijing_nextalive")
								tyqijingend = tyqijingend + 1
							end
						end
					end
				end
			end
			if not p:hasSkill("qj_cuixin") then
				room:acquireSkill(p, "qj_cuixin")
			end
			p:gainAnExtraTurn()
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
ty_shendengai:addSkill(tyqijing)
ty_shendengai:addRelateSkill("qj_cuixin")
--“摧心”
qj_cuixin = sgs.CreateTriggerSkill{
	name = "qj_cuixin",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardFinished},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		if use.card and not use.card:isKindOf("SkillCard") and use.from and use.from:objectName() == player:objectName() then
			if not player:hasFlag(self:objectName()) then
				room:setPlayerFlag(player, self:objectName())
				local last, naxt
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:getNextAlive():objectName() == player:objectName() then --找到上家
						last = p
					end
				end
				naxt = player:getNextAlive()
				local cuixinTo = sgs.SPlayerList()
				for _, p in sgs.qlist(use.to) do
					if p:objectName() == last:objectName() then
						cuixinTo:append(naxt)
					elseif p:objectName() == naxt:objectName() then
						cuixinTo:append(last)
					end
				end
				if not cuixinTo:isEmpty() then
					if (player:getState() == "robot" and (room:alivePlayerCount() == 2 or player:hasSkill("bahu")))
					or room:askForSkillInvoke(player, self:objectName(), data) then
						for _, p in sgs.qlist(use.to) do
							use.to:removeOne(p)
						end
						for _, p in sgs.qlist(cuixinTo) do
							use.to:append(p)
						end
						local can_useagain = false
						for _, p in sgs.qlist(use.to) do
							if not player:isProhibited(p, use.card) then
							can_useagain = true end
						end
						if can_useagain then
							room:broadcastSkillInvoke(self:objectName())
							use.card:cardOnUse(room, use)
						end
					end
				end
			else
				room:setPlayerFlag(player, "-qj_cuixin")
			end
		end
	end,
}
if not sgs.Sanguosha:getSkill("qj_cuixin") then skills:append(qj_cuixin) end

--

--神典韦-自改版(神·武)
ty_shendianwei = sgs.General(extension_t, "ty_shendianwei", "god", 4, true)

tyjuanjiaGMS = sgs.CreateTriggerSkill{
	name = "tyjuanjiaGMS",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.MarkChanged, sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			if player:hasEquipArea(1) then
				player:throwEquipArea(1)
			end
			local log = sgs.LogMessage()
			log.type = "$tyjuanjia_getJJea"
			log.from = player
			room:sendLog(log)
			room:addPlayerMark(player, "@tyjuanjia_equiparea")
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			if mark.name == "@tyjuanjia_equiparea" and mark.who and mark.who:objectName() == player:objectName()
			and player:getMark("@tyjuanjia_equiparea") > 0 and not player:hasSkill("tyjuanjia_equiparea") then
				room:attachSkillToPlayer(player, "tyjuanjia_equiparea")
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == "tyjuanjia_equiparea" and player:getMark("@tyjuanjia_equiparea") > 0 then
				room:attachSkillToPlayer(player, "tyjuanjia_equiparea")
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("tyjuanjia")
	end,
}
tyjuanjia = sgs.CreateViewAsEquipSkill{
	name = "tyjuanjia",
	view_as_equip = function(self, player)
		return "" .. player:property("tyjuanjia_equiparea_record"):toString()
	end,
}
tyjuanjia_equipareaCard = sgs.CreateSkillCard{
	name = "tyjuanjia_equipareaCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("tyjuanjia")
		room:setPlayerProperty(source, "tyjuanjia_equiparea_record", sgs.QVariant()) --先清空记录
		local jjea_names = source:property("tyjuanjia_equiparea_record"):toString():split(",")
		local jjea_eq = {}
		local jjea_id = self:getSubcards():first()
		local jjea_card = sgs.Sanguosha:getCard(jjea_id)
		table.insert(jjea_eq, jjea_card:objectName())
		if source:getPile("tyjuanjia"):length() > 0 then
			local dummy = sgs.Sanguosha:cloneCard("slash")
			dummy:addSubcards(source:getPile("tyjuanjia"))
			room:throwCard(dummy, source, nil)
			dummy:deleteLater()
		end
		source:addToPile("tyjuanjia", self)
		for _, _name in ipairs(jjea_eq) do
			if not table.contains(jjea_names, _name) then
				table.insert(jjea_names, _name)
			end
		end
		room:setPlayerProperty(source, "tyjuanjia_equiparea_record", sgs.QVariant(table.concat(jjea_names, ",")))
	end,
}
tyjuanjia_equiparea = sgs.CreateViewAsSkill{
	name = "tyjuanjia_equiparea&",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped() and to_select:isKindOf("Weapon")
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local jj_ea = tyjuanjia_equipareaCard:clone()
		for _, wp in ipairs(cards) do
			jj_ea:addSubcard(wp)
		end
		return jj_ea
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng()
	end,
}
ty_shendianwei:addSkill(tyjuanjia)
if not sgs.Sanguosha:getSkill("tyjuanjiaGMS") then skills:append(tyjuanjiaGMS) end
if not sgs.Sanguosha:getSkill("tyjuanjia_equiparea") then skills:append(tyjuanjia_equiparea) end

tyqiexie = sgs.CreateTriggerSkill{
	name = "tyqiexie",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start then return false end
		if not player:hasEquipArea(0) and player:getMark("@tyjuanjia_equiparea") == 0 then return false end
		room:sendCompulsoryTriggerLog(player, self:objectName())
		room:broadcastSkillInvoke(self:objectName())
		local qiexies = {}
		local qiexie = {}
		for _, name in ipairs(sgs.Sanguosha:getLimitedGeneralNames()) do
			table.insert(qiexies, name)
		end
		for _, p in sgs.qlist(room:getAllPlayers(true)) do
			if table.contains(qiexies, p:getGeneralName()) then
				table.removeOne(qiexies, p:getGeneralName())
			end
		end
		for i = 1, 5 do
			local first = qiexies[math.random(1, #qiexies)]
			table.insert(qiexie, first)
			table.removeOne(qiexies, first)
		end
		local n = 2
		if not player:hasEquipArea(0) then n = n - 1 end
		if player:getMark("@tyjuanjia_equiparea") == 0 then n = n - 1 end
		--1.置入装备区
		if n > 0 and player:hasEquipArea(0) then
			local general = room:askForGeneral(player, table.concat(qiexie, "+"))
			table.removeOne(qiexie, general)
			local ggeneral = sgs.Sanguosha:getGeneral(general)
			room:setPlayerProperty(player, "tyqiexie_wparea_record", sgs.QVariant())
			local wqxs = player:property("tyqiexie_wparea_record"):toString():split(",")
			for _, _skill in sgs.qlist(ggeneral:getVisibleSkillList()) do
				if string.find(_skill:getDescription(), "【杀】") then --含有“【杀】”
					if not string.find(_skill:getDescription(), "技，") then --不带类型标签(粗略过滤)
						table.insert(wqxs, _skill:objectName())
					else
						if string.find(_skill:getDescription(), "锁定技，")
						and not string.find(_skill:getDescription(), "主公技，")
						and not string.find(_skill:getDescription(), "限定技，")
						and not string.find(_skill:getDescription(), "觉醒技，")
						and not string.find(_skill:getDescription(), "联动技，")
						and not string.find(_skill:getDescription(), "转换技，")
						and not string.find(_skill:getDescription(), "隐匿技，")
						and not string.find(_skill:getDescription(), "势力技，")
						and not string.find(_skill:getDescription(), "使命技，")
						and not string.find(_skill:getDescription(), "宗族技，")
						and not string.find(_skill:getDescription(), "说明技，")
						and not string.find(_skill:getDescription(), "激活技，")
						and not string.find(_skill:getDescription(), "学习技，")
						and not string.find(_skill:getDescription(), "解锁技，")
						and not string.find(_skill:getDescription(), "命运技，")
						and not string.find(_skill:getDescription(), "阶梯技，")
						and not string.find(_skill:getDescription(), "聚气技，")
						and not string.find(_skill:getDescription(), "昂扬技，")
						and not string.find(_skill:getDescription(), "皇后技，")
						then --带有，但仅锁定技(基本过滤)
							table.insert(wqxs, _skill:objectName())
						end
					end
				end
			end
			room:setPlayerProperty(player, "tyqiexie_wparea_record", sgs.QVariant(table.concat(wqxs, ",")))
			room:setPlayerFlag(player, "tyqiexie_wparea") --识别置入的是装备区还是“捐甲”区
			local mhp = ggeneral:getMaxHp()
			if mhp > 5 then mhp = 5 end
			local cds = sgs.IntList()
			for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
				local wqx = sgs.Sanguosha:getEngineCard(id)
				if mhp == 1 and wqx:isKindOf("WeaponQiexieOne") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXone_ID", sgs.QVariant(id))
				elseif mhp == 2 and wqx:isKindOf("WeaponQiexieTwo") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXtwo_ID", sgs.QVariant(id))
				elseif mhp == 3 and wqx:isKindOf("WeaponQiexieThree") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXthree_ID", sgs.QVariant(id))
				elseif mhp == 4 and wqx:isKindOf("WeaponQiexieFour") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXfour_ID", sgs.QVariant(id))
				elseif mhp == 5 and wqx:isKindOf("WeaponQiexieFive") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXfive_ID", sgs.QVariant(id))
				end
				if not cds:isEmpty() then break end
			end
			if not cds:isEmpty() then
				local cid = cds:first()
				local exchangeMove = sgs.CardsMoveList()
				exchangeMove:append(sgs.CardsMoveStruct(cid, player, sgs.Player_PlaceEquip,
				sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), self:objectName(), "")))
				local card = sgs.Sanguosha:getCard(cid)
				local realEquip = sgs.Sanguosha:getCard(cid):getRealCard():toEquipCard()
				local equip = player:getEquip(realEquip:location())
				if equip then
					exchangeMove:append(sgs.CardsMoveStruct(equip:getEffectiveId(), nil, sgs.Player_DiscardPile,
					sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_CHANGE_EQUIP, player:objectName())))
				end
				room:broadcastSkillInvoke(self:objectName())
				room:moveCardsAtomic(exchangeMove, true)
				--[[for _, m in sgs.list(player:getMarkNames()) do
		        	if string.find(m, "tyqiexie_first") then
	                	room:setPlayerMark(player, m, 0)
					end
				end
				room:setPlayerMark(player, "&tyqiexie_first:" .. sgs.Sanguosha:translate(general))]]
			end
			if player:hasFlag("tyqiexie_wparea") then room:setPlayerFlag(player, "-tyqiexie_wparea") end
			n = n - 1
		end
		--2.置入“捐甲”区
		if n > 0 and player:getMark("@tyjuanjia_equiparea") > 0 then
			local generall = room:askForGeneral(player, table.concat(qiexie, "+"))
			local ggenerall = sgs.Sanguosha:getGeneral(generall)
			room:setPlayerProperty(player, "tyqiexie_jjarea_record", sgs.QVariant())
			local jqxs = player:property("tyqiexie_jjarea_record"):toString():split(",")
			for _, _skill in sgs.qlist(ggenerall:getVisibleSkillList()) do
				if string.find(_skill:getDescription(), "【杀】") then --含有“【杀】”
					if not string.find(_skill:getDescription(), "技，") then --不带类型标签(粗略过滤)
						table.insert(jqxs, _skill:objectName())
					else
						if string.find(_skill:getDescription(), "锁定技，")
						and not string.find(_skill:getDescription(), "主公技，")
						and not string.find(_skill:getDescription(), "限定技，")
						and not string.find(_skill:getDescription(), "觉醒技，")
						and not string.find(_skill:getDescription(), "联动技，")
						and not string.find(_skill:getDescription(), "转换技，")
						and not string.find(_skill:getDescription(), "隐匿技，")
						and not string.find(_skill:getDescription(), "势力技，")
						and not string.find(_skill:getDescription(), "使命技，")
						and not string.find(_skill:getDescription(), "宗族技，")
						and not string.find(_skill:getDescription(), "说明技，")
						and not string.find(_skill:getDescription(), "激活技，")
						and not string.find(_skill:getDescription(), "学习技，")
						and not string.find(_skill:getDescription(), "解锁技，")
						and not string.find(_skill:getDescription(), "命运技，")
						and not string.find(_skill:getDescription(), "阶梯技，")
						and not string.find(_skill:getDescription(), "聚气技，")
						and not string.find(_skill:getDescription(), "昂扬技，")
						and not string.find(_skill:getDescription(), "皇后技，")
						then --带有，但仅锁定技(基本过滤)
							table.insert(jqxs, _skill:objectName())
						end
					end
				end
			end
			room:setPlayerProperty(player, "tyqiexie_jjarea_record", sgs.QVariant(table.concat(jqxs, ",")))
			room:setPlayerFlag(player, "tyqiexie_jjarea") --识别置入的是装备区还是“捐甲”区
			local mhp = ggenerall:getMaxHp()
			if mhp > 5 then mhp = 5 end
			local cds = sgs.IntList()
			local jjea_eq = {}
			for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
				local wqx = sgs.Sanguosha:getEngineCard(id)
				if mhp == 1 and wqx:isKindOf("WeaponQiexieOne") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXone_ID", sgs.QVariant(id))
					table.insert(jjea_eq, wqx:objectName())
				elseif mhp == 2 and wqx:isKindOf("WeaponQiexieTwo") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXtwo_ID", sgs.QVariant(id))
					table.insert(jjea_eq, wqx:objectName())
				elseif mhp == 3 and wqx:isKindOf("WeaponQiexieThree") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXthree_ID", sgs.QVariant(id))
					table.insert(jjea_eq, wqx:objectName())
				elseif mhp == 4 and wqx:isKindOf("WeaponQiexieFour") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXfour_ID", sgs.QVariant(id))
					table.insert(jjea_eq, wqx:objectName())
				elseif mhp == 5 and wqx:isKindOf("WeaponQiexieFive") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXfive_ID", sgs.QVariant(id))
					table.insert(jjea_eq, wqx:objectName())
				end
				if not cds:isEmpty() then break end
			end
			if not cds:isEmpty() then
				room:setPlayerProperty(player, "tyjuanjia_equiparea_record", sgs.QVariant())
				--local jjea_names = player:property("tyjuanjia_equiparea_record"):toString():split(",")
				if player:getPile("tyjuanjia"):length() > 0 then
					local dummy = sgs.Sanguosha:cloneCard("slash")
					dummy:addSubcards(player:getPile("tyjuanjia"))
					room:throwCard(dummy, player, nil)
					dummy:deleteLater()
				end
				room:broadcastSkillInvoke(self:objectName())
				player:addToPile("tyjuanjia", cds)
				--[[for _, _name in pairs(jjea_eq) do
					if not table.contains(jjea_names, _name) then
						table.insert(jjea_names, _name)
					end
				end
				room:setPlayerProperty(player, "tyjuanjia_equiparea_record", sgs.QVariant(table.concat(jjea_names, ",")))]]
				local jqxs = player:property("tyqiexie_jjarea_record"):toString():split(",")
				room:setPlayerProperty(player, "tyqiexie_jjarea_lost_record", sgs.QVariant())
				local jqxs_tolose = player:property("tyqiexie_jjarea_lost_record"):toString():split(",") --用于离开“捐甲”区时找到对应技能
				for _, sk in pairs(jqxs) do
					room:attachSkillToPlayer(player, sk)
					table.insert(jqxs_tolose, sk)
				end
				room:setPlayerProperty(player, "tyqiexie_jjarea_lost_record", sgs.QVariant(table.concat(jqxs_tolose, ",")))
				--[[for _, m in sgs.list(player:getMarkNames()) do
		        	if string.find(m, "tyqiexie_second") then
	                	room:setPlayerMark(player, m, 0)
					end
				end
				room:setPlayerMark(player, "&tyqiexie_second:" .. sgs.Sanguosha:translate(generall))]]
			end
			if player:hasFlag("tyqiexie_jjarea") then room:setPlayerFlag(player, "-tyqiexie_jjarea") end
		end
	end,
}
ty_shendianwei:addSkill(tyqiexie)
-----
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
-----
tyqiexieRemover = sgs.CreateTriggerSkill{
	name = "tyqiexieRemover",
	global = true,
	priority = 15,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.from and move.from:objectName() == player:objectName()
		and (move.from_places:contains(sgs.Player_PlaceEquip) or table.contains(move.from_pile_names, "tyjuanjia")) then
			for _, id in sgs.qlist(move.card_ids) do
				local card = sgs.Sanguosha:getCard(id)
				if card:isKindOf("WeaponQiexieOne") then
					room:setTag("WQXone_ID", sgs.QVariant(id))
					destroyEquip(room, move, "WQXone_ID")
				end
				if card:isKindOf("WeaponQiexieTwo") then
					room:setTag("WQXtwo_ID", sgs.QVariant(id))
					destroyEquip(room, move, "WQXtwo_ID")
				end
				if card:isKindOf("WeaponQiexieThree") then
					room:setTag("WQXthree_ID", sgs.QVariant(id))
					destroyEquip(room, move, "WQXthree_ID")
				end
				if card:isKindOf("WeaponQiexieFour") then
					room:setTag("WQXfour_ID", sgs.QVariant(id))
					destroyEquip(room, move, "WQXfour_ID")
				end
				if card:isKindOf("WeaponQiexieFive") then
					room:setTag("WQXfive_ID", sgs.QVariant(id))
					destroyEquip(room, move, "WQXfive_ID")
				end
			end
			if table.contains(move.from_pile_names, "tyjuanjia") then
				local can_empty = false
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if card:isKindOf("WeaponQiexieOne") or card:isKindOf("WeaponQiexieTwo") or card:isKindOf("WeaponQiexieThree")
					or card:isKindOf("WeaponQiexieFour") or card:isKindOf("WeaponQiexieFive") then
						can_empty = true
					end
				end
				if can_empty then --手动清除
					local jqxs_tolose = player:property("tyqiexie_jjarea_lost_record"):toString():split(",")
					for _, sk in pairs(jqxs_tolose) do
						room:detachSkillFromPlayer(player, sk, true, true)
					end
					room:setPlayerProperty(player, "tyqiexie_jjarea_lost_record", sgs.QVariant())
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("tyqiexieRemover") then skills:append(tyqiexieRemover) end
--为“挈挟”而量身打造的武器：
  --攻击范围1
WeaponQiexieOne = sgs.CreateWeapon{
	name = "_weapon_qiexie_one",
	class_name = "WeaponQiexieOne",
	range = 1,
	on_install = function(self, player)
		local room = player:getRoom()
		if player:hasFlag("tyqiexie_wparea") then
			local wqxs = player:property("tyqiexie_wparea_record"):toString():split(",")
			room:setPlayerProperty(player, "tyqiexie_wparea_lost_record", sgs.QVariant())
			local wqxs_tolose = player:property("tyqiexie_wparea_lost_record"):toString():split(",") --用于失去装备时找到对应技能
			for _, sk in pairs(wqxs) do
				room:attachSkillToPlayer(player, sk)
				table.insert(wqxs_tolose, sk)
			end
			room:setPlayerProperty(player, "tyqiexie_wparea_lost_record", sgs.QVariant(table.concat(wqxs_tolose, ",")))
		--[[elseif player:hasFlag("tyqiexie_jjarea") then
			local jqxs = player:property("tyqiexie_jjarea_record"):toString():split(",")
			room:setPlayerProperty(player, "tyqiexie_jjarea_lost_record", sgs.QVariant())
			local jqxs_tolose = player:property("tyqiexie_jjarea_lost_record"):toString():split(",") --用于离开“捐甲”区时找到对应技能
			for _, sk in pairs(jqxs) do
				room:attachSkillToPlayer(player, sk)
				table.insert(jqxs_tolose, sk)
			end
			room:setPlayerProperty(player, "tyqiexie_jjarea_lost_record", sgs.QVariant(table.concat(jqxs_tolose, ",")))]]
		end
		return false
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		local wqxs_tolose = player:property("tyqiexie_wparea_lost_record"):toString():split(",")
		for _, sk in pairs(wqxs_tolose) do
			room:detachSkillFromPlayer(player, sk, true, true)
		end
		room:setPlayerProperty(player, "tyqiexie_wparea_lost_record", sgs.QVariant())
		return false
	end,
}
WeaponQiexieOne:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
WeaponQiexieOne:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
WeaponQiexieOne:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
WeaponQiexieOne:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
  --攻击范围2
WeaponQiexieTwo = sgs.CreateWeapon{
	name = "_weapon_qiexie_two",
	class_name = "WeaponQiexieTwo",
	range = 2,
	on_install = function(self, player)
		local room = player:getRoom()
		if player:hasFlag("tyqiexie_wparea") then
			local wqxs = player:property("tyqiexie_wparea_record"):toString():split(",")
			room:setPlayerProperty(player, "tyqiexie_wparea_lost_record", sgs.QVariant())
			local wqxs_tolose = player:property("tyqiexie_wparea_lost_record"):toString():split(",") --用于失去装备时找到对应技能
			for _, sk in pairs(wqxs) do
				room:attachSkillToPlayer(player, sk)
				table.insert(wqxs_tolose, sk)
			end
			room:setPlayerProperty(player, "tyqiexie_wparea_lost_record", sgs.QVariant(table.concat(wqxs_tolose, ",")))
		--[[elseif player:hasFlag("tyqiexie_jjarea") then
			local jqxs = player:property("tyqiexie_jjarea_record"):toString():split(",")
			room:setPlayerProperty(player, "tyqiexie_jjarea_lost_record", sgs.QVariant())
			local jqxs_tolose = player:property("tyqiexie_jjarea_lost_record"):toString():split(",") --用于离开“捐甲”区时找到对应技能
			for _, sk in pairs(jqxs) do
				room:attachSkillToPlayer(player, sk)
				table.insert(jqxs_tolose, sk)
			end
			room:setPlayerProperty(player, "tyqiexie_jjarea_lost_record", sgs.QVariant(table.concat(jqxs_tolose, ",")))]]
		end
		return false
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		local wqxs_tolose = player:property("tyqiexie_wparea_lost_record"):toString():split(",")
		for _, sk in pairs(wqxs_tolose) do
			room:detachSkillFromPlayer(player, sk, true, true)
		end
		room:setPlayerProperty(player, "tyqiexie_wparea_lost_record", sgs.QVariant())
		return false
	end,
}
WeaponQiexieTwo:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
WeaponQiexieTwo:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
WeaponQiexieTwo:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
WeaponQiexieTwo:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
  --攻击范围3
WeaponQiexieThree = sgs.CreateWeapon{
	name = "_weapon_qiexie_three",
	class_name = "WeaponQiexieThree",
	range = 3,
	on_install = function(self, player)
		local room = player:getRoom()
		if player:hasFlag("tyqiexie_wparea") then
			local wqxs = player:property("tyqiexie_wparea_record"):toString():split(",")
			room:setPlayerProperty(player, "tyqiexie_wparea_lost_record", sgs.QVariant())
			local wqxs_tolose = player:property("tyqiexie_wparea_lost_record"):toString():split(",") --用于失去装备时找到对应技能
			for _, sk in pairs(wqxs) do
				room:attachSkillToPlayer(player, sk)
				table.insert(wqxs_tolose, sk)
			end
			room:setPlayerProperty(player, "tyqiexie_wparea_lost_record", sgs.QVariant(table.concat(wqxs_tolose, ",")))
		--[[elseif player:hasFlag("tyqiexie_jjarea") then
			local jqxs = player:property("tyqiexie_jjarea_record"):toString():split(",")
			room:setPlayerProperty(player, "tyqiexie_jjarea_lost_record", sgs.QVariant())
			local jqxs_tolose = player:property("tyqiexie_jjarea_lost_record"):toString():split(",") --用于离开“捐甲”区时找到对应技能
			for _, sk in pairs(jqxs) do
				room:attachSkillToPlayer(player, sk)
				table.insert(jqxs_tolose, sk)
			end
			room:setPlayerProperty(player, "tyqiexie_jjarea_lost_record", sgs.QVariant(table.concat(jqxs_tolose, ",")))]]
		end
		return false
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		local wqxs_tolose = player:property("tyqiexie_wparea_lost_record"):toString():split(",")
		for _, sk in pairs(wqxs_tolose) do
			room:detachSkillFromPlayer(player, sk, true, true)
		end
		room:setPlayerProperty(player, "tyqiexie_wparea_lost_record", sgs.QVariant())
		return false
	end,
}
WeaponQiexieThree:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
WeaponQiexieThree:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
WeaponQiexieThree:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
WeaponQiexieThree:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
  --攻击范围4
WeaponQiexieFour = sgs.CreateWeapon{
	name = "_weapon_qiexie_four",
	class_name = "WeaponQiexieFour",
	range = 4,
	on_install = function(self, player)
		local room = player:getRoom()
		if player:hasFlag("tyqiexie_wparea") then
			local wqxs = player:property("tyqiexie_wparea_record"):toString():split(",")
			room:setPlayerProperty(player, "tyqiexie_wparea_lost_record", sgs.QVariant())
			local wqxs_tolose = player:property("tyqiexie_wparea_lost_record"):toString():split(",") --用于失去装备时找到对应技能
			for _, sk in pairs(wqxs) do
				room:attachSkillToPlayer(player, sk)
				table.insert(wqxs_tolose, sk)
			end
			room:setPlayerProperty(player, "tyqiexie_wparea_lost_record", sgs.QVariant(table.concat(wqxs_tolose, ",")))
		--[[elseif player:hasFlag("tyqiexie_jjarea") then
			local jqxs = player:property("tyqiexie_jjarea_record"):toString():split(",")
			room:setPlayerProperty(player, "tyqiexie_jjarea_lost_record", sgs.QVariant())
			local jqxs_tolose = player:property("tyqiexie_jjarea_lost_record"):toString():split(",") --用于离开“捐甲”区时找到对应技能
			for _, sk in pairs(jqxs) do
				room:attachSkillToPlayer(player, sk)
				table.insert(jqxs_tolose, sk)
			end
			room:setPlayerProperty(player, "tyqiexie_jjarea_lost_record", sgs.QVariant(table.concat(jqxs_tolose, ",")))]]
		end
		return false
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		local wqxs_tolose = player:property("tyqiexie_wparea_lost_record"):toString():split(",")
		for _, sk in pairs(wqxs_tolose) do
			room:detachSkillFromPlayer(player, sk, true, true)
		end
		room:setPlayerProperty(player, "tyqiexie_wparea_lost_record", sgs.QVariant())
		return false
	end,
}
WeaponQiexieFour:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
WeaponQiexieFour:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
WeaponQiexieFour:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
WeaponQiexieFour:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
  --攻击范围5
WeaponQiexieFive = sgs.CreateWeapon{
	name = "_weapon_qiexie_five",
	class_name = "WeaponQiexieFive",
	range = 5,
	on_install = function(self, player)
		local room = player:getRoom()
		if player:hasFlag("tyqiexie_wparea") then
			local wqxs = player:property("tyqiexie_wparea_record"):toString():split(",")
			room:setPlayerProperty(player, "tyqiexie_wparea_lost_record", sgs.QVariant())
			local wqxs_tolose = player:property("tyqiexie_wparea_lost_record"):toString():split(",") --用于失去装备时找到对应技能
			for _, sk in pairs(wqxs) do
				room:attachSkillToPlayer(player, sk)
				table.insert(wqxs_tolose, sk)
			end
			room:setPlayerProperty(player, "tyqiexie_wparea_lost_record", sgs.QVariant(table.concat(wqxs_tolose, ",")))
		--[[elseif player:hasFlag("tyqiexie_jjarea") then
			local jqxs = player:property("tyqiexie_jjarea_record"):toString():split(",")
			room:setPlayerProperty(player, "tyqiexie_jjarea_lost_record", sgs.QVariant())
			local jqxs_tolose = player:property("tyqiexie_jjarea_lost_record"):toString():split(",") --用于离开“捐甲”区时找到对应技能
			for _, sk in pairs(jqxs) do
				room:attachSkillToPlayer(player, sk)
				table.insert(jqxs_tolose, sk)
			end
			room:setPlayerProperty(player, "tyqiexie_jjarea_lost_record", sgs.QVariant(table.concat(jqxs_tolose, ",")))]]
		end
		return false
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		local wqxs_tolose = player:property("tyqiexie_wparea_lost_record"):toString():split(",")
		for _, sk in pairs(wqxs_tolose) do
			room:detachSkillFromPlayer(player, sk, true, true)
		end
		room:setPlayerProperty(player, "tyqiexie_wparea_lost_record", sgs.QVariant())
		return false
	end,
}
WeaponQiexieFive:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
WeaponQiexieFive:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
WeaponQiexieFive:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
WeaponQiexieFive:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)
-----

tycuijueCard = sgs.CreateSkillCard{
	name = "tycuijueCard",
	target_fixed = false,
	filter = function(self, targets, to_select, player)
		local distance = 0
		for _, p in sgs.qlist(player:getAliveSiblings()) do --第一遍，算出(攻击范围内)最远距离
			if player:inMyAttackRange(p) then
				local dt = player:distanceTo(p)
				if dt > distance then distance = dt
				else continue end
			else
				continue
			end
		end
		local tgts = {}
		for _, q in sgs.qlist(player:getAliveSiblings()) do --第二遍，统计所有(攻击范围内)最远距离且符合其他所有限制的角色
			if not player:inMyAttackRange(q) or player:distanceTo(q) < distance then continue end
			if q:getMark("tycuijueTarget-Clear") > 0 then continue end
			table.insert(tgts, q)
		end
		if #tgts == 0 then return false end
		return table.contains(tgts, to_select)
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		room:addPlayerMark(effect.to, "tycuijueTarget-Clear")
		room:damage(sgs.DamageStruct("tycuijue", effect.from, effect.to))
	end,
}
tycuijue = sgs.CreateOneCardViewAsSkill{
	name = "tycuijue",
	filter_pattern = ".!",
	view_as = function(self, card)
		local cj_card = tycuijueCard:clone()
		cj_card:addSubcard(card:getId())
		return cj_card
	end,
	enabled_at_play = function(self, player)
		return not player:isNude() and player:canDiscard(player, "he")
	end,
}
ty_shendianwei:addSkill(tycuijue)

--OL神武将==--
--神曹丕(神武再世)（和削弱后的版本一样；一开始6血的版本不可能放出来，无解的存在，现在这个版本军八也是天花板级别）
ol_shencaopi = sgs.General(extension_o, "ol_shencaopi", "god", 5, true)

olchuyuan = sgs.CreateMasochismSkill{
	name = "olchuyuan",
	on_damaged = function(self, player, damage)
		local room = player:getRoom()
		for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
			if p:getPile("powerful"):length() < p:getMaxHp() and player and player:isAlive()
			and p:askForSkillInvoke(self:objectName()) then
				room:broadcastSkillInvoke(self:objectName())
				room:drawCards(player, 1, self:objectName())
				if not player:isKongcheng() then
					local card_id = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					if player:getHandcardNum() == 1 then
						card_id = player:handCards():first()
						--room:getThread():delay()
					else
						card_id = room:askForExchange(player, self:objectName(), 1, 1, false, "QuanjiPush"):getSubcards():first()
					end
					p:addToPile("powerful", card_id)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
ol_shencaopi:addSkill(olchuyuan)

oldengji = sgs.CreatePhaseChangeSkill{
	name = "oldengji",
	frequency = sgs.Skill_Wake,
	waked_skills = "tenyearjianxiong, oltianxing",
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getPile("powerful"):length() < 3 then return false end
		return true
	end,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		room:doSuperLightbox("ol_shencaopi", "oldengji")
		room:addPlayerMark(player, self:objectName())
		local dummy = sgs.Sanguosha:cloneCard("slash")
		dummy:addSubcards(player:getPile("powerful"))
		room:obtainCard(player, dummy, false)
		if room:changeMaxHpForAwakenSkill(player) then
			room:handleAcquireDetachSkills(player, "tenyearjianxiong|oltianxing")
		end
	end,
}
ol_shencaopi:addSkill(oldengji)
ol_shencaopi:addRelateSkill("tenyearjianxiong")
ol_shencaopi:addRelateSkill("oltianxing")

oltianxing = sgs.CreatePhaseChangeSkill{
	name = "oltianxing",
	frequency = sgs.Skill_Wake,
	waked_skills = "tenyearrende, tenyearzhiheng, olluanji",
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getPile("powerful"):length() < 3 then return false end
		return true
	end,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		room:doSuperLightbox("ol_shencaopi", "oltianxing")
		room:addPlayerMark(player, self:objectName())
		local dummy = sgs.Sanguosha:cloneCard("slash")
		dummy:addSubcards(player:getPile("powerful"))
		room:obtainCard(player, dummy, false)
		if room:changeMaxHpForAwakenSkill(player) then
			room:detachSkillFromPlayer(player, "olchuyuan")
			local choices = {}
			if not player:hasSkill("tenyearrende") then
				table.insert(choices, "tenyearrende")
			end
			if not player:hasSkill("tenyearzhiheng") then
				table.insert(choices, "tenyearzhiheng")
			end
			if not player:hasSkill("olluanji") then
				table.insert(choices, "olluanji")
			end
			--[[if #choices > 0 then
				local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			end
			room:handleAcquireDetachSkills(player, "-olchuyuan|"..choice)
			]]
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			if choice == "tenyearrende" then
				room:acquireSkill(player, "tenyearrende")
			elseif choice == "tenyearzhiheng" then
				room:acquireSkill(player, "tenyearzhiheng")
			elseif choice == "olluanji" then
				room:acquireSkill(player, "olluanji")
			end
		end
	end,
}
if not sgs.Sanguosha:getSkill("oltianxing") then skills:append(oltianxing) end
ol_shencaopi:addRelateSkill("tenyearrende")
ol_shencaopi:addRelateSkill("tenyearzhiheng")
ol_shencaopi:addRelateSkill("olluanji")

--神甄姬(神武再世)（OL+欢乐杀加强部分）
ol_shenzhenji = sgs.General(extension_o, "ol_shenzhenji", "god", 3, false)

olshenfu = sgs.CreatePhaseChangeSkill{
	name = "olshenfu",
	on_phasechange = function(self, player)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Finish then
			local n = 0
			local players = room:getAlivePlayers()
			if math.mod(player:getHandcardNum(), 2) == 1 then
				players:removeOne(player)
			end
			local to = room:askForPlayerChosen(player, players, self:objectName(), self:objectName().."-invoke", true, true)
			if to then
				room:broadcastSkillInvoke(self:objectName(), math.mod(player:getHandcardNum(), 2)+1)
				if math.mod(player:getHandcardNum(), 2) == 1 then
					while true do
						if n < 5 then n = n + 1 end
						room:damage(sgs.DamageStruct(self:objectName(), player, to, 1, sgs.DamageStruct_Thunder))
						if to and to:isAlive() then break end
						to = room:askForPlayerChosen(player, players, self:objectName(), self:objectName().."-invoke", true, true)
					end
				else
					while true do
						if n < 5 then n = n + 1 end
						local choices = {"draw"}
						if not to:isNude() and to:canDiscard(to, "he") then
							table.insert(choices, "discard")
						end
						local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
						if choice == "draw" then
							to:drawCards(1, self:objectName())
						else
							local to_throw = room:askForCardChosen(player, to, "he", self:objectName(), false, sgs.Card_MethodDiscard)
							room:throwCard(sgs.Sanguosha:getCard(to_throw), to, player)
						end
						players:removeOne(to)
						if to:getHandcardNum() ~= to:getHp() then break end
						to = room:askForPlayerChosen(player, players, self:objectName(), self:objectName().."-invoke", true, true)
					end
				end
			end
			if n > 0 then
				room:broadcastSkillInvoke(self:objectName())
				room:drawCards(player, n, self:objectName())
			end
		end
	end,
}
ol_shenzhenji:addSkill(olshenfu)

olqixianMXC = sgs.CreateMaxCardsSkill{
	name = "olqixianMXC",
	fixed_func = function(self, player)
		if player:hasSkill("olqixian") then
			return 7
		end
		return -1
	end,
}
olqixian = sgs.CreateTriggerSkill{
	name = "olqixian",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseEnd, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Play then
				if not room:askForSkillInvoke(player, self:objectName(), data) then return false end
				room:broadcastSkillInvoke(self:objectName())
				if not player:isKongcheng() then
					local card_id = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					if player:getHandcardNum() == 1 then
						card_id = player:handCards():first()
						--room:getThread():delay()
					else
						card_id = room:askForExchange(player, self:objectName(), 1, 1, false, "QuanjiPush"):getSubcards():first()
					end
					player:addToPile("LingSheJi", card_id, false)
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			local dummy = sgs.Sanguosha:cloneCard("slash")
			dummy:addSubcards(player:getPile("LingSheJi"))
			room:obtainCard(player, dummy, false)
		end
	end,
}
ol_shenzhenji:addSkill(olqixian)
if not sgs.Sanguosha:getSkill("olqixianMXC") then skills:append(olqixianMXC) end

joyfeifu = sgs.CreateOneCardViewAsSkill{
	name = "joyfeifu",
	response_pattern = "jink",
	filter_pattern = ".|black",
	response_or_use = true,
	view_as = function(self, card)
		local jink = sgs.Sanguosha:cloneCard("jink", card:getSuit(), card:getNumber())
		jink:setSkillName(self:objectName())
		jink:addSubcard(card:getId())
		return jink
	end,
}
ol_shenzhenji:addSkill(joyfeifu)

--神孙权
ol_shensunquan = sgs.General(extension_o, "ol_shensunquan", "god", 4, true)

olyuhengCard = sgs.CreateSkillCard{
	name = "olyuhengCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		local n = self:subcardsLength()
		room:addPlayerMark(source, "olyuhengSCL", n)
	end,
}
olyuhengVS = sgs.CreateViewAsSkill{
	name = "olyuheng",
	n = 999, --n = 4,
	view_filter = function(self, selected, to_select)
		local m = sgs.Self:getHandcardNum() + sgs.Self:getEquips():length()
		local n = math.max(1, m)
		if #selected >= n then return false end
		for _, c in sgs.list(selected) do
			if c:getSuit() == to_select:getSuit() then return false end
		end
		return true
	end,
	view_as = function(self, cards)
		local m = sgs.Self:getHandcardNum() + sgs.Self:getEquips():length()
		local n = math.max(1, m)
		if #cards >= 1 and #cards <= n then
			local MXC = olyuhengCard:clone()
			for _, c in ipairs(cards) do
				MXC:addSubcard(c)
			end
			return MXC
		end
		return nil
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@olyuheng")
	end,
}
olyuheng = sgs.CreateTriggerSkill{
    name = "olyuheng",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart, sgs.EventPhaseChanging},
	view_as_skill = olyuhengVS,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local sks = player:getTag("olyuheng"):toString():split("+")
		if event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_RoundStart and not player:isNude() then
			if not room:askForUseCard(player, "@@olyuheng!", "@olyuheng-card") and player:getState() == "online" then return false end
			if player:getState() == "robot" then --AI，无脑弃一手牌换取一个技能
				room:askForDiscard(player, self:objectName(), 1, 1, false, true)
				room:addPlayerMark(player, "olyuhengSCL")
				room:broadcastSkillInvoke(self:objectName())
			end
			while player:getMark("olyuhengSCL") > 0 do
				local all_generals = sgs.Sanguosha:getLimitedGeneralNames()
				local wu_generals = {}
				for _, name in ipairs(all_generals) do
					local general = sgs.Sanguosha:getGeneral(name)
					if general:getKingdom() == "wu" then
						table.insert(wu_generals, name)
					end
				end
				local wu_general = {}
				local first = wu_generals[math.random(1, #wu_generals)]
				table.insert(wu_general, first)
				local generals = table.concat(wu_general, "+")
				local general = sgs.Sanguosha:getGeneral(room:askForGeneral(player, generals))
				local skill_names = {}
				for _, skill in sgs.qlist(general:getVisibleSkillList()) do --没有加主公技、限定技、觉醒技限制，全都可以拿
					table.insert(skill_names, skill:objectName())
				end
				if #skill_names > 0 then
					local one = skill_names[math.random(1, #skill_names)]
					if not player:hasFlag("oldiliLocked") then room:setPlayerFlag(player, "oldiliLocked") end --因为我的写法不是一次性获得所有技能而且依次一个个获得，故需防止于获得技能途中就触发觉醒
					if player:hasFlag("oldiliLocked") and player:getMark("olyuhengSCL") <= 1 then room:setPlayerFlag(player, "-oldiliLocked") end --获得最后一个技能前，可以解除限制
					room:acquireSkill(player, one)
					table.insert(sks, one) --登记为以此法获得的技能
					room:removePlayerMark(player, "olyuhengSCL")
				end
			end
			player:setTag("olyuheng", sgs.QVariant(table.concat(sks, "+")))
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			local n = 0
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			for _, lsk in ipairs(sks) do
				if player:hasSkill(lsk) then
					room:detachSkillFromPlayer(player, lsk)
					n = n + 1
				end
			end
			room:drawCards(player, n, self:objectName())
			for _, lsk in ipairs(sks) do --同时清除所有于当回合登记的技能记录
				table.removeOne(sks, lsk)
			end
			player:setTag("olyuheng", sgs.QVariant(table.concat(sks, "+")))
		end
	end,
}
ol_shensunquan:addSkill(olyuheng)

oldili = sgs.CreateTriggerSkill{
    name = "oldili",
	frequency = sgs.Skill_Wake,
	waked_skills = "dl_shengzhi, dl_quandao, dl_chigang",
	events = {sgs.EventAcquireSkill},
	can_wake = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:hasFlag("oldiliLocked") then return false end
		local n = 0
		local m = player:getMaxHp()
		for _, skill in sgs.qlist(player:getSkillList()) do
			n = n + 1
		end
		--除开一些虽做成技能按钮但实际定位并非为技能
		if player:hasSkill("mobileGOD_SkinChange_Button") then n = n - 1 end
		if player:hasSkill("GOD_changeFullSkin_Button") then n = n - 1 end
		if player:hasSkill("wmzgl_SkinChange_Button") then n = n - 1 end
		if player:hasSkill("f_mobile_efs_egg") then n = n - 1 end
		if player:hasSkill("f_mobile_efs_flower") then n = n - 1 end
		if n <= m then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		room:doSuperLightbox("ol_shensunquan", self:objectName())
		room:addPlayerMark(player, self:objectName())
		if room:changeMaxHpForAwakenSkill(player) then
			local loseskill = {}
			table.insert(loseskill, "end")
			for _, skill in sgs.qlist(player:getSkillList()) do
				if skill:objectName() ~= self:objectName() and skill:objectName() ~= "mobileGOD_SkinChange_Button" and skill:objectName() ~= "GOD_changeFullSkin_Button"
				and skill:objectName() ~= "wmzgl_SkinChange_Button" and skill:objectName() ~= "f_mobile_efs_egg" and skill:objectName() ~= "f_mobile_efs_flower" then
					table.insert(loseskill, skill:objectName())
				end
			end
			local excg = 0
			while not player:hasFlag("oldiliAddSkillsEND") do
				local choice = room:askForChoice(player, self:objectName(), table.concat(loseskill, "+"))
				if choice == "end" then
					room:setPlayerFlag(player, "oldiliAddSkillsEND")
				else
					room:detachSkillFromPlayer(player, choice)
					table.removeOne(loseskill, choice)
					excg = excg + 1
				end
			end
			if player:hasFlag("oldiliAddSkillsEND") then room:setPlayerFlag(player, "-oldiliAddSkillsEND") end
			if excg >= 1 then
				room:acquireSkill(player, "dl_shengzhi")
			end
			if excg >= 2 then
				room:acquireSkill(player, "dl_quandao")
			end
			if excg >= 3 then
				room:acquireSkill(player, "dl_chigang")
			end
		end
	end,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
ol_shensunquan:addSkill(oldili)
ol_shensunquan:addRelateSkill("dl_shengzhi")
ol_shensunquan:addRelateSkill("dl_quandao")
ol_shensunquan:addRelateSkill("dl_chigang")
--“圣质”
dl_shengzhi = sgs.CreateTriggerSkill{
    name = "dl_shengzhi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		if use.from:objectName() ~= player:objectName() then return false end
		if use.card:isKindOf("SkillCard") and use.card:getSkillName() ~= "mobilegod_skinchange_button" and use.card:getSkillName() ~= "god_changefullskin_button"
		and use.card:getSkillName() ~= "wmzgl_skinchange_button" and use.card:getSkillName() ~= "f_mobile_efs_egg" and use.card:getSkillName() ~= "f_mobile_efs_flower" then
			local log = sgs.LogMessage()
			log.type = "$dl_shengzhiNoLimit"
			log.from = player
			room:sendLog(log)
			room:broadcastSkillInvoke(self:objectName())
			room:setPlayerFlag(player, "dlszCardBuff")
		elseif use.card and not use.card:isKindOf("SkillCard") and player:hasFlag("dlszCardBuff") then
			room:setPlayerFlag(player, "-dlszCardBuff")
		end
	end,
}
dl_shengzhiNoLimit = sgs.CreateTargetModSkill{
	name = "dl_shengzhiNoLimit",
	pattern = "Card",
	distance_limit_func = function(self, player, card)
		if player:hasSkill("dl_shengzhi") and player:hasFlag("dlszCardBuff") and not card:isKindOf("SkillCard") then
		    return 1000
		else
		    return 0
		end
	end,
	residue_func = function(self, player, card)
		if player:hasSkill("dl_shengzhi") and player:hasFlag("dlszCardBuff") and not card:isKindOf("SkillCard") then
			return 1000
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("dl_shengzhi") then skills:append(dl_shengzhi) end
if not sgs.Sanguosha:getSkill("dl_shengzhiNoLimit") then skills:append(dl_shengzhiNoLimit) end
--“权道”（因为“权道”涉及到技能卡牌，所以实际上可以和我改的“圣质”打配合，算是弥补一些没能还原“圣质”的缺憾吧。）
dl_quandao = sgs.CreateTriggerSkill{
    name = "dl_quandao",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		if use.from:objectName() ~= player:objectName() then return false end
		if use.card:isKindOf("Slash") or use.card:isNDTrick() then
			local s = 0
			local ndt = 0
			for _, card in sgs.qlist(player:getHandcards()) do
				if card:isKindOf("Slash") then
					s = s + 1
				elseif card:isNDTrick() then
					ndt = ndt + 1
				end
			end
			if s > ndt then
				local n = s - ndt
				room:setPlayerMark(player, "dl_quandao-throw", n)
				if room:askForUseCard(player, "@@dl_quandao_throwslash!", "@dl_quandao_throwslash") then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:drawCards(player, 1, self:objectName())
				end
				room:setPlayerMark(player, "dl_quandao-throw", 0)
			elseif s < ndt then
				local m = ndt - s
				room:setPlayerMark(player, "dl_quandao-throw", m)
				if room:askForUseCard(player, "@@dl_quandao_throwNDtrick!", "@dl_quandao_throwNDtrick") then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:drawCards(player, 1, self:objectName())
				end
				room:setPlayerMark(player, "dl_quandao-throw", 0)
			elseif s == ndt then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:drawCards(player, 1, self:objectName())
			end
		end
	end,
}
  --弃置杀
dl_quandao_throwslashCard = sgs.CreateSkillCard{
	name = "dl_quandao_throwslashCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
	end,
}
dl_quandao_throwslash = sgs.CreateViewAsSkill{
	name = "dl_quandao_throwslash",
	n = 999,
	view_filter = function(self, selected, to_select)
		local n = sgs.Self:getMark("dl_quandao-throw")
		if #selected >= n then return false end
		return to_select:isKindOf("Slash")
	end,
	view_as = function(self, cards)
		local n = sgs.Self:getMark("dl_quandao-throw")
		if #cards >= n then
			local TC = dl_quandao_throwslashCard:clone()
			for _, c in ipairs(cards) do
				TC:addSubcard(c)
			end
			return TC
		end
		return nil
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@dl_quandao_throwslash")
	end,
}
  --弃置普通锦囊牌
dl_quandao_throwNDtrickCard = sgs.CreateSkillCard{
	name = "dl_quandao_throwNDtrickCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
	end,
}
dl_quandao_throwNDtrick = sgs.CreateViewAsSkill{
	name = "dl_quandao_throwNDtrick",
	n = 999,
	view_filter = function(self, selected, to_select)
		local n = sgs.Self:getMark("dl_quandao-throw")
		if #selected >= n then return false end
		return to_select:isNDTrick()
	end,
	view_as = function(self, cards)
		local n = sgs.Self:getMark("dl_quandao-throw")
		if #cards >= n then
			local TC = dl_quandao_throwNDtrickCard:clone()
			for _, c in ipairs(cards) do
				TC:addSubcard(c)
			end
			return TC
		end
		return nil
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@dl_quandao_throwNDtrick")
	end,
}
if not sgs.Sanguosha:getSkill("dl_quandao") then skills:append(dl_quandao) end
if not sgs.Sanguosha:getSkill("dl_quandao_throwslash") then skills:append(dl_quandao_throwslash) end
if not sgs.Sanguosha:getSkill("dl_quandao_throwNDtrick") then skills:append(dl_quandao_throwNDtrick) end
--“持纲”
dl_chigang = sgs.CreateTriggerSkill{
	name = "dl_chigang",
	priority = {3, 2},
	change_skill = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		local n = player:getChangeSkillState(self:objectName())
		if change.to == sgs.Player_Judge then
		    if n == 1 then
			    room:setChangeSkillState(player, self:objectName(), 2)
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				player:setPhase(sgs.Player_Draw)
				room:broadcastProperty(player, "phase")
				local thread = room:getThread()
				if not thread:trigger(sgs.EventPhaseStart, room, player) then
					thread:trigger(sgs.EventPhaseProceeding, room, player)
				end
				thread:trigger(sgs.EventPhaseEnd, room, player)
				player:setPhase(sgs.Player_Judge)
				room:broadcastProperty(player, "phase")
				if not player:isSkipped(sgs.Player_Judge) then
					player:skip(change.to)
				end
			elseif n == 2 then
			    room:setChangeSkillState(player, self:objectName(), 1)
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				player:setPhase(sgs.Player_Play)
				room:broadcastProperty(player, "phase")
				local thread = room:getThread()
				if not thread:trigger(sgs.EventPhaseStart, room, player) then
					thread:trigger(sgs.EventPhaseProceeding, room, player)
				end
				thread:trigger(sgs.EventPhaseEnd, room, player)
				player:setPhase(sgs.Player_Judge)
				room:broadcastProperty(player, "phase")
				if not player:isSkipped(sgs.Player_Judge) then
					player:skip(change.to)
				end
			end
		end
	end,
}
if not sgs.Sanguosha:getSkill("dl_chigang") then skills:append(dl_chigang) end

--

--(界)神张角
ol_shenzhangjiao = sgs.General(extension_o, "ol_shenzhangjiao", "god", 3, true)

ol_shenzhangjiao:addSkill("tyyizhao")

olsanshou = sgs.CreateTriggerSkill{
	name = "olsanshou",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.GameStart then
			local cards, cards_copy = sgs.CardList(), sgs.CardList()
			for _, id in sgs.qlist(room:getDrawPile()) do
				local card = sgs.Sanguosha:getCard(id)
				if card:isKindOf("OlSanshou") then
					cards:append(card)
					cards_copy:append(card)
				end
			end
			if not cards:isEmpty() then
				local equipA
				while not equipA do
					if cards:isEmpty() then break end
					if not equipA then
						equipA = cards:at(math.random(0, cards:length() - 1))
						for _, card in sgs.qlist(cards_copy) do
							if card:getSubtype() == equipA:getSubtype() then
								cards:removeOne(card)
							end
						end
					end
				end
				if equipA then
					local Moves = sgs.CardsMoveList()
					local equip = equipA:getRealCard():toEquipCard()
					local equip_index = equip:location()
					if player:getEquip(equip_index) == nil and player:hasEquipArea(equip_index) then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						Moves:append(sgs.CardsMoveStruct(equipA:getId(), player, sgs.Player_PlaceEquip, sgs.CardMoveReason()))
					else
						Moves:append(sgs.CardsMoveStruct(equipA:getId(), player, sgs.Player_PlaceHand, sgs.CardMoveReason()))
					end
					room:moveCardsAtomic(Moves, true)
				end
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceEquip) then
				for _, ss in sgs.qlist(move.card_ids) do
					local OLSS = sgs.Sanguosha:getCard(ss)
					if OLSS:isKindOf("OlSanshou") then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						room:drawCards(player, 3, self:objectName())
						break
					end
				end
			end
		end
	end,
}
ol_shenzhangjiao:addSkill(olsanshou)

--==专属装备·三首（防具）==--
function ArmorNotNullified(target)
	return target:getMark("Armor_Nullified") < 1
	and #target:getTag("Qinggang"):toStringList() < 1
	and target:getMark("Equips_Nullified_to_Yourself") < 1
end
OlSanshows = sgs.CreateTriggerSkill{
	name = "OlSanshow",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local damage = data:toDamage()
		if room:askForSkillInvoke(player, self:objectName(), data) then
			local card_ids = room:getNCards(3)
			room:fillAG(card_ids)
			room:getThread():delay()
			local can_invoke = false
			for _, c in sgs.qlist(card_ids) do
				local card = sgs.Sanguosha:getCard(c)
				if (card:isKindOf("BasicCard") and not player:hasFlag("olsanshou_basic")) or (card:isKindOf("TrickCard") and not player:hasFlag("olsanshou_trick"))
				or (card:isKindOf("EquipCard") and not player:hasFlag("olsanshou_equip")) then
					can_invoke = true
				end
			end
			room:clearAG()
			if can_invoke then
				local log = sgs.LogMessage()
				--log.type = "$olsanshouPrevent"
				log.type = "$tysanshouPrevent"
				log.from = player
				room:sendLog(log)
				room:broadcastSkillInvoke("olsanshou")
				room:setEmotion(player, "skill_nullify")
				return true
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getArmor():isKindOf("OlSanshou") and ArmorNotNullified(player)
	end,
}
olsanshouCardUsed = sgs.CreateTriggerSkill{
	name = "olsanshouCardUsed",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.CardResponded, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.CardUsed or event == sgs.CardResponded then
			local card = nil
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and card:getHandlingMethod() == sgs.Card_MethodUse then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if card:isKindOf("BasicCard") and not p:hasFlag("olsanshou_basic") then
						room:setPlayerFlag(p, "olsanshou_basic")
					end
					if card:isKindOf("TrickCard") and not p:hasFlag("olsanshou_trick") then
						room:setPlayerFlag(p, "olsanshou_trick")
					end
					if card:isKindOf("EquipCard") and not p:hasFlag("olsanshou_equip") then
						room:setPlayerFlag(p, "olsanshou_equip")
					end
				end
			end
		else
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("olsanshou_basic") then room:setPlayerFlag(p, "-olsanshou_basic") end
				if p:hasFlag("olsanshou_trick") then room:setPlayerFlag(p, "-olsanshou_trick") end
				if p:hasFlag("olsanshou_equip") then room:setPlayerFlag(p, "-olsanshou_equip") end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
OlSanshou = sgs.CreateArmor{
	name = "ol_sanshou",
	class_name = "OlSanshou",
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, OlSanshows, false, true, false)
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "OlSanshow", true, true)
	end,
}
OlSanshou:clone(sgs.Card_Diamond, 12):setParent(newgodsCard)
if not sgs.Sanguosha:getSkill("OlSanshow") then skills:append(OlSanshows) end
if not sgs.Sanguosha:getSkill("olsanshouCardUsed") then skills:append(olsanshouCardUsed) end

olsijun = sgs.CreateTriggerSkill{
	name = "olsijun",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local phase = player:getPhase()
		if phase ~= sgs.Player_Start then return false end
		local n = player:getMark("&tyHuang")
		local m = room:getDrawPile():length()
		if n <= m then return false end
		if room:askForSkillInvoke(player, self:objectName(), data) then
			room:setPlayerMark(player, "tyHuang", 0)
			player:loseAllMarks("&tyHuang")
			local olsijun_cards = {}
			local olsijun_one_count = 36
			--以下代码默认一张牌的点数不超过13
			while olsijun_one_count > 13 do
				local olsijun_this_count = 0
				for _, id in sgs.qlist(room:getDrawPile()) do
					if not table.contains(olsijun_cards, id) and olsijun_this_count < 1 then
						local num = sgs.Sanguosha:getCard(id):getNumber()
						olsijun_one_count = olsijun_one_count - num
						olsijun_this_count = olsijun_this_count + 1
						table.insert(olsijun_cards, id)
					end
				end
			end
			--当“olsijun_one_count”计数已减至不超过13且不为0时，精准拿最后一张点数已定死的牌
			local olsijun_last_count = 0
			if olsijun_one_count > 0 then
				for _, id in sgs.qlist(room:getDrawPile()) do
					if sgs.Sanguosha:getCard(id):getNumber() == olsijun_one_count and not table.contains(olsijun_cards, id) and olsijun_last_count < 1 then
						olsijun_last_count = olsijun_last_count + 1
						table.insert(olsijun_cards, id)
					end
				end
			end
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, id in ipairs(olsijun_cards) do
				dummy:addSubcard(id)
			end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			room:obtainCard(player, dummy, false)
		end
	end,
}
ol_shenzhangjiao:addSkill(olsijun)

ol_shenzhangjiao:addSkill("tytianjie")
--

--神典韦-自改版
onl_shendianwei = sgs.General(extension_o, "onl_shendianwei", "god", 4, true)

onl_shendianwei:addSkill("tyjuanjia")

onlqiexie = sgs.CreateTriggerSkill{
	name = "onlqiexie",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start then return false end
		if not player:hasEquipArea(0) and player:getMark("@tyjuanjia_equiparea") == 0 then return false end
		room:sendCompulsoryTriggerLog(player, self:objectName())
		room:broadcastSkillInvoke(self:objectName())
		local qiexies = {}
		local qiexie = {}
		for _, name in ipairs(sgs.Sanguosha:getLimitedGeneralNames()) do
			table.insert(qiexies, name)
		end
		for _, p in sgs.qlist(room:getAllPlayers(true)) do
			if table.contains(qiexies, p:getGeneralName()) then
				table.removeOne(qiexies, p:getGeneralName())
			end
		end
		for i = 1, 5 do
			local first = qiexies[math.random(1, #qiexies)]
			table.insert(qiexie, first)
			table.removeOne(qiexies, first)
		end
		local n = 2
		if not player:hasEquipArea(0) then n = n - 1 end
		if player:getMark("@tyjuanjia_equiparea") == 0 then n = n - 1 end
		--1.置入装备区
		if n > 0 and player:hasEquipArea(0) then
			local general = room:askForGeneral(player, table.concat(qiexie, "+"))
			table.removeOne(qiexie, general)
			local ggeneral = sgs.Sanguosha:getGeneral(general)
			room:setPlayerProperty(player, "tyqiexie_wparea_record", sgs.QVariant())
			local wqxs = player:property("tyqiexie_wparea_record"):toString():split(",")
			for _, _skill in sgs.qlist(ggeneral:getVisibleSkillList()) do
				if string.find(_skill:getDescription(), "【杀】")
				and not string.find(_skill:getDescription(), "觉醒技，")
				and not string.find(_skill:getDescription(), "限定技，")
				and not string.find(_skill:getDescription(), "转换技，")
				and not string.find(_skill:getDescription(), "主公技，")
				then
					table.insert(wqxs, _skill:objectName())
				end
			end
			room:setPlayerProperty(player, "tyqiexie_wparea_record", sgs.QVariant(table.concat(wqxs, ",")))
			room:setPlayerFlag(player, "tyqiexie_wparea") --识别置入的是装备区还是“捐甲”区
			local mhp = ggeneral:getMaxHp()
			if mhp > 5 then mhp = 5 end
			local cds = sgs.IntList()
			for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
				local wqx = sgs.Sanguosha:getEngineCard(id)
				if mhp == 1 and wqx:isKindOf("WeaponQiexieOne") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXone_ID", sgs.QVariant(id))
				elseif mhp == 2 and wqx:isKindOf("WeaponQiexieTwo") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXtwo_ID", sgs.QVariant(id))
				elseif mhp == 3 and wqx:isKindOf("WeaponQiexieThree") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXthree_ID", sgs.QVariant(id))
				elseif mhp == 4 and wqx:isKindOf("WeaponQiexieFour") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXfour_ID", sgs.QVariant(id))
				elseif mhp == 5 and wqx:isKindOf("WeaponQiexieFive") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXfive_ID", sgs.QVariant(id))
				end
				if not cds:isEmpty() then break end
			end
			if not cds:isEmpty() then
				local cid = cds:first()
				local exchangeMove = sgs.CardsMoveList()
				exchangeMove:append(sgs.CardsMoveStruct(cid, player, sgs.Player_PlaceEquip,
				sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), self:objectName(), "")))
				local card = sgs.Sanguosha:getCard(cid)
				local realEquip = sgs.Sanguosha:getCard(cid):getRealCard():toEquipCard()
				local equip = player:getEquip(realEquip:location())
				if equip then
					exchangeMove:append(sgs.CardsMoveStruct(equip:getEffectiveId(), nil, sgs.Player_DiscardPile,
					sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_CHANGE_EQUIP, player:objectName())))
				end
				room:broadcastSkillInvoke(self:objectName())
				room:moveCardsAtomic(exchangeMove, true)
				--[[for _, m in sgs.list(player:getMarkNames()) do
		        	if string.find(m, "tyqiexie_first") then
	                	room:setPlayerMark(player, m, 0)
					end
				end
				room:setPlayerMark(player, "&tyqiexie_first:" .. sgs.Sanguosha:translate(general))]]
			end
			if player:hasFlag("tyqiexie_wparea") then room:setPlayerFlag(player, "-tyqiexie_wparea") end
			n = n - 1
		end
		--2.置入“捐甲”区
		if n > 0 and player:getMark("@tyjuanjia_equiparea") > 0 then
			local generall = room:askForGeneral(player, table.concat(qiexie, "+"))
			local ggenerall = sgs.Sanguosha:getGeneral(generall)
			room:setPlayerProperty(player, "tyqiexie_jjarea_record", sgs.QVariant())
			local jqxs = player:property("tyqiexie_jjarea_record"):toString():split(",")
			for _, _skill in sgs.qlist(ggenerall:getVisibleSkillList()) do
				if string.find(_skill:getDescription(), "【杀】")
				and not string.find(_skill:getDescription(), "觉醒技，")
				and not string.find(_skill:getDescription(), "限定技，")
				and not string.find(_skill:getDescription(), "转换技，")
				and not string.find(_skill:getDescription(), "主公技，")
				then
					table.insert(jqxs, _skill:objectName())
				end
			end
			room:setPlayerProperty(player, "tyqiexie_jjarea_record", sgs.QVariant(table.concat(jqxs, ",")))
			room:setPlayerFlag(player, "tyqiexie_jjarea") --识别置入的是装备区还是“捐甲”区
			local mhp = ggenerall:getMaxHp()
			if mhp > 5 then mhp = 5 end
			local cds = sgs.IntList()
			local jjea_eq = {}
			for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
				local wqx = sgs.Sanguosha:getEngineCard(id)
				if mhp == 1 and wqx:isKindOf("WeaponQiexieOne") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXone_ID", sgs.QVariant(id))
					table.insert(jjea_eq, wqx:objectName())
				elseif mhp == 2 and wqx:isKindOf("WeaponQiexieTwo") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXtwo_ID", sgs.QVariant(id))
					table.insert(jjea_eq, wqx:objectName())
				elseif mhp == 3 and wqx:isKindOf("WeaponQiexieThree") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXthree_ID", sgs.QVariant(id))
					table.insert(jjea_eq, wqx:objectName())
				elseif mhp == 4 and wqx:isKindOf("WeaponQiexieFour") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXfour_ID", sgs.QVariant(id))
					table.insert(jjea_eq, wqx:objectName())
				elseif mhp == 5 and wqx:isKindOf("WeaponQiexieFive") and room:getCardPlace(id) ~= sgs.Player_DrawPile
				and room:getCardPlace(id) ~= sgs.Player_PlaceHand and room:getCardPlace(id) ~= sgs.Player_PlaceEquip
				and room:getCardPlace(id) ~= sgs.Player_PlaceSpecial then
					cds:append(id)
					--room:setTag("WQXfive_ID", sgs.QVariant(id))
					table.insert(jjea_eq, wqx:objectName())
				end
				if not cds:isEmpty() then break end
			end
			if not cds:isEmpty() then
				room:setPlayerProperty(player, "tyjuanjia_equiparea_record", sgs.QVariant())
				--local jjea_names = player:property("tyjuanjia_equiparea_record"):toString():split(",")
				if player:getPile("tyjuanjia"):length() > 0 then
					local dummy = sgs.Sanguosha:cloneCard("slash")
					dummy:addSubcards(player:getPile("tyjuanjia"))
					room:throwCard(dummy, player, nil)
					dummy:deleteLater()
				end
				room:broadcastSkillInvoke(self:objectName())
				player:addToPile("tyjuanjia", cds)
				--[[for _, _name in pairs(jjea_eq) do
					if not table.contains(jjea_names, _name) then
						table.insert(jjea_names, _name)
					end
				end
				room:setPlayerProperty(player, "tyjuanjia_equiparea_record", sgs.QVariant(table.concat(jjea_names, ",")))]]
				local jqxs = player:property("tyqiexie_jjarea_record"):toString():split(",")
				room:setPlayerProperty(player, "tyqiexie_jjarea_lost_record", sgs.QVariant())
				local jqxs_tolose = player:property("tyqiexie_jjarea_lost_record"):toString():split(",") --用于离开“捐甲”区时找到对应技能
				for _, sk in pairs(jqxs) do
					room:attachSkillToPlayer(player, sk)
					table.insert(jqxs_tolose, sk)
				end
				room:setPlayerProperty(player, "tyqiexie_jjarea_lost_record", sgs.QVariant(table.concat(jqxs_tolose, ",")))
				--[[for _, m in sgs.list(player:getMarkNames()) do
		        	if string.find(m, "tyqiexie_second") then
	                	room:setPlayerMark(player, m, 0)
					end
				end
				room:setPlayerMark(player, "&tyqiexie_second:" .. sgs.Sanguosha:translate(generall))]]
			end
			if player:hasFlag("tyqiexie_jjarea") then room:setPlayerFlag(player, "-tyqiexie_jjarea") end
		end
	end,
}
onl_shendianwei:addSkill(onlqiexie)

onl_shendianwei:addSkill("tycuijue")



--

--==欢乐杀神武将==--
--神关羽
joy_shenguanyu = sgs.General(extension_j, "joy_shenguanyu", "god", 5, true)

joywushen = sgs.CreateOneCardViewAsSkill{
	name = "joywushen",
	response_or_use = true,
	view_filter = function(self, card)
		if card:getSuit() ~= sgs.Card_Heart or card:isEquipped() then return false end
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
joywushenBuffA = sgs.CreateTargetModSkill{
	name = "joywushenBuffA",
	distance_limit_func = function(self, from, card)
		if from:hasSkill("joywushen") and card:isKindOf("Slash") and card:getSuit() == sgs.Card_Heart then
			return 1000
		else
			return 0
		end
	end,
}
joywushenBuffB = sgs.CreateTriggerSkill{
	name = "joywushenBuffB",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.card and damage.card:isKindOf("Slash") and damage.card:getSuit() == sgs.Card_Heart then
			room:sendCompulsoryTriggerLog(player, "joywushen")
			room:broadcastSkillInvoke("joywushen")
			local hurt = damage.damage
			damage.damage = hurt + 1
			data:setValue(damage)
		end
	end,
	can_trigger = function(self, player)
		return player and player:hasSkill("joywushen")
	end,
}
joy_shenguanyu:addSkill(joywushen)
if not sgs.Sanguosha:getSkill("joywushenBuffA") then skills:append(joywushenBuffA) end
if not sgs.Sanguosha:getSkill("joywushenBuffB") then skills:append(joywushenBuffB) end

joywuhun = sgs.CreateTriggerSkill{
	name = "joywuhun",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.from and damage.from:objectName() ~= player:objectName() then
			room:notifySkillInvoked(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			damage.from:gainMark("@joyMY", damage.damage)
		end
	end,
}
joywuhunRevive = sgs.CreateTriggerSkill{
	name = "joywuhunRevive",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.QuitDying, sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.QuitDying then
			local dying = data:toDying()
			if dying.who:objectName() ~= player:objectName() or not player:hasSkill("joywuhun") or player:isDead() then return false end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() or not player:hasSkill("joywuhun") then return false end
		end
		local mx = 0
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			mx = math.max(mx, p:getMark("@joyMY"))
		end
		if mx == 0 then return false end
		local foes = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:getMark("@joyMY") == mx then
				foes:append(p)
			end
		end
		if foes:isEmpty() then return false end
		local foe
		if foes:length() == 1 then
			foe = foes:first()
		else
			foe = room:askForPlayerChosen(player, foes, "joywuhun", "@joywuhun-revenge")
		end
		room:notifySkillInvoked(player, "joywuhun")
		room:broadcastSkillInvoke("joywuhun")
		local judge = sgs.JudgeStruct()
		judge.pattern = "Peach,GodSalvation"
		judge.good = true
		judge.negative = true
		judge.reason = "joywuhun"
		judge.who = foe
		room:judge(judge)
		if judge:isBad() then
			room:loseHp(foe, 5)
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
joy_shenguanyu:addSkill(joywuhun)
if not sgs.Sanguosha:getSkill("joywuhunRevive") then skills:append(joywuhunRevive) end

--神吕蒙
joy_shenlvmeng = sgs.General(extension_j, "joy_shenlvmeng", "god", 3, true)

joyshelie = sgs.CreateTriggerSkill{
	name = "joyshelie",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		local card_ids = room:getNCards(5)
		room:fillAG(card_ids)
		local to_get = sgs.IntList()
		local to_throw = sgs.IntList()
		while not card_ids:isEmpty() do
			local card_id = room:askForAG(player, card_ids, false, self:objectName())
			card_ids:removeOne(card_id)
			to_get:append(card_id)
			local card = sgs.Sanguosha:getCard(card_id)
			local suit = card:getSuit()
			room:takeAG(player, card_id, false)
			local _card_ids = card_ids
			for i = 0, 150 do
				for _, id in sgs.qlist(_card_ids) do
					local c = sgs.Sanguosha:getCard(id)
					if c:getSuit() == suit then
						card_ids:removeOne(id)
						room:takeAG(nil, id, false)
						to_throw:append(id)
					end
				end
			end
		end
		local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		if not to_get:isEmpty() then
			dummy:addSubcards(getCardList(to_get))
			player:obtainCard(dummy)
		end
		dummy:clearSubcards()
		if not to_throw:isEmpty() then
			dummy:addSubcards(getCardList(to_throw))
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), "")
			room:throwCard(dummy, reason, nil)
		end
		dummy:deleteLater()
		room:clearAG()
		
		data:setValue(-1000)
	end,
}
joy_shenlvmeng:addSkill(joyshelie)

function FCToData(self)
	local data = sgs.QVariant()
	if type(self) == "string"
	or type(self) == "boolean"
	or type(self) == "number"
	then data = sgs.QVariant(self)
	elseif self ~= nil then data:setValue(self) end
	return data
end
joygongxin = sgs.CreateTriggerSkill{
	name = "joygongxin",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed, sgs.TargetConfirmed}, --不用考虑【闪】了
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if player:getMark("&joygongxind") > 0 or use.card:isKindOf("SkillCard") then return false end
		if event == sgs.CardUsed then
			if use.from:objectName() ~= player:objectName() or use.to:contains(player) then return false end
			for _, p in sgs.qlist(use.to) do
				room:setPlayerFlag(p, "joygongxinTarget")
			end
		else
			if not use.from or not use.to:contains(player) or use.to:length() ~= 1 then return false end
			room:setPlayerFlag(use.from, "joygongxinTarget")
		end
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if not p:hasFlag("joygongxinTarget") then continue end
			room:setPlayerFlag(p, "-joygongxinTarget")
			if p:isKongcheng() or player:getMark("&joygongxind") > 0 then continue end
			if not room:askForSkillInvoke(player, self:objectName(), FCToData("joygongxinTarget:"..p:objectName())) then continue end
			room:broadcastSkillInvoke(self:objectName())
			local ids = sgs.IntList()
			for _, card in sgs.qlist(p:getHandcards()) do
				if card:isRed() then
					ids:append(card:getEffectiveId())
				end
			end
			local card_id = room:doGongxin(player, p, ids)
			if (card_id == -1) then return end
			local result = room:askForChoice(player, self:objectName(), "get+put")
			player:removeTag("joygongxin")
			if result == "get" then
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
				room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
			else
				player:setFlags("Global_GongxinOperator")
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), nil, self:objectName(), nil)
				room:moveCardTo(sgs.Sanguosha:getCard(card_id), p, nil, sgs.Player_DrawPile, reason, true)
				player:setFlags("-Global_GongxinOperator")
			end
			room:addPlayerMark(player, "&joygongxind")
		end
	end,
}
joygongxinClear = sgs.CreateTriggerSkill{
	name = "joygongxinClear",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then return false end
		for _, p in sgs.qlist(room:getAllPlayers()) do
			room:setPlayerMark(p, "&joygongxind", 0)
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
joy_shenlvmeng:addSkill(joygongxin)
if not sgs.Sanguosha:getSkill("joygongxinClear") then skills:append(joygongxinClear) end


--

--神周瑜
joy_shenzhouyu = sgs.General(extension_j, "joy_shenzhouyu", "god", 4, true)

joyqinyin = sgs.CreateTriggerSkill{
	name = "joyqinyin",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime, sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if player:getPhase() == sgs.Player_Discard and move.from and move.from:objectName() == player:objectName() and not player:hasFlag(self:objectName())
			and bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD then
				room:setPlayerFlag(player, self:objectName())
			end
		elseif event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Discard and player:hasFlag(self:objectName()) then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				local choices = {"l"}
				for _, plr in sgs.qlist(room:getAllPlayers()) do
					if plr:isWounded() then
						table.insert(choices, "r")
						break
					end
				end
				table.insert(choices, "cancel")
				local result = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
				if result == "r" then
					room:broadcastSkillInvoke(self:objectName(), 1)
					for _, p in sgs.qlist(room:getAllPlayers()) do
						room:recover(p, sgs.RecoverStruct(player))
					end
				elseif result == "l" then
					room:broadcastSkillInvoke(self:objectName(), 2)
					for _, q in sgs.qlist(room:getAllPlayers()) do
						room:loseHp(q, 1)
					end
				end
			end
		end
	end,
}
joy_shenzhouyu:addSkill(joyqinyin)

joyyeyan = sgs.CreateTriggerSkill{
	name = "joyyeyan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				local cmd = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:damage(sgs.DamageStruct(self:objectName(), player, cmd, 1, sgs.DamageStruct_Fire))
			end
		end
	end,
}
joy_shenzhouyu:addSkill(joyyeyan)

--神诸葛亮
joy_shenzhugeliang = sgs.General(extension_j, "joy_shenzhugeliang", "god", 3, true)

joy_shenzhugeliang:addSkill("qixing")

joykuangfengCard = sgs.CreateSkillCard{
	name = "joykuangfengCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return #targets < self:subcardsLength()
	end,
	on_use = function(self, room, source, targets)
		for _, p in ipairs(targets) do
			room:damage(sgs.DamageStruct("joykuangfeng", source, p))
		end
	end,
}
joykuangfengVS = sgs.CreateViewAsSkill{
	name = "joykuangfeng", 
	n = 999,
	expand_pile = "stars",
	view_filter = function(self, selected, to_select)
		return sgs.Self:getPile("stars"):contains(to_select:getId())
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local jkf = joykuangfengCard:clone()
			for _, card in pairs(cards) do
				jkf:addSubcard(card)
			end
			return jkf
		end
		
		return nil
	end,
	response_pattern = "@@joykuangfeng",
}
joykuangfeng = sgs.CreateTriggerSkill{
	name = "joykuangfeng",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseEnd},
	view_as_skill = joykuangfengVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play then
			if player:getPile("stars"):length() > 0 then
				room:askForUseCard(player, "@@joykuangfeng", "@joykuangfeng-card", -1, sgs.Card_MethodNone)
			end
		end
	end,
}
joy_shenzhugeliang:addSkill(joykuangfeng)

joydawuCard = sgs.CreateSkillCard{
	name = "joydawuCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		source:gainMark("@joydawu", 1)
	end,
}
joydawuVS = sgs.CreateOneCardViewAsSkill{
	name = "joydawu", 
	filter_pattern = ".|.|.|stars",
	expand_pile = "stars",
	view_as = function(self, card)
		local jdw = joydawuCard:clone()
		jdw:addSubcard(card)
		return jdw
	end,
	response_pattern = "@@joydawu",
}
joydawu = sgs.CreateTriggerSkill{
	name = "joydawu",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseProceeding, sgs.DamageInflicted, sgs.EventPhaseStart},
	view_as_skill = joydawuVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseProceeding then
			local phase = player:getPhase()
			if phase ~= sgs.Player_Finish then return false end
			if player:hasSkill(self:objectName()) and player:getPile("stars"):length() > 0 and player:getMark("@joydawu") == 0 then
				room:askForUseCard(player, "@@joydawu", "@joydawu-card", -1, sgs.Card_MethodNone)
			end
		elseif event == sgs.DamageInflicted then
			local damage = data:toDamage()
			if damage.to and damage.to:objectName() == player:objectName() and player:getMark("@joydawu") > 0
			and damage.nature == sgs.DamageStruct_Normal then
				local damagedown = damage.damage - 1
				local log = sgs.LogMessage()
				log.type = "$joydawu_dmgdown"
				log.from = player
				log.arg = damage.damage
				log.arg2 = damagedown
				room:sendLog(log)
				room:broadcastSkillInvoke(self:objectName())
				damage.damage = damagedown
				data:setValue(damage)
				if damage.damage < 1 then
					return true
				end
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart and player:getMark("@joydawu") > 0 then
				player:loseAllMarks("@joydawu")
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
joy_shenzhugeliang:addSkill(joydawu)




-----------
--神孙权
joy_shensunquan = sgs.General(extension_j, "joy_shensunquan", "god", 4, true)

joyquanxueCard = sgs.CreateSkillCard{
    name = "joyquanxueCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
	    return #targets < 2 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
	    for _, lm in pairs(targets) do
			lm:gainMark("&jStudy")
		end
	end,
}
joyquanxueVS = sgs.CreateZeroCardViewAsSkill{
    name = "joyquanxue",
    view_as = function()
		return joyquanxueCard:clone()
	end,
	response_pattern = "@@joyquanxue",
}
joyquanxue = sgs.CreateTriggerSkill{
    name = "joyquanxue",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = joyquanxueVS,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play and room:askForSkillInvoke(player, self:objectName(), data) then
		    if not room:askForUseCard(player, "@@joyquanxue", "@joyquanxue-card") then
				if player:getState() == "robot" then --AI部分（仅斗地主模式生效）
					local can_invoke = false
					for _, p in sgs.qlist(room:getAllPlayers()) do --寻找地主
						if p:hasSkill("bahu") then
							can_invoke = true
							break
						end
					end
					if can_invoke then
						room:broadcastSkillInvoke(self:objectName())
						if player:hasSkill("bahu") then --是地主，给所有农民上标记；是农民，给地主上标记
							for _, p in sgs.qlist(room:getOtherPlayers(player)) do
								p:gainMark("&jStudy")
							end
						else
							for _, p in sgs.qlist(room:getOtherPlayers(player)) do
								if p:hasSkill("bahu") then
									p:gainMark("&jStudy")
								end
							end
						end
					end
				end
			end
		end
	end,
}
joyquanxueDeBuff = sgs.CreateTriggerSkill{
    name = "joyquanxueDeBuff",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd},
	view_as_skill = joydingliSK, --联动“鼎立”
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart and player:getMark("&jStudy") > 0 then
		    	player:loseMark("&jStudy")
				for _, jssq in sgs.qlist(room:findPlayersBySkillName("joydingli")) do
					if jssq:getMark("joydingliUsed_lun") == 0 then
						local x = jssq:getHp()
						local y = player:getHp()
						if x <= y then
							room:setPlayerFlag(jssq, "joydingliRecover")
							room:askForUseCard(jssq, "@@joydingliSK", "@joydingliSK-card")
						else
							local z = x - y
							room:addPlayerMark(jssq, "joydingliDraw", z)
							room:setPlayerFlag(jssq, "joydingliDraw")
							room:askForUseCard(jssq, "@@joydingliSK", "@joydingliSK-card")
						end
					end
				end
				local choice = room:askForChoice(player, "joyquanxue", "1+2")
				if choice == "1" then
					room:broadcastSkillInvoke("joyquanxue")
					room:setPlayerFlag(player, "joyquanxueLimitedKey")
				else
					room:broadcastSkillInvoke("joyquanxue")
					room:loseHp(player, 1)
				end
			elseif player:getPhase() == sgs.Player_Play and player:hasFlag("joyquanxueLimitedKey") then
				room:acquireSkill(player, "joyquanxueDeBuff_CardLimited")
			end
		elseif event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Play and player:hasFlag("joyquanxueLimitedKey") then
			room:setPlayerFlag(player, "-joyquanxueLimitedKey")
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:hasSkill("joyquanxueDeBuff_CardLimited") then
					room:detachSkillFromPlayer(p, "joyquanxueDeBuff_CardLimited", false, true)
				end
			end
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
joyquanxueDeBuff_CardLimited = sgs.CreateProhibitSkill{
	name = "joyquanxueDeBuff_CardLimited&",
	is_prohibited = function(self, from, to, card)
		for _, p in sgs.qlist(from:getAliveSiblings()) do
			if from:hasSkill(self:objectName()) and from:hasFlag("joyquanxueLimitedKey")
			and to:objectName() ~= from:objectName() and not card:isKindOf("SkillCard") then
				return true
			end
		end
		return false
	end,
}
joy_shensunquan:addSkill(joyquanxue)
if not sgs.Sanguosha:getSkill("joyquanxueDeBuff") then skills:append(joyquanxueDeBuff) end
if not sgs.Sanguosha:getSkill("joyquanxueDeBuff_CardLimited") then skills:append(joyquanxueDeBuff_CardLimited) end

joyshehu = sgs.CreateTriggerSkill{
    name = "joyshehu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			for _, p in sgs.qlist(use.to) do
		        local _data = sgs.QVariant()
				_data:setValue(p)
				if not p:isKongcheng() and p:getMark("&jStudy") > 0 then
		    		local id = room:askForCardChosen(player, p, "h", self:objectName())
					room:throwCard(id, p, player)
				end
			end
		end
	end,
}
joy_shensunquan:addSkill(joyshehu)

joydingliSKCard = sgs.CreateSkillCard{ --“鼎立”技能卡
    name = "joydingliSKCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
	    room:broadcastSkillInvoke("joydingli")
		if source:hasFlag("joydingliRecover") then
			local recover = sgs.RecoverStruct()
			recover.who = source
			room:recover(source, recover)
			room:setPlayerFlag(source, "-joydingliRecover")
		elseif source:hasFlag("joydingliDraw") then
			local n = source:getMark("joydingliDraw")
			if n > 2 then n = 2 end
			room:drawCards(source, n, "joydingli")
			room:removePlayerMark(source, "joydingliDraw", n)
			room:setPlayerFlag(source, "-joydingliDraw")
		end
		room:addPlayerMark(source, "joydingliUsed_lun")
	end,
}
joydingliSK = sgs.CreateZeroCardViewAsSkill{
    name = "joydingliSK",
    view_as = function()
		return joydingliSKCard:clone()
	end,
	response_pattern = "@@joydingliSK",
}
if not sgs.Sanguosha:getSkill("joydingliSK") then skills:append(joydingliSK) end
joydingli = sgs.CreateTriggerSkill{
	name = "joydingli",
	frequency = sgs.Skill_Frequent,
	events = {sgs.RoundStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getMark("joydingliUsed_lun") > 0 then
			room:removePlayerMark(player, "joydingliUsed_lun")
		end
	end,
}
joy_shensunquan:addSkill(joydingli)
--

--神张辽
joy_shenzhangliao = sgs.General(extension_j, "joy_shenzhangliao", "god", 4, true)

joyduorui = sgs.CreateTriggerSkill{
	name = "joyduorui",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart, sgs.TargetSpecified},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Play and room:askForSkillInvoke(player, self:objectName(), data) then
			local targets = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if not p:isKongcheng() then
					targets:append(p)
				end
			end
			local sunquan = room:askForPlayerChosen(player, targets, self:objectName(), "joyduorui-invoke", true, true)
			room:broadcastSkillInvoke(self:objectName())
			local ids = sgs.IntList()
			for _, card in sgs.qlist(sunquan:getHandcards()) do
				ids:append(card:getEffectiveId())
			end
			local card_id = room:doGongxin(player, sunquan, ids)
			if (card_id == -1) then return end
			if sgs.Sanguosha:getCard(card_id):isRed() then
				room:setPlayerFlag(player, "joyduoruiRED")
			elseif sgs.Sanguosha:getCard(card_id):isBlack() then
				room:setPlayerFlag(player, "joyduoruiBLACK")
			end
			room:setPlayerFlag(sunquan, "joyduoruiTarget")
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
			room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
			room:broadcastSkillInvoke(self:objectName())
		elseif event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.card and use.from:objectName() == player:objectName() then
				if player:hasFlag("joyduoruiRED") and use.card:isRed() then
					local no_respond_list = use.no_respond_list
					for _, p in sgs.qlist(use.to) do
				    	if p:hasFlag("joyduoruiTarget") then
							room:sendCompulsoryTriggerLog(player, self:objectName())
							room:broadcastSkillInvoke(self:objectName())
							table.insert(no_respond_list, p:objectName())
						end
					end
					use.no_respond_list = no_respond_list
					data:setValue(use)
					
				elseif player:hasFlag("joyduoruiBLACK") and use.card:isBlack() then
					local no_respond_list = use.no_respond_list
					for _, p in sgs.qlist(use.to) do
				    	if p:hasFlag("joyduoruiTarget") then
							room:sendCompulsoryTriggerLog(player, self:objectName())
							room:broadcastSkillInvoke(self:objectName())
							table.insert(no_respond_list, p:objectName())
						end
					end
					use.no_respond_list = no_respond_list
					data:setValue(use)
				end
			end
		end
	end,
}
joy_shenzhangliao:addSkill(joyduorui)

joyzhiti = sgs.CreateTriggerSkill{
	name = "joyzhiti",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local n = 0
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:isWounded() then
				n = n + 1
			end
		end
		if n > 1 then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			local count = data:toInt() + 1
			data:setValue(count)
		end
	end,
}
joyzhitiX = sgs.CreateTargetModSkill{
    name = "joyzhitiX",
	pattern = "Slash",
	frequency = sgs.Skill_Compulsory,
	residue_func = function(self, from)
		local n = 0
		if from:hasSkill("joyzhiti") then
			local m = 0
			for _, p in sgs.qlist(from:getAliveSiblings()) do
				if p:isWounded() then
					m = m + 1
				end
			end
			if from:isWounded() then m = m + 1 end
			if m > 2 then
				return n + 1
			end
		end
		return n
	end,
}
joy_shenzhangliao:addSkill(joyzhiti)
if not sgs.Sanguosha:getSkill("joyzhitiX") then skills:append(joyzhitiX) end

--神典韦
joy_shendianwei = sgs.General(extension_j, "joy_shendianwei", "god", 5, true)

joyshenweiCard = sgs.CreateSkillCard{
    name = "joyshenweiCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		if sgs.Self:getHp() == 1 then
			return #targets < 2 and to_select:getMark("&joyWEI") == 0
		else
			return #targets == 0 and to_select:getMark("&joyWEI") == 0
		end
	end,
	on_use = function(self, room, source, targets)
		for _, cc in pairs(targets) do
			cc:gainMark("&joyWEI")
		end
		room:addPlayerMark(source, "joy_shendianwei")
	end,
}
joyshenweiVS = sgs.CreateZeroCardViewAsSkill{
    name = "joyshenwei",
    view_as = function()
		return joyshenweiCard:clone()
	end,
	response_pattern = "@@joyshenwei",
}
joyshenwei = sgs.CreateTriggerSkill{
    name = "joyshenwei",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = joyshenweiVS,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() == sgs.Player_RoundStart and room:askForSkillInvoke(player, self:objectName(), data) then
		    if not room:askForUseCard(player, "@@joyshenwei", "@joyshenwei-card") then
				if player:getState() == "robot" then --AI部分
					--[[if player:getRole() == "rebel" or player:getRole() == "loyalist" then
						for _, friend in sgs.qlist(room:getOtherPlayers(player)) do --反贼/农民给队友套盾，忠臣给主公套盾（但不适用于3v3模式，冷方小弟不会给主将套盾）
							if ((friend:getRole() == "rebel" and player:getRole() == "rebel") or (friend:getRole() == "lord" and player:getRole() == "loyalist"))
							and firend:getMark("&joyWEI") == 0 and not player:hasFlag("joyWEIgived") then
								friend:gainMark("&joyWEI")
								room:addPlayerMark(player, "joy_shendianwei")
								room:setPlayerFlag(player, "joyWEIgived")
							end
						end
						if not player:hasFlag("joyWEIgived") and player:getRole() == "loyalist" then
							for _, friend in sgs.qlist(room:getOtherPlayers(player)) do --2v2忠臣给队友套盾
								if firend:getMark("&joyWEI") == 0 and friend:getRole() == "loyalist" and not player:hasFlag("joyWEIgived") then
									friend:gainMark("&joyWEI")
									room:addPlayerMark(player, "joy_shendianwei")
									room:setPlayerFlag(player, "joyWEIgived")
								end
							end
						end
					else
						if not player:hasFlag("joyWEIgived") then
							player:gainMark("&joyWEI") --主公/地主无脑给自己套盾，内奸直接明内打法（但适用于3v3模式）
							room:addPlayerMark(player, "joy_shendianwei")
							room:setPlayerFlag(player, "joyWEIgived")
						end
					end]]
					--if not player:hasFlag("joyWEIgived") then --皆不满足上述要求，就给自己套盾
						if player:getMark("&joyWEI") == 0 then
							player:gainMark("&joyWEI")
							room:addPlayerMark(player, "joy_shendianwei")
						end
					--end
					room:broadcastSkillInvoke(self:objectName())
					--room:setPlayerFlag(player, "-joyWEIgived")
				end
			end
		end
	end,
}
joyshenweiMoveDamage = sgs.CreateTriggerSkill{
	name = "joyshenweiMoveDamage",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if room:askForSkillInvoke(player, "@joyshenweiMoveDamage", data) then
			for _, jsdw in sgs.qlist(room:getAllPlayers()) do
				if jsdw:getMark("joy_shendianwei") > 0 then
					room:removePlayerMark(jsdw, "joy_shendianwei")
					player:loseMark("&joyWEI")
					damage.to = jsdw
					damage.transfer = true
					room:damage(damage)
					break
				end
			end
			return true
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&joyWEI") > 0
	end,
}
joy_shendianwei:addSkill(joyshenwei)
if not sgs.Sanguosha:getSkill("joyshenweiMoveDamage") then skills:append(joyshenweiMoveDamage) end

joyelai = sgs.CreateTriggerSkill{
	name = "joyelai",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.MarkChanged}, --标记（数量）变动时
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local mark = data:toMark()
		if mark.name == "&joyWEI" and mark.who and mark.who:getMark("&joyWEI") == 0 then --之所以直接这样写是每名角色“卫”标记至多1枚
			for _, jsdw in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				local choice = room:askForChoice(jsdw, self:objectName(), "1+2")
				if choice == "1" then
					room:broadcastSkillInvoke(self:objectName())
					room:recover(jsdw, sgs.RecoverStruct(jsdw))
				elseif choice == "2" then
					local ZXJ = sgs.SPlayerList()
					for _, z in sgs.qlist(room:getAllPlayers()) do
						if jsdw:inMyAttackRange(z) then
							ZXJ:append(z)
						end
					end
					local hucheer = room:askForPlayerChosen(jsdw, ZXJ, self:objectName(), "joyelai_damage")
					room:broadcastSkillInvoke(self:objectName())
					room:damage(sgs.DamageStruct(self:objectName(), jsdw, hucheer, 1, sgs.DamageStruct_Normal))
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
joy_shendianwei:addSkill(joyelai)

joykuangxi = sgs.CreateTriggerSkill{
	name = "joykuangxi",
	priority = -1,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageCaused}, --events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local can_invoke = false
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:getMark("&joyWEI") > 0 then can_invoke = true break end
		end
		if can_invoke then
			local log = sgs.LogMessage()
			log.type = "$joykuangxi_MoreDamage"
			log.from = player
			room:sendLog(log)
			local zhangxiusima = damage.damage
			damage.damage = zhangxiusima + 1
			data:setValue(damage)
			room:broadcastSkillInvoke(self:objectName())
		end
	end,
}
joy_shendianwei:addSkill(joykuangxi)





--

--神华佗
joy_shenhuatuo = sgs.General(extension_j, "joy_shenhuatuo", "god", 1, true)

joyjishi = sgs.CreateTriggerSkill{
	name = "joyjishi",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.GameStart, sgs.EnterDying, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:hasSkill(self:objectName()) then
				room:broadcastSkillInvoke(self:objectName())
				player:gainMark("&joyMedicine", 3)
				room:setPlayerMark(player, "&joyMedicine", 3)
			end
		elseif event == sgs.EnterDying then
			for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if p:getMark("&joyMedicine") == 0 then continue end
				if not room:askForSkillInvoke(p, self:objectName(), data) then continue end
				room:broadcastSkillInvoke(self:objectName())
				p:loseMark("&joyMedicine")
				local maxhp = player:getMaxHp()
				local recover = math.min(1 - player:getHp(), maxhp - player:getHp()) --local hp = math.min(1, maxhp)
				room:recover(player, sgs.RecoverStruct(player, nil, recover)) --room:setPlayerProperty(player, "hp", sgs.QVariant(hp))
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if (move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceHand) and player:hasSkill(self:objectName()) and player:getPhase() == sgs.Player_NotActive)
			and not (move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceHand) then
				local n = 0
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if card:isRed() then
						n = n + 1
					end
				end
				if n > 0 and player:getMark("&joyMedicine") < 3 then
					local m = player:getMark("&joyMedicine")
					if m + n <= 3 then
						player:gainMark("&joyMedicine", n)
					else
						player:gainMark("&joyMedicine", 3-m)
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
joyjishi_MaxCards = sgs.CreateMaxCardsSkill{
	name = "joyjishi_MaxCards",
	extra_func = function(self, player)
		if player:hasSkill("joyjishi") then
			return 3
		else
			return 0
		end
	end,
}
joy_shenhuatuo:addSkill(joyjishi)
if not sgs.Sanguosha:getSkill("joyjishi_MaxCards") then skills:append(joyjishi_MaxCards) end

joytaoxian = sgs.CreateViewAsSkill{
	name = "joytaoxian",
	n = 1,
	view_filter = function(self, selected, to_select)
		if #selected == 0 then
			return to_select:getSuit() == sgs.Card_Heart
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local id = card:getId()
			local peach = sgs.Sanguosha:cloneCard("peach", suit, point)
			peach:setSkillName(self:objectName())
			peach:addSubcard(id)
			return peach
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return player:isWounded() and player:getMark("Global_PreventPeach") == 0
	end,
	enabled_at_response = function(self, player, pattern)
		return string.find(pattern, "peach")
	end,
}
joytaoxianDraw = sgs.CreateTriggerSkill{
	name = "joytaoxianDraw",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Peach") and use.from:objectName() == player:objectName() then
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:hasSkill("joytaoxian") then
					room:sendCompulsoryTriggerLog(p, "joytaoxian")
					room:broadcastSkillInvoke("joytaoxian")
					room:drawCards(p, 1, "joytaoxian")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
joy_shenhuatuo:addSkill(joytaoxian)
if not sgs.Sanguosha:getSkill("joytaoxianDraw") then skills:append(joytaoxianDraw) end

joyshenzhenCard = sgs.CreateSkillCard{
    name = "joyshenzhenCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets < sgs.Self:getMark("&joyMedicine")
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		local n = 0
		for _, p in pairs(targets) do
		    if p then
			n = n + 1 end
		end
		source:loseMark("&joyMedicine", n)
		local choice = room:askForChoice(source, "joyshenzhen", "1+2")
		if choice == "1" then
			for _, p in pairs(targets) do
				room:recover(p, sgs.RecoverStruct(source)) --“女巫的解药”（毕竟神针是神华佗的）
			end
		else
			for _, p in pairs(targets) do
		    	room:loseHp(p, 1) --“女巫的毒药”
			end
		end
	end,
}
joyshenzhenVS = sgs.CreateZeroCardViewAsSkill{
    name = "joyshenzhen",
    view_as = function()
		return joyshenzhenCard:clone()
	end,
	response_pattern = "@@joyshenzhen",
}
joyshenzhen = sgs.CreateTriggerSkill{
	name = "joyshenzhen",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = joyshenzhenVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_RoundStart and player:getMark("&joyMedicine") > 0 then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:askForUseCard(player, "@@joyshenzhen", "@joyshenzhen-card")
			end
		end
	end,
}
joy_shenhuatuo:addSkill(joyshenzhen)

--神貂蝉
joy_shendiaochan = sgs.General(extension_j, "joy_shendiaochan", "god", 3, false)

joymeihun = sgs.CreateTriggerSkill{
	name = "joymeihun",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseChanging, sgs.TargetConfirmed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:hasFlag(self:objectName()) then room:setPlayerFlag(p, "-joymeihun") end
				end
			end
			if change.to ~= sgs.Player_Finish then
				return false
			end
		end
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash") or not use.to:contains(player) or player:hasFlag(self:objectName()) then return false end
			room:setPlayerFlag(player, self:objectName())
		end
		if player:hasSkill(self:objectName()) and room:askForSkillInvoke(player, self:objectName(), data) then
			local suit = room:askForSuit(player, self:objectName())
			local log = sgs.LogMessage()
			if suit == sgs.Card_Heart then log.type = "$joymeihun_heart"
			elseif suit == sgs.Card_Diamond then log.type = "$joymeihun_diamond"
			elseif suit == sgs.Card_Club then log.type = "$joymeihun_club"
			elseif suit == sgs.Card_Spade then log.type = "$joymeihun_spade" end
			log.from = player
			room:sendLog(log)
			local MH = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if not p:isNude() then
					MH:append(p)
				end
			end
			if MH:length() == 0 then return false end
			local MHto
			if MH:length() > 1 then MHto = room:askForPlayerChosen(player, MH, self:objectName())
			elseif MH:length() == 1 then
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if not p:isNude() then
						MHto = p
						break
					end
				end
			end
			room:broadcastSkillInvoke(self:objectName())
			local dummy_card = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, cd in sgs.qlist(MHto:getCards("he")) do
				if cd:getSuit() == suit then
					dummy_card:addSubcard(cd)
				end
			end
			if dummy_card:subcardsLength() > 0 then
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, player:objectName(), MHto:objectName(), self:objectName(), nil)
				room:moveCardTo(dummy_card, MHto, player, sgs.Player_PlaceHand, reason, false)
			else
				if not MHto:isKongcheng() then
					local ids = sgs.IntList()
					for _, card in sgs.qlist(MHto:getHandcards()) do
						ids:append(card:getEffectiveId())
					end
					local card_id = room:doGongxin(player, MHto, ids)
					if (card_id == -1) then return end
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
					room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
joy_shendiaochan:addSkill(joymeihun)

joyhuoxinCard = sgs.CreateSkillCard{
    name = "joyhuoxinCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return #targets < 2 and not to_select:isKongcheng()
	end,
	feasible = function(self, targets)
		return #targets == 2
	end,
	on_use = function(self, room, source, targets)
		room:setPlayerFlag(source, "joyhuoxinPDF") --后续拼点结算通过此标志找到神貂蝉
		targets[1]:pindian(targets[2], "joyhuoxin", nil)
	end,
}
joyhuoxin = sgs.CreateOneCardViewAsSkill{
    name = "joyhuoxin",
	filter_pattern =  ".",
	view_as = function(self, card)
		local jhx_card = joyhuoxinCard:clone()
		jhx_card:addSubcard(card)
		return jhx_card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#joyhuoxinCard") and not player:isNude()
	end,
}
joyhuoxinMH = sgs.CreateTriggerSkill{
    name = "joyhuoxinMH",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.Pindian, sgs.MarkChanged, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.Pindian then
			local pindian = data:toPindian()
			if pindian.reason == "joyhuoxin" then
				local jsdc
				for _, p in sgs.qlist(room:getAllPlayers()) do --找到神貂蝉
					if p:hasFlag("joyhuoxinPDF") then
						room:setPlayerFlag(p, "-joyhuoxinPDF")
						jsdc = p
						break
					end
				end
				local suit = room:askForSuit(jsdc, "joyhuoxin")
				local log = sgs.LogMessage()
				if suit == sgs.Card_Heart then log.type = "$joymeihun_heart"
				elseif suit == sgs.Card_Diamond then log.type = "$joymeihun_diamond"
				elseif suit == sgs.Card_Club then log.type = "$joymeihun_club"
				elseif suit == sgs.Card_Spade then log.type = "$joymeihun_spade" end
				log.from = jsdc
				room:sendLog(log)
				local fromNumber = pindian.from_card:getNumber()
				local toNumber = pindian.to_card:getNumber()
				local losers = sgs.SPlayerList()
				if fromNumber ~= toNumber then
					local winner
					local loser
					if fromNumber > toNumber then
						winner = pindian.from
						loser = pindian.to
					else
						winner = pindian.to
						loser = pindian.from
					end
					losers:append(loser)
				else
					losers:append(pindian.from)
					losers:append(pindian.to)
				end
				for _, lsr in sgs.qlist(losers) do
					local dummy_card = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					for _, cd in sgs.qlist(lsr:getCards("he")) do
						if cd:getSuit() == suit then
							dummy_card:addSubcard(cd)
						end
					end
					local choices = {}
					if dummy_card:subcardsLength() > 0 then
						if suit == sgs.Card_Heart then
							table.insert(choices, "gh=" .. jsdc:objectName())
						elseif suit == sgs.Card_Diamond then
							table.insert(choices, "gd=" .. jsdc:objectName())
						elseif suit == sgs.Card_Club then
							table.insert(choices, "gc=" .. jsdc:objectName())
						elseif suit == sgs.Card_Spade then
							table.insert(choices, "gs=" .. jsdc:objectName())
						end
					end
					if suit == sgs.Card_Heart then
						table.insert(choices, "lh")
					elseif suit == sgs.Card_Diamond then
						table.insert(choices, "ld")
					elseif suit == sgs.Card_Club then
						table.insert(choices, "lc")
					elseif suit == sgs.Card_Spade then
						table.insert(choices, "ls")
					end
					local choice = room:askForChoice(lsr, "joyhuoxin", table.concat(choices, "+"))
					room:broadcastSkillInvoke("joyhuoxin")
					if choice == "gh=" .. jsdc:objectName() or choice == "gd=" .. jsdc:objectName() or choice == "gc=" .. jsdc:objectName() or choice == "gs=" .. jsdc:objectName() then
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, jsdc:objectName(), lsr:objectName(), "joyhuoxin", nil)
						room:moveCardTo(dummy_card, lsr, jsdc, sgs.Player_PlaceHand, reason, false)
					end
					if choice == "lh" then
						lsr:gainMark("&joyMeiHuo+heart")
					end
					if choice == "ld" then
						lsr:gainMark("&joyMeiHuo+diamond")
					end
					if choice == "lc" then
						lsr:gainMark("&joyMeiHuo+club")
					end
					if choice == "ls" then
						lsr:gainMark("&joyMeiHuo+spade")
					end
				end
			end
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			if (mark.name == "&joyMeiHuo+heart" or mark.name == "&joyMeiHuo+diamond" or mark.name == "&joyMeiHuo+club" or mark.name == "&joyMeiHuo+spade") and mark.who:objectName() == player:objectName() then
				if mark.gain > 0 then --获得标记，封牌
					if mark.name == "&joyMeiHuo+heart" then
						room:setPlayerCardLimitation(player, "use,response", ".|heart|.|.", false)
					elseif mark.name == "&joyMeiHuo+diamond" then
						room:setPlayerCardLimitation(player, "use,response", ".|diamond|.|.", false)
					elseif mark.name == "&joyMeiHuo+club" then
						room:setPlayerCardLimitation(player, "use,response", ".|club|.|.", false)
					elseif mark.name == "&joyMeiHuo+spade" then
						room:setPlayerCardLimitation(player, "use,response", ".|spade|.|.", false)
					end
				elseif mark.gain < 0 then --移去标记，解封
					if mark.name == "&joyMeiHuo+heart" then
						room:removePlayerCardLimitation(player, "use,response", ".|heart|.|.")
					elseif mark.name == "&joyMeiHuo+diamond" then
						room:removePlayerCardLimitation(player, "use,response", ".|diamond|.|.")
					elseif mark.name == "&joyMeiHuo+club" then
						room:removePlayerCardLimitation(player, "use,response", ".|club|.|.")
					elseif mark.name == "&joyMeiHuo+spade" then
						room:removePlayerCardLimitation(player, "use,response", ".|spade|.|.")
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			if player:getMark("&joyMeiHuo+heart") > 0 then room:setPlayerMark(player, "&joyMeiHuo+heart", 0) end
			if player:getMark("&joyMeiHuo+diamond") > 0 then room:setPlayerMark(player, "&joyMeiHuo+diamond", 0) end
			if player:getMark("&joyMeiHuo+club") > 0 then room:setPlayerMark(player, "&joyMeiHuo+club", 0) end
			if player:getMark("&joyMeiHuo+spade") > 0 then room:setPlayerMark(player, "&joyMeiHuo+spade", 0) end
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
joy_shendiaochan:addSkill(joyhuoxin)
if not sgs.Sanguosha:getSkill("joyhuoxinMH") then skills:append(joyhuoxinMH) end

--神-大乔&小乔
joy_shenerqiao = sgs.General(extension_j, "joy_shenerqiao", "god", 4, false)

joyshuangshu = sgs.CreateTriggerSkill{
	name = "joyshuangshu",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase ~= sgs.Player_Start then return false end
		if room:askForSkillInvoke(player, self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName())
			local card_ids = room:getNCards(2)
			room:fillAG(card_ids)
			room:getThread():delay()
			local n = 0
			for _, id in sgs.qlist(card_ids) do
				local card = sgs.Sanguosha:getCard(id)
				if card:isRed() then
					if card:getSuit() == sgs.Card_Diamond and not player:hasFlag("joypinting") then
						local log = sgs.LogMessage()
						log.type = "$joy_shuangshu_pinting"
						log.from = player
						room:sendLog(log)
						room:setPlayerFlag(player, "joypinting")
					elseif card:getSuit() == sgs.Card_Heart and not player:hasFlag("joyyizheng") then
						local log = sgs.LogMessage()
						log.type = "$joy_shuangshu_yizheng"
						log.from = player
						room:sendLog(log)
						room:setPlayerFlag(player, "joyyizheng")
					end
				else
					n = n + 1
				end
			end
			if n == 2 then
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, id in sgs.qlist(card_ids) do
					dummy:addSubcard(id)
				end
				room:obtainCard(player, dummy)
				dummy:deleteLater()
			end
			room:clearAG()
		end
	end,
}
joy_shenerqiao:addSkill(joyshuangshu)

joypinting = sgs.CreateTriggerSkill{
	name = "joypinting",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName())
				local choices = {"1", "2", "3", "4"}
				local n = 2
				if player:hasFlag(self:objectName()) then n = n + 1 end
				while n > 0 do
					local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
					if choice == "cancel" then break end
					if choice == "1" then
						room:setPlayerMark(player, "joypintingFCU", 1)
						table.removeOne(choices, "1")
					elseif choice == "2" then
						room:setPlayerMark(player, "joypintingSCU", 2)
						table.removeOne(choices, "2")
					elseif choice == "3" then
						room:setPlayerMark(player, "joypintingTCU", 3)
						table.removeOne(choices, "3")
					elseif choice == "4" then
						room:setPlayerMark(player, "joypintingFTCU", 4)
						table.removeOne(choices, "4")
					end
					n = n - 1
					if player:hasFlag(self:objectName()) and n == 1 then
						table.insert(choices, "cancel")
					end
				end
			end
		end
	end,
}
joypintings = sgs.CreateTriggerSkill{
	name = "joypintings",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.CardResponded, sgs.CardFinished, sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed or event == sgs.CardResponded then
			local card = nil
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and card:getHandlingMethod() == sgs.Card_MethodUse and not card:isKindOf("SkillCard") then
				if player:getMark("joypintingFCU") > 0 then
					room:removePlayerMark(player, "joypintingFCU")
				end
				if player:getMark("joypintingSCU") > 0 then
					room:removePlayerMark(player, "joypintingSCU")
					if player:getMark("joypintingSCU") == 0 then
						if player:hasSkill("joypinting") then room:sendCompulsoryTriggerLog(player, "joypinting") end
						room:broadcastSkillInvoke("joypinting")
						if not (card:isVirtualCard() and card:getSubcards():length() == 0) then
							room:obtainCard(player, card)
						end
					end
				end
				if player:getMark("joypintingTCU") > 0 then
					room:removePlayerMark(player, "joypintingTCU")
					if player:getMark("joypintingTCU") == 0 then
						room:setPlayerFlag(player, "joypintingTCU")
					end
				end
				if player:getMark("joypintingFTCU") > 0 then
					room:removePlayerMark(player, "joypintingFTCU")
					if player:getMark("joypintingFTCU") == 0 then
						room:setPlayerFlag(player, "joypintingFTCU")
					end
				end
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.card and not use.card:isKindOf("SkillCard") and use.from:objectName() == player:objectName() then
				if player:hasFlag("joypintingTCU") then
					room:setPlayerFlag(player, "-joypintingTCU")
					if player:hasSkill("joypinting") then room:sendCompulsoryTriggerLog(player, "joypinting") end
					room:broadcastSkillInvoke("joypinting")
					room:drawCards(player, 2, "joypinting")
				end
				if player:hasFlag("joypintingFTCU") then
					room:setPlayerFlag(player, "-joypintingFTCU")
					if player:hasSkill("joypinting") then room:sendCompulsoryTriggerLog(player, "joypinting") end
					room:broadcastSkillInvoke("joypinting")
					local can_useagain = false
					for _, p in sgs.qlist(use.to) do
						if not player:isProhibited(p, use.card) then
						can_useagain = true end
					end
					if can_useagain then
						use.card:cardOnUse(room, use)
					end
				end
			end
		elseif event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Play then
			room:setPlayerMark(player, "joypintingFCU", 0)
			room:setPlayerMark(player, "joypintingSCU", 0)
			room:setPlayerMark(player, "joypintingTCU", 0)
			room:setPlayerMark(player, "joypintingFTCU", 0)
			if player:hasFlag("joypintingTCU") then room:setPlayerFlag(player, "-joypintingTCU") end
			if player:hasFlag("joypintingFTCU") then room:setPlayerFlag(player, "-joypintingFTCU") end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
joypintingMD = sgs.CreateTargetModSkill{
	name = "joypintingMD",
	pattern = "Card",
	distance_limit_func = function(self, player, card)
		if player:getMark("joypintingFCU") > 0 and not card:isKindOf("SkillCard") then
			return 1000
		else
			return 0
		end
	end,
}
joy_shenerqiao:addSkill(joypinting)
if not sgs.Sanguosha:getSkill("joypintings") then skills:append(joypintings) end
if not sgs.Sanguosha:getSkill("joypintingMD") then skills:append(joypintingMD) end

joyyizheng = sgs.CreateTriggerSkill{
	name = "joyyizheng",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName())
				local choices = {}
				local wt, at, ht = 0, 0, 0
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:getWeapon() ~= nil then
						wt = wt + 1
					end
					if p:getArmor() ~= nil then
						at = at + 1
					end
					if p:getDefensiveHorse() ~= nil or p:getOffensiveHorse() ~= nil then
						ht = ht + 1
					end
				end
				if wt > 0 then
					table.insert(choices, "w")
				end
				if at > 0 then
					table.insert(choices, "a")
				end
				if ht > 0 then
					table.insert(choices, "h")
				end
				local n, m, move_from = 1, 0, nil
				if player:hasFlag(self:objectName()) then n = n + 1 end
				while n > 0 do
					local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
					if choice == "cancel" then break end
					m = m + 1
					if choice == "w" then
						local weapon_movers = sgs.SPlayerList()
						for _, p in sgs.qlist(room:getAllPlayers()) do
							if p:getWeapon() ~= nil then
								weapon_movers:append(p)
							end
						end
						if weapon_movers:length() > 1 then
							move_from = room:askForPlayerChosen(player, weapon_movers, self:objectName(), "joyyizheng_movefrom")
						elseif weapon_movers:length() == 1 then
							for _, i in sgs.qlist(room:getAllPlayers()) do
								if i:getWeapon() ~= nil then
									move_from = i
									break
								end
							end
						end
						if move_from then
							room:setPlayerFlag(player, "joyyizheng_findWeapontoMove")
						end
						table.removeOne(choices, "w")
					elseif choice == "a" then
						local armor_movers = sgs.SPlayerList()
						for _, p in sgs.qlist(room:getAllPlayers()) do
							if p:getArmor() ~= nil then
								armor_movers:append(p)
							end
						end
						if armor_movers:length() > 1 then
							move_from = room:askForPlayerChosen(player, armor_movers, self:objectName(), "joyyizheng_movefrom")
						elseif armor_movers:length() == 1 then
							for _, i in sgs.qlist(room:getAllPlayers()) do
								if i:getArmor() ~= nil then
									move_from = i
									break
								end
							end
						end
						if move_from then
							room:setPlayerFlag(player, "joyyizheng_findArmortoMove")
						end
						table.removeOne(choices, "a")
					elseif choice == "h" then
						local horse_movers = sgs.SPlayerList()
						for _, p in sgs.qlist(room:getAllPlayers()) do
							if p:getDefensiveHorse() ~= nil or p:getOffensiveHorse() ~= nil then
								horse_movers:append(p)
							end
						end
						if horse_movers:length() > 1 then
							move_from = room:askForPlayerChosen(player, horse_movers, self:objectName(), "joyyizheng_movefrom")
						elseif horse_movers:length() == 1 then
							for _, i in sgs.qlist(room:getAllPlayers()) do
								if i:getDefensiveHorse() ~= nil or i:getOffensiveHorse() ~= nil then
									move_from = i
									break
								end
							end
						end
						if move_from then
							local choicess = {}
							if move_from:getDefensiveHorse() ~= nil then
								table.insert(choicess, "df")
							end
							if move_from:getOffensiveHorse() ~= nil then
								table.insert(choicess, "of")
							end
							local choicee = room:askForChoice(player, "joyyizheng_movehorse", table.concat(choicess, "+"))
							if choicee == "df" then
								room:setPlayerFlag(player, "joyyizheng_findDFHtoMove")
							elseif choicee == "of" then
								room:setPlayerFlag(player, "joyyizheng_findOFHtoMove")
							end
						end
						table.removeOne(choices, "h")
					end
					if move_from then
						local card_id
						for _, eq in sgs.qlist(move_from:getCards("e")) do
							if (player:hasFlag("joyyizheng_findWeapontoMove") and eq:isKindOf("Weapon"))
							or (player:hasFlag("joyyizheng_findArmortoMove") and eq:isKindOf("Armor"))
							or (player:hasFlag("joyyizheng_findDFHtoMove") and eq:isKindOf("DefensiveHorse"))
							or (player:hasFlag("joyyizheng_findOFHtoMove") and eq:isKindOf("OffensiveHorse")) then
								card_id = eq:getEffectiveId()
								break
							end
						end
						local card = sgs.Sanguosha:getCard(card_id)
						local place = room:getCardPlace(card_id)
						local equip = card:getRealCard():toEquipCard()
						local equip_index = equip:location()
						local tos = sgs.SPlayerList()
						local list = room:getAlivePlayers()
						for _, p in sgs.qlist(list) do
							if not p:getEquip(equip_index) then
								tos:append(p)
							end
						end
						local tag = sgs.QVariant()
						tag:setValue(move_from)
						room:setTag("joyyizhengTarget", tag)
						local move_to = room:askForPlayerChosen(player, tos, self:objectName(), "joyyizheng_moveto:" .. card:objectName())
						if move_to then
							room:moveCardTo(card, move_from, move_to, place, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, player:objectName(), self:objectName(), ""))
						end
						room:removeTag("joyyizhengTarget")
					end
					n = n - 1
					if player:hasFlag(self:objectName()) and n == 1 then
						table.insert(choices, "cancel")
					end
					if player:hasFlag("joyyizheng_findWeapontoMove") then room:setPlayerFlag(player, "-joyyizheng_findWeapontoMove") end
					if player:hasFlag("joyyizheng_findArmortoMove") then room:setPlayerFlag(player, "-joyyizheng_findArmortoMove") end
					if player:hasFlag("joyyizheng_findDFHtoMove") then room:setPlayerFlag(player, "-joyyizheng_findDFHtoMove") end
					if player:hasFlag("joyyizheng_findOFHtoMove") then room:setPlayerFlag(player, "-joyyizheng_findOFHtoMove") end
				end
				if m == 1 and player:isWounded() then
					room:broadcastSkillInvoke(self:objectName())
					room:recover(player, sgs.RecoverStruct(player))
				elseif m == 2 then
					room:broadcastSkillInvoke(self:objectName())
					room:addPlayerMark(player, "&joyyizheng")
				end
			end
		end
	end,
}
joyyizhengd = sgs.CreateTriggerSkill{
	name = "joyyizhengd",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardsMoveOneTime, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if (move.from and move.from:objectName() == player:objectName()
			and (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip)))
			and not (move.to and move.to:objectName() == player:objectName()
			and (move.to_place == sgs.Player_PlaceHand or move.to_place == sgs.Player_PlaceEquip)) then
				local n = move.card_ids:length()
				if player:hasSkill("joyyizheng") then room:sendCompulsoryTriggerLog(player, "joyyizheng") end
				room:broadcastSkillInvoke("joyyizheng")
				room:drawCards(player, n, "joyyizheng")
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				room:setPlayerMark(player, "&joyyizheng", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&joyyizheng") > 0
	end,
}
joy_shenerqiao:addSkill(joyyizheng)
if not sgs.Sanguosha:getSkill("joyyizhengd") then skills:append(joyyizhengd) end

--孙悟空
joy_sunwukong = sgs.General(extension_j, "joy_sunwukong", "god", 4, true)

joyseventytwoCard = sgs.CreateSkillCard{
	name = "joyseventytwoCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		local czid = self:getSubcards():first()
		local CZ = sgs.Sanguosha:getCard(self:getSubcards():first())
		local log = sgs.LogMessage()
		log.type = "#UseCard_Recast"
		log.from = source
		log.card_str = CZ:toString()
		room:sendLog(log)
		local seventytwo_recast_cards = {}
		local seventytwo_recast_count = 0
		for _, id in sgs.qlist(room:getDrawPile()) do
			if ((sgs.Sanguosha:getCard(id):isKindOf("TrickCard") and CZ:isKindOf("BasicCard"))
			or (sgs.Sanguosha:getCard(id):isKindOf("EquipCard") and CZ:isKindOf("TrickCard"))
			or (sgs.Sanguosha:getCard(id):isKindOf("BasicCard") and CZ:isKindOf("EquipCard")))
			and not table.contains(seventytwo_recast_cards, id) and seventytwo_recast_count < 1 then
				seventytwo_recast_count = seventytwo_recast_count + 1
				table.insert(seventytwo_recast_cards, id)
			end
		end
		if #seventytwo_recast_cards > 0 then
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, id in ipairs(seventytwo_recast_cards) do
				dummy:addSubcard(id)
			end
			--room:broadcastSkillInvoke("joyseventytwo")
			room:obtainCard(source, dummy, true)
			dummy:deleteLater()
		end
		if CZ:isKindOf("BasicCard") then room:setPlayerFlag(source, "joyseventytwoBasic")
		elseif CZ:isKindOf("TrickCard") then room:setPlayerFlag(source, "joyseventytwoTrick")
		elseif CZ:isKindOf("EquipCard") then room:setPlayerFlag(source, "joyseventytwoEquip")
		end
	end,
}
joyseventytwo = sgs.CreateViewAsSkill{
	name = "joyseventytwo",
	n = 1,
	view_filter = function(self, selected, to_select)
		if (sgs.Self:hasFlag("joyseventytwoBasic") and to_select:isKindOf("BasicCard"))
		or (sgs.Self:hasFlag("joyseventytwoTrick") and to_select:isKindOf("TrickCard"))
		or (sgs.Self:hasFlag("joyseventytwoEquip") and to_select:isKindOf("EquipCard"))
		then return false end
		return true
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local cg_card = joyseventytwoCard:clone()
			cg_card:addSubcard(cards[1])
			return cg_card
		end
	end,
	enabled_at_play = function(self, player)
		return not (player:hasFlag("joyseventytwoBasic") and player:hasFlag("joyseventytwoTrick") and player:hasFlag("joyseventytwoEquip"))
	end,
}
joy_sunwukong:addSkill(joyseventytwo)

joyruyi = sgs.CreateViewAsEquipSkill{
	name = "joyruyi",
	waked_skills = "joy_ruyijingubang",
	view_as_equip = function(self, player)
		if player:getWeapon() == nil then
			if player:getMark("&joy_ruyijingubang") == 1 then
				return "__joy_ruyijingubang_one"
			elseif player:getMark("&joy_ruyijingubang") == 2 then
				return "__joy_ruyijingubang_two"
			elseif player:getMark("&joy_ruyijingubang") == 3 then
				return "__joy_ruyijingubang_three"
			elseif player:getMark("&joy_ruyijingubang") == 4 then
				return "__joy_ruyijingubang_four"
			else
				return ""
			end
		else
			return ""
		end
	end,
}
joy_ruyijingubang = sgs.CreateTriggerSkill{
	name = "joy_ruyijingubang",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.GameStart, sgs.EventAcquireSkill, sgs.EventLoseSkill, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:hasSkill("joyruyi") then
				room:sendCompulsoryTriggerLog(player, "joyruyi")
				room:broadcastSkillInvoke("joyruyi")
				room:setPlayerMark(player, "&joy_ruyijingubang", 1) --设置初始攻击范围为1
			end
		elseif event == sgs.EventAcquireSkill then
			if data:toString() == "joyruyi" then
				room:sendCompulsoryTriggerLog(player, "joyruyi")
				room:broadcastSkillInvoke("joyruyi")
				room:setPlayerMark(player, "&joy_ruyijingubang", 1)
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == "joyruyi" then
				room:setPlayerMark(player, "&joy_ruyijingubang", 0)
			end
		elseif event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_RoundStart and player:getWeapon() == nil then
			if player:getMark("&joy_ruyijingubang") > 0 then
				local choices = {}
				if player:getMark("&joy_ruyijingubang") ~= 1 then
					table.insert(choices, "1")
				end
				if player:getMark("&joy_ruyijingubang") ~= 2 then
					table.insert(choices, "2")
				end
				if player:getMark("&joy_ruyijingubang") ~= 3 then
					table.insert(choices, "3")
				end
				if player:getMark("&joy_ruyijingubang") ~= 4 then
					table.insert(choices, "4")
				end
				table.insert(choices, "5")
				local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
				if choice == "5" then return false end
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke("joyruyi")
				if choice == "1" then
					room:setPlayerMark(player, "&joy_ruyijingubang", 1)
				elseif choice == "2" then
					room:setPlayerMark(player, "&joy_ruyijingubang", 2)
				elseif choice == "3" then
					room:setPlayerMark(player, "&joy_ruyijingubang", 3)
				elseif choice == "4" then
					room:setPlayerMark(player, "&joy_ruyijingubang", 4)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
joy_sunwukong:addSkill(joyruyi)
joy_sunwukong:addRelateSkill("joy_ruyijingubang")
if not sgs.Sanguosha:getSkill("joy_ruyijingubang") then skills:append(joy_ruyijingubang) end
--==专属装备·如意金箍棒（武器）==--
--攻击范围1(初始装备)：
JoyRuyijingubangOne = sgs.CreateWeapon{
	name = "__joy_ruyijingubang_one",
	class_name = "JoyRuyijingubangOne",
	range = 1,
	on_install = function()
	end,
	on_uninstall = function()
	end,
}
JoyRuyijingubangOne:clone(sgs.Card_Heart, 1):setParent(newgodsCard)
joyruyiOne = sgs.CreateTargetModSkill{ --距离为1的专属效果
	name = "joyruyiOne",
	residue_func = function(self, player)
		if player:getWeapon() == nil and player:hasSkill("joyruyi") and player:getMark("&joy_ruyijingubang") == 1 then
			return 1000
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("joyruyiOne") then skills:append(joyruyiOne) end
--攻击范围2：
JoyRuyijingubangTwo = sgs.CreateWeapon{
	name = "__joy_ruyijingubang_two",
	class_name = "JoyRuyijingubangTwo",
	range = 2,
	on_install = function()
	end,
	on_uninstall = function()
	end,
}
JoyRuyijingubangTwo:clone(sgs.Card_Heart, 2):setParent(newgodsCard)
joyruyiTwo = sgs.CreateTriggerSkill{ --距离为2的专属效果
	name = "joyruyiTwo",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardFinished, sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") and use.from:objectName() == player:objectName()
			and player:getPhase() ~= sgs.Player_NotActive and not player:hasFlag("joyruyiTwo_notfirstSlash") then
				room:setPlayerFlag(player, "joyruyiTwo_notfirstSlash")
			end
		elseif event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash") and damage.from:objectName() == player:objectName()
			and player:getWeapon() == nil and player:hasSkill("joyruyi") and player:getMark("&joy_ruyijingubang") == 2
			and player:getPhase() ~= sgs.Player_NotActive and not player:hasFlag("joyruyiTwo_notfirstSlash") then
				local hurt = damage.damage
				damage.damage = hurt + 1
				data:setValue(damage)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("joyruyiTwo") then skills:append(joyruyiTwo) end
--攻击范围3：
JoyRuyijingubangThree = sgs.CreateWeapon{
	name = "__joy_ruyijingubang_three",
	class_name = "JoyRuyijingubangThree",
	range = 3,
	on_install = function()
	end,
	on_uninstall = function()
	end,
}
JoyRuyijingubangThree:clone(sgs.Card_Heart, 3):setParent(newgodsCard)
joyruyiThree = sgs.CreateTriggerSkill{ --距离为3的专属效果
	name = "joyruyiThree",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecified},
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
		return player:getWeapon() == nil and player:hasSkill("joyruyi") and player:getMark("&joy_ruyijingubang") == 3
	end,
}
if not sgs.Sanguosha:getSkill("joyruyiThree") then skills:append(joyruyiThree) end
--攻击范围4：
JoyRuyijingubangFour = sgs.CreateWeapon{
	name = "__joy_ruyijingubang_four",
	class_name = "JoyRuyijingubangFour",
	range = 4,
	on_install = function()
	end,
	on_uninstall = function()
	end,
}
JoyRuyijingubangFour:clone(sgs.Card_Heart, 4):setParent(newgodsCard)
joyruyiFour = sgs.CreateTargetModSkill{ --距离为4的专属效果
	name = "joyruyiFour",
	extra_target_func = function(self, player)
		if player:getWeapon() == nil and player:hasSkill("joyruyi") and player:getMark("&joy_ruyijingubang") == 4 then
		    return 1
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("joyruyiFour") then skills:append(joyruyiFour) end
----

joyqitian = sgs.CreateTriggerSkill{
	name = "joyqitian",
	frequency = sgs.Skill_Wake,
	events = {sgs.HpChanged},
	waked_skills = "qt_huoyan, qt_jindouyun",
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		if player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getHp() ~= 1 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		room:doLightbox("joyqitianAnimate")
		room:loseMaxHp(player, 1)
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
		if not player:hasSkill("qt_huoyan") then
			room:acquireSkill(player, "qt_huoyan")
		end
		if not player:hasSkill("qt_jindouyun") then
			room:acquireSkill(player, "qt_jindouyun")
		end
	end,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
joy_sunwukong:addSkill(joyqitian)
joy_sunwukong:addRelateSkill("qt_huoyan")
joy_sunwukong:addRelateSkill("qt_jindouyun")
--“火眼”
qt_huoyanCard = sgs.CreateSkillCard{
    name = "qt_huoyanCard",
	target_fixed = false,
	view_filter = function(self, selected, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and not to_select:isKongcheng()
	end,
	on_use = function(self, room, source, targets)
	    local yaoguai = targets[1]
		room:showAllCards(yaoguai, source)
	end,
}
qt_huoyan = sgs.CreateZeroCardViewAsSkill{
    name = "qt_huoyan",
	view_as = function()
		return qt_huoyanCard:clone()
	end,
	enabled_at_play = function(self, player)
		return true
	end,
}
qt_huoyanTrigger = sgs.CreateTriggerSkill{ --和新杀孙悟空的“金睛”一模一样
	name = "qt_huoyanTrigger",
	global = true,
	priority = {667, 667, 667, 667, 667},--666,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.EventPhaseStart, sgs.TargetConfirming, sgs.EventAcquireSkill, sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:hasSkill("qt_huoyan") then
				room:setTag("Dongchaer", sgs.QVariant(player:objectName()))
				local hyjj = room:askForPlayersChosen(player, room:getOtherPlayers(player), "qt_huoyan", 0, 999, "@qt_huoyan-toseeGMS", false, true) --目标角色多选
				if not hyjj:isEmpty() then
					room:sendCompulsoryTriggerLog(player, "qt_huoyan")
					room:broadcastSkillInvoke("qt_huoyan")
					for _, p in sgs.qlist(hyjj) do
						room:doAnimate(1, player:objectName(), p:objectName())
						room:showAllCards(p, player)
						room:getThread():delay()
					end
				end
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				for _, skw in sgs.qlist(room:findPlayersBySkillName("qt_huoyan")) do
					local hyjj = room:askForPlayersChosen(skw, room:getOtherPlayers(skw), "qt_huoyan", 0, 999, "@qt_huoyan-tosee", false, true)
					if not hyjj:isEmpty() then
						room:sendCompulsoryTriggerLog(skw, "qt_huoyan")
						room:broadcastSkillInvoke("qt_huoyan")
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
			if use.from and use.from:objectName() ~= player:objectName() and not use.from:isKongcheng() and player:hasSkill("qt_huoyan") then
				room:sendCompulsoryTriggerLog(player, "qt_huoyan")
				room:showAllCards(use.from, player)
			end
		elseif event == sgs.EventAcquireSkill then
			if data:toString() == "qt_huoyan" then
				room:setTag("Dongchaer", sgs.QVariant(player:objectName()))
				local hyjj = room:askForPlayersChosen(player, room:getOtherPlayers(player), "qt_huoyan", 0, 999, "@qt_huoyan-tosee", false, true)
				if not hyjj:isEmpty() then
					room:sendCompulsoryTriggerLog(player, "qt_huoyan")
					room:broadcastSkillInvoke("qt_huoyan")
					for _, p in sgs.qlist(hyjj) do
						room:doAnimate(1, player:objectName(), p:objectName())
						room:showAllCards(p, player)
						room:getThread():delay()
					end
				end
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == "qt_huoyan" then
				local other_skw = room:findPlayerBySkillName("qt_huoyan")
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
if not sgs.Sanguosha:getSkill("qt_huoyan") then skills:append(qt_huoyan) end
if not sgs.Sanguosha:getSkill("qt_huoyanTrigger") then skills:append(qt_huoyanTrigger) end
--“筋斗云”
qt_jindouyun = sgs.CreateDistanceSkill{
	name = "qt_jindouyun",
	correct_func = function(self, from, to)
		local correct = 0
		if from:hasSkill(self:objectName()) then
			correct = correct - 1
		end
		if to:hasSkill(self:objectName()) then
			correct = correct + 1
		end
		return correct
	end,
}
if not sgs.Sanguosha:getSkill("qt_jindouyun") then skills:append(qt_jindouyun) end

--孙悟空-威力加强版
joy_sunwukongEX = sgs.General(extension_j, "joy_sunwukongEX", "god", 5, true)

joyseventytwoEXCard = sgs.CreateSkillCard{
	name = "joyseventytwoEXCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		local czid = self:getSubcards():first()
		local CZ = sgs.Sanguosha:getCard(self:getSubcards():first())
		local choices = {}
		if not CZ:isKindOf("BasicCard") then
			table.insert(choices, "rtBasic")
		end
		if not CZ:isKindOf("TrickCard") then
			table.insert(choices, "rtTrick")
		end
		if not CZ:isKindOf("EquipCard") then
			table.insert(choices, "rtEquip")
		end
		local choice = room:askForChoice(source, "joyseventytwoEX", table.concat(choices, "+"))
		if choice == "rtBasic" then
			room:setPlayerFlag(source, "joyseventytwoEX_rtBasic")
		elseif choice == "rtTrick" then
			room:setPlayerFlag(source, "joyseventytwoEX_rtTrick")
		elseif choice == "rtEquip" then
			room:setPlayerFlag(source, "joyseventytwoEX_rtEquip")
		end
		local log = sgs.LogMessage()
		log.type = "#UseCard_Recast"
		log.from = source
		log.card_str = CZ:toString()
		room:sendLog(log)
		local seventytwo_recast_cards = {}
		local seventytwo_recast_count = 0
		for _, id in sgs.qlist(room:getDrawPile()) do
			if ((sgs.Sanguosha:getCard(id):isKindOf("BasicCard") and source:hasFlag("joyseventytwoEX_rtBasic"))
			or (sgs.Sanguosha:getCard(id):isKindOf("TrickCard") and source:hasFlag("joyseventytwoEX_rtTrick"))
			or (sgs.Sanguosha:getCard(id):isKindOf("EquipCard") and source:hasFlag("joyseventytwoEX_rtEquip")))
			and not table.contains(seventytwo_recast_cards, id) and seventytwo_recast_count < 1 then
				seventytwo_recast_count = seventytwo_recast_count + 1
				table.insert(seventytwo_recast_cards, id)
			end
		end
		if #seventytwo_recast_cards > 0 then
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, id in ipairs(seventytwo_recast_cards) do
				dummy:addSubcard(id)
			end
			room:broadcastSkillInvoke("joyseventytwoEX")
			room:obtainCard(source, dummy, true)
			dummy:deleteLater()
		end
		if CZ:isKindOf("BasicCard") then room:setPlayerFlag(source, "joyseventytwoEXBasic")
		elseif CZ:isKindOf("TrickCard") then room:setPlayerFlag(source, "joyseventytwoEXTrick")
		elseif CZ:isKindOf("EquipCard") then room:setPlayerFlag(source, "joyseventytwoEXEquip")
		end
		if source:hasFlag("joyseventytwoEX_rtBasic") then room:setPlayerFlag(source, "-joyseventytwoEX_rtBasic") end
		if source:hasFlag("joyseventytwoEX_rtTrick") then room:setPlayerFlag(source, "-joyseventytwoEX_rtTrick") end
		if source:hasFlag("joyseventytwoEX_rtEquip") then room:setPlayerFlag(source, "-joyseventytwoEX_rtEquip") end
	end,
}
joyseventytwoEX = sgs.CreateViewAsSkill{
	name = "joyseventytwoEX",
	n = 1,
	view_filter = function(self, selected, to_select)
		if (sgs.Self:hasFlag("joyseventytwoEXBasic") and to_select:isKindOf("BasicCard"))
		or (sgs.Self:hasFlag("joyseventytwoEXTrick") and to_select:isKindOf("TrickCard"))
		or (sgs.Self:hasFlag("joyseventytwoEXEquip") and to_select:isKindOf("EquipCard"))
		then return false end
		return true
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local cg_card = joyseventytwoEXCard:clone()
			cg_card:addSubcard(cards[1])
			return cg_card
		end
	end,
	enabled_at_play = function(self, player)
		return not (player:hasFlag("joyseventytwoEXBasic") and player:hasFlag("joyseventytwoEXTrick") and player:hasFlag("joyseventytwoEXEquip"))
	end,
}
joy_sunwukongEX:addSkill(joyseventytwoEX)

joy_sunwukongEX:addSkill("qt_jindouyun")

joyruyiEX_zhongjiCard = sgs.CreateSkillCard{
    name = "joyruyiEX_zhongjiCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local choice = room:askForChoice(source, "joyruyiEX_zhongji", "fire+thunder+ice+none")
		if choice == "fire" then
			room:askForUseCard(source, "@@joyruyiEX_zhongji_FireSlash", "@joyruyiEX_zhongji_FireSlash")
		elseif choice == "thunder" then
			room:askForUseCard(source, "@@joyruyiEX_zhongji_ThunderSlash", "@joyruyiEX_zhongji_ThunderSlash")
		elseif choice == "ice" then
			room:askForUseCard(source, "@@joyruyiEX_zhongji_IceSlash", "@joyruyiEX_zhongji_IceSlash")
		elseif choice == "none" then
			room:askForUseCard(source, "@@joyruyiEX_zhongji_NormalSlash", "@joyruyiEX_zhongji_NormalSlash")
		end
	end,
}
joyruyiEX_zhongji = sgs.CreateZeroCardViewAsSkill{
    name = "joyruyiEX_zhongji",
	waked_skills = "joy_zjjingubang",
	view_as = function()
		return joyruyiEX_zhongjiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#joyruyiEX_zhongjiCard") and sgs.Slash_IsAvailable(player)
	end,
}
joy_sunwukongEX:addSkill(joyruyiEX_zhongji)
joy_sunwukongEX:addRelateSkill("joy_zjjingubang")
--火杀
joyruyiEX_zhongji_FireSlash = sgs.CreateOneCardViewAsSkill{
	name = "joyruyiEX_zhongji_FireSlash",
	view_filter = function(self, card)
		if not card:isKindOf("EquipCard") then return false end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			local fs = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, -1)
			fs:addSubcard(card:getEffectiveId())
			fs:deleteLater()
			return fs:isAvailable(sgs.Self)
		end
		return true
	end,
	view_as = function(self, card)
		local fs = sgs.Sanguosha:cloneCard("fire_slash", card:getSuit(), card:getNumber())
		fs:addSubcard(card:getId())
		fs:setSkillName("joyruyiEX_zhongji")
		return fs
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	response_pattern = "@@joyruyiEX_zhongji_FireSlash",
}
if not sgs.Sanguosha:getSkill("joyruyiEX_zhongji_FireSlash") then skills:append(joyruyiEX_zhongji_FireSlash) end
--雷杀
joyruyiEX_zhongji_ThunderSlash = sgs.CreateOneCardViewAsSkill{
	name = "joyruyiEX_zhongji_ThunderSlash",
	view_filter = function(self, card)
		if not card:isKindOf("EquipCard") then return false end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			local ts = sgs.Sanguosha:cloneCard("thunder_slash", sgs.Card_SuitToBeDecided, -1)
			ts:addSubcard(card:getEffectiveId())
			ts:deleteLater()
			return ts:isAvailable(sgs.Self)
		end
		return true
	end,
	view_as = function(self, card)
		local ts = sgs.Sanguosha:cloneCard("thunder_slash", card:getSuit(), card:getNumber())
		ts:addSubcard(card:getId())
		ts:setSkillName("joyruyiEX_zhongji")
		return ts
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	response_pattern = "@@joyruyiEX_zhongji_ThunderSlash",
}
if not sgs.Sanguosha:getSkill("joyruyiEX_zhongji_ThunderSlash") then skills:append(joyruyiEX_zhongji_ThunderSlash) end
--冰杀
joyruyiEX_zhongji_IceSlash = sgs.CreateOneCardViewAsSkill{
	name = "joyruyiEX_zhongji_IceSlash",
	view_filter = function(self, card)
		if not card:isKindOf("EquipCard") then return false end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			local is = sgs.Sanguosha:cloneCard("ice_slash", sgs.Card_SuitToBeDecided, -1)
			is:addSubcard(card:getEffectiveId())
			is:deleteLater()
			return is:isAvailable(sgs.Self)
		end
		return true
	end,
	view_as = function(self, card)
		local is = sgs.Sanguosha:cloneCard("ice_slash", card:getSuit(), card:getNumber())
		is:addSubcard(card:getId())
		is:setSkillName("joyruyiEX_zhongji")
		return is
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	response_pattern = "@@joyruyiEX_zhongji_IceSlash",
}
if not sgs.Sanguosha:getSkill("joyruyiEX_zhongji_IceSlash") then skills:append(joyruyiEX_zhongji_IceSlash) end
--无属性杀(普通杀)
joyruyiEX_zhongji_NormalSlash = sgs.CreateOneCardViewAsSkill{
	name = "joyruyiEX_zhongji_NormalSlash",
	view_filter = function(self, card)
		if not card:isKindOf("EquipCard") then return false end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			local ns = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
			ns:addSubcard(card:getEffectiveId())
			ns:deleteLater()
			return ns:isAvailable(sgs.Self)
		end
		return true
	end,
	view_as = function(self, card)
		local ns = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber())
		ns:addSubcard(card:getId())
		ns:setSkillName("joyruyiEX_zhongji")
		return ns
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	response_pattern = "@@joyruyiEX_zhongji_NormalSlash",
}
if not sgs.Sanguosha:getSkill("joyruyiEX_zhongji_NormalSlash") then skills:append(joyruyiEX_zhongji_NormalSlash) end
--
joyruyiEX_zhongji_SlashMD = sgs.CreateTargetModSkill{
	name = "joyruyiEX_zhongji_SlashMD",
	pattern = "Slash",
	distance_limit_func = function(self, player, card)
		if card:getSkillName() == "joyruyiEX_zhongji" then
			return 1000
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("joyruyiEX_zhongji_SlashMD") then skills:append(joyruyiEX_zhongji_SlashMD) end
----
joyruyiEX_zhongjii = sgs.CreateViewAsEquipSkill{
	name = "#joyruyiEX_zhongjii",
	view_as_equip = function(self, player)
		if player:hasSkill("joyruyiEX_zhongji") and player:getWeapon() == nil then
			if player:getMark("&joy_zjjingubang") == 1 then
				return "__joy_zjjingubang_one"
			elseif player:getMark("&joy_zjjingubang") == 2 then
				return "__joy_zjjingubang_two"
			elseif player:getMark("&joy_zjjingubang") == 3 then
				return "__joy_zjjingubang_three"
			elseif player:getMark("&joy_zjjingubang") == 4 then
				return "__joy_zjjingubang_four"
			else
				return ""
			end
		else
			return ""
		end
	end,
}
joy_zjjingubang = sgs.CreateTriggerSkill{
	name = "joy_zjjingubang",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.GameStart, sgs.EventAcquireSkill, sgs.EventLoseSkill, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:hasSkill("joyruyiEX_zhongji") then
				room:sendCompulsoryTriggerLog(player, "joyruyiEX_zhongji")
				room:broadcastSkillInvoke("joyruyiEX_zhongji")
				room:setPlayerMark(player, "&joy_zjjingubang", 4) --设置初始攻击范围为4
			end
		elseif event == sgs.EventAcquireSkill then
			if data:toString() == "joyruyiEX_zhongji" then
				room:sendCompulsoryTriggerLog(player, "joyruyiEX_zhongji")
				room:broadcastSkillInvoke("joyruyiEX_zhongji")
				room:setPlayerMark(player, "&joy_zjjingubang", 4)
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == "joyruyiEX_zhongji" then
				room:setPlayerMark(player, "&joy_zjjingubang", 0)
			end
		elseif event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_RoundStart and player:getWeapon() == nil then
			if player:getMark("&joy_zjjingubang") > 0 then
				local choices = {}
				if player:getMark("&joy_zjjingubang") ~= 1 then
					table.insert(choices, "1")
				end
				if player:getMark("&joy_zjjingubang") ~= 2 then
					table.insert(choices, "2")
				end
				if player:getMark("&joy_zjjingubang") ~= 3 then
					table.insert(choices, "3")
				end
				if player:getMark("&joy_zjjingubang") ~= 4 then
					table.insert(choices, "4")
				end
				table.insert(choices, "5")
				local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
				if choice == "5" then return false end
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke("joyruyiEX_zhongji")
				if choice == "1" then
					room:setPlayerMark(player, "&joy_zjjingubang", 1)
				elseif choice == "2" then
					room:setPlayerMark(player, "&joy_zjjingubang", 2)
				elseif choice == "3" then
					room:setPlayerMark(player, "&joy_zjjingubang", 3)
				elseif choice == "4" then
					room:setPlayerMark(player, "&joy_zjjingubang", 4)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
joy_sunwukongEX:addSkill(joyruyiEX_zhongjii)
if not sgs.Sanguosha:getSkill("joy_zjjingubang") then skills:append(joy_zjjingubang) end
--==专属装备·终极金箍棒（武器）==--
--攻击范围1：
JoyZjjingubangOne = sgs.CreateWeapon{
	name = "__joy_zjjingubang_one",
	class_name = "JoyZjjingubangOne",
	range = 1,
	on_install = function()
	end,
	on_uninstall = function()
	end,
}
JoyZjjingubangOne:clone(sgs.Card_Heart, 10):setParent(newgodsCard)
JoyZjOne = sgs.CreateTargetModSkill{ --距离为1的专属效果
	name = "JoyZjOne",
	residue_func = function(self, player)
		if player:getWeapon() == nil and player:hasSkill("joyruyiEX_zhongji") and player:getMark("&joy_zjjingubang") == 1 then
			return 1000
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("JoyZjOne") then skills:append(JoyZjOne) end
--攻击范围2：
JoyZjjingubangTwo = sgs.CreateWeapon{
	name = "__joy_zjjingubang_two",
	class_name = "JoyZjjingubangTwo",
	range = 2,
	on_install = function()
	end,
	on_uninstall = function()
	end,
}
JoyZjjingubangTwo:clone(sgs.Card_Heart, 11):setParent(newgodsCard)
JoyZjTwo = sgs.CreateTriggerSkill{ --距离为1&2的效果
	name = "JoyZjTwo",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardFinished, sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") and use.from:objectName() == player:objectName()
			and player:getPhase() ~= sgs.Player_NotActive and not player:hasFlag("JoyZjTwo_notfirstSlash") then
				room:setPlayerFlag(player, "JoyZjTwo_notfirstSlash")
			end
		elseif event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash") and damage.from:objectName() == player:objectName()
			and player:getWeapon() == nil and player:hasSkill("joyruyiEX_zhongji") and (player:getMark("&joy_zjjingubang") == 1 or player:getMark("&joy_zjjingubang") == 2)
			and player:getPhase() ~= sgs.Player_NotActive and not player:hasFlag("JoyZjTwo_notfirstSlash") then
				local hurt = damage.damage
				damage.damage = hurt + 1
				data:setValue(damage)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("JoyZjTwo") then skills:append(JoyZjTwo) end
--攻击范围3：
JoyZjjingubangThree = sgs.CreateWeapon{
	name = "__joy_zjjingubang_three",
	class_name = "JoyZjjingubangThree",
	range = 3,
	on_install = function()
	end,
	on_uninstall = function()
	end,
}
JoyZjjingubangThree:clone(sgs.Card_Heart, 12):setParent(newgodsCard)
JoyZjThree = sgs.CreateTriggerSkill{ --距离为1/2/3的效果
	name = "JoyZjThree",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecified},
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
		return player:getWeapon() == nil and player:hasSkill("joyruyiEX_zhongji") and (player:getMark("&joy_zjjingubang") >= 1 and player:getMark("&joy_zjjingubang") <= 3)
	end,
}
if not sgs.Sanguosha:getSkill("JoyZjThree") then skills:append(JoyZjThree) end
--攻击范围4(初始装备)：
JoyZjjingubangFour = sgs.CreateWeapon{
	name = "__joy_zjjingubang_four",
	class_name = "JoyZjjingubangFour",
	range = 4,
	on_install = function()
	end,
	on_uninstall = function()
	end,
}
JoyZjjingubangFour:clone(sgs.Card_Heart, 13):setParent(newgodsCard)
JoyZjFour = sgs.CreateTargetModSkill{ --距离为1/2/3/4的效果
	name = "JoyZjFour",
	extra_target_func = function(self, player)
		if player:getWeapon() == nil and player:hasSkill("joyruyiEX_zhongji") and (player:getMark("&joy_zjjingubang") >= 1 and player:getMark("&joy_zjjingubang") <= 4) then
		    return 1
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("JoyZjFour") then skills:append(JoyZjFour) end
----

joyqitianEX = sgs.CreateTriggerSkill{
	name = "joyqitianEX",
	frequency = sgs.Skill_Wake,
	events = {sgs.HpChanged},
	waked_skills = "qt_huoyan, qt_fatianxiangdi",
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		if player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getHp() > player:getMaxHp()/2 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		sgs.Sanguosha:playAudioEffect("audio/skill/joyqitianEXs.ogg", false) room:broadcastSkillInvoke(self:objectName())
		room:doLightbox("joyqitianAnimate")
		room:loseMaxHp(player, 1)
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
		local rec, n = player:getMaxHp() - player:getHp(), player:getMaxHp() - player:getHandcardNum()
		local choices = {}
		if rec > 0 then
			table.insert(choices, "recover")
		end
		if n > 0 then
			table.insert(choices, "draw")
		end
		if #choices > 0 then
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			if choice == "recover" then
				room:recover(player, sgs.RecoverStruct(player, nil, rec))
			elseif choice == "draw" then
				room:drawCards(player, n, self:objectName())
			end
		end
		if not player:hasSkill("qt_huoyan") then
			room:acquireSkill(player, "qt_huoyan")
		end
		if not player:hasSkill("qt_fatianxiangdi") then
			room:acquireSkill(player, "qt_fatianxiangdi")
		end
	end,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
joy_sunwukongEX:addSkill(joyqitianEX)
joy_sunwukongEX:addRelateSkill("qt_huoyan")
joy_sunwukongEX:addRelateSkill("qt_fatianxiangdi")
--“火眼”（同原版）
--“法象”（法天象地）
qt_fatianxiangdiCard = sgs.CreateSkillCard{
	name = "qt_fatianxiangdiCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
	    room:removePlayerMark(source, "@qt_fatianxiangdi")
		room:doSuperLightbox("joy_sunwukongEX", "qt_fatianxiangdi")
		room:setPlayerMark(source, "qt_fatianxiangdiMaxHp", source:getMaxHp()) --储存玩家此时的体力上限
		room:setPlayerMark(source, "qt_fatianxiangdiHp", source:getHp()) --储存玩家此时的体力值
		local mhp, hp = 0, 0
		for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			mhp = mhp + p:getMaxHp()
			hp = hp + p:getHp()
		end
		room:setPlayerProperty(source, "maxhp", sgs.QVariant(mhp))
		local log = sgs.LogMessage()
		log.type = "$qt_fatianxiangdiMaxHp"
		log.from = source
		log.arg2 = mhp
		 room:sendLog(log)
		room:setPlayerProperty(source, "hp", sgs.QVariant(hp))
		local log = sgs.LogMessage()
		log.type = "$qt_fatianxiangdiHp"
		log.from = source
		log.arg2 = hp
		room:sendLog(log)
		room:addPlayerMark(source, "&qt_fatianxiangdii")
	end,
}
qt_fatianxiangdiVS = sgs.CreateZeroCardViewAsSkill{
	name = "qt_fatianxiangdi",
	view_as = function()
		return qt_fatianxiangdiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@qt_fatianxiangdi") > 0
	end,
}
qt_fatianxiangdi = sgs.CreateTriggerSkill{ --时效结束，调整回来
	name = "qt_fatianxiangdi",
	--global = true,
	frequency = sgs.Skill_Limited,
	limit_mark = "@qt_fatianxiangdi",
	view_as_skill = qt_fatianxiangdiVS,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local mhp = player:getMark("qt_fatianxiangdiMaxHp")
		local hp = player:getMark("qt_fatianxiangdiHp")
		room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp))
		room:setPlayerProperty(player, "hp", sgs.QVariant(hp))
		room:setPlayerMark(player, "qt_fatianxiangdiMaxHp", 0)
		room:setPlayerMark(player, "qt_fatianxiangdiHp", 0)
		room:setPlayerMark(player, "&qt_fatianxiangdii", 0)
	end,
	can_trigger = function(self, player)
		return player:getMark("&qt_fatianxiangdii") > 0 and player:getPhase() == sgs.Player_RoundStart
	end,
}
if not sgs.Sanguosha:getSkill("qt_fatianxiangdi") then skills:append(qt_fatianxiangdi) end
--[[joyruyiExtra = sgs.CreateTriggerSkill{
	name = "joyruyiExtra",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceEquip then
			for _, id in sgs.qlist(move.card_ids) do
				local jgb = sgs.Sanguosha:getCard(id)
				if jgb:isKindOf("Weapon") then
					room:setPlayerMark(player, "&joy_ruyijingubang", 0)
					room:setPlayerMark(player, "&joy_zjjingubang", 0)
				end
			end
		end
		if move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceEquip) then
			for _, id in sgs.qlist(move.card_ids) do
				local jgb = sgs.Sanguosha:getCard(id)
				if jgb:isKindOf("Weapon") then
					if player:hasSkill("joyruyi") then
						room:setPlayerMark(player, "&joy_ruyijingubang", 1)
					end
					if player:hasSkill("joyruyiEX_zhongji") then
						room:setPlayerMark(player, "&joy_zjjingubang", 4)
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("joyruyiExtra") then skills:append(joyruyiExtra) end]]

--

--嫦娥
joy_change = sgs.General(extension_j, "joy_change", "god", 4, false, false, false, 1)

joydaoyaoCard = sgs.CreateSkillCard{
	name = "joydaoyaoCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		local joydaoyao_peach = {}
		local joydaoyao_count = 0
		for _, id in sgs.qlist(room:getDrawPile()) do
			if sgs.Sanguosha:getCard(id):isKindOf("Peach") and joydaoyao_count < 1 then
				joydaoyao_count = joydaoyao_count + 1
				table.insert(joydaoyao_peach, id)
			end
		end
		if #joydaoyao_peach > 0 then
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, id in ipairs(joydaoyao_peach) do
				dummy:addSubcard(id)
			end
			room:obtainCard(source, dummy)
			dummy:deleteLater()
			room:drawCards(source, 2, "joydaoyao")
		else
			room:drawCards(source, 3, "joydaoyao")
		end
	end,
}
joydaoyao = sgs.CreateOneCardViewAsSkill{
	name = "joydaoyao",
	filter_pattern = ".|.|.|hand",
	view_as = function(self, cards)
		local card = joydaoyaoCard:clone()
		card:addSubcard(cards)
		return card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#joydaoyaoCard")
	end,
}
joy_change:addSkill(joydaoyao)

joybenyueRecover = sgs.CreateTriggerSkill{
    name = "joybenyueRecover",
	global = true,
	priority = 3, --优先级高于觉醒技主体，便于觉醒判断
	frequency = sgs.Skill_Frequent,
	events = {sgs.HpRecover},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local recover = data:toRecover()
		room:addPlayerMark(player, self:objectName(), recover.recover)
	end,
	can_trigger = function(self, player)
	    return player:getMark("joybenyue") == 0
	end,
}
joybenyue = sgs.CreateTriggerSkill{
    name = "joybenyue",
	frequency = sgs.Skill_Wake,
	waked_skills = "by_guanghan",
	events = {sgs.CardsMoveOneTime, sgs.HpRecover},
	can_wake = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getMark(self:objectName()) > 0 then return false end
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from_places:contains(sgs.Player_DrawPile) and move.to and move.to:objectName() == player:objectName() then
				for _, id in sgs.qlist(move.card_ids) do
					if room:getCardOwner(id):objectName() == player:objectName() and room:getCardPlace(id) == sgs.Player_PlaceHand
					and sgs.Sanguosha:getCard(id):isKindOf("Peach") then
						if player:canWake(self:objectName()) then
							return true
						else
							if player:getHandcardNum() < 3 then return false end
							local peach_num = 0
							for _, cd in sgs.qlist(player:getHandcards()) do
								if cd:isKindOf("Peach") then
									peach_num = peach_num + 1
								end
							end
							if peach_num >= 3 then return true
							else return false end
						end
						break
					end
				end
			end
		elseif event == sgs.HpRecover then
			if player:canWake(self:objectName()) or player:getMark("joybenyueRecover") >= 3 then
				return true
			end
		end
		return false
	end,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		room:doSuperLightbox("joy_change", self:objectName())
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
		local mhp = player:getMaxHp()
		if mhp < 15 then
			local m = 15 - mhp
			room:gainMaxHp(player, m, self:objectName())
		end
		if not player:hasSkill("by_guanghan") then
			room:acquireSkill(player, "by_guanghan")
		end
	end,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
joy_change:addSkill(joybenyue)
joy_change:addRelateSkill("by_guanghan")
if not sgs.Sanguosha:getSkill("joybenyueRecover") then skills:append(joybenyueRecover) end
--“广寒”
by_guanghan = sgs.CreateTriggerSkill{
    name = "by_guanghan",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local damage = data:toDamage()
		local ces = room:findPlayerBySkillName(self:objectName())
		if not ces then return false end
		local last, naxt = nil, nil --相邻角色即为上下家
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:getNextAlive():objectName() == player:objectName() and not isSpecialOne(p, "嫦娥") then
				last = p
			end
		end
		local q = player:getNextAlive()
		if q:objectName() ~= last:objectName() and not isSpecialOne(q, "嫦娥") then
			naxt = q
		end
		if last == nil and naxt == nil then return false end
		room:sendCompulsoryTriggerLog(ces, self:objectName())
		room:broadcastSkillInvoke(self:objectName())
		local dis
		if last ~= nil then
			if not last:isKongcheng() and last:canDiscard(last, "h") then
				if last:getState() == "robot" and (last:getHandcardNum() > 1 or last:getHp() <= damage.damage)
				and not (last:getHp() > damage.damage and (last:hasSkill("zhaxiang") or last:hasSkill("moukurouu"))) then --有老六
					dis = room:askForDiscard(last, self:objectName(), 1, 1) --一般情况下，AI选择风险更低的弃手牌
				else
					dis = room:askForDiscard(last, self:objectName(), 1, 1, true, false)
				end
				if not dis then
					room:loseHp(last, damage.damage)
				end
			else
				room:loseHp(last, damage.damage)
			end
		end
		if naxt ~= nil then
			if not naxt:isKongcheng() and naxt:canDiscard(naxt, "h") then
				if naxt:getState() == "robot" and (naxt:getHandcardNum() > 1 or naxt:getHp() <= damage.damage)
				and not (naxt:getHp() > damage.damage and (naxt:hasSkill("zhaxiang") or naxt:hasSkill("moukurouu"))) then --有老六
					dis = room:askForDiscard(naxt, self:objectName(), 1, 1) --一般情况下，AI选择风险更低的弃手牌
				else
					dis = room:askForDiscard(naxt, self:objectName(), 1, 1, true, false)
				end
				if not dis then
					room:loseHp(naxt, damage.damage)
				end
			else
				room:loseHp(naxt, damage.damage)
			end
		end
	end,
	can_trigger = function(self, player)
	    return true--player
	end,
}
if not sgs.Sanguosha:getSkill("by_guanghan") then skills:append(by_guanghan) end

--==小程序神武将==--
--神关羽
wx_shenguanyu = sgs.General(extension_w, "wx_shenguanyu", "god", 5, true)

wxwushen = sgs.CreateOneCardViewAsSkill{
	name = "wxwushen",
	response_or_use = true,
	view_filter = function(self, card)
		if not card:isRed() then return false end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
			slash:addSubcard(card:getEffectiveId())
			slash:deleteLater()
			if card:getSuit() ~= sgs.Card_Heart then return slash:isAvailable(sgs.Self) end
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
		return true --sgs.Slash_IsAvailable(player)
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "slash"
	end,
}
wxwushenBuff = sgs.CreateTargetModSkill{
	name = "wxwushenBuff",
	distance_limit_func = function(self, from, card)
		if from:hasSkill("wxwushen") and card:isKindOf("Slash") and card:getSuit() == sgs.Card_Diamond then
			return 1000
		else
			return 0
		end
	end,
	residue_func = function(self, from, card)
		if from:hasSkill("wxwushen") and card:isKindOf("Slash") and card:getSuit() == sgs.Card_Heart then
			return 1000
		else
			return 0
		end
	end,
}
wx_shenguanyu:addSkill(wxwushen)
if not sgs.Sanguosha:getSkill("wxwushenBuff") then skills:append(wxwushenBuff) end

--神吕蒙
wx_shenlvmeng = sgs.General(extension_w, "wx_shenlvmeng", "god", 3, true)

wx_shenlvmeng:addSkill("shelie")

wxgongxinCard = sgs.CreateSkillCard{
	name = "wxgongxinCard",
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		if not effect.to:isKongcheng() then
			local ids = sgs.IntList()
			for _, card in sgs.qlist(effect.to:getHandcards()) do
				if card:isRed() then
					ids:append(card:getEffectiveId())
				end
			end
			local card_id = room:doGongxin(effect.from, effect.to, ids)
			if (card_id == -1) then return end
			room:showCard(effect.to, card_id)
			local result = room:askForChoice(effect.from, "wxgongxin", "get+put")
			effect.from:removeTag("wxgongxin")
			if result == "get" then
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, effect.from:objectName())
				room:obtainCard(effect.from, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
			else
				effect.from:setFlags("Global_GongxinOperatorr")
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, effect.from:objectName(), nil, "wxgongxin", nil)
				room:moveCardTo(sgs.Sanguosha:getCard(card_id), effect.to, nil, sgs.Player_DrawPile, reason, true)
				effect.from:setFlags("-Global_GongxinOperatorr")
			end
		end
	end,
}
wxgongxin = sgs.CreateZeroCardViewAsSkill{
	name = "wxgongxin",
	view_as = function()
		return wxgongxinCard:clone()
	end,
	enabled_at_play = function(self, target)
		return not target:hasUsed("#wxgongxinCard")
	end,
}
wx_shenlvmeng:addSkill(wxgongxin)


--

--神诸葛亮
  --原版
wx_shenzhugeliang = sgs.General(extension_w, "wx_shenzhugeliang", "god", 3, true)

wxqixing = sgs.CreateTriggerSkill{
	name = "wxqixing",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.AskForPeaches},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		if dying.who:objectName() == player:objectName() and player:getMark("wxqixing_lun") == 0 then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:addPlayerMark(player, "wxqixing_lun")
				room:broadcastSkillInvoke(self:objectName())
				local judge = sgs.JudgeStruct()
				judge.pattern = ".|.|8~13"
				judge.good = true
				judge.play_animation = true
				judge.reason = self:objectName()
				judge.who = player
				room:judge(judge)
				if judge:isGood() or judge.card:getNumber() > 13 then --专门防老六
					room:broadcastSkillInvoke(self:objectName())
					room:recover(player, sgs.RecoverStruct(player))
				end
			end
		end
	end,
}
wx_shenzhugeliang:addSkill(wxqixing)

wxjifengCard = sgs.CreateSkillCard{
	name = "wxjifengCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		local rtg = {}
		for _, t in sgs.qlist(room:getDrawPile()) do
			local trick = sgs.Sanguosha:getCard(t)
			if trick:isKindOf("TrickCard") then
				table.insert(rtg, trick)
			end
		end
		if #rtg == 0 then
			for _, t in sgs.qlist(room:getDiscardPile()) do
				local trick = sgs.Sanguosha:getCard(t)
				if trick:isKindOf("TrickCard") then
					table.insert(rtg, trick)
				end
			end
		end
		local trk = rtg[math.random(1, #rtg)]
		room:obtainCard(source, trk)
	end,
}
wxjifeng = sgs.CreateOneCardViewAsSkill{
	name = "wxjifeng",
	view_filter = function(self, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, card)
		local jf_card = wxjifengCard:clone()
		jf_card:addSubcard(card:getId())
		return jf_card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#wxjifengCard") and not player:isKongcheng()
	end,
}
wx_shenzhugeliang:addSkill(wxjifeng)

wxtianfaCard = sgs.CreateSkillCard{
	name = "wxtianfaCard",
	target_fixed = false,
	mute = true,
	filter = function(self, targets, to_select)
		return #targets < sgs.Self:getMark("&wxFA") and to_select:objectName() ~= sgs.Self:objectName()
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		for _, p in ipairs(targets) do
			room:damage(sgs.DamageStruct("wxtianfa", source, p))
		end
	end,
}
wxtianfaVS = sgs.CreateZeroCardViewAsSkill{
    name = "wxtianfa",
    view_as = function()
		return wxtianfaCard:clone()
	end,
	response_pattern = "@@wxtianfa",
}
wxtianfa = sgs.CreateTriggerSkill{
	name = "wxtianfa",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.EventPhaseEnd, sgs.EventPhaseChanging},
	view_as_skill = wxtianfaVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.from and use.from:objectName() == player:objectName() then
				if use.card and use.card:isKindOf("TrickCard") and player:getPhase() == sgs.Player_Play then
					if player:getMark(self:objectName()) == 0
					or player:getMark(self:objectName()) == 2 then
						room:setPlayerMark(player, self:objectName(), 1) --第奇数张
					elseif player:getMark(self:objectName()) == 1 then
						room:setPlayerMark(player, self:objectName(), 2) --第偶数张
						if player:hasSkill(self:objectName()) then
							room:sendCompulsoryTriggerLog(player, self:objectName())
							room:broadcastSkillInvoke(self:objectName(), 1)
							player:gainMark("&wxFA", 1)
						end
					end
				end
				if use.card and use.card:getSkillName() == "wxtianfa" then
					room:broadcastSkillInvoke(self:objectName(), 2)
				end
			end
		elseif event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Play then
			room:setPlayerMark(player, self:objectName(), 0)
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			if player:getMark("&wxFA") > 0 then
				if player:hasSkill(self:objectName()) then
					room:askForUseCard(player, "@@wxtianfa", "@wxtianfa-card")
				end
				player:loseAllMarks("&wxFA")
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
wx_shenzhugeliang:addSkill(wxtianfa)

  --威力加强版
wx_shenzhugeliangEX = sgs.General(extension_w, "wx_shenzhugeliangEX", "god", 3, true)

wxqixingEX = sgs.CreateTriggerSkill{
	name = "wxqixingEX",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.AskForPeaches},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		if dying.who:objectName() == player:objectName() and player:getMark("wxqixingEX_lun") == 0 then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:addPlayerMark(player, "wxqixingEX_lun")
				room:broadcastSkillInvoke(self:objectName())
				local judge = sgs.JudgeStruct()
				judge.pattern = ".|.|8~13"
				judge.good = true
				judge.play_animation = true
				judge.reason = self:objectName()
				judge.who = player
				room:judge(judge)
				if judge:isGood() or judge.card:getNumber() > 13 then --专门防老六
					room:broadcastSkillInvoke(self:objectName())
					local recover = math.min(1 - player:getHp(), player:getMaxHp() - player:getHp())
					room:recover(player, sgs.RecoverStruct(player, nil, recover))
				end
			end
		end
	end,
}
wx_shenzhugeliangEX:addSkill(wxqixingEX)

wxjifengEXCard = sgs.CreateSkillCard{
	name = "wxjifengEXCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "wxjifengEX_zuiandfa")
		local rtg = {}
		for _, t in sgs.qlist(room:getDrawPile()) do
			local trick = sgs.Sanguosha:getCard(t)
			if trick:isKindOf("TrickCard") then
				table.insert(rtg, trick)
			end
		end
		if #rtg == 0 then
			for _, t in sgs.qlist(room:getDiscardPile()) do
				local trick = sgs.Sanguosha:getCard(t)
				if trick:isKindOf("TrickCard") then
					table.insert(rtg, trick)
				end
			end
		end
		local trk = rtg[math.random(1, #rtg)]
		room:broadcastSkillInvoke("wxjifengEX")
		room:obtainCard(source, trk)
	end,
}
wxjifengEX = sgs.CreateOneCardViewAsSkill{
	name = "wxjifengEX",
	view_filter = function(self, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, card)
		local jf_card = wxjifengEXCard:clone()
		jf_card:addSubcard(card:getId())
		return jf_card
	end,
	enabled_at_play = function(self, player)
		return player:getMark("wxjifengEX_zuiandfa") > 0 and not player:isKongcheng()
	end,
}
wxqixingEX_zuiandfa = sgs.CreateTriggerSkill{
	name = "wxqixingEX_zuiandfa",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			local z, f = player:getMark("&exZUI"), player:getMark("&exFA")
			local zaf = z + f
			room:setPlayerMark(player, "wxjifengEX_zuiandfa", zaf+1)
			if player:hasSkill("wxjifengEX") then
				room:setPlayerMark(player, "&wxjifengEX_add", zaf) --方便玩家查看用
			end
			if z > 0 then player:loseAllMarks("&exZUI") end
			if f > 0 then player:loseAllMarks("&exFA") end
		elseif event == sgs.EventPhaseEnd then
			room:setPlayerMark(player, "wxjifengEX_zuiandfa", 0)
			room:setPlayerMark(player, "&wxjifengEX_add", 0)
		end
	end,
	can_trigger = function(self, player)
		return player:getPhase() == sgs.Player_Play
	end,
}
wx_shenzhugeliangEX:addSkill(wxjifengEX)
if not sgs.Sanguosha:getSkill("wxqixingEX_zuiandfa") then skills:append(wxqixingEX_zuiandfa) end

wxtianzuiEXCard = sgs.CreateSkillCard{
	name = "wxtianzuiEXCard",
	target_fixed = false,
	mute = true,
	filter = function(self, targets, to_select, player)
		return #targets < sgs.Self:getMark("&exZUI") and to_select:objectName() ~= sgs.Self:objectName()
		and not to_select:isAllNude() and player:canDiscard(to_select, "hej")
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		for _, p in ipairs(targets) do
			local card = room:askForCardChosen(source, p, "hej", "wxtianzuiEX", false, sgs.Card_MethodDiscard)
			room:throwCard(card, p, source)
		end
	end,
}
wxtianzuiEX = sgs.CreateZeroCardViewAsSkill{
    name = "wxtianzuiEX",
    view_as = function()
		return wxtianzuiEXCard:clone()
	end,
	response_pattern = "@@wxtianzuiEX",
}
wx_shenzhugeliangEX:addSkill(wxtianzuiEX)

wxtianfaEXCard = sgs.CreateSkillCard{
	name = "wxtianfaEXCard",
	target_fixed = false,
	mute = true,
	filter = function(self, targets, to_select)
		return #targets < sgs.Self:getMark("&exFA") and to_select:objectName() ~= sgs.Self:objectName()
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		for _, p in ipairs(targets) do
			room:damage(sgs.DamageStruct("wxtianfaEX", source, p, 1, sgs.DamageStruct_Thunder))
		end
	end,
}
wxtianfaEX = sgs.CreateZeroCardViewAsSkill{
    name = "wxtianfaEX",
    view_as = function()
		return wxtianfaEXCard:clone()
	end,
	response_pattern = "@@wxtianfaEX",
}
wx_shenzhugeliangEX:addSkill(wxtianfaEX)

wx_ZUIandFA = sgs.CreateTriggerSkill{
	name = "wx_ZUIandFA",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.EventPhaseEnd, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.from and use.from:objectName() == player:objectName() then
				if use.card and use.card:isKindOf("TrickCard") and player:getPhase() == sgs.Player_Play then
					if player:getMark(self:objectName()) == 0 or player:getMark(self:objectName()) == 2 then
						room:setPlayerMark(player, self:objectName(), 1) --第奇数张
						if player:hasSkill("wxtianzuiEX") then
							room:sendCompulsoryTriggerLog(player, "wxtianzuiEX")
							room:broadcastSkillInvoke("wxtianzuiEX", 1)
							player:gainMark("&exZUI", 1)
						end
					elseif player:getMark(self:objectName()) == 1 then
						room:setPlayerMark(player, self:objectName(), 2) --第偶数张
						if player:hasSkill("wxtianfaEX") then
							room:sendCompulsoryTriggerLog(player, "wxtianfaEX")
							room:broadcastSkillInvoke("wxtianfaEX", 1)
							player:gainMark("&exFA", 1)
						end
					end
				end
				if use.card and use.card:getSkillName() == "wxtianzuiex" then
					room:broadcastSkillInvoke("wxtianzuiEX", 2)
				end
				if use.card and use.card:getSkillName() == "wxtianfaex" then
					room:broadcastSkillInvoke("wxtianfaEX", 2)
				end
			end
		elseif event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Play then
			room:setPlayerMark(player, self:objectName(), 0)
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			if player:getMark("&exZUI") > 0 and player:hasSkill("wxtianzuiEX") then
				room:askForUseCard(player, "@@wxtianzuiEX", "@wxtianzuiEX-card")
			end
			if player:getMark("&exFA") > 0 and player:hasSkill("wxtianfaEX") then
				room:askForUseCard(player, "@@wxtianfaEX", "@wxtianfaEX-card")
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("wx_ZUIandFA") then skills:append(wx_ZUIandFA) end


--

--==极略三国神武将==--
--神黄忠
jlsg_shenhuangzhong = sgs.General(extension_jl, "jlsg_shenhuangzhong", "god", 4, true)

jlsgliegong = sgs.CreateViewAsSkill{
	name = "jlsgliegong",
	n = --[[4]]5, --考虑一手无花色
	view_filter = function(self, selected, to_select)
		for _, c in sgs.list(selected) do
			if c:getSuit() == to_select:getSuit() then
			return false end
		end
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards >= 1 and #cards <= 5 then
			local cardA = cards[1]
			local suit = cardA:getSuit()
			local number = cardA:getNumber()
			local lg_slash
			--[[if #cards == 1 then
				lg_slash = sgs.Sanguosha:cloneCard("fire_slash", suit, number)
			else
				lg_slash = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_NoSuit, 0)
			end]]
			lg_slash = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, -1)
			for _, c in ipairs(cards) do
				lg_slash:addSubcard(c)
			end
			lg_slash:setSkillName(self:objectName())
			return lg_slash
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return ((not player:isWounded() and player:getMark(self:objectName()) < 1)
		or (player:isWounded() and player:getMark(self:objectName()) < 2)) and not player:isKongcheng()
	end,
}
jlsgliegongDR = sgs.CreateTargetModSkill{
	name = "jlsgliegongDR",
	pattern = "Slash",
	distance_limit_func = function(self, player, card)
		if card:getSkillName() == "jlsgliegong" then
			return 1000
		else
			return 0
		end
	end,
	residue_func = function(self, player, card)
		if card:getSkillName() == "jlsgliegong" then
			return 1000
		else
			return 0
		end
	end,
}
Table2IntList = function(theTable)
	local result = sgs.IntList()
	for i = 1, #theTable, 1 do
		result:append(theTable[i])
	end
	return result
end
jlsgliegongBfs = sgs.CreateTriggerSkill{
	name = "jlsgliegongBfs",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.TargetSpecified, sgs.CardUsed, sgs.ConfirmDamage, sgs.Damage, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use, damage = data:toCardUse(), data:toDamage()
		if event == sgs.TargetSpecified then --保底强命
			if use.card:isKindOf("Slash") and use.card:getSkillName() == "jlsgliegong" and use.card:subcardsLength() >= 1 then
				room:sendCompulsoryTriggerLog(player, "jlsgliegong")
				local jink_table = sgs.QList2Table(player:getTag("Jink_" .. use.card:toString()):toIntList())
				local index = 1
				for _, p in sgs.qlist(use.to) do
					if not player:isAlive() then break end
					local _data = sgs.QVariant()
					_data:setValue(p)
					jink_table[index] = 0
					index = index + 1
				end
				local jink_data = sgs.QVariant()
				jink_data:setValue(Table2IntList(jink_table))
				player:setTag("Jink_" .. use.card:toString(), jink_data)
			end
		elseif event == sgs.CardUsed then --制衡，无中无中生有
			if use.card:isKindOf("Slash") and use.card:getSkillName() == "jlsgliegong" then
				room:addPlayerMark(player, "jlsgliegong") --记录使用次数
				if use.card:subcardsLength() >= 2 then
					room:sendCompulsoryTriggerLog(player, "jlsgliegong")
					room:drawCards(player, 3, "jlsgliegong")
				end
			end
		elseif event == sgs.ConfirmDamage then --矢贯坚石，劲冠三军！
			if damage.card and damage.card:isKindOf("Slash") and damage.card:getSkillName() == "jlsgliegong" and damage.card:subcardsLength() >= 3 then
				room:sendCompulsoryTriggerLog(player, "jlsgliegong")
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		elseif event == sgs.Damage then --♥♠♦♣吾虽年迈，箭矢犹锋！
			if damage.card and damage.card:isKindOf("Slash") and damage.card:getSkillName() == "jlsgliegong" and damage.card:subcardsLength() >= 4
			and damage.to and damage.to:isAlive() then
				room:sendCompulsoryTriggerLog(player, "jlsgliegong")
				local loseskill = {}
				for _, skill in sgs.qlist(damage.to:getSkillList()) do
					if skill:objectName() ~= "mobileGOD_SkinChange_Button" and skill:objectName() ~= "GOD_changeFullSkin_Button" and skill:objectName() ~= "wmzgl_SkinChange_Button"
					and skill:objectName() ~= "f_mobile_efs_egg" and skill:objectName() ~= "f_mobile_efs_flower" then
						table.insert(loseskill, skill:objectName())
					end
				end
				if #loseskill > 0 then
					local lose = loseskill[math.random(1, #loseskill)]
					room:detachSkillFromPlayer(damage.to, lose)
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(player, "jlsgliegong", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
jlsg_shenhuangzhong:addSkill(jlsgliegong)
if not sgs.Sanguosha:getSkill("jlsgliegongDR") then skills:append(jlsgliegongDR) end
if not sgs.Sanguosha:getSkill("jlsgliegongBfs") then skills:append(jlsgliegongBfs) end





--

--神黄盖
jlsg_shenhuanggai = sgs.General(extension_jl, "jlsg_shenhuanggai", "god", 6, true)

jlsglianti = sgs.CreateTriggerSkill{
	name = "jlsglianti",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.ChainStateChange, sgs.Damaged, sgs.EventPhaseChanging, sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:hasSkill(self:objectName()) and not player:isChained() then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				player:speak("弓我还没得，不可能铁索，一体力我都没得~")
				room:broadcastSkillInvoke(self:objectName(), 1)
				room:setPlayerChained(player)
			end
		elseif event == sgs.ChainStateChange then
			if player:hasSkill(self:objectName()) and player:isChained() then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				player:speak("弓我还没得，不可能铁索，一体力我都没得~")
				room:broadcastSkillInvoke(self:objectName(), 1)
				return true
			end
		elseif event == sgs.Damaged then
			local damage = data:toDamage()
			local jlsgshg = room:getCurrent()
			if jlsgshg:hasSkill(self:objectName()) then
				if damage.to and damage.to:isAlive() and damage.to:objectName() == player:objectName() and player:objectName() ~= jlsgshg:objectName()
				and damage.nature ~= sgs.DamageStruct_Normal and not player:hasFlag(self:objectName()) then
					room:setPlayerFlag(player, self:objectName())
					room:sendCompulsoryTriggerLog(jlsgshg, self:objectName())
					jlsgshg:speak("好多的牌，摸 好多的牌哦，全局是闪哎~")
					room:broadcastSkillInvoke(self:objectName(), 2)
					--[[if damage.from:isAlive() then
						room:damage(sgs.DamageStruct(self:objectName(), damage.from, player, damage.damage, damage.nature))
					else]]
						room:damage(sgs.DamageStruct(self:objectName(), nil, player, damage.damage, damage.nature))
					--end
				end
			end
			if damage.to and damage.to:isAlive() and damage.to:objectName() == player:objectName() and player:hasSkill(self:objectName())
			and damage.nature ~= sgs.DamageStruct_Normal then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				local spk = math.random(0,2)
				if spk == 0 then player:speak("苦肉一次，弓无闪有，弓啊在哪")
				elseif spk == 1 then player:speak("苦肉无数，苦了没奶")
				elseif spk == 2 then player:speak("还拿桃哦，你自己打~")
				end
				room:broadcastSkillInvoke(self:objectName(), 3)
				room:addPlayerMark(player, "&jlsglianti")
				room:loseMaxHp(player, 1)
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag(self:objectName()) then
					room:setPlayerFlag(p, "-jlsglianti")
				end
			end
		elseif event == sgs.DrawNCards then
			local room = player:getRoom()
			local n = player:getMark("&jlsglianti")
			local count = data:toInt() + n
			data:setValue(count)
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
jlsgliantiMXC = sgs.CreateMaxCardsSkill{
	name = "jlsgliantiMXC",
	extra_func = function(self, player)
		local n = player:getMark("&jlsglianti")
		if n > 0 then
			return n
		else
			return 0
		end
	end,
}
jlsg_shenhuanggai:addSkill(jlsglianti)
if not sgs.Sanguosha:getSkill("jlsgliantiMXC") then skills:append(jlsgliantiMXC) end

jlsgyanlieCard = sgs.CreateSkillCard{
	name = "jlsgyanlieCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		local n = self:subcardsLength()
		if #targets == n then return false end
		return to_select:objectName() ~= sgs.Self:objectName()
	end,
	feasible = function(self, targets)
		return #targets == self:subcardsLength()
	end,
	on_use = function(self, room, source, targets)
	    local useto = sgs.SPlayerList()
		for _, p in pairs(targets) do
			useto:append(p)
		end
		local iron_chain = sgs.Sanguosha:cloneCard("iron_chain", sgs.Card_NoSuit, 0)
		iron_chain:setSkillName("jlsgyanlie")
		room:useCard(sgs.CardUseStruct(iron_chain, source, useto), false)
		local yanlieTargets = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:isChained() then
				yanlieTargets:append(p)
			end
		end
		if yanlieTargets:isEmpty() then return false end
		local yanlieTarget
		if yanlieTargets:length() == 1 then
			yanlieTarget = yanlieTargets:first()
		else
			yanlieTarget = room:askForPlayerChosen(source, yanlieTargets, "jlsgyanlie")
		end
		local spk2 = math.random(1,4) --if math.random() <= 0.5 then
		if spk2 <= 2 then
			if spk2 == 1 then
				source:speak("原来他们敢打是看你胆大摸完")
			elseif spk2 == 2 then
				source:speak("是苦肉的我拿命给她挡的~")
			end
			room:broadcastSkillInvoke("jlsgyanlie", 1)
		else
			source:speak("没诸葛拿的，不哭我们投哦~")
			room:broadcastSkillInvoke("jlsgyanlie", 2)
		end
		room:damage(sgs.DamageStruct("jlsgyanlie", source, yanlieTarget, 1, sgs.DamageStruct_Fire))
	end,
}
jlsgyanlie = sgs.CreateViewAsSkill{
    name = "jlsgyanlie",
	n = 999,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local ylcard = jlsgyanlieCard:clone()
			for _, card in pairs(cards) do
				ylcard:addSubcard(card)
			end
			ylcard:setSkillName(self:objectName())
			return ylcard
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng() and not player:hasUsed("#jlsgyanlieCard")
	end,
}
jlsg_shenhuanggai:addSkill(jlsgyanlie)



--

--神华佗
jlsg_shenhuatuo = sgs.General(extension_jl, "jlsg_shenhuatuo", "god", 3, true)

jlsgyuanhua = sgs.CreateTriggerSkill{
	name = "jlsgyuanhua",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.EventAcquireSkill, sgs.EventLoseSkill, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart and player:hasSkill(self:objectName()) then --防止手气卡刷桃卡BUG
			room:setPlayerMark(player, self:objectName(), 1)
		elseif event == sgs.EventAcquireSkill then
			if data:toString() == self:objectName() then
				room:setPlayerMark(player, self:objectName(), 1)
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == self:objectName() then
				room:setPlayerMark(player, self:objectName(), 0)
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceHand
			and player:hasSkill(self:objectName()) and player:getMark(self:objectName()) > 0 then
				for _, id in sgs.qlist(move.card_ids) do
					local peach = sgs.Sanguosha:getCard(id)
					if peach:isKindOf("Peach") then
						room:sendCompulsoryTriggerLog(player, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						if player:isWounded() then
							room:recover(player, sgs.RecoverStruct(player))
						end
						room:drawCards(player, 2, self:objectName())
						player:addToPile(self:objectName(), peach)
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
jlsg_shenhuatuo:addSkill(jlsgyuanhua)

local function hasPeach(player)
	if player:isDead() then return false end
	local hP = false
	for _, c in sgs.qlist(player:getHandcards()) do
		if c:isKindOf("Peach") then
			hP = true
			break
		end
	end
	return hP
end
jlsgguiyuanCard = sgs.CreateSkillCard{
    name = "jlsgguiyuanCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
	    room:loseHp(source, 1)
		if not source:isAlive() then return false end
		for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			if p:isKongcheng() or not hasPeach(p) then continue end
			if p:getState() == "robot" then
				local gyg = {}
				for _, ph in sgs.qlist(p:getHandcards()) do
					if ph:isKindOf("Peach") then
					table.insert(gyg, ph) end
				end
				local ph_card = gyg[math.random(1, #gyg)]
				source:obtainCard(ph_card)
			else
				local data = sgs.QVariant()
				data:setValue(p)
				local ph_card = room:askForCard(p, "peach", "@jlsgguiyuan-wtgy:" .. source:objectName(), data, sgs.Card_MethodNone)
				if ph_card then
					source:obtainCard(ph_card)
				else
					local gyg = {}
					for _, ph in sgs.qlist(p:getHandcards()) do
						if ph:isKindOf("Peach") then
						table.insert(gyg, ph) end
					end
					local ph_card = gyg[math.random(1, #gyg)]
					source:obtainCard(ph_card)
				end
			end
		end
		local rpg = {}
		for _, ph in sgs.qlist(room:getDrawPile()) do
			local tz = sgs.Sanguosha:getCard(ph)
			if tz:isKindOf("Peach") then
				table.insert(rpg, tz)
			end
		end
		for _, ph in sgs.qlist(room:getDiscardPile()) do
			local tz = sgs.Sanguosha:getCard(ph)
			if tz:isKindOf("Peach") then
				table.insert(rpg, tz)
			end
		end
		if #rpg > 0 then
			local phc = rpg[math.random(1, #rpg)]
			room:obtainCard(source, phc)
		end
	end,
}
jlsgguiyuan = sgs.CreateZeroCardViewAsSkill{
    name = "jlsgguiyuan",
    view_as = function()
		return jlsgguiyuanCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#jlsgguiyuanCard")
	end,
}
jlsg_shenhuatuo:addSkill(jlsgguiyuan)

jlsgchongsheng = sgs.CreateTriggerSkill{
	name = "jlsgchongsheng",
	frequency = sgs.Skill_Limited,
	limit_mark = "@jlsgchongsheng",
	events = {sgs.Dying},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		if room:askForSkillInvoke(player, self:objectName(), data) then
			player:loseMark("@jlsgchongsheng")
			room:broadcastSkillInvoke(self:objectName())
			room:doSuperLightbox("jlsg_shenhuatuo", self:objectName())
			local gy = player:getPile("jlsgyuanhua"):length()
			if gy < 1 then gy = 1 end
			room:setPlayerProperty(dying.who, "maxhp", sgs.QVariant(gy))
			local recover = dying.who:getMaxHp() - dying.who:getHp()
			if recover > 0 then --防极端情况-1
				room:recover(dying.who, sgs.RecoverStruct(player, nil, recover))
			end
			if dying.who:getState() == "robot" or room:askForSkillInvoke(dying.who, "@jlsgchongsheng-generalChanged", data) then
				local all_generals = sgs.Sanguosha:getLimitedGeneralNames()
				local rv_generals = {}
				for _, name in ipairs(all_generals) do
					local general = sgs.Sanguosha:getGeneral(name)
					if general:getKingdom() == dying.who:getKingdom() then
						table.insert(rv_generals, name)
					end
				end
				if #rv_generals == 0 then return false end --防极端情况-2
				local rv_general, rv = {}, 3
				while rv > 0 and #rv_generals > 0 do
					local cs = rv_generals[math.random(1, #rv_generals)]
					table.insert(rv_general, cs)
					table.removeOne(rv_generals, cs)
					rv = rv - 1
				end
				local generals = table.concat(rv_general, "+")
				local general = room:askForGeneral(dying.who, generals)
				room:changeHero(dying.who, general, false, false, false, true)
				if dying.who:getMaxHp() ~= gy then room:setPlayerProperty(dying.who, "maxhp", sgs.QVariant(gy)) end
				if dying.who:getHp() ~= gy then room:setPlayerProperty(dying.who, "hp", sgs.QVariant(gy)) end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill(self:objectName()) and player:getMark("@jlsgchongsheng") > 0
	end,
}
jlsg_shenhuatuo:addSkill(jlsgchongsheng)
--

--==线下神武将==--
--神姜维
ofl_shenjiangwei = sgs.General(extension_ofl, "ofl_shenjiangwei", "god", 4, true)

ofl_shenjiangwei:addSkill("tytianren")

ofljiufa = sgs.CreateTriggerSkill{
    name = "ofljiufa",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardFinished, sgs.CardResponded},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local card = nil
		if event == sgs.CardFinished then
			card = data:toCardUse().card
		else
			local response = data:toCardResponse()
			card = response.m_card
		end
		if card and not card:isKindOf("SkillCard") and not (card:isVirtualCard() and card:subcardsLength() == 0) then
			if player:getPile(self:objectName()):length() == 0 then
				if (player:getState() == "online" and room:askForSkillInvoke(player, self:objectName(), data))
				or (player:getState() == "robot" and (card:isKindOf("BasicCard") or card:isNDTrick())) then
					if player:getState() == "online" then
						room:broadcastSkillInvoke(self:objectName())
						player:addToPile(self:objectName(), card)
					else
						if room:askForSkillInvoke(player, self:objectName(), data) then
							room:broadcastSkillInvoke(self:objectName())
							player:addToPile(self:objectName(), card)
						end
					end
				end
			else
				local can_add = true
				for _, jf in sgs.qlist(player:getPile(self:objectName())) do
					local jfc = sgs.Sanguosha:getCard(jf)
					if jfc:objectName() == card:objectName() then
						can_add = false
					end
				end
				if can_add then
					if (player:getState() == "online" and room:askForSkillInvoke(player, self:objectName(), data))
					or (player:getState() == "robot" and (card:isKindOf("BasicCard") or card:isNDTrick())) then
						room:broadcastSkillInvoke(self:objectName())
						player:addToPile(self:objectName(), card)
					end
				end
			end
			if player:getPile(self:objectName()):length() < 9 then return false end
			local ofljiufa_objectName = {}
			for _, jf in sgs.qlist(player:getPile(self:objectName())) do
				local jfc = sgs.Sanguosha:getCard(jf)
				if table.contains(ofljiufa_objectName, jfc:objectName()) then continue end
				table.insert(ofljiufa_objectName, jfc:objectName())
			end
			if #ofljiufa_objectName >= 9 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local dummy = sgs.Sanguosha:cloneCard("slash")
				dummy:addSubcards(player:getPile(self:objectName()))
				room:throwCard(dummy, player, player)
				local card_ids = room:getNCards(9)
				room:fillAG(card_ids)
				local to_get = sgs.IntList()
				local to_throw = sgs.IntList()
				local card_ids_ = card_ids
				for _, i in sgs.qlist(card_ids_) do --第一步：剔除所有点数不重复的牌
					local num = sgs.Sanguosha:getCard(i):getNumber()
					if num == 1 then --不考虑范围不在1~13之内的点数了
						room:addPlayerMark(player, "ofljiufaRPTA")
					elseif num == 2 then
						room:addPlayerMark(player, "ofljiufaRPT2")
					elseif num == 3 then
						room:addPlayerMark(player, "ofljiufaRPT3")
					elseif num == 4 then
						room:addPlayerMark(player, "ofljiufaRPT4")
					elseif num == 5 then
						room:addPlayerMark(player, "ofljiufaRPT5")
					elseif num == 6 then
						room:addPlayerMark(player, "ofljiufaRPT6")
					elseif num == 7 then
						room:addPlayerMark(player, "ofljiufaRPT7")
					elseif num == 8 then
						room:addPlayerMark(player, "ofljiufaRPT8")
					elseif num == 9 then
						room:addPlayerMark(player, "ofljiufaRPT9")
					elseif num == 10 then
						room:addPlayerMark(player, "ofljiufaRPT10")
					elseif num == 11 then
						room:addPlayerMark(player, "ofljiufaRPTJ")
					elseif num == 12 then
						room:addPlayerMark(player, "ofljiufaRPTQ")
					elseif num == 13 then
						room:addPlayerMark(player, "ofljiufaRPTK")
					end
				end
				for i = 0, 150 do --果然，不加这句必定会有BUG，写“涉猎”代码的前辈yyds
					for _, i in sgs.qlist(card_ids_) do
						local num = sgs.Sanguosha:getCard(i):getNumber()
						if (num == 1 and player:getMark("ofljiufaRPTA") <= 1) or (num == 2 and player:getMark("ofljiufaRPT2") <= 1) or (num == 3 and player:getMark("ofljiufaRPT3") <= 1)
						or (num == 4 and player:getMark("ofljiufaRPT4") <= 1) or (num == 5 and player:getMark("ofljiufaRPT5") <= 1) or (num == 6 and player:getMark("ofljiufaRPT6") <= 1)
						or (num == 7 and player:getMark("ofljiufaRPT7") <= 1) or (num == 8 and player:getMark("ofljiufaRPT8") <= 1) or (num == 9 and player:getMark("ofljiufaRPT9") <= 1)
						or (num == 10 and player:getMark("ofljiufaRPT10") <= 1) or (num == 11 and player:getMark("ofljiufaRPTJ") <= 1) or (num == 12 and player:getMark("ofljiufaRPTQ") <= 1)
						or (num == 13 and player:getMark("ofljiufaRPTK") <= 1) then
							card_ids:removeOne(i)
							room:takeAG(nil, i, false)
							to_throw:append(i)
						end
					end
				end
				room:setPlayerMark(player, "ofljiufaRPTA", 0)
				room:setPlayerMark(player, "ofljiufaRPT2", 0)
				room:setPlayerMark(player, "ofljiufaRPT3", 0)
				room:setPlayerMark(player, "ofljiufaRPT4", 0)
				room:setPlayerMark(player, "ofljiufaRPT5", 0)
				room:setPlayerMark(player, "ofljiufaRPT6", 0)
				room:setPlayerMark(player, "ofljiufaRPT7", 0)
				room:setPlayerMark(player, "ofljiufaRPT8", 0)
				room:setPlayerMark(player, "ofljiufaRPT9", 0)
				room:setPlayerMark(player, "ofljiufaRPT10", 0)
				room:setPlayerMark(player, "ofljiufaRPTJ", 0)
				room:setPlayerMark(player, "ofljiufaRPTQ", 0)
				room:setPlayerMark(player, "ofljiufaRPTK", 0)
				while not card_ids:isEmpty() do --第二步：从剩余的牌中选择点数不同的牌各一张
					local card_id = room:askForAG(player, card_ids, false, self:objectName())
					card_ids:removeOne(card_id)
					to_get:append(card_id)
					local card = sgs.Sanguosha:getCard(card_id)
					local number = card:getNumber()
					room:takeAG(player, card_id, false)
					local _card_ids = card_ids
					for i = 0, 150 do
						for _, id in sgs.qlist(_card_ids) do
							local c = sgs.Sanguosha:getCard(id)
							if c:getNumber() == number then
								card_ids:removeOne(id)
								room:takeAG(nil, id, false)
								to_throw:append(id)
							end
						end
					end
				end
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				if not to_get:isEmpty() then
					dummy:addSubcards(getCardList(to_get))
					player:obtainCard(dummy)
				end
				dummy:clearSubcards()
				if not to_throw:isEmpty() then
					dummy:addSubcards(getCardList(to_throw))
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), "")
					room:throwCard(dummy, reason, nil)
				end
				dummy:deleteLater()
				room:clearAG()
			end
		end
	end,
}
ofl_shenjiangwei:addSkill(ofljiufa)

--虚拟火【杀】
oflpingxiangFireSlashCard = sgs.CreateSkillCard{
	name = "oflpingxiangFireSlashCard",
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return sgs.Self:canSlash(to_select, nil)
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local fs = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_NoSuit, 0)
		fs:setSkillName("oflpingxiang")
		local use = sgs.CardUseStruct()
		use.card = fs
		use.from = source
		for _, p in pairs(targets) do
			use.to:append(p)
		end
		room:useCard(use)
	end,
}
oflpingxiangFireSlash = sgs.CreateZeroCardViewAsSkill{
	name = "oflpingxiangFireSlash",
	view_as = function()
		return oflpingxiangFireSlashCard:clone()
	end,
	enabled_at_play = function()
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@oflpingxiangFireSlash"
	end,
}
oflpingxiangCard = sgs.CreateSkillCard{ --全扩最燃大招
	name = "oflpingxiangCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@oflpingxiang")
		room:loseMaxHp(source, 9)
		room:doSuperLightbox("ty_shenjiangwei", "oflpingxiang")
		local n = 0 --记录以此法使用虚拟火杀的次数
		while n < 9 and not source:hasFlag("oflpingxiangFSstop") and source:isAlive() do
			if room:askForUseCard(source, "@@oflpingxiangFireSlash", "@oflpingxiangFireSlash") then
				n = n + 1
			else
				room:setPlayerFlag(source, "oflpingxiangFSstop")
			end
		end
		if source:hasFlag("oflpingxiangFSstop") then room:setPlayerFlag(source, "-oflpingxiangFSstop") end
		if source:hasSkill("ofljiufa") then
			room:detachSkillFromPlayer(source, "ofljiufa")
		end
		room:addPlayerMark(source, "typingxiangMaxCards")
	end,
}
oflpingxiangVS = sgs.CreateZeroCardViewAsSkill{
	name = "oflpingxiang",
	view_as = function()
		return oflpingxiangCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@oflpingxiang") > 0 and player:getMaxHp() > 9
	end,
}
oflpingxiang = sgs.CreateTriggerSkill{
	name = "oflpingxiang",
	frequency = sgs.Skill_Limited,
	limit_mark = "@oflpingxiang",
	view_as_skill = oflpingxiangVS,
	on_trigger = function()
	end,
}
ofl_shenjiangwei:addSkill(oflpingxiang)
if not sgs.Sanguosha:getSkill("oflpingxiangFireSlash") then skills:append(oflpingxiangFireSlash) end


--

--新神马超
ofl_shenmachao = sgs.General(extension_ofl, "ofl_shenmachao", "god", 4, true)

oflshouliGMS = sgs.CreateTriggerSkill{
	name = "oflshouliGMS",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:sendCompulsoryTriggerLog(player, "oflshouli")
		room:broadcastSkillInvoke("oflshouli")
		for _, m in sgs.qlist(room:getOtherPlayers(player)) do
			local JorL = math.random(0,1)
			if JorL == 0 then
				m:gainMark("&oflshouli_JUN", 1)
			else
				m:gainMark("&oflshouli_LI", 1)
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("oflshouli")
	end,
}
if not sgs.Sanguosha:getSkill("oflshouliGMS") then skills:append(oflshouliGMS) end
--主动使用【杀】
oflshouliCard = sgs.CreateSkillCard{
	name = "oflshouliCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
	    return to_select:objectName() ~= sgs.Self:objectName() and to_select:getMark("&oflshouli_JUN") > 0
	end,
	on_use = function(self, room, source, targets)
		room:addPlayerMark(source, "oflshouliSlash-Clear")
		local nmml = targets[1]
		local JUN = nmml:getMark("&oflshouli_JUN")
		local last, naxt
		for _, p in sgs.qlist(room:getOtherPlayers(nmml)) do
			if p:getNextAlive():objectName() == nmml:objectName() then --找到上家
				last = p
			end
		end
		naxt = nmml:getNextAlive() --下家
		local choice = room:askForChoice(source, "oflshouli", "JtoL+JtoN")
		if choice == "JtoL" then
			nmml:loseAllMarks("&oflshouli_JUN")
			last:gainMark("&oflshouli_JUN", JUN)
		elseif choice == "JtoN" then
			nmml:loseAllMarks("&oflshouli_JUN")
			naxt:gainMark("&oflshouli_JUN", JUN)
		end
		room:askForUseCard(source, "@@oflshouliSlash!", "@oflshouli_useSlash")
	end,
}
oflshouli = sgs.CreateZeroCardViewAsSkill{
	name = "oflshouli",
	view_as = function()
		return oflshouliCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("oflshouliSlash-Clear") == 0
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "slash"
	end,
}
--【杀】技能卡（使用）
oflshouliSlashCard = sgs.CreateSkillCard{
	name = "oflshouliSlashCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and sgs.Self:canSlash(to_select, nil, false)
	end,
	on_use = function(self, room, source, targets)
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("oflshouli")
		local use = sgs.CardUseStruct()
		use.card = slash
		use.from = source
		for _, p in pairs(targets) do
			use.to:append(p)
		end
		room:useCard(use)
	end,
}
oflshouliSlash = sgs.CreateZeroCardViewAsSkill{
	name = "oflshouliSlash",
	view_as = function()
		return oflshouliSlashCard:clone()
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@oflshouliSlash")
	end,
}
oflshouliSlashMax = sgs.CreateTargetModSkill{
	name = "oflshouliSlashMax",
	residue_func = function(self, player, card)
		if card:isKindOf("Slash") and card:getSkillName() == "oflshouli" then
			return 1000
		else
			return 0
		end
	end,
}
--使用/打出【杀/闪】以响应需求
oflshouliTrigger = sgs.CreateTriggerSkill{
	name = "oflshouliTrigger",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardAsked},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local pattern = data:toStringList()[1]
		if (pattern == "slash" or pattern == "jink") then
			if pattern == "slash" and player:getMark("oflshouliSlash-Clear") == 0 then
				local MA = sgs.SPlayerList()
				for _, m in sgs.qlist(room:getOtherPlayers(player)) do
					if m:getMark("&oflshouli_JUN") > 0 then
						MA:append(m)
					end
				end
				if MA:isEmpty() then return false end
				if room:askForSkillInvoke(player, "oflshouli", data) then
					room:addPlayerMark(player, "oflshouliSlash-Clear")
					local nmml = room:askForPlayerChosen(player, MA, "oflshouli", "oflshouli_JT")
					if nmml then
						local JUN = nmml:getMark("&oflshouli_JUN")
						local last, naxt
						for _, p in sgs.qlist(room:getOtherPlayers(nmml)) do
							if p:getNextAlive():objectName() == nmml:objectName() then
								last = p
							end
						end
						naxt = nmml:getNextAlive()
						local choice = room:askForChoice(player, "oflshouli", "JtoL+JtoN")
						room:broadcastSkillInvoke("oflshouli")
						if choice == "JtoL" then
							nmml:loseAllMarks("&oflshouli_JUN")
							last:gainMark("&oflshouli_JUN", JUN)
						elseif choice == "JtoN" then
							nmml:loseAllMarks("&oflshouli_JUN")
							naxt:gainMark("&oflshouli_JUN", JUN)
						end
						local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
						slash:setSkillName("oflshouli")
						room:provide(slash)
						room:setEmotion(player, "slash_black")
					end
				end
			elseif pattern == "jink" and player:getMark("oflshouliJink-Clear") == 0 then
				local MA = sgs.SPlayerList()
				for _, m in sgs.qlist(room:getOtherPlayers(player)) do
					if m:getMark("&oflshouli_LI") > 0 then
						MA:append(m)
					end
				end
				if MA:isEmpty() then return false end
				if room:askForSkillInvoke(player, "oflshouli", data) then
					room:addPlayerMark(player, "oflshouliJink-Clear")
					local nmml = room:askForPlayerChosen(player, MA, "oflshouli", "oflshouli_LT")
					if nmml then
						local LI = nmml:getMark("&oflshouli_LI")
						local last, naxt
						for _, p in sgs.qlist(room:getOtherPlayers(nmml)) do
							if p:getNextAlive():objectName() == nmml:objectName() then
								last = p
							end
						end
						naxt = nmml:getNextAlive()
						local choice = room:askForChoice(player, "oflshouli", "LtoL+LtoN")
						room:broadcastSkillInvoke("oflshouli")
						if choice == "LtoL" then
							nmml:loseAllMarks("&oflshouli_LI")
							last:gainMark("&oflshouli_LI", LI)
						elseif choice == "LtoN" then
							nmml:loseAllMarks("&oflshouli_LI")
							naxt:gainMark("&oflshouli_LI", LI)
						end
						local jink = sgs.Sanguosha:cloneCard("jink", sgs.Card_NoSuit, 0)
						jink:setSkillName("oflshouli")
						room:provide(jink)
						room:setEmotion(player, "jink")
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("oflshouli")
	end,
}
ofl_shenmachao:addSkill(oflshouli)
if not sgs.Sanguosha:getSkill("oflshouliSlash") then skills:append(oflshouliSlash) end
if not sgs.Sanguosha:getSkill("oflshouliSlashMax") then skills:append(oflshouliSlashMax) end
if not sgs.Sanguosha:getSkill("oflshouliTrigger") then skills:append(oflshouliTrigger) end
--==♞“骏”♞==--
oflshouli_JUN_one = sgs.CreateDistanceSkill{
	name = "oflshouli_JUN_one",
	correct_func = function(self, from)
		if from:getMark("&oflshouli_JUN") >= 1 then
			return -1
		else
			return 0	
		end
	end,
}
oflshouli_JUN_oneMore = sgs.CreateTriggerSkill{
	name = "oflshouli_JUN_oneMore",
	global = true,
	priority = -7,
	frequency = sgs.Skill_Frequent,
	events = {sgs.DamageInflicted, sgs.DrawNCards, sgs.CardUsed, sgs.MarkChanged, sgs.ObtainEquipArea, sgs.EventPhaseChanging, sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawNCards and player:getMark("&oflshouli_JUN") >= 2 then
			local log = sgs.LogMessage()
			log.type = "$oflshouli_JUN_two"
			log.from = player
			room:sendLog(log)
			local count = data:toInt() + 1
			data:setValue(count)
		elseif event == sgs.CardUsed and player:getMark("&oflshouli_JUN") >= 3 then
			local use = data:toCardUse()
			if use.from and use.from:objectName() == player:objectName() and use.card and use.card:isKindOf("Slash") then
				player:setFlags("JUNthreeSource")
				for _, p in sgs.qlist(use.to) do
					if p:getMark("@skill_invalidity") > 0 then continue end
					local log = sgs.LogMessage()
					log.type = "$oflshouli_JUN_three"
					log.from = player
					log.to:append(p)
					room:sendLog(log)
					p:setFlags("JUNthreeTarget")
					room:addPlayerMark(p, "@skill_invalidity")
				end
			end
		elseif event == sgs.DamageInflicted and player:getMark("&oflshouli_JUN") > 0 then
			local damage = data:toDamage()
			if damage.to and damage.to:objectName() == player:objectName() then
				if damage.nature ~= sgs.DamageStruct_Normal or (damage.card and (damage.card:isKindOf("SavageAssault") or damage.card:isKindOf("ArcheryAttack"))) then
					local last
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if p:getNextAlive():objectName() == player:objectName() then --找到上家
							last = p
						end
					end
					local JUN = player:getMark("&oflshouli_JUN")
					player:loseAllMarks("&oflshouli_JUN")
					last:gainMark("&oflshouli_JUN", JUN)
				end
			end
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			if mark.name == "&oflshouli_JUN" and mark.who and mark.who:objectName() == player:objectName() then
				if player:getMark("&oflshouli_JUN") > 0 and player:hasEquipArea(3) then
					room:setPlayerMark(player, "oflshouli_JUN_target", 1) --标明是因此才废除的装备栏
					player:throwEquipArea(3)
				elseif player:getMark("&oflshouli_JUN") == 0 and not player:hasEquipArea(3) and player:getMark("oflshouli_JUN_target") > 0 then
					room:setPlayerMark(player, "oflshouli_JUN_target", 0)
					player:obtainEquipArea(3)
				end
			end
		elseif event == sgs.ObtainEquipArea and player:getMark("&oflshouli_JUN") > 0 and player:hasEquipArea(3) then
			room:setPlayerMark(player, "oflshouli_JUN_target", 1)
			player:throwEquipArea(3)
		elseif event == sgs.EventPhaseChanging or event == sgs.Death then
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
				if p:hasFlag("JUNthreeSource") then p:setFlags("-JUNthreeSource") end
				if p:hasFlag("JUNthreeTarget") then
					p:setFlags("-JUNthreeTarget")
					if p:getMark("@skill_invalidity") > 0 then
						room:setPlayerMark(p, "@skill_invalidity", 0)
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("oflshouli_JUN_one") then skills:append(oflshouli_JUN_one) end
if not sgs.Sanguosha:getSkill("oflshouli_JUN_oneMore") then skills:append(oflshouli_JUN_oneMore) end
--==♘“骊”♘==--
oflshouli_LI_one = sgs.CreateDistanceSkill{
	name = "oflshouli_LI_one",
	correct_func = function(self, from, to)
		if to:getMark("&oflshouli_LI") >= 1 then
			return 1
		else
			return 0
		end
	end,
}
oflshouli_LI_oneMore = sgs.CreateTriggerSkill{
	name = "oflshouli_LI_oneMore",
	global = true,
	priority = {7, 7},
	frequency = sgs.Skill_Frequent,
	events = {sgs.DamageCaused, sgs.DamageInflicted, sgs.DrawNCards, sgs.MarkChanged, sgs.ObtainEquipArea},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawNCards and player:getMark("&oflshouli_LI") >= 2 then
			local log = sgs.LogMessage()
			log.type = "$oflshouli_LI_two"
			log.from = player
			room:sendLog(log)
			local count = data:toInt() + 1
			data:setValue(count)
		elseif event == sgs.DamageCaused or event == sgs.DamageInflicted then
			local damage = data:toDamage()
			if player:getMark("&oflshouli_LI") > 0 then
				if damage.nature ~= sgs.DamageStruct_Thunder and player:getMark("&oflshouli_LI") >= 3 then
					local log = sgs.LogMessage()
					log.type = "$oflshouli_LI_three"
					log.from = player
					room:sendLog(log)
					damage.nature = sgs.DamageStruct_Thunder
				end
				if player:getMark("&oflshouli_LI") >= 4 then
					local msg = sgs.LogMessage()
					msg.from = player
					if event == sgs.DamageCaused then
						msg.type = "$oflshouli_LI_four_DC"
						msg.to:append(damage.to)
					elseif event == sgs.DamageInflicted then
						msg.type = "$oflshouli_LI_four_DI"
						msg.to:append(damage.from)
					end
					room:sendLog(msg)
					damage.damage = damage.damage + 1
				end
				data:setValue(damage)
				if damage.nature ~= sgs.DamageStruct_Normal or (damage.card and (damage.card:isKindOf("SavageAssault") or damage.card:isKindOf("ArcheryAttack"))) then
					local naxt = player:getNextAlive() --下家
					local LI = player:getMark("&oflshouli_LI")
					player:loseAllMarks("&oflshouli_LI")
					naxt:gainMark("&oflshouli_LI", LI)
				end
			end
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			if mark.name == "&oflshouli_LI" and mark.who and mark.who:objectName() == player:objectName() then
				if player:getMark("&oflshouli_LI") > 0 and player:hasEquipArea(2) then
					room:setPlayerMark(player, "oflshouli_LI_target", 1) --标明是因此才废除的装备栏
					player:throwEquipArea(2)
				elseif player:getMark("&oflshouli_LI") == 0 and not player:hasEquipArea(2) and player:getMark("oflshouli_LI_target") > 0 then
					room:setPlayerMark(player, "oflshouli_LI_target", 0)
					player:obtainEquipArea(2)
				end
			end
		elseif event == sgs.ObtainEquipArea and player:getMark("&oflshouli_LI") > 0 and player:hasEquipArea(2) then
			room:setPlayerMark(player, "oflshouli_LI_target", 1)
			player:throwEquipArea(2)
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("oflshouli_LI_one") then skills:append(oflshouli_LI_one) end
if not sgs.Sanguosha:getSkill("oflshouli_LI_oneMore") then skills:append(oflshouli_LI_oneMore) end

oflhengwu = sgs.CreateTriggerSkill{
	name = "oflhengwu",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.MarkChanged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local mark = data:toMark()
		if (mark.name == "&oflshouli_JUN" and mark.who and mark.gain > 0 and mark.who:getMark("&oflshouli_JUN") - mark.gain > 0)
		or (mark.name == "&oflshouli_LI" and mark.who and mark.gain > 0 and mark.who:getMark("&oflshouli_LI") - mark.gain > 0) then
			local nsmcDraw = 0
			if mark.name == "&oflshouli_JUN" then
				nsmcDraw = mark.who:getMark("&oflshouli_JUN")
			elseif mark.name == "&oflshouli_LI" then
				nsmcDraw = mark.who:getMark("&oflshouli_LI")
			end
			if nsmcDraw > 0 then
				for _, nsmc in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					room:sendCompulsoryTriggerLog(nsmc, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:drawCards(nsmc, nsmcDraw, self:objectName())
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
ofl_shenmachao:addSkill(oflhengwu)


--

--神郭嘉
ofl_shenguojia = sgs.General(extension_ofl, "ofl_shenguojia", "god", 3, true)

oflhuishiCard = sgs.CreateSkillCard{
	name = "oflhuishiCard",
	target_fixed = true,
	on_use = function(self, room, source, target)
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:deleteLater()
		while source:isAlive() do
			local all, suits = {"spade", "heart", "club", "diamond"}, {} --不考虑无花色了
			for _, suit in ipairs(all) do
				if source:getMark("oflhuishi_judge_" .. suit .. "-PlayClear") > 0 then continue end
				table.insert(suits, suit)
			end
			if #suits == 0 then suits = {"xxx"} end
			local judge = sgs.JudgeStruct()
			judge.who = source
			judge.reason = "oflhuishi"
			judge.pattern = ".|" .. table.concat(suits, ",")
			judge.good = true
			room:judge(judge)
			local suit_str = judge.pattern
			source:addMark("oflhuishi_judge_" .. suit_str .. "-PlayClear")
			local id = judge.card:getEffectiveId()
			if room:getCardPlace(id) == sgs.Player_DiscardPile and not slash:getSubcards():contains(id) then
				slash:addSubcard(id)
			end
			if judge:isGood() and source:isAlive() then
				if not source:askForSkillInvoke("oflhuishi") then break end
			else
				break
			end
		end
		if source:isAlive() and slash:subcardsLength() > 0 then
			room:fillAG(slash:getSubcards(), source)
			local to = room:askForPlayerChosen(source, room:getAlivePlayers(), "oflhuishi", "@oflhuishi-give", true, false)
			room:clearAG(source)
			if not to then return end
			room:doAnimate(1, source:objectName(), to:objectName())
			room:giveCard(source, to, slash, "oflhuishi", true)
		end
	end,
}
oflhuishi = sgs.CreateZeroCardViewAsSkill{
	name = "oflhuishi",
	view_as = function()
		return oflhuishiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#oflhuishiCard")
	end,
}
oflhuishiContinue = sgs.CreateTriggerSkill{
	name = "oflhuishiContinue",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.FinishJudge},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local judge = data:toJudge()
		if judge.reason ~= "oflhuishi" then return false end
		judge.pattern = judge.card:getSuitString()
	end,
	can_trigger = function(self, player)
		return player:hasSkill("oflhuishi")
	end,
}
ofl_shenguojia:addSkill(oflhuishi)
if not sgs.Sanguosha:getSkill("oflhuishiContinue") then skills:append(oflhuishiContinue) end

ofltianyiDamageTake = sgs.CreateTriggerSkill{
    name = "ofltianyiDamageTake",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local damage = data:toDamage()
		local sgj = room:findPlayerBySkillName("ofltianyi")
		if not sgj then return false end
		if player:getMark("ofltianyiDamageTake") == 0 then
		    room:addPlayerMark(player, "ofltianyiDamageTake")
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
ofltianyi = sgs.CreateTriggerSkill{
    name = "ofltianyi",
	frequency = sgs.Skill_Wake,
	waked_skills = "ty_zuoxing",
	events = {sgs.EventPhaseStart},
	can_wake = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:getMark("ofltianyiDamageTake") == 0 then
				return false
			end
		end
		return true
	end,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		room:doLightbox("f_tianyiAnimate")
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
		local mhp = player:getMaxHp()
		if mhp < 10 then
			local m = 10 - mhp
			room:gainMaxHp(player, m, self:objectName())
		end
		local beneficiary = room:askForPlayerChosen(player, room:getAllPlayers(), "@ofltianyi", "ofltianyi-invoke")
		room:addPlayerMark(player, "ty_zuoxingFrom")
		if not beneficiary:hasSkill("ty_zuoxing") then
			room:acquireSkill(beneficiary, "ty_zuoxing") --懒得再单独写一个佐幸了，正好线下版的就是出牌阶段扣体力上限的版本
		end
	end,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
ofl_shenguojia:addSkill(ofltianyi)
ofl_shenguojia:addRelateSkill("ty_zuoxing")
if not sgs.Sanguosha:getSkill("ofltianyiDamageTake") then skills:append(ofltianyiDamageTake) end

oflhuishii = sgs.CreateTriggerSkill{
	name = "oflhuishii",
	frequency = sgs.Skill_Limited,
	limit_mark = "@oflhuishii",
	events = {sgs.AskForPeaches},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying_data = data:toDying()
		if dying_data.who:objectName() == player:objectName() then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				player:loseMark("@oflhuishii")
				room:broadcastSkillInvoke(self:objectName())
				room:doSuperLightbox("f_shenguojia", self:objectName())
				local waker = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName(), "oflhuishii-wake")
				local skills = {}
				for _, sk in sgs.qlist(waker:getVisibleSkillList()) do
					if sk:getFrequency(waker) ~= sgs.Skill_Wake or waker:getMark(sk:objectName()) > 0 then continue end
					table.insert(skills, sk:objectName())
				end
				if #skills > 0 then
					local data = sgs.QVariant()
					data:setValue(waker)
					local skill = room:askForChoice(player, self:objectName(), table.concat(skills, "+"), data)
					waker:setCanWake(self:objectName(), skill)
				else
					waker:drawCards(4, self:objectName())
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill(self:objectName()) and player:getMark("@oflhuishii") > 0
	end,
}
ofl_shenguojia:addSkill(oflhuishii)



--

--神荀彧
ofl_shenxunyu = sgs.General(extension_ofl, "ofl_shenxunyu", "god", 3, true)

ofl_shenxunyu:addSkill("tianzuo")

ofllingce = sgs.CreateTriggerSkill{
	name = "ofllingce",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed, sgs.TargetConfirming},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.CardUsed then
			if use.card and not use.card:isKindOf("SkillCard") then
				for _, sxy in sgs.qlist(room:getAllPlayers()) do
					if sxy:isDead() or not sxy:hasSkill(self:objectName()) then continue end
					local names = sxy:property("SkillDescriptionRecord_ofldinghan"):toString():split("+")
					if table.contains(names, use.card:objectName()) then
						room:sendCompulsoryTriggerLog(sxy, self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						room:drawCards(sxy, 1, self:objectName())
					end
				end
			end
		elseif event == sgs.TargetConfirming then
			if use.card and not use.card:isKindOf("SkillCard") and use.from and use.from:objectName() ~= player:objectName() then
				local names, name = player:property("SkillDescriptionRecord_ofldinghan"):toString():split("+"), use.card:objectName()
				if table.contains(names, name) then
					local log = sgs.LogMessage()
					log.type = "#WuyanGooD"
					log.from = player
					log.to:append(use.from)
					log.arg = name
					log.arg2 = self:objectName()
					room:sendLog(log)
					room:notifySkillInvoked(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					local nullified_list = use.nullified_list
					table.insert(nullified_list, player:objectName())
					use.nullified_list = nullified_list
					data:setValue(use)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
ofl_shenxunyu:addSkill(ofllingce)

--初始“智囊牌”记录：
ofldinghan_firstZNs = sgs.CreateTriggerSkill{
	name = "ofldinghan_firstZNs",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.GameStart, sgs.EventAcquireSkill},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:hasSkill("ofldinghan") then
				local names = player:property("SkillDescriptionRecord_ofldinghan"):toString():split("+")
				table.insert(names, "dismantlement")
				table.insert(names, "ex_nihilo")
				table.insert(names, "nullification")
				room:setPlayerProperty(player, "SkillDescriptionRecord_ofldinghan", sgs.QVariant(table.concat(names, "+")))
				room:changeTranslation(player, "ofldinghan", 11)
			end
		elseif event == sgs.EventAcquireSkill then
			if data:toString() == "ofldinghan" then
				local names = player:property("SkillDescriptionRecord_ofldinghan"):toString():split("+")
				--检测记录是不是空的：
				if #names == 0 then --是空的，载入三张初始智囊牌；不是空的，说明有记录，就不重置了。
					table.insert(names, "dismantlement")
					table.insert(names, "ex_nihilo")
					table.insert(names, "nullification")
				end
				room:setPlayerProperty(player, "SkillDescriptionRecord_ofldinghan", sgs.QVariant(table.concat(names, "+")))
				room:changeTranslation(player, "ofldinghan", 11)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("ofldinghan_firstZNs") then skills:append(ofldinghan_firstZNs) end
---
ofldinghan = sgs.CreateTriggerSkill{
	name = "ofldinghan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase ~= sgs.Player_Start then return false end
		local record, other, dinghan, tricks = sgs.IntList(), sgs.IntList(), player:property("SkillDescriptionRecord_ofldinghan"):toString():split("+"), {}
		if #dinghan == 0 then return false end
		if not room:askForSkillInvoke(player, self:objectName(), data) then return false end
		for _, i in sgs.qlist(sgs.Sanguosha:getRandomCards()) do
			local c = sgs.Sanguosha:getEngineCard(i)
			if not c:isKindOf("TrickCard") or table.contains(tricks, c:objectName()) then continue end
			table.insert(tricks, c:objectName())
			if table.contains(dinghan, c:objectName()) then
				record:append(i)
			else
				other:append(i)
			end
		end
		--移除记录
		room:fillAG(record, player)
		local id = room:askForAG(player, record, false, self:objectName())
		room:clearAG(player)
		local name = sgs.Sanguosha:getEngineCard(id):objectName()
		local log = sgs.LogMessage()
		log.type = "#oflDingHanRemove"
		log.from = player
		log.arg = self:objectName()
		log.arg2 = name
		room:sendLog(log)
		room:broadcastSkillInvoke(self:objectName())
		table.removeOne(dinghan, name)
		other:append(id)
		room:setPlayerProperty(player, "SkillDescriptionRecord_ofldinghan", sgs.QVariant(table.concat(dinghan, "+")))
		if #dinghan == 0 then
			room:changeTranslation(player, "ofldinghan", 1)
		else
			room:changeTranslation(player, "ofldinghan", 11)
		end
		--增添记录
		room:fillAG(other, player)
		local it = room:askForAG(player, other, false, self:objectName())
		room:clearAG(player)
		local name = sgs.Sanguosha:getEngineCard(it):objectName()
		local msg = sgs.LogMessage()
		msg.type = "#oflDingHanAdd"
		msg.from = player
		msg.arg = self:objectName()
		msg.arg2 = name
		room:sendLog(msg)
		room:broadcastSkillInvoke(self:objectName())
		table.insert(dinghan, name)
		room:setPlayerProperty(player, "SkillDescriptionRecord_ofldinghan", sgs.QVariant(table.concat(dinghan, "+")))
		room:changeTranslation(player, "ofldinghan", 11)
	end,
}
ofl_shenxunyu:addSkill(ofldinghan)

--

--长坂坡模式·神赵云
  --原版
ofl_cbp_shenzhaoyun = sgs.General(extension_ofl, "ofl_cbp_shenzhaoyun", "god", 4, true)

ofl_cbp_shenzhaoyun:addSkill("longdan")

oflqinggang = sgs.CreateTriggerSkill{
	name = "oflqinggang",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.from and damage.from:objectName() == player:objectName() and damage.to and damage.card and damage.card:isKindOf("Slash") then
			if damage.to:isNude() or (damage.to:getEquips():length() == 0 and not damage.to:canDiscard(damage.to, "h")) then return false end
			if room:askForSkillInvoke(player, self:objectName(), data) then
				local choices = {}
				if not damage.to:isKongcheng() and damage.to:canDiscard(damage.to, "h") then
					table.insert(choices, "1")
				end
				if damage.to:getEquips():length() > 0 then
					table.insert(choices, "2")
				end
				local choice = room:askForChoice(damage.to, self:objectName(), table.concat(choices, "+"))
				if choice == "1" then
					room:askForDiscard(damage.to, self:objectName(), 1, 1)
					room:broadcastSkillInvoke(self:objectName(), 1)
				elseif choice == "2" then
					local equip = room:askForCardChosen(player, damage.to, "e", self:objectName())
					room:obtainCard(player, equip)
					room:broadcastSkillInvoke(self:objectName(), 2)
				end
			end
		end
	end,
}
ofl_cbp_shenzhaoyun:addSkill(oflqinggang)

ofllongnuCard = sgs.CreateSkillCard{
	name = "ofllongnuCard",
	target_fixed = true,
	will_throw = true,
	mute = true,
	on_use = function(self, room, source, target)
		room:addPlayerMark(source, "&ofllongnu")
	end,
}
ofllongnu = sgs.CreateViewAsSkill{
	name = "ofllongnu",
	n = 2,
	expand_pile = "oflAngry",
	view_filter = function(self, selected, to_select)
	   	for _, c in sgs.list(selected) do
	    	if c:getSuit() ~= to_select:getSuit() then
			return end
	   	end
		return sgs.Self:getPile("oflAngry"):contains(to_select:getEffectiveId())
	end,
	view_as = function(self, cards)
		if #cards ~= 2 then return nil end
		local card = ofllongnuCard:clone()
	   	for _, c in sgs.list(cards) do
	    	card:addSubcard(c)
	   	end
		return card
	end,
	enabled_at_play = function(self, player)
		return player:getPile("oflAngry"):length() >= 2 and player:getMark("&ofllongnu") == 0
	end,
}
ofllongnuBuff = sgs.CreateTriggerSkill{
	name = "ofllongnuBuff",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.TargetSpecified, sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.CardUsed then
			if use.card and use.card:getSkillName() == "ofllongnu" then
				room:broadcastSkillInvoke("ofllongnu", 1)
			end
		elseif event == sgs.TargetSpecified then
			if use.from and use.from:objectName() == player:objectName() and player:getMark("&ofllongnu") > 0
			and use.card and use.card:isKindOf("Slash") then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke("ofllongnu", 2)
				local no_respond_list = use.no_respond_list
				for _, cj in sgs.qlist(use.to) do
					table.insert(no_respond_list, cj:objectName())
				end
				use.no_respond_list = no_respond_list
				room:setPlayerMark(player, "&ofllongnu", 0)
				data:setValue(use)
			end
		elseif event == sgs.CardFinished then
			if use.card and use.card:isKindOf("Slash") and player:getMark("&ofllongnu") > 0 then
				room:setPlayerMark(player, "&ofllongnu", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
ofl_cbp_shenzhaoyun:addSkill(ofllongnu)
if not sgs.Sanguosha:getSkill("ofllongnuBuff") then skills:append(ofllongnuBuff) end

oflyuxue = sgs.CreateViewAsSkill{
	name = "oflyuxue",
	n = 1,
	expand_pile = "oflAngry",
	view_filter = function(self, selected, to_select)
		return sgs.Self:getPile("oflAngry"):contains(to_select:getEffectiveId())
		and (to_select:getSuit() == sgs.Card_Heart or to_select:getSuit() == sgs.Card_Diamond)
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local card = cards[1]
		local peach = sgs.Sanguosha:cloneCard("peach", card:getSuit(), card:getNumber())
		peach:setSkillName(self:objectName())
		peach:addSubcard(card)
		return peach
	end,
	enabled_at_play = function(self, player)
		return player:getPile("oflAngry"):length() > 0 and player:isWounded()
	end,
	enabled_at_response = function(self, player, pattern)
		return player:getPile("oflAngry"):length() > 0
		and string.find(pattern, "peach") and not player:hasFlag("Global_PreventPeach")
	end,
}
ofl_cbp_shenzhaoyun:addSkill(oflyuxue)

ofllongyin = sgs.CreateTriggerSkill{
	name = "ofllongyin",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start and player:getPile("oflAngry"):length() < 4 then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName(), 1)
				local card_ids = room:getNCards(3)
				local angry = sgs.IntList()
				room:fillAG(card_ids)
				local id = room:askForAG(player, card_ids, false, self:objectName())
				card_ids:removeOne(id)
				angry:append(id)
				room:clearAG()
				
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, i in sgs.qlist(angry) do
					dummy:addSubcard(i)
				end
				room:broadcastSkillInvoke(self:objectName(), 2)
				player:addToPile("oflAngry", dummy)
				dummy:deleteLater()
				local dummi = sgs.Sanguosha:cloneCard("jink", sgs.Card_NoSuit, 0)
				for _, ids in sgs.qlist(card_ids) do
					dummi:addSubcard(ids)
				end
				room:obtainCard(player, dummi)
				dummi:deleteLater()
			end
		end
	end,
}
ofl_cbp_shenzhaoyun:addSkill(ofllongyin)

  --威力加强版
ofl_cbp_shenzhaoyunEX = sgs.General(extension_ofl, "ofl_cbp_shenzhaoyunEX", "god", 4, true)

ofl_cbp_shenzhaoyunEX:addSkill("ollongdan")

oflqinggangEX = sgs.CreateTriggerSkill{
	name = "oflqinggangEX",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.from and damage.from:objectName() == player:objectName() and damage.to and damage.card and damage.card:isKindOf("Slash") then
			if damage.to:isNude() or (damage.to:getEquips():length() == 0 and not damage.to:canDiscard(damage.to, "h")) then return false end
			if room:askForSkillInvoke(player, self:objectName(), data) then
				if not damage.to:isKongcheng() and damage.to:canDiscard(damage.to, "h") then
					room:askForDiscard(damage.to, self:objectName(), 1, 1)
					room:broadcastSkillInvoke(self:objectName(), 1)
				end
				if damage.to:getEquips():length() > 0 then
					local equip = room:askForCardChosen(player, damage.to, "e", self:objectName())
					room:obtainCard(player, equip)
					room:broadcastSkillInvoke(self:objectName(), 2)
				end
			end
		end
	end,
}
ofl_cbp_shenzhaoyunEX:addSkill(oflqinggangEX)

ofllongnuEXCard = sgs.CreateSkillCard{
	name = "ofllongnuEXCard",
	target_fixed = true,
	will_throw = false,
	mute = true,
	on_use = function(self, room, source, target)
		room:addPlayerMark(source, "&ofllongnuEX")
		local choice = room:askForChoice(source, "ofllongnuEX", "get+dis")
		if choice == "get" then
			local reason_g = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "ofllongnuEX", "")
			room:obtainCard(source, self, reason_g)
		elseif choice == "dis" then
			local reason_d = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "ofllongnuEX", "")
			room:throwCard(self, reason_d, source)
			room:addPlayerMark(source, "ofllongnuEX")
		end
	end,
}
ofllongnuEX = sgs.CreateViewAsSkill{
	name = "ofllongnuEX",
	n = 2,
	expand_pile = "oflAngry",
	view_filter = function(self, selected, to_select)
	   	for _, c in sgs.list(selected) do
	    	if c:getSuit() ~= to_select:getSuit() then
			return end
	   	end
		return sgs.Self:getPile("oflAngry"):contains(to_select:getEffectiveId())
	end,
	view_as = function(self, cards)
		if #cards ~= 2 then return nil end
		local card = ofllongnuEXCard:clone()
	   	for _, c in sgs.list(cards) do
	    	card:addSubcard(c)
	   	end
		return card
	end,
	enabled_at_play = function(self, player)
		return player:getPile("oflAngry"):length() >= 2 --and player:getMark("&ofllongnuEX") == 0
	end,
}
ofllongnuEXbuff = sgs.CreateTriggerSkill{
	name = "ofllongnuEXbuff",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.TargetSpecified, sgs.ConfirmDamage, sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.CardUsed then
			if use.card and use.card:getSkillName() == "ofllongnuex" then
				room:broadcastSkillInvoke("ofllongnuEX", 1)
			end
		elseif event == sgs.TargetSpecified then
			if use.from and use.from:objectName() == player:objectName() and player:getMark("&ofllongnuEX") > 0
			and use.card and use.card:isKindOf("Slash") then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke("ofllongnuEX", 2)
				local no_respond_list = use.no_respond_list
				for _, cj in sgs.qlist(use.to) do
					table.insert(no_respond_list, cj:objectName())
				end
				use.no_respond_list = no_respond_list
				room:setPlayerMark(player, "&ofllongnuEX", 0)
				if player:getMark("ofllongnuEX") > 0 then
					local n = player:getMark("ofllongnuEX")
					room:setPlayerMark(player, "ofllongnuEX", 0)
					room:setPlayerMark(player, "ofllongnuEXbuff_md", n)
				end
				data:setValue(use)
			end
		elseif event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.from and damage.from:objectName() == player:objectName() and player:getMark("ofllongnuEXbuff_md") > 0
			and damage.card and damage.card:isKindOf("Slash") then
				local n = player:getMark("ofllongnuEXbuff_md")
				room:setPlayerMark(player, "ofllongnuEXbuff_md", 0)
				local log = sgs.LogMessage()
				log.type = "$ofllongnuEXbuff_md"
				log.from = player
				log.to:append(damage.to)
				log.arg2 = n
				room:sendLog(log)
				room:broadcastSkillInvoke("ofllongnuEX", 2)
				damage.damage = damage.damage + n
				data:setValue(damage)
			end
		elseif event == sgs.CardFinished then
			if use.card and use.card:isKindOf("Slash") then
				if player:getMark("&ofllongnuEX") > 0 then room:setPlayerMark(player, "&ofllongnuEX", 0) end
				if player:getMark("ofllongnuEX") > 0 then room:setPlayerMark(player, "ofllongnuEX", 0) end
				if player:getMark("ofllongnuEXbuff_md") > 0 then room:setPlayerMark(player, "ofllongnuEXbuff_md", 0) end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
ofl_cbp_shenzhaoyunEX:addSkill(ofllongnuEX)
if not sgs.Sanguosha:getSkill("ofllongnuEXbuff") then skills:append(ofllongnuEXbuff) end

oflyuxueEX = sgs.CreateOneCardViewAsSkill{
	name = "oflyuxueEX",
	filter_pattern = ".|.|.|oflAngry",
	expand_pile = "oflAngry",
	view_filter = function(self, card)
		local newana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_SuitToBeDecided, 0)
		local usereason = sgs.Sanguosha:getCurrentCardUseReason()
		if usereason == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			if sgs.Self:isWounded() and sgs.Self:usedTimes("Analeptic") > sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, sgs.Self, newana) then
				return card:isRed()
			elseif not sgs.Self:isWounded() and sgs.Self:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, sgs.Self, newana) then
				return card:isBlack()
			end
			if sgs.Self:isWounded() or sgs.Self:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, sgs.Self, newana) then
				return card:isRed() or card:isBlack()
			end
		elseif usereason == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or usereason == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if string.find(pattern, "peach") then
				if not sgs.Self:hasFlag("Global_Dying") then
					if not sgs.Self:hasFlag("Global_PreventPeach") then
						return card:isRed()
					else
						return false
					end
				elseif sgs.Self:hasFlag("Global_PreventPeach") and sgs.Self:hasFlag("Global_Dying") then
					return card:isBlack()
				end
				return card:isRed() or card:isBlack()
			elseif string.find(pattern, "analeptic") then
				return card:isBlack()
			end
		else
			return false
		end
		return false
	end,
	view_as = function(self, card)
		if card:isRed() then
			local peach = sgs.Sanguosha:cloneCard("peach", card:getSuit(), card:getNumber())
			peach:addSubcard(card)
			peach:setSkillName(self:objectName())
			return peach
		elseif card:isBlack() then
			local analeptic = sgs.Sanguosha:cloneCard("analeptic", card:getSuit(), card:getNumber())
			analeptic:addSubcard(card)
			analeptic:setSkillName(self:objectName())
			return analeptic
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		local newana = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_SuitToBeDecided, 0)
		return player:getPile("oflAngry"):length() > 0
		and (player:isWounded() or player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, player, newana))
	end,
	enabled_at_response = function(self, player, pattern)
		return player:getPile("oflAngry"):length() > 0
		and ((string.find(pattern, "peach") and not player:hasFlag("Global_PreventPeach")) or string.find(pattern, "analeptic"))
	end,
}
function GetColor(card)
	if card:isRed() then return "red" elseif card:isBlack() then return "black" end
end
oflyuxueEXbuff = sgs.CreateTriggerSkill{
	name = "oflyuxueEXbuff",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card and use.card:getSkillName() == "oflyuxueEX" then
			local ofllongnuEX_cards = {}
			local ofllongnuEX_count = 0
			for _, gid in sgs.qlist(room:getDrawPile()) do
				local get_card = sgs.Sanguosha:getCard(gid)
				if GetColor(get_card) == GetColor(use.card) and ofllongnuEX_count < 1 then
					ofllongnuEX_count = ofllongnuEX_count + 1
					table.insert(ofllongnuEX_cards, gid)
				end
			end
			if #ofllongnuEX_cards > 0 then
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, id in ipairs(ofllongnuEX_cards) do
					dummy:addSubcard(id)
				end
				room:sendCompulsoryTriggerLog(player, "oflyuxueEX")
				room:broadcastSkillInvoke("oflyuxueEX")
				room:obtainCard(player, dummy, true)
				dummy:deleteLater()
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("oflyuxueEX")
	end,
}
ofl_cbp_shenzhaoyunEX:addSkill(oflyuxueEX)
if not sgs.Sanguosha:getSkill("oflyuxueEXbuff") then skills:append(oflyuxueEXbuff) end

ofllongyinEX = sgs.CreateTriggerSkill{
	name = "ofllongyinEX",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start and player:getPile("oflAngry"):length() < 8 then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName(), 1)
				local n = 4 + player:getEquips():length()
				local card_ids = room:getNCards(n)
				local angry = sgs.IntList()
				room:fillAG(card_ids)
				local id = room:askForAG(player, card_ids, false, self:objectName())
				card_ids:removeOne(id)
				angry:append(id)
				room:clearAG()
				local cot, agy = 0, 7 - player:getPile("oflAngry"):length()
				while agy - cot > 0 and not card_ids:isEmpty() do
					room:fillAG(card_ids)
					local id = room:askForAG(player, card_ids, true, self:objectName()) --可中止
					if id == -1 then room:clearAG() break end
					card_ids:removeOne(id)
					angry:append(id)
					if agy - cot <= 0 then room:clearAG() break end
					if player:getState() == "robot" and agy - cot <= 2 then
					room:clearAG() break end
					cot = cot + 1
					room:clearAG()
				end
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, i in sgs.qlist(angry) do
					dummy:addSubcard(i)
				end
				room:broadcastSkillInvoke(self:objectName(), 2)
				player:addToPile("oflAngry", dummy)
				dummy:deleteLater()
				local dummi = sgs.Sanguosha:cloneCard("jink", sgs.Card_NoSuit, 0)
				for _, ids in sgs.qlist(card_ids) do
					dummi:addSubcard(ids)
				end
				room:obtainCard(player, dummi)
				dummi:deleteLater()
			end
		end
	end,
}
ofl_cbp_shenzhaoyunEX:addSkill(ofllongyinEX)

--长坂坡模式·神张飞
  --原版
ofl_cbp_shenzhangfei = sgs.General(extension_ofl, "ofl_cbp_shenzhangfei", "god", 5, true)

oflzhangba = sgs.CreateViewAsEquipSkill{
	name = "oflzhangba",
	view_as_equip = function(self, player)
		if player:getWeapon() == nil then
			return "__ofl_zhangba"
		else
			return ""
		end
	end,
}
ofl_cbp_shenzhangfei:addSkill(oflzhangba)
--伪实现：虚拟装备
OflZhangba = sgs.CreateWeapon{
	name = "__ofl_zhangba",
	class_name = "OflZhangba",
	range = 3,
	on_install = function()
	end,
	on_uninstall = function()
	end,
}
OflZhangba:clone(sgs.Card_NoSuit, 0):setParent(newgodsCard)

oflbeiliang = sgs.CreateTriggerSkill{
	name = "oflbeiliang",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local count = data:toInt()
		if player:getHandcardNum() < player:getMaxHp() then
			local n = player:getMaxHp() - player:getHandcardNum()
			if (player:getState() == "online" and room:askForSkillInvoke(player, self:objectName(), data))
			or (player:getState() == "robot" and count < n) then
				room:broadcastSkillInvoke(self:objectName())
				room:drawCards(player, n, self:objectName())
				data:setValue(-1000)
			end
		end
	end,
}
ofl_cbp_shenzhangfei:addSkill(oflbeiliang)

ofljuwuCard = sgs.CreateSkillCard{
	name = "ofljuwuCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and isSpecialOne(to_select, "神") and isSpecialOne(to_select, "赵云")
	end,
	on_use = function(self, room, source, targets)
		local n = self:getSubcards():length()
		local sidi = targets[1]
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName(), sidi:objectName(), "ofljuwu", "")
		room:obtainCard(sidi, self, reason, false)
		room:addPlayerMark(source, "ofljuwu-PlayClear", n)
	end,
}
ofljuwu = sgs.CreateViewAsSkill{
	name = "ofljuwu",
	n = 999,
	view_filter = function(self, selected, to_select)
		local n = sgs.Self:getHp() - sgs.Self:getMark("ofljuwu-PlayClear")
		if #selected >= n then return false end
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		local n = sgs.Self:getHp() - sgs.Self:getMark("ofljuwu-PlayClear")
		if #cards >= 1 and #cards <= n then
			local ofljuwu_card = ofljuwuCard:clone()
			if ofljuwu_card then
				ofljuwu_card:setSkillName(self:objectName())
				for _, c in ipairs(cards) do
					ofljuwu_card:addSubcard(c)
				end
			end
			return ofljuwu_card
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng() and player:getMark("ofljuwu-PlayClear") < player:getHp()
	end,
}
ofl_cbp_shenzhangfei:addSkill(ofljuwu)

oflchanshe = sgs.CreateViewAsSkill{
	name = "oflchanshe",
	n = 1,
	expand_pile = "oflAngry",
	view_filter = function(self, selected, to_select)
		return sgs.Self:getPile("oflAngry"):contains(to_select:getEffectiveId())
		and (to_select:getSuit() == sgs.Card_Heart or to_select:getSuit() == sgs.Card_Diamond)
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local card = cards[1]
		local n_glzl = sgs.Sanguosha:cloneCard("indulgence", card:getSuit(), card:getNumber())
		n_glzl:setSkillName(self:objectName())
		n_glzl:addSubcard(card)
		return n_glzl
	end,
	enabled_at_play = function(self, player)
		return player:getPile("oflAngry"):length() > 0
	end,
}
ofl_cbp_shenzhangfei:addSkill(oflchanshe)

oflshishenCard = sgs.CreateSkillCard{
	name = "oflshishenCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return #targets == 0
	end,
	on_use = function(self, room, source, targets)
		room:loseHp(targets[1], 1)
	end,
}
oflshishen = sgs.CreateViewAsSkill{
	name = "oflshishen",
	n = 2,
	expand_pile = "oflAngry",
	view_filter = function(self, selected, to_select)
	   	for _, c in sgs.list(selected) do
	    	if GetColor(c) ~= GetColor(to_select) then
			return end
	   	end
		return sgs.Self:getPile("oflAngry"):contains(to_select:getEffectiveId())
	end,
	view_as = function(self, cards)
		if #cards ~= 2 then return nil end
		local card = oflshishenCard:clone()
	   	for _, c in sgs.list(cards) do
	    	card:addSubcard(c)
	   	end
		return card
	end,
	enabled_at_play = function(self, player)
		return player:getPile("oflAngry"):length() >= 2
	end,
}
oflshishenJQ = sgs.CreateTriggerSkill{
	name = "oflshishenJQ",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start and player:getPile("oflAngry"):length() < 4 then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke("oflshishen")
				local ids = room:getNCards(1, false)
				local move = sgs.CardsMoveStruct()
				move.card_ids = ids
				move.to = player
				move.to_place = sgs.Player_PlaceTable
				move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), self:objectName(), nil)
				room:moveCardsAtomic(move, true)
				room:getThread():delay()
				local id = ids:first()
				local card = sgs.Sanguosha:getCard(id)
				player:addToPile("oflAngry", card)
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("oflshishen")
	end,
}
ofl_cbp_shenzhangfei:addSkill(oflshishen)
if not sgs.Sanguosha:getSkill("oflshishenJQ") then skills:append(oflshishenJQ) end

  --威力加强版
ofl_cbp_shenzhangfeiEX = sgs.General(extension_ofl, "ofl_cbp_shenzhangfeiEX", "god", 5, true)

oflzhangbaEX = sgs.CreateViewAsEquipSkill{
	name = "oflzhangbaEX",
	view_as_equip = function(self, player)
		if player:getWeapon() == nil then
			return "spear"
		else
			return ""
		end
	end,
}
oflzhangbaEX_viewas = sgs.CreateTriggerSkill{ --因为视为装备技法则限制，需手动添加主动发动的技能
	name = "oflzhangbaEX_viewas",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.EventAcquireSkill, sgs.EventLoseSkill, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:hasSkill("oflzhangbaEX") and player:getWeapon() == nil and not player:hasSkill("spear") then
				room:attachSkillToPlayer(player, "spear")
			end
		elseif event == sgs.EventAcquireSkill then
			if data:toString() == "oflzhangbaEX" and player:getWeapon() == nil and not player:hasSkill("spear") then
				room:attachSkillToPlayer(player, "spear")
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == "oflzhangbaEX" and player:hasSkill("spear")
			and not (player:getWeapon() ~= nil and player:getWeapon():isKindOf("Spear")) then
				room:detachSkillFromPlayer(player, "spear", true)
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and move.from_places:contains(sgs.Player_PlaceEquip) and move.from:objectName() == player:objectName()
			and player:hasSkill("oflzhangbaEX") and not player:hasSkill("spear") and move.to and move.to_place ~= sgs.Player_PlaceEquip then
				for _, zb in sgs.qlist(move.card_ids) do
					local zhangba = sgs.Sanguosha:getCard(zb)
					if zhangba:isWeapon() then
						room:attachSkillToPlayer(player, "spear")
						break
					end
				end
			elseif move.to and move.to_place == sgs.Player_PlaceEquip and move.to:objectName() == player:objectName() and player:hasSkill("spear") then
				for _, zb in sgs.qlist(move.card_ids) do
					local zhangba = sgs.Sanguosha:getCard(zb)
					if zhangba:isKindOf("Weapon") and not zhangba:isKindOf("Spear") then
						room:detachSkillFromPlayer(player, "spear", true)
						break
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
ofl_cbp_shenzhangfeiEX:addSkill(oflzhangbaEX)
if not sgs.Sanguosha:getSkill("oflzhangbaEX_viewas") then skills:append(oflzhangbaEX_viewas) end

oflbeiliangEX = sgs.CreateTriggerSkill{
	name = "oflbeiliangEX",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start and player:getHandcardNum() < player:getMaxHp() then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				local n = player:getMaxHp() - player:getHandcardNum()
				room:broadcastSkillInvoke(self:objectName())
				room:drawCards(player, n, self:objectName())
			end
		end
	end,
}
ofl_cbp_shenzhangfeiEX:addSkill(oflbeiliangEX)

ofljuwuEXCard = sgs.CreateSkillCard{
	name = "ofljuwuEXCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:getKingdom() == sgs.Self:getKingdom() and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
		local n = self:subcardsLength()
		local friend = targets[1]
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName(), friend:objectName(), "ofljuwuEX", "")
		room:broadcastSkillInvoke("ofljuwuEX")
		room:obtainCard(friend, self, reason, false)
		room:addPlayerMark(source, "ofljuwuEX-PlayClear", n)
		if not friend:hasFlag("ofljuwuEX_targets") then
			room:drawCards(source, source:getLostHp(), "ofljuwuEX")
			room:setPlayerFlag(friend, "ofljuwuEX_targets")
		end
	end,
}
ofljuwuEX = sgs.CreateViewAsSkill{
	name = "ofljuwuEX",
	n = 999,
	view_filter = function(self, selected, to_select)
		local n = sgs.Self:getHp() - sgs.Self:getMark("ofljuwuEX-PlayClear")
		if #selected >= n then return false end
		return true
	end,
	view_as = function(self, cards)
		local n = sgs.Self:getHp() - sgs.Self:getMark("ofljuwuEX-PlayClear")
		if #cards >= 1 and #cards <= n then
			local ofljuwu_card = ofljuwuEXCard:clone()
			if ofljuwu_card then
				ofljuwu_card:setSkillName(self:objectName())
				for _, c in ipairs(cards) do
					ofljuwu_card:addSubcard(c)
				end
			end
			return ofljuwu_card
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return not player:isNude() and player:getMark("ofljuwuEX-PlayClear") < player:getHp()
	end,
}
ofljuwuEX_targetsClear = sgs.CreateTriggerSkill{
	name = "ofljuwuEX_targetsClear",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasFlag("ofljuwuEX_targets") then
				room:setPlayerFlag(p, "-ofljuwuEX_targets")
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
ofl_cbp_shenzhangfeiEX:addSkill(ofljuwuEX)
if not sgs.Sanguosha:getSkill("ofljuwuEX_targetsClear") then skills:append(ofljuwuEX_targetsClear) end

oflchansheEX = sgs.CreateOneCardViewAsSkill{
	name = "oflchansheEX",
	filter_pattern = ".|.|.|oflAngry",
	expand_pile = "oflAngry",
	view_as = function(self, card)
		if card:isRed() then
			local idg = sgs.Sanguosha:cloneCard("indulgence", card:getSuit(), card:getNumber())
			idg:addSubcard(card)
			idg:setSkillName(self:objectName())
			return idg
		elseif card:isBlack() then
			local ss = sgs.Sanguosha:cloneCard("supply_shortage", card:getSuit(), card:getNumber())
			ss:addSubcard(card)
			ss:setSkillName(self:objectName())
			return ss
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return player:getPile("oflAngry"):length() > 0
	end,
}
ofl_cbp_shenzhangfeiEX:addSkill(oflchansheEX)

oflshishenEXCard = sgs.CreateSkillCard{
	name = "oflshishenEXCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return #targets == 0
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local r, b, ns = 0, 0, 0
		for _, c in sgs.qlist(self:getSubcards()) do
			local card = sgs.Sanguosha:getCard(c)
			if card:isRed() then r = r + 1
			elseif card:isBlack() then b = b + 1
			elseif card:getSuit() == sgs.Card_NoSuit then ns = ns + 1 --考虑一手无色
			end
		end
		room:broadcastSkillInvoke("oflshishenEX")
		if r == 2 or b == 2 or ns == 2 then --同色
			room:loseHp(effect.to, 1)
			if effect.to:isAlive() then
				if not effect.from:hasFlag("oflshishenEXsource") then
					room:setPlayerFlag(effect.from, "oflshishenEXsource")
				end
				if not effect.to:hasFlag("oflshishenEXtarget") then
					room:setPlayerFlag(effect.to, "oflshishenEXtarget")
				end
				room:addPlayerMark(effect.to, "@skill_invalidity")
			end
		else --异色
			room:damage(sgs.DamageStruct("oflshishenEX", effect.from, effect.to))
			if effect.to:isAlive() then
				if not effect.from:hasFlag("oflshishenEXfrom") then
					room:setPlayerFlag(effect.from, "oflshishenEXfrom")
				end
				if not effect.to:hasFlag("oflshishenEXto") then
					room:setPlayerFlag(effect.to, "oflshishenEXto")
				end
				room:setPlayerCardLimitation(effect.to, "use,response", ".|.|.|hand", false)
			end
		end
	end,
}
oflshishenEX = sgs.CreateViewAsSkill{
	name = "oflshishenEX",
	n = 2,
	expand_pile = "oflAngry",
	view_filter = function(self, selected, to_select)
		return sgs.Self:getPile("oflAngry"):contains(to_select:getEffectiveId())
	end,
	view_as = function(self, cards)
		if #cards ~= 2 then return nil end
		local card = oflshishenEXCard:clone()
	   	for _, c in sgs.list(cards) do
	    	card:addSubcard(c)
	   	end
		return card
	end,
	enabled_at_play = function(self, player)
		return player:getPile("oflAngry"):length() >= 2
	end,
}
oflshishenEXClear = sgs.CreateTriggerSkill{
	name = "oflshishenEXClear",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseChanging, sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
		end
		if event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then return false end
		end
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasFlag("oflshishenEXsource") then p:setFlags("-oflshishenEXsource") end
			if p:hasFlag("oflshishenEXtarget") then
				p:setFlags("-oflshishenEXtarget")
				if p:getMark("@skill_invalidity") > 0 then
					room:setPlayerMark(p, "@skill_invalidity", 0)
				end
			end
		end
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasFlag("oflshishenEXfrom") then p:setFlags("-oflshishenEXfrom") end
			if p:hasFlag("oflshishenEXto") then
				p:setFlags("-oflshishenEXto")
				room:removePlayerCardLimitation(p, "use,response", ".|.|.|hand")
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
oflshishenEXJQ = sgs.CreateTriggerSkill{
	name = "oflshishenEXJQ",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start and player:getPile("oflAngry"):length() < 8 then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke("oflshishenEX")
				local m = math.min(8 - player:getPile("oflAngry"):length(), 3)
				local card_ids
				if m == 1 then
					card_ids = room:getNCards(1)
				else
					local n = math.random(1,m)
					card_ids = room:getNCards(n)
				end
				room:fillAG(card_ids)
				room:getThread():delay(1000)
				room:clearAG()
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, i in sgs.qlist(card_ids) do
					dummy:addSubcard(i)
				end
				player:addToPile("oflAngry", dummy)
				dummy:deleteLater()
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("oflshishenEX")
	end,
}
ofl_cbp_shenzhangfeiEX:addSkill(oflshishenEX)
if not sgs.Sanguosha:getSkill("oflshishenEXClear") then skills:append(oflshishenEXClear) end
if not sgs.Sanguosha:getSkill("oflshishenEXJQ") then skills:append(oflshishenEXJQ) end





--

--==DIY神武将==--
--神司马师
f_shensimashi = sgs.General(extension_f, "f_shensimashi", "god", 5, true, false, false, 4)

f_henjueCard = sgs.CreateSkillCard{
    name = "f_henjueCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
	    return #targets == 0 and to_select:hasEquipArea() and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
		local choices = {}
		for i = 0, 4 do
			if source:hasEquipArea(i) then
				table.insert(choices, i)
			end
		end
		if choices == "" then return false end
		local choice = room:askForChoice(source, "f_henjue", table.concat(choices, "+"))
		local area = tonumber(choice)
		source:throwEquipArea(area)
		local choicess = {}
		for i = 0, 4 do
			if targets[1]:hasEquipArea(i) then
				table.insert(choicess, i)
			end
		end
		if choicess == "" then return false end
		local choicee = room:askForChoice(source, "f_henjue", table.concat(choicess, "+"))
		local area = tonumber(choicee)
		targets[1]:throwEquipArea(area)
		local e = 0
		for i = 0, 4 do
			if not source:hasEquipArea(i) then
				e = e + 1
			end
		end
		room:drawCards(source, e, "f_henjue")
	end,
}
f_henjue = sgs.CreateZeroCardViewAsSkill{
    name = "f_henjue",
	view_as = function()
		return f_henjueCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:hasEquipArea() and not player:hasUsed("#f_henjueCard")
	end,
}
f_shensimashi:addSkill(f_henjue)

f_pingpan = sgs.CreateTriggerSkill{
	name = "f_pingpan",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.to:objectName() == player:objectName() then return false end
		local e = 0
		for i = 0, 4 do
			if not damage.to:hasEquipArea(i) then
				e = e + 1
			end
		end
		if e == 0 then return false end
		local log = sgs.LogMessage()
		log.type = "$f_pingpan"
		log.from = player
		log.to:append(damage.to)
		log.arg2 = e
		room:sendLog(log)
		room:broadcastSkillInvoke(self:objectName())
		damage.damage = damage.damage + e
		data:setValue(damage)
		damage.to:obtainEquipArea()
		local ea = {}
		for i = 0, 4 do
			if not player:hasEquipArea(i) then
				table.insert(ea, i)
			end
		end
		if ea == "" then return false end
		local x = ea[math.random(1, #ea)]
		local area = tonumber(x)
		player:obtainEquipArea(area)
	end,
}
f_shensimashi:addSkill(f_pingpan)

--神刘三刀
f_three = sgs.General(extension_f, "f_three", "god", 4, true)

f_sandaooo = sgs.CreateTargetModSkill{
	name = "f_sandaooo",
	residue_func = function(self, player)
		if player:hasSkill("f_sandao") then
			return 2
		else
			return 0
		end
	end,
}
f_sandaoC = sgs.CreateTargetModSkill{
	name = "f_sandaoC",
	residue_func = function(self, player)
		if player:hasSkill(self:objectName()) then
			return 2
		else
			return 0
		end
	end,
}
f_sandaoD = sgs.CreateTargetModSkill{
	name = "f_sandaoD",
	residue_func = function(self, player)
		if player:hasSkill(self:objectName()) then
			return 2
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("f_sandaooo") then skills:append(f_sandaooo) end
if not sgs.Sanguosha:getSkill("f_sandaoC") then skills:append(f_sandaoC) end
if not sgs.Sanguosha:getSkill("f_sandaoD") then skills:append(f_sandaoD) end
f_sandaoDraw = sgs.CreateTriggerSkill{
	name = "f_sandaoDraw",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed, sgs.CardResponded},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local card = nil
		if event == sgs.CardUsed then
			card = data:toCardUse().card
			if not card:isKindOf("Slash") then return false end
			room:setPlayerMark(player, "&f_sandaoResp", 0)
			room:addPlayerMark(player, "&f_sandaoUse")
			room:addPlayerMark(player, "f_sandaoUaR")
			if player:getMark("&f_sandaoUse") >= 3 then
				room:sendCompulsoryTriggerLog(player, "f_sandao")
				room:broadcastSkillInvoke("f_sandao")
				room:drawCards(player, 3, "f_sandao")
				room:removePlayerMark(player, "&f_sandaoUse", 3)
			end
		else
			local response = data:toCardResponse()
			card = response.m_card
			if not card:isKindOf("Slash") then return false end
			room:setPlayerMark(player, "&f_sandaoUse", 0)
			room:addPlayerMark(player, "&f_sandaoResp")
			room:addPlayerMark(player, "f_sandaoUaR")
			if player:getMark("&f_sandaoResp") >= 3 then
				room:sendCompulsoryTriggerLog(player, "f_sandao")
				room:broadcastSkillInvoke("f_sandao")
				room:drawCards(player, 3, "f_sandao")
				room:removePlayerMark(player, "&f_sandaoResp", 3)
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_sandao") or player:hasSkill("f_sandaoC")
	end,
}
if not sgs.Sanguosha:getSkill("f_sandaoDraw") then skills:append(f_sandaoDraw) end
f_sandao = sgs.CreateTriggerSkill{
	name = "f_sandao",
	global = true,
	frequency = sgs.Skill_Wake,
	events = {sgs.EventPhaseStart},
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end 
		if player:getMark("f_sandaoUaR") < 3 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		room:doSuperLightbox("WEhaveLSD", self:objectName())
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
		room:attachSkillToPlayer(player, "f_sandaoEX")
		room:addPlayerMark(player, "@f_sandaoEX")
		if player:hasSkill(self:objectName()) then
			room:detachSkillFromPlayer(player, self:objectName(), true)
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill(self:objectName()) and player:isAlive()
	end,
}
f_three:addSkill(f_sandao)
--“三刀”升级版
f_sandaoEXSlashCard = sgs.CreateSkillCard{
	name = "f_sandaoEXSlashCard",
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return sgs.Self:canSlash(to_select, nil, false)
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("f_sandaoEXSlash")
		local use = sgs.CardUseStruct()
		use.card = slash
		use.from = source
		for _, p in pairs(targets) do
			use.to:append(p)
		end
		room:broadcastSkillInvoke("f_sandaoEXSlash")
		room:broadcastSkillInvoke("f_sandaoEXSlash")
		room:broadcastSkillInvoke("f_sandaoEXSlash")
		room:useCard(use)
	end,
}
f_sandaoEXSlash = sgs.CreateZeroCardViewAsSkill{
	name = "f_sandaoEXSlash",
	view_as = function()
		return f_sandaoEXSlashCard:clone()
	end,
	enabled_at_play = function()
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@f_sandaoEXSlash"
	end,
}
f_sandaoEXCard = sgs.CreateSkillCard{
	name = "f_sandaoEXCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@f_sandaoEX")
		room:broadcastSkillInvoke("f_sandao")
		room:doSuperLightbox("WEhaveLSD", "f_sandao")
		room:setPlayerFlag(source, "f_sandaoEX")
		local n = 0
		while n < 3 and not source:hasFlag("f_sandaoEXSstop") and source:isAlive() do
			if room:askForUseCard(source, "@@f_sandaoEXSlash", "@f_sandaoEXSlash") then
				n = n + 1
			else
				room:setPlayerFlag(source, "f_sandaoEXSstop")
			end
		end
		if source:hasFlag("f_sandaoEXSstop") then room:setPlayerFlag(source, "-f_sandaoEXSstop") end
		room:setPlayerFlag(source, "-f_sandaoEX")
	end,
}
f_sandaoEXVS = sgs.CreateZeroCardViewAsSkill{
	name = "f_sandaoEX",
	view_as = function()
		return f_sandaoEXCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@f_sandaoEX") > 0
	end,
}
f_sandaoEX = sgs.CreateTriggerSkill{
	name = "f_sandaoEX",
	frequency = sgs.Skill_Limited,
	limit_mark = "@f_sandaoEX",
	view_as_skill = f_sandaoEXVS,
	on_trigger = function()
	end,
}
if not sgs.Sanguosha:getSkill("f_sandaoEXSlash") then skills:append(f_sandaoEXSlash) end
if not sgs.Sanguosha:getSkill("f_sandaoEX") then skills:append(f_sandaoEX) end
---
f_sandaoEXkill = sgs.CreateTriggerSkill{
	name = "f_sandaoEXkill",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.Death, sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Death then
			local death = data:toDeath()
		    if death.who:objectName() ~= player:objectName() then
		        local killer
		        if death.damage then
			        killer = death.damage.from
		        else
			        killer = nil
		        end
		        local current = room:getCurrent()
		        if killer and killer:hasFlag("f_sandaoEX") and (current:isAlive() or current:objectName() == death.who:objectName()) then
			        if killer:getMark("f_sandaoEX") == 0 then
						room:addPlayerMark(player, "f_sandaoEX")
					end
					if killer:getMark("@f_sandaoEX") == 0 then
						room:addPlayerMark(player, "@f_sandaoEX")
					end
		        end
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Play and player:getMark("@f_sandaoEX") == 0 then
				if player:hasSkill("f_sandaoEX") then
					room:detachSkillFromPlayer(player, "f_sandaoEX", true)
					if player:getMark("f_sandaoEX") > 0 then
						room:attachSkillToPlayer(player, "f_sandaoC")
					else
						room:attachSkillToPlayer(player, "f_sandaoD")
						room:setPlayerFlag(player, "f_sandaoUse", 0)
						room:setPlayerFlag(player, "f_sandaoResp", 0)
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("f_sandaoEXkill") then skills:append(f_sandaoEXkill) end

--

--神刘备-威力加强版
f_shenliubeiEX = sgs.General(extension_f, "f_shenliubeiEX", "god", 8, true, true, false, 6)

f_longnu = sgs.CreatePhaseChangeSkill{
	name = "f_longnu",
	priority = {3, 2},
	change_skill = true,
	frequency = sgs.Skill_Compulsory,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		local n = player:getChangeSkillState(self:objectName())
		if player:getPhase() == sgs.Player_Play then
			--龙怒·阳
			if n == 1 then
			    room:setChangeSkillState(player, self:objectName(), 2)
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
				room:loseMaxHp(player, 1)
				room:drawCards(player, 1, self:objectName())
				room:acquireSkill(player, "f_longnu_yang", false)
				room:acquireSkill(player, "f_longnu_yangg", false)
				room:filterCards(player, player:getCards("h"), true)
			--龙怒·阴
			elseif n == 2 then
			    room:setChangeSkillState(player, self:objectName(), 1)
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
				room:loseMaxHp(player, 1)
				room:drawCards(player, 1, self:objectName())
				room:acquireSkill(player, "f_longnu_yin", false)
				room:acquireSkill(player, "f_longnu_yinn", false)
				room:filterCards(player, player:getCards("h"), true)
			end
		end
	end,
}
----
f_longnu_yang = sgs.CreateFilterSkill{
	name = "f_longnu_yang",
	view_filter = function(self, to_select)
		return (to_select:isRed() or to_select:isKindOf("EquipCard")) and not to_select:isEquipped() and not (to_select:isRed() and to_select:isKindOf("EquipCard"))
	end,
	view_as = function(self, card)
		local FireSlash = sgs.Sanguosha:cloneCard("fire_slash", card:getSuit(), card:getNumber())
		FireSlash:setSkillName("f_longnu_yang")
		local new = sgs.Sanguosha:getWrappedCard(card:getId())
		new:takeOver(FireSlash)
		return new
	end,
}
f_longnu_yin = sgs.CreateFilterSkill{
	name = "f_longnu_yin",
	view_filter = function(self, to_select)
		return (to_select:isBlack() or to_select:isKindOf("TrickCard")) and not to_select:isEquipped() and not (to_select:isBlack() and to_select:isKindOf("TrickCard"))
	end,
	view_as = function(self, card)
		local ThunderSlash = sgs.Sanguosha:cloneCard("thunder_slash", card:getSuit(), card:getNumber())
		ThunderSlash:setSkillName("f_longnu_yin")
		local new = sgs.Sanguosha:getWrappedCard(card:getId())
		new:takeOver(ThunderSlash)
		return new
	end,
}
--
f_longnu_yangg = sgs.CreateFilterSkill{
	name = "f_longnu_yangg",
	view_filter = function(self, to_select)
		return (to_select:isRed() and to_select:isKindOf("EquipCard")) and not to_select:isEquipped()
	end,
	view_as = function(self, card)
		local FireSlash = sgs.Sanguosha:cloneCard("fire_slash", card:getSuit(), card:getNumber())
		FireSlash:setSkillName("f_longnu_yangg")
		local new = sgs.Sanguosha:getWrappedCard(card:getId())
		new:takeOver(FireSlash)
		return new
	end,
}
f_longnu_yinn = sgs.CreateFilterSkill{
	name = "f_longnu_yinn",
	view_filter = function(self, to_select)
		return (to_select:isBlack() and to_select:isKindOf("TrickCard")) and not to_select:isEquipped()
	end,
	view_as = function(self, card)
		local ThunderSlash = sgs.Sanguosha:cloneCard("thunder_slash", card:getSuit(), card:getNumber())
		ThunderSlash:setSkillName("f_longnu_yinn")
		local new = sgs.Sanguosha:getWrappedCard(card:getId())
		new:takeOver(ThunderSlash)
		return new
	end,
}
----
f_longnu_DRbuff = sgs.CreateTargetModSkill{
    name = "f_longnu_DRbuff",
	pattern = "Slash",
	distance_limit_func = function(self, from, card, to)
	    if card:getSkillName() == "f_longnu_yang" or card:getSkillName() == "f_longnu_yin" or card:getSkillName() == "f_longnu_yangg" or card:getSkillName() == "f_longnu_yinn" then
			return 1000
		else
			return 0
		end
	end,
	residue_func = function(self, from, card, to)
		if card:getSkillName() == "f_longnu_yang" or card:getSkillName() == "f_longnu_yin" or card:getSkillName() == "f_longnu_yangg" or card:getSkillName() == "f_longnu_yinn" then
			return 1000
		else
			return 0
		end
	end,
}
f_longnu_buffs = sgs.CreateTriggerSkill{
    name = "f_longnu_buffs",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.CardFinished, sgs.TargetSpecified, sgs.EventPhaseChanging, sgs.QuitDying},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
        local use = data:toCardUse()
		local change = data:toPhaseChange()
		if event == sgs.CardUsed then
			if use.from:objectName() ~= player:objectName() or not player:hasSkill("f_longnu") then return false end
			if use.card:isKindOf("FireSlash") and (use.card:getSkillName() == "f_longnu_yang" or use.card:getSkillName() == "f_longnu_yangg") then
				room:broadcastSkillInvoke("f_longnu", 3)
			elseif use.card:isKindOf("ThunderSlash") and (use.card:getSkillName() == "f_longnu_yin" or use.card:getSkillName() == "f_longnu_yinn") then
				room:broadcastSkillInvoke("f_longnu", 4)
			elseif player:getPhase() == sgs.Player_Play and use.card:getSkillName() == "f_longnu_yangg" then
				room:sendCompulsoryTriggerLog(player, "f_longnu_yangg")
				player:setFlags("f_longnuPFfrom")
				for _, wg in sgs.qlist(use.to) do
					wg:setFlags("f_longnuPFto")
					room:addPlayerMark(wg, "Armor_Nullified")
				end
			end
		elseif event == sgs.CardFinished and use.card:getSkillName() == "f_longnu_yangg" then
		    if not player:hasFlag("f_longnuPFfrom") then return false end
			for _, wg in sgs.qlist(room:getAllPlayers()) do
				if wg:hasFlag("f_longnuPFto") then
					wg:setFlags("-f_longnuPFto")
					if wg:getMark("Armor_Nullified") then
						room:removePlayerMark(wg, "Armor_Nullified")
					end
				end
			end
			player:setFlags("-f_longnuPFfrom")
		elseif event == sgs.TargetSpecified then
			if use.card:getSkillName() == "f_longnu_yinn" and use.from:objectName() == player:objectName() and player:hasSkill("f_longnu") then
				room:sendCompulsoryTriggerLog(player, "f_longnu_yinn")
				local no_respond_list = use.no_respond_list
				for _, wg in sgs.qlist(use.to) do
					table.insert(no_respond_list, wg:objectName())
				end
				use.no_respond_list = no_respond_list
				data:setValue(use)
			end
		elseif event == sgs.EventPhaseChanging then
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
		    	if p:hasSkill("f_longnu_yang") then
			    	room:detachSkillFromPlayer(p, "f_longnu_yang")
				end
				if p:hasSkill("f_longnu_yangg") then
			    	room:detachSkillFromPlayer(p, "f_longnu_yangg")
				end
				if p:hasSkill("f_longnu_yin") then
			    	room:detachSkillFromPlayer(p, "f_longnu_yin")
				end
				if p:hasSkill("f_longnu_yinn") then
			    	room:detachSkillFromPlayer(p, "f_longnu_yinn")
				end
		    end
		elseif event == sgs.QuitDying then
			if not player:isAlive() then return false end
			local current = room:getCurrent()
			if current:hasSkill("f_longnu") then
				local choice = room:askForChoice(current, "f_longnu", "1+2")
				if choice == "1" then
					room:sendCompulsoryTriggerLog(current, "f_longnu")
					room:broadcastSkillInvoke("f_longnu", math.random(1,2))
					room:loseHp(current, 1)
					room:drawCards(current, 1, "f_longnu")
				else
					room:sendCompulsoryTriggerLog(current, "f_longnu")
					room:broadcastSkillInvoke("f_longnu", math.random(1,2))
					room:loseMaxHp(current, 1)
					room:drawCards(current, 1, "f_longnu")
				end
			end
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
f_shenliubeiEX:addSkill(f_longnu)
if not sgs.Sanguosha:getSkill("f_longnu_yang") then skills:append(f_longnu_yang) end
if not sgs.Sanguosha:getSkill("f_longnu_yangg") then skills:append(f_longnu_yangg) end
if not sgs.Sanguosha:getSkill("f_longnu_yin") then skills:append(f_longnu_yin) end
if not sgs.Sanguosha:getSkill("f_longnu_yinn") then skills:append(f_longnu_yinn) end
if not sgs.Sanguosha:getSkill("f_longnu_DRbuff") then skills:append(f_longnu_DRbuff) end
if not sgs.Sanguosha:getSkill("f_longnu_buffs") then skills:append(f_longnu_buffs) end

f_shenliubeiEX:addSkill("jieying")

--神董卓
f_shendongzhuo = sgs.General(extension_f, "f_shendongzhuo", "god", 5, true)

f_xiongyan = sgs.CreateTriggerSkill{
	name = "f_xiongyan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play and room:askForSkillInvoke(player, self:objectName(), data) then
			room:setPlayerFlag(player, "f_shendongzhuo") --AI判断敌友用
			room:broadcastSkillInvoke(self:objectName(), 1)
			local judge = sgs.JudgeStruct()
			judge.good = true
			judge.play_animation = false
			judge.reason = "f_xiongyan"
			judge.who = player
			room:judge(judge)
			local n = judge.card:getNumber()
			room:setPlayerFlag(player, self:objectName()) --点名判断辅助标志
			while n > 0 do
				for _, p in sgs.qlist(room:getAllPlayers()) do --进行一次点名
					if p:hasFlag(self:objectName()) then
						room:setPlayerFlag(p, "-f_xiongyan")
						room:setPlayerFlag(p:getNextAlive(), self:objectName()) --将辅助标志移给此时被点名者（下家），准备结算或下一次点名
						break
					end
				end
				n = n - 1
			end
			if n == 0 then --点名完了，开始结算
				if player:hasFlag(self:objectName()) then --最终点名到自己
					local log = sgs.LogMessage()
				    log.type = "$f_xiongyan_self"
				    log.from = player
				    room:sendLog(log)
					room:broadcastSkillInvoke(self:objectName(), 2)
					local analeptic = sgs.Sanguosha:cloneCard("Analeptic", sgs.Card_NoSuit, 0)
					analeptic:setSkillName("f_xiongyann") --防止乱播报语音
					room:useCard(sgs.CardUseStruct(analeptic, player, player, false))
					if player:isWounded() then room:recover(player, sgs.RecoverStruct(player)) end
				else --最终点名到别人
					room:broadcastSkillInvoke(self:objectName(), 3)
					for _, oc in sgs.qlist(room:getOtherPlayers(player)) do
						if oc:hasFlag(self:objectName()) then
							local log = sgs.LogMessage()
				    		log.type = "$f_xiongyan_others"
				    		log.from = player
							log.to:append(oc)
				    		room:sendLog(log)
							room:setPlayerFlag(oc, "-f_xiongyan")
							local choices = {}
							table.insert(choices, "1")
							if oc:getHandcardNum() + oc:getEquips():length() >= 2 then
			    				table.insert(choices, "2=" .. player:objectName())
							end
							local choice = room:askForChoice(oc, self:objectName(), table.concat(choices, "+"))
							if choice == "1" then
								room:loseHp(oc, 1)
								if not oc:isChained() then room:setPlayerChained(oc) end
							else
								local card = room:askForExchange(oc, self:objectName(), 999, 2, true, "#f_xiongyan:".. player:getGeneralName())
								if card then
									room:obtainCard(player, card, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), oc:objectName(), self:objectName(), ""), false)
									room:setPlayerFlag(oc, "f_sdzForE") --自己的AI判断敌友用
									if room:askForSkillInvoke(player, "@f_xiongyanDraw", data) then
										local m = card:getSubcards():length()
										room:drawCards(oc, m, self:objectName())
									end
									room:setPlayerFlag(oc, "-f_sdzForE")
								end
							end
						end
					end
				end
			end
			room:setPlayerFlag(player, "-f_shendongzhuo")
		end
	end,
}
f_shendongzhuo:addSkill(f_xiongyan)

f_qianduCard = sgs.CreateSkillCard{
	name = "f_qianduCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
	    room:removePlayerMark(source, "@f_qiandu")
		room:doLightbox("QianduAnimate")
		local ChangAn = targets[1]
		room:swapSeat(source, ChangAn)
		local n = source:distanceTo(ChangAn)*2
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if n > 0 and source:canDiscard(p, "ej") and p:getEquips():length() + p:getJudgingArea():length() > 0 then
				local m = 1
				while n > 0 and m > 0 and p:getEquips():length() + p:getJudgingArea():length() > 0 do
					local ruins = room:askForCardChosen(source, p, "ej", "f_qiandu", false, sgs.Card_MethodDiscard, sgs.IntList(), true)
					if ruins < 0 then --若中途取消弃牌，不再询问对该角色的弃牌，直接跳到其下家
						m = m - 1
					else
						room:throwCard(ruins, p, source)
						n = n - 1
					end
				end
			end
		end
		room:acquireSkill(source, "f_xibeng")
	end,
}
f_qianduVS = sgs.CreateZeroCardViewAsSkill{
    name = "f_qiandu",
	view_as = function()
		return f_qianduCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@f_qiandu") > 0 and not player:hasFlag("f_qiandu_limited")
	end,
	response_pattern = "@@f_qiandu",
}
f_qiandu = sgs.CreateTriggerSkill{
	name = "f_qiandu",
	frequency = sgs.Skill_Limited,
	limit_mark = "@f_qiandu",
	view_as_skill = f_qianduVS,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start and player:getMark("@f_qiandu") > 0 then
			if not room:askForUseCard(player, "@@f_qiandu", "@f_qiandu-card") then
				room:setPlayerFlag(player, "f_qiandu_limited")
			end
		end
	end,
}
f_shendongzhuo:addSkill(f_qiandu)
f_shendongzhuo:addRelateSkill("f_xibeng")
--“析崩”
f_xibeng = sgs.CreateTriggerSkill{
	name = "f_xibeng",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreHpRecover, sgs.CardsMoveOneTime}, --sgs.EventPhaseStart, sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.PreHpRecover then
			local recover = data:toRecover()
			if recover.who:objectName() == player:objectName() and not player:hasFlag("Global_Dying") then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local n = recover.recover + 2
				room:drawCards(player, n, self:objectName())
				return true
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceHand
			and not move.card_ids:isEmpty() and move.reason.m_skillName == self:objectName() then
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					room:setCardFlag(card, "f_xibengCard")
				end
			end
		--[[else
			if player:getPhase() ~= sgs.Player_Discard then return false end
			if event == sgs.EventPhaseStart then
				for _, h in sgs.qlist(player:getCards("h")) do
					if h:hasFlag("f_xibengCard") then
						room:addPlayerMark(player, self:objectName())
					end
				end
			elseif event == sgs.EventPhaseEnd then room:setPlayerMark(player, self:objectName(), 0) end]]
		end
	end,
}
f_xibengMaxCards = sgs.CreateMaxCardsSkill{ --擦边球写法
	name = "f_xibengMaxCards",
	extra_func = function(self, player)
		local n = 0
		if not player:hasSkill("f_xibeng") then return n end
		for _, card in sgs.list(player:getHandcards()) do
			if card:hasFlag("f_xibengCard") then
			n = n + 1 end
		end
		return n
	end,
}
if not sgs.Sanguosha:getSkill("f_xibeng") then skills:append(f_xibeng) end
if not sgs.Sanguosha:getSkill("f_xibengMaxCards") then skills:append(f_xibengMaxCards) end

--神罗贯中
f_shenluoguanzhong = sgs.General(extension_f, "f_shenluoguanzhong", "god", 4, true)

f_yanyiStart = sgs.CreateTriggerSkill{
	name = "f_yanyiStart",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.GameStart, sgs.TurnStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local mhp = player:getMaxHp()
		local hp = player:getHp()
		room:broadcastSkillInvoke(self:objectName())
		local allnames = sgs.Sanguosha:getLimitedGeneralNames() 
		for _, p in sgs.qlist(room:getPlayers()) do
			local name = p:getGeneralName()
			allnames[name] = nil
		end
        math.randomseed(tostring(os.time()):reverse():sub(1,7))
		local targets = {}
		for i = 1, 1, 1 do
			local count = #allnames
			local index = math.random(1, count)
			local selected = allnames[index]
			table.insert(targets, selected)
			allnames[selected] = nil
		end
		local generals = table.concat(targets, "+")
		local general = room:askForGeneral(player, generals)
		room:changeHero(player, general, false, false, true, true)
		room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp))
		room:setPlayerProperty(player, "hp", sgs.QVariant(hp))
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_yanyi")
	end,
}
f_yanyiStage = sgs.CreateTriggerSkill{
	name = "f_yanyiStage",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Judge)
		or (event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Finish) then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				local mhp = player:getMaxHp()
				local hp = player:getHp()
				room:broadcastSkillInvoke(self:objectName())
				local allnames = sgs.Sanguosha:getLimitedGeneralNames() 
				for _, p in sgs.qlist(room:getPlayers()) do
					local name = p:getGeneralName()
					allnames[name] = nil
				end
				math.randomseed(tostring(os.time()):reverse():sub(1,7))
				local targets = {}
				for i = 1, 1, 1 do
					local count = #allnames
					local index = math.random(1, count)
					local selected = allnames[index]
					table.insert(targets, selected)
					allnames[selected] = nil
				end
				local generals = table.concat(targets, "+")
				local general = room:askForGeneral(player, generals)
				room:changeHero(player, general, false, false, true, true)
				room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp))
				room:setPlayerProperty(player, "hp", sgs.QVariant(hp))
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_yanyi")
	end,
}
f_yanyiCard = sgs.CreateSkillCard{
	name = "f_yanyiCard",
	target_fixed = true,
	on_use = function(self, room, player, targets)
	    local mhp = player:getMaxHp()
		local hp = player:getHp()
		local allnames = sgs.Sanguosha:getLimitedGeneralNames() 
		for _, p in sgs.qlist(room:getPlayers()) do
			local name = p:getGeneralName()
			allnames[name] = nil
		end
        math.randomseed(tostring(os.time()):reverse():sub(1,7))
		local targetss = {}
		for i = 1, 1, 1 do
			local count = #allnames
			local index = math.random(1, count)
			local selected = allnames[index]
			table.insert(targetss, selected)
			allnames[selected] = nil
		end
		local generals = table.concat(targetss, "+")
		local general = room:askForGeneral(player, generals)
		room:changeHero(player, general, false, false, true, true)
		room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp))
		room:setPlayerProperty(player, "hp", sgs.QVariant(hp))
	end,
}
f_yanyi = sgs.CreateZeroCardViewAsSkill{
    name = "f_yanyi",
	view_as = function()
		return f_yanyiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#f_yanyiCard")
	end,
}
f_shenluoguanzhong:addSkill(f_yanyi)
if not sgs.Sanguosha:getSkill("f_yanyiStart") then skills:append(f_yanyiStart) end
if not sgs.Sanguosha:getSkill("f_yanyiStage") then skills:append(f_yanyiStage) end

--

--神左慈
f_shenzuoci = sgs.General(extension_f, "f_shenzuoci", "god", 3, true)

--==攻击特效==-- --左慈手杀传说动皮“使役鬼神”的出框动画，特别感谢珂酱的技术支持！（设置成仅作为主将可以触发，避免与其他动皮武将双将时的动画冲突）
f_shenzuociAttack = sgs.CreateTriggerSkill{
	name = "f_shenzuociAttack",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if (use.card:isKindOf("Slash") or use.card:isKindOf("Duel") or use.card:isKindOf("AOE"))
		and use.from:objectName() == player:objectName() then
			room:broadcastSkillInvoke("f_quanshen")
			room:setEmotion(player, "f_shenzuoci_small")
			room:getThread():delay(1000)
		end
	end,
	can_trigger = function(self, player)
		return player:getGeneralName() == "f_shenzuoci" --or player:getGeneral2Name() == "f_shenzuoci"
	end,
}
if not sgs.Sanguosha:getSkill("f_shenzuociAttack") then skills:append(f_shenzuociAttack) end
---

f_quanshen = sgs.CreateTriggerSkill{
	name = "f_quanshen",
	priority = -100,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:sendCompulsoryTriggerLog(player, self:objectName())
		room:broadcastSkillInvoke(self:objectName())
		for _, p in sgs.qlist(room:getAllPlayers()) do
			room:setPlayerProperty(p, "kingdom", sgs.QVariant("god"))
		end
	end,
}
f_shenzuoci:addSkill(f_quanshen)

f_yishiGMS = sgs.CreateTriggerSkill{
	name = "f_yishiGMS",
	global = true, priority = 9999, --保证最高优先级，不然某些回合开始时的技能用不了/没效果
	frequency = sgs.Skill_Frequent,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local n = player:getHp()
		if n - 1 <= 0 then return false end
		local sks = player:getTag("f_yishi"):toString():split("+")
		room:sendCompulsoryTriggerLog(player, "f_yishi")
		room:broadcastSkillInvoke("f_yishi")
		local all_generals = sgs.Sanguosha:getLimitedGeneralNames()
		local god_generals = {}
		for _, name in ipairs(all_generals) do
			local general = sgs.Sanguosha:getGeneral(name)
			if general:getKingdom() == "god" then
				table.insert(god_generals, name)
			end
		end
		for _, p in sgs.qlist(room:getAllPlayers(true)) do
			if table.contains(god_generals, p:getGeneralName()) then
				table.removeOne(god_generals, p:getGeneralName())
			end
		end
		local god_general = {}
		for i = 1, n+1 do
			local first = god_generals[math.random(1, #god_generals)]
			table.insert(god_general, first)
			table.removeOne(god_generals, first)
		end
		local m = n - 1
		while m > 0 do
			local generals = table.concat(god_general, "+")
			local general = sgs.Sanguosha:getGeneral(room:askForGeneral(player, generals))
			local skill_names = {}
			for _, skill in sgs.qlist(general:getVisibleSkillList()) do
				table.insert(skill_names, skill:objectName())
			end
			if #skill_names > 0 then
				local one = room:askForChoice(player, "f_yishi", table.concat(skill_names, "+"))
				room:acquireSkill(player, one)
				table.insert(sks, one) --登记为以此法获得的技能
				for _, nam in ipairs(god_general) do
					local generall = sgs.Sanguosha:getGeneral(nam)
					if generall:objectName() == general:objectName() then
						table.removeOne(god_general, nam)
					end
				end
				m = m - 1
			end
		end
		player:setTag("f_yishi", sgs.QVariant(table.concat(sks, "+")))
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_yishi")
	end,
}
f_yishiCard = sgs.CreateSkillCard{
	name = "f_yishiCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local sks = source:getTag("f_yishi"):toString():split("+")
		local n = 0
		for _, s in ipairs(sks) do --先检测玩家有没有记录里的技能，没有则不能选2选项和3选项
			if source:hasSkill(s) then
				n = n + 1
			end
		end
		local hp = source:getHp()
		if hp < 1 then hp = 1 end
	    local choices = {}
		if source:getHandcardNum() >= hp and source:getEquips():length() > 0 and source:canDiscard(source, "he") then
			table.insert(choices, "1=" .. hp)
		end
		if n > 0 then
			table.insert(choices, "2")
			table.insert(choices, "3")
		end
		table.insert(choices, "cancel")
		local choice = room:askForChoice(source, "f_yishi", table.concat(choices, "+"))
		if choice == "cancel" then
			room:addPlayerHistory(source, "#f_yishiCard", -1)
			return
		end
		if choice == "1=" .. hp then
			room:askForDiscard(source, "f_yishi", hp, hp)
			local card_id = room:askForCardChosen(source, source, "e", "f_yishi", false, sgs.Card_MethodDiscard)
			room:throwCard(sgs.Sanguosha:getCard(card_id), source, source)
			local all_generals = sgs.Sanguosha:getLimitedGeneralNames()
			local god_generals = {}
			for _, name in ipairs(all_generals) do
				local general = sgs.Sanguosha:getGeneral(name)
				if general:getKingdom() == "god" then
					table.insert(god_generals, name)
				end
			end
			for _, p in sgs.qlist(room:getAllPlayers(true)) do
				if table.contains(god_generals, p:getGeneralName()) then
					table.removeOne(god_generals, p:getGeneralName())
				end
			end
			local god_general = {}
			for i = 1, hp do
				local first = god_generals[math.random(1, #god_generals)]
				table.insert(god_general, first)
				table.removeOne(god_generals, first)
			end
			local generals = table.concat(god_general, "+")
			local general = sgs.Sanguosha:getGeneral(room:askForGeneral(source, generals))
			local skill_names = {}
			for _, skill in sgs.qlist(general:getVisibleSkillList()) do
				table.insert(skill_names, skill:objectName())
			end
			if #skill_names > 0 then
				local one = room:askForChoice(source, "f_yishi", table.concat(skill_names, "+"))
				room:broadcastSkillInvoke("f_yishi")
				room:acquireSkill(source, one)
				table.insert(sks, one) --登记为以此法获得的技能
			end
		elseif choice == "2" or choice == "3" then
			local reduce_skilllist = {}
			for _, lsk in ipairs(sks) do
				if source:hasSkill(lsk) then
					table.insert(reduce_skilllist, lsk)
				end
			end
			local off = room:askForChoice(source, "f_yishi", table.concat(reduce_skilllist, "+"))
			room:detachSkillFromPlayer(source, off)
			if choice == "2" then
				local all_generals = sgs.Sanguosha:getLimitedGeneralNames()
				local god_generals = {}
				for _, name in ipairs(all_generals) do
					local general = sgs.Sanguosha:getGeneral(name)
					if general:getKingdom() == "god" then
						table.insert(god_generals, name)
					end
				end
				local god_general = {}
				local first = god_generals[math.random(1, #god_generals)]
				table.insert(god_general, first)
				local generals = table.concat(god_general, "+")
				local general = sgs.Sanguosha:getGeneral(room:askForGeneral(source, generals))
				local skill_names = {}
				for _, skill in sgs.qlist(general:getVisibleSkillList()) do
					table.insert(skill_names, skill:objectName())
				end
				if #skill_names > 0 then
					local one = skill_names[math.random(1, #skill_names)]
					room:broadcastSkillInvoke("f_yishi")
					room:acquireSkill(source, one)
					table.insert(sks, one) --登记为以此法获得的技能
				end
			elseif choice == "3" then
				if source:isWounded() then
					if room:askForChoice(source, "f_yishi", "draw+recover") == "recover" then
						room:broadcastSkillInvoke("f_yishi")
						local recover = sgs.RecoverStruct()
						recover.who = source
						room:recover(source, recover)
					else
						room:broadcastSkillInvoke("f_yishi")
						room:drawCards(source, 2, "f_yishi")
					end
				else
					room:broadcastSkillInvoke("f_yishi")
					room:drawCards(source, 2, "f_yishi")
				end
			end
		end
		source:setTag("f_yishi", sgs.QVariant(table.concat(sks, "+")))
	end,
}
f_yishi = sgs.CreateZeroCardViewAsSkill{
    name = "f_yishi",
	view_as = function()
		return f_yishiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#f_yishiCard")
	end,
}
f_shenzuoci:addSkill(f_yishi)
if not sgs.Sanguosha:getSkill("f_yishiGMS") then skills:append(f_yishiGMS) end

f_mizong = sgs.CreateMasochismSkill{
	name = "f_mizong",
	on_damaged = function(self, player, damage)
		local room = player:getRoom()
		local data = sgs.QVariant()
		if room:askForSkillInvoke(player, self:objectName(), data) then
			local loseskill = {}
			for _, skill in sgs.qlist(player:getSkillList()) do
				table.insert(loseskill, skill:objectName())
			end
			room:broadcastSkillInvoke(self:objectName(), 1)
			local choice = room:askForChoice(player, self:objectName(), table.concat(loseskill, "+"))
			local other = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName())
			room:detachSkillFromPlayer(player, choice)
			room:acquireSkill(other, choice)
			room:broadcastSkillInvoke(self:objectName(), 2)
			if player:hasSkill(self:objectName()) then room:addPlayerMark(player, "&f_mizongRMC")
			end
		end
	end,
}
f_mizongReduceMC = sgs.CreateMaxCardsSkill{
	name = "f_mizongReduceMC",
	extra_func = function(self, player)
		if player:getMark("&f_mizongRMC") > 0 then
			local n = player:getMark("&f_mizongRMC")
			return -n
		else
			return 0
		end
	end,
}
f_shenzuoci:addSkill(f_mizong)
if not sgs.Sanguosha:getSkill("f_mizongReduceMC") then skills:append(f_mizongReduceMC) end

--神刘禅
f_shenliushan = sgs.General(extension_f, "f_shenliushan$", "god", 4, true)

f_leji = sgs.CreateTriggerSkill{
	name = "f_leji",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirmed, sgs.CardFinished, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if use.card:isKindOf("Indulgence") then
				for _, p in sgs.qlist(use.to) do --找出被使用者并锁定
					room:setPlayerFlag(p, "f_lejiTarget")
				end
				for _, sls in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					if sls:hasFlag("f_lejiTarget") or sls:hasFlag("f_lejiNI") then continue end
					if sls:getJudgingArea():length() > 0 then
						local n = 0
						for _, c in sgs.qlist(sls:getJudgingArea()) do
							if c:isKindOf("Indulgence") then n = n + 1 end
						end
						if n > 0 then continue end
					end
					if not room:askForSkillInvoke(sls, self:objectName(), data) then room:setPlayerFlag(sls, "f_lejiNI") continue end
					room:broadcastSkillInvoke(self:objectName())
					use.to:removeOne(player)
					use.to:append(sls)
					room:sortByActionOrder(use.to)
					data:setValue(use)
				end
				for _, p in sgs.qlist(room:getAllPlayers()) do --清除所有锁定用标志
					if p:hasFlag("f_lejiTarget") then room:setPlayerFlag(p, "-f_lejiTarget") end
				end
			end
		elseif event == sgs.CardFinished then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("f_lejiNI") then
					room:setPlayerFlag(p, "-f_lejiNI")
				end
			end
		elseif event == sgs.EventPhaseStart then
			if player:hasSkill(self:objectName()) and player:getPhase() == sgs.Player_Discard then
				local can_invoke = false
				for _, cjl in sgs.qlist(room:getOtherPlayers(player)) do
					if cjl:getJudgingArea():length() > 0 then
						local n = 0
						for _, c in sgs.qlist(cjl:getJudgingArea()) do
							if c:isKindOf("Indulgence") then n = n + 1 end
						end
						if n > 0 then
							if not cjl:hasFlag("f_lejiFrom") then room:setPlayerFlag(cjl, "f_lejiFrom") end --找到可以移动【乐不思蜀】的其他角色
							if not player:hasFlag("f_lejiInvokeMove") then room:setPlayerFlag(player, "f_lejiInvokeMove") end --可选2选项的条件
							can_invoke = true
						end
					end
				end
				if not player:isNude() then
					if not player:hasFlag("f_lejiInvokeUse") then room:setPlayerFlag(player, "f_lejiInvokeUse") end --可选1选项的条件
					can_invoke = true
				end
				if player:getJudgingArea():length() > 0 then
					local n = 0
					for _, c in sgs.qlist(player:getJudgingArea()) do
						if c:isKindOf("Indulgence") then n = n + 1 end
					end
					if n > 0 then can_invoke = false end --如果自己判定区里有【乐不思蜀】，那还是不能发动
				end
				if can_invoke then
					if room:askForSkillInvoke(player, self:objectName(), data) then
						local choices = {}
						if player:hasFlag("f_lejiInvokeUse") then
							table.insert(choices, "1")
						end
						if player:hasFlag("f_lejiInvokeMove") then
							table.insert(choices, "2")
						end
						table.insert(choices, "cancel")
						local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
						if choice == "1" then
							local IdgCard = room:askForExchange(player, self:objectName(), 1, 1, true, "f_lejiPush")
							local Indulgence = sgs.Sanguosha:cloneCard("indulgence", IdgCard:getSuit(), IdgCard:getNumber())
							Indulgence:setSkillName(self:objectName())
							Indulgence:addSubcard(IdgCard)
							if not player:isProhibited(player, Indulgence) then
								room:useCard(sgs.CardUseStruct(Indulgence, player, player))
							else
								Indulgence:deleteLater()
							end
						elseif choice == "2" then
							local CJL = sgs.SPlayerList()
							for _, p in sgs.qlist(room:getOtherPlayers(player)) do
								if p:hasFlag("f_lejiFrom") then
									CJL:append(p)
								end
							end
							local BSS
							if CJL:length() > 1 then
								BSS = room:askForPlayerChosen(player, CJL, self:objectName(), "f_lejiIndulgenceMove")
							elseif CJL:length() == 1 then --不得已而为之
								for _, p in sgs.qlist(room:getOtherPlayers(player)) do
									if p:hasFlag("f_lejiFrom") then
										BSS = p
										break
									end
								end
							end
							local ids = sgs.IntList()
							for _, c in sgs.qlist(BSS:getJudgingArea()) do
								if c:isKindOf("Indulgence") then
									ids:append(c:getEffectiveId())
								end
							end
							local card, place
							for _, id in sgs.qlist(ids) do
								if id then
									card = sgs.Sanguosha:getCard(id)
									place = room:getCardPlace(id)
								end
							end
							local tag = sgs.QVariant()
							tag:setValue(BSS)
							room:setTag("f_lejiTarget", tag)
							room:moveCardTo(card, BSS, player, place, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, player:objectName(), self:objectName(), ""))
							room:removeTag("f_lejiTarget")
						end
					end
				end
				--标志清除
				if player:hasFlag("f_lejiInvokeUse") then room:setPlayerFlag(player, "-f_lejiInvokeUse") end
				if player:hasFlag("f_lejiInvokeMove") then room:setPlayerFlag(player, "-f_lejiInvokeMove") end
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:hasFlag("f_lejiFrom") then room:setPlayerFlag(p, "-f_lejiFrom") end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_shenliushan:addSkill(f_leji)

f_wuyou = sgs.CreateProhibitSkill{
	name = "f_wuyou",
	frequency = sgs.Skill_Frequent,
	is_prohibited = function(self, from, to, card)
		--[[local n = 0
		if to:hasSkill(self:objectName()) and to:getJudgingArea():length() > 0 then
			for _, c in sgs.qlist(to:getCards("j")) do
				if c:isKindOf("Indulgence") then n = n + 1 end
			end
		end
		return to:hasSkill(self:objectName()) and ((card:isKindOf("Slash") or card:isKindOf("Duel")) and not card:isVirtualCard()) and n > 0]]
		return to:hasSkill(self:objectName()) and to:getMark(self:objectName()) > 0 and ((card:isKindOf("Slash") or card:isKindOf("Duel")) and not card:isVirtualCard())
	end,
}
f_wuyouo = sgs.CreateTriggerSkill{ --当【乐不思蜀】进入神刘禅的判定区时播放，就像诸葛亮的“空城”一样，代表“无忧”开始起作用了
    name = "f_wuyouo",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.to and move.to:objectName() == player:objectName() and player:hasSkill("f_wuyou") then
			for _, id in sgs.qlist(move.card_ids) do
				local card = sgs.Sanguosha:getCard(id)
				if card:isKindOf("Indulgence") then
					for _, c in sgs.qlist(player:getJudgingArea()) do --是你逼我的
						if c:isKindOf("Indulgence") then
							if player:getMark("f_wuyou") == 0 then room:addPlayerMark(player, "f_wuyou") end
							room:broadcastSkillInvoke("f_wuyou")
						end
					end
				end
			end
		elseif move.from and move.from:objectName() == player:objectName() then
			for _, id in sgs.qlist(move.card_ids) do
				local card = sgs.Sanguosha:getCard(id)
				if card:isKindOf("Indulgence") then
					local n = 0
					for _, c in sgs.qlist(player:getJudgingArea()) do
						if c:isKindOf("Indulgence") then
							n = n + 1
						end
					end
					if n == 0 then --n值没变化，代表确实是【乐不思蜀】离开的判定区
						room:setPlayerMark(player, "f_wuyou", 0) --虽然前置条件并不严谨，但能保证测定一旦判定区无乐就撤标记
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_shenliushan:addSkill(f_wuyou)
if not sgs.Sanguosha:getSkill("f_wuyouo") then skills:append(f_wuyouo) end

f_dansha = sgs.CreateTriggerSkill{
    name = "f_dansha$",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.BeforeCardsMove, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local move = data:toMoveOneTime()
		if event == sgs.BeforeCardsMove then
			if move.from and move.from:objectName() == player:objectName() then
				for _, c in sgs.qlist(player:getJudgingArea()) do
					if c:isKindOf("Indulgence") then
						room:addPlayerMark(player, self:objectName()) --“单杀”启动前置条件标记
					end
				end
			end
		elseif event == sgs.CardsMoveOneTime then
			if move.from and move.from:objectName() == player:objectName() then
				local can_invoke = false
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if card:isKindOf("Indulgence") then
						local n = 0
						for _, c in sgs.qlist(player:getJudgingArea()) do
							if c:isKindOf("Indulgence") then
								n = n + 1
							end
						end
						if n == 0 and player:getMark(self:objectName()) > 0 then
							can_invoke = true
						end
					end
				end
				if can_invoke then
					if room:askForSkillInvoke(player, self:objectName(), data) then
						local smz = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName(), "f_danshaSiMaZhao")
						room:broadcastSkillInvoke(self:objectName())
						room:loseHp(smz, 2)
						if not smz:isAlive() then room:detachSkillFromPlayer(player, self:objectName())
						end
					end
				end
			end
			room:setPlayerMark(player, self:objectName(), 0)
		end
	end,
}
f_shenliushan:addSkill(f_dansha)

--神曹仁
f_shencaoren = sgs.General(extension_f, "f_shencaoren", "god", 4, true)

f_qizhen = sgs.CreateTriggerSkill{
    name = "f_qizhen",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {--[[sgs.TargetConfirmed]]sgs.TargetConfirming, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.TargetConfirming then
			local use = data:toCardUse()
			if (use.card:isKindOf("Slash") or use.card:isKindOf("TrickCard")) and use.from and use.from:objectName() ~= player:objectName()
			and use.to and use.to:contains(player) and use.to:length() == 1 and player:hasSkill(self:objectName()) then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					local judge = sgs.JudgeStruct()
					judge.pattern = ".|spade" --判定出♠：被破阵，等价于判定失败。
					judge.good = false
					judge.play_animation = true
					judge.reason = self:objectName()
					judge.who = player
					room:judge(judge)
					local jsuit = judge.card:getSuit()
					-- ♠
					if jsuit == sgs.Card_Spade then
						room:broadcastSkillInvoke(self:objectName(), 1)
						local log = sgs.LogMessage()
						log.type = "$f_qizhenSpadePZ"
						log.from = player
						log.to:append(use.from)
						room:sendLog(log)
						if not player:hasFlag("f_qizhen_beipo") then room:setPlayerCardLimitation(player, "use,response", ".|.|.|hand", false) end
						room:setPlayerFlag(player, "f_qizhen_beipo")
					-- ♣
					elseif jsuit == sgs.Card_Club then
						room:broadcastSkillInvoke(self:objectName(), 2)
						room:drawCards(player, 1, self:objectName())
					-- ♦
					elseif jsuit == sgs.Card_Diamond then
						room:broadcastSkillInvoke(self:objectName(), 3)
						--return true
						local nullified_list = use.nullified_list
						table.insert(nullified_list, player:objectName())
						use.nullified_list = nullified_list
						data:setValue(use)
					-- ♥
					elseif jsuit == sgs.Card_Heart then
						room:broadcastSkillInvoke(self:objectName(), 4)
						local lbj = use.from
						local log = sgs.LogMessage()
						log.type = "$f_qizhenHeartEXchange"
						log.from = player
						log.to:append(lbj)
						log.card_str = use.card:getEffectiveId()
						room:sendLog(log)
						for _, p in sgs.qlist(use.to) do
							use.to:removeOne(p)
						end
						use.from = player
						use.to:append(lbj)
						room:doAnimate(1, player:objectName(), lbj:objectName())
						data:setValue(use)
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("f_qizhen_beipo") then
					room:removePlayerCardLimitation(p, "use,response", ".|.|.|hand")
					room:setPlayerFlag(p, "-f_qizhen_beipo")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_shencaoren:addSkill(f_qizhen)

f_lijun = sgs.CreateMasochismSkill{
	name = "f_lijun",
	on_damaged = function(self, player, damage)
		local room = player:getRoom()
		local data = sgs.QVariant()
		if room:askForSkillInvoke(player, self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName(), 1)
			local choice = room:askForChoice(player, self:objectName(), "1+2")--"1+2+cancel")
			if choice == "1" then
				room:setPlayerFlag(player, "f_lijunChooseOne") --AI用，让AI知道其选择了1选项
				room:broadcastSkillInvoke(self:objectName(), 2)
				local weijun = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName())
				local hp = player:getLostHp()
				room:drawCards(weijun, hp, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), 2)
				if weijun:objectName() ~= player:objectName() then
					if player:getState() == "online" and room:askForSkillInvoke(player, "@f_lijunGHJ", data) then
						room:broadcastSkillInvoke(self:objectName(), 4)
						weijun:gainHujia(1)
					elseif player:getState() == "robot" then --电脑直接无脑给队友即可
						room:broadcastSkillInvoke(self:objectName(), 4)
						weijun:gainHujia(1)
					end
				end
				room:setPlayerFlag(player, "-f_lijunChooseOne")
			elseif choice == "2" then
				room:setPlayerFlag(player, "f_lijunChooseTwo") --AI用，让AI知道其选择了2选项
				room:broadcastSkillInvoke(self:objectName(), 3)
				local shujun = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName())
				local hp = shujun:getHp()
				local hc = shujun:getHandcardNum()
				if hp < hc then
					local n = hc - hp
					room:askForDiscard(shujun, self:objectName(), n, n)
					room:broadcastSkillInvoke(self:objectName(), 3)
				end
				if shujun:objectName() ~= player:objectName() then
					--资敌（
					if room:askForSkillInvoke(player, "@f_lijunGHJ", data) then
						room:broadcastSkillInvoke(self:objectName(), 4)
						shujun:gainHujia(1)
					end
				end
				room:setPlayerFlag(player, "-f_lijunChooseTwo")
			end
		end
	end,
}
f_shencaoren:addSkill(f_lijun)





--

--神赵云&陈到
f_shenZhaoyunChendao = sgs.General(extension_f, "f_shenZhaoyunChendao", "god", 4, true)

f_junzhen = sgs.CreateMaxCardsSkill{
	name = "f_junzhen",
	extra_func = function(self, player)
		if player:hasSkill(self:objectName()) then
			return 2
		else
			return 0
		end
	end,
}
f_junzhenAudio = sgs.CreateTriggerSkill{
    name = "f_junzhenAudio",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_Discard then return false end
		room:sendCompulsoryTriggerLog(player, "f_junzhen")
		room:notifySkillInvoked(player, "f_junzhen")
		room:broadcastSkillInvoke("f_junzhen")
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_junzhen") and player:getHandcardNum() > player:getHp()
	end,
}
f_shenZhaoyunChendao:addSkill(f_junzhen)
if not sgs.Sanguosha:getSkill("f_junzhenAudio") then skills:append(f_junzhenAudio) end

f_yonghunCard = sgs.CreateSkillCard{
	name = "f_yonghunCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:drawCards(source, 2, "f_yonghun")
	end,
}
f_yonghun = sgs.CreateZeroCardViewAsSkill{
    name = "f_yonghun",
	view_as = function()
		return f_yonghunCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#f_yonghunCard")
	end,
}
f_shenZhaoyunChendao:addSkill(f_yonghun)
----
f_yonghunMoveCardBuff = sgs.CreateTriggerSkill{
    name = "f_yonghunMoveCardBuff",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.to and move.to:objectName() == player:objectName() and move.reason.m_skillName == "f_yonghun" then
			for _, id in sgs.qlist(move.card_ids) do
				if room:getCardOwner(id):objectName() == player:objectName() and room:getCardPlace(id) == sgs.Player_PlaceHand then
					local card = sgs.Sanguosha:getCard(id)
					if card:isKindOf("Slash") then room:setCardFlag(card, "f_yonghunSlash")
					elseif card:isKindOf("Jink") then room:setCardFlag(card, "f_yonghunJink")
					elseif card:isKindOf("Peach") then room:setCardFlag(card, "f_yonghunPeach")
					elseif card:isKindOf("Analeptic") then room:setCardFlag(card, "f_yonghunAnaleptic")
					end
				end
			end
			--1.寻找其中的【酒】并询问发动效果
			for _, cd in sgs.qlist(player:getHandcards()) do
				if cd:hasFlag("f_yonghunAnaleptic") then
					if not room:askForUseCard(player, "@@f_yonghunAnaleptic", "@f_yonghunAnaleptic") then
						room:setCardFlag(cd, "-f_yonghunAnaleptic") --防止重复询问
					end
				end
			end
			for _, cd in sgs.qlist(player:getHandcards()) do
				if cd:hasFlag("f_yonghunAnaleptic") then
					room:askForUseCard(player, "@@f_yonghunAnaleptic", "@f_yonghunAnaleptic")
				end
			end
			--2.寻找其中的【桃】并询问发动效果
			for _, cd in sgs.qlist(player:getHandcards()) do
				if cd:hasFlag("f_yonghunPeach") then
					if not room:askForUseCard(player, "@@f_yonghunPeach", "@f_yonghunPeach") then
						room:setCardFlag(cd, "-f_yonghunPeach") --防止重复询问
					end
				end
			end
			for _, cd in sgs.qlist(player:getHandcards()) do
				if cd:hasFlag("f_yonghunPeach") then
					room:askForUseCard(player, "@@f_yonghunPeach", "@f_yonghunPeach")
				end
			end
			--3.寻找其中的【闪】并询问发动效果
			for _, cd in sgs.qlist(player:getHandcards()) do --实测不需要写两遍
				if cd:hasFlag("f_yonghunJink") then
					room:askForUseCard(player, "@@f_yonghunJink", "@f_yonghunJink")
				end
			end
			--4.寻找其中的【杀】并询问发动效果
			for _, cd in sgs.qlist(player:getHandcards()) do
				if cd:hasFlag("f_yonghunSlash") then
					if not room:askForUseCard(player, "@@f_yonghunSlash", "@f_yonghunSlash") then
						room:setCardFlag(cd, "-f_yonghunSlash") --防止重复询问
					end
				end
			end
			for _, cd in sgs.qlist(player:getHandcards()) do
				if cd:hasFlag("f_yonghunSlash") then
					room:askForUseCard(player, "@@f_yonghunSlash", "@f_yonghunSlash")
				end
			end
			for _, cd in sgs.qlist(player:getHandcards()) do --清除标志
				if cd:hasFlag("f_yonghunSlash") then room:setCardFlag(cd, "-f_yonghunSlash")
				elseif cd:hasFlag("f_yonghunJink") then room:setCardFlag(cd, "-f_yonghunJink")
				elseif cd:hasFlag("f_yonghunPeach") then room:setCardFlag(cd, "-f_yonghunPeach")
				elseif cd:hasFlag("f_yonghunAnaleptic") then room:setCardFlag(cd, "-f_yonghunAnaleptic")
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_yonghun")
	end,
}
if not sgs.Sanguosha:getSkill("f_yonghunMoveCardBuff") then skills:append(f_yonghunMoveCardBuff) end
--1.使用【酒】：
f_yonghunAnalepticCard = sgs.CreateSkillCard{
	name = "f_yonghunAnalepticCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		for _, id in sgs.qlist(self:getSubcards()) do
			local c = sgs.Sanguosha:getCard(id)
			room:broadcastSkillInvoke("f_yonghun")
			room:useCard(sgs.CardUseStruct(c, source, source), false) --不计入使用次数
			room:setPlayerFlag(source, "f_yonghunAN")
		end
	end,
}
f_yonghunAnaleptic = sgs.CreateOneCardViewAsSkill{
    name = "f_yonghunAnaleptic",
	view_filter = function(self, to_select)
		return to_select:hasFlag(self:objectName())
	end,
	view_as = function(self, card)
		local ana = f_yonghunAnalepticCard:clone()
		ana:addSubcard(card)
		return ana
	end,
	response_pattern = "@@f_yonghunAnaleptic",
}
f_yonghunAN = sgs.CreateTargetModSkill{
	name = "f_yonghunAN",
	pattern = "Card",
	residue_func = function(self, player, card)
		if player:hasSkill("f_yonghun") and player:hasFlag(self:objectName()) then
			return 1000
		else
			return 0
		end
	end,
}
f_yonghunANClear = sgs.CreateTriggerSkill{
    name = "f_yonghunANClear",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:isKindOf("SkillCard") then return false end --防火防盗防技能卡牌
		end
		room:setPlayerFlag(player, "-f_yonghunAN")
	end,
	can_trigger = function(self, player)
		return player:hasFlag("f_yonghunAN")
	end,
}
--2.发动【桃】对应效果：
f_yonghunPeachCard = sgs.CreateSkillCard{
	name = "f_yonghunPeachCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return to_select:isWounded() and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		effect.to:obtainCard(self)
		for _, id in sgs.qlist(self:getSubcards()) do
			local c = sgs.Sanguosha:getCard(id)
			room:broadcastSkillInvoke("f_yonghun")
			room:useCard(sgs.CardUseStruct(c, effect.to, effect.to))
		end
	end,
}
f_yonghunPeach = sgs.CreateOneCardViewAsSkill{
    name = "f_yonghunPeach",
	view_filter = function(self, to_select)
		return to_select:hasFlag(self:objectName())
	end,
	view_as = function(self, card)
		local ph = f_yonghunPeachCard:clone()
		ph:addSubcard(card)
		return ph
	end,
	response_pattern = "@@f_yonghunPeach",
}
--3.发动【闪】对应效果：
f_yonghunJinkCard = sgs.CreateSkillCard{
	name = "f_yonghunJinkCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("f_yonghun")
		room:drawCards(source, 2, "f_yonghunJink")
	end,
}
f_yonghunJink = sgs.CreateOneCardViewAsSkill{
    name = "f_yonghunJink",
	view_filter = function(self, to_select)
		return to_select:hasFlag(self:objectName())
	end,
	view_as = function(self, card)
		local jk = f_yonghunJinkCard:clone()
		jk:addSubcard(card)
		return jk
	end,
	response_pattern = "@@f_yonghunJink",
}
--4.使用【杀】：
f_yonghunSlashCard = sgs.CreateSkillCard{
	name = "f_yonghunSlashCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return sgs.Self:canSlash(to_select, nil, false) --无距离限制
			and to_select:objectName() ~= sgs.Self:objectName()
		end
		return false
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		for _, id in sgs.qlist(self:getSubcards()) do
			local c = sgs.Sanguosha:getCard(id)
			room:broadcastSkillInvoke("f_yonghun")
			room:addPlayerMark(effect.to, "Armor_Nullified") --无视防具
			room:useCard(sgs.CardUseStruct(c, effect.from, effect.to), true) --无次数限制
			if effect.to:isAlive() then
				room:removePlayerMark(effect.to, "Armor_Nullified")
			end
		end
	end,
}
f_yonghunSlash = sgs.CreateOneCardViewAsSkill{
    name = "f_yonghunSlash",
	view_filter = function(self, to_select)
		return to_select:hasFlag(self:objectName())
	end,
	view_as = function(self, card)
		local sh = f_yonghunSlashCard:clone()
		sh:addSubcard(card)
		return sh
	end,
	response_pattern = "@@f_yonghunSlash",
}
----
if not sgs.Sanguosha:getSkill("f_yonghunAnaleptic") then skills:append(f_yonghunAnaleptic) end
if not sgs.Sanguosha:getSkill("f_yonghunAN") then skills:append(f_yonghunAN) end
if not sgs.Sanguosha:getSkill("f_yonghunANClear") then skills:append(f_yonghunANClear) end
if not sgs.Sanguosha:getSkill("f_yonghunPeach") then skills:append(f_yonghunPeach) end
if not sgs.Sanguosha:getSkill("f_yonghunJink") then skills:append(f_yonghunJink) end
if not sgs.Sanguosha:getSkill("f_yonghunSlash") then skills:append(f_yonghunSlash) end

--神孙尚香
f_shensunshangxiang = sgs.General(extension_f, "f_shensunshangxiang", "god", 4, false)

f_jianyuan = sgs.CreateTriggerSkill{
    name = "f_jianyuan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage, sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		for i = 0, damage.damage - 1, 1 do
			if player:getEquips():length() == 0 then break end
			if room:askForSkillInvoke(player, self:objectName(), data) then
			--寻找【缘】角色：
				--1.装备区里有牌
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:isMale() and p:getEquips():length() > 0 then
						room:setPlayerFlag(p, "f_JYuan")
					end
				end
				--2.此次的伤害目标(你造成伤害)/伤害来源(你受到伤害)
				local to
				if event == sgs.Damage and damage.to:isAlive() then
					to = damage.to
				elseif event == sgs.Damaged and damage.from then
					to = damage.from
				end
				if to and to:objectName() ~= player:objectName() and to:isMale() and not to:hasFlag("f_JYuan") then
					room:setPlayerFlag(to, "f_JYuan")
				end
				--3.被记录入《剑缘录》
				local JianYuanLu = player:property("SkillDescriptionRecord_f_jianyuan"):toString():split("+")
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:isMale() and table.contains(JianYuanLu, p:getGeneralName()) and not p:hasFlag("f_JYuan") then
						room:setPlayerFlag(p, "f_JYuan")
					end
				end
				if not player:isKongcheng() then
					player:throwAllHandCards()
				end
				local x = 4 + player:getMark("&f_jianyuanX")
				if player:getWeapon() ~= nil then x = x + 1 end
				local card_ids = room:getNCards(x)
				for _, id in sgs.qlist(card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					room:setCardFlag(card, self:objectName())
				end
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				if not card_ids:isEmpty() then
					for _, id in sgs.qlist(card_ids) do
						dummy:addSubcard(id)
					end
					room:obtainCard(player, dummy, false)
					room:broadcastSkillInvoke(self:objectName(), 1)
				end
				dummy:clearSubcards()
				local z = 3
				while z > 0 do
					if not room:askForUseCard(player, "@@f_jianyuangive", "@f_jianyuangive-card") then
						room:askForUseCard(player, "@@f_jianyuanthrow!", "@f_jianyuanthrow-card")
					end
					z = z - 1
				end
				local y = 2 + player:getMark("&f_jianyuanY")
				if player:getWeapon() ~= nil then y = y + 1 end
				if player:getHandcardNum() > y then player:turnOver() end
				if player:getHandcardNum() > 4 then room:loseHp(player, 1) end
				--==《剑缘录》==--
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:hasFlag("f_JYuan_real") then
						room:setPlayerFlag(p, "-f_JYuan_real")
						if p:getWeapon() ~= nil or not table.contains(JianYuanLu, p:getGeneralName()) then
							local choice = room:askForChoice(player, self:objectName(), "x+y")
							if choice == "x" then room:addPlayerMark(player, "&f_jianyuanX")
							else room:addPlayerMark(player, "&f_jianyuanY") end
						end
						if not table.contains(JianYuanLu, p:getGeneralName()) and room:askForSkillInvoke(player, self:objectName(), FCToData("JianYuanLu:"..p:objectName())) then
							room:broadcastSkillInvoke(self:objectName(), 3)
							table.insert(JianYuanLu, p:getGeneralName())
							room:setPlayerProperty(player, "SkillDescriptionRecord_f_jianyuan", sgs.QVariant(table.concat(JianYuanLu, "+")))
							room:changeTranslation(player, "f_jianyuan", 11)
						end
					end
				end
				--==============--
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:hasFlag("f_JYuan") then
						room:setPlayerFlag(p, "-f_JYuan")
					end
				end
				for _, c in sgs.qlist(player:getHandcards()) do
					if c:hasFlag(self:objectName()) then
						room:setCardFlag(c, "-f_jianyuan")
					end
				end
			else
				break
			end
		end
	end,
}
f_shensunshangxiang:addSkill(f_jianyuan)
--给牌：
f_jianyuangiveCard = sgs.CreateSkillCard{
	name = "f_jianyuangiveCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and (to_select:hasFlag("f_JYuan") or to_select:objectName() == sgs.Self:objectName())
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		for _, id in sgs.qlist(self:getSubcards()) do
			local c = sgs.Sanguosha:getCard(id)
			room:setCardFlag(c, "-f_jianyuan")
		end
		room:broadcastSkillInvoke("f_jianyuan", 2)
		effect.to:obtainCard(self, false)
		if effect.to:objectName() ~= effect.from:objectName() then
			room:setPlayerFlag(effect.to, "f_JYuan_real")
		end
	end,
}
f_jianyuangive = sgs.CreateOneCardViewAsSkill{
    name = "f_jianyuangive",
	mute = true,
	view_filter = function(self, to_select)
		return to_select:hasFlag("f_jianyuan")
	end,
	view_as = function(self, card)
		local jyg = f_jianyuangiveCard:clone()
		jyg:addSubcard(card)
		return jyg
	end,
	response_pattern = "@@f_jianyuangive",
}
if not sgs.Sanguosha:getSkill("f_jianyuangive") then skills:append(f_jianyuangive) end
--丢牌：
f_jianyuanthrowCard = sgs.CreateSkillCard{
	name = "f_jianyuanthrowCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		for _, id in sgs.qlist(self:getSubcards()) do
			local c = sgs.Sanguosha:getCard(id)
			room:setCardFlag(c, "-f_jianyuan")
		end
	end,
}
f_jianyuanthrow = sgs.CreateOneCardViewAsSkill{
    name = "f_jianyuanthrow",
	mute = true,
	view_filter = function(self, to_select)
		return to_select:hasFlag("f_jianyuan")
	end,
	view_as = function(self, card)
		local jyt = f_jianyuanthrowCard:clone()
		jyt:addSubcard(card)
		return jyt
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@f_jianyuanthrow")
	end,
}
if not sgs.Sanguosha:getSkill("f_jianyuanthrow") then skills:append(f_jianyuanthrow) end

f_gongli = sgs.CreateTriggerSkill{
    name = "f_gongli",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_RoundStart then
			if player:hasSkill(self:objectName()) then
				local JianYuanLu = player:property("SkillDescriptionRecord_f_jianyuan"):toString():split("+")
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if player:distanceTo(p) <= #JianYuanLu + 1 then
						if not player:hasFlag("fGLfrom") then room:setPlayerFlag(player, "fGLfrom") end
						room:setPlayerFlag(p, "fGLPto")
						room:insertAttackRangePair(player, p)
					end
				end
			end
			if not player:isWounded() then return false end
			for _, ss in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				local JianYuanLuu = ss:property("SkillDescriptionRecord_f_jianyuan"):toString():split("+")
				if table.contains(JianYuanLuu, player:getGeneralName()) then
					local choices = {}
					if ss:hasEquipArea() then
						table.insert(choices, "ue")
					end
					table.insert(choices, "dc")
					table.insert(choices, "cancel")
					local choice = room:askForChoice(ss, self:objectName(), table.concat(choices, "+"))
					if choice == "cancel" then return false end
					if choice == "ue" then
						local use_id = -1
						for _, id in sgs.qlist(room:getDrawPile()) do
							local card = sgs.Sanguosha:getCard(id)
							if (card:isKindOf("Weapon") and ss:hasEquipArea(0)) or (card:isKindOf("Armor") and ss:hasEquipArea(1))
							or (card:isKindOf("DefensiveHorse") and ss:hasEquipArea(0)) or (card:isKindOf("OffensiveHorse") and ss:hasEquipArea(3))
							or (card:isKindOf("Treasure") and ss:hasEquipArea(0)) then --这样分类讨论是为了防止没有对应装备栏还使用对应副类别的装备
								use_id = id
								break
							end
						end
						room:doAnimate(1, ss:objectName(), ss:objectName())
						if use_id >= 0 then
							local use_card = sgs.Sanguosha:getCard(use_id)
							if ss:isAlive() and ss:canUse(use_card, ss, true) then
								room:broadcastSkillInvoke(self:objectName())
								room:useCard(sgs.CardUseStruct(use_card, ss, ss))
							end
						end
					elseif choice == "dc" then
						room:broadcastSkillInvoke(self:objectName())
						room:drawCards(ss, 1, self:objectName())
					end
					room:recover(player, sgs.RecoverStruct(ss), true)
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			if player:hasFlag("fGLfrom") then room:setPlayerFlag(player, "-fGLfrom") else return false end
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:hasFlag("fGLto") then
					room:setPlayerFlag(p, "-fGLto")
					room:removeAttackRangePair(player, p)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_shensunshangxiang:addSkill(f_gongli)

--神于吉
f_shenyuji = sgs.General(extension_f, "f_shenyuji", "god", 2, true)

f_huisheng = sgs.CreateTriggerSkill{
    name = "f_huisheng",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Dying},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		if dying.who:objectName() == player:objectName() then
			if player:getMark("f_huishengRedBan") > 0 and player:getMark("f_huishengBlackBan") > 0 then return false end
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName(), 1)
				local judge = sgs.JudgeStruct()
				if player:getMark("f_huishengRedBan") > 0 then
					judge.pattern = ".|black"
				elseif player:getMark("f_huishengBlackBan") > 0 then
					judge.pattern = ".|red"
				else
					judge.pattern = "." --不考虑无色了，但无色就算动画打√也过不了，后面会卡着仅限红色或黑色牌
				end
				judge.good = true
				judge.play_animation = true
				judge.who = player
				judge.reason = self:objectName()
				room:judge(judge)
				if judge:isGood() and (judge.card:isRed() or judge.card:isBlack()) then
					room:broadcastSkillInvoke(self:objectName(), 2)
					local hs = 2 - player:getHp()
					room:recover(player, sgs.RecoverStruct(player, nil, hs))
					if not player:isAllNude() then
						local throw_all = sgs.IntList()
						for _, c in sgs.qlist(player:getCards("hej")) do
							throw_all:append(c:getEffectiveId())
						end
						local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
						if not throw_all:isEmpty() then
							for _, id in sgs.qlist(throw_all) do
								dummy:addSubcard(id)
							end
							local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), nil)
							room:throwCard(dummy, reason, player)
							dummy:deleteLater()
						end
					end
					room:drawCards(player, 4, self:objectName())
					local choices = {}
					if player:getMark("f_huishengRedBan") == 0 then
						table.insert(choices, "dr")
					end
					if player:getMark("f_huishengBlackBan") == 0 then
						table.insert(choices, "db")
					end
					local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
					if choice == "dr" then
						local log = sgs.LogMessage()
						log.type = "$f_huishengRedBan"
						log.from = player
						room:sendLog(log)
						room:addPlayerMark(player, "f_huishengRedBan")
					elseif choice == "db" then
						local log = sgs.LogMessage()
						log.type = "$f_huishengBlackBan"
						log.from = player
						room:sendLog(log)
						room:addPlayerMark(player, "f_huishengBlackBan")
					end
				else
					room:broadcastSkillInvoke(self:objectName(), 3)
				end
			end
		end
	end,
}
f_shenyuji:addSkill(f_huisheng)

f_miaodao = sgs.CreateTriggerSkill{
    name = "f_miaodao",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseEnd, sgs.CardsMoveOneTime, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Play and not player:isKongcheng() then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				local card_id = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				if player:getHandcardNum() == 1 then
					card_id = player:handCards():first()
				else
					card_id = room:askForExchange(player, self:objectName(), 2, 1, false, "f_miaodaoPush")
				end
				player:addToPile("f_syjDao", card_id)
				room:broadcastSkillInvoke(self:objectName())
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceSpecial)
			and table.contains(move.from_pile_names, "f_syjDao") and player:getPile("f_syjDao"):length() == 0 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:drawCards(player, 2, self:objectName())
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			local n = player:getPile("f_syjDao"):length() if n > 4 then n = 4 end
			if n > 0 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:drawCards(player, n, self:objectName())
			end
		end
	end,
}
f_shenyuji:addSkill(f_miaodao)

f_yifaCard = sgs.CreateSkillCard{
	name = "f_yifaCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		room:setPlayerFlag(source, "f_yifaPUT")
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, source:objectName(), nil, self:objectName(), nil)
		room:moveCardTo(self, source, nil, sgs.Player_DrawPile, reason, false)
		room:setPlayerFlag(source, "-f_yifaPUT")
	end,
}
f_yifaVS = sgs.CreateOneCardViewAsSkill{
	name = "f_yifa",
	filter_pattern = ".|.|.|f_syjDao",
	expand_pile = "f_syjDao",
	view_as = function(self, card)
		local pc = f_yifaCard:clone()
		pc:addSubcard(card)
		return pc
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@f_yifa")
	end,
}
f_yifa = sgs.CreateTriggerSkill{
    name = "f_yifa",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseProceeding, sgs.RoundStart},
	view_as_skill = f_yifaVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseProceeding then
			local phase = player:getPhase()
			if phase == sgs.Player_RoundStart then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					room:setPlayerMark(p, "f_yifana", 0)
				end
			end
			if phase ~= sgs.Player_Start then return false end
			for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if p:getMark(self:objectName()) >= 2 or p:getMark("f_yifana") > 0 then continue end
				if p:isKongcheng() and p:getPile("f_syjDao"):length() == 0 then continue end
				if room:askForSkillInvoke(p, self:objectName(), data) then
					room:addPlayerMark(p, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					local choices = {}
					if not p:isKongcheng() then
						table.insert(choices, "handcard")
					end
					if p:getPile("f_syjDao"):length() > 0 then
						table.insert(choices, "pilecard")
					end
					local choice = room:askForChoice(p, self:objectName(), table.concat(choices, "+"))
					if choice == "handcard" then
						local hc = room:askForCardChosen(p, p, "h", self:objectName())
						if hc then
							room:setPlayerFlag(p, "f_yifaPUT")
							local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, p:objectName(), nil, self:objectName(), nil)
							room:moveCardTo(sgs.Sanguosha:getCard(hc), p, nil, sgs.Player_DrawPile, reason, false)
							room:setPlayerFlag(p, "-f_yifaPUT")
						end
					elseif choice == "pilecard" then
						room:askForUseCard(p, "@@f_yifa!", "@f_yifa-Dao")
					end
					local current = room:getCurrent()
					local choicess = {}
					table.insert(choicess, "move")
					if not current:isAllNude() then
						table.insert(choicess, "get")
					end
					local choicee = room:askForChoice(p, self:objectName(), table.concat(choicess, "+"))
					if choicee == "move" then
						local xintuers = sgs.SPlayerList()
						for _, xt in sgs.qlist(room:getAllPlayers()) do
							if xt:getEquips():length() > 0 or xt:getJudgingArea():length() > 0 then
								xintuers:append(xt)
							end
						end
						local from
						if xintuers:length() > 1 then
							from = room:askForPlayerChosen(p, xintuers, self:objectName(), "f_yifa_Move", true, true)
						elseif xintuers:length() == 1 then
							for _, xt in sgs.qlist(room:getAllPlayers()) do
								if xt:getEquips():length() > 0 or xt:getJudgingArea():length() > 0 then
									from = xt
									break
								end
							end
						end
						if from and (from:getEquips():length() > 0 or from:getJudgingArea():length() > 0) then
							local card_id = room:askForCardChosen(p, from, "ej", self:objectName())
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
										if not p:isProhibited(p, card) and not p:containsTrick(card:objectName()) then
											tos:append(p)
										end
									end
								end
								local tag = sgs.QVariant()
								tag:setValue(from)
								room:setTag("f_yifaMoveTarget", tag)
								local to = room:askForPlayerChosen(p, tos, self:objectName(), "@f_yifa_Move-to:" .. card:objectName())
								if to then
									room:moveCardTo(card, from, to, place, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, p:objectName(), self:objectName(), ""))
									room:broadcastSkillInvoke(self:objectName())
								end
								room:removeTag("f_yifaMoveTarget")
							end
						end
					elseif choicee == "get" then
						room:doAnimate(1, p:objectName(), current:objectName())
						local card_id = room:askForCardChosen(p, current, "hej", self:objectName())
			    		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, p:objectName())
			    		room:obtainCard(p, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
						room:broadcastSkillInvoke(self:objectName())
					end
				else
					room:addPlayerMark(p, "f_yifana")
				end
			end
		elseif event == sgs.RoundStart then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, self:objectName(), 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_shenyuji:addSkill(f_yifa)

--

--神庞统
f_shenpangtong = sgs.General(extension_f, "f_shenpangtong", "god", 3, true)

f_fengchu = sgs.CreateTriggerSkill{
    name = "f_fengchu",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_RoundStart then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			local choices = {"1", "2", "3", "4"}
			local n = 0
			while n < 3 do
				local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
				if choice == "1" then
					room:gainMaxHp(player, 1, self:objectName())
					table.removeOne(choices, "1")
					if player:getState() == "robot" then table.removeOne(choices, "2") end --为了AI，保证AI必选3和4
				elseif choice == "2" then
					room:recover(player, sgs.RecoverStruct(player))
					table.removeOne(choices, "2")
					if player:getState() == "robot" then table.removeOne(choices, "1") end --为了AI，保证AI必选3和4
				elseif choice == "3" then
					room:drawCards(player, 2, self:objectName())
					table.removeOne(choices, "3")
				elseif choice == "4" then
					room:setPlayerFlag(player, "no_f_luofeng")
					table.removeOne(choices, "4")
				end
				n = n + 1
			end
			if player:hasFlag("f_fengchuOneTwoChoiced") then room:setPlayerFlag(player, "-f_fengchuOneTwoChoiced") end
		end
	end,
}
f_shenpangtong:addSkill(f_fengchu)

f_shenpanCard = sgs.CreateSkillCard{
	name = "f_shenpanCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return #targets == 0 and not to_select:hasFlag("f_shenpanSelected")
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		room:setPlayerFlag(effect.to, "f_shenpanSelected")
		if effect.to:getMark("f_shenpanOne") > 0 then
			room:askForDiscard(effect.to, "f_shenpan", 2, 2, false, true)
		end
		if effect.to:getMark("f_shenpanTwo") > 0 then
			room:damage(sgs.DamageStruct("f_shenpan", nil, effect.to))
		end
		if effect.to:getMark("f_shenpanThree") > 0 then
			room:loseHp(effect.to, 1)
		end
	end,
}
f_shenpan = sgs.CreateOneCardViewAsSkill{
	name = "f_shenpan",
	view_filter = function(self, to_select)
		return true
	end,
	view_as = function(self, card)
		local sp = f_shenpanCard:clone()
		sp:addSubcard(card)
		return sp
	end,
	enabled_at_play = function(self, player)
		return not player:isNude() and player:canDiscard(player, "he")
	end,
}
f_shenpanTarget = sgs.CreateTriggerSkill{
    name = "f_shenpanTarget",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardsMoveOneTime, sgs.Damage, sgs.Death, sgs.TurnStart, sgs.EventPhaseStart, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local spt = room:findPlayerBySkillName("f_shenpan")
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if ((move.to and move.to:objectName() == player:objectName() and move.from and move.from:objectName() ~= move.to:objectName()
			and (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip))
			and move.reason.m_reason ~= sgs.CardMoveReason_S_REASON_PREVIEWGIVE)
			or (move.from and move.from:objectName() ~= player:objectName()
			and (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip))
			and bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD))
			and player:getPhase() ~= sgs.Player_NotActive then
				if spt and player:getMark("&f_shenpanOne") == 0 then
					room:addPlayerMark(player, "&f_shenpanOne") --文字标记只是为了方便神庞统玩家看的，真正起作用的是隐藏标记
				end
				room:addPlayerMark(player, "f_shenpanOne")
			end
		elseif event == sgs.Damage then
			local damage = data:toDamage()
			if damage.from:objectName() == player:objectName() and player:getPhase() ~= sgs.Player_NotActive then
				if spt and player:getMark("&f_shenpanTwo") == 0 then
					room:addPlayerMark(player, "&f_shenpanTwo")
				end
				room:addPlayerMark(player, "f_shenpanTwo")
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.damage and death.damage.from and death.who and death.damage.from:objectName() ~= death.who:objectName()
			and death.damage.from:getMark("f_shenpanTMG") > 0 then --and death.damage.from:getPhase() ~= sgs.Player_NotActive then
				if spt and death.damage.from:getMark("&f_shenpanThree") == 0 then
					room:addPlayerMark(death.damage.from, "&f_shenpanThree")
				end
				room:addPlayerMark(death.damage.from, "f_shenpanThree")
			end
		elseif event == sgs.TurnStart then
			room:setPlayerMark(player, "&f_shenpanOne", 0)
			room:setPlayerMark(player, "f_shenpanOne", 0)
			room:setPlayerMark(player, "&f_shenpanTwo", 0)
			room:setPlayerMark(player, "f_shenpanTwo", 0)
			room:setPlayerMark(player, "&f_shenpanThree", 0)
			room:setPlayerMark(player, "f_shenpanThree", 0)
		elseif event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_RoundStart then
			room:setPlayerMark(player, "f_shenpanTMG", 1) --用于判断死亡来源是不是在其回合内
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("f_shenpanSelected") then
					room:setPlayerFlag(p, "-f_shenpanSelected")
				end
			end
			room:setPlayerMark(player, "f_shenpanTMG", 0)
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_shenpangtong:addSkill(f_shenpan)
if not sgs.Sanguosha:getSkill("f_shenpanTarget") then skills:append(f_shenpanTarget) end

f_luofeng = sgs.CreateTriggerSkill{
    name = "f_luofeng",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive or player:hasFlag("no_f_luofeng") then return false end
		room:sendCompulsoryTriggerLog(player, self:objectName())
		room:broadcastSkillInvoke(self:objectName(), 1)
		local judge = sgs.JudgeStruct()
		judge.pattern = ".|.|5"
		judge.good = true
		judge.play_animation = true
		judge.reason = self:objectName()
		judge.who = player
		room:judge(judge)
		if judge:isGood() then
			room:broadcastSkillInvoke(self:objectName(), 2)
			
			if judge.card:objectName() == "dilu" then --彩蛋：正好判定出了的卢
				room:doLightbox("f_luofengAnimate")
			end
			
			room:loseHp(player, player:getHp())
			if not player:isAlive() then return false end
			if player:hasSkill("f_fengchu") then
				room:detachSkillFromPlayer(player, "f_fengchu")
			end
			if player:hasSkill(self:objectName()) then
				room:detachSkillFromPlayer(player, self:objectName())
			end
		end
	end,
}
f_shenpangtong:addSkill(f_luofeng)


--

--神蒲元
f_shenpuyuan = sgs.General(extension_f, "f_shenpuyuan", "god", 4, true) --初始；巨匠
f_shenpuyuanx = sgs.General(extension_f, "f_shenpuyuanx", "god", 4, true, true, true) --侠匠

f_tianciStart = sgs.CreateTriggerSkill{ --挑选幸运儿
    name = "f_tianciStart",
	priority = 5,
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local spy = room:findPlayerBySkillName("f_tianci")
		if not spy then return false end
		local online = {} --登记“神蒲元”玩家
		local robots = {} --登记“神蒲元”AI
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if (p:getGeneralName() == "f_shenpuyuan" or p:getGeneral2Name() == "f_shenpuyuan") and p:hasSkill("f_tianci") then
				if p:getState() == "online" then
					table.insert(online, p)
				elseif p:getState() == "robot" then
					table.insert(online, p)
				end
			end
		end
		local xyr = nil
		if #online > 0 then
			xyr = online[math.random(1, #online)]
			room:addPlayerMark(xyr, self:objectName())
		end
		if xyr == nil and #robots > 0 then
			xyr = robots[math.random(1, #robots)]
			room:addPlayerMark(xyr, self:objectName())
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
--[[function destroyEquip(room, move, tag_name) --销毁装备
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
end]]
f_tianci = sgs.CreateTriggerSkill{
    name = "f_tianci",
	priority = 4,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.CardsMoveOneTime},
	waked_skills = "spy_shenbingku",
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:getMark("f_tianciStart") == 0 then return false end
			room:setPlayerMark(player, "f_tianciStart", 0)
			sgs.Sanguosha:playAudioEffect("audio/skill/f_tianciFate.ogg", false)
			room:doLightbox("$f_tianciFate") --触发命运
			local cds = sgs.IntList()
			for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
				local tlr = sgs.Sanguosha:getEngineCard(id)
				if tlr:isKindOf("Tianleiren") and room:getCardPlace(id) ~= sgs.Player_DrawPile then
					cds:append(id)
				end
			end
			if not cds:isEmpty() then
				room:shuffleIntoDrawPile(player, cds, self:objectName(), true)
				local ids = sgs.IntList()
				for _, id in sgs.qlist(room:getDrawPile()) do
					local cd = sgs.Sanguosha:getCard(id)
					if cd:isKindOf("Tianleiren") then
						room:setTag("TLR_ID", sgs.QVariant(id))
						ids:append(id)
					end
				end
				if not ids:isEmpty() then
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					for _, i in sgs.qlist(ids) do
						dummy:addSubcard(i)
						break
					end
					room:obtainCard(player, dummy) --获得神兵【天雷刃】，此即命运的开始
					dummy:deleteLater()
				end
			end
			local choices = {}
			if player:hasEquipArea(0) then
				table.insert(choices, "XJ") --《侠匠之路》
			end
			table.insert(choices, "JJ") --《巨匠之路》
			local choice = room:askForChoice(player, "f_tianciFate", table.concat(choices, "+"))
			if choice == "XJ" then
				for _, tlr in sgs.qlist(player:getCards("he")) do
					if tlr:isKindOf("Tianleiren") then
						room:broadcastSkillInvoke(self:objectName(), 1)
						room:useCard(sgs.CardUseStruct(tlr, player, player)) --装备【天雷刃】
						break
					end
				end
				player:gainMark("&fXiaJiang", 1) --成为“侠匠”
				--更换头像
				local mhp = player:getMaxHp()
				local hp = player:getHp()
				if player:getGeneralName() == "f_shenpuyuan" then
					room:changeHero(player, "f_shenpuyuanx", false, false, false, false)
				elseif player:getGeneral2Name() == "f_shenpuyuan" then
					room:changeHero(player, "f_shenpuyuanx", false, false, true, false)
				end
				if player:getMaxHp() ~= mhp then room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp)) end
				if player:getHp() ~= hp then room:setPlayerProperty(player, "hp", sgs.QVariant(hp)) end
			elseif choice == "JJ" then
				for _, tlr in sgs.qlist(player:getCards("he")) do
					if tlr:isKindOf("Tianleiren") then
						room:broadcastSkillInvoke(self:objectName(), 2)
						room:throwCard(tlr, nil) --创造销毁的时机
						break
					end
				end
				player:gainMark("&fJuJiang", 1) --成为“巨匠”
				--建立“神兵库”
				local sbk = {"_hunduwanbi", "_shuibojian", "_liecuidao", "_hongduanqiang",
				"_f_wushuangfangtianji", "_f_guilongzhanyuedao", "_f_chixieqingfeng", "_f_bingtieshuangji", "wutiesuolian", "wuxinghelingshan",
				"_f_linglongshimandai", "_f_hongmianbaihuapao", "_f_guofengyupao", "_f_qimenbazhen", "huxinjing", "heiguangkai",
				"_f_shufazijinguan", "_f_xuwangzhimian", "tianjitu", "taigongyinfu", "_f_sanlve", "_f_zhaogujing"}
				local cds = sgs.IntList()
				for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
					local sb = sgs.Sanguosha:getEngineCard(id)
					if table.contains(sbk, sb:objectName()) then
						cds:append(id)
						table.removeOne(sbk, sb:objectName())
					end
				end
				if not cds:isEmpty() then
					player:addToPile("spy_shenbingku", cds)
					local dummi = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					local random_get, n = {}, 2
					for _, ee in sgs.qlist(player:getPile("spy_shenbingku")) do
						local eqp = sgs.Sanguosha:getCard(ee)
						table.insert(random_get, eqp)
					end
					while n > 0 do
						local rgt = random_get[math.random(1, #random_get)]
						dummi:addSubcard(rgt:getEffectiveId())
						table.removeOne(random_get, rgt)
						n = n - 1
					end
					room:obtainCard(player, dummi)
					dummi:deleteLater()
				end
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from:objectName() == player:objectName() and move.to_place == sgs.Player_DiscardPile then
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if card:isKindOf("Tianleiren") then
						destroyEquip(room, move, "TLR_ID") --销毁【天雷刃】
					end
				end
			end
		end
	end,
}
f_shenpuyuan:addSkill(f_tianci)
f_shenpuyuan:addRelateSkill("spy_shenbingku")
if not sgs.Sanguosha:getSkill("f_tianciStart") then skills:append(f_tianciStart) end
--
f_tianciATA = sgs.CreateTriggerSkill{
    name = "f_tianciATA",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_RoundStart then return false end
		local can_invoke = true
		for _, c in sgs.qlist(player:getCards("he")) do
			if c:isKindOf("Tianleiren") then
				can_invoke = false
			end
		end
		if can_invoke then --检测到玩家已没有【天雷刃】，重新给予
			local cds = sgs.IntList()
			for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
				local tlr = sgs.Sanguosha:getEngineCard(id)
				if tlr:isKindOf("Tianleiren") and room:getCardPlace(id) ~= sgs.Player_DrawPile then
					cds:append(id)
				end
			end
			if not cds:isEmpty() then
				room:shuffleIntoDrawPile(player, cds, self:objectName(), true)
			end
			local ids = sgs.IntList()
			for _, id in sgs.qlist(room:getDrawPile()) do
				local cd = sgs.Sanguosha:getCard(id)
				if cd:isKindOf("Tianleiren") then
					room:setTag("TLR_ID", sgs.QVariant(id))
					ids:append(id)
				end
			end
			if not ids:isEmpty() then
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, i in sgs.qlist(ids) do
					dummy:addSubcard(i)
					break
				end
				room:sendCompulsoryTriggerLog(player, "f_tianci")
				room:broadcastSkillInvoke("f_tianci")
				room:obtainCard(player, dummy)
				dummy:deleteLater()
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getMark("&fXiaJiang") > 0
	end,
}
f_shenpuyuanx:addSkill("f_tianci")
if not sgs.Sanguosha:getSkill("f_tianciATA") then skills:append(f_tianciATA) end

--==【“神兵库”】==--
spy_shenbingku = sgs.CreateTriggerSkill{
	name = "spy_shenbingku",
	priority = 22,
	frequency = sgs.Skill_NotFrequent,
	events = {},
	on_trigger = function()
	end,
}
if not sgs.Sanguosha:getSkill("spy_shenbingku") then skills:append(spy_shenbingku) end
--==[[武器]]==--
--1.混毒弯匕(已有)
----
--2.水波剑(已有)
----
--3.烈淬刀(已有)
----
--4.红锻枪(已有)
----
--5.无双方天戟
Fwushuangfangtianjis = sgs.CreateTriggerSkill{
	name = "Fwushuangfangtianji",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.card:isKindOf("Slash") and damage.from:objectName() == player:objectName() and damage.to then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				local choices = {}
				table.insert(choices, "1")
				if not damage.to:isNude() and player:canDiscard(damage.to, "he") then
					table.insert(choices, "2=" .. damage.to:objectName())
				end
				local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
				if choice == "1" then
					sgs.Sanguosha:playAudioEffect("audio/equip/Halberd.ogg", false)
					room:setEmotion(player, "weapon/halberd")
	    			room:drawCards(player, 1, self:objectName())
				else
					local card = room:askForCardChosen(player, damage.to, "he", self:objectName(), false, sgs.Card_MethodDiscard)
					sgs.Sanguosha:playAudioEffect("audio/equip/Halberd.ogg", false)
					room:setEmotion(player, "weapon/halberd")
					room:throwCard(card, damage.to, player)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getWeapon():isKindOf("Fwushuangfangtianji")
	end,
}
Fwushuangfangtianji = sgs.CreateWeapon{
	name = "_f_wushuangfangtianji",
	class_name = "Fwushuangfangtianji",
	subtype = "JJ_shenbingku",
	range = 4,
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, Fwushuangfangtianjis, false, true, false)
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "Fwushuangfangtianji", true, true)
	end,
}
Fwushuangfangtianji:clone(sgs.Card_Diamond, 12):setParent(newgodsCard)
if not sgs.Sanguosha:getSkill("Fwushuangfangtianji") then skills:append(Fwushuangfangtianjis) end
--6.鬼龙斩月刀
Fguilongzhanyuedaos = sgs.CreateTriggerSkill{
	name = "Fguilongzhanyuedao",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecified},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if not use.card:isKindOf("Slash") or not use.card:isRed() then return false end
		room:sendCompulsoryTriggerLog(player, self:objectName())
		sgs.Sanguosha:playAudioEffect("audio/equip/Blade.ogg", false)
		room:setEmotion(player, "weapon/blade")
		local jink_table = sgs.QList2Table(player:getTag("Jink_" .. use.card:toString()):toIntList())
		local index = 1
		for _, p in sgs.qlist(use.to) do
			if not player:isAlive() then break end
			local _data = sgs.QVariant()
			_data:setValue(p)
			jink_table[index] = 0
			index = index + 1
		end
		local jink_data = sgs.QVariant()
		jink_data:setValue(Table2IntList(jink_table))
		player:setTag("Jink_" .. use.card:toString(), jink_data)
	end,
	can_trigger = function(self, player)
		return player:getWeapon():isKindOf("Fguilongzhanyuedao")
	end,
}
Fguilongzhanyuedao = sgs.CreateWeapon{
	name = "_f_guilongzhanyuedao",
	class_name = "Fguilongzhanyuedao",
	subtype = "JJ_shenbingku",
	range = 3,
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, Fguilongzhanyuedaos, false, true, false)
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "Fguilongzhanyuedao", true, true)
	end,
}
Fguilongzhanyuedao:clone(sgs.Card_Spade, 5):setParent(newgodsCard)
if not sgs.Sanguosha:getSkill("Fguilongzhanyuedao") then skills:append(Fguilongzhanyuedaos) end
--7.赤血青锋
Fchixieqingfengs = sgs.CreateTriggerSkill{
	name = "Fchixieqingfeng",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetConfirming, sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.TargetConfirming then
			if use.card:isKindOf("Slash") and use.from:hasSkill(self:objectName()) and use.from:getWeapon():isKindOf("Fchixieqingfeng") then
				room:sendCompulsoryTriggerLog(use.from, self:objectName())
				sgs.Sanguosha:playAudioEffect("audio/equip/qinggang_sword.ogg", false)
				room:setEmotion(use.from, "weapon/qinggang_sword")
				use.from:setFlags("f_cxqfPFfrom")
				for _, p in sgs.qlist(use.to) do
					room:setPlayerCardLimitation(p, "use,response", ".|.|.|hand", false)
					p:setFlags("f_cxqfPFto")
					room:addPlayerMark(p, "Armor_Nullified")
				end
				data:setValue(use)
			end
		elseif event == sgs.CardFinished and use.card:isKindOf("Slash") then
			if not player:hasFlag("f_cxqfPFfrom") then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("f_cxqfPFto") then
					room:removePlayerCardLimitation(p, "use,response", ".|.|.|hand")
					p:setFlags("-f_cxqfPFto")
					if p:getMark("Armor_Nullified") then
						room:removePlayerMark(p, "Armor_Nullified")
					end
				end
			end
			player:setFlags("-f_cxqfPFfrom")
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
Fchixieqingfeng = sgs.CreateWeapon{
	name = "_f_chixieqingfeng",
	class_name = "Fchixieqingfeng",
	subtype = "JJ_shenbingku",
	range = 2,
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, Fchixieqingfengs, false, true, false)
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "Fchixieqingfeng", true, true)
	end,
}
Fchixieqingfeng:clone(sgs.Card_Spade, 6):setParent(newgodsCard)
if not sgs.Sanguosha:getSkill("Fchixieqingfeng") then skills:append(Fchixieqingfengs) end
--8.镔铁双戟
Fbingtieshuangjis = sgs.CreateTriggerSkill{
	name = "Fbingtieshuangji",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.SlashMissed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local effect = data:toSlashEffect()
		if effect.slash and effect.from:objectName() == player:objectName() then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:loseHp(player, 1)
				if not player:isAlive() then return false end
				room:obtainCard(player, effect.slash)
				room:drawCards(player, 1, self:objectName())
				room:addPlayerMark(player, self:objectName())
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getWeapon():isKindOf("Fbingtieshuangji")
	end,
}
Fbingtieshuangjix = sgs.CreateTargetModSkill{
	name = "Fbingtieshuangjix",
	residue_func = function(self, player)
		local n = player:getMark("Fbingtieshuangji")
		if n > 0 then
			return n
		else
			return 0
		end
	end,
}
FbingtieshuangjiClear = sgs.CreateTriggerSkill{
	name = "FbingtieshuangjiClear",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then return false end
		room:setPlayerMark(player, "Fbingtieshuangji", 0)
	end,
	can_trigger = function(self, player)
		return player:getMark("Fbingtieshuangji") > 0
	end,
}
Fbingtieshuangji = sgs.CreateWeapon{
	name = "_f_bingtieshuangji",
	class_name = "Fbingtieshuangji",
	subtype = "JJ_shenbingku",
	range = 3,
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, Fbingtieshuangjis, false, true, false)
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "Fbingtieshuangji", true, true)
	end,
}
Fbingtieshuangji:clone(sgs.Card_Diamond, 13):setParent(newgodsCard)
if not sgs.Sanguosha:getSkill("Fbingtieshuangji") then skills:append(Fbingtieshuangjis) end
if not sgs.Sanguosha:getSkill("Fbingtieshuangjix") then skills:append(Fbingtieshuangjix) end
if not sgs.Sanguosha:getSkill("FbingtieshuangjiClear") then skills:append(FbingtieshuangjiClear) end
----------
--==[[防具]]==--
--9.乌铁锁链(已有)
----
--10.五行鹤翎扇(已有)
----
--11.玲珑狮蛮带
Flinglongshimandais = sgs.CreateTriggerSkill{
	name = "Flinglongshimandai",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirmed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("SkillCard") or use.to:length() ~= 1 or not use.to:contains(player)
		or use.from:objectName() == player:objectName() then return false end
		if not room:askForSkillInvoke(player, self:objectName(), data) then return false end
		local judge = sgs.JudgeStruct()
		judge.who = player
		judge.good = true
		judge.pattern = ".|heart"
		judge.reason = self:objectName()
		room:judge(judge)
		if not judge:isGood() then return false end
		sgs.Sanguosha:playAudioEffect("audio/equip/silver_lion.ogg", false)
		room:setEmotion(player, "armor/silver_lion")
		local nullified_list = use.nullified_list
		table.insert(nullified_list, player:objectName())
		use.nullified_list = nullified_list
		data:setValue(use)
	end,
	can_trigger = function(self, player)
		return player:getArmor():isKindOf("Flinglongshimandai") and ArmorNotNullified(player)
	end,
}
Flinglongshimandai = sgs.CreateArmor{
	name = "_f_linglongshimandai",
	class_name = "Flinglongshimandai",
	subtype = "JJ_shenbingku",
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, Flinglongshimandais, false, true, false)
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "Flinglongshimandai", true, true)
	end,
}
Flinglongshimandai:clone(sgs.Card_Spade, 2):setParent(newgodsCard)
if not sgs.Sanguosha:getSkill("Flinglongshimandai") then skills:append(Flinglongshimandais) end
--12.红棉百花袍
Fhongmianbaihuapaos = sgs.CreateTriggerSkill{
	name = "Fhongmianbaihuapao",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.nature == sgs.DamageStruct_Fire or damage.nature == sgs.DamageStruct_Thunder
		or damage.nature == sgs.DamageStruct_Ice or damage.nature == sgs.DamageStruct_Poison then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:setEmotion(player, "skill_nullify")
			return true
		end
	end,
	can_trigger = function(self, player)
		return player:getArmor():isKindOf("Fhongmianbaihuapao") and ArmorNotNullified(player)
	end,
}
Fhongmianbaihuapao = sgs.CreateArmor{
	name = "_f_hongmianbaihuapao",
	class_name = "Fhongmianbaihuapao",
	subtype = "JJ_shenbingku",
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, Fhongmianbaihuapaos, false, true, false)
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "Fhongmianbaihuapao", true, true)
	end,
}
Fhongmianbaihuapao:clone(sgs.Card_Club, 1):setParent(newgodsCard)
if not sgs.Sanguosha:getSkill("Fhongmianbaihuapao") then skills:append(Fhongmianbaihuapaos) end
--13.国风玉袍
Fguofengyupaos = sgs.CreateProhibitSkill{
	name = "Fguofengyupao",
	is_prohibited = function(self, from, to, card)
		return from:objectName() ~= to:objectName() and to:getArmor() ~= nil and to:getArmor():isKindOf("Fguofengyupao")
		and ArmorNotNullified(to) and card:isNDTrick()
	end,
}
Fguofengyupao = sgs.CreateArmor{
	name = "_f_guofengyupao",
	class_name = "Fguofengyupao",
	subtype = "JJ_shenbingku",
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, Fguofengyupaos, false, true, false)
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "Fguofengyupao", true, true)
	end,
}
Fguofengyupao:clone(sgs.Card_Spade, 9):setParent(newgodsCard)
if not sgs.Sanguosha:getSkill("Fguofengyupao") then skills:append(Fguofengyupaos) end
--14.奇门八阵
Fqimenbazhens = sgs.CreateTriggerSkill{
	name = "Fqimenbazhen",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardEffected},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local effect = data:toCardEffect()
		if effect.card:isKindOf("Slash") and effect.from:objectName() ~= player:objectName() then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			sgs.Sanguosha:playAudioEffect("audio/equip/eight_diagram.ogg", false)
			room:setEmotion(player, "armor/eight_diagram")
	    	effect.nullified = true
			data:setValue(effect)
		end
	end,
	can_trigger = function(self, player)
		return player:getArmor():isKindOf("Fqimenbazhen") and ArmorNotNullified(player)
	end,
}
Fqimenbazhen = sgs.CreateArmor{
	name = "_f_qimenbazhen",
	class_name = "Fqimenbazhen",
	subtype = "JJ_shenbingku",
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, Fqimenbazhens, false, true, false)
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "Fqimenbazhen", true, true)
	end,
}
Fqimenbazhen:clone(sgs.Card_Spade, 2):setParent(newgodsCard)
if not sgs.Sanguosha:getSkill("Fqimenbazhen") then skills:append(Fqimenbazhens) end
------
--==[[宝物]]==--
--15.护心镜(已有)
----
--16.黑光铠(已有)
----
--17.束发紫金冠
Fshufazijinguans = sgs.CreateTriggerSkill{
	name = "Fshufazijinguan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase ~= sgs.Player_Start then return false end
		if room:askForSkillInvoke(player, self:objectName(), data) then
			local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName())
			room:damage(sgs.DamageStruct(self:objectName(), player, target))
		end
	end,
	can_trigger = function(self, player)
		return player:getTreasure():isKindOf("Fshufazijinguan")
	end,
}
Fshufazijinguan = sgs.CreateTreasure{
	name = "_f_shufazijinguan",
	class_name = "Fshufazijinguan",
	subtype = "JJ_shenbingku",
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, Fshufazijinguans, false, true, false)
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "Fshufazijinguan", true, true)
	end,
}
Fshufazijinguan:clone(sgs.Card_Diamond, 1):setParent(newgodsCard)
if not sgs.Sanguosha:getSkill("Fshufazijinguan") then skills:append(Fshufazijinguans) end
--18.虚妄之冕
Fxuwangzhimians = sgs.CreateDrawCardsSkill{
	name = "Fxuwangzhimian",
	frequency = sgs.Skill_Compulsory,
	draw_num_func = function(self, player, n)
		if player:getTreasure() ~= nil and player:getTreasure():isKindOf("Fxuwangzhimian") then
			player:getRoom():sendCompulsoryTriggerLog(player, self:objectName())
			return n + 2
		else
			return n
		end
	end,
}
Fxuwangzhimianx = sgs.CreateMaxCardsSkill{
	name = "Fxuwangzhimianx",
	extra_func = function(self, player)
		if player:getTreasure() ~= nil and player:getTreasure():isKindOf("Fxuwangzhimian") then
			return -1
		else
			return 0
		end
	end,
}
Fxuwangzhimian = sgs.CreateTreasure{
	name = "_f_xuwangzhimian",
	class_name = "Fxuwangzhimian",
	subtype = "JJ_shenbingku",
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, Fxuwangzhimians, false, true, false)
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "Fxuwangzhimian", true, true)
	end,
}
Fxuwangzhimian:clone(sgs.Card_Club, 4):setParent(newgodsCard)
if not sgs.Sanguosha:getSkill("Fxuwangzhimian") then skills:append(Fxuwangzhimians) end
if not sgs.Sanguosha:getSkill("Fxuwangzhimianx") then skills:append(Fxuwangzhimianx) end
--19.天机图(已有)
----
--20.太公阴符(已有)
----
--21.三略
Fsanlves = sgs.CreateTargetModSkill{
	name = "Fsanlve",
	pattern = "Slash",
	distance_limit_func = function(self, player)
		if player:getTreasure() ~= nil and player:getTreasure():isKindOf("Fsanlve") then
		    return 1
		else
		    return 0
		end
	end,
}
Fsanlvex = sgs.CreateMaxCardsSkill{
	name = "Fsanlvex",
	extra_func = function(self, player)
		if player:getTreasure() ~= nil and player:getTreasure():isKindOf("Fsanlve") then
			return 1
		else
			return 0
		end
	end,
}
Fsanlvey = sgs.CreateTargetModSkill{
	name = "Fsanlvey",
	residue_func = function(self, player)
		if player:getTreasure() ~= nil and player:getTreasure():isKindOf("Fsanlve") and player:getPhase() == sgs.Player_Play then
			return 1
		else
			return 0
		end
	end,
}
Fsanlve = sgs.CreateTreasure{
	name = "_f_sanlve",
	class_name = "Fsanlve",
	subtype = "JJ_shenbingku",
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, Fsanlves, false, true, false)
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "Fsanlve", true, true)
	end,
}
Fsanlve:clone(sgs.Card_Spade, 5):setParent(newgodsCard)
if not sgs.Sanguosha:getSkill("Fsanlve") then skills:append(Fsanlves) end
if not sgs.Sanguosha:getSkill("Fsanlvex") then skills:append(Fsanlvex) end
if not sgs.Sanguosha:getSkill("Fsanlvey") then skills:append(Fsanlvey) end
--22.照骨镜
FzhaogujingsCard = sgs.CreateSkillCard{
	name = "Fzhaogujing",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		for _, id in sgs.list(self:getSubcards()) do
		    room:showCard(source, id)
		end
		local ZGJ_toUse = sgs.Sanguosha:getCard(self:getSubcards():first())
		if ZGJ_toUse:isKindOf("Jink") or ZGJ_toUse:isKindOf("Nullification")
		or ZGJ_toUse:isKindOf("JlWuxiesy") then return false end --这几个硬要使用等的就是闪退
		local pattern = {}
		for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			if not sgs.Sanguosha:isProhibited(source, p, ZGJ_toUse) and ZGJ_toUse:isAvailable(source) then
				table.insert(pattern, ZGJ_toUse:getEffectiveId())
			end
		end
		if #pattern > 0 then
			sgs.Sanguosha:playAudioEffect("audio/equip/eight_diagram.ogg", false)
			room:setEmotion(source, "_f_zhaogujing")
			room:askForUseCard(source, table.concat(pattern, ","), "@Fzhaogujing_use:"..ZGJ_toUse:objectName(), -1)
		end
	end,
}
FzhaogujingsVS = sgs.CreateOneCardViewAsSkill{
	name = "Fzhaogujing",
	view_filter = function(self, to_select)
		return (to_select:isKindOf("BasicCard") or to_select:isNDTrick()) and not to_select:isEquipped()
	end,
	view_as = function(self, card)
	    local zgj_card = FzhaogujingsCard:clone()
		zgj_card:addSubcard(card:getId())
		return zgj_card
	end,
	response_pattern = "@@Fzhaogujing",
}
Fzhaogujings = sgs.CreateTriggerSkill{
	name = "Fzhaogujing",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseEnd},
	view_as_skill = FzhaogujingsVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play and not player:isKongcheng() then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:askForUseCard(player, "@@Fzhaogujing", "@Fzhaogujing-showcard")
			end
		end
	end,
	can_trigger = function(self, player)
		return player:getTreasure():isKindOf("Fzhaogujing")
	end,
}
Fzhaogujing = sgs.CreateTreasure{
	name = "_f_zhaogujing",
	class_name = "Fzhaogujing",
	subtype = "JJ_shenbingku",
	on_install = function(self, player)
		local room = player:getRoom()
		room:acquireSkill(player, Fzhaogujings, false, true, false)
	end,
	on_uninstall = function(self, player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "Fzhaogujing", true, true)
	end,
}
Fzhaogujing:clone(sgs.Card_Diamond, 1):setParent(newgodsCard)
if not sgs.Sanguosha:getSkill("Fzhaogujing") then skills:append(Fzhaogujings) end
------
--================--

mini_f_qigongCard = sgs.CreateSkillCard{
	name = "mini_f_qigongCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("f_qigong")
		room:setPlayerFlag(source, "f_qigong")
		local n, success, fail = 2, 0, 0 --2*(0+1)=2
		room:getThread():delay(1000)
		while n > 0 do
			local ids = room:getNCards(1)
			room:fillAG(ids)
			room:getThread():delay(1000)
			local id = ids:first()
			local card = sgs.Sanguosha:getCard(id)
			if card:isKindOf("EquipCard") then
				success = success + 1
				local to = room:askForPlayerChosen(source, room:getAllPlayers(), "f_qigong", "f_qigongUse:" .. card:objectName())
				local equip_index = card:getRealCard():toEquipCard():location()
				if to:hasEquipArea(equip_index) then
					room:useCard(sgs.CardUseStruct(card, to, to))
				else
					room:obtainCard(to, card)
				end
			else
				fail = fail + 1
				source:addToPile("f_YT", id)
			end
			room:clearAG()
			n = n - 1
		end
		if success > fail then
			room:setPlayerFlag(source, "-f_qigong")
		end
	end,
}
pro_f_qigongCard = sgs.CreateSkillCard{
	name = "mini_f_qigongCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("f_qigong")
		room:setPlayerFlag(source, "f_qigong")
		local m = self:subcardsLength()
		local n, success, fail = 2*(m+1), 0, 0
		room:getThread():delay(1000)
		while n > 0 do
			local ids = room:getNCards(1)
			room:fillAG(ids)
			room:getThread():delay(1000)
			local id = ids:first()
			local card = sgs.Sanguosha:getCard(id)
			if card:isKindOf("EquipCard") then
				success = success + 1
				local to = room:askForPlayerChosen(source, room:getAllPlayers(), "f_qigong", "f_qigongUse:" .. card:objectName())
				local equip_index = card:getRealCard():toEquipCard():location()
				if to:hasEquipArea(equip_index) then
					room:useCard(sgs.CardUseStruct(card, to, to))
				else
					room:obtainCard(to, card)
				end
			else
				fail = fail + 1
				source:addToPile("f_YT", id)
			end
			room:clearAG()
			n = n - 1
		end
		if success > fail then
			room:setPlayerFlag(source, "-f_qigong")
		end
	end,
}
f_qigong = sgs.CreateViewAsSkill{
	name = "f_qigong",
	n = 5,--n = 999,
	view_filter = function(self, selected, to_select)
		if #selected >= 0 then
			return to_select:isEquipped()
		else
			return true
		end
	end,
	view_as = function(self, cards)
		if #cards == 0 then
			return mini_f_qigongCard:clone()
		end
		--
		if #cards >= 1 and #cards <= 5 then
			local qg_card = pro_f_qigongCard:clone()
			for _, card in ipairs(cards) do
				qg_card:addSubcard(card)
			end
			return qg_card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:hasFlag(self:objectName())
	end,
}
f_shenpuyuan:addSkill(f_qigong)
f_shenpuyuanx:addSkill("f_qigong")

f_lingqi = sgs.CreateOneCardViewAsSkill{
	name = "f_lingqi",
	mute = true,
	view_filter = function(self, card)
		if not card:isKindOf("EquipCard") then return false end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			local slash = nil
			if sgs.Self:getMark("&fXiaJiang") > 0 then --侠匠
				local suit = card:getSuit()
				if suit == sgs.Card_Spade then --“毒杀”
					slash = sgs.Sanguosha:cloneCard("slash"--[["poison_slash"]], sgs.Card_SuitToBeDecided, -1)
				elseif suit == sgs.Card_Club then --冰杀
					slash = sgs.Sanguosha:cloneCard("ice_slash", sgs.Card_SuitToBeDecided, -1)
				elseif suit == sgs.Card_Diamond then --雷杀
					slash = sgs.Sanguosha:cloneCard("thunder_slash", sgs.Card_SuitToBeDecided, -1)
				elseif suit == sgs.Card_Heart then --火杀
					slash = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, -1)
				else
					return false --防无花色gank
				end
			elseif sgs.Self:getMark("&fJuJiang") > 0 then --巨匠
				slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
			end
			slash:addSubcard(card:getEffectiveId())
			slash:deleteLater()
			return slash:isAvailable(sgs.Self)
		end
		return true
	end,
	view_as = function(self, card)
		local slash = nil
		if sgs.Self:getMark("&fXiaJiang") > 0 then --侠匠
			local suit = card:getSuit()
			if suit == sgs.Card_Spade then --“毒杀”
				slash = sgs.Sanguosha:cloneCard("slash"--[["poison_slash"]], card:getSuit(), card:getNumber())
				slash:setSkillName("f_lingqix_poison")
			elseif suit == sgs.Card_Club then --冰杀
				slash = sgs.Sanguosha:cloneCard("ice_slash", card:getSuit(), card:getNumber())
				slash:setSkillName("f_lingqix")
			elseif suit == sgs.Card_Diamond then --雷杀
				slash = sgs.Sanguosha:cloneCard("thunder_slash", card:getSuit(), card:getNumber())
				slash:setSkillName("f_lingqix")
			elseif suit == sgs.Card_Heart then --火杀
				slash = sgs.Sanguosha:cloneCard("fire_slash", card:getSuit(), card:getNumber())
				slash:setSkillName("f_lingqix")
			else
				return nil --防无花色gank
			end
		elseif sgs.Self:getMark("&fJuJiang") > 0 then --巨匠
			slash = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber())
			slash:setSkillName("f_lingqij")
		end
		if slash ~= nil then
			slash:addSubcard(card:getId())
			return slash
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return sgs.Slash_IsAvailable(player) and (player:getMark("&fXiaJiang") > 0 or player:getMark("&fJuJiang") > 0)
	end,
}
f_lingqiSlashs = sgs.CreateTriggerSkill{
	name = "f_lingqiSlashs",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreCardUsed, sgs.TargetConfirming, sgs.CardFinished, sgs.DamageInflicted, sgs.Damage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		local damage = data:toDamage()
		if event == sgs.PreCardUsed then
			if use.card:isKindOf("Slash") and use.from:objectName() == player:objectName() then
				if use.card:getSkillName() == "f_lingqix" then
					room:broadcastSkillInvoke("f_lingqi", 1)
				elseif use.card:getSkillName() == "f_lingqix_poison" then
					room:broadcastSkillInvoke("f_lingqi", 1)
					room:setEmotion(player, "zhen_analeptic")
					room:setEmotion(player, "poison_slash")
				elseif use.card:getSkillName() == "f_lingqij" then
					room:broadcastSkillInvoke("f_lingqi", 2)
				end
			end
		elseif event == sgs.TargetConfirming then
			if use.card:isKindOf("Slash") and use.card:getSkillName() == "f_lingqij" then
				use.from:setFlags("f_lingqiPFfrom")
				for _, p in sgs.qlist(use.to) do
					p:setFlags("f_lingqiPFto")
					room:addPlayerMark(p, "Armor_Nullified")
				end
				data:setValue(use)
			end
		elseif event == sgs.CardFinished and use.card:isKindOf("Slash") then
			if not player:hasFlag("f_lingqiPFfrom") then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("f_lingqiPFto") then
					p:setFlags("-f_lingqiPFto")
					if p:getMark("Armor_Nullified") then
						room:removePlayerMark(p, "Armor_Nullified")
					end
				end
			end
			player:setFlags("-f_lingqiPFfrom")
		elseif event == sgs.DamageInflicted then --转化为毒属性伤害
			if damage.card and damage.card:objectName() == "slash" and (damage.card:getSkillName() == "f_lingqix_poison" or damage.card:hasFlag("poison_slash")) then
				damage.nature = sgs.DamageStruct_Poison
				data:setValue(damage)
			end
		elseif event == sgs.Damage then --“毒杀”效果
			if damage.card and damage.card:objectName() == "slash" and (damage.card:getSkillName() == "f_lingqix_poison" or damage.card:hasFlag("poison_slash")) then
				local lhp = damage.to:getLostHp()
				local n = lhp*0.2
				if lhp >= 5 or (lhp < 5 and math.random() <= n) then --5*20%=100%
					if damage.to:isMale() then sgs.Sanguosha:playAudioEffect("audio/system/poison_injure1.ogg", false)
					elseif damage.to:isFemale() then sgs.Sanguosha:playAudioEffect("audio/system/poison_injure2.ogg", false)
					end
					room:loseHp(damage.to, 1)
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_lingqiSlashMD = sgs.CreateTargetModSkill{
    name = "f_lingqiSlashMD",
	pattern = "Slash",
	distance_limit_func = function(self, player, card)
	    if card:getSkillName() == "f_lingqix" or card:getSkillName() == "f_lingqix_poison" then
			return 1000
		else
			return 0
		end
	end,
}
f_shenpuyuan:addSkill(f_lingqi)
f_shenpuyuanx:addSkill("f_lingqi")
if not sgs.Sanguosha:getSkill("f_lingqiSlashs") then skills:append(f_lingqiSlashs) end
if not sgs.Sanguosha:getSkill("f_lingqiSlashMD") then skills:append(f_lingqiSlashMD) end

f_shenjiangCard = sgs.CreateSkillCard{
    name = "f_shenjiangCard",
	target_fixed = false,
	will_throw = true,
	mute = true,
	filter = function(self, targets, to_select)
		return #targets == 0
	end,
	on_effect = function(self, effect)
	    local room = effect.from:getRoom()
		if effect.from:getMark("&fXiaJiang") > 0 then
			local rcard = room:askForCard(effect.from, ".!", "@f_shenjiangRecast", sgs.QVariant(), sgs.Card_MethodRecast)
			if rcard then
				--room:showcard(effect.from, rcard:getId())
				room:moveCardTo(rcard, effect.from, nil, sgs.Player_DiscardPile, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECAST, effect.from:objectName(), "f_shenjiang", ""))
				local log = sgs.LogMessage()
				log.type = "#UseCard_Recast"
				log.from = effect.from
				log.card_str = rcard:toString()
				room:sendLog(log)
				effect.from:drawCards(1, "recast")
				local suit = rcard:getSuit()
				if suit == sgs.Card_Spade then --混毒弯匕
					room:addPlayerMark(effect.to, "&f_shenjiang:+_hunduwanbi")
				elseif suit == sgs.Card_Club then --水波剑
					room:addPlayerMark(effect.to, "&f_shenjiang:+_shuibojian")
				elseif suit == sgs.Card_Diamond then --烈淬刀
					room:addPlayerMark(effect.to, "&f_shenjiang:+_liecuidao")
				elseif suit == sgs.Card_Heart then --红锻枪
					room:addPlayerMark(effect.to, "&f_shenjiang:+_hongduanqiang")
				else
					return false
				end
				if not effect.to:hasSkill("f_shenjiangVAE") then
					room:acquireSkill(effect.to, "f_shenjiangVAE", false)
				end
			end
		elseif effect.from:getMark("&fJuJiang") > 0 then
			room:setPlayerFlag(effect.to, "f_shenjiangTarget") --锁定目标
			room:askForUseCard(effect.from, "@@f_shenjiangSBK!", "@f_shenjiangSBK") --从“神兵库”掏出大宝贝
			room:setPlayerFlag(effect.to, "-f_shenjiangTarget")
		end
	end,
}
f_shenjiang = sgs.CreateViewAsSkill{
    name = "f_shenjiang",
    n = 4,
	expand_pile = "f_YT",
	view_filter = function(self, selected, to_select)
	    return sgs.Self:getPile("f_YT"):contains(to_select:getId())
	end,
    view_as = function(self, cards)
	    if #cards == 4 then
			local c = f_shenjiangCard:clone()
			for _, card in ipairs(cards) do
				c:addSubcard(card)
			end
			return c
		end
		return nil
	end,
	enabled_at_play = function(self, player)
	    return player:getPile("f_YT"):length() >= 4 and ((player:getMark("&fXiaJiang") > 0 and not player:isKongcheng()) --要保证能重铸
		or (player:getMark("&fJuJiang") > 0 and player:getPile("spy_shenbingku"):length() > 0)) --神兵库都没装备了还发动个锤子
	end,
}
f_shenjiangVAE = sgs.CreateViewAsEquipSkill{
	name = "f_shenjiangVAE",
	view_as_equip = function(self, player)
		if player:getMark("&f_shenjiang:+_hunduwanbi") > 0 then
			return "_hunduwanbi"
		elseif player:getMark("&f_shenjiang:+_shuibojian") > 0 then
			return "_shuibojian"
		elseif player:getMark("&f_shenjiang:+_liecuidao") > 0 then
			return "_liecuidao"
		elseif player:getMark("&f_shenjiang:+_hongduanqiang") > 0 then
			return "_hongduanqiang"
		else
			return ""
		end
	end,
}
f_shenjiangSBKCard = sgs.CreateSkillCard{
    name = "f_shenjiangSBKCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		local SB = sgs.Sanguosha:getCard(self:getSubcards():first())
		local sb_id = self:getSubcards():first()
		local log = sgs.LogMessage()
		log.type = "$f_shenjiangSBK"
		log.from = source
		log.card_str = SB:toString()
		room:sendLog(log)
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasFlag("f_shenjiangTarget") then
				room:obtainCard(p, SB)
				if p:getState() == "robot" then --AI默认无脑装
					local equip_index = SB:getRealCard():toEquipCard():location()
					if p:hasEquipArea(equip_index) then
						room:useCard(sgs.CardUseStruct(SB, p, p))
					end
				else
					local pattern = {}
					for _, q in sgs.qlist(room:getOtherPlayers(p)) do
						if not sgs.Sanguosha:isProhibited(p, q, SB) and SB:isAvailable(p) then
							table.insert(pattern, sb_id)
						end
					end
					if #pattern > 0 then
						room:askForUseCard(p, table.concat(pattern, ","), "@f_shenjiangSBK_use:"..SB:objectName(), -1)
					end
				end
				break
			end
		end
	end,
}
f_shenjiangSBK = sgs.CreateOneCardViewAsSkill{
    name = "f_shenjiangSBK",
	filter_pattern = ".|.|.|spy_shenbingku",
	expand_pile = "spy_shenbingku",
	view_as = function(self, originalCard)
	    local sbk_equip = f_shenjiangSBKCard:clone()
		sbk_equip:addSubcard(originalCard:getId())
		return sbk_equip
	end,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@f_shenjiangSBK")
	end,
}
f_shenjiangAC = sgs.CreateTriggerSkill{
	name = "f_shenjiangAC",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:getSkillName() == "f_shenjiang" and use.from:objectName() == player:objectName() then
				if player:getMark("&fXiaJiang") > 0 then
					room:broadcastSkillInvoke("f_shenjiang", 1)
				elseif player:getMark("&fJuJiang") > 0 then
					room:broadcastSkillInvoke("f_shenjiang", 2)
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			if player:hasSkill("f_shenjiangVAE") then
				room:detachSkillFromPlayer(player, "f_shenjiangVAE")
			end
			room:setPlayerMark(player, "&f_shenjiang:+_hunduwanbi", 0)
			room:setPlayerMark(player, "&f_shenjiang:+_shuibojian", 0)
			room:setPlayerMark(player, "&f_shenjiang:+_liecuidao", 0)
			room:setPlayerMark(player, "&f_shenjiang:+_hongduanqiang", 0)
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_shenpuyuan:addSkill(f_shenjiang)
f_shenpuyuanx:addSkill("f_shenjiang")
if not sgs.Sanguosha:getSkill("f_shenjiangVAE") then skills:append(f_shenjiangVAE) end
if not sgs.Sanguosha:getSkill("f_shenjiangSBK") then skills:append(f_shenjiangSBK) end
if not sgs.Sanguosha:getSkill("f_shenjiangAC") then skills:append(f_shenjiangAC) end

--神马钧
f_shenmajun = sgs.General(extension_f, "f_shenmajun", "god", 3, true, false, false, 3, 1)

f_yanfa = sgs.CreateTriggerSkill{
	name = "f_yanfa",
	priority = 100001,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			--统计隐藏卡牌（后续还会视情况扩增）
			local hidden_cards = {"_qizhengxiangsheng", "_hunduwanbi", "_shuibojian", "_liecuidao", "_hongduanqiang", "_tianleiren",
			"_piliche", "_secondpiliche", "_tenyearpiliche", "_feilunzhanyu", "_sichengliangyu", "_tiejixuanyu", "_jinshu", "_qiongshu", "_xishu",
			"_f_wushuangfangtianji", "_f_guilongzhanyuedao", "_f_chixieqingfeng", "_f_bingtieshuangji",
			"_f_linglongshimandai", "_f_hongmianbaihuapao", "_f_guofengyupao", "_f_qimenbazhen",
			"_f_shufazijinguan", "_f_xuwangzhimian", "_f_sanlve", "_f_zhaogujing",
			"_f_goldenchelsea", "_yrjxn", "_xtbgz", "_rwjgd", "_zyszk", "_tybrj",
			"_xy_ruyijingubang_one", "_xy_ruyijingubang_two", "_xy_ruyijingubang_three", "_xy_ruyijingubang_four",
			"_ov_lingbaoxianhu", "_ov_taijifuchen", "_ov_chongyingshenfu", "_ov_tiaojiyanmei", "_ov_binglinchengxia", "_ov_mantianguohai",
			"_wm_jugongjincui", "_wm_chushibiao", "_wm_bazhentu", "_wm_kongmingdeng", "_wm_huoshou", "_wm_qixingdeng",
			"_keqi_taipingyaoshu", "_kecheng_tuixinzhifu", "_kecheng_chenhuodajie", "_kecheng_stabs_slash",
			"_tpys_nhlx"
			}
			local hc_data = player:property("SkillDescriptionRecord_f_yanfa"):toString():split("+") --准备好储存隐藏卡牌信息的存档
			local cds = sgs.IntList()
			for _, id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
				local hc = sgs.Sanguosha:getEngineCard(id)
				if table.contains(hidden_cards, hc:objectName()) then
					cds:append(id)
					if not table.contains(hc_data, hc:objectName()) then
						table.insert(hc_data, hc:objectName())
					end
				end
			end
			if not cds:isEmpty() then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:doLightbox("f_yanfaAnimate")
				room:shuffleIntoDrawPile(player, cds, self:objectName(), false) --把这些牛鬼蛇神加入牌堆，群魔乱舞！
				room:setPlayerProperty(player, "SkillDescriptionRecord_f_yanfa", sgs.QVariant(table.concat(hc_data, "+")))
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do --把储存完毕的这份存档发送给全场角色，方便后续的“机神”宝物加成
					room:setPlayerProperty(p, "SkillDescriptionRecord_f_yanfa", sgs.QVariant(table.concat(hc_data, "+")))
				end
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				local cds = {}
				local hc_data = player:property("SkillDescriptionRecord_f_yanfa"):toString():split("+")
				for _, c in sgs.qlist(room:getDrawPile()) do
					local cd = sgs.Sanguosha:getCard(c)
					if table.contains(hc_data, cd:objectName()) then
						table.insert(cds, cd)
					end
				end
				if #cds > 0 then
					local ran_cd = cds[math.random(1, #cds)]
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:obtainCard(player, ran_cd)
				end
			end
		end
	end,
}
f_shenmajun:addSkill(f_yanfa)

f_jishenCard = sgs.CreateSkillCard{
	name = "f_jishenCard",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:hasEquipArea()
	end,
	on_use = function(self, room, source, targets)
		local jiangjun = targets[1]
		local choices = {}
		for i = 0, 4 do
			table.insert(choices, i)
		end
		local mhp = source:getMaxHp()
		if mhp > 5 then mhp = 5 end
		local n = 5 - mhp
		while n > 0 do
			local buzao = choices[math.random(1, #choices)]
			table.removeOne(choices, buzao)
			n = n - 1
		end
		local choice = room:askForChoice(source, "f_jishen", table.concat(choices, "+"))
		local area = tonumber(choice)
		local use_id = -1
		for _, id in sgs.qlist(room:getDrawPile()) do
			local card = sgs.Sanguosha:getCard(id)
			if card:isKindOf("EquipCard") and card:getRealCard():toEquipCard():location() == area then
				use_id = id
				break
			end
		end
		--使用装备
		if use_id >= 0 then
			local use_card = sgs.Sanguosha:getCard(use_id)
			if jiangjun:isAlive() and jiangjun:canUse(use_card, jiangjun, true) then
				room:useCard(sgs.CardUseStruct(use_card, jiangjun, jiangjun))
			end
		end
		--附以加成
		if area == 0 then --武器加伤
			room:addPlayerMark(jiangjun, "&f_jishen+jsweapon")
		elseif area == 1 then --防具减伤
			room:addPlayerMark(jiangjun, "&f_jishen+jsarmor")
		elseif area == 2 then -- +1马增回
			room:addPlayerMark(jiangjun, "&f_jishen+jsdefen")
		elseif area == 3 then -- -1马减距
			room:addPlayerMark(jiangjun, "&f_jishen+jsoffen")
		elseif area == 4 then --宝物摸牌
			room:addPlayerMark(jiangjun, "&f_jishen+jstrsr")
		end
	end,
}
f_jishen = sgs.CreateZeroCardViewAsSkill{
	name = "f_jishen",
	view_as = function()
		return f_jishenCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#f_jishenCard")
	end,
}
f_jishenBUFF = sgs.CreateTriggerSkill{
	name = "f_jishenBUFF",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.ConfirmDamage, sgs.DamageInflicted, sgs.PreHpRecover, sgs.TargetSpecified, sgs.CardUsed, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage, recover, use, change = data:toDamage(), data:toRecover(), data:toCardUse(), data:toPhaseChange()
		local smj = room:findPlayerBySkillName("f_jishen")
		if event == sgs.ConfirmDamage then
			if damage.from:objectName() == player:objectName() and player:getMark("&f_jishen+jsweapon") > 0
			and damage.card and not damage.card:isVirtualCard() then
				if smj then room:sendCompulsoryTriggerLog(smj, "f_jishen") end
				room:broadcastSkillInvoke("f_jishen")
				damage.damage = damage.damage*2
				data:setValue(damage)
			end
		elseif event == sgs.DamageInflicted then
			if damage.to:objectName() == player:objectName() and player:getMark("&f_jishen+jsarmor") > 0
			and not (damage.card and not damage.card:isVirtualCard()) then
				if smj then room:sendCompulsoryTriggerLog(smj, "f_jishen") end
				room:broadcastSkillInvoke("f_jishen")
				damage.damage = damage.damage/2
				data:setValue(damage)
				if damage.damage < 1 then return true end
			end
		elseif event == sgs.PreHpRecover then
			if recover.who and recover.who:objectName() == player:objectName() and player:getMark("&f_jishen+jsdefen") > 0 then
				if smj then room:sendCompulsoryTriggerLog(smj, "f_jishen") end
				room:broadcastSkillInvoke("f_jishen")
				recover.recover = recover.recover*2
				data:setValue(recover)
			end
		elseif event == sgs.TargetSpecified then
			if use.from:objectName() == player:objectName() and player:getMark("&f_jishen+jsoffen") > 0
			and use.card and not use.card:isKindOf("SkillCard") then
				if smj then room:sendCompulsoryTriggerLog(smj, "f_jishen") end
				room:broadcastSkillInvoke("f_jishen")
				local no_respond_list = use.no_respond_list
				for _, p in sgs.qlist(use.to) do
					if player:distanceTo(p) == 1 then
						table.insert(no_respond_list, p:objectName())
					end
				end
				use.no_respond_list = no_respond_list
				data:setValue(use)
			end
		elseif event == sgs.CardUsed then
			local hc_data = player:property("SkillDescriptionRecord_f_yanfa"):toString():split("+")
			if use.from:objectName() == player:objectName() and player:getMark("&f_jishen+jstrsr") > 0
			and use.card and table.contains(hc_data, use.card:objectName()) then
				if smj then room:sendCompulsoryTriggerLog(smj, "f_jishen") end
				room:broadcastSkillInvoke("f_jishen")
				room:drawCards(player, 1, "f_jishen")
			end
		elseif event == sgs.EventPhaseChanging then
			if change.to ~= sgs.Player_NotActive then return false end
			room:setPlayerMark(player, "&f_jishen+jsweapon", 0)
			room:setPlayerMark(player, "&f_jishen+jsarmor", 0)
			room:setPlayerMark(player, "&f_jishen+jsdefen", 0)
			room:setPlayerMark(player, "&f_jishen+jsoffen", 0)
			room:setPlayerMark(player, "&f_jishen+jstrsr", 0)
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_jishenOF = sgs.CreateDistanceSkill{
	name = "f_jishenOF",
	correct_func = function(self, from)
		if from:getMark("&f_jishen+jsoffen") > 0 then
			local d = from:getEquips():length()
			if d > 0 then
				return -(d+1)/2
			else
				return 0
			end
		else
			return 0	
		end
	end,
}
f_shenmajun:addSkill(f_jishen)
if not sgs.Sanguosha:getSkill("f_jishenBUFF") then skills:append(f_jishenBUFF) end
if not sgs.Sanguosha:getSkill("f_jishenOF") then skills:append(f_jishenOF) end





--

--神司马炎(初版)
f_shensimayan = sgs.General(extension_f, "f_shensimayan", "god", 4, true)

f_zhengmie = sgs.CreateTriggerSkill{
	name = "f_zhengmie",
	global = true,
	priority = {-3, -3, -3, -3},
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseProceeding, sgs.DamageCaused, sgs.EventPhaseEnd, sgs.RoundStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseProceeding then
			local phase = player:getPhase()
			if phase ~= sgs.Player_Start then return false end
			for _, smy in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if smy:getMark("&f_zhengmie") >= 3 then continue end
				local zmto = room:askForPlayerChosen(smy, room:getOtherPlayers(player), self:objectName(), "f_zhengmie-invoke:" .. player:objectName(), true, true) --默认不杀自己，总不能讨伐自己吧
				if zmto then
					--播放文字语音
					if math.random() <= 0.5 then room:doLightbox("$f_zhengmie1")
					else room:doLightbox("$f_zhengmie2") end
					--
					room:addPlayerMark(smy, "&f_zhengmie")
					room:setPlayerFlag(smy, "f_zhengmieSource")
					if not player:hasFlag("f_zhengmieTarget") then room:setPlayerFlag(player, "f_zhengmieTarget") end
					local zm_slash = room:askForUseSlashTo(player, zmto, "@f_zhengmie-slash:" .. zmto:objectName(), false)
				end
			end
		elseif event == sgs.DamageCaused then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash") and damage.from:objectName() == player:objectName() and player:hasFlag("f_zhengmieTarget") then
				room:setPlayerFlag(player, "-f_zhengmieTarget")
				for _, zmf in sgs.qlist(room:getAllPlayers()) do
					if zmf:hasFlag("f_zhengmieSource") then
						room:setPlayerFlag(zmf, "-f_zhengmieSource")
						if zmf:hasSkill(self:objectName()) then
							room:sendCompulsoryTriggerLog(zmf, self:objectName())
							if math.random() <= 0.5 then room:doLightbox("$f_zhengmie1")
							else room:doLightbox("$f_zhengmie2") end
							room:drawCards(zmf, 1, self:objectName())
							zmf:gainMark("&fZHENG", 1)
						end
					end
				end
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Start then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:hasFlag("f_zhengmieSource") then room:setPlayerFlag(p, "-f_zhengmieSource") end
					if p:hasFlag("f_zhengmieTarget") then room:setPlayerFlag(p, "-f_zhengmieTarget") end
				end
			end
		elseif event == sgs.RoundStart then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, "&f_zhengmie", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_shensimayan:addSkill(f_zhengmie)

f_diyun = sgs.CreateTriggerSkill{
	name = "f_diyun",
	priority = -4,
	frequency = sgs.Skill_Wake,
	events = {sgs.EventPhaseProceeding},
	waked_skills = "dy_shemi, f_shensimayan_sktc",
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase ~= sgs.Player_Start or player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getMark("&fZHENG") < 3 and player:getMark("&fZHENGf") < 3 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if math.random() <= 0.5 then room:doLightbox("$f_diyun1")
		else room:doLightbox("$f_diyun2") end
		room:doSuperLightbox("f_shensimayan", self:objectName())
		room:loseMaxHp(player, 1)
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
		if player:isWounded() then
			if room:askForChoice(player, self:objectName(), "rec+drw") == "rec" then
				local recover = sgs.RecoverStruct()
				recover.who = player
				room:recover(player, recover)
			else
				room:drawCards(player, 2, self:objectName())
			end
		else
			room:drawCards(player, 2, self:objectName())
		end
		if not player:hasSkill("dy_shemi") then
			room:acquireSkill(player, "dy_shemi")
		end
	end,
	can_trigger = function(self, player)
	    return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
f_shensimayan:addSkill(f_diyun)
f_shensimayan:addRelateSkill("dy_shemi")
f_shensimayan:addRelateSkill("f_shensimayan_sktc")
--“奢靡”
dy_shemi = sgs.CreateTriggerSkill{
	name = "dy_shemi",
	frequency = sgs.Skill_Frequent,--NotFrequent,
	events = {sgs.EventPhaseStart, sgs.DrawNCards, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Draw then
				--if not room:askForSkillInvoke(player, self:objectName(), data) then return false end
				local choices = {"1", "2", "cancel"}
				local n = 2
				while n > 0 do
					local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
					if choice == "cancel" then break end
					if choice == "1" then
						room:setPlayerFlag(player, "dy_shemi_draw")
						table.removeOne(choices, "1")
					elseif choice == "2" then
						room:setPlayerFlag(player, "dy_shemi_slash")
						table.removeOne(choices, "2")
					end
					room:addPlayerMark(player, "&dy_shemi")
					n = n - 1
				end
				if math.random() <= 0.5 then room:doLightbox("$dy_shemi1")
				else room:doLightbox("$dy_shemi2") end
			end
		elseif event == sgs.DrawNCards then
			if player:hasFlag("dy_shemi_draw") then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				local count = data:toInt() + 2
				data:setValue(count)
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_Finish then return false end
			if player:isKongcheng() and player:getEquips():length() > 0 and player:canDiscard(player, "e") then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				if math.random() <= 0.5 then room:doLightbox("$dy_shemi1")
				else room:doLightbox("$dy_shemi2") end
				local yangche = room:askForCardChosen(player, player, "e", self:objectName(), false, sgs.Card_MethodDiscard)
				room:throwCard(yangche, player, player)
			end
		end
	end,
}
dy_shemiSlashBuff = sgs.CreateTargetModSkill{
	name = "dy_shemiSlashBuff",
	pattern = "Slash",
	residue_func = function(self, player)
		if player:hasFlag("dy_shemi_slash") and player:getPhase() == sgs.Player_Play then
			return 1
		else
			return 0
		end
	end,
	extra_target_func = function(self, player)
		if player:hasFlag("dy_shemi_slash") and player:getPhase() == sgs.Player_Play then
			return 1
		else
			return 0
		end
	end,
}
dy_shemiDeBuff = sgs.CreateMaxCardsSkill{
	name = "dy_shemiDeBuff",
	extra_func = function(self, player)
		local n = player:getMark("&dy_shemi")
		if n > 0 then
		    return -n
		else
			return 0
		end
	end,
}
f_shensimayan_sktc = sgs.CreateTriggerSkill{
	name = "f_shensimayan_sktc",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then return false end
		for _, p in sgs.qlist(room:getAllPlayers()) do
			room:setPlayerMark(p, "&dy_shemi", 0)
			if p:hasFlag("dy_shemi_draw") then room:setPlayerFlag(p, "dy_shemi_draw") end
			if p:hasFlag("dy_shemi_slash") then room:setPlayerFlag(p, "dy_shemi_slash") end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
if not sgs.Sanguosha:getSkill("dy_shemi") then skills:append(dy_shemi) end
if not sgs.Sanguosha:getSkill("dy_shemiSlashBuff") then skills:append(dy_shemiSlashBuff) end
if not sgs.Sanguosha:getSkill("dy_shemiDeBuff") then skills:append(dy_shemiDeBuff) end
if not sgs.Sanguosha:getSkill("f_shensimayan_sktc") then skills:append(f_shensimayan_sktc) end

--神司马炎(正式版)
f_shensimayan_f = sgs.General(extension_f, "f_shensimayan_f", "god", 4, true)

f_zhengmie_f = sgs.CreateTriggerSkill{
	name = "f_zhengmie_f",
	global = true,
	priority = {-3, -3, -3, -3},
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseProceeding, sgs.DamageCaused, sgs.EventPhaseEnd, sgs.RoundStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseProceeding then
			local phase = player:getPhase()
			if phase ~= sgs.Player_Start then return false end
			for _, smy in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if smy:getMark("&f_zhengmie_f") >= 3 then continue end
				local zmto = room:askForPlayerChosen(smy, room:getOtherPlayers(player), self:objectName(), "f_zhengmie_f-invoke:" .. player:objectName(), true, true) --默认不杀自己，总不能讨伐自己吧
				if zmto then
					--播放文字语音
					if math.random() <= 0.5 then room:doLightbox("$f_zhengmie1")
					else room:doLightbox("$f_zhengmie2") end
					--
					room:addPlayerMark(smy, "&f_zhengmie_f")
					room:setPlayerFlag(smy, "f_zhengmie_fSource")
					if not player:hasFlag("f_zhengmie_fTarget") then room:setPlayerFlag(player, "f_zhengmie_fTarget") end
					if player:canSlash(zmto, nil, false) then
						local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
						slash:setSkillName(self:objectName())
						room:useCard(sgs.CardUseStruct(slash, player, zmto), false)
					end
				end
			end
		elseif event == sgs.DamageCaused then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash") and damage.from:objectName() == player:objectName() and player:hasFlag("f_zhengmie_fTarget") then
				room:setPlayerFlag(player, "-f_zhengmie_fTarget")
				for _, zmf in sgs.qlist(room:getAllPlayers()) do
					if zmf:hasFlag("f_zhengmie_fSource") then
						room:setPlayerFlag(zmf, "-f_zhengmie_fSource")
						if zmf:hasSkill(self:objectName()) then
							room:sendCompulsoryTriggerLog(zmf, self:objectName())
							if math.random() <= 0.5 then room:doLightbox("$f_zhengmie1")
							else room:doLightbox("$f_zhengmie2") end
							room:drawCards(zmf, 1, self:objectName())
							zmf:gainMark("&fZHENGf", 1)
						end
					end
				end
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Start then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if p:hasFlag("f_zhengmie_fSource") then room:setPlayerFlag(p, "-f_zhengmie_fSource") end
					if p:hasFlag("f_zhengmie_fTarget") then room:setPlayerFlag(p, "-f_zhengmie_fTarget") end
				end
			end
		elseif event == sgs.RoundStart then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				room:setPlayerMark(p, "&f_zhengmie_f", 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_shensimayan_f:addSkill(f_zhengmie_f)

f_shensimayan_f:addSkill("f_diyun")
f_shensimayan_f:addRelateSkill("dy_shemi")
f_shensimayan_f:addRelateSkill("f_shensimayan_sktc")

--神刘协
f_shenliuxie = sgs.General(extension_f, "f_shenliuxie", "god", 3, true)

f_skyssonCard = sgs.CreateSkillCard{
	name = "f_skyssonCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return #targets < 2
	end,
	feasible = function(self, targets)
		return #targets == 2
	end,
	on_use = function(self, room, source, targets)
		local hxds = sgs.SPlayerList()
		for _, p in ipairs(targets) do
			hxds:append(p)
		end
		local from = room:askForPlayerChosen(source, hxds, "f_skysson", "f_skysson-slashfrom")
		room:setPlayerFlag(from, "f_skysson_sf")
		local to
		for _, p in ipairs(targets) do
			if not p:hasFlag("f_skysson_sf") then
				to = p
			else
				room:setPlayerFlag(p, "-f_skysson_sf")
			end
		end
		local use_slash = room:askForUseSlashTo(from, to, "@f_skysson-slash:" .. to:objectName(), true)
		if not use_slash then
			local log = sgs.LogMessage()
			log.type = "$to_f_shenliuxie_fou"
			log.from = source
			log.to:append(from)
			room:sendLog(log)
			if source:canSlash(from, nil, false) then
				local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				slash:setSkillName("f_skysson")
				room:useCard(sgs.CardUseStruct(slash, source, from))
			end
		end
	end,
}
f_skysson = sgs.CreateOneCardViewAsSkill{
	name = "f_skysson",
	view_filter = function(self, to_select)
		return true
	end,
    view_as = function(self, cards)
		local ss_card = f_skyssonCard:clone()
		ss_card:addSubcard(cards)
		return ss_card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#f_skyssonCard") and not player:isNude()
	end,
}
f_skyssons = sgs.CreateTriggerSkill{
	name = "f_skyssons",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardAsked, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardAsked then
			local pattern = data:toStringList()[1]
			local prompt = data:toStringList()[2]
			if pattern ~= "jink" or string.find(prompt, "@f_skysson-jink")
			or player:getMark(self:objectName()) > 0 or not player:hasSkill("f_skysson") then return false end
			if not room:askForSkillInvoke(player, "f_skysson", data) then return false end
			room:broadcastSkillInvoke("f_skysson")
			room:addPlayerMark(player, self:objectName())
			local tohelp = sgs.QVariant()
			tohelp:setValue(player)
			local prompt = string.format("@f_skysson-jink:%s", player:objectName())
			local jw = room:askForPlayerChosen(player, room:getAllPlayers(), "f_skysson", "f_skysson-usejink")
			local jink = room:askForCard(jw, "jink", prompt, tohelp, sgs.Card_MethodResponse, player, false, "", true)
			if jink then
				room:provide(jink)
				return true
			else
				local log = sgs.LogMessage()
				log.type = "$to_f_shenliuxie_fou"
				log.from = player
				log.to:append(jw)
				room:sendLog(log)
				if not jw:isAllNude() then
					local card = room:askForCardChosen(player, jw, "hej", "f_skysson")
					room:obtainCard(player, card, false)
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
f_shenliuxie:addSkill(f_skysson)
if not sgs.Sanguosha:getSkill("f_skyssons") then skills:append(f_skyssons) end

f_guozuo = sgs.CreateTriggerSkill{
	name = "f_guozuo",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.EventAcquireSkill, sgs.PreHpLost, sgs.MaxHpChanged, sgs.Death, sgs.DrawNCards, sgs.PreCardUsed, sgs.CardResponded, sgs.CardFinished, sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if player:hasSkill(self:objectName()) then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				if player:hasJudgeArea() then
					player:throwJudgeArea()
				end
				local mhp = player:getMaxHp()
				room:setPlayerMark(player, self:objectName(), mhp)
			end
		elseif event == sgs.EventAcquireSkill then
			if data:toString() == self:objectName() then
				local mhp = player:getMaxHp()
				room:setPlayerMark(player, self:objectName(), mhp)
			end
		--[[elseif event == sgs.PreHpLost then --处理扣减体力上限导致体力减少的情况，后续补正体力上限再调整回来（实测无用）
			if player:hasSkill(self:objectName()) then
				local hp = player:getHp()
				room:setPlayerMark(player, "f_guozuoHPinthistime", hp)
			end]]
		elseif event == sgs.MaxHpChanged then
			if player:hasSkill(self:objectName()) then
				local maxhp = player:getMaxHp()
				local mhp = player:getMark(self:objectName())
				if mhp ~= maxhp and not player:hasFlag(self:objectName()) and not player:hasFlag("f_guozuoo") then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:setPlayerFlag(player, "f_guozuoo") --防止套娃
					room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp)) --伪实现
					--[[local nowhp = player:getHp()
					local hp = player:getMark("f_guozuoHPinthistime")
					if hp > nowhp then room:setPlayerProperty(player, "hp", sgs.QVariant(hp)) end]]
					room:setPlayerFlag(player, "-f_guozuoo")
				end
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			local can_invoke = true
			for _, sl in sgs.qlist(room:getAlivePlayers()) do
				if sl:getKingdom() == death.who:getKingdom() then
					can_invoke = false
				end
			end
			if can_invoke then
				for _, slx in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					if slx:hasFlag("f_guozuoInvoked") then continue end
					room:sendCompulsoryTriggerLog(slx, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:setPlayerFlag(slx, self:objectName())
					room:gainMaxHp(slx, 1, self:objectName())
					room:setPlayerMark(slx, self:objectName(), slx:getMaxHp())
					room:setPlayerFlag(slx, "-f_guozuo")
					room:recover(slx, sgs.RecoverStruct(slx))
					room:addPlayerMark(slx, "&f_guozuoDraw")
					room:setPlayerFlag(slx, "f_guozuoInvoked")
				end
			end
		elseif event == sgs.DrawNCards then
			if player:hasSkill(self:objectName()) and player:getMark("&f_guozuoDraw") > 0 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local n = player:getMark("&f_guozuoDraw")
				local count = data:toInt() + n
				data:setValue(count)
			end
		elseif event == sgs.PreCardUsed or event == sgs.CardResponded or event == sgs.CardFinished or event == sgs.EventPhaseEnd then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasFlag("f_guozuoInvoked") then
					room:setPlayerFlag(p, "-f_guozuoInvoked") --及时清除防止神刘协多次触发“国祚”加体力上限的标志
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_shenliuxie:addSkill(f_guozuo)

f_kuilei = sgs.CreateTriggerSkill{
	name = "f_kuilei",
	global = true,
	frequency = sgs.Skill_Limited,
	limit_mark = "@f_kuilei",
	events = {sgs.AskForPeaches, sgs.AskForPeachesDone, sgs.QuitDying},
	waked_skills = "tianming, mizhao",
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		if event == sgs.AskForPeaches then
			if dying.who:objectName() == player:objectName() and player:getMark("@f_kuilei") > 0 then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:removePlayerMark(player, "@f_kuilei")
					room:broadcastSkillInvoke(self:objectName())
					room:doSuperLightbox("f_shenliuxie_kuilei", self:objectName())
					local bgx = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "f_kuilei_jieguo") --默认不能选自己，总不能自己挟自己吧
					local peach = room:askForCard(bgx, "peach", "@f_kuilei-peach:" .. player:objectName(), data, sgs.Card_MethodNone)
					if peach then
						room:useCard(sgs.CardUseStruct(peach, player, player))
						if not bgx:hasSkill("f_skysson") then
							room:acquireSkill(bgx, "f_skysson")
						end
						bgx:gainMark("&f_Xtz", 1)
						if player:isWounded() then
							local rec = player:getMaxHp() - player:getHp()
							room:recover(player, sgs.RecoverStruct(player, nil, rec))
						end
						if player:hasSkill("f_skysson") then
							room:detachSkillFromPlayer(player, "f_skysson")
						end
						if not player:hasSkill("tianming") then
							room:acquireSkill(player, "tianming")
						end
						if not player:hasSkill("mizhao") then
							room:acquireSkill(player, "mizhao")
						end
					else
						local log = sgs.LogMessage()
						log.type = "$to_f_shenliuxie_fou"
						log.from = player
						log.to:append(bgx)
						room:sendLog(log)
						if not bgx:isNude() then
							bgx:throwAllHandCardsAndEquips()
						end
						room:setPlayerFlag(player, "re_f_kuilei")
					end
				end
			end
		elseif event == sgs.QuitDying then
			if dying.who:objectName() == player:objectName() and player:hasSkill(self:objectName()) and player:hasFlag("re_f_kuilei") then
				room:setPlayerFlag(player, "-re_f_kuilei")
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:setPlayerMark(player, "@f_kuilei", 1)
			end
			if player:hasFlag("re_f_kuilei") then room:setPlayerFlag(player, "-re_f_kuilei") end
		end
	end,
}
f_shenliuxie:addSkill(f_kuilei)
f_shenliuxie:addRelateSkill("tianming")
f_shenliuxie:addRelateSkill("mizhao")

f_handi = sgs.CreateTriggerSkill{
	name = "f_handi",
	global = true,
	frequency = sgs.Skill_Wake,
	events = {sgs.Death},
	waked_skills = "luanji, tushe",
	can_wake = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		if player:getMark(self:objectName()) > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if death.who:getMark("&f_Xtz") == 0 then return false end
		return true
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		room:doSuperLightbox("f_shenliuxie_handi", self:objectName())
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
		if not player:hasSkill("f_skysson") then
			room:acquireSkill(player, "f_skysson")
		end
		if not player:hasSkill("luanji") then
			room:acquireSkill(player, "luanji")
		end
		if not player:hasSkill("tushe") then
			room:acquireSkill(player, "tushe")
		end
		if player:hasSkill("tianming") then
			room:detachSkillFromPlayer(player, "tianming")
		end
		if player:hasSkill("mizhao") then
			room:detachSkillFromPlayer(player, "mizhao")
		end
	end,
	can_trigger = function(self, player)
	    return player:isAlive() and player:hasSkill(self:objectName())
	end,
}
f_shenliuxie:addSkill(f_handi)
f_shenliuxie:addRelateSkill("luanji")
f_shenliuxie:addRelateSkill("tushe")

--新神刘禅
f_shenliushan_new = sgs.General(extension_f, "f_shenliushan_new$", "god", 4, true)

f_shenliushan_new:addSkill("f_leji")
f_shenliushan_new:addSkill("f_wuyou")

f_dansha_new = sgs.CreateTriggerSkill{
    name = "f_dansha_new",--"f_dansha_new$",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.BeforeCardsMove, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local move = data:toMoveOneTime()
		if event == sgs.BeforeCardsMove then
			if move.from and move.from:objectName() == player:objectName() then
				for _, c in sgs.qlist(player:getJudgingArea()) do
					if c:isKindOf("Indulgence") then
						room:addPlayerMark(player, self:objectName()) --“单杀”启动前置条件标记
					end
				end
			end
		elseif event == sgs.CardsMoveOneTime then
			if move.from and move.from:objectName() == player:objectName() then
				local can_invoke = false
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if card:isKindOf("Indulgence") then
						local n = 0
						for _, c in sgs.qlist(player:getJudgingArea()) do
							if c:isKindOf("Indulgence") then
								n = n + 1
							end
						end
						if n == 0 and player:getMark(self:objectName()) > 0 then
							can_invoke = true
						end
					end
				end
				if can_invoke then
					if room:askForSkillInvoke(player, self:objectName(), data) then
						local smz = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName(), "f_danshaSiMaZhao")
						room:broadcastSkillInvoke(self:objectName())
						local m = 1
						if player:isLord() then
							room:loseHp(smz, m*2)
							room:askForDiscard(smz, self:objectName(), m*2, m*2, false, true)
						else
							room:loseHp(smz, m)
							room:askForDiscard(smz, self:objectName(), m, m, false, true)
						end
						if not smz:isAlive() then
							--此间不乐，思蜀......
							if player:isLord() and not player:hasSkill("olsishu") then
								room:acquireSkill(player, "olsishu")
							end
							room:detachSkillFromPlayer(player, self:objectName())
						end
					end
				end
			end
			room:setPlayerMark(player, self:objectName(), 0)
		end
	end,
}
f_shenliushan_new:addSkill(f_dansha_new)



--

--神-曹丕&甄姬
god_caopi_zhenji = sgs.General(extension_f, "god_caopi_zhenji", "god", 4)
god_caopi_zhenji:setGender(sgs.General_Neuter)
god_caopi_zhenji_m = sgs.General(extension_f, "god_caopi_zhenji_m", "god", 4, true, true, true)
god_caopi_zhenji_f = sgs.General(extension_f, "god_caopi_zhenji_f", "god", 4, false, true, true)
diy_k_luoshangCard = sgs.CreateSkillCard{
    name = "diy_k_luoshang",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
	    source:loseMark("&"..self:objectName(), 1)
		local judge = sgs.JudgeStruct()
		judge.pattern = ".|black"
		judge.good = true
		judge.reason = self:objectName().."Card"
		judge.who = source
		judge.time_consuming = true
		room:judge(judge)
		room:obtainCard(source, judge.card, false)
		if judge:isBlack() then
			source:gainMark("&"..self:objectName(), 1)
		end
	end,
}
diy_k_luoshangvs = sgs.CreateViewAsSkill{
	name = "diy_k_luoshang" ,
	n = 0,
	view_as = function(self, cards)
		return diy_k_luoshangCard:clone()
	end ,
	enabled_at_play = function(self, player)
		return player:getMark("&"..self:objectName()) > 0 and player:usedTimes("#diy_k_luoshang") < 1
	end
}
diy_k_luoshang = sgs.CreateTriggerSkill{
	name = "diy_k_luoshang",
	global = true,
	--frequency = sgs.Skill_Frequent,
	events = {sgs.Death, sgs.EventPhaseStart, sgs.PreCardUsed, sgs.GameStart, sgs.AskForRetrial},
	view_as_skill = diy_k_luoshangvs,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart and player:hasSkill(self:objectName()) then
			    local n = 0
			    if player:getGeneralName() == "god_caopi_zhenji_m" or player:getGeneral2Name() == "god_caopi_zhenji_m" then
				    n = 2
			    end
			    if player:getGeneralName() == "god_caopi_zhenji_f" or player:getGeneral2Name() == "god_caopi_zhenji_f" then
				    n = 4
			    end
				while room:askForSkillInvoke(player, self:objectName(), data) do
					room:broadcastSkillInvoke(self:objectName(), n)
					local judge = sgs.JudgeStruct()
					judge.pattern = ".|black"
					judge.good = true
					judge.reason = self:objectName()
					judge.who = player
					judge.time_consuming = true
					room:judge(judge)
					if judge:isBad() then
			            return nil
					else
		                room:obtainCard(player, judge.card, false)
			            player:gainMark("&"..self:objectName(), 1)
					end
				end
			end
		elseif event == sgs.GameStart then
			if (player:getGeneralName() == "god_caopi_zhenji" or player:getGeneral2Name() == "god_caopi_zhenji") and player:hasSkill(self:objectName()) then
			    if room:askForChoice(player, "gcz_skinchange", "caopi+zhenji") == "caopi" then
				    if player:getGeneralName() == "god_caopi_zhenji" then
				        room:changeHero(player, "god_caopi_zhenji_m", false, false, false, true)
				    elseif player:getGeneral2Name() == "god_caopi_zhenji" then
				        room:changeHero(player, "god_caopi_zhenji_m", false, false, true, true)
					end
					room:sendCompulsoryTriggerLog(player, self:objectName())
		            room:broadcastSkillInvoke(self:objectName(), 2)
					player:gainMark("&"..self:objectName(), 3)
				else
				    if player:getGeneralName() == "god_caopi_zhenji" then
				        room:changeHero(player, "god_caopi_zhenji_f", false, false, false, true)
				    elseif player:getGeneral2Name() == "god_caopi_zhenji" then
				        room:changeHero(player, "god_caopi_zhenji_f", false, false, true, true)
					end
					room:sendCompulsoryTriggerLog(player, self:objectName())
		            room:broadcastSkillInvoke(self:objectName(), 4)
					player:gainMark("&"..self:objectName(), 3)
				end
			end
		elseif event == sgs.AskForRetrial then
			local judge = data:toJudge()
			local n = 2
			if player:getGeneralName() == "god_caopi_zhenji_f" or player:getGeneral2Name() == "god_caopi_zhenji_f" then
				n = n + 2
			end
			if judge.reason == self:objectName() and player:getPhase() ~= sgs.Player_Play and judge.who:objectName() == player:objectName() and judge.card:isRed()
			and player:getMark("&"..self:objectName()) > 0 and player:hasSkill(self:objectName()) and player:askForSkillInvoke(self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName(), n)
				player:loseMark("&"..self:objectName(), 1)
				local card_id = room:drawCard()
			    room:getThread():delay()
			    local card = sgs.Sanguosha:getCard(card_id)
			    room:retrial(card, player, judge, self:objectName())
			end
		elseif event == sgs.Death then
		    local death = data:toDeath()
		    if death.who:objectName() == player:objectName() or death.who:isNude() or not player:isAlive() or not player:hasSkill(self:objectName()) then return false end
			if not room:askForSkillInvoke(player, self:objectName(), data) then return false end
			local n = 2
			if player:getGeneralName() == "god_caopi_zhenji_f" or player:getGeneral2Name() == "god_caopi_zhenji_f" then
				n = n + 2
			end
			room:broadcastSkillInvoke(self:objectName(), n)
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			local dummi = sgs.Sanguosha:cloneCard("jink", sgs.Card_NoSuit, 0)
			local cards = death.who:getCards("he")
			for _, card in sgs.qlist(cards) do
				dummy:addSubcard(card)
				if card:isBlack() then
				    dummi:addSubcard(card)
				end
			end
			if cards:length() > 0 then
				room:obtainCard(player, dummy, false)
				if dummi:getSubcards():length() > 0 and room:askForChoice(player, "gcz_throwBlack", "yes+no") == "yes" then
					room:throwCard(dummi, player, nil)
					local d = dummi:getSubcards():length()
					player:gainMark("&"..self:objectName(), d)
				end
			end
			dummy:deleteLater()
			dummi:deleteLater()
			local judge = sgs.JudgeStruct()
			judge.pattern = ".|black"
			judge.good = true
			judge.reason = self:objectName()
			judge.who = player
			judge.time_consuming = true
			room:judge(judge)
			if judge:isBad() then
			    return nil
			else
		        room:obtainCard(player, judge.card, false)
			    player:gainMark("&"..self:objectName(), 1)
			end
		else
			local use = data:toCardUse()
			if use.card then
				local skill = use.card:getSkillName()
				local name = use.from:getGeneralName()
				local n = 0
				if use.from:getGeneralName() == "god_caopi_zhenji_m" or use.from:getGeneral2Name() == "god_caopi_zhenji_m" then
				    n = 1
				end
				if use.from:getGeneralName() == "god_caopi_zhenji_f" or use.from:getGeneral2Name() == "god_caopi_zhenji_f" then
				    n = 3
				end
				if skill == self:objectName() and use.from:hasSkill(self:objectName()) then
					room:broadcastSkillInvoke(self:objectName(), n)
					return true
				end
			end
		end
		return false
	end,
	can_trigger = function(self, player)
	    return player
	end
}
god_caopi_zhenji:addSkill(diy_k_luoshang)
god_caopi_zhenji_m:addSkill("diy_k_luoshang")
god_caopi_zhenji_f:addSkill("diy_k_luoshang")





--

--十长逝
f_ten = sgs.General(extension_f, "f_ten", "god", 1)
f_ten_zhuangsi = sgs.General(extension_f, "f_ten_zhuangsi", "god", 99, true, true, true)

f_danggu = sgs.CreateTriggerSkill{
	name = "f_danggu",
	--priority = 10,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.MarkChanged},
	waked_skills = "mobilezhimiewu, mobilepojun, mobilezhiqinzheng, oflhuishi, yizheng, hl_qiaosi, poxi, mobilemouliegong, pingcai, dg_anruo",
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			local tens = {"f_ten_dadi", "f_ten_ermei", "f_ten_sunzhang", "f_ten_bilan", "f_ten_xiayun",
			"f_ten_hanli", "f_ten_lisong", "f_ten_duangui", "f_ten_guosheng", "f_ten_dage"}
			local ten_data = player:property("SkillDescriptionRecord_f_danggu"):toString():split("+")
			for _, n in ipairs(tens) do
				if not table.contains(ten_data, n) then
					table.insert(ten_data, n)
				end
			end
			room:setPlayerProperty(player, "SkillDescriptionRecord_f_danggu", sgs.QVariant(table.concat(ten_data, "+")))
			local mhp, hp = player:getMaxHp(), player:getHp() --记录下玩家初始体力上限与体力值，用于后续结党及装死
			room:setPlayerMark(player, "f_ten_mhp", mhp)
			room:setPlayerMark(player, "f_ten_hp", hp)
			room:addPlayerMark(player, self:objectName()) --“结党”启动标记
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			if mark.name == self:objectName() and mark.gain > 0 and mark.who and mark.who:objectName() == player:objectName() then
				--开始结党
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:setPlayerMark(player, self:objectName(), 0)
				local ten_tojd = player:property("SkillDescriptionRecord_f_danggu"):toString():split("+")
				local mhp, hp = player:getMark("f_ten_mhp"), player:getMark("f_ten_hp")
				if #ten_tojd > 0 then
					--1.抽主将
					local first = ten_tojd[math.random(1, #ten_tojd)]
					if first == "f_ten_dadi" then
						room:broadcastSkillInvoke(self:objectName(), 1)
						if player:getMark("&mobilezhiwuku") == 0 then room:setPlayerMark(player, "&mobilezhiwuku", 1) end
					elseif first == "f_ten_ermei" then
						room:broadcastSkillInvoke(self:objectName(), 2)
					elseif first == "f_ten_sunzhang" then
						room:broadcastSkillInvoke(self:objectName(), 3)
					elseif first == "f_ten_bilan" then
						room:broadcastSkillInvoke(self:objectName(), 4)
					elseif first == "f_ten_xiayun" then
						room:broadcastSkillInvoke(self:objectName(), 5)
					elseif first == "f_ten_hanli" then
						room:broadcastSkillInvoke(self:objectName(), 6)
					elseif first == "f_ten_lisong" then
						room:broadcastSkillInvoke(self:objectName(), 7)
					elseif first == "f_ten_duangui" then
						room:broadcastSkillInvoke(self:objectName(), 8)
					elseif first == "f_ten_guosheng" then
						room:broadcastSkillInvoke(self:objectName(), 9)
					elseif first == "f_ten_dage" then
						room:broadcastSkillInvoke(self:objectName(), 10)
					end
					room:changeHero(player, first, false, false, false, true)
					table.removeOne(ten_tojd, first)
					if #ten_tojd > 0 then
						--2.选副将
						local ten_tojd_tpr = {}
						for _, t in pairs(ten_tojd) do
							table.insert(ten_tojd_tpr, t)
						end
						local sec_choices, n = {}, 4
						while #ten_tojd_tpr > 0 and n > 0 do
							local sec = ten_tojd_tpr[math.random(1, #ten_tojd_tpr)]
							table.insert(sec_choices, sec)
							table.removeOne(ten_tojd_tpr, sec)
							n = n - 1
						end
						local second = room:askForChoice(player, self:objectName(), table.concat(sec_choices, "+"))
						if second == "f_ten_dadi" then
							room:broadcastSkillInvoke(self:objectName(), 1)
							if player:getMark("&mobilezhiwuku") == 0 then room:setPlayerMark(player, "&mobilezhiwuku", 1) end
						elseif second == "f_ten_ermei" then
							room:broadcastSkillInvoke(self:objectName(), 2)
						elseif second == "f_ten_sunzhang" then
							room:broadcastSkillInvoke(self:objectName(), 3)
						elseif second == "f_ten_bilan" then
							room:broadcastSkillInvoke(self:objectName(), 4)
						elseif second == "f_ten_xiayun" then
							room:broadcastSkillInvoke(self:objectName(), 5)
						elseif second == "f_ten_hanli" then
							room:broadcastSkillInvoke(self:objectName(), 6)
						elseif second == "f_ten_lisong" then
							room:broadcastSkillInvoke(self:objectName(), 7)
						elseif second == "f_ten_duangui" then
							room:broadcastSkillInvoke(self:objectName(), 8)
						elseif second == "f_ten_guosheng" then
							room:broadcastSkillInvoke(self:objectName(), 9)
						elseif second == "f_ten_dage" then
							room:broadcastSkillInvoke(self:objectName(), 10)
						end
						room:changeHero(player, second, false, false, true, true)
						table.removeOne(ten_tojd, second)
					end
				end
				room:setPlayerProperty(player, "SkillDescriptionRecord_f_danggu", sgs.QVariant(table.concat(ten_tojd, "+")))
				if player:getMaxHp() ~= mhp then room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp)) end
				if player:getHp() ~= hp then room:setPlayerProperty(player, "hp", sgs.QVariant(hp)) end
				room:setPlayerMark(player, "&f_danggu_yinling", #ten_tojd) --方便玩家认知剩余的“阴灵”牌数
			--装死结束
			elseif mark.name == "f_ten_zhuangsi" and mark.gain < 0 and mark.who and mark.who:objectName() == player:objectName()
			and player:getMark("f_ten_zhuangsi") == 0 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				local mhp, hp = player:getMark("f_ten_mhp"), player:getMark("f_ten_hp")
				if player:getMaxHp() ~= mhp then room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp)) end
				if player:getHp() ~= hp then room:setPlayerProperty(player, "hp", sgs.QVariant(hp)) end
				room:addPlayerMark(player, self:objectName())
				room:drawCards(player, 4, self:objectName())
			end
		end
	end,
}
f_ten:addSkill(f_danggu)
f_ten_zhuangsi:addSkill("f_danggu")
f_ten:addRelateSkill("mobilezhimiewu")
f_ten:addRelateSkill("mobilepojun")
f_ten:addRelateSkill("mobilezhiqinzheng")
f_ten:addRelateSkill("oflhuishi")
f_ten:addRelateSkill("yizheng")
f_ten:addRelateSkill("hl_qiaosi")
f_ten:addRelateSkill("poxi")
f_ten:addRelateSkill("mobilemouliegong")
f_ten:addRelateSkill("pingcai")
f_ten:addRelateSkill("dg_anruo")

f_mowang = sgs.CreateTriggerSkill{
	name = "f_mowang",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging, sgs.AskForPeachesDone, sgs.TurnStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			local ten_tozs = player:property("SkillDescriptionRecord_f_danggu"):toString():split("+")
			if #ten_tozs == 0 then --无用之人，死！
				room:killPlayer(player)
			elseif #ten_tozs > 0 and player:hasSkill(self:objectName()) then
				room:broadcastSkillInvoke(self:objectName())
				local first = player:getGeneralName()
				if first == "f_ten_dadi" then
					room:doLightbox("f_ten_dadiAniamte", 4000)
				elseif first == "f_ten_ermei" then
					room:doLightbox("f_ten_ermeiAniamte", 4000)
				elseif first == "f_ten_sunzhang" then
					room:doLightbox("f_ten_sunzhangAniamte", 4000)
				elseif first == "f_ten_bilan" then
					room:doLightbox("f_ten_bilanAniamte", 4000)
				elseif first == "f_ten_xiayun" then
					room:doLightbox("f_ten_xiayunAniamte", 4000)
				elseif first == "f_ten_hanli" then
					room:doLightbox("f_ten_hanliAniamte", 4000)
				elseif first == "f_ten_lisong" then
					room:doLightbox("f_ten_lisongAniamte", 4000)
				elseif first == "f_ten_duangui" then
					room:doLightbox("f_ten_duanguiAniamte", 4000)
				elseif first == "f_ten_guosheng" then
					room:doLightbox("f_ten_guoshengAniamte", 4000)
				elseif first == "f_ten_dage" then
					room:doLightbox("f_ten_dageAniamte")
				end
				room:changeHero(player, "", false, false, true, false) --清空副将
				local log = sgs.LogMessage()
				log.type = "$f_mowang_EnterZS"
				log.from = player
				room:sendLog(log)
				room:changeHero(player, "f_ten_zhuangsi", true, false, false, false) --开始装死！
				room:addPlayerMark(player, "f_ten_zhuangsi")
			end
		elseif event == sgs.AskForPeachesDone then
			local dying = data:toDying()
			if dying.who:objectName() ~= player:objectName() then return false end
			if player:getHp() > 0 then return false end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			local ten_tozs = player:property("SkillDescriptionRecord_f_danggu"):toString():split("+")
			if #ten_tozs > 0 and player:hasSkill(self:objectName()) then
				room:broadcastSkillInvoke(self:objectName())
				local first = player:getGeneralName()
				if first == "f_ten_dadi" then
					room:doLightbox("f_ten_dadiAniamte", 4000)
				elseif first == "f_ten_ermei" then
					room:doLightbox("f_ten_ermeiAniamte", 4000)
				elseif first == "f_ten_sunzhang" then
					room:doLightbox("f_ten_sunzhangAniamte", 4000)
				elseif first == "f_ten_bilan" then
					room:doLightbox("f_ten_bilanAniamte", 4000)
				elseif first == "f_ten_xiayun" then
					room:doLightbox("f_ten_xiayunAniamte", 4000)
				elseif first == "f_ten_hanli" then
					room:doLightbox("f_ten_hanliAniamte", 4000)
				elseif first == "f_ten_lisong" then
					room:doLightbox("f_ten_lisongAniamte", 4000)
				elseif first == "f_ten_duangui" then
					room:doLightbox("f_ten_duanguiAniamte", 4000)
				elseif first == "f_ten_guosheng" then
					room:doLightbox("f_ten_guoshengAniamte", 4000)
				elseif first == "f_ten_dage" then
					room:doLightbox("f_ten_dageAniamte", 4000)
				end
				room:changeHero(player, "", false, false, true, false) --清空副将
				local log = sgs.LogMessage()
				log.type = "$f_mowang_EnterZS"
				log.from = player
				room:sendLog(log)
				room:changeHero(player, "f_ten_zhuangsi", true, false, false, false) --开始装死！
				room:addPlayerMark(player, "f_ten_zhuangsi")
			end
		elseif event == sgs.TurnStart then
			if player:getGeneralName() == "f_ten_zhuangsi" and player:getMark("f_ten_zhuangsi") > 0 then
				local log = sgs.LogMessage()
				log.type = "$f_mowang_QuitZS"
				log.from = player
				room:sendLog(log)
				room:setPlayerMark(player, "f_ten_zhuangsi", 0)
			end
		end
	end,
}
f_mowangDeath = sgs.CreateTriggerSkill{
	name = "f_mowangDeath",
	global = true,
	priority = 10000,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameOverJudge},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		if death.who:objectName() ~= player:objectName() then return false end
		if isSpecialOne(player, "十长逝") then
			sgs.Sanguosha:playAudioEffect("audio/death/f_ten.ogg", false)
			room:getThread():delay(3500)
			room:doLightbox("f_ten_die", 5500)
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_ten:addSkill(f_mowang)
f_ten_zhuangsi:addSkill("f_mowang")
if not sgs.Sanguosha:getSkill("f_mowangDeath") then skills:append(f_mowangDeath) end
--☠“装死”
f_ten_zs = sgs.CreateProhibitSkill{
	name = "f_ten_zs",
	is_prohibited = function(self, from, to, card)
		return to:hasSkill(self:objectName())
	end,
}
f_ten_zsTrigger = sgs.CreateTriggerSkill{
	name = "f_ten_zsTrigger",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.MarkChanged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local mark = data:toMark()
		if mark.name == "f_ten_zhuangsi" and mark.gain > 0 and mark.who and mark.who:objectName() == player:objectName() then
			if not player:isAllNude() then
				local dummy = sgs.Sanguosha:cloneCard("slash")
				dummy:addSubcards(player:getCards("hej"))
				room:throwCard(dummy, player, nil)
				dummy:deleteLater()
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_ten_zhuangsi:addSkill(f_ten_zs)
if not sgs.Sanguosha:getSkill("f_ten_zsTrigger") then skills:append(f_ten_zsTrigger) end

--==“阴灵”牌==--
  --张让
f_ten_dadi = sgs.General(extension_f, "f_ten_dadi", "god", 1, true, true, true)
f_ten_dadi:addSkill("mobilezhimiewu")
f_ten_dadi_extreme = sgs.CreateTriggerSkill{
	name = "f_ten_dadi_extreme",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.MarkChanged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local mark = data:toMark()
		if mark.name == "&mobilezhiwuku" and mark.who and mark.who:objectName() == player:objectName()
		and player:getMark("&mobilezhiwuku") == 0 then
			room:setPlayerMark(player, "&mobilezhiwuku", 1)
		end
	end,
	can_trigger = function(self, player)
		return isSpecialOne(player, "十长逝") and isSpecialOne(player, "张让")
	end,
}
if not sgs.Sanguosha:getSkill("f_ten_dadi_extreme") then skills:append(f_ten_dadi_extreme) end

  --赵忠
f_ten_ermei = sgs.General(extension_f, "f_ten_ermei", "god", 1, true, true, true)
f_ten_ermei:addSkill("mobilepojun")

  --孙璋
f_ten_sunzhang = sgs.General(extension_f, "f_ten_sunzhang", "god", 1, true, true, true)
f_ten_sunzhang:addSkill("mobilezhiqinzheng")

  --毕岚
f_ten_bilan = sgs.General(extension_f, "f_ten_bilan", "god", 1, true, true, true)
f_ten_bilan:addSkill("oflhuishi")

  --夏恽
f_ten_xiayun = sgs.General(extension_f, "f_ten_xiayun", "god", 1, true, true, true)
f_ten_xiayun:addSkill("yizheng")
f_ten_xiayun_mhp = sgs.CreateTriggerSkill{
	name = "f_ten_xiayun_mhp",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreCardUsed, sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if not use.card or use.card:getSkillName() ~= "yizheng" then return false end
		if event == sgs.PreCardUsed then
			local mhp = player:getMaxHp()
			room:setPlayerMark(player, self:objectName(), mhp)
			room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp+1))
		elseif event == sgs.CardFinished then
			if player:getMark(self:objectName()) > 0 then
				local mhp = player:getMark(self:objectName())
				room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp))
				room:setPlayerMark(player, self:objectName(), 0)
			end
		end
	end,
	can_trigger = function(self, player)
		return isSpecialOne(player, "十长逝") and isSpecialOne(player, "夏恽")
	end,
}
if not sgs.Sanguosha:getSkill("f_ten_xiayun_mhp") then skills:append(f_ten_xiayun_mhp) end

  --韩悝
f_ten_hanli = sgs.General(extension_f, "f_ten_hanli", "god", 1, true, true, true)
--“巧思”
hl_qiaosiCard = sgs.CreateSkillCard{
	name = "hl_qiaosiCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local choices = {"1", "2", "3", "4", "5", "6"}
		local hl_qiaosi_cards = {}
		local n = 0
		while n < 3 do
			local choice = room:askForChoice(source, "ShuiZhuanBaiXiTu", table.concat(choices, "+"))
			if choice == "1" then --【王】
				local hl_qiaosi_king_count = 0
				for _, id in sgs.qlist(room:getDrawPile()) do
					if sgs.Sanguosha:getCard(id):isKindOf("TrickCard") and not table.contains(hl_qiaosi_cards, id) and hl_qiaosi_king_count < 2 then
						hl_qiaosi_king_count = hl_qiaosi_king_count + 1
						table.insert(hl_qiaosi_cards, id)
					end
				end
				table.removeOne(choices, "1")
				if table.contains(choices, "5") then --已选择【王】，将限制【士】
					table.removeOne(choices, "5")
					table.insert(choices, "5.5")
				end
			elseif choice == "2" then --【商】
				local random_business = math.random(0,3)
				local hl_qiaosi_business_count = 0
				for _, id in sgs.qlist(room:getDrawPile()) do
					if ((sgs.Sanguosha:getCard(id):isKindOf("EquipCard") and random_business <= 1)
					or (sgs.Sanguosha:getCard(id):isKindOf("Slash") and random_business == 2)
					or (sgs.Sanguosha:getCard(id):isKindOf("Analeptic") and random_business == 3))
					and not table.contains(hl_qiaosi_cards, id) and hl_qiaosi_business_count < 1 then
						hl_qiaosi_business_count = hl_qiaosi_business_count + 1
						table.insert(hl_qiaosi_cards, id)
					end
				end
				table.removeOne(choices, "2")
			elseif choice == "2.5" then --【商】（限制效果）
				local random_business = math.random(0,1)
				local hl_qiaosi_business_count = 0
				for _, id in sgs.qlist(room:getDrawPile()) do
					if ((sgs.Sanguosha:getCard(id):isKindOf("Slash") and random_business == 0)
					or (sgs.Sanguosha:getCard(id):isKindOf("Analeptic") and random_business == 1))
					and not table.contains(hl_qiaosi_cards, id) and hl_qiaosi_business_count < 1 then
						hl_qiaosi_business_count = hl_qiaosi_business_count + 1
						table.insert(hl_qiaosi_cards, id)
					end
				end
				table.removeOne(choices, "2.5")
			elseif choice == "3" then --【工】
				local random_worker = math.random(0,2)
				local hl_qiaosi_worker_count = 0
				for _, id in sgs.qlist(room:getDrawPile()) do
					if ((sgs.Sanguosha:getCard(id):isKindOf("Slash") and random_worker <= 1)
					or (sgs.Sanguosha:getCard(id):isKindOf("Analeptic") and random_worker == 2))
					and not table.contains(hl_qiaosi_cards, id) and hl_qiaosi_worker_count < 1 then
						hl_qiaosi_worker_count = hl_qiaosi_worker_count + 1
						table.insert(hl_qiaosi_cards, id)
					end
				end
				table.removeOne(choices, "3")
			elseif choice == "4" then --【农】
				local random_farmer = math.random(0,2)
				local hl_qiaosi_farmer_count = 0
				for _, id in sgs.qlist(room:getDrawPile()) do
					if ((sgs.Sanguosha:getCard(id):isKindOf("Jink") and random_farmer <= 1)
					or (sgs.Sanguosha:getCard(id):isKindOf("Peach") and random_farmer == 2))
					and not table.contains(hl_qiaosi_cards, id) and hl_qiaosi_farmer_count < 1 then
						hl_qiaosi_farmer_count = hl_qiaosi_farmer_count + 1
						table.insert(hl_qiaosi_cards, id)
					end
				end
				table.removeOne(choices, "4")
			elseif choice == "5" then --【士】
				local random_man = math.random(0,3)
				local hl_qiaosi_man_count = 0
				for _, id in sgs.qlist(room:getDrawPile()) do
					if ((sgs.Sanguosha:getCard(id):isKindOf("TrickCard") and random_man <= 1)
					or (sgs.Sanguosha:getCard(id):isKindOf("Jink") and random_man == 2)
					or (sgs.Sanguosha:getCard(id):isKindOf("Peach") and random_man == 3))
					and not table.contains(hl_qiaosi_cards, id) and hl_qiaosi_man_count < 1 then
						hl_qiaosi_man_count = hl_qiaosi_man_count + 1
						table.insert(hl_qiaosi_cards, id)
					end
				end
				table.removeOne(choices, "5")
			elseif choice == "5.5" then --【士】（限制效果）
				local random_man = math.random(0,1)
				local hl_qiaosi_man_count = 0
				for _, id in sgs.qlist(room:getDrawPile()) do
					if ((sgs.Sanguosha:getCard(id):isKindOf("Jink") and random_man == 0)
					or (sgs.Sanguosha:getCard(id):isKindOf("Peach") and random_man == 1))
					and not table.contains(hl_qiaosi_cards, id) and hl_qiaosi_man_count < 1 then
						hl_qiaosi_man_count = hl_qiaosi_man_count + 1
						table.insert(hl_qiaosi_cards, id)
					end
				end
				table.removeOne(choices, "5.5")
			elseif choice == "6" then --【将】
				local hl_qiaosi_general_count = 0
				for _, id in sgs.qlist(room:getDrawPile()) do
					if sgs.Sanguosha:getCard(id):isKindOf("EquipCard") and not table.contains(hl_qiaosi_cards, id) and hl_qiaosi_general_count < 2 then
						hl_qiaosi_general_count = hl_qiaosi_general_count + 1
						table.insert(hl_qiaosi_cards, id)
					end
				end
				table.removeOne(choices, "6")
				if table.contains(choices, "2") then --已选择【将】，将限制【商】
					table.removeOne(choices, "2")
					table.insert(choices, "2.5")
				end
			end
			n = n + 1
		end
		-----
		--马钧转一转，地主跑一半！
		if #hl_qiaosi_cards > 0 then
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, id in ipairs(hl_qiaosi_cards) do
				dummy:addSubcard(id)
			end
			room:obtainCard(source, dummy, true)
			local choice = room:askForChoice(source, "hl_qiaosi", "throw+give")
			if choice == "throw" then
				room:askForDiscard(source, "hl_qiaosi", #hl_qiaosi_cards, #hl_qiaosi_cards, false, true)
			elseif choice == "give" then
				local target = room:askForPlayerChosen(source, room:getOtherPlayers(source), "hl_qiaosi", "hl_qiaosi-invoke", false, true)
				local hl_qiaosi_give_cards = room:askForExchange(source, "hl_qiaosi", #hl_qiaosi_cards, #hl_qiaosi_cards, true, "hl_qiaosi_exchange")
				if target and hl_qiaosi_give_cards then
					room:obtainCard(target, hl_qiaosi_give_cards, false)
				end
			end
		end
	end,
}
hl_qiaosi = sgs.CreateZeroCardViewAsSkill{
	name = "hl_qiaosi",
	view_as = function()
		return hl_qiaosiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#hl_qiaosiCard")
	end,
}
f_ten_hanli:addSkill(hl_qiaosi)

  --栗嵩
f_ten_lisong = sgs.General(extension_f, "f_ten_lisong", "god", 1, true, true, true)
f_ten_lisong:addSkill("poxi")

  --段珪
f_ten_duangui = sgs.General(extension_f, "f_ten_duangui", "god", 1, true, true, true)
f_ten_duangui:addSkill("mobilemouliegong")

  --郭胜
f_ten_guosheng = sgs.General(extension_f, "f_ten_guosheng", "god", 1, true, true, true)
f_ten_guosheng:addSkill("pingcai")

  --高望
f_ten_dage = sgs.General(extension_f, "f_ten_dage", "god", 1, true, true, true)
dg_anruo = sgs.CreateViewAsSkill{
	name = "dg_anruo",
	n = 1,
	view_filter = function(self, selected, to_select)
		if (#selected >= 1) or to_select:hasFlag("using") then return false end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			if sgs.Self:isWounded() and (to_select:getSuit() == sgs.Card_Heart) then
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
		if #cards ~= 1 then return nil end
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
			new_card:setSkillName(self:objectName())
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
		return (pattern == "slash") or (pattern == "jink")
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
dg_anruoBuffs = sgs.CreateTriggerSkill{
	name = "dg_anruoBuffs",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed, sgs.CardResponded, sgs.NullificationEffect},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.from and use.from:objectName() == player:objectName() and use.card then
				if player:hasSkill("dg_anruo") and use.card:getSkillName() == "dg_anruo" then
					if use.card:isKindOf("Slash") then
						for _, p in sgs.qlist(use.to) do
							if p:isNude() then continue end
							local _data = sgs.QVariant()
							_data:setValue(p)
							p:setFlags("dg_anruoTarget")
							local invoke = room:askForSkillInvoke(player, "dg_anruo", _data)
							p:setFlags("-dg_anruoTarget")
							if invoke then
								room:broadcastSkillInvoke("dg_anruo")
								local card_id = room:askForCardChosen(player, p, "he", "dg_anruo")
								local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
								room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, false)
							end
						end
					elseif use.card:isKindOf("Peach") then
						if room:askForSkillInvoke(player, "dg_anruo", data) then
							local victim = room:askForPlayerChosen(player, room:getAllPlayers(), "dg_anruo")
							if not victim:isNude() then
								room:broadcastSkillInvoke("dg_anruo")
								local card_id = room:askForCardChosen(player, victim, "he", "dg_anruo")
								local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
								room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, false)
							end
						end
					elseif use.card:isKindOf("Nullification") then
						if room:askForSkillInvoke(player, "dg_anruo", data) then
							for _, p in sgs.qlist(room:getAllPlayers()) do
								if p:hasFlag("dg_anruo_NDTsource") then
									room:setPlayerFlag(p, "-dg_anruo_NDTsource")
									if not p:isNude() then
										room:broadcastSkillInvoke("dg_anruo")
										local card_id = room:askForCardChosen(player, p, "he", "dg_anruo")
										local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
										room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, false)
									end
									break
								end
							end
						end
						room:setPlayerFlag(player, "dg_anruo_NDTsource")
					end
				end
				if use.card:isNDTrick() and use.card:getSkillName() ~= "dg_anruo" then --过滤掉通过“安弱”转化的无懈，防撞车
					for _, p in sgs.qlist(room:getAllPlayers()) do --避免出现重复标记
						if p:hasFlag("dg_anruo_NDTsource") then
							room:setPlayerFlag(p, "-dg_anruo_NDTsource")
						end
					end
					room:setPlayerFlag(player, "dg_anruo_NDTsource")
				end
			end
		elseif event == sgs.CardResponded then
			local resp = data:toCardResponse()
			if resp.m_card:isKindOf("Jink") and resp.m_who then
				if resp.m_card:getSkillName() == "dg_anruo" and not resp.m_who:isNude() then
					local _data = sgs.QVariant()
					_data:setValue(resp.m_who)
					if room:askForSkillInvoke(player, "dg_anruo", _data) then
						room:broadcastSkillInvoke("dg_anruo")
						local card_id = room:askForCardChosen(player, resp.m_who, "he", "dg_anruo")
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
						room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, false)
		        	end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
f_ten_dage:addSkill(dg_anruo)
if not sgs.Sanguosha:getSkill("dg_anruoBuffs") then skills:append(dg_anruoBuffs) end
----------
f_ten_dadi:addSkill("f_danggu")
f_ten_ermei:addSkill("f_danggu")
f_ten_sunzhang:addSkill("f_danggu")
f_ten_bilan:addSkill("f_danggu")
f_ten_xiayun:addSkill("f_danggu")
f_ten_hanli:addSkill("f_danggu")
f_ten_lisong:addSkill("f_danggu")
f_ten_duangui:addSkill("f_danggu")
f_ten_guosheng:addSkill("f_danggu")
f_ten_dage:addSkill("f_danggu")
--
f_ten_dadi:addSkill("f_mowang")
f_ten_ermei:addSkill("f_mowang")
f_ten_sunzhang:addSkill("f_mowang")
f_ten_bilan:addSkill("f_mowang")
f_ten_xiayun:addSkill("f_mowang")
f_ten_hanli:addSkill("f_mowang")
f_ten_lisong:addSkill("f_mowang")
f_ten_duangui:addSkill("f_mowang")
f_ten_guosheng:addSkill("f_mowang")
f_ten_dage:addSkill("f_mowang")
--======--

--神袁绍
f_shenyuanshao = sgs.General(extension_f, "f_shenyuanshao", "god", 4, true)

f_mingwang = sgs.CreateTriggerSkill{
	name = "f_mingwang",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.DrawNCards, sgs.EventPhaseEnd, sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				local choices = {}
				table.insert(choices, "1")
				if player:getCards("he"):length() >= 2 and player:canDiscard(player, "he") then
					table.insert(choices, "2")
				end
				local choice = room:askForChoice(p, self:objectName(), table.concat(choices, "+"))
				if choice == "1" then
					room:drawCards(p, 2, self:objectName())
					room:broadcastSkillInvoke(self:objectName(), 1)
					p:gainMark("&f_ysS", 1)
				elseif choice == "2" then
					room:askForDiscard(p, self:objectName(), 2, 2, false, true)
				end
			end
		elseif event == sgs.DrawNCards then
			local count = 1
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("&f_ysS") > 0 then
					count = count + 1
				end
			end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName(), 2)
			data:setValue(count)
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Discard and player:getHandcardNum() > player:getHp() then
				room:broadcastSkillInvoke(self:objectName(), 2)
			end
		elseif event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			if damage.from and damage.from:objectName() == player:objectName()
			and damage.to and damage.to:getMark("&f_ysS") == 0 then
				local log = sgs.LogMessage()
				log.type = "$f_mingwangMD"
				log.from = player
				log.to:append(damage.to)
				room:sendLog(log)
				room:broadcastSkillInvoke(self:objectName(), math.random(3,4))
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		end
	end,
}
f_mingwangMaxCards = sgs.CreateMaxCardsSkill{
	name = "f_mingwangMaxCards",
	extra_func = function(self, player)
		local n = 0
		if player:getMark("&f_ysS") > 0 then n = n + 1 end
		for _, p in sgs.qlist(player:getAliveSiblings()) do
			if p:getMark("&f_ysS") > 0 then
				n = n + 1
			end
		end
		return n
	end,
}
f_shenyuanshao:addSkill(f_mingwang)
if not sgs.Sanguosha:getSkill("f_mingwangMaxCards") then skills:append(f_mingwangMaxCards) end

f_guamou = sgs.CreateTriggerSkill{
    name = "f_guamou",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreCardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if (not use.card:isKindOf("BasicCard") and not use.card:isNDTrick()) or use.from:objectName() ~= player:objectName() then return false end
		local can_invoke = false
		for _, p in sgs.qlist(use.to) do
			if p:getMark("&f_ysS") == 0 then
				can_invoke = true
			end
		end
		if not can_invoke then return false end
		local extra_targets = room:getCardTargets(player, use.card, use.to)
		if extra_targets:isEmpty() then return false end
		local adds = sgs.SPlayerList()
		for _, p in sgs.qlist(extra_targets) do
			if p:getMark("&f_ysS") > 0 then
				if not use.to:contains(p) then
					use.to:append(p)
				end
				adds:append(p)
			end
		end
		if adds:isEmpty() then return false end
		room:sortByActionOrder(adds)
		room:sortByActionOrder(use.to)
		data:setValue(use)
		local log = sgs.LogMessage()
		log.type = "#QiaoshuiAdd"
		log.from = player
		log.to = adds
		log.card_str = use.card:toString()
		log.arg = self:objectName()
		room:sendLog(log)
		for _, p in sgs.qlist(adds) do
			room:doAnimate(1, player:objectName(), p:objectName())
		end
		room:notifySkillInvoked(player, self:objectName())
		room:broadcastSkillInvoke(self:objectName())
	end,
}
f_shenyuanshao:addSkill(f_guamou)

f_feishi = sgs.CreateTriggerSkill{
    name = "f_feishi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage, sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damage then
			local damage = data:toDamage()
			if damage.from and damage.from:objectName() == player:objectName()
			and damage.to and damage.to:isAlive() and damage.to:getMark("&f_ysS") > 0 then
				if room:askForSkillInvoke(damage.to, self:objectName(), FCToData("f_feishi-leave:"..player:objectName())) then
					local g = 2
					while not player:isNude() and g > 0 do
						local card = room:askForCardChosen(damage.to, player, "he", self:objectName())
						room:obtainCard(damage.to, card, false)
						g = g - 1
					end
					room:broadcastSkillInvoke(self:objectName())
					damage.to:loseAllMarks("&f_ysS")
				end
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who and death.who:objectName() ~= player:objectName()
			and death.who:getMark("&f_ysS") > 0 and player:hasSkill(self:objectName()) then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				room:loseHp(player, 1)
			end
		end
	end,
}
f_shenyuanshao:addSkill(f_feishi)







--

--==天才包专属神武将==--
--[[extension_tc = sgs.Package("GeniusPackageGod", sgs.Package_GeneralPack)

--神祝融
tc_shenzhurong = sgs.General(extension_tc, "tc_shenzhurong", "god", 4, false)

tc_juxiang_stsh = sgs.CreateTriggerSkill{
    name = "tc_juxiang_stsh",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.BeforeCardsMove, sgs.CardUsed, sgs.CardEffected, sgs.GameStart, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:isKindOf("SavageAssault") then
				if use.card:isVirtualCard() and (use.card:subcardsLength() ~= 1) or not player:hasSkill(self:objectName()) then return false end
				if sgs.Sanguosha:getEngineCard(use.card:getEffectiveId()) and sgs.Sanguosha:getEngineCard(use.card:getEffectiveId()):isKindOf("SavageAssault")
				and use.from and use.from:objectName() ~= player:objectName() then
					room:setCardFlag(use.card:getEffectiveId(), "real_SA")
				end
				if use.from:objectName() == player:objectName() and player:hasSkill(self:objectName()) then
				    room:setPlayerFlag(player, self:objectName())
				end
			end
		elseif event == sgs.EventPhaseChanging then
		    local change = data:toPhaseChange()
			if change.to ~= sgs.Player_Finish or player:hasFlag(self:objectName()) then return false end
			if not player:hasSkill(self:objectName()) then return false end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			local slash = sgs.Sanguosha:cloneCard("savage_assault", sgs.Card_SuitToBeDecided, -1)
		    slash:setSkillName("_"..self:objectName())
			room:useCard(sgs.CardUseStruct(slash, player, room:getOtherPlayers(player)), false)
		elseif event == sgs.BeforeCardsMove then
		    if player and player:isAlive() and player:hasSkill(self:objectName()) then
			    local move = data:toMoveOneTime()
				local card = sgs.Sanguosha:getCard(move.card_ids:first())
			    if card:hasFlag("real_SA") then
				    room:sendCompulsoryTriggerLog(player, self:objectName())
				    room:broadcastSkillInvoke(self:objectName())
					player:obtainCard(card)
					move.card_ids = sgs.IntList()
					data:setValue(move)
				end
			end
		elseif event == sgs.CardEffected then
		    local effect = data:toCardEffect()
		    if effect.card:isKindOf("SavageAssault") and effect.to:hasSkill(self:objectName()) then
				    room:sendCompulsoryTriggerLog(effect.to, self:objectName())
				    room:broadcastSkillInvoke(self:objectName())
			    return true
		    else
			    return false
		    end
		end
	end,
	can_trigger = function(self, target)
		return target
	end,
}
tc_liefeng_spwd = sgs.CreateTriggerSkill{
    name = "tc_liefeng_spwd",
	global = true,
	events = {sgs.CardUsed, sgs.CardFinished, sgs.Pindian},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.CardUsed then
		    local use = data:toCardUse()
		    local lieren = true
		    for _, p in sgs.qlist(use.to) do
			    if p:isKongcheng() or p:objectName() == player:objectName() then lieren = false end
			end
			if lieren and use.card:isKindOf("Slash") and use.from:objectName() == player:objectName()
			and player:hasSkill(self:objectName()) and not player:isKongcheng() and room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName())
				local success
				local card_id = room:askForExchange(player, self:objectName(), 1, 1, false, "@tc_liefeng_spwd-invoke", false)
				for _, p in sgs.qlist(use.to) do
			    	success = player:pindian(p, self:objectName(), card_id)
				end
				if success then room:setCardFlag(use.card, "lieren") end
			end
		elseif event == sgs.Pindian then
			local pindian = data:toPindian()
			if pindian.reason ~= self:objectName() then return false end
			local winner
			local loser
			if pindian.from_number >= pindian.to_number then
				winner = pindian.from
				loser = pindian.to
			end
			if loser then
				room:setPlayerFlag(loser, "lieren")
			end
		else
		    local use = data:toCardUse()
			if not use.card:hasFlag("lieren") or not player:hasSkill(self:objectName()) then return false end
			local players, targets = room:getOtherPlayers(player), sgs.SPlayerList()
			for _, p in sgs.qlist(players) do
			    if p:hasFlag("lieren") then
				    players:removeOne(p)
					room:setPlayerFlag(p, "-lieren")
				    targets:append(p)
				end
			end
			if not players:isEmpty() then
			    local to = room:askForPlayerChosen(player, players, self:objectName(), "~shuangren", false, true)
				room:broadcastSkillInvoke(self:objectName())
				local dama, n = nil, math.random(1, 4)
				if n == 1 then dama = sgs.DamageStruct_Normal end
				if n == 2 then dama = sgs.DamageStruct_Ice end
				if n == 3 then dama = sgs.DamageStruct_Thunder end
				if n == 4 then dama = sgs.DamageStruct_Fire end
				room:damage(sgs.DamageStruct(self:objectName(), player, to, math.random(1, 3), dama))
				if not targets:isEmpty() then
				    for _, pe in sgs.qlist(targets) do
			            room:loseHp(pe)
					end
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target:hasSkill(self:objectName())--getGeneralName() == "tc_shenzhurong" or target:getGeneral2Name() == "tc_shenzhurong"
	end,
}
tc_changbiao_sqrhCard = sgs.CreateSkillCard{
	name = "tc_changbiao_sqrh",
	filter = function(self, targets, to_select)
		return to_select:objectName() ~= sgs.Self:objectName()
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		room:addPlayerMark(source, "&".."tc_changbiao_sqrh".."-Clear", self:getSubcards():length())
		if #targets > 0 then
			for _,p in pairs(targets) do
				room:cardEffect(self, source, p)
			end
		end
	end,
	on_effect = function(self, effect) 
		local room = effect.from:getRoom()
		if effect.to then
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, 0)
		    slash:addSubcards(self:getSubcards())
		    slash:setSkillName("tc_changbiao_sqrh")
			room:useCard(sgs.CardUseStruct(slash, effect.from, effect.to, false))
		end
	end,
}
tc_changbiao_sqrhvs = sgs.CreateViewAsSkill{
	name = "tc_changbiao_sqrh",
	n = 999,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local skillcard = tc_changbiao_sqrhCard:clone()
		for _, c in ipairs(cards) do
			skillcard:addSubcard(c)
		end
		return skillcard
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#tc_changbiao_sqrh") and not player:isKongcheng()
	end,
}
tc_changbiao_sqrh = sgs.CreateTriggerSkill{
    name = "tc_changbiao_sqrh",
	events = {sgs.Damage, sgs.CardFinished},
    view_as_skill = tc_changbiao_sqrhvs,
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if event == sgs.Damage then
		    local damage = data:toDamage()
		    if damage.card:getSkillName() == "tc_changbiao_sqrh" then
				room:setCardFlag(damage.card, "olchangbiao")
			end
		else
		    local use = data:toCardUse()
			if not use.card:hasFlag("olchangbiao") or player:getMark("&".."tc_changbiao_sqrh".."-Clear") == 0 then return false end
			room:sendCompulsoryTriggerLog(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			player:drawCards(player:getMark("&".."tc_changbiao_sqrh".."-Clear"))
		end
	end,
}
tc_shenzhurong:addSkill(tc_juxiang_stsh)
tc_shenzhurong:addSkill(tc_liefeng_spwd)
tc_shenzhurong:addSkill(tc_changbiao_sqrh)]]





--

--更换武将皮肤--
mobileGOD_SkinChange = sgs.CreateTriggerSkill{
    name = "mobileGOD_SkinChange",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.AfterDrawInitialCards},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		--(界)神郭嘉(手杀)
		if player:getGeneralName() == "f_shenguojia" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "sgj_hnqm+sjjoy+sgj_wxmy+sgj_zcjj+sgj_yxzy_first")
			if choice == "sgj_hnqm" then
				room:changeHero(player, "f_shenguojia_c", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sjjoy" then
				room:changeHero(player, "f_shenguojia_joy", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sgj_wxmy" then
				room:changeHero(player, "f_shenguojia_nv1", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sgj_zcjj" then
				room:changeHero(player, "f_shenguojia_nv2", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sgj_yxzy_first" then
				room:changeHero(player, "f_shenguojia_d1", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		if player:getGeneral2Name() == "f_shenguojia" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "sgj_hnqm+sjjoy+sgj_wxmy+sgj_zcjj+sgj_yxzy_first")
			if choice == "sgj_hnqm" then
				room:changeHero(player, "f_shenguojia_c", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sjjoy" then
				room:changeHero(player, "f_shenguojia_joy", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sgj_wxmy" then
				room:changeHero(player, "f_shenguojia_nv1", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sgj_zcjj" then
				room:changeHero(player, "f_shenguojia_nv2", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sgj_yxzy_first" then
				room:changeHero(player, "f_shenguojia_d1", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		--(界)神荀彧(手杀)
		if player:getGeneralName() == "f_shenxunyu" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "sxy_hnqm+sjjoy+sxy_yjtw+sxy_xhry")
			if choice == "sxy_hnqm" then
				room:changeHero(player, "f_shenxunyu_c", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sjjoy" then
				room:changeHero(player, "f_shenxunyu_joy", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sxy_yjtw" then
				room:changeHero(player, "f_shenxunyu_x", false, true, false, false)
				room:broadcastSkillInvoke(self:objectName())
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sxy_xhry" then
				room:changeHero(player, "f_shenxunyu_nv", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		if player:getGeneral2Name() == "f_shenxunyu" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "sxy_hnqm+sjjoy+sxy_yjtw+sxy_xhry")
			if choice == "sxy_hnqm" then
				room:changeHero(player, "f_shenxunyu_c", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sjjoy" then
				room:changeHero(player, "f_shenxunyu_joy", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sxy_yjtw" then
				room:changeHero(player, "f_shenxunyu_x", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sxy_xhry" then
				room:changeHero(player, "f_shenxunyu_nv", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		--(界)神孙策(手杀)
		if player:getGeneralName() == "f_shensunce" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "ssc_yjtw+sjjoy+ssc_bwzs")
			if choice == "ssc_yjtw" then
				room:changeHero(player, "f_shensunce_x", false, true, false, false)
				room:broadcastSkillInvoke(self:objectName())
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sjjoy" then
				room:changeHero(player, "f_shensunce_joy", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "ssc_bwzs" then
				room:changeHero(player, "f_shensunce_c", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		if player:getGeneral2Name() == "f_shensunce" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "ssc_yjtw+sjjoy+ssc_bwzs")
			if choice == "ssc_yjtw" then
				room:changeHero(player, "f_shensunce_x", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sjjoy" then
				room:changeHero(player, "f_shensunce_joy", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "ssc_bwzs" then
				room:changeHero(player, "f_shensunce_c", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		--神太史慈-第二版(手杀)
		if player:getGeneralName() == "f_shentaishicii" and room:askForSkillInvoke(player, self:objectName(), data) then
			--local choice = room:askForChoice(player, self:objectName(), "stsc_yhry+?")
			--if choice == "stsc_yhry" then
				room:changeHero(player, "f_shentaishicii_c", false, false, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--else
				--room:changeHero(player, "", false, false, false, false)
				--if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--end
		end
		if player:getGeneral2Name() == "f_shentaishicii" and room:askForSkillInvoke(player, self:objectName(), data) then
			--local choice = room:askForChoice(player, self:objectName(), "stsc_yhry+?")
			--if choice == "stsc_yhry" then
				room:changeHero(player, "f_shentaishicii_c", false, false, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--else
				--room:changeHero(player, "", false, false, true, false)
				--if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--end
		end
		--神姜维-怒麟燎原
		if (player:getGeneralName() == "ty_shenjiangweiBN" or player:getGeneralName() == "ty_shenjiangweiBN_ub") and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "ty_shenjiangweiBN_1", false, false, false, false)
			if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
		end
		if (player:getGeneral2Name() == "ty_shenjiangweiBN" or player:getGeneral2Name() == "ty_shenjiangweiBN_ub") and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "ty_shenjiangweiBN_1", false, false, true, false)
			if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
		end
		--(界)神姜维(新杀)
		if player:getGeneralName() == "ty_shenjiangwei" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "sjjoy+sjw_ymlt+sjw_cjfb")
			if choice == "sjjoy" then
				room:changeHero(player, "ty_shenjiangwei_joy", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sjw_ymlt" then
				room:changeHero(player, "ty_shenjiangwei_3gods", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sjw_cjfb" then
				room:changeHero(player, "ty_shenjiangwei_1", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		if player:getGeneral2Name() == "ty_shenjiangwei" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "sjjoy+sjw_ymlt+sjw_cjfb")
			if choice == "sjjoy" then
				room:changeHero(player, "ty_shenjiangwei_joy", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sjw_ymlt" then
				room:changeHero(player, "ty_shenjiangwei_3gods", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sjw_cjfb" then
				room:changeHero(player, "ty_shenjiangwei_1", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		--神马超(新杀)
		if player:getGeneralName() == "ty_shenmachao" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "smc_xwjl+smc_xwjldt+smc_xyxc+smc_lwfc+smc_ymlt")
			if choice == "smc_xwjl" then
				room:changeHero(player, "ty_shenmachao_1", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "smc_xwjldt" then
				room:changeHero(player, "ty_shenmachao_1dt", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "smc_xyxc" then
				room:changeHero(player, "ty_shenmachao_t", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "smc_lwfc" then
				room:changeHero(player, "ty_shenmachao_sp", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "smc_ymlt" then
				room:changeHero(player, "ty_shenmachao_3gods", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		if player:getGeneral2Name() == "ty_shenmachao" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "smc_xwjl+smc_xwjldt+smc_xyxc+smc_lwfc+smc_ymlt")
			if choice == "smc_xwjl" then
				room:changeHero(player, "ty_shenmachao_1", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "smc_xwjldt" then
				room:changeHero(player, "ty_shenmachao_1dt", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "smc_xyxc" then
				room:changeHero(player, "ty_shenmachao_t", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "smc_lwfc" then
				room:changeHero(player, "ty_shenmachao_sp", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "smc_ymlt" then
				room:changeHero(player, "ty_shenmachao_3gods", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		--神张飞(新杀)
		if player:getGeneralName() == "ty_shenzhangfei" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "szf_ansh+sjjoy+szf_ymlt+szf_tbzh")
			if choice == "szf_ansh" then
				room:changeHero(player, "ty_shenzhangfei_1", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sjjoy" then
				room:changeHero(player, "ty_shenzhangfei_joy", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "szf_ymlt" then
				room:changeHero(player, "ty_shenzhangfei_3gods", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "szf_tbzh" then
				room:changeHero(player, "ty_shenzhangfei_2", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		if player:getGeneral2Name() == "ty_shenzhangfei" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "szf_ansh+sjjoy+szf_ymlt+szf_tbzh")
			if choice == "szf_ansh" then
				room:changeHero(player, "ty_shenzhangfei_1", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "sjjoy" then
				room:changeHero(player, "ty_shenzhangfei_joy", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "szf_ymlt" then
				room:changeHero(player, "ty_shenzhangfei_3gods", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			elseif choice == "szf_tbzh" then
				room:changeHero(player, "ty_shenzhangfei_2", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		--神张角(新杀)
		if player:getGeneralName() == "ty_shenzhangjiao" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "szj_ydzz+sjjoy")
			if choice == "szj_ydzz" then
				room:changeHero(player, "ty_shenzhangjiao_1", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			else
				room:changeHero(player, "ty_shenzhangjiao_joy", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		if player:getGeneral2Name() == "ty_shenzhangjiao" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "szj_ydzz+sjjoy")
			if choice == "szj_ydzz" then
				room:changeHero(player, "ty_shenzhangjiao_1", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			else
				room:changeHero(player, "ty_shenzhangjiao_joy", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		--神邓艾(新杀)
		if player:getGeneralName() == "ty_shendengai" and room:askForSkillInvoke(player, self:objectName(), data) then
			--local choice = room:askForChoice(player, self:objectName(), "sdi_eczz+?")
			--if choice == "sdi_eczz" then
				room:changeHero(player, "ty_shendengai_1", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--else
				--room:changeHero(player, "", false, true, false, false)
				--if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--end
		end
		if player:getGeneral2Name() == "ty_shendengai" and room:askForSkillInvoke(player, self:objectName(), data) then
			--local choice = room:askForChoice(player, self:objectName(), "sdi_eczz+?")
			--if choice == "sdi_eczz" then
				room:changeHero(player, "ty_shendengai_1", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--else
				--room:changeHero(player, "", false, true, true, false)
				--if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--end
		end
		--(界)神张角(OL)
		if player:getGeneralName() == "ol_shenzhangjiao" and room:askForSkillInvoke(player, self:objectName(), data) then
			--local choice = room:askForChoice(player, self:objectName(), "szj_ydzz+?")
			--if choice == "szj_ydzz" then
				room:changeHero(player, "ol_shenzhangjiao_1", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--else
				--room:changeHero(player, "", false, true, false, false)
				--if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--end
		end
		if player:getGeneral2Name() == "ol_shenzhangjiao" and room:askForSkillInvoke(player, self:objectName(), data) then
			--local choice = room:askForChoice(player, self:objectName(), "szj_ydzz+?")
			--if choice == "szj_ydzz" then
				room:changeHero(player, "ol_shenzhangjiao_1", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--else
				--room:changeHero(player, "", false, true, true, false)
				--if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--end
		end
		--神甄姬(OL)
		if player:getGeneralName() == "ol_shenzhenji" and room:askForSkillInvoke(player, self:objectName(), data) then
			--local choice = room:askForChoice(player, self:objectName(), "sjjoy+?")
			--if choice == "sjjoy" then
				room:changeHero(player, "ol_shenzhenji_joy", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--else
				--room:changeHero(player, "", false, true, false, false)
				--if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--end
		end
		if player:getGeneral2Name() == "ol_shenzhenji" and room:askForSkillInvoke(player, self:objectName(), data) then
			--local choice = room:askForChoice(player, self:objectName(), "sjjoy+?")
			--if choice == "sjjoy" then
				room:changeHero(player, "ol_shenzhenji_joy", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--else
				--room:changeHero(player, "", false, true, true, false)
				--if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--end
		end
		--神孙权(OL)
		if player:getGeneralName() == "ol_shensunquan" and room:askForSkillInvoke(player, self:objectName(), data) then
			--local choice = room:askForChoice(player, self:objectName(), "ssq_thry+?")
			--if choice == "ssq_thry" then
				room:changeHero(player, "ol_shensunquan_1", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--else
				--room:changeHero(player, "", false, true, false, false)
				--if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--end
		end
		if player:getGeneral2Name() == "ol_shensunquan" and room:askForSkillInvoke(player, self:objectName(), data) then
			--local choice = room:askForChoice(player, self:objectName(), "ssq_thry+?")
			--if choice == "ssq_thry" then
				room:changeHero(player, "ol_shensunquan_1", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--else
				--room:changeHero(player, "", false, true, true, false)
				--if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			--end
		end
		----
		--神孙尚香(diy)
		if player:getGeneralName() == "f_shensunshangxiang" and player:getKingdom() == "shu" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "f_shensunshangxiang_shu", false, true, false, false)
		end
		if player:getGeneral2Name() == "f_shensunshangxiang" and player:getKingdom() == "shu" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "f_shensunshangxiang_shu", false, true, true, false)
		end
		--神祝融(天才包)
		--[[if player:getGeneralName() == "tc_shenzhurong" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "tc_shenzhurong_1", false, true, false, false)
			if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
		end
		if player:getGeneral2Name() == "tc_shenzhurong" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "tc_shenzhurong_1", false, true, true, false)
			if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
		end]]
		----
		if player:getGeneralName() == "f_shenguojia" or player:getGeneralName() == "f_shenxunyu" or player:getGeneralName() == "f_shensunce" or player:getGeneralName() == "f_shentaishicii"
		or player:getGeneralName() == "ty_shenjiangweiBN" or player:getGeneralName() == "ty_shenjiangweiBN_ub" or player:getGeneralName() == "ty_shenjiangwei" or player:getGeneralName() == "ty_shenmachao"
		or player:getGeneralName() == "ty_shenzhangfei" or player:getGeneralName() == "ty_shenzhangjiao" or player:getGeneralName() == "ty_shendengai"
		or player:getGeneralName() == "ol_shenzhenji" or player:getGeneralName() == "ol_shenzhangjiao" or player:getGeneralName() == "ol_shensunquan"
		or player:getGeneralName() == "tc_shenzhurong"
		--
		or player:getGeneral2Name() == "f_shenguojia" or player:getGeneral2Name() == "f_shenxunyu" or player:getGeneral2Name() == "f_shensunce" or player:getGeneral2Name() == "f_shentaishicii"
		or player:getGeneral2Name() == "ty_shenjiangweiBN" or player:getGeneral2Name() == "ty_shenjiangweiBN_ub" or player:getGeneral2Name() == "ty_shenjiangwei" or player:getGeneral2Name() == "ty_shenmachao"
		or player:getGeneral2Name() == "ty_shenzhangfei" or player:getGeneral2Name() == "ty_shenzhangjiao" or player:getGeneral2Name() == "ty_shendengai"
		or player:getGeneral2Name() == "ol_shenzhenji" or player:getGeneral2Name() == "ol_shenzhangjiao" or player:getGeneral2Name() == "ol_shensunquan"
		or player:getGeneralName() == "tc_shenzhurong"
		then
			if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
if not sgs.Sanguosha:getSkill("mobileGOD_SkinChange") then skills:append(mobileGOD_SkinChange) end
--皮肤池--
f_shenguojia_c = sgs.General(extension, "f_shenguojia_c", "god", 3, true, true, true)
f_shenguojia_c:addSkill("f_huishi")
f_shenguojia_c:addSkill("f_tianyi")
f_shenguojia_c:addSkill("f_huishii")
f_shenguojia_joy = sgs.General(extension, "f_shenguojia_joy", "god", 3, true, true, true)
f_shenguojia_joy:addSkill("f_huishi")
f_shenguojia_joy:addSkill("f_tianyi")
f_shenguojia_joy:addSkill("f_huishii")
f_shenguojia_nv1 = sgs.General(extension, "f_shenguojia_nv1", "god", 3, false, true, true)
f_shenguojia_nv1:addSkill("f_huishi")
f_shenguojia_nv1:addSkill("f_tianyi")
f_shenguojia_nv1:addSkill("f_huishii")
f_shenguojia_nv2 = sgs.General(extension, "f_shenguojia_nv2", "god", 3, false, true, true)
f_shenguojia_nv2:addSkill("f_huishi")
f_shenguojia_nv2:addSkill("f_tianyi")
f_shenguojia_nv2:addSkill("f_huishii")
f_shenguojia_d1 = sgs.General(extension, "f_shenguojia_d1", "god", 3, true, true, true)
f_shenguojia_d1:addSkill("f_huishi")
f_shenguojia_d1:addSkill("f_tianyi")
f_shenguojia_d1:addSkill("f_huishii")
f_shenguojia_d2 = sgs.General(extension, "f_shenguojia_d2", "god", 3, true, true, true)
f_shenguojia_d2:addSkill("f_huishi")
f_shenguojia_d2:addSkill("f_tianyi")
f_shenguojia_d2:addSkill("f_huishii")

f_shenxunyu_c = sgs.General(extension, "f_shenxunyu_c", "god", 3, true, true, true)
f_shenxunyu_c:addSkill("f_tianzuo")
f_shenxunyu_c:addSkill("f_lingce")
f_shenxunyu_c:addSkill("f_dinghan")
f_shenxunyu_joy = sgs.General(extension, "f_shenxunyu_joy", "god", 3, true, true, true)
f_shenxunyu_joy:addSkill("f_tianzuo")
f_shenxunyu_joy:addSkill("f_lingce")
f_shenxunyu_joy:addSkill("f_dinghan")
f_shenxunyu_x = sgs.General(extension, "f_shenxunyu_x", "god", 3, true, true, true)
f_shenxunyu_x:addSkill("f_tianzuo")
f_shenxunyu_x:addSkill("f_lingce")
f_shenxunyu_x:addSkill("f_dinghan")
f_shenxunyu_nv = sgs.General(extension, "f_shenxunyu_nv", "god", 3, false, true, true)
f_shenxunyu_nv:addSkill("f_tianzuo")
f_shenxunyu_nv:addSkill("f_lingce")
f_shenxunyu_nv:addSkill("f_dinghan")

f_shensunce_x = sgs.General(extension, "f_shensunce_x", "god", 6, true, true, true, 1)
f_shensunce_x:addSkill("imba")
f_shensunce_x:addSkill("f_fuhai")
f_shensunce_x:addSkill("f_pinghe")
f_shensunce_joy = sgs.General(extension, "f_shensunce_joy", "god", 6, true, true, true, 1)
f_shensunce_joy:addSkill("imba")
f_shensunce_joy:addSkill("f_fuhai")
f_shensunce_joy:addSkill("f_pinghe")
f_shensunce_c = sgs.General(extension, "f_shensunce_c", "god", 6, true, true, true, 1)
f_shensunce_c:addSkill("imba")
f_shensunce_c:addSkill("f_fuhai")
f_shensunce_c:addSkill("f_pinghe")

f_shentaishicii_c = sgs.General(extension, "f_shentaishicii_c", "god", 4, true, true, true)
f_shentaishicii_c:addSkill("f_duliee")
f_shentaishicii_c:addSkill("f_poweii")

ty_shenjiangweiBN_1 = sgs.General(extension_t, "ty_shenjiangweiBN_1", "god", 4, true, true, true)
ty_shenjiangweiBN_1:addSkill("tyjiufaBN")
ty_shenjiangweiBN_1:addSkill("tytianrenBN")
ty_shenjiangweiBN_1:addSkill("typingxiangBN")

ty_shenjiangwei_joy = sgs.General(extension_t, "ty_shenjiangwei_joy", "god", 4, true, true, true)
ty_shenjiangwei_joy:addSkill("tyjiufa")
ty_shenjiangwei_joy:addSkill("tytianren")
ty_shenjiangwei_joy:addSkill("typingxiang")
ty_shenjiangwei_3gods = sgs.General(extension_t, "ty_shenjiangwei_3gods", "god", 4, true, true, true)
ty_shenjiangwei_3gods:addSkill("tyjiufa")
ty_shenjiangwei_3gods:addSkill("tytianren")
ty_shenjiangwei_3gods:addSkill("typingxiang")
ty_shenjiangwei_1 = sgs.General(extension_t, "ty_shenjiangwei_1", "god", 4, true, true, true)
ty_shenjiangwei_1:addSkill("tyjiufa")
ty_shenjiangwei_1:addSkill("tytianren")
ty_shenjiangwei_1:addSkill("typingxiang")

ty_shenmachao_1 = sgs.General(extension_t, "ty_shenmachao_1", "god", 4, true, true, true)
ty_shenmachao_1:addSkill("tyshouli")
ty_shenmachao_1:addSkill("tyhengwu")
ty_shenmachao_1dt = sgs.General(extension_t, "ty_shenmachao_1dt", "god", 4, true, true, true)
ty_shenmachao_1dt:addSkill("tyshouli")
ty_shenmachao_1dt:addSkill("tyhengwu")
ty_shenmachao_t = sgs.General(extension_t, "ty_shenmachao_t", "god", 4, true, true, true)
ty_shenmachao_t:addSkill("tyshouli")
ty_shenmachao_t:addSkill("tyhengwu")
ty_shenmachao_sp = sgs.General(extension_t, "ty_shenmachao_sp", "god", 4, true, true, true)
ty_shenmachao_sp:addSkill("tyshouli")
ty_shenmachao_sp:addSkill("tyhengwu")
ty_shenmachao_3gods = sgs.General(extension_t, "ty_shenmachao_3gods", "god", 4, true, true, true)
ty_shenmachao_3gods:addSkill("tyshouli")
ty_shenmachao_3gods:addSkill("tyhengwu")

ty_shenzhangfei_1 = sgs.General(extension_t, "ty_shenzhangfei_1", "god", 4, true, true, true)
ty_shenzhangfei_1:addSkill("tyshencai")
ty_shenzhangfei_1:addSkill("tyxunshi")
ty_shenzhangfei_joy = sgs.General(extension_t, "ty_shenzhangfei_joy", "god", 4, true, true, true)
ty_shenzhangfei_joy:addSkill("tyshencai")
ty_shenzhangfei_joy:addSkill("tyxunshi")
ty_shenzhangfei_3gods = sgs.General(extension_t, "ty_shenzhangfei_3gods", "god", 4, true, true, true)
ty_shenzhangfei_3gods:addSkill("tyshencai")
ty_shenzhangfei_3gods:addSkill("tyxunshi")
ty_shenzhangfei_2 = sgs.General(extension_t, "ty_shenzhangfei_2", "god", 4, true, true, true)
ty_shenzhangfei_2:addSkill("tyshencai")
ty_shenzhangfei_2:addSkill("tyxunshi")

ty_shenzhangjiao_1 = sgs.General(extension_t, "ty_shenzhangjiao_1", "god", 3, true, true, true)
ty_shenzhangjiao_1:addSkill("tyyizhao")
ty_shenzhangjiao_1:addSkill("tysanshou")
ty_shenzhangjiao_1:addSkill("tysijun")
ty_shenzhangjiao_1:addSkill("tytianjie")
ty_shenzhangjiao_joy = sgs.General(extension_t, "ty_shenzhangjiao_joy", "god", 3, true, true, true)
ty_shenzhangjiao_joy:addSkill("tyyizhao")
ty_shenzhangjiao_joy:addSkill("tysanshou")
ty_shenzhangjiao_joy:addSkill("tysijun")
ty_shenzhangjiao_joy:addSkill("tytianjie")

ty_shendengai_1 = sgs.General(extension_t, "ty_shendengai_1", "god", 4, true, true, true)
ty_shendengai_1:addSkill("tytuoyu")
ty_shendengai_1:addSkill("tyxianjin")
ty_shendengai_1:addSkill("tyqijing")

ol_shenzhangjiao_1 = sgs.General(extension_o, "ol_shenzhangjiao_1", "god", 3, true, true, true)
ol_shenzhangjiao_1:addSkill("tyyizhao")
ol_shenzhangjiao_1:addSkill("olsanshou")
ol_shenzhangjiao_1:addSkill("olsijun")
ol_shenzhangjiao_1:addSkill("tytianjie")

ol_shenzhenji_joy = sgs.General(extension_o, "ol_shenzhenji_joy", "god", 3, false, true, true)
ol_shenzhenji_joy:addSkill("olshenfu")
ol_shenzhenji_joy:addSkill("olqixian")
ol_shenzhenji_joy:addSkill("joyfeifu")

ol_shensunquan_1 = sgs.General(extension_o, "ol_shensunquan_1", "god", 4, true, true, true)
ol_shensunquan_1:addSkill("olyuheng")
ol_shensunquan_1:addSkill("oldili")

f_shensunshangxiang_shu = sgs.General(extension_f, "f_shensunshangxiang_shu", "god", 4, false, true, true)
f_shensunshangxiang_shu:addSkill("f_jianyuan")
f_shensunshangxiang_shu:addSkill("f_gongli")

--[[tc_shenzhurong_1 = sgs.General(extension_tc, "tc_shenzhurong_1", "god", 4, false, true, true)
tc_shenzhurong_1:addSkill("tc_juxiang_stsh")
tc_shenzhurong_1:addSkill("tc_liefeng_spwd")
tc_shenzhurong_1:addSkill("tc_changbiao_sqrh")]]

--

--可于出牌阶段随意更换皮肤
mobileGOD_SkinChange_ButtonCard = sgs.CreateSkillCard{
    name = "mobileGOD_SkinChange_ButtonCard",
	target_fixed = true,
	on_use = function(self, room, player, targets)
		local mhp = player:getMaxHp()
		local hp = player:getHp()
		--(界)神郭嘉(手杀)
		if player:getGeneralName() == "f_shenguojia" or player:getGeneralName() == "f_shenguojia_c" or player:getGeneralName() == "f_shenguojia_joy"
		or player:getGeneralName() == "f_shenguojia_nv1" or player:getGeneralName() == "f_shenguojia_nv2"
		or player:getGeneralName() == "f_shenguojia_d1" or player:getGeneralName() == "f_shenguojia_d2" then
			local n = player:getMark("@f_huishii")
			local choices = {"sjyh", "sgj_hnqm", "sjjoy", "sgj_wxmy", "sgj_zcjj", "sgj_yxzy_first", "sgj_yxzy_second"}
			if player:getMark("f_tianyi") > 0 then table.removeOne(choices, "sgj_yxzy_first")
			else table.removeOne(choices, "sgj_yxzy_second") end
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			if choice == "sjyh" then
				room:changeHero(player, "f_shenguojia", false, false, false, false)
			elseif choice == "sgj_hnqm" then
				room:changeHero(player, "f_shenguojia_c", false, false, false, false)
			elseif choice == "sjjoy" then
				room:changeHero(player, "f_shenguojia_joy", false, false, false, false)
			elseif choice == "sgj_wxmy" then
				room:changeHero(player, "f_shenguojia_nv1", false, false, false, false)
			elseif choice == "sgj_zcjj" then
				room:changeHero(player, "f_shenguojia_nv2", false, false, false, false)
			elseif choice == "sgj_yxzy_first" then
				room:changeHero(player, "f_shenguojia_d1", false, false, false, false)
			elseif choice == "sgj_yxzy_second" then
				room:changeHero(player, "f_shenguojia_d2", false, false, false, false)
			end
			room:setPlayerMark(player, "@f_huishii", n)
		end
		if player:getGeneral2Name() == "f_shenguojia" or player:getGeneral2Name() == "f_shenguojia_c" or player:getGeneral2Name() == "f_shenguojia_joy"
		or player:getGeneral2Name() == "f_shenguojia_nv1" or player:getGeneral2Name() == "f_shenguojia_nv2"
		or player:getGeneral2Name() == "f_shenguojia_d1" or player:getGeneral2Name() == "f_shenguojia_d2" then
			local n = player:getMark("@f_huishii")
			local choices = {"sjyh", "sgj_hnqm", "sjjoy", "sgj_wxmy", "sgj_zcjj", "sgj_yxzy_first", "sgj_yxzy_second"}
			if player:getMark("f_tianyi") > 0 then table.removeOne(choices, "sgj_yxzy_first")
			else table.removeOne(choices, "sgj_yxzy_second") end
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			if choice == "sjyh" then
				room:changeHero(player, "f_shenguojia", false, false, true, false)
			elseif choice == "sgj_hnqm" then
				room:changeHero(player, "f_shenguojia_c", false, false, true, false)
			elseif choice == "sjjoy" then
				room:changeHero(player, "f_shenguojia_joy", false, false, true, false)
			elseif choice == "sgj_wxmy" then
				room:changeHero(player, "f_shenguojia_nv1", false, false, true, false)
			elseif choice == "sgj_zcjj" then
				room:changeHero(player, "f_shenguojia_nv2", false, false, true, false)
			elseif choice == "sgj_yxzy_first" then
				room:changeHero(player, "f_shenguojia_d1", false, false, true, false)
			elseif choice == "sgj_yxzy_second" then
				room:changeHero(player, "f_shenguojia_d2", false, false, true, false)
			end
			room:setPlayerMark(player, "@f_huishii", n)
		end
		--(界)神荀彧(手杀)
		if player:getGeneralName() == "f_shenxunyu" or player:getGeneralName() == "f_shenxunyu_c" or player:getGeneralName() == "f_shenxunyu_joy"
		or player:getGeneralName() == "f_shenxunyu_x" or player:getGeneralName() == "f_shenxunyu_nv" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+sxy_hnqm+sjjoy+sxy_yjtw+sxy_xhry")
			if choice == "sjyh" then
				room:changeHero(player, "f_shenxunyu", false, false, false, false)
			elseif choice == "sjjoy" then
				room:changeHero(player, "f_shenxunyu_joy", false, false, false, false)
			elseif choice == "sxy_hnqm" then
				room:changeHero(player, "f_shenxunyu_c", false, false, false, false)
			elseif choice == "sxy_yjtw" then
				room:changeHero(player, "f_shenxunyu_x", false, false, false, false)
			elseif choice == "sxy_xhry" then
				room:changeHero(player, "f_shenxunyu_nv", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "f_shenxunyu" or player:getGeneral2Name() == "f_shenxunyu_c" or player:getGeneral2Name() == "f_shenxunyu_joy"
		or player:getGeneral2Name() == "f_shenxunyu_x" or player:getGeneral2Name() == "f_shenxunyu_nv" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+sxy_hnqm+sjjoy+sxy_yjtw+sxy_xhry")
			if choice == "sjyh" then
				room:changeHero(player, "f_shenxunyu", false, false, true, false)
			elseif choice == "sjjoy" then
				room:changeHero(player, "f_shenxunyu_joy", false, false, true, false)
			elseif choice == "sxy_hnqm" then
				room:changeHero(player, "f_shenxunyu_c", false, false, true, false)
			elseif choice == "sxy_yjtw" then
				room:changeHero(player, "f_shenxunyu_x", false, false, true, false)
			elseif choice == "sxy_xhry" then
				room:changeHero(player, "f_shenxunyu_nv", false, false, true, false)
			end
		end
		--(界)神孙策(手杀)
		if player:getGeneralName() == "f_shensunce" or player:getGeneralName() == "f_shensunce_x" or player:getGeneralName() == "f_shensunce_joy"
		or player:getGeneralName() == "f_shensunce_c" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+ssc_yjtw+sjjoy+ssc_bwzs")
			if choice == "sjyh" then
				room:changeHero(player, "f_shensunce", false, false, false, false)
			elseif choice == "ssc_yjtw" then
				room:changeHero(player, "f_shensunce_x", false, false, false, false)
			elseif choice == "sjjoy" then
				room:changeHero(player, "f_shensunce_joy", false, false, false, false)
			elseif choice == "ssc_bwzs" then
				room:changeHero(player, "f_shensunce_c", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "f_shensunce" or player:getGeneral2Name() == "f_shensunce_x" or player:getGeneral2Name() == "f_shensunce_joy"
		or player:getGeneral2Name() == "f_shensunce_c" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+ssc_yjtw+sjjoy+ssc_bwzs")
			if choice == "sjyh" then
				room:changeHero(player, "f_shensunce", false, false, true, false)
			elseif choice == "ssc_yjtw" then
				room:changeHero(player, "f_shensunce_x", false, false, true, false)
			elseif choice == "sjjoy" then
				room:changeHero(player, "f_shensunce_joy", false, false, true, false)
			elseif choice == "ssc_bwzs" then
				room:changeHero(player, "f_shensunce_c", false, false, true, false)
			end
		end
		--神太史慈-第二版(手杀)
		if player:getGeneralName() == "f_shentaishicii" or player:getGeneralName() == "f_shentaishicii_c" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+stsc_yhry")
			if choice == "sjyh" then
				room:changeHero(player, "f_shentaishicii", false, false, false, false)
			else
				room:changeHero(player, "f_shentaishicii_c", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "f_shentaishicii" or player:getGeneral2Name() == "f_shentaishicii_c" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+stsc_yhry")
			if choice == "sjyh" then
				room:changeHero(player, "f_shentaishicii", false, false, true, false)
			else
				room:changeHero(player, "f_shentaishicii_c", false, false, true, false)
			end
		end
		--神姜维-怒麟燎原
		if player:getGeneralName() == "ty_shenjiangweiBN" or player:getGeneralName() == "ty_shenjiangweiBN_ub" or player:getGeneralName() == "ty_shenjiangweiBN_1" then
			local n = player:getMark("@typingxiangBN")
			local choice = room:askForChoice(player, self:objectName(), "sjwbn_fhls+sjwbn_ldjz")
			if choice == "sjwbn_fhls" then
				room:changeHero(player, "ty_shenjiangweiBN", false, false, false, false)
			else
				room:changeHero(player, "ty_shenjiangweiBN_1", false, false, false, false)
			end
			room:setPlayerMark(player, "@typingxiangBN", n)
		end
		if player:getGeneral2Name() == "ty_shenjiangweiBN" or player:getGeneral2Name() == "ty_shenjiangweiBN_ub" or player:getGeneral2Name() == "ty_shenjiangweiBN_1" then
			local n = player:getMark("@typingxiangBN")
			local choice = room:askForChoice(player, self:objectName(), "sjwbn_fhls+sjwbn_ldjz")
			if choice == "sjwbn_fhls" then
				room:changeHero(player, "ty_shenjiangweiBN", false, false, true, false)
			else
				room:changeHero(player, "ty_shenjiangweiBN_1", false, false, true, false)
			end
			room:setPlayerMark(player, "@typingxiangBN", n)
		end
		--(界)神姜维(新杀)
		if player:getGeneralName() == "ty_shenjiangwei" or player:getGeneralName() == "ty_shenjiangwei_joy" or player:getGeneralName() == "ty_shenjiangwei_3gods"
		or player:getGeneralName() == "ty_shenjiangwei_1" then
			local n = player:getMark("@typingxiang")
			local choice = room:askForChoice(player, self:objectName(), "sjyh+sjjoy+sjw_ymlt+sjw_cjfb")
			if choice == "sjyh" then
				room:changeHero(player, "ty_shenjiangwei", false, false, false, false)
			elseif choice == "sjjoy" then
				room:changeHero(player, "ty_shenjiangwei_joy", false, false, false, false)
			elseif choice == "sjw_ymlt" then
				room:changeHero(player, "ty_shenjiangwei_3gods", false, false, false, false)
			elseif choice == "sjw_cjfb" then
				room:changeHero(player, "ty_shenjiangwei_1", false, false, false, false)
			end
			room:setPlayerMark(player, "@typingxiang", n)
		end
		if player:getGeneral2Name() == "ty_shenjiangwei" or player:getGeneral2Name() == "ty_shenjiangwei_joy" or player:getGeneral2Name() == "ty_shenjiangwei_3gods"
		or player:getGeneral2Name() == "ty_shenjiangwei_1" then
			local n = player:getMark("@typingxiang")
			local choice = room:askForChoice(player, self:objectName(), "sjyh+sjjoy+sjw_ymlt+sjw_cjfb")
			if choice == "sjyh" then
				room:changeHero(player, "ty_shenjiangwei", false, false, true, false)
			elseif choice == "sjjoy" then
				room:changeHero(player, "ty_shenjiangwei_joy", false, false, true, false)
			elseif choice == "sjw_ymlt" then
				room:changeHero(player, "ty_shenjiangwei_3gods", false, false, true, false)
			elseif choice == "sjw_cjfb" then
				room:changeHero(player, "ty_shenjiangwei_1", false, false, true, false)
			end
			room:setPlayerMark(player, "@typingxiang", n)
		end
		--神马超(新杀)
		if player:getGeneralName() == "ty_shenmachao" or player:getGeneralName() == "ty_shenmachao_1" or player:getGeneralName() == "ty_shenmachao_1dt"
		or player:getGeneralName() == "ty_shenmachao_t" or player:getGeneralName() == "ty_shenmachao_sp" or player:getGeneralName() == "ty_shenmachao_3gods" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+smc_xwjl+smc_xwjldt+smc_xyxc+smc_lwfc+smc_ymlt")
			if choice == "sjyh" then
				room:changeHero(player, "ty_shenmachao", false, false, false, false)
			elseif choice == "smc_xwjl" then
				room:changeHero(player, "ty_shenmachao_1", false, false, false, false)
			elseif choice == "smc_xwjldt" then
				room:changeHero(player, "ty_shenmachao_1dt", false, false, false, false)
			elseif choice == "smc_xyxc" then
				room:changeHero(player, "ty_shenmachao_t", false, false, false, false)
			elseif choice == "smc_lwfc" then
				room:changeHero(player, "ty_shenmachao_sp", false, false, false, false)
			elseif choice == "smc_ymlt" then
				room:changeHero(player, "ty_shenmachao_3gods", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "ty_shenmachao" or player:getGeneral2Name() == "ty_shenmachao_1" or player:getGeneral2Name() == "ty_shenmachao_1dt"
		or player:getGeneral2Name() == "ty_shenmachao_t" or player:getGeneral2Name() == "ty_shenmachao_sp" or player:getGeneral2Name() == "ty_shenmachao_3gods" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+smc_xwjl+smc_xwjldt+smc_xyxc+smc_lwfc+smc_ymlt")
			if choice == "sjyh" then
				room:changeHero(player, "ty_shenmachao", false, false, true, false)
			elseif choice == "smc_xwjl" then
				room:changeHero(player, "ty_shenmachao_1", false, false, true, false)
			elseif choice == "smc_xwjldt" then
				room:changeHero(player, "ty_shenmachao_1dt", false, false, true, false)
			elseif choice == "smc_xyxc" then
				room:changeHero(player, "ty_shenmachao_t", false, false, true, false)
			elseif choice == "smc_lwfc" then
				room:changeHero(player, "ty_shenmachao_sp", false, false, true, false)
			elseif choice == "smc_ymlt" then
				room:changeHero(player, "ty_shenmachao_3gods", false, false, true, false)
			end
		end
		--神张飞(新杀)
		if player:getGeneralName() == "ty_shenzhangfei" or player:getGeneralName() == "ty_shenzhangfei_1" or player:getGeneralName() == "ty_shenzhangfei_joy"
		or player:getGeneralName() == "ty_shenzhangfei_3gods" or player:getGeneralName() == "ty_shenzhangfei_2" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+szf_ansh+sjjoy+szf_ymlt+szf_tbzh")
			if choice == "sjyh" then
				room:changeHero(player, "ty_shenzhangfei", false, false, false, false)
			elseif choice == "szf_ansh" then
				room:changeHero(player, "ty_shenzhangfei_1", false, false, false, false)
			elseif choice == "sjjoy" then
				room:changeHero(player, "ty_shenzhangfei_joy", false, false, false, false)
			elseif choice == "szf_ymlt" then
				room:changeHero(player, "ty_shenzhangfei_3gods", false, false, false, false)
			elseif choice == "szf_tbzh" then
				room:changeHero(player, "ty_shenzhangfei_2", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "ty_shenzhangfei" or player:getGeneral2Name() == "ty_shenzhangfei_1" or player:getGeneral2Name() == "ty_shenzhangfei_joy"
		or player:getGeneral2Name() == "ty_shenzhangfei_3gods" or player:getGeneral2Name() == "ty_shenzhangfei_2" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+szf_ansh+sjjoy+szf_ymlt+szf_tbzh")
			if choice == "sjyh" then
				room:changeHero(player, "ty_shenzhangfei", false, false, true, false)
			elseif choice == "szf_ansh" then
				room:changeHero(player, "ty_shenzhangfei_1", false, false, true, false)
			elseif choice == "sjjoy" then
				room:changeHero(player, "ty_shenzhangfei_joy", false, false, true, false)
			elseif choice == "szf_ymlt" then
				room:changeHero(player, "ty_shenzhangfei_3gods", false, false, false, false)
			elseif choice == "szf_tbzh" then
				room:changeHero(player, "ty_shenzhangfei_2", false, false, false, false)
			end
		end
		--神张角(新杀)
		if player:getGeneralName() == "ty_shenzhangjiao" or player:getGeneralName() == "ty_shenzhangjiao_1" or player:getGeneralName() == "ty_shenzhangjiao_joy" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+szj_ydzz+sjjoy")
			if choice == "sjyh" then
				room:changeHero(player, "ty_shenzhangjiao", false, false, false, false)
			elseif choice == "szj_ydzz" then
				room:changeHero(player, "ty_shenzhangjiao_1", false, false, false, false)
			elseif choice == "sjjoy" then
				room:changeHero(player, "ty_shenzhangjiao_joy", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "ty_shenzhangjiao" or player:getGeneral2Name() == "ty_shenzhangjiao_1" or player:getGeneral2Name() == "ty_shenzhangjiao_joy" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+szj_ydzz+sjjoy")
			if choice == "sjyh" then
				room:changeHero(player, "ty_shenzhangjiao", false, false, true, false)
			elseif choice == "szj_ydzz" then
				room:changeHero(player, "ty_shenzhangjiao_1", false, false, true, false)
			elseif choice == "sjjoy" then
				room:changeHero(player, "ty_shenzhangjiao_joy", false, false, true, false)
			end
		end
		--神邓艾(新杀)
		if player:getGeneralName() == "ty_shendengai" or player:getGeneralName() == "ty_shendengai_1" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+sdi_eczz")
			if choice == "sjyh" then
				room:changeHero(player, "ty_shendengai", false, false, false, false)
			else
				room:changeHero(player, "ty_shendengai_1", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "ty_shendengai" or player:getGeneral2Name() == "ty_shendengai_1" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+sdi_eczz")
			if choice == "sjyh" then
				room:changeHero(player, "ty_shendengai", false, false, true, false)
			else
				room:changeHero(player, "ty_shendengai_1", false, false, true, false)
			end
		end
		--(界)神张角(OL)
		if player:getGeneralName() == "ol_shenzhangjiao" or player:getGeneralName() == "ol_shenzhangjiao_1" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+szj_ydzz")
			if choice == "sjyh" then
				room:changeHero(player, "ol_shenzhangjiao", false, false, false, false)
			else
				room:changeHero(player, "ol_shenzhangjiao_1", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "ol_shenzhangjiao" or player:getGeneral2Name() == "ol_shenzhangjiao_1" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+szj_ydzz")
			if choice == "sjyh" then
				room:changeHero(player, "ol_shenzhangjiao", false, false, true, false)
			else
				room:changeHero(player, "ol_shenzhangjiao_1", false, false, true, false)
			end
		end
		--神甄姬(OL)
		if player:getGeneralName() == "ol_shenzhenji" or player:getGeneralName() == "ol_shenzhenji_joy" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+sjjoy")
			if choice == "sjyh" then
				room:changeHero(player, "ol_shenzhenji", false, false, false, false)
			else
				room:changeHero(player, "ol_shenzhenji_joy", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "ol_shenzhenji" or player:getGeneral2Name() == "ol_shenzhenji_joy" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+sjjoy")
			if choice == "sjyh" then
				room:changeHero(player, "ol_shenzhenji", false, false, true, false)
			else
				room:changeHero(player, "ol_shenzhenji_joy", false, false, true, false)
			end
		end
		--神孙权(OL)
		if player:getGeneralName() == "ol_shensunquan" or player:getGeneralName() == "ol_shensunquan_1" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+ssq_thry")
			if choice == "sjyh" then
				room:changeHero(player, "ol_shensunquan", false, false, false, false)
			else
				room:changeHero(player, "ol_shensunquan_1", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "ol_shensunquan" or player:getGeneral2Name() == "ol_shensunquan_1" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+ssq_thry")
			if choice == "sjyh" then
				room:changeHero(player, "ol_shensunquan", false, false, true, false)
			else
				room:changeHero(player, "ol_shensunquan_1", false, false, true, false)
			end
		end
		--神祝融(天才包)
		--[[if player:getGeneralName() == "tc_shenzhurong" or player:getGeneralName() == "tc_shenzhurong_1" then
			local choice = room:askForChoice(player, self:objectName(), "szr_jghw+szr_fdlh")
			if choice == "szr_jghw" then
				room:changeHero(player, "tc_shenzhurong", false, false, false, false)
			else
				room:changeHero(player, "tc_shenzhurong_1", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "tc_shenzhurong" or player:getGeneral2Name() == "tc_shenzhurong_1" then
			local choice = room:askForChoice(player, self:objectName(), "szr_jghw+szr_fdlh")
			if choice == "szr_jghw" then
				room:changeHero(player, "tc_shenzhurong", false, false, true, false)
			else
				room:changeHero(player, "tc_shenzhurong_1", false, false, true, false)
			end
		end]]
		----
		if player:getMaxHp() ~= mhp then room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp)) end
		if player:getHp() ~= hp then room:setPlayerProperty(player, "hp", sgs.QVariant(hp)) end
	end,
}
mobileGOD_SkinChange_Button = sgs.CreateZeroCardViewAsSkill{
    name = "mobileGOD_SkinChange_Button&",
	view_as = function()
		return mobileGOD_SkinChange_ButtonCard:clone()
	end,
}
if not sgs.Sanguosha:getSkill("mobileGOD_SkinChange_Button") then skills:append(mobileGOD_SkinChange_Button) end

sgs.Sanguosha:addSkills(skills)
sgs.LoadTranslationTable{
    ["mobileGod"] = "手杀神武将",
	["tenyearGod"] = "十周年神武将",
	["OLGod"] = "OL神武将",
	["joyGod"] = "欢乐杀神武将",
	["wxGod"] = "小程序神武将",
	["offlineGod"] = "线下神武将",
	["jlsgGod"] = "极略三国神武将",
	["FCGod"] = "吧友diy神武将",
	["newgodsCard"] = "神武将专属卡牌",
	
	["GeniusPackageGod"] = "天才包专属神武将",
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--==手杀神武将==--
	--神郭嘉(手杀)-->界限突破
	["f_shenguojia"] = "界·神郭嘉[手杀]",
	["&f_shenguojia"] = "界神郭嘉",
	["#f_shenguojia"] = "星月奇佐",
	["designer:f_shenguojia"] = "黑稻子,官方,时光流逝FC",
	["cv:f_shenguojia"] = "官方",
	["illustrator:f_shenguojia"] = "木美人,紫髯的小乔",
	  --慧识（界）
	["f_huishi"] = "慧识",
	["f_huishiContinue"] = "慧识",
	["f_huishicontinue"] = "慧识",
	[":f_huishi"] = "出牌阶段限一次，若你的体力上限小于10，你可以进行判定：若结果与此阶段内以此法进行判定的结果的花色均不同且此时你的体力上限小于10，你可以重复此流程并<font color=\"#00CCFF\"><b>选择加1点体力上限或回复1点体力</b></font>，否则你终止判定。" ..
	"所有流程结束后，你可以将所有判定牌交给一名角色。然后若<font color=\"#00CCFF\"><b>你</b></font>手牌数为全场最多，你须<font color=\"#00CCFF\"><b>选择减1点体力上限或失去1点体力</b></font>。",
	["HandcarddataHS"] = "慧识",
	["@f_huishiAdd"] = "慧识",
	["@f_huishiAdd:mhp"] = "加1点体力上限",
	["@f_huishiAdd:hp"] = "回复1点体力",
	["@f_huishi_continue"] = "[慧识]你可以继续判定",
	["f_huishi-give"] = "请将所有判定牌交给一名角色",
	["@f_huishiLose"] = "慧识",
	["@f_huishiLose:mhp"] = "减1点体力上限",
	["@f_huishiLose:hp"] = "失去1点体力",
	["$f_huishi1"] = "聪以知远，明以察微。",
	["$f_huishi2"] = "见微知著，识人心智。",
	  --天翊
	["f_tianyi"] = "天翊",
	["f_tianyiDamageTake"] = "",
	[":f_tianyi"] = "觉醒技，准备阶段开始时，若全场存活角色在本局游戏中均受到过伤害，你加2点体力上限，回复1点体力，然后令一名角色获得“佐幸”。",
	["f_tianyiAnimate"] = "image=image/animate/f_tianyi.png",
	["@f_tianyi"] = "天翊",
	["f_tianyi-invoke"] = "请选择一名角色，令其获得“佐幸”",
	["$f_tianyi1"] = "天命靡常，惟德是辅。",
	["$f_tianyi2"] = "可成吾志者，必此人也！",
	    --佐幸（测试版）
	  ["ty_zuoxing"] = "佐幸",
	  [":ty_zuoxing"] = "出牌阶段限一次，若<font color=\"#00CCFF\"><b>令你获得此技能的角色</b></font>存活且其体力上限大于1，你可以令其减1点体力上限，若如此做，你可以视为使用一张普通锦囊牌。",
	  ["$ty_zuoxing1"] = "以聪虑难，悉咨于上。",
	  ["$ty_zuoxing2"] = "奉孝不才，愿献勤心。",
	  ["$ty_zuoxing3"] = "既为奇佐，岂可徒有虚名？",
	  --辉逝（改回原版）
	["f_huishii"] = "辉逝",
	[":f_huishii"] = "限定技，出牌阶段，你可以选择一名角色：若其有未触发的觉醒技，且你体力上限不小于场上存活人数，则你选择其中一个觉醒技，其视为已满足觉醒条件；否则其摸四张牌。若如此做，你减2点体力上限。",
	["@f_huishii"] = "辉逝",
	--["f_tianyi_Trigger"] = "“天翊”已可觉醒",
	["$f_huishii1"] = "丧家之犬，主公实不足虑也！",
	["$f_huishii2"] = "时势兼备，主公复有何忧？",
	  --阵亡
	["~f_shenguojia"] = "可叹桢干命也迂..........",
	
	--神荀彧(手杀)-->界限突破
	["f_shenxunyu"] = "界·神荀彧[手杀]",
	["&f_shenxunyu"] = "界神荀彧",
	["#f_shenxunyu"] = "洞心先识",
	["designer:f_shenxunyu"] = "官方,时光流逝FC",
	["cv:f_shenxunyu"] = "官方",
	["illustrator:f_shenxunyu"] = "枭瞳,紫髯的小乔",
	
	["ngCRemover"] = "加入[神武将专属卡牌]",
	["ngcremover"] = "加入[神武将专属卡牌]",
	["@ngCRemover"] = "是否加入【神武将专属卡牌】？",
	["~ngCRemover"] = "包括：【奇正相生/三首】<br />\
◆如果场上有技能“天佐/OL三首”，【奇正相生/三首】不会被移除<br />\
×神蒲元“神兵库”中(游戏主体没有)的新装备牌/【挈挟】<font color='red'>不会加入牌堆</font>",
	
	  --天佐（原测试版）
	["f_tianzuo"] = "天佐",
	[":f_tianzuo"] = "游戏开始前，你将八张【奇正相生】加入牌堆。<font color=\"#FFCC00\"><b>当有一名角色成为你于游戏开始前加入的【奇正相生】的目标时，你可以查看其手牌，然后为其重新指定“正兵”或“奇兵”。</b></font>",
	["zhengbing"] = "指定为“正兵”",
	["qibing"] = "指定为“奇兵”",
	["$f_tianzuo1"] = "此时进之多弊，守之多利，愿主公熟虑。",
	["$f_tianzuo2"] = "主公若不时定，待四方生心，则无及矣！",
	    --普通单体锦囊:奇正相生
	  ["f_qizhengxiangsheng"] = "奇正相生",
	  ["Fqizhengxiangsheng"] = "奇正相生",
	  ["f_shenxunyuTrick"] = "神荀彧专属锦囊",
	  [":f_qizhengxiangsheng"] = "锦囊牌\
	  <b>时机</b>：出牌阶段\
	  <b>目标</b>：一名其他角色\
	  <b>效果</b>：出牌阶段，对一名其他角色使用此牌并指定其为目标后，为其指定“正兵”或“奇兵”。然后其可以打出一张【杀】或【闪】。若“奇兵”目标没有打出【杀】，你对其造成1点伤害；若“正兵”目标没有打出【闪】，你获得其一张牌。",
	  ["buyaosong"] = "正兵",
	  ["touxi!"] = "奇兵",
	  ["yingduiqibing"] = "【应对“奇兵”】打出一张【杀】",
	  ["yingduizhengbing"] = "【应对“正兵”】打出一张【闪】",
	  ["wobuyingdui"] = "什么也不做",
	  ["f_qizhengxiangsheng-slash"] = "请打出一张【杀】",
	  ["f_qizhengxiangsheng-jink"] = "请打出一张【闪】",
	  --灵策（界）
	["f_lingce"] = "灵策",
	[":f_lingce"] = "锁定技，一名角色使用智囊牌名的锦囊牌([官方]:<s>无中生有/</s>过河拆桥/无懈可击;<font color=\"#FFCC00\"><b>[三十六计]:借刀杀人/无中生有/顺手牵羊/铁索连环</b></font>)、“定汉”已记录的牌名或【奇正相生】时，你摸一张牌。",
	["$f_lingce1"] = "绍士卒虽众，其实难用，必无为也！",
	["$f_lingce2"] = "袁军不过一盘砂砾，主公用奇则散！",
	  --定汉
	["f_dinghan"] = "定汉",
	["f_dinghanMR"] = "定汉",
	[":f_dinghan"] = "每种牌名限一次，你成为锦囊牌的目标时，你记录此牌名，然后取消之。你的回合开始时，你可以在“定汉”记录中增加或移除一种锦囊牌名。<font color=\"#FFCC00\"><b>（锦囊牌记录范围：标准包、军争篇、应变篇、天灾包、奇正相生）</b></font>",
	["addtrickcard"] = "增加一种锦囊牌名",
	["rmvtrickcard"] = "移除一种锦囊牌名",
	["cancel"] = "取消",
	    --记录牌名：
	  ["dly"] = "【延时锦囊】",
	  
	  --["wzsy"] = "无中生有",
	  ["ghcq"] = "过河拆桥",
	  ["wxkj"] = "无懈可击",
	  --
	  ["jdsr"] = "借刀杀人", --胜战计,第3计
	  ["wzsy"] = "无中生有", --敌战计,第7计
	  ["ssqy"] = "顺手牵羊", --敌战计,第12计
	  ["tslh"] = "铁索连环", --败战计,第35计(原名:连环计)
	  
	  ["nmrq"] = "南蛮入侵",
	  ["wjqf"] = "万箭齐发",
	  ["wgfd"] = "五谷丰登",
	  ["tyjy"] = "桃园结义",
	  ["jd"] = "决斗",
	  ["lbss"] = "乐不思蜀",
	  ["sd"] = "闪电",
	  ["hg"] = "火攻",
	  ["blcd"] = "兵粮寸断",
	  ["syqj"] = "水淹七军",
	  ["dzxj"] = "洞烛先机",
	  ["zjqy"] = "逐近弃远",
	  ["cqby"] = "出其不意",
	  ["sjyb"] = "随机应变",
	  ["dz"] = "地震",
	  ["tf"] = "台风",
	  ["hsi"] = "洪水",
	  ["hsn"] = "火山",
	  ["nsl"] = "泥石流",
	  
	  ["qzxs"] = "奇正相生", --神荀彧专属锦囊
	  
	["@f_dinghan1"] = "增加锦囊记录",
	["@f_dinghand1"] = "增加延时锦囊记录",
	["@f_dinghan2"] = "移除记录",
	["@f_dinghand2"] = "移除延时锦囊记录",
	["$f_dinghan1"] = "益国之事，虽死弗避。",
	["$f_dinghan2"] = "杀身有地，报国有时！",
	["$f_dinghan3"] = "汉室复兴，指日可待！", --修改“定汉”记录
	  --阵亡
	["~f_shenxunyu"] = "宁鸣而死，不默而生！",
	
	--神太史慈(手杀)-->界限突破
	["f_shentaishici"] = "界·神太史慈[手杀]",
	["&f_shentaishici"] = "界神太史慈",
	["#f_shentaishici"] = "义信天武",
	["designer:f_shentaishici"] = "官方,时光流逝FC",
	["cv:f_shentaishici"] = "官方",
	["illustrator:f_shentaishici"] = "枭瞳,紫髯的小乔",
	  --笃烈（界）
	["f_dulie"] = "笃烈",
	["f_dulieEXS"] = "笃烈",
	[":f_dulie"] = "锁定技，游戏开始时，所有其他角色<font color=\"#CC3333\"><b>随机</b></font>获得“围”标记。你对没有“围”标记的角色使用【杀】无距离限制，且当你成为没有“围”标记的角色使用【杀】的目标时，你进行判定：若判定结果为红桃，取消之。",
	["WEI"] = "围", --与原版神太史慈的“围”标记不同
	["$f_dulie1"] = "素来言出必践，成吾信义昭彰！",
	["$f_dulie2"] = "小信如若不成，大信将以何立？",
	  --破围（界）
	["f_powei"] = "破围",
	[":f_powei"] = "使命技，你使用的【杀】对有“围”标记的角色造成伤害时，弃置该“围”标记并防止此伤害。\
	使命<b>成功</b>：你使用的【杀】结算结束后，若场上没有“围”标记，且你未于这之前进入过濒死状态，则你使命达成，<font color=\"#CC3333\"><b>摸X张牌</b></font>并获得“神著”（X为你本局弃置的“围”标记数）；\
	使命<b>失败</b>：若你在成功达成使命前进入濒死状态，你将体力值回复至1点，再弃置装备区所有牌，使命失效。",
	["f_poweisdc"] = "",
	["$f_powei"] = "成功破围，使命达成！",
	["$f_poweiSUC"] = "<font color='red'><b>义信天武</b></font>！%from 使命成功，获得<font color='yellow'><b>“神著”</b></font>",
	["$f_poweiFAL"] = "很遗憾，%from 使命已失败",
	["f_powei_success"] = "",
	["f_powei_fail"] = "",
	["$f_powei1"] = "弓马齐射洒热血，突破重围显英豪！", --弃置“围”标记；使命成功
	["$f_powei2"] = "敌军尚犹严防，有待明日再看！", --使命失败
	  --“破围”使命成功可获得技能：
	    --神著
	  ["f_shenzhuo"] = "神著",
	  ["f_shenzhuoMAXS"] = "神著",
	  [":f_shenzhuo"] = "你使用非转化和非虚拟【杀】结算结束后，摸一张牌。你使用【杀】无次数限制。",
	  ["$f_shenzhuo1"] = "力引强弓百斤，矢出贯手著棼！",
	  ["$f_shenzhuo2"] = "箭既已在弦上，吾又岂能不发！",
	  --荡魔（界）
	["f_dangmo"] = "荡魔",
	[":f_dangmo"] = "你于出牌阶段使用的第一张【杀】可以多选Y-1名角色且<font color=\"#CC3333\"><b>攻击距离+Z</b></font>。" ..
	"（Y为你的当前体力值<font color=\"#CC3333\"><b>且至少为1</b></font>；<font color=\"#CC3333\"><b>Z为你已损失的体力值</b></font>）", --注：至少为1是为了防止和老周泰双将时在不屈状态砍不了人的情况
	["$f_dangmo1"] = "魔高一尺，道高一丈！",
	["$f_dangmo2"] = "天魔祸世，吾自荡而除之！",
	["stscAudio"] = "", --神太史慈专用音响
	  --阵亡
	["~f_shentaishici"] = "魂归......天...地...",
	------
	["$yingba1"] = "从我者可免，拒我者难容！",
	["$yingba2"] = "卧榻之侧，岂容他人鼾睡！",
	["$fuhaisc1"] = "翻江覆蹈海，六合定乾坤！",
	["$fuhaisc2"] = "力攻平江东，威名扬天下！",
	["$pinghe1"] = "不过胆小鼠辈，吾等有何惧哉！",
	["$pinghe2"] = "只可得胜而返，岂能战败而归！",
	["~shensunce"] = "无耻小人！胆敢暗算于我……",
	
	--神太史慈-第二版(手杀)
	["f_shentaishicii"] = "神太史慈[手杀]-第二版",
	["&f_shentaishicii"] = "神太史慈",
	["#f_shentaishicii"] = "义信天武",
	["designer:f_shentaishicii"] = "官方",
	["cv:f_shentaishicii"] = "官方",
	["illustrator:f_shentaishicii"] = "枭瞳,紫髯的小乔",
	  --笃烈
	["f_duliee"] = "笃烈",
	[":f_duliee"] = "锁定技，当你成为体力值大于你的角色使用【杀】的目标时，你进行判定：若判定结果为红桃，取消之。",
	["$f_duliee1"] = "素来言出必践，成吾信义昭彰！",
	["$f_duliee2"] = "小信如若不成，大信将以何立？",
	  --破围
	["f_poweii"] = "破围",
	[":f_poweii"] = "使命技，游戏开始时，所有其他角色获得“围”标记。有“围”标记的角色受到伤害后弃置其“围”标记。回合开始时，你令有“围”标记的所有角色将“围”标记移动至下家（若你因此获得“围”标记，立即移至下家）。有“围”标记的角色回合开始时，你可以选择一项：1.弃置一张手牌，对其造成1点伤害；2.若其体力值不大于你，获得其一张手牌。若如此做，你本回合视为在其攻击范围内。\
	使命<b>成功</b>：回合开始时，若场上没有“围”标记，且你未于这之前进入过濒死状态，则你使命达成，获得“神著”；\
	使命<b>失败</b>：若你在成功达成使命前进入濒死状态，你将体力值回复至1点，再弃置场上所有“围”标记以及你装备区所有牌，使命失效。",
	["WEII"] = "围",
	["f_poweii:1"] = "弃置一张手牌，对其造成1点伤害（以此弃置其“围”标记）",
	["f_poweii:2"] = "获得其一张手牌",
	["$f_poweii"] = "成功破围，使命达成！",
	["$f_poweiiSUC"] = "<font color='red'><b>义信天武</b></font>！%from 使命成功，获得<font color='yellow'><b>“神著”</b></font>",
	["$f_poweiiFAL"] = "很遗憾，%from 使命已失败",
	["f_poweii_success"] = "",
	["f_poweii_fail"] = "",
	["$f_poweii1"] = "君且城中等候，待吾探敌虚实！", --游戏/回合开始时
	["$f_poweii2"] = "弓马齐射洒热血，突破重围显英豪！", --弃置“围”标记；使命成功
	["$f_poweii3"] = "敌军尚犹严防，有待明日再看！", --使命失败
	  --“破围”使命成功可获得技能：
	    --神著
	["f_shenzhuoo"] = "神著",
	["f_shenzhuooMAXS"] = "神著",
	[":f_shenzhuoo"] = "锁定技，你使用非转化和非虚拟【杀】结算结束后，选择一项：1.摸一张牌，本回合使用【杀】次数+1；2.摸三张牌，本回合不能再使用【杀】。",
	["szSlashaddOne"] = "",
	["f_shenzhuoo:1"] = "摸一张牌，本回合使用【杀】次数+1",
	["f_shenzhuoo:2"] = "摸三张牌，本回合不能再使用【杀】",
	["$f_shenzhuoo1"] = "力引强弓百斤，矢出贯手著棼！",
	["$f_shenzhuoo2"] = "箭既已在弦上，吾又岂能不发！",
	  --阵亡
	["~f_shentaishicii"] = "魂归......天...地...",
	
	--神孙策(手杀)-->界限突破
	["f_shensunce"] = "界·神孙策[手杀]",
	["&f_shensunce"] = "界神孙策",
	["#f_shensunce"] = "踞江鬼雄",
	["designer:f_shensunce"] = "官方,时光流逝FC",
	["cv:f_shensunce"] = "官方",
	["illustrator:f_shensunce"] = "枭瞳,紫髯的小乔",
	  --英霸（界）
	["imba"] = "英霸",
	["imbaMaxDistance"] = "英霸",
	["imbaNoLimit"] = "英霸",
	[":imba"] = "出牌阶段限一次，你可以选择一名体力上限大于1的其他角色，令其减1点体力上限并获得1枚“平定”标记，然后你减1点体力上限。你对拥有“平定”标记的角色使用牌无距离限制<font color=\"#FF0066\"><b>且次数+X</b></font>（X为其拥有的“平定”标记数）。",
	["PingDing"] = "平定",
	["$imba1"] = "卧榻之侧，岂容他人酣睡！",
	["$imba2"] = "从我者可免，拒我者难容！",
	  --覆海
	["f_fuhai"] = "覆海",
	[":f_fuhai"] = "锁定技，当你对拥有“平定”标记的角色使用牌时，你令其不能响应此牌且你摸一张牌（每回合限摸两次）。拥有“平定”标记的角色死亡时，你加X点体力上限并摸X张牌。",
	["f_fuhaiDraw"] = "",
	["$f_fuhai1"] = "翻江覆蹈海，六合定乾坤！",
	["$f_fuhai2"] = "力攻平江东，威名扬天下！",
	["$f_fuhai3"] = "平定三郡，稳踞江东！！", --拥有“平定”标记的角色死亡
	  --冯河（界）
	["f_pinghe"] = "冯河",
	["f_pingheDefuseDamage"] = "冯河",
	["f_pinghedefusedamage"] = "冯河",
	["f_pingheAudio"] = "冯河",
	[":f_pinghe"] = "锁定技，你的手牌上限等于你已损失的体力值。当你受到其他角色造成的伤害时，若你有手牌且体力上限大于1，防止本次伤害，然后你减1点体力上限并将一张手牌交给一名其他角色，然后若你拥有“英霸”，令伤害来源获得1枚“平定”标记。" ..
	"<font color=\"#FF0066\"><b>锁定技，当你回复体力后，若你的体力值大于1，你失去1点体力，然后摸Y张牌（Y为你此时的体力值数）。</b></font>",
	["@f_pingheDefuseDamage-card"] = "请选择一名其他角色，交给其一张手牌",
	["~f_pingheDefuseDamage"] = "优先给队友好牌，如果没有队友则给对手废牌或卡对手手牌",
	["$f_pinghe1"] = "只可得胜而返，岂能败战而归？！",
	["$f_pinghe2"] = "不过胆小鼠辈，吾等有何惧哉？！",
	  --阵亡
	["~f_shensunce"] = "无耻小人，胆敢暗算于我！......",
	
	--张仲景-测试初版(手杀)
	["zhangzhongjing_first"] = "张仲景-测试初版",
	["&zhangzhongjing_first"] = "张机",
	["#zhangzhongjing_first"] = "医理圣哲?黑心冥医!",
	["designer:zhangzhongjing_first"] = "官方",
	["cv:zhangzhongjing_first"] = "官方",
	["illustrator:zhangzhongjing_first"] = "佚名,紫髯的小乔",
	  --济世
	["f_jishi"] = "济世",
	[":f_jishi"] = "锁定技，当你使用牌结算结束后，若此牌未造成伤害且仍在弃牌堆，你将此牌置于你武将牌上，称为“仁”（最多6张；每当“仁”数量溢出时，最先置为“仁”的牌将会依次移出“仁”直到剩余6张）；当你失去“仁”时，你摸一张牌。",
	["f_REN"] = "仁", --这里为私家牌堆，其实应为公共牌堆
	["$f_jishi1"] = "勤求古训，常怀济人之志。",
	["$f_jishi2"] = "博采众方，不随趋势之徒。",
	    --“仁”溢出：
	  ["f_RENareaThrow"] = "",
	  ["f_renareathrow"] = "“仁”区机制",
	  ["@f_RENareaThrow-card"] = "请将溢出的“仁”弃置",
	  ["~f_RENareaThrow"] = "弃至六张",
	  --疗疫
	["f_liaoyi"] = "疗疫",
	[":f_liaoyi"] = "其他角色的回合开始时，若其手牌数：小于体力值，你可令其获得X张“仁”；大于体力值，你可令其将X张牌置为“仁”。（X为其手牌数与体力值之差且至多为4）",
	["f_liaoyiGive"] = "",
	["@f_liaoyi-card"] = "请将“仁”中要求数量的牌交给该角色",
	["~f_liaoyi"] = "选够要求数量的“仁”后，点【确定】",
	["f_liaoyiPut"] = "请选择要求数量的牌置入“仁”",
	["$f_liaoyi1"] = "麻黄之汤，或可疗伤寒之疫。",
	["$f_liaoyi2"] = "望闻问切，因病施治。",
	  --病论
	["f_binglun"] = "病论",
	["f_binglunRecover"] = "病论",
	[":f_binglun"] = "出牌阶段限一次，你可以选择一名角色并弃置一张“仁”，其选择一项：1.摸一张牌；2.于其回合结束时回复1点体力。",
	["f_binglun:1"] = "摸一张牌",
	["f_binglun:2"] = "你回合结束时回复1点体力",
	["f_binglunREC"] = "病论回复",
	["$f_binglun1"] = "受病有深浅，使药有重轻。",
	["$f_binglun2"] = "三分需外治，七分靠内养。",
	  --阵亡
	["~zhangzhongjing_first"] = "得人不传，恐成坠绪......",
	
	--神关羽-海外服(手杀)
	["os_shenguanyu"] = "神關羽[手殺]-初版",
	["&os_shenguanyu"] = "神關羽",
	["#os_shenguanyu"] = "鬼神再臨",
	["designer:os_shenguanyu"] = "手殺海外服",
	["cv:os_shenguanyu"] = "奈何,官方",
	["illustrator:os_shenguanyu"] = "KayaK,紫髯的小乔",
	  --武神
	["oswushen"] = "武神",
	[":oswushen"] = "<font color='blue'><b>鎖定技，</b></font>你每階段使用的第一張【殺】不可被回應；你的红桃手牌視為【殺】；你使用红桃【殺】無距離和次數限制且額外指定所有擁有“夢魘”標記的角色為目標。",
	["$oswushen1"] = "武神現世，天下莫敵！",
	["$oswushen2"] = "戰意，化為青龍翺翔吧！",
	  --武魂
	["oswuhun"] = "武魂",
	["oswuhunDeath"] = "武魂",
	["oswuhundeath"] = "武魂",
	[":oswuhun"] = "<font color='blue'><b>鎖定技，</b></font>每當你受到1點傷害後，你令傷害來源獲得1枚“夢魘”標記；當你對有“夢魘”標記的角色造成傷害後，你令其獲得1枚“夢魘”標記。當你死亡時，你選擇是否進行判定，若進行判定且結果不為【桃】或【桃園結義】，你選擇至少一名擁有“夢魘”標記的角色，令這些角色各自依次失去等同於其擁有“夢魘”標記數的體力。",
	["EMeng"] = "夢魘",
	--[[["@oswuhunInvoke"] = "武魂:是否進行判定?",
	["@oswuhunInvoke:yes"] = "是",
	["@oswuhunInvoke:no"] = "否",]]
	["oswuhunDeathJudge"] = "[武魂]進行判定",
	["@oswuhunDeath-card"] = "請選擇至少一名擁有“夢魘”標記的角色，有機會讓其跟你下地獄",
	["~oswuhunDeath"] = "點擊你看ta不爽的可被選擇的角色，點【確定】",
	["$oswuhun1"] = "拿命來！", --受到伤害
	["$oswuhun2"] = "還不速速領死！", --造成伤害
	["$oswuhun3"] = "取汝狗頭，有如探囊取物！", --判定成功
	["$oswuhun4"] = "桃園之夢，再也不會回來了......", --判定失败
	  --阵亡
	["~os_shenguanyu"] = "吾一世英名，竟葬於小人之手！",
	
	--神吕蒙-海外服(手杀)
	["os_shenlvmeng"] = "神呂蒙[手殺]-初版",
	["&os_shenlvmeng"] = "神呂蒙",
	["#os_shenlvmeng"] = "聖光之國士",
	["designer:os_shenlvmeng"] = "手殺海外服",
	["cv:os_shenlvmeng"] = "极略三国",
	["illustrator:os_shenlvmeng"] = "KayaK,紫髯的小乔",
	  --涉獵
	["osshelie"] = "涉獵",
	[":osshelie"] = "摸牌階段，你可以改為亮出牌堆頂的五張牌，然後獲得其中每種花色的牌各一張。每輪限一次，回合結束時，若你本回合使用牌花色數不小於你的體力值，你選擇執行一個額外摸牌或出牌階段。",
	["osshelieSuits"] = "涉獵花色",
	["osshelie:1"] = "執行一個額外的摸牌階段",
	["osshelie:2"] = "執行一個額外的出牌階段",
	["$osshelie"] = "涉獵閱舊聞，暫使心魂澄。",
	  --攻心
	["osgongxin"] = "攻心",
	[":osgongxin"] = "<font color='green'><b>出牌階段限一次，</b></font>你可以觀看一名其他角色的手牌，然後你可以展示其中一張牌，選擇一項：1.棄置此牌；2.將此牌置於牌堆頂。若其手牌中花色數因此減少，你可以令其本回合無法使用或打出一種顏色的牌。",
	["osgongxin:discard"] = "棄置此牌",
	["osgongxin:put"] = "將此牌置於牌堆頂",
	["osgongxin:red"] = "令其本回合無法使用或打出紅色牌",
	["osgongxin:black"] = "令其本回合無法使用或打出黑色牌",
	["$osgongxin"] = "攻城為下，攻心為上。",
	  --阵亡
	["~os_shenlvmeng"] = "死去方知萬事空......",
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--==十周年神武将==--
	--神姜维(新杀)
	  --爆料版-->怒麟燎原
	["ty_shenjiangweiBN"] = "神姜维[十周年]-怒麟燎原", --爆料的技能描述有很模糊且逻辑不通的地方，根据自己的理解有所修（mo）改
	["&ty_shenjiangweiBN"] = "神姜维",
	["#ty_shenjiangweiBN"] = "怒麟燎原",
	["designer:ty_shenjiangweiBN"] = "官方",
	["cv:ty_shenjiangweiBN"] = "官方",
	["illustrator:ty_shenjiangweiBN"] = "魔奇士", --姜维皮肤：烽火乱世
	  --九伐
	["tyjiufaBN"] = "九伐",
	[":tyjiufaBN"] = "每当你使用九张不同牌名的牌后，你可以亮出牌堆顶的九张牌，你选择并获得其中点数<font color='red'><b>不同</b></font>的牌各一张，其余的牌置入弃牌堆。",
	["tyjiufaBNRecord"] = "九伐",
	["$tyjiufaBN1"] = "北定中原，光复汉室！",
	["$tyjiufaBN2"] = "北伐大计，不可废也！",
	  --天任
	["tytianrenBN"] = "天任",
	[":tytianrenBN"] = "锁定技，<font color='red'><b>每有一张基本牌或普通锦囊牌不因使用而进入弃牌堆后</b></font>，你获得1枚“天任”标记。当你的“天任”标记大于等于你的体力上限时，你移除等同于你当前体力上限值的“天任”标记然后增加1点体力上限并摸两张牌。",
	["$tytianrenBN1"] = "复我汉统，此志不渝！",
	["$tytianrenBN2"] = "大汉之光微微，我也要尽力而为！",
	  --平襄
	["typingxiangBN"] = "平襄",
	["typingxiangbn"] = "平襄",
	[":typingxiangBN"] = "限定技，出牌阶段，你减9点体力上限，然后对任意名其他角色造成共计9点伤害（你可以任意分配）。若如此做，你失去技能“九伐”。\
	<font color='blue'><b>◆操作提示：你选择的角色仅为你可以分配伤害的目标，并非必须分配有伤害。实际分配中，如果伤害已分配了9点，就是还有你选择的未分配伤害的角色将也不会再分配伤害。</b></font>",
	["@typingxiangBN"] = "平襄",
	["typingxiangBNTargets"] = "",
	["typingxiangBNLastDamageDbt"] = "",
	["typingxiangBNDamageDbt"] = "平襄：分配伤害",
	["typingxiangBNDMG"] = "",
	["typingxiangBNDamageDbt:0"] = "0点伤害",
	["typingxiangBNDamageDbt:1"] = "1点伤害",
	["typingxiangBNDamageDbt:2"] = "2点伤害",
	["typingxiangBNDamageDbt:3"] = "3点伤害",
	["typingxiangBNDamageDbt:4"] = "4点伤害",
	["typingxiangBNDamageDbt:5"] = "5点伤害",
	["typingxiangBNDamageDbt:6"] = "6点伤害",
	["typingxiangBNDamageDbt:7"] = "7点伤害",
	["typingxiangBNDamageDbt:8"] = "8点伤害",
	["typingxiangBNDamageDbt:9"] = "9点伤害",
	["$typingxiangBN1"] = "臣誓讨贼，以报国恩！",
	["$typingxiangBN2"] = "继往开来，重兴大汉之荣光！",
	  --阵亡
	["~ty_shenjiangweiBN"] = "汉室复兴，本就是一场梦吗？......",
	
	  --正式版-->界限突破
	["ty_shenjiangwei"] = "界·神姜维[十周年]",
	["&ty_shenjiangwei"] = "界神姜维",
	["#ty_shenjiangwei"] = "怒麟布武",
	["designer:ty_shenjiangwei"] = "官方,时光流逝FC",
	["cv:ty_shenjiangwei"] = "官方",
	["illustrator:ty_shenjiangwei"] = "匠人绘,紫髯的小乔",
	  --九伐
	["tyjiufa"] = "九伐",
	[":tyjiufa"] = "每当你使用或打出九张不同牌名的牌后，你可以亮出牌堆顶的九张牌，你选择并获得其中点数重复的牌各一张，其余的牌置入弃牌堆。",
	["tyjiufaRecord"] = "九伐",
	["$tyjiufa1"] = "九伐中原，以圆先帝遗志。",
	["$tyjiufa2"] = "日日砺剑，相报丞相厚恩。",
	["$tyjiufa3"] = "(皮肤“敕剑伏波”专属)担北伐重托，当兴复汉室，还于旧都。",
	["$tyjiufa4"] = "(皮肤“敕剑伏波”专属)任将军之职，应厉兵秣马，军出陇右。",
	  --天任
	["tytianren"] = "天任",
	[":tytianren"] = "锁定技，每有一张基本牌或普通锦囊牌不因使用而进入弃牌堆后，你获得1枚“天任”标记。当你的“天任”标记大于等于你的体力上限时，你移除等同于你当前体力上限值的“天任”标记然后增加1点体力上限并摸两张牌。",
	["$tytianren1"] = "举石补苍天，舍我更复其谁？",
	["$tytianren2"] = "天地同协力，何愁汉道不昌？",
	["$tytianren3"] = "(皮肤“敕剑伏波”专属)残兵盘据雄关险，独梁力支大厦倾！",
	["$tytianren4"] = "(皮肤“敕剑伏波”专属)雄关高岭壮英姿，一腔热血谱汉风！",
	  --平襄（界）
	["typingxiang"] = "平襄",
	["typingxiangFireSlash"] = "平襄",
	["typingxiangfireslash"] = "平襄",
	["typingxiangMaxCards"] = "平襄",
	--[":typingxiang"] = "限定技，出牌阶段，若你的体力上限大于9，你减9点体力上限，若如此做，你视为使用至多九张火【杀】（不计次）。然后你失去技能“九伐”且你的手牌上限改为你的体力上限。",
	[":typingxiang"] = "限定技，出牌阶段，你可以减<font color=\"#EA7500\"><b>至多X</b></font>点体力上限，若如此做，" ..
	"你视为使用<font color=\"#EA7500\"><b>至多为你以此法减去的体力上限值的张数</b></font>的火【杀】（不计次）。" ..
	"然后你失去技能“九伐”且你的手牌上限改为你的体力上限。（X为你的体力上限-1且至多为9）",
	["@typingxiang"] = "平襄",
	["typingxiang:1"] = "减【1】点体力上限，视为使用至多【1】张火杀",
	["typingxiang:2"] = "减【2】点体力上限，视为使用至多【2】张火杀",
	["typingxiang:3"] = "减【3】点体力上限，视为使用至多【3】张火杀",
	["typingxiang:4"] = "减【4】点体力上限，视为使用至多【4】张火杀",
	["typingxiang:5"] = "减【5】点体力上限，视为使用至多【5】张火杀",
	["typingxiang:6"] = "减【6】点体力上限，视为使用至多【6】张火杀",
	["typingxiang:7"] = "减【7】点体力上限，视为使用至多【7】张火杀",
	["typingxiang:8"] = "减【8】点体力上限，视为使用至多【8】张火杀",
	["typingxiang:9"] = "减【9】点体力上限，视为使用至多【9】张火杀",
	["@typingxiangFireSlash"] = "你可以视为使用一张火【杀】",
	["~typingxiangFireSlash"] = "选择你想砍的可被选择的角色，点【确定】；若点【取消】视为你中止“平襄”火【杀】的持续使用",
	["$typingxiang1"] = "策马纵慷慨，捐躯抗虎豺！",
	["$typingxiang2"] = "解甲事仇雠，竭力挽狂澜！",
	["$typingxiang3"] = "(皮肤“敕剑伏波”专属)此身独继隆中志，功成再拜五丈原！",
	["$typingxiang4"] = "(皮肤“敕剑伏波”专属)平北襄乱之心，纵身加斧钺，亦不改半分！",
	  --阵亡
	["~ty_shenjiangwei"] = "武侯遗志，已成泡影矣.........",
	
	--神马超(新杀)
	["ty_shenmachao"] = "神马超[十周年]",
	["&ty_shenmachao"] = "神马超",
	["#ty_shenmachao"] = "神威天将军",
	["designer:ty_shenmachao"] = "官方",
	["cv:ty_shenmachao"] = "官方",
	["illustrator:ty_shenmachao"] = "君桓文化",
	  --狩骊（真·猎马）
	["tyshouliGMS"] = "狩骊",
	["tyshouli"] = "狩骊",
	["tyshoulii"] = "狩骊",
	["tyshouliTrigger"] = "狩骊",
	["tyshouliSlash"] = "狩骊",
	["tyshoulislash"] = "狩骊-使用[杀]",
	["tyshouliSlashed"] = "狩骊",
	["tyshoulislashed"] = "狩骊-打出[杀]",
	["tyshouliJink"] = "狩骊",
	["tyshoulijink"] = "狩骊-使用/打出[闪]",
	["tyshouliBuffANDClear"] = "狩骊",
	[":tyshouli"] = "锁定技，游戏开始时，从下家开始所有角色依次从牌堆中随机使用一张坐骑牌直到牌堆中没有坐骑牌。当你需要使用或打出【杀】/【闪】时，你可获得场上的一张进攻马/防御马，并立即将该牌当做【杀】（不计次）/【闪】使用或打出"..
	"<font color='red'><b>（特别注意！你需要确保你能将此牌当【杀】/【闪】使用出去，以免影响后续游戏的进程）</b></font>，且获得此牌时，失去该坐骑的角色本回合非锁定技失效，你与失去该坐骑的角色本回合受到的伤害+1且改为雷电伤害。",
	["tyshouli_OT"] = "请选择一名装备区里有进攻马的角色",
	["tyshouli_DT"] = "请选择一名装备区里有防御马的角色",
	["@tyshouli_useSlash"] = "请将你猎的这匹进攻马当【杀】使用",
	["@tyshouli_respSlash"] = "请将你猎的这匹进攻马当【杀】打出",
	["@tyshouli_useJink"] = "请将你猎的这匹防御马当【闪】使用或打出",
	["$tyshouliMoreDamage"] = "因为受到“<font color='yellow'><b>狩骊</b></font>”的影响，%to 受到的伤害 + %arg2",
	["$tyshouli1"] = "赤骊骋疆，巡狩八荒！", --送马；猎进攻马
	["$tyshouli2"] = "长缨在手，百骥可降！", --送马；猎防御马
	["$tyshouli3"] = "敢缚苍龙擒猛虎，一枪纵横定天山！", --用马当杀；触发增伤
	["$tyshouli4"] = "马踏祁连山河动，兵起玄黄奈何天！", --用马当闪；触发增伤
	  --横骛
	["tyhengwu"] = "横骛",
	[":tyhengwu"] = "当你使用或打出牌时，若你没有该花色的手牌，你可摸X张牌（X为场上与此牌花色相同的装备数量）。",
	["$tyhengwu1"] = "横枪立马，独啸秋风！",
	["$tyhengwu2"] = "世皆彳亍，唯我纵横！", --诸子百家......
	["$tyhengwu3"] = "雷部显圣，引赤电为翼，铸霹雳成枪！",
	["$tyhengwu4"] = "一骑破霄汉，饮马星河，醉卧广寒！",
	  --阵亡
	["~ty_shenmachao"] = "离群之马，虽强亦亡......", --七情难言，六欲难消，何谓之神......
	
	--神张飞(新杀)
	["ty_shenzhangfei"] = "神张飞[十周年]",
	["&ty_shenzhangfei"] = "神张飞",
	["#ty_shenzhangfei"] = "两界大巡环使",
	["designer:ty_shenzhangfei"] = "官方",
	["cv:ty_shenzhangfei"] = "官方",
	["illustrator:ty_shenzhangfei"] = "荧光笔工作室,紫髯的小乔",
	  --神裁
	["tyshencai"] = "神裁",
	["tyshencaiClear"] = "神裁",
	["tyshencai_CHI"] = "神裁",
	["tyshencai_ZHANG"] = "神裁",
	["tyshencai_TU"] = "神裁",
	["tyshencai_LIU"] = "神裁",
	["tyshencai_DIE"] = "神裁",
	["tyshencai_DYING"] = "神裁",
	[":tyshencai"] = "<font color='green'><b>出牌阶段限X次（X初始为1且至多为5），</b></font>你可以令一名其他角色进行判定且你获得此判定牌。若此判定牌包含以下内容，其获得（已有“神裁”相关标记(不包括“死”标记)则改为修改）对应标记：\
	<font color='green'><b>体力：“笞”标记，每次受到伤害后失去等量体力</b></font><font color='red'><b>(范围:桃,酒,桃园结义,白银狮子;护心镜)</b></font>；\
	<font color='blue'><b>武器：“杖”标记，无法响应【杀】</b></font><font color='red'><b>(范围:武器牌,借刀杀人)</b></font>；\
	<font color='purple'><b>打出：“徒”标记，以此法外失去手牌后随机弃置一张手牌</b></font><font color='red'><b>(范围:南蛮入侵,万箭齐发,决斗,丈八蛇矛,银月枪,八卦阵;随机应变)</b></font>；\
	<font color='orange'><b>距离：“流”标记，结束阶段将武将牌翻面</b></font><font color='red'><b>(范围:顺手牵羊,兵粮寸断,马;逐近弃远)</b></font>；\
	若判定牌不包含以上内容，该角色获得1枚“死”标记且手牌上限-Y（Y为其拥有的“死”标记数），然后你获得其区域内的一张牌。“死”标记数大于场上存活人数的角色回合结束时，其立即被宣判死亡。",
	["tyscCHI"] = "笞",
	["tyscZHANG"] = "杖",
	["tyscTU"] = "徒",
	["tyscLIU"] = "流",
	["tyscDIE"] = "死",
	["$tyshencai_CHI"] = "<font color='green'><b>笞</b></font> 标记生效，%to 将会失去 %arg2 点体力",
	["$tyshencai_ZHANG"] = "<font color='blue'><b>杖</b></font> 标记生效，%to 无法响应 %from 的 %card",
	["$tyshencai_TU"] = "<font color='purple'><b>徒</b></font> 标记生效，%to 的随机一张手牌将被弃置",
	["$tyshencai_LIU"] = "<font color='orange'><b>流</b></font> 标记生效，%to 将会翻面",
	["$tyshencai_DIE"] = "%to 的 <font color='red'><b>死</b></font> 标记数达到 %arg2 枚，已超过场上存活人数 %arg3 人，将会被宣判死亡",
	["$tyshencai1"] = "我有三千炼狱，待汝万世轮回！",
	["$tyshencai2"] = "纵汝王侯将相，亦须俯首待裁！",
	["$tyshencai3"] = "汝罪之大，似彻天之山、盈渊之海！",
	["$tyshencai4"] = "生犯贪嗔痴戾疑，死受鞭笞斧灼烹！",
	  --巡使
	["tyxunshi"] = "巡使",
	["tyxunshiExtreme"] = "巡使",
	["tyxunshiSCLevelUp"] = "巡使",
	[":tyxunshi"] = "锁定技，你的多目标锦囊牌均视为无色【杀】，你使用无色牌无距离、次数、指定目标数限制，且使用时，本局“神裁”X+1。",
	["tyshencaiAdd"] = "神裁次数+",
	["$tyxunshi1"] = "秉身为正，辟易万邪！",
	["$tyxunshi2"] = "巡御两界，路寻不平！",
	["$tyxunshi3"] = "此间不明我明之，此事不平我平之！",
	["$tyxunshi4"] = "长车琳、铁架铮，桓侯既至百冤明！",
	  --语音隐藏彩蛋
	["tyszfAudioCD"] = "神张飞语音隐藏彩蛋",
	["$tyszfAudioCD1"] = "俺颇有家资！", --隐藏语音彩蛋1（正常使用【五谷丰登】）
	["$tyszfAudioCD2"] = "俺也一样！", --隐藏语音彩蛋2（与他人拼点点数相同）
	  --阵亡
	["~ty_shenzhangfei"] = "尔等欲复斩我头乎？......", --愿舍神冕入轮回，与吾兄再结金兰......
	
	--神张角(新杀)
	["ty_shenzhangjiao"] = "神张角[十周年]",
	["&ty_shenzhangjiao"] = "神张角",
	["#ty_shenzhangjiao"] = "末世的起首",
	["designer:ty_shenzhangjiao"] = "官方",
	["cv:ty_shenzhangjiao"] = "官方",
	["illustrator:ty_shenzhangjiao"] = "紫髯的小乔",
	  --异兆
    ["tyyizhao"] = "异兆",
    [":tyyizhao"] = "锁定技，你使用或打出一张牌后，获得等于此牌点数的“黄”标记。每次“黄”标记的十位数因此变化时，你获得牌堆中一张与变化后的“黄”标记的十位数点数相同的牌。",
	["tyHuang"] = "黄",
	["$tyyizhao1"] = "苍天已死，此黄天当立之时！",
	["$tyyizhao2"] = "甲子尚水，显炎汉将亡之兆！",
	["$tyyizhao3"] = "苍天离兮汉祚倾颓，逢甲子之岁可问道太平。",
	["$tyyizhao4"] = "紫薇离北七煞掠日，此天地欲复以吾为刍狗。",
	  --三首
    ["tysanshou"] = "三首",
    [":tysanshou"] = "当你受到伤害时，你可以亮出牌堆顶的三张牌，若其中有本回合没有使用过的牌的类型，则防止此伤害。",
	["$tysanshouPrevent"] = "%from 的“<font color='yellow'><b>三首</b></font>”生效，成功防止此伤害",
	["$tysanshou1"] = "三公既现，领大道而立黄天！",
	["$tysanshou2"] = "天地三才，载厚德已驱魍魉！",
	["$tysanshou3"] = "贫道所求之道，非富贵、非长生，唯愿天下太平。",
	["$tysanshou4"] = "诸君刀利，可斩百头万头，然可绝太平于人间否？",
	  --肆军
    ["tysijun"] = "肆军",
    [":tysijun"] = "准备阶段，若你的“黄”标记数大于牌堆的牌数，你可以移去所有“黄”标记<b>并洗牌*</b>，然后随机获得点数之和为36的牌。\
	<b>◆<font color=\"#E2DB18\">注：为保证不因洗牌代码导致平局，实际已改为伪洗牌代码，故无法与涉及到洗牌的武将产生联动。</font></b>",
	["$tysijun1"] = "联九州黎庶，撼一家之王庭！",
	["$tysijun2"] = "吾以此身为药，欲医天下之疾！",
	["$tysijun3"] = "苍天已被吾累末，且看黄天召太平！",
	["$tysijun4"] = "黄巾副首，连方数万，此击可撼百年之炎汉！",
	  --天劫
    ["tytianjie"] = "天劫",
    [":tytianjie"] = "每个回合结束时，若本回合牌堆洗过牌，你可以选择至多三名其他角色，对这些角色分别造成X点雷电伤害（X为其手牌中【闪】的数量且至少为1）。",
	["@tytianjie-card"] = "请选择至多三名其他角色，对他们造成伤害",
	["~tytianjie"] = "选中你要选择的角色，点【确定】",
	["$tytianjie1"] = "苍天既死，贫道当替天行道！",
	["$tytianjie2"] = "贫道张角，请大汉赴死！！！",
	["$tytianjie3"] = "雷池铸剑，今霜刃既成，当震天下于大白！",
	["$tytianjie4"] = "汝辈食民脂靡民膏，当受天劫而死！",
	  --隐藏彩蛋
	["shenzhangjiao_HTDL"] = "神张角隐藏彩蛋",
	  --阵亡
	["~ty_shenzhangjiao"] = "诸君唤我为贼，然我所窃何物？......", --书中皆记王侯事，青史不载人间民......
	
	--神邓艾(新杀)
	["ty_shendengai"] = "神邓艾[十周年]",
	["&ty_shendengai"] = "神邓艾",
	["#ty_shendengai"] = "带砺山河",
	["designer:ty_shendengai"] = "官方",
	["cv:ty_shendengai"] = "官方",
	["illustrator:ty_shendengai"] = "紫髯的小乔",
	  --拓域
    ["tytuoyu"] = "拓域",
	["tytuoyuACAbuff_ft"] = "拓域",
	["tytuoyuACAbuff_qq"] = "拓域",
	["tytuoyuACAbuff_js"] = "拓域",
    [":tytuoyu"] = "锁定技，你拥有三个未开发的手牌副区域：【<font color='orange'><b>丰田</b></font>】、【<font color='blue'><b>清渠</b></font>】、【<font color='green'><b>峻山</b></font>】。" ..
	"出牌阶段开始/结束时，你将手牌任意分配至已开发的手牌副区域中（每个手牌副区域至多容纳五张牌）。\
	每个手牌副区域内的手牌分别拥有相应效果：\
	【<font color='orange'><b>丰田</b></font>】：伤害值与回复值+1；\
	【<font color='blue'><b>清渠</b></font>】：无距离与次数限制；\
	【<font color='green'><b>峻山</b></font>】：不能被响应。\
	<font color='red'><b>▣注：(1)为兼容20221231版本，未引入卡牌文字标注。通过于出牌阶段或响应卡牌时<font color='green'><b>点击此按钮</b></font>，可查看各手牌副区域的情况。\
	(2)分配手牌至手牌副区域的过程中，若想中止此手牌副区域的分配，点【确定】即可。</b></font>",
	["tyty_Fengtian"] = "丰田",
	["@tyty_Fengtian"] = "丰田",
	["tyty_Qingqu"] = "清渠",
	["@tyty_Qingqu"] = "清渠",
	["tyty_Junshan"] = "峻山",
	["@tyty_Junshan"] = "峻山",
	["tytuoyu:tyty_Fengtian"] = "分配手牌至手牌副区域【丰田】",
	["tyty_PutToFengtian"] = "请选择一张牌，分配至手牌副区域【丰田】中（若想中止分配，点【取消】即可）",
	--["tyty_ptft"] = "拓域-丰田",
	--["@tyty_ptft"] = "请将至多五张未被分配的手牌分配至手牌副区域【丰田】中",
	--["~tyty_ptft"] = "亮着的手牌是可以分配的；若不分配直接点【取消】即可",
	["tytuoyu:tyty_Qingqu"] = "分配手牌至手牌副区域【清渠】",
	["tyty_PutToQingqu"] = "请选择一张牌，分配至手牌副区域【清渠】中（若想中止分配，点【取消】即可）",
	--["tyty_ptqq"] = "拓域-清渠",
	--["@tyty_ptqq"] = "请将至多五张未被分配的手牌分配至手牌副区域【清渠】中",
	--["~tyty_ptqq"] = "亮着的手牌是可以分配的；若不分配直接点【取消】即可",
	["tytuoyu:tyty_Junshan"] = "分配手牌至手牌副区域【峻山】",
	["tyty_PutToJunshan"] = "请选择一张牌，分配至手牌副区域【峻山】中（若想中止分配，点【取消】即可）",
	--["tyty_ptjs"] = "拓域-峻山",
	--["@tyty_ptjs"] = "请将至多五张未被分配的手牌分配至手牌副区域【峻山】中",
	--["~tyty_ptjs"] = "亮着的手牌是可以分配的；若不分配直接点【取消】即可",
	["tytuoyu:endput"] = "中止分配(注:请确定重新分配好了再点)",
	["see_tyty_Fengtian"] = "查看手牌副区域【丰田】",
	["tytuoyu_seeft"] = "拓域-查看[丰田]",
	["@tytuoyu_seeft"] = "请查看你的手牌副区域【丰田】中的所有手牌",
	["~tytuoyu_seeft"] = "亮着的即是位于此手牌副区域中；查看完毕，点【取消】即可",
	["see_tyty_Qingqu"] = "查看手牌副区域【清渠】",
	["tytuoyu_seeqq"] = "拓域-查看[清渠]",
	["@tytuoyu_seeqq"] = "请查看你的手牌副区域【清渠】中的所有手牌",
	["~tytuoyu_seeqq"] = "亮着的即是位于此手牌副区域中；查看完毕，点【取消】即可",
	["see_tyty_Junshan"] = "查看手牌副区域【峻山】",
	["tytuoyu_seejs"] = "拓域-查看[峻山]",
	["@tytuoyu_seejs"] = "请查看你的手牌副区域【峻山】中的所有手牌",
	["~tytuoyu_seejs"] = "亮着的即是位于此手牌副区域中；查看完毕，点【取消】即可",
	["$tytuoyuACAbuff_ft_dmg"] = "因为此 %card 来自于手牌副区域【<font color='orange'><b>丰田</b></font>】，此 %card 伤害值+1",
	["$tytuoyuACAbuff_ft_rec"] = "因为此 %card 来自于手牌副区域【<font color='orange'><b>丰田</b></font>】，此 %card 回复值+1",
	["$tytuoyuACAbuff_js"] = "因为此 %card 来自于手牌副区域【<font color='green'><b>峻山</b></font>】，此 %card 不能被响应",
	["$tytuoyu1"] = "本尊目之所及，皆为麾下王土！",
	["$tytuoyu2"] = "擎五丁之神力，碎万仞之高山！",
	["$tytuoyu3"] = "开疆拓土之心，岂群山可挡、大河可挠！",
	["$tytuoyu4"] = "我欲试剑天门，断彻天之岳、拓无垠之疆！",
	  --险进
    ["tyxianjin"] = "险进",
    [":tyxianjin"] = "锁定技，每当你分别造成或受到两次伤害后，你开发一个手牌副区域，摸X张牌（X为你已开发的手牌副区域数；若你的手牌数为全场<font color='red'><b>唯一</b></font>最多则X改为1）。",
	["tyxianjin_zs"] = "险进造伤",
	["tyxianjin_ss"] = "险进受伤",
	["tyxianjin:kfFengtian"] = "开发手牌副区域【丰田】",
	["tyxianjin:kfQingqu"] = "开发手牌副区域【清渠】",
	["tyxianjin:kfJunshan"] = "开发手牌副区域【峻山】",
	["$tyxianjin_kfFengtian"] = "%from 开发了手牌副区域【<font color='orange'><b>丰田</b></font>】",
	["$tyxianjin_kfQingqu"] = "%from 开发了手牌副区域【<font color='blue'><b>清渠</b></font>】",
	["$tyxianjin_kfJunshan"] = "%from 开发了手牌副区域【<font color='green'><b>峻山</b></font>】",
	["$tyxianjin1"] = "大风，大雨，大景！",
	["$tyxianjin2"] = "行役沙场，不战胜，则战死！",
	["$tyxianjin3"] = "彼方立于坚营深垒，非蹈险不可图之！",
	["$tyxianjin4"] = "大胜在前，纵身负斧钺，亦当仁不让！",
	  --奇径
    ["tyqijing"] = "奇径",
    [":tyqijing"] = "觉醒技，每个回合结束时，若你（“拓域”中提到）的三个手牌副区域均已开发，你减1点体力上限，将座次移至其他两名相邻角色之间，然后获得技能“摧心”并执行一个额外的回合。",
	["@tyqijing-nextalivechoice"] = "你将开始享受美妙的穿越之旅，请选择你旅途终点后的下家",
	["$tyqijing1"] = "今神兵于天降，贯奕世之长虹！",
	["$tyqijing2"] = "辟罗浮之险径，捣伪汉之黄龙！",
	["$tyqijing3"] = "控五行之力，擎越艮之梁，平无垠之堑！",
	["$tyqijing4"] = "区区蜀道，本尊履之如平地，何谓之难？",
	    --摧心
      ["qj_cuixin"] = "摧心",
      [":qj_cuixin"] = "当你不以此法对上家/下家使用的牌结算结束后，你可以视为对下家/上家再使用一次此牌。",
	  ["$qj_cuixin1"] = "今兵临城下，其王庭可摧！",
	  ["$qj_cuixin2"] = "四面皆奏楚歌，问汝降是不降？",
	  ["$qj_cuixin3"] = "今王师天降，尔孤城疲将，可有致胜之法？",
	  ["$qj_cuixin4"] = "匹夫窃金瓯之缺，还不速速俯首献降！",
	  --阵亡
	["~ty_shendengai"] = "灭蜀者，邓氏士载也！......", --大丈夫不能建功立业，其与豕鼠何异......
	
	--神典韦(新杀/魔改)
	["ty_shendianwei"] = "神典韦[十周年]-自改版",
	["&ty_shendianwei"] = "神典韦",
	["#ty_shendianwei"] = "襢裼暴虎",
	["designer:ty_shendianwei"] = "Walker(源自“飞鸿印雪”)",
	["cv:ty_shendianwei"] = "官方",
	["illustrator:ty_shendianwei"] = "君桓文化,紫髯的小乔",
	  --捐甲
    ["tyjuanjia"] = "捐甲",
	["tyjuanjiaGMS"] = "捐甲",
	["tyjuanjia_equiparea"] = "捐甲",
    [":tyjuanjia"] = "锁定技，游戏开始时，废除你的防具栏，然后你获得一个<font color='blue'><s>额外</s></font><font color='red'><b>特殊</b></font>的" ..
	"<font color='red'><b>(被称为“捐甲”的)</b></font>武器<font color='blue'><s>栏</s></font><font color='red'><b>区域</b></font>" ..
	"<font color='orange'><b>(用法:只能容纳一张武器牌,你视为装备置入该区域的武器牌;出牌阶段,你可以<font color='green'><b>点击武将头像左上角的“捐甲”按钮</b></font>," ..
	"选择手牌中的一张武器牌置入该区域(若该区域已有牌,则替代))</b></font>。",
	["@tyjuanjia_equiparea"] = "“捐甲”区",
	["$tyjuanjia_getJJea"] = "%from 获得了一个特殊的武器区域【<font color='yellow'><b>捐甲</b></font>】",
	[":tyjuanjia_equiparea"] = "出牌阶段，你可以<font color='green'><b>点击此按钮</b></font>，选择手牌中的一张武器牌置入“捐甲”区(若此区域已有牌，则替代)。",
	["$tyjuanjia1"] = "善攻者弃守，其提双刃，斩万敌！",
	["$tyjuanjia2"] = "舍衣事力，提兵驱敌！",
	  --挈挟
    ["tyqiexie"] = "挈挟",
	["tyqiexieRemover"] = "挈挟",
    [":tyqiexie"] = "锁定技，准备阶段，你在剩余武将牌堆中随机观看五张武将牌，然后依次选择其中<font color='blue'><s>任意张当武器牌置于你的装备区中</s></font>" ..
	"<font color='red'><b>总计X张牌(X为2.若你没有武器栏,X-1;若你没有“捐甲”区,X-1)，将对应的(被称为“挈挟”的)武器牌依次置入你的：1.武器栏；2.“捐甲”区</b></font>。" ..
	"以此法获得的“挈挟”武器牌拥有如下规则：\
	1.无花色与点数且攻击范围为武将牌上的体力上限<font color='red'><b>(至多为5)</b></font>；\
	2.武器效果为武将牌上描述中含有“【杀】”的无类型标签或仅有锁定技标签的技能；\
	3.此牌离开你的装备区<font color='red'><b>或“捐甲”区</b></font>时，你令其销毁。",
	--["tyqiexie_first"] = "挈挟1",
	--["tyqiexie_second"] = "挈挟2",
	--【挈挟】--
	--攻击范围1
	["_weapon_qiexie_one"] = "挈挟[1]",
	["WeaponQiexieOne"] = "挈挟[1]",
	["weaponqiexieone"] = "挈挟[1]",
	[":_weapon_qiexie_one"] = "装备牌·武器<br /><b>攻击范围</b>：１\
	<br /><b>武器技能</b>：\
	1.无花色与点数且攻击范围为对应因缘武将牌上的体力上限(至多为5)；\
	2.武器效果为对应因缘武将牌上描述中含有“【杀】”的：无类型标签或仅有锁定技标签的技能(新杀)/除觉醒技、限定技、转换技、主公技之外的技能(OL)；\
	3.离开装备区或“捐甲”区时销毁。",
	--攻击范围2
	["_weapon_qiexie_two"] = "挈挟[2]",
	["WeaponQiexieTwo"] = "挈挟[2]",
	["weaponqiexietwo"] = "挈挟[2]",
	[":_weapon_qiexie_two"] = "装备牌·武器<br /><b>攻击范围</b>：２\
	<br /><b>武器技能</b>：\
	1.无花色与点数且攻击范围为对应因缘武将牌上的体力上限(至多为5)；\
	2.武器效果为对应因缘武将牌上描述中含有“【杀】”的：无类型标签或仅有锁定技标签的技能(新杀)/除觉醒技、限定技、转换技、主公技之外的技能(OL)；\
	3.离开装备区或“捐甲”区时销毁。",
	--攻击范围3
	["_weapon_qiexie_three"] = "挈挟[3]",
	["WeaponQiexieThree"] = "挈挟[3]",
	["weaponqiexiethree"] = "挈挟[3]",
	[":_weapon_qiexie_three"] = "装备牌·武器<br /><b>攻击范围</b>：３\
	<br /><b>武器技能</b>：\
	1.无花色与点数且攻击范围为对应因缘武将牌上的体力上限(至多为5)；\
	2.武器效果为对应因缘武将牌上描述中含有“【杀】”的：无类型标签或仅有锁定技标签的技能(新杀)/除觉醒技、限定技、转换技、主公技之外的技能(OL)；\
	3.离开装备区或“捐甲”区时销毁。",
	--攻击范围4
	["_weapon_qiexie_four"] = "挈挟[4]",
	["WeaponQiexieFour"] = "挈挟[4]",
	["weaponqiexiefour"] = "挈挟[4]",
	[":_weapon_qiexie_four"] = "装备牌·武器<br /><b>攻击范围</b>：４\
	<br /><b>武器技能</b>：\
	1.无花色与点数且攻击范围为对应因缘武将牌上的体力上限(至多为5)；\
	2.武器效果为对应因缘武将牌上描述中含有“【杀】”的：无类型标签或仅有锁定技标签的技能(新杀)/除觉醒技、限定技、转换技、主公技之外的技能(OL)；\
	3.离开装备区或“捐甲”区时销毁。",
	--攻击范围5
	["_weapon_qiexie_five"] = "挈挟[5]",
	["WeaponQiexieFive"] = "挈挟[5]",
	["weaponqiexiefive"] = "挈挟[5]",
	[":_weapon_qiexie_five"] = "装备牌·武器<br /><b>攻击范围</b>：５\
	<br /><b>武器技能</b>：\
	1.无花色与点数且攻击范围为对应因缘武将牌上的体力上限(至多为5)；\
	2.武器效果为对应因缘武将牌上描述中含有“【杀】”的：无类型标签或仅有锁定技标签的技能(新杀)/除觉醒技、限定技、转换技、主公技之外的技能(OL)；\
	3.离开装备区或“捐甲”区时销毁。",
	-----
	["$tyqiexie1"] = "今挟双戟搏战，定护主公太平！",
	["$tyqiexie2"] = "吾乃典韦是也，谁敢向前？谁敢向前！",
	  --摧决
    ["tycuijue"] = "摧决",
    [":tycuijue"] = "<font color='green'><b>每个回合对每名角色限一次，</b></font>出牌阶段，你可以弃置一张牌，然后对一名在你攻击范围内且距离你最远的其他角色造成1点伤害。",
	["$tycuijue1"] = "当锋摧决，贯瑕洞坚！",
	["$tycuijue2"] = "殒身不恤，死战成仁！",
	  --阵亡
	["~ty_shendianwei"] = "战死沙场，快哉快哉！......",
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--==OL神武将==--
	--神曹丕(OL)
	["ol_shencaopi"] = "神曹丕[OL]",
	["&ol_shencaopi"] = "神曹丕",
    ["#ol_shencaopi"] = "大汉终结者",
    ["illustrator:ol_shencaopi"] = "鬼画符,紫髯的小乔",
	  --储元
    ["olchuyuan"] = "储元",
    ["powerful"] = "储",
    [":olchuyuan"] = "当一名角色受到伤害后，若你的“储”数小于你的体力上限，你可以令其摸一张牌，然后令其将一张手牌置于你的武将牌上，称为“储”。",
	["$olchuyuan1"] = "此役，我之胜。",
	["$olchuyuan2"] = "储君之位，囊中之物。",--"这些，都是孤赏赐给你的。",
	  --登极
    ["oldengji"] = "登极",
    [":oldengji"] = "觉醒技，准备阶段，若你的“储”数不小于3，你减1点体力上限并获得所有“储”，获得技能“界奸雄”和“天行”。",
	["$oldengji1"] = "登高位，享极乐。",
	["$oldengji2"] = "今日，便是我称帝之时。",
	    --天行
      ["oltianxing"] = "天行",
      [":oltianxing"] = "觉醒技，准备阶段，若你的“储”数不小于3，你减1点体力上限并获得所有“储”，失去技能“储元”，然后获得其中一个技能：“界仁德”、“界制衡”、“OL界乱击”。",
      ["$oltianxing1"] = "孤之行，天之意。",
      ["$oltianxing2"] = "我做的决定，便是天的旨意。",
	  --阵亡
    ["~ol_shencaopi"] = "曹魏锦绣，孤..还未看尽...",
	
	--神甄姬(OL)
	["ol_shenzhenji"] = "神甄姬[OL+欢乐杀强化]",
	["&ol_shenzhenji"] = "神甄姬",
    ["#ol_shenzhenji"] = "洛神赋",
    ["illustrator:ol_shenzhenji"] = "鬼画符,紫髯的小乔",
	  --神赋
    ["olshenfu"] = "神赋",
    ["olshenfu-invoke"] = "你可以发动“神赋”<br/> <b>操作提示</b>: 选择一名角色→点击确定<br/>",
    [":olshenfu"] = "结束阶段，若你的手牌数为：奇数，你可以对一名其他角色造成1点雷电伤害，然后若造成其死亡，你可重复此流程；偶数，你可以选择一名角色，<font color=\"#96943D\"><b>弃置其一张牌</b></font>或令其摸一张牌，然后若其手牌数等于其体力值，你可重复此流程（选择的角色不能重复）。<font color=\"#96943D\"><b>若如此做，你摸X张牌（X为你本回合发动此技能的次数且至多为5）。</b></font>",
	["olshenfu:discard"] = "弃置其一张牌",
	["olshenfu:draw"] = "令其摸一张牌",
	["$olshenfu1"] = "河洛之神，诗赋可抒。",
	["$olshenfu2"] = "云神鱼游，罗扇掩面。",
      --七弦
	["olqixian"] = "七弦",
	["olqixianMXC"] = "七弦",
    [":olqixian"] = "锁定技，你的手牌上限为7。<font color=\"#96943D\"><b>出牌阶段结束时，你可以将你的一张手牌置于武将牌上，回合结束后获得之。</b></font>",
	["LingSheJi"] = "灵蛇髻",
	["$olqixian1"] = "戴金翠之首饰，缀明珠以耀躯。",
	["$olqixian2"] = "践远游之文履，曳雾绡之轻裾。",
	  --飞凫
	["joyfeifu"] = "飞凫",
    [":joyfeifu"] = "<font color=\"#96943D\"><b>你可以将一张黑色牌当【闪】使用或打出。</b></font>",
	["$joyfeifu1"] = "妙丽善舞，佳人难寻。",
	["$joyfeifu2"] = "含辞未吐，气若幽兰。",
	  --阵亡
    ["~ol_shenzhenji"] = "众口烁金，难证吾清.......",
	
	--神孙权(OL)-测试版
	--[[["ol_shensunquan"] = "神孙权[OL]",
	["&ol_shensunquan"] = "神孙权",
    ["#ol_shensunquan"] = "东吴大帝",
	["designer:ol_shensunquan"] = "玄蝶",
	["cv:ol_shensunquan"] = "官方,大塚正子",
    ["illustrator:ol_shensunquan"] = "鬼画符",
	  --帝力
    ["oldili"] = "帝力",
    [":oldili"] = "锁定技，游戏开始时，你随机开启一条“<font color=\"#4DB873\"><b>东吴命运线</b></font>”。",
	------
	["oldiliShengZhi"] = "命运线:圣质",
	[":&oldiliShengZhi"] = "若你获得过“英魂”、“弘德”、“界秉壹”，你点数为质数的牌不能被响应",
	["oldiliChiGang"] = "命运线:持纲",
	[":&oldiliChiGang"] = "若你获得过“观微”、“弼政”、“新安国”，你的判定阶段改为摸牌阶段",
	["oldiliQiongLan"] = "命运线:穹览",
	[":&oldiliQiongLan"] = "若你获得过“涉猎”、“问卦”、“博图”，你随机开启其他两条命运线",
	["oldiliQuanDao"] = "命运线:权道",
	[":&oldiliQuanDao"] = "若你获得过“界制衡”、“诫训”、“手杀界安恤”，你点数为字母的手牌视为【调剂盐梅】",
	["oldiliJiaoHui"] = "命运线:交辉",
	[":&oldiliJiaoHui"] = "若你获得过“下书”、“界结姻”、“OL界缔盟”，你最后一张手牌视为【远交近攻】",
	["oldiliYuanLv"] = "命运线:渊虑",
	[":&oldiliYuanLv"] = "若你获得过“观潮”、“决堰”、“澜疆”，你于之后使用的装备牌视为【长安大舰】",
	------
	["ShengZhiACT"] = "圣质已激活",
	[":&ShengZhiACT"] = "你点数为质数的牌不能被响应",
	["ChiGangACT"] = "持纲已激活",
	[":&ChiGangACT"] = "你的判定阶段改为摸牌阶段",
	["QiongLanACT"] = "穹览已激活",
	[":&QiongLanACT"] = "你已随机开启其他两条命运线",
	["QuanDaoACT"] = "权道已激活",
	[":&QuanDaoACT"] = "你点数为字母的手牌视为【调剂盐梅】",
	["JiaoHuiACT"] = "交辉已激活",
	[":&JiaoHuiACT"] = "你最后一张手牌视为【远交近攻】",
	["YuanLvACT"] = "渊虑已激活",
	[":&YuanLvACT"] = "你使用的装备牌视为【长安大舰】",
	------
	["$oldili1"] = "身处巅峰，揽天下大事。",
	["$oldili2"] = "位居至尊，掌至高之权。",
	["$oldili3"] = "（三国志12BGM：吴之主题曲）",
      --驭衡
	["olyuheng"] = "驭衡",
    --[":olyuheng"] = "出牌阶段限一次，你可以失去其他非锁定技并随机获得任意<font color=\"#4DB873\"><b>东吴命运线</b></font>提及的一个技能，且若你本阶段未发动过其他非锁定技，你随机获得你当前<font color=\"#4DB873\"><b>东吴命运线</b></font>提及的一个技能。出牌阶段结束时，若你于本阶段未发动过“驭衡”，你失去1点体力。",
	[":olyuheng"] = "出牌阶段限一次，你可以失去其他非锁定技并随机获得任意<font color=\"#4DB873\"><b>东吴命运线</b></font>提及的一个技能，然后你随机获得你当前<font color=\"#4DB873\"><b>东吴命运线</b></font>提及的一个技能（若随机到重复技能，不可重复获得）。出牌阶段结束时，若你于本阶段未发动过“驭衡”，你失去1点体力。",
	["$olyuheng1"] = "权术妙用，存乎异心。",
	["$olyuheng2"] = "维权之道，皆在于衡。",
	------东吴命运线------
	["DongWu_fatelines"] = "东吴命运线",
	[":DongWu_fatelines"] = "东吴命运线：\
	圣质：锁定技，若你获得过“英魂”、“弘德”、“界秉壹”，你点数为质数的牌(2,3,5,7,J,K)不能被响应。\
	持纲：锁定技，若你获得过“观微”、“弼政”、“新安国”，你的判定阶段改为摸牌阶段。\
	穹览：锁定技，若你获得过“涉猎”、“问卦”、“博图”，你随机开启其他两条命运线。\
	权道：锁定技，若你获得过“界制衡”、“诫训”、“手杀界安恤”，你点数为字母的手牌视为【调剂盐梅】。\
	交辉：锁定技，若你获得过“下书”、“界结姻”、“OL界缔盟”，你最后一张手牌视为【远交近攻】。\
	渊虑：锁定技，若你获得过“观潮”、“决堰”、“澜疆”，你于之后使用的装备牌视为【长安大舰】。",
	  --圣质
	["dl_shengzhi"] = "圣质",
	[":dl_shengzhi"] = "锁定技，若你获得过“英魂”、“弘德”、“界秉壹”，你点数为质数的牌(2,3,5,7,J,K)不能被响应。",
	["$dl_shengzhi1"] = "为继父兄，程弘德以继往。",
	["$dl_shengzhi2"] = "英魂犹在，吕宫夜而开来。",
	  --持纲
	["dl_chigang"] = "持纲",
	[":dl_chigang"] = "锁定技，若你获得过“观微”、“弼政”、“新安国”，你的判定阶段改为摸牌阶段。",
	["$dl_chigang1"] = "秉承伦长，扶树刚济。",
	["$dl_chigang2"] = "至尊临位，则朝野自诉。",
	  --穹览
	["dl_qionglan"] = "穹览",
	[":dl_qionglan"] = "锁定技，若你获得过“涉猎”、“问卦”、“博图”，你随机开启其他两条命运线。",
	["$dl_qionglan1"] = "事无巨细，闲尽问寻。",
	["$dl_qionglan2"] = "纵览全局，以小见大。",
	  --权道
	["dl_quandao"] = "权道",
	[":dl_quandao"] = "锁定技，若你获得过“界制衡”、“诫训”、“手杀界安恤”，你点数为字母的手牌视为【调剂盐梅】。",
	["$dl_quandao1"] = "计策掌权，福令无快。",
	["$dl_quandao2"] = "以权御衡，谋定天下。",
	  --交辉
	["dl_jiaohui"] = "交辉",
	[":dl_jiaohui"] = "锁定技，若你获得过“下书”、“界结姻”、“OL界缔盟”，你最后一张手牌视为【远交近攻】。",
	["$dl_jiaohui1"] = "日月交辉，天下大白。",
	["$dl_jiaohui2"] = "雄鸡饮酒，声名百里。",
	  --渊虑
	["dl_yuanlv"] = "渊虑",
	[":dl_yuanlv"] = "锁定技，若你获得过“观潮”、“决堰”、“澜疆”，你于之后使用的装备牌视为【长安大舰】。",
	["$dl_yuanlv1"] = "临江而眺，静观江水东流。",
	["$dl_yuanlv2"] = "屹立山巅，笑看大江潮来。",
	----------------------
	    --普通单体锦囊:调剂盐梅
	  ["f_tiaojiyanmei"] = "调剂盐梅",
	  ["Ftiaojiyanmei"] = "调剂盐梅",
	  [":f_tiaojiyanmei"] = "锦囊牌\
	  <b>时机</b>：出牌阶段\
	  <b>目标</b>：两名手牌数不同的角色\
	  <b>效果</b>：出牌阶段，对两名手牌数不同的角色使用。其中手牌数较多的角色弃置一张牌，另一名手牌数较少的角色摸一张牌。",
	    --普通单体锦囊:远交近攻
	  ["f_yuanjiaojingong"] = "远交近攻",
	  ["Fyuanjiaojingong"] = "远交近攻",
	  [":f_yuanjiaojingong"] = "锦囊牌\
	  <b>时机</b>：出牌阶段\
	  <b>目标</b>：一名与你势力不同的角色\
	  <b>效果</b>：出牌阶段，对一名与你势力不同的角色使用。其摸一张牌，然后令你摸三张牌。",
	    --完全隐藏装备牌:长安大舰
		  --作为武器
	  ["CADJ_weapon"] = "长安大舰",
	  [":CADJ_weapon"] = "装备牌·武器<br /><b>攻击范围：</b>6<br /><b>武器效果：</b>锁定技，当你失去装备区里的此牌时，你还原之并选择场上的一张牌，若此牌点数为字母，你获得之，否则弃置之。",
	      --作为防具
	  ["CADJ_armor"] = "长安大舰",
	  [":CADJ_armor"] = "装备牌·防具<br /><b>防具效果：</b>锁定技，当你失去装备区里的此牌时，你还原之，回复1点体力并选择场上的一张牌，若此牌点数为字母，你获得之，否则弃置之。",
	      --作为防御马
	  ["CADJ_defensivehorse"] = "长安大舰",
	  [":CADJ_defensivehorse"] = "装备牌·防御马[+2]<br /><b>坐骑效果：</b>锁定技，当你失去装备区里的此牌时，你还原之并选择场上的一张牌，若此牌点数为字母，你获得之，否则弃置之。",
	      --作为进攻马
	  ["CADJ_offensivehorse"] = "长安大舰",
	  [":CADJ_offensivehorse"] = "装备牌·进攻马[-2]<br /><b>坐骑效果：</b>锁定技，当你失去装备区里的此牌时，你还原之并选择场上的一张牌，若此牌点数为字母，你获得之，否则弃置之。",
	      --作为宝物
	  ["CADJ_treasure"] = "长安大舰",
	  [":CADJ_treasure"] = "装备牌·宝物<br /><b>宝物效果：</b>锁定技，你的手牌上限+2。当你失去装备区里的此牌时，你还原之并选择场上的一张牌，若此牌点数为字母，你获得之，否则弃置之。",
	  --阵亡
    ["~ol_shensunquan"] = "困居江东，妄称至尊......",]]
	--神孙权(OL)
	["ol_shensunquan"] = "神孙权[OL]",
	["&ol_shensunquan"] = "神孙权",
    ["#ol_shensunquan"] = "东吴大帝",
	["designer:ol_shensunquan"] = "官方",
	["cv:ol_shensunquan"] = "官方",
    ["illustrator:ol_shensunquan"] = "鬼画符,紫髯的小乔",
	  --驭衡
	["olyuheng"] = "驭衡",
	[":olyuheng"] = "锁定技，回合开始时，你弃置任意张花色各不相同的牌，随机获得等量吴势力角色的技能。回合结束时，你失去以此法获得的技能，摸等量的牌。",
	["@olyuheng-card"] = "请选择任意张花色各不相同的牌弃置",
	["~olyuheng"] = "弃置几张牌，就可以随机获得几个吴势力角色技能",
	["olyuhengSCL"] = "",
	["$olyuheng1"] = "权术妙用，存乎异心。",
	["$olyuheng2"] = "维权之道，皆在于衡。",
	  --帝力
	["oldili"] = "帝力",
	[":oldili"] = "觉醒技，当你的技能数超过体力上限后，你减1点体力上限，失去任意个其他技能并依次获得“圣质”、“权道”、“持纲”中的前等量个。",
	["oldili:end"] = "[中止]",
	["$oldili1"] = "身处巅峰，揽天下大事。",
	["$oldili2"] = "位居至尊，掌至高之权。",
	    --圣质
	  ["dl_shengzhi"] = "圣质",
	  ["dl_shengzhiNoLimit"] = "圣质",
	  [":dl_shengzhi"] = "锁定技，当你使用<font color='red'><b>“技能卡牌”</b></font>后，你本回合使用下一张牌无距离和次数限制。",
	  ["$dl_shengzhiNoLimit"] = "%from 的“<font color='yellow'><b>圣质</b></font>”被触发，其于本回合使用的下一张牌将无距离和次数限制",
	  ["$dl_shengzhi1"] = "为继父兄，程弘德以继往。",
	  ["$dl_shengzhi2"] = "英魂犹在，吕宫夜而开来。",
		--权道
	  ["dl_quandao"] = "权道",
	  ["dl_quandao_throwslash"] = "权道",
	  ["dl_quandao_throwNDtrick"] = "权道",
	  ["dl_quandao_throwndtrick"] = "权道",
	  [":dl_quandao"] = "锁定技，当你使用【杀】或普通锦囊牌时，你将手牌中两者的数量弃至相同并摸一张牌。",
	  ["dl_quandao-throw"] = "",
	  ["@dl_quandao_throwslash"] = "请弃置【杀】，保持手牌中【杀】的数量与普通锦囊牌相等",
	  ["@dl_quandao_throwNDtrick"] = "请弃置普通锦囊牌，保持手牌中普通锦囊牌的数量与【杀】相等",
	  ["$dl_quandao1"] = "计策掌权，福令无快。",
	  ["$dl_quandao2"] = "以权御衡，谋定天下。",
		--持纲
	  ["dl_chigang"] = "持纲",
	  [":dl_chigang"] = "转换技，锁定技，①你的判定阶段改为摸牌阶段；②你的判定阶段改为出牌阶段。",
	  [":dl_chigang1"] = "转换技，锁定技，①你的判定阶段改为摸牌阶段；<font color=\"#01A5AF\"><s>②你的判定阶段改为出牌阶段</s></font>。",
	  [":dl_chigang2"] = "转换技，锁定技，<font color=\"#01A5AF\"><s>①你的判定阶段改为摸牌阶段</s></font>；②你的判定阶段改为出牌阶段。",
	  ["$dl_chigang1"] = "秉承伦长，扶树刚济。",
	  ["$dl_chigang2"] = "至尊临位，则朝野自诉。",
	  --阵亡
    ["~ol_shensunquan"] = "困居江东，妄称至尊......",
	
	--神张角(OL)-->界限突破
	["ol_shenzhangjiao"] = "界·神张角[OL]",
	["&ol_shenzhangjiao"] = "界神张角",
	--["#ol_shenzhangjiao"] = "末世的起首",
	["#ol_shenzhangjiao"] = "闪电之王", --来源：OL公告自己写的XD
	["designer:ol_shenzhangjiao"] = "官方,时光流逝FC",
	["cv:ol_shenzhangjiao"] = "官方",
	["illustrator:ol_shenzhangjiao"] = "紫髯的小乔",
	  --异兆、天劫（同新杀）
	  --三首（界新增）
    ["olsanshou"] = "三首",
	["olsanshouCardUsed"] = "三首",
    [":olsanshou"] = "锁定技，<font color=\"#E2DB18\"><b>游戏开始时，你将【三首】置入你的装备区；当你失去装备区里的【三首】时，你摸三张牌。</b></font>",
	["$olsanshou1"] = "三公既现，领大道而立黄天！",
	["$olsanshou2"] = "天地三才，载厚德已驱魍魉！",
	["$olsanshou3"] = "贫道所求之道，非富贵、非长生，唯愿天下太平。",
	["$olsanshou4"] = "诸君刀利，可斩百头万头，然可绝太平于人间否？",
	--==防具·三首==--
	["ol_sanshou"] = "三首", --♦Q
	["OlSanshou"] = "三首",
	["OlSanshow"] = "三首",
	[":ol_sanshou"] = "装备牌·防具<br /><b>防具技能</b>：当你受到伤害时，你可以亮出牌堆顶的三张牌，若其中有本回合没有使用过的牌的类型，则防止此伤害。",
	  --肆军
    ["olsijun"] = "肆军",
    [":olsijun"] = "准备阶段，若你的“黄”标记数大于牌堆的牌数，你可以移去所有“黄”标记，然后随机获得点数之和为36的牌。",
	["$olsijun1"] = "联九州黎庶，撼一家之王庭！",
	["$olsijun2"] = "吾以此身为药，欲医天下之疾！",
	["$olsijun3"] = "苍天已被吾累末，且看黄天召太平！",
	["$olsijun4"] = "黄巾副首，连方数万，此击可撼百年之炎汉！",
	  --阵亡
    ["~ol_shenzhangjiao"] = "诸君唤我为贼，然我所窃何物？......", --书中皆记王侯事，青史不载人间民......
	
	--神典韦(OL/魔改)
	["onl_shendianwei"] = "神典韦[OL]-自改版",
	["&onl_shendianwei"] = "神典韦",
	["#onl_shendianwei"] = "冯陵猩衃",
	["designer:onl_shendianwei"] = "Walker(源自“飞鸿印雪”)",
	["cv:onl_shendianwei"] = "官方",
	["illustrator:onl_shendianwei"] = "君桓文化,紫髯的小乔",
	  --捐甲+摧决（同新杀）
	  --挈挟
    ["onlqiexie"] = "挈挟",
    [":onlqiexie"] = "锁定技，准备阶段，你在剩余武将牌堆中随机观看五张武将牌，然后依次选择其中<font color='blue'><s>任意张当武器牌置于你的装备区中</s></font>" ..
	"<font color='red'><b>总计X张牌(X为2.若你没有武器栏,X-1;若你没有“捐甲”区,X-1)，将对应的(被称为“挈挟”的)武器牌依次置入你的：1.武器栏；2.“捐甲”区</b></font>。" ..
	"以此法获得的“挈挟”武器牌拥有如下规则：\
	1.无花色与点数且攻击范围为武将牌上的体力上限<font color='red'><b>(至多为5)</b></font>；\
	2.武器效果为武将牌上描述中含有“【杀】”的的技能（觉醒技、限定技、转换技、主公技除外）；\
	3.此牌离开你的装备区<font color='red'><b>或“捐甲”区</b></font>时，你令其销毁。",
	--【挈挟】--（同新杀）
	["$onlqiexie1"] = "今挟双戟搏战，定护主公太平！",
	["$onlqiexie2"] = "吾乃典韦是也，谁敢向前？谁敢向前！",
	  --阵亡
    ["~onl_shendianwei"] = "战死沙场，快哉快哉！......",
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--==欢乐杀神武将==--
	--神关羽(欢乐杀)
	["joy_shenguanyu"] = "神关羽[欢乐杀]",
	["&joy_shenguanyu"] = "欢乐神关羽",
	["#joy_shenguanyu"] = "鬼神再临",
	["designer:joy_shenguanyu"] = "欢乐杀",
	["cv:joy_shenguanyu"] = "官方",
	["illustrator:joy_shenguanyu"] = "欢乐杀,紫髯的小乔",
	  --武神
	["joywushen"] = "武神",
	["joywushenBuffA"] = "武神",
	["joywushenBuffB"] = "武神",
	[":joywushen"] = "你可以将一张红桃手牌当【杀】使用或打出；你使用红桃【杀】无距离限制且伤害+1。",
	["$joywushen1"] = "还不速速领死！",
	["$joywushen2"] = "取汝狗头，犹如探囊取物！",
	  --武魂
	["joywuhun"] = "武魂",
	["joywuhunRevive"] = "武魂",
	[":joywuhun"] = "锁定技，当你受到1点伤害后，伤害来源获得1枚“梦魇”标记；当你脱离濒死状态或死亡时，你令“梦魇”标记最多的一名其他角色进行判定：" ..
	"若判定结果不为【桃】或【桃园结义】，其失去5点体力。",
	["@joyMY"] = "梦魇",
	["@joywuhun-revenge"] = "“武魂”触发，请选择“梦魇”标记最多的一名其他角色",
	["$joywuhun1"] = "谁来与我同去？",
	["$joywuhun2"] = "拿~命~来~！",
	  --阵亡
	["~joy_shenguanyu"] = "夙愿已了，魂归地府......",
	
	--神吕蒙(欢乐杀)
	["joy_shenlvmeng"] = "神吕蒙[欢乐杀]",
	["&joy_shenlvmeng"] = "欢乐神吕蒙",
	["#joy_shenlvmeng"] = "圣光之国士",
	["designer:joy_shenlvmeng"] = "欢乐杀",
	["cv:joy_shenlvmeng"] = "官方",
	["illustrator:joy_shenlvmeng"] = "欢乐杀,紫髯的小乔",
	  --涉猎
	["joyshelie"] = "涉猎",
	[":joyshelie"] = "锁定技，摸牌阶段，你改为亮出牌堆顶的五张牌，获得每种花色的牌各一张。",
	["$joyshelie1"] = "略懂，略懂。",
	["$joyshelie2"] = "什么都略懂一点儿，生活更多彩一些。",
	  --攻心
	["joygongxin"] = "攻心",
	["joygongxinClear"] = "攻心",
	[":joygongxin"] = "每个回合限一次，你对其他角色使用牌或其他角色使用牌指定你为唯一目标后，你可以观看对方的手牌，选择其中的一张红色牌获得之或置于牌堆顶。",
	["joygongxin:joygongxinTarget"] = "你是否对%src发动“攻心”？",
	["joygongxind"] = "已攻心",
	["joygongxin:get"] = "获得之",
	["joygongxin:put"] = "置于牌堆顶",
	["$joygongxin1"] = "我替施主把把脉。",
	["$joygongxin2"] = "攻城为下，攻心为上。",
	  --阵亡
	["~joy_shenlvmeng"] = "劫数难逃，我们别无选择......",
	
	--神周瑜(欢乐杀)
	["joy_shenzhouyu"] = "神周瑜[欢乐杀]",
	["&joy_shenzhouyu"] = "欢乐神周瑜",
	["#joy_shenzhouyu"] = "赤壁的火神",
	["designer:joy_shenzhouyu"] = "欢乐杀",
	["cv:joy_shenzhouyu"] = "官方",
	["illustrator:joy_shenzhouyu"] = "欢乐杀,紫髯的小乔",
	  --琴音
	["joyqinyin"] = "琴音",
	[":joyqinyin"] = "若你于弃牌阶段弃置有手牌，你可以令所有角色各回复或失去1点体力。",
	["joyqinyin:r"] = "所有角色各回复1点体力",
	["joyqinyin:l"] = "所有角色各失去1点体力",
	["$joyqinyin1"] = "（舒缓的琴声）",
	["$joyqinyin2"] = "（急促的琴声）",
	  --业炎
	["joyyeyan"] = "业炎",
	[":joyyeyan"] = "出牌阶段开始时，你可以对一名其他角色造成1点火焰伤害。",
	["$joyyeyan1"] = "聆听吧，这献给你的镇魂曲！",
	["$joyyeyan2"] = "让这熊熊业火，焚尽你的罪恶！",
	  --阵亡
	["~joy_shenzhouyu"] = "逝者不死，浴火重生......",
	
	--神诸葛亮(欢乐杀)
	["joy_shenzhugeliang"] = "神诸葛亮[欢乐杀]",
	["&joy_shenzhugeliang"] = "欢乐神诸葛",
	["#joy_shenzhugeliang"] = "赤壁的妖术师",
	["designer:joy_shenzhugeliang"] = "欢乐杀",
	["cv:joy_shenzhugeliang"] = "皮肤“赤壁唤风”",
	["illustrator:joy_shenzhugeliang"] = "欢乐杀,紫髯的小乔",
	  --七星（同原版）
	  --狂风
	["joykuangfeng"] = "狂风",
	[":joykuangfeng"] = "出牌阶段结束时，你可以移去任意张“星”，对等量的角色各造成1点伤害。",
	["@joykuangfeng-card"] = "你可以移去任意张“星”，对等量的角色各造成1点伤害",
	["~joykuangfeng"] = "选择任意张“星”，再选择等量的角色直到可以点【确定】",
	["$joykuangfeng1"] = "云从龙，风从虎！",
	["$joykuangfeng2"] = "风随吾意，变化无常！",
	  --大雾
	["joydawu"] = "大雾",
	[":joydawu"] = "结束阶段，你可以移去一张“星”，则直到你的下回合开始时，你受到的普通伤害-1。",
	["@joydawu"] = "大雾",
	["@joydawu-card"] = "你可以移去一张“星”，则直到你的下回合开始时你受到的普通伤害-1",
	["~joydawu"] = "选择一张“星”，点【确定】",
	["$joydawu_dmgdown"] = "由于“<font color=\"#00FFFF\"><b>大雾</b></font>”的保护效果，%from 此次受到的伤害由 %arg 点 减为了 %arg2 点",
	["$joydawu1"] = "天公助我，雾笼满江！",
	["$joydawu2"] = "虚实难测，莫敢来攻！",
	  --阵亡
	["~joy_shenzhugeliang"] = "七星灯灭，魂归九州......",
	
	--神孙权(欢乐杀)
	["joy_shensunquan"] = "神孙权[欢乐杀]",
	["&joy_shensunquan"] = "欢乐神孙权",
	["#joy_shensunquan"] = "英雄无觅",
	["designer:joy_shensunquan"] = "欢乐杀",
	["cv:joy_shensunquan"] = "官方,英雄杀",
	["illustrator:joy_shensunquan"] = "欢乐杀,紫髯的小乔",
	  --劝学
	["joyquanxue"] = "劝学", --你管这个叫劝学？这不是劝退！？
	["joyquanxueDeBuff"] = "劝学",
	[":joyquanxue"] = "出牌阶段开始时，你可以令至多两名其他角色各获得“学”标记，拥有“学”标记的角色于回合开始时移去此标记并选择一项：1.出牌阶段不能对除其之外的角色使用牌；2.失去1点体力。",
	["jStudy"] = "学",
	["@joyquanxue-card"] = "你可以选择至多两名其他角色，令他们获得“学”标记",
	["~joyquanxue"] = "请选择两位幸运儿进行劝退",
	["joyquanxue:1"] = "出牌阶段不能对其他角色使用牌",
	["joyquanxue:2"] = "失去1点体力",
	["joyquanxueDeBuff_CardLimited"] = "苦读",
	[":joyquanxueDeBuff_CardLimited"] = "锁定技，你出牌阶段不能对除你之外的角色使用牌。",
	["$joyquanxue1"] = "帝王权术，在于巧用朝野。",
	["$joyquanxue2"] = "天下事动，故要沉心思虑。",
	  --射虎
	["joyshehu"] = "射虎", --你是射虎还是射人啊？
	[":joyshehu"] = "锁定技，你对拥有“学”标记的角色使用【杀】时，弃置其一张手牌。",
	["$joyshehu"] = "亲射虎，看孙郎！", --暂无语音
	  --鼎立
	["joydingli"] = "鼎立",
	["joydingliSK"] = "鼎立",
	["joydinglisk"] = "鼎立",
	["joydingliskcard"] = "鼎立",
	[":joydingli"] = "每轮限一次，当其他角色移去“学”标记时，若其体力值：大于等于你，你可以回复1点体力；小于你，你可以摸等同于你与其体力值之差的牌（至多两张）。",
	["@joydingliSK-card"] = "你可以发动技能“鼎立”",
	["joydingliDraw"] = "",
	["joydingliUsed_lun"] = "",
	["$joydingli1"] = "凭长江之险而固守之。",
	["$joydingli2"] = "两汉四百载，分为魏蜀吴。",
	  --阵亡
	["~joy_shensunquan"] = "英雄志远，奈何坎坷难行......",
	
	--神张辽(欢乐杀)
	["joy_shenzhangliao"] = "神张辽[欢乐杀]",
	["&joy_shenzhangliao"] = "欢乐神张辽",
	["#joy_shenzhangliao"] = "逍遥威名",
	["designer:joy_shenzhangliao"] = "欢乐杀",
	["cv:joy_shenzhangliao"] = "官方",
	["illustrator:joy_shenzhangliao"] = "欢乐杀,紫髯的小乔",
	  --夺锐
	["joyduorui"] = "夺锐",
	[":joyduorui"] = "出牌阶段开始时，你可以观看一名其他角色的手牌并获得其中一张，本回合你使用该颜色的牌不能被其响应。",
	["joyduorui-invoke"] = "你可以选择一名有手牌的其他角色发动“夺锐”",
	["$joyduorui1"] = "八百虎贲踏江去，十万吴兵丧胆还！",
	["$joyduorui2"] = "虎啸逍遥震千里，江东碧眼犹梦惊！",
	  --止啼
	["joyzhiti"] = "止啼",
	["joyzhitiX"] = "止啼",
	[":joyzhiti"] = "锁定技，若已受伤角色数：大于1，你摸牌阶段摸牌数+1；大于2，你使用【杀】的次数上限+1。",
	["$joyzhiti1"] = "敌无心恋战，亦无力嚎哭乎！",
	["$joyzhiti2"] = "定叫吴儿，闻名止啼！",
	  --阵亡
	["~joy_shenzhangliao"] = "我也有被孙仲谋所伤之时！？",
	
	--神典韦(欢乐杀)
	["joy_shendianwei"] = "神典韦[欢乐杀]", --技能描述相较于欢乐杀在不改变原意的情况下有所改动
	["&joy_shendianwei"] = "欢乐神典韦",
	["#joy_shendianwei"] = "雄武壮烈",
	["designer:joy_shendianwei"] = "欢乐杀",
	["cv:joy_shendianwei"] = "官方",
	["illustrator:joy_shendianwei"] = "欢乐杀,紫髯的小乔",
	  --神卫
	["joyshenwei"] = "神卫",
	["joyshenweiMoveDamage"] = "神卫",
	[":joyshenwei"] = "回合开始时，你可以选择一名（若你的体力值为1，则改为至多两名）角色获得“卫”标记（每名角色至多1枚）；有“卫”标记的角色受到伤害时可以移除“卫”标记，然后你承受本次伤害。",
	["joyWEI"] = "卫",
	["@joyshenwei-card"] = "请选择没有“卫”标记的角色",
	["~joyshenwei"] = "若你体力值为1，可以选至多2名；否则可选1名",
	["@joyshenweiMoveDamage"] = "[神卫]转移伤害",
	["$joyshenwei1"] = "勇字当头，义字当先！",
	["$joyshenwei2"] = "铁戟双提八十斤，威风凛凛震乾坤！",
	  --恶来
	["joyelai"] = "恶来",
	[":joyelai"] = "锁定技，当场上的“卫”标记被移除时，你选择一项：1.回复1点体力；2.对你攻击范围内的一名其他角色造成1点伤害。",
	["joyelai:1"] = "回复1点体力",
	["joyelai:2"] = "对你攻击范围内的一名其他角色造成1点伤害",
	["joyelai_damage"] = "选择一名在你攻击范围内的角色，对其造成1点伤害",
	["$joyelai1"] = "吃我一戟！",
	["$joyelai2"] = "看我三步之内，取你小命！",
	  --狂袭
	["joykuangxi"] = "狂袭",
	[":joykuangxi"] = "锁定技，当场上有“卫”标记时，你造成的伤害+1。",
	["$joykuangxi_MoreDamage"] = "因为场上有“<font color='yellow'><b>卫</b></font>”标记存在，%from 造成的伤害+1",
	["$joykuangxi1"] = "口出狂言，汝命已结！",
	["$joykuangxi2"] = "我的双戟，可不是摆设！",
	  --阵亡
	["~joy_shendianwei"] = "主公！典韦来世，愿再追随！",
	
	--神华佗(欢乐杀)
	["joy_shenhuatuo"] = "神华佗[欢乐杀]",
	["&joy_shenhuatuo"] = "欢乐神华佗",
	["#joy_shenhuatuo"] = "不灭魔医",
	["designer:joy_shenhuatuo"] = "欢乐杀",
	["cv:joy_shenhuatuo"] = "官方",
	["illustrator:joy_shenhuatuo"] = "欢乐杀,紫髯的小乔",
	  --济世
	["joyjishi"] = "济世",
	["joyjishi_MaxCards"] = "济世",
	[":joyjishi"] = "游戏开始时，你获得3枚“药”标记（至多3枚）。当有角色进入濒死状态时，你可以弃置1枚“药”标记，令其回复至1点体力；当你于回合外失去红色手牌时，你获得等量的“药”标记。你的手牌上限+3。",
	["joyMedicine"] = "药",
	["$joyjishi1"] = "妙手仁心，药到病除！",
	["$joyjishi2"] = "救死扶伤，悬壶济世！",
	  --桃仙
	["joytaoxian"] = "桃仙",
	["joytaoxianDraw"] = "桃仙",
	[":joytaoxian"] = "你可以将一张红桃牌当【桃】使用；其他角色使用【桃】时，你摸一张牌。",
	["$joytaoxian1"] = "别紧张，有老夫呢。",
	["$joytaoxian2"] = "救人一命，胜造七级浮屠。",
	  --神针
	["joyshenzhen"] = "神针",
	[":joyshenzhen"] = "回合开始时，你可以弃置任意枚“药”标记，然后选择一项：1.令等量角色各回复1点体力；2.令等量角色各失去1点体力。",
	["@joyshenzhen-card"] = "选择不超过你“药”标记数量的角色，令他们回复或失去体力",
	["~joyshenzhen"] = "点击你想选择的不超过你“药”标记数量的角色，点【确定】",
	["joyshenzhen:1"] = "这些角色各回复1点体力",
	["joyshenzhen:2"] = "这些角色各失去1点体力",
	["$joyshenzhen1"] = "病入膏肓，需下猛药！",
	["$joyshenzhen2"] = "病去，如抽丝！",
	  --阵亡
	["~joy_shenhuatuo"] = "生老病死，命不可违......",
	
	--神貂蝉(欢乐杀)
	["joy_shendiaochan"] = "神貂蝉[欢乐杀]",
	["&joy_shendiaochan"] = "欢乐神貂蝉",
	["#joy_shendiaochan"] = "英雄难过",
	["designer:joy_shendiaochan"] = "欢乐杀",
	["cv:joy_shendiaochan"] = "欢乐杀",
	["illustrator:joy_shendiaochan"] = "欢乐杀,紫髯的小乔",
	  --魅魂
	["joymeihun"] = "魅魂",
	[":joymeihun"] = "结束阶段或当你每回合首次成为【杀】的目标后，你可以声明一种花色，令一名其他角色交给你该花色的所有牌，若其没有，则你观看其手牌并获得其中一张。",
	["$joymeihun_heart"] = "%from 声明了<font color='yellow'><b>[红桃<font color='red'><b>♥</b></font>]</b></font>花色",
	["$joymeihun_diamond"] = "%from 声明了<font color='yellow'><b>[方块<font color='red'><b>♦</b></font>]</b></font>花色",
	["$joymeihun_club"] = "%from 声明了<font color='yellow'><b>[梅花<font color='black'><b>♣</b></font>]</b></font>花色",
	["$joymeihun_spade"] = "%from 声明了<font color='yellow'><b>[黑桃<font color='black'><b>♠</b></font>]</b></font>花色",
	["$joymeihun1"] = "嗯~妾身就是喜欢这些，给我嘛~",
	["$joymeihun2"] = "这个和这个不要，其他全给我吧~",
	  --惑心
	["joyhuoxin"] = "惑心",
	["joyhuoxinMH"] = "惑心",
	[":joyhuoxin"] = "出牌阶段限一次，你可以弃置一张牌，令两名有手牌的角色拼点<font color='red'><b>(若点数相同,双方都算没赢)</b></font>，然后你可以声明一种花色，" ..
	"没赢的角色须交给你该花色的所有牌，否则其获得1枚该花色的“魅惑”标记。有“魅惑”标记的角色不能使用或打出此标记对应花色的牌；其回合结束时，移去所有“魅惑”标记。",
	["joyhuoxin:gh"] = "将你的所有【红桃♥】牌交给%src",
	["joyhuoxin:gd"] = "将你的所有【方块♦】牌交给%src",
	["joyhuoxin:gc"] = "将你的所有【梅花♣】牌交给%src",
	["joyhuoxin:gs"] = "将你的所有【黑桃♠】牌交给%src",
	["joyhuoxin:lh"] = "获得1枚“魅惑”标记（红桃）",
	["joyhuoxin:ld"] = "获得1枚“魅惑”标记（方块）",
	["joyhuoxin:lc"] = "获得1枚“魅惑”标记（梅花）",
	["joyhuoxin:ls"] = "获得1枚“魅惑”标记（黑桃）",
	["joyMeiHuo"] = "魅惑",
	["joyMeiHuo+heart"] = "魅惑红桃",
	["joyMeiHuo+diamond"] = "魅惑方块",
	["joyMeiHuo+club"] = "魅惑梅花",
	["joyMeiHuo+spade"] = "魅惑黑桃",
	["$joyhuoxin1"] = "哎呀，妾身能有什么坏心思呢？",
	["$joyhuoxin2"] = "一笑倾城，一眼惑心。",
	  --阵亡
	["~joy_shendiaochan"] = "纵使消逝，妾影长存......",
	
	--神-大乔&小乔(欢乐杀)
	["joy_shenerqiao"] = "神-大乔＆小乔[欢乐杀]",
	["&joy_shenerqiao"] = "欢乐神二乔",
	["#joy_shenerqiao"] = "双生之花",
	["designer:joy_shenerqiao"] = "欢乐杀",
	["cv:joy_shenerqiao"] = "官方",
	["illustrator:joy_shenerqiao"] = "欢乐杀,紫髯的小乔",
	  --双姝
	["joyshuangshu"] = "双姝",
	[":joyshuangshu"] = "准备阶段，你可以展示牌堆顶的两张牌，若其中：含方块牌，本回合“娉婷”可多选择一项；含红桃牌，本回合“移筝”可多选择一项；不含红色牌，你获得你展示的牌。",
	["$joy_shuangshu_pinting"] = "因为“<font color='yellow'><b>双姝</b></font>”的加成效果，本回合 %from 发动“<font color='yellow'><b>娉婷</b></font>”可多选择一项",
	["$joy_shuangshu_yizheng"] = "因为“<font color='yellow'><b>双姝</b></font>”的加成效果，本回合 %from 发动“<font color='yellow'><b>移筝</b></font>”可多选择一项",
	["$joyshuangshu1"] = "莞尔流年，光阴易逝。",
	["$joyshuangshu2"] = "将军，还是你来帮助我(们)吧~",
	  --娉婷
	["joypinting"] = "娉婷",
	["joypintings"] = "娉婷",
	["joypintingMD"] = "娉婷",
	[":joypinting"] = "出牌阶段开始时，你可以令你于此阶段使用的牌获得以下效果中的两项：\
	1.使用的第一张牌无距离限制；\
	2.使用的第二张牌指定目标后获得之；\
	3.使用的第三张牌于结算后摸两张牌；\
	4.使用的第四张牌额外结算一次。",
	["joypinting:1"] = "使用的第一张牌【无距离限制】",
	["joypinting:2"] = "使用的第二张牌【指定目标后获得之】",
	["joypinting:3"] = "使用的第三张牌【于结算后摸两张牌】",
	["joypinting:4"] = "使用的第四张牌【额外结算一次】",
	["joypintingFCU"] = "",
	["joypintingSCU"] = "",
	["joypintingTCU"] = "",
	["joypintingFTCU"] = "",
	["$joypinting1"] = "日星隐曜，双花耀世。",
	["$joypinting2"] = "星月流光，舞跃心间。",
	  --移筝
	["joyyizheng"] = "移筝",
	["joyyizhengd"] = "移筝",
	[":joyyizheng"] = "出牌阶段结束时，你可以移动场上的一张武器/防具/坐骑牌。若你以此法移动了：\
	1.一张牌，你回复1点体力；\
	2.两张牌，直到你的下回合开始，你失去一张牌就摸一张牌。",
	["joyyizheng:w"] = "移动场上的一张【武器牌】",
	["joyyizheng:a"] = "移动场上的一张【防具牌】",
	["joyyizheng:h"] = "移动场上的一张【坐骑牌】",
	["joyyizheng_movefrom"] = "请选择你要移动牌的来源角色",
	["joyyizheng_movehorse"] = "你想要抓走ta的哪匹马？",
	["joyyizheng_movehorse:df"] = "防御马",
	["joyyizheng_movehorse:of"] = "进攻马",
	["joyyizheng_moveto"] = "请选择【%src】移动的目标角色",
	["$joyyizheng1"] = "花香满径，足下生莲。",
	["$joyyizheng2"] = "清香袅袅，天色暖暖。",
	  --阵亡
	["~joy_shenerqiao"] = "来生，我们再做姐妹......",
	
	--孙悟空(欢乐杀)
	  --标准版
	["joy_sunwukong"] = "孙悟空[欢乐杀]",
	["&joy_sunwukong"] = "欢乐孙悟空",
	["#joy_sunwukong"] = "我命由我",
	["designer:joy_sunwukong"] = "欢乐杀",
	["cv:joy_sunwukong"] = "网络,王者荣耀[皮肤“齐天大圣”]",
	["illustrator:joy_sunwukong"] = "欢乐杀,紫髯的小乔",
	  --72变
	["joyseventytwo"] = "72变",
	[":joyseventytwo"] = "<font color='green'><b>每个回合每种类别的牌限一次，</b></font>出牌阶段，你可以按以下规则重铸牌：\
	基本牌->锦囊牌；锦囊牌->装备牌；装备牌->基本牌。",
	["$joyseventytwo1"] = "打遍三界棍无双，再战此界又何妨！",
	["$joyseventytwo2"] = "七十二般变化，可有机械这一变？",
	  --如意
	["joyruyi"] = "如意",
	[":joyruyi"] = "锁定技，若你的装备区里没有武器牌，你视为装备【如意金箍棒】<font color='red'><b>(初始攻击范围为1;鼠标悬停武将头像上的对应标记可以查看装备效果)</b></font>。",
	["$joyruyi1"] = "俺老孙来也！",
	["$joyruyi2"] = "呔！妖怪哪里跑！",
	  --齐天
	["joyqitian"] = "齐天",
	[":joyqitian"] = "觉醒技，当你的体力值为1时，你减1点体力上限，获得技能“火眼”、“筋斗云”。",
	["joyqitianAnimate"] = "image=image/animate/joyqitian.png",
	["$joyqitian1"] = "群妖又起，大圣重归！",
	["$joyqitian2"] = "往时管他谁是谁，今日方知我是我！",
	    --火眼
	  ["qt_huoyan"] = "火眼",
	  ["qt_huoyanTrigger"] = "火眼",
	  [":qt_huoyan"] = "锁定技，其他角色的手牌<font color='yellow'><b>/</b></font><font color='red'><b>始终</b></font><font color='yellow'><b>/</b></font>对你可见。\
	  --------\
	  <font color='blue'><b>◆伪实现(如果你不能鼠标右键查看已知牌)：\
	  1.出牌阶段可以随时<font color='green'><b>点击此按钮</b></font>选择其他角色查看其手牌；\
	  2.<font color='orange'><b>游戏开始时</b></font>以及<font color='green'><b>每个角色的回合开始时</b></font>，" ..
	  "你可以选择任意名其他角色，查看这些角色的手牌<font color='pink'>(留意文字信息播报界面)</font>；\
	  3.当你成为其他角色使用牌的目标时，你可以看见其所有手牌。</b></font>\
	  --------\
	  <font color='red'><b>◆真实现(如果你可以鼠标右键查看已知牌)：\
	  -->鼠标右键，点击“查看已知牌”，选择你要查看手牌的目标角色。</b></font>",
	  ["@qt_huoyan-toseeGMS"] = "【<font color='yellow'><b>游戏开始</b></font>】你可以选择任意名其他角色，查看他们的手牌",
	  ["@qt_huoyan-tosee"] = "你可以选择任意名其他角色，查看他们的手牌",
	  ["$qt_huoyan1"] = "哼！这年间，魑魅魍魉换了个样，牛鬼蛇神竟也称了霸王！", --神项羽：？怎么的，你有意见
	  ["$qt_huoyan2"] = "想过去三五步行遍天下，一转眼竟已是沧海桑田！",
	    --筋斗云
	  ["qt_jindouyun"] = "筋斗云",
	  [":qt_jindouyun"] = "锁定技，你与其他角色的距离-1；其他角色与你的距离+1。", --就是-1+1马，马术加飞影
	  ["$qt_jindouyun1"] = "",
	  ["$qt_jindouyun2"] = "",
	  --阵亡
	["~joy_sunwukong"] = "毁得钢铁躯，毁不得天地心......",
	  --==专属装备==--
	  --<如意金箍棒>--
	["joy_ruyijingubang"] = "如意金箍棒",
	["joy_ruyijingubang:1"] = "将攻击范围调整为【1】",
	["joy_ruyijingubang:2"] = "将攻击范围调整为【2】",
	["joy_ruyijingubang:3"] = "将攻击范围调整为【3】",
	["joy_ruyijingubang:4"] = "将攻击范围调整为【4】",
	["joy_ruyijingubang:5"] = "不调整攻击范围",
	[":joy_ruyijingubang"] = "装备牌·武器<br /><b>攻击范围</b>：１~４(初始为1)\
	<b>武器技能</b>：回合开始时，你可以调整此武器牌的攻击范围（1~4）。若此牌的攻击范围为：\
	1 你使用【杀】无次数限制；\
	2 你于回合内使用的首张【杀】造成的伤害+1；\
	3 你使用【杀】不能被响应；\
	4 你使用【杀】可以额外选择一个目标。",
	[":&joy_ruyijingubang"] = "装备牌·武器<br /><b>攻击范围</b>：１~４(初始为1)\
	<b>武器技能</b>：回合开始时，你可以调整此武器牌的攻击范围（1~4）。若此牌的攻击范围为：\
	1 你使用【杀】无次数限制；\
	2 你于回合内使用的首张【杀】造成的伤害+1；\
	3 你使用【杀】不能被响应；\
	4 你使用【杀】可以额外选择一个目标。",
	--攻击范围1：AK
	["__joy_ruyijingubang_one"] = "如意金箍棒[1]", --初始
	["JoyRuyijingubangOne"] = "如意金箍棒[1]",
	["joyruyiOne"] = "如意金箍棒[1]",
	[":__joy_ruyijingubang_one"] = "装备牌·武器<br /><b>攻击范围</b>：１\
	<br /><b>武器技能</b>：回合开始时，你可以调整此武器牌的攻击范围（1~4）。若此牌的攻击范围为：<br />\
	<font color='red'><b>1 你使用【杀】无次数限制；</b></font>\
	2 你于回合内使用的首张【杀】造成的伤害+1；\
	3 你使用【杀】不能被响应；\
	4 你使用【杀】可以额外选择一个目标。",
	--攻击范围2：加伤
	["__joy_ruyijingubang_two"] = "如意金箍棒[2]",
	["JoyRuyijingubangTwo"] = "如意金箍棒[2]",
	["joyruyiTwo"] = "如意金箍棒[2]",
	[":__joy_ruyijingubang_two"] = "装备牌·武器<br /><b>攻击范围</b>：２\
	<br /><b>武器技能</b>：回合开始时，你可以调整此武器牌的攻击范围（1~4）。若此牌的攻击范围为：<br />\
	1 你使用【杀】无次数限制；\
	<font color='red'><b>2 你于回合内使用的首张【杀】造成的伤害+1；</b></font>\
	3 你使用【杀】不能被响应；\
	4 你使用【杀】可以额外选择一个目标。",
	--攻击范围3：强命
	["__joy_ruyijingubang_three"] = "如意金箍棒[3]",
	["JoyRuyijingubangThree"] = "如意金箍棒[3]",
	["joyruyiThree"] = "如意金箍棒[3]",
	[":__joy_ruyijingubang_three"] = "装备牌·武器<br /><b>攻击范围</b>：３\
	<br /><b>武器技能</b>：回合开始时，你可以调整此武器牌的攻击范围（1~4）。若此牌的攻击范围为：<br />\
	1 你使用【杀】无次数限制；\
	2 你于回合内使用的首张【杀】造成的伤害+1；\
	<font color='red'><b>3 你使用【杀】不能被响应；</b></font>\
	4 你使用【杀】可以额外选择一个目标。",
	--攻击范围4：尿分叉
	["__joy_ruyijingubang_four"] = "如意金箍棒[4]",
	["JoyRuyijingubangFour"] = "如意金箍棒[4]",
	["joyruyiFour"] = "如意金箍棒[4]",
	[":__joy_ruyijingubang_four"] = "装备牌·武器<br /><b>攻击范围</b>：４\
	<br /><b>武器技能</b>：回合开始时，你可以调整此武器牌的攻击范围（1~4）。若此牌的攻击范围为：<br />\
	1 你使用【杀】无次数限制；\
	2 你于回合内使用的首张【杀】造成的伤害+1；\
	3 你使用【杀】不能被响应；\
	<font color='red'><b>4 你使用【杀】可以额外选择一个目标。</b></font>",
	  ----
	
	  --威力加强版
	["joy_sunwukongEX"] = "孙悟空[欢乐杀]-威力加强版",
	["&joy_sunwukongEX"] = "欢乐孙悟空",
	["#joy_sunwukongEX"] = "我命由我,不由天!",
	["designer:joy_sunwukongEX"] = "时光流逝FC",
	["cv:joy_sunwukongEX"] = "英雄联盟[皮肤“地狱行者”],DOTA2,戴荃",
	["illustrator:joy_sunwukongEX"] = "欢乐杀",
	  --72变
	["joyseventytwoEX"] = "72变",
	["joyseventytwoex"] = "72变",
	[":joyseventytwoEX"] = "<font color='green'><b>出牌阶段每种类别的牌限一次，</b></font>你可以将基本牌/锦囊牌/装备牌重铸为一种与之不同类别的牌（你可以选择重铸出来的类别）。",
	["joyseventytwoEX:rtBasic"] = "重铸为【基本牌】",
	["joyseventytwoEX:rtTrick"] = "重铸为【锦囊牌】",
	["joyseventytwoEX:rtEquip"] = "重铸为【装备牌】",
	["$joyseventytwoEX1"] = "中国有句老话，叫做：不打不相识！",
	["$joyseventytwoEX2"] = "芜~！湖呼呼呼呼呼呼~",
	  --筋斗云（同原版，但是从觉醒才能获得改为一开始就能获得）
	  --终极
	["joyruyiEX_zhongji"] = "终极",
	["joyruyiex_zhongji"] = "终极",
	["joyruyiEX_zhongjii"] = "终极",
	["joyruyiEX_zhongji_FireSlash"] = "终极-火属性[杀]",
	["joyruyiex_zhongji_fireslash"] = "终极-火属性[杀]",
	["joyruyiEX_zhongji_ThunderSlash"] = "终极-雷属性[杀]",
	["joyruyiex_zhongji_thunderslash"] = "终极-雷属性[杀]",
	["joyruyiEX_zhongji_IceSlash"] = "终极-冰属性[杀]",
	["joyruyiex_zhongji_iceslash"] = "终极-冰属性[杀]",
	["joyruyiEX_zhongji_NormalSlash"] = "终极-无属性[杀]",
	["joyruyiex_zhongji_normalslash"] = "终极-无属性[杀]",
	[":joyruyiEX_zhongji"] = "锁定技，若你的装备区里没有武器牌，你视为装备【终极金箍棒】<font color='red'><b>(初始攻击范围为4;鼠标悬停武将头像上的对应标记可以查看装备效果)</b></font>。" ..
	"出牌阶段限一次，你可以将一张装备牌当作无距离限制的属性【杀】（包括无属性）使用。",
	["joyruyiEX_zhongji:fire"] = "火属性【杀】",
	["joyruyiEX_zhongji:thunder"] = "雷属性【杀】",
	["joyruyiEX_zhongji:ice"] = "冰属性【杀】",
	["joyruyiEX_zhongji:none"] = "无属性【杀】",
	["@joyruyiEX_zhongji_FireSlash"] = "你可以将一张装备牌当作无距离限制的<font color='red'><b>火</b></font>【杀】使用",
	["@joyruyiEX_zhongji_ThunderSlash"] = "你可以将一张装备牌当作无距离限制的<font color='blue'><b>雷</b></font>【杀】使用",
	["@joyruyiEX_zhongji_IceSlash"] = "你可以将一张装备牌当作无距离限制的<font color=\"#00FFFF\"><b>冰</b></font>【杀】使用",
	["@joyruyiEX_zhongji_NormalSlash"] = "你可以将一张装备牌当作无距离限制的无属性【杀】使用",
	["$joyruyiEX_zhongji1"] = "领教下俺老孙的本事吧！",
	["$joyruyiEX_zhongji2"] = "吃俺老孙一棒！",
	  --齐天
	["joyqitianEX"] = "齐天", --与原版共用觉醒动画
	[":joyqitianEX"] = "觉醒技，当你的体力值不超过你体力上限的一半（向下取整）时，你减1点体力上限，选择回复至满体力或将手牌补至体力上限，获得技能“火眼”、“法象”。",
	["joyqitianEX:recover"] = "回复至满体力",
	["joyqitianEX:draw"] = "将手牌补至体力上限",
	["$joyqitianEX1"] = "俺的敌人以为火焰能把俺吞了，这只会让俺老孙更强！",
	["$joyqitianEX2"] = "长生不老前俺就天不怕地不怕，现在连神也要敬俺三分呢！",
	    --火眼（同原版）
	    --法象（法天象地）
	  ["qt_fatianxiangdi"] = "法象",
	  [":qt_fatianxiangdi"] = "<b>[大神通·法天象地]</b>限定技，出牌阶段，你将你的体力上限、体力值调整为所有其他角色的体力上限之和、体力值之和。" ..
	  "若如此做，你的下回合开始时，（无论你是否还有此技能）你将体力上限、体力值调整回发动此技能之前。",
	  ["@qt_fatianxiangdi"] = "法天象地",
	  ["qt_fatianxiangdii"] = "法天象地",
	  ["$qt_fatianxiangdiMaxHp"] = "%from 发动了“<font color='yellow'>[<b>大神通·法天象地</b>]</font>”，体力上限变为 %arg2",
	  ["$qt_fatianxiangdiHp"] = "%from 发动了“<font color='yellow'>[<b>大神通·法天象地</b>]</font>”，体力值变为 %arg2",
	  ["$qt_fatianxiangdi1"] = "善恶浮世真假界，尘缘散聚不分明，难断~！",
	  ["$qt_fatianxiangdi2"] = "我要，这铁棒醉舞魔；我有，这变化乱迷浊~！",
	  --阵亡
	["~joy_sunwukongEX"] = "踏碎凌霄，放肆桀骜；世恶道险，终究难逃......",
	  --==专属装备==--
	  --<终极金箍棒>--
	["joy_zjjingubang"] = "终极金箍棒",
	["joy_zjjingubang:1"] = "将攻击范围调整为【1】",
	["joy_zjjingubang:2"] = "将攻击范围调整为【2】",
	["joy_zjjingubang:3"] = "将攻击范围调整为【3】",
	["joy_zjjingubang:4"] = "将攻击范围调整为【4】",
	["joy_zjjingubang:5"] = "不调整攻击范围",
	[":joy_zjjingubang"] = "装备牌·武器<br /><b>攻击范围</b>：１~４(初始为4)\
	<b>武器技能</b>：回合开始时，你可以调整此武器牌的攻击范围（1~4）。若此牌的攻击范围为：\
	1 你使用【杀】无次数限制；\
	1/2 你于回合内使用的首张【杀】造成的伤害+1；\
	1/2/3 你使用【杀】不能被响应；\
	1/2/3/4 你使用【杀】可以额外选择一个目标。",
	[":&joy_zjjingubang"] = "装备牌·武器<br /><b>攻击范围</b>：１~４(初始为4)\
	<b>武器技能</b>：回合开始时，你可以调整此武器牌的攻击范围（1~4）。若此牌的攻击范围为：\
	1 你使用【杀】无次数限制；\
	1/2 你于回合内使用的首张【杀】造成的伤害+1；\
	1/2/3 你使用【杀】不能被响应；\
	1/2/3/4 你使用【杀】可以额外选择一个目标。",
	--攻击范围1：AK+加伤+强命+尿分叉
	["__joy_zjjingubang_one"] = "终极金箍棒[1]",
	["JoyZjjingubangOne"] = "终极金箍棒[1]",
	["JoyZjOne"] = "终极金箍棒[1]",
	[":__joy_zjjingubang_one"] = "装备牌·武器<br /><b>攻击范围</b>：１\
	<br /><b>武器技能</b>：回合开始时，你可以调整此武器牌的攻击范围（1~4）。若此牌的攻击范围为：<br />\
	<font color='red'><b>1 你使用【杀】无次数限制；</b></font>\
	<font color='red'><b>1/2 你于回合内使用的首张【杀】造成的伤害+1；</b></font>\
	<font color='red'><b>1/2/3 你使用【杀】不能被响应；</b></font>\
	<font color='red'><b>1/2/3/4 你使用【杀】可以额外选择一个目标。</b></font>",
	--攻击范围2：加伤+强命+尿分叉
	["__joy_zjjingubang_two"] = "终极金箍棒[2]",
	["JoyZjjingubangTwo"] = "终极金箍棒[2]",
	["JoyZjTwo"] = "终极金箍棒[2]",
	[":__joy_zjjingubang_two"] = "装备牌·武器<br /><b>攻击范围</b>：２\
	<br /><b>武器技能</b>：回合开始时，你可以调整此武器牌的攻击范围（1~4）。若此牌的攻击范围为：<br />\
	1 你使用【杀】无次数限制；\
	<font color='red'><b>1/2 你于回合内使用的首张【杀】造成的伤害+1；</b></font>\
	<font color='red'><b>1/2/3 你使用【杀】不能被响应；</b></font>\
	<font color='red'><b>1/2/3/4 你使用【杀】可以额外选择一个目标。</b></font>",
	--攻击范围3：强命+尿分叉
	["__joy_zjjingubang_three"] = "终极金箍棒[3]",
	["JoyZjjingubangThree"] = "终极金箍棒[3]",
	["JoyZjThree"] = "终极金箍棒[3]",
	[":__joy_zjjingubang_three"] = "装备牌·武器<br /><b>攻击范围</b>：３\
	<br /><b>武器技能</b>：回合开始时，你可以调整此武器牌的攻击范围（1~4）。若此牌的攻击范围为：<br />\
	1 你使用【杀】无次数限制；\
	1/2 你于回合内使用的首张【杀】造成的伤害+1；\
	<font color='red'><b>1/2/3 你使用【杀】不能被响应；</b></font>\
	<font color='red'><b>1/2/3/4 你使用【杀】可以额外选择一个目标。</b></font>",
	--攻击范围4：尿分叉
	["__joy_zjjingubang_four"] = "终极金箍棒[4]", --初始
	["JoyZjjingubangFour"] = "终极金箍棒[4]",
	["JoyZjFour"] = "终极金箍棒[4]",
	[":__joy_zjjingubang_four"] = "装备牌·武器<br /><b>攻击范围</b>：４\
	<br /><b>武器技能</b>：回合开始时，你可以调整此武器牌的攻击范围（1~4）。若此牌的攻击范围为：<br />\
	1 你使用【杀】无次数限制；\
	1/2 你于回合内使用的首张【杀】造成的伤害+1；\
	1/2/3 你使用【杀】不能被响应；\
	<font color='red'><b>1/2/3/4 你使用【杀】可以额外选择一个目标。</b></font>",
	  ----
	
	--嫦娥(欢乐杀)
	["joy_change"] = "嫦娥[欢乐杀]",
	["&joy_change"] = "欢乐嫦娥",
	["#joy_change"] = "广寒仙女",
	["designer:joy_change"] = "欢乐杀",
	["cv:joy_change"] = "欢乐杀",
	["illustrator:joy_change"] = "欢乐杀",
	  --捣药
	["joydaoyao"] = "捣药",
	[":joydaoyao"] = "出牌阶段限一次，你可以弃置一张手牌，然后从牌堆中获得一张【桃】并摸两张牌，若牌堆中没有【桃】则改为摸三张牌。",
	["$joydaoyao1"] = "（捣药声）入河蟾不没，捣药兔长生！",
	["$joydaoyao2"] = "（捣药声）转空轧軏冰轮响，捣药叮当玉杵鸣！",
	  --奔月
	["joybenyue"] = "奔月",
	["joybenyueRecover"] = "奔月",
	[":joybenyue"] = "觉醒技，当你于摸到【桃】后拥有三张及以上的【桃】，或本局累计回复体力值达到至少3点时，<font color='red'><b>(若你的体力上限小于15)</b></font>" ..
	"你将体力上限增加至15点，并获得技能“广寒”。\
	<font color='purple'>◆</font><font color='blue'><b>注：若嫦娥受到神郭嘉“辉逝”的增益，觉醒条件将变为：<font color='purple'>“当你摸到【桃】后，或回复体力时”</font></b></font>",
	["$joybenyue1"] = "纵令奔月成仙去，且作行云入梦来！",
	["$joybenyue2"] = "一入月宫去，千秋闭蛾眉！",
	    --广寒
	  ["by_guanghan"] = "广寒",
	  [":by_guanghan"] = "锁定技，当场上的任意一名角色受到伤害后，与其相邻的（不为“嫦娥”）的角色需弃置一张手牌，否则流失等量的体力。",
	  ["$by_guanghan1"] = "月宫清冷人独立，寒梦纷飞思绪深！",
	  ["$by_guanghan2"] = "银河无声月宫冷，思念如影伴孤灯！",
	  --阵亡
	["~joy_change"] = "（嫦娥应悔偷灵药，碧海青天夜夜心......）",
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--==小程序神武将==--
	--神关羽(小程序)
	["wx_shenguanyu"] = "神关羽[小程序]",
	["&wx_shenguanyu"] = "·神关羽",
	["#wx_shenguanyu"] = "鬼神再临",
	["designer:wx_shenguanyu"] = "三国杀微信小程序",
	["cv:wx_shenguanyu"] = "官方",
	["illustrator:wx_shenguanyu"] = "小程序精修",
	  --武神
	["wxwushen"] = "武神",
	["wxwushenBuff"] = "武神",
	[":wxwushen"] = "你可以将一张红色牌当【杀】使用或打出；你使用方块【杀】无距离限制、红桃【杀】无次数限制。",
	["$wxwushen1"] = "还不速速领死！",
	["$wxwushen2"] = "取汝狗头，犹如探囊取物！",
	  --阵亡
	["~wx_shenguanyu"] = "大师，我悟了......",
	
	--神吕蒙(小程序)
	["wx_shenlvmeng"] = "神吕蒙[小程序]",
	["&wx_shenlvmeng"] = "·神吕蒙",
	["#wx_shenlvmeng"] = "圣光之国士",
	["designer:wx_shenlvmeng"] = "三国杀微信小程序",
	["cv:wx_shenlvmeng"] = "官方",
	["illustrator:wx_shenlvmeng"] = "KayaK,紫髯的小乔",
	  --涉猎（同原版）
	  --攻心
	["wxgongxin"] = "攻心",
	[":wxgongxin"] = "出牌阶段限一次，你可以观看一名其他角色的手牌，然后你可以展示其中一张红色牌，获得此牌或将此牌置于牌堆顶。",
	["wxgongxin:get"] = "获得此牌",
	["wxgongxin:put"] = "将此牌置于牌堆顶",
	["$wxgongxin1"] = "我替施主把把脉。",
	["$wxgongxin2"] = "攻城为下，攻心为上。",
	  --阵亡
	["~wx_shenlvmeng"] = "劫数难逃，我们别无选择......",
	
	--神诸葛亮(小程序)
	  --原版
	["wx_shenzhugeliang"] = "神诸葛亮[小程序]",
	["&wx_shenzhugeliang"] = "·神诸葛亮",
	["#wx_shenzhugeliang"] = "赤壁的妖术师",
	["designer:wx_shenzhugeliang"] = "三国杀微信小程序",
	["cv:wx_shenzhugeliang"] = "官方",
	["illustrator:wx_shenzhugeliang"] = "小程序精修",
	  --七星
	["wxqixing"] = "七星",
	[":wxqixing"] = "每轮限一次，当你处于濒死状态时，你可以进行判定：若判定点数大于7，你回复1点体力。",
	["$wxqixing1"] = "斗转星移，七星借命！", --观星唤雨
	["$wxqixing2"] = "七星不灭，法力不绝！", --孟章诛邪
	  --祭风
	["wxjifeng"] = "祭风",
	[":wxjifeng"] = "出牌阶段限一次，你可以弃置一张手牌，从牌堆（若牌堆中没有，则改为弃牌堆）随机获得一张锦囊牌。",
	["$wxjifeng1"] = "东风生，旗幡动！", --剑祭通天
	["$wxjifeng2"] = "狂风起，江水腾！", --剑祭通天
	  --天罚
	["wxtianfa"] = "天罚",
	[":wxtianfa"] = "出牌阶段，你使用第偶数张锦囊牌时，你获得1枚“罚”标记（“罚”标记持续至回合结束）；回合结束时，你可以对至多X名其他角色各造成1点伤害（X为你的“罚”标记数）。",
	["wxFA"] = "罚",
	["@wxtianfa-card"] = "你可以对数量至多为你“罚”标记数的其他角色各造成1点伤害",
	["~wxtianfa"] = "执此神工，恭行天罚！",
	["$wxtianfa1"] = "星象为我控，七星握掌中！", --合纵破曹 --叠标记
	["$wxtianfa2"] = "七星八阵，敌军将困！", --孟章诛邪 --砸人
	  --阵亡
	["~wx_shenzhugeliang"] = "时也，命也......", --孟章诛邪
	
	  --威力加强版
	["wx_shenzhugeliangEX"] = "神诸葛亮[小程序]-威力加强版",
	["&wx_shenzhugeliangEX"] = "·神诸葛亮",
	["#wx_shenzhugeliangEX"] = "赤壁的大神",
	["designer:wx_shenzhugeliangEX"] = "时光流逝FC",
	["cv:wx_shenzhugeliangEX"] = "官方",
	["illustrator:wx_shenzhugeliangEX"] = "小程序精修",
	  --七星
	["wxqixingEX"] = "七星",
	[":wxqixingEX"] = "每轮限一次，当你处于濒死状态时，你可以进行判定：若判定点数大于7，你回复至1点体力。",
	["$wxqixingEX1"] = "斗转星移，七星借命！", --观星唤雨
	["$wxqixingEX2"] = "七星不灭，法力不绝！", --孟章诛邪
	  --祭风
	["wxjifengEX"] = "祭风",
	["wxjifengex"] = "祭风",
	["wxjifengEX_zuiandfa"] = "祭风",
	[":wxjifengEX"] = "<font color='green'><b>出牌阶段限X+1次，</b></font>你可以弃置一张手牌，从牌堆（若牌堆中没有，则改为弃牌堆）随机获得一张锦囊牌。" ..
	"（X为出牌阶段开始时你的“罪”标记数与“罚”标记数之和）",
	["wxjifengEX_add"] = "祭风次数+",
	["$wxjifengEX1"] = "东风生，旗幡动！", --剑祭通天
	["$wxjifengEX2"] = "狂风起，江水腾！", --剑祭通天
	  --天罪
	["wxtianzuiEX"] = "天罪",
	["wxtianzuiex"] = "天罪",
	[":wxtianzuiEX"] = "出牌阶段，你使用第奇数张锦囊牌时，你获得1枚“罪”标记（“罪”标记持续至下个出牌阶段开始时）；" ..
	"回合结束时，你可以弃置至多Y名其他角色各一张区域内的牌（Y为你的“罪”标记数）。",
	["exZUI"] = "罪",
	["@wxtianzuiEX-card"] = "你可以选择数量至多为你“罪”标记数的其他角色，弃置他们区域内各一张牌",
	["~wxtianzuiEX"] = "汝罪之大，似彻天之山、盈渊之海！",
	["$wxtianzuiEX1"] = "借天风，浴业火，可破万敌！", --合纵破曹 --叠标记
	["$wxtianzuiEX2"] = "星辰之力，助我灭敌！", --极略三国SP神诸葛亮“妖智” --拆人
	  --天罚
	["wxtianfaEX"] = "天罚",
	["wxtianfaex"] = "天罚",
	[":wxtianfaEX"] = "出牌阶段，你使用第偶数张锦囊牌时，你获得1枚“罚”标记（“罚”标记持续至下个出牌阶段开始时）；" ..
	"回合结束时，你可以对至多Z名其他角色各造成1点雷电伤害（Z为你的“罚”标记数）。",
	["exFA"] = "罚",
	["@wxtianfaEX-card"] = "你可以对数量至多为你“罚”标记数的其他角色各造成1点雷电伤害",
	["~wxtianfaEX"] = "请叫我：罪罚哥",
	["$wxtianfaEX1"] = "星象为我控，七星握掌中！", --合纵破曹 --叠标记
	["$wxtianfaEX2"] = "七星八阵，敌军将困！", --孟章诛邪 --砸人
	--
	["wx_ZUIandFA"] = "罪与罚",
	  --阵亡
	["~wx_shenzhugeliangEX"] = "时也，命也......", --孟章诛邪
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--==极略三国神武将==--
	--神黄忠(SGK)
	["jlsg_shenhuangzhong"] = "神黄忠[极略三国]",
	["&jlsg_shenhuangzhong"] = "神黄忠",
	["#jlsg_shenhuangzhong"] = "烈弓神威", --取自神黄忠在极略三国中的台词：“烈弓神威，箭矢毙敌”
	["designer:jlsg_shenhuangzhong"] = "极略三国",
	["cv:jlsg_shenhuangzhong"] = "极略三国",
	["illustrator:jlsg_shenhuangzhong"] = "极略三国",
	  --神烈弓
	["jlsgliegong"] = "烈弓",
	["jlsgliegongDR"] = "烈弓",
	["jlsgliegongBfs"] = "烈弓",
	[":jlsgliegong"] = "每个回合限一次，<font color='red'><b>（若你已受伤，改为每个回合限两次）</b></font>你可以将至少一张花色各不相同的手牌当无距离和次数限制的火【杀】使用。" ..
	"若你以此法使用的转化前的牌数不小于：\
	1，此【杀】不能被【闪】响应；\
	2，使用此【杀】后，你摸三张牌；\
	3，此【杀】的伤害+1；\
	4，此【杀】造成伤害后，你令目标角色随机失去一个技能。\
	<font color='red'><b>（小魔改：失去技能范围不只是武将牌上的技能）</b></font>",
	["$jlsgliegong1"] = "烈弓神威，箭矢毙敌！",
	["$jlsgliegong2"] = "鋷甲锵躯，肝胆俱裂！",
	  --阵亡
	["~jlsg_shenhuangzhong"] = "终究抵不过这沧桑岁月......",
	
	--神黄盖(SGK)
	["jlsg_shenhuanggai"] = "神黄盖[极略三国]",
	["&jlsg_shenhuanggai"] = "神黄盖",
	["#jlsg_shenhuanggai"] = "灿世连炎", --xjb起的
	["designer:jlsg_shenhuanggai"] = "极略三国",
	["cv:jlsg_shenhuanggai"] = "GK逆天广告",
	["illustrator:jlsg_shenhuanggai"] = "极略三国",
	  --炼体
	["jlsglianti"] = "炼体",
	[":jlsglianti"] = "锁定技，你始终横置；其他角色于你的回合内第一次受到属性伤害后，你令其再受到一次此伤害；当你受到属性伤害后，你令你的摸牌阶段摸牌数和手牌上限+1，然后减1点体力上限。",
	["$jlsglianti1"] = "弓我还没得，不可能铁索，一体力我都没得~", --横置
	["$jlsglianti2"] = "好多的牌，摸 好多的牌哦，全局是闪哎~", --二段伤
	["$jlsglianti3"] = "苦肉一次，弓无闪有，弓啊在哪，苦肉无数，苦了没奶，还拿桃哦，你自己打~", --受伤
	  --炎烈
	["jlsgyanlie"] = "炎烈",
	[":jlsgyanlie"] = "出牌阶段限一次，你可以弃置至少一张手牌并选择等量的其他角色，视为你对这些角色使用【铁锁连环】，然后你对一名横置角色造成1点火焰伤害。",
	["$jlsgyanlie1"] = "原来他们敢打是看你胆大摸完，是苦肉的我拿命给她挡的~",
	["$jlsgyanlie2"] = "没诸葛拿的，不哭我们投哦~",
	  --阵亡
	["~jlsg_shenhuanggai"] = "（现在是幻想时间：“莫急，有老夫在此~”羞答答的玫瑰，静悄悄地开~）",
	
	--神华佗(SGK)
	["jlsg_shenhuatuo"] = "神华佗[极略三国]",
	["&jlsg_shenhuatuo"] = "神华佗",
	["#jlsg_shenhuatuo"] = "桃市垄断", --为什么会这么起，看技能就懂了
	["designer:jlsg_shenhuatuo"] = "极略三国",
	["cv:jlsg_shenhuatuo"] = "极略三国",
	["illustrator:jlsg_shenhuatuo"] = "极略三国",
	  --元化
	["jlsgyuanhua"] = "元化",
	[":jlsgyuanhua"] = "锁定技，你每获得一张【桃】，你回复1点体力并摸两张牌，然后将此牌移出游戏。",
	["$jlsgyuanhua1"] = "两剂服下，自当痊愈。",
	["$jlsgyuanhua2"] = "怎么样，是不是感觉好点儿了？", --所以这语音和技能有半毛钱关系......
	  --归元
	["jlsgguiyuan"] = "归元",
	[":jlsgguiyuan"] = "出牌阶段限一次，你可以失去1点体力，令所有其他角色各交给你一张【桃】，然后你从牌堆或弃牌堆获得一张【桃】。",
	["@jlsgguiyuan-wtgy"] = "请将一张【桃】交给%src<br /> 注：若点【取消】，则系统会帮你随机给一张",
	["$jlsgguiyuan"] = "这点小技，怕不足以救天下人吧......", --你是在嘲讽吗
	  --重生
	["jlsgchongsheng"] = "重生",
	[":jlsgchongsheng"] = "限定技，当一名角色进入濒死状态时，你可以令其将体力上限调整至X并回复所有体力（X为你通过“元化”移出游戏的牌数且至少为1），" ..
	"然后其可以从随机三张同势力武将牌中选择一张替换之（体力上限与体力值不因此改变）。",
	["@jlsgchongsheng"] = "重生",
	["@jlsgchongsheng-generalChanged"] = "[重生]更换武将",
	["$jlsgchongsheng"] = "快好起来吧，还有人等着你......",
	  --阵亡
	["~jlsg_shenhuatuo"] = "别担心，毕竟，也这个岁数了......",
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--==线下神武将==--
	--神姜维(官盗)
	["ofl_shenjiangwei"] = "神姜维[线下]",
	["&ofl_shenjiangwei"] = "神姜维",
	["#ofl_shenjiangwei"] = "怒麟布武",
	["designer:ofl_shenjiangwei"] = "线下官盗",
	["cv:ofl_shenjiangwei"] = "官方",
	["illustrator:ofl_shenjiangwei"] = "匠人绘",
	  --天任（同原版）
	  --九伐
	["ofljiufa"] = "九伐",
	[":ofljiufa"] = "当你使用或打出的牌结算完成后，若你的武将牌上没有与之牌名相同的牌，你可以将这些牌置于你的武将牌上。此时若你以此法置于武将牌上的牌中包括至少九种牌名，" ..
	"你移去这些牌，然后展示牌堆顶的九张牌，获得其中点数重复的牌各一张。",
	["$ofljiufa1"] = "九伐中原，以圆先帝遗志。",
	["$ofljiufa2"] = "日日砺剑，相报丞相厚恩。",
	  --平襄（其实与原版一样，但因失去的“九伐”不一样故不能直接引用）
	["oflpingxiang"] = "平襄",
	["oflpingxiangFireSlash"] = "平襄",
	["oflpingxiangfireslash"] = "平襄",
	[":oflpingxiang"] = "限定技，出牌阶段，若你的体力上限大于9，你减9点体力上限，若如此做，你视为使用至多九张火【杀】（不计次）。然后你失去技能“九伐”且你的手牌上限改为你的体力上限。",
	["@oflpingxiang"] = "平襄",
	["@oflpingxiangFireSlash"] = "你可以视为使用一张火【杀】",
	["~oflpingxiangFireSlash"] = "选择你想砍的可被选择的角色，点【确定】；若点【取消】视为你中止“平襄”火【杀】的持续使用",
	["$oflpingxiang1"] = "策马纵慷慨，捐躯抗虎豺！",
	["$oflpingxiang2"] = "解甲事仇雠，竭力挽狂澜！",
	  --阵亡
	["~ofl_shenjiangwei"] = "武侯遗志，已成泡影矣.........",
	
	--新神马超(官方)
	["ofl_shenmachao"] = "新神马超[线下]", --神马超[线下]（就是那个无敌的永动机神马）可于Nyarz大佬的“自嗨包”中下载游玩。
	["&ofl_shenmachao"] = "神马超",
	["#ofl_shenmachao"] = "神威天将军",
	["designer:ofl_shenmachao"] = "线下官方",
	["cv:ofl_shenmachao"] = "官方(皮肤“雷挝缚苍”)",
	["illustrator:ofl_shenmachao"] = "君桓文化,紫髯的小乔",
	  --狩骊
	["oflshouliGMS"] = "狩骊",
	["oflshouli"] = "狩骊",
	["oflshouliSlash"] = "狩骊",
	["oflshoulislash"] = "狩骊",
	["oflshouliJink"] = "狩骊",
	["oflshouliSlashMax"] = "狩骊",
	["oflshouliTrigger"] = "狩骊",
	[":oflshouli"] = "游戏开始时，你令所有其他角色随机获得一种“狩骊”标记（“狩骊”标记分为两种：“骏”/“骊”）。<font color='green'><b>每个回合各限一次，</b></font>" ..
	"你可以将一名其他角色的所有“骏”/“骊”标记移动至其上家或下家，并视为使用或打出一张无距离和次数限制的【杀】/一张【闪】。\
	-------\
	<font color='red'><b>♞“骏”标记效果：</b>1.若你拥有此标记的数量：不小于1，你与其他角色的距离-1；不小于2，你于摸牌阶段多摸一张牌；不小于3，你使用【杀】指定目标后，本回合其非锁定技失效。\
	2.当你受到属性伤害时，或受到【南蛮入侵】或【万箭齐发】造成的伤害时，将你的所有此标记移至上家。\
	3.你拥有此标记的期间，<s>你的装备区里不能置入进攻坐骑牌</s>你的进攻坐骑栏处于废除状态。</font>\
	-------\
	<font color='blue'><b>♘“骊”标记效果：</b>1.若你拥有此标记的数量：不小于1，其他角色与你的距离+1；不小于2，你于摸牌阶段多摸一张牌；不小于3，你造成或受到的伤害均视为雷电伤害；不小于4，你造成或受到的伤害+1；\
	2.当你受到属性伤害时，或受到【南蛮入侵】或【万箭齐发】造成的伤害时，将你的所有此标记移至下家。\
	3.你拥有此标记的期间，<s>你的装备区里不能置入防御坐骑牌</s>你的防御坐骑栏处于废除状态。</font>",
	["oflshouli:JtoL"] = "将其所有“骏”标记移给其上家",
	["oflshouli:JtoN"] = "将其所有“骏”标记移给其下家",
	["oflshouli:LtoL"] = "将其所有“骊”标记移给其上家",
	["oflshouli:LtoN"] = "将其所有“骊”标记移给其下家",
	["@oflshouli_useSlash"] = "[狩骊]你视为使用一张【杀】",
	["~oflshouli_useSlash"] = "此【杀】无距离与次数限制",
	["oflshouli_JT"] = "请选择一名有“骏”标记的其他角色",
	["oflshouli_LT"] = "请选择一名有“骊”标记的其他角色",
	["$oflshouli1"] = "饲骊胡肉，饮骥虏血，一骑可定万里江山！",
	["$oflshouli2"] = "折兵为弭，纫甲为服，此箭可狩在野之龙！",
	    --“骏”标记效果：
	  ["oflshouli_JUN"] = "狩骊-骏",
	  ["oflshouli_JUN_one"] = "狩骊-骏",
	  ["oflshouli_JUN_oneMore"] = "狩骊-骏",
	  [":&oflshouli_JUN"] = "1.若你拥有此标记的数量：不小于1，你与其他角色的距离-1；不小于2，你于摸牌阶段多摸一张牌；不小于3，你使用【杀】指定目标后，本回合其非锁定技失效。\
	  2.当你受到属性伤害时，或受到【南蛮入侵】或【万箭齐发】造成的伤害时，将你的所有此标记移至上家。\
	  3.你拥有此标记的期间，你的装备区里不能置入进攻坐骑牌。",
	  ["$oflshouli_JUN_two"] = "%from 的“<font color='yellow'><b>骏</b></font>”标记已不少于 <font color='yellow'><b>2</b></font> 枚，于摸牌阶段的摸牌数+1",
	  ["$oflshouli_JUN_three"] = "因为 %from 的“<font color='yellow'><b>骏</b></font>”标记已不少于 <font color='yellow'><b>3</b></font> 枚，%to 本回合非锁定技失效",
	    --“骊”标记效果：
	  ["oflshouli_LI"] = "狩骊-骊",
	  ["oflshouli_LI_one"] = "狩骊-骊",
	  ["oflshouli_LI_oneMore"] = "狩骊-骊",
	  [":&oflshouli_LI"] = "1.若你拥有此标记的数量：不小于1，其他角色与你的距离+1；不小于2，你于摸牌阶段多摸一张牌；不小于3，你造成或受到的伤害均视为雷电伤害；不小于4，你造成或受到的伤害+1；\
	  2.当你受到属性伤害时，或受到【南蛮入侵】或【万箭齐发】造成的伤害时，将你的所有此标记移至下家。\
	  3.你拥有此标记的期间，你的装备区里不能置入防御坐骑牌。",
	  ["$oflshouli_LI_two"] = "%from 的“<font color='yellow'><b>骊</b></font>”标记已不少于 <font color='yellow'><b>2</b></font> 枚，于摸牌阶段的摸牌数+1",
	  ["$oflshouli_LI_three"] = "因为 %from 的“<font color='yellow'><b>骊</b></font>”标记已不少于 <font color='yellow'><b>3</b></font> 枚，此次伤害视为雷电伤害",
	  ["$oflshouli_LI_four_DC"] = "因为 %from 的“<font color='yellow'><b>骊</b></font>”标记已不少于 <font color='yellow'><b>4</b></font> 枚，%from 对 %to 造成的此次伤害+1",
	  ["$oflshouli_LI_four_DI"] = "因为 %from 的“<font color='yellow'><b>骊</b></font>”标记已不少于 <font color='yellow'><b>4</b></font> 枚，%from 受到 %to 造成的此次伤害+1",
	  --横骛
	["oflhengwu"] = "横骛",
	[":oflhengwu"] = "锁定技，拥有“骏”或“骊”标记的角色再次获得相同标记后，你摸X张牌（X为其拥有该标记的数量）。",
	["$oflhengwu1"] = "此身独傲，天下无不可敌之人，无不可去之地！",
	["$oflhengwu2"] = "神威天降，世间无不可驭之雷，无不可降之马！",
	  --阵亡
	["~ofl_shenmachao"] = "以战入圣，贪战而亡.......",
	
	--神郭嘉(官方)
	["ofl_shenguojia"] = "神郭嘉[线下]",
	["&ofl_shenguojia"] = "神郭嘉",
	["#ofl_shenguojia"] = "星月奇佐",
	["designer:ofl_shenguojia"] = "线下官方(飞鸿印雪)",
	["cv:ofl_shenguojia"] = "官方(皮肤“倚星折月”-第一形态)",
	["illustrator:ofl_shenguojia"] = "木美人,紫髯的小乔",
	  --慧识
	["oflhuishi"] = "慧识",
	["oflhuishiContinue"] = "慧识",
	[":oflhuishi"] = "出牌阶段限一次，你可以进行判定，并重复此流程直到出现花色相同的判定牌。然后你可以将所有生效的判定牌交给一名角色。",
	["@oflhuishi-give"] = "请将所有判定牌交给一名角色",
	["$oflhuishi1"] = "观滴水而知沧海，窥一举而察人心。",
	["$oflhuishi2"] = "察才识贤，以翊公之事。",
	  --天翊
	["ofltianyi"] = "天翊",
	["ofltianyiDamageTake"] = "",
	[":ofltianyi"] = "觉醒技，准备阶段开始时，若全场存活角色在本局游戏中均受到过伤害，<font color='red'><b>(若你的体力上限小于10)</b></font>" ..
	"你将体力上限增加至10点，然后令一名角色获得“佐幸”。",
	["@ofltianyi"] = "天翊",
	["ofltianyi-invoke"] = "请选择一名角色，令其获得“佐幸”",
	["$ofltianyi1"] = "明主既现，吾定极尽所能。",
	["$ofltianyi2"] = "今九州纷乱，当祈天翊佑。",
	  --辉逝
	["oflhuishii"] = "辉逝",
	[":oflhuishii"] = "限定技，当你进入濒死状态时，你可以选择一名角色：若其有未触发的觉醒技，你选择其中一个觉醒技，其视为已满足觉醒条件；否则其摸四张牌。",
	["@oflhuishii"] = "辉逝",
	["oflhuishii-wake"] = "选择一名角色，助他觉醒大业！",
	["$oflhuishii1"] = "人亦如星，或居空而渺然，或为彗而明夜。",
	["$oflhuishii2"] = "纵殒身祭命，亦要助明公大业。",
	  --阵亡
	["~ofl_shenguojia"] = "未及引动天能，竟已要坠入轮回..........",
	
	--神荀彧(官方)
	["ofl_shenxunyu"] = "神荀彧[线下]",
	["&ofl_shenxunyu"] = "神荀彧",
	["#ofl_shenxunyu"] = "洞心先识",
	["designer:ofl_shenxunyu"] = "线下官方(飞鸿印雪)",
	["cv:ofl_shenxunyu"] = "官方(原画,皮肤“虎年清明”)",
	["illustrator:ofl_shenxunyu"] = "枭瞳,紫髯的小乔",
	  --天佐（同原版）
	  --灵策
	["ofllingce"] = "灵策",
	[":ofllingce"] = "锁定技，有角色使用“智囊牌”时，你摸一张牌；其他角色使用的“智囊牌”对你无效。\
	<font color=\"#FFCC00\"><b>☀注：初始“智囊牌”：【过河拆桥】、【无中生有】、【无懈可击】</font>",
	["$ofllingce1"] = "绍士卒虽众，其实难用，良策者，胜败之机也。",
	["$ofllingce2"] = "袁军不过一盘沙砾，以帷幄之规，下攻拔之捷。",
	  --定汉
	["ofldinghan"] = "定汉",
	["ofldinghan_firstZNs"] = "",
	[":ofldinghan"] = "准备阶段，你可以移除一张“智囊牌”的记录，然后将一张不为“智囊牌”的锦囊牌记录为“智囊牌”。",
	[":ofldinghan1"] = "准备阶段，你可以移除一张“智囊牌”的记录，然后将一张不为“智囊牌”的锦囊牌记录为“智囊牌”。",
	[":ofldinghan11"] = "准备阶段，你可以移除一张“智囊牌”的记录，然后将一张不为“智囊牌”的锦囊牌记录为“智囊牌”。\
						<font color=\"red\"><b>“智囊牌”记录：%arg11</b></font>",
	["#oflDingHanRemove"] = "%from 在“%arg”的记录中移除了【%arg2】",
	["#oflDingHanAdd"] = "%from 在“%arg”的记录中增加了【%arg2】",
	["$ofldinghan1"] = "汉室复兴，指日可待。",
	["$ofldinghan2"] = "天下已定，吾再无忧矣。",
	  --阵亡
	["~ofl_shenxunyu"] = "君本起义兵匡国，今怎可生此异心......",
	
	--长坂坡模式·神赵云(民间,长坂坡模式)
	  --原版
	--["ofl_cbp_shenzhaoyun"] = "长坂坡模式·神赵云-第二形态[线下]",
	["ofl_cbp_shenzhaoyun"] = "长坂坡·神赵云-2[线下]",
	["&ofl_cbp_shenzhaoyun"] = "长坂坡神赵云",
	["#ofl_cbp_shenzhaoyun"] = "不败神话",
	["designer:ofl_cbp_shenzhaoyun"] = "洛神小组",
	["cv:ofl_cbp_shenzhaoyun"] = "官方",
	["illustrator:ofl_cbp_shenzhaoyun"] = "洪肖三郎",
	  --龙胆（同标准包原版）
	  --青釭
	["oflqinggang"] = "青釭",
	[":oflqinggang"] = "当你使用的【杀】造成伤害后，你可以令目标选择一项：1.弃置一张手牌；2.你从其装备区获得一张牌。",
	["oflqinggang:1"] = "弃置一张手牌",
	["oflqinggang:2"] = "其从你装备区获得一张牌",
	["$oflqinggang1"] = "金甲映日，驱邪祛秽！", --弃牌
	["$oflqinggang2"] = "龙升九天，马踏飞燕！", --得牌
	  --龙怒
	["ofllongnu"] = "龙怒",
	["ofllongnuBuff"] = "龙怒-强命",
	[":ofllongnu"] = "<b>聚气技，</b>出牌阶段，你可以弃置两张相同花色的“怒”，若如此做，你使用的下一张【杀】不可被响应。",
	["$ofllongnu1"] = "腾龙行云，首尾不见。", --弃怒
	["$ofllongnu2"] = "千里一怒，红莲灿世！", --杀
	  --浴血
	["oflyuxue"] = "浴血",
	[":oflyuxue"] = "<b>聚气技，</b>你可以将你的一张红桃或方块花色的“怒”当【桃】使用。",
	["$oflyuxue1"] = "潜龙于渊，涉灵愈伤。",
	["$oflyuxue2"] = "龙游中原，魂魄不息！",
	  --龙吟
	["ofllongyin"] = "龙吟",
	[":ofllongyin"] = "<font color='blue'><s><font color='red'><b>特定技，</b></font>聚气阶段，</s></font>准备阶段结束时，你可以从牌堆顶亮出三张牌，" ..
	"选择其中一张牌置于武将牌上，称为“怒”（至多四张）；其余牌获得之。",
	["oflAngry"] = "怒",
	["$ofllongyin1"] = "龙战于野，其血玄黄！", --发动
	["$ofllongyin2"] = "来感受这，降世神龙的力量吧！", --叠怒
	  --阵亡
	["~ofl_cbp_shenzhaoyun"] = "血染鳞甲，龙坠九天.........",
	
	  --威力加强版
	--["ofl_cbp_shenzhaoyunEX"] = "长坂坡模式·神赵云-第二形态[线下]-威力加强版",
	["ofl_cbp_shenzhaoyunEX"] = "长坂坡·神赵云-2[线下]-EX",
	["&ofl_cbp_shenzhaoyunEX"] = "长坂坡神赵云",
	["#ofl_cbp_shenzhaoyunEX"] = "千古传,神话兴",
	["designer:ofl_cbp_shenzhaoyunEX"] = "时光流逝FC",
	["cv:ofl_cbp_shenzhaoyunEX"] = "官方",
	["illustrator:ofl_cbp_shenzhaoyunEX"] = "洪肖三郎",
	  --龙胆（同OL界限突破版）
	  --青釭
	["oflqinggangEX"] = "青釭",
	[":oflqinggangEX"] = "当你使用的【杀】造成伤害后，你可以令目标弃置一张手牌且你从其装备区获得一张牌。",
	["$oflqinggangEX1"] = "金甲映日，驱邪祛秽！", --弃牌
	["$oflqinggangEX2"] = "龙升九天，马踏飞燕！", --得牌
	  --龙怒
	["ofllongnuEX"] = "龙怒",
	["ofllongnuex"] = "龙怒",
	["ofllongnuEXbuff"] = "龙怒-加成效果",
	[":ofllongnuEX"] = "<b>聚气技，</b>出牌阶段，你可以选择两张相同花色的“怒”，获得之或弃置之，若如此做，你使用的下一张【杀】不可被响应，且若你选择弃置，此【杀】伤害+1。",
	["ofllongnuEX:get"] = "获得这两张“怒”",
	["ofllongnuEX:dis"] = "弃置这两张“怒”(下一张【杀】将附带伤害加成)",
	["$ofllongnuEXbuff_md"] = "因为 %from 发动“<font color='yellow'><b>龙怒</b></font>”时选择获得了伤害加成效果，%from 使用的此【<font color='yellow'><b>杀</b></font>】" ..
	"对 %to 造成的伤害 + %arg2",
	["$ofllongnuEX1"] = "腾龙行云，首尾不见。", --弃怒
	["$ofllongnuEX2"] = "千里一怒，红莲灿世！", --杀
	  --浴血
	["oflyuxueEX"] = "浴血",
	["oflyuxueex"] = "浴血",
	["oflyuxueEXbuff"] = "浴血",
	[":oflyuxueEX"] = "<b>聚气技，</b>你可以将你的一张红色/黑色“怒”当【桃】/【酒】使用，然后从牌堆获得一张红色/黑色牌。",
	["$oflyuxueEX1"] = "潜龙于渊，涉灵愈伤。",
	["$oflyuxueEX2"] = "龙游中原，魂魄不息！",
	  --龙吟
	["ofllongyinEX"] = "龙吟",
	[":ofllongyinEX"] = "准备阶段结束时，你可以从牌堆顶亮出X张牌，选择任意张牌（至少一张）置于武将牌上，称为“怒”（至多八张）；其余牌获得之。（X为4+你装备区内的牌数）",
	["$ofllongyinEX1"] = "龙战于野，其血玄黄！", --发动
	["$ofllongyinEX2"] = "来感受这，降世神龙的力量吧！", --叠怒
	  --阵亡
	["~ofl_cbp_shenzhaoyunEX"] = "血染鳞甲，龙坠九天.........",
	
	--长坂坡模式·神张飞(民间,长坂坡模式)
	  --原版
	--["ofl_cbp_shenzhangfei"] = "长坂坡模式·神张飞-第二形态[线下]",
	["ofl_cbp_shenzhangfei"] = "长坂坡·神张飞-2[线下]",
	["&ofl_cbp_shenzhangfei"] = "长坂坡神张飞",
	["#ofl_cbp_shenzhangfei"] = "虎啸盘蛇",
	["designer:ofl_cbp_shenzhangfei"] = "洛神小组",
	["cv:ofl_cbp_shenzhangfei"] = "官方",
	["illustrator:ofl_cbp_shenzhangfei"] = "洪肖三郎",
	  --丈八
	["oflzhangba"] = "丈八",
	["OflZhangba"] = "丈八",
	[":oflzhangba"] = "锁定技，当你没有装备武器牌时，你的初始攻击范围为3。",
	["__ofl_zhangba"] = "丈八",
	--[":__ofl_zhangba"] = "装备牌·武器<br /><b>攻击范围</b>：３",
	  --备粮
	["oflbeiliang"] = "备粮",
	[":oflbeiliang"] = "摸牌阶段，你可以放弃摸牌，将手牌补至等同于你体力上限的张数。",
	["$oflbeiliang1"] = "力大欺理，勇大欺谋！",
	["$oflbeiliang2"] = "竖子休走，张飞在此！",
	  --聚武
	["ofljuwu"] = "聚武",
	[":ofljuwu"] = "出牌阶段，你可以将你的手牌任意分配给“神·赵云”，每阶段至多以此法分配X张（X为你的当前体力值）。",
	["$ofljuwu"] = "四弟，俺来助你！",
	  --缠蛇
	["oflchanshe"] = "缠蛇",
	[":oflchanshe"] = "<b>聚气技，</b>你可以将你的一张红桃或方块花色的“怒”当【乐不思蜀】使用。",
	["$oflchanshe1"] = "矛锋断千军之生，炬目判万人之死！",
	["$oflchanshe2"] = "世人独惧生死，奈何不畏因果轮回！",
	  --弑神
	["oflshishen"] = "弑神",
	["oflshishenJQ"] = "弑神-聚气",
	[":oflshishen"] = "<font color='red'><b>[聚气]</b></font>准备阶段结束时，你可以从牌堆顶亮出一张牌并置于你的武将牌上，称为“怒”（至多四张）。\
	<b>聚气技，</b>出牌阶段，你可以弃置两张相同颜色的“怒”，令一名角色失去1点体力。",
	["$oflshishen1"] = "鸣鼓净街魑魅退，擂瓮升堂罪何人！",
	["$oflshishen2"] = "巡界奔走双甲子，归来两界又一秋！",
	  --阵亡
	["~ofl_cbp_shenzhangfei"] = "与其独行天地，不如大醉一回......",
	
	  --威力加强版
	--["ofl_cbp_shenzhangfeiEX"] = "长坂坡模式·神张飞-第二形态[线下]-威力加强版",
	["ofl_cbp_shenzhangfeiEX"] = "长坂坡·神张飞-2[线下]-EX",
	["&ofl_cbp_shenzhangfeiEX"] = "长坂坡神张飞",
	["#ofl_cbp_shenzhangfeiEX"] = "虎长啸,蛇狂行",
	["designer:ofl_cbp_shenzhangfeiEX"] = "时光流逝FC",
	["cv:ofl_cbp_shenzhangfeiEX"] = "官方",
	["illustrator:ofl_cbp_shenzhangfeiEX"] = "洪肖三郎",
	  --丈八
	["oflzhangbaEX"] = "丈八",
	["oflzhangbaEX_viewas"] = "丈八",
	[":oflzhangbaEX"] = "锁定技，当你没有装备武器牌时，你视为装备【丈八蛇矛】。",
	  --备粮
	["oflbeiliangEX"] = "备粮",
	[":oflbeiliangEX"] = "准备阶段开始时，你可以将手牌补至等同于你体力上限的张数。",
	["$oflbeiliangEX1"] = "力大欺理，勇大欺谋！",
	["$oflbeiliangEX2"] = "竖子休走，张飞在此！",
	  --聚武
	["ofljuwuEX"] = "聚武",
	["ofljuwuex"] = "聚武",
	["ofljuwuEX_targetsClear"] = "聚武",
	[":ofljuwuEX"] = "出牌阶段，你可以将你的牌任意分配给其他同势力角色（每阶段至多以此法分配X张），然后若你为此阶段第一次以此法分配给其牌，" ..
	"你摸Y张牌（X为你的当前体力值；Y为你已损失的体力值）。",
	["$ofljuwuEX"] = "二哥，俺来助你！",
	  --缠蛇
	["oflchansheEX"] = "缠蛇",
	["oflchansheex"] = "缠蛇",
	[":oflchansheEX"] = "<b>聚气技，</b>你可以将你的一张红色/黑色“怒”当【乐不思蜀】/【兵粮寸断】使用。",
	["$oflchansheEX1"] = "矛锋断千军之生，炬目判万人之死！",
	["$oflchansheEX2"] = "世人独惧生死，奈何不畏因果轮回！",
	  --弑神
	["oflshishenEX"] = "弑神",
	["oflshishenex"] = "弑神",
	["oflshishenEXClear"] = "弑神",
	["oflshishenEXJQ"] = "弑神-聚气",
	[":oflshishenEX"] = "<font color='red'><b>[聚气]</b></font>准备阶段结束时，你可以从牌堆顶亮出随机1~3张牌并置于你的武将牌上，称为“怒”（至多八张）。\
	<b>聚气技，</b>出牌阶段，你可以弃置两张相同颜色/不同颜色的“怒”，令一名角色失去1点体力且本回合非锁定技失效/受到你造成的1点伤害且本回合不能使用或打出手牌。",
	["$oflshishenEX1"] = "鸣鼓净街魑魅退，擂瓮升堂罪何人！",
	["$oflshishenEX2"] = "巡界奔走双甲子，归来两界又一秋！",
	  --阵亡
	["~ofl_cbp_shenzhangfeiEX"] = "与其独行天地，不如大醉一回......",
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--==吧友diy神武将==--
	--神司马师(自己DIY)
	["f_shensimashi"] = "神司马师",
	["#f_shensimashi"] = "钢铁之心",
	["designer:f_shensimashi"] = "时光流逝FC",
	["cv:f_shensimashi"] = "官方",
	["illustrator:f_shensimashi"] = "?",
	  --狠决
	["f_henjue"] = "狠决",
	[":f_henjue"] = "出牌阶段限一次，你可以废除一个装备栏，废除一名其他角色的一个装备栏。若如此做，你摸X张牌（X为你已废除的装备栏数）。",
	["f_henjue:0"] = "废除武器栏",
	["f_henjue:1"] = "废除防具栏",
	["f_henjue:2"] = "废除+1马栏",
	["f_henjue:3"] = "废除-1马栏",
	["f_henjue:4"] = "废除宝物栏",
	["$f_henjue1"] = "汝大逆不道，当死无赦！",
	["$f_henjue2"] = "斩草除根，灭其退路！",
	  --平叛
	["f_pingpan"] = "平叛",
	[":f_pingpan"] = "锁定技，当你对其他角色造成伤害时，若该角色有被废除的装备栏，你令此伤害+Y，然后该角色恢复所有装备栏，你随机恢复一个装备栏。（Y为该角色已废除的装备栏数）",
	["$f_pingpan"] = "%to 有 %arg2 个装备栏已废除，故 %from 对其造成的伤害 + %arg2",
	["$f_pingpan1"] = "司马当兴，其兴在吾！",
	["$f_pingpan2"] = "撼山易，撼我司马氏难！",
	  --阵亡
	["~f_shensimashi"] = "吾家夙愿，得偿与否，尽看子上......",
	
	--神刘三刀(自己DIY)
	["f_three"] = "神刘三刀",
	["#f_three"] = "三刀神话",
	["designer:f_three"] = "时光流逝FC",
	["cv:f_three"] = "新三国,官方",
	["illustrator:f_three"] = "三国志12",
	  --三刀
	["f_sandao"] = "三刀",
	["f_sandaooo"] = "三刀",
	["f_sandaoDraw"] = "三刀",
	[":f_sandao"] = "<b>原版：</b>锁定技，你于出牌阶段可使用杀的基础次数改为3；你每连续使用/打出三张【杀】，你摸三张牌。\
	<font color='red'><b>升级：</b></font>觉醒技，准备阶段开始时，若你于本局累计使用或打出了至少三张【杀】，你升级“三刀”（限定技，出牌阶段，你可以视为使用至多三张无距离限制且不计次的【杀】。若你以此法造成有角色死亡，此技能视为未发动过）。\
	出牌阶段结束时，若你已发动过升级版“三刀”，你将“三刀”重置为原版，且若你未能通过发动升级版“三刀”杀死有角色，你删除原版“三刀”中的该部分：你每连续使用/打出三张【杀】，你摸三张牌。",
	["f_sandaoUse"] = "使用杀",
	["f_sandaoResp"] = "打出杀",
	["f_sandaoUaR"] = "",
	["WEhaveLSD"] = "我部悍将刘三刀",
	["$f_sandao"] = "我部悍将刘三刀，三刀之内必斩吕布于马下！",
	    --升级版
	  ["f_sandaoEX"] = "三刀",
	  ["f_sandaoex"] = "三刀",
	  ["f_sandaoEXSlash"] = "三刀",
	  ["f_sandaoexslash"] = "三刀",
	  ["f_sandaoEXkill"] = "三刀",
	  [":f_sandaoEX"] = "限定技，出牌阶段，你可以视为使用至多三张无距离限制且不计次的【杀】。若你以此法造成有角色死亡，此技能视为未发动过。",
	  ["@f_sandaoEX"] = "三刀",
	  ["@f_sandaoEXSlash"] = "你可以视为使用一张无距离限制且不计次的【杀】",
	  ["~f_sandaoEXSlash"] = "选择你想斩于马下的角色，点【确定】；若点【取消】视为你中止【杀】的持续使用",
	    --原版（重置）
	  ["f_sandaoC"] = "三刀",
	  [":f_sandaoC"] = "锁定技，你于出牌阶段可使用杀的基础次数改为3；你每连续使用/打出三张【杀】，你摸三张牌。",
	    --原版（重置且阉割）
	  ["f_sandaoD"] = "三刀",
	  [":f_sandaoD"] = "锁定技，你于出牌阶段可使用杀的基础次数改为3。",
	  --阵亡
	["~f_three"] = "你特么，吹牛逼能不能别带上我...额啊",
	
	--神刘备-威力加强版(吧友DIY)
	["f_shenliubeiEX"] = "神刘备-威力加强版",
	["&f_shenliubeiEX"] = "神刘备",
	["#f_shenliubeiEX"] = "雷火神剑",
	["designer:f_shenliubeiEX"] = "◆流木野◆",
	["cv:f_shenliubeiEX"] = "官方",
	["illustrator:f_shenliubeiEX"] = "鬼画符",
	  --龙怒
	["f_longnu"] = "龙怒",
	["f_longnu_yang"] = "龙怒·阳",
	["f_longnu_yangg"] = "龙怒·阳-附加效果",
	["f_longnu_yin"] = "龙怒·阴",
	["f_longnu_yinn"] = "龙怒·阴-附加效果",
	["f_longnu_DRbuff"] = "龙怒",
	["f_longnu_buffs"] = "龙怒",
	[":f_longnu"] = "转换技，锁定技，出牌阶段开始时：\
	[龙怒·阳]你减1点体力上限并摸一张牌，本回合你手牌中的红色牌和装备牌视为火【杀】且无距离和次数限制，若此牌为红色牌且为装备牌，则附加无视防具效果。\
	[龙怒·阴]你减1点体力上限并摸一张牌，本回合你手牌中的黑色牌和锦囊牌视为雷【杀】且无距离和次数限制，若此牌为黑色牌且为锦囊牌，则附加不可被响应效果。\
	锁定技，当有一名角色在你的回合脱离濒死状态后，你选择一项（1.失去1点体力；2.减1点体力上限），然后摸一张牌。",
	[":f_longnu1"] = "转换技，锁定技，出牌阶段开始时：\
	[龙怒·阳]你减1点体力上限并摸一张牌，本回合你手牌中的红色牌和装备牌视为火【杀】且无距离和次数限制，若此牌为红色牌且为装备牌，则附加无视防具效果。\
	<font color=\"#01A5AF\"><s>[龙怒·阴]你减1点体力上限并摸一张牌，本回合你手牌中的黑色牌和锦囊牌视为雷【杀】且无距离和次数限制，若此牌为黑色牌且为锦囊牌，则附加不可被响应效果。</s></font>\
	锁定技，当有一名角色在你的回合脱离濒死状态后，你选择一项（1.失去1点体力；2.减1点体力上限），然后摸一张牌。",
	[":f_longnu2"] = "转换技，锁定技，出牌阶段开始时：\
	<font color=\"#01A5AF\"><s>[龙怒·阳]你减1点体力上限并摸一张牌，本回合你手牌中的红色牌和装备牌视为火【杀】且无距离和次数限制，若此牌为红色牌且为装备牌，则附加无视防具效果。</s></font>\
	[龙怒·阴]你减1点体力上限并摸一张牌，本回合你手牌中的黑色牌和锦囊牌视为雷【杀】且无距离和次数限制，若此牌为黑色牌且为锦囊牌，则附加不可被响应效果。\
	锁定技，当有一名角色在你的回合脱离濒死状态后，你选择一项（1.失去1点体力；2.减1点体力上限），然后摸一张牌。",
	["f_longnu:1"] = "失去1点体力",
	["f_longnu:2"] = "减1点体力上限",
	["$f_longnu1"] = "兄弟疾难，血债血偿！", --摸牌
	["$f_longnu2"] = "损神熬心，誓报此仇！", --摸牌
	["$f_longnu3"] = "真龙之怒，势如燎原！", --火杀
	["$f_longnu4"] = "雷霆一怒，伏尸百万！", --雷杀
	  --结营（同原版）
	  --阵亡
	["~f_shenliubeiEX"] = "云长，翼德，为兄来也......",
	
	--神董卓(吧友DIY)
	["f_shendongzhuo"] = "神董卓",
	["#f_shendongzhuo"] = "权盛位极",
	["designer:f_shendongzhuo"] = "小珂酱",
	["cv:f_shendongzhuo"] = "官方",
	["illustrator:f_shendongzhuo"] = "秋呆呆",
	  --凶宴
	["f_xiongyan"] = "凶宴",
	["f_xiongyann"] = "凶宴",
	[":f_xiongyan"] = "出牌阶段开始时，你可以进行一次判定，根据判定牌的点数，从你的下家开始以逆时针方向依次点名（若场上存活玩家数少于判定牌的点数，将会循环），若点到的角色：\
	<b>·是你</b>，你视为使用一张【酒】并回复1点体力；\
	<b>·不是你</b>，该角色选择一项：1.失去1点体力并横置武将牌；2.交给你至少两张牌，然后你可以令其摸等量的牌。",
	["$f_xiongyan_self"] = "由 %from 发起的“<font color='yellow'><b>凶宴</b></font>”点名结束，发起者 %from 自己被点到",
	["$f_xiongyan_others"] = "由 %from 发起的“<font color='yellow'><b>凶宴</b></font>”点名结束，%to 被点到",
	["f_xiongyan:1"] = "失去1点体力并横置武将牌",
	["f_xiongyan:2"] = "交给“凶宴”发起者%src至少两张牌",
	["#f_xiongyan"] = "请交给 %src 至少两张牌",
	["@f_xiongyanDraw"] = "[凶宴]令其摸等量的牌",
	["$f_xiongyan1"] = "纵酒畅饮，人生妙哉！", --开始判定
	["$f_xiongyan2"] = "风流人生，不枉此生！", --最终点名到自己
	["$f_xiongyan3"] = "饮尽千杯酒，沙场百斩杀！", --最终点名到别人
	  --迁都
	["f_qiandu"] = "迁都",
	[":f_qiandu"] = "限定技，准备阶段开始时，你可以与一名其他角色交换座位，然后你可以依次弃置场上的至多2X张牌（X为你与该角色的距离）。然后你获得技能“析崩”。<font color='red'><b>注：当弹出弃置目标角色牌的界面时，若你点【取消】，则终止对该角色牌的弃置，跳到其下家。</b></font>", --依次：从你开始，以逆时针方向一个个弃置（不包括手牌）
	["@f_qiandu"] = "迁都",
	["@f_qiandu-card"] = "你想发动技能“迁都”吗？",
	["~f_qiandu"] = "迁都：与一名其他角色交换座位，然后弃置场上的牌",
	["QianduAnimate"] = "image=image/animate/f_qiandu.png",
	["$f_qiandu1"] = "大汉权责，由我掌控！",
	["$f_qiandu2"] = "我说的，就是王法！",
	    --析崩
	  ["f_xibeng"] = "析崩",
	  ["f_xibengMaxCards"] = "析崩",
	  [":f_xibeng"] = "锁定技，除非你处于濒死状态，当你即将回复体力时，你防止之，改为摸X+2张牌；你以此法获得的牌不计入你的手牌上限。（X为你即将回复的体力值）",
	  ["$f_xibeng1"] = "朝纲王法，与我无效！",
	  ["$f_xibeng2"] = "天下，有我一人就够了！",
	  --阵亡
	["~f_shendongzhuo"] = "竟中了，这王允老贼的奸计......",
	--==作者的设计思路==--
	--[[首先是体力上限，历史上董卓出兵的时候只有5000兵马，所以设定为5。
	凶宴的灵感来自于董卓在宴会上，随机杀人寻乐的事迹。并且可以和李儒的焚城配合。
	迁都则是董卓把都城从洛阳迁到长安，沿途百姓死亡无数，体现为董卓弃置场上的牌。
	析崩则是突出董卓只顾享乐，而不顾及国家大事的感觉。]]
	--==================--
	
	--神罗贯中(自己DIY)
	["f_shenluoguanzhong"] = "神罗贯中",
	["#f_shenluoguanzhong"] = "演义史诗",
	["designer:f_shenluoguanzhong"] = "时光流逝FC",
	["cv:f_shenluoguanzhong"] = "无",
	["illustrator:f_shenluoguanzhong"] = "QQ-AI作画",
	  --演义
	["f_yanyi"] = "演义",
	["f_yanyiStart"] = "演义",
	["f_yanyiStage"] = "演义",
	[":f_yanyi"] = "游戏开始时，你随机抽取一名未登场的武将牌作为自己的副将（体力上限与体力值保持与游戏开始时相同）。\
	<font color=\"#96943D\"><b>判定阶段开始时，</b></font>出牌阶段限一次，<font color='grey'><b>结束阶段结束时，</b></font>你可以以此法变更你的副将；回合开始前，你须以此法变更你的副将。（体力上限与体力值保持与变更前相同）。",
	  --阵亡
	--["~f_shenluoguanzhong"] = "",
	
	--神左慈(自己DIY)
	["f_shenzuoci"] = "神左慈",
	["#f_shenzuoci"] = "众神大战",
	["designer:f_shenzuoci"] = "时光流逝FC,小珂酱(动画制作)",
	["cv:f_shenzuoci"] = "官方",
	["illustrator:f_shenzuoci"] = "凝聚永恒",
	["f_shenzuociAttack"] = "",
	  --全神
	["f_quanshen"] = "全神",
	[":f_quanshen"] = "锁定技，游戏开始后，场上所有武将势力变更为“神”。",
	["$f_quanshen"] = "（摇铃声）",
	  --役使
	["f_yishi"] = "役使",
	["f_yishiGMS"] = "役使",
	[":f_yishi"] = "游戏开始时，你随机抽取X+1张未登场的神武将牌，依次获得其中X-1名武将的各一个技能。出牌阶段限一次，你可以选择一项：\
	1.弃置X张手牌和一张装备区里的牌，随机抽取X张未登场的神武将牌，获得其中一名武将的一个技能；\
	2.移除一个你以此法获得的技能，随机获得一名神武将的一个技能；\
	3.移除一个你以此法获得的技能，摸两张牌或回复1点体力。\
	（<font color='red'><b>注意：技能可能会重复</b></font>；X为你的当前体力值且至少为1）",
	["f_yishi:1"] = "弃置%src张手牌和一张装备区里的牌：我的回合，抽卡！",
	["f_yishi:2"] = "移除一个你以此法获得的技能，随机获得一名神武将的一个技能",
	["f_yishi:3"] = "移除一个你以此法获得的技能，摸两张牌或回复1点体力",
	["f_yishi:draw"] = "摸两张牌",
	["f_yishi:recover"] = "回复1点体力",
	["$f_yishi1"] = "眼之所见，皆为幻象。",
	["$f_yishi2"] = "幻化之术警之，为政者自当为国为民。",
	  --谜踪
	["f_mizong"] = "谜踪",
	["f_mizongReduceMC"] = "谜踪",
	[":f_mizong"] = "你每受到一次伤害，可以将你的一个技能移交给一名其他角色，若你此次移交的技能不为本技能，你本局游戏的手牌上限-1。",
	["f_mizongRMC"] = "手牌上限-",
	["$f_mizong1"] = "死生存亡，命之形也。",
	["$f_mizong2"] = "放下俗念，为道为仙。",
	  --阵亡
	["~f_shenzuoci"] = "凡俗琐事，不再牵扰......",
	
	--神刘禅(吧友DIY)
	["f_shenliushan"] = "神刘禅",
	["#f_shenliushan"] = "单挑王子",
	["designer:f_shenliushan"] = "luzhuoyuty38",
	["cv:f_shenliushan"] = "官方",
	["illustrator:f_shenliushan"] = "真三国无双",
	  --乐极
	["f_leji"] = "乐极",
	[":f_leji"] = "当其他角色成为【乐不思蜀】的目标时，若你的判定区没有【乐不思蜀】，你可以将目标改为自己。弃牌阶段开始时，你可以选择一项：" ..
	"1.将一张牌视为【乐不思蜀】对自己使用；2.若自己的判定区没有【乐不思蜀】，将场上的一张【乐不思蜀】移至自己的判定区。",
	["invoke"] = "发动",
	["f_leji:1"] = "将一张牌视为【乐不思蜀】对自己使用",
	["f_leji:2"] = "将场上的一张【乐不思蜀】移至自己的判定区",
	["f_lejiPush"] = "请选择一张牌，将此牌视为【乐不思蜀】对你自己使用",
	["f_lejiIndulgenceMove"] = "请选择场上的一名判定区有【乐不思蜀】的角色，将其【乐不思蜀】移至自己的判定区",
	["$f_leji1"] = "相父不在，奏乐起舞！",
	["$f_leji2"] = "纵情享受，不亦乐乎？",
	  --无忧
	["f_wuyou"] = "无忧",
	["f_wuyouo"] = "无忧",
	[":f_wuyou"] = "当你的判定区有【乐不思蜀】时，你不能被选择为非转化和非虚拟的【杀】或【决斗】的目标。",
	["$f_wuyou1"] = "此事爱卿可解，朕先退朝！",
	["$f_wuyou2"] = "有众卿家在，朕大可放心！",
	  --丹砂！
	["f_dansha"] = "单杀",
	[":f_dansha"] = "主公技，当【乐不思蜀】离开你的判定区时，你可以令一名角色失去2点体力。若有角色因此技能死亡，你失去此技能。",
	["f_danshaSiMaZhao"] = "请选择一名角色，让ta笑到心脏骤停",
	--["$f_dansha1"] = "",
	--["$f_dansha2"] = "",
	  --阵亡
	["~f_shenliushan"] = "五十四州王霸业，怎甘抛弃属他人......",
	
	--神曹仁(吧友DIY)
	["f_shencaoren"] = "神曹仁",
	["#f_shencaoren"] = "不灭金身",
	["designer:f_shencaoren"] = "钻洞老虎",
	["cv:f_shencaoren"] = "官方",
	["illustrator:f_shencaoren"] = "嗑嗑一休",
	  --奇阵
	["f_qizhen"] = "奇阵",
	[":f_qizhen"] = "当一名其他角色使用【杀】或锦囊牌指定你为唯一目标<font color='red'><b>时</b></font>，你可以进行判定，若结果为：\
	黑桃：你本回合不能使用或打出手牌；\
	梅花：你摸一张牌；\
	方块：此牌对你无效；\
	红桃：此牌的使用者改为你，该角色成为此牌的目标。",
	["$f_qizhenSpadePZ"] = "%from 布置的 <font color='yellow'><b>[</b></font><font color='blue'><b>奇阵</b></font><font color='yellow'><b>]</b></font> 被 %to 破除，%from 本回合不能使用或打出手牌",
	["$f_qizhenHeartEXchange"] = "%from 布置的 <font color='yellow'><b>[</b></font><font color='blue'><b>奇阵</b></font><font color='yellow'><b>]</b></font> 将法则改变，%from 成为 %card 的使用者，目标为 %to",
	["$f_qizhen1"] = "命中如此啊...", --判定失败(♠)，被破阵
	["$f_qizhen2"] = "以不变应万变！", --判定成功(♣)，摸牌
	["$f_qizhen3"] = "坚持住，援兵即刻就到！", --判定大成功(♦)，化解
	["$f_qizhen4"] = "吾自有办法！", --判定出奇迹(♥)，改变法则
	  --励军
	["f_lijun"] = "励军",
	[":f_lijun"] = "当你受到伤害后，你可以选择一项：1.令一名角色摸X张牌（X为你已损失的体力值）；2.令一名角色将手牌弃至其体力值。\
	若你选择了其他角色，你可以令其获得1点护甲。",
	["f_lijun:1"] = "令一名角色摸等同于你损失体力值数的牌",
	["f_lijun:2"] = "令一名角色将手牌弃至其体力值",
	["@f_lijunGHJ"] = "[励军]令其获得1点护甲",
	["$f_lijun1"] = "冲出重围，血拼到底！", --发动
	["$f_lijun2"] = "正是为国杀敌的时刻，冲啊！", --摸牌
	["$f_lijun3"] = "凭你叫嚣，我自坚守不动！", --弃牌
	["$f_lijun4"] = "齐军徐进，步伍严整，方得所向披靡！", --给护甲
	  --阵亡
	["~f_shencaoren"] = "舍身尽忠孝......",
	--==作者的设计思路==--
	--[[一技能来自三国演义中曹仁在新野摆下八门金锁阵的事迹，突出防中有攻的特点，同时也有可能起到负面效果（被徐庶破阵）。
	二技能思路是在周瑜攻打南郡时，曹仁率数十骑解救牛金等人，作为一个辅助队友的技能，也能对声势浩大的敌人造成破坏。至于为什么受伤发动，emmmm，大魏特色！]]
	--==================--
	
	--神赵云&陈到(自己DIY)
	["f_shenZhaoyunChendao"] = "神赵云＆陈到",
	["&f_shenZhaoyunChendao"] = "神赵云陈到",
	["#f_shenZhaoyunChendao"] = "忠勇相往",
	["designer:f_shenZhaoyunChendao"] = "时光流逝FC",
	["cv:f_shenZhaoyunChendao"] = "官方",
	["illustrator:f_shenZhaoyunChendao"] = "绯雪工作室,匠人绘",
	  --军阵
	["f_junzhen"] = "军阵",
	["f_junzhenAudio"] = "军阵",
	[":f_junzhen"] = "锁定技，你的手牌上限+2。",
	["$f_junzhen1"] = "龙威虎胆，斩敌破阵！/猛将之烈，统帅之所往！",
	["$f_junzhen2"] = "进退自如，游刃有余！/与子龙忠勇相往，猛烈相合！",
	  --勇魂
	["f_yonghun"] = "勇魂",
	["f_yonghunMoveCardBuff"] = "勇魂",
	["f_yonghunAnaleptic"] = "勇魂",
	["f_yonghunanaleptic"] = "勇魂",
	["f_yonghunAN"] = "勇魂",
	["f_yonghunANClear"] = "勇魂",
	["f_yonghunPeach"] = "勇魂",
	["f_yonghunpeach"] = "勇魂",
	["f_yonghunJink"] = "勇魂",
	["f_yonghunjink"] = "勇魂",
	["f_yonghunSlash"] = "勇魂",
	["f_yonghunslash"] = "勇魂",
	[":f_yonghun"] = "出牌阶段限一次，你可以摸两张牌。然后若你手牌中的这两张牌中有：\
	<font color='red'>[<b>杀</b>]</font>可以对一名其他角色使用之，且无距离和次数限制、无视其防具；\
	<font color=\"#00FFFF\">[<b>闪</b>]</font>可以弃置之，然后摸两张牌；\
	<font color='pink'>[<b>桃</b>]</font>可以交给一名其他已受伤角色，然后其使用之；\
	<font color='black'>[<b>酒</b>]</font>可以使用之，不计入使用次数且此阶段你使用的下一张牌不受次数限制。\
	<font color='red'><b>（注：效果发动询问顺序：酒->桃->闪->杀）</b></font>",
	["@f_yonghunAnaleptic"] = "你可以使用这张【酒】",
	["~f_yonghunAnaleptic"] = "此【酒】不计入使用次数，且此阶段你使用的下一张牌不受次数限制",
	["@f_yonghunPeach"] = "你可以选择一名其他已受伤角色，将这张【桃】交给其",
	["~f_yonghunPeach"] = "目标角色获得此【桃】，然后使用之",
	["@f_yonghunJink"] = "你可以弃置这张【闪】，然后摸两张牌",
	["~f_yonghunJink"] = "“无中生有！”",
	["@f_yonghunSlash"] = "你可以选择一名其他可被选择的角色，对其使用这张【杀】",
	["~f_yonghunSlash"] = "此【杀】无距离和次数限制、无视目标角色的防具",
	["$f_yonghun1"] = "策马趋前，斩敌当先！/有我在，无人能伤主公分毫！",
	["$f_yonghun2"] = "遍寻天下，但求一败！/主公的安危，由我来守护！",
	  --阵亡
	["~f_shenZhaoyunChendao"] = "你们谁......还敢再上？/我的白毦兵，再也不能为先帝出力了......",
	
	--神孙尚香(自己DIY)
	["f_shensunshangxiang"] = "神孙尚香",
	["#f_shensunshangxiang"] = "剑定情缘",
	["designer:f_shensunshangxiang"] = "时光流逝FC",
	["cv:f_shensunshangxiang"] = "官方",
	["illustrator:f_shensunshangxiang"] = "鬼画府",
	  --剑缘
	["f_jianyuan"] = "剑缘",
	["f_jianyuangive"] = "剑缘",
	["f_jianyuanthrow"] = "剑缘",
	[":f_jianyuan"] = "你每造成或受到1点伤害，若你的装备区里有牌，你可以弃置所有手牌并摸4+X张牌：将其中的总计三张牌依次选择交给一名【缘】角色/自己或弃置。" ..
	"然后若你此时的手牌数：大于2+Y，你翻面；大于4，你失去1点体力。（X与Y初始为0；若你的装备区里有武器牌，此次X与Y值+1）\
	<font color='green'><b>剑缘录：</b></font>上述内容结算完成后，若你此次以此法给牌的【缘】角色：1.装备区里有武器牌或未被记录入<b>《<font color='green'>剑缘录</font>》</b>，" .. 
	"你可以于令“剑缘”的X或Y值+1；2.若其未被记录入<b>《<font color='green'>剑缘录</font>》</b>，你可以记录之。\
	<font color='red'>*注:【缘】角色-->为其他男性角色，且至少满足其中一项：1.装备区里有牌；2.此次的伤害目标(你造成伤害)/伤害来源(你受到伤害)；3.被记录入<b>《<font color='green'>剑缘录</font>》</b>。</font>",
	[":f_jianyuan11"] = "你每造成或受到1点伤害，若你的装备区里有牌，你可以弃置所有手牌并摸4+X张牌：将其中的总计三张牌依次选择交给一名【缘】角色/自己或弃置。" ..
	"然后若你此时的手牌数：大于2+Y，你翻面；大于4，你失去1点体力。（X与Y初始为0；若你的装备区里有武器牌，此次X与Y值+1）\
	<font color='green'><b>剑缘录：</b></font>上述内容结算完成后，若你此次以此法给牌的【缘】角色：1.装备区里有武器牌或未被记录入<b>《<font color='green'>剑缘录</font>》</b>，" .. 
	"你可以于令“剑缘”的X或Y值+1；2.若其未被记录入<b>《<font color='green'>剑缘录</font>》</b>，你可以记录之。\
	<font color='red'>*注:【缘】角色-->为其他男性角色，且至少满足其中一项：1.装备区里有牌；2.此次的伤害目标(你造成伤害)/伤害来源(你受到伤害)；3.被记录入<b>《<font color='green'>剑缘录</font>》</b>。</font>\
	<font color='green'><b>《剑缘录》：%arg11</b></font>",
	["f_jianyuanX"] = "剑缘X+",
	["f_jianyuanY"] = "剑缘Y+",
	["@f_jianyuangive-card"] = "你可以选择一张“剑缘”牌，交给一名【缘】角色（或留给自己）",
	["~f_jianyuangive"] = "若点【取消】，视为你选择弃牌",
	["@f_jianyuanthrow-card"] = "请弃置一张“剑缘”牌",
	["~f_jianyuanthrow"] = "选择一张牌，点【确定】",
	["f_jianyuan:x"] = "令“剑缘”的X值+1",
	["f_jianyuan:y"] = "令“剑缘”的Y值+1",
	["f_jianyuan:JianYuanLu"] = "剑缘：你是否将 <font color='yellow'>%src</font> 记录入<b>《<font color=\"#00FF00\">剑缘录</font>》</b>？",
	["$f_jianyuan1"] = "彩袖双剑鸾凤鸣，良缘牵线醉黛眉。", --摸牌
	["$f_jianyuan2"] = "地生连理枝，水出并头莲。", --给牌
	["$f_jianyuan3"] = "刀剑花舞，将军看看如何？", --记录
	  --弓漓
	["f_gongli"] = "弓漓",
	[":f_gongli"] = "你的回合内，你距离不大于Z的其他角色视为在你的攻击范围内（Z为回合开始时已记录入<b>《<font color='green'>剑缘录</font>》</b>的角色数+1）；" ..
	"一名已受伤且被记录入<b>《<font color='green'>剑缘录</font>》</b>的角色回合开始时，你可以从牌堆随机使用一张装备牌或摸一张牌，令其回复1点体力。",
	["f_gongli:ue"] = "从牌堆随机使用一张装备牌",
	["f_gongli:dc"] = "摸一张牌",
	["$f_gongli1"] = "花间矫捷，快步无影。",
	["$f_gongli2"] = "体态轻盈，出招无形。",
	  --阵亡
	["~f_shensunshangxiang"] = "四水楚歌起，望乡泪满裳......",
	
	--神于吉(吧友DIY)
	["f_shenyuji"] = "神于吉",
	["#f_shenyuji"] = "变幻万千",
	["designer:f_shenyuji"] = "aGbQbEM",
	["cv:f_shenyuji"] = "官方",
	["illustrator:f_shenyuji"] = "猜猜看啊",
	  --回生
	["f_huisheng"] = "回生",
	[":f_huisheng"] = "当你进入濒死状态时，你可以进行一次判定，若结果为红色/黑色，你回复体力至2点，弃置区域内所有牌并摸四张牌，然后删除“回生”中的一种颜色。",
	["f_huisheng:dr"] = "删除“回生”中的红色",
	["f_huisheng:db"] = "删除“回生”中的黑色",
	["f_huishengRedBan"] = "",
	["$f_huishengRedBan"] = "%from 删除了“<font color='yellow'><b>回生</b></font>”中的 <font color='red'><b>红色</b></font>",
	["f_huishengBlackBan"] = "",
	["$f_huishengBlackBan"] = "%from 删除了“<font color='yellow'><b>回生</b></font>”中的 <font color='black'><b>黑色</b></font>",
	["$f_huisheng1"] = "猜猜看啊？", --判定
	["$f_huisheng2"] = "道法玄机，变幻莫测！", --成功
	["$f_huisheng3"] = "道法玄机，竟被参破！", --失败
	  --妙道
	["f_miaodao"] = "妙道",
	[":f_miaodao"] = "出牌阶段结束时，你可以将至多两张手牌置于武将牌上，称为“道”。你失去最后一张“道”时，你摸两张牌。结束阶段，你摸X张牌（X为你的“道”数<font color='red'><b>且至多为4</b></font>）。",
	["f_syjDao"] = "道",
	["f_miaodaoPush"] = "请将至多两张手牌置于武将牌上，称为“道”",
	["$f_miaodao1"] = "心之所向，势不可挡！",
	["$f_miaodao2"] = "大道之行，为国为民！",
	  --异法
	["f_yifa"] = "异法",
	[":f_yifa"] = "每轮限两次，一名角色的准备阶段，你可以将一张手牌或“道”置于牌堆顶，然后选择移动场上的一张牌或获得当前回合角色区域内的一张牌。",
	["f_yifana"] = "",
	["f_yifa:handcard"] = "将一张手牌置于牌堆顶",
	["f_yifa:pilecard"] = "将一张“道”置于牌堆顶",
	["@f_yifa-Dao"] = "请选择一张“道”，将其置于牌堆顶",
	["~f_yifa"] = "如果这是你的最后一张“道”，它应该将会回到你的手心哦",
	["f_yifa:move"] = "移动场上的一张牌",
	["f_yifa:get"] = "获得当前回合角色区域内的一张牌",
	["f_yifa_Move"] = "你可以选择一名场上有牌的角色",
	["@f_yifa_Move-to"] = "请选择移动的目标角色",
	["$f_yifa1"] = "不识天数，在劫难逃！",
	["$f_yifa2"] = "凡人仇怨，皆由心生！",
	  --阵亡
	["~f_shenyuji"] = "治得了病，治不了心啊......",
	
	--神庞统(吧友DIY)
	["f_shenpangtong"] = "神庞统",
	["#f_shenpangtong"] = "断案如神",
	["designer:f_shenpangtong"] = "luzhuoyuty38",
	["cv:f_shenpangtong"] = "官方,老/新三国",
	["illustrator:f_shenpangtong"] = "凝聚永恒",
	  --凤雏
	["f_fengchu"] = "凤雏",
	[":f_fengchu"] = "回合开始时，你选择三项：\
	1.加1点体力上限；\
	2.回复1点体力；\
	3.摸两张牌；\
	4.本回合“落凤”失效。",
	["f_fengchu:1"] = "加1点体力上限",
	["f_fengchu:2"] = "回复1点体力",
	["f_fengchu:3"] = "摸两张牌",
	["f_fengchu:4"] = "本回合“落凤”失效",
	["$f_fengchu1"] = "朱雀之火，永不熄灭！",
	["$f_fengchu2"] = "太阳终将再度升起！",
	  --神判
	["f_shenpan"] = "神判",
	["f_shenpanTarget"] = "神判",
	[":f_shenpan"] = "出牌阶段，你可以弃置一张牌并指定一名本回合未以此法指定过的角色，执行所有对应效果：\
	其的上个回合：\
	1.若其获得<font color='blue'><s>或弃置</s></font>过其他角色的牌<font color='red'><b>或有其他角色的牌被弃置</b></font>，其弃置两张牌；\
	2.若其造成过伤害，其受到无来源的1点伤害；\
	3.若其杀死过其他角色，其失去1点体力。",
	["f_shenpanOne"] = "神判:盗案",
	[":&f_shenpanOne"] = "其于上回合获得过其他角色的牌/有其他角色的牌被弃置",
	["f_shenpanTwo"] = "神判:伤案",
	[":&f_shenpanTwo"] = "其于上回合造成过伤害",
	["f_shenpanThree"] = "神判:命案",
	[":&f_shenpanThree"] = "其于上回合杀死过其他角色",
	["f_shenpanTMG"] = "",
	["$f_shenpan1"] = "李六，你知罪吗？", --老三国
	["$f_shenpan2"] = "区区百里小县，有何难人的事？", --新三国
	  --落凤
	["f_luofeng"] = "落凤",
	[":f_luofeng"] = "锁定技，回合结束时，你进行一次判定：若判定点数为5，你失去所有体力值，失去技能“凤雏”、“落凤”。",
	["f_luofengAnimate"] = "image=image/animate/luofengpo_DiLu.png",
	["$f_luofeng1"] = "我道号“凤雏”，此地名“落凤坡”，难道我此行果真不利？", --老三国(判定)
	["$f_luofeng2"] = "看来，这是上天赐我的葬身之地呀！哈哈哈哈哈哈......", --新三国(中奖)
	  --阵亡
	["~f_shenpangtong"] = "白马...白马...主公的白马！再也不能同你伴随主公，驰骋天下了......", --老三国
	--==作者的设计思路==--
	--[[神判来自一日断百日案首次在蜀展示能力；点数5对应的卢]]
	--==================--
	
	--神蒲元(自己DIY)
	["f_shenpuyuan"] = "神蒲元", --巨匠
	["#f_shenpuyuan"] = "万古神兵",
	["f_shenpuyuanx"] = "神蒲元", --侠匠
	["#f_shenpuyuanx"] = "万古神兵",
	["designer:f_shenpuyuan"] = "时光流逝FC",
	["cv:f_shenpuyuan"] = "官方",
	["illustrator:f_shenpuyuan"] = "M云涯",
	  --天赐
	["f_tianci"] = "天赐",
	["f_tianciStart"] = "天赐",
	["f_tianciATA"] = "天赐",
	[":f_tianci"] = "<b>命运技<font color='red'>[神蒲元]</font>，</b>锁定技，游戏开始时，你将获得一件由上天赐予的“神兵”：【天雷刃】。然后你选择一项：\
	<font color='blue'><b>《侠匠之路》</b></font>：你装备之，成为<b>“<font color='blue'>侠匠</font>”</b>并更换头像。之后你的每个回合开始时，" ..
	"若你没有【天雷刃】，（无论你是否有该技能）你重新获得之。\
	<font color='red'><b>《巨匠之路》</b></font>：你销毁之，成为<b>“<font color='red'>巨匠</font>”</b>并建立<font color='red'>//<b>神兵库</b>//</font>，" ..
	"然后从<font color='red'>//<b>神兵库</b>//</font>中随机获得两张装备牌。\
	<font color='orange'><b>(注：出现重复将以及同将模式中，改为只有其中一位“神蒲元”会触发“天赐”，且玩家优先)</b></font>",
	["f_tianciFate"] = "[天赐]请选择你的命运之路",
	["$f_tianciFate"] = "今日，上天赐予了神蒲元一件“神兵”【天雷刃】，\
	属于神蒲元的命运，从此刻开始......",
	["f_tianciFate:XJ"] = "《侠匠之路》",
	["f_tianciFate:JJ"] = "《巨匠之路》",
	["fXiaJiang"] = "侠匠",
	["fJuJiang"] = "巨匠",
	["#DestroyEqiup"] = "%card 被销毁",
	["$f_tianci1"] = "吹毛断发，血不沾锋，当车鼠辈观之尽皆丧胆！", --侠匠（包括后续重得天雷刃）
	["$f_tianci2"] = "切金断玉，削铁如泥，执吾兵者可为万人之敌！", --巨匠
	  --奇工
	["f_qigong"] = "奇工",
	["mini_f_qigong"] = "奇工",
	["pro_f_qigong"] = "奇工",
	[":f_qigong"] = "出牌阶段限一次，你可以弃置X张装备区里的牌（也可以不弃置），进行“<font color='black'><b>工之锻造</b></font>”：你依次亮出牌堆顶的总计2*（X+1）张牌：" ..
	"若为装备牌，你令一名有对应装备栏的角色使用之（若该角色没有对应的装备栏，改为获得之）；否则你将其置于武将牌上，称为“陨铁”。" ..
	"若此次“<font color='black'><b>工之锻造</b></font>”的结果为你(此次)“锻造”出的装备牌数大于你(此次)获得的“陨铁”数，你于此回合可以再次发动“奇工”。",
	["f_YT"] = "陨铁",
	["f_qigongUse"] = "请选择一名角色，其使用这张【<font color='yellow'>%src<b></b></font>】<br />（若其没有对应装备栏，改为获得）",
	["$f_qigong1"] = "匠心独运，自通器具。",
	["$f_qigong2"] = "能工巧匠，百炼成器。",
	  --灵器
	["f_lingqi"] = "灵器",
	["f_lingqix"] = "灵器", --侠匠
	["f_lingqix_poison"] = "灵器[毒杀]",
	["f_lingqij"] = "灵器", --巨匠
	["f_lingqiSlashs"] = "灵器",
	["f_lingqiSlashMD"] = "灵器",
	[":f_lingqi"] = "出牌阶段，你可以将一张装备牌按以下规则使用：\
	1.若你为<b>“<font color='blue'>侠匠</font>”</b>，当作无距离限制的【<font color=\"#99CC00\">毒杀*</b></font>(黑桃)/冰杀(梅花)/雷杀(方块)/火杀(红桃)】使用。\
	2.若你为<b>“<font color='red'>巨匠</font>”</b>，当作无视防具的普通【杀】使用。\
	<font color=\"#99CC00\">*【<b>毒杀</b>】：与属性【杀】不同的是，其性质等同于普通【杀】，但造成的伤害转化为毒素伤害，且造成伤害后根据目标已损失的体力值，" ..
	"有概率令其失去1点体力。（概率公式：目标已损失的体力值数*20%，至多100%）</font>",
	["$f_lingqi1"] = "良禽择木，佳刃择水。", --侠匠
	["$f_lingqi2"] = "融古铸今，通晓百刃。", --巨匠
	  --神匠
	["f_shenjiang"] = "神匠",
	["f_shenjiangVAE"] = "神匠·视为装备",
	["f_shenjiangSBK"] = "神匠",
	["f_shenjiangsbk"] = "神匠",
	["f_shenjiangAC"] = "神匠",
	[":f_shenjiang"] = "出牌阶段，你可以弃置四张“陨铁”并选择一名角色，进行“<font color=\"#FFFF00\"><b>神之锻造</b></font>”：\
	1.若你为<b>“<font color='blue'>侠匠</font>”</b>，你展示一张手牌并重铸，根据你以此法展示的牌的花色，令该角色视为装备【混毒弯匕[黑桃]/水波剑[梅花]/烈淬刀[方块]/红锻枪[红桃]】直到其回合结束。\
	2.若你为<b>“<font color='red'>巨匠</font>”</b>，你<b>打造</b>出<font color='red'>//<b>神兵库</b>//</font>中的一种装备牌，然后该角色获得，并可立即装备之。",
	["@f_shenjiangRecast"] = "请展示并重铸一张手牌，根据此牌花色令目标获得相应效果",
	["f_shenjiang:"] = "神匠:",
	["$f_shenjiangSBK"] = "通过“<font color=\"#FFFF00\"><b>神之锻造</b></font>”，%from 从 <font color='red'>//<b>神兵库</b>//</font> " ..
	"打造出“<font color='yellow'><b>神兵·%card</b></font>”",
	["@f_shenjiangSBK"] = "请选择<font color='red'>//<b>神兵库</b>//</font>中的一件“<font color='yellow'><b>神兵</b></font>”打造",
	["@f_shenjiangSBK_use"] = "你可以装备这张【<font color='yellow'>%src<b></b></font>】",
	["$f_shenjiang1"] = "蜀江爽烈，正合淬刃，唯神匠可尽其用。", --侠匠
	["$f_shenjiang2"] = "熔金造器，得天独厚，非常法可及也。", --巨匠
	--==【“神兵库”】==--（混毒弯匕、水波剑、烈淬刀、红锻枪；乌铁锁链、五行鹤翎扇、护心镜、黑光铠、天机图、太公阴符：游戏主体已有，就不再写了。）\
	["spy_shenbingku"] = "神兵库",
	["JJ_shenbingku"] = "巨匠·“神兵库”",
	[":spy_shenbingku"] = "神蒲元的<font color='red'>//<b>神兵库</b>//</font>内含<b>22</b>种装备牌（带*的为游戏主体已有的），分别为：\
	↑武器牌：【混毒弯匕*】、【水波剑*】、【烈淬刀*】、【红锻枪*】；【无双方天戟】、【鬼龙斩月刀】、【赤血青锋】、【镔铁双戟】、【乌铁锁链*】、【五行鹤翎扇*】\
	☯防具牌：【玲珑狮蛮带】、【红棉百花袍】、【国风玉袍】、【奇门八阵】、【护心镜*】、【黑光铠*】\
	☆宝物牌：【束发紫金冠】、【虚妄之冕】、【天机图*】、【太公阴符*】、【三略】、【照骨镜】",
	--1.混毒弯匕(已有)
	----
	--2.水波剑(已有)
	----
	--3.烈淬刀(已有)
	----
	--4.红锻枪(已有)
	----
	--5.无双方天戟
	["_f_wushuangfangtianji"] = "无双方天戟", --♦Q
	["Fwushuangfangtianji"] = "无双方天戟",
	[":_f_wushuangfangtianji"] = "装备牌·武器<br /><b>攻击范围</b>：４\
	<b>武器技能</b>：当你使用【杀】对目标角色造成伤害后，可以摸一张牌或弃置其一张牌。",
	["Fwushuangfangtianji:1"] = "摸一张牌",
	["Fwushuangfangtianji:2"] = "弃置%src的一张牌",
	--6.鬼龙斩月刀
	["_f_guilongzhanyuedao"] = "鬼龙斩月刀", --♠5
	["Fguilongzhanyuedao"] = "鬼龙斩月刀",
	[":_f_guilongzhanyuedao"] = "装备牌·武器<br /><b>攻击范围</b>：３\
	<b>武器技能</b>：锁定技，你使用的红色【杀】不能被【闪】响应。",
	--7.赤血青锋
	["_f_chixieqingfeng"] = "赤血青锋", --♠6
	["Fchixieqingfeng"] = "赤血青锋",
	[":_f_chixieqingfeng"] = "装备牌·武器<br /><b>攻击范围</b>：２\
	<b>武器技能</b>：锁定技，你使用的【杀】结算结束前，目标角色不能使用或打出手牌，且此【杀】无视其防具。",
	--8.镔铁双戟
	["_f_bingtieshuangji"] = "镔铁双戟", --♦K
	["Fbingtieshuangji"] = "镔铁双戟",
	["Fbingtieshuangjix"] = "镔铁双戟",
	["FbingtieshuangjiClear"] = "镔铁双戟",
	[":_f_bingtieshuangji"] = "装备牌·武器<br /><b>攻击范围</b>：３\
	<b>武器技能</b>：你的【杀】被抵消后，你可以失去1点体力，然后获得此【杀】并摸一张牌，本回合使用【杀】的次数+1。",
	--9.乌铁锁链(已有)
	----
	--10.五行鹤翎扇(已有)
	----
	--11.玲珑狮蛮带
	["_f_linglongshimandai"] = "玲珑狮蛮带", --♠2
	["Flinglongshimandai"] = "玲珑狮蛮带",
	[":_f_linglongshimandai"] = "装备牌·防具<br /><b>防具技能</b>：当其他角色使用牌指定你为唯一目标后，你可以进行一次判定，若判定结果为红桃，则此牌对你无效。", --“笃烈”？
	--12.红棉百花袍
	["_f_hongmianbaihuapao"] = "红棉百花袍", --♣A
	["Fhongmianbaihuapao"] = "红棉百花袍",
	[":_f_hongmianbaihuapao"] = "装备牌·防具<br /><b>防具技能</b>：锁定技，防止你受到的属性伤害。",
	--13.国风玉袍
	["_f_guofengyupao"] = "国风玉袍", --♠9
	["Fguofengyupao"] = "国风玉袍",
	[":_f_guofengyupao"] = "装备牌·防具<br /><b>防具技能</b>：锁定技，你不能成为其他角色使用普通锦囊牌的目标。",
	--14.奇门八阵
	["_f_qimenbazhen"] = "奇门八阵", --♠2
	["Fqimenbazhen"] = "奇门八阵",
	[":_f_qimenbazhen"] = "装备牌·防具<br /><b>防具技能</b>：锁定技，其他角色使用的【杀】对你无效。",
	--15.护心镜(已有)
	----
	--16.黑光铠(已有)
	----
	--17.束发紫金冠
	["_f_shufazijinguan"] = "束发紫金冠", --♦A
	["Fshufazijinguan"] = "束发紫金冠",
	[":_f_shufazijinguan"] = "装备牌·宝物<br /><b>宝物技能</b>：准备阶段，你可以对一名其他角色造成1点伤害。",
	--18.虚妄之冕
	["_f_xuwangzhimian"] = "虚妄之冕", --♣4
	["Fxuwangzhimian"] = "虚妄之冕",
	["Fxuwangzhimianx"] = "虚妄之冕",
	[":_f_xuwangzhimian"] = "装备牌·宝物<br /><b>宝物技能</b>：锁定技，摸牌阶段，你额外摸两张牌；你的手牌上限-1。",
	--19.天机图(已有)
	----
	--20.太公阴符(已有)
	----
	--21.三略
	["_f_sanlve"] = "三略", --♠5
	["Fsanlve"] = "三略",
	["Fsanlvex"] = "三略",
	["Fsanlvey"] = "三略",
	[":_f_sanlve"] = "装备牌·宝物<br /><b>宝物技能</b>：锁定技，你的攻击<font color='blue'><s>范围</s></font><font color='red'><b>距离</b></font>+1；" ..
	"你的手牌上限+1；你出牌阶段使用【杀】的次数+1。", --四个字：你是个不够帅的营
	--22.照骨镜
	["_f_zhaogujing"] = "照骨镜", --♦A
	["Fzhaogujing"] = "照骨镜",
	["fzhaogujing"] = "照骨镜",
	["@Fzhaogujing-showcard"] = "你可以展示一张基本牌或普通锦囊手牌，然后可以立即使用之",
	["~Fzhaogujing"] = "注意：只能用来响应而不能主动使用的牌将只会展示，不被允许使用",
	["@Fzhaogujing_use"] = "你可以使用这张【<font color='yellow'><b>%src</b></font>】",
	[":_f_zhaogujing"] = "装备牌·宝物<br /><b>宝物技能</b>：出牌阶段结束时，你可以展示一张基本或普通锦囊手牌，" ..
	"<font color='blue'><s>视为</s></font><font color='red'><b>然后</b></font>你<font color='red'><b>可以</b></font>使用之。",
	--================--
	  --阵亡
	["~f_shenpuyuan"] = "[侠匠]:一生铸兵，何日可见铸剑为犁之景？\
	[巨匠]:望有一日，能铸甲销戈。",
	["~f_shenpuyuanx"] = "一生铸兵，何日可见铸剑为犁之景？",
	
	--神马钧(自己DIY)
	["f_shenmajun"] = "神马钧",
	["#f_shenmajun"] = "鬼斧神工",
	["designer:f_shenmajun"] = "时光流逝FC",
	["cv:f_shenmajun"] = "官方",
	["illustrator:f_shenmajun"] = "第七个桔子",
	  --研发
	["f_yanfa"] = "研发",
	[":f_yanfa"] = "锁定技，游戏开始时，你将所有<font color='gray'><b>“隐藏游戏卡牌”</b></font>加入牌堆。" ..
	"回合开始时，你从牌堆随机获得一张<font color='gray'><b>“隐藏游戏卡牌”</b></font>。" ..
	"<font color='red'>（<font color='gray'><b>“隐藏游戏卡牌”</b></font>范围：<font color='black'>游戏主体</font>、" ..
	"<font color=\"#FFFF00\">“各服神武将”扩展包(包括“附赠包”;不包括:实质内容为空白的卡牌,“灭世·神兵”,“挈挟”)</font>、" ..
	"<font color=\"#CC99FF\">“海外服”扩展包<b>[作者:lua学生]</b></font>、" ..
	"<font color=\"#66FFFF\">“江山如故”扩展包<b>[作者:小珂酱]</b></font>；" ..
	"若你未装有相应补丁，则补丁中的卡牌不会加入游戏）</font>",
	["f_yanfaAnimate"] = "image=image/animate/f_yanfa.png",
	["$f_yanfa1"] = "吾所欲作者，国之精器、军之要用也。",
	["$f_yanfa2"] = "路未尽，铸不止。",
	  --机神
	["f_jishen"] = "机神",
	["f_jishenBUFF"] = "机神的加护",
	["f_jishenOF"] = "机神",
	[":f_jishen"] = "出牌阶段限一次，你可以令一名角色使用牌堆中的一张由你选择的副类别的装备牌（你从随机给出的X个选项中选择一个，X为你的体力上限且至多为5），" ..
	"然后根据你选择的副类别，其获得对应效果直到其回合结束：\
	1.<b>武器牌，</b>其使用非虚拟非转化牌造成的伤害翻倍；\
	2.<b>防具牌，</b>其受到不因非虚拟非转化牌造成的伤害减半（向下取整）；\
	3.<b>+1马牌，</b>其回复量翻倍；\
	4.<b>-1马牌，</b>其与其他角色的距离减去其装备区牌数的一半（向上取整，至少为1），其使用牌不可被其距离为1的目标角色响应；\
	5.<b>宝物牌，</b>其每使用一张“隐藏游戏卡牌”，摸一张牌。",
	["f_jishen:0"] = "武器牌",
	["f_jishen:1"] = "防具牌",
	["f_jishen:2"] = "+1马牌",
	["f_jishen:3"] = "-1马牌",
	["f_jishen:4"] = "宝物牌",
	["jsweapon"] = "武器加伤",
	["jsarmor"] = "防具减伤",
	["jsdefen"] = "+1马增回",
	["jsoffen"] = "-1马减距",
	["jstrsr"] = "宝物摸牌",
	["$f_jishen1"] = "另辟蹊径博君乐，盛世美景百戏中。",
	["$f_jishen2"] = "机关精巧，将军可看在眼里？",
	  --阵亡
	["~f_shenmajun"] = "污泥覆玉，顽石掩璞，痛哉痛哉！.....",
	
	--神司马炎(吧友DIY)
	  --初版
	["f_shensimayan"] = "神司马炎-初版",
	["&f_shensimayan"] = "神司马炎",
	["#f_shensimayan"] = "晋武大帝",
	["designer:f_shensimayan"] = "aGbQbEM", --“卯兔包”落选稿
	["cv:f_shensimayan"] = "(文字播报)", --在尝试一种全新的方式
	["illustrator:f_shensimayan"] = "率土之滨",
	  --征灭
	["f_zhengmie"] = "征灭",
	[":f_zhengmie"] = "<font color='green'><b>每轮限三次，</b></font>每名角色的准备阶段，你可以令其对一名你指定的角色使用一张无距离限制且不计入次数限制的【杀】。" ..
	"若此【杀】造成伤害，你摸一张牌并获得1枚“征”标记。",
	["fZHENG"] = "征",
	["f_zhengmie-invoke"] = "你可以发动技能“征灭”<br /> 提示：选择一名角色，其成为你令%src使用【杀】的目标",
	["@f_zhengmie-slash"] = "你是否响应“征灭”，对%src使用一张【杀】？",
	["$f_zhengmie1"] = "平定秦凉，安抚边境！",
	["$f_zhengmie2"] = "击灭东吴，一统山河！",
	  --帝运
	["f_diyun"] = "帝运",
	[":f_diyun"] = "觉醒技，准备阶段，若你的“征”标记数至少为3枚，你减1点体力上限，回复1点体力或摸两张牌，获得技能“奢靡”。",
	["f_diyun:rec"] = "回复1点体力",
	["f_diyun:drw"] = "摸两张牌",
	["$f_diyun1"] = "三分归一，帝运龙兴！",
	["$f_diyun2"] = "太康盛世，天下繁荣！",
	    --奢靡
	  ["dy_shemi"] = "奢靡",
	  ["dy_shemiSlashBuff"] = "奢靡",
	  ["dy_shemiDeBuff"] = "奢靡",
	  [":dy_shemi"] = "摸牌阶段开始时，你可以选择至多两项：\
	  1.于此阶段多摸两张牌；\
	  2.出牌阶段可以多使用一张【杀】且使用【杀】的目标上限+1。\
	  你每选择一项，本回合的手牌上限-1；结束阶段，若你没有手牌且装备区里有牌，你弃置一张装备区里的牌。",
	  ["dy_shemi:1"] = "此摸牌阶段多摸两张牌",
	  ["dy_shemi:2"] = "出牌阶段可以多使用一张【杀】且使用【杀】的目标上限+1",
	  ["$dy_shemi1"] = "君臣赛富，纵情奢华！",
	  ["$dy_shemi2"] = "尽收佳丽，羊车巡幸！",
	--
	["f_shensimayan_sktc"] = "神司马炎-技能台词",
	[":f_shensimayan_sktc"] = "\
	【征灭】平定秦凉，安抚边境！/击灭东吴，一统山河！\
	【帝运】三分归一，帝运龙兴！/太康盛世，天下繁荣！\
	【奢靡】君臣赛富，纵情奢华！/尽收佳丽，羊车巡幸！",
	  --阵亡
	["~f_shensimayan"] = "宗室同心，朕的江山定会永世长久......",
	
	  --正式版
	["f_shensimayan_f"] = "神司马炎",
	["#f_shensimayan_f"] = "晋武大帝",
	["designer:f_shensimayan_f"] = "aGbQbEM",
	["cv:f_shensimayan_f"] = "(文字播报)",
	["illustrator:f_shensimayan_f"] = "率土之滨",
	  --征灭
	["f_zhengmie_f"] = "征灭",
	[":f_zhengmie_f"] = "<font color='green'><b>每轮限三次，</b></font>每名角色的准备阶段，你可以令其<b>视为</b>对一名你指定的角色使用一张无距离限制且不计入次数限制的【杀】。" ..
	"若此【杀】造成伤害，你摸一张牌并获得1枚“征”标记。",
	["fZHENGf"] = "征",
	["f_zhengmie_f-invoke"] = "你可以发动技能“征灭”<br /> 提示：选择一名角色，其成为你令%src视为使用【杀】的目标",
	["$f_zhengmie_f1"] = "平定秦凉，安抚边境！",
	["$f_zhengmie_f2"] = "击灭东吴，一统山河！",
	  --帝运+奢靡（同初版）
	  --阵亡
	["~f_shensimayan_f"] = "宗室同心，朕的江山定会永世长久......",
	--
	
	--神刘协(吧友DIY)
	["f_shenliuxie"] = "神刘协",
	["#f_shenliuxie"] = "天命所归",
	["designer:f_shenliuxie"] = "通缉令绘制",
	["cv:f_shenliuxie"] = "官方",
	["illustrator:f_shenliuxie"] = "第七个桔子",
	  --天子
	["f_skysson"] = "天子",
	[":f_skysson"] = "出牌阶段限一次，你可以弃置一张牌并选择一名角色，令其选择是否对另一名你选择的角色使用一张【杀】" ..
	"<font color='red'><b>(注:实际发动时要先选两名角色，然后选择是由其中的哪名角色使用【杀】)</b></font>：若其选“否”，视为你对其使用一张【杀】。" ..
	"每个回合限一次，当你需要使用或打出一张【闪】时，你可以选择一名角色，令其选择是否替你使用或打出一张【闪】：若其选“否”，你获得其区域内的一张牌。",
	["f_skysson-slashfrom"] = "请选择使用【杀】的角色",
	["@f_skysson-slash"] = "你是否遵从“天子”的命令，对%src使用一张【杀】？",
	["f_skysson-usejink"] = "请选择一名角色，询问其是否代替你出【闪】",
	["@f_skysson-jink"] = "你是否遵从“天子”的命令，替%src使用一张【闪】？",
	["$to_f_shenliuxie_fou"] = "%to 没有执行 %from 的要求，选择了<font color='red'><b>否</b></font>",
	["$f_skysson1"] = "大汉天命之传承，皆在吾身！",
	["$f_skysson2"] = "朕乃天子，定得天助！",
	  --国祚
	["f_guozuo"] = "国祚",
	[":f_guozuo"] = "锁定技，游戏开始时，你废除判定区；你的体力上限不会因为其他<font color='blue'><s>角色的</s></font>技能的变化而变化" ..
	"<font color='blue'><b>(伪实现:体力上限变动时，立即调整回来)</b></font>；" ..
	"每当场上一种势力的角色全部阵亡时，你加1点体力上限并回复1点体力，本局摸牌阶段的摸牌数+1。",
	["f_guozuoDraw"] = "国祚摸牌",
	["$f_guozuo1"] = "炎汉的国运，请再帮我一把！",
	["$f_guozuo2"] = "这江山，哪能轻易换主！",
	  --傀儡
	["f_kuilei"] = "傀儡",
	[":f_kuilei"] = "限定技，当你处于濒死状态时，你可以选择一名<font color='red'><b>其他</b></font>角色，其选择是否替你使用一张【桃】：\
	1.若其选“是”，则其获得技能“天子”并获得1枚“挟天子”标记，你将体力回复至体力上限，失去技能“天子”，获得技能“天命”、“密诏”；\
	2.若其选“否”，其弃置所有牌，且当你脱离濒死状态后，此技能重置(视为未发动过)。", --emm...要是自己挟自己的话会不会显得很奇怪？所以后续我还是加了限制只能选其他人
	["@f_kuilei"] = "傀儡",
	["f_shenliuxie_kuilei"] = "傀儡·神刘协",
	["f_Xtz"] = "挟天子",
	["f_kuilei_jieguo"] = "哪位将军，救朕于危急？",
	["@f_kuilei-peach"] = "你是否扶持“傀儡”%src，对其使用一张【桃】？",
	["$f_kuilei1"] = "孤，与将军共进退~", --艹，好屑
	["$f_kuilei2"] = "吾乃真龙天子，岂能坐以待毙？",
	  --汉帝
	["f_handi"] = "汉帝",
	[":f_handi"] = "觉醒技，当有“挟天子”标记的角色死亡时，你获得技能“天子”、“乱击”、“图射”，失去技能“天命”、“密诏”。",
	["f_shenliuxie_handi"] = "汉帝·神刘协",
	["$f_handi1"] = "朕祈上帝诸神，佑我汉室不衰！",
	["$f_handi2"] = "朕乃天命所归，逆臣岂敢无礼！",
	  --阵亡
	["~f_shenliuxie"] = "皇权旁落，忠良尽丧，无人...为朕分忧矣......",
	
	--新神刘禅(对吧友DIY的翻新)
	["f_shenliushan_new"] = "新神刘禅",
	["&f_shenliushan_new"] = "神刘禅",
	["#f_shenliushan_new"] = "单挑皇子",
	["designer:f_shenliushan_new"] = "luzhuoyuty38",
	["cv:f_shenliushan_new"] = "官方",
	["illustrator:f_shenliushan_new"] = "真三国无双6",
	  --乐极+无忧（同原版）
	  --丹砂！！
	["f_dansha_new"] = "单杀",
	[":f_dansha_new"] = "当【乐不思蜀】离开你的判定区时，你可以令一名角色[失去X点体力并弃置X张牌]（X为1；主公技，若你的身份为“主公(包括“主将”和“地主”)”，X值翻倍）。" ..
	"若有角色因此技能死亡，你[失去此技能]（主公技，若你的身份为“主公(包括“主将”和“地主”)”，改为：失去此技能并获得技能“思蜀”）。",
	--["$f_dansha_new1"] = "",
	--["$f_dansha_new2"] = "",
	  --阵亡
	["~f_shenliushan_new"] = "五十四州王霸业，怎甘抛弃属他人......",
	
	--神-曹丕&甄姬(吧友DIY)
	["god_caopi_zhenji"] = "神-曹丕＆甄姬",
	["&god_caopi_zhenji"] = "神曹丕甄姬",
	["#god_caopi_zhenji"] = "洛水多殇",
	["designer:god_caopi_zhenji"] = "俺的西木野Maki(包括lua代码编写)",
	["cv:god_caopi_zhenji"] = "官方",
	["illustrator:god_caopi_zhenji"] = "DH",
	  -->曹丕
	["god_caopi_zhenji_m"] = "神·曹丕",
	["&god_caopi_zhenji_m"] = "神曹丕",
	["#god_caopi_zhenji_m"] = "霸业的继承者",
	["designer:god_caopi_zhenji_m"] = "俺的西木野Maki",
	["cv:god_caopi_zhenji_m"] = "官方",
	["illustrator:god_caopi_zhenji_m"] = "DH",
	  -->甄姬
	["god_caopi_zhenji_f"] = "神·甄姬",
	["&god_caopi_zhenji_f"] = "神甄姬",
	["#god_caopi_zhenji_f"] = "薄幸的美人",
	["designer:god_caopi_zhenji_f"] = "俺的西木野Maki",
	["cv:god_caopi_zhenji_f"] = "官方",
	["illustrator:god_caopi_zhenji_f"] = "DH",
	  --洛殇
	["diy_k_luoshang"] = "洛殇",
	["diy_k_luoshangCard"] = "洛殇",
	[":diy_k_luoshang"] = "①游戏开始时，你可以选择将此武将牌变更为“神·曹丕”或“神·甄姬”，然后你获得3枚“洛殇”标记。回合开始时，你可以进行判定：" ..
	"（“洛殇”判定）若结果为黑色，则你获得1枚“洛殇”标记，且于判定牌生效后你获得之，然后你可以再次发动“洛殇”进行判定。\
	②每当一名其他角色死亡时，你可以获得其所有牌，然后你可以弃置其中所有黑色牌并获得等量枚“洛殇”标记，然后你可以发动一次“洛殇”判定。\
	③<font color='green'><b>出牌阶段限X次，</b></font>若X大于0，你可以弃置1枚“洛殇”标记进行一次“洛殇”判定。在你的“洛殇”判定牌生效前，你可以弃置1枚“洛殇”标记，" ..
	"然后从牌堆顶亮出一张牌代替之。（X为你的“洛殇”标记数）",
	["gcz_losehp"] = "失去体力",
	["gcz_losemark"] = "弃置标记",
	["gcz_throwBlack"] = "弃置黑色牌",
	  ["gcz_throwBlack:yes"] = "是（弃置所有黑色牌并获得等量枚“洛殇”标记）",
	  ["gcz_throwBlack:no"] = "否（不弃牌）",
	["gcz_skinchange"] = "选择武将性别", --"变更武将性别",
	  ["gcz_skinchange:caopi"] = "男（神·曹丕）",
	  ["gcz_skinchange:zhenji"] = "女（神·甄姬）",
	["$diy_k_luoshang1"] = "群燕辞归鹄南翔，念君客游思断肠。", --神·曹丕1
	["$diy_k_luoshang2"] = "霜露纷兮交下，木叶落兮凄凄。", --神·曹丕2
	["$diy_k_luoshang3"] = "翩若惊鸿，婉若游龙。", --神·甄姬1
	["$diy_k_luoshang4"] = "神光离合，乍阴乍阳。", --神·甄姬2
	  --阵亡
	["~god_caopi_zhenji"] = "(神·曹丕)建平所言八十，谓昼夜也，吾其决矣……/(神·甄姬)揽騑辔以抗策，怅盘桓而不能去。",
	["~god_caopi_zhenji_m"] = "建平所言八十，谓昼夜也，吾其决矣……", --神·曹丕
	["~god_caopi_zhenji_f"] = "揽騑辔以抗策，怅盘桓而不能去。", --神·甄姬
	
	--十长逝(网络灵感)
	["f_ten"] = "十长逝",
	["#f_ten"] = "阴灵殿主",
	["designer:f_ten"] = "官方,网络",
	["cv:f_ten"] = "官方,网络",
	["illustrator:f_ten"] = "官方,网络",
	  --党锢
	["f_danggu"] = "党锢",
	[":f_danggu"] = "锁定技，游戏开始时，你获得十张不同的“阴灵”牌，然后你进行一次“结党”。当你结束<font color='purple'><b>☠装死状态</b></font>后，" ..
	"你进行一次“结党”，然后你摸四张牌。你拥有你亮出“阴灵”牌的技能。\
	----------\
	<font color='blue'><b>“阴灵”牌一览：</b>张让(“灭吴”[+无限标记])/赵忠(“界破军”)/孙璋(“勤政”)/毕岚(“(线下版)慧识”)/夏恽(“义争”[+体力上限保护机制])/" ..
	"韩悝(“巧思”)/栗嵩(“魄袭”)/段珪(“谋烈弓”)/郭胜(“评才”)/高望(“<font color='black'><s>龙魂</s></font>安弱”)</font>\
	----------\
	<font color='red'><b>“结党”过程：</b>系统随机给玩家一张未亮出过的“阴灵”牌作为主将，玩家再从剩余四张（若不足四张，则为全部）未亮出过的“阴灵”牌中选择一张作为副将。" ..
	"每张“阴灵”牌限完成一次“结党”。</font>",
	--==“阴灵”牌==--
	["f_danggu_yinling"] = "阴灵",
	--张让（杜预）
	["f_ten_dadi"] = "十长逝·张让",
	["&f_ten_dadi"] = "张让",
	["$f_danggu1"] = "罗琦朱紫，皆若吾等手中傀儡。", --原技能：滔乱
	["f_ten_dadiAniamte"] = "image=image/animate/f_ten_dadi.png",
	["f_ten_dadi_extreme"] = "灭吴·无限标记",
	--赵忠（界徐盛）
	["f_ten_ermei"] = "十长逝·赵忠",
	["&f_ten_ermei"] = "赵忠",
	["$f_danggu2"] = "逆臣乱党，都要受这啄心之刑。", --原技能：鸱咽
	["f_ten_ermeiAniamte"] = "image=image/animate/f_ten_ermei.png",
	--孙璋（骆统）
	["f_ten_sunzhang"] = "十长逝·孙璋",
	["&f_ten_sunzhang"] = "孙璋",
	["$f_danggu3"] = "在宫里当差，还不是为这“利”字。", --原技能：自谋
	["f_ten_sunzhangAniamte"] = "image=image/animate/f_ten_sunzhang.png",
	--毕岚（神郭嘉）
	["f_ten_bilan"] = "十长逝·毕岚",
	["&f_ten_bilan"] = "毕岚",
	["$f_danggu4"] = "修得广厦千万，可庇汉室不倾。", --原技能：庀材
	["f_ten_bilanAniamte"] = "image=image/animate/f_ten_bilan.png",
	--夏恽（杨彪）
	["f_ten_xiayun"] = "十长逝·夏恽",
	["&f_ten_xiayun"] = "夏恽",
	["$f_danggu5"] = "上蔽天听，下诓朝野。", --原技能：谣诼
	["f_ten_xiayunAniamte"] = "image=image/animate/f_ten_xiayun.png",
	["f_ten_xiayun_mhp"] = "义争·体力上限保护机制",
	--韩悝（马钧）
	["f_ten_hanli"] = "十长逝·韩悝",
	["&f_ten_hanli"] = "韩悝",
	    --巧思
	  ["hl_qiaosi"] = "巧思",
	  [":hl_qiaosi"] = "出牌阶段限一次，你可以表演<font color='blue'><b>《水转百戏图》</b></font>来赢取相应的牌，然后你选择一项：弃置等量的牌，或将等量的牌交给一名其他角色。\
	  <font color='orange'><b>♘小游戏</b></font><font color='blue'><b>《水转百戏图》</b></font><font color='red'><b>规则：</b></font>\
	  依次选择执行以下六种效果中的总计三种效果：\
	  1.♔【王】获得两张锦囊牌。\
	  2.♙【商】从两张装备牌+一张[杀/酒]中获得一张。（但若你先行选择执行了【将】效果，将改为只能获得一张[杀/酒]）\
	  3.♖【工】从两张[杀]+一张[酒]中获得一张。\
	  4.❃【农】从两张[闪]+一张[桃]中获得一张。\
	  5.♗【士】从两张锦囊牌+一张[闪/桃]中获得一张。（但若你先行选择执行了【王】效果，将改为只能获得一张[闪/桃]）\
	  6.✪【将】获得两张装备牌。",
	  ["ShuiZhuanBaiXiTu"] = "《水转百戏图》",
	  ["ShuiZhuanBaiXiTu:1"] = "【王】(获得两张锦囊牌)",
	  ["ShuiZhuanBaiXiTu:2"] = "【商】(从两张装备牌+一张[杀/酒]中获得一张)",
	  ["ShuiZhuanBaiXiTu:2.5"] = "【商】(获得一张[杀/酒])",
	  ["ShuiZhuanBaiXiTu:3"] = "【工】(从两张[杀]+一张[酒]中获得一张)",
	  ["ShuiZhuanBaiXiTu:4"] = "【农】(从两张[闪]+一张[桃]中获得一张)",
	  ["ShuiZhuanBaiXiTu:5"] = "【士】(从两张锦囊牌+一张[闪/桃]中获得一张)",
	  ["ShuiZhuanBaiXiTu:5.5"] = "【士】(获得一张[闪/桃])",
	  ["ShuiZhuanBaiXiTu:6"] = "【将】(获得两张装备牌)",
	  ["hl_qiaosi:throw"] = "弃置等量的牌",
	  ["hl_qiaosi:give"] = "将等量的牌交给一名其他角色",
	  ["hl_qiaosi-invoke"] = "你可以发动“巧思”<br/> <b>操作提示</b>: 选择一名其他角色→点击确定<br/>",
	  ["hl_qiaosi_exchange"] = "请选择等量的牌交给对方<br/> <b>操作提示</b>: 选择牌直到可以点确定<br/>",
	  ["$hl_qiaosi1"] = "才通墨翟，巧比公输。",
	  ["$hl_qiaosi2"] = "沉机照物，妙思考神。",
	["$f_danggu6"] = "咱家上下打点，自是要废些银子。", --原技能：宵赂
	["f_ten_hanliAniamte"] = "image=image/animate/f_ten_hanli.png",
	--栗嵩（神甘宁）
	["f_ten_lisong"] = "十长逝·栗嵩",
	["&f_ten_lisong"] = "栗嵩",
	["$f_danggu7"] = "同道者为忠，殊途者为奸。", --原技能：窥机
	["f_ten_lisongAniamte"] = "image=image/animate/f_ten_lisong.png",
	--段珪（谋黄忠）
	["f_ten_duangui"] = "十长逝·段珪",
	["&f_ten_duangui"] = "段珪",
	["$f_danggu8"] = "想见圣上？哼哼哼哈哈哈呵~你怕是没这个福分了！", --原技能：叱吓
	["f_ten_duanguiAniamte"] = "image=image/animate/f_ten_duangui.png",
	--郭胜（庞德公）
	["f_ten_guosheng"] = "十长逝·郭胜",
	["&f_ten_guosheng"] = "郭胜",
	["$f_danggu9"] = "离心离德，为吾等所不容。", --原技能：逆取
	["f_ten_guoshengAniamte"] = "image=image/animate/f_ten_guosheng.png",
	--高望（高达X号）
	["f_ten_dage"] = "十长逝·大哥-高望",
	["&f_ten_dage"] = "大哥",
	    --安弱（大哥高望被削之前的技能）
	  ["dg_anruo"] = "安弱", --现名“妙语”
	  ["dg_anruoBuffs"] = "安弱",
	  [":dg_anruo"] = "你可以将牌按下列规则使用或打出：红桃当【桃】；方块当火【杀】；梅花当【闪】；黑桃当【无懈可击】。当你以此法使用或打出【杀】或【闪】时，你可以获得对方的一张牌；" ..
	  "当你以此法使用【桃】时，你可以获得一名角色的一张牌；当你以此法使用【无懈可击】时，你可以获得响应的目标普通锦囊牌的使用者的一张牌。",
	  --["dg_anruo:dg_anruo_getCard"] = "你可以发动“安弱”，获得 %src 的一张牌",
	  ["$dg_anruo1"] = "还不可以认输！",
	  ["$dg_anruo2"] = "绝望中，仍存有一线生机！",
	["$f_danggu10"] = "小伤无碍，安心修养便可。",
	["f_ten_dageAniamte"] = "image=image/animate/f_ten_dage.png",
	  --殁亡
	["f_mowang"] = "殁亡",
	["f_mowangDeath"] = "殁亡",
	[":f_mowang"] = "锁定技，回合结束后，你死亡；你即将因此技能死亡或于濒死状态询问结束后即将死亡时，若你拥有技能“党锢”且你仍有未出亮出的“阴灵”牌，" ..
	"则改为进入<font color='purple'><b>☠装死状态</b></font>（持续至你的下回合开始前）。\
	<font color='purple'><b>☠装死：</b>锁定技，当你进入此状态时，你立即清空区域内所有牌；你不能成为牌的目标。</font>",
	["f_ten_die"] = "image=image/animate/f_ten_die.png",
	["$f_mowang_EnterZS"] = "%from 进入 ☠<font color='purple'><b>装死状态</b></font>",
	["$f_mowang_QuitZS"] = "%from 从 ☠<font color='purple'><b>装死状态</b></font> 脱离",
	["$f_mowang1"] = "",
	["$f_mowang2"] = "",
	["$f_mowang3"] = "",
	["$f_mowang4"] = "",
	["$f_mowang5"] = "",
	["$f_mowang6"] = "",
	["$f_mowang7"] = "",
	["$f_mowang8"] = "",
	["$f_mowang9"] = "",
	["$f_mowang10"] = "",
	    --装死
	  ["f_ten_zhuangsi"] = "装死中...",
	  ["&f_ten_zhuangsi"] = "装死中",
	  ["f_ten_zs"] = "装死",
	  ["f_ten_zsTrigger"] = "装死",
	  [":f_ten_zs"] = "锁定技，当你进入此状态时，你立即清空区域内所有牌；你不能成为牌的目标。",
	  --阵亡
	["~f_ten"] = "死亡过后，即是重生..........",
	
	--神袁绍(吧友DIY)
	["f_shenyuanshao"] = "神袁绍",
	["#f_shenyuanshao"] = "一时之杰",
	["designer:f_shenyuanshao"] = "张一舟2012",
	["cv:f_shenyuanshao"] = "官方",
	["illustrator:f_shenyuanshao"] = "铁杵文化",
	  --名望
	["f_mingwang"] = "名望",
	["f_mingwangMaxCards"] = "名望",
	[":f_mingwang"] = "锁定技，游戏开始时，你令所有其他角色选择一项：1.摸两张牌，获得1枚“势”标记；2.弃置两张牌。\
	锁定技，摸牌阶段，你改为摸X+1张牌；你的手牌上限+X；你对非“势”角色造成的伤害+1。（X为场上的“势”标记数）\
	<font color='red'><b>◆注：有“势”标记的角色称为【“势”角色】；没有“势”标记的角色称为【非“势”角色】</b></font>",
	["f_ysS"] = "势",
	["f_mingwang:1"] = "摸两张牌，成为“势”角色",
	["f_mingwang:2"] = "弃两张牌，仍为非“势”角色",
	["$f_mingwangMD"] = "因为“<font color='yellow'><b>名望</b></font>”的效果，%from 对【<font color='yellow'><b>非“<font color='orange'>势</font>”角色</b></font>】%to " ..
	"造成的伤害+1",
	["$f_mingwang1"] = "诸公，皆吾功成元勋也！", --角色选择获得“势”标记
	["$f_mingwang2"] = "吾袁门之裔，定一统天下！", --额外摸牌、享受手牌上限增益
	["$f_mingwang3"] = "乘敌乱而击之，必大获全胜！", --加伤
	["$f_mingwang4"] = "凶顽之贼，皆以乱箭射之！", --加伤
	  --寡谋
	["f_guamou"] = "寡谋",
	[":f_guamou"] = "锁定技，当你对非“势”角色使用<font color='red'><b>基本牌或普通锦囊牌</b></font>时，额外指定所有“势”角色为目标。",
	["$f_guamou1"] = "弓箭手准备，放！",
	["$f_guamou2"] = "箭如雨下，士众崩溃！",
	  --非势
	["f_feishi"] = "非势",
	[":f_feishi"] = "当你对“势”角色造成伤害后，其可获得你两张牌并移除其所有“势”标记；“势”角色死亡后，你失去1点体力。",
	["f_feishi-leave"] = "你可以拿走盟主%src的两张牌，之后不再是“势”角色",
	["$f_feishi1"] = "这可是与生俱来的血统！",
	["$f_feishi2"] = "这...不可能！",
	  --阵亡
	["~f_shenyuanshao"] = "莫非...最后的赢家是......",
	
	--神袁绍-江山如梦(吧友DIY)
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--==天才包专属神武将==--
	--神祝融
	["tc_shenzhurong"] = "神祝融[天才包]",
	["&tc_shenzhurong"] = "神祝融",
	["#tc_shenzhurong"] = "巾帼豪迈",
	["designer:tc_shenzhurong"] = "俺的西木野Maki",
	["cv:tc_shenzhurong"] = "官方",
	["illustrator:tc_shenzhurong"] = "第七个桔子/枭瞳",
	  --巨象 势吞山河
	["tc_juxiang_stsh"] = "巨象 势吞山河",
    [":tc_juxiang_stsh"] = "锁定技，【南蛮入侵】对你无效。其他角色使用的【南蛮入侵】在结算完毕后置入弃牌堆时，你获得之。回合结束时，若你于回合内未使用过【南蛮入侵】，" ..
	"你视为使用一张【南蛮入侵】。",
	["$tc_juxiang_stsh1"] = "南蛮巨象，开疆辟土！",
	["$tc_juxiang_stsh2"] = "腾骞征敌，肆意沙场！",
	  --烈锋 势破万敌
	["tc_liefeng_spwd"] = "烈锋 势破万敌",
	[":tc_liefeng_spwd"] = "当你使用【杀】后，你可以与目标角色拼点，若你赢，此【杀】结算结束后，你对另一名其他角色造成随机1~3点随机属性伤害且目标角色失去1点体力。",
	["@tc_liefeng_spwd-invoke"] = "你发动了“烈锋”拼点，请选择一张手牌<br/> <b>操作提示</b>: 选择一张手牌→点击确定<br/>",
	["$tc_liefeng_spwd1"] = "葵花映日熠生辉，烈刃炽火燃赤金！",
	["$tc_liefeng_spwd2"] = "弯刃折衰枝，金葵向日倾！",
	  --长标 势气如虹
	["tc_changbiao_sqrh"] = "长标 势气如虹",
	[":tc_changbiao_sqrh"] = "出牌阶段限一次，你可将任意张手牌当无距离限制的【杀】对任意名其他角色使用。若此【杀】造成过伤害，此【杀】结算结束后你摸等量的牌。",
	["$tc_changbiao_sqrh1"] = "今日就让这群汉人，长长见识！",
	["$tc_changbiao_sqrh2"] = "长矛、飞刀、烈火，都来吧！",
	  --阵亡
	["~tc_shenzhurong"] = "霜露萧瑟，花败枝折......",
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--待续......
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--更换武将皮肤--
	["mobileGOD_SkinChange"] = "更换武将皮肤",
	["mobileGOD_SkinChange_Button"] = "换皮",
	["mobilegod_skinchange_button"] = "更换武将皮肤",
	["mobileGOD_SkinChange_ButtonCard"] = "更换武将皮肤",
	["sjyh"] = "原画",
	["sjjoy"] = "欢乐杀",
	--(界)神郭嘉(手杀)
	["sgj_hnqm"] = "虎年清明",
	["sgj_wxmy"] = "我心明月", --自己编的
	["sgj_zcjj"] = "总裁姐姐",
	["sgj_yxzy_first"] = "倚星折月(第一形态)",
	["f_tianyiAnimate_yxzy"] = "image=image/animate/f_tianyi_yxzy.png", --觉醒，从第一形态切换为第二形态
	["sgj_yxzy_second"] = "倚星折月(第二形态)",
	["f_shenguojia_c"] = "界·神郭嘉[手杀]",
	["&f_shenguojia_c"] = "界神郭嘉",
	["~f_shenguojia_c"] = "可叹桢干命也迂..........",
	["f_shenguojia_joy"] = "界·神郭嘉[手杀]",
	["&f_shenguojia_joy"] = "界神郭嘉",
	["~f_shenguojia_joy"] = "可叹桢干命也迂..........",
	["f_shenguojia_nv1"] = "界·神郭嘉[手杀]",
	["&f_shenguojia_nv1"] = "界神郭嘉",
	["~f_shenguojia_nv1"] = "可叹桢干命也迂..........",
	["f_shenguojia_nv2"] = "界·神郭嘉[手杀]",
	["&f_shenguojia_nv2"] = "界神郭嘉",
	["~f_shenguojia_nv2"] = "可叹桢干命也迂..........",
	["f_shenguojia_d1"] = "界·神郭嘉[手杀]",
	["&f_shenguojia_d1"] = "界神郭嘉",
	["~f_shenguojia_d1"] = "可叹桢干命也迂..........",
	["f_shenguojia_d2"] = "界·神郭嘉[手杀]",
	["&f_shenguojia_d2"] = "界神郭嘉",
	["~f_shenguojia_d2"] = "可叹桢干命也迂..........",
	--(界)神荀彧(手杀)
	["sxy_hnqm"] = "虎年清明",
	["sxy_yjtw"] = "阴间天王",
	["sxy_xhry"] = "羲和浴日", --自己编的
	["f_shenxunyu_c"] = "界·神荀彧[手杀]",
	["&f_shenxunyu_c"] = "界神荀彧",
	["~f_shenxunyu_c"] = "宁鸣而死，不默而生！",
	["f_shenxunyu_joy"] = "界·神荀彧[手杀]",
	["&f_shenxunyu_joy"] = "界神荀彧",
	["~f_shenxunyu_joy"] = "宁鸣而死，不默而生！",
	["f_shenxunyu_x"] = "界·神荀彧[手杀]",
	["&f_shenxunyu_x"] = "界神荀彧",
	["~f_shenxunyu_x"] = "宁鸣而死，不默而生！",
	["$mobileGOD_SkinChange"] = "", --神荀彧、神孙策墨镜皮肤（双将模式仅作为主将）登场BGM
	["f_shenxunyu_nv"] = "界·神荀彧[手杀]",
	["&f_shenxunyu_nv"] = "界神荀彧",
	["~f_shenxunyu_nv"] = "宁鸣而死，不默而生！",
	--(界)神孙策(手杀)
	["ssc_yjtw"] = "阴间天王",
	["ssc_bwzs"] = "霸王再世",
	["f_shensunce_x"] = "界·神孙策[手杀]",
	["&f_shensunce_x"] = "界神孙策",
	["~f_shensunce_x"] = "无耻小人，胆敢暗算于我！......",
	["f_shensunce_joy"] = "界·神孙策[手杀]",
	["&f_shensunce_joy"] = "界神孙策",
	["~f_shensunce_joy"] = "无耻小人，胆敢暗算于我！......",
	["f_shensunce_c"] = "界·神孙策[手杀]",
	["&f_shensunce_c"] = "界神孙策",
	["~f_shensunce_c"] = "无耻小人，胆敢暗算于我！......",
	--神太史慈-第二版(手杀)
	["stsc_yhry"] = "勇撼日月",
	["f_shentaishicii_c"] = "神太史慈[手杀]-第二版",
	["&f_shentaishicii_c"] = "神太史慈",
	["~f_shentaishicii_c"] = "魂归......天...地...",
	--神姜维-怒麟燎原
	["sjwbn_fhls"] = "现原画:烽火乱世",
	["sjwbn_ldjz"] = "初原画:凛冬将至",
	["ty_shenjiangweiBN_1"] = "神姜维[十周年]-怒麟燎原",
	["&ty_shenjiangweiBN_1"] = "神姜维",
	["~ty_shenjiangweiBN_1"] = "汉室复兴，本就是一场梦吗？......",
	--(界)神姜维(新杀)
	["sjw_ymlt"] = "跃马龙腾",
	["sjw_cjfb"] = "敕剑伏波",
	["ty_shenjiangwei_joy"] = "界·神姜维[十周年]",
	["&ty_shenjiangwei_joy"] = "界神姜维",
	["~ty_shenjiangwei_joy"] = "武侯遗志，已成泡影矣.........",
	["ty_shenjiangwei_3gods"] = "界·神姜维[十周年]",
	["&ty_shenjiangwei_3gods"] = "界神姜维",
	["~ty_shenjiangwei_3gods"] = "武侯遗志，已成泡影矣.........",
	["ty_shenjiangwei_1"] = "界·神姜维[十周年]",
	["&ty_shenjiangwei_1"] = "界神姜维",
	["~ty_shenjiangwei_1"] = "残阳晦月映秋霜，天命不再计成空.........",
	--神马超(新杀)
	["smc_xwjl"] = "迅骛惊雷",
	["smc_xwjldt"] = "迅骛惊雷(动皮)",
	["smc_xyxc"] = "星夜袭曹", --其实是马超的手杀传说动皮
	["smc_lwfc"] = "雷挝缚苍",
	["smc_ymlt"] = "跃马龙腾",
	["ty_shenmachao_1"] = "神马超[十周年]",
	["&ty_shenmachao_1"] = "神马超",
	["~ty_shenmachao_1"] = "七情难言，六欲难消，何谓之神......",
	["ty_shenmachao_1dt"] = "神马超[十周年]",
	["&ty_shenmachao_1dt"] = "神马超",
	["~ty_shenmachao_1dt"] = "七情难言，六欲难消，何谓之神......",
	["ty_shenmachao_t"] = "神马超[十周年]",
	["&ty_shenmachao_t"] = "神马超",
	["~ty_shenmachao_t"] = "离群之马，虽强亦亡......",
	["ty_shenmachao_sp"] = "神马超[十周年]",
	["&ty_shenmachao_sp"] = "神马超",
	["~ty_shenmachao_sp"] = "离群之马，虽强亦亡......",
	["ty_shenmachao_3gods"] = "神马超[十周年]",
	["&ty_shenmachao_3gods"] = "神马超",
	["~ty_shenmachao_3gods"] = "离群之马，虽强亦亡......",
	--神张飞(新杀)
	["szf_ansh"] = "傲睨山河",
	["szf_ymlt"] = "跃马龙腾",
	["szf_tbzh"] = "铁鞭震洪",
	["ty_shenzhangfei_1"] = "神张飞[十周年]",
	["&ty_shenzhangfei_1"] = "神张飞",
	["~ty_shenzhangfei_1"] = "愿舍神冕入轮回，与吾兄再结金兰......",
	["ty_shenzhangfei_joy"] = "神张飞[十周年]",
	["&ty_shenzhangfei_joy"] = "神张飞",
	["~ty_shenzhangfei_joy"] = "愿舍神冕入轮回，与吾兄再结金兰......",
	["ty_shenzhangfei_3gods"] = "神张飞[十周年]",
	["&ty_shenzhangfei_3gods"] = "神张飞",
	["~ty_shenzhangfei_3gods"] = "尔等欲复斩我头乎？......",
	["ty_shenzhangfei_2"] = "神张飞[十周年]",
	["&ty_shenzhangfei_2"] = "神张飞",
	["~ty_shenzhangfei_2"] = "尔等欲复斩我头乎？......",
	--神张角(新杀)
	["szj_ydzz"] = "驭道震泽",
	["ty_shenzhangjiao_1"] = "神张角[十周年]",
	["&ty_shenzhangjiao_1"] = "神张角",
	["~ty_shenzhangjiao_1"] = "书中皆记王侯事，青史不载人间民......",
	["ty_shenzhangjiao_joy"] = "神张角[十周年]",
	["&ty_shenzhangjiao_joy"] = "神张角",
	["~ty_shenzhangjiao_joy"] = "诸君唤我为贼，然我所窃何物？......",
	--神邓艾(新杀)
	["sdi_eczz"] = "遏川制泽",
	["ty_shendengai_1"] = "神邓艾[十周年]",
	["&ty_shendengai_1"] = "神邓艾",
	["~ty_shendengai_1"] = "大丈夫不能建功立业，其与豕鼠何异......",
	--神甄姬(OL)
	["ol_shenzhenji_joy"] = "神甄姬[OL+欢乐杀强化]",
	["&ol_shenzhenji_joy"] = "神甄姬",
	["~ol_shenzhenji_joy"] = "众口烁金，难证吾清.......",
	--神孙权(OL)
	["ssq_thry"] = "同辉日月",
	["ol_shensunquan_1"] = "神孙权[OL]",
	["&ol_shensunquan_1"] = "神孙权",
	["~ol_shensunquan_1"] = "困居江东，妄称至尊......",
	--(界)神张角(OL)
	["ol_shenzhangjiao_1"] = "界·神张角[OL]",
	["&ol_shenzhangjiao_1"] = "界神张角",
	["~ol_shenzhangjiao_1"] = "书中皆记王侯事，青史不载人间民......",
	--神孙尚香(diy)
	["f_shensunshangxiang_shu"] = "神孙尚香",
	["~f_shensunshangxiang_shu"] = "四水楚歌起，望乡泪满裳......",
	--神祝融(天才包)
	["szr_jghw"] = "巾帼花武",
	["szr_fdlh"] = "飞刀烈火",
	["tc_shenzhurong_1"] = "神祝融[天才包]",
	["&tc_shenzhurong_1"] = "神祝融",
	["~tc_shenzhurong_1"] = "霜露萧瑟，花败枝折......",
	--------------------
}
return {extension, extension_t, extension_o, extension_j, extension_w, extension_jl, extension_ofl, extension_f, newgodsCard}--, extension_tc}