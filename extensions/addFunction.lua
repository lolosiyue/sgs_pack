sgs.HorseSkill = {}
sgs.shifa_skills = {}
sgs.wangxing_skills = {}
function addToSkills(skill)
	if not sgs.Sanguosha:getSkill(skill:objectName())
	then
		local skills = sgs.SkillList()
		skills:append(skill)
		sgs.Sanguosha:addSkills(skills)
	end
end
function HorseSkills(horse_name)
	return sgs.HorseSkill[horse_name]
end
function DamageRevises(data,n,player)
	local damage = data:toDamage()
	n = math.max(0,damage.damage+n)
	if player
	then
	   	local log = sgs.LogMessage()
		log.type = "$DamageRevises1"
        log.from = player
	   	log.arg = damage.damage
	   	log.arg2 = n
		log.arg3 = "normal_nature"
	   	log.arg4 = "RDamaged"
		if player~=damage.to then log.arg4 = "RDamage" end
		if damage.nature==sgs.DamageStruct_Fire then log.arg3 = "fire_nature"
		elseif damage.nature==sgs.DamageStruct_Thunder then log.arg3 = "thunder_nature"
		elseif damage.nature==sgs.DamageStruct_Ice then log.arg3 = "ice_nature" end
		if n<1 then log.type = "$DamageRevises2" end
	   	player:getRoom():sendLog(log)
	end
	damage.damage = n
	damage.prevented = n<1
	data:setValue(damage)
	return n<1
end
function SCfilter(tring,targets,to_select,self,skill_name)
	if tring~=""
	then
		local plist = sgs.PlayerList()
		for i = 1,#targets do plist:append(targets[i]) end
		for c,name in sgs.list(tring:split("+"))do
			c = dummyCard(name)
			if c
			then
				if self then c:addSubcards(self:getSubcards()) end
				if type(skill_name)=="string" then c:setSkillName(skill_name) end
				return c:targetFilter(plist,to_select,sgs.Self)
				and not sgs.Self:isProhibited(to_select,c,plist)
			end
		end
	end
end
function SCfeasible(tring,targets,self,skill_name)
	if tring~=""
	then
		local plist = sgs.PlayerList()
		for i = 1,#targets do plist:append(targets[i]) end
		for c,name in sgs.list(tring:split("+"))do
			c = dummyCard(name)
			if c
			then
				if self then c:addSubcards(self:getSubcards()) end
				if type(skill_name)=="string" then c:setSkillName(skill_name) end
				return c:targetsFeasible(plist,sgs.Self)
			end
		end
	else
		return #targets>=0
	end
end
function CardIsAvailable(player,name,sn,suit,num)
	local c = sgs.Sanguosha:cloneCard(name)
	if c
	then
    	if sn then c:setSkillName(sn) end
    	if suit then c:setSuit(suit) end
    	if num then c:setNumber(num) end
    	c:deleteLater()
    	if c:isAvailable(player)
    	then return c end
	end
end
function AgCardsToName(player,type_ids,NODT,no_names)
	no_names = no_names or {}
	local tocs,toids = {},sgs.IntList()
	type_ids = type_ids or "basic+trick"
	for c,id in sgs.list(sgs.Sanguosha:getRandomCards())do
    	c = sgs.Sanguosha:getEngineCard(id)
		if NODT and c:isKindOf("DelayedTrick")
		or table.contains(tocs,c:objectName())
		or table.contains(no_names,c:objectName())
		then continue end
	    if c:isAvailable(player)
		and string.find(type_ids,c:getType())
		then
        	table.insert(tocs,c:objectName())
			toids:append(c:getId())
		end
   	end
	if toids:isEmpty() then return end
	local room = player:getRoom()
   	room:fillAG(toids,player)
   	toids = room:askForAG(player,toids,false,"AgCardsToName")
   	room:clearAG(player)
	return sgs.Sanguosha:getCard(toids):objectName()
end
function ShimingSkillDoAnimate(self,player,bool,gn)
	self = type(self)=="string" and self or self:objectName()
	bool = bool and "Successful" or "Fail"
	local msg = sgs.LogMessage()
	msg.type = "#ShimingSkillDoAnimate"
	msg.from = player
	msg.arg = self
	msg.arg2 = bool
	local room = player:getRoom()
	room:broadcastSkillInvoke(self)
	room:sendLog(msg)
	msg = player:getGeneral2()
	if msg and msg:hasSkill(self)
	then gn = gn or player:getGeneral2Name() end
	gn = gn or player:getGeneralName()
	room:doSuperLightbox(gn,bool)
end
function SkillWakeTrigger(self,player,n,gn)
	self = type(self)=="string" and self or self:objectName()
	local room = player:getRoom()
	local log = sgs.LogMessage()
	log.type = "$SkillWakeTrigger"
	log.from = player
	log.arg = self
	room:sendLog(log)
	n = n or -1
	room:sendCompulsoryTriggerLog(player,self)
	room:addPlayerMark(player,self)
	room:broadcastSkillInvoke(self)--播放配音
	log = player:getGeneral2()
	if log and log:hasSkill(self)
	then gn = gn or player:getGeneral2Name() end
	gn = gn or player:getGeneralName()
	room:doSuperLightbox(gn,self)
	room:changeMaxHpForAwakenSkill(player,n)
	player:setTag(self,sgs.QVariant(true))
end
function NotifySkillInvoked(self,player,tos,num)
	local room = player:getRoom()
	self = type(self)=="string" and self or self:objectName()
  	if type(num)=="number" then room:broadcastSkillInvoke(self,num)
	elseif num~=false then room:broadcastSkillInvoke(self) end
	local msg = sgs.LogMessage()
	msg.type = "$NotifySkillInvoked_2"
  	if tos and tos:length()>0
	then
    	msg.type = "$NotifySkillInvoked_1"
		for _,p in sgs.list(tos)do
			msg.to:append(p)
			room:doAnimate(1,player:objectName(),p:objectName())
		end
	end
	msg.from = player
	msg.arg = self
	room:sendLog(msg)
end
function PlayerChosen(self,player,tos,reason,optional)
	local room = player:getRoom()
	self = type(self)=="string" and self or self:objectName()
	tos = tos or room:getAlivePlayers()
	local to_reason = "PlayerChosen0:"..self
	optional = optional or false
	if optional then to_reason = "PlayerChosen1:"..self end
	to_reason = reason or to_reason
	local to = room:askForPlayerChosen(player,tos,self,to_reason,optional)
	local msg = sgs.LogMessage()
	msg.type = "$PlayerChosen"
	msg.from = player
	msg.arg = self
	if to
	then
		msg.to:append(to)
		room:sendLog(msg)
		room:doAnimate(1,player:objectName(),to:objectName())
		return to
	end
end
function hasCard(player,name,he)
	local cs,hes = sgs.CardList(),sgs.CardList()
	he = he or "he"
	if he:match("h")
	then
		hes = player:getHandcards()
	end
	if he:match("e")
	then
		for _,c in sgs.list(player:getEquips())do
			hes:append(c)
		end
	end
	if he:match("j")
	then
		for _,c in sgs.list(player:getJudgingArea())do
			hes:append(c)
		end
	end
	if he:match("&")
	then
		for _,key in sgs.list(player:getPileNames())do
			if key:match("&") or key=="wooden_ox"
			then
				for _,id in sgs.list(player:getPile(key))do
					hes:append(sgs.Sanguosha:getCard(id))
				end
			end
		end
	end
	for _,c in sgs.list(hes)do
		if c:isKindOf(name) or c:objectName()==name
		then cs:append(c) end
	end
	return cs:length()>0 and cs
end
function getKingdoms(player)
	local kingdoms = {player:getKingdom()}
	for _,p in sgs.list(player:getAliveSiblings())do
		if table.contains(kingdoms,p:getKingdom()) then continue end
		table.insert(kingdoms,p:getKingdom())
	end
	return #kingdoms
end
function BfFire(player,to,n,struct)
	local damage = sgs.DamageStruct()
	damage.from = player or nil
	damage.to = to
	damage.damage = n or 1
	damage.nature = struct or sgs.DamageStruct_Fire
	to:getRoom():damage(damage)
end
function UseCardRecast(player,card,reason,n)
	card = type(card)~="number" and card or sgs.Sanguosha:getCard(card)
   	reason = reason or ""
	local r = string.sub(reason,1,1)
	local log = sgs.LogMessage()
	log.type = "$UseCardRecast"
   	log.from = player
  	log.card_str = table.concat(sgs.QList2Table(card:getSubcards()),"+")
	if r=="_"
	or r=="@"
	or r=="#"
	then
		log.type = "$UseCardRecast"..r
		reason = string.sub(reason,2,-1)
	end
	log.arg = reason
	local room = player:getRoom()
	if player:hasSkill(reason) then room:notifySkillInvoked(player,reason) end
	if r~="#" then room:sendLog(log) end
    room:broadcastSkillInvoke("@recast")
	reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECAST,player:objectName(),"","",reason)
   	room:moveCardTo(card,player,nil,sgs.Player_DiscardPile,reason,true)
	n = type(n)=="number" and n or type(n)=="string" and tonumber(n) or 1
	return player:drawCardsList(n,"recast")
end
function RandomList(rl)
	local tolist = {}
   	for _,id in sgs.list(rl)do
    	table.insert(tolist,id)
   	end
	if type(rl)=="table"
	then
    	while #tolist>0 do
        	local x = math.random(1,#tolist)
	    	x = tolist[x]
			table.removeOne(rl,x)
	    	table.insert(rl,x)
			table.removeOne(tolist,x)
    	end
	else
    	while #tolist>0 do
        	local x = math.random(1,#tolist)
	    	x = tolist[x]
	    	rl:removeOne(x)
	    	rl:append(x)
			table.removeOne(tolist,x)
    	end
	end
	return rl
end
function MoveFromPlaceIds(move,places)
	local ids = sgs.IntList()
   	for i,id in sgs.list(move.card_ids)do
    	if move.from_places:at(i)==places
		then ids:append(id) end
   	end
	return ids
end
function MovePlaceIds(room,ids,place)
	local toids = sgs.IntList()
   	for i,id in sgs.list(ids)do
		if room:getCardPlace(id)==place
		then toids:append(id) end
   	end
	return toids
end
function BeMan(room,self,dead)
	dead = dead or false
	self = type(self)=="string" and self or self and self:objectName()
	for _,p in sgs.list(room:getAllPlayers(dead))do
		if p:objectName()==self then return p end
	end
end
function dummyCard(name,suit,number)
	name = name or "slash"
	local c = sgs.Sanguosha:cloneCard(name)
	if c
	then
		if suit then c:setSuit(suit) end
		if number then c:setNumber(number) end
		c:deleteLater()
		return c
	end
end
function ToData(self)
	local data = sgs.QVariant()
	if type(self)=="string" or type(self)=="boolean" or type(self)=="number"
	then data = sgs.QVariant(self) elseif self~=nil then data:setValue(self) end
	return data
end
function ToSkillInvoke(self,player,to,data,n)
	self = type(self)=="string" and self or self:objectName()
	data = data or to and to~=true and ToData(to) or sgs.QVariant()
	local room = player:getRoom()
	local msg = sgs.LogMessage()
	msg.type = "$ToSkillInvoke"
	msg.from = player
	msg.arg = self
	local function Invoke()
		if type(n)=="number" then room:broadcastSkillInvoke(self,n)
		elseif n~=false then room:broadcastSkillInvoke(self) end
	end
	if to==true
	then
		Invoke()
		if player:hasSkill(self) then room:notifySkillInvoked(player,self) end
		room:sendLog(msg)
		return true
	elseif data==true
	and to
	then
		Invoke()
		if player:hasSkill(self) then room:notifySkillInvoked(player,self)
		elseif to:hasSkill(self) then room:notifySkillInvoked(to,self) end
		room:doAnimate(1,player:objectName(),to:objectName())
		msg.type = "$ToSkillInvoke3"
		msg.to:append(to)
		room:sendLog(msg)
		return true
	elseif to
	then
		if player:askForSkillInvoke(self,data,false)
		then
			Invoke()
			if player:hasSkill(self) then room:notifySkillInvoked(player,self)
			elseif to:hasSkill(self) then room:notifySkillInvoked(to,self) end
			room:doAnimate(1,player:objectName(),to:objectName())
			msg.type = "$ToSkillInvoke3"
			msg.to:append(to)
			room:sendLog(msg)
			return true
		end
	elseif player:askForSkillInvoke(self,data)
	then
		Invoke()
--		room:sendLog(msg)
		return true
	end
end
function YijiPreview(self,player,cards,bool,reason)
	local guojia = sgs.SPlayerList()
	local room = player:getRoom()
	guojia:append(player)
	reason = reason or sgs.CardMoveReason_S_REASON_PREVIEW
	self = type(self)=="string" and self or self:objectName()
	local move = sgs.CardsMoveStruct(cards,player,nil,sgs.Player_PlaceHand,sgs.Player_PlaceTable,
	sgs.CardMoveReason(reason,player:objectName(),self,nil))
	if bool
	then
		local slash = dummyCard()
		for i,id in sgs.list(cards)do
			i = room:getCardPlace(id)
			if i~=sgs.Player_PlaceTable
			and i~=sgs.Player_DrawPile
			then slash:addSubcard(id) end
		end
		room:moveCardTo(slash,nil,sgs.Player_PlaceTable)
		move = sgs.CardsMoveStruct(cards,nil,player,sgs.Player_PlaceTable,sgs.Player_PlaceHand,
		sgs.CardMoveReason(reason,player:objectName(),self,nil))
	end
	local moves = sgs.CardsMoveList()
	moves:append(move)
	room:notifyMoveCards(true,moves,false,guojia)
	room:notifyMoveCards(false,moves,false,guojia)
end
function PlayerHandcardNum(player,self,num)
	self = type(self)=="string" and self or self:objectName()
	local room = player:getRoom()
	local n = player:getHandcardNum()
	local msg = sgs.LogMessage()
	msg.type = "$PlayerHandcardNum"
	msg.from = player
	msg.arg = n
	msg.arg2 = num
	room:sendLog(msg)
	if n>num then room:askForDiscard(player,self,n-num,n-num)
	elseif num>n then room:drawCards(player,num-n,self) end
end
function AddSelectShownMark(targets,marks,source) --基于妹神的文字标记制作（膜拜）
    source = source or sgs.Self
	local alive = source:getAliveSiblings()
	alive:append(source)
	for _,p in sgs.list(alive)do
		for _,mark in ipairs(marks)do
	      	p:setMark("&"..mark,0)
		end
	end
	for i = 1,#targets do
    	if marks[i]=="" or marks[i]==nil
		then table.insert(marks,marks[1]) end
    	targets[i]:setMark("&"..marks[i],1)
	end
end
function SetCloneCard(card,name)
   	if name
	then
    	local slash = dummyCard(name)
      	slash:addSubcards(card:getSubcards())
     	for _,f in sgs.list(card:getFlags())do
	    	slash:setFlags(f)
    	end
    	return slash
	elseif card:isVirtualCard()
	then
		local s,n = sgs.Card_NoSuit,0
     	for c,id in sgs.list(card:getSubcards())do
			c = sgs.Sanguosha:getEngineCard(id)
			if card:subcardsLength()>1
			then
				s = c:getColor()
				if sgs.Sanguosha:getEngineCard(card:getSubcards():at(1)):getColor()~=s
				then s = sgs.Card_NoSuit break end
			else
				n = c:getNumber()
				s = c:getSuit()
			end
		end
    	card:setNumber(n)
     	card:setSuit(s)
	end
	return card
end
function Skill_msg(self,player,num)
	local room = player:getRoom()
  	local msg = sgs.LogMessage()
	self = type(self)=="string" and self or self:objectName()
	if player:hasSkill(self) then room:notifySkillInvoked(player,self) end
  	if num and type(num)=="number" then room:broadcastSkillInvoke(self,num) end
	msg.type = "#Skill_msg"
   	msg.from = player
	msg.arg = self
  	room:sendLog(msg)
end
function SkillInvoke(self,player,trigger,n)
	local room = player:getRoom()
	self = type(self)=="string" and self or self:objectName()
	if trigger then room:sendCompulsoryTriggerLog(player,self) end
 	if type(n)=="number" then room:broadcastSkillInvoke(self,n)
	else room:broadcastSkillInvoke(self) end
end
function ArmorNotNullified(target)
	return target:getMark("Armor_Nullified")<1
	and #target:getTag("Qinggang"):toStringList()<1
	and target:getMark("Equips_Nullified_to_Yourself")<1
end

sgs.LoadTranslationTable{
	["$TransferMark"] = "%from 将 %arg2枚 %arg 转移给 %to",
	["$ToSkillInvoke2"] = "%from 发动了 %arg2 的“%arg”",
	["$ToSkillInvoke"] = "%from 发动了“%arg”",
	["$ToSkillInvoke3"] = "%from 对 %to 发动了“%arg”",
	["$DamageRevises1"] = "%from 将%arg4的伤害[%arg3]由 %arg 点变更为 %arg2 点",
	["$DamageRevises2"] = "%from 防止了此次 %arg 点伤害[%arg3]",
	["RDamaged"] = "受到",
	["RDamage"] = "造成",
	["$PlayerHandcardNum"] = "%from 将手牌数从 %arg 张调整为 %arg2 张",
	["$UseCardRecast_"] = "%from 执行了“%arg”的效果，重铸了 %card",
	["$UseCardRecast"] = "%from 重铸了 %card",
	["$UseCardRecast@"] = "%from 发动“%arg”，重铸了 %card",
	["#Skill_msg"] = "%from 的“%arg”效果触发",
	["$SkillWakeTrigger"] = "%from 的 %arg 觉醒条件达成",
	["$PlayerChosen"] = "%from 执行了“%arg”的效果，选择了 %to",
	["PlayerChosen0"] = "%src：请选择一名角色",
	["PlayerChosen1"] = "%src：你可以选择一名角色",
	["#ShimingSkillDoAnimate"] = "%from 的 %arg %arg2",
	["Successful"] = "使命成功",
	["Fail"] = "使命失败",
	["BreakCard"] = "销毁",
	["#PhaseExtra"] = "%from 将执行一个额外的 %arg",
	["$BreakCard"] = "%from 销毁了 %card",
	["$zhengsu0"] = "%from 执行 %arg 的结果为 %arg2",
	["$shifa"] = "%from 选择了“%arg3”的 %arg 回合为 %arg2 ，“%arg3”的效果将于第 %arg2 个回合结束后生效",
	["shifa"] = "施法",
	["$shifa0"] = "%from“%arg”的 %arg2 效果生效",
	["$bf_huangtian0"] = "%to 发动了 %from 的“%arg”",
	["@Equip0lose"] = "武器栏",
	["@Equip1lose"] = "防具栏",
	["@Equip2lose"] = "+马 ",
	["@Equip3lose"] = "-马 ",
	["@Equip4lose"] = "宝物栏",
	["Player_Start"] = "准备阶段",
	["Player_Judge"] = "判定阶段",
	["Player_Draw"] = "摸牌阶段",
	["Player_Play"] = "出牌阶段",
	["Player_Discard"] = "弃牌阶段",
	["Player_Finish"] = "结束阶段",
	["$NotifySkillInvoked_1"] = "%from 发动了“%arg”，目标是 %to",
	["$NotifySkillInvoked_2"] = "%from 发动了“%arg”",
	["basic_char"] = "基",
	["trick_char"] = "锦",
	["equip_char"] = "装",
	["zhengsu"] = "整肃",
	["zhengsu1"] = "擂进",
	["zhengsu2"] = "变阵",
	["zhengsu3"] = "鸣止",
	["zhengsu_successful"] = "成功",
	["zhengsu_fail"] = "失败",
	[":zhengsu1"] = "出牌阶段内，使用的牌点数递增且至少使用三张牌。",
	[":zhengsu2"] = "出牌阶段内，使用的牌花色均相同且至少使用两张牌。",
	[":zhengsu3"] = "弃牌阶段内，弃置的牌花色各不同且至少弃置两张牌。",
	["drawCards_2"] = "摸两张牌",
	["recover_1"] = "回复1点体力",
	["$zhengsu"] = "%from 选择执行 %arg 的 %arg2",
	["$jl_zhendian0"] = "%from 在“%arg”中选择了 %arg2",
	["addRenPile"] = "添加至仁区",
	["RenPile"] = "仁",
	["$addRenPile"] = "%from 将 %card 置入“%arg”区",
	["$fromRenPile"] = "%card 移出了“%arg”区",
	["bieshui"] = "背水",
	["Exchange:Exchange"] = "%src：是否与“%dest”中进行交换牌？",
	["Exchange0"] = "请选择牌交换至“%src”",
	["ExNihilo"] = "无中生有",
	["Dismantlement"] = "过河拆桥",
	["Nullification"] = "无懈可击",
	["Qizhengxiangsheng"] = "奇正相生",
	["Mantianguohai"] = "瞒天过海",
	["Tiaojiyanmei"] = "调剂盐梅",
	["Binglinchengxia"] = "兵临城下",
	["beishui_choice"] = "背水 %src",
	[":beishui_choice"] = "依次执行上面所有的选项",
	["shifa1"] = "第一个回合结束时生效",
	["shifa2"] = "第二个回合结束时生效",
	["shifa3"] = "第三个回合结束时生效",
	["$ov_baonieNum0"] = "%from 获得了 %arg 点 %arg2",
	["$ov_baonieNum1"] = "%from 消耗了 %arg 点 %arg2",
	["ov_baonieNum"] = "暴虐值",
	["$PlaceSpecial0"] = "%from 从 %to 的“%arg”中获得了 %arg2 张牌 %card",
	["$PlaceSpecial1"] = "%from 从 %to 的“%arg”中获得了 %arg2 张牌",
	["$wangxing"] = "%from“%arg3”选择了“%arg”的值为 %arg2",
	["$wangxing0"] = "%from“%arg3”的“%arg2”效果触发，需弃置 %arg 张牌，否则扣减1点体力上限",
	["wangxing0"] = "%dest-妄行：请弃置%src张牌，否则将扣减1点体力上限",
	["wangxing"] = "妄行",
	["$targetsPindian0"] = "%from 为此次%arg2中唯一最大点数 %arg ，%from获得%arg2胜利",
	["$targetsPindian1"] = "此次%arg2中最大点数 %arg 重复，无人获得%arg2胜利",
	["MoveField0"] = "%src：请选择一名角色转移牌",
	["MoveField1"] = "%src：请选择一名角色成为此【%dest】转移的目标",
	["#InstallEquip"] = "%from 装备了 %card",
	["robot"] = "     电脑",
	["Hello, I'm a robot"] = "",
	["rebelish"] = "叛逆",
	["loyalish"] = "忠诚",
	["dilemma"] = "两难",
	["neutral"] = "未知",
	["QsgsAI"] = "神小杀",
}

function getCardList(intlist)
	local cs = sgs.CardList()
	for _,id in sgs.list(intlist)do
		cs:append(sgs.Sanguosha:getCard(id))
	end
	return cs
end
function CardListToIntlist(cardlist)
	local ids = sgs.IntList()
	for _,c in sgs.list(cardlist)do
		ids:append(c:getEffectiveId())
	end
	return ids
end
function PhaseExtra(player,tophase,log)
	local room = player:getRoom()
	if log
	then
    	local log = sgs.LogMessage()
    	log.type ="#PhaseExtra"
    	log.from = player
		if tophase==sgs.Player_Start
		then log.arg = "Player_Start"
		elseif tophase==sgs.Player_Judge
		then log.arg = "Player_Judge"
		elseif tophase==sgs.Player_Draw
		then log.arg = "Player_Draw"
		elseif tophase==sgs.Player_Play
		then log.arg = "Player_Play"
		elseif tophase==sgs.Player_Discard
		then log.arg = "Player_Discard"
		elseif tophase==sgs.Player_Finish
		then log.arg = "Player_Finish" end
    	room:sendLog(log)
	end
	local current = room:getCurrent()
	local player_phase = player:getPhase()
	local thread = room:getThread()
	player:setPhase(tophase)
	room:broadcastProperty(player,"phase")
	if not thread:trigger(sgs.EventPhaseStart,room,player)
	then thread:trigger(sgs.EventPhaseProceeding,room,player) end
	thread:trigger(sgs.EventPhaseEnd,room,player)
	player:setPhase(player_phase)
	room:broadcastProperty(player,"phase")
end
function getPileSuitNum(Pile,suit)
	local suits = {}
	for s,c in sgs.list(Pile)do
		s = c:getSuitString()
		if suit then if s==suit then table.insert(suits,c) end
		elseif not table.contains(suits,s) then table.insert(suits,s) end
	end
   	return #suits
end
function MovePlayerCard(player,players,Pile,reason,reason1)
	local room = player:getRoom()
	local totos = sgs.SPlayerList()
	for _,p in sgs.list(players)do
    	local can
		for _,c in sgs.list(p:getCards(Pile))do
    		can = true
			break
		end
		if can
		then
			totos:append(p)
		end
	end
	totos = room:askForPlayerChosen(player,totos,reason,reason1)
	local id = room:askForCardChosen(player,totos,Pile,reason)
	local card = sgs.Sanguosha:getCard(id)
	local place = room:getCardPlace(id)
	local index = -1
	if place==sgs.Player_PlaceEquip
	then
		index = card:getRealCard():toEquipCard():location()
	end
	local tos = sgs.SPlayerList()
	for _,p in sgs.list(room:getAlivePlayers())do
		if index~=-1
		then
			if not p:getEquip(index)
			then tos:append(p) end
		else
			if not player:isProhibited(p,card)
			and not p:containsTrick(card:objectName())
			then tos:append(p) end
		end
	end
	local tag,mx = sgs.QVariant(),sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER,player:objectName(),reason,"")
	tag:setValue(totos)
	room:setTag("QiaobianTarget",tag)
	local to1 = room:askForPlayerChosen(player,tos,reason,reason1)
	if to1
	then room:moveCardTo(card,totos,to1,place,mx) end
	room:removeTag("QiaobianTarget")
end
function Log_message(msg_type,from,to,cid,arg,arg2,arg3,arg4,arg5)
	cid = cid and type(cid)~="number" and type(cid)~="string" and cid:getEffectiveId() or cid
	local room = from and from:getRoom() or to and to:length()>0 and to:at(0):getRoom()
	local msg = sgs.LogMessage()
	msg.type = msg_type
	msg.from = from or nil
	msg.to = to or sgs.SPlayerList()
	msg.card_str = cid or "."
	msg.arg = arg or "."
	msg.arg2 = arg2 or "."
	msg.arg3 = arg3 or "."
	msg.arg4 = arg4 or "."
	msg.arg5 = arg5 or "."
	room:sendLog(msg)
end
function BreakCard(player,card)
	card = type(card)=="number" and sgs.Sanguosha:getCard(card) or card
	if card:getEffectiveId()<0 then return end
	local toids = sgs.IntList()
	for _,id in sgs.list(card:getSubcards())do
		toids:append(id)
	end
	local room = player:getRoom()
	local msg = sgs.LogMessage()
	msg.type = "$BreakCard"
	msg.from = player
	msg.card_str = table.concat(sgs.QList2Table(toids,"+"))
	room:sendLog(msg)
	for _,id in sgs.list(room:getTag("BreakCard"):toIntList())do
		if room:getCardPlace(id)==sgs.Player_PlaceTable
		then toids:append(id) end
	end
	room:setTag("BreakCard",ToData(toids))
	msg = sgs.CardMoveReason(sgs.CardMoveReason_S_MASK_BASIC_REASON,player:objectName(),"BreakCard","")
   	room:moveCardTo(card,nil,sgs.Player_PlaceTable,msg,true)
end
function SearchCard(player,card_names)
	local cs = sgs.CardList()
	local function SearchCardNames(c)
    	if type(card_names)=="table"
		then
			if table.contains(card_names,c:objectName())
			or table.contains(card_names,c:getClassName())
			then return true end
		elseif string.find(card_names,c:objectName())
		or string.find(card_names,c:getClassName())
		then return true end
	end
	local room = player:getRoom()
	for _,c in sgs.list(room:getDiscardPile())do
		c = sgs.Sanguosha:getCard(c)
		if SearchCardNames(c) then cs:append(c) end
	end
   	for _,p in sgs.list(room:getAlivePlayers())do
		for _,c in sgs.list(p:getCards("ej"))do
			if SearchCardNames(c) then cs:append(c) end
		end
	end
	return cs
end
function ThrowEquipArea(self,player,cancel,invoke,n,x)
	self = type(self)=="string" and self or self:objectName()
	local choices = {}
	n = n or 0
	x = x or 4
	for i=n,x do
		if player:hasEquipArea(i)
		then
			table.insert(choices,"@Equip"..i.."lose")
		end
	end
	if #choices>0
	then
    	if invoke and not player:askForSkillInvoke(self)
		then return false end
		if cancel then table.insert(choices,"cancel") end
    	choices = player:getRoom():askForChoice(player,self,table.concat(choices,"+"))
    	if choices~="cancel"
    	then
	        choices = string.sub(choices,7,7)-0
			player:throwEquipArea(choices)
    	    return choices
	    end
	end
end
function ObtainEquipArea(self,player,cancel,invoke,n,x)
	self = type(self)=="string" and self or self:objectName()
	local choices = {}
	n = n or 0
	x = x or 4
	for i=n,x do
		if player:hasEquipArea(i) then continue end
		table.insert(choices,"@Equip"..i.."lose")
	end
	if #choices>0
	then
    	if invoke and not player:askForSkillInvoke(self)
		then return false end
    	if cancel then table.insert(choices,"cancel") end
		choices = player:getRoom():askForChoice(player,self,table.concat(choices,"+"))
    	if choices~="cancel"
		then
	        choices = string.sub(choices,7,7)-0
	        player:obtainEquipArea(choices)
        	return choices
		end
	end
	return false
end
function GetCardPlace(source,to_select)
    if source:getHandcards():contains(to_select)
	then return 1 end
    if source:getEquips():contains(to_select)
	then return 2 end
    if source:getJudgingArea():contains(to_select)
	then return 3 end
	return -1
end
function PatternsCard(name,islist,derivative)
  	local cards = {}
	if type(name)=="table"
	then
		for _,n in sgs.list(name)do
			n = PatternsCard(n,islist,derivative)
			if type(n)=="table" then InsertList(cards,n)
			else return n end
		end
		return islist and cards
	elseif name:match(",")
	then
		for _,n in sgs.list(name:split(","))do
			n = PatternsCard(n,islist,derivative)
			if type(n)=="table" then InsertList(cards,n)
			else return n end
		end
		return islist and cards
	end
	derivative = derivative or false
	for c,id in sgs.list(sgs.Sanguosha:getRandomCards(derivative))do
		c = sgs.Sanguosha:getEngineCard(id)
		if c:objectName()==name
		or c:isKindOf(name)
		then
			if islist then table.insert(cards,c)
			else return c end
		end
	end
	return islist and cards
end
function MarkRevises(player,mark1,mark2)
	local mark1 = mark1:split("-")
	local c_m = mark1[1].."+:+"..mark2
	local function MarkLikeness(m,to_m)
		if string.find(m,mark1[1])
		then
			if #mark1>1
			then
				if string.find(to_m[#to_m],mark1[#mark1])
				then return true else return end
			end
			return true
		end
	end
	local room = player:getRoom()
	for n,m in sgs.list(player:getMarkNames())do
		n = player:getMark(m)
		local to_m = m:split("-")
		if MarkLikeness(m,to_m)
		and n>0
		then
			c_m = to_m[1].."+"..mark2
			if #mark1>1 then c_m = c_m.."-"..mark1[#mark1] end
			room:setPlayerMark(player,m,0)
			room:setPlayerMark(player,c_m,n)
			return true
		end
	end
	if #mark1>1 then c_m = c_m.."-"..mark1[#mark1] end
	room:addPlayerMark(player,c_m)
	return true
end
function TransferMark(player,target,name,n)
	n = n or 1
	n = math.min(n,player:getMark(name))
	if n<1 then return end
	local room = player:getRoom()
   	local log = sgs.LogMessage()
   	log.type = "$TransferMark"
    log.from = player
    log.to:append(target)
 	log.arg = name --string.sub(name,2,5)
 	log.arg2 = n
 	room:sendLog(log)
	room:removePlayerMark(player,name,n)
	room:addPlayerMark(target,name,n)
end
function ExchangePileCard(self,player,name,n,can_equipped,will,compulsory)
	local can_equipped,compulsory = can_equipped or false,compulsory or false
	if can_equipped and player:getCardCount()<1
	or player:getHandcardNum()<1 then return end
	local self = type(self)=="string" and self or self:objectName()
	local room = player:getRoom()
	if compulsory or player:askForSkillInvoke("Exchange",sgs.QVariant("Exchange:"..self..":"..name),false)
	then
		local cids = player:getPile(name)
		local c,ids = dummyCard(),sgs.IntList()
		local guojia = sgs.SPlayerList()
		guojia:append(player)
		local reason = sgs.CardMoveReason_S_REASON_PREVIEW
		local move = sgs.CardsMoveStruct(cids,player,player,sgs.Player_PlaceSpecial,sgs.Player_PlaceHand,
		sgs.CardMoveReason(reason,player:objectName(),self,nil))
		local moves = sgs.CardsMoveList()
		moves:append(move)
		room:notifyMoveCards(true,moves,false,guojia)
		room:notifyMoveCards(false,moves,false,guojia)
		local x = n
		if will then x = 1 end
		local ns = room:askForExchange(player,self,n,x,can_equipped,"Exchange0:"..name,compulsory)
		move = sgs.CardsMoveStruct(cids,player,nil,sgs.Player_PlaceHand,sgs.Player_PlaceTable,
		sgs.CardMoveReason(reason,player:objectName(),self,nil))
		moves = sgs.CardsMoveList()
		moves:append(move)
		room:notifyMoveCards(true,moves,false,guojia)
		room:notifyMoveCards(false,moves,false,guojia)
		if ns and ns:subcardsLength()>0
		then
			ids = dummyCard()
			for i,id in sgs.list(ns:getSubcards())do
				if cids:contains(id)
				then continue end
				ids:addSubcard(id)
			end
			for i,id in sgs.list(cids)do
				if ns:getSubcards():contains(id)
				then continue end
				c:addSubcard(id)
			end
			player:addToPile(name,ids)
			room:obtainCard(player,c)
		end
	end
end
function PreviewCards(self,player,cards,x,n,optional,prompt,throw)
	if cards:length()<1 then return end
	self = type(self)=="string" and self or self:objectName()
	local room,optional = player:getRoom(),optional or false
	local guojia = sgs.SPlayerList()
	guojia:append(player)
	local prompt = prompt or self
	local reason = sgs.CardMoveReason_S_REASON_PREVIEW
	local owner,place = room:getCardOwner(cards:at(0)),room:getCardPlace(cards:at(0))
	local move = sgs.CardsMoveStruct(cards,owner,player,place,sgs.Player_PlaceHand,
	sgs.CardMoveReason(reason,player:objectName(),self,nil))
	local moves = sgs.CardsMoveList()
	moves:append(move)
	room:notifyMoveCards(true,moves,false,guojia)
	room:notifyMoveCards(false,moves,false,guojia)
	local ns = table.concat(sgs.QList2Table(cards),",")
	player:setTag("PreviewCards",ToData(ns))
	if throw then ns = room:askForDiscard(player,self,x,n,true,optional,prompt,ns,self)
	else ns = room:askForExchange(player,self,x,n,true,prompt,optional,ns) end
	player:removeTag("PreviewCards")
	move = sgs.CardsMoveStruct(cards,player,nil,sgs.Player_PlaceHand,sgs.Player_PlaceTable,
	sgs.CardMoveReason(reason,player:objectName(),self,nil))
	moves = sgs.CardsMoveList()
	moves:append(move)
	room:notifyMoveCards(true,moves,false,guojia)
	room:notifyMoveCards(false,moves,false,guojia)
	return ns and ns:subcardsLength()>0 and ns
end
function CanToCard(card,from,to,tos)
	tos = tos or sgs.SPlayerList()
	local plist = sgs.PlayerList()
	for _,p in sgs.list(tos)do
		plist:append(p)
	end
	if from:isProhibited(to,card,plist)
	or plist:contains(to) then return end
  	return card:targetFilter(plist,to,from)
end
function CardVisible(player,id,special)
	id = type(id)=="number" and id or id:getEffectiveId()
	local place = player:getRoom():getCardPlace(id)
	if place==sgs.Player_PlaceEquip
	or place==sgs.Player_PlaceJudge
	or place==sgs.Player_PlaceTable
	or place==sgs.Player_DiscardPile
	or place==sgs.Player_PlaceDelayedTrick
	then return true
	elseif special
	and place==sgs.Player_PlaceSpecial
	then
		place = player:getRoom():getCardOwner(id)
		return place:pileOpen(place:getPileName(id),player:objectName())
	end
end
function ThrowArea(player,n)
	if n==1
	then
		local room = player:getRoom()
		local log = sgs.LogMessage()
		log.type = "#ThrowArea"
		log.from = player
		log.arg = "hand_area"
		room:sendLog(log)
		log = dummyCard()
		log:addSubcards(player:handCards())
		room:throwCard(log,nil)
		player:setTag("ThrowArea_"..n,sgs.QVariant(true))
		room:setPlayerMark(player,"@Handlose",1)
		return true
	elseif n==2
	then
		player:throwJudgeArea()
		return true
	elseif n==3
	then
		player:throwEquipArea()
		return true
	end
end
function ObtainArea(player,n)
	if n==1
	then
		local room = player:getRoom()
		local log = sgs.LogMessage()
		log.type = "#ObtainArea"
		log.from = player
		log.arg = "hand_area"
		room:sendLog(log)
		player:setTag("ThrowArea_"..n,sgs.QVariant(false))
		room:setPlayerMark(player,"@Handlose",0)
		return true
	elseif n==2
	then
		player:obtainJudgeArea()
		return true
	elseif n==3
	then
		player:obtainEquipArea()
		return true
	end
end
function GetStringLength(inputstr)
    if not inputstr or type(inputstr)~="string" or #inputstr<1
	then return 0 end
    local i,n = 1,0
    while true do
        local count = 1
        local cur = string.byte(inputstr,i)
        if cur>239 then count = 4 -- 4字节字符
        elseif cur>223 then count = 3 -- 汉字
        elseif cur>128 then count = 2 -- 双字节字符
        else count = 1 end -- 单字节字符
        i = i+count
        n = n+1
        if i>#inputstr
		then break end
    end
    return n
end
function string:stringLength()
	return GetStringLength(self)
end
function addRenPile(card,player,self)
	local room = player:getRoom()
	card = type(card)=="number" and sgs.Sanguosha:getCard(card) or card
	self = type(self)=="string" and self or self and self:objectName() or ""
	if card:getEffectiveId()<0 then return end
	local log = sgs.LogMessage()
	log.type = "$addRenPile"
	log.from = player
	log.arg = "RenPile"
	local toids = {}
	local RenPile = room:getTag("RenPile"):toIntList()
	for _,id in sgs.list(card:getSubcards())do
		table.insert(toids,id)
		RenPile:append(id)
	end
	room:setTag("RenPile",ToData(RenPile))
   	log.card_str = table.concat(toids,"+")
   	room:sendLog(log)
	local data = "RenPile:enter:"..log.card_str
	room:getThread():trigger(sgs.EventForDiy,room,player,ToData(data))
   	log = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECYCLE,player:objectName(),"",self,"addRenPile")
   	room:moveCardTo(card,nil,sgs.Player_PlaceTable,log,true)
	RenPile = room:getTag("RenPile"):toIntList()
   	for _,p in sgs.list(room:getAlivePlayers())do
    	if p:getMark("@RenPile")>0
		then
	    	room:setPlayerMark(p,"@RenPile",RenPile:length())
			return
		end
	end
	room:setPlayerMark(player,"@RenPile",RenPile:length())
end
function getRenPile(room)
	return room:getTag("RenPile"):toIntList()
end
function ZhengsuChoice(player)
	local choices = {}
	for i = 1,3 do
		if player:getTag("zhengsu"..i):toBool() then continue end
		table.insert(choices,"zhengsu"..i)
	end
	if #choices<1 then return -1 end
	local room = player:getRoom()
	choices = room:askForChoice(player,"zhengsu",table.concat(choices,"+"))
	Log_message("$zhengsu",player,nil,nil,"zhengsu",choices)
	player:setTag(choices,ToData(true))
	room:setPlayerMark(player,"&zhengsu+-+"..choices,1)
	return tonumber(string.sub(choices,8,8))
end
function SetShifa(self,player,x)
	local room = player:getRoom()
	self = type(self)=="string" and self or self:objectName()
	x = x and 4-x>0 and x>0 and x or room:askForChoice(player,"shifa","shifa1+shifa2+shifa3")
	if x=="shifa1" then x = 1 elseif x=="shifa2" then x = 2 elseif x=="shifa3" then x = 3 end
	for _,sf in sgs.list(sgs.shifa_skills)do
		if sf.name==self and sf.owner:objectName()==player:objectName()
		then table.removeOne(sgs.shifa_skills,sf) end
	end
	local shifa_skill = {}
	shifa_skill.name = self
	shifa_skill.x = x
	shifa_skill.owner = player
	player:setTag("shifa_"..self,ToData(x))
	table.insert(sgs.shifa_skills,shifa_skill)
	room:setPlayerMark(player,"&"..self.."+-+shifa",x)
	Log_message("$shifa",player,nil,nil,"shifa",x,self)
	return shifa_skill
end
sgs.ZhinangClassName = {"ExNihilo","Dismantlement","Nullification","Qizhengxiangsheng","Mantianguohai","Tiaojiyanmei","Binglinchengxia"}
function GainOvBaonieNum(target,n)
	local room = target:getRoom()
	n = tonumber(n)
	if n>0
	then
		local x = 5-target:getTag("ov_baonieNum"):toInt()
		if x<1 then return end
		x = x<n and x or n
		local m = target:getTag("ov_baonieNum"):toInt()+x
		target:setTag("ov_baonieNum",ToData(m))
		room:setPlayerMark(target,"@ov_baonieNum",m)
		Log_message("$ov_baonieNum0",target,nil,nil,x,"ov_baonieNum")
	elseif n<0
	then
		local x = target:getTag("ov_baonieNum"):toInt()
		if x<1 then return end
		x = x+n<1 and x or -n
		local m = target:getTag("ov_baonieNum"):toInt()-x
		target:setTag("ov_baonieNum",ToData(m))
		room:setPlayerMark(target,"@ov_baonieNum",m)
		Log_message("$ov_baonieNum1",target,nil,nil,x,"ov_baonieNum")
	end
	
end
function SetWangxing(self,player,x)
	local room = player:getRoom()
	self = type(self)=="string" and self or self:objectName()
	x = x and 5-x>0 and x>0 and x or room:askForChoice(player,"wangxing","1+2+3+4")
	x = tonumber(x)
	for _,wx in sgs.list(sgs.wangxing_skills)do
		if wx.name==self and wx.owner:objectName()==player:objectName()
		then table.removeOne(sgs.wangxing_skills,wx) end
	end
	local wx_skill = {}
	wx_skill.name = self
	wx_skill.x = x
	wx_skill.owner = player
	player:setTag("wangxing_"..self,ToData(true))
	table.insert(sgs.wangxing_skills,wx_skill)
	room:setPlayerMark(player,"&"..self.."+-+wangxing-Clear",x)
	Log_message("$wangxing",player,nil,nil,"wangxing",x,self)
	return wx_skill
end
function targetsPindian(self,player,targets)
	self = type(self)=="string" and self or self:objectName()
    local log = sgs.LogMessage()
    log.type = "#Pindian"
    log.from = player
	local to_names = {}
	for i,to in sgs.list(targets)do
		log.to:append(to)
		table.insert(to_names,to:objectName())
	end
	if log.to:length()<1 then return end
	local room = player:getRoom()
    room:sendLog(log)
	to_names = table.concat(to_names,"+")
	player:setTag("targetsPindian_"..self,ToData(to_names))
	local pd = sgs.PindianStruct()
	local pd_to_card = {}
	pd.from = player
	pd.reason = self
	for data,to in sgs.list(targets)do
		pd.to = to
		pd.to_card = nil
		data = ToData(pd)
		room:getThread():trigger(sgs.AskforPindianCard,room,player,data)
		pd = data:toPindian()
		if pd.to_card
		then
			pd_to_card[to:objectName()]=pd.to_card
		end
	end
	local pd_to_number = {}
	for c,to in sgs.list(targets)do
		if not pd_to_card[to:objectName()]
		and not pd.from_card
		then
			c = room:askForPindianRace(player,to,self)
			if c:length()<2 then continue end
			pd.from_card = c:at(0)
			pd.from_number = c:at(0):getNumber()
			pd_to_card[to:objectName()] = c:at(1)
			pd_to_number[to:objectName()] = c:at(1):getNumber()
		elseif not pd.from_card
		then
			pd.from_card = room:askForPindian(player,player,to,self)
			pd.from_number = pd.from_card:getNumber()
		elseif not pd_to_card[to:objectName()]
		then
			pd_to_card[to:objectName()] = room:askForPindian(to,player,to,self)
			pd_to_number[to:objectName()] = pd_to_card[to:objectName()]:getNumber()
		end
	end
	local moves = sgs.CardsMoveList()
	if pd.from_card
	then
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PINDIAN,pd.from:objectName(),"",pd.reason,"pindian")
		moves:append(sgs.CardsMoveStruct(pd.from_card:getEffectiveId(),nil,sgs.Player_PlaceTable,reason))
	elseif #pd_to_card<2 then player:removeTag("targetsPindian_"..self) return end
	for c,to in sgs.list(targets)do
		c = pd_to_card[to:objectName()]
		if not c then continue end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PINDIAN,pd.from:objectName(),to:objectName(),pd.reason,"pindian")
		moves:append(sgs.CardsMoveStruct(c:getEffectiveId(),nil,sgs.Player_PlaceTable,reason))
	end
	room:moveCardsAtomic(moves,true)
    log.type = "$PindianResult"
    log.from = pd.from
    log.card_str = pd.from_card:getEffectiveId()
    room:sendLog(log)
	for c,to in sgs.list(targets)do
		c = pd_to_card[to:objectName()]
		if not c then continue end
		log.type = "$PindianResult"
		log.from = to
		log.card_str = c:getEffectiveId()
		room:sendLog(log)
	end
	local fn
	for data,to in sgs.list(targets)do
		pd.to_card = pd_to_card[to:objectName()]
		if not pd.to_card then continue end
		pd.to_number = pd_to_number[to:objectName()]
		pd.to = to
		data = ToData(pd)
		room:getThread():trigger(sgs.PindianVerifying,room,player,data)
		pd = data:toPindian()
		fn = fn or pd.from_number
		pd_to_number[to:objectName()] = pd.to_number
		pd.from_number = pd.from_card:getNumber()
	end
	pd.from_number = fn or pd.from_number
	local numbers = {}
	if pd.from_number
	then
		table.insert(numbers,pd.from_number)
	end
	for i,to in sgs.list(targets)do
		if not pd_to_number[to:objectName()] then continue end
		table.insert(numbers,pd_to_number[to:objectName()])
	end
	local maxNumbers = function(a,b)
		return a>b
	end
	table.sort(numbers,maxNumbers)
	local pd_ = {}
	pd_.from = pd.from
	pd_.reason = pd.reason
	pd_.from_card = pd.from_card
	pd_.from_number = pd.from_number
	pd_.to = sgs.SPlayerList()
	pd_.to_number = sgs.IntList()
	pd_.to_card = sgs.CardList()
	if numbers[1]==numbers[2]
	then
		pd_.success_owner = nil
		room:setEmotion(player,"no-success")
	elseif numbers[1]==pd.from_number
	then
		pd_.success_owner = player
		room:setEmotion(player,"success")
	end
	for c,to in sgs.list(targets)do
		c = pd_to_card[to:objectName()]
		if not c then continue end
		if numbers[1]~=numbers[2]
		and pd_to_number[to:objectName()]==numbers[1]
		then
			pd_.success_owner = to
			room:setEmotion(to,"success")
		else
			room:setEmotion(to,"no-success")
		end
		pd_.to:append(to)
		pd_.to_number:append(pd_to_number[to:objectName()])
		pd_.to_card:append(c)
	end
	if pd_.success_owner
	then
		log.type = "$targetsPindian0"
		log.from = pd_.success_owner
		log.arg = numbers[1]
		log.arg2 = "pindian"
		room:sendLog(log)
	else
		log.type = "$targetsPindian1"
		log.arg = numbers[1]
		log.arg2 = "pindian"
		room:sendLog(log)
	end
	for data,to in sgs.list(targets)do
		pd.to_card = pd_to_card[to:objectName()]
		if not pd.to_card then continue end
		pd.to_number = pd_to_number[to:objectName()]
		if numbers[1]~=numbers[2]
		then pd.success = pd.to_number~=numbers[1]
		else pd.success = nil end
		pd.to = to
		data = ToData(pd)
		room:getThread():trigger(sgs.Pindian,room,player,data)
	end
	local moves = sgs.CardsMoveList()
	if pd.from_card
	and room:getCardPlace(pd.from_card:getEffectiveId())==sgs.Player_PlaceTable
	then
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PINDIAN,pd.from:objectName(),"",pd.reason,"pindian")
		moves:append(sgs.CardsMoveStruct(pd.from_card:getEffectiveId(),nil,sgs.Player_DiscardPile,reason))
	end
	for c,to in sgs.list(targets)do
		c = pd_to_card[to:objectName()]
		if not c or room:getCardPlace(c:getEffectiveId())~=sgs.Player_PlaceTable then continue end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PINDIAN,pd.from:objectName(),to:objectName(),pd.reason,"pindian")
		moves:append(sgs.CardsMoveStruct(c:getEffectiveId(),nil,sgs.Player_DiscardPile,reason))
	end
	room:moveCardsAtomic(moves,true)
	room:getThread():delay(1111)
	player:removeTag("targetsPindian_"..self)
	return pd_
end
function InstallEquip(ec,player,self,to)
	ec = type(ec)~="number" and ec:getEffectiveId() or ec
	local e = sgs.Sanguosha:getCard(ec)
	e = e:getRealCard():toEquipCard():location()
	to = to or player
	if sgs.Sanguosha:getCard(ec):getTypeId()~=3
	or not to:hasEquipArea(e) then return end
	local ton = to~=player and to:objectName() or ""
	self = type(self)=="string" and self or self and self:objectName() or ""
	local move1 = sgs.CardsMoveStruct()
	move1.card_ids:append(ec)
	move1.to = to
	move1.to_place = sgs.Player_PlaceEquip
	move1.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT,player:objectName(),ton,self,"")
	local moves = sgs.CardsMoveList()
	e = to:getEquip(e)
	if e and e:getEffectiveId()~=ec
	then
		local move2 = sgs.CardsMoveStruct()
		move2.card_ids:append(e:getEffectiveId())
		move2.from = to
		move2.to = nil
		move2.to_place = sgs.Player_DiscardPile
		move2.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_CHANGE_EQUIP,player:objectName(),ton,self,"")
		moves:append(move2)
	end
	moves:append(move1)
	player:getRoom():moveCardsAtomic(moves,true)
	Log_message("#InstallEquip",player,nil,ec)
	return true
end
function MoveFieldCard(self,player,flags,froms,tos)
	local room = player:getRoom()
	self = type(self)=="string" and self or self:objectName()
	local mfc = {reason = self,owner = player}
	flags = flags or "ej"
	mfc.flags = flags
	froms = froms or sgs.SPlayerList()
	if froms:isEmpty()
	then
		for i,p in sgs.list(room:getAlivePlayers())do
			if p:getCards(flags):length()>0
			then froms:append(p) end
		end
	end
	tos = tos or room:getAlivePlayers()
	if froms:isEmpty() then return end
	mfc.from = room:askForPlayerChosen(player,froms,self.."_from","MoveField0:"..self)
	room:doAnimate(1,player:objectName(),mfc.from:objectName())
	local noids = sgs.IntList()
	for i,ej in sgs.list(mfc.from:getCards(flags))do
		i = room:getCardPlace(ej:getEffectiveId())
		local can = false
		for n,p in sgs.list(tos)do
			if i==sgs.Player_PlaceEquip
			then
				n = ej:getRealCard():toEquipCard():location()
				if p:getEquip(n) or not p:hasEquipArea(n)
				then continue end
				can = true
			elseif i==sgs.Player_PlaceDelayedTrick
			then
				if p:containsTrick(ej:objectName())
				or player:isProhibited(p,ej)
				then continue end
				can = true
			else
				can = true
			end
		end
		if not can
		then
			noids:append(ej:getEffectiveId())
		end
	end
	noids = room:askForCardChosen(player,mfc.from,flags,self,false,sgs.Card_MethodNone,noids)
	if noids<0 then return end
	mfc.to_place = room:getCardPlace(noids)
	mfc.card = sgs.Sanguosha:getCard(noids)
	local canTos = sgs.SPlayerList()
	for i,p in sgs.list(tos)do
		if mfc.to_place==sgs.Player_PlaceEquip
		then
			i = mfc.card:getRealCard():toEquipCard():location()
			if p:getEquip(i) or not p:hasEquipArea(i)
			then continue end
		elseif mfc.to_place==sgs.Player_PlaceDelayedTrick
		then
			if p:containsTrick(mfc.card:objectName())
			or player:isProhibited(p,mfc.card)
			then continue end
		end
		canTos:append(p)
	end
	mfc.to = room:askForPlayerChosen(player,canTos,self.."_to","MoveField1:"..self..":"..mfc.card:objectName())
	room:doAnimate(1,mfc.from:objectName(),mfc.to:objectName())
	canTos = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER,player:objectName(),mfc.from:objectName(),self,"")
	room:moveCardTo(mfc.card,mfc.from,mfc.to,mfc.to_place,canTos)
	return mfc
end
function InsertList(list1,list2)
	if type(list1)=="table"
	then
		for _,l in sgs.list(list2)do
			table.insert(list1,l)
		end
	else
		for _,l in sgs.list(list2)do
			list1:append(l)
		end
	end
	return list1
end
function string:cardAvailable(player,sn,suit,num)
	return CardIsAvailable(player,self,sn,suit,num)
end
function sgs.QList2Table(list)
	local t = {}
	for _,a in sgs.list(list)do
		table.insert(t,a)
	end
	return t
end












sgs.patterns = {}
equip_patterns = {}
function AllCardPatterns()
	local tocs = {}
  	for c,id in sgs.list(sgs.Sanguosha:getRandomCards())do
		c = sgs.Sanguosha:getEngineCard(id)
		sgs.patterns[c:getClassName()] = c:objectName()
		if table.contains(tocs,c:objectName()) then continue end
		if c:getTypeId()<3 then table.insert(tocs,c:objectName())
		else table.insert(equip_patterns,c:objectName()) end
	end
	return tocs
end
patterns = AllCardPatterns()
sgs.aiHandCardVisible = io.open("aiHandCardVisible.txt")~=nil
OnSkillTrigger = sgs.CreateTriggerSkill{
    name = "OnSkillTrigger",
	frequency = sgs.Skill_Compulsory,
    events = {sgs.PreCardUsed,sgs.EventPhaseStart,sgs.EventPhaseProceeding,sgs.EventPhaseEnd,sgs.EventPhaseChanging,
	sgs.GameOver,sgs.DrawInitialCards,sgs.CardsMoveOneTime,sgs.Damaged,sgs.BeforeCardsMove,sgs.FinishRetrial},
	global = true,
	priority = {9,5,4},
    on_trigger = function(self,event,player,data,room)
		if event==sgs.CardsMoveOneTime
		then
	    	local move = data:toMoveOneTime()
			if move.to and move.to:objectName()==player:objectName()
			and move.to_place==sgs.Player_PlaceEquip
			then
               	for c,id in sgs.list(move.card_ids)do
			    	c = sgs.Sanguosha:getCard(id)
					if c:isKindOf("Horse")
					then
						id = sgs.HorseSkill[c:objectName()]
						if id
						then
							local oi = id.on_install
							if type(oi)=="function"
							then oi(c,player,room) end
						end
			  		end
				end
			end
			if move.from_places:contains(sgs.Player_PlaceEquip)
			and move.from:objectName()==player:objectName()
			then
				for c,id in sgs.list(move.card_ids)do
					if move.from_places:at(c)==sgs.Player_PlaceEquip
					then
						c = sgs.Sanguosha:getCard(id)
						if c:isKindOf("Horse")
						then
							id = sgs.HorseSkill[c:objectName()]
							if id
							then
								local ou = id.on_uninstall
								if type(ou)=="function"
								then ou(c,player,room) end
							end
						end
					end
				end
 			end
			if move.to
			and move.to_place==sgs.Player_PlaceHand
			and move.from_places:contains(sgs.Player_PlaceSpecial)
			and not move.from_pile_names[1]:startsWith("#")
			and move.to:objectName()==player:objectName()
			then
				local ids,opens = {},{}
				for i,p in sgs.list(move.from_places)do
					if p==sgs.Player_PlaceSpecial
					then
						table.insert(ids,move.card_ids:at(i))
						if move.open:at(i)
						then
							table.insert(opens,move.card_ids:at(i))
						end
					end
				end
               	local log = sgs.LogMessage()
               	log.type = "$PlaceSpecial0"
               	log.from = player
               	log.to:append(BeMan(room,move.from))
               	log.arg = move.from_pile_names[1]
               	log.arg2 = #ids
               	log.card_str = table.concat(ids,"+")
				room:sendLog(log,player)
               	log.card_str = table.concat(opens,"+")
				if #opens<1 then log.type = "$PlaceSpecial1" end
				room:sendLog(log,room:getOtherPlayers(player,true))
			end
			if move.to_place==sgs.Player_PlaceHand
			and move.to:objectName()==player:objectName()
			and player:getTag("ThrowArea_1"):toBool()
			then
				move.to = nil
				move.card_ids = player:handCards()
				move.to_place = sgs.Player_DiscardPile
				room:moveCardsAtomic(move,true)
			end
			if room:getCurrent()~=player then return end
			if player:getTag("zhengsu3"):toBool() and player:getPhase()==sgs.Player_Discard and move.to_place==sgs.Player_DiscardPile
			and bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON)==sgs.CardMoveReason_S_REASON_DISCARD
			then
				local cards = player:getTag("zhengsu-3"):toIntList()
				for _,id in sgs.list(move.card_ids)do
					cards:append(sgs.Sanguosha:getCard(id):getSuit())
				end
				player:setTag("zhengsu-3",ToData(cards))
			end
           	local RenPile = room:getTag("RenPile"):toIntList()
			if move.to_place==sgs.Player_PlaceTable
			and RenPile:length()>6
			then
             	local c = dummyCard()
				while RenPile:length()>6 do
					c:addSubcard(RenPile:first())
    	    		RenPile:removeOne(RenPile:first())
				end
 		   		room:setTag("RenPile",ToData(RenPile))
				local data = "RenPile:throw:"..table.concat(sgs.QList2Table(c:getSubcards()),"+")
				room:getThread():trigger(sgs.EventForDiy,room,player,ToData(data))
				room:throwCard(c,nil)
               	for _,p in sgs.list(room:getAlivePlayers())do
					if p:getMark("@RenPile")>0
					then
						room:setPlayerMark(p,"@RenPile",RenPile:length())
						c = false
						break
					end
				end
				if c
				then
					room:setPlayerMark(player,"@RenPile",RenPile:length())
				end
			end
			RenPile = room:getTag("RenPile"):toIntList()
			if RenPile:length()>0
			and move.from_places:contains(sgs.Player_PlaceTable)
			then
				local ids,toids = {},{}
            	for _,id in sgs.list(RenPile)do
			   		table.insert(ids,id)
				end
            	for _,id in sgs.list(ids)do
			    	if room:getCardPlace(id)~=sgs.Player_PlaceTable
					then
						if move.card_ids:contains(id)
						then table.insert(toids,id) end
						RenPile:removeOne(id)
					end
				end
 		    	room:setTag("RenPile",ToData(RenPile))
				if #toids>0
				then
                  	local log = sgs.LogMessage()
                  	log.type = "$bf_fromRenPile"
                 	log.arg = "RenPile"
                	log.card_str = table.concat(toids,"+")
                	room:sendLog(log)
                 	for _,p in sgs.list(room:getAlivePlayers())do
						if p:getMark("@RenPile")>0
						then
							room:setPlayerMark(p,"@RenPile",RenPile:length())
							log = false
							break
						end
					end
					if log
					then
						room:setPlayerMark(player,"@RenPile",RenPile:length())
					end
				end
			end
        elseif event==sgs.BeforeCardsMove
		then
			local move = data:toMoveOneTime()
			if move.to_place==sgs.Player_PlaceHand
			and move.to:objectName()==player:objectName()
			and player:getTag("ThrowArea_1"):toBool()
			then
				move.to = nil
				move.to_place = sgs.Player_DiscardPile
				data:setValue(move)
				local msg = sgs.LogMessage()
				msg.type = "$ThrowArea_1"
				msg.from = player
				msg.arg = "hand_area"
				msg.card_str = table.concat(sgs.QList2Table(move.card_ids),"+")
				room:sendLog(msg)
			end
		elseif event==sgs.DrawInitialCards
		then
			if player:getState()=="robot"
			and sgs.aiHandCardVisible
			then
				sgs.screenIds = sgs.screenIds or sgs.IntList()
				local x = 33
				while sgs.screenIds do
					x = math.random(10,99)
					if sgs.screenIds:contains(x)
					then else break end
				end
				sgs.screenIds:append(x)
				local k = player:getKingdom()
				local ks = sgs.Sanguosha:getKingdoms()
				if ks[1]==k then ks = ks[2] else ks = ks[1] end
				room:setPlayerProperty(player,"kingdom",ToData(ks))
				room:setPlayerProperty(player,"screenname",ToData("QsgsAI:0"..x))
				room:setPlayerProperty(player,"kingdom",ToData(k))
			end
		elseif event==sgs.FinishRetrial
		then
	    	local judge = data:toJudge()
	    	local card = sgs.Sanguosha:cloneCard(judge.card)
			if card
			then
	         	card:setSkillName("JudgeCard")
		     	player:setTag("JudgeCard_"..judge.reason,ToData(card))
             	card:deleteLater()
			end
		elseif event==sgs.Damaged
		then
		    local damage = data:toDamage()
			if damage.card
			then
				room:setTag("damage_caused_"..damage.card:toString(),data)
				damage.card:setProperty("damage_caused",data)
			end
			if damage.from
			then
				for _,skill in sgs.list(damage.from:getSkillList())do
					if skill:property("ov_baonieNum"):toBool()
					then
						GainOvBaonieNum(damage.from,damage.damage)
						break
					end
				end
			end
			player:setTag("bf_tianyig_damage",ToData(true))
			for _,skill in sgs.list(player:getSkillList())do
				if skill:property("ov_baonieNum"):toBool()
				then
					GainOvBaonieNum(player,damage.damage)
					break
				end
			end
		elseif event==sgs.GameOver
		then
    		local winner = data:toString():split("+")
	       	for s,p in sgs.list(room:getAllPlayers())do
				if table.contains(winner,p:objectName())
				or table.contains(winner,p:getRole())
				then
					s = "audio/"..p:getGeneralName().."-win.ogg"
					sgs.Sanguosha:playAudioEffect(s)
					if p:getGeneral2()
					then
						s = "audio/"..p:getGeneral2Name().."-win.ogg"
						sgs.Sanguosha:playAudioEffect(s)
					end
				end
			end
        elseif event==sgs.PreCardUsed
		then
	       	local use = data:toCardUse()--[[
			if use.card:isVirtualCard()
			and use.card:getTypeId()>0
			then
				use.card = SetCloneCard(use.card)
				data:setValue(use)
				use = data:toCardUse()
			end--]]
			room:removeTag("damage_caused_"..use.card:toString())
			use.card:setProperty("damage_caused",ToData())
			for i=1,2 do
				if use.from==player
				and player:getTag("zhengsu"..i):toBool()
				and player:getPhase()==sgs.Player_Play
				and use.card:getTypeId()~=0
				then
					local zhengsu = player:getTag("zhengsu-"..i):toIntList()
					if i<2 then zhengsu:append(use.card:getNumber())
					else zhengsu:append(use.card:getSuit()) end
					player:setTag("zhengsu-"..i,ToData(zhengsu))
				end
			end
        elseif event==sgs.EventPhaseChanging
        then
	     	local change = data:toPhaseChange()
			if change.to==sgs.Player_NotActive
			then
	         	for _,to in sgs.list(room:getAllPlayers())do
					for x,sf in sgs.list(sgs.shifa_skills)do
					   	if sf.owner:objectName()~=to:objectName() then continue end
						x = sf.owner:getTag("shifa_"..sf.name):toInt()
						x = x>0 and x or sf.owner:getMark("&"..sf.name.."+-+shifa")
						if x<1 then continue end
						x = x-1
						sf.owner:setTag("shifa_"..sf.name,ToData(x))
						room:setPlayerMark(sf.owner,"&"..sf.name.."+-+shifa",x)
						if x>0 then continue end
						Log_message("$shifa0",sf.owner,nil,nil,sf.name,"shifa")
						sf.effect(sf.owner,sf.x)
						sf.owner:removeTag("shifa_"..sf.name)
					end
					for x,wx in sgs.list(sgs.wangxing_skills)do
					   	if wx.owner:objectName()~=to:objectName() then continue end
						x = wx.owner:getTag("wangxing_"..wx.name):toBool()
						x = x and wx.x or wx.owner:getMark("&"..wx.name.."+-+wangxing-Clear")
						if x<1 then continue end
						Log_message("$wangxing0",wx.owner,nil,nil,x,"wangxing",wx.name)
						change = wx.owner:getCardCount()>=x
						if change
						then
							wx.owner:setTag("wangxing_ai",ToData(wx.name))
							change = room:askForDiscard(wx.owner,"wangxing",x,x,true,true,"wangxing0:"..x..":"..wx.name)
							wx.owner:removeTag("wangxing_ai")
						end
						if not change then room:loseMaxHp(wx.owner) end
						wx.owner:removeTag("wangxing_"..wx.name)
					end
				end
			elseif change.from==sgs.Player_Discard
			then
				for i=1,3 do
					if player:getTag("zhengsu"..i):toBool()
					then
						local ids = player:getTag("zhengsu-"..i):toIntList()
						local can,n = true,0
						if i==1
						then
							for _,c in sgs.list(ids)do
								if c<=n then can = false end
								n = c
							end
							can = can and ids:length()>2
						elseif i==2
						then
							n = ids:first()
							for _,c in sgs.list(ids)do
								if c~=n then can = false end
								n = c
							end
							can = can and ids:length()>1
						elseif i==3
						then
							n = {}
							for _,c in sgs.list(ids)do
								if table.contains(n,c) then can = false end
								table.insert(n,c)
							end
							can = can and ids:length()>1
						end
						local msg = sgs.LogMessage()
						msg.type = "$zhengsu0"
						msg.from = player
						msg.arg = "zhengsu"
						msg.arg2 = "zhengsu_fail"
						local data = "zhengsu:"..i..":zhengsu_fail"
						if can
						then
							msg.arg2 = "zhengsu_successful"
							room:sendLog(msg)
							data = "zhengsu:"..i..":zhengsu_successful"
							if room:askForChoice(player,"zhengsu","drawCards_2+recover_1")~="drawCards_2"
							then room:recover(player,sgs.RecoverStruct(player))
							else player:drawCards(2,"zhengsu") end
						else room:sendLog(msg) end
						player:removeTag("zhengsu"..i)
						player:removeTag("zhengsu-"..i)
						room:getThread():trigger(sgs.EventForDiy,room,player,ToData(data))
						room:setPlayerMark(player,"&zhengsu+-+zhengsu"..i,0)
					end
				end
			end
			local n = player:getTag("FinishPhase"):toInt()
			if n>0
			then
				if n==change.to then return true end
				if n>=change.to then return end
				player:removeTag("FinishPhase")
			end
        elseif event==sgs.EventPhaseStart
		or event==sgs.EventPhaseProceeding
		or event==sgs.EventPhaseEnd
        then
			local n = player:getTag("FinishPhase"):toInt()
			if n>0
			then
				if n==player:getPhase() then return true end
				if n>=player:getPhase() then return end
				player:removeTag("FinishPhase")
			end
 		end
		return false
    end,
}
addToSkills(OnSkillTrigger)
IsProhibited = sgs.CreateProhibitSkill{
	name = "IsProhibited",
	is_prohibited = function(self,from,to,card)
		if card:getTypeId()>0 and to
		and to:property("aiNoTo"):toBool()
		then return true end
		if card:isKindOf("EquipCard")
		then
			local ec = sgs.Sanguosha:getEngineCard(card:getEffectiveId())
			if ec:property("YingBianEffects"):toString()=="present_card"
			then return ec:getPackage()=="zhulu" end
		end
	end
}
addToSkills(IsProhibited)

--[[
extensioncard = sgs.Package("cloneCard",sgs.Package_CardPack)
for i=1,99 do
	local c = sgs.Sanguosha:cloneCard("slash",math.random(0,3),math.random(1,13))
	c:setParent(extensioncard)
end
return {extensioncard}--]]