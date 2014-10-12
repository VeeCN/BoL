local Version = 1.0

require "VPrediction"

function PluginOnLoad()
	EzrealLoad()
	EzrealMenu()
end

function PluginOnTick()
	EzrealCheck()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			if qReady and Menu.ComboQ and GetDistance(Target) < SpellQ.Range then
				CastVPredQ(Target)
			end
			if wReady and Menu.ComboW and GetDistance(Target) < SpellW.Range and wLevel >= Menu.CLevelW then
				CastVPredW(Target)
			end
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			if qReady and Menu.HarassQ and GetDistance(Target) < SpellQ.Range then
				CastVPredQ(Target)
			end
			if wReady and Menu.HarassW and GetDistance(Target) < SpellW.Range and wLevel >= Menu.HLevelW then
				CastVPredW(Target)
			end
		end
	end
	EzrealKill()
end

function PluginOnDraw()
	if not myHero.dead then
		if Menu.DrawQ and qReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellQ.Range, 0xFFFFFF)
		end
		if Menu.DrawW and wReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellW.Range, 0xFFFFFF)
		end
		if Menu.DrawE and eReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellE.Range, 0xFFFFFF)
		end
	end
end

function EzrealMenu()
	Menu:addParam("sep", "---- [ 连招设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ComboQ", "连招使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboW", "连招使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 消耗设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("HarassQ", "消耗使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassW", "消耗使用 W", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 击杀设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("KillQ", "击杀使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("KillW", "击杀使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("KillR", "击杀使用 R", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 其他设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("CLevelW", "连招等级 W", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
	Menu:addParam("HLevelW", "消耗等级 W", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
	Menu:addParam("MinR", "最小距离 R", SCRIPT_PARAM_SLICE, 500, 0, 2000, -1)
	Menu:addParam("MaxR", "最大距离 R", SCRIPT_PARAM_SLICE, 2000, 0, 2000, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 显示设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DrawQ", "显示 Q 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawW", "显示 W 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawE", "显示 E 范围", SCRIPT_PARAM_ONOFF, false)
end

function EzrealLoad()
	AutoCarry.SkillsCrosshair.range = 2000
	SpellQ = {Range = 1150, Speed = 1200, Delay = 0.25, Width =  80}
	SpellW = {Range = 1000, Speed = 1200, Delay = 0.25, Width =  80}
	SpellE = {Range =  475, Speed =    0, Delay =    0, Width =   0}
	SpellR = {Range =    0, Speed = 2000, Delay = 1.00, Width = 160}
	qReady, wReady, eReady, rReady = false, false, false, false
	VP = VPrediction()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	wLevel = myHero:GetSpellData(_W).level
	Enemies = GetEnemyHeroes()
	if AutoCarry.Skills then
		AutoCarry.Skills:DisableAll()
	end
end

function EzrealCheck()
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

function EzrealKill()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.KillQ and GetDistance(enemy) < SpellQ.Range and qDmg > enemy.health then
				CastVPredQ(enemy)
			elseif Menu.KillW and GetDistance(enemy) < SpellQ.Range and wDmg > enemy.health then
				CastVPredW(enemy)
			elseif Menu.KillR and GetDistance(enemy) > Menu.MinR and GetDistance(enemy) < Menu.MaxR and rDmg > enemy.health then
				CastVPredR(enemy)
			end
		end
	end
end

function CastVPredQ(unit)
	if qReady and ValidTarget(unit) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SpellQ.Delay, SpellQ.Width, SpellQ.Range, SpellQ.Speed, myHero, true)
		if HitChance >= 2 and GetDistance(CastPosition) < SpellQ.Range then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

function CastVPredW(unit)
	if wReady and ValidTarget(unit) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SpellW.Delay, SpellW.Width, SpellW.Range, SpellW.Speed, myHero, false)
		if HitChance >= 2 and GetDistance(CastPosition) < SpellW.Range then
			CastSpell(_W, CastPosition.x, CastPosition.z)
		end
	end
end

function CastVPredR(unit)
	if rReady and ValidTarget(unit) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SpellR.Delay, SpellR.Width, Menu.MaxR, SpellR.Speed, myHero, false)
		if HitChance >= 2 and GetDistance(CastPosition) > Menu.MinR and GetDistance(CastPosition) < Menu.MaxR then
			CastSpell(_R, CastPosition.x, CastPosition.z)
		end
	end
end