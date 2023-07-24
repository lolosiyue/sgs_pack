extension = sgs.Package("mobileGod", sgs.Package_GeneralPack)
extension_t = sgs.Package("tenyearGod", sgs.Package_GeneralPack)
extension_o = sgs.Package("OLGod", sgs.Package_GeneralPack)
extension_j = sgs.Package("joyGod", sgs.Package_GeneralPack)
--extension_w = sgs.Package("wxGod", sgs.Package_GeneralPack)
extension_f = sgs.Package("FCGod", sgs.Package_GeneralPack)
newgodsCard = sgs.Package("newgodsCard", sgs.Package_CardPack)

--[[《目录》
手杀神武将（始计篇10位，海外服1位）：
  神郭嘉(智)、神荀彧(智)、神太史慈(信)、神孙策(信)、神孙权(仁)?、神鲁肃(仁)?、神张飞(勇)?、神马超(勇)?、神袁绍(严)?、神曹仁(严)?（附赠张仲景(仁,测试初版)）；神关羽(海外服)
十周年神武将（3）：
  神姜维(包括爆料版)、神马超、神孙权(技能未知)
OL神武将（3）：
  神曹丕、神甄姬、神孙权(正式版暂无消息)
欢乐杀神武将（目前有14位，我只是写了其中一部分）：
  神孙权、神张辽、神典韦、神华佗
小程序神武将（0）：

自己/吧友DIY的神武将（3）：
  神司马师(自)、神刘三刀(自)、神刘备-威力加强版
]]
  
--==手杀神武将==--
--神郭嘉（智）
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
		        room:loseMaxHp(source, 1)
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
		--第一次判定
		if use.card:getSkillName() == "f_huishi" and player:getMaxHp() < 10 then
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
			local card1 = judge.card
			local card_id1 = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		    if card_id1 then
				card_id1:deleteLater()
			    card_id1 = card1
		    end
		    player:addToPile("HandcarddataHS", card_id1, true)
			local c1 = player:getMaxHp()
		    local mhp1 = sgs.QVariant()
		    mhp1:setValue(c1 + 1)
		    room:setPlayerProperty(player, "maxhp", mhp1)
		    --第二次判定
		    if player:getMaxHp() < 10 and room:askForSkillInvoke(player, "@f_huishi_continue", data) then
			    local judge = sgs.JudgeStruct()
			    judge.pattern = "."
			    judge.good = true
			    judge.play_animation = false
			    judge.who = player
			    judge.reason = "f_huishi"
			    room:judge(judge)
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
					local c2 = player:getMaxHp()
		            local mhp2 = sgs.QVariant()
		            mhp2:setValue(c2 + 1)
		            room:setPlayerProperty(player, "maxhp", mhp2)
			    end
		        --第三次判定
		        if player:getMaxHp() < 10 and room:askForSkillInvoke(player, "@f_huishi_continue", data) then
			        local judge = sgs.JudgeStruct()
			        judge.pattern = "."
			        judge.good = true
			        judge.play_animation = false
			        judge.who = player
			        judge.reason = "f_huishi"
			        room:judge(judge)
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
						local c3 = player:getMaxHp()
		                local mhp3 = sgs.QVariant()
		                mhp3:setValue(c3 + 1)
		                room:setPlayerProperty(player, "maxhp", mhp3)
			        end
			        --第四次判定
			        if player:getMaxHp() < 10 and room:askForSkillInvoke(player, "@f_huishi_continue", data) then
					    local judge = sgs.JudgeStruct()
			            judge.pattern = "."
			            judge.good = true
			            judge.play_animation = false
			            judge.who = player
			            judge.reason = "f_huishi"
			            room:judge(judge)
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
							local c4 = player:getMaxHp()
		                    local mhp4 = sgs.QVariant()
		                    mhp4:setValue(c4 + 1)
		                    room:setPlayerProperty(player, "maxhp", mhp4)
				        end
				        --第五次判定（也是最后一次，因为这一次必撞花色）
				        if player:getMaxHp() < 10 and room:askForSkillInvoke(player, "@f_huishi_continue", data) then
							local judge = sgs.JudgeStruct()
			            	judge.pattern = "."
			            	judge.good = true
			            	judge.play_animation = false
			            	judge.who = player
			            	judge.reason = "f_huishi"
			            	room:judge(judge)
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
	frequency = sgs.Skill_Compulsory,
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
	--[[can_wake = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Start or player:getMark("f_tianyi") > 0 then return false end
		if player:canWake(self:objectName()) then return true end
		if player:getMark("&f_tianyi_Trigger") > 0 then return true end
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:getMark("f_tianyiDamageTake") == 0 then
				return false
				break
			end
		end
		return true
	end,]]
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local can_invoke = true
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:getMark("f_tianyiDamageTake") == 0 then
				can_invoke = false
				break
			end
		end
		if player:getMark("&f_tianyi_Trigger") > 0 then can_invoke = true end
		if can_invoke then
			room:broadcastSkillInvoke(self:objectName())
			room:doLightbox("f_tianyiAnimate")
			local c = player:getMaxHp()
			local mhp = sgs.QVariant()
			mhp:setValue(c + 2)
			room:setPlayerProperty(player, "maxhp", mhp)
			local recover = sgs.RecoverStruct()
			recover.who = player
			room:recover(player, recover)
			local beneficiary = room:askForPlayerChosen(player, room:getAllPlayers(), "@f_tianyi", "f_tianyi-invoke")
			if not beneficiary:hasSkill("ty_zuoxing") then
		    	room:acquireSkill(beneficiary, "ty_zuoxing")
			end
			room:addPlayerMark(player, self:objectName())
			room:addPlayerMark(player, "@waked")
			if player:getMark("&f_tianyi_Trigger") > 0 then
		    	room:removePlayerMark(player, "&f_tianyi_Trigger")
			end
		end
	end,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill(self:objectName()) and player:getPhase() == sgs.Player_Start and player:getMark(self:objectName()) == 0
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
		    if n:getMark("f_tianyi") > 0 and n:isAlive() and n:getMaxHp() > 1 then
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
	skill_name = "f_huishii",
	target_fixed = false,
	filter = function(self, targets, to_select)
		return #targets == 0
	end,
	on_use = function(self, room, source, targets)
		local count = room:alivePlayerCount()
		local mhp = source:getMaxHp()
		if targets[1]:getGeneralName() == source:getGeneralName() and source:getMark("f_tianyi") == 0 and mhp >= count then
		    room:addPlayerMark(targets[1], "&f_tianyi_Trigger")
		else
		    room:drawCards(targets[1], 4, self:objectName())
		end
		room:loseMaxHp(source, 2)
		room:removePlayerMark(source, "@f_huishii")
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

--神荀彧（智）
f_shenxunyu = sgs.General(extension, "f_shenxunyu", "god", 3, true)

--==神荀彧专属锦囊：奇正相生==--
f_qizhengxiangsheng = sgs.CreateTrickCard{
    name = "f_qizhengxiangsheng",
	class_name = "Fqizhengxiangsheng",
	target_fixed = false,
	can_recast = false,
	available = true,
	is_cancelable = true,
	damage_card = true,
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	filter = function(self, targets, to_select)
	    return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and not sgs.Self:isCardLimited(self, sgs.Card_MethodUse)
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
ngCRemover = sgs.CreateTriggerSkill{ --如果不选择加入【神武将专属卡牌】，将其移出游戏（如果场上有技能“天佐”，【奇正相生】不会被移除）
	name = "ngCRemover",
	global = true,
	priority = 10,
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawInitialCards, sgs.CardsMoveOneTime},
	view_as_skill = ngCRemoverVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawInitialCards then
			if player:getState() == "online" then --玩家选择是否加入【神武将专属卡牌】
			    if not room:askForUseCard(player, "@@ngCRemover", "@ngCRemover") then
					for _, id in sgs.qlist(room:getDrawPile()) do
						--奇正相生
						if sgs.Sanguosha:getCard(id):isKindOf("Fqizhengxiangsheng") then
							local tz = room:findPlayerBySkillName("f_tianzuo")
							if tz then return false end
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
			end
		end
		return false
	end,
}
if not sgs.Sanguosha:getSkill("ngCRemover") then skills:append(ngCRemover) end




--

f_tianzuo = sgs.CreateTriggerSkill{ --一个空壳，“天佐”的所有技能内容皆在锦囊【奇正相生】里。
	name = "f_tianzuo",
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
		    	if (use.card:isKindOf("Collateral") or use.card:isKindOf("ExNihilo") or use.card:isKindOf("Snatch") or use.card:isKindOf("IronChain")) or (use.card:isKindOf("Fqizhengxiangsheng") or use.card:isKindOf("Qizhengxiangsheng")) then
			    	room:sendCompulsoryTriggerLog(sxy, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					room:drawCards(sxy, 1, self:objectName())
				end
				if (use.card:isKindOf("Dismantlement") and sxy:getMark("ghcq") > 0) or (use.card:isKindOf("SavageAssault") and sxy:getMark("nmrq") > 0) or (use.card:isKindOf("ArcheryAttack") and sxy:getMark("wjqf") > 0)
			    	or (use.card:isKindOf("AmazingGrace") and sxy:getMark("wgfd") > 0) or (use.card:isKindOf("GodSalvation") and sxy:getMark("tyjy") > 0) or (use.card:isKindOf("Duel") and sxy:getMark("jd") > 0)
					or (use.card:isKindOf("Nullification") and sxy:getMark("wxkj") > 0) or (use.card:isKindOf("Indulgence") and sxy:getMark("lbss") > 0) or (use.card:isKindOf("Lightning") and sxy:getMark("sd") > 0)
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

--神太史慈（信）
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
					--[[if not use.card:isVirtualCard() then
						room:sendCompulsoryTriggerLog(player, "f_shenzhuo") --手动神著
		    			room:broadcastSkillInvoke("f_shenzhuo")
		    			room:drawCards(player, 1, "f_shenzhuo")
					end]]
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
				local hp = math.min(1, maxhp)
				room:setPlayerProperty(player, "hp", sgs.QVariant(hp))
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
				local hp = math.min(1, maxhp)
				room:setPlayerProperty(player, "hp", sgs.QVariant(hp))
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

--神孙策（信）
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
	events = {sgs.DamageInflicted},
	view_as_skill = f_pingheDefuseDamageVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
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
	priority = -100, --优先级降到最低，给其他捡垃圾技能让路
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
	filter_pattern =  ".|.|.|f_REN",
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
	frequency = sgs.Skill_NotFrequent, --设置成锁定技无法触发
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

--==十周年神武将==--
--神姜维
  --爆料版
ty_shenjiangweiBN = sgs.General(extension_t, "ty_shenjiangweiBN", "god", 4, true)

--获取卡牌列表
function getCardList(intlist)
	local ids = sgs.CardList()
	for _, id in sgs.qlist(intlist) do
		ids:append(sgs.Sanguosha:getCard(id))
	end
	return ids
end
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
			if card and card:getHandlingMethod() == sgs.Card_MethodUse then
				local names, name = player:property("tyjiufaBNRecord"):toString():split("+"), card:objectName()
				if table.contains(names, name) then return false end
				table.insert(names, name)
				room:setPlayerProperty(player, "tyjiufaBNRecord", sgs.QVariant(table.concat(names, "+"))) --记录牌名
				room:addPlayerMark(player, "&tyjiufaBNRecord")
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

  --正式版
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
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and card:getHandlingMethod() == sgs.Card_MethodUse then
				local names, name = player:property("tyjiufaRecord"):toString():split("+"), card:objectName()
				if table.contains(names, name) then return false end
				table.insert(names, name)
				room:setPlayerProperty(player, "tyjiufaRecord", sgs.QVariant(table.concat(names, "+"))) --记录牌名
				room:addPlayerMark(player, "&tyjiufaRecord")
				room:broadcastSkillInvoke(self:objectName())
			end
		elseif event == sgs.MarkChanged then
			local mark = data:toMark()
			if mark.name == "&tyjiufaRecord" and mark.who and mark.who:getMark("&tyjiufaRecord") >= 9 then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
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
						room:broadcastSkillInvoke(self:objectName())
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
				room:broadcastSkillInvoke(self:objectName())
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
		fs:setSkillName("typingxiang")
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
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@typingxiang")
		room:loseMaxHp(source, 9)
		room:doSuperLightbox("ty_shenjiangwei", "typingxiang")
		local n = 0 --记录以此法使用虚拟火杀的次数
		while n < 9 and not source:hasFlag("typingxiangFSstop") and source:isAlive() do
			if room:askForUseCard(source, "@@typingxiangFireSlash", "@typingxiangFireSlash") then
				n = n + 1
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
		return player:getMark("@typingxiang") > 0 and player:getMaxHp() > 9
	end,
}
typingxiang = sgs.CreateTriggerSkill{
	name = "typingxiang",
	frequency = sgs.Skill_Limited,
	limit_mark = "@typingxiang",
	view_as_skill = typingxiangVS,
	on_trigger = function()
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

--神马超
ty_shenmachao = sgs.General(extension_t, "ty_shenmachao", "god", 4, true)

--全自动送马
function useHorse(room, player)
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

--OL神武将==--
--神曹丕（和削弱后的版本一样；一开始6血的版本不可能放出来，无解的存在，现在这个版本军八也是天花板级别）
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
						room:getThread():delay()
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
	on_phasechange = function(self, player)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start and player:getMark(self:objectName()) == 0 and player:getPile("powerful"):length() >= 3 then
			room:broadcastSkillInvoke(self:objectName())
			room:doSuperLightbox("ol_shencaopi", "oldengji")
			room:addPlayerMark(player, self:objectName())
			local dummy = sgs.Sanguosha:cloneCard("slash")
			dummy:addSubcards(player:getPile("powerful"))
			room:obtainCard(player, dummy, false)
			if room:changeMaxHpForAwakenSkill(player) then
				room:handleAcquireDetachSkills(player, "tenyearjianxiong|oltianxing")
			end
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
	on_phasechange = function(self, player)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start and player:getMark(self:objectName()) == 0 and player:getPile("powerful"):length() >= 3 then
			room:broadcastSkillInvoke(self:objectName())
			room:doSuperLightbox("ol_shencaopi", "oltianxing")
			room:addPlayerMark(player, self:objectName())
			local dummy = sgs.Sanguosha:cloneCard("slash")
			dummy:addSubcards(player:getPile("powerful"))
			room:obtainCard(player, dummy, false)
			if room:changeMaxHpForAwakenSkill(player) then
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
				if #choices > 0 then
					local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
				end
				room:handleAcquireDetachSkills(player, "-olchuyuan|"..choice)
			end
		end
	end,
}
if not sgs.Sanguosha:getSkill("oltianxing") then skills:append(oltianxing) end
ol_shencaopi:addRelateSkill("tenyearrende")
ol_shencaopi:addRelateSkill("tenyearzhiheng")
ol_shencaopi:addRelateSkill("olluanji")

--神甄姬（被通渠了，只有3血...）
ol_shenzhenji = sgs.General(extension_o, "ol_shenzhenji", "god", 3, false)

olshenfu = sgs.CreatePhaseChangeSkill{
	name = "olshenfu",
	on_phasechange = function(self, player)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Finish then
			local players = room:getAlivePlayers()
			if math.mod(player:getHandcardNum(), 2) == 1 then
				players:removeOne(player)
			end
			local to = room:askForPlayerChosen(player, players, self:objectName(), self:objectName().."-invoke", true, true)
			if to then
				room:broadcastSkillInvoke(self:objectName(), math.mod(player:getHandcardNum(), 2)+1)
				if math.mod(player:getHandcardNum(), 2) == 1 then
					while true do
						room:damage(sgs.DamageStruct(self:objectName(), player, to, 1, sgs.DamageStruct_Thunder))
						if to and to:isAlive() then break end
						to = room:askForPlayerChosen(player, players, self:objectName(), self:objectName().."-invoke", true, true)
					end
				else
					while true do
						local choices = {"draw"}
						if not to:isNude() and to:canDiscard(to, "he") then
							table.insert(choices, "discard")
						end
						local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
						if choice == "draw" then
							to:drawCards(1, self:objectName())
						else
							room:askForDiscard(to, self:objectName(), 1, 1, false, true)
						end
						if to:getHandcardNum() ~= to:getHp() then break end
						to = room:askForPlayerChosen(player, players, self:objectName(), self:objectName().."-invoke", true, true)
					end
				end
			end
		end
	end,
}
ol_shenzhenji:addSkill(olshenfu)

olqixian = sgs.CreateMaxCardsSkill{
	name = "olqixian",
	fixed_func = function(self, player)
		if player:hasSkill(self:objectName()) then
			return 7
		end
		return -1
	end,
}
ol_shenzhenji:addSkill(olqixian)

--神孙权
--ol_shensunquan = sgs.General(extension_o, "ol_shensunquan", "god", 4, true)
--

--==欢乐杀神武将==--
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
					if jssq:getMark("joydingliUsed") == 0 then
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
			if from:hasSkill(self:objectName()) and from:hasFlag("joyquanxueLimitedKey") and to:objectName() ~= from:objectName() and card then
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
		room:addPlayerMark(source, "joydingliUsed")
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
	events = {sgs.TurnStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getMark("joydingliUsed") > 0 then
			room:removePlayerMark(player, "joydingliUsed")
		end
	end,
}
joy_shensunquan:addSkill(joydingli)

--神张辽（欢乐杀）
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
	    return #targets == 0 and to_select:getMark("&joyWEI") == 0
	end,
	on_use = function(self, room, source, targets)
	    local CC = targets[1]
		CC:gainMark("&joyWEI")
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
			if p:getMark("&joyWEI") > 0 then
				can_invoke = true
				break
			end
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
				local hp = math.min(1, maxhp)
				room:setPlayerProperty(player, "hp", sgs.QVariant(hp))
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

--==小程序神武将==--







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
		local area = tonumber(choice), 0
		source:throwEquipArea(area)
		local choicess = {}
		for i = 0, 4 do
			if targets[1]:hasEquipArea(i) then
				table.insert(choicess, i)
			end
		end
		if choicess == "" then return false end
		local choicee = room:askForChoice(source, "f_henjue", table.concat(choicess, "+"))
		local area = tonumber(choicee), 0
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
		local area = tonumber(x), 0
		player:obtainEquipArea(area)
	end,
}
f_shensimashi:addSkill(f_pingpan)

--神刘三刀
f_three = sgs.General(extension_f, "f_three", "god", 4, true)

f_sandao = sgs.CreateTargetModSkill{
	name = "f_sandao",
	residue_func = function(self, player)
		if player:hasSkill(self:objectName()) then
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
f_three:addSkill(f_sandao)
if not sgs.Sanguosha:getSkill("f_sandaoC") then skills:append(f_sandaoC) end
if not sgs.Sanguosha:getSkill("f_sandaoD") then skills:append(f_sandaoD) end
f_sandaoDraw = sgs.CreateTriggerSkill{
	name = "f_sandaoDraw",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed, sgs.CardResponded},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash") then return false end
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
			if response.m_isUse then
				card = response.m_card
			end
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
f_sandaoLevelUp = sgs.CreateTriggerSkill{
	name = "f_sandaoLevelUp",
	global = true,
	frequency = sgs.Skill_Wake,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke("f_sandao")
		room:doSuperLightbox("WEhaveLSD", "f_sandao")
		if player:hasSkill("f_sandao") then
			room:detachSkillFromPlayer(player, "f_sandao", true)
		end
		room:attachSkillToPlayer(player, "f_sandaoEX")
		room:addPlayerMark(player, self:objectName())
		room:addPlayerMark(player, "@waked")
		room:addPlayerMark(player, "@f_sandaoEX")
	end,
	can_trigger = function(self, player)
		return player:hasSkill("f_sandao") and player:getPhase() == sgs.Player_Start and player:getMark(self:objectName()) == 0 and player:getMark("f_sandaoUaR") >= 3
	end,
}
if not sgs.Sanguosha:getSkill("f_sandaoDraw") then skills:append(f_sandaoDraw) end
if not sgs.Sanguosha:getSkill("f_sandaoLevelUp") then skills:append(f_sandaoLevelUp) end
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
		        if killer:hasFlag("f_sandaoEX") and (current:isAlive() or current:objectName() == death.who:objectName()) then
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
		    if n == 1 then
			    room:setChangeSkillState(player, self:objectName(), 2)
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName(), math.random(1,2))
				room:loseMaxHp(player, 1)
				room:drawCards(player, 1, self:objectName())
				room:acquireSkill(player, "f_longnu_yang", false)
				room:acquireSkill(player, "f_longnu_yangg", false)
				room:filterCards(player, player:getCards("h"), true)
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

--更换武将皮肤--
mobileGOD_SkinChange = sgs.CreateTriggerSkill{
    name = "mobileGOD_SkinChange",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.AfterDrawInitialCards},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		--神郭嘉
		if player:getGeneralName() == "f_shenguojia" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "f_shenguojia_c", false, true, false, false)
			if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
		end
		if player:getGeneral2Name() == "f_shenguojia" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "f_shenguojia_c", false, true, true, false)
			if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
		end
		--神荀彧
		if player:getGeneralName() == "f_shenxunyu" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "sxy_hnqm+sxy_yjzl")
			if choice == "sxy_hnqm" then
				room:changeHero(player, "f_shenxunyu_c", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			else
				room:changeHero(player, "f_shenxunyu_x", false, true, false, false)
				room:broadcastSkillInvoke(self:objectName())
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		if player:getGeneral2Name() == "f_shenxunyu" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "sxy_hnqm+sxy_yjzl")
			if choice == "sxy_hnqm" then
				room:changeHero(player, "f_shenxunyu_c", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			else
				room:changeHero(player, "f_shenxunyu_x", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		--神孙策
		if player:getGeneralName() == "f_shensunce" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "f_shensunce_x", false, true, false, false)
			room:broadcastSkillInvoke(self:objectName())
			if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
		end
		if player:getGeneral2Name() == "f_shensunce" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "f_shensunce_x", false, true, true, false)
			if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
		end
		--神马超
		if player:getGeneralName() == "ty_shenmachao" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "smc_xwjl+smc_xyxc")
			if choice == "smc_xwjl" then
				room:changeHero(player, "ty_shenmachao_1", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			else
				room:changeHero(player, "ty_shenmachao_t", false, true, false, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		if player:getGeneral2Name() == "ty_shenmachao" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "smc_xwjl+smc_xyxc")
			if choice == "smc_xwjl" then
				room:changeHero(player, "ty_shenmachao_1", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			else
				room:changeHero(player, "ty_shenmachao_t", false, true, true, false)
				if not player:hasSkill("mobileGOD_SkinChange_Button") then room:attachSkillToPlayer(player, "mobileGOD_SkinChange_Button") end
			end
		end
		if player:getGeneralName() == "f_shenguojia" or player:getGeneralName() == "f_shenxunyu" or player:getGeneralName() == "f_shensunce" or player:getGeneralName() == "ty_shenmachao"
		or player:getGeneral2Name() == "f_shenguojia" or player:getGeneral2Name() == "f_shenxunyu" or player:getGeneral2Name() == "f_shensunce" or player:getGeneral2Name() == "ty_shenmachao" then
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

f_shenxunyu_c = sgs.General(extension, "f_shenxunyu_c", "god", 3, true, true, true)
f_shenxunyu_c:addSkill("f_tianzuo")
f_shenxunyu_c:addSkill("f_lingce")
f_shenxunyu_c:addSkill("f_dinghan")
f_shenxunyu_x = sgs.General(extension, "f_shenxunyu_x", "god", 3, true, true, true)
f_shenxunyu_x:addSkill("f_tianzuo")
f_shenxunyu_x:addSkill("f_lingce")
f_shenxunyu_x:addSkill("f_dinghan")

f_shensunce_x = sgs.General(extension, "f_shensunce_x", "god", 6, true, true, true, 1)
f_shensunce_x:addSkill("imba")
f_shensunce_x:addSkill("f_fuhai")
f_shensunce_x:addSkill("f_pinghe")

ty_shenmachao_1 = sgs.General(extension_t, "ty_shenmachao_1", "god", 4, true, true, true)
ty_shenmachao_1:addSkill("tyshouli")
ty_shenmachao_1:addSkill("tyhengwu")
ty_shenmachao_t = sgs.General(extension_t, "ty_shenmachao_t", "god", 4, true, true, true)
ty_shenmachao_t:addSkill("tyshouli")
ty_shenmachao_t:addSkill("tyhengwu")
----
mobileGOD_SkinChange_ButtonCard = sgs.CreateSkillCard{
    name = "mobileGOD_SkinChange_ButtonCard",
	target_fixed = true,
	on_use = function(self, room, player, targets)
		--神郭嘉
		if player:getGeneralName() == "f_shenguojia" or player:getGeneralName() == "f_shenguojia_c" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+sgj_hnqm")
			if choice == "sjyh" then
				room:changeHero(player, "f_shenguojia", false, false, false, false)
			else
				room:changeHero(player, "f_shenguojia_c", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "f_shenguojia" or player:getGeneral2Name() == "f_shenguojia_c" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+sgj_hnqm")
			if choice == "sjyh" then
				room:changeHero(player, "f_shenguojia", false, false, true, false)
			else
				room:changeHero(player, "f_shenguojia_c", false, false, true, false)
			end
		end
		--神荀彧
		if player:getGeneralName() == "f_shenxunyu" or player:getGeneralName() == "f_shenxunyu_c" or player:getGeneralName() == "f_shenxunyu_x" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+sxy_hnqm+sxy_yjzl")
			if choice == "sjyh" then
				room:changeHero(player, "f_shenxunyu", false, false, false, false)
			elseif choice == "sxy_hnqm" then
				room:changeHero(player, "f_shenxunyu_c", false, false, false, false)
			elseif choice == "sxy_yjzl" then
				room:changeHero(player, "f_shenxunyu_x", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "f_shenxunyu" or player:getGeneral2Name() == "f_shenxunyu_c" or player:getGeneral2Name() == "f_shenxunyu_x" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+sxy_hnqm+sxy_yjzl")
			if choice == "sjyh" then
				room:changeHero(player, "f_shenxunyu", false, false, true, false)
			elseif choice == "sxy_hnqm" then
				room:changeHero(player, "f_shenxunyu_c", false, false, true, false)
			elseif choice == "sxy_yjzl" then
				room:changeHero(player, "f_shenxunyu_x", false, false, true, false)
			end
		end
		--神孙策
		if player:getGeneralName() == "f_shensunce" or player:getGeneralName() == "f_shensunce_x" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+ssc_yjzl")
			if choice == "sjyh" then
				room:changeHero(player, "f_shensunce", false, false, false, false)
			else
				room:changeHero(player, "f_shensunce_x", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "f_shensunce" or player:getGeneral2Name() == "f_shensunce_x" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+ssc_yjzl")
			if choice == "sjyh" then
				room:changeHero(player, "f_shensunce", false, false, true, false)
			else
				room:changeHero(player, "f_shensunce_x", false, false, true, false)
			end
		end
		--神马超
		if player:getGeneralName() == "ty_shenmachao" or player:getGeneralName() == "ty_shenmachao_1" or player:getGeneralName() == "ty_shenmachao_t" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+smc_xwjl+smc_xyxc")
			if choice == "sjyh" then
				room:changeHero(player, "ty_shenmachao", false, false, false, false)
			elseif choice == "smc_xwjl" then
				room:changeHero(player, "ty_shenmachao_1", false, false, false, false)
			elseif choice == "smc_xyxc" then
				room:changeHero(player, "ty_shenmachao_t", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "ty_shenmachao" or player:getGeneral2Name() == "ty_shenmachao_1" or player:getGeneral2Name() == "ty_shenmachao_t" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+smc_xwjl+smc_xyxc")
			if choice == "sjyh" then
				room:changeHero(player, "ty_shenmachao", false, false, true, false)
			elseif choice == "smc_xwjl" then
				room:changeHero(player, "ty_shenmachao_1", false, false, true, false)
			elseif choice == "smc_xyxc" then
				room:changeHero(player, "ty_shenmachao_t", false, false, true, false)
			end
		end
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
	["FCGod"] = "吧友diy神武将",
	["newgodsCard"] = "神武将专属卡牌",
	
	--神郭嘉(手杀)
	["f_shenguojia"] = "神郭嘉[手杀]",
	["&f_shenguojia"] = "神郭嘉",
	["#f_shenguojia"] = "星月奇佐",
	["designer:f_shenguojia"] = "黑稻子,官方",
	["cv:f_shenguojia"] = "官方",
	["illustrator:f_shenguojia"] = "木美人,紫髯的小乔",
	  --慧识（有改动）
	["f_huishi"] = "慧识",
	["f_huishiContinue"] = "慧识",
	["f_huishicontinue"] = "慧识",
	[":f_huishi"] = "出牌阶段限一次，若你的体力上限小于10，你可以进行判定：若结果与此阶段内以此法进行判定的结果的花色均不同且此时你的体力上限小于10，你可以重复此流程并加1点体力上限，否则你终止判定。所有流程结束后，你可以将所有判定牌交给一名角色。然后若<font color='red'><b>你</b></font>手牌数为全场最多，你减1点体力上限。",
	["HandcarddataHS"] = "慧识",
	["@f_huishi_continue"] = "[慧识]你可以继续判定",
	["f_huishi-give"] = "请将所有判定牌交给一名角色",
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
	  [":ty_zuoxing"] = "出牌阶段限一次，若<font color='red'><b>令你获得此技能的角色</b></font>存活且其体力上限大于1，你可以令其减1点体力上限，若如此做，你可以视为使用一张普通锦囊牌。",
	  ["$ty_zuoxing1"] = "以聪虑难，悉咨于上。",
	  ["$ty_zuoxing2"] = "奉孝不才，愿献勤心。",
	  ["$ty_zuoxing3"] = "既为奇佐，岂可徒有虚名？",
	  --辉逝（有改动）
	["f_huishii"] = "辉逝",
	[":f_huishii"] = "限定技，出牌阶段，你可以选择一名角色：<font color='red'><b>若其为你，且你的觉醒技“天翊”未触发，且你的体力上限不小于X（X为全场存活角色数），则你视为已达成“天翊”的觉醒条件</b></font>；否则其摸四张牌。若如此做，你减2点体力上限。",
	["@f_huishii"] = "辉逝",
	["f_tianyi_Trigger"] = "“天翊”已可觉醒",
	["$f_huishii1"] = "丧家之犬，主公实不足虑也！",
	["$f_huishii2"] = "时势兼备，主公复有何忧？",
	  --阵亡
	["~f_shenguojia"] = "可叹桢干命也迂..........",
	
	--神荀彧(手杀)
	["f_shenxunyu"] = "神荀彧[手杀]",
	["&f_shenxunyu"] = "神荀彧",
	["#f_shenxunyu"] = "洞心先识",
	["designer:f_shenxunyu"] = "官方",
	["cv:f_shenxunyu"] = "官方",
	["illustrator:f_shenxunyu"] = "枭瞳,紫髯的小乔",
	
	["ngCRemover"] = "加入[神武将专属卡牌]",
	["ngcremover"] = "加入[神武将专属卡牌]",
	["@ngCRemover"] = "是否加入【神武将专属卡牌】？",
	--["~ngCRemover"] = "包括：奇正相生、调剂盐梅、远交近攻\
	["~ngCRemover"] = "包括：奇正相生\
	如果场上有技能“天佐”，【奇正相生】不会被移除",
	
	  --天佐
	["f_tianzuo"] = "天佐",
	[":f_tianzuo"] = "游戏开始前，你将八张【奇正相生】加入牌堆。<font color='red'><b>当有一名角色成为你于游戏开始前加入的【奇正相生】的目标时，你可以查看其手牌，然后为其重新指定“正兵”或“奇兵”。</b></font>",
	["zhengbing"] = "指定为“正兵”",
	["qibing"] = "指定为“奇兵”",
	["$f_tianzuo1"] = "此时进之多弊，守之多利，愿主公熟虑。",
	["$f_tianzuo2"] = "主公若不时定，待四方生心，则无及矣！",
	    --普通单体锦囊:奇正相生
	  ["f_qizhengxiangsheng"] = "奇正相生",
	  ["Fqizhengxiangsheng"] = "奇正相生",
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
	  --灵策（这里的智囊牌是记录在“三十六计”中的锦囊牌名）
	["f_lingce"] = "灵策",
	[":f_lingce"] = "锁定技，一名角色使用智囊牌名的锦囊牌<font color='red'><b>(借刀杀人/无中生有/顺手牵羊/铁索连环)</b></font>、“定汉”已记录的牌名或【奇正相生】时，你摸一张牌。",
	["$f_lingce1"] = "绍士卒虽众，其实难用，必无为也！",
	["$f_lingce2"] = "袁军不过一盘砂砾，主公用奇则散！",
	  --定汉
	["f_dinghan"] = "定汉",
	["f_dinghanMR"] = "定汉",
	[":f_dinghan"] = "每种牌名限一次，你成为锦囊牌的目标时，你记录此牌名，然后取消之。你的回合开始时，你可以在“定汉”记录中增加或移除一种锦囊牌名。<font color='red'><b>（锦囊牌记录范围：标准包、军争篇、应变篇、天灾包、奇正相生）</b></font>",
	["addtrickcard"] = "增加一种锦囊牌名",
	["rmvtrickcard"] = "移除一种锦囊牌名",
	["cancel"] = "取消",
	    --记录牌名：
	  ["dly"] = "【延时锦囊】",
	  
	  ["jdsr"] = "借刀杀人", --胜战计,第3计
	  ["wzsy"] = "无中生有", --敌战计,第7计
	  ["ssqy"] = "顺手牵羊", --敌战计,第12计
	  ["tslh"] = "铁索连环", --败战计,第35计(原名:连环计)
	  
	  ["ghcq"] = "过河拆桥",
	  ["nmrq"] = "南蛮入侵",
	  ["wjqf"] = "万箭齐发",
	  ["wgfd"] = "五谷丰登",
	  ["tyjy"] = "桃园结义",
	  ["jd"] = "决斗",
	  ["wxkj"] = "无懈可击",
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
	
	--神太史慈(手杀)
	["f_shentaishici"] = "神太史慈[手杀]",
	["&f_shentaishici"] = "神太史慈",
	["#f_shentaishici"] = "义信天武",
	["designer:f_shentaishici"] = "官方",
	["cv:f_shentaishici"] = "官方",
	["illustrator:f_shentaishici"] = "枭瞳,紫髯的小乔",
	  --笃烈（“围”标记改成了随机获得）
	["f_dulie"] = "笃烈",
	["f_dulieEXS"] = "笃烈",
	[":f_dulie"] = "锁定技，游戏开始时，所有其他角色<font color='red'><b>随机</b></font>获得“围”标记。你对没有“围”标记的角色使用【杀】无距离限制，且当你成为没有“围”标记的角色使用【杀】的目标时，你进行判定：若判定结果为红桃，取消之。",
	["WEI"] = "围", --与原版神太史慈的“围”标记不同
	["$f_dulie1"] = "素来言出必践，成吾信义昭彰！",
	["$f_dulie2"] = "小信如若不成，大信将以何立？",
	  --破围
	["f_powei"] = "破围",
	[":f_powei"] = "<font color='yellow'><b>使命技，</b></font>你使用的【杀】对有“围”标记的角色造成伤害时，弃置该“围”标记并防止此伤害。\
	使命<b>成功</b>：你使用的【杀】结算结束后，若场上没有“围”标记，且你未于这之前进入过濒死状态，则你使命达成，<font color='red'><b>摸X张牌</b></font>并获得“神著”（X为你本局弃置的“围”标记数）；\
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
	  --荡魔（有改动）
	["f_dangmo"] = "荡魔",
	[":f_dangmo"] = "你于出牌阶段使用的第一张【杀】可以多选Y-1名角色。（Y为你的当前体力值<font color='red'><b>且至少为1</b></font>）", --注：防止和老周泰双将时在不屈状态砍不了人的情况
	["$f_dangmo1"] = "魔高一尺，道高一丈！",
	["$f_dangmo2"] = "天魔祸世，吾自荡而除之！",
	
	["stscAudio"] = "", --神太史慈专用音响
	  --阵亡
	["~f_shentaishici"] = "魂归......天...地...",
	
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
	
	--神孙策(手杀)
	["f_shensunce"] = "神孙策[手杀]",
	["#f_shensunce"] = "踞江鬼雄",
	["designer:f_shensunce"] = "官方",
	["cv:f_shensunce"] = "官方",
	["illustrator:f_shensunce"] = "枭瞳,紫髯的小乔",
	["&f_shensunce"] = "神孙策",
	  --英霸（有改动）
	["imba"] = "英霸",
	["imbaMaxDistance"] = "英霸",
	["imbaNoLimit"] = "英霸",
	[":imba"] = "出牌阶段限一次，你可以选择一名体力上限大于1的其他角色，令其减1点体力上限并获得1枚“平定”标记，然后你减1点体力上限。你对拥有“平定”标记的角色使用牌无距离限制<font color='red'><b>且次数+X</b></font>（X为其拥有的“平定”标记数）。",
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
	  --冯河
	["f_pinghe"] = "冯河",
	["f_pingheDefuseDamage"] = "冯河",
	["f_pinghedefusedamage"] = "冯河",
	["f_pingheAudio"] = "冯河",
	[":f_pinghe"] = "锁定技，你的手牌上限等于你已损失的体力值。当你受到其他角色造成的伤害时，若你有手牌且体力上限大于1，防止本次伤害，然后你减1点体力上限并将一张手牌交给一名其他角色，然后若你拥有“英霸”，令伤害来源获得1枚“平定”标记。",
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
	["os_shenguanyu"] = "神關羽[手殺]",
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
	
	
	--神姜维(新杀)
	  --爆料版
	["ty_shenjiangweiBN"] = "神姜维[十周年]-爆料版", --爆料的技能描述有很模糊且逻辑不通的地方，根据自己的理解有所修改
	["&ty_shenjiangweiBN"] = "神姜维",
	["#ty_shenjiangweiBN"] = "兴汉怒麟",
	["designer:ty_shenjiangweiBN"] = "官方",
	["cv:ty_shenjiangweiBN"] = "官方",
	["illustrator:ty_shenjiangweiBN"] = "NOWART",
	  --九伐
	["tyjiufaBN"] = "九伐",
	[":tyjiufaBN"] = "每当你使用九张不同牌名的牌后，你可以亮出牌堆顶的九张牌，你选择并获得其中点数<font color='red'><b>不同</b></font>的牌各一张，其余的牌置入弃牌堆。",
	["tyjiufaBNRecord"] = "九伐",
	["$tyjiufaBN1"] = "",
	["$tyjiufaBN2"] = "",
	  --天任
	["tytianrenBN"] = "天任",
	[":tytianrenBN"] = "锁定技，当有基本牌或普通锦囊牌不因使用而进入弃牌堆后，你获得1枚“天任”标记。当你的“天任”标记大于等于你的体力上限时，你移除等同于你当前体力上限值的“天任”标记然后增加1点体力上限并摸两张牌。",
	["$tytianrenBN1"] = "",
	["$tytianrenBN2"] = "",
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
	["$typingxiangBN1"] = "",
	["$typingxiangBN2"] = "",
	  --阵亡
	["~ty_shenjiangweiBN"] = "",
	
	  --正式版
	["ty_shenjiangwei"] = "神姜维[十周年]",
	["&ty_shenjiangwei"] = "神姜维",
	["#ty_shenjiangwei"] = "怒麟燎原",
	["designer:ty_shenjiangwei"] = "官方",
	["cv:ty_shenjiangwei"] = "官方",
	["illustrator:ty_shenjiangwei"] = "匠人绘,紫髯的小乔",
	  --九伐
	["tyjiufa"] = "九伐",
	[":tyjiufa"] = "每当你使用九张不同牌名的牌后，你可以亮出牌堆顶的九张牌，你选择并获得其中点数重复的牌各一张，其余的牌置入弃牌堆。",
	["tyjiufaRecord"] = "九伐",
	["$tyjiufa1"] = "九伐中原，以圆先帝遗志。",
	["$tyjiufa2"] = "日日砺剑，相报丞相厚恩。",
	  --天任
	["tytianren"] = "天任",
	[":tytianren"] = "锁定技，每有一张基本牌或普通锦囊牌不因使用而进入弃牌堆后，你获得1枚“天任”标记。当你的“天任”标记大于等于你的体力上限时，你移除等同于你当前体力上限值的“天任”标记然后增加1点体力上限并摸两张牌。",
	["$tytianren1"] = "举石补苍天，舍我更复其谁？",
	["$tytianren2"] = "天地同协力，何愁汉道不昌？",
	  --平襄
	["typingxiang"] = "平襄",
	["typingxiangFireSlash"] = "平襄",
	["typingxiangfireslash"] = "平襄",
	["typingxiangMaxCards"] = "平襄",
	[":typingxiang"] = "限定技，出牌阶段，若你的体力上限大于9，你减9点体力上限，若如此做，你视为使用至多九张火【杀】（不计次）。然后你失去技能“九伐”且你的手牌上限改为你的体力上限。",
	["@typingxiang"] = "平襄",
	["@typingxiangFireSlash"] = "你可以视为使用一张火【杀】",
	["~typingxiangFireSlash"] = "选择你想砍的可被选择的角色，点【确定】；若点【取消】视为你中止“平襄”火【杀】的持续使用",
	["$typingxiang1"] = "策马纵慷慨，捐躯抗虎豺！",
	["$typingxiang2"] = "解甲事仇雠，竭力挽狂澜！",
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
	
	--神孙权(新杀)
	
	
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
	["$olchuyuan2"] = "这些，都是孤赏赐给你的。",
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
	["ol_shenzhenji"] = "神甄姬[OL]",
	["&ol_shenzhenji"] = "神甄姬",
    ["#ol_shenzhenji"] = "洛神赋",
    ["illustrator:ol_shenzhenji"] = "鬼画符,紫髯的小乔",
	  --神赋
    ["olshenfu"] = "神赋",
    ["olshenfu-invoke"] = "你可以发动“神赋”<br/> <b>操作提示</b>: 选择一名角色→点击确定<br/>",
    [":olshenfu"] = "结束阶段，若你的手牌数为：奇数，你可以对一名其他角色造成1点雷电伤害，然后若造成其死亡，你可重复此流程；偶数，你可以选择一名角色，令其弃置一张牌或摸一张牌，然后若其手牌数等于其体力值，你可重复此流程。",
	["olshenfu:discard"] = "令其弃一张牌",
	["olshenfu:draw"] = "令其摸一张牌",
	["$olshenfu1"] = "河洛之神，诗赋可抒。",
	["$olshenfu2"] = "云神鱼游，罗扇掩面。",
      --七弦
	["olqixian"] = "七弦",
    [":olqixian"] = "锁定技，你的手牌上限为7。",
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
	["$oldili1"] = "位居至尊，掌至高之权。",
	["$oldili2"] = "身处巅峰，揽天下大事。",
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
    ["#ol_shensunquan"] = "",
	["designer:ol_shensunquan"] = "玄蝶",
	["cv:ol_shensunquan"] = "官方",
    ["illustrator:ol_shensunquan"] = "",
	  --阵亡
    ["~ol_shensunquan"] = "困居江东，妄称至尊......",
	
	
	--神孙权(欢乐杀)
	["joy_shensunquan"] = "神孙权[欢乐杀]",
	["&joy_shensunquan"] = "欢乐神孙权",
	["#joy_shensunquan"] = "英雄无觅",
	["designer:joy_shensunquan"] = "欢乐杀",
	["cv:joy_shensunquan"] = "官方,英雄杀",
	["illustrator:joy_shensunquan"] = "欢乐杀",
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
	["joydingliUsed"] = "",
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
	["illustrator:joy_shenzhangliao"] = "欢乐杀",
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
	["illustrator:joy_shendianwei"] = "欢乐杀",
	  --神卫
	["joyshenwei"] = "神卫",
	["joyshenweiMoveDamage"] = "神卫",
	[":joyshenwei"] = "回合开始时，你可以选择一名角色获得“卫”标记（每名角色至多1枚）；有“卫”标记的角色受到伤害时可以移除“卫”标记，然后你承受本次伤害。",
	["joyWEI"] = "卫",
	["@joyshenwei-card"] = "请选择一名没有“卫”标记的角色",
	["~joyshenwei"] = "点击一名可被选择的角色，点【确定】",
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
	["illustrator:joy_shenhuatuo"] = "欢乐杀",
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
	["f_sandaoDraw"] = "三刀",
	["f_sandaoLevelUp"] = "三刀",
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
	
	--待续......
	
	--更换武将皮肤--
	["mobileGOD_SkinChange"] = "更换武将皮肤",
	["mobileGOD_SkinChange_Button"] = "换皮",
	["mobilegod_skinchange_button"] = "更换武将皮肤",
	["mobileGOD_SkinChange_ButtonCard"] = "更换武将皮肤",
	["sjyh"] = "原画",
	--神郭嘉(手杀)
	["sgj_hnqm"] = "虎年清明",
	["f_shenguojia_c"] = "神郭嘉[手杀]",
	["&f_shenguojia_c"] = "神郭嘉",
	["~f_shenguojia_c"] = "可叹桢干命也迂..........",
	--神荀彧(手杀)
	["sxy_hnqm"] = "虎年清明",
	["sxy_yjzl"] = "阴间天王",
	["f_shenxunyu_c"] = "神荀彧[手杀]",
	["&f_shenxunyu_c"] = "神荀彧",
	["~f_shenxunyu_c"] = "宁鸣而死，不默而生！",
	["f_shenxunyu_x"] = "神荀彧[手杀]",
	["&f_shenxunyu_x"] = "神荀彧",
	["~f_shenxunyu_x"] = "宁鸣而死，不默而生！",
	["$mobileGOD_SkinChange"] = "", --神荀彧、神孙策墨镜皮肤（双将模式仅作为主将）登场BGM
	--神孙策(手杀)
	["ssc_yjzl"] = "阴间天王",
	["f_shensunce_x"] = "神孙策[手杀]",
	["&f_shensunce_x"] = "神孙策",
	["~f_shensunce_x"] = "无耻小人，胆敢暗算于我！......",
	--神马超(新杀)
	["smc_xwjl"] = "迅骛惊雷",
	["smc_xyxc"] = "星夜袭曹", --其实是马超的手杀传说动皮
	["ty_shenmachao_1"] = "神马超[十周年]",
	["&ty_shenmachao_1"] = "神马超",
	["~ty_shenmachao_1"] = "",
	["ty_shenmachao_t"] = "神马超[十周年]",
	["&ty_shenmachao_t"] = "神马超",
	["~ty_shenmachao_t"] = "",
}
return {extension, extension_t, extension_o, extension_j, extension_f, newgodsCard}