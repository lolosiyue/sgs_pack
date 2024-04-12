extension = sgs.Package("mojiang", sgs.Package_GeneralPack)

sgs.LoadTranslationTable{
	["mojiang"] = "魔武将",
}


--魔孙皓
mo_sunhao = sgs.General(extension, "mo_sunhao", "sy_god", 3, true)


mo_sunhao:addSkill("sy_mingzheng")
mo_sunhao:addRelateSkill("sy_shisha")
mo_sunhao:addSkill("sy_huangyin")
mo_sunhao:addSkill("sy_zuijiu")
mo_sunhao:addSkill("sy_guiming")


sgs.LoadTranslationTable{
    ["mo_sunhao"] = "魔孙皓",
	["#mo_sunhao"] = "末世暴君",
	["~mo_sunhao"] = "乱臣贼子，不得好死！",
}


--魔司马懿
mo_simayi = sgs.General(extension, "mo_simayi", "sy_god", 3, true)


mo_simayi:addSkill("sy_bolue")
mo_simayi:addSkill("sy_renji")
mo_simayi:addSkill("sy_biantian")
mo_simayi:addSkill("sy_tianyou")


sgs.LoadTranslationTable{
    ["mo_simayi"] = "魔司马懿",
	["#mo_simayi"] = "三分归晋",
	["~mo_simayi"] = "呃哦……呃啊……",
}


--魔张角
mo_zhangjiao = sgs.General(extension, "mo_zhangjiao", "sy_god", 3, true)


mo_zhangjiao:addSkill("sy_bujiao")
mo_zhangjiao:addSkill("sy_taiping")
mo_zhangjiao:addSkill("sy_yaohuo")
mo_zhangjiao:addSkill("sy_sanzhi")


sgs.LoadTranslationTable{
    ["mo_zhangjiao"] = "魔张角",
	["#mo_zhangjiao"] = "大贤良师",
	["~mo_zhangjiao"] = "逆道者，必遭天谴而亡！",
}


--魔董卓
mo_dongzhuo = sgs.General(extension, "mo_dongzhuo", "sy_god", 3, true)


mo_dongzhuo:addSkill("sy_zongyu")
mo_dongzhuo:addSkill("sy_lingnue")
mo_dongzhuo:addSkill("sy_baozheng")
mo_dongzhuo:addSkill("sy_nishi")
mo_dongzhuo:addSkill("sy_hengxing")


sgs.LoadTranslationTable{
    ["mo_dongzhuo"] = "魔董卓",
	["#mo_dongzhuo"] = "狱魔王",
	["~mo_dongzhuo"] = "那酒池肉林……都是我的……",
}


--魔魏延
mo_weiyan = sgs.General(extension, "mo_weiyan", "sy_god", 3, true)


mo_weiyan:addSkill("sy_shiao")
mo_weiyan:addSkill("sy_fangu")
mo_weiyan:addSkill("sy_kuangxi")


sgs.LoadTranslationTable{
    ["mo_weiyan"] = "魔魏延",
	["#mo_weiyan"] = "嗜血狂狼",
	["~mo_weiyan"] = "这就是老子追求的东西吗？",
}


--魔张让
mo_zhangrang = sgs.General(extension, "mo_zhangrang", "sy_god", 3, true)


mo_zhangrang:addSkill("sy_chanxian")
mo_zhangrang:addSkill("sy_luanzheng")
mo_zhangrang:addSkill("sy_canlue")


sgs.LoadTranslationTable{
    ["mo_zhangrang"] = "魔张让",
	["#mo_zhangrang"] = "祸乱之源",
	["~mo_zhangrang"] = "小的怕是活不成了，陛下，保重……",
}


--魔蔡夫人
mo_caifuren = sgs.General(extension, "mo_caifuren", "sy_god", 3, false)


mo_caifuren:addSkill("sy_dihui")
mo_caifuren:addSkill("sy_luansi")
mo_caifuren:addSkill("sy_huoxin")


sgs.LoadTranslationTable{
    ["mo_caifuren"] = "魔蔡夫人",
	["#mo_caifuren"] = "蛇蝎美人",
	["~mo_caifuren"] = "做鬼也不会放过你的！",
}


--魔吕布
mo_lvbu = sgs.General(extension, "mo_lvbu", "sy_god", 3, true)


mo_lvbu:addSkill("sy_wushuang")
mo_lvbu:addSkill("mashu")
mo_lvbu:addSkill("sy_xiuluo")
mo_lvbu:addSkill("sy_shenwei")
mo_lvbu:addSkill("sy_shenji")
mo_lvbu:addSkill("#sy_shenji")


sgs.LoadTranslationTable{
    ["mo_lvbu"] = "魔吕布",
	["#mo_lvbu"] = "最强神话",
	["~mo_lvbu"] = "我在地狱等着你们！",
}


--魔袁绍
mo_yuanshao = sgs.General(extension, "mo_yuanshao", "sy_god", 3, true)


mo_yuanshao:addSkill("sy_mojian")
mo_yuanshao:addSkill("sy_zhuzai")
mo_yuanshao:addSkill("sy_duoji")


sgs.LoadTranslationTable{
    ["mo_yuanshao"] = "魔袁绍",
	["#mo_yuanshao"] = "魔君",
	["~mo_yuanshao"] = "我不甘心！我不甘心啊！",
}

return {extension}