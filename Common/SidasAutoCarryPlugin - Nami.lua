local Version = "1.0"

require "VPrediction"

local SpellQ = {Range =  875, Speed = 1750, Delay = 0.25, Width = 150}
local SpellW = {Range =  725, Speed = 2000, Delay = 0.25, Width =   0}
local SpellE = {Range =  800, Speed =    0, Delay = 0.25, Width =   0}
local SpellR = {Range = 2750, Speed = 1200, Delay = 0.50, Width = 244}
local qReady, wReady, eReady, rReady = false, false, false, false
local Interrupt = {}
local InterruptList = {
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

function PluginOnLoad()
	NamiLoad()
	NamiMenu()
end

function PluginOnTick()
	NamiCheck()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			NamiCombo(Target)
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			NamiHarass(Target)
		end
	end
	if Menu.DashesQ then
		NamiDashes()
	end
	if Menu.ImmobileQ then
		NamiImmobile()
	end
	NamiKill()
end

function PluginOnProcessSpell(unit, spell)
	if Menu.InterruptQ then
		if #Interrupt > 0 then
			for _, Inter in pairs(Interrupt) do
				if spell.name == Inter.spellName and unit.team ~= myHero.team then
					if Menu[Inter.spellName] and GetDistance(unit) < SpellQ.Range then
						CastSpell(_Q, unit.x, unit.z)
					end
				end
			end
		end
	end
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

function NamiMenu()
	Menu:addParam("sep", "---- [ 连招设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ComboQ", "连招使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboW", "连招使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboE", "连招使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 消耗设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("HarassQ", "消耗使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassW", "消耗使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassE", "消耗使用 E", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 技能设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("KillQ", "击杀使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("KillW", "击杀使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 碧波之牢 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ImmobileQ", "目标禁锢时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("DashesQ", "目标突进时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("RangesQ", "突进的距离小于", SCRIPT_PARAM_SLICE, 600, 0, SpellQ.Range, -1)
	Menu:addParam("InterruptQ", "目标大招时使用", SCRIPT_PARAM_ONOFF, true)
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

	Menu:addParam("sep", "---- [ 冲击之潮 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("HealthW", "使用的血量小于", SCRIPT_PARAM_SLICE, 80, 0, 100, 0)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 显示设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DrawQ", "显示 Q 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawW", "显示 W 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawE", "显示 E 范围", SCRIPT_PARAM_ONOFF, false)
end

function NamiLoad()
	AutoCarry.SkillsCrosshair.range = 2750
	VP = VPrediction()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Enemies = GetEnemyHeroes()
	Alliance = GetAllyHeroes()
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

function NamiCheck()
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

function NamiCombo(unit)
	if qReady and Menu.ComboQ and GetDistance(unit) < SpellQ.Range then
		CastVPredQ(unit)
	end
	if wReady and Menu.ComboW and GetDistance(unit) < SpellW.Range then
		CastVPredW(unit)
	end
	if eReady and Menu.ComboE and GetDistance(unit) < SpellE.Range then
		CastVPredE(unit)
	end
end

function NamiHarass(unit)
	if qReady and Menu.HarassQ and GetDistance(unit) < SpellQ.Range then
		CastVPredQ(unit)
	end
	if wReady and Menu.HarassW and GetDistance(unit) < SpellW.Range then
		CastVPredW(unit)
	end
	if eReady and Menu.HarassE and GetDistance(unit) < SpellE.Range then
		CastVPredE(unit)
	end
end

function NamiKill()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.KillQ and GetDistance(enemy) < SpellQ.Range and qDmg > enemy.health then
				CastVPredQ(enemy)
			elseif Menu.KillW and GetDistance(enemy) < SpellW.Range and wDmg > enemy.health then
				CastVPredW(enemy)
			end
		end
	end
end

function NamiDashes()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellQ.Delay, SpellQ.Width, SpellQ.Speed, myHero)
			if IsDashing and CanHit and qReady and GetDistance(Position) < Menu.RangesQ then
				CastSpell(_Q, Position.x, Position.z)
			end
		end
	end
end

function NamiImmobile()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsImmobile, Pos = VP:IsImmobile(enemy, SpellQ.Delay, SpellQ.Width, SpellQ.Speed, myHero)
			if IsImmobile and qReady and GetDistance(Pos) < SpellQ.Range then
				CastSpell(_Q, Pos.x, Pos.z)
			end
		end
	end
end

function CountEnemies(range, unit)
	local enemys = 0
	for _, enemy in ipairs(Enemies) do
		if ValidTarget(enemy) and not enemy.dead and GetDistance(enemy, unit) < (range or math.huge) then
			enemys = enemys + 1
		end
	end
	return enemys
end

function CastVPredQ(unit)
	if qReady and ValidTarget(unit) then
		local PredictedPos, EnemyHit = VP:GetPredictedPos(unit, SpellQ.Delay, SpellQ.Speed, myHero, false)
		local CastPosition, SkillHit, Position = VP:GetCircularCastPosition(unit, SpellQ.Delay, SpellQ.Width, SpellQ.Range, SpellQ.Speed, myHero, false)
		if SkillHit >= 2 and GetDistance(CastPosition) < SpellQ.Range then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		elseif EnemyHit >= 2 and GetDistance(PredictedPos) < SpellQ.Range then
			CastSpell(_Q, PredictedPos.x, PredictedPos.z)
		end
	end
end

function CastVPredW(unit)
	if wReady then
		local WTarget = nil
		if (myHero.health / myHero.maxHealth) < (Menu.HealthW / 100) and CountEnemies(725, myHero) > 0 then
			WTarget = myHero
		end
		for _, ally in ipairs(Alliance) do
			if (ally.health / ally.maxHealth) < (Menu.HealthW / 100) and CountEnemies(725, ally) > 0 and GetDistance(ally) < SpellW.Range then
				if not WTarget or WTarget.health > ally.health then
					WTarget = ally
				end
			end
		end
		if WTarget then
			CastSpell(_W, WTarget)
		else
			CastSpell(_W, unit)
		end
	end
end

function CastVPredE(unit)
	if eReady then
		local ETarget = myHero
		for _, ally in ipairs(Alliance) do
			if ally.damage > myHero.damage and GetDistance(ally) < SpellE.Range then
				ETarget = ally
			end
		end
		CastSpell(_E, ETarget)
	end
end