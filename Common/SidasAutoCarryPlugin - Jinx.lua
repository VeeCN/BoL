local Version = "1.0"

require "VPrediction"

local SpellQ = {Range =  700, Speed = 2000, Delay = 0.25, Width = 113}
local SpellW = {Range = 1500, Speed = 1200, Delay = 0.60, Width =  45}
local SpellE = {Range =  900, Speed = 1750, Delay = 0.95, Width = 113}
local SpellR = {Range = 4000, Speed = 1700, Delay = 0.60, Width = 105}
local qReady, wReady, eReady, rReady = false, false, false, false
local FishBones = false

function PluginOnLoad()
	JinxLoad()
	JinxMenu()
end

function PluginOnTick()
	JinxCheck()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			JinxCombo(Target)
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			JinxHarass(Target)
		end
	end
	if Menu.DashesE then
		JinxDashes()
	end
	if Menu.ImmobileE then
		JinxImmobile()
	end
	JinxKill()
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

function JinxMenu()
	Menu:addParam("sep", "---- [ 连招设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ComboQ", "连招使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboW", "连招使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboE", "连招使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 消耗设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("HarassQ", "消耗使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassW", "消耗使用 W", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("HarassE", "消耗使用 E", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 击杀设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("KillW", "击杀使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("KillR", "击杀使用 R", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 震荡电磁波 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("MinW", "使用的最小距离", SCRIPT_PARAM_SLICE, 500, 0, SpellW.Range, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 嚼火者手雷 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ImmobileE", "目标禁锢时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("DashesE", "目标突进时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("RangesE", "目标的距离小于", SCRIPT_PARAM_SLICE, 600, 0, SpellE.Range, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 超究极死神飞弹 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("MinR", "使用的最小距离", SCRIPT_PARAM_SLICE, 600, 0, SpellR.Range, -1)
	Menu:addParam("MaxR", "使用的最大距离", SCRIPT_PARAM_SLICE, 2000, 0, SpellR.Range, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 显示设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DrawQ", "显示 Q 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawW", "显示 W 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawE", "显示 E 范围", SCRIPT_PARAM_ONOFF, false)
end

function JinxLoad()
	AutoCarry.SkillsCrosshair.range = 4000
	VP = VPrediction()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Enemies = GetEnemyHeroes()
	if AutoCarry.Skills then
		AutoCarry.Skills:DisableAll()
	end
end

function JinxCheck()
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
	if myHero.range == 525.5 then
		FishBones = false
	else
		FishBones = true
	end
end

function JinxCombo(unit)
	if qReady and Menu.ComboQ and GetDistance(unit) < SpellQ.Range and AttackReset() then
		CastVPredQ(unit)
	end
	if wReady and Menu.ComboW and GetDistance(unit) > Menu.MinW and GetDistance(unit) < SpellW.Range then
		CastVPredW(unit)
	end
	if eReady and Menu.ComboE and GetDistance(unit) < SpellE.Range then
		CastVPredE(unit)
	end
end

function JinxHarass(unit)
	if qReady and Menu.HarassQ and GetDistance(unit) < SpellQ.Range and AttackReset() then
		CastVPredQ(unit)
	end
	if wReady and Menu.HarassW and GetDistance(unit) > Menu.MinW and GetDistance(unit) < SpellW.Range then
		CastVPredW(unit)
	end
	if eReady and Menu.HarassE and GetDistance(unit) < SpellE.Range then
		CastVPredE(unit)
	end
end

function JinxKill()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.KillW and wDmg > enemy.health and GetDistance(enemy) < SpellW.Range then
				CastVPredW(enemy)
			elseif Menu.KillR and rDmg > enemy.health and GetDistance(enemy) < Menu.MaxR then
				CastVPredR(enemy)
			end
		end
	end
end

function JinxDashes()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellE.Delay, SpellE.Width, SpellE.Speed, myHero)
			if IsDashing and CanHit and eReady and GetDistance(Position) < Menu.RangesE then
				CastSpell(_E, Position.x, Position.z)
			end
		end
	end
end

function JinxImmobile()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsImmobile, Pos = VP:IsImmobile(enemy, SpellE.Delay, SpellE.Width, SpellE.Speed, myHero)
			if IsImmobile and eReady and GetDistance(Pos) < SpellE.Range then
				CastSpell(_E, Pos.x, Pos.z)
			end
		end
	end
end

function JinxUltSpeed(unit)
	if rReady and ValidTarget(unit) then
		local Distance = GetDistance(unit)
		local Speed = (Distance > 1350 and (1350 * 1700 + ((Distance - 1350) * 2200)) / Distance or 1700)
		return Speed
	end
end

function AttackReset()
	if AutoCarry.shotFired or AutoCarry.Orbwalker:IsAfterAttack() then
		return true
	else
		return false
	end
end

function GenerateWallVector(Pos)
	local WallDisplacement = 120
	local HeroToWallVector = Vector(Vector(Pos) - Vector(myHero)):normalized()
	local RotatedVec1 = HeroToWallVector:perpendicular()
	local RotatedVec2 = HeroToWallVector:perpendicular2()
	local EndPoint1 = Vector(Pos) + Vector(RotatedVec1) * WallDisplacement
	local EndPoint2 = Vector(Pos) + Vector(RotatedVec2) * WallDisplacement
	local DiffVector = Vector(EndPoint2 - EndPoint1):normalized()
	return EndPoint1, EndPoint2, DiffVector
end

function GetWallCollision(unit)
	local TargetDestination, HitChance = VP:GetPredictedPos(unit, SpellE.Delay, SpellE.Speed, myHero, false)
	local TargetDestination2, HitChance2 = VP:GetPredictedPos(unit, SpellE.Delay, SpellE.Speed, myHero, false)
	if TargetDestination == nil or TargetDestination2 == nil then return end
	local TargetWaypoints = VP:GetCurrentWayPoints(unit)
	local Destination1 = TargetWaypoints[#TargetWaypoints]
	local Destination2 = TargetWaypoints[1]
	local Destination13D = {x=Destination1.x, y=myHero.y, z=Destination1.y}
	if TargetDestination ~= nil and HitChance >= 1 and HitChance2 >= 2 and GetDistance(Destination1, Destination2) > 100 then
		if GetDistance(TargetDestination, unit) > 5 then
			local UnitVector = Vector(Vector(TargetDestination) - Vector(unit)):normalized()
			Endpoint1, Endpoint2, Diffunitvector = GenerateWallVector(Destination13D)
			local DisplacedVector = Vector(unit) + Vector(Vector(Destination13D) - Vector(unit)):normalized() * ((unit.ms) * SpellE.Delay+110)
			local angle = UnitVector:angle(Diffunitvector)
			if angle ~= nil then
				if angle * 57.2957795 < 105 and angle * 57.2957795 > 75 and GetDistance(DisplacedVector, myHero) < SpellE.Range and eReady then
					CastSpell(_E, DisplacedVector.x, DisplacedVector.z)
				end
			end
		end
	elseif eReady and GetDistance(Destination2) < SpellE.Range and GetDistance(Destination1, Destination2) < 50 and GetDistance(TargetDestination, Destination13D) < 100 and VP:CountWaypoints(unit.networkID, os.clock() - 0.5) == 0 then
		CastSpell(_E, Destination13D.x, Destination13D.z)
	end
end

function CastVPredQ(unit)
	if qReady and ValidTarget(unit) then
		local PredictedPos, HitChance = VP:GetPredictedPos(unit, SpellQ.Delay, SpellQ.Speed, myHero, false)
		if PredictedPos ~= nil and HitChance ~= nil and GetDistance(unit) < SpellQ.Range then
			if FishBones then
				if (GetDistance(PredictedPos) < 550 + VP:GetHitBox(unit)) or (GetDistance(unit) < 550 + VP:GetHitBox(unit)) then
					CastSpell(_Q)
				end
			else
				if (GetDistance(PredictedPos) > 550 + VP:GetHitBox(unit)) or (GetDistance(unit) > 550 + VP:GetHitBox(unit)) then
					CastSpell(_Q)
				end
			end
		end
	end
end

function CastVPredW(unit)
	if wReady and ValidTarget(unit) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SpellW.Delay, SpellW.Width, SpellW.Range, SpellW.Speed, myHero, true)
		if HitChance >= 2 and GetDistance(CastPosition) < SpellW.Range then
			CastSpell(_W, CastPosition.x, CastPosition.z)
		end
	end
end

function CastVPredE(unit)
	if eReady and ValidTarget(unit) then
		local PredictedPos, EnemyHit = VP:GetPredictedPos(unit, SpellE.Delay, SpellE.Speed, myHero, false)
		local CastPosition, SkillHit, Position = VP:GetCircularCastPosition(unit, SpellE.Delay, SpellE.Width, SpellE.Range, SpellE.Speed, myHero, false)
		if GetDistance(unit) < SpellE.Range then
			GetWallCollision(unit)
		elseif EnemyHit >= 2 and GetDistance(PredictedPos) < SpellE.Range then
			CastSpell(_E, PredictedPos.x, PredictedPos.z)
		elseif SkillHit >= 2 and GetDistance(CastPosition) < SpellE.Range then
			CastSpell(_E, CastPosition.x, CastPosition.z)
		end
	end
end

function CastVPredR(unit)
	if rReady and ValidTarget(unit) then
		local UltSpeed = JinxUltSpeed(unit)
		local PredictedPos, EnemyHit = VP:GetPredictedPos(unit, SpellR.Delay, UltSpeed, myHero, false)
		local CastPosition, SkillHit, Position = VP:GetLineCastPosition(unit, SpellR.Delay, SpellR.Width, Menu.MaxR, UltSpeed, myHero, false)
		if SkillHit >= 2 and GetDistance(CastPosition) > Menu.MinR and GetDistance(CastPosition) < Menu.MaxR then
			CastSpell(_R, CastPosition.x, CastPosition.z)
		elseif EnemyHit >= 2 and GetDistance(PredictedPos) > Menu.MinR and GetDistance(PredictedPos) < Menu.MaxR then
			CastSpell(_R, PredictedPos.x, PredictedPos.z)
		end
	end
end