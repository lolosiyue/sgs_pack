--==《新武将》==--
extension = sgs.Package("kearjsrgthe", sgs.Package_GeneralPack)
local skills = sgs.SkillList()

function KeheToData(self)
	local data = sgs.QVariant()
	if type(self)=="string"
	or type(self)=="boolean"
	or type(self)=="number"
	then data = sgs.QVariant(self)
	elseif self~=nil then data:setValue(self) end
	return data
end
function kehegetCardList(intlist)
	local ids = sgs.CardList()
	for _, id in sgs.qlist(intlist) do
		ids:append(sgs.Sanguosha:getCard(id))
	end
	return ids
end
--buff集中
keheslashmore = sgs.CreateTargetModSkill{
	name = "keheslashmore",
	pattern = ".",
	residue_func = function(self, from, card, to)
		local n = 0
		if (card:getSkillName() == "kehexuanfeng") then
			n = n + 1000
		end
		if from and from:hasSkill("kehezhubei") and to and (to:getMark("&kehezhubeisp-Clear") > 0) then
			n = n + 1000
		end
		return n
	end,
	extra_target_func = function(self, from, card)
		--[[local n = 0
		if (from:getMark("&kechengneifaNotBasic") > 0 and card:isNDTrick()) then
			n = n + 1
		end
		return n]]
	end,
	distance_limit_func = function(self, from, card, to)
		local n = 0
		if (card:getSkillName() == "kehexuanfeng") then
			n = n + 1000
		end
		return n
	end
}
if not sgs.Sanguosha:getSkill("keheslashmore") then skills:append(keheslashmore) end


kezhuanxumou_card_one = sgs.CreateTrickCard{
	name = "_kezhuanxumou_card_one",
	class_name = "XumouCardone",
	subtype = "xumou_card",
	subclass = sgs.LuaTrickCard_TypeDelayedTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = false,
	movable = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and not to_select:containsTrick(self:objectName()) 
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, effect.to:objectName())
		room:throwCard(self, reason, nil)
	end,
}
local card = kezhuanxumou_card_one:clone()
card:setSuit(0)
card:setNumber(0)
card:setParent(extension)

kezhuanxumou_card_two = sgs.CreateTrickCard{
	name = "_kezhuanxumou_card_two",
	class_name = "XumouCardtwo",
	subtype = "xumou_card",
	subclass = sgs.LuaTrickCard_TypeDelayedTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = false,
	movable = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and not to_select:containsTrick(self:objectName()) 
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, effect.to:objectName())
		room:throwCard(self, reason, nil)
	end,
}
local card = kezhuanxumou_card_two:clone()
card:setSuit(0)
card:setNumber(0)
card:setParent(extension)

kezhuanxumou_card_three = sgs.CreateTrickCard{
	name = "_kezhuanxumou_card_three",
	class_name = "XumouCardthree",
	subtype = "xumou_card",
	subclass = sgs.LuaTrickCard_TypeDelayedTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = false,
	movable = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and not to_select:containsTrick(self:objectName()) 
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, effect.to:objectName())
		room:throwCard(self, reason, nil)
	end,
}
local card = kezhuanxumou_card_three:clone()
card:setSuit(0)
card:setNumber(0)
card:setParent(extension)

kezhuanxumou_card_four = sgs.CreateTrickCard{
	name = "_kezhuanxumou_card_four",
	class_name = "XumouCardfour",
	subtype = "xumou_card",
	subclass = sgs.LuaTrickCard_TypeDelayedTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = false,
	movable = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and not to_select:containsTrick(self:objectName()) 
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, effect.to:objectName())
		room:throwCard(self, reason, nil)
	end,
}
local card = kezhuanxumou_card_four:clone()
card:setSuit(0)
card:setNumber(0)
card:setParent(extension)

kezhuanxumou_card_five = sgs.CreateTrickCard{
	name = "_kezhuanxumou_card_five",
	class_name = "XumouCardfive",
	subtype = "xumou_card",
	subclass = sgs.LuaTrickCard_TypeDelayedTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = false,
	movable = false,
	filter = function(self, targets, to_select)
		return #targets == 0 and not to_select:containsTrick(self:objectName()) 
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, effect.to:objectName())
		room:throwCard(self, reason, nil)
	end,
}
local card = kezhuanxumou_card_five:clone()
card:setSuit(0)
card:setNumber(0)
card:setParent(extension)


kehezhugeliang = sgs.General(extension, "kehezhugeliang", "shu", 3,true)

kehewentianVS = sgs.CreateViewAsSkill{
	name = "kehewentian",
	view_as = function(self, cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern == "nullification" then
			local use_card = sgs.Sanguosha:cloneCard("nullification")
			use_card:addSubcard(sgs.Self:getMark("kehewentianId"))
			use_card:setSkillName("kehewentian")
			return use_card
		else
			local use_card = sgs.Sanguosha:cloneCard("fire_attack")
			use_card:addSubcard(sgs.Self:getMark("kehewentianId"))
			use_card:setSkillName("kehewentian")
			return use_card
		end
	end,
	enabled_at_play = function(self, player)
		return (player:getMark("&bankehewentian_lun") == 0)
	end, 
    enabled_at_response = function(self,player,pattern)
	   	return ((player:getMark("&bankehewentian_lun") == 0) and (pattern == "nullification")) 
	end,
	enabled_at_nullification = function(self,player)				
		return (player:getMark("&bankehewentian_lun") == 0) 
	end
}
kehewentian = sgs.CreateTriggerSkill{
	name = "kehewentian",
	view_as_skill = kehewentianVS,
	events = {sgs.CardsMoveOneTime,sgs.EventPhaseStart,sgs.PreCardUsed,sgs.Death,sgs.GameReady},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.GameReady) and player:hasSkill(self:objectName()) then
			room:setPlayerMark(player,"@usekehewentian",7)
		end
		if (event == sgs.EventPhaseStart)
		and (player:getMark("usedkehewentian-Clear") == 0)
		--一般主阶段列举
		and ((player:getPhase() == sgs.Player_Start) 
		or (player:getPhase() == sgs.Player_Judge)
		or (player:getPhase() == sgs.Player_Draw)
		or (player:getPhase() == sgs.Player_Play)
		or (player:getPhase() == sgs.Player_Discard)
		or (player:getPhase() == sgs.Player_Finish)
	    )
		then	
			if (player:getMark("&bankehewentian_lun") == 0) and room:askForSkillInvoke(player,self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName())
				room:setPlayerMark(player,"usedkehewentian-Clear",1)
				local card_ids = room:getNCards(math.max(1,player:getMark("@usekehewentian")))
				room:fillAG(card_ids,player)
				--选牌给人
				local duiyounum = 0
				if (player:getState() ~= "online") then
					for _,other in sgs.qlist(room:getOtherPlayers(player)) do
						if (player:isYourFriend(other)) then
							duiyounum = 1 
							break 
						end
					end
				end
				local card_id 
				--电脑且没有队友
				if (player:getState() ~= "online") and (duiyounum == 0) then
					card_id = -1
				else
				    card_id = room:askForAG(player, card_ids, true, "kehewentian","kehewentianchoose-ask")
				end
				if not (card_id == -1) then
					room:takeAG(nil, card_id, false)
					local fri = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "kehewentian-ask",false)
					if fri then
						if (player:getState() == "online") then
							if sgs.Sanguosha:getCard(card_id):isRed() then
								room:setPlayerFlag(fri,"kehewentianred")
							else
								room:setPlayerFlag(fri,"kehewentianblack")
							end
						end
						card_ids:removeOne(card_id)
						fri:obtainCard(sgs.Sanguosha:getCard(card_id))
					end
				end	
				room:clearAG()
				--开始观星
				if (card_ids:length() > 0) then
				    room:askForGuanxing(player,card_ids)
				end
				if (player:getMark("@usekehewentian") > 1) then
				    room:removePlayerMark(player,"@usekehewentian")
				end
			end
		end
		if (event == sgs.CardsMoveOneTime)
		then
	     	local move = data:toMoveOneTime()
			if move.to_place==sgs.Player_DrawPile or move.from_places:contains(sgs.Player_DrawPile)
			then room:setPlayerMark(player,"kehewentianId",room:getDrawPile():first()) end
		end
		if (event == sgs.PreCardUsed)
		then
			local use = data:toCardUse()
			if use.card:getSkillName()=="kehewentian"
			then
				if use.card:isKindOf("Nullification") and not use.card:isBlack()
				or use.card:isKindOf("FireAttack") and not use.card:isRed()
				then room:addPlayerMark(player,"&bankehewentian_lun") end
			end
		end
		--鸣谢毒主任
		if (event == sgs.Death) then
			local death = data:toDeath()
			if death.who:hasSkill(self:objectName()) then
				local reason = death.damage
				if not reason then
				    room:broadcastSkillInvoke("kehewentiancaidan")
				else
					local killer = reason.from
					if not killer then
				        room:broadcastSkillInvoke("kehewentiancaidan")
					end
				end
			end
		end
	end,
	can_trigger = function(self,target)
		return target and target:hasSkill(self:objectName())
	end
}
kehezhugeliang:addSkill(kehewentian)

kehewentiancaidan = sgs.CreateTriggerSkill{
	name = "kehewentiancaidan",
	events = {},
	on_trigger = function(self, event, player, data)
	end,
	can_trigger = function(self,target)
		return false
	end
}
if not sgs.Sanguosha:getSkill("kehewentiancaidan") then skills:append(kehewentiancaidan) end


kehechushiCard = sgs.CreateSkillCard{
	name = "kehechushiCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, player, targets)
		local zhugong
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if (p:getRole() == "lord") then
				zhugong = p
				break
			end
		end
		--议事
		local zgandzg = sgs.SPlayerList()
		zgandzg:append(player)
		if (zhugong:objectName() ~= player:objectName()) then
		    zgandzg:append(zhugong)
		end
		for _,p in sgs.qlist(zgandzg) do
			room:setPlayerMark(p,"keyishiing",1)
			--每个人提前挑选牌准备展示
			if not p:isKongcheng() then
				local id = room:askForExchange(p, "kehechushi", 1, 1, false, "keqichaozheng_yishi"):getSubcards():first()
				local card = sgs.Sanguosha:getCard(id)
				room:setCardFlag(card,"useforyishi")
				if card:isRed() then
					room:setPlayerMark(p,"keyishi_red",1)
				elseif card:isBlack() then
					room:setPlayerMark(p,"keyishi_black",1)
				end
				--标记选择了牌的人（没有空城的人）
				room:setPlayerMark(p,"chooseyishi",1)
			end
		end
		--依次展示选好的牌，公平公正公开
		local sj = room:findPlayerBySkillName("kehebazheng")
		if sj then
			for _,bz in sgs.qlist(room:getAllPlayers()) do
				if (bz:getMark("&kehebazheng-Clear") > 0) then
					if (sj:getMark("keyishi_red") > 0) and (bz:getMark("keyishi_black") > 0) then
						room:setPlayerMark(bz,"keyishi_black",0)
						room:setPlayerMark(bz,"keyishi_red",1)
						local log = sgs.LogMessage()
						log.type = "$kehebazhengredlog"
						log.from = bz
						log.to:append(sj)
						room:sendLog(log)
					elseif (sj:getMark("keyishi_black") > 0) and (bz:getMark("keyishi_red") > 0) then
						room:setPlayerMark(bz,"keyishi_black",1)
						room:setPlayerMark(bz,"keyishi_red",0)
						local log = sgs.LogMessage()
						log.type = "$kehebazhengblacklog"
						log.from = bz
						log.to:append(sj)
						room:sendLog(log)
					end
				end
			end
		end
		room:getThread():delay(800)
		local yishirednum = 0
		local yishiblacknum = 0
		for _,p in sgs.qlist(zgandzg) do
			if (p:getMark("keyishi_black") > 0) then yishiblacknum = yishiblacknum + 1 end
			if (p:getMark("keyishi_red") > 0) then yishirednum = yishirednum + 1 end
			for _,c in sgs.qlist(p:getCards("h")) do
				if c:hasFlag("useforyishi") then
					room:showCard(p,c:getEffectiveId())
					room:setCardFlag(c,"-useforyishi")
					break
				end
			end	
		end
		room:getThread():delay(1200)
		--0为平局（默认），1：红色；2：黑色
		local yishiresult = 0
		if (yishirednum > yishiblacknum) then
			yishiresult = 1
			local log = sgs.LogMessage()
			log.type = "$keyishired"
			log.from = player
			room:sendLog(log)	
			room:doLightbox("$keyishired")
		elseif (yishirednum < yishiblacknum) then
			yishiresult = 2
			local log = sgs.LogMessage()
			log.type = "$keyishiblack"
			log.from = player
			room:sendLog(log)	
			room:doLightbox("$keyishiblack")
		elseif (yishirednum == yishiblacknum) then
			yishiresult = 0
			local log = sgs.LogMessage()
			log.type = "$keyishipingju"
			log.from = player
			room:sendLog(log)	
			room:doLightbox("$keyishipingju")
		end
		--结果
		if (yishiresult == 1) then
			local goon = 1
			while (goon == 1) do
				player:drawCards(1)
				zhugong:drawCards(1)
				local allnum = 0
				allnum = player:getHandcardNum() + zhugong:getHandcardNum()
				if (allnum >= 7) then
					goon = 0
				end
			end	
		elseif (yishiresult == 2) then
			room:setPlayerMark(player,"&kehechushi_lun",1)
		end
		--开始清理标记
		for _,p in sgs.qlist(room:getAllPlayers()) do
			if (p:getMark("keyishiing")>0) then room:setPlayerMark(p,"keyishiing",0) end
			if (p:getMark("chooseyishi")>0) then room:setPlayerMark(p,"chooseyishi",0) end
		end
		for _,p in sgs.qlist(room:getAllPlayers()) do
			if (p:getMark("keyishi_red")>0) then room:setPlayerMark(p,"keyishi_red",0) end
			if (p:getMark("keyishi_black")>0) then room:setPlayerMark(p,"keyishi_black",0) end
		end
		--清除ai
		for _,p in sgs.qlist(room:getAllPlayers()) do
			--[[room:setPlayerFlag(p,"-chaozhengwantblack")
			room:setPlayerFlag(p,"-chaozhengwantred")]]
		end
	end 
}

kehechushiVS = sgs.CreateZeroCardViewAsSkill{
	name = "kehechushi",
	view_as = function(self, cards)
		return kehechushiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#kehechushiCard")
	end, 
}

kehechushi = sgs.CreateTriggerSkill{
	name = "kehechushi",
	view_as_skill = kehechushiVS,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.ConfirmDamage) then
			local damage = data:toDamage()
			if (damage.nature ~= sgs.DamageStruct_Normal) and (player:getMark("&kehechushi_lun") > 0) then
				local hurt = damage.damage
				damage.damage = hurt + 1
				data:setValue(damage)
			end
		end
	end,
}
kehezhugeliang:addSkill(kehechushi)

keheyinlue = sgs.CreateTriggerSkill{
	name = "keheyinlue",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageInflicted,sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.DamageInflicted) then
			local damage = data:toDamage()    
			if (damage.nature == sgs.DamageStruct_Fire) then
				for _, zgl in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					if (zgl:getMark("&keheyinluemp") == 0) then
						local to_data = sgs.QVariant()
						to_data:setValue(damage.to)
						if zgl:isYourFriend(damage.to) then room:setPlayerFlag(zgl,"wantuseyinlue") end
						if room:askForDiscard(zgl, self:objectName(), 1, 1, true,true,"keheyinluedishuoyan:"..damage.to:objectName(),".",self:objectName()) then
							room:setPlayerFlag(zgl,"-wantuseyinlue")
							room:broadcastSkillInvoke(self:objectName())
							room:setPlayerMark(zgl,"&keheyinluemp",1)
							return true		
					    end
					end
				end
			elseif (damage.nature == sgs.DamageStruct_Thunder) then
				for _, zgl in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					if (zgl:getMark("&keheyinlueqp") == 0) then
						local to_data = sgs.QVariant()
						to_data:setValue(damage.to)
						if zgl:isYourFriend(damage.to) then room:setPlayerFlag(zgl,"wantuseyinlue") end
						--local will_use = room:askForSkillInvoke(zgl, self:objectName(), to_data)
						if room:askForDiscard(zgl, self:objectName(), 1, 1, true,true,"keheyinluedisleidian:"..damage.to:objectName(),".",self:objectName()) then
							room:setPlayerFlag(zgl,"-wantuseyinlue")
							room:broadcastSkillInvoke(self:objectName())
							room:setPlayerMark(zgl,"&keheyinlueqp",1)
							return true
						end
					end
				end
			end
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_NotActive) then
				for _, zgl in sgs.qlist(room:getAllPlayers()) do
					if (zgl:getMark("&keheyinluemp") > 0) then
						room:setPlayerMark(zgl,"&keheyinluemp",0)
						local phases = sgs.PhaseList()
						phases:append(sgs.Player_Draw)
						zgl:play(phases)
					end
					if (zgl:getMark("&keheyinlueqp") > 0) then
						room:setPlayerMark(zgl,"&keheyinlueqp",0)
						local phases = sgs.PhaseList()
						phases:append(sgs.Player_Discard)
						zgl:play(phases)
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
kehezhugeliang:addSkill(keheyinlue)

kehejiangwei = sgs.General(extension, "kehejiangwei", "shu", 4,true)

kehejinfaCard = sgs.CreateSkillCard{
	name = "kehejinfaCard" ,
	target_fixed = true ,
	will_throw = false,
	on_use = function(self, room, player, targets)
		room:showCard(player,self:getSubcards())
		local zhanshicard = sgs.Sanguosha:getCard(self:getSubcards():first())
		local jfplayers = sgs.SPlayerList()
		for _,p in sgs.qlist(room:getAllPlayers()) do
			--for ai
			if p:isYourFriend(player) then
				if zhanshicard:isRed() then
					room:setPlayerFlag(p,"wantjinfared")
				else
					room:setPlayerFlag(p,"wantjinfablack")
				end
			end
			if (p:getMaxHp() <= player:getMaxHp()) then
				jfplayers:append(p)
			end
		end
		for _,p in sgs.qlist(jfplayers) do
			room:setPlayerMark(p,"keyishiing",1)
			--每个人提前挑选牌准备展示
			if not p:isKongcheng() then
				local id = room:askForExchange(p, "kehejinfa", 1, 1, false, "keqichaozheng_yishi"):getSubcards():first()
				local card = sgs.Sanguosha:getCard(id)
				room:setCardFlag(card,"useforyishi")
				if card:isRed() then
					room:setPlayerMark(p,"keyishi_red",1)
				elseif card:isBlack() then
					room:setPlayerMark(p,"keyishi_black",1)
				end
				--标记选择了牌的人（没有空城的人）
				room:setPlayerMark(p,"chooseyishi",1)
			end
		end
		--依次展示选好的牌，公平公正公开
		room:getThread():delay(800)
		local sj = room:findPlayerBySkillName("kehebazheng")
		if sj then
			for _,bz in sgs.qlist(room:getAllPlayers()) do
				if (bz:getMark("&kehebazheng-Clear") > 0) then
					if (sj:getMark("keyishi_red") > 0) and (bz:getMark("keyishi_black") > 0) then
						room:setPlayerMark(bz,"keyishi_black",0)
						room:setPlayerMark(bz,"keyishi_red",1)
						local log = sgs.LogMessage()
						log.type = "$kehebazhengredlog"
						log.from = bz
						log.to:append(sj)
						room:sendLog(log)
					elseif (sj:getMark("keyishi_black") > 0) and (bz:getMark("keyishi_red") > 0) then
						room:setPlayerMark(bz,"keyishi_black",1)
						room:setPlayerMark(bz,"keyishi_red",0)
						local log = sgs.LogMessage()
						log.type = "$kehebazhengblacklog"
						log.from = bz
						log.to:append(sj)
						room:sendLog(log)
					end
				end
			end
		end
		local yishirednum = 0
		local yishiblacknum = 0
		for _,p in sgs.qlist(room:getAllPlayers()) do
			if (p:getMark("keyishi_black") > 0) then yishiblacknum = yishiblacknum + 1 end
			if (p:getMark("keyishi_red") > 0) then yishirednum = yishirednum + 1 end
			for _,c in sgs.qlist(p:getCards("h")) do
				if c:hasFlag("useforyishi") then
					--if c:isRed() then yishirednum = yishirednum + 1 end
					--if c:isBlack() then yishiblacknum = yishiblacknum + 1 end
					room:showCard(p,c:getEffectiveId())
					room:setCardFlag(c,"-useforyishi")
					break
				end
			end
		end
		room:getThread():delay(1200)
		--0为平局（默认），1：红色；2：黑色
		local yishiresult = 0
		if (yishirednum > yishiblacknum) then
			yishiresult = 1
			local log = sgs.LogMessage()
			log.type = "$keyishired"
			log.from = player
			room:sendLog(log)	
			room:doLightbox("$keyishired")
		elseif (yishirednum < yishiblacknum) then
			yishiresult = 2
			local log = sgs.LogMessage()
			log.type = "$keyishiblack"
			log.from = player
			room:sendLog(log)	
			room:doLightbox("$keyishiblack")
		elseif (yishirednum == yishiblacknum) then
			yishiresult = 0
			local log = sgs.LogMessage()
			log.type = "$keyishipingju"
			log.from = player
			room:sendLog(log)	
			room:doLightbox("$keyishipingju")
		end
		--效果：
		if ((yishiresult == 1) and (zhanshicard:isRed())) or ((yishiresult == 2) and (zhanshicard:isBlack())) then
			local fris = room:askForPlayersChosen(player, jfplayers, "kehejinfa", 0, 2, "kehejinfa-ask", true, true)
			for _,p in sgs.qlist(fris) do
				local cha = p:getMaxHp() - p:getHandcardNum()
				if cha > 0 then
					p:drawCards(math.min(5,cha))
				end
			end
		else
			local num = 2
			local yiji_cards = sgs.IntList()
			while (num > 0) do
				for _,id in sgs.qlist(sgs.Sanguosha:getRandomCards(true)) do
					if sgs.Sanguosha:getEngineCard(id):isKindOf("kezhuan_ying") and (room:getCardPlace(id) ~= sgs.Player_DrawPile)
					and (room:getCardPlace(id) ~= sgs.Player_PlaceHand) and (room:getCardPlace(id) ~= sgs.Player_PlaceEquip) then
						if not yiji_cards:contains(id) then
							room:setCardFlag(sgs.Sanguosha:getCard(id),"-kefirstdes")
							yiji_cards:append(id)
							break
						end
					end
				end
				num = num - 1
			end
			if not yiji_cards:isEmpty() then
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				dummy:addSubcards(kehegetCardList(yiji_cards))
				player:obtainCard(dummy)
				dummy:deleteLater()
			end
		end
		if ((player:getMark("keyishi_red") > 0) and (yishirednum == 1))
		or ((player:getMark("keyishi_black") > 0) and (yishiblacknum == 1)) then
			local kd = room:askForKingdom(player)
			if (player:getKingdom() ~= kd) then
				room:setPlayerProperty(player, "kingdom", sgs.QVariant(kd))
			end
		end
		--开始清理标记
		for _,p in sgs.qlist(room:getAllPlayers()) do
			if (p:getMark("keyishiing")>0) then room:setPlayerMark(p,"keyishiing",0) end
			if (p:getMark("chooseyishi")>0) then room:setPlayerMark(p,"chooseyishi",0) end
		end
		for _,p in sgs.qlist(room:getAllPlayers()) do
			if (p:getMark("keyishi_red")>0) then room:setPlayerMark(p,"keyishi_red",0) end
			if (p:getMark("keyishi_black")>0) then room:setPlayerMark(p,"keyishi_black",0) end
		end
		--清除ai
		for _,p in sgs.qlist(room:getAllPlayers()) do
			room:setPlayerFlag(p,"-wantjinfared")
		    room:setPlayerFlag(p,"-wantjinfablack")
		end
	end
}
kehejinfa = sgs.CreateViewAsSkill{
	name = "kehejinfa" ,
	n = 1 ,
	view_filter = function(self, cards, to_select)
		return not to_select:isEquipped()
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local card = kehejinfaCard:clone()
		card:addSubcard(cards[1])
		card:setSkillName(self:objectName())
		return card
	end ,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#kehejinfaCard")
	end
}
kehejiangwei:addSkill(kehejinfa)


kehefumouex = sgs.CreateProhibitSkill{
	name = "kehefumouex",
	is_prohibited = function(self, from, to, card)
		return ((card:getSkillName() == "kehefumou") 
		and (from:hasSkill("kehefumou")) 
		and card:isKindOf("Chuqibuyi") 
		and to and ((to:getMark("&kehefumoured") + to:getMark("&kehefumoublack")) == 0)) 
	end
}
if not sgs.Sanguosha:getSkill("kehefumouex") then skills:append(kehefumouex) end

--[[kehefumouVS = sgs.CreateOneCardViewAsSkill{
	name = "kehefumou",
	view_filter = function(self, card)
		return card:isKindOf("kezhuan_ying") 
	end,
	view_as = function(self, card)
		local suit = card:getSuit()
		local point = card:getNumber()
		local id = card:getId()
		local cqby = sgs.Sanguosha:cloneCard("chuqibuyi", suit, point)
		cqby:setSkillName("kehefumou")
		cqby:addSubcard(id)
		return cqby
	end,
	enabled_at_play = function(self, player)
		return true
	end, 
}]]
kehefumouVS = sgs.CreateViewAsSkill{
	name = "kehefumou" ,
	n = 1 ,
	view_filter = function(self, selected, to_select)
		return #selected == 0 and (not sgs.Self:isJilei(to_select)) and to_select:isKindOf("kezhuan_ying") 
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then
			return nil
		end
		local slash = sgs.Sanguosha:cloneCard("chuqibuyi")
		slash:setSkillName("kehefumou")
		slash:addSubcard(cards[1])
		return slash
	end ,
	enabled_at_play = function()
		return false
	end ,
	enabled_at_response = function(self, player, pattern)
		return pattern:startsWith("@@kehefumou")
	end
}

kehefumou = sgs.CreateTriggerSkill{
	name = "kehefumou",
	view_as_skill = kehefumouVS,
	frequency = sgs.Skill_Frequent,
	events = {sgs.MarkChanged,sgs.Death,sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_NotActive) then
				for _, p in sgs.qlist(room:getAllPlayers()) do 
					if p:getMark("&kehefumoured") > 0 then
						room:removePlayerCardLimitation(p, "use,response", ".|heart,diamond|.|.")
						room:removePlayerMark(p, "&kehefumoured")
					end
					if p:getMark("&kehefumoublack") > 0 then
						room:removePlayerCardLimitation(p, "use,response", ".|club,spade|.|.")
						room:removePlayerMark(p, "&kehefumoublack")
					end
				end
			end
		end
		if (event == sgs.Death) then
			local death = data:toDeath()
			if death.who:hasSkill(self:objectName()) then
				for _, p in sgs.qlist(room:getAllPlayers()) do 
					if p:getMark("&kehefumoured") > 0 then
						room:removePlayerCardLimitation(p, "use,response", ".|heart,diamond|.|.")
						room:removePlayerMark(p, "&kehefumoured")
						local log = sgs.LogMessage()
						log.type = "$kehefumoured"
						log.from = player
						log.to:append(p)
						room:sendLog(log)
					end
					if p:getMark("&kehefumoublack") > 0 then
						room:removePlayerCardLimitation(p, "use,response", ".|club,spade|.|.")
						room:removePlayerMark(p, "&kehefumoublack")
						local log = sgs.LogMessage()
						log.type = "$kehefumoublack"
						log.from = player
						log.to:append(p)
						room:sendLog(log)
					end
				end
			end
		end
		if (event == sgs.MarkChanged) then
			local mark = data:toMark()
			if (mark.name == "chooseyishi") and player:hasSkill(self:objectName()) 
			and (player:getKingdom() == "wei") then
				if (mark.gain < 0) then
					local players = sgs.SPlayerList()
					for _,p in sgs.qlist(room:getAllPlayers()) do
						if ((p:getMark("keyishi_red") > 0) and (player:getMark("keyishi_black") > 0)) then
							room:setPlayerMark(p,"&kehefumoured",1)
							room:setPlayerCardLimitation(p, "use,response", ".|heart,diamond|.|.", false)
						end
						if ((p:getMark("keyishi_black") > 0) and (player:getMark("keyishi_red") > 0)) then
							room:setPlayerMark(p,"&kehefumoublack",1)
							room:setPlayerCardLimitation(p, "use,response", ".|club,spade|.|.", false)
						end		
					end
					room:askForUseCard(player, "@@kehefumou", "kehefumoucpby-ask") 
				end
			end
		end
	end ,
	can_trigger = function(self, player)
		return (player:getKingdom() == "wei")
	end,
}
kehejiangwei:addSkill(kehefumou)


--[[local cscard = sgs.Sanguosha:cloneCard("slash",-1,-1)
cscard:setObjectName("_kecheng_stabs_slash")
cscard:setParent(extension)]]
--[[function AddheCloneCard(name,suit,number,is_gift,revise)
	local c = sgs.Sanguosha:cloneCard(name,suit,number)
	if c
	then
		if is_gift
		then
			c:addCharTag("present_card")
			c:setGift(true)
		end
		c:setObjectName(revise or name)
		c:setParent(extension)
	end
end
AddheCloneCard("slash",0,6,nil,"_kecheng_stabs_slash")]]

kehexuanfengVS = sgs.CreateOneCardViewAsSkill{
	name = "kehexuanfeng",
	view_filter = function(self, card)
		return card:isKindOf("kezhuan_ying") 
	end,
	view_as = function(self, card)
		local suit = card:getSuit()
		local point = card:getNumber()
		local id = card:getId()
		local cisha = sgs.Sanguosha:cloneCard("slash", suit, point)
		--cisha:setObjectName("_kecheng_stabs_slash")
		cisha:setSkillName("kehexuanfeng")
		cisha:addSubcard(id)
		return cisha
	end,
	enabled_at_play = function(self, player)
		local num = 0
		for _,c in sgs.qlist(player:getHandcards()) do
			if c:isKindOf("kezhuan_ying") then
				num = 1
				break
			end
		end
		if (num > 0) then
		    return (player:getKingdom() == "shu")
		else
			return false
		end
	end, 
}

kehexuanfeng = sgs.CreateTriggerSkill{
	name = "kehexuanfeng",
	view_as_skill = kehexuanfengVS,
	events = {sgs.CardUsed,sgs.SlashMissed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if (use.card:getSkillName() == "kehexuanfeng") then
				local log = sgs.LogMessage()
				log.type = "$kehexuanfengcisha"
				log.from = player
				room:sendLog(log)
			end
		end
		if (event == sgs.SlashMissed) then
			local effect = data:toSlashEffect()
			if (effect.slash:getSkillName() == "kehexuanfeng") 
			and effect.to:getHandcardNum()>0
			and effect.jink
			then
				--Skill_msg("_kecheng_stabs_slash",effect.from)
				if (effect.to:getState() ~= "online") and (effect.to:getHandcardNum()>1) then
					if room:askForDiscard(effect.to,"_kecheng_stabs_slash",1,1,false,false,"_kecheng_stabs_slash0:")
					then else room:slashResult(effect,nil) end
				else
					if room:askForDiscard(effect.to,"_kecheng_stabs_slash",1,1,true,false,"_kecheng_stabs_slash0:")
					then else room:slashResult(effect,nil) end
				end
			end
		end
	end ,
	can_trigger = function(self, player)
		return player
	end,
}
kehejiangwei:addSkill(kehexuanfeng)

kehesimayi = sgs.General(extension, "kehesimayi", "wei", 4,true)

kehe_jiejiaguitian = sgs.CreateTrickCard{
	name = "_kehe_jiejiaguitian",
	class_name = "Kehe_jiejiaguitian",
	subclass = sgs.LuaTrickCard_TypeSingleTargetTrick,
	target_fixed = false,
	can_recast = false,
	is_cancelable = true,
    available = function(self,player)
    	local tos = player:getAliveSiblings()
		tos:append(player)
		for _,to in sgs.list(tos)do
			if CanToCard(self,player,to)
			then
				return self:cardIsAvailable(player)
			end
		end
    end,
	filter = function(self,targets,to_select,source)
        if source:isProhibited(to_select,self) then return end
	    return to_select:hasEquip()
		and #targets<=sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget,source,self,to_select)
	end,
	feasible = function(self,targets)
		if sgs.Self:hasEquip() and not sgs.Self:isProhibited(sgs.Self,self)
		then return #targets>=0 end
		return #targets>0
	end,
	about_to_use = function(self,room,use)
		if use.to:isEmpty() then use.to:append(use.from) end
		self:cardOnUse(room,use)
	end,
	on_effect = function(self,effect)
		local room = effect.to:getRoom()
		local dc = dummyCard()
		dc:addSubcards(effect.to:getEquips())
		if dc:subcardsLength()>0
		then
			if (effect.card:getSkillName() == "kehetuigu") then
				local ids = {}
				for _, id in sgs.list(dc:getSubcards()) do
					local thecard = sgs.Sanguosha:getCard(id)
					table.insert(ids,thecard:getEffectiveId())
				end
				ids = table.concat(ids,",")
				room:setPlayerCardLimitation(effect.to, "use", ids, true)
			end
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECYCLE,effect.from:objectName(),effect.to:objectName(),"kehe_jiejiaguitian","")
			room:obtainCard(effect.to,dc,reason,false)
		end
		return false
	end,
}
kehe_jiejiaguitian:clone(-1,-1):setParent(extension)

keheyingshi = sgs.CreateTriggerSkill{
	name = "keheyingshi",
	events = {sgs.TurnedOver} ,
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.TurnedOver) then
			local num = 3
			if ((room:getAllPlayers(true):length() - room:getAllPlayers():length()) > 2) then
				num = 5
			end
			if player:askForSkillInvoke(self,KeToData("keheyingshiuse-ask:"..num)) then
				room:broadcastSkillInvoke(self:objectName())
				local card_ids = room:getNCards(num,true,false)
				room:askForGuanxing(player,card_ids)
			end
		end
	end	
}
kehesimayi:addSkill(keheyingshi)

kehetuigu = sgs.CreateTriggerSkill{
	name = "kehetuigu",
	events = {sgs.CardsMoveOneTime,sgs.TurnStart,sgs.EventPhaseStart,sgs.Death,sgs.RoundEnd,sgs.EventPhaseChanging} ,
	frequency = sgs.Skill_NotFrequent,
	priority = 10,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseChanging) and player:hasSkill(self:objectName()) then
			local change = data:toPhaseChange()
			if (change.from == sgs.Player_NotActive) then
				room:addPlayerMark(player,"kehetuiguhuihe_lun",1)
			end
		end
		if (event == sgs.RoundEnd) and player:hasSkill(self:objectName()) then
			if (player:getMark("kehetuiguhuihe_lun") == 0) then
				room:sendCompulsoryTriggerLog(player,"kehetuigu")
				local log = sgs.LogMessage()
				log.type = "$kehetuigulog"
				log.from = player
				room:sendLog(log)
				room:broadcastSkillInvoke(self:objectName(),math.random(1,2))
				player:gainAnExtraTurn()
			end
		end
		if (event == sgs.EventPhaseStart) and player:hasSkill(self:objectName()) and (player:getPhase() == sgs.Player_RoundStart) then
			if player:askForSkillInvoke(self,KeToData("kehetuiguuse-ask")) then
				room:broadcastSkillInvoke(self:objectName(),math.random(3,4))
				player:turnOver()
				local num = math.floor(player:aliveCount()/2)
				room:addMaxCards(player, num, true)
				player:drawCards(num,self:objectName())
				local xjgt = sgs.Sanguosha:cloneCard("_kehe_jiejiaguitian")
				xjgt:setSkillName("kehetuigu")
				local targets = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getAllPlayers()) do 
					if p:hasEquip() and not (player:isProhibited(p,xjgt)) then
						targets:append(p)
					end
				end
				local theone = room:askForPlayerChosen(player,targets, self:objectName(), "kehetuiguxjgt-ask")
				if theone then
					local card_use = sgs.CardUseStruct()
					card_use.from = player
					card_use.to:append(theone)
					card_use.card = xjgt
					room:useCard(card_use, false)    
					xjgt:deleteLater() 
				end
			end
		end
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from 
			and (move.from:objectName() == player:objectName()) 
			and (move.from_places:contains(sgs.Player_PlaceEquip))
			and player:hasSkill(self:objectName()) then
				room:sendCompulsoryTriggerLog(player,"kehetuigu")
				room:broadcastSkillInvoke(self:objectName())
				room:recover(player, sgs.RecoverStruct())
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
kehesimayi:addSkill(kehetuigu)

keheluxun = sgs.General(extension, "keheluxun", "wu", 3,true)

keheyoujin = sgs.CreateTriggerSkill{
	name = "keheyoujin",
	events = {sgs.EventPhaseStart,sgs.Pindian} ,
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Pindian) then
			local pindian = data:toPindian()
			if (pindian.reason == self:objectName()) then
				room:setPlayerMark(pindian.from,"&keheyoujinnum-Clear",pindian.from_card:getNumber())
				room:setPlayerMark(pindian.to,"&keheyoujinnum-Clear",pindian.to_card:getNumber())
				local fromNumber = pindian.from_card:getNumber()
				local toNumber = pindian.to_card:getNumber()
				if (fromNumber > toNumber) then
					local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					slash:setSkillName(self:objectName())
					local card_use = sgs.CardUseStruct()
					card_use.from = pindian.from
					card_use.to:append(pindian.to)
					card_use.card = slash
					room:useCard(card_use, false)     
					slash:deleteLater()
				elseif (fromNumber < toNumber) then
					local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					slash:setSkillName(self:objectName())
					local card_use = sgs.CardUseStruct()
					card_use.from = pindian.to
					card_use.to:append(pindian.from)
					card_use.card = slash
					room:useCard(card_use, false)     
					slash:deleteLater()
				end
			end
		end
		if (event == sgs.EventPhaseStart) 
		and (player:getPhase() == sgs.Player_Play)
		and player:hasSkill(self:objectName()) then
			local pds = sgs.SPlayerList()
			for _,p in sgs.qlist(room:getOtherPlayers(player)) do
				if (player:canPindian(p, true)) and not p:isKongcheng() then
					pds:append(p)
				end
			end
			local eny = room:askForPlayerChosen(player, pds, self:objectName(), "keheyoujin-ask", true, true)
			if eny then
				room:broadcastSkillInvoke(self:objectName())
				player:pindian(eny, self:objectName(), nil)
			end
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
keheluxun:addSkill(keheyoujin)

keheyoujinex = sgs.CreateCardLimitSkill{
	name = "keheyoujinex",
	limit_list = function(self, player)
		if (player:getMark("&keheyoujinnum-Clear") > 0) then
			return "use,response"
		else
			return ""
		end
	end,
	limit_pattern = function(self, player)
		if (player:getMark("&keheyoujinnum-Clear") > 0) then
			local pattern = {}
			for _,c in sgs.qlist(player:getHandcards()) do
				if (c:getNumber() < player:getMark("&keheyoujinnum-Clear")) then
					table.insert(pattern,c:getEffectiveId())
				end
			end
			pattern = table.concat(pattern,",")
			return pattern
		else
			return ""
		end
	end
}
if not sgs.Sanguosha:getSkill("keheyoujinex") then skills:append(keheyoujinex) end


kehedailaoCard = sgs.CreateSkillCard{
	name = "kehedailaoCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, player, targets)
		room:showAllCards(player)
		player:drawCards(2,"kehedailao")
		local log = sgs.LogMessage()
		log.type = "$kehedailaolog"
		log.from = player
		room:sendLog(log)
		room:throwEvent(sgs.TurnBroken)
	end 
}

kehedailao = sgs.CreateZeroCardViewAsSkill{
	name = "kehedailao",
	view_as = function(self, cards)
		return kehedailaoCard:clone()
	end,
	enabled_at_play = function(self, player)
		local num = 0
		for _,c in sgs.qlist(player:getHandcards()) do
			if (not player:isJilei(c)) and (c:isAvailable(player)) then
				num = num + 1
			end
		end
		if (num == 0) then
			return true
		else
			return false
		end
	end, 
}
keheluxun:addSkill(kehedailao)

kehezhubei = sgs.CreateTriggerSkill{
	name = "kehezhubei",
	events = {sgs.Damaged,sgs.CardsMoveOneTime,sgs.ConfirmDamage} ,
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.ConfirmDamage) then
			local damage = data:toDamage()
			if damage.from:hasSkill(self:objectName()) and (damage.to:getMark("&kehezhubeida-Clear") > 0) then
				room:sendCompulsoryTriggerLog(damage.from,self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				local hurt = damage.damage                   
				damage.damage = hurt + 1
				data:setValue(damage)
			end
		end
		if (event == sgs.CardsMoveOneTime) then
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName() 
			and move.from_places:contains(sgs.Player_PlaceHand) 
			and move.is_last_handcard then
				local luxun = room:findPlayerBySkillName(self:objectName())
				if luxun and (luxun:getPhase() == sgs.Player_Play) then
				    room:broadcastSkillInvoke(self:objectName())
				end
				room:setPlayerMark(player,"&kehezhubeisp-Clear",1)
			end
		end
		if (event == sgs.Damaged) then
			room:setPlayerMark(player,"&kehezhubeida-Clear",1)
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
keheluxun:addSkill(kehezhubei)

kehezhaoyun = sgs.General(extension, "kehezhaoyun", "shu", 4,true)

kehelonglin = sgs.CreateTriggerSkill{
	name = "kehelonglin",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage,sgs.TargetSpecified,sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data, room)
		if (event == sgs.TargetSpecified) then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") and (use.from:getPhase() == sgs.Player_Play) then
				room:addPlayerMark(use.from,"kehelonglinusetimes-PlayClear",1)
				if (use.from:getMark("kehelonglinusetimes-PlayClear") == 1) then
					for _, zy in sgs.qlist(room:getOtherPlayers(use.from)) do
						if zy:isYourFriend(use.to:at(0)) then room:setPlayerFlag(zy,"wantuselonglin") end
						if zy:hasSkill(self:objectName()) and room:askForDiscard(zy, self:objectName(), 1, 1, true,true,"kehezhendan-ask") then
							room:broadcastSkillInvoke(self:objectName())
							local nullified_list = use.nullified_list
							table.insert(nullified_list, "_ALL_TARGETS")
							use.nullified_list = nullified_list
							data:setValue(use)
							local _data = sgs.QVariant()
							_data:setValue(zy)
							if (not use.from:isYourFriend(zy)) 
							and ((use.from:getHp()*2 + use.from:getHujia()*2 + use.from:getHandcardNum()) >= (zy:getHp()*2 + zy:getHujia()*2 + zy:getHandcardNum())) then
								room:setPlayerFlag(use.from,"wantuselonglinjuedou")
							end
							if room:askForSkillInvoke(use.from, "kehelonglinjuedou", _data) then
								room:setPlayerMark(zy,"kehelonglinzy",1)
								local juedou = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
								juedou:setSkillName("kehelonglinjuedou")
								local card_use = sgs.CardUseStruct()
								card_use.from = use.from
								card_use.to:append(zy)
								card_use.card = juedou
								room:useCard(card_use, false)    
								juedou:deleteLater() 
								room:setPlayerMark(zy,"kehelonglinzy",0)
							end
							room:setPlayerFlag(use.from,"-wantuselonglinjuedou")
						end
						room:setPlayerFlag(zy,"-wantuselonglin")
					end
				end
			end
		end
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			if damage.card 
			and (damage.card:getSkillName() == "kehelonglinjuedou")
			and (damage.from:getMark("kehelonglinzy") > 0) then
				room:setPlayerMark(damage.to,"&kehelonglin-Clear",1)
				room:setPlayerCardLimitation(damage.to, "use,response", ".|.|.|hand", false)
			end
		end
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.from == sgs.Player_Play) then
				if (player:getMark("&kehelonglin-Clear") > 0) then
					room:setPlayerMark(player,"&kehelonglin-Clear",0)
					room:removePlayerCardLimitation(player, "use,response", ".|.|.|hand")
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end
}
kehezhaoyun:addSkill(kehelonglin)


kehezhendanCard = sgs.CreateSkillCard{
	name = "kehezhendan",
	will_throw = false,
	filter = function(self, targets, to_select)
		local plist = sgs.PlayerList()
		for i = 1, #targets do plist:append(targets[i]) end
		local rangefix = 0
		if not self:getSubcards():isEmpty() and sgs.Self:getWeapon() and sgs.Self:getWeapon():getId() == self:getSubcards():first() then
			local card = sgs.Self:getWeapon():getRealCard():toWeapon()
			rangefix = rangefix + card:getRange() - sgs.Self:getAttackRange(false)
		end
		if not self:getSubcards():isEmpty() and sgs.Self:getOffensiveHorse() and sgs.Self:getOffensiveHorse():getId() == self:getSubcards():first() then
			rangefix = rangefix + 1
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card, user_str = nil, self:getUserString()
			if user_str ~= "" then
				local us = user_str:split("+")
				card = sgs.Sanguosha:cloneCard(us[1])
			end
			return card and card:targetFilter(plist, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, plist)
				and not (card:isKindOf("Slash") and not sgs.Self:canSlash(to_select, true, rangefix))
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return false
		end
		local card = sgs.Self:getTag("kehezhendan"):toCard()
		return card and card:targetFilter(plist, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, plist)
			and not (card:isKindOf("Slash") and not sgs.Self:canSlash(to_select, true, rangefix))
	end,
	target_fixed = function(self)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card, user_str = nil, self:getUserString()
			if user_str ~= "" then
				local us = user_str:split("+")
				card = sgs.Sanguosha:cloneCard(us[1])
			end
			return card and card:targetFixed()
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return true
		end
		local card = sgs.Self:getTag("kehezhendan"):toCard()
		return card and card:targetFixed()
	end,
	feasible = function(self, targets)
		local plist = sgs.PlayerList()
		for i = 1, #targets do plist:append(targets[i]) end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card, user_str = nil, self:getUserString()
			if user_str ~= "" then
				local us = user_str:split("+")
				card = sgs.Sanguosha:cloneCard(us[1])
			end
			return card and card:targetsFeasible(plist, sgs.Self)
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return true
		end
		local card = sgs.Self:getTag("kehezhendan"):toCard()
		return card and card:targetsFeasible(plist, sgs.Self)
	end,
	on_validate = function(self, card_use)
		local player = card_use.from
		local room, to_kehezhendan = player:getRoom(), self:getUserString()
		if self:getUserString() == "slash" and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local kehezhendan_list = {}
			table.insert(kehezhendan_list, "slash")
			table.insert(kehezhendan_list, "fire_slash")
			table.insert(kehezhendan_list, "thunder_slash")
			table.insert(kehezhendan_list, "ice_slash")
			to_kehezhendan = room:askForChoice(player, "kehezhendan_slash", table.concat(kehezhendan_list, "+"))
		end
		local card = nil
		if self:subcardsLength() == 1 then card = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(self:getSubcards():first())) end
		local user_str
		if to_kehezhendan == "slash" then
			if card and card:objectName() == "slash" then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		else
			user_str = to_kehezhendan
		end
		local use_card = sgs.Sanguosha:cloneCard(user_str, card and card:getSuit() or sgs.Card_SuitToBeDecided, card and card:getNumber() or -1)
		use_card:setSkillName("_kehezhendan")
		use_card:addSubcards(self:getSubcards())
		use_card:deleteLater()
		return use_card
	end,
	on_validate_in_response = function(self, user)
		local room, user_str = user:getRoom(), self:getUserString()
		local to_kehezhendan
		if user_str == "peach+analeptic" then
			local kehezhendan_list = {}
			table.insert(kehezhendan_list, "peach")
			table.insert(kehezhendan_list, "analeptic")
			to_kehezhendan = room:askForChoice(user, "kehezhendan_saveself", table.concat(kehezhendan_list, "+"))
		elseif user_str == "slash" then
			local kehezhendan_list = {}
			table.insert(kehezhendan_list, "slash")
			table.insert(kehezhendan_list, "fire_slash")
			table.insert(kehezhendan_list, "thunder_slash")
			table.insert(kehezhendan_list, "ice_slash")
			to_kehezhendan = room:askForChoice(user, "kehezhendan_slash", table.concat(kehezhendan_list, "+"))
		else
			to_kehezhendan = user_str
		end
		local card = nil
		if self:subcardsLength() == 1 then card = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(self:getSubcards():first())) end
		local user_str
		if to_kehezhendan == "slash" then
			if card and card:objectName() == "slash" then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		else
			user_str = to_kehezhendan
		end
		local use_card = sgs.Sanguosha:cloneCard(user_str, card and card:getSuit() or sgs.Card_SuitToBeDecided, card and card:getNumber() or -1)
		use_card:setSkillName("_kehezhendan")
		use_card:addSubcards(self:getSubcards())
		use_card:deleteLater()
		return use_card
	end,
}
kehezhendanVS = sgs.CreateViewAsSkill{
	name = "kehezhendan",
	n = 1,
	response_or_use = true,
	view_filter = function(self, selected, to_select)
		return (not to_select:isEquipped()) and (not to_select:isKindOf("BasicCard"))
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local skillcard = kehezhendanCard:clone()
		skillcard:setSkillName(self:objectName())
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE
			or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			skillcard:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
			for _, card in ipairs(cards) do
				skillcard:addSubcard(card)
			end
			return skillcard
		end
		local c = sgs.Self:getTag("kehezhendan"):toCard()
		if c then
			skillcard:setUserString(c:objectName())
			for _, card in ipairs(cards) do
				skillcard:addSubcard(card)
			end
			return skillcard
		else
			return nil
		end
	end,
	enabled_at_play = function(self, player)
		local basic = {"slash", "peach"}
		table.insert(basic, "fire_slash")
		table.insert(basic, "thunder_slash")
		table.insert(basic, "ice_slash")
		table.insert(basic, "analeptic")
		for _, patt in ipairs(basic) do
			local poi = sgs.Sanguosha:cloneCard(patt, sgs.Card_NoSuit, -1)
			if poi and poi:isAvailable(player) and not (patt == "peach" and not player:isWounded()) then
				return true
			end
		end
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		if string.startsWith(pattern, ".") or string.startsWith(pattern, "@") then return false end
        if pattern == "peach" and player:getMark("Global_PreventPeach") > 0 then return false end
        return pattern ~= "nullification" and pattern ~= "jl_wuxiesy"
	end,
}


kehezhendan = sgs.CreateTriggerSkill{
	name = "kehezhendan",
	view_as_skill = kehezhendanVS,
	priority = 9,
	events = {sgs.Damaged,sgs.RoundEnd,sgs.EventPhaseChanging,sgs.TurnStart},
	on_trigger = function(self, event, player, data, room)
		if (event == sgs.TurnStart) then
			if player:faceUp() then
			    room:addPlayerMark(player,"kehezhendanhuihe_lun")
			end
		end
		--[[if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if (change.from == sgs.Player_NotActive) then
				room:addPlayerMark(player,"kehezhendanhuihe_lun",1)
			end
		end]]
		if (event == sgs.Damaged) then
			local damage = data:toDamage()
			if damage.to:hasSkill(self:objectName()) and (damage.to:getMark("&kehezhendan_lun") == 0) then
				local num = 0
				for _, p in sgs.qlist(room:getAllPlayers()) do
					num = num + p:getMark("kehezhendanhuihe_lun")
				end
				room:sendCompulsoryTriggerLog(player,self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				damage.to:drawCards(math.min(5,num))
				room:setPlayerMark(damage.to,"&kehezhendan_lun",1)
			end
		end
		if (event == sgs.RoundEnd) then
			if (player:getMark("&kehezhendan_lun") == 0) and player:hasSkill(self:objectName()) then
				local num = 0
				for _, p in sgs.qlist(room:getAllPlayers()) do
					num = num + p:getMark("kehezhendanhuihe_lun")
				end
				room:sendCompulsoryTriggerLog(player,self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				player:drawCards(math.min(5,num))
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end
}
kehezhendan:setGuhuoDialog("l")
kehezhaoyun:addSkill(kehezhendan)

kehecaofang = sgs.General(extension, "kehecaofang$", "wei", 3,true)

kehezhaotuVS = sgs.CreateViewAsSkill{
	name = "kehezhaotu",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isRed() and (not to_select:isKindOf("TrickCard"))
	end,
	view_as = function(self, cards)
		if #cards == 0 then
			return nil
		elseif #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local id = card:getId()
			local indulgence = sgs.Sanguosha:cloneCard("indulgence", suit, point)
			indulgence:addSubcard(id)
			indulgence:setSkillName("kehezhaotu")
			return indulgence
		end
	end,
	enabled_at_play = function(self, player)
		return (player:getMark("kehezhaotuuse_lun") == 0)
	end, 
}

kehezhaotu = sgs.CreateTriggerSkill{
	name = "kehezhaotu",
	view_as_skill = kehezhaotuVS,
	events = {sgs.CardUsed,sgs.EventPhaseStart,sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if (use.card:getSkillName() == "kehezhaotu") then
				room:setPlayerMark(use.from,"kehezhaotuuse_lun",1)
				room:setPlayerMark(use.to:at(0),"&kehezhaotu",1)
			end
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_NotActive) then
				for _, p in sgs.qlist(room:getAllPlayers()) do
					if (p:getMark("&kehezhaotu") > 0) then
						room:setPlayerMark(p,"&kehezhaotu",0)
						room:addMaxCards(p, -2, true)
						p:gainAnExtraTurn()
					end
				end
			end
		end
		if (event == sgs.Death) then
			local death = data:toDeath()
			if death.who:hasSkill(self:objectName()) then
				for _, p in sgs.qlist(room:getAllPlayers()) do 
					if p:getMark("&kehezhaotu") > 0 then
						room:setPlayerMark(p,"&kehezhaotu",0)
					end
				end
			end
		end
	end ,
	can_trigger = function(self, player)
		return player
	end,
}
kehecaofang:addSkill(kehezhaotu)

kehejingjuCard = sgs.CreateSkillCard{
	name = "kehejingjuCard",
	will_throw = false,
	filter = function(self,targets,to_select,from)
		local pattern = self:getUserString()
		local use_card = dummyCard(pattern:split("+")[1])
		use_card:setSkillName("kehejingju")
		if use_card:targetFixed()
		then return false end
		local plist = sgs.PlayerList()
		for _,p in sgs.list(targets)do
			plist:append(p)
		end
		return use_card:targetFilter(plist,to_select,from)
	end,
	feasible = function(self,targets)
		local pattern = self:getUserString()
		local use_card = dummyCard(pattern:split("+")[1])
		return #targets>0 or use_card:targetFixed()
	end,
	on_validate = function(self,use)
		local room = use.from:getRoom()
		local tos = sgs.SPlayerList()
		for _,p in sgs.list(room:getOtherPlayers(use.from))do
			for _,j in sgs.list(p:getJudgingArea())do
				if use.from:containsTrick(j:objectName())
				then continue end
				tos:append(p)
				break
			end
		end
		if tos:isEmpty() then return nil end
		tos = room:askForPlayerChosen(use.from,tos,"kehejingju","kehejingju0:",true,true)
		if not tos then return nil end
		local ids = sgs.IntList()
		for _,j in sgs.list(tos:getJudgingArea())do
			if use.from:containsTrick(j:objectName())
			then ids:append(j:getId()) end
		end
		local id = room:askForCardChosen(use.from,tos,"j","kehejingju",false,sgs.Card_MethodNone,ids)
		if id==1 then return nil end
		room:moveCardTo(sgs.Sanguosha:getCard(id),use.from,sgs.Player_PlaceDelayedTrick)
		local pattern = self:getUserString()
		pattern = room:askForChoice(use.from,"kehejingju",pattern)
		local log = sgs.LogMessage()
		log.type = "#choice"
		log.from = pattern
		log.arg = pattern
		room:sendLog(log)
		local use_card = dummyCard(pattern)
		use_card:setSkillName("_kehejingju")
		return use_card
	end,
	on_validate_in_response = function(self,from)
		local room = from:getRoom()
		local tos = sgs.SPlayerList()
		for _,p in sgs.list(room:getOtherPlayers(from))do
			for _,j in sgs.list(p:getJudgingArea())do
				if from:containsTrick(j:objectName())
				then continue end
				tos:append(p)
				break
			end
		end
		if tos:isEmpty() then return nil end
		tos = room:askForPlayerChosen(from,tos,"kehejingju","kehejingju0:",true,true)
		if not tos then return nil end
		local ids = sgs.IntList()
		for _,j in sgs.list(tos:getJudgingArea())do
			if from:containsTrick(j:objectName())
			then ids:append(j:getId()) end
		end
		local id = room:askForCardChosen(from,tos,"j","kehejingju",false,sgs.Card_MethodNone,ids)
		if id==1 then return nil end
		room:moveCardTo(sgs.Sanguosha:getCard(id),from,sgs.Player_PlaceDelayedTrick)
		local pattern = self:getUserString()
		pattern = room:askForChoice(from,"kehejingju",pattern)
		local use_card = dummyCard(pattern)
		use_card:setSkillName("_kehejingju")
		return use_card
	end
}
kehejingju = sgs.CreateViewAsSkill{
	name = "kehejingju",
	guhuo_type = "l",
	view_as = function(self,cards)
		local new_card = kehejingjuCard:clone()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern==""
		then
			pattern = sgs.Self:getTag("kehejingju"):toCard():objectName()
		end
		new_card:setUserString(pattern)
		return new_card
	end,
	enabled_at_response = function(self,player,pattern)
		if sgs.Sanguosha:getCurrentCardUseReason()~=sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
		then return false end
		local can = false
		for _,p in sgs.list(pattern:split("+"))do
			local dc = dummyCard(p)
			if dc and dc:getTypeId()==1
			then
				dc:setSkillName("kehejingju")
				if not player:isLocked(dc)
				then can = true break end
			end
		end
		if can==false then return false end
		for _,p in sgs.list(player:getAliveSiblings())do
			for _,j in sgs.list(p:getJudgingArea())do
				if player:containsTrick(j:objectName())
				then continue end
				return true
			end
		end
	end,
	enabled_at_play = function(self,player)
		local can = false
		for _,p in sgs.list(patterns)do
			local dc = dummyCard(p)
			if dc and dc:getTypeId()==1
			then
				dc:setSkillName("kehejingju")
				if not player:isLocked(dc)
				then can = true break end
			end
		end
		if can==false then return false end
		for _,p in sgs.list(player:getAliveSiblings())do
			for _,j in sgs.list(p:getJudgingArea())do
				if player:containsTrick(j:objectName())
				then continue end
				return true
			end
		end
		return false
	end,
}
kehecaofang:addSkill(kehejingju)

keheweizhui = sgs.CreateTriggerSkill{
	name = "keheweizhui$",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data, room)
		if (event == sgs.EventPhaseStart)
		and (player:getPhase() == sgs.Player_Finish) and (player:getKingdom() == "wei") and (not player:isNude()) then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if p:hasLordSkill(self:objectName()) and p:canDiscard(p, "hej") then
					if (not player:isYourFriend(p)) or (player:isYourFriend(p) and (p:getCards("j"):length() > 0)) then room:setPlayerFlag(player,"wantuseweizhui") end
					local todis = room:askForExchange(player, "keheweizhui", 1, 1, false, "keheweizhuiask:"..p:objectName(),true,".|black|.|hand")
					room:setPlayerFlag(player,"-wantuseweizhui")
					if todis and (todis:getSubcards():length() > 0) then
						local card = sgs.Sanguosha:getCard(todis:getSubcards():first())
						local ghcq = sgs.Sanguosha:cloneCard("dismantlement", card:getSuit(), card:getNumber())
						ghcq:setSkillName("keheweizhui") 
						ghcq:addSubcard(card)
						room:useCard(sgs.CardUseStruct(ghcq, player, p))
					end
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end
}
kehecaofang:addSkill(keheweizhui)

kehesunjun = sgs.General(extension, "kehesunjun", "wu", 4,true)

keheyaoyan = sgs.CreateTriggerSkill{
	name = "keheyaoyan",
	events = {sgs.EventPhaseStart} ,
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Start) then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					room:setPlayerMark(player,"willyaoyanyishi-Clear",1)
					room:broadcastSkillInvoke(self:objectName())
					for _, p in sgs.qlist(room:getAllPlayers()) do
						local result = room:askForChoice(p,"keheyaoyan","join+notjoin")
						if result == "join" then	
							room:setPlayerMark(p,"&keheyaoyanjoin-Clear",1)
						else
							room:setPlayerMark(p,"&keheyaoyannotjoin-Clear",1)
						end
					end
				end
			end
			if (player:getPhase() == sgs.Player_Finish) and (player:getMark("willyaoyanyishi-Clear") > 0 ) then
				room:setPlayerMark(player,"willyaoyanyishi-Clear",0)
				local yaoyanplayers = sgs.SPlayerList()
				local notjoins = sgs.SPlayerList()
				for _,pp in sgs.qlist(room:getAllPlayers()) do
					if ((pp:getMark("&keheyaoyanjoin-Clear") > 0) and not pp:isKongcheng() )then
						yaoyanplayers:append(pp)
					elseif ((pp:getMark("&keheyaoyanjoin-Clear") == 0) or pp:isKongcheng()) then
						notjoins:append(pp)
					end
				end
				room:broadcastSkillInvoke(self:objectName())
				for _,p in sgs.qlist(yaoyanplayers) do
					room:setPlayerMark(p,"keyishiing",1)
					--每个人提前挑选牌准备展示
					if not p:isKongcheng() then
						local id = room:askForExchange(p, "keheyaoyan", 1, 1, false, "keqichaozheng_yishi"):getSubcards():first()
						local card = sgs.Sanguosha:getCard(id)
						room:setCardFlag(card,"useforyishi")
						if card:isRed() then
							room:setPlayerMark(p,"keyishi_red",1)
						elseif card:isBlack() then
							room:setPlayerMark(p,"keyishi_black",1)
						end
						--标记选择了牌的人（没有空城的人）
						room:setPlayerMark(p,"chooseyishi",1)
					end
				end
				--依次展示选好的牌，公平公正公开
				local sj = room:findPlayerBySkillName("kehebazheng")
				if sj then
					for _,bz in sgs.qlist(room:getAllPlayers()) do
						if (bz:getMark("&kehebazheng-Clear") > 0) then
							if (sj:getMark("keyishi_red") > 0) and (bz:getMark("keyishi_black") > 0) then
								room:setPlayerMark(bz,"keyishi_black",0)
								room:setPlayerMark(bz,"keyishi_red",1)
								local log = sgs.LogMessage()
								log.type = "$kehebazhengredlog"
								log.from = bz
								log.to:append(sj)
								room:sendLog(log)
							elseif (sj:getMark("keyishi_black") > 0) and (bz:getMark("keyishi_red") > 0) then
								room:setPlayerMark(bz,"keyishi_black",1)
								room:setPlayerMark(bz,"keyishi_red",0)
								local log = sgs.LogMessage()
								log.type = "$kehebazhengblacklog"
								log.from = bz
								log.to:append(sj)
								room:sendLog(log)
							end
						end
					end
				end
				room:getThread():delay(800)
				local yishirednum = 0
				local yishiblacknum = 0
				for _,p in sgs.qlist(room:getAllPlayers()) do
					if (p:getMark("keyishi_black") > 0) then yishiblacknum = yishiblacknum + 1 end
					if (p:getMark("keyishi_red") > 0) then yishirednum = yishirednum + 1 end
					for _,c in sgs.qlist(p:getCards("h")) do
						if c:hasFlag("useforyishi") then
							--if c:isRed() then yishirednum = yishirednum + 1 end
							--if c:isBlack() then yishiblacknum = yishiblacknum + 1 end
							room:showCard(p,c:getEffectiveId())
							room:setCardFlag(c,"-useforyishi")
							break
						end
					end
				end
				room:getThread():delay(1200)
				--0为平局（默认），1：红色；2：黑色
				local yishiresult = 0
				if (yishirednum > yishiblacknum) then
					yishiresult = 1
					local log = sgs.LogMessage()
					log.type = "$keyishired"
					log.from = player
					room:sendLog(log)	
					room:doLightbox("$keyishired")
				elseif (yishirednum < yishiblacknum) then
					yishiresult = 2
					local log = sgs.LogMessage()
					log.type = "$keyishiblack"
					log.from = player
					room:sendLog(log)	
					room:doLightbox("$keyishiblack")
				elseif (yishirednum == yishiblacknum) then
					yishiresult = 0
					local log = sgs.LogMessage()
					log.type = "$keyishipingju"
					log.from = player
					room:sendLog(log)	
					room:doLightbox("$keyishipingju")
				end
				--效果：
				if (yishiresult == 1) then
					local daomeidan = room:askForPlayersChosen(player, notjoins, self:objectName(), 0, 99, "keheyaoyanget-ask", false, true)
					for _,dmd in sgs.qlist(daomeidan) do
						if not dmd:isKongcheng() then
							local card_id = room:askForCardChosen(player, dmd, "h", self:objectName())
							local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
							room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
						end
					end
				elseif (yishiresult == 2) then
					local eny = room:askForPlayerChosen(player, yaoyanplayers, self:objectName(), "keheyaoyandamage-ask", true, true)
					if eny then
						room:damage(sgs.DamageStruct(self:objectName(), player, eny, 2))
					end	
				end
				--开始清理标记
				for _,p in sgs.qlist(room:getAllPlayers()) do
					if (p:getMark("keyishiing")>0) then room:setPlayerMark(p,"keyishiing",0) end
					if (p:getMark("chooseyishi")>0) then room:setPlayerMark(p,"chooseyishi",0) end
				end
				for _,p in sgs.qlist(room:getAllPlayers()) do
					if (p:getMark("keyishi_red")>0) then room:setPlayerMark(p,"keyishi_red",0) end
					if (p:getMark("keyishi_black")>0) then room:setPlayerMark(p,"keyishi_black",0) end
				end
				--清除ai
				for _,p in sgs.qlist(room:getAllPlayers()) do
					--[[for _,c in sgs.qlist(p:getCards("h")) do
						room:setCardFlag(c,"-chaozhengred")
						room:setCardFlag(c,"-chaozhengblack")
					end	]]
				end
			end
		end
	end	
}
kehesunjun:addSkill(keheyaoyan)

kehebazheng = sgs.CreateTriggerSkill{
	name = "kehebazheng",
	events = {sgs.Damage},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Damage) then
			local damage = data:toDamage()
			if damage.from:hasSkill(self:objectName()) 
			and (damage.from:objectName() ~= damage.to:objectName()) then
				room:broadcastSkillInvoke(self:objectName())
				room:setPlayerMark(damage.to,"&kehebazheng-Clear",1)
			end
		end
	end	
}
kehesunjun:addSkill(kehebazheng)

keheguoxun = sgs.General(extension, "keheguoxun", "wei", 4,true)

kehexumouuse = sgs.CreateZeroCardViewAsSkill{
	name = "kehexumouuse",
	response_pattern = "@@kehexumouuse",
	enabled_at_play = function(self, player)
		return false
	end ,
	view_as = function()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if (pattern == "@@kehexumouuse") then
			local id = sgs.Self:getMark("kehexumouuse-PlayClear") - 1
			if id < 0 then return nil end
			local card = sgs.Sanguosha:getEngineCard(id)
			return card
		end
	end
}
if not sgs.Sanguosha:getSkill("kehexumouuse") then skills:append(kehexumouuse) end

keheeqianjl = sgs.CreateDistanceSkill{
	name = "keheeqianjl",
	correct_func = function(self, from, to)
		if (from:getMark("keheeqianfrom-Clear")>0)
		and (to:getMark("keheeqianto-Clear")) then
			return 2*(to:getMark("keheeqianto-Clear"))
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("keheeqianjl") then skills:append(keheeqianjl) end

keheeqian = sgs.CreateTriggerSkill{
	name = "keheeqian",
	view_as_skill = kehexumouuse,
	global = true,
	priority = 10,
	events = {sgs.EventPhaseStart,sgs.TargetSpecified,sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if use.from and use.card:hasFlag("xumoucard") then
				room:setPlayerMark(use.from,use.card:objectName().."+-Clear",1)
			end
		end
		if (event == sgs.TargetSpecified) and player:hasSkill(self:objectName()) then
			local use = data:toCardUse()
			if (use.card:isKindOf("Slash") or use.card:hasFlag("xumoucard"))
			and (use.to:length() == 1) and (use.to:at(0):objectName() ~= player:objectName()) then
				local to_data = sgs.QVariant()
				to_data:setValue(use.to:at(0))
				if room:askForSkillInvoke(player,self:objectName(), to_data) then
					room:broadcastSkillInvoke(self:objectName())
					local eny = use.to:at(0)
					if use.m_addHistory then
						room:addPlayerHistory(player, use.card:getClassName(),-1)
					end
					if not eny:isNude() then
						local card_id = room:askForCardChosen(player, eny, "he", self:objectName())
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
						room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
					end
					local result = room:askForChoice(eny,self:objectName(),"add+cancel")
					if result == "add" then 
						room:addPlayerMark(eny,"keheeqianto-Clear",1)
						room:addPlayerMark(eny,"&keheeqian-Clear",1)
						room:setPlayerMark(player,"keheeqianfrom-Clear",1)
					end
				end
			end
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Finish) and player:hasSkill(self:objectName()) then
				local goon = 0
				if not (player:containsTrick("_kezhuanxumou_card_one") and player:containsTrick("_kezhuanxumou_card_two") and
				player:containsTrick("_kezhuanxumou_card_three") and player:containsTrick("_kezhuanxumou_card_four") and
				player:containsTrick("_kezhuanxumou_card_five")) then goon = 1 end
				while (goon == 1) do
					local todis = room:askForExchange(player, self:objectName(), 1, 1, false, "keheeqian-ask",true)
					if todis and (todis:getSubcards():length() > 0) then
						if not player:containsTrick("_kezhuanxumou_card_one") then 
							local xmcard = sgs.Sanguosha:getCard(todis:getSubcards():first())
							local xumoupai = sgs.Sanguosha:cloneCard("_kezhuanxumou_card_one", xmcard:getSuit(), xmcard:getNumber())
							xumoupai:setSkillName("keheeqian") 
							xumoupai:addSubcard(xmcard)
							room:useCard(sgs.CardUseStruct(xumoupai, player, player))
						elseif not player:containsTrick("_kezhuanxumou_card_two") then 
							local xmcard = sgs.Sanguosha:getCard(todis:getSubcards():first())
							local xumoupai = sgs.Sanguosha:cloneCard("_kezhuanxumou_card_two", xmcard:getSuit(), xmcard:getNumber())
							xumoupai:setSkillName("keheeqian") 
							xumoupai:addSubcard(xmcard)
							room:useCard(sgs.CardUseStruct(xumoupai, player, player))
						elseif not player:containsTrick("_kezhuanxumou_card_three") then 
							local xmcard = sgs.Sanguosha:getCard(todis:getSubcards():first())
							local xumoupai = sgs.Sanguosha:cloneCard("_kezhuanxumou_card_three", xmcard:getSuit(), xmcard:getNumber())
							xumoupai:setSkillName("keheeqian") 
							xumoupai:addSubcard(xmcard)
							room:useCard(sgs.CardUseStruct(xumoupai, player, player))
						elseif not player:containsTrick("_kezhuanxumou_card_four") then 
							local xmcard = sgs.Sanguosha:getCard(todis:getSubcards():first())
							local xumoupai = sgs.Sanguosha:cloneCard("_kezhuanxumou_card_four", xmcard:getSuit(), xmcard:getNumber())
							xumoupai:setSkillName("keheeqian") 
							xumoupai:addSubcard(xmcard)
							room:useCard(sgs.CardUseStruct(xumoupai, player, player))
						elseif not player:containsTrick("_kezhuanxumou_card_five") then 
							local xmcard = sgs.Sanguosha:getCard(todis:getSubcards():first())
							local xumoupai = sgs.Sanguosha:cloneCard("_kezhuanxumou_card_five", xmcard:getSuit(), xmcard:getNumber())
							xumoupai:setSkillName("keheeqian") 
							xumoupai:addSubcard(xmcard)
							room:useCard(sgs.CardUseStruct(xumoupai, player, player))
						end
					else
						goon = 0
					end
					if (player:containsTrick("_kezhuanxumou_card_one") and player:containsTrick("_kezhuanxumou_card_two") and
					player:containsTrick("_kezhuanxumou_card_three") and player:containsTrick("_kezhuanxumou_card_four") and
					player:containsTrick("_kezhuanxumou_card_five")) then goon = 0 end
				end
			end
			if (player:getPhase() == sgs.Player_Judge) then
				if player:containsTrick("_kezhuanxumou_card_one") or player:containsTrick("_kezhuanxumou_card_two") or
				player:containsTrick("_kezhuanxumou_card_three") or player:containsTrick("_kezhuanxumou_card_four") or
				player:containsTrick("_kezhuanxumou_card_five") then
					local havepai = 1
					while (havepai == 1) do
						room:setPlayerFlag(player,"-restartxumouuse")
						for _, c in sgs.qlist(player:getCards("j")) do 
							if (c:objectName() == "_kezhuanxumou_card_five") and (not player:hasFlag("restartxumouuse")) then
								--local id = c:getSubcards():first()
								local id = c:getEffectiveId()
								local move = sgs.CardsMoveStruct(id, player, sgs.Player_PlaceHand, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,player:objectName(),self:objectName(),""))
								room:moveCardsAtomic(move,false)
								room:setCardTip(id, self:objectName())
								room:setPlayerMark(player, "kehexumouuse-PlayClear", id + 1)
								if (player:getMark(sgs.Sanguosha:getCard(id):objectName().."+-Clear") > 0) or (not sgs.Sanguosha:getCard(id):isAvailable(player)) or not room:askForUseCard(player, "@@kehexumouuse", "kehexumouuse-ask:"..c:objectName(),-1,sgs.Card_MethodUse, false, player, nil, "xumoucard") then
									local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
									local allxmp = sgs.IntList()
									allxmp:append(c:getId())
									for _, xm in sgs.qlist(player:getCards("j")) do 
										if (xm:objectName() == "_kezhuanxumou_card_two") 
										or (xm:objectName() == "_kezhuanxumou_card_three") 
										or (xm:objectName() == "_kezhuanxumou_card_one") 
										or (xm:objectName() == "_kezhuanxumou_card_four") 
										then
											allxmp:append(xm:getId())
										end
									end
									dummy:addSubcards(kehegetCardList(allxmp))
									room:throwCard(dummy, reason, nil)
									dummy:deleteLater()
								end
								room:setPlayerMark(player,"kehexumouuse-PlayClear",0)
							end
						end
						for _, c in sgs.qlist(player:getCards("j")) do 
							if (c:objectName() == "_kezhuanxumou_card_four")and (not player:hasFlag("restartxumouuse")) then
								--local id = c:getSubcards():first()
								local id = c:getEffectiveId()
								local move = sgs.CardsMoveStruct(id, player, sgs.Player_PlaceHand, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,player:objectName(),self:objectName(),""))
								room:moveCardsAtomic(move,false)
								room:setCardTip(id, self:objectName())
								room:setPlayerMark(player, "kehexumouuse-PlayClear", id + 1)
								if (player:getMark(sgs.Sanguosha:getCard(id):objectName().."+-Clear") > 0) or (not sgs.Sanguosha:getCard(id):isAvailable(player)) or not room:askForUseCard(player, "@@kehexumouuse", "kehexumouuse-ask:"..c:objectName(),-1,sgs.Card_MethodUse, false, player, nil, "xumoucard") then
									local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
									local allxmp = sgs.IntList()
									allxmp:append(c:getId())
									for _, xm in sgs.qlist(player:getCards("j")) do 
										if (xm:objectName() == "_kezhuanxumou_card_one") 
										or (xm:objectName() == "_kezhuanxumou_card_three") 
										or (xm:objectName() == "_kezhuanxumou_card_two") 
										or (xm:objectName() == "_kezhuanxumou_card_five") then
											allxmp:append(xm:getId())
										end
									end
									dummy:addSubcards(kehegetCardList(allxmp))
									room:throwCard(dummy, reason, nil)
									dummy:deleteLater()
								end
								room:setPlayerMark(player,"kehexumouuse-PlayClear",0)
							end
						end
						for _, c in sgs.qlist(player:getCards("j")) do 
							if (c:objectName() == "_kezhuanxumou_card_three")and (not player:hasFlag("restartxumouuse")) then
								--local id = c:getSubcards():first()
								local id = c:getEffectiveId()
								local move = sgs.CardsMoveStruct(id, player, sgs.Player_PlaceHand, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,player:objectName(),self:objectName(),""))
								room:moveCardsAtomic(move,false)
								room:setCardTip(id, self:objectName())
								room:setPlayerMark(player, "kehexumouuse-PlayClear", id + 1)
								if (player:getMark(sgs.Sanguosha:getCard(id):objectName().."+-Clear") > 0) or (not sgs.Sanguosha:getCard(id):isAvailable(player)) or not room:askForUseCard(player, "@@kehexumouuse", "kehexumouuse-ask:"..c:objectName(),-1,sgs.Card_MethodUse, false, player, nil, "xumoucard") then
									local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
									local allxmp = sgs.IntList()
									allxmp:append(c:getId())
									for _, xm in sgs.qlist(player:getCards("j")) do 
										if (xm:objectName() == "_kezhuanxumou_card_one") 
										or (xm:objectName() == "_kezhuanxumou_card_two") 
										or (xm:objectName() == "_kezhuanxumou_card_four") 
										or (xm:objectName() == "_kezhuanxumou_card_five") then
											allxmp:append(xm:getId())
										end
									end
									dummy:addSubcards(kehegetCardList(allxmp))
									room:throwCard(dummy, reason, nil)
									dummy:deleteLater()
								end
								room:setPlayerMark(player,"kehexumouuse-PlayClear",0)
							end
						end
						for _, c in sgs.qlist(player:getCards("j")) do 
							if (c:objectName() == "_kezhuanxumou_card_two")and (not player:hasFlag("restartxumouuse")) then
								--local id = c:getSubcards():first()
								local id = c:getEffectiveId()
								local move = sgs.CardsMoveStruct(id, player, sgs.Player_PlaceHand, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,player:objectName(),self:objectName(),""))
								room:moveCardsAtomic(move,false)
								room:setCardTip(id, self:objectName())
								room:setPlayerMark(player, "kehexumouuse-PlayClear", id + 1)
								if (player:getMark(sgs.Sanguosha:getCard(id):objectName().."+-Clear") > 0) or (not sgs.Sanguosha:getCard(id):isAvailable(player)) or not room:askForUseCard(player, "@@kehexumouuse", "kehexumouuse-ask:"..c:objectName(),-1,sgs.Card_MethodUse, false, player, nil, "xumoucard") then
									local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
									local allxmp = sgs.IntList()
									allxmp:append(c:getId())
									for _, xm in sgs.qlist(player:getCards("j")) do 
										if (xm:objectName() == "_kezhuanxumou_card_one") 
										or (xm:objectName() == "_kezhuanxumou_card_four") 
										or (xm:objectName() == "_kezhuanxumou_card_three") 
										or (xm:objectName() == "_kezhuanxumou_card_five") then
											allxmp:append(xm:getId())
										end
									end
									dummy:addSubcards(kehegetCardList(allxmp))
									room:throwCard(dummy, reason, nil)
									dummy:deleteLater()
								end
								room:setPlayerMark(player,"kehexumouuse-PlayClear",0)
							end
						end
						for _, c in sgs.qlist(player:getCards("j")) do 
							if (c:objectName() == "_kezhuanxumou_card_one")and (not player:hasFlag("restartxumouuse")) then
								--local id = c:getSubcards():first()
								local id = c:getEffectiveId()
								local move = sgs.CardsMoveStruct(id, player, sgs.Player_PlaceHand, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW,player:objectName(),self:objectName(),""))
								room:moveCardsAtomic(move,false)
								room:setCardTip(id, self:objectName())
								room:setPlayerMark(player, "kehexumouuse-PlayClear", id + 1)
								if (player:getMark(sgs.Sanguosha:getCard(id):objectName().."+-Clear") > 0) or (not sgs.Sanguosha:getCard(id):isAvailable(player)) or not room:askForUseCard(player, "@@kehexumouuse", "kehexumouuse-ask:"..c:objectName(),-1,sgs.Card_MethodUse, false, player, nil, "xumoucard") then
									local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
									local allxmp = sgs.IntList()
									allxmp:append(c:getId())
									for _, xm in sgs.qlist(player:getCards("j")) do 
										if (xm:objectName() == "_kezhuanxumou_card_five") 
										or (xm:objectName() == "_kezhuanxumou_card_two") 
										or (xm:objectName() == "_kezhuanxumou_card_three") 
										or (xm:objectName() == "_kezhuanxumou_card_four")  then
											allxmp:append(xm:getId())
										end
									end
									dummy:addSubcards(kehegetCardList(allxmp))
									room:throwCard(dummy, reason, nil)
									dummy:deleteLater()
								end
								room:setPlayerMark(player,"kehexumouuse-PlayClear",0)
							end
						end
						if player:containsTrick("_kezhuanxumou_card_one") or player:containsTrick("_kezhuanxumou_card_two") or
						player:containsTrick("_kezhuanxumou_card_three") or player:containsTrick("_kezhuanxumou_card_four") or
						player:containsTrick("_kezhuanxumou_card_five") then
							havepai = 1
						else
							havepai = 0
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end
}
keheguoxun:addSkill(keheeqian)

kehefushaCard = sgs.CreateSkillCard{
	name = "kehefushaCard" ,
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (to_select:objectName() ~= sgs.Self:objectName()) 
		and (sgs.Self:inMyAttackRange(to_select))
	end,
	on_use = function(self, room, player, targets)
		local target = targets[1]
		room:removePlayerMark(player,"@kehefusha")
		room:doSuperLightbox("keheguoxun", "kehefusha")
		room:damage(sgs.DamageStruct(self:objectName(), player, target,math.min(player:getAttackRange(),room:getAllPlayers(true):length())))
	end
}

kehefusha = sgs.CreateZeroCardViewAsSkill{
	name = "kehefusha",
	frequency = sgs.Skill_Limited,
	limit_mark = "@kehefusha",
	enabled_at_play = function(self, player)
		local num = 0
		for _, p in sgs.qlist(player:getAliveSiblings()) do
			if player:inMyAttackRange(p) then
				num = num + 1
			end
		end
		if (num == 1) then 
		    return (player:getMark("@kehefusha") > 0)
		end
	end ,
	view_as = function()
		return kehefushaCard:clone()
	end
}
keheguoxun:addSkill(kehefusha)


keheerhu = sgs.General(extension, "keheerhu", "wu", 3,false)

kehedaimou = sgs.CreateTriggerSkill {
	name = "kehedaimou",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetSpecified},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") then
				for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					local oneok = 0
					for _, pp in sgs.qlist(use.to) do
						if (pp:objectName() ~= p:objectName()) then
							oneok = 1
							break
						end
					end
					if (oneok == 1) and (p:getMark("usedaimouone-Clear") == 0) then
						if room:askForSkillInvoke(p, "kehedaimouone", data) then
							room:broadcastSkillInvoke(self:objectName(),math.random(1,2))
							room:setPlayerMark(p,"usedaimouone-Clear",1)
							local todis = room:getNCards(1)
							if not p:containsTrick("_kezhuanxumou_card_one") then 
								local xmcard = sgs.Sanguosha:getCard(todis:first())
								local xumoupai = sgs.Sanguosha:cloneCard("_kezhuanxumou_card_one", xmcard:getSuit(), xmcard:getNumber())
								--xumoupai:setSkillName("kehedaimou") 
								xumoupai:addSubcard(xmcard)
								room:useCard(sgs.CardUseStruct(xumoupai, p, p))
							elseif not p:containsTrick("_kezhuanxumou_card_two") then 
								local xmcard = sgs.Sanguosha:getCard(todis:first())
								local xumoupai = sgs.Sanguosha:cloneCard("_kezhuanxumou_card_two", xmcard:getSuit(), xmcard:getNumber())
								--xumoupai:setSkillName("kehedaimou") 
								xumoupai:addSubcard(xmcard)
								room:useCard(sgs.CardUseStruct(xumoupai, p, p))
							elseif not p:containsTrick("_kezhuanxumou_card_three") then 
								local xmcard = sgs.Sanguosha:getCard(todis:first())
								local xumoupai = sgs.Sanguosha:cloneCard("_kezhuanxumou_card_three", xmcard:getSuit(), xmcard:getNumber())
								--xumoupai:setSkillName("kehedaimou") 
								xumoupai:addSubcard(xmcard)
								room:useCard(sgs.CardUseStruct(xumoupai, p, p))
							elseif not p:containsTrick("_kezhuanxumou_card_four") then 
								local xmcard = sgs.Sanguosha:getCard(todis:first())
								local xumoupai = sgs.Sanguosha:cloneCard("_kezhuanxumou_card_four", xmcard:getSuit(), xmcard:getNumber())
								--xumoupai:setSkillName("kehedaimou") 
								xumoupai:addSubcard(xmcard)
								room:useCard(sgs.CardUseStruct(xumoupai, p, p))
							elseif not p:containsTrick("_kezhuanxumou_card_five") then 
								local xmcard = sgs.Sanguosha:getCard(todis:first())
								local xumoupai = sgs.Sanguosha:cloneCard("_kezhuanxumou_card_five", xmcard:getSuit(), xmcard:getNumber())
								--xumoupai:setSkillName("kehedaimou") 
								xumoupai:addSubcard(xmcard)
								room:useCard(sgs.CardUseStruct(xumoupai, p, p))
							end
							room:setPlayerFlag(p,"restartxumouuse")
						end
					end
					--包含你
					if (use.to:contains(p)) and (p:getMark("usedaimoutwo-Clear") == 0) then
						if p:containsTrick("_kezhuanxumou_card_one") or p:containsTrick("_kezhuanxumou_card_two") or
						p:containsTrick("_kezhuanxumou_card_three") or p:containsTrick("_kezhuanxumou_card_four") or
						p:containsTrick("_kezhuanxumou_card_five") then
							room:broadcastSkillInvoke(self:objectName(),math.random(3,4))
							--if room:askForSkillInvoke(p, "kehedaimoutwo", data) then
								room:setPlayerMark(p,"usedaimoutwo-Clear",1)
								local choices = {}
								--table.insert(choices, "cancel") 
								if p:containsTrick("_kezhuanxumou_card_five") then
									for _, c in sgs.qlist(p:getCards("j")) do 
										if (c:objectName() == "_kezhuanxumou_card_five") then
											table.insert(choices, "keheerhufive="..(sgs.Sanguosha:getEngineCard(c:getId())):objectName()) 
										end
									end
								end
								if p:containsTrick("_kezhuanxumou_card_four") then
									for _, c in sgs.qlist(p:getCards("j")) do 
										if (c:objectName() == "_kezhuanxumou_card_four") then
											table.insert(choices, "keheerhufour="..(sgs.Sanguosha:getEngineCard(c:getId())):objectName()) 
										end
									end
								end
								if p:containsTrick("_kezhuanxumou_card_three") then
									for _, c in sgs.qlist(p:getCards("j")) do 
										if (c:objectName() == "_kezhuanxumou_card_three") then
											table.insert(choices, "keheerhuthree="..(sgs.Sanguosha:getEngineCard(c:getId())):objectName()) 
										end
									end
								end
								if p:containsTrick("_kezhuanxumou_card_two") then
									for _, c in sgs.qlist(p:getCards("j")) do 
										if (c:objectName() == "_kezhuanxumou_card_two") then
											table.insert(choices, "keheerhutwo="..(sgs.Sanguosha:getEngineCard(c:getId())):objectName()) 
										end
									end
								end
								if p:containsTrick("_kezhuanxumou_card_one") then
									for _, c in sgs.qlist(p:getCards("j")) do 
										if (c:objectName() == "_kezhuanxumou_card_one") then
											table.insert(choices, "keheerhuone="..(sgs.Sanguosha:getEngineCard(c:getId())):objectName()) 
										end
									end
								end
								if (#choices > 0) then
									local choice = room:askForChoice(p, self:objectName(), table.concat(choices, "+"))
									if choice:startsWith("keheerhufive") then
										for _, c in sgs.qlist(p:getCards("j")) do 
											if c:objectName() == "_kezhuanxumou_card_five" then
												room:throwCard(c, reason, nil)
												break
											end
										end
									end
									if choice:startsWith("keheerhufour") then
										for _, c in sgs.qlist(p:getCards("j")) do 
											if c:objectName() == "_kezhuanxumou_card_four" then
												room:throwCard(c, reason, nil)
												break
											end
										end
									end
									if choice:startsWith("keheerhuthree") then
										for _, c in sgs.qlist(p:getCards("j")) do 
											if c:objectName() == "_kezhuanxumou_card_three" then
												room:throwCard(c, reason, nil)
												break
											end
										end
									end
									if choice:startsWith("keheerhutwo") then
										for _, c in sgs.qlist(p:getCards("j")) do 
											if c:objectName() == "_kezhuanxumou_card_two" then
												room:throwCard(c, reason, nil)
												break
											end
										end
									end
									if choice:startsWith("keheerhuone") then
										for _, c in sgs.qlist(p:getCards("j")) do 
											if c:objectName() == "_kezhuanxumou_card_one" then
												room:throwCard(c, reason, nil)
												break
											end
										end
									end
								end
							--end
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end
}
keheerhu:addSkill(kehedaimou)

kehefangjie = sgs.CreateTriggerSkill{
	name = "kehefangjie",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_Start) then
				if not (player:containsTrick("_kezhuanxumou_card_one") or player:containsTrick("_kezhuanxumou_card_two") or
				player:containsTrick("_kezhuanxumou_card_three") or player:containsTrick("_kezhuanxumou_card_four") or
				player:containsTrick("_kezhuanxumou_card_five")) then
					room:broadcastSkillInvoke(self:objectName(),math.random(1,2))
					room:recover(player, sgs.RecoverStruct())
					player:drawCards(1)
				else
					if room:askForSkillInvoke(player, "kehefangjiedis", data) then 
						room:broadcastSkillInvoke(self:objectName(),math.random(3,4))
						local yescancel = 0
						while (yescancel == 0) do
							local choices = {}
							if player:containsTrick("_kezhuanxumou_card_five") then
								for _, c in sgs.qlist(player:getCards("j")) do 
									if (c:objectName() == "_kezhuanxumou_card_five") then
										table.insert(choices, "keheerhufive="..(sgs.Sanguosha:getEngineCard(c:getId())):objectName()) 
									end
								end
							end
							if player:containsTrick("_kezhuanxumou_card_four") then
								for _, c in sgs.qlist(player:getCards("j")) do 
									if (c:objectName() == "_kezhuanxumou_card_four") then
										table.insert(choices, "keheerhufour="..(sgs.Sanguosha:getEngineCard(c:getId())):objectName()) 
									end
								end
							end
							if player:containsTrick("_kezhuanxumou_card_three") then
								for _, c in sgs.qlist(player:getCards("j")) do 
									if (c:objectName() == "_kezhuanxumou_card_three") then
										table.insert(choices, "keheerhuthree="..(sgs.Sanguosha:getEngineCard(c:getId())):objectName()) 
									end
								end
							end
							if player:containsTrick("_kezhuanxumou_card_two") then
								for _, c in sgs.qlist(player:getCards("j")) do 
									if (c:objectName() == "_kezhuanxumou_card_two") then
										table.insert(choices, "keheerhutwo="..(sgs.Sanguosha:getEngineCard(c:getId())):objectName())  
									end
								end
							end
							if player:containsTrick("_kezhuanxumou_card_one") then
								for _, c in sgs.qlist(player:getCards("j")) do 
									if (c:objectName() == "_kezhuanxumou_card_one") then
										table.insert(choices, "keheerhuone="..(sgs.Sanguosha:getEngineCard(c:getId())):objectName()) 
									end
								end
							end
							table.insert(choices, "cancel")
							if (#choices > 0) then
								local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
								if (choice == "cancel") then
									yescancel = 1
								end
								if choice:startsWith("keheerhufive") then
									for _, c in sgs.qlist(player:getCards("j")) do 
										if c:objectName() == "_kezhuanxumou_card_five" then
											room:throwCard(c, reason, nil)
											break
										end
									end
								end
								if choice:startsWith("keheerhufour") then
									for _, c in sgs.qlist(player:getCards("j")) do 
										if c:objectName() == "_kezhuanxumou_card_four" then
											room:throwCard(c, reason, nil)
											break
										end
									end
								end
								if choice:startsWith("keheerhuthree") then
									for _, c in sgs.qlist(player:getCards("j")) do 
										if c:objectName() == "_kezhuanxumou_card_three" then
											room:throwCard(c, reason, nil)
											break
										end
									end
								end
								if choice:startsWith("keheerhutwo") then
									for _, c in sgs.qlist(player:getCards("j")) do 
										if c:objectName() == "_kezhuanxumou_card_two" then
											room:throwCard(c, reason, nil)
											break
										end
									end
								end
								if choice:startsWith("keheerhuone") then
									for _, c in sgs.qlist(player:getCards("j")) do 
										if c:objectName() == "_kezhuanxumou_card_one" then
											room:throwCard(c, reason, nil)
											break
										end
									end
								end
							end
						end
						room:handleAcquireDetachSkills(player, "-kehefangjie")
					end
				end
			end
		end
	end,
	--[[can_trigger = function(self, player)
		return player
	end,]]
}
keheerhu:addSkill(kehefangjie)


keheweiwenzhugezhi = sgs.General(extension, "keheweiwenzhugezhi", "wu", 4,true)

kehefuhaiCard = sgs.CreateSkillCard{
	name = "kehefuhaiCard" ,
	target_fixed = true ,
	on_use = function(self, room, player, targets)
		--准备选择牌，记录
		local shows = {}
		local tos = room:getOtherPlayers(player)
		for _, p in sgs.qlist(tos) do
			if p:isKongcheng() then continue end
			shows[p:objectName()] = room:askForExchange(p, "kehefuhai", 1, 1, false, "kehefuhai-ask")
		end
		--依次展示记录的牌
		for _, p in sgs.qlist(tos) do
			if p:isKongcheng() then continue end
			room:showCard(p,shows[p:objectName()]:getEffectiveId())
		end
		--选方向
		tos = sgs.QList2Table(tos)
		if room:askForChoice(player,"kehefuhai","ssz+nsz")=="ssz"
		then tos = sgs.reverse(tos) end
		local c,n
		for i,p in ipairs(tos) do
			c = shows[p:objectName()]
			n = i
			if c then break end
		end
		local a,b,x = c:getNumber(),0,1
		table.remove(tos,n)
		for i,p in ipairs(tos) do
			c = shows[p:objectName()]
			if not c then continue end
			if i==1
			then
				if c:getNumber()>a then b = 1
				elseif c:getNumber()<a then b = -1
				else break end
				x = x+1
			elseif b==1 and c:getNumber()>a
			or b==-1 and c:getNumber()<a
			then x = x+1
			else break end
			a = c:getNumber()
		end
		player:drawCards(x,"kehefuhai")
	end
}
kehefuhai = sgs.CreateViewAsSkill{
	name = "kehefuhai" ,
	view_as = function(self, cards)
		return kehefuhaiCard:clone()
	end ,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#kehefuhaiCard")
	end
}
keheweiwenzhugezhi:addSkill(kehefuhai)



keheguozhao = sgs.General(extension, "keheguozhao", "wei", 3,false)

kehepianchong = sgs.CreateTriggerSkill{
	name = "kehepianchong",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime,sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardsMoveOneTime) then
			local move = data:toMoveOneTime()
			if (move.to_place == sgs.Player_DiscardPile) and player:hasSkill(self:objectName()) then
				for _,card_id in sgs.qlist(move.card_ids) do
					if (sgs.Sanguosha:getCard(card_id)):isRed() then
						--for _, gz in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
							room:addPlayerMark(player,"&kehepianchongred-Clear")
						--end
					elseif (sgs.Sanguosha:getCard(card_id)):isBlack() then
						--for _, gz in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
							room:addPlayerMark(player,"&kehepianchongblack-Clear")
						--end
					end
				end
			end
			if player:hasSkill(self:objectName()) 
			and (
			(move.from and (move.from:objectName() == player:objectName()) 
			and (move.from_places:contains(sgs.Player_PlaceHand) 
			or move.from_places:contains(sgs.Player_PlaceEquip))) 
		    )
			and 
			(not 
			(move.to and (move.to:objectName() == player:objectName() 
			and (move.to_place == sgs.Player_PlaceHand 
			or move.to_place == sgs.Player_PlaceEquip)))) then
			--[[if move.from and (move.from:objectName() == player:objectName())
			and player:hasSkill(self:objectName())
			and (move.from_places:contains(sgs.Player_PlaceHand)
			or move.from_places:contains(sgs.Player_PlaceEquip))
			then]]
				room:setPlayerMark(player,"&kehepianchong-Clear",1)
			end
		end	
		if (event == sgs.EventPhaseStart) and (player:getPhase() == sgs.Player_Finish) then	
			for _, gz in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if (gz:getMark("&kehepianchong-Clear") > 0) and room:askForSkillInvoke(gz, self:objectName(), data) then 
					room:broadcastSkillInvoke(self:objectName())
					local judge = sgs.JudgeStruct()
					judge.pattern = "."
					judge.good = true
					judge.play_animation = true
					judge.who = gz
					judge.reason = self:objectName()
					room:judge(judge)
					if judge.card:isRed() then
						gz:drawCards(math.min(gz:getMark("&kehepianchongred-Clear"),gz:getMaxHp()))
					elseif judge.card:isBlack() then
						gz:drawCards(math.min(gz:getMark("&kehepianchongblack-Clear"),gz:getMaxHp()))
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
keheguozhao:addSkill(kehepianchong)
keheguozhao:addSkill("zunwei")


kehegaoxiang = sgs.General(extension, "kehegaoxiang", "shu", 4,true)

kehechiyingCard = sgs.CreateSkillCard{
	name = "kehechiyingCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return (#targets < 1) 
	end,
	on_use = function(self, room, player, targets)
		local target = targets[1]
		local alldis = sgs.IntList()
		local jbdis = sgs.IntList()
		for _, p in sgs.qlist(room:getOtherPlayers(target)) do 
			if target:inMyAttackRange(p) and (not p:isNude()) and (p:objectName() ~= player:objectName()) then
				local dis = room:askForDiscard(p, "kehechiying", 1, 1, false,true,"kehechiying-ask") 
				if dis then
					alldis:append(dis:getSubcards():first())
				end
			end
		end
		room:getThread():delay(800)
		if (alldis:length() > 0) then
			local jbpnum = 0
			for _, id in sgs.qlist(alldis) do
				if sgs.Sanguosha:getCard(id):isKindOf("BasicCard") then
					jbdis:append(id)
					jbpnum = jbpnum + 1
				end
			end
			if (jbpnum <= target:getHp()) then
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				dummy:addSubcards(kehegetCardList(jbdis))
				target:obtainCard(dummy)
				dummy:deleteLater()
			end
		end
	end
}
--主技能
kehechiying = sgs.CreateViewAsSkill{
	name = "kehechiying",
	n = 0,
	view_as = function(self, cards)
		return kehechiyingCard:clone()
	end,
	enabled_at_play = function(self, player)
		return (not player:hasUsed("#kehechiyingCard")) 
	end, 
}
kehegaoxiang:addSkill(kehechiying)

keheliuyong = sgs.General(extension, "keheliuyong", "shu", 3,true)

kehedanxinVS = sgs.CreateOneCardViewAsSkill{
	name = "kehedanxin", 
	filter_pattern = ".",
	view_as = function(self, card) 
		local acard = sgs.Sanguosha:cloneCard("_kecheng_tuixinzhifu", card:getSuit(), card:getNumber())
		acard:addSubcard(card:getId())
		acard:setSkillName("kehedanxin")
		return acard
	end, 
}

kehedanxin = sgs.CreateTriggerSkill{
	name = "kehedanxin",
	events = {sgs.CardFinished} ,
	view_as_skill = kehedanxinVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardFinished) then
			local use = data:toCardUse()
			room:setPlayerMark(player,"kehedanxinjulifrom-Clear",1)
			if (use.card:getSkillName() == "kehedanxin") then
				for _, p in sgs.qlist(use.to) do 
				    room:setPlayerMark(p,"kehedanxinjuli-Clear",1)
				end
			end
		end
	end,
}
keheliuyong:addSkill(kehedanxin)

kehedanxinex = sgs.CreateDistanceSkill{
	name = "kehedanxinex",
	correct_func = function(self, from,to)
		if (from:getMark("kehedanxinjulifrom-Clear")>0) and (to:getMark("kehedanxinjuli-Clear") > 0) then
			return 1
		else
			return 0
		end
	end,
}
if not sgs.Sanguosha:getSkill("kehedanxinex") then skills:append(kehedanxinex) end

kehefengxiang = sgs.CreateTriggerSkill{
	name = "kehefengxiang",
	events = {sgs.Damaged} ,
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Damaged) then
			local damage = data:toDamage()
			local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "kehefengxiang-ask")
			if target then
				room:broadcastSkillInvoke(self:objectName())
				local log = sgs.LogMessage()
				log.type = "$kehefengxianglog"
				log.from = player
				room:sendLog(log)
				local orinum = player:getCards("e"):length()
				local n1 = player:getHandcardNum()
				local n2 = target:getHandcardNum()
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if p:objectName() ~= player:objectName() and p:objectName() ~= target:objectName() then
						room:doNotify(p, sgs.CommandType.S_COMMAND_EXCHANGE_KNOWN_CARDS, json.encode({player:objectName(), target:objectName()}))
					end
				end
				local exchangeMove = sgs.CardsMoveList()
				local move1 = sgs.CardsMoveStruct(player:getEquipsId(), target, sgs.Player_PlaceEquip, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, player:objectName(), target:objectName(), "kehefengxiang", ""))
				local move2 = sgs.CardsMoveStruct(target:getEquipsId(), player, sgs.Player_PlaceEquip, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, target:objectName(), player:objectName(), "kehefengxiang", ""))
				exchangeMove:append(move1)
				exchangeMove:append(move2)	
				room:moveCardsAtomic(exchangeMove, false)
				local twonum = player:getCards("e"):length()
				if ((orinum - twonum) > 0) then
					player:drawCards(orinum - twonum)
				end
			end
		end
	end,
}
keheliuyong:addSkill(kehefengxiang)


--搬运

kehezhugeliangpre = sgs.General(extension, "kehezhugeliangpre", "shu", 3,true,true)

--[[kehewentianCard = sgs.CreateSkillCard{
	name = "kehewentianCard",
	target_fixed = false,
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select, player)
		local qtargets = sgs.PlayerList()
		for _,p in ipairs(targets) do
			qtargets:append(p)
		end
		local huogong = sgs.Sanguosha:cloneCard("FireAttack")
		return huogong and huogong:targetFilter(qtargets, to_select, player) and not player:isProhibited(to_select, card, qtargets)
		--return (#targets < 1) and (not to_select:isKongcheng())
	end,
	on_use = function(self, room, player, targets)
		--local target = targets[1]
		local qtargets = sgs.SPlayerList()
		for _,p in ipairs(targets) do
			qtargets:append(p)
		end
	    local card_id = room:getNCards(1):first()
		local card = sgs.Sanguosha:getCard(card_id)
		local huogong = sgs.Sanguosha:cloneCard("FireAttack", card:getSuit(), card:getNumber())
		huogong:addSubcard(card)
		huogong:setSkillName("kehewentian")
		local card_use = sgs.CardUseStruct()
		card_use.from = player
		card_use.to = qtargets
		card_use.card = huogong
		room:useCard(card_use, false)
		huogong:deleteLater() 
	end 
}

kehewentianVS = sgs.CreateViewAsSkill{
	name = "kehewentian",
	n = 0,
	view_as = function(self, cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern and (pattern == "nullification") then
			return kehewentianwxCard:clone()
		else
		    return kehewentianCard:clone()
		end
	end,
	enabled_at_play = function(self, player)
		return (player:getMark("&bankehewentian") == 0)
	end, 
    enabled_at_response = function(self,player,pattern)
	   	return ((player:getMark("&bankehewentian") == 0) and (pattern == "nullification")) 
	end,
	enabled_at_nullification = function(self,player)				
		return (player:getMark("&bankehewentian") == 0) 
	end
}

kehewentian = sgs.CreateTriggerSkill{
	name = "kehewentian",
	--frequency = sgs.Skill_NotFrequent,
	view_as_skill = kehewentianVS,
	events = {sgs.CardsMoveOneTime,sgs.EventPhaseStart,sgs.PreCardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) 
		and (player:getMark("usedkehewentian-Clear") == 0)
		and (player:getPhase() ~= sgs.Player_NotActive) then	
			if room:askForSkillInvoke(player,self:objectName(), data) then
				room:setPlayerMark(player,"usedkehewentian-Clear",1)
				local card_ids = room:getNCards(5)
				room:fillAG(card_ids)
				local to_get = sgs.IntList()
				local to_guanxing = sgs.IntList()
				--选牌给人
				local card_id = room:askForAG(player, card_ids, false, "kehewentian")
				card_ids:removeOne(card_id)
				to_get:append(card_id)
				local card = sgs.Sanguosha:getCard(card_id)
				room:takeAG(player, card_id, false)
				local fri = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "kehewentian-ask")
				if fri then
					fri:obtainCard(card)
				end
				room:clearAG()
				--开始观星
				room:askForGuanxing(player,card_ids)
			end
		end
		
	end,
}]]
kehewentianpreVS = sgs.CreateViewAsSkill{
	name = "kehewentianpre",
	view_as = function(self, cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern == "nullification" then
			local use_card = sgs.Sanguosha:cloneCard("nullification")
			use_card:addSubcard(sgs.Self:getMark("kehewentianId"))
			use_card:setSkillName("kehewentian")
			return use_card
		else
			local use_card = sgs.Sanguosha:cloneCard("fire_attack")
			use_card:addSubcard(sgs.Self:getMark("kehewentianId"))
			use_card:setSkillName("kehewentian")
			return use_card
		end
	end,
	enabled_at_play = function(self, player)
		return (player:getMark("&bankehewentian_lun") == 0)
	end, 
    enabled_at_response = function(self,player,pattern)
	   	return ((player:getMark("&bankehewentian_lun") == 0) and (pattern == "nullification")) 
	end,
	enabled_at_nullification = function(self,player)				
		return (player:getMark("&bankehewentian_lun") == 0) 
	end
}
kehewentianpre = sgs.CreateTriggerSkill{
	name = "kehewentianpre",
	view_as_skill = kehewentianpreVS,
	events = {sgs.CardsMoveOneTime,sgs.EventPhaseStart,sgs.PreCardUsed,sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart)
		and (player:getMark("usedkehewentian-Clear") == 0)
		--一般主阶段列举
		and ((player:getPhase() == sgs.Player_Start) 
		or (player:getPhase() == sgs.Player_Judge)
		or (player:getPhase() == sgs.Player_Draw)
		or (player:getPhase() == sgs.Player_Play)
		or (player:getPhase() == sgs.Player_Discard)
		or (player:getPhase() == sgs.Player_Finish)
	    )
		then	
			if (player:getMark("&bankehewentian_lun") == 0) and room:askForSkillInvoke(player,self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName())
				room:setPlayerMark(player,"usedkehewentian-Clear",1)
				local card_ids = room:getNCards(5)
				room:fillAG(card_ids,player)
				--选牌给人
				local duiyounum = 0
				if (player:getState() ~= "online") then
					for _,other in sgs.qlist(room:getOtherPlayers(player)) do
						if (player:isYourFriend(other)) then
							duiyounum = 1 
							break 
						end
					end
				end
				local card_id 
				--电脑且没有队友
				if (player:getState() ~= "online") and (duiyounum == 0) then
					card_id = -1
				else
				    card_id = room:askForAG(player, card_ids, true, "kehewentian","kehewentianchoose-ask")
				end
				if not (card_id == -1) then
					room:takeAG(nil, card_id, false)
					local fri = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "kehewentian-ask",false)
					if fri then
						if (player:getState() == "online") then
							if sgs.Sanguosha:getCard(card_id):isRed() then
								room:setPlayerFlag(fri,"kehewentianred")
							else
								room:setPlayerFlag(fri,"kehewentianblack")
							end
						end
						card_ids:removeOne(card_id)
						fri:obtainCard(sgs.Sanguosha:getCard(card_id))
					end
				end	
				room:clearAG()
				--开始观星
				room:askForGuanxing(player,card_ids)
			end
		end
		if (event == sgs.CardsMoveOneTime)
		then
	     	local move = data:toMoveOneTime()
			if move.to_place==sgs.Player_DrawPile or move.from_places:contains(sgs.Player_DrawPile)
			then room:setPlayerMark(player,"kehewentianId",room:getDrawPile():first()) end
		end
		if (event == sgs.PreCardUsed)
		then
			local use = data:toCardUse()
			if use.card:getSkillName()=="kehewentian"
			then
				if use.card:isKindOf("Nullification") and not use.card:isBlack()
				or use.card:isKindOf("FireAttack") and not use.card:isRed()
				then room:addPlayerMark(player,"&bankehewentian_lun") end
			end
		end
		if (event == sgs.Death) then
			local death = data:toDeath()
			if death.who:hasSkill(self:objectName()) then
				local reason = death.damage
				if not reason then
				    room:broadcastSkillInvoke("kehewentiancaidan")
				else
					local killer = reason.from
					if not killer then
				        room:broadcastSkillInvoke("kehewentiancaidan")
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player and player:hasSkill(self:objectName())
	end,
}
kehezhugeliangpre:addSkill(kehewentianpre)

kehezhugeliangpre:addSkill("kehechushi")

keheyinluepre = sgs.CreateTriggerSkill{
	name = "keheyinluepre",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageInflicted,sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.DamageInflicted) then
			local damage = data:toDamage()    
			if (damage.nature == sgs.DamageStruct_Fire) then
				for _, zgl in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					if (zgl:getMark("&keheyinluemp") == 0) then
						local to_data = sgs.QVariant()
						to_data:setValue(damage.to)
						if zgl:isYourFriend(damage.to) then room:setPlayerFlag(zgl,"wantuseyinlue") end
						local will_use = room:askForSkillInvoke(zgl, self:objectName(), to_data)
						room:setPlayerFlag(zgl,"-wantuseyinlue")
						if will_use then
							room:broadcastSkillInvoke(self:objectName())
							room:setPlayerMark(zgl,"&keheyinluemp",1)
							return true
						end
					end
				end
			elseif (damage.nature == sgs.DamageStruct_Thunder) then
				for _, zgl in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					if (zgl:getMark("&keheyinlueqp") == 0) then
						local to_data = sgs.QVariant()
						to_data:setValue(damage.to)
						if zgl:isYourFriend(damage.to) then room:setPlayerFlag(zgl,"wantuseyinlue") end
						local will_use = room:askForSkillInvoke(zgl, self:objectName(), to_data)
						room:setPlayerFlag(zgl,"-wantuseyinlue")
						if will_use then
							room:broadcastSkillInvoke(self:objectName())
							room:setPlayerMark(zgl,"&keheyinlueqp",1)
							return true
						end
					end
				end
			end
		end
		if (event == sgs.EventPhaseStart) then
			if (player:getPhase() == sgs.Player_NotActive) then
				for _, zgl in sgs.qlist(room:getAllPlayers()) do
					if (zgl:getMark("&keheyinluemp") > 0) then
						room:setPlayerMark(zgl,"&keheyinluemp",0)
						local phases = sgs.PhaseList()
						phases:append(sgs.Player_Draw)
						zgl:play(phases)
					end
					if (zgl:getMark("&keheyinlueqp") > 0) then
						room:setPlayerMark(zgl,"&keheyinlueqp",0)
						local phases = sgs.PhaseList()
						phases:append(sgs.Player_Discard)
						zgl:play(phases)
					end
				end
			end
		end
	end,
	can_trigger = function(self, player)
		return player
	end,
}
kehezhugeliangpre:addSkill(keheyinluepre)

kehecaoshuang = sgs.General(extension, "kehecaoshuang", "wei", 4,true,true)
kehecaoshuang:addSkill("tuogu")
kehecaoshuang:addSkill("shanzhuan")

kehechentai = sgs.General(extension, "kehechentai", "wei", 4,true,true)

kehejiuxian = sgs.CreateViewAsSkill
{
    name = "kehejiuxian",
    n = 999,
    view_filter = function(self, selected, to_select)
        return sgs.Self:getHandcards():contains(to_select)
        and #selected < math.ceil(sgs.Self:getHandcardNum()/2)
    end,
    view_as = function(self, cards)
        if #cards > 0 and #cards == math.ceil(sgs.Self:getHandcardNum()/2) then
            local cc = kehejiuxianCard:clone()
            for _,card in ipairs(cards) do
                cc:addSubcard(card)
            end
            return cc
        end
    end,
    enabled_at_play = function(self, player)
        return not player:hasUsed("#kehejiuxian")
    end,
}

kehejiuxianCard = sgs.CreateSkillCard
{
    name = "kehejiuxian",
    will_throw = false,
    handling_method = sgs.Card_MethodRecast,
    filter = function(self, targets, to_select, player)
        local qtargets = sgs.PlayerList()
        for _,p in ipairs(targets) do
            qtargets:append(p)
        end
    
        local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_SuitToBeDecided, -1)
        duel:setSkillName("kehejiuxian")

        duel:deleteLater()
        return duel and duel:targetFilter(qtargets, to_select, player) and not player:isProhibited(to_select, duel, qtargets)
    end,
    feasible = function(self, targets, player)
        local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_SuitToBeDecided, -1)
        duel:setSkillName("kehejiuxian")
        duel:deleteLater()
        local qtargets = sgs.PlayerList()
        for _,p in ipairs(targets) do
            qtargets:append(p)
        end
        return duel and duel:targetsFeasible(qtargets, player)
    end,
    on_validate = function(self, cardUse)
        local source = cardUse.from
        local room = source:getRoom()

        local skill_log = sgs.LogMessage()
        skill_log.type = "#InvokeSkill"
        skill_log.from = source
        skill_log.arg = self:objectName()
        room:sendLog(skill_log)

        local log = sgs.LogMessage()
        log.from = source
        log.type = "$RecastCard"
        log.card_str = table.concat(sgs.QList2Table(self:getSubcards()), "+")
        room:sendLog(log)

        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECAST, source:objectName(), self:objectName(), "")
        room:moveCardTo(self, nil, nil, sgs.Player_DiscardPile, reason)

        source:drawCards(self:subcardsLength(), "recast")

        local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_SuitToBeDecided, -1)
        duel:setSkillName("_kehejiuxian")
        return duel
    end,
}

kehejiuxian_buff = sgs.CreateTriggerSkill{
    name = "#kehejiuxian_buff",
    events = {sgs.TargetConfirmed, sgs.Damage},
    frequency = sgs.Skill_NotFrequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.TargetConfirmed then
            local use = data:toCardUse()
            if use.card:isKindOf("Duel") and use.card:getSkillName() == "kehejiuxian" then
                local names = {}
                for _,p in sgs.qlist(use.to) do
                    room:setCardFlag(use.card, "kehejiuxian_target_"..p:objectName())
                end
            end
        end
        if event == sgs.Damage then
            local damage = data:toDamage()
            if damage.card and damage.card:hasFlag("kehejiuxian_target_"..damage.to:objectName()) then
                local targets = sgs.SPlayerList()
                for _,p in sgs.qlist(room:getOtherPlayers(damage.to)) do
                    if p:isWounded() and damage.to:inMyAttackRange(p) and p:objectName() ~= player:objectName() then
                        targets:append(p)
                    end
                end
                if not targets:isEmpty() then
                    local target = room:askForPlayerChosen(player, targets, "kehejiuxian", 
                    "@kehejiuxian:"..damage.to:getGeneralName(), true, true)
                    if target then
                        room:broadcastSkillInvoke("kehejiuxian")
                        room:recover(target, sgs.RecoverStruct(player, nil, 1))
                    end
                end
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end,
}

kehechenyong = sgs.CreateTriggerSkill{
    name = "kehechenyong",
    events = {sgs.CardUsed, sgs.CardResponded, sgs.EventPhaseStart},
    frequency = sgs.Skill_Frequent,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event ~= sgs.EventPhaseStart then
            local card = nil
            if event == sgs.CardUsed then
                card = data:toCardUse().card
            elseif event == sgs.CardResponded then
                local respose = data:toCardResponse()
                if respose.m_isUse then
                    card = respose.m_card
                end
            end
            if (not card) or (card:isKindOf("SkillCard")) then return false end
            local types = {"BasicCard", "TrickCard", "EquipCard"}
            for _,cardtype in ipairs(types) do
                if card:isKindOf(cardtype) and player:getMark("kehechenyong_"..cardtype.."-Clear") == 0 then
                    room:setPlayerMark(player, "kehechenyong_"..cardtype.."-Clear", 1)
                    room:addPlayerMark(player, "&kehechenyong-Clear", 1)
                end
            end
        end

        if event == sgs.EventPhaseStart then
            if player:getPhase() ~= sgs.Player_Finish then return false end
            if player:getMark("&kehechenyong-Clear") <= 0 then return false end
            local prompt = string.format("draw:%s:", player:getMark("&kehechenyong-Clear"))
            if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant(prompt)) then
                room:broadcastSkillInvoke(self:objectName())
                player:drawCards(player:getMark("&kehechenyong-Clear"), self:objectName())
            end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName()) and target:getPhase() ~= sgs.Player_NotActive
    end,
}

kehechentai:addSkill(kehejiuxian)
kehechentai:addSkill(kehejiuxian_buff)
kehechentai:addSkill(kehechenyong)
extension:insertRelatedSkills("kehejiuxian", "#kehejiuxian_buff")


kehewenqin = sgs.General(extension, "kehewenqin", "wei", 4,true,true)

keheguangaoex = sgs.CreateTargetModSkill{
    name = "#keheguangaoex",
 	pattern = "Slash",
	extra_target_func = function(self, from)
		local k = 0
		if from:hasSkill("keheguangao") then
		    return 1
		end
	end,
}
kehewenqin:addSkill(keheguangaoex)

keheguangao = sgs.CreateTriggerSkill{
	name = "keheguangao",
	frequency == sgs.Skill_Frequent,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.CardUsed) then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") then
				--别人额外目标
			    for _,p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:hasSkill(self:objectName()) and (not use.to:contains(p)) then
						if not player:isYourFriend(p) then room:setPlayerFlag(player,"wantusekeheguangao") end
						if player:askForSkillInvoke(self,KeToData("keheguangao-ask:"..p:objectName())) then
							room:doAnimate(1, player:objectName(), p:objectName())
							room:broadcastSkillInvoke(self:objectName())
							room:setPlayerFlag(player,"-wantusekeheguangao")
							use.to:append(p)
						end
						room:setPlayerFlag(player,"-wantusekeheguangao")
					end
				end
				--自己用杀摸牌情形
				if (use.from:hasSkill(self:objectName())) then
					if (use.from:getHandcardNum() % 2 == 0) then
						use.from:drawCards(1)
						local fris = room:askForPlayersChosen(use.from, use.to, self:objectName(), 0, 99, "keheguangaominus-ask", true, true)
						if (fris:length() > 0) then
							room:broadcastSkillInvoke(self:objectName())
						end
						local nullified_list = use.nullified_list
						for _,p in sgs.qlist(fris) do
							table.insert(nullified_list, p:objectName())
						end
						use.nullified_list = nullified_list
						data:setValue(use)
					end
				end
				--被杀摸牌情形
				for _,p in sgs.qlist(use.to) do
					if p:hasSkill(self:objectName()) then
						if (p:getHandcardNum() % 2 == 0) then
							p:drawCards(1)
							local fris = room:askForPlayersChosen(p, use.to, self:objectName(), 0, 99, "keheguangaominus-ask", true, true)
							if (fris:length() > 0) then
								room:broadcastSkillInvoke(self:objectName())
							end
							local nullified_list = use.nullified_list
							for _,p in sgs.qlist(fris) do
								table.insert(nullified_list, p:objectName())
							end
							use.nullified_list = nullified_list
							data:setValue(use)
						end
					end
				end
				data:setValue(use)
			end
		end
	end,
	can_trigger = function(self,target)
		return target ~= nil
	end
}
kehewenqin:addSkill(keheguangao)

extension:insertRelatedSkills("keheguangao", "#keheguangaoex")

kehehuiqi = sgs.CreateTriggerSkill{
	name = "kehehuiqi",
	events = {sgs.TargetConfirmed,sgs.EventPhaseChanging},
	frequency = sgs.Skill_Wake,
	waked_skills = "kehexieju",
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				for _,wq in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
					if (wq:getMark("kehehuiqi-Clear") == 3)
					and (wq:getMark("&kehehuiqi-Clear") > 0) and (wq:getMark(self:objectName()) == 0) then
						room:sendCompulsoryTriggerLog(wq,self:objectName())
						room:broadcastSkillInvoke(self:objectName())
						room:doSuperLightbox("kehewenqin", "kehehuiqi")
						room:setPlayerMark(wq, self:objectName(), 1)
						room:changeMaxHpForAwakenSkill(wq, 0)
						room:recover(wq, sgs.RecoverStruct())
						room:acquireSkill(wq, "kehexieju")
					end
				end		
			end
		end
		if (event == sgs.TargetConfirmed) then
			local use = data:toCardUse()
			local wqs = room:findPlayersBySkillName(self:objectName())
			if not use.card:isKindOf("SkillCard") then
				for _,p in sgs.qlist(use.to) do
					if (p:getMark("&kehehuiqi-Clear") == 0) then
						for _,pp in sgs.qlist(wqs) do
						    room:addPlayerMark(pp,"kehehuiqi-Clear",1)
						end
						room:setPlayerMark(p,"&kehehuiqi-Clear",1,wqs)
					end
				end
			end
		end
	end,
	can_trigger = function(self,target)
		return target ~= nil
	end
}
kehewenqin:addSkill(kehehuiqi)

--黑牌当杀（以下）
kehexiejuslash = sgs.CreateViewAsSkill{
	name = "kehexiejuslash" ,
	n = 1 ,
	view_filter = function(self, selected, to_select)
		return #selected == 0 and (not sgs.Self:isJilei(to_select)) and to_select:isBlack()
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then
			return nil
		end
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:setSkillName("_kehexieju")
		slash:addSubcard(cards[1])
		return slash
	end ,
	enabled_at_play = function()
		return false
	end ,
	enabled_at_response = function(self, player, pattern)
		return pattern:startsWith("@@kehexiejuslash")
	end
}
if not sgs.Sanguosha:getSkill("kehexiejuslash") then skills:append(kehexiejuslash) end
--黑牌当杀（以上结束）

kehexiejuCard = sgs.CreateSkillCard{
	name = "kehexiejuCard" ,
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return (to_select:getMark("kehexiejutar-Clear") > 0)
	end,
	on_use = function(self, room, player, targets)
		for _, p in sgs.list(targets) do 
			--依次询问黑牌当杀
			room:askForUseCard(p, "@@kehexiejuslash", "kehexiejuslash-ask") 
		end
	end
}

kehexiejuVS = sgs.CreateZeroCardViewAsSkill{
	name = "kehexieju",
	enabled_at_play = function(self, player)
		return not player:hasUsed("#kehexiejuCard") 
	end ,
	view_as = function()
		return kehexiejuCard:clone()
	end
}

kehexieju = sgs.CreateTriggerSkill{
	name = "kehexieju",
	view_as_skill = kehexiejuVS,
	events = {sgs.TargetConfirmed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.TargetConfirmed) then
			local use = data:toCardUse()
			local wq = room:getCurrent()
			if wq:hasSkill(self:objectName()) and (not use.card:isKindOf("SkillCard")) then
				for _, p in sgs.qlist(use.to) do 
					room:setPlayerMark(p,"kehexiejutar-Clear",1)
				end
			end
		end
	end ,
	can_trigger = function(self,target)
		return target ~= nil
	end
}
if not sgs.Sanguosha:getSkill("kehexieju") then skills:append(kehexieju) end

kehezhangxuan = sgs.General(extension, "kehezhangxuan", "wu", 4,false,true)
kehezhangxuan:addSkill("tongli")
kehezhangxuan:addSkill("shezang")























sgs.Sanguosha:addSkills(skills)
sgs.LoadTranslationTable{
    ["kearjsrgthe"] = "江山如故·合",
	["xumou_card"] = "蓄谋牌",
	["kehexumouuse-ask"] = "你可以使用蓄谋牌【%src】：选择目标 -> 点击确定",
    ["_kezhuanxumou_card_one"] = "蓄谋牌",
	["_kezhuanxumou_card_two"] = "蓄谋牌",
	["_kezhuanxumou_card_three"] = "蓄谋牌",
	["_kezhuanxumou_card_four"] = "蓄谋牌",
	["_kezhuanxumou_card_five"] = "蓄谋牌",

	["_kehe_jiejiaguitian"] = "解甲归田",
	[":_kehe_jiejiaguitian"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名装备区有牌的角色<br /><b>效果</b>：目标角色获得其装备区里的所有牌。",

	--郭循
	["keheguoxun"] = "郭循-合", 
	["&keheguoxun"] = "郭循",
	["#keheguoxun"] = "秉心不回",
	["designer:keheguoxun"] = "官方",
	["cv:keheguoxun"] = "泪何不寐",
	["illustrator:keheguoxun"] = "鬼画府，极乐",

	["keheeqian"] = "遏前",
	["keheeqian:add"] = "令其本回合与你距离+2",
	["keheeqian-ask"] = "你可以发动“遏前”蓄谋任意张牌",
	[":keheeqian"] = "<font color='green'><b>结束阶段，</s></font>你可以蓄谋任意次；当你使用【杀】或蓄谋牌指定其他角色为唯一目标后，你可以令此牌不计入次数并获得其一张牌，然后其可以令你本回合与其距离+2。",

	["kehefusha"] = "伏杀",
	[":kehefusha"] = "限定技，出牌阶段，你可以对攻击范围内的唯一角色造成X点伤害（X为你的攻击范围且至多为总角色数）。",


	["$keheeqian1"] = "勇过聂政，功逾介子。",
	["$keheeqian2"] = "砥节砺行，秉心不回！",
	["$kehefusha1"] = "（咚咚锵）",

	["~keheguoxun"] = "杀身成仁，矢志不移。",


	--二虎
	["keheerhu"] = "孙鲁班＆孙鲁育-合", 
	["&keheerhu"] = "孙鲁班＆孙鲁育",
	["#keheerhu"] = "恶紫夺朱",
	["designer:keheerhu"] = "官方",
	["cv:keheerhu"] = "官方",
	["illustrator:keheerhu"] = "鬼画府，悦君歌",

	["keheerhuone"] = "弃置蓄谋牌【%src】",
	["keheerhutwo"] = "弃置蓄谋牌【%src】",
	["keheerhuthree"] = "弃置蓄谋牌【%src】",
	["keheerhufour"] = "弃置蓄谋牌【%src】",
	["keheerhufive"] = "弃置蓄谋牌【%src】",
	
	["kehedaimou"] = "殆谋",
	[":kehedaimou"] = "<font color='green'><b>每回合各限一次，</s></font>当一名角色使用【杀】指定其他角色/你为目标时，你可以将牌堆顶的牌蓄谋/你弃置你判定区内的一张蓄谋牌。",
	["kehedaimouone"] = "殆谋：将牌堆顶的牌蓄谋",
	["kehedaimoutwo"] = "殆谋",

	["kehefangjie"] = "芳洁",
	["kehefangjiedis"] = "芳洁：弃置任意张蓄谋牌",
	[":kehefangjie"] = "<font color='green'><b>准备阶段，</s></font>若你的判定区内没有蓄谋牌，你回复1点体力并摸一张牌，否则你可以弃置任意张你判定区内的蓄谋牌并失去“芳洁”。",

	["$kehedaimou1"] = "哼，真以为我能饶过你？",
	["$kehedaimou2"] = "哼，定叫你吃不了兜着走！",
	["$kehedaimou3"] = "你疯了，我可是长公主！",
	["$kehedaimou4"] = "姐妹敦睦，家国和睦。",
	["$kehefangjie1"] = "素性贞淑，穆穆春山。",
	["$kehefangjie2"] = "贵胄之身，岂能轻折",
	["$kehefangjie3"] = "慕清兴荣，太平祥和。",
	["$kehefangjie4"] = "雍穆融治，吾之所愿。",
	["~keheerhu"] = "姐姐，你太狠心了。/你们居然敢治我的罪！",

	--卫温诸葛直
	["keheweiwenzhugezhi"] = "卫温＆诸葛直-合", 
	["&keheweiwenzhugezhi"] = "卫温＆诸葛直",
	["#keheweiwenzhugezhi"] = "帆至夷州",
	["designer:keheweiwenzhugezhi"] = "官方",
	["cv:keheweiwenzhugezhi"] = "官方",
	["illustrator:keheweiwenzhugezhi"] = "聚一@LEK-D3",

	["kehefuhai"] = "浮海",
	["kehefuhai:nsz"] = "逆时针",
	["kehefuhai:ssz"] = "顺时针",
	[":kehefuhai"] = "出牌阶段限一次，你可以令所有有手牌的其他角色同时展示一张手牌，然后你选择一个方向（顺时针或逆时针）并摸X张牌（X为从你开始该方向上的这些角色展示的牌的点数连续严格递增或严格递减的牌数且至少为1）。",
	
	["$kehefuhai1"] = "苦海茫茫，渡心无边。",
	["$kehefuhai2"] = "此征艰险，万事小心为慎。",
	["~keheweiwenzhugezhi"] = "吾死不足惜，只愿四海升平。",
	
	--郭照
	["keheguozhao"] = "郭照-合", 
	["&keheguozhao"] = "郭照",
	["#keheguozhao"] = "碧海青天",
	["designer:keheguozhao"] = "官方",
	["cv:keheguozhao"] = "官方",
	["illustrator:keheguozhao"] = "杨杨和夏季",

	["kehepianchongred"] = "偏宠红",
	["kehepianchongblack"] = "偏宠黑",
	["kehepianchong"] = "偏宠",

	[":kehepianchong"] = "一名角色的<font color='green'><b>结束阶段，</s></font>若你于此回合内失去过牌，你可以判定，然后你摸X张牌（X为本回合进入弃牌堆的与判定牌颜色相同的牌的数量且至多为你的体力上限）。",
	
	["$kehepianchong1"] = "得陛下怜爱，恩宠不衰",
	["$kehepianchong2"] = "谬蒙圣恩，光授殊宠",
	["~keheguozhao"] = "我的出身，不配为后？",



	--诸葛亮
	["kehezhugeliang"] = "诸葛亮-合", 
	["&kehezhugeliang"] = "诸葛亮",
	["#kehezhugeliang"] = "炎汉忠魂",
	["designer:kehezhugeliang"] = "官方",
	["cv:kehezhugeliang"] = "官方",
	["illustrator:kehezhugeliang"] = "鬼画府",

	["kehezhugeliangpre"] = "诸葛亮-合-初版", 
	["&kehezhugeliangpre"] = "诸葛亮",
	["#kehezhugeliangpre"] = "炎汉忠魂",
	["designer:kehezhugeliangpre"] = "官方",
	["cv:kehezhugeliangpre"] = "官方",
	["illustrator:kehezhugeliangpre"] = "鬼画府",

	["kehewentian"] = "问天",
	["kehewentianpre"] = "问天",
	[":kehewentian"] = "每个回合限一次，你的阶段开始时，你可以观看牌堆顶的X张牌（X为7-你以此法观看过牌的次数且X至少为1）且可以将其中一张交给一名其他角色，然后将其余牌以任意顺序置于牌堆顶或牌堆底；你可以将牌堆顶的牌当【无懈可击】/【火攻】使用，若以此法使用的牌不为黑色/红色，本轮“问天”失效。",
	[":kehewentianpre"] = "每个回合限一次，你的阶段开始时，你可以观看牌堆顶的五张牌，且可以将其中一张交给一名其他角色，然后将其余牌以任意顺序置于牌堆顶或牌堆底；你可以将牌堆顶的牌当【无懈可击】/【火攻】使用，若以此法使用的牌不为黑色/红色，本轮“问天”失效。",

	["kehechushi"] = "出师",
	[":kehechushi"] = "出牌阶段限一次，你可以与主公议事，若结果为：红色，你与其各摸一张牌，若你的手牌数与其手牌数之和小于7，重复此摸牌流程；黑色，你本轮造成的属性伤害+1。",

	["keheyinlue"] = "隐略",
	["keheyinluepre"] = "隐略",
	["keheyinluedisleidian"] = "你可以弃置一张牌发动“隐略”防止 %src 受到的雷电伤害",
	["keheyinluedishuoyan"] = "你可以弃置一张牌发动“隐略”防止 %src 受到的火焰伤害",
	[":keheyinlue"] = "<font color='green'><b>每轮每项限一次，</s></font>当一名角色受到火焰/雷电伤害时，你可以弃置一张牌防止之，然后当前回合结束后，你执行一个仅包含摸牌阶段/弃牌阶段的额外回合。",
	[":keheyinluepre"] = "<font color='green'><b>每轮每项限一次，</s></font>当一名角色受到火焰/雷电伤害时，你可以防止之，然后当前回合结束后，你执行一个仅包含摸牌阶段/弃牌阶段的额外回合。",


	["bankehewentian_lun"] = "问天失效",
	["kehewentianchoose-ask"] = "请选择交给其他角色的牌，或点击确定跳过",
	["kehewentian-ask"] = "请将此牌交给一名其他角色",
	["kehechushi_lun"] = "出师伤害",
	["keheyinluemp"] = "隐略摸牌",
	["keheyinlueqp"] = "隐略弃牌",
	["bankehewentian"] = "问天失效",

	["$kehewentian1"] = "七星北斗，布阵如棋。",
	["$kehewentian2"] = "问天用奇术，洞敌于机先。",
	["$kehewentianpre1"] = "七星北斗，布阵如棋。",
	["$kehewentianpre2"] = "问天用奇术，洞敌于机先。",
	["$kehechushi1"] = "半生韶华付社稷，一枕清梦压星河。",
	["$kehechushi2"] = "繁星四百八十万，颗颗鉴照老臣心。",
	["$keheyinlue1"] = "亮，且以星为子，天为局。",
	["$keheyinlue2"] = "眼底星河进，何日太平归？",
	["$keheyinluepre1"] = "亮，且以星为子，天为局。",
	["$keheyinluepre2"] = "眼底星河进，何日太平归？",
	["~kehezhugeliang"] = "回天有术，奈何难寻破局良方。",
	["~kehezhugeliangpre"] = "回天有术，奈何难寻破局良方。",
	

	
	["$kehexuanfengcisha"] = "此【杀】为刺【杀】",

	--姜维
	["kehejiangwei"] = "姜维-合", 
	["&kehejiangwei"] = "姜维",
	["#kehejiangwei"] = "赤血化龙",
	["designer:kehejiangwei"] = "官方",
	["cv:kehejiangwei"] = "官方",
	["illustrator:kehejiangwei"] = "鬼画府，极乐",

	["kehejinfa"] = "矜伐",
	["kehejinfa-ask"] = "你可以令至多两名角色将手牌摸至其体力上限（至多五张）",
	[":kehejinfa"] = "出牌阶段限一次，你可以展示一张手牌并令所有体力上限不大于你的角色议事，若结果与你展示的牌颜色：相同，你令其中至多两名角色将手牌摸至其体力上限（至多五张）；不同，你从游戏外获得两张【影】，若没有其他角色的意见与你相同，你可以变更势力。",

	["kehefumou"] = "复谋",
	["kehefumoured"] = "复谋红色",
	["kehefumoublack"] = "复谋黑色",
	["kehefumoucpby-ask"] = "你可以将一张【影】当【出其不意】对与你意见不同的角色使用",
	[":kehefumou"] = "魏势力技，当你参与的议事结束后，与你意见不同的角色当前回合不能使用或打出其意见对应颜色的牌，然后你可以将一张【影】当【出其不意】对其中一名角色使用。",
	["$kehefumoured"] = "%to 本回合不能使用或打出红色牌",
	["$kehefumoublack"] = "%to 本回合不能使用或打出黑色牌",

	["kehexuanfeng"] = "选锋",
	[":kehexuanfeng"] = "蜀势力技，你可以将一张【影】当无距离和次数限制的刺【杀】使用。",
	
	["$kehejinfa1"] = "古来圣贤为道而死，道之存焉何惜身入九渊。",
	["$kehejinfa2"] = "炎阳在悬，岂因乌云障日而弃金光于野？",
	["$kehefumou1"] = "我辈沐光而行，不为浮云障目。",
	["$kehefumou2"] = "烛焰灼长剑，待裁万里江山。",
	["$kehexuanfeng1"] = "炎阳将坠，可为者，唯舍生擎天！",
	["$kehexuanfeng2"] = "此生未止，志随先烈之遗风！",
	["~kehejiangwei"] = "这八阵天机，我也难以看破。",

	--曹芳
	["kehecaofang"] = "曹芳-合", 
	["&kehecaofang"] = "曹芳",
	["#kehecaofang"] = "引狼入庙",
	["designer:kehecaofang"] = "官方",
	["cv:kehecaofang"] = "官方",
	["illustrator:kehecaofang"] = "鬼画府，极乐",
	
	["keheweizhuiask"] = "危坠：你可以将一张黑色手牌当【过河拆桥】对 %src 使用",

	["kehezhaotu"] = "诏图",
	[":kehezhaotu"] = "每轮限一次，你可以将一张红色非锦囊牌当【乐不思蜀】使用，当前回合结束后，此牌的目标角色执行一个手牌上限-2的额外回合。",

	["kehejingju"] = "惊惧",
	["kehejingju0"] = "请选择发动“惊惧”移动牌的角色",
	[":kehejingju"] = "你可以将其他角色判定区的一张牌移至你的判定区，视为你使用一张基本牌。",

	["keheweizhui"] = "危坠",
	[":keheweizhui"] = "主公技，其他魏势力角色的结束阶段，其可以将一张黑色手牌当【过河拆桥】对你使用。",

	--赵云
	["kehezhaoyun"] = "赵云-合", 
	["&kehezhaoyun"] = "赵云",
	["#kehezhaoyun"] = "北伐之柱",
	["designer:kehezhaoyun"] = "官方",
	["cv:kehezhaoyun"] = "官方",
	["illustrator:kehezhaoyun"] = "鬼画府",

	["kehelonglin"] = "龙临",
	[":kehelonglin"] = "当其他角色在其出牌阶段首次使用【杀】指定目标后，你可以弃置一张牌令此【杀】无效，然后其可以视为对你使用一张【决斗】，你因此【决斗】造成伤害后，其本阶段不能使用或打出手牌。",
	["kehelonglinjuedou"] = "龙临：视为对其使用一张【决斗】",
	["kehezhendan-ask"] = "你可以发动“龙临”弃置一张牌令此【杀】无效",
	
	["kehezhendan"] = "镇胆",
	["kehezhendanskill"] = "镇胆",
	["kehezhendan_slash"] = "镇胆",
	["kehezhendan_saveself"] = "镇胆",
	[":kehezhendan"] = "你可以将一张非基本手牌当任意基本牌使用或打出；当你受到伤害后或每轮结束时，你摸X张牌且本轮“镇胆”失效（X为本轮所有角色行动过的总回合数且至多为5）。",

	["$kehelonglin1"] = "不图功略盖天地，愿以义勇冠三军！",
	["$kehelonglin2"] = "一腔忠勇匡时难，勇熄狼烟汉祚兴。",

	["$kehezhendan1"] = "银枪所至，千夫不敌！",
	["$kehezhendan2"] = "踏遍天下谁敌手，自杖银枪辨雌雄。",
	["$kehezhendan3"] = "宇内安有无双将，且与子龙试高低！",

	["~kehezhaoyun"] = "北伐大业未定，末将实难心安。",

	--司马懿
	["kehesimayi"] = "司马懿-合", 
	["&kehesimayi"] = "司马懿",
	["#kehesimayi"] = "危崖隐羽",
	["designer:kehesimayi"] = "官方",
	["cv:kehesimayi"] = "官方",
	["illustrator:kehesimayi"] = "鬼画府，极乐",

	["keheyingshi"] = "鹰眎",
	["keheyingshi:keheyingshiuse-ask"] = "你可以发动“鹰眎”观看牌堆底的 %src 张牌。",
	[":keheyingshi"] = "当你翻面时，你可以观看牌堆底的三张牌（若死亡角色数大于2，改为五张），然后将这些牌以任意顺序置于牌堆顶或牌堆底。",
	
	["kehetuigu"] = "蜕骨",
	[":kehetuigu"] = "<font color='green'><b>回合开始时，</s></font>你可以翻面令你本回合手牌上限+X（X为存活角色数的一半，向下取整）且你摸X张牌，然后你视为使用一张【解甲归田】且目标角色不能使用因此牌获得的牌直到其回合结束；每轮结束时，若你本轮没有行动过，你执行一个额外回合；当你失去装备区的牌后，你回复1点体力。",

	["kehetuiguxjgt-ask"] = "请选择使用【解甲归田】的角色",
	["kehetuigu:kehetuiguuse-ask"] = "你可以发动“蜕骨”将武将牌翻面",
	["$kehetuigulog"] = "%from 执行一个额外的回合",

	["$keheyingshi1"] = "善谋者，鹰扬于九天之上！",
	["$keheyingshi2"] = "善瞻者，察微于九地之下。",

	["$kehetuigu1"] = "我本殿上君王客，如何甘为堂下臣？",
	["$kehetuigu2"] = "指点江山五十载，一朝化龙越金銮。",
	["$kehetuigu3"] = "以退为进，俗子焉能度之？",
	["$kehetuigu4"] = "应时而变，当行权宜之计。",

	["~kehesimayi"] = "吾梦贾逵、王凌为祟，甚恶之。",
	
	--孙峻
	["kehesunjun"] = "孙峻-合", 
	["&kehesunjun"] = "孙峻",
	["#kehesunjun"] = "朋党执虎",
	["designer:kehesunjun"] = "官方",
	["cv:kehesunjun"] = "孙綝",
	["illustrator:kehesunjun"] = "鬼画府，极乐",

	["keheyaoyan"] = "邀宴",
	["keheyaoyan:join"] = "本回合结束阶段参与议事",
	["keheyaoyan:notjoin"] = "拒绝参与议事",
	["keheyaoyanget-ask"] = "邀宴：你可以获得任意名未参与本次议事的角色的各一张手牌",
	["keheyaoyandamage-ask"] = "邀宴：你可以对一名参与本次议事的角色造成2点伤害",
	[":keheyaoyan"] = "<font color='green'><b>准备阶段，</s></font>你可以令所有角色选择是否在本回合结束时议事，若如此做，本回合结束时，你令所有选择“是”的角色议事，若结果为：红色，你获得任意名未参与本次议事的角色的各一张手牌；黑色，你可以对一名参与本次议事的角色造成2点伤害。",
	["keheyaoyanjoin"] = "接受邀宴",
	["keheyaoyannotjoin"] = "拒绝邀宴",

	["kehebazheng"] = "霸政",
	[":kehebazheng"] = "锁定技，当你对一名其他角色造成伤害后，直到当前回合结束，若参与议事的角色包含你与该角色，其此次议事的意见视为与你相同。",

	["$kehebazhengredlog"] = "%from 因<font color='yellow'><b> “霸政” </s></font>效果，本次议事的意见视为与 %to 相同",
	["$kehebazhengblacklog"] = "%from 因<font color='yellow'><b> “霸政” </s></font>效果，本次议事的意见视为与 %to 相同",

	["$keheyaoyan1"] = "当今天子乃我所立，他敢怎样？",
	["$keheyaoyan2"] = "我兄弟三人同掌禁军，有何所惧？",
	["$kehebazheng1"] = "以杀立威，谁敢反我？",
	["$kehebazheng2"] = "将这些乱臣贼子尽皆诛之！",

	["~kehesunjun"] = "愿陛下念臣昔日之功，陛下......陛下！",


	--陆逊
	["keheluxun"] = "陆逊-合", 
	["&keheluxun"] = "陆逊",
	["#keheluxun"] = "却敌安疆",
	["designer:keheluxun"] = "官方",
	["cv:keheluxun"] = "官方",
	["illustrator:keheluxun"] = "鬼画府，极乐",

	["keheyoujin"] = "诱进",
	["keheyoujin-ask"] = "你可以发动“诱进”与一名角色拼点",
	
	["keheyoujinnum"] = "诱进点数",
	[":keheyoujin"] = "<font color='green'><b>出牌阶段开始时，</s></font>你可以与一名角色拼点，然后你与其本回合不能使用或打出点数小于本次各自拼点牌的牌，且赢的角色视为对没赢的角色使用一张【杀】。",

	["kehedailao"] = "待劳",
	[":kehedailao"] = "出牌阶段，若你没有可以使用的手牌，你可以展示所有手牌并摸两张牌，然后结束此回合。",
	["$kehedailaolog"] = "%from 结束了此回合",

	["kehezhubei"] = "逐北",
	["kehezhubeisp"] = "逐北失牌",
	["kehezhubeida"] = "逐北伤害",
	[":kehezhubei"] = "锁定技，你对当前回合受到过伤害的角色造成的伤害+1；你对当前回合失去过最后的手牌的角色使用牌无次数限制。",

	["$keheyoujin1"] = "谦恭守分，静待天时。",
	["$keheyoujin2"] = "夫唯不争，故天下莫能与之争。",
	["$kehedailao1"] = "揣度当世时局，以求少劳而多利。",
	["$kehedailao2"] = "静观世事，以待时变。",
	["$kehezhubei1"] = "克荆擒羽，不过举手之劳，有何难哉！",
	["$kehezhubei2"] = "烽火连绵，尽摧敌营。",

	["~keheluxun"] = "祸起萧墙，终及吾身。",

	--高翔
	["kehegaoxiang"] = "高翔-合", 
	["&kehegaoxiang"] = "高翔",
	["#kehegaoxiang"] = "玄乡侯",
	["designer:kehegaoxiang"] = "官方",
	["cv:kehegaoxiang"] = "官方",
	["illustrator:kehegaoxiang"] = "黯荧岛",

	["kehechiying"] = "驰应",
	[":kehechiying"] = "出牌阶段限一次，你可以选择一名角色，该角色攻击范围内的其他角色各弃置一张牌，若其中弃置的基本牌数不大于其体力值，其获得这些基本牌。",

	["$kehechiying1"] = "今诱老贼来此，必折其父子于上方谷。",
	["$kehechiying2"] = "列柳城既失，当下唯死守阳平关。",

	["~kehegaoxiang"] = "老贼不死，实天意也。",

	--刘永
	["keheliuyong"] = "刘永-合", 
	["&keheliuyong"] = "刘永",
	["#keheliuyong"] = "甘陵王",
	["designer:keheliuyong"] = "官方",
	["cv:keheliuyong"] = "官方",
	["illustrator:keheliuyong"] = "君桓文化",

	["kehedanxin"] = "丹心",
	[":kehedanxin"] = "你可以将一张牌当【推心置腹】使用，当你因以此法使用的【推心置腹】获得或给出牌时，你展示这些牌，且得到♥牌的角色回复1点体力，此牌结算完毕后，你本回合与此牌目标角色的距离+1。",

	["kehefengxiang"] = "封乡",
	[":kehefengxiang"] = "锁定技，当你受到伤害后，你与一名其他角色交换装备区的所有牌，然后你摸X张牌（X为你装备区因此减少的牌数且至少为0）。",
	["kehefengxiang-ask"] = "封乡：请选择一名角色与其交换装备区的所有牌",
	
	["$kehedanxin1"] = "吾父之基业，岂能亡于奸宦之手！",
	["$kehedanxin2"] = "纵与吾兄成隙，亦当除此蛀虫！",
	["$kehefengxiang1"] = "百年扶汉积万骨，十载相隙累半生。",
	["$kehefengxiang2"] = "一骑蓝翎魏旨到，王兄大梦可曾闻？",

	["~keheliuyong"] = "刘公嗣，你睁开眼看看这八百里蜀川吧！",

    --陈泰

    ["kehechentai"] = "陈泰-合",
    ["&kehechentai"] = "陈泰",
    ["#kehechentai"] = "断围破蜀",
    ["designer:kehechentai"] = "官方",
	["cv:kehechentai"] = "官方",
	["illustrator:kehechentai"] = "画画的闻玉",

    ["kehejiuxian"] = "救陷",
    [":kehejiuxian"] = "出牌阶段限一次，你可以重铸一半数量的手牌（向上取整），然后视为使用一张【决斗】。此牌对目标角色造成伤害后，你可令其攻击范围内的一名其他角色回复1点体力。",
    ["@kehejiuxian"] = "你可以令 %src 攻击范围内的一名其他角色回复一点体力",
    ["kehechenyong"] = "沉勇",
    [":kehechenyong"] = "结束阶段，你可以摸x张牌。（x为本回合你使用过牌的类型数）",
    ["kehechenyong:draw"] = "你可以发动“沉勇”摸 %src 张牌",

    ["$kehejiuxian1"] = "救袍泽于水火，返清明于天下。",
    ["$kehejiuxian2"] = "与君共扼王旗，焉能见死不救。",
    ["$kehechenyong1"] = "将者，当泰山崩于前而不改色。",
    ["$kehechenyong2"] = "救将陷之城，焉求益兵之助。",

    ["~kehechentai"] = "公非旦，我非勃。",

    ["kehecaoshuang"] = "曹爽-合",
    ["&kehecaoshuang"] = "曹爽",
    ["#kehecaoshuang"] = "骄奢跋扈",
    ["designer:kehecaoshuang"] = "官方",
	["cv:kehecaoshuang"] = "官方",
	["illustrator:kehecaoshuang"] = "画画的闻玉",
	["~kehecaoshuang"] = "悔不该降了司马懿！",

    ["kehezhangxuan"] = "张嫙-合",
    ["&kehezhangxuan"] = "张嫙",
    ["#kehezhangxuan"] = "玉宇嫁蔷",
    ["designer:kehezhangxuan"] = "官方",
	["cv:kehezhangxuan"] = "官方",
	["illustrator:kehezhangxuan"] = "官方",
	["~kehezhangxuan"] = "陛下，臣妾绝无异心",
    
    ["kehewenqin"] = "文钦-合",
    ["&kehewenqin"] = "文钦",
    ["#kehewenqin"] = "困兽鸱张",
    ["designer:kehewenqin"] = "官方",
	["cv:kehewenqin"] = "官方",
	["illustrator:kehewenqin"] = "官方",

	["keheguangao"] = "犷骜",
	[":keheguangao"] = "你使用【杀】的目标数限制+1；其他角色使用【杀】时，其可以令你成为此【杀】的额外目标；当一名角色使用【杀】时，若你是使用者或目标且你的手牌数为偶数，你摸一张牌，然后可以令此【杀】对任意名角色无效。",
    ["keheguangao:keheguangao-ask"] = "你可以发动“犷骜”令 %src 成为此【杀】的额外目标",

	["kehehuiqi"] = "慧企",
	[":kehehuiqi"] = "觉醒技，一个回合结束时，若此回合成为过牌的目标的角色数为3且包括你，你回复1点体力并获得“偕举”。",

	["kehexieju"] = "偕举",
	[":kehexieju"] = "出牌阶段限一次，你可以令任意名本回合成为过牌的目标的角色依次选择是否将一张黑色牌当【杀】使用。",
	["kehexiejuslashCard"] = "偕举",
	["kehexiejuCard"] = "偕举",

	["keheguangaominus-ask"] = "你可以发动“犷骜”令此【杀】对任意名目标角色无效",
	["kehexiejuslash-ask"] = "偕举：你可以将一张黑色牌当【杀】使用",
	
	["$keheguangao1"] = "大丈夫行事，焉能畏首畏尾。",
	["$keheguangao2"] = "策马觅封侯，长驱万里之数。",
	["$kehehuiqi1"] = "今大星西垂，此天降清君侧之证。",
	["$kehehuiqi2"] = "彗星竟于西北，此罚天狼之兆。",
	["$kehexieju1"] = "今举大义，誓与仲恭共死。",
	["$kehexieju2"] = "天降大任，当与志士同忾。",

	["~kehewenqin"] = "天不佑国魏，天不佑族文！",












}
return {extension}

