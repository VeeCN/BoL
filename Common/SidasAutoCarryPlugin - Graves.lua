local Version = "1.0"

require "VPrediction"

local SpellQ = {Range =  950, Speed =  902, Delay = 0.25, Width =   8}
local SpellW = {Range =  950, Speed = 1650, Delay = 0.25, Width = 188}
local SpellE = {Range =  425, Speed =    0, Delay = 0.25, Width =  38}
local SpellR = {Range = 1000, Speed = 1400, Delay = 0.25, Width =  75}
local qReady, wReady, eReady, rReady = false, false, false, false

function PluginOnLoad()
	GravesLoad()
	GravesMenu()
end

function PluginOnTick()
	GravesCheck()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			GravesCombo(Target)
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			GravesHarass(Target)
		end
	end
	if Menu.DashesW then
		GravesDashes()
	end
	if Menu.ImmobileW then
		GravesImmobile()
	end
	GravesKill()
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

function GravesMenu()
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
	Menu:addParam("KillR", "击杀使用 R", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 大号铅弹 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("MaxQ", "使用的最大距离", SCRIPT_PARAM_SLICE, 500, 0, SpellQ.Range, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 烟雾弹 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ImmobileW", "目标禁锢时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("DashesW", "目标突进时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("MaxW", "使用的最大距离", SCRIPT_PARAM_SLICE, 600, 0, SpellW.Range, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 终极爆弹 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("MinR", "使用的最小距离", SCRIPT_PARAM_SLICE, 500, 0, SpellR.Range, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 显示设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DrawQ", "显示 Q 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawW", "显示 W 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawE", "显示 E 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawR", "显示 R 范围", SCRIPT_PARAM_ONOFF, false)
end

function GravesLoad()
	AutoCarry.SkillsCrosshair.range = 1000
	VP = VPrediction()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Enemies = GetEnemyHeroes()
	if AutoCarry.Skills then
		AutoCarry.Skills:DisableAll()
	end
end

function GravesCheck()
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

function GravesCombo(unit)
	if qReady and Menu.ComboQ and GetDistance(unit) < Menu.MaxQ then
		CastVPredQ(unit)
	end
	if wReady and Menu.ComboW and GetDistance(unit) < Menu.MaxW then
		CastVPredW(unit)
	end
end

function GravesHarass(unit)
	if qReady and Menu.HarassQ and GetDistance(unit) < Menu.MaxQ then
		CastVPredQ(unit)
	end
	if wReady and Menu.HarassW and GetDistance(unit) < Menu.MaxW then
		CastVPredW(unit)
	end
end

function GravesKill()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.KillQ and qDmg > enemy.health and GetDistance(enemy) < SpellQ.Range then
				CastVPredQ(enemy)
			elseif Menu.KillR and rDmg > enemy.health and GetDistance(enemy) < SpellR.Range then
				CastVPredR(enemy)
			end
		end
	end
end

function GravesDashes()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellW.Delay, SpellW.Width, SpellW.Speed, myHero)
			if IsDashing and CanHit and wReady and GetDistance(Position) < Menu.MaxW then
				CastSpell(_W, Position.x, Position.z)
			end
		end
	end
end

function GravesImmobile()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsImmobile, Pos = VP:IsImmobile(enemy, SpellW.Delay, SpellW.Width, SpellW.Speed, myHero)
			if IsImmobile and wReady and GetDistance(Pos) < SpellW.Range then
				CastSpell(_W, Pos.x, Pos.z)
			end
		end
	end
end

function CastVPredQ(unit)
	if qReady and ValidTarget(unit) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SpellQ.Delay, SpellQ.Width, SpellQ.Range, SpellQ.Speed, myHero, false)
		if HitChance >= 2 and GetDistance(CastPosition) < SpellQ.Range then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

function CastVPredW(unit)
	if wReady and ValidTarget(unit) then
		local PredictedPos, EnemyHit = VP:GetPredictedPos(unit, SpellW.Delay, SpellW.Speed, myHero, false)
		local CastPosition, SkillHit, Position = VP:GetCircularCastPosition(unit, SpellW.Delay, SpellW.Width, SpellW.Range, SpellW.Speed, myHero, false)
		if SkillHit >= 2 and GetDistance(CastPosition) < SpellW.Range then
			CastSpell(_W, CastPosition.x, CastPosition.z)
		elseif EnemyHit >= 2 and GetDistance(PredictedPos) < SpellW.Range then
			CastSpell(_W, PredictedPos.x, PredictedPos.z)
		end
	end
end

function CastVPredR(unit)
	if rReady and ValidTarget(unit) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SpellR.Delay, SpellR.Width, SpellR.Range, SpellR.Speed, myHero, false)
		if HitChance >= 2 and GetDistance(CastPosition) > Menu.MinR and GetDistance(CastPosition) < SpellR.Range then
			CastSpell(_R, CastPosition.x, CastPosition.z)
		end
	end
end