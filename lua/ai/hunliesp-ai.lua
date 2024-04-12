--妖智
sgs.ai_skill_invoke.sgkgodyaozhi = true


--杀绝
local sgkgodshajue_skill = {}
sgkgodshajue_skill.name = "sgkgodshajue"
table.insert(sgs.ai_skills, sgkgodshajue_skill)
sgkgodshajue_skill.getTurnUseCard = function(self, inclusive)
	if self.player:hasUsed("#sgkgodshajueCard") or self.player:isKongcheng() then return end
	if #self.enemies == 0 then return end
	return sgs.Card_Parse("#sgkgodshajueCard:.:")
end

sgs.ai_skill_use_func["#sgkgodshajueCard"] = function(card, use, self)
	self:sort(self.enemies, "hp")
	local inicards = sgs.CardList()
	for _, c in sgs.qlist(self.player:getCards("h")) do
		if not self.player:isJilei(c) then
			inicards:append(c)
		end
	end
	local x = inicards:length()
	local target
	for _, enemy in ipairs(self.enemies) do
		if not (enemy:hasSkill("kongcheng")) and self.player:canSlash(enemy, nil, false) and (not self:canLiuli(enemy, self.friends_noself)) then
			if x >= enemy:getHp() then
				target = enemy
				break
			end
		end
	end
	if target then
		use.card = sgs.Card_Parse("#sgkgodshajueCard:.:")
		if use.to then use.to:append(target) end
		return
	end
end


sgs.ai_use_value["sgkgodshajueCard"] = 9.5
sgs.ai_use_priority["sgkgodshajueCard"] = 9.5
sgs.ai_card_intention["sgkgodshajueCard"] = 100


--鬼驱
sgs.ai_cardsview["sgkgodguiquPeach"] = function(self, class_name, player)
	if class_name == "Peach" then
		if player:hasSkill("sgkgodguiqu") and player:hasFlag("Global_Dying") and player:getVisibleSkillList():length() > 0 then
			return ("peach:sgkgodguiqu[no_suit:0]=.")
		end
	end
end

sgs.ai_skill_choice["sgkgodguiqu"] = function(self, choices, data)
	local room = self.room
	local skills = choices:split("+")
	local bad_skills = {"shiyong", "sk_shiyong", "longnu", "jinjiu", "sgkgodwushen", "wushen", "tongji"}  --几个与【杀】有关的负面技
	local lvbu_initial = {"sgkgodshajue", "sgkgodluocha", "sgkgodguiqu"}
	local to_lose
	for _, bad in ipairs(bad_skills) do
		if table.contains(skills, bad) then
			to_lose = bad
			break
		end
	end
	if not to_lose then
		local lvbu_extra = {}
		for _, _skill in ipairs(skills) do
			if not table.contains(lvbu_initial, _skill) then table.insert(lvbu_extra, _skill) end
		end
		if #lvbu_extra > 0 then
			to_lose = lvbu_extra[math.random(1, #lvbu_extra)]
		end
	end
	if not to_lose then
		if #skills <= 3 then
			if table.contains(skills, lvbu_initial[1]) then return lvbu_initial[1] end  --如果额外技能全丢了，优先舍弃【杀绝】
			if table.contains(skills, lvbu_initial[2]) then return lvbu_initial[2] end  --再其次，为了保命，舍弃【罗刹】
			if table.contains(skills, lvbu_initial[3]) then return lvbu_initial[3] end  --最后变成白板，舍弃【鬼驱】
		end
	end
	if to_lose then
		return to_lose
	end
	return skills[math.random(1, #skills)]
end


--函数1：判断SP神张角当前所处的“阴阳生”状态
function getYinyangState(player)
	if player:getHp() > player:getLostHp() then  --体力值大于损失体力，阳
		return "hp_Yang"
	end
	if player:getHp() == player:getLostHp() then  --体力值等于损失体力，生
		return "hp_Sheng"
	end
	if player:getHp() < player:getLostHp() then  --体力值小于损失体力，阴
		return "hp_Yin"
	end
end


--函数2：判断SP神张角自身的技能是否会因为体力上限的变化引起“阴阳生”状态变化
function canChangeYinyangState(player, add_or_lose)
	if add_or_lose == "add" then
		if getYinyangState(player) == "hp_Sheng" then  --处在“生”状态下，只要增加体力上限，必定打破平衡
			return true
		elseif getYinyangState(player) == "hp_Yang" then  --处在“阳”状态下，只有hp比lost多1时，再加1点就从“阳”变为“生”
			if player:getHp() == player:getLostHp() + 1 then return true end
		elseif getYinyangState(player) == "hp_Yin" then  --处在“阴”状态下，如果只是增加体力上限，这是无论如何都无法改变“阴阳生”状态的
			return false
		end
	elseif add_or_lose == "lose" then
		if getYinyangState(player) == "hp_Sheng" then  --处在“生”状态下，只要减少体力上限，必定打破平衡
			return true
		elseif getYinyangState(player) == "hp_Yang" then  --处在“阳”状态下，如果只是减少体力上限，这是无论如何都无法改变“阴阳生”状态的
			return false
		elseif getYinyangState(player) == "hp_Yin" then  --处在“阴”状态下，只有hp=losthp-1时，再减1点就会从“阴”变成“生”
			if player:getHp() + 1 == player:getLostHp() then return true end
		end
	end
end


--极阳
sgs.ai_skill_playerchosen.sgkgodjiyang = function(self, targets)
	local jiyang = {}
	for _, _player in sgs.qlist(targets) do
	    if self:isFriend(_player) then 
			if (not (_player:hasSkill("hunzi") and _player:getHp() == 1)) then table.insert(jiyang, _player) end
		end
	end
	self:sort(jiyang, "value")
	if #jiyang > 0 then
	    self:sort(jiyang, "value")
	    return jiyang[1]
	end
end


--极阴
sgs.ai_skill_playerchosen.sgkgodjiyin = function(self, targets)
	local jiyin = {}
	if self.player:isWounded() and (not self.player:hasSkill("jueqing")) and canChangeYinyangState(self.player, "lose") then return self.player end
	for _, _player in sgs.qlist(targets) do
	    if self:isEnemy(_player) then 
			if (not _player:hasSkills("sgkgodyinshi|sgkgodleihun")) or (_player:hasSkill("sr_weiwo") and _player:isKongcheng()) then
				table.insert(jiyin, _player)
			end
		end
	end
	self:sort(jiyin, "value")
	if #jiyin > 0 then
	    self:sort(jiyin, "value")
	    return jiyin[1]
	end
end


--定命
sgs.ai_skill_invoke.sgkgoddingming = function(self, data)
	local to = data:toPlayer()
	local x = math.abs(to:getHp() - to:getLostHp())
	--情形1：自己的准备阶段
	if self.player:getSeat() == to:getSeat() and self.player:getPhase() == sgs.Player_Start then
		--有【桃】或【酒】，想炸血卖
		if getYinyangState(self.player) == "hp_Yang" and self:getCardsNum("Peach") + self:getCardsNum("Analeptic") >= 1 then
			if x >= 2 then return true end
			--有界黄盖的【诈降】，哪怕差值只有1也卖
			if self.player:hasSkill("zhaxiang") then return true end
			--能触发夏侯霸的【豹变】也卖了
			if self.player:hasSkill("baobian") and self.player:getHp() - x <= 3 then return true end
			--如果有【英魂】/【再起】也卖
			if self.player:hasSkills("yinghun|zaiqi") and self.player:getLostHp() + x >= 2 and self.player:getHp() - x >= 0 then return true end
			--有神孙策的【冯河】，必须得卖，否则保不住手牌上限
			if self.player:hasSkill("f_pinghe") and self.player:getHp() - x >= 0 then return true end
		end
		--自己刚好状态很残
		if getYinyangState(self.player) == "hp_Yin" and x >= 2 then return true end
	end
	--情形2：伤害类
	local damage = data:toDamage()
	--分支2-1：自己受到伤害时
	if self.player:getSeat() == to:getSeat() then
		if getYinyangState(self.player) == "hp_Yin" and x >= 2 then return true end
		--特殊：自己有孙策的【魂姿】且没觉醒的时候，即使自己处在“阳”也要炸血，并且压得越多越好，先保证能觉醒
		if getYinyangState(self.player) == "hp_Yang" and self.player:getMark("@waked") == 0 and self.player:hasSkill("hunzi") then
			if self:getCardsNum("Peach") + self:getCardsNum("Analeptic") >= 1 and self.player:getHp() - x <= 1 then return true end
		end
	else
	--分支2-2：对其他角色造成伤害时
		if self:isEnemy(to) then
			if getYinyangState(to) == "hp_Yang" and not (to:hasSkill("hunzi") and to:getMark("@waked") == 0) then
				if (x >= 2 or to:getHp() - x <= 1) and self.player:getMaxHp() > 1 and canChangeYinyangState(self.player, "lose") then return true end
			end
		elseif self:isFriend(to) then
			--特例：如果这个人是没觉醒且有【魂姿】的孙策
			if getYinyangState(to) == "hp_Yang" and not (to:hasSkill("hunzi") and to:getMark("@waked") == 0) then
				if self.player:getMaxHp() > 1 and to:getLostHp() == 1 then return true end
			else
				if getYinyangState(to) == "hp_Yin" then return true end
			end
		end
	end
end


--锋影
sgs.ai_skill_playerchosen.sgkgodfengying = function(self, targets)
	if #self.enemies == 0 then return nil end
	local room = self.room
	local tos = {}
	local tslash = sgs.Sanguosha:cloneCard("thunder_slash", sgs.Card_NoSuit, 0)
	for _, p in sgs.qlist(targets) do
		if self:isEnemy(p) then
			if not sgs.Sanguosha:isProhibited(self.player, p, tslash) and self:damageIsEffective(p, sgs.DamageStruct_Thunder, self.player) then table.insert(tos, p) end
		end
	end
	if #tos > 0 then
		self:sort(tos, "defenseSlash")
		return tos[1]
	else
	    return nil
	end
	return nil
end


--止啼
sgs.ai_skill_invoke.sgkgodzhiti = function(self, data)
	local to = data:toPlayer()
	return self:isEnemy(to)
end


--止啼5选1
function evil()
	return {"mobilepojun", "tenyearzhiheng", "pingjian", "pingcai", "jieyingg", "tenyearxuanfeng", "jiwu", "sgkgodguixin", "guixin", 
	"fenyin", "qinzheng", "sgkgodluocha", "sgkgodzhitian", "sgkgodtongtian", "f_lingce", "rangjie", "chengxiang", "hengwu", "liuzhuan", 
	"chouce", "yiji", "sgkgodzhiti", "sgkgodyinyang", "fangzhu", "yuqi", "sgkgodxiejia", "gdlonghun", "f_huishi", "longhun", "sgkgodleihun", 
	"sgkgodmeixin", "sr_zhaoxiang", "jiaozi", "shanjia", "wushuang", "tenyearyiji", "sgkgodjilue"}
end
sgs.ai_skill_choice["sgkgodzhiti"] = function(self, choices, data)
	local imba = evil()
	local steal = false
	if string.find(choices, "_stealOneSkill") then
		local target = data:toPlayer()
		for _, sk in sgs.qlist(target:getVisibleSkillList()) do
			if string.find(table.concat(imba, "+"), sk:objectName()) then
				steal = true
				break
			end
		end
		if not steal then
			for _, sk in sgs.qlist(target:getVisibleSkillList()) do
				if self:isValueSkill(sk:objectName(), target, true) then
					steal = true
					break
				end
			end
		end
		if not steal then
			for _, sk in sgs.qlist(target:getVisibleSkillList()) do
				if self:isValueSkill(sk:objectName(), target) then
					steal = true
					break
				end
			end
		end
		if steal then return "spgodzl_stealOneSkill" end
	end
	local zhiti = choices:split("+")
	for i = 1, #zhiti, 1 do
		if self:isWeak() and string.find(zhiti[i], "_stealOneHpAndMaxhp") then
			return zhiti[i]
		end
		if self:isEnemy(to) and to:hasSkills(sgs.need_equip_skill .. "|" .. sgs.lose_equip_skill) and string.find(zhiti[i], "_banEquip") then
			return zhiti[i]
		end
		if self:isEnemy(to) and self:hasSkills(sgs.priority_skill, to) and string.find(zhiti[i], "_turnOver") then
			return zhiti[i]
		end
	end
	return zhiti[math.random(1, #zhiti)]
end

sgs.ai_skill_choice["zhiti_stealWhat"] = function(self, choices, data)
	local target = data:toPlayer()
	local skills = choices:split("+")
	local imba = evil()
	for _, sk in ipairs(skills) do
		if table.contains(imba, sk) then
			return sk
		end
	end
	for _, sk in ipairs(skills) do
		if self:isValueSkill(sk, target, true) then
			return sk
		end
	end
	for _, sk in ipairs(skills) do
		if self:isValueSkill(sk, target) then
			return sk
		end
	end
	local not_bad_skills = {}
	for _, sk in ipairs(skills) do
		if string.find(sgs.bad_skills, sk) then continue end
		table.insert(not_bad_skills, sk)
	end
	if #not_bad_skills > 0 then
		return not_bad_skills[math.random(1, #not_bad_skills)]
	end
	return skills[math.random(1, #skills)]
end


--劫营
sgs.ai_skill_invoke.sgkgodjieying = function(self, data)
	if #self.enemies == 0 then return nil end
	return true
end

sgs.ai_skill_playerchosen.sgkgodjieying = function(self, targets)
	local target
	for _, pe in sgs.qlist(targets) do
		if self:isEnemy(pe) and pe:hasSkills("yongsi|tenyearzhiheng|zhiheng|sgkgodluocha|zishou|xiaoji|haoshi|mou_yingzi|yingzi|sgkgodguixin|fenyin|pingcai|tenyearfenyin") then
			target = pe
			break
		end
	end
	if not target then
		for _, pe in sgs.qlist(targets) do
			if self:isEnemy(pe) and pe:hasSkills("sgkgodyinyang|sgkgodjiyang|sgkgodxiangsheng|sgkgodyaozhi|sgkgodzhitian|sy_mingzheng|hunzi|zhiji|wuji|zhengnan|tenyearzhengnan|sgkgodzhiti") then
				target = pe
				break
			end
		end
	end
	if not target then
		local es = {}
		for _, pe in sgs.qlist(targets) do
			if self:isEnemy(pe) then table.insert(es, pe) end
		end
		self:sort(es, "chaofeng")
		target = es[1]
	end
	return target
end