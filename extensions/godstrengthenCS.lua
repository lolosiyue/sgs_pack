--更换皮肤功能：十二神将+两位神秘武将
extension = sgs.Package("godstrengthenCS", sgs.Package_GeneralPack)
GOD_changeFullSkin = sgs.CreateTriggerSkill{
    name = "GOD_changeFullSkin",
	global = true,
	priority = 8,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		--神关羽
		if player:getGeneralName() == "shenguanyu" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "sgy_hzfj+sgy_lygh+sgy_yzfw")
			if choice == "sgy_hzfj" then
				room:changeHero(player, "shenguanyu_extra1", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "sgy_lygh" then
				room:changeHero(player, "shenguanyu_extra2", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "sgy_yzfw" then
				room:changeHero(player, "shenguanyu_extra3", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		if player:getGeneral2Name() == "shenguanyu" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "sgy_hzfj+sgy_lygh+sgy_yzfw")
			if choice == "sgy_hzfj" then
				room:changeHero(player, "shenguanyu_extra1", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "sgy_lygh" then
				room:changeHero(player, "shenguanyu_extra2", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "sgy_yzfw" then
				room:changeHero(player, "shenguanyu_extra3", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		--OL神关羽
		if player:getGeneralName() == "ol_shenguanyu" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "olshenguanyu_extra", false, true, false, false)
			if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
		end
		if player:getGeneral2Name() == "ol_shenguanyu" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "olshenguanyu_extra", false, true, true, false)
			if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
		end
		--神吕蒙
		if player:getGeneralName() == "shenlvmeng" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "slm_bydj+slm_fscm+slm_jzww")
			if choice == "slm_bydj" then
				room:changeHero(player, "shenlvmeng_extra1", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slm_fscm" then
				room:changeHero(player, "shenlvmeng_extra2", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slm_jzww" then
				room:changeHero(player, "shenlvmeng_extra3", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		if player:getGeneral2Name() == "shenlvmeng" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "slm_bydj+slm_fscm+slm_jzww")
			if choice == "slm_bydj" then
				room:changeHero(player, "shenlvmeng_extra1", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slm_fscm" then
				room:changeHero(player, "shenlvmeng_extra2", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slm_jzww" then
				room:changeHero(player, "shenlvmeng_extra3", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		--神周瑜
		if player:getGeneralName() == "shenzhouyu" and room:askForSkillInvoke(player, self:objectName(), data) then
			for _, szgl in sgs.qlist(room:getAllPlayers()) do
				if (szgl:getGeneralName() == "shenzhugeliang" or szgl:getGeneral2Name() == "shenzhugeliang")
				or (szgl:getGeneralName() == "shenzhugeliang_extra1" or szgl:getGeneral2Name() == "shenzhugeliang_extra1")
				or (szgl:getGeneralName() == "shenzhugeliang_extra2" or szgl:getGeneral2Name() == "shenzhugeliang_extra2")
				or (szgl:getGeneralName() == "shenzhugeliang_extra3" or szgl:getGeneral2Name() == "shenzhugeliang_extra3")
				or (szgl:getGeneralName() == "shenzhugeliang_extra4" or szgl:getGeneral2Name() == "shenzhugeliang_extra4")
				or (szgl:getGeneralName() == "shenzhugeliang_extra5" or szgl:getGeneral2Name() == "shenzhugeliang_extra5")
				or (szgl:getGeneralName() == "shenzhugeliang_extra6" or szgl:getGeneral2Name() == "shenzhugeliang_extra6") then
					room:setPlayerFlag(player, "szy_ytql")
					break
				end
			end
			local choices = {}
			table.insert(choices, "wxxcx")
			table.insert(choices, "szy_hlyh")
			table.insert(choices, "szy_qynn")
			table.insert(choices, "szy_lgyl")
			if player:hasFlag("szy_ytql") then
				table.insert(choices, "szy_ytql")
			end
			table.insert(choices, "szy_hzpc")
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			if choice == "wxxcx" then
				room:changeHero(player, "shenzhouyu_extra1", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szy_hlyh" then
				room:changeHero(player, "shenzhouyu_extra1", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szy_qynn" then
				room:changeHero(player, "shenzhouyu_extra2", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szy_lgyl" then
				room:changeHero(player, "shenzhouyu_extra3", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szy_ytql" then
				room:changeHero(player, "shenzhouyu_extra4", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szy_hzpc" then
				room:changeHero(player, "shenzhouyu_extra5", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		if player:getGeneral2Name() == "shenzhouyu" and room:askForSkillInvoke(player, self:objectName(), data) then
			for _, szgl in sgs.qlist(room:getAllPlayers()) do
				if (szgl:getGeneralName() == "shenzhugeliang" or szgl:getGeneral2Name() == "shenzhugeliang")
				or (szgl:getGeneralName() == "shenzhugeliang_extra1" or szgl:getGeneral2Name() == "shenzhugeliang_extra1")
				or (szgl:getGeneralName() == "shenzhugeliang_extra2" or szgl:getGeneral2Name() == "shenzhugeliang_extra2")
				or (szgl:getGeneralName() == "shenzhugeliang_extra3" or szgl:getGeneral2Name() == "shenzhugeliang_extra3")
				or (szgl:getGeneralName() == "shenzhugeliang_extra4" or szgl:getGeneral2Name() == "shenzhugeliang_extra4")
				or (szgl:getGeneralName() == "shenzhugeliang_extra5" or szgl:getGeneral2Name() == "shenzhugeliang_extra5")
				or (szgl:getGeneralName() == "shenzhugeliang_extra6" or szgl:getGeneral2Name() == "shenzhugeliang_extra6") then
					room:setPlayerFlag(player, "szy_ytql")
					break
				end
			end
			local choices = {}
			table.insert(choices, "wxxcx")
			table.insert(choices, "szy_hlyh")
			table.insert(choices, "szy_qynn")
			table.insert(choices, "szy_lgyl")
			if player:hasFlag("szy_ytql") then
				table.insert(choices, "szy_ytql")
			end
			table.insert(choices, "szy_hzpc")
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			if choice == "wxxcx" then
				room:changeHero(player, "shenzhouyu_extra1", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szy_hlyh" then
				room:changeHero(player, "shenzhouyu_extra1", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szy_qynn" then
				room:changeHero(player, "shenzhouyu_extra2", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szy_lgyl" then
				room:changeHero(player, "shenzhouyu_extra3", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szy_ytql" then
				room:changeHero(player, "shenzhouyu_extra4", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szy_hzpc" then
				room:changeHero(player, "shenzhouyu_extra5", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		--神诸葛亮
		if player:getGeneralName() == "shenzhugeliang" and room:askForSkillInvoke(player, self:objectName(), data) then
			for _, szy in sgs.qlist(room:getAllPlayers()) do
				if (szy:getGeneralName() == "shenzhouyu" or szy:getGeneral2Name() == "shenzhouyu")
				or (szy:getGeneralName() == "shenzhouyu_wx" or szy:getGeneral2Name() == "shenzhouyu_wx")
				or (szy:getGeneralName() == "shenzhouyu_extra1" or szy:getGeneral2Name() == "shenzhouyu_extra1")
				or (szy:getGeneralName() == "shenzhouyu_extra2" or szy:getGeneral2Name() == "shenzhouyu_extra2")
				or (szy:getGeneralName() == "shenzhouyu_extra3" or szy:getGeneral2Name() == "shenzhouyu_extra3")
				or (szy:getGeneralName() == "shenzhouyu_extra4" or szy:getGeneral2Name() == "shenzhouyu_extra4")
				or (szy:getGeneralName() == "shenzhouyu_extra5" or szy:getGeneral2Name() == "shenzhouyu_extra5") then
					room:setPlayerFlag(player, "szgl_fwmn")
					break
				end
			end
			local choices = {}
			table.insert(choices, "szgl_gxhy")
			table.insert(choices, "szgl_cbhf")
			table.insert(choices, "szgl_mzzx")
			if player:hasFlag("szgl_fwmn") then
				table.insert(choices, "szgl_fwmn")
			end
			table.insert(choices, "szgl_jjtt")
			table.insert(choices, "szgl_hzpc")
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			if choice == "szgl_gxhy" then
				room:changeHero(player, "shenzhugeliang_extra1", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szgl_cbhf" then
				room:changeHero(player, "shenzhugeliang_extra2", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szgl_mzzx" then
				room:changeHero(player, "shenzhugeliang_extra3", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szgl_fwmn" then
				room:changeHero(player, "shenzhugeliang_extra4", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szgl_jjtt" then
				room:changeHero(player, "shenzhugeliang_extra5", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szgl_hzpc" then
				room:changeHero(player, "shenzhugeliang_extra6", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		if player:getGeneral2Name() == "shenzhugeliang" and room:askForSkillInvoke(player, self:objectName(), data) then
			for _, szy in sgs.qlist(room:getAllPlayers()) do
				if (szy:getGeneralName() == "shenzhouyu" or szy:getGeneral2Name() == "shenzhouyu")
				or (szy:getGeneralName() == "shenzhouyu_wx" or szy:getGeneral2Name() == "shenzhouyu_wx")
				or (szy:getGeneralName() == "shenzhouyu_extra1" or szy:getGeneral2Name() == "shenzhouyu_extra1")
				or (szy:getGeneralName() == "shenzhouyu_extra2" or szy:getGeneral2Name() == "shenzhouyu_extra2")
				or (szy:getGeneralName() == "shenzhouyu_extra3" or szy:getGeneral2Name() == "shenzhouyu_extra3")
				or (szy:getGeneralName() == "shenzhouyu_extra4" or szy:getGeneral2Name() == "shenzhouyu_extra4")
				or (szy:getGeneralName() == "shenzhouyu_extra5" or szy:getGeneral2Name() == "shenzhouyu_extra5") then
					room:setPlayerFlag(player, "szgl_fwmn")
					break
				end
			end
			local choices = {}
			table.insert(choices, "szgl_gxhy")
			table.insert(choices, "szgl_cbhf")
			table.insert(choices, "szgl_mzzx")
			if player:hasFlag("szgl_fwmn") then
				table.insert(choices, "szgl_fwmn")
			end
			table.insert(choices, "szgl_jjtt")
			table.insert(choices, "szgl_hzpc")
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			if choice == "szgl_gxhy" then
				room:changeHero(player, "shenzhugeliang_extra1", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szgl_cbhf" then
				room:changeHero(player, "shenzhugeliang_extra2", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szgl_mzzx" then
				room:changeHero(player, "shenzhugeliang_extra3", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szgl_fwmn" then
				room:changeHero(player, "shenzhugeliang_extra4", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szgl_jjtt" then
				room:changeHero(player, "shenzhugeliang_extra5", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szgl_hzpc" then
				room:changeHero(player, "shenzhugeliang_extra6", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		--神曹操
		if player:getGeneralName() == "shencaocao" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "shencaocao_extra", false, true, false, false)
			if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
		end
		if player:getGeneral2Name() == "shencaocao" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "shencaocao_extra", false, true, true, false)
			if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
		end
		--端游神曹操
		if player:getGeneralName() == "new_shencaocao" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "pcscc_ytjs+pcscc_lyxh")
			if choice == "pcscc_ytjs" then
				room:changeHero(player, "pcshencaocao_extra1", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			else
				room:changeHero(player, "pcshencaocao_extra2", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		if player:getGeneral2Name() == "new_shencaocao" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "pcscc_ytjs+pcscc_lyxh")
			if choice == "pcscc_ytjs" then
				room:changeHero(player, "pcshencaocao_extra1", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			else
				room:changeHero(player, "pcshencaocao_extra2", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		--神吕布
		if player:getGeneralName() == "shenlvbu" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "slb_gjtx+slb_zsjg+slb_nzhd+slb_jbsm+slb_sftw+slb_lhft+slb_gsws")
			if choice == "slb_gjtx" then
				room:changeHero(player, "shenlvbu_extra1", false, false, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_zsjg" then
				room:changeHero(player, "shenlvbu_extra2", false, false, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_nzhd" then
				room:changeHero(player, "shenlvbu_extra3", false, false, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_jbsm" then
				room:changeHero(player, "shenlvbu_extra4", false, false, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_sftw" then
				room:changeHero(player, "shenlvbu_extra5", false, false, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_lhft" then
				room:changeHero(player, "shenlvbu_extra6", false, false, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_gsws" then
				room:changeHero(player, "shenlvbu_extra7", false, false, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		if player:getGeneral2Name() == "shenlvbu" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "slb_gjtx+slb_zsjg+slb_nzhd+slb_jbsm+slb_sftw+slb_lhft+slb_gsws")
			if choice == "slb_gjtx" then
				room:changeHero(player, "shenlvbu_extra1", false, false, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_zsjg" then
				room:changeHero(player, "shenlvbu_extra2", false, false, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_nzhd" then
				room:changeHero(player, "shenlvbu_extra3", false, false, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_jbsm" then
				room:changeHero(player, "shenlvbu_extra4", false, false, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_sftw" then
				room:changeHero(player, "shenlvbu_extra5", false, false, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_lhft" then
				room:changeHero(player, "shenlvbu_extra6", false, false, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_gsws" then
				room:changeHero(player, "shenlvbu_extra7", false, false, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		--神赵云
		if player:getGeneralName() == "shenzhaoyun" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "shenzhaoyun_extra", false, true, false, false)
			if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
		end
		if player:getGeneral2Name() == "shenzhaoyun" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "shenzhaoyun_extra", false, true, true, false)
			if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
		end
		--新神赵云
		if player:getGeneralName() == "new_shenzhaoyun" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "nszy_zlzy+nszy_slyz+nszy_gzbq+nszy_gdjz+nszy_ylzt+nszy_jwwy")
			if choice == "nszy_zlzy" then
				room:changeHero(player, "newshenzhaoyun_extra1", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "nszy_slyz" then
				room:changeHero(player, "newshenzhaoyun_extra2", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "nszy_gzbq" then
				room:changeHero(player, "newshenzhaoyun_extra3", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "nszy_gdjz" then
				room:changeHero(player, "newshenzhaoyun_extra4", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "nszy_ylzt" then
				room:changeHero(player, "newshenzhaoyun_extra5", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "nszy_jwwy" then
				room:changeHero(player, "newshenzhaoyun_extra6", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		if player:getGeneral2Name() == "new_shenzhaoyun" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "nszy_zlzy+nszy_slyz+nszy_gzbq+nszy_gdjz+nszy_ylzt+nszy_jwwy")
			if choice == "nszy_zlzy" then
				room:changeHero(player, "newshenzhaoyun_extra1", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "nszy_slyz" then
				room:changeHero(player, "newshenzhaoyun_extra2", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "nszy_gzbq" then
				room:changeHero(player, "newshenzhaoyun_extra3", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "nszy_gdjz" then
				room:changeHero(player, "newshenzhaoyun_extra4", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "nszy_ylzt" then
				room:changeHero(player, "newshenzhaoyun_extra5", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "nszy_jwwy" then
				room:changeHero(player, "newshenzhaoyun_extra6", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		--神司马懿
		if player:getGeneralName() == "shensimayi" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "ssmy_jwzl+ssmy_sltw+ssmy_kqcw")
			if choice == "ssmy_jwzl" then
				room:changeHero(player, "shensimayi_extra1", false, false, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "ssmy_sltw" then
				room:changeHero(player, "shensimayi_extra2", false, false, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "ssmy_kqcw" then
				room:changeHero(player, "shensimayi_extra3", false, false, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		if player:getGeneral2Name() == "shensimayi" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "ssmy_jwzl+ssmy_sltw+ssmy_kqcw")
			if choice == "ssmy_jwzl" then
				room:changeHero(player, "shensimayi_extra1", false, false, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "ssmy_sltw" then
				room:changeHero(player, "shensimayi_extra2", false, false, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "ssmy_kqcw" then
				room:changeHero(player, "shensimayi_extra3", false, false, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		--神刘备
		if player:getGeneralName() == "shenliubei" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "slb_zlnh+slb_nhfc+slb_lxhn+slb_dwzz")
			if choice == "slb_zlnh" then
				room:changeHero(player, "shenliubei_extra1", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_nhfc" then
				room:changeHero(player, "shenliubei_extra2", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_lxhn" then
				room:changeHero(player, "shenliubei_extra3", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_dwzz" then
				room:changeHero(player, "shenliubei_extra4", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		if player:getGeneral2Name() == "shenliubei" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "slb_zlnh+slb_nhfc+slb_lxhn+slb_dwzz")
			if choice == "slb_zlnh" then
				room:changeHero(player, "shenliubei_extra1", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_nhfc" then
				room:changeHero(player, "shenliubei_extra2", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_lxhn" then
				room:changeHero(player, "shenliubei_extra3", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slb_dwzz" then
				room:changeHero(player, "shenliubei_extra4", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		--神陆逊
		if player:getGeneralName() == "shenluxun" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "slx_zyck+slx_ylps+slx_ltfh+slx_zhfw")
			if choice == "slx_zyck" then
				room:changeHero(player, "shenluxun_extra1", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slx_ylps" then
				room:changeHero(player, "shenluxun_extra2", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slx_ltfh" then
				room:changeHero(player, "shenluxun_extra3", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slx_zhfw" then
				room:changeHero(player, "shenluxun_extra4", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		if player:getGeneral2Name() == "shenluxun" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "slx_zyck+slx_ylps+slx_ltfh+slx_zhfw")
			if choice == "slx_zyck" then
				room:changeHero(player, "shenluxun_extra1", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slx_ylps" then
				room:changeHero(player, "shenluxun_extra2", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slx_ltfh" then
				room:changeHero(player, "shenluxun_extra3", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "slx_zhfw" then
				room:changeHero(player, "shenluxun_extra4", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		--神张辽
		if player:getGeneralName() == "shenzhangliao" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "szl_ztjs+szl_pldk+szl_drys")
			if choice == "szl_ztjs" then
				room:changeHero(player, "shenzhangliao_extra1", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szl_pldk" then
				room:changeHero(player, "shenzhangliao_extra2", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szl_drys" then
				room:changeHero(player, "shenzhangliao_extra3", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		if player:getGeneral2Name() == "shenzhangliao" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "szl_ztjs+szl_pldk+szl_drys")
			if choice == "szl_ztjs" then
				room:changeHero(player, "shenzhangliao_extra1", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szl_pldk" then
				room:changeHero(player, "shenzhangliao_extra2", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "szl_drys" then
				room:changeHero(player, "shenzhangliao_extra3", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		--OL神张辽
		if player:getGeneralName() == "ol_shenzhangliao" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "olshenzhangliao_extra", false, true, false, false)
			if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
		end
		if player:getGeneral2Name() == "ol_shenzhangliao" and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "olshenzhangliao_extra", false, true, true, false)
			if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
		end
		--神甘宁
		if player:getGeneralName() == "shenganning" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "dagui_wrby+dagui_swrm+dagui_syft+dagui_fyys+dagui_ywsh")
			if choice == "dagui_wrby" then
				room:changeHero(player, "dagui_1", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "dagui_swrm" then
				room:changeHero(player, "dagui_2", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "dagui_syft" then
				room:changeHero(player, "dagui_3", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "dagui_fyys" then
				room:changeHero(player, "dagui_4", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "dagui_ywsh" then
				room:changeHero(player, "dagui_5", false, true, false, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		if player:getGeneral2Name() == "shenganning" and room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "dagui_wrby+dagui_swrm+dagui_syft+dagui_fyys+dagui_ywsh")
			if choice == "dagui_wrby" then
				room:changeHero(player, "dagui_1", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "dagui_swrm" then
				room:changeHero(player, "dagui_2", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "dagui_syft" then
				room:changeHero(player, "dagui_3", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "dagui_fyys" then
				room:changeHero(player, "dagui_4", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			elseif choice == "dagui_ywsh" then
				room:changeHero(player, "dagui_5", false, true, true, false)
				if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
			end
		end
		----
		if player:getGeneralName() == "shenguanyu" or player:getGeneralName() == "ol_shenguanyu" or player:getGeneralName() == "shenlvmeng" or player:getGeneralName() == "shenzhouyu"
		or player:getGeneralName() == "shenzhugeliang" or player:getGeneralName() == "shencaocao" or player:getGeneralName() == "new_shencaocao" or player:getGeneralName() == "shenlvbu"
		or player:getGeneralName() == "shenzhaoyun" or player:getGeneralName() == "new_shenzhaoyun" or player:getGeneralName() == "shensimayi" or player:getGeneralName() == "shenliubei"
		or player:getGeneralName() == "shenluxun" or player:getGeneralName() == "shenzhangliao" or player:getGeneralName() == "ol_shenzhangliao" or player:getGeneralName() == "shenganning"
		or player:getGeneral2Name() == "shenguanyu" or player:getGeneral2Name() == "ol_shenguanyu" or player:getGeneral2Name() == "shenlvmeng" or player:getGeneral2Name() == "shenzhouyu"
		or player:getGeneral2Name() == "shenzhugeliang" or player:getGeneral2Name() == "shencaocao" or player:getGeneral2Name() == "new_shencaocao" or player:getGeneral2Name() == "shenlvbu"
		or player:getGeneral2Name() == "shenzhaoyun" or player:getGeneral2Name() == "new_shenzhaoyun" or player:getGeneral2Name() == "shensimayi" or player:getGeneral2Name() == "shenliubei"
		or player:getGeneral2Name() == "shenluxun" or player:getGeneral2Name() == "shenzhangliao" or player:getGeneral2Name() == "ol_shenzhangliao" or player:getGeneral2Name() == "shenganning" then
			if not player:hasSkill("GOD_changeFullSkin_Button") then room:attachSkillToPlayer(player, "GOD_changeFullSkin_Button") end
		end
		--==彩蛋角色(仅可于游戏开始时更换)==--
		--手杀界徐盛
		if player:getGeneralName() == "mobile_xusheng" and player:hasSkill("bahu") and room:askForSkillInvoke(player, self:objectName(), data) then
			room:changeHero(player, "dabao", false, true, false, false)
		end
		--卧龙凤雏
		if player:getGeneralName() == "wolongfengchu" and math.random() > 0.5 then
			room:changeHero(player, "wlfc_mini", false, true, false, false)
		end
		if player:getGeneral2Name() == "wolongfengchu" and math.random() > 0.5 then
			room:changeHero(player, "wlfc_mini", false, true, true, false)
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("GOD_changeFullSkin") then skills:append(GOD_changeFullSkin) end
--[[GOD_changeFullSkin_repair = sgs.CreateTriggerSkill{
    name = "GOD_changeFullSkin_repair",
	global = true,
	priority = 7,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		if player:getGeneralName() == "shenlvbu_extra1" or player:getGeneral2Name() == "shenlvbu_extra1"
		or player:getGeneralName() == "shenlvbu_extra2" or player:getGeneral2Name() == "shenlvbu_extra2"
		or player:getGeneralName() == "shenlvbu_extra3" or player:getGeneral2Name() == "shenlvbu_extra3"
		or player:getGeneralName() == "shenlvbu_extra4" or player:getGeneral2Name() == "shenlvbu_extra4"
		or player:getGeneralName() == "shenlvbu_extra5" or player:getGeneral2Name() == "shenlvbu_extra5"
		or player:getGeneralName() == "shenlvbu_extra6" or player:getGeneral2Name() == "shenlvbu_extra6" then
		    local x = player:getMark("&wrath")
			room:removePlayerMark(player, "&wrath", x/2 + 1)
		end
		if player:getGeneralName() == "shensimayi_extra1" or player:getGeneral2Name() == "shensimayi_extra1"
		or player:getGeneralName() == "shensimayi_extra2" or player:getGeneral2Name() == "shensimayi_extra2"
		or player:getGeneralName() == "shensimayi_extra3" or player:getGeneral2Name() == "shensimayi_extra3" then
		    local x = player:getMark("&bear")
			room:removePlayerMark(player, "&bear", x/2)
		end
	end,
	can_trigger = function(self, player)
	    return player
	end,
}]]
--if not sgs.Sanguosha:getSkill("GOD_changeFullSkin_repair") then skills:append(GOD_changeFullSkin_repair) end
--皮肤池--
shenguanyu_extra1 = sgs.General(extension, "shenguanyu_extra1", "god", 5, true, true, true)
shenguanyu_extra1:addSkill("wushen")
shenguanyu_extra1:addSkill("wuhun")
shenguanyu_extra2 = sgs.General(extension, "shenguanyu_extra2", "god", 5, true, true, true)
shenguanyu_extra2:addSkill("wushen")
shenguanyu_extra2:addSkill("wuhun")
shenguanyu_extra3 = sgs.General(extension, "shenguanyu_extra3", "god", 5, true, true, true)
shenguanyu_extra3:addSkill("wushen")
shenguanyu_extra3:addSkill("wuhun")

olshenguanyu_extra = sgs.General(extension, "olshenguanyu_extra", "god", 5, true, true, true)
olshenguanyu_extra:addSkill("olwushen")
olshenguanyu_extra:addSkill("wuhun")

shenlvmeng_extra1 = sgs.General(extension, "shenlvmeng_extra1", "god", 3, true, true, true)
shenlvmeng_extra1:addSkill("shelie")
shenlvmeng_extra1:addSkill("gongxin")
shenlvmeng_extra2 = sgs.General(extension, "shenlvmeng_extra2", "god", 3, true, true, true)
shenlvmeng_extra2:addSkill("shelie")
shenlvmeng_extra2:addSkill("gongxin")
shenlvmeng_extra3 = sgs.General(extension, "shenlvmeng_extra3", "god", 3, true, true, true)
shenlvmeng_extra3:addSkill("shelie")
shenlvmeng_extra3:addSkill("gongxin")

shenzhouyu_wx = sgs.General(extension, "shenzhouyu_wx", "god", 4, true, true, true)
shenzhouyu_wx:addSkill("qinyin")
shenzhouyu_wx:addSkill("yeyan")
shenzhouyu_extra1 = sgs.General(extension, "shenzhouyu_extra1", "god", 4, true, true, true)
shenzhouyu_extra1:addSkill("qinyin")
shenzhouyu_extra1:addSkill("yeyan")
shenzhouyu_extra2 = sgs.General(extension, "shenzhouyu_extra2", "god", 4, true, true, true)
shenzhouyu_extra2:addSkill("qinyin")
shenzhouyu_extra2:addSkill("yeyan")
shenzhouyu_extra3 = sgs.General(extension, "shenzhouyu_extra3", "god", 4, true, true, true)
shenzhouyu_extra3:addSkill("qinyin")
shenzhouyu_extra3:addSkill("yeyan")
shenzhouyu_extra4 = sgs.General(extension, "shenzhouyu_extra4", "god", 4, true, true, true)
shenzhouyu_extra4:addSkill("qinyin")
shenzhouyu_extra4:addSkill("yeyan")
shenzhouyu_extra5 = sgs.General(extension, "shenzhouyu_extra5", "god", 4, true, true, true)
shenzhouyu_extra5:addSkill("qinyin")
shenzhouyu_extra5:addSkill("yeyan")

shenzhugeliang_extra1 = sgs.General(extension, "shenzhugeliang_extra1", "god", 3, true, true, true)
shenzhugeliang_extra1:addSkill("qixing")
shenzhugeliang_extra1:addSkill("kuangfeng")
shenzhugeliang_extra1:addSkill("dawu")
shenzhugeliang_extra2 = sgs.General(extension, "shenzhugeliang_extra2", "god", 3, true, true, true)
shenzhugeliang_extra2:addSkill("qixing")
shenzhugeliang_extra2:addSkill("kuangfeng")
shenzhugeliang_extra2:addSkill("dawu")
shenzhugeliang_extra3 = sgs.General(extension, "shenzhugeliang_extra3", "god", 3, true, true, true)
shenzhugeliang_extra3:addSkill("qixing")
shenzhugeliang_extra3:addSkill("kuangfeng")
shenzhugeliang_extra3:addSkill("dawu")
shenzhugeliang_extra4 = sgs.General(extension, "shenzhugeliang_extra4", "god", 3, true, true, true)
shenzhugeliang_extra4:addSkill("qixing")
shenzhugeliang_extra4:addSkill("kuangfeng")
shenzhugeliang_extra4:addSkill("dawu")
shenzhugeliang_extra5 = sgs.General(extension, "shenzhugeliang_extra5", "god", 3, true, true, true)
shenzhugeliang_extra5:addSkill("qixing")
shenzhugeliang_extra5:addSkill("kuangfeng")
shenzhugeliang_extra5:addSkill("dawu")
shenzhugeliang_extra6 = sgs.General(extension, "shenzhugeliang_extra6", "god", 3, true, true, true)
shenzhugeliang_extra6:addSkill("qixing")
shenzhugeliang_extra6:addSkill("kuangfeng")
shenzhugeliang_extra6:addSkill("dawu")

shencaocao_extra = sgs.General(extension, "shencaocao_extra", "god", 3, true, true, true)
shencaocao_extra:addSkill("guixin")
shencaocao_extra:addSkill("feiying")

pcshencaocao_extra1 = sgs.General(extension, "pcshencaocao_extra1", "god", 3, true, true, true)
pcshencaocao_extra1:addSkill("newguixin")
pcshencaocao_extra1:addSkill("feiying")
pcshencaocao_extra2 = sgs.General(extension, "pcshencaocao_extra2", "god", 3, true, true, true)
pcshencaocao_extra2:addSkill("newguixin")
pcshencaocao_extra2:addSkill("feiying")

shenlvbu_extra1 = sgs.General(extension, "shenlvbu_extra1", "god", 5, true, true, true)
shenlvbu_extra1:addSkill("kuangbao")
shenlvbu_extra1:addSkill("wumou")
shenlvbu_extra1:addSkill("wuqian")
shenlvbu_extra1:addSkill("shenfen")
shenlvbu_extra2 = sgs.General(extension, "shenlvbu_extra2", "god", 5, true, true, true)
shenlvbu_extra2:addSkill("kuangbao")
shenlvbu_extra2:addSkill("wumou")
shenlvbu_extra2:addSkill("wuqian")
shenlvbu_extra2:addSkill("shenfen")
shenlvbu_extra3 = sgs.General(extension, "shenlvbu_extra3", "god", 5, true, true, true)
shenlvbu_extra3:addSkill("kuangbao")
shenlvbu_extra3:addSkill("wumou")
shenlvbu_extra3:addSkill("wuqian")
shenlvbu_extra3:addSkill("shenfen")
shenlvbu_extra4 = sgs.General(extension, "shenlvbu_extra4", "god", 5, true, true, true)
shenlvbu_extra4:addSkill("kuangbao")
shenlvbu_extra4:addSkill("wumou")
shenlvbu_extra4:addSkill("wuqian")
shenlvbu_extra4:addSkill("shenfen")
shenlvbu_extra5 = sgs.General(extension, "shenlvbu_extra5", "god", 5, true, true, true)
shenlvbu_extra5:addSkill("kuangbao")
shenlvbu_extra5:addSkill("wumou")
shenlvbu_extra5:addSkill("wuqian")
shenlvbu_extra5:addSkill("shenfen")
shenlvbu_extra6 = sgs.General(extension, "shenlvbu_extra6", "god", 5, true, true, true)
shenlvbu_extra6:addSkill("kuangbao")
shenlvbu_extra6:addSkill("wumou")
shenlvbu_extra6:addSkill("wuqian")
shenlvbu_extra6:addSkill("shenfen")
shenlvbu_extra7 = sgs.General(extension, "shenlvbu_extra7", "god", 5, true, true, true)
shenlvbu_extra7:addSkill("kuangbao")
shenlvbu_extra7:addSkill("wumou")
shenlvbu_extra7:addSkill("wuqian")
shenlvbu_extra7:addSkill("shenfen")

shenzhaoyun_extra = sgs.General(extension, "shenzhaoyun_extra", "god", 2, true, true, true)
shenzhaoyun_extra:addSkill("juejing")
shenzhaoyun_extra:addSkill("longhun")

newshenzhaoyun_extra1 = sgs.General(extension, "newshenzhaoyun_extra1", "god", 2, true, true, true)
newshenzhaoyun_extra1:addSkill("newjuejing")
newshenzhaoyun_extra1:addSkill("newlonghun")
newshenzhaoyun_extra2 = sgs.General(extension, "newshenzhaoyun_extra2", "god", 2, true, true, true)
newshenzhaoyun_extra2:addSkill("newjuejing")
newshenzhaoyun_extra2:addSkill("newlonghun")
newshenzhaoyun_extra3 = sgs.General(extension, "newshenzhaoyun_extra3", "god", 2, true, true, true)
newshenzhaoyun_extra3:addSkill("newjuejing")
newshenzhaoyun_extra3:addSkill("newlonghun")
newshenzhaoyun_extra4 = sgs.General(extension, "newshenzhaoyun_extra4", "god", 2, true, true, true)
newshenzhaoyun_extra4:addSkill("newjuejing")
newshenzhaoyun_extra4:addSkill("newlonghun")
newshenzhaoyun_extra5 = sgs.General(extension, "newshenzhaoyun_extra5", "god", 2, true, true, true)
newshenzhaoyun_extra5:addSkill("newjuejing")
newshenzhaoyun_extra5:addSkill("newlonghun")
newshenzhaoyun_extra6 = sgs.General(extension, "newshenzhaoyun_extra6", "god", 2, true, true, true)
newshenzhaoyun_extra6:addSkill("newjuejing")
newshenzhaoyun_extra6:addSkill("newlonghun")

shensimayi_extra1 = sgs.General(extension, "shensimayi_extra1", "god", 4, true, true, true)
shensimayi_extra1:addSkill("renjie")
shensimayi_extra1:addSkill("baiyin")
shensimayi_extra1:addSkill("lianpo")
shensimayi_extra2 = sgs.General(extension, "shensimayi_extra2", "god", 4, true, true, true)
shensimayi_extra2:addSkill("renjie")
shensimayi_extra2:addSkill("baiyin")
shensimayi_extra2:addSkill("lianpo")
shensimayi_extra3 = sgs.General(extension, "shensimayi_extra3", "god", 4, true, true, true)
shensimayi_extra3:addSkill("renjie")
shensimayi_extra3:addSkill("baiyin")
shensimayi_extra3:addSkill("lianpo")

shenliubei_extra1 = sgs.General(extension, "shenliubei_extra1", "god", 6, true, true, true)
shenliubei_extra1:addSkill("longnu")
shenliubei_extra1:addSkill("jieying")
shenliubei_extra2 = sgs.General(extension, "shenliubei_extra2", "god", 6, true, true, true)
shenliubei_extra2:addSkill("longnu")
shenliubei_extra2:addSkill("jieying")
shenliubei_extra3 = sgs.General(extension, "shenliubei_extra3", "god", 6, true, true, true)
shenliubei_extra3:addSkill("longnu")
shenliubei_extra3:addSkill("jieying")
shenliubei_extra4 = sgs.General(extension, "shenliubei_extra4", "god", 6, true, true, true)
shenliubei_extra4:addSkill("longnu")
shenliubei_extra4:addSkill("jieying")

shenluxun_extra1 = sgs.General(extension, "shenluxun_extra1", "god", 4, true, true, true)
shenluxun_extra1:addSkill("junlve")
shenluxun_extra1:addSkill("cuike")
shenluxun_extra1:addSkill("zhanhuo")
shenluxun_extra2 = sgs.General(extension, "shenluxun_extra2", "god", 4, true, true, true)
shenluxun_extra2:addSkill("junlve")
shenluxun_extra2:addSkill("cuike")
shenluxun_extra2:addSkill("zhanhuo")
shenluxun_extra3 = sgs.General(extension, "shenluxun_extra3", "god", 4, true, true, true)
shenluxun_extra3:addSkill("junlve")
shenluxun_extra3:addSkill("cuike")
shenluxun_extra3:addSkill("zhanhuo")
shenluxun_extra4 = sgs.General(extension, "shenluxun_extra4", "god", 4, true, true, true)
shenluxun_extra4:addSkill("junlve")
shenluxun_extra4:addSkill("cuike")
shenluxun_extra4:addSkill("zhanhuo")

shenzhangliao_extra1 = sgs.General(extension, "shenzhangliao_extra1", "god", 4, true, true, true)
shenzhangliao_extra1:addSkill("duorui")
shenzhangliao_extra1:addSkill("zhiti")
shenzhangliao_extra2 = sgs.General(extension, "shenzhangliao_extra2", "god", 4, true, true, true)
shenzhangliao_extra2:addSkill("duorui")
shenzhangliao_extra2:addSkill("zhiti")
shenzhangliao_extra3 = sgs.General(extension, "shenzhangliao_extra3", "god", 4, true, true, true)
shenzhangliao_extra3:addSkill("duorui")
shenzhangliao_extra3:addSkill("zhiti")

olshenzhangliao_extra = sgs.General(extension, "olshenzhangliao_extra", "god", 4, true, true, true)
olshenzhangliao_extra:addSkill("olduorui")
olshenzhangliao_extra:addSkill("olzhiti")

dagui_1 = sgs.General(extension, "dagui_1", "god", 6, true, true, true, 3)
dagui_1:addSkill("poxi")
dagui_1:addSkill("jieyingg")
dagui_2 = sgs.General(extension, "dagui_2", "god", 6, true, true, true, 3)
dagui_2:addSkill("poxi")
dagui_2:addSkill("jieyingg")
dagui_3 = sgs.General(extension, "dagui_3", "god", 6, true, true, true, 3)
dagui_3:addSkill("poxi")
dagui_3:addSkill("jieyingg")
dagui_4 = sgs.General(extension, "dagui_4", "god", 6, true, true, true, 3)
dagui_4:addSkill("poxi")
dagui_4:addSkill("jieyingg")
dagui_5 = sgs.General(extension, "dagui_5", "god", 6, false, true, true, 3)
dagui_5:addSkill("poxi")
dagui_5:addSkill("jieyingg")

--彩蛋：
dabao = sgs.General(extension, "dabao", "wu", 4, true, true, true)
dabao:addSkill("mobilepojun")

wlfc_mini = sgs.General(extension, "wlfc_mini", "shu", 4, true, true, true)
wlfc_mini:addSkill("youlong")
wlfc_mini:addSkill("luanfeng")
----
--

--可于出牌阶段随意更换皮肤
GOD_changeFullSkin_ButtonCard = sgs.CreateSkillCard{
    name = "GOD_changeFullSkin_ButtonCard",
	target_fixed = true,
	on_use = function(self, room, player, targets)
		local mhp = player:getMaxHp()
		local hp = player:getHp()
		--神关羽
		if player:getGeneralName() == "shenguanyu" or player:getGeneralName() == "shenguanyu_extra1"
		or player:getGeneralName() == "shenguanyu_extra2" or player:getGeneralName() == "shenguanyu_extra3" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+sgy_hzfj+sgy_lygh+sgy_yzfw")
			if choice == "sjyh" then
				room:changeHero(player, "shenguanyu", false, false, false, false)
			elseif choice == "sgy_hzfj" then
				room:changeHero(player, "shenguanyu_extra1", false, false, false, false)
			elseif choice == "sgy_lygh" then
				room:changeHero(player, "shenguanyu_extra2", false, false, false, false)
			elseif choice == "sgy_yzfw" then
				room:changeHero(player, "shenguanyu_extra3", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "shenguanyu" or player:getGeneral2Name() == "shenguanyu_extra1"
		or player:getGeneral2Name() == "shenguanyu_extra2" or player:getGeneral2Name() == "shenguanyu_extra3" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+sgy_hzfj+sgy_lygh+sgy_yzfw")
			if choice == "sjyh" then
				room:changeHero(player, "shenguanyu", false, false, true, false)
			elseif choice == "sgy_hzfj" then
				room:changeHero(player, "shenguanyu_extra1", false, false, true, false)
			elseif choice == "sgy_lygh" then
				room:changeHero(player, "shenguanyu_extra2", false, false, true, false)
			elseif choice == "sgy_yzfw" then
				room:changeHero(player, "shenguanyu_extra3", false, false, true, false)
			end
		end
		--OL神关羽
		if player:getGeneralName() == "ol_shenguanyu" or player:getGeneralName() == "olshenguanyu_extra" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+olsgy_gdzh")
			if choice == "sjyh" then
				room:changeHero(player, "ol_shenguanyu", false, false, false, false)
			else
				room:changeHero(player, "olshenguanyu_extra", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "ol_shenguanyu" or player:getGeneral2Name() == "olshenguanyu_extra" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+olsgy_gdzh")
			if choice == "sjyh" then
				room:changeHero(player, "ol_shenguanyu", false, false, true, false)
			else
				room:changeHero(player, "olshenguanyu_extra", false, false, true, false)
			end
		end
		--神吕蒙
		if player:getGeneralName() == "shenlvmeng" or player:getGeneralName() == "shenlvmeng_extra1" or player:getGeneralName() == "shenlvmeng_extra2"
		or player:getGeneralName() == "shenlvmeng_extra3" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+slm_bydj+slm_fscm+slm_jzww")
			if choice == "sjyh" then
				room:changeHero(player, "shenlvmeng", false, false, false, false)
			elseif choice == "slm_bydj" then
				room:changeHero(player, "shenlvmeng_extra1", false, false, false, false)
			elseif choice == "slm_fscm" then
				room:changeHero(player, "shenlvmeng_extra2", false, false, false, false)
			elseif choice == "slm_jzww" then
				room:changeHero(player, "shenlvmeng_extra3", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "shenlvmeng" or player:getGeneral2Name() == "shenlvmeng_extra1" or player:getGeneral2Name() == "shenlvmeng_extra2"
		or player:getGeneral2Name() == "shenlvmeng_extra3" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+slm_bydj+slm_fscm+slm_jzww")
			if choice == "sjyh" then
				room:changeHero(player, "shenlvmeng", false, false, true, false)
			elseif choice == "slm_bydj" then
				room:changeHero(player, "shenlvmeng_extra1", false, false, true, false)
			elseif choice == "slm_fscm" then
				room:changeHero(player, "shenlvmeng_extra2", false, false, true, false)
			elseif choice == "slm_jzww" then
				room:changeHero(player, "shenlvmeng_extra3", false, false, true, false)
			end
		end
		--神周瑜
		if player:getGeneralName() == "shenzhouyu" or player:getGeneralName() == "shenzhouyu_wx" or player:getGeneralName() == "shenzhouyu_extra1"
		or player:getGeneralName() == "shenzhouyu_extra2" or player:getGeneralName() == "shenzhouyu_extra3" or player:getGeneralName() == "shenzhouyu_extra4"
		or player:getGeneralName() == "shenzhouyu_extra5" then
			local n = player:getMark("@flame")
			for _, szgl in sgs.qlist(room:getAllPlayers()) do
				if (szgl:getGeneralName() == "shenzhugeliang" or szgl:getGeneral2Name() == "shenzhugeliang")
				or (szgl:getGeneralName() == "shenzhugeliang_extra1" or szgl:getGeneral2Name() == "shenzhugeliang_extra1")
				or (szgl:getGeneralName() == "shenzhugeliang_extra2" or szgl:getGeneral2Name() == "shenzhugeliang_extra2")
				or (szgl:getGeneralName() == "shenzhugeliang_extra3" or szgl:getGeneral2Name() == "shenzhugeliang_extra3")
				or (szgl:getGeneralName() == "shenzhugeliang_extra4" or szgl:getGeneral2Name() == "shenzhugeliang_extra4")
				or (szgl:getGeneralName() == "shenzhugeliang_extra5" or szgl:getGeneral2Name() == "shenzhugeliang_extra5")
				or (szgl:getGeneralName() == "shenzhugeliang_extra6" or szgl:getGeneral2Name() == "shenzhugeliang_extra6") then
					room:setPlayerFlag(player, "szy_ytql")
					break
				end
			end
			local choices = {}
			table.insert(choices, "sjyh")
			table.insert(choices, "wxxcx")
			table.insert(choices, "szy_hlyh")
			table.insert(choices, "szy_qynn")
			table.insert(choices, "szy_lgyl")
			if player:hasFlag("szy_ytql") then
				table.insert(choices, "szy_ytql")
			end
			table.insert(choices, "szy_hzpc")
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			if choice == "sjyh" then
				room:changeHero(player, "shenzhouyu", false, false, false, false)
			elseif choice == "wxxcx" then
				room:changeHero(player, "shenzhouyu_wx", false, false, false, false)
			elseif choice == "szy_hlyh" then
				room:changeHero(player, "shenzhouyu_extra1", false, false, false, false)
			elseif choice == "szy_qynn" then
				room:changeHero(player, "shenzhouyu_extra2", false, false, false, false)
			elseif choice == "szy_lgyl" then
				room:changeHero(player, "shenzhouyu_extra3", false, false, false, false)
			elseif choice == "szy_ytql" then
				room:changeHero(player, "shenzhouyu_extra4", false, false, false, false)
			elseif choice == "szy_hzpc" then
				room:changeHero(player, "shenzhouyu_extra5", false, false, false, false)
			end
			room:setPlayerMark(player, "@flame", n)
		end
		if player:getGeneral2Name() == "shenzhouyu" or player:getGeneral2Name() == "shenzhouyu_wx" or player:getGeneral2Name() == "shenzhouyu_extra1"
		or player:getGeneral2Name() == "shenzhouyu_extra2" or player:getGeneral2Name() == "shenzhouyu_extra3" or player:getGeneral2Name() == "shenzhouyu_extra4"
		or player:getGeneral2Name() == "shenzhouyu_extra5" then
			local n = player:getMark("@flame")
			for _, szgl in sgs.qlist(room:getAllPlayers()) do
				if (szgl:getGeneralName() == "shenzhugeliang" or szgl:getGeneral2Name() == "shenzhugeliang")
				or (szgl:getGeneralName() == "shenzhugeliang_extra1" or szgl:getGeneral2Name() == "shenzhugeliang_extra1")
				or (szgl:getGeneralName() == "shenzhugeliang_extra2" or szgl:getGeneral2Name() == "shenzhugeliang_extra2")
				or (szgl:getGeneralName() == "shenzhugeliang_extra3" or szgl:getGeneral2Name() == "shenzhugeliang_extra3")
				or (szgl:getGeneralName() == "shenzhugeliang_extra4" or szgl:getGeneral2Name() == "shenzhugeliang_extra4")
				or (szgl:getGeneralName() == "shenzhugeliang_extra5" or szgl:getGeneral2Name() == "shenzhugeliang_extra5")
				or (szgl:getGeneralName() == "shenzhugeliang_extra6" or szgl:getGeneral2Name() == "shenzhugeliang_extra6") then
					room:setPlayerFlag(player, "szy_ytql")
					break
				end
			end
			local choices = {}
			table.insert(choices, "sjyh")
			table.insert(choices, "wxxcx")
			table.insert(choices, "szy_hlyh")
			table.insert(choices, "szy_qynn")
			table.insert(choices, "szy_lgyl")
			if player:hasFlag("szy_ytql") then
				table.insert(choices, "szy_ytql")
			end
			table.insert(choices, "szy_hzpc")
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			if choice == "sjyh" then
				room:changeHero(player, "shenzhouyu", false, false, true, false)
			elseif choice == "wxxcx" then
				room:changeHero(player, "shenzhouyu_wx", false, false, true, false)
			elseif choice == "szy_hlyh" then
				room:changeHero(player, "shenzhouyu_extra1", false, false, true, false)
			elseif choice == "szy_qynn" then
				room:changeHero(player, "shenzhouyu_extra2", false, false, true, false)
			elseif choice == "szy_lgyl" then
				room:changeHero(player, "shenzhouyu_extra3", false, false, true, false)
			elseif choice == "szy_ytql" then
				room:changeHero(player, "shenzhouyu_extra4", false, false, true, false)
			elseif choice == "szy_hzpc" then
				room:changeHero(player, "shenzhouyu_extra5", false, false, true, false)
			end
			room:setPlayerMark(player, "@flame", n)
		end
		--神诸葛亮
		if player:getGeneralName() == "shenzhugeliang" or player:getGeneralName() == "shenzhugeliang_extra1" or player:getGeneralName() == "shenzhugeliang_extra2"
		or player:getGeneralName() == "shenzhugeliang_extra3" or player:getGeneralName() == "shenzhugeliang_extra4" or player:getGeneralName() == "shenzhugeliang_extra5"
		or player:getGeneralName() == "shenzhugeliang_extra6" then
			for _, szy in sgs.qlist(room:getAllPlayers()) do
				if (szy:getGeneralName() == "shenzhouyu" or szy:getGeneral2Name() == "shenzhouyu")
				or (szy:getGeneralName() == "shenzhouyu_wx" or szy:getGeneral2Name() == "shenzhouyu_wx")
				or (szy:getGeneralName() == "shenzhouyu_extra1" or szy:getGeneral2Name() == "shenzhouyu_extra1")
				or (szy:getGeneralName() == "shenzhouyu_extra2" or szy:getGeneral2Name() == "shenzhouyu_extra2")
				or (szy:getGeneralName() == "shenzhouyu_extra3" or szy:getGeneral2Name() == "shenzhouyu_extra3")
				or (szy:getGeneralName() == "shenzhouyu_extra4" or szy:getGeneral2Name() == "shenzhouyu_extra4")
				or (szy:getGeneralName() == "shenzhouyu_extra5" or szy:getGeneral2Name() == "shenzhouyu_extra5") then
					room:setPlayerFlag(player, "szgl_fwmn")
					break
				end
			end
			local choices = {}
			table.insert(choices, "sjyh")
			table.insert(choices, "szgl_gxhy")
			table.insert(choices, "szgl_cbhf")
			table.insert(choices, "szgl_mzzx")
			if player:hasFlag("szgl_fwmn") then
				table.insert(choices, "szgl_fwmn")
			end
			table.insert(choices, "szgl_jjtt")
			table.insert(choices, "szgl_hzpc")
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			if choice == "sjyh" then
				room:changeHero(player, "shenzhugeliang", false, false, false, false)
			elseif choice == "szgl_gxhy" then
				room:changeHero(player, "shenzhugeliang_extra1", false, false, false, false)
			elseif choice == "szgl_cbhf" then
				room:changeHero(player, "shenzhugeliang_extra2", false, false, false, false)
			elseif choice == "szgl_mzzx" then
				room:changeHero(player, "shenzhugeliang_extra3", false, false, false, false)
			elseif choice == "szgl_fwmn" then
				room:changeHero(player, "shenzhugeliang_extra4", false, false, false, false)
			elseif choice == "szgl_jjtt" then
				room:changeHero(player, "shenzhugeliang_extra5", false, false, false, false)
			elseif choice == "szgl_hzpc" then
				room:changeHero(player, "shenzhugeliang_extra6", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "shenzhugeliang" or player:getGeneral2Name() == "shenzhugeliang_extra1" or player:getGeneral2Name() == "shenzhugeliang_extra2"
		or player:getGeneral2Name() == "shenzhugeliang_extra3" or player:getGeneral2Name() == "shenzhugeliang_extra4" or player:getGeneral2Name() == "shenzhugeliang_extra5"
		or player:getGeneral2Name() == "shenzhugeliang_extra6" then
			for _, szy in sgs.qlist(room:getAllPlayers()) do
				if (szy:getGeneralName() == "shenzhouyu" or szy:getGeneral2Name() == "shenzhouyu")
				or (szy:getGeneralName() == "shenzhouyu_wx" or szy:getGeneral2Name() == "shenzhouyu_wx")
				or (szy:getGeneralName() == "shenzhouyu_extra1" or szy:getGeneral2Name() == "shenzhouyu_extra1")
				or (szy:getGeneralName() == "shenzhouyu_extra2" or szy:getGeneral2Name() == "shenzhouyu_extra2")
				or (szy:getGeneralName() == "shenzhouyu_extra3" or szy:getGeneral2Name() == "shenzhouyu_extra3")
				or (szy:getGeneralName() == "shenzhouyu_extra4" or szy:getGeneral2Name() == "shenzhouyu_extra4")
				or (szy:getGeneralName() == "shenzhouyu_extra5" or szy:getGeneral2Name() == "shenzhouyu_extra5") then
					room:setPlayerFlag(player, "szgl_fwmn")
					break
				end
			end
			local choices = {}
			table.insert(choices, "sjyh")
			table.insert(choices, "szgl_gxhy")
			table.insert(choices, "szgl_cbhf")
			table.insert(choices, "szgl_mzzx")
			if player:hasFlag("szgl_fwmn") then
				table.insert(choices, "szgl_fwmn")
			end
			table.insert(choices, "szgl_jjtt")
			table.insert(choices, "szgl_hzpc")
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			if choice == "sjyh" then
				room:changeHero(player, "shenzhugeliang", false, false, true, false)
			elseif choice == "szgl_gxhy" then
				room:changeHero(player, "shenzhugeliang_extra1", false, false, true, false)
			elseif choice == "szgl_cbhf" then
				room:changeHero(player, "shenzhugeliang_extra2", false, false, true, false)
			elseif choice == "szgl_mzzx" then
				room:changeHero(player, "shenzhugeliang_extra3", false, false, true, false)
			elseif choice == "szgl_fwmn" then
				room:changeHero(player, "shenzhugeliang_extra4", false, false, true, false)
			elseif choice == "szgl_jjtt" then
				room:changeHero(player, "shenzhugeliang_extra5", false, false, true, false)
			elseif choice == "szgl_hzpc" then
				room:changeHero(player, "shenzhugeliang_extra6", false, false, true, false)
			end
		end
		--神曹操
		if player:getGeneralName() == "shencaocao" or player:getGeneralName() == "shencaocao_extra" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+scc_xttm")
			if choice == "sjyh" then
				room:changeHero(player, "shencaocao", false, false, false, false)
				if player:getMark("ngx_zhuangxin") > 0 then room:detachSkillFromPlayer(player, "guixin", true) end
			else
				room:changeHero(player, "shencaocao_extra", false, false, false, false)
				if player:getMark("ngx_zhuangxin") > 0 then room:detachSkillFromPlayer(player, "guixin", true) end
			end
		end
		if player:getGeneral2Name() == "shencaocao" or player:getGeneral2Name() == "shencaocao_extra" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+scc_xttm")
			if choice == "sjyh" then
				room:changeHero(player, "shencaocao", false, false, true, false)
				if player:getMark("ngx_zhuangxin") > 0 then room:detachSkillFromPlayer(player, "guixin", true) end
			else
				room:changeHero(player, "shencaocao_extra", false, false, true, false)
				if player:getMark("ngx_zhuangxin") > 0 then room:detachSkillFromPlayer(player, "guixin", true) end
			end
		end
		--端游神曹操
		if player:getGeneralName() == "new_shencaocao" or player:getGeneralName() == "pcshencaocao_extra1" or player:getGeneralName() == "pcshencaocao_extra2" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+pcscc_ytjs+pcscc_lyxh")
			if choice == "sjyh" then
				room:changeHero(player, "new_shencaocao", false, false, false, false)
				if player:getMark("ngx_zhuangxin") > 0 then room:detachSkillFromPlayer(player, "newguixin", true) end
			elseif choice == "pcscc_ytjs" then
				room:changeHero(player, "pcshencaocao_extra1", false, false, false, false)
				if player:getMark("ngx_zhuangxin") > 0 then room:detachSkillFromPlayer(player, "newguixin", true) end
			elseif choice == "pcscc_lyxh" then
				room:changeHero(player, "pcshencaocao_extra2", false, false, false, false)
				if player:getMark("ngx_zhuangxin") > 0 then room:detachSkillFromPlayer(player, "newguixin", true) end
			end
		end
		if player:getGeneral2Name() == "new_shencaocao" or player:getGeneral2Name() == "pcshencaocao_extra1" or player:getGeneral2Name() == "pcshencaocao_extra2" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+pcscc_ytjs+pcscc_lyxh")
			if choice == "sjyh" then
				room:changeHero(player, "new_shencaocao", false, false, true, false)
				if player:getMark("ngx_zhuangxin") > 0 then room:detachSkillFromPlayer(player, "newguixin", true) end
			elseif choice == "pcscc_ytjs" then
				room:changeHero(player, "pcshencaocao_extra1", false, false, true, false)
				if player:getMark("ngx_zhuangxin") > 0 then room:detachSkillFromPlayer(player, "newguixin", true) end
			elseif choice == "pcscc_lyxh" then
				room:changeHero(player, "pcshencaocao_extra2", false, false, true, false)
				if player:getMark("ngx_zhuangxin") > 0 then room:detachSkillFromPlayer(player, "newguixin", true) end
			end
		end
		--神吕布
		if player:getGeneralName() == "shenlvbu" or player:getGeneralName() == "shenlvbu_extra1" or player:getGeneralName() == "shenlvbu_extra2"
		or player:getGeneralName() == "shenlvbu_extra3" or player:getGeneralName() == "shenlvbu_extra4" or player:getGeneralName() == "shenlvbu_extra5"
		or player:getGeneralName() == "shenlvbu_extra6" or player:getGeneralName() == "shenlvbu_extra7" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+slb_gjtx+slb_zsjg+slb_nzhd+slb_jbsm+slb_sftw+slb_lhft+slb_gsws")
			if choice == "sjyh" then
				room:changeHero(player, "shenlvbu", false, false, false, false)
			elseif choice == "slb_gjtx" then
				room:changeHero(player, "shenlvbu_extra1", false, false, false, false)
			elseif choice == "slb_zsjg" then
				room:changeHero(player, "shenlvbu_extra2", false, false, false, false)
			elseif choice == "slb_nzhd" then
				room:changeHero(player, "shenlvbu_extra3", false, false, false, false)
			elseif choice == "slb_jbsm" then
				room:changeHero(player, "shenlvbu_extra4", false, false, false, false)
			elseif choice == "slb_sftw" then
				room:changeHero(player, "shenlvbu_extra5", false, false, false, false)
			elseif choice == "slb_lhft" then
				room:changeHero(player, "shenlvbu_extra6", false, false, false, false)
			elseif choice == "slb_gsws" then
				room:changeHero(player, "shenlvbu_extra7", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "shenlvbu" or player:getGeneral2Name() == "shenlvbu_extra1" or player:getGeneral2Name() == "shenlvbu_extra2"
		or player:getGeneral2Name() == "shenlvbu_extra3" or player:getGeneral2Name() == "shenlvbu_extra4" or player:getGeneral2Name() == "shenlvbu_extra5"
		or player:getGeneral2Name() == "shenlvbu_extra6" or player:getGeneral2Name() == "shenlvbu_extra7" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+slb_gjtx+slb_zsjg+slb_nzhd+slb_jbsm+slb_sftw+slb_lhft+slb_gsws")
			if choice == "sjyh" then
				room:changeHero(player, "shenlvbu", false, false, true, false)
			elseif choice == "slb_gjtx" then
				room:changeHero(player, "shenlvbu_extra1", false, false, true, false)
			elseif choice == "slb_zsjg" then
				room:changeHero(player, "shenlvbu_extra2", false, false, true, false)
			elseif choice == "slb_nzhd" then
				room:changeHero(player, "shenlvbu_extra3", false, false, true, false)
			elseif choice == "slb_jbsm" then
				room:changeHero(player, "shenlvbu_extra4", false, false, true, false)
			elseif choice == "slb_sftw" then
				room:changeHero(player, "shenlvbu_extra5", false, false, true, false)
			elseif choice == "slb_lhft" then
				room:changeHero(player, "shenlvbu_extra6", false, false, true, false)
			elseif choice == "slb_gsws" then
				room:changeHero(player, "shenlvbu_extra7", false, false, true, false)
			end
		end
		--神赵云
		if player:getGeneralName() == "shenzhaoyun" or player:getGeneralName() == "shenzhaoyun_extra" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+szy_jlsg")
			if choice == "sjyh" then
				room:changeHero(player, "shenzhaoyun", false, false, false, false)
			else
				room:changeHero(player, "shenzhaoyun_extra", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "shenzhaoyun" or player:getGeneral2Name() == "shenzhaoyun_extra" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+szy_jlsg")
			if choice == "sjyh" then
				room:changeHero(player, "shenzhaoyun", false, false, true, false)
			else
				room:changeHero(player, "shenzhaoyun_extra", false, false, true, false)
			end
		end
		--新神赵云
		if player:getGeneralName() == "new_shenzhaoyun" or player:getGeneralName() == "newshenzhaoyun_extra1" or player:getGeneralName() == "newshenzhaoyun_extra2"
		or player:getGeneralName() == "newshenzhaoyun_extra3" or player:getGeneralName() == "newshenzhaoyun_extra4" or player:getGeneralName() == "newshenzhaoyun_extra5"
		or player:getGeneralName() == "newshenzhaoyun_extra6" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+nszy_zlzy+nszy_slyz+nszy_gzbq+nszy_gdjz+nszy_ylzt+nszy_jwwy")
			if choice == "sjyh" then
				room:changeHero(player, "new_shenzhaoyun", false, false, false, false)
			elseif choice == "nszy_zlzy" then
				room:changeHero(player, "newshenzhaoyun_extra1", false, false, false, false)
			elseif choice == "nszy_slyz" then
				room:changeHero(player, "newshenzhaoyun_extra2", false, false, false, false)
			elseif choice == "nszy_gzbq" then
				room:changeHero(player, "newshenzhaoyun_extra3", false, false, false, false)
			elseif choice == "nszy_gdjz" then
				room:changeHero(player, "newshenzhaoyun_extra4", false, false, false, false)
			elseif choice == "nszy_ylzt" then
				room:changeHero(player, "newshenzhaoyun_extra5", false, false, false, false)
			elseif choice == "nszy_jwwy" then
				room:changeHero(player, "newshenzhaoyun_extra6", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "new_shenzhaoyun" or player:getGeneral2Name() == "newshenzhaoyun_extra1" or player:getGeneral2Name() == "newshenzhaoyun_extra2"
		or player:getGeneral2Name() == "newshenzhaoyun_extra3" or player:getGeneral2Name() == "newshenzhaoyun_extra4" or player:getGeneral2Name() == "newshenzhaoyun_extra5"
		or player:getGeneral2Name() == "newshenzhaoyun_extra6" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+nszy_zlzy+nszy_slyz+nszy_gzbq+nszy_gdjz+nszy_ylzt+nszy_jwwy")
			if choice == "sjyh" then
				room:changeHero(player, "new_shenzhaoyun", false, false, true, false)
			elseif choice == "nszy_zlzy" then
				room:changeHero(player, "newshenzhaoyun_extra1", false, false, true, false)
			elseif choice == "nszy_slyz" then
				room:changeHero(player, "newshenzhaoyun_extra2", false, false, true, false)
			elseif choice == "nszy_gzbq" then
				room:changeHero(player, "newshenzhaoyun_extra3", false, false, true, false)
			elseif choice == "nszy_gdjz" then
				room:changeHero(player, "newshenzhaoyun_extra4", false, false, true, false)
			elseif choice == "nszy_ylzt" then
				room:changeHero(player, "newshenzhaoyun_extra5", false, false, true, false)
			elseif choice == "nszy_jwwy" then
				room:changeHero(player, "newshenzhaoyun_extra6", false, false, true, false)
			end
		end
		--神司马懿
		if player:getGeneralName() == "shensimayi" or player:getGeneralName() == "shensimayi_extra1" or player:getGeneralName() == "shensimayi_extra2"
		or player:getGeneralName() == "shensimayi_extra3" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+ssmy_jwzl+ssmy_sltw+ssmy_kqcw")
			if choice == "sjyh" then
				room:changeHero(player, "shensimayi", false, false, false, false)
			elseif choice == "ssmy_jwzl" then
				room:changeHero(player, "shensimayi_extra1", false, false, false, false)
			elseif choice == "ssmy_sltw" then
				room:changeHero(player, "shensimayi_extra2", false, false, false, false)
			elseif choice == "ssmy_kqcw" then
				room:changeHero(player, "shensimayi_extra3", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "shensimayi" or player:getGeneral2Name() == "shensimayi_extra1" or player:getGeneral2Name() == "shensimayi_extra2"
		or player:getGeneral2Name() == "shensimayi_extra3" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+ssmy_jwzl+ssmy_sltw+ssmy_kqcw")
			if choice == "sjyh" then
				room:changeHero(player, "shensimayi_extra1", false, false, true, false)
			elseif choice == "ssmy_jwzl" then
				room:changeHero(player, "shensimayi_extra1", false, false, true, false)
			elseif choice == "ssmy_sltw" then
				room:changeHero(player, "shensimayi_extra2", false, false, true, false)
			elseif choice == "ssmy_kqcw" then
				room:changeHero(player, "shensimayi_extra3", false, false, true, false)
			end
		end
		--神刘备
		if player:getGeneralName() == "shenliubei" or player:getGeneralName() == "shenliubei_extra1" or player:getGeneralName() == "shenliubei_extra2"
		or player:getGeneralName() == "shenliubei_extra3" or player:getGeneralName() == "shenliubei_extra4" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+slb_zlnh+slb_nhfc+slb_lxhn+slb_dwzz")
			if choice == "sjyh" then
				room:changeHero(player, "shenliubei", false, false, false, false)
			elseif choice == "slb_zlnh" then
				room:changeHero(player, "shenliubei_extra1", false, false, false, false)
			elseif choice == "slb_nhfc" then
				room:changeHero(player, "shenliubei_extra2", false, false, false, false)
			elseif choice == "slb_lxhn" then
				room:changeHero(player, "shenliubei_extra3", false, false, false, false)
			elseif choice == "slb_dwzz" then
				room:changeHero(player, "shenliubei_extra4", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "shenliubei" or player:getGeneral2Name() == "shenliubei_extra1" or player:getGeneral2Name() == "shenliubei_extra2"
		or player:getGeneral2Name() == "shenliubei_extra3" or player:getGeneral2Name() == "shenliubei_extra4" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+slb_zlnh+slb_nhfc+slb_lxhn+slb_dwzz")
			if choice == "sjyh" then
				room:changeHero(player, "shenliubei", false, false, true, false)
			elseif choice == "slb_zlnh" then
				room:changeHero(player, "shenliubei_extra1", false, false, true, false)
			elseif choice == "slb_nhfc" then
				room:changeHero(player, "shenliubei_extra2", false, false, true, false)
			elseif choice == "slb_lxhn" then
				room:changeHero(player, "shenliubei_extra3", false, false, true, false)
			elseif choice == "slb_dwzz" then
				room:changeHero(player, "shenliubei_extra4", false, false, true, false)
			end
		end
		--神陆逊
		if player:getGeneralName() == "shenluxun" or player:getGeneralName() == "shenluxun_extra1" or player:getGeneralName() == "shenluxun_extra2"
		or player:getGeneralName() == "shenluxun_extra3" or player:getGeneralName() == "shenluxun_extra4" then
			local n = player:getMark("@zhanhuoMark")
			local choice = room:askForChoice(player, self:objectName(), "sjyh+slx_zyck+slx_ylps+slx_ltfh+slx_zhfw")
			if choice == "sjyh" then
				room:changeHero(player, "shenluxun", false, false, false, false)
			elseif choice == "slx_zyck" then
				room:changeHero(player, "shenluxun_extra1", false, false, false, false)
			elseif choice == "slx_ylps" then
				room:changeHero(player, "shenluxun_extra2", false, false, false, false)
			elseif choice == "slx_ltfh" then
				room:changeHero(player, "shenluxun_extra3", false, false, false, false)
			elseif choice == "slx_zhfw" then
				room:changeHero(player, "shenluxun_extra4", false, false, false, false)
			end
			room:setPlayerMark(player, "@zhanhuoMark", n)
		end
		if player:getGeneral2Name() == "shenluxun" or player:getGeneral2Name() == "shenluxun_extra1" or player:getGeneral2Name() == "shenluxun_extra2"
		or player:getGeneral2Name() == "shenluxun_extra3" or player:getGeneral2Name() == "shenluxun_extra4" then
			local n = player:getMark("@zhanhuoMark")
			local choice = room:askForChoice(player, self:objectName(), "sjyh+slx_zyck+slx_ylps+slx_ltfh+slx_zhfw")
			if choice == "sjyh" then
				room:changeHero(player, "shenluxun", false, false, true, false)
			elseif choice == "slx_zyck" then
				room:changeHero(player, "shenluxun_extra1", false, false, true, false)
			elseif choice == "slx_ylps" then
				room:changeHero(player, "shenluxun_extra2", false, false, true, false)
			elseif choice == "slx_ltfh" then
				room:changeHero(player, "shenluxun_extra3", false, false, true, false)
			elseif choice == "slx_zhfw" then
				room:changeHero(player, "shenluxun_extra4", false, false, true, false)
			end
			room:setPlayerMark(player, "@zhanhuoMark", n)
		end
		--神张辽
		if player:getGeneralName() == "shenzhangliao" or player:getGeneralName() == "shenzhangliao_extra1" or player:getGeneralName() == "shenzhangliao_extra2"
		or player:getGeneralName() == "shenzhangliao_extra3" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+szl_ztjs+szl_pldk+szl_drys")
			if choice == "sjyh" then
				room:changeHero(player, "shenzhangliao", false, false, false, false)
			elseif choice == "szl_ztjs" then
				room:changeHero(player, "shenzhangliao_extra1", false, false, false, false)
			elseif choice == "szl_pldk" then
				room:changeHero(player, "shenzhangliao_extra2", false, false, false, false)
			elseif choice == "szl_drys" then
				room:changeHero(player, "shenzhangliao_extra3", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "shenzhangliao" or player:getGeneral2Name() == "shenzhangliao_extra1" or player:getGeneral2Name() == "shenzhangliao_extra2"
		or player:getGeneral2Name() == "shenzhangliao_extra3" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+szl_ztjs+szl_pldk+szl_drys")
			if choice == "sjyh" then
				room:changeHero(player, "shenzhangliao", false, false, true, false)
			elseif choice == "szl_ztjs" then
				room:changeHero(player, "shenzhangliao_extra1", false, false, true, false)
			elseif choice == "szl_pldk" then
				room:changeHero(player, "shenzhangliao_extra2", false, false, true, false)
			elseif choice == "szl_drys" then
				room:changeHero(player, "shenzhangliao_extra3", false, false, true, false)
			end
		end
		--OL神张辽
		if player:getGeneralName() == "ol_shenzhangliao" or player:getGeneralName() == "olshenzhangliao_extra" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+olszl_drzf")
			if choice == "sjyh" then
				room:changeHero(player, "ol_shenzhangliao", false, false, false, false)
			else
				room:changeHero(player, "olshenzhangliao_extra", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "ol_shenzhangliao" or player:getGeneral2Name() == "olshenzhangliao_extra" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+olszl_drzf")
			if choice == "sjyh" then
				room:changeHero(player, "ol_shenzhangliao", false, false, true, false)
			else
				room:changeHero(player, "olshenzhangliao_extra", false, false, true, false)
			end
		end
		--神甘宁
		if player:getGeneralName() == "shenganning" or player:getGeneralName() == "dagui_1" or player:getGeneralName() == "dagui_2"
		or player:getGeneralName() == "dagui_3" or player:getGeneralName() == "dagui_4" or player:getGeneralName() == "dagui_5" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+dagui_wrby+dagui_swrm+dagui_syft+dagui_fyys+dagui_ywsh")
			if choice == "sjyh" then
				room:changeHero(player, "shenganning", false, false, false, false)
			elseif choice == "dagui_wrby" then
				room:changeHero(player, "dagui_1", false, false, false, false)
			elseif choice == "dagui_swrm" then
				room:changeHero(player, "dagui_2", false, false, false, false)
			elseif choice == "dagui_syft" then
				room:changeHero(player, "dagui_3", false, false, false, false)
			elseif choice == "dagui_fyys" then
				room:changeHero(player, "dagui_4", false, false, false, false)
			elseif choice == "dagui_ywsh" then
				room:changeHero(player, "dagui_5", false, false, false, false)
			end
		end
		if player:getGeneral2Name() == "shenganning" or player:getGeneral2Name() == "dagui_1" or player:getGeneral2Name() == "dagui_2"
		or player:getGeneral2Name() == "dagui_3" or player:getGeneral2Name() == "dagui_4" or player:getGeneral2Name() == "dagui_5" then
			local choice = room:askForChoice(player, self:objectName(), "sjyh+dagui_wrby+dagui_swrm+dagui_syft+dagui_fyys+dagui_ywsh")
			if choice == "sjyh" then
				room:changeHero(player, "shenganning", false, false, true, false)
			elseif choice == "dagui_wrby" then
				room:changeHero(player, "dagui_1", false, false, true, false)
			elseif choice == "dagui_swrm" then
				room:changeHero(player, "dagui_2", false, false, true, false)
			elseif choice == "dagui_syft" then
				room:changeHero(player, "dagui_3", false, false, true, false)
			elseif choice == "dagui_fyys" then
				room:changeHero(player, "dagui_4", false, false, true, false)
			elseif choice == "dagui_ywsh" then
				room:changeHero(player, "dagui_5", false, false, true, false)
			end
		end
		----
		if player:getMaxHp() ~= mhp then room:setPlayerProperty(player, "maxhp", sgs.QVariant(mhp)) end
		if player:getHp() ~= hp then room:setPlayerProperty(player, "hp", sgs.QVariant(hp)) end
	end,
}
GOD_changeFullSkin_Button = sgs.CreateZeroCardViewAsSkill{
    name = "GOD_changeFullSkin_Button&",
	view_as = function()
		return GOD_changeFullSkin_ButtonCard:clone()
	end,
}
if not sgs.Sanguosha:getSkill("GOD_changeFullSkin_Button") then skills:append(GOD_changeFullSkin_Button) end

--[手杀传说动皮-神甘宁·万人辟易]测试
--[[shenganningWRBY = sgs.CreateTriggerSkill{
	name = "shenganningWRBY",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_RoundStart and player:hasSkill("jieyingg") then
			room:broadcastSkillInvoke("jieyingg_extra")
			room:setEmotion(player, "dagui_test")
			room:getThread():delay(600)
		end
	end,
	can_trigger = function(self, player)
		return player:getGeneralName() == "shenganning" or player:getGeneralName() == "dagui_1" or player:getGeneralName() == "dagui_2"
		or player:getGeneralName() == "dagui_3" or player:getGeneralName() == "dagui_4" or player:getGeneralName() == "dagui_5"
		
		or player:getGeneral2Name() == "shenganning" or player:getGeneral2Name() == "dagui_1" or player:getGeneral2Name() == "dagui_2"
		or player:getGeneral2Name() == "dagui_3" or player:getGeneral2Name() == "dagui_4" or player:getGeneral2Name() == "dagui_5"
	end,
}
if not sgs.Sanguosha:getSkill("shenganningWRBY") then skills:append(shenganningWRBY) end]]





--

sgs.Sanguosha:addSkills(skills)
sgs.LoadTranslationTable{
	["godstrengthenCS"] = "神将皮肤更换",
	
	["GOD_changeFullSkin"] = "更换武将皮肤",
	["GOD_changeFullSkin_repair"] = "",
	["GOD_changeFullSkin_Button"] = "换皮",
	["god_changefullskin_button"] = "更换武将皮肤",
	["GOD_changeFullSkin_ButtonCard"] = "更换武将皮肤",
	["sjyh"] = "原画",
	["wxxcx"] = "小程序精修",
	["sjjoy"] = "欢乐杀",
	
	["shenguanyu_extra1"] = "神关羽",
	["shenguanyu_extra2"] = "神关羽",
	["shenguanyu_extra3"] = "神关羽",
	["sgy_hzfj"] = "魂追弗届",
	["sgy_lygh"] = "链狱鬼魂",
	["sgy_yzfw"] = "佑子伐吴",
	
	["olshenguanyu_extra"] = "OL神关羽",
	["&olshenguanyu_extra"] = "神关羽",
	["olsgy_gdzh"] = "关帝之魂",
	
	["shenlvmeng_extra1"] = "神吕蒙",
	["shenlvmeng_extra2"] = "神吕蒙",
	["shenlvmeng_extra3"] = "神吕蒙",
	["slm_bydj"] = "白衣渡江",
	["slm_fscm"] = "风神超迈",
	["slm_jzww"] = "兼资文武",
	
	["shenzhouyu_wx"] = "神周瑜",
	["shenzhouyu_extra1"] = "神周瑜",
	["shenzhouyu_extra2"] = "神周瑜",
	["shenzhouyu_extra3"] = "神周瑜",
	["shenzhouyu_extra4"] = "神周瑜",
	["shenzhouyu_extra5"] = "神周瑜",
	["szy_hlyh"] = "红莲业火",
	["szy_qynn"] = "琴音袅袅",
	["szy_lgyl"] = "陵光引灵",
	  ["szy_ytql"] = "焰腾麒麟", --仅场上有神诸葛亮时
	["szy_hzpc"] = "合纵破曹", --本就是同框拆解的皮肤，就不作同框限制了
	
	["shenzhugeliang_extra1"] = "神诸葛亮",
	["shenzhugeliang_extra2"] = "神诸葛亮",
	["shenzhugeliang_extra3"] = "神诸葛亮",
	["shenzhugeliang_extra4"] = "神诸葛亮",
	["shenzhugeliang_extra5"] = "神诸葛亮",
	["shenzhugeliang_extra6"] = "神诸葛亮",
	["szgl_gxhy"] = "观星唤雨",
	["szgl_cbhf"] = "赤壁唤风",
	["szgl_mzzx"] = "孟章诛邪",
	  ["szgl_fwmn"] = "风舞魔鸟", --仅场上有神周瑜时
	["szgl_jjtt"] = "剑祭通天",
	["szgl_hzpc"] = "合纵破曹", --本就是同框拆解的皮肤，就不作同框限制了
	
	["shencaocao_extra"] = "神曹操",
	["scc_xttm"] = "玄天通冥",
	
	["pcshencaocao_extra1"] = "新神曹操",
	["pcshencaocao_extra2"] = "新神曹操",
	["&pcshencaocao_extra1"] = "神曹操",
	["&pcshencaocao_extra2"] = "神曹操",
	["pcscc_ytjs"] = "一统江山",
	["pcscc_lyxh"] = "炼狱枭魂",
	
	["shenlvbu_extra1"] = "神吕布",
	["shenlvbu_extra2"] = "神吕布",
	["shenlvbu_extra3"] = "神吕布",
	["shenlvbu_extra4"] = "神吕布",
	["shenlvbu_extra5"] = "神吕布",
	["shenlvbu_extra6"] = "神吕布",
	["shenlvbu_extra7"] = "神吕布",
	["slb_gjtx"] = "冠绝天下",
	["slb_zsjg"] = "战神金刚",
	["slb_nzhd"] = "怒斩混沌",
	["slb_jbsm"] = "监兵噬魅",
	["slb_sftw"] = "神愤天威",
	["slb_lhft"] = "戾火浮屠",
	["slb_gsws"] = "盖世无双",
	
	["shenzhaoyun_extra"] = "神赵云",
	["szy_jlsg"] = "极略三国",
	
	["newshenzhaoyun_extra1"] = "新神赵云",
	["newshenzhaoyun_extra2"] = "新神赵云",
	["newshenzhaoyun_extra3"] = "新神赵云",
	["newshenzhaoyun_extra4"] = "新神赵云",
	["newshenzhaoyun_extra5"] = "新神赵云",
	["newshenzhaoyun_extra6"] = "新神赵云",
	["&newshenzhaoyun_extra1"] = "神赵云",
	["&newshenzhaoyun_extra2"] = "神赵云",
	["&newshenzhaoyun_extra3"] = "神赵云",
	["&newshenzhaoyun_extra4"] = "神赵云",
	["&newshenzhaoyun_extra5"] = "神赵云",
	["&newshenzhaoyun_extra6"] = "神赵云",
	["nszy_zlzy"] = "战龙在野",
	["nszy_slyz"] = "神龙佑主",
	["nszy_gzbq"] = "孤战不怯",
	["nszy_gdjz"] = "孤胆救主",
	["nszy_ylzt"] = "御龙在天",
	["nszy_jwwy"] = "今吾往矣",
	
	["shensimayi_extra1"] = "神司马懿",
	["shensimayi_extra2"] = "神司马懿",
	["shensimayi_extra3"] = "神司马懿",
	["ssmy_jwzl"] = "鉴往知来",
	["ssmy_sltw"] = "三狼吞魏",
	["ssmy_kqcw"] = "控权曹魏",
	
	["shenliubei_extra1"] = "神刘备",
	["shenliubei_extra2"] = "神刘备",
	["shenliubei_extra3"] = "神刘备",
	["shenliubei_extra4"] = "神刘备",
	["slb_zlnh"] = "昭烈怒火",
	["slb_nhfc"] = "怒火复仇",
	["slb_lxhn"] = "龙兴海内",
	["slb_dwzz"] = "帝王之姿",
	
	["shenluxun_extra1"] = "神陆逊",
	["shenluxun_extra2"] = "神陆逊",
	["shenluxun_extra3"] = "神陆逊",
	["shenluxun_extra4"] = "神陆逊",
	["slx_zyck"] = "绽焰摧枯",
	["slx_ylps"] = "夷陵破蜀",
	["slx_ltfh"] = "连天烽火",
	["slx_zhfw"] = "绽火烽威",
	
	["shenzhangliao_extra1"] = "神张辽",
	["shenzhangliao_extra2"] = "神张辽",
	["shenzhangliao_extra3"] = "神张辽",
	["szl_ztjs"] = "止啼噤声",
	["szl_pldk"] = "破虏荡寇",
	["szl_drys"] = "夺锐扬旌",
	
	["olshenzhangliao_extra"] = "OL神张辽",
	["&olshenzhangliao_extra"] = "神张辽",
	["olszl_drzf"] = "夺锐争锋",
	
	["dagui_1"] = "神甘宁",
	["dagui_2"] = "神甘宁",
	["dagui_3"] = "神甘宁",
	["dagui_4"] = "神甘宁",
	["dagui_5"] = "神甘宁",
	["dagui_wrby"] = "万人辟易",
	["dagui_swrm"] = "神威如芒",
	["dagui_syft"] = "神鸦浮屠",
	["dagui_fyys"] = "绯狱鸦杀",
	["dagui_ywsh"] = "鸦舞摄魂", --云涯大佬画的娘化皮肤，名字是自己编的
	----
	  --附赠
	  ["dabao"] = "手杀界徐盛", --仅当地主时可以选择更换
	  --彩蛋
	  ["wlfc_mini"] = "卧龙凤雏", --随机更换
	----
}
return {extension}