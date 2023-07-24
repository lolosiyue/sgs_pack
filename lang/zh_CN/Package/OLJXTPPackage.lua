-- translation for OLJXTP Package

return {
	["OLJXTP"] = "OL界限突破",
	
	["ol_caocao"] = "OL界曹操",
	["&ol_caocao"] = "界曹操",
	["illustrator:ol_caocao"] = "青骑士",
	["olhujia"] = "护驾",
	[":olhujia"] = "主公技，每当你需要使用或打出一张【闪】时，你可以令其他魏势力角色打出一张【闪】，视为你使用或打出之。每个回合限一次，其他魏势力角色于其回合外使用或打出【闪】时，可令你摸一张牌。",
	["@olhujia-draw"] = "你可以令一名有技能“护驾”的角色摸一张牌",
	
	["ol_liubei"] = "OL界刘备",
	["&ol_liubei"] = "界刘备",
	["illustrator:ol_liubei"] = "木美人",
	["oljijiang"] = "激将",
	[":oljijiang"] = "主公技，每当你需要使用或打出一张【杀】时，你可以令其他蜀势力角色打出一张【杀】，视为你使用或打出之。其他蜀势力角色于其回合外使用或打出【杀】时，可令你摸一张牌。",
	["@oljijiang-draw"] = "你可以令一名有技能“激将”的角色摸一张牌",
	["@oljijiang-slash"] = "请打出一张【杀】响应 %src “激将”",
	
	["ol_zhangfei"] = "OL界张飞",
	["&ol_zhangfei"] = "界张飞",
	["illustrator:ol_zhangfei"] = "SONGQIJIN",
	["olpaoxiao"] = "咆哮",
	[":olpaoxiao"] = "锁定技，你使用【杀】无次数限制。若你使用的【杀】被【闪】抵消，你本回合下一次造成【杀】的伤害时，此伤害+1。",
	["olpaoxiao_missed"] = "咆哮加伤",
	["#OlpaoxiaoDamage"] = "%from 的“<font color=\"yellow\"><b>咆哮</b></font>”被触发，对 %to 的伤害由 %arg 点增至 %arg2 点",
	["oltishen"] = "替身",
	[":oltishen"] = "限定技，准备阶段开始时，你可以将体力回复至体力上限，然后摸X张牌（X为你回复的体力值）。",
	
	["ol_zhaoyun"] = "OL界赵云",
	["&ol_zhaoyun"] = "界赵云",
	["illustrator:ol_zhaoyun"] = "DH",
	["ollongdan"] = "龙胆",
	[":ollongdan"] = "你可以将一张【杀】当【闪】、【闪】当【杀】、【酒】当【桃】、【桃】当【酒】使用或打出。",
	["olyajiao"] = "涯角",
	[":olyajiao"] = "当你于回合外使用或打出手牌时，你可以展示牌堆顶的一张牌。若这两张牌的类别相同，你可以将展示的牌交给一名角色；若类别不同，你可弃置攻击范围内包含你的一名角色"..
					"区域里的一张牌。",
	["@olyajiao-give"] = "你可以将此牌交给一名角色",
	["@olyajiao-discard"] = "你可弃置攻击范围内包含你的一名角色区域里的一张牌",
	["olyajiao_discard"] = "涯角",
	
	["ol_sunquan"] = "OL界孙权",
	["&ol_sunquan"] = "界孙权",
	["illustrator:ol_sunquan"] = "凝聚永恒",
	["oljiuyuan"] = "救援",
	[":oljiuyuan"] = "主公技，其他吴势力角色于其回合内回复体力时，若其体力值大于等于你，其可以改为令你回复1点体力，然后其摸一张牌。",
	
	["ol_lvmeng"] = "OL界吕蒙",
	["&ol_lvmeng"] = "界吕蒙",
	["illustrator:ol_lvmeng"] = "樱花闪乱",
	["olqinxue"] = "勤学",
	[":olqinxue"] = "觉醒技，准备阶段或结束阶段开始时，若你的手牌数比你的体力值多2或更多，你减1点体力上限，回复1点体力或摸两张牌，然后获得“攻心”。",
	["olqinxue:recover"] = "回复1点体力",
	["olqinxue:draw"] = "摸两张牌",
	["olbotu"] = "博图",
	[":olbotu"] = "回合结束后，若你于出牌阶段内使用过四种花色的牌，你可以获得一个额外回合。",
	--每轮限X次，回合结束后，若此回合内置入弃牌堆的牌包含四种花色，你可以获得一个额外回合（X为存活角色数且至多为3）。
	
	["ol_zhangjiao"] = "OL界张角",
	["&ol_zhangjiao"] = "界张角",
	["illustrator:ol_zhangjiao"] = "青骑士",
	["olleiji"] = "雷击",
	[":olleiji"] = "当你使用或打出【闪】或【闪电】时，你可以进行判定。当你不因“暴虐”而进行判定后，若判定结果为：黑桃，你对一名角色造成2点雷电伤害；梅花，你回复1点体力，"..
					"然后对一名角色造成1点雷电伤害。",
	["@olleiji-invoke"] = "请选择一名角色，对其造成 %src 点雷电伤害",
	["olguidao"] = "鬼道",
	[":olguidao"] = "当一名角色的判定牌生效前，你可以打出一张黑色牌替换之。若你打出的牌是黑桃2~9，你摸一张牌。",
	["@olguidao-card"] = CommonTranslationTable["@askforretrial"],
	
	["second_ol_zhangjiao"] = "OL界张角-第二版",
	["&second_ol_zhangjiao"] = "界张角",
	["illustrator:second_ol_zhangjiao"] = "青骑士",
	["olhuangtian"] = "黄天",
	[":olhuangtian"] = "主公技，其他群势力角色的出牌阶段限一次，该角色可以交给你一张【闪】或黑桃手牌。",
	["olhuangtian_attach"] = "黄天送牌",
	
	["ol_yuji"] = "OL界于吉",
	["&ol_yuji"] = "界于吉",
	["illustrator:ol_yuji"] = "波子",
	["olguhuo"] = "蛊惑",
	[":olguhuo"] = "每名角色的回合限一次，你可以扣置一张手牌当任意一张基本牌或普通锦囊牌使用或打出。其他角色可同时进行质疑并翻开此牌：若为假则此牌作废，且质疑者摸一张牌；"..
					"若为真则所有质疑者弃置一张牌或失去1点体力，并获得“缠怨”。",
	["olguhuo-discard"] = "请弃置一张牌，否则失去1点体力",
	["olguhuo:noquestion"] = "不质疑",
	["olguhuo:question"] = "质疑",
	["olguhuo_saveself"] = "“蛊惑”【桃】或【酒】",
	["olguhuo_slash"] = "“蛊惑”【杀】",
	
	["ol_xiahouyuan"] = "OL界夏侯渊",
	["&ol_xiahouyuan"] = "界夏侯渊",
	["illustrator:ol_xiahouyuan"] = "李秀森",
	["olshebian"] = "设变",
	[":olshebian"] = "当你的武将牌翻面时，你可以移动场上的一张装备牌。",
	
	["ol_weiyan"] = "OL界魏延",
	["&ol_weiyan"] = "界魏延",
	["illustrator:ol_weiyan"] = "王强",
	["olqimou"] = "奇谋",
	[":olqimou"] = "限定技，出牌阶段，你可以失去任意点体力，摸X张牌，然后直到回合结束，你与其他角色的距离-X，且你可以多使用X张【杀】（X为你失去的体力值）。",
	
	["ol_xiaoqiao"] = "OL界小乔",
	["&ol_xiaoqiao"] = "界小乔",
	["illustrator:ol_xiaoqiao"] = "王强",
	["oltianxiang"] = "天香",
	[":oltianxiang"] = "当你受到伤害时，你可以弃置一张红桃牌，防止此次伤害并选择一名其他角色，你选择一项：令其受到1点伤害，然后摸X张牌（X为其已损失体力值且至多为5）；令其失去1点体力，然后其获得你弃置的牌。",
	["oltianxiang:damage"] = "令其受到1点伤害，然后摸X张牌",
	["oltianxiang:losehp"] = "令其失去1点体力，然后其获得你弃置的牌",
	["@oltianxiang"] = "你可以弃置一张<font color=\"red\">♥</font>手牌发动“天香”",
	["~oltianxiang"] = "选择一张<font color=\"red\">♥</font>手牌和一名其他角色→点“确定”",
	["olhongyan"] = "红颜",
	[":olhongyan"] = "锁定技，你的黑桃牌视为红桃牌。若你的装备区内有红桃牌，你的手牌上限等于体力上限。",
	["olpiaoling"] = "飘零",
	[":olpiaoling"] = "回合结束时，你可进行一次判定，若判定结果为红桃，你将判定牌置于牌堆顶或交给一名角色，若该角色是你，你弃置一张牌。",
	["@olpiaoling-invoke"] = "你可以将【%src】交给一名角色，或点“取消”置于牌堆顶",
	
	["ol_yuanshao"] = "OL界袁绍",
	["&ol_yuanshao"] = "界袁绍",
	["illustrator:ol_yuanshao"] = "罔両",
	["olluanji"] = "乱击",
	[":olluanji"] = "你可以将两张花色相同的手牌当【万箭齐发】使用；当你使用【万箭齐发】时，若此牌的目标数大于1，你可以少选一个目标。",
	["@olluanji-remove"] = "你可以为【万箭齐发】减少一个目标",
	["olxueyi"] = "血裔",
	[":olxueyi"] = "主公技，游戏开始时，你获得X枚“裔”标记（X为群势力角色数）；回合开始时，你可以弃置一枚“裔”并摸一张牌；你每有一枚“裔”，手牌上限+2。",
	["olyi"] = "裔",
	
	["second_ol_yuanshao"] = "OL界袁绍-第二版",
	["&second_ol_yuanshao"] = "界袁绍",
	["illustrator:second_ol_yuanshao"] = "罔両",
	["secondolxueyi"] = "血裔",
	[":secondolxueyi"] = "主公技，游戏开始时，你获得2X枚“裔”标记（X为群势力角色数）；出牌阶段开始时，你可以弃置一枚“裔”并摸一张牌；你每有一枚“裔”，手牌上限+1。",
	
	["ol_wolong"] = "OL界卧龙诸葛亮",
	["&ol_wolong"] = "界卧龙诸葛亮",
	["illustrator:ol_wolong"] = "李秀森",
	["olhuoji"] = "火计",
	[":olhuoji"] = "你可以将一张红色牌当【火攻】使用。",
	["olkanpo"] = "看破",
	[":olkanpo"] = "你可以将一张黑色牌当【无懈可击】使用。",
	["olcangzhuo"] = "藏拙",
	[":olcangzhuo"] = "锁定技，若你本回合未使用过锦囊牌，你的锦囊牌在弃牌阶段不计入手牌上限。",
	
	["ol_pangtong"] = "OL界庞统",
	["&ol_pangtong"] = "界庞统",
	["illustrator:ol_pangtong"] = "MUMU",
	["ollianhuan"] = "连环",
	[":ollianhuan"] = "你可以将一张梅花牌当【铁索连环】使用或重铸；你使用【铁索连环】可以额外选择一名目标。",
	["olniepan"] = "涅槃",
	[":olniepan"] = "限定技，当你处于濒死状态时，你可以弃置所有牌，然后复原你的武将牌，摸三张牌，将体力回复至3点。然后你从“八阵”、“火计”、“看破”中选择一个技能获得。",
	
	["ol_pangde"] = "OL界庞德",
	["&ol_pangde"] = "界庞德",
	["illustrator:ol_pangde"] = "",
	["oljianchu"] = "鞬出",
	[":oljianchu"] = "当你使用【杀】指定一个目标后，你可以弃置其一张牌，若弃置的牌：不是基本牌，该角色不能使用【闪】且你本回合可额外使用一张【杀】；基本牌，该角色获得此【杀】。",
	
	["ol_taishici"] = "OL界太史慈",
	["&ol_taishici"] = "界太史慈",
	["illustrator:ol_taishici"] = "biou09",
	["olhanzhan"] = "酣战",
	[":olhanzhan"] = "你与其他角色拼点或其他角色与你拼点时，你可令其使用随机的手牌拼点。",
	
	["second_ol_taishici"] = "OL界太史慈-第二版",
	["&second_ol_taishici"] = "界太史慈",
	["illustrator:second_ol_taishici"] = "biou09",
	["secondolhanzhan"] = "酣战",
	[":secondolhanzhan"] = "你与其他角色拼点，或其他角色与你拼点时，你可令其使用随机的手牌拼点。当你拼点后，你可获得拼点牌中点数最大的【杀】。",
	["#secondolhanzhan"] = "酣战",
	["@secondolhanzhan"] = "你可获得拼点牌中点数最大的【杀】",
	["~secondolhanzhan"] = "选择点数最大的【杀】→点“确定”",
	
	["ol_sunjian"] = "OL界孙坚",
	["&ol_sunjian"] = "界孙坚",
	["illustrator:ol_sunjian"] = "匠人绘",
	["olwulie"] = "武烈",
	[":olwulie"] = "限定技，结束阶段开始时，你可以失去任意点体力，令等同于失去体力值数量的其他角色获得一枚“烈”标记；拥有“烈”标记的角色受到伤害时，弃置此标记并防止该伤害。",
	["@olwulie"] = "你可以发动“武烈”",
	["~olwulie"] = "选择至多等于你体力值数量的角色→点“确定”",
	["ollie"] = "烈",
	["#OlwuliePrevent"] = "%from 的“%arg”效果被触发，防止了 %arg2 点伤害",
	
	["second_ol_sunjian"] = "OL界孙坚-第二版",
	["&second_ol_sunjian"] = "界孙坚",
	["illustrator:second_ol_sunjian"] = "匠人绘",
	
	["ol_dongzhuo"] = "OL界董卓",
	["&ol_dongzhuo"] = "界董卓",
	["illustrator:ol_dongzhuo"] = "",
	["oljiuchi"] = "酒池",
	[":oljiuchi"] = "你可以将一张黑桃手牌当【酒】使用。你使用【酒】无次数限制。你使用受【酒】影响的【杀】造成伤害后，本回合“崩坏”失效。",
	["olbaonue"] = "暴虐",
	[":olbaonue"] = "主公技，当其他群势力角色造成1点伤害后，你可进行判定，若判定结果为黑桃，你回复1点体力并获得此判定牌。",
	
	["ol_zuoci"] = "OL界左慈",
	["&ol_zuoci"] = "界左慈",
	["illustrator:ol_zuoci"] = "波子",
	["olhuashen"] = "化身",
	[":olhuashen"] = "游戏开始时，你随机获得3张武将牌，然后亮出其中一张。你获得亮出“化身”牌的一个技能，且性别和势力视为与“化身”牌相同。回合开始时和回合结束时，你可以选择一项："..
					"更改亮出的“化身”牌；或移去至多两张“化身”牌并获得等量新的“化身”牌。",
	["olhuashen:change"] = "更改亮出的“化身”牌",
	["olhuashen:exchangeone"] = "移去一张“化身”牌并获得一张新的“化身”牌",
	["olhuashen:exchangetwo"] = "移去两张“化身”牌并获得两张新的“化身”牌",
	["#RemoveHuashenDetail"] = "%from 移去了 %arg 张“化身”牌：%arg2",
	
	["ol_liushan"] = "OL界刘禅",
	["&ol_liushan"] = "界刘禅",
	["illustrator:ol_liushan"] = "拉布拉卡",
	["olfangquan"] = "放权",
	[":olfangquan"] = "你可以跳过出牌阶段，然后弃牌阶段开始时，你可以弃置一张手牌并令一名其他角色在你的回合结束后获得一个额外的回合。",
	["@olfangquan-give"] = "你可以弃置一张手牌令一名其他角色进行一个额外的回合",
	["~olfangquan"] = "选择一张手牌→选择一名其他角色→点击确定",
	["olruoyu"] = "若愚",
	[":olruoyu"] = "主公技，觉醒技，准备阶段开始时，若你是体力值最小的角色，你加1点体力上限，将体力回复至3点，然后获得“激将”和“思蜀”。",
	["olsishu"] = "思蜀",
	[":olsishu"] = "出牌阶段开始时，你可以令一名角色在本局游戏中【乐不思蜀】的判定效果反转。",
	["@olsishu-invoke"] = "你可以发动“思蜀”",
	["#OLsishuEffect"] = "%from 的“%arg”效果被触发，判定效果反转",
	
	["ol_sunce"] = "OL界孙策",
	["&ol_sunce"] = "界孙策",
	["illustrator:ol_sunce"] = "李敏然",
	["olzhiba"] = "制霸",
	[":olzhiba"] = "主公技，<font color=\"green\"><b>其他吴势力角色的出牌阶段限一次，</b></font>该角色可以与你拼点（你可拒绝此拼点）；<font color=\"green\"><b>你的出牌阶段限一次，</b></font>你可与其他吴势力角色拼点。若其没赢，你可以获得拼点的两张牌。",
	["olzhiba_pindian"] = "制霸拼点",
	["olzhiba_pindian:accept"] = "接受",
	["olzhiba_pindian:reject"] = "拒绝",
	["olzhiba_pindian_obtain"] = "制霸获得牌",
	["olzhiba_pindian_obtain:obtainPindianCards"] = "获得拼点牌",
	["olzhiba_pindian_obtain:reject"] = "不获得",
	
	["ol_dengai"] = "OL界邓艾",
	["&ol_dengai"] = "界邓艾",
	["illustrator:ol_dengai"] = "凝聚永恒",
	["oltuntian"] = "屯田",
	[":oltuntian"] = "当你于回合外失去牌或于回合内弃置【杀】后，你可以进行判定：若结果不为红桃，将判定牌置于武将牌上，称为“田”。你与其他角色的距离-X（X为“田”的数量）。",
	["#oltuntian-dist"] = "屯田",
	["olzaoxian"] = "凿险",
    [":olzaoxian"] = "觉醒技，准备阶段开始时，若你的“田”大于或等于三张，你减1点体力上限，获得“急袭”，且你于当前回合结束后获得一个额外回合。",
	
	["ol_gongsunzan"] = "OL界公孙瓒",
	["&ol_gongsunzan"] = "界公孙瓒",
	["illustrator:ol_gongsunzan"] = "Vincent",
	["olqiaomeng"] = "趫猛",
	[":olqiaomeng"] = "当你使用的【杀】对一名角色造成伤害后，你可弃置其区域里的一张牌。若此牌为坐骑牌，你获得之。",
	["olyicong"] = "义从",
	[":olyicong"] = "锁定技，你与其他角色的距离-1；若你的体力值不大于2，其他角色与你的距离+1。",
	
	["ol_zhurong"] = "OL界祝融",
	["&ol_zhurong"] = "界祝融",
	["illustrator:ol_zhurong"] = "",
	["olchangbiao"] = "长标",
	[":olchangbiao"] = "出牌阶段限一次，你可将任意张手牌当无距离限制的【杀】使用。若此【杀】造成过伤害，此阶段结束时你摸等量的牌。",
	
	["ol_jiangwei"] = "OL界姜维",
	["&ol_jiangwei"] = "界姜维",
	["illustrator:ol_jiangwei"] = "",
	["oltiaoxin"] = "挑衅",
	[":oltiaoxin"] = "出牌阶段限一次，你可以选择一名攻击范围内含有你的角色，然后除非该角色对你使用一张【杀】且此【杀】对你造成伤害，否则你弃置其一张牌，然后将此技能修改为出牌阶段限两次直到回合结束。",
	["@oltiaoxin-slash"] = "%src 对你发动“挑衅”，请对其使用一张【杀】",
	["olzhiji"] = "志继",
	[":olzhiji"] = "觉醒技，准备阶段或结束阶段开始时，若你没有手牌，你回复1点体力或摸两张牌，然后减1点体力上限，获得“观星”。",
	
	["ol_menghuo"] = "OL界孟获",
	["&ol_menghuo"] = "界孟获",
	["illustrator:ol_menghuo"] = "",
	["olzaiqi"] = "再起",
	[":olzaiqi"] = "结束阶段开始时，你可以令至多X名角色各选择一项（X为本回合内置入弃牌堆的红色牌数）：摸一张牌；或令你回复1点体力。",
	["olzaiqi:draw"] = "摸一张牌",
	["olzaiqi:recover"] = "令%src回复1点体力",
	
	["ol_xuhuang"] = "OL界徐晃",
	["&ol_xuhuang"] = "界徐晃",
	["illustrator:ol_xuhuang"] = "",
	["olduanliang"] = "断粮",
	[":olduanliang"] = "你可以将一张黑色基本牌或黑色装备牌当【兵粮寸断】使用；若你本回合未造成过伤害，你使用【兵粮寸断】无距离限制。",
	["oljiezi"] = "截辎",
	[":oljiezi"] = "一名角色跳过摸牌阶段后，你可选择一名角色，若其手牌数为全场最少且没有“辎”标记，其获得“辎”，否则其摸一张牌。有“辎”的角色于其摸牌阶段结束时弃置“辎”，然后执行一个额外的摸牌阶段。",
	["@oljiezi-target"] = "你可选择一名角色，若其手牌数为全场最少且没有“辎”标记，其获得“辎”，否则其摸一张牌",
	["olxhzi"] = "辎",
	[":&olxhzi"] = "摸牌阶段结束时你弃置“辎”标记，然后执行一个额外的摸牌阶段",
	
	["ol_zhanghe"] = "OL界张郃",
	["&ol_zhanghe"] = "界张郃",
	["illustrator:ol_zhanghe"] = "君桓文化",
	["olqiaobian"] = "巧变",
	[":olqiaobian"] = "游戏开始时，你获得2枚“变”标记。你可以弃置一张牌或一枚“变”标记并跳过你的一个阶段（准备阶段和结束阶段除外）。若跳过摸牌阶段，你可以获得至多两名角色各一张手牌；" ..
					"若跳过出牌阶段，你可以移动场上的一张牌。结束阶段开始时，若你的手牌数与之前你的每一个结束阶段开始时的手牌数均不相等，你获得一枚“变”标记。",
	[":olqiaobian1"] = "游戏开始时，你获得2枚“变”标记。你可以弃置一张牌或一枚“变”标记并跳过你的一个阶段（准备阶段和结束阶段除外）。若跳过摸牌阶段，你可以获得至多两名角色各一张手牌；" ..
					"若跳过出牌阶段，你可以移动场上的一张牌。结束阶段开始时，若你的手牌数与之前你的每一个结束阶段开始时的手牌数均不相等，你获得一枚“变”标记。\
					<font color=\"red\"><b>已记录手牌数：%arg11</b></font>",
	["olzhbian"] = "变",
	["@olqiaobian-2"] = "你可以依次获得一至两名其他角色的各一张手牌",
	["@olqiaobian-3"] = "你可以将场上的一张牌移动至另一名角色相应的区域内",
	["#olqiaobian-1"] = "你可以弃置%arg张牌或点“确定”弃置一枚“变”标记跳过判定阶段",
	["#olqiaobian-2"] = "你可以弃置%arg张牌或点“确定”弃置一枚“变”标记跳过摸牌阶段",
	["#olqiaobian-3"] = "你可以弃置%arg张牌或点“确定”弃置一枚“变”标记跳过出牌阶段",
	["#olqiaobian-4"] = "你可以弃置%arg张牌或点“确定”弃置一枚“变”标记跳过弃牌阶段",
	["~olqiaobian2"] = "选择 1-2 名其他角色→点击确定",
	["~olqiaobian3"] = "选择一名角色→点击确定",
	["olqiaobian:mark"] = "弃置一枚“变”标记跳过%src阶段",
	["olqiaobian:card"] = "弃置一张牌跳过%src阶段",
	
	["ol_jie_caiwenji"] = "OL界蔡文姬",
	["&ol_jie_caiwenji"] = "界蔡文姬",
	["illustrator:ol_jie_caiwenji"] = "",
	["olbeige"] = "悲歌",
	[":olbeige"] = "当一名角色受到【杀】的伤害后，若你有牌，你可以令其进行一次判定，然后你可以弃置一张牌并根据判定结果执行对应效果：\
					红桃，其回复1点体力；\
					方块，其摸两张牌；\
					梅花，伤害来源弃置两张牌；\
					黑桃，伤害来源将武将牌翻面。\
					若你弃置的牌与判定牌：\
					点数相同，你获得你弃置的牌；\
					花色相同，你获得判定牌。",
	["@olbeige-discard"] = "%src 的判定结果为 %arg%dest，你可以弃置一张牌对其发动“悲歌”",
	
	["ol_xunyu"] = "OL界荀彧",
	["&ol_xunyu"] = "界荀彧",
	["illustrator:ol_xunyu"] = "",
	["oljieming"] = "节命",
	[":oljieming"] = "当你受到1点伤害后或死亡时，你可以令一名角色摸X张牌，然后其将手牌弃置至X张（X为其体力上限且至多为5）。",
	["@oljieming-invoke"] = "你可以令一名角色摸牌",
	
	["ol_dianwei"] = "OL界典韦",
	["&ol_dianwei"] = "界典韦",
	["illustrator:ol_dianwei"] = "",
	["olqiangxi"] = "强袭",
	[":olqiangxi"] = "出牌阶段限两次，你可以受到1点伤害或弃置一张武器牌，对一名本回合内未以此法指定过的其他角色造成1点伤害。",
	["olninge"] = "狞恶",
	[":olninge"] = "锁定技，当一名角色每回合第二次受到伤害后，若其为你或伤害来源为你，你摸一张牌并弃置其场上一张牌。",
	
	--[[界孙策  修改稿
	激昂 当你使用【决斗】或红色【杀】指定目标后，或成为【决斗】或红色【杀】的目标后，你可以摸一张牌。每回合首次【决斗】或红色【杀】因弃置置入弃牌堆后，你可失去1点体力获得之。
	魂姿 觉醒技，准备阶段，若你的体力值为1，你减少1点体力上限并获得【英姿】【英魂】，本回合结束阶段，你摸两张牌或回复1点体力。
	zhiba
	]]
	
	--[[OL界颜良文丑 群	4
	【双雄】：摸牌阶段结束时，你可以弃置一张牌，然后你本回合可以将一张与之颜色不同的牌当【决斗】使用。结束阶段开始时，你获得本回合对你造成伤害的牌。
	]]
}
