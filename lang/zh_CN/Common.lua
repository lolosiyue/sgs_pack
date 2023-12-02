CommonTranslationTable = {
	["lord"] = "主公",
	["loyalist"] = "忠臣",
	["rebel"] = "反贼",
	["renegade"] = "内奸",
	["leader"] = "主帅",
	["guard"] = "前锋",
	["vanguard"] = "先锋",
	["mainstay"] = "中坚",
	["general"] = "大将",
	["offensive"] = "先手",
	["defensive"] = "后手",

	["compulsoryskill"] = "锁定技，",
	["limitedskill"] = "限定技，",
	["wakeskill"] = "觉醒技，",
	["lordskill"] = "主公技，",
	["oppphskill"] = "出牌阶段限一次，",
	["changeskill"] = "转换技，",
	["hideskill"] = "隐匿技，",
	["turnskill"] = "每个回合限一次，",
	["shimingskill"] = "使命技，",
	["lunskill"] = "每轮限一次，",
	["weiskill"] = "魏势力技，",
	["shuskill"] = "蜀势力技，",
	["wuskill"] = "吴势力技，",
	["qunskill"] = "群势力技，",
	["jinskill"] = "晋势力技，",
	["godskill"] = "神势力技，",

	["Pairs"] = "双将",
	["XMode"] = "血战到底",
	["Cards"] = "卡牌",
	["cancel"] = "取消",
	["GeneralA"] = "主将",
	["GeneralB"] = "副将",
	["surrender:yes"] = "你可以立即认输结束游戏",
	["@dummy-slash"] = "请选择你使用【杀】的目标角色",
	["@dummy-slash2"] = "请选择 %src 使用【杀】的目标角色",

	["spade"] = "黑桃",
	["club"] = "梅花",
	["heart"] = "红桃",
	["diamond"] = "方块",
	["no_suit"] = "无色",
	["no_suit_black"] = "黑色",
	["no_suit_red"] = "红色",
	["black"] = "黑色",
	["red"] = "红色",
	["basic"] = "基本牌",
	["trick"] = "锦囊牌",
	["equip"] = "装备牌",
	["notbasic"] = "非基本牌",
	["BasicCard"] = "基本牌",
	["TrickCard"] = "锦囊牌",
	["EquipCard"] = "装备牌",
	["ndtrick"] = "非延时锦囊",

	["spade_char"] = "♠",
	["club_char"] = "♣",
	["heart_char"] = "♥",
	["diamond_char"] = "♦",
	["no_suit_red_char"] = "红色",
	["no_suit_black_char"] = "黑色",
	["no_suit_char"] = "无色",
	["roundstart"] = "回合开始",
	["start"] = "准备",
	["judge"] = "判定",
	["retrial"] = "改判",
	["judgedone"] = "的判定结果",
	["put"] = "置于",
	["throw"] = "弃置",
	["enter"] = "置入",
	["backinto"] = "移回弃牌堆",
	["draw"] = "摸牌",
	["play"] = "出牌",
	["discard"] = "弃牌",
	["gamerule"] = "弃牌阶段", -- display reason
	["finish"] = "结束",
	["use"] = "使用",
	["response"] = "打出",
	["dismantled"] = "被弃置",
	["recast"] = "重铸",
	["pindian"] = "拼点",
	["change equip"] = "更换装备",
	["turnover"] = "从牌堆顶翻开",
	["preview"] = "观看牌堆",
	["show"] = "展示",
	["shuffle"] = "洗入",
	["online"] = "在线",
	["offline"] = "离线",
	["robot"] = "",--电脑
	["trust"] = "托管",
	["yes"] = "是",
	["no"] = "否",
	["male"] = "男性",
	["female"] = "女性",
	["neuter"] = "中性",
	["sexless"] = "无性",
	["discardPile"] = "弃牌堆",
	["drawPile"] = "牌堆",
	["drawPileTop"] = "牌堆顶",
	["drawPileEnd"] = "牌堆底",
	["equip_area"] = "装备区",
	["weapon_area"] = "武器栏",
	["armor_area"] = "防具栏",
	["defensive_horse_area"] = "+1坐骑栏",
	["offensive_horse_area"] = "-1坐骑栏",
	["treasure_area"] = "宝物栏",
	["judge_area"] = "判定区",
	["luck_card"] = "手气卡",
	["cheat"] = "作弊",

	["use upon"] = "对",
	["yourself"] = "你",

	["attack_card"] = "进攻牌",
	["defense_card"] = "防御牌",
	["recover_card"] = "恢复牌",
	["global_effect"] = "全局效果",
	["aoe"] = "AOE",
	["single_target_trick"] = "单目标锦囊",
	["multiple_target_trick"] = "多目标锦囊",
	["delayed_trick"] = "延时锦囊",
	["buff_card"] = "辅助伤害",
	["damage_spread"] = "伤害传导",
	["weapon"] = "武器",
	["armor"] = "防具",
	["defensive_horse"] = "+1坐骑",
	["offensive_horse"] = "-1坐骑",
	["treasure"] = "宝物",

	["wei"] = "魏",
	["shu"] = "蜀",
	["wu"] = "吴",
	["qun"] = "群",
	["jin"] = "晋",
	
	["1_num"] = "①",
	["2_num"] = "②",
	["3_num"] = "③",
	["4_num"] = "④",
	["5_num"] = "⑤",
	["6_num"] = "⑥",
	["7_num"] = "⑦",
	["8_num"] = "⑧",
	["9_num"] = "⑨",
	["10_num"] = "⑩",

	["#Murder"] = "%to【%arg】阵亡，伤害来源为 %from",
	["#Suicide"] = "%to【%arg】自杀",
	["#Revive"] = "%from 复活",
	["#InvokeSkill"] = "%from 发动了“%arg”",
	["#InvokeOthersSkill"] = "%from 发动了 %to 的“%arg”",
	["#ChoosePlayerWithSkill"] = "%from 发动了“%arg”，目标是 %to",
	["#TriggerSkill"] = "%from 的“%arg”被触发",
	["#FinishShiMing"] = "%from 完成了使命“%arg”",
	["#ShiMingFailed"] = "%from 的使命“%arg”失败",
	["#TriggerEquipSkill"] = "%from 的装备技能“%arg”被触发",
	["#Pindian"] = "%from 向 %to 发起了拼点",
	["#PindianSuccess"] = "%from (对 %to) 拼点赢！",
	["#PindianFailure"] = "%from (对 %to) 拼点没赢",
	["#Damage"] = "%from 对 %to 造成了 %arg 点伤害[%arg2]",
	["#DamageNoSource"] = "%to 受到了 %arg 点伤害[%arg2]",
	["#Recover"] = "%from 回复了 %arg 点体力",
	["#AskForPeaches"] = "%from 向 %to 求桃，一共需要 %arg 张【<font color=\"yellow\"><b>桃</b></font>】",
	["#ChooseKingdom"] = "%from 选择了 %arg 势力",
	["#NullificationDetails"] = "【<font color=\"yellow\"><b>无懈可击</b></font>】的目标是 %from 对 %to 的锦囊【%arg】",
	["#SkillAvoid"] = "%from 的“%arg”被触发，%from 不能成为此【%arg2】的目标",
	["#NoJudgeAreaAvoid"] = "%from 没有判定区，%from 不能成为此【%arg】的目标",
	["#SkillAvoidFrom"]= "%from 的“%arg”被触发，%to 不能成为此【%arg2】的目标",
	["#CardNullified"] = "【%arg】对 %from 无效",
	["#Transfigure"] = "%from 变身为 %arg",
	["#TransfigureDual"] = "%from 的 %arg2 变身为 %arg",
	["#AcquireSkill"] = "%from 获得了技能“%arg”",
	["#LoseSkill"] = "%from 失去了技能“%arg”",
	["$InitialJudge"] = "%from 的判定牌为 %card",
	["$ChangedJudge"] = "%from 发动“%arg”把 %to 的判定牌改为 %card",
	["$MoveCard"] = "%to 从 %from 处获得 %card",
	["$PasteCard"] = "%from 对 %to 使用延时锦囊 %card",
	["$LightningMove"] = "%card 从 %from 移动到 %to",
	["$TurnOver"] = "%from 展示了牌堆顶的 %card",
	["$ShowEnd"] = "%from 展示了牌堆底的 %card",
	["$DiscardCard"] = "%from 弃置了 %card",
	["$DiscardCardWithSkill"] = "%from 发动“%arg”弃置了 %card",
	["$DiscardCardByOther"] = "%from 弃置了 %to 的卡牌 %card",
	["$EnterDiscardPile"] = "%card 被置入弃牌堆",
	["$MoveToDiscardPile"] = "%from 将 %card 置入弃牌堆",
	["$GotCardBack"] = "%from 收回了 %card",
	["$RecycleCard"] = "%from 从弃牌堆获得了 %card",
	["$Dismantlement"] = "%from 的 %card 被弃置",
	["$ShowCard"] = "%from 展示了 %card",
	["$ShowAllCards"] = "%from 展示了所有手牌 %card",
	["$ViewAllCards"] = "%from 观看了 %to 的所有手牌 %card",
	["#ViewAllCards"] = "%from 观看了 %to 的所有手牌",
	["$ViewDrawPile"] = "%from 观看了牌堆顶的 %card",
	["#ViewDrawPile"] = "%from 观看了牌堆顶的 %arg 张牌",
	["$ViewEndDrawPile"] = "%from 观看了牌堆底的 %card",
	["#ViewEndDrawPile"] = "%from 观看了牌堆底的 %arg 张牌",
	["$JileiShowAllCards"] = "%from 展示了不能弃置的手牌 %card",
	["$PutCard"] = "%from 的 %card 被置于牌堆顶",
	["#PutCard"] = "%from 的 %arg 张牌被置于牌堆顶",
	["$PutCard2"] = "%from 将 %card 置于牌堆顶",
	["$ShuffleCard"] = "%from 将 %card 洗入牌堆",
	["#ShuffleCard"] = "%from 将 %arg 张牌洗入牌堆",
	["$PutCardEnd"] = "%from 的 %card 被置于牌堆底",
	["#PutCardEnd"] = "%from 的 %arg 张牌被置于牌堆底",
	["$PutCardEnd2"] = "%from 将 %card 置于牌堆底",
	["$RecastCard"] = "%from 重铸了 %card",
	["normal_nature"] = "无属性",
	["fire_nature"] = "火属性",
	["thunder_nature"] = "雷属性",
	["ice_nature"] = "冰属性",
	["poison_nature"] = "毒属性",
	["IceDamagePrevent"] = "冰属性伤害弃牌",
	["IceDamagePrevent:IceDamagePrevent_info"] = "你是否防止对 %src 的 %arg 点冰属性伤害，改为依次弃置其两张牌？",
	["#IceDamageEffect"] = "%from 对 %to 发动了%arg伤害的效果",
	["#Contingency"] = "%to【%arg】阵亡，无伤害来源",
	["#DelayedTrick"] = "%from 的延时锦囊【%arg】开始判定",
	["#SkillNullify"] = "%from 的“%arg”被触发，【%arg2】对其无效",
	["#ArmorNullify"] = "%from 的防具【%arg】效果被触发，【%arg2】对其无效",
	["#DrawNCards"] = "%from 摸了 %arg 张牌",
	["$DrawCards"] = "%from 摸了 %arg 张牌 %card",
	["#MoveNCards"] = "%to 从 %from 处得到 %arg 张牌",
	["$TakeAG"] = "%from 获得了 %card",
	["$Install"] = "%from 装备了 %card",
	["$Uninstall"] = "%from 卸载了 %card",
	["$JudgeResult"] = "%from 的判定结果为 %card",
	["$PindianResult"] = "%from 的拼点牌为 %card",
	["#ChooseSuit"] = "%from 选择了花色 %arg",
	["#TurnOver"] = "%from 将武将牌翻面，现在是 %arg",
	["face_up"] = "正面朝上",
	["face_down"] = "背面朝上",
	["#SkipPhase"] = "%from 跳过了 %arg 阶段",
	["#SkipAllPhase"] = "%from 当前回合结束",
	["#IronChainDamage"] = "%from 处于横置状态，将被传导 %arg 点属性伤害",
	["#LoseHp"] = "%from 失去了 %arg 点体力",
	["#LoseMaxHp"] = "%from 失去了 %arg 点体力上限",
	["#GainMaxHp"] = "%from 增加了 %arg 点体力上限",
	["#GetHp"] = "%from 体力值为 %arg ，体力上限为 %arg2",
	["#ChangeKingdom"] = "%from 把 %to 的势力由 %arg 改成了 %arg2",
	["#ChangeKingdom2"] = "%from 将势力由 %arg 改为了 %arg2",
	["#AnalepticBuff"] = "%from 使用【<font color=\"yellow\"><b>酒</b></font>】，对 %to 造成的伤害从 %arg 点增加至 %arg2 点",
	["#GetMark"] = "%from 得到了 %arg2 枚 %arg 标记",
	["#LoseMark"] = "%from 弃置了 %arg2 枚 %arg 标记",
	["#GetHujia"] = "%from 获得了 %arg 点护甲",
	["#LoseHuJia"] = "%from 失去了 %arg 点护甲",
	["$AddToPile"] = "%card 被作为 %arg 牌移出游戏",
	["#RemoveFromGame"] = "%arg2 张牌被作为 %arg 牌移出游戏",
	["$GotCardFromPile"] = "%from 从 %arg 牌中获得 %card",
	["#GotNCardFromPile"] = "%from 从 %arg 牌中获得 %arg2 张牌",
	["#BecomeUser"] = "%from 成为了 %card 的使用者",
	["#BecomeTarget"] = "%from 成为了 %card 的目标",
	["@askforslash"] = "你可以对你攻击范围内的一名角色使用一张【杀】",
	["@askforretrial"] = "请发动“%dest”来修改 %src 的 %arg 判定",
	["$CheatCard"] = "%from 作弊，获得了 %card",
	["#FilterJudge"] = "%from 的“%arg”效果被触发，判定牌被改变",
	["$CancelTarget"] = "%from 使用【%arg】的目标 %to 被取消",
	["$CancelTargetNoUser"] = "【%arg】的目标 %to 被取消",
	["$ViewRole"] = "%from 观看了 %to 的身份 %arg",
	["#UseLuckCard"] = "%from 使用了 <font color=\"yellow\"><b>手气卡</b></font>",
	["#PlayerChained"] = "%from 将武将牌横置",
	["#PlayerNotChained"] = "%from 将武将牌重置",
	["@movefield-from"] = "请选择一名角色，移动其一张牌",
	["@movefield-equip-from"] = "请选择一名角色，移动其装备区里的一张牌",
	["@movefield-judge-from"] = "请选择一名角色，移动其判定区里的一张牌",
	["@movefield-from-optional"] = "你可以选择一名角色，移动其一张牌",
	["@movefield-equip-from-optional"] = "你可以选择一名角色，移动其装备区里的一张牌",
	["@movefield-judge-from-optional"] = "你可以选择一名角色，移动其判定区里的一张牌",
	["@movefield-to"] = "请将 【%src】 移给一名角色",
	["#ThrowArea"] = "%from 废除了 %arg",
	["#ObtainArea"] = "%from 恢复了 %arg",
	["#EndPlayPhase"] = "%from 结束了 %arg 阶段",
	["#BreakYinniState"] = "%from 的武将 %arg 登场",
	["#BreakYinniState2"] = "%from 的武将 %arg/%arg2 登场",
	[":&commonmarktooltip"] = "由%dest标记",
	["#WakeSkillCanWake"] = "%from 的“%arg”效果被触发，“%arg2”视为满足条件",

	["cw"] = "顺时针",
	["ccw"] = "逆时针",
	["@3v3-action"] = "请选择行动角色",
	["warm"] = "暖色方",
	["cool"] = "冷色方",
	["#VsTakeGeneral"] = "%arg 选择了 %arg2",
	["#TrickDirection"] = "%from 选择了 %arg 作为结算顺序",
	["custom"] = "自定义模式",
	["UnknowNick"] = "",
	["DefaultIllustrator"] = "KayaK",
	["hulaopass_shenlvbu"] = "选择第二阶段形态",
	["hulaopass_shenlvbu:bnzs"] = "暴怒战神",
	["hulaopass_shenlvbu:sgwq"] = "神鬼无前",

	["@waked"] = "觉醒",

	["CAPITAL(1)"] = "一",
	["CAPITAL(2)"] = "二",
	["CAPITAL(3)"] = "三",
	["CAPITAL(4)"] = "四",
	["CAPITAL(5)"] = "五",
	["CAPITAL(6)"] = "六",
	["CAPITAL(7)"] = "七",
	["CAPITAL(8)"] = "八",
	["CAPITAL(9)"] = "九",
	["CAPITAL(10)"] = "十",
}

return CommonTranslationTable