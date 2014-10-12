local Version = 1.0

require "VPrediction"

function PluginOnLoad()
	TristanaLoad()
	TristanaMenu()
end

function PluginOnTick()
	TristanaCheck()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			if qReady and Menu.ComboQ and GetDistance(Target) < SpellR.Range then
				CastSpell(_Q)
			end
			if eReady and Menu.ComboE and GetDistance(Target) < SpellE.Range then
				CastSpell(_E, Target)
			end
			if rReady and Menu.ComboR and GetDistance(Target) < Menu.CRangesR then
				CastSpell(_R, Target)
			end
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			if qReady and Menu.HarassQ and GetDistance(Target) < SpellR.Range then
				CastSpell(_Q)
			end
			if eReady and Menu.HarassE and GetDistance(Target) < SpellE.Range then
				CastSpell(_E, Target)
			end
			if rReady and Menu.HarassR and GetDistance(Target) < Menu.HRangesR then
				CastSpell(_R, Target)
			end
		end
	end
	if Menu.DashesR and (Menu2.AutoCarry or Menu2.MixedMode or TristanaHealthLow()) then
		TristanaDashes()
	end
	TristanaKill()
end

function PluginOnProcessSpell(unit, spell)
	if Menu.InterruptR then
		if #Interrupt > 0 then
			for _, Inter in pairs(Interrupt) do
				if spell.name == Inter.spellName and unit.team ~= myHero.team then
					if Menu[Inter.spellName] and GetDistance(unit) < SpellR.Range then
						CastSpell(_R, unit)
					end
				end
			end
		end
	end
end

function PluginOnDraw()
	if not myHero.dead then
		if Menu.DrawW and wReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellW.Range, 0xFFFFFF)
		end
		if Menu.DrawE and eReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellE.Range, 0xFFFFFF)
		end
		if Menu.DrawR and rReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellR.Range, 0xFFFFFF)
		end
	end
end

function TristanaMenu()
	Menu:addParam("sep", "---- [ 连招设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ComboQ", "连招使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboE", "连招使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboR", "连招使用 R", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("CRangesR", "距离设置 R", SCRIPT_PARAM_SLICE, 250, 0, SpellR.Range, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 消耗设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("HarassQ", "消耗使用 Q", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("HarassE", "消耗使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassR", "消耗使用 R", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("HRangesR", "距离设置 R", SCRIPT_PARAM_SLICE, 250, 0, SpellR.Range, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 击杀设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("KillE", "击杀使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("KillR", "击杀使用 R", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 自动防突 - 毁灭射击 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DashesR", "目标突进时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("RangesR", "目标的距离小于", SCRIPT_PARAM_SLICE, 500, 0, SpellR.Range, -1)
	Menu:addParam("HealthR", "自己的血量小于", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	Menu:addParam("sep", "---- [ 自动打断 - 毁灭射击 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("InterruptR", "目标大招时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	Menu:addParam("sep", "---- [ 打断列表 ] ----", SCRIPT_PARAM_INFO, "")
	if #Interrupt > 0 then
		for _, Inter in pairs(Interrupt) do
			Menu:addParam(Inter.spellName, Inter.charName.." → "..Inter.spellName, SCRIPT_PARAM_ONOFF, true)
		end
	else
		Menu:addParam("sep", "没有需要打断的英雄技能", SCRIPT_PARAM_INFO, "")
	end

	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	Menu:addParam("sep", "---- [ 显示设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DrawW", "显示 W 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawE", "显示 E 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawR", "显示 R 范围", SCRIPT_PARAM_ONOFF, false)
end

function TristanaLoad()
	AutoCarry.SkillsCrosshair.range = 900
	SpellQ = {Range =    0, Speed = 1450, Delay =    0, Width =   0}
	SpellW = {Range =  900, Speed =   20, Delay =  0.5, Width =   0}
	SpellE = {Range =  703, Speed = 1400, Delay =  0.5, Width =   0}
	SpellR = {Range =  703, Speed = 1600, Delay =  0.5, Width =   0}
	qReady, wReady, eReady, rReady = false, false, false, false
	VP = VPrediction()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Enemies = GetEnemyHeroes()
	Interrupt = {}
	InterruptList = {
		{ charName = "Caitlyn", spellName = "CaitlynAceintheHole"},
		{ charName = "FiddleSticks", spellName = "Crowstorm"},
		{ charName = "Galio", spellName = "GalioIdolOfDurand"},
		{ charName = "Karthus", spellName = "FallenOne"},
		{ charName = "Katarina", spellName = "KatarinaR"},
		{ charName = "Malzahar", spellName = "AlZaharNetherGrasp"},
		{ charName = "MissFortune", spellName = "MissFortuneBulletTime"},
		{ charName = "Nunu", spellName = "AbsoluteZero"},
		{ charName = "Pantheon", spellName = "Pantheon_GrandSkyfall_Jump"},
		{ charName = "Shen", spellName = "ShenStandUnited"},
		{ charName = "Urgot", spellName = "UrgotSwap2"},
		{ charName = "Velkoz", spellName = "VelkozR"},
		{ charName = "Warwick", spellName = "InfiniteDuress"},
		{ charName = "TwistedFate", spellName = "gate"},
		{ charName = "Morgana", spellName = "SoulShackles"}
	}
	if AutoCarry.Skills then
		AutoCarry.Skills:DisableAll()
	end
	for _, enemy in pairs(Enemies) do
		for _, champ in pairs(InterruptList) do
			if enemy.charName == champ.charName then
				table.insert(Interrupt, {charName = champ.charName, spellName = champ.spellName})
			end
		end
	end
end

function TristanaCheck()
	Target = AutoCarry.GetAttackTarget()
	qReady = (myHero:CanUseSpell(_Q) == READY)
	wReady = (myHero:CanUseSpell(_W) == READY)
	eReady = (myHero:CanUseSpell(_E) == READY)
	rReady = (myHero:CanUseSpell(_R) == READY)
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			qDmg = getDmg("Q", enemy, myHero)
			wDmg = getDmg("W", enemy, myHero)
			eDmg = getDmg("E", enemy, myHero)
			rDmg = getDmg("R", enemy, myHero)
		end
	end
end

function TristanaKill()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.KillE and GetDistance(enemy) < SpellE.Range and eDmg > enemy.health then
				CastSpell(_E, enemy)
			elseif Menu.KillR and GetDistance(enemy) < SpellR.Range and rDmg > enemy.health then
				CastSpell(_R, enemy)
			end
		end
	end
end

function TristanaDashes()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellR.Delay, SpellR.Width, SpellR.Speed, myHero)
			if IsDashing and CanHit and rReady and GetDistance(enemy) < Menu.RangesR then
				CastSpell(_R, enemy)
			end
		end
	end
end

function TristanaHealthLow()
	if (myHero.health / myHero.maxHealth) < (Menu.HealthR / 100) then
		return true
	else
		return false
	end
end