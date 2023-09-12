-- This is the Smart AI,and it should be loaded and run at the server side

-- "middleclass" is the Lua OOP library written by kikito
-- more information see: https://github.com/kikito/middleclass
middleclass = require "middleclass"

-- initialize the random seed for later use
math.randomseed(os.time())

-- SmartAI is the base class for all other specialized AI classes
SmartAI = middleclass.class("SmartAI")

version = "QSanguosha AI 20141006 (V1.32 Alpha)"

-- checkout https://github.com/haveatry823/QSanguoshaAI for details

--- this function is only function that exposed to the host program
--- and it clones an AI instance by general name
-- @param player The ServerPlayer object that want to create the AI object
-- @return The AI object
function CloneAI(player)
	return SmartAI(player).lua_ai
end

sgs.ais = {}
sgs.ai_role = {}
sgs.roleValue = {}
sgs.ai_card_intention = {}
sgs.ai_playerchosen_intention = {}
sgs.ai_Yiji_intention = {}
sgs.ai_retrial_intention = {}
sgs.ai_keep_value = {}
sgs.ai_use_value = {}
sgs.ai_use_priority = {}
sgs.ai_suit_priority = {}
sgs.ai_chaofeng = {}
sgs.ai_global_flags = {}
sgs.ai_skill_invoke = {}
sgs.ai_skill_suit = {}
sgs.ai_skill_cardask = {}
sgs.ai_skill_choice = {}
sgs.ai_skill_askforag = {}
sgs.ai_skill_askforyiji = {}
sgs.ai_skill_pindian = {}
sgs.ai_filterskill_filter = {}
sgs.ai_skill_playerchosen = {}
sgs.ai_skill_discard = {}
sgs.ai_cardshow = {}
sgs.ai_nullification = {}
sgs.ai_skill_cardchosen = {}
sgs.ai_skill_use = {}
sgs.ai_cardneed = {}
sgs.ai_skill_use_func = {}
sgs.ai_skills = {}
sgs.ai_slash_weaponfilter = {}
sgs.ai_slash_prohibit = {}
sgs.ai_view_as = {}
sgs.ai_cardsview = {}
sgs.ai_cardsview_valuable = {}
sgs.dynamic_value = {
	damage_card = {},
	control_usecard = {},
	control_card = {},
	lucky_chance = {},
	benefit = {}
}
sgs.ai_choicemade_filter = {
	cardUsed = {},
	cardResponded = {},
	skillInvoke = {},
	skillChoice = {},
	Nullification = {},
	playerChosen = {},
	cardChosen = {},
	Yiji = {},
	viewCards = {},
	pindian = {}
}
sgs.card_lack = {}
sgs.ai_need_damaged = {}
sgs.ai_debug_func = {}
sgs.ai_chat_func = {}
sgs.ai_event_callback = {}
sgs.ai_NeedPeach = {}
sgs.ai_damage_effect = {}
sgs.ai_judgeGood = {}
sgs.ai_need_retrial_func = {}
sgs.ai_use_revises = {}
sgs.ai_guhuo_card = {}
sgs.ai_target_revises = {}
sgs.ai_useto_revises = {}
sgs.ai_skill_defense = {}
sgs.card_value = {}
sgs.ai_card_priority = {}
sgs.ai_poison_card = {}
sgs.ai_skill_playerschosen = {}
sgs.ai_used_revises = {}
sgs.weapon_range = {}


for i = sgs.NonTrigger, sgs.NumOfEvents do
	sgs.ai_debug_func[i]     = {}
	sgs.ai_chat_func[i]      = {}
	sgs.ai_event_callback[i] = {}
end

function setInitialTables()
	sgs.playerRoles = { lord = 0, loyalist = 0, rebel = 0, renegade = 0 }

	sgs.ai_type_name = { "SkillCard", "BasicCard", "TrickCard", "EquipCard" }

	sgs.lose_equip_skill = "kofxiaoji|xiaoji|xuanfeng|nosxuanfeng|tenyearxuanfeng|mobilexuanfeng"

	sgs.need_kongcheng = "lianying|noslianying|kongcheng|sijian|hengzheng"

	sgs.masochism_skill = "guixin|yiji|fankui|jieming|xuehen|neoganglie|ganglie|vsganglie|enyuan|" ..
		"fangzhu|nosenyuan|langgu|quanji|zhiyu|renjie|tanlan|tongxin|huashen|duodao|chengxiang|benyu"

	sgs.wizard_skill = "nosguicai|guicai|guidao|olguidao|jilve|tiandu|luoying|noszhenlie|huanshi|jinshenpin" ..
		"|LuaGuizha|luaguidao" --add
	sgs.wizard_harm_skill = "nosguicai|guicai|guidao|olguidao|jilve|jinshenpin|midao|zhenyi" ..
		"|LuaGuizha|luaguidao" --add
	sgs.priority_skill = "dimeng|haoshi|qingnang|nosjizhi|jizhi|guzheng|qixi|jieyin|guose|duanliang|jujian|fanjian|" ..
		"neofanjian|lijian|noslijian|manjuan|tuxi|qiaobian|yongsi|zhiheng|luoshen|nosrende|rende|" ..
		"mingce|wansha|gongxin|jilve|anxu|qice|yinling|qingcheng|houyuan|zhaoxin|shuangren|zhaxiang|" ..
		"xiansi|junxing|bifa|yanyu|shenxian|jgtianyun" ..
		"|luamouce|eqiehu" --add

	sgs.save_skill = "jijiu|buyi|nosjiefan|chunlao|tenyearchunlao|secondtenyearchunlao|longhun|newlonghun"

	sgs.exclusive_skill = "huilei|duanchang|wuhun|buqu|dushi" ..
		"|meizlrangma|meizlhunshi|meizlyuanshi|meizlliyi" --add

	sgs.dont_kongcheng_skill = "yuce|tanlan|toudu|qiaobian|jieyuan|anxian|liuli|chongzhen|tianxiang|tenyeartianxiang|" ..
		"oltianxiang|guhuo|nosguhuo|olguhuo|leiji|nosleiji|olleiji|qingguo|yajiao|chouhai|tenyearchouhai|" ..
		"nosrenxin|taoluan|tenyeartaoluan|huisheng|zhendu|newzhendu|kongsheng|zhuandui|longhun|" ..
		"newlonghun|fanghun|olfanghun|mobilefanghun|zhenshan|jijiu|daigong|yinshicai" ..
		"|s4_cloud_tuxi|luafan|meizlcimin" --add

	sgs.Active_cardneed_skill = "paoxiao|tenyearpaoxiao|olpaoxiao|tianyi|xianzhen|shuangxiong|nosjizhi|jizhi|guose|" ..
		"duanliang|qixi|qingnang|luoyi|guhuo|nosguhuo|jieyin|zhiheng|rende|nosrende|nosjujian|luanji|" ..
		"qiaobian|lirang|mingce|fuhun|spzhenwei|nosfuhun|nosluoyi|yinbing|jieyue|sanyao|xinzhan" ..
		"|luaxiongfeng|eqiehu" --add

	sgs.notActive_cardneed_skill = "kanpo|guicai|guidao|beige|xiaoguo|liuli|tianxiang|jijiu|leiji|nosleiji" ..
		"qingjian|zhuhai|qinxue|jspdanqi|" .. sgs.dont_kongcheng_skill ..
		"|LuaGuizha|luaguidao" --add

	sgs.cardneed_skill = sgs.Active_cardneed_skill .. "|" .. sgs.notActive_cardneed_skill

	sgs.drawpeach_skill = "tuxi|qiaobian" ..
		"|duYinling|luajiejiang" --add

	sgs.recover_hp_skill = "nosrende|rende|tenyearrende|kofkuanggu|kuanggu|tenyearkuanggu|zaiqi|mobilezaiqi|jieyin|" ..
		"qingnang|shenzhi|longhun|newlonghun|ytchengxiang|quji|dev_zhiyu|dev_pinghe|dev_qiliao|dev_saodong" ..
		"|meizlchongyuan|etushou" --add

	sgs.recover_skill = "yinghun|hunzi|nosmiji|zishou|newzishou|olzishou|tenyearzishou|ganlu|xueji|shangshi|nosshangshi|" ..
		"buqu|miji|" .. sgs.recover_hp_skill

	sgs.use_lion_skill = "longhun|newlonghun|duanliang|qixi|guidao|noslijian|lijian|jujian|nosjujian|zhiheng|mingce|" ..
		"yongsi|fenxun|gongqi|yinling|jilve|qingcheng|neoluoyi|diyyicong" ..
		"|LuaGuizha|luaguidao|eqiehu" --add


	sgs.need_equip_skill = "shensu|tenyearshensu|mingce|jujian|beige|yuanhu|huyuan|gongqi|nosgongqi|yanzheng|qingcheng|" ..
		"neoluoyi|longhun|newlonghun|shuijian|yinbing" ..
		"|meizljinguo" --add

	sgs.judge_reason = "bazhen|EightDiagram|wuhun|supply_shortage|tuntian|nosqianxi|nosmiji|indulgence|lightning|baonue" ..
		"|nosleiji|leiji|caizhaoji_hujia|tieji|luoshen|ganglie|neoganglie|vsganglie|kofkuanggu"

	sgs.straight_damage_skill = "qiangxi|nosxuanfeng|duwu|danshou"

	sgs.double_slash_skill =
		"paoxiao|tenyearpaoxiao|olpaoxiao|fuhun|tianyi|xianzhen|zhaxiang|lihuo|jiangchi|shuangxiong|" ..
		"qiangwu|luanji" ..
		"|luajuao|s4_xianfeng|luazhenshe|blood_hj" --add

	sgs.need_maxhp_skill = "yingzi|zaiqi|yinghun|hunzi|juejing|ganlu|zishou|miji|chizhong|xueji|quji|xuehen|shude|" ..
		"neojushou|tannang|fangzhu|nosshangshi|nosmiji|yisuan|xuhe" ..
		"|eweicheng|echinei" --add

	sgs.bad_skills = "benghuai|wumou|shiyong|yaowu|zaoyao|chanyuan|chouhai|tenyearchouhai|lianhuo|ranshang" ..
		"du_jiyu|meizlhunshidistance|meizlkuijiu" --add

	sgs.hit_skill = "wushuang|fuqi|tenyearfuqi|zhuandui|tieji|nostieji|dahe|olqianxi|qianxi|tenyearjianchu|oljianchu|" ..
		"wenji|tenyearbenxi|mobileliyong|olwushen|tenyearliegong|liegong|kofliegong|tenyearqingxi|wanglie|" ..
		"conqueror|zhaxiang|tenyearyijue|yijue|xiongluan|xiying|"

	sgs.Friend_All = 0
	sgs.Friend_Draw = 1
	sgs.Friend_Male = 2
	sgs.Friend_Female = 3
	sgs.Friend_Wounded = 4
	sgs.Friend_MaleWounded = 5
	sgs.Friend_FemaleWounded = 6
	sgs.Friend_Weak = 7
end

function SmartAI:initialize(player)
	self.player = player
	self.room = player:getRoom()
	self.role = player:getRole()
	self.lua_ai = sgs.LuaAI(player)
	self.lua_ai.callback = function(full_method_name, ...)
		local method_name = 1
		while true do
			local found = string.find(full_method_name, "::", method_name)
			if type(found) == "number" then method_name = found + 2 else break end
		end
		method_name = string.sub(full_method_name, method_name)
		local method = self[method_name]
		if method then
			local success, result1, result2 = pcall(method, self, ...)
			if success then
				return result1, result2
			else
				self.room:writeToConsole(method_name)
				self.room:writeToConsole(result1)
				self.room:outputEventStack()
			end
		end
	end
	self.toUse = {}
	self.keepdata = {}
	self.keepValue = {}
	self.harsh_retain = true
	self.disabled_ids = sgs.IntList()
	if sgs.initialized ~= true
	then
		sgs.ais = {}
		sgs.drawData = {}
		sgs.turncount = 0
		sgs.throwData = {}
		sgs.damageData = {}
		sgs.convertData = {}
		sgs.recoverData = {}
		sgs.debugmode = false
		sgs.initialized = true
		global_room = self.room
		sgs.getMode = self.room:getMode()
		sgs.delay = sgs.GetConfig("OriginAIDelay", 0)
		self.room:writeToConsole(version .. ",Powered by " .. _VERSION)
		setInitialTables()
		for on, ap in sgs.qlist(self.room:getAllPlayers()) do
			on = ap:objectName()
			sgs.ai_role[on] = "neutral"
			sgs.roleValue[on] = { lord = 0, loyalist = 0, rebel = 0, renegade = 0 }
			sgs.roleValue[on][ap:getRole()] = 0
			if ap:getRole() == "lord"
			then
				sgs.roleValue[on]["lord"] = 99999
				sgs.roleValue[on]["loyalist"] = 65535
				sgs.ai_role[on] = "loyalist"
			elseif isRolePredictable()
			then
				if ap:getRole() == "renegade" then sgs.explicit_renegade = true end
				sgs.roleValue[on][ap:getRole()] = 65535
				sgs.ai_role[on] = ap:getRole()
			end
		end
	end
	sgs.ais[player:objectName()] = self
	sgs.card_lack[player:objectName()] = {}
	sgs.card_lack[player:objectName()]["Slash"] = 0
	sgs.card_lack[player:objectName()]["Jink"] = 0
	sgs.card_lack[player:objectName()]["Peach"] = 0
	sgs.ai_NeedPeach[player:objectName()] = 0
	self:updatePlayers()
	self:assignKeep(true)
end

function sgs.getPlayerSkillList(player)
	local skills = {}
	for _, skill in sgs.qlist(player:getSkillList(true)) do
		if skill:isLordSkill()
		then
			if player:hasLordSkill(skill) then table.insert(skills, skill) end
		else
			table.insert(skills, skill)
		end
	end
	if player:hasSkill("weidi")
	then
		local gl = global_room:getLord()
		if gl and gl ~= player
		then
			for _, skill in sgs.qlist(gl:getSkillList()) do
				if skill:isLordSkill() then table.insert(skills, skill) end
			end
		end
	end
	return skills
end

function sgs.getCardNumAtCertainPlace(card, place)
	local num = 0
	if card and card:isVirtualCard()
	then
		for _, id in sgs.qlist(card:getSubcards()) do
			if global_room:getCardPlace(id) == place
			then
				num = num + 1
			end
		end
		return num
	elseif place == sgs.Player_PlaceHand
	then
		return 1
	end
	return num
end

function sgs.getValue(player)
	return type(player) == "userdata" and player:getHp() * 2 + player:getHandcardNum() or 0
end

function sgs.getDefense(player) --回避值
	if type(player) ~= "userdata" then return 0 end
	local current_player = global_room:getCurrent()
	if type(current_player) ~= "userdata" then return sgs.getValue(player) end
	local defense = player:getHp() * 2 + player:getHandcardNum() + player:getHandPile():length()
	local function gdt(di)
		di = di:split(",")
		local n = 0
		for _, x in ipairs(di) do
			if x ~= "" then n = n + x end
		end
		return n / #di
	end
	local drawData = {}
	local dt = io.open("lua/ai/data/drawData", "r")
	if dt
	then
		for _, st in ipairs(dt:read("*all"):split("\n")) do
			if st:match(":")
			then
				st = st:split(":")
				drawData[st[1]] = gdt(st[2])
			end
		end
		dt:close()
	end
	local damageData = {}
	dt = io.open("lua/ai/data/damageData", "r")
	if dt
	then
		for _, st in ipairs(dt:read("*all"):split("\n")) do
			if st:match(":")
			then
				st = st:split(":")
				damageData[st[1]] = gdt(st[2])
			end
		end
		dt:close()
	end
	local throwData = {}
	dt = io.open("lua/ai/data/throwData", "r")
	if dt
	then
		for _, st in ipairs(dt:read("*all"):split("\n")) do
			if st:match(":")
			then
				st = st:split(":")
				throwData[st[1]] = gdt(st[2])
			end
		end
		dt:close()
	end
	for invoke, ac in ipairs(aiConnect(player)) do
		invoke = sgs.ai_skill_defense[ac]
		if type(invoke) == "function"
		then
			invoke = invoke(current_self, player)
			if type(invoke) == "number" then defense = defense + invoke end
		elseif type(invoke) == "number" then
			defense = defense + invoke
		end
		invoke = drawData[ac]
		if type(invoke) == "number"
		then
			defense = defense + invoke
		end
		invoke = damageData[ac]
		if type(invoke) == "number"
		then
			defense = defense - invoke
		end
		invoke = throwData[ac]
		if type(invoke) == "number"
		then
			defense = defense - invoke
		end
	end
	if player:hasArmorEffect("eight_diagram")
		or (player:hasSkill("bazhen") and not player:getArmor())
	then
		if player:hasSkill("tiandu") then defense = defense + 1 end
		if player:hasSkill("gushou") then defense = defense + 1 end
		if player:hasSkill("nosleiji") then defense = defense + 2 end
		if player:hasSkill("leiji") then defense = defense + 2 end
		if player:hasSkill("olleiji") then defense = defense + 2 end
		if player:hasSkill("noszhenlie") then defense = defense + 1 end
		if player:hasSkill("hongyan") then defense = defense + 2 end
	end
	for _, masochism in sgs.list(sgs.masochism_skill:split("|")) do
		if player:hasSkill(masochism) and current_self:isGoodHp(player)
		then
			defense = defense + 1
		end
	end
	if player:hasSkill("guixin") then defense = defense + player:aliveCount() - 1 end
	if player:hasSkill("yuce") then defense = defense + 2 end
	if player:getMark("@tied") > 0 then defense = defense + 1 end
	if player:hasSkill("chengxiang") then defense = defense + 2 end
	if player:hasLordSkill("shichou") and player:getMark("xhate") > 0
	then
		for _, p in sgs.qlist(player:getAliveSiblings()) do
			if p:getMark("hate_" .. player:objectName()) > 0 and p:getMark("@hate_to") > 0
			then
				defense = defense + p:getHp()
				break
			end
		end
	end
	if player:hasSkill("nosrende") and player:getHp() > 2
		and player:getHandcardNum() > 1 then
		defense = defense + 1
	end
	if player:hasSkill("rende") and player:getHp() > 2
		and player:getHandcardNum() > 1 then
		defense = defense + 1
	end
	if player:hasSkill("kuanggu") and player:getHp() > 1
	then
		defense = defense + 0.5
	end
	if player:hasSkill("kofkuanggu") and player:getHp() > 1
	then
		defense = defense + 1
	end
	if player:hasSkill("zaiqi") and player:getHp() > 1
	then
		defense = defense + player:getLostHp() * 0.5
	end
	if player:hasSkill("aocai")
		and player:getPhase() == sgs.Player_NotActive
	then
		defense = defense + 0.5
	end
	if player:hasSkill("wanrong")
		and not hasManjuanEffect(player)
	then
		defense = defense + 0.5
	end
	if player:hasSkill("tianxiang")
	then
		defense = defense + player:getHandcardNum() * 0.5
	end
	if player:getHp() > getBestHp(player) then defense = defense + 0.8 end
	if player:getHp() <= 2 then defense = defense - 0.4 end
	if isLord(player)
	then
		defense = defense - 0.4
		if sgs.isLordInDanger()
		then
			defense = defense - 0.7
		end
	end
	if player:getMark("@skill_invalidity") > 0 then defense = defense - 5 end
	if not player:faceUp() then defense = defense - 1 end
	if player:hasSkill("qianhuan")
	then
		defense = defense + 2 + player:getPile("sorcery"):length()
	end
	if player:hasSkill("qingnang")
	then
		defense = defense + 2
	end
	if player:hasSkill("guzheng")
	then
		defense = defense + 2.5
	end
	if player:hasSkill("qiaobian")
	then
		defense = defense + 2.4
	end
	if player:hasSkill("jieyin")
	then
		defense = defense + 2.3
	end
	if player:hasSkill("xiliang")
	then
		defense = defense + 2
	end
	if player:hasSkill("guhuo")
	then
		for _, p in sgs.qlist(player:getAliveSiblings()) do
			if p:hasSkill("chanyuan") then defense = defense + 1 end
		end
	end
	if player:hasSkill("yishe") then defense = defense + 2 end
	if player:hasSkill("paiyi") then defense = defense + 1.5 end
	if player:hasSkill("yongsi") then defense = defense + 2 end
	defense = defense + (player:aliveCount() - (player:getSeat() - current_player:getSeat()) % player:aliveCount()) / 4
	defense = defense + player:getVisibleSkillList(true):length() * 0.25
	return defense
end

function SmartAI:assignKeep(start)
	if start
	then
		self.keepdata = {}
		for k, v in pairs(sgs.ai_keep_value) do
			self.keepdata[k] = v
		end
		for _, askill in ipairs(sgs.getPlayerSkillList(self.player)) do
			askill = sgs[askill:objectName() .. "_keep_value"]
			if askill
			then
				for k, v in pairs(askill) do
					self.keepdata[k] = v
				end
			end
		end
	end
	if sgs.turncount <= 1 or #self.enemies < 1
	then
		self.keepdata.Jink = 4.2
	end
	if self.player:getHandcardNum() >= 4
		or not self:isWeak()
	then
		for _, f in ipairs(self.friends_noself) do
			if self:willSkipDrawPhase(f) or self:willSkipPlayPhase(f)
			then
				self.keepdata.Nullification = 5.5
				break
			end
		end
	end
	if self:getOverflow(nil, true) == 1
	then
		self.keepdata.Analeptic = (self.keepdata.Jink or 5.2) + 0.1
		-- 特殊情况下还是要留闪，待补充...
	end
	if self:isWeak()
	then
		if self:hasSkills("buyi", self.friends)
		then
			self.keepdata.Peach = 10
			self.keepdata.TrickCard = 8
			self.keepdata.EquipCard = 7.9
		end

		--add
		if self:hasSkills("meizlzhuanchong", self.friends)
		then
			self.keepdata.Peach = 10
			self.keepdata.EquipCard = 7.9
		end
	else
		if self.player:getHp() > getBestHp(self.player)
			or not self:isGoodTarget(self.player, self.friends)
			or self:needToLoseHp()
		then
			self.keepdata.ThunderSlash = 5.2
			self.keepdata.FireSlash = 5.1
			self.keepdata.Slash = 5
			self.keepdata.Jink = 4.5
		end
	end
	for _, enemy in ipairs(self.enemies) do
		if enemy:hasSkill("nosqianxi")
			and enemy:distanceTo(self.player) == 1
		then
			self.keepdata.Jink = 6
		end
	end
	local kept = {}
	self.keepValue = {}
	for _, c in sgs.qlist(self.player:getCards("he")) do
		self.keepValue[c:getEffectiveId()] = self:getKeepValue(c, kept, true)
	end
	local cards = self:sortByKeepValue(self.player:getHandcards())
	while #cards > 0 do
		local sc = cards[#cards]
		self.keepValue[sc:getEffectiveId()] = self:getKeepValue(sc, kept)
		table.insert(kept, sc)
		table.removeOne(cards, sc)
	end
end

function SmartAI:getKeepValue(card, kept, writeMode)
	if type(card) ~= "userdata" then return 0 end
	if type(kept) ~= "table"
	then
		return self.keepValue[card:getEffectiveId()] or self.keepdata[card:getClassName()] or
			sgs.ai_keep_value[card:getClassName()] or 0
	end
	local owner = self.room:getCardOwner(card:getEffectiveId()) or self.player
	local n, place, class = 0, self.room:getCardPlace(card:getEffectiveId()), card:getClassName()
	local maxvalue = self.keepdata[card:getClassName()] or sgs.ai_keep_value[card:getClassName()] or 0
	for k, v in pairs(self.keepdata) do
		if v > maxvalue and isCard(k, card, owner)
		then
			maxvalue = v
			class = k
		end
	end
	if writeMode
	then
		if place == sgs.Player_PlaceEquip
		then
			if card:isKindOf("Armor")
				and self:needToThrowArmor() then
				return -10
			elseif owner:hasSkills(sgs.lose_equip_skill)
			then
				if card:isKindOf("OffensiveHorse") then
					return -10
				elseif card:isKindOf("Weapon") then
					return -9.9
				else
					return -9.7
				end
			elseif owner:hasSkills("bazhen|yizhong")
				and card:isKindOf("Armor") then
				return -8
			elseif self:needKongcheng() then
				return 5.0
			end
			if card:isKindOf("Armor")
			then
				n = self:isWeak() and 5.2 or 3.2
			elseif card:isKindOf("DefensiveHorse")
			then
				n = self:isWeak() and 4.3 or 3.19
			elseif card:isKindOf("OffensiveHorse")
			then
				n = 3.17
			elseif card:isKindOf("Weapon")
			then
				n = owner:getPhase() <= sgs.Player_Play and self:slashIsAvailable() and 3.39 or 3.2
			elseif card:isKindOf("WoodenOx")
			then
				n = owner:getPile("wooden_ox"):length() * 1.8
			else
				n = 3.18
			end
			if class ~= card:getClassName()
			then
				n = n + maxvalue
			end
			return n
		elseif place == sgs.Player_PlaceHand
		then
			local si, ni, ci, vs, vn = 0, 0, 0, 0, 0
			for x, askill in sgs.qlist(owner:getVisibleSkillList(true)) do
				x = sgs[askill:objectName() .. "_suit_value"]
				if x
				then
					x = x[card:getSuitString()]
					if type(x) == "number"
					then
						si = si + 1
						vs = vs + x
					end
				end
				x = sgs[askill:objectName() .. "_number_value"]
				if x
				then
					x = x[card:getNumberString()]
					if type(x) == "number"
					then
						ni = ni + 1
						vn = vn + x
					end
				end
				x = sgs.card_value[askill:objectName()]
				if type(x) == "table"
				then
					ci = ci + 1
					cv = x[card:getSuitString()]
					if type(cv) == "number" then n = n + cv end
					cv = x[card:getNumberString()]
					if type(cv) == "number" then n = n + cv end
					cv = x[card:getClassName()]
					if type(cv) == "number" then n = n + cv end
					cv = x[card:objectName()]
					if type(cv) == "number" then n = n + cv end
					cv = x[card:getColorString()]
					if type(cv) == "number" then n = n + cv end
					cv = x[card:getType()]
					if type(cv) == "number" then n = n + cv end
				end
			end
			if ci > 0 then n = n / ci end
			if si > 0 then vs = vs / si end
			if ni > 0 then vn = vn / ni end
			n = n + maxvalue + vs + vn
			if class ~= card:getClassName() then n = n + 0.1 end
			return self:adjustKeepValue(card, n)
		end
	end
	n = self.keepValue[card:getEffectiveId()] or self.keepdata[class] or sgs.ai_keep_value[class] or 0
	if place == sgs.Player_PlaceHand
	then
		place = 0
		for _, kc in ipairs(kept) do
			if isCard(class, kc, owner)
			then
				n = n - 1.2 - place
				place = place + 0.1
			elseif kc:isKindOf("Slash")
				and card:isKindOf("Slash")
			then
				n = n - 1.2 - place
				place = place + 0.1
			end
		end
	end
	return n
end

function SmartAI:adjustKeepValue(card, v)
	local suits = { "club", "spade", "diamond", "heart" }
	local owner = self.room:getCardOwner(card:getEffectiveId()) or self.player
	for _, askill in sgs.qlist(owner:getVisibleSkillList(true)) do
		askill = sgs.ai_suit_priority[askill:objectName()]
		if type(askill) == "function"
		then
			suits = askill(self, card):split("|")
			break
		elseif type(askill) == "string"
		then
			suits = askill:split("|")
			break
		end
	end
	table.insert(suits, "no_suit")
	if card:isKindOf("Slash")
	then
		if card:isRed() then v = v + 0.002 end
		if card:isKindOf("NatureSlash") then v = v + 0.003 end
		if owner:hasSkill("jiang") and card:isRed() then v = v + 0.004 end
		if owner:hasSkills("wushen|olwushen") and card:getSuit() == sgs.Card_Heart then v = v + 0.003 end
		if owner:hasSkills("jinjiu|mobilejinjiu") and card:getEffectiveId() >= 0 and sgs.Sanguosha:getEngineCard(card:getEffectiveId()):isKindOf("Analeptic") then
			v =
				v - 0.002
		end
	end
	local suits_value = owner:getPileName(card:getEffectiveId())
	if suits_value == "wooden_ox" or suits_value:match("&")
	then
		v = v - 0.1
	end
	suits_value = {}
	for index, suit in sgs.list(suits) do
		suits_value[suit] = index
	end
	v = v + (suits_value[card:getSuitString()] or 0) / 100
	v = v + card:getNumber() / 100
	return v
end

function SmartAI:getUseValue(card)
	if type(card) ~= "userdata" then return 0 end
	local v = sgs.ai_use_value[card:getClassName()] or 0
	if card:isKindOf("LuaSkillCard")
	then
		v = sgs.ai_use_value[card:objectName()] or v
	elseif card:isKindOf("EquipCard")
	then
		if self.player:hasEquip(card)
		then
			if card:isKindOf("OffensiveHorse")
				and self.player:getAttackRange() > 2
			then
				return 5.5
			end
			if card:isKindOf("DefensiveHorse")
				and self:hasEightDiagramEffect()
			then
				return 5.5
			end
			return 9
		end
		if not self:getSameEquip(card) then v = 6.7 end
		if card:isKindOf("Weapon")
			and table.contains(self.toUse, card)
		then
			v = 2
		end
		if self.role == "loyalist"
			and self.player:getKingdom() == "wei"
			and not self.player:hasSkill("bazhen")
			and getLord(self.player):hasLordSkill("hujia")
			and card:isKindOf("EightDiagram")
		then
			v = 9
		end
		if self.player:hasSkills(sgs.lose_equip_skill)
		then
			return 10
		end
	elseif card:isKindOf("BasicCard")
	then
		if card:isKindOf("Slash")
		then
			if self.player:hasFlag("TianyiSuccess")
				or self.player:hasFlag("JiangchiInvoke")
			then
				v = 8.7
			end
			if self.player:getPhase() == sgs.Player_Play
				and self:slashIsAvailable() and #self.enemies > 0
				and self:getCardsNum("Slash") == 1
			then
				v = v + 5
			end
			if self:hasCrossbowEffect()
			then
				v = v + 4
			end
		elseif card:isKindOf("Jink")
		then
			if self:getCardsNum("Jink") > 1
			then
				v = v - 6
			end
		elseif card:isKindOf("Peach")
		then
			if self.player:isWounded()
			then
				v = v + 6
			end
		end
	elseif card:isKindOf("TrickCard")
	then
		if self.player:getWeapon()
			and not self.player:hasSkills(sgs.lose_equip_skill)
			and card:isKindOf("Collateral") then
			v = 2
		end
		if card:isKindOf("Duel") then v = v + self:getCardsNum("Slash") * 2 end
	end
	if self:hasSkills(sgs.need_kongcheng)
		and self.player:isLastHandCard(card) then
		v = v + 9
	end
	if self.player:getPhase() <= sgs.Player_Play
	then
		self.useValue = true
		v = self:adjustUsePriority(card, v)
		self.useValue = false
	end
	return v
end

function SmartAI:getUsePriority(card)
	if type(card) ~= "userdata" then return 0 end
	local upv = sgs.ai_use_priority[card:getClassName()] or 0
	if card:isKindOf("EquipCard")
	then
		if self.player:hasSkills(sgs.lose_equip_skill) then upv = upv + 8 end
		if self:getSameEquip(card) then
		elseif card:isKindOf("Weapon") then
			upv = upv + 1
		elseif card:isKindOf("Armor") then
			upv = upv + 2.2
		elseif card:isKindOf("DefensiveHorse") then
			upv = upv + 2.8
		elseif card:isKindOf("OffensiveHorse") then
			upv = upv + 2.5
		end
		return upv
	elseif card:isKindOf("LuaSkillCard")
	then
		upv = sgs.ai_use_priority[card:objectName()] or upv
	end
	return self:adjustUsePriority(card, upv)
end

function SmartAI:adjustUsePriority(card, v)
	if card:getTypeId() < 1 then return v end
	local suits_value, suits = nil, { "club", "spade", "diamond", "heart" }
	for cb, s in ipairs(sgs.getPlayerSkillList(self.player)) do
		cb = sgs.ai_card_priority[s]
		if type(cb) == "table"
		then
			cb = cb[card:getSuitString()]
			if type(cb) == "number" then v = v + cb end
			cb = cb[card:getNumberString()]
			if type(cb) == "number" then v = v + cb end
			cb = cb[card:getClassName()]
			if type(cb) == "number" then v = v + cb end
			cb = cb[card:objectName()]
			if type(cb) == "number" then v = v + cb end
			cb = cb[card:getColorString()]
			if type(cb) == "number" then v = v + cb end
			cb = cb[card:getSkillName()]
			if type(cb) == "number" then v = v + cb end
		elseif type(cb) == "function"
		then
			cb = cb(self, card, v)
			if type(cb) == "number" then v = v + cb end
		end
		if suits_value then continue end
		cb = sgs.ai_suit_priority[s]
		if type(cb) == "function"
		then
			suits_value = true
			suits = cb(self, card):split("|")
		elseif type(cb) == "string"
		then
			suits_value = true
			suits = cb:split("|")
		end
	end
	table.insert(suits, "no_suit")
	suits_value = self.player:getPileName(card:getEffectiveId())
	if suits_value == "wooden_ox" or suits_value:match("&") then v = v + 0.2 end
	v = v - math.min(sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, card) * 0.2, 2)
	if card:isVirtualCard() then v = v - card:subcardsLength() * 0.15 end
	suits_value = {}
	for i, suit in ipairs(suits) do
		suits_value[suit] = -i
	end
	v = v + (suits_value[card:getSuitString()] or 0) / 100
	v = v + (13 - card:getNumber()) / 100
	return v
end

function SmartAI:getDynamicUsePriority(card)
	if type(card) ~= "userdata" then return 0 end
	if card:hasFlag("AIGlobal_KillOff") then
		return 15
	elseif card:isKindOf("DelayedTrick") and #card:getSkillName() > 0
	then
		return (sgs.ai_use_priority[card:getClassName()] or 0.1) - 0.1
	elseif card:isKindOf("Duel")
	then
		if self:hasCrossbowEffect()
			or self.player:hasUsed("FenxunCard")
			or self.player:canSlashWithoutCrossbow()
			or self.player:hasFlag("XianzhenSuccess")
		then
			return sgs.ai_use_priority.Slash - 0.1
		end
	end
	local value = self:getUsePriority(card)
	if card:isKindOf("Weapon") and #self.enemies > 0
		and self.player:getPhase() <= sgs.Player_Play
	then
		self:sort(self.enemies)
		local vw, inAttackRange = self:evaluateWeapon(card, self.player, self.enemies[1]) / 20
		if inAttackRange then value = value + 0.5 end
		value = value + string.format("%3.3f", vw)
	elseif card:isKindOf("AmazingGrace")
	then
		local dv = 10
		for _, p in sgs.qlist(self.player:getAliveSiblings()) do
			dv = dv - 1
			if self:isEnemy(p) then
				dv = dv - ((p:getHandcardNum() + p:getHp()) / p:getHp()) * dv
			else
				dv = dv + ((p:getHandcardNum() + p:getHp()) / p:getHp()) * dv
			end
		end
		value = value + dv
	end
	return value
end

function SmartAI:cardNeed(card)
	if type(card) ~= "userdata" then return 0 end
	local value = self:getUseValue(card)
	if isCard("Peach", card, self.player)
	then
		self:sort(self.friends, "hp")
		if self.friends[1]:getHp() < 2 then value = value + 4 end
		if (self.player:getHp() < 3 or self.player:getLostHp() > 1 and self:isWeak())
			or self.player:hasSkills("kurou|benghuai") then
			value = value + 6
		end
	end
	if self:hasSkills("buyi", self.friends) and card:getTypeId() > 1
	then
		if (self.player:getHp() < 3 or self.player:getLostHp() > 1 and self:isWeak())
			or self.player:hasSkills("kurou|benghuai") then
			value = value + 5
		end
	end
	local i = 0
	for v, askill in sgs.qlist(self.player:getVisibleSkillList(true)) do
		v = sgs[askill:objectName() .. "_keep_value"]
		if type(v) == "table"
		then
			v = v[card:getClassName()]
			if type(v) == "number"
			then
				i = i + 1
				value = value + v / i
			end
		end
		v = sgs[askill:objectName() .. "_suit_value"]
		if type(v) == "table"
		then
			v = v[card:getSuitString()]
			if type(v) == "number"
			then
				i = i + 1
				value = value + v / i
			end
		end
	end
	if card:getTypeId() < 3 then value = (2 / math.max(1, self:getCardsNum(card:getClassName()))) * value end
	if self:isWeak() and isCard("Jink,Analeptic", card, self.player) then
		value = value + 5
	elseif isCard("Slash", card, self.player)
		and (self:hasCrossbowEffect() or self:getCardsNum("Crossbow") > 0)
	then
		value = value + 3
	elseif card:isKindOf("Crossbow")
		and self.player:hasSkills("luoshen|yongsi|kurou|keji|wusheng|tenyearwusheng|wushen|olwushen|chixin")
	then
		value = value + self:getCardsNum("Slash") * 2
	elseif card:isKindOf("Axe")
		and self.player:hasSkills("luoyi|jiushi|jiuchi|pojun")
	then
		value = value + 5
	elseif card:isKindOf("Nullification")
		and self:getCardsNum("Nullification") < 2
	then
		for _, friend in ipairs(self.friends) do
			if self:willSkipPlayPhase(friend)
				or self:willSkipDrawPhase(friend)
				or friend:getJudgingArea():length() > 0
			then
				value = value + 5
				break
			end
		end
	end
	return value
end

sgs.ai_compare_funcs = {
	value = function(a, b)
		return sgs.getValue(a) < sgs.getValue(b)
	end,
	chaofeng = function(a, b)
		return sgs.getDefense(a) < sgs.getDefense(b)
	end,
	defense = function(a, b)
		return sgs.getDefenseSlash(a) < sgs.getDefenseSlash(b)
	end,
	threat = function(a, b)
		local d1 = 0
		if type(a) == "userdata"
		then
			d1 = a:getHandcardNum()
			for _, p in sgs.list(a:getAliveSiblings()) do
				if a:canSlash(p) then
					d1 = d1 + 10 / sgs.getDefense(p)
				end
			end
		end
		local d2 = 0
		if type(b) == "userdata"
		then
			d2 = b:getHandcardNum()
			for _, p in sgs.list(b:getAliveSiblings()) do
				if b:canSlash(p) then
					d2 = d2 + 10 / sgs.getDefense(p)
				end
			end
		end
		return d1 > d2
	end,
}

function SmartAI:sort(players, key, anti)
	if type(players) ~= "table" then players = sgs.QList2Table(players) end
	if #players < 2 then return players end
	local function result()
		local func = sgs.ai_compare_funcs[key]
		if key == "hp"
		then
			func = function(a, b)
				local c1 = type(a) == "userdata" and a:getHp() + a:getHujia() or 0
				local c2 = type(b) == "userdata" and b:getHp() + b:getHujia() or 0
				return c1 < c2 or c1 == c2 and sgs.ai_compare_funcs.chaofeng(a, b)
			end
		elseif key == "HP"
		then
			func = function(a, b)
				local c1 = type(a) == "userdata" and a:getHp() or 0
				local c2 = type(b) == "userdata" and b:getHp() or 0
				return c1 < c2 or c1 == c2 and sgs.ai_compare_funcs.chaofeng(a, b)
			end
		elseif key == "handcard"
		then
			func = function(a, b)
				local c1 = type(a) == "userdata" and a:getHandcardNum() or 0
				local c2 = type(b) == "userdata" and b:getHandcardNum() or 0
				return c1 < c2 or c1 == c2 and sgs.ai_compare_funcs.chaofeng(a, b)
			end
		elseif key == "card"
		then
			func = function(a, b)
				local c1 = type(a) == "userdata" and a:getCardCount() or 0
				local c2 = type(b) == "userdata" and b:getCardCount() or 0
				return c1 < c2 or c1 == c2 and sgs.ai_compare_funcs.chaofeng(a, b)
			end
		elseif key == "handcard_defense"
		then
			func = function(a, b)
				local c1 = type(a) == "userdata" and a:getHandcardNum() or 0
				local c2 = type(b) == "userdata" and b:getHandcardNum() or 0
				return c1 < c2 or c1 == c2 and sgs.ai_compare_funcs.chaofeng(a, b)
			end
		elseif key == "equip"
		then
			func = function(a, b)
				local c1 = type(a) == "userdata" and a:getEquips():length() or 0
				local c2 = type(b) == "userdata" and b:getEquips():length() or 0
				return c1 < c2 or c1 == c2 and sgs.ai_compare_funcs.chaofeng(a, b)
			end
		elseif key == "maxhp"
		then
			func = function(a, b)
				local c1 = type(a) == "userdata" and a:getMaxHp() or 0
				local c2 = type(b) == "userdata" and b:getMaxHp() or 0
				return c1 < c2 or c1 == c2 and sgs.ai_compare_funcs.chaofeng(a, b)
			end
		elseif key == "maxcards"
		then
			func = function(a, b)
				local c1 = type(a) == "userdata" and a:getMaxCards() or 0
				local c2 = type(b) == "userdata" and b:getMaxCards() or 0
				if c1 == c2
				then
					c1 = type(a) == "userdata" and a:getHp() or 0
					c2 = type(b) == "userdata" and b:getHp() or 0
				end
				return c1 < c2 or c1 == c2 and sgs.ai_compare_funcs.chaofeng(a, b)
			end
		elseif key == "skill"
		then
			func = function(a, b)
				local c1 = type(a) == "userdata" and a:getSkillList():length() or 0
				local c2 = type(b) == "userdata" and b:getSkillList():length() or 0
				return c1 < c2 or c1 == c2 and sgs.ai_compare_funcs.chaofeng(a, b)
			end
		elseif func == nil
		then
			func = function(a, b)
				local c1 = type(a) == "userdata" and sgs.getDefenseSlash(a, self) or 0
				local c2 = type(b) == "userdata" and sgs.getDefenseSlash(b, self) or 0
				return c1 < c2
			end
		end
		table.sort(players, func)
	end
	pcall(result)
	if anti then players = sgs.reverse(players) end
	return players
end

function SmartAI:sortByKeepValue(cards, inverse, jorl)
	if type(cards) ~= "table" then cards = sgs.QList2Table(cards) end
	if jorl == "j"
	then
		for i = 1, #cards do
			if self.player:isJilei(cards[i])
			then
				table.remove(cards, i)
			end
		end
	elseif jorl == "l"
	then
		for i = 1, #cards do
			if self.player:isLocked(cards[i])
			then
				table.remove(cards, i)
			end
		end
	end
	if #cards < 2 then return cards end
	local function result()
		local function compare_func(a, b)
			return self:getKeepValue(a) <= self:getKeepValue(b)
		end
		table.sort(cards, compare_func)
	end
	pcall(result)
	if inverse then cards = sgs.reverse(cards) end
	return cards
end

function SmartAI:sortByUseValue(cards, inverse, jorl)
	if type(cards) ~= "table" then cards = sgs.QList2Table(cards) end
	if jorl == "j"
	then
		for i = 1, #cards do
			if self.player:isJilei(cards[i])
			then
				table.remove(cards, i)
			end
		end
	elseif jorl == "l"
	then
		for i = 1, #cards do
			if self.player:isLocked(cards[i])
			then
				table.remove(cards, i)
			end
		end
	end
	if #cards < 2 then return cards end
	local function result()
		local bcv = {}
		for _, c in ipairs(cards) do
			bcv[c:toString()] = self:getUseValue(c)
		end
		local function compare_func(a, b)
			local va = type(a) == "userdata" and bcv[a:toString()] or 0
			local vb = type(b) == "userdata" and bcv[b:toString()] or 0
			return va >= vb
		end
		table.sort(cards, compare_func)
	end
	pcall(result)
	if inverse then cards = sgs.reverse(cards) end
	return cards
end

function SmartAI:sortByUsePriority(cards, inverse, jorl)
	if type(cards) ~= "table" then cards = sgs.QList2Table(cards) end
	if jorl == "j"
	then
		for i = 1, #cards do
			if self.player:isJilei(cards[i])
			then
				table.remove(cards, i)
			end
		end
	elseif jorl == "l"
	then
		for i = 1, #cards do
			if self.player:isLocked(cards[i])
			then
				table.remove(cards, i)
			end
		end
	end
	if #cards < 2 then return cards end
	local function result()
		local bcv = {}
		for _, c in ipairs(cards) do
			bcv[c:toString()] = self:getUsePriority(c)
		end
		local function compare_func(a, b)
			local va = type(a) == "userdata" and bcv[a:toString()] or 0
			local vb = type(b) == "userdata" and bcv[b:toString()] or 0
			return va >= vb
		end
		table.sort(cards, compare_func)
	end
	pcall(result)
	if inverse then cards = sgs.reverse(cards) end
	return cards
end

function SmartAI:sortByDynamicUsePriority(cards, inverse, jorl)
	if type(cards) ~= "table" then cards = sgs.QList2Table(cards) end
	if jorl == "j"
	then
		for i = 1, #cards do
			if self.player:isJilei(cards[i])
			then
				table.remove(cards, i)
			end
		end
	elseif jorl == "l"
	then
		for i = 1, #cards do
			if self.player:isLocked(cards[i])
			then
				table.remove(cards, i)
			end
		end
	end
	if #cards < 2 then return cards end
	local function result()
		local bcv = {}
		for _, c in ipairs(cards) do
			bcv[c:toString()] = self:getDynamicUsePriority(c)
		end
		local function compare_func(a, b)
			local va = type(a) == "userdata" and bcv[a:toString()] or 0
			local vb = type(b) == "userdata" and bcv[b:toString()] or 0
			return va >= vb
		end
		table.sort(cards, compare_func)
	end
	pcall(result)
	if inverse then cards = sgs.reverse(cards) end
	return cards
end

function SmartAI:sortByCardNeed(cards, inverse, jorl)
	if type(cards) ~= "table" then cards = sgs.QList2Table(cards) end
	if jorl == "j"
	then
		for i = 1, #cards do
			if self.player:isJilei(cards[i])
			then
				table.remove(cards, i)
			end
		end
	elseif jorl == "l"
	then
		for i = 1, #cards do
			if self.player:isLocked(cards[i])
			then
				table.remove(cards, i)
			end
		end
	end
	if #cards < 2 then return cards end
	local function result()
		local bcv = {}
		for _, c in ipairs(cards) do
			bcv[c:toString()] = self:cardNeed(c)
		end
		local function compare_func(a, b)
			local va = type(a) == "userdata" and bcv[a:toString()] or 0
			local vb = type(b) == "userdata" and bcv[b:toString()] or 0
			return va <= vb
		end
		table.sort(cards, compare_func)
	end
	pcall(result)
	if inverse then cards = sgs.reverse(cards) end
	return cards
end

function SmartAI:getPriorTarget()
	if #self.enemies < 1 then return end
	self:sort(self.enemies, "defense")
	return self.enemies[1]
end

function SmartAI:compareRoleEvaluation(player, first, second)
	if player:getRole() == "lord" then return "loyalist" end
	if isRolePredictable() then return player:getRole() end
	if (first == "renegade" or second == "renegade") and sgs.ai_role[player:objectName()] == "renegade" then
		return
		"renegade"
	end
	if sgs.ai_role[player:objectName()] == first then return first end
	if sgs.ai_role[player:objectName()] == second then return second end
	return "neutral"
end

function isRolePredictable(classical)
	return sgs.getMode == "02p" or string.sub(sgs.getMode, 3, 3) ~= "p"
		or not classical and sgs.GetConfig("RolePredictable", false)
end

function sgs.findIntersectionSkills(first, second)
	if type(first) == "string" then first = first:split("|") end
	if type(second) == "string" then second = second:split("|") end
	local findings = {}
	for _, skill in sgs.list(first) do
		for _, compare_skill in sgs.list(second) do
			if skill == compare_skill and not table.contains(findings, skill)
			then
				table.insert(findings, skill)
			end
		end
	end
	return findings
end

function sgs.findUnionSkills(first, second)
	if type(first) == "string" then first = first:split("|") end
	if type(second) == "string" then second = second:split("|") end
	local findings = table.copyFrom(first)
	for _, skill in sgs.list(second) do
		if not table.contains(findings, skill)
		then
			table.insert(findings, skill)
		end
	end
	return findings
end

function outputRoleValues(p, level)
	global_room:writeToConsole(sgs.Sanguosha:translate(p:getGeneralName()) .. " " .. level ..
		" " .. sgs.Sanguosha:translate(sgs.ai_role[p:objectName()]) ..
		" 忠值:" .. sgs.roleValue[p:objectName()].loyalist ..
		" 内值:" .. sgs.roleValue[p:objectName()].renegade ..
		" " .. sgs.Sanguosha:translate(sgs.gameProcess()) ..
		"," .. string.format("%3.3f", sgs.gameProcess(1)))
end

function sgs.updateIntention(from, to, level)
	if sgs.ai_doNotUpdateIntenion then level = 0 end
	sgs.ai_doNotUpdateIntenion = nil
	local fn = from:objectName()
	if fn == to:objectName() then return end
	local tar, far = sgs.ai_role[to:objectName()], sgs.ai_role[fn]
	level = level + to:getTag("Intention" .. from:objectName()):toInt()
	to:removeTag("Intention" .. from:objectName())
	level = level * math.random(0.2, 0.5)
	if from:getRole() == "lord"
	then
		if tar ~= "rebel" and to:getState() == "robot" and math.random() < 0.2
			and sgs.roleValue[to:objectName()].loyalist > -level / 2
		then
			local intention = {
				"。。。。。。",
				"我特么....",
				"<#" .. math.random(1, 56) .. "#>",
				"<#" .. math.random(1, 56) .. "#>",
				"<#44#>",
				"小心我跳反！"
			}
			if from:getPhase() <= sgs.Player_Play
			then
				table.insert(intention, "不要乱来啊")
				table.insert(intention, "主公别乱打啊")
				table.insert(intention, "盲狙轻点....")
			end
			if level > 22
			then
				table.insert(intention, "<#20#>")
				table.insert(intention, "主公你这样就不好了")
				table.insert(intention, "你乱来，就不要怪我乱来了")
				to:setMark("general" .. fn, level / 2)
			end
			to:speak(intention[math.random(1, #intention)])
		end
		return
	end
	if tar == "neutral" and level > 0
		and to:getState() == "robot"
	then
		if tar == far
			and math.random() < 0.3
		then
			local intention = {
				"嗯？",
				"。。。。",
				"<#" .. math.random(1, 56) .. "#>",
				"<#" .. math.random(1, 56) .. "#>",
				"<#12#>",
				"我记下了"
			}
			if from:getPhase() <= sgs.Player_Play
			then
				table.insert(intention, "警告你")
				table.insert(intention, "喂喂喂！")
				table.insert(intention, "我特么....")
			end
			if level > 22
			then
				table.insert(intention, "你等着！")
				table.insert(intention, "乱来是吧")
				table.insert(intention, "找茬是吧")
				table.insert(intention, "<#19#>")
				to:setMark("general" .. fn, level)
			end
			to:speak(intention[math.random(1, #intention)])
		elseif far ~= tar and math.random() < 0.2
		then
			local intention = {
				"看好身份",
				"<#" .. math.random(1, 56) .. "#>",
				"<#" .. math.random(1, 56) .. "#>",
				"<#6#>",
				"<#44#>",
				"。。。。"
			}
			if from:getPhase() <= sgs.Player_Play
			then
				table.insert(intention, "点读机是吧")
				table.insert(intention, "我招你惹你了....")
				table.insert(intention, "我特么....")
			end
			if level > 22
			then
				table.insert(intention, "你等着！")
				table.insert(intention, "你歌姬吧")
				table.insert(intention, "*****")
				table.insert(intention, "<#7#>")
				table.insert(intention, "<#15#>")
				to:setMark("general" .. fn, level)
			end
			to:speak(intention[math.random(1, #intention)])
		end
	elseif tar == "loyalist"
	then
		if to:getRole() ~= "lord" and (sgs.UnknownRebel or sgs.roleValue[fn].renegade > 0 and not sgs.explicit_renegade) then
		elseif sgs.playerRoles.rebel > 0 and level > 0 or sgs.playerRoles.renegade + sgs.playerRoles.loyalist > 0 and level < 0
		then
			sgs.roleValue[fn].loyalist = sgs.roleValue[fn].loyalist - level
		end
		if sgs.playerRoles.renegade > 0
		then
			if sgs.UnknownRebel and level > 0
				and sgs.playerRoles.loyalist > 0 then --反装忠
			elseif not (to:getRole() == "lord" or sgs.explicit_renegade)
				and sgs.playerRoles.rebel < 1 and sgs.playerRoles.loyalist > 0
			then -- 进入主忠内,但此时没人跳过内，则忠臣之间相互攻击，不更新内奸值
			elseif far ~= "rebel" and level > 0 or far == "rebel" and level < 0
			then
				sgs.roleValue[fn].renegade = sgs.roleValue[fn].renegade + math.abs(level)
			end
		end
	elseif tar == "rebel"
	then
		sgs.roleValue[fn].loyalist = sgs.roleValue[fn].loyalist + level
		if sgs.playerRoles.renegade > 0 and (far ~= "rebel" and level < 0 or far == "rebel" and level > 0)
		then
			sgs.roleValue[fn].renegade = sgs.roleValue[fn].renegade + math.abs(level)
		end
	end
	outputRoleValues(from, level)
	for _, p in sgs.qlist(global_room:getAlivePlayers()) do
		sgs.ais[p:objectName()]:updatePlayers(true, fn == p:objectName())
	end
end

function sgs.updateIntentions(from, tos, intention)
	for _, to in sgs.list(tos) do
		sgs.updateIntention(from, to, intention)
	end
end

function sgs.isLordHealthy()
	local lord = global_room:getLord()
	if not lord then return true end
	local lord_hp = lord:getHp()
	if lord:hasSkill("benghuai") and lord_hp > 4 then lord_hp = 4 end
	return lord_hp > 3 or lord_hp > 2 and sgs.getDefense(lord) > 3
end

function sgs.isLordInDanger()
	local lord = global_room:getLord()
	if not lord then return false end
	local lord_hp = lord:getHp()
	if lord:hasSkill("benghuai") and lord_hp > 4
	then
		lord_hp = 4
	end
	return lord_hp < 3
end

function sgs.gameProcess(arg, update)
	if not update
	then
		if arg
		then
			if sgs.ai_gameProcess_arg then return sgs.ai_gameProcess_arg end
		elseif sgs.ai_gameProcess then
			return sgs.ai_gameProcess
		end
	end
	if sgs.playerRoles.rebel < 1
		and sgs.playerRoles.loyalist > 0
	then
		if arg then
			sgs.ai_gameProcess_arg = 99
			return 99
		else
			sgs.ai_gameProcess = "loyalist"
			return "loyalist"
		end
	elseif sgs.playerRoles.loyalist < 1 and sgs.playerRoles.rebel > 1
	then
		if arg then
			sgs.ai_gameProcess_arg = -99
			return -99
		else
			sgs.ai_gameProcess = "rebel"
			return "rebel"
		end
	end
	local loyal_value, rebel_value, process, health = 0, 0, "neutral", sgs.isLordHealthy()
	for role, ap in sgs.qlist(global_room:getAlivePlayers()) do
		role = sgs.ai_role[ap:objectName()] --ap:getRole()
		local hp = ap:getHp()
		if ap:hasSkill("benghuai") and hp > 4 then hp = 4 end
		if role == "rebel"
		then
			local lord = global_room:getLord()
			rebel_value = rebel_value + hp + math.max(sgs.getDefense(ap) - hp * 2, 0) * 0.5
			if lord and ap:inMyAttackRange(lord) then rebel_value = rebel_value + 0.4 end
		elseif role == "loyalist" or role == "lord"
		then
			loyal_value = loyal_value + hp + math.max(sgs.getDefense(ap) - hp * 2, 0) * 0.5
		end
	end
	local diff = loyal_value - rebel_value + (sgs.playerRoles.loyalist + 1 - sgs.playerRoles.rebel) * 3
	if arg then sgs.ai_gameProcess_arg = diff end
	if diff >= 4
	then
		if health then
			process = "loyalist"
		else
			process = "dilemma"
		end
	elseif diff >= 2
	then
		if health then
			process = "loyalish"
		elseif sgs.isLordInDanger() then
			process = "dilemma"
		else
			process = "rebelish"
		end
	elseif diff <= -4
	then
		process = "rebel"
	elseif diff <= -2
	then
		if health then
			process = "rebelish"
		else
			process = "rebel"
		end
	elseif not health then
		process = "rebelish"
	else
		process = "neutral"
	end
	sgs.ai_gameProcess = process
	if arg then return diff end
	return process
end

function SmartAI:objectiveLevel(to)
	if type(to) ~= "userdata" then return 0 end
	if to:objectName() == self.player:objectName() then return -2 end
	local players = sgs.QList2Table(self.player:getAliveSiblings())
	if #players < 2 then
		return 5
	elseif self.player:getMark("general" .. to:objectName()) > 0 --报复仇恨
	then
		self.player:removeMark("general" .. to:objectName())
		return 3
	elseif isRolePredictable(true) --明身份
	then
		if self.lua_ai:isFriend(to) then
			return -2
		elseif self.lua_ai:isEnemy(to) then
			return 5
		elseif self.lua_ai:relationTo(to) == sgs.AI_Neutrality
			and self.lua_ai:getEnemies():isEmpty()
		then
			return 4
		else
			return 0
		end
	elseif self.player:getMark("roleRobot") > 0 --添加点随机仇恨
	then
		self.player:removeMark("roleRobot")
		if sgs.ai_role[to:objectName()] == sgs.ai_role[self.player:objectName()]
		then
			return 4 - to:getHp()
		end
	end
	local target_role = sgs.ai_role[to:objectName()]
	local process = sgs.gameProcess()
	if self.role == "renegade"
	then
		if to:getRole() == "lord" and sgs.getMode ~= "couple"
			and not sgs.GetConfig("EnableHegemony", false)
			and to:hasFlag("Global_Dying") then
			return -2
		elseif target_role == "rebel" and to:getHp() < 2
			and not to:hasSkills("kongcheng|tianming")
			and not hasBuquEffect(to) and to:isKongcheng()
		then
			return 5
		end
		if sgs.playerRoles.rebel < 1
			or sgs.playerRoles.loyalist < 1
		then
			if sgs.playerRoles.rebel > 0
			then
				if sgs.playerRoles.rebel > 1
				then
					if to:getRole() == "lord" then
						return -2
					elseif target_role == "rebel"
					then
						return 5
					else
						return 0
					end
				elseif sgs.playerRoles.renegade > 1
				then
					if to:getRole() == "lord" then
						return 0
					elseif target_role == "renegade"
					then
						return 3
					else
						return 5
					end
				else
					if process == "loyalist"
					then
						if to:getRole() == "lord"
						then
							if sgs.isLordHealthy()
							then
								return 1
							else
								return -1
							end
						elseif target_role == "rebel"
						then
							return 0
						else
							return 5
						end
					elseif process:match("rebel")
					then
						if target_role == "rebel"
						then
							return 5
						else
							return -1
						end
					elseif to:getRole() == "lord" then
						return 0
					else
						return 5
					end
				end
			elseif sgs.playerRoles.loyalist > 0
			then
				if sgs.explicit_renegade and sgs.playerRoles.renegade == 1
					and sgs.roleValue[self.player:objectName()].renegade == 0
					and sgs.ai_role[self.player:objectName()] == "loyalist"
				then
					if target_role == "renegade"
					then
						return 5
					else
						return -1
					end
				end
				if to:getRole() == "lord"
				then
					if sgs.roleValue[self.player:objectName()].renegade == 0
						and not sgs.explicit_renegade then
						return 0
					elseif not sgs.isLordHealthy()
					then
						return 0
					else
						return 1
					end
				elseif target_role == "renegade" and sgs.playerRoles.renegade > 1
				then
					return 3
				else
					return 5
				end
			elseif sgs.playerRoles.loyalist + sgs.playerRoles.rebel < 1
			then
				local dp, dt = sgs.getDefense(self.player), sgs.getDefense(to)
				return dt > dp * (1 + math.random()) and dt
					or dp - dt < -(1 + math.random() * 2) and dt
					or dp - dt > (1 + math.random() * 2) and dp - dt
					or 0
			else
				if to:getRole() == "lord"
				then
					if sgs.isLordInDanger then
						return 0
					elseif not sgs.isLordHealthy() then
						return 3
					else
						return 5
					end
				elseif sgs.isLordHealthy() then
					return 3
				else
					return 5
				end
			end
		end
		if process == "neutral"
			or sgs.turncount <= 1 and sgs.isLordHealthy()
		then
			if sgs.turncount <= 1
				and sgs.isLordHealthy()
			then
				if sgs.playerRoles.renegade > 1 then
					return 0
				elseif self:getOverflow() <= -1 then
					return 0
				end
				if to:getRole() == "lord" then return sgs.playerRoles.loyalist + 1 < sgs.playerRoles.rebel and -1 or 0 end
				if target_role == "loyalist" then
					return sgs.playerRoles.loyalist + 1 < sgs.playerRoles.rebel and 0 or 3.5
				elseif target_role == "rebel" then
					return sgs.playerRoles.loyalist + 1 < sgs.playerRoles.rebel and 3.5 or 0
				else
					return 0
				end
			end
			if to:getRole() == "lord" then return -1 end
			for _, p in ipairs(players) do
				if p:getRole() ~= "lord"
					and p:hasSkills("buqu|nosbuqu|" .. sgs.priority_skill .. "|" .. sgs.save_skill .. "|" .. sgs.recover_skill .. "|" .. sgs.drawpeach_skill)
				then
					return 5
				end
			end
			return self:getOverflow() > 0 and 3 or 0
		elseif process:match("rebel")
		then
			return target_role == "rebel" and 5
				or target_role == "neutral" and 0 or -1
		elseif process:match("dilemma")
		then
			if target_role == "rebel" then
				return 5
			elseif target_role == "loyalist"
				or target_role == "renegade" then
				return 0
			elseif to:getRole() == "lord" then
				return -2
			else
				return 5
			end
		elseif process == "loyalish"
		then
			if to:getRole() == "lord" or target_role == "renegade" then return 0 end
			if target_role == "loyalist" then
				return sgs.playerRoles.loyalist + 1 < sgs.playerRoles.rebel and 0 or 3.5
			elseif target_role == "rebel" then
				return sgs.playerRoles.loyalist + 1 < sgs.playerRoles.rebel and 3.5 or 0
			else
				return 0
			end
		else
			if to:getRole() == "lord" or target_role == "renegade" then return 0 end
			return target_role == "rebel" and -2 or 5
		end
	elseif self.player:getRole() == "lord"
		or self.role == "loyalist"
	then
		if to:getRole() == "lord" then return -2 end
		if self.role == "loyalist" and sgs.playerRoles.loyalist < 2 and sgs.playerRoles.renegade < 1
			or sgs.playerRoles.loyalist + sgs.playerRoles.renegade < 1 then
			return 5
		end
		if target_role == "neutral"
		then
			if sgs.playerRoles.rebel > 0
			then
				local rebelish = process:match("rebel")
				local friendNum, enemyNum, renegadeNum = 1, 0, 0
				local consider_renegade = sgs.getMode == "05p" or sgs.getMode == "07p" or sgs.getMode == "09p"
				for ar, ap in sgs.qlist(self.player:getAliveSiblings()) do
					ar = sgs.ai_role[ap:objectName()]
					if ar == "loyalist" then
						friendNum = friendNum + 1
					elseif ar == "renegade" then
						renegadeNum = renegadeNum + 1
					elseif ar == "rebel" then
						enemyNum = enemyNum + 1
					end
				end
				if friendNum + ((consider_renegade or rebelish) and renegadeNum or 0)
					>= sgs.playerRoles.loyalist + ((rebelish or consider_renegade) and sgs.playerRoles.renegade or 0) + 1
				then
					return self:getOverflow() > -1 and 5 or 3
				elseif enemyNum + (consider_renegade and renegadeNum or rebelish and 0 or renegadeNum)
					>= sgs.playerRoles.rebel + (consider_renegade and sgs.playerRoles.renegade or rebelish and 0 or sgs.playerRoles.renegade)
				then
					return -1
				elseif self:getOverflow() > -1
					and friendNum + ((consider_renegade or rebelish) and renegadeNum or 0) + 1
					== sgs.playerRoles.loyalist + ((rebelish or consider_renegade) and sgs.playerRoles.renegade or 0) + 1
					and enemyNum <= 1 and enemyNum / sgs.playerRoles.rebel < 0.35
				then
					return 1
				end
			elseif sgs.explicit_renegade
				and sgs.playerRoles.renegade == 1
			then
				return -1
			end
		end
		if sgs.playerRoles.rebel < 1
		then
			if #players == 2 and self.role == "loyalist" then return 5 end
			if self.player:getRole() == "lord" and to:getHp() <= 2
				and not self.player:hasFlag("stack_overflow_jijiang")
				and self:ajustDamage(self.player, to, 1, dummyCard()) > 1
			then
				return 0
			end
			if sgs.explicit_renegade
			then
				if self.player:getRole() == "lord"
				then
					if target_role == "loyalist" then
						return -2
					elseif target_role == "renegade" and sgs.roleValue[to:objectName()].renegade > 50
					then
						return 5
					else
						return to:getHp() > 1 and 4 or 0
					end
				else
					if self.role == "loyalist"
						and sgs.ai_role[self.player:objectName()] == "renegade"
					then
						for _, p in ipairs(players) do
							if sgs.roleValue[p:objectName()].renegade > 0
							then
								return to:objectName() == p:objectName() and 5 or -2
							end
						end
						return 4
					else
						if target_role == "loyalist"
						then
							return -2
						else
							return 4
						end
					end
				end
			else
				self:sort(players, "hp")
				local maxhp = players[#players]:getRole() == "lord" and players[#players - 1]:getHp() or
					players[#players]:getHp()
				if maxhp > 2 then return to:getHp() == maxhp and 5 or 0 end
				if maxhp == 2 then return self.player:getRole() == "lord" and 0 or (to:getHp() == maxhp and 5 or 1) end
				return self.player:getRole() == "lord" and 0 or 5
			end
		end
		if sgs.playerRoles.loyalist < 1
			and target_role == "renegade"
		then
			if sgs.playerRoles.rebel > 2 then
				return -1
			elseif sgs.playerRoles.rebel > 1 then
				return to:getHp() - 1
			end
			return sgs.isLordInDanger() and -1 or to:getHp() + 1
		end
		if sgs.playerRoles.renegade < 1
		then
			if target_role == "loyalist" then return -2 end
			if sgs.playerRoles.rebel > 0 and sgs.turncount > 1
			then
				sgs.UnknownRebel = false
				for _, p in ipairs(players) do
					if sgs.ai_role[p:objectName()] == "rebel"
					then
						sgs.UnknownRebel = true
						break
					end
				end
				if not sgs.UnknownRebel
				then
					self:sort(players, "hp")
					hasRebel = players[#players]:getRole() == "lord" and players[#players - 1]:getHp() or
						players[#players]:getHp()
					if hasRebel > 2 then return to:getHp() == hasRebel and 5 or 0 end
					if hasRebel == 2 then
						return self.player:getRole() == "lord" and 0 or
							(to:getHp() == hasRebel and 5 or 1)
					end
					return self.player:getRole() == "lord" and 0 or 5
				end
			end
		end
		if target_role == "rebel" then
			return 5
		elseif target_role == "loyalist" then
			return -2
		elseif target_role == "renegade"
		then
			if process:match("rebel") then return -2 end
			return sgs.isLordInDanger() and 0 or to:getHp() + 1
		end
	elseif self.role == "rebel"
	then
		if sgs.playerRoles.loyalist + sgs.playerRoles.renegade < 1
		then
			return to:getRole() == "lord" and 5 or -2
		end
		if target_role == "neutral"
		then
			local friendNum, enemyNum, renegadeNum = 1, 0, 0
			for ar, ap in sgs.qlist(self.player:getAliveSiblings()) do
				ar = sgs.ai_role[ap:objectName()]
				if ar == "rebel" then
					friendNum = friendNum + 1
				elseif ar == "renegade" then
					renegadeNum = renegadeNum + 1
				elseif ar == "loyalist" then
					enemyNum = enemyNum + 1
				end
			end
			local loyalish = process:match("loyal")
			local consider_renegade = sgs.getMode == "05p" or sgs.getMode == "07p" or sgs.getMode == "09p"
			if friendNum + ((consider_renegade or loyalish) and renegadeNum or 0)
				>= sgs.playerRoles.rebel + ((consider_renegade or loyalish) and sgs.playerRoles.renegade or 0)
			then
				return self:getOverflow() > -1 and 5 or 3
			elseif enemyNum + (consider_renegade and renegadeNum or loyalish and 0 or renegadeNum)
				>= sgs.playerRoles.loyalist + (consider_renegade and sgs.playerRoles.renegade or loyalish and 0 or sgs.playerRoles.renegade) + 1
			then
				return -1
			elseif sgs.playerRoles.loyalist + sgs.playerRoles.renegade > 0 and self:getOverflow() >= 0
				and friendNum + ((consider_renegade or loyalish) and renegadeNum or 0) + 1
				== sgs.playerRoles.rebel + ((consider_renegade or loyalish) and sgs.playerRoles.renegade or 0)
				and enemyNum <= 1 and enemyNum / (sgs.playerRoles.loyalist + sgs.playerRoles.renegade) < 0.35
			then
				return 1
			end
		end
		if to:getRole() == "lord" then
			return 5
		elseif target_role == "loyalist" then
			return 4
		end
		if target_role == "rebel" then
			return (sgs.playerRoles.rebel > 1 or sgs.playerRoles.renegade > 0 and process:match("loyal")) and
				-2 or 5
		end
		if target_role == "renegade" then return process:match("loyal") and -1 or to:getHp() + 1 end
	end
	return 0
end

function SmartAI:isFriend(other, another)
	if another then
		local of, af = self:isFriend(other), self:isFriend(another)
		return of ~= nil and of == af
	end
	local obj_level = self:objectiveLevel(other)
	if obj_level ~= 0 then return obj_level < 0 end
end

function SmartAI:isEnemy(other, another)
	if another then
		local of, af = self:isFriend(other), self:isFriend(another)
		return of ~= nil and of ~= af
	end
	local obj_level = self:objectiveLevel(other)
	if obj_level ~= 0 then return obj_level > 0 end
end

function SmartAI:getFriendsNoself(player)
	player = player or self.player
	local friends_noself = {}
	for _, p in sgs.qlist(self.room:getAlivePlayers()) do
		if p:objectName() ~= player:objectName() and self:isFriend(p, player)
		then
			table.insert(friends_noself, p)
		end
	end
	return friends_noself
end

function SmartAI:getFriends(player)
	player = player or self.player
	local friends = {}
	for _, p in sgs.qlist(self.room:getAlivePlayers()) do
		if self:isFriend(p, player) then table.insert(friends, p) end
	end
	return friends
end

function SmartAI:getEnemies(player)
	local enemies = {}
	for _, p in sgs.qlist(self.room:getAlivePlayers()) do
		if self:isEnemy(p, player) then table.insert(enemies, p) end
	end
	return enemies
end

function SmartAI:sortEnemies(players)
	local function comp_func(a, b)
		local alevel = self:objectiveLevel(a)
		local blevel = self:objectiveLevel(b)
		if alevel ~= blevel then return alevel > blevel end
		return sgs.getDefenseSlash(a, self) < sgs.getDefenseSlash(b, self)
	end
	table.sort(players, comp_func)
end

function updateAlivePlayerRoles()
	for _, ap in sgs.qlist(global_room:getPlayers()) do
		sgs.playerRoles[ap:getRole()] = 0
	end
	for r, ap in sgs.qlist(global_room:getAllPlayers()) do
		r = ap:getRole()
		sgs.playerRoles[r] = sgs.playerRoles[r] + 1
	end
end

function SmartAI:updatePlayers(clear, update)
	if self.role ~= self.player:getRole()
	then
		if self.player:getRole() ~= "lord"
		then
			sgs.roleValue[self.player:objectName()]["loyalist"] = 0
			sgs.roleValue[self.player:objectName()]["rebel"] = 0
			sgs.roleValue[self.player:objectName()]["renegade"] = 0
		end
		self.role = self.player:getRole()
	end
	if clear ~= false
	then
		for _, aflag in ipairs(sgs.ai_global_flags) do
			sgs[aflag] = nil
		end
	end
	updateAlivePlayerRoles()
	if update ~= false then sgs.gameProcess(1, true) end
	local neutrality = {}
	self.enemies = {}
	self.friends = {}
	self.friends_noself = {}
	if isRolePredictable(true)
	then
		for _, p in sgs.qlist(self.room:getAlivePlayers()) do
			if self.lua_ai:isFriend(p)
			then
				table.insert(self.friends, p)
				if p ~= self.player then table.insert(self.friends_noself, p) end
			elseif self.lua_ai:isEnemy(p) then
				table.insert(self.enemies, p)
			elseif self.lua_ai:relationTo(p) == sgs.AI_Neutrality
			then
				table.insert(neutrality, p)
			end
		end
		self.harsh_retain = false
		if #self.enemies < 1
			and #neutrality > 0
		then
			function compare_func(a, b)
				return sgs.getDefense(a) < sgs.getDefense(b)
			end

			table.sort(neutrality, compare_func)
			table.insert(self.enemies, neutrality[1])
		end
	else
		if isRolePredictable()
		then
			if sgs.ai_role[self.player:objectName()] ~= self.player:getRole()
				and not self.player:getRole() == "lord" then
				self:adjustAIRole()
			end
		elseif update ~= false then
			evaluateAlivePlayersRole()
		end
		for n, p in sgs.qlist(self.room:getAlivePlayers()) do
			n = self:objectiveLevel(p)
			if n < 0
			then
				table.insert(self.friends, p)
				if p ~= self.player then table.insert(self.friends_noself, p) end
			elseif n > 0 then
				table.insert(self.enemies, p)
			else
				table.insert(neutrality, p)
			end
		end
		if #self.enemies < 1 and #neutrality > 0
			and #self.toUse < 3 and self:getOverflow() > 0
		then
			function compare_func(a, b)
				return sgs.getDefense(a) < sgs.getDefense(b)
			end

			table.sort(neutrality, compare_func)
			table.insert(self.enemies, neutrality[1])
		end
	end
end

function evaluateAlivePlayersRole()
	local cmp = function(a, b)
		local va = a and sgs.roleValue[a:objectName()].renegade or 0
		local vb = b and sgs.roleValue[b:objectName()].renegade or 0
		if va == vb
		then
			va = a and sgs.roleValue[a:objectName()].loyalist or 0
			vb = b and sgs.roleValue[b:objectName()].loyalist or 0
		end
		return va > vb
	end
	local aps = sgs.QList2Table(global_room:getAlivePlayers())
	table.sort(aps, cmp)
	local rebel = 0
	sgs.explicit_renegade = false
	for name, p in ipairs(aps) do
		name = p:objectName()
		if p:getRole() == "lord" then
			sgs.ai_role[name] = "loyalist"
		elseif sgs.playerRoles.rebel + sgs.playerRoles.loyalist < 1
			and sgs.playerRoles.renegade > 0
		then
			sgs.explicit_renegade = true
			sgs.ai_role[name] = "renegade"
		elseif sgs.playerRoles.renegade + sgs.playerRoles.loyalist < 1
			and sgs.playerRoles.rebel > 0
		then
			rebel = rebel + 1
			sgs.ai_role[name] = "rebel"
		elseif sgs.roleValue[name].renegade >= 10
			and sgs.roleValue[name].loyalist > -40
			and sgs.playerRoles.renegade > 0
		then
			sgs.ai_role[name] = "renegade"
			sgs.explicit_renegade = sgs.roleValue[name].renegade >= (sgs.playerRoles.rebel < 1 and 10 or 20)
		elseif sgs.roleValue[name].loyalist > 10 and sgs.playerRoles.loyalist > 0
		then
			sgs.ai_role[name] = "loyalist"
		elseif sgs.roleValue[name].loyalist < -10
			and sgs.playerRoles.rebel > 0
		then
			sgs.ai_role[name] = "rebel"
			rebel = rebel + 1
		else
			sgs.ai_role[name] = "neutral"
			if (sgs.roleValue[name].loyalist > 10 or sgs.roleValue[name].loyalist < 0) and sgs.playerRoles.renegade > 0
			then
				sgs.ai_role[name] = "renegade"
				sgs.explicit_renegade = true
			end
		end
	end
	if rebel < sgs.playerRoles.rebel
	then
		local lR_players = {}
		for _, p in ipairs(aps) do
			if sgs.ai_role[p:objectName()] == "loyalist"
				or sgs.ai_role[p:objectName()] == "renegade"
			then
				table.insert(lR_players, p)
			end
		end
		function cmp_rebel(a, b)
			return sgs.roleValue[a:objectName()].loyalist < sgs.roleValue[b:objectName()].loyalist
		end

		table.sort(lR_players, cmp_rebel)
		for name, p in ipairs(lR_players) do
			name = p:objectName()
			if sgs.roleValue[name].loyalist < -10
				and sgs.roleValue[name].renegade > 10
				and rebel < sgs.playerRoles.rebel
			then
				rebel = rebel + 1
				sgs.roleValue[name].loyalist = math.min(-sgs.roleValue[name].renegade, sgs.roleValue[name].loyalist)
				sgs.roleValue[name].renegade = 0
				sgs.ai_role[name] = "rebel"
				outputRoleValues(p, 0)
				global_room:writeToConsole("rebel:" .. p:getGeneralName() .. " Modified Success!")
			end
		end
	end
end

---查找room内指定objectName的player
function findPlayerByObjectName(room, name, include_death, except)
	if not room then return end
	include_death = include_death or false
	local players = room:getAllPlayers(include_death)
	if except then players:removeOne(except) end
	for _, p in sgs.list(players) do
		if p:objectName() == name
		then
			return p
		end
	end
end

function getTrickIntention(trick_class, target)
	local intention = sgs.ai_card_intention[trick_class]
	if type(intention) == "number" then
		return intention
	elseif type(intention) == "function"
	then
		if trick_class == "IronChain"
		then
			if target and target:isChained() then return -60 else return 60 end
		elseif trick_class == "Drowning"
		then
			if target and target:getArmor() and target:hasSkills("yizhong|bazhen") then return 0 end
			if target and target:isChained() then return -60 else return 60 end
		end
	end
	if trick_class == "Collateral" then return 0 end
	if sgs.dynamic_value.damage_card[trick_class] then return 70 end
	if sgs.dynamic_value.benefit[trick_class] then return -40 end
	if target and ("Snatch|Dismantlement|Zhujinqiyuan"):match(trick_class)
	then
		if target:getJudgingArea():isEmpty()
		then
			if not (target:hasArmorEffect("silver_lion")
					and target:isWounded())
			then
				return 80
			end
		end
	end
	return 0
end

sgs.ai_choicemade_filter.Nullification.general = function(self, player, promptlist)
	if promptlist[2] == "Nullification"
	then
		sgs.nullification_level = sgs.nullification_level + 1
		if sgs.nullification_level % 2 == 0 then
			sgs.updateIntention(player, sgs.nullification_source, sgs.nullification_intention)
		elseif sgs.nullification_level % 2 == 1 then
			sgs.updateIntention(player, sgs.nullification_source, -sgs.nullification_intention)
		end
	else
		sgs.nullification_level = 1
		sgs.nullification_source = BeMan(global_room, promptlist[3])
		sgs.nullification_intention = getTrickIntention(promptlist[2], sgs.nullification_source)
		if player:objectName() ~= promptlist[3] then
			sgs.updateIntention(player, sgs.nullification_source, -sgs.nullification_intention)
		end
	end
end

sgs.ai_choicemade_filter.playerChosen.general = function(self, from, promptlist)
	if from:objectName() == promptlist[3] then return end
	local reason = string.gsub(promptlist[2], "%-", "_")
	local to = BeMan(self.room, promptlist[3])
	local callback = sgs.ai_playerchosen_intention[reason]
	if type(callback) == "number" then
		sgs.updateIntention(from, to, sgs.ai_playerchosen_intention[reason])
	elseif type(callback) == "function" then
		callback(self, from, to)
	end
end

sgs.ai_choicemade_filter.viewCards.general = function(self, from, promptlist)
	local to = BeMan(self.room, promptlist[#promptlist])
	if to
	then
		for _, card in sgs.list(to:getHandcards()) do
			card:setFlags("visible_" .. from:objectName() .. "_" .. to:objectName())
		end
	end
end

sgs.ai_choicemade_filter.Yiji.general = function(self, from, promptlist)
	local from = BeMan(self.room, promptlist[3])
	local to = BeMan(self.room, promptlist[4])
	local cards = {}
	for _, id in sgs.list(promptlist[5]:split("+")) do
		table.insert(cards, sgs.Sanguosha:getCard(id))
	end
	if from and to
	then
		local callback = sgs.ai_Yiji_intention[promptlist[2]]
		if type(callback) == "number" and not hasManjuanEffect(to)
			and not (self:needKongcheng(to, true) and #cards == 1) then
			sgs.updateIntention(from, to, callback)
		elseif type(callback) == "function" then
			callback(self, from, to, cards)
		elseif not (self:needKongcheng(to, true) and #cards == 1) and not hasManjuanEffect(to)
		then
			sgs.updateIntention(from, to, -10)
		end
	end
end

function SmartAI:filterEvent(event, player, data)
	if self.player ~= player then return end
	sgs.lasteventdata = data
	sgs.lastevent = event
	if sgs.debugmode
	then
		for _, callback in pairs(sgs.ai_debug_func[event]) do
			if type(callback) == "function" then callback(self, player, data) end
		end
	end
	if player:getState() == "robot" and sgs.delay > 0
		and sgs.GetConfig("AIChat", false)
	then
		for _, callback in pairs(sgs.ai_chat_func[event]) do
			if type(callback) == "function" then callback(self, player, data) end
		end
	end
	for _, callback in pairs(sgs.ai_event_callback[event]) do
		if type(callback) == "function" then callback(self, player, data) end
	end
	if self.room:getCurrent() == player
	then
		current_self = self
	end
	if event == sgs.AskForPeaches
	then
		local dying = data:toDying()
		if self:isFriend(dying.who) and dying.who:getHp() < 1
		then
			sgs.card_lack[player:objectName()]["Peach"] = 1
		end
		if sgs.DebugMode_Niepan then endlessNiepan(dying.who) end
	elseif event == sgs.Death
	then
		local de = data:toDeath()
		sgs.ai_role[de.who:objectName()] = de.who:getRole()
		if de.damage and de.damage.from and de.damage.from ~= player
			and de.who ~= player and sgs.turncount > 1 and self:objectiveLevel(de.who) < 0
		then
			local intention = 99
			if de.damage.transfer or de.damage.chain then intention = intention / 3 end
			sgs.updateIntention(de.damage.from, player, intention)
		else
			self:updatePlayers()
		end
	elseif event == sgs.TargetConfirmed
	then
		local struct = data:toCardUse()
		if struct.from ~= player then return end
		if not player:hasFlag("ZenhuiUser_" .. struct.card:toString())
		then
			local callback = sgs.ai_card_intention[struct.card:getClassName()]
			if struct.card:isKindOf("SingleTargetTrick") then sgs.TrickUsefrom = player end
			if type(callback) == "function" then
				callback(self, struct.card, player, sgs.QList2Table(struct.to))
			elseif type(callback) == "number" then
				sgs.updateIntentions(player, struct.to, callback)
			end
		end
		if struct.card:isDamageCard()
		then
			if sgs.ai_role[player:objectName()] == "rebel"
				and not self:isFriend(player:getNextAlive())
			then
				for _, target in sgs.qlist(struct.to) do
					if self:isFriend(target) and sgs.ai_role[target:objectName()] == "rebel"
						and target:getHp() < 2 and target:isKongcheng() and self:isGoodTarget(target)
						and getCardsNum("Peach,Analeptic", target, player) < 1
						and self:getEnemyNumBySeat(player, target) > 0
					then
						target:setFlags("AI_doNotSave")
					end
				end
			end
			if struct.card:getSkillName() == "qice"
			then
				sgs.ai_qice_data = data
			end
		end
		if struct.card:isKindOf("AOE")
		then
			self.aoeTos = struct.to
			local lord = getLord(player)
			if lord and lord:getHp() < 2 and struct.to:contains(lord) and self:aoeIsEffective(struct.card, lord, player)
			then
				sgs[struct.card:getClassName() .. "HasLord"] = true
			end
			sgs.ai_AOE_data = data
			self.aoeTos = nil
		end
	elseif event == sgs.ChoiceMade
	then
		local struct = type(data) == "userdata" and data:toCardUse()
		if struct and struct.card
		then
			for _, aflag in ipairs(sgs.ai_global_flags) do
				sgs[aflag] = nil
			end
			for _, callback in ipairs(sgs.ai_choicemade_filter.cardUsed) do
				if type(callback) == "function" then callback(self, player, struct) end
			end
		else
			struct = data:toString()
			if struct == "" then return end
			local promptlist = struct:split(":")
			local callbacktable = sgs.ai_choicemade_filter[promptlist[1]]
			if type(callbacktable) == "table"
			then
				local index = 2
				if promptlist[1] == "cardResponded"
				then
					if promptlist[2]:match("jink") then
						sgs.card_lack[player:objectName()]["Jink"] = promptlist[#promptlist] == "_nil_" and 1 or 0
					elseif promptlist[2]:match("slash") then
						sgs.card_lack[player:objectName()]["Slash"] = promptlist[#promptlist] == "_nil_" and 1 or 0
					elseif promptlist[2]:match("peach") then
						sgs.card_lack[player:objectName()]["Peach"] = promptlist[#promptlist] == "_nil_" and 1 or 0
					end
					index = 3
				end
				callbacktable = callbacktable[promptlist[index]] or callbacktable.general
				if type(callbacktable) == "function" then callbacktable(self, player, promptlist) end
			end
			if struct == "skillInvoke:fenxin:yes"
			then
				for _, ap in sgs.qlist(self.room:getAllPlayers()) do
					if ap:hasFlag("FenxinTarget")
					then
						sgs.roleValue[player:objectName()] = sgs.roleValue[ap:objectName()]
						sgs.ai_role[player:objectName()] = sgs.ai_role[ap:objectName()]
						self:updatePlayers()
						break
					end
				end
			end
		end
	elseif event == sgs.CardEffect
	then
		local struct = data:toCardEffect()
		if struct.card:isKindOf("AOE") and struct.to:getRole() == "lord"
		then
			sgs[struct.card:getClassName() .. "HasLord"] = nil
		end
		sgs.cardEffect = struct
		if struct.to:hasSkill("chongzhen")
			and (struct.card:isKindOf("AOE") or struct.card:isKindOf("Slash"))
		then
			sgs.chongzhen_target = struct.from
		end
	elseif event == sgs.DamageDone
	then
		local damage = data:toDamage()
		for _, p in sgs.qlist(self.room:getAlivePlayers()) do
			sgs.ai_NeedPeach[p:objectName()] = 0
		end
		if damage.chain
			or damage.nature == sgs.DamageStruct_Normal then
		elseif damage.to:isChained()
		then
			for _, p in sgs.qlist(damage.to:getAliveSiblings()) do
				if p:isChained()
				then
					sgs.ai_NeedPeach[p:objectName()] = damage.damage - p:getHp()
				end
			end
		end
		local reason = damage.card and damage.card:getSkillName() or ""
		if reason == "" then reason = damage.reason end
		local intention = reason == "" and damage.card and sgs.ai_card_intention[damage.card:getClassName()]
		if type(intention) == "function" or type(intention) == "number" then return end
		intention = damage.damage * 40
		damage.from = self.room:findPlayerBySkillName(reason) or damage.from
		if sgs.ai_quhu_effect or reason:match("quhu") then
			sgs.ai_quhu_effect = false
			intention = damage.damage * 30
		elseif damage.from and (damage.from:hasFlag("ShenfenUsing") or damage.from:hasFlag("FenchengUsing") or reason:match("zhendu"))
		then
			intention = damage.damage * 10
		end
		if damage.transfer or damage.chain then intention = damage.damage * 20 end
		if damage.from then sgs.updateIntention(damage.from, damage.to, intention) end
		if reason ~= ""
		then
			if sgs.damageData[reason]
			then
				sgs.damageData[reason] = sgs.damageData[reason] + damage.damage
			else
				sgs.damageData[reason] = damage.damage
			end
		end
	elseif event == sgs.CardUsed
	then
		local struct = data:toCardUse()
		sgs.chongzhen_target = nil
		sgs.ai_qice_data = nil
		sgs.UsedData = struct
		if struct.m_reason == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			struct.from:setFlags("hasUsed" ..
				struct.card:getClassName())
		end
		if struct.card:isKindOf("Duel") and getLord(player) then
			getLord(player):setFlags("-AIGlobal_NeedToWake")
		elseif struct.card:isKindOf("Collateral") then
			sgs.ai_collateral = false
		end
		local sn = struct.card:getSkillName()
		if sn ~= "" and struct.card:getTypeId() > 0
		then
			if sgs.convertData[sn]
			then
				sgs.convertData[sn] = sgs.convertData[sn] + self:getUseValue(struct.card)
			else
				sgs.convertData[sn] = self:getUseValue(struct.card)
			end
		end
	elseif event == sgs.HpRecover
	then
		local rec = data:toRecover()
		local aci = rec.card and sgs.ai_card_intention[rec.card:getClassName()]
		if type(aci) == "function" or type(aci) == "number" then return end
		if rec.who then sgs.updateIntention(rec.who, player, -66 * rec.recover) end
	elseif event == sgs.CardsMoveOneTime
	then
		local move = data:toMoveOneTime()
		local m_to = BeMan(self.room, move.to)
		local m_from = BeMan(self.room, move.from)
		if move.reason.m_skillName == "fenji" then sgs.ai_fenji_target = m_from end
		if move.to_place == sgs.Player_PlaceHand and m_to == player
		then
			local cstring = {}
			if sgs.aiHandCardVisible
				and player:getPhase() <= sgs.Player_Play
			then
				for i, c in sgs.qlist(player:getHandcards()) do
					i = sgs.Sanguosha:translate(c:objectName()) ..
						"[" .. sgs.Sanguosha:translate(c:getSuitString() .. "_char") .. c:getNumberString() .. "]"
					table.insert(cstring, i)
				end
				self.room:writeToConsole(sgs.Sanguosha:translate(player:getGeneralName()) ..
					":HC=" .. table.concat(cstring, "、"))
			end
			cstring = move.reason.m_skillName
			if cstring ~= ""
			then
				if sgs.drawData[cstring]
				then
					sgs.drawData[cstring] = sgs.drawData[cstring] + move.card_ids:length()
				else
					sgs.drawData[cstring] = move.card_ids:length()
				end
			end
		end
		for mp, mc in sgs.qlist(move.card_ids) do
			mp = move.from_places:at(mp)
			if move.to_place == sgs.Player_DrawPile and self.top_draw_pile_id ~= mc
				or mp == sgs.Player_DrawPile then
				self.top_draw_pile_id = nil
			end
			mc = sgs.Sanguosha:getCard(mc)
			if move.to_place == sgs.Player_PlaceHand and player == m_to
			then
				if mc:hasFlag("visible")
				then
					if isCard("Slash", mc, player) then sgs.card_lack[player:objectName()]["Slash"] = 0 end
					if isCard("Jink", mc, player) then sgs.card_lack[player:objectName()]["Jink"] = 0 end
					if isCard("Peach", mc, player) then sgs.card_lack[player:objectName()]["Peach"] = 0 end
				else
					sgs.card_lack[player:objectName()]["Slash"] = 0
					sgs.card_lack[player:objectName()]["Jink"] = 0
					sgs.card_lack[player:objectName()]["Peach"] = 0
					if m_from then
						self.room:setCardFlag(mc, "visible_" .. m_from:objectName() .. "_" ..
							m_to:objectName())
					end
				end
			end
			if move.reason.m_skillName == "qiaobian"
				and m_from and m_to and self.room:getCurrent() == player
			then
				if #self:poisonCards({ mc }, m_from) > 0
				then
					mp = -70
				else
					mp = 70
				end
				sgs.updateIntention(player, m_from, mp)
				if #self:poisonCards({ mc }, m_to) > 0
				then
					mp = 70
				else
					mp = -70
				end
				sgs.updateIntention(player, m_to, mc)
			elseif bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD
			then
				if m_from == player and move.reason.m_playerId ~= player:objectName()
				then
					local m_player = BeMan(self.room, move.reason.m_playerId)
					if m_player
					then
						if mp == sgs.Player_PlaceEquip and (sgs.ai_poison_card[mc:objectName()] or self:evaluateArmor(mc) < -5)
							or mp == sgs.Player_PlaceDelayedTrick then
							mc = -55
						else
							mc = 55
						end
						sgs.updateIntention(m_player, player, mc)
					end
				elseif m_from and move.reason.m_playerId == m_from:objectName()
					and move.reason.m_reason == sgs.CardMoveReason_S_REASON_RULEDISCARD
					and m_from:getPhase() <= sgs.Player_Discard
				then
					if m_from:hasSkills("leiji|nosleiji|olleiji")
						and isCard("Jink", mc, m_from) and m_from:getHandcardNum() >= 2
					then
						sgs.card_lack[m_from:objectName()]["Jink"] = 2 -- 张角用
					elseif sgs.ai_role[m_from:objectName()] == "neutral" and not m_from:isSkipped(sgs.Player_Play)
						and not (m_from:hasSkills("renjie+baiyin") and not m_from:hasSkill("jilve"))
						and CanUpdateIntention(m_from)
					then
						local zhanghe = self.room:findPlayerBySkillName("qiaobian")
						mp = isCard("Indulgence", mc, m_from)
						if mp
						then
							for _, p in ipairs(self.enemies) do
								if zhanghe and self:playerGetRound(zhanghe) <= self:playerGetRound(p) and self:isFriend(zhanghe, p)
									or p:containsTrick("YanxiaoCard") or p:hasSkill("qiaobian") then
									continue
								end
								if m_from:canUse(mp, p) then
									player:setTag("Intention" .. m_from:objectName(), ToData(35))
									break
								end
							end
						end
						mp = isCard("SupplyShortage", mc, m_from)
						if mp
						then
							for _, p in ipairs(self.enemies) do
								if zhanghe and self:playerGetRound(zhanghe) <= self:playerGetRound(p) and self:isFriend(zhanghe, p)
									or p:containsTrick("YanxiaoCard") or p:hasSkill("qiaobian") then
									continue
								end
								if m_from:canUse(mp, p) then
									player:setTag("Intention" .. m_from:objectName(), ToData(35))
									break
								end
							end
						end
						if m_from:hasFlag("JiangchiInvoke")
							or m_from:hasFlag("hasUsed" .. mc:getClassName()) then
						elseif mc:isDamageCard() or not mc:targetFixed()
						then
							for _, ep in ipairs(self.enemies) do
								if m_from:canUse(mc, ep) and self:isGoodTarget(ep, nil, mc)
								then
									player:setTag("Intention" .. m_from:objectName(), ToData(35))
									break
								end
							end
							for _, ep in ipairs(self.friends) do
								if sgs.ai_role[ep:objectName()] ~= "neutral" and m_from:canUse(mc, ep) and self:isGoodTarget(ep, nil, mc)
								then
									player:setTag("Intention" .. m_from:objectName(), ToData(-35))
									break
								end
							end
						end
					end
				end
			elseif m_from and m_to == player
				and (move.reason.m_reason == sgs.CardMoveReason_S_REASON_GIVE or m_to:getTag("PresentCard"):toString() == mc:toString())
			then
				mp = -33
				if move.to_place == sgs.Player_PlaceEquip or mc:hasFlag("visible")
				then
					if #self:poisonCards({ mc }) > 0 then
						mp = 33
					else
						mp = -self:getUseValue(mc) * 2
					end
				end
				sgs.updateIntention(m_from, m_to, mp)
			end
		end
	elseif event == sgs.StartJudge
	then
		local judge = data:toJudge()
		if judge.reason:match("beige")
		then
			local caiwenji = self.room:findPlayerBySkillName(judge.reason)
			sgs.updateIntention(caiwenji, player, -60)
		end
		sgs.ai_judgeGood[judge.reason] = judge:isGood()
		if judge:isGood() and math.random() < 0.4
		then
			if self:speak(judge.reason .. "IsGood") or math.random() < 0.4
				or judge.pattern == "." then
				return
			end
			self:speak("judgeIsGood")
		end
	elseif event == sgs.AskForRetrial
	then
		local judge = data:toJudge()
		local intention = sgs.ai_retrial_intention[judge.reason]
		if type(intention) == "function" then intention = intention(self, judge, sgs.ai_judgeGood[judge.reason]) end
		if type(intention) ~= "number"
		then
			if sgs.ai_judgeGood[judge.reason]
			then
				if judge:isBad() then intention = 30 end
			elseif judge:isGood() then
				intention = -30
			end
		end
		if type(intention) == "number" then sgs.updateIntention(player, judge.who, intention) end
		sgs.ai_judgeGood[judge.reason] = judge:isGood()
	elseif event == sgs.RoundStart
	then
		sgs.turncount = data:toInt()
		if sgs.turncount <= 1
		then
			local hc = 0
			for _, ap in sgs.qlist(self.room:getAllPlayers()) do
				if ap:getState() ~= "robot" then hc = hc + 1 end
			end
			self.room:setTag("humanCount", ToData(hc))
		end
		if player:getMark("drawData_lun") < 1
		then
			for i, m in pairs(sgs.drawData) do
				if m < 0 then continue end
				saveItemData("drawData", i, m)
				if self.room:findPlayerBySkillName(i)
				then
					sgs.drawData[i] = 0
				else
					sgs.drawData[i] = -99
				end
			end
			for i, m in pairs(sgs.convertData) do
				if m < 0 then continue end
				saveItemData("convertData", i, m)
				if self.room:findPlayerBySkillName(i)
				then
					sgs.convertData[i] = 0
				else
					sgs.convertData[i] = -99
				end
			end
			for i, m in pairs(sgs.damageData) do
				if m < 0 then continue end
				saveItemData("damageData", i, m)
				if self.room:findPlayerBySkillName(i)
				then
					sgs.damageData[i] = 0
				else
					sgs.damageData[i] = -99
				end
			end
			for i, m in pairs(sgs.throwData) do
				if m < 0 then continue end
				saveItemData("throwData", i, m)
				if self.room:findPlayerBySkillName(i)
				then
					sgs.throwData[i] = 0
				else
					sgs.throwData[i] = -99
				end
			end
			for _, ap in sgs.qlist(self.room:getAllPlayers()) do
				ap:addMark("drawData_lun")
			end
		end
		if player:getRole() ~= "lord"
			and player:getMark("roleRobot") < 1 and math.random() < 0.2 - sgs.turncount * 0.01
		then
			player:addMark("roleRobot", math.random(10, 30))
		end
	elseif event == sgs.GameReady
		and player:getRole() == "lord"
	then
		sgs.debugmode = io.open("lua/ai/debug")
		if sgs.debugmode
		then
			logmsg("ai.html", "<meta charset='utf-8'/>")
			sgs.debugmode:close()
		end
	end
end

function saveItemData(dataName, data1, data2)
	local file = io.open("lua/ai/data/" .. dataName, "r")
	if file == nil
	then
		file = io.open("lua/ai/data/" .. dataName, "w")
		file:write(data1 .. ":" .. data2)
		file:close()
	else
		local tt = file:read("*all"):split("\n")
		file:close()
		local can = true
		local record = assert(io.open("lua/ai/data/" .. dataName, "w"))
		for t, item in ipairs(tt) do
			if item == "" then continue end
			t = item:split(":")
			if t[1] == data1
			then
				can = false
				record:write(item .. "," .. data2)
			else
				record:write(item)
			end
			record:write("\n")
		end
		if can
		then
			record:write(data1 .. ":" .. data2)
		end
		record:close()
	end
end

function SmartAI:askForSuit(reason)
	if not reason then return sgs.ai_skill_suit.fanjian(self) end
	local callback = sgs.ai_skill_suit[reason]
	if type(callback) == "function"
	then
		callback = callback(self)
		if callback then return callback end
	end
	return math.random(0, 3)
end

function SmartAI:askForSkillInvoke(skill_name, data)
	skill_name = string.gsub(skill_name, "%-", "_")
	local invoke = sgs.ai_skill_invoke[skill_name]
	self.data = data
	if type(invoke) == "boolean" then
	elseif type(invoke) == "function"
	then
		invoke = invoke(self, data)
	else
		invoke = sgs.Sanguosha:getSkill(skill_name)
		if invoke and invoke:getFrequency() == sgs.Skill_Frequent
		then
			return true
		else
			invoke = false
		end
	end
	if sgs.jl_bingfen
		and math.random() > 0.8
	then
		if jl_bingfen1
			and math.random() > 0.6
		then
			self.player:speak(jl_bingfen1[math.random(1, #jl_bingfen1)])
		end
		sgs.JLBFto = self.player
		invoke = not invoke
	end
	return invoke
end

function SmartAI:askForChoice(skill_name, choices, data)
	local choice = sgs.ai_skill_choice[skill_name]
	if type(choice) == "string" then
		return choice
	elseif type(choice) == "function"
	then
		self.data = data
		self.choices = choices
		choice = choice(self, choices, data)
		if choice then return choice end
	end
	choice = choices:split("+")
	if table.contains(choice, "benghuai")
	then
		table.removeOne(choice, "benghuai")
	end
	return choice[math.random(1, #choice)]
end

function getChoice(choices, choice_name, n)
	if type(choices) ~= "table" then
		choices = choices:split("+")
	end
	n = n or 1
	for new_choices, choice in sgs.list(choices) do
		new_choices = choice:split("=")
		if #new_choices < n then continue end
		if new_choices[n] == choice_name
		then
			return choice
		end
	end
end

function SmartAI:askForDiscard(reason, max_num, min_num, optional, equiped, pattern)
	local exchange = self.player:hasFlag("Global_AIDiscardExchanging")
	local callback = sgs.ai_skill_discard[reason]
	min_num = min_num or max_num
	pattern = pattern or "."
	self:assignKeep(true)
	if not optional
	then
		if sgs.throwData[reason] then
			sgs.throwData[reason] = sgs.throwData[reason] + min_num
		else
			sgs.throwData[reason] = min_num
		end
	end
	if type(callback) == "function"
	then
		self.x = max_num
		self.n = min_num
		self.equiped = equiped
		self.pattern = pattern
		self.optional = optional
		callback = callback(self, max_num, min_num, optional, equiped, pattern)
		if type(callback) == "number"
			and (exchange or self.player:canDiscard(self.player, callback))
		then
			callback = { callback }
		elseif type(callback) == "table"
		then
			for _, id in ipairs(callback) do
				if exchange then break end
				if self.player:isJilei(sgs.Sanguosha:getCard(id), self.player:handCards():contains(id))
				then
					return {}
				end
			end
		else
			callback = {}
		end
		return callback
	elseif type(callback) == "table"
	then
		for _, id in ipairs(callback) do
			if exchange then break end
			if self.player:isJilei(sgs.Sanguosha:getCard(id), self.player:handCards():contains(id))
			then
				return {}
			end
		end
		return callback
	elseif optional
		and equiped
	then
		callback = {}
		for i, c in ipairs(self:poisonCards("e")) do
			i = c:getEffectiveId()
			if #callback >= max_num then break end
			if (exchange or self.player:canDiscard(self.player, i))
				and (pattern == "." or sgs.Sanguosha:matchExpPattern(pattern, self.player, c))
			then
				table.insert(callback, i)
			end
		end
		return callback
	end
	local flag = "h"
	if equiped then flag = "he" end
	flag = self.player:getCards(flag)
	flag = self:sortByKeepValue(flag, nil, not exchange and "j")
	local to_discard, temp = {}, {}
	for i, c in ipairs(flag) do
		i = c:getEffectiveId()
		if pattern == "."
			or pattern == ".." and self.player:handCards():contains(i)
			or sgs.Sanguosha:matchExpPattern(pattern, self.player, c)
		then
			if self.room:getCardPlace(i) == sgs.Player_PlaceEquip and self.player:hasSkills(sgs.lose_equip_skill)
				or self:getKeepValue(c) > 4 then
				table.insert(temp, i)
			else
				table.insert(to_discard, i)
			end
		end
		if #to_discard >= min_num then return to_discard end
	end
	if #to_discard < min_num
	then
		for _, id in ipairs(temp) do
			table.insert(to_discard, id)
			if #to_discard >= min_num then return to_discard end
		end
	end
	return to_discard
end

sgs.ai_skill_discard.gamerule = function(self, discard_num, min_num)
	local discard = {}
	for _, c in ipairs(self:sortByKeepValue(self.player:getHandcards())) do
		if self.player:isCardLimited(c, sgs.Card_MethodDiscard, true) then continue end
		table.insert(discard, c:getEffectiveId())
		if #discard >= min_num then return discard end
	end
end

function aiConnect(owner)
	local connects = {}
	for _, s in ipairs(sgs.getPlayerSkillList(owner)) do
		table.insert(connects, s:objectName())
	end
	for t, m in ipairs(owner:getMarkNames()) do
		t = m:split("+")[1]
		if owner:getMark(m) > 0
			and (t:match("&") or t:match("@"))
		then
			table.insert(connects, t)
		end
	end
	for _, pn in ipairs(owner:getPileNames()) do
		if string.sub(pn, 1, 1) == "#" or owner:getPile(pn):isEmpty() or table.contains(connects, pn)
		then else
			table.insert(connects, pn)
		end
	end
	for _, e in sgs.qlist(owner:getEquips()) do
		if table.contains(connects, e:objectName())
		then else
			table.insert(connects, e:objectName())
		end
	end
	return connects
end

---询问无懈可击--
function SmartAI:askForNullification(trick, from, to, positive)
	self.null_num = self:getCard("Nullification", true)
	local null_card
	for _, nc in sgs.list(self.null_num) do
		if self.player:isLocked(nc) then
		else
			null_card = nc
			break
		end
	end
	if from and from:isDead()
		or not (null_card and to and to:isAlive())
		or from and from:hasSkill("funan") and not self:isFriend(from)
		or ("snatch|dismantlement|zhujinqiyuan"):match(trick:objectName()) and to:isAllNude()
		or self:hasSkills("jgjingmiao", self.enemies) and self.player:getHp() < 2
		or to:hasFlag("AIGlobal_NeedToWake") then
		return
	end
	self.null_num = #self.null_num
	if trick:isDamageCard()
	then
		if self:needToLoseHp(to, from, trick)
			or self:canDamageHp(from, trick, to)
		then
			if positive and math.random() >= 1 / self.null_num
				and from ~= self.player and self:isEnemy(to)
				and not self:isWeak(to)
			then
				self:speak("null_card")
				return null_card
			end
			return
		elseif from and positive
			and self:isFriend(to)
		then
			local adn = self:ajustDamage(from, to, 1, trick)
			if adn > 1 or adn >= to:getHp() then return null_card end
		end
	end
	self.to = to
	self.from = from
	self.trick = trick
	self.positive = positive
	for can, ac in ipairs(aiConnect(to)) do
		can = sgs.ai_nullification[ac]
		if type(can) == "function"
		then
			can = can(self, trick, from, to, positive, self.null_num)
			if can then return null_card elseif can ~= nil then return end
		end
	end
	local callback = sgs.ai_nullification[trick:getClassName()]
	if type(callback) == "function"
	then
		callback = callback(self, trick, from, to, positive, self.null_num)
		if callback then return null_card elseif callback ~= nil then return end
	end
	if positive
	then
		if from and trick:isDamageCard() and self:isFriend(from)
			and (self:needDeath(to) or self:cantbeHurt(to, from)) then
			return null_card
		elseif ("snatch|dismantlement|zhujinqiyuan"):match(trick:objectName())
			and self:isEnemy(from) and sgs.ai_role[from:objectName()] ~= "neutral"
		then
			if self:isFriend(to)
			then --敌方拆友方威胁牌、价值牌、最后一张手牌->命中
				if self:getDangerousCard(to)
					or self:getValuableCard(to)
					or to:containsTrick("YanxiaoCard")
				then
					return null_card
				end
				if to:getHandcardNum() == 1
					and not self:needKongcheng(to)
				then
					if getKnownCard(to, self.player, "TrickCard,EquipCard,Slash") == 1
					then
						return
					else
						return null_card
					end
				end
			elseif self:isEnemy(to)
			then --敌方顺手牵羊、过河拆桥敌方判定区延时性锦囊->命中
				if to:getJudgingArea():length() > 0 then return null_card end
			end
		end
		if trick:isKindOf("AOE")
			and self:isFriend(to)
		then --多目标攻击性锦囊
			local lord, current = getLord(self.player), self.room:getCurrent()
			if lord and self:isFriend(lord) and self:isWeak(lord) and self:aoeIsEffective(trick, lord)
				and (lord:getSeat() - current:getSeat()) % to:aliveCount() > (to:getSeat() - current:getSeat()) % to:aliveCount()
				and not (self.player == to and self.player:getHp() < 2 and not self:canAvoidAOE(trick))
			then
				return
			end                     --主公
			if self.player == to
				and not self:canAvoidAOE(trick) --自己
			then
				return null_card
			end
			if self:isWeak(to)
				and self:aoeIsEffective(trick, to)
			then --队友
				if self.null_num > 1
					or self.player:getHp() > 1
					or isLord(to) and self.role == "loyalist"
					or (to:getSeat() - current:getSeat()) % to:aliveCount() > (self.player:getSeat() - current:getSeat()) % to:aliveCount()
					or self:canAvoidAOE(trick)
				then
					return null_card
				end
			end
		end
	else
		if from
		then
			if trick:isDamageCard() and self:isEnemy(from) and (self:needDeath(to) or self:cantbeHurt(to, from))
				or trick:targetFixed() and trick:isKindOf("SingleTargetTrick") and self:isFriend(to)
			then
				return null_card
			end
			if trick:isKindOf("SingleTargetTrick")
				and self:isFriend(from) and not self:isFriend(to)
			then
				if ("snatch|dismantlement|zhujinqiyuan"):match(trick:objectName()) and to:isNude()
				then else
					return null_card
				end
			end
		elseif self:isEnemy(to)
			and math.random() > 1 / (self.null_num + 1)
		then
			return null_card
		end
	end
end

function SmartAI:getCardRandomly(who, flags)
	if who == self.player
	then
		for i, c in sgs.list(self:sortByKeepValue(who:getCards(flags))) do
			i = c:getEffectiveId()
			if self.disabled_ids:contains(i)
			then else
				return i
			end
		end
		return -1
	end
	local ids = {}
	for i, c in sgs.list(who:getCards(flags)) do
		i = c:getEffectiveId()
		if self.disabled_ids:contains(i)
		then else
			table.insert(ids, i)
		end
	end
	if #ids < 1 then return -1 end
	local ir = math.random(1, #ids)
	local id = ids[ir]
	if who:getArmor() and who:hasArmorEffect("silver_lion")
		and who:isWounded() and self:isEnemy(who)
		and id == who:getArmor():getEffectiveId()
	then
		if ir ~= #ids then
			id = ids[ir + 1]
		elseif ir > 1 then
			id = ids[ir - 1]
		end
	end
	return id
end

function SmartAI:askForCardChosen(who, flags, reason, method)
	self.disabled_ids = self.player:getTag("askForCardChosen_ForAI"):toIntList()
	local no_dis, cid
	self.who = who
	self.flags = flags
	self.method = method
	if method == sgs.Card_MethodDiscard
	then
		if sgs.throwData[reason] then
			sgs.throwData[reason] = sgs.throwData[reason] + 1
		else
			sgs.throwData[reason] = 1
		end
	else
		no_dis = true
	end
	for _, s in sgs.list(sgs.getPlayerSkillList(who)) do
		cid = sgs.ai_skill_cardchosen["#" .. s:objectName()]
		if type(cid) == "function"
		then
			cid = cid(self, who, flags, method)
			if cid and type(cid) ~= "number" then cid = cid:getEffectiveId() end
			if cid and not self.disabled_ids:contains(cid) then return cid end
		end
	end
	cid = sgs.ai_skill_cardchosen[string.gsub(reason, "%-", "_")]
	if type(cid) == "function"
	then
		cid = cid(self, who, flags, method)
		if cid and type(cid) ~= "number" then cid = cid:getEffectiveId() end
		if cid and not self.disabled_ids:contains(cid)
		then
			return cid < 0 and -2 or cid
		end
	elseif type(cid) == "number"
	then
		sgs.ai_skill_cardchosen[string.gsub(reason, "%-", "_")] = nil
		if cid < 0 then return -2 end
		if not self.disabled_ids:contains(cid)
		then
			return cid < 0 and -2 or cid
		end
	end
	if ("snatch|dismantlement|yinling|danshou"):match(reason)
	then
		cid = nil
		local flag = "AIGlobal_SDCardChosen_" .. reason
		for i, c in sgs.list(who:getCards(flags)) do
			if c:hasFlag(flag)
			then
				c:setFlags("-" .. flag)
				i = c:getEffectiveId()
				if self:canDisCard(who, i)
				then
					cid = i
					break
				end
			end
		end
		if cid
		then
			if who:handCards():contains(cid)
				and sgs.getMode == "02_1v1"
				and sgs.GetConfig("1v1/Rule", "Classical") == "2013"
				and reason == "dismantlement"
			then
				local peach, jink
				cards = who:getHandcards()
				for i, c in sgs.list(cards) do
					i = c:getEffectiveId()
					if self.disabled_ids:contains(i) then continue end
					if not peach and isCard("Peach", c, who) then peach = i end
					if not jink and isCard("Jink", c, who) then jink = i end
					if peach and jink then break end
				end
				if peach or jink then return peach or jink end
				cards = self:sortByKeepValue(cards, true)
				for i, c in sgs.list(cards) do
					i = c:getEffectiveId()
					if self.disabled_ids:contains(i)
					then
						continue
					end
					return i
				end
			end
			return cid
		end
	end
	if self:isFriend(who)
	then
		if flags:match("j")
			and not (who:hasSkill("qiaobian") and who:getHandcardNum() > 0)
		then
			local lightning, indulgence, supply_shortage
			for i, trick in sgs.list(who:getJudgingArea()) do
				i = trick:getEffectiveId()
				if self:canDisCard(who, i, nil, no_dis)
				then
					if trick:isDamageCard() then
						lightning = i
					elseif trick:isKindOf("Indulgence") then
						indulgence = i
					elseif not trick:isKindOf("Disaster") then
						supply_shortage = i
					end
				end
			end
			if lightning and self:hasWizard(self.enemies)
			then
				return lightning
			end
			if indulgence and supply_shortage
			then
				if who:getHp() >= who:getHandcardNum()
				then
					return supply_shortage
				else
					return indulgence
				end
			end
			if indulgence or supply_shortage
			then
				return indulgence or supply_shortage
			end
		end
		if flags:match("e")
		then
			cid = who:getArmor()
			cid = cid and cid:getEffectiveId()
			if cid and self:needToThrowArmor(who, reason == "moukui")
				and self:canDisCard(who, cid, nil, no_dis)
			then
				return cid
			end
			if cid and self:canDisCard(who, cid, nil, no_dis)
			then
				return cid
			end
			cid = who:getWeapon()
			cid = cid and cid:getEffectiveId()
			if cid and self:canDisCard(who, cid, nil, no_dis)
			then
				return cid
			end
			cid = who:getOffensiveHorse()
			cid = cid and cid:getEffectiveId()
			if cid and self:canDisCard(who, cid, nil, no_dis)
			then
				return cid
			end
			cid = who:getDefensiveHorse()
			cid = cid and cid:getEffectiveId()
			if cid and self:canDisCard(who, cid, nil, no_dis)
			then
				return cid
			end
			cid = who:getTreasure()
			cid = cid and cid:getEffectiveId()
			if cid and self:canDisCard(who, cid, nil, no_dis)
			then
				return cid
			end
			if who:hasSkills(sgs.lose_equip_skill)
				and self:isWeak(who)
			then
				cid = who:getWeapon()
				cid = cid and cid:getEffectiveId()
				if cid and self:canDisCard(who, cid, nil, no_dis)
				then
					return cid
				end
				cid = who:getOffensiveHorse()
				cid = cid and cid:getEffectiveId()
				if cid and self:canDisCard(who, cid, nil, no_dis)
				then
					return cid
				end
			end
		end
		if flags:match("h") and who:objectName() ~= self.player:objectName()
		then
			return self:getCardRandomly(who, "h")
		elseif who:objectName() == self.player:objectName()
		then
			for i, c in ipairs(self:sortByKeepValue(self.player:getCards(flags))) do
				i = c:getEffectiveId()
				if self.disabled_ids:contains(i)
				then
					continue
				end
				return i
			end
		end
	else
		if flags:match("e")
		then
			cid = self:getDangerousCard(who)
			if cid and self:canDisCard(who, cid, nil, no_dis)
			then
				return cid
			end
			cid = who:getTreasure()
			cid = cid and cid:getEffectiveId()
			if cid and who:getPile("wooden_ox"):length() > 1
				and self:canDisCard(who, cid, nil, no_dis)
			then
				return cid
			end
			cid = who:getArmor()
			cid = cid and cid:getEffectiveId()
			if cid and who:hasArmorEffect("eight_diagram")
				and not self:needToThrowArmor(who, reason == "moukui")
				and self:canDisCard(who, cid, nil, no_dis)
			then
				return cid
			end
			if who:hasSkills("jijiu|beige|mingce|weimu|qingcheng")
				and not self:doNotDiscard(who, "e", false, 1, reason)
			then
				cid = who:getDefensiveHorse()
				cid = cid and cid:getEffectiveId()
				if cid and self:canDisCard(who, cid, nil, no_dis)
				then
					return cid
				end
				cid = who:getArmor()
				cid = cid and cid:getEffectiveId()
				if cid and not self:needToThrowArmor(who, reason == "moukui")
					and self:canDisCard(who, cid, nil, no_dis)
				then
					return cid
				end
				cid = who:getOffensiveHorse()
				if cid and (not who:hasSkill("jijiu") or cid:isRed())
					and self:canDisCard(who, cid:getEffectiveId(), nil, no_dis)
				then
					return cid:getEffectiveId()
				end
				cid = who:getWeapon()
				if cid and (not who:hasSkill("jijiu") or cid:isRed())
					and self:canDisCard(who, cid:getEffectiveId(), nil, no_dis)
				then
					return cid:getEffectiveId()
				end
			end
			cid = self:getValuableCard(who)
			if cid and self:canDisCard(who, cid, nil, no_dis)
			then
				return cid
			end
		end
		if flags:match("h")
			and self:canDisCard(who, "h", nil, no_dis)
		then
			if who:hasSkills("jijiu|qingnang|qiaobian|jieyin|beige|buyi|manjuan")
				and not who:isKongcheng() and who:getHandcardNum() <= 2
				and not self:doNotDiscard(who, "h", false, 1, reason)
			then
				return self:getCardRandomly(who, "h")
			end
			if who:getHandcardNum() <= 2
				and not self:doNotDiscard(who, "h", false, 1, reason)
			then
				for _, h in sgs.list(who:getHandcards()) do
					if (h:hasFlag("visible") or h:hasFlag("visible_" .. self.player:objectName() .. "_" .. who:objectName()))
						and (h:isKindOf("Peach") or h:isKindOf("Analeptic"))
					then
						return self:getCardRandomly(who, "h")
					end
				end
			end
		end
		if flags:match("j")
		then
			local lightning, yanxiao
			for i, trick in sgs.list(who:getJudgingArea()) do
				i = trick:getEffectiveId()
				if trick:isDamageCard()
					and self:canDisCard(who, i, nil, no_dis)
				then
					lightning = i
				elseif trick:isKindOf("YanxiaoCard")
					and self:canDisCard(who, i, nil, no_dis)
				then
					yanxiao = i
				end
			end
			if lightning and self:getFinalRetrial(self.player) > 1
			then
				return lightning
			end
			if yanxiao then
				return yanxiao
			end
		end
		if flags:match("h") and not self:doNotDiscard(who, "h")
			and self:canDisCard(who, "h", nil, no_dis)
		then
			if who:hasSkills(sgs.cardneed_skill)
				or (who:getHandcardNum() == 1 and sgs.getDefenseSlash(who, self) < 3 and who:getHp() <= 2)
			then
				return self:getCardRandomly(who, "h")
			end
		end
		if flags:match("e") and not self:doNotDiscard(who, "e")
		then
			cid = who:getDefensiveHorse()
			cid = cid and cid:getEffectiveId()
			if cid and not self:needToThrowArmor(who, reason == "moukui")
				and self:canDisCard(who, cid, nil, no_dis)
			then
				return cid
			end
			cid = who:getTreasure()
			cid = cid and cid:getEffectiveId()
			if cid and self:canDisCard(who, cid, nil, no_dis)
			then
				return cid
			end
		end
		if flags:match("h")
			and self:canDisCard(who, "h", nil, no_dis)
		then
			if (who:getHandcardNum() > 0 and who:getHandcardNum() <= 2)
				and not self:doNotDiscard(who, "h", false, 1, reason)
			then
				return self:getCardRandomly(who, "h")
			end
		end
	end
	return self:getCardRandomly(who, flags)
end

function SmartAI:canDisCard(to, flags, from, no_dis)
	from = from or self.player
	flags = flags or "hej"
	if no_dis or from:canDiscard(to, flags)
	then else
		return
	end
	if type(flags) == "number"
	then
		if not no_dis and to:hasSkill("zhexiu") and to:getEquips():length() < 2 and to:getEquipsId():contains(flags)
			or self.disabled_ids:contains(flags) then
			return
		end
		if self:isFriend(to)
		then
			if to:getJudgingAreaID():contains(flags)
			then
				if sgs.Sanguosha:getCard(flags):isDamageCard() and self:getFinalRetrial(to) == 1
					or to:containsTrick("YanxiaoCard") then
					return
				else
					return true
				end
			end
			return #self:poisonCards({ flags }, to) > 0
		else
			if to:getJudgingAreaID():contains(flags)
			then
				flags = sgs.Sanguosha:getCard(flags)
				if flags:isDamageCard() and self:getFinalRetrial(from) > 1
					or flags:isKindOf("YanxiaoCard") then
					return true
				end
			end
			return #self:poisonCards({ flags }, to) < 1
		end
	else
		local is_friend = self:isFriend(to)
		if flags:match("j")
		then
			if is_friend then
				if #self:poisonCards("j", to) > 0 then return true end
			elseif #self:poisonCards("j", to) < 1 then
				return true
			end
		end
		if flags:match("e")
		then
			if is_friend then
				if #self:poisonCards("e", to) > 0 then return true end
			elseif #self:poisonCards("e", to) < 1 then
				return true
			end
		end
		if flags:match("h")
		then
			if self:needKongcheng(to) and to:getHandcardNum() == 1
			then
				return is_friend
			end
		end
	end
end

function sgs.ai_skill_cardask.nullfilter(self, data, pattern, target)
	if target and hasJueqingEffect(target, self.player) then return end
	local effect = type(data) == "userdata" and data:toSlashEffect()
	local nature = sgs.DamageStruct_Normal
	if effect and effect.slash then
		nature = effect.nature
		if effect.slash:hasFlag("nosjiefan-slash")
			and self:isFriend(self.room:getTag("NosJiefanTarget"):toPlayer())
			and not self:isEnemy(self.room:findPlayerBySkillName("nosjiefan"))
		then
			return "."
		end
	end
	if target and self:needDeath()
		or self:needBear() and self.player:getHp() > 2
		or not self:damageIsEffective(nil, nature, target)
		or target and target:hasSkill("guagu") and self.player:getRole() == "lord"
		or self:needToLoseHp(self.player, target, effect and effect.slash)
		or target and sgs.ai_role[target:objectName()] == "rebel" and self.role == "rebel" and self.player:hasFlag("AI_doNotSave")
	then
		return "."
	end
end

function SmartAI:askForCard(pattern, prompt, data)
	local compulsive, parsed = pattern:match("!"), prompt:split(":")
	if compulsive then pattern = string.sub(pattern, 1, -2) end
	local callback = type(data) == "userdata" and data:toCardEffect()
	if callback and callback.from and not compulsive and callback.card:isDamageCard()
		and self:canDamageHp(callback.from, callback.card) then
		return "."
	end
	if parsed[2]
	then
		for _, p in sgs.qlist(self.room:getPlayers()) do
			if p:getGeneralName() == parsed[2]
				or p:objectName() == parsed[2]
			then
				self.target = p
				break
			end
		end
		if parsed[3]
		then
			for _, p in sgs.qlist(self.room:getPlayers()) do
				if p:getGeneralName() == parsed[3]
					or p:objectName() == parsed[3]
				then
					self.target2 = p
					break
				end
			end
		end
	end
	self.data = data
	self.pattern = pattern
	self.prompt = prompt
	self.parsed4 = parsed[4]
	self.parsed5 = parsed[5]
	callback = sgs.ai_skill_cardask[parsed[1]]
	if type(callback) == "function"
	then
		callback = callback(self, data, pattern, self.target, self.target2, parsed[4], parsed[5])
		if type(callback) == "number"
			or type(callback) == "string"
		then
			if not (compulsive and callback == ".")
			then
				return callback
			end
		elseif type(callback) == "boolean"
		then
			if callback then
				compulsive = true
			elseif not compulsive and callback == false
			then
				return "."
			end
		end
	end
	callback = sgs.Sanguosha:getCurrentCardUseReason()
	if callback == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE
		or callback == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
	then
		parsed = {}
		for _, c in ipairs(self:addHandPile("he")) do
			callback = c:isKindOf("Slash") and "Slash" or c:getClassName()
			if table.contains(parsed, callback) then continue end
			if pattern:match(c:objectName()) or pattern:match(callback)
				or sgs.Sanguosha:matchExpPattern(pattern, self.player, c)
			then
				table.insert(parsed, callback)
			end
		end
		for c, p in ipairs(patterns) do
			c = dummyCard(p)
			if c
			then
				callback = c:isKindOf("Slash") and "Slash" or c:getClassName()
				if table.contains(parsed, callback) then continue end
				if pattern:match(c:objectName()) or pattern:match(callback)
					or sgs.Sanguosha:matchExpPattern(pattern, self.player, c)
				then
					table.insert(parsed, callback)
				end
			end
		end
		for dc, cn in ipairs(parsed) do
			if sgs.ai_skill_cardask.nullfilter(self, data, pattern, target) == "."
			then
				sgs.card_lack[self.player:objectName()][cn] = 1
				continue
			end
			for _, c in sgs.list(self:getCard(cn, true)) do
				dc = c
				if c:isKindOf("SkillCard")
				then
					dc = dummyCard(sgs.patterns[cn])
					if dc
					then
						dc:setSuit(c:getSuit())
						dc:setNumber(c:getNumber())
						dc:addSubcards(c:getSubcards())
					end
				end
				if dc and sgs.Sanguosha:matchExpPattern(cn .. "," .. pattern, self.player, dc)
				then
					return c:toString()
				end
				if dc and sgs.Sanguosha:matchExpPattern(pattern, self.player, dc)
				then
					return c:toString()
				end
			end
		end
	end
	if compulsive
	then
		for _, c in ipairs(self:sortByKeepValue(self.player:getCards("he"))) do
			if pattern == ".." or pattern == "." and self.player:getHandcards():contains(c)
				or sgs.Sanguosha:matchExpPattern(pattern, self.player, c)
			then
				return c:getEffectiveId()
			end
		end
	end
	return "."
end

for cn, name in pairs(sgs.patterns) do
	if type(sgs.ai_skill_use[name]) == "function" then continue end
	sgs.ai_skill_use[name] = function(self, prompt, method)
		for d, c in ipairs(self:getCard(cn, true)) do
			d = self:aiUseCard(c)
			if d.card and d.to
			then
				if c:canRecast() and d.to:length() < 1
					and method ~= sgs.Card_MethodRecast
				then
					continue
				end
				local c_tos = {}
				for _, p in sgs.list(d.to) do
					table.insert(c_tos, p:objectName())
				end
				return c:toString() .. "->" .. table.concat(c_tos, "+")
			end
		end
	end
	if type(sgs.ai_skill_use[cn]) == "function" then continue end
	sgs.ai_skill_use[cn] = function(self, prompt, method)
		for d, c in ipairs(self:getCard(cn, true)) do
			d = self:aiUseCard(c)
			if d.card and d.to
			then
				if c:canRecast() and d.to:length() < 1
					and method ~= sgs.Card_MethodRecast
				then
					continue
				end
				local c_tos = {}
				for _, p in sgs.list(d.to) do
					table.insert(c_tos, p:objectName())
				end
				return c:toString() .. "->" .. table.concat(c_tos, "+")
			end
		end
	end
end

sgs.armorName = {}

for c = 1, sgs.Sanguosha:getCardCount() do
	c = sgs.Sanguosha:getEngineCard(c - 1)
	if c:isKindOf("Weapon") then
		sgs.weapon_range[c:getClassName()] = c:property("weaponRange"):toInt()
	elseif c:isKindOf("Armor") then
		sgs.armorName[c:objectName()] = true
	end
	if c:isDamageCard() then
		sgs.dynamic_value.damage_card[c:getClassName()] = true
	elseif c:targetFixed() then
		sgs.dynamic_value.benefit[c:getClassName()] = true
	end
	if type(sgs.ai_skill_use[c:toString()]) == "function" then continue end
	sgs.ai_skill_use[c:toString()] = function(self, prompt, method)
		c = sgs.Sanguosha:getCard(c:getEffectiveId())
		if self.player:isLocked(c) then return end
		local d = self:aiUseCard(c)
		if d.card and d.to
		then
			if c:canRecast() and d.to:length() < 1
				and method ~= sgs.Card_MethodRecast
			then
				return
			end
			local c_tos = {}
			for _, p in sgs.list(d.to) do
				table.insert(c_tos, p:objectName())
			end
			return c:toString() .. "->" .. table.concat(c_tos, "+")
		end
	end
end

function SmartAI:askForUseCard(pattern, prompt, method)
	local func, compulsive = sgs.ai_skill_use[pattern], pattern:match("!")
	if compulsive then pattern = string.sub(pattern, 1, -2) end
	self.prompt = prompt
	self.method = method
	self.pattern = pattern
	if type(func) == "function"
	then
		func = func(self, prompt, method, pattern)
		if type(func) == "string" and not (compulsive and func == ".") then return func end
	end
	func = prompt:split(":")[1]
	func = sgs.ai_skill_use[func]
	if type(func) == "function"
	then
		func = func(self, prompt, method, pattern)
		if type(func) == "string" and not (compulsive and func == ".") then return func end
	end
	if pattern:match("@") then return "." end
	for _, pn in ipairs(pattern:split("|")[1]:split(",")) do
		for d, c in ipairs(self:getCard(pn, true)) do
			func = c
			if c:isKindOf("SkillCard")
			then
				func = dummyCard(sgs.patterns[pn])
				if func
				then
					func:addSubcards(c:getSubcards())
					func:setNumber(c:getNumber())
					func:setSuit(c:getSuit())
				end
			end
			if func and sgs.Sanguosha:matchExpPattern(pattern, self.player, func)
			then
				d = self:aiUseCard(func)
				if d.card and d.to
				then
					if func:canRecast() and d.to:length() < 1
						and method ~= sgs.Card_MethodResponse
					then
						continue
					end
					tos = {}
					for _, p in sgs.list(d.to) do
						table.insert(tos, p:objectName())
					end
					return c:toString() .. "->" .. table.concat(tos, "+")
				end
			end
		end
	end
	for d, c in ipairs(self:sortByUseValue(self:addHandPile("he"))) do
		if sgs.Sanguosha:matchExpPattern(pattern, self.player, c)
		then
			d = self:aiUseCard(c)
			if d.card and d.to
			then
				if c:canRecast() and d.to:length() < 1
					and method ~= sgs.Card_MethodResponse
				then
					continue
				end
				tos = {}
				for _, p in sgs.list(d.to) do
					table.insert(tos, p:objectName())
				end
				return c:toString() .. "->" .. table.concat(tos, "+")
			end
		end
	end
	return "."
end

function SmartAI:askForAG(card_ids, refusable, reason)
	if #card_ids < 1 then return -1 end
	self.card_ids = card_ids
	self.refusable = refusable
	self.reason = reason
	local cardchosen = sgs.ai_skill_askforag[string.gsub(reason, "%-", "_")]
	if type(cardchosen) == "function"
	then
		cardchosen = cardchosen(self, card_ids)
		if cardchosen and table.contains(card_ids, cardchosen)
		then
			return cardchosen
		elseif refusable then
			return -1
		end
	elseif type(cardchosen) == "number"
	then
		if table.contains(card_ids, cardchosen) then
			return cardchosen
		elseif refusable then
			return -1
		end
	end
	if refusable and reason == "xinzhan"
	then
		cardchosen = self.player:getNextAlive()
		if self:isFriend(cardchosen)
			and cardchosen:containsTrick("indulgence")
			and not cardchosen:containsTrick("YanxiaoCard")
		then
			if #card_ids == 1 then return -1 end
		end
		for _, id in sgs.list(card_ids) do
			if sgs.Sanguosha:getCard(id):isKindOf("Shit")
			then else
				return id
			end
		end
		return -1
	end
	for _, id in sgs.list(card_ids) do
		if isCard("Peach", id, self.player)
		then
			return id
		end
	end
	for _, id in sgs.list(card_ids) do
		if isCard("Indulgence", id, self.player)
			and not (self:isWeak() and self:getCardsNum("Jink") < 1)
		then
			return id
		end
		if isCard("AOE", id, self.player)
			and not (self:isWeak() and self:getCardsNum("Jink") < 1)
		then
			return id
		end
	end
	return sgs.ai_skill_askforag.amazing_grace(self, card_ids)
end

sgs.ai_skill_askforag.AgCardsToName = function(self, card_ids)
	for _, id in sgs.list(card_ids) do
		if self.ACTN == sgs.Sanguosha:getCard(id):objectName()
		then
			return id
		end
	end
end

function SmartAI:askForCardShow(requestor, reason)
	local func = sgs.ai_cardshow[reason]
	self.requestor = requestor
	if func
	then
		func = func(self, requestor)
		if func then return func end
	end
	return self.player:getRandomHandCard()
end

function sgs.ai_cardneed.bignumber(to, card, self)
	if not self:willSkipPlayPhase(to) and self:getUseValue(card) < 6
	then
		return card:getNumber() > 10
	end
end

function sgs.ai_cardneed.equip(to, card, self)
	if not self:willSkipPlayPhase(to) then
		return card:isKindOf("EquipCard")
	end
end

function sgs.ai_cardneed.weapon(to, card, self)
	if not self:willSkipPlayPhase(to) then
		return card:isKindOf("Weapon")
	end
end

function SmartAI:getEnemyNumBySeat(from, to, target, include_neutral)
	target = target or from
	local players = sgs.QList2Table(self.room:getAllPlayers())
	local to_seat, enemynum = (to:getSeat() - from:getSeat()) % #players, 0
	for _, p in sgs.list(players) do
		if (self:isEnemy(target, p) or include_neutral and not self:isFriend(target, p))
			and ((p:getSeat() - from:getSeat()) % #players) < to_seat
		then
			enemynum = enemynum + 1
		end
	end
	return enemynum
end

function SmartAI:getFriendNumBySeat(from, to)
	local players, friendnum = sgs.QList2Table(self.room:getAllPlayers()), 0
	for _, p in sgs.list(players) do
		if self:isFriend(from, p) and ((p:getSeat() - from:getSeat()) % #players) < (to:getSeat() - from:getSeat()) % #players
		then
			friendnum = friendnum + 1
		end
	end
	return friendnum
end

function SmartAI:needKongcheng(player, keep)
	player = player or self.player
	if keep then
		return player:getHandcardNum() < 1
			and (player:hasSkill("kongcheng") or player:hasSkill("zhiji") and player:getMark("zhiji") < 1
				or player:hasSkill("mobilezhiji") and player:getMark("mobilezhiji") < 1 or player:hasSkill("olzhiji") and player:getMark("olzhiji") < 1)
	end
	if not player:hasFlag("stack_overflow_xiangle")
		and player:hasSkill("beifa") and player:getHandcardNum() > 0
		and sgs.ais[player:objectName()]:aiUseCard(dummyCard()).card
	then
		return true
	end
	if not self:hasLoseHandcardEffective(player) and player:getHandcardNum() > 0 then return true end
	if player:hasSkill("zhiji") and player:getMark("zhiji") < 1 then return true end
	if player:hasSkill("mobilezhiji") and player:getMark("mobilezhiji") < 1 then return true end
	if player:hasSkill("olzhiji") and player:getMark("olzhiji") < 1 then return true end
	if player:hasSkill("shude") and player:getPhase() == sgs.Player_Play then return true end

	--add
	if player:hasSkill("LuaJuejing") and player:getMark("LuaJuejing") < 1 then return true end
	return player:hasSkills(sgs.need_kongcheng)
end

function SmartAI:needToThrowLastHandcard(player, handnum)
	handnum = handnum or 1
	player = player or self.player
	if player:getHandcardNum() > handnum then return false end
	if player:hasSkill("kongcheng")
		or player:hasSkill("zhiji") and player:getMark("zhiji") < 1
		or player:hasSkill("mobilezhiji") and player:getMark("mobilezhiji") < 1
		or player:hasSkill("olzhiji") and player:getMark("olzhiji") < 1
		--add
		or player:hasSkill("LuaJuejing") and player:getMark("LuaJuejing") < 1
	then
		return true
	end
	return false
end

function SmartAI:getLeastHandcardNum(player)
	local least = 0
	player = player or self.player
	if player:hasSkills("lianying|noslianying") and least < 1 then least = 1 end
	if least < 1 and self:hasSkills("shoucheng", self.friends) then least = 1 end
	if player:hasSkill("shangshi") and least < math.min(2, player:getLostHp()) then
		least = math.min(2,
			player:getLostHp())
	end
	if player:hasSkill("nosshangshi") and least < player:getLostHp() then least = player:getLostHp() end

	--add
	if player:hasSkill("LuaXiongcai") and player:getPhase() ~= sgs.Player_Discard and least < 3
	then
		least = 3
	end

	return least
end

function SmartAI:hasLoseHandcardEffective(player, num)
	player = player or self.player
	num = num or player:getHandcardNum()
	return num > self:getLeastHandcardNum(player)
end

function SmartAI:hasCrossbowEffect(player)
	player = player or self.player
	if player:hasWeapon("crossbow")
		or player:hasSkills("paoxiao|tenyearpaoxiao|olpaoxiao")
	then
		return true
	end
	local num, slashs = 0, sgs.ais[player:objectName()]:getCards("Slash")
	for _, s in sgs.list(slashs) do
		num = num + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, player, s)
	end
	return num > #slashs / 2
end

function SmartAI:getCardNeedPlayer(cards, include_self, tos)
	cards = cards or sgs.QList2Table(self.player:getHandcards())
	local tos = tos or include_self and self.room:getAlivePlayers() or self.room:getOtherPlayers(self.player)
	tos = sgs.QList2Table(tos)
	if #tos < 1 then return end

	PC = self:poisonCards(cards)

	local friends = {}
	for l, p in sgs.list(tos) do
		l = self:objectiveLevel(p)
		exclude = self:needKongcheng(p) or self:willSkipPlayPhase(p)
		if p:hasSkills("keji|qiaobian|shensu") or p:getHp() - p:getHandcardNum() >= 3
			or p:getRole() == "lord" and self:isWeak(p) and self:getEnemyNumBySeat(self.player, p) >= 1
		then
			exclude = false
		end
		if l <= -2 and not hasManjuanEffect(p) and not exclude
		then
			table.insert(friends, p)
		end
		if l >= 0
		then
			for i, c in sgs.list(PC) do
				if c:getTypeId() < 3
				then
					return c, p
				end
			end
		end
	end

	local AssistTarget = self:AssistTarget()
	if AssistTarget and (self:needKongcheng(AssistTarget, true) or self:willSkipPlayPhase(AssistTarget) or AssistTarget:hasSkill("manjuan"))
	then
		AssistTarget = nil
	end

	if self.role ~= "renegade"
	then
		local R_num = sgs.playerRoles.renegade
		if R_num > 0 and #friends > R_num
		then
			local k, temp_friends, new_friends = 0, {}, {}
			for _, p in sgs.list(friends) do
				if k < R_num and sgs.explicit_renegade and sgs.ai_role[p:objectName()] == "renegade"
				then
					k = k + 1
					if AssistTarget and p:objectName() == AssistTarget:objectName() then AssistTarget = nil end
				else
					table.insert(temp_friends, p)
				end
			end
			if k == R_num then
				friends = temp_friends
			else
				cmp = function(a, b)
					ar_value, br_value = sgs.roleValue[a:objectName()]["renegade"],
						sgs.roleValue[b:objectName()]["renegade"]
					al_value, bl_value = sgs.roleValue[a:objectName()]["loyalist"],
						sgs.roleValue[b:objectName()]["loyalist"]
					return (ar_value > br_value) or (ar_value == br_value and al_value > bl_value)
				end
				table.sort(temp_friends, cmp)
				for _, p in sgs.list(temp_friends) do
					if k < R_num and sgs.roleValue[p:objectName()]["renegade"] > 0
					then
						k = k + 1
						if AssistTarget and p:objectName() == AssistTarget:objectName() then AssistTarget = nil end
					else
						table.insert(new_friends, p)
					end
				end
				friends = new_friends
			end
		end
	end
	local specialnum = 0
	-- special move between liubei and xunyu and huatuo
	for _, player in sgs.list(friends) do
		if player:hasSkill("jieming") or player:hasSkill("jijiu")
		then
			specialnum = specialnum + 1
		end
		for i, c in sgs.list(PC) do
			if c:getTypeId() > 2
			then
				return c, player
			end
		end
	end
	local keptslash, cardtogivespecial = 0, {}
	if specialnum > 1 and #cardtogivespecial < 1 and self.player:hasSkill("nosrende") and self.player:getPhase() == sgs.Player_Play
	then
		redcardnum = 0
		xunyu = self.room:findPlayerBySkillName("jieming")
		huatuo = self.room:findPlayerBySkillName("jijiu")
		for _, acard in sgs.list(cards) do
			if isCard("Slash", acard, self.player)
			then
				if self.player:canSlash(xunyu) and self:slashIsEffective(acard, xunyu)
				then
					keptslash = keptslash + 1
				end
				if keptslash > 0 then
					table.insert(cardtogivespecial, acard)
				end
			elseif isCard("Duel", acard, self.player)
			then
				table.insert(cardtogivespecial, acard)
			end
		end
		for _, hcard in sgs.list(cardtogivespecial) do
			if hcard:isRed() then redcardnum = redcardnum + 1 end
		end
		if self.player:getHandcardNum() > #cardtogivespecial and redcardnum > 0
		then
			for _, hcard in sgs.list(cardtogivespecial) do
				if hcard:isRed() then return hcard, huatuo end
				return hcard, xunyu
			end
		end
	end

	-- keep a jink
	local cardtogive, keptjink = {}, 0
	for _, acard in sgs.list(cards) do
		if isCard("Jink", acard, self.player) and keptjink < 1
		then
			keptjink = keptjink + 1
		else
			table.insert(cardtogive, acard)
		end
	end

	-- weak
	self:sort(friends, "defense")
	for _, friend in sgs.list(friends) do
		if self:isWeak(friend) and friend:getHandcardNum() < 3
		then
			for _, hcard in sgs.list(cards) do
				if hcard:isKindOf("Shit") then
				elseif isCard("Peach", hcard, friend) or (isCard("Jink", hcard, friend) and self:getEnemyNumBySeat(self.player, friend) > 0) or isCard("Analeptic", hcard, friend)
				then
					return hcard, friend
				end
			end
		end
	end

	if self.player:hasSkill("nosrende") and self.player:isWounded() and self.player:getMark("nosrende") < 2
	then
		if self.player:getHandcardNum() < 2 and self.player:getMark("nosrende") < 1 then return end
	end
	if self.player:hasSkill("rende") and not self.player:hasUsed("RendeCard") and self.player:isWounded() and self.player:getMark("rende") < 2
	then
		if self.player:getHandcardNum() < 2 and self.player:getMark("rende") < 1 then return end

		if (self.player:getHandcardNum() == 2 and self.player:getMark("rende") == 0
				or self.player:getHandcardNum() == 1 and self.player:getMark("rende") == 1)
			and self:getOverflow() <= 0
		then
			for _, enemy in sgs.list(self.enemies) do
				if enemy:hasWeapon("guding_blade")
					and (enemy:canSlash(self.player) or enemy:hasSkill("shensu") or enemy:hasSkills("wushen|olwushen") or enemy:hasSkill("jiangchi")) then
					return
				end
				if enemy:canSlash(self.player, nil, true) and enemy:hasSkill("nosqianxi") and enemy:distanceTo(self.player) == 1 then return end
			end
		end
	end

	-- Armor,DefensiveHorse
	for _, friend in sgs.list(friends) do
		if friend:getHp() <= 2 and friend:faceUp()
		then
			for _, hcard in sgs.list(cards) do
				if (hcard:isKindOf("Armor") and not friend:getArmor() and not self:hasSkills("yizhong|bazhen", friend))
					or (hcard:isKindOf("DefensiveHorse") and not friend:getDefensiveHorse())
				then
					return hcard, friend
				end
			end
		end
	end

	-- jijiu,jieyin
	self:sortByUseValue(cards, true)
	for _, friend in sgs.list(friends) do
		if friend:hasSkills("jijiu|jieyin") and friend:getHandcardNum() < 4
		then
			for _, hcard in sgs.list(cards) do
				if (hcard:isRed() and friend:hasSkill("jijiu")) or friend:hasSkill("jieyin")
				then
					return hcard, friend
				end
			end
		end
	end

	--Crossbow
	for _, friend in sgs.list(friends) do
		if friend:hasSkills("longdan|ollongdan|wusheng|tenyearwusheng|keji|chixin") and not self:hasCrossbowEffect(friend) and friend:getHandcardNum() >= 2
		then
			for _, hcard in sgs.list(cards) do
				if hcard:isKindOf("Crossbow")
				then
					return hcard, friend
				end
			end
		end
	end

	for _, friend in sgs.list(friends) do
		if getKnownCard(friend, self.player, "Crossbow") > 0
		then
			for _, p in sgs.list(self.enemies) do
				if self:isGoodTarget(p, self.enemies, dummyCard()) and friend:distanceTo(p) <= 1
				then
					for _, hcard in sgs.list(cards) do
						if isCard("Slash", hcard, friend)
						then
							return hcard, friend
						end
					end
				end
			end
		end
	end
	cmpByAction = function(a, b)
		return a:getRoom():getFront(a, b):objectName() == a:objectName()
	end
	table.sort(friends, cmpByAction)
	for _, friend in sgs.list(friends) do
		if friend:faceUp() then
			can_slash = false
			for _, p in sgs.list(self.room:getOtherPlayers(friend)) do
				if self:isEnemy(p) and self:isGoodTarget(p, self.enemies, dummyCard()) and friend:distanceTo(p) <= friend:getAttackRange()
				then
					can_slash = true
					break
				end
			end
			flag = string.format("weapon_done_%s_%s", self.player:objectName(), friend:objectName())
			if not can_slash then
				for _, p in sgs.list(self.room:getOtherPlayers(friend)) do
					if self:isEnemy(p) and self:isGoodTarget(p, self.enemies, dummyCard()) and friend:distanceTo(p) > friend:getAttackRange()
					then
						for _, hcard in sgs.list(cardtogive) do
							if hcard:isKindOf("Weapon") and friend:distanceTo(p) <= friend:getAttackRange() + (sgs.weapon_range[hcard:getClassName()] or 0)
								and not friend:getWeapon() and not friend:hasFlag(flag)
							then
								self.room:setPlayerFlag(friend, flag)
								return hcard, friend
							end
							if hcard:isKindOf("OffensiveHorse") and friend:distanceTo(p) <= friend:getAttackRange() + 1
								and not friend:getOffensiveHorse() and not friend:hasFlag(flag)
							then
								self.room:setPlayerFlag(friend, flag)
								return hcard, friend
							end
						end
					end
				end
			end
		end
	end

	cmpByNumber = function(a, b)
		return a:getNumber() > b:getNumber()
	end
	table.sort(cardtogive, cmpByNumber)

	for _, friend in sgs.list(friends) do
		if not self:needKongcheng(friend, true) and friend:faceUp()
		then
			for _, hcard in sgs.list(cardtogive) do
				for _, askill in sgs.list(friend:getVisibleSkillList(true)) do
					callback = sgs.ai_cardneed[askill:objectName()]
					if type(callback) == "function" and callback(friend, hcard, self)
					then
						return hcard, friend
					end
				end
			end
		end
	end

	-- shit
	for _, shit in sgs.list(cardtogive) do
		if shit:isKindOf("Shit") then
			for _, friend in sgs.list(friends) do
				if self:isWeak(friend) then
				elseif shit:getSuit() == sgs.Card_Spade or hasJueqingEffect(friend, friend)
				then
					if hasZhaxiangEffect(friend)
					then
						return shit, friend
					end
				elseif self:hasSkills("guixin|jieming|yiji|nosyiji|chengxiang|noschengxiang|jianxiong", friend)
				then
					return shit, friend
				end
			end
		end
	end

	-- slash
	if self.role == "lord" and self.player:hasLordSkill("jijiang")
	then
		for _, friend in sgs.list(friends) do
			if friend:getKingdom() == "shu" and friend:getHandcardNum() < 3
			then
				for _, hcard in sgs.list(cardtogive) do
					if isCard("Slash", hcard, friend)
					then
						return hcard, friend
					end
				end
			end
		end
	end

	-- kongcheng
	self:sort(self.enemies, "defense")
	if #self.enemies > 0 and self.enemies[1]:isKongcheng() and self.enemies[1]:hasSkill("kongcheng")
		and not hasManjuanEffect(self.enemies[1])
	then
		for _, acard in sgs.list(cardtogive) do
			if acard:isKindOf("Lightning") or acard:isKindOf("Collateral") or (acard:isKindOf("Slash") and self.player:getPhase() == sgs.Player_Play)
				or acard:isKindOf("OffensiveHorse") or acard:isKindOf("Weapon") or acard:isKindOf("AmazingGrace")
			then
				return acard, self.enemies[1]
			end
		end
	end

	if AssistTarget then
		for _, hcard in sgs.list(cardtogive) do
			return hcard, AssistTarget
		end
	end

	self:sort(friends, "defense")
	for _, hcard in sgs.list(cardtogive) do
		for _, friend in sgs.list(friends) do
			if not self:needKongcheng(friend, true) and not friend:hasSkill("manjuan")
				and not self:willSkipPlayPhase(friend) and self:hasSkills(sgs.priority_skill, friend)
				and (self:getOverflow() > 0 or self.player:getHandcardNum() > 3) and friend:getHandcardNum() <= 3
			then
				return hcard, friend
			end
		end
	end

	local shoulduse = self.player:isWounded() and
		(self.player:hasSkill("rende") and not self.player:hasUsed("RendeCard") and self.player:getMark("rende") < 2)
		or (self.player:hasSkill("nosrende") and self.player:getMark("nosrende") < 2)

	if #cardtogive < 1 and shoulduse then cardtogive = cards end

	self:sort(friends, "handcard")
	for _, hcard in sgs.list(cardtogive) do
		for _, friend in sgs.list(friends) do
			if not self:needKongcheng(friend, true) and not friend:hasSkill("manjuan")
			then
				if friend:getHandcardNum() <= 3 and (self:getOverflow() > 0 or self.player:getHandcardNum() > 3 or shoulduse)
				then
					return hcard, friend
				end
			end
		end
	end

	for _, hcard in sgs.list(cardtogive) do
		for _, friend in sgs.list(friends) do
			if (not self:needKongcheng(friend, true) or #friends == 1) and not friend:hasSkill("manjuan")
			then
				if self:getOverflow() > 0 or self.player:getHandcardNum() > 3 or shoulduse
				then
					return hcard, friend
				end
			end
		end
	end

	for _, hcard in sgs.list(cardtogive) do
		for _, friend in sgs.list(tos) do
			if (not self:needKongcheng(friend, true) or #tos == 1) and not friend:hasSkill("manjuan")
			then
				if self:getOverflow() > 0 or self.player:getHandcardNum() > 3 or shoulduse
				then
					return hcard, friend
				end
			end
		end
	end

	if #cards > 0 and shoulduse then
		if sgs.playerRoles.rebel < 1 and sgs.playerRoles.loyalist > 0 and self.player:isWounded()
			or sgs.playerRoles.rebel > 0 and sgs.playerRoles.renegade > 0 and sgs.playerRoles.loyalist < 1 and self:isWeak()
		then
			self:sort(tos, "defense")
			self:sortByUseValue(cards, true)
			return cards[1], tos[1]
		end
	end
end

function SmartAI:askForYiji(card_ids, reason)
	if reason
	then
		self.card_ids = card_ids
		reason = sgs.ai_skill_askforyiji[string.gsub(reason, "%-", "_")]
		if type(reason) == "function"
		then
			local targets = sgs.SPlayerList()
			local player_names = self.player:getTag("askForyiji_ForAI"):toString():split("+")
			for _, p in sgs.list(self.room:getAlivePlayers()) do
				if table.contains(player_names, p:objectName())
				then
					targets:append(p)
				end
			end
			local target, cid = reason(self, card_ids, targets)
			if target and cid and table.contains(card_ids, cid)
			then
				return target, cid
			end
		end
	end
	return nil, -1
end

function SmartAI:askForPindian(requestor, reason)
	local passive = { "mizhao", "lieren" }
	if self.player:objectName() == requestor:objectName()
		and not table.contains(passive, reason)
	then
		passive = self[reason .. "_card"]
		if passive
		then
			passive = type(passive) ~= "number" and passive:getEffectiveId() or passive
			if self.player:handCards():contains(passive) then return sgs.Sanguosha:getCard(passive) end
		end
		self.room:writeToConsole("Pindian card for " .. reason .. " not found!!")
		return self:getMaxCard()
	end
	self.requestor = requestor
	local cards = self.player:getHandcards()
	cards = self:sortByUseValue(cards)
	local maxcard, mincard = cards[1], cards[1]
	function compare_func(a, b)
		return a:getNumber() < b:getNumber()
	end

	table.sort(cards, compare_func)
	for _, c in sgs.list(cards) do
		if self:getUseValue(c) < 6
		then
			mincard = c
			break
		end
	end
	for _, c in sgs.list(sgs.reverse(cards)) do
		if self:getUseValue(c) < 6 then
			maxcard = c
			break
		end
	end
	passive = sgs.ai_skill_pindian[reason]
	cards = self:sortByUseValue(cards)
	if type(passive) == "function"
	then
		passive = passive(cards[1], self, requestor, maxcard, mincard)
		if passive then return passive end
	end
	passive = cards[1]
	local sameclass = true
	for _, c in sgs.list(cards) do
		if passive:getClassName() ~= c:getClassName()
		then
			sameclass = false
			break
		end
	end
	if sameclass
	then
		if self:isFriend(requestor) then
			return self:getMinCard()
		else
			return self:getMaxCard()
		end
	end
	if self:isFriend(requestor) then
		return mincard
	else
		return maxcard
	end
end

sgs.ai_skill_playerchosen.damage = function(self, targets)
	local targetlist = self:sort(targets, "hp")
	for _, target in sgs.list(targetlist) do
		if self:isEnemy(target)
		then
			return target
		end
	end
	for _, target in sgs.list(targetlist) do
		if not self:isFriend(target)
		then
			return target
		end
	end
	return targetlist[#targetlist]
end

function SmartAI:askForPlayerChosen(targets, reason)
	local chosen = sgs.ai_skill_playerchosen[string.gsub(reason, "%-", "_")]
	if sgs.jl_bingfen and math.random() > 0.67 then chosen = nil end
	self.targets = targets
	if type(chosen) == "function"
	then
		chosen = chosen(self, targets)
		if chosen and targets:contains(chosen) then return chosen else return end
	elseif chosen and targets:contains(chosen) then
		return chosen
	end
	return targets:at(math.random(0, targets:length() - 1))
end

function SmartAI:askForPlayersChosen(targets, reason, max_num, min_num)
	local chosen = sgs.ai_skill_playerschosen[reason]
	local tos = {}
	self.targets = targets
	self.x = max_num
	self.n = min_num
	if type(chosen) == "function"
	then
		chosen = chosen(self, targets, max_num, min_num)
		if type(chosen) == type(targets)
			or type(chosen) == "table"
		then
			for _, p in sgs.list(chosen) do
				if targets:contains(p)
				then
					table.insert(tos, p)
				end
			end
			if sgs.jl_bingfen and math.random() > 0.67 then tos = {} end
			if #tos >= min_num then return tos end
		end
	end
	for _, p in sgs.list(RandomList(targets)) do
		if table.contains(tos, p) then continue end
		if #tos >= min_num then break end
		table.insert(tos, p)
	end
	return tos
end

function SmartAI:ableToSave(saver, dying)
	local current = self.room:getCurrent()
	if current and current:hasSkill("wansha") and current ~= saver and current ~= dying
		and not saver:hasSkills("jiuzhu|chunlao|tenyearchunlao|secondtenyearchunlao|nosjiefan|renxin")
	then
		return false
	end
	if saver:isCardLimited(dummyCard("peach"), sgs.Card_MethodUse, true)
		and not saver:hasSkills("jiuzhu|chunlao|tenyearchunlao|secondtenyearchunlao|nosjiefan|renxin")
	then
		return false
	end
	return true
end

function SmartAI:askForSinglePeach(dying)
	local peach_str
	function usePeachTo(str)
		if peach_str then return peach_str end
		str = str or "Peach"
		for _, c in sgs.list(self:getCard(str, true)) do
			if self.player:isProhibited(dying, c)
			then else
				return c:toString()
			end
		end
	end

	if self:needDeath(dying) then return "." end
	if self.player == dying
	then
		peach_str = usePeachTo("Analeptic,Peach")
		if peach_str
		then
			if dying:getState() == "robot"
				and math.random() < sgs.turncount * 0.1
				and #self.friends < dying:aliveCount() / 2
			then
				self:speak("no_peach", dying:isFemale())
				self.room:getThread():delay(sgs.delay * 2)
			else
				return peach_str
			end
		end
		return "."
	else
		local td = self.player:getCardCount() * 333
		if td > 333
		then
			if td > sgs.delay * 3 then td = sgs.delay * 3 end
			self.room:getThread():delay(math.random(sgs.delay * 0.4, td))
		end
	end
	local lord = getLord(self.player)
	if hasBuquEffect(dying)
		or lord and self.role == "renegade" and dying:getRole() ~= "lord"
		and (sgs.playerRoles.loyalist + 1 == sgs.playerRoles.rebel
			or sgs.playerRoles.loyalist == sgs.playerRoles.rebel
			or self.room:getCurrent():objectName() == self.player:objectName()
			or sgs.gameProcess() == "neutral")
		or isLord(self.player) and self:getEnemyNumBySeat(self.room:getCurrent(), self.player, self.player) > 0
		and self:getCardsNum("Peach") < 2 and self:isWeak() and self.player:getHp() < 2 then
		return "."
	end
	if sgs.ai_role[dying:objectName()] == "renegade"
	then
		if self.role == "loyalist"
			or self.role == "renegade"
			or self.role == "lord"
		then
			if sgs.playerRoles.loyalist + sgs.playerRoles.renegade >= sgs.playerRoles.rebel
				or sgs.gameProcess() == "loyalist"
				or sgs.gameProcess() == "loyalish"
				or sgs.gameProcess() == "dilemma"
			then
				return "."
			end
		end
		if self.role == "rebel"
			or self.role == "renegade"
		then
			if sgs.playerRoles.rebel + sgs.playerRoles.renegade - 1 >= sgs.playerRoles.loyalist + 1
				or sgs.gameProcess() == "rebelish"
				or sgs.gameProcess() == "dilemma"
				or sgs.gameProcess() == "rebel"
			then
				return "."
			end
		end
	end
	if self:isFriend(dying)
	then
		if dying:getRole() == "lord"
		then
			peach_str = usePeachTo()
		elseif lord
		then
			if (self.role == "loyalist" or self.role == "renegade" and dying:aliveCount() > 2)
				and self:getCardsNum("Peach") <= sgs.ai_NeedPeach[lord:objectName()]
				or (self:getCardsNum("Peach") < 2
					and (sgs.SavageAssaultHasLord and getCardsNum("Slash", lord, self.player) < 1
						or sgs.ArcheryAttackHasLord and getCardsNum("Jink", lord, self.player) < 1))
			then
				return "."
			end
			local pn = self:getCardsNum("Peach")
			for _, friend in sgs.list(self.friends_noself) do
				if self:playerGetRound(friend) < self:playerGetRound(self.player)
					or sgs.card_lack[friend:objectName()]["Peach"] == 1
					or not self:ableToSave(friend, dying) then
				else
					pn = pn + getCardsNum("Peach", friend, self.player)
				end
			end
			if pn + dying:getHp() < 1 then return "." end
			local CP = self.room:getCurrent()
			if dying:objectName() ~= lord:objectName()
				and lord:getHp() < 2 and self:isFriend(lord)
				and self:isEnemy(CP) and CP:canSlash(lord)
				and getCardsNum("Peach,Analeptic", lord, self.player) < 1
				and #self.friends_noself <= 2 and self:slashIsAvailable(CP)
				and self:getCardsNum("Peach") <= self:getEnemyNumBySeat(CP, lord, self.player) + 1
				and self:damageIsEffective(CP, nil, lord)
			then
				return "."
			end
			if lord:getHp() < 2 and not hasBuquEffect(lord)
				and (self:isFriend(lord) or self.role == "renegade")
				or self:getAllPeachNum() + dying:getHp() > 0
			then
				peach_str = usePeachTo()
			end
		elseif dying:hasFlag("Kurou_toDie") and getCardsNum("Crossbow", dying, self.player) < 1
			or dying:hasSkill("jiushi") and dying:faceUp() and dying:getHp() >= 0
			or canNiepan(dying) --add
			or self:doNotSave(dying)
		then
			return "."
		end
	else                                            --救对方的情形
		if dying:hasSkill("wuhun")                  --濒死者有技能“武魂”
			and self.role ~= sgs.ai_role[dying:objectName()] --可能有救的必要
		then
			if lord and self.player:aliveCount() > 2
				or sgs.playerRoles.rebel + sgs.playerRoles.renegade > 1
			then
				for _, target in pairs(self:getWuhunRevengeTargets()) do --武魂复仇目标
					if target:getRole() == "lord"
					then                                     --主公会被武魂带走，真的有必要……
						finalRetrial, wizard = self:getFinalRetrial(nil, "wuhun")
						if finalRetrial == 0                 --没有判官，需要考虑观星、心战、攻心的结果（已忽略）
							or finalRetrial == 2             --对方后判，这个一定要救了……
						then
							peach_str = usePeachTo()
						elseif finalRetrial == 1
						then --己方后判，需要考虑最后的判官是否有桃或桃园结义改判（已忽略）
							flag = wizard:hasSkill("huanshi") and "he" or "h"
							if getKnownCard(wizard, self.player, "Peach,GodSalvation", false, flag) > 0
							then
								return "."
							else
								peach_str = usePeachTo()
							end
						end
					end
				end
			end
		elseif not dying:hasSkills(sgs.masochism_skill)
			and lord and not canNiepan(dying) -- 鞭尸...
		then
			local mode = string.lower(sgs.getMode)
			if mode == "06_3v3" and #self.enemies < 2 and dying:isNude()
				and #self.friends > 2 and not self:isWeak(self.friends)
			then
				peach_str = usePeachTo()
				if peach_str
				then
					self:speak("bianshi", dying:isFemale())
					sgs.ai_doNotUpdateIntenion = true
				end
			elseif string.find(mode, "p")
				and sgs.playerRoles.renegade < 1
				and mode >= "03p"
			then
				if (self.role == "lord" or self.role == "loyalist")
					and sgs.playerRoles.rebel == 1 and #self.enemies < 2 and dying:isNude()
					and self.room:getCurrent():getNextAlive():objectName() ~= dying:objectName()
					and #self.friends > 2
				then
					peach_str = usePeachTo()
					if peach_str
					then
						self:speak("bianshi", dying:isFemale())
						sgs.ai_doNotUpdateIntenion = true
					end
				elseif self.role == "rebel"
					and sgs.playerRoles.loyalist < 1
					and #self.enemies < 2 and dying:isNude()
					and self.room:getCurrent():getNextAlive():objectName() ~= dying:objectName()
					and #self.friends > 2 and not self:isWeak(self.friends)
				then
					peach_str = usePeachTo()
					if peach_str
					then
						self:speak("bianshi", dying:isFemale())
						sgs.ai_doNotUpdateIntenion = true
					end
				end
			end
			if sgs.jl_bingfen
				and math.random() < 0.30
			then
				peach_str = usePeachTo()
				if peach_str and jl_bingfen3
				then
					sgs.JLBFto = self.player
					self.player:speak(jl_bingfen3[math.random(1, #jl_bingfen3)])
					self.room:getThread():delay(sgs.delay * 2)
				end
			end
		end
	end
	return peach_str or "."
end

function SmartAI:addHandPile(cards, player)
	player = player or self.player
	cards = type(cards) == "string" and player:getCards(cards) or cards or player:getHandcards()
	if type(cards) ~= "table" then cards = sgs.QList2Table(cards) end
	for _, key in ipairs(player:getPileNames()) do
		if key:match("&") or key == "wooden_ox"
		then
			for _, id in sgs.qlist(player:getPile(key)) do
				table.insert(cards, sgs.Sanguosha:getCard(id))
			end
		end
	end
	return cards
end

function SmartAI:getTurnUse()
	useNum = {}
	turnUse = {}
	function canMethodUse(c, cn)
		if c:hasFlag("AIGlobal_KillOff")
			or c:getTypeId() < 1 then
			return true
		end
		self.player:addHistory(cn, useNum[cn])
		canmu = c:isAvailable(self.player)
		self.player:addHistory(cn, -useNum[cn])
		return canmu
	end

	for cn, c in ipairs(self:sortByDynamicUsePriority(self:fillSkillCards(self:addHandPile()))) do
		cn = c:isKindOf("Slash") and "Slash" or c:getClassName()
		useNum[cn] = useNum[cn] or 0
		if canMethodUse(c, cn)
			and self:aiUseCard(c, { to = sgs.SPlayerList() }).card
		then
			table.insert(turnUse, c)
			useNum[cn] = useNum[cn] + 1
		elseif c:canRecast()
		then
			if c:isKindOf("Weapon") and sgs.getMode ~= "04_1v3" --为什么不是虎牢关,ai也可以重铸武器啊......
			then else
				table.insert(turnUse, c)
			end
		end
		if #turnUse >= 5 then break end
	end
	self.toUse = turnUse
	return turnUse
end

function SmartAI:activate(use)
	for _, c in ipairs(self:getTurnUse()) do
		if c:isAvailable(self.player) and self:aiUseCard(c, use).card
		then elseif c:canRecast() then
			use.card = c
		end
		if use.card and use.card:canRecast()
			and use.to:isEmpty()
		then
			if use.card:isKindOf("Weapon") then
			elseif self.player:isCardLimited(use.card, sgs.Card_MethodRecast)
				or self.player:getHandPile():contains(use.card:getEffectiveId())
			then
				use.card = nil
			end
		end
		if use.card then return end
	end
end

function SmartAI:getOverflow(player, getMaxCards)
	player = player or self.player
	local MaxCards = player:getMaxCards()
	if player:hasSkill("qiaobian") then MaxCards = math.max(self.player:getHandcardNum() - 1, MaxCards) end
	if player:hasSkill("keji") and not player:hasFlag("KejiSlashInPlayPhase")
		or player:hasSkill("zaoyao") then
		MaxCards = self.player:getHandcardNum()
	end
	if getMaxCards and MaxCards > 0 then return MaxCards end
	if player:hasSkill("yongsi")
		and player:getPhase() < sgs.Player_Finish
		and not (player:hasSkill("keji") and not player:hasFlag("KejiSlashInPlayPhase"))
		and not player:hasSkill("conghui")
	then
		local kingdom_num = {}
		for _, ap in sgs.qlist(self.room:getAlivePlayers()) do
			ap = ap:getKingdom()
			if table.contains(kingdom_num, ap) then continue end
			table.insert(kingdom_num, ap)
		end
		kingdom_num = #kingdom_num
		if kingdom_num > 0
		then
			if player:getCardCount() > kingdom_num
			then
				MaxCards = math.min(MaxCards, player:getCardCount() - kingdom_num)
			else
				MaxCards = 0
			end
		end
	end
	if getMaxCards then return MaxCards end
	local of_ic = player:getTag("IgnoreCards"):toIntList()
	for _, c in sgs.list(getKnownCards(player, self.player)) do
		if of_ic:contains(c:getEffectiveId())
		then
			MaxCards = MaxCards + 1
		end
	end
	return player:getHandcardNum() - MaxCards
end

function SmartAI:isWeak(player, getAP)
	if type(player) == "table"
	then
		for _, p in sgs.list(player) do
			if self:isWeak(p, getAP)
			then
				return true
			end
		end
		return false
	end
	player = player or self.player
	if hasBuquEffect(player)
		or player:inYinniState()
		or player:hasSkill("dev_shanbi")
		or player:hasSkills("longhun|newlonghun") and player:getCardCount() > 2
		or player:hasSkills("yingba+pinghe") and player:getHandcardNum() > 1
	then
		return false
	end
	local hp = player:getHp()
	if player:hasSkill("hunzi") and player:getMark("hunzi") < 1 and hp > 1
		or player:hasSkill("mobilehunzi") and player:getMark("mobilehunzi") < 1 and hp > 2
	then
		return false
	end
	for _, m in sgs.list(player:getMarkNames()) do
		if m:match("ai_hp") then hp = hp + player:getMark(m) end
	end
	local hj = player:getHujia()
	if self:hasSkills("dev_nvshen", self:getEnemies(player)) then hj = 0 end
	if getAP ~= false
	then
		if player:objectName() == self.player:objectName()
		then
			for _, c in sgs.list(self:getCards("Analeptic,Peach")) do
				if self.player:isLocked(c) then else hp = hp + 1 end
			end
		else
			hp = hp + getCardsNum("Analeptic,Peach", player, self.player)
		end
	end
	hp = hp + hj
	if hp <= 2 and player:getHandcardNum() <= 2
		or hp <= 1 then
		return true
	end
	return false
end

function SmartAI:hasWizard(players, onlyharm)
	local skill = onlyharm and sgs.wizard_harm_skill or sgs.wizard_skill
	for _, player in sgs.list(players) do
		if player:hasSkills(skill)
		then
			return true
		end
	end
end

function SmartAI:canRetrial(player, reason)
	player = player or self.player
	if player:hasSkill("guidao")
		and not (reason and reason == "wuhun")
	then
		local blacknum = #self:addHandPile(nil, player)
		for _, e in sgs.list(player:getEquips()) do
			if e:isBlack() then blacknum = blacknum + 1 end
		end
		if blacknum > 0 then return true end
	end
	if player:hasSkill("nosguicai") and #self:addHandPile(nil, player) > 0
		or player:hasSkill("jilve") and player:getCardCount() > 0 and player:getMark("&bear") > 0
		or player:hasSkill("midao") and player:getPile("rice"):length() > 0
		or player:hasSkill("zhenyi") and player:getMark("@flziwei") > 0
	then
		return true
	end
	for _, sk in sgs.list(sgs.getPlayerSkillList(player)) do
		sk = sgs.Sanguosha:getTriggerSkill(sk:objectName())
		if sk and sk:hasEvent(sgs.AskForRetrial)
			and player:getCardCount() > 0
		then
			return true
		end
	end
end

function SmartAI:getFinalRetrial(owner, reason)
	local maxenemyseat, wizardf, players = 0, nil, {}
	owner = owner or self.room:getCurrent()
	table.insert(players, owner)
	local Next = owner:getNextAlive()
	while Next:objectName() ~= owner:objectName() do
		table.insert(players, Next)
		Next = Next:getNextAlive()
	end
	for _, ap in sgs.list(players) do
		if self:canRetrial(ap, reason)
		then
			maxenemyseat = self:isFriend(ap) and 1 or 2
			wizardf = ap
		end
	end
	return maxenemyseat, wizardf
end

--- Determine that the current judge is worthy retrial
-- @param judge The JudgeStruct that contains the judge information
-- @return True if it is needed to retrial
function SmartAI:needRetrial(judge)
	local lord = getLord(self.player)
	self.isWeak_judge = false
	if judge.reason == "lightning"
	then
		if lord and (judge.who:getRole() == "lord" or judge.who:isChained() and lord:isChained())
			and self:objectiveLevel(lord) <= 3
		then
			if lord:hasArmorEffect("silver_lion") and lord:getHp() >= 2
				and self:isGoodChainTarget(lord, "T")
			then
				return false
			end
			return self:damageIsEffective(lord, "T")
				and judge:isBad()
		end
		if judge.who:getHp() > 1
			and judge.who:hasArmorEffect("silver_lion")
		then
			return false
		end
		if self:isFriend(judge.who)
		then
			if judge.who:isChained()
				and self:isGoodChainTarget(judge.who, "T", nil, 3)
			then
				return false
			end
		else
			if judge.who:isChained()
				and not self:isGoodChainTarget(judge.who, "T", nil, 3)
			then
				return judge:isGood()
			end
		end
	elseif judge.reason == "indulgence"
	then
		if judge.who:isKongcheng()
			and judge.who:isSkipped(sgs.Player_Draw)
		then
			if judge.who:hasSkill("shenfen") and judge.who:getMark("&wrath") >= 6
				or judge.who:hasSkill("jixi") and judge.who:getPile("field"):length() > 2
				or judge.who:hasSkill("lihun") and self:isLihunTarget(self:getEnemies(judge.who), 0)
				or judge.who:hasSkill("xiongyi") and judge.who:getMark("@arise") > 0
				or judge.who:hasSkill("kurou") and judge.who:getHp() >= 3
			then
				if self:isFriend(judge.who) then
					return judge:isBad()
				else
					return judge:isGood()
				end
			end
		end
		if self:isFriend(judge.who)
		then
			if judge.who:getHp() - judge.who:getHandcardNum() >= self:ImitateResult_DrawNCards(judge.who, judge.who:getVisibleSkillList(true))
				and self:getOverflow() < 0 then
				return false
			end
			if judge.who:hasSkill("tuxi") and judge.who:getHp() > 2
				and self:getOverflow() < 0 then
				return false
			end
			return judge:isBad()
		else
			return judge:isGood()
		end
	elseif judge.reason == "supply_shortage"
	then
		if self:isFriend(judge.who)
		then
			if self:hasSkills("guidao|tiandu", judge.who)
			then
				return false
			end
			return judge:isBad()
		else
			return judge:isGood()
		end
	elseif judge.reason == "luoshen"
	then
		if self:isFriend(judge.who)
		then
			if judge.who:getHandcardNum() > 30
			then
				return false
			end
			if self:hasCrossbowEffect(judge.who)
				or getKnownCard(judge.who, self.player, "Crossbow", false) > 0
			then
				return judge:isBad()
			end
			if self:getOverflow(judge.who) > 1
				and self.player:getHandcardNum() < 3
			then
				return false
			end
			return judge:isBad()
		else
			return judge:isGood()
		end
	elseif judge.reason == "tuntian"
	then
		if not judge.who:hasSkill("zaoxian")
			and judge.who:getMark("zaoxian") < 1
		then
			return false
		end
	elseif judge.reason == "beige"
	then
		return true
	end
	local callback = sgs.ai_need_retrial_func[judge.reason]
	if type(callback) == "function"
	then
		callback = callback(self, judge, judge:isGood(), judge.who, self:isFriend(judge.who), lord)
		if type(callback) == "boolean" then return callback end
	elseif type(callback) == "boolean" then
		return callback
	end
	if self:isFriend(judge.who) then
		return judge:isBad()
	elseif self:isEnemy(judge.who) then
		return judge:isGood()
	else
		self.isWeak_judge = true
		if self:isWeak(judge.who) then
			return judge:isBad()
		else
			return judge:isGood()
		end
	end
end

--- Get the retrial cards with the lowest keep value
-- @param cards the table that contains all cards can use in retrial skill
-- @param judge the JudgeStruct that contains the judge information
-- @return the retrial card id or -1 if not found
function SmartAI:getRetrialCardId(cards, judge, self_card, exchange)
	local can_use, other_suit, hasSpade = {}, {}, nil
	for x, c in sgs.list(cards) do
		x = CardFilter(c, judge.who)
		if judge.reason:match("beige")
			and not isCard("Peach", c, self.player)
		then
			local damage = self.room:getTag("CurrentDamageStruct"):toDamage()
			if damage.from
			then
				if self:isFriend(damage.from)
				then
					if not self:toTurnOver(damage.from, 0)
						and judge.card:getSuit() ~= sgs.Card_Spade
						and x:getSuit() == sgs.Card_Spade
					then
						hasSpade = true
						table.insert(can_use, c)
					elseif (self_card == false or self:getOverflow() > 0)
						and judge.card:getSuit() ~= x:getSuit()
					then
						if judge.card:getSuit() == sgs.Card_Heart and judge.who:isWounded() and self:isFriend(judge.who)
							or judge.card:getSuit() == sgs.Card_Diamond and self:isEnemy(judge.who) and hasManjuanEffect(judge.who)
							or judge.card:getSuit() == sgs.Card_Club and self:needToThrowArmor(damage.from) then
						elseif (self:isFriend(judge.who) and x:getSuit() == sgs.Card_Heart and judge.who:isWounded()
								or x:getSuit() == sgs.Card_Diamond and self:isEnemy(judge.who) and hasManjuanEffect(judge.who)
								or x:getSuit() == sgs.Card_Diamond and self:isFriend(judge.who) and not hasManjuanEffect(judge.who)
								or x:getSuit() == sgs.Card_Club and (self:needToThrowArmor(damage.from) or damage.from:isNude()))
							or judge.card:getSuit() == sgs.Card_Spade and self:toTurnOver(damage.from, 0)
						then
							table.insert(other_suit, c)
						end
					end
				else
					if not self:toTurnOver(damage.from, 0)
						and x:getSuit() ~= sgs.Card_Spade
						and judge.card:getSuit() == sgs.Card_Spade
					then
						table.insert(can_use, c)
					end
				end
			end
		elseif (self:isFriend(judge.who) and judge:isGood(x) or self:isEnemy(judge.who) and not judge:isGood(x))
			and not (self_card ~= false and (self:getFinalRetrial(nil, judge.reason) == 2 or self:dontRespondPeachInJudge(judge)) and isCard("Peach", c, self.player) and not self:isWeak(self.friends))
		then
			table.insert(can_use, c)
		end
	end
	if not hasSpade and #other_suit > 0
	then
		InsertList(can_use, other_suit)
	end
	if judge.reason ~= "lightning"
	then
		for _, ap in sgs.list(self.room:getAllPlayers()) do
			if ap:containsTrick("lightning")
			then
				for i, c in sgs.list(can_use) do
					c = CardFilter(c, ap)
					if c:getSuit() == sgs.Card_Spade
						and c:getNumber() >= 2 and c:getNumber() <= 9
					then
						table.remove(can_use, i)
						break
					end
				end
			end
		end
	end
	if #can_use < 1
		and exchange
	then
		for _, c in sgs.list(cards) do
			if judge:isGood(CardFilter(c, judge.who))
			then
				if judge:isGood() then table.insert(can_use, c) end
			elseif judge:isBad() then
				table.insert(can_use, c)
			end
			if judge.pattern == "." then table.insert(can_use, c) end
		end
	end
	if next(can_use)
	then
		for i, c in sgs.list(can_use) do
			i = c:getEffectiveId()
			if self:canDisCard(self.player, i)
			then
				return i
			end
		end
		self:sortByKeepValue(can_use)
		return can_use[1]:getEffectiveId()
	end
	return -1
end

function CardFilter(cid, owner, place)
	if type(cid) ~= "number" then cid = cid:getEffectiveId() end
	place = place or sgs.Player_PlaceJudge
	local gc = sgs.Sanguosha:getCard(cid)
	owner = BeMan(global_room, owner)
	for cl, s in sgs.list(sgs.getPlayerSkillList(owner)) do
		if s:inherits("FilterSkill")
		then
			local co = global_room:getCardOwner(cid)
			local cp = global_room:getCardPlace(cid)
			s = sgs.Sanguosha:getViewAsSkill(s:objectName())
			global_room:setCardMapping(cid, owner, place)
			cl = sgs.CardList()
			cl:append(gc)
			if s:viewFilter(sgs.CardList(), gc) then gc = s:viewAs(cl) end
			global_room:setCardMapping(cid, co, cp)
		end
	end
	return gc
end

function SmartAI:damageIsEffective(to, card_nature, from)
	local struct = {}
	struct.to = to or self.player
	struct.from = from or self.room:getCurrent() or self.player
	struct.card = type(card_nature) ~= "number" and type(card_nature) ~= "string" and card_nature
	struct.nature = (type(card_nature) == "number" or type(card_nature) == "string") and card_nature
	return self:damageStruct(struct)
end

sgs.card_damage_nature = {}

function SmartAI:damageStruct(struct)
	if type(struct) ~= "table" and type(struct) ~= "userdata"
		or type(struct.to) ~= "userdata" then
		self.room:writeToConsole(debug.traceback())
		return
	end
	if self:ajustDamage(struct.from, struct.to, struct.damage, struct.card, struct.nature) > 0
	then
		return math.random() < 0.95
	end
end

function prohibitUseDirectly(card, player)
	return player:isCardLimited(card, card:getHandlingMethod())
		or player:getMark("Global_Prevent" .. card:getClassName()) > 0
end

function SmartAI:cardsView(class_name, islist)
	local cvs = {}
	for cv, skill in ipairs(sgs.getPlayerSkillList(self.player)) do
		skill = skill:objectName()
		cv = sgs.ai_cardsview_valuable[skill]
		if type(cv) == "function"
		then
			local va = sgs.Sanguosha:getViewAsSkill(skill)
			if va and va:isEnabledAtResponse(self.player, sgs.patterns[class_name])
			then
				cv = cv(self, class_name, self.player)
				if type(cv) == "string" or type(cv) == "number"
				then
					if islist then
						table.insert(cvs, cv)
					else
						return cv
					end
				elseif type(cv) == "table"
				then
					for _, c in sgs.list(cv) do
						if islist then
							table.insert(cvs, c)
						else
							return c
						end
					end
				end
			end
		end
		cv = sgs.ai_cardsview[skill]
		if type(cv) == "function"
		then
			local va = sgs.Sanguosha:getViewAsSkill(skill)
			if va and va:isEnabledAtResponse(self.player, sgs.patterns[class_name])
			then
				cv = cv(self, class_name, self.player)
				if type(cv) == "string" or type(cv) == "number"
				then
					if islist then
						table.insert(cvs, cv)
					else
						return cv
					end
				elseif type(cv) == "table"
				then
					for _, c in sgs.list(cv) do
						if islist then
							table.insert(cvs, c)
						else
							return c
						end
					end
				end
			end
		end
	end
	return islist and cvs
end

function string:getSkillViewCard(card, player, place)
	for cid, skill in ipairs(sgs.getPlayerSkillList(player)) do
		cid = skill:objectName()
		skill = sgs.ai_view_as[cid]
		if type(skill) == "function"
		then
			cid = sgs.Sanguosha:getViewAsSkill(cid)
			if cid and cid:isEnabledAtResponse(player, sgs.patterns[self])
			then
				cid = card:getEffectiveId()
				place = place or global_room:getCardPlace(cid)
				if place == sgs.Player_PlaceSpecial
					and player:getHandPile():contains(cid)
				then
					cid = sgs.Sanguosha:getCurrentCardUseReason()
					if cid == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
						or cid == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE
					then
						place = sgs.Player_PlaceHand
					end
				end
				skill = skill(card, player, place, self)
				if type(skill) == "string" or type(skill) == "number"
				then
					cid = sgs.Card_Parse(skill)
					if cid and cid:isKindOf(self)
					then
						return skill
					end
				end
			end
		end
	end
end

function isCard(class_name, card, player)
	if not (player and card) then
		global_room:writeToConsole(debug.traceback())
		return
	end
	if type(card) == "number" then card = sgs.Sanguosha:getCard(card) end
	if class_name:match(",")
	then
		for c, cn in ipairs(class_name:split(",")) do
			c = isCard(cn, card, player)
			if c then return c end
		end
	else
		if card:isKindOf(class_name)
			and not prohibitUseDirectly(card, player)
		then
			return card
		else
			local cf = CardFilter(card, player, sgs.Player_PlaceHand)
			if cf:isKindOf(class_name) and not prohibitUseDirectly(cf, player) then return cf end
			cf = global_room:getCardOwner(card:getEffectiveId())
			cf = (not cf or cf:objectName() ~= player:objectName()) and sgs.Player_PlaceHand
			cf = class_name:getSkillViewCard(card, player, cf)
			return cf and sgs.Card_Parse(cf)
		end
	end
end

function string:isCard(card, player)
	return isCard(self, card, player)
end

function SmartAI:getMaxCard(player, cards)
	player = player or self.player
	cards = cards or player:getHandcards()
	cards = sgs.QList2Table(cards)
	if #cards < 1 then return end
	local max_card, max_point = nil, 0
	for point, card in sgs.list(cards) do
		if player:objectName() == self.player:objectName() and not self:isValuableCard(card)
			or player:objectName() ~= self.player:objectName() and self.player:canSeeHandcard(player)
			or card:hasFlag("visible_" .. self.player:objectName() .. "_" .. player:objectName())
			or card:hasFlag("visible")
		then
			point = card:getNumber()
			if player:hasSkill("tianbian") and card:getSuit() == sgs.Card_Heart then point = 13 end
			if point > max_point then
				max_point = point
				max_card = card
			end
		end
	end
	if player:objectName() == self.player:objectName()
		and not max_card
	then
		for point, card in sgs.list(cards) do
			point = card:getNumber()
			if player:hasSkill("tianbian") and card:getSuit() == sgs.Card_Heart then point = 13 end
			if point > max_point then
				max_point = point
				max_card = card
			end
		end
	end
	if player:objectName() ~= self.player:objectName() then return max_card end
	if (player:hasSkills("tianyi|dahe|xianzhen") or self.player:hasFlag("AI_XiechanUsing"))
		and max_point > 0
	then
		for _, card in sgs.list(cards) do
			if card:getNumber() == max_point
				and not isCard("Slash", card, player)
			then
				return card
			end
		end
	end
	if player:hasSkill("qiaoshui") and max_point > 0
	then
		for _, card in sgs.list(cards) do
			if card:getNumber() == max_point
				and not card:isNDTrick()
			then
				return card
			end
		end
	end
	return max_card
end

function SmartAI:getMinCard(player, cards)
	player = player or self.player
	cards = cards or player:getHandcards()
	cards = sgs.QList2Table(cards)
	if #cards < 1 then return end
	local min_card, min_point = nil, 14
	for point, card in sgs.list(cards) do
		if player:objectName() == self.player:objectName()
			or self.player:canSeeHandcard(player) or card:hasFlag("visible")
			or card:hasFlag("visible_" .. self.player:objectName() .. "_" .. player:objectName())
		then
			point = card:getNumber()
			if player:hasSkill("tianbian") and card:getSuit() == sgs.Card_Heart then point = 13 end
			if point < min_point then
				min_point = point
				min_card = card
			end
		end
	end
	return min_card
end

function SmartAI:getKnownNum(player)
	if player and player:objectName() ~= self.player:objectName()
	then
		return #getKnownCards(player, self.player)
	else
		return #self:addHandPile()
	end
end

function getKnownNum(player, ap)
	return #getKnownCards(player, ap)
end

function getKnownCard(player, from, class_name, viewas, flags)
	local known = 0
	if class_name:match(",")
	then
		for _, cn in sgs.list(class_name:split(",")) do
			known = known + getKnownCard(player, from, cn, viewas, flags)
		end
		return known
	end
	for _, c in sgs.list(getKnownCards(player, from, flags)) do
		if viewas and isCard(class_name, c, player)
			or c:getColorString() == class_name
			or c:getSuitString() == class_name
			or c:isKindOf(class_name)
		then
			known = known + 1
		end
	end
	return known
end

function string:getKnownCard(to, from, viewas, flags)
	return getKnownCard(player, from, self, viewas, flags)
end

function getKnownCards(player, from, flags, suit)
	if not player or (flags and type(flags) ~= "string") then
		global_room:writeToConsole(debug.traceback())
		return {}
	end
	from = from or global_room:getCurrent()
	local cards, gs = {}, {}
	flags = flags or "h"
	if flags:match("h")
	then
		InsertList(gs, player:getHandcards())
		if flags:match("&")
		then
			for _, id in sgs.list(player:getHandPile()) do
				table.insert(gs, sgs.Sanguosha:getCard(id))
			end
		end
	end
	if flags:match("e") then InsertList(gs, player:getEquips()) end
	for _, c in sgs.list(gs) do
		if player:objectName() == from:objectName() or c:hasFlag("visible")
			or from:canSeeHandcard(player) and player:getHandcards():contains(c)
			or c:hasFlag("visible_" .. from:objectName() .. "_" .. player:objectName())
			or CardVisible(BeMan(global_room, from), c, true)
		then
			if suit then
				if c:getSuit() == suit then table.insert(cards, c) end
			else
				table.insert(cards, c)
			end
		end
	end
	return cards
end

function SmartAI:getCard(class_name, islist)
	local cardArrs = {}
	if class_name:match(",")
	then
		sgs.isSplit = true
		for _, cn in ipairs(class_name:split(",")) do
			InsertList(cardArrs, self:getCard(cn, true))
		end
		sgs.isSplit = nil
		self:sortByUsePriority(cardArrs)
		return islist and cardArrs or cardArrs[1]
	end
	if self.player:getMark("Global_Prevent" .. class_name) > 0
	then
		return islist and cardArrs
	end
	self.class_name = class_name
	for _, cs in ipairs(self:getGuhuoCard(class_name, true)) do
		table.insert(cardArrs, sgs.Card_Parse(cs))
	end
	for _, cs in ipairs(self:cardsView(class_name, true)) do
		table.insert(cardArrs, sgs.Card_Parse(cs))
	end
	local cards = self.player:getCards("he")
	for _, key in ipairs(self.player:getPileNames()) do
		if string.sub(key, 1, 1) == "#" then continue end
		for _, id in sgs.qlist(self.player:getPile(key)) do
			cards:append(sgs.Sanguosha:getCard(id))
		end
	end
	local handp = self:addHandPile({})
	for cp, c in sgs.qlist(cards) do
		cp = self.room:getCardPlace(c:getEffectiveId())
		if (c:isKindOf(class_name) or class_name == ".")
			and (cp ~= sgs.Player_PlaceSpecial or table.contains(handp, c))
		then
			table.insert(cardArrs, c)
		else
			cp = class_name:getSkillViewCard(c, self.player, cp)
			if cp then table.insert(cardArrs, sgs.Card_Parse(cp)) end
		end
	end
	if sgs.isSplit ~= true then self:sortByUsePriority(cardArrs) end
	return islist and cardArrs or cardArrs[1]
end

function SmartAI:getCardId(class_name, islist)
	local cards = self:getCard(class_name, islist)
	if type(cards) == "table"
	then
		local viewArr = {}
		for _, c in ipairs(cards) do
			table.insert(viewArr, c:toString())
		end
		return viewArr
	elseif type(cards) == "userdata"
	then
		return cards:toString()
	end
end

function SmartAI:getCards(class_name, flags, acards)
	local cards = {}
	if class_name:match(",")
	then
		for _, cn in ipairs(class_name:split(",")) do
			InsertList(cards, self:getCards(cn, flags, acards))
		end
		return cards
	end
	local haspile = type(flags) ~= "string"
	flags = haspile and "he" or flags
	self.flags = flags
	flags = self.player:getCards(flags)
	if type(acards) == "table"
	then
		flags = acards
		for _, c in sgs.list(acards) do
			self.player:addCard(c, sgs.Player_PlaceHand)
		end
	elseif haspile
	then
		for _, key in sgs.list(self.player:getPileNames()) do
			if string.sub(key, 1, 1) == "#" then continue end
			for _, id in sgs.list(self.player:getPile(key)) do
				flags:append(sgs.Sanguosha:getCard(id))
			end
		end
	end
	self.class_name = class_name
	haspile = self:addHandPile({})
	for cp, c in sgs.list(flags) do
		cp = self.room:getCardPlace(c:getEffectiveId())
		if c:hasFlag("AI_Using") then elseif (c:isKindOf(class_name) or class_name == ".")
			and (cp ~= sgs.Player_PlaceSpecial or table.contains(haspile, c))
			and not self.player:isLocked(c) then
			table.insert(cards, c)
		else
			cp = class_name:getSkillViewCard(c, self.player, cp)
			if cp then table.insert(cards, sgs.Card_Parse(cp)) end
		end
	end
	for _, cs in ipairs(self:cardsView(class_name, true)) do
		table.insert(cards, sgs.Card_Parse(cs))
	end
	if type(acards) == "table"
	then
		for _, c in ipairs(acards) do
			self.player:removeCard(c, sgs.Player_PlaceHand)
		end
	end
	return cards
end

function getCardsNum(class_name, to, from)
	return getKnownCard(to, from, class_name, true, "he")
end

function string:getCardsNum(to, from)
	return getCardsNum(self, to, from)
end

function SmartAI:getCardsNum(class_name, flag, selfonly)
	local n = 0
	if type(class_name) == "table"
	then
		for _, class in sgs.list(class_name) do
			n = n + self:getCardsNum(class, flag, selfonly)
		end
		return n
	end
	for _, c in sgs.list(self:getCards(class_name, flag)) do
		if ("spear|fuhun"):match(c:getSkillName())
		then
			n = n + math.floor(#self:addHandPile() / 2)
		elseif c:getSkillName() == "jiuzhu"
		then
			n = math.max(n, math.max(0, math.min(self.player:getCardCount(), self.player:getHp() - 1)))
		elseif c:getSkillName():match("chunlao")
		then
			n = n + self.player:getPile("wine"):length()
		else
			n = n + 1
		end
	end
	if selfonly then return n end
	if class_name:match("Jink")
	then
		if self.player:hasLordSkill("hujia")
		then
			for _, liege in sgs.list(self.room:getLieges("wei", self.player)) do
				if self:isFriend(liege) then n = n + getCardsNum("Jink", liege, self.player) end
			end
		end
	elseif class_name:match("Slash")
	then
		if self.player:hasLordSkill("jijiang")
		then
			for _, liege in sgs.list(self.room:getLieges("shu", self.player)) do
				if self:isFriend(liege) then n = n + getCardsNum("Slash", liege, self.player) end
			end
		end
	end
	return n
end

function SmartAI:getAllPeachNum(player)
	local pn = 0
	player = player or self.player
	local ws = self.room:getCurrent() or self.player
	ws = ws:hasSkill("wansha")
	for cn, friend in sgs.list(self:getFriends(player)) do
		if player == friend then
			cn = "Peach,Analeptic"
		else
			if ws then continue end
			cn = "Peach"
		end
		pn = pn + getCardsNum(cn, friend, self.player)
	end
	return pn
end

function SmartAI:getRestCardsNum(class_name, yuji)
	yuji = yuji or self.player
	local knownnum = 0
	sgs.discard_pile = self.room:getDiscardPile()
	for _, id in sgs.list(sgs.discard_pile) do
		if sgs.Sanguosha:getCard(id):isKindOf(class_name)
			and math.random(0, knownnum + knownnum * math.random()) <= knownnum
		then
			knownnum = knownnum + 1
		end
	end
	for _, ap in sgs.list(self.room:getOtherPlayers(yuji)) do
		knownnum = knownnum + getKnownCard(ap, yuji, class_name)
	end
	return #PatternsCard(class_name, true) - knownnum
end

function SmartAI:hasSuit(suit_strings, include_equip, player)
	return self:getSuitNum(suit_strings, include_equip, player) > 0
end

function SmartAI:getSuitNum(suit_strings, include_equip, player)
	flag = include_equip and "he" or "h"
	player = player or self.player
	local n, allcards = 0, player:getCards(flag)
	if player:objectName() ~= self.player:objectName()
	then
		allcards = include_equip and player:getEquips() or sgs.CardList()
		flag = string.format("%s_%s_%s", "visible", self.player:objectName(), player:objectName())
		for _, h in sgs.list(player:getHandcards()) do
			if h:hasFlag("visible") or h:hasFlag(flag)
			then
				allcards:append(h)
			end
		end
	end
	for _, c in sgs.list(allcards) do
		for _, suit_string in sgs.list(suit_strings:split("|")) do
			if c:getSuitString() == suit_string
				or c:getColorString() == suit_string
			then
				n = n + 1
			end
		end
	end
	return n
end

function SmartAI:hasSkill(skill)
	if type(skill) == "table" then
		skill = skill.name
	elseif type(skill) ~= "string" then
		skill = skill:objectName()
	end
	local gs = sgs.Sanguosha:getSkill(skill)
	if gs and gs:isLordSkill() then
		return self.player:hasLordSkill(skill)
	else
		return self.player:hasSkill(skill)
	end
end

function SmartAI:hasSkills(skill_names, player)
	player = player or self.player
	if type(player) == "table"
	then
		for _, p in sgs.list(player) do
			if p:hasSkills(skill_names)
			then
				return p
			end
		end
	else
		return player:hasSkills(skill_names)
	end
end

sgs.ai_fill_skill = {}

function SmartAI:fillSkillCards(cards)
	--[[
	for gc,skill in ipairs(sgs.ai_skills)do
        if (self:hasSkill(skill.name) or self.player:getMark("ViewAsSkill_"..skill.name.."Effect")>0)
		and sgs.Sanguosha:getViewAsSkill(skill.name):isEnabledAtPlay(self.player)
		then
			gc = skill.getTurnUseCard(self,#cards<1)
			if type(gc)=="table" then InsertList(cards,gc)
			elseif gc then table.insert(cards,gc) end
        end
    end--]]
	for gc, skill in ipairs(sgs.getPlayerSkillList(self.player)) do
		skill = skill:objectName()
		gc = sgs.ai_fill_skill[skill]
		if type(gc) == "function"
		then
			skill = sgs.Sanguosha:getViewAsSkill(skill)
			if skill and skill:isEnabledAtPlay(self.player)
			then
				gc = gc(self, #cards < 1)
				if type(gc) == "userdata"
				then
					table.insert(cards, gc)
				elseif type(gc) == "table"
				then
					for _, c in ipairs(gc) do
						table.insert(cards, c)
					end
				end
			end
		end
	end
	return cards
end

function SmartAI:useSkillCard(card, use)
	local name = card:getClassName()
	if card:isKindOf("LuaSkillCard")
	then
		name = "#" .. card:objectName()
	end
	local invoke = sgs.ai_skill_use_func[name]
	self.card = card
	if type(invoke) == "function"
	then
		invoke(card, use, self)
	else
		invoke = self["useCard" .. name]
		if invoke then invoke(self, card, use) end
	end
	if use.card and use.card:willThrow()
		and use.card:subcardsLength() > 0
	then
		invoke = self.player:getHp()
		for c, id in sgs.qlist(use.card:getSubcards()) do
			c = sgs.Sanguosha:getCard(id)
			if c:isKindOf("YjPoison") or c:isKindOf("Shit")
			then
				invoke = invoke - 1
			end
		end
		if invoke < 1 and invoke + self:getAllPeachNum() < 1
		then
			use.card = nil
		end
	end
end

function SmartAI:aoeIsEffective(card, to, player)
	if self:hasHuangenEffect(to) then return end
	return self:hasTrickEffective(card, to, player)
end

function SmartAI:hasHuangenEffect(to)
	for friends, lx in sgs.list(self.room:findPlayersBySkillName("huangen")) do
		friends = self:getFriends(lx)
		if math.min(lx:getHp(), #friends) > 0
		then
			to = to or self.player
			if type(to) ~= "table" then to = { to } end
			for _, p in ipairs(to) do
				if table.connects(friends, p)
				then
					return lx
				end
			end
		end
	end
end

function SmartAI:canAvoidAOE(card)
	if not self:aoeIsEffective(card, self.player)
		or card:isKindOf("SavageAssault") and self:getCardsNum("Slash") > 0
	then
		return true
	end
	if card:isKindOf("ArcheryAttack")
	then
		if self:getCardsNum("Jink") > 0
			or self:hasEightDiagramEffect() and self.player:getHp() > 1
		then
			return true
		end
	end
end

function SmartAI:getDistanceLimit(card, from, to)
	from = from or self.player
	if (card:isKindOf("Snatch") or card:isKindOf("SupplyShortage")) and card:getSkillName() ~= "qiaoshui"
	then
		return 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_DistanceLimit, from, card, to)
	elseif card:isKindOf("Slash")
	then
		return from:getAttackRange() + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_DistanceLimit, from, card, to)
	end
end

function SmartAI:exclude(players, card, from)
	local excluded, range_fix = {}, 0
	from = from or self.player
	if card:isVirtualCard()
		and card:subcardsLength() > 0
	then
		local oh = from:getOffensiveHorse()
		if oh and card:getSubcards():contains(oh:getId())
			or card:getSkillName() == "jixi"
		then
			range_fix = range_fix + 1
		end
	end
	for limit, p in sgs.list(players) do
		if not from:isProhibited(p, card)
		then
			limit = self:getDistanceLimit(card, from, p)
			if limit and from:distanceTo(p, range_fix) > limit
			then else
				table.insert(excluded, p)
			end
		end
	end
	return excluded
end

function SmartAI:getJiemingChaofeng(player)
	local max_x, chaofeng = 0, 0
	for x, friend in sgs.list(self:getFriends(player)) do
		x = math.min(friend:getMaxHp(), 5) - friend:getHandcardNum()
		if x > max_x then max_x = x end
	end
	if max_x < 2 then
		chaofeng = 5 - max_x * 2
	else
		chaofeng = (-max_x) * 2
	end
	return chaofeng
end

function SmartAI:getAoeValueTo(card, to, from)
	local value, sj_num = 0, 0
	if card:isKindOf("ArcheryAttack")
	then
		value = -50
		sj_num = getCardsNum("Jink", to, self.player)
		if sgs.card_lack[to:objectName()]["Jink"] == 1
			or to:isCardLimited(dummyCard("jink"), sgs.Card_MethodResponse)
			or sj_num < 1 then
			value = -70
		end
		if to:hasSkills("leiji|nosleiji|olleiji")
			and (sj_num >= 1 or self:hasEightDiagramEffect(to))
			and self:findLeijiTarget(to, 50, self.player)
		then
			value = value + 100
			if self:hasSuit("spade", true, to) then
				value = value + 150
			else
				value = value + to:getHandcardNum() * 35
			end
		elseif self:hasEightDiagramEffect(to)
		then
			value = value + 20
			if self:getFinalRetrial() == 2 then
				value = value - 15
			elseif self:getFinalRetrial() == 1 then
				value = value + 10
			end
		end
		if sj_num >= 1 and to:hasSkills("mingzhe|gushou") then value = value + 8 end
		if sj_num >= 1 and to:hasSkill("xiaoguo") then value = value - 4 end
	elseif card:isKindOf("SavageAssault")
	then
		value = -50
		sj_num = getCardsNum("Slash", to, self.player)
		if sgs.card_lack[to:objectName()]["Slash"] == 1
			or to:isCardLimited(dummyCard(), sgs.Card_MethodResponse)
			or sj_num < 1 then
			value = -70
		end
		if sj_num >= 1 and to:hasSkill("gushou") then value = value + 8 end
		if sj_num >= 1 and to:hasSkill("xiaoguo") then value = value - 4 end
	end
	value = value + math.min(20, to:getHp() * 5)
	if self:needToLoseHp(to, from, card, true) then value = value + 30 end
	if to:hasSkill("chongzhen") and self:isEnemy(to)
		and getCardsNum("Slash,Jink", to, self.player) >= 1
	then
		value = value + 15
	end
	--xiemu
	if to:hasSkill("xiemu") and to:getMark("@xiemu_" .. from:getKingdom()) > 0 and card:isBlack() then value = value + 35 end
	if to:getHp() < 2 and (sgs.card_lack[to:objectName()]["Peach"] == 1 or self:getAllPeachNum(to) < 1)
	then
		value = value - 30
	end
	if not hasJueqingEffect(from, to)
	then
		if sgs.getMode ~= "06_3v3" and sgs.getMode ~= "06_XMode" and to:getHp() < 2
			and isLord(from) and sgs.ai_role[to:objectName()] == "loyalist" and self:getCardsNum("Peach") < 1
		then
			value = value - from:getCardCount() * 20
		end
		if to:getHp() > 1 then
			if to:hasSkill("quanji") then value = value + 10 end
			if to:hasSkill("langgu") and self:isEnemy(to) then value = value - 15 end
			if to:hasSkill("jianxiong") then
				value = value + (card:isVirtualCard() and card:subcardsLength() * 10 or 10)
			end
			if to:hasSkills("fenyong+xuehen") and to:getMark("@fenyong") < 1
			then
				value = value + 30
			end
			if to:hasSkill("shenfen") and to:hasSkill("kuangbao") then
				value = value + math.min(25, to:getMark("&wrath") * 5)
			end
			if to:hasSkill("beifa") and to:getHandcardNum() == 1 and self:needKongcheng(to)
			then
				if sj_num == 1 or getCardsNum("Nullification", to, self.player) == 1 then
					value = value + 20
				elseif self:getKnownNum(to) < 1 then
					value = value + 5
				end
			end
			if to:hasSkill("tanlan") and self:isEnemy(to) and from:getCardCount() > 0 then value = value + 10 end
		end
	end
	if to:hasSkill("juxiang") and not card:isVirtualCard()
		or to:hasSkill("danlao") and to:aliveCount() > 2
		or self:hasHuangenEffect(to)
	then
		value = value + 20
	end
	return value
end

function getLord(player)
	if sgs.GetConfig("EnableHegemony", false) then return end
	local gl = global_room:getLord()
	if gl then
		return gl
	elseif player:getRole() ~= "renegade"
	then
		for _, p in sgs.list(global_room:getOtherPlayers(player)) do
			if p:getRole() == player:getRole() then return p end
		end
	end
	return player
end

function isLord(player)
	return getLord(player) == player
end

function SmartAI:getAoeValue(card, from)
	local lord, good = getLord(self.player), 0
	from = from or self.player
	function canHelpLord()
		local goodnull, kd = 0, {}
		if card:isVirtualCard() and card:subcardsLength() > 0
			and from == self.player
		then
			for _, id in sgs.qlist(card:getSubcards()) do
				if isCard("Nullification", id, from) then goodnull = goodnull - 1 end
			end
		end
		if card:isKindOf("SavageAssault")
		then
			for _, s in ipairs(sgs.getPlayerSkillList(lord)) do
				if s:objectName():match("jijiang")
					or s:objectName():match("qinwang") and lord:getCardCount() > 0
				then
					kd["shu"] = "Slash"
					break
				end
			end
		elseif card:isKindOf("ArcheryAttack")
		then
			for _, s in ipairs(sgs.getPlayerSkillList(lord)) do
				if s:objectName():match("hujia")
				then
					kd["wei"] = "Jink"
					break
				end
			end
		end
		for _, p in sgs.qlist(self.room:getAlivePlayers()) do
			if self:isFriend(lord, p)
			then
				if getCardsNum("Peach", p, self.player) > 0 then return true end
				if kd[p:getKingdom()] and getCardsNum(kd[p:getKingdom()], p, self.player) > 0 then return true end
				goodnull = goodnull + getCardsNum("Nullification", p, self.player)
			else
				goodnull = goodnull - getCardsNum("Nullification", p, self.player)
			end
		end
		return goodnull >= 2
	end

	local isEffective_F, isEffective_E, enemy_number = 0, 0, 0
	self.aoeTos = self.room:getOtherPlayers(from)
	for _, p in sgs.qlist(self.aoeTos) do
		if self:hasTrickEffective(card, p, from)
		then
			if self:isFriend(p)
			then
				isEffective_F = isEffective_F + 1
				good = good + self:getAoeValueTo(card, p, from)
				if lord == p and not canHelpLord()
					and sgs.isLordInDanger() and not hasBuquEffect(p)
				then
					good = good - (p:getHp() < 2 and 2013 or 250)
				end
				if p:hasSkill("dushi") and not from:hasSkill("benghuai")
					and self:isWeak(p) then
					good = good - 40
				end
			else
				enemy_number = enemy_number + 1
				if self:isEnemy(p)
				then
					isEffective_E = isEffective_E + 1
					good = good - self:getAoeValueTo(card, p, from)
					if lord == p and not canHelpLord()
						and sgs.isLordInDanger() and not hasBuquEffect(p)
					then
						good = good + 300 - p:getHp() * 100
						if #self.enemies == 1 or p:isKongcheng()
						then
							good = good + 200
						end
					end
				end
			end
			if self:cantbeHurt(p, from)
			then
				if p:hasSkill("wuhun") and not self:isWeak(p) and from:getMark("&nightmare") < 1
				then
					if from == self.player and self.role ~= "renegade" and self.role ~= "lord"
						or from ~= self.player and not (self:isFriend(from) and from == lord)
					then else
						good = good - 250
					end
				else
					good = good - 250
				end
			end
		end
	end
	self.aoeTos = nil
	if from:hasSkills("nosjizhi|jizhi") then good = good + 50 end
	if isEffective_F + isEffective_E < 1 then
		return good
	elseif isEffective_E < 1 then
		good = good - 500
	end
	if from:hasSkills("shenfen+kuangbao")
	then
		good = good + 3 * enemy_number
		if not from:hasSkill("wumou") then good = good + 3 * enemy_number end
		if from:getMark("&wrath") > 0 then good = good + enemy_number end
	end
	if from:hasSkills("jianxiong|luanji|qice|manjuan") then good = good + 2 * enemy_number end
	if from:getMark("AI_fangjian-Clear") > 0 then good = good + 300 end
	xiahou = self.room:findPlayerBySkillName("yanyu")
	if xiahou and self:isEnemy(xiahou) and xiahou:getMark("YanyuDiscard2") > 0 then good = good - 50 end
	return good
end

function SmartAI:hasTrickEffective(card, to, from)
	from = from or self.room:getCurrent() or self.player
	to = to or self.player
	if from:isProhibited(to, card)
		or card:isDamageCard() and self:ajustDamage(from, to, 1, card) == 0 then
		return
	end
	local use = { card = card, from = from, to = self.aoeTos or sgs.SPlayerList() }
	if not use.to:contains(to) then use.to:append(to) end
	for tr, sk in ipairs(aiConnect(to)) do
		tr = sgs.ai_target_revises[sk]
		if type(tr) == "function"
			and tr(to, card, self, use)
		then
			return
		end
	end
	return true
end

function SmartAI:hasEightDiagramEffect(owner)
	owner = owner or self.player
	return owner:hasArmorEffect("eight_diagram") or owner:hasArmorEffect("bazhen")
end

sgs.ai_weapon_value = {}

function SmartAI:evaluateWeapon(card, owner, target)
	if type(card) ~= "userdata" or not card:isKindOf("Weapon") then return -1 end
	owner = owner or self.player
	self.card = card
	self.target = target
	local deltaSelfThreat, inAttackRange = 0, nil
	local currentRange = sgs.weapon_range[card:getClassName()] or 1
	local w_enemies = target and { target } or self:getEnemies(owner)
	for w_def, enemy in sgs.list(w_enemies) do
		if owner:distanceTo(enemy) <= currentRange
		then
			inAttackRange = true
			w_def = sgs.getDefenseSlash(enemy, self) / 2
			if w_def < 0 then
				w_def = 6 - w_def
			elseif w_def <= 1 then
				w_def = 6
			else
				w_def = 6 / w_def
			end
			deltaSelfThreat = deltaSelfThreat + w_def
		end
	end
	if card:isKindOf("Crossbow") and not owner:hasSkills("paoxiao|tenyearpaoxiao|olpaoxiao") and inAttackRange
	then
		local w_slash_num = getCardsNum("Slash", owner, self.player)
		deltaSelfThreat = deltaSelfThreat + w_slash_num * 3 - 2
		if owner:hasSkill("kurou") then
			deltaSelfThreat = deltaSelfThreat +
				getCardsNum("Peach,Analeptic", owner, self.player) + self.player:getHp()
		end
		if owner:getWeapon() and not self:hasCrossbowEffect(owner) and not owner:canSlashWithoutCrossbow() and w_slash_num > 0
		then
			for _, enemy in sgs.list(w_enemies) do
				if owner:distanceTo(enemy) <= currentRange
					and (sgs.card_lack[enemy:objectName()]["Jink"] == 1 or w_slash_num >= enemy:getHp())
				then
					deltaSelfThreat = deltaSelfThreat + 10
				end
			end
		end
	end
	local w_callback = sgs.ai_weapon_value[card:objectName()]
	if type(w_callback) == "function"
	then
		deltaSelfThreat = deltaSelfThreat + (w_callback(self, nil, owner) or 0)
		for added, enemy in sgs.list(w_enemies) do
			if owner:distanceTo(enemy) <= currentRange
			then
				added = sgs.ai_slash_weaponfilter[card:objectName()]
				if type(added) == "function" and added(self, enemy, owner) then deltaSelfThreat = deltaSelfThreat + 1 end
				deltaSelfThreat = deltaSelfThreat + (w_callback(self, enemy, owner) or 0)
			end
		end
	end
	if owner:hasSkill("jijiu") and card:isRed() then deltaSelfThreat = deltaSelfThreat + 0.5 end
	if owner:hasSkills("qixi|guidao") and card:isBlack() then deltaSelfThreat = deltaSelfThreat + 0.5 end
	return deltaSelfThreat, inAttackRange
end

sgs.ai_armor_value = {}

function SmartAI:evaluateArmor(card, owner)
	owner = owner or self.player
	card = type(card) == "number" and sgs.Sanguosha:getCard(card) or card or owner:getArmor()
	local a_value = 0
	self.card = card
	self.owner = owner
	for cb, as in sgs.list(owner:getVisibleSkillList(true)) do
		cb = sgs.ai_armor_value[as:objectName()]
		if type(cb) == "function" then
			a_value = a_value + (cb(card, owner, self) or 0)
		elseif type(cb) == "number" then
			a_value = a_value + cb
		end
	end
	if card
	then
		if owner:hasSkill("jijiu") and card:isRed() then a_value = a_value + 0.5 end
		if owner:hasSkills("qixi|guidao") and card:isBlack() then a_value = a_value + 0.5 end
		local cb = sgs.ai_armor_value[card:objectName()]
		if type(cb) == "function" then
			a_value = a_value + (cb(owner, self, card) or 0)
		elseif type(cb) == "number" then
			a_value = a_value + cb
		end
		a_value = a_value + 0.1
	end
	return a_value
end

function SmartAI:getSameEquip(card, owner)
	if card and card:isKindOf("EquipCard")
	then
		owner = owner or self.player
		return owner:getEquip(card:getRealCard():toEquipCard():location())
	end
end

function SmartAI:damageMinusHp(enemy, type)
	if not enemy then return 0 end
	local trick_effectivenum, slash_damagenum, analepticpowerup, effectivefireattacknum, basicnum = 0, 0, 0, 0, 0
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	for _, acard in sgs.list(cards) do
		if acard:getTypeId() == sgs.Card_TypeBasic and not acard:isKindOf("Peach") then basicnum = basicnum + 1 end
	end
	for _, acard in sgs.list(cards) do
		if acard:isDamageCard() and not self.player:isProhibited(enemy, acard)
			or acard:isKindOf("AOE") and self:aoeIsEffective(acard, enemy)
		then
			if acard:isKindOf("FireAttack")
			then
				if not enemy:isKongcheng()
				then
					effectivefireattacknum = effectivefireattacknum + 1
				else
					trick_effectivenum = trick_effectivenum - 1
				end
			end
			trick_effectivenum = trick_effectivenum + 1
		elseif acard:isKindOf("Slash") and self:slashIsEffective(acard, enemy)
			and self.player:distanceTo(enemy) <= self.player:getAttackRange()
			and (slash_damagenum < 1 or self:hasCrossbowEffect())
		then
			if not (enemy:hasSkill("xiangle") and basicnum < 2) then slash_damagenum = slash_damagenum + 1 end
			if self:getCardsNum("Analeptic") > 0 and analepticpowerup < 1
				and not (enemy:hasArmorEffect("silver_lion") or self:hasEightDiagramEffect(enemy))
				and not IgnoreArmor(self.player, enemy)
			then
				slash_damagenum = slash_damagenum + 1
				analepticpowerup = analepticpowerup + 1
			end
			if self.player:hasWeapon("guding_blade")
				and (enemy:isKongcheng() or self.player:hasSkill("lihun") and enemy:isMale() and not enemy:hasSkill("kongcheng"))
				and not (enemy:hasArmorEffect("silver_lion") and not IgnoreArmor(self.player, enemy))
			then
				slash_damagenum = slash_damagenum + 1
			end
		end
	end
	if type == 0 then
		return trick_effectivenum + slash_damagenum - effectivefireattacknum - enemy:getHp()
	else
		return trick_effectivenum + slash_damagenum - enemy:getHp()
	end
	return -10
end

function getBestHp(owner)
	if owner:hasSkill("longhun") and owner:getCardCount() > 2 then return 1 end
	if owner:hasSkill("hunzi") and owner:getMark("hunzi") == 0 then return 2 end
	for skill, dec in pairs({ ganlu = 1, yinghun = 2, nosmiji = 1, xueji = 1, baobian = math.max(0, owner:getMaxHp() - 3) }) do
		if owner:hasSkill(skill) then
			return math.max((owner:getRole() == "lord" and 3 or 2), owner:getMaxHp() - dec)
		end
	end
	if owner:hasSkills("renjie+baiyin") and owner:getMark("baiyin") == 0 then return owner:getMaxHp() - 1 end
	if owner:hasSkills("quanji+zili") and owner:getMark("zili") == 0 then return owner:getMaxHp() - 1 end

	--add
	if owner:hasSkills("LuaHuaji+LuaBaonu") and owner:getMark("LuaBaonu") == 0 then return owner:getMaxHp() - 1 end
	if owner:hasSkills("LuaHuaji+xingLuashenji") and owner:getMark("xingLuashenji") == 0 then return owner:getMaxHp() - 1 end
	if owner:hasSkills("du_jieying+duYinling") and owner:getMark("du_jieying") == 0 and owner:getPile("du_jin"):length() >= 2 then
		return
			owner:getMaxHp() - 2
	end
	if owner:hasSkill("duWuhun") and owner:getMark("BladeUsed") == 0 and owner:getMark("ChiTuUsed") == 0 then
		return
			owner:getMaxHp() - 1
	end
	if owner:hasSkill("meizlwuqing") then return owner:getMaxHp() - 1 end
	if owner:hasSkill("luanixi") then return owner:getMaxHp() - 1 end

	if owner:hasSkill("meizlshangwu") and owner:getMark("meizlshangwu1") == 0 then return 2 end
	if owner:hasSkill("meizlshangwu") and owner:getMark("meizlshangwu2") == 0 then return 1 end



	return owner:getMaxHp()
end

function SmartAI:isGoodHp(to)
	to = to or self.player
	if to:getHp() > 1 or hasBuquEffect(to) or canNiepan(to)
		or getCardsNum("Peach,Analeptic", to, self.player) > 0 then
		return true
	elseif not (self.room:getCurrent() and self.room:getCurrent():hasSkill("wansha"))
	then
		for _, p in sgs.list(self:getFriendsNoself(to)) do
			if getCardsNum("Peach", p, self.player) > 0
			then
				return true
			end
		end
	end
end

function SmartAI:needToLoseHp(to, from, card, passive, recover)
	from = from or self.room:getCurrent() or self.player
	to = to or self.player
	if hasJueqingEffect(from, to)
	then
		if self:hasSkills(sgs.masochism_skill, to)
		then
			return
		end
	else
		if self:dontHurt(to, from) then
			return
		end
		if card and card:isKindOf("Slash")
		then
			if from:hasWeapon("ice_sword") and to:getCardCount() > 1 and not self:isFriend(from, to)
				or from:hasSkill("nosqianxi") and from:distanceTo(to) == 1 and not self:isFriend(from, to)
				or self:ajustDamage(from, to, 1, card) > 1
				or to:hasSkill("sizhan")
			then
				return
			end
		end
		if to:hasLordSkill("shichou") then
			return sgs.ai_need_damaged.shichou(self, from, to) == 1
		end
		if to:hasSkill("dev_110") and to:getMark("dev_110_first_time") <= 0 and from:faceUp()
			and self:isWeak(from) and to:getPhase() == sgs.Player_NotActive
		then
			return math.random() < 0.95
		end --据守、放逐什么的再说吧
		if self:isGoodHp(to)
		then
			for nd, as in sgs.list(aiConnect(to)) do
				nd = sgs.ai_need_damaged[as]
				if type(nd) == "function" and nd(self, from, to, card)
				then
					return math.random() < 0.95
				end
			end
		end
	end
	if self:ajustDamage(from, to, 1, card) >= to:getHp() then return end
	local bh = getBestHp(to)
	if not passive and to:getMaxHp() > 2
	then
		if to:hasSkills("longluo|miji|yinghun") and self:findFriendsByType(sgs.Friend_Draw, to)
			or to:hasSkills("nosrende|rende") and not self:willSkipPlayPhase(to) and self:findFriendsByType(sgs.Friend_Draw, to)
			or to:hasSkill("jspdanqi") and self:getOverflow() == 0
		then
			bh = math.min(bh, to:getMaxHp() - 1)
		end
		local count = sgs.Sanguosha:getPlayerCount(sgs.getMode)
		if to:hasSkill("qinxue") and (self:getOverflow() == 1 and count >= 7 or self:getOverflow() == 2 and count < 7)
			or to:hasSkill("canshi") and count >= 3 then
			bh = math.min(bh, to:getMaxHp() - 1)
		end

		--add
		if to:hasSkills("echinei") and self:findFriendsByType(sgs.Friend_Draw, to) and not self:willSkipDrawPhase(to)
		then
			bh = math.min(bh, to:getMaxHp() - 1)
		end
		if to:hasSkills("meizljichi") and self:findFriendsByType(sgs.Friend_Draw, to) and not self:willSkipPlayPhase(to)
		then
			bh = math.min(bh, to:getMaxHp() - 1)
		end
	end
	local xiangxiang = self.room:findPlayerBySkillName("jieyin")
	if xiangxiang and xiangxiang:isWounded()
		and not to:isWounded() and to:isMale()
		and self:isFriend(xiangxiang, to)
	then
		local need_jieyin = true
		for _, friend in sgs.list(self:sort(self:getFriendsNoself(to), "hp")) do
			if friend:isMale() and friend:isWounded()
			then
				need_jieyin = false
				break
			end
		end
		if need_jieyin then bh = math.min(bh, to:getMaxHp() - 1) end
	end
	return (recover and to:getHp() >= bh or to:getHp() > bh)
		and math.random() < 0.95
end

function IgnoreArmor(from, to)
	return from:hasWeapon("qinggang_sword") and to:getMark("Equips_of_Others_Nullified_to_You") < 1
		or not to:hasArmorEffect(nil)
end

function SmartAI:needToThrowArmor(player)
	player = player or self.player
	if not player or not player:getArmor() or not player:hasArmorEffect(player:getArmor():objectName()) then return false end
	if player:hasSkills("bazhen|yizhong") and not player:getArmor():isKindOf("EightDiagram") then return true end
	if self:evaluateArmor(nil, player) <= -2 then return true end
	if player:hasArmorEffect("silver_lion") and player:isWounded()
	then
		if self:isFriend(player)
		then
			if player:objectName() ~= self.player:objectName()
			then
				return self:isWeak(player) and not player:hasSkills(sgs.use_lion_skill)
			else
				return true
			end
		end
		return true
	end
	local FS = dummyCard("fire_slash")
	if not self.player:hasSkill("moukui")
		and player:hasArmorEffect("vine")
		and player:objectName() ~= self.player:objectName()
		and self:isEnemy(player)
		and self.player:getPhase() == sgs.Player_Play
		and self:slashIsAvailable()
		and not self:slashProhibit(FS, player)
		and not IgnoreArmor(self.player, player)
		and (self:getCard("FireSlash")
			or (self:getCard("Slash")
				and (self.player:hasWeapon("fan")
					or self.player:hasSkills("lihuo|zonghuo")
					or self:getCardsNum("fan") >= 1)))
		and (player:isKongcheng()
			or sgs.card_lack[player:objectName()]["Jink"] == 1
			or getCardsNum("Jink", player, self.player) < 1)
	then
		return true
	end
	return false
end

function SmartAI:doNotDiscard(to, flags, conservative, n, cant_choose)
	if not to then
		global_room:writeToConsole(debug.traceback())
		return
	end
	n = n or 1
	flags = flags or "he"
	to = BeMan(global_room, to)
	if to and to:isNude() then return true end
	conservative = conservative or (sgs.turncount <= 2 and self.room:alivePlayerCount() > 2)
	local enemies = self:getEnemies(to)
	if #enemies == 1 and self:hasSkills("noswuyan|qianxun|weimu", enemies[1]) and self.room:alivePlayerCount() == 2 then conservative = false end
	--if to:hasSkill("tuntian") and to:hasSkill("zaoxian") and to:getPhase() == sgs.Player_NotActive and (conservative or #self.enemies > 1) then return true end
	if hasTuntianEffect(to) and (conservative or #self.enemies > 1) then return true end
	if cant_choose
	then
		if to:hasSkill("lirang") and #self.enemies > 1 then return true end
		if self:needKongcheng(to) and to:getHandcardNum() <= n then return true end
		if self:getLeastHandcardNum(to) <= n then return true end
		if self:hasSkills(sgs.lose_equip_skill, to) and to:hasEquip() then return true end
		if to:hasSkill("dev_quanneng") and to:getMark("&dev_die") > 0 and to:hasEquip() then return true end
		if self:needToThrowArmor(to) then return true end
	else
		if flags:match("e") then
			if to:hasSkills("jieyin+xiaoji") and to:getDefensiveHorse() then return false end
			if to:hasSkills("jieyin+xiaoji") and to:getArmor() and not to:getArmor():isKindOf("SilverLion") then return false end
			if to:hasSkill("zhexiu") and to:getCard(flags):length() < 2 and to:getEquips():length() == 1 then return false end
		end
		if flags == "h" or (flags == "he" and not to:hasEquip()) then
			if to:isKongcheng() or not self.player:canDiscard(to, "h") then return true end
			if not self:hasLoseHandcardEffective(to) then return true end
			if to:getHandcardNum() == 1 and self:needKongcheng(to) then return true end
			if #self.friends > 1 and to:getHandcardNum() == 1 and to:hasSkill("sijian") then return false end
		elseif flags == "e" or (flags == "he" and to:isKongcheng()) then
			if not to:hasEquip() then return true end
			if self:hasSkills(sgs.lose_equip_skill, to) then return true end
			if to:hasSkill("dev_quanneng") and to:getMark("&dev_die") > 0 then return true end
			if to:getCardCount(true) == 1 and self:needToThrowArmor(to) then return true end
		end
		if flags == "he" and n == 2 then
			if not self.player:canDiscard(to, "e") then return true end --why?
			if to:getCardCount(true) < 2 then return true end
			if not to:hasEquip() then
				if not self:hasLoseHandcardEffective(to) then return true end
				if to:getHandcardNum() <= 2 and self:needKongcheng(to) then return true end
			end
			if self:hasSkills(sgs.lose_equip_skill, to) and to:getHandcardNum() < 2 then return true end
			if to:hasSkill("dev_quanneng") and to:getMark("&dev_die") > 0 and to:getHandcardNum() < 2 then return true end
			if to:getCardCount(true) <= 2 and self:needToThrowArmor(to) then return true end
		end
	end
	if flags == "he" and n > 2 then
		if not self.player:canDiscard(to, "e") then return true end --why?
		if to:getCardCount() < n then return true end
	end
	return false
end

function SmartAI:findPlayerToDiscard(flags, include_self, no_dis, players, return_table, reason)
	local friends, enemies = {}, {}
	if players
	then
		for _, p in sgs.list(players) do
			if self:isEnemy(p) then
				table.insert(enemies, p)
			elseif self:isFriend(p) and (include_self or p:objectName() ~= self.player:objectName())
			then
				table.insert(friends, p)
			end
		end
	else
		friends = include_self and self.friends or self.friends_noself
		enemies = self.enemies
	end
	flags = flags or "he"
	reason = reason or ""
	local player_table = {}
	no_dis = no_dis == false
	function IsDis(from, to)
		if reason == "zhujinqiyuan"
		then
			if from:distanceTo(to) > 1
			then
				no_dis = false
			else
				no_dis = true
			end
		end
	end

	self:sort(enemies, "defense")
	if flags:match("e")
	then
		for _, enemy in sgs.list(enemies) do
			IsDis(self.player, enemy)
			if self:canDisCard(enemy, "e", nil, no_dis)
				or no_dis and not enemy:isKongcheng()
			then
				dangerous = self:getDangerousCard(enemy)
				if dangerous and self:canDisCard(enemy, dangerous, nil, no_dis)
				then
					table.insert(player_table, enemy)
				end
			end
		end
		for _, enemy in sgs.list(enemies) do
			IsDis(self.player, enemy)
			if enemy:hasArmorEffect("eight_diagram")
				and enemy:getArmor() and not self:needToThrowArmor(enemy)
			then
				if self:canDisCard(enemy, enemy:getArmor():getEffectiveId(), nil, no_dis)
				then
					table.insert(player_table, enemy)
				end
			end
		end
	end
	if flags:match("j")
	then
		for _, friend in sgs.list(friends) do
			IsDis(self.player, friend)
			if (friend:containsTrick("indulgence") and not friend:hasSkill("keji") or friend:containsTrick("supply_shortage"))
				and not friend:containsTrick("YanxiaoCard") and not (friend:hasSkill("qiaobian") and not friend:isKongcheng())
				and self:canDisCard(friend, "j", nil, no_dis)
			then
				table.insert(player_table, friend)
			end
		end
		for _, friend in sgs.list(friends) do
			IsDis(self.player, friend)
			if self:hasWizard(enemies, true)
				and friend:containsTrick("lightning")
				and self:canDisCard(friend, "j", nil, no_dis)
			then
				table.insert(player_table, friend)
			end
		end
		for _, enemy in sgs.list(enemies) do
			IsDis(self.player, enemy)
			if self:hasWizard(enemies, true)
				and enemy:containsTrick("lightning")
				and self:canDisCard(enemy, "j", nil, no_dis)
			then
				table.insert(player_table, enemy)
			end
		end
	end
	if flags:match("e")
	then
		for _, friend in sgs.list(friends) do
			IsDis(self.player, friend)
			if self:canDisCard(friend, "e", nil, no_dis)
			then
				table.insert(player_table, friend)
			end
		end
		for _, enemy in sgs.list(enemies) do
			IsDis(self.player, enemy)
			if self:canDisCard(enemy, "e", nil, no_dis)
			then
				valuable = self:getValuableCard(enemy)
				if valuable and self:canDisCard(enemy, valuable, nil, no_dis)
				then
					table.insert(player_table, enemy)
				end
			end
		end
		for _, enemy in sgs.list(enemies) do
			IsDis(self.player, enemy)
			if enemy:hasSkills("jijiu|beige|mingce|weimu|qingcheng")
				and not self:doNotDiscard(enemy, "e")
			then
				for _, e in sgs.list(enemy:getEquips()) do
					if self:canDisCard(enemy, e:getId(), nil, no_dis)
					then
						table.insert(player_table, enemy)
						break
					end
				end
			end
		end
	end
	if flags:match("h")
	then
		for _, enemy in sgs.list(enemies) do
			IsDis(self.player, enemy)
			if enemy:getHandcardNum() <= 2 and enemy:getHandcardNum() > 0
				and not (hasTuntianEffect(enemy, true))
			then
				flag = string.format("%s_%s_%s", "visible", self.player:objectName(), enemy:objectName())
				for _, h in sgs.list(enemy:getHandcards()) do
					if (h:hasFlag("visible") or h:hasFlag(flag))
						and (h:isKindOf("Peach") or h:isKindOf("Analeptic"))
						and self:canDisCard(enemy, h:getEffectiveId(), nil, no_dis)
					then
						table.insert(player_table, enemy)
					end
				end
			end
		end
	end
	if flags:match("e")
	then
		for _, enemy in sgs.list(enemies) do
			IsDis(self.player, enemy)
			if enemy:hasEquip() and not self:doNotDiscard(enemy, "e")
				and self:canDisCard(enemy, "e", nil, no_dis)
			then
				table.insert(player_table, enemy)
			end
		end
	end
	if flags:match("j")
	then
		for _, enemy in sgs.list(enemies) do
			IsDis(self.player, enemy)
			if self:canDisCard(enemy, "j", nil, no_dis)
			then
				table.insert(player_table, enemy)
			end
		end
	end
	if flags:match("h")
	then
		self:sort(enemies, "handcard")
		for _, enemy in sgs.list(enemies) do
			IsDis(self.player, enemy)
			if not self:doNotDiscard(enemy, "h")
				and self:canDisCard(enemy, "h", nil, no_dis)
			then
				table.insert(player_table, enemy)
			end
		end
		zhugeliang = self.room:findPlayerBySkillName("kongcheng")
		if zhugeliang
		then
			IsDis(self.player, zhugeliang)
			if self:isFriend(zhugeliang) and zhugeliang:getHandcardNum() == 1
				and self:getEnemyNumBySeat(self.player, zhugeliang) > 0 and zhugeliang:getHp() <= 2
				and self:canDisCard(zhugeliang, "h", nil, no_dis)
			then
				table.insert(player_table, zhugeliang)
			end
		end
	end
	local new_player_table = {} --有的角色重复加入了，需要去重
	for _, p in sgs.list(player_table) do
		if table.contains(new_player_table, p)
		then else
			table.insert(new_player_table, p)
		end
	end
	return return_table and new_player_table or new_player_table[1]
end

function SmartAI:findPlayerToDraw(include_self, drawnum, count)
	drawnum = drawnum or 1
	local friends, player_list = {}, sgs.SPlayerList()
	local players = sgs.QList2Table(include_self and self.room:getAllPlayers() or self.room:getOtherPlayers(self.player))
	for _, player in sgs.list(players) do
		if self:isFriend(player) and not hasManjuanEffect(player)
			and not (player:hasSkill("kongcheng") and player:isKongcheng() and drawnum <= 2) then
			table.insert(friends, player)
		end
	end
	if #friends < 1 then return end

	self:sort(friends, "defense")
	for _, friend in sgs.list(friends) do
		if friend:getHandcardNum() < 2 and not self:needKongcheng(friend) and not self:willSkipPlayPhase(friend) then
			if count then
				if not player_list:contains(friend) then player_list:append(friend) end
				if count == player_list:length() then return sgs.QList2Table(player_list) end
			else
				return friend
			end
		end
	end

	local AssistTarget = self:AssistTarget()
	if AssistTarget and not self:willSkipPlayPhase(AssistTarget)
		and (AssistTarget:getHandcardNum() < AssistTarget:getMaxCards() * 2 or AssistTarget:getHandcardNum() < self.player:getHandcardNum())
	then
		for _, friend in sgs.list(friends) do
			if friend:objectName() == AssistTarget:objectName() and not self:willSkipPlayPhase(friend)
			then
				if count then
					if not player_list:contains(friend) then player_list:append(friend) end
					if count == player_list:length() then return sgs.QList2Table(player_list) end
				else
					return friend
				end
			end
		end
	end

	for _, friend in sgs.list(friends) do
		if self:hasSkills(sgs.cardneed_skill, friend) and not self:willSkipPlayPhase(friend)
		then
			if count then
				if not player_list:contains(friend) then player_list:append(friend) end
				if count == player_list:length() then return sgs.QList2Table(player_list) end
			else
				return friend
			end
		end
	end

	self:sort(friends, "handcard")
	for _, friend in sgs.list(friends) do
		if not self:needKongcheng(friend) and not self:willSkipPlayPhase(friend)
		then
			if count then
				if not player_list:contains(friend) then player_list:append(friend) end
				if count == player_list:length() then return sgs.QList2Table(player_list) end
			else
				return friend
			end
		end
	end
	if count then return sgs.QList2Table(player_list) end
	return
end

function SmartAI:findPlayerToDamage(damage, player, nature, targets, include_self, base_value, return_table)
	damage = damage or 1
	nature = nature or "N"
	base_value = base_value or 0
	targets = targets or include_self ~= false and self.room:getOtherPlayers(player) or self.room:getAlivePlayers()
	targets = sgs.QList2Table(targets)
	if #targets < 2
	then
		if return_table then
			return targets
		else
			return targets[1]
		end
	end

	function getDamageValue(target, self_only)
		local value, count = 0, self:ajustDamage(player, target, damage, nil, nature)
		if self:damageIsEffective(target, nature, player)
		then else
			count = 0
		end
		if count > 0
		then
			value = value + count * 20 --设1牌价值为10，且1体力价值2牌，1回合价值2.5牌，下同
			local hp = target:getHp()
			local deathFlag = false
			if count >= hp then
				deathFlag = count >= hp + self:getAllPeachNum(target)
			end
			if deathFlag then
				value = value + 500
			else
				if hp >= getBestHp(target) + count
				then
					value = value - 2
				end
				if self:needToLoseHp(target, player)
				then
					value = value - 5
				end
				if self:isWeak(target) then
					value = value + 15
				else
					value = value + 12 - sgs.getDefense(target)
				end
				if hp <= count then
					if target:hasSkill("jiushi") and target:faceUp()
					then
						value = value + 25
					end
				end
				if self:needToLoseHp(target, player)
				then
					if target:hasSkill("nosyiji")
					then
						value = value - 20 * count
					end
					if target:hasSkill("yiji")
					then
						value = value - 10 * count
					end
					if target:hasSkill("jieming")
					then
						chaofeng = self:getJiemingChaofeng(target)
						if chaofeng > 0 then
							value = value - (5 - chaofeng) * 5
						else
							value = value + chaofeng * 5
						end
					end
					if target:hasSkill("guixin")
					then
						x = 0
						value = value + 25
						for _, p in sgs.list(self.room:getOtherPlayers(target)) do
							if p:getCardCount(true, true) > 0
							then
								x = x + 1
								if self:isFriend(p, target)
								then
									if p:getJudgingArea():length() > 0 then value = value - 5 end
								elseif p:isNude() then
									value = value + 5
								end
							end
						end
						if not hasManjuanEffect(target)
						then
							value = value - x * 10
						end
					end
					if target:hasSkill("chengxiang")
					then
						value = value + 15
					end
					if target:hasSkill("noschengxiang")
					then
						value = value + 15
					end
				end
			end
			if self:isFriend(target) then
				value = -value
			elseif not self:isEnemy(target) then
				value = value / 2
			end
			if self_only or nature == "N" then
			elseif target:isChained()
			then
				for _, p in sgs.list(self.room:getOtherPlayers(target)) do
					if p:isChained() then
						value = value + getDamageValue(p, true)
					end
				end
			end
			if self:cantbeHurt(target, player, count) then value = value - 800 end
			if deathFlag and self.role == "renegade" and target:getRole() == "lord"
				and target:aliveCount() > 2 then
				value = value - 1000
			end
		end
		return value
	end

	local func = function(a, b)
		return getDamageValue(a) >= getDamageValue(b)
	end
	table.sort(targets, func)
	if return_table then
		local result = {}
		for _, victim in sgs.list(targets) do
			if getDamageValue(victim) > base_value
			then
				table.insert(result, victim)
			end
		end
		return result
	end
	if getDamageValue(targets[1]) > base_value then return targets[1] end
end

function SmartAI:dontRespondPeachInJudge(judge)
	local peach_num = self:getCardsNum("Peach")
	if peach_num < 1 then return false end
	if self:willSkipPlayPhase() and peach_num > self:getOverflow(self.player, true) then return false end
	local card = self:getCard("Peach")
	local dummy = { isDummy = true }
	self:useBasicCard(card, dummy)
	if dummy.card then return true end
	if peach_num <= self.player:getLostHp()
		or self:isWeak(self.friends)
	then
		return true
	end
	--judge.reason:baonue,neoganglie,ganglie,caizhaoji_hujia
	if judge.reason == "tuntian" and judge.who:getMark("zaoxian") < 1
		and judge.who:getPile("field"):length() < 2 then
		return true
	elseif (judge.reason == "EightDiagram" or judge.reason == "bazhen")
		and (not self:isWeak(judge.who) or judge.who:hasSkills(sgs.masochism_skill))
		and self:isFriend(judge.who) then
		return true
	elseif judge.reason == "nosmiji" and judge.who:getLostHp() == 1
	then
		return true
	elseif judge.reason == "shaoying" and sgs.shaoying_target
	then
		if sgs.shaoying_target:hasArmorEffect("vine") and sgs.shaoying_target:getHp() > 3
			or sgs.shaoying_target:getHp() > 2 then
			return true
		end
	elseif judge.reason:match("tieji")
		or judge.reason:match("qianxi")
		or judge.reason:match("beige")
	then
		return true
	end
	return false
end

function CanUpdateIntention(player)
	local current_rebel_num = 0
	for _, ap in sgs.qlist(global_room:getAlivePlayers()) do
		if sgs.ai_role[ap:objectName()] == "rebel"
		then
			current_rebel_num = current_rebel_num + 1
		end
	end
	if sgs.ai_role[player:objectName()] == "rebel" and current_rebel_num >= sgs.playerRoles.rebel
		or sgs.ai_role[player:objectName()] == "neutral" and current_rebel_num + 2 >= sgs.playerRoles.rebel
	then
		return false
	end
	return true
end

function SmartAI:AssistTarget()
	if sgs.ai_AssistTarget_off then return end
	local human_count, player = 0, nil
	if not sgs.ai_AssistTarget then
		for _, p in sgs.list(self.room:getAlivePlayers()) do
			if p:getState() ~= "robot" then
				human_count = human_count + 1
				player = p
			end
		end
		if human_count == 1 and player then
			sgs.ai_AssistTarget = player
		else
			sgs.ai_AssistTarget_off = true
		end
	end
	player = sgs.ai_AssistTarget
	if player and player:isAlive() and self:isFriend(player)
		and player:objectName() ~= self.player:objectName() and self:getOverflow(player) > 1
		and not player:hasSkill("nosjuejing") and self:getOverflow(player) < 3
	then
		return player
	end
end

function SmartAI:findFriendsByType(prompt, player)
	player = player or self.player
	local friends = self:getFriendsNoself(player)
	if #friends < 1 then return false end
	if prompt == sgs.Friend_Draw
	then
		for _, friend in sgs.list(friends) do
			if not friend:hasSkill("manjuan") and not self:needKongcheng(friend, true) then return true end
		end
	elseif prompt == sgs.Friend_Male
	then
		for _, friend in sgs.list(friends) do
			if friend:isMale() then return true end
		end
	elseif prompt == sgs.Friend_MaleWounded
	then
		for _, friend in sgs.list(friends) do
			if friend:isMale() and friend:isWounded() then return true end
		end
	elseif prompt == sgs.Friend_All
	then
		return true
	elseif prompt == sgs.Friend_Weak
	then
		for _, friend in sgs.list(friends) do
			if self:isWeak(friend) then return true end
		end
	else
		global_room:writeToConsole(debug.traceback())
		return
	end
	return false
end

function SmartAI:willSkipPlayPhase(player, NotContains_Null)
	player = player or self.player
	if player:isSkipped(sgs.Player_Play) then return true end
	fuhuanghou = self.room:findPlayerBySkillName("noszhuikong")
	if fuhuanghou and fuhuanghou:objectName() ~= player:objectName() and self:isEnemy(player, fuhuanghou)
		and fuhuanghou:isWounded() and fuhuanghou:getHandcardNum() > 1 and not player:isKongcheng() and not self:isWeak(fuhuanghou)
	then
		local max_card = self:getMaxCard(fuhuanghou)
		local player_max_card = self:getMaxCard(player)
		if max_card and player_max_card and max_card:getNumber() > player_max_card:getNumber()
			or max_card and max_card:getNumber() >= 12 then
			return true
		end
	end
	cp = self.room:getCurrent()
	friend_snatch_dismantlement, friend_null = 0, 0
	if cp and self.player:objectName() == cp:objectName()
		and self.player:objectName() ~= player:objectName() and self:isFriend(player)
	then
		for _, h in sgs.list(self.player:getCards("he")) do
			if isCard("Snatch", h, self.player) and self.player:distanceTo(player) == 1
				or isCard("Dismantlement", h, self.player)
			then
				trick = dummyCard(h:objectName())
				trick:addSubcard(h)
				if self:hasTrickEffective(trick, player, self.player)
				then
					friend_snatch_dismantlement = friend_snatch_dismantlement + 1
				end
			end
		end
	end
	if not NotContains_Null
	then
		for _, p in sgs.list(self.room:getAllPlayers()) do
			if self:isFriend(p, player) then friend_null = friend_null + getCardsNum("Nullification", p, self.player) end
			if self:isEnemy(p, player) then friend_null = friend_null - getCardsNum("Nullification", p, self.player) end
		end
	end
	if player:containsTrick("Indulgence")
	then
		if player:containsTrick("YanxiaoCard") or self:hasSkills("keji|conghui", player) or (player:hasSkill("qiaobian") and not player:isKongcheng()) then return false end
		if friend_null + friend_snatch_dismantlement > 1 then return false end
		local i, to = self:getFinalRetrial(player)
		if i == 1 and self:getSuitNum("heart", true, to) > 0
		then
			return false
		end
		return true
	end

	--add
	caifuren = self.room:findPlayerBySkillName("noszhuikong")
	if caifuren and caifuren:objectName() ~= player:objectName() and self:isEnemy(player, caifuren)
		and caifuren:canPindian(player) and not self:isWeak(caifuren)
	then
		local max_card = self:getMaxCard(caifuren)
		local player_max_card = self:getMaxCard(player)
		if max_card and player_max_card and max_card:getNumber() > player_max_card:getNumber()
			or max_card and max_card:getNumber() >= 12 then
			return true
		end
	end


	return false
end

function SmartAI:willSkipDrawPhase(player, NotContains_Null)
	player = player or self.player
	if player:getMark("&yizheng") + player:getMark("&zhibian") + player:getMark("kuanshi_skip") > 0
	then
		return true
	end
	local friend_null, friend_snatch_dismantlement = 0, 0
	if not NotContains_Null
	then
		for _, p in sgs.list(self.room:getAllPlayers()) do
			if self:isFriend(p, player) then friend_null = friend_null + getCardsNum("Nullification", p, self.player) end
			if self:isEnemy(p, player) then friend_null = friend_null - getCardsNum("Nullification", p, self.player) end
		end
	end
	local cp = self.room:getCurrent()
	if cp and self.player:objectName() == cp:objectName()
		and self.player:objectName() ~= player:objectName() and self:isFriend(player)
	then
		for _, h in sgs.list(self.player:getCards("he")) do
			if isCard("Snatch", h, self.player) and self.player:distanceTo(player) == 1
				or isCard("Dismantlement", h, self.player)
			then
				local trick = dummyCard(h:objectName())
				trick:addSubcard(h)
				if self:hasTrickEffective(trick, player, self.player)
				then
					friend_snatch_dismantlement = friend_snatch_dismantlement + 1
				end
			end
		end
	end
	if player:containsTrick("supply_shortage")
	then
		if player:containsTrick("YanxiaoCard") or self:hasSkills("shensu|jisu", player)
			or player:hasSkill("qiaobian") and player:getHandcardNum() > 0 then
			return false
		end
		if friend_null + friend_snatch_dismantlement > 1 then return false end
		local i, to = self:getFinalRetrial(player)
		if i == 1 and self:getSuitNum("club", true, to) > 0
		then
			return false
		end
		return true
	end
	return false
end

function SmartAI:willSkipDiscardPhase(player)
	player = player or self.player
	--克己、巧变、界神速、奋励
	if player:hasSkill("conghui")
		or player:getMark("&mobilexinyinju") > 0
	then
		return true
	end
	if player:hasSkill("xingzhao")
	then
		local wounded = 0
		for _, p in sgs.list(self.room:getAlivePlayers()) do
			if not p:isWounded() then continue end
			wounded = wounded + 1
			if wounded >= 3 then break end
		end
		if wounded >= 3 then return true end
	end

	--add

	if player:hasSkill("ekegou") then
		for _, p in sgs.list(self.room:getAlivePlayers()) do
			if p:getHandcardNum() >= player:getHandcardNum() then
				return true
			end
		end
	end


	return false
end

function hasBuquEffect(player)
	return player:hasSkill("buqu") and player:getPile("buqu"):length() <= 4
		or player:hasSkill("nosbuqu") and player:getPile("nosbuqu"):length() <= 4
		or player:hasSkill("PlusBuqu") and player:getPile("Plushurt"):length() <= 4 --add
end

function canNiepan(player)
	return player:hasSkill("niepan") and player:getMark("@nirvana") > 0
		or player:hasSkill("mobileniepan") and player:getMark("@mobileniepanMark") > 0
		or player:hasSkill("olniepan") and player:getMark("@olniepanMark") > 0
		or player:hasSkill("fuli") and player:getMark("@laoji") > 0
		--add
		or player:hasSkill("blood_gudan") and player:getMark("@gudan") > 0
		or player:hasLordSkill("blood_hunzi") and player:getMark("blood_hunzi") == 0
		or player:hasSkill("meizlboxing") and player:faceUp() and player:getHandcardNum() > 0
end

function SmartAI:adjustAIRole()
	sgs.explicit_renegade = false
	for role, ap in sgs.qlist(self.room:getAlivePlayers()) do
		role = ap:getRole()
		if role == "renegade" then sgs.explicit_renegade = true end
		if role ~= "lord"
		then
			sgs.roleValue[ap:objectName()]["renegade"] = 0
			if role == "rebel" then
				sgs.roleValue[ap:objectName()]["loaylist"] = -65535
			else
				sgs.roleValue[ap:objectName()][role] = 65535
			end
			sgs.ai_role[ap:objectName()] = role
		end
	end
end

function hasWulingEffect(element)
	if not element:startsWith("@") then element = "@" .. element end
	for _, p in sgs.list(global_room:getAlivePlayers()) do
		if p:hasSkill("wuling") and p:getMark(element) > 0
		then
			return true
		end
	end
end

function hasTuntianEffect(to, need_zaoxian)
	if to:hasSkills("tuntian|mobiletuntian|oltuntian") and to:getPhase() == sgs.Player_NotActive
	then
		if need_zaoxian
		then
			return to:hasSkills("zaoxian|olzaoxian")
		end
		return true
	end
	--add
	if to:hasSkill("meizljinlian") and to:getPhase() == sgs.Player_NotActive
	then
		return true
	end
	return false
end

function SmartAI:isValueSkill(skill_name, player, HighValue)
	if not skill_name then return false end
	player = player or self.player
	if string.find(sgs.bad_skills, skill_name) then return false end
	if (skill_name == "buqu" or skill_name == "nosbuqu") and hasBuquEffect(player) and (not HighValue or player:getHp() <= 1) then return true end
	if not HighValue then
		local powerful_skills = { "zhiheng", "tenyearzhiheng", "jijiu" } --待补充
		if table.contains(powerful_skills, skill_name) then return true end
	end
	local skill = sgs.Sanguosha:getSkill(skill_name)
	if not skill then return false end
	if skill:isLimitedSkill() and skill:getLimitMark() ~= "" and player:getMark(skill:getLimitMark()) > 0 then return true end
	if skill:getFrequency() == sgs.Skill_Wake and player:getMark(skill_name) == 0
	then
		if not HighValue then return true end
		if skill_name == "fengliang" then return true end
		if skill_name == "baiyin" and (player:getMark("&bear") >= 4 or player:hasSkill("renjie")) then return true end
		if skill_name == "chuyuan" and (player:getPile("cychu"):length() >= 3 or player:hasSkill("chuyuan")) then return true end
		if skill_name == "tianxing" and (player:getPile("cychu"):length() >= 3 or player:hasSkill("chuyuan")) then return true end
		if skill_name == "baoling" and player:getMark("HengzhengUsed") >= 1 then return true end
		if skill_name == "poshi" and (not player:hasequipArea() or player:getHp() == 1) then return true end
		if (skill_name == "hongju" or skill_name == "olhongju" or skill_name == "mobilehongju") --暂且不管需不需要有死亡角色了
			and (player:getPile("rong"):length() >= 3 or player:hasSkills("zhengrong|olzhengrong|mobilezhengrong")) then
			return true
		end
		if (skill_name == "zhiji" or skill_name == "mobilezhiji" or skill_name == "olzhiji") and player:isKongcheng() then return true end
		if skill_name == "mobilehunzi" and player:getHp() <= 2 then return true end
		if skill_name == "hunzi" and player:getHp() == 1 then return true end
		if skill_name == "mobilechengzhang" and player:getMark("&mobilechengzhang") + player:getMark("mobilechengzhang_num") >= 7 then return true end
		if (skill_name == "zaoxian" or skill_name == "olzaoxian")
			and (player:getPile("field"):length() >= 3 or player:hasSkills("tuntian|mobiletuntian|oltuntian")) then
			return true
		end
		if (skill_name == "ruoyu" or skill_name == "olruoyu") and player:isLowestHpPlayer() then return true end
		if skill_name == "nosbaijiang" and player:getEquips():length() >= 3 then return true end
		if skill_name == "noszili" and (player:getPile("nospower"):length() >= 3 or player:hasSkill("nosyexin")) then return true end
		if skill_name == "zili" and (player:getPile("power"):length() >= 3 or player:hasSkills("quanji|mobilequanji")) then return true end
		if skill_name == "zhiri" and (player:getPile("burn"):length() >= 3 or player:hasSkill("fentian")) then return true end
		if skill_name == "oljixi" and player:getMark("oljixi_turn") >= 2 then return true end
		if (skill_name == "wuji" or skill_name == "newwuji") and player:getMark("damage_point_round") >= 3 then return true end
		if skill_name == "juyi" and player:isWounded() and player:getMaxHp() > player:aliveCount() then return true end
		if skill_name == "choujue" and math.abs(player:getHandcardNum() - player:getHp()) >= 3 then return true end
		if skill_name == "beishui" and (player:getHandcardNum() < 2 or player:getHp() < 2) then return true end
		if skill_name == "longyuan" and player:getMark("&yizan") >= 3 then return true end
		if skill_name == "zhanyuan" and player:getMark("&zhanyuan_num") + player:getMark("zhanyuan_num") > 7 then return true end
		if skill_name == "secondzhanyuan" and player:getMark("&secondzhanyuan_num") + player:getMark("secondzhanyuan_num") > 7 then return true end
		if skill_name == "baijia" and player:getMark("&baijia_num") + player:getMark("baijia_num") >= 7 then return true end
		if skill_name == "diaoling" and player:getMark("&mubing") + player:getMark("mubing_num") >= 6 then return true end
		if skill_name == "shanli" and player:getTag("BaiyiUsed"):toBool() and #player:getTag("Jinglve_targets"):toStringList() >= 2 then return true end
		if skill_name == "zhanshen" and player:isWounded() and (player:getMark("zhanshen_fight") > 0 or player:getMark("@fight") > 0) then return true end
		if skill_name == "qianxin" and player:isWounded() then return true end
		if skill_name == "qinxue"
		then
			n = player:getHandcardNum() - player:getHp()
			if sgs.Sanguosha:getPlayerCount(sgs.getMode) >= 7 and n >= 2
				or n >= 3 then
				return true
			end
		end
		if skill_name == "jiehuo" and player:getMark("@shouye") >= 7 then return true end
		if skill_name == "kegou" and player:getKingdom() == "wu" then
			for _, p in sgs.list(player:getAliveSiblings()) do
				if p:getKingdom() == "wu" and not p:getRole() == "lord" then return false end
			end
			return true
		end
		if skill_name == "fanxiang" then
			for _, p in sgs.list(self.room:getAlivePlayers()) do
				if p:getTag("liangzhu_draw" .. player:objectName()):toBool() and p:isWounded() then return true end
			end
		end
		if skill_name == "jspdanqi" and player:getHandcardNum() > player:getHp() and self.room:getLord() ~= nil and not string.find(self.room:getLord():getGeneralName(), "liubei")
			and (not self.room:getLord():getGeneral2() or not string.find(self.room:getLord():getGeneral2Name(), "liubei")) then
			return true
		end
		if skill_name == "danji" and player:getHandcardNum() > player:getHp() and self.room:getLord() ~= nil and not string.find(self.room:getLord():getGeneralName(), "caocao")
			and (not self.room:getLord():getGeneral2() or not string.find(self.room:getLord():getGeneral2Name(), "caocao")) then
			return true
		end
		if skill_name == "jinsanchen" and (player:getMark("&jinsanchen") >= 3 or player:hasSkill("jinsanchen")) then return true end
		if skill_name == "mobilezhisanchen" and (player:getMark("&mobilezhiwuku") >= 3 or player:hasSkill("mobilezhiwuku")) then return true end
		if skill_name == "zongfan" and player:getMark("tunjiang_skip_play-Clear") <= 0 and player:getMark("mouni-Clear") > 0 then return true end
		if skill_name == "tenyearmoucheng" and player:getMark("tenyearlianji_choice_1") > 0 and player:getMark("tenyearlianji_choice_2") > 0 then return true end
		if skill_name == "olmoucheng" and (player:getMark("&ollianji") >= 3 or player:hasSkill("ollianji")) then return true end
		if skill_name == "secondolmoucheng" and player:getMark("&ollianjidamage") > 0 then return true end
		if skill_name == "mobilemoucheng" and player:getMark("&mobilelianji") > 2 then return true end
	end
	return false
end

function SmartAI:needToThrowCard(to, flags, dis, give, draw)
	to = to or self.player
	flags = flags or "he"
	if not give and not draw then dis = true end
	if flags:match("h") and not to:isKongcheng()
	then
		if not self:hasLoseHandcardEffective(to) and not dis
			or (dis or give) and self:needKongcheng(to, false, true)
			or draw and to:hasSkill("lirang") and self:findFriendsByType(sgs.Friend_Draw, to)
			or draw and to:hasSkill("shangjian") and to:getMark("shangjian-Clear") < to:getHp()
			or hasTuntianEffect(to)
		then
			return true
		end
	end
	if flags:match("e") and to:hasEquip() and not (to:getEquips():length() == 1 and self:keepWoodenOx(to))
	then
		if self:hasSkills(sgs.lose_equip_skill, to) and (to:getOffensiveHorse() or to:getWeapon())
			or draw and to:hasSkill("shangjian") and to:getMark("shangjian_lose_card_num-Clear") < to:getHp() and (to:getOffensiveHorse() or to:getWeapon())
			or not dis and to:hasArmorEffect("silver_lion") and to:isWounded() and not self:needToLoseHp(to, self.player, false, true, true) and not to:hasSkill("dingpan")
			or draw and to:hasSkill("shanjia") and to:getMark("&shanjia") < 3
			or self:needToThrowArmor(to)
			or hasTuntianEffect(to)
		then
			return true
		end
	end
	if flags:match("j") then
		if (to:containsTrick("indulgence") or to:containsTrick("supply_shortage")) and not to:containsTrick("YanxiaoCard") then return true end
	end
	return false
end

function SmartAI:keepCard(c, p, disPeach, asPeach)
	if not c then return true end
	p = p or self.player
	if c:isKindOf("WoodenOx")
		and p:getPile("wooden_ox"):length() > 0
	then
		if asPeach then
			for _, id in sgs.list(p:getPile("wooden_ox")) do
				if isCard("Peach", id, p) then return true end
			end
			return false
		end
		return true
	end
	if not disPeach and c:isKindOf("Peach") then return true end
	return false
end

function SmartAI:keepWoodenOx(p, flag)
	p = p or self.player
	flag = flag or "e"
	if not p:hasTreasure("wooden_ox") or p:getPile("wooden_ox"):length() < 1 then return false end
	return p:getCards(flag):length() == 1
end

function SmartAI:hasZhenguEffect(to, from)
	if not to or not to:hasSkill("zhengu") then return false end
	if self:isWeak(to) and to:getHp() < 2 and to:getHandcardNum() < 2
	then
		return false
	end

	from = from or self.player
	for _, p in sgs.list(self.room:getAlivePlayers()) do
		if p:getMark("&zhengu") > 0 and self:isEnemy(p, from) and not self:needKongcheng(p, true)
		then
			return true
		end
	end
	return false
end

function SmartAI:needDraw(to, notDraw)
	if not to then return false end
	if to:hasSkills("manjuan|zishu") and to:getPhase() ~= sgs.Player_NotActive then return true end
	if not notDraw and to:hasSkill("zhanji") and to:getPhase() == sgs.Player_Play then return true end
	if to:hasSkill("zhengu") and to:getHandcardNum() < 5 then
		for _, p in sgs.list(self.room:getAlivePlayers()) do
			if p:getMark("&zhengu") > 0 and self:isFriend(p, to)
			then
				return true
			end
		end
	end
	return false
end

function SmartAI:hasJieyingyEffect(player)
	player = player or self.player
	if player:getMark("&jygying") > 0 and not player:hasSkill("jieyingg")
	then
		for _, shenganning in sgs.list(self.room:findPlayersBySkillName("jieyingg")) do
			if not self:isFriend(shenganning, player) then return true end
		end
	end
	for _, gexuan in sgs.list(self.room:findPlayersBySkillName("zhafu")) do
		if table.contains(player:property("zhafu_from"):toStringList(), gexuan:objectName())
		then
			if not self:isFriend(gexuan, player)
			then
				return true
			end
		end
	end
	return false
end

function SmartAI:canDraw(to, from)
	to = to or self.player
	if self:needKongcheng(to, true)
	then
		return false
	end
	if hasManjuanEffect(to)
	then
		return false
	end
	if self:hasJieyingyEffect(to)
		and to:getPhase() > 4 and to:getPhase() < 7
	then
		return false
	end
	from = from or self.player
	if self:hasZhenguEffect(to, from)
	then
		return false
	end
	return true
end

function SmartAI:noChoice(targets, reason)
	if reason == "damage"
	then
		for _, p in sgs.list(targets) do
			if not self:damageIsEffective(p, nil, self.player)
				or self:needToLoseHp(p, self.player, nil, true)
				or sgs.ai_role[p:objectName()] == "neutral"
			then
				continue
			end
			sgs.updateIntention(self.player, p, -10)
		end
	elseif reason == "change"
	then
		for _, p in sgs.list(targets) do
			if hasManjuanEffect(p) or p:isNude()
				or sgs.ai_role[p:objectName()] == "neutral"
			then
				continue
			end
			sgs.updateIntention(self.player, p, 10)
		end
	elseif reason == "discard"
	then
		for _, p in sgs.list(targets) do
			if self:doNotDiscard(p)
				or sgs.ai_role[p:objectName()] == "neutral"
			then
				continue
			end
			sgs.updateIntention(self.player, p, -10)
		end
	elseif reason == "letDis"
	then
		for _, p in sgs.list(targets) do
			if self:needToThrowCard(p) or p:isNude()
				or sgs.ai_role[p:objectName()] == "neutral"
			then
				continue
			end
			sgs.updateIntention(self.player, p, -10)
		end
	else
		for _, p in sgs.list(targets) do
			if sgs.ai_role[p:objectName()] == "neutral"
				or not self:canDraw(p)
			then
				continue
			end
			sgs.updateIntention(self.player, p, 10)
		end
	end
end

function SmartAI:canDamage(to, from, slash, nature, card)
	from = from or self.room:getCurrent() or self.player
	to = to or self.player
	if not self:damageIsEffective(to, card, from)
		or self:isEnemy(to) and self:isFriend(from) and self:cantbeHurt(to, from) then
		return false
	end
	if self:isEnemy(to) then return not self:needToLoseHp(to, from, slash, true) end
	if self:isFriend(to) then return self:needToLoseHp(to, from, slash, true) end
	return not self:isFriend(to)
end

function SmartAI:findPlayerToLoseHp(must)
	local second
	self:sort(self.enemies, "hp")
	for _, enemy in sgs.list(self.enemies) do
		if not hasZhaxiangEffect(enemy) and not self:needToLoseHp(enemy, self.player, false, true) then return enemy end
		if must and not second then second = enemy end
	end
	if must then
		self:sort(self.friends_noself, "hp")
		self.friends_noself = sgs.reverse(self.friends_noself)
		for _, friend in sgs.list(self.friends_noself) do
			if hasZhaxiangEffect(friend) and not self:isWeak(friend)
				or self:needToLoseHp(friend, self.player, false, true)
			then
				return friend
			end
		end
	end
	return second
end

function SmartAI:disEquip(hand_only, equip_only)
	if self:needToThrowArmor() then
		return self.player:getArmor():getEffectiveId()
	end
	if hand_only and equip_only then return end
	local cards = self.player:getCards("he")
	if hand_only then cards = self.player:getHandcards() end
	if equip_only then cards = self.player:getEquips() end
	local equips = {}
	for _, c in sgs.list(cards) do
		if c:isKindOf("EquipCard") then
			if c:isKindOf("WoodenOx") and not self.player:getPile("wooden_ox"):isEmpty() then continue end
			table.insert(equips, c)
		end
	end
	if #equips < 1 then return end
	self:sortByKeepValue(equips)
	return equips[1]:getEffectiveId()
end

function hasOrangeEffect(player)
	return global_room:findPlayerBySkillName("huaiju") and player:getMark("&orange") > 0
end

function SmartAI:cantDamageMore(from, to)
	from = from or self.room:getCurrent() or self.player
	to = to or self.player
	if not hasJueqingEffect(from, to)
	then
		if to:hasArmorEffect("silver_lion") and not IgnoreArmor(from, to)
			or to:hasSkill("gongqing") and from:getAttackRange() < 3
			or hasOrangeEffect(to)
		then
			return true
		end
		jiaren_zidan = self.room:findPlayerBySkillName("jgchiying")
		if jiaren_zidan and jiaren_zidan:getRole() == to:getRole()
		then
			return true
		end
		if getSpecialMark("&tiansuan4", to) + getSpecialMark("&tiansuan5", to) < 1
		then
			if getSpecialMark("&tiansuan2", to) > 0 then return true end
			if getSpecialMark("&tiansuan3", to) > 0 then return true end --受到火焰伤害会加伤待补充
		end
	end
	return false
end

function canJiaozi(player)
	if not player:hasSkill("jiaozi") then return false end
	for _, p in sgs.list(player:getAliveSiblings()) do
		if p:getHandcardNum() >= player:getHandcardNum() then return false end
	end
	return true
end

function beFriend(to, from)
	if not (from and to) then return false end
	if from:objectName() == to:objectName() then return true end
	if from:getRole() == "lord" or from:getRole() == "loyalist"
	then
		if sgs.turncount <= 1 and to:getRole() == "renegade" and from:aliveCount() > 7
			or to:getRole() == "lord" or to:getRole() == "loyalist"
		then
			return true
		end
	end
	if from:getRole() == "rebel" and to:getRole() == "rebel" then return true end
	if from:getRole() == "renegade"
	then
		if sgs.turncount <= 1 and to:getRole() == "loyalist" and from:aliveCount() > 7
			or to:getRole() == "lord" and from:aliveCount() > 2
		then
			return true
		end
	end
	return false
end

sgs.ai_ajustdamage_to = {}
sgs.ai_ajustdamage_from = {}

function SmartAI:ajustDamage(from, to, dmg, card, nature)
	from = from or self.room:getCurrent() or self.player
	to = to or self.player
	dmg = dmg or 1
	if hasJueqingEffect(from, to) then return -dmg end
	if self:cantDamageMore(from, to) then return 1 end
	if getSpecialMark("&tiansuan1", to) > 0 then return 0 end
	nature = card and sgs.card_damage_nature[card:getClassName()] or nature or "N"
	local na = {
		[sgs.DamageStruct_Fire] = "F",
		[sgs.DamageStruct_Thunder] = "T",
		[sgs.DamageStruct_Ice] = "I",
		[sgs.DamageStruct_Poison] = "P"
	}
	nature = na[nature] or nature
	if nature == "F" or hasWulingEffect("@fire")
	then
		nature = "F"
		if hasWulingEffect("@wind") then dmg = dmg + 1 end
		if hasWulingEffect("@earth") and not to:hasSkill("ranshang") then return 1 end
	end
	if to:getMark("&shouli_debuff-Clear") > 0
	then
		nature = "T"
		dmg = dmg + to:getMark("&shouli_debuff-Clear")
	end
	self.to = to
	self.from = from
	self.card = card
	self.nature = nature
	for ad, s in sgs.list(aiConnect(from)) do
		ad = sgs.ai_ajustdamage_from[s]
		if type(ad) == "function"
		then
			ad = ad(self, from, to, card, nature)
			if type(ad) == "number" then dmg = dmg + ad end
		end
	end
	if nature == "T"
	then
		if hasWulingEffect("@earth") then return 1 end
		if hasWulingEffect("@thunder") then dmg = dmg + 1 end
	end
	if canJiaozi(from) then dmg = dmg + 1 end
	if canJiaozi(to) then dmg = dmg + 1 end
	if card
	then
		if card:isKindOf("Duel")
		then
			if from:hasFlag("luoyi") then dmg = dmg + 1 end
			if from:hasFlag("neoluoyi") then dmg = dmg + 1 end
		elseif card:isKindOf("Slash")
		then
			if card:hasFlag("drank") then
				dmg = dmg + 1
			else
				dmg = dmg + from:getMark("drank")
			end
			if from:hasFlag("nosluoyi") then dmg = dmg + 1 end
			if from:hasFlag("neoluoyi") then dmg = dmg + 1 end
			dmg = dmg + from:getMark("&olpaoxiao_missed-Clear") + to:getMark("&yise")
			if card:hasFlag("yj_nvzhuang_debuff") then dmg = dmg + 1 end
			guanyu = self.room:findPlayerBySkillName("zhongyi")
			if guanyu and guanyu:getPile("loyal"):length() > 0 and self:isFriend(guanyu, from) then dmg = dmg + 1 end
		elseif card:isKindOf("AOE") and card:hasFlag("hanyong") then
			dmg = dmg + 1
		end
		if card:hasFlag("yb_canqu1_add_damage") then dmg = dmg + 1 end
		if card:hasFlag("cuijinAddDamage_1") then dmg = dmg + 1 end
		if card:hasFlag("cuijinAddDamage_2") then dmg = dmg + 2 end
	end
	dmg = dmg + getSpecialMark("&tiansuan4", to) + getSpecialMark("&tiansuan5", to)
	for ad, s in sgs.list(aiConnect(to)) do
		ad = sgs.ai_ajustdamage_to[s]
		if type(ad) == "function"
		then
			ad = ad(self, from, to, card, nature)
			if type(ad) == "number" then dmg = dmg + ad end
		end
	end
	return dmg < -10 and 0 or dmg
end

function SmartAI:hasHeavyDamage(from, card, to, nature)
	return self:ajustDamage(from, to, 1, card, nature) > 1
end

function hasYinshiEffect(to, hasArmor)
	if hasArmor then return to:hasSkill("yinshi") and to:getMark("&dragon_signet") + to:getMark("&phoenix_signet") < 1 end
	return to:hasSkill("yinshi") and to:getMark("&dragon_signet") + to:getMark("&phoenix_signet") < 1 and
		not to:getArmor()
end

function hasJueqingEffect(from, to, nature)
	if from and from:hasSkills("jueqing|gangzhi") then return true end
	if from and from:hasSkill("tenyearjueqing") and from:getMark("tenyearjueqing") > 0 then return true end
	if to and to:hasSkill("gangzhi") then return true end

	--add
	nature = nature or sgs.DamageStruct_Normal
	if from and from:hasSkills("meizlwuqing") and from:isWounded() and nature == sgs.DamageStruct_Normal then
		return true
	end

	return false
end

function hasZhaxiangEffect(to)
	if to:hasSkill("zhaxiang") then return true end
end

function SmartAI:hasGuanxingEffect(owner)
	owner = owner or self.player
	if owner:hasSkills("guanxing|tenyearguanxing") and owner:aliveCount() > 3
		or owner:hasSkill("zhiming") and owner:getCardCount() > 2
	then
		return true
	end
end

function SmartAI:throwEquipArea(choices, player)
	player = player or self.player
	local items = choices:split("+")
	if self:isFriend(player)
	then --友方有sgs.lose_equip_skill待补充
		if self:needToThrowArmor(player) and player:hasEquipArea(1) and table.contains(items, "1")
		then
			return "1"
		elseif player:hasEquipArea(4) and not player:getTreasure() and table.contains(items, "4")
		then
			return "4"
		elseif player:hasEquipArea(1) and not player:getArmor() and table.contains(items, "1")
		then
			return "1"
		elseif player:hasEquipArea(0) and not player:getWeapon() and table.contains(items, "0")
		then
			return "0"
		elseif player:hasEquipArea(3) and not player:getOffensiveHorse() and table.contains(items, "3")
		then
			return "3"
		elseif player:hasEquipArea(2) and not player:getDefensiveHorse() and table.contains(items, "2")
		then
			return "2"
		elseif player:hasEquipArea(4) and not self:keepWoodenOx(player) and table.contains(items, "4")
		then
			return "4"
		elseif player:hasEquipArea(1) and table.contains(items, "1")
		then
			return "1"
		elseif player:hasEquipArea(0) and table.contains(items, "0")
		then
			return "0"
		elseif player:hasEquipArea(3) and table.contains(items, "3")
		then
			return "3"
		elseif player:hasEquipArea(2) and table.contains(items, "2")
		then
			return "2"
		else
			return items[1]
		end
	else
		--待补充
	end
	return items[#items]
end

function SmartAI:moveField(player, flag, froms, tos)
	froms = froms or self.room:getAlivePlayers()
	tos = tos or self.room:getAlivePlayers()
	player = player or self.player
	flag = flag or "ej"
	from_friends, from_enemies, to_friends, to_enemies = {}, {}, {}, {}
	for _, p in sgs.list(froms) do
		if self:isFriend(p) then
			table.insert(from_friends, p)
		else
			table.insert(from_enemies, p)
		end
	end
	for _, p in sgs.list(tos) do
		if self:isFriend(p) then
			table.insert(to_friends, p)
		else
			table.insert(to_enemies, p)
		end
	end
	from_friends_noself = {}
	for _, p in sgs.list(from_friends) do
		if p:objectName() == player:objectName() then continue end
		table.insert(from_friends_noself, p)
	end
	self:sort(from_enemies, "defense")
	self:sort(from_friends, "defense")
	self:sort(from_friends_noself, "defense")
	if flag:match("j") then
		for _, friend in sgs.list(from_friends) do
			if friend:getJudgingArea():length() > 0
				and not friend:containsTrick("YanxiaoCard")
			then
				to, c = self:card_for_qiaobian(friend, flag, to_friends, to_enemies)
				if to and c then return friend, c, to end
			end
		end
		for _, enemy in sgs.list(from_enemies) do
			if enemy:getJudgingArea():length() > 0
				and enemy:containsTrick("YanxiaoCard")
			then
				to, c = self:card_for_qiaobian(enemy, flag, to_friends, to_enemies)
				if to and c then return enemy, c, to end
			end
		end
	end
	if flag:match("e") then
		for _, friend in sgs.list(from_friends_noself) do
			if friend:hasEquip()
				and self:hasSkills(sgs.lose_equip_skill, friend)
			then
				to, c = self:card_for_qiaobian(friend, flag, to_friends, to_enemies)
				if to and c then return friend, c, to end
			end
		end
		targets = {}
		for _, enemy in sgs.list(self.enemies) do
			if not self:hasSkills(sgs.lose_equip_skill, enemy)
				and self:card_for_qiaobian(enemy, flag, to_friends, to_enemies)
			then
				table.insert(targets, enemy)
			end
		end
		if #targets > 0
		then
			self:sort(targets, "defense")
			to, c = self:card_for_qiaobian(targets[1], flag, to_friends, to_enemies)
			if to and c then return targets[1], c, to end
		end
	end
end

function SmartAI:dontHurt(to, from) --针对队友
	if hasJueqingEffect(from, to)
		or hasOrangeEffect(to)
	then
		return true
	end
	if to:hasSkills("sizhan|lixun")
	then
		return true
	end
	--add
	if to:hasSkill("meispliwu") and to:getMark("@meispliwuprevent") > 0
	then
		return true
	end

	return false
end

function SmartAI:justDamage(to, from, isSlash, lock) --针对敌人
	if from:hasFlag("NosJiefanUsed") then return true end
	if self:isFriend(to, from) then return false end
	if self:dontHurt(to, from) then return true end
	if from:hasSkill("nosdanshou") then return true end
	if from:hasSkill("duorui") and #from:property("duorui_skills"):toStringList() < 1 then return true end
	if from:hasSkill("olduorui") then return true end
	if to:getHp() <= 2 and to:hasSkill("chanyuan") then return true end
	if isSlash and from:hasSkill("chuanxin") then
		if to:getEquips():length() > 0 and not hasZhaxiangEffect(to)
			and not self:doNotDiscard(to, "e") then
			return true
		end
		if to:getMark("@chuanxin") < 1 and not to:hasSkills(sgs.bad_skills)
		then
			n = 0
			for _, skill in sgs.list(to:getVisibleSkillList()) do
				n = n + 1
				if n > 1 then return true end
			end
		end
	end
	if from:hasSkills("zhiman|tenyearzhiman") and not self:doNotDiscard(to, "e") then return true end
	if isSlash then
		if not lock and from:hasSkill("tieji") then return true end
		if from:hasSkill("nosqianxi") and from:distanceTo(to) == 1
		then
			return true
		end
		if from:hasWeapon("ice_sword") and not self:doNotDiscard(to, "he")
		then
			return true
		end
	end
	return false
end

function SmartAI:goodJudge(p, reason, c)
	if not reason then return false end
	if p:hasSkills("qianxi|olqianxi") and not self:isFriend(p) then return false end
	c = CardFilter(c, p)
	if reason == "lightning" and not p:hasSkills("wuyan")
	then
		if self:isFriend(p) then
			return not (c:getSuit() == sgs.Card_Spade and c:getNumber() >= 2 and c:getNumber() <= 9)
		elseif self:isEnemy(p) then
			return c:getSuit() == sgs.Card_Spade and c:getNumber() >= 2 and c:getNumber() <= 9
		end
	elseif reason == "indulgence"
	then
		if self:isFriend(p) then
			return c:getSuit() == sgs.Card_Heart
		elseif self:isEnemy(p) then
			return c:getSuit() ~= sgs.Card_Heart
		end
	elseif reason == "supply_shortage"
	then
		if self:isFriend(p) then
			return c:getSuit() == sgs.Card_Club
		elseif self:isEnemy(p) then
			return c:getSuit() ~= sgs.Card_Club
		end
	elseif reason == "black"
	then
		if self:isFriend(p) then
			return c:isBlack()
		elseif self:isEnemy(p) then
			return c:isRed()
		end
	end
	return false
end

function SmartAI:canUse(card, players, from)
	players = players or self.room:getAlivePlayers()
	from = from or self.player
	if type(players) == "table"
	then
		new_players = sgs.SPlayerList()
		for _, p in sgs.list(players) do
			new_players:append(p)
		end
		players = new_players
	end
	if players:isEmpty() then return false end
	if from:canUse(c, players) then return true end
	return false
end

function SmartAI:willUse(player, card, ignoreDistance, disWeapon, play)
	from = player or self.player
	if play then
		if self:aiUseCard(card).card
		then
			return true
		end
	else
		if card:isKindOf("Slash")
		then
			for _, to in sgs.list(self.enemies) do
				far = false
				if from:hasSkill("tenyearliegong") or from:hasFlag("TianyiSuccess")
					or from:hasFlag("JiangchiInvoke") or from:hasFlag("InfinityAttackRange")
					or from:getMark("InfinityAttackRange") > 0 then
					far = true
				end
				if disWeapon then
					if from:distanceTo(to) > 1 and not far
						or to:hasArmorEffect("renwang_shield") and card:isBlack()
						or to:hasArmorEffect("vine") and not card:isKindOf("NatureSlash")
					then
						continue
					end
				end
				if (from:canSlash(to, card, not ignoreDistance) or far)
					and self:slashIsEffective(card, to, from) and self:isGoodTarget(to, self.enemies, card)
					and not self:slashProhibit(card, to, from)
				then
					return true
				end
			end
		elseif card:isKindOf("SupplyShortage")
		then
			if from:hasSkill("jizhi") then ignoreDistance = true end
			for _, to in sgs.list(self.enemies) do
				if not ignoreDistance and from:distanceTo(to) > 1
					or to:containsTrick("supply_shortage")
					or to:containsTrick("YanxiaoCard")
				then
					continue
				end
				if self.room:isProhibited(from, to, card)
				then else
					return true
				end
			end
		elseif card:isKindOf("Snatch")
		then
			if from:hasSkill("jizhi") then ignoreDistance = true end
			for _, to in sgs.list(self.enemies) do
				if not ignoreDistance and from:distanceTo(to) > 1 then continue end
				if self:hasTrickEffective(card, to, from) and not self:doNotDiscard(to) then return true end
			end
		end
		if card:getTypeId() > 1 and from:objectName() == self.player:objectName()
			and self:aiUseCard(card).card then
			return true
		end
	end
	return false
end

function SmartAI:GetAskForPeachActionOrderSeat(player)
	local another_seat, nextAlive = {}, self.room:getCurrent()
	player = player or self.player
	for i = 1, self.room:alivePlayerCount() do
		table.insert(another_seat, nextAlive)
		nextAlive = nextAlive:getNextAlive()
	end
	for i = 1, #another_seat do
		if another_seat[i]:objectName() == player:objectName()
		then
			return i
		end
	end
	return -1
end

function ZishuEffect(player)
	local n = 0
	if player:hasSkill("zhanji") and player:getPhase() == sgs.Player_Play then n = n + 1 end
	if player:hasSkill("zishu") and player:getPhase() ~= sgs.Player_NotActive then n = n + 1 end
	return n
end

function canAiSkills(name)
	if type(name) == "string"
	then
		for fname, fs in pairs(sgs.ai_fill_skill) do
			if fname == name then return { name = fname, ai_fill_skill = fs } end
		end
	else
		local cas, bp = {}, sgs.Sanguosha:getBanPackages()
		for _, g in sgs.list(sgs.Sanguosha:getAllGenerals()) do
			if table.contains(bp, g:getPackage()) or g:isHidden()
				or g:isTotallyHidden() then
				continue
			end
			for fs, s in sgs.list(g:getSkillList()) do
				fs = { name = s:objectName() }
				fs.ai_fill_skill = sgs.ai_fill_skill[s:objectName()]
				if fs.ai_fill_skill then table.insert(cas, fs) end
			end
		end
		return cas
	end
end

sgs.ai_can_damagehp = {}

function SmartAI:canDamageHp(from, card, to)
	to = to or self.player
	self.from = from
	self.card = card
	self.to = to
	for d, c in ipairs(aiConnect(to)) do
		d = sgs.ai_can_damagehp[c]
		if type(d) == "function"
		then
			d = d(self, from, card, to)
			if d then
				return true
			elseif d ~= nil then
				return
			end
		end
	end
	if to:inYinniState()
		and to:objectName() == self.player:objectName()
	then
		local general = self.player:property("yinni_general"):toString()
		general = general ~= "" and sgs.Sanguosha:getGeneral(general)
		if general
		then
			for d, s in sgs.list(general:getSkillList()) do
				d = sgs.ai_can_damagehp[s:objectName()]
				if type(d) == "function"
				then
					d = d(self, from, card, to)
					if d then
						return true
					elseif d ~= nil then
						return
					end
				end
			end
		end
		general = self.player:property("yinni_general2"):toString()
		general = general ~= "" and sgs.Sanguosha:getGeneral(general)
		if general
		then
			for d, s in sgs.list(general:getSkillList()) do
				d = sgs.ai_can_damagehp[s:objectName()]
				if type(d) == "function"
				then
					d = d(self, from, card, to)
					if d then
						return true
					elseif d ~= nil then
						return
					end
				end
			end
		end
	end
	for _, m in sgs.list(to:getMarkNames()) do
		if m:match("canDamage")
			and to:getMark(m) > 0
		then
			if m:match("canDamage_")
			then
				if from and m:match(from:objectName())
				then else
					continue
				end
			end
			return self:canLoseHp(from, card, to)
		end
	end
end

function SmartAI:canLoseHp(from, card, to)
	from = from or self.room:getCurrent() or self.player
	to = to or self.player
	if hasJueqingEffect(from, to) then return end
	if from:hasSkill("nosqianxi")
		and not self:isFriend(to, from)
		and card and card:isKindOf("Slash")
		and from:distanceTo(to) == 1
	then
		return
	end
	if from:hasSkill("kuanggu")
		and not self:isFriend(to, from)
		and from:distanceTo(to) == 1
	then
		return
	end
	if from:hasSkill("jinyimie")
		and not self:isFriend(to, from)
		and from:getMark("jinyimie-Clear") < 1
	then
		return
	end
	if from:hasSkill("jieyuan")
		and not self:isFriend(to, from)
		and from:getHp() <= to:getHp()
		and from:getHandcardNum() > 0
	then
		return
	end
	if from:hasSkill("xionghuo")
		and to:getMark("@brutal") > 0
		and self:isWeak(to)
	then
		return
	end
	if self:ajustDamage(from, to, 1, card) >= to:getHp()
	then
		return
	end
	if from:hasSkill("zhenyi")
		and from:getMark("@flyuqing") > 0
		and not self:isFriend(to, from)
		and self:isWeak(to)
	then
		return
	end
	if card and card:isKindOf("Slash")
		and from:getMark("&kannan") >= to:getHp()
	then
		return
	end
	if from:hasSkill("jiedao")
		and from:getMark("jiedao-Clear") > 0
		and not self:isFriend(to, from)
		and from:getLostHp() >= to:getHp()
	then
		return
	end
	if from:hasSkill("shanzhuan")
		and not self:isFriend(to, from)
		and to:getJudgingArea():isEmpty()
	then
		return
	end
	if from:hasSkill("jiaozi")
		and from:getHandcardNum() > to:getHandcardNum()
	then
		return
	end
	if from:hasSkill("zhuixi")
		and (from:faceUp() and not to:faceUp() or to:faceUp() and not from:faceUp())
		and self:isWeak(to)
	then
		return
	end
	if from:hasSkill("pojun")
		and not self:isFriend(to, from)
		and self:isWeak(to)
	then
		return
	end
	if from:hasSkill("duorui")
		and not self:isFriend(to, from)
		and #from:property("duorui_skills"):toStringList() < 1
	then
		return
	end
	if from:hasSkill("nosdanshou")
		and not self:isFriend(to, from)
	--	and self:isWeak(to)
	then
		return
	end
	if from:hasSkill("chuanxin")
		and not self:isFriend(to, from)
	then
		return
	end
	if from:hasSkill("ov_equan")
		and from:getPhase() ~= sgs.Player_NotActive
	then
		return
	end
	return true
end

sgs.ai_poison_card.shit = function(self, c, player)
	return player:getPhase() ~= sgs.Player_NotActive
end

function SmartAI:poisonCards(flags, owner)
	owner = owner or self.player
	self.owner = owner
	local cards = {}
	flags = flags or "h"
	if type(flags) == "string" then flags = owner:getCards(flags) end
	for ap, c in sgs.list(flags) do
		if type(c) == "number" then c = sgs.Sanguosha:getCard(c) end
		ap = sgs.ai_poison_card[c:objectName()]
		self.card = c
		if type(ap) == "function" and ap(self, c, owner) or ap == true then
			table.insert(cards, c)
		elseif owner:hasEquip(c) and self:evaluateArmor(c, owner) < -5 then
			table.insert(cards, c)
		elseif owner:getJudgingArea():contains(c) and not owner:containsTrick("YanxiaoCard") then
			table.insert(cards, c)
		else --[[
			ap = sgs.ai_poison_card[c:getClassName()]
			if type(ap)=="function" and ap(self,c,owner)
			or ap==true then table.insert(cards,c) end--]]
		end
	end
	return cards
end

function addAiSkills(sk)
	ai_sk = {}
	ai_sk.name = sk
	table.insert(sgs.ai_skills, ai_sk)
	return ai_sk
end

function SmartAI:useCardByClassName(card, use)
	usefunc = self["useCard" .. card:getClassName()]
	if usefunc then return usefunc(self, card, use) end
end

function SmartAI:targetRevises(use)
	if use.to and cti ~= 3
	then
		if use.to:isEmpty()
		then
			if use.card:isKindOf("AOE")
			then
				for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
					if self.player:isProhibited(p, use.card)
					then else
						use.to:append(p)
					end
				end
			elseif use.card:isKindOf("GlobalEffect")
			then
				for _, p in sgs.qlist(self.room:getAlivePlayers()) do
					if self.player:isProhibited(p, use.card)
					then else
						use.to:append(p)
					end
				end
			elseif use.card:targetFixed()
			then
				use.to:append(self.player)
			end
		end
		utr = {}
		uc = use.card:toString()
		is_collateral = use.card:isKindOf("Collateral") or use.card:isKindOf("JlLianhuansr")
		for tx, to in sgs.qlist(use.to) do
			if is_collateral
			then
				if math.mod(tx, 2) == 1 then continue end
				tx = use.to:length() > 2
			else
				tx = use.to:length() > 1
			end
			if tx and use.card:isKindOf("TrickCard") and self:isEnemy(to)
				and self:hasHuangenEffect(to) and math.random() < 0.95 then
				table.insert(utr, to)
				continue
			end
			tx = use.card:hasFlag("Qinggang") or use.card:hasFlag("SlashIgnoreArmor") or not to:hasArmorEffect(nil)
			for tr, ac in ipairs(aiConnect(to)) do
				if tx and sgs.armorName[ac] then continue end
				tr = sgs.ai_target_revises[ac]
				if type(tr) == "function" and tr(to, use.card, self, use)
					and math.random() < 0.95 then
					table.insert(utr, to)
					break
				end
			end
			if not use.card then return end
		end
		if #utr > 0 and use.card:toString() == uc
		then
			for _, p in ipairs(utr) do
				p:setProperty("aiNoTo", ToData(true))
			end
			use.card = nil
			use.to = sgs.SPlayerList()
			uc = sgs.Card_Parse(uc)
			is_collateral = self["useCard" .. uc:getClassName()]
			if is_collateral then is_collateral(self, uc, use) end
			for _, p in ipairs(utr) do
				p:setProperty("aiNoTo", ToData(false))
			end
		end
	end
end

function SmartAI:aiUseCard(card, use)
	if not card then
		global_room:writeToConsole(debug.traceback())
		return
	end
	use = use or { isDummy = true, to = sgs.SPlayerList() }
	cti = card:getTypeId()
	if cti < 1
	then
		self:useSkillCard(card, use)
		return use
	end
	uc_acs = aiConnect(self.player)
	for invoke, ac in ipairs(uc_acs) do
		invoke = sgs.ai_use_revises[ac]
		if type(invoke) == "function"
		then
			invoke = invoke(self, card, use)
			if type(invoke) == "boolean"
			then
				if invoke
				then
					if use.card then break end
					self:useCardByClassName(card, use)
				else
					return use
				end
			end
		end
	end
	for _, p in sgs.qlist(self.room:getAlivePlayers()) do
		for invoke, ac in sgs.list(aiConnect(p)) do
			invoke = sgs.ai_useto_revises[ac]
			if type(invoke) == "function"
			then
				invoke = invoke(self, card, use, p)
				if type(invoke) == "boolean"
				then
					if invoke
					then
						if use.card then break end
						self:useCardByClassName(card, use)
					else
						return use
					end
				end
			end
		end
		for invoke, j in sgs.qlist(p:getJudgingArea()) do
			invoke = sgs.ai_useto_revises[j:objectName()]
			if type(invoke) == "function"
			then
				invoke = invoke(self, card, use, p)
				if type(invoke) == "boolean"
				then
					if invoke
					then
						if use.card then break end
						self:useCardByClassName(card, use)
					else
						return use
					end
				end
			end
		end
	end
	if not use.card
	then
		utn = self["use" .. sgs.ai_type_name[cti + 1]]
		if utn then utn(self, card, use) end
	end
	if use.card
	then
		self:targetRevises(use)
		if use.card and not use.isDummy
		then
			for tr, ac in ipairs(uc_acs) do
				tr = sgs.ai_used_revises[ac]
				if type(tr) == "function"
					and math.random() < 0.95
				then
					tr(self, use)
				end
			end
		end
	end
	return use
end

function SmartAI:getGuhuoCard(class_name, islist)
	local cname = sgs.patterns[class_name]
	if not cname then return islist and {} end
	local ghs = {}
	for gc, s in ipairs(sgs.getPlayerSkillList(self.player)) do
		s = s:objectName()
		gc = sgs.ai_guhuo_card[s]
		if type(gc) == "function"
		then
			s = sgs.Sanguosha:getViewAsSkill(s)
			if s and s:isEnabledAtResponse(self.player, cname)
			then
				gc = gc(self, cname, class_name)
				if type(gc) == "string" or type(gc) == "number"
				then
					if islist then
						table.insert(ghs, gc)
					else
						return gc
					end
				elseif type(gc) == "table"
				then
					for _, st in sgs.list(gc) do
						if islist then
							table.insert(ghs, st)
						else
							return st
						end
					end
				end
			end
		end
	end
	return islist and ghs or ghs[1]
end

function SmartAI:useBasicCard(card, use)
	self:useCardByClassName(card, use)
end

function SmartAI:useEquipCard(card, use)
	ea = self:evaluateArmor(card)
	if self.player:getHandcardNum() <= 2 and ea > -5 and self:needKongcheng()
		or ea > -5 and #self.enemies > 1 and self.player:hasSkills(sgs.lose_equip_skill)
	then
		use.card = card
		return
	end
	same = self:getSameEquip(card)
	if same and self:hasSkills("guzheng", self.friends) and self:evaluateArmor(same) > -5
		or self:useCardByClassName(card, use) then
		return
	end

	gof = self:getOverflow()
	if card:isKindOf("Weapon")
	then
		canUseSlash = self:slashIsAvailable() and self:getCard("Slash")
		if gof <= (canUseSlash and 1 or 0)
		then
			if canUseSlash
				or self.player:hasWeapon("Crossbow")
				or self:needKongcheng()
			then else
				return
			end
		end
		if same and gof > -1 and self:evaluateWeapon(card) > self:evaluateWeapon(same)
		then
			use.card = card
			return
		end
	elseif card:isKindOf("Armor")
	then
		lion = self:getCard("SilverLion")
		if lion and self.player:isWounded()
			and not (self.player:hasArmorEffect("silver_lion") or card:isKindOf("SilverLion")
				or self.player:hasSkills("bazhen|yizhong") and not same)
		then
			use.card = lion
			return
		end
	elseif card:isKindOf("OffensiveHorse")
	then
		if same and not (self:hasSkills(sgs.lose_equip_skill) or self:getCard("Slash") and self:slashIsAvailable() or self:getCard("Snatch"))
		then
			return
		end
	elseif card:isKindOf("Treasure")
	then
		for _, friend in sgs.list(self.friends_noself) do
			if friend:getPile("wooden_ox"):length() > 1
			then
				return
			end
		end
	end
	if ea > -5 and gof > 1 and self:hasSkills("guzheng", self.enemies)
	then
		use.card = card
		return
	elseif gof < 1 then
		return
	end

	--add
	if ea > -5 and gof > 1 and self:hasSkills("meizlshuyi", self.enemies)
	then
		use.card = card
		return
	elseif gof < 1 then
		return
	end

	same = same and self:evaluateArmor(same)
	if type(same) ~= "number" then same = card:isKindOf("Armor") and self:evaluateArmor() or -1 end
	if ea > same and self.lua_ai:useCard(card) then use.card = card end
end

function SmartAI:useTrickCard(card, use)
	if self:useCardByClassName(card, use)
		or use.card then
		return
	end
	if card:isKindOf("AOE")
	then
		if sgs.getMode:find("p")
			and sgs.getMode >= "04p"
		then
			if card:isKindOf("ArcheryAttack") and self.player:getMark("AI_fangjian-Clear") > 0 and self:getOverflow() < 1
				or sgs.turncount < 2 and (self.role == "loyalist" and card:isKindOf("ArcheryAttack") or self.role == "rebel" and card:isKindOf("SavageAssault"))
			then
				return
			end
		end
		if self:getAoeValue(card) > 0 then use.card = card end
	end
end

do
	sgs.ai_use_revises.qinggang_sword = function(self, card, use)
		if card:isKindOf("Slash")
		then
			card:setFlags("Qinggang")
		end
	end

	sgs.ai_nullification.FireAttack = function(self, trick, from, to, positive, null_num)
		if to:isKongcheng() or from:isKongcheng() or self.player == from and self.player:getHandcardNum() == 1
		then
			return false
		elseif positive
		then
			if self:isEnemy(from)
				and self:isFriend(to)
			then
				if from:getHandcardNum() > 2
					or to:isChained() and not self:isGoodChainTarget(to, trick, from)
				then
					return true
				end
			end
		else
		end
	end

	sgs.ai_nullification.ExNihilo = function(self, trick, from, to, positive, null_num)
		if positive
		then
			if self:isEnemy(from) and (self:isWeak(to) or to:hasSkills(sgs.cardneed_skill) or to:hasSkill("manjuan"))
				and not (self.role == "rebel" and not self:hasExplicitRebel() and sgs.turncount < 1 and self.room:getCurrent():getNextAlive():objectName() ~= self.player:objectName())
			then
				return true
			end --敌方在虚弱、需牌技、漫卷中使用无中生有->命中
		else

		end
	end

	sgs.ai_nullification.IronChain = function(self, trick, from, to, positive, null_num)
		if positive
		then
			if self:isEnemy(from) and self:isFriend(to)
				and not to:isChained() and self:hasHeavyDamage(from, nil, to, "F")
			then
				return true
			end --铁索连环的目标有加伤->命中
		else

		end
	end

	sgs.ai_nullification.Duel = function(self, trick, from, to, positive, null_num)
		if positive
		then
			if to == self.player
			then
				if self:hasSkills(sgs.masochism_skill)
					and (self.player:getHp() > 1 or self:getCardsNum("Analeptic,Peach") > 0)
				then elseif self:getCardsNum("Slash") < 1 then
					return true
				end
			end
			if to:getHp() < 2 and sgs.ai_role[to:objectName()] == "rebel"
				and sgs.ai_role[from:objectName()] == "rebel"
			then
				return
			end
			if self:isFriend(to)
			then
				if self:isEnemy(from) and self:isWeak(to)
					or (self:isWeak(to) or null_num > 1 or self:getOverflow() > 0 or not self:isWeak())
				then
					return true
				end
			end
		else
			if self:isEnemy(to)
				and (self:isWeak(to) or null_num > 1 or self:getOverflow() > 0 or not self:isWeak())
			then
				return true
			end
		end
	end

	sgs.ai_nullification.Indulgence = function(self, trick, from, to, positive, null_num)
		if positive
		then
			if self:isFriend(to)
				and not (self:hasGuanxingEffect(to) or to:isSkipped(sgs.Player_Play))
			then --无观星友方判定区有乐不思蜀->视“突袭”、“巧变”情形而定
				if to:getHp() - to:getHandcardNum() >= 2
					or to:hasSkill("tuxi") and to:getHp() > 2
					or null_num < 2 and self:getOverflow(to) < -1
					or to:hasSkill("qiaobian") and not to:isKongcheng()
					and (to:containsTrick("supply_shortage") or self:willSkipDrawPhase(to))
				then else
					return true
				end
			end
		else

		end
	end

	sgs.ai_nullification.SupplyShortage = function(self, trick, from, to, positive, null_num)
		if positive
		then
			if self:isFriend(to)
				and not (self:hasGuanxingEffect(to) or to:isSkipped(sgs.Player_Draw))
			then --无观星友方判定区有兵粮寸断->视“鬼道”、“天妒”、“溃围”、“巧变”情形而定
				if self:hasSkills("guidao|tiandu", to)
					or to:getMark("@kuiwei") < 1
					or null_num <= 1 and self:getOverflow(to) > 1
					or to:hasSkill("qiaobian") and not to:isKongcheng()
					and (to:containsTrick("indulgence") or self:willSkipPlayPhase(to))
				then else
					return true
				end
			end
		else

		end
	end

	sgs.ai_nullification.GodSalvation = function(self, trick, from, to, positive, null_num)
		if positive
		then
			if self:isEnemy(to) and self:isWeak(to)
				and to:getLostHp() > 0
			then
				return true
			end
		else

		end
	end

	sgs.ai_nullification.AmazingGrace = function(self, trick, from, to, positive, null_num)
		if positive
		then
			if self:isEnemy(to)
			then
				for i = 1, null_num do
					local NP = to:getNextAlive(i)
					if self:isFriend(NP)
					then
						i = { p = 0, e = 0, s = 0, a = 0, c = 0, i = 0 }
						for _, c in sgs.list(self.room:getTag("AmazingGrace"):toIntList()) do
							c = sgs.Sanguosha:getCard(c)
							if isCard("Peach", c, NP) then i.p = i.p + 1 end
							if isCard("ExNihilo", c, NP) then i.e = i.e + 1 end
							if isCard("Snatch", c, NP) then i.s = i.s + 1 end
							if isCard("Analeptic", c, NP) then i.a = i.a + 1 end
							if isCard("Crossbow", c, NP) then i.c = i.c + 1 end
							if isCard("Indulgence", c, NP) then i.i = i.i + 1 end
							if c:isDamageCard()
							then
								for _, friend in sgs.list(self.friends) do
									if to:canUse(c, friend) and to:getHandcardNum() > 2
										and self:ajustDamage(to, friend, 1, c) > 1
									then
										return true
									end
								end
							end
						end
						if i.p == 1 and to:getHp() < getBestHp(to)
							or i.p > 0 and (self:isWeak(to) or NP:getHp() < getBestHp(NP) and self:getOverflow(NP) < 1)
						then
							return true
						end
						if i.p < 1
							and not self:willSkipPlayPhase(NP)
						then
							if i.p > 0
							then
								if NP:hasSkills("nosjizhi|jizhi|nosrende|zhiheng")
									or NP:hasSkill("rende") and not NP:hasUsed("RendeCard")
									or NP:hasSkill("jilve") and NP:getMark("&bear") > 0
								then
									return true
								end
							else
								for _, enemy in sgs.list(self.enemies) do
									if i.i > 0 and not self:willSkipPlayPhase(enemy, true)
										or i.s > 0 and to:distanceTo(enemy) == 1 and (self:willSkipPlayPhase(enemy, true) or self:willSkipDrawPhase(enemy, true))
										or i.a > 0 and (enemy:hasWeapon("axe") or getCardsNum("Axe", enemy, self.player) > 0)
									then
										return true
									elseif i.c > 0
										and getCardsNum("Slash", enemy, self.player) > 2
									then
										for _, friend in sgs.list(self.friends) do
											if enemy:distanceTo(friend) == 1
												and self:slashIsEffective(dummyCard(), friend, enemy)
											then
												return true
											end
										end
									end
								end
							end
						end
					end
				end
			end
		else

		end
	end

	sgs.ai_can_damagehp.zili = function(self, from, card, to)
		return not (self:isWeak(to) or to:hasSkill("paiyi"))
			and self:ajustDamage(from, to, 1, card) > 0
	end

	sgs.ai_can_damagehp.wumou = function(self, from, card, to)
		return to:getMark("&wrath") < 7 and not self:isWeak(to)
			and self:ajustDamage(from, to, 1, card) > 0
	end

	sgs.ai_can_damagehp.longhun = function(self, from, card, to)
		return to:getHp() > 1 and self:ajustDamage(from, to, 1, card) > 0
	end

	sgs.ai_can_damagehp.tianxiang = function(self, from, card, to)
		local d = { damage = 1 }
		d.nature = card and sgs.card_damage_nature[card:getClassName()] or sgs, DamageStruct_Normal
		return sgs.ai_skill_use["@@tianxiang"](self, d, sgs.Card_MethodDiscard) ~= "."
	end

	sgs.ai_guhuo_card.guhuo = function(self, cname, class_name)
		local handcards = self.player:getCards("h")
		handcards = self:sortByKeepValue(handcards, nil, "l") -- 按保留值排序
		if #handcards > 0
		then
			local hc, fake, question = {}, {}, #self.enemies
			local all = sgs.getMode == "_mini_48"
			for _, enemy in sgs.list(self.enemies) do
				if enemy:hasSkill("chanyuan")
					or enemy:hasSkill("hunzi") and enemy:getMark("hunzi") < 1
				then
					question = question - 1
				end
				if question < 1 then all = true end
			end
			for _, h in sgs.list(handcards) do
				if h:isKindOf(class_name) then
					table.insert(hc, h)
				elseif self:getCardsNum(class_name) > 0
				then
					table.insert(fake, h)
				end
			end
			if all then hc = handcards end
			question = question < 1 and 100 or #self.enemies / question
			if #hc > 1 or #hc > 0 and all
			then
				local index = 1
				if not all and (class_name == "Peach" or class_name == "Analeptic" or class_name == "Jink")
				then
					index = #hc
				end
				return "@GuhuoCard=" .. hc[index]:getEffectiveId() .. ":" .. cname
			end
			if #fake > 0 and math.random(1, 5) <= question
			then
				return "@GuhuoCard=" .. fake[1]:getEffectiveId() .. ":" .. cname
			end
			if #hc > 0 then return "@GuhuoCard=" .. hc[1]:getEffectiveId() .. ":" .. cname end
			if self:isWeak()
			then
				if (class_name == "Peach" or class_name == "Analeptic") and self:getCardsNum("Peach,Analeptic") < 1
				then
					return "@GuhuoCard=" .. handcards[1]:getEffectiveId() .. ":" .. cname
				end
				if class_name == "Jink" then return "@GuhuoCard=" .. handcards[1]:getEffectiveId() .. ":" .. cname end
			end
			if class_name == "Jink" and math.random(1, #handcards + 1) < (#handcards + 1) / 2
			then
				return "@GuhuoCard=" .. handcards[1]:getEffectiveId() .. ":" .. cname
			elseif class_name == "Slash" and math.random(1, #handcards + 2) > (#handcards + 1) / 2
			then
				return "@GuhuoCard=" .. handcards[1]:getEffectiveId() .. ":" .. cname
			elseif class_name == "Peach" or class_name == "Analeptic"
			then
				question = self.room:getCurrentDyingPlayer()
				if question and self:isFriend(question) and math.random(1, #handcards + 1) > (#handcards + 1) / 2
				then
					return "@GuhuoCard=" .. handcards[1]:getEffectiveId() .. ":" .. cname
				end
			end
		end
	end

	sgs.ai_guhuo_card.nosguhuo = function(self, cname, class_name)
		local handcards = self.player:getCards("h")
		handcards = self:sortByKeepValue(handcards, nil, "l") -- 按保留值排序
		if #handcards > 0
		then
			local hc, fake, question = {}, {}, #self.enemies
			for _, enemy in sgs.list(self.enemies) do
				if enemy:getHp() < 2 then question = question - 1 end
			end
			for _, h in sgs.list(handcards) do
				if h:isKindOf(class_name) and h:getSuit() == 2
				then
					table.insert(hc, h)
				end
			end
			for _, h in sgs.list(handcards) do
				if h:isKindOf(class_name) and h:getSuit() ~= 2
				then
					table.insert(hc, h)
				end
			end
			if question < 1 then hc = handcards end
			for _, h in sgs.list(handcards) do
				if not h:isKindOf(class_name)
					and self:getCardsNum(class_name) > 0
				then
					table.insert(fake, h)
				end
			end
			if self:isWeak()
			then
				if (class_name == "Peach" or class_name == "Analeptic") and self:getCardsNum("Peach,Analeptic") < 1
				then
					return "@NosGuhuoCard=" .. handcards[1]:getEffectiveId() .. ":" .. cname
				end
				if class_name == "Jink" then return "@NosGuhuoCard=" .. handcards[1]:getEffectiveId() .. ":" .. cname end
			end
			if #fake > 0 and self:isWeak() then return "@NosGuhuoCard=" .. fake[1]:getEffectiveId() .. ":" .. cname end
			if #hc > 0 then return "@NosGuhuoCard=" .. hc[1]:getEffectiveId() .. ":" .. cname end
			if #hc > 1 or #hc > 0 and hc[1]:getSuit() == 2
			then
				local index = 1
				if class_name == "Peach"
					or class_name == "Jink"
					or class_name == "Analeptic"
				then
					index = #hc
				end
				return "@NosGuhuoCard=" .. hc[index]:getEffectiveId() .. ":" .. cname
			end
			question = self.room:getCurrentDyingPlayer()
			if question and self:isFriend(question) and #hc > 0
			then
				return "@NosGuhuoCard=" .. hc[1]:getEffectiveId() .. ":" .. cname
			end
		end
	end

	sgs.ai_guhuo_card.taoluan = function(self, cname, class_name)
		if self:getCardsNum(class_name) < 1 and self.player:getCardCount() > 0
			and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_hc_REASON_RESPONSE_USE
		then
			local he = self.player:getCards("he")
			he = self:sortByKeepValue(he, nil, "l") -- 按保留值排序
			self:sort(self.friends_noself, "card", true)
			if #self.friends_noself > 0 and self.friends_noself[1]:getCardCount() > 1 or self.player:getHp() > 1
			then
				return "@TaoluanCard=" .. he[1]:getEffectiveId() .. ":" .. cname
			end
		end
	end

	sgs.ai_ajustdamage_to.shenjun = function(self, from, to, card, nature)
		if to:getGender() ~= from:getGender() and nature ~= "T"
		then
			return -99
		end
	end

	sgs.ai_ajustdamage_to.fenyong = function(self, from, to, card, nature)
		if to:getMark("@fenyong") > 0
		then
			return -99
		end
	end

	sgs.ai_ajustdamage_to["&dawu"] = function(self, from, to, card, nature)
		if nature ~= "T"
		then
			return -99
		end
	end

	sgs.ai_ajustdamage_to["&ollie"] = function(self, from, to, card, nature)
		--return -99
	end

	sgs.ai_ajustdamage_to.jgyuhuo = function(self, from, to, card, nature)
		if nature == "F" then return -99 end
	end

	sgs.ai_ajustdamage_to.shixin = function(self, from, to, card, nature)
		if nature == "F" then return -99 end
	end

	sgs.ai_ajustdamage_to["&jinxuanmu-Clear"] = function(self, from, to, card, nature)
		return -99
	end

	sgs.ai_ajustdamage_from.tenyearzishou = function(self, from, to, card, nature)
		if from:objectName() ~= to:objectName()
		then
			return -99
		end
	end

	sgs.ai_ajustdamage_from.olzishou = function(self, from, to, card, nature)
		if from:hasFlag("olzishou") and from:objectName() ~= to:objectName()
		then
			return -99
		end
	end

	sgs.ai_ajustdamage_from.olchezheng = function(self, from, to, card, nature)
		if from:getPhase() == sgs.Player_Play and not to:inMyAttackRange(from)
		then
			return -99
		end
	end

	sgs.ai_ajustdamage_to.shichou = function(self, from, to, card, nature)
		if to:getMark("xhate") > 0
		then
			for _, p in sgs.list(self.room:getOtherPlayers(to)) do
				if p:getMark("hate_" .. to:objectName()) > 0 and p:getMark("@hate_to") > 0
				then
					return self:ajustDamage(from, p, 0, card, nature)
				end
			end
		end
	end

	sgs.ai_ajustdamage_to.yuce = function(self, from, to, card, nature)
		if not to:isKongcheng() and to:getHp() > 1
		then
			if self:isFriend(to, from)
			then
				return -1
			else
				if from:objectName() ~= self.player:objectName()
				then
					if from:getHandcardNum() <= 2
					then
						return -1
					end
				else
					if getKnownCard(to, self.player, "TrickCard,EquipCard", false, "h") < to:getHandcardNum()
						and getCardsNum("TrickCard,EquipCard", from, self.player) - from:getEquips():length() < 1
						or getCardsNum("BasicCard", from, self.player) < 2
					then
						return -1
					end
				end
			end
		end
	end

	sgs.ai_ajustdamage_to.shibei = function(self, from, to, card, nature)
		if getKnownCard(from, self.player, "TrickCard") > 1
			or getKnownCard(from, self.player, "Slash") > 1 and (getKnownCard(from, self.player, "Crossbow") > 0 or from:hasSkills(sgs.double_slash_skill))
			or from:hasSkills(sgs.straight_damage_skill)
			or self:getOverflow(from) > 0 then
		else
			return to:getMark("shibei") < 1
		end
	end

	sgs.ai_card_priority.jianying = function(self, card, v)
		if self.player:getMark("JianyingSuit") == card:getSuit() + 1
			or self.player:getMark("JianyingNumber") == card:getNumber()
		then
			return 10
		end
	end

	sgs.ai_card_priority.yanxiao = function(self, card, v)
		if card:isKindOf("YanxiaoCard") and self.player:containsTrick("YanxiaoCard")
		then
			v = 0.10
		end
	end

	sgs.ai_card_priority.luanji = function(self, card, v)
		if card:isKindOf("ArcheryAttack")
		then
			return 6
		end
	end

	sgs.ai_card_priority.sp_moonspear = function(self, card, v)
		if card:isBlack() and self.player:getPhase() == sgs.Player_NotActive
		then
			return 5
		end
	end

	sgs.ai_card_priority.moon_spear = function(self, card, v)
		if card:isBlack() and self.player:getPhase() == sgs.Player_NotActive
		then
			return 5
		end
	end

	sgs.ai_card_priority.shuangxiong = function(self, card, v)
		if card:isKindOf("Duel")
		then
			return 6.3
		end
	end

	sgs.ai_card_priority.cihuai = function(self, card, v)
		if card:isKindOf("Slash")
			and self.player:getMark("@cihuai") > 0
		then
			return 9
		end
	end

	sgs.ai_card_priority.danshou = function(self, card, v)
		if (card:isDamageCard() or sgs.dynamic_value.damage_card[card:getClassName()])
			and not hasJueqingEffect(self.player)
		then
			v = 0
		end
	end

	sgs.ai_card_priority.kuanggu = function(self, card, v)
		if card:isKindOf("Peach")
		then
			v = 1.09
		end
	end

	sgs.ai_card_priority.kofkuanggu = function(self, card, v)
		if card:isKindOf("Peach")
		then
			v = 1.09
		end
	end

	sgs.ai_ajustdamage_to.mingshi = function(self, from, to, card, nature)
		local x = self.equipsToDec or 0
		if card then x = sgs.getCardNumAtCertainPlace(card, sgs.Player_PlaceEquip) end
		if from:getEquips():length() - x <= to:getEquips():length() then return -1 end
	end

	sgs.ai_ajustdamage_to.ranshang = function(self, from, to, card, nature)
		if nature == "F"
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_to["&kuangfeng"] = function(self, from, to, card, nature)
		if nature == "F"
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_to.vine = function(self, from, to, card, nature)
		if nature == "F" and not IgnoreArmor(from, to)
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_to.gongqing = function(self, from, to, card, nature)
		if from:getAttackRange() > 3
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_from.xionghuo = function(self, from, to, card, nature)
		if to:getMark("@brutal") > 0
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_from.jinjian = function(self, from, to, card, nature)
		if from:getMark("&jinjianreduce-Clear") > 0
		then
			return -from:getMark("&jinjianreduce-Clear")
		end
		if not self:isFriend(from)
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_to.jinjian = function(self, from, to, card, nature)
		if to:getMark("&jinjianadd-Clear") > 0
		then
			return to:getMark("&jinjianadd-Clear")
		end
	end

	sgs.ai_ajustdamage_from.jieyuan = function(self, from, to, card, nature)
		if not beFriend(to, from)
			and (to:getHp() >= from:getHp() or from:getMark("jieyuan_rebel-Keep") > 0)
			and (from:getHandcardNum() >= 3 or (from:getMark("jieyuan_renegade-Keep") > 0 and not from:isNude()))
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_to.chouhai = function(self, from, to, card, nature)
		if to:isKongcheng()
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_from.jiedao = function(self, from, to, card, nature)
		if from:getLostHp() > 0 and not beFriend(to, from)
		then
			return from:getLostHp()
		end
	end

	sgs.ai_ajustdamage_from.lingren = function(self, from, to, card, nature)
		if from:getPhase() == sgs.Player_Play and to:hasFlag("lingren_damage_to")
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_from.zhuixi = function(self, from, to, card, nature)
		if from:faceUp() ~= to:faceUp()
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_to.zhuixi = function(self, from, to, card, nature)
		if from:faceUp() ~= to:faceUp()
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_from["@luoyi"] = function(self, from, to, card, nature)
		if card and card:isKindOf("Duel")
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_to.yj_yinfengyi = function(self, from, to, card, nature)
		if card and card:isKindOf("TrickCard")
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_to.zl_yinfengjia = function(self, from, to, card, nature)
		if card and card:isKindOf("TrickCard")
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_to.yinshi = function(self, from, to, card, nature)
		if card and hasYinshiEffect(to) and (card:getTypeId() == 2 or card:isKindOf("NatureSlash") or nature ~= "N")
		then
			return -99
		end
	end

	sgs.ai_ajustdamage_from.wenjiu = function(self, from, to, slash, nature)
		if slash and slash:isKindOf("Slash") and slash:isBlack()
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_from.shenli = function(self, from, to, slash, nature)
		if slash and slash:isKindOf("Slash") and from:getMark("@struggle") > 0
		then
			return math.min(3, from:getMark("@struggle"))
		end
	end

	sgs.ai_ajustdamage_from["&mobileliyong"] = function(self, from, to, slash, nature)
		if slash and slash:isKindOf("Slash")
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_from.wangong = function(self, from, to, slash, nature)
		if slash and slash:isKindOf("Slash") and from:getMark("&wangong") + from:getMark("wangong") > 0
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_from["&kannan"] = function(self, from, to, slash, nature)
		if slash and slash:isKindOf("Slash")
		then
			return from:getMark("&kannan")
		end
	end

	sgs.ai_ajustdamage_from.jie = function(self, from, to, slash, nature)
		if slash and slash:isKindOf("Slash") and slash:isRed()
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_from.zonghuo = function(self, from, to, slash, nature)
		if slash and slash:isKindOf("Slash")
		then
			nature = "F"
		end
	end

	sgs.ai_ajustdamage_from.anjian = function(self, from, to, slash, nature)
		if slash and slash:isKindOf("Slash") and not to:inMyAttackRange(from)
		then
			return 1
		end
	end

	sgs.ai_ajustdamage_to.jiaojin = function(self, from, to, slash, nature)
		if slash and slash:isKindOf("Slash") and from:isMale() and to:getEquips():length() > 0
		then
			return -1
		end
	end

	sgs.ai_ajustdamage_from.guding_blade = function(self, from, to, slash, nature)
		if slash and slash:isKindOf("Slash") and to:isKongcheng()
		then
			return 1
		end
	end

	sgs.ai_card_priority.zhulou = function(self, card, v)
		if self.useValue
			and card:isKindOf("Weapon")
		then
			v = 2
		end
	end

	sgs.ai_card_priority.taichen = function(self, card, v)
		if self.useValue
			and card:isKindOf("Weapon")
		then
			v = 2
		end
	end

	sgs.ai_card_priority.qiangxi = function(self, card, v)
		if self.useValue
			and card:isKindOf("Weapon")
		then
			v = 2
		end
	end

	sgs.ai_card_priority.kurou = function(self, card, v)
		if self.useValue
			and card:isKindOf("Crossbow")
		then
			return 9
		end
	end

	sgs.ai_card_priority.yizhong = function(self, card, v)
		if self.useValue
			and card:isKindOf("Armor")
		then
			v = 2
		end
	end

	sgs.ai_card_priority.bazhen = function(self, card, v)
		if self.useValue
			and card:isKindOf("Armor")
		then
			v = 2
		end
	end

	sgs.ai_card_priority.kuanggu = function(self, card, v)
		if self.useValue
			and card:inherits("Shit")
			and card:getSuit() ~= sgs.Card_Spade
		then
			v = 0.1
		end
	end

	sgs.ai_card_priority.jizhi = function(self, card, v)
		if self.useValue
			and card:isKindOf("TrickCard")
		then
			v = v + 3
		end
	end

	sgs.ai_card_priority.nosjizhi = function(self, card, v)
		if self.useValue
			and card:isNDTrick()
		then
			v = v + 4
		end
	end

	sgs.ai_card_priority.shuangxiong = function(self, card, v)
		if self.useValue
			and card:getSkillName() == "shuangxiong"
		then
			v = 6
		end
	end

	sgs.ai_card_priority.wumou = function(self, card, v)
		if self.useValue and card:isNDTrick() and not card:isKindOf("AOE")
			and not (card:isKindOf("Duel") and self.player:hasUsed("WuqianCard"))
		then
			v = 1
		end
	end

	sgs.ai_card_priority.tenyearchouhai = function(self, card, v)
		if self.useValue
			and self.player:getHandcardNum() <= 1
		then
			v = 1
		end
	end

	sgs.ai_card_priority.chouhai = function(self, card, v)
		if self.useValue
			and self.player:hasFlag("canshi")
			and self.player:getHandcardNum() <= 2
		then
			v = 1
		end
	end

	sgs.ai_card_priority.canshi = function(self, card, v)
		if self.useValue and self.player:hasFlag("canshi")
		then
			v = v - 2
		end
	end

	sgs.ai_card_priority.halberd = function(self, card, v)
		if self.useValue and card:isKindOf("Slash")
			and self.player:isLastHandCard(card)
		then
			v = 10
		end
	end

	sgs.ai_card_priority.spear = function(self, card)
		if card:getSkillName() == "spear"
		then
			if self.useValue
			then
				return -1
			end
			return -0.2
		end
	end

	sgs.ai_card_priority.jie = function(self, card)
		if card:isKindOf("Slash") and card:isRed()
		then
			return 0.16
		end
	end

	sgs.ai_card_priority.chongzhen = function(self, card)
		if card:getSkillName() == "longdan"
		then
			if self.useValue
			then
				return 1
			end
			return 0.08
		end
	end

	sgs.ai_card_priority.fuhun = function(self, card)
		if card:getSkillName() == "fuhun"
		then
			if self.useValue
			then
				return self.player:getPhase() == sgs.Player_Play and 1 or -1
			end
			return self.player:getPhase() == sgs.Player_Play and 0.06 or -0.05
		end
	end

	sgs.ai_card_priority.jiang = function(self, card)
		if card:isKindOf("Slash") and card:isRed()
		then
			return 0.05
		end
	end

	sgs.ai_card_priority.wushen = function(self, card)
		if card:isKindOf("Slash") and card:getSuit() == sgs.Card_Heart
		then
			return 0.03
		end
	end

	sgs.ai_card_priority.olwushen = function(self, card)
		if card:isKindOf("Slash") and card:getSuit() == sgs.Card_Heart
		then
			return 0.03
		end
	end

	sgs.ai_card_priority.lihuo = function(self, card)
		if card:getSkillName() == "lihuo"
		then
			return -0.02
		end
	end

	sgs.ai_card_priority.mingzhe = function(self, card)
		if card:isRed() then return self.player:getPhase() ~= sgs.Player_NotActive and 0.05 or -0.05 end
	end

	sgs.ai_card_priority.zenhui = function(self, card)
		if card:isBlack() and (card:isKindOf("Slash") or card:isNDTrick())
			and sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card) < 1
			and not self.player:hasFlag("zenhui")
		then
			return 0.1
		end
	end

	sgs.ai_target_revises.vine = function(to, card)
		if card:isKindOf("SavageAssault")
			or card:isKindOf("ArcheryAttack")
			or card:isKindOf("Chuqibuyi")
			or card:getClassName() == "Slash"
		then
			return true
		end
	end

	sgs.ai_nullification.kongcheng = function(self, trick, from, to, positive, null_num)
		if positive and from and self:isEnemy(from) and self:isFriend(to)
			and sgs.ai_role[from:objectName()] ~= "neutral"
			and self.player:getHandcardNum() <= null_num
		then
			return true
		end
	end

	sgs.ai_nullification.wumou = function(self, trick, from, to, positive, null_num)
		if self.player:getMark("&wrath") < 1 and self:isWeak()
			or not self:isWeak() and to:objectName() == self.player:objectName() and trick:isDamageCard()
		then
			return false
		end
	end

	sgs.ai_target_revises["dream"] = function(to, card)
		if to:isLocked(card) then return true end
	end

	sgs.ai_target_revises.huoshou = function(to, card)
		if card:isKindOf("SavageAssault")
		then
			return true
		end
	end

	sgs.ai_target_revises.danlao = function(to, card, self, use)
		if card:isKindOf("TrickCard") and use.to:length() > 1
			and not self:isFriend(to)
		then
			return true
		end
	end

	sgs.ai_target_revises.xiemu = function(to, card, self, use)
		if card:getTypeId() > 0 and card:isBlack() and self:isEnemy(to)
			and to:getMark("@xiemu_" .. self.player:getKingdom()) > 0
			and not (self:isWeak(to) and card:isDamageCard())
		then
			return true
		end
	end

	sgs.ai_target_revises.juxiang = function(to, card)
		if card:isKindOf("SavageAssault")
		then
			return true
		end
	end

	sgs.ai_target_revises.manyi = function(to, card)
		if card:isKindOf("SavageAssault")
		then
			return true
		end
	end

	sgs.ai_target_revises.olzhennan = function(to, card)
		if card:isKindOf("SavageAssault")
		then
			return true
		end
	end

	sgs.ai_target_revises.tenyearzongshi = function(to, card)
		if (card:isKindOf("DelayedTrick") or not card:isBlack() and not card:isRed())
			and to:getHandcardNum() >= to:getMaxCards() and to:getPhase() == sgs.Player_NotActive
		then
			return true
		end
	end

	sgs.ai_target_revises["@late"] = function(to, card, self)
		return card:isKindOf("Slash") or card:isNDTrick()
	end

	sgs.ai_target_revises.noswuyan = function(to, card, self)
		return card:isNDTrick() and self.player:objectName() ~= to:objectName()
			and not hasJueqingEffect(self.player, to)
	end

	sgs.ai_target_revises.wuyan = function(to, card, self)
		return card:isNDTrick() and card:isDamageCard()
			and not hasJueqingEffect(self.player, to)
	end

	sgs.ai_use_revises.wuyan = function(self, card, use)
		if card:isKindOf("SavageAssault")
		then
			menghuo = self.room:findPlayerBySkillName("huoshou")
			if menghuo and (not menghuo:hasSkill("wuyan") or hasJueqingEffect(menghuo))
			then else
				return false
			end
		elseif card:isKindOf("AOE")
		then
			if self:hasHuangenEffect(self.friends_noself)
			then else
				return false
			end
		elseif card:isNDTrick() and card:isDamageCard()
			and not hasJueqingEffect(self.player)
		then
			return false
		end
	end

	sgs.ai_use_revises.noswuyan = function(self, card, use)
		if card:isKindOf("AOE")
		then
			if self:hasHuangenEffect(self.friends_noself)
			then else
				return false
			end
		elseif card:isKindOf("AmazingGrace")
		then
			use.card = card
		elseif card:isKindOf("GodSalvation")
		then
			if self.player:isWounded() or self.player:hasSkills("nosjizhi|jizhi")
			then
				use.card = card
			else
				return false
			end
		end
	end

	sgs.ai_use_revises.luanji = function(self, card, use)
		if card:isKindOf("AOE") and self.player:getRole() == "lord" and sgs.turncount < 2 and math.random() > 0.7
		then
			self.player:addMark("AI_fangjian-Clear")
		end
	end

	sgs.ai_use_revises.nosgongqi = function(self, card, use)
		if card:isKindOf("EquipCard") and self:getSameEquip(card)
			and self:slashIsAvailable()
		then
			return false
		end
	end

	sgs.ai_use_revises.xiaoji = function(self, card, use)
		if card:isKindOf("EquipCard") and self:evaluateArmor(card) > -5
		then
			use.card = card
			return true
		end
	end

	sgs.ai_use_revises.kofxiaoji = function(self, card, use)
		if card:isKindOf("EquipCard") and self:evaluateArmor(card) > -5
		then
			use.card = card
			return true
		end
	end

	sgs.ai_use_revises.yongsi = function(self, card, use)
		if card:isKindOf("EquipCard") and self:getOverflow() < 2
		then
			return false
		end
	end

	sgs.ai_use_revises.qixi = function(self, card, use)
		if card:isKindOf("EquipCard")
			and card:isBlack()
		then
			same = self:getSameEquip(card)
			if same and same:isBlack()
			then
				return false
			end
		end
	end

	sgs.ai_use_revises.duanliang = function(self, card, use)
		if card:isKindOf("EquipCard")
			and card:isBlack()
		then
			same = self:getSameEquip(card)
			if same and same:isBlack()
			then
				return false
			end
		end
	end

	sgs.ai_use_revises.yinling = function(self, card, use)
		if card:isKindOf("EquipCard")
			and card:isBlack()
		then
			same = self:getSameEquip(card)
			if same and same:isBlack()
			then
				return false
			end
		end
	end

	sgs.ai_use_revises.guose = function(self, card, use)
		if card:isKindOf("EquipCard")
			and card:getSuit() == sgs.Card_Diamond
		then
			same = self:getSameEquip(card)
			if same and same:getSuit() == sgs.Card_Diamond
			then
				return false
			end
		end
	end

	sgs.ai_use_revises.longhun = function(self, card, use)
		if card:isKindOf("EquipCard")
			and card:getSuit() == sgs.Card_Diamond
		then
			same = self:getSameEquip(card)
			if same and same:getSuit() == sgs.Card_Diamond
			then
				return false
			end
		end
	end

	sgs.ai_use_revises.jijiu = function(self, card, use)
		if card:isKindOf("EquipCard")
			and card:isRed()
		then
			same = self:getSameEquip(card)
			if same and same:isRed()
			then
				return false
			end
		end
	end

	sgs.ai_use_revises.guidao = function(self, card, use)
		if card:isKindOf("EquipCard")
			and card:isBlack()
		then
			same = self:getSameEquip(card)
			if same and same:isBlack()
			then
				return false
			end
		end
	end

	sgs.ai_use_revises.junxing = function(self, card, use)
		if card:isKindOf("EquipCard")
			and self:getSameEquip(card)
		then
			return false
		end
	end

	sgs.ai_use_revises.jiehuo = function(self, card, use)
		if (card:isKindOf("Weapon") or card:isKindOf("OffensiveHorse"))
			and self.player:getMark("jiehuo") < 0 and card:isRed()
		then
			return false
		end
	end

	sgs.ai_use_revises.zhulou = function(self, card, use)
		if card:isKindOf("Weapon") and self:getSameEquip(card)
		then
			return false
		end
	end

	sgs.ai_use_revises.taichen = function(self, card, use)
		if card:isKindOf("Weapon")
		then
			same = self:getSameEquip(card)
			if same
			then
				same = sgs.Card_Parse("@TaichenCard=" .. same:getEffectiveId())
				if self:aiUseCard(same).card
				then
					return false
				end
			end
		end
	end

	sgs.ai_use_revises.qiangxi = function(self, card, use)
		if card:isKindOf("Weapon")
			and not self.player:hasUsed("QiangxiCard")
		then
			same = self:getSameEquip(card)
			if same
			then
				same = sgs.Card_Parse("@QiangxiCard=" .. same:getEffectiveId())
				same = self:aiUseCard(same)
				if same.card and same.card:subcardsLength() == 1
				then
					return false
				end
			end
		end
	end

	sgs.ai_use_revises.paoxiao = function(self, card, use)
		if card:isKindOf("Crossbow")
		then
			return false
		end
	end

	sgs.ai_use_revises.tenyearpaoxiao = function(self, card, use)
		if card:isKindOf("Crossbow")
		then
			return false
		end
	end

	sgs.ai_use_revises.olpaoxiao = function(self, card, use)
		if card:isKindOf("Crossbow")
		then
			return false
		end
	end

	sgs.ai_use_revises.nosfuhun = function(self, card, use)
		if card:isKindOf("Crossbow")
		then
			return false
		end
	end

	sgs.ai_use_revises.zhiheng = function(self, card, use)
		if card:isKindOf("Weapon")
			and not card:isKindOf("Crossbow")
			and self:getSameEquip(card)
			and not self.player:hasUsed("ZhihengCard")
		then
			return false
		end
	end

	sgs.ai_use_revises.jilve = function(self, card, use)
		if card:isKindOf("Weapon")
			and self.player:getMark("&bear") > 0
			and not card:isKindOf("Crossbow")
			and self:getSameEquip(card)
			and not self.player:hasUsed("ZhihengCard")
		then
			return false
		end
	end

	sgs.ai_use_revises.tiaoxin = function(self, card, use)
		if card:isKindOf("DefensiveHorse")
		then
			if self:aiUseCard(sgs.Card_Parse("@TiaoxinCard=."), { isDummy = true, defHorse = true }).card
			then
				return false
			end
		end
	end
end


dofile "lua/ai/debug-ai.lua"
dofile "lua/ai/imagine-ai.lua"
dofile "lua/ai/standard_cards-ai.lua"
dofile "lua/ai/maneuvering-ai.lua"
dofile "lua/ai/classical-ai.lua"
dofile "lua/ai/standard-ai.lua"
dofile "lua/ai/chat-ai.lua"
dofile "lua/ai/basara-ai.lua"
dofile "lua/ai/hegemony-ai.lua"
dofile "lua/ai/hulaoguan-ai.lua"
dofile "lua/ai/jiange-defense-ai.lua"
dofile "lua/ai/boss-ai.lua"

local loaded = "standard|standard_cards|maneuvering|sp"

local ai_files = sgs.GetFileNames("lua/ai")

for _, aextension in sgs.list(sgs.Sanguosha:getExtensions()) do
	if loaded:match(aextension) then continue end
	aextension = string.lower(aextension) .. "-ai.lua"
	for _, ai_file in sgs.list(ai_files) do
		if aextension == string.lower(ai_file)
		then
			dofile("lua/ai/" .. aextension)
			break
		end
	end
end

dofile "lua/ai/sp-ai.lua"
dofile "lua/ai/special3v3-ai.lua"

for _, ascenario in sgs.list(sgs.Sanguosha:getModScenarioNames()) do
	if loaded:match(ascenario) then continue end
	ascenario = string.lower(ascenario) .. "-ai.lua"
	for _, ai_file in sgs.list(ai_files) do
		if ascenario == string.lower(ai_file)
		then
			dofile("lua/ai/" .. ascenario)
			break
		end
	end
end

for _, skill in ipairs(sgs.ai_skills) do
	sgs.ai_fill_skill[skill.name] = skill.getTurnUseCard
end
