local Version = "1.0"

require "VPrediction"

local SpellQ = {Range = 1175, Speed = 1200, Delay = 0.25, Width =  53}
local SpellW = {Range =  900, Speed =   20, Delay = 0.25, Width = 131}
local SpellE = {Range =  750, Speed =   20, Delay = 0.52, Width =   0}
local SpellR = {Range =  600, Speed =   20, Delay = 0.35, Width =   0}
local qReady, wReady, eReady, rReady = false, false, false, false

function PluginOnLoad()
	MorganaLoad()
	MorganaMenu()
end

function PluginOnTick()
	MorganaCheck()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			MorganaCombo(Target)
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			MorganaHarass(Target)
		end
	end
	if Menu.DashesQ then
		MorganaDashes()
	end
	if Menu.ImmobileQ or Menu.ImmobileW then
		MorganaImmobile()
	end
	MorganaKill()
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
		if Menu.DrawR and rReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellR.Range, 0xFFFFFF)
		end
	end
end

function MorganaMenu()
	Menu:addParam("sep", "---- [ 连招设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ComboQ", "连招使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboW", "连招使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboR", "连招使用 R", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 消耗设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("HarassQ", "消耗使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassW", "消耗使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassR", "消耗使用 R", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 技能设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("KillQ", "击杀使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("KillW", "击杀使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("EnemiesR", "人数设置 R", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 暗之禁锢 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ImmobileQ", "目标禁锢时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("DashesQ", "目标突进时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("RangesQ", "目标的距离小于", SCRIPT_PARAM_SLICE, 600, 0, SpellQ.Range, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 痛苦腐蚀 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ImmobileW", "目标禁锢时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 显示设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DrawQ", "显示 Q 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawW", "显示 W 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawE", "显示 E 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawR", "显示 R 范围", SCRIPT_PARAM_ONOFF, false)
end

function MorganaLoad()
	AutoCarry.SkillsCrosshair.range = 1175
	VP = VPrediction()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Enemies = GetEnemyHeroes()
	if AutoCarry.Skills then
		AutoCarry.Skills:DisableAll()
	end
end

function MorganaCheck()
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

function MorganaCombo(unit)
	if qReady and Menu.ComboQ and GetDistance(unit) < SpellQ.Range then
		CastVPredQ(unit)
	end
	if wReady and Menu.ComboW and GetDistance(unit) < SpellW.Range then
		CastVPredW(unit)
	end
	if rReady and Menu.ComboR and GetDistance(unit) < SpellR.Range and CountEnemyHeroInRange(SpellR.Range) >= Menu.EnemiesR then
		CastSpell(_R)
	end
end

function MorganaHarass(unit)
	if qReady and Menu.HarassQ and GetDistance(unit) < SpellQ.Range then
		CastVPredQ(unit)
	end
	if wReady and Menu.HarassW and GetDistance(unit) < SpellW.Range then
		CastVPredW(unit)
	end
	if rReady and Menu.HarassR and GetDistance(unit) < SpellR.Range and CountEnemyHeroInRange(SpellR.Range) >= Menu.EnemiesR then
		CastSpell(_R)
	end
end

function MorganaKill()
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

function MorganaDashes()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellQ.Delay, SpellQ.Width, SpellQ.Speed, myHero)
			if IsDashing and CanHit and qReady and GetDistance(Position) < Menu.RangesQ then
				CastSpell(_Q, Position.x, Position.z)
			end
		end
	end
end

function MorganaImmobile()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.ImmobileQ then
				local IsImmobile, Pos = VP:IsImmobile(enemy, SpellQ.Delay, SpellQ.Width, SpellQ.Speed, myHero)
				if IsImmobile and qReady and GetDistance(Pos) < SpellQ.Range then
					CastSpell(_Q, Pos.x, Pos.z)
				end
			elseif Menu.ImmobileW then
				local IsImmobile, Pos = VP:IsImmobile(enemy, SpellW.Delay, SpellW.Width, SpellW.Speed, myHero)
				if IsImmobile and wReady and GetDistance(Pos) < SpellW.Range then
					CastSpell(_W, Pos.x, Pos.z)
				end
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
		local CastPosition, HitChance, Position = VP:GetCircularCastPosition(unit, SpellW.Delay, SpellW.Width, SpellW.Range, SpellW.Speed, myHero, false)
		if HitChance >= 2 and GetDistance(CastPosition) < SpellW.Range then
			CastSpell(_W, CastPosition.x, CastPosition.z)
		end
	end
end