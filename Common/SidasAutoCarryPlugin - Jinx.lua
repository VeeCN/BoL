local version = "1.16"

require "VPrediction"
require 'Collision'
require 'Prodiction'

local ProdOneLoaded = false
local ProdFile = LIB_PATH .. "Prodiction.lua"
local VP = VPrediction()
local Col = Collision(3000, 1700, 0.316, 140)
local SpellW = {Speed = 3300, Range = 1500, Delay = 0.600, Width = 60}
local SpellE = {Speed = 1750, Delay = 0.5 + 0.2658, Range = 900, Width = 120}
local SpellR = {Speed = 1700, Delay = 0.066 + 0.250, Range = 25750, Width = 140}
local QReady, WReady, EReady, RReady = nil, nil, nil, nil
local QObject = nil
local QEndPos = nil
local LastDistance = nil
local TargetQPos = nil
local isFishBones = true
local FishStacks = 0
local Walking = false
local QRange

function JinxMenu()
	Menu:addSubMenu("---- [ 连招设置 ] ----", "ComboSub")
	Menu:addSubMenu("---- [ 消耗设置 ] ----", "HarassSub")
	Menu:addSubMenu("---- [ 击杀设置 ] ----", "KSSub")
	Menu:addSubMenu("---- [ 高级设置 ] ----", "ExtrasSub")
	Menu:addSubMenu("---- [ 显示设置 ] ----", "DrawSub")
	--Combo
	Menu.ComboSub:addParam("useQ", "连招使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("useW", "连招使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("useE", "连招使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("mManager", "蓝耗管理 %", SCRIPT_PARAM_SLICE, 0, 0, 100, -1)
	--Harass
	Menu.HarassSub:addParam("useQ", "消耗使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu.HarassSub:addParam("useW", "消耗使用 W", SCRIPT_PARAM_ONOFF, false)
	Menu.HarassSub:addParam("useE", "消耗使用 E", SCRIPT_PARAM_ONOFF, false)
	Menu.HarassSub:addParam("mManager", "蓝耗管理 %", SCRIPT_PARAM_SLICE, 0, 0, 100, -1)
	--KS
	Menu.KSSub:addParam("useW", "击杀使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu.KSSub:addParam("useR", "击杀使用 R", SCRIPT_PARAM_ONOFF, true)
	--Draw
	Menu.DrawSub:addParam("DrawOtherQ", "显示 Q 范围", SCRIPT_PARAM_ONOFF, false)
	Menu.DrawSub:addParam("DrawW", "显示 W 范围", SCRIPT_PARAM_ONOFF, false)
	Menu.DrawSub:addParam("DrawE", "显示 E 范围", SCRIPT_PARAM_ONOFF, false)
	Menu.DrawSub:addParam("DrawR", "显示 R 范围", SCRIPT_PARAM_ONOFF, false)
	--Extras
	Menu.ExtrasSub:addParam("sep", "---- [ 枪炮交响曲 ] ----", SCRIPT_PARAM_INFO, "")
	Menu.ExtrasSub:addParam("SwapDistance", "超出范围时切换", SCRIPT_PARAM_ONOFF, true)
	Menu.ExtrasSub:addParam("SwapAOE", "范围伤害时切换", SCRIPT_PARAM_ONOFF, false)
	Menu.ExtrasSub:addParam("SwapThree", "三层加速时切换", SCRIPT_PARAM_ONOFF, false)
	Menu.ExtrasSub:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	Menu.ExtrasSub:addParam("sep", "---- [ 震荡电磁波 ] ----", SCRIPT_PARAM_INFO, "")
	Menu.ExtrasSub:addParam("WRange", "使用最小距离", SCRIPT_PARAM_SLICE, 300, 0, 1450, -1)
	Menu.ExtrasSub:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	Menu.ExtrasSub:addParam("sep", "---- [ 嚼火者手雷 ] ----", SCRIPT_PARAM_INFO, "")
	Menu.ExtrasSub:addParam("EImmobile", "目标禁锢时使用", SCRIPT_PARAM_ONOFF, true)
	Menu.ExtrasSub:addParam("EDashes", "目标突进时使用", SCRIPT_PARAM_ONOFF, true)
	Menu.ExtrasSub:addParam("EAutoCast", "目标存在时使用", SCRIPT_PARAM_ONOFF, true)
	Menu.ExtrasSub:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	Menu.ExtrasSub:addParam("sep", "---- [ 超究极死神飞弹 ] ----", SCRIPT_PARAM_INFO, "")
	Menu.ExtrasSub:addParam("MinRRange", "使用最小距离", SCRIPT_PARAM_SLICE, 500, 0, 1800, -1)
	Menu.ExtrasSub:addParam("MaxRRange", "使用最大距离", SCRIPT_PARAM_SLICE, 2000, 0, 3600, -1)
	Menu.ExtrasSub:addParam("REnemies", "使用最小人数", SCRIPT_PARAM_SLICE, 1, 1, 5, 0)
	Menu.ExtrasSub:addParam("ROverkill", "检测过量击杀", SCRIPT_PARAM_ONOFF, false)
	Menu.ExtrasSub:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	Menu.ExtrasSub:addParam("sep", "---- [ 其他设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu.ExtrasSub:addParam("Debug", "调试模式", SCRIPT_PARAM_ONOFF, false)
	if ProdOneLoaded then
		Menu.ExtrasSub:addParam("Prodiction", "使用 Prodiction 预判", SCRIPT_PARAM_ONOFF, false)
	end
end

function JinxLoad()
	AutoCarry.SkillsCrosshair.range = 1500
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
end

function PluginOnLoad()
	JinxLoad()
	JinxMenu()
end

function IsMyManaLow()
	if myHero.mana < (myHero.maxMana * ( Menu.ComboSub.mManager / 100)) then
		return true
	else
		return false
	end
end

function IsMyManaLowHarass()
	if myHero.mana < (myHero.maxMana * ( Menu.HarassSub.mManager / 100)) then
		return true
	else
		return false
	end
end

--End Credit Trees
function PluginOnTick()
	Check()
	if Menu2.AutoCarry and Target ~= nil then
		Combo(Target)
	elseif Menu2.AutoCarry and WTarget ~= nil then
		Combo(WTarget)
	end
	if (Menu2.MixedMode or Menu2.LaneClear) and Target ~= nil then
		Harass(Target)
	elseif (Menu2.MixedMode or Menu2.LaneClear) and WTarget ~= nil then
		Harass(WTarget)
	elseif (Menu2.MixedMode or Menu2.LaneClear) and WTarget == nil and not isFishBones then
		CastSpell(_Q)
	end
	if Menu.ExtrasSub.EImmobile then
		CheckImmobile()
	end
	if Menu.ExtrasSub.EDashes then
		CheckDashes()
	end
	KS()
end

function Combo(Target)
	if GetDistance(Target) < 1575 and Menu.ComboSub.useW and not IsMyManaLow() then
		CastW(Target)
	end
	if EReady and Menu.ComboSub.useE and not IsMyManaLow() then
		CastE(Target)
	end
	if EReady and Menu.ExtrasSub.EAutoCast and not IsMyManaLow()then
		AutoCastE(Target)
	end
	if QReady and Menu.ComboSub.useQ and not IsMyManaLow() then
		Swap(Target)
	end
end

function Swap(Target)
	if Target ~= nil and not Target.dead and ValidTarget(Target) and QReady then
		local PredictedPos, HitChance = CombinedPos(Target, 0.25, math.huge, myHero, false)
		if PredictedPos ~= nil and HitChance ~= nil then
			if isFishBones then
				if Menu.ExtrasSub.SwapThree and FishStacks == 3 and GetDistance(PredictedPos) < QRange then
					CastSpell(_Q)
				end
				if Menu.ExtrasSub.SwapDistance and GetDistance(Target) > 575 + VP:GetHitBox(Target) and GetDistance(PredictedPos) > 575 + VP:GetHitBox(Target) and GetDistance(PredictedPos) < QRange + VP:GetHitBox(Target) then
					CastSpell(_Q)
				end
				if Menu.ExtrasSub.SwapAOE and CountEnemyNearPerson(Target, 150) > 1 and FishStacks > 2 then 
					CastSpell(_Q)
				end
			else
				if Menu.ExtrasSub.SwapAOE and CountEnemyNearPerson(Target, 150) > 1 then 
					return
				end
				if Menu.ExtrasSub.SwapThree and FishStacks < 3 and GetDistance(PredictedPos) < 575 + VP:GetHitBox(Target) and GetDistance(Target) < 575 + VP:GetHitBox(Target) then
					CastSpell(_Q)
				end
				if Menu.ExtrasSub.SwapDistance and GetDistance(PredictedPos) < 575 + VP:GetHitBox(Target) and GetDistance(Target) < 575 + VP:GetHitBox(Target) then
					CastSpell(_Q)
				end
				if IsMyManaLow() and GetDistance(Target) < 575 + VP:GetHitBox(Target) then
					CastSpell(_Q)
				end 
				if (Menu2.MixedMode or Menu2.LaneClear) and GetDistance(Target) > 575 + VP:GetHitBox(Target) + 50 then
					CastSpell(_Q)
				end
			end
		end
	end
end

function Harass(Target)
	if WReady and Menu.HarassSub.useW and not IsMyManaLowHarass() then
		CastW(Target)
	end
	if QReady and Menu.HarassSub.useQ  and not IsMyManaLowHarass() then
		Swap(Target)
	end
	if EReady and Menu.HarassSub.useE and not IsMyManaLowHarass() then
		CastE(Target)
	end
end

function CastE(Target)
	if EReady and GetDistance(Target) < 1100 then
		GetWallCollision(Target)
	end
end

function CastW(Target)
	local CastPosition, HitChance, Pos = CombinedPredict(Target, SpellW.Delay, SpellW.Width, SpellW.Range, SpellW.Speed, myHero, true)
	if CastPosition ~= nil and HitChance ~= nil then
		if GetDistance(Target) < 600 and WReady and Reset(Target) and HitChance >= 2 and GetDistance(Target) > Menu.ExtrasSub.WRange then
			CastSpell(_W, CastPosition.x, CastPosition.z)
		elseif GetDistance(Target) > 600 and HitChance >= 2 and GetDistance(Target) > Menu.ExtrasSub.WRange then
			CastSpell(_W, CastPosition.x, CastPosition.z)
		end
	end
end

function CastR(Target)
	if Target ~= nil and GetDistance(Target) < Menu.ExtrasSub.MaxRRange and RReady then
		if CountEnemyNearPerson(Target, 250) > Menu.ExtrasSub.REnemies then
			local CurrentRSpeed = JinxUltSpeed(Target)
			local RAoEPosition, RHitchance, NumHit = VP:GetCircularAOECastPosition(Target, SpellR.Delay, SpellR.Width, SpellR.Range, CurrentRSpeed, myHero)
			if RHitchance >= 2 and RAoEPosition ~= nil and GetDistance(RAoEPosition) < Menu.ExtrasSub.MaxRRange then
				CastSpell(_R, RAoEPosition.x, RAoEPosition.z)
			end
		end
		if GetDistance(Target) > Menu.ExtrasSub.MinRRange and Menu.ExtrasSub.ROverkill and GetDistance(Target) < Menu.ExtrasSub.MaxRRange then
			local RDamage = getDmg("R", Target, myHero)
			local ADamage = getDmg("AD", Target, myHero)
			if Target.health < ADamage * 3.5 then
				return
			elseif Target.health < RDamage then
				local CurrentRSpeed = JinxUltSpeed(Target)
				local RPosition, HitChance, Pos = CombinedPredict(Target, SpellR.Delay, SpellR.Width, Menu.ExtrasSub.MaxRRange, CurrentRSpeed, myHero, false)
				if RPosition ~= nil and HitChance ~= nil then
					if HitChance >= 2 then
						CastSpell(_R, RPosition.x, RPosition.z)
					end
				end
			end
		elseif GetDistance(Target) < Menu.ExtrasSub.MaxRRange then
			local RDamage = getDmg("R", Target, myHero)
			local ADamage = getDmg("AD", Target, myHero)
			if Target.health < RDamage then
				local CurrentRSpeed = JinxUltSpeed(Target)
				local RPosition, HitChance, Pos = CombinedPredict(Target, SpellR.Delay, SpellR.Width, Menu.ExtrasSub.MaxRRange, CurrentRSpeed, myHero, false)
				if RPosition ~= nil and HitChance ~= nil then
					if HitChance >= 2 then
						CastSpell(_R, RPosition.x, RPosition.z)
					end
				end
			end
		end
	end
end

function KS()
	local Enemies = GetEnemyHeroes()
	for idx, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) and GetDistance(enemy) < Menu.ExtrasSub.MaxRRange and Menu.KSSub.useR then
			if getDmg("R", enemy, myHero) > enemy.health then
				CastR(enemy)
			end
		elseif  not enemy.dead and ValidTarget(enemy) and GetDistance(enemy) < SpellW.Range and Menu.KSSub.useW then
			if getDmg("W", enemy, myHero) > enemy.health then
				CastW(enemy)
			end
		end
	end
end

function CheckImmobile()
	local Enemies = GetEnemyHeroes()
	for idx, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) and GetDistance(enemy) < SpellW.Range and Menu.ExtrasSub.EImmobile then
			local IsImmobile, pos = VP:IsImmobile(enemy, 0.605, SpellE.Width, SpellW.Speed, myHero)
			if IsImmobile and GetDistance(pos) < SpellE.Range and EReady then
				CastSpell(_E, pos.x, pos.z)
			end
		end
	end
end

function CheckDashes()
	local Enemies = GetEnemyHeroes()
	for idx, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) and GetDistance(enemy) < SpellW.Range and Menu.ExtrasSub.EImmobile then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, 0.250, 10, math.huge, myHero)
			if IsDashing and CanHit and GetDistance(Position) < SpellE.Range and EReady then
				local DashVector = Vector(Vector(Position) - Vector(enemy)):normalized()*((SpellE.Delay - 0.250)*enemy.ms)
				local CastPosition = Position + DashVector
				if GetDistance(CastPosition) < SpellE.Range then
					CastSpell(_E, CastPosition.x, CastPosition.z)
				end
			end
		end
	end
end

function AutoCastE(Target)
	if Target ~= nil and not Target.dead and ValidTarget(Target, 1500) then
		local CastPosition, HitChance, Position = VP:GetCircularCastPosition(Target, SpellE.Delay+0.2, 60, SpellE.Range, SpellE.Speed, myHero, false)
		if HitChance >= 3 and EReady and GetDistance(CastPosition) < SpellE.Range then
			CastSpell(_E, CastPosition.x, CastPosition.z)
		end
	end
end

function Reset(Target)
	if GetDistance(Target) > 580 then
		return true
	elseif _G.MMA_Loaded and _G.MMA_NextAttackAvailability < 0.6 then
		return true
	elseif _G.AutoCarry and (_G.AutoCarry.shotFired or _G.AutoCarry.Orbwalker:IsAfterAttack()) then
		return true
	else
		return false
	end
end

function PluginOnDraw()
	if Menu.ExtrasSub.Debug then
		DrawText3D("Current FishBones status is " .. tostring(isFishBones), myHero.x+200, myHero.y, myHero.z+200, 25,  ARGB(255,255,0,0), true)
		DrawText3D("Current FishBones stacks is " .. tostring(FishStacks), myHero.x, myHero.y, myHero.z, 25,  ARGB(255,255,0,0), true)
		if WTarget ~= nil then
			DrawCircle2(WTarget.x, WTarget.y, WTarget.z, 150, ARGB(255, 0, 255, 255))
		end
	end
	if Menu.DrawSub.DrawW then
		DrawCircle2(myHero.x, myHero.y, myHero.z, SpellW.Range, ARGB(255, 0, 255, 255))
	end
	if Menu.DrawSub.DrawE then
		DrawCircle2(myHero.x, myHero.y, myHero.z, SpellE.Range, ARGB(255, 0, 255, 255))
	end
	if Menu.DrawSub.DrawR then
		DrawCircle2(myHero.x, myHero.y, myHero.z, Menu.ExtrasSub.MaxRRange, ARGB(255, 0, 255, 255))
	end
	if Menu.DrawSub.DrawOtherQ then
		if isFishBones then
			DrawCircle2(myHero.x, myHero.y, myHero.z, 600,ARGB(255, 255, 0, 0))
		else
			DrawCircle2(myHero.x, myHero.y, myHero.z, QRange, ARGB(255, 255, 0, 0))
		end
	end
end

function OrbwalkToPosition(position)
	if position ~= nil then
		if _G.AutoCarry.Orbwalker then
			_G.AutoCarry.Orbwalker:OverrideOrbwalkLocation(position)
		elseif _G.MMA_Loaded then
			moveToCursor(position.x, position.z)
		end
	else
		if _G.AutoCarry.Orbwalker then
			_G.AutoCarry.Orbwalker:OverrideOrbwalkLocation(nil)
		elseif _G.MMA_Loaded then
			moveToCursor()
		end
	end
end

function OnGainBuff(unit, buff)
	if unit.isMe and buff.name == 'jinxqramp' then
		FishStacks = 1
	end
end

function OnUpdateBuff(unit, buff)
	if unit.isMe and buff.name == 'jinxqramp' then
		FishStacks = buff.stack
	end
end

function OnLoseBuff(unit, buff)
	if unit.isMe and buff.name == 'jinxqramp' then
		FishStacks = 0
	end
end

function Check()
	Target = AutoCarry.GetAttackTarget()
	WTarget = AutoCarry.GetAttackTarget()
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	if QObject == nil and not QReady then
		QEndPos = nil
		LastDistance = nil
	end
	QRange = myHero:GetSpellData(_Q).level*25 + 575
	if myHero.range == 525.5 then
		isFishBones = true
	else
		isFishBones = false
	end
end

function GenerateWallVector(pos)
	local WallDisplacement = 120
	local HeroToWallVector = Vector(Vector(pos) - Vector(myHero)):normalized()
	local RotatedVec1 = HeroToWallVector:perpendicular()
	local RotatedVec2 = HeroToWallVector:perpendicular2()
	local EndPoint1 = Vector(pos) + Vector(RotatedVec1)*WallDisplacement
	local EndPoint2 = Vector(pos) + Vector(RotatedVec2)*WallDisplacement
	local DiffVector = Vector(EndPoint2 - EndPoint1):normalized()
	return EndPoint1, EndPoint2, DiffVector
end

function GetWallCollision(Target)
	local TargetDestination, HitChance = CombinedPos(Target, 1.000, math.huge, myHero, false)
	local TargetDestination2, HitChance2 = CombinedPos(Target, 0.250, math.huge, myHero, false)
	if TargetDestination == nil or TargetDestination2 == nil then return end
	local TargetWaypoints = VP:GetCurrentWayPoints(Target)
	local Destination1 = TargetWaypoints[#TargetWaypoints]
	local Destination2 = TargetWaypoints[1]
	local Destination13D = {x=Destination1.x, y=myHero.y, z=Destination1.y}
	if TargetDestination ~= nil and HitChance >= 1 and HitChance2 >= 2 and GetDistance(Destination1, Destination2) > 100 then
		if GetDistance(TargetDestination, Target) > 5 then
			local UnitVector = Vector(Vector(TargetDestination) - Vector(Target)):normalized()
			Endpoint1, Endpoint2, Diffunitvector = GenerateWallVector(Destination13D)
			local DisplacedVector = Vector(Target) + Vector(Vector(Destination13D) - Vector(Target)):normalized()*((Target.ms)*SpellE.Delay+110)
			local angle = UnitVector:angle(Diffunitvector)
			if angle ~= nil then
				--print('Angle Generated!' .. tostring(angle*57.2957795))
				if angle*57.2957795 < 105 and angle*57.2957795 > 75 and GetDistance(DisplacedVector, myHero) < SpellE.Range and EReady then
					CastSpell(_E, DisplacedVector.x, DisplacedVector.z)
				end
			end
		end
	elseif EReady and GetDistance(Destination2) < SpellE.Range and GetDistance(Destination1, Destination2) < 50 and GetDistance(TargetDestination, Destination13D) < 100 and VP:CountWaypoints(Target.networkID, os.clock() - 0.5) == 0 then
		CastSpell(_E, Destination13D.x, Destination13D.z)
	end
end

function JinxUltSpeed(Target)
	if Target ~= nil and ValidTarget(Target) then
		local Distance = GetDistance(Target)
		local Speed = (Distance > 1350 and (1350*1700+((Distance-1350)*2200))/Distance or 1700)
		return Speed
	end
end

--Credit Xetrok
function CountEnemyNearPerson(person,vrange)
	count = 0
	for i=1, heroManager.iCount do
		currentEnemy = heroManager:GetHero(i)
		if currentEnemy.team ~= myHero.team then
			if GetDistance(currentEnemy, person) <= vrange and not currentEnemy.dead then count = count + 1 end
		end
	end
	return count
end

--End Credit Xetrok
--Credit
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8, round(180 / math.deg((math.asin((chordlength / (2 * radius)))))))
	quality = 2 * math.pi / quality
	radius = radius * .92
	local points = {}
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	end
	DrawLines2(points, width or 1, color or 4294967295)
end

function round(num)
	if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircle2(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
		DrawCircleNextLvl(x, y, z, radius, 1, color, 100)
	end
end

function CombinedPredict(Target, Delay, Width, Range, Speed, myHero, boolean)
	if Target == nil or Target.dead or not ValidTarget(Target) then return end
	if not ProdOneLoaded or not Menu.ExtrasSub.Prodiction then
		local CastPosition, Hitchance, Position = VP:GetLineCastPosition(Target, Delay, Width, Range, Speed, myHero, boolean)
		if CastPosition ~= nil and Hitchance >= 1 then
			return CastPosition, Hitchance+1, Position
		end
	elseif ProdOneLoaded and Menu.ExtrasSub.Prodiction then
		local CastPosition, info = Prodiction.GetPrediction(Target, Range, Speed, Delay, Width, myHero)
		local isCol = false
		if info ~= nil and info.mCollision() ~= nil then
			isCol, _ = info.mCollision()
			if Menu.ExtrasSub.Debug and CastPosition ~= nil then
				print(CastPosition)
				print(isCol)
			end
		end
		if info ~= nil and info.hitchance ~= nil and CastPosition ~= nil and isCol and boolean then
			return CastPosition, 0, CastPosition
		elseif info ~= nil and info.hitchance ~= nil and CastPosition ~= nil then
			Hitchance = info.hitchance
			return CastPosition, Hitchance, CastPosition
		end
	end
end

function CombinedPos(Target, Delay, Speed, myHero, boolean)
	if Target == nil or Target.dead or not ValidTarget(Target) then return end
	if Collision == nil then Collision = false end
	if not ProdOneLoaded or not Menu.ExtrasSub.Prodiction then
		local PredictedPos, HitChance = VP:GetPredictedPos(Target, Delay, Speed, myHero, boolean)
		return PredictedPos, HitChance
	elseif ProdOneLoaded and Menu.ExtrasSub.Prodiction then
		local PredictedPos, info = Prodiction.GetPrediction(Target, 5000, Speed, Delay, 10, myHero)
		local isCol = false
		local hitchance = 0
		if info ~= nil and info.mCollision() ~= nil then
			isCol, _ = info.mCollision()
			hitchance = info.hitchance
		end
		if PredictedPos ~= nil and info ~= nil and isCol and boolean then
			return PredictedPos, 0
		elseif PredictedPos ~= nil and info ~= nil and hitchance~= nil then
			return PredictedPos, hitchance
		end
	end
end